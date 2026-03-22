"""Sync status and trigger endpoints."""
import logging
from fastapi import APIRouter, Depends, HTTPException
from app.auth import require_auth
from app.database import get_db
from app.models import SyncTriggerRequest

router = APIRouter()
log = logging.getLogger('curatorr.routes.sync')


@router.get('/sync/status')
async def sync_status(_auth=Depends(require_auth)):
    """Get sync status for all sources."""
    async for db in get_db():
        async with db.execute("SELECT * FROM sync_log") as cur:
            rows = await cur.fetchall()
            return [dict(r) for r in rows]


@router.post('/sync/trigger')
async def sync_trigger(body: SyncTriggerRequest, _auth=Depends(require_auth)):
    """Trigger a sync for specified source."""
    import asyncio
    source = body.source

    try:
        from app.scheduler import trigger_sync_by_source, is_sync_running
        if is_sync_running(source):
            return {'ok': False, 'message': f'Sync already running: {source}'}
        asyncio.create_task(trigger_sync_by_source(source))
        return {'ok': True, 'message': f'Sync triggered for: {source}'}
    except Exception as e:
        log.error(f"Sync trigger error: {e}")
        raise HTTPException(status_code=500, detail=str(e))
