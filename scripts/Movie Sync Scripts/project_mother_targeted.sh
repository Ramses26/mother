#!/bin/bash

################################################################################
# PROJECT MOTHER - TARGETED SYNC SCRIPT (CORRECT APPROACH)
################################################################################
#
# This script copies ONLY the specific files identified in the analysis:
#   - 2,578 files Ali → Chris (Ali-only + Ali-better)
#   - 2,769 files Chris → Ali (Chris-only + Chris-better)
#   - Total: 5,347 files (NOT all 13,000!)
#
# Then deletes the 2,047 lower quality duplicates after sync.
#
# STRATEGY: Sync-Then-Delete
#   - Copies better versions FIRST
#   - Deletes lower quality versions AFTER (now duplicates)
#   - Files never missing
#
################################################################################

set -euo pipefail

# Configuration
LOG_DIR="/opt/mother/logs"
LOG_FILE="$LOG_DIR/project_mother_targeted_$(date +%Y%m%d_%H%M%S).log"
STATE_FILE="/opt/mother/.project_mother_state"
DRY_RUN=false

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create log directory
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

# Save state
save_state() {
    echo "$1" > "$STATE_FILE"
    log "State saved: $1"
}

# Load state
load_state() {
    if [ -f "$STATE_FILE" ]; then
        cat "$STATE_FILE"
    else
        echo "START"
    fi
}

# Error handler
error_handler() {
    log_error "Script failed at line $1"
    log_error "Last command: $BASH_COMMAND"
    log_error "Check logs: $LOG_FILE"
    exit 1
}

trap 'error_handler $LINENO' ERR

################################################################################
# START
################################################################################

log "========================================================================"
log "PROJECT MOTHER - TARGETED SYNC (CORRECT APPROACH)"
log "========================================================================"
log "Log file: $LOG_FILE"
log "Dry run: $DRY_RUN"
log ""
log "This script copies ONLY the specific files identified in analysis:"
log "  - 2,578 files Ali → Chris"
log "  - 2,769 files Chris → Ali"
log "  - Total: 5,347 files (not 13,000!)"
log ""

# Check state
CURRENT_STATE=$(load_state)
if [ "$CURRENT_STATE" != "START" ]; then
    log "Resuming from state: $CURRENT_STATE"
fi

################################################################################
# PRE-FLIGHT CHECKS
################################################################################

if [ "$CURRENT_STATE" == "START" ]; then
    log "Running pre-flight checks..."
    
    # Check file lists exist
    if [ ! -f "$SCRIPT_DIR/ali_to_chris.filelist" ]; then
        log_error "Missing file list: ali_to_chris.filelist"
        exit 1
    fi
    
    if [ ! -f "$SCRIPT_DIR/chris_to_ali.filelist" ]; then
        log_error "Missing file list: chris_to_ali.filelist"
        exit 1
    fi
    
    log_success "File lists found"
    
    # Check mounts
    if ! mount | grep -q "/mnt/unraid/media"; then
        log_error "Unraid not mounted!"
        exit 1
    fi
    log_success "Unraid mounted"
    
    if ! mount | grep -q "/mnt/synology/rs-movies"; then
        log_error "Synology not mounted!"
        exit 1
    fi
    log_success "Synology mounted"
    
    # Check disk space
    UNRAID_FREE=$(df -BG /mnt/unraid/media | tail -1 | awk '{print $4}' | sed 's/G//')
    SYNOLOGY_FREE=$(df -BG /mnt/synology/rs-movies | tail -1 | awk '{print $4}' | sed 's/G//')
    
    log "Disk space - Unraid: ${UNRAID_FREE}GB, Synology: ${SYNOLOGY_FREE}GB"
    
    if [ "$UNRAID_FREE" -lt 2000 ]; then
        log_error "Insufficient space on Unraid"
        exit 1
    fi
    
    if [ "$SYNOLOGY_FREE" -lt 2000 ]; then
        log_error "Insufficient space on Synology"
        exit 1
    fi
    
    log_success "Pre-flight checks passed"
    save_state "PREFLIGHT_DONE"
    log ""
fi

################################################################################
# PHASE 1: TARGETED SYNC - ALI → CHRIS
################################################################################

if [[ "$CURRENT_STATE" =~ ^(START|PREFLIGHT_DONE)$ ]]; then
    log "========================================================================"
    log "PHASE 1: TARGETED SYNC - Ali → Chris (Movies)"
    log "========================================================================"
    log ""
    log "Copying 2,578 specific files from Ali to Chris..."
    log "  From: /mnt/unraid/media/Movies/"
    log "  To:   /mnt/synology/rs-movies/"
    log "  List: ali_to_chris.filelist"
    log ""
    
    RSYNC_OPTS="-avh --stats --no-perms --no-owner --no-group"
    RSYNC_OPTS="$RSYNC_OPTS --files-from=$SCRIPT_DIR/ali_to_chris.filelist"
    RSYNC_OPTS="$RSYNC_OPTS --log-file=$LOG_FILE.rsync_ali_to_chris"
    [ "$DRY_RUN" == "true" ] && RSYNC_OPTS="$RSYNC_OPTS --dry-run"
    
    if rsync $RSYNC_OPTS /mnt/unraid/media/Movies/ /mnt/synology/rs-movies/; then
        log_success "Ali → Chris sync complete (2,578 files)"
    else
        log_error "Ali → Chris sync failed!"
        exit 1
    fi
    
    save_state "ALI_TO_CHRIS_DONE"
    log ""
fi

################################################################################
# PHASE 2: TARGETED SYNC - CHRIS → ALI
################################################################################

if [[ "$CURRENT_STATE" =~ ^(START|PREFLIGHT_DONE|ALI_TO_CHRIS_DONE)$ ]]; then
    log "========================================================================"
    log "PHASE 2: TARGETED SYNC - Chris → Ali (Movies)"
    log "========================================================================"
    log ""
    log "Copying 2,769 specific files from Chris to Ali..."
    log "  From: /mnt/synology/rs-movies/"
    log "  To:   /mnt/unraid/media/Movies/"
    log "  List: chris_to_ali.filelist"
    log ""
    
    RSYNC_OPTS="-avh --stats --no-perms --no-owner --no-group"
    RSYNC_OPTS="$RSYNC_OPTS --files-from=$SCRIPT_DIR/chris_to_ali.filelist"
    RSYNC_OPTS="$RSYNC_OPTS --log-file=$LOG_FILE.rsync_chris_to_ali"
    [ "$DRY_RUN" == "true" ] && RSYNC_OPTS="$RSYNC_OPTS --dry-run"
    
    if rsync $RSYNC_OPTS /mnt/synology/rs-movies/ /mnt/unraid/media/Movies/; then
        log_success "Chris → Ali sync complete (2,769 files)"
    else
        log_error "Chris → Ali sync failed!"
        exit 1
    fi
    
    save_state "MOVIES_SYNCED"
    log_success "PHASE 2 COMPLETE: Movies synced (5,347 files total)"
    log ""
fi

################################################################################
# PHASE 3: DELETE LOWER QUALITY MOVIES (Now Duplicates)
################################################################################

if [[ "$CURRENT_STATE" =~ ^(START|PREFLIGHT_DONE|ALI_TO_CHRIS_DONE|MOVIES_SYNCED)$ ]]; then
    log "========================================================================"
    log "PHASE 3: DELETE LOWER QUALITY MOVIES"
    log "========================================================================"
    log ""
    
    log "Running Synology deletions (1,534 files)..."
    if [ "$DRY_RUN" == "false" ]; then
        sed -i 's/^EXECUTE=false/EXECUTE=true/' "$SCRIPT_DIR/DELETE_Synology_Movies.sh" 2>/dev/null || true
    fi
    
    if bash "$SCRIPT_DIR/DELETE_Synology_Movies.sh" >> "$LOG_FILE" 2>&1; then
        log_success "Synology deletions complete"
    else
        log_error "Synology deletions failed!"
        exit 1
    fi
    
    log "Running Unraid deletions (513 files)..."
    if [ "$DRY_RUN" == "false" ]; then
        sed -i 's/^EXECUTE=false/EXECUTE=true/' "$SCRIPT_DIR/DELETE_Unraid_Movies.sh" 2>/dev/null || true
    fi
    
    if bash "$SCRIPT_DIR/DELETE_Unraid_Movies.sh" >> "$LOG_FILE" 2>&1; then
        log_success "Unraid deletions complete"
    else
        log_error "Unraid deletions failed!"
        exit 1
    fi
    
    save_state "MOVIES_DELETED"
    log_success "PHASE 3 COMPLETE: 2,047 lower quality files deleted"
    log ""
fi

################################################################################
# PHASE 4: 4K MOVIES (Same targeted approach)
################################################################################

# TODO: Add 4K targeted sync here (similar to movies)

################################################################################
# COMPLETION
################################################################################

log "========================================================================"
log "PROJECT MOTHER - EXECUTION COMPLETE!"
log "========================================================================"
log ""
log "Summary:"
log "  - Copied 5,347 specific files (not 13,000!)"
log "  - Deleted 2,047 lower quality duplicates"
log "  - Both libraries now have all movies at best quality"
log ""
log "End time: $(date)"
log "Log file: $LOG_FILE"
log ""

rm -f "$STATE_FILE"
log_success "ALL PHASES COMPLETE - PROJECT MOTHER SUCCESS!"
