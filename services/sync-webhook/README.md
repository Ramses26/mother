# Sync Webhook Service

A lightweight Python Flask service that receives webhooks from Radarr/Sonarr and triggers immediate rsync to sync new content to a remote destination.

## Overview

When Radarr or Sonarr imports a new file (download complete), they send a webhook to this service. The service:

1. Parses the webhook payload to extract file/folder paths
2. Translates container paths to NFS mount paths
3. Runs rsync to copy the content to the destination
4. Sends a Telegram notification on success or failure

## Files

```
services/sync-webhook/
├── README.md           # This file
├── Dockerfile          # Python 3.11-slim + rsync
├── requirements.txt    # Flask, gunicorn, apprise, requests
└── app.py              # Main application (all logic in one file)
```

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check - returns status, timestamp, config info |
| `/test` | GET/POST | Send a test notification to Telegram |
| `/sync/radarr` | POST | Receive Radarr webhook, sync movie |
| `/sync/sonarr` | POST | Receive Sonarr webhook, sync episode |
| `/sync/manual` | POST | Manually trigger sync for a path |

### Health Check Response
```json
{
  "status": "healthy",
  "timestamp": "2026-01-01T12:00:00",
  "dry_run": false,
  "notifications": true
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
| `TZ` | `UTC` | Timezone for timestamps |

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
- Server: gunicorn with 2 workers
- Health check: Built-in

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

## Related Documentation

- [REALTIME_SYNC_SETUP.md](../../docs/REALTIME_SYNC_SETUP.md) - Full setup guide
- [docker-compose.yml](../../docker-compose.yml) - Container configuration
