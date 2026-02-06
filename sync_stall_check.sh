#!/bin/bash
# Sync Stall Detector - alerts if less than 100MB transferred in an hour

APPRISE_URL="http://192.168.1.14:8000/notify/apprise"
SNAPSHOT_FILE="/opt/mother/traffic_stats/snapshots.csv"
LOG_FILE="/opt/mother/logs/sync_stall.log"
MIN_BYTES=104857600  # 100MB

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Need at least 2 snapshots
LINE_COUNT=$(wc -l < "$SNAPSHOT_FILE" 2>/dev/null || echo "0")
if [ "$LINE_COUNT" -lt 3 ]; then
    exit 0
fi

# Get last two snapshots
LAST=$(tail -1 "$SNAPSHOT_FILE")
PREV=$(tail -2 "$SNAPSHOT_FILE" | head -1)

LAST_SENT=$(echo "$LAST" | cut -d',' -f4)
LAST_RECV=$(echo "$LAST" | cut -d',' -f5)
PREV_SENT=$(echo "$PREV" | cut -d',' -f4)
PREV_RECV=$(echo "$PREV" | cut -d',' -f5)

# Calculate delta
DELTA_SENT=$((LAST_SENT - PREV_SENT))
DELTA_RECV=$((LAST_RECV - PREV_RECV))
DELTA_TOTAL=$((DELTA_SENT + DELTA_RECV))

# Handle counter reset (negative = reset occurred)
[ $DELTA_TOTAL -lt 0 ] && exit 0

# Check if below threshold
if [ $DELTA_TOTAL -lt $MIN_BYTES ]; then
    DELTA_MB=$((DELTA_TOTAL / 1048576))
    log "STALL DETECTED: Only ${DELTA_MB}MB transferred in last hour"
    
    curl -sf -X POST "${APPRISE_URL}?tag=servers" \
        -d "title=⚠️ Sync Stalled" \
        -d "body=Only ${DELTA_MB}MB transferred in the last hour.

Syncs may be stuck or completed.

Check with:
ps aux | grep sync
screen -ls" \
        -d "type=warning" \
        --connect-timeout 5 \
        --max-time 10
fi
