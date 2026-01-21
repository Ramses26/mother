#!/usr/bin/env python3
"""
Batch Sync Status Report - Project Mother

Send nightly Telegram status updates for batch sync operations.
This script checks both Movies and TV Shows sync progress and sends
a combined status report to Telegram.

Can be run via cron for nightly updates:
    0 21 * * * /opt/mother/scripts/batch_sync_report.py

Usage:
    ./batch_sync_report.py                    # Auto-detect scripts in /opt/mother
    ./batch_sync_report.py --scripts-dir /path/to/reports  # Specify location
    ./batch_sync_report.py --movie-script <path> --tv-script <path>  # Manual

Author: Project Mother
Last Updated: 2026-01-21
"""

import argparse
import hashlib
import os
import re
import subprocess
import sys
from datetime import datetime
from pathlib import Path


def get_telegram_config():
    """Get Telegram configuration from environment or .env file"""
    bot_token = os.environ.get('TELEGRAM_BOT_TOKEN', '')
    chat_id = os.environ.get('TELEGRAM_CHAT_ID', '')

    if not bot_token or not chat_id:
        env_files = [
            Path.home() / '.env',
            Path('/opt/mother/.env'),
            Path(__file__).parent.parent / '.env',
        ]
        for env_file in env_files:
            if env_file.exists():
                with open(env_file) as f:
                    for line in f:
                        line = line.strip()
                        if line.startswith('TELEGRAM_BOT_TOKEN='):
                            bot_token = line.split('=', 1)[1].strip('"\'')
                        elif line.startswith('TELEGRAM_CHAT_ID='):
                            chat_id = line.split('=', 1)[1].strip('"\'')

    return bot_token, chat_id


def send_telegram(message: str, bot_token: str = None, chat_id: str = None) -> bool:
    """Send message to Telegram using curl"""
    if not bot_token or not chat_id:
        bot_token, chat_id = get_telegram_config()

    if not bot_token or not chat_id:
        print("ERROR: Telegram credentials not configured")
        print("Set TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID environment variables")
        return False

    try:
        cmd = [
            'curl', '-s', '-X', 'POST',
            f'https://api.telegram.org/bot{bot_token}/sendMessage',
            '-d', f'chat_id={chat_id}',
            '-d', f'text={message}',
            '-d', 'parse_mode=Markdown'
        ]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        return result.returncode == 0
    except Exception as e:
        print(f"ERROR: Failed to send Telegram: {e}")
        return False


def count_operations_movies(script_path: Path) -> int:
    """Count sync operations in movie sync script"""
    with open(script_path, 'r', encoding='utf-8') as f:
        content = f.read()
    matches = re.findall(r'run_cmd "[^"]+" rsync', content)
    return len(matches)


def count_operations_tv(script_path: Path) -> int:
    """Count sync operations in TV sync script"""
    with open(script_path, 'r', encoding='utf-8') as f:
        content = f.read()
    matches = re.findall(r'do_rsync "[^"]+"', content)
    return len(matches)


def get_progress_file(script_path: Path) -> Path:
    """Determine progress file path from script"""
    with open(script_path, 'r', encoding='utf-8') as f:
        content = f.read(3000)

    match = re.search(r'PROGRESS_FILE="\$\{PROGRESS_FILE:-([^}]+)\}"', content)
    if match:
        progress_filename = match.group(1)
        possible_paths = [
            script_path.parent / progress_filename,
            Path.cwd() / progress_filename,
            Path('/opt/mother') / progress_filename,
        ]
        for p in possible_paths:
            if p.exists():
                return p
        return script_path.parent / progress_filename

    return None


def count_completed(progress_path: Path) -> int:
    """Count completed entries in progress file"""
    if not progress_path or not progress_path.exists():
        return 0
    with open(progress_path, 'r') as f:
        return sum(1 for line in f if line.strip())


def is_script_running(script_name: str) -> bool:
    """Check if sync script is currently running"""
    try:
        # Try exact script name first
        result = subprocess.run(
            ['pgrep', '-f', script_name],
            capture_output=True, text=True, timeout=10
        )
        if result.returncode == 0:
            return True

        # Also check for the base pattern (e.g., any tv_sync_actions running)
        if 'tv_sync' in script_name:
            result = subprocess.run(
                ['pgrep', '-f', 'tv_sync_actions.*\\.sh'],
                capture_output=True, text=True, timeout=10
            )
            return result.returncode == 0
        elif 'sync_actions' in script_name:
            # Check for movie sync scripts (but not tv_sync)
            result = subprocess.run(
                ['pgrep', '-af', 'sync_actions'],
                capture_output=True, text=True, timeout=10
            )
            if result.returncode == 0:
                # Make sure it's not a tv_sync
                for line in result.stdout.split('\n'):
                    if 'sync_actions' in line and 'tv_sync' not in line:
                        return True
        return False
    except Exception:
        return False


def find_script_with_progress(directory: Path, pattern: str) -> Path:
    """
    Find a script that has a matching progress file.
    Prefers scripts with existing progress files (actually being used).
    Falls back to most recent script if no progress files exist.
    """
    scripts = list(directory.glob(pattern))
    if not scripts:
        return None

    # Check each script for a matching progress file
    scripts_with_progress = []
    for script in scripts:
        progress_file = get_progress_file(script)
        if progress_file and progress_file.exists():
            # Get the number of entries in progress file
            with open(progress_file) as f:
                count = sum(1 for line in f if line.strip())
            scripts_with_progress.append((script, progress_file, count))

    # If we found scripts with progress files, use the one with most progress
    if scripts_with_progress:
        scripts_with_progress.sort(key=lambda x: x[2], reverse=True)
        return scripts_with_progress[0][0]

    # Fall back to most recent script
    scripts.sort(key=lambda p: p.stat().st_mtime, reverse=True)
    return scripts[0]


def get_status(script_path: Path, script_type: str) -> dict:
    """Get status for a sync script"""
    if not script_path or not script_path.exists():
        return None

    # Count operations
    if script_type == 'movie':
        total = count_operations_movies(script_path)
    else:
        total = count_operations_tv(script_path)

    # Get progress file and count completed
    progress_file = get_progress_file(script_path)
    completed = count_completed(progress_file)

    # Check if running
    running = is_script_running(script_path.name)

    # Calculate
    remaining = max(0, total - completed)
    percent = (completed / total * 100) if total > 0 else 0

    return {
        'script': script_path.name,
        'progress_file': str(progress_file) if progress_file else None,
        'total': total,
        'completed': completed,
        'remaining': remaining,
        'percent': percent,
        'running': running,
    }


def progress_bar(percent: float, width: int = 15) -> str:
    """Generate a text progress bar"""
    filled = int(width * percent / 100)
    return '█' * filled + '░' * (width - filled)


def main():
    parser = argparse.ArgumentParser(
        description='Batch Sync Status Report - Project Mother'
    )
    parser.add_argument(
        '--scripts-dir', '-d',
        type=Path,
        default=Path('/opt/mother'),
        help='Directory containing sync scripts and progress files'
    )
    parser.add_argument(
        '--movie-script', '-m',
        type=Path,
        help='Path to movie sync script'
    )
    parser.add_argument(
        '--tv-script', '-t',
        type=Path,
        help='Path to TV sync script'
    )
    parser.add_argument(
        '--quiet', '-q',
        action='store_true',
        help='Only output to Telegram, no console output'
    )
    parser.add_argument(
        '--dry-run', '-n',
        action='store_true',
        help='Print message but do not send to Telegram'
    )
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Show which scripts and progress files are being used'
    )

    args = parser.parse_args()

    # Find scripts
    movie_script = args.movie_script
    tv_script = args.tv_script

    if not movie_script:
        # Try common locations
        search_dirs = [
            args.scripts_dir,
            args.scripts_dir / 'reports',
            Path.cwd(),
            Path.cwd() / 'reports',
        ]
        for d in search_dirs:
            if d.exists():
                found = find_script_with_progress(d, 'sync_actions_*bw*.sh')
                if not found:
                    found = find_script_with_progress(d, 'sync_actions_*.sh')
                if found:
                    movie_script = found
                    break

    if not tv_script:
        for d in search_dirs:
            if d.exists():
                found = find_script_with_progress(d, 'tv_sync_actions_*.sh')
                if found:
                    tv_script = found
                    break

    # Verbose output
    if args.verbose:
        print("Scripts detected:")
        if movie_script:
            progress = get_progress_file(movie_script)
            print(f"  Movie: {movie_script}")
            print(f"         Progress: {progress}")
        else:
            print("  Movie: Not found")
        if tv_script:
            progress = get_progress_file(tv_script)
            print(f"  TV:    {tv_script}")
            print(f"         Progress: {progress}")
        else:
            print("  TV:    Not found")
        print()

    # Get status for each
    movie_status = get_status(movie_script, 'movie') if movie_script else None
    tv_status = get_status(tv_script, 'tv') if tv_script else None

    if not movie_status and not tv_status:
        print("ERROR: No sync scripts found")
        print(f"Searched in: {args.scripts_dir}")
        print("Use --movie-script and/or --tv-script to specify paths")
        sys.exit(1)

    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    # Build message
    msg_parts = ["📊 *DR Sync Nightly Status*", ""]

    if movie_status:
        running_icon = "🟢" if movie_status['running'] else "🔴"
        bar = progress_bar(movie_status['percent'])
        msg_parts.extend([
            f"*🎬 Movies* {running_icon}",
            f"[{bar}] {movie_status['percent']:.1f}%",
            f"✅ {movie_status['completed']:,} / {movie_status['total']:,}",
            f"⏳ {movie_status['remaining']:,} remaining",
            "",
        ])

    if tv_status:
        running_icon = "🟢" if tv_status['running'] else "🔴"
        bar = progress_bar(tv_status['percent'])
        msg_parts.extend([
            f"*📺 TV Shows* {running_icon}",
            f"[{bar}] {tv_status['percent']:.1f}%",
            f"✅ {tv_status['completed']:,} / {tv_status['total']:,}",
            f"⏳ {tv_status['remaining']:,} remaining",
            "",
        ])

    # Overall summary
    total_completed = (movie_status['completed'] if movie_status else 0) + (tv_status['completed'] if tv_status else 0)
    total_remaining = (movie_status['remaining'] if movie_status else 0) + (tv_status['remaining'] if tv_status else 0)
    grand_total = total_completed + total_remaining
    overall_percent = (total_completed / grand_total * 100) if grand_total > 0 else 0

    msg_parts.extend([
        f"*Overall:* {total_completed:,}/{grand_total:,} ({overall_percent:.1f}%)",
        f"_{timestamp}_",
    ])

    message = '\n'.join(msg_parts)

    # Console output
    if not args.quiet:
        print("=" * 50)
        print("PROJECT MOTHER - DR SYNC STATUS REPORT")
        print("=" * 50)
        print()

        if movie_status:
            status = "Running" if movie_status['running'] else "Stopped"
            print(f"Movies ({status}):")
            print(f"  Progress: {movie_status['percent']:.1f}%")
            print(f"  Completed: {movie_status['completed']:,}")
            print(f"  Remaining: {movie_status['remaining']:,}")
            print(f"  Total: {movie_status['total']:,}")
            print()

        if tv_status:
            status = "Running" if tv_status['running'] else "Stopped"
            print(f"TV Shows ({status}):")
            print(f"  Progress: {tv_status['percent']:.1f}%")
            print(f"  Completed: {tv_status['completed']:,}")
            print(f"  Remaining: {tv_status['remaining']:,}")
            print(f"  Total: {tv_status['total']:,}")
            print()

        print(f"Overall: {total_completed:,}/{grand_total:,} ({overall_percent:.1f}%)")
        print()

    # Send to Telegram
    if args.dry_run:
        print("DRY RUN - Would send message:")
        print("-" * 40)
        print(message)
        print("-" * 40)
    else:
        if send_telegram(message):
            if not args.quiet:
                print("✅ Status sent to Telegram")
            sys.exit(0)
        else:
            print("❌ Failed to send to Telegram")
            sys.exit(1)


if __name__ == '__main__':
    main()
