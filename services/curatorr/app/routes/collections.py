"""Collections API."""
import logging
from fastapi import APIRouter, Depends, HTTPException
from app.auth import require_auth
from app.database import get_db

router = APIRouter()
log = logging.getLogger('curatorr.routes.collections')


@router.get('/collections')
async def list_collections(_auth=Depends(require_auth)):
    async for db in get_db():
        async with db.execute(
            "SELECT c.*, "
            "(SELECT COUNT(*) FROM movies m WHERE m.collection_tmdb_id = c.tmdb_id) AS owned_count "
            "FROM collections c ORDER BY c.name"
        ) as cur:
            rows = await cur.fetchall()
        return [dict(r) for r in rows]


@router.get('/collections/{tmdb_id}')
async def get_collection(tmdb_id: int, _auth=Depends(require_auth)):
    async for db in get_db():
        async with db.execute("SELECT * FROM collections WHERE tmdb_id=?", (tmdb_id,)) as cur:
            row = await cur.fetchone()

        if not row:
            # Try to build from movies
            async with db.execute(
                "SELECT collection_name, collection_tmdb_id FROM movies WHERE collection_tmdb_id=? LIMIT 1",
                (tmdb_id,)
            ) as cur:
                mrow = await cur.fetchone()
            if not mrow:
                raise HTTPException(status_code=404, detail='Collection not found')
            collection = {'tmdb_id': tmdb_id, 'name': mrow['collection_name'], 'poster_url': None}
        else:
            collection = dict(row)

        async with db.execute(
            "SELECT id, title, year, composite_score, imdb_rating, rt_critics, "
            "resolution, file_size_bytes, tmdb_id, monitored, purge_score "
            "FROM movies WHERE collection_tmdb_id=? ORDER BY year",
            (tmdb_id,)
        ) as cur:
            collection['movies'] = [dict(r) for r in await cur.fetchall()]

        return collection


@router.post('/collections/{tmdb_id}/request')
async def request_collection_movie(tmdb_id: int, _auth=Depends(require_auth)):
    """Request missing collection movies via Overseerr."""
    # Placeholder — Overseerr integration
    return {'ok': True, 'message': 'Request submitted to Overseerr (not yet implemented)'}
