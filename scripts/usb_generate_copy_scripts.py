#!/usr/bin/env python3
"""
USB Copy Script Generator - Project Mother

Generates rsync scripts for USB transfer operations based on existing sync scripts.

Creates 4 scripts:
1. usb_copy_ali_to_usb.sh     - Copy Ali's files TO the USB drive
2. usb_copy_usb_to_chris.sh   - Copy FROM USB to Chris's Synology
3. usb_copy_chris_to_usb.sh   - Copy Chris's files TO the USB drive
4. usb_copy_usb_to_ali.sh     - Copy FROM USB to Ali's Unraid

Usage:
    ./usb_generate_copy_scripts.py \
        --movie-script ../reports/sync_actions_20260122_180402.sh \
        --tv-script ../reports/tv_sync_actions_20260122_180402.sh \
        --output-dir ../reports/usb_scripts \
        --max-size 19.5T

    # Then at Ali's house:
    cd ../reports/usb_scripts
    ./usb_copy_ali_to_usb.sh /mnt/usb
"""

import os
import sys
import re
import argparse
from pathlib import Path
from datetime import datetime
from typing import List, Tuple, Dict


def extract_movie_paths(script_path: str, direction: str) -> List[Tuple[str, str, str]]:
    """Extract paths from movie sync script"""
    results = []

    if direction == 'ali-to-chris':
        pattern = r'run_cmd "Copy Ali->Chris: ([^"]+)" rsync [^"]*"([^"]+)" "([^"]+)"'
    else:
        pattern = r'run_cmd "Copy Chris->Ali: ([^"]+)" rsync [^"]*"([^"]+)" "([^"]+)"'

    with open(script_path, 'r') as f:
        for line in f:
            match = re.search(pattern, line)
            if match:
                title = match.group(1)
                source = match.group(2)
                dest = match.group(3)
                results.append((source, dest, title))

    return results


def extract_tv_paths(script_path: str, direction: str) -> List[Tuple[str, str, str]]:
    """Extract paths from TV sync script"""
    results = []
    pattern = r'do_rsync "([^"]+)" "([^"]+)" "([^"]+)"'

    with open(script_path, 'r') as f:
        for line in f:
            match = re.search(pattern, line)
            if match:
                source = match.group(1)
                dest = match.group(2)
                title = match.group(3)

                if direction == 'ali-to-chris' and source.startswith('/mnt/unraid'):
                    results.append((source, dest, title))
                elif direction == 'chris-to-ali' and source.startswith('/mnt/synology'):
                    results.append((source, dest, title))

    return results


def generate_script_header(title: str, direction: str) -> str:
    """Generate bash script header"""
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    return f'''#!/bin/bash
#==============================================================================
# {title}
# Project Mother - USB Transfer Script
#==============================================================================
# Generated: {timestamp}
# Direction: {direction}
#
# Usage:
#   ./{Path(title).stem}.sh /path/to/usb/mount
#
# Features:
#   - Progress tracking with resume capability
#   - Checksums for verification
#   - Detailed logging
#
#==============================================================================

set -o pipefail

USB_MOUNT="${{1:-/mnt/usb}}"
PROGRESS_FILE="usb_progress_{direction.replace('->', '_').replace(' ', '_')}.log"
ERROR_LOG="usb_errors_{direction.replace('->', '_').replace(' ', '_')}.log"
LOG_FILE="usb_transfer_{direction.replace('->', '_').replace(' ', '_')}.log"

# Colors
RED="\\033[0;31m"
GREEN="\\033[0;32m"
YELLOW="\\033[0;33m"
BLUE="\\033[0;34m"
NC="\\033[0m"

# Statistics
TOTAL=0
COMPLETED=0
SKIPPED=0
FAILED=0

log() {{
    local msg="[$(date "+%Y-%m-%d %H:%M:%S")] $1"
    echo -e "$msg"
    echo "$msg" >> "$LOG_FILE"
}}

log_error() {{
    local msg="[$(date "+%Y-%m-%d %H:%M:%S")] ERROR: $1"
    echo -e "${{RED}}$msg${{NC}}"
    echo "$msg" >> "$ERROR_LOG"
    echo "$msg" >> "$LOG_FILE"
}}

is_completed() {{
    grep -qF "$1" "$PROGRESS_FILE" 2>/dev/null
}}

mark_completed() {{
    echo "$1" >> "$PROGRESS_FILE"
}}

# Verify USB is mounted
if [ ! -d "$USB_MOUNT" ]; then
    echo -e "${{RED}}ERROR: USB mount not found at $USB_MOUNT${{NC}}"
    echo "Usage: $0 /path/to/usb/mount"
    exit 1
fi

# Check USB has write access
if ! touch "$USB_MOUNT/.write_test" 2>/dev/null; then
    echo -e "${{RED}}ERROR: Cannot write to USB mount $USB_MOUNT${{NC}}"
    exit 1
fi
rm -f "$USB_MOUNT/.write_test"

log "Starting USB transfer: {direction}"
log "USB mount: $USB_MOUNT"
log "Progress file: $PROGRESS_FILE"

# Run rsync for a single item
do_copy() {{
    local src="$1"
    local dst="$2"
    local desc="$3"
    local hash
    hash=$(echo "usb|$src|$dst" | md5sum | cut -d" " -f1)

    ((TOTAL++))

    if is_completed "$hash"; then
        log "${{YELLOW}}SKIP${{NC}} [already done] $desc"
        ((SKIPPED++))
        return 0
    fi

    if [ ! -e "$src" ]; then
        log "${{YELLOW}}SKIP${{NC}} [not found] $desc"
        mark_completed "$hash"
        ((SKIPPED++))
        return 0
    fi

    log "COPY: $desc"
    log "  From: $src"
    log "  To: $dst"

    # Ensure destination directory exists
    local dst_dir
    dst_dir=$(dirname "$dst")
    mkdir -p "$dst_dir"

    # rsync with progress, checksums, and resume support
    if rsync -avhP --checksum "$src" "$dst" 2>&1 | tee -a "$LOG_FILE"; then
        mark_completed "$hash"
        log "${{GREEN}}OK${{NC}}: $desc"
        ((COMPLETED++))
    else
        local exit_code=$?
        log_error "Failed (exit $exit_code): $desc"
        ((FAILED++))
    fi
}}

print_summary() {{
    log ""
    log "=============================================="
    log "TRANSFER SUMMARY"
    log "=============================================="
    log "Total items: $TOTAL"
    log "Completed: $COMPLETED"
    log "Skipped: $SKIPPED"
    log "Failed: $FAILED"
    log ""

    # Show USB space
    log "USB Space:"
    df -h "$USB_MOUNT" | tee -a "$LOG_FILE"
}}

trap print_summary EXIT

'''


def generate_ali_to_usb_script(movie_paths: List, tv_paths: List, output_dir: Path) -> str:
    """Generate script to copy Ali's files to USB"""
    script = generate_script_header("Copy Ali's Data TO USB", "ali-to-usb")

    script += '''
# =============================================================================
# MOVIES (Ali -> USB)
# =============================================================================
log "\\n=== COPYING MOVIES TO USB ==="

'''

    for source, dest, title in movie_paths:
        # USB structure: /mnt/usb/ali_to_chris/Movies/<folder>
        safe_title = title.replace('"', '\\"')
        folder_name = os.path.basename(source)
        usb_dest = f'$USB_MOUNT/ali_to_chris/Movies/{folder_name}'
        script += f'do_copy "{source}" "{usb_dest}" "Movie: {safe_title}"\n\n'

    script += '''
# =============================================================================
# TV SHOWS (Ali -> USB)
# =============================================================================
log "\\n=== COPYING TV SHOWS TO USB ==="

'''

    for source, dest, title in tv_paths:
        safe_title = title.replace('"', '\\"')
        # Preserve TV folder structure: Show/Season/episode
        # Source: /mnt/unraid/media/TV Shows/Show Name/Season XX/file.mkv
        # USB: /mnt/usb/ali_to_chris/TV Shows/Show Name/Season XX/file.mkv
        rel_path = source.replace('/mnt/unraid/media/TV Shows/', '')
        usb_dest = f'$USB_MOUNT/ali_to_chris/TV Shows/{rel_path}'
        script += f'do_copy "{source}" "{usb_dest}" "TV: {safe_title}"\n\n'

    script += '''
log "\\nTransfer complete!"
'''

    output_path = output_dir / 'usb_copy_ali_to_usb.sh'
    with open(output_path, 'w') as f:
        f.write(script)
    os.chmod(output_path, 0o755)

    return str(output_path)


def generate_usb_to_chris_script(movie_paths: List, tv_paths: List, output_dir: Path) -> str:
    """Generate script to copy from USB to Chris's Synology"""
    script = generate_script_header("Copy FROM USB to Chris's Synology", "usb-to-chris")

    script += '''
# =============================================================================
# MOVIES (USB -> Chris)
# =============================================================================
log "\\n=== COPYING MOVIES TO CHRIS ==="

'''

    for source, dest, title in movie_paths:
        safe_title = title.replace('"', '\\"')
        folder_name = os.path.basename(source)
        usb_source = f'$USB_MOUNT/ali_to_chris/Movies/{folder_name}'
        # dest should be Chris's path (/mnt/synology/rs-movies/)
        script += f'do_copy "{usb_source}" "{dest}" "Movie: {safe_title}"\n\n'

    script += '''
# =============================================================================
# TV SHOWS (USB -> Chris)
# =============================================================================
log "\\n=== COPYING TV SHOWS TO CHRIS ==="

'''

    for source, dest, title in tv_paths:
        safe_title = title.replace('"', '\\"')
        rel_path = source.replace('/mnt/unraid/media/TV Shows/', '')
        usb_source = f'$USB_MOUNT/ali_to_chris/TV Shows/{rel_path}'
        script += f'do_copy "{usb_source}" "{dest}" "TV: {safe_title}"\n\n'

    script += '''
log "\\nTransfer complete!"
'''

    output_path = output_dir / 'usb_copy_usb_to_chris.sh'
    with open(output_path, 'w') as f:
        f.write(script)
    os.chmod(output_path, 0o755)

    return str(output_path)


def generate_chris_to_usb_script(movie_paths: List, tv_paths: List, output_dir: Path) -> str:
    """Generate script to copy Chris's files to USB"""
    script = generate_script_header("Copy Chris's Data TO USB", "chris-to-usb")

    script += '''
# =============================================================================
# MOVIES (Chris -> USB)
# =============================================================================
log "\\n=== COPYING MOVIES TO USB ==="

'''

    for source, dest, title in movie_paths:
        safe_title = title.replace('"', '\\"')
        folder_name = os.path.basename(source)
        usb_dest = f'$USB_MOUNT/chris_to_ali/Movies/{folder_name}'
        script += f'do_copy "{source}" "{usb_dest}" "Movie: {safe_title}"\n\n'

    script += '''
# =============================================================================
# TV SHOWS (Chris -> USB)
# =============================================================================
log "\\n=== COPYING TV SHOWS TO USB ==="

'''

    for source, dest, title in tv_paths:
        safe_title = title.replace('"', '\\"')
        # Source: /mnt/synology/rs-tv/Show Name/Season XX/file.mkv
        rel_path = source.replace('/mnt/synology/rs-tv/', '')
        usb_dest = f'$USB_MOUNT/chris_to_ali/TV Shows/{rel_path}'
        script += f'do_copy "{usb_dest}" "{usb_dest}" "TV: {safe_title}"\n\n'

    script += '''
log "\\nTransfer complete!"
'''

    output_path = output_dir / 'usb_copy_chris_to_usb.sh'
    with open(output_path, 'w') as f:
        f.write(script)
    os.chmod(output_path, 0o755)

    return str(output_path)


def generate_usb_to_ali_script(movie_paths: List, tv_paths: List, output_dir: Path) -> str:
    """Generate script to copy from USB to Ali's Unraid"""
    script = generate_script_header("Copy FROM USB to Ali's Unraid", "usb-to-ali")

    script += '''
# =============================================================================
# MOVIES (USB -> Ali)
# =============================================================================
log "\\n=== COPYING MOVIES TO ALI ==="

'''

    for source, dest, title in movie_paths:
        safe_title = title.replace('"', '\\"')
        folder_name = os.path.basename(source)
        usb_source = f'$USB_MOUNT/chris_to_ali/Movies/{folder_name}'
        # dest should be Ali's path (/mnt/unraid/media/Movies/)
        script += f'do_copy "{usb_source}" "{dest}" "Movie: {safe_title}"\n\n'

    script += '''
# =============================================================================
# TV SHOWS (USB -> Ali)
# =============================================================================
log "\\n=== COPYING TV SHOWS TO ALI ==="

'''

    for source, dest, title in tv_paths:
        safe_title = title.replace('"', '\\"')
        rel_path = source.replace('/mnt/synology/rs-tv/', '')
        usb_source = f'$USB_MOUNT/chris_to_ali/TV Shows/{rel_path}'
        script += f'do_copy "{usb_source}" "{dest}" "TV: {safe_title}"\n\n'

    script += '''
log "\\nTransfer complete!"
'''

    output_path = output_dir / 'usb_copy_usb_to_ali.sh'
    with open(output_path, 'w') as f:
        f.write(script)
    os.chmod(output_path, 0o755)

    return str(output_path)


def main():
    parser = argparse.ArgumentParser(description='Generate USB copy scripts')
    parser.add_argument('--movie-script', required=True, help='Path to movie sync script')
    parser.add_argument('--tv-script', required=True, help='Path to TV sync script')
    parser.add_argument('--output-dir', required=True, help='Output directory for generated scripts')
    parser.add_argument('--max-size', default='19.5T', help='Max size for USB (e.g., 19.5T)')

    args = parser.parse_args()

    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    print(f"Parsing movie script: {args.movie_script}")
    print(f"Parsing TV script: {args.tv_script}")

    # Extract Ali->Chris paths
    ali_movies = extract_movie_paths(args.movie_script, 'ali-to-chris')
    ali_tv = extract_tv_paths(args.tv_script, 'ali-to-chris')

    # Extract Chris->Ali paths
    chris_movies = extract_movie_paths(args.movie_script, 'chris-to-ali')
    chris_tv = extract_tv_paths(args.tv_script, 'chris-to-ali')

    print(f"\nAli -> Chris: {len(ali_movies)} movies, {len(ali_tv)} TV episodes")
    print(f"Chris -> Ali: {len(chris_movies)} movies, {len(chris_tv)} TV episodes")

    # Generate scripts
    print("\nGenerating scripts...")

    script1 = generate_ali_to_usb_script(ali_movies, ali_tv, output_dir)
    print(f"  Created: {script1}")

    script2 = generate_usb_to_chris_script(ali_movies, ali_tv, output_dir)
    print(f"  Created: {script2}")

    script3 = generate_chris_to_usb_script(chris_movies, chris_tv, output_dir)
    print(f"  Created: {script3}")

    script4 = generate_usb_to_ali_script(chris_movies, chris_tv, output_dir)
    print(f"  Created: {script4}")

    print(f"\n✓ All scripts generated in: {output_dir}")

    # Print usage instructions
    print("""
=============================================================================
USAGE INSTRUCTIONS
=============================================================================

TRIP TO CHRIS:
1. At Ali's house, mount USB and run:
   cd {output_dir}
   ./usb_copy_ali_to_usb.sh /mnt/usb

2. At Chris's house, mount USB and run:
   ./usb_copy_usb_to_chris.sh /mnt/usb

RETURN FROM CHRIS:
3. At Chris's house, run:
   ./usb_copy_chris_to_usb.sh /mnt/usb

4. At Ali's house, run:
   ./usb_copy_usb_to_ali.sh /mnt/usb
""".format(output_dir=output_dir))


if __name__ == '__main__':
    main()
