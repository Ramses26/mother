# Curatorr

**Media Intelligence & Curation Service** — Comprehensive web app for managing and analyzing the Project Mother media library.

## Overview

Curatorr provides:
- Full movie/TV library browser with advanced filtering and multi-source ratings
- Composite scoring (IMDb 35%, RT 25%, MDBList 20%, Metacritic 15%, TMDB 5%)
- Purge scoring to identify deletion candidates (0-100 scale)
- Watch history tracking from both Tautulli instances (Ali + Chris)
- Rules engine for automated media management
- Collection tracking (TMDB collections)
- Duplicate detection (Synology NFS scan + Unraid Agent API)
- **Sync Status** — real-time Synology→Unraid parity view showing In Sync / Missing / Version Mismatch / Radarr Out of Date / Not Downloaded for HD Movies and TV
- Direct deletion via Radarr/Sonarr API + Unraid NFS

## Access

- **URL**: `http://mother:9707`
- **Auth**: JWT (bcrypt), HttpOnly cookies, 1h access / 7d refresh tokens
- **First run**: Navigate to `/setup` to set admin password

## Environment Variables

| Variable | Description |
|----------|-------------|
| `CURATORR_ADMIN_PASSWORD` | Admin password (if set, overrides DB config) |
| `CURATORR_SECRET_KEY` | JWT signing key (auto-generated if absent) |
| `OMDB_API_KEY` | OMDB API for IMDb/RT/Metacritic ratings |
| `MDBLIST_API_KEY` | MDBList aggregated ratings |
| `TMDB_API_KEY` | TMDB ratings and collection data |
| `CURATORR_TELEGRAM_CHAT_ID` | Telegram chat for notifications |

## Sync Schedule

| Job | Schedule | Source |
|-----|----------|--------|
| Library sync | Every 6h | Radarr + Sonarr + Plex |
| Watch history | 02:00 UTC | Tautulli (both instances) |
| Ratings refresh | 03:00 UTC | OMDB + MDBList + TMDB |
| Rules execution | 04:00 UTC | All enabled daily/weekly rules |
| DB backup | 04:30 UTC | SQLite backup to `/data/backups/` |
| Weekly digest | Sunday 09:00 UTC | Telegram summary |

## Scoring

### Composite Score (0-10)
```
IMDb:        weight 35%  (0-10)
RT Critics:  weight 25%  (0-100 → 0-10)
MDBList:     weight 20%  (0-100 → 0-10)
Metacritic:  weight 15%  (0-100 → 0-10)
TMDB:        weight 5%   (0-10)
```

### Purge Score (0-100, higher = stronger delete candidate)
- Low composite score: up to +50 points
- Never watched: +20, watched ≤1 total: +10
- Low resolution (720p/SD): +15
- Cancelled show + both watched: +10
- High rating (≥8.5): -20 points protection

## API

```
GET  /health                    — Health check (no auth)
POST /api/login                 — Login (5/min rate limit)
POST /api/logout                — Logout
POST /api/setup                 — First-run setup

GET  /api/stats                 — Dashboard stats
GET  /api/movies                — List movies (many filters)
GET  /api/movies/{id}           — Movie detail
DELETE /api/movies/{id}         — Delete movie
POST /api/movies/{id}/unmonitor — Unmonitor in Radarr

GET  /api/tv                    — List TV shows
GET  /api/tv/{id}               — Show detail
DELETE /api/tv/{id}             — Delete show
POST /api/tv/{id}/unmonitor     — Unmonitor in Sonarr

GET  /api/collections           — List TMDB collections
GET  /api/collections/{id}      — Collection detail

GET  /api/duplicates            — Duplicate movie detection

GET  /api/rules                 — List rules
POST /api/rules                 — Create rule
PUT  /api/rules/{id}            — Update rule
DELETE /api/rules/{id}          — Delete rule
POST /api/rules/{id}/run        — Run rule (stage matches)
POST /api/rules/{id}/preview    — Preview matches (dry run)
POST /api/rules/{id}/execute    — Execute on staged matches

GET  /api/deletion-log          — Deletion history
GET  /api/sync/status           — Sync status
POST /api/sync/trigger          — Trigger sync

GET  /api/movies/export         — CSV export
GET  /api/tv/export             — CSV export
```

## Data

- **Database**: SQLite WAL at `/data/curatorr.db`
- **Backups**: `/data/backups/curatorr_*.db` (7 kept)
- **Port**: 9707 (host) → 8000 (container)
