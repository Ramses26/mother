# Curatorr — User Guide

Curatorr is a media intelligence and curation service running at `http://mother:9707`.
It connects to Radarr, Sonarr, Plex, and Tautulli to give you a unified view of your
combined 160TB+ media library with composite ratings, purge analysis, and deletion tools.

---

## Quick Start

1. Browse to `http://mother:9707`
2. Login with the admin password (set via `CURATORR_ADMIN_PASSWORD` in `.env`)
3. The dashboard shows library stats immediately — sync happens automatically every 6 hours
4. To sync on demand: Dashboard → **Sync Now**, or Settings → Manual Sync

---

## Navigation

| Page | What it does |
|------|-------------|
| Dashboard | Stats, histogram, purge candidates, sync status |
| Movies | Full movie library with filters and sort |
| TV Shows | Full TV library with filters and sort |
| Collections | TMDB collection completeness |
| Duplicates | Detect duplicate media |
| Rules | Create automated curation rules |
| Logs | Event log for sync/deletion/rule activity |
| Settings | URLs, password, backup, sync controls |

---

## Movies & TV Shows

### Poster Grid vs Table View
Toggle between poster grid and table view using the icons in the toolbar.

### Filters
The left sidebar contains filters:
- **Composite Score** slider (0–10)
- **Resolution**: 4K, 1080p, 720p, SD
- **HDR**: DolbyVision, HDR10+, HDR10
- **Watch Status**: Never Watched, Ali Watched, Chris Watched, Both Watched
- **Genres**: multi-select
- **Status** (TV): Continuing, Ended, Cancelled

### Filter Presets
Quick preset buttons above the grid:
- **Purge Candidates** — purge score ≥ 50
- **Never Watched** — zero plays by both users
- **Low Rated** — composite score < 5.0
- **4K** — 4K resolution
- **Recently Added** — added in last 30 days

Click an active preset again to clear all filters.

### Column Visibility (Table View)
Click the gear icon in the toolbar to show/hide columns. State is saved per view in localStorage.

### Media Detail Panel
Click any movie/show to open the detail panel:
- Full metadata, ratings, watch history, file info
- Season progress (TV)
- **Close**: click the × button (top-right) or click the dark backdrop
- **Unmonitor**: removes from *arr search queue
- **Delete**: calls *arr API + removes from Unraid NFS (with confirmation)
- **External links**: "Open in Radarr/Sonarr" (requires Public URLs configured in Settings)

---

## Composite Score

Weighted average of 5 external rating sources (0–10 scale):

| Source | Weight |
|--------|--------|
| IMDb | 35% |
| Rotten Tomatoes Critics | 25% |
| MDBList | 20% |
| Metacritic | 15% |
| TMDB | 5% |

The composite score only includes sources with data — missing sources are excluded from the average.

---

## Purge Score

Deletion candidate score (0–100). Higher = stronger candidate.

| Factor | Points |
|--------|--------|
| Composite < 5.0 | up to +50 |
| Never watched by either user | +20 |
| Watched once total | +10 |
| Resolution 720p or SD | +15 |
| Cancelled show, both watched | +10 |
| High rating ≥ 8.5 | −20 (protection) |

Color guide: **Green** <30 · **Yellow** 30–54 · **Orange** 55–74 · **Red** 75+

---

## Rating Histogram

The Dashboard histogram shows the distribution of ratings in your library.

Use the source toggle pills below the histogram to switch between:
- **Composite** — the weighted average (default)
- **IMDb** — raw IMDb scores (0–10 scale)
- **RT Critics** — Rotten Tomatoes (0–100 scale)
- **Metacritic** — Metacritic (0–100 scale)
- **MDBList** — MDBList score (0–100 scale)

Click a bar in Composite mode to jump to Movies/TV filtered by that score range.

---

## Collections

The Collections page shows TMDB movie collections (franchises, series) and how complete your library is.

1. Click a collection to view its movies
2. Missing movies load automatically from TMDB
3. Click **Request via Overseerr** on a missing movie to add it to your request queue
4. Requires `OVERSEERR_URL` configured in Settings → Public URLs

---

## Rules Engine

Create automated rules to stage, unmonitor, delete, or notify about media matching your criteria.

### Creating a Rule
1. Rules → **New Rule**
2. Set name, media type (movies/TV), and schedule (daily/weekly/manual)
3. Add conditions using AND/OR logic
4. Set action: Stage, Unmonitor, Delete, or Notify
5. Enable "Send notification" to get Telegram alerts on matches

### Available Conditions
- Composite score, IMDb, RT, Metacritic, MDBList, TMDB rating
- Purge score
- Resolution, HDR format
- Watch status (ali plays, chris plays)
- Year, genres, status (TV)
- File size

### Example Rules
- **Cleanup low-rated unwatched**: composite < 4.0 AND ali_play_count = 0 AND chris_play_count = 0 → Stage
- **Upgrade candidates**: resolution = 720p AND purge_score < 30 → Notify
- **Finished cancelled shows**: status = Cancelled AND ali_play_count > 0 AND chris_play_count > 0 → Stage

### Rule Matches
After a rule runs, matches appear in the rule's match list. You can exclude individual items before executing the action.

---

## Deletion Workflow

Deleting from Curatorr does two things:
1. Calls the *arr API (`DELETE /api/v3/movie/{id}?deleteFiles=true`)
2. Removes the file/directory from the Unraid NFS mount (`/mnt/unraid/media`)

Both steps are logged in the deletion_log table with success/failure flags.
A Telegram notification is sent on every deletion.

**Note**: Deletion from Curatorr does NOT automatically remove from the Synology NAS — Radarr/Sonarr handle that via their delete API. The Unraid path deletion removes it from Ali's side.

---

## Logs Page

The Logs page shows the last 2000 system events. Events are written during:
- Library syncs (each Radarr/Sonarr/Plex/Tautulli instance)
- Deletions
- Rule runs
- Errors

Use the filter dropdowns to narrow by event type, level (info/warning/error), or source.

---

## Settings

### Public URLs
Configure deep links so "Open in Radarr/Sonarr" buttons work in the detail panel:
- Radarr HD Public URL: `https://radarrhd.stuttler.net`
- Radarr 4K Public URL: `https://radarr4k.stuttler.net`
- Sonarr HD Public URL: `https://sonarrhd.stuttler.net`
- Sonarr 4K Public URL: `https://sonarr4k.stuttler.net`
- Overseerr URL: `https://request.stuttler.net`

These are saved to the database config table and take effect immediately.

### Manual Sync
Trigger individual sync sources without waiting for the scheduler:
- **Sync Everything** — all sources in sequence
- **Radarr** — movie metadata from Radarr HD + 4K
- **Sonarr** — TV metadata from Sonarr HD + 4K
- **Plex** — file metadata from Chris + Ali Plex
- **Tautulli** — watch history delta from Chris + Ali Tautulli
- **Ratings** — refresh OMDB + MDBList + TMDB ratings

### Database Backups
Curatorr automatically backs up the database daily at 04:30 UTC.
Backups are stored in `/opt/mother/data/curatorr/backups/`.

From Settings you can:
- Create a backup manually
- Download any backup
- View backup list with size and date

### Password
Change the admin password from Security section. Bcrypt-hashed, no plain-text storage.

---

## Sync Sources & Schedules

| Source | Schedule | What it updates |
|--------|----------|----------------|
| Radarr HD/4K | Every 6h | Movie metadata, quality, file info, posters |
| Sonarr HD/4K | Every 6h | TV metadata, seasons, episode counts, posters |
| Plex (Chris + Ali) | Every 6h | File paths, codecs, resolution, plex keys |
| Tautulli (Chris + Ali) | Daily 02:00 | Watch history, play counts, last-watched dates |
| Ratings | Daily 03:00 | IMDb via OMDB, RT/Metacritic/MDB via MDBList, TMDB |
| Rules | Daily 04:00 | Evaluate scheduled rules |
| DB Backup | Daily 04:30 | SQLite backup to `/data/backups/` |
| Weekly Digest | Sun 09:00 | Telegram summary of library stats |

Sync status is visible on the Dashboard. If a source shows "Not configured", the URL
or API key for that service is not set in `.env`.

---

## Troubleshooting

**Sync shows "not_configured"**: The URL or token for that service isn't set in `.env`.
Check `CHRIS_PLEX_TOKEN`, `ALI_TAUTULLI_URL`, `ALI_TAUTULLI_KEY`, etc.

**Posters not loading**: Posters come from TMDB via `remotePoster` URLs from Radarr/Sonarr.
No Plex required. If posters are missing, the item may not have a TMDB ID assigned.

**"Open in Radarr" link missing**: Configure Public URLs in Settings.

**Deletion failed on Unraid**: The Unraid NFS mount may be stale. Check:
```bash
timeout 5 ls /mnt/unraid/media/ && echo OK
# If hung: sudo umount -l /mnt/unraid/media && sudo mount /mnt/unraid/media
```

**Container logs**:
```bash
docker logs curatorr --tail 100 -f
```
