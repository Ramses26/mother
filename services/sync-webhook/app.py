#!/usr/bin/env python3
"""
Sync Webhook Server - Project Mother

Receives webhooks from Radarr/Sonarr on download completion,
triggers targeted rsync to Unraid, sends notifications via Apprise.

Endpoints:
    POST /sync/radarr     - Radarr webhook receiver
    POST /sync/sonarr     - Sonarr webhook receiver
    GET  /health          - Health check
    POST /test            - Test notification
"""

import os
import re
import signal
import subprocess
import logging
import json
import threading
import sqlite3
import atexit
from datetime import datetime, timedelta
from pathlib import Path
from logging.handlers import RotatingFileHandler
from flask import Flask, request, jsonify, render_template, redirect, url_for
import apprise
import requests
from apscheduler.schedulers.background import BackgroundScheduler

# Configuration from environment
TELEGRAM_BOT_TOKEN = os.environ.get('TELEGRAM_BOT_TOKEN', '')
TELEGRAM_CHAT_ID = os.environ.get('TELEGRAM_CHAT_ID', '')
DRY_RUN = os.environ.get('SYNC_DRY_RUN', 'false').lower() == 'true'
LOG_LEVEL = os.environ.get('SYNC_LOG_LEVEL', 'INFO')
LOG_PATH = os.environ.get('SYNC_LOG_PATH', '/logs')
DB_PATH   = os.environ.get('SYNC_DB_PATH', '/data/sync_jobs.db')
BACKUP_DIR = os.environ.get('SYNC_BACKUP_DIR', '/data/backups')
DEDUP_STATUS_FILE = os.environ.get('DEDUP_STATUS_FILE', '/data/dedup_status.json')

# Shared TRaSH scoring config — single source of truth across all services.
# Mounted at /app/scoring/trash_scoring.json via docker-compose volume.
_SCORING_PATH = os.environ.get('TRASH_SCORING_PATH', '/app/scoring/trash_scoring.json')
with open(_SCORING_PATH) as _f:
    _SC = json.load(_f)
_SC_RES   = _SC['resolution']
_SC_SRC   = _SC['source']
_SC_SRC_TV = _SC.get('tv_source', _SC_SRC)
_SC_CF    = _SC['custom_formats']
_RG_RE    = re.compile(r'-([A-Za-z][A-Za-z0-9]{1,14})\.(mkv|mp4|avi|m4v|ts|m2ts)$', re.IGNORECASE)
MAX_CONCURRENT_SYNCS = int(os.environ.get('SYNC_MAX_CONCURRENT', '2'))
MAX_RETRIES = int(os.environ.get('SYNC_MAX_RETRIES', '20'))
RETRY_LOOKBACK_DAYS = int(os.environ.get('SYNC_RETRY_LOOKBACK_DAYS', '7'))

# Skip list - titles to exclude from syncing (case-insensitive partial match)
# These are typically very large files that timeout or cause issues
SKIP_TITLES = [
    title.strip() for title in
    os.environ.get('SYNC_SKIP_TITLES', 'The Lord of the Rings: The Fellowship of the Ring').split(',')
    if title.strip()
]

# Radarr/Sonarr API configuration for history scanning
RADARR_HD_URL = os.environ.get('RADARR_HD_URL', 'http://radarr-hd:7878')
RADARR_HD_API_KEY = os.environ.get('RADARR_HD_API_KEY', '')
RADARR_4K_URL = os.environ.get('RADARR_4K_URL', 'http://radarr-4k:7879')
RADARR_4K_API_KEY = os.environ.get('RADARR_4K_API_KEY', '')
SONARR_HD_URL = os.environ.get('SONARR_HD_URL', 'http://sonarr-hd:8989')
SONARR_HD_API_KEY = os.environ.get('SONARR_HD_API_KEY', '')
SONARR_4K_URL = os.environ.get('SONARR_4K_URL', 'http://sonarr-4k:8990')
SONARR_4K_API_KEY = os.environ.get('SONARR_4K_API_KEY', '')

# History scanner settings
HISTORY_SCAN_HOURS = int(os.environ.get('SYNC_HISTORY_SCAN_HOURS', '6'))  # Look back 6 hours
HISTORY_SCAN_INTERVAL = int(os.environ.get('SYNC_HISTORY_SCAN_INTERVAL', '30'))  # Every 30 minutes

# Stall watchdog settings
RSYNC_STALL_MINUTES = int(os.environ.get('RSYNC_STALL_MINUTES', '15'))   # No I/O for this long = stalled
RSYNC_MAX_MINUTES = int(os.environ.get('RSYNC_MAX_MINUTES', '240'))       # Absolute max runtime (4h)

# Unraid Agent (for inventory lookups — avoids slow CIFS listing over VPN)
UNRAID_AGENT_URL = os.environ.get('UNRAID_AGENT_URL', 'http://192.168.1.10:8100')
UNRAID_AGENT_API_KEY = os.environ.get('UNRAID_AGENT_API_KEY', '')

# Plex configuration
PLEX_URL = os.environ.get('PLEX_URL', '')  # e.g., http://10.0.0.50:32400
PLEX_TOKEN = os.environ.get('PLEX_TOKEN', '')
# Map destination paths to Plex library section IDs
PLEX_SECTIONS = {
    '/mnt/unraid/media/Movies': os.environ.get('PLEX_SECTION_MOVIES', ''),
    '/mnt/unraid/media/4K Movies': os.environ.get('PLEX_SECTION_MOVIES_4K', ''),
    '/mnt/unraid/media/TV Shows': os.environ.get('PLEX_SECTION_TV', ''),
    '/mnt/unraid/media/4K TV Shows': os.environ.get('PLEX_SECTION_TV_4K', ''),
}

# Path mappings: Container path -> (Source NFS, Destination NFS)
PATH_MAPPINGS = {
    # Radarr-HD: /movies -> Synology rs-movies -> Unraid Movies
    '/movies': (
        '/mnt/synology/rs-movies',
        '/mnt/unraid/media/Movies'
    ),
    # Radarr-4K: /movies-4k -> Synology 4kmovies -> Unraid 4K Movies
    '/movies-4k': (
        '/mnt/synology/rs-4kmedia/4kmovies',
        '/mnt/unraid/media/4K Movies'
    ),
    # Sonarr-HD: /tv -> Synology rs-tv -> Unraid TV Shows
    '/tv': (
        '/mnt/synology/rs-tv',
        '/mnt/unraid/media/TV Shows'
    ),
    # Sonarr-4K: /tv-4k -> Synology 4ktv -> Unraid 4K TV Shows
    '/tv-4k': (
        '/mnt/synology/rs-4kmedia/4ktv',
        '/mnt/unraid/media/4K TV Shows'
    ),
}


def get_dest_base_from_path(dest_path: str) -> str:
    """
    Extract the base destination path for Plex section lookup.

    For example:
        /mnt/unraid/media/TV Shows/Show Name/Season 01 -> /mnt/unraid/media/TV Shows
        /mnt/unraid/media/Movies -> /mnt/unraid/media/Movies

    Returns the matching base path or the original path if no match found.
    """
    # Check against PLEX_SECTIONS keys (sorted by length, longest first)
    for base_path in sorted(PLEX_SECTIONS.keys(), key=len, reverse=True):
        if dest_path.startswith(base_path):
            return base_path
    return dest_path

# Setup logging - console + file
logging.basicConfig(
    level=getattr(logging, LOG_LEVEL),
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Add file handler for persistent logs
try:
    log_dir = Path(LOG_PATH)
    log_dir.mkdir(parents=True, exist_ok=True)
    file_handler = RotatingFileHandler(
        log_dir / 'sync_webhook.log',
        maxBytes=10*1024*1024,  # 10MB
        backupCount=6
    )
    file_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
    logger.addHandler(file_handler)

    # Separate sync history log (human-readable)
    history_handler = RotatingFileHandler(
        log_dir / 'sync_history.log',
        maxBytes=10*1024*1024,
        backupCount=6
    )
    history_handler.setFormatter(logging.Formatter('%(message)s'))
    history_logger = logging.getLogger('sync_history')
    history_logger.addHandler(history_handler)
    history_logger.setLevel(logging.INFO)
except Exception as e:
    logger.warning(f"Could not setup file logging: {e}")
    history_logger = logger  # Fallback to main logger

# Setup Flask
app = Flask(__name__)

# Statistics tracking (in-memory, reset on restart)
stats = {
    'movies_synced': 0,
    'episodes_synced': 0,
    'failures': 0,
    'bytes_transferred': 0,
    'start_time': datetime.now().isoformat()
}
stats_lock = threading.Lock()

# History scanner timestamps (in-memory)
history_scanner_last_ran: datetime | None = None
history_scanner_last_found: int = 0

# Concurrency limit for rsync operations to prevent overwhelming NFS mounts
sync_semaphore = threading.Semaphore(MAX_CONCURRENT_SYNCS)
logger.info(f"Max concurrent syncs: {MAX_CONCURRENT_SYNCS}")


def init_database():
    """Initialize SQLite database for job tracking"""
    try:
        db_dir = Path(DB_PATH).parent
        db_dir.mkdir(parents=True, exist_ok=True)

        # Test write permissions
        test_file = db_dir / '.write_test'
        try:
            test_file.touch()
            test_file.unlink()
        except PermissionError:
            logger.error(f"No write permission to {db_dir}")
            return False

        conn = sqlite3.connect(DB_PATH, timeout=30)
        cursor = conn.cursor()
        # WAL mode allows concurrent reads during writes — prevents "database is locked" under load
        cursor.execute("PRAGMA journal_mode=WAL")
        cursor.execute("PRAGMA busy_timeout=30000")

        cursor.execute('''
            CREATE TABLE IF NOT EXISTS sync_jobs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                job_type TEXT NOT NULL,
                source_path TEXT NOT NULL,
                dest_path TEXT NOT NULL,
                title TEXT,
                quality TEXT,
                file_size INTEGER,
                status TEXT DEFAULT 'pending',
                error_message TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                completed_at TIMESTAMP,
                duration_seconds REAL,
                retry_count INTEGER DEFAULT 0
            )
        ''')

        # Add columns if they don't exist (for existing databases)
        cursor.execute("PRAGMA table_info(sync_jobs)")
        columns = [col[1] for col in cursor.fetchall()]
        if 'retry_count' not in columns:
            cursor.execute('ALTER TABLE sync_jobs ADD COLUMN retry_count INTEGER DEFAULT 0')
        if 'is_upgrade' not in columns:
            cursor.execute('ALTER TABLE sync_jobs ADD COLUMN is_upgrade INTEGER DEFAULT 0')
        if 'rsync_pid' not in columns:
            cursor.execute('ALTER TABLE sync_jobs ADD COLUMN rsync_pid INTEGER')
        if 'last_progress_bytes' not in columns:
            cursor.execute('ALTER TABLE sync_jobs ADD COLUMN last_progress_bytes INTEGER')
        if 'last_progress_at' not in columns:
            cursor.execute('ALTER TABLE sync_jobs ADD COLUMN last_progress_at TIMESTAMP')
        if 'stall_killed' not in columns:
            cursor.execute('ALTER TABLE sync_jobs ADD COLUMN stall_killed INTEGER DEFAULT 0')
        if 'started_at' not in columns:
            cursor.execute('ALTER TABLE sync_jobs ADD COLUMN started_at TIMESTAMP')
        if 'priority' not in columns:
            cursor.execute('ALTER TABLE sync_jobs ADD COLUMN priority INTEGER DEFAULT 0')
        if 'delete_after_sync' not in columns:
            cursor.execute('ALTER TABLE sync_jobs ADD COLUMN delete_after_sync TEXT DEFAULT NULL')

        cursor.execute('''
            CREATE INDEX IF NOT EXISTS idx_status ON sync_jobs(status)
        ''')

        cursor.execute('''
            CREATE INDEX IF NOT EXISTS idx_created ON sync_jobs(created_at)
        ''')

        conn.commit()
        conn.close()
        logger.info(f"Database initialized at {DB_PATH}")
    except Exception as e:
        logger.error(f"Could not initialize database: {e}")


def log_sync_job(job_type, source, dest, title, status, duration=None, error=None, file_size=0):
    """Log sync job to database and history file"""
    try:
        # Log to history file
        timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        duration_str = f"{duration:.1f}s" if duration else "N/A"
        history_logger.info(f"{timestamp} | {status.upper():8} | {job_type:8} | {title} | {duration_str}")

        # Log to database
        conn = sqlite3.connect(DB_PATH, timeout=30)
        cursor = conn.cursor()
        cursor.execute('''
            INSERT INTO sync_jobs (job_type, source_path, dest_path, title, status, duration_seconds, error_message, file_size, completed_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (job_type, source, dest, title, status, duration, error, file_size, datetime.now().isoformat() if status != 'pending' else None))
        conn.commit()
        conn.close()
    except Exception as e:
        logger.error(f"Could not log sync job: {e}")


def start_sync_job(job_type, source, dest, title, quality, file_size, retry_count=0, status='in_progress', delete_after_sync=None, priority=0):
    """Create a job entry with the given status and return the job_id.

    Pass status='pending' to create the row before the semaphore is acquired
    so the history scanner and auto-retry see it immediately and skip duplicates.
    Promote to 'in_progress' via _update_job_status() once the semaphore is held.
    Pass delete_after_sync=path to remove an old Unraid file after successful sync.
    priority: lower sorts first (same column/semantics as the manual "rush" button,
    which sets -1). Webhook handlers pass -1 for first-time imports (isUpgrade=False)
    so a new episode/movie a user is waiting on doesn't sit behind a backlog of
    routine quality-upgrade syncs; upgrades keep the default 0.
    """
    try:
        conn = sqlite3.connect(DB_PATH, timeout=30)
        cursor = conn.cursor()
        cursor.execute('''
            INSERT INTO sync_jobs (job_type, source_path, dest_path, title, quality, file_size, status, retry_count, delete_after_sync, priority)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (job_type, source, dest, title, quality, file_size, status, retry_count, delete_after_sync, priority))
        job_id = cursor.lastrowid
        conn.commit()
        conn.close()
        logger.debug(f"Created job {job_id} ({status}): {title}")
        return job_id
    except Exception as e:
        logger.error(f"Could not start sync job: {e}")
        return None


def _is_already_queued(source_path: str) -> bool:
    """Return True if this source_path is already actively queued (pending or in_progress).
    Only blocks concurrent duplicates — does NOT block retries of failed jobs.
    Auto-retry handles its own backoff; history scanner has its own in-scan dedup."""
    try:
        conn = sqlite3.connect(DB_PATH, timeout=30)
        c = conn.cursor()
        c.execute(
            """SELECT 1 FROM sync_jobs
               WHERE source_path = ?
               AND status IN ('pending', 'in_progress')
               LIMIT 1""",
            (source_path,)
        )
        result = c.fetchone()
        conn.close()
        return result is not None
    except Exception:
        return False  # On DB error, allow the sync to proceed


def _update_job_status(job_id: int | None, status: str):
    """Promote a job row from one status to another (e.g. pending → in_progress)."""
    if job_id is None:
        return
    try:
        conn = sqlite3.connect(DB_PATH, timeout=30)
        if status == 'in_progress':
            conn.execute(
                'UPDATE sync_jobs SET status = ?, started_at = ? WHERE id = ?',
                (status, datetime.utcnow().isoformat(), job_id)
            )
        else:
            conn.execute('UPDATE sync_jobs SET status = ? WHERE id = ?', (status, job_id))
        conn.commit()
        conn.close()
    except Exception as e:
        logger.error(f"Could not update job {job_id} status to {status}: {e}")


def complete_sync_job(job_id, status, duration=None, error=None):
    """Update a job to success or failed status"""
    try:
        # Log to history file
        conn = sqlite3.connect(DB_PATH, timeout=30)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()

        # Get job details for history log
        cursor.execute('SELECT job_type, title FROM sync_jobs WHERE id = ?', (job_id,))
        job = cursor.fetchone()

        if job:
            timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
            duration_str = f"{duration:.1f}s" if duration else "N/A"
            history_logger.info(f"{timestamp} | {status.upper():8} | {job['job_type']:8} | {job['title']} | {duration_str}")

        # Update the job
        cursor.execute('''
            UPDATE sync_jobs
            SET status = ?, completed_at = ?, duration_seconds = ?, error_message = ?
            WHERE id = ?
        ''', (status, datetime.utcnow().isoformat(), duration, error, job_id))
        conn.commit()
        conn.close()
        logger.debug(f"Completed job {job_id}: {status}")
    except Exception as e:
        logger.error(f"Could not complete sync job: {e}")


def update_job_pid(job_id: int, pid: int):
    """Store the rsync PID in the job record so the stall watchdog can track it."""
    try:
        conn = sqlite3.connect(DB_PATH, timeout=30)
        conn.execute('UPDATE sync_jobs SET rsync_pid = ? WHERE id = ?', (pid, job_id))
        conn.commit()
        conn.close()
    except Exception as e:
        logger.error(f"Could not update rsync PID for job {job_id}: {e}")


def get_rsync_io_bytes(pid: int):
    """
    Read total I/O bytes (rchar + wchar) summed across the entire process group
    of the given PID.  rsync spawns 2-3 child processes (generator, sender,
    receiver) and the actual data transfer happens in the children.  Monitoring
    only the parent PID can show zero I/O while children are actively copying,
    triggering false-positive stall kills.  Summing the whole pgid gives a true
    picture of transfer activity.

    Returns None if the process is gone or no I/O data is readable.
    """
    try:
        pgid = os.getpgid(pid)
    except (ProcessLookupError, OSError):
        return None

    total = 0
    found = False
    try:
        for entry in os.scandir('/proc'):
            if not entry.name.isdigit():
                continue
            try:
                if os.getpgid(int(entry.name)) != pgid:
                    continue
                with open(f'/proc/{entry.name}/io', 'r') as f:
                    data = dict(
                        line.split(': ', 1)
                        for line in f.read().splitlines()
                        if ': ' in line
                    )
                total += int(data.get('rchar', 0)) + int(data.get('wchar', 0))
                found = True
            except (ProcessLookupError, PermissionError, FileNotFoundError, ValueError, OSError):
                continue
    except OSError:
        return None

    return total if found else None


def validate_rsync_pid(pid: int, source_path: str) -> bool:
    """
    Confirm a PID is our rsync process and not a recycled unrelated process.
    Checks /proc/<pid>/cmdline for 'rsync' and the source path.
    """
    try:
        with open(f'/proc/{pid}/cmdline', 'rb') as f:
            cmdline = f.read().replace(b'\x00', b' ').decode('utf-8', errors='replace')
        return 'rsync' in cmdline and source_path in cmdline
    except (FileNotFoundError, PermissionError):
        return False


def _kill_stalled_job(cursor, job_id: int, pid: int, title: str, reason: str, running_minutes: float):
    """
    Kill a stalled rsync process group and set stall_killed=1 in the DB.
    The do_sync() thread will detect the flag and send the proper Telegram alert
    instead of a generic "Sync Failed" notification.
    """
    logger.warning(f"Stall watchdog: killing '{title}' (PID {pid}) - {reason}")

    # Mark stall_killed and commit BEFORE sending SIGKILL so do_sync() sees the flag
    # immediately when it wakes up from proc.communicate() — otherwise it reads 0 and
    # sends a generic "Sync Failed" notification instead of "Stalled Sync Killed".
    cursor.execute(
        "UPDATE sync_jobs SET stall_killed = 1 WHERE id = ? AND status = 'in_progress'",
        (job_id,)
    )
    cursor.connection.commit()

    # Kill the entire process group - rsync spawns sender/receiver/generator children
    try:
        pgid = os.getpgid(pid)
        os.killpg(pgid, signal.SIGKILL)
        logger.info(f"Stall watchdog: killed process group {pgid} for '{title}'")
    except ProcessLookupError:
        logger.debug(f"Stall watchdog: PID {pid} already gone for '{title}'")
    except Exception as e:
        logger.error(f"Stall watchdog: failed to kill PID {pid} for '{title}': {e}")


def check_stalled_syncs():
    """
    Watchdog: periodically detect and kill rsync processes that are frozen or
    have exceeded their maximum allowed runtime.

    A sync is stalled if its rsync process shows no I/O activity (rchar+wchar
    unchanged) for RSYNC_STALL_MINUTES. This catches D-state NFS hangs and
    other frozen-but-not-dead processes without killing legitimately slow transfers.

    A sync is force-killed if it exceeds RSYNC_MAX_MINUTES regardless of progress.

    A 30-minute grace period prevents killing fast syncs that haven't had their
    first progress snapshot yet.
    """
    logger.debug("Stall watchdog: checking for stalled syncs...")

    try:
        conn = sqlite3.connect(DB_PATH, timeout=30)
        conn.row_factory = sqlite3.Row
        c = conn.cursor()

        # Use UTC for all comparisons — SQLite CURRENT_TIMESTAMP stores UTC,
        # so datetime.now() (local time) would cause a 5h offset mismatch.
        now = datetime.utcnow()

        # Only check jobs older than the grace period (avoids false positives on fresh starts)
        grace_cutoff = (now - timedelta(minutes=30)).isoformat()
        c.execute("""
            SELECT id, title, source_path, rsync_pid,
                   last_progress_bytes, last_progress_at, created_at, started_at
            FROM sync_jobs
            WHERE status = 'in_progress'
              AND rsync_pid IS NOT NULL
              AND created_at < ?
        """, (grace_cutoff,))
        jobs = [dict(row) for row in c.fetchall()]

        for job in jobs:
            job_id = job['id']
            pid = job['rsync_pid']
            title = job['title']
            source_path = job['source_path']

            try:
                # Use started_at (when rsync actually began) for runtime, not created_at
                # (which includes time spent waiting as 'pending'). Fall back to created_at
                # for rows written before this column was added.
                ts = job.get('started_at') or job['created_at']
                started = datetime.fromisoformat(ts)
                running_minutes = (now - started).total_seconds() / 60
            except (ValueError, TypeError):
                continue

            # Validate PID is still our rsync (guards against PID reuse)
            if not validate_rsync_pid(pid, source_path):
                logger.debug(f"Stall watchdog: PID {pid} for '{title}' is gone (completed normally)")
                continue

            # Read current I/O bytes
            current_bytes = get_rsync_io_bytes(pid)
            if current_bytes is None:
                continue  # Can't read /proc/io, skip this cycle

            # Check absolute maximum runtime first
            if running_minutes >= RSYNC_MAX_MINUTES:
                reason = f"exceeded {RSYNC_MAX_MINUTES}m maximum runtime ({running_minutes:.0f}m elapsed)"
                _kill_stalled_job(c, job_id, pid, title, reason, running_minutes)
                continue

            # Check for stall (no I/O progress since last snapshot)
            last_bytes = job.get('last_progress_bytes')
            last_progress_at = job.get('last_progress_at')

            if last_bytes is None or current_bytes != last_bytes:
                # Progress made - update snapshot
                c.execute(
                    "UPDATE sync_jobs SET last_progress_bytes = ?, last_progress_at = ? WHERE id = ?",
                    (current_bytes, now.isoformat(), job_id)
                )
                if last_bytes is not None:
                    logger.debug(f"Stall watchdog: '{title}' active (+{current_bytes - last_bytes:,} bytes)")
            else:
                # No progress since last snapshot
                if last_progress_at:
                    try:
                        last_active = datetime.fromisoformat(last_progress_at)
                        stall_minutes = (now - last_active).total_seconds() / 60
                        if stall_minutes >= RSYNC_STALL_MINUTES:
                            reason = f"no I/O activity for {stall_minutes:.0f}m (threshold: {RSYNC_STALL_MINUTES}m)"
                            _kill_stalled_job(c, job_id, pid, title, reason, running_minutes)
                        else:
                            logger.debug(f"Stall watchdog: '{title}' idle {stall_minutes:.0f}m/{RSYNC_STALL_MINUTES}m")
                    except (ValueError, TypeError):
                        pass
                else:
                    # First time we've seen this job - initialize the snapshot
                    c.execute(
                        "UPDATE sync_jobs SET last_progress_bytes = ?, last_progress_at = ? WHERE id = ?",
                        (current_bytes, now.isoformat(), job_id)
                    )

        conn.commit()
        conn.close()

    except Exception as e:
        logger.error(f"Stall watchdog error: {e}")


def recover_interrupted_jobs():
    """On startup, recover interrupted jobs and retry unresolved failures"""
    try:
        conn = sqlite3.connect(DB_PATH, timeout=30)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()

        # Recover both pending and in_progress jobs from the previous session.
        # Both represent work that was never completed — pending threads were
        # waiting for a semaphore slot, in_progress threads were actively rsyncing.
        # Mark all as failed so _is_already_queued is unblocked, then re-queue them.
        cursor.execute('''
            SELECT * FROM sync_jobs
            WHERE status IN ('pending', 'in_progress')
            ORDER BY priority ASC, created_at ASC
        ''')
        interrupted_jobs = [dict(row) for row in cursor.fetchall()]

        if interrupted_jobs:
            logger.warning(f"Found {len(interrupted_jobs)} unfinished job(s) from previous session — re-queuing")

            for job in interrupted_jobs:
                cursor.execute('''
                    UPDATE sync_jobs
                    SET status = 'failed', error_message = 'Interrupted by restart', completed_at = ?
                    WHERE id = ?
                ''', (datetime.now().isoformat(), job['id']))

            conn.commit()

            # Track IDs just recovered so the unresolved-failed query below doesn't double-queue them
            interrupted_ids = {job['id'] for job in interrupted_jobs}

            # Only spawn up to MAX_CONCURRENT_SYNCS * 10 threads at startup.
            # With thousands of pending jobs, spawning one thread per job causes
            # severe GIL contention and health-check timeouts. The auto-retry
            # scheduler (15-min interval) will drain the rest from DB.
            STARTUP_THREAD_LIMIT = MAX_CONCURRENT_SYNCS * 10
            startup_queued = 0
            for job in interrupted_jobs:
                retry_count = (job.get('retry_count') or 0) + 1
                if retry_count <= MAX_RETRIES:
                    if startup_queued < STARTUP_THREAD_LIMIT:
                        logger.info(f"Re-queuing on startup: {job['title']} (was {job['status']}, attempt {retry_count}/{MAX_RETRIES})")
                        background_sync_with_retry(
                            job['source_path'],
                            job['dest_path'],
                            job['title'],
                            job.get('quality', 'Unknown'),
                            job.get('file_size', 0),
                            "Movie" if job['job_type'] == 'movie' else "Episode",
                            retry_count,
                            delete_after_sync=job.get('delete_after_sync')
                        )
                        startup_queued += 1
                    # Remaining jobs stay as 'failed' and will be picked up
                    # by the auto-retry scheduler within 15 minutes.
                else:
                    logger.warning(f"Job exceeded max retries, not retrying: {job['title']}")
            if startup_queued < len([j for j in interrupted_jobs if (j.get('retry_count') or 0) + 1 <= MAX_RETRIES]):
                deferred = len(interrupted_jobs) - startup_queued
                logger.info(f"Deferred {deferred} startup re-queues to auto-retry scheduler (thread limit={STARTUP_THREAD_LIMIT})")
        else:
            interrupted_ids = set()

        # Also find unresolved failed jobs that should be retried after restart
        # Exclude any jobs already queued above to prevent double-queuing
        lookback = f'-{RETRY_LOOKBACK_DAYS} days'
        if interrupted_ids:
            placeholders = ','.join('?' * len(interrupted_ids))
            cursor.execute(f'''
                SELECT f.* FROM sync_jobs f
                WHERE f.status = 'failed'
                AND f.created_at > strftime('%Y-%m-%dT%H:%M:%S', 'now', ?)
                AND (f.retry_count IS NULL OR f.retry_count < ?)
                AND f.id NOT IN ({placeholders})
                AND NOT EXISTS (
                    SELECT 1 FROM sync_jobs s
                    WHERE s.title = f.title
                    AND s.status = 'success'
                    AND s.created_at > f.created_at
                )
                ORDER BY f.created_at ASC
                LIMIT 50
            ''', (lookback, MAX_RETRIES) + tuple(interrupted_ids))
        else:
            cursor.execute('''
                SELECT f.* FROM sync_jobs f
                WHERE f.status = 'failed'
                AND f.created_at > strftime('%Y-%m-%dT%H:%M:%S', 'now', ?)
                AND (f.retry_count IS NULL OR f.retry_count < ?)
                AND NOT EXISTS (
                    SELECT 1 FROM sync_jobs s
                    WHERE s.title = f.title
                    AND s.status = 'success'
                    AND s.created_at > f.created_at
                )
                ORDER BY f.created_at ASC
                LIMIT 50
            ''', (lookback, MAX_RETRIES))
        unresolved_jobs = [dict(row) for row in cursor.fetchall()]
        conn.close()

        if unresolved_jobs:
            # Deduplicate by title
            seen_titles = set()
            unique_unresolved = []
            for job in unresolved_jobs:
                title = job['title'] or 'Unknown'
                if title not in seen_titles:
                    seen_titles.add(title)
                    unique_unresolved.append(job)

            logger.info(f"Found {len(unique_unresolved)} unresolved failed jobs to retry on startup")
            for job in unique_unresolved:
                retry_count = (job.get('retry_count') or 0) + 1
                if retry_count <= MAX_RETRIES:
                    logger.info(f"Queueing unresolved job for retry: {job['title']} (attempt {retry_count}/{MAX_RETRIES})")
                    background_sync_with_retry(
                        job['source_path'],
                        job['dest_path'],
                        job['title'],
                        job.get('quality', 'Unknown'),
                        job.get('file_size', 0),
                        "Movie" if job['job_type'] == 'movie' else "Episode",
                        retry_count,
                        delete_after_sync=job.get('delete_after_sync')
                    )

        return len(interrupted_jobs) + len(unresolved_jobs) if unresolved_jobs else len(interrupted_jobs)
    except Exception as e:
        logger.error(f"Error recovering interrupted jobs: {e}")
        return 0


def update_stats(job_type, success, file_size=0):
    """Update in-memory statistics"""
    with stats_lock:
        if success:
            if job_type == 'movie':
                stats['movies_synced'] += 1
            else:
                stats['episodes_synced'] += 1
            stats['bytes_transferred'] += file_size
        else:
            stats['failures'] += 1


def check_nfs_health():
    """Check if NFS mounts are accessible"""
    issues = []
    for container_path, (source, dest) in PATH_MAPPINGS.items():
        if not os.path.exists(source):
            issues.append(f"Source mount missing: {source}")
        if not os.path.exists(dest):
            issues.append(f"Destination mount missing: {dest}")
    return issues


# Initialize database on startup
init_database()

# Setup Apprise
apobj = apprise.Apprise()
if TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID:
    apprise_url = f"tgram://{TELEGRAM_BOT_TOKEN}/{TELEGRAM_CHAT_ID}/"
    apobj.add(apprise_url)
    logger.info("Apprise configured with Telegram")
else:
    logger.warning("Telegram credentials not configured - notifications disabled")

# Dedup-specific Apprise target, added 2026-07-30 (Ali's request): route Unraid dedup
# notifications to the same Telegram chat Curatorr's own Synology dedup already uses
# (CURATORR_TELEGRAM_CHAT_ID), instead of the general TELEGRAM_CHAT_ID every other
# sync-webhook notification uses. Falls back to the general apobj if unconfigured.
CURATORR_TELEGRAM_CHAT_ID = os.environ.get('CURATORR_TELEGRAM_CHAT_ID', '')
dedup_apobj = apprise.Apprise()
if TELEGRAM_BOT_TOKEN and CURATORR_TELEGRAM_CHAT_ID:
    dedup_apobj.add(f"tgram://{TELEGRAM_BOT_TOKEN}/{CURATORR_TELEGRAM_CHAT_ID}/")
    logger.info("Dedup notifications routed to Curatorr's Telegram chat")
else:
    logger.warning("CURATORR_TELEGRAM_CHAT_ID not configured - dedup notifications fall back to general chat")
    dedup_apobj = None


def send_notification(title: str, body: str, notify_type=apprise.NotifyType.INFO):
    """Send notification via Apprise"""
    try:
        if len(apobj) > 0:
            apobj.notify(
                title=title,
                body=body,
                notify_type=notify_type
            )
            logger.info(f"Notification sent: {title}")
        else:
            logger.warning("No notification services configured")
    except Exception as e:
        logger.error(f"Failed to send notification: {e}")


def send_dedup_notification(title: str, body: str, notify_type=apprise.NotifyType.INFO):
    """Send Unraid dedup notifications to Curatorr's Telegram chat (2026-07-30, Ali's
    request) -- same destination Curatorr's own Synology dedup already notifies to, so
    both dedup systems land in one place instead of Unraid's going to the general chat.
    Falls back to send_notification's general chat if CURATORR_TELEGRAM_CHAT_ID isn't set."""
    if dedup_apobj is None:
        send_notification(title, body, notify_type)
        return
    try:
        if len(dedup_apobj) > 0:
            dedup_apobj.notify(title=title, body=body, notify_type=notify_type)
            logger.info(f"Dedup notification sent (Curatorr chat): {title}")
        else:
            logger.warning("No dedup notification services configured")
    except Exception as e:
        logger.error(f"Failed to send dedup notification: {e}")


def trigger_plex_scan(dest_path: str, specific_path: str = None):
    """
    Trigger Plex library scan for the appropriate section.

    Args:
        dest_path: The destination base path (e.g., /mnt/unraid/media/Movies)
        specific_path: Optional specific folder path to scan (faster than full library)
    """
    if not PLEX_URL or not PLEX_TOKEN:
        logger.debug("Plex not configured, skipping library scan")
        return False

    # Find the section ID for this destination
    section_id = PLEX_SECTIONS.get(dest_path, '')
    if not section_id:
        logger.warning(f"No Plex section configured for: {dest_path}")
        return False

    try:
        # Build the scan URL
        url = f"{PLEX_URL}/library/sections/{section_id}/refresh"
        params = {'X-Plex-Token': PLEX_TOKEN}

        # If specific path provided, do a targeted scan (much faster)
        if specific_path:
            # Translate path from sync-webhook's view to Plex's view
            # sync-webhook: /mnt/unraid/media/...  ->  Plex: /mnt/media/...
            plex_path = specific_path.replace('/mnt/unraid/media/', '/mnt/media/')
            params['path'] = plex_path
            logger.info(f"Triggering Plex scan for: {plex_path}")
        else:
            logger.info(f"Triggering Plex full library scan for section {section_id}")

        response = requests.get(url, params=params, timeout=30)

        if response.status_code == 200:
            logger.info(f"Plex scan triggered successfully for section {section_id}")
            return True
        else:
            logger.error(f"Plex scan failed: HTTP {response.status_code}")
            return False

    except Exception as e:
        logger.error(f"Failed to trigger Plex scan: {e}")
        return False


def translate_path(container_path: str) -> tuple:
    """
    Translate container path to source/destination NFS paths.

    Preserves the folder structure in the destination path for FILES.
    For FOLDERS, the destination is just the base (rsync will create the folder).

    Examples:
        FILE (TV episode):
            /tv/Show Name/Season 01/episode.mkv ->
                source:    /mnt/synology/rs-tv/Show Name/Season 01/episode.mkv
                dest:      /mnt/unraid/media/TV Shows/Show Name/Season 01
                dest_base: /mnt/unraid/media/TV Shows
            Result: /mnt/unraid/media/TV Shows/Show Name/Season 01/episode.mkv ✓

        FOLDER (Movie):
            /movies/Movie Title (2024) ->
                source:    /mnt/synology/rs-movies/Movie Title (2024)
                dest:      /mnt/unraid/media/Movies
                dest_base: /mnt/unraid/media/Movies
            Result: /mnt/unraid/media/Movies/Movie Title (2024)/movie.mkv ✓

    Returns: (source_path, dest_path, dest_base) or (None, None, None) if no mapping found
    """
    # Sort by path length (longest first) to match /movies-4k before /movies
    sorted_mappings = sorted(PATH_MAPPINGS.items(), key=lambda x: len(x[0]), reverse=True)

    for container_base, (src_base, dst_base) in sorted_mappings:
        if container_path.startswith(container_base):
            # Get the relative path after the container base
            relative = container_path[len(container_base):].lstrip('/')
            source = os.path.join(src_base, relative)

            # Determine if source is a file or directory
            # Check if the relative path looks like a file (has extension in last component)
            # Common video extensions: .mkv, .mp4, .avi, .mov, .wmv, .m4v, .ts
            basename = os.path.basename(relative)
            is_likely_file = '.' in basename and not basename.startswith('.')

            if is_likely_file:
                # It's a file - include the parent directory structure in destination
                # e.g., "Show Name/Season 01/episode.mkv" -> dest includes "Show Name/Season 01"
                relative_dir = os.path.dirname(relative)
                dest_dir = os.path.join(dst_base, relative_dir) if relative_dir else dst_base
            else:
                # It's a directory - destination is just the base
                # rsync will copy the folder INTO the destination
                # e.g., source "/Movies/Title (2024)" + dest "/media/Movies"
                #       -> creates "/media/Movies/Title (2024)/..."
                dest_dir = dst_base

            return source, dest_dir, dst_base
    return None, None, None


def translate_path_to_destination(container_path: str) -> str:
    """
    Translate a container path directly to a full destination path.

    Unlike translate_path(), this returns the FULL destination file path,
    useful for deletion operations where we need the exact file location.

    Args:
        container_path: Path as seen by Sonarr/Radarr container (e.g., /movies/Title/file.mkv)

    Returns:
        Full destination path on Unraid, or None if no mapping found

    Example:
        /movies/Movie Title (2024)/movie.mkv -> /mnt/unraid/media/Movies/Movie Title (2024)/movie.mkv
        /tv/Show/Season 01/ep.mkv -> /mnt/unraid/media/TV Shows/Show/Season 01/ep.mkv
    """
    sorted_mappings = sorted(PATH_MAPPINGS.items(), key=lambda x: len(x[0]), reverse=True)

    for container_base, (src_base, dst_base) in sorted_mappings:
        if container_path.startswith(container_base):
            relative = container_path[len(container_base):].lstrip('/')
            return os.path.join(dst_base, relative)
    return None










def run_rsync(source: str, dest_dir: str, is_file: bool = True, job_id: int = None) -> tuple:
    """
    Run rsync for a specific file or folder.

    Returns: (success: bool, message: str, duration: float)
    """
    start_time = datetime.now()

    # Ensure destination directory exists
    # This is important for TV shows where we create nested paths like
    # /media/TV Shows/Show Name/Season 01/
    try:
        os.makedirs(dest_dir, exist_ok=True)
        logger.debug(f"Ensured destination directory exists: {dest_dir}")
    except OSError as e:
        logger.error(f"Failed to create destination directory {dest_dir}: {e}")
        return False, f"Failed to create destination directory: {e}", 0

    # chmod is best-effort — Synology NFS rejects it via root_squash (EPERM) when
    # the directory already exists and is owned by a different UID. That's fine;
    # the existing perms are already set correctly by Sonarr/Radarr on Synology.
    try:
        os.chmod(dest_dir, 0o777)
    except OSError:
        pass

    # Build rsync command
    # -a: archive mode
    # -v: verbose
    # -h: human readable
    # --ignore-existing: don't overwrite existing files
    # --chmod: set permissions on destination (Unraid needs 777 for full write access)
    cmd = [
        'rsync',
        '-avh',
        '--no-group',       # Synology NFS root_squash rejects chgrp; group ownership unused
        '--ignore-existing',
        '--chmod=D777,F777',
        '--exclude', '#recycle',
        '--exclude', '@eaDir',
        '--exclude', '.DS_Store',
    ]

    if DRY_RUN:
        cmd.append('--dry-run')
        logger.info("DRY RUN mode enabled")

    # For files, sync the specific file
    # For folders, sync the entire folder
    cmd.extend([source, dest_dir + '/'])

    logger.info(f"Running: {' '.join(cmd)}")

    try:
        # Use Popen (not subprocess.run) so we can capture the PID immediately
        # and store it in the DB for the stall watchdog.
        # start_new_session=True puts rsync in its own process group so we can
        # killpg() all child processes (sender/receiver/generator) at once.
        proc = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            start_new_session=True
        )

        # Store PID in DB so stall watchdog can monitor this process
        if job_id:
            update_job_pid(job_id, proc.pid)
            logger.debug(f"Rsync started: PID {proc.pid} for job {job_id}")

        try:
            stdout, stderr = proc.communicate(timeout=43200)  # 12 hour absolute timeout
        except subprocess.TimeoutExpired:
            logger.warning(f"Rsync timeout after 4 hours: {source}")
            try:
                os.killpg(os.getpgid(proc.pid), signal.SIGKILL)
            except Exception:
                pass
            stdout, stderr = proc.communicate()
            duration = (datetime.now() - start_time).total_seconds()
            return False, "Rsync timed out after 4 hours", duration

        duration = (datetime.now() - start_time).total_seconds()

        if proc.returncode == 0:
            return True, stdout, duration
        else:
            return False, stderr or stdout, duration

    except Exception as e:
        duration = (datetime.now() - start_time).total_seconds()
        return False, str(e), duration


def format_size(size_bytes: int) -> str:
    """Format bytes to human readable size"""
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if size_bytes < 1024:
            return f"{size_bytes:.1f} {unit}"
        size_bytes /= 1024
    return f"{size_bytes:.1f} PB"


def background_sync(source: str, dest: str, title: str, quality: str, file_size: int, media_type: str, dest_base: str = None, retry_count: int = 0, delete_after_sync: str = None, priority: int = 0):
    """
    Run rsync in background thread and send notification when complete.
    This allows the webhook to return immediately.

    Args:
        source: Source path (file or folder)
        dest: Full destination path (may include nested folders for TV shows)
        title: Display title for notifications
        quality: Quality string
        file_size: File size in bytes
        media_type: "Movie" or "Episode"
        dest_base: Base destination path for Plex section lookup (e.g., /mnt/unraid/media/TV Shows)
        retry_count: Current retry attempt (0 = first try, 1 = first retry, etc.)
        delete_after_sync: Unraid path of old file to delete after successful sync (version replacement)
        priority: lower sorts first in the pending queue (default 0). Webhook handlers
            pass -1 for first-time imports so new content jumps ahead of routine
            quality-upgrade syncs — see start_sync_job()'s docstring.
    """
    job_type = 'movie' if media_type == 'Movie' else 'episode'
    # Fall back to extracting dest_base from dest if not provided (for retries from database)
    plex_base = dest_base or get_dest_base_from_path(dest)

    # Deduplicate: if a pending or in_progress row already exists for this
    # source path, another thread is already queued or running — skip.
    if _is_already_queued(source):
        logger.info(f"Skipping duplicate queue for: {title} (already pending/running)")
        return

    # Create the DB row as 'pending' NOW, before the semaphore.  This makes
    # the item visible to the history scanner and auto-retry immediately so
    # neither will re-queue it while it waits for a free slot.
    job_id = start_sync_job(job_type, source, dest, title, quality, file_size, retry_count, status='pending', delete_after_sync=delete_after_sync, priority=priority)

    def do_sync():
        # Acquire semaphore to limit concurrent syncs (prevents overwhelming NFS)
        retry_info = f" (retry {retry_count}/{MAX_RETRIES})" if retry_count > 0 else ""
        logger.info(f"Waiting for sync slot: {title}{retry_info}")
        sync_semaphore.acquire()
        logger.info(f"Acquired sync slot: {title}{retry_info}")

        try:
            # Check if job was cancelled while waiting for the semaphore
            if job_id:
                try:
                    _conn = sqlite3.connect(DB_PATH, timeout=30)
                    _cur = _conn.cursor()
                    _cur.execute('SELECT status FROM sync_jobs WHERE id = ?', (job_id,))
                    _row = _cur.fetchone()
                    _conn.close()
                    if _row and _row[0] == 'cancelled':
                        logger.info(f"Job {job_id} was cancelled while queued — skipping: {title}")
                        return
                except Exception:
                    pass

            # Promote pending → in_progress now that we hold the semaphore slot
            _update_job_status(job_id, 'in_progress')

            logger.info(f"Background sync started: {title}{retry_info}")

            # Check NFS health before sync
            nfs_issues = check_nfs_health()
            if nfs_issues:
                error_msg = "NFS mount issues: " + "; ".join(nfs_issues)
                logger.error(error_msg)
                if job_id:
                    complete_sync_job(job_id, 'failed', error=error_msg)
                update_stats(job_type, success=False)
                send_notification(
                    title=f"Sync Failed - NFS Error",
                    body=f"*{title}*\n\n{error_msg}",
                    notify_type=apprise.NotifyType.FAILURE
                )
                return

            # Run the rsync - pass job_id so PID is tracked for stall watchdog
            success, output, duration = run_rsync(source, dest, is_file=False, job_id=job_id)

            if success:
                # Update job to success
                if job_id:
                    complete_sync_job(job_id, 'success', duration=duration)
                update_stats(job_type, success=True, file_size=file_size)

                # Version sync: delete the inferior file after successful copy.
                # Direction depends on job quality:
                #   Reverse (MovieReverseSync/TVReverseSync): source=Unraid CIFS, dest=Synology NFS
                #     → old file is on Synology → direct os.remove() on NFS path
                #   Forward (MovieVersionSync/TVVersionSync): source=Synology NFS, dest=Unraid CIFS
                #     → old file is on Unraid → delete via Unraid Agent API
                # Detect direction from the actual delete path, not quality name —
                # quality may be 'Retry' when retried via manual endpoint but dest is still Synology
                is_reverse = quality in ('MovieReverseSync', 'TVReverseSync') or dest.startswith('/mnt/synology/')
                if job_id and not DRY_RUN:
                    try:
                        _conn = sqlite3.connect(DB_PATH, timeout=30)
                        _row = _conn.execute('SELECT delete_after_sync FROM sync_jobs WHERE id = ?', (job_id,)).fetchone()
                        _conn.close()
                        old_path = _row[0] if _row else None
                        if old_path:
                            # Verify the new file landed at the destination first
                            new_dest = os.path.join(dest, os.path.basename(source))
                            if os.path.exists(new_dest):
                                if is_reverse:
                                    # Delete old Synology file via direct NFS remove
                                    try:
                                        os.remove(old_path)
                                        logger.info(f"Reverse version sync: removed old Synology file {old_path}")
                                    except FileNotFoundError:
                                        # Already gone (Sonarr/Radarr may have replaced it) — no-op
                                        logger.info(f"Reverse version sync: old Synology file already removed {old_path}")
                                    except OSError as _oe:
                                        logger.warning(f"Reverse version sync: could not delete old Synology file {old_path}: {_oe}")
                                        send_notification(
                                            title="⚠️ Reverse Sync: Old Synology File Not Deleted",
                                            body=f"Rsync succeeded but NFS delete failed.\nPath: {old_path}\nError: {_oe}",
                                            notify_type=apprise.NotifyType.WARNING
                                        )
                                else:
                                    # Delete old Unraid file via Agent API
                                    _del_resp = requests.post(
                                        f"{UNRAID_AGENT_URL}/delete",
                                        json={'paths': [old_path]},
                                        headers={'X-Api-Key': UNRAID_AGENT_API_KEY},
                                        timeout=30
                                    )
                                    _del_result = _del_resp.json()
                                    if old_path in _del_result.get('deleted', []):
                                        logger.info(f"Version sync: removed old file {old_path}")
                                    else:
                                        _errs = _del_result.get('errors', {})
                                        logger.warning(f"Version sync: Agent could not delete {old_path}: {_errs}")
                                        send_notification(
                                            title="⚠️ Version Sync: Old File Not Deleted",
                                            body=f"Rsync succeeded but Agent rejected delete of old file.\nPath: {old_path}\nErrors: {_errs}",
                                            notify_type=apprise.NotifyType.WARNING
                                        )
                            else:
                                logger.warning(f"Version sync: new file not found at {new_dest} — skipping delete of {old_path}")
                                send_notification(
                                    title="⚠️ Version Sync: Destination Not Found",
                                    body=f"Rsync succeeded but new file missing at destination.\nExpected: {new_dest}\nOld file NOT deleted: {old_path}",
                                    notify_type=apprise.NotifyType.WARNING
                                )
                    except Exception as _e:
                        logger.error(f"Version sync: delete-after-sync error: {_e}")
                        send_notification(
                            title="⚠️ Version Sync: Delete-After-Sync Error",
                            body=f"Rsync succeeded but post-sync delete failed with exception.\nOld path: {old_path}\nError: {_e}",
                            notify_type=apprise.NotifyType.WARNING
                        )

                msg = (
                    f"*{title}*\n"
                    f"Quality: {quality}\n"
                    f"Size: {format_size(file_size)}\n"
                    f"Duration: {duration:.1f}s"
                )
                if DRY_RUN:
                    msg += "\n_(DRY RUN - no files copied)_"

                if media_type != "Episode":
                    send_notification(
                        title=f"{media_type} Synced",
                        body=msg,
                        notify_type=apprise.NotifyType.SUCCESS
                    )

                # Trigger Plex library scan for the synced content
                if not DRY_RUN:
                    # Build the specific path for targeted scan
                    # For folders (movies): specific_folder = dest + folder name
                    # For files (TV episodes): specific_folder = dest (already includes full path)
                    basename = os.path.basename(source)
                    is_file = '.' in basename and not basename.startswith('.')
                    if is_file:
                        # Source is a file - dest already has the full folder path
                        specific_folder = dest
                    else:
                        # Source is a folder - add folder name to dest
                        specific_folder = os.path.join(dest, basename)
                    trigger_plex_scan(plex_base, specific_folder)

                logger.info(f"Background sync completed: {title} in {duration:.1f}s")
            else:
                # Check if this was killed by the stall watchdog before marking failed
                stall_killed = False
                if job_id:
                    try:
                        conn = sqlite3.connect(DB_PATH, timeout=30)
                        row = conn.execute(
                            'SELECT stall_killed FROM sync_jobs WHERE id = ?', (job_id,)
                        ).fetchone()
                        conn.close()
                        stall_killed = bool(row and row[0])
                    except Exception:
                        pass

                if job_id:
                    complete_sync_job(job_id, 'failed', duration=duration, error=output[:500])
                update_stats(job_type, success=False)

                if stall_killed:
                    send_notification(
                        title=f"⚠️ Stalled Sync Killed - {media_type}",
                        body=(
                            f"*{title}*{retry_info}\n"
                            f"Duration: {duration/60:.0f}m\n\n"
                            f"Killed by stall watchdog (no I/O progress). Will auto-retry."
                        ),
                        notify_type=apprise.NotifyType.WARNING
                    )
                    logger.warning(f"Stalled sync killed: {title} after {duration/60:.0f}m")
                else:
                    send_notification(
                        title=f"Sync Failed - {media_type}",
                        body=f"*{title}*{retry_info}\n\nError: {output[:500]}",
                        notify_type=apprise.NotifyType.FAILURE
                    )
                    logger.error(f"Background sync failed: {title} - {output[:200]}")
        finally:
            # Always release semaphore, even if exception occurs
            sync_semaphore.release()
            logger.debug(f"Released sync slot: {title}")

    thread = threading.Thread(target=do_sync, daemon=True)
    thread.start()
    logger.info(f"Background sync thread started for: {title}")


def background_sync_with_retry(source: str, dest: str, title: str, quality: str, file_size: int, media_type: str, retry_count: int = 0, delete_after_sync: str = None):
    """Wrapper for background_sync that handles retry count.

    Must forward delete_after_sync — this is used exclusively by the startup
    recovery path (recover_interrupted_jobs) to re-queue jobs that were pending/
    in_progress/failed when the container restarted. Version/reverse-sync jobs
    carry a delete_after_sync target (the old file to remove once the new one
    lands); dropping it here silently turns a version-replacement into a copy-only
    job, leaving the old file behind. The next night's reconcile then re-detects
    that leftover as a fresh "mismatch" and queues another sync to clean it up —
    a full extra day's delay every time a restart interrupts one of these jobs.
    """
    # Clean up title if it has retry prefix
    clean_title = title.replace('[RETRY] ', '').replace('[RETRY]', '')
    background_sync(source, dest, clean_title, quality, file_size, media_type,
                   dest_base=None, retry_count=retry_count, delete_after_sync=delete_after_sync)


def get_job_counts():
    """Get counts of jobs by status from database"""
    try:
        conn = sqlite3.connect(DB_PATH, timeout=30)
        cursor = conn.cursor()
        cursor.execute('''
            SELECT status, COUNT(*) FROM sync_jobs
            WHERE created_at > strftime('%Y-%m-%dT%H:%M:%S', 'now', '-24 hours')
            GROUP BY status
        ''')
        counts = dict(cursor.fetchall())
        conn.close()
        return counts
    except Exception:
        return {}


def create_backup(label='scheduled'):
    """Copy the SQLite DB to the backup directory. Keep last 10 backups."""
    backup_dir = Path(BACKUP_DIR)
    backup_dir.mkdir(parents=True, exist_ok=True)
    ts = datetime.utcnow().strftime('%Y%m%d_%H%M%S')
    dest = backup_dir / f"sync_jobs_{label}_{ts}.db"
    try:
        import shutil
        # Checkpoint WAL before copying so backup is consistent
        conn = sqlite3.connect(DB_PATH, timeout=10)
        conn.execute("PRAGMA wal_checkpoint(TRUNCATE)")
        conn.close()
        shutil.copy2(DB_PATH, dest)
        # Keep only last 10 backups
        backups = sorted(backup_dir.glob('sync_jobs_*.db'))
        for old in backups[:-10]:
            old.unlink()
        logger.info(f"DB backup created: {dest.name}")
        return str(dest)
    except Exception as e:
        logger.error(f"DB backup failed: {e}")
        return None


def list_backups():
    backup_dir = Path(BACKUP_DIR)
    if not backup_dir.exists():
        return []
    files = sorted(backup_dir.glob('sync_jobs_*.db'), reverse=True)
    result = []
    for f in files:
        stat = f.stat()
        result.append({'filename': f.name, 'size': stat.st_size, 'modified': stat.st_mtime})
    return result


def send_daily_summary():
    """Send daily summary of sync activity to Telegram"""
    logger.info("Generating daily summary...")

    try:
        conn = sqlite3.connect(DB_PATH, timeout=30)
        cursor = conn.cursor()

        # Get yesterday's stats
        yesterday = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%d')

        cursor.execute('''
            SELECT
                SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) as successful,
                SUM(CASE WHEN status = 'failed' THEN 1 ELSE 0 END) as failed,
                SUM(CASE WHEN job_type = 'movie' AND status = 'success' THEN 1 ELSE 0 END) as movies,
                SUM(CASE WHEN job_type = 'episode' AND status = 'success' THEN 1 ELSE 0 END) as episodes,
                SUM(CASE WHEN status = 'success' THEN file_size ELSE 0 END) as total_bytes,
                SUM(CASE WHEN status = 'success' THEN duration_seconds ELSE 0 END) as total_duration
            FROM sync_jobs
            WHERE date(created_at) = ?
        ''', (yesterday,))

        row = cursor.fetchone()

        # Get list of failed job titles (exclude retries to avoid duplicates)
        cursor.execute('''
            SELECT title, error_message FROM sync_jobs
            WHERE date(created_at) = ? AND status = 'failed'
            AND title NOT LIKE '[RETRY%'
            ORDER BY created_at DESC
            LIMIT 10
        ''', (yesterday,))
        failed_jobs = cursor.fetchall()

        # Also get any jobs still needing attention (failed within lookback, not yet resolved)
        lookback = f'-{RETRY_LOOKBACK_DAYS} days'
        cursor.execute('''
            SELECT DISTINCT title FROM sync_jobs
            WHERE status = 'failed'
            AND created_at > strftime('%Y-%m-%dT%H:%M:%S', 'now', ?)
            AND title NOT LIKE '[RETRY%'
            AND title NOT IN (
                SELECT title FROM sync_jobs
                WHERE status = 'success'
                AND created_at > strftime('%Y-%m-%dT%H:%M:%S', 'now', ?)
            )
            LIMIT 10
        ''', (lookback, lookback))
        unresolved_jobs = cursor.fetchall()

        conn.close()

        if row:
            successful, failed, movies, episodes, total_bytes, total_duration = row
            total_bytes = total_bytes or 0
            total_duration = total_duration or 0

            # Format the summary
            msg = f"""📊 *Daily Sync Summary - {yesterday}*

✅ Successful: {successful or 0}
❌ Failed: {failed or 0}

🎬 Movies: {movies or 0}
📺 Episodes: {episodes or 0}

💾 Data Synced: {format_size(total_bytes)}
⏱️ Total Duration: {total_duration/60:.1f} minutes"""

            # List failed jobs with titles
            if failed_jobs:
                msg += f"\n\n⚠️ *Failed Syncs:*"
                for title, error in failed_jobs[:5]:  # Limit to 5 to avoid huge messages
                    clean_title = title.replace('[RETRY] ', '') if title else 'Unknown'
                    short_error = (error[:50] + '...') if error and len(error) > 50 else (error or 'Unknown error')
                    msg += f"\n• {clean_title}"
                if len(failed_jobs) > 5:
                    msg += f"\n  _...and {len(failed_jobs) - 5} more_"

            # List unresolved jobs that need attention
            if unresolved_jobs:
                msg += f"\n\n🔴 *Needs Attention ({len(unresolved_jobs)}):*"
                for (title,) in unresolved_jobs[:5]:
                    clean_title = title.replace('[RETRY] ', '') if title else 'Unknown'
                    msg += f"\n• {clean_title}"
                if len(unresolved_jobs) > 5:
                    msg += f"\n  _...and {len(unresolved_jobs) - 5} more_"

            send_notification(
                title="Daily Sync Summary",
                body=msg,
                notify_type=apprise.NotifyType.INFO
            )
            logger.info(f"Daily summary sent: {successful} success, {failed} failed")
        else:
            send_notification(
                title="Daily Sync Summary",
                body=f"📊 *Daily Summary - {yesterday}*\n\nNo sync activity recorded.",
                notify_type=apprise.NotifyType.INFO
            )
            logger.info("Daily summary sent: no activity")

    except Exception as e:
        logger.error(f"Error generating daily summary: {e}")


# Initialize scheduler for daily summary and auto-retry
# All times expressed in America/New_York (Eastern); APScheduler handles DST automatically.
scheduler = BackgroundScheduler(timezone='America/New_York')
scheduler.add_job(
    func=send_daily_summary,
    trigger='cron',
    hour=20,
    minute=5,  # 8:05 PM ET
    id='daily_summary',
    name='Daily sync summary',
    replace_existing=True
)


def send_error_alert(error_type: str, error_msg: str):
    """Send alert notification for system errors"""
    send_notification(
        title=f"⚠️ Sync Webhook Error",
        body=f"*{error_type}*\n\n{error_msg}",
        notify_type=apprise.NotifyType.FAILURE
    )


# Track if we've already alerted about persistent errors (avoid spam)
_error_alert_sent = {}


def get_retry_wait_minutes(retry_count):
    """Get minimum wait time in minutes based on retry count (exponential backoff)"""
    if retry_count < 3:
        return 15       # Retries 1-3: every 15 minutes
    elif retry_count < 6:
        return 60       # Retries 4-6: every 1 hour
    elif retry_count < 12:
        return 240      # Retries 7-12: every 4 hours
    else:
        return 720      # Retries 13+: every 12 hours


def auto_retry_failed():
    """Automatically retry failed jobs with exponential backoff"""
    global _error_alert_sent
    logger.info("Auto-retry: checking for failed jobs...")
    try:
        conn = sqlite3.connect(DB_PATH, timeout=30)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()

        # Get failed jobs within lookback window that haven't exceeded max retries
        # Exclude titles that have a successful sync AFTER the failed one
        lookback = f'-{RETRY_LOOKBACK_DAYS} days'
        cursor.execute('''
            SELECT f.* FROM sync_jobs f
            WHERE f.status = 'failed'
            AND f.created_at > strftime('%Y-%m-%dT%H:%M:%S', 'now', ?)
            AND (f.retry_count IS NULL OR f.retry_count < ?)
            AND NOT EXISTS (
                SELECT 1 FROM sync_jobs s
                WHERE s.title = f.title
                AND s.status = 'success'
                AND s.created_at > f.created_at
            )
            ORDER BY f.created_at ASC
            LIMIT 500
        ''', (lookback, MAX_RETRIES))
        failed_jobs = [dict(row) for row in cursor.fetchall()]
        conn.close()

        # Clear error state on success
        _error_alert_sent.pop('database', None)

        if failed_jobs:
            # Deduplicate by title (only retry each unique title once per cycle)
            seen_titles = set()
            unique_jobs = []
            for job in failed_jobs:
                title = job['title'] or 'Unknown'
                if title not in seen_titles:
                    seen_titles.add(title)
                    unique_jobs.append(job)

            now = datetime.utcnow()
            queued = 0
            for job in unique_jobs:
                retry_count = (job.get('retry_count') or 0) + 1
                wait_minutes = get_retry_wait_minutes(retry_count)

                # Check if enough time has passed since last failure (backoff)
                # completed_at is stored as UTC via datetime.utcnow() so compare against utcnow()
                completed_at = job.get('completed_at')
                if completed_at:
                    try:
                        last_failed = datetime.fromisoformat(completed_at)
                        elapsed = (now - last_failed).total_seconds() / 60
                        if elapsed < wait_minutes:
                            continue  # Not ready for retry yet
                    except (ValueError, TypeError):
                        pass  # If we can't parse, allow retry

                if retry_count <= MAX_RETRIES:
                    source = job['source_path']
                    dest = job['dest_path']
                    title = job['title'] or 'Unknown'
                    job_type = job['job_type']
                    file_size = job['file_size'] or 0
                    quality = job.get('quality') or 'Retry'
                    delete_after = job.get('delete_after_sync')

                    # Stale-entry guard: source file gone means Sonarr/Radarr upgraded it.
                    # Mark all rows for this source as success so history scanner stops re-queuing.
                    if source and not os.path.exists(source):
                        logger.info(f"Auto-retry: source gone (upgraded?), marking stale: {title!r} {source}")
                        _conn2 = sqlite3.connect(DB_PATH, timeout=30)
                        _conn2.execute(
                            "UPDATE sync_jobs SET status='success', error_message='stale: source file upgraded' "
                            "WHERE source_path = ? AND status IN ('pending','failed','in_progress')",
                            (source,)
                        )
                        _conn2.commit()
                        _conn2.close()
                        continue

                    media_type = "Movie" if job_type == 'movie' else "Episode"
                    background_sync(source, dest, title, quality, file_size, media_type,
                                   dest_base=None, retry_count=retry_count,
                                   delete_after_sync=delete_after)
                    queued += 1
                    logger.info(f"Auto-retry: queued {title} (attempt {retry_count}/{MAX_RETRIES})")
                else:
                    logger.warning(f"Auto-retry: {title} exceeded max retries ({MAX_RETRIES}), skipping")

            if queued > 0:
                logger.info(f"Auto-retry: queued {queued} of {len(unique_jobs)} failed jobs")
            else:
                logger.debug("Auto-retry: all failed jobs waiting for backoff window")
        else:
            logger.debug("Auto-retry: no failed jobs to retry")

    except Exception as e:
        logger.error(f"Auto-retry error: {e}")
        # Send alert only once per error type (avoid spam)
        if 'database' not in _error_alert_sent:
            send_error_alert("Database Error", str(e))
            _error_alert_sent['database'] = True


def recover_orphaned_pending_jobs():
    """Detect and recover 'pending' jobs whose do_sync thread died before ever
    acquiring the sync semaphore -- added 2026-07-30.

    Root cause found live: running reconcile/gap-scan functions via a detached
    `docker exec` process (instead of through the running app's own API) spawns
    daemon threads that die the instant that separate process exits, mid-flight,
    sometimes while blocked on sync_semaphore.acquire() -- confirmed via logs
    showing "Waiting for sync slot" with no matching "Acquired sync slot" ever
    following, for jobs whose thread had genuinely started. A concurrent flood
    of ~700 such threads from one exec'd session also appears to have caused a
    handful of properly API-triggered jobs in the *live* process to die the same
    way (exact mechanism unconfirmed -- plausibly a container-wide pid/thread
    limit -- but the detection and recovery approach below doesn't depend on
    knowing the exact cause).

    A dead pending-job thread is invisible to both recover_interrupted_jobs()
    (startup-only) and auto_retry_failed() (only looks at status='failed') --
    it just sits as 'pending' forever. Worse, _is_already_queued() then
    silently blocks every future legitimate attempt to sync that exact source
    path, since a 'pending' row for it still exists. Confirmed live: 748 rows,
    all created 2026-07-25, deferring the nightly Unraid dedup every single day
    for 5 straight days (dedup refuses to run while any TVGapSync/GapSync/
    TVVersionSync/MovieVersionSync/TVReverseSync/MovieReverseSync job is
    pending/in_progress) with the exact same count night after night --
    a real backlog would fluctuate as jobs complete; a frozen, unchanging count
    is the signature of orphaned rows, not genuine queue depth.

    Detection: a live, correctly-waiting thread would acquire a slot the
    instant one frees up, so it cannot coexist with a fully-idle semaphore for
    more than an instant. If sync_semaphore is currently at full capacity
    (nothing running) and 'pending' rows still exist that are older than a
    short buffer (avoids racing a job that's mid-way through queuing right
    now), those rows are provably orphaned -- no live thread is waiting on
    them. 'in_progress' jobs aren't handled here; the stall watchdog
    (check_stalled_syncs) already covers threads that died mid-rsync.
    """
    try:
        if sync_semaphore._value < MAX_CONCURRENT_SYNCS:
            return  # syncs actively running -- pending rows may legitimately be waiting

        conn = sqlite3.connect(DB_PATH, timeout=30)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        cursor.execute("""
            SELECT id, title, source_path FROM sync_jobs
            WHERE status = 'pending'
            AND created_at < strftime('%Y-%m-%dT%H:%M:%S', 'now', '-5 minutes')
        """)
        orphaned = [dict(row) for row in cursor.fetchall()]
        if not orphaned:
            conn.close()
            return

        for job in orphaned:
            cursor.execute(
                "UPDATE sync_jobs SET status = 'failed', "
                "error_message = 'Orphaned pending job recovered (thread died before acquiring sync slot)', "
                "completed_at = ? WHERE id = ?",
                (datetime.utcnow().isoformat(), job['id'])
            )
        conn.commit()
        conn.close()

        logger.warning(
            f"Recovered {len(orphaned)} orphaned pending job(s) (semaphore idle, no live thread) "
            f"-- marked failed for auto-retry to pick up next cycle. Sample: "
            f"{[j['title'] for j in orphaned[:5]]}"
        )
        send_notification(
            title="Sync: Orphaned Jobs Recovered",
            body=f"{len(orphaned)} pending job(s) had no live thread (semaphore was fully idle) — "
                 f"marked failed, auto-retry will requeue them within 15 minutes.",
            notify_type=apprise.NotifyType.WARNING
        )
    except Exception as e:
        logger.error(f"recover_orphaned_pending_jobs failed: {e}")


# Add auto-retry job (every 15 minutes)
scheduler.add_job(
    func=auto_retry_failed,
    trigger='interval',
    minutes=15,
    id='auto_retry',
    name='Auto retry failed syncs',
    replace_existing=True
)

# Add orphaned-pending-job recovery (every 15 minutes, same cadence as auto-retry
# since it feeds into it — see recover_orphaned_pending_jobs docstring)
scheduler.add_job(
    func=recover_orphaned_pending_jobs,
    trigger='interval',
    minutes=15,
    id='recover_orphaned_pending',
    name='Recover orphaned pending syncs',
    replace_existing=True
)

# Add stall watchdog job (every 15 minutes, offset by 7 min to spread load)
scheduler.add_job(
    func=check_stalled_syncs,
    trigger='interval',
    minutes=15,
    id='stall_watchdog',
    name='Stall watchdog - detect and kill frozen rsync processes',
    replace_existing=True
)
logger.info(f"Stall watchdog enabled - stall threshold: {RSYNC_STALL_MINUTES}m, max runtime: {RSYNC_MAX_MINUTES}m")


def scan_arr_history():
    """
    Scan Radarr/Sonarr history for recent downloads and sync any that were missed.
    This catches downloads where the webhook failed (container down, network issue, etc).
    """
    global history_scanner_last_ran, history_scanner_last_found
    history_scanner_last_ran = datetime.utcnow()
    logger.info("History scanner: checking for missed downloads...")

    missed_count = 0
    missed_titles = []
    lookback = datetime.utcnow() - timedelta(hours=HISTORY_SCAN_HOURS)

    # Get list of recently synced titles from our database.
    # Bug fix: pending/in_progress are checked without a time limit — old jobs (weeks/months
    # old) must still block re-queuing even if outside the 48h lookback window.
    # success/failed are time-limited: we only care about recent completions/failures.
    synced_titles = set()
    try:
        conn = sqlite3.connect(DB_PATH, timeout=30)
        c = conn.cursor()
        c.execute('''
            SELECT title FROM sync_jobs
            WHERE status IN ('in_progress', 'pending')
            UNION
            SELECT title FROM sync_jobs
            WHERE created_at > ? AND status IN ('success', 'failed')
        ''', (lookback.isoformat(),))
        synced_titles = {row[0] for row in c.fetchall()}
        conn.close()
    except Exception as e:
        logger.error(f"History scanner: database error: {e}")
        return

    # Per-scan dedup: Sonarr/Radarr history often has multiple import events for
    # the same item (successive upgrades).  Track what we've queued in THIS run
    # so we don't create multiple jobs for the same logical episode/movie.
    queued_this_scan: set = set()

    # Define arr instances to check
    arr_configs = [
        ('Radarr-HD', RADARR_HD_URL, RADARR_HD_API_KEY, 'movie', '/movies'),
        ('Radarr-4K', RADARR_4K_URL, RADARR_4K_API_KEY, 'movie', '/movies-4k'),
        ('Sonarr-HD', SONARR_HD_URL, SONARR_HD_API_KEY, 'episode', '/tv'),
        ('Sonarr-4K', SONARR_4K_URL, SONARR_4K_API_KEY, 'episode', '/tv-4k'),
    ]

    for name, url, api_key, media_type, container_path in arr_configs:
        if not api_key:
            continue

        try:
            # Query history API
            history_url = f"{url}/api/v3/history"
            params = {
                'pageSize': 100,
                'sortKey': 'date',
                'sortDirection': 'descending',
                # Include nested media objects so title/path fields are populated
                'includeMovie': 'true',
                'includeSeries': 'true',
                'includeEpisode': 'true',
            }
            headers = {'X-Api-Key': api_key}

            response = requests.get(history_url, params=params, headers=headers, timeout=30)
            if response.status_code != 200:
                logger.warning(f"History scanner: {name} API returned {response.status_code}")
                continue

            data = response.json()
            # Filter for completed downloads only
            records = [r for r in data.get('records', []) if r.get('eventType') == 'downloadFolderImported']

            for record in records:
                # Check if within lookback window
                date_str = record.get('date', '')
                if date_str:
                    try:
                        record_date = datetime.fromisoformat(date_str.replace('Z', '+00:00'))
                        if record_date.replace(tzinfo=None) < lookback:
                            continue  # Too old
                    except:
                        pass

                # Get title
                if media_type == 'movie':
                    movie = record.get('movie', {})
                    title = movie.get('title', '')
                    year = movie.get('year', '')
                    display_title = f"{title} ({year})" if year else title
                    # folderPath may be null; fall back to directory of importedPath
                    folder_path = movie.get('folderPath', '') or ''
                    if not folder_path:
                        imported = record.get('data', {}).get('importedPath', '')
                        if imported:
                            folder_path = imported.rsplit('/', 1)[0]
                else:
                    series = record.get('series', {})
                    episode = record.get('episode', {})
                    title = series.get('title', '')
                    season = episode.get('seasonNumber', 0)
                    ep_num = episode.get('episodeNumber', 0)
                    display_title = f"{title} - S{season:02d}E{ep_num:02d}"
                    # Use specific episode file path if available (avoids syncing entire show dir)
                    imported_path = record.get('data', {}).get('importedPath', '')
                    folder_path = imported_path if imported_path else series.get('path', '')

                if not title:
                    continue

                # Check if already synced (episode-level match for TV, title match for movies)
                check_title = display_title if media_type == 'episode' else title
                already_synced = any(check_title.lower() in s.lower() or s.lower() in check_title.lower()
                                    for s in synced_titles)
                if already_synced:
                    continue

                # Per-scan dedup: skip if we already queued this logical item in this run.
                # Catches multiple Sonarr/Radarr import events for the same episode (upgrades).
                if check_title in queued_this_scan:
                    continue

                # Check skip list
                skip = False
                for skip_title in SKIP_TITLES:
                    if skip_title.lower() in title.lower():
                        skip = True
                        break
                if skip:
                    continue

                # Get source and dest paths
                source, dest, dest_base = translate_path(folder_path)
                if not source:
                    continue

                # Stale-entry guard: if the source file no longer exists on NFS,
                # Sonarr/Radarr upgraded it since it was imported. Skip silently so
                # we don't keep re-queuing a ghost file every 30 min.
                if not os.path.exists(source):
                    logger.info(
                        f"History scanner: source gone (upgraded?), skipping {display_title!r}: {source}"
                    )
                    queued_this_scan.add(check_title)  # prevent re-check this scan
                    continue

                logger.info(f"History scanner: found missed download - {display_title}")
                missed_titles.append(display_title)
                queued_this_scan.add(check_title)

                # Queue the sync
                source_path = source if media_type == 'movie' else folder_path.replace(container_path, source.rsplit('/', 1)[0])
                background_sync(
                    source=source,
                    dest=dest,
                    title=display_title,
                    quality="(catchup)",
                    file_size=0,
                    media_type="Movie" if media_type == 'movie' else "Episode",
                    dest_base=dest_base
                )
                missed_count += 1

        except requests.exceptions.RequestException as e:
            logger.warning(f"History scanner: {name} connection error: {e}")
        except Exception as e:
            logger.error(f"History scanner: {name} error: {e}")

    history_scanner_last_found = missed_count

    if missed_count > 0:
        logger.info(f"History scanner: queued {missed_count} missed downloads for sync")
        titles_list = "\n".join(f"• {t}" for t in missed_titles)
        send_notification(
            title="Catchup Sync",
            body=f"Queued {missed_count} missed download(s):\n{titles_list}",
            notify_type=apprise.NotifyType.INFO
        )
    else:
        logger.info("History scanner: no missed downloads found")


def _get_unraid_movie_folders() -> set:
    """
    Fetch HD movie folder names from the Unraid Agent API.
    Returns a set of folder names (e.g. {"Wuthering Heights (2026)", ...}).
    Raises on failure so the caller can log and skip.
    """
    url = f"{UNRAID_AGENT_URL}/inventory"
    params = {'path': '/mnt/user/Media/Movies', 'refresh': 'true'}
    headers = {'X-Api-Key': UNRAID_AGENT_API_KEY}
    resp = requests.get(url, params=params, headers=headers, timeout=120)
    resp.raise_for_status()
    data = resp.json()
    folders = set()
    for item in data.get('items', []):
        path = item.get('path', '')
        if path:
            # path = /mnt/user/Media/Movies/<folder>/<filename>
            parts = path.split('/')
            if len(parts) >= 6:
                folders.add(parts[5])
    return folders


def _score_filename(filename: str, size_bytes: int = 0, media_type: str = 'movie') -> int:
    """TRaSH-aligned quality score from a media filename.
    Scores loaded from configs/scoring/trash_scoring.json (shared with curatorr).
    Higher score wins in version reconcile comparisons.

    media_type='tv' uses the TV source ranking (WEB-DL > Bluray) instead of the
    movie ranking (Bluray > WEB-DL) — TV intentionally differs, per
    scripts/lib/quality_scoring.py's TV_SOURCE_SCORES and CLAUDE.md. Fixed
    2026-07-02: reconcile_tv_versions() was previously using the movie ranking for
    TV episodes too, which could pick the wrong side in a Bluray-vs-WEB-DL comparison.
    """
    name = filename.lower()
    src_table = _SC_SRC_TV if media_type == 'tv' else _SC_SRC

    # Resolution — explicit pixel-count tags first so "[4K Remaster]" edition labels
    # don't override the actual quality tag "[Remux-1080p]"
    if re.search(r'\b2160p\b', name):
        res_score, is_4k = _SC_RES['2160p'], True
    elif re.search(r'\b1080p\b', name):
        res_score, is_4k = _SC_RES['1080p'], False
    elif re.search(r'\b720p\b', name):
        res_score, is_4k = _SC_RES['720p'], False
    elif re.search(r'\b(4k|uhd)\b', name):
        res_score, is_4k = _SC_RES['4k_uhd_fallback'], True
    else:
        res_score, is_4k = _SC_RES['sd'], False

    # Source
    src_score = 0
    if re.search(r'\bremux\b', name):                           src_score = src_table['remux']
    elif re.search(r'\b(bluray|blu-ray|bdrip|bdremux)\b', name): src_score = src_table['bluray']
    elif re.search(r'\b(web-dl|webdl)\b', name):                src_score = src_table['web_dl']
    elif re.search(r'\bwebrip\b', name):                        src_score = src_table['webrip']
    elif re.search(r'\bhdtv\b', name):                          src_score = src_table['hdtv']

    # HDR — longer tags checked first to avoid partial matches
    hdr_score = 0
    for tag, pts in (_SC['hdr_4k'] if is_4k else _SC['hdr_hd']):
        if tag in name:
            hdr_score = pts
            break

    # Audio — longest/best tags first
    audio_score = 0
    for tag, pts in _SC['audio']:
        if tag in name:
            audio_score = pts
            break

    # HEVC penalty at 1080p without HDR
    is_hevc = bool(re.search(r'\b(x265|h265|hevc|x\.265)\b', name))
    hevc_penalty = _SC['hevc_penalty_hd_no_hdr'] if (is_hevc and not is_4k and hdr_score == 0) else 0

    # Size bonus capped at configured max
    size_bonus = min(int(size_bytes / 1_073_741_824 * _SC['size_bonus_per_gb']), _SC['size_bonus_cap'])

    # Container penalty: MP4 can't hold lossless audio
    container_penalty = _SC['container_penalty_mp4'] if filename.lower().endswith('.mp4') else 0

    # TRaSH Custom Format equivalents
    hybrid = _SC_CF['hybrid']        if re.search(r'\[hybrid\]', name) else 0
    rg     = _SC_CF['release_group'] if _RG_RE.search(filename) else 0
    proper = _SC_CF['proper_repack'] if re.search(r'\b(proper|repack|rerip)\b', name) else 0

    return res_score + src_score + hdr_score + audio_score + hevc_penalty + size_bonus + container_penalty + hybrid + rg + proper


def _should_sync_tv_episode(filename: str) -> bool:
    """Returns False for files that must NOT be synced per sync rules:
    – 720p/SD content (Upgraderr handles the upgrade first)
    – x265/HEVC at 1080p without HDR/DV (blocked by Recyclarr quality profile)
    """
    name = filename.lower()
    if re.search(r'\b(480p|576p|720p|sd)\b', name):
        return False
    if re.search(r'\b(hdtv|webrip|webdl|bluray|bdrip)[-\[]?720p\b', name):
        return False
    is_hevc = bool(re.search(r'\b(x265|h265|hevc|x\.265)\b', name))
    has_hdr = bool(re.search(r'\b(hdr10\+?|hdr10|hdr|dv|dovi|dolby\.?vision|hlg|pq)\b', name))
    if is_hevc and not has_hdr:
        return False
    return True


def scan_tv_gaps():
    """
    Nightly TV gap scanner — runs at 03:00 UTC.

    Compares Synology rs-tv NFS listing (per-episode) against the Unraid Agent
    inventory. Any episode present on Synology but absent on Unraid (and passing
    the quality filter) is queued for an append-only rsync.

    Uses the Unraid Agent API for Unraid inventory — never CIFS bulk listing.
    """
    logger.info("TV gap scanner: starting nightly check...")

    synology_tv_root = '/mnt/synology/rs-tv'
    if not os.path.isdir(synology_tv_root):
        logger.error("TV gap scanner: Synology TV mount not accessible")
        return

    # Fetch Unraid TV inventory via Agent (fast local scan, no CIFS)
    try:
        resp = requests.get(
            f"{UNRAID_AGENT_URL}/inventory",
            params={'path': '/mnt/user/Media/TV Shows', 'refresh': 'true'},
            headers={'X-Api-Key': UNRAID_AGENT_API_KEY},
            timeout=180
        )
        resp.raise_for_status()
        agent_data = resp.json()
    except Exception as e:
        logger.error(f"TV gap scanner: Agent inventory failed: {e}")
        return

    # Build set of (show_folder_name, SxxExx) present on Unraid
    # path = /mnt/user/Media/TV Shows/<show>/<season>/<file>
    unraid_eps: set = set()
    ep_re = re.compile(r'S(\d{1,2})E(\d{1,4})', re.IGNORECASE)
    for item in agent_data.get('items', []):
        path = item.get('path', '')
        parts = path.split('/')
        if len(parts) < 8:
            continue
        show_folder = parts[5]  # index 5 under /mnt/user/Media/TV Shows/
        fname = parts[-1]
        m = ep_re.search(fname)
        if m:
            ep_key = f"S{int(m.group(1)):02d}E{int(m.group(2)):04d}"
            unraid_eps.add((show_folder, ep_key))

    skip_names = {'#recycle', '@eaDir', '.DS_Store', '.lnk', '.txt'}
    video_exts = ('.mkv', '.mp4', '.avi', '.ts', '.m4v')
    to_queue = []  # list of (source_file_path, show_name, ep_key)

    for show_entry in os.scandir(synology_tv_root):
        if not show_entry.is_dir() or show_entry.name in skip_names:
            continue
        show_name = show_entry.name
        for season_entry in os.scandir(show_entry.path):
            if not season_entry.is_dir() or season_entry.name in skip_names:
                continue
            for f_entry in os.scandir(season_entry.path):
                if not f_entry.is_file():
                    continue
                fname = f_entry.name
                if not fname.lower().endswith(video_exts):
                    continue
                # Quality filter removed 2026-07-25 -- Ali's explicit instruction: absolute
                # parity between Synology and Unraid regardless of quality tier. Every
                # Synology episode syncs to Unraid now, not just ones passing the old
                # 720p/x265-no-HDR gate. See CLAUDE.md Sync Strategy section.
                m = ep_re.search(fname)
                if not m:
                    continue
                ep_key = f"S{int(m.group(1)):02d}E{int(m.group(2)):04d}"
                if (show_name, ep_key) not in unraid_eps:
                    to_queue.append((f_entry.path, show_name, ep_key))

    if not to_queue:
        logger.info("TV gap scanner: all syncable TV episodes are present on Unraid")
        return

    logger.info(f"TV gap scanner: {len(to_queue)} episode(s) missing from Unraid")

    # Deduplicate: if multiple files for the same (show, ep_key) gap, pick the best
    # (highest file size as a simple proxy — TRaSH scoring needs the filename parser
    # which isn't available here; size is a safe heuristic for the same episode)
    best: dict = {}  # (show, ep_key) -> (path, size)
    for src_path, show_name, ep_key in to_queue:
        key = (show_name, ep_key)
        try:
            size = os.path.getsize(src_path)
        except OSError:
            size = 0
        if key not in best or size > best[key][1]:
            best[key] = (src_path, size)

    conn = sqlite3.connect(DB_PATH, timeout=30)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    total_queued = 0
    queued_titles = []
    tv_dest_base = '/mnt/unraid/media/TV Shows'
    # Cap how many jobs we queue per run to avoid overwhelming the system.
    # Remaining gaps will be picked up in subsequent nightly runs.
    GAP_SCAN_MAX_QUEUE = int(os.environ.get('GAP_SCAN_MAX_QUEUE', '500'))

    for (show_name, ep_key), (src_path, file_size) in sorted(best.items()):
        if total_queued >= GAP_SCAN_MAX_QUEUE:
            logger.info(f"TV gap scanner: capped at {GAP_SCAN_MAX_QUEUE} queued items — "
                        f"{len(best) - total_queued} gaps deferred to tomorrow's run")
            break
        fname = os.path.basename(src_path)
        season_dir = os.path.basename(os.path.dirname(src_path))
        dest = os.path.join(tv_dest_base, show_name, season_dir)
        display_title = f"{show_name} - {ep_key}"

        # Skip if already pending/in_progress
        cursor.execute(
            "SELECT id FROM sync_jobs WHERE source_path = ? AND status IN ('pending','in_progress')",
            (src_path,)
        )
        if cursor.fetchone():
            continue

        # NOTE: Do NOT skip based on "recently synced" — if the file is missing from Unraid
        # right now (verified by fresh Agent inventory above), we must re-queue it even if
        # it was synced recently. The nightly dedup may have deleted it after the last sync.

        conn.close()
        background_sync(
            source=src_path,
            dest=dest,
            title=display_title,
            quality='TVGapSync',
            file_size=file_size,
            media_type='Episode',
            dest_base=tv_dest_base,
        )
        conn = sqlite3.connect(DB_PATH, timeout=30)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()

        total_queued += 1
        queued_titles.append(display_title)
        logger.info(f"TV gap scanner: queued {display_title}")

    conn.close()

    if total_queued > 0:
        titles_list = "\n".join(f"• {t}" for t in queued_titles[:20])
        if len(queued_titles) > 20:
            titles_list += f"\n... and {len(queued_titles) - 20} more"
        send_notification(
            title="TV Gap Sync",
            body=f"Found {total_queued} TV episode(s) missing from Unraid — queued for sync:\n{titles_list}",
            notify_type=apprise.NotifyType.WARNING
        )
    else:
        logger.info("TV gap scanner: all identified gaps are already queued or recently synced")


VERSION_SYNC_MAX_PER_RUN = int(os.environ.get('VERSION_SYNC_MAX_PER_RUN', '20'))
VERSION_SYNC_DRY_RUN = os.environ.get('VERSION_SYNC_DRY_RUN', 'false').lower() == 'true'


def reconcile_tv_versions():
    """
    Nightly TV version reconciliation — runs at 11:15 PM ET (after TV gap scan).

    For episodes present on BOTH Synology and Unraid, checks whether the filename
    matches. If Synology's version differs (e.g. WEB-DL vs old Remux), queues a
    TVVersionSync job that: (1) rsyncs the Synology file to Unraid, (2) deletes
    the old Unraid file via Agent after successful transfer.

    Synology is always the source of truth — it is managed by Sonarr/Upgraderr.
    Uses the cached Agent inventory from the TV gap scan (30-min cache, no re-scan).
    """
    logger.info("TV version reconcile: starting check for version mismatches...")

    pause_file = os.environ.get('PAUSE_VERSION_SYNC_FILE', '/opt/mother/PAUSE_VERSION_SYNC')
    if os.path.exists(pause_file):
        logger.warning(f"TV version reconcile: PAUSE_VERSION_SYNC sentinel exists — skipping. Remove {pause_file} to re-enable.")
        return

    synology_tv_root = '/mnt/synology/rs-tv'
    if not os.path.isdir(synology_tv_root):
        logger.error("TV version reconcile: Synology TV mount not accessible")
        return

    # Fetch Unraid inventory — uses 30-min cache populated by gap scan (no refresh=true)
    try:
        resp = requests.get(
            f"{UNRAID_AGENT_URL}/inventory",
            params={'path': '/mnt/user/Media/TV Shows'},
            headers={'X-Api-Key': UNRAID_AGENT_API_KEY},
            timeout=180
        )
        resp.raise_for_status()
        agent_data = resp.json()
    except Exception as e:
        logger.error(f"TV version reconcile: Agent inventory failed: {e}")
        return

    # Build dict: (show_folder, ep_key) -> (fname, full_unraid_path)
    # When there are multiple files for the same episode (shouldn't happen after dedup),
    # keep the largest (best quality).
    ep_re = re.compile(r'S(\d{1,2})E(\d{1,4})', re.IGNORECASE)
    unraid_ep_files: dict = {}
    for item in agent_data.get('items', []):
        path = item.get('path', '')
        parts = path.split('/')
        if len(parts) < 8:
            continue
        show_folder = parts[5]
        fname = parts[-1]
        m = ep_re.search(fname)
        if not m:
            continue
        ep_key = f"S{int(m.group(1)):02d}E{int(m.group(2)):04d}"
        key = (show_folder, ep_key)
        size = item.get('size_bytes', 0)
        if key not in unraid_ep_files or size > unraid_ep_files[key][2]:
            unraid_ep_files[key] = (fname, path, size)

    skip_names = {'#recycle', '@eaDir', '.DS_Store', '.lnk', '.txt'}
    video_exts = ('.mkv', '.mp4', '.avi', '.ts', '.m4v')
    mismatches = []  # list of (syn_path, unraid_path, display_title)

    for show_entry in os.scandir(synology_tv_root):
        if not show_entry.is_dir() or show_entry.name in skip_names:
            continue
        show_name = show_entry.name
        for season_entry in os.scandir(show_entry.path):
            if not season_entry.is_dir() or season_entry.name in skip_names:
                continue
            for f_entry in os.scandir(season_entry.path):
                if not f_entry.is_file():
                    continue
                fname = f_entry.name
                if not fname.lower().endswith(video_exts):
                    continue
                # Quality filter removed 2026-07-25 -- see scan_tv_gaps' matching comment.
                # Absolute parity: Synology's file always wins on mismatch regardless of
                # tier, even if it's itself 720p/x265-no-HDR.
                m = ep_re.search(fname)
                if not m:
                    continue
                ep_key = f"S{int(m.group(1)):02d}E{int(m.group(2)):04d}"
                key = (show_name, ep_key)

                if key not in unraid_ep_files:
                    continue  # gap scanner handles missing episodes

                unraid_fname, unraid_path, unraid_size = unraid_ep_files[key]
                if fname.lower() == unraid_fname.lower():
                    continue  # same file — in sync

                try:
                    syn_size = f_entry.stat().st_size
                except OSError:
                    syn_size = 0
                syn_score = _score_filename(fname, syn_size, media_type='tv')
                unraid_score = _score_filename(unraid_fname, unraid_size, media_type='tv')
                display_title = f"{show_name} - {ep_key}"

                if syn_score > unraid_score:
                    # Synology has a better version → push to Unraid (existing direction)
                    logger.info(
                        f"TV version reconcile: mismatch {display_title} — "
                        f"Synology score {syn_score} > Unraid score {unraid_score} — "
                        f"queuing Syn→Unraid (syn={fname!r} vs unraid={unraid_fname!r})"
                    )
                    mismatches.append(('syn_to_unraid', f_entry.path, unraid_path, display_title))
                elif unraid_score > syn_score:
                    # Unraid has a better version → push to Synology (reverse direction).
                    # Gate only applies here, not to the Syn→Unraid branch above: pushing a
                    # good Synology file down to replace a bad/excluded Unraid file is always
                    # safe regardless of what disqualifies the OLD Unraid file. This check
                    # used to run before either direction was chosen, which meant it also
                    # silently skipped the Syn→Unraid direction any time Unraid's stale file
                    # happened to be 720p/x265-no-HDR (common, since that's exactly the class
                    # of legacy pre-quality-filter leftover this project has the most of) --
                    # found live 2026-07-25: 729 Syn-better mismatches were sitting completely
                    # unaddressed for this reason, while the nightly job logged "0 mismatches"
                    # for 4 straight nights because they never even reached the mismatches list.
                    if not _should_sync_tv_episode(unraid_fname):
                        continue
                    logger.info(
                        f"TV version reconcile: mismatch {display_title} — "
                        f"Unraid score {unraid_score} > Synology score {syn_score} — "
                        f"queuing Unraid→Syn (unraid={unraid_fname!r} vs syn={fname!r})"
                    )
                    # Compute Synology destination dir for reverse job
                    syn_season_dir = season_entry.path  # /mnt/synology/rs-tv/<show>/<season>/
                    # Agent returns /mnt/user/Media/... paths; rsync source must use CIFS mount
                    unraid_cifs_path = unraid_path.replace('/mnt/user/Media/', '/mnt/unraid/media/', 1)
                    mismatches.append(('unraid_to_syn', unraid_cifs_path, syn_season_dir, display_title, f_entry.path))

    if not mismatches:
        logger.info("TV version reconcile: all episodes in sync — no version mismatches")
        return

    syn_better = sum(1 for m in mismatches if m[0] == 'syn_to_unraid')
    unraid_better = sum(1 for m in mismatches if m[0] == 'unraid_to_syn')
    logger.info(f"TV version reconcile: {len(mismatches)} version mismatch(es) — "
                f"{syn_better} Syn→Unraid, {unraid_better} Unraid→Syn")

    tv_dest_base = '/mnt/unraid/media/TV Shows'
    syn_tv_base = '/mnt/synology/rs-tv'
    queued = 0
    queued_titles = []
    queued_syn_better = 0
    queued_unraid_better = 0
    deferred = 0

    for mismatch in mismatches:
        if queued >= VERSION_SYNC_MAX_PER_RUN:
            deferred = len(mismatches) - queued
            logger.info(f"TV version reconcile: capped at {VERSION_SYNC_MAX_PER_RUN} — "
                        f"{deferred} deferred to tomorrow")
            break

        direction = mismatch[0]

        if direction == 'syn_to_unraid':
            _, syn_path, unraid_path, display_title = mismatch
            source = syn_path
            if _is_already_queued(source):
                continue
            try:
                file_size = os.path.getsize(source)
            except OSError:
                file_size = 0
            season_dir = os.path.basename(os.path.dirname(syn_path))
            show_name = os.path.basename(os.path.dirname(os.path.dirname(syn_path)))
            dest = os.path.join(tv_dest_base, show_name, season_dir)
            if VERSION_SYNC_DRY_RUN:
                logger.info(f"[DRY RUN] TV reconcile Syn→Unraid: would replace {display_title}\n"
                            f"  old: {os.path.basename(unraid_path)}\n  new: {os.path.basename(syn_path)}")
                queued += 1
                queued_syn_better += 1
                queued_titles.append(f"{display_title} [Syn→Unraid]")
                continue
            background_sync(
                source=source, dest=dest, title=display_title,
                quality='TVVersionSync', file_size=file_size,
                media_type='Episode', dest_base=tv_dest_base,
                delete_after_sync=unraid_path,
            )
            logger.info(f"TV reconcile Syn→Unraid queued: {display_title} "
                        f"({os.path.basename(unraid_path)} → {os.path.basename(syn_path)})")
        else:  # unraid_to_syn
            _, unraid_path, syn_dest_dir, display_title, old_syn_path = mismatch
            source = unraid_path
            if _is_already_queued(source):
                continue
            try:
                file_size = os.path.getsize(source)
            except OSError:
                file_size = 0
            if VERSION_SYNC_DRY_RUN:
                logger.info(f"[DRY RUN] TV reconcile Unraid→Syn: would replace {display_title}\n"
                            f"  old: {os.path.basename(old_syn_path)}\n  new: {os.path.basename(unraid_path)}")
                queued += 1
                queued_unraid_better += 1
                queued_titles.append(f"{display_title} [Unraid→Syn]")
                continue
            background_sync(
                source=source, dest=syn_dest_dir, title=display_title,
                quality='TVReverseSync', file_size=file_size,
                media_type='Episode', dest_base=syn_tv_base,
                delete_after_sync=old_syn_path,
            )
            logger.info(f"TV reconcile Unraid→Syn queued: {display_title} "
                        f"({os.path.basename(old_syn_path)} → {os.path.basename(unraid_path)})")

        queued += 1
        if direction == 'syn_to_unraid':
            queued_syn_better += 1
        else:
            queued_unraid_better += 1
        label = 'Syn→Unraid' if direction == 'syn_to_unraid' else 'Unraid→Syn'
        queued_titles.append(f"{display_title} [{label}]")

    if queued > 0:
        dry = " (DRY RUN)" if VERSION_SYNC_DRY_RUN else ""
        titles_list = "\n".join(f"• {t}" for t in queued_titles[:20])
        if len(queued_titles) > 20:
            titles_list += f"\n... and {len(queued_titles) - 20} more"
        deferred_line = f"\n{deferred} more deferred to tomorrow's run." if deferred > 0 else ""
        send_notification(
            title=f"TV Version Sync{dry}",
            body=f"Found {queued} episode(s) with version mismatches — queued for replacement:\n({queued_syn_better} Syn→Unraid, {queued_unraid_better} Unraid→Syn){deferred_line}\n{titles_list}",
            notify_type=apprise.NotifyType.WARNING
        )


def reconcile_movie_versions():
    """
    Nightly movie version reconciliation — runs at 11:45 PM ET (after movie gap scan).

    Uses Radarr HD API as the canonical source of what file should exist on both sides.
    Radarr's quality profile is the authority — the file Radarr tracks IS the correct
    version for both Synology and Unraid, even if Unraid has a higher raw TRaSH score.

    Queues MovieVersionSync (Syn→Unraid) when Synology's Radarr file differs from Unraid.
    Queues MovieReverseSync (Unraid→Syn) when Radarr's file is missing from Synology but
    exists on Unraid (rare, handles NFS/filesystem drift).
    """
    logger.info("Movie version reconcile: starting check for version mismatches...")

    pause_file = os.environ.get('PAUSE_VERSION_SYNC_FILE', '/opt/mother/PAUSE_VERSION_SYNC')
    if os.path.exists(pause_file):
        logger.warning(f"Movie version reconcile: PAUSE_VERSION_SYNC sentinel exists — skipping. Remove {pause_file} to re-enable.")
        return

    # ── Step 1: Get Radarr's canonical file map ────────────────────────────────
    # Radarr knows exactly which file it imported for each movie — far more reliable
    # than guessing from the largest NFS file.
    synology_movies_nfs = '/mnt/synology/rs-movies'
    try:
        resp = requests.get(
            f"{RADARR_HD_URL}/api/v3/movie",
            params={'includeMovieFile': 'true'},
            headers={'X-Api-Key': RADARR_HD_API_KEY},
            timeout=120
        )
        resp.raise_for_status()
        radarr_movies = resp.json()
    except Exception as e:
        logger.error(f"Movie version reconcile: Radarr API failed — {e}")
        return

    # Build dict: folder_name → (expected_filename, nfs_path, size, quality_name)
    # Radarr container path /movies/<folder>/<file> → NFS /mnt/synology/rs-movies/<folder>/<file>
    radarr_file_map: dict = {}
    for m in radarr_movies:
        if not m.get('hasFile') or not m.get('movieFile'):
            continue
        mf = m['movieFile']
        container_path = mf.get('path', '')  # e.g. /movies/Movie (Year)/file.mkv
        if not container_path:
            continue
        folder = os.path.basename(os.path.dirname(container_path))
        filename = os.path.basename(container_path)
        nfs_path = os.path.join(synology_movies_nfs, folder, filename)
        quality = mf.get('quality', {}).get('quality', {}).get('name', '?')
        size = mf.get('size', 0)
        radarr_file_map[folder] = (filename, nfs_path, size, quality)

    logger.info(f"Movie version reconcile: {len(radarr_file_map):,} movies with files in Radarr")

    # ── Step 2: Get Unraid inventory ───────────────────────────────────────────
    try:
        resp = requests.get(
            f"{UNRAID_AGENT_URL}/inventory",
            params={'path': '/mnt/user/Media/Movies'},
            headers={'X-Api-Key': UNRAID_AGENT_API_KEY},
            timeout=180
        )
        resp.raise_for_status()
        agent_data = resp.json()
    except Exception as e:
        logger.error(f"Movie version reconcile: Agent inventory failed: {e}")
        return

    video_exts = ('.mkv', '.mp4', '.avi', '.m4v', '.ts', '.m2ts')
    unraid_movie_files: dict = {}   # folder → (best_fname, best_agent_path, best_size)
    unraid_folder_all: dict = {}    # folder → {fname_lower: agent_path} for specific-filename lookup
    for item in agent_data.get('items', []):
        path = item.get('path', '')
        parts = path.split('/')
        if len(parts) < 7:
            continue
        movie_folder = parts[5]
        fname = parts[-1]
        if not any(fname.lower().endswith(ext) for ext in video_exts):
            continue
        size = item.get('size_bytes', 0)
        sc = _score_filename(fname, size)
        if movie_folder not in unraid_movie_files or sc > _score_filename(unraid_movie_files[movie_folder][0], unraid_movie_files[movie_folder][2]):
            unraid_movie_files[movie_folder] = (fname, path, size)
        # Store CIFS path (rsync reads Unraid files via CIFS mount, not Agent paths)
        cifs_path = path.replace('/mnt/user/Media/', '/mnt/unraid/media/', 1)
        unraid_folder_all.setdefault(movie_folder, {})[fname.lower()] = cifs_path

    # ── Step 3: Compare Radarr's file vs Unraid, queue mismatches ────────────
    # Radarr is the authority for what file should exist on both sides.
    # We also scan the Synology folder so that if Unraid already has the best
    # available file (e.g. a better release-group copy from batch sync that
    # Radarr hasn't recognised yet), we don't overwrite it.
    #
    # Decision tree:
    #   1. radarr_fname == unraid_fname → in sync, nothing to do
    #   2. best Synology folder file == unraid_fname → Unraid already has
    #      Synology's best (Radarr just hasn't rescanned yet) → in sync
    #   3. Otherwise → sync Radarr's tracked file to Unraid and delete the old one
    #
    # NO score gate: profile mismatches (Remux when profile says Blu-ray) and
    # container changes (m2ts → mkv) must sync even though Radarr's new file
    # scores lower. Radarr chose the file; both sides must mirror that choice.
    synology_movies_nfs = '/mnt/synology/rs-movies'
    mismatches = []  # (syn_file_path, unraid_file_path, movie_folder, quality)

    for movie_folder, (radarr_fname, nfs_path, radarr_size, quality) in radarr_file_map.items():
        if movie_folder not in unraid_movie_files:
            continue  # gap scanner handles missing folders

        unraid_fname, unraid_path, unraid_size = unraid_movie_files[movie_folder]

        # Fast path: Radarr's tracked file == Unraid's file → in sync
        if radarr_fname.lower() == unraid_fname.lower():
            continue

        # Scan Synology folder for all video files (best-quality first)
        folder_path = os.path.join(synology_movies_nfs, movie_folder)
        syn_files = []
        try:
            for entry in os.scandir(folder_path):
                if entry.is_file() and entry.name.lower().endswith(video_exts):
                    try:
                        sz = entry.stat().st_size
                    except OSError:
                        sz = 0
                    syn_files.append((entry.name, entry.path, sz))
        except OSError:
            pass

        if syn_files:
            syn_files.sort(key=lambda x: _score_filename(x[0], x[2]), reverse=True)
            best_syn_fname, best_syn_path = syn_files[0][0], syn_files[0][1]
        else:
            best_syn_fname, best_syn_path = radarr_fname, nfs_path

        # If Unraid already has Synology's best file (even if Radarr hasn't rescanned yet) → in sync
        if best_syn_fname.lower() == unraid_fname.lower():
            continue

        # Quality gate removed 2026-07-25 -- Ali's explicit instruction: absolute parity
        # between Synology and Unraid regardless of quality tier, movies and TV alike.
        # Radarr's tracked file now always syncs to Unraid even if it's itself
        # 720p/SD or x265-without-HDR. See CLAUDE.md Sync Strategy section.

        # ── Direction: PROFILE AUTHORITY — Radarr's tracked file always wins ────────
        # See CLAUDE.md "Profile Authority" section. Reverted 2026-07-02: commit
        # ae46ea1 (2026-06-27) replaced this with "highest TRaSH score wins,
        # regardless of tier" — reasoning it was protecting Unraid's "better" Remux
        # from being overwritten by Synology's Bluray. That's backwards: if Radarr's
        # profile doesn't want Remux, Unraid's Remux is the anomaly, not the target.
        # That commit queued 250+ Unraid→Synology reverse syncs that restored old
        # Remuxes over Upgraderr's legitimate profile-compliant upgrades (391
        # succeeded total before this revert) — including deleting the exact files
        # Upgraderr had just correctly grabbed for Varsity Blues and Mazinger Z,
        # which is what re-triggered Tier 7 and caused those incidents to repeat.
        # No score comparison here — Synology (Radarr) is simply always the target.
        # The only legitimate reverse-sync case is below: Radarr's tracked file is
        # genuinely missing from Synology's filesystem (real drift, not a quality
        # difference).

        if not os.path.isfile(nfs_path):
            # Radarr's file is missing from Synology NFS — look up exact filename in Agent
            # inventory (already fetched above) instead of os.path.isfile() over CIFS.
            folder_files = unraid_folder_all.get(movie_folder, {})
            unraid_agent_path = folder_files.get(radarr_fname.lower())
            if unraid_agent_path:
                syn_folder = os.path.join(synology_movies_nfs, movie_folder)
                syn_old_file = best_syn_path if syn_files else None
                logger.info(
                    f"Movie version reconcile: Radarr's file on Unraid but missing from Synology — "
                    f"queuing Unraid→Syn for '{movie_folder}' ({radarr_fname!r})"
                )
                mismatches.append(('unraid_to_syn', unraid_agent_path, syn_folder, movie_folder, quality, syn_old_file))
            else:
                logger.warning(f"Movie version reconcile: Radarr's file missing from NFS and not found on Unraid — "
                               f"skipping '{movie_folder}' ({radarr_fname!r})")
            continue

        # If Unraid already has Radarr's tracked file (alongside a duplicate), skip —
        # dedup will clean the extra file. No need to rsync a file that's already there.
        if radarr_fname.lower() in unraid_folder_all.get(movie_folder, {}):
            logger.info(
                f"Movie version reconcile: skipping '{movie_folder}' — "
                f"Unraid already has Radarr's file {radarr_fname!r} (plus duplicate {unraid_fname!r}, dedup will clean)"
            )
            continue

        mismatches.append(('syn_to_unraid', nfs_path, unraid_path, movie_folder, quality))
        logger.info(
            f"Movie version reconcile: mismatch '{movie_folder}' — queuing Syn→Unraid "
            f"({radarr_fname!r} → replaces {unraid_fname!r})"
        )

    if not mismatches:
        logger.info("Movie version reconcile: all movies in sync — no version mismatches")
        return

    syn_better = sum(1 for m in mismatches if m[0] == 'syn_to_unraid')
    unraid_better = sum(1 for m in mismatches if m[0] == 'unraid_to_syn')
    logger.info(f"Movie version reconcile: {len(mismatches)} version mismatch(es) — "
                f"{syn_better} Syn→Unraid, {unraid_better} Unraid→Syn")

    movies_dest_base = '/mnt/unraid/media/Movies'
    syn_movies_base = '/mnt/synology/rs-movies'
    queued = 0
    queued_titles = []
    queued_syn_better = 0
    queued_unraid_better = 0
    deferred = 0

    for mismatch in mismatches:
        if queued >= VERSION_SYNC_MAX_PER_RUN:
            deferred = len(mismatches) - queued
            logger.info(f"Movie version reconcile: capped at {VERSION_SYNC_MAX_PER_RUN} — "
                        f"{deferred} deferred to tomorrow")
            break

        direction = mismatch[0]

        if direction == 'syn_to_unraid':
            _, syn_path, unraid_path, movie_folder, radarr_quality = mismatch
            source = syn_path
            if _is_already_queued(source):
                continue
            try:
                file_size = os.path.getsize(source)
            except OSError:
                file_size = 0
            dest = os.path.join(movies_dest_base, movie_folder)
            if VERSION_SYNC_DRY_RUN:
                logger.info(f"[DRY RUN] Movie reconcile Syn→Unraid: would replace {movie_folder}\n"
                            f"  old: {os.path.basename(unraid_path)}\n"
                            f"  new: {os.path.basename(syn_path)}  [{radarr_quality}]")
                queued += 1
                queued_syn_better += 1
                queued_titles.append(f"{movie_folder} [{radarr_quality}] [Syn→Unraid]")
                continue
            background_sync(
                source=source, dest=dest, title=movie_folder,
                quality='MovieVersionSync', file_size=file_size,
                media_type='Movie', dest_base=movies_dest_base,
                delete_after_sync=unraid_path,
            )
            logger.info(f"Movie reconcile Syn→Unraid queued: {movie_folder} "
                        f"[{radarr_quality}] ({os.path.basename(unraid_path)} → {os.path.basename(syn_path)})")
        else:  # unraid_to_syn
            _, unraid_path, syn_folder, movie_folder, radarr_quality, old_syn_file = mismatch
            source = unraid_path
            if _is_already_queued(source):
                continue
            try:
                file_size = os.path.getsize(source)
            except OSError:
                file_size = 0
            if VERSION_SYNC_DRY_RUN:
                old_name = os.path.basename(old_syn_file) if old_syn_file else '(none)'
                logger.info(f"[DRY RUN] Movie reconcile Unraid→Syn: would replace {movie_folder}\n"
                            f"  old: {old_name}\n  new: {os.path.basename(unraid_path)}  [{radarr_quality}]")
                queued += 1
                queued_unraid_better += 1
                queued_titles.append(f"{movie_folder} [{radarr_quality}] [Unraid→Syn]")
                continue
            background_sync(
                source=source, dest=syn_folder, title=movie_folder,
                quality='MovieReverseSync', file_size=file_size,
                media_type='Movie', dest_base=syn_movies_base,
                delete_after_sync=old_syn_file,
            )
            logger.info(f"Movie reconcile Unraid→Syn queued: {movie_folder} "
                        f"[{radarr_quality}] ({os.path.basename(unraid_path)} → Synology)")

        queued += 1
        label = 'Syn→Unraid' if direction == 'syn_to_unraid' else 'Unraid→Syn'
        if direction == 'syn_to_unraid':
            queued_syn_better += 1
        else:
            queued_unraid_better += 1
        queued_titles.append(f"{movie_folder} [{radarr_quality}] [{label}]")

    if queued > 0:
        dry = " (DRY RUN)" if VERSION_SYNC_DRY_RUN else ""
        titles_list = "\n".join(f"• {t}" for t in queued_titles[:20])
        if len(queued_titles) > 20:
            titles_list += f"\n... and {len(queued_titles) - 20} more"
        deferred_line = f"\n{deferred} more deferred to tomorrow's run." if deferred > 0 else ""
        send_notification(
            title=f"Movie Version Sync{dry}",
            body=f"Found {queued} movie(s) with version mismatches — queued for replacement:\n({queued_syn_better} Syn→Unraid, {queued_unraid_better} Unraid→Syn){deferred_line}\n{titles_list}",
            notify_type=apprise.NotifyType.WARNING
        )


def nightly_library_report():
    """
    Nightly library health report — runs at 04:15 UTC (after both gap scans).

    Sends a single Telegram summary covering:
    - HD movies: Synology count vs Unraid count, list of any still-missing titles
    - HD TV: shows + episode counts on each side, missing episodes grouped by show

    Informational only — no queuing, no deletions.
    """
    logger.info("Library report: generating nightly summary...")

    from collections import defaultdict

    lines = ["*Nightly Library Report*\n"]
    missing_movies: list = []
    missing_by_show: dict = {}
    total_missing_eps: int = 0
    ep_re = re.compile(r'S(\d{1,2})E(\d{1,4})', re.IGNORECASE)
    skip_names = {'#recycle', '@eaDir', '.DS_Store', 'testfile'}
    skip_suffixes = ('.lnk', '.txt', '.url')
    video_exts = ('.mkv', '.mp4', '.avi', '.ts', '.m4v')

    # ── Movies ───────────────────────────────────────────────────────────────
    try:
        src_base = '/mnt/synology/rs-movies'
        syn_folders = set()
        if os.path.isdir(src_base):
            for f in os.listdir(src_base):
                if f in skip_names or any(f.endswith(s) for s in skip_suffixes):
                    continue
                folder_path = os.path.join(src_base, f)
                if os.path.isdir(folder_path) and not any(True for _ in Path(folder_path).iterdir()):
                    continue  # skip empty folders — nothing to sync
                syn_folders.add(f)

        unraid_folders = _get_unraid_movie_folders()

        missing_movies = sorted(
            f for f in (syn_folders - unraid_folders)
            if f not in skip_names and not any(f.endswith(s) for s in skip_suffixes)
        )

        lines.append(f"🎬 *HD Movies*")
        lines.append(f"Synology: {len(syn_folders):,}  |  Unraid: {len(unraid_folders):,}")
        if not missing_movies:
            lines.append("✅ All movies present on Unraid")
        else:
            lines.append(f"⚠️ {len(missing_movies)} missing from Unraid:")
            for title in missing_movies[:15]:
                lines.append(f"  • {title}")
            if len(missing_movies) > 15:
                lines.append(f"  … and {len(missing_movies) - 15} more")
    except Exception as e:
        logger.error(f"Library report: movie section failed: {e}")
        lines.append("🎬 *HD Movies* — ❌ error fetching data")

    lines.append("")

    # ── TV ───────────────────────────────────────────────────────────────────
    try:
        synology_tv_root = '/mnt/synology/rs-tv'

        # Fetch Unraid TV inventory (Agent cache may still be warm from 03:00 scan)
        resp = requests.get(
            f"{UNRAID_AGENT_URL}/inventory",
            params={'path': '/mnt/user/Media/TV Shows'},
            headers={'X-Api-Key': UNRAID_AGENT_API_KEY},
            timeout=180
        )
        resp.raise_for_status()
        agent_data = resp.json()

        unraid_eps: set = set()
        unraid_shows: set = set()
        for item in agent_data.get('items', []):
            path = item.get('path', '')
            parts = path.split('/')
            if len(parts) < 6:
                continue
            show_folder = parts[5]
            unraid_shows.add(show_folder)
            fname = parts[-1]
            m = ep_re.search(fname)
            if m:
                ep_key = f"S{int(m.group(1)):02d}E{int(m.group(2)):04d}"
                unraid_eps.add((show_folder, ep_key))

        # Scan Synology TV — build (show, ep_key) set and per-show counts
        syn_shows: set = set()
        missing_by_show: dict = defaultdict(list)
        syn_ep_total = 0

        if os.path.isdir(synology_tv_root):
            for show_entry in os.scandir(synology_tv_root):
                if not show_entry.is_dir() or show_entry.name in skip_names:
                    continue
                show_name = show_entry.name
                syn_shows.add(show_name)
                for season_entry in os.scandir(show_entry.path):
                    if not season_entry.is_dir() or season_entry.name in skip_names:
                        continue
                    for f_entry in os.scandir(season_entry.path):
                        if not f_entry.is_file():
                            continue
                        fname = f_entry.name
                        if not fname.lower().endswith(video_exts):
                            continue
                        # Quality filter removed 2026-07-25 to match the gap scanner/reconcile
                        # policy change -- this health report's "missing" count should reflect
                        # the same absolute-parity definition those jobs now sync against.
                        m = ep_re.search(fname)
                        if not m:
                            continue
                        syn_ep_total += 1
                        ep_key = f"S{int(m.group(1)):02d}E{int(m.group(2)):04d}"
                        if (show_name, ep_key) not in unraid_eps:
                            missing_by_show[show_name].append(ep_key)

        total_missing_eps = sum(len(v) for v in missing_by_show.values())

        lines.append(f"📺 *HD TV Shows*")
        lines.append(f"Synology: {len(syn_shows):,} shows, {syn_ep_total:,} syncable eps")
        lines.append(f"Unraid: {len(unraid_shows):,} shows, {len(unraid_eps):,} eps")

        if not missing_by_show:
            lines.append("✅ All syncable episodes present on Unraid")
        else:
            lines.append(f"⚠️ {total_missing_eps} episode(s) missing across {len(missing_by_show)} show(s):")
            # Sort by most missing first, show top 12
            sorted_shows = sorted(missing_by_show.items(), key=lambda x: -len(x[1]))
            for show, eps in sorted_shows[:12]:
                # Strip TVDB suffix for readability: "Show Name (Year) {tvdb-12345}" → "Show Name (Year)"
                display = show.split(' {')[0]
                lines.append(f"  • {display}: {len(eps)} ep(s)")
            if len(sorted_shows) > 12:
                lines.append(f"  … and {len(sorted_shows) - 12} more shows")

    except Exception as e:
        logger.error(f"Library report: TV section failed: {e}")
        lines.append("📺 *HD TV* — ❌ error fetching data")

    body = "\n".join(lines)
    has_gaps = bool(missing_movies) or bool(missing_by_show)
    notify_type = apprise.NotifyType.WARNING if has_gaps else apprise.NotifyType.SUCCESS

    send_notification(title="Library Health", body=body, notify_type=notify_type)
    logger.info(f"Library report: sent — {len(missing_movies)} missing movies, {total_missing_eps} missing TV eps")


def _dedup_norm_title(title: str) -> str:
    t = re.sub(r'\s*\(\d{4}\)\s*$', '', title)
    t = t.lower().replace('&', ' and ')
    return re.sub(r'[^a-z0-9]+', '', t)


def _dedup_fetch_tier7_pending(instance: str) -> set:
    """Normalized movie titles Upgraderr currently has an active tier7_profile_mismatch
    entry for, per instance — read from a plain JSON export Upgraderr writes after
    each sweep (/opt/mother/data/upgraderr/tier7_pending.json), NOT a live SQLite read
    against upgraderr.db: a read-only bind mount can't create the -shm file WAL mode
    needs, so direct cross-container SQLite reads intermittently failed with "unable
    to open database file." This mirrors the trash_scoring.json pattern already used
    for read-only cross-service config sharing in this codebase.

    Raises on failure rather than returning set() — this is the automated,
    unattended dedup path (see nightly_unraid_dedup's fail-closed handling below);
    an empty set must mean "genuinely nothing pending," never "the file was
    unreadable.\""""
    path = os.environ.get('TIER7_PENDING_PATH', '/data/upgraderr_ro/tier7_pending.json')
    with open(path) as f:
        data = json.load(f)
    return {_dedup_norm_title(t) for t in data.get(instance, []) if t}


def _dedup_fetch_radarr_tracked(url: str, api_key: str) -> dict:
    """normalized movie title -> Radarr's currently tracked filename (lowercase).

    Raises on fetch failure (not api_key missing/unconfigured, which legitimately
    returns {}) rather than swallowing it — an empty dict must mean "Radarr tracks
    nothing," never "the fetch failed," or the caller's fail-closed abort
    (nightly_unraid_dedup) never actually triggers."""
    if not api_key:
        return {}
    r = requests.get(f"{url}/api/v3/movie", headers={'X-Api-Key': api_key}, timeout=60)
    r.raise_for_status()
    movies = r.json()
    out = {}
    for m in movies:
        mf = m.get('movieFile')
        if mf and mf.get('relativePath'):
            out[_dedup_norm_title(m['title'])] = os.path.basename(mf['relativePath']).lower()
    return out


def _dedup_fetch_sonarr_tracked(url: str, api_key: str) -> dict:
    """(tvdbId, 'S####E####') -> Sonarr's currently tracked episode filename (lowercase).

    Raises on fetch failure (not api_key missing/unconfigured, which legitimately
    returns {}) rather than swallowing it — see _dedup_fetch_radarr_tracked. Per-
    series episode-list failures inside the loop below are tolerated (skip that one
    series) since that's genuine partial data, not a full fetch failure."""
    if not api_key:
        return {}
    r = requests.get(f"{url}/api/v3/series", headers={'X-Api-Key': api_key}, timeout=60)
    r.raise_for_status()
    series_list = r.json()
    out = {}
    for s in series_list:
        tvdb_id = s.get('tvdbId')
        if not tvdb_id:
            continue
        try:
            r = requests.get(f"{url}/api/v3/episode",
                              params={'seriesId': s['id'], 'includeEpisodeFile': 'true'},
                              headers={'X-Api-Key': api_key}, timeout=60)
            r.raise_for_status()
            episodes = r.json()
        except Exception:
            continue
        for ep in episodes:
            ef = ep.get('episodeFile')
            if not ef or not ef.get('relativePath'):
                continue
            key = (tvdb_id, f"S{ep.get('seasonNumber', 0):04d}E{ep.get('episodeNumber', 0):04d}")
            out[key] = os.path.basename(ef['relativePath']).lower()
    return out


_DEDUP_PART_RE = re.compile(r'\bpart\s*\d+\b', re.IGNORECASE)


def _dedup_is_multipart_group(group: dict) -> bool:
    """Mirrors Curatorr's _is_multipart_group() (services/curatorr/app/scheduler.py) —
    kept as a separate copy for the same reason as _dedup_is_known_bad_release below.
    Found live 2026-07-19 the hard way: this check existed in Curatorr's Synology dedup
    but NOT here, so a real 50-item Unraid dedup run destroyed 4 of 5 parts of a
    user-made multi-part fan edit ("Marvel's Infinity Saga - The Sacred Timeline Cut"),
    treating PART 2-5 as duplicates of PART 1. Recovered from Synology (the original
    source, still intact) the same session. Applies to every duplicate group processed
    by this function, not just that one title — this was a real, general gap."""
    versions = group.get('versions', [])
    part_count = sum(
        1 for v in versions
        if _DEDUP_PART_RE.search(os.path.basename(v.get('file_path', '') or ''))
    )
    return part_count >= 2


_DEDUP_ALWAYS_PROTECTED_TITLES = ('sacred timeline cut', 'infinity saga')


def _dedup_is_always_protected_title(title: str) -> bool:
    """Belt-and-suspenders guard for known fan-edit/multi-part titles by name,
    independent of _dedup_is_multipart_group's PART-number regex — added 2026-07-22
    alongside a bug that caught the same "Sacred Timeline Cut" title being silently
    unprotected in Curatorr's manual duplicate-scanner route (duplicates.py had no
    multipart guard at all, unlike this file and scheduler.py). If a future rename
    ever breaks the PART-number pattern match, this name-based check still holds."""
    t = (title or '').lower()
    return any(name in t for name in _DEDUP_ALWAYS_PROTECTED_TITLES)


_DEDUP_BAD_RELEASE_GROUPS = {'bhdstudio'}
_DEDUP_BAD_CONTAINERS = ('.avi', '.mp4', '.ts', '.wmv', '.m4v', '.divx', '.xvid')


def _dedup_is_known_bad_release(filename: str) -> bool:
    """Mirrors Upgraderr's _is_known_bad_release() + Tier 2 container check
    (services/upgraderr/app.py) — kept as a separate small copy here since dedup
    lives in a different service, not because the criteria should ever diverge.
    See CLAUDE.md's Known-Bad Releases table."""
    fn = (filename or '').lower()
    if fn.endswith(_DEDUP_BAD_CONTAINERS):
        return True
    m = re.search(r'-([a-z0-9]+)(?:\.[a-z0-9]{2,4})?$', fn)
    group = m.group(1) if m else ''
    return group in _DEDUP_BAD_RELEASE_GROUPS


def _dedup_enforce_profile_authority(groups: list, tracked_by_title: dict = None,
                                      tracked_by_episode: dict = None, media_type: str = 'movie',
                                      tier7_pending: set = None) -> None:
    """Re-rank each duplicate group in place so the file Radarr/Sonarr is currently
    tracking is always first (kept), regardless of raw TRaSH score — see CLAUDE.md
    Profile Authority. Without this, the automatic nightly dedup could delete the
    actively-tracked, profile-compliant file and keep a higher-scoring orphan (e.g. a
    leftover Remux from before a profile was assigned) — confirmed live 2026-07-02:
    32 of 305 Unraid HD movie duplicate groups had exactly this mismatch before this
    fix (found via the equivalent fix in curatorr/routes/duplicates.py — mirrored
    here since this dedup job calls the Unraid Agent directly, not through Curatorr).

    tier7_pending (movies only): normalized titles Upgraderr currently has an active
    tier7_profile_mismatch entry for — Radarr's tracked file (the one kept here)
    itself violates its assigned profile and a search for a replacement is already
    underway. Deleting the "duplicate" alternates in that window means Radarr will
    likely re-download essentially the same thing shortly after — pure waste. Marks
    non-kept versions un-deletable until Tier 7 resolves (see
    scripts/resolve_tier7_remux_duplicates.py).

    Known-bad-release guard — added 2026-07-19 after a live dry-run caught this
    exact gap: Profile Authority governs resolution/source TIER, not release
    *quality control* (see CLAUDE.md — these are explicitly orthogonal). Without
    this check, a movie whose tracked file is a known-bad release (BHDStudio group,
    or a non-MKV container like the observed BHDStudio .mp4 case) would have its
    only clean alternative deleted to preserve the bad file — confirmed live for
    Mortal Kombat II (2026), The Devil Wears Prada 2 (2026), and The Man from Earth
    (2007), all BHDStudio .mp4. If the kept/tracked file matches this check, every
    other version in the group is marked un-deletable instead of ranked — Radarr's
    own custom formats / Upgraderr's Tier 2+BAD_RELEASE_GROUPS are what should
    eventually replace the bad file, not this dedup job destroying the fallback.
    """
    for grp in groups:
        versions = grp.get('versions') or []
        if len(versions) < 2:
            continue

        tracked_fname = None
        if media_type == 'movie' and tracked_by_title is not None:
            tracked_fname = tracked_by_title.get(_dedup_norm_title(grp['title']))
        elif media_type == 'tv' and tracked_by_episode is not None:
            m = re.search(r'\{tvdb-(\d+)\}', grp.get('title', ''))
            if m:
                tracked_fname = tracked_by_episode.get((int(m.group(1)), grp.get('episode', '')))
        if not tracked_fname:
            continue

        tracked_idx = next(
            (i for i, v in enumerate(versions) if v['filename'].lower() == tracked_fname), None
        )
        if tracked_idx is None:
            continue

        if tracked_idx != 0:
            tracked_version = versions.pop(tracked_idx)
            tracked_version['kept_reason'] = 'profile_authority'
            versions.insert(0, tracked_version)
            grp['versions'] = versions

        if _dedup_is_known_bad_release(versions[0].get('filename', '')):
            for v in versions[1:]:
                v['safe_to_delete'] = False
                v['known_bad_tracked_file'] = True
            logger.warning(
                f"Dedup: '{grp.get('title', '')}' tracked file is a known-bad release "
                f"({versions[0].get('filename', '')}) — protecting {len(versions)-1} "
                f"alternate(s) from deletion instead of deleting them to preserve it."
            )

        if (media_type == 'movie' and tier7_pending
                and _dedup_norm_title(grp['title']) in tier7_pending):
            for v in versions[1:]:
                v['safe_to_delete'] = False
                v['pending_tier7'] = True


def _write_dedup_status(outcome, reason='', deleted=0, freed=0):
    """Persist the outcome of the most recent dedup attempt so daily_report.py can show
    real status instead of just checking the PAUSE_DEDUP sentinel. Found 2026-07-19:
    the Telegram report said "Enabled" every day for 11+ days while dedup silently
    deferred daily — this makes that visible instead of invisible."""
    try:
        with open(DEDUP_STATUS_FILE, 'w') as f:
            json.dump({
                'timestamp': datetime.utcnow().isoformat(),
                'outcome': outcome,   # 'ran' | 'deferred' | 'paused' | 'blocked' | 'error'
                'reason': reason,
                'deleted': deleted,
                'freed_bytes': freed,
            }, f)
    except Exception as e:
        logger.warning(f"Unraid dedup: could not write status file: {e}")


def nightly_unraid_dedup(force=False):
    """
    Nightly Unraid duplicate cleanup.

    Safety checks (in order):
    1. PAUSE_DEDUP sentinel file — operator-controlled pause (e.g. during active batch sync)
    2. In-progress sync jobs — skip if active gap-sync jobs are running (those jobs may create
       the "duplicates" we'd otherwise delete before they finish)
    3. DEDUP_SAFETY_LIMIT — abort if too many duplicates found (scoring bug / stale cache)
    4. DEDUP_MAX_PER_RUN — cap deletions per run to rate-limit in recovery scenarios
    5. DEDUP_DRY_RUN — log would-be deletions without executing them

    Env vars:
      PAUSE_DEDUP_FILE  path to sentinel (default /opt/mother/PAUSE_DEDUP)
      DEDUP_SAFETY_LIMIT  abort threshold (default 200)
      DEDUP_SAFETY_LIMIT_WEEKLY  abort threshold used instead of DEDUP_SAFETY_LIMIT when
                          force=True (default 500) — added 2026-07-22, see force below
      DEDUP_MAX_PER_RUN   max deletions per run (default 50)
      DEDUP_DRY_RUN       'true' to preview without deleting (default false)
      DEDUP_MIN_AGE_HOURS block dedup if a *forward* gap/version-sync job (writes to Unraid)
                          completed in the last N hours (default 24); dedup is already
                          separated from gap scan by scheduling (03:00 scan → 12:00 dedup), so
                          this adds a second layer of protection. TVReverseSync/MovieReverseSync
                          (Unraid -> Synology) are excluded from this lookback since they never
                          leave a new file on Unraid — see check 2b below.

    force: when True, skips the DEDUP_MIN_AGE_HOURS "recent gap job" defer (check 2b below)
      and uses DEDUP_SAFETY_LIMIT_WEEKLY instead of DEDUP_SAFETY_LIMIT (check 4) — but still
      honors PAUSE_DEDUP and the in-progress-job check (2a) — used by the weekly
      guaranteed-drain job so a sustained restore project (which completes a gap-sync job
      almost every day, and can grow the backlog past the daily limit over several days)
      can't starve dedup indefinitely the way it did 2026-07-09 to 07-19, and again
      2026-07-19 to 07-22 via a different false-trigger (see check 2b's docstring).
    """
    # ── 1. PAUSE_DEDUP sentinel ────────────────────────────────────────────────
    pause_file = os.environ.get('PAUSE_DEDUP_FILE', '/opt/mother/PAUSE_DEDUP')
    if os.path.exists(pause_file):
        msg = f"PAUSE_DEDUP sentinel exists ({pause_file}) — skipping dedup. Remove the file to re-enable."
        logger.warning(f"Unraid dedup: {msg}")
        send_dedup_notification(title="Unraid Dedup PAUSED", body=msg,
                          notify_type=apprise.NotifyType.WARNING)
        _write_dedup_status('paused', msg)
        return

    # ── 2. Skip if gap-sync jobs are running OR recently completed ───────────
    # Gap sync jobs create new files on Unraid. Dedup must not run while the
    # queue is draining. Two conditions both trigger a skip:
    #   a) Any gap job currently in_progress OR pending (not yet dispatched)
    #   b) Any gap job completed within DEDUP_MIN_AGE_HOURS (default 24h)
    DEDUP_MIN_AGE_HOURS = int(os.environ.get('DEDUP_MIN_AGE_HOURS', '24'))
    try:
        conn = sqlite3.connect(DB_PATH, timeout=30)
        cursor = conn.cursor()
        # Issue 3 fix: include 'pending' — jobs waiting for semaphore count as active
        # Also include version sync jobs (both directions) — they write new files whose
        # old counterparts dedup must not delete before the replacement lands.
        cursor.execute(
            "SELECT COUNT(*) FROM sync_jobs WHERE status IN ('in_progress','pending') "
            "AND quality IN ('TVGapSync','GapSync','TVVersionSync','MovieVersionSync',"
            "'TVReverseSync','MovieReverseSync')"
        )
        active_gap_jobs = cursor.fetchone()[0]
        # Use UTC-aware comparison (completed_at now stored as UTC via datetime.utcnow)
        # Deliberately excludes TVReverseSync/MovieReverseSync here (unlike the
        # active-job check above): reverse syncs copy Unraid -> Synology, so a
        # *completed* one never leaves a new/changed file on Unraid for dedup to
        # race against. Including them caused a false-positive defer every single
        # day 2026-07-19 to 07-22 while the known-bad-release restore project was
        # running (it completes a ReverseSync most nights), silently growing the
        # real duplicate backlog past DEDUP_SAFETY_LIMIT with zero dedup runs.
        cursor.execute(
            "SELECT COUNT(*) FROM sync_jobs WHERE quality IN ('TVGapSync','GapSync',"
            "'TVVersionSync','MovieVersionSync') "
            "AND status = 'success' "
            "AND completed_at > strftime('%Y-%m-%dT%H:%M:%S', 'now', ?)",
            (f'-{DEDUP_MIN_AGE_HOURS} hours',)
        )
        recent_gap_jobs = cursor.fetchone()[0]
        conn.close()
    except Exception as e:
        logger.warning(f"Unraid dedup: could not check gap job status: {e}")
        active_gap_jobs = 0
        recent_gap_jobs = 0

    if active_gap_jobs > 0:
        msg = (f"Skipping dedup: {active_gap_jobs} gap-sync job(s) currently in progress/pending. "
               f"Dedup will run tomorrow once the queue drains.")
        logger.warning(f"Unraid dedup: {msg}")
        send_dedup_notification(title="Unraid Dedup DEFERRED", body=msg,
                          notify_type=apprise.NotifyType.WARNING)
        _write_dedup_status('deferred', msg)
        return

    if recent_gap_jobs > 0 and not force:
        msg = (f"Skipping dedup: {recent_gap_jobs} gap-sync job(s) completed in the last "
               f"{DEDUP_MIN_AGE_HOURS}h — waiting for rsync queue to fully settle.")
        logger.warning(f"Unraid dedup: {msg}")
        send_dedup_notification(title="Unraid Dedup DEFERRED", body=msg,
                          notify_type=apprise.NotifyType.WARNING)
        _write_dedup_status('deferred', msg)
        return
    elif recent_gap_jobs > 0 and force:
        logger.info(f"Unraid dedup: {recent_gap_jobs} recent gap-sync job(s) present, but "
                     f"force=True (weekly guaranteed-drain run) — proceeding anyway.")

    DRY_RUN = os.environ.get('DEDUP_DRY_RUN', 'false').lower() == 'true'
    # R3: Pre-dedup notification with pause window.
    # Send a "dedup starting in 10 min" alert so operator can create PAUSE_DEDUP
    # if needed. Pause file is re-checked after the wait.
    DEDUP_WARN_MINUTES = int(os.environ.get('DEDUP_WARN_MINUTES', '10'))
    if not DRY_RUN and DEDUP_WARN_MINUTES > 0:
        send_dedup_notification(
            title="Unraid Dedup Starting",
            body=f"Duplicate cleanup begins in {DEDUP_WARN_MINUTES} minute(s). "
                 f"Create /opt/mother/PAUSE_DEDUP to abort.",
            notify_type=apprise.NotifyType.INFO
        )
        import time as _time
        _time.sleep(DEDUP_WARN_MINUTES * 60)
        # Re-check sentinel after wait window
        if os.path.exists(pause_file):
            logger.warning("Unraid dedup: PAUSE_DEDUP created during warn window — aborting.")
            return
        logger.info("Unraid dedup: warn window passed, starting duplicate cleanup...")
    elif DRY_RUN:
        logger.info("Unraid dedup: DRY RUN mode — will log but not delete")

    # ── 3. Fetch scan data ─────────────────────────────────────────────────────
    try:
        resp = requests.get(
            f"{UNRAID_AGENT_URL}/scan",
            params={'refresh': 'true'},
            headers={'X-Api-Key': UNRAID_AGENT_API_KEY},
            timeout=300
        )
        resp.raise_for_status()
        scan_data = resp.json()
    except Exception as e:
        logger.error(f"Unraid dedup: Agent scan failed: {e}")
        _write_dedup_status('error', f"Agent scan failed: {e}")
        return

    # ── Profile Authority correction ──────────────────────────────────────────
    # The Unraid Agent's scan is pure filesystem + raw TRaSH score — it doesn't know
    # what Radarr/Sonarr currently track. Re-rank every group so the actively-tracked
    # file always wins before deciding what's deletable. See CLAUDE.md Profile
    # Authority and _dedup_enforce_profile_authority()'s docstring.
    try:
        radarr_hd_tracked = _dedup_fetch_radarr_tracked(RADARR_HD_URL, RADARR_HD_API_KEY)
        radarr_4k_tracked = _dedup_fetch_radarr_tracked(RADARR_4K_URL, RADARR_4K_API_KEY)
        sonarr_hd_tracked = _dedup_fetch_sonarr_tracked(SONARR_HD_URL, SONARR_HD_API_KEY)
        sonarr_4k_tracked = _dedup_fetch_sonarr_tracked(SONARR_4K_URL, SONARR_4K_API_KEY)
        # tier7_pending: same fail-closed treatment as the tracked-file fetches above —
        # this is the unattended automated path, so if we can't confirm what Upgraderr
        # currently has an active profile-mismatch search out for, we must not assume
        # nothing does. See _dedup_enforce_profile_authority()'s tier7_pending docstring.
        radarr_hd_tier7 = _dedup_fetch_tier7_pending('radarr-hd')
        radarr_4k_tier7 = _dedup_fetch_tier7_pending('radarr-4k')
        unraid_groups = scan_data.get('unraid', {})
        _dedup_enforce_profile_authority(unraid_groups.get('hd_movies', []), tracked_by_title=radarr_hd_tracked, media_type='movie', tier7_pending=radarr_hd_tier7)
        _dedup_enforce_profile_authority(unraid_groups.get('4k_movies', []), tracked_by_title=radarr_4k_tracked, media_type='movie', tier7_pending=radarr_4k_tier7)
        _dedup_enforce_profile_authority(unraid_groups.get('hd_tv', []), tracked_by_episode=sonarr_hd_tracked, media_type='tv')
        _dedup_enforce_profile_authority(unraid_groups.get('4k_tv', []), tracked_by_episode=sonarr_4k_tracked, media_type='tv')
    except Exception as e:
        logger.error(f"Unraid dedup: Profile Authority correction failed — aborting run rather than risk deleting an actively-tracked file: {e}")
        send_dedup_notification(title="Unraid Dedup ABORTED", body=f"Profile Authority correction failed: {e}", notify_type=apprise.NotifyType.FAILURE)
        _write_dedup_status('error', f"Profile Authority correction failed: {e}")
        return

    total_deleted = 0
    total_freed = 0
    errors = []
    top_freed: list = []  # (bytes, path) for Telegram sample

    # ── 4. Safety limit: abort if too many duplicates ─────────────────────────
    # force=True (the weekly guaranteed-drain run) uses its own, higher ceiling —
    # added 2026-07-22 after the daily 8am run went 3 straight days without a
    # single real deletion (false-positive defer, see check 2b above) and the
    # backlog silently grew to 268, past the daily limit of 200. A sustained
    # restore/recovery project can keep generating a modest surplus like that
    # for days; the daily limit should stay tight (catches real scoring-bug/
    # stale-cache blowups fast), but the weekly run exists specifically so that
    # kind of ordinary backlog growth still drains on its own without requiring
    # a human to notice and manually raise DEDUP_SAFETY_LIMIT every time.
    DEDUP_SAFETY_LIMIT = int(os.environ.get('DEDUP_SAFETY_LIMIT', '200'))
    if force:
        DEDUP_SAFETY_LIMIT = int(os.environ.get('DEDUP_SAFETY_LIMIT_WEEKLY', '500'))
    all_groups = [(ftype, group) for ftype, groups in scan_data.get('unraid', {}).items()
                  for group in groups if len(group.get('versions', [])) >= 2]
    total_deletable = sum(
        len([v for v in g.get('versions', [])[1:] if v.get('safe_to_delete', True)])
        for _, g in all_groups
    )
    if total_deletable > DEDUP_SAFETY_LIMIT:
        msg = (f"Dedup safety limit hit: {total_deletable} deletable duplicates found "
               f"(limit={DEDUP_SAFETY_LIMIT}{' weekly' if force else ''}). Skipping all deletions. "
               f"Raise DEDUP_SAFETY_LIMIT{'_WEEKLY' if force else ''} or investigate — may indicate ongoing batch sync.")
        logger.error(f"Unraid dedup: {msg}")
        send_dedup_notification(title="Unraid Dedup BLOCKED", body=msg,
                          notify_type=apprise.NotifyType.FAILURE)
        _write_dedup_status('blocked', msg)
        return

    # ── 5. Per-run cap ────────────────────────────────────────────────────────
    DEDUP_MAX_PER_RUN = int(os.environ.get('DEDUP_MAX_PER_RUN', '50'))
    # Flatten all groups for clean cap enforcement across all ftypes (Issue 1 fix:
    # iterating dict directly had no break at the ftype level, allowing overflow).
    for _, group in all_groups:
        if total_deleted >= DEDUP_MAX_PER_RUN:
            break
        versions = group.get('versions', [])
        if len(versions) < 2:
            continue
        if _dedup_is_multipart_group(group) or _dedup_is_always_protected_title(group.get('title', '')):
            logger.debug(f"Dedup: skipping multi-part/protected group '{group.get('title', '')}'")
            continue
        # versions[0] is the keeper — either Radarr/Sonarr's actively-tracked file
        # (Profile Authority correction above) or, absent a tracked-file match,
        # highest raw TRaSH score as sorted by the Agent.
        keeper_path = versions[0].get('file_path', '')
        for version in versions[1:]:
            if not version.get('safe_to_delete', True):
                logger.debug(f"Dedup: skipping unsafe {version.get('file_path')}")
                continue
            if total_deleted >= DEDUP_MAX_PER_RUN:
                break
            file_path = version.get('file_path', '')
            if not file_path:
                continue
            # Independent sanity check — added 2026-07-19 alongside the known-bad
            # guard. Doesn't rely on versions[1:] excluding the keeper by
            # construction: if a future bug ever duplicated a path in the group or
            # left the tracked file out of position 0, this refuses the delete
            # rather than trusting the loop bounds alone.
            if keeper_path and file_path == keeper_path:
                logger.error(
                    f"Dedup: REFUSING to delete '{file_path}' — matches the group's "
                    f"own kept/tracked file. This should be impossible; investigate "
                    f"before this group is processed again."
                )
                errors.append(file_path)
                continue
            freed = version.get('file_size_bytes', 0)

            if DRY_RUN:
                logger.info(f"Dedup [DRY RUN]: would delete: {file_path} ({format_size(freed)})")
                total_deleted += 1
                total_freed += freed
                top_freed.append((freed, file_path))
                continue

            try:
                del_resp = requests.post(
                    f"{UNRAID_AGENT_URL}/delete",
                    json={'paths': [file_path]},
                    headers={'X-Api-Key': UNRAID_AGENT_API_KEY},
                    timeout=30
                )
                if del_resp.status_code == 200:
                    # Issue 7 fix: Agent returns 200 even on partial failure.
                    # Confirm the path appears in 'deleted' list before counting.
                    result = del_resp.json()
                    if file_path in result.get('deleted', []):
                        total_deleted += 1
                        total_freed += freed
                        top_freed.append((freed, file_path))
                        logger.info(f"Dedup: removed lower-quality duplicate: {file_path}")
                    else:
                        errors.append(file_path)
                        logger.warning(f"Dedup: Agent reported error for {file_path}: "
                                       f"{result.get('errors', 'unknown')}")
                else:
                    errors.append(file_path)
                    logger.warning(f"Dedup: Agent delete failed ({del_resp.status_code}): {file_path}")
            except Exception as e:
                errors.append(file_path)
                logger.error(f"Dedup: error deleting {file_path}: {e}")

    # Remaining duplicates deferred to next run
    remaining = total_deletable - total_deleted
    prefix = "[DRY RUN] " if DRY_RUN else ""
    summary = f"{prefix}Removed {total_deleted} duplicate(s), freed {format_size(total_freed)}"
    if remaining > 0:
        summary += f" | {remaining} more deferred to next run"
    if errors:
        summary += f" | {len(errors)} error(s)"
    logger.info(f"Unraid dedup: {summary}")
    _write_dedup_status('ran', summary, deleted=total_deleted, freed=total_freed)

    if total_deleted > 0 or DRY_RUN:
        # Include up to 10 largest deletions in the notification for visibility
        top_freed.sort(reverse=True)
        sample = "\n".join(
            f"  {format_size(b)} — {os.path.basename(p)}"
            for b, p in top_freed[:10]
        )
        body = summary
        if sample:
            body += f"\n\nLargest removed:\n{sample}"
        send_dedup_notification(
            title=f"Unraid Nightly Dedup{' (DRY RUN)' if DRY_RUN else ''}",
            body=body,
            notify_type=apprise.NotifyType.WARNING if DRY_RUN else apprise.NotifyType.INFO
        )


def scan_library_gaps():
    """
    Nightly reconciliation: compare Synology HD-movies source folders vs Unraid destination
    (fetched via Unraid Agent API, not CIFS). Any folder on Synology but missing from Unraid
    gets queued as a sync job.

    Skips: system entries (#recycle, .lnk, .txt), items already pending/in_progress.
    Note: the 7-day skip was removed 2026-06-17 — missing files are always re-queued.
    """
    SKIP_NAMES = {'#recycle', 'testfile'}
    SKIP_SUFFIXES = ('.lnk', '.txt', '.url')

    src_base = '/mnt/synology/rs-movies'

    if not os.path.isdir(src_base):
        logger.warning("Gap scanner: Synology movies mount not accessible, skipping")
        return

    # Synology: direct NFS listing (fast, local mount)
    try:
        src_folders = set(os.listdir(src_base))
    except Exception as e:
        logger.error(f"Gap scanner: failed to list Synology movies: {e}")
        return

    # Unraid: fetch via Agent API (avoids slow CIFS listing over VPN)
    try:
        dst_folders = _get_unraid_movie_folders()
        logger.info(f"Gap scanner: Synology={len(src_folders)} folders, Unraid={len(dst_folders)} folders")
    except Exception as e:
        logger.error(f"Gap scanner: failed to fetch Unraid inventory from agent: {e}")
        return

    missing = sorted(src_folders - dst_folders)
    filtered = []
    for m in missing:
        if m in SKIP_NAMES or any(m.endswith(s) for s in SKIP_SUFFIXES):
            continue
        folder_path = os.path.join(src_base, m)
        if os.path.isdir(folder_path) and not any(True for _ in Path(folder_path).iterdir()):
            logger.debug(f"Gap scanner: skipping empty source folder: {m}")
            continue
        filtered.append(m)
    missing = filtered

    if not missing:
        logger.info("Gap scanner: HD movies are in sync — no gaps found")
        return

    logger.info(f"Gap scanner: {len(missing)} HD movie folder(s) missing from Unraid")

    total_queued = 0
    queued_titles = []
    MOVIE_GAP_SCAN_MAX_QUEUE = int(os.environ.get('GAP_SCAN_MAX_QUEUE', '500'))

    conn = sqlite3.connect(DB_PATH, timeout=30)
    conn.row_factory = sqlite3.Row
    cursor = conn.cursor()

    for folder in missing:
        if total_queued >= MOVIE_GAP_SCAN_MAX_QUEUE:
            logger.info(f"Gap scanner: capped at {MOVIE_GAP_SCAN_MAX_QUEUE} queued — "
                        f"{len(missing) - total_queued} movie gaps deferred to tomorrow")
            break

        source = os.path.join(src_base, folder)

        # Skip if already pending or in_progress (exact source_path match)
        cursor.execute(
            "SELECT id FROM sync_jobs WHERE source_path = ? AND status IN ('pending','in_progress')",
            (source,)
        )
        if cursor.fetchone():
            logger.debug(f"Gap scanner: {folder} already queued, skipping")
            continue

        # NOTE: Do NOT skip based on "recently synced" — the folder is missing from Unraid
        # (verified by fresh Agent inventory above). Dedup may have deleted it after last sync.

        try:
            file_size = sum(f.stat().st_size for f in Path(source).rglob('*') if f.is_file())
        except Exception:
            file_size = 0

        conn.close()
        background_sync(source, '/mnt/unraid/media/Movies', folder, 'GapSync', file_size, 'Movie')
        conn = sqlite3.connect(DB_PATH, timeout=30)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()

        total_queued += 1
        queued_titles.append(folder)
        logger.info(f"Gap scanner: queued {folder}")

    conn.close()

    if total_queued > 0:
        titles_list = "\n".join(f"• {t}" for t in queued_titles[:20])
        if len(queued_titles) > 20:
            titles_list += f"\n... and {len(queued_titles) - 20} more"
        send_notification(
            title="Movie Gap Sync",
            body=f"Found {total_queued} HD movie(s) missing from Unraid — queued for sync:\n{titles_list}",
            notify_type=apprise.NotifyType.WARNING
        )
    else:
        logger.info("Gap scanner: all HD movies are in sync")


# Daily DB backup at 10:00 PM ET
scheduler.add_job(
    func=lambda: create_backup('scheduled'),
    trigger='cron',
    hour=22,
    minute=0,
    id='db_backup',
    name='Daily DB backup',
    replace_existing=True
)

# Add history scanner job
if RADARR_HD_API_KEY or SONARR_HD_API_KEY:
    scheduler.add_job(
        func=scan_arr_history,
        trigger='interval',
        minutes=HISTORY_SCAN_INTERVAL,
        id='history_scanner',
        name='Scan Radarr/Sonarr history for missed downloads',
        replace_existing=True
    )
    logger.info(f"History scanner enabled - checking every {HISTORY_SCAN_INTERVAL} min, looking back {HISTORY_SCAN_HOURS} hours")

# TV gap scanner — nightly at 11:00 PM ET
scheduler.add_job(
    func=scan_tv_gaps,
    trigger='cron',
    hour=23,
    minute=0,
    id='tv_gap_scanner',
    name='Nightly TV gap scan (Synology vs Unraid via Agent)',
    replace_existing=True
)
logger.info("TV gap scanner enabled - runs nightly at 11:00 PM ET")

# TV version reconcile — nightly at 11:15 PM ET (after TV gap scan).
# Score-gated + quality-filtered: only syncs when Synology scores higher AND file
# passes the 720p/x265-no-HDR filter. Unraid's better copies are never touched.
scheduler.add_job(
    func=reconcile_tv_versions,
    trigger='cron',
    hour=23,
    minute=15,
    timezone='America/New_York',
    id='tv_version_reconcile',
    name='Nightly TV version reconcile (TV-specific scoring picks direction; 720p excluded both ways)',
    replace_existing=True
)
logger.info("TV version reconcile enabled (TV-specific scoring: WEB-DL > Bluray, fixed 2026-07-02) - runs nightly at 11:15 PM ET")

# Movie gap scanner — nightly at 11:30 PM ET (after TV reconcile, before library report)
scheduler.add_job(
    func=scan_library_gaps,
    trigger='cron',
    hour=23,
    minute=30,
    id='library_gap_scanner',
    name='Nightly HD movie gap scan (Synology vs Unraid via Agent)',
    replace_existing=True
)
logger.info("Library gap scanner enabled - runs nightly at 11:30 PM ET")

# Movie version reconcile — nightly at 11:45 PM ET (after movie gap scan).
# Profile Authority, not a score gate: Radarr's tracked file always wins and gets
# pushed to Unraid, even if Unraid's current file scores higher raw TRaSH (e.g.
# Unraid holds a Remux, Radarr tracks Bluray-1080p because that's the assigned
# profile). See CLAUDE.md "Profile Authority" section. (Comment corrected 2026-07-02
# — it previously described a score gate that was removed; see reconcile_movie_versions() docstring.)
scheduler.add_job(
    func=reconcile_movie_versions,
    trigger='cron',
    hour=23,
    minute=45,
    id='movie_version_reconcile',
    name='Nightly movie version reconcile (Profile Authority — Radarr file always wins)',
    replace_existing=True
)
logger.info("Movie version reconcile enabled (Profile Authority) - runs nightly at 11:45 PM ET")

# Library health report — nightly at 12:15 AM ET (after both gap scans)
scheduler.add_job(
    func=nightly_library_report,
    trigger='cron',
    hour=0,
    minute=15,
    id='library_report',
    name='Nightly library health report (movies + TV summary to Telegram)',
    replace_existing=True
)
logger.info("Library report enabled - runs nightly at 12:15 AM ET")

# Unraid dedup — daily at 8:00 AM ET.
# Gap scanners run at 11:00/11:30 PM ET and queue rsync jobs;
# running dedup at 8 AM ET gives the 12-concurrent rsync queue ~8 hours to drain
# before dedup evaluates what remains.
scheduler.add_job(
    func=nightly_unraid_dedup,
    trigger='cron',
    hour=8,
    minute=0,
    id='unraid_dedup',
    name='Daily Unraid duplicate cleanup via Agent',
    replace_existing=True
)
logger.info("Unraid dedup enabled - runs daily at 8:00 AM ET")

# Weekly guaranteed-drain dedup — Sunday 9:00 AM ET, force=True (bypasses only the
# DEDUP_MIN_AGE_HOURS "recent gap job" defer, still honors PAUSE_DEDUP and the
# active-in-progress-job check). Added 2026-07-19 after finding the daily job had
# silently deferred every single day for 11+ days straight during the TV restore
# project, since that project completes a gap-sync job almost every day and the daily
# job never gets a quiet window. This guarantees the backlog can't grow unbounded even
# if the daily heuristic keeps missing.
scheduler.add_job(
    func=nightly_unraid_dedup,
    kwargs={'force': True},
    trigger='cron',
    day_of_week='sun',
    hour=9,
    minute=0,
    id='unraid_dedup_weekly_forced',
    name='Weekly guaranteed Unraid duplicate cleanup (bypasses recent-gap-job defer)',
    replace_existing=True
)
logger.info("Unraid weekly guaranteed dedup enabled - runs Sunday 9:00 AM ET (force=True)")

scheduler.start()
logger.info("Scheduler started - daily summary at 00:05, auto-retry every 15 min")

# Recover interrupted jobs in background so gunicorn serves health checks
# immediately after startup (recovery of 10k+ jobs can take 1-2 minutes).
def _deferred_recovery():
    interrupted_count = recover_interrupted_jobs()
    if interrupted_count > 0:
        logger.info(f"Recovered {interrupted_count} interrupted jobs from previous run")

threading.Thread(target=_deferred_recovery, name="startup-recovery", daemon=True).start()

# Shut down scheduler on exit
atexit.register(lambda: scheduler.shutdown())


@app.route('/metrics', methods=['GET'])
def prometheus_metrics():
    """Prometheus-format metrics for sync-webhook"""
    job_counts = get_job_counts()
    available_slots = sync_semaphore._value
    active_syncs = MAX_CONCURRENT_SYNCS - available_slots

    with stats_lock:
        bytes_xfer = stats['bytes_transferred']

    lines = [
        '# HELP sync_webhook_active_syncs Currently running rsync transfers',
        '# TYPE sync_webhook_active_syncs gauge',
        f'sync_webhook_active_syncs {active_syncs}',
        '# HELP sync_webhook_pending_jobs Jobs waiting for a semaphore slot',
        '# TYPE sync_webhook_pending_jobs gauge',
        f'sync_webhook_pending_jobs {job_counts.get("pending", 0)}',
        '# HELP sync_webhook_failed_jobs_24h Failed jobs in the last 24h',
        '# TYPE sync_webhook_failed_jobs_24h gauge',
        f'sync_webhook_failed_jobs_24h {job_counts.get("failed", 0)}',
        '# HELP sync_webhook_success_jobs_24h Successful jobs in the last 24h',
        '# TYPE sync_webhook_success_jobs_24h gauge',
        f'sync_webhook_success_jobs_24h {job_counts.get("success", 0)}',
        '# HELP sync_webhook_bytes_transferred_total Total bytes transferred since startup',
        '# TYPE sync_webhook_bytes_transferred_total counter',
        f'sync_webhook_bytes_transferred_total {bytes_xfer}',
        '# HELP sync_webhook_max_concurrent Maximum concurrent syncs configured',
        '# TYPE sync_webhook_max_concurrent gauge',
        f'sync_webhook_max_concurrent {MAX_CONCURRENT_SYNCS}',
    ]
    return '\n'.join(lines) + '\n', 200, {'Content-Type': 'text/plain; charset=utf-8'}


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint with comprehensive status"""
    nfs_issues = check_nfs_health()
    job_counts = get_job_counts()

    status = 'healthy'
    if nfs_issues:
        status = 'degraded'

    # Calculate active syncs (semaphore slots in use)
    # _value gives available slots, so active = max - available
    available_slots = sync_semaphore._value
    active_syncs = MAX_CONCURRENT_SYNCS - available_slots

    return jsonify({
        'status': status,
        'timestamp': datetime.now().isoformat(),
        'dry_run': DRY_RUN,
        'notifications': len(apobj) > 0,
        'nfs_status': 'ok' if not nfs_issues else 'error',
        'nfs_issues': nfs_issues,
        'jobs_24h': job_counts,
        'uptime_since': stats['start_time'],
        'sync_queue': {
            'max_concurrent': MAX_CONCURRENT_SYNCS,
            'active_syncs': active_syncs,
            'available_slots': available_slots
        }
    })


@app.route('/api/pending-count', methods=['GET'])
def api_pending_count():
    """True all-time pending sync_jobs count (not the 24h-windowed figure /health
    reports in jobs_24h). Built for Upgraderr's sweep to check before triggering new
    searches — see _sync_queue_is_large() in services/upgraderr/app.py."""
    try:
        conn = sqlite3.connect(DB_PATH, timeout=30)
        count = conn.execute("SELECT COUNT(*) FROM sync_jobs WHERE status='pending'").fetchone()[0]
        conn.close()
        return jsonify({'pending': count})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/stats', methods=['GET'])
def get_stats():
    """Get sync statistics"""
    with stats_lock:
        current_stats = dict(stats)

    # Add formatted bytes transferred
    current_stats['bytes_transferred_human'] = format_size(current_stats['bytes_transferred'])

    # Get database stats
    try:
        conn = sqlite3.connect(DB_PATH, timeout=30)
        cursor = conn.cursor()

        # Total counts
        cursor.execute('SELECT COUNT(*) FROM sync_jobs WHERE status = "success"')
        current_stats['total_successful'] = cursor.fetchone()[0]

        cursor.execute('SELECT COUNT(*) FROM sync_jobs WHERE status = "failed"')
        current_stats['total_failed'] = cursor.fetchone()[0]

        # Today's counts
        cursor.execute('''
            SELECT COUNT(*) FROM sync_jobs
            WHERE status = "success" AND date(created_at) = date('now')
        ''')
        current_stats['today_successful'] = cursor.fetchone()[0]

        cursor.execute('''
            SELECT COUNT(*) FROM sync_jobs
            WHERE status = "failed" AND date(created_at) = date('now')
        ''')
        current_stats['today_failed'] = cursor.fetchone()[0]

        conn.close()
    except Exception as e:
        logger.error(f"Error getting database stats: {e}")

    return jsonify(current_stats)


@app.route('/jobs', methods=['GET'])
def list_jobs():
    """List recent sync jobs"""
    limit = request.args.get('limit', 50, type=int)
    status_filter = request.args.get('status', None)

    try:
        conn = sqlite3.connect(DB_PATH, timeout=30)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()

        if status_filter:
            cursor.execute('''
                SELECT * FROM sync_jobs
                WHERE status = ?
                ORDER BY created_at DESC
                LIMIT ?
            ''', (status_filter, limit))
        else:
            cursor.execute('''
                SELECT * FROM sync_jobs
                ORDER BY created_at DESC
                LIMIT ?
            ''', (limit,))

        jobs = [dict(row) for row in cursor.fetchall()]
        conn.close()

        return jsonify({'jobs': jobs, 'count': len(jobs)})
    except Exception as e:
        logger.error(f"Error listing jobs: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/jobs/<int:job_id>', methods=['GET'])
def get_job(job_id):
    """Get details for a specific job"""
    try:
        conn = sqlite3.connect(DB_PATH, timeout=30)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        cursor.execute('SELECT * FROM sync_jobs WHERE id = ?', (job_id,))
        row = cursor.fetchone()
        conn.close()

        if row:
            return jsonify(dict(row))
        else:
            return jsonify({'error': 'Job not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/test', methods=['POST', 'GET'])
def test_notification():
    """Test notification endpoint"""
    send_notification(
        title="Mother Sync Test",
        body="If you see this, notifications are working!",
        notify_type=apprise.NotifyType.SUCCESS
    )
    return jsonify({'status': 'notification sent'})


@app.route('/summary/send', methods=['POST', 'GET'])
def trigger_summary():
    """Manually trigger daily summary (for testing)"""
    try:
        # Run in background to return immediately
        thread = threading.Thread(target=send_daily_summary, daemon=True)
        thread.start()
        return jsonify({'status': 'summary triggered'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/sync/radarr', methods=['POST'])
def radarr_webhook():
    """
    Handle Radarr webhook.

    Expected events: Download, Upgrade, MovieFileDelete
    """
    try:
        data = request.json
        if not data:
            return jsonify({'error': 'No JSON data'}), 400

        event_type = data.get('eventType', 'Unknown')
        logger.info(f"Radarr webhook received: {event_type}")
        logger.debug(f"Payload: {json.dumps(data, indent=2)}")

        # Handle supported event types
        if event_type not in ['Download', 'Upgrade', 'Test', 'MovieFileDelete']:
            logger.info(f"Ignoring event type: {event_type}")
            return jsonify({'status': 'ignored', 'reason': f'Event type {event_type} not handled'})

        # Handle test webhook
        if event_type == 'Test':
            send_notification(
                title="Radarr Webhook Test",
                body="Webhook connection successful!",
                notify_type=apprise.NotifyType.SUCCESS
            )
            return jsonify({'status': 'test successful'})

        # Extract movie info
        movie = data.get('movie', {})
        title = movie.get('title', 'Unknown Movie')
        year = movie.get('year', '')
        display_title = f"{title} ({year})" if year else title

        # Check if title should be skipped
        for skip_title in SKIP_TITLES:
            if skip_title.lower() in title.lower():
                logger.info(f"Skipping excluded title: {display_title} (matched: {skip_title})")
                return jsonify({
                    'status': 'skipped',
                    'reason': f'Title in skip list: {skip_title}',
                    'title': display_title
                })

        # Handle MovieFileDelete event (append-only sync — ignore deletions)
        if event_type == 'MovieFileDelete':
            delete_reason = data.get('deleteReason', 'unknown')
            logger.info(f"MovieFileDelete ignored (append-only sync): {display_title} — reason: {delete_reason}")
            return jsonify({'status': 'ignored', 'reason': 'append-only sync mode'})

        # Handle Download/Upgrade events
        movie_file = data.get('movieFile', {})
        folder_path = movie.get('folderPath', '')
        file_path = movie_file.get('path', '')
        file_size = movie_file.get('size', 0)
        is_upgrade = data.get('isUpgrade', False)

        # Safely extract quality - handle various payload formats
        quality_data = movie_file.get('quality', {})
        if isinstance(quality_data, dict):
            inner_quality = quality_data.get('quality', {})
            if isinstance(inner_quality, dict):
                quality = inner_quality.get('name', 'Unknown')
            elif isinstance(inner_quality, str):
                quality = inner_quality
            else:
                quality = str(quality_data.get('name', 'Unknown'))
        else:
            quality = str(quality_data) if quality_data else 'Unknown'

        upgrade_note = " [UPGRADE]" if is_upgrade else ""
        logger.info(f"Processing: {display_title} - {quality}{upgrade_note}")
        logger.info(f"File path: {file_path}")

        # Translate path
        source, dest, dest_base = translate_path(folder_path)
        if not source:
            error_msg = f"No path mapping for: {folder_path}"
            logger.error(error_msg)
            send_notification(
                title="Sync Error - Path Mapping",
                body=f"Movie: {display_title}\nPath: {folder_path}\n\nNo path mapping configured!",
                notify_type=apprise.NotifyType.FAILURE
            )
            return jsonify({'error': error_msg}), 400

        # Run rsync in background thread - returns immediately
        logger.info(f"Syncing: {source} -> {dest}")
        background_sync(
            source=source,
            dest=dest,
            title=display_title,
            quality=quality,
            file_size=file_size,
            media_type="Movie",
            dest_base=dest_base,
            priority=-1 if not is_upgrade else 0,
        )

        # Return immediately - sync happens in background
        response_data = {
            'status': 'accepted',
            'message': f'Sync started for {display_title}',
            'source': source,
            'dest': dest,
            'is_upgrade': is_upgrade
        }

        return jsonify(response_data)

    except Exception as e:
        logger.exception("Error processing Radarr webhook")
        send_notification(
            title="Sync Error - Radarr",
            body=f"Exception: {str(e)[:500]}",
            notify_type=apprise.NotifyType.FAILURE
        )
        return jsonify({'error': str(e)}), 500


@app.route('/sync/sonarr', methods=['POST'])
def sonarr_webhook():
    """
    Handle Sonarr webhook.

    Expected events: Download, Upgrade, EpisodeFileDelete
    """
    try:
        data = request.json
        if not data:
            return jsonify({'error': 'No JSON data'}), 400

        event_type = data.get('eventType', 'Unknown')
        logger.info(f"Sonarr webhook received: {event_type}")
        logger.debug(f"Payload: {json.dumps(data, indent=2)}")

        # Handle supported event types
        if event_type not in ['Download', 'Upgrade', 'Test', 'EpisodeFileDelete']:
            logger.info(f"Ignoring event type: {event_type}")
            return jsonify({'status': 'ignored', 'reason': f'Event type {event_type} not handled'})

        # Handle test webhook
        if event_type == 'Test':
            send_notification(
                title="Sonarr Webhook Test",
                body="Webhook connection successful!",
                notify_type=apprise.NotifyType.SUCCESS
            )
            return jsonify({'status': 'test successful'})

        # Extract series info
        series = data.get('series', {})
        series_title = series.get('title', 'Unknown Series')
        series_path = series.get('path', '')

        # Handle EpisodeFileDelete event (append-only sync — ignore deletions)
        if event_type == 'EpisodeFileDelete':
            delete_reason = data.get('deleteReason', 'unknown')
            logger.info(f"EpisodeFileDelete ignored (append-only sync): {series_title} — reason: {delete_reason}")
            return jsonify({'status': 'ignored', 'reason': 'append-only sync mode'})

        # Handle Download/Upgrade events
        episodes = data.get('episodes', [{}])
        episode_file = data.get('episodeFile', {})
        file_path = episode_file.get('path', '')
        file_size = episode_file.get('size', 0)
        is_upgrade = data.get('isUpgrade', False)

        # Safely extract quality - handle various payload formats
        quality_data = episode_file.get('quality', {})
        if isinstance(quality_data, dict):
            inner_quality = quality_data.get('quality', {})
            if isinstance(inner_quality, dict):
                quality = inner_quality.get('name', 'Unknown')
            elif isinstance(inner_quality, str):
                quality = inner_quality
            else:
                quality = str(quality_data.get('name', 'Unknown'))
        else:
            quality = str(quality_data) if quality_data else 'Unknown'

        # Build episode string (e.g., S01E05 or S01E05-E06)
        ep_codes = []
        for ep in episodes:
            season = ep.get('seasonNumber', 0)
            episode_num = ep.get('episodeNumber', 0)
            ep_codes.append(f"S{season:02d}E{episode_num:02d}")
        ep_string = '-'.join(ep_codes) if ep_codes else 'Unknown'

        ep_titles = [ep.get('title', '') for ep in episodes if ep.get('title')]
        ep_title = ' / '.join(ep_titles[:2])  # Limit to 2 titles
        if len(ep_titles) > 2:
            ep_title += f" (+{len(ep_titles)-2} more)"

        upgrade_note = " [UPGRADE]" if is_upgrade else ""
        logger.info(f"Processing: {series_title} - {ep_string}{upgrade_note}")
        logger.info(f"File path: {file_path}")

        # Translate path - sync the specific episode file
        source, dest, dest_base = translate_path(file_path)
        if not source:
            # Try series folder path
            source, dest, dest_base = translate_path(series_path)
            if not source:
                error_msg = f"No path mapping for: {file_path} or {series_path}"
                logger.error(error_msg)
                send_notification(
                    title="Sync Error - Path Mapping",
                    body=f"Series: {series_title}\nPath: {file_path}\n\nNo path mapping configured!",
                    notify_type=apprise.NotifyType.FAILURE
                )
                return jsonify({'error': error_msg}), 400

        # For TV, sync in background thread - returns immediately
        logger.info(f"Syncing: {source} -> {dest}")
        display_title = f"{series_title} - {ep_string}"
        if ep_title:
            display_title += f": {ep_title}"

        background_sync(
            source=source,
            dest=dest,
            title=display_title,
            dest_base=dest_base,
            quality=quality,
            file_size=file_size,
            media_type="Episode",
            priority=-1 if not is_upgrade else 0,
        )

        # Return immediately - sync happens in background
        response_data = {
            'status': 'accepted',
            'message': f'Sync started for {display_title}',
            'source': source,
            'dest': dest,
            'is_upgrade': is_upgrade
        }

        return jsonify(response_data)

    except Exception as e:
        logger.exception("Error processing Sonarr webhook")
        send_notification(
            title="Sync Error - Sonarr",
            body=f"Exception: {str(e)[:500]}",
            notify_type=apprise.NotifyType.FAILURE
        )
        return jsonify({'error': str(e)}), 500


@app.route('/jobs/<int:job_id>/retry', methods=['POST'])
def retry_job(job_id):
    """Retry a specific failed job"""
    try:
        conn = sqlite3.connect(DB_PATH, timeout=30)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        cursor.execute('SELECT * FROM sync_jobs WHERE id = ?', (job_id,))
        row = cursor.fetchone()

        if not row:
            conn.close()
            return jsonify({'error': 'Job not found'}), 404

        job = dict(row)
        if job['status'] not in ['failed']:
            conn.close()
            return jsonify({'error': f'Job status is {job["status"]}, not failed'}), 400

        # Queue the retry
        source = job['source_path']
        dest = job['dest_path']
        title = job['title'] or 'Unknown'
        job_type = job['job_type']
        file_size = job['file_size'] or 0

        logger.info(f"Retrying job {job_id}: {title}")

        # Run in background
        media_type = "Movie" if job_type == 'movie' else "Episode"
        background_sync(source, dest, f"[RETRY] {title}", job.get('quality') or 'Retry', file_size, media_type,
                       dest_base=None, retry_count=1,
                       delete_after_sync=job.get('delete_after_sync'))

        conn.close()
        return jsonify({'status': 'retry_started', 'job_id': job_id})

    except Exception as e:
        logger.error(f"Error retrying job {job_id}: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/queue/retry-failed', methods=['POST'])
def retry_all_failed():
    """Retry failed jobs within the lookback window (oldest first, capped at 500 per click)"""
    try:
        conn = sqlite3.connect(DB_PATH, timeout=30)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        lookback = f'-{RETRY_LOOKBACK_DAYS} days'
        cursor.execute('''
            SELECT f.* FROM sync_jobs f
            WHERE f.status = 'failed'
            AND f.created_at > strftime('%Y-%m-%dT%H:%M:%S', 'now', ?)
            AND NOT EXISTS (
                SELECT 1 FROM sync_jobs s
                WHERE s.title = f.title
                AND s.status = 'success'
                AND s.created_at > f.created_at
            )
            ORDER BY f.created_at ASC
            LIMIT 500
        ''', (lookback,))
        failed_jobs = [dict(row) for row in cursor.fetchall()]
        conn.close()

        if not failed_jobs:
            return jsonify({'status': 'no_failed_jobs', 'count': 0})

        # Deduplicate by title
        seen_titles = set()
        unique_jobs = []
        for job in failed_jobs:
            title = job['title'] or 'Unknown'
            if title not in seen_titles:
                seen_titles.add(title)
                unique_jobs.append(job)

        retried = 0
        for job in unique_jobs:
            source = job['source_path']
            dest = job['dest_path']
            title = job['title'] or 'Unknown'
            job_type = job['job_type']
            file_size = job['file_size'] or 0
            retry_count = (job.get('retry_count') or 0) + 1

            media_type = "Movie" if job_type == 'movie' else "Episode"
            background_sync(source, dest, title, job.get('quality') or 'Retry', file_size, media_type,
                           dest_base=None, retry_count=retry_count,
                           delete_after_sync=job.get('delete_after_sync'))
            retried += 1
            logger.info(f"Queued retry for: {title}")

        return jsonify({'status': 'retries_started', 'count': retried})

    except Exception as e:
        logger.error(f"Error retrying failed jobs: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/sync/manual', methods=['POST'])
def manual_sync():
    """
    Queue a manual sync for a specific path.

    JSON body:
        path: Full container path to sync (required)
        type: "movie" or "tv" (default: "movie")
        title: Display title for notifications (default: last path component)
        quality: Quality string (default: "unknown")

    Returns 202 immediately; sync runs in background via the job queue.
    """
    try:
        data = request.json
        if not data or 'path' not in data:
            return jsonify({'error': 'Missing path parameter'}), 400

        path = data['path']
        sync_type = data.get('type', 'movie')
        title = data.get('title') or path.rstrip('/').split('/')[-1]
        quality = data.get('quality', 'unknown')

        source, dest, dest_base = translate_path(path)
        if not source:
            return jsonify({'error': f'No path mapping for: {path}'}), 400

        try:
            src_path = Path(source)
            file_size = sum(f.stat().st_size for f in src_path.rglob('*') if f.is_file()) if src_path.is_dir() else src_path.stat().st_size
        except Exception:
            file_size = 0

        media_type = 'Movie' if sync_type == 'movie' else 'Episode'
        logger.info(f"Manual sync queued: {source} -> {dest} ({title})")
        background_sync(source, dest, title, quality, file_size, media_type, dest_base)

        return jsonify({'status': 'queued', 'source': source, 'dest': dest}), 202

    except Exception as e:
        logger.exception("Error in manual sync")
        return jsonify({'error': str(e)}), 500


@app.route('/sync/reverse', methods=['POST'])
def sync_reverse():
    """
    Queue a reverse sync (Unraid -> Synology) with explicit source/dest paths,
    bypassing translate_path() (which only computes the forward direction).

    Built for one-off resolution tools — e.g. scripts/resolve_tier7_remux_duplicates.py
    copying an existing Unraid alternate back to Synology so Radarr can import it
    without a new indexer download. delete_after_sync is intentionally NOT exposed
    here: the caller decides cleanup timing (e.g. only after confirming Radarr's
    manual import succeeded), so this endpoint never deletes anything — it only
    copies. Reuses background_sync()'s existing dedup check, job tracking, retry,
    and stall-watchdog infrastructure like every other sync path in this file.

    JSON body:
        source: full Unraid CIFS source path (file) (required)
        dest: full Synology NFS destination folder (required)
        title: display title for notifications (default: source basename)
        media_type: 'Movie' or 'Episode' (default: 'Movie')
    Returns 202 immediately; sync runs in background.
    """
    try:
        data = request.json or {}
        source = data.get('source')
        dest = data.get('dest')
        if not source or not dest:
            return jsonify({'error': 'source and dest required'}), 400
        if not os.path.exists(source):
            return jsonify({'error': f'source not found: {source}'}), 404

        title = data.get('title') or os.path.basename(source)
        media_type = data.get('media_type', 'Movie')
        quality = 'MovieReverseSync' if media_type == 'Movie' else 'TVReverseSync'
        try:
            file_size = os.path.getsize(source)
        except OSError:
            file_size = 0

        logger.info(f"Manual reverse sync queued: {source} -> {dest} ({title})")
        background_sync(source, dest, title, quality, file_size, media_type, delete_after_sync=None)

        # background_sync() inserts the sync_jobs row synchronously (before spawning
        # the copy thread) so it's already present by the time we look it up here —
        # return the id so callers (e.g. the batch resolution script) can poll
        # GET /jobs/<id> for completion instead of guessing at timing.
        conn = sqlite3.connect(DB_PATH, timeout=30)
        row = conn.execute(
            "SELECT id FROM sync_jobs WHERE source_path=? AND status IN ('pending','in_progress') "
            "ORDER BY id DESC LIMIT 1", (source,)
        ).fetchone()
        conn.close()
        job_id = row[0] if row else None

        return jsonify({'status': 'queued', 'source': source, 'dest': dest, 'job_id': job_id}), 202

    except Exception as e:
        logger.exception("Error in reverse sync")
        return jsonify({'error': str(e)}), 500


@app.route('/api/backup/list')
def api_backup_list():
    return jsonify(list_backups())

@app.route('/api/backup/now', methods=['POST'])
def api_backup_now():
    path = create_backup('manual')
    if path:
        return jsonify({'status': 'ok', 'file': Path(path).name})
    return jsonify({'error': 'Backup failed — check logs'}), 500

@app.route('/api/backup/restore', methods=['POST'])
def api_backup_restore():
    import shutil
    data = request.get_json(silent=True) or {}
    filename = data.get('filename', '')
    if not filename or not filename.endswith('.db'):
        return jsonify({'error': 'Provide a valid backup filename'}), 400
    src = Path(BACKUP_DIR) / Path(filename).name  # strip any path traversal
    if not src.exists():
        return jsonify({'error': 'Backup file not found'}), 404
    create_backup('pre-restore')  # safety snapshot of current DB
    try:
        shutil.copy2(str(src), DB_PATH)
        for wal in [DB_PATH + '-shm', DB_PATH + '-wal']:
            if Path(wal).exists():
                Path(wal).unlink()
        logger.info(f"DB restored from backup: {filename}")
        return jsonify({'status': 'restored', 'message': 'Restored. Restart container to apply.'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/scheduler')
def api_scheduler():
    """Return history scanner timing info for the dashboard."""
    job = scheduler.get_job('history_scanner')
    next_run = None
    if job and job.next_run_time:
        next_run = job.next_run_time.astimezone(tz=None).strftime('%Y-%m-%d %H:%M:%S')
    return jsonify({
        'history_scanner': {
            'interval_minutes': HISTORY_SCAN_INTERVAL,
            'lookback_hours': HISTORY_SCAN_HOURS,
            'last_ran': history_scanner_last_ran.strftime('%Y-%m-%d %H:%M:%S') if history_scanner_last_ran else None,
            'last_found': history_scanner_last_found,
            'next_run': next_run,
            'enabled': job is not None,
        }
    })


# ── Jinja2 template helpers ────────────────────────────────────────────────

def _fmt_size(b):
    if b is None:
        return '—'
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if b < 1024:
            return f'{b:.1f} {unit}'
        b /= 1024
    return f'{b:.1f} PB'

def _fmt_dt(s):
    if not s:
        return '—'
    try:
        return str(s)[:16].replace('T', ' ')
    except Exception:
        return str(s)

def _fmt_dur(s):
    if s is None:
        return '—'
    s = int(s)
    if s < 60:
        return f'{s}s'
    if s < 3600:
        return f'{s//60}m {s%60}s'
    return f'{s//3600}h {(s%3600)//60}m'

app.jinja_env.globals['fmt_size'] = _fmt_size
app.jinja_env.globals['fmt_dt'] = _fmt_dt
app.jinja_env.globals['fmt_dur'] = _fmt_dur


# ── UI Routes ──────────────────────────────────────────────────────────────

@app.route('/ui')
@app.route('/ui/')
def ui_dashboard():
    conn = sqlite3.connect(DB_PATH, timeout=30)
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()

    cur.execute("SELECT COUNT(*) FROM sync_jobs WHERE status='pending'")
    pending_count = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM sync_jobs WHERE status='in_progress'")
    active_count = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM sync_jobs WHERE status='success' AND date(COALESCE(completed_at, created_at))=date('now')")
    done_today = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM sync_jobs WHERE status='failed' AND date(created_at)=date('now')")
    failed_today = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM sync_jobs WHERE status='success'")
    total_success = cur.fetchone()[0]
    cur.execute("SELECT COALESCE(SUM(file_size),0) FROM sync_jobs WHERE status='success'")
    total_bytes = cur.fetchone()[0]

    cur.execute("SELECT * FROM sync_jobs WHERE status='in_progress' ORDER BY started_at DESC")
    active = [dict(r) for r in cur.fetchall()]

    cur.execute("SELECT * FROM sync_jobs WHERE status='pending' ORDER BY priority ASC, created_at ASC LIMIT 15")
    pending = [dict(r) for r in cur.fetchall()]

    cur.execute("""
        SELECT * FROM sync_jobs
        WHERE status IN ('success','failed','cancelled')
        ORDER BY COALESCE(completed_at, created_at) DESC
        LIMIT 20
    """)
    recent = [dict(r) for r in cur.fetchall()]

    conn.close()

    hs_job = scheduler.get_job('history_scanner')
    hs_next = None
    if hs_job and hs_job.next_run_time:
        hs_next = hs_job.next_run_time.astimezone(tz=None).strftime('%H:%M:%S')

    return render_template('dashboard.html',
        pending_count=pending_count, active_count=active_count,
        done_today=done_today, failed_today=failed_today,
        total_success=total_success, total_bytes=total_bytes,
        active=active, pending=pending, recent=recent,
        hs_last_ran=history_scanner_last_ran.strftime('%H:%M:%S') if history_scanner_last_ran else None,
        hs_last_found=history_scanner_last_found,
        hs_next=hs_next,
        hs_interval=HISTORY_SCAN_INTERVAL)


@app.route('/ui/queue')
def ui_queue():
    page = request.args.get('page', 1, type=int)
    per_page = 50
    sort_col = request.args.get('sort', 'priority')
    sort_dir = request.args.get('order', 'asc')
    status_filter = request.args.get('status', 'active')
    type_filter = request.args.get('type', '')
    search_q = request.args.get('q', '')

    _allowed_sort = {'title', 'job_type', 'quality', 'file_size', 'status',
                     'priority', 'created_at', 'retry_count'}
    if sort_col not in _allowed_sort:
        sort_col = 'priority'
    sql_dir = 'DESC' if sort_dir == 'desc' else 'ASC'

    params = []
    where = []
    if status_filter == 'active':
        where.append("status IN ('pending','in_progress')")
    elif status_filter == 'failed':
        where.append("status = 'failed'")
    elif status_filter == 'cancelled':
        where.append("status = 'cancelled'")

    if type_filter:
        where.append("job_type = ?")
        params.append(type_filter)
    if search_q:
        where.append("title LIKE ?")
        params.append(f'%{search_q}%')

    where_sql = ('WHERE ' + ' AND '.join(where)) if where else ''
    secondary = ', created_at ASC' if sort_col != 'created_at' else ''

    try:
        conn = sqlite3.connect(DB_PATH, timeout=30)
        conn.row_factory = sqlite3.Row
        cur = conn.cursor()
        cur.execute(f"SELECT COUNT(*) FROM sync_jobs {where_sql}", params)
        total = cur.fetchone()[0]
        cur.execute(
            f"SELECT * FROM sync_jobs {where_sql} ORDER BY {sort_col} {sql_dir}{secondary} LIMIT ? OFFSET ?",
            params + [per_page, (page - 1) * per_page]
        )
        items = [dict(r) for r in cur.fetchall()]
        conn.close()
    except Exception as e:
        logger.error(f"UI queue error: {e}")
        items, total = [], 0

    return render_template('queue.html',
        items=items, total=total, page=page, per_page=per_page,
        sort_col=sort_col, sort_dir=sort_dir,
        status_filter=status_filter, type_filter=type_filter, search_q=search_q)


@app.route('/ui/history')
def ui_history():
    page = request.args.get('page', 1, type=int)
    per_page = 50
    sort_col = request.args.get('sort', 'completed_at')
    sort_dir = request.args.get('order', 'desc')
    status_filter = request.args.get('status', '')
    type_filter = request.args.get('type', '')
    search_q = request.args.get('q', '')

    _allowed_sort = {'title', 'job_type', 'quality', 'file_size', 'status',
                     'created_at', 'completed_at', 'duration_seconds', 'retry_count'}
    if sort_col not in _allowed_sort:
        sort_col = 'completed_at'
    sql_dir = 'DESC' if sort_dir == 'desc' else 'ASC'

    params = []
    where = ["status IN ('success','failed','cancelled')"]
    if status_filter in ('success', 'failed', 'cancelled'):
        where = [f"status = ?"]
        params.append(status_filter)

    if type_filter:
        where.append("job_type = ?")
        params.append(type_filter)
    if search_q:
        where.append("title LIKE ?")
        params.append(f'%{search_q}%')

    where_sql = 'WHERE ' + ' AND '.join(where)

    try:
        conn = sqlite3.connect(DB_PATH, timeout=30)
        conn.row_factory = sqlite3.Row
        cur = conn.cursor()
        cur.execute(f"SELECT COUNT(*) FROM sync_jobs {where_sql}", params)
        total = cur.fetchone()[0]
        cur.execute(
            f"SELECT * FROM sync_jobs {where_sql} ORDER BY {sort_col} {sql_dir} LIMIT ? OFFSET ?",
            params + [per_page, (page - 1) * per_page]
        )
        items = [dict(r) for r in cur.fetchall()]
        conn.close()
    except Exception as e:
        logger.error(f"UI history error: {e}")
        items, total = [], 0

    return render_template('history.html',
        items=items, total=total, page=page, per_page=per_page,
        sort_col=sort_col, sort_dir=sort_dir,
        status_filter=status_filter, type_filter=type_filter, search_q=search_q)


@app.route('/api/history-scan/trigger', methods=['POST'])
def trigger_history_scan():
    """Manually trigger the history scanner immediately."""
    try:
        thread = threading.Thread(target=scan_arr_history, daemon=True)
        thread.start()
        return jsonify({'status': 'triggered'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/gap-scan/trigger', methods=['POST'])
def trigger_gap_scan():
    """Manually trigger the library gap scanner (Synology vs Unraid folder diff)."""
    try:
        thread = threading.Thread(target=scan_library_gaps, daemon=True)
        thread.start()
        return jsonify({'status': 'triggered', 'message': 'Gap scan started — check logs for results'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/reconcile/trigger', methods=['POST'])
def trigger_reconcile():
    """Manually trigger bidirectional version reconcile (TV, movies, or both).
    Query param: type=tv|movies|all (default: all)
    """
    try:
        type_ = request.args.get('type', 'all')
        started = []
        if type_ in ('tv', 'all'):
            thread = threading.Thread(target=reconcile_tv_versions, daemon=True)
            thread.start()
            started.append('tv')
        if type_ in ('movies', 'all'):
            thread = threading.Thread(target=reconcile_movie_versions, daemon=True)
            thread.start()
            started.append('movies')
        if not started:
            return jsonify({'error': f"Unknown type {type_!r}, use tv|movies|all"}), 400
        return jsonify({'status': 'triggered', 'reconcile': started,
                        'message': f"Reconcile started for: {', '.join(started)} — check logs and Telegram for results"})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/api/library-report/trigger', methods=['POST'])
def trigger_library_report():
    """Manually trigger the nightly library health report (sends Telegram summary)."""
    try:
        thread = threading.Thread(target=nightly_library_report, daemon=True)
        thread.start()
        return jsonify({'status': 'triggered', 'message': 'Library report generating — Telegram notification will arrive in ~1-2 min'})
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/jobs/<int:job_id>/cancel', methods=['POST'])
def cancel_job(job_id):
    """Cancel a pending or failed job."""
    try:
        conn = sqlite3.connect(DB_PATH, timeout=30)
        cur = conn.cursor()
        cur.execute("SELECT status FROM sync_jobs WHERE id = ?", (job_id,))
        row = cur.fetchone()
        if not row:
            conn.close()
            return jsonify({'error': 'Job not found'}), 404
        if row[0] not in ('pending', 'failed'):
            conn.close()
            return jsonify({'error': f'Job is {row[0]}, only pending/failed jobs can be cancelled'}), 400
        cur.execute("UPDATE sync_jobs SET status='cancelled', completed_at=CURRENT_TIMESTAMP WHERE id=?", (job_id,))
        conn.commit()
        conn.close()
        logger.info(f"Job {job_id} cancelled via UI")
        return jsonify({'status': 'cancelled', 'job_id': job_id})
    except Exception as e:
        logger.error(f"Error cancelling job {job_id}: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/jobs/bulk-cancel', methods=['POST'])
def bulk_cancel_jobs():
    """Cancel multiple pending/failed jobs by ID. Skips in_progress jobs."""
    try:
        data = request.get_json() or {}
        ids = data.get('ids', [])
        if not ids or not isinstance(ids, list):
            return jsonify({'error': 'ids must be a non-empty list'}), 400
        # Clamp to 2000 IDs per call to prevent accidental mass-ops
        ids = [int(i) for i in ids[:2000]]
        conn = sqlite3.connect(DB_PATH, timeout=30)
        cur = conn.cursor()
        placeholders = ','.join('?' * len(ids))
        cur.execute(
            f"UPDATE sync_jobs SET status='cancelled', completed_at=CURRENT_TIMESTAMP "
            f"WHERE id IN ({placeholders}) AND status IN ('pending', 'failed')",
            ids
        )
        cancelled = cur.rowcount
        conn.commit()
        conn.close()
        logger.info(f"Bulk cancel: {cancelled} job(s) cancelled via UI (requested {len(ids)})")
        return jsonify({'cancelled': cancelled, 'requested': len(ids)})
    except Exception as e:
        logger.error(f"Error in bulk cancel: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/jobs/cancel-matching', methods=['POST'])
def cancel_matching_jobs():
    """Cancel all pending/failed jobs matching the given filters (status, type, q)."""
    try:
        data = request.get_json() or {}
        status_filter = data.get('status', '')
        type_filter   = data.get('type', '')
        search_q      = data.get('q', '')

        where = ["status IN ('pending', 'failed')"]
        params = []

        if status_filter == 'failed':
            where = ["status = 'failed'"]
        elif status_filter == 'active':
            where = ["status = 'pending'"]  # in_progress cannot be cancelled
        # '' (all) → default: both pending + failed

        if type_filter:
            where.append("job_type = ?")
            params.append(type_filter)
        if search_q:
            where.append("title LIKE ?")
            params.append(f'%{search_q}%')

        where_sql = 'WHERE ' + ' AND '.join(where)
        conn = sqlite3.connect(DB_PATH, timeout=30)
        cur = conn.cursor()
        cur.execute(
            f"UPDATE sync_jobs SET status='cancelled', completed_at=CURRENT_TIMESTAMP {where_sql}",
            params
        )
        cancelled = cur.rowcount
        conn.commit()
        conn.close()
        logger.info(f"Cancel-matching: {cancelled} job(s) cancelled (status={status_filter!r} type={type_filter!r} q={search_q!r})")
        return jsonify({'cancelled': cancelled})
    except Exception as e:
        logger.error(f"Error in cancel-matching: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/jobs/<int:job_id>/rush', methods=['POST'])
def rush_job(job_id):
    """
    Mark a pending job as high priority and open an extra semaphore slot so it
    can start immediately alongside current active syncs rather than waiting.
    """
    try:
        conn = sqlite3.connect(DB_PATH, timeout=30)
        cur = conn.cursor()
        cur.execute("SELECT status, title FROM sync_jobs WHERE id = ?", (job_id,))
        row = cur.fetchone()
        if not row:
            conn.close()
            return jsonify({'error': 'Job not found'}), 404
        if row[0] != 'pending':
            conn.close()
            return jsonify({'error': f'Job is {row[0]}, only pending jobs can be rushed'}), 400

        title = row[1] or 'Unknown'
        cur.execute("UPDATE sync_jobs SET priority = -1 WHERE id = ?", (job_id,))
        conn.commit()
        conn.close()

        # Open one extra semaphore slot so a waiting thread can start immediately.
        # Only release if the semaphore is currently fully consumed (i.e. there are
        # threads blocked on acquire). _value is a CPython implementation detail but
        # it's the only way to peek without acquiring. If _value > 0, all slots are
        # free and releasing would permanently inflate the concurrency limit.
        if sync_semaphore._value == 0:
            sync_semaphore.release()
            logger.info(f"Job {job_id} ({title}) rushed — extra semaphore slot opened")
        else:
            logger.info(f"Job {job_id} ({title}) rushed — semaphore has free slots, no extra release needed")
        return jsonify({
            'status': 'rushed',
            'job_id': job_id,
            'message': f'Extra sync slot opened — "{title}" should start within seconds ⚡'
        })
    except Exception as e:
        logger.error(f"Error rushing job {job_id}: {e}")
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    logger.info("Starting Sync Webhook Server")
    logger.info(f"DRY_RUN: {DRY_RUN}")
    logger.info(f"MAX_CONCURRENT_SYNCS: {MAX_CONCURRENT_SYNCS}")
    logger.info(f"Notifications configured: {len(apobj) > 0}")

    # Log path mappings
    logger.info("Path mappings:")
    for container, (src, dst) in PATH_MAPPINGS.items():
        logger.info(f"  {container} -> {src} -> {dst}")

    app.run(host='0.0.0.0', port=5000, debug=False)
