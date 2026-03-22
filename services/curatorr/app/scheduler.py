"""Curatorr APScheduler — all background jobs."""
import asyncio
import logging
import aiosqlite
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.executors.pool import ThreadPoolExecutor

from app.config import DB_PATH

log = logging.getLogger('curatorr.scheduler')

# Tracks which sync sources are currently running (prevents concurrent duplicate syncs)
_running_syncs: set = set()

_scheduler = BackgroundScheduler(
    executors={'default': ThreadPoolExecutor(3)},
    job_defaults={'coalesce': True, 'max_instances': 1},
)


def _run_async(coro_fn, *args, **kwargs):
    """Run async coroutine function from sync scheduler thread."""
    loop = asyncio.new_event_loop()
    try:
        return loop.run_until_complete(coro_fn(*args, **kwargs))
    finally:
        loop.close()


async def _sync_libraries():
    """Full library sync: radarr + sonarr + plex."""
    async with aiosqlite.connect(DB_PATH, timeout=60) as db:
        db.row_factory = aiosqlite.Row
        await db.execute("PRAGMA journal_mode=WAL")
        from app.sync.radarr import sync_all_movies
        from app.sync.sonarr import sync_all_shows
        from app.sync.plex import sync_plex_library
        try:
            await sync_all_movies(db)
        except Exception as e:
            log.error(f"Radarr sync error: {e}")
        try:
            await sync_all_shows(db)
        except Exception as e:
            log.error(f"Sonarr sync error: {e}")
        try:
            await sync_plex_library(db)
        except Exception as e:
            log.error(f"Plex sync error: {e}")


async def _sync_watch_history():
    async with aiosqlite.connect(DB_PATH, timeout=60) as db:
        db.row_factory = aiosqlite.Row
        await db.execute("PRAGMA journal_mode=WAL")
        from app.sync.tautulli import sync_watch_history
        await sync_watch_history(db)


async def _refresh_ratings():
    async with aiosqlite.connect(DB_PATH, timeout=60) as db:
        db.row_factory = aiosqlite.Row
        await db.execute("PRAGMA journal_mode=WAL")
        from app.sync.omdb import sync_all_ratings as omdb_sync, sync_tv_ratings as omdb_tv_sync
        from app.sync.mdblist import sync_all_ratings as mdb_sync, sync_tv_ratings as mdb_tv_sync
        from app.sync.tmdb import refresh_stale_ratings, refresh_stale_tv_ratings, sync_collections, fill_missing_tv_ids
        from app.sync.radarr import update_scores
        from app.sync.sonarr import update_tv_scores
        for fn in [fill_missing_tv_ids, omdb_sync, omdb_tv_sync, mdb_sync, mdb_tv_sync,
                   refresh_stale_ratings, refresh_stale_tv_ratings,
                   sync_collections, update_scores, update_tv_scores]:
            try:
                await fn(db)
            except Exception as e:
                log.error(f"{fn.__name__} error: {e}")


async def _run_scheduled_rules():
    """Run all daily/weekly enabled rules."""
    async with aiosqlite.connect(DB_PATH, timeout=60) as db:
        db.row_factory = aiosqlite.Row
        await db.execute("PRAGMA journal_mode=WAL")
        try:
            from app.rules_engine import run_all_scheduled_rules
            await run_all_scheduled_rules(db)
        except Exception as e:
            log.error(f"Scheduled rules error: {e}")


async def _backup_database():
    """Backup SQLite database."""
    import shutil
    from pathlib import Path
    from datetime import datetime
    backup_path = Path(DB_PATH).parent / 'backups'
    backup_path.mkdir(exist_ok=True)
    timestamp = datetime.utcnow().strftime('%Y%m%d_%H%M%S')
    dest = backup_path / f"curatorr_{timestamp}.db"
    shutil.copy2(DB_PATH, dest)
    log.info(f"Database backed up to {dest}")
    # Keep only last 7 backups
    backups = sorted(backup_path.glob('curatorr_*.db'))
    for old in backups[:-7]:
        old.unlink()


async def _weekly_digest():
    """Send weekly Telegram digest."""
    from app.notifications import send_notification
    async with aiosqlite.connect(DB_PATH, timeout=60) as db:
        db.row_factory = aiosqlite.Row
        await db.execute("PRAGMA journal_mode=WAL")
        try:
            async with db.execute("SELECT COUNT(*) FROM movies") as cur:
                movie_count = (await cur.fetchone())[0]
            async with db.execute("SELECT COUNT(*) FROM tv_shows") as cur:
                tv_count = (await cur.fetchone())[0]
            async with db.execute(
                "SELECT COUNT(*) FROM deletion_log WHERE deleted_at > date('now', '-7 days')"
            ) as cur:
                deleted_count = (await cur.fetchone())[0]
            msg = (
                f"Curatorr Weekly Digest\n"
                f"Movies: {movie_count} | TV Shows: {tv_count}\n"
                f"Deleted this week: {deleted_count}"
            )
            send_notification(msg)
        except Exception as e:
            log.error(f"Weekly digest error: {e}")


# Sync wrappers for scheduler (must be regular functions)
def _job_sync_libraries():
    _run_async(_sync_libraries)


def _job_sync_watch_history():
    _run_async(_sync_watch_history)


def _job_refresh_ratings():
    _run_async(_refresh_ratings)


def _job_run_rules():
    _run_async(_run_scheduled_rules)


def _job_backup():
    _run_async(_backup_database)


def _job_weekly_digest():
    _run_async(_weekly_digest)


def start_scheduler():
    """Start all APScheduler jobs."""
    _scheduler.add_job(_job_sync_libraries, 'interval', hours=6,
                       id='library_sync', replace_existing=True)
    _scheduler.add_job(_job_sync_watch_history, 'cron', hour=2, minute=0,
                       id='tautulli_sync', replace_existing=True)
    _scheduler.add_job(_job_refresh_ratings, 'cron', hour=3, minute=0,
                       id='ratings_refresh', replace_existing=True)
    _scheduler.add_job(_job_run_rules, 'cron', hour=4, minute=0,
                       id='rules_run', replace_existing=True)
    _scheduler.add_job(_job_backup, 'cron', hour=4, minute=30,
                       id='db_backup', replace_existing=True)
    _scheduler.add_job(_job_weekly_digest, 'cron', day_of_week='sun', hour=9,
                       id='weekly_digest', replace_existing=True)
    _scheduler.start()
    log.info("Scheduler started")


def stop_scheduler():
    if _scheduler.running:
        _scheduler.shutdown(wait=False)
        log.info("Scheduler stopped")


async def trigger_initial_sync():
    """Run *arr sync immediately on startup (Plex/ratings run on schedule).
    Keeping this lean avoids long DB write locks blocking the web UI."""
    log.info("Triggering initial *arr sync...")
    async with aiosqlite.connect(DB_PATH, timeout=60) as db:
        db.row_factory = aiosqlite.Row
        await db.execute("PRAGMA journal_mode=WAL")
        from app.sync.radarr import sync_all_movies
        from app.sync.sonarr import sync_all_shows
        try:
            await sync_all_movies(db)
        except Exception as e:
            log.error(f"Radarr initial sync: {e}")
        try:
            await sync_all_shows(db)
        except Exception as e:
            log.error(f"Sonarr initial sync: {e}")
    log.info("Initial *arr sync complete")


async def trigger_sync_by_source(source: str):
    """Trigger sync for a specific source. Returns False if already running."""
    if source in _running_syncs:
        log.warning(f"Sync already running for source: {source}")
        return False
    _running_syncs.add(source)
    try:
        return await _do_sync_by_source(source)
    finally:
        _running_syncs.discard(source)


def is_sync_running(source: str) -> bool:
    """Check if a sync is currently running for the given source."""
    return source in _running_syncs


async def _do_sync_by_source(source: str):
    """Internal: perform the actual sync for a given source."""
    async with aiosqlite.connect(DB_PATH, timeout=60) as db:
        db.row_factory = aiosqlite.Row
        await db.execute("PRAGMA journal_mode=WAL")

        if source in ('all', 'radarr'):
            from app.sync.radarr import sync_all_movies
            await sync_all_movies(db)

        if source in ('all', 'sonarr'):
            from app.sync.sonarr import sync_all_shows
            await sync_all_shows(db)

        if source in ('all', 'plex'):
            from app.sync.plex import sync_plex_library
            await sync_plex_library(db)

        if source in ('all', 'tautulli'):
            from app.sync.tautulli import sync_watch_history
            await sync_watch_history(db)

        if source == 'tautulli-ali':
            from app.sync.tautulli import sync_watch_history
            await sync_watch_history(db, instance_filter='ali')

        if source == 'tautulli-chris':
            from app.sync.tautulli import sync_watch_history
            await sync_watch_history(db, instance_filter='chris')

        if source in ('all', 'ratings'):
            from app.sync.omdb import sync_all_ratings as omdb_sync, sync_tv_ratings as omdb_tv_sync
            from app.sync.mdblist import sync_all_ratings as mdb_sync, sync_tv_ratings as mdb_tv_sync
            from app.sync.tmdb import refresh_stale_ratings, refresh_stale_tv_ratings, sync_collections, fill_missing_tv_ids
            from app.sync.radarr import update_scores
            from app.sync.sonarr import update_tv_scores
            # Manual trigger:
            # - OMDB/MDBList capped at 1000 (OMDB free-tier daily limit)
            # - TMDB uncapped (40 req/10s, very generous)
            try:
                await fill_missing_tv_ids(db)
            except Exception as e:
                log.error(f"fill_missing_tv_ids error: {e}")
            # Clear TMDB cache for Ended shows and reset ratings_updated_at so they get re-fetched
            try:
                await db.execute(
                    "DELETE FROM ratings_cache WHERE media_type='tv' AND source='tmdb' "
                    "AND external_id IN (SELECT CAST(tmdb_id AS TEXT) FROM tv_shows WHERE status='Ended' AND tmdb_id IS NOT NULL)"
                )
                await db.execute(
                    "UPDATE tv_shows SET ratings_updated_at=NULL WHERE status='Ended' AND tmdb_id IS NOT NULL"
                )
                await db.commit()
                log.info("[ratings] Cleared TMDB cache + reset ratings_updated_at for Ended shows — will re-fetch status")
            except Exception as e:
                log.error(f"TMDB cache clear error: {e}")
            for fn, kwargs in [
                (omdb_sync, {'limit': 1000}), (omdb_tv_sync, {'limit': 1000}),
                (mdb_sync, {'limit': 1000}), (mdb_tv_sync, {'limit': 1000}),
                (refresh_stale_ratings, {'limit': 0}), (refresh_stale_tv_ratings, {'limit': 0}),
                (sync_collections, {}), (update_scores, {}), (update_tv_scores, {}),
            ]:
                try:
                    await fn(db, **kwargs)
                except Exception as e:
                    log.error(f"{fn.__name__} error: {e}")
