# Sync Strategy - Ongoing Replication

**Last Updated:** 2024-12-23

---

## Strategy Overview

**Primary Goal:** Real-time, one-way sync from Chris's Synology → Ali's Unraid

**Flow:**
```
Mother downloads → Chris's Synology → [SYNC] → Ali's Unraid
```

---

## Tool Selection: Syncthing vs rclone

### Syncthing (RECOMMENDED)

**Pros:**
- True real-time syncing
- Web GUI for monitoring
- Automatic conflict resolution
- Bidirectional capable (future-proof)
- Handles large files well
- Resumable transfers

**Cons:**
- Higher resource usage
- Requires installation on both sides

### rclone

**Pros:**
- Lightweight
- Scriptable
- Many cloud backends supported

**Cons:**
- Not truly real-time (requires scheduling)
- No GUI
- Manual conflict handling

**Decision:** Use Syncthing for real-time capability

---

## Syncthing Setup

### Install on Mother (Chris's side)

```bash
# Add Syncthing repository
sudo curl -o /usr/share/keyrings/syncthing-archive-keyring.gpg \
  https://syncthing.net/release-key.gpg
echo "deb [signed-by=/usr/share/keyrings/syncthing-archive-keyring.gpg] \
  https://apt.syncthing.net/ syncthing stable" | \
  sudo tee /etc/apt/sources.list.d/syncthing.list

# Install
sudo apt update
sudo apt install syncthing

# Enable as service
sudo systemctl enable syncthing@$USER
sudo systemctl start syncthing@$USER

# Access Web GUI
# http://10.0.x.x:8384
```

### Install on Ali's Unraid

```bash
# SSH to Unraid
ssh root@192.168.1.10

# Create directory for Syncthing
mkdir -p /mnt/user/appdata/syncthing

# Run as Docker container
docker run -d \
  --name=syncthing \
  --hostname=unraid-syncthing \
  -e PUID=99 \
  -e PGID=100 \
  -e TZ=America/New_York \
  -p 8384:8384 \
  -p 22000:22000/tcp \
  -p 22000:22000/udp \
  -p 21027:21027/udp \
  -v /mnt/user/appdata/syncthing:/config \
  -v /mnt/user/media:/media \
  --restart unless-stopped \
  lscr.io/linuxserver/syncthing:latest

# Access Web GUI
# http://192.168.1.10:8384
```

### Configure Sync Folders

**On Mother (Source):**

1. Access Web GUI: http://10.0.x.x:8384
2. Actions → Settings → GUI → Set username/password
3. Add Folder:
   - Folder Label: "Movies"
   - Folder Path: /mnt/synology/movies
   - Folder Type: "Send Only"
4. Repeat for:
   - TV Shows: /mnt/synology/tv
   - 4K Movies: /mnt/synology/4kmovies
   - 4K TV Shows: /mnt/synology/4ktv

**On Ali's Unraid (Destination):**

1. Access Web GUI: http://192.168.1.10:8384
2. Add Remote Device (Mother's device ID)
3. Accept folder shares from Mother
4. Set folder paths:
   - Movies → /media/Movies
   - TV Shows → /media/TV Shows
   - 4K Movies → /media/4K Movies
   - 4K TV Shows → /media/4K TV Shows

### Advanced Settings

**File Versioning:**
- Type: "Staggered File Versioning"
- Keep versions: 5
- Age: 30 days
- Purpose: Protect against accidental deletions

**Ignore Patterns:**
```
// .stignore file
*.partial~
*.!sync
.DS_Store
Thumbs.db
*.tmp
```

**Bandwidth Limits (if needed):**
- Set during business hours to avoid impacting VPN
- Unlimited during off-hours

---

## Monitoring

### Syncthing Web Dashboard

Monitor at: http://10.0.x.x:8384

**Key Metrics:**
- Sync status (Up to Date, Syncing, etc.)
- Transfer rate
- Total data synced
- Errors/conflicts

### Alerting

Configure notifications in Syncthing:
- Actions → Settings → GUI → API Key
- Use API to check status via script

**Monitor script:**
```bash
#!/bin/bash
# /opt/mother/scripts/sync/check-sync-status.sh

SYNCTHING_API="http://localhost:8384/rest"
API_KEY="your-api-key-here"

STATUS=$(curl -s -H "X-API-Key: $API_KEY" \
  "$SYNCTHING_API/system/status" | jq -r '.myID')

if [ -z "$STATUS" ]; then
  echo "ERROR: Syncthing not responding"
  # Send alert
fi

# Check folder status
FOLDERS=$(curl -s -H "X-API-Key: $API_KEY" \
  "$SYNCTHING_API/db/status?folder=movies" | jq -r '.state')

if [ "$FOLDERS" != "idle" ]; then
  echo "WARNING: Folder not in sync"
fi
```

---

## Backup Strategy

**Config Backups:**
```bash
# Backup Syncthing config weekly
0 2 * * 0 tar -czf /opt/mother/scripts/backup/syncthing-config-$(date +\%Y\%m\%d).tar.gz \
  ~/.config/syncthing/
```

**Data Integrity:**
- Syncthing maintains checksums automatically
- Regular verification runs in background
- Monitor for "Out of Sync" errors

---

## Disaster Recovery

**If sync breaks:**

1. Check Syncthing status on both sides
2. Verify VPN tunnel is up
3. Check firewall rules (ports 22000, 21027)
4. Review Syncthing logs
5. Restart Syncthing if needed

**If data corruption detected:**

1. Pause sync
2. Identify corrupt files
3. Re-sync from source
4. Enable file versioning to recover if needed

---

## Performance Tuning

**Expected Performance:**
- Initial sync: 50-100 MB/s (limited by VPN)
- Ongoing sync: Near real-time (< 1 minute delay)

**Optimization:**
- Use connection relay only if direct unavailable
- Enable UPnP if both routers support
- Adjust block size for large files

---

## Alternative: rclone Approach

If Syncthing proves problematic:

```bash
#!/bin/bash
# /opt/mother/scripts/sync/rclone-sync.sh

# Run every 15 minutes via cron
rclone sync \
  /mnt/synology/movies \
  unraid-remote:media/Movies \
  --transfers 4 \
  --checkers 8 \
  --bwlimit 100M \
  --log-file /opt/mother/logs/rclone-movies.log \
  --verbose

# Repeat for other folders
```

**Crontab:**
```
*/15 * * * * /opt/mother/scripts/sync/rclone-sync.sh
```

---

## Next Steps

1. Install Syncthing on both systems
2. Configure folder pairs
3. Monitor initial sync progress
4. Set up monitoring/alerting
5. Document actual performance metrics
6. Fine-tune based on real-world usage
