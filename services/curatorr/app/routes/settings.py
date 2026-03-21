"""Settings API."""
import logging
from fastapi import APIRouter, Depends, HTTPException
from app.auth import require_auth, verify_login, hash_password
from app.database import get_db, set_config, get_config
from app.models import ChangePasswordRequest

router = APIRouter()
log = logging.getLogger('curatorr.routes.settings')


@router.get('/settings')
async def get_settings(_auth=Depends(require_auth)):
    """Return safe (non-secret) settings."""
    from app.config import (
        TMDB_API_KEY, OMDB_API_KEY, MDBLIST_API_KEY,
        CURATORR_TELEGRAM_CHAT, CHRIS_PLEX_URL, ALI_PLEX_URL,
        CHRIS_TAUTULLI_URL, ALI_TAUTULLI_URL
    )

    def mask(v):
        if not v:
            return ''
        return v[:4] + '****' + v[-4:] if len(v) > 8 else '****'

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
    }


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
