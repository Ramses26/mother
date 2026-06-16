"""Tautulli sync — fetch watch history and update play counts."""
import logging
import re
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
    owner_username = tautulli.get('owner_username', '')  # only this user's plays count

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
        # Tautulli uses start_date (YYYY-MM-DD), not 'after'. Use one day before
        # last sync to avoid missing records at day boundaries.
        dt = datetime.utcfromtimestamp(int(last_sync))
        params['start_date'] = dt.strftime('%Y-%m-%d')

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
            grandparent_rating_key = str(record.get('grandparent_rating_key', '') or '')
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

            # Store in watch_history — only update play counts for new (non-duplicate) records.
            # INSERT OR IGNORE silently skips duplicates; rowcount=0 means it was a duplicate.
            is_new_watch = True  # default True for records we can't deduplicate (no key/time)
            if rating_key and watched_at:
                try:
                    _show_title = grandparent_title if media_type in ('episode', 'show') else None
                    _show_plex_key = grandparent_rating_key if media_type in ('episode', 'show') and grandparent_rating_key else None
                    cur_insert = await db.execute("""
                        INSERT OR IGNORE INTO watch_history
                        (source, user_name, media_type, plex_key, title, show_title, show_plex_key, watched_at, duration_sec, completion_pct, player)
                        VALUES (?,?,?,?,?,?,?,?,?,?,?)
                    """, (source_key, user_name, media_type, rating_key, title, _show_title, _show_plex_key,
                          watched_at, duration, round(watched_pct, 1), player))
                    is_new_watch = cur_insert.rowcount > 0
                except Exception:
                    pass

            if not is_new_watch:
                continue

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
                # Only use grandparent_title for show matching — never the episode title.
                # Falling back to title (episode name) would wrongly match unrelated shows
                # that happen to share an episode title with a show name.
                show_title = grandparent_title
                if not show_title:
                    continue

                # Step 1: exact title match (most specific, avoids multi-row updates)
                cur = await db.execute(f"""
                    UPDATE tv_shows SET
                        {user_field} = COALESCE({user_field}, 0) + 1,
                        {last_watched_field} = CASE
                            WHEN {last_watched_field} IS NULL OR {last_watched_field} < ?
                            THEN ? ELSE {last_watched_field} END,
                        updated_at = CURRENT_TIMESTAMP
                    WHERE lower(title) = lower(?)
                """, (watched_at, watched_at, show_title))

                if cur.rowcount == 0:
                    # Step 2: Tautulli sends "Show", DB has "Show (YYYY)" — use scalar
                    # subquery with LIMIT 1 to prevent updating multiple rows at once.
                    cur = await db.execute(f"""
                        UPDATE tv_shows SET
                            {user_field} = COALESCE({user_field}, 0) + 1,
                            {last_watched_field} = CASE
                                WHEN {last_watched_field} IS NULL OR {last_watched_field} < ?
                                THEN ? ELSE {last_watched_field} END,
                            updated_at = CURRENT_TIMESTAMP
                        WHERE id = (
                            SELECT id FROM tv_shows
                            WHERE lower(title) LIKE lower(?) || ' (____)'
                            LIMIT 1
                        )
                    """, (watched_at, watched_at, show_title))

                if cur.rowcount == 0:
                    # Step 3: Tautulli sends "Show (YYYY)", try stripping year suffix
                    stripped = re.sub(r'\s*\(\d{4}\)\s*$', '', show_title).strip()
                    if stripped != show_title:
                        cur = await db.execute(f"""
                            UPDATE tv_shows SET
                                {user_field} = COALESCE({user_field}, 0) + 1,
                                {last_watched_field} = CASE
                                    WHEN {last_watched_field} IS NULL OR {last_watched_field} < ?
                                    THEN ? ELSE {last_watched_field} END,
                                updated_at = CURRENT_TIMESTAMP
                            WHERE lower(title) = lower(?)
                        """, (watched_at, watched_at, stripped))

                        if cur.rowcount == 0:
                            await db.execute(f"""
                                UPDATE tv_shows SET
                                    {user_field} = COALESCE({user_field}, 0) + 1,
                                    {last_watched_field} = CASE
                                        WHEN {last_watched_field} IS NULL OR {last_watched_field} < ?
                                        THEN ? ELSE {last_watched_field} END,
                                    updated_at = CURRENT_TIMESTAMP
                                WHERE id = (
                                    SELECT id FROM tv_shows
                                    WHERE lower(title) LIKE lower(?) || ' (____)'
                                    LIMIT 1
                                )
                            """, (watched_at, watched_at, stripped))

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
