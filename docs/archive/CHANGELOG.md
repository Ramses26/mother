# Changelog

## Curatorr v1.1.0 — Sprint 2: Enhancement & Polish (2026-03-21)

### New Features
- **Public URL deep links** — "Open in Radarr/Sonarr" links now use configurable public URLs (set via Settings page or env vars). Supports NPM/reverse-proxy public hostnames.
- **TMDB posters** — Movie and TV posters now sourced from Radarr/Sonarr's `remotePoster` field (TMDB CDN). No Plex dependency for poster display; Plex proxy is fallback only.
- **TV Shows poster grid** — TV Shows page now has a poster grid view (same as Movies), with completion bar and watch status on hover.
- **Column visibility** — Movies and TV tables have a gear icon to toggle optional columns: Year, IMDb, RT Critics, Metacritic, MDBList, HDR, File Size, Watched, Date Added. Preferences saved to localStorage.
- **Rating columns in tables** — IMDb, RT, Metacritic, MDBList columns now available in both Movies and TV tables.
- **Preset toggle** — Clicking an already-active filter preset now clears all filters (toggle behavior).
- **"Both Watched" filter** — New filter for movies and TV: show only items watched by both Ali and Chris.
- **Sync progress polling** — "Sync Now" button shows live per-source spinner while syncing, updating every 3s for up to 2 minutes.
- **Histogram source toggle** — Rating distribution histogram has source toggle pills (Composite, IMDb, RT, Metacritic, MDBList). Currently displays composite; per-source in future sprint.
- **Purge score tooltip** — Hovering any purge score badge shows a tooltip explaining the formula and color thresholds.
- **TV completion tooltip** — Hovering the "Completion" column header explains what the percentage means.
- **Collections: missing movies** — "Check Missing" button fetches TMDB collection data and shows movies not in library with poster, rating, and "Request via Overseerr" button.
- **Collections: Overseerr request** — Request missing collection movies directly through Overseerr API.
- **Activity Log page** — New `/logs` page showing event_log entries with type/level/source filters and pagination.
- **Settings: Public URLs editing** — Configure Radarr/Sonarr/Overseerr public URLs directly in the Settings page; saved to DB config table (overrides env vars).
- **Settings: DB Backup management** — List backups, create new backup on demand, download any backup file.
- **Duplicati container** — Backup client added to docker-compose. Configure via web UI at port 8200.

### Backend Changes
- `app/config.py`: Added `RADARR_HD_PUBLIC_URL`, `RADARR_4K_PUBLIC_URL`, `SONARR_HD_PUBLIC_URL`, `SONARR_4K_PUBLIC_URL`, `OVERSEERR_URL` env vars. VERSION → 1.1.0.
- `app/database.py`: Added `poster_url TEXT` column to `movies` and `tv_shows`. Added `event_log` table. Migration runs at startup.
- `app/sync/radarr.py`: Saves `remotePoster` as `poster_url` during Radarr sync.
- `app/sync/sonarr.py`: Saves `remotePoster` as `poster_url` during Sonarr sync.
- `app/routes/settings.py`: Added `public_urls` to GET /settings, new PATCH /settings/connections, GET /settings/backups, POST /settings/backups/create, GET /settings/backups/{filename}.
- `app/routes/logs.py`: New — paginated event log API.
- `app/routes/collections.py`: Added GET /collections/{id}/missing (TMDB lookup), POST /collections/{id}/request/{tmdb_id} (Overseerr).
- `app/routes/movies.py`: Added `both_watched` filter.
- `app/routes/tv.py`: Added `both_watched` filter.
- `app/main.py`: Registered logs router.

### Frontend Changes
- `App.vue`: Provides `publicUrls` via Vue inject to all child components; loads on auth.
- `router/index.js`: Added `/logs` route.
- `components/MediaDetail.vue`: Uses injected `publicUrls` for Radarr/Sonarr deep links. Added TMDB poster display (with Plex fallback). Added purge score tooltip.
- `views/Movies.vue`: Preset toggle (clicking active clears), TMDB poster, `both_watched` filter, column visibility gear, optional rating columns.
- `views/TvShows.vue`: Poster grid view mode, preset toggle, `both_watched` filter, column visibility gear, optional rating columns, completion tooltip.
- `views/Dashboard.vue`: Sync progress polling (3s interval, 2min max), histogram source toggle pills.
- `views/Collections.vue`: Missing movies section with "Check Missing" + "Request via Overseerr".
- `views/Logs.vue`: New — event log browser with type/level/source filters.
- `views/Settings.vue`: Public URLs editing form, DB backup list/create/download.

### Infrastructure
- `docker-compose.yml`: Added Duplicati container (port 8200). Added public URL env vars to Curatorr service.
- `.env.example`: Added public URL vars and Duplicati port.

---

## Curatorr v1.0.0 — Sprint 1: Full Build (2026-03-20)

### Initial Build — All 8 Phases

- **Auth**: JWT dual-token (access 1h + refresh 7d), bcrypt passwords, HttpOnly cookies, rate-limited login (5/min per IP), first-run setup flow.
- **Database**: aiosqlite WAL mode. 11 tables: movies, tv_shows, tv_seasons, ratings_cache, collections, watch_history, rules, rule_matches, deletion_log, config, sync_log.
- **Radarr sync**: All 4 instances (HD + 4K). Extracts resolution, codecs, HDR, file size, collection membership.
- **Sonarr sync**: All 4 instances. Season completion percentage per show.
- **Plex sync**: Chris + Ali Plex XML API. Updates resolution, codecs, plex_key, added_at.
- **Tautulli sync**: Both instances. Delta watch history sync. Updates ali/chris play counts and last_watched.
- **Ratings**: OMDB (IMDb + Metacritic + RT), MDBList (aggregated), TMDB ratings. 7-day cache.
- **Scoring**: Composite score (IMDb 35%, RT 25%, MDBList 20%, Metacritic 15%, TMDB 5%). Purge score (0-100).
- **Rules engine**: Visual condition builder (AND/OR), 15 field types, 10 operators, actions (stage/unmonitor/delete), scheduling (manual/daily/weekly).
- **Direct deletion**: Calls *arr API + removes file from Unraid NFS path. Audit log.
- **Collections**: TMDB collection tracking, owned vs total count.
- **Duplicates**: Same TMDB + same resolution tier grouping.
- **Dashboard**: Movie/TV counts, rating histogram, top purge candidates, recent additions, sync status.
- **APScheduler**: 6h library sync, 02:00 watch history, 03:00 ratings refresh, 04:00 rules, 04:30 backup, Sun 09:00 digest.
- **Port**: 9707 (host) → 8000 (container). FastAPI + Vue 3 SPA.
