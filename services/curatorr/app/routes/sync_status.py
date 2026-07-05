"""Sync status — Radarr canonical files vs Unraid Agent comparison."""
import asyncio
import json
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

_movie_cache:  dict = {'data': None, 'ts': 0.0, 'running': False}
_tv_cache:     dict = {'data': None, 'ts': 0.0, 'running': False}
_parity_cache: dict = {'data': None, 'ts': 0.0, 'running': False}
_MOVIE_TTL  = 1800   # 30 min
_TV_TTL     = 3600   # 1 hour — NFS + Agent scan is slow
_PARITY_TTL = 3600   # 1 hour — full Synology NFS walk + Agent scan is ~2 min
_lock = threading.Lock()

# Release group at end of filename: -GROUPNAME.ext
# Must start with a letter to avoid matching codec tags like -1080p, -264
_RELEASE_GROUP_RE = re.compile(
    r'-([A-Za-z][A-Za-z0-9]{1,14})\.(mkv|mp4|avi|m4v|ts|m2ts)$',
    re.IGNORECASE,
)


# ── TRaSH scoring — loaded from shared JSON config ────────────────────────────
_SCORING_PATH = os.environ.get('TRASH_SCORING_PATH', '/app/scoring/trash_scoring.json')
with open(_SCORING_PATH) as _f:
    _SC = json.load(_f)

def _score(filename: str, size_bytes: int = 0, media_type: str = 'movie') -> int:
    """media_type='tv' uses the TV source ranking (WEB-DL > Bluray) instead of the
    movie ranking (Bluray > WEB-DL) — see CLAUDE.md Shared TRaSH Scoring Config.
    Fixed 2026-07-02: this function had no media_type distinction at all and used
    the movie ranking for TV too, the same bug found and fixed in sync-webhook's
    _score_filename() the same day."""
    name = filename.lower()
    src_table = _SC.get('tv_source', _SC['source']) if media_type == 'tv' else _SC['source']
    if re.search(r'\b2160p\b', name):
        res, is_4k = _SC['resolution']['2160p'], True
    elif re.search(r'\b1080p\b', name):
        res, is_4k = _SC['resolution']['1080p'], False
    elif re.search(r'\b720p\b', name):
        res, is_4k = _SC['resolution']['720p'], False
    elif re.search(r'\b(4k|uhd)\b', name):
        res, is_4k = _SC['resolution']['4k_uhd_fallback'], True
    else:
        res, is_4k = _SC['resolution']['sd'], False

    src = 0
    if re.search(r'\bremux\b', name):                            src = src_table['remux']
    elif re.search(r'\b(bluray|blu-ray|bdrip|bdremux)\b', name): src = src_table['bluray']
    elif re.search(r'\b(web-dl|webdl)\b', name):                 src = src_table['web_dl']
    elif re.search(r'\bwebrip\b', name):                         src = src_table['webrip']
    elif re.search(r'\bhdtv\b', name):                           src = src_table['hdtv']

    hdr = 0
    for tag, pts in (_SC['hdr_4k'] if is_4k else _SC['hdr_hd']):
        if tag in name: hdr = pts; break

    audio = 0
    for tag, pts in _SC['audio']:
        if tag in name: audio = pts; break

    hevc_pen = 0
    if re.search(r'\b(x265|h265|hevc|x\.265)\b', name) and not is_4k and hdr == 0:
        hevc_pen = _SC['hevc_penalty_hd_no_hdr']

    size_bonus = min(int(size_bytes / 1_073_741_824 * _SC['size_bonus_per_gb']), _SC['size_bonus_cap'])

    hybrid = _SC['custom_formats']['hybrid']        if re.search(r'\[hybrid\]', name) else 0
    rg     = _SC['custom_formats']['release_group'] if _RELEASE_GROUP_RE.search(filename) else 0
    proper = _SC['custom_formats']['proper_repack'] if re.search(r'\b(proper|repack|rerip)\b', name) else 0

    return res + src + hdr + audio + hevc_pen + size_bonus + hybrid + rg + proper


def _qlabel(filename: str) -> str:
    name = filename.lower()
    parts = []
    if re.search(r'\[hybrid\]', name):          parts.append('Hybrid')
    if re.search(r'\b2160p\b', name):           parts.append('4K')
    elif re.search(r'\b1080p\b', name):         parts.append('1080p')
    elif re.search(r'\b(4k|uhd)\b', name):      parts.append('4K')
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
        syn_better, unraid_better, radarr_stale, missing_list = [], [], [], []

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

            # Case 3: Mismatch. Corrected 2026-07-02 — this used to imply "Unraid
            # score >= Synology score" meant Unraid's file was safe and wouldn't be
            # touched. That's no longer true: sync-webhook's reconcile now always
            # syncs Synology's (Radarr's) file to Unraid regardless of score (Profile
            # Authority — see CLAUDE.md). syn_score/unraid_score below are kept as
            # informational metadata only (which side scores higher), NOT a
            # prediction of what will happen — both "syn_better" and "unraid_better"
            # entries get the same Syn→Unraid treatment on the next reconcile run.
            radarr_sc = _score(radarr_file, radarr_size)
            unraid_sc = _score(unraid_file, unraid_size)
            entry = {
                'title': title,
                'syn_file': radarr_file, 'syn_score': radarr_sc,
                'syn_size_bytes': radarr_size, 'syn_quality': quality,
                'syn_label': _qlabel(radarr_file),
                'unraid_file': unraid_file, 'unraid_score': unraid_sc,
                'unraid_size_bytes': unraid_size,
                'unraid_label': _qlabel(unraid_file),
            }
            if radarr_sc > unraid_sc:
                syn_better.append(entry)
            else:
                unraid_better.append(entry)
            if radarr_behind:
                radarr_stale.append({
                    'title': title,
                    'radarr_file': radarr_file, 'radarr_size_bytes': radarr_size,
                    'syn_file': syn_file, 'syn_size_bytes': syn_size,
                    'syn_score': _score(syn_file, syn_size),
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
                'unraid_better_count': len(unraid_better),
                'radarr_stale_count': len(radarr_stale),
                'no_file_count': no_file,
            },
            'missing': sorted(missing_list, key=lambda x: x['title']),
            'syn_better': sorted(syn_better, key=lambda x: x['title']),
            'unraid_better': sorted(unraid_better, key=lambda x: x['title']),
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
                        sc = _score(f.name, size, media_type='tv')
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
            sc = _score(fname, size, media_type='tv')
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


# ── TV Parity scan (full Synology NFS walk vs Unraid Agent) ────────────────────
EP_RE      = re.compile(r'[Ss](\d{1,2})[Ee](\d{1,4})')
VIDEO_EXTS_TUPLE = ('.mkv', '.mp4', '.avi', '.ts', '.m4v', '.m2ts')


def _tv_ep_key(fname: str):
    m = EP_RE.search(fname)
    return f"S{int(m.group(1)):02d}E{int(m.group(2)):04d}" if m else None


def _should_sync_tv(filename: str):
    """Same quality gate as sync-webhook: skip 720p/SD and x265-no-HDR."""
    name = filename.lower()
    if re.search(r'\b(480p|576p|720p|sd)\b', name):
        return False, '720p/SD'
    is_hevc = bool(re.search(r'\b(x265|h265|hevc|x\.265)\b', name))
    has_hdr  = bool(re.search(r'\b(hdr10\+?|hdr10|hdr|dv|dovi|dolby\.?vision|hlg|pq)\b', name))
    if is_hevc and not has_hdr:
        return False, 'x265-no-HDR'
    return True, 'ok'


def _run_tv_parity_scan():
    t0 = time.time()
    try:
        # ── 1. Scan Synology NFS ───────────────────────────────────────────
        syn_eps: dict = {}   # (show, ep_key) → {fname, size, season}
        if os.path.isdir(SYNOLOGY_TV):
            for show_e in os.scandir(SYNOLOGY_TV):
                if not show_e.is_dir() or show_e.name in SKIP_NAMES:
                    continue
                try:
                    for season_e in os.scandir(show_e.path):
                        if not season_e.is_dir() or season_e.name in SKIP_NAMES:
                            continue
                        for f_e in os.scandir(season_e.path):
                            if not f_e.is_file():
                                continue
                            fname = f_e.name
                            if not fname.lower().endswith(VIDEO_EXTS_TUPLE):
                                continue
                            epk = _tv_ep_key(fname)
                            if not epk:
                                continue
                            k = (show_e.name, epk)
                            try:
                                sz = f_e.stat().st_size
                            except OSError:
                                sz = 0
                            if k not in syn_eps or sz > syn_eps[k]['size']:
                                syn_eps[k] = {'fname': fname, 'size': sz, 'season': season_e.name}
                except (PermissionError, OSError):
                    pass

        # ── 2. Fetch Unraid Agent inventory ───────────────────────────────
        with httpx.Client(timeout=240) as client:
            r = client.get(f"{UNRAID_AGENT_URL}/inventory",
                           params={'path': UNRAID_TV, 'refresh': 'true'},
                           headers={'X-Api-Key': UNRAID_AGENT_API_KEY})
            r.raise_for_status()
            agent_items = r.json().get('items', [])

        unraid_eps: dict = {}   # (show, ep_key) → {fname, size}
        for item in agent_items:
            parts = item.get('path', '').split('/')
            if len(parts) < 8:
                continue
            show_folder = parts[5]
            fname = parts[-1]
            if not fname.lower().endswith(VIDEO_EXTS_TUPLE):
                continue
            epk = _tv_ep_key(fname)
            if not epk:
                continue
            k = (show_folder, epk)
            sz = item.get('size_bytes', 0)
            if k not in unraid_eps or sz > unraid_eps[k]['size']:
                unraid_eps[k] = {'fname': fname, 'size': sz}

        # ── 3. Compare ────────────────────────────────────────────────────
        from collections import defaultdict
        missing_by_show    = defaultdict(list)   # on Syn (syncable), not on Unraid
        unraid_only_pass   = defaultdict(list)   # on Unraid, not on Syn, passes filter
        unraid_only_filt   = defaultdict(list)   # on Unraid, not on Syn, filtered quality
        mismatch_by_show   = defaultdict(list)   # both have it, different filename

        for (show, epk), si in syn_eps.items():
            sync_ok, _ = _should_sync_tv(si['fname'])
            if not sync_ok:
                continue  # only track syncable Synology episodes here
            if (show, epk) not in unraid_eps:
                missing_by_show[show].append({
                    'ep': epk, 'file': si['fname'],
                    'size_bytes': si['size'], 'season': si['season'],
                })
            else:
                ui = unraid_eps[(show, epk)]
                if si['fname'].lower() != ui['fname'].lower():
                    syn_sc  = _score(si['fname'], si['size'], media_type='tv')
                    unr_sc  = _score(ui['fname'], ui['size'], media_type='tv')
                    mismatch_by_show[show].append({
                        'ep': epk,
                        'syn_file': si['fname'],  'syn_score': syn_sc,  'syn_size_bytes': si['size'],
                        'unraid_file': ui['fname'], 'unraid_score': unr_sc, 'unraid_size_bytes': ui['size'],
                        'syn_better': syn_sc > unr_sc,
                    })

        syn_keys = set(syn_eps.keys())
        for (show, epk), ui in unraid_eps.items():
            if (show, epk) not in syn_keys:
                sync_ok, reason = _should_sync_tv(ui['fname'])
                entry = {'ep': epk, 'file': ui['fname'], 'size_bytes': ui['size'], 'filter_reason': reason}
                if sync_ok:
                    unraid_only_pass[show].append(entry)
                else:
                    unraid_only_filt[show].append(entry)

        def _group(d, sort_key='ep', limit=200):
            return sorted(
                [{'show': s,
                  'count': len(eps),
                  'total_bytes': sum(e['size_bytes'] for e in eps),
                  'episodes': sorted(eps, key=lambda x: x[sort_key])[:50]}
                 for s, eps in d.items()],
                key=lambda x: -x['count']
            )[:limit]

        all_mismatches = [e for v in mismatch_by_show.values() for e in v]
        result = {
            'status': 'ready',
            'elapsed_s': int(time.time() - t0),
            'summary': {
                'syn_total':             len(syn_eps),
                'unraid_total':          len(unraid_eps),
                'missing_count':         sum(len(v) for v in missing_by_show.values()),
                'unraid_pass_count':     sum(len(v) for v in unraid_only_pass.values()),
                'unraid_filt_count':     sum(len(v) for v in unraid_only_filt.values()),
                'mismatch_count':        len(all_mismatches),
                'mismatch_syn_better':   sum(1 for e in all_mismatches if e.get('syn_better')),
                'mismatch_unraid_better': sum(1 for e in all_mismatches if not e.get('syn_better')),
                'unraid_pass_bytes':     sum(e['size_bytes'] for v in unraid_only_pass.values() for e in v),
                'unraid_filt_bytes':     sum(e['size_bytes'] for v in unraid_only_filt.values() for e in v),
            },
            'missing_shows':     _group(missing_by_show),
            'unraid_only_pass':  _group(unraid_only_pass),
            'unraid_only_filt':  _group(unraid_only_filt),
            'mismatch_shows':    _group(mismatch_by_show),
        }
        with _lock:
            _parity_cache['data'] = result
            _parity_cache['ts']   = time.time()
    except Exception as e:
        log.error(f"TV parity scan failed: {e}")
        with _lock:
            _parity_cache['data'] = {'status': 'error', 'error': str(e)}
            _parity_cache['ts']   = time.time()
    finally:
        with _lock:
            _parity_cache['running'] = False


@router.get('/sync-status/tv-parity')
async def sync_status_tv_parity(refresh: bool = Query(False), _auth=Depends(require_auth)):
    now = time.time()
    with _lock:
        age = now - _parity_cache['ts']
        stale = _parity_cache['data'] is None or age > _PARITY_TTL or refresh
        already_running = _parity_cache['running']
        if stale and not already_running:
            _parity_cache['running'] = True
            threading.Thread(target=_run_tv_parity_scan, daemon=True).start()

    if _parity_cache['data'] is None:
        return {'status': 'scanning', 'summary': None, 'cached_age_s': 0}

    return {**_parity_cache['data'], 'cached_age_s': int(age), 'scanning': _parity_cache['running']}


_SYNC_WEBHOOK_INTERNAL = os.environ.get('SYNC_WEBHOOK_URL', 'http://sync-webhook:5000')

_DIRECTION_LABELS = {
    'MovieReverseSync': 'Unraid → Syn',
    'TVReverseSync':    'Unraid → Syn',
    'MovieVersionSync': 'Syn → Unraid',
    'TVVersionSync':    'Syn → Unraid',
    'GapSync':          'Syn → Unraid',
    'TVGapSync':        'Syn → Unraid',
}


@router.get('/sync-status/queue')
async def get_sync_queue(_auth=Depends(require_auth)):
    """Live sync-webhook job queue: active + pending + today's stats."""
    try:
        async with httpx.AsyncClient(timeout=10) as client:
            stats_r, active_r, pending_r, recent_r = await asyncio.gather(
                client.get(f"{_SYNC_WEBHOOK_INTERNAL}/stats"),
                client.get(f"{_SYNC_WEBHOOK_INTERNAL}/jobs", params={'status': 'in_progress', 'limit': 20}),
                client.get(f"{_SYNC_WEBHOOK_INTERNAL}/jobs", params={'status': 'pending',     'limit': 200}),
                client.get(f"{_SYNC_WEBHOOK_INTERNAL}/jobs", params={'limit': 30}),
            )
        stats   = stats_r.json()
        active  = active_r.json().get('jobs', [])
        pending = pending_r.json().get('jobs', [])
        recent  = recent_r.json().get('jobs', [])

        # Pending breakdown by job type
        pending_by_type: dict = {}
        for j in pending:
            q = j.get('quality') or j.get('job_type', 'unknown')
            pending_by_type[q] = pending_by_type.get(q, 0) + 1

        def _job_row(j):
            src = j.get('source_path', '') or ''
            fname = src.split('/')[-1] if src else ''
            q = j.get('quality') or j.get('job_type', '')
            return {
                'id':        j['id'],
                'title':     j.get('title', ''),
                'quality':   q,
                'direction': _DIRECTION_LABELS.get(q, 'Syn → Unraid'),
                'status':    j['status'],
                'filename':  fname,
                'file_size': j.get('file_size'),
                'started_at':   j.get('started_at'),
                'completed_at': j.get('completed_at'),
                'error_message': j.get('error_message'),
                'retry_count': j.get('retry_count', 0),
            }

        return {
            'stats': {
                'today_successful': stats.get('today_successful', 0),
                'today_failed':     stats.get('today_failed', 0),
                'bytes_transferred': stats.get('bytes_transferred', 0),
                'bytes_transferred_human': stats.get('bytes_transferred_human', '0 B'),
            },
            'active':          [_job_row(j) for j in active],
            'pending_count':   len(pending),
            'pending_by_type': pending_by_type,
            'recent':          [_job_row(j) for j in recent],
        }
    except Exception as e:
        log.error(f"Queue fetch failed: {e}")
        return {'error': str(e)}


@router.post('/sync-status/reconcile')
async def trigger_reconcile(type: str = 'all', _auth=Depends(require_auth)):
    """Trigger bidirectional version reconcile on sync-webhook. type=tv|movies|all"""
    try:
        async with httpx.AsyncClient(timeout=90) as client:
            r = await client.post(f"{_SYNC_WEBHOOK_INTERNAL}/api/reconcile/trigger",
                                  params={'type': type})
            r.raise_for_status()
            return r.json()
    except Exception as e:
        log.error(f"Reconcile trigger failed: {e}")
        return {'error': str(e), 'status': 'failed'}
