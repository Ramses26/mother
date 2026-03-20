# Upgraderr

Custom quality upgrade automation service for Project Mother. Replaces Huntarr.

**UI**: `http://mother:9706` — JWT login required
**Container**: `upgraderr` — port 9706 (host) → 5000 (container)
**Source**: `services/upgraderr/app.py` (Flask + APScheduler + SQLite)

---

## Purpose

Upgraderr replaces Huntarr because:
- Huntarr does not use TRaSH-aligned quality scoring
- Cannot handle all 4 *arr instances with different scoring rules (TV vs movies)
- No TMDB integration for physical release date detection
- Huntarr had abandoned upstream / security concerns

Upgraderr uses the same `scripts/lib/quality_scoring.py` shared module as the sync scripts.

---

## Upgrade Tiers

Items are classified into 6 tiers, processed in priority order:

| Tier | Description | Condition |
|------|-------------|-----------|
| 1 | m2ts / BDMV | File is `.m2ts`, `.bdmv`, or a Blu-ray folder structure |
| 2 | Non-MKV container | File is `.avi`, `.mp4`, `.mkv` not yet — any non-MKV |
| 3 | 720p / SD | Resolution is 720p, 480p, or SD |
| 4 | TMDB BluRay available | TMDB shows a physical release (type 5) ≥ 90 days ago (movies only) |
| 5 | No surround audio | No DD 5.1 / DTS / Atmos detected; skips pre-1992 movies |
| 6 | Low TRaSH score | Quality score below instance threshold |

---

## Key Behaviors

### Discovery Sweep (every 30 min)
- Queries all 4 *arr instances for their libraries
- Classifies each item into its highest applicable tier
- Upserts into `upgrade_queue` with `before_quality` / `before_score`
- **Skips** items tagged `upgraderr-skip` (permanent) or `upgraderr-no-source`
- **Defers** sweep entirely if batch sync is actively writing (checks `/opt/sync_reports/` log mtime < 120s)

### Search Budget
- Per-instance daily search limit stored in `config` table
- Adaptive cooldown: 24h → 7d → 14d → 30d based on consecutive failed searches
- Global pause toggle via Settings page (searches stop, discovery continues)

### TV Season Grouping
- Episodes grouped by season; if ≥ 50% of season qualifies → `SeasonSearch`
- Otherwise individual episode searches

### TMDB Tier 4
- Calls `https://api.themoviedb.org/3/movie/{tmdb_id}/release_dates`
- Type 5 = Physical (BluRay/DVD) release
- Results cached 7 days in `tmdb_cache` table
- Daily scan job runs at 02:30 UTC to populate cache proactively
- Env var: `TMDB_API_KEY` (set in `.env`), `UPGRADERR_BLURAY_WAIT_DAYS` (default 90)

### Instance Health
- Each *arr instance checked with 3s timeout GET to `/api/v3/system/status`
- Green/red dot shown on dashboard
- Docker internal ports used (radarr-hd:7878, radarr-4k:7878, sonarr-hd:8989, sonarr-4k:8989)

### Webhook Integration (Before/After Tracking)
Configure each *arr instance: **Settings → Connect → + Webhook**

| Instance | URL |
|----------|-----|
| radarr-hd | `http://upgraderr:5000/webhook/radarr` |
| radarr-4k | `http://upgraderr:5000/webhook/radarr` |
| sonarr-hd | `http://upgraderr:5000/webhook/sonarr` |
| sonarr-4k | `http://upgraderr:5000/webhook/sonarr` |

Events to enable: **On Upgrade** (and optionally On Import).
The webhook records `after_quality` / `after_score` on the queue entry → visible in **Upgrades** history page.

Webhook endpoints are unauthenticated but restricted to internal IPs (172.x, 10.x, 192.168.x, 127.0.0.1).

---

## Environment Variables

Add to `.env`:

```bash
UPGRADERR_ADMIN_PASSWORD=<your-password>
UPGRADERR_SECRET_KEY=<random-secret>
UPGRADERR_TELEGRAM_CHAT_ID=-5187870710   # dedicated upgrade Telegram channel
TMDB_API_KEY=<your-tmdb-key>
UPGRADERR_BLURAY_WAIT_DAYS=90            # days after physical release before Tier 4 triggers
RSYNC_STALL_MINUTES=15                   # (sync-webhook) stall detection threshold
RSYNC_MAX_MINUTES=240                    # (sync-webhook) max rsync runtime
```

All 4 *arr API keys are already present from sync-webhook config.

---

## Database

SQLite at `/data/upgraderr.db` (volume: `data/upgraderr/`).

| Table | Purpose |
|-------|---------|
| `upgrade_queue` | All discovered items with tier, score, before/after quality |
| `search_log` | Every search triggered with result |
| `daily_stats` | Per-day search counts per instance |
| `config` | Key/value: pause state, search budgets, TMDB API key |
| `upgrade_history` | Completed upgrades (populated by webhooks) |
| `tmdb_cache` | TMDB physical release dates (7-day TTL) |

---

## API Endpoints

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/health` | None | Health check |
| GET | `/api/stats` | None (internal IP) | Queue stats for daily_report.py |
| GET | `/api/queue` | JWT | Paginated queue |
| POST | `/api/queue/<id>/search` | JWT | Trigger manual search |
| GET | `/upgrades` | JWT | Upgrade history page |
| POST | `/webhook/radarr` | None (internal IP) | Radarr upgrade webhook |
| POST | `/webhook/sonarr` | None (internal IP) | Sonarr upgrade webhook |
| POST | `/api/settings` | JWT | Save settings |
| POST | `/api/pause` | JWT | Toggle pause |

---

## Scheduled Jobs

| Job | Schedule | Description |
|-----|----------|-------------|
| `_run_sweep` | Every 30 min | Discovery + search sweep |
| `_scan_tmdb_releases` | 02:30 UTC daily | Pre-populate TMDB cache |
| DB backup | 03:00 UTC daily | Copy SQLite to `/data/upgraderr_backup.db` |

---

## Operations

```bash
# View logs
docker logs upgraderr --tail 100

# Rebuild after code change
docker compose build upgraderr && docker compose up -d upgraderr

# Check health
curl http://localhost:9706/health

# Manual trigger via UI
# Settings → "Run Sweep Now" button

# Pause all searches (discovery continues)
# Settings → Pause toggle

# Enable upgrades (after sync complete)
# 1. Update configs/recyclarr/recyclarr.yml → upgrade: allowed: true
# 2. Run recyclarr: docker exec recyclarr recyclarr sync
# 3. Settings → enable each instance
# 4. Settings → Reset Queue & History (rediscovers with upgrade paths open)
```

---

## Current Status (as of 2026-03-20)

- **Paused** — waiting for 1080p movie batch sync to complete (~3-7 days from 2026-03-19)
- Discovery is running, queue populated with 2,976 items
- Searches are suspended via global pause toggle
- Radarr/Sonarr webhooks not yet configured (manual step after enabling upgrades)
