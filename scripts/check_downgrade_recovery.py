#!/usr/bin/env python3
"""
Cross-checks every movie downgraded by the 2026-07 Upgraderr Tier 7 incident against
three possible recovery sources, so we know what's actually lost before re-downloading
anything:

  1. Unraid (via Unraid Agent inventory API) — sync is one-way/append-only and never
     deletes on a Synology-side downgrade, so Ali's copy is often still the good version.
  2. qBittorrent (Synology, 10.0.1.203:8080) — the original torrent may still be present
     (seeding/stalled/stopped) even if Radarr no longer references it.
  3. Synology #recycle bin — DSM intercepts NFS deletes, but retention isn't guaranteed
     (see docs/AUDIT_2026-07-02 for why the Mazinger Z Remux wasn't recoverable this way).

Read-only. Makes no changes to Radarr, qBittorrent, or any filesystem.

Usage:
    python3 check_downgrade_recovery.py [--db /path/to/upgraderr.db] [--out report.csv]
"""
import argparse
import csv
import json
import os
import re
import sqlite3
import sys
from pathlib import Path

import requests

sys.path.insert(0, str(Path(__file__).parent))
from lib.quality_scoring import calculate_quality_score, parse_quality_from_filename

UNRAID_AGENT_URL = os.environ.get('UNRAID_AGENT_URL', 'http://192.168.1.10:8100')
UNRAID_AGENT_API_KEY = os.environ.get('UNRAID_AGENT_API_KEY', '')
QBIT_HOST = os.environ.get('QBITMANAGE_QBT_HOST', 'http://10.0.1.203:8080')
QBIT_USER = os.environ.get('QBITMANAGE_QBT_USER', '')
QBIT_PASS = os.environ.get('QBITMANAGE_QBT_PASS', '')
SYNOLOGY_RECYCLE = '/mnt/synology/rs-movies/#recycle'
# Radarr's OWN recycle bin (Settings > Media Management > Recycle Bin), separate from
# and far more reliable than the Synology-native NFS #recycle above — this is where
# Radarr moves a file on every delete-on-upgrade, with a configured retention (30
# days on radarr-hd at time of writing). Check this FIRST.
RADARR_DELETED_MOVIES = '/mnt/synology/deleted-movies'


def load_env():
    env_path = Path(__file__).parent.parent / '.env'
    if not env_path.exists():
        return
    for line in env_path.read_text().splitlines():
        line = line.strip()
        if not line or line.startswith('#') or '=' not in line:
            continue
        k, v = line.split('=', 1)
        os.environ.setdefault(k, v)


def normalize_title(title):
    """Strip year suffix and punctuation for fuzzy matching. Radarr spells out '&'
    as 'and' in on-disk folder names, so normalize that too."""
    t = re.sub(r'\s*\(\d{4}\)\s*$', '', title)
    t = t.lower().replace('&', ' and ')
    t = re.sub(r'[^a-z0-9]+', '', t)
    return t


def extract_release_group(filename):
    m = re.search(r'-([A-Za-z0-9]+)(?:\.[a-z0-9]{2,4})?$', filename)
    return m.group(1).lower() if m else None


def score_of(filename):
    q = parse_quality_from_filename(filename)
    return calculate_quality_score(
        resolution=q.get('resolution') or 'Unknown', source=q.get('source') or 'Unknown',
        hdr=q.get('hdr') or '', audio=q.get('audio') or '', codec=q.get('codec') or '',
        size_gb=0, media_type='movie',
    )


def fetch_downgrades(db_path):
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    rows = conn.execute(
        "SELECT instance, media_id, title, tier, before_quality, before_score, "
        "after_quality, after_score, imported_at FROM upgrade_history "
        "WHERE after_score < before_score ORDER BY imported_at ASC"
    ).fetchall()
    return [dict(r) for r in rows]


def fetch_unraid_inventory():
    r = requests.get(
        f"{UNRAID_AGENT_URL}/inventory",
        params={'path': '/mnt/user/Media/Movies'},
        headers={'X-Api-Key': UNRAID_AGENT_API_KEY},
        timeout=60,
    )
    r.raise_for_status()
    return r.json().get('items', [])


def fetch_qbit_torrents():
    if not QBIT_USER:
        return []
    s = requests.Session()
    r = s.post(f"{QBIT_HOST}/api/v2/auth/login",
               data={'username': QBIT_USER, 'password': QBIT_PASS}, timeout=10)
    r.raise_for_status()
    r = s.get(f"{QBIT_HOST}/api/v2/torrents/info", timeout=30)
    r.raise_for_status()
    return r.json()


def check_unraid(title, before_score, unraid_by_norm_title):
    key = normalize_title(title)
    candidates = unraid_by_norm_title.get(key, [])
    if not candidates:
        return None, None
    best = max(candidates, key=lambda it: score_of(it.get('filename', '')))
    best_score = score_of(best.get('filename', ''))
    if best_score >= before_score:
        return best, best_score
    return None, best_score


def check_qbit(title, before_quality, torrents_by_group):
    group = extract_release_group(before_quality or '')
    title_key = normalize_title(title)
    # Short titles ("Go", "It", "Us") produce false positives via naive substring
    # matching (e.g. "go" matches inside "igor") — require enough signal to be safe.
    if len(title_key) < 6:
        return []
    hits = []
    for t in torrents_by_group.get(group, []) if group else []:
        name_key = re.sub(r'[^a-z0-9]+', '', t['name'].lower())
        if title_key[:12] in name_key:
            hits.append(t)
    return hits


def build_folder_index(base_path):
    """Index a directory's immediate subfolders by normalized name — Radarr strips
    colons and other punctuation from folder names, so an exact `title` string from
    the DB (which keeps the raw metadata title, e.g. "Elvira: Mistress of the Dark")
    won't literally match the on-disk folder ("Elvira Mistress of the Dark") unless
    matched via the same normalization used for Unraid."""
    index = {}
    try:
        for entry in Path(base_path).iterdir():
            if entry.is_dir():
                index[normalize_title(entry.name)] = entry
    except OSError:
        pass
    return index


def check_recycle_bin(title, recycle_index):
    folder = recycle_index.get(normalize_title(title))
    if not folder:
        return []
    try:
        return [f.name for f in folder.iterdir() if f.is_file()]
    except OSError:
        return []


def check_radarr_deleted(title, before_score, deleted_index):
    folder = deleted_index.get(normalize_title(title))
    if not folder:
        return None, None
    try:
        files = [f for f in folder.iterdir() if f.is_file() and f.suffix.lower() != '.nfo']
    except OSError:
        return None, None
    if not files:
        return None, None
    best = max(files, key=lambda f: score_of(f.name))
    best_score = score_of(best.name)
    if best_score >= before_score:
        return best.name, best_score
    return None, best_score


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--db', default='/opt/mother/data/upgraderr/upgraderr.db')
    ap.add_argument('--out', default=None)
    args = ap.parse_args()

    load_env()
    global UNRAID_AGENT_URL, UNRAID_AGENT_API_KEY, QBIT_HOST, QBIT_USER, QBIT_PASS
    UNRAID_AGENT_URL = os.environ.get('UNRAID_AGENT_URL', UNRAID_AGENT_URL)
    UNRAID_AGENT_API_KEY = os.environ.get('UNRAID_AGENT_API_KEY', UNRAID_AGENT_API_KEY)
    QBIT_HOST = os.environ.get('QBITMANAGE_QBT_HOST', QBIT_HOST)
    QBIT_USER = os.environ.get('QBITMANAGE_QBT_USER', QBIT_USER)
    QBIT_PASS = os.environ.get('QBITMANAGE_QBT_PASS', QBIT_PASS)

    print(f"Loading downgrades from {args.db} ...", file=sys.stderr)
    downgrades = fetch_downgrades(args.db)
    print(f"  {len(downgrades)} downgraded movies", file=sys.stderr)

    print("Fetching Unraid Movies inventory ...", file=sys.stderr)
    unraid_items = fetch_unraid_inventory()
    unraid_by_norm_title = {}
    for it in unraid_items:
        # path like /mnt/user/Media/Movies/<Folder>/<file>
        parts = it.get('path', '').split('/')
        folder = parts[5] if len(parts) > 5 else it.get('title', '')
        unraid_by_norm_title.setdefault(normalize_title(folder), []).append(it)
    print(f"  {len(unraid_items)} files across {len(unraid_by_norm_title)} folders", file=sys.stderr)

    print("Fetching qBittorrent torrent list ...", file=sys.stderr)
    torrents = fetch_qbit_torrents()
    torrents_by_group = {}
    for t in torrents:
        g = extract_release_group(t['name'])
        if g:
            torrents_by_group.setdefault(g, []).append(t)
    print(f"  {len(torrents)} torrents", file=sys.stderr)

    print("Indexing Radarr deleted-movies bin and Synology recycle bin ...", file=sys.stderr)
    deleted_index = build_folder_index(RADARR_DELETED_MOVIES)
    recycle_index = build_folder_index(SYNOLOGY_RECYCLE)
    print(f"  {len(deleted_index)} folders in deleted-movies, {len(recycle_index)} in #recycle", file=sys.stderr)

    results = []
    for d in downgrades:
        title = d['title']
        before_score = d['before_score']
        radarr_deleted_match, radarr_deleted_best_score = check_radarr_deleted(title, before_score, deleted_index)
        unraid_hit, unraid_best_score = check_unraid(title, before_score, unraid_by_norm_title)
        qbit_hits = check_qbit(title, d['before_quality'], torrents_by_group)
        recycle_hits = check_recycle_bin(title, recycle_index)

        if radarr_deleted_match:
            category = 'RECOVERABLE_RADARR_DELETED_BIN'
        elif unraid_hit:
            category = 'RECOVERABLE_UNRAID'
        elif qbit_hits:
            category = 'RECOVERABLE_QBIT'
        elif recycle_hits:
            category = 'RECOVERABLE_RECYCLE'
        else:
            category = 'NEEDS_REDOWNLOAD'

        results.append({
            **d,
            'category': category,
            'radarr_deleted_match': radarr_deleted_match or '',
            'radarr_deleted_best_score_seen': radarr_deleted_best_score,
            'unraid_match': unraid_hit.get('filename') if unraid_hit else '',
            'unraid_best_score_seen': unraid_best_score,
            'qbit_matches': '; '.join(t['name'] for t in qbit_hits[:3]),
            'qbit_states': '; '.join(t['state'] for t in qbit_hits[:3]),
            'recycle_matches': '; '.join(recycle_hits[:3]),
        })

    from collections import Counter
    counts = Counter(r['category'] for r in results)
    print("\n=== Summary ===", file=sys.stderr)
    for cat in ('RECOVERABLE_RADARR_DELETED_BIN', 'RECOVERABLE_UNRAID', 'RECOVERABLE_QBIT',
                'RECOVERABLE_RECYCLE', 'NEEDS_REDOWNLOAD'):
        print(f"  {cat}: {counts.get(cat, 0)}", file=sys.stderr)

    out_path = args.out or str(Path(__file__).parent.parent / 'reports' / 'downgrade_recovery_report.csv')
    fieldnames = ['category', 'instance', 'title', 'tier', 'before_quality', 'before_score',
                  'after_quality', 'after_score', 'imported_at', 'radarr_deleted_match',
                  'radarr_deleted_best_score_seen', 'unraid_match',
                  'unraid_best_score_seen', 'qbit_matches', 'qbit_states', 'recycle_matches']
    with open(out_path, 'w', newline='') as f:
        w = csv.DictWriter(f, fieldnames=fieldnames)
        w.writeheader()
        for r in results:
            w.writerow({k: r.get(k, '') for k in fieldnames})
    print(f"\nWrote {out_path}", file=sys.stderr)


if __name__ == '__main__':
    main()
