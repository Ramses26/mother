"""Delete and unmonitor actions with Unraid NFS path resolution."""
import os
import shutil
import logging
from app.config import RADARR_INSTANCES, SONARR_INSTANCES, synology_to_unraid_path, UNRAID_MEDIA_PATH
from app.notifications import send_notification
from app.database import get_db
from app.log_events import log_event

router_log = logging.getLogger('curatorr.routes.actions')

from fastapi import APIRouter
router = APIRouter()


async def delete_from_arr_and_disk(item: dict, media_type: str) -> dict:
    """
    Delete media from *arr and Unraid disk.
    Returns dict with arr_delete_ok, unraid_delete_ok, and freed_bytes.
    """
    import httpx

    title = item.get('title', 'Unknown')
    year = item.get('year')
    tmdb_id = item.get('tmdb_id')
    imdb_id = item.get('imdb_id')
    file_path = item.get('file_path', '')
    file_size = item.get('file_size_bytes', 0)

    arr_delete_ok = False
    unraid_delete_ok = False

    # ── Delete from *arr ──────────────────────────────────────────────────────
    if media_type == 'movie':
        radarr_id = item.get('radarr_id')
        instance_name = item.get('radarr_instance')
        inst = next((i for i in RADARR_INSTANCES if i['name'] == instance_name), None)
        if inst and radarr_id:
            try:
                async with httpx.AsyncClient(timeout=30) as client:
                    r = await client.delete(
                        f"{inst['url']}/api/v3/movie/{radarr_id}",
                        headers={'X-Api-Key': inst['api_key']},
                        params={'deleteFiles': 'true'},
                    )
                    arr_delete_ok = r.status_code in (200, 204)
            except Exception as e:
                router_log.error(f"Radarr delete error for {title}: {e}")
    else:
        sonarr_id = item.get('sonarr_id')
        instance_name = item.get('sonarr_instance')
        inst = next((i for i in SONARR_INSTANCES if i['name'] == instance_name), None)
        if inst and sonarr_id:
            try:
                async with httpx.AsyncClient(timeout=30) as client:
                    r = await client.delete(
                        f"{inst['url']}/api/v3/series/{sonarr_id}",
                        headers={'X-Api-Key': inst['api_key']},
                        params={'deleteFiles': 'true'},
                    )
                    arr_delete_ok = r.status_code in (200, 204)
            except Exception as e:
                router_log.error(f"Sonarr delete error for {title}: {e}")

    # ── Delete from Unraid NFS (only if arr delete succeeded) ────────────────
    if arr_delete_ok and file_path:
        unraid_path = synology_to_unraid_path(file_path)
        if unraid_path and unraid_path.startswith(UNRAID_MEDIA_PATH):
            try:
                if os.path.isfile(unraid_path):
                    os.remove(unraid_path)
                    unraid_delete_ok = True
                elif os.path.isdir(unraid_path):
                    shutil.rmtree(unraid_path)
                    unraid_delete_ok = True
                else:
                    # Try parent dir (for movie folder)
                    parent = os.path.dirname(unraid_path)
                    if os.path.isdir(parent) and parent.startswith(UNRAID_MEDIA_PATH):
                        shutil.rmtree(parent)
                        unraid_delete_ok = True
            except Exception as e:
                router_log.error(f"Unraid delete error for {title} at {unraid_path}: {e}")

    # ── Log to deletion_log + event_log ──────────────────────────────────────
    async for db in get_db():
        await db.execute("""
            INSERT INTO deletion_log (
                media_type, title, year, tmdb_id, imdb_id, file_path,
                file_size_bytes, composite_score, imdb_rating, purge_score,
                ali_play_count, chris_play_count, deleted_via,
                arr_delete_ok, unraid_delete_ok
            ) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
        """, (
            media_type, title, year, tmdb_id, imdb_id, file_path,
            file_size, item.get('composite_score'), item.get('imdb_rating'),
            item.get('purge_score'),
            item.get('ali_play_count', 0), item.get('chris_play_count', 0),
            'manual',
            1 if arr_delete_ok else 0,
            1 if unraid_delete_ok else 0,
        ))
        instance = item.get('radarr_instance') or item.get('sonarr_instance') or media_type
        evt_level = 'info' if arr_delete_ok else 'warning'
        await log_event(db, 'deletion', instance,
                        f"Deleted: {title} ({year or '?'})",
                        detail={'arr_ok': arr_delete_ok, 'unraid_ok': unraid_delete_ok,
                                'size_gb': round((file_size or 0) / 1_073_741_824, 2)},
                        level=evt_level)
        await db.commit()

    # ── Telegram notification ─────────────────────────────────────────────────
    size_gb = (file_size or 0) / 1_073_741_824
    status_parts = []
    if arr_delete_ok:
        status_parts.append("*arr OK")
    else:
        status_parts.append("*arr FAILED")
    if unraid_delete_ok:
        status_parts.append("Unraid OK")
    else:
        status_parts.append("Unraid skipped/failed")

    msg = (
        f"Curatorr deleted: {title} ({year or '?'})\n"
        f"Size freed: {size_gb:.1f} GB\n"
        f"Status: {', '.join(status_parts)}"
    )
    send_notification(msg)

    return {
        'ok': arr_delete_ok,
        'arr_delete_ok': arr_delete_ok,
        'unraid_delete_ok': unraid_delete_ok,
        'freed_bytes': file_size if (arr_delete_ok or unraid_delete_ok) else 0,
        'message': f"Deleted {title}",
    }
