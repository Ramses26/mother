"""Sync status and trigger endpoints."""
import logging
from fastapi import APIRouter, Depends, HTTPException
from app.auth import require_auth
from app.database import get_db
from app.models import SyncTriggerRequest

router = APIRouter()
log = logging.getLogger('curatorr.routes.sync')


@router.get('/sync/status')
async def sync_status(_auth=Depends(require_auth)):
    """Get sync status for all sources."""
    async for db in get_db():
        async with db.execute("SELECT * FROM sync_log") as cur:
            rows = await cur.fetchall()
            return [dict(r) for r in rows]


@router.post('/sync/trigger')
async def sync_trigger(body: SyncTriggerRequest, _auth=Depends(require_auth)):
    """Trigger a sync for specified source."""
    import asyncio
    source = body.source

    try:
        from app.scheduler import trigger_sync_by_source, is_sync_running
        if is_sync_running(source):
            raise HTTPException(status_code=409, detail=f'Sync already running for source: {source}')
        asyncio.create_task(trigger_sync_by_source(source))
        return {'ok': True, 'message': f'Sync triggered for: {source}'}
    except Exception as e:
        log.error(f"Sync trigger error: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post('/sync/recompute-play-counts')
async def recompute_play_counts(_auth=Depends(require_auth)):
    """Recompute ali/chris play counts from watch_history using Python-side aggregation.

    Avoids correlated subqueries (which scan 255k rows × 3300 shows = 843M comparisons).
    Instead: one GROUP BY scan of watch_history → dict → targeted per-show updates.
    Runs in seconds instead of minutes.
    """
    import asyncio, aiosqlite, re
    from collections import defaultdict
    from app.config import DB_PATH

    async def _run():
        log.info("Play count recompute: starting...")
        async with aiosqlite.connect(DB_PATH, timeout=120) as db:
            await db.execute('PRAGMA journal_mode=WAL')

            # --- TV shows ---
            async with db.execute("SELECT id, title FROM tv_shows") as cur:
                shows = await cur.fetchall()

            # Build title lookup maps for TV: lower(title) → [id, ...]
            # Two maps: exact title and year-stripped title (handles "Bluey (2018)" → "Bluey")
            exact_map = defaultdict(list)
            strip_map = defaultdict(list)
            for show_id, title in shows:
                if not title:
                    continue
                tl = title.lower().strip()
                exact_map[tl].append(show_id)
                stripped = re.sub(r'\s*\(\d{4}\)\s*$', '', tl).strip()
                if stripped != tl:
                    strip_map[stripped].append(show_id)

            # Reset TV play counts
            await db.execute('UPDATE tv_shows SET ali_play_count=0, chris_play_count=0, ali_last_watched=NULL, chris_last_watched=NULL')
            await db.commit()

            for source, col, lw_col in [
                ('tautulli-ali',   'ali_play_count',   'ali_last_watched'),
                ('tautulli-chris', 'chris_play_count', 'chris_last_watched'),
            ]:
                # One scan of watch_history aggregated by show_title
                async with db.execute("""
                    SELECT lower(show_title), COUNT(*), MAX(watched_at)
                    FROM watch_history
                    WHERE source=? AND media_type IN ('episode','show') AND show_title IS NOT NULL
                    GROUP BY lower(show_title)
                """, (source,)) as cur:
                    history_rows = await cur.fetchall()

                # Python-side matching: aggregate counts per show_id
                show_counts = defaultdict(lambda: [0, None])
                for stitle, cnt, last_w in history_rows:
                    matched_ids = set()
                    # Rule 1: exact title match (DB title = watch title)
                    for sid in exact_map.get(stitle, []):
                        matched_ids.add(sid)
                    # Rule 2: watch title has year suffix, DB title is the base
                    # e.g. wh.show_title="Dark (2017)", db.title="Dark"
                    base = re.sub(r'\s*\(\d{4}\)\s*$', '', stitle).strip()
                    if base != stitle:
                        for sid in exact_map.get(base, []):
                            matched_ids.add(sid)
                    # Rule 3: DB title has year suffix, watch title is the base
                    # e.g. wh.show_title="Bluey", db.title="Bluey (2018)"
                    for sid in strip_map.get(stitle, []):
                        matched_ids.add(sid)

                    for sid in matched_ids:
                        show_counts[sid][0] += cnt
                        if last_w and (not show_counts[sid][1] or last_w > show_counts[sid][1]):
                            show_counts[sid][1] = last_w

                if show_counts:
                    await db.executemany(
                        f"UPDATE tv_shows SET {col}=?, {lw_col}=? WHERE id=?",
                        [(cnt, lw, sid) for sid, (cnt, lw) in show_counts.items()]
                    )
                    await db.commit()
                log.info(f"Play count recompute: {col} done ({len(show_counts)} shows updated)")

            # --- Movies ---
            # Reset movie play counts
            await db.execute('UPDATE movies SET ali_play_count=0, chris_play_count=0, ali_last_watched=NULL, chris_last_watched=NULL')
            await db.commit()

            # Ali movies: match by ali_plex_key (per-instance), fall back to shared plex_key
            async with db.execute("""
                SELECT wh.plex_key, COUNT(*), MAX(wh.watched_at)
                FROM watch_history wh
                WHERE wh.source='tautulli-ali' AND wh.media_type='movie'
                GROUP BY wh.plex_key
            """) as cur:
                ali_movie_history = await cur.fetchall()

            ali_movie_map = {pk: (cnt, lw) for pk, cnt, lw in ali_movie_history if pk}

            async with db.execute("SELECT id, ali_plex_key, plex_key FROM movies") as cur:
                movies = await cur.fetchall()

            updates = []
            for mid, ali_pk, shared_pk in movies:
                key = ali_pk or shared_pk
                if key and key in ali_movie_map:
                    cnt, lw = ali_movie_map[key]
                    updates.append((cnt, lw, mid))
            if updates:
                await db.executemany("UPDATE movies SET ali_play_count=?, ali_last_watched=? WHERE id=?", updates)
                await db.commit()
            log.info(f"Play count recompute: movies ali done ({len(updates)} movies updated)")

            # Chris movies: match by title (different Plex key spaces)
            async with db.execute("""
                SELECT lower(wh.title), COUNT(*), MAX(wh.watched_at)
                FROM watch_history wh
                WHERE wh.source='tautulli-chris' AND wh.media_type='movie'
                GROUP BY lower(wh.title)
            """) as cur:
                chris_movie_history = {r[0]: (r[1], r[2]) for r in await cur.fetchall()}

            async with db.execute("SELECT id, title FROM movies") as cur:
                all_movies = await cur.fetchall()

            updates = []
            for mid, title in all_movies:
                if title:
                    match = chris_movie_history.get(title.lower())
                    if match:
                        updates.append((match[0], match[1], mid))
            if updates:
                await db.executemany("UPDATE movies SET chris_play_count=?, chris_last_watched=? WHERE id=?", updates)
                await db.commit()
            log.info(f"Play count recompute: movies chris done ({len(updates)} movies updated)")

            log.info("Play count recompute: complete")

    asyncio.create_task(_run())
    return {'ok': True, 'message': 'Play count recompute started in background'}

