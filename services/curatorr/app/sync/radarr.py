"""Radarr sync — pull all movies from all Radarr instances."""
import json
import logging
from datetime import datetime

import httpx
from app.config import RADARR_INSTANCES
from app.scoring import compute_composite_score, compute_purge_score
from app.log_events import log_event

log = logging.getLogger('curatorr.sync.radarr')


def _parse_resolution(quality_data: dict) -> str:
    """Extract resolution string from Radarr quality data."""
    try:
        quality_name = quality_data.get('quality', {}).get('name', '')
        if '2160' in quality_name or '4K' in quality_name:
            return '4K'
        if '1080' in quality_name:
            return '1080p'
        if '720' in quality_name:
            return '720p'
        if '480' in quality_name or 'SD' in quality_name:
            return 'SD'
        # Try mediaInfo
        media_info = quality_data.get('mediaInfo', {})
        height = media_info.get('height', 0)
        if height >= 2160:
            return '4K'
        if height >= 1080:
            return '1080p'
        if height >= 720:
            return '720p'
        if height > 0:
            return 'SD'
        return quality_name or 'Unknown'
    except Exception:
        return 'Unknown'


def _parse_hdr(media_info: dict) -> str:
    if not media_info:
        return ''
    video_dynamic_range = media_info.get('videoDynamicRange', '') or ''
    video_dynamic_range_type = media_info.get('videoDynamicRangeType', '') or ''
    hdr_str = (video_dynamic_range + ' ' + video_dynamic_range_type).strip()
    if 'DolbyVision' in hdr_str or 'Dolby Vision' in hdr_str:
        return 'DolbyVision'
    if 'HDR10+' in hdr_str:
        return 'HDR10+'
    if 'HDR10' in hdr_str or 'HDR' in hdr_str:
        return 'HDR10'
    return ''


async def sync_all_movies(db):
    """Pull all movies from all Radarr instances, upsert into movies table."""
    total = 0
    for inst in RADARR_INSTANCES:
        if not inst.get('api_key'):
            log.warning(f"[{inst['name']}] No API key configured, skipping")
            continue
        try:
            async with httpx.AsyncClient(timeout=60) as client:
                r = await client.get(
                    f"{inst['url']}/api/v3/movie",
                    headers={'X-Api-Key': inst['api_key']},
                )
                r.raise_for_status()
                movies = r.json()
        except Exception as e:
            log.error(f"[{inst['name']}] Failed to fetch movies: {e}")
            await db.execute(
                "INSERT OR REPLACE INTO sync_log (source, status, error_msg, last_sync) VALUES (?,?,?,CURRENT_TIMESTAMP)",
                (inst['name'], 'error', str(e))
            )
            await log_event(db, 'sync', inst['name'], f"Sync failed: {str(e)[:200]}", level='error')
            await db.commit()
            continue

        log.info(f"[{inst['name']}] Syncing {len(movies)} movies")
        count = 0
        live_ids = {m.get('id') for m in movies}

        for i, m in enumerate(movies):
            # Commit every 100 movies to release write lock periodically
            if i > 0 and i % 100 == 0:
                await db.commit()
                count_so_far = i
            try:
                movie_file = m.get('movieFile') or {}
                media_info = movie_file.get('mediaInfo') or {}
                quality_data = movie_file.get('quality') or {}

                resolution = _parse_resolution(quality_data)
                video_codec = media_info.get('videoCodec', '')
                audio_codec = media_info.get('audioCodec', '') or media_info.get('audioCodecs', '')
                if isinstance(audio_codec, list):
                    audio_codec = ', '.join(audio_codec)
                audio_channels = media_info.get('audioChannels', None)
                hdr_format = _parse_hdr(media_info)
                file_size = movie_file.get('size', 0)
                file_path = movie_file.get('path', '') or ''

                # Extract container path prefix
                # Radarr paths start with the container mount point
                for prefix in ['/movies', '/movies-4k']:
                    if file_path.startswith(prefix) or '/movies' in inst['url'] or True:
                        break

                genres = json.dumps([g.get('name', g) if isinstance(g, dict) else g for g in (m.get('genres') or [])])

                collection = m.get('collection') or {}
                collection_tmdb_id = collection.get('tmdbId') or collection.get('id')
                collection_name = collection.get('name', '')

                sort_title = m.get('sortTitle') or m.get('title', '')
                added_str = m.get('added', '')
                try:
                    added_at = datetime.fromisoformat(added_str.replace('Z', '+00:00')).isoformat() if added_str else None
                except Exception:
                    added_at = None

                # Poster URL: use images[] array (coverType='poster', remoteUrl)
                poster_url = next(
                    (img.get('remoteUrl', '') for img in m.get('images', [])
                     if img.get('coverType') == 'poster'),
                    ''
                ) or ''

                await db.execute("""
                    INSERT INTO movies (
                        radarr_id, radarr_instance, tmdb_id, imdb_id,
                        title, sort_title, year, genres, runtime_min,
                        content_rating, studio, summary, original_language,
                        collection_tmdb_id, collection_name,
                        resolution, video_codec, audio_codec, audio_channels,
                        hdr_format, file_size_bytes, file_path,
                        quality_profile, monitored, poster_url, title_slug,
                        radarr_added_at, last_synced, updated_at
                    ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP)
                    ON CONFLICT(radarr_id, radarr_instance) DO UPDATE SET
                        tmdb_id=excluded.tmdb_id, imdb_id=excluded.imdb_id,
                        title=excluded.title, sort_title=excluded.sort_title,
                        year=excluded.year, genres=excluded.genres,
                        runtime_min=excluded.runtime_min,
                        content_rating=excluded.content_rating,
                        studio=excluded.studio, summary=excluded.summary,
                        original_language=excluded.original_language,
                        collection_tmdb_id=excluded.collection_tmdb_id,
                        collection_name=excluded.collection_name,
                        resolution=excluded.resolution, video_codec=excluded.video_codec,
                        audio_codec=excluded.audio_codec, audio_channels=excluded.audio_channels,
                        hdr_format=excluded.hdr_format, file_size_bytes=excluded.file_size_bytes,
                        file_path=excluded.file_path, quality_profile=excluded.quality_profile,
                        monitored=excluded.monitored, poster_url=excluded.poster_url,
                        title_slug=excluded.title_slug,
                        last_synced=CURRENT_TIMESTAMP, updated_at=CURRENT_TIMESTAMP
                """, (
                    m.get('id'), inst['name'],
                    m.get('tmdbId'), m.get('imdbId'),
                    m.get('title', ''), sort_title,
                    m.get('year'), genres,
                    m.get('runtime'), m.get('certification'),
                    m.get('studio'), m.get('overview', ''),
                    m.get('originalLanguage', {}).get('name', '') if isinstance(m.get('originalLanguage'), dict) else m.get('originalLanguage', ''),
                    collection_tmdb_id, collection_name,
                    resolution, video_codec, audio_codec, audio_channels,
                    hdr_format, file_size, file_path,
                    m.get('qualityProfileId'), 1 if m.get('monitored') else 0,
                    poster_url, m.get('titleSlug'), added_at,
                ))
                count += 1
            except Exception as e:
                log.error(f"[{inst['name']}] Error upserting movie {m.get('title', '?')}: {e}")

        await db.commit()

        # ── Prune movies Radarr no longer tracks ────────────────────────────
        # See sonarr.py's identical prune step for the 2026-07-22 context — this
        # sync only ever upserted, so a movie deleted from Radarr left its row
        # in `movies` forever.
        async with db.execute(
            "SELECT id, radarr_id, title, year FROM movies WHERE radarr_instance=?",
            (inst['name'],)
        ) as cur:
            db_rows = await cur.fetchall()
        orphans = [r for r in db_rows if r[1] not in live_ids]
        for orphan_id, radarr_id, title, year in orphans:
            await db.execute("DELETE FROM movies WHERE id=?", (orphan_id,))
            log.info(f"[{inst['name']}] Pruned stale movie no longer in Radarr: "
                     f"{title} ({year}) radarr_id={radarr_id}")
        if orphans:
            await db.commit()
            await log_event(db, 'sync', inst['name'],
                            f"Pruned {len(orphans)} movie(s) no longer in Radarr",
                            detail={'titles': [f"{t} ({y})" for _, _, t, y in orphans]})

        # Now update purge scores and composite scores for this instance
        await update_scores(db, inst['name'])

        await db.execute("""
            INSERT OR REPLACE INTO sync_log (source, last_sync, item_count, status, error_msg)
            VALUES (?,CURRENT_TIMESTAMP,?,'ok',NULL)
        """, (inst['name'], count))
        await db.commit()

        log.info(f"[{inst['name']}] Synced {count} movies"
                 + (f", pruned {len(orphans)}" if orphans else ""))
        await log_event(db, 'sync', inst['name'], f"Synced {count} movies")
        await db.commit()
        total += count

    return total


async def update_scores(db, instance_name: str = None):
    """Recompute composite, purge, and TRaSH quality scores for all movies (or one instance)."""
    # trash_score was a dead column until 2026-08-01 — declared in the schema and read by
    # the movies API/UI, but never written (composite_score/purge_score were, trash_score
    # wasn't), so every movie showed a null quality score. Populate it here from the
    # tracked filename using the shared JSON scorer (same one sync-webhook/dedup use).
    # Lazy import to avoid any routes<->sync import cycle at module load.
    from app.routes.sync_status import _score as _trash_score

    where = "WHERE radarr_instance=?" if instance_name else ""
    args = [instance_name] if instance_name else []

    async with db.execute(
        f"SELECT id, imdb_rating, rt_critics, metacritic, tmdb_rating, mdblist_score, "
        f"ali_play_count, chris_play_count, resolution, plex_added_at, radarr_added_at, "
        f"last_synced, file_path, file_size_bytes FROM movies {where}", args
    ) as cur:
        rows = await cur.fetchall()

    for row in rows:
        row = dict(row)
        composite = compute_composite_score(
            row.get('imdb_rating'), row.get('rt_critics'),
            row.get('metacritic'), row.get('tmdb_rating'),
            row.get('mdblist_score'),
        )
        row['composite_score'] = composite
        purge = compute_purge_score(row)
        # Quality score from the tracked filename (basename). None when no file.
        fp = row.get('file_path') or ''
        trash = None
        if fp:
            try:
                trash = _trash_score(fp.rsplit('/', 1)[-1], row.get('file_size_bytes') or 0, 'movie')
            except Exception:
                trash = None
        await db.execute(
            "UPDATE movies SET composite_score=?, purge_score=?, trash_score=?, "
            "updated_at=CURRENT_TIMESTAMP WHERE id=?",
            (composite, purge, trash, row['id'])
        )

    await db.commit()
