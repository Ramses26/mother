#!/usr/bin/env python3
"""
Upgraderr — Quality Upgrade Automation Service
Replacement for Huntarr. Uses TRaSH-aligned scoring to find and trigger
upgrades across all 4 Radarr/Sonarr instances.
"""

import os
import sys
import json
import time
import random
import shutil
import logging
import sqlite3
import threading
from datetime import datetime, timedelta
from functools import wraps
from pathlib import Path

import bcrypt
import jwt
import pytz
import requests
import apprise
from flask import (Flask, request, jsonify, render_template,
                   redirect, url_for, make_response, g, send_file)
from apscheduler.schedulers.background import BackgroundScheduler

# ---------------------------------------------------------------------------
# Configuration (env vars = defaults only; DB is authoritative after first run)
# ---------------------------------------------------------------------------

SECRET_KEY   = os.environ.get('UPGRADERR_SECRET_KEY', 'change-me-32-chars-xxxxxxxxxxxxxxxx')
DB_PATH      = os.environ.get('UPGRADERR_DB_PATH', '/data/upgraderr.db')
BACKUP_DIR   = os.environ.get('UPGRADERR_BACKUP_DIR', '/data/backups')
LOG_LEVEL    = os.environ.get('UPGRADERR_LOG_LEVEL', 'INFO')
DISPLAY_TZ   = os.environ.get('TZ', 'America/New_York')

# Default instance configuration from env (bootstrapped into DB on first run)
DEFAULT_INSTANCES = {
    'radarr-hd': {
        'url':     os.environ.get('RADARR_HD_URL',   'http://radarr-hd:7878'),
        'api_key': os.environ.get('RADARR_HD_API_KEY', ''),
        'type':    'radarr',
        'label':   'Radarr HD',
        'enabled': 1,
    },
    'radarr-4k': {
        'url':     os.environ.get('RADARR_4K_URL',   'http://radarr-4k:7879'),
        'api_key': os.environ.get('RADARR_4K_API_KEY', ''),
        'type':    'radarr',
        'label':   'Radarr 4K',
        'enabled': 1,
    },
    'sonarr-hd': {
        'url':     os.environ.get('SONARR_HD_URL',   'http://sonarr-hd:8989'),
        'api_key': os.environ.get('SONARR_HD_API_KEY', ''),
        'type':    'sonarr',
        'label':   'Sonarr HD',
        'enabled': 1,
    },
    'sonarr-4k': {
        'url':     os.environ.get('SONARR_4K_URL',   'http://sonarr-4k:8990'),
        'api_key': os.environ.get('SONARR_4K_API_KEY', ''),
        'type':    'sonarr',
        'label':   'Sonarr 4K',
        'enabled': 1,
    },
}

# Rate limit env defaults
SEARCHES_PER_HOUR  = int(os.environ.get('UPGRADERR_SEARCHES_PER_HOUR', '5'))
DOWNLOADS_PER_DAY  = int(os.environ.get('UPGRADERR_DOWNLOADS_PER_DAY', '10'))
COOLDOWN_HOURS     = int(os.environ.get('UPGRADERR_COOLDOWN_HOURS', '24'))
SWEEP_MINUTES      = int(os.environ.get('UPGRADERR_SWEEP_MINUTES', '30'))
JITTER_MAX         = int(os.environ.get('UPGRADERR_JITTER_MAX_SECONDS', '30'))
MIN_SCORE          = int(os.environ.get('UPGRADERR_MIN_SCORE', '200'))
SEASON_THRESHOLD       = int(os.environ.get('UPGRADERR_SEASON_THRESHOLD', '50'))
NO_SOURCE_SYNC_THRESHOLD = int(os.environ.get('UPGRADERR_NO_SOURCE_SYNC_THRESHOLD', '2'))
SYNC_WEBHOOK_URL       = os.environ.get('SYNC_WEBHOOK_URL', 'http://sync-webhook:5001')
TELEGRAM_BOT_TOKEN = os.environ.get('TELEGRAM_BOT_TOKEN', '')
UPGRADERR_TG_CHAT  = os.environ.get('UPGRADERR_TELEGRAM_CHAT_ID', '')
TMDB_BASE          = 'https://api.themoviedb.org/3'
BLURAY_WAIT_DAYS   = int(os.environ.get('UPGRADERR_BLURAY_WAIT_DAYS', '90'))
SYNC_REPORTS_DIR   = '/opt/sync_reports'
QB_URL             = os.environ.get('QBITTORRENT_URL', 'http://10.0.1.203:8080')
QB_USER            = os.environ.get('QBITTORRENT_USER', '')
QB_PASS            = os.environ.get('QBITTORRENT_PASS', '')
QB_TAG             = 'upgraderr'

JWT_ACCESS_TTL  = 3600
JWT_REFRESH_TTL = 604800

# ---------------------------------------------------------------------------
# App setup
# ---------------------------------------------------------------------------

app = Flask(__name__)
app.secret_key = SECRET_KEY

logging.basicConfig(
    level=getattr(logging, LOG_LEVEL, logging.INFO),
    format='%(asctime)s [%(levelname)s] %(name)s: %(message)s',
)
log = logging.getLogger('upgraderr')

# Persistent log file (survives container restarts)
try:
    from logging.handlers import RotatingFileHandler as _RFH
    import pathlib as _pl
    _log_dir = _pl.Path('/logs')
    _log_dir.mkdir(parents=True, exist_ok=True)
    _fh = _RFH(_log_dir / 'upgraderr.log', maxBytes=20 * 1024 * 1024, backupCount=10)
    _fh.setFormatter(logging.Formatter('%(asctime)s [%(levelname)s] %(name)s: %(message)s'))
    logging.getLogger().addHandler(_fh)
except Exception as _e:
    log.warning(f'Could not set up file logging: {_e}')

sys.path.insert(0, '/app')
try:
    from lib.quality_scoring import parse_quality_from_filename, calculate_quality_score
    log.info("Quality scoring library loaded OK")
except ImportError as e:
    log.warning(f"Could not load quality_scoring: {e}")
    def parse_quality_from_filename(fn):
        return {'resolution': '', 'source': '', 'hdr': '', 'audio': '', 'codec': '', 'release_group': ''}
    def calculate_quality_score(*a, **kw):
        return 0

# ---------------------------------------------------------------------------
# Timezone helpers
# ---------------------------------------------------------------------------

def get_display_tz():
    tz_name = _cfg_cache.get('display_tz', DISPLAY_TZ)
    try:
        return pytz.timezone(tz_name)
    except Exception:
        return pytz.timezone('America/New_York')

def fmt_dt(ts_str):
    """Format a UTC ISO timestamp string into local time for display."""
    if not ts_str:
        return '—'
    try:
        ts = str(ts_str)
        dt = datetime.fromisoformat(ts.replace('Z', '+00:00'))
        if dt.tzinfo is None:
            dt = pytz.utc.localize(dt)
        local = dt.astimezone(get_display_tz())
        return local.strftime('%m/%d %I:%M %p %Z')
    except Exception:
        return str(ts_str)[:16]

# ---------------------------------------------------------------------------
# Database
# ---------------------------------------------------------------------------

_db_lock = threading.Lock()

def get_db():
    """Get a thread-local SQLite connection (NOT Flask g — safe for background threads)."""
    if not hasattr(_db_local, 'conn') or _db_local.conn is None:
        _db_local.conn = sqlite3.connect(DB_PATH, check_same_thread=False)
        _db_local.conn.row_factory = sqlite3.Row
        _db_local.conn.execute("PRAGMA journal_mode=WAL")
    return _db_local.conn

_db_local = threading.local()

# Flask request-scoped db (for web routes)
def get_request_db():
    if 'db' not in g:
        g.db = sqlite3.connect(DB_PATH, check_same_thread=False)
        g.db.row_factory = sqlite3.Row
        g.db.execute("PRAGMA journal_mode=WAL")
    return g.db

@app.teardown_appcontext
def close_request_db(exc):
    db = g.pop('db', None)
    if db:
        db.close()

def init_database():
    Path(DB_PATH).parent.mkdir(parents=True, exist_ok=True)
    Path(BACKUP_DIR).mkdir(parents=True, exist_ok=True)
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA journal_mode=WAL")
    conn.executescript("""
        CREATE TABLE IF NOT EXISTS instances (
            name    TEXT PRIMARY KEY,
            url     TEXT NOT NULL,
            api_key TEXT NOT NULL,
            type    TEXT NOT NULL,
            label   TEXT NOT NULL,
            enabled INTEGER DEFAULT 1
        );
        CREATE TABLE IF NOT EXISTS upgrade_queue (
            id              INTEGER PRIMARY KEY AUTOINCREMENT,
            instance        TEXT NOT NULL,
            media_id        INTEGER NOT NULL,
            media_type      TEXT NOT NULL,
            title           TEXT,
            current_quality TEXT,
            current_score   INTEGER DEFAULT 0,
            priority_tier   INTEGER DEFAULT 6,
            upgrade_reason  TEXT,
            search_type     TEXT DEFAULT 'episode',
            season_number   INTEGER,
            search_count    INTEGER DEFAULT 0,
            bluray_date     TEXT,
            status          TEXT DEFAULT 'pending',
            searched_at     TEXT,
            cooldown_until  TEXT,
            created_at      TEXT DEFAULT (datetime('now')),
            UNIQUE(instance, media_id, media_type)
        );
        CREATE TABLE IF NOT EXISTS search_log (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            instance    TEXT,
            title       TEXT,
            trigger     TEXT,
            result      TEXT,
            tier        INTEGER,
            search_type TEXT,
            searched_at TEXT DEFAULT (datetime('now'))
        );
        CREATE TABLE IF NOT EXISTS daily_stats (
            date            TEXT PRIMARY KEY,
            searches_total  INTEGER DEFAULT 0,
            upgrades_found  INTEGER DEFAULT 0,
            gb_upgraded     REAL DEFAULT 0
        );
        CREATE TABLE IF NOT EXISTS config (
            key   TEXT PRIMARY KEY,
            value TEXT
        );
        CREATE TABLE IF NOT EXISTS upgrade_history (
            id             INTEGER PRIMARY KEY AUTOINCREMENT,
            instance       TEXT NOT NULL,
            media_id       INTEGER NOT NULL,
            media_type     TEXT NOT NULL,
            title          TEXT,
            before_quality TEXT,
            before_score   INTEGER,
            after_quality  TEXT,
            after_score    INTEGER,
            tier           INTEGER,
            imported_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
        CREATE TABLE IF NOT EXISTS tmdb_cache (
            tmdb_id          INTEGER PRIMARY KEY,
            physical_release TEXT,
            streaming_only   INTEGER DEFAULT 0,
            checked_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
    """)
    conn.commit()

    # Migrate upgrade_queue: add before_quality, before_score columns if missing
    for col, coldef in [('before_quality', 'TEXT'), ('before_score', 'INTEGER')]:
        try:
            conn.execute(f"ALTER TABLE upgrade_queue ADD COLUMN {col} {coldef}")
            conn.commit()
        except Exception:
            pass  # Column already exists

    # Bootstrap instances from env if table is empty
    existing = conn.execute("SELECT COUNT(*) FROM instances").fetchone()[0]
    if existing == 0:
        for name, data in DEFAULT_INSTANCES.items():
            conn.execute(
                "INSERT OR IGNORE INTO instances(name,url,api_key,type,label,enabled) VALUES(?,?,?,?,?,?)",
                (name, data['url'], data['api_key'], data['type'], data['label'], data['enabled'])
            )
        conn.commit()
        log.info("Bootstrapped instances from environment variables")

    conn.close()
    log.info(f"Database initialized at {DB_PATH}")

# ---------------------------------------------------------------------------
# Config cache (avoids repeated DB reads in tight loops)
# ---------------------------------------------------------------------------

_cfg_cache = {}
_cfg_lock  = threading.Lock()

def _reload_config():
    db = get_db()
    with _cfg_lock:
        _cfg_cache.clear()
        for row in db.execute("SELECT key, value FROM config"):
            _cfg_cache[row['key']] = row['value']

def get_cfg(key, default=None):
    return _cfg_cache.get(key, default)

def set_cfg(key, value):
    db = get_db()
    with _db_lock:
        db.execute("INSERT OR REPLACE INTO config(key,value) VALUES(?,?)", (key, str(value)))
        db.commit()
    with _cfg_lock:
        _cfg_cache[key] = str(value)

# Request-scoped versions (for web handlers)
def get_config(key, default=None):
    db = get_request_db()
    row = db.execute("SELECT value FROM config WHERE key=?", (key,)).fetchone()
    return row['value'] if row else default

def set_config(key, value):
    db = get_request_db()
    db.execute("INSERT OR REPLACE INTO config(key,value) VALUES(?,?)", (key, str(value)))
    db.commit()
    with _cfg_lock:
        _cfg_cache[key] = str(value)

# ---------------------------------------------------------------------------
# Instance management
# ---------------------------------------------------------------------------

def get_instances_from_db():
    """Return dict of instances from DB (authoritative source)."""
    db = get_db()
    rows = db.execute("SELECT * FROM instances").fetchall()
    return {row['name']: dict(row) for row in rows}

def get_instances_request():
    """Return instances dict using request-scoped DB."""
    db = get_request_db()
    rows = db.execute("SELECT * FROM instances").fetchall()
    return {row['name']: dict(row) for row in rows}

# ---------------------------------------------------------------------------
# Auth
# ---------------------------------------------------------------------------

def hash_password(plain):
    return bcrypt.hashpw(plain.encode(), bcrypt.gensalt()).decode()

def check_password(plain, hashed):
    return bcrypt.checkpw(plain.encode(), hashed.encode())

def make_access_token():
    return jwt.encode({
        'sub': 'admin', 'type': 'access',
        'exp': datetime.utcnow() + timedelta(seconds=JWT_ACCESS_TTL),
        'iat': datetime.utcnow(),
    }, SECRET_KEY, algorithm='HS256')

def make_refresh_token():
    return jwt.encode({
        'sub': 'admin', 'type': 'refresh',
        'exp': datetime.utcnow() + timedelta(seconds=JWT_REFRESH_TTL),
        'iat': datetime.utcnow(),
    }, SECRET_KEY, algorithm='HS256')

def verify_token(token, token_type='access'):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=['HS256'])
        return payload if payload.get('type') == token_type else None
    except jwt.InvalidTokenError:
        return None

def get_token():
    auth = request.headers.get('Authorization', '')
    if auth.startswith('Bearer '):
        return auth[7:]
    return request.cookies.get('access_token')

def require_auth(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = get_token()
        if token and verify_token(token, 'access'):
            return f(*args, **kwargs)
        refresh = request.cookies.get('refresh_token')
        if refresh and verify_token(refresh, 'refresh'):
            new_token = make_access_token()
            resp = make_response(f(*args, **kwargs))
            resp.set_cookie('access_token', new_token, httponly=True,
                            samesite='Lax', max_age=JWT_ACCESS_TTL)
            return resp
        if request.path.startswith('/api/'):
            return jsonify({'error': 'Unauthorized'}), 401
        return redirect(url_for('login_page'))
    return decorated

_login_attempts = {}
_login_lock = threading.Lock()

def check_login_rate(ip):
    with _login_lock:
        now = time.time()
        attempts = [t for t in _login_attempts.get(ip, []) if now - t < 60]
        if len(attempts) >= 5:
            return False
        attempts.append(now)
        _login_attempts[ip] = attempts
        return True

# ---------------------------------------------------------------------------
# Notifications
# ---------------------------------------------------------------------------

# Notification category keys (stored in config table)
NOTIFY_KEYS = {
    'notify_each_search':   ('Each individual search triggered',       'false'),  # Very noisy — off by default
    'notify_sweep_summary': ('Sweep complete summary',                 'true'),
    'notify_pause_resume':  ('Pause / Resume events',                  'true'),
    'notify_errors':        ('Errors (instance unreachable, etc.)',    'true'),
}

def _notify_enabled(category):
    default = NOTIFY_KEYS.get(category, ('', 'true'))[1]
    return get_cfg(category, default) == 'true'

def send_telegram(message, category='notify_sweep_summary'):
    if not TELEGRAM_BOT_TOKEN or not UPGRADERR_TG_CHAT:
        return
    if not _notify_enabled(category):
        return
    try:
        ap = apprise.Apprise()
        ap.add(f"tgram://{TELEGRAM_BOT_TOKEN}/{UPGRADERR_TG_CHAT}")
        ap.notify(body=message)
    except Exception as e:
        log.error(f"Telegram failed: {e}")

# ---------------------------------------------------------------------------
# qBittorrent helper
# ---------------------------------------------------------------------------

_QB_CIRCUIT_KEY = 'qbt_circuit_open_until'
_QB_CIRCUIT_MINUTES = 90  # back off for 90 min after a ban/failure

def _qb_tag_torrent(infohash: str, tag: str = QB_TAG) -> bool:
    """Login to qBittorrent and add a tag to the torrent identified by infohash."""
    if not QB_USER or not infohash:
        return False

    # Circuit breaker: stop hammering qBit if it recently banned or rejected us
    circuit_until = get_config(_QB_CIRCUIT_KEY, '')
    if circuit_until and datetime.utcnow().isoformat() < circuit_until:
        log.debug(f"[qbt] circuit open until {circuit_until}, skipping tag")
        return False

    try:
        s = requests.Session()
        r = s.post(f"{QB_URL}/api/v2/auth/login",
                   data={'username': QB_USER, 'password': QB_PASS}, timeout=10)
        resp = r.text.strip()
        if resp not in ('Ok.', 'Ok'):
            log.warning(f"[qbt] login failed: {resp!r}")
            # Open circuit: don't retry for 90 min
            open_until = (datetime.utcnow() + timedelta(minutes=_QB_CIRCUIT_MINUTES)).isoformat()
            set_config(_QB_CIRCUIT_KEY, open_until)
            return False

        # Successful login — clear any open circuit
        set_config(_QB_CIRCUIT_KEY, '')

        r2 = s.post(f"{QB_URL}/api/v2/torrents/addTags",
                    data={'hashes': infohash.lower(), 'tags': tag}, timeout=10)
        r2.raise_for_status()
        log.info(f"[qbt] tagged {infohash[:8]}… with '{tag}'")
        return True
    except Exception as e:
        log.warning(f"[qbt] tag failed for {infohash}: {e}")
        return False

# ---------------------------------------------------------------------------
# *arr API Client
# ---------------------------------------------------------------------------

def arr_get(inst, path, params=None, timeout=30):
    url = f"{inst['url']}/api/v3{path}"
    try:
        r = requests.get(url, headers={'X-Api-Key': inst['api_key']},
                         params=params, timeout=timeout)
        r.raise_for_status()
        return r.json()
    except Exception as e:
        log.error(f"[{inst.get('name', '?')}] GET {path}: {e}")
        return None

def arr_post(inst, path, data, timeout=30):
    url = f"{inst['url']}/api/v3{path}"
    try:
        r = requests.post(url, headers={'X-Api-Key': inst['api_key'],
                          'Content-Type': 'application/json'},
                          json=data, timeout=timeout)
        r.raise_for_status()
        return r.json()
    except Exception as e:
        log.error(f"[{inst.get('name', '?')}] POST {path}: {e}")
        return None

def arr_put(inst, path, data, timeout=30):
    url = f"{inst['url']}/api/v3{path}"
    try:
        r = requests.put(url, headers={'X-Api-Key': inst['api_key'],
                         'Content-Type': 'application/json'},
                         json=data, timeout=timeout)
        r.raise_for_status()
        return r.json()
    except Exception as e:
        log.error(f"[{inst.get('name', '?')}] PUT {path}: {e}")
        return None

def test_instance_connection(inst):
    """Test connectivity. Returns (ok: bool, message: str)."""
    if not inst.get('url') or not inst.get('api_key'):
        return False, "URL or API key missing"
    data = arr_get(inst, '/system/status')
    if data:
        version = data.get('version', '?')
        return True, f"Connected — {inst['type'].capitalize()} v{version}"
    return False, "Connection failed — check URL and API key"

def get_queue_ids(inst):
    data = arr_get(inst, '/queue', params={'pageSize': 500})
    if not data:
        return set()
    records = data.get('records', []) if isinstance(data, dict) else data
    ids = set()
    for r in records:
        mid = r.get('movieId') if inst['type'] == 'radarr' else r.get('seriesId')
        if mid:
            ids.add(mid)
    return ids

# ---------------------------------------------------------------------------
# Quality tier classification
# ---------------------------------------------------------------------------

SURROUND_AUDIO = {
    'TrueHD Atmos', 'Atmos', 'TrueHD', 'DTS-HD MA', 'DTS-HD',
    'DTS:X', 'DTSX', 'DTS', 'DD+', 'EAC3',
}

def get_pre_era_skip_tier5(year):
    return year is not None and year < 1992

def classify_tiers(filename, year=None, is_4k=False, media_type='movie', tmdb_id=None, web_source=False):
    if not filename:
        return []
    tiers = []
    fn_lower = filename.lower()
    ext = Path(filename).suffix.lower()

    if ext == '.m2ts':
        tiers.append((1, 'tier1_m2ts'))
        return tiers

    if ext in ('.avi', '.mp4', '.ts', '.wmv', '.m4v', '.divx', '.xvid'):
        tiers.append((2, 'tier2_container'))

    q = parse_quality_from_filename(filename)
    resolution = q.get('resolution', '')
    source     = q.get('source', '')
    audio      = q.get('audio', '')
    hdr        = q.get('hdr', '')
    codec      = q.get('codec', '')

    if resolution in ('720p', '480p'):
        tiers.append((3, 'tier3_720p'))

    # Tier 4: WEB-DL/WEBRip with BluRay now available
    detected_web = web_source or any(
        t in fn_lower for t in ('webdl', 'webrip', 'web-dl', 'web-rip')
    )
    if tmdb_id and detected_web:
        physical_date, streaming_only = _tmdb_get_physical_release(tmdb_id)
        if physical_date and not streaming_only:
            try:
                phys_dt = datetime.strptime(physical_date, '%Y-%m-%d')
                if (datetime.utcnow() - phys_dt).days >= BLURAY_WAIT_DAYS:
                    tiers.append((4, 'tier4_bluray'))
            except Exception:
                pass

    if not get_pre_era_skip_tier5(year):
        import re
        # True if filename explicitly shows multi-channel audio (5.1, 6.1, 7.1, 7.2)
        has_surround_channels = bool(re.search(r'\b(5\.1|6\.1|7\.1|7\.2)\b', fn_lower))
        if audio in SURROUND_AUDIO:
            pass  # confirmed surround codec
        elif audio == 'DD' and has_surround_channels:
            pass  # AC3/DD with explicit 5.1+ channels in filename — is surround
        elif audio:
            # DD without explicit surround channels (AC3 2.0, bare DD), AAC, etc.
            tiers.append((5, 'tier5_audio'))
        elif not has_surround_channels and not re.search(
                r'\b(atmos|truehd|dts|dd\+|eac3)\b', fn_lower):
            tiers.append((5, 'tier5_audio'))

    score = calculate_quality_score(
        resolution=resolution or 'Unknown', source=source or 'Unknown',
        hdr=hdr or '', audio=audio or '', codec=codec or '',
        size_gb=0, is_4k=is_4k, media_type=media_type,
    )
    if score < int(get_cfg('min_score', str(MIN_SCORE))):
        tiers.append((6, 'tier6_score'))

    return tiers

def get_current_score(filename, is_4k=False, media_type='movie'):
    q = parse_quality_from_filename(filename or '')
    return calculate_quality_score(
        resolution=q.get('resolution', 'Unknown'),
        source=q.get('source', 'Unknown'),
        hdr=q.get('hdr', ''), audio=q.get('audio', ''),
        codec=q.get('codec', ''), size_gb=0,
        is_4k=is_4k, media_type=media_type,
    )

# ---------------------------------------------------------------------------
# TMDB helpers (Tier 4 — BluRay release detection)
# ---------------------------------------------------------------------------

def _tmdb_api_key():
    return get_cfg('tmdb_api_key', os.getenv('TMDB_API_KEY', ''))

def _tmdb_get_physical_release(tmdb_id: int) -> tuple:
    """Returns (physical_release_date_str_or_None, streaming_only_bool).
    Checks cache first (valid for 7 days). Queries TMDB if stale/missing."""
    db = get_db()
    row = db.execute(
        "SELECT physical_release, streaming_only, checked_at FROM tmdb_cache WHERE tmdb_id=?",
        (tmdb_id,)
    ).fetchone()
    if row:
        checked = row['checked_at']
        if isinstance(checked, str):
            try:
                checked_dt = datetime.fromisoformat(checked)
            except Exception:
                checked_dt = datetime.utcnow() - timedelta(days=8)
        else:
            checked_dt = checked
        if (datetime.utcnow() - checked_dt).days < 7:
            return row['physical_release'], bool(row['streaming_only'])

    api_key = _tmdb_api_key()
    if not api_key:
        return None, False

    try:
        url = f"{TMDB_BASE}/movie/{tmdb_id}/release_dates?api_key={api_key}"
        r = requests.get(url, timeout=10)
        if not r.ok:
            return None, False
        data = r.json()
        results = data.get('results', [])

        has_any_release = len(results) > 0
        type5_dates = []
        for country in results:
            for rel in country.get('release_dates', []):
                if rel.get('type') == 5 and rel.get('release_date'):
                    date_str = rel['release_date'][:10]
                    type5_dates.append(date_str)

        if type5_dates:
            physical_date = min(type5_dates)
            streaming_only = False
        else:
            streaming_only = has_any_release
            physical_date = None

        db.execute(
            "INSERT OR REPLACE INTO tmdb_cache (tmdb_id, physical_release, streaming_only, checked_at) VALUES (?,?,?,?)",
            (tmdb_id, physical_date, 1 if streaming_only else 0, datetime.utcnow().isoformat())
        )
        db.commit()
        return physical_date, streaming_only
    except Exception as e:
        log.warning(f"TMDB lookup failed for {tmdb_id}: {e}")
        return None, False

def _scan_tmdb_releases():
    """Daily job: pre-warm TMDB cache for all WEB-DL/WEBRip movies."""
    log.info("[tmdb_scan] Starting TMDB release date pre-fetch")
    instances = get_instances_from_db()
    count = 0
    for inst_name, inst in instances.items():
        if not inst.get('enabled') or inst.get('type') != 'radarr':
            continue
        inst['name'] = inst_name
        movies = arr_get(inst, '/movie') or []
        for movie in movies:
            mfile = movie.get('movieFile')
            if not mfile:
                continue
            fn = mfile.get('relativePath', '') or mfile.get('path', '')
            fn_lower = fn.lower()
            if not any(t in fn_lower for t in ('webdl', 'webrip', 'web-dl', 'web-rip')):
                continue
            tmdb_id = movie.get('tmdbId')
            if not tmdb_id:
                continue
            _tmdb_get_physical_release(tmdb_id)
            count += 1
    log.info(f"[tmdb_scan] Pre-fetched TMDB data for {count} WEB-DL movies")

# ---------------------------------------------------------------------------
# Bandwidth-aware sweep guard
# ---------------------------------------------------------------------------

def _sync_is_active() -> bool:
    """Returns True if batch sync is actively writing progress (within last 2 minutes)."""
    import glob as _glob
    import time as _time
    try:
        pattern = os.path.join(SYNC_REPORTS_DIR, 'sync_progress_*.log')
        files = _glob.glob(pattern)
        if not files:
            return False
        newest = max(files, key=os.path.getmtime)
        age_seconds = _time.time() - os.path.getmtime(newest)
        return age_seconds < 120
    except Exception:
        return False

# ---------------------------------------------------------------------------
# Sweep rate limiting — in-memory counter (reliable, no DB-read race conditions)
# ---------------------------------------------------------------------------

class SweepBudget:
    """Tracks per-instance and global search budgets for one sweep run."""
    def __init__(self, per_instance_limit, global_limit):
        self._per = {}
        self._per_limit = per_instance_limit
        self._total = 0
        self._global_limit = global_limit
        self._lock = threading.Lock()

    def can_search(self, instance_name):
        with self._lock:
            return (self._total < self._global_limit and
                    self._per.get(instance_name, 0) < self._per_limit)

    def record(self, instance_name):
        with self._lock:
            self._per[instance_name] = self._per.get(instance_name, 0) + 1
            self._total += 1

    @property
    def total(self):
        return self._total

# ---------------------------------------------------------------------------
# DB helpers for sweep (use thread-local connection, not Flask g)
# ---------------------------------------------------------------------------

def _db_log_search(instance, title, trigger, result, tier, search_type):
    db = get_db()
    with _db_lock:
        db.execute(
            "INSERT INTO search_log(instance,title,trigger,result,tier,search_type) VALUES(?,?,?,?,?,?)",
            (instance, title, trigger, result, tier, search_type)
        )
        db.commit()

def _db_increment_daily(searches=0, upgrades=0):
    today = datetime.utcnow().strftime('%Y-%m-%d')
    db = get_db()
    with _db_lock:
        db.execute(
            """INSERT INTO daily_stats(date,searches_total,upgrades_found)
               VALUES(?,?,?)
               ON CONFLICT(date) DO UPDATE SET
                 searches_total=searches_total+excluded.searches_total,
                 upgrades_found=upgrades_found+excluded.upgrades_found""",
            (today, searches, upgrades)
        )
        db.commit()

def _db_upsert_queue(instance, media_id, media_type, title, score, tier, reason, search_type,
                     season=None, current_filename=None):
    db = get_db()
    with _db_lock:
        # Only set before_quality/before_score on INSERT (first time), not on subsequent sweeps.
        # Preserve 'searching'/'found' status — only reset to 'pending' if currently pending/new.
        db.execute(
            """INSERT INTO upgrade_queue
               (instance,media_id,media_type,title,current_score,priority_tier,upgrade_reason,
                search_type,season_number,before_quality,before_score)
               VALUES(?,?,?,?,?,?,?,?,?,?,?)
               ON CONFLICT(instance,media_id,media_type) DO UPDATE SET
                 title=excluded.title, current_score=excluded.current_score,
                 priority_tier=excluded.priority_tier, upgrade_reason=excluded.upgrade_reason,
                 search_type=excluded.search_type,
                 status=CASE WHEN upgrade_queue.status IN ('searching','found')
                             THEN upgrade_queue.status ELSE 'pending' END""",
            (instance, media_id, media_type, title, score, tier, reason, search_type, season,
             current_filename, score)
        )
        db.commit()

def _db_mark_searching(instance, media_id, media_type, search_count, cooldown_until):
    db = get_db()
    with _db_lock:
        db.execute(
            """UPDATE upgrade_queue SET status='searching',
               searched_at=datetime('now'), search_count=?, cooldown_until=?
               WHERE instance=? AND media_id=? AND media_type=?""",
            (search_count, cooldown_until, instance, media_id, media_type)
        )
        db.commit()

def _db_get_queue_entry(instance, media_id, media_type):
    db = get_db()
    return db.execute(
        "SELECT search_count, cooldown_until, status FROM upgrade_queue "
        "WHERE instance=? AND media_id=? AND media_type=?",
        (instance, media_id, media_type)
    ).fetchone()

def _adaptive_cooldown(search_count):
    if search_count <= 1: return int(get_cfg('cooldown_hours', str(COOLDOWN_HOURS)))
    if search_count == 2: return 7 * 24
    if search_count == 3: return 14 * 24
    return 30 * 24

# ---------------------------------------------------------------------------
# Core sweep
# ---------------------------------------------------------------------------

_sweep_lock = threading.Lock()

def do_sweep(trigger='scheduled'):
    if not _sweep_lock.acquire(blocking=False):
        log.info("Sweep already running, skipping")
        return
    try:
        _run_sweep(trigger)
    finally:
        _sweep_lock.release()

def _cleanup_stale_queue(inst):
    """Remove queue entries for movies/seasons that no longer qualify for any tier.
    Called for disabled instances so stale entries don't linger indefinitely."""
    inst_name = inst['name']
    inst_type = inst.get('type', 'radarr')
    db = get_db()

    if inst_type == 'radarr':
        pending = db.execute(
            "SELECT media_id FROM upgrade_queue WHERE instance=? AND media_type='movie' AND status IN ('pending','searching')",
            (inst_name,)
        ).fetchall()
        is_4k = '4k' in inst_name.lower()
        removed = 0
        for row in pending:
            mid = row['media_id'] if isinstance(row, sqlite3.Row) else row[0]
            movie = arr_get(inst, f'/movie/{mid}')
            if not movie:
                continue
            mfile = movie.get('movieFile')
            if not mfile:
                continue
            filename = mfile.get('relativePath', '') or mfile.get('path', '')
            year = movie.get('year')
            tmdb_id = movie.get('tmdbId')
            tiers = classify_tiers(filename, year=year, is_4k=is_4k, media_type='movie', tmdb_id=tmdb_id)
            if not tiers:
                with _db_lock:
                    db.execute("DELETE FROM upgrade_queue WHERE instance=? AND media_id=? AND media_type='movie'",
                               (inst_name, mid))
                    db.commit()
                removed += 1
        if removed:
            log.info(f"[{inst_name}] Stale queue cleanup: removed {removed} resolved entries")
    # Sonarr cleanup is handled per-series during the enabled sweep; skip here for performance


def _run_sweep(trigger):
    if _sync_is_active():
        log.info("Batch sync is active — deferring sweep to avoid conflicts")
        return

    _reload_config()

    # Check daily search cap before doing any work
    max_per_day = int(get_cfg('max_searches_per_day', '0'))
    if max_per_day > 0:
        today = datetime.utcnow().strftime('%Y-%m-%d')
        db = get_db()
        done_today = db.execute(
            "SELECT COALESCE(searches_total,0) FROM daily_stats WHERE date=?", (today,)
        ).fetchone()
        searches_done = done_today[0] if done_today else 0
        if searches_done >= max_per_day:
            log.info(f"Daily search cap reached ({searches_done}/{max_per_day}) — skipping sweep")
            return

    per_inst  = int(get_cfg('searches_per_hour', str(SEARCHES_PER_HOUR)))
    global_lim = int(get_cfg('downloads_per_day', str(DOWNLOADS_PER_DAY)))
    budget    = SweepBudget(per_instance_limit=per_inst, global_limit=global_lim)
    tier_counts = {}

    instances = get_instances_from_db()
    for inst_name, inst in instances.items():
        if not inst.get('api_key'):
            log.debug(f"[{inst_name}] no API key, skipping")
            continue
        inst['name'] = inst_name
        if inst['enabled']:
            try:
                if inst['type'] == 'radarr':
                    _sweep_radarr(inst, budget, trigger, tier_counts)
                else:
                    _sweep_sonarr(inst, budget, trigger, tier_counts)
            except Exception as e:
                log.error(f"[{inst_name}] Sweep error: {e}", exc_info=True)
        else:
            # Disabled instances: still clean up stale queue entries
            try:
                _cleanup_stale_queue(inst)
            except Exception as e:
                log.debug(f"[{inst_name}] Stale cleanup error: {e}")

    if budget.total > 0:
        tier_summary = ', '.join(f"T{k}:{v}" for k, v in sorted(tier_counts.items()) if v > 0)
        send_telegram(
            f"Upgraderr sweep complete: {budget.total} searches triggered ({tier_summary})"
        )
    log.info(f"Sweep done: {budget.total} searches triggered across all instances")


def _is_paused():
    return get_cfg('paused', 'false') == 'true'

def _tier_enabled(t):
    return get_cfg(f'tier_enabled_{t}', 'true') == 'true'


def _trigger_fallback_sync(container_path: str, title: str, media_type: str, quality: str = 'unknown'):
    """Queue a sync of the current (pre-upgrade) file when no upgrade has been found
    after no_source_sync_threshold searches. Fires async so the sweep is not blocked."""
    url = f"{SYNC_WEBHOOK_URL}/sync/manual"
    payload = {'path': container_path, 'type': media_type, 'title': title, 'quality': quality}
    def _post():
        try:
            r = requests.post(url, json=payload, timeout=15)
            log.info(f"[fallback-sync] Queued {title} ({container_path}) — {r.status_code}")
        except Exception as exc:
            log.warning(f"[fallback-sync] Failed to queue {title}: {exc}")
    threading.Thread(target=_post, daemon=True).start()


def _sweep_radarr(inst, budget, trigger, tier_counts):
    inst_name = inst['name']
    movies = arr_get(inst, '/movie') or []
    queue_ids = get_queue_ids(inst)
    is_4k = '4k' in inst_name.lower()

    all_tags = {t['id']: t['label'].lower() for t in (arr_get(inst, '/tag') or [])}
    skip_tag_ids = {tid for tid, lbl in all_tags.items() if lbl in ('upgraderr-skip', 'upgraderr-no-source')}

    random.shuffle(movies)

    for movie in movies:
        if not budget.can_search(inst_name) and not _is_paused():
            log.debug(f"[{inst_name}] Budget exhausted, stopping")
            break

        mid   = movie.get('id')
        title = movie.get('title', 'Unknown')
        year  = movie.get('year')
        mfile = movie.get('movieFile')

        if not movie.get('monitored') or not mfile or mid in queue_ids:
            continue
        if set(movie.get('tags', [])) & skip_tag_ids:
            continue

        filename = mfile.get('relativePath', '') or mfile.get('path', '')
        tmdb_id = movie.get('tmdbId')
        tiers = classify_tiers(filename, year=year, is_4k=is_4k, media_type='movie', tmdb_id=tmdb_id)
        tiers = [(t, r) for (t, r) in tiers if _tier_enabled(t)]
        if not tiers:
            row = _db_get_queue_entry(inst_name, mid, 'movie')
            if row and row['status'] in ('pending', 'searching'):
                db = get_db()
                with _db_lock:
                    db.execute("DELETE FROM upgrade_queue WHERE instance=? AND media_id=? AND media_type='movie'",
                               (inst_name, mid))
                    db.commit()
                log.debug(f"[{inst_name}] Cleared resolved queue entry: {title}")
            continue

        top_tier, top_reason = min(tiers, key=lambda x: x[0])
        score = get_current_score(filename, is_4k=is_4k, media_type='movie')
        full_title = f"{title} ({year})"

        row = _db_get_queue_entry(inst_name, mid, 'movie')
        if row and row['status'] == 'found':
            continue
        if row and row['cooldown_until']:
            if datetime.utcnow().isoformat() < row['cooldown_until']:
                continue

        _db_upsert_queue(inst_name, mid, 'movie', full_title, score, top_tier, top_reason, 'movie',
                         current_filename=filename)

        if _is_paused():
            continue

        jitter = random.randint(0, min(JITTER_MAX, 10))
        if jitter:
            time.sleep(jitter)

        result = arr_post(inst, '/command', {'name': 'MoviesSearch', 'movieIds': [mid]})
        search_count = (row['search_count'] if row else 0) + 1
        cooldown_h   = _adaptive_cooldown(search_count)
        cooldown_until = (datetime.utcnow() + timedelta(hours=cooldown_h)).isoformat()

        _db_mark_searching(inst_name, mid, 'movie', search_count, cooldown_until)

        # After N failed searches, sync current quality so Ali isn't permanently missing content
        threshold = int(get_cfg('no_source_sync_threshold', str(NO_SOURCE_SYNC_THRESHOLD)))
        if search_count >= threshold and top_tier == 3:
            movie_path = movie.get('path', '')
            if movie_path:
                _trigger_fallback_sync(movie_path, full_title, 'movie', score)
                send_telegram(
                    f"📦 Upgraderr: Syncing current quality for {full_title} "
                    f"(no upgrade after {search_count} searches) | {inst_name}",
                    category='notify_each_search'
                )

        if result:
            budget.record(inst_name)
            tier_counts[top_tier] = tier_counts.get(top_tier, 0) + 1
            _db_log_search(inst_name, full_title, trigger, 'triggered', top_tier, 'movie')
            _db_increment_daily(searches=1)
            log.info(f"[{inst_name}] Search triggered: {full_title} — Tier {top_tier}")
            send_telegram(
                f"🔍 Upgraderr: Searching {full_title} "
                f"(Tier {top_tier} — {top_reason.replace('_',' ')}) | {inst_name}",
                category='notify_each_search'
            )
        else:
            _db_log_search(inst_name, full_title, trigger, 'error', top_tier, 'movie')


def _sweep_sonarr(inst, budget, trigger, tier_counts):
    inst_name = inst['name']
    is_4k = '4k' in inst_name.lower()
    series_list = arr_get(inst, '/series') or []
    queue_ids   = get_queue_ids(inst)

    all_tags = {t['id']: t['label'].lower() for t in (arr_get(inst, '/tag') or [])}
    skip_tag_ids = {tid for tid, lbl in all_tags.items() if lbl in ('upgraderr-skip',)}

    random.shuffle(series_list)
    season_threshold = int(get_cfg('season_threshold', str(SEASON_THRESHOLD)))

    for series in series_list:
        if not budget.can_search(inst_name) and not _is_paused():
            break

        sid   = series.get('id')
        stitle = series.get('title', 'Unknown')
        year  = series.get('year')

        if not series.get('monitored') or sid in queue_ids:
            continue
        if set(series.get('tags', [])) & skip_tag_ids:
            continue

        episodes = arr_get(inst, '/episode',
                           params={'seriesId': sid, 'includeEpisodeFile': True}) or []

        # Group upgradeable episodes by season
        seasons = {}
        for ep in episodes:
            if not ep.get('monitored') or ep.get('seasonNumber', 0) == 0:
                continue
            epfile = ep.get('episodeFile')
            if not epfile:
                continue
            snum = ep['seasonNumber']
            fn   = epfile.get('relativePath', '') or epfile.get('path', '')
            tiers = classify_tiers(fn, year=year, is_4k=is_4k, media_type='tv')
            tiers = [(t, r) for (t, r) in tiers if _tier_enabled(t)]
            if not tiers:
                continue
            top_tier, top_reason = min(tiers, key=lambda x: x[0])
            if snum not in seasons:
                seasons[snum] = {'eps': [], 'top_tier': top_tier, 'top_reason': top_reason, 'fn': fn}
            seasons[snum]['eps'].append({'ep_id': ep['id']})
            if top_tier < seasons[snum]['top_tier']:
                seasons[snum]['top_tier'] = top_tier
                seasons[snum]['top_reason'] = top_reason

        # Clean up stale season entries for this series (seasons that no longer qualify)
        db = get_db()
        stale_rows = db.execute(
            "SELECT media_id FROM upgrade_queue WHERE instance=? AND media_id BETWEEN ? AND ? "
            "AND media_type='season' AND status IN ('pending','searching')",
            (inst_name, sid * 10000 + 1, sid * 10000 + 9999)
        ).fetchall()
        for stale_row in stale_rows:
            snum_queued = stale_row['media_id'] % 10000
            if snum_queued not in seasons:
                with _db_lock:
                    db.execute("DELETE FROM upgrade_queue WHERE instance=? AND media_id=? AND media_type='season'",
                               (inst_name, stale_row['media_id']))
                    db.commit()
                log.debug(f"[{inst_name}] Cleared resolved queue entry: {stitle} S{snum_queued:02d}")

        for snum, sdata in seasons.items():
            if not budget.can_search(inst_name) and not _is_paused():
                break

            # Get total monitored eps in season for threshold calc
            all_eps_in_season = arr_get(inst, '/episode',
                                        params={'seriesId': sid, 'seasonNumber': snum}) or []
            monitored_count = sum(
                1 for e in all_eps_in_season
                if e.get('monitored') and e.get('seasonNumber', 0) != 0
            )
            if monitored_count == 0:
                continue

            n_upgrade = len(sdata['eps'])
            upgrade_pct = n_upgrade / monitored_count * 100
            top_tier   = sdata['top_tier']
            top_reason = sdata['top_reason']

            use_season_search = upgrade_pct >= season_threshold
            search_type = 'season' if use_season_search else 'episode'
            title = f"{stitle} S{snum:02d}"

            # Composite key: seriesId * 10000 + seasonNumber
            composite_id = sid * 10000 + snum
            row = _db_get_queue_entry(inst_name, composite_id, 'season')
            if row and row['status'] == 'found':
                continue
            if row and row['cooldown_until']:
                if datetime.utcnow().isoformat() < row['cooldown_until']:
                    continue

            score = get_current_score(sdata['fn'], is_4k=is_4k, media_type='tv')
            _db_upsert_queue(inst_name, composite_id, 'season', title, score,
                             top_tier, top_reason, search_type, snum,
                             current_filename=sdata['fn'])

            if _is_paused():
                continue

            jitter = random.randint(0, min(JITTER_MAX, 10))
            if jitter:
                time.sleep(jitter)

            if use_season_search:
                result = arr_post(inst, '/command',
                                  {'name': 'SeasonSearch', 'seriesId': sid, 'seasonNumber': snum})
                msg = (f"🔍 Upgraderr: Season search {title} "
                       f"({n_upgrade}/{monitored_count} eps below threshold) | {inst_name}")
            else:
                ep_ids = [e['ep_id'] for e in sdata['eps']]
                result = arr_post(inst, '/command', {'name': 'EpisodeSearch', 'episodeIds': ep_ids})
                msg = f"🔍 Upgraderr: Episode search {title} (Tier {top_tier}) | {inst_name}"

            search_count  = (row['search_count'] if row else 0) + 1
            cooldown_h    = _adaptive_cooldown(search_count)
            cooldown_until = (datetime.utcnow() + timedelta(hours=cooldown_h)).isoformat()
            _db_mark_searching(inst_name, composite_id, 'season', search_count, cooldown_until)

            # After N failed searches, sync current quality so Ali isn't permanently missing content
            threshold = int(get_cfg('no_source_sync_threshold', str(NO_SOURCE_SYNC_THRESHOLD)))
            if search_count >= threshold and top_tier == 3:
                series_path = series.get('path', '')
                if series_path:
                    season_score = get_current_score(sdata['fn'], is_4k=is_4k, media_type='tv')
                    _trigger_fallback_sync(series_path, f"{stitle} ({year})", 'tv', season_score)
                    send_telegram(
                        f"📦 Upgraderr: Syncing current quality for {title} "
                        f"(no upgrade after {search_count} searches) | {inst_name}",
                        category='notify_each_search'
                    )

            if result:
                budget.record(inst_name)
                tier_counts[top_tier] = tier_counts.get(top_tier, 0) + 1
                _db_log_search(inst_name, title, trigger, 'triggered', top_tier, search_type)
                _db_increment_daily(searches=1)
                log.info(f"[{inst_name}] Search triggered: {title} — Tier {top_tier}")
                send_telegram(msg, category='notify_each_search')
            else:
                _db_log_search(inst_name, title, trigger, 'error', top_tier, search_type)

# ---------------------------------------------------------------------------
# Backup helpers
# ---------------------------------------------------------------------------

def create_backup(label='scheduled'):
    Path(BACKUP_DIR).mkdir(parents=True, exist_ok=True)
    ts = datetime.utcnow().strftime('%Y%m%d_%H%M%S')
    dest = Path(BACKUP_DIR) / f"upgraderr_{label}_{ts}.db"
    shutil.copy2(DB_PATH, dest)
    log.info(f"Backup created: {dest}")
    # Keep only the last 10 backups
    backups = sorted(Path(BACKUP_DIR).glob('upgraderr_*.db'))
    for old in backups[:-10]:
        old.unlink()
    return str(dest)

def list_backups():
    return sorted(
        [{'name': f.name, 'size_kb': f.stat().st_size // 1024,
          'ts': datetime.utcfromtimestamp(f.stat().st_mtime).strftime('%Y-%m-%d %H:%M UTC')}
         for f in Path(BACKUP_DIR).glob('upgraderr_*.db')],
        key=lambda x: x['name'], reverse=True
    )

def _prune_search_log():
    """Keep search_log to last 90 days to prevent unbounded growth."""
    try:
        db = get_db()
        result = db.execute(
            "DELETE FROM search_log WHERE searched_at < datetime('now', '-90 days')"
        )
        deleted = result.rowcount
        db.execute("PRAGMA wal_checkpoint(TRUNCATE)")
        log.info(f"[prune] Pruned {deleted} old search_log rows")
    except Exception as exc:
        log.warning(f"[prune] search_log prune failed: {exc}")

# ---------------------------------------------------------------------------
# APScheduler
# ---------------------------------------------------------------------------

scheduler = BackgroundScheduler(timezone='UTC')

def start_scheduler():
    sweep_interval = int(get_cfg('sweep_minutes', str(SWEEP_MINUTES)))
    scheduler.add_job(
        lambda: do_sweep('scheduled'),
        'interval', minutes=sweep_interval,
        id='sweep', replace_existing=True,
        next_run_time=datetime.utcnow() + timedelta(minutes=2),
    )

    backup_hour = int(get_cfg('backup_schedule_hour', '3'))
    scheduler.add_job(
        lambda: create_backup('scheduled'),
        'cron', hour=backup_hour, minute=0,
        id='backup', replace_existing=True,
    )

    scheduler.add_job(
        lambda: _scan_tmdb_releases(),
        'cron', hour=2, minute=30,
        id='tmdb_scan', replace_existing=True,
    )

    scheduler.add_job(
        _prune_search_log,
        'cron', hour=4, minute=0,
        id='prune_search_log', replace_existing=True,
    )

    scheduler.start()
    log.info(f"Scheduler started — sweep every {sweep_interval}m, backup at {backup_hour:02d}:00 UTC")

# ---------------------------------------------------------------------------
# Jinja2 helpers
# ---------------------------------------------------------------------------

@app.template_filter('localtime')
def localtime_filter(ts):
    return fmt_dt(ts)

@app.context_processor
def inject_globals():
    return {'fmt_dt': fmt_dt}

# ---------------------------------------------------------------------------
# Auth routes
# ---------------------------------------------------------------------------

@app.route('/login', methods=['GET'])
def login_page():
    return render_template('login.html')

@app.route('/login', methods=['POST'])
def login_post():
    ip = request.remote_addr
    if not check_login_rate(ip):
        return render_template('login.html', error='Too many login attempts. Try again in a minute.'), 429

    password = request.form.get('password', '')
    stored = get_config('admin_password_hash')

    ok = check_password(password, stored) if stored else (password == 'changeme')
    if not ok:
        return render_template('login.html', error='Invalid password'), 401

    resp = make_response(redirect(url_for('dashboard')))
    resp.set_cookie('access_token',  make_access_token(),  httponly=True, samesite='Lax', max_age=JWT_ACCESS_TTL)
    resp.set_cookie('refresh_token', make_refresh_token(), httponly=True, samesite='Lax', max_age=JWT_REFRESH_TTL)
    return resp

@app.route('/logout', methods=['POST'])
def logout():
    resp = make_response(redirect(url_for('login_page')))
    resp.delete_cookie('access_token')
    resp.delete_cookie('refresh_token')
    return resp

# ---------------------------------------------------------------------------
# Web UI routes
# ---------------------------------------------------------------------------

@app.route('/')
@require_auth
def dashboard():
    paused = get_config('paused', 'false') == 'true'
    today  = datetime.utcnow().strftime('%Y-%m-%d')
    db = get_request_db()

    today_stats = db.execute("SELECT * FROM daily_stats WHERE date=?", (today,)).fetchone()

    # Real upgrade count from upgrade_history
    upgrades_today = db.execute(
        "SELECT COUNT(*) FROM upgrade_history WHERE date(imported_at)=?", (today,)
    ).fetchone()[0]

    # 5-day rolling history for chart
    history_rows = db.execute("""
        SELECT d.date,
               COALESCE(s.searches_total, 0) as searches,
               COALESCE(u.upgrades, 0) as upgrades
        FROM (
            SELECT date('now', '-' || n || ' days') as date
            FROM (SELECT 0 n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4)
        ) d
        LEFT JOIN daily_stats s ON s.date = d.date
        LEFT JOIN (
            SELECT date(imported_at) as date, COUNT(*) as upgrades
            FROM upgrade_history GROUP BY date(imported_at)
        ) u ON u.date = d.date
        ORDER BY d.date ASC
    """).fetchall()
    history = [{'date': r[0], 'searches': r[1], 'upgrades': r[2]} for r in history_rows]

    max_searches_per_day = int(get_config('max_searches_per_day', '0'))
    searches_today = today_stats['searches_total'] if today_stats else 0

    tier_counts = {}
    for row in db.execute(
            "SELECT priority_tier, COUNT(*) as cnt FROM upgrade_queue "
            "WHERE status='pending' GROUP BY priority_tier"):
        tier_counts[row['priority_tier']] = row['cnt']

    activity = db.execute(
        "SELECT * FROM search_log ORDER BY searched_at DESC LIMIT 50"
    ).fetchall()

    # Searches triggered today that have no matching upgrade imported today or tomorrow
    no_grab_today = db.execute("""
        SELECT COUNT(DISTINCT sl.title) FROM search_log sl
        WHERE date(sl.searched_at)=? AND sl.result='triggered'
          AND sl.title NOT IN (
              SELECT uh.title FROM upgrade_history uh
              WHERE date(uh.imported_at) BETWEEN ? AND date(?, '+1 day')
          )
    """, (today, today, today)).fetchone()[0]

    searching_count = db.execute(
        "SELECT COUNT(*) FROM upgrade_queue WHERE status='searching'"
    ).fetchone()[0]

    instances = get_instances_request()
    instance_status = {}
    instance_health = {}
    for iname, idata in instances.items():
        qd = db.execute(
            "SELECT COUNT(*) as cnt FROM upgrade_queue WHERE instance=? AND status='pending'",
            (iname,)
        ).fetchone()['cnt']
        instance_status[iname] = {
            'label':   idata['label'],
            'enabled': bool(idata['enabled']),
            'queue_depth': qd,
        }
        if idata.get('enabled'):
            instance_health[iname] = _check_instance_health(idata)

    next_sweep = None
    job = scheduler.get_job('sweep')
    if job and job.next_run_time:
        tz = get_display_tz()
        next_sweep = job.next_run_time.astimezone(tz).strftime('%I:%M %p %Z')

    return render_template('dashboard.html',
        paused=paused,
        searches_today=searches_today,
        upgrades_today=upgrades_today,
        no_grab_today=no_grab_today,
        searching_count=searching_count,
        max_searches_per_day=max_searches_per_day,
        history=history,
        tier_counts=tier_counts,
        activity=activity,
        instance_status=instance_status,
        instance_health=instance_health,
        next_sweep=next_sweep,
        today_date=today,
    )

@app.route('/queue')
@require_auth
def queue_page():
    page   = int(request.args.get('page', 1))
    per    = 50
    tier_f = request.args.get('tier', '')
    inst_f = request.args.get('instance', '')
    stat_f = request.args.get('status', 'pending')

    _allowed_sort = {'title', 'priority_tier', 'current_score', 'search_count', 'cooldown_until', 'created_at', 'instance', 'upgrade_reason', 'status'}
    sort_col  = request.args.get('sort', 'priority_tier')
    sort_dir  = request.args.get('order', 'asc')
    if sort_col not in _allowed_sort: sort_col = 'priority_tier'
    if sort_dir not in ('asc', 'desc'): sort_dir = 'asc'
    secondary = 'created_at DESC' if sort_col != 'created_at' else 'title ASC'

    search_q = request.args.get('q', '').strip()

    db = get_request_db()
    where, params = [], []
    if tier_f:    where.append("priority_tier=?");        params.append(tier_f)
    if inst_f:    where.append("instance=?");             params.append(inst_f)
    if stat_f:    where.append("status=?");               params.append(stat_f)
    if search_q:  where.append("title LIKE ?");           params.append(f'%{search_q}%')
    wc = ("WHERE " + " AND ".join(where)) if where else ""

    total = db.execute(f"SELECT COUNT(*) as cnt FROM upgrade_queue {wc}", params).fetchone()['cnt']
    items = db.execute(
        f"SELECT * FROM upgrade_queue {wc} ORDER BY {sort_col} {sort_dir}, {secondary} LIMIT ? OFFSET ?",
        params + [per, (page - 1) * per]
    ).fetchall()

    return render_template('queue.html',
        items=items, page=page, per_page=per, total=total,
        tier_filter=tier_f, instance_filter=inst_f, status_filter=stat_f,
        search_query=search_q,
        instances=list(get_instances_request().keys()),
        sort_col=sort_col, sort_dir=sort_dir,
    )

@app.route('/history')
@require_auth
def history_page():
    page   = int(request.args.get('page', 1))
    per    = 100
    inst_f = request.args.get('instance', '')
    res_f  = request.args.get('result', '')
    search_q = request.args.get('q', '').strip()
    date_f = request.args.get('date', '').strip()
    if date_f == 'today':
        date_f = datetime.utcnow().strftime('%Y-%m-%d')

    _allowed_sort = {'searched_at', 'instance', 'title', 'tier', 'search_type', 'trigger', 'result'}
    sort_col = request.args.get('sort', 'searched_at')
    sort_dir = request.args.get('order', 'desc')
    if sort_col not in _allowed_sort: sort_col = 'searched_at'
    if sort_dir not in ('asc', 'desc'): sort_dir = 'desc'

    db = get_request_db()
    where, params = [], []
    if inst_f:   where.append("instance=?");         params.append(inst_f)
    if res_f:    where.append("result=?");           params.append(res_f)
    if search_q: where.append("title LIKE ?");       params.append(f'%{search_q}%')
    if date_f:   where.append("date(searched_at)=?"); params.append(date_f)
    wc = ("WHERE " + " AND ".join(where)) if where else ""

    total = db.execute(f"SELECT COUNT(*) as cnt FROM search_log {wc}", params).fetchone()['cnt']
    items = db.execute(
        f"SELECT * FROM search_log {wc} ORDER BY {sort_col} {sort_dir} LIMIT ? OFFSET ?",
        params + [per, (page - 1) * per]
    ).fetchall()

    return render_template('history.html',
        items=items, page=page, per_page=per, total=total,
        instance_filter=inst_f, result_filter=res_f, search_query=search_q,
        date_filter=date_f,
        sort_col=sort_col, sort_dir=sort_dir,
        instances=list(get_instances_request().keys()),
    )

@app.route('/settings')
@require_auth
def settings_page():
    paused = get_config('paused', 'false') == 'true'
    cfg = {
        'searches_per_hour': get_config('searches_per_hour', str(SEARCHES_PER_HOUR)),
        'downloads_per_day': get_config('downloads_per_day', str(DOWNLOADS_PER_DAY)),
        'cooldown_hours':    get_config('cooldown_hours',    str(COOLDOWN_HOURS)),
        'sweep_minutes':     get_config('sweep_minutes',     str(SWEEP_MINUTES)),
        'min_score':         get_config('min_score',         str(MIN_SCORE)),
        'season_threshold':           get_config('season_threshold',           str(SEASON_THRESHOLD)),
        'no_source_sync_threshold':   get_config('no_source_sync_threshold',   str(NO_SOURCE_SYNC_THRESHOLD)),
        'max_searches_per_day':       get_config('max_searches_per_day',       '0'),
        'display_tz':        get_config('display_tz',        DISPLAY_TZ),
        'backup_schedule_hour': get_config('backup_schedule_hour', '3'),
        'tmdb_api_key': get_config('tmdb_api_key', os.getenv('TMDB_API_KEY', '')),
    }
    tier_enabled = {
        t: get_config(f'tier_enabled_{t}', 'true') == 'true'
        for t in range(1, 7)
    }
    instances = get_instances_request()
    backups   = list_backups()

    notify_cfg = {
        k: get_config(k, NOTIFY_KEYS[k][1]) == 'true'
        for k in NOTIFY_KEYS
    }

    return render_template('settings.html',
        paused=paused, cfg=cfg,
        tier_enabled=tier_enabled,
        instances=instances,
        backups=backups,
        notify_cfg=notify_cfg,
        notify_keys=NOTIFY_KEYS,
    )

# ---------------------------------------------------------------------------
# API — Control
# ---------------------------------------------------------------------------

@app.route('/health')
def health():
    return jsonify({'status': 'healthy', 'paused': get_config('paused', 'false') == 'true'})

@app.route('/api/pause', methods=['POST'])
@require_auth
def api_pause():
    set_config('paused', 'true')
    set_cfg('paused', 'true')
    send_telegram("⏸ Upgraderr paused by user", category='notify_pause_resume')
    return jsonify({'status': 'paused'})

@app.route('/api/resume', methods=['POST'])
@require_auth
def api_resume():
    set_config('paused', 'false')
    set_cfg('paused', 'false')
    send_telegram("▶ Upgraderr resumed by user", category='notify_pause_resume')
    return jsonify({'status': 'resumed'})

@app.route('/api/sweep', methods=['POST'])
@require_auth
def api_sweep():
    threading.Thread(target=do_sweep, args=('manual',), daemon=True).start()
    return jsonify({'status': 'started'})

def _is_local_request():
    """True if request comes from localhost or Docker bridge network (172.x.x.x)"""
    addr = request.remote_addr or ''
    return addr == '127.0.0.1' or addr.startswith('172.')

@app.route('/api/stats')
def api_stats():
    # Allow unauthenticated access from localhost/Docker host (for daily_report.py)
    if not _is_local_request():
        token = get_token()
        if not (token and verify_token(token, 'access')):
            refresh = request.cookies.get('refresh_token')
            if not (refresh and verify_token(refresh, 'refresh')):
                return jsonify({'error': 'Unauthorized'}), 401
    db = get_request_db()
    today = datetime.utcnow().strftime('%Y-%m-%d')
    s = db.execute("SELECT * FROM daily_stats WHERE date=?", (today,)).fetchone()

    # Real upgrade count from upgrade_history (daily_stats.upgrades_found was never incremented)
    upgrades_today = db.execute(
        "SELECT COUNT(*) FROM upgrade_history WHERE date(imported_at)=?", (today,)
    ).fetchone()[0]
    searches_today = s['searches_total'] if s else 0

    max_searches = int(get_config('max_searches_per_day', '0'))  # 0 = unlimited

    queue_total = db.execute(
        "SELECT COUNT(*) as cnt FROM upgrade_queue WHERE status='pending'"
    ).fetchone()['cnt']
    tier_counts = {str(r['priority_tier']): r['cnt'] for r in db.execute(
        "SELECT priority_tier, COUNT(*) as cnt FROM upgrade_queue WHERE status='pending' GROUP BY priority_tier"
    )}
    job = scheduler.get_job('sweep')
    next_sweep = None
    if job and job.next_run_time:
        next_sweep = job.next_run_time.isoformat()
    paused = get_config('paused', 'false') == 'true'

    # 5-day rolling history
    history = []
    for row in db.execute("""
        SELECT d.date,
               COALESCE(s.searches_total, 0) as searches,
               COALESCE(u.upgrades, 0) as upgrades
        FROM (
            SELECT date('now', '-' || n || ' days') as date
            FROM (SELECT 0 n UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4)
        ) d
        LEFT JOIN daily_stats s ON s.date = d.date
        LEFT JOIN (
            SELECT date(imported_at) as date, COUNT(*) as upgrades
            FROM upgrade_history GROUP BY date(imported_at)
        ) u ON u.date = d.date
        ORDER BY d.date ASC
    """):
        history.append({'date': row[0], 'searches': row[1], 'upgrades': row[2]})

    return jsonify({
        'paused':              paused,
        'searches_today':      searches_today,
        'upgrades_today':      upgrades_today,
        'max_searches_per_day': max_searches,
        'queue_total':         queue_total,
        'tier_counts':         tier_counts,
        'next_sweep':          next_sweep,
        'history':             history,
    })

# ---------------------------------------------------------------------------
# API — Settings
# ---------------------------------------------------------------------------

@app.route('/api/settings', methods=['POST'])
@require_auth
def api_settings():
    data = request.get_json() or {}
    numeric = ['searches_per_hour','downloads_per_day','cooldown_hours',
               'sweep_minutes','min_score','season_threshold','backup_schedule_hour',
               'no_source_sync_threshold','max_searches_per_day']
    for key in numeric:
        if key in data:
            set_config(key, data[key])

    if 'display_tz' in data:
        set_config('display_tz', data['display_tz'])

    if 'tmdb_api_key' in data:
        set_config('tmdb_api_key', str(data['tmdb_api_key']).strip())

    for t in range(1, 7):
        k = f'tier_enabled_{t}'
        if k in data:
            set_config(k, 'true' if data[k] else 'false')

    for k in NOTIFY_KEYS:
        if k in data:
            set_config(k, 'true' if data[k] else 'false')

    # Reschedule sweep if interval changed
    if 'sweep_minutes' in data:
        try:
            mins = int(data['sweep_minutes'])
            scheduler.reschedule_job('sweep', trigger='interval', minutes=mins)
        except Exception:
            pass

    # Reschedule backup if hour changed
    if 'backup_schedule_hour' in data:
        try:
            h = int(data['backup_schedule_hour'])
            scheduler.reschedule_job('backup', trigger='cron', hour=h, minute=0)
        except Exception:
            pass

    return jsonify({'status': 'saved'})

@app.route('/api/password', methods=['POST'])
@require_auth
def api_change_password():
    data = request.get_json() or {}
    current  = data.get('current', '')
    new_pw   = data.get('new', '')
    confirm  = data.get('confirm', '')

    stored = get_config('admin_password_hash')
    if stored:
        if not check_password(current, stored):
            return jsonify({'error': 'Current password is incorrect'}), 400
    else:
        if current != 'changeme':
            return jsonify({'error': 'Current password is incorrect'}), 400

    if len(new_pw) < 8:
        return jsonify({'error': 'New password must be at least 8 characters'}), 400
    if new_pw != confirm:
        return jsonify({'error': 'Passwords do not match'}), 400

    set_config('admin_password_hash', hash_password(new_pw))
    return jsonify({'status': 'changed'})

# ---------------------------------------------------------------------------
# API — Instances
# ---------------------------------------------------------------------------

@app.route('/api/instances', methods=['GET'])
@require_auth
def api_instances_list():
    db = get_request_db()
    rows = db.execute("SELECT * FROM instances ORDER BY name").fetchall()
    return jsonify([dict(r) for r in rows])

@app.route('/api/instances', methods=['POST'])
@require_auth
def api_instances_add():
    data = request.get_json() or {}
    required = ['name', 'url', 'api_key', 'type', 'label']
    if not all(data.get(k) for k in required):
        return jsonify({'error': f'Required: {required}'}), 400
    if data['type'] not in ('radarr', 'sonarr'):
        return jsonify({'error': 'type must be radarr or sonarr'}), 400

    db = get_request_db()
    try:
        db.execute(
            "INSERT INTO instances(name,url,api_key,type,label,enabled) VALUES(?,?,?,?,?,1)",
            (data['name'], data['url'].rstrip('/'), data['api_key'],
             data['type'], data['label'])
        )
        db.commit()
    except sqlite3.IntegrityError:
        return jsonify({'error': f"Instance '{data['name']}' already exists"}), 409
    return jsonify({'status': 'added', 'name': data['name']})

@app.route('/api/instances/<name>', methods=['PUT'])
@require_auth
def api_instances_update(name):
    data = request.get_json() or {}
    db = get_request_db()
    inst = db.execute("SELECT * FROM instances WHERE name=?", (name,)).fetchone()
    if not inst:
        return jsonify({'error': 'Not found'}), 404

    url     = data.get('url', inst['url']).rstrip('/')
    api_key = data.get('api_key', inst['api_key'])
    label   = data.get('label', inst['label'])
    enabled = int(data['enabled']) if 'enabled' in data else inst['enabled']

    db.execute(
        "UPDATE instances SET url=?, api_key=?, label=?, enabled=? WHERE name=?",
        (url, api_key, label, enabled, name)
    )
    db.commit()
    return jsonify({'status': 'updated', 'name': name})

@app.route('/api/instances/<name>', methods=['DELETE'])
@require_auth
def api_instances_delete(name):
    db = get_request_db()
    if not db.execute("SELECT 1 FROM instances WHERE name=?", (name,)).fetchone():
        return jsonify({'error': 'Not found'}), 404
    db.execute("DELETE FROM instances WHERE name=?", (name,))
    db.commit()
    return jsonify({'status': 'deleted', 'name': name})

@app.route('/api/instances/<name>/test', methods=['POST'])
@require_auth
def api_instances_test(name):
    db = get_request_db()
    row = db.execute("SELECT * FROM instances WHERE name=?", (name,)).fetchone()
    if not row:
        return jsonify({'error': 'Not found'}), 404
    ok, msg = test_instance_connection(dict(row))
    return jsonify({'ok': ok, 'message': msg})

# ---------------------------------------------------------------------------
# API — Queue management
# ---------------------------------------------------------------------------

@app.route('/api/queue')
@require_auth
def api_queue():
    page = int(request.args.get('page', 1))
    per  = int(request.args.get('per_page', 50))
    db   = get_request_db()
    total = db.execute("SELECT COUNT(*) as cnt FROM upgrade_queue WHERE status='pending'").fetchone()['cnt']
    items = db.execute(
        "SELECT * FROM upgrade_queue WHERE status='pending' ORDER BY priority_tier, created_at DESC LIMIT ? OFFSET ?",
        (per, (page - 1) * per)
    ).fetchall()
    return jsonify({'total': total, 'items': [dict(r) for r in items]})

@app.route('/api/history')
@require_auth
def api_history():
    page = int(request.args.get('page', 1))
    per  = int(request.args.get('per_page', 100))
    db   = get_request_db()
    total = db.execute("SELECT COUNT(*) as cnt FROM search_log").fetchone()['cnt']
    items = db.execute(
        "SELECT * FROM search_log ORDER BY searched_at DESC LIMIT ? OFFSET ?",
        (per, (page - 1) * per)
    ).fetchall()
    return jsonify({'total': total, 'items': [dict(r) for r in items]})

# ---------------------------------------------------------------------------
# API — Quality profile upgrade toggle
# ---------------------------------------------------------------------------

@app.route('/api/instances/<name>/upgrades', methods=['POST'])
@require_auth
def api_toggle_upgrades(name):
    """Enable or disable upgradeAllowed on all quality profiles for an instance."""
    data    = request.get_json() or {}
    enabled = bool(data.get('enabled', True))

    db   = get_request_db()
    inst = db.execute("SELECT * FROM instances WHERE name=?", (name,)).fetchone()
    if not inst:
        return jsonify({'error': 'Not found'}), 404

    inst = dict(inst)
    profiles = arr_get(inst, '/qualityprofile')
    if profiles is None:
        return jsonify({'error': 'Could not reach instance'}), 502

    updated = []
    for profile in profiles:
        if profile.get('upgradeAllowed') != enabled:
            profile['upgradeAllowed'] = enabled
            result = arr_put(inst, f"/qualityprofile/{profile['id']}", profile)
            if result:
                updated.append(profile['name'])

    action = 'enabled' if enabled else 'disabled'
    msg = f"Upgrades {action} on {name}: {len(updated)} profiles updated ({', '.join(updated) or 'none changed'})"
    log.info(msg)
    return jsonify({'status': action, 'updated_profiles': updated, 'message': msg})

@app.route('/api/instances/<name>/upgrades', methods=['GET'])
@require_auth
def api_get_upgrades_status(name):
    """Return upgradeAllowed status for each quality profile on an instance."""
    db   = get_request_db()
    inst = db.execute("SELECT * FROM instances WHERE name=?", (name,)).fetchone()
    if not inst:
        return jsonify({'error': 'Not found'}), 404

    profiles = arr_get(dict(inst), '/qualityprofile')
    if profiles is None:
        return jsonify({'error': 'Could not reach instance'}), 502

    return jsonify([{'name': p['name'], 'upgradeAllowed': p.get('upgradeAllowed', False)}
                    for p in profiles])

# ---------------------------------------------------------------------------
# API — Reset queue
# ---------------------------------------------------------------------------

@app.route('/api/reset', methods=['POST'])
@require_auth
def api_reset():
    """Clear all queue, search logs, and daily stats. Does NOT affect config or instances."""
    data = request.get_json() or {}
    what = data.get('what', 'all')  # 'all', 'queue', 'logs'

    db = get_request_db()
    cleared = []
    if what in ('all', 'queue'):
        db.execute("DELETE FROM upgrade_queue")
        cleared.append('upgrade_queue')
    if what in ('all', 'logs'):
        db.execute("DELETE FROM search_log")
        db.execute("DELETE FROM daily_stats")
        cleared.append('search_log')
        cleared.append('daily_stats')
    db.commit()

    log.info(f"Queue reset: cleared {cleared}")
    return jsonify({'status': 'cleared', 'tables': cleared})

# ---------------------------------------------------------------------------
# API — Backup
# ---------------------------------------------------------------------------

@app.route('/api/backup/download')
@require_auth
def api_backup_download():
    path = create_backup('manual')
    return send_file(path, as_attachment=True,
                     download_name=f"upgraderr_backup_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.db")

@app.route('/api/backup/now', methods=['POST'])
@require_auth
def api_backup_now():
    path = create_backup('manual')
    return jsonify({'status': 'created', 'path': path})

@app.route('/api/backup/list')
@require_auth
def api_backup_list():
    return jsonify(list_backups())

@app.route('/api/backup/restore', methods=['POST'])
@require_auth
def api_backup_restore():
    if 'file' not in request.files:
        return jsonify({'error': 'No file uploaded'}), 400
    f = request.files['file']
    if not f.filename.endswith('.db'):
        return jsonify({'error': 'File must be a .db file'}), 400

    # Backup current DB first
    create_backup('pre-restore')
    restore_path = Path(DB_PATH)
    f.save(str(restore_path))
    log.info(f"Database restored from uploaded file")
    return jsonify({'status': 'restored', 'message': 'DB restored. Restart container to apply.'})

# ---------------------------------------------------------------------------
# Instance helpers
# ---------------------------------------------------------------------------

def get_instance(name):
    """Return a single instance dict by name (request-scoped)."""
    db = get_request_db()
    row = db.execute("SELECT * FROM instances WHERE name=?", (name,)).fetchone()
    return dict(row) if row else None

def _check_instance_health(inst) -> bool:
    """Quick health check — returns True if instance responds within 3s."""
    try:
        url = inst['url'].rstrip('/') + '/api/v3/system/status'
        r = requests.get(url, headers={'X-Api-Key': inst['api_key']}, timeout=3)
        return r.ok
    except Exception:
        return False

# ---------------------------------------------------------------------------
# Webhook endpoints (unauthenticated — called by Radarr/Sonarr)
# ---------------------------------------------------------------------------

def _is_internal_request():
    """Allow requests from Docker bridge (172.x), private LAN (10.x, 192.168.x), or localhost."""
    addr = request.remote_addr or ''
    return (addr == '127.0.0.1' or addr.startswith('172.') or
            addr.startswith('10.') or addr.startswith('192.168.'))

@app.route('/webhook/radarr', methods=['POST'])
def webhook_radarr():
    """Receive download/import events from Radarr."""
    if not _is_internal_request():
        return jsonify({'error': 'Forbidden'}), 403

    # Instance identified via ?source=radarr-hd (or radarr-4k) in the webhook URL
    source = request.args.get('source', 'radarr-unknown')

    data = request.get_json(silent=True) or {}
    event_type = data.get('eventType', '')

    if event_type == 'Grab':
        movie = data.get('movie', {})
        mid = movie.get('id')
        infohash = data.get('downloadId', '')
        if mid and infohash:
            db = get_request_db()
            # Tag if Upgraderr searched this movie within the last 2 hours
            row = db.execute(
                """SELECT id FROM upgrade_queue
                   WHERE media_id=? AND media_type='movie' AND instance=?
                     AND searched_at >= datetime('now', '-2 hours')""",
                (mid, source)
            ).fetchone()
            if row:
                _qb_tag_torrent(infohash)
        return jsonify({'status': 'grab_processed'}), 200

    if event_type not in ('Download', 'MovieFileRenamed'):
        return jsonify({'status': 'ignored'}), 200

    # Skip first-time RSS grabs — only record quality upgrades of existing files
    if event_type == 'Download' and not data.get('isUpgrade', False):
        return jsonify({'status': 'new_content_ignored'}), 200

    movie = data.get('movie', {})
    movie_file = data.get('movieFile', {})
    mid = movie.get('id')
    title = movie.get('title', 'Unknown')
    year = movie.get('year', '')
    new_path = movie_file.get('relativePath', '') or movie_file.get('path', '')

    if not mid:
        return jsonify({'status': 'no_id'}), 200

    db = get_request_db()
    # Scope lookup to the sending instance so IDs from different instances don't collide
    row = db.execute(
        "SELECT * FROM upgrade_queue WHERE media_id=? AND media_type='movie' AND instance=?",
        (mid, source)
    ).fetchone()

    inst_name = row['instance'] if row else source
    before_quality = row['before_quality'] if row else None
    before_score = row['before_score'] if row else None
    tier = row['priority_tier'] if row else None
    full_title = f"{title} ({year})" if year else title

    after_score = get_current_score(new_path, media_type='movie') if new_path else None

    db.execute(
        """INSERT INTO upgrade_history
           (instance, media_id, media_type, title, before_quality, before_score,
            after_quality, after_score, tier)
           VALUES (?,?,?,?,?,?,?,?,?)""",
        (inst_name, mid, 'movie', full_title, before_quality, before_score,
         new_path, after_score, tier)
    )

    if row:
        db.execute(
            """UPDATE upgrade_queue SET status='found', searched_at=CURRENT_TIMESTAMP
               WHERE media_id=? AND media_type='movie' AND instance=?""",
            (mid, source)
        )
    db.commit()

    log.info(f"[webhook] Radarr import ({source}): {full_title} -> {new_path}")
    return jsonify({'status': 'recorded'}), 200


@app.route('/webhook/sonarr', methods=['POST'])
def webhook_sonarr():
    """Receive download/import events from Sonarr."""
    if not _is_internal_request():
        return jsonify({'error': 'Forbidden'}), 403

    # Instance identified via ?source=sonarr-hd (or sonarr-4k) in the webhook URL
    source = request.args.get('source', 'sonarr-unknown')

    data = request.get_json(silent=True) or {}
    event_type = data.get('eventType', '')

    if event_type == 'Grab':
        series = data.get('series', {})
        sid = series.get('id')
        infohash = data.get('downloadId', '')
        season_num = (data.get('episodes') or [{}])[0].get('seasonNumber', 0)
        if sid and infohash:
            composite_id = sid * 10000 + season_num
            db = get_request_db()
            row = db.execute(
                """SELECT id FROM upgrade_queue
                   WHERE media_id=? AND media_type='season' AND instance=?
                     AND searched_at >= datetime('now', '-2 hours')""",
                (composite_id, source)
            ).fetchone()
            if row:
                _qb_tag_torrent(infohash)
        return jsonify({'status': 'grab_processed'}), 200

    if event_type not in ('Download', 'EpisodeFileRenamed'):
        return jsonify({'status': 'ignored'}), 200

    # Skip first-time RSS grabs — only record quality upgrades of existing files
    if event_type == 'Download' and not data.get('isUpgrade', False):
        return jsonify({'status': 'new_content_ignored'}), 200

    series = data.get('series', {})
    episode_file = data.get('episodeFile', {})
    sid = series.get('id')
    title = series.get('title', 'Unknown')
    year = series.get('year', '')
    new_path = episode_file.get('relativePath', '') or episode_file.get('path', '')
    season_num = episode_file.get('seasonNumber', 0)

    if not sid:
        return jsonify({'status': 'no_id'}), 200

    composite_id = sid * 10000 + season_num
    db = get_request_db()
    # Scope lookup to the sending instance so IDs from different instances don't collide
    row = db.execute(
        "SELECT * FROM upgrade_queue WHERE media_id=? AND media_type='season' AND instance=?",
        (composite_id, source)
    ).fetchone()

    inst_name = row['instance'] if row else source
    before_quality = row['before_quality'] if row else None
    before_score = row['before_score'] if row else None
    tier = row['priority_tier'] if row else None
    season_title = f"{title} S{season_num:02d}" if season_num else title

    after_score = get_current_score(new_path, media_type='tv') if new_path else None

    db.execute(
        """INSERT INTO upgrade_history
           (instance, media_id, media_type, title, before_quality, before_score,
            after_quality, after_score, tier)
           VALUES (?,?,?,?,?,?,?,?,?)""",
        (inst_name, composite_id, 'season', season_title, before_quality, before_score,
         new_path, after_score, tier)
    )

    if row:
        db.execute(
            """UPDATE upgrade_queue SET status='found', searched_at=CURRENT_TIMESTAMP
               WHERE media_id=? AND media_type='season' AND instance=?""",
            (composite_id, source)
        )
    db.commit()

    log.info(f"[webhook] Sonarr import ({source}): {season_title} -> {new_path}")
    return jsonify({'status': 'recorded'}), 200

# ---------------------------------------------------------------------------
# API — Manual queue search
# ---------------------------------------------------------------------------

@app.route('/api/queue/<int:item_id>/search', methods=['POST'])
@require_auth
def api_queue_search(item_id):
    db = get_request_db()
    row = db.execute("SELECT * FROM upgrade_queue WHERE id=?", (item_id,)).fetchone()
    if not row:
        return jsonify({'error': 'Not found'}), 404

    inst = get_instance(row['instance'])
    if not inst or not inst.get('enabled'):
        return jsonify({'error': 'Instance not available'}), 400

    if row['media_type'] == 'movie':
        result = arr_post(inst, '/command', {'name': 'MoviesSearch', 'movieIds': [row['media_id']]})
    elif row['search_type'] == 'season':
        sid = row['media_id'] // 10000
        snum = row['season_number']
        result = arr_post(inst, '/command', {
            'name': 'SeasonSearch', 'seriesId': sid, 'seasonNumber': snum
        })
    else:
        return jsonify({'error': 'Unsupported search type'}), 400

    if result:
        cooldown_h = int(get_config('cooldown_hours', str(COOLDOWN_HOURS)))
        cooldown_until = (datetime.utcnow() + timedelta(hours=cooldown_h)).isoformat()
        search_count = (row['search_count'] or 0) + 1
        db.execute(
            """UPDATE upgrade_queue SET status='searching', searched_at=CURRENT_TIMESTAMP,
               search_count=?, cooldown_until=? WHERE id=?""",
            (search_count, cooldown_until, item_id)
        )
        db.commit()
        _db_log_search(row['instance'], row['title'], 'manual', 'triggered',
                       row['priority_tier'], row['search_type'] or 'movie')
        _db_increment_daily(searches=1)
        return jsonify({'status': 'triggered'})
    else:
        return jsonify({'error': 'Search command failed'}), 500


@app.route('/api/queue/<int:item_id>/reset', methods=['POST'])
@require_auth
def api_queue_reset(item_id):
    """Clear cooldown and decrement search count so the next sweep re-searches this item."""
    db = get_request_db()
    row = db.execute("SELECT id, title FROM upgrade_queue WHERE id=?", (item_id,)).fetchone()
    if not row:
        return jsonify({'error': 'Not found'}), 404
    db.execute(
        "UPDATE upgrade_queue SET cooldown_until=NULL, search_count=MAX(0, search_count-1), status='pending' WHERE id=?",
        (item_id,)
    )
    db.commit()
    return jsonify({'status': 'reset'})


@app.route('/api/queue/reset-all', methods=['POST'])
@require_auth
def api_queue_reset_all():
    """Clear cooldowns on all pending items matching optional tier/instance filters."""
    data = request.get_json(silent=True) or {}
    tier_f = data.get('tier')
    inst_f = data.get('instance')
    where, params = ["status='pending'"], []
    if tier_f: where.append("priority_tier=?"); params.append(tier_f)
    if inst_f: where.append("instance=?");      params.append(inst_f)
    wc = "WHERE " + " AND ".join(where)
    db = get_request_db()
    affected = db.execute(
        f"UPDATE upgrade_queue SET cooldown_until=NULL, search_count=MAX(0, search_count-1) {wc}",
        params
    ).rowcount
    db.commit()
    return jsonify({'status': 'reset', 'affected': affected})

# ---------------------------------------------------------------------------
# Upgrade History page
# ---------------------------------------------------------------------------

@app.route('/upgrades')
@require_auth
def upgrades_page():
    db = get_request_db()
    page = max(1, request.args.get('page', 1, type=int))
    per_page = 50
    inst_f   = request.args.get('instance', '')
    tier_f   = request.args.get('tier', '')
    search_q = request.args.get('q', '').strip()
    date_f   = request.args.get('date', '').strip()
    if date_f == 'today':
        date_f = datetime.utcnow().strftime('%Y-%m-%d')

    _allowed_sort = {'imported_at', 'instance', 'title', 'tier', 'before_quality', 'after_quality', 'score_delta'}
    sort_col = request.args.get('sort', 'imported_at')
    sort_dir = request.args.get('order', 'desc')
    if sort_col not in _allowed_sort: sort_col = 'imported_at'
    if sort_dir not in ('asc', 'desc'): sort_dir = 'desc'

    order_expr = '(after_score - before_score)' if sort_col == 'score_delta' else sort_col

    where, params = [], []
    if inst_f:   where.append("instance=?");          params.append(inst_f)
    if tier_f:   where.append("tier=?");              params.append(tier_f)
    if search_q: where.append("title LIKE ?");        params.append(f'%{search_q}%')
    if date_f:   where.append("date(imported_at)=?"); params.append(date_f)
    wc = ("WHERE " + " AND ".join(where)) if where else ""

    total = db.execute(f"SELECT COUNT(*) as cnt FROM upgrade_history {wc}", params).fetchone()['cnt']
    items = db.execute(
        f"SELECT * FROM upgrade_history {wc} ORDER BY {order_expr} {sort_dir} LIMIT ? OFFSET ?",
        params + [per_page, (page - 1) * per_page]
    ).fetchall()

    return render_template('upgrades.html', items=items, total=total,
                           page=page, per_page=per_page, fmt_dt=fmt_dt,
                           instance_filter=inst_f, tier_filter=tier_f,
                           search_query=search_q, date_filter=date_f,
                           sort_col=sort_col, sort_dir=sort_dir,
                           instances=list(get_instances_request().keys()))

# ---------------------------------------------------------------------------
# Init
# ---------------------------------------------------------------------------

init_database()
_reload_config()
start_scheduler()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=False)
