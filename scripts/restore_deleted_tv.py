#!/usr/bin/env python3
"""
restore_deleted_tv.py — Restore orphaned episodes from Deleted TV Shows back to TV Shows.

Orphaned = file exists in Deleted TV Shows but NO matching episode in TV Shows.
Moves files into the correct Show/Season subfolder, creating if needed.

Run on Unraid:
  python3 /path/restore_deleted_tv.py --dry-run        # preview
  python3 /path/restore_deleted_tv.py                  # execute
"""
import os
import re
import shutil
import sys
import argparse
from collections import defaultdict

DELETED_DIR = '/mnt/user/Media/Deleted TV Shows'
TV_DIR = '/mnt/user/Media/TV Shows'
DRY_RUN = '--dry-run' in sys.argv or '-n' in sys.argv

ep_re = re.compile(r'[Ss](\d{1,2})[Ee](\d{1,4})')
show_re = re.compile(r'^(.+?)\s*\((\d{4})\)\s*-\s*[Ss]\d')

def parse_ep(fname):
    m = ep_re.search(fname)
    sm = show_re.match(fname)
    if m and sm:
        return sm.group(1).strip(), sm.group(2), int(m.group(1)), int(m.group(2))
    return None

def normalize(s):
    return re.sub(r'[^a-z0-9]', '', s.lower())

# Build lookup: normalized_show_name -> list of actual TV Shows folder names
def build_show_index():
    index = defaultdict(list)
    for d in os.listdir(TV_DIR):
        full = os.path.join(TV_DIR, d)
        if not os.path.isdir(full):
            continue
        # Strip {tvdb-XXXXX} suffix for matching
        base = re.sub(r'\s*\{tvdb-\d+\}', '', d).strip()
        # Try to extract year from folder name
        ym = re.search(r'\((\d{4})\)', base)
        year = ym.group(1) if ym else ''
        name_only = re.sub(r'\s*\(\d{4}\)', '', base).strip()
        key = normalize(name_only + year)
        index[key].append(d)
    return index

def find_show_folder(show_name, year, index):
    key = normalize(show_name + year)
    if key in index:
        return index[key][0]
    # Try without year
    key2 = normalize(show_name)
    matches = [v for k, vs in index.items() for v in vs if normalize(re.sub(r'\(\d{4}\)', '', v).split('{')[0].strip()) == key2]
    if matches:
        return matches[0]
    return None

def main():
    print(f"Mode: {'DRY RUN' if DRY_RUN else 'LIVE'}")
    print(f"Deleted TV Shows: {DELETED_DIR}")
    print(f"TV Shows: {TV_DIR}")
    print()

    index = build_show_index()
    print(f"Indexed {sum(len(v) for v in index.values())} show folders\n")

    # Find active episodes
    print("Scanning active TV Shows for existing episodes...")
    active_keys = set()
    for show_dir in os.listdir(TV_DIR):
        show_path = os.path.join(TV_DIR, show_dir)
        if not os.path.isdir(show_path):
            continue
        for root, dirs, files in os.walk(show_path):
            for f in files:
                if f.lower().endswith(('.mkv', '.mp4', '.avi')):
                    parsed = parse_ep(f)
                    if parsed:
                        sname, yr, s, e = parsed
                        active_keys.add((normalize(sname + yr), s, e))
    print(f"Active episodes found: {len(active_keys)}\n")

    # Process deleted files
    files = sorted(os.listdir(DELETED_DIR))
    moved = skipped_has_active = skipped_no_match = skipped_no_parse = errors = 0
    no_match_shows = set()

    for fname in files:
        src = os.path.join(DELETED_DIR, fname)
        if not os.path.isfile(src):
            continue
        if not fname.lower().endswith(('.mkv', '.mp4', '.avi')):
            continue

        parsed = parse_ep(fname)
        if not parsed:
            skipped_no_parse += 1
            continue

        show_name, year, season, episode = parsed
        active_key = (normalize(show_name + year), season, episode)

        # Skip if already have an active copy
        if active_key in active_keys:
            skipped_has_active += 1
            continue

        # Find target show folder
        show_folder = find_show_folder(show_name, year, index)
        if not show_folder:
            no_match_shows.add(f"{show_name} ({year})")
            skipped_no_match += 1
            continue

        season_folder = f"Season {season:02d}"
        dest_dir = os.path.join(TV_DIR, show_folder, season_folder)
        dest = os.path.join(dest_dir, fname)

        if DRY_RUN:
            print(f"[DRY] {fname[:80]}")
            print(f"   -> {show_folder}/Season {season:02d}/")
        else:
            try:
                os.makedirs(dest_dir, exist_ok=True)
                shutil.move(src, dest)
                moved += 1
                if moved % 500 == 0:
                    print(f"  Moved {moved} files so far...")
            except Exception as ex:
                print(f"ERROR moving {fname}: {ex}")
                errors += 1

    print(f"\n=== Results ===")
    print(f"  Moved to TV Shows:       {moved}")
    print(f"  Skipped (has active):    {skipped_has_active}")
    print(f"  Skipped (no show match): {skipped_no_match}")
    print(f"  Skipped (parse failed):  {skipped_no_parse}")
    print(f"  Errors:                  {errors}")
    if no_match_shows:
        print(f"\nShows with no matching TV Shows folder ({len(no_match_shows)}):")
        for s in sorted(no_match_shows)[:50]:
            print(f"  {s}")

if __name__ == '__main__':
    main()
