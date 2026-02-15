#!/usr/bin/env python3
"""
Duplicate Media Cleanup Script - Project Mother

Finds and removes duplicate video files within a single library.
Groups by folder (movies) or S##E## (TV), scores each file, keeps the best.

Usage:
    # Local directories:
    python3 cleanup_duplicates.py /mnt/synology/rs-movies --type movies --dry-run
    python3 cleanup_duplicates.py /mnt/synology/rs-tv --type tv --dry-run
    python3 cleanup_duplicates.py /mnt/unraid/media/Movies --type movies --dry-run --deleted-dir "/mnt/unraid/media/Deleted Movies"
    python3 cleanup_duplicates.py "/mnt/unraid/media/TV Shows" --type tv --dry-run --deleted-dir "/mnt/unraid/media/Deleted TV"

    # Remote via SSH:
    python3 cleanup_duplicates.py --ssh root@192.168.1.10 "/mnt/user/media/TV Shows" --type tv --dry-run

Author: Project Mother
"""

import argparse
import csv
import os
import re
import subprocess
import sys
from collections import defaultdict
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple

# Add parent dir to path for lib imports
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lib.quality_scoring import (
    calculate_quality_score,
    parse_quality_from_filename,
    parse_episode_info,
)

VIDEO_EXTENSIONS = {'.mkv', '.mp4', '.avi', '.ts', '.m4v'}

# Directories to skip during scanning (recycle bins, trash, etc.)
EXCLUDED_DIRS = {'#recycle', '@eaDir', '.Trash', '.Trashes', '$RECYCLE.BIN', '@Recycle', 'lost+found'}


###############################################################################
# Data Structures
###############################################################################

class VideoFile:
    """Represents a video file with quality metadata."""

    def __init__(self, path: str, size_bytes: int = 0):
        self.path = path
        self.filename = os.path.basename(path)
        self.size_bytes = size_bytes
        self.size_gb = size_bytes / (1024**3) if size_bytes > 0 else 0.0

        # Parse quality from filename
        parsed = parse_quality_from_filename(self.filename)
        self.resolution = parsed['resolution']
        self.source = parsed['source']
        self.hdr = parsed['hdr']
        self.audio = parsed['audio']
        self.codec = parsed['codec']

        # If brackets didn't parse, try non-bracket patterns
        if not self.resolution:
            self.resolution = self._extract_resolution()
        if not self.source:
            self.source = self._extract_source()
        if not self.codec:
            self.codec = self._extract_codec()
        if not self.audio:
            self.audio = self._extract_audio()

    def _extract_resolution(self) -> str:
        for res in ('2160p', '1080p', '720p', '480p'):
            if res in self.filename:
                return res
        return ''

    def _extract_source(self) -> str:
        fn = self.filename
        if re.search(r'remux', fn, re.IGNORECASE):
            return 'Remux'
        if re.search(r'blu-?ray', fn, re.IGNORECASE):
            return 'BluRay'
        if re.search(r'web-?dl', fn, re.IGNORECASE):
            return 'WEB-DL'
        if re.search(r'webrip', fn, re.IGNORECASE):
            return 'WEBRip'
        if re.search(r'hdtv', fn, re.IGNORECASE):
            return 'HDTV'
        if re.search(r'dvdrip', fn, re.IGNORECASE):
            return 'DVDRip'
        return ''

    def _extract_codec(self) -> str:
        fn = self.filename.upper()
        if 'HEVC' in fn or 'H.265' in fn or 'H265' in fn or 'X265' in fn:
            return 'HEVC'
        if 'AVC' in fn or 'H.264' in fn or 'H264' in fn or 'X264' in fn:
            return 'AVC'
        if 'AV1' in fn:
            return 'AV1'
        return ''

    def _extract_audio(self) -> str:
        fn = self.filename.upper()
        if 'TRUEHD' in fn and 'ATMOS' in fn:
            return 'TrueHD Atmos'
        if 'TRUEHD' in fn:
            return 'TrueHD'
        if 'DTS-HD' in fn and 'MA' in fn:
            return 'DTS-HD MA'
        if 'DTS-X' in fn or 'DTSX' in fn:
            return 'DTS:X'
        if 'DTS-HD' in fn:
            return 'DTS-HD'
        if 'ATMOS' in fn:
            return 'Atmos'
        if 'EAC3' in fn or 'DDP' in fn or 'DD+' in fn or 'DDP5' in fn:
            return 'DD+'
        if re.search(r'\bDTS\b', fn):
            return 'DTS'
        if re.search(r'\bAC3\b', fn) or re.search(r'\bDD\b', fn):
            return 'DD'
        if 'AAC' in fn:
            return 'AAC'
        return ''

    def quality_score(self, media_type: str = 'movie', is_4k: bool = False) -> int:
        return calculate_quality_score(
            self.resolution, self.source, self.hdr,
            self.audio, self.codec, self.size_gb,
            is_4k=is_4k, media_type=media_type,
        )

    def quality_summary(self) -> str:
        parts = [p for p in [self.resolution, self.source, self.audio, self.hdr, self.codec] if p]
        return '/'.join(parts) if parts else 'Unknown'

    def __repr__(self):
        return f"VideoFile({self.filename}, {self.size_gb:.1f}GB, {self.quality_summary()})"


###############################################################################
# Scanning
###############################################################################

def scan_local(root_path: str) -> List[VideoFile]:
    """Scan a local directory for video files."""
    files = []
    root = Path(root_path)
    if not root.is_dir():
        print(f"ERROR: Directory not found: {root_path}")
        sys.exit(1)

    for dirpath, dirnames, filenames in os.walk(root_path):
        # Skip recycle bins and trash directories
        dirnames[:] = [d for d in dirnames if d not in EXCLUDED_DIRS]
        for fn in filenames:
            ext = os.path.splitext(fn)[1].lower()
            if ext in VIDEO_EXTENSIONS:
                full_path = os.path.join(dirpath, fn)
                try:
                    size = os.path.getsize(full_path)
                except OSError:
                    size = 0
                files.append(VideoFile(full_path, size))

    return files


def scan_ssh(ssh_target: str, remote_path: str) -> List[VideoFile]:
    """Scan a remote directory via SSH for video files."""
    # Use find to get file paths and sizes, excluding recycle/trash dirs
    ext_args = ' -o '.join(f'-name "*.{ext.lstrip(".")}"' for ext in VIDEO_EXTENSIONS)
    prune_args = ' -o '.join(f'-name "{d}" -prune' for d in EXCLUDED_DIRS)
    cmd = f'ssh {ssh_target} \'find "{remote_path}" \\( {prune_args} \\) -o -type f \\( {ext_args} \\) -printf "%s\\t%p\\n"\''

    print(f"Scanning remote {ssh_target}:{remote_path} ...")
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=300)
    except subprocess.TimeoutExpired:
        print("ERROR: SSH scan timed out after 5 minutes")
        sys.exit(1)

    if result.returncode != 0:
        print(f"ERROR: SSH scan failed: {result.stderr.strip()}")
        sys.exit(1)

    files = []
    for line in result.stdout.strip().split('\n'):
        if not line:
            continue
        parts = line.split('\t', 1)
        if len(parts) == 2:
            size_str, path = parts
            try:
                size = int(size_str)
            except ValueError:
                size = 0
            files.append(VideoFile(path, size))

    return files


###############################################################################
# Grouping
###############################################################################

def group_movies(files: List[VideoFile]) -> Dict[str, List[VideoFile]]:
    """Group video files by parent folder (each folder = one movie)."""
    groups = defaultdict(list)
    for f in files:
        folder = os.path.dirname(f.path)
        groups[folder].append(f)
    return groups


def group_tv_episodes(files: List[VideoFile]) -> Dict[str, List[VideoFile]]:
    """
    Group video files by show/season/episode.
    Key format: show_folder/Season NN/S##E##
    """
    groups = defaultdict(list)
    for f in files:
        season, first_ep, last_ep = parse_episode_info(f.filename)
        if season < 0:
            # Can't parse episode info - group by folder as fallback
            folder = os.path.dirname(f.path)
            groups[f"UNPARSED:{folder}"].append(f)
            continue

        # Get the show folder (two levels up from file: Show/Season/file.mkv)
        parent = os.path.dirname(f.path)
        grandparent = os.path.dirname(parent)
        show_folder = os.path.basename(grandparent)
        season_folder = os.path.basename(parent)

        # Index under first episode number
        ep_key = f"{show_folder}/{season_folder}/S{season:02d}E{first_ep:02d}"
        groups[ep_key].append(f)

    return groups


###############################################################################
# Duplicate Detection & Reporting
###############################################################################

def find_duplicates(groups: Dict[str, List[VideoFile]], media_type: str,
                    is_4k: bool = False) -> List[dict]:
    """
    Find groups with multiple files and determine which to keep/remove.

    Returns list of dicts with keys:
        group_key, keeper, removals (list), total_save_bytes
    """
    duplicates = []

    for key, files in groups.items():
        if len(files) <= 1:
            continue

        # Score each file
        scored = []
        for f in files:
            score = f.quality_score(media_type=media_type, is_4k=is_4k)
            scored.append((score, f))

        # Sort by score descending, then by size descending for tiebreak
        scored.sort(key=lambda x: (x[0], x[1].size_bytes), reverse=True)

        keeper_score, keeper = scored[0]
        removals = []
        total_save = 0
        for score, f in scored[1:]:
            removals.append({'file': f, 'score': score})
            total_save += f.size_bytes

        duplicates.append({
            'group_key': key,
            'keeper': keeper,
            'keeper_score': keeper_score,
            'removals': removals,
            'total_save_bytes': total_save,
        })

    return duplicates


def generate_reports(duplicates: List[dict], output_dir: str, media_type: str,
                     deleted_dir: Optional[str], use_delete: bool,
                     ssh_target: Optional[str]):
    """Generate human-readable report, CSV, and cleanup shell script."""
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    os.makedirs(output_dir, exist_ok=True)

    total_files_to_remove = sum(len(d['removals']) for d in duplicates)
    total_bytes_to_save = sum(d['total_save_bytes'] for d in duplicates)
    total_gb_to_save = total_bytes_to_save / (1024**3)

    # --- Human-readable report ---
    report_path = os.path.join(output_dir, f'cleanup_report_{timestamp}.txt')
    with open(report_path, 'w') as f:
        f.write("=" * 80 + "\n")
        f.write(f"DUPLICATE CLEANUP REPORT - {media_type.upper()}\n")
        f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write("=" * 80 + "\n\n")

        f.write(f"Groups with duplicates: {len(duplicates)}\n")
        f.write(f"Total files to remove:  {total_files_to_remove}\n")
        f.write(f"Total space to reclaim: {total_gb_to_save:.2f} GB\n\n")

        for d in sorted(duplicates, key=lambda x: x['group_key']):
            f.write("-" * 60 + "\n")
            f.write(f"Group: {d['group_key']}\n")
            keeper = d['keeper']
            f.write(f"  KEEP:   {keeper.filename}\n")
            f.write(f"          Score: {d['keeper_score']}  Quality: {keeper.quality_summary()}  Size: {keeper.size_gb:.2f}GB\n")
            for r in d['removals']:
                rf = r['file']
                f.write(f"  REMOVE: {rf.filename}\n")
                f.write(f"          Score: {r['score']}  Quality: {rf.quality_summary()}  Size: {rf.size_gb:.2f}GB\n")
            f.write(f"  Space saved: {d['total_save_bytes'] / (1024**3):.2f} GB\n\n")

    print(f"Report: {report_path}")

    # --- CSV ---
    csv_path = os.path.join(output_dir, f'cleanup_plan_{timestamp}.csv')
    with open(csv_path, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(['Group', 'Action', 'File', 'Score', 'Quality', 'Size_GB', 'Path'])
        for d in sorted(duplicates, key=lambda x: x['group_key']):
            keeper = d['keeper']
            writer.writerow([
                d['group_key'], 'KEEP', keeper.filename,
                d['keeper_score'], keeper.quality_summary(),
                f"{keeper.size_gb:.2f}", keeper.path,
            ])
            for r in d['removals']:
                rf = r['file']
                writer.writerow([
                    d['group_key'], 'REMOVE', rf.filename,
                    r['score'], rf.quality_summary(),
                    f"{rf.size_gb:.2f}", rf.path,
                ])

    print(f"CSV: {csv_path}")

    # --- Cleanup shell script ---
    script_path = os.path.join(output_dir, f'cleanup_actions_{timestamp}.sh')
    with open(script_path, 'w') as f:
        f.write("#!/bin/bash\n")
        f.write("#" + "=" * 78 + "\n")
        f.write(f"# Duplicate Cleanup Script - {media_type.upper()}\n")
        f.write(f"# Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"# Groups with duplicates: {len(duplicates)}\n")
        f.write(f"# Files to remove: {total_files_to_remove}\n")
        f.write(f"# Space to reclaim: {total_gb_to_save:.2f} GB\n")
        f.write("#\n")
        f.write("# Usage:\n")
        f.write(f"#   DRY_RUN=true ./{os.path.basename(script_path)}    # Preview (default)\n")
        f.write(f"#   DRY_RUN=false ./{os.path.basename(script_path)}   # Actually cleanup\n")
        f.write("#" + "=" * 78 + "\n\n")

        f.write('DRY_RUN="${DRY_RUN:-true}"\n')
        f.write('REMOVED=0\n')
        f.write('FAILED=0\n')
        f.write('SKIPPED=0\n\n')

        f.write('RED="\\033[0;31m"\n')
        f.write('GREEN="\\033[0;32m"\n')
        f.write('YELLOW="\\033[0;33m"\n')
        f.write('BLUE="\\033[0;34m"\n')
        f.write('NC="\\033[0m"\n\n')

        f.write('log() { echo -e "[$(date "+%Y-%m-%d %H:%M:%S")] $1"; }\n\n')

        f.write('cleanup_file() {\n')
        f.write('    local file="$1"\n')
        f.write('    local desc="$2"\n')

        if ssh_target:
            f.write(f'    local ssh_target="{ssh_target}"\n')
            f.write('    if [ "$DRY_RUN" = "true" ]; then\n')
            f.write('        log "${BLUE}[DRY RUN]${NC} Would remove: $desc"\n')
            f.write('        log "  $file"\n')
            f.write('        ((REMOVED++))\n')
            f.write('        return 0\n')
            f.write('    fi\n')
            if deleted_dir:
                f.write(f'    local deleted_dir="{deleted_dir}"\n')
                f.write('    if ssh "$ssh_target" "mkdir -p \\"$deleted_dir\\" && mv \\"$file\\" \\"$deleted_dir/\\""; then\n')
                f.write('        log "${GREEN}REMOVED${NC}: $desc"\n')
                f.write('        ((REMOVED++))\n')
                f.write('    else\n')
                f.write('        log "${RED}FAILED${NC}: $desc"\n')
                f.write('        ((FAILED++))\n')
                f.write('    fi\n')
            elif use_delete:
                f.write('    if ssh "$ssh_target" "rm -f \\"$file\\""; then\n')
                f.write('        log "${GREEN}REMOVED${NC}: $desc"\n')
                f.write('        ((REMOVED++))\n')
                f.write('    else\n')
                f.write('        log "${RED}FAILED${NC}: $desc"\n')
                f.write('        ((FAILED++))\n')
                f.write('    fi\n')
            else:
                f.write('    log "${YELLOW}SKIP${NC} No --deleted-dir or --delete specified: $desc"\n')
                f.write('    ((SKIPPED++))\n')
                f.write('    return 0\n')
        else:
            f.write('    if [ ! -e "$file" ]; then\n')
            f.write('        log "${YELLOW}SKIP${NC} [not found] $desc"\n')
            f.write('        ((SKIPPED++))\n')
            f.write('        return 0\n')
            f.write('    fi\n')
            f.write('    if [ "$DRY_RUN" = "true" ]; then\n')
            f.write('        log "${BLUE}[DRY RUN]${NC} Would remove: $desc"\n')
            f.write('        log "  $file"\n')
            f.write('        ((REMOVED++))\n')
            f.write('        return 0\n')
            f.write('    fi\n')
            if deleted_dir:
                f.write(f'    mkdir -p "{deleted_dir}"\n')
                f.write(f'    if mv "$file" "{deleted_dir}/"; then\n')
            elif use_delete:
                f.write('    if rm -f "$file"; then\n')
            else:
                f.write('    log "${YELLOW}SKIP${NC} No --deleted-dir or --delete specified: $desc"\n')
                f.write('    ((SKIPPED++))\n')
                f.write('    return 0\n')

            if deleted_dir or use_delete:
                f.write('        log "${GREEN}REMOVED${NC}: $desc"\n')
                f.write('        ((REMOVED++))\n')
                f.write('    else\n')
                f.write('        log "${RED}FAILED${NC}: $desc"\n')
                f.write('        ((FAILED++))\n')
                f.write('    fi\n')

        f.write('}\n\n')

        f.write('log "Starting duplicate cleanup..."\n')
        f.write('if [ "$DRY_RUN" = "true" ]; then\n')
        f.write('    log "${BLUE}DRY RUN MODE - no files will be modified${NC}"\n')
        f.write('fi\n')
        f.write('echo ""\n\n')

        for d in sorted(duplicates, key=lambda x: x['group_key']):
            keeper = d['keeper']
            f.write(f'# Group: {d["group_key"]}\n')
            f.write(f'# KEEP: {keeper.filename} (score: {d["keeper_score"]})\n')
            for r in d['removals']:
                rf = r['file']
                desc = f'{rf.filename} (score: {r["score"]} vs keeper {d["keeper_score"]})'
                escaped_path = rf.path.replace('"', '\\"')
                escaped_desc = desc.replace('"', '\\"')
                f.write(f'cleanup_file "{escaped_path}" "{escaped_desc}"\n')
            f.write('\n')

        f.write('echo ""\n')
        f.write('echo "========================================"\n')
        f.write('echo "CLEANUP SUMMARY"\n')
        f.write('echo "========================================"\n')
        f.write('echo "Removed: $REMOVED"\n')
        f.write('echo "Skipped: $SKIPPED"\n')
        f.write('echo "Failed:  $FAILED"\n')
        f.write('echo "========================================"\n')
        f.write('if [ "$DRY_RUN" = "true" ]; then\n')
        f.write('    echo "This was a DRY RUN - no files were modified"\n')
        f.write('    echo "Run with DRY_RUN=false to actually cleanup"\n')
        f.write('fi\n')

    os.chmod(script_path, 0o755)
    print(f"Script: {script_path}")

    return report_path, csv_path, script_path


###############################################################################
# Main
###############################################################################

def main():
    parser = argparse.ArgumentParser(
        description='Find and clean duplicate video files - Project Mother',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s /mnt/synology/rs-movies --type movies --dry-run
  %(prog)s /mnt/synology/rs-tv --type tv --dry-run
  %(prog)s /mnt/unraid/media/Movies --type movies --deleted-dir "/mnt/unraid/media/Deleted Movies"
  %(prog)s --ssh root@192.168.1.10 "/mnt/user/media/TV Shows" --type tv --dry-run
        """
    )
    parser.add_argument('path', help='Directory to scan for duplicates')
    parser.add_argument('--type', required=True, choices=['movies', 'tv'],
                        help='Media type: movies (group by folder) or tv (group by S##E##)')
    parser.add_argument('--dry-run', action='store_true', default=True,
                        help='Only report, do not generate destructive commands (default: true)')
    parser.add_argument('--deleted-dir',
                        help='Move duplicates here instead of deleting (safer)')
    parser.add_argument('--delete', action='store_true',
                        help='Generate rm commands instead of mv (use with caution)')
    parser.add_argument('--ssh',
                        help='SSH target for remote scan (e.g., root@192.168.1.10)')
    parser.add_argument('--4k', dest='is_4k', action='store_true',
                        help='Treat as 4K library (affects HDR scoring)')
    parser.add_argument('-o', '--output-dir', default=None,
                        help='Output directory for reports (default: reports/)')

    args = parser.parse_args()

    output_dir = args.output_dir or os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'reports'
    )

    print(f"Scanning: {args.path}")
    print(f"Type: {args.type}")
    print(f"4K: {args.is_4k}")
    print()

    # Scan
    if args.ssh:
        files = scan_ssh(args.ssh, args.path)
    else:
        files = scan_local(args.path)

    print(f"Found {len(files)} video files")

    if not files:
        print("No video files found. Nothing to do.")
        return

    # Group
    if args.type == 'movies':
        groups = group_movies(files)
    else:
        groups = group_tv_episodes(files)

    print(f"Grouped into {len(groups)} groups")

    # Find duplicates
    duplicates = find_duplicates(groups, media_type=args.type, is_4k=args.is_4k)

    total_removals = sum(len(d['removals']) for d in duplicates)
    total_save_gb = sum(d['total_save_bytes'] for d in duplicates) / (1024**3)

    print(f"\nDuplicate groups found: {len(duplicates)}")
    print(f"Files to remove: {total_removals}")
    print(f"Space to reclaim: {total_save_gb:.2f} GB")

    if not duplicates:
        print("\nNo duplicates found!")
        return

    # Generate reports
    print(f"\nGenerating reports in: {output_dir}")
    generate_reports(
        duplicates, output_dir, args.type,
        deleted_dir=args.deleted_dir,
        use_delete=args.delete,
        ssh_target=args.ssh,
    )

    print(f"\nDone! Review reports before running cleanup script.")


if __name__ == '__main__':
    main()
