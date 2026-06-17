#!/usr/bin/env python3
"""
USB Transfer Size Calculator - Project Mother

Parses sync scripts and calculates actual file/folder sizes for USB transfer planning.

Usage:
    # Movies Ali->Chris
    ./usb_calculate_sizes.py \
        --script ../reports/sync_actions_20260122_180402.sh \
        --direction ali-to-chris \
        --output ../reports/ali_to_chris_sizes.csv

    # TV Chris->Ali
    ./usb_calculate_sizes.py \
        --script ../reports/tv_sync_actions_20260122_180402.sh \
        --direction chris-to-ali \
        --output ../reports/chris_to_ali_tv_sizes.csv
"""

import os
import sys
import re
import csv
import argparse
from pathlib import Path
from typing import List, Tuple, Dict
from datetime import datetime


def format_size(size_bytes: int) -> str:
    """Format bytes to human readable size"""
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if size_bytes < 1024:
            return f"{size_bytes:.2f} {unit}"
        size_bytes /= 1024
    return f"{size_bytes:.2f} PB"


def get_folder_size(path: str) -> int:
    """Get total size of a file or folder"""
    try:
        if os.path.isfile(path):
            return os.path.getsize(path)

        total = 0
        for dirpath, dirnames, filenames in os.walk(path):
            for filename in filenames:
                filepath = os.path.join(dirpath, filename)
                try:
                    total += os.path.getsize(filepath)
                except (OSError, FileNotFoundError):
                    pass
        return total
    except (OSError, FileNotFoundError):
        return 0


def extract_movie_paths(script_path: str, direction: str) -> List[Tuple[str, str, str]]:
    """
    Extract source paths from movie sync script.

    Returns list of (source_path, dest_path, title) tuples
    """
    results = []

    # Pattern for movie script: run_cmd "Copy Ali->Chris: Title" rsync ... "source" "dest"
    if direction == 'ali-to-chris':
        pattern = r'run_cmd "Copy Ali->Chris: ([^"]+)" rsync [^"]*"([^"]+)" "([^"]+)"'
    else:  # chris-to-ali
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
    """
    Extract source paths from TV sync script.

    Returns list of (source_path, dest_path, title) tuples
    """
    results = []

    # Pattern for TV script: do_rsync "source" "dest" "description"
    pattern = r'do_rsync "([^"]+)" "([^"]+)" "([^"]+)"'

    with open(script_path, 'r') as f:
        for line in f:
            match = re.search(pattern, line)
            if match:
                source = match.group(1)
                dest = match.group(2)
                title = match.group(3)

                # Filter by direction based on source path
                if direction == 'ali-to-chris' and source.startswith('/mnt/unraid'):
                    results.append((source, dest, title))
                elif direction == 'chris-to-ali' and source.startswith('/mnt/synology'):
                    results.append((source, dest, title))

    return results


def calculate_sizes(paths: List[Tuple[str, str, str]], check_exists: bool = True) -> List[Dict]:
    """Calculate sizes for each path"""
    results = []
    total_size = 0
    exists_count = 0
    missing_count = 0

    for i, (source, dest, title) in enumerate(paths):
        if (i + 1) % 100 == 0:
            print(f"  Processing {i + 1}/{len(paths)}...", file=sys.stderr)

        size = 0
        exists = False

        if check_exists:
            if os.path.exists(source):
                size = get_folder_size(source)
                exists = True
                exists_count += 1
                total_size += size
            else:
                missing_count += 1

        results.append({
            'title': title,
            'source': source,
            'dest': dest,
            'size_bytes': size,
            'size_human': format_size(size),
            'exists': exists
        })

    return results, total_size, exists_count, missing_count


def main():
    parser = argparse.ArgumentParser(description='Calculate sizes for USB transfer')
    parser.add_argument('--script', required=True, help='Path to sync script')
    parser.add_argument('--direction', required=True, choices=['ali-to-chris', 'chris-to-ali'],
                        help='Transfer direction')
    parser.add_argument('--output', required=True, help='Output CSV path')
    parser.add_argument('--no-check', action='store_true',
                        help='Skip file existence check (just extract paths)')
    parser.add_argument('--limit', type=int, default=0,
                        help='Limit number of items to process (for testing)')

    args = parser.parse_args()

    # Determine script type (movie or TV) based on filename
    script_name = os.path.basename(args.script).lower()
    is_tv = 'tv_' in script_name or '_tv_' in script_name

    print(f"Parsing {'TV' if is_tv else 'Movie'} script: {args.script}")
    print(f"Direction: {args.direction}")

    # Extract paths
    if is_tv:
        paths = extract_tv_paths(args.script, args.direction)
    else:
        paths = extract_movie_paths(args.script, args.direction)

    print(f"Found {len(paths)} items to transfer")

    if args.limit > 0:
        paths = paths[:args.limit]
        print(f"Limited to {args.limit} items for testing")

    # Calculate sizes
    print("Calculating sizes...")
    results, total_size, exists_count, missing_count = calculate_sizes(
        paths,
        check_exists=not args.no_check
    )

    # Sort by size descending
    results.sort(key=lambda x: x['size_bytes'], reverse=True)

    # Write CSV
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)

    with open(output_path, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=['title', 'size_bytes', 'size_human', 'exists', 'source', 'dest'])
        writer.writeheader()
        writer.writerows(results)

    print(f"\nOutput written to: {args.output}")

    # Print summary
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print(f"Total items: {len(paths)}")

    if not args.no_check:
        print(f"Files found: {exists_count}")
        print(f"Files missing: {missing_count}")
        print(f"Total size: {format_size(total_size)}")
        print(f"Total size (bytes): {total_size:,}")

        # Show top 10 largest
        print("\nTop 10 largest items:")
        for item in results[:10]:
            if item['exists']:
                print(f"  {item['size_human']:>12}  {item['title']}")

    # Generate quick stats for planning
    print("\n" + "=" * 60)
    print("USB TRANSFER ESTIMATE")
    print("=" * 60)
    if total_size > 0:
        hours_300mbps = total_size / (300 * 1024 * 1024) / 3600
        print(f"At 300 MB/s: ~{hours_300mbps:.1f} hours")

        if total_size > 19.5 * 1024**4:  # 19.5 TB
            print(f"\n⚠️  WARNING: Total size ({format_size(total_size)}) exceeds 19.5 TB USB capacity!")
            print("   Will need to prioritize or make multiple trips.")


if __name__ == '__main__':
    main()
