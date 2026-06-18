"""Sync status — Radarr canonical files vs Unraid Agent comparison."""
import logging
import os
import re
import threading
import time
from fastapi import APIRouter, Depends, Query
from app.auth import require_auth
from app.config import (
    RADARR_HD_URL, RADARR_HD_KEY,
    UNRAID_AGENT_URL, UNRAID_AGENT_API_KEY,
)

import httpx

router = APIRouter()
log = logging.getLogger('curatorr.routes.sync_status')

SYNOLOGY_MOVIES = '/mnt/synology/rs-movies'
SYNOLOGY_TV     = '/mnt/synology/rs-tv'
UNRAID_MOVIES   = '/mnt/user/Media/Movies'
UNRAID_TV       = '/mnt/user/Media/TV Shows'
VIDEO_EXTS      = ('.mkv', '.mp4', '.avi', '.m4v', '.ts', '.m2ts')
SKIP_NAMES      = {'#recycle', '@eaDir', '.DS_Store'}

_movie_cache: dict = {'data': None, 'ts': 0.0, 'running': False}
_tv_cache:    dict = {'data': None, 'ts': 0.0, 'running': False}
_MOVIE_TTL = 1800   # 30 min
_TV_TTL    = 3600   # 1 hour — NFS + Agent scan is slow
_lock = threading.Lock()

# Release group at end of filename: -GROUPNAME.ext
# Must start with a letter to avoid matching codec tags like -1080p, -264
_RELEASE_GROUP_RE = re.compile(
    r'-([A-Za-z][A-Za-z0-9]{1,14})\.(mkv|mp4|avi|m4v|ts|m2ts)$',
    re.IGNORECASE,
)


# ── TRaSH scoring ─────────────────────────────────────────────────────────────
# Follows TRaSH guides quality scoring + custom format bonuses.
# Custom formats included: [Hybrid] (+100), release group (+50), Proper/Repack (+25).

def _score(filename: str, size_bytes: int = 0) -> int:
    name = filename.lower()
    if re.search(r'\b(2160p|4k|uhd)\b', name):
        res, is_4k = 4000, True
    elif re.search(r'\b1080p\b', name):
        res, is_4k = 2000, False
    elif re.search(r'\b720p\b', name):
        res, is_4k = 0, False
    else:
        res, is_4k = -500, False

    src = 0
    if re.search(r'\bremux\b', name):                            src = 2000
    elif re.search(r'\b(bluray|blu-ray|bdrip|bdremux)\b', name): src = 1500
    elif re.search(r'\b(web-dl|webdl)\b', name):                 src = 1000
    elif re.search(r'\bwebrip\b', name):                         src = 800
    elif re.search(r'\bhdtv\b', name):                           src = 200

    hdr = 0
    hdr_4k = [('dv hdr10+',800),('dv hdr10',800),('hdr10+',300),('hdr10',700),
              ('dv hlg',400),('dv sdr',300),('dolby vision',400),('dv',400),('hdr',700),('hlg',300)]
    hdr_hd = [('dv hdr10+',400),('dv hdr10',400),('hdr10+',350),('hdr10',400),
              ('dv hlg',350),('dv sdr',300),('dolby vision',350),('dv',350),('hdr',400),('hlg',300)]
    for tag, pts in (hdr_4k if is_4k else hdr_hd):
        if tag in name: hdr = pts; break

    audio = 0
    for tag, pts in [('truehd atmos',500),('truehd',450),('dts-hd ma',400),('dts:x',400),
                     ('dts-hd',350),('eac3 atmos',300),('atmos',500),('eac3',150),
                     ('dts',200),('dd+',150),('ac3',100),('aac',50)]:
        if tag in name: audio = pts; break

    hevc_pen = 0
    if re.search(r'\b(x265|h265|hevc|x\.265)\b', name) and not is_4k and hdr == 0:
        hevc_pen = -300

    size_bonus = min(int(size_bytes / 1_073_741_824 * 10), 200)

    # TRaSH Custom Format equivalents
    hybrid  = 100 if re.search(r'\[hybrid\]', name) else 0
    rg      = 50  if _RELEASE_GROUP_RE.search(filename) else 0
    proper  = 25  if re.search(r'\b(proper|repack|rerip)\b', name) else 0

    return res + src + hdr + audio + hevc_pen + size_bonus + hybrid + rg + proper


def _qlabel(filename: str) -> str:
    name = filename.lower()
    parts = []
    if re.search(r'\[hybrid\]', name):          parts.append('Hybrid')
    if re.search(r'\b(2160p|4k|uhd)\b', name):  parts.append('4K')
    elif re.search(r'\b1080p\b', name):          parts.append('1080p')
    elif re.search(r'\b720p\b', name):           parts.append('720p')
    else:                                        parts.append('SD')
    if re.search(r'\bremux\b', name):                             parts.append('Remux')
    elif re.search(r'\b(bluray|blu-ray)\b', name):                parts.append('BluRay')
    elif re.search(r'\b(web-dl|webdl)\b', name):                  parts.append('WEB-DL')
    elif re.search(r'\bwebrip\b', name):                          parts.append('WEBRip')
    elif re.search(r'\bhdtv\b', name):                            parts.append('HDTV')
    for tag in ['TrueHD Atmos','TrueHD','DTS-HD MA','DTS:X','EAC3 Atmos','Atmos','DTS','EAC3','DD+','AC3']:
        if tag.lower() in name: parts.append(tag); break
    for tag in ['DV HDR10+','DV HDR10','HDR10+','HDR10','DV HLG','DV SDR','DV','HDR','HLG']:
        if tag.lower() in name: parts.append(tag); break
    m = _RELEASE_GROUP_RE.search(filename)
    if m: parts.append(m.group(1))
    return ' · '.join(parts)


# ── Movie scan ─────────────────────────────────────────────────────────────────

def _scan_synology_movies() -> dict:
    """Scan Synology NFS movies root once. Returns folder → best (fname, size, all_count)."""
    result: dict = {}
    try:
        if not os.path.isdir(SYNOLOGY_MOVIES):
            return result
        for folder_e in os.scandir(SYNOLOGY_MOVIES):
            if not folder_e.is_dir() or folder_e.name in SKIP_NAMES:
                continue
            files = []
            try:
                for f in os.scandir(folder_e.path):
                    if not f.is_file() or not f.name.lower().endswith(VIDEO_EXTS):
                        continue
                    try:
                        sz = f.stat().st_size
                    except OSError:
                        sz = 0
                    files.append((f.name, sz))
            except OSError:
                pass
            if files:
                files.sort(key=lambda x: _score(x[0], x[1]), reverse=True)
                result[folder_e.name] = {'best': files[0], 'count': len(files)}
    except Exception as e:
        log.warning(f"Synology movies NFS scan failed: {e}")
    return result


def _run_movie_scan():
    try:
        with httpx.Client(timeout=120) as client:
            r = client.get(f"{RADARR_HD_URL}/api/v3/movie",
                           params={'includeMovieFile': 'true'},
                           headers={'X-Api-Key': RADARR_HD_KEY})
            r.raise_for_status()
            radarr_movies = r.json()

            r2 = client.get(f"{UNRAID_AGENT_URL}/inventory",
                            params={'path': UNRAID_MOVIES},
                            headers={'X-Api-Key': UNRAID_AGENT_API_KEY})
            r2.raise_for_status()
            agent_items = r2.json().get('items', [])

        # Unraid: folder → best video file by score.
        # Also track all folder names regardless of extension for the "missing" check —
        # prevents false-missing for .m2ts-only folders if agent returns them.
        unraid: dict = {}
        unraid_folders: set = set()
        for item in agent_items:
            parts = item.get('path', '').split('/')
            if len(parts) < 7:
                continue
            folder, fname = parts[5], parts[-1]
            unraid_folders.add(folder)
            if not fname.lower().endswith(VIDEO_EXTS):
                continue
            size = item.get('size_bytes', 0)
            sc = _score(fname, size)
            if folder not in unraid or sc > _score(unraid[folder][0], unraid[folder][2]):
                unraid[folder] = (fname, item['path'], size)

        # Synology NFS folder scan (actual disk, not just Radarr's view).
        # Lets us detect when Radarr is tracking an old file while a better one sits
        # in the same folder — and lets us use the real best file for comparison.
        syn_nfs = _scan_synology_movies()

        in_sync = missing = no_file = 0
        syn_better, radarr_stale, missing_list = [], [], []

        for m in radarr_movies:
            if not m.get('hasFile') or not m.get('movieFile'):
                no_file += 1
                continue
            mf = m['movieFile']
            cp = mf.get('path', '')
            folder = os.path.basename(os.path.dirname(cp))
            radarr_file = os.path.basename(cp)
            quality = mf.get('quality', {}).get('quality', {}).get('name', '?')
            radarr_size = mf.get('size', 0)
            title = f"{m.get('title', '')} ({m.get('year', '')})"

            # "Missing" = folder not on Unraid at all (not even a non-video file)
            if folder not in unraid_folders:
                missing += 1
                missing_list.append({
                    'title': title,
                    'file': radarr_file, 'quality': quality, 'size_bytes': radarr_size,
                })
                continue

            # Folder exists but no recognised video extension (e.g. .m2ts only and agent
            # doesn't index it) — treat as in_sync rather than false-missing.
            if folder not in unraid:
                in_sync += 1
                continue

            # Decision tree (matches reconcile_movie_versions logic):
            #   1. radarr_file == unraid_file → in sync
            #   2. Synology's best file == unraid_file → in sync (Unraid has best, Radarr just stale)
            #   3. Otherwise → Version Mismatch (version reconcile will fix tonight)
            #
            # NO score gate: Radarr's file is authoritative. Profile mismatches
            # (Remux when profile says Blu-ray) and container changes (m2ts → mkv)
            # are mismatches even if Radarr's new file scores lower.

            syn_info = syn_nfs.get(folder)
            if syn_info:
                syn_file, syn_size = syn_info['best']
            else:
                syn_file, syn_size = radarr_file, radarr_size

            unraid_file, unraid_path, unraid_size = unraid[folder]

            # Detect when Radarr is tracking an old file while the folder has better
            radarr_behind = (
                syn_file.lower() != radarr_file.lower()
                and _score(syn_file, syn_size) > _score(radarr_file, radarr_size)
            )

            # Case 1: Radarr's file == Unraid's file → in sync
            if radarr_file.lower() == unraid_file.lower():
                in_sync += 1
                if radarr_behind:
                    radarr_stale.append({
                        'title': title,
                        'radarr_file': radarr_file, 'radarr_size_bytes': radarr_size,
                        'syn_file': syn_file, 'syn_size_bytes': syn_size,
                        'syn_score': _score(syn_file, syn_size),
                        'syn_label': _qlabel(syn_file),
                        'note': 'Both sides have Radarr\'s file — trigger a Radarr library rescan to adopt better version',
                    })
                continue

            # Case 2: Unraid already has Synology's best file (Radarr not rescanned yet) → in sync
            if syn_file.lower() == unraid_file.lower():
                in_sync += 1
                if radarr_behind:
                    radarr_stale.append({
                        'title': title,
                        'radarr_file': radarr_file, 'radarr_size_bytes': radarr_size,
                        'syn_file': syn_file, 'syn_size_bytes': syn_size,
                        'syn_score': _score(syn_file, syn_size),
                        'syn_label': _qlabel(syn_file),
                        'note': 'Unraid has Synology\'s best file — trigger a Radarr library rescan',
                    })
                continue

            # Case 3: Mismatch — Radarr's file ≠ Unraid's file, version reconcile will fix
            syn_sc    = _score(syn_file, syn_size)
            unraid_sc = _score(unraid_file, unraid_size)
            syn_better.append({
                'title': title,
                'syn_file': radarr_file, 'syn_score': _score(radarr_file, radarr_size),
                'syn_size_bytes': radarr_size, 'syn_quality': quality,
                'syn_label': _qlabel(radarr_file),
                'unraid_file': unraid_file, 'unraid_score': unraid_sc,
                'unraid_size_bytes': unraid_size,
                'unraid_label': _qlabel(unraid_file),
                'radarr_file': None,
                'note': ('Radarr\'s file scores lower but is profile-correct — reconcile will replace Unraid copy'
                         if _score(radarr_file, radarr_size) < unraid_sc else None),
            })
            if radarr_behind:
                radarr_stale.append({
                    'title': title,
                    'radarr_file': radarr_file, 'radarr_size_bytes': radarr_size,
                    'syn_file': syn_file, 'syn_size_bytes': syn_size,
                    'syn_score': syn_sc,
                    'syn_label': _qlabel(syn_file),
                    'note': 'Synology folder has better file — trigger a Radarr library rescan after sync',
                })

        result = {
            'status': 'ready',
            'summary': {
                'total': len(radarr_movies) - no_file,
                'in_sync': in_sync,
                'missing_count': missing,
                'syn_better_count': len(syn_better),
                'radarr_stale_count': len(radarr_stale),
                'no_file_count': no_file,
            },
            'missing': sorted(missing_list, key=lambda x: x['title']),
            'syn_better': sorted(syn_better, key=lambda x: x['title']),
            'radarr_stale': sorted(radarr_stale, key=lambda x: x['title']),
        }
        with _lock:
            _movie_cache['data'] = result
            _movie_cache['ts'] = time.time()
    except Exception as e:
        log.error(f"Movie sync scan failed: {e}")
        with _lock:
            _movie_cache['data'] = {'status': 'error', 'error': str(e)}
            _movie_cache['ts'] = time.time()
    finally:
        with _lock:
            _movie_cache['running'] = False


# ── TV scan ────────────────────────────────────────────────────────────────────

EP_RE = re.compile(r'S(\d{1,2})E(\d{1,4})', re.IGNORECASE)


def _run_tv_scan():
    try:
        # Synology NFS scan — pick best file per (show, episode) by TRaSH score
        syn: dict = {}
        if os.path.isdir(SYNOLOGY_TV):
            for show_e in os.scandir(SYNOLOGY_TV):
                if not show_e.is_dir() or show_e.name in SKIP_NAMES: continue
                show = show_e.name
                try:
                    seasons = list(os.scandir(show_e.path))
                except OSError: continue
                for sea_e in seasons:
                    if not sea_e.is_dir() or sea_e.name in SKIP_NAMES: continue
                    try:
                        files = list(os.scandir(sea_e.path))
                    except OSError: continue
                    for f in files:
                        if not f.is_file(): continue
                        if not f.name.lower().endswith(VIDEO_EXTS): continue
                        ep_m = EP_RE.search(f.name)
                        if not ep_m: continue
                        ep = f"S{int(ep_m.group(1)):02d}E{int(ep_m.group(2)):04d}"
                        key = (show, ep)
                        try: size = f.stat().st_size
                        except OSError: size = 0
                        sc = _score(f.name, size)
                        if key not in syn or sc > syn[key]['score']:
                            syn[key] = {'file': f.name, 'path': f.path, 'size': size, 'score': sc}

        # Unraid Agent TV inventory — pick best file per (show, episode) by TRaSH score
        with httpx.Client(timeout=300) as client:
            r = client.get(f"{UNRAID_AGENT_URL}/inventory",
                           params={'path': UNRAID_TV},
                           headers={'X-Api-Key': UNRAID_AGENT_API_KEY})
            r.raise_for_status()
            agent_items = r.json().get('items', [])

        unraid: dict = {}
        for item in agent_items:
            parts = item.get('path', '').split('/')
            if len(parts) < 8: continue
            show, fname = parts[5], parts[-1]
            ep_m = EP_RE.search(fname)
            if not ep_m: continue
            ep = f"S{int(ep_m.group(1)):02d}E{int(ep_m.group(2)):04d}"
            key = (show, ep)
            size = item.get('size_bytes', 0)
            sc = _score(fname, size)
            if key not in unraid or sc > unraid[key]['score']:
                unraid[key] = {'file': fname, 'path': item['path'], 'size_bytes': size, 'score': sc}

        # Compare
        show_stats: dict = {}

        def _gs(show):
            if show not in show_stats:
                show_stats[show] = {'missing': [], 'syn_better': [], 'unraid_better': [], 'in_sync': 0}
            return show_stats[show]

        in_sync_total = 0
        for (show, ep), si in syn.items():
            g = _gs(show)
            if (show, ep) not in unraid:
                g['missing'].append({'ep': ep, 'file': si['file'], 'size_bytes': si['size']})
                continue
            ui = unraid[(show, ep)]
            if si['file'].lower() == ui['file'].lower():
                g['in_sync'] += 1
                in_sync_total += 1
                continue
            ss = si['score']
            us = ui['score']
            mm = {
                'ep': ep,
                'syn_file': si['file'], 'syn_score': ss, 'syn_size_bytes': si['size'],
                'syn_label': _qlabel(si['file']),
                'unraid_file': ui['file'], 'unraid_score': us, 'unraid_size_bytes': ui['size_bytes'],
                'unraid_label': _qlabel(ui['file']),
            }
            if ss > us:   g['syn_better'].append(mm)
            else:         g['unraid_better'].append(mm)

        total_missing = sum(len(v['missing']) for v in show_stats.values())
        total_syn     = sum(len(v['syn_better']) for v in show_stats.values())
        total_unraid  = sum(len(v['unraid_better']) for v in show_stats.values())

        missing_shows = sorted(
            [{'show': s, 'count': len(v['missing']),
              'episodes': sorted(v['missing'], key=lambda x: x['ep'])[:50]}
             for s, v in show_stats.items() if v['missing']],
            key=lambda x: -x['count']
        )[:100]

        syn_better_shows = sorted(
            [{'show': s, 'count': len(v['syn_better']),
              'episodes': sorted(v['syn_better'], key=lambda x: x['ep'])[:20]}
             for s, v in show_stats.items() if v['syn_better']],
            key=lambda x: -x['count']
        )[:100]

        unraid_better_shows = sorted(
            [{'show': s, 'count': len(v['unraid_better']),
              'episodes': sorted(v['unraid_better'], key=lambda x: x['ep'])[:20]}
             for s, v in show_stats.items() if v['unraid_better']],
            key=lambda x: -x['count']
        )[:100]

        result = {
            'status': 'ready',
            'summary': {
                'syn_total': len(syn),
                'unraid_total': len(unraid),
                'in_sync': in_sync_total,
                'missing_count': total_missing,
                'syn_better_count': total_syn,
                'unraid_better_count': total_unraid,
            },
            'missing_shows': missing_shows,
            'syn_better_shows': syn_better_shows,
            'unraid_better_shows': unraid_better_shows,
        }
        with _lock:
            _tv_cache['data'] = result
            _tv_cache['ts'] = time.time()
    except Exception as e:
        log.error(f"TV sync scan failed: {e}")
        with _lock:
            _tv_cache['data'] = {'status': 'error', 'error': str(e)}
            _tv_cache['ts'] = time.time()
    finally:
        with _lock:
            _tv_cache['running'] = False


# ── Endpoints ──────────────────────────────────────────────────────────────────

@router.get('/sync-status/movies')
async def sync_status_movies(refresh: bool = Query(False), _auth=Depends(require_auth)):
    now = time.time()
    with _lock:
        age = now - _movie_cache['ts']
        stale = _movie_cache['data'] is None or age > _MOVIE_TTL or refresh
        already_running = _movie_cache['running']
        if stale and not already_running:
            _movie_cache['running'] = True
            threading.Thread(target=_run_movie_scan, daemon=True).start()

    if _movie_cache['data'] is None:
        return {'status': 'scanning', 'summary': None, 'cached_age_s': 0}

    return {**_movie_cache['data'], 'cached_age_s': int(age), 'scanning': _movie_cache['running']}


@router.get('/sync-status/tv')
async def sync_status_tv(refresh: bool = Query(False), _auth=Depends(require_auth)):
    now = time.time()
    with _lock:
        age = now - _tv_cache['ts']
        stale = _tv_cache['data'] is None or age > _TV_TTL or refresh
        already_running = _tv_cache['running']
        if stale and not already_running:
            _tv_cache['running'] = True
            threading.Thread(target=_run_tv_scan, daemon=True).start()

    if _tv_cache['data'] is None:
        return {'status': 'scanning', 'summary': None, 'cached_age_s': 0}

    return {**_tv_cache['data'], 'cached_age_s': int(age), 'scanning': _tv_cache['running']}
