"""
Unraid Agent — lightweight FastAPI service for local duplicate scanning + deletion.
Runs ON Unraid (192.168.1.10) so it has fast local disk access (no CIFS).
Called by Curatorr on Mother instead of slow CIFS directory scan.
"""
import os
import re
import time
import logging
from fastapi import FastAPI, HTTPException, Header
from pydantic import BaseModel
from typing import List

logging.basicConfig(level=logging.INFO, format='%(asctime)s [%(levelname)s] %(name)s: %(message)s')
log = logging.getLogger('unraid-agent')

app = FastAPI(title='Unraid Agent', version='1.0.0')

# ── Auth ──────────────────────────────────────────────────────────────────────
AGENT_API_KEY = os.environ.get('AGENT_API_KEY', '')

def _check_key(x_api_key: str = Header(...)):
    if not AGENT_API_KEY:
        raise HTTPException(500, 'AGENT_API_KEY not configured on agent')
    if x_api_key != AGENT_API_KEY:
        raise HTTPException(401, 'Invalid API key')


# ── Media paths (local to Unraid) ─────────────────────────────────────────────
MEDIA_ROOT = os.environ.get('MEDIA_ROOT', '/mnt/user/Media')
SCAN_ROOTS = [
    (f'{MEDIA_ROOT}/Movies',      'hd_movies', 'movie'),
    (f'{MEDIA_ROOT}/4K Movies',   '4k_movies', 'movie'),
    (f'{MEDIA_ROOT}/TV Shows',    'hd_tv',     'tv'),
    (f'{MEDIA_ROOT}/4K TV Shows', '4k_tv',     'tv'),
]
_ALLOWED_DELETE_PREFIXES = [f'{MEDIA_ROOT}/Movies/', f'{MEDIA_ROOT}/4K Movies/',
                             f'{MEDIA_ROOT}/TV Shows/', f'{MEDIA_ROOT}/4K TV Shows/']

# ── TRaSH scoring (same as duplicates.py) ────────────────────────────────────
_VIDEO_EXTS = frozenset({'.mkv', '.mp4', '.avi', '.ts', '.m4v', '.mov', '.wmv', '.m2ts'})
_EP_RE = re.compile(r'[Ss](\d{1,2})[Ee](\d{1,4})', re.IGNORECASE)

_RES   = {'4K': 4000, '1080p': 2000, '720p': 0, 'SD': -500}
_SRC   = {'Remux': 2000, 'BluRay': 1500, 'Bluray': 1500, 'WEB-DL': 1000,
          'WEBDL': 1000, 'WEBRip': 800, 'HDTV': 200}
_HDR_4K = {'DV HDR10+': 800, 'DV HDR10': 800, 'HDR10': 700, 'HDR': 700,
           'DV': 400, 'DV HLG': 400, 'DV SDR': 300, 'HDR10+': 300, 'HLG': 300}
_HDR_HD = {'DV HDR10+': 400, 'DV HDR10': 400, 'HDR10': 400, 'HDR': 400,
           'DV': 350, 'DV HLG': 350, 'DV SDR': 300, 'HDR10+': 350, 'HLG': 300}
_AUDIO  = {'TrueHD Atmos': 500, 'Atmos': 500, 'TrueHD': 450, 'DTS-HD MA': 400,
           'DTS:X': 400, 'DTS-HD': 350, 'DTS': 200, 'EAC3 Atmos': 300,
           'EAC3': 150, 'DD+': 150, 'AC3': 100, 'DD': 100, 'AAC': 50}


def _parse_brackets(file_path: str) -> dict:
    name = os.path.basename(file_path)
    brackets = re.findall(r'\[([^\]]+)\]', name)
    source = hdr = audio = ''
    for b in brackets:
        bl = b.lower()
        if not source:
            for key, val in [('remux', 'Remux'), ('bluray', 'BluRay'), ('blu-ray', 'BluRay'),
                             ('web-dl', 'WEB-DL'), ('webdl', 'WEB-DL'), ('webrip', 'WEBRip'), ('hdtv', 'HDTV')]:
                if key in bl: source = val; break
        if not hdr:
            for key, val in [('dv hdr10+', 'DV HDR10+'), ('dv hdr10', 'DV HDR10'), ('hdr10+', 'HDR10+'),
                             ('hdr10', 'HDR10'), ('dv hlg', 'DV HLG'), ('dv sdr', 'DV SDR'),
                             ('dv', 'DV'), ('hdr', 'HDR'), ('hlg', 'HLG')]:
                if key in bl: hdr = val; break
        if not audio:
            for key, val in [('truehd atmos', 'TrueHD Atmos'), ('truehd', 'TrueHD'),
                             ('dts-hd ma', 'DTS-HD MA'), ('dts:x', 'DTS:X'), ('dts-hd', 'DTS-HD'),
                             ('eac3 atmos', 'EAC3 Atmos'), ('atmos', 'Atmos'),
                             ('eac3', 'EAC3'), ('dts', 'DTS'), ('ac3', 'AC3'), ('aac', 'AAC')]:
                if key in bl: audio = val; break
    return {'source': source, 'hdr': hdr, 'audio': audio}


def _detect_resolution(name: str) -> str:
    n = name.upper()
    if '2160P' in n or '4K' in n or 'UHD' in n: return '4K'
    if '1080P' in n: return '1080p'
    if '720P' in n: return '720p'
    if '480P' in n or '576P' in n: return 'SD'
    return '?'


def _detect_video_codec(name: str) -> str:
    n = name.upper()
    if 'X265' in n or 'H265' in n or 'HEVC' in n: return 'hevc'
    if 'X264' in n or 'H264' in n or 'AVC' in n: return 'h264'
    return ''


def _make_file_version(path: str, size: int) -> dict:
    name = os.path.basename(path)
    brackets = _parse_brackets(path)
    is_4k = _detect_resolution(name) == '4K'
    codec = _detect_video_codec(name)
    audio = brackets['audio']
    hdr = brackets['hdr']
    src = brackets['source']
    score = _RES.get(_detect_resolution(name), 0)
    score += _SRC.get(src, 0)
    score += (_HDR_4K if is_4k else _HDR_HD).get(hdr, 0)
    score += _AUDIO.get(audio, 0)
    if codec in ('hevc', 'h265') and not is_4k:
        score += 200 if 'DV' in hdr else (0 if hdr else -300)
    score += min(int(size / 1_073_741_824 * 10), 200)
    return {
        'file_path': path,
        'filename': name,
        'file_size_bytes': size,
        'resolution': _detect_resolution(name),
        'video_codec': codec,
        'audio_codec': audio,
        'source': src,
        'hdr': hdr,
        'trash_score': score,
    }


def _scan_movie_dir(root: str, ftype: str) -> list:
    results = []
    if not os.path.isdir(root):
        return results
    for entry in os.scandir(root):
        if not entry.is_dir():
            continue
        videos = []
        try:
            for f in os.scandir(entry.path):
                if f.is_file() and os.path.splitext(f.name)[1].lower() in _VIDEO_EXTS:
                    try:
                        videos.append(_make_file_version(f.path, f.stat().st_size))
                    except OSError:
                        pass
        except (PermissionError, OSError):
            continue
        if len(videos) >= 2:
            videos.sort(key=lambda x: x['trash_score'], reverse=True)
            results.append({
                'id': f"unraid:{entry.path}",
                'title': entry.name,
                'folder': entry.path,
                'source': 'unraid',
                'folder_type': ftype,
                'media_type': 'movie',
                'versions': videos,
                'total_size_bytes': sum(v['file_size_bytes'] for v in videos),
                'deletable_size_bytes': sum(v['file_size_bytes'] for v in videos[1:]),
            })
    return results


def _scan_tv_dir(root: str, ftype: str) -> list:
    results = []
    if not os.path.isdir(root):
        return results
    for show_entry in os.scandir(root):
        if not show_entry.is_dir():
            continue
        episodes: dict = {}
        try:
            for sub in os.scandir(show_entry.path):
                if sub.is_dir():
                    try:
                        for f in os.scandir(sub.path):
                            if f.is_file() and os.path.splitext(f.name)[1].lower() in _VIDEO_EXTS:
                                m = _EP_RE.search(f.name)
                                if m:
                                    key = f"S{m.group(1).zfill(2)}E{m.group(2).zfill(4)}"
                                    try:
                                        episodes.setdefault(key, []).append(
                                            _make_file_version(f.path, f.stat().st_size))
                                    except OSError:
                                        pass
                    except (PermissionError, OSError):
                        pass
                elif sub.is_file() and os.path.splitext(sub.name)[1].lower() in _VIDEO_EXTS:
                    m = _EP_RE.search(sub.name)
                    if m:
                        key = f"S{m.group(1).zfill(2)}E{m.group(2).zfill(4)}"
                        try:
                            episodes.setdefault(key, []).append(
                                _make_file_version(sub.path, sub.stat().st_size))
                        except OSError:
                            pass
        except (PermissionError, OSError):
            continue
        for ep_key, files in sorted(episodes.items()):
            if len(files) >= 2:
                files.sort(key=lambda x: x['trash_score'], reverse=True)
                results.append({
                    'id': f"unraid:{show_entry.path}:{ep_key}",
                    'title': show_entry.name,
                    'episode': ep_key,
                    'folder': show_entry.path,
                    'source': 'unraid',
                    'folder_type': ftype,
                    'media_type': 'tv',
                    'versions': files,
                    'total_size_bytes': sum(v['file_size_bytes'] for v in files),
                    'deletable_size_bytes': sum(v['file_size_bytes'] for v in files[1:]),
                })
    return results


# ── Scan cache ────────────────────────────────────────────────────────────────
_scan_cache: dict = {'data': None, 'ts': 0.0}
SCAN_CACHE_TTL = 1800  # 30 minutes


def _do_scan() -> dict:
    from concurrent.futures import ThreadPoolExecutor, as_completed

    result = {
        'unraid': {'hd_movies': [], '4k_movies': [], 'hd_tv': [], '4k_tv': []},
        'errors': [],
        'scan_time_seconds': 0,
    }
    t0 = time.time()

    def _scan_one(args):
        root, ftype, mkind = args
        try:
            if mkind == 'movie':
                items = _scan_movie_dir(root, ftype)
            else:
                items = _scan_tv_dir(root, ftype)
            log.info(f"scan {ftype} → {len(items)} groups")
            return ftype, items, None
        except Exception as e:
            log.error(f"scan error {root}: {e}")
            return ftype, [], str(e)

    with ThreadPoolExecutor(max_workers=4) as ex:
        futures = {ex.submit(_scan_one, args): args for args in SCAN_ROOTS}
        for fut in as_completed(futures, timeout=300):
            ftype, items, err = fut.result()
            result['unraid'][ftype] = items
            if err:
                result['errors'].append({'ftype': ftype, 'error': err})

    result['scan_time_seconds'] = round(time.time() - t0, 1)
    result['summary'] = {
        'unraid': {
            ftype: {
                'groups': len(result['unraid'][ftype]),
                'deletable_bytes': sum(g['deletable_size_bytes'] for g in result['unraid'][ftype]),
            }
            for ftype in ('hd_movies', '4k_movies', 'hd_tv', '4k_tv')
        }
    }
    return result


# ── Endpoints ─────────────────────────────────────────────────────────────────

@app.get('/health')
def health():
    return {
        'ok': True,
        'media_root': MEDIA_ROOT,
        'roots': [r[0] for r in SCAN_ROOTS],
        'roots_exist': {r[0]: os.path.isdir(r[0]) for r in SCAN_ROOTS},
    }


@app.get('/scan')
def scan(refresh: bool = False, x_api_key: str = Header(...)):
    _check_key(x_api_key)
    now = time.time()
    if not refresh and _scan_cache['data'] and (now - _scan_cache['ts']) < SCAN_CACHE_TTL:
        log.info('Returning cached scan result')
        return _scan_cache['data']
    log.info('Starting fresh filesystem scan...')
    data = _do_scan()
    _scan_cache['data'] = data
    _scan_cache['ts'] = now
    return data


class DeleteRequest(BaseModel):
    paths: List[str]


@app.post('/delete')
def delete_files(body: DeleteRequest, x_api_key: str = Header(...)):
    _check_key(x_api_key)
    deleted = []
    errors = []
    freed_bytes = 0

    for path in body.paths:
        # Safety: must be under an allowed media prefix
        safe = any(path.startswith(p) for p in _ALLOWED_DELETE_PREFIXES)
        if not safe:
            errors.append({'path': path, 'error': 'Path outside allowed media roots'})
            continue
        # No symlink traversal
        if os.path.islink(path):
            errors.append({'path': path, 'error': 'Refusing to delete symlink'})
            continue
        try:
            size = os.path.getsize(path)
            os.remove(path)
            freed_bytes += size
            deleted.append(path)
            log.info(f"Deleted: {path} ({size} bytes)")
            # Invalidate cache
            _scan_cache['data'] = None
        except FileNotFoundError:
            deleted.append(path)  # Already gone — treat as success
            log.info(f"Already gone: {path}")
        except Exception as e:
            errors.append({'path': path, 'error': str(e)})
            log.error(f"Delete error {path}: {e}")

    return {
        'ok': len(errors) == 0,
        'deleted': deleted,
        'errors': errors,
        'freed_bytes': freed_bytes,
    }
