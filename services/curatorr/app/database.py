"""Curatorr database — aiosqlite, WAL mode, full schema."""
import aiosqlite
import logging
from pathlib import Path
from app.config import DB_PATH, BACKUP_DIR

log = logging.getLogger('curatorr.db')

CREATE_SQL = """
PRAGMA journal_mode=WAL;

CREATE TABLE IF NOT EXISTS movies (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    plex_key TEXT, radarr_id INTEGER, radarr_instance TEXT,
    tmdb_id INTEGER, imdb_id TEXT,
    title TEXT NOT NULL, sort_title TEXT, year INTEGER,
    genres TEXT,
    runtime_min INTEGER, content_rating TEXT, studio TEXT, summary TEXT,
    original_language TEXT, collection_tmdb_id INTEGER, collection_name TEXT,
    resolution TEXT, video_codec TEXT, audio_codec TEXT,
    audio_channels REAL, hdr_format TEXT,
    file_size_bytes INTEGER, file_path TEXT,
    trash_score INTEGER, quality_profile TEXT, monitored INTEGER DEFAULT 1,
    imdb_rating REAL, imdb_votes INTEGER,
    rt_critics INTEGER, rt_audience INTEGER, metacritic INTEGER,
    tmdb_rating REAL, tmdb_votes INTEGER,
    mdblist_score INTEGER, trakt_rating REAL, letterboxd_rating REAL,
    composite_score REAL, ratings_updated_at TIMESTAMP,
    ali_play_count INTEGER DEFAULT 0, ali_last_watched TIMESTAMP, ali_total_watch_sec INTEGER DEFAULT 0,
    chris_play_count INTEGER DEFAULT 0, chris_last_watched TIMESTAMP, chris_total_watch_sec INTEGER DEFAULT 0,
    purge_score INTEGER DEFAULT 0,
    poster_url TEXT,
    plex_added_at TIMESTAMP, radarr_added_at TIMESTAMP,
    last_synced TIMESTAMP, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(radarr_id, radarr_instance)
);

CREATE TABLE IF NOT EXISTS tv_shows (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    plex_key TEXT, sonarr_id INTEGER, sonarr_instance TEXT,
    tmdb_id INTEGER, tvdb_id INTEGER, imdb_id TEXT,
    title TEXT NOT NULL, sort_title TEXT, year INTEGER,
    genres TEXT, runtime_min INTEGER, content_rating TEXT,
    network TEXT, summary TEXT, original_language TEXT,
    status TEXT,
    total_seasons INTEGER, total_episodes INTEGER,
    imdb_rating REAL, rt_critics INTEGER, metacritic INTEGER,
    tmdb_rating REAL, mdblist_score INTEGER, trakt_rating REAL,
    composite_score REAL, ratings_updated_at TIMESTAMP,
    ali_play_count INTEGER DEFAULT 0, ali_last_watched TIMESTAMP,
    chris_play_count INTEGER DEFAULT 0, chris_last_watched TIMESTAMP,
    purge_score INTEGER DEFAULT 0, season_completion_pct REAL,
    poster_url TEXT,
    monitored INTEGER DEFAULT 1,
    plex_added_at TIMESTAMP,
    last_synced TIMESTAMP, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(sonarr_id, sonarr_instance)
);

CREATE TABLE IF NOT EXISTS tv_seasons (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    show_id INTEGER REFERENCES tv_shows(id),
    season_number INTEGER, episode_count INTEGER,
    episodes_downloaded INTEGER DEFAULT 0, monitored INTEGER DEFAULT 1,
    UNIQUE(show_id, season_number)
);

CREATE TABLE IF NOT EXISTS ratings_cache (
    media_type TEXT, external_id TEXT, source TEXT,
    data TEXT,
    fetched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP,
    PRIMARY KEY (media_type, external_id, source)
);

CREATE TABLE IF NOT EXISTS collections (
    tmdb_id INTEGER PRIMARY KEY, name TEXT, poster_url TEXT,
    movie_count INTEGER, owned_count INTEGER
);

CREATE TABLE IF NOT EXISTS collection_members (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    collection_tmdb_id INTEGER,
    movie_tmdb_id INTEGER,
    title TEXT, year TEXT, poster_url TEXT,
    overview TEXT, vote_average REAL,
    UNIQUE(collection_tmdb_id, movie_tmdb_id)
);
CREATE INDEX IF NOT EXISTS idx_collection_members ON collection_members(collection_tmdb_id);

CREATE TABLE IF NOT EXISTS watch_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    source TEXT,
    user_name TEXT, media_type TEXT, plex_key TEXT,
    title TEXT, season INTEGER, episode INTEGER,
    watched_at TIMESTAMP, duration_sec INTEGER, completion_pct REAL, player TEXT,
    UNIQUE(source, user_name, plex_key, watched_at)
);

CREATE TABLE IF NOT EXISTS rules (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL, enabled INTEGER DEFAULT 1,
    media_type TEXT,
    condition_logic TEXT DEFAULT 'AND',
    conditions TEXT,
    action TEXT,
    schedule TEXT DEFAULT 'manual',
    notify INTEGER DEFAULT 1,
    last_run TIMESTAMP, last_match_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS rule_matches (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    rule_id INTEGER REFERENCES rules(id),
    media_type TEXT, media_id INTEGER, title TEXT,
    match_reason TEXT,
    action_taken TEXT, excluded_by_user INTEGER DEFAULT 0,
    matched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, acted_at TIMESTAMP
);

CREATE TABLE IF NOT EXISTS deletion_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    media_type TEXT, title TEXT, year INTEGER,
    tmdb_id INTEGER, imdb_id TEXT, file_path TEXT,
    file_size_bytes INTEGER, composite_score REAL,
    imdb_rating REAL, purge_score INTEGER,
    ali_play_count INTEGER, chris_play_count INTEGER,
    deleted_via TEXT,
    arr_delete_ok INTEGER, unraid_delete_ok INTEGER,
    deleted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS config (
    key TEXT PRIMARY KEY, value TEXT
);

CREATE TABLE IF NOT EXISTS sync_log (
    source TEXT PRIMARY KEY, last_sync TIMESTAMP,
    last_delta_sync TIMESTAMP, item_count INTEGER,
    status TEXT, error_msg TEXT
);

CREATE INDEX IF NOT EXISTS idx_movies_tmdb ON movies(tmdb_id);
CREATE INDEX IF NOT EXISTS idx_movies_imdb ON movies(imdb_id);
CREATE INDEX IF NOT EXISTS idx_movies_title ON movies(sort_title);
CREATE INDEX IF NOT EXISTS idx_movies_purge ON movies(purge_score DESC);
CREATE INDEX IF NOT EXISTS idx_movies_composite ON movies(composite_score);
CREATE INDEX IF NOT EXISTS idx_tv_tmdb ON tv_shows(tmdb_id);
CREATE INDEX IF NOT EXISTS idx_tv_title ON tv_shows(sort_title);
CREATE INDEX IF NOT EXISTS idx_watch_history_plex ON watch_history(plex_key);
CREATE INDEX IF NOT EXISTS idx_movies_imdb_rating ON movies(imdb_rating);
CREATE INDEX IF NOT EXISTS idx_movies_ratings_updated ON movies(ratings_updated_at);
CREATE INDEX IF NOT EXISTS idx_tv_shows_status ON tv_shows(status);
CREATE INDEX IF NOT EXISTS idx_tv_shows_ratings_updated ON tv_shows(ratings_updated_at);
CREATE INDEX IF NOT EXISTS idx_tv_shows_composite_score ON tv_shows(composite_score);
CREATE INDEX IF NOT EXISTS idx_watch_history_media ON watch_history(media_type, plex_key);
CREATE INDEX IF NOT EXISTS idx_ratings_cache_lookup ON ratings_cache(media_type, external_id, source);
CREATE INDEX IF NOT EXISTS idx_movies_monitored ON movies(monitored);
CREATE INDEX IF NOT EXISTS idx_movies_resolution ON movies(resolution);
CREATE INDEX IF NOT EXISTS idx_movies_ali_play ON movies(ali_play_count);
CREATE INDEX IF NOT EXISTS idx_movies_chris_play ON movies(chris_play_count);
CREATE INDEX IF NOT EXISTS idx_tv_ali_play ON tv_shows(ali_play_count);
CREATE INDEX IF NOT EXISTS idx_tv_chris_play ON tv_shows(chris_play_count);
CREATE INDEX IF NOT EXISTS idx_watch_history_user_ts ON watch_history(user_name, watched_at);

CREATE TABLE IF NOT EXISTS event_log (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    event_type TEXT,
    source     TEXT,
    message    TEXT,
    detail     TEXT,
    level      TEXT DEFAULT 'info',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX IF NOT EXISTS idx_event_log_type ON event_log(event_type, created_at DESC);
"""


async def _migrate_columns():
    """Add new columns to existing tables without dropping data."""
    migrations = [
        ("ALTER TABLE movies ADD COLUMN poster_url TEXT",),
        ("ALTER TABLE tv_shows ADD COLUMN poster_url TEXT",),
        ("CREATE TABLE IF NOT EXISTS collection_members (id INTEGER PRIMARY KEY AUTOINCREMENT, collection_tmdb_id INTEGER, movie_tmdb_id INTEGER, title TEXT, year TEXT, poster_url TEXT, overview TEXT, vote_average REAL, UNIQUE(collection_tmdb_id, movie_tmdb_id))",),
        ("CREATE INDEX IF NOT EXISTS idx_collection_members ON collection_members(collection_tmdb_id)",),
    ]
    async with aiosqlite.connect(DB_PATH, timeout=60) as db:
        for (sql,) in migrations:
            try:
                await db.execute(sql)
                await db.commit()
            except Exception:
                pass  # Column already exists
        # Auto-purge event_log: keep last 2000 rows
        try:
            await db.execute(
                "DELETE FROM event_log WHERE id NOT IN "
                "(SELECT id FROM event_log ORDER BY id DESC LIMIT 2000)"
            )
            await db.commit()
        except Exception:
            pass


async def init_database():
    """Initialize the database and create all tables."""
    Path(DB_PATH).parent.mkdir(parents=True, exist_ok=True)
    Path(BACKUP_DIR).mkdir(parents=True, exist_ok=True)
    async with aiosqlite.connect(DB_PATH) as db:
        await db.executescript(CREATE_SQL)
        await db.commit()
    await _migrate_columns()
    log.info(f"Database initialized at {DB_PATH}")


async def get_db():
    """Async context manager — yields an aiosqlite connection."""
    async with aiosqlite.connect(DB_PATH, timeout=60) as db:
        db.row_factory = aiosqlite.Row
        await db.execute("PRAGMA journal_mode=WAL")
        await db.execute("PRAGMA foreign_keys=ON")
        yield db


async def get_config(key: str, default: str = None) -> str | None:
    async with aiosqlite.connect(DB_PATH, timeout=60) as db:
        db.row_factory = aiosqlite.Row
        async with db.execute("SELECT value FROM config WHERE key=?", (key,)) as cur:
            row = await cur.fetchone()
            return row['value'] if row else default


async def set_config(key: str, value: str):
    async with aiosqlite.connect(DB_PATH, timeout=60) as db:
        await db.execute("INSERT OR REPLACE INTO config(key,value) VALUES(?,?)", (key, str(value)))
        await db.commit()


async def get_movie_count() -> int:
    async with aiosqlite.connect(DB_PATH) as db:
        async with db.execute("SELECT COUNT(*) FROM movies") as cur:
            row = await cur.fetchone()
            return row[0] if row else 0


async def get_tv_count() -> int:
    async with aiosqlite.connect(DB_PATH) as db:
        async with db.execute("SELECT COUNT(*) FROM tv_shows") as cur:
            row = await cur.fetchone()
            return row[0] if row else 0
