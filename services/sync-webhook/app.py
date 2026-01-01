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
from datetime import datetime
from flask import Flask, request, jsonify
import apprise

# Configuration from environment
TELEGRAM_BOT_TOKEN = os.environ.get('TELEGRAM_BOT_TOKEN', '')
TELEGRAM_CHAT_ID = os.environ.get('TELEGRAM_CHAT_ID', '')
DRY_RUN = os.environ.get('SYNC_DRY_RUN', 'false').lower() == 'true'
LOG_LEVEL = os.environ.get('SYNC_LOG_LEVEL', 'INFO')

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

# Setup logging
logging.basicConfig(
    level=getattr(logging, LOG_LEVEL),
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Setup Flask
app = Flask(__name__)

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


def translate_path(container_path: str) -> tuple:
    """
    Translate container path to source/destination NFS paths.

    Returns: (source_path, dest_path) or (None, None) if no mapping found
    """
    for container_base, (src_base, dst_base) in PATH_MAPPINGS.items():
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


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.now().isoformat(),
        'dry_run': DRY_RUN,
        'notifications': len(apobj) > 0
    })


@app.route('/test', methods=['POST', 'GET'])
def test_notification():
    """Test notification endpoint"""
    send_notification(
        title="Mother Sync Test",
        body="If you see this, notifications are working!",
        notify_type=apprise.NotifyType.SUCCESS
    )
    return jsonify({'status': 'notification sent'})


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
        quality = movie_file.get('quality', {}).get('quality', {}).get('name', 'Unknown')

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

        # Run rsync for the movie folder
        logger.info(f"Syncing: {source} -> {dest}")
        success, output, duration = run_rsync(source, dest, is_file=False)

        if success:
            msg = (
                f"*{title}* ({year})\n"
                f"Quality: {quality}\n"
                f"Size: {format_size(file_size)}\n"
                f"Duration: {duration:.1f}s"
            )
            if DRY_RUN:
                msg += "\n_(DRY RUN - no files copied)_"

            send_notification(
                title="Movie Synced",
                body=msg,
                notify_type=apprise.NotifyType.SUCCESS
            )
            return jsonify({'status': 'success', 'duration': duration})
        else:
            send_notification(
                title="Sync Failed - Movie",
                body=f"*{title}* ({year})\n\nError: {output[:500]}",
                notify_type=apprise.NotifyType.FAILURE
            )
            return jsonify({'status': 'failed', 'error': output}), 500

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
        quality = episode_file.get('quality', {}).get('quality', {}).get('name', 'Unknown')

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

        # For TV, sync the episode file specifically
        logger.info(f"Syncing: {source} -> {dest}")
        success, output, duration = run_rsync(source, dest, is_file=True)

        if success:
            msg = (
                f"*{series_title}*\n"
                f"{ep_string}: {ep_title}\n"
                f"Quality: {quality}\n"
                f"Size: {format_size(file_size)}\n"
                f"Duration: {duration:.1f}s"
            )
            if DRY_RUN:
                msg += "\n_(DRY RUN - no files copied)_"

            send_notification(
                title="Episode Synced",
                body=msg,
                notify_type=apprise.NotifyType.SUCCESS
            )
            return jsonify({'status': 'success', 'duration': duration})
        else:
            send_notification(
                title="Sync Failed - Episode",
                body=f"*{series_title}* - {ep_string}\n\nError: {output[:500]}",
                notify_type=apprise.NotifyType.FAILURE
            )
            return jsonify({'status': 'failed', 'error': output}), 500

    except Exception as e:
        logger.exception("Error processing Sonarr webhook")
        send_notification(
            title="Sync Error - Sonarr",
            body=f"Exception: {str(e)[:500]}",
            notify_type=apprise.NotifyType.FAILURE
        )
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
