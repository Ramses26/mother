# Cross-Seed Hardlink Detection Fix

## Problem Summary

Your files **ARE** hardlinked correctly on the Synology (verified by your `find` command), but qbitmanage is incorrectly tagging them as `noHL`. 

## Root Cause

**qbitmanage cannot detect hardlinks over NFS mounts.**

Current setup:
- ✅ **qBittorrent + cross-seed** run on Synology (10.0.1.203) - hardlinks work perfectly
- ❌ **qbitmanage** runs on terminus (10.0.0.162) - checks hardlinks over NFS mount
- ⚠️ NFS doesn't preserve inode numbers, so qbitmanage can't see the hardlink relationship

## Solution: Move qbitmanage to Synology

Since qbitmanage needs to check hardlinks on the same filesystem where they exist, it must run on the Synology alongside qBittorrent and cross-seed.

### Step 1: Add qbitmanage to Synology docker-compose

Edit `/volume1/docker/mother/synology-qbittorrent/docker-compose.yml` on your Synology and add:

```yaml
  # qbit_manage - qBittorrent automation/cleanup  
  # Must run on same system as qBittorrent for hardlink detection
  qbitmanage:
    image: ghcr.io/stuffanthings/qbit_manage:latest
    container_name: qbitmanage
    environment:
      - PUID=1028
      - PGID=100
      - TZ=America/New_York
      - QBT_CONFIG_DIR=/config
      - QBT_LOGFILE=/config/logs/qbit_manage.log
      - QBT_SCHEDULE=30         # run every 30 minutes
      - QBT_STARTUP_DELAY=60    # wait for qBittorrent to come up
      - QBT_RUN=false           # use internal scheduler
      - QBT_WEB_SERVER=false
      - QBT_SHARE_LIMITS=true
      - QBT_TAG_NOHARDLINKS=true
      - QBT_REM_UNREGISTERED=true
      - QBT_REM_ORPHANED=false
      - QBT_TAG_TRACKER_ERROR=true
      - QBITMANAGE_QBT_HOST=http://localhost:8080
      - QBITMANAGE_QBT_USER=muthur
      - QBITMANAGE_QBT_PASS=Md4DQbghf@5ptf&K
    volumes:
      - /volume1/docker/qbitmanage:/config
      - /volume1/Downloads:/downloads
    restart: unless-stopped
    depends_on:
      - qbittorrent
```

### Step 2: Copy qbitmanage config to Synology

```bash
# From your terminus server, copy the config to Synology
scp -r /opt/mother/configs/qbitmanage/* admin@10.0.1.203:/volume1/docker/qbitmanage/

# Or manually copy:
# Source: \\wsl.localhost\Ubuntu\home\alig\projects\mother\configs\qbitmanage\config.yml
# Destination: Synology /volume1/docker/qbitmanage/config.yml
```

### Step 3: Update qbitmanage config paths

The config should already be correct with these paths (which match the Synology):
```yaml
directory:
  root_dir: /downloads
  recycle_bin: /downloads/.RecycleBin
  torrents_dir: /bt_backup
  orphaned_dir: /downloads/orphaned_data
```

### Step 4: Deploy on Synology

```bash
# SSH into your Synology
ssh admin@10.0.1.203

# Navigate to the compose directory
cd /volume1/docker/mother/synology-qbittorrent

# Stop and recreate containers
docker-compose down
docker-compose up -d

# Verify it's running
docker-compose ps
docker logs qbitmanage
```

### Step 5: Disable qbitmanage on terminus

Edit your terminus `docker-compose.yml` and comment out the qbitmanage service, then:

```bash
cd /home/alig/projects/mother
docker-compose down qbitmanage
docker-compose up -d
```

### Step 6: Verify the fix

After qbitmanage runs on the Synology:

1. Check qBittorrent UI - the `noHL` tags should disappear from cross-seeded torrents
2. Check logs: `docker logs qbitmanage`
3. Verify hardlinks are now detected properly

## Why This Works

When qbitmanage runs **on the same filesystem** as the hardlinked files:
- It can properly read inode numbers
- It correctly identifies hardlink relationships
- The `noHL` tag is only applied to torrents that truly aren't hardlinked

## Alternative: Disable noHL Tagging

If you don't want to move qbitmanage, you can disable hardlink checking entirely in the terminus config:

```yaml
# In configs/qbitmanage/config.yml
commands:
  tag_nohardlinks: false  # Change from true to false
```

However, this means you lose the ability to track which torrents aren't hardlinked, which is useful for ratio management.

## Testing

To verify hardlinks work correctly after the change:

```bash
# SSH into Synology and run qbitmanage manually
docker exec -it qbitmanage python3 /app/qbit_manage.py --run --config /config/config.yml --log-level DEBUG

# Or just watch the automated runs
docker logs -f qbitmanage
```

The logs should now show correct hardlink detection for cross-seeded torrents.
