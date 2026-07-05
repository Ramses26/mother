#!/usr/bin/env python3
"""
DEPRECATED — DO NOT RUN. Kept for incident-history reference only.

This script directly moved files on the filesystem to "restore" Remuxes that Tier 7
had (correctly, per Profile Authority — see CLAUDE.md) replaced with profile-compliant
Bluray-1080p releases. That was the wrong fix: Ali confirmed the profile assignment,
not the raw file quality, decides what should be kept. Running this against a movie
profiled "HD Bluray + WEB" would put a Remux back in place of the release the profile
actually wants — exactly the mistake this script was aborted mid-run over on
2026-07-02 (~144 movies moved before it was caught; left in place per Ali's explicit
instruction rather than un-done). See upgraderr_tier7_downgrade_incident_2026_07 memory.

The correct way to fix "wrong quality on a movie" is to let Upgraderr's tier sweep
(now correctly enforcing Profile Authority, backed by working recyclarr custom
formats) trigger a normal Radarr search — Radarr only deletes the old file after the
new one successfully imports. Never hand-roll direct file moves/deletes for this.

---- Original docstring below, describing what this script did ----

Restores movies downgraded by the 2026-07 Upgraderr Tier 7 incident, using the good
copy still sitting in Radarr's old recycle-bin location (/mnt/synology/deleted-movies
on 10.0.0.160 — superseded as of this incident by a new consolidated location on the
4K Synology, but the original 529 folders are untouched there).

Works directly on the Synology NFS mounts (both the deleted-movies bin and the live
rs-movies library are mounted on Mother) rather than through Radarr's Manual Import
API, since that API only sees what's currently mounted inside the Radarr container —
and the container's /deleted-movies mount now points at the new, empty, consolidated
location, not the old one holding these files.

For each row in reports/downgrade_recovery_report.csv with category
RECOVERABLE_RADARR_DELETED_BIN:
  1. Extract the tmdb id from before_quality (all TRaSH filenames embed {tmdb-XXXXX}).
  2. Find the matching movie in Radarr by tmdbId (reliable — no fuzzy title matching).
  3. Find the best-scoring file in the deleted-movies bin folder for that movie.
  4. If its score < the movie's current live file score, skip (nothing to gain).
  5. Move the deleted-bin file into the live folder, remove the current (worse) file(s).
  6. Trigger a Radarr RescanMovie so Radarr's DB reflects the restored file.

Defaults to DRY_RUN=true — set DRY_RUN=false to actually move files.
"""
import csv
import os
import re
import shutil
import sys
from pathlib import Path

import requests

sys.path.insert(0, str(Path(__file__).parent))
from lib.quality_scoring import calculate_quality_score, parse_quality_from_filename

DRY_RUN = os.environ.get('DRY_RUN', 'true').lower() != 'false'

OLD_DELETED_BIN = '/mnt/synology/deleted-movies'
LIVE_MOVIES = '/mnt/synology/rs-movies'
RADARR_URL = 'http://localhost:7878'

# tmdb ids to leave alone — Ali already made a manual call on these this session
# (Mazinger Z: kept the 1080p HANDJOB rather than chasing the Remux further).
EXCLUDE_TMDB_IDS = {452970}


def load_env():
    env_path = Path(__file__).parent.parent / '.env'
    for line in env_path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith('#') or '=' not in line:
            continue
        k, v = line.split('=', 1)
        os.environ.setdefault(k, v)


def score_of(filename):
    q = parse_quality_from_filename(filename)
    return calculate_quality_score(
        resolution=q.get('resolution') or 'Unknown', source=q.get('source') or 'Unknown',
        hdr=q.get('hdr') or '', audio=q.get('audio') or '', codec=q.get('codec') or '',
        size_gb=0, media_type='movie',
    )


def extract_tmdb_id(filename):
    m = re.search(r'\{tmdb-(\d+)\}', filename or '')
    return int(m.group(1)) if m else None


def normalize_title(title):
    t = re.sub(r'\s*\(\d{4}\)\s*$', '', title)
    t = t.lower().replace('&', ' and ')
    return re.sub(r'[^a-z0-9]+', '', t)


def main():
    load_env()
    api_key = os.environ['RADARR_HD_API_KEY']
    headers = {'X-Api-Key': api_key, 'Content-Type': 'application/json'}

    print(f"Loading recovery report ...", file=sys.stderr)
    rows = [r for r in csv.DictReader(open(Path(__file__).parent.parent / 'reports' / 'downgrade_recovery_report.csv'))
            if r['category'] == 'RECOVERABLE_RADARR_DELETED_BIN']
    print(f"  {len(rows)} candidates", file=sys.stderr)

    print("Fetching Radarr movie list ...", file=sys.stderr)
    movies = requests.get(f"{RADARR_URL}/api/v3/movie", headers=headers, timeout=60).json()
    by_tmdb = {m['tmdbId']: m for m in movies}
    by_norm_title = {}
    for m in movies:
        by_norm_title.setdefault(normalize_title(m['title']), []).append(m)

    # Index deleted-movies bin folders by normalized name (Radarr strips punctuation
    # from folder names, so exact string matching against the DB title fails on
    # colons etc.)
    bin_index = {}
    for entry in Path(OLD_DELETED_BIN).iterdir():
        if entry.is_dir():
            bin_index.setdefault(normalize_title(entry.name), []).append(entry)

    restored, skipped_no_gain, skipped_no_match, errors = [], [], [], []

    for row in rows:
        title = row['title']
        tmdb_id = extract_tmdb_id(row['before_quality'])
        before_score = int(row['before_score'])

        if tmdb_id in EXCLUDE_TMDB_IDS:
            skipped_no_match.append((title, 'excluded — Ali already handled this one manually'))
            continue

        movie = by_tmdb.get(tmdb_id) if tmdb_id else None
        if not movie:
            candidates = by_norm_title.get(normalize_title(title), [])
            movie = candidates[0] if len(candidates) == 1 else None
        if not movie:
            skipped_no_match.append((title, 'movie not found in Radarr'))
            continue

        bin_folders = bin_index.get(normalize_title(title), [])
        if not bin_folders:
            skipped_no_match.append((title, 'bin folder not found (moved/renamed?)'))
            continue

        # Pick the best-scoring file across all matching bin folders (handles the
        # "_2" duplicate-name folders created when the same title was deleted twice)
        best_file, best_score = None, -1
        for folder in bin_folders:
            for f in folder.iterdir():
                if f.is_file() and f.suffix.lower() != '.nfo':
                    s = score_of(f.name)
                    if s > best_score:
                        best_file, best_score = f, s

        if best_file is None:
            skipped_no_match.append((title, 'no usable file in bin folder'))
            continue

        current_file = (movie.get('movieFile') or {}).get('relativePath', '')
        current_score = score_of(current_file) if current_file else -999999

        live_folder = Path(LIVE_MOVIES) / movie['folderName'].split('/')[-1]

        # Radarr's DB record can go stale if a file was manually placed/replaced
        # outside of Radarr since its last scan (this happened to Mazinger Z earlier
        # in this incident) — don't guess at what to delete/replace in that case.
        if current_file and not (live_folder / Path(current_file).name).exists():
            skipped_no_match.append((title, f"[movieId={movie['id']}] Radarr's DB file record "
                                             f"doesn't match disk (stale — needs a rescan first): {current_file}"))
            continue

        if best_score <= current_score:
            skipped_no_gain.append((title, f'bin file scores {best_score} <= current {current_score}'))
            continue

        dest = live_folder / best_file.name

        print(f"{'[DRY RUN] ' if DRY_RUN else ''}RESTORE: {title}")
        print(f"    from: {best_file}")
        print(f"    to:   {dest}")
        print(f"    replacing: {current_file or '(no current file)'} (score {current_score} -> {best_score})")

        if not DRY_RUN:
            try:
                live_folder.mkdir(parents=True, exist_ok=True)
                if current_file:
                    old_path = Path(LIVE_MOVIES) / movie['folderName'].split('/')[-1] / Path(current_file).name
                    if old_path.exists():
                        old_path.unlink()
                shutil.move(str(best_file), str(dest))
                r = requests.post(f"{RADARR_URL}/api/v3/command", headers=headers,
                                   json={'name': 'RescanMovie', 'movieId': movie['id']}, timeout=30)
                r.raise_for_status()
            except Exception as e:
                errors.append((title, str(e)))
                continue

        restored.append(title)

    print("\n=== Summary ===", file=sys.stderr)
    print(f"  Restored: {len(restored)}", file=sys.stderr)
    print(f"  Skipped (bin file not actually better): {len(skipped_no_gain)}", file=sys.stderr)
    print(f"  Skipped (no match found): {len(skipped_no_match)}", file=sys.stderr)
    print(f"  Errors: {len(errors)}", file=sys.stderr)
    if skipped_no_match:
        print("\n  No-match details:", file=sys.stderr)
        for t, reason in skipped_no_match:
            print(f"    {t}: {reason}", file=sys.stderr)
    if errors:
        print("\n  Error details:", file=sys.stderr)
        for t, reason in errors:
            print(f"    {t}: {reason}", file=sys.stderr)

    if DRY_RUN:
        print("\nDRY RUN — no files were moved. Set DRY_RUN=false to execute.", file=sys.stderr)


if __name__ == '__main__':
    main()
