#!/usr/bin/env python3
"""
Plex Duplicate Finder - Project Mother

Queries Plex for duplicate media, scores each copy using TRaSH quality
scoring, and generates a cleanup shell script (DRY_RUN=true by default).

Plex handles the hard matching (TVDB/TMDB episode/movie identity), we just
decide which copy is better.

Usage:
    cd /opt/mother/scripts
    python3 plex_dupefinder.py                    # all sections, dry-run report
    python3 plex_dupefinder.py --section tv       # TV only
    python3 plex_dupefinder.py --section movies   # Movies only
    python3 plex_dupefinder.py --execute          # write cleanup script

Output:
    /opt/mother/reports/plex_dupes/TIMESTAMP/
        plex_dupes_report_TIMESTAMP.txt    human-readable decisions
        plex_dupes_plan_TIMESTAMP.csv      spreadsheet
        plex_dupes_actions_TIMESTAMP.sh    executable cleanup script
"""

import argparse
import csv
import os
import sys
import xml.etree.ElementTree as ET
from collections import defaultdict
from datetime import datetime
from pathlib import Path
from urllib.request import urlopen
from urllib.error import URLError
from urllib.parse import urlencode

# ── imports from shared lib ──────────────────────────────────────────────────
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from lib.quality_scoring import (
    calculate_quality_score,
    parse_quality_from_filename,
)

# ── Configuration ────────────────────────────────────────────────────────────
PLEX_URL   = os.environ.get('PLEX_URL',   'http://10.0.0.250:32400')
PLEX_TOKEN = os.environ.get('PLEX_TOKEN', '_baJvspRxVjRzaokRoLB')

REPORTS_DIR = Path('/opt/mother/reports/plex_dupes')

# Plex path prefix → Mother NFS path prefix
# Add entries here if new shares are added to Plex
PLEX_PATH_MAP = {
    '/mnt/MOVIES/': '/mnt/synology/rs-movies/',
    '/mnt/TV/':     '/mnt/synology/rs-tv/',
    '/mnt/4KMOVIES/': '/mnt/synology/rs-4kmedia/4kmovies/',
    '/mnt/4KTV/':     '/mnt/synology/rs-4kmedia/4ktv/',
}

# Sections to scan: (section_id, media_type, plex_type_param, label, is_4k)
SECTIONS = [
    (1,  'movie',   None, 'Movies',    False),
    (2,  'tv',      4,    'TV Shows',  False),
    (13, 'movie',   None, '4K Movies', True),
    (12, 'tv',      4,    '4K TV',     True),
]


# ── Plex API ─────────────────────────────────────────────────────────────────

def plex_get(path: str, params: dict = None) -> ET.Element:
    params = params or {}
    params['X-Plex-Token'] = PLEX_TOKEN
    url = f"{PLEX_URL}{path}?{urlencode(params)}"
    try:
        with urlopen(url, timeout=30) as resp:
            return ET.fromstring(resp.read())
    except URLError as e:
        print(f"ERROR: Plex API failed ({url}): {e}", file=sys.stderr)
        sys.exit(1)


def get_duplicates(section_id: int, plex_type: int = None) -> list:
    params = {'duplicate': '1'}
    if plex_type:
        params['type'] = str(plex_type)
    root = plex_get(f'/library/sections/{section_id}/all', params)
    return root.findall('Video')


# ── Scoring ───────────────────────────────────────────────────────────────────

def score_media(filename: str, size_bytes: int, is_4k: bool = False,
                media_type: str = 'movie') -> dict:
    parsed = parse_quality_from_filename(filename)
    size_gb = size_bytes / 1024**3
    score  = calculate_quality_score(
        resolution=parsed.get('resolution', ''),
        source=parsed.get('source', ''),
        hdr=parsed.get('hdr', ''),
        audio=parsed.get('audio', ''),
        codec=parsed.get('codec', ''),
        size_gb=size_gb,
        is_4k=is_4k,
        media_type=media_type,
    )
    return {
        'filename': filename,
        'size_bytes': size_bytes,
        'size_gb': size_bytes / 1024**3,
        'score': score,
        'resolution': parsed.get('resolution', ''),
        'source': parsed.get('source', ''),
        'hdr': parsed.get('hdr', ''),
        'audio': parsed.get('audio', ''),
        'codec': parsed.get('codec', ''),
    }


# ── Path translation ──────────────────────────────────────────────────────────

def plex_to_local(plex_path: str) -> str:
    for plex_prefix, local_prefix in PLEX_PATH_MAP.items():
        if plex_path.startswith(plex_prefix):
            return local_prefix + plex_path[len(plex_prefix):]
    return None   # unmapped — flag for manual review


# ── Process one Plex Video element ───────────────────────────────────────────

def process_video(video: ET.Element, is_4k: bool) -> dict:
    """
    Returns a dict describing the duplicate group, or None if <2 files.
    """
    title            = video.get('title', '')
    grandparent      = video.get('grandparentTitle', '')   # show name (TV)
    parent           = video.get('parentTitle', '')         # season (TV)
    rating_key       = video.get('ratingKey', '')
    season_ep        = f"S{video.get('parentIndex','?'):>02}E{video.get('index','?'):>02}"

    display = f"{grandparent} | {parent} | {title}" if grandparent else f"{title} ({video.get('year','')})"

    entries = []
    for media in video.findall('Media'):
        media_id = media.get('id', '')
        for part in media.findall('Part'):
            plex_path  = part.get('file', '')
            size_bytes = int(part.get('size', 0))
            filename   = Path(plex_path).name
            local_path = plex_to_local(plex_path)
            scored     = score_media(filename, size_bytes, is_4k,
                               media_type='tv' if grandparent else 'movie')
            entries.append({
                'plex_path':  plex_path,
                'local_path': local_path,
                'media_id':   media_id,
                **scored,
            })

    if len(entries) < 2:
        return None

    # Sort: highest score first; tiebreak by size (larger = keep)
    entries.sort(key=lambda e: (e['score'], e['size_bytes']), reverse=True)

    keeper   = entries[0]
    removals = entries[1:]

    # Flag groups where scores are equal (may need human review)
    scores_equal = len(set(e['score'] for e in entries)) == 1

    # Flag groups where local path couldn't be mapped
    unmapped = [e for e in entries if e['local_path'] is None]

    return {
        'display':       display,
        'rating_key':    rating_key,
        'season_ep':     season_ep if grandparent else '',
        'keeper':        keeper,
        'removals':      removals,
        'scores_equal':  scores_equal,
        'unmapped':      unmapped,
        'total_save_gb': sum(r['size_gb'] for r in removals),
    }


# ── Report generation ─────────────────────────────────────────────────────────

def write_report(groups: list, label: str, out_dir: Path, timestamp: str):
    report_path  = out_dir / f'plex_dupes_report_{label}_{timestamp}.txt'
    csv_path     = out_dir / f'plex_dupes_plan_{label}_{timestamp}.csv'
    script_path  = out_dir / f'plex_dupes_actions_{label}_{timestamp}.sh'

    total_removals = sum(len(g['removals']) for g in groups)
    total_save_gb  = sum(g['total_save_gb'] for g in groups)
    needs_review   = [g for g in groups if g['scores_equal'] or g['unmapped']]

    # ── Human-readable report ────────────────────────────────────────────────
    with open(report_path, 'w') as f:
        f.write('=' * 80 + '\n')
        f.write(f'PLEX DUPLICATE REPORT — {label.upper()}\n')
        f.write(f'Generated: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}\n')
        f.write('=' * 80 + '\n\n')
        f.write(f'Duplicate groups:  {len(groups)}\n')
        f.write(f'Files to remove:   {total_removals}\n')
        f.write(f'Space to reclaim:  {total_save_gb:.2f} GB\n')
        f.write(f'Needs review:      {len(needs_review)}\n\n')

        if needs_review:
            f.write('⚠ GROUPS NEEDING MANUAL REVIEW (equal scores or unmapped paths):\n')
            for g in needs_review:
                reason = []
                if g['scores_equal']:   reason.append('equal scores')
                if g['unmapped']:       reason.append('unmapped path')
                f.write(f'  [{", ".join(reason)}] {g["display"]}\n')
            f.write('\n')

        for g in sorted(groups, key=lambda x: x['display']):
            f.write('-' * 60 + '\n')
            ep = f' {g["season_ep"]}' if g['season_ep'] else ''
            flag = ' ⚠ REVIEW' if (g['scores_equal'] or g['unmapped']) else ''
            f.write(f'Group: {g["display"]}{ep}{flag}\n')
            k = g['keeper']
            f.write(f'  KEEP:   {k["filename"]}\n')
            f.write(f'          Score: {k["score"]}  '
                    f'Quality: {k["resolution"]}/{k["source"]}/{k["audio"]}'
                    f'{"/"+k["hdr"] if k["hdr"] else ""}  '
                    f'Size: {k["size_gb"]:.2f}GB\n')
            for r in g['removals']:
                local = r['local_path'] or f'UNMAPPED: {r["plex_path"]}'
                f.write(f'  REMOVE: {r["filename"]}\n')
                f.write(f'          Score: {r["score"]}  '
                        f'Quality: {r["resolution"]}/{r["source"]}/{r["audio"]}'
                        f'{"/"+r["hdr"] if r["hdr"] else ""}  '
                        f'Size: {r["size_gb"]:.2f}GB\n')
                f.write(f'          Path: {local}\n')
            f.write(f'  Space saved: {g["total_save_gb"]:.2f} GB\n\n')

    print(f'Report: {report_path}')

    # ── CSV ──────────────────────────────────────────────────────────────────
    with open(csv_path, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=[
            'group', 'action', 'filename', 'score', 'resolution',
            'source', 'audio', 'hdr', 'codec', 'size_gb', 'local_path', 'plex_path'
        ])
        writer.writeheader()
        for g in groups:
            writer.writerow({
                'group': g['display'], 'action': 'KEEP',
                'filename': g['keeper']['filename'],
                'score': g['keeper']['score'],
                'resolution': g['keeper']['resolution'],
                'source': g['keeper']['source'],
                'audio': g['keeper']['audio'],
                'hdr': g['keeper']['hdr'],
                'codec': g['keeper']['codec'],
                'size_gb': f"{g['keeper']['size_gb']:.2f}",
                'local_path': g['keeper']['local_path'] or '',
                'plex_path': g['keeper']['plex_path'],
            })
            for r in g['removals']:
                writer.writerow({
                    'group': g['display'], 'action': 'REMOVE',
                    'filename': r['filename'],
                    'score': r['score'],
                    'resolution': r['resolution'],
                    'source': r['source'],
                    'audio': r['audio'],
                    'hdr': r['hdr'],
                    'codec': r['codec'],
                    'size_gb': f"{r['size_gb']:.2f}",
                    'local_path': r['local_path'] or '',
                    'plex_path': r['plex_path'],
                })
    print(f'CSV:    {csv_path}')

    # ── Cleanup shell script ─────────────────────────────────────────────────
    with open(script_path, 'w') as f:
        f.write('#!/bin/bash\n')
        f.write(f'# Plex Duplicate Cleanup — {label}\n')
        f.write(f'# Generated: {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}\n')
        f.write(f'# Files to remove: {total_removals}  |  Space: {total_save_gb:.2f} GB\n')
        f.write('#\n')
        f.write('# Review the report before running.\n')
        f.write('# Groups marked REVIEW have equal scores — verify manually.\n')
        f.write('#\n')
        f.write('DRY_RUN="${DRY_RUN:-true}"\n')
        f.write('REMOVED=0; SKIPPED=0; FAILED=0\n\n')

        f.write('RED="\\033[0;31m"; GREEN="\\033[0;32m"\n')
        f.write('YELLOW="\\033[1;33m"; BLUE="\\033[0;34m"; NC="\\033[0m"\n\n')

        f.write('log() { echo -e "[$(date +%T)] $1"; }\n\n')

        f.write('cleanup_file() {\n')
        f.write('    local file="$1" desc="$2"\n')
        f.write('    if [ ! -e "$file" ]; then\n')
        f.write('        log "${YELLOW}SKIP${NC} [not found]: $desc"\n')
        f.write('        ((SKIPPED++)); return 0\n')
        f.write('    fi\n')
        f.write('    if [ "$DRY_RUN" = "true" ]; then\n')
        f.write('        log "${BLUE}[DRY RUN]${NC} Would remove: $desc"\n')
        f.write('        ((REMOVED++)); return 0\n')
        f.write('    fi\n')
        f.write('    if rm -f "$file"; then\n')
        f.write('        log "${GREEN}REMOVED${NC}: $desc"\n')
        f.write('        ((REMOVED++))\n')
        f.write('    else\n')
        f.write('        log "${RED}FAILED${NC}: $desc"\n')
        f.write('        ((FAILED++))\n')
        f.write('    fi\n')
        f.write('}\n\n')

        f.write('log "Starting Plex duplicate cleanup..."\n')
        f.write('[ "$DRY_RUN" = "true" ] && log "${BLUE}DRY RUN — no files will be deleted${NC}"\n')
        f.write('echo ""\n\n')

        for g in sorted(groups, key=lambda x: x['display']):
            ep = f' {g["season_ep"]}' if g['season_ep'] else ''
            review = ' # ⚠ REVIEW — equal scores' if g['scores_equal'] else ''
            f.write(f'# {g["display"]}{ep}{review}\n')
            f.write(f'# KEEP: {g["keeper"]["filename"]} (score: {g["keeper"]["score"]})\n')
            for r in g['removals']:
                if r['local_path']:
                    escaped = r['local_path'].replace('"', '\\"')
                    desc = f'{r["filename"]} (score: {r["score"]} vs keeper {g["keeper"]["score"]})'
                    desc_esc = desc.replace('"', '\\"')
                    f.write(f'cleanup_file "{escaped}" "{desc_esc}"\n')
                else:
                    f.write(f'# UNMAPPED (manual delete needed): {r["plex_path"]}\n')
            f.write('\n')

        f.write('echo ""\n')
        f.write('echo "========================================"\n')
        f.write('echo "PLEX DUPE CLEANUP SUMMARY"\n')
        f.write('echo "========================================"\n')
        f.write('echo "Removed: $REMOVED  Skipped: $SKIPPED  Failed: $FAILED"\n')
        f.write('echo "========================================"\n')
        f.write('[ "$DRY_RUN" = "true" ] && echo "DRY RUN — rerun with DRY_RUN=false to delete"\n')

    os.chmod(script_path, 0o755)
    print(f'Script: {script_path}')
    return report_path, csv_path, script_path


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description='Plex Duplicate Finder — Project Mother')
    parser.add_argument('--section', choices=['movies', 'tv', 'all'], default='all',
                        help='Which library to scan (default: all)')
    parser.add_argument('--url',   default=None, help='Override Plex URL')
    parser.add_argument('--token', default=None, help='Override Plex token')
    args = parser.parse_args()

    global PLEX_URL, PLEX_TOKEN
    if args.url:   PLEX_URL   = args.url
    if args.token: PLEX_TOKEN = args.token

    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    out_dir   = REPORTS_DIR / timestamp
    out_dir.mkdir(parents=True, exist_ok=True)

    section_filter = {
        'movies': {'movie'},
        'tv':     {'tv'},
        'all':    {'movie', 'tv'},
    }[args.section]

    all_groups   = []
    total_save   = 0.0

    for section_id, media_type, plex_type, label, is_4k in SECTIONS:
        if media_type not in section_filter:
            continue

        print(f'\nScanning {label} (section {section_id})...')
        videos = get_duplicates(section_id, plex_type)
        print(f'  {len(videos)} duplicate items found')

        groups = []
        for video in videos:
            g = process_video(video, is_4k)
            if g:
                groups.append(g)

        if not groups:
            print(f'  No actionable duplicates.')
            continue

        save_gb = sum(g['total_save_gb'] for g in groups)
        review_count = sum(1 for g in groups if g['scores_equal'] or g['unmapped'])
        print(f'  {len(groups)} groups  |  {save_gb:.1f} GB to reclaim  |  {review_count} need review')

        write_report(groups, label.replace(' ', '_'), out_dir, timestamp)
        all_groups.extend(groups)
        total_save += save_gb

    print(f'\n{"=" * 60}')
    print(f'TOTAL: {len(all_groups)} duplicate groups  |  {total_save:.1f} GB to reclaim')
    print(f'Reports: {out_dir}')
    print(f'\nReview reports then execute:')
    print(f'  DRY_RUN=false {out_dir}/plex_dupes_actions_*.sh')


if __name__ == '__main__':
    main()
