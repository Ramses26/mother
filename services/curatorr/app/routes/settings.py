"""Settings API."""
import logging
import os
import shutil
from datetime import datetime
from pathlib import Path
from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import FileResponse
from app.auth import require_auth, verify_login, hash_password
from app.database import get_db, set_config, get_config
from app.models import ChangePasswordRequest

router = APIRouter()
log = logging.getLogger('curatorr.routes.settings')


@router.get('/settings')
async def get_settings(_auth=Depends(require_auth)):
    """Return safe (non-secret) settings including public URLs."""
    from app.config import (
        TMDB_API_KEY, OMDB_API_KEY, MDBLIST_API_KEY,
        CURATORR_TELEGRAM_CHAT, CHRIS_PLEX_URL, ALI_PLEX_URL,
        CHRIS_TAUTULLI_URL, ALI_TAUTULLI_URL,
        RADARR_HD_PUBLIC_URL, RADARR_4K_PUBLIC_URL,
        SONARR_HD_PUBLIC_URL, SONARR_4K_PUBLIC_URL, OVERSEERR_URL,
    )

    def mask(v):
        if not v:
            return ''
        return v[:4] + '****' + v[-4:] if len(v) > 8 else '****'

    # Config-table overrides take priority over env vars
    radarr_hd_url  = await get_config('public_url_radarr_hd',  RADARR_HD_PUBLIC_URL)
    radarr_4k_url  = await get_config('public_url_radarr_4k',  RADARR_4K_PUBLIC_URL)
    sonarr_hd_url  = await get_config('public_url_sonarr_hd',  SONARR_HD_PUBLIC_URL)
    sonarr_4k_url  = await get_config('public_url_sonarr_4k',  SONARR_4K_PUBLIC_URL)
    overseerr_url  = await get_config('public_url_overseerr',   OVERSEERR_URL)

    return {
        'api_keys': {
            'tmdb': mask(TMDB_API_KEY),
            'omdb': mask(OMDB_API_KEY),
            'mdblist': mask(MDBLIST_API_KEY),
        },
        'telegram_chat_id': CURATORR_TELEGRAM_CHAT,
        'plex': {
            'chris_url': CHRIS_PLEX_URL,
            'ali_url': ALI_PLEX_URL,
        },
        'tautulli': {
            'chris_url': CHRIS_TAUTULLI_URL,
            'ali_url': ALI_TAUTULLI_URL,
        },
        'public_urls': {
            'radarr_hd': radarr_hd_url or '',
            'radarr_4k': radarr_4k_url or '',
            'sonarr_hd': sonarr_hd_url or '',
            'sonarr_4k': sonarr_4k_url or '',
            'overseerr': overseerr_url or '',
        },
    }


@router.patch('/settings/connections')
async def update_connections(body: dict, _auth=Depends(require_auth)):
    """Save public URL overrides to config table."""
    mapping = {
        'radarr_hd': 'public_url_radarr_hd',
        'radarr_4k': 'public_url_radarr_4k',
        'sonarr_hd': 'public_url_sonarr_hd',
        'sonarr_4k': 'public_url_sonarr_4k',
        'overseerr': 'public_url_overseerr',
    }
    for field, config_key in mapping.items():
        if field in body:
            await set_config(config_key, body[field])
    return {'ok': True, 'message': 'Public URLs updated'}


@router.post('/settings/change-password')
async def change_password(body: ChangePasswordRequest, _auth=Depends(require_auth)):
    if not await verify_login(body.current_password):
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
