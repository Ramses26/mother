#!/bin/bash
#==============================================================================
# Start Sync Screen Sessions - Project Mother
#
# Starts movie and TV sync scripts in detached screen sessions.
# Called by systemd service on boot or manual restart.
#==============================================================================

set -e

REPORTS_DIR="/opt/mother/reports"
LOG_DIR="/opt/mother/logs"
PARALLEL="${PARALLEL:-8}"

# Find the most recent sync scripts
MOVIE_SCRIPT=$(ls -t "$REPORTS_DIR"/sync_actions_*.sh 2>/dev/null | head -1)
TV_SCRIPT=$(ls -t "$REPORTS_DIR"/tv_sync_actions_*.sh 2>/dev/null | head -1)

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_DIR/sync-autostart.log"
}

# Check if scripts exist
if [ -z "$MOVIE_SCRIPT" ]; then
    log "ERROR: No movie sync script found in $REPORTS_DIR"
    exit 1
fi

if [ -z "$TV_SCRIPT" ]; then
    log "ERROR: No TV sync script found in $REPORTS_DIR"
    exit 1
fi

log "Starting sync screens with PARALLEL=$PARALLEL"
log "Movie script: $(basename "$MOVIE_SCRIPT")"
log "TV script: $(basename "$TV_SCRIPT")"

# Check if screens already exist and are running
check_screen() {
    local name="$1"
    if screen -list | grep -q "\.$name"; then
        return 0  # exists
    fi
    return 1  # doesn't exist
}

# Start movie sync if not already running
if check_screen "movie"; then
    log "Movie sync screen already running, skipping"
else
    log "Starting movie sync screen..."
    cd "$REPORTS_DIR"
    screen -dmS movie bash -c "PARALLEL=$PARALLEL $MOVIE_SCRIPT 2>&1 | tee -a $LOG_DIR/movie_sync.log"
    sleep 2
    if check_screen "movie"; then
        log "Movie sync screen started successfully"
    else
        log "ERROR: Failed to start movie sync screen"
    fi
fi

# TV sync loop disabled — batch sync complete Jun 17 2026; nightly gap scanner handles ongoing TV sync
if [ -f /opt/mother/DISABLE_TV_SYNC ]; then
    log "TV sync: DISABLE_TV_SYNC sentinel present — not starting tvsync screen"
elif check_screen "tvsync"; then
    log "TV sync screen already running, skipping"
else
    log "Starting TV sync screen..."
    cd "$REPORTS_DIR"
    screen -dmS tvsync bash -c "PARALLEL=$PARALLEL $TV_SCRIPT 2>&1 | tee -a $LOG_DIR/tv_sync.log"
    sleep 2
    if check_screen "tvsync"; then
        log "TV sync screen started successfully"
    else
        log "ERROR: Failed to start TV sync screen"
    fi
fi

# Final status
log "Screen status:"
screen -ls | tee -a "$LOG_DIR/sync-autostart.log"

log "Sync screens startup complete"
