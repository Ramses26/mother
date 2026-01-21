#!/usr/bin/env python3
"""
Sync Status Checker - Project Mother

Check the progress of batch sync scripts by analyzing:
1. The sync script itself (count total operations)
2. The progress file (count completed operations)
3. Show statistics and progress

Usage:
    ./sync_status.py <sync_script.sh>                    # Check status
    ./sync_status.py <sync_script.sh> --telegram         # Send status to Telegram
    ./sync_status.py <sync_script.sh> --json             # Output as JSON

Author: Project Mother
Last Updated: 2026-01-21
"""

import argparse
import hashlib
import json
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

    # Try to read from .env if not in environment
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
    """Send message to Telegram using curl (no dependencies)"""
    if not bot_token or not chat_id:
        bot_token, chat_id = get_telegram_config()

    if not bot_token or not chat_id:
        print("ERROR: Telegram credentials not configured")
        return False

    try:
        # Use curl to avoid requiring requests library
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
        print(f"ERROR: Failed to send Telegram message: {e}")
        return False


def extract_sync_operations_movies(script_path: Path) -> list:
    """
    Extract sync operations from movie sync script.
    Returns list of dicts with: description, hash, source, dest
    """
    operations = []

    with open(script_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Match run_cmd "description" rsync ... "source" "dest/"
    # Pattern: run_cmd "Copy Ali->Chris: TITLE" rsync -avhP "SOURCE" "DEST/"
    pattern = r'run_cmd "([^"]+)" rsync[^"]*"([^"]+)" "([^"]+)"'

    for match in re.finditer(pattern, content):
        desc = match.group(1)
        source = match.group(2)
        dest = match.group(3)

        # Calculate MD5 hash the same way the script does
        # The script uses: hash=$(echo "$@" | md5sum | cut -d" " -f1)
        # where "$@" is: rsync -avhP "source" "dest/"
        # We need to reconstruct this exactly
        cmd_string = f'rsync -avhP {source} {dest}'
        cmd_hash = hashlib.md5(cmd_string.encode()).hexdigest()

        operations.append({
            'description': desc,
            'hash': cmd_hash,
            'source': source,
            'dest': dest,
        })

    return operations


def extract_sync_operations_tv(script_path: Path) -> list:
    """
    Extract sync operations from TV sync script.
    Returns list of dicts with: description, hash, source, dest
    """
    operations = []

    with open(script_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # TV script uses: do_rsync "source" "dest" "description"
    # Hash is: echo "$src|$dst" | md5sum
    pattern = r'do_rsync "([^"]+)" "([^"]+)" "([^"]+)"'

    for match in re.finditer(pattern, content):
        source = match.group(1)
        dest = match.group(2)
        desc = match.group(3)

        # Calculate hash the same way TV script does
        cmd_string = f'{source}|{dest}'
        cmd_hash = hashlib.md5(cmd_string.encode()).hexdigest()

        operations.append({
            'description': desc,
            'hash': cmd_hash,
            'source': source,
            'dest': dest,
        })

    return operations


def extract_sync_operations(script_path: Path) -> list:
    """Detect script type and extract operations"""
    with open(script_path, 'r', encoding='utf-8') as f:
        first_lines = f.read(2000)

    if 'do_rsync' in first_lines:
        return extract_sync_operations_tv(script_path)
    else:
        return extract_sync_operations_movies(script_path)


def get_progress_file(script_path: Path) -> Path:
    """Determine the progress file path from the script"""
    with open(script_path, 'r', encoding='utf-8') as f:
        content = f.read(3000)

    # Look for PROGRESS_FILE definition
    match = re.search(r'PROGRESS_FILE="\$\{PROGRESS_FILE:-([^}]+)\}"', content)
    if match:
        progress_filename = match.group(1)
        # Progress file is usually in same directory or current working directory
        possible_paths = [
            script_path.parent / progress_filename,
            Path.cwd() / progress_filename,
            Path('/opt/mother') / progress_filename,
        ]
        for p in possible_paths:
            if p.exists():
                return p
        # Return the expected path even if it doesn't exist
        return script_path.parent / progress_filename

    return None


def read_progress_file(progress_path: Path) -> set:
    """Read completed hashes from progress file"""
    completed = set()
    if progress_path and progress_path.exists():
        with open(progress_path, 'r') as f:
            for line in f:
                line = line.strip()
                if line:
                    completed.add(line)
    return completed


def format_size(size_bytes: int) -> str:
    """Format bytes to human readable"""
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if size_bytes < 1024:
            return f"{size_bytes:.1f} {unit}"
        size_bytes /= 1024
    return f"{size_bytes:.1f} PB"


def calculate_status(operations: list, completed_hashes: set) -> dict:
    """Calculate sync status statistics"""
    total = len(operations)
    completed = sum(1 for op in operations if op['hash'] in completed_hashes)
    remaining = total - completed

    # Categorize by direction
    ali_to_chris = [op for op in operations if 'Ali->Chris' in op['description'] or 'Ali → Chris' in op['description']]
    chris_to_ali = [op for op in operations if 'Chris->Ali' in op['description'] or 'Chris → Ali' in op['description']]

    ali_to_chris_done = sum(1 for op in ali_to_chris if op['hash'] in completed_hashes)
    chris_to_ali_done = sum(1 for op in chris_to_ali if op['hash'] in completed_hashes)

    return {
        'total': total,
        'completed': completed,
        'remaining': remaining,
        'percent': (completed / total * 100) if total > 0 else 0,
        'ali_to_chris': {
            'total': len(ali_to_chris),
            'completed': ali_to_chris_done,
            'remaining': len(ali_to_chris) - ali_to_chris_done,
        },
        'chris_to_ali': {
            'total': len(chris_to_ali),
            'completed': chris_to_ali_done,
            'remaining': len(chris_to_ali) - chris_to_ali_done,
        },
    }


def get_running_processes(script_name: str) -> list:
    """Check if sync script is currently running"""
    try:
        result = subprocess.run(
            ['pgrep', '-af', script_name],
            capture_output=True, text=True, timeout=10
        )
        if result.returncode == 0:
            return [line for line in result.stdout.strip().split('\n') if line]
    except Exception:
        pass
    return []


def main():
    parser = argparse.ArgumentParser(
        description='Check batch sync progress - Project Mother'
    )
    parser.add_argument(
        'script',
        type=Path,
        help='Path to the sync script (e.g., sync_actions_20251231_171646_bw600.sh)'
    )
    parser.add_argument(
        '--progress-file', '-p',
        type=Path,
        help='Override progress file path'
    )
    parser.add_argument(
        '--telegram', '-t',
        action='store_true',
        help='Send status to Telegram'
    )
    parser.add_argument(
        '--json', '-j',
        action='store_true',
        help='Output as JSON'
    )
    parser.add_argument(
        '--list-remaining', '-l',
        action='store_true',
        help='List remaining (not completed) items'
    )
    parser.add_argument(
        '--limit',
        type=int,
        default=20,
        help='Limit number of items to list (default: 20)'
    )

    args = parser.parse_args()

    if not args.script.exists():
        print(f"ERROR: Script not found: {args.script}")
        sys.exit(1)

    # Extract operations from script
    operations = extract_sync_operations(args.script)
    if not operations:
        print(f"ERROR: No sync operations found in script")
        sys.exit(1)

    # Find and read progress file
    progress_file = args.progress_file or get_progress_file(args.script)
    completed_hashes = read_progress_file(progress_file)

    # Calculate status
    status = calculate_status(operations, completed_hashes)

    # Detect script type
    script_type = "TV Shows" if "tv_sync" in args.script.name.lower() else "Movies"

    # Check if script is running
    running = get_running_processes(args.script.name)

    # Prepare output
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    if args.json:
        output = {
            'timestamp': timestamp,
            'script': str(args.script),
            'progress_file': str(progress_file) if progress_file else None,
            'progress_file_exists': progress_file.exists() if progress_file else False,
            'type': script_type,
            'running': len(running) > 0,
            'status': status,
        }
        print(json.dumps(output, indent=2))
    else:
        print("=" * 60)
        print(f"PROJECT MOTHER - {script_type.upper()} SYNC STATUS")
        print("=" * 60)
        print(f"Timestamp: {timestamp}")
        print(f"Script: {args.script.name}")
        print(f"Progress file: {progress_file}")
        if progress_file:
            print(f"Progress file exists: {'Yes' if progress_file.exists() else 'No'}")
        print(f"Running: {'Yes' if running else 'No'}")
        print()

        print("-" * 40)
        print("OVERALL PROGRESS")
        print("-" * 40)
        bar_width = 30
        filled = int(bar_width * status['percent'] / 100)
        bar = '█' * filled + '░' * (bar_width - filled)
        print(f"[{bar}] {status['percent']:.1f}%")
        print(f"Completed: {status['completed']:,} / {status['total']:,}")
        print(f"Remaining: {status['remaining']:,}")
        print()

        print("-" * 40)
        print("BY DIRECTION")
        print("-" * 40)
        atc = status['ali_to_chris']
        cta = status['chris_to_ali']
        print(f"Ali → Chris: {atc['completed']:,} / {atc['total']:,} ({atc['remaining']:,} remaining)")
        print(f"Chris → Ali: {cta['completed']:,} / {cta['total']:,} ({cta['remaining']:,} remaining)")
        print()

    # List remaining items if requested
    if args.list_remaining:
        remaining_ops = [op for op in operations if op['hash'] not in completed_hashes]
        print("-" * 40)
        print(f"REMAINING ITEMS (showing first {min(args.limit, len(remaining_ops))})")
        print("-" * 40)
        for op in remaining_ops[:args.limit]:
            print(f"  - {op['description']}")
        if len(remaining_ops) > args.limit:
            print(f"  ... and {len(remaining_ops) - args.limit} more")
        print()

    # Send to Telegram if requested
    if args.telegram:
        running_status = "🟢 Running" if running else "🔴 Stopped"
        bar_width = 15
        filled = int(bar_width * status['percent'] / 100)
        bar = '█' * filled + '░' * (bar_width - filled)

        msg = f"""📊 *{script_type} Sync Status*

{running_status}

*Progress:* [{bar}] {status['percent']:.1f}%
✅ Completed: {status['completed']:,}
⏳ Remaining: {status['remaining']:,}
📁 Total: {status['total']:,}

*By Direction:*
→ Ali to Chris: {status['ali_to_chris']['completed']:,}/{status['ali_to_chris']['total']:,}
← Chris to Ali: {status['chris_to_ali']['completed']:,}/{status['chris_to_ali']['total']:,}

_{timestamp}_"""

        if send_telegram(msg):
            print("✅ Status sent to Telegram")
        else:
            print("❌ Failed to send to Telegram")


if __name__ == '__main__':
    main()
