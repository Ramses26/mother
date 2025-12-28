#!/bin/bash

################################################################################
# PROJECT MOTHER - TARGETED SYNC SCRIPT (FIXED)
################################################################################

set -euo pipefail

# Configuration
LOG_DIR="/opt/mother/logs"
LOG_FILE="$LOG_DIR/project_mother_targeted_$(date +%Y%m%d_%H%M%S).log"
STATE_FILE="/opt/mother/.project_mother_state"
DRY_RUN=false

# Script directory (where the filelists are)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$LOG_DIR"

# Logging functions
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $*" | tee -a "$LOG_FILE" >&2
}

log_success() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ✓ $*" | tee -a "$LOG_FILE"
}

save_state() {
    echo "$1" > "$STATE_FILE"
}

load_state() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        echo "START"
    fi
}

error_handler() {
    log_error "Script failed at line $1"
    exit 1
}

trap 'error_handler $LINENO' ERR

################################################################################
# START
################################################################################

log "========================================================================"
log "PROJECT MOTHER - TARGETED SYNC"
log "========================================================================"
log "Log: $LOG_FILE"
log ""

CURRENT_STATE=$(load_state)

################################################################################
# PRE-FLIGHT
################################################################################

if [ "$CURRENT_STATE" == "START" ]; then
    log "Pre-flight checks..."
    
    # Check file lists
    if [ ! -f "$SCRIPT_DIR/ali_to_chris.filelist" ]; then
        log_error "Missing: ali_to_chris.filelist"
        exit 1
    fi
    
    if [ ! -f "$SCRIPT_DIR/chris_to_ali.filelist" ]; then
        log_error "Missing: chris_to_ali.filelist"
        exit 1
    fi
    
    log_success "File lists found"
    
    # Check mounts
    if ! mount | grep -q "/mnt/unraid/media"; then
        log_error "Unraid not mounted!"
        exit 1
    fi
    
    if ! mount | grep -q "/mnt/synology/rs-movies"; then
        log_error "Synology not mounted!"
        exit 1
    fi
    
    log_success "Mounts OK"
    save_state "PREFLIGHT_DONE"
    log ""
fi

################################################################################
# PHASE 1: ALI → CHRIS
################################################################################

if [[ "$CURRENT_STATE" =~ ^(START|PREFLIGHT_DONE)$ ]]; then
    log "========================================================================"
    log "PHASE 1: Ali → Chris (2,578 files)"
    log "========================================================================"
    log ""
    
    rsync -avh --stats --no-perms --no-owner --no-group \
          --files-from="$SCRIPT_DIR/ali_to_chris.filelist" \
          --log-file="$LOG_FILE.rsync_ali_to_chris" \
          /mnt/unraid/media/Movies/ \
          /mnt/synology/rs-movies/
    
    log_success "Phase 1 complete"
    save_state "ALI_TO_CHRIS_DONE"
    log ""
fi

################################################################################
# PHASE 2: CHRIS → ALI
################################################################################

if [[ "$CURRENT_STATE" =~ ^(START|PREFLIGHT_DONE|ALI_TO_CHRIS_DONE)$ ]]; then
    log "========================================================================"
    log "PHASE 2: Chris → Ali (2,769 files)"
    log "========================================================================"
    log ""
    
    rsync -avh --stats --no-perms --no-owner --no-group \
          --files-from="$SCRIPT_DIR/chris_to_ali.filelist" \
          --log-file="$LOG_FILE.rsync_chris_to_ali" \
          /mnt/synology/rs-movies/ \
          /mnt/unraid/media/Movies/
    
    log_success "Phase 2 complete"
    save_state "MOVIES_SYNCED"
    log ""
fi

################################################################################
# PHASE 3: DELETE LOWER QUALITY
################################################################################

if [[ "$CURRENT_STATE" =~ ^(START|PREFLIGHT_DONE|ALI_TO_CHRIS_DONE|MOVIES_SYNCED)$ ]]; then
    log "========================================================================"
    log "PHASE 3: Delete Lower Quality Files"
    log "========================================================================"
    log ""
    
    log "Deleting Synology lower quality (1,534 files)..."
    sed -i 's/^EXECUTE=false/EXECUTE=true/' "$SCRIPT_DIR/DELETE_Synology_Movies.sh" 2>/dev/null || true
    bash "$SCRIPT_DIR/DELETE_Synology_Movies.sh" >> "$LOG_FILE" 2>&1
    log_success "Synology deletions done"
    
    log "Deleting Unraid lower quality (513 files)..."
    sed -i 's/^EXECUTE=false/EXECUTE=true/' "$SCRIPT_DIR/DELETE_Unraid_Movies.sh" 2>/dev/null || true
    bash "$SCRIPT_DIR/DELETE_Unraid_Movies.sh" >> "$LOG_FILE" 2>&1
    log_success "Unraid deletions done"
    
    save_state "COMPLETE"
    log ""
fi

################################################################################
# DONE
################################################################################

log "========================================================================"
log "PROJECT MOTHER COMPLETE!"
log "========================================================================"
log ""
log "Summary:"
log "  ✓ Copied 5,347 targeted files"
log "  ✓ Deleted 2,047 lower quality files"
log ""
rm -f "$STATE_FILE"
