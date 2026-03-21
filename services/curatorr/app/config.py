"""Curatorr configuration — reads from environment variables."""
import os
import secrets
from pathlib import Path

# ── Core ────────────────────────────────────────────────────────────────────
DB_PATH      = os.environ.get('CURATORR_DB_PATH', '/data/curatorr.db')
BACKUP_DIR   = os.environ.get('CURATORR_BACKUP_DIR', '/data/backups')
SECRET_FILE  = '/data/curatorr.secret'
DATA_DIR     = '/data'

def get_secret_key() -> str:
    env_key = os.environ.get('CURATORR_SECRET_KEY', '').strip()
    if env_key:
        return env_key
    p = Path(SECRET_FILE)
    if p.exists():
        return p.read_text().strip()
    key = secrets.token_hex(32)
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(key)
    return key

SECRET_KEY = get_secret_key()

# ── Auth ─────────────────────────────────────────────────────────────────────
ADMIN_PASSWORD  = os.environ.get('CURATORR_ADMIN_PASSWORD', '').strip()
JWT_ACCESS_TTL  = 3600        # 1 hour
JWT_REFRESH_TTL = 604800      # 7 days

# ── External APIs ─────────────────────────────────────────────────────────────
TMDB_API_KEY     = os.environ.get('TMDB_API_KEY', '')
OMDB_API_KEY     = os.environ.get('OMDB_API_KEY', '')
MDBLIST_API_KEY  = os.environ.get('MDBLIST_API_KEY', '')

# ── Plex ──────────────────────────────────────────────────────────────────────
CHRIS_PLEX_URL   = os.environ.get('CHRIS_PLEX_URL', 'http://10.0.0.250:32400')
CHRIS_PLEX_TOKEN = os.environ.get('CHRIS_PLEX_TOKEN', '_baJvspRxVjRzaokRoLB')
ALI_PLEX_URL     = os.environ.get('ALI_PLEX_URL', 'http://192.168.1.52:32400')
ALI_PLEX_TOKEN   = os.environ.get('ALI_PLEX_TOKEN', '')

# ── Tautulli ──────────────────────────────────────────────────────────────────
CHRIS_TAUTULLI_URL = os.environ.get('CHRIS_TAUTULLI_URL', 'http://tautulli:8181')
CHRIS_TAUTULLI_KEY = os.environ.get('CHRIS_TAUTULLI_KEY', '')
ALI_TAUTULLI_URL   = os.environ.get('ALI_TAUTULLI_URL', '')
ALI_TAUTULLI_KEY   = os.environ.get('ALI_TAUTULLI_KEY', '')

# ── *arr ──────────────────────────────────────────────────────────────────────
RADARR_HD_URL    = os.environ.get('RADARR_HD_URL',    'http://radarr-hd:7878')
RADARR_HD_KEY    = os.environ.get('RADARR_HD_API_KEY', '')
RADARR_4K_URL    = os.environ.get('RADARR_4K_URL',    'http://radarr-4k:7878')
RADARR_4K_KEY    = os.environ.get('RADARR_4K_API_KEY', '')
SONARR_HD_URL    = os.environ.get('SONARR_HD_URL',    'http://sonarr-hd:8989')
SONARR_HD_KEY    = os.environ.get('SONARR_HD_API_KEY', '')
SONARR_4K_URL    = os.environ.get('SONARR_4K_URL',    'http://sonarr-4k:8989')
SONARR_4K_KEY    = os.environ.get('SONARR_4K_API_KEY', '')

# ── Telegram ──────────────────────────────────────────────────────────────────
TELEGRAM_BOT_TOKEN      = os.environ.get('TELEGRAM_BOT_TOKEN', '')
CURATORR_TELEGRAM_CHAT  = os.environ.get('CURATORR_TELEGRAM_CHAT_ID', '')

# ── Paths ─────────────────────────────────────────────────────────────────────
UNRAID_MEDIA_PATH = os.environ.get('UNRAID_MEDIA_PATH', '/mnt/unraid/media')

PATH_MAPPINGS = {
    '/movies':    ('/mnt/synology/rs-movies',            UNRAID_MEDIA_PATH + '/Movies'),
    '/movies-4k': ('/mnt/synology/rs-4kmedia/4kmovies',  UNRAID_MEDIA_PATH + '/4K Movies'),
    '/tv':        ('/mnt/synology/rs-tv',                UNRAID_MEDIA_PATH + '/TV Shows'),
    '/tv-4k':     ('/mnt/synology/rs-4kmedia/4ktv',      UNRAID_MEDIA_PATH + '/4K TV Shows'),
}

def synology_to_unraid_path(synology_path: str) -> str | None:
    for container_prefix, (_, unraid_base) in PATH_MAPPINGS.items():
        if synology_path.startswith(container_prefix + '/'):
            relative = synology_path[len(container_prefix):]
            return unraid_base + relative
    return None

# ── *arr instances list ───────────────────────────────────────────────────────
RADARR_INSTANCES = [
    {'name': 'radarr-hd', 'url': RADARR_HD_URL, 'api_key': RADARR_HD_KEY, 'label': 'Radarr HD'},
    {'name': 'radarr-4k', 'url': RADARR_4K_URL, 'api_key': RADARR_4K_KEY, 'label': 'Radarr 4K'},
]
SONARR_INSTANCES = [
    {'name': 'sonarr-hd', 'url': SONARR_HD_URL, 'api_key': SONARR_HD_KEY, 'label': 'Sonarr HD'},
    {'name': 'sonarr-4k', 'url': SONARR_4K_URL, 'api_key': SONARR_4K_KEY, 'label': 'Sonarr 4K'},
]
PLEX_INSTANCES = [
    {'name': 'chris', 'url': CHRIS_PLEX_URL, 'token': CHRIS_PLEX_TOKEN},
    {'name': 'ali',   'url': ALI_PLEX_URL,   'token': ALI_PLEX_TOKEN},
]
TAUTULLI_INSTANCES = [
    {'name': 'chris', 'url': CHRIS_TAUTULLI_URL, 'api_key': CHRIS_TAUTULLI_KEY, 'user': 'chris'},
    {'name': 'ali',   'url': ALI_TAUTULLI_URL,   'api_key': ALI_TAUTULLI_KEY,   'user': 'ali'},
]

# ── Public URLs (for deep links in UI) ────────────────────────────────────────
RADARR_HD_PUBLIC_URL  = os.environ.get('RADARR_HD_PUBLIC_URL',  '')
RADARR_4K_PUBLIC_URL  = os.environ.get('RADARR_4K_PUBLIC_URL',  '')
SONARR_HD_PUBLIC_URL  = os.environ.get('SONARR_HD_PUBLIC_URL',  '')
SONARR_4K_PUBLIC_URL  = os.environ.get('SONARR_4K_PUBLIC_URL',  '')
OVERSEERR_URL         = os.environ.get('OVERSEERR_URL',         '')

VERSION = '1.1.0'
