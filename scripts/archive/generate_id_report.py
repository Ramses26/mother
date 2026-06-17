#!/usr/bin/env python3
"""
Generate reports of files missing TMDB IDs
Separates files with IMDB-only from files with NO ID at all

Usage:
    python3 generate_id_report.py inventories/ali_movies_1080p.json inventories/chris_movies_1080p.json -o reports/id_report
"""

import json
import re
import argparse
from pathlib import Path
from collections import defaultdict

# Fan-made/custom media to exclude from reports
EXCLUDED_PATTERNS = [
    'Despecialized Edition',
    'Sacred Timeline Cut',
    'Infinity Saga',
    'Adele Live in New York',
    'Hateful Eight, The - Extended Version',
    'Live at',
    'Concert',
]

def is_excluded(path: str, title: str) -> bool:
    """Check if file should be excluded (fan edits, concerts, etc.)"""
    text = f"{path} {title}".lower()
    for pattern in EXCLUDED_PATTERNS:
        if pattern.lower() in text:
            return True
    return False


def extract_ids(filename: str) -> dict:
    """Extract TMDB, IMDB, and TVDB IDs from filename"""
    ids = {
        'tmdb': None,
        'imdb': None,
        'tvdb': None,
    }

    # TMDB: {tmdb-123456}
    tmdb_match = re.search(r'\{tmdb-(\d+)\}', filename, re.IGNORECASE)
    if tmdb_match:
        ids['tmdb'] = tmdb_match.group(1)

    # IMDB: {imdb-tt1234567}
    imdb_match = re.search(r'\{imdb-(tt\d+)\}', filename, re.IGNORECASE)
    if imdb_match:
        ids['imdb'] = imdb_match.group(1)

    # TVDB: {tvdb-123456}
    tvdb_match = re.search(r'\{tvdb-(\d+)\}', filename, re.IGNORECASE)
    if tvdb_match:
        ids['tvdb'] = tvdb_match.group(1)

    return ids


def analyze_inventory(inventory_path: Path) -> dict:
    """Analyze an inventory file and categorize files by ID status"""

    with open(inventory_path, 'r') as f:
        items = json.load(f)

    results = {
        'has_tmdb': [],
        'imdb_only': [],  # Has IMDB but no TMDB - can be renamed
        'tvdb_only': [],  # Has TVDB but no TMDB - can be renamed
        'no_id': [],      # No ID at all - needs manual lookup
        'excluded': [],   # Fan edits, concerts - skipped
        'total': len(items)
    }

    for item in items:
        filename = item.get('filename', '')
        path = item.get('path', '')
        title = item.get('title', '')

        # Skip fan edits, concerts, etc.
        if is_excluded(path, title):
            results['excluded'].append({'filename': filename, 'path': path, 'title': title})
            continue

        ids = extract_ids(filename)

        entry = {
            'filename': filename,
            'path': path,
            'title': title,
            'tmdb': ids['tmdb'],
            'imdb': ids['imdb'],
            'tvdb': ids['tvdb'],
        }

        if ids['tmdb']:
            results['has_tmdb'].append(entry)
        elif ids['imdb']:
            results['imdb_only'].append(entry)
        elif ids['tvdb']:
            results['tvdb_only'].append(entry)
        else:
            results['no_id'].append(entry)

    return results


def write_report(ali_results: dict, chris_results: dict, output_base: str, library_name: str):
    """Write detailed reports"""

    output_dir = Path(output_base)
    output_dir.mkdir(parents=True, exist_ok=True)

    # Summary report
    summary_file = output_dir / f'{library_name}_id_summary.txt'
    with open(summary_file, 'w') as f:
        f.write("=" * 80 + "\n")
        f.write(f"ID STATUS REPORT - {library_name.upper()}\n")
        f.write("=" * 80 + "\n\n")

        f.write("SUMMARY\n")
        f.write("-" * 50 + "\n")
        f.write(f"{'Category':<35} {'Ali':>10} {'Chris':>10}\n")
        f.write("-" * 50 + "\n")
        f.write(f"{'Total files':<35} {ali_results['total']:>10} {chris_results['total']:>10}\n")
        f.write(f"{'Has TMDB ID':<35} {len(ali_results['has_tmdb']):>10} {len(chris_results['has_tmdb']):>10}\n")
        f.write(f"{'IMDB only (can rename)':<35} {len(ali_results['imdb_only']):>10} {len(chris_results['imdb_only']):>10}\n")
        f.write(f"{'TVDB only (can rename)':<35} {len(ali_results['tvdb_only']):>10} {len(chris_results['tvdb_only']):>10}\n")
        f.write(f"{'NO ID (manual needed)':<35} {len(ali_results['no_id']):>10} {len(chris_results['no_id']):>10}\n")
        f.write(f"{'Excluded (fan edits/concerts)':<35} {len(ali_results['excluded']):>10} {len(chris_results['excluded']):>10}\n")
        f.write("-" * 50 + "\n\n")

        # Percentages
        ali_pct = len(ali_results['has_tmdb']) / ali_results['total'] * 100 if ali_results['total'] > 0 else 0
        chris_pct = len(chris_results['has_tmdb']) / chris_results['total'] * 100 if chris_results['total'] > 0 else 0
        f.write(f"Ali TMDB coverage: {ali_pct:.1f}%\n")
        f.write(f"Chris TMDB coverage: {chris_pct:.1f}%\n\n")

    print(f"Summary: {summary_file}")

    # IMDB-only report (for Radarr/Sonarr rename)
    imdb_file = output_dir / f'{library_name}_imdb_only_RENAME_THESE.txt'
    with open(imdb_file, 'w') as f:
        f.write("=" * 80 + "\n")
        f.write("FILES WITH IMDB BUT NO TMDB - RUN THROUGH RADARR/SONARR TO RENAME\n")
        f.write("=" * 80 + "\n\n")
        f.write("These files have IMDB IDs but no TMDB IDs.\n")
        f.write("Radarr/Sonarr can automatically add TMDB IDs when you:\n")
        f.write("  1. Go to Movie/Series > Edit\n")
        f.write("  2. Click 'Rename Files'\n")
        f.write("Or use Mass Editor to rename multiple at once.\n\n")

        f.write(f"\n{'='*40}\nALI'S FILES ({len(ali_results['imdb_only'])})\n{'='*40}\n\n")
        for item in sorted(ali_results['imdb_only'], key=lambda x: x['title']):
            f.write(f"Title: {item['title']}\n")
            f.write(f"  IMDB: {item['imdb']}\n")
            f.write(f"  File: {item['filename']}\n")
            f.write(f"  Path: {item['path']}\n\n")

        f.write(f"\n{'='*40}\nCHRIS'S FILES ({len(chris_results['imdb_only'])})\n{'='*40}\n\n")
        for item in sorted(chris_results['imdb_only'], key=lambda x: x['title']):
            f.write(f"Title: {item['title']}\n")
            f.write(f"  IMDB: {item['imdb']}\n")
            f.write(f"  File: {item['filename']}\n")
            f.write(f"  Path: {item['path']}\n\n")

    print(f"IMDB-only (rename these): {imdb_file}")

    # No-ID report (needs manual intervention)
    no_id_file = output_dir / f'{library_name}_no_id_MANUAL_NEEDED.txt'
    with open(no_id_file, 'w') as f:
        f.write("=" * 80 + "\n")
        f.write("FILES WITH NO ID - NEED MANUAL LOOKUP OR ARE FAN EDITS\n")
        f.write("=" * 80 + "\n\n")
        f.write("These files have NO TMDB or IMDB ID in the filename.\n")
        f.write("They are likely:\n")
        f.write("  - Fan edits (Despecialized, extended cuts)\n")
        f.write("  - Concerts/live performances\n")
        f.write("  - Custom compilations\n")
        f.write("  - Files that need manual renaming\n\n")
        f.write("For regular movies/shows, manually add to Radarr/Sonarr and rename.\n")
        f.write("For fan edits, consider leaving as-is or using a custom naming scheme.\n\n")

        f.write(f"\n{'='*40}\nALI'S FILES ({len(ali_results['no_id'])})\n{'='*40}\n\n")
        for item in sorted(ali_results['no_id'], key=lambda x: x['title']):
            f.write(f"Title: {item['title']}\n")
            f.write(f"  File: {item['filename']}\n")
            f.write(f"  Path: {item['path']}\n\n")

        f.write(f"\n{'='*40}\nCHRIS'S FILES ({len(chris_results['no_id'])})\n{'='*40}\n\n")
        for item in sorted(chris_results['no_id'], key=lambda x: x['title']):
            f.write(f"Title: {item['title']}\n")
            f.write(f"  File: {item['filename']}\n")
            f.write(f"  Path: {item['path']}\n\n")

    print(f"No ID (manual needed): {no_id_file}")

    return {
        'summary': summary_file,
        'imdb_only': imdb_file,
        'no_id': no_id_file,
    }


def main():
    parser = argparse.ArgumentParser(description='Generate ID status reports')
    parser.add_argument('ali_inventory', type=Path, help="Ali's inventory JSON")
    parser.add_argument('chris_inventory', type=Path, help="Chris's inventory JSON")
    parser.add_argument('-o', '--output', required=True, help='Output directory')
    parser.add_argument('-n', '--name', default='library', help='Library name for report')

    args = parser.parse_args()

    print(f"Analyzing Ali's inventory: {args.ali_inventory}")
    ali_results = analyze_inventory(args.ali_inventory)

    print(f"Analyzing Chris's inventory: {args.chris_inventory}")
    chris_results = analyze_inventory(args.chris_inventory)

    print(f"\nGenerating reports...")
    write_report(ali_results, chris_results, args.output, args.name)

    print("\nDone!")


if __name__ == '__main__':
    main()
