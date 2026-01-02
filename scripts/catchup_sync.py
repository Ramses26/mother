#!/usr/bin/env python3
"""
Catch-Up Sync Script - Project Mother

Queries Radarr/Sonarr APIs for recently imported files and syncs them.
Use this to recover from webhook failures or missed syncs.

Usage:
    python3 catchup_sync.py --hours 24              # Last 24 hours
    python3 catchup_sync.py --hours 48 --dry-run    # Preview last 48 hours
    python3 catchup_sync.py --since "2026-01-01"    # Since specific date
"""

import os
import sys
import json
import argparse
import subprocess
import requests
from datetime import datetime, timedelta
from pathlib import Path


def load_env_file(env_path=None):
    """Load environment variables from .env file"""
    if env_path is None:
        # Try to find .env file - check parent directory (project root)
        script_dir = Path(__file__).parent
        env_path = script_dir.parent / '.env'

    env_vars = {}
    if env_path.exists():
        with open(env_path, 'r') as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    key, value = line.split('=', 1)
                    env_vars[key.strip()] = value.strip()
    return env_vars


# Load from .env file first, then allow environment variable overrides
ENV = load_env_file()

# Configuration - reads from .env file, can override with environment variables
CONFIG = {
    'RADARR_HD_URL': os.environ.get('RADARR_HD_URL', f"http://localhost:{ENV.get('RADARR_HD_PORT', '7878')}"),
    'RADARR_HD_API_KEY': os.environ.get('RADARR_HD_API_KEY', ENV.get('RADARR_HD_API_KEY', '')),
    'RADARR_4K_URL': os.environ.get('RADARR_4K_URL', f"http://localhost:{ENV.get('RADARR_4K_PORT', '7879')}"),
    'RADARR_4K_API_KEY': os.environ.get('RADARR_4K_API_KEY', ENV.get('RADARR_4K_API_KEY', '')),
    'SONARR_HD_URL': os.environ.get('SONARR_HD_URL', f"http://localhost:{ENV.get('SONARR_HD_PORT', '8989')}"),
    'SONARR_HD_API_KEY': os.environ.get('SONARR_HD_API_KEY', ENV.get('SONARR_HD_API_KEY', '')),
    'SONARR_4K_URL': os.environ.get('SONARR_4K_URL', f"http://localhost:{ENV.get('SONARR_4K_PORT', '8990')}"),
    'SONARR_4K_API_KEY': os.environ.get('SONARR_4K_API_KEY', ENV.get('SONARR_4K_API_KEY', '')),
}

# Path mappings - same as sync-webhook
PATH_MAPPINGS = {
    'radarr-hd': {
        'container': '/movies',
        'source': '/mnt/synology/rs-movies',
        'dest': '/mnt/unraid/media/Movies'
    },
    'radarr-4k': {
        'container': '/movies-4k',
        'source': '/mnt/synology/rs-4kmedia/4kmovies',
        'dest': '/mnt/unraid/media/4K Movies'
    },
    'sonarr-hd': {
        'container': '/tv',
        'source': '/mnt/synology/rs-tv',
        'dest': '/mnt/unraid/media/TV Shows'
    },
    'sonarr-4k': {
        'container': '/tv-4k',
        'source': '/mnt/synology/rs-4kmedia/4ktv',
        'dest': '/mnt/unraid/media/4K TV Shows'
    },
}


def log(msg, level='INFO'):
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    print(f"[{timestamp}] [{level}] {msg}")


def get_radarr_history(base_url, api_key, since_date):
    """Get import history from Radarr"""
    if not api_key:
        log(f"Skipping {base_url} - no API key", 'WARN')
        return []

    try:
        # Get history with downloadFolderImported events
        url = f"{base_url}/api/v3/history"
        params = {
            'pageSize': 500,
            'sortKey': 'date',
            'sortDirection': 'descending',
            'eventType': 'downloadFolderImported'
        }
        headers = {'X-Api-Key': api_key}

        response = requests.get(url, params=params, headers=headers, timeout=30)
        response.raise_for_status()
        data = response.json()

        imports = []
        for record in data.get('records', []):
            event_date = datetime.fromisoformat(record['date'].replace('Z', '+00:00'))
            if event_date.replace(tzinfo=None) >= since_date:
                movie_id = record.get('movieId')
                if movie_id:
                    # Get movie details
                    movie_url = f"{base_url}/api/v3/movie/{movie_id}"
                    movie_resp = requests.get(movie_url, headers=headers, timeout=10)
                    if movie_resp.ok:
                        movie = movie_resp.json()
                        imports.append({
                            'type': 'movie',
                            'title': movie.get('title', 'Unknown'),
                            'year': movie.get('year', ''),
                            'path': movie.get('path', ''),
                            'date': record['date']
                        })

        return imports

    except Exception as e:
        log(f"Error querying Radarr {base_url}: {e}", 'ERROR')
        return []


def get_sonarr_history(base_url, api_key, since_date):
    """Get import history from Sonarr"""
    if not api_key:
        log(f"Skipping {base_url} - no API key", 'WARN')
        return []

    try:
        url = f"{base_url}/api/v3/history"
        params = {
            'pageSize': 500,
            'sortKey': 'date',
            'sortDirection': 'descending',
            'eventType': 'downloadFolderImported'
        }
        headers = {'X-Api-Key': api_key}

        response = requests.get(url, params=params, headers=headers, timeout=30)
        response.raise_for_status()
        data = response.json()

        imports = []
        seen_series = set()  # Dedupe by series to avoid syncing same show multiple times

        for record in data.get('records', []):
            event_date = datetime.fromisoformat(record['date'].replace('Z', '+00:00'))
            if event_date.replace(tzinfo=None) >= since_date:
                series_id = record.get('seriesId')
                if series_id and series_id not in seen_series:
                    seen_series.add(series_id)
                    # Get series details
                    series_url = f"{base_url}/api/v3/series/{series_id}"
                    series_resp = requests.get(series_url, headers=headers, timeout=10)
                    if series_resp.ok:
                        series = series_resp.json()
                        imports.append({
                            'type': 'episode',
                            'title': series.get('title', 'Unknown'),
                            'path': series.get('path', ''),
                            'date': record['date']
                        })

        return imports

    except Exception as e:
        log(f"Error querying Sonarr {base_url}: {e}", 'ERROR')
        return []


def translate_path(container_path, instance):
    """Translate container path to source/dest NFS paths"""
    mapping = PATH_MAPPINGS.get(instance)
    if not mapping:
        return None, None

    container_base = mapping['container']
    if container_path.startswith(container_base):
        relative = container_path[len(container_base):].lstrip('/')
        source = os.path.join(mapping['source'], relative)
        dest = mapping['dest']
        return source, dest

    # Try direct path if it's already a full path
    if container_path.startswith('/mnt/'):
        return container_path, mapping['dest']

    return None, None


def run_rsync(source, dest, dry_run=False):
    """Run rsync for a specific path"""
    cmd = [
        'rsync', '-avh',
        '--ignore-existing',
        '--exclude', '#recycle',
        '--exclude', '@eaDir',
        '--exclude', '.DS_Store',
    ]

    if dry_run:
        cmd.append('--dry-run')

    cmd.extend([source, dest + '/'])

    log(f"Running: {' '.join(cmd)}")

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=3600
        )
        return result.returncode == 0, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return False, '', 'Timeout after 1 hour'
    except Exception as e:
        return False, '', str(e)


def main():
    parser = argparse.ArgumentParser(description='Catch up on missed syncs')
    parser.add_argument('--hours', type=int, default=24, help='Hours to look back (default: 24)')
    parser.add_argument('--since', type=str, help='Since date (YYYY-MM-DD)')
    parser.add_argument('--dry-run', action='store_true', help='Preview only, no actual sync')
    parser.add_argument('--instance', type=str, help='Specific instance (radarr-hd, radarr-4k, sonarr-hd, sonarr-4k)')

    args = parser.parse_args()

    # Determine since date
    if args.since:
        since_date = datetime.strptime(args.since, '%Y-%m-%d')
    else:
        since_date = datetime.now() - timedelta(hours=args.hours)

    log(f"Looking for imports since: {since_date}")
    if args.dry_run:
        log("DRY RUN MODE - no files will be synced", 'WARN')

    all_imports = []

    # Query each instance
    instances = [args.instance] if args.instance else ['radarr-hd', 'radarr-4k', 'sonarr-hd', 'sonarr-4k']

    for instance in instances:
        log(f"Querying {instance}...")

        if instance == 'radarr-hd':
            imports = get_radarr_history(CONFIG['RADARR_HD_URL'], CONFIG['RADARR_HD_API_KEY'], since_date)
            for imp in imports:
                imp['instance'] = 'radarr-hd'
            all_imports.extend(imports)

        elif instance == 'radarr-4k':
            imports = get_radarr_history(CONFIG['RADARR_4K_URL'], CONFIG['RADARR_4K_API_KEY'], since_date)
            for imp in imports:
                imp['instance'] = 'radarr-4k'
            all_imports.extend(imports)

        elif instance == 'sonarr-hd':
            imports = get_sonarr_history(CONFIG['SONARR_HD_URL'], CONFIG['SONARR_HD_API_KEY'], since_date)
            for imp in imports:
                imp['instance'] = 'sonarr-hd'
            all_imports.extend(imports)

        elif instance == 'sonarr-4k':
            imports = get_sonarr_history(CONFIG['SONARR_4K_URL'], CONFIG['SONARR_4K_API_KEY'], since_date)
            for imp in imports:
                imp['instance'] = 'sonarr-4k'
            all_imports.extend(imports)

    log(f"Found {len(all_imports)} imports to sync")

    if not all_imports:
        log("No imports found in the specified time range")
        return 0

    # Dedupe by path
    seen_paths = set()
    unique_imports = []
    for imp in all_imports:
        if imp['path'] not in seen_paths:
            seen_paths.add(imp['path'])
            unique_imports.append(imp)

    log(f"After deduplication: {len(unique_imports)} unique paths")

    # Process each import
    success_count = 0
    fail_count = 0

    for i, imp in enumerate(unique_imports, 1):
        title = imp.get('title', 'Unknown')
        path = imp['path']
        instance = imp['instance']

        log(f"[{i}/{len(unique_imports)}] Processing: {title}")

        source, dest = translate_path(path, instance)
        if not source:
            log(f"  No path mapping for: {path}", 'WARN')
            fail_count += 1
            continue

        # Check if source exists
        if not os.path.exists(source):
            log(f"  Source not found: {source}", 'WARN')
            fail_count += 1
            continue

        log(f"  Source: {source}")
        log(f"  Dest: {dest}")

        success, stdout, stderr = run_rsync(source, dest, args.dry_run)

        if success:
            log(f"  OK: {title}", 'SUCCESS')
            success_count += 1
        else:
            log(f"  FAILED: {stderr[:200]}", 'ERROR')
            fail_count += 1

    # Summary
    log("=" * 50)
    log(f"SUMMARY: {success_count} succeeded, {fail_count} failed")
    if args.dry_run:
        log("(DRY RUN - no files were actually synced)")

    return 0 if fail_count == 0 else 1


if __name__ == '__main__':
    sys.exit(main())
