"""OMDB sync — fetch ratings with cache."""
import json
import logging
from datetime import datetime, timedelta

import httpx
from app.config import OMDB_API_KEY
from app.database import get_config

log = logging.getLogger('curatorr.sync.omdb')

OMDB_URL = 'http://www.omdbapi.com/'
CACHE_TTL_DAYS = 7


async def get_cache(db, media_type: str, external_id: str, source: str) -> dict | None:
    async with db.execute(
        "SELECT data, expires_at FROM ratings_cache WHERE media_type=? AND external_id=? AND source=?",
        (media_type, external_id, source)
    ) as cur:
        row = await cur.fetchone()
    if not row:
        return None
    if row['expires_at'] and row['expires_at'] < datetime.utcnow().isoformat():
        return None
    try:
        return json.loads(row['data'])
    except Exception:
        return None


async def set_cache(db, media_type: str, external_id: str, source: str, data: dict, ttl_days: int = 7):
    expires = (datetime.utcnow() + timedelta(days=ttl_days)).isoformat()
    await db.execute("""
        INSERT OR REPLACE INTO ratings_cache (media_type, external_id, source, data, fetched_at, expires_at)
        VALUES (?,?,?,?,CURRENT_TIMESTAMP,?)
    """, (media_type, external_id, source, json.dumps(data), expires))
    await db.commit()


async def fetch_ratings(imdb_id: str, db, media_type: str = 'movie', _api_key: str = None, _client=None) -> dict:
    """Fetch OMDB ratings for an IMDb ID, using cache."""
    if not imdb_id:
        return {}

    cached = await get_cache(db, media_type, imdb_id, 'omdb')
    if cached:
        return cached

    api_key = _api_key or OMDB_API_KEY
    if not api_key:
        log.debug("OMDB API key not configured")
        return {}

    _own_client = _client is None
    if _own_client:
        client = httpx.AsyncClient(timeout=10)
    else:
        client = _client
    try:
        r = await client.get(OMDB_URL, params={'i': imdb_id, 'apikey': api_key})
        if r.status_code == 401:
            log.warning("OMDB API key invalid or daily quota exceeded (401)")
            return {'_quota_exceeded': True}
        r.raise_for_status()
        data = r.json()
    except Exception as e:
        log.warning(f"OMDB fetch failed for {imdb_id}: {e}")
        return {}
    finally:
        if _own_client:
            await client.aclose()

    if data.get('Response') == 'False':
        if 'Request limit reached' in data.get('Error', ''):
            log.warning("OMDB daily request limit reached")
            return {'_quota_exceeded': True}
        log.debug(f"OMDB: no data for {imdb_id}")
        return {}

    result = {}
    try:
        imdb_rating_raw = data.get('imdbRating', 0) or 0
        imdb_rating = float(imdb_rating_raw) if str(imdb_rating_raw).replace('.', '', 1).isdigit() else 0
        if imdb_rating > 0:
            result['imdb_rating'] = imdb_rating
        imdb_votes_str = (data.get('imdbVotes', '') or '').replace(',', '')
        if imdb_votes_str.isdigit():
            result['imdb_votes'] = int(imdb_votes_str)
        metascore = int(data.get('Metascore', 0) or 0)
        if metascore > 0:
            result['metacritic'] = metascore

        for rating in data.get('Ratings', []):
            source = rating.get('Source', '')
            value = rating.get('Value', '')
            if 'Rotten Tomatoes' in source:
                try:
                    result['rt_critics'] = int(value.replace('%', ''))
                except Exception:
                    pass
    except Exception as e:
        log.warning(f"OMDB parse error for {imdb_id}: {e}")

    await set_cache(db, media_type, imdb_id, 'omdb', result, CACHE_TTL_DAYS)
    return result


async def sync_all_ratings(db, limit: int = 1000):
    """Fetch OMDB ratings for all movies with imdb_id but missing ratings."""
    # Pick up API key from config table (editable in Settings UI)
    _api_key = await get_config('omdb_api_key', OMDB_API_KEY) or OMDB_API_KEY

    limit_clause = f"LIMIT {limit}" if limit else ""
    async with db.execute(
        "SELECT id, imdb_id, title FROM movies WHERE imdb_id IS NOT NULL "
        f"AND (imdb_rating IS NULL OR imdb_rating = 0) "
        f"AND imdb_id != '' {limit_clause}"
    ) as cur:
        movies = await cur.fetchall()

    log.info(f"[omdb] Fetching ratings for {len(movies)} movies")
    updated = 0

    async with httpx.AsyncClient(timeout=10) as http_client:
        for movie in movies:
            data = await fetch_ratings(movie['imdb_id'], db, 'movie', _api_key=_api_key, _client=http_client)
            if data.get('_quota_exceeded'):
                log.info(f"[omdb] Stopping movies — quota exceeded after {updated} updates")
                break
            if data:
                await db.execute("""
                    UPDATE movies SET
                        imdb_rating = COALESCE(?, imdb_rating),
                        imdb_votes = COALESCE(?, imdb_votes),
                        rt_critics = COALESCE(?, rt_critics),
                        metacritic = COALESCE(?, metacritic),
                        ratings_updated_at = CURRENT_TIMESTAMP,
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = ?
                """, (
                    data.get('imdb_rating'), data.get('imdb_votes'),
                    data.get('rt_critics'), data.get('metacritic'),
                    movie['id']
                ))
                updated += 1

    await db.commit()
    log.info(f"[omdb] Updated ratings for {updated} movies")
    return updated


async def sync_tv_ratings(db, limit: int = 1000):
    """Fetch OMDB ratings for all TV shows with imdb_id but missing ratings."""
    _api_key = await get_config('omdb_api_key', OMDB_API_KEY) or OMDB_API_KEY

    limit_clause = f"LIMIT {limit}" if limit else ""
    async with db.execute(
        "SELECT id, imdb_id, title FROM tv_shows WHERE imdb_id IS NOT NULL "
        f"AND (imdb_rating IS NULL OR imdb_rating = 0 OR rt_critics IS NULL) "
        f"AND imdb_id != '' {limit_clause}"
    ) as cur:
        shows = await cur.fetchall()

    log.info(f"[omdb] Fetching ratings for {len(shows)} TV shows")
    updated = 0

    async with httpx.AsyncClient(timeout=10) as http_client:
        for show in shows:
            data = await fetch_ratings(show['imdb_id'], db, 'tv', _api_key=_api_key, _client=http_client)
            if data.get('_quota_exceeded'):
                log.info(f"[omdb] Stopping TV shows — quota exceeded after {updated} updates")
                break
            if data:
                await db.execute("""
                    UPDATE tv_shows SET
                        imdb_rating = COALESCE(?, imdb_rating),
                        rt_critics = COALESCE(?, rt_critics),
                        metacritic = COALESCE(?, metacritic),
                        ratings_updated_at = CURRENT_TIMESTAMP,
                        updated_at = CURRENT_TIMESTAMP
                    WHERE id = ?
                """, (
                    data.get('imdb_rating'),
                    data.get('rt_critics'), data.get('metacritic'),
                    show['id']
                ))
                updated += 1

    await db.commit()
    log.info(f"[omdb] Updated ratings for {updated} TV shows")
    return updated
