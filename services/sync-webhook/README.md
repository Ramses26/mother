# Sync Webhook Service (V2)

A Python Flask service that receives webhooks from Radarr/Sonarr, triggers immediate rsync to sync new content, with job tracking, auto-retry, and daily summaries.

## Overview

When Radarr or Sonarr imports a new file (download complete), they send a webhook to this service. The service:

1. Parses the webhook payload to extract file/folder paths
2. Checks NFS mount health before proceeding
3. Translates container paths to NFS mount paths
4. Logs the job to SQLite database
5. Runs rsync in background thread (webhook returns immediately)
6. Sends a Telegram notification on success or failure
7. Auto-retries failed jobs every 15 minutes
8. Sends daily summary report at midnight

## Files

```
services/sync-webhook/
├── README.md           # This file
├── Dockerfile          # Python 3.11-slim + rsync
├── requirements.txt    # Flask, gunicorn, apprise, apscheduler
└── app.py              # Main application
```

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check with NFS status, job counts, uptime |
| `/stats` | GET | Sync statistics (session + database totals) |
| `/jobs` | GET | List recent jobs (?limit=N&status=failed) |
| `/jobs/<id>` | GET | Get specific job details |
| `/jobs/<id>/retry` | POST | Retry a specific failed job |
| `/queue/retry-failed` | POST | Retry all failed jobs from last 24h |
| `/test` | GET/POST | Send a test notification to Telegram |
| `/summary/send` | GET/POST | Manually trigger daily summary |
| `/sync/radarr` | POST | Receive Radarr webhook, sync movie |
| `/sync/sonarr` | POST | Receive Sonarr webhook, sync episode |
| `/sync/manual` | POST | Manually trigger sync for a path |

### Health Check Response
```json
{
  "status": "healthy",
  "timestamp": "2026-01-01T12:00:00",
  "dry_run": false,
  "notifications": true,
  "nfs_status": "ok",
  "nfs_issues": [],
  "jobs_24h": {"success": 15, "failed": 2},
  "uptime_since": "2026-01-01T00:00:00"
}
```

### Stats Response
```json
{
  "movies_synced": 10,
  "episodes_synced": 25,
  "failures": 2,
  "bytes_transferred": 150000000000,
  "bytes_transferred_human": "139.7 GB",
  "total_successful": 100,
  "total_failed": 5,
  "today_successful": 10,
  "today_failed": 1
}
```

### Manual Sync Request
```bash
curl -X POST http://localhost:5001/sync/manual \
  -H "Content-Type: application/json" \
  -d '{"path": "/movies/Movie Name (2024)", "type": "movie"}'
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `TELEGRAM_BOT_TOKEN` | (required) | Telegram bot API token |
| `TELEGRAM_CHAT_ID` | (required) | Telegram chat ID for notifications |
| `SYNC_DRY_RUN` | `false` | If `true`, rsync runs with `--dry-run` |
| `SYNC_LOG_LEVEL` | `INFO` | Logging level (DEBUG, INFO, WARNING, ERROR) |
| `SYNC_LOG_PATH` | `/logs` | Directory for persistent log files |
| `SYNC_DB_PATH` | `/data/sync_jobs.db` | SQLite database path |
| `TZ` | `UTC` | Timezone for timestamps |

### Plex Integration (Optional)

| Variable | Description |
|----------|-------------|
| `PLEX_URL` | Plex server URL (e.g., `http://10.0.0.50:32400`) |
| `PLEX_TOKEN` | Plex authentication token |
| `PLEX_SECTION_MOVIES` | Library section ID for Movies |
| `PLEX_SECTION_MOVIES_4K` | Library section ID for 4K Movies |
| `PLEX_SECTION_TV` | Library section ID for TV Shows |
| `PLEX_SECTION_TV_4K` | Library section ID for 4K TV Shows |

When configured, the service triggers a targeted Plex library scan after each successful sync.

### Finding Plex Section IDs

```bash
# Get all library sections
curl "http://PLEX_IP:32400/library/sections?X-Plex-Token=YOUR_TOKEN"
```

Look for `<Directory>` entries with `key="1"`, `key="2"`, etc. The `key` is the section ID.

### Getting Plex Token

1. Sign in to Plex Web App
2. Open any media item
3. Click "Get Info" → "View XML"
4. Look for `X-Plex-Token=` in the URL

## Persistent Storage

The container stores logs and job database in mounted volumes:

```yaml
volumes:
  - ${CONFIG_PATH}/sync-webhook/logs:/logs    # Log files
  - ${CONFIG_PATH}/sync-webhook/data:/data    # SQLite database
```

**Log files created:**
- `sync_webhook.log` - Full application logs (10MB rotation, 5 backups)
- `sync_history.log` - Human-readable sync history (10MB rotation, 10 backups)

## Scheduled Tasks (Built-in)

The service includes APScheduler for automatic background tasks:

| Task | Schedule | Description |
|------|----------|-------------|
| Daily Summary | 00:05 | Sends Telegram summary with failed titles and items needing attention |
| Auto-Retry | Every 15 min | Retries failed jobs (up to 3 attempts per job) |
| Startup Recovery | On start | Recovers in-progress jobs interrupted by restart |

**These run automatically when the container starts - no cron setup needed.**

## Reliability Features

### In-Progress Tracking
Jobs are marked as `in_progress` in the database when they start. If the container restarts mid-sync:
1. On startup, finds all `in_progress` jobs (interrupted)
2. Marks them as failed with "Interrupted by restart"
3. Automatically queues them for retry

### Retry Logic (Up to 3 Attempts)
- Failed jobs automatically retry every 15 minutes
- Each job tracks its `retry_count` in the database
- Jobs retry up to 3 times before giving up
- Successfully synced jobs are excluded from retry
- Logs show attempt number: `(retry 1/3)`, `(retry 2/3)`, etc.

### Daily Summary Report
The 00:05 daily summary includes:
- Success/failure counts
- Movies and episodes synced
- Total data transferred
- **List of failed sync titles** (up to 5)
- **"Needs Attention" section** for unresolved failures

## Path Mappings

The service translates paths from what Radarr/Sonarr sees (container paths) to what the sync-webhook container sees (NFS mounts):

| Container Path | Source (Synology NFS) | Destination (Unraid NFS) |
|----------------|----------------------|--------------------------|
| `/movies` | `/mnt/synology/rs-movies` | `/mnt/unraid/media/Movies` |
| `/movies-4k` | `/mnt/synology/rs-4kmedia/4kmovies` | `/mnt/unraid/media/4K Movies` |
| `/tv` | `/mnt/synology/rs-tv` | `/mnt/unraid/media/TV Shows` |
| `/tv-4k` | `/mnt/synology/rs-4kmedia/4ktv` | `/mnt/unraid/media/4K TV Shows` |

### Modifying Path Mappings

Edit the `PATH_MAPPINGS` dictionary in `app.py`:

```python
PATH_MAPPINGS = {
    '/movies': (
        '/mnt/synology/rs-movies',      # Source
        '/mnt/unraid/media/Movies'       # Destination
    ),
    # Add more mappings as needed
}
```

## Rsync Behavior

The service uses rsync with these flags:

```bash
rsync -avh --ignore-existing --exclude='#recycle' --exclude='@eaDir' --exclude='.DS_Store' <source> <dest>/
```

- `-a`: Archive mode (preserves permissions, timestamps, etc.)
- `-v`: Verbose output
- `-h`: Human-readable sizes
- `--ignore-existing`: Skip files that already exist on destination
- Excludes Synology recycle bin and metadata folders

## Docker Configuration

### Dockerfile
- Base: `python:3.11-slim`
- Installs: rsync
- Runs as: non-root user (uid 1000)
- Server: gunicorn with 1 worker + 4 threads (prevents multiple schedulers)
- Health check: Built-in
- Rsync timeout: 4 hours (for large files over NFS)

### Required Volume Mounts

The container needs access to both source and destination NFS mounts:

```yaml
volumes:
  # Source (read-only)
  - /mnt/synology/rs-movies:/mnt/synology/rs-movies:ro
  - /mnt/synology/rs-tv:/mnt/synology/rs-tv:ro
  - /mnt/synology/rs-4kmedia:/mnt/synology/rs-4kmedia:ro
  # Destination (read-write)
  - /mnt/unraid/media:/mnt/unraid/media
```

## Radarr/Sonarr Webhook Configuration

### Radarr Settings
1. Settings → Connect → Add → Webhook
2. Name: `Sync to Unraid`
3. Triggers: ✅ On Import, ✅ On Upgrade
4. URL: `http://sync-webhook:5000/sync/radarr`
5. Method: POST

### Sonarr Settings
1. Settings → Connect → Add → Webhook
2. Name: `Sync to Unraid`
3. Triggers: ✅ On Import, ✅ On Upgrade
4. URL: `http://sync-webhook:5000/sync/sonarr`
5. Method: POST

## Webhook Payload Examples

### Radarr (On Import)
```json
{
  "eventType": "Download",
  "movie": {
    "id": 1,
    "title": "Movie Title",
    "year": 2024,
    "folderPath": "/movies/Movie Title (2024)"
  },
  "movieFile": {
    "path": "/movies/Movie Title (2024)/Movie.Title.2024.1080p.BluRay.mkv",
    "size": 15000000000,
    "quality": {"quality": {"name": "Bluray-1080p"}}
  }
}
```

### Sonarr (On Import)
```json
{
  "eventType": "Download",
  "series": {
    "id": 1,
    "title": "Series Title",
    "path": "/tv/Series Title (2020) {tvdb-123456}"
  },
  "episodes": [
    {"seasonNumber": 1, "episodeNumber": 5, "title": "Episode Title"}
  ],
  "episodeFile": {
    "path": "/tv/Series Title (2020) {tvdb-123456}/Season 01/...",
    "size": 4000000000,
    "quality": {"quality": {"name": "WEBDL-1080p"}}
  }
}
```

## Notification Format

### Success (Movie)
```
Title: Movie Synced
Body:
*Movie Title* (2024)
Quality: Bluray-1080p
Size: 14.0 GB
Duration: 45.2s
```

### Success (Episode)
```
Title: Episode Synced
Body:
*Series Title*
S01E05: Episode Title
Quality: WEBDL-1080p
Size: 3.7 GB
Duration: 12.1s
```

### Failure
```
Title: Sync Failed - Movie
Body:
*Movie Title* (2024)

Error: rsync error message...
```

## Troubleshooting

### Container won't start
```bash
# Check logs
docker logs sync-webhook

# Verify NFS mounts exist on host
ls -la /mnt/synology/rs-movies
ls -la /mnt/unraid/media
```

### Webhook not receiving
```bash
# Test from Radarr/Sonarr container
curl -X POST http://sync-webhook:5000/sync/radarr \
  -H "Content-Type: application/json" \
  -d '{"eventType": "Test"}'

# Check container is on same network
docker network inspect mother_mother_network
```

### Rsync failing
```bash
# Enable debug logging
SYNC_LOG_LEVEL=DEBUG

# Test rsync manually
docker exec -it sync-webhook rsync -avhn \
  /mnt/synology/rs-movies/TestMovie \
  /mnt/unraid/media/Movies/
```

### Notifications not sending
```bash
# Test endpoint
curl -X POST http://localhost:5001/test

# Check Telegram credentials in container
docker exec sync-webhook env | grep TELEGRAM

# Test Telegram API directly
curl "https://api.telegram.org/bot<TOKEN>/sendMessage" \
  -d "chat_id=<CHAT_ID>" \
  -d "text=Test"
```

### Path translation issues
```bash
# Check what path Radarr/Sonarr sends
docker logs sync-webhook | grep "File path:"

# Verify PATH_MAPPINGS in app.py matches your setup
```

## Development

### Run locally (without Docker)
```bash
cd services/sync-webhook
pip install -r requirements.txt
export TELEGRAM_BOT_TOKEN=your_token
export TELEGRAM_CHAT_ID=your_chat_id
export SYNC_DRY_RUN=true
python app.py
```

### Test with sample webhook
```bash
curl -X POST http://localhost:5000/sync/radarr \
  -H "Content-Type: application/json" \
  -d '{
    "eventType": "Download",
    "movie": {"title": "Test Movie", "year": 2024, "folderPath": "/movies/Test Movie (2024)"},
    "movieFile": {"path": "/movies/Test Movie (2024)/test.mkv", "size": 1000000000, "quality": {"quality": {"name": "Test"}}}
  }'
```

## Changelog

| Date | Change |
|------|--------|
| 2026-01-01 | Initial version |
| 2026-01-02 | V2: SQLite job tracking, auto-retry, daily summary, NFS health checks |
| 2026-01-02 | Added Plex library scan after sync (with path translation) |
| 2026-01-03 | V2.1: In-progress tracking, startup recovery, up to 3 retries |
| 2026-01-03 | Daily summary now lists failed titles and unresolved items |
| 2026-01-03 | Increased rsync timeout to 4 hours, fixed gunicorn to 1 worker |

## Related Documentation

- [REALTIME_SYNC_SETUP.md](../../docs/REALTIME_SYNC_SETUP.md) - Full setup guide
- [docker-compose.yml](../../docker-compose.yml) - Container configuration
