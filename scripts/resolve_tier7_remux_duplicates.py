#!/usr/bin/env python3
"""
Resolves the Tier 7 / duplicate-scanner coordination gap: movies where Curatorr
correctly keeps a Remux (Profile Authority — Radarr's tracked file wins) but
Upgraderr already has an active tier7_profile_mismatch search out because the
profile doesn't allow Remux. Instead of letting Radarr search indexers for a
replacement we may already have, this reverse-syncs the best already-downloaded
Unraid Bluray/WEB alternate back to Synology and manually imports it into Radarr
— zero new downloads.

Candidate selection per flagged movie:
  - Only versions the duplicate scan already flagged pending_tier7=True
  - Skip known-bad release groups (BHDStudio) and MP4 containers
  - Skip if the parsed quality isn't in the movie's assigned Radarr quality
    profile's allowed list (must be resolvable to a *better* end state, not just
    "not the worst")
  - Among remaining candidates, keep the highest-scoring file (shared JSON
    scoring module — same one Upgraderr/sync-webhook/Curatorr all use)

Per-movie resolution sequence: reverse-sync (Unraid -> Synology, no delete) via
sync-webhook's /sync/reverse -> poll to completion -> verify file landed on
Synology -> Radarr manualimport (validate) -> execute ManualImport command ->
poll to completion -> verify movieFile now points at the new file. Any failure
at any step leaves everything in place (still protected by pending_tier7) and
is logged for manual follow-up — no retries within a run.

No explicit deletion of the old Remux: once Radarr's tracked file changes,
Upgraderr's next sweep clears its own queue row, the next Curatorr/sync-webhook
scan sees pending_tier7 clear, and the *existing* nightly dedup deletes the
Remux like any other ordinary duplicate.

Usage:
  python3 resolve_tier7_remux_duplicates.py --limit 5              # dry run (default)
  DRY_RUN=false python3 resolve_tier7_remux_duplicates.py --limit 1 --only "Ninja Assassin"
"""
import argparse
import json
import os
import re
import sys
import time
from pathlib import Path

import requests

sys.path.insert(0, str(Path(__file__).parent / 'lib'))
from trash_scoring_json import calculate_quality_score, parse_quality_from_filename  # noqa: E402


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


load_env()

DRY_RUN = os.environ.get('DRY_RUN', 'true').lower() != 'false'
SLEEP_SECONDS = int(os.environ.get('SLEEP_SECONDS', '45'))
SYNC_POLL_TIMEOUT = int(os.environ.get('SYNC_POLL_TIMEOUT', '1800'))  # 30 min per file

CURATORR_URL = f"http://localhost:{os.environ.get('CURATORR_PORT', '9707')}"
CURATORR_USER = 'bishop'
CURATORR_PASS = '858T!GSE68pPsfrf'

SYNC_WEBHOOK_URL = f"http://localhost:{os.environ.get('SYNC_WEBHOOK_PORT', '5001')}"

RADARR_INSTANCES = {
    'radarr-hd': {
        'url': f"http://localhost:{os.environ.get('RADARR_HD_PORT', '7878')}",
        'api_key': os.environ.get('RADARR_HD_API_KEY', ''),
        'container_movies_prefix': '/movies',
        'synology_root': '/mnt/synology/rs-movies',
        'unraid_root': '/mnt/unraid/media/Movies',
    },
    'radarr-4k': {
        'url': f"http://localhost:{os.environ.get('RADARR_4K_PORT', '7879')}",
        'api_key': os.environ.get('RADARR_4K_API_KEY', ''),
        'container_movies_prefix': '/movies-4k',
        'synology_root': '/mnt/synology/rs-4kmedia/4kmovies',
        'unraid_root': '/mnt/unraid/media/4K Movies',
    },
}

BAD_RELEASE_GROUPS = {'bhdstudio'}  # matches Upgraderr's BAD_RELEASE_GROUPS


def normalize_title(title):
    t = re.sub(r'\s*\(\d{4}\)\s*$', '', title)
    t = t.lower().replace('&', ' and ')
    return re.sub(r'[^a-z0-9]+', '', t)


def radarr_quality_name(source, resolution):
    """Map parsed (source, resolution) to Radarr's quality name format, e.g.
    ('Bluray', '1080p') -> 'Bluray-1080p', ('WEB-DL', '1080p') -> 'WEBDL-1080p'."""
    src = source.upper().replace('WEB-DL', 'WEBDL')
    src = {'BLURAY': 'Bluray', 'WEBDL': 'WEBDL', 'WEBRIP': 'WEBRip',
           'HDTV': 'HDTV', 'REMUX': 'Remux'}.get(src, source)
    return f"{src}-{resolution}"


def curatorr_session():
    s = requests.Session()
    r = s.post(f"{CURATORR_URL}/api/login", json={'username': CURATORR_USER, 'password': CURATORR_PASS}, timeout=15)
    r.raise_for_status()
    if not r.json().get('ok'):
        raise RuntimeError(f"Curatorr login failed: {r.text}")
    return s


def fetch_flagged_groups(session, refresh=True):
    """hd_movies + 4k_movies duplicate groups where the kept version is
    profile_authority and at least one other version is pending_tier7."""
    url = f"{CURATORR_URL}/api/duplicates/scan"
    if refresh:
        url += "?refresh=true"
    r = session.get(url, timeout=180)
    r.raise_for_status()
    data = r.json()
    out = []
    for lib_key, instance in (('hd_movies', 'radarr-hd'), ('4k_movies', 'radarr-4k')):
        for grp in data.get('unraid', {}).get(lib_key, []):
            kept = grp['versions'][0]
            if kept.get('kept_reason') != 'profile_authority':
                continue
            flagged = [v for v in grp['versions'][1:] if v.get('pending_tier7')]
            if flagged:
                out.append({'title': grp['title'], 'instance': instance, 'kept': kept, 'candidates': flagged})
    return out


def get_movie_and_profile(instance_cfg, title):
    r = requests.get(f"{instance_cfg['url']}/api/v3/movie", headers={'X-Api-Key': instance_cfg['api_key']}, timeout=60)
    r.raise_for_status()
    movies = r.json()
    norm = normalize_title(title)
    movie = next((m for m in movies if normalize_title(m['title'] + f" ({m.get('year', '')})") == norm
                  or normalize_title(m['title']) == norm), None)
    if not movie:
        return None, None
    r2 = requests.get(f"{instance_cfg['url']}/api/v3/qualityprofile/{movie['qualityProfileId']}",
                       headers={'X-Api-Key': instance_cfg['api_key']}, timeout=30)
    r2.raise_for_status()
    profile = r2.json()
    allowed = set()
    for item in profile.get('items', []):
        if item.get('quality') and item.get('allowed'):
            allowed.add(item['quality']['name'])
        for sub in item.get('items', []):
            if sub.get('quality') and item.get('allowed'):
                allowed.add(sub['quality']['name'])
    return movie, allowed


def pick_best_candidate(candidates, allowed_qualities):
    """Filter candidates to known-good, profile-allowed releases; return the
    highest-scoring one, or None if nothing qualifies."""
    scored = []
    for v in candidates:
        fname = os.path.basename(v['file_path'])
        if fname.lower().endswith('.mp4'):
            continue
        parsed = parse_quality_from_filename(fname)
        group = parsed.get('release_group', '').lower()
        if group in BAD_RELEASE_GROUPS:
            continue
        if not parsed.get('source') or not parsed.get('resolution'):
            continue
        qname = radarr_quality_name(parsed['source'], parsed['resolution'])
        if qname not in allowed_qualities:
            continue
        size_gb = v.get('file_size_bytes', 0) / 1_073_741_824
        score = calculate_quality_score(
            resolution=parsed['resolution'], source=parsed['source'], hdr=parsed.get('hdr', ''),
            audio=parsed.get('audio', ''), codec=parsed.get('codec', ''), size_gb=size_gb,
            is_4k=(parsed['resolution'] == '2160p'), media_type='movie',
        )
        scored.append((score, v, qname))
    if not scored:
        return None, None
    scored.sort(key=lambda x: x[0], reverse=True)
    _, best, qname = scored[0]
    return best, qname


def folder_name_from_unraid_path(path):
    """.../Movies/<Folder Name>/<file>.mkv -> 'Folder Name'"""
    return os.path.basename(os.path.dirname(path))


def agent_path_to_cifs_path(agent_path, instance):
    """Curatorr's duplicate scan reports file_path via the Unraid Agent's inventory
    API, e.g. /mnt/user/Media/Movies/<folder>/<file> — that root only exists on
    Unraid itself. sync-webhook reaches Unraid over the CIFS mount instead
    (/mnt/unraid/media/Movies/...), which is what /sync/reverse actually needs as
    its source path. Rebuild the CIFS path from the folder+filename rather than
    string-replacing the prefix, since the Agent and CIFS roots don't share a
    common ancestor on Mother's filesystem."""
    folder = folder_name_from_unraid_path(agent_path)
    fname = os.path.basename(agent_path)
    return os.path.join(RADARR_INSTANCES[instance]['unraid_root'], folder, fname)


def do_reverse_sync(unraid_path, synology_folder_path, title):
    r = requests.post(f"{SYNC_WEBHOOK_URL}/sync/reverse", json={
        'source': unraid_path, 'dest': synology_folder_path, 'title': title, 'media_type': 'Movie',
    }, timeout=30)
    if r.status_code != 202:
        raise RuntimeError(f"reverse sync queue failed: {r.status_code} {r.text}")
    return r.json().get('job_id')


def poll_sync_job(job_id, timeout=SYNC_POLL_TIMEOUT):
    if job_id is None:
        raise RuntimeError("no job_id returned from /sync/reverse")
    deadline = time.time() + timeout
    while time.time() < deadline:
        r = requests.get(f"{SYNC_WEBHOOK_URL}/jobs/{job_id}", timeout=15)
        r.raise_for_status()
        job = r.json()
        if job.get('status') == 'success':
            return True, job
        if job.get('status') == 'failed':
            return False, job
        time.sleep(10)
    return False, {'error': 'timeout'}


def manual_import_and_execute(instance_cfg, container_folder, movie_id, expected_quality_name):
    r = requests.get(f"{instance_cfg['url']}/api/v3/manualimport",
                      params={'folder': container_folder}, headers={'X-Api-Key': instance_cfg['api_key']}, timeout=60)
    r.raise_for_status()
    candidates = r.json()
    match = None
    for c in candidates:
        if c.get('movie', {}).get('id') == movie_id and not c.get('rejections'):
            if c.get('quality', {}).get('quality', {}).get('name') == expected_quality_name:
                match = c
                break
            match = match or c
    if not match:
        return False, f"no valid manualimport candidate found in {container_folder}"
    if match.get('rejections'):
        return False, f"manualimport rejected: {match['rejections']}"

    cmd_body = {
        'name': 'ManualImport',
        'files': [{
            'path': match['path'], 'movieId': movie_id,
            'quality': match['quality'], 'languages': match.get('languages', []),
            'releaseGroup': match.get('releaseGroup'), 'indexerFlags': match.get('indexerFlags', 0),
        }],
        'importMode': 'move',
    }
    r2 = requests.post(f"{instance_cfg['url']}/api/v3/command", json=cmd_body,
                        headers={'X-Api-Key': instance_cfg['api_key']}, timeout=30)
    r2.raise_for_status()
    command_id = r2.json()['id']

    deadline = time.time() + 300
    while time.time() < deadline:
        r3 = requests.get(f"{instance_cfg['url']}/api/v3/command/{command_id}",
                           headers={'X-Api-Key': instance_cfg['api_key']}, timeout=30)
        r3.raise_for_status()
        status = r3.json().get('status')
        if status == 'completed':
            return True, None
        if status == 'failed':
            return False, f"ManualImport command failed: {r3.json()}"
        time.sleep(5)
    return False, "ManualImport command timed out"


def resolve_one(item, log):
    title, instance = item['title'], item['instance']
    instance_cfg = RADARR_INSTANCES[instance]

    movie, allowed = get_movie_and_profile(instance_cfg, title)
    if not movie:
        log.append(f"SKIP {title}: not found in {instance}")
        return False

    best, qname = pick_best_candidate(item['candidates'], allowed)
    if not best:
        log.append(f"SKIP {title}: no safe profile-allowed alternate among candidates — leaving to Upgraderr's Tier 7 search")
        return False

    agent_path = best['file_path']
    folder = folder_name_from_unraid_path(agent_path)
    unraid_cifs_path = agent_path_to_cifs_path(agent_path, instance)
    synology_folder = os.path.join(instance_cfg['synology_root'], folder)
    fname = os.path.basename(agent_path)
    synology_file_path = os.path.join(synology_folder, fname)

    already_synced = os.path.exists(synology_file_path)

    if not already_synced:
        if not os.path.exists(unraid_cifs_path):
            log.append(f"SKIP {title}: expected CIFS path not found: {unraid_cifs_path} (mount stale, or Curatorr's cached scan is out of date — re-run with a fresh scan)")
            return False

        log.append(f"RESOLVE {title} [{instance}]: reverse-sync {fname} (best-scoring allowed alternate, quality={qname})")

        if DRY_RUN:
            log.append(f"  [DRY RUN] would reverse-sync {unraid_cifs_path} -> {synology_folder}, then manual-import into Radarr")
            return True

        job_id = do_reverse_sync(unraid_cifs_path, synology_folder, title)
        ok, job = poll_sync_job(job_id)
        if not ok:
            log.append(f"  FAILED reverse sync: {job}")
            return False

        if not os.path.exists(synology_file_path):
            log.append(f"  FAILED: sync reported success but {synology_file_path} not found — stopping, nothing else touched")
            return False
        log.append(f"  OK: {fname} now on Synology")
    else:
        # File already landed on Synology from a prior run of this script (e.g. the
        # reverse-sync completed but the run ended/timed out before manual import ran).
        # Resume from the import step instead of re-syncing.
        if DRY_RUN:
            log.append(f"RESOLVE {title} [{instance}]: {fname} already on Synology")
            log.append(f"  [DRY RUN] would manual-import into Radarr")
            return True
        log.append(f"RESOLVE {title} [{instance}]: {fname} already on Synology — resuming from manual import")

    container_folder = os.path.join(instance_cfg['container_movies_prefix'], folder)
    ok, err = manual_import_and_execute(instance_cfg, container_folder, movie['id'], qname)
    if not ok:
        log.append(f"  FAILED manual import: {err} — file left on Synology alongside Remux, needs manual follow-up")
        return False
    log.append(f"  OK: manual import complete for {title}")

    # The ManualImport command can report 'completed' slightly before Radarr's own
    # /movie/{id} response reflects the new movieFile (observed directly: an
    # immediate re-fetch here returned the stale Remux even though the import had
    # genuinely succeeded) — retry briefly rather than false-alarm on a race.
    new_rel = ''
    for attempt in range(6):
        r = requests.get(f"{instance_cfg['url']}/api/v3/movie/{movie['id']}",
                          headers={'X-Api-Key': instance_cfg['api_key']}, timeout=30)
        r.raise_for_status()
        updated = r.json()
        new_rel = (updated.get('movieFile') or {}).get('relativePath', '')
        if fname in new_rel:
            break
        time.sleep(3)
    if fname not in new_rel:
        log.append(f"  WARNING: Radarr's tracked file after import ({new_rel}) doesn't match expected {fname} — verify manually")
    else:
        log.append(f"  VERIFIED: Radarr now tracks {new_rel}")
    return True


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--limit', type=int, default=5)
    parser.add_argument('--only', type=str, default=None, help='Substring filter on title (case-insensitive)')
    parser.add_argument('--sleep-seconds', type=int, default=SLEEP_SECONDS)
    args = parser.parse_args()

    session = curatorr_session()
    flagged = fetch_flagged_groups(session, refresh=True)
    print(f"Found {len(flagged)} movie groups with a kept Remux + pending_tier7 alternate(s)")

    if args.only:
        flagged = [f for f in flagged if args.only.lower() in f['title'].lower()]
        print(f"Filtered to {len(flagged)} matching '--only {args.only}'")

    flagged = flagged[:args.limit]

    log = []
    resolved = 0
    for item in flagged:
        try:
            if resolve_one(item, log):
                resolved += 1
        except Exception as e:
            log.append(f"ERROR {item['title']}: {e}")
        if item is not flagged[-1] and not DRY_RUN:
            time.sleep(args.sleep_seconds)

    print()
    print(f"{'[DRY RUN] ' if DRY_RUN else ''}Processed {len(flagged)}, resolved/would-resolve {resolved}")
    print()
    for line in log:
        print(line)


if __name__ == '__main__':
    main()
