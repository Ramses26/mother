"""TMDB sync — ratings, genres, collection data."""
import json
import logging

import httpx
from app.config import TMDB_API_KEY
from app.database import get_config
from app.sync.omdb import get_cache, set_cache

log = logging.getLogger('curatorr.sync.tmdb')

TMDB_BASE = 'https://api.themoviedb.org/3'
CACHE_TTL_DAYS = 7


async def fetch_movie_details(tmdb_id: int, db, _api_key: str = None, _client=None) -> dict:
    """Fetch TMDB movie details."""
    api_key = _api_key or TMDB_API_KEY
    if not tmdb_id or not api_key:
        return {}

    cached = await get_cache(db, 'movie', str(tmdb_id), 'tmdb')
    if cached:
        return cached

    _own_client = _client is None
    if _own_client:
        client = httpx.AsyncClient(timeout=10)
    else:
        client = _client
    try:
        r = await client.get(
            f"{TMDB_BASE}/movie/{tmdb_id}",
            params={'api_key': api_key, 'append_to_response': 'release_dates'},
        )
        r.raise_for_status()
        data = r.json()
    except Exception as e:
        log.warning(f"TMDB fetch failed for tmdb_id={tmdb_id}: {e}")
        return {}
    finally:
        if _own_client:
            await client.aclose()

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


async def fetch_tv_details(tmdb_id: int, db, _api_key: str = None, _client=None) -> dict:
    """Fetch TMDB TV show details."""
    api_key = _api_key or TMDB_API_KEY
    if not tmdb_id or not api_key:
        return {}

    cached = await get_cache(db, 'tv', str(tmdb_id), 'tmdb')
    if cached:
        return cached

    _own_client = _client is None
    if _own_client:
        client = httpx.AsyncClient(timeout=10)
    else:
        client = _client
    try:
        r = await client.get(
            f"{TMDB_BASE}/tv/{tmdb_id}",
            params={'api_key': api_key},
        )
        r.raise_for_status()
        data = r.json()
    except Exception as e:
        log.warning(f"TMDB TV fetch failed for tmdb_id={tmdb_id}: {e}")
        return {}
    finally:
        if _own_client:
            await client.aclose()

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
    _api_key = await get_config('tmdb_api_key', TMDB_API_KEY) or TMDB_API_KEY
    if not _api_key:
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
                    params={'api_key': _api_key},
                )
                if r.status_code != 200:
                    continue
                data = r.json()

            parts = data.get('parts', [])
            movie_count = len(parts)
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

            # Store collection members for offline /missing endpoint
            for part in parts:
                part_poster = f"https://image.tmdb.org/t/p/w300{part['poster_path']}" if part.get('poster_path') else None
                await db.execute("""
                    INSERT OR REPLACE INTO collection_members
                        (collection_tmdb_id, movie_tmdb_id, title, year, poster_url, overview, vote_average)
                    VALUES (?,?,?,?,?,?,?)
                """, (
                    tmdb_id, part.get('id'), part.get('title', ''),
                    (part.get('release_date') or '')[:4],
                    part_poster, part.get('overview', ''), part.get('vote_average'),
                ))
        except Exception as e:
            log.warning(f"Collection sync error for {tmdb_id}: {e}")

    await db.commit()
    log.info(f"[tmdb] Synced {len(collections)} collections")


async def fill_missing_tv_ids(db):
    """For TV shows with tvdb_id but no tmdb_id, look up TMDB ID via find endpoint."""
    _api_key = await get_config('tmdb_api_key', TMDB_API_KEY) or TMDB_API_KEY
    if not _api_key:
        return 0

    async with db.execute(
        "SELECT id, tvdb_id, title FROM tv_shows WHERE tvdb_id IS NOT NULL AND tmdb_id IS NULL LIMIT 100"
    ) as cur:
        shows = await cur.fetchall()

    found = 0
    async with httpx.AsyncClient(timeout=10) as client:
        for show in shows:
            try:
                r = await client.get(
                    f"{TMDB_BASE}/find/{show['tvdb_id']}",
                    params={'api_key': _api_key, 'external_source': 'tvdb_id'},
                )
                if r.status_code != 200:
                    continue
                data = r.json()
                results = data.get('tv_results', [])
                if not results:
                    continue
                tmdb_id = results[0].get('id')
                if tmdb_id:
                    await db.execute(
                        "UPDATE tv_shows SET tmdb_id=?, updated_at=CURRENT_TIMESTAMP WHERE id=?",
                        (tmdb_id, show['id'])
                    )
                    found += 1
            except Exception as e:
                log.debug(f"fill_missing_tv_ids: {show['title']}: {e}")

    await db.commit()
    log.info(f"[tmdb] Filled missing tmdb_id for {found} TV shows")
    return found


async def refresh_stale_ratings(db, limit: int = 300):
    """Refresh ratings for movies where ratings_updated_at is older than 7 days."""
    from datetime import timedelta
    from datetime import datetime

    _tmdb_key = await get_config('tmdb_api_key', TMDB_API_KEY) or TMDB_API_KEY

    cutoff = (datetime.utcnow() - timedelta(days=7)).isoformat()

    limit_clause = f"LIMIT {limit}" if limit else ""
    async with db.execute(
        "SELECT id, tmdb_id, imdb_id FROM movies WHERE tmdb_id IS NOT NULL "
        f"AND (ratings_updated_at IS NULL OR ratings_updated_at < ?) {limit_clause}",
        (cutoff,)
    ) as cur:
        movies = await cur.fetchall()

    updated = 0
    from app.sync.mdblist import fetch_ratings as mdb_fetch
    async with httpx.AsyncClient(timeout=10) as http_client:
        for movie in movies:
            tmdb_id = movie['tmdb_id']
            imdb_id = movie['imdb_id']

            if tmdb_id:
                # Invalidate cache to force re-fetch
                await db.execute(
                    "DELETE FROM ratings_cache WHERE media_type='movie' AND external_id=? AND source='tmdb'",
                    (str(tmdb_id),)
                )
                tmdb_data = await fetch_movie_details(tmdb_id, db, _api_key=_tmdb_key, _client=http_client)
                if tmdb_data:
                    if tmdb_data.get('tmdb_rating'):
                        await db.execute(
                            "UPDATE movies SET tmdb_rating=?, tmdb_votes=?, ratings_updated_at=CURRENT_TIMESTAMP WHERE id=?",
                            (tmdb_data['tmdb_rating'], tmdb_data.get('tmdb_votes'), movie['id'])
                        )
                        updated += 1

            if imdb_id:
                await db.execute(
                    "DELETE FROM ratings_cache WHERE media_type='movie' AND external_id=? AND source='mdblist'",
                    (imdb_id,)
                )
                mdb_data = await mdb_fetch(imdb_id, db, _client=http_client)
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


async def refresh_stale_tv_ratings(db, limit: int = 300):
    """Refresh TMDB ratings for TV shows where ratings are stale."""
    from datetime import timedelta
    from datetime import datetime

    _tmdb_key = await get_config('tmdb_api_key', TMDB_API_KEY) or TMDB_API_KEY

    cutoff = (datetime.utcnow() - timedelta(days=7)).isoformat()

    limit_clause = f"LIMIT {limit}" if limit else ""
    async with db.execute(
        "SELECT id, tmdb_id, imdb_id FROM tv_shows WHERE tmdb_id IS NOT NULL "
        "AND (ratings_updated_at IS NULL OR ratings_updated_at < ?) "
        "ORDER BY CASE WHEN status='Ended' THEN 0 ELSE 1 END, ratings_updated_at ASC NULLS FIRST "
        f"{limit_clause}",
        (cutoff,)
    ) as cur:
        shows = await cur.fetchall()

    updated = 0
    from app.sync.mdblist import fetch_ratings as mdb_fetch
    async with httpx.AsyncClient(timeout=10) as http_client:
        for show in shows:
            tmdb_id = show['tmdb_id']
            imdb_id = show['imdb_id']

            if tmdb_id:
                await db.execute(
                    "DELETE FROM ratings_cache WHERE media_type='tv' AND external_id=? AND source='tmdb'",
                    (str(tmdb_id),)
                )
                tmdb_data = await fetch_tv_details(tmdb_id, db, _api_key=_tmdb_key, _client=http_client)
                if tmdb_data:
                    set_clauses = ['ratings_updated_at=CURRENT_TIMESTAMP']
                    vals = []
                    if tmdb_data.get('tmdb_rating'):
                        set_clauses.append('tmdb_rating=?')
                        vals.append(tmdb_data['tmdb_rating'])
                    # Update status from TMDB — catches shows Sonarr marks "ended" but TMDB marks "Canceled"
                    if tmdb_data.get('status'):
                        set_clauses.append('status=?')
                        vals.append(tmdb_data['status'])
                    vals.append(show['id'])
                    await db.execute(
                        f"UPDATE tv_shows SET {', '.join(set_clauses)} WHERE id=?", vals
                    )
                    updated += 1

            if imdb_id:
                await db.execute(
                    "DELETE FROM ratings_cache WHERE media_type='tv' AND external_id=? AND source='mdblist'",
                    (imdb_id,)
                )
                mdb_data = await mdb_fetch(imdb_id, db, 'tv', _client=http_client)
                if mdb_data:
                    await db.execute("""
                        UPDATE tv_shows SET
                            mdblist_score = COALESCE(?, mdblist_score),
                            imdb_rating = COALESCE(?, imdb_rating),
                            rt_critics = COALESCE(?, rt_critics),
                            metacritic = COALESCE(?, metacritic),
                            ratings_updated_at = CURRENT_TIMESTAMP
                        WHERE id = ?
                    """, (
                        mdb_data.get('mdblist_score'), mdb_data.get('imdb_rating'),
                        mdb_data.get('rt_critics'), mdb_data.get('metacritic'), show['id']
                ))

    await db.commit()
    log.info(f"[tmdb] Refreshed TV ratings for {updated} shows")
    return updated
