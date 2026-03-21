"""Collections API."""
import logging
import httpx
from fastapi import APIRouter, Depends, HTTPException
from app.auth import require_auth
from app.database import get_db
from app.config import TMDB_API_KEY, OVERSEERR_URL

router = APIRouter()
log = logging.getLogger('curatorr.routes.collections')


@router.get('/collections')
async def list_collections(_auth=Depends(require_auth)):
    async for db in get_db():
        async with db.execute(
            "SELECT c.*, "
            "(SELECT COUNT(DISTINCT m.tmdb_id) FROM movies m WHERE m.collection_tmdb_id = c.tmdb_id) AS owned_count "
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
            "resolution, file_size_bytes, tmdb_id, monitored, purge_score, poster_url "
            "FROM movies WHERE collection_tmdb_id=? ORDER BY year",
            (tmdb_id,)
        ) as cur:
            collection['movies'] = [dict(r) for r in await cur.fetchall()]

        return collection


@router.get('/collections/{tmdb_id}/missing')
async def get_missing_movies(tmdb_id: int, _auth=Depends(require_auth)):
    """Return movies in this TMDB collection that we don't own. Uses DB cache."""
    async for db in get_db():
        # Check if we have cached members from sync_collections()
        async with db.execute(
            "SELECT COUNT(*) FROM collection_members WHERE collection_tmdb_id=?", (tmdb_id,)
        ) as cur:
            cached_count = (await cur.fetchone())[0]

        if cached_count > 0:
            # Use cached data — no TMDB API call needed
            async with db.execute(
                "SELECT cm.movie_tmdb_id AS tmdb_id, cm.title, cm.year, cm.poster_url, cm.overview, cm.vote_average "
                "FROM collection_members cm "
                "WHERE cm.collection_tmdb_id=? "
                "AND cm.movie_tmdb_id NOT IN (SELECT tmdb_id FROM movies WHERE collection_tmdb_id=?)",
                (tmdb_id, tmdb_id)
            ) as cur:
                rows = await cur.fetchall()
            missing = [dict(r) for r in rows]
            return {'missing': missing, 'total': len(missing)}

        # No cache yet — fall back to live TMDB call
        if not TMDB_API_KEY:
            raise HTTPException(status_code=503, detail='TMDB API key not configured — run a ratings sync first')

        try:
            async with httpx.AsyncClient(timeout=10) as client:
                r = await client.get(
                    f'https://api.themoviedb.org/3/collection/{tmdb_id}',
                    params={'api_key': TMDB_API_KEY}
                )
                r.raise_for_status()
                data = r.json()
        except Exception as e:
            raise HTTPException(status_code=502, detail=f'TMDB error: {e}')

        tmdb_movies = data.get('parts', [])

        # Cache members for future use
        for part in tmdb_movies:
            part_poster = f"https://image.tmdb.org/t/p/w300{part['poster_path']}" if part.get('poster_path') else None
            try:
                await db.execute("""
                    INSERT OR REPLACE INTO collection_members
                        (collection_tmdb_id, movie_tmdb_id, title, year, poster_url, overview, vote_average)
                    VALUES (?,?,?,?,?,?,?)
                """, (
                    tmdb_id, part.get('id'), part.get('title', ''),
                    (part.get('release_date') or '')[:4],
                    part_poster, part.get('overview', ''), part.get('vote_average'),
                ))
            except Exception:
                pass
        await db.commit()

        async with db.execute(
            "SELECT tmdb_id FROM movies WHERE collection_tmdb_id=?", (tmdb_id,)
        ) as cur:
            owned_ids = {r[0] for r in await cur.fetchall()}

        missing = []
        for m in tmdb_movies:
            if m.get('id') not in owned_ids:
                missing.append({
                    'tmdb_id': m.get('id'),
                    'title': m.get('title', ''),
                    'year': (m.get('release_date') or '')[:4],
                    'poster_url': f"https://image.tmdb.org/t/p/w300{m['poster_path']}" if m.get('poster_path') else None,
                    'overview': m.get('overview', ''),
                    'vote_average': m.get('vote_average'),
                })

        return {'missing': missing, 'total': len(missing)}


@router.post('/collections/{tmdb_id}/request/{movie_tmdb_id}')
async def request_movie(tmdb_id: int, movie_tmdb_id: int, _auth=Depends(require_auth)):
    """Request a missing collection movie via Overseerr."""
    overseerr = await _get_overseerr_url()
    if not overseerr:
        raise HTTPException(status_code=503, detail='Overseerr URL not configured')

    try:
        async with httpx.AsyncClient(timeout=10) as client:
            r = await client.post(
                f'{overseerr}/api/v1/request',
                json={'mediaType': 'movie', 'mediaId': movie_tmdb_id},
                headers={'X-Api-User': '1'},  # Overseerr admin user
            )
            if r.status_code in (200, 201):
                return {'ok': True, 'message': 'Request submitted to Overseerr'}
            elif r.status_code == 409:
                return {'ok': True, 'message': 'Already requested or in library'}
            else:
                raise HTTPException(status_code=r.status_code, detail=r.text)
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=502, detail=f'Overseerr error: {e}')


@router.post('/collections/{tmdb_id}/add-to-radarr/{movie_tmdb_id}')
async def add_to_radarr(tmdb_id: int, movie_tmdb_id: int, _auth=Depends(require_auth)):
    """Add a missing collection movie directly to Radarr HD and trigger a search."""
    from app.config import RADARR_INSTANCES
    from app.database import get_config
    from app.config import RADARR_HD_PUBLIC_URL

    inst = RADARR_INSTANCES[0]  # Use Radarr HD by default
    if not inst.get('api_key'):
        raise HTTPException(status_code=503, detail='Radarr HD not configured')

    try:
        async with httpx.AsyncClient(timeout=15) as client:
            # Get root folders
            rf = await client.get(f"{inst['url']}/api/v3/rootfolder",
                                  headers={'X-Api-Key': inst['api_key']})
            rf.raise_for_status()
            root_folders = rf.json()
            if not root_folders:
                raise HTTPException(status_code=503, detail='No root folders in Radarr HD')
            root_path = root_folders[0]['path']

            # Get quality profiles
            qp = await client.get(f"{inst['url']}/api/v3/qualityprofile",
                                  headers={'X-Api-Key': inst['api_key']})
            qp.raise_for_status()
            profiles = qp.json()
            if not profiles:
                raise HTTPException(status_code=503, detail='No quality profiles in Radarr HD')
            profile_id = profiles[0]['id']

            # Add movie
            r = await client.post(
                f"{inst['url']}/api/v3/movie",
                headers={'X-Api-Key': inst['api_key']},
                json={
                    'tmdbId': movie_tmdb_id,
                    'qualityProfileId': profile_id,
                    'rootFolderPath': root_path,
                    'monitored': True,
                    'addOptions': {'searchForMovie': True},
                }
            )
            if r.status_code in (200, 201):
                return {'ok': True, 'message': 'Added to Radarr HD — searching now'}
            elif r.status_code == 400 and 'already' in (r.text or '').lower():
                return {'ok': True, 'message': 'Already in Radarr'}
            else:
                raise HTTPException(status_code=r.status_code, detail=r.text[:200])
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=502, detail=f'Radarr error: {e}')


async def _get_overseerr_url() -> str:
    """Get Overseerr URL from config table or env."""
    from app.database import get_config
    from app.config import OVERSEERR_URL
    url = await get_config('public_url_overseerr', OVERSEERR_URL)
    return (url or '').rstrip('/')
