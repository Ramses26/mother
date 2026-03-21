"""Duplicates detection from Plex."""
import logging
from fastapi import APIRouter, Depends
from app.auth import require_auth
from app.database import get_db

router = APIRouter()
log = logging.getLogger('curatorr.routes.duplicates')


@router.get('/duplicates')
async def list_duplicates(_auth=Depends(require_auth)):
    """Find duplicate movies by TMDB ID (same movie, multiple files)."""
    async for db in get_db():
        async with db.execute("""
            SELECT tmdb_id, COUNT(*) AS count
            FROM movies
            WHERE tmdb_id IS NOT NULL
            GROUP BY tmdb_id
            HAVING count > 1
        """) as cur:
            dup_tmdb_ids = [row['tmdb_id'] for row in await cur.fetchall()]

        if not dup_tmdb_ids:
            return []

        result = []
        for tmdb_id in dup_tmdb_ids:
            async with db.execute(
                "SELECT id, title, year, resolution, video_codec, audio_codec, "
                "file_size_bytes, file_path, trash_score, imdb_rating, composite_score, "
                "radarr_instance, radarr_id "
                "FROM movies WHERE tmdb_id=? ORDER BY trash_score DESC",
                (tmdb_id,)
            ) as cur:
                versions = [dict(r) for r in await cur.fetchall()]

            if len(versions) >= 2:
                result.append({
                    'tmdb_id': tmdb_id,
                    'title': versions[0]['title'],
                    'year': versions[0]['year'],
                    'versions': versions,
                    'recommended_keep_id': versions[0]['id'],  # highest trash_score
                })

        return result
