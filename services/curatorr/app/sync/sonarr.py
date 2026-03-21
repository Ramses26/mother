"""Sonarr sync — pull all TV shows from all Sonarr instances."""
import json
import logging
from datetime import datetime

import httpx
from app.config import SONARR_INSTANCES
from app.scoring import compute_composite_score, compute_purge_score
from app.log_events import log_event

log = logging.getLogger('curatorr.sync.sonarr')


async def sync_all_shows(db):
    """Pull all series from all Sonarr instances, upsert into tv_shows table."""
    total = 0

    for inst in SONARR_INSTANCES:
        if not inst.get('api_key'):
            log.warning(f"[{inst['name']}] No API key configured, skipping")
            continue
        try:
            async with httpx.AsyncClient(timeout=60) as client:
                r = await client.get(
                    f"{inst['url']}/api/v3/series",
                    headers={'X-Api-Key': inst['api_key']},
                )
                r.raise_for_status()
                shows = r.json()
        except Exception as e:
            log.error(f"[{inst['name']}] Failed to fetch shows: {e}")
            await db.execute(
                "INSERT OR REPLACE INTO sync_log (source, status, error_msg, last_sync) VALUES (?,?,?,CURRENT_TIMESTAMP)",
                (inst['name'], 'error', str(e))
            )
            await log_event(db, 'sync', inst['name'], f"Sync failed: {str(e)[:200]}", level='error')
            await db.commit()
            continue

        log.info(f"[{inst['name']}] Syncing {len(shows)} shows")
        count = 0

        for i, s in enumerate(shows):
            if i > 0 and i % 100 == 0:
                await db.commit()
            try:
                genres = json.dumps([g.get('name', g) if isinstance(g, dict) else g for g in (s.get('genres') or [])])
                sort_title = s.get('sortTitle') or s.get('title', '')
                added_str = s.get('added', '')
                try:
                    added_at = datetime.fromisoformat(added_str.replace('Z', '+00:00')).isoformat() if added_str else None
                except Exception:
                    added_at = None

                # Map status
                raw_status = (s.get('status') or '').lower()
                if raw_status == 'continuing':
                    status = 'Continuing'
                elif raw_status == 'ended':
                    status = 'Ended'
                elif raw_status in ('deleted', 'canceled'):
                    status = 'Cancelled'
                else:
                    status = raw_status.capitalize()

                seasons = s.get('seasons') or []
                total_seasons = len([ss for ss in seasons if ss.get('seasonNumber', 0) > 0])
                total_episodes = sum(ss.get('statistics', {}).get('totalEpisodeCount', 0) for ss in seasons)

                # Extract TVDB ID from alternate IDs if not at top level
                tvdb_id = s.get('tvdbId')

                # Poster URL: use images[] array (coverType='poster', remoteUrl)
                poster_url = next(
                    (img.get('remoteUrl', '') for img in s.get('images', [])
                     if img.get('coverType') == 'poster'),
                    ''
                ) or ''

                await db.execute("""
                    INSERT INTO tv_shows (
                        sonarr_id, sonarr_instance, tmdb_id, tvdb_id, imdb_id,
                        title, sort_title, year, genres, runtime_min,
                        content_rating, network, summary, original_language,
                        status, total_seasons, total_episodes,
                        monitored, poster_url, last_synced, updated_at
                    ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP)
                    ON CONFLICT(sonarr_id, sonarr_instance) DO UPDATE SET
                        tmdb_id=excluded.tmdb_id, tvdb_id=excluded.tvdb_id,
                        imdb_id=excluded.imdb_id, title=excluded.title,
                        sort_title=excluded.sort_title, year=excluded.year,
                        genres=excluded.genres, runtime_min=excluded.runtime_min,
                        content_rating=excluded.content_rating, network=excluded.network,
                        summary=excluded.summary, original_language=excluded.original_language,
                        status=excluded.status, total_seasons=excluded.total_seasons,
                        total_episodes=excluded.total_episodes,
                        monitored=excluded.monitored, poster_url=excluded.poster_url,
                        last_synced=CURRENT_TIMESTAMP, updated_at=CURRENT_TIMESTAMP
                """, (
                    s.get('id'), inst['name'],
                    s.get('tmdbId'), tvdb_id, s.get('imdbId'),
                    s.get('title', ''), sort_title,
                    s.get('year'), genres,
                    s.get('runtime'), s.get('certification'),
                    s.get('network'), s.get('overview', ''),
                    s.get('originalLanguage', {}).get('name', '') if isinstance(s.get('originalLanguage'), dict) else s.get('originalLanguage', ''),
                    status, total_seasons, total_episodes,
                    1 if s.get('monitored') else 0, poster_url,
                ))

                # Get show DB ID
                async with db.execute(
                    "SELECT id FROM tv_shows WHERE sonarr_id=?", (s.get('id'),)
                ) as cur:
                    show_row = await cur.fetchone()

                if show_row:
                    show_db_id = show_row[0]
                    # Upsert seasons
                    for season in seasons:
                        season_num = season.get('seasonNumber', 0)
                        if season_num == 0:
                            continue
                        stats = season.get('statistics') or {}
                        ep_count = stats.get('totalEpisodeCount', 0)
                        ep_downloaded = stats.get('episodeFileCount', 0)
                        await db.execute("""
                            INSERT INTO tv_seasons (show_id, season_number, episode_count, episodes_downloaded, monitored)
                            VALUES (?,?,?,?,?)
                            ON CONFLICT(show_id, season_number) DO UPDATE SET
                                episode_count=excluded.episode_count,
                                episodes_downloaded=excluded.episodes_downloaded,
                                monitored=excluded.monitored
                        """, (show_db_id, season_num, ep_count, ep_downloaded,
                              1 if season.get('monitored') else 0))

                    # Compute season completion pct
                    total_ep = max(total_episodes, 1)
                    downloaded = sum(ss.get('statistics', {}).get('episodeFileCount', 0) for ss in seasons)
                    completion = round(downloaded / total_ep * 100, 1) if total_ep > 0 else 0
                    await db.execute(
                        "UPDATE tv_shows SET season_completion_pct=? WHERE id=?",
                        (completion, show_db_id)
                    )

                count += 1
            except Exception as e:
                log.error(f"[{inst['name']}] Error upserting show {s.get('title', '?')}: {e}")

        await db.commit()

        # Update purge/composite scores
        await update_tv_scores(db, inst['name'])

        await db.execute("""
            INSERT OR REPLACE INTO sync_log (source, last_sync, item_count, status, error_msg)
            VALUES (?,CURRENT_TIMESTAMP,?,'ok',NULL)
        """, (inst['name'], count))
        await db.commit()

        log.info(f"[{inst['name']}] Synced {count} shows")
        await log_event(db, 'sync', inst['name'], f"Synced {count} shows")
        await db.commit()
        total += count

    return total


async def update_tv_scores(db, instance_name: str = None):
    """Recompute composite and purge scores for TV shows."""
    where = "WHERE sonarr_instance=?" if instance_name else ""
    args = [instance_name] if instance_name else []

    async with db.execute(
        f"SELECT id, imdb_rating, rt_critics, metacritic, tmdb_rating, mdblist_score, "
        f"ali_play_count, chris_play_count, status FROM tv_shows {where}", args
    ) as cur:
        rows = await cur.fetchall()

    for row in rows:
        row = dict(row)
        composite = compute_composite_score(
            row.get('imdb_rating'), row.get('rt_critics'),
            row.get('metacritic'), row.get('tmdb_rating'),
            row.get('mdblist_score'),
        )
        row_for_purge = dict(row)
        row_for_purge['composite_score'] = composite
        row_for_purge['tv_status'] = row.get('status')
        purge = compute_purge_score(row_for_purge)
        await db.execute(
            "UPDATE tv_shows SET composite_score=?, purge_score=?, updated_at=CURRENT_TIMESTAMP WHERE id=?",
            (composite, purge, row['id'])
        )

    await db.commit()
