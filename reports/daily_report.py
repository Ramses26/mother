#!/usr/bin/env python3
"""
Project Mother - Daily Report

Unified daily status report combining:
- Movies and TV sync progress
- VPN traffic statistics
- Error counts and health checks

Sends notifications via Apprise on Terminus (192.168.1.14:8000)

Usage:
    ./daily_report.py                    # Send report via Apprise
    ./daily_report.py --dry-run          # Print without sending
    ./daily_report.py --console          # Console output only
    ./daily_report.py --verbose          # Show debug info

Cron (8 AM daily):
    0 8 * * * /opt/mother/reports/daily_report.py >> /opt/mother/logs/daily_report.log 2>&1

Author: Project Mother
Last Updated: 2026-01-30
"""

import argparse
import os
import re
import subprocess
import sys
from datetime import datetime, timedelta
from pathlib import Path
from urllib.parse import urlencode
from urllib.request import Request, urlopen
from urllib.error import URLError


# =============================================================================
# Configuration
# =============================================================================

APPRISE_URL = "http://192.168.1.14:8000/notify/apprise"
APPRISE_TAG = "servers"

# Default paths (can be overridden via environment or arguments)
DEFAULT_SCRIPTS_DIR = Path("/opt/mother/reports")
DEFAULT_TRAFFIC_STATS = Path("/opt/mother/traffic_stats/snapshots.csv")

# Error threshold - only show warning if errors exceed this
ERROR_THRESHOLD = 0


# =============================================================================
# Utility Functions
# =============================================================================

def bytes_to_human(num_bytes: int) -> str:
    """Convert bytes to human readable format"""
    if num_bytes >= 1099511627776:  # TB
        return f"{num_bytes / 1099511627776:.2f} TB"
    elif num_bytes >= 1073741824:  # GB
        return f"{num_bytes / 1073741824:.2f} GB"
    elif num_bytes >= 1048576:  # MB
        return f"{num_bytes / 1048576:.2f} MB"
    else:
        return f"{num_bytes / 1024:.2f} KB"


def time_ago(dt: datetime) -> str:
    """Convert datetime to human-readable 'X ago' format"""
    now = datetime.now()
    diff = now - dt

    if diff.total_seconds() < 60:
        return "just now"
    elif diff.total_seconds() < 3600:
        mins = int(diff.total_seconds() / 60)
        return f"{mins}m ago"
    elif diff.total_seconds() < 86400:
        hours = int(diff.total_seconds() / 3600)
        return f"{hours}h ago"
    else:
        days = int(diff.total_seconds() / 86400)
        return f"{days}d ago"


def progress_bar(percent: float, width: int = 15) -> str:
    """Generate a text progress bar"""
    filled = int(width * percent / 100)
    return '\u2588' * filled + '\u2591' * (width - filled)


# =============================================================================
# Sync Status Functions
# =============================================================================

def find_sync_script(scripts_dir: Path, pattern: str) -> Path:
    """Find the most recent sync script matching pattern"""
    scripts = list(scripts_dir.glob(pattern))
    if not scripts:
        return None

    # Sort by modification time, most recent first
    scripts.sort(key=lambda p: p.stat().st_mtime, reverse=True)
    return scripts[0]


def get_progress_file(script_path: Path) -> Path:
    """Extract progress file path from sync script"""
    with open(script_path, 'r', encoding='utf-8') as f:
        content = f.read(3000)

    # Match: PROGRESS_FILE="${PROGRESS_FILE:-sync_progress_XXXXX.log}"
    match = re.search(r'PROGRESS_FILE="\$\{PROGRESS_FILE:-([^}]+)\}"', content)
    if match:
        progress_filename = match.group(1)
        progress_path = script_path.parent / progress_filename
        if progress_path.exists():
            return progress_path

    return None


def get_error_file(script_path: Path) -> Path:
    """Extract error log file path from sync script"""
    with open(script_path, 'r', encoding='utf-8') as f:
        content = f.read(3000)

    # Match: ERROR_LOG="${ERROR_LOG:-sync_errors_XXXXX.log}"
    match = re.search(r'ERROR_LOG="\$\{ERROR_LOG:-([^}]+)\}"', content)
    if match:
        error_filename = match.group(1)
        error_path = script_path.parent / error_filename
        if error_path.exists():
            return error_path

    return None


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
    # Support both old format (do_rsync) and new format (run_cmd ... rsync)
    matches_old = re.findall(r'do_rsync "[^"]+"', content)
    matches_new = re.findall(r'run_cmd "[^"]+" rsync', content)
    return len(matches_old) + len(matches_new)


def count_completed(progress_path: Path) -> int:
    """Count completed entries in progress file"""
    if not progress_path or not progress_path.exists():
        return 0
    with open(progress_path, 'r') as f:
        return sum(1 for line in f if line.strip())


def count_errors_today(error_path: Path) -> int:
    """Count errors logged today"""
    if not error_path or not error_path.exists():
        return 0

    today = datetime.now().strftime('%Y-%m-%d')
    count = 0
    with open(error_path, 'r') as f:
        for line in f:
            if today in line and 'ERROR' in line:
                count += 1
    return count


def is_script_running(script_name: str) -> bool:
    """Check if sync script is currently running"""
    try:
        result = subprocess.run(
            ['pgrep', '-f', script_name],
            capture_output=True, text=True, timeout=10
        )
        return result.returncode == 0
    except Exception:
        return False


def get_last_activity(progress_path: Path) -> datetime:
    """Get last modification time of progress file"""
    if not progress_path or not progress_path.exists():
        return None
    return datetime.fromtimestamp(progress_path.stat().st_mtime)


def get_sync_status(scripts_dir: Path, script_pattern: str, script_type: str) -> dict:
    """Get comprehensive sync status for a script type"""
    script = find_sync_script(scripts_dir, script_pattern)
    if not script:
        return None

    # Count operations based on script type
    if script_type == 'movie':
        total = count_operations_movies(script)
    else:
        total = count_operations_tv(script)

    progress_file = get_progress_file(script)
    error_file = get_error_file(script)

    completed = count_completed(progress_file)
    errors_today = count_errors_today(error_file)
    running = is_script_running(script.name)
    last_activity = get_last_activity(progress_file)

    remaining = max(0, total - completed)
    percent = (completed / total * 100) if total > 0 else 0

    return {
        'script': script.name,
        'total': total,
        'completed': completed,
        'remaining': remaining,
        'percent': percent,
        'running': running,
        'errors_today': errors_today,
        'last_activity': last_activity,
    }


# =============================================================================
# VPN Traffic Functions
# =============================================================================

def get_vpn_traffic(snapshots_file: Path) -> dict:
    """Get today's VPN traffic from snapshots CSV"""
    if not snapshots_file.exists():
        return None

    today = datetime.now().strftime('%Y-%m-%d')

    today_entries = []
    with open(snapshots_file, 'r') as f:
        # Skip header
        next(f, None)
        for line in f:
            parts = line.strip().split(',')
            if len(parts) >= 5 and parts[1] == today:
                today_entries.append({
                    'timestamp': int(parts[0]),
                    'to_unraid': int(parts[3]),
                    'from_unraid': int(parts[4]),
                })

    if len(today_entries) < 2:
        # Not enough data points for today
        return None

    first = today_entries[0]
    last = today_entries[-1]

    # Calculate daily transfer
    daily_to = last['to_unraid'] - first['to_unraid']
    daily_from = last['from_unraid'] - first['from_unraid']

    # Handle counter reset
    if daily_to < 0:
        daily_to = last['to_unraid']
    if daily_from < 0:
        daily_from = last['from_unraid']

    daily_total = daily_to + daily_from

    # Calculate average speed
    hours_elapsed = max(1, (last['timestamp'] - first['timestamp']) / 3600)
    avg_speed_bps = daily_total / (hours_elapsed * 3600)
    avg_speed_mbps = avg_speed_bps * 8 / 1_000_000

    # Max theoretical: 166 Mbps = ~1.79 TB/day
    max_daily_bytes = 166 * 1_000_000 / 8 * 86400
    utilization = (daily_total / max_daily_bytes * 100) if max_daily_bytes > 0 else 0

    return {
        'to_unraid': daily_to,
        'from_unraid': daily_from,
        'total': daily_total,
        'avg_speed_mbps': avg_speed_mbps,
        'utilization': utilization,
        'hours_tracked': hours_elapsed,
    }


# =============================================================================
# Notification Functions
# =============================================================================

def send_apprise(title: str, body: str, msg_type: str = "info") -> bool:
    """Send notification via Apprise on Terminus"""
    try:
        data = urlencode({
            'title': title,
            'body': body,
            'type': msg_type,
        }).encode('utf-8')

        url = f"{APPRISE_URL}?tag={APPRISE_TAG}"
        req = Request(url, data=data, method='POST')
        req.add_header('Content-Type', 'application/x-www-form-urlencoded')

        with urlopen(req, timeout=30) as response:
            return response.status == 200
    except URLError as e:
        print(f"ERROR: Failed to send Apprise notification: {e}")
        return False
    except Exception as e:
        print(f"ERROR: Unexpected error sending notification: {e}")
        return False


# =============================================================================
# Report Generation
# =============================================================================

def generate_report(scripts_dir: Path, snapshots_file: Path) -> tuple:
    """Generate the daily report content. Returns (title, body, type)"""

    now = datetime.now()
    timestamp = now.strftime('%Y-%m-%d %H:%M')

    # Get sync status
    movie_status = get_sync_status(scripts_dir, 'sync_actions_*.sh', 'movie')
    tv_status = get_sync_status(scripts_dir, 'tv_sync_actions_*.sh', 'tv')

    # Get VPN traffic
    vpn_traffic = get_vpn_traffic(snapshots_file)

    # Build report
    lines = [
        f"\U0001F4CA Project Mother - Daily Report",
        f"\U0001F4C5 {timestamp}",
        "",
    ]

    # Sync Progress Section
    total_errors = 0

    if movie_status or tv_status:
        lines.append("\u2501\u2501\u2501 Sync Progress \u2501\u2501\u2501")

        if movie_status:
            running_icon = "\U0001F7E2" if movie_status['running'] else "\U0001F534"
            bar = progress_bar(movie_status['percent'])
            activity = time_ago(movie_status['last_activity']) if movie_status['last_activity'] else "unknown"

            lines.append(f"\U0001F3AC Movies [{bar}] {movie_status['percent']:.1f}%")
            lines.append(f"   \u2705 {movie_status['completed']:,} / {movie_status['total']:,} | \u23F3 {movie_status['remaining']:,} left | {running_icon}")
            lines.append(f"   \u23F1\uFE0F Last activity: {activity}")
            total_errors += movie_status['errors_today']
            lines.append("")

        if tv_status:
            running_icon = "\U0001F7E2" if tv_status['running'] else "\U0001F534"
            bar = progress_bar(tv_status['percent'])
            activity = time_ago(tv_status['last_activity']) if tv_status['last_activity'] else "unknown"

            lines.append(f"\U0001F4FA TV Shows [{bar}] {tv_status['percent']:.1f}%")
            lines.append(f"   \u2705 {tv_status['completed']:,} / {tv_status['total']:,} | \u23F3 {tv_status['remaining']:,} left | {running_icon}")
            lines.append(f"   \u23F1\uFE0F Last activity: {activity}")
            total_errors += tv_status['errors_today']
            lines.append("")

    # VPN Traffic Section
    if vpn_traffic:
        lines.append("\u2501\u2501\u2501 VPN Traffic \u2501\u2501\u2501")
        lines.append(f"\U0001F4E4 {bytes_to_human(vpn_traffic['to_unraid'])} sent | \U0001F4E5 {bytes_to_human(vpn_traffic['from_unraid'])} received")
        lines.append(f"\U0001F4E6 {bytes_to_human(vpn_traffic['total'])} today | \u26A1 {vpn_traffic['avg_speed_mbps']:.1f} Mbps avg")
        lines.append(f"\U0001F4C8 {vpn_traffic['utilization']:.1f}% utilization ({vpn_traffic['hours_tracked']:.1f}h tracked)")
        lines.append("")

    # Health Section (only show if errors exceed threshold)
    if total_errors > ERROR_THRESHOLD:
        lines.append("\u2501\u2501\u2501 Health \u2501\u2501\u2501")
        lines.append(f"\u26A0\uFE0F {total_errors} error(s) today - check logs")
        lines.append("")

    # Overall Summary
    if movie_status and tv_status:
        total_completed = movie_status['completed'] + tv_status['completed']
        total_items = movie_status['total'] + tv_status['total']
        overall_percent = (total_completed / total_items * 100) if total_items > 0 else 0
        lines.append(f"\U0001F4C8 Overall: {total_completed:,}/{total_items:,} ({overall_percent:.1f}%)")
    elif movie_status:
        lines.append(f"\U0001F4C8 Overall: {movie_status['completed']:,}/{movie_status['total']:,} ({movie_status['percent']:.1f}%)")
    elif tv_status:
        lines.append(f"\U0001F4C8 Overall: {tv_status['completed']:,}/{tv_status['total']:,} ({tv_status['percent']:.1f}%)")

    title = "\U0001F4CA Project Mother - Daily Report"
    body = '\n'.join(lines)

    # Determine message type based on errors
    if total_errors > ERROR_THRESHOLD:
        msg_type = "warning"
    else:
        msg_type = "info"

    return title, body, msg_type


# =============================================================================
# Main
# =============================================================================

def main():
    parser = argparse.ArgumentParser(
        description='Project Mother - Daily Report'
    )
    parser.add_argument(
        '--scripts-dir', '-d',
        type=Path,
        default=DEFAULT_SCRIPTS_DIR,
        help='Directory containing sync scripts and progress files'
    )
    parser.add_argument(
        '--snapshots', '-s',
        type=Path,
        default=DEFAULT_TRAFFIC_STATS,
        help='Path to VPN traffic snapshots CSV'
    )
    parser.add_argument(
        '--dry-run', '-n',
        action='store_true',
        help='Print report but do not send notification'
    )
    parser.add_argument(
        '--console', '-c',
        action='store_true',
        help='Console output only, no notification'
    )
    parser.add_argument(
        '--verbose', '-v',
        action='store_true',
        help='Show debug information'
    )

    args = parser.parse_args()

    if args.verbose:
        print(f"Scripts directory: {args.scripts_dir}")
        print(f"Snapshots file: {args.snapshots}")
        print()

    # Generate report
    title, body, msg_type = generate_report(args.scripts_dir, args.snapshots)

    # Console output
    print("=" * 50)
    print(body)
    print("=" * 50)

    # Send notification
    if args.console:
        print("\nConsole mode - notification not sent")
    elif args.dry_run:
        print(f"\nDRY RUN - Would send as '{msg_type}' notification")
    else:
        print("\nSending notification via Apprise...")
        if send_apprise(title, body, msg_type):
            print("\u2705 Notification sent successfully")
            sys.exit(0)
        else:
            print("\u274C Failed to send notification")
            sys.exit(1)


if __name__ == '__main__':
    main()
