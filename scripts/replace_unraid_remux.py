#!/usr/bin/env python3
"""
One-time script: queue MovieVersionSync jobs to replace Unraid Remux copies with
Synology (Radarr-tracked) copies, so both sides reach 1:1 parity.

Rules:
- Only processes movies where Unraid has a Remux and Synology has a non-Remux
- Skips the 4 keeper exceptions (Star Wars saga + 13th Warrior)
- Verifies Synology source file exists on NFS before queuing
- DRY_RUN=true by default — set to false to actually queue jobs

Usage:
  python3 replace_unraid_remux.py           # dry run
  DRY_RUN=false python3 replace_unraid_remux.py  # queue jobs
"""
import json
import os
import re
import sqlite3
import time

# ── Config ────────────────────────────────────────────────────────────────────
SCAN_DATA      = '/tmp/movie_sync_data.json'
SYNOLOGY_ROOT  = '/mnt/synology/rs-movies'
UNRAID_CIFS    = '/mnt/unraid/media/Movies'    # rsync destination base (CIFS)
UNRAID_AGENT   = '/mnt/user/Media/Movies'      # Agent path base for delete
DB_PATH        = '/opt/mother/data/sync_jobs.db'
DRY_RUN        = os.environ.get('DRY_RUN', 'true').lower() != 'false'

# TMDB IDs to KEEP on Unraid (user-specified exceptions)
EXCEPTION_TMDB = {
    'tmdb-1911',  # The 13th Warrior (1999)
    'tmdb-1891',  # The Empire Strikes Back (1980)
    'tmdb-11',    # Star Wars (1977)
    'tmdb-1892',  # Return of the Jedi (1983)
}

# ── Helpers ───────────────────────────────────────────────────────────────────
def get_folder(filename: str) -> str:
    """Extract Synology/Unraid folder name = 'Title (Year)' from filename.
    Folders on both Synology and Unraid do NOT include {tmdb-ID} — only the
    filename inside the folder does. Strip everything from ' {tmdb-' onward."""
    m = re.match(r'^(.+?)\s*\{tmdb-', filename)
    if m:
        return m.group(1).rstrip()
    # Fallback: everything before ' - ['
    m2 = re.match(r'^(.+?)\s+-\s+\[', filename)
    if m2:
        return m2.group(1).strip()
    return re.sub(r'\.[a-z0-9]{2,4}$', '', filename, flags=re.I)


def is_already_queued(conn, source_path: str) -> bool:
    cur = conn.execute(
        "SELECT COUNT(*) FROM sync_jobs WHERE source_path=? AND status IN ('pending','in_progress')",
        (source_path,)
    )
    return cur.fetchone()[0] > 0


# ── Main ──────────────────────────────────────────────────────────────────────
def main():
    if not os.path.exists(SCAN_DATA):
        print(f"ERROR: scan data not found at {SCAN_DATA}")
        print("Run a Curatorr sync-status/movies scan first.")
        return

    with open(SCAN_DATA) as f:
        data = json.load(f)

    unraid_better = data.get('unraid_better', [])
    print(f"Total 'unraid_better' movies: {len(unraid_better)}")

    conn = sqlite3.connect(DB_PATH)

    skipped_exc   = []
    skipped_nosyn = []
    skipped_dup   = []
    to_queue      = []

    for movie in unraid_better:
        unraid_file = movie['unraid_file']
        syn_file    = movie['syn_file']
        title       = movie['title']

        # Only Remux copies on Unraid
        if 'remux' not in unraid_file.lower():
            continue

        # Exceptions — keep these Remuxes on Unraid
        if any(exc in syn_file for exc in EXCEPTION_TMDB):
            skipped_exc.append(title)
            continue

        # Derive folder and paths
        folder   = get_folder(syn_file)
        syn_path = os.path.join(SYNOLOGY_ROOT, folder, syn_file)
        dest_dir = os.path.join(UNRAID_CIFS, folder)
        del_path = os.path.join(UNRAID_AGENT, folder, unraid_file)

        # Verify Synology source exists
        if not os.path.isfile(syn_path):
            skipped_nosyn.append(f"{title} → {syn_path}")
            continue

        # Skip if already queued
        if is_already_queued(conn, syn_path):
            skipped_dup.append(title)
            continue

        try:
            file_size = os.path.getsize(syn_path)
        except OSError:
            file_size = movie.get('syn_size_bytes', 0)

        to_queue.append({
            'title':    title,
            'source':   syn_path,
            'dest':     dest_dir,
            'del_path': del_path,
            'syn_file': syn_file,
            'unraid_file': unraid_file,
            'syn_score':   movie['syn_score'],
            'unraid_score': movie['unraid_score'],
            'file_size': file_size,
        })

    # ── Summary ───────────────────────────────────────────────────────────────
    print(f"\nExceptions (keeping Unraid Remux): {len(skipped_exc)}")
    for t in skipped_exc:
        print(f"  ✓ {t}")

    print(f"\nSynology file not found (skipped): {len(skipped_nosyn)}")
    for t in skipped_nosyn:
        print(f"  ✗ {t}")

    if skipped_dup:
        print(f"\nAlready queued (skipped): {len(skipped_dup)}")

    print(f"\n{'[DRY RUN] ' if DRY_RUN else ''}Jobs to queue: {len(to_queue)}")
    print()
    for job in to_queue:
        gb = job['file_size'] / 1_073_741_824
        print(f"  {job['title']}")
        print(f"    Syn  ({job['syn_score']:,}): {job['syn_file']}")
        print(f"    Raid ({job['unraid_score']:,}): {job['unraid_file']}  [DELETE after sync]")
        print(f"    Size: {gb:.1f} GB")
        print()

    if DRY_RUN:
        print(f"DRY RUN — no jobs queued. Set DRY_RUN=false to queue {len(to_queue)} jobs.")
        conn.close()
        return

    # ── Queue jobs ────────────────────────────────────────────────────────────
    queued = 0
    for job in to_queue:
        conn.execute("""
            INSERT INTO sync_jobs
                (job_type, source_path, dest_path, title, quality, file_size,
                 status, retry_count, delete_after_sync)
            VALUES (?, ?, ?, ?, ?, ?, 'pending', 0, ?)
        """, (
            'movie',
            job['source'],
            job['dest'],
            job['title'],
            'MovieVersionSync',
            job['file_size'],
            job['del_path'],
        ))
        queued += 1

    conn.commit()
    conn.close()
    print(f"Queued {queued} MovieVersionSync jobs.")
    print("The sync-webhook auto-retry scheduler will pick them up within 15 minutes.")
    print("Jobs are capped at SYNC_MAX_CONCURRENT=3 concurrent transfers.")


if __name__ == '__main__':
    main()
