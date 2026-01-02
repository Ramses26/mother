# Syncthing Setup Plan - Project Mother

**Status:** On Hold - sync-webhook recommended instead
**Purpose:** Alternative to webhook-based sync for 1:1 mirror

> **Note:** After evaluation, sync-webhook is recommended over Syncthing because:
> 1. **Plex Integration** - sync-webhook can trigger targeted Plex library scans after each sync
> 2. **Notification Quality** - sync-webhook sends rich notifications with movie/show details
> 3. **Already Working** - sync-webhook is deployed and functional
>
> This plan is kept for reference if we want to evaluate Syncthing in the future.

---

## Overview

Once the initial quality comparison sync is complete, we'll transition from the webhook-based rsync approach to Syncthing for ongoing real-time synchronization.

```
┌─────────────────────┐              ┌─────────────────────┐
│   Chris's Synology  │              │    Ali's Unraid     │
│    (10.0.0.100)     │              │    (10.0.0.50)      │
│                     │   Syncthing  │                     │
│  ┌───────────────┐  │◄────────────►│  ┌───────────────┐  │
│  │  rs-movies    │  │   Real-time  │  │    Movies     │  │
│  │  rs-tv        │  │    Sync      │  │   TV Shows    │  │
│  │  rs-4kmedia   │  │              │  │   4K Movies   │  │
│  └───────────────┘  │              │  │   4K TV Shows │  │
│                     │              │  └───────────────┘  │
│   Mode: SEND ONLY   │              │ Mode: RECEIVE ONLY  │
└─────────────────────┘              └─────────────────────┘
```

---

## Why Syncthing Over Webhooks

| Aspect | Webhook + rsync | Syncthing |
|--------|-----------------|-----------|
| Speed | Real-time | Real-time |
| Catches manual copies | No | Yes |
| Custom code to maintain | Yes | No |
| Network interruption handling | Custom retry logic | Built-in |
| Conflict resolution | None | Built-in |
| File integrity verification | Manual | Automatic (hashing) |
| Partial transfer resume | No | Yes |
| Delta sync | No (full file) | Yes (block-level) |

---

## Architecture

### Deployment Options

**Option A: Native Install on Both Servers**
- Install Syncthing directly on Synology and Unraid
- Pros: Direct access to filesystems, best performance
- Cons: Different install process for each OS

**Option B: Docker on Mother (Recommended)**
- Run Syncthing container on Mother VM
- Mount NFS shares from both Synology and Unraid
- Pros: Centralized management, consistent setup
- Cons: Extra network hop

**Option C: Docker on Each Server**
- Syncthing container on Synology + Syncthing container on Unraid
- Pros: Direct access, no middle server
- Cons: Two places to manage

### Recommended: Option B (Docker on Mother)

```yaml
# docker-compose.yml addition
syncthing:
  image: syncthing/syncthing:latest
  container_name: syncthing
  hostname: mother-syncthing
  environment:
    - PUID=${PUID}
    - PGID=${PGID}
    - TZ=${TZ}
  volumes:
    # Config
    - ${CONFIG_PATH}/syncthing:/var/syncthing
    # Synology sources (read-only for safety)
    - /mnt/synology/rs-movies:/data/source/movies:ro
    - /mnt/synology/rs-tv:/data/source/tv:ro
    - /mnt/synology/rs-4kmedia:/data/source/4kmedia:ro
    # Unraid destinations (read-write)
    - /mnt/unraid/media/Movies:/data/dest/movies
    - /mnt/unraid/media/TV Shows:/data/dest/tv
    - "/mnt/unraid/media/4K Movies:/data/dest/4k-movies"
    - "/mnt/unraid/media/4K TV Shows:/data/dest/4k-tv"
  ports:
    - "8384:8384"      # Web UI
    - "22000:22000"    # Sync protocol (TCP)
    - "22000:22000/udp" # Sync protocol (UDP)
    - "21027:21027/udp" # Discovery
  restart: unless-stopped
  networks:
    - mother_network
```

---

## Folder Configuration

### Folders to Sync

| Folder ID | Source Path | Dest Path | Type |
|-----------|-------------|-----------|------|
| `movies-hd` | `/data/source/movies` | `/data/dest/movies` | Send Only → Receive Only |
| `tv-hd` | `/data/source/tv` | `/data/dest/tv` | Send Only → Receive Only |
| `movies-4k` | `/data/source/4kmedia/4kmovies` | `/data/dest/4k-movies` | Send Only → Receive Only |
| `tv-4k` | `/data/source/4kmedia/4ktv` | `/data/dest/4k-tv` | Send Only → Receive Only |

### Folder Settings

```
Folder Type: Send Only (source) / Receive Only (destination)
File Versioning: None (one-way mirror, no need)
Ignore Permissions: Yes (different systems)
Watch for Changes: Yes (real-time sync)
Scan Interval: 3600 (hourly rescan as backup to watcher)
```

### Ignore Patterns (.stignore)

```
// Synology system files
@eaDir
#recycle
.DS_Store
Thumbs.db

// Temporary files
*.part
*.!qB
*.downloading

// System files
.Spotlight-*
.Trashes
.fseventsd
```

---

## Notifications & Alerting

Syncthing itself doesn't have built-in Telegram/Discord notifications, but we have several options:

### Option 1: Syncthing Monitor with Apprise (Recommended)

Create a monitoring script using Apprise (same as sync-webhook):

```python
#!/usr/bin/env python3
"""
Syncthing Monitor - Project Mother
Monitors Syncthing status and sends alerts via Apprise (Telegram, Discord, etc.)
"""

import os
import requests
import apprise
from datetime import datetime, timedelta

SYNCTHING_URL = os.environ.get("SYNCTHING_URL", "http://localhost:8384")
SYNCTHING_API_KEY = os.environ.get("SYNCTHING_API_KEY")
TELEGRAM_BOT_TOKEN = os.environ.get("TELEGRAM_BOT_TOKEN")
TELEGRAM_CHAT_ID = os.environ.get("TELEGRAM_CHAT_ID")

# Setup Apprise (same config as sync-webhook)
apobj = apprise.Apprise()
if TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID:
    apobj.add(f"tgram://{TELEGRAM_BOT_TOKEN}/{TELEGRAM_CHAT_ID}/")

def get_syncthing_status():
    """Get Syncthing status via REST API"""
    headers = {"X-API-Key": SYNCTHING_API_KEY}

    folders = requests.get(f"{SYNCTHING_URL}/rest/stats/folder", headers=headers, timeout=10).json()
    connections = requests.get(f"{SYNCTHING_URL}/rest/system/connections", headers=headers, timeout=10).json()
    errors = requests.get(f"{SYNCTHING_URL}/rest/system/error", headers=headers, timeout=10).json()

    return folders, connections, errors

def send_notification(title, body, notify_type=apprise.NotifyType.INFO):
    """Send notification via Apprise"""
    apobj.notify(title=title, body=body, notify_type=notify_type)

def check_and_alert():
    """Check status and send alerts if needed"""
    try:
        folders, connections, errors = get_syncthing_status()
    except Exception as e:
        send_notification(
            title="Syncthing Unreachable",
            body=f"Cannot connect to Syncthing API:\n{str(e)}",
            notify_type=apprise.NotifyType.FAILURE
        )
        return

    # Check for errors
    if errors.get("errors"):
        for error in errors["errors"]:
            send_notification(
                title="Syncthing Error",
                body=error['message'],
                notify_type=apprise.NotifyType.FAILURE
            )

    # Check folder status - alert if no sync in 2 hours
    for folder_id, stats in folders.items():
        try:
            last_scan = stats.get("lastScan", "")
            if last_scan:
                last_sync = datetime.fromisoformat(last_scan.replace("Z", "+00:00"))
                if datetime.now(last_sync.tzinfo) - last_sync > timedelta(hours=2):
                    send_notification(
                        title="Syncthing Stale",
                        body=f"Folder `{folder_id}` hasn't synced in over 2 hours",
                        notify_type=apprise.NotifyType.WARNING
                    )
        except Exception:
            pass

def send_daily_summary():
    """Send daily summary report"""
    try:
        folders, connections, errors = get_syncthing_status()
    except Exception as e:
        send_notification(
            title="Syncthing Daily Summary",
            body=f"Failed to get status: {str(e)}",
            notify_type=apprise.NotifyType.FAILURE
        )
        return

    lines = [f"📅 {datetime.now().strftime('%Y-%m-%d')}\n"]

    # Folder status
    for folder_id, stats in folders.items():
        last_scan = stats.get("lastScan", "Never")[:19].replace("T", " ")
        lines.append(f"📁 {folder_id}: {last_scan}")

    # Connection status
    conn_count = len([c for c in connections.get("connections", {}).values() if c.get("connected")])
    lines.append(f"\n🔗 Active connections: {conn_count}")

    # Errors
    error_count = len(errors.get("errors", []))
    lines.append(f"{'⚠️ Errors: ' + str(error_count) if error_count else '✅ No errors'}")

    send_notification(
        title="Syncthing Daily Summary",
        body="\n".join(lines),
        notify_type=apprise.NotifyType.INFO
    )

if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1 and sys.argv[1] == "--summary":
        send_daily_summary()
    else:
        check_and_alert()
```

**Cron setup on Mother:**
```bash
# Check for issues every 15 minutes
*/15 * * * * /usr/bin/python3 /opt/mother/scripts/syncthing_monitor.py

# Daily summary at 8 AM
0 8 * * * /usr/bin/python3 /opt/mother/scripts/syncthing_monitor.py --summary
```

### Option 2: Uptime Kuma Integration

Monitor Syncthing Web UI health endpoint:
- URL: `http://syncthing:8384/rest/system/ping`
- Expected: `{"ping": "pong"}`
- Alert on failure

### Option 3: Built-in with Syncthing Container

Run the monitor script inside the Syncthing container using APScheduler (same pattern as sync-webhook) - no cron needed.

---

## Error Handling & Recovery

### How Syncthing Handles Issues

| Issue | Syncthing Behavior |
|-------|-------------------|
| Network interruption | Automatically reconnects, resumes transfer |
| Partial file transfer | Resumes from where it left off |
| File conflict | Creates `.sync-conflict` copy (configurable) |
| Disk full | Pauses sync, logs error, resumes when space available |
| Permission denied | Logs error, skips file, continues with others |
| Corrupt file detected | Re-syncs the corrupted blocks |
| Service restart | Scans folders, resumes pending transfers |

### File Versioning (Optional)

For safety, we can enable "Trash Can" versioning:
```
Versioning Type: Trash Can
Clean Out After: 30 days
```

This keeps deleted files for 30 days before permanent removal.

### Monitoring Endpoints

Syncthing REST API endpoints for monitoring:

| Endpoint | Description |
|----------|-------------|
| `/rest/system/ping` | Basic health check |
| `/rest/system/status` | System status (uptime, memory, etc.) |
| `/rest/system/error` | Recent errors |
| `/rest/stats/folder` | Folder statistics |
| `/rest/db/status?folder=X` | Detailed folder sync status |
| `/rest/events` | Event stream (for real-time monitoring) |

---

## Migration Plan

### Prerequisites
- [ ] Initial quality comparison sync completed
- [ ] All libraries verified as correct on Unraid
- [ ] Syncthing container tested

### Migration Steps

1. **Stop webhook-based sync**
   ```bash
   docker-compose stop sync-webhook
   ```

2. **Deploy Syncthing**
   ```bash
   docker-compose up -d syncthing
   ```

3. **Configure folders in Syncthing Web UI**
   - Access: http://mother:8384
   - Add folders with Send Only / Receive Only settings
   - Add ignore patterns

4. **Initial verification**
   - Let Syncthing scan all folders
   - Verify no unexpected changes detected
   - Check that existing files are marked as "Up to Date"

5. **Test with new content**
   - Download something via Radarr/Sonarr
   - Verify it syncs to Unraid within seconds
   - Check Telegram notification (if configured)

6. **Remove old webhook service** (optional)
   ```bash
   docker-compose rm sync-webhook
   ```

7. **Update documentation**
   - Mark webhook approach as deprecated
   - Document Syncthing as primary sync method

---

## Comparison: What We Lose vs Gain

### What We Lose
- Per-file notifications with movie/show names and quality
- Integration with Radarr/Sonarr metadata
- Job history database with detailed logs

### What We Gain
- Simpler architecture (no custom code)
- Catches ALL file changes (not just Radarr/Sonarr imports)
- Battle-tested reliability
- Block-level delta sync (faster for modified files)
- Built-in conflict resolution
- Partial transfer resume
- Less maintenance

### Notification Workaround

For per-file notifications, we could run a filesystem watcher on Unraid:
```bash
inotifywait -m -r /mnt/user/media --format '%w%f' -e create | while read file; do
    # Send notification for new files
    curl -X POST "https://api.telegram.org/bot${TOKEN}/sendMessage" \
        -d "chat_id=${CHAT_ID}" \
        -d "text=📥 New file: $(basename "$file")"
done
```

---

## Environment Variables

Add to `.env`:
```bash
# Syncthing
SYNCTHING_API_KEY=your-api-key-here  # Found in Syncthing Web UI > Actions > Settings
```

---

## Timeline

| Phase | Task | When |
|-------|------|------|
| 1 | Complete initial quality sync | Current |
| 2 | Verify all libraries match | After sync |
| 3 | Deploy Syncthing (test mode) | +1 day |
| 4 | Configure folders and monitoring | +1 day |
| 5 | Run parallel with webhooks (verify) | +1 week |
| 6 | Disable webhooks, Syncthing primary | +2 weeks |
| 7 | Remove webhook service | +1 month |

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-02 | Plan created |
