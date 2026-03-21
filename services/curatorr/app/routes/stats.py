"""Dashboard stats endpoint."""
import logging
from fastapi import APIRouter, Depends
from app.auth import require_auth
from app.database import get_db

router = APIRouter()
log = logging.getLogger('curatorr.routes.stats')


@router.get('/stats')
async def dashboard_stats(_auth=Depends(require_auth)):
    """Full dashboard statistics."""
    async for db in get_db():
        # Movie counts
        async with db.execute("SELECT COUNT(*) FROM movies") as cur:
            movie_total = (await cur.fetchone())[0]
        async with db.execute("SELECT COUNT(*) FROM movies WHERE ali_play_count=0 AND chris_play_count=0") as cur:
            movie_never_watched = (await cur.fetchone())[0]
        async with db.execute("SELECT COUNT(*) FROM movies WHERE composite_score < 5 AND composite_score > 0") as cur:
            movie_below_5 = (await cur.fetchone())[0]

        # TV counts
        async with db.execute("SELECT COUNT(*) FROM tv_shows") as cur:
            tv_total = (await cur.fetchone())[0]
        async with db.execute("SELECT COUNT(*) FROM tv_shows WHERE ali_play_count=0 AND chris_play_count=0") as cur:
            tv_never_watched = (await cur.fetchone())[0]
        async with db.execute("SELECT COUNT(*) FROM tv_shows WHERE composite_score < 5 AND composite_score > 0") as cur:
            tv_below_5 = (await cur.fetchone())[0]

        # Storage (movies only — TV file sizes not tracked in DB)
        async with db.execute("SELECT COALESCE(SUM(file_size_bytes), 0) FROM movies") as cur:
            total_bytes = (await cur.fetchone())[0]

        # Histogram bucket definitions
        buckets_10 = [
            ('0-1', 0, 1), ('1-2', 1, 2), ('2-3', 2, 3), ('3-4', 3, 4),
            ('4-5', 4, 5), ('5-6', 5, 6), ('6-7', 6, 7), ('7-8', 7, 8),
            ('8-9', 8, 9), ('9-10', 9, 10),
        ]
        buckets_100 = [
            ('0-10', 0, 10), ('10-20', 10, 20), ('20-30', 20, 30), ('30-40', 30, 40),
            ('40-50', 40, 50), ('50-60', 50, 60), ('60-70', 60, 70), ('70-80', 70, 80),
            ('80-90', 80, 90), ('90-100', 90, 101),
        ]

        async def build_hist(table, col, buckets):
            result = []
            for label, low, high in buckets:
                async with db.execute(
                    f"SELECT COUNT(*) FROM {table} WHERE {col} >= ? AND {col} < ? AND {col} > 0",
                    (low, high)
                ) as cur:
                    result.append({'bucket': label, 'count': (await cur.fetchone())[0]})
            return result

        # Per-source histograms for movies and TV
        movie_hist = {
            'composite':  await build_hist('movies', 'composite_score', buckets_10),
            'imdb':       await build_hist('movies', 'imdb_rating', buckets_10),
            'rt':         await build_hist('movies', 'rt_critics', buckets_100),
            'metacritic': await build_hist('movies', 'metacritic', buckets_100),
            'mdblist':    await build_hist('movies', 'mdblist_score', buckets_100),
        }
        tv_hist = {
            'composite':  await build_hist('tv_shows', 'composite_score', buckets_10),
            'imdb':       await build_hist('tv_shows', 'imdb_rating', buckets_10),
            'rt':         await build_hist('tv_shows', 'rt_critics', buckets_100),
            'metacritic': await build_hist('tv_shows', 'metacritic', buckets_100),
            'mdblist':    await build_hist('tv_shows', 'mdblist_score', buckets_100),
        }

        # Top purge candidates
        async with db.execute(
            "SELECT id, title, year, composite_score, purge_score, imdb_rating, "
            "ali_play_count, chris_play_count, resolution, file_size_bytes, file_path "
            "FROM movies ORDER BY purge_score DESC LIMIT 5"
        ) as cur:
            top_purge = [dict(r) for r in await cur.fetchall()]

        # Recent additions (use radarr_added_at for movies, last_synced for TV)
        async with db.execute(
            "SELECT id, title, year, composite_score, resolution, radarr_added_at AS added_at, "
            "'movie' AS media_type FROM movies WHERE radarr_added_at IS NOT NULL "
            "UNION ALL "
            "SELECT id, title, year, composite_score, NULL AS resolution, last_synced AS added_at, "
            "'tv' AS media_type FROM tv_shows WHERE last_synced IS NOT NULL "
            "ORDER BY added_at DESC LIMIT 10"
        ) as cur:
            recent = [dict(r) for r in await cur.fetchall()]

        # Sync status
        async with db.execute("SELECT * FROM sync_log") as cur:
            sync_status = [dict(r) for r in await cur.fetchall()]

        return {
            'movies': {
                'total': movie_total,
                'never_watched': movie_never_watched,
                'below_5': movie_below_5,
            },
            'tv_shows': {
                'total': tv_total,
                'never_watched': tv_never_watched,
                'below_5': tv_below_5,
            },
            'storage': {'total_bytes': total_bytes, 'movies_only': True},
            'rating_histogram': {
                'movies': movie_hist,
                'tv': tv_hist,
            },
            'top_purge_candidates': top_purge,
            'recent_additions': recent,
            'sync_status': sync_status,
        }


