"""Overseerr sync — pull all requests and store locally for fast lookup."""
import logging
import httpx
from app.config import OVERSEERR_URL, OVERSEERR_API_KEY
from app.log_events import log_event

log = logging.getLogger('curatorr.sync.overseerr')

# Overseerr request status codes
STATUS_LABELS = {
    1: 'Pending',
    2: 'Approved',
    3: 'Declined',
    4: 'Available',
    5: 'Processing',
}


async def sync_overseerr_requests(db) -> int:
    """Fetch all requests from Overseerr and upsert into overseerr_requests table."""
    url = (OVERSEERR_URL or 'http://overseerr:5055').rstrip('/')
    key = OVERSEERR_API_KEY or ''

    if not key:
        log.warning("OVERSEERR_API_KEY not set — skipping Overseerr sync")
        await db.execute(
            "INSERT OR REPLACE INTO sync_log (source, status, error_msg, last_sync) VALUES (?,?,?,CURRENT_TIMESTAMP)",
            ('overseerr', 'not_configured', 'No API key')
        )
        await db.commit()
        return 0

    await db.execute(
        "INSERT OR REPLACE INTO sync_log (source, status, last_sync) VALUES (?,?,CURRENT_TIMESTAMP)",
        ('overseerr', 'syncing')
    )
    await db.commit()

    page = 0
    page_size = 100
    total_synced = 0

    try:
        async with httpx.AsyncClient(timeout=30) as client:
            while True:
                r = await client.get(
                    f"{url}/api/v1/request",
                    headers={'X-Api-Key': key},
                    params={'take': page_size, 'skip': page * page_size, 'sort': 'added'},
                )
                r.raise_for_status()
                data = r.json()
                results = data.get('results', [])
                if not results:
                    break

                for req in results:
                    media = req.get('media') or {}
                    requested_by = req.get('requestedBy') or {}
                    seasons = req.get('seasons') or []
                    season_nums = sorted([s.get('seasonNumber', 0) for s in seasons if s.get('seasonNumber') is not None])

                    await db.execute("""
                        INSERT INTO overseerr_requests
                            (overseerr_id, media_type, tmdb_id, tvdb_id, status, is_4k,
                             requested_by, requested_at, season_numbers, last_synced)
                        VALUES (?,?,?,?,?,?,?,?,?,CURRENT_TIMESTAMP)
                        ON CONFLICT(overseerr_id) DO UPDATE SET
                            status=excluded.status,
                            requested_by=excluded.requested_by,
                            season_numbers=excluded.season_numbers,
                            last_synced=CURRENT_TIMESTAMP
                    """, (
                        req.get('id'),
                        req.get('type'),
                        media.get('tmdbId'),
                        media.get('tvdbId'),
                        req.get('status', 1),
                        1 if req.get('is4k') else 0,
                        requested_by.get('displayName') or requested_by.get('username') or 'Unknown',
                        req.get('createdAt', '')[:19].replace('T', ' '),
                        ','.join(str(s) for s in season_nums) if season_nums else '',
                    ))
                    total_synced += 1

                await db.commit()

                page_info = data.get('pageInfo', {})
                total = page_info.get('results', 0)
                if (page + 1) * page_size >= total:
                    break
                page += 1

        await db.execute(
            "INSERT OR REPLACE INTO sync_log (source, status, item_count, error_msg, last_sync) VALUES (?,?,?,NULL,CURRENT_TIMESTAMP)",
            ('overseerr', 'ok', total_synced)
        )
        await db.commit()
        await log_event(db, 'sync', 'overseerr', f"Synced {total_synced} requests")
        await db.commit()
        log.info(f"[overseerr] Synced {total_synced} requests")
        return total_synced

    except Exception as e:
        log.error(f"[overseerr] Sync failed: {e}")
        await db.execute(
            "INSERT OR REPLACE INTO sync_log (source, status, error_msg, last_sync) VALUES (?,?,?,CURRENT_TIMESTAMP)",
            ('overseerr', 'error', str(e)[:500])
        )
        await db.commit()
        return 0
