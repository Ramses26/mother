# Features

## Curatorr (port 9707)

Media intelligence and curation service. Full-stack media library management with scoring,
purge analysis, watch history, rules engine, and direct deletion.

### Library Browser
- Movies: 7,600+ movies from Radarr HD + 4K instances
- TV Shows: 1,600+ shows from Sonarr HD + 4K instances
- Poster grid and table views with column visibility controls
- Filter sidebar: composite score range, resolution, HDR, watch status, genres, status (TV)
- Filter presets: Purge Candidates, Never Watched, Low Rated, 4K, Recently Added
- Sort by: title, year, composite score, purge score, file size, date added

### Composite Scoring (0–10 scale)
Weighted average of external ratings:
- IMDb 35%, RT Critics 25%, MDBList 20%, Metacritic 15%, TMDB 5%
- Ratings sourced via OMDB, MDBList API, TMDB API

### Purge Scoring (0–100)
Deletion candidate scoring:
- Composite below 5.0 → up to +50 pts
- Never watched by either user → +20 pts
- Watched only once total → +10 pts
- Low resolution (720p/SD) → +15 pts
- Cancelled show, both watched → +10 pts
- High rating (≥8.5) → −20 pts (protection)
- Color coded: Green <30 · Yellow 30–54 · Orange 55–74 · Red 75+

### Media Detail Panel
- Slide-in panel with full metadata, ratings, watch history, file info, season progress
- Click backdrop or × to close
- External deep links: Radarr/Sonarr (configurable public URLs), IMDb, TMDB
- Actions: Unmonitor, Delete (with confirmation)

### Watch History
- Delta sync from both Tautulli instances (Chris + Ali)
- Per-user play counts and last-watched timestamps on each movie/show
- Watch history stored in DB for rule conditions

### Collections (TMDB)
- Browse TMDB movie collections (Marvel, Star Wars, Bond, etc.)
- Ownership progress bar per collection
- Auto-loads missing movies from TMDB on collection open
- Request missing movies via Overseerr integration

### Rules Engine
- Visual condition builder with AND/OR logic
- Conditions: composite score, IMDb, RT, resolution, watch status, year, genres, status, file size
- Actions: stage for review, unmonitor, delete, notify
- Schedule: daily, weekly, or manual
- Telegram notification on match
- Rule matches staged in DB for review before action

### Direct Deletion
- Calls Radarr/Sonarr API (`deleteFiles: true`) then removes from Unraid NFS mount
- Path resolution: container path → Synology NFS → Unraid destination
- Deletion log with arr_delete_ok, unraid_delete_ok flags, freed space

### Dashboard
- Stats cards: total movies/TV, never-watched counts, below-5.0 rating count, movie storage
- Rating distribution histogram with per-source toggle (Composite/IMDb/RT/Metacritic/MDBList)
- Top 5 purge candidates
- Recent additions (movies + TV)
- Sync status panel with per-source state (ok/error/syncing/not_configured)
- Manual sync trigger with live polling

### Logs Page
- Paginated event log (last 2000 entries)
- Filter by event type: sync, deletion, rule, error
- Filter by source, level (info/warning/error)
- Events written during: library syncs, deletions, rule runs

### Settings
- Change password (bcrypt)
- Public URL configuration (Radarr HD/4K, Sonarr HD/4K, Overseerr) — persisted to DB config table
- API keys display (masked)
- Connection info (Plex URLs, Telegram chat ID)
- Manual sync triggers per source
- Database backup management: create, download, list with size/date
- Danger Zone: reset all synced data

### Sync Sources
- Radarr HD + 4K: movie metadata, quality, file info, posters (TMDB `remotePoster`)
- Sonarr HD + 4K: TV metadata, season/episode counts, posters
- Plex XML API (Chris + Ali): file metadata, codec, resolution, watch keys
- Tautulli (Chris + Ali): watch history delta sync, play counts

### Auth
- JWT dual-token: access token (1h) + refresh token (7d, HttpOnly cookie)
- Login rate limiting: 5 attempts/minute per IP
- bcrypt password hashing

### Scheduled Jobs (APScheduler)
- 6h: full library sync (Radarr + Sonarr)
- 02:00: watch history sync (Tautulli)
- 03:00: ratings refresh (OMDB + MDBList + TMDB)
- 04:00: run scheduled rules
- 04:30: DB backup
- Sun 09:00: weekly Telegram digest

---

## Upgraderr (port 9706)

Custom quality upgrade automation service. Replaces Huntarr.

### 6 Upgrade Tiers
| Tier | Criteria |
|------|----------|
| 1 | `.m2ts`/`BDMV` container (no companion MKV) |
| 2 | Non-MKV container (`.avi`, `.mp4`, `.ts`, etc.) |
| 3 | 720p or lower resolution |
| 4 | WEB-DL + TMDB physical release ≥90 days ago |
| 5 | No surround sound (stereo/2.0 only, post-1991) |
| 6 | TRaSH score below threshold (catch-all) |

### Discovery
- Queries all 4 `*arr` instances (Radarr HD/4K, Sonarr HD/4K)
- Classifies items into tiers using TRaSH quality scoring
- Pre-era audio logic: skips Tier 5 for pre-1992 content (stereo was canonical)
- TV season grouping: SeasonSearch if ≥50% of season qualifies

### Rate Limiting
- Configurable searches/hour per instance (default 5)
- Global downloads/day cap (default 10)
- Per-item adaptive cooldown: 7d → 14d → 30d → 90d on repeated no-results
- Random jitter between searches (0–60s)

### TMDB Integration
- Daily scan: queries TMDB release dates for WEB-DL/WEBRip movies
- Detects physical releases (type 5) for Tier 4 promotion
- Detects streaming-only titles → applies `upgraderr-stream-only` tag
- Results cached 7 days

### Tag System
- `upgraderr-skip` — permanent user exclusion
- `upgraderr-no-source` — 3+ searches with no result, 90-day cooldown
- `upgraderr-stream-only` — no physical release, skip Tier 4
- `upgraderr-waiting-bluray` — upcoming BluRay release

### Web UI
- Dashboard: global pause toggle, searches today, queue depth per tier, activity feed
- Queue browser: paginated, filterable by tier/instance/status
- Search history with outcomes
- Settings: rate limits, instance enable/disable, tier enable/disable, TMDB toggle

### Auth + Security
- bcrypt password + JWT dual-token
- Login rate limiting (5/min per IP)

### Global Pause
- Toggle suspends searches while keeping discovery running
- Banner shown across all UI pages
- Telegram notification on pause/resume

### Notifications (Telegram)
- Dedicated upgrade channel (separate from main Mother notifications)
- Sweep completion summary
- Per-search notification
- BluRay availability alerts
- Daily digest

### Scheduled Jobs
- 30 min: discovery sweep
- 02:30 UTC: TMDB release date scan
- 03:00 UTC: DB backup
