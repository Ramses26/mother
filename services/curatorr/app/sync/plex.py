"""Plex sync — pull libraries via XML API, enrich movies/tv with Plex metadata."""
import logging
import xml.etree.ElementTree as ET
from datetime import datetime

import httpx
from app.config import PLEX_INSTANCES
from app.database import get_config
from app.log_events import log_event

log = logging.getLogger('curatorr.sync.plex')


def _detect_hdr(video_stream: ET.Element) -> str:
    """Detect HDR format from Plex video stream XML element."""
    color_transfer = video_stream.get('colorTransfer', '') or ''
    color_space = video_stream.get('colorSpace', '') or ''
    bit_depth = video_stream.get('bitDepth', '')
    display_title = video_stream.get('displayTitle', '') or ''

    if 'dolby' in display_title.lower() or 'dv' in display_title.lower():
        return 'DolbyVision'
    if 'hdr10+' in display_title.lower():
        return 'HDR10+'
    if 'hdr' in display_title.lower() or 'hdr10' in display_title.lower():
        return 'HDR10'
    if 'smpte2084' in color_transfer.lower() or 'bt.2020' in color_space.lower():
        return 'HDR10'
    return ''


def _parse_resolution(video_stream: ET.Element) -> str:
    height = int(video_stream.get('height', 0) or 0)
    if height >= 2160:
        return '4K'
    if height >= 1080:
        return '1080p'
    if height >= 720:
        return '720p'
    if height > 0:
        return 'SD'
    return ''


async def get_library_sections(plex_url: str, token: str) -> list[dict]:
    """Return list of library sections (id, title, type)."""
    try:
        async with httpx.AsyncClient(timeout=10) as client:
            r = await client.get(
                f"{plex_url}/library/sections",
                headers={'X-Plex-Token': token, 'Accept': 'application/xml'},
            )
            r.raise_for_status()
        root = ET.fromstring(r.text)
        sections = []
        for d in root.findall('.//Directory'):
            sections.append({
                'key': d.get('key'),
                'title': d.get('title'),
                'type': d.get('type'),
            })
        return sections
    except Exception as e:
        log.error(f"[plex] Failed to get library sections from {plex_url}: {e}")
        return []


async def sync_plex_library(db):
    """Sync Plex metadata into movies/tv_shows tables (updates resolution, codec, plex_key, etc.)."""
    # Build instances with config-table overrides (editable from Settings UI)
    from app.config import CHRIS_PLEX_URL, ALI_PLEX_URL, CHRIS_PLEX_TOKEN, ALI_PLEX_TOKEN
    instances = []
    for plex in PLEX_INSTANCES:
        overridden = dict(plex)
        if plex['name'] == 'chris':
            overridden['url']   = await get_config('plex_chris_url',   CHRIS_PLEX_URL)   or plex['url']
            overridden['token'] = await get_config('plex_chris_token', CHRIS_PLEX_TOKEN) or plex['token']
        elif plex['name'] == 'ali':
            overridden['url']   = await get_config('plex_ali_url',   ALI_PLEX_URL)   or plex['url']
            overridden['token'] = await get_config('plex_ali_token', ALI_PLEX_TOKEN) or plex['token']
        instances.append(overridden)

    for plex in instances:
        source_key = f"plex-{plex['name']}"
        if not plex.get('token'):
            log.warning(f"[{source_key}] No token configured, skipping")
            await db.execute(
                "INSERT OR REPLACE INTO sync_log (source, status, error_msg, last_sync) VALUES (?,?,?,CURRENT_TIMESTAMP)",
                (source_key, 'not_configured', 'No Plex token configured')
            )
            await db.commit()
            continue

        if not plex.get('url'):
            await db.execute(
                "INSERT OR REPLACE INTO sync_log (source, status, error_msg, last_sync) VALUES (?,?,?,CURRENT_TIMESTAMP)",
                (source_key, 'not_configured', 'No Plex URL configured')
            )
            await db.commit()
            continue

        # Mark as syncing
        await db.execute(
            "INSERT OR REPLACE INTO sync_log (source, status, last_sync) VALUES (?,?,CURRENT_TIMESTAMP)",
            (source_key, 'syncing')
        )
        await db.commit()

        try:
            sections = await get_library_sections(plex['url'], plex['token'])
            log.info(f"[{source_key}] Found {len(sections)} library sections")
            total_count = 0

            for section in sections:
                if section['type'] not in ('movie', 'show'):
                    continue
                try:
                    await _sync_section(db, plex, section)
                    total_count += 1
                except Exception as e:
                    log.error(f"[{source_key}] Error syncing section {section['title']}: {e}")

            await db.execute("""
                INSERT OR REPLACE INTO sync_log (source, last_sync, status, error_msg)
                VALUES (?,CURRENT_TIMESTAMP,'ok',NULL)
            """, (source_key,))
            await db.commit()
            await log_event(db, 'sync', source_key, f"Plex: {total_count} sections updated")
            await db.commit()
        except Exception as e:
            log.error(f"[{source_key}] Sync failed: {e}")
            await db.execute(
                "INSERT OR REPLACE INTO sync_log (source, status, error_msg, last_sync) VALUES (?,?,?,CURRENT_TIMESTAMP)",
                (source_key, 'error', str(e)[:500])
            )
            await log_event(db, 'sync', source_key, f"Sync failed: {str(e)[:200]}", level='error')
            await db.commit()


async def _sync_section(db, plex: dict, section: dict):
    """Sync one Plex library section."""
    log.info(f"[plex-{plex['name']}] Syncing {section['type']} section: {section['title']}")
    offset = 0
    page_size = 100
    count = 0

    async with httpx.AsyncClient(timeout=60) as client:
        while True:
            r = await client.get(
                f"{plex['url']}/library/sections/{section['key']}/all",
                headers={'X-Plex-Token': plex['token'], 'Accept': 'application/xml'},
                params={'X-Plex-Start': offset, 'X-Plex-Container-Size': page_size},
            )
            r.raise_for_status()
            root = ET.fromstring(r.text)

            if section['type'] == 'movie':
                items = root.findall('.//Video')
            else:
                items = root.findall('.//Directory')

            if not items:
                break

            for item in items:
                try:
                    if section['type'] == 'movie':
                        await _sync_plex_movie(db, plex, item)
                    else:
                        await _sync_plex_show(db, plex, item)
                    count += 1
                except Exception as e:
                    log.debug(f"Error syncing item {item.get('title', '?')}: {e}")

            # Commit after each page to release write lock
            await db.commit()
            offset += page_size
            if len(items) < page_size:
                break
    log.info(f"[plex-{plex['name']}] Updated {count} items in {section['title']}")


async def _sync_plex_movie(db, plex: dict, item: ET.Element):
    """Extract metadata from Plex movie XML and update movies table."""
    plex_key = item.get('ratingKey', '')
    title = item.get('title', '')
    year = item.get('year')
    tmdb_id = None
    imdb_id = None

    # Extract GUIDs
    for guid in item.findall('.//Guid'):
        guid_id = guid.get('id', '')
        if guid_id.startswith('tmdb://'):
            tmdb_id = int(guid_id.replace('tmdb://', ''))
        elif guid_id.startswith('imdb://'):
            imdb_id = guid_id.replace('imdb://', '')

    # Legacy guid
    if not tmdb_id and not imdb_id:
        old_guid = item.get('guid', '')
        if 'themoviedb' in old_guid:
            try:
                tmdb_id = int(old_guid.split('//')[1].split('/')[0].split('?')[0])
            except Exception:
                pass

    # Added timestamp
    added_at_unix = item.get('addedAt')
    added_at = None
    if added_at_unix:
        try:
            added_at = datetime.utcfromtimestamp(int(added_at_unix)).isoformat()
        except Exception:
            pass

    # Media info from first Part
    resolution = ''
    video_codec = ''
    audio_codec = ''
    audio_channels = None
    hdr_format = ''
    file_path = ''

    media_el = item.find('.//Media')
    if media_el is not None:
        part = media_el.find('.//Part')
        if part is not None:
            file_path = part.get('file', '')

        # Video stream
        video_stream = item.find('.//Stream[@streamType="1"]')
        if video_stream is not None:
            resolution = _parse_resolution(video_stream)
            video_codec = video_stream.get('displayTitle', '') or video_stream.get('codec', '')
            hdr_format = _detect_hdr(video_stream)

        # Audio stream
        audio_stream = item.find('.//Stream[@streamType="2"]')
        if audio_stream is not None:
            audio_codec = audio_stream.get('displayTitle', '') or audio_stream.get('codec', '')
            try:
                audio_channels = float(audio_stream.get('channels', 0) or 0)
            except Exception:
                pass

    # Try to match by tmdb_id or title+year
    matched = False
    if tmdb_id:
        cur = await db.execute(
            "UPDATE movies SET plex_key=?, resolution=COALESCE(NULLIF(?,''), resolution), "
            "video_codec=COALESCE(NULLIF(?,''), video_codec), audio_codec=COALESCE(NULLIF(?,''), audio_codec), "
            "audio_channels=COALESCE(?,audio_channels), hdr_format=COALESCE(NULLIF(?,''),hdr_format), "
            "file_path=COALESCE(NULLIF(?,''),file_path), plex_added_at=COALESCE(?,plex_added_at), "
            "updated_at=CURRENT_TIMESTAMP WHERE tmdb_id=?",
            (plex_key, resolution, video_codec, audio_codec, audio_channels,
             hdr_format, file_path, added_at, tmdb_id)
        )
        matched = cur.rowcount > 0

    if not matched and title and year:
        await db.execute(
            "UPDATE movies SET plex_key=?, plex_added_at=COALESCE(?,plex_added_at), "
            "updated_at=CURRENT_TIMESTAMP WHERE title=? AND year=?",
            (plex_key, added_at, title, int(year))
        )


async def _sync_plex_show(db, plex: dict, item: ET.Element):
    """Extract metadata from Plex show XML and update tv_shows table."""
    plex_key = item.get('ratingKey', '')
    title = item.get('title', '')
    year = item.get('year')
    tmdb_id = None

    for guid in item.findall('.//Guid'):
        guid_id = guid.get('id', '')
        if guid_id.startswith('tmdb://'):
            try:
                tmdb_id = int(guid_id.replace('tmdb://', ''))
            except Exception:
                pass

    added_at_unix = item.get('addedAt')
    added_at = None
    if added_at_unix:
        try:
            added_at = datetime.utcfromtimestamp(int(added_at_unix)).isoformat()
        except Exception:
            pass

    if tmdb_id:
        await db.execute(
            "UPDATE tv_shows SET plex_key=?, plex_added_at=COALESCE(?,plex_added_at), "
            "updated_at=CURRENT_TIMESTAMP WHERE tmdb_id=?",
            (plex_key, added_at, tmdb_id)
        )
    elif title:
        if year:
            await db.execute(
                "UPDATE tv_shows SET plex_key=?, plex_added_at=COALESCE(?,plex_added_at), "
                "updated_at=CURRENT_TIMESTAMP WHERE title=? AND year=?",
                (plex_key, added_at, title, int(year))
            )
        else:
            await db.execute(
                "UPDATE tv_shows SET plex_key=?, plex_added_at=COALESCE(?,plex_added_at), "
                "updated_at=CURRENT_TIMESTAMP WHERE title=?",
                (plex_key, added_at, title)
            )
