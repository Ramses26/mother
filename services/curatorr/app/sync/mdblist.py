"""MDBList sync — aggregated ratings (IMDb, RT, Metacritic, Trakt, Letterboxd)."""
import json
import logging
from datetime import datetime, timedelta

import httpx
from app.config import MDBLIST_API_KEY
from app.database import get_config
from app.sync.omdb import get_cache, set_cache

log = logging.getLogger('curatorr.sync.mdblist')

MDBLIST_URL = 'https://mdblist.com/api/'
CACHE_TTL_DAYS = 7


async def fetch_ratings(imdb_id: str, db, media_type: str = 'movie', _api_key: str = None, _client=None) -> dict:
    """Fetch MDBList aggregated ratings for an IMDb ID."""
    if not imdb_id:
        return {}

    cached = await get_cache(db, media_type, imdb_id, 'mdblist')
    if cached:
        return cached

    api_key = _api_key or MDBLIST_API_KEY
    if not api_key:
        log.debug("MDBList API key not configured")
        return {}

    _own_client = _client is None
    if _own_client:
        client = httpx.AsyncClient(timeout=10)
    else:
        client = _client
    try:
        r = await client.get(MDBLIST_URL, params={'apikey': api_key, 'i': imdb_id})
        r.raise_for_status()
        data = r.json()
    except Exception as e:
        log.warning(f"MDBList fetch failed for {imdb_id}: {e}")
        return {}
    finally:
        if _own_client:
            await client.aclose()

    if data.get('error') or not data.get('title'):
        return {}

    result = {}
    try:
        score = data.get('score')
        if score is not None:
            result['mdblist_score'] = int(score)

        # Extract from ratings array
        for rating in data.get('ratings', []):
            source = rating.get('source', '').lower()
            value = rating.get('value')
            if value is None:
                continue
            if source == 'imdb':
                result['imdb_rating'] = float(value)
            elif source == 'tomatoes':
                result['rt_critics'] = int(value)
            elif source == 'metacritic':
                result['metacritic'] = int(value)
            elif source == 'trakt':
                result['trakt_rating'] = float(value)
            elif source == 'letterboxd':
                result['letterboxd_rating'] = float(value)
            elif source == 'tmdb':
                result['tmdb_rating'] = float(value)
    except Exception as e:
        log.warning(f"MDBList parse error for {imdb_id}: {e}")

    await set_cache(db, media_type, imdb_id, 'mdblist', result, CACHE_TTL_DAYS)
    return result


async def sync_all_ratings(db, limit: int = 1000):
    """Fetch MDBList ratings for movies missing composite scores."""
    _api_key = await get_config('mdblist_api_key', MDBLIST_API_KEY) or MDBLIST_API_KEY

    limit_clause = f"LIMIT {limit}" if limit else ""
    async with db.execute(
        "SELECT id, imdb_id, title FROM movies WHERE imdb_id IS NOT NULL "
        f"AND (mdblist_score IS NULL OR mdblist_score = 0) "
        f"AND imdb_id != '' {limit_clause}"
    ) as cur:
        movies = await cur.fetchall()

    log.info(f"[mdblist] Fetching ratings for {len(movies)} movies")
    updated = 0

    async with httpx.AsyncClient(timeout=10) as http_client:
        for movie in movies:
            data = await fetch_ratings(movie['imdb_id'], db, 'movie', _api_key=_api_key, _client=http_client)
            if data:
                await db.execute("""
                    UPDATE movies SET
                        mdblist_score = COALESCE(?, mdblist_score),
                        imdb_rating = COALESCE(?, imdb_rating),
                        rt_critics = COALESCE(?, rt_critics),
                        metacritic = COALESCE(?, metacritic),
                        trakt_rating = COALESCE(?, trakt_rating),
                        letterboxd_rating = COALESCE(?, letterboxd_rating),
                        tmdb_rating = COALESCE(?, tmdb_rating),
                        ratings_updated_at = CURRENT_TIMESTAMP,
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = ?
                """, (
                    data.get('mdblist_score'), data.get('imdb_rating'),
                    data.get('rt_critics'), data.get('metacritic'),
                    data.get('trakt_rating'), data.get('letterboxd_rating'),
                    data.get('tmdb_rating'), movie['id']
                ))
                updated += 1

    await db.commit()
    log.info(f"[mdblist] Updated ratings for {updated} movies")
    return updated


async def sync_tv_ratings(db, limit: int = 1000):
    """Fetch MDBList ratings for TV shows missing ratings."""
    _api_key = await get_config('mdblist_api_key', MDBLIST_API_KEY) or MDBLIST_API_KEY

    limit_clause = f"LIMIT {limit}" if limit else ""
    async with db.execute(
        "SELECT id, imdb_id, title FROM tv_shows WHERE imdb_id IS NOT NULL "
        f"AND (mdblist_score IS NULL OR mdblist_score = 0 OR rt_critics IS NULL) "
        f"AND imdb_id != '' {limit_clause}"
    ) as cur:
        shows = await cur.fetchall()

    log.info(f"[mdblist] Fetching ratings for {len(shows)} TV shows")
    updated = 0

    async with httpx.AsyncClient(timeout=10) as http_client:
        for show in shows:
            data = await fetch_ratings(show['imdb_id'], db, 'tv', _api_key=_api_key, _client=http_client)
            if data:
                await db.execute("""
                    UPDATE tv_shows SET
                        mdblist_score = COALESCE(?, mdblist_score),
                        imdb_rating = COALESCE(?, imdb_rating),
                        rt_critics = COALESCE(?, rt_critics),
                        metacritic = COALESCE(?, metacritic),
                        trakt_rating = COALESCE(?, trakt_rating),
                        tmdb_rating = COALESCE(?, tmdb_rating),
                        ratings_updated_at = CURRENT_TIMESTAMP,
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = ?
                """, (
                    data.get('mdblist_score'), data.get('imdb_rating'),
                    data.get('rt_critics'), data.get('metacritic'),
                    data.get('trakt_rating'),
                    data.get('tmdb_rating'), show['id']
                ))
                updated += 1

    await db.commit()
    log.info(f"[mdblist] Updated ratings for {updated} TV shows")
    return updated
