#!/usr/bin/env python3
"""
Nightly Reconciliation Script - Project Mother

Compares source and destination directories to find missing files.
Runs as a cron job to catch any files that fell through the cracks.

Usage:
    python3 nightly_reconcile.py                    # Full reconciliation
    python3 nightly_reconcile.py --dry-run          # Preview only
    python3 nightly_reconcile.py --report-only      # Just send report, no sync
    python3 nightly_reconcile.py --library movies   # Only check movies
"""

import os
import sys
import argparse
import subprocess
import requests
from datetime import datetime
from pathlib import Path
from collections import defaultdict


def load_env_file(env_path=None):
    """Load environment variables from .env file"""
    if env_path is None:
        script_dir = Path(__file__).parent
        env_path = script_dir.parent / '.env'

    env_vars = {}
    if env_path.exists():
        with open(env_path, 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, value = line.split('=', 1)
                    env_vars[key.strip()] = value.strip()
    return env_vars


# Load from .env file
ENV = load_env_file()

# Configuration
TELEGRAM_BOT_TOKEN = ENV.get('TELEGRAM_BOT_TOKEN', '')
TELEGRAM_CHAT_ID = ENV.get('TELEGRAM_CHAT_ID', '')

# Library mappings: (source_path, dest_path, name)
LIBRARIES = {
    'movies': (
        '/mnt/synology/rs-movies',
        '/mnt/unraid/media/Movies',
        'Movies (HD)'
    ),
    'movies-4k': (
        '/mnt/synology/rs-4kmedia/4kmovies',
        '/mnt/unraid/media/4K Movies',
        '4K Movies'
    ),
    'tv': (
        '/mnt/synology/rs-tv',
        '/mnt/unraid/media/TV Shows',
        'TV Shows (HD)'
    ),
    'tv-4k': (
        '/mnt/synology/rs-4kmedia/4ktv',
        '/mnt/unraid/media/4K TV Shows',
        '4K TV Shows'
    ),
}


def log(msg, level='INFO'):
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print(f"[{timestamp}] [{level}] {msg}")


def send_telegram(message):
    """Send message via Telegram"""
    if not TELEGRAM_BOT_TOKEN or not TELEGRAM_CHAT_ID:
        log("Telegram not configured, skipping notification", 'WARN')
        return False

    try:
        url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"
        data = {
            'chat_id': TELEGRAM_CHAT_ID,
            'text': message,
            'parse_mode': 'Markdown'
        }
        response = requests.post(url, data=data, timeout=10)
        return response.ok
    except Exception as e:
        log(f"Telegram error: {e}", 'ERROR')
        return False


def get_media_folders(path):
    """Get list of media folders (movie or show folders)"""
    if not os.path.exists(path):
        return set()

    folders = set()
    for item in os.listdir(path):
        item_path = os.path.join(path, item)
        # Skip hidden files and system folders
        if item.startswith('.') or item.startswith('@') or item.startswith('#'):
            continue
        if os.path.isdir(item_path):
            folders.add(item)
    return folders


def get_video_files(path):
    """Get all video files in a directory tree"""
    video_extensions = {'.mkv', '.mp4', '.avi', '.m4v', '.mov', '.wmv', '.ts'}
    files = set()

    if not os.path.exists(path):
        return files

    for root, dirs, filenames in os.walk(path):
        # Skip hidden/system directories
        dirs[:] = [d for d in dirs if not d.startswith('.') and not d.startswith('@') and not d.startswith('#')]

        for filename in filenames:
            if any(filename.lower().endswith(ext) for ext in video_extensions):
                # Get relative path from base
                rel_path = os.path.relpath(os.path.join(root, filename), path)
                files.add(rel_path)

    return files


def compare_library(source, dest, name):
    """Compare source and destination libraries"""
    log(f"Comparing {name}...")

    if not os.path.exists(source):
        log(f"  Source not found: {source}", 'ERROR')
        return {'error': 'source_missing'}

    if not os.path.exists(dest):
        log(f"  Destination not found: {dest}", 'ERROR')
        return {'error': 'dest_missing'}

    # Get folder lists (for movies/shows)
    source_folders = get_media_folders(source)
    dest_folders = get_media_folders(dest)

    # Find missing folders
    missing_folders = source_folders - dest_folders

    # Get detailed file comparison
    source_files = get_video_files(source)
    dest_files = get_video_files(dest)

    missing_files = source_files - dest_files

    return {
        'name': name,
        'source': source,
        'dest': dest,
        'source_folder_count': len(source_folders),
        'dest_folder_count': len(dest_folders),
        'missing_folders': missing_folders,
        'missing_folder_count': len(missing_folders),
        'source_file_count': len(source_files),
        'dest_file_count': len(dest_files),
        'missing_files': missing_files,
        'missing_file_count': len(missing_files),
    }


def run_rsync(source, dest, dry_run=False):
    """Run rsync for a specific folder"""
    cmd = [
        'rsync', '-avh',
        '--ignore-existing',
        '--exclude', '#recycle',
        '--exclude', '@eaDir',
        '--exclude', '.DS_Store',
    ]

    if dry_run:
        cmd.append('--dry-run')

    cmd.extend([source + '/', dest + '/'])

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=3600
        )
        return result.returncode == 0, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return False, '', 'Timeout'
    except Exception as e:
        return False, '', str(e)


def main():
    parser = argparse.ArgumentParser(description='Nightly library reconciliation')
    parser.add_argument('--dry-run', action='store_true', help='Preview only')
    parser.add_argument('--report-only', action='store_true', help='Report only, no sync')
    parser.add_argument('--library', type=str, help='Specific library to check')
    parser.add_argument('--no-telegram', action='store_true', help='Skip Telegram notification')

    args = parser.parse_args()

    log("=" * 60)
    log("Nightly Reconciliation Started")
    log("=" * 60)

    # Determine which libraries to check
    if args.library:
        if args.library not in LIBRARIES:
            log(f"Unknown library: {args.library}", 'ERROR')
            log(f"Available: {', '.join(LIBRARIES.keys())}")
            return 1
        libs_to_check = {args.library: LIBRARIES[args.library]}
    else:
        libs_to_check = LIBRARIES

    # Compare libraries
    results = []
    total_missing_folders = 0
    total_missing_files = 0

    for lib_key, (source, dest, name) in libs_to_check.items():
        result = compare_library(source, dest, name)
        results.append(result)

        if 'error' not in result:
            total_missing_folders += result['missing_folder_count']
            total_missing_files += result['missing_file_count']

            log(f"  Source folders: {result['source_folder_count']}")
            log(f"  Dest folders: {result['dest_folder_count']}")
            log(f"  Missing folders: {result['missing_folder_count']}")
            log(f"  Missing files: {result['missing_file_count']}")

            if result['missing_folders'] and len(result['missing_folders']) <= 10:
                log(f"  Missing: {', '.join(list(result['missing_folders'])[:10])}")

    # Build report
    report_lines = [
        "📊 *Nightly Reconciliation Report*",
        f"📅 {datetime.now().strftime('%Y-%m-%d %H:%M')}",
        ""
    ]

    for result in results:
        if 'error' in result:
            report_lines.append(f"❌ {result.get('name', 'Unknown')}: Error - {result['error']}")
        else:
            status = "✅" if result['missing_folder_count'] == 0 else "⚠️"
            report_lines.append(
                f"{status} {result['name']}: "
                f"{result['dest_folder_count']}/{result['source_folder_count']} folders, "
                f"{result['missing_folder_count']} missing"
            )

    report_lines.append("")
    report_lines.append(f"📁 Total missing folders: {total_missing_folders}")
    report_lines.append(f"📄 Total missing files: {total_missing_files}")

    if args.report_only or args.dry_run:
        report_lines.append("")
        report_lines.append("ℹ️ _Report only - no sync performed_")

    report = "\n".join(report_lines)
    print("\n" + report)

    # Send Telegram notification
    if not args.no_telegram:
        send_telegram(report)

    # Sync missing folders if not report-only
    if not args.report_only and total_missing_folders > 0:
        log("")
        log("Starting sync of missing folders...")

        synced = 0
        failed = 0

        for result in results:
            if 'error' in result or not result['missing_folders']:
                continue

            source_base = result['source']
            dest_base = result['dest']

            for folder in result['missing_folders']:
                source_path = os.path.join(source_base, folder)
                log(f"Syncing: {folder}")

                success, stdout, stderr = run_rsync(source_path, dest_base, args.dry_run)

                if success:
                    log(f"  OK: {folder}")
                    synced += 1
                else:
                    log(f"  FAILED: {stderr[:100]}", 'ERROR')
                    failed += 1

        log("")
        log(f"Sync complete: {synced} synced, {failed} failed")

        # Send summary notification
        if not args.no_telegram and (synced > 0 or failed > 0):
            sync_msg = f"🔄 *Reconciliation Sync Complete*\n\n✅ Synced: {synced}\n❌ Failed: {failed}"
            if args.dry_run:
                sync_msg += "\n\n_DRY RUN - no files copied_"
            send_telegram(sync_msg)

    return 0


if __name__ == '__main__':
    sys.exit(main())
