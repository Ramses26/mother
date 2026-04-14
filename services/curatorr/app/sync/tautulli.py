"""Tautulli sync — fetch watch history and update play counts."""
import logging
from datetime import datetime

import httpx
from app.config import TAUTULLI_INSTANCES
from app.database import get_config, set_config
from app.log_events import log_event

log = logging.getLogger('curatorr.sync.tautulli')


async def sync_watch_history(db, instance_filter: str = None):
    """Pull watch history from Tautulli instances, update play counts.
    instance_filter: 'ali' or 'chris' to sync only that instance; None = both.
    """
    from app.config import (
        CHRIS_TAUTULLI_URL, ALI_TAUTULLI_URL,
        CHRIS_TAUTULLI_KEY, ALI_TAUTULLI_KEY,
    )
    instances = []
    for t in TAUTULLI_INSTANCES:
        if instance_filter and t['name'] != instance_filter:
            continue
        overridden = dict(t)
        if t['name'] == 'chris':
            db_url = await get_config('tautulli_chris_url')
            db_key = await get_config('tautulli_chris_key')
            overridden['url']     = db_url or CHRIS_TAUTULLI_URL or t['url']
            overridden['api_key'] = db_key or CHRIS_TAUTULLI_KEY or t['api_key']
        elif t['name'] == 'ali':
            db_url = await get_config('tautulli_ali_url')
            db_key = await get_config('tautulli_ali_key')
            overridden['url']     = db_url or ALI_TAUTULLI_URL or t['url']
            overridden['api_key'] = db_key or ALI_TAUTULLI_KEY or t['api_key']
        instances.append(overridden)

    for tautulli in instances:
        source_key = f"tautulli-{tautulli['name']}"
        if not tautulli.get('url') or not tautulli.get('api_key'):
            log.warning(f"[{source_key}] Not configured, skipping")
            await db.execute(
                "INSERT OR REPLACE INTO sync_log (source, status, error_msg, last_sync) VALUES (?,?,?,CURRENT_TIMESTAMP)",
                (source_key, 'not_configured', 'URL or API key not set')
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
            await _sync_tautulli_instance(db, tautulli)
        except Exception as e:
            log.error(f"[{source_key}] Sync error: {e}")
            await db.execute(
                "INSERT OR REPLACE INTO sync_log (source, status, error_msg, last_sync) VALUES (?,?,?,CURRENT_TIMESTAMP)",
                (source_key, 'error', str(e))
            )
            await log_event(db, 'sync', source_key, f"Sync failed: {str(e)[:200]}", level='error')
            await db.commit()


async def _sync_tautulli_instance(db, tautulli: dict):
    """Sync one Tautulli instance."""
    source_key = f"tautulli-{tautulli['name']}"
    user_field = f"{tautulli['user']}_play_count"
    last_watched_field = f"{tautulli['user']}_last_watched"
    total_sec_field = f"{tautulli['user']}_total_watch_sec"

    # Delta sync from last sync time
    last_sync_key = f"tautulli_{tautulli['name']}_last_sync"
    last_sync = await get_config(last_sync_key)

    params = {
        'apikey': tautulli['api_key'],
        'cmd': 'get_history',
        'length': 1000,
        'start': 0,
    }
    if last_sync:
        params['after'] = int(last_sync)

    all_records = []
    try:
        async with httpx.AsyncClient(timeout=30) as client:
            while True:
                r = await client.get(f"{tautulli['url']}/api/v2", params=params)
                r.raise_for_status()
                data = r.json()

                records = data.get('response', {}).get('data', {}).get('data', [])
                if not records:
                    break

                all_records.extend(records)
                params['start'] += params['length']

                total = data.get('response', {}).get('data', {}).get('recordsFiltered', 0)
                if params['start'] >= total:
                    break
    except Exception as e:
        url_safe = tautulli['url'].split('?')[0] if tautulli.get('url') else 'unconfigured'
        log.error(f"[{source_key}] HTTP error fetching {url_safe}: {e}")
        raise

    log.info(f"[{source_key}] Processing {len(all_records)} history records")

    for record in all_records:
        try:
            media_type = record.get('media_type', '')
            title = record.get('title', '') or record.get('full_title', '')
            grandparent_title = record.get('grandparent_title', '')
            year = record.get('year')
            rating_key = str(record.get('rating_key', ''))
            watched_at_unix = record.get('date') or record.get('started')
            duration = record.get('duration') or record.get('duration_ms', 0) // 1000 if record.get('duration_ms') else 0
            watched_pct = record.get('percent_complete') or record.get('watch_time', 0) / max(duration, 1) * 100 if duration else 0
            player = record.get('platform', '') or record.get('player', '')
            user_name = record.get('user', tautulli['user'])

            watched_at = None
            if watched_at_unix:
                try:
                    watched_at = datetime.utcfromtimestamp(int(watched_at_unix)).isoformat()
                except Exception:
                    pass

            # Store in watch_history
            if rating_key and watched_at:
                try:
                    _show_title = grandparent_title if media_type in ('episode', 'show') else None
                    await db.execute("""
                        INSERT OR IGNORE INTO watch_history
                        (source, user_name, media_type, plex_key, title, show_title, watched_at, duration_sec, completion_pct, player)
                        VALUES (?,?,?,?,?,?,?,?,?,?)
                    """, (source_key, user_name, media_type, rating_key, title, _show_title,
                          watched_at, duration, round(watched_pct, 1), player))
                except Exception:
                    pass

            # Update movie play counts
            if media_type == 'movie' and rating_key:
                cur = await db.execute(f"""
                    UPDATE movies SET
                        {user_field} = COALESCE({user_field}, 0) + 1,
                        {last_watched_field} = CASE
                            WHEN {last_watched_field} IS NULL OR {last_watched_field} < ?
                            THEN ? ELSE {last_watched_field} END,
                        updated_at = CURRENT_TIMESTAMP
                    WHERE plex_key = ?
                """, (watched_at, watched_at, rating_key))

                # Fallback: try title match if plex_key didn't match any row
                if cur.rowcount == 0 and title:
                    await db.execute(f"""
                        UPDATE movies SET
                            {user_field} = COALESCE({user_field}, 0) + 1,
                            updated_at = CURRENT_TIMESTAMP
                        WHERE title=? AND (year=? OR ? IS NULL)
                    """, (title, year, year))

            elif media_type in ('episode', 'show') and rating_key:
                # Update TV play counts by grandparent_title or title
                show_title = grandparent_title or title
                if show_title:
                    # Match: exact title OR DB title has year suffix (e.g. "Acapulco (2021)" when Tautulli sends "Acapulco")
                    # Also match reverse: Tautulli sends "Show (2021)", DB has "Show"
                    cur = await db.execute(f"""
                        UPDATE tv_shows SET
                            {user_field} = COALESCE({user_field}, 0) + 1,
                            {last_watched_field} = CASE
                                WHEN {last_watched_field} IS NULL OR {last_watched_field} < ?
                                THEN ? ELSE {last_watched_field} END,
                            updated_at = CURRENT_TIMESTAMP
                        WHERE lower(title) = lower(?)
                           OR lower(title) LIKE lower(?) || ' (____)'
                    """, (watched_at, watched_at, show_title, show_title))
                    # Fallback: strip trailing year suffix from Tautulli title (e.g. "Lioness (2021)" → "Lioness")
                    if cur.rowcount == 0 and show_title:
                        import re as _re
                        stripped = _re.sub(r'\s*\(\d{4}\)\s*$', '', show_title).strip()
                        if stripped != show_title:
                            await db.execute(f"""
                                UPDATE tv_shows SET
                                    {user_field} = COALESCE({user_field}, 0) + 1,
                                    {last_watched_field} = CASE
                                        WHEN {last_watched_field} IS NULL OR {last_watched_field} < ?
                                        THEN ? ELSE {last_watched_field} END,
                                    updated_at = CURRENT_TIMESTAMP
                                WHERE lower(title) = lower(?)
                                   OR lower(title) LIKE lower(?) || ' (____)'
                            """, (watched_at, watched_at, stripped, stripped))

        except Exception as e:
            log.debug(f"[{source_key}] Error processing record: {e}")

    await db.commit()

    # Save last sync timestamp
    await set_config(last_sync_key, str(int(datetime.utcnow().timestamp())))

    await db.execute("""
        INSERT OR REPLACE INTO sync_log (source, last_sync, last_delta_sync, item_count, status)
        VALUES (?,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,?,'ok')
    """, (source_key, len(all_records)))
    await db.commit()

    await log_event(db, 'sync', source_key, f"Watch history: {len(all_records)} plays synced")
    await db.commit()

    log.info(f"[{source_key}] Processed {len(all_records)} history records")
