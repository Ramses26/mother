"""Movies API — filtering, sorting, pagination, detail, delete, unmonitor."""
import logging
import os
import shutil
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query
from fastapi.responses import StreamingResponse
import io, csv

from app.auth import require_auth
from app.database import get_db
from app.models import DeleteRequest
from app.notifications import send_notification
from app.config import RADARR_INSTANCES, synology_to_unraid_path

router = APIRouter()
log = logging.getLogger('curatorr.routes.movies')

PRESET_FILTERS = {
    'never_watched': {'neither_watched': 'true'},
    'low_rated_unwatched': {'composite_max': 5.0, 'neither_watched': 'true'},
    'hidden_gems': {'composite_min': 7.5, 'neither_watched': 'true'},
    'purge_candidates': {'purge_score_min': 30},
    'large_files': {'sort_by': 'file_size_bytes', 'sort_dir': 'desc'},
    'cancelled_watched': {},  # handled specially for TV
}


def build_movie_query(params: dict) -> tuple[str, list]:
    """Build SQL WHERE clause from filter params."""
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

    if params.get('resolution'):
        res_list = [r.strip() for r in str(params['resolution']).split(',')]
        placeholders = ','.join('?' * len(res_list))
        conditions.append(f"resolution IN ({placeholders})")
        args += res_list

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

    if params.get('file_size_min_gb'):
        conditions.append("file_size_bytes >= ?")
        args.append(int(float(params['file_size_min_gb']) * 1_073_741_824))
    if params.get('file_size_max_gb'):
        conditions.append("file_size_bytes <= ?")
        args.append(int(float(params['file_size_max_gb']) * 1_073_741_824))

    if params.get('instance'):
        conditions.append("radarr_instance = ?")
        args.append(params['instance'])

    if params.get('collection_id'):
        conditions.append("collection_tmdb_id = ?")
        args.append(int(params['collection_id']))

    where = ("WHERE " + " AND ".join(conditions)) if conditions else ""
    return where, args


ALLOWED_SORT_COLS = {
    'sort_title', 'title', 'year', 'composite_score', 'imdb_rating',
    'rt_critics', 'metacritic', 'tmdb_rating', 'mdblist_score',
    'purge_score', 'file_size_bytes', 'plex_added_at', 'radarr_added_at',
    'ali_play_count', 'chris_play_count', 'resolution',
}


def safe_sort(col: str, direction: str) -> str:
    col = col if col in ALLOWED_SORT_COLS else 'sort_title'
    direction = 'DESC' if direction.upper() == 'DESC' else 'ASC'
    return f"{col} {direction}"


@router.get('/movies')
async def list_movies(
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
    resolution: Optional[str] = None,
    language: Optional[str] = None,
    genre: Optional[str] = None,
    monitored: Optional[str] = None,
    ali_watched: Optional[str] = None,
    chris_watched: Optional[str] = None,
    neither_watched: Optional[str] = None,
    both_watched: Optional[str] = None,
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
    file_size_min_gb: Optional[float] = None,
    file_size_max_gb: Optional[float] = None,
    instance: Optional[str] = None,
    collection_id: Optional[int] = None,
    preset: Optional[str] = None,
    _auth=Depends(require_auth),
):
    params = {
        'title': title, 'year_min': year_min, 'year_max': year_max,
        'resolution': resolution, 'language': language, 'genre': genre,
        'monitored': monitored, 'ali_watched': ali_watched,
        'chris_watched': chris_watched, 'neither_watched': neither_watched,
        'both_watched': both_watched, 'composite_min': composite_min, 'composite_max': composite_max,
        'imdb_min': imdb_min, 'imdb_max': imdb_max,
        'rt_min': rt_min, 'rt_max': rt_max,
        'metacritic_min': metacritic_min, 'metacritic_max': metacritic_max,
        'tmdb_min': tmdb_min, 'tmdb_max': tmdb_max,
        'mdblist_min': mdblist_min, 'mdblist_max': mdblist_max,
        'purge_score_min': purge_score_min, 'purge_score_max': purge_score_max,
        'file_size_min_gb': file_size_min_gb, 'file_size_max_gb': file_size_max_gb,
        'instance': instance, 'collection_id': collection_id,
    }

    # Apply preset
    if preset and preset in PRESET_FILTERS:
        for k, v in PRESET_FILTERS[preset].items():
            if params.get(k) is None:
                params[k] = v
        if preset == 'large_files':
            sort_by = 'file_size_bytes'
            sort_dir = 'desc'

    # Remove None
    params = {k: v for k, v in params.items() if v is not None}

    where, args = build_movie_query(params)

    # Build ORDER BY
    order_parts = [safe_sort(sort_by, sort_dir)]
    if sort_by2:
        order_parts.append(safe_sort(sort_by2, sort_dir2))
    if sort_by3:
        order_parts.append(safe_sort(sort_by3, sort_dir3))
    order_by = "ORDER BY " + ", ".join(order_parts)

    async for db in get_db():
        async with db.execute(f"SELECT COUNT(*) FROM movies {where}", args) as cur:
            total = (await cur.fetchone())[0]

        offset = (page - 1) * per_page
        query = f"""
            SELECT id, title, sort_title, year, tmdb_id, imdb_id,
                   resolution, video_codec, audio_codec, hdr_format,
                   file_size_bytes, file_path, trash_score, quality_profile,
                   monitored, radarr_id, radarr_instance,
                   imdb_rating, rt_critics, metacritic, tmdb_rating,
                   mdblist_score, composite_score, purge_score,
                   ali_play_count, ali_last_watched,
                   chris_play_count, chris_last_watched,
                   plex_added_at, genres, collection_name, collection_tmdb_id
            FROM movies {where} {order_by}
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


@router.get('/movies/export')
async def export_movies(_auth=Depends(require_auth)):
    """Export movies as CSV."""
    async for db in get_db():
        async with db.execute(
            "SELECT id, title, year, imdb_id, tmdb_id, composite_score, imdb_rating, "
            "rt_critics, metacritic, resolution, file_size_bytes, ali_play_count, "
            "chris_play_count, purge_score, monitored, radarr_instance "
            "FROM movies ORDER BY sort_title"
        ) as cur:
            rows = await cur.fetchall()

    output = io.StringIO()
    writer = csv.DictWriter(output, fieldnames=[
        'id', 'title', 'year', 'imdb_id', 'tmdb_id', 'composite_score',
        'imdb_rating', 'rt_critics', 'metacritic', 'resolution',
        'file_size_bytes', 'ali_play_count', 'chris_play_count',
        'purge_score', 'monitored', 'radarr_instance',
    ])
    writer.writeheader()
    for row in rows:
        writer.writerow(dict(row))

    return StreamingResponse(
        iter([output.getvalue()]),
        media_type='text/csv',
        headers={'Content-Disposition': 'attachment; filename=curatorr_movies.csv'},
    )


@router.get('/movies/{movie_id}')
async def get_movie(movie_id: int, _auth=Depends(require_auth)):
    async for db in get_db():
        async with db.execute("SELECT * FROM movies WHERE id=?", (movie_id,)) as cur:
            row = await cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail='Movie not found')
        movie = dict(row)

        # Watch history
        async with db.execute(
            "SELECT * FROM watch_history WHERE plex_key=? ORDER BY watched_at DESC LIMIT 50",
            (movie['plex_key'],)
        ) as cur:
            movie['watch_history'] = [dict(r) for r in await cur.fetchall()]

        return movie


@router.delete('/movies/{movie_id}')
async def delete_movie(movie_id: int, body: DeleteRequest, _auth=Depends(require_auth)):
    if not body.confirm:
        raise HTTPException(status_code=400, detail='Confirm required')

    async for db in get_db():
        async with db.execute("SELECT * FROM movies WHERE id=?", (movie_id,)) as cur:
            row = await cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail='Movie not found')
        movie = dict(row)

    from app.routes.actions import delete_from_arr_and_disk
    result = await delete_from_arr_and_disk(movie, 'movie')

    async for db in get_db():
        await db.execute("DELETE FROM movies WHERE id=?", (movie_id,))
        await db.commit()

    return result


@router.post('/movies/{movie_id}/unmonitor')
async def unmonitor_movie(movie_id: int, _auth=Depends(require_auth)):
    async for db in get_db():
        async with db.execute("SELECT radarr_id, radarr_instance, title FROM movies WHERE id=?", (movie_id,)) as cur:
            row = await cur.fetchone()
        if not row:
            raise HTTPException(status_code=404, detail='Movie not found')

    radarr_id = row['radarr_id']
    instance_name = row['radarr_instance']

    inst = next((i for i in RADARR_INSTANCES if i['name'] == instance_name), None)
    if inst and radarr_id:
        try:
            import httpx
            async with httpx.AsyncClient(timeout=10) as client:
                r = await client.get(
                    f"{inst['url']}/api/v3/movie/{radarr_id}",
                    headers={'X-Api-Key': inst['api_key']}
                )
                if r.status_code == 200:
                    data = r.json()
                    data['monitored'] = False
                    await client.put(
                        f"{inst['url']}/api/v3/movie/{radarr_id}",
                        headers={'X-Api-Key': inst['api_key'], 'Content-Type': 'application/json'},
                        json=data,
                    )
        except Exception as e:
            log.error(f"Unmonitor error: {e}")

    async for db in get_db():
        await db.execute("UPDATE movies SET monitored=0, updated_at=CURRENT_TIMESTAMP WHERE id=?", (movie_id,))
        await db.commit()

    return {'ok': True, 'message': 'Unmonitored'}
