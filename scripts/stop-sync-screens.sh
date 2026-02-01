#!/bin/bash
#==============================================================================
# Stop Sync Screen Sessions - Project Mother
#==============================================================================

LOG_DIR="/opt/mother/logs"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_DIR/sync-autostart.log"
}

log "Stopping sync screens..."

# Send quit to screens (graceful)
screen -S movie -X quit 2>/dev/null && log "Stopped movie screen" || log "Movie screen not running"
screen -S tvsync -X quit 2>/dev/null && log "Stopped tvsync screen" || log "TV sync screen not running"

log "Sync screens stopped"
