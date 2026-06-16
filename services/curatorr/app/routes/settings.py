"""Settings API."""
import logging
import os
import shutil
import sqlite3
from datetime import datetime
from pathlib import Path
from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import FileResponse
from app.auth import require_auth, verify_login, hash_password
from app.database import get_db, set_config, get_config
from app.models import ChangePasswordRequest

router = APIRouter()
log = logging.getLogger('curatorr.routes.settings')

_plex_machine_cache: dict[str, str] = {}


async def _get_plex_machine_id(plex_url: str, token: str) -> str:
    """Fetch Plex server machine identifier (cached per URL)."""
    if not plex_url or not token:
        return ''
    key = plex_url
    if key in _plex_machine_cache:
        return _plex_machine_cache[key]
    try:
        import httpx
        async with httpx.AsyncClient(timeout=5) as client:
            r = await client.get(
                f"{plex_url.rstrip('/')}/",
                headers={'X-Plex-Token': token, 'Accept': 'application/json'},
            )
        data = r.json()
        machine_id = (data.get('MediaContainer') or {}).get('machineIdentifier', '')
        if machine_id:
            _plex_machine_cache[key] = machine_id
        return machine_id
    except Exception:
        return ''


def _mask(v):
    if not v:
        return ''
    return v[:4] + '****' + v[-4:] if len(v) > 8 else '****'


@router.get('/settings')
async def get_settings(_auth=Depends(require_auth)):
    """Return safe (non-secret) settings including public URLs."""
    from app.config import (
        TMDB_API_KEY, OMDB_API_KEY, MDBLIST_API_KEY,
        CURATORR_TELEGRAM_CHAT, CHRIS_PLEX_URL, ALI_PLEX_URL,
        CHRIS_PLEX_TOKEN, ALI_PLEX_TOKEN,
        CHRIS_TAUTULLI_URL, ALI_TAUTULLI_URL,
        CHRIS_TAUTULLI_KEY, ALI_TAUTULLI_KEY,
        RADARR_HD_PUBLIC_URL, RADARR_4K_PUBLIC_URL,
        SONARR_HD_PUBLIC_URL, SONARR_4K_PUBLIC_URL, OVERSEERR_URL, OVERSEERR_API_KEY,
    )

    # Config-table overrides take priority over env vars
    radarr_hd_url   = await get_config('public_url_radarr_hd',  RADARR_HD_PUBLIC_URL)
    radarr_4k_url   = await get_config('public_url_radarr_4k',  RADARR_4K_PUBLIC_URL)
    sonarr_hd_url   = await get_config('public_url_sonarr_hd',  SONARR_HD_PUBLIC_URL)
    sonarr_4k_url   = await get_config('public_url_sonarr_4k',  SONARR_4K_PUBLIC_URL)
    overseerr_url   = await get_config('public_url_overseerr',   OVERSEERR_URL)

    # Connection overrides
    plex_chris_url   = await get_config('plex_chris_url',   CHRIS_PLEX_URL)
    plex_ali_url     = await get_config('plex_ali_url',     ALI_PLEX_URL)
    plex_chris_token = await get_config('plex_chris_token', CHRIS_PLEX_TOKEN)
    plex_ali_token   = await get_config('plex_ali_token',   ALI_PLEX_TOKEN)

    tautulli_chris_url = await get_config('tautulli_chris_url', CHRIS_TAUTULLI_URL)
    tautulli_ali_url   = await get_config('tautulli_ali_url',   ALI_TAUTULLI_URL)
    tautulli_chris_key = await get_config('tautulli_chris_key', CHRIS_TAUTULLI_KEY)
    tautulli_ali_key   = await get_config('tautulli_ali_key',   ALI_TAUTULLI_KEY)

    tmdb_key   = await get_config('tmdb_api_key',    TMDB_API_KEY)
    omdb_key   = await get_config('omdb_api_key',    OMDB_API_KEY)
    mdblist_key = await get_config('mdblist_api_key', MDBLIST_API_KEY)
    overseerr_api_key = await get_config('overseerr_api_key', OVERSEERR_API_KEY)

    return {
        'api_keys': {
            'tmdb':    _mask(tmdb_key),
            'omdb':    _mask(omdb_key),
            'mdblist': _mask(mdblist_key),
        },
        'telegram_chat_id': CURATORR_TELEGRAM_CHAT,
        'plex': {
            'chris_url':   plex_chris_url or '',
            'ali_url':     plex_ali_url or '',
            'chris_token': _mask(plex_chris_token),
            'ali_token':   _mask(plex_ali_token),
        },
        'tautulli': {
            'chris_url': tautulli_chris_url or '',
            'ali_url':   tautulli_ali_url or '',
            'chris_key': _mask(tautulli_chris_key),
            'ali_key':   _mask(tautulli_ali_key),
        },
        'public_urls': {
            'radarr_hd': radarr_hd_url or '',
            'radarr_4k': radarr_4k_url or '',
            'sonarr_hd': sonarr_hd_url or '',
            'sonarr_4k': sonarr_4k_url or '',
            'overseerr': overseerr_url or '',
            'plex_chris_url': plex_chris_url or '',
            'plex_ali_url': plex_ali_url or '',
            'plex_chris_machine_id': await _get_plex_machine_id(plex_chris_url, plex_chris_token),
            'plex_ali_machine_id': await _get_plex_machine_id(plex_ali_url, plex_ali_token),
        },
        'overseerr_api_key': _mask(overseerr_api_key),
    }


@router.patch('/settings/connections')
async def update_connections(body: dict, _auth=Depends(require_auth)):
    """Save connection settings to config table."""
    # Public URL overrides
    url_mapping = {
        'radarr_hd': 'public_url_radarr_hd',
        'radarr_4k': 'public_url_radarr_4k',
        'sonarr_hd': 'public_url_sonarr_hd',
        'sonarr_4k': 'public_url_sonarr_4k',
        'overseerr': 'public_url_overseerr',
    }
    for field, config_key in url_mapping.items():
        if field in body:
            await set_config(config_key, body[field])

    # Plex / Tautulli connection overrides
    conn_fields = [
        'plex_chris_url', 'plex_ali_url',
        'plex_chris_token', 'plex_ali_token',
        'tautulli_chris_url', 'tautulli_ali_url',
        'tautulli_chris_key', 'tautulli_ali_key',
        'tmdb_api_key', 'omdb_api_key', 'mdblist_api_key',
        'overseerr_api_key',
    ]
    for field in conn_fields:
        if field in body and body[field] is not None:
            await set_config(field, body[field])

    return {'ok': True, 'message': 'Connections updated'}


@router.post('/settings/test-connection')
async def test_connection(body: dict, _auth=Depends(require_auth)):
    """Test connectivity to a configured service."""
    import httpx
    from app.config import (
        CHRIS_PLEX_URL, ALI_PLEX_URL, CHRIS_PLEX_TOKEN, ALI_PLEX_TOKEN,
        CHRIS_TAUTULLI_URL, ALI_TAUTULLI_URL, CHRIS_TAUTULLI_KEY, ALI_TAUTULLI_KEY,
    )

    source = body.get('source', '')

    if source in ('plex-chris', 'plex-ali'):
        if source == 'plex-chris':
            url   = await get_config('plex_chris_url',   CHRIS_PLEX_URL)
            token = await get_config('plex_chris_token', CHRIS_PLEX_TOKEN)
        else:
            url   = await get_config('plex_ali_url',   ALI_PLEX_URL)
            token = await get_config('plex_ali_token', ALI_PLEX_TOKEN)
        if not url or not token:
            return {'ok': False, 'message': 'URL or token not configured'}
        try:
            async with httpx.AsyncClient(timeout=5, follow_redirects=True) as client:
                r = await client.get(f"{url}/identity",
                                     headers={'X-Plex-Token': token, 'Accept': 'application/json'})
            if r.status_code != 200:
                return {'ok': False, 'message': f'HTTP {r.status_code}'}
            content_type = r.headers.get('content-type', '')
            if 'json' not in content_type:
                # Plex sometimes returns XML — parse friendly name from XML
                import xml.etree.ElementTree as ET
                try:
                    root = ET.fromstring(r.text)
                    name = root.get('friendlyName', 'Plex')
                    return {'ok': True, 'message': f'Connected: {name}'}
                except Exception:
                    snippet = r.text[:80].replace('\n', ' ').strip()
                    return {'ok': False, 'message': f'Non-JSON response: {snippet}'}
            name = r.json().get('MediaContainer', {}).get('friendlyName', 'Plex')
            return {'ok': True, 'message': f'Connected: {name}'}
        except Exception as e:
            return {'ok': False, 'message': str(e)[:120]}

    elif source in ('tautulli-chris', 'tautulli-ali'):
        if source == 'tautulli-chris':
            url = await get_config('tautulli_chris_url', CHRIS_TAUTULLI_URL)
            key = await get_config('tautulli_chris_key', CHRIS_TAUTULLI_KEY)
        else:
            url = await get_config('tautulli_ali_url', ALI_TAUTULLI_URL)
            key = await get_config('tautulli_ali_key', ALI_TAUTULLI_KEY)
        if not url or not key:
            return {'ok': False, 'message': 'URL or API key not configured'}
        try:
            async with httpx.AsyncClient(timeout=5, follow_redirects=True) as client:
                r = await client.get(f"{url}/api/v2",
                                     params={'apikey': key, 'cmd': 'get_server_info'})
            # Guard against non-JSON responses (HTML login redirect, proxy page, etc.)
            content_type = r.headers.get('content-type', '')
            if 'json' not in content_type:
                snippet = r.text[:120].replace('\n', ' ').strip()
                return {'ok': False, 'message': f'HTTP {r.status_code} — non-JSON response: {snippet}'}
            data = r.json()
            if data.get('response', {}).get('result') == 'success':
                name = data['response']['data'].get('pms_name', 'Tautulli')
                return {'ok': True, 'message': f'Connected: {name}'}
            return {'ok': False, 'message': data.get('response', {}).get('message', f'HTTP {r.status_code}')}
        except Exception as e:
            return {'ok': False, 'message': str(e)[:120]}

    else:
        raise HTTPException(status_code=400, detail=f'Unknown source: {source}')


@router.post('/settings/change-password')
async def change_password(body: ChangePasswordRequest, _auth=Depends(require_auth)):
    from app.database import get_config as _get_config
    _username = await _get_config('admin_username') or 'admin'
    if not await verify_login(_username, body.current_password):
        raise HTTPException(status_code=401, detail='Current password incorrect')
    if len(body.new_password) < 8:
        raise HTTPException(status_code=400, detail='Password must be at least 8 characters')
    hashed = hash_password(body.new_password)
    await set_config('admin_password_hash', hashed)
    return {'ok': True, 'message': 'Password updated'}


@router.post('/settings/reset')
async def reset_all_data(_auth=Depends(require_auth)):
    """Delete all synced media data (not config/auth)."""
    async for db in get_db():
        await db.execute("DELETE FROM movies")
        await db.execute("DELETE FROM tv_shows")
        await db.execute("DELETE FROM tv_seasons")
        await db.execute("DELETE FROM watch_history")
        await db.execute("DELETE FROM ratings_cache")
        await db.execute("DELETE FROM collections")
        await db.execute("UPDATE sync_log SET last_sync=NULL, item_count=0")
        await db.commit()
    log.warning("All media data reset via settings API")
    return {'ok': True, 'message': 'All data reset'}


@router.get('/settings/backups')
async def list_backups(_auth=Depends(require_auth)):
    """List available database backup files."""
    from app.config import BACKUP_DIR
    backup_path = Path(BACKUP_DIR)
    if not backup_path.exists():
        return []
    backups = []
    for f in sorted(backup_path.glob('*.db'), reverse=True):
        stat = f.stat()
        backups.append({
            'filename': f.name,
            'size_bytes': stat.st_size,
            'created_at': datetime.fromtimestamp(stat.st_mtime).isoformat(),
        })
    return backups


@router.post('/settings/backups/create')
async def create_backup(_auth=Depends(require_auth)):
    """Create a new database backup."""
    from app.config import DB_PATH, BACKUP_DIR
    backup_path = Path(BACKUP_DIR)
    backup_path.mkdir(parents=True, exist_ok=True)
    ts = datetime.now().strftime('%Y%m%d_%H%M%S')
    dest = backup_path / f'curatorr_{ts}.db'
    try:
        shutil.copy2(DB_PATH, str(dest))
        # Keep only last 14 backups
        all_backups = sorted(backup_path.glob('*.db'), reverse=True)
        for old in all_backups[14:]:
            old.unlink()
        return {'ok': True, 'filename': dest.name, 'size_bytes': dest.stat().st_size}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f'Backup failed: {e}')


@router.get('/settings/backups/integrity')
async def check_integrity(_auth=Depends(require_auth)):
    """Run SQLite integrity_check on the live database."""
    from app.config import DB_PATH
    try:
        # Use synchronous sqlite3 — integrity_check doesn't need WAL
        conn = sqlite3.connect(DB_PATH, timeout=10)
        rows = conn.execute('PRAGMA integrity_check').fetchall()
        conn.close()
        result = rows[0][0] if rows else 'unknown'
        ok = result == 'ok'
        return {'ok': ok, 'result': result}
    except Exception as e:
        return {'ok': False, 'result': str(e)}


@router.post('/settings/backups/{filename}/restore')
async def restore_backup(filename: str, _auth=Depends(require_auth)):
    """Restore a backup over the live database."""
    from app.config import DB_PATH, BACKUP_DIR
    from app.log_events import log_event
    # Safety: only allow .db files, no path traversal
    if '/' in filename or '..' in filename or not filename.endswith('.db'):
        raise HTTPException(status_code=400, detail='Invalid filename')
    src = Path(BACKUP_DIR) / filename
    if not src.exists():
        raise HTTPException(status_code=404, detail='Backup not found')
    try:
        shutil.copy2(str(src), DB_PATH)
        log.warning(f"Database restored from backup: {filename}")
        # Log event to the freshly-restored DB
        async for db in get_db():
            await log_event(db, 'system', 'settings', f'Database restored from backup: {filename}')
            await db.commit()
        return {'ok': True, 'message': f'Restore complete — database replaced with {filename}. Refresh the page.'}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f'Restore failed: {e}')


@router.get('/settings/backups/{filename}')
async def download_backup(filename: str, _auth=Depends(require_auth)):
    """Download a backup file."""
    from app.config import BACKUP_DIR
    # Safety: only allow .db files, no path traversal
    if '/' in filename or '..' in filename or not filename.endswith('.db'):
        raise HTTPException(status_code=400, detail='Invalid filename')
    path = Path(BACKUP_DIR) / filename
    if not path.exists():
        raise HTTPException(status_code=404, detail='Backup not found')
    return FileResponse(str(path), filename=filename, media_type='application/octet-stream')
