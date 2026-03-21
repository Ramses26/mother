"""Duplicates detection from Plex."""
import logging
from fastapi import APIRouter, Depends
from app.auth import require_auth
from app.database import get_db

router = APIRouter()
log = logging.getLogger('curatorr.routes.duplicates')


@router.get('/duplicates')
async def list_duplicates(_auth=Depends(require_auth)):
    """Find duplicate movies by TMDB ID within the same resolution tier.
    1080p + 4K of the same movie are intentional — never flagged as duplicates.
    Duplicates are same TMDB ID AND same resolution tier (both 4K, or both non-4K).
    """
    async for db in get_db():
        async with db.execute("""
            SELECT tmdb_id,
                   CASE WHEN resolution = '4K' THEN '4K' ELSE 'HD' END AS res_tier,
                   COUNT(*) AS count
            FROM movies
            WHERE tmdb_id IS NOT NULL
            GROUP BY tmdb_id, res_tier
            HAVING count > 1
        """) as cur:
            dup_groups = [(row['tmdb_id'], row['res_tier']) for row in await cur.fetchall()]

        if not dup_groups:
            return []

        result = []
        for tmdb_id, res_tier in dup_groups:
            res_condition = "resolution = '4K'" if res_tier == '4K' else "resolution != '4K'"
            async with db.execute(
                f"SELECT id, title, year, resolution, video_codec, audio_codec, "
                f"file_size_bytes, file_path, trash_score, imdb_rating, composite_score, "
                f"radarr_instance, radarr_id "
                f"FROM movies WHERE tmdb_id=? AND {res_condition} ORDER BY trash_score DESC",
                (tmdb_id,)
            ) as cur:
                versions = [dict(r) for r in await cur.fetchall()]

            if len(versions) >= 2:
                result.append({
                    'tmdb_id': tmdb_id,
                    'title': versions[0]['title'],
                    'year': versions[0]['year'],
                    'resolution_tier': res_tier,
                    'versions': versions,
                    'recommended_keep_id': versions[0]['id'],  # highest trash_score
                })

        return result
