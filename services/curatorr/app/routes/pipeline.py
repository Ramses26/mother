"""Pipeline — unified view of Upgraderr + Radarr/Sonarr download queues."""
import asyncio
import logging
from fastapi import APIRouter, Depends

import httpx

from app.auth import require_auth
from app.config import (
    RADARR_INSTANCES, SONARR_INSTANCES,
    UPGRADERR_INTERNAL_URL, UPGRADERR_SERVICE_KEY,
)

router = APIRouter()
log = logging.getLogger('curatorr.routes.pipeline')

_SVC_HEADERS = {'X-Service-Key': UPGRADERR_SERVICE_KEY} if UPGRADERR_SERVICE_KEY else {}

TIER_LABELS = {
    '1': 'm2ts/BDMV → encode',
    '2': 'Non-MKV container',
    '3': '720p/SD → 1080p',
    '4': 'BluRay source available',
    '5': 'No surround audio',
    '6': 'Low TRaSH score',
    '7': 'Profile mismatch',
}


async def _fetch_arr_queue(client: httpx.AsyncClient, instance: dict, media_type: str) -> list:
    url  = instance['url']
    key  = instance['api_key']
    name = instance['label']
    try:
        r = await client.get(
            f"{url}/api/v3/queue",
            params={'page': 1, 'pageSize': 50, 'apikey': key},
            timeout=8,
        )
        records = r.json().get('records', [])
        out = []
        for rec in records:
            size     = rec.get('size', 0) or 0
            sizeleft = rec.get('sizeleft', size) or size
            progress = round((1 - sizeleft / size) * 100) if size > 0 else 0
            quality  = (rec.get('quality') or {}).get('quality', {}).get('name', 'Unknown')
            out.append({
                'instance':   name,
                'media_type': media_type,
                'title':      rec.get('title', ''),
                'status':     rec.get('status', ''),
                'tracked_state': rec.get('trackedDownloadState', ''),
                'quality':    quality,
                'size_bytes': size,
                'size_left':  sizeleft,
                'progress':   progress,
                'time_left':  rec.get('timeleft'),
                'protocol':   rec.get('protocol', ''),
            })
        return out
    except Exception as e:
        log.warning(f"Failed to fetch queue from {name}: {e}")
        return []


@router.get('/pipeline')
async def get_pipeline(_auth=Depends(require_auth)):
    """Upgraderr stats + all *arr download queues in one call."""
    async with httpx.AsyncClient(timeout=10) as client:
        # Upgraderr stats (no auth needed from Docker bridge 172.x)
        upgraderr_task = client.get(f"{UPGRADERR_INTERNAL_URL}/api/stats")

        # All *arr queues in parallel
        arr_tasks = []
        for inst in RADARR_INSTANCES:
            arr_tasks.append(_fetch_arr_queue(client, inst, 'movie'))
        for inst in SONARR_INSTANCES:
            arr_tasks.append(_fetch_arr_queue(client, inst, 'tv'))

        results = await asyncio.gather(upgraderr_task, *arr_tasks, return_exceptions=True)

    upgraderr_result = results[0]
    arr_results = results[1:]

    # Parse Upgraderr
    upgraderr = {}
    try:
        upgraderr = upgraderr_result.json()
        # Enrich tier_counts with labels
        upgraderr['tier_labels'] = {
            k: {'count': v, 'label': TIER_LABELS.get(str(k), f'Tier {k}')}
            for k, v in (upgraderr.get('tier_counts') or {}).items()
        }
    except Exception as e:
        log.warning(f"Upgraderr stats parse error: {e}")
        upgraderr = {'error': str(e)}

    # Aggregate download queues
    downloads = []
    for res in arr_results:
        if isinstance(res, list):
            downloads.extend(res)

    # Sort: downloading first, then by size descending
    status_order = {'downloading': 0, 'warning': 1, 'queued': 2, 'completed': 3}
    downloads.sort(key=lambda x: (status_order.get(x['status'], 9), -(x['size_bytes'] or 0)))

    by_instance: dict = {}
    for d in downloads:
        by_instance.setdefault(d['instance'], 0)
        by_instance[d['instance']] += 1

    return {
        'upgraderr': upgraderr,
        'downloads': downloads,
        'downloads_total': len(downloads),
        'by_instance': by_instance,
    }


@router.post('/pipeline/sweep')
async def trigger_sweep(_auth=Depends(require_auth)):
    """Trigger an Upgraderr quality sweep immediately."""
    try:
        async with httpx.AsyncClient(timeout=10) as client:
            r = await client.post(f"{UPGRADERR_INTERNAL_URL}/api/sweep", headers=_SVC_HEADERS)
        return r.json()
    except Exception as e:
        log.error(f"Sweep trigger failed: {e}")
        return {'error': str(e)}


@router.post('/pipeline/pause')
async def pause_upgraderr(_auth=Depends(require_auth)):
    try:
        async with httpx.AsyncClient(timeout=10) as client:
            r = await client.post(f"{UPGRADERR_INTERNAL_URL}/api/pause", headers=_SVC_HEADERS)
        return r.json()
    except Exception as e:
        return {'error': str(e)}


@router.post('/pipeline/resume')
async def resume_upgraderr(_auth=Depends(require_auth)):
    try:
        async with httpx.AsyncClient(timeout=10) as client:
            r = await client.post(f"{UPGRADERR_INTERNAL_URL}/api/resume", headers=_SVC_HEADERS)
        return r.json()
    except Exception as e:
        return {'error': str(e)}
