"""Duplicates detection from Plex and filesystem scan."""
import json
import logging
import os
import re
import threading
import time
import xml.etree.ElementTree as ET
import httpx
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import List
from app.auth import require_auth
from app.database import get_db, get_config
from app.config import (
    RADARR_INSTANCES, SONARR_INSTANCES, synology_to_unraid_path,
    UNRAID_MEDIA_PATH, UNRAID_AGENT_URL, UNRAID_AGENT_API_KEY,
)

router = APIRouter()
log = logging.getLogger('curatorr.routes.duplicates')

# ── TRaSH-aligned scoring — loaded from shared JSON config ────────────────────
_SCORING_PATH = os.environ.get('TRASH_SCORING_PATH', '/app/scoring/trash_scoring.json')
with open(_SCORING_PATH) as _f:
    _SC = json.load(_f)

# Plex API uses string keys ('4K', '1080p', 'Remux', etc.) — map to JSON numeric values
_RES = {
    '4K':   _SC['resolution']['2160p'],
    '1080p': _SC['resolution']['1080p'],
    '720p':  _SC['resolution']['720p'],
    'SD':    _SC['resolution']['sd'],
}
_SRC = {
    'Remux': _SC['source']['remux'],  'BluRay': _SC['source']['bluray'],
    'Bluray': _SC['source']['bluray'], 'WEB-DL': _SC['source']['web_dl'],
    'WEBDL':  _SC['source']['web_dl'], 'WEBRip': _SC['source']['webrip'],
    'HDTV':   _SC['source']['hdtv'],
}
# HDR: _parse_brackets() returns capitalized labels — map to JSON scores explicitly
_HDR_4K = {
    'DV HDR10+': _SC['hdr_4k'][0][1], 'DV HDR10': _SC['hdr_4k'][1][1],
    'HDR10+':    _SC['hdr_4k'][2][1], 'HDR10':    _SC['hdr_4k'][3][1],
    'DV HLG':    _SC['hdr_4k'][4][1], 'DV SDR':   _SC['hdr_4k'][5][1],
    'DV':        _SC['hdr_4k'][7][1], 'HDR':      _SC['hdr_4k'][8][1],
    'HLG':       _SC['hdr_4k'][9][1],
}
_HDR_HD = {
    'DV HDR10+': _SC['hdr_hd'][0][1], 'DV HDR10': _SC['hdr_hd'][1][1],
    'HDR10+':    _SC['hdr_hd'][2][1], 'HDR10':    _SC['hdr_hd'][3][1],
    'DV HLG':    _SC['hdr_hd'][4][1], 'DV SDR':   _SC['hdr_hd'][5][1],
    'DV':        _SC['hdr_hd'][7][1], 'HDR':      _SC['hdr_hd'][8][1],
    'HLG':       _SC['hdr_hd'][9][1],
}
# Audio: capitalized Plex-style keys → JSON scores
_AUDIO = {
    'TrueHD Atmos': _SC['audio'][0][1], 'TrueHD':  _SC['audio'][1][1],
    'DTS-HD MA':    _SC['audio'][2][1], 'DTS:X':   _SC['audio'][3][1],
    'DTS-HD':       _SC['audio'][4][1], 'EAC3 Atmos': _SC['audio'][5][1],
    'Atmos':        _SC['audio'][6][1], 'EAC3':    _SC['audio'][7][1],
    'DTS':          _SC['audio'][8][1], 'DD+':     _SC['audio'][9][1],
    'AC3':          _SC['audio'][10][1], 'DD':     _SC['audio'][10][1],
    'AAC':          _SC['audio'][11][1],
}
_PLEX_AUDIO = {'truehd': 'TrueHD', 'dts': 'DTS', 'eac3': 'EAC3',
               'ac3': 'AC3', 'aac': 'AAC', 'mp3': 'AAC'}

def _parse_brackets(file_path: str) -> dict:
    """Extract source, HDR, audio from TRaSH bracket-format filename."""
    name = os.path.basename(file_path)
    brackets = re.findall(r'\[([^\]]+)\]', name)
    source = hdr = audio = ''
    for b in brackets:
        bl = b.lower()
        if not source:
            for key, val in [('remux','Remux'),('bluray','BluRay'),('blu-ray','BluRay'),
                             ('web-dl','WEB-DL'),('webdl','WEB-DL'),('webrip','WEBRip'),('hdtv','HDTV')]:
                if key in bl: source = val; break
        if not hdr:
            for key, val in [('dv hdr10+','DV HDR10+'),('dv hdr10','DV HDR10'),('hdr10+','HDR10+'),
                             ('hdr10','HDR10'),('dv hlg','DV HLG'),('dv sdr','DV SDR'),
                             ('dv','DV'),('hdr','HDR'),('hlg','HLG')]:
                if key in bl: hdr = val; break
        if not audio:
            for key, val in [('truehd atmos','TrueHD Atmos'),('truehd','TrueHD'),
                             ('dts-hd ma','DTS-HD MA'),('dts:x','DTS:X'),('dts-hd','DTS-HD'),
                             ('eac3 atmos','EAC3 Atmos'),('atmos','Atmos'),
                             ('eac3','EAC3'),('dts','DTS'),('ac3','AC3'),('aac','AAC')]:
                if key in bl: audio = val; break
    return {'source': source, 'hdr': hdr, 'audio': audio}

_RELEASE_GROUP_RE = re.compile(r'-([A-Za-z][A-Za-z0-9]{1,14})\.(mkv|mp4|avi|m4v|ts|m2ts)$', re.IGNORECASE)

def _score_plex_version(v: dict) -> int:
    res    = v.get('resolution', '')
    codec  = v.get('video_codec', '').lower()
    is_4k  = res == '4K'
    size_gb = v.get('file_size_bytes', 0) / 1_073_741_824
    file_path = v.get('file_path', '')
    fname  = os.path.basename(file_path)
    name   = fname.lower()
    q = _parse_brackets(file_path)
    audio  = q['audio'] or _PLEX_AUDIO.get(v.get('audio_codec', '').lower(), '')
    hdr, src = q['hdr'], q['source']

    score  = _RES.get(res, 0)
    score += _SRC.get(src, 0)
    score += (_HDR_4K if is_4k else _HDR_HD).get(hdr, 0)
    score += _AUDIO.get(audio, 0)
    # x265/hevc at 1080p without HDR = penalised
    if codec in ('hevc', 'h265') and not is_4k:
        score += 200 if 'DV' in hdr else (0 if hdr else -300)
    score += min(int(size_gb * _SC['size_bonus_per_gb']), _SC['size_bonus_cap'])
    score += _SC['custom_formats']['hybrid']        if re.search(r'\[hybrid\]', name) else 0
    score += _SC['custom_formats']['release_group'] if _RELEASE_GROUP_RE.search(fname) else 0
    score += _SC['custom_formats']['proper_repack'] if re.search(r'\b(proper|repack|rerip)\b', name) else 0
    score += _SC['container_penalty_mp4']           if fname.lower().endswith('.mp4') else 0
    return score


@router.get('/duplicates')
async def list_duplicates(_auth=Depends(require_auth)):
    """Find duplicate movies by TMDB ID within the same resolution tier.
    1080p + 4K of the same movie are intentional — never flagged as duplicates.
    Duplicates are same TMDB ID AND same resolution tier (both 4K, or both non-4K).
    """
    async for db in get_db():
        async with db.execute("""
            SELECT tmdb_id,
                   CASE WHEN resolution = '4K' THEN '4K' ELSE 'HD' END AS res_tier,
                   COUNT(*) AS count
            FROM movies
            WHERE tmdb_id IS NOT NULL
            GROUP BY tmdb_id, res_tier
            HAVING count > 1
        """) as cur:
            dup_groups = [(row['tmdb_id'], row['res_tier']) for row in await cur.fetchall()]

        if not dup_groups:
            return []

        result = []
        for tmdb_id, res_tier in dup_groups:
            res_condition = "resolution = '4K'" if res_tier == '4K' else "resolution != '4K'"
            async with db.execute(
                f"SELECT id, title, year, resolution, video_codec, audio_codec, "
                f"file_size_bytes, file_path, trash_score, imdb_rating, composite_score, "
                f"radarr_instance, radarr_id "
                f"FROM movies WHERE tmdb_id=? AND {res_condition} ORDER BY trash_score DESC",
                (tmdb_id,)
            ) as cur:
                versions = [dict(r) for r in await cur.fetchall()]

            if len(versions) >= 2:
                result.append({
                    'tmdb_id': tmdb_id,
                    'title': versions[0]['title'],
                    'year': versions[0]['year'],
                    'resolution_tier': res_tier,
                    'versions': versions,
                    'recommended_keep_id': versions[0]['id'],  # highest trash_score
                })

        return result


# ── Filesystem scan helpers ───────────────────────────────────────────────────

_VIDEO_EXTS = frozenset({'.mkv', '.mp4', '.avi', '.ts', '.m4v', '.mov', '.wmv', '.m2ts'})


def _parse_episode_keys(filename: str) -> list:
    """Return all S##E#### group keys for a filename.
    Handles multi-episode files: S05E01-E02, S05E01E02, S05E01-02.
    Handles 4-digit year-based seasons (e.g. Looney Tunes S1930E01).
    Requires the S to follow a non-alphanumeric character so show names like
    NOS4A2 (which contain 'S4') are not mistaken for a season marker.
    """
    # (?<![A-Za-z0-9]) prevents matching S inside show names (NOS4A2 → S4)
    # \d{1,4} handles year-based seasons like S1930
    season_match = re.search(r'(?<![A-Za-z0-9])[Ss](\d{1,4})', filename)
    if not season_match:
        return []
    season = int(season_match.group(1))
    rest = filename[season_match.end():]

    first_ep = re.search(r'[Ee](\d{1,4})', rest)
    if not first_ep:
        return []
    ep_start = int(first_ep.group(1))
    after = rest[first_ep.end():]

    # Range: E01-E02 or E01-02 (dash/en-dash immediately after first episode)
    range_match = re.match(r'[-\u2013](?:[Ee])?(\d{1,4})', after)
    if range_match:
        ep_end = int(range_match.group(1))
        return [f"S{season:04d}E{ep:04d}" for ep in range(ep_start, ep_end + 1)]

    # Concatenated: E01E02E03... immediately following with no gap
    keys = [f"S{season:04d}E{ep_start:04d}"]
    pos = after
    while True:
        nxt = re.match(r'[Ee](\d{1,4})', pos)
        if nxt:
            keys.append(f"S{season:04d}E{int(nxt.group(1)):04d}")
            pos = pos[nxt.end():]
        else:
            break
    return keys
_scan_cache: dict = {'data': None, 'ts': 0.0}
SCAN_CACHE_TTL = 1800  # 30 minutes

_scan_lock = threading.Lock()
_scan_in_progress = False

# (filesystem_path, server_label, folder_type_key, media_kind)
_SCAN_ROOTS = [
    ('/mnt/synology/rs-movies',           'synology', 'hd_movies', 'movie'),
    ('/mnt/synology/rs-4kmedia/4kmovies', 'synology', '4k_movies', 'movie'),
    ('/mnt/synology/rs-tv',               'synology', 'hd_tv',     'tv'),
    ('/mnt/synology/rs-4kmedia/4ktv',     'synology', '4k_tv',     'tv'),
    ('/mnt/unraid/media/Movies',          'unraid',   'hd_movies', 'movie'),
    ('/mnt/unraid/media/4K Movies',       'unraid',   '4k_movies', 'movie'),
    ('/mnt/unraid/media/TV Shows',        'unraid',   'hd_tv',     'tv'),
    ('/mnt/unraid/media/4K TV Shows',     'unraid',   '4k_tv',     'tv'),
]

# Both Synology NFS and Unraid CIFS are writable — duplicates are deleted from both
# to maintain an exact DR mirror.
_SYNOLOGY_DELETE_PREFIXES = [
    '/mnt/synology/rs-movies/',
    '/mnt/synology/rs-4kmedia/4kmovies/',
    '/mnt/synology/rs-tv/',
    '/mnt/synology/rs-4kmedia/4ktv/',
]
_UNRAID_DELETE_PREFIXES = [
    '/mnt/unraid/media/Movies/',
    '/mnt/unraid/media/4K Movies/',
    '/mnt/unraid/media/TV Shows/',
    '/mnt/unraid/media/4K TV Shows/',
]
_ALLOWED_DELETE_PREFIXES = _SYNOLOGY_DELETE_PREFIXES + _UNRAID_DELETE_PREFIXES

# NFS host path → Unraid CIFS path (for the filesystem scan delete flow)
_NFS_TO_UNRAID = [
    ('/mnt/synology/rs-movies/',           UNRAID_MEDIA_PATH + '/Movies/'),
    ('/mnt/synology/rs-4kmedia/4kmovies/', UNRAID_MEDIA_PATH + '/4K Movies/'),
    ('/mnt/synology/rs-tv/',               UNRAID_MEDIA_PATH + '/TV Shows/'),
    ('/mnt/synology/rs-4kmedia/4ktv/',     UNRAID_MEDIA_PATH + '/4K TV Shows/'),
]


def _nfs_to_unraid_path(nfs_path: str) -> str | None:
    """Translate a Synology NFS host path to the corresponding Unraid CIFS path."""
    for src, dst in _NFS_TO_UNRAID:
        if nfs_path.startswith(src):
            return dst + nfs_path[len(src):]
    return None


def _purge_synology_recycle(path: str) -> None:
    """
    Synology DSM moves NFS-deleted files to #recycle/ in the same share root.
    After os.remove(), purge the recycle copy so space is actually freed.
    Structure: {share_root}/#recycle/{relative/path/to/file}
    """
    for prefix in _SYNOLOGY_DELETE_PREFIXES:
        if path.startswith(prefix):
            rel = path[len(prefix):]
            recycle_path = os.path.join(prefix, '#recycle', rel)
            try:
                if os.path.isfile(recycle_path):
                    os.remove(recycle_path)
                    log.info(f"Purged recycle: {recycle_path}")
                    # Remove empty parent dir in recycle (best-effort)
                    try:
                        os.rmdir(os.path.dirname(recycle_path))
                    except OSError:
                        pass
            except Exception as e:
                log.warning(f"Recycle purge failed for {recycle_path}: {e}")
            return


def _detect_resolution(name: str) -> str:
    n = name.upper()
    if '2160P' in n or '4K' in n or 'UHD' in n:
        return '4K'
    if '1080P' in n:
        return '1080p'
    if '720P' in n:
        return '720p'
    if '480P' in n or '576P' in n:
        return 'SD'
    return '?'


def _detect_video_codec(name: str) -> str:
    n = name.upper()
    if 'X265' in n or 'H265' in n or 'HEVC' in n:
        return 'hevc'
    if 'X264' in n or 'H264' in n or 'AVC' in n:
        return 'h264'
    return ''


def _make_file_version(path: str, size: int) -> dict:
    name = os.path.basename(path)
    brackets = _parse_brackets(path)
    v = {
        'file_path': path,
        'filename': name,
        'file_size_bytes': size,
        'resolution': _detect_resolution(name),
        'video_codec': _detect_video_codec(name),
        'audio_codec': brackets['audio'],
        'source': brackets['source'],
        'hdr': brackets['hdr'],
    }
    v['trash_score'] = _score_plex_version(v)
    return v


def _scan_movie_dir(root: str, source_label: str, folder_type: str) -> list:
    """Movie folders with 2+ video files = duplicate group."""
    results = []
    if not os.path.isdir(root):
        return results
    try:
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
                    'id': f"{source_label}:{entry.path}",
                    'title': entry.name,
                    'folder': entry.path,
                    'source': source_label,
                    'folder_type': folder_type,
                    'media_type': 'movie',
                    'versions': videos,
                    'total_size_bytes': sum(v['file_size_bytes'] for v in videos),
                    'deletable_size_bytes': sum(v['file_size_bytes'] for v in videos[1:]),
                })
    except (PermissionError, OSError) as e:
        log.warning(f"scan_movie_dir error scanning {root}: {e}")
    return results


def _scan_tv_dir(root: str, source_label: str, folder_type: str) -> list:
    """TV show directories: 2+ files with the same S##E## = duplicate group."""
    results = []
    if not os.path.isdir(root):
        return results
    try:
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
                                    for key in _parse_episode_keys(f.name):
                                        try:
                                            episodes.setdefault(key, []).append(
                                                _make_file_version(f.path, f.stat().st_size))
                                        except OSError:
                                            pass
                        except (PermissionError, OSError):
                            pass
                    elif sub.is_file() and os.path.splitext(sub.name)[1].lower() in _VIDEO_EXTS:
                        for key in _parse_episode_keys(sub.name):
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

                    # Mark each version as safe or unsafe to delete.
                    # A multi-episode file (e.g. S09E27-E28) is unsafe to delete if
                    # any other episode it covers has no other file — deleting it would
                    # destroy that content.  Standalone files are always safe to delete.
                    for f in files:
                        f_keys = _parse_episode_keys(f['filename'])
                        if len(f_keys) <= 1:
                            f['safe_to_delete'] = True
                        else:
                            other_keys = [k for k in f_keys if k != ep_key]
                            f['safe_to_delete'] = all(
                                any(other['file_path'] != f['file_path']
                                    for other in episodes.get(k, []))
                                for k in other_keys
                            )

                    results.append({
                        'id': f"{source_label}:{show_entry.path}:{ep_key}",
                        'title': show_entry.name,
                        'episode': ep_key,
                        'folder': show_entry.path,
                        'source': source_label,
                        'folder_type': folder_type,
                        'media_type': 'tv',
                        'versions': files,
                        'total_size_bytes': sum(v['file_size_bytes'] for v in files),
                        'deletable_size_bytes': sum(
                            v['file_size_bytes'] for v in files[1:]
                            if v.get('safe_to_delete', True)
                        ),
                    })
    except (PermissionError, OSError) as e:
        log.warning(f"scan_tv_dir error scanning {root}: {e}")
    return results


def _scan_one_root(args: tuple) -> tuple:
    """Scan a single root path — designed for parallel execution."""
    root, source, ftype, mkind = args
    try:
        if mkind == 'movie':
            items = _scan_movie_dir(root, source, ftype)
        else:
            items = _scan_tv_dir(root, source, ftype)
        log.info(f"FS scan: {source}/{ftype} → {len(items)} groups ({root})")
        return source, ftype, items, None
    except Exception as e:
        log.error(f"FS scan error for {root}: {e}")
        return source, ftype, [], str(e)


_PER_ROOT_TIMEOUT = 300  # seconds per individual scan root (TV dir has 66k items)
_SCAN_SKIP_ROOTS  = {
    # All Unraid CIFS paths are too slow to directory-scan (7500+ movie dirs,
    # 100K+ episode files over VPN). Synology NFS results cover these since
    # Unraid is the rsync destination of Synology.
    '/mnt/unraid/media/Movies',
    '/mnt/unraid/media/4K Movies',
    '/mnt/unraid/media/TV Shows',
    '/mnt/unraid/media/4K TV Shows',
}


def _fetch_unraid_agent_scan(refresh: bool = False) -> dict | None:
    """Call Unraid Agent /scan endpoint. Returns agent payload or None on failure."""
    import urllib.request
    import urllib.error
    import json

    if not UNRAID_AGENT_URL or not UNRAID_AGENT_API_KEY:
        log.info('Unraid agent not configured — skipping')
        return None
    url = f"{UNRAID_AGENT_URL.rstrip('/')}/scan"
    if refresh:
        url += '?refresh=true'
    try:
        req = urllib.request.Request(url, headers={'X-Api-Key': UNRAID_AGENT_API_KEY})
        with urllib.request.urlopen(req, timeout=360) as resp:
            return json.loads(resp.read())
    except Exception as e:
        log.warning(f"Unraid agent scan failed: {e}")
        return None


def _norm_title(title: str) -> str:
    t = re.sub(r'\s*\(\d{4}\)\s*$', '', title)
    t = t.lower().replace('&', ' and ')
    return re.sub(r'[^a-z0-9]+', '', t)


def _fetch_radarr_tracked(inst_name: str) -> dict:
    """normalized movie title -> Radarr's currently tracked filename (lowercase).

    Raises on fetch failure rather than returning {} — an empty dict must mean
    "Radarr genuinely tracks nothing," never "the fetch failed," or the caller's
    Profile Authority correction silently no-ops instead of visibly failing."""
    inst = next((i for i in RADARR_INSTANCES if i['name'] == inst_name), None)
    if not inst:
        raise RuntimeError(f"Radarr instance not configured: {inst_name}")
    with httpx.Client(timeout=60) as client:
        r = client.get(f"{inst['url']}/api/v3/movie", headers={'X-Api-Key': inst['api_key']})
        r.raise_for_status()
        movies = r.json()
    out = {}
    for m in movies:
        mf = m.get('movieFile')
        if mf and mf.get('relativePath'):
            out[_norm_title(m['title'])] = os.path.basename(mf['relativePath']).lower()
    return out


def _movie_title_from_path(path: str) -> str:
    """Extract the movie folder name from a file path (e.g.
    '/mnt/user/Media/Movies/Ninja Assassin (2009)/file.mkv' -> 'Ninja Assassin (2009)'),
    stripping any {tmdb-...} suffix if present."""
    folder = os.path.basename(os.path.dirname(path))
    return re.sub(r'\s*\{tmdb-\d+\}', '', folder).strip()


def _reject_tier7_pending_items(items) -> tuple:
    """Server-side enforcement, not just a UI nicety — a stale client-side selection
    (made before a re-scan flagged a file pending_tier7) would otherwise still reach
    the delete endpoint unfiltered, since the frontend only disables the checkbox.
    Returns (safe_items, rejected_results) — safe_items is what should actually be
    deleted; rejected_results are pre-formatted {'file_path','ok':False,'error':...}
    entries for anything currently tier7-pending, to merge into the response as-is.

    Fails open (returns items unfiltered) on fetch error — this is the interactive,
    human-confirmed delete path, not the automated nightly job; the scan itself
    already surfaced tier7_guard.ok=False to the human if the check couldn't run, so
    silently blocking every delete here on a transient DB read hiccup would be worse
    than the (already-flagged-to-the-human) risk of a rare unguarded delete."""
    try:
        tier7 = _fetch_tier7_pending('radarr-hd') | _fetch_tier7_pending('radarr-4k')
    except Exception as e:
        log.warning(f"Tier7-pending check failed during delete (proceeding unfiltered): {e}")
        return items, []

    safe, rejected = [], []
    for item in items:
        title = _movie_title_from_path(item.file_path)
        if title and _norm_title(title) in tier7:
            rejected.append({'file_path': item.file_path, 'ok': False,
                              'error': 'Blocked: Upgraderr has an active Tier 7 replacement pending for this movie'})
        else:
            safe.append(item)
    return safe, rejected


def _fetch_tier7_pending(instance: str) -> set:
    """Normalized movie titles Upgraderr currently has an active tier7_profile_mismatch
    entry for, per instance — read from a plain JSON export Upgraderr writes after
    each sweep (/opt/mother/data/upgraderr/tier7_pending.json), NOT a live SQLite read
    against upgraderr.db: a read-only bind mount can't create the -shm file WAL mode
    needs, so direct cross-container SQLite reads intermittently failed with "unable
    to open database file." This mirrors the trash_scoring.json pattern already used
    for read-only cross-service config sharing in this codebase.

    Raises on failure rather than returning set() — same convention as
    _fetch_radarr_tracked: an empty set must mean "genuinely nothing pending," never
    "the file was unreadable," or the guard silently no-ops."""
    path = os.environ.get('TIER7_PENDING_PATH', '/data/upgraderr_ro/tier7_pending.json')
    with open(path) as f:
        data = json.load(f)
    return {_norm_title(t) for t in data.get(instance, []) if t}


def _fetch_sonarr_tracked(inst_name: str) -> dict:
    """(tvdbId, 'S####E####') -> Sonarr's currently tracked episode filename (lowercase).

    Raises on fetch failure rather than returning {} — an empty dict must mean
    "Sonarr genuinely tracks nothing," never "the fetch failed," or the caller's
    Profile Authority correction silently no-ops instead of visibly failing. Per-
    series episode-list failures inside the loop below are tolerated (skip that one
    series) since that's genuine partial data, not a full fetch failure."""
    inst = next((i for i in SONARR_INSTANCES if i['name'] == inst_name), None)
    if not inst:
        raise RuntimeError(f"Sonarr instance not configured: {inst_name}")
    with httpx.Client(timeout=60) as client:
        r = client.get(f"{inst['url']}/api/v3/series", headers={'X-Api-Key': inst['api_key']})
        r.raise_for_status()
        series_list = r.json()
    out = {}
    with httpx.Client(timeout=60) as client:
        for s in series_list:
            tvdb_id = s.get('tvdbId')
            if not tvdb_id:
                continue
            try:
                r = client.get(f"{inst['url']}/api/v3/episode",
                                params={'seriesId': s['id'], 'includeEpisodeFile': 'true'},
                                headers={'X-Api-Key': inst['api_key']})
                r.raise_for_status()
                episodes = r.json()
            except Exception:
                continue
            for ep in episodes:
                ef = ep.get('episodeFile')
                if not ef or not ef.get('relativePath'):
                    continue
                key = (tvdb_id, f"S{ep.get('seasonNumber', 0):04d}E{ep.get('episodeNumber', 0):04d}")
                out[key] = os.path.basename(ef['relativePath']).lower()
    return out


_BAD_RELEASE_GROUPS = {'bhdstudio'}
_BAD_CONTAINERS = ('.avi', '.mp4', '.ts', '.wmv', '.m4v', '.divx', '.xvid')

_PART_RE = re.compile(r'\bpart\s*\d+\b', re.IGNORECASE)
_ALWAYS_PROTECTED_TITLES = ('sacred timeline cut', 'infinity saga')


def _is_multipart_group(group: dict) -> bool:
    """Mirrors sync-webhook's _dedup_is_multipart_group() / scheduler.py's
    _is_multipart_group() — kept as a separate copy for the same reason as
    _is_known_bad_release above. Found live 2026-07-22: this manual duplicate-
    scanner route (used by the Curatorr UI's bulk-delete) had NO multipart guard
    at all, unlike the two automatic dedup engines — the exact gap that let the
    2026-07-19 "Infinity Saga" 4/5-parts-destroyed incident happen in the first
    place, just reachable here via a human clicking bulk-delete instead of an
    automated job. Continuation files (PART 1, PART 2, ...) are not duplicates."""
    versions = group.get('versions') or []
    part_count = sum(
        1 for v in versions
        if _PART_RE.search(os.path.basename(v.get('filename', '') or v.get('file_path', '') or ''))
    )
    return part_count >= 2


def _is_always_protected_title(title: str) -> bool:
    """Belt-and-suspenders guard for known fan-edit/multi-part titles by name,
    independent of _is_multipart_group's PART-number regex."""
    t = (title or '').lower()
    return any(name in t for name in _ALWAYS_PROTECTED_TITLES)


def _filter_protected_groups(groups: list) -> list:
    """Drop multi-part / always-protected groups entirely before they ever reach
    the UI or a bulk-delete call — matches the other two dedup engines' behavior
    of skipping such groups rather than merely flagging them."""
    kept = []
    for grp in groups:
        if _is_multipart_group(grp) or _is_always_protected_title(grp.get('title', '')):
            log.debug(f"Duplicate scan: excluding protected multi-part group '{grp.get('title', '')}'")
            continue
        kept.append(grp)
    return kept


def _is_known_bad_release(filename: str) -> bool:
    """Mirrors Upgraderr's _is_known_bad_release() + Tier 2 container check
    (services/upgraderr/app.py) and sync-webhook's copy of the same. See CLAUDE.md's
    Known-Bad Releases table."""
    fn = (filename or '').lower()
    if fn.endswith(_BAD_CONTAINERS):
        return True
    m = re.search(r'-([a-z0-9]+)(?:\.[a-z0-9]{2,4})?$', fn)
    group = m.group(1) if m else ''
    return group in _BAD_RELEASE_GROUPS


def _enforce_profile_authority(groups: list, tracked_by_title: dict = None,
                                tracked_by_episode: dict = None, media_type: str = 'movie',
                                tier7_pending: set = None) -> None:
    """Re-rank each duplicate group in place so the file Radarr/Sonarr is currently
    tracking is always first (kept), regardless of raw TRaSH score — see CLAUDE.md
    Profile Authority. Without this, a stray higher-scoring orphan (e.g. a leftover
    Remux from before a profile was assigned) would be marked "keep" and the actively
    tracked, profile-compliant file would be marked deletable — the exact mistake
    that caused the 2026-07 sync-webhook incident, just via the duplicate scanner
    instead of the reconcile job. Confirmed live 2026-07-02: 32 of 305 Unraid HD
    movie duplicate groups had this exact mismatch before this fix.

    tier7_pending (movies only): normalized titles Upgraderr currently has an active
    tier7_profile_mismatch entry for — i.e. Radarr's tracked file (the one we're about
    to keep here) itself violates its assigned profile and Radarr has already been
    told to search for a replacement. Found live 2026-07-06: 140 of 196 Unraid HD
    movie duplicate groups keeping a Remux were in this exact state — deleting the
    "duplicate" Bluray alternates in that window is pure waste, since Radarr will
    otherwise re-download essentially the same thing via Tier 7 shortly after. Marks
    the non-kept versions un-deletable and flagged until Tier 7 resolves (see
    scripts/resolve_tier7_remux_duplicates.py and the incident-flagged plan this was
    added for).

    Known-bad-release guard — added 2026-07-19 after a live sync-webhook dry-run
    caught this exact gap (Mortal Kombat II, The Devil Wears Prada 2, The Man from
    Earth — all BHDStudio .mp4 tracked, with a clean alternative sitting right next
    to it that would have been deleted). Profile Authority governs resolution/source
    TIER, not release quality control — these are explicitly orthogonal per CLAUDE.md.
    If the kept/tracked file is itself a known-bad release, every other version in
    the group is marked un-deletable instead of ranked below it.
    """
    for grp in groups:
        versions = grp.get('versions') or []
        if len(versions) < 2:
            continue

        tracked_fname = None
        if media_type == 'movie' and tracked_by_title is not None:
            tracked_fname = tracked_by_title.get(_norm_title(grp['title']))
        elif media_type == 'tv' and tracked_by_episode is not None:
            m = re.search(r'\{tvdb-(\d+)\}', grp.get('title', ''))
            if m:
                tracked_fname = tracked_by_episode.get((int(m.group(1)), grp.get('episode', '')))
        if not tracked_fname:
            continue

        tracked_idx = next(
            (i for i, v in enumerate(versions) if v['filename'].lower() == tracked_fname), None
        )
        if tracked_idx is None:
            continue  # not present in this group
        if tracked_idx == 0:
            # Already ranked first by raw score — no reorder needed, but Profile
            # Authority is still the reason it's kept, so the UI badge should say
            # so rather than defaulting to "kept: highest score" for this common case.
            versions[0]['kept_reason'] = 'profile_authority'
        else:
            tracked_version = versions.pop(tracked_idx)
            tracked_version['kept_reason'] = 'profile_authority'
            versions.insert(0, tracked_version)
            grp['versions'] = versions

        if _is_known_bad_release(versions[0].get('filename', '')):
            for v in versions[1:]:
                v['safe_to_delete'] = False
                v['known_bad_tracked_file'] = True
            log.warning(
                f"Duplicate scan: '{grp.get('title', '')}' tracked file is a known-bad "
                f"release ({versions[0].get('filename', '')}) — protecting "
                f"{len(versions)-1} alternate(s) from deletion instead of deleting "
                f"them to preserve it."
            )

        if (media_type == 'movie' and tier7_pending
                and _norm_title(grp['title']) in tier7_pending):
            for v in versions[1:]:
                v['safe_to_delete'] = False
                v['pending_tier7'] = True

        grp['deletable_size_bytes'] = sum(
            v['file_size_bytes'] for v in versions[1:]
            if v.get('safe_to_delete', True)
        )


def _do_filesystem_scan(refresh_unraid: bool = False) -> dict:
    _refresh_unraid = refresh_unraid
    """
    Scan Synology NFS roots in parallel (fast).
    For Unraid, call the Unraid Agent API (avoids slow CIFS scan over VPN).
    """
    from concurrent.futures import ThreadPoolExecutor, as_completed
    from concurrent.futures import TimeoutError as FuturesTimeout

    result: dict = {
        'synology': {'hd_movies': [], '4k_movies': [], 'hd_tv': [], '4k_tv': []},
        'unraid':   {'hd_movies': [], '4k_movies': [], 'hd_tv': [], '4k_tv': []},
        'errors': [],
        'skipped': [],
        'unraid_agent': None,
    }

    # ── Synology: parallel NFS scan ───────────────────────────────────────────
    active_roots = [args for args in _SCAN_ROOTS if args[0] not in _SCAN_SKIP_ROOTS]

    with ThreadPoolExecutor(max_workers=max(len(active_roots), 1)) as pool:
        futures = {pool.submit(_scan_one_root, args): args for args in active_roots}
        for future in as_completed(futures, timeout=_PER_ROOT_TIMEOUT * max(len(active_roots), 1)):
            try:
                source, ftype, items, err = future.result(timeout=_PER_ROOT_TIMEOUT)
                result[source][ftype].extend(items)
                if err:
                    result['errors'].append(f"{source}/{ftype}: {err}")
            except FuturesTimeout:
                args = futures[future]
                log.warning(f"FS scan timeout: {args[0]}")
                result['errors'].append(f"{args[1]}/{args[2]}: scan timed out")
            except Exception as e:
                log.error(f"FS scan future error: {e}")

    # ── Unraid: call agent API ────────────────────────────────────────────────
    agent_data = _fetch_unraid_agent_scan(refresh=_refresh_unraid)
    if agent_data and 'unraid' in agent_data:
        for ftype in ('hd_movies', '4k_movies', 'hd_tv', '4k_tv'):
            result['unraid'][ftype] = agent_data['unraid'].get(ftype, [])
        result['unraid_agent'] = {
            'ok': True,
            'scan_time_seconds': agent_data.get('scan_time_seconds'),
            'errors': agent_data.get('errors', []),
        }
        log.info(f"Unraid agent scan: "
                 f"hd_movies={len(result['unraid']['hd_movies'])}, "
                 f"4k_movies={len(result['unraid']['4k_movies'])}, "
                 f"hd_tv={len(result['unraid']['hd_tv'])}, "
                 f"4k_tv={len(result['unraid']['4k_tv'])}")
    else:
        result['unraid_agent'] = {'ok': False, 'error': 'Agent unreachable or not configured'}
        log.warning('Unraid agent scan unavailable — Unraid tabs will show placeholder')

    # ── Multi-part / always-protected filter ──────────────────────────────────
    # Must run before Profile Authority correction so protected groups never reach
    # the UI or a bulk-delete call at all — see _filter_protected_groups docstring.
    for src in ('synology', 'unraid'):
        for ftype in ('hd_movies', '4k_movies', 'hd_tv', '4k_tv'):
            result[src][ftype] = _filter_protected_groups(result[src][ftype])

    # ── Profile Authority correction ──────────────────────────────────────────
    # Neither the Synology scan (pure filesystem) nor the Unraid Agent scan (also
    # pure filesystem) know what Radarr/Sonarr currently tracks — they only sort by
    # raw TRaSH score. Re-rank every group here so the actively-tracked file always
    # wins, regardless of score. See _enforce_profile_authority() docstring.
    # tier7_pending fetch is a separate concern from Profile Authority itself (it can
    # fail independently) — see _enforce_profile_authority()'s tier7_pending docstring.
    # Fails open (scan still returns, tier7_guard.ok=False signals the UI) since this
    # is a human-reviewed page, not automated deletion — same risk tier as
    # profile_authority.ok above.
    try:
        radarr_hd_tier7 = _fetch_tier7_pending('radarr-hd')
        radarr_4k_tier7 = _fetch_tier7_pending('radarr-4k')
        result['tier7_guard'] = {'ok': True}
    except Exception as e:
        log.error(f"Tier 7 pending-check failed (duplicates won't be flagged as tier7-pending this scan): {e}")
        radarr_hd_tier7 = radarr_4k_tier7 = set()
        result['tier7_guard'] = {'ok': False, 'error': str(e)}

    try:
        radarr_hd_tracked = _fetch_radarr_tracked('radarr-hd')
        radarr_4k_tracked = _fetch_radarr_tracked('radarr-4k')
        sonarr_hd_tracked = _fetch_sonarr_tracked('sonarr-hd')
        sonarr_4k_tracked = _fetch_sonarr_tracked('sonarr-4k')
        for src in ('synology', 'unraid'):
            _enforce_profile_authority(result[src]['hd_movies'], tracked_by_title=radarr_hd_tracked, media_type='movie', tier7_pending=radarr_hd_tier7)
            _enforce_profile_authority(result[src]['4k_movies'], tracked_by_title=radarr_4k_tracked, media_type='movie', tier7_pending=radarr_4k_tier7)
            _enforce_profile_authority(result[src]['hd_tv'], tracked_by_episode=sonarr_hd_tracked, media_type='tv')
            _enforce_profile_authority(result[src]['4k_tv'], tracked_by_episode=sonarr_4k_tracked, media_type='tv')
        result['profile_authority'] = {'ok': True}
    except Exception as e:
        # Visible in the response, not just the server log — a human reviewing this
        # scan before a bulk delete needs to know raw-score ranking is unverified
        # against Radarr/Sonarr's tracked files right now, not just silently trust it.
        log.error(f"Profile Authority correction failed (scan proceeds with raw-score ranking): {e}")
        result['profile_authority'] = {'ok': False, 'error': str(e)}

    result['summary'] = {
        src: {
            ftype: {
                'groups': len(result[src][ftype]),
                'deletable_bytes': sum(g['deletable_size_bytes'] for g in result[src][ftype]),
            }
            for ftype in ('hd_movies', '4k_movies', 'hd_tv', '4k_tv')
        }
        for src in ('synology', 'unraid')
    }
    return result


def _empty_scan_result() -> dict:
    empty_ftypes = {ft: {'groups': 0, 'deletable_bytes': 0}
                    for ft in ('hd_movies', '4k_movies', 'hd_tv', '4k_tv')}
    return {
        'synology': {'hd_movies': [], '4k_movies': [], 'hd_tv': [], '4k_tv': []},
        'unraid':   {'hd_movies': [], '4k_movies': [], 'hd_tv': [], '4k_tv': []},
        'errors': [], 'skipped': [], 'unraid_agent': None,
        'summary': {'synology': dict(empty_ftypes), 'unraid': dict(empty_ftypes)},
    }


def run_background_scan(refresh_unraid: bool = False) -> bool:
    """Start a background filesystem scan in a daemon thread.
    Returns True if scan was started, False if already in progress."""
    global _scan_in_progress
    with _scan_lock:
        if _scan_in_progress:
            return False
        _scan_in_progress = True

    def _worker():
        global _scan_in_progress
        try:
            data = _do_filesystem_scan(refresh_unraid=refresh_unraid)
            _scan_cache['data'] = data
            _scan_cache['ts'] = time.time()
            log.info("Background filesystem scan complete")
        except Exception as e:
            log.error(f"Background filesystem scan failed: {e}")
        finally:
            _scan_in_progress = False

    threading.Thread(target=_worker, daemon=True, name='curatorr-fs-scan').start()
    return True


@router.get('/duplicates/scan')
async def scan_filesystem_duplicates(refresh: bool = False, _auth=Depends(require_auth)):
    """
    Filesystem-based duplicate scan across Synology and Unraid.
    Returns immediately: cached data if available, otherwise kicks off a background scan
    and returns scanning=True. Poll again every few seconds until scanning=False.
    Pass ?refresh=true to force a fresh scan (also returns immediately while scan runs).
    """
    now = time.time()
    cache_age = now - _scan_cache['ts']
    cache_fresh = _scan_cache['data'] is not None and cache_age < SCAN_CACHE_TTL

    if not refresh and cache_fresh:
        return {**_scan_cache['data'], 'cached': True,
                'cached_age_s': int(cache_age), 'scanning': False}

    # Trigger background scan (no-op if already running)
    run_background_scan(refresh_unraid=refresh)

    base = _scan_cache['data'] if _scan_cache['data'] else _empty_scan_result()
    return {**base, 'cached': bool(_scan_cache['data']),
            'cached_age_s': int(cache_age) if _scan_cache['data'] else 0,
            'scanning': True}


class BulkDeleteItem(BaseModel):
    file_path: str    # Path from the filesystem scan (Synology NFS or Unraid CIFS)
    title: str = ''
    media_type: str = 'movie'


class BulkDeleteRequest(BaseModel):
    items: List[BulkDeleteItem]
    dry_run: bool = False


@router.post('/duplicates/bulk-delete')
async def bulk_delete_duplicates(body: BulkDeleteRequest, _auth=Depends(require_auth)):
    """
    Delete duplicate files from one server only — the server the scan ran against.
    Safe route: each server's cleanup is independent. Synology deletes stay on Synology;
    Unraid deletes stay on Unraid (Unraid scanning requires the Unraid Agent).
    Pass dry_run=true to preview without touching files.
    """
    from app.notifications import send_notification

    safe_items, results = _reject_tier7_pending_items(body.items)
    total_freed = 0

    for item in safe_items:
        path = item.file_path

        # Issue 5 fix: bulk_delete only handles Synology paths.
        # Unraid deletions must go through /duplicates/unraid-delete (via Agent),
        # which provides audit logging and path safety checks.
        if not any(path.startswith(p) for p in _SYNOLOGY_DELETE_PREFIXES):
            if any(path.startswith(p) for p in _UNRAID_DELETE_PREFIXES):
                results.append({'file_path': path, 'ok': False,
                                 'error': 'Use /duplicates/unraid-delete for Unraid paths'})
            else:
                results.append({'file_path': path, 'ok': False,
                                 'error': 'Path not in allowed Synology media directories'})
            log.warning(f"Bulk delete rejected (not Synology path): {path}")
            continue

        # Symlink safety
        try:
            real = os.path.realpath(path)
        except Exception:
            real = path
        if not any(real.startswith(p.rstrip('/')) for p in _SYNOLOGY_DELETE_PREFIXES):
            results.append({'file_path': path, 'ok': False,
                             'error': 'Symlink resolves outside allowed directories'})
            log.warning(f"Bulk delete symlink escape: {path} -> {real}")
            continue

        if body.dry_run:
            try:
                size = os.path.getsize(path)
            except OSError:
                size = 0
            results.append({'file_path': path, 'ok': True, 'dry_run': True, 'freed_bytes': size})
            total_freed += size
            continue

        try:
            size = os.path.getsize(path)
            os.remove(path)
            _purge_synology_recycle(path)
            total_freed += size
            results.append({'file_path': path, 'ok': True, 'freed_bytes': size})
            log.info(f"Bulk delete: removed {path} ({size:,} bytes)")
        except FileNotFoundError:
            results.append({'file_path': path, 'ok': True, 'freed_bytes': 0, 'note': 'Already gone'})
        except Exception as e:
            results.append({'file_path': path, 'ok': False, 'error': str(e)})
            log.error(f"Bulk delete failed: {path} — {e}")

    ok_count = sum(1 for r in results if r['ok'])

    if not body.dry_run and ok_count > 0:
        _scan_cache['data'] = None
        _scan_cache['ts'] = 0.0
        gb = total_freed / 1_073_741_824
        try:
            send_notification(f"Curatorr: {ok_count} duplicate file(s) deleted, {gb:.2f} GB freed")
        except Exception:
            pass

    return {
        'deleted': ok_count,
        'failed': len(results) - ok_count,
        'total_freed_bytes': total_freed,
        'dry_run': body.dry_run,
        'results': results,
    }


@router.post('/duplicates/unraid-delete')
async def unraid_delete_duplicates(body: BulkDeleteRequest, _auth=Depends(require_auth)):
    """
    Proxy bulk delete to the Unraid Agent.
    Files must be on Unraid (/mnt/user/Media/...). Agent handles path validation.
    """
    from app.notifications import send_notification
    import json as _json

    if not UNRAID_AGENT_URL or not UNRAID_AGENT_API_KEY:
        raise HTTPException(503, 'Unraid agent not configured (UNRAID_AGENT_URL / UNRAID_AGENT_API_KEY)')

    import urllib.request
    import urllib.error

    safe_items, rejected = _reject_tier7_pending_items(body.items)

    if body.dry_run:
        # Agent doesn't support dry_run — simulate from size lookups
        results = [{'file_path': i.file_path, 'ok': True, 'dry_run': True} for i in safe_items] + rejected
        return {'deleted': 0, 'failed': len(rejected), 'total_freed_bytes': 0, 'dry_run': True,
                'results': results}

    if not safe_items:
        return {'deleted': 0, 'failed': len(rejected), 'total_freed_bytes': 0, 'dry_run': False,
                'results': rejected}

    payload = _json.dumps({'paths': [item.file_path for item in safe_items]}).encode()
    url = f"{UNRAID_AGENT_URL.rstrip('/')}/delete"

    try:
        req = urllib.request.Request(url, data=payload, method='POST',
                                     headers={'X-Api-Key': UNRAID_AGENT_API_KEY,
                                              'Content-Type': 'application/json'})
        with urllib.request.urlopen(req, timeout=60) as resp:
            agent_result = _json.loads(resp.read())
    except Exception as e:
        raise HTTPException(502, f'Unraid agent error: {e}')

    ok_count = len(agent_result.get('deleted', []))
    freed = agent_result.get('freed_bytes', 0)

    if ok_count > 0:
        _scan_cache['data'] = None
        _scan_cache['ts'] = 0.0
        gb = freed / 1_073_741_824
        try:
            send_notification(f"Curatorr (Unraid): {ok_count} duplicate(s) deleted, {gb:.2f} GB freed")
        except Exception:
            pass

    errors = agent_result.get('errors', [])
    results = [{'file_path': p, 'ok': True, 'freed_bytes': 0} for p in agent_result.get('deleted', [])]
    results += [{'file_path': e['path'], 'ok': False, 'error': e['error']} for e in errors]
    results += rejected

    return {
        'deleted': ok_count,
        'failed': len(errors) + len(rejected),
        'total_freed_bytes': freed,
        'dry_run': False,
        'results': results,
    }


@router.get('/duplicates/plex')
async def list_plex_duplicates(server: str = 'chris', _auth=Depends(require_auth)):
    """Return movies Plex identifies as having multiple media files (native duplicate detection).
    Uses /library/sections/{id}/all?duplicate=1 for the given Plex server.
    """
    from app.config import CHRIS_PLEX_URL, CHRIS_PLEX_TOKEN, ALI_PLEX_URL, ALI_PLEX_TOKEN

    if server == 'ali':
        url = (await get_config('plex_ali_url', ALI_PLEX_URL) or '').rstrip('/')
        token = await get_config('plex_ali_token', ALI_PLEX_TOKEN) or ''
    else:
        url = (await get_config('plex_chris_url', CHRIS_PLEX_URL) or '').rstrip('/')
        token = await get_config('plex_chris_token', CHRIS_PLEX_TOKEN) or ''

    if not url or not token:
        return {'error': f'Plex {server} not configured', 'items': []}

    # Discover library sections
    try:
        async with httpx.AsyncClient(timeout=15, follow_redirects=True) as client:
            r = await client.get(f"{url}/library/sections",
                                 headers={'X-Plex-Token': token, 'Accept': 'application/xml'})
            r.raise_for_status()
            root = ET.fromstring(r.text)
            movie_sections = [d.get('key') for d in root.findall('.//Directory')
                              if d.get('type') == 'movie']

            items = []
            for section_id in movie_sections:
                dr = await client.get(
                    f"{url}/library/sections/{section_id}/all",
                    params={'duplicate': '1'},
                    headers={'X-Plex-Token': token, 'Accept': 'application/xml'},
                )
                dr.raise_for_status()
                sroot = ET.fromstring(dr.text)
                for video in sroot.findall('.//Video'):
                    media_list = video.findall('Media')
                    if len(media_list) < 2:
                        continue
                    versions = []
                    for media in media_list:
                        part = media.find('Part')
                        height = int(media.get('videoResolution', '0').replace('k', '000') or 0)
                        if media.get('videoResolution', '') == '4k':
                            res = '4K'
                        elif height >= 1080:
                            res = '1080p'
                        elif height >= 720:
                            res = '720p'
                        elif height > 0:
                            res = 'SD'
                        else:
                            res = media.get('videoResolution', '?')
                        versions.append({
                            'resolution': res,
                            'video_codec': media.get('videoCodec', ''),
                            'audio_codec': media.get('audioCodec', ''),
                            'audio_channels': media.get('audioChannels', ''),
                            'duration_ms': int(media.get('duration', 0) or 0),
                            'file_size_bytes': int(part.get('size', 0) if part is not None else 0),
                            'file_path': part.get('file', '') if part is not None else '',
                            'bitrate': int(media.get('bitrate', 0) or 0),
                            'plex_media_id': media.get('id', ''),
                        })
                    for v in versions:
                        v['trash_score'] = _score_plex_version(v)
                    versions_scored = sorted(versions, key=lambda v: v['trash_score'], reverse=True)
                    items.append({
                        'title': video.get('title', ''),
                        'year': int(video.get('year', 0) or 0),
                        'plex_key': video.get('ratingKey', ''),
                        'thumb': video.get('thumb', ''),
                        'tmdb_id': None,
                        'versions': versions_scored,
                    })

        return {'server': server, 'count': len(items), 'items': items}
    except Exception as e:
        log.error(f"Plex duplicate fetch error ({server}): {e}")
        return {'error': str(e), 'server': server, 'items': []}


class PlexDeleteRequest(BaseModel):
    file_path: str
    title: str
    year: int
    server: str = 'chris'


@router.post('/duplicates/plex/delete')
async def delete_plex_version(body: PlexDeleteRequest, _auth=Depends(require_auth)):
    """Delete one specific version of a Plex duplicate via Radarr moviefile API,
    with fallback to direct Unraid NFS deletion for orphaned files."""
    file_path = body.file_path
    if not file_path:
        raise HTTPException(400, 'file_path required')

    target_name = os.path.basename(file_path)
    log.info(f"Plex delete request: {body.title} ({body.year}) — {target_name}")

    # ── 1. Look up movie in DB (exact title+year, fallback to filename fragment) ─
    async for db in get_db():
        async with db.execute(
            "SELECT radarr_id, radarr_instance FROM movies "
            "WHERE (title=? AND year=?) OR file_path LIKE ? "
            "AND radarr_id IS NOT NULL ORDER BY (title=? AND year=?) DESC LIMIT 1",
            (body.title, body.year, f'%{target_name}%', body.title, body.year)
        ) as cur:
            row = await cur.fetchone()

    # ── 2. Try Radarr moviefile delete ────────────────────────────────────────
    radarr_deleted = False
    if row:
        radarr_id = row['radarr_id']
        inst = next((i for i in RADARR_INSTANCES if i['name'] == row['radarr_instance']), None)
        if inst:
            try:
                async with httpx.AsyncClient(timeout=15) as client:
                    r = await client.get(
                        f"{inst['url']}/api/v3/moviefile",
                        params={'movieId': radarr_id},
                        headers={'X-Api-Key': inst['api_key']},
                    )
                    movie_files = r.json() if r.status_code == 200 else []

                    # Match by filename
                    target_mf = next(
                        (mf for mf in movie_files
                         if os.path.basename(mf.get('relativePath', mf.get('path', ''))) == target_name),
                        None
                    )
                    if target_mf and len(movie_files) >= 2:
                        dr = await client.delete(
                            f"{inst['url']}/api/v3/moviefile/{target_mf['id']}",
                            headers={'X-Api-Key': inst['api_key']},
                        )
                        radarr_deleted = dr.status_code in (200, 204)
                        if radarr_deleted:
                            log.info(f"Radarr deleted moviefile {target_mf['id']}: {target_name}")
                    elif target_mf and len(movie_files) < 2:
                        raise HTTPException(400, 'Only one Radarr file entry — refusing to delete (would break movie)')
            except HTTPException:
                raise
            except Exception as e:
                log.warning(f"Radarr moviefile delete failed: {e}")

    # ── 3. Fallback: use Unraid Agent for orphaned files (Issue 6 fix) ───────
    # Previously used os.remove() on CIFS, bypassing audit log and Agent safety
    # checks. Now always routes through Agent for Unraid paths.
    disk_deleted = False
    if not radarr_deleted:
        unraid_path = synology_to_unraid_path(file_path)
        if not unraid_path and file_path.startswith(UNRAID_MEDIA_PATH):
            unraid_path = file_path
        if unraid_path and unraid_path.startswith(UNRAID_MEDIA_PATH):
            try:
                import httpx
                agent_resp = await httpx.AsyncClient(timeout=30).post(
                    f"{UNRAID_AGENT_URL.rstrip('/')}/delete",
                    json={'paths': [unraid_path]},
                    headers={'X-Api-Key': UNRAID_AGENT_API_KEY},
                )
                result = agent_resp.json()
                disk_deleted = unraid_path in result.get('deleted', [])
                if disk_deleted:
                    log.info(f"Agent deleted orphaned Plex file: {unraid_path}")
                elif result.get('errors'):
                    log.error(f"Agent delete failed for {unraid_path}: {result['errors']}")
                    raise HTTPException(500, f'Agent delete failed: {result["errors"]}')
            except HTTPException:
                raise
            except Exception as e:
                log.error(f"Agent delete failed for {unraid_path}: {e}")
                raise HTTPException(500, f'Delete failed: {e}')

    if not radarr_deleted and not disk_deleted:
        raise HTTPException(404, f'Could not locate or delete file: {target_name}')

    return {
        'deleted': True,
        'file': target_name,
        'method': 'radarr' if radarr_deleted else 'disk',
    }


@router.get('/duplicates/tv')
async def list_tv_duplicates(_auth=Depends(require_auth)):
    """Find TV shows that exist in multiple Sonarr instances (same TMDB ID)."""
    async for db in get_db():
        async with db.execute("""
            SELECT tmdb_id, COUNT(*) AS instance_count
            FROM tv_shows
            WHERE tmdb_id IS NOT NULL
            GROUP BY tmdb_id
            HAVING COUNT(*) > 1
        """) as cur:
            dup_groups = [row['tmdb_id'] for row in await cur.fetchall()]

        if not dup_groups:
            return []

        result = []
        for tmdb_id in dup_groups:
            async with db.execute(
                "SELECT id, title, year, sonarr_instance, sonarr_id, total_seasons, total_episodes, "
                "composite_score, purge_score, poster_url, monitored, imdb_rating "
                "FROM tv_shows WHERE tmdb_id=? ORDER BY total_episodes DESC NULLS LAST",
                (tmdb_id,)
            ) as cur:
                versions = [dict(r) for r in await cur.fetchall()]

            if len(versions) >= 2:
                # Recommend keeping the version with most episodes (usually the one with more data)
                result.append({
                    'tmdb_id': tmdb_id,
                    'title': versions[0]['title'],
                    'year': versions[0]['year'],
                    'versions': versions,
                    'recommended_keep_id': versions[0]['id'],
                })

        return result
