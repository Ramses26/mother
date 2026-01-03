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
import subprocess
import logging
import json
import threading
import sqlite3
import atexit
from datetime import datetime, timedelta
from pathlib import Path
from logging.handlers import RotatingFileHandler
from flask import Flask, request, jsonify
import apprise
from apscheduler.schedulers.background import BackgroundScheduler

# Configuration from environment
TELEGRAM_BOT_TOKEN = os.environ.get('TELEGRAM_BOT_TOKEN', '')
TELEGRAM_CHAT_ID = os.environ.get('TELEGRAM_CHAT_ID', '')
DRY_RUN = os.environ.get('SYNC_DRY_RUN', 'false').lower() == 'true'
LOG_LEVEL = os.environ.get('SYNC_LOG_LEVEL', 'INFO')
LOG_PATH = os.environ.get('SYNC_LOG_PATH', '/logs')
DB_PATH = os.environ.get('SYNC_DB_PATH', '/data/sync_jobs.db')

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
        backupCount=5
    )
    file_handler.setFormatter(logging.Formatter('%(asctime)s - %(levelname)s - %(message)s'))
    logger.addHandler(file_handler)

    # Separate sync history log (human-readable)
    history_handler = RotatingFileHandler(
        log_dir / 'sync_history.log',
        maxBytes=10*1024*1024,
        backupCount=10
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

        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()

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
                duration_seconds REAL
            )
        ''')

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
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        cursor.execute('''
            INSERT INTO sync_jobs (job_type, source_path, dest_path, title, status, duration_seconds, error_message, file_size, completed_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (job_type, source, dest, title, status, duration, error, file_size, datetime.now().isoformat() if status != 'pending' else None))
        conn.commit()
        conn.close()
    except Exception as e:
        logger.error(f"Could not log sync job: {e}")


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
            # Plex needs the path as it sees it (on the Plex server)
            # The path we have is the NFS mount path on Mother, which should match Plex's view
            params['path'] = specific_path
            logger.info(f"Triggering Plex scan for: {specific_path}")
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

    Returns: (source_path, dest_path) or (None, None) if no mapping found
    """
    # Sort by path length (longest first) to match /movies-4k before /movies
    sorted_mappings = sorted(PATH_MAPPINGS.items(), key=lambda x: len(x[0]), reverse=True)

    for container_base, (src_base, dst_base) in sorted_mappings:
        if container_path.startswith(container_base):
            # Get the relative path after the container base
            relative = container_path[len(container_base):].lstrip('/')
            source = os.path.join(src_base, relative)
            dest_dir = dst_base
            return source, dest_dir
    return None, None


def run_rsync(source: str, dest_dir: str, is_file: bool = True) -> tuple:
    """
    Run rsync for a specific file or folder.

    Returns: (success: bool, message: str, duration: float)
    """
    start_time = datetime.now()

    # Build rsync command
    # -a: archive mode
    # -v: verbose
    # -h: human readable
    # --ignore-existing: don't overwrite existing files
    # -R: use relative paths (preserves directory structure)
    cmd = [
        'rsync',
        '-avh',
        '--ignore-existing',
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
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=3600  # 1 hour timeout
        )

        duration = (datetime.now() - start_time).total_seconds()

        if result.returncode == 0:
            return True, result.stdout, duration
        else:
            return False, result.stderr, duration

    except subprocess.TimeoutExpired:
        duration = (datetime.now() - start_time).total_seconds()
        return False, "Rsync timed out after 1 hour", duration
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


def background_sync(source: str, dest: str, title: str, quality: str, file_size: int, media_type: str):
    """
    Run rsync in background thread and send notification when complete.
    This allows the webhook to return immediately.
    """
    job_type = 'movie' if media_type == 'Movie' else 'episode'

    def do_sync():
        logger.info(f"Background sync started: {title}")

        # Check NFS health before sync
        nfs_issues = check_nfs_health()
        if nfs_issues:
            error_msg = "NFS mount issues: " + "; ".join(nfs_issues)
            logger.error(error_msg)
            log_sync_job(job_type, source, dest, title, 'failed', error=error_msg, file_size=file_size)
            update_stats(job_type, success=False)
            send_notification(
                title=f"Sync Failed - NFS Error",
                body=f"*{title}*\n\n{error_msg}",
                notify_type=apprise.NotifyType.FAILURE
            )
            return

        # Run the rsync
        success, output, duration = run_rsync(source, dest, is_file=False)

        if success:
            # Log success to database and history
            log_sync_job(job_type, source, dest, title, 'success', duration=duration, file_size=file_size)
            update_stats(job_type, success=True, file_size=file_size)

            msg = (
                f"*{title}*\n"
                f"Quality: {quality}\n"
                f"Size: {format_size(file_size)}\n"
                f"Duration: {duration:.1f}s"
            )
            if DRY_RUN:
                msg += "\n_(DRY RUN - no files copied)_"

            send_notification(
                title=f"{media_type} Synced",
                body=msg,
                notify_type=apprise.NotifyType.SUCCESS
            )

            # Trigger Plex library scan for the synced content
            if not DRY_RUN:
                # Build the specific path for targeted scan (folder that was synced)
                specific_folder = os.path.join(dest, os.path.basename(source))
                trigger_plex_scan(dest, specific_folder)

            logger.info(f"Background sync completed: {title} in {duration:.1f}s")
        else:
            # Log failure to database and history
            log_sync_job(job_type, source, dest, title, 'failed', duration=duration, error=output[:500], file_size=file_size)
            update_stats(job_type, success=False)

            send_notification(
                title=f"Sync Failed - {media_type}",
                body=f"*{title}*\n\nError: {output[:500]}",
                notify_type=apprise.NotifyType.FAILURE
            )
            logger.error(f"Background sync failed: {title} - {output[:200]}")

    thread = threading.Thread(target=do_sync, daemon=True)
    thread.start()
    logger.info(f"Background sync thread started for: {title}")


def get_job_counts():
    """Get counts of jobs by status from database"""
    try:
        conn = sqlite3.connect(DB_PATH)
        cursor = conn.cursor()
        cursor.execute('''
            SELECT status, COUNT(*) FROM sync_jobs
            WHERE created_at > datetime('now', '-24 hours')
            GROUP BY status
        ''')
        counts = dict(cursor.fetchall())
        conn.close()
        return counts
    except Exception:
        return {}


def send_daily_summary():
    """Send daily summary of sync activity to Telegram"""
    logger.info("Generating daily summary...")

    try:
        conn = sqlite3.connect(DB_PATH)
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

            if failed and failed > 0:
                msg += f"\n\n⚠️ {failed} failed syncs - check /jobs?status=failed"

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
scheduler = BackgroundScheduler()
scheduler.add_job(
    func=send_daily_summary,
    trigger='cron',
    hour=0,
    minute=5,  # Run at 00:05 each day
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


def auto_retry_failed():
    """Automatically retry failed jobs every 15 minutes"""
    global _error_alert_sent
    logger.info("Auto-retry: checking for failed jobs...")
    try:
        conn = sqlite3.connect(DB_PATH)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()

        # Get failed jobs from the last 6 hours that haven't been retried recently
        cursor.execute('''
            SELECT * FROM sync_jobs
            WHERE status = 'failed'
            AND created_at > datetime('now', '-6 hours')
            AND title NOT LIKE '[RETRY]%'
            ORDER BY created_at DESC
            LIMIT 10
        ''')
        failed_jobs = [dict(row) for row in cursor.fetchall()]
        conn.close()

        # Clear error state on success
        _error_alert_sent.pop('database', None)

        if failed_jobs:
            logger.info(f"Auto-retry: found {len(failed_jobs)} failed jobs to retry")
            for job in failed_jobs:
                source = job['source_path']
                dest = job['dest_path']
                title = job['title'] or 'Unknown'
                job_type = job['job_type']
                file_size = job['file_size'] or 0

                media_type = "Movie" if job_type == 'movie' else "Episode"
                background_sync(source, dest, f"[RETRY] {title}", "Retry", file_size, media_type)
                logger.info(f"Auto-retry: queued {title}")
        else:
            logger.debug("Auto-retry: no failed jobs to retry")

    except Exception as e:
        logger.error(f"Auto-retry error: {e}")
        # Send alert only once per error type (avoid spam)
        if 'database' not in _error_alert_sent:
            send_error_alert("Database Error", str(e))
            _error_alert_sent['database'] = True


# Add auto-retry job (every 15 minutes)
scheduler.add_job(
    func=auto_retry_failed,
    trigger='interval',
    minutes=15,
    id='auto_retry',
    name='Auto retry failed syncs',
    replace_existing=True
)

scheduler.start()
logger.info("Scheduler started - daily summary at 00:05, auto-retry every 15 min")

# Shut down scheduler on exit
atexit.register(lambda: scheduler.shutdown())


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint with comprehensive status"""
    nfs_issues = check_nfs_health()
    job_counts = get_job_counts()

    status = 'healthy'
    if nfs_issues:
        status = 'degraded'

    return jsonify({
        'status': status,
        'timestamp': datetime.now().isoformat(),
        'dry_run': DRY_RUN,
        'notifications': len(apobj) > 0,
        'nfs_status': 'ok' if not nfs_issues else 'error',
        'nfs_issues': nfs_issues,
        'jobs_24h': job_counts,
        'uptime_since': stats['start_time']
    })


@app.route('/stats', methods=['GET'])
def get_stats():
    """Get sync statistics"""
    with stats_lock:
        current_stats = dict(stats)

    # Add formatted bytes transferred
    current_stats['bytes_transferred_human'] = format_size(current_stats['bytes_transferred'])

    # Get database stats
    try:
        conn = sqlite3.connect(DB_PATH)
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
        conn = sqlite3.connect(DB_PATH)
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
        conn = sqlite3.connect(DB_PATH)
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

    Expected events: Download, Upgrade
    """
    try:
        data = request.json
        if not data:
            return jsonify({'error': 'No JSON data'}), 400

        event_type = data.get('eventType', 'Unknown')
        logger.info(f"Radarr webhook received: {event_type}")
        logger.debug(f"Payload: {json.dumps(data, indent=2)}")

        # Only process Download and Upgrade events
        if event_type not in ['Download', 'Upgrade', 'Test']:
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
        movie_file = data.get('movieFile', {})

        title = movie.get('title', 'Unknown Movie')
        year = movie.get('year', '')
        folder_path = movie.get('folderPath', '')
        file_path = movie_file.get('path', '')
        file_size = movie_file.get('size', 0)

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

        logger.info(f"Processing: {title} ({year}) - {quality}")
        logger.info(f"File path: {file_path}")

        # Translate path
        source, dest = translate_path(folder_path)
        if not source:
            error_msg = f"No path mapping for: {folder_path}"
            logger.error(error_msg)
            send_notification(
                title="Sync Error - Path Mapping",
                body=f"Movie: {title} ({year})\nPath: {folder_path}\n\nNo path mapping configured!",
                notify_type=apprise.NotifyType.FAILURE
            )
            return jsonify({'error': error_msg}), 400

        # Run rsync in background thread - returns immediately
        logger.info(f"Syncing: {source} -> {dest}")
        display_title = f"{title} ({year})" if year else title
        background_sync(
            source=source,
            dest=dest,
            title=display_title,
            quality=quality,
            file_size=file_size,
            media_type="Movie"
        )

        # Return immediately - sync happens in background
        return jsonify({
            'status': 'accepted',
            'message': f'Sync started for {display_title}',
            'source': source,
            'dest': dest
        })

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

    Expected events: Download, Upgrade
    """
    try:
        data = request.json
        if not data:
            return jsonify({'error': 'No JSON data'}), 400

        event_type = data.get('eventType', 'Unknown')
        logger.info(f"Sonarr webhook received: {event_type}")
        logger.debug(f"Payload: {json.dumps(data, indent=2)}")

        # Only process Download and Upgrade events
        if event_type not in ['Download', 'Upgrade', 'Test']:
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
        episodes = data.get('episodes', [{}])
        episode_file = data.get('episodeFile', {})

        series_title = series.get('title', 'Unknown Series')
        series_path = series.get('path', '')
        file_path = episode_file.get('path', '')
        file_size = episode_file.get('size', 0)

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
            episode = ep.get('episodeNumber', 0)
            ep_codes.append(f"S{season:02d}E{episode:02d}")
        ep_string = '-'.join(ep_codes) if ep_codes else 'Unknown'

        ep_titles = [ep.get('title', '') for ep in episodes if ep.get('title')]
        ep_title = ' / '.join(ep_titles[:2])  # Limit to 2 titles
        if len(ep_titles) > 2:
            ep_title += f" (+{len(ep_titles)-2} more)"

        logger.info(f"Processing: {series_title} - {ep_string}")
        logger.info(f"File path: {file_path}")

        # Translate path - sync the specific episode file
        source, dest = translate_path(file_path)
        if not source:
            # Try series folder path
            source, dest = translate_path(series_path)
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
            quality=quality,
            file_size=file_size,
            media_type="Episode"
        )

        # Return immediately - sync happens in background
        return jsonify({
            'status': 'accepted',
            'message': f'Sync started for {display_title}',
            'source': source,
            'dest': dest
        })

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
        conn = sqlite3.connect(DB_PATH)
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
        background_sync(source, dest, f"[RETRY] {title}", "Retry", file_size, media_type)

        conn.close()
        return jsonify({'status': 'retry_started', 'job_id': job_id})

    except Exception as e:
        logger.error(f"Error retrying job {job_id}: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/queue/retry-failed', methods=['POST'])
def retry_all_failed():
    """Retry all failed jobs from the last 24 hours"""
    try:
        conn = sqlite3.connect(DB_PATH)
        conn.row_factory = sqlite3.Row
        cursor = conn.cursor()
        cursor.execute('''
            SELECT * FROM sync_jobs
            WHERE status = 'failed'
            AND created_at > datetime('now', '-24 hours')
            ORDER BY created_at DESC
        ''')
        failed_jobs = [dict(row) for row in cursor.fetchall()]
        conn.close()

        if not failed_jobs:
            return jsonify({'status': 'no_failed_jobs', 'count': 0})

        retried = 0
        for job in failed_jobs:
            source = job['source_path']
            dest = job['dest_path']
            title = job['title'] or 'Unknown'
            job_type = job['job_type']
            file_size = job['file_size'] or 0

            media_type = "Movie" if job_type == 'movie' else "Episode"
            background_sync(source, dest, f"[RETRY] {title}", "Retry", file_size, media_type)
            retried += 1
            logger.info(f"Queued retry for: {title}")

        return jsonify({'status': 'retries_started', 'count': retried})

    except Exception as e:
        logger.error(f"Error retrying failed jobs: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/sync/manual', methods=['POST'])
def manual_sync():
    """
    Trigger manual sync for a specific path.

    JSON body:
        path: Full container path to sync
        type: "movie" or "tv"
    """
    try:
        data = request.json
        if not data or 'path' not in data:
            return jsonify({'error': 'Missing path parameter'}), 400

        path = data['path']
        sync_type = data.get('type', 'unknown')

        source, dest = translate_path(path)
        if not source:
            return jsonify({'error': f'No path mapping for: {path}'}), 400

        logger.info(f"Manual sync: {source} -> {dest}")
        success, output, duration = run_rsync(source, dest)

        if success:
            send_notification(
                title=f"Manual Sync Complete",
                body=f"Path: {path}\nDuration: {duration:.1f}s",
                notify_type=apprise.NotifyType.SUCCESS
            )
            return jsonify({'status': 'success', 'duration': duration})
        else:
            return jsonify({'status': 'failed', 'error': output}), 500

    except Exception as e:
        logger.exception("Error in manual sync")
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    logger.info("Starting Sync Webhook Server")
    logger.info(f"DRY_RUN: {DRY_RUN}")
    logger.info(f"Notifications configured: {len(apobj) > 0}")

    # Log path mappings
    logger.info("Path mappings:")
    for container, (src, dst) in PATH_MAPPINGS.items():
        logger.info(f"  {container} -> {src} -> {dst}")

    app.run(host='0.0.0.0', port=5000, debug=False)
