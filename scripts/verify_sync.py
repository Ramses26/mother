#!/usr/bin/env python3
"""
Sync Verification Tool - Project Mother

Verifies that completed sync operations actually exist at their destinations.
Identifies:
1. Partial/incomplete transfers
2. Missing files that were marked as complete
3. Files that need to be re-synced

Can optionally remove entries from progress file so they will be re-synced.

Usage:
    ./verify_sync.py <sync_script.sh>                    # Verify all completed
    ./verify_sync.py <sync_script.sh> --fix              # Remove bad entries from progress
    ./verify_sync.py <sync_script.sh> --telegram         # Send report to Telegram

Author: Project Mother
Last Updated: 2026-01-21
"""

import argparse
import hashlib
import os
import re
import shutil
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


def extract_operations_movies(script_path: Path) -> list:
    """Extract sync operations from movie sync script"""
    operations = []

    with open(script_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Match run_cmd "description" rsync ... "source" "dest/"
    pattern = r'run_cmd "([^"]+)" rsync[^"]*"([^"]+)" "([^"]+)"'

    for match in re.finditer(pattern, content):
        desc = match.group(1)
        source = match.group(2)
        dest = match.group(3)

        # Calculate hash same as the script
        cmd_string = f'rsync -avhP {source} {dest}'
        cmd_hash = hashlib.md5(cmd_string.encode()).hexdigest()

        operations.append({
            'description': desc,
            'hash': cmd_hash,
            'source': source,
            'dest': dest,
        })

    return operations


def extract_operations_tv(script_path: Path) -> list:
    """Extract sync operations from TV sync script"""
    operations = []

    with open(script_path, 'r', encoding='utf-8') as f:
        content = f.read()

    pattern = r'do_rsync "([^"]+)" "([^"]+)" "([^"]+)"'

    for match in re.finditer(pattern, content):
        source = match.group(1)
        dest = match.group(2)
        desc = match.group(3)

        cmd_string = f'{source}|{dest}'
        cmd_hash = hashlib.md5(cmd_string.encode()).hexdigest()

        operations.append({
            'description': desc,
            'hash': cmd_hash,
            'source': source,
            'dest': dest,
        })

    return operations


def extract_operations(script_path: Path) -> list:
    """Detect script type and extract operations"""
    with open(script_path, 'r', encoding='utf-8') as f:
        first_lines = f.read(2000)

    if 'do_rsync' in first_lines:
        return extract_operations_tv(script_path)
    else:
        return extract_operations_movies(script_path)


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


def verify_file_exists(dest_path: str, source_path: str) -> dict:
    """
    Check if destination file/folder exists and is reasonable.

    For movies: source is a folder, dest is the parent library folder
                The movie folder should exist at dest/basename(source)
    For TV:     source is a file, dest is the containing folder
                The file should exist at dest
    """
    result = {
        'exists': False,
        'source_exists': False,
        'size_ok': True,
        'issue': None,
    }

    source = Path(source_path)
    dest = Path(dest_path.rstrip('/'))

    # Check source
    result['source_exists'] = source.exists()

    # Determine expected destination
    if source.is_dir():
        # Movie folder - should be at dest/movie_folder_name
        expected_dest = dest / source.name
    else:
        # TV file - dest already includes the path
        expected_dest = dest / source.name

    result['expected_dest'] = str(expected_dest)

    # Check if exists
    if expected_dest.exists():
        result['exists'] = True

        # For files, compare sizes
        if expected_dest.is_file() and source.exists() and source.is_file():
            src_size = source.stat().st_size
            dst_size = expected_dest.stat().st_size
            result['source_size'] = src_size
            result['dest_size'] = dst_size

            # Allow 1% tolerance for size differences
            if dst_size < src_size * 0.99:
                result['size_ok'] = False
                result['issue'] = f'Partial transfer: {dst_size:,} < {src_size:,} bytes'
        elif expected_dest.is_dir() and source.exists() and source.is_dir():
            # For directories, count files
            src_files = list(source.rglob('*'))
            dst_files = list(expected_dest.rglob('*'))
            src_media = [f for f in src_files if f.suffix.lower() in ('.mkv', '.mp4', '.avi', '.m4v')]
            dst_media = [f for f in dst_files if f.suffix.lower() in ('.mkv', '.mp4', '.avi', '.m4v')]

            if len(dst_media) < len(src_media):
                result['size_ok'] = False
                result['issue'] = f'Missing media files: {len(dst_media)} < {len(src_media)}'
    else:
        result['issue'] = f'Destination does not exist: {expected_dest}'

    return result


def verify_operations(operations: list, completed_hashes: set, limit: int = 0) -> dict:
    """
    Verify completed operations exist at destination.

    Returns dict with lists of:
    - verified: operations that are properly synced
    - missing: operations marked complete but file doesn't exist
    - partial: operations with incomplete/partial transfers
    - source_missing: operations where source no longer exists
    """
    results = {
        'verified': [],
        'missing': [],
        'partial': [],
        'source_missing': [],
    }

    completed_ops = [op for op in operations if op['hash'] in completed_hashes]

    if limit > 0:
        completed_ops = completed_ops[:limit]

    total = len(completed_ops)
    print(f"Verifying {total} completed operations...")

    for i, op in enumerate(completed_ops, 1):
        if i % 100 == 0:
            print(f"  Progress: {i}/{total} ({i*100//total}%)")

        try:
            check = verify_file_exists(op['dest'], op['source'])
            op['verification'] = check

            if not check['source_exists']:
                results['source_missing'].append(op)
            elif not check['exists']:
                results['missing'].append(op)
            elif not check['size_ok']:
                results['partial'].append(op)
            else:
                results['verified'].append(op)
        except Exception as e:
            op['verification'] = {'error': str(e)}
            results['missing'].append(op)

    return results


def remove_from_progress(progress_file: Path, hashes_to_remove: set, backup: bool = True):
    """Remove entries from progress file so they will be re-synced"""
    if not progress_file or not progress_file.exists():
        return False

    # Backup first
    if backup:
        backup_path = progress_file.with_suffix(f'.backup_{datetime.now().strftime("%Y%m%d_%H%M%S")}')
        shutil.copy(progress_file, backup_path)
        print(f"Backed up progress file to: {backup_path}")

    # Read current entries
    with open(progress_file, 'r') as f:
        current_hashes = set(line.strip() for line in f if line.strip())

    # Remove bad entries
    new_hashes = current_hashes - hashes_to_remove

    # Write back
    with open(progress_file, 'w') as f:
        for h in sorted(new_hashes):
            f.write(h + '\n')

    removed = len(current_hashes) - len(new_hashes)
    print(f"Removed {removed} entries from progress file")
    return True


def main():
    parser = argparse.ArgumentParser(
        description='Verify completed syncs - Project Mother'
    )
    parser.add_argument(
        'script',
        type=Path,
        help='Path to the sync script'
    )
    parser.add_argument(
        '--progress-file', '-p',
        type=Path,
        help='Override progress file path'
    )
    parser.add_argument(
        '--fix', '-f',
        action='store_true',
        help='Remove bad entries from progress file (will be re-synced)'
    )
    parser.add_argument(
        '--telegram', '-t',
        action='store_true',
        help='Send report to Telegram'
    )
    parser.add_argument(
        '--limit', '-l',
        type=int,
        default=0,
        help='Limit number of operations to verify (0=all)'
    )
    parser.add_argument(
        '--show-issues',
        action='store_true',
        help='Show details of issues found'
    )

    args = parser.parse_args()

    if not args.script.exists():
        print(f"ERROR: Script not found: {args.script}")
        sys.exit(1)

    # Extract operations
    print(f"Extracting operations from: {args.script}")
    operations = extract_operations(args.script)
    print(f"Found {len(operations)} total operations")

    # Get progress file
    progress_file = args.progress_file or get_progress_file(args.script)
    if not progress_file:
        print("ERROR: Could not determine progress file")
        sys.exit(1)

    if not progress_file.exists():
        print(f"Progress file not found: {progress_file}")
        print("No completed operations to verify.")
        sys.exit(0)

    # Read completed hashes
    completed_hashes = read_progress_file(progress_file)
    print(f"Progress file: {progress_file}")
    print(f"Completed entries in progress file: {len(completed_hashes)}")

    # Verify operations
    results = verify_operations(operations, completed_hashes, args.limit)

    # Print report
    print()
    print("=" * 60)
    print("VERIFICATION RESULTS")
    print("=" * 60)
    print(f"Verified OK:      {len(results['verified']):,}")
    print(f"Missing at dest:  {len(results['missing']):,}")
    print(f"Partial transfer: {len(results['partial']):,}")
    print(f"Source missing:   {len(results['source_missing']):,}")
    print()

    issues = results['missing'] + results['partial']
    issues_need_resync = len(issues)

    if issues_need_resync > 0:
        print(f"⚠️  {issues_need_resync} operations need to be re-synced!")

        if args.show_issues:
            print()
            print("-" * 40)
            print("ISSUES FOUND")
            print("-" * 40)
            for op in issues[:20]:
                print(f"  - {op['description']}")
                if 'verification' in op and op['verification'].get('issue'):
                    print(f"    Issue: {op['verification']['issue']}")
            if len(issues) > 20:
                print(f"  ... and {len(issues) - 20} more")

        if args.fix:
            print()
            hashes_to_remove = {op['hash'] for op in issues}
            remove_from_progress(progress_file, hashes_to_remove)
            print()
            print("✅ Progress file updated. Re-run the sync script to sync these files.")
    else:
        print("✅ All verified operations look good!")

    # Send to Telegram
    if args.telegram:
        script_type = "TV Shows" if "tv_sync" in args.script.name.lower() else "Movies"
        status_emoji = "✅" if issues_need_resync == 0 else "⚠️"

        msg = f"""{status_emoji} *{script_type} Sync Verification*

Checked: {len(results['verified']) + len(issues):,} completed items

✅ Verified OK: {len(results['verified']):,}
❌ Missing: {len(results['missing']):,}
⚠️ Partial: {len(results['partial']):,}

{"✅ All syncs verified!" if issues_need_resync == 0 else f"⚠️ {issues_need_resync} items need re-sync"}

_{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}_"""

        if send_telegram(msg):
            print("✅ Report sent to Telegram")
        else:
            print("❌ Failed to send to Telegram")


if __name__ == '__main__':
    main()
