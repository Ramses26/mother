#!/bin/bash
# NFS Health Check - runs every 5 minutes via cron
# Alerts via Apprise if mounts are hung

APPRISE_URL="http://192.168.1.14:8000/notify/apprise"
LOG_FILE="/opt/mother/logs/nfs_health.log"
TIMEOUT=10

# Mounts to check
MOUNTS=(
    "/mnt/synology/rs-movies"
    "/mnt/synology/rs-tv"
    "/mnt/synology/rs-4kmedia/4kmovies"
    "/mnt/unraid/media"
)

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

for mount in "${MOUNTS[@]}"; do
    if ! timeout $TIMEOUT ls "$mount" > /dev/null 2>&1; then
        log "ALERT: Mount $mount is not responding"
        
        curl -sf -X POST "${APPRISE_URL}?tag=servers" \
            -d "title=⚠️ NFS Mount Issue" \
            -d "body=Mount $mount is not responding on mother.

Possible causes:
- VPN tunnel down
- NFS server rebooted
- Network issue

Check with: mount | grep nfs" \
            -d "type=warning" \
            --connect-timeout 5 \
            --max-time 10
    fi
done
