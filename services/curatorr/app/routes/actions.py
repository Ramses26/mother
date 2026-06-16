"""Delete and unmonitor actions — uses Unraid Agent for remote deletion."""
import json
import logging
import os
import urllib.request
import urllib.error

from app.config import (
    RADARR_INSTANCES, SONARR_INSTANCES,
    container_to_unraid_agent_path,
    UNRAID_AGENT_URL, UNRAID_AGENT_API_KEY,
)
from app.notifications import send_notification
from app.database import get_db
from app.log_events import log_event

router_log = logging.getLogger('curatorr.routes.actions')

from fastapi import APIRouter
router = APIRouter()


async def _delete_via_agent(agent_path: str, title: str) -> bool:
    """Call the Unraid Agent /delete endpoint. Returns True on success."""
    if not UNRAID_AGENT_URL or not UNRAID_AGENT_API_KEY:
        router_log.warning(f"Unraid agent not configured — skipping Unraid delete for {title}")
        return False
    try:
        payload = json.dumps({'paths': [agent_path]}).encode()
        url = f"{UNRAID_AGENT_URL.rstrip('/')}/delete"
        req = urllib.request.Request(
            url, data=payload, method='POST',
            headers={'X-Api-Key': UNRAID_AGENT_API_KEY, 'Content-Type': 'application/json'},
        )
        with urllib.request.urlopen(req, timeout=60) as resp:
            result = json.loads(resp.read())
        if result.get('errors'):
            router_log.error(f"Unraid agent delete errors for {title}: {result['errors']}")
        ok = agent_path in result.get('deleted', [])
        if ok:
            router_log.info(f"Unraid agent deleted {agent_path} ({result.get('freed_bytes', 0)} bytes)")
        return ok
    except Exception as e:
        router_log.error(f"Unraid agent delete failed for {title} at {agent_path}: {e}")
        return False


async def _delete_from_sonarr_instances(title: str, primary_instance: str, tvdb_id: int | None) -> dict[str, bool]:
    """Delete a TV show from all Sonarr instances except the primary one, matched by TVDB ID."""
    import httpx
    results = {}
    if not tvdb_id:
        return results
    for inst in SONARR_INSTANCES:
        if inst['name'] == primary_instance:
            continue
        try:
            async with httpx.AsyncClient(timeout=20) as client:
                r = await client.get(
                    f"{inst['url']}/api/v3/series",
                    headers={'X-Api-Key': inst['api_key']},
                )
            if r.status_code != 200:
                router_log.warning(f"Could not fetch series from {inst['name']} (status {r.status_code})")
                continue
            match = next((s for s in r.json() if s.get('tvdbId') == tvdb_id), None)
            if not match:
                router_log.info(f"Show {title} (tvdb={tvdb_id}) not found in {inst['name']} — skipping")
                continue
            async with httpx.AsyncClient(timeout=30) as client:
                del_r = await client.delete(
                    f"{inst['url']}/api/v3/series/{match['id']}",
                    headers={'X-Api-Key': inst['api_key']},
                    params={'deleteFiles': 'true'},
                )
            ok = del_r.status_code in (200, 204, 404)  # 404 = already deleted
            results[inst['name']] = ok
            level = 'info' if ok else 'error'
            getattr(router_log, level)(
                f"Cross-instance TV delete {'OK' if ok else 'FAILED'}: {title} from {inst['name']} (status {del_r.status_code})"
            )
        except Exception as e:
            router_log.error(f"Cross-instance TV delete error for {title} in {inst['name']}: {e}")
            results[inst['name']] = False
    return results


async def _delete_from_radarr_instances(title: str, primary_instance: str, tmdb_id: int | None) -> dict[str, bool]:
    """Delete a movie from all Radarr instances except the primary one, matched by TMDB ID."""
    import httpx
    results = {}
    if not tmdb_id:
        return results
    for inst in RADARR_INSTANCES:
        if inst['name'] == primary_instance:
            continue
        try:
            async with httpx.AsyncClient(timeout=20) as client:
                r = await client.get(
                    f"{inst['url']}/api/v3/movie",
                    headers={'X-Api-Key': inst['api_key']},
                )
            if r.status_code != 200:
                router_log.warning(f"Could not fetch movies from {inst['name']} (status {r.status_code})")
                continue
            match = next((m for m in r.json() if m.get('tmdbId') == tmdb_id), None)
            if not match:
                router_log.info(f"Movie {title} (tmdb={tmdb_id}) not found in {inst['name']} — skipping")
                continue
            async with httpx.AsyncClient(timeout=30) as client:
                del_r = await client.delete(
                    f"{inst['url']}/api/v3/movie/{match['id']}",
                    headers={'X-Api-Key': inst['api_key']},
                    params={'deleteFiles': 'true'},
                )
            ok = del_r.status_code in (200, 204, 404)  # 404 = already deleted
            results[inst['name']] = ok
            level = 'info' if ok else 'error'
            getattr(router_log, level)(
                f"Cross-instance movie delete {'OK' if ok else 'FAILED'}: {title} from {inst['name']} (status {del_r.status_code})"
            )
        except Exception as e:
            router_log.error(f"Cross-instance movie delete error for {title} in {inst['name']}: {e}")
            results[inst['name']] = False
    return results


async def delete_from_arr_and_disk(item: dict, media_type: str) -> dict:
    """
    Delete media from *arr (all instances) and Unraid via the Unraid Agent.
    Returns dict with arr_delete_ok, unraid_delete_ok, cross_instance_results, and freed_bytes.
    """
    import httpx

    title = item.get('title', 'Unknown')
    year = item.get('year')
    tmdb_id = item.get('tmdb_id')
    imdb_id = item.get('imdb_id')
    tvdb_id = item.get('tvdb_id')
    file_path = item.get('file_path', '')
    file_size = item.get('file_size_bytes', 0)

    arr_delete_ok = False
    unraid_delete_ok = False
    agent_path = None
    cross_instance_results = {}

    # ── Resolve Unraid Agent path before deleting from *arr ──────────────────
    if media_type == 'movie':
        if file_path:
            folder = os.path.dirname(file_path)
            agent_path = container_to_unraid_agent_path(folder)
            if not agent_path:
                router_log.warning(f"Could not map movie path to agent path: {folder}")

    else:  # tv
        sonarr_id = item.get('sonarr_id')
        instance_name = item.get('sonarr_instance')
        inst = next((i for i in SONARR_INSTANCES if i['name'] == instance_name), None)
        if inst and sonarr_id:
            try:
                async with httpx.AsyncClient(timeout=15) as client:
                    r = await client.get(
                        f"{inst['url']}/api/v3/series/{sonarr_id}",
                        headers={'X-Api-Key': inst['api_key']},
                    )
                    if r.status_code == 200:
                        series_path = r.json().get('path', '')
                        agent_path = container_to_unraid_agent_path(series_path)
                        if not agent_path:
                            router_log.warning(
                                f"Could not map TV path to agent path: {series_path}"
                            )
            except Exception as e:
                router_log.error(f"Failed to fetch Sonarr path for {title}: {e}")

    # ── Delete from primary *arr instance (also deletes files from Synology) ──
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
                    arr_delete_ok = r.status_code in (200, 204, 404)  # 404 = already deleted, treat as success
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
                    arr_delete_ok = r.status_code in (200, 204, 404)  # 404 = already deleted, treat as success
            except Exception as e:
                router_log.error(f"Sonarr delete error for {title}: {e}")

    # ── Delete from remaining *arr instances (cross-instance) ─────────────────
    if media_type == 'movie':
        cross_instance_results = await _delete_from_radarr_instances(title, instance_name, tmdb_id)
    else:
        cross_instance_results = await _delete_from_sonarr_instances(title, instance_name, tvdb_id)

    # ── Delete from Unraid via the Agent API ──────────────────────────────────
    if agent_path:
        unraid_delete_ok = await _delete_via_agent(agent_path, title)
    else:
        router_log.warning(f"No Unraid agent path resolved for {title} — skipping Unraid delete")

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
            media_type, title, year, tmdb_id, imdb_id, agent_path or file_path,
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
                                'cross_instances': cross_instance_results,
                                'agent_path': agent_path,
                                'size_gb': round((file_size or 0) / 1_073_741_824, 2)},
                        level=evt_level)
        await db.commit()

    # ── Telegram notification ─────────────────────────────────────────────────
    size_gb = (file_size or 0) / 1_073_741_824
    status_parts = []
    status_parts.append(f"{instance_name}: {'OK' if arr_delete_ok else 'FAILED'}")
    for inst_name, ok in cross_instance_results.items():
        status_parts.append(f"{inst_name}: {'OK' if ok else 'FAILED'}")
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
        'cross_instance_results': cross_instance_results,
        'freed_bytes': file_size if (arr_delete_ok or unraid_delete_ok) else 0,
        'message': f"Deleted {title}",
    }
