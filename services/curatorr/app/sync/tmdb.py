"""TMDB sync — ratings, genres, collection data."""
import json
import logging

import httpx
from app.config import TMDB_API_KEY
from app.sync.omdb import get_cache, set_cache

log = logging.getLogger('curatorr.sync.tmdb')

TMDB_BASE = 'https://api.themoviedb.org/3'
CACHE_TTL_DAYS = 7


async def fetch_movie_details(tmdb_id: int, db) -> dict:
    """Fetch TMDB movie details."""
    if not tmdb_id or not TMDB_API_KEY:
        return {}

    cached = await get_cache(db, 'movie', str(tmdb_id), 'tmdb')
    if cached:
        return cached

    try:
        async with httpx.AsyncClient(timeout=10) as client:
            r = await client.get(
                f"{TMDB_BASE}/movie/{tmdb_id}",
                params={'api_key': TMDB_API_KEY, 'append_to_response': 'release_dates'},
            )
            r.raise_for_status()
            data = r.json()
    except Exception as e:
        log.warning(f"TMDB fetch failed for tmdb_id={tmdb_id}: {e}")
        return {}

    result = {
        'tmdb_rating': data.get('vote_average'),
        'tmdb_votes': data.get('vote_count'),
        'original_language': data.get('original_language', ''),
        'runtime_min': data.get('runtime'),
        'genres': json.dumps([g['name'] for g in data.get('genres', [])]),
    }

    # Collection
    coll = data.get('belongs_to_collection')
    if coll:
        result['collection_tmdb_id'] = coll.get('id')
        result['collection_name'] = coll.get('name', '')

    await set_cache(db, 'movie', str(tmdb_id), 'tmdb', result, CACHE_TTL_DAYS)
    return result


async def fetch_tv_details(tmdb_id: int, db) -> dict:
    """Fetch TMDB TV show details."""
    if not tmdb_id or not TMDB_API_KEY:
        return {}

    cached = await get_cache(db, 'tv', str(tmdb_id), 'tmdb')
    if cached:
        return cached

    try:
        async with httpx.AsyncClient(timeout=10) as client:
            r = await client.get(
                f"{TMDB_BASE}/tv/{tmdb_id}",
                params={'api_key': TMDB_API_KEY},
            )
            r.raise_for_status()
            data = r.json()
    except Exception as e:
        log.warning(f"TMDB TV fetch failed for tmdb_id={tmdb_id}: {e}")
        return {}

    status_map = {
        'Returning Series': 'Continuing',
        'Ended': 'Ended',
        'Canceled': 'Cancelled',
        'In Production': 'Continuing',
    }
    status = status_map.get(data.get('status', ''), data.get('status', ''))

    result = {
        'tmdb_rating': data.get('vote_average'),
        'tmdb_votes': data.get('vote_count'),
        'original_language': data.get('original_language', ''),
        'status': status,
        'genres': json.dumps([g['name'] for g in data.get('genres', [])]),
        'network': data.get('networks', [{}])[0].get('name', '') if data.get('networks') else '',
    }

    await set_cache(db, 'tv', str(tmdb_id), 'tmdb', result, CACHE_TTL_DAYS)
    return result


async def sync_collections(db):
    """Sync collection data for all movies with collection_tmdb_id."""
    if not TMDB_API_KEY:
        return

    async with db.execute(
        "SELECT DISTINCT collection_tmdb_id, collection_name FROM movies "
        "WHERE collection_tmdb_id IS NOT NULL"
    ) as cur:
        collections = await cur.fetchall()

    for coll_row in collections:
        tmdb_id = coll_row['collection_tmdb_id']
        try:
            async with httpx.AsyncClient(timeout=10) as client:
                r = await client.get(
                    f"{TMDB_BASE}/collection/{tmdb_id}",
                    params={'api_key': TMDB_API_KEY},
                )
                if r.status_code != 200:
                    continue
                data = r.json()

            movie_count = len(data.get('parts', []))
            async with db.execute(
                "SELECT COUNT(*) FROM movies WHERE collection_tmdb_id=?", (tmdb_id,)
            ) as cur:
                owned_count = (await cur.fetchone())[0]

            poster_path = data.get('poster_path', '')
            poster_url = f"https://image.tmdb.org/t/p/w300{poster_path}" if poster_path else None

            await db.execute("""
                INSERT OR REPLACE INTO collections (tmdb_id, name, poster_url, movie_count, owned_count)
                VALUES (?,?,?,?,?)
            """, (tmdb_id, data.get('name', coll_row['collection_name']),
                  poster_url, movie_count, owned_count))
        except Exception as e:
            log.warning(f"Collection sync error for {tmdb_id}: {e}")

    await db.commit()
    log.info(f"[tmdb] Synced {len(collections)} collections")


async def refresh_stale_ratings(db):
    """Refresh ratings for movies where ratings_updated_at is older than 7 days."""
    from datetime import timedelta
    from datetime import datetime

    cutoff = (datetime.utcnow() - timedelta(days=7)).isoformat()

    async with db.execute(
        "SELECT id, tmdb_id, imdb_id FROM movies WHERE tmdb_id IS NOT NULL "
        "AND (ratings_updated_at IS NULL OR ratings_updated_at < ?) LIMIT 50",
        (cutoff,)
    ) as cur:
        movies = await cur.fetchall()

    updated = 0
    for movie in movies:
        tmdb_id = movie['tmdb_id']
        imdb_id = movie['imdb_id']

        if tmdb_id:
            # Invalidate cache to force re-fetch
            await db.execute(
                "DELETE FROM ratings_cache WHERE media_type='movie' AND external_id=? AND source='tmdb'",
                (str(tmdb_id),)
            )
            tmdb_data = await fetch_movie_details(tmdb_id, db)
            if tmdb_data:
                if tmdb_data.get('tmdb_rating'):
                    await db.execute(
                        "UPDATE movies SET tmdb_rating=?, tmdb_votes=?, ratings_updated_at=CURRENT_TIMESTAMP WHERE id=?",
                        (tmdb_data['tmdb_rating'], tmdb_data.get('tmdb_votes'), movie['id'])
                    )
                    updated += 1

        if imdb_id:
            from app.sync.mdblist import fetch_ratings as mdb_fetch
            await db.execute(
                "DELETE FROM ratings_cache WHERE media_type='movie' AND external_id=? AND source='mdblist'",
                (imdb_id,)
            )
            mdb_data = await mdb_fetch(imdb_id, db)
            if mdb_data:
                await db.execute("""
                    UPDATE movies SET
                        mdblist_score = COALESCE(?, mdblist_score),
                        imdb_rating = COALESCE(?, imdb_rating),
                        rt_critics = COALESCE(?, rt_critics),
                        metacritic = COALESCE(?, metacritic),
                        ratings_updated_at = CURRENT_TIMESTAMP
                    WHERE id = ?
                """, (
                    mdb_data.get('mdblist_score'), mdb_data.get('imdb_rating'),
                    mdb_data.get('rt_critics'), mdb_data.get('metacritic'), movie['id']
                ))

    await db.commit()
    log.info(f"[tmdb] Refreshed ratings for {updated} items")
    return updated
