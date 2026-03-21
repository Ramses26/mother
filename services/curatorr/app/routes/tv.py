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
    'season_completion_pct', 'status', 'total_episodes',
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
        genre_list = [g.strip() for g in str(params['genre']).split(',')]
        for g in genre_list:
            conditions.append("genres LIKE ?")
            args.append(f"%{g}%")

    if params.get('status'):
        conditions.append("status = ?")
        args.append(params['status'])

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
        conditions.append("status = 'Cancelled' AND (ali_play_count > 0 OR chris_play_count > 0)")

    if params.get('cancelled_never_watched') == 'true':
        conditions.append("status = 'Cancelled' AND ali_play_count = 0 AND chris_play_count = 0")

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
    title: Optional[str] = None,
    year_min: Optional[int] = None,
    year_max: Optional[int] = None,
    language: Optional[str] = None,
    genre: Optional[str] = None,
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
    _auth=Depends(require_auth),
):
    params = {
        'title': title, 'year_min': year_min, 'year_max': year_max,
        'language': language, 'genre': genre, 'status': status,
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

    params = {k: v for k, v in params.items() if v is not None}

    where, args = build_tv_query(params)

    order_parts = [safe_sort(sort_by, sort_dir)]
    if sort_by2:
        order_parts.append(safe_sort(sort_by2, sort_dir2))
    order_by = "ORDER BY " + ", ".join(order_parts)

    async for db in get_db():
        async with db.execute(f"SELECT COUNT(*) FROM tv_shows {where}", args) as cur:
            total = (await cur.fetchone())[0]

        offset = (page - 1) * per_page
        query = f"""
            SELECT id, title, sort_title, year, tmdb_id, imdb_id, tvdb_id,
                   status, network, total_seasons, total_episodes,
                   monitored, sonarr_id, sonarr_instance,
                   imdb_rating, rt_critics, metacritic, tmdb_rating,
                   mdblist_score, composite_score, purge_score,
                   season_completion_pct,
                   ali_play_count, ali_last_watched,
                   chris_play_count, chris_last_watched,
                   plex_added_at, genres
            FROM tv_shows {where} {order_by}
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


@router.get('/tv/export')
async def export_tv(_auth=Depends(require_auth)):
    async for db in get_db():
        async with db.execute(
            "SELECT id, title, year, imdb_id, tmdb_id, composite_score, imdb_rating, "
            "rt_critics, metacritic, status, total_seasons, total_episodes, "
            "ali_play_count, chris_play_count, purge_score, monitored, sonarr_instance "
            "FROM tv_shows ORDER BY sort_title"
        ) as cur:
            rows = await cur.fetchall()

    output = io.StringIO()
    writer = csv.DictWriter(output, fieldnames=[
        'id', 'title', 'year', 'imdb_id', 'tmdb_id', 'composite_score',
        'imdb_rating', 'rt_critics', 'metacritic', 'status', 'total_seasons',
        'total_episodes', 'ali_play_count', 'chris_play_count',
        'purge_score', 'monitored', 'sonarr_instance',
    ])
    writer.writeheader()
    for row in rows:
        writer.writerow(dict(row))

    return StreamingResponse(
        iter([output.getvalue()]),
        media_type='text/csv',
        headers={'Content-Disposition': 'attachment; filename=curatorr_tv.csv'},
    )


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

    async for db in get_db():
        await db.execute("DELETE FROM tv_seasons WHERE show_id=?", (show_id,))
        await db.execute("DELETE FROM tv_shows WHERE id=?", (show_id,))
        await db.commit()

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
