# Ongoing Sync Strategy - Project Mother

## Overview
After the initial sync is complete, we need ongoing real-time synchronization from Chris's Synology devices to your Unraid server to maintain identical copies.

## Sync Direction

```
Chris's Synology (Primary) → Your Unraid (Mirror)
    ↓
Mother Server downloads via qBittorrent
    ↓
Radarr/Sonarr copy to final location on Synology
    ↓
Real-time sync to your Unraid
```

## Sync Tool Selection

### Option 1: Rclone (RECOMMENDED)
**Pros:**
- Powerful, flexible
- Handles large files well
- Can run as daemon (rclone mount) or scheduled
- Excellent bandwidth control
- Good logging and monitoring

**Cons:**
- More complex initial setup
- Requires configuration per sync path

### Option 2: Syncthing
**Pros:**
- Easy setup with web UI
- Truly bidirectional (if needed)
- Automatic conflict resolution
- No central server needed

**Cons:**
- Can be resource intensive
- May create conflicts if both sides modified
- Less suitable for large one-way sync

### Option 3: Rsync + Inotify
**Pros:**
- Very efficient (only syncs changes)
- Lightweight
- Native Linux tools

**Cons:**
- Requires custom scripting
- Inotify watches can be limited
- More complex for real-time sync

**RECOMMENDATION**: Use **Rclone** with scheduled runs (every 15-30 minutes)

## Rclone Setup

### Installation on Mother Server

```bash
# Install rclone
sudo apt install rclone -y

# Or install latest version
curl https://rclone.org/install.sh | sudo bash
```

### Configure Rclone

```bash
rclone config
```

#### Create Remote for Chris's Synology

```
n) New remote
name> chris-synology
Type of storage> sftp
host> 10.0.1.203 (or use NFS mount)
user> admin
port> 22
key_file> /home/user/.ssh/id_ed25519
y) Yes this is OK
```

#### Create Remote for Your Unraid

```
n) New remote
name> your-unraid
Type of storage> sftp
host> 192.168.1.10
user> root
port> 22
key_file> /home/user/.ssh/id_ed25519
y) Yes this is OK
```

**Alternative**: Use local mount points instead of SFTP
```
n) New remote
name> chris-local
Type of storage> local
nounc> true
```

### Rclone Configuration File

Edit `~/.config/rclone/rclone.conf`:

```ini
[chris-movies-hd]
type = local
nounc = true

[chris-movies-4k]
type = local
nounc = true

[chris-tv-hd]
type = local
nounc = true

[chris-tv-4k]
type = local
nounc = true

[unraid]
type = sftp
host = 192.168.1.10
user = root
port = 22
key_file = /home/user/.ssh/id_ed25519
shell_type = unix
md5sum_command = md5sum
sha1sum_command = sha1sum
```

## Sync Scripts

### Master Sync Script

Create `/opt/mother/scripts/sync_to_unraid.sh`:

```bash
#!/bin/bash
#
# Sync all media from Chris's Synology to Your Unraid
# Run via cron every 15-30 minutes
#

set -e

LOG_FILE="/opt/mother/logs/sync-$(date +%Y%m%d).log"
LOCK_FILE="/tmp/mother-sync.lock"

# Prevent concurrent runs
if [ -f "$LOCK_FILE" ]; then
    echo "$(date): Sync already running" >> "$LOG_FILE"
    exit 1
fi

touch "$LOCK_FILE"
trap "rm -f $LOCK_FILE" EXIT

echo "$(date): Starting sync to Unraid" >> "$LOG_FILE"

# Function to sync a directory
sync_directory() {
    local SOURCE=$1
    local DEST=$2
    local NAME=$3
    
    echo "$(date): Syncing $NAME..." >> "$LOG_FILE"
    
    rclone sync \
        "$SOURCE" \
        "$DEST" \
        --config /home/user/.config/rclone/rclone.conf \
        --log-file "$LOG_FILE" \
        --log-level INFO \
        --stats 1m \
        --stats-one-line \
        --transfers 4 \
        --checkers 8 \
        --bwlimit 700M \
        --exclude ".DS_Store" \
        --exclude "Thumbs.db" \
        --exclude "@eaDir/" \
        --exclude ".@__thumb/" \
        --exclude "#recycle/" \
        --exclude ".Recycle.Bin/" \
        --delete-after \
        --fast-list
    
    echo "$(date): Completed $NAME" >> "$LOG_FILE"
}

# Sync each media directory
sync_directory "/mnt/synology/movies" "unraid:/mnt/user/media/Movies" "HD Movies"
sync_directory "/mnt/synology/4kmovies" "unraid:/mnt/user/media/4K Movies" "4K Movies"
sync_directory "/mnt/synology/tv" "unraid:/mnt/user/media/TV Shows" "HD TV Shows"
sync_directory "/mnt/synology/4ktv" "unraid:/mnt/user/media/4K TV Shows" "4K TV Shows"

echo "$(date): Sync completed successfully" >> "$LOG_FILE"

# Send notification (optional)
# curl -X POST "https://discord.webhook.url" -d '{"content":"Sync completed"}'
```

Make executable:
```bash
chmod +x /opt/mother/scripts/sync_to_unraid.sh
```

### Test Sync (Dry Run)

```bash
# Test without making changes
rclone sync \
    /mnt/synology/movies \
    unraid:/mnt/user/media/Movies \
    --dry-run \
    -v
```

## Scheduling Sync

### Cron Job Setup

```bash
# Edit crontab
crontab -e

# Add sync every 30 minutes
*/30 * * * * /opt/mother/scripts/sync_to_unraid.sh

# Or every 15 minutes for more real-time
*/15 * * * * /opt/mother/scripts/sync_to_unraid.sh

# Or hourly at 5 minutes past
5 * * * * /opt/mother/scripts/sync_to_unraid.sh
```

### Systemd Timer (Alternative to Cron)

Create `/etc/systemd/system/mother-sync.service`:

```ini
[Unit]
Description=Mother Media Sync to Unraid
After=network.target

[Service]
Type=oneshot
User=your_user
ExecStart=/opt/mother/scripts/sync_to_unraid.sh
```

Create `/etc/systemd/system/mother-sync.timer`:

```ini
[Unit]
Description=Mother Media Sync Timer
Requires=mother-sync.service

[Timer]
OnBootSec=5min
OnUnitActiveSec=30min
Unit=mother-sync.service

[Install]
WantedBy=timers.target
```

Enable and start:
```bash
sudo systemctl daemon-reload
sudo systemctl enable mother-sync.timer
sudo systemctl start mother-sync.timer

# Check status
sudo systemctl status mother-sync.timer
sudo systemctl list-timers
```

## Monitoring Sync

### Log Rotation

Create `/etc/logrotate.d/mother-sync`:

```
/opt/mother/logs/sync-*.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
}
```

### Monitoring Script

Create `/opt/mother/scripts/monitor_sync.sh`:

```bash
#!/bin/bash
#
# Monitor sync status and send alerts if issues
#

LAST_LOG=$(ls -t /opt/mother/logs/sync-*.log | head -1)
LAST_SUCCESS=$(grep "Sync completed successfully" "$LAST_LOG" | tail -1)
CURRENT_TIME=$(date +%s)

if [ -z "$LAST_SUCCESS" ]; then
    echo "WARNING: No successful sync found in latest log"
    # Send alert
    exit 1
fi

LAST_SUCCESS_TIME=$(date -d "$(echo $LAST_SUCCESS | awk '{print $1, $2}')" +%s)
TIME_DIFF=$((CURRENT_TIME - LAST_SUCCESS_TIME))

# Alert if last sync was more than 2 hours ago
if [ $TIME_DIFF -gt 7200 ]; then
    echo "WARNING: Last successful sync was $((TIME_DIFF / 3600)) hours ago"
    # Send alert
    exit 1
fi

echo "Sync OK: Last success was $((TIME_DIFF / 60)) minutes ago"
```

### Dashboard (Optional)

Consider adding sync monitoring to:
- **Uptime Kuma**: Monitor sync script execution
- **Grafana**: Visualize sync metrics
- **Homepage**: Display sync status

## Handling Sync Conflicts

### File Conflicts
Since sync is one-way (Synology → Unraid), conflicts shouldn't occur unless:
- Files manually added to Unraid
- Files modified on Unraid

**Resolution**: Unraid is mirror only, changes on Synology always win.

### Delete Handling

Rclone `--delete-after` flag means:
- Files deleted on Synology will be deleted on Unraid
- This maintains 1:1 mirror

**To prevent accidental deletions:**
```bash
# Add to rclone command:
--max-delete 100  # Abort if more than 100 deletions
--backup-dir /backups/deleted  # Backup deleted files
```

## Bandwidth Management

### Bandwidth Limiting

```bash
# Limit to 500 Mbps during daytime
--bwlimit "09:00,500M 17:00,700M"

# Or use schedule file
--bwlimit-file /opt/mother/configs/bwlimit.txt
```

**bwlimit.txt**:
```
# Format: HH:MM,BANDWIDTH
00:00,700M  # Full speed midnight to 8am
08:00,500M  # Reduced speed during day
18:00,700M  # Full speed evening
```

### Priority Management

```bash
# Lower priority during business hours
--tpslimit 10  # Transactions per second limit
--tpslimit-burst 50
```

## Verification & Integrity

### Periodic Full Verification

Create `/opt/mother/scripts/verify_sync.sh`:

```bash
#!/bin/bash
#
# Monthly full sync verification
# Compare checksums between source and destination
#

rclone check \
    /mnt/synology/movies \
    unraid:/mnt/user/media/Movies \
    --one-way \
    --log-file /opt/mother/logs/verify-$(date +%Y%m%d).log
```

Schedule monthly:
```bash
# crontab -e
0 2 1 * * /opt/mother/scripts/verify_sync.sh
```

## Disaster Recovery

### Backup Sync Configuration

```bash
# Backup rclone config
cp ~/.config/rclone/rclone.conf ~/rclone.conf.backup

# Include in repository
cp ~/.config/rclone/rclone.conf /opt/mother/configs/rclone.conf.example
# Remove sensitive data before committing
```

### Recovery Procedures

**If Unraid data lost:**
1. Stop sync cron job
2. Verify Synology data intact
3. Clear Unraid media directories
4. Run full initial sync
5. Verify integrity
6. Resume scheduled sync

**If Synology data lost:**
1. Stop all *arr services
2. Stop sync
3. Reverse sync from Unraid to Synology
4. Verify integrity
5. Resume normal operations

## Performance Optimization

### Rclone Tuning

```bash
# Optimal settings for VPN over gigabit
--transfers 4        # Parallel file transfers
--checkers 8         # Parallel hash checkers
--buffer-size 256M   # Buffer for each transfer
--use-mmap          # Use memory-mapped IO
--fast-list         # Use recursive list if supported
```

### Network Optimization

```bash
# TCP tuning on Mother server
sudo sysctl -w net.ipv4.tcp_window_scaling=1
sudo sysctl -w net.core.rmem_max=134217728
sudo sysctl -w net.core.wmem_max=134217728
```

## Sync Statistics

### Generate Stats Report

```bash
# Add to sync script
rclone sync ... \
    --stats-file-name-length 0 \
    --stats-log-level NOTICE
```

### Weekly Summary

Create `/opt/mother/scripts/sync_report.sh`:

```bash
#!/bin/bash
#
# Generate weekly sync report
#

WEEK_LOGS=$(find /opt/mother/logs/ -name "sync-*.log" -mtime -7)

echo "=== Weekly Sync Report ==="
echo "Total files transferred: $(cat $WEEK_LOGS | grep -c 'Transferred:')"
echo "Total data transferred: $(cat $WEEK_LOGS | grep 'Transferred:' | awk '{sum+=$2} END {print sum}')"
echo "Average transfer speed: ..."
# Add more analytics
```

## Alternative: Real-Time Sync with Inotify

If you need true real-time sync (not recommended for media):

```bash
# Install inotify tools
sudo apt install inotify-tools -y

# Create watch script
#!/bin/bash
inotifywait -m -r -e modify,create,delete,move /mnt/synology/movies |
while read path action file; do
    rclone copy "$path$file" "unraid:..."
done
```

**Not recommended** because:
- Resource intensive
- May trigger on incomplete files
- Better to let media files fully settle before sync

## Next Steps
1. ⏳ Install rclone on Mother
2. ⏳ Configure rclone remotes
3. ⏳ Create sync scripts
4. ⏳ Test sync (dry run)
5. ⏳ Test actual sync with small dataset
6. ⏳ Configure bandwidth limits
7. ⏳ Setup cron job
8. ⏳ Setup monitoring
9. ⏳ Test sync after Radarr/Sonarr download
10. ⏳ Create verification script
11. ⏳ Document recovery procedures
12. ⏳ Setup alerting
