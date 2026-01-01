# Real-Time Media Sync Setup

**Project:** Event-driven sync from Chris's Synology to Ali's Unraid
**Created:** 2026-01-01
**Status:** Ready for Deployment

---

## Overview

Replace polling-based sync with event-driven sync triggered by Radarr/Sonarr webhooks. When new content downloads, immediately sync just that file/folder to Unraid with notifications via Apprise/Telegram.

---

## Architecture

```
┌─────────────────┐     webhook      ┌──────────────────┐
│ Radarr/Sonarr   │ ──────────────→  │  Webhook Server  │
│ (download done) │                  │  (sync-webhook)  │
└─────────────────┘                  └────────┬─────────┘
                                              │
                                              ▼
                                     ┌──────────────────┐
                                     │  Targeted rsync  │
                                     │  (just new file) │
                                     └────────┬─────────┘
                                              │
                              ┌───────────────┴───────────────┐
                              ▼                               ▼
                     ┌──────────────┐                ┌──────────────┐
                     │   Apprise    │                │   Apprise    │
                     │  ✅ Success  │                │  ❌ Failure  │
                     │  (Telegram)  │                │  (Telegram)  │
                     └──────────────┘                └──────────────┘
```

---

## Components

### 1. Apprise (Notifications)

**Purpose:** Send notifications to Telegram (and later Discord)

**Docker Container:** `caronc/apprise`

**Configuration:**
- Telegram Bot Token: (to be created)
- Telegram Chat ID: (to be obtained)
- Future: Discord webhook URL

### 2. Sync Webhook Server

**Purpose:** Receive webhooks from Radarr/Sonarr, trigger targeted rsync

**Features:**
- Lightweight Python Flask/FastAPI server
- Parses webhook payload to get file path
- Translates Synology path → NFS mount path
- Runs rsync for just that specific file/folder
- Sends success/failure notification via Apprise

**Docker Container:** Custom (we'll build)

### 3. Radarr/Sonarr Webhook Configuration

**Webhook Events to Enable:**
- `On Import` - When a file is imported after download
- `On Upgrade` - When a file is upgraded to better quality

**Webhook URL:** `http://sync-webhook:5000/sync`

---

## Path Mappings

| Source (Synology via NFS) | Destination (Unraid via NFS) | Type |
|---------------------------|------------------------------|------|
| `/mnt/synology/rs-movies/` | `/mnt/unraid/media/Movies/` | Movies 1080p |
| `/mnt/synology/rs-4kmedia/4kmovies/` | `/mnt/unraid/media/4K Movies/` | Movies 4K |
| `/mnt/synology/rs-tv/` | `/mnt/unraid/media/TV Shows/` | TV 1080p |
| `/mnt/synology/rs-4kmedia/4ktv/` | `/mnt/unraid/media/4K TV Shows/` | TV 4K |

### Radarr/Sonarr Internal Paths → NFS Paths

Need to map from what Radarr/Sonarr sees to what Mother sees:

| Arr Container Path | Mother NFS Path |
|-------------------|-----------------|
| `/movies/` | `/mnt/synology/rs-movies/` |
| `/movies4k/` | `/mnt/synology/rs-4kmedia/4kmovies/` |
| `/tv/` | `/mnt/synology/rs-tv/` |
| `/tv4k/` | `/mnt/synology/rs-4kmedia/4ktv/` |

*(These may need adjustment based on actual Radarr/Sonarr container mappings)*

---

## Implementation Steps

### Phase 1: Apprise Setup - COMPLETE
- [x] Create Telegram Bot via @BotFather (Bishop - @BishopPrimeBot)
- [x] Get Chat ID for notifications (1264005957)
- [x] Test notification delivery - WORKING
- [x] Configure in .env file

### Phase 2: Webhook Server - COMPLETE
- [x] Create Python webhook server script (services/sync-webhook/app.py)
- [x] Handle Radarr webhook payload format
- [x] Handle Sonarr webhook payload format
- [x] Implement path translation logic
- [x] Implement targeted rsync function
- [x] Add Apprise notification calls
- [x] Create Dockerfile
- [x] Add to docker-compose.yml

### Phase 3: Radarr/Sonarr Configuration - PENDING
- [ ] Deploy sync-webhook container
- [ ] Configure webhook in Radarr-HD (http://sync-webhook:5000/sync/radarr)
- [ ] Configure webhook in Radarr-4K (http://sync-webhook:5000/sync/radarr)
- [ ] Configure webhook in Sonarr-HD (http://sync-webhook:5000/sync/sonarr)
- [ ] Configure webhook in Sonarr-4K (http://sync-webhook:5000/sync/sonarr)
- [ ] Test with actual download

### Phase 4: Testing & Monitoring
- [ ] Test Movies 1080p sync
- [ ] Test Movies 4K sync
- [ ] Test TV 1080p sync
- [ ] Test TV 4K sync
- [ ] Verify notifications on success
- [ ] Verify notifications on failure

### Phase 5: Future Enhancements (Optional)
- [ ] Add Discord notifications
- [ ] Add sync statistics/dashboard
- [ ] Add retry logic for failed syncs
- [ ] Add queue for multiple simultaneous downloads

---

## Deployment Instructions

### Step 1: Build and Start the Container

```bash
cd /home/alig/projects/mother

# Build the sync-webhook image
docker-compose build sync-webhook

# Start the container
docker-compose up -d sync-webhook

# Check logs
docker logs -f sync-webhook
```

### Step 2: Test the Webhook

```bash
# Health check
curl http://localhost:5001/health

# Test notification
curl -X POST http://localhost:5001/test
```

### Step 3: Configure Radarr Webhooks

For each Radarr instance (HD and 4K):

1. Go to Settings > Connect
2. Click + to add new connection
3. Select "Webhook"
4. Configure:
   - Name: `Sync to Unraid`
   - Notification Triggers:
     - [x] On Import
     - [x] On Upgrade
   - URL: `http://sync-webhook:5000/sync/radarr`
   - Method: POST
5. Click "Test" to verify
6. Save

### Step 4: Configure Sonarr Webhooks

For each Sonarr instance (HD and 4K):

1. Go to Settings > Connect
2. Click + to add new connection
3. Select "Webhook"
4. Configure:
   - Name: `Sync to Unraid`
   - Notification Triggers:
     - [x] On Import
     - [x] On Upgrade
   - URL: `http://sync-webhook:5000/sync/sonarr`
   - Method: POST
5. Click "Test" to verify
6. Save

---

## File Structure

```
/home/alig/projects/mother/
├── docker-compose.yml              # Updated with sync-webhook service
├── .env                            # Contains TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID
├── configs/
│   └── apprise/
│       └── apprise.yml             # Notification configuration (optional)
├── services/
│   └── sync-webhook/
│       ├── Dockerfile              # Python 3.11 + rsync
│       ├── requirements.txt        # Flask, gunicorn, apprise
│       └── app.py                  # Webhook server with rsync logic
└── docs/
    └── REALTIME_SYNC_SETUP.md      # This document
```

---

## Telegram Bot Setup Instructions

### Step 1: Create Bot
1. Open Telegram, search for `@BotFather`
2. Send `/newbot`
3. Choose a name: `Mother Sync Bot` (display name)
4. Choose a username: `mother_sync_bot` (must end in `bot`)
5. Save the **API Token** provided

### Step 2: Get Chat ID
1. Start a chat with your new bot (search for it, click Start)
2. Send any message to the bot
3. Visit: `https://api.telegram.org/bot<YOUR_TOKEN>/getUpdates`
4. Find your `chat.id` in the response
5. Save the **Chat ID**

### Step 3: Test
```bash
curl -X POST "https://api.telegram.org/bot<TOKEN>/sendMessage" \
  -d "chat_id=<CHAT_ID>" \
  -d "text=Test from Mother!"
```

---

## Apprise Configuration

### apprise.yml
```yaml
urls:
  # Telegram - Primary
  - tgram://<bot_token>/<chat_id>/?format=markdown

  # Discord - Future
  # - discord://<webhook_id>/<webhook_token>/
```

### Apprise URL Formats
- **Telegram:** `tgram://bot_token/chat_id/`
- **Discord:** `discord://webhook_id/webhook_token/`
- **Pushover:** `pover://user_key@app_token/`
- **Email:** `mailto://user:pass@gmail.com`

---

## Webhook Payload Examples

### Radarr (On Import)
```json
{
  "eventType": "Download",
  "movie": {
    "id": 1,
    "title": "Movie Title",
    "year": 2024,
    "folderPath": "/movies/Movie Title (2024)",
    "tmdbId": 123456
  },
  "movieFile": {
    "relativePath": "Movie Title (2024).mkv",
    "path": "/movies/Movie Title (2024)/Movie Title (2024).mkv",
    "size": 15000000000
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
  "episodeFile": {
    "relativePath": "Season 01/Series Title - S01E01 - Episode Name.mkv",
    "path": "/tv/Series Title (2020) {tvdb-123456}/Season 01/...",
    "size": 4000000000
  }
}
```

---

## Environment Variables

```bash
# Apprise
APPRISE_TELEGRAM_TOKEN=your_bot_token
APPRISE_TELEGRAM_CHAT_ID=your_chat_id

# Sync Webhook
SYNC_WEBHOOK_PORT=5000
SYNC_DRY_RUN=false
SYNC_LOG_LEVEL=INFO

# Path mappings (if needed to override)
SYNC_SOURCE_BASE=/mnt/synology
SYNC_DEST_BASE=/mnt/unraid/media
```

---

## Troubleshooting

### Webhook not receiving
- Check Radarr/Sonarr webhook configuration
- Verify container networking (same Docker network)
- Check webhook server logs

### Rsync failing
- Verify NFS mounts are active on Mother
- Check permissions on source/destination
- Test manual rsync with same paths

### Notifications not sending
- Test Apprise directly: `apprise -t "Test" -b "Body" "tgram://..."`
- Verify Telegram bot token and chat ID
- Check Apprise container logs

---

## Notes

- This runs on **Mother** (the middleman server with NFS mounts to both Synology and Unraid)
- Does NOT replace the quality comparison sync scripts - this is for NEW content only
- Uses `--ignore-existing` to avoid overwriting during main sync
- Webhook server should be lightweight and fast

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-01 | Initial plan created |
| 2026-01-01 | Built sync-webhook service, tested Telegram notifications |
