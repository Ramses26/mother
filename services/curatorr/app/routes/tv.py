"""TV Shows API — filtering, sorting, pagination, detail, delete, unmonitor."""
import logging
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import StreamingResponse
import io, csv

from app.auth import require_auth
from app.database import get_db
from app.models import DeleteRequest
from app.config import SONARR_INSTANCES

router = APIRouter()
log = logging.getLogger('curatorr.routes.tv')

ALLOWED_SORT_COLS = {
    'sort_title', 'title', 'year', 'composite_score', 'imdb_rating',
    'rt_critics', 'metacritic', 'tmdb_rating', 'mdblist_score',
    'purge_score', 'plex_added_at', 'ali_play_count', 'chris_play_count',
    'season_completion_pct', 'status', 'total_episodes', 'total_seasons',
    'network', 'ali_last_watched', 'chris_last_watched', 'size_on_disk',
}


def safe_sort(col: str, direction: str) -> str:
    col = col if col in ALLOWED_SORT_COLS else 'sort_title'
    direction = 'DESC' if direction.upper() == 'DESC' else 'ASC'
    return f"{col} {direction}"


def build_tv_query(params: dict) -> tuple[str, list]:
    conditions = []
    args = []

    if params.get('title'):
        conditions.append("(title LIKE ? OR sort_title LIKE ?)")
        pattern = f"%{params['title']}%"
        args += [pattern, pattern]

    if params.get('year_min'):
        conditions.append("year >= ?")
        args.append(int(params['year_min']))
    if params.get('year_max'):
        conditions.append("year <= ?")
        args.append(int(params['year_max']))

    if params.get('language'):
        lang_list = [l.strip() for l in str(params['language']).split(',')]
        placeholders = ','.join('?' * len(lang_list))
        conditions.append(f"original_language IN ({placeholders})")
        args += lang_list

    if params.get('genre'):
        genre_list = [g.strip() for g in str(params['genre']).split(',') if g.strip()]
        if genre_list:
            clauses = ' OR '.join(['genres LIKE ?' for _ in genre_list])
            conditions.append(f"({clauses})")
            args += [f"%{g}%" for g in genre_list]

    if params.get('content_rating'):
        cr_list = [c.strip() for c in str(params['content_rating']).split(',') if c.strip()]
        if cr_list:
            placeholders = ','.join('?' * len(cr_list))
            conditions.append(f"content_rating IN ({placeholders})")
            args += cr_list

    if params.get('status'):
        conditions.append("(status = ? OR tmdb_status = ?)")
        args += [params['status'], params['status']]

    if params.get('monitored') in ('true', 'false'):
        conditions.append("monitored = ?")
        args.append(1 if params['monitored'] == 'true' else 0)

    if params.get('ali_watched') == 'true':
        conditions.append("ali_play_count > 0")
    elif params.get('ali_watched') == 'false':
        conditions.append("ali_play_count = 0")

    if params.get('chris_watched') == 'true':
        conditions.append("chris_play_count > 0")
    elif params.get('chris_watched') == 'false':
        conditions.append("chris_play_count = 0")

    if params.get('neither_watched') == 'true':
        conditions.append("ali_play_count = 0 AND chris_play_count = 0")

    if params.get('both_watched') == 'true':
        conditions.append("ali_play_count > 0 AND chris_play_count > 0")

    if params.get('cancelled_watched') == 'true':
        conditions.append("(status = 'Cancelled' OR tmdb_status = 'Cancelled') AND (ali_play_count > 0 OR chris_play_count > 0)")

    if params.get('cancelled_never_watched') == 'true':
        conditions.append("(status = 'Cancelled' OR tmdb_status = 'Cancelled') AND ali_play_count = 0 AND chris_play_count = 0")

    if params.get('unwatched_only') == 'true':
        conditions.append("(ali_play_count IS NULL OR ali_play_count = 0) AND (chris_play_count IS NULL OR chris_play_count = 0)")

    # Time-based last-watched filters
    # ali_not_watched_days: shows where ali hasn't watched in N days (includes never watched)
    if params.get('ali_not_watched_days') is not None:
        days = int(params['ali_not_watched_days'])
        conditions.append(f"(ali_last_watched IS NULL OR ali_last_watched < datetime('now', '-{days} days'))")

    # chris_not_watched_days: shows where chris hasn't watched in N days (includes never watched)
    if params.get('chris_not_watched_days') is not None:
        days = int(params['chris_not_watched_days'])
        conditions.append(f"(chris_last_watched IS NULL OR chris_last_watched < datetime('now', '-{days} days'))")

    # either_not_watched_days: neither person has watched in N days
    if params.get('either_not_watched_days') is not None:
        days = int(params['either_not_watched_days'])
        conditions.append(f"""(
            (ali_last_watched IS NULL OR ali_last_watched < datetime('now', '-{days} days'))
            AND (chris_last_watched IS NULL OR chris_last_watched < datetime('now', '-{days} days'))
        )""")

    # ali_abandoned_days: ali watched at some point but stopped (has plays, last_watched is old)
    if params.get('ali_abandoned_days') is not None:
        days = int(params['ali_abandoned_days'])
        conditions.append(f"ali_play_count > 0 AND ali_last_watched IS NOT NULL AND ali_last_watched < datetime('now', '-{days} days')")

    # chris_abandoned_days: chris watched at some point but stopped
    if params.get('chris_abandoned_days') is not None:
        days = int(params['chris_abandoned_days'])
        conditions.append(f"chris_play_count > 0 AND chris_last_watched IS NOT NULL AND chris_last_watched < datetime('now', '-{days} days')")

    # either_abandoned_days: either person was watching but stopped
    if params.get('either_abandoned_days') is not None:
        days = int(params['either_abandoned_days'])
        conditions.append(f"""(
            (ali_play_count > 0 AND ali_last_watched IS NOT NULL AND ali_last_watched < datetime('now', '-{days} days'))
            OR (chris_play_count > 0 AND chris_last_watched IS NOT NULL AND chris_last_watched < datetime('now', '-{days} days'))
        )""")

    for field, col in [
        ('composite_min', 'composite_score'), ('composite_max', 'composite_score'),
        ('imdb_min', 'imdb_rating'), ('imdb_max', 'imdb_rating'),
        ('tmdb_min', 'tmdb_rating'), ('tmdb_max', 'tmdb_rating'),
    ]:
        if params.get(field) is not None:
            op = '>=' if field.endswith('_min') else '<='
            conditions.append(f"{col} {op} ?")
            args.append(float(params[field]))

    for field, col in [
        ('rt_min', 'rt_critics'), ('rt_max', 'rt_critics'),
        ('metacritic_min', 'metacritic'), ('metacritic_max', 'metacritic'),
        ('mdblist_min', 'mdblist_score'), ('mdblist_max', 'mdblist_score'),
        ('purge_score_min', 'purge_score'), ('purge_score_max', 'purge_score'),
    ]:
        if params.get(field) is not None:
            op = '>=' if field.endswith('_min') else '<='
            conditions.append(f"{col} {op} ?")
            args.append(int(params[field]))

    if params.get('instance'):
        conditions.append("sonarr_instance = ?")
        args.append(params['instance'])

    if params.get('seasons_min') is not None:
        conditions.append("total_seasons >= ?")
        args.append(int(params['seasons_min']))
    if params.get('seasons_max') is not None:
        conditions.append("total_seasons <= ?")
        args.append(int(params['seasons_max']))

    where = ("WHERE " + " AND ".join(conditions)) if conditions else ""
    return where, args


@router.get('/tv')
async def list_tv(
    page: int = Query(1, ge=1),
    per_page: int = Query(50, ge=1, le=200),
    sort_by: str = Query('sort_title'),
    sort_dir: str = Query('asc'),
    sort_by2: Optional[str] = None,
    sort_dir2: str = Query('asc'),
    sort_by3: Optional[str] = None,
    sort_dir3: str = Query('asc'),
    title: Optional[str] = None,
    year_min: Optional[int] = None,
    year_max: Optional[int] = None,
    language: Optional[str] = None,
    genre: Optional[str] = None,
    content_rating: Optional[str] = None,
    status: Optional[str] = None,
    monitored: Optional[str] = None,
    ali_watched: Optional[str] = None,
    chris_watched: Optional[str] = None,
    neither_watched: Optional[str] = None,
    both_watched: Optional[str] = None,
    cancelled_watched: Optional[str] = None,
    cancelled_never_watched: Optional[str] = None,
    composite_min: Optional[float] = None,
    composite_max: Optional[float] = None,
    imdb_min: Optional[float] = None,
    imdb_max: Optional[float] = None,
    rt_min: Optional[int] = None,
    rt_max: Optional[int] = None,
    metacritic_min: Optional[int] = None,
    metacritic_max: Optional[int] = None,
    tmdb_min: Optional[float] = None,
    tmdb_max: Optional[float] = None,
    mdblist_min: Optional[int] = None,
    mdblist_max: Optional[int] = None,
    purge_score_min: Optional[int] = None,
    purge_score_max: Optional[int] = None,
    instance: Optional[str] = None,
    preset: Optional[str] = None,
    seasons_min: Optional[int] = None,
    seasons_max: Optional[int] = None,
    unwatched_only: Optional[bool] = None,
    ali_not_watched_days: Optional[int] = None,
    chris_not_watched_days: Optional[int] = None,
    either_not_watched_days: Optional[int] = None,
    ali_abandoned_days: Optional[int] = None,
    chris_abandoned_days: Optional[int] = None,
    either_abandoned_days: Optional[int] = None,
    _auth=Depends(require_auth),
):
    params = {
        'title': title, 'year_min': year_min, 'year_max': year_max,
        'language': language, 'genre': genre, 'content_rating': content_rating, 'status': status,
        'monitored': monitored, 'ali_watched': ali_watched,
        'chris_watched': chris_watched, 'neither_watched': neither_watched,
        'both_watched': both_watched, 'cancelled_watched': cancelled_watched,
        'cancelled_never_watched': cancelled_never_watched,
        'composite_min': composite_min, 'composite_max': composite_max,
        'imdb_min': imdb_min, 'imdb_max': imdb_max,
        'rt_min': rt_min, 'rt_max': rt_max,
        'metacritic_min': metacritic_min, 'metacritic_max': metacritic_max,
        'tmdb_min': tmdb_min, 'tmdb_max': tmdb_max,
        'mdblist_min': mdblist_min, 'mdblist_max': mdblist_max,
        'purge_score_min': purge_score_min, 'purge_score_max': purge_score_max,
        'instance': instance,
        'seasons_min': seasons_min, 'seasons_max': seasons_max,
        'unwatched_only': 'true' if unwatched_only else None,
        'ali_not_watched_days': ali_not_watched_days,
        'chris_not_watched_days': chris_not_watched_days,
        'either_not_watched_days': either_not_watched_days,
        'ali_abandoned_days': ali_abandoned_days,
        'chris_abandoned_days': chris_abandoned_days,
        'either_abandoned_days': either_abandoned_days,
    }

    if preset == 'never_watched':
        params['neither_watched'] = 'true'
    elif preset == 'cancelled_watched':
        params['cancelled_watched'] = 'true'
    elif preset == 'purge_candidates':
        params['purge_score_min'] = 70
    elif preset == 'low_rated_unwatched':
        params['composite_max'] = 5.0
        params['neither_watched'] = 'true'
    elif preset == 'continuing_unwatched':
        params['status'] = 'Continuing'
        params['unwatched_only'] = 'true'

    params = {k: v for k, v in params.items() if v is not None}

    where, args = build_tv_query(params)

    order_parts = [safe_sort(sort_by, sort_dir)]
    if sort_by2:
        order_parts.append(safe_sort(sort_by2, sort_dir2))
    if sort_by3:
        order_parts.append(safe_sort(sort_by3, sort_dir3))
    order_by = "ORDER BY " + ", ".join(order_parts)

    async for db in get_db():
        async with db.execute(
            f"SELECT COUNT(*) FROM (SELECT DISTINCT COALESCE(tmdb_id, id) FROM tv_shows {where})", args
        ) as cur:
            total = (await cur.fetchone())[0]

        offset = (page - 1) * per_page
        # Use a CTE that picks one representative row per TMDB ID (prefer sonarr-hd,
        # fall back to lowest id). Scores and watch counts are merged across instances.
        # Shows with no tmdb_id (NULL) are kept as-is (no dedup).
        query = f"""
            WITH ranked AS (
                SELECT *,
                    ROW_NUMBER() OVER (
                        PARTITION BY COALESCE(CAST(tmdb_id AS TEXT), 'null_' || CAST(id AS TEXT))
                        ORDER BY CASE sonarr_instance WHEN 'sonarr-hd' THEN 0 ELSE 1 END, id
                    ) AS rn,
                    MAX(ali_play_count) OVER (
                        PARTITION BY COALESCE(CAST(tmdb_id AS TEXT), 'null_' || CAST(id AS TEXT))
                    ) AS merged_ali_plays,
                    MAX(chris_play_count) OVER (
                        PARTITION BY COALESCE(CAST(tmdb_id AS TEXT), 'null_' || CAST(id AS TEXT))
                    ) AS merged_chris_plays,
                    MAX(ali_last_watched) OVER (
                        PARTITION BY COALESCE(CAST(tmdb_id AS TEXT), 'null_' || CAST(id AS TEXT))
                    ) AS merged_ali_last,
                    MAX(chris_last_watched) OVER (
                        PARTITION BY COALESCE(CAST(tmdb_id AS TEXT), 'null_' || CAST(id AS TEXT))
                    ) AS merged_chris_last,
                    MAX(size_on_disk) OVER (
                        PARTITION BY COALESCE(CAST(tmdb_id AS TEXT), 'null_' || CAST(id AS TEXT))
                    ) AS merged_size
                FROM tv_shows {where}
            )
            SELECT id, title, sort_title, year, tmdb_id, imdb_id, tvdb_id,
                   status, tmdb_status, network, total_seasons, total_episodes,
                   original_language, content_rating, runtime_min,
                   monitored, sonarr_id, sonarr_instance,
                   imdb_rating, rt_critics, metacritic, tmdb_rating,
                   mdblist_score, trakt_rating, composite_score, purge_score,
                   season_completion_pct, merged_size AS size_on_disk,
                   merged_ali_plays AS ali_play_count, merged_ali_last AS ali_last_watched,
                   merged_chris_plays AS chris_play_count, merged_chris_last AS chris_last_watched,
                   plex_added_at, genres,
                   poster_url, plex_key, ali_plex_key, chris_plex_key
            FROM ranked WHERE rn = 1
            {order_by}
            LIMIT ? OFFSET ?
        """
        async with db.execute(query, args + [per_page, offset]) as cur:
            items = [dict(r) for r in await cur.fetchall()]

        return {
            'items': items,
            'total': total,
            'page': page,
            'per_page': per_page,
            'pages': max(1, (total + per_page - 1) // per_page),
        }


@router.get('/tv/languages')
async def tv_languages(_auth=Depends(require_auth)):
    """Return distinct original_language codes present in TV shows."""
    async for db in get_db():
        async with db.execute(
            "SELECT DISTINCT original_language FROM tv_shows "
            "WHERE original_language IS NOT NULL AND original_language != '' ORDER BY original_language"
        ) as cur:
            rows = await cur.fetchall()
    return [r[0] for r in rows]


@router.get('/tv/genres')
async def tv_genres(_auth=Depends(require_auth)):
    """Return distinct genre values across all TV shows."""
    async for db in get_db():
        async with db.execute(
            "SELECT DISTINCT value FROM tv_shows, json_each(tv_shows.genres) "
            "WHERE tv_shows.genres IS NOT NULL AND tv_shows.genres != '[]' AND tv_shows.genres != 'null' "
            "ORDER BY value"
        ) as cur:
            rows = await cur.fetchall()
    return [r[0] for r in rows]


@router.get('/tv/content-ratings')
async def tv_content_ratings(_auth=Depends(require_auth)):
    """Return distinct content_rating values present in TV shows."""
    async for db in get_db():
        async with db.execute(
            "SELECT DISTINCT content_rating FROM tv_shows "
            "WHERE content_rating IS NOT NULL AND content_rating != '' ORDER BY content_rating"
        ) as cur:
            rows = await cur.fetchall()
    return [r[0] for r in rows]


@router.get('/tv/export')
async def export_tv(ids: Optional[str] = None, _auth=Depends(require_auth)):
    """Export TV shows as CSV. If ids= provided, export only those."""
    fields = [
        'id', 'title', 'year', 'original_language', 'content_rating', 'genres',
        'status', 'network', 'total_seasons', 'total_episodes',
        'composite_score', 'imdb_rating', 'rt_critics', 'metacritic', 'mdblist_score', 'trakt_rating',
        'ali_play_count', 'chris_play_count', 'purge_score', 'monitored', 'sonarr_instance',
        'size_on_disk',
    ]
    async for db in get_db():
        if ids:
            id_list = [int(i) for i in ids.split(',') if i.strip().isdigit()]
            placeholders = ','.join('?' * len(id_list))
            async with db.execute(
                f"SELECT {', '.join(fields)} FROM tv_shows WHERE id IN ({placeholders}) ORDER BY sort_title",
                id_list
            ) as cur:
                rows = await cur.fetchall()
        else:
            async with db.execute(
                f"SELECT {', '.join(fields)} FROM tv_shows ORDER BY sort_title"
            ) as cur:
                rows = await cur.fetchall()

    output = io.StringIO()
    writer = csv.DictWriter(output, fieldnames=fields)
    writer.writeheader()
    for row in rows:
        writer.writerow(dict(row))

    return StreamingResponse(
        iter([output.getvalue()]),
        media_type='text/csv',
        headers={'Content-Disposition': 'attachment; filename=curatorr_tv.csv'},
    )


@router.post('/tv/bulk-unmonitor')
async def bulk_unmonitor_tv(body: dict, _auth=Depends(require_auth)):
    """Unmonitor multiple TV shows in Sonarr and update DB."""
    import httpx
    ids = [int(i) for i in body.get('ids', []) if str(i).isdigit()]
    if not ids:
        return {'succeeded': [], 'failed': []}

    succeeded, failed = [], []
    async for db in get_db():
        placeholders = ','.join('?' * len(ids))
        async with db.execute(
            f"SELECT id, sonarr_id, sonarr_instance, title FROM tv_shows WHERE id IN ({placeholders})", ids
        ) as cur:
            items = [dict(r) for r in await cur.fetchall()]

    async with httpx.AsyncClient(timeout=15) as client:
        for item in items:
            inst = next((i for i in SONARR_INSTANCES if i['name'] == item['sonarr_instance']), None)
            ok = False
            if inst and item['sonarr_id']:
                try:
                    r = await client.get(
                        f"{inst['url']}/api/v3/series/{item['sonarr_id']}",
                        headers={'X-Api-Key': inst['api_key']}
                    )
                    if r.status_code == 200:
                        data = r.json()
                        data['monitored'] = False
                        await client.put(
                            f"{inst['url']}/api/v3/series/{item['sonarr_id']}",
                            headers={'X-Api-Key': inst['api_key'], 'Content-Type': 'application/json'},
                            json=data,
                        )
                        ok = True
                except Exception as e:
                    log.error(f"Bulk unmonitor error for {item['title']}: {e}")
            if ok:
                succeeded.append(item['id'])
            else:
                failed.append(item['id'])

    if succeeded:
        async for db in get_db():
            placeholders = ','.join('?' * len(succeeded))
            await db.execute(
                f"UPDATE tv_shows SET monitored=0, updated_at=CURRENT_TIMESTAMP WHERE id IN ({placeholders})",
                succeeded
            )
            await db.commit()

    return {'succeeded': succeeded, 'failed': failed}


@router.post('/tv/bulk-monitor')
async def bulk_monitor_tv(body: dict, _auth=Depends(require_auth)):
    """Re-monitor multiple TV shows in Sonarr and update DB."""
    import httpx
    ids = [int(i) for i in body.get('ids', []) if str(i).isdigit()]
    if not ids:
        return {'succeeded': [], 'failed': []}

    succeeded, failed = [], []
    async for db in get_db():
        placeholders = ','.join('?' * len(ids))
        async with db.execute(
            f"SELECT id, sonarr_id, sonarr_instance, title FROM tv_shows WHERE id IN ({placeholders})", ids
        ) as cur:
            items = [dict(r) for r in await cur.fetchall()]

    async with httpx.AsyncClient(timeout=15) as client:
        for item in items:
            inst = next((i for i in SONARR_INSTANCES if i['name'] == item['sonarr_instance']), None)
            ok = False
            if inst and item['sonarr_id']:
                try:
                    r = await client.get(
                        f"{inst['url']}/api/v3/series/{item['sonarr_id']}",
                        headers={'X-Api-Key': inst['api_key']}
                    )
                    if r.status_code == 200:
                        data = r.json()
                        data['monitored'] = True
                        await client.put(
                            f"{inst['url']}/api/v3/series/{item['sonarr_id']}",
                            headers={'X-Api-Key': inst['api_key'], 'Content-Type': 'application/json'},
                            json=data,
                        )
                        ok = True
                except Exception as e:
                    log.error(f"Bulk monitor error for {item['title']}: {e}")
            if ok:
                succeeded.append(item['id'])
            else:
                failed.append(item['id'])

    if succeeded:
        async for db in get_db():
            placeholders = ','.join('?' * len(succeeded))
            await db.execute(
                f"UPDATE tv_shows SET monitored=1, updated_at=CURRENT_TIMESTAMP WHERE id IN ({placeholders})",
                succeeded
            )
            await db.commit()

    return {'succeeded': succeeded, 'failed': failed}


@router.post('/tv/bulk-delete')
async def bulk_delete_tv(body: dict, _auth=Depends(require_auth)):
    """Delete multiple TV shows from Sonarr + Unraid."""
    ids = [int(i) for i in body.get('ids', []) if str(i).isdigit()]
    if not ids:
        return {'succeeded': [], 'failed': []}

    async for db in get_db():
        placeholders = ','.join('?' * len(ids))
        async with db.execute(
            f"SELECT * FROM tv_shows WHERE id IN ({placeholders})", ids
        ) as cur:
            items = [dict(r) for r in await cur.fetchall()]

    from app.routes.actions import delete_from_arr_and_disk
    succeeded, failed = [], []
    for item in items:
        try:
            result = await delete_from_arr_and_disk(item, 'tv')
            if result.get('arr_delete_ok') and result.get('unraid_delete_ok'):
                async for db in get_db():
                    await db.execute("DELETE FROM tv_seasons WHERE show_id=?", (item['id'],))
                    await db.execute("DELETE FROM tv_shows WHERE id=?", (item['id'],))
                    await db.commit()
                succeeded.append({'id': item['id'], 'title': item['title']})
            else:
                failed.append({'id': item['id'], 'title': item['title'],
                               'error': 'Verification failed — Sonarr or disk deletion could not be confirmed'})
        except Exception as e:
            failed.append({'id': item['id'], 'title': item['title'], 'error': str(e)})

    return {'succeeded': succeeded, 'failed': failed}


@router.get('/tv/{show_id}/watch-analytics')
async def tv_watch_analytics(show_id: int, _auth=Depends(require_auth)):
    """Watch depth analytics for a TV show."""
    from datetime import datetime, timezone

    def _analytics(plays, total_eps, last_watched_iso):
        depth_pct = min(100.0, round(plays / max(total_eps, 1) * 100, 1)) if plays else 0.0
        days_since = None
        if last_watched_iso:
            try:
                dt = datetime.fromisoformat(last_watched_iso)
                days_since = (datetime.now(timezone.utc) - dt.replace(tzinfo=timezone.utc)).days
            except Exception:
                pass
        if plays == 0:
            status = 'Never'
        elif days_since is not None and days_since > 90:
            status = 'Abandoned'
        elif days_since is not None and days_since > 30:
            status = 'Stalled'
        elif days_since is not None and days_since <= 14:
            status = 'Active'
        else:
            status = 'Watching'
        return {'plays': plays, 'depth_pct': depth_pct, 'days_since': days_since, 'status': status,
                'last_watched': last_watched_iso}

    async for db in get_db():
        async with db.execute("SELECT * FROM tv_shows WHERE id=?", (show_id,)) as cur:
            row = await cur.fetchone()
        if not row:
            from fastapi import HTTPException
            raise HTTPException(status_code=404, detail='Show not found')
        show = dict(row)

        total_eps = show.get('total_episodes') or 1
        ali = _analytics(show.get('ali_play_count') or 0, total_eps, show.get('ali_last_watched'))
        chris = _analytics(show.get('chris_play_count') or 0, total_eps, show.get('chris_last_watched'))

        combined_plays = (show.get('ali_play_count') or 0) + (show.get('chris_play_count') or 0)
        combined_last = max(
            show.get('ali_last_watched') or '',
            show.get('chris_last_watched') or ''
        ) or None
        combined = _analytics(combined_plays, total_eps, combined_last)

        # Episode timeline from watch_history
        # Use per-instance keys where available (set by Plex sync), fall back to shared plex_key
        ali_key = show.get('ali_plex_key') or show.get('plex_key') or ''
        chris_key = show.get('chris_plex_key') or show.get('plex_key') or ''
        async with db.execute(f"""
            SELECT user_name, title as episode_title, watched_at, completion_pct, duration_sec, source
            FROM watch_history
            WHERE media_type = 'episode'
              AND (
                -- Precise: new records have show_plex_key from Tautulli, matched per-server
                (show_plex_key IS NOT NULL AND (
                  (source='tautulli-ali'   AND ? != '' AND show_plex_key = ?)
                  OR (source='tautulli-chris' AND ? != '' AND show_plex_key = ?)
                ))
                -- Fallback: title-based for records without show_plex_key
                -- Only exact match or "Title (YYYY)" variant — do NOT strip year from DB title
                -- (stripping causes false positives e.g. "The Continental (2018)" matching John Wick spinoff)
                OR (show_plex_key IS NULL AND (
                  lower(show_title) = lower(?)
                  OR lower(show_title) LIKE lower(?) || ' (____)'
                ))
              )
            ORDER BY watched_at DESC LIMIT 200
        """, (ali_key, ali_key, chris_key, chris_key,
              show['title'], show['title'])) as cur:
            timeline = [dict(r) for r in await cur.fetchall()]

        # User breakdown from timeline
        user_counts = {}
        for t in timeline:
            u = t['user_name']
            user_counts[u] = user_counts.get(u, 0) + 1
        top_watchers = sorted(user_counts.items(), key=lambda x: -x[1])[:10]

        return {
            'show_id': show_id,
            'title': show['title'],
            'total_episodes': total_eps,
            'ali': ali,
            'chris': chris,
            'combined': combined,
            'timeline': timeline,
            'top_watchers': [{'user': u, 'plays': c} for u, c in top_watchers],
        }


@router.get('/tv/unwatched-seasons')
async def list_unwatched_seasons(
    status: Optional[str] = None,
    _auth=Depends(require_auth),
):
    """Shows that have episodes downloaded but neither person has watched any.
    Returns grouped by show with season-level breakdown.
    """
    async for db in get_db():
        where_status = "AND t.status = ?" if status else ""
        args = [status] if status else []
        async with db.execute(f"""
            SELECT t.id, t.title, t.sort_title, t.year, t.status, t.tmdb_status, t.poster_url,
                   t.total_seasons, t.total_episodes, t.sonarr_instance,
                   t.composite_score, t.imdb_rating,
                   t.ali_play_count, t.chris_play_count
            FROM tv_shows t
            WHERE t.total_episodes > 0
              AND (t.ali_play_count IS NULL OR t.ali_play_count = 0)
              AND (t.chris_play_count IS NULL OR t.chris_play_count = 0)
              {where_status}
            ORDER BY t.sort_title
        """, args) as cur:
            shows = [dict(r) for r in await cur.fetchall()]

        result = []
        for show in shows:
            async with db.execute(
                "SELECT season_number, episode_count, episodes_downloaded FROM tv_seasons "
                "WHERE show_id=? AND season_number > 0 AND episodes_downloaded > 0 ORDER BY season_number",
                (show['id'],)
            ) as cur:
                seasons = [dict(r) for r in await cur.fetchall()]
            total_on_disk = sum(s['episodes_downloaded'] for s in seasons)
            if total_on_disk > 0:
                result.append({**show, 'seasons_on_disk': seasons, 'total_on_disk': total_on_disk})

        return {'total': len(result), 'items': result}


@router.get('/tv/{show_id}')
async def get_tv_show(show_id: int, _auth=Depends(require_auth)):
    async for db in get_db():
        async with db.execute("SELECT * FROM tv_shows WHERE id=?", (show_id,)) as cur:
            row = await cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail='Show not found')
        show = dict(row)

        async with db.execute(
            "SELECT * FROM tv_seasons WHERE show_id=? ORDER BY season_number",
            (show_id,)
        ) as cur:
            show['seasons'] = [dict(r) for r in await cur.fetchall()]

        async with db.execute(
            "SELECT * FROM watch_history WHERE plex_key=? ORDER BY watched_at DESC LIMIT 100",
            (show.get('plex_key'),)
        ) as cur:
            show['watch_history'] = [dict(r) for r in await cur.fetchall()]

        return show


@router.delete('/tv/{show_id}')
async def delete_tv_show(show_id: int, body: DeleteRequest, _auth=Depends(require_auth)):
    if not body.confirm:
        raise HTTPException(status_code=400, detail='Confirm required')

    async for db in get_db():
        async with db.execute("SELECT * FROM tv_shows WHERE id=?", (show_id,)) as cur:
            row = await cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail='Show not found')
        show = dict(row)

    from app.routes.actions import delete_from_arr_and_disk
    result = await delete_from_arr_and_disk(show, 'tv')

    if result.get('arr_delete_ok') and result.get('unraid_delete_ok'):
        async for db in get_db():
            await db.execute("DELETE FROM tv_seasons WHERE show_id=?", (show_id,))
            await db.execute("DELETE FROM tv_shows WHERE id=?", (show_id,))
            await db.commit()
    else:
        result['message'] = 'Verification failed — show NOT removed from Curatorr (Sonarr or disk deletion could not be confirmed)'

    return result


@router.post('/tv/{show_id}/unmonitor')
async def unmonitor_tv_show(show_id: int, _auth=Depends(require_auth)):
    async for db in get_db():
        async with db.execute("SELECT sonarr_id, sonarr_instance, title FROM tv_shows WHERE id=?", (show_id,)) as cur:
            row = await cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail='Show not found')

    sonarr_id = row['sonarr_id']
    instance_name = row['sonarr_instance']

    inst = next((i for i in SONARR_INSTANCES if i['name'] == instance_name), None)
    if inst and sonarr_id:
        try:
            import httpx
            async with httpx.AsyncClient(timeout=10) as client:
                r = await client.get(
                    f"{inst['url']}/api/v3/series/{sonarr_id}",
                    headers={'X-Api-Key': inst['api_key']}
                )
                if r.status_code == 200:
                    data = r.json()
                    data['monitored'] = False
                    await client.put(
                        f"{inst['url']}/api/v3/series/{sonarr_id}",
                        headers={'X-Api-Key': inst['api_key'], 'Content-Type': 'application/json'},
                        json=data,
                    )
        except Exception as e:
            log.error(f"TV unmonitor error: {e}")

    async for db in get_db():
        await db.execute("UPDATE tv_shows SET monitored=0, updated_at=CURRENT_TIMESTAMP WHERE id=?", (show_id,))
        await db.commit()

    return {'ok': True, 'message': 'Unmonitored'}
