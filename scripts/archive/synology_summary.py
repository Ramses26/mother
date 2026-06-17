#!/usr/bin/env python3
"""
Synology Library Summary - Project Mother

Reads inventory JSON files (from generate_inventory.py) and prints a
comprehensive quality + file-type breakdown for each library and combined.

Also does a raw filesystem scan to find non-media files (subtitles, extras,
cruft) that inventories don't capture.

Usage:
    python3 synology_summary.py inventory1.json [inventory2.json ...]
    python3 synology_summary.py --all   # auto-load all chris_*.json inventories
    python3 synology_summary.py --scan-extras /mnt/synology/rs-movies  # filesystem scan

Output: stdout + /opt/mother/reports/synology_summary_TIMESTAMP.txt
"""

import argparse
import json
import os
import sys
from collections import defaultdict
from datetime import datetime
from pathlib import Path


REPORTS_DIR = Path("/opt/mother/reports")
INVENTORIES_DIR = Path("/opt/mother/inventories")

VIDEO_EXTENSIONS = {'.mkv', '.mp4', '.avi', '.ts', '.m4v', '.mov', '.wmv', '.flv', '.webm', '.iso'}

# Ordered display tiers
RESOLUTION_ORDER = ['2160p', '1080p', '720p', '576p', '480p', 'Unknown']
SOURCE_ORDER = ['Remux', 'BluRay', 'WEB-DL', 'WEBRip', 'HDTV', 'DVD', 'HDDVD', 'Unknown']
CODEC_ORDER = ['H.265', 'H.264', 'AV1', 'VC-1', 'MPEG-2', 'Unknown']
AUDIO_ORDER = ['Atmos', 'TrueHD', 'DTS-HD MA', 'DTS-X', 'DTS', 'DD+', 'DD', 'AAC', 'MP3', 'Unknown']
HDR_ORDER = ['DV HDR10', 'HDR10+', 'HDR10', 'HDR', 'DV', 'HLG', 'SDR', 'Unknown']


def normalise_audio(raw: str) -> str:
    if not raw:
        return 'Unknown'
    r = raw.upper()
    if 'ATMOS' in r:
        return 'Atmos'
    if 'TRUEHD' in r or 'TRUE-HD' in r:
        return 'TrueHD'
    if 'DTS-HD' in r and ('MA' in r or 'MASTER' in r):
        return 'DTS-HD MA'
    if 'DTS:X' in r or 'DTS-X' in r:
        return 'DTS-X'
    if 'DTS' in r:
        return 'DTS'
    if 'EAC3' in r or 'E-AC-3' in r or 'DD+' in r or 'DDPLUS' in r:
        return 'DD+'
    if 'AC3' in r or ' DD' in r or r == 'DD':
        return 'DD'
    if 'AAC' in r:
        return 'AAC'
    if 'MP3' in r:
        return 'MP3'
    return raw or 'Unknown'


def normalise_hdr(raw: str) -> str:
    if not raw:
        return 'SDR'
    r = raw.upper()
    if 'DV' in r and 'HDR10' in r:
        return 'DV HDR10'
    if 'HDR10+' in r:
        return 'HDR10+'
    if 'HDR10' in r:
        return 'HDR10'
    if 'DV' in r or 'DOLBY VISION' in r:
        return 'DV'
    if 'HLG' in r:
        return 'HLG'
    if 'HDR' in r:
        return 'HDR'
    return 'SDR'


def normalise_codec(raw: str) -> str:
    if not raw:
        return 'Unknown'
    r = raw.upper()
    if 'H.265' in r or 'HEVC' in r or 'X265' in r or 'H265' in r:
        return 'H.265'
    if 'H.264' in r or 'AVC' in r or 'X264' in r or 'H264' in r:
        return 'H.264'
    if 'AV1' in r:
        return 'AV1'
    if 'VC-1' in r or 'VC1' in r:
        return 'VC-1'
    if 'MPEG-2' in r or 'MPEG2' in r:
        return 'MPEG-2'
    return raw or 'Unknown'


def load_inventory(path: str) -> list:
    with open(path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    if isinstance(data, list):
        return data
    # Some inventories may be wrapped
    return data.get('files', data.get('inventory', []))


def bucket(items, key_fn, gb_fn, order):
    counts = defaultdict(int)
    gbs = defaultdict(float)
    for item in items:
        k = key_fn(item) or 'Unknown'
        counts[k] += 1
        gbs[k] += gb_fn(item)

    rows = []
    seen = set()
    for k in order:
        if k in counts:
            rows.append((k, counts[k], gbs[k]))
            seen.add(k)
    # Any unlisted keys
    for k in sorted(counts):
        if k not in seen:
            rows.append((k, counts[k], gbs[k]))
    return rows


def fmt_table(rows, col1='Category', col2='Count', col3='Size (GB)', width1=18):
    """Format a 3-column table."""
    lines = []
    lines.append(f"  {'─' * (width1 + 26)}")
    lines.append(f"  {col1:<{width1}}  {col2:>7}  {col3:>10}")
    lines.append(f"  {'─' * (width1 + 26)}")
    for name, count, gb in rows:
        lines.append(f"  {name:<{width1}}  {count:>7,}  {gb:>9.1f} GB")
    lines.append(f"  {'─' * (width1 + 26)}")
    return '\n'.join(lines)


def summarise_library(items: list, label: str) -> str:
    """Generate a full quality breakdown for a list of inventory items."""
    out = []
    total_files = len(items)
    total_gb = sum(i.get('size_gb', 0) or 0 for i in items)

    out.append(f"\n{'=' * 60}")
    out.append(f"  {label}")
    out.append(f"  {total_files:,} files  |  {total_gb:.1f} GB total")
    out.append(f"{'=' * 60}")

    # Resolution
    out.append("\nResolution:")
    rows = bucket(items,
                  lambda i: i.get('resolution') or 'Unknown',
                  lambda i: i.get('size_gb', 0) or 0,
                  RESOLUTION_ORDER)
    out.append(fmt_table(rows))

    # Source
    out.append("\nSource:")
    rows = bucket(items,
                  lambda i: i.get('source') or 'Unknown',
                  lambda i: i.get('size_gb', 0) or 0,
                  SOURCE_ORDER)
    out.append(fmt_table(rows))

    # Video codec
    out.append("\nVideo Codec:")
    rows = bucket(items,
                  lambda i: normalise_codec(i.get('video_codec', '')),
                  lambda i: i.get('size_gb', 0) or 0,
                  CODEC_ORDER)
    out.append(fmt_table(rows))

    # Audio codec
    out.append("\nAudio Codec:")
    rows = bucket(items,
                  lambda i: normalise_audio(i.get('audio_codec', '')),
                  lambda i: i.get('size_gb', 0) or 0,
                  AUDIO_ORDER)
    out.append(fmt_table(rows))

    # HDR
    out.append("\nHDR Format:")
    rows = bucket(items,
                  lambda i: normalise_hdr(i.get('hdr', '')),
                  lambda i: i.get('size_gb', 0) or 0,
                  HDR_ORDER)
    out.append(fmt_table(rows))

    # File extension
    out.append("\nFile Extension:")
    ext_order = ['.mkv', '.mp4', '.avi', '.ts', '.m4v', '.iso', '.mov', '.wmv', 'Unknown']
    rows = bucket(items,
                  lambda i: Path(i.get('filename', '')).suffix.lower() or 'Unknown',
                  lambda i: i.get('size_gb', 0) or 0,
                  ext_order)
    out.append(fmt_table(rows, col1='Extension'))

    return '\n'.join(out)


def scan_non_media(root_paths: list) -> str:
    """
    Walk filesystem paths and report non-media files by extension + size.
    Groups into categories: subtitles, images, archives, docs, audio, unknown.
    """
    EXCLUDED_DIRS = {'#recycle', '@eaDir', '.Trash', '.Trashes', '$RECYCLE.BIN',
                     '@Recycle', 'lost+found', '@tmp'}

    subtitle_exts = {'.srt', '.sub', '.idx', '.ass', '.ssa', '.vtt', '.sup', '.pgs'}
    image_exts = {'.jpg', '.jpeg', '.png', '.bmp', '.gif', '.tiff', '.webp', '.nfo', '.xml'}
    archive_exts = {'.zip', '.rar', '.7z', '.tar', '.gz', '.bz2'}
    audio_exts = {'.mp3', '.flac', '.m4a', '.aac', '.ogg', '.wav', '.opus'}
    doc_exts = {'.txt', '.pdf', '.doc', '.docx', '.nfo', '.xml', '.json', '.csv'}
    torrent_exts = {'.torrent', '.nzb'}

    by_ext = defaultdict(lambda: {'count': 0, 'bytes': 0})
    skipped_roots = []

    for root_path in root_paths:
        if not os.path.isdir(root_path):
            skipped_roots.append(root_path)
            continue
        for dirpath, dirnames, filenames in os.walk(root_path):
            # Prune excluded dirs in-place
            dirnames[:] = [d for d in dirnames if d not in EXCLUDED_DIRS]
            for fname in filenames:
                ext = Path(fname).suffix.lower()
                if ext in VIDEO_EXTENSIONS:
                    continue  # already counted in inventory
                fpath = os.path.join(dirpath, fname)
                try:
                    size = os.path.getsize(fpath)
                except OSError:
                    size = 0
                by_ext[ext or '(no ext)']['count'] += 1
                by_ext[ext or '(no ext)']['bytes'] += size

    if not by_ext and not skipped_roots:
        return "  (no non-media files found)\n"

    # Group by category
    categories = {
        'Subtitles': subtitle_exts,
        'Images/NFO': image_exts,
        'Archives': archive_exts,
        'Audio': audio_exts,
        'Documents': doc_exts,
        'Torrents/NZB': torrent_exts,
    }

    cat_totals = defaultdict(lambda: {'count': 0, 'bytes': 0, 'exts': defaultdict(lambda: {'count': 0, 'bytes': 0})})
    other = {'count': 0, 'bytes': 0, 'exts': defaultdict(lambda: {'count': 0, 'bytes': 0})}

    for ext, stats in by_ext.items():
        matched = False
        for cat_name, cat_exts in categories.items():
            if ext in cat_exts:
                cat_totals[cat_name]['count'] += stats['count']
                cat_totals[cat_name]['bytes'] += stats['bytes']
                cat_totals[cat_name]['exts'][ext]['count'] += stats['count']
                cat_totals[cat_name]['exts'][ext]['bytes'] += stats['bytes']
                matched = True
                break
        if not matched:
            other['count'] += stats['count']
            other['bytes'] += stats['bytes']
            other['exts'][ext]['count'] += stats['count']
            other['exts'][ext]['bytes'] += stats['bytes']

    out = []
    grand_count = sum(s['count'] for s in by_ext.values())
    grand_gb = sum(s['bytes'] for s in by_ext.values()) / (1024 ** 3)

    out.append(f"\n{'=' * 60}")
    out.append(f"  Non-Media Files (filesystem scan)")
    out.append(f"  {grand_count:,} files  |  {grand_gb:.2f} GB total")
    out.append(f"{'=' * 60}")

    if skipped_roots:
        out.append(f"  WARNING: Paths not found: {', '.join(skipped_roots)}")

    for cat_name in list(categories.keys()) + ['Other']:
        if cat_name == 'Other':
            data = other
        else:
            data = cat_totals.get(cat_name)
        if not data or data['count'] == 0:
            continue
        gb = data['bytes'] / (1024 ** 3)
        out.append(f"\n  {cat_name}: {data['count']:,} files, {gb:.2f} GB")
        # Show top extensions within category
        ext_rows = sorted(data['exts'].items(), key=lambda x: x[1]['bytes'], reverse=True)
        for ext, es in ext_rows[:8]:
            egb = es['bytes'] / (1024 ** 3)
            out.append(f"    {ext:<12}  {es['count']:>6,}  {egb:>8.2f} GB")

    return '\n'.join(out)


def main():
    parser = argparse.ArgumentParser(
        description='Synology Library Summary - Project Mother',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python3 synology_summary.py /opt/mother/inventories/chris_movies.json
  python3 synology_summary.py --all
  python3 synology_summary.py --all --scan-extras
        """
    )
    parser.add_argument('inventories', nargs='*', help='Inventory JSON files to summarise')
    parser.add_argument('--all', action='store_true',
                        help='Auto-load all chris_*.json files from inventories dir')
    parser.add_argument('--scan-extras', action='store_true',
                        help='Also scan Synology paths for non-media files (subtitle/NFO/etc)')
    parser.add_argument('--scan-paths', nargs='*',
                        default=['/mnt/synology/rs-movies', '/mnt/synology/rs-tv',
                                 '/mnt/synology/rs-4kmedia/4kmovies', '/mnt/synology/rs-4kmedia/4ktv'],
                        help='Paths to scan for non-media files (default: all 4 Synology paths)')
    args = parser.parse_args()

    inventory_paths = list(args.inventories)

    if args.all:
        found = sorted(INVENTORIES_DIR.glob('chris_*.json'))
        if not found:
            print(f"No chris_*.json files found in {INVENTORIES_DIR}", file=sys.stderr)
            sys.exit(1)
        inventory_paths = [str(p) for p in found]

    if not inventory_paths and not args.scan_extras:
        parser.print_help()
        sys.exit(1)

    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    out_path = REPORTS_DIR / f"synology_summary_{timestamp}.txt"
    REPORTS_DIR.mkdir(parents=True, exist_ok=True)

    output_lines = []
    output_lines.append(f"Synology Library Summary")
    output_lines.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")

    all_items = []
    lib_labels = {}

    for inv_path in inventory_paths:
        if not os.path.exists(inv_path):
            print(f"WARNING: File not found: {inv_path}", file=sys.stderr)
            continue
        print(f"Loading: {inv_path}")
        items = load_inventory(inv_path)
        label = Path(inv_path).stem.replace('_', ' ').title()
        lib_labels[inv_path] = label
        all_items.extend(items)
        output_lines.append(summarise_library(items, label))

    if len(inventory_paths) > 1 and all_items:
        output_lines.append(summarise_library(all_items, "COMBINED TOTAL"))

    if args.scan_extras:
        print(f"\nScanning for non-media files on: {', '.join(args.scan_paths)}")
        print("(This may take several minutes for large NFS shares)")
        output_lines.append(scan_non_media(args.scan_paths))

    full_output = '\n'.join(output_lines)
    print(full_output)

    with open(out_path, 'w', encoding='utf-8') as f:
        f.write(full_output)
    print(f"\nReport saved: {out_path}")


if __name__ == '__main__':
    main()
