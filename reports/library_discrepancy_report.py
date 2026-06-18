#!/usr/bin/env python3
"""
Library sync discrepancy report.

Compares what Radarr/Sonarr manages on Synology against what's on Unraid
(via Unraid Agent), using TRaSH quality scoring to categorise mismatches.

Run directly on Mother (not inside Docker):
  python3 reports/library_discrepancy_report.py
  python3 reports/library_discrepancy_report.py --movies-only
  python3 reports/library_discrepancy_report.py --tv-only
  python3 reports/library_discrepancy_report.py --4k
  python3 reports/library_discrepancy_report.py --output /tmp/report.txt
  python3 reports/library_discrepancy_report.py --show "Breaking Bad"
"""
import os
import re
import sys
import time
import argparse
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor, as_completed

try:
    import requests
except ImportError:
    sys.exit("pip3 install requests")


# ── Load .env ─────────────────────────────────────────────────────────────────

def _load_env(path='/opt/mother/.env'):
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('#') or '=' not in line:
                continue
            k, _, v = line.partition('=')
            k = k.strip()
            # Strip inline comments only when the value isn't quoted
            if v and not v.startswith(('"', "'")):
                v = v.split('#')[0].strip()
            elif v.startswith(('"', "'")):
                v = v.strip('"\'')
            if k:
                os.environ.setdefault(k, v)


_load_env()

RADARR_HD_URL  = f"http://localhost:{os.environ.get('RADARR_HD_PORT', '7878')}"
RADARR_HD_KEY  = os.environ.get('RADARR_HD_API_KEY', '')
RADARR_4K_URL  = f"http://localhost:{os.environ.get('RADARR_4K_PORT', '7879')}"
RADARR_4K_KEY  = os.environ.get('RADARR_4K_API_KEY', '')
SONARR_HD_URL  = f"http://localhost:{os.environ.get('SONARR_HD_PORT', '8989')}"
SONARR_HD_KEY  = os.environ.get('SONARR_HD_API_KEY', '')
SONARR_4K_URL  = f"http://localhost:{os.environ.get('SONARR_4K_PORT', '8990')}"
SONARR_4K_KEY  = os.environ.get('SONARR_4K_API_KEY', '')
AGENT_URL      = os.environ.get('UNRAID_AGENT_URL', 'http://192.168.1.10:8100')
AGENT_KEY      = os.environ.get('UNRAID_AGENT_API_KEY', '')

SYNOLOGY_MOVIES    = '/mnt/synology/rs-movies'
SYNOLOGY_TV        = '/mnt/synology/rs-tv'
SYNOLOGY_4K_MOVIES = '/mnt/synology/rs-4kmedia/4kmovies'
SYNOLOGY_4K_TV     = '/mnt/synology/rs-4kmedia/4ktv'

UNRAID_MOVIES    = '/mnt/user/Media/Movies'
UNRAID_TV        = '/mnt/user/Media/TV Shows'
UNRAID_4K_MOVIES = '/mnt/user/Media/4K Movies'
UNRAID_4K_TV     = '/mnt/user/Media/4K TV Shows'

VIDEO_EXTS = ('.mkv', '.mp4', '.avi', '.m4v', '.ts')
SKIP_NAMES = {'#recycle', '@eaDir', '.DS_Store', '.lnk', '.txt'}


# ── TRaSH quality scoring (mirrors app.py _score_filename) ────────────────────

def score_filename(filename: str, size_bytes: int = 0) -> int:
    name = filename.lower()
    if re.search(r'\b(2160p|4k|uhd)\b', name):
        res_score, is_4k = 4000, True
    elif re.search(r'\b1080p\b', name):
        res_score, is_4k = 2000, False
    elif re.search(r'\b720p\b', name):
        res_score, is_4k = 0, False
    else:
        res_score, is_4k = -500, False

    src_score = 0
    if re.search(r'\bremux\b', name):
        src_score = 2000
    elif re.search(r'\b(bluray|blu-ray|bdrip|bdremux)\b', name):
        src_score = 1500
    elif re.search(r'\b(web-dl|webdl)\b', name):
        src_score = 1000
    elif re.search(r'\bwebrip\b', name):
        src_score = 800
    elif re.search(r'\bhdtv\b', name):
        src_score = 200

    hdr_score = 0
    _HDR_4K = [('dv hdr10+', 800), ('dv hdr10', 800), ('hdr10+', 300), ('hdr10', 700),
               ('dv hlg', 400), ('dv sdr', 300), ('dolby vision', 400), ('dv', 400), ('hdr', 700), ('hlg', 300)]
    _HDR_HD = [('dv hdr10+', 400), ('dv hdr10', 400), ('hdr10+', 350), ('hdr10', 400),
               ('dv hlg', 350), ('dv sdr', 300), ('dolby vision', 350), ('dv', 350), ('hdr', 400), ('hlg', 300)]
    for tag, pts in (_HDR_4K if is_4k else _HDR_HD):
        if tag in name:
            hdr_score = pts
            break

    audio_score = 0
    for tag, pts in [('truehd atmos', 500), ('truehd', 450), ('dts-hd ma', 400),
                     ('dts:x', 400), ('dts-hd', 350), ('eac3 atmos', 300), ('atmos', 500),
                     ('eac3', 150), ('dts', 200), ('dd+', 150), ('ac3', 100), ('aac', 50)]:
        if tag in name:
            audio_score = pts
            break

    hevc_penalty = 0
    if re.search(r'\b(x265|h265|hevc|x\.265)\b', name) and not is_4k and hdr_score == 0:
        hevc_penalty = -300

    size_bonus = min(int(size_bytes / 1_073_741_824 * 10), 200)
    return res_score + src_score + hdr_score + audio_score + hevc_penalty + size_bonus


def quality_label(filename: str) -> str:
    """Short quality descriptor for display."""
    name = filename.lower()
    parts = []
    if re.search(r'\b(2160p|4k|uhd)\b', name):
        parts.append('4K')
    elif re.search(r'\b1080p\b', name):
        parts.append('1080p')
    elif re.search(r'\b720p\b', name):
        parts.append('720p')
    else:
        parts.append('SD')
    if re.search(r'\bremux\b', name):
        parts.append('Remux')
    elif re.search(r'\b(bluray|blu-ray)\b', name):
        parts.append('BluRay')
    elif re.search(r'\b(web-dl|webdl)\b', name):
        parts.append('WEB-DL')
    elif re.search(r'\bwebrip\b', name):
        parts.append('WEBRip')
    elif re.search(r'\bhdtv\b', name):
        parts.append('HDTV')
    for tag in ['TrueHD Atmos', 'TrueHD', 'DTS-HD MA', 'DTS:X', 'EAC3 Atmos', 'Atmos', 'DTS', 'EAC3', 'DD+', 'AC3']:
        if tag.lower() in name:
            parts.append(tag)
            break
    for tag in ['DV HDR10+', 'DV HDR10', 'HDR10+', 'HDR10', 'DV HLG', 'DV SDR', 'DV', 'HDR', 'HLG']:
        if tag.lower() in name:
            parts.append(tag)
            break
    return ' | '.join(parts) if parts else '?'


# ── API helpers ────────────────────────────────────────────────────────────────

def radarr_get_movies(url: str, key: str) -> list:
    print(f"  Fetching Radarr movies from {url}...", flush=True)
    r = requests.get(f"{url}/api/v3/movie", params={'includeMovieFile': 'true'},
                     headers={'X-Api-Key': key}, timeout=120)
    r.raise_for_status()
    return r.json()


def sonarr_get_series(url: str, key: str) -> list:
    print(f"  Fetching Sonarr series list from {url}...", flush=True)
    r = requests.get(f"{url}/api/v3/series", headers={'X-Api-Key': key}, timeout=120)
    r.raise_for_status()
    return r.json()


def sonarr_get_episode_files(url: str, key: str, series_id: int) -> list:
    r = requests.get(f"{url}/api/v3/episodeFile",
                     params={'seriesId': series_id},
                     headers={'X-Api-Key': key}, timeout=30)
    r.raise_for_status()
    return r.json()


def agent_get_inventory(unraid_path: str, refresh: bool = False) -> dict:
    """Returns dict: folder_name → list of {filename, path, size_bytes}"""
    print(f"  Fetching Unraid inventory: {unraid_path}...", flush=True)
    params = {'path': unraid_path}
    if refresh:
        params['refresh'] = 'true'
    r = requests.get(f"{AGENT_URL}/inventory", params=params,
                     headers={'X-Api-Key': AGENT_KEY}, timeout=300)
    r.raise_for_status()
    items = r.json().get('items', [])
    inventory: dict = {}
    for item in items:
        path = item.get('path', '')
        parts = path.split('/')
        if len(parts) < 7:
            continue
        folder = parts[5]
        fname = parts[-1]
        size = item.get('size_bytes', 0)
        if folder not in inventory:
            inventory[folder] = []
        inventory[folder].append({'filename': fname, 'path': path, 'size_bytes': size})
    return inventory


# ── Movie analysis ─────────────────────────────────────────────────────────────

def analyse_movies(label: str, radarr_url: str, radarr_key: str,
                   unraid_path: str, show_filter: str = None) -> dict:
    """Compare Radarr canonical files vs Unraid inventory."""
    movies = radarr_get_movies(radarr_url, radarr_key)
    unraid = agent_get_inventory(unraid_path)

    in_sync = []
    missing = []
    syn_better = []   # Synology (Radarr) has better/newer version
    unraid_better = []  # Unraid somehow has a better version
    no_file = []      # Radarr entry with no imported file

    for m in movies:
        title = m.get('title', '')
        year = m.get('year', '')
        display = f"{title} ({year})"

        if show_filter and show_filter.lower() not in title.lower():
            continue

        if not m.get('hasFile') or not m.get('movieFile'):
            no_file.append({'title': display})
            continue

        mf = m['movieFile']
        radarr_path = mf.get('path', '')
        folder = os.path.basename(os.path.dirname(radarr_path))
        expected_fname = os.path.basename(radarr_path)
        radarr_quality = mf.get('quality', {}).get('quality', {}).get('name', '?')
        radarr_size = mf.get('size', 0)

        if folder not in unraid:
            missing.append({
                'title': display, 'folder': folder,
                'file': expected_fname, 'quality': radarr_quality,
                'size_bytes': radarr_size,
            })
            continue

        # Pick best (largest) file on Unraid for this folder
        unraid_files = sorted(unraid[folder], key=lambda x: x['size_bytes'], reverse=True)
        best_unraid = unraid_files[0]

        if expected_fname.lower() == best_unraid['filename'].lower():
            in_sync.append({'title': display})
            continue

        syn_score = score_filename(expected_fname, radarr_size)
        unraid_score = score_filename(best_unraid['filename'], best_unraid['size_bytes'])

        entry = {
            'title': display, 'folder': folder,
            'syn_file': expected_fname, 'syn_quality': radarr_quality,
            'syn_size': radarr_size, 'syn_score': syn_score,
            'unraid_file': best_unraid['filename'],
            'unraid_size': best_unraid['size_bytes'], 'unraid_score': unraid_score,
        }
        if syn_score > unraid_score:
            syn_better.append(entry)
        else:
            unraid_better.append(entry)

    return {
        'label': label,
        'in_sync': in_sync, 'missing': missing,
        'syn_better': syn_better, 'unraid_better': unraid_better,
        'no_file': no_file,
    }


# ── TV analysis ────────────────────────────────────────────────────────────────

EP_RE = re.compile(r'S(\d{1,2})E(\d{1,4})', re.IGNORECASE)


def _scan_synology_tv(root: str, show_filter: str = None) -> dict:
    """Returns dict: (show_folder, ep_key) → {filename, path, size}"""
    result: dict = {}
    try:
        show_entries = list(os.scandir(root))
    except OSError as e:
        print(f"  WARNING: Cannot scan {root}: {e}", flush=True)
        return result

    for show_entry in show_entries:
        if not show_entry.is_dir() or show_entry.name in SKIP_NAMES:
            continue
        if show_filter and show_filter.lower() not in show_entry.name.lower():
            continue
        show = show_entry.name
        try:
            season_entries = list(os.scandir(show_entry.path))
        except OSError:
            continue
        for season_entry in season_entries:
            if not season_entry.is_dir() or season_entry.name in SKIP_NAMES:
                continue
            try:
                file_entries = list(os.scandir(season_entry.path))
            except OSError:
                continue
            for f in file_entries:
                if not f.is_file():
                    continue
                if not f.name.lower().endswith(VIDEO_EXTS):
                    continue
                m = EP_RE.search(f.name)
                if not m:
                    continue
                ep_key = f"S{int(m.group(1)):02d}E{int(m.group(2)):04d}"
                key = (show, ep_key)
                try:
                    size = f.stat().st_size
                except OSError:
                    size = 0
                # Keep largest file for same (show, ep) if duplicates exist
                if key not in result or size > result[key]['size']:
                    result[key] = {'filename': f.name, 'path': f.path, 'size': size}
    return result


def _build_unraid_tv_map(unraid_inventory: dict) -> dict:
    """
    Build dict: (show_folder, ep_key) → {filename, path, size_bytes}
    unraid_inventory comes from agent_get_inventory which keys by folder.
    For TV: folder = show name, but items have full paths like
    /mnt/user/Media/TV Shows/<show>/<season>/<file>
    """
    # Need to rebuild from raw items since TV is nested show/season/file
    return unraid_inventory  # caller needs raw path structure


def agent_get_tv_inventory(unraid_path: str) -> dict:
    """Returns dict: (show_folder, ep_key) → {filename, path, size_bytes}"""
    print(f"  Fetching Unraid TV inventory (may take ~60s)...", flush=True)
    r = requests.get(f"{AGENT_URL}/inventory", params={'path': unraid_path},
                     headers={'X-Api-Key': AGENT_KEY}, timeout=300)
    r.raise_for_status()
    items = r.json().get('items', [])
    result: dict = {}
    for item in items:
        path = item.get('path', '')
        parts = path.split('/')
        # /mnt/user/Media/TV Shows/<show>/<season>/<file>
        if len(parts) < 8:
            continue
        show_folder = parts[5]
        fname = parts[-1]
        m = EP_RE.search(fname)
        if not m:
            continue
        ep_key = f"S{int(m.group(1)):02d}E{int(m.group(2)):04d}"
        key = (show_folder, ep_key)
        size = item.get('size_bytes', 0)
        if key not in result or size > result[key]['size_bytes']:
            result[key] = {'filename': fname, 'path': path, 'size_bytes': size}
    return result


def analyse_tv(label: str, synology_root: str, unraid_path: str,
               show_filter: str = None) -> dict:
    """Compare Synology NFS episodes vs Unraid Agent inventory."""
    print(f"  Scanning Synology TV NFS {synology_root}...", flush=True)
    t0 = time.time()
    syn_map = _scan_synology_tv(synology_root, show_filter)
    print(f"    Synology scan: {len(syn_map):,} episodes in {time.time()-t0:.1f}s", flush=True)

    unraid_map = agent_get_tv_inventory(unraid_path)
    print(f"    Unraid inventory: {len(unraid_map):,} episodes", flush=True)

    # Per-show aggregation
    show_stats: dict = {}  # show → {missing, syn_better, unraid_better, in_sync}

    def _show_entry(show):
        if show not in show_stats:
            show_stats[show] = {'missing': [], 'syn_better': [], 'unraid_better': [], 'in_sync': 0}
        return show_stats[show]

    in_sync_total = 0
    for (show, ep_key), syn_info in syn_map.items():
        entry = _show_entry(show)
        syn_fname = syn_info['filename']
        syn_size = syn_info['size']

        if (show, ep_key) not in unraid_map:
            entry['missing'].append({
                'ep_key': ep_key, 'file': syn_fname, 'size': syn_size,
            })
            continue

        unraid_info = unraid_map[(show, ep_key)]
        unraid_fname = unraid_info['filename']
        unraid_size = unraid_info['size_bytes']

        if syn_fname.lower() == unraid_fname.lower():
            entry['in_sync'] += 1
            in_sync_total += 1
            continue

        syn_score = score_filename(syn_fname, syn_size)
        unraid_score = score_filename(unraid_fname, unraid_size)

        mismatch = {
            'ep_key': ep_key,
            'syn_file': syn_fname, 'syn_score': syn_score, 'syn_size': syn_size,
            'unraid_file': unraid_fname, 'unraid_score': unraid_score,
            'unraid_size': unraid_size,
        }
        if syn_score > unraid_score:
            entry['syn_better'].append(mismatch)
        else:
            entry['unraid_better'].append(mismatch)

    return {
        'label': label,
        'show_stats': show_stats,
        'syn_total': len(syn_map),
        'unraid_total': len(unraid_map),
        'in_sync_total': in_sync_total,
    }


# ── Formatting ─────────────────────────────────────────────────────────────────

W = 72

def hr(char='─'):
    return char * W

def section(title: str):
    return f"\n{'━' * W}\n  {title}\n{'━' * W}"

def _gb(b: int) -> str:
    return f"{b/1_073_741_824:.1f} GB"


def format_movie_report(result: dict, max_list: int = 50) -> str:
    lines = [section(result['label'])]

    total = len(result['in_sync']) + len(result['missing']) + len(result['syn_better']) + \
            len(result['unraid_better']) + len(result['no_file'])
    total_w_file = total - len(result['no_file'])

    lines.append(f"\n  Total in Radarr (with files): {total_w_file:,}")
    lines.append(f"  ✅ In sync:                   {len(result['in_sync']):>6,}  ({100*len(result['in_sync'])/max(total_w_file,1):.1f}%)")
    lines.append(f"  ❌ Missing from Unraid:        {len(result['missing']):>6,}  ({100*len(result['missing'])/max(total_w_file,1):.1f}%)")
    lines.append(f"  ⬆  Synology upgrade available: {len(result['syn_better']):>6,}  ({100*len(result['syn_better'])/max(total_w_file,1):.1f}%)  ← will be queued by version reconcile")
    lines.append(f"  ⬇  Unraid has better version:  {len(result['unraid_better']):>6,}  ({100*len(result['unraid_better'])/max(total_w_file,1):.1f}%)  ← Synology may need Upgraderr")
    lines.append(f"  ⚪ No file in Radarr yet:       {len(result['no_file']):>6,}")

    if result['missing']:
        lines.append(f"\n{'─'*W}")
        n = len(result['missing'])
        lines.append(f"  MISSING FROM UNRAID  ({n:,} movies)" + (f"  — showing {max_list}" if n > max_list else ""))
        lines.append(f"{'─'*W}")
        for m in sorted(result['missing'], key=lambda x: x['title'])[:max_list]:
            lines.append(f"  {m['title']:<45}  {m['quality']:<20}  {_gb(m['size_bytes'])}")

    if result['syn_better']:
        lines.append(f"\n{'─'*W}")
        n = len(result['syn_better'])
        lines.append(f"  SYNOLOGY HAS BETTER VERSION  ({n} movies) — queued tonight")
        lines.append(f"{'─'*W}")
        for m in sorted(result['syn_better'], key=lambda x: x['title'])[:max_list]:
            lines.append(f"\n  {m['title']}")
            lines.append(f"    Synology [{m['syn_score']:>5}]: {m['syn_file'][:65]}  {_gb(m['syn_size'])}")
            lines.append(f"    Unraid   [{m['unraid_score']:>5}]: {m['unraid_file'][:65]}  {_gb(m['unraid_size'])}")

    if result['unraid_better']:
        lines.append(f"\n{'─'*W}")
        n = len(result['unraid_better'])
        lines.append(f"  ⚠  UNRAID HAS BETTER VERSION  ({n} movies) — Synology needs Upgraderr")
        lines.append(f"{'─'*W}")
        for m in sorted(result['unraid_better'], key=lambda x: x['title'])[:max_list]:
            lines.append(f"\n  {m['title']}")
            lines.append(f"    Synology [{m['syn_score']:>5}]: {m['syn_file'][:65]}  {_gb(m['syn_size'])}")
            lines.append(f"    Unraid   [{m['unraid_score']:>5}]: {m['unraid_file'][:65]}  {_gb(m['unraid_size'])}")

    return '\n'.join(lines)


def format_tv_report(result: dict, max_shows: int = 30, show_filter: str = None) -> str:
    lines = [section(result['label'])]
    stats = result['show_stats']

    total_missing = sum(len(v['missing']) for v in stats.values())
    total_syn_better = sum(len(v['syn_better']) for v in stats.values())
    total_unraid_better = sum(len(v['unraid_better']) for v in stats.values())
    total_in_sync = result['in_sync_total']
    syn_total = result['syn_total']

    lines.append(f"\n  Episodes on Synology:         {syn_total:>8,}")
    lines.append(f"  Episodes on Unraid:           {result['unraid_total']:>8,}")
    lines.append(f"  ✅ In sync:                   {total_in_sync:>8,}  ({100*total_in_sync/max(syn_total,1):.1f}%)")
    lines.append(f"  ❌ Missing from Unraid:        {total_missing:>8,}  ({100*total_missing/max(syn_total,1):.1f}%)")
    lines.append(f"  ⬆  Synology upgrade available: {total_syn_better:>8,}  ({100*total_syn_better/max(syn_total,1):.1f}%)")
    lines.append(f"  ⬇  Unraid has better version:  {total_unraid_better:>8,}  ({100*total_unraid_better/max(syn_total,1):.1f}%)")

    shows_with_missing = [(s, v) for s, v in stats.items() if v['missing']]
    if shows_with_missing:
        shows_with_missing.sort(key=lambda x: len(x[1]['missing']), reverse=True)
        lines.append(f"\n{'─'*W}")
        n = len(shows_with_missing)
        lines.append(f"  SHOWS WITH MISSING EPISODES  ({n} shows, {total_missing:,} episodes total)"
                     + (f"  — top {max_shows}" if n > max_shows else ""))
        lines.append(f"{'─'*W}")
        for show, v in shows_with_missing[:max_shows]:
            ep_list = sorted(v['missing'], key=lambda x: x['ep_key'])
            ep_keys = [e['ep_key'] for e in ep_list]
            # Group into ranges by season
            seasons: dict = {}
            for ek in ep_keys:
                sn = ek[:3]
                seasons.setdefault(sn, []).append(ek)
            season_summary = ', '.join(
                f"{sn}: {len(eps)} ep" for sn, eps in sorted(seasons.items())
            )
            lines.append(f"  {show:<50}  {season_summary}")

        if show_filter and shows_with_missing:
            # Show episode detail for the filtered show
            for show, v in shows_with_missing:
                lines.append(f"\n  Detail for: {show}")
                for ep in sorted(v['missing'], key=lambda x: x['ep_key']):
                    lines.append(f"    {ep['ep_key']}  {ep['file'][:60]}  {_gb(ep['size'])}")

    shows_with_syn_better = [(s, v) for s, v in stats.items() if v['syn_better']]
    if shows_with_syn_better:
        shows_with_syn_better.sort(key=lambda x: len(x[1]['syn_better']), reverse=True)
        lines.append(f"\n{'─'*W}")
        n = len(shows_with_syn_better)
        lines.append(f"  SYNOLOGY HAS BETTER VERSION  ({n} shows, {total_syn_better:,} episodes) — queued tonight")
        lines.append(f"{'─'*W}")
        for show, v in shows_with_syn_better[:max_shows]:
            cnt = len(v['syn_better'])
            sample = v['syn_better'][0]
            lines.append(f"  {show:<50}  {cnt} episode(s)")
            if show_filter or cnt <= 3:
                for ep in sorted(v['syn_better'], key=lambda x: x['ep_key']):
                    lines.append(f"    {ep['ep_key']}  Syn [{ep['syn_score']:>5}]: {ep['syn_file'][:50]}  {_gb(ep['syn_size'])}")
                    lines.append(f"         Unraid [{ep['unraid_score']:>5}]: {ep['unraid_file'][:50]}  {_gb(ep['unraid_size'])}")
            else:
                lines.append(f"    e.g. {sample['ep_key']}  Syn [{sample['syn_score']:>5}]: {sample['syn_file'][:45]}")
                lines.append(f"                  Unraid [{sample['unraid_score']:>5}]: {sample['unraid_file'][:45]}")

    shows_with_unraid_better = [(s, v) for s, v in stats.items() if v['unraid_better']]
    if shows_with_unraid_better:
        shows_with_unraid_better.sort(key=lambda x: len(x[1]['unraid_better']), reverse=True)
        lines.append(f"\n{'─'*W}")
        n = len(shows_with_unraid_better)
        lines.append(f"  ⚠  UNRAID HAS BETTER VERSION  ({n} shows, {total_unraid_better:,} episodes) — investigate")
        lines.append(f"{'─'*W}")
        for show, v in shows_with_unraid_better[:max_shows]:
            cnt = len(v['unraid_better'])
            lines.append(f"  {show:<50}  {cnt} episode(s)")
            if show_filter or cnt <= 2:
                for ep in sorted(v['unraid_better'], key=lambda x: x['ep_key']):
                    lines.append(f"    {ep['ep_key']}  Syn [{ep['syn_score']:>5}]: {ep['syn_file'][:50]}  {_gb(ep['syn_size'])}")
                    lines.append(f"         Unraid [{ep['unraid_score']:>5}]: {ep['unraid_file'][:50]}  {_gb(ep['unraid_size'])}")

    return '\n'.join(lines)


# ── Main ───────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser(description='Library sync discrepancy report')
    parser.add_argument('--movies-only', action='store_true', help='Movies only')
    parser.add_argument('--tv-only', action='store_true', help='TV only')
    parser.add_argument('--4k', dest='include_4k', action='store_true', help='Include 4K libraries')
    parser.add_argument('--show', default=None, help='Filter to a specific show/movie title')
    parser.add_argument('--output', default=None, help='Save report to file (also prints to stdout)')
    parser.add_argument('--max', type=int, default=50, help='Max items to list per section (default: 50)')
    args = parser.parse_args()

    do_movies = not args.tv_only
    do_tv = not args.movies_only

    header = [
        '=' * W,
        f"  LIBRARY SYNC DISCREPANCY REPORT — {datetime.now().strftime('%Y-%m-%d %H:%M')}",
        '=' * W,
        '',
        f"  Source of truth: Radarr/Sonarr (Chris's Synology) → Unraid (Ali)",
        f"  Unraid Agent: {AGENT_URL}",
    ]
    if args.show:
        header.append(f"  Filter: '{args.show}'")
    header.append('')

    out = '\n'.join(header)
    print(out, flush=True)

    sections = []

    if do_movies:
        print("\n[HD MOVIES]", flush=True)
        if not RADARR_HD_KEY:
            sections.append("  ERROR: RADARR_HD_API_KEY not set")
        else:
            try:
                res = analyse_movies(
                    "HD MOVIES  (Radarr HD → Unraid /mnt/user/Media/Movies)",
                    RADARR_HD_URL, RADARR_HD_KEY,
                    UNRAID_MOVIES, args.show
                )
                sections.append(format_movie_report(res, args.max))
            except Exception as e:
                sections.append(f"  ERROR fetching HD movies: {e}")

        if args.include_4k:
            print("\n[4K MOVIES]", flush=True)
            try:
                res = analyse_movies(
                    "4K MOVIES  (Radarr 4K → Unraid /mnt/user/Media/4K Movies)",
                    RADARR_4K_URL, RADARR_4K_KEY,
                    UNRAID_4K_MOVIES, args.show
                )
                sections.append(format_movie_report(res, args.max))
            except Exception as e:
                sections.append(f"  ERROR fetching 4K movies: {e}")

    if do_tv:
        print("\n[HD TV]", flush=True)
        if not os.path.isdir(SYNOLOGY_TV):
            sections.append(f"  ERROR: Synology TV mount not accessible: {SYNOLOGY_TV}")
        else:
            try:
                res = analyse_tv(
                    "HD TV  (Synology rs-tv → Unraid /mnt/user/Media/TV Shows)",
                    SYNOLOGY_TV, UNRAID_TV, args.show
                )
                sections.append(format_tv_report(res, args.max, args.show))
            except Exception as e:
                sections.append(f"  ERROR analysing TV: {e}")

        if args.include_4k:
            print("\n[4K TV]", flush=True)
            if os.path.isdir(SYNOLOGY_4K_TV):
                try:
                    res = analyse_tv(
                        "4K TV  (Synology rs-4kmedia/4ktv → Unraid /mnt/user/Media/4K TV Shows)",
                        SYNOLOGY_4K_TV, UNRAID_4K_TV, args.show
                    )
                    sections.append(format_tv_report(res, args.max, args.show))
                except Exception as e:
                    sections.append(f"  ERROR analysing 4K TV: {e}")

    full_report = out + '\n' + '\n'.join(sections) + '\n'

    print('\n' + '\n'.join(sections), flush=True)

    if args.output:
        with open(args.output, 'w') as f:
            f.write(full_report)
        print(f"\n  Report saved to {args.output}", flush=True)


if __name__ == '__main__':
    main()
