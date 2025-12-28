#!/bin/bash

################################################################################
# PROJECT MOTHER - MASTER ORCHESTRATION SCRIPT
################################################################################
#
# STRATEGY: Sync-Then-Delete for safety
#
# Phase 1: Sync Movies (bidirectional)
# Phase 2: Delete lower quality Movies (now duplicates)
# Phase 3: Sync 4K Movies (bidirectional)
# Phase 4: Delete lower quality 4K Movies (now duplicates)
#
# This ensures files are NEVER missing - better version arrives before
# worse version is deleted.
#
# Safe for unattended overnight execution.
#
################################################################################

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Configuration
LOG_DIR="/opt/mother/logs"
LOG_FILE="$LOG_DIR/project_mother_$(date +%Y%m%d_%H%M%S).log"
STATE_FILE="/opt/mother/.project_mother_state"
DRY_RUN=false  # Set to true for testing

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

# Save state for resume capability
save_state() {
    echo "$1" > "$STATE_FILE"
    log "State saved: $1"
}

# Load previous state
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
    log_error "Execution stopped. Check logs: $LOG_FILE"
    exit 1
}

trap 'error_handler $LINENO' ERR

################################################################################
# START
################################################################################

log "========================================================================"
log "PROJECT MOTHER - MASTER ORCHESTRATION"
log "========================================================================"
log "Log file: $LOG_FILE"
log "Dry run: $DRY_RUN"
log ""

# Check if resuming
CURRENT_STATE=$(load_state)
if [ "$CURRENT_STATE" != "START" ]; then
    log "Resuming from state: $CURRENT_STATE"
    read -p "Resume from $CURRENT_STATE? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Starting fresh..."
        CURRENT_STATE="START"
        rm -f "$STATE_FILE"
    fi
fi

################################################################################
# PRE-FLIGHT CHECKS
################################################################################

if [ "$CURRENT_STATE" == "START" ]; then
    log "Running pre-flight checks..."
    
    # Check mounts
    if ! mount | grep -q "/mnt/unraid/media"; then
        log_error "Unraid not mounted!"
        exit 1
    fi
    log_success "Unraid mounted"
    
    if ! mount | grep -q "/mnt/synology/rs-movies"; then
        log_error "Synology Movies not mounted!"
        exit 1
    fi
    log_success "Synology mounted"
    
    # Check disk space
    UNRAID_FREE=$(df -BG /mnt/unraid/media | tail -1 | awk '{print $4}' | sed 's/G//')
    SYNOLOGY_FREE=$(df -BG /mnt/synology/rs-movies | tail -1 | awk '{print $4}' | sed 's/G//')
    
    log "Disk space - Unraid: ${UNRAID_FREE}GB, Synology: ${SYNOLOGY_FREE}GB"
    
    if [ "$UNRAID_FREE" -lt 2000 ]; then
        log_error "Insufficient space on Unraid: ${UNRAID_FREE}GB (need 2300GB)"
        exit 1
    fi
    
    if [ "$SYNOLOGY_FREE" -lt 2000 ]; then
        log_error "Insufficient space on Synology: ${SYNOLOGY_FREE}GB (need 2300GB)"
        exit 1
    fi
    
    log_success "Pre-flight checks passed"
    save_state "PREFLIGHT_DONE"
    log ""
fi

################################################################################
# PHASE 1: SYNC MOVIES (BIDIRECTIONAL)
################################################################################

if [[ "$CURRENT_STATE" =~ ^(START|PREFLIGHT_DONE)$ ]]; then
    log "========================================================================"
    log "PHASE 1: SYNC MOVIES (Bidirectional)"
    log "========================================================================"
    log ""
    
    # Sync Ali → Chris
    log "Step 1a: Syncing Ali → Chris (Movies)..."
    log "From: /mnt/unraid/media/Movies/"
    log "To:   /mnt/synology/rs-movies/"
    
    RSYNC_OPTS="-avh --stats --log-file=$LOG_FILE.rsync_movies_ali_to_chris"
    [ "$DRY_RUN" == "true" ] && RSYNC_OPTS="$RSYNC_OPTS --dry-run"
    
    if rsync $RSYNC_OPTS /mnt/unraid/media/Movies/ /mnt/synology/rs-movies/; then
        log_success "Ali → Chris sync complete"
    else
        log_error "Ali → Chris sync failed!"
        exit 1
    fi
    log ""
    
    # Sync Chris → Ali
    log "Step 1b: Syncing Chris → Ali (Movies)..."
    log "From: /mnt/synology/rs-movies/"
    log "To:   /mnt/unraid/media/Movies/"
    
    RSYNC_OPTS="-avh --stats --log-file=$LOG_FILE.rsync_movies_chris_to_ali"
    [ "$DRY_RUN" == "true" ] && RSYNC_OPTS="$RSYNC_OPTS --dry-run"
    
    if rsync $RSYNC_OPTS /mnt/synology/rs-movies/ /mnt/unraid/media/Movies/; then
        log_success "Chris → Ali sync complete"
    else
        log_error "Chris → Ali sync failed!"
        exit 1
    fi
    
    save_state "MOVIES_SYNCED"
    log_success "PHASE 1 COMPLETE: Movies synced bidirectionally"
    log ""
fi

################################################################################
# PHASE 2: DELETE LOWER QUALITY MOVIES (Now Duplicates)
################################################################################

if [[ "$CURRENT_STATE" =~ ^(START|PREFLIGHT_DONE|MOVIES_SYNCED)$ ]]; then
    log "========================================================================"
    log "PHASE 2: DELETE LOWER QUALITY MOVIES"
    log "========================================================================"
    log ""
    
    # Run Synology Movies deletions
    log "Running Synology Movies deletions (1,534 files)..."
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    if [ "$DRY_RUN" == "false" ]; then
        # Set EXECUTE=true in the deletion script before running
        sed -i 's/^EXECUTE=false/EXECUTE=true/' "$SCRIPT_DIR/DELETE_Synology_Movies.sh" 2>/dev/null || true
    fi
    
    if bash "$SCRIPT_DIR/DELETE_Synology_Movies.sh" >> "$LOG_FILE" 2>&1; then
        log_success "Synology Movies deletions complete"
    else
        log_error "Synology Movies deletions failed!"
        exit 1
    fi
    
    # Run Unraid Movies deletions (via NFS mount)
    log "Running Unraid Movies deletions (513 files)..."
    
    if [ "$DRY_RUN" == "false" ]; then
        sed -i 's/^EXECUTE=false/EXECUTE=true/' "$SCRIPT_DIR/DELETE_Unraid_Movies.sh" 2>/dev/null || true
    fi
    
    if bash "$SCRIPT_DIR/DELETE_Unraid_Movies.sh" >> "$LOG_FILE" 2>&1; then
        log_success "Unraid Movies deletions complete"
    else
        log_error "Unraid Movies deletions failed!"
        exit 1
    fi
    
    save_state "MOVIES_DELETED"
    log_success "PHASE 2 COMPLETE: Lower quality movies deleted"
    log ""
fi

################################################################################
# PHASE 3: SYNC 4K MOVIES (BIDIRECTIONAL)
################################################################################

if [[ "$CURRENT_STATE" =~ ^(START|PREFLIGHT_DONE|MOVIES_SYNCED|MOVIES_DELETED)$ ]]; then
    log "========================================================================"
    log "PHASE 3: SYNC 4K MOVIES (Bidirectional)"
    log "========================================================================"
    log ""
    
    # Sync Ali → Chris
    log "Step 3a: Syncing Ali → Chris (4K)..."
    log "From: /mnt/unraid/media/4K Movies/"
    log "To:   /mnt/synology/rs-4kmedia/4kmovies/"
    
    RSYNC_OPTS="-avh --stats --log-file=$LOG_FILE.rsync_4k_ali_to_chris"
    [ "$DRY_RUN" == "true" ] && RSYNC_OPTS="$RSYNC_OPTS --dry-run"
    
    if rsync $RSYNC_OPTS "/mnt/unraid/media/4K Movies/" /mnt/synology/rs-4kmedia/4kmovies/; then
        log_success "Ali → Chris 4K sync complete"
    else
        log_error "Ali → Chris 4K sync failed!"
        exit 1
    fi
    log ""
    
    # Sync Chris → Ali
    log "Step 3b: Syncing Chris → Ali (4K)..."
    log "From: /mnt/synology/rs-4kmedia/4kmovies/"
    log "To:   /mnt/unraid/media/4K Movies/"
    
    RSYNC_OPTS="-avh --stats --log-file=$LOG_FILE.rsync_4k_chris_to_ali"
    [ "$DRY_RUN" == "true" ] && RSYNC_OPTS="$RSYNC_OPTS --dry-run"
    
    if rsync $RSYNC_OPTS /mnt/synology/rs-4kmedia/4kmovies/ "/mnt/unraid/media/4K Movies/"; then
        log_success "Chris → Ali 4K sync complete"
    else
        log_error "Chris → Ali 4K sync failed!"
        exit 1
    fi
    
    save_state "4K_SYNCED"
    log_success "PHASE 3 COMPLETE: 4K movies synced bidirectionally"
    log ""
fi

################################################################################
# PHASE 4: DELETE LOWER QUALITY 4K (Now Duplicates)
################################################################################

if [[ "$CURRENT_STATE" =~ ^(START|PREFLIGHT_DONE|MOVIES_SYNCED|MOVIES_DELETED|4K_SYNCED)$ ]]; then
    log "========================================================================"
    log "PHASE 4: DELETE LOWER QUALITY 4K MOVIES"
    log "========================================================================"
    log ""
    
    # Run Synology 4K deletions
    log "Running Synology 4K deletions (94 files)..."
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    if [ "$DRY_RUN" == "false" ]; then
        sed -i 's/^EXECUTE=false/EXECUTE=true/' "$SCRIPT_DIR/DELETE_Synology_4K.sh" 2>/dev/null || true
    fi
    
    if bash "$SCRIPT_DIR/DELETE_Synology_4K.sh" >> "$LOG_FILE" 2>&1; then
        log_success "Synology 4K deletions complete"
    else
        log_error "Synology 4K deletions failed!"
        exit 1
    fi
    
    # Run Unraid 4K deletions
    log "Running Unraid 4K deletions (6 files)..."
    
    if [ "$DRY_RUN" == "false" ]; then
        sed -i 's/^EXECUTE=false/EXECUTE=true/' "$SCRIPT_DIR/DELETE_Unraid_4K.sh" 2>/dev/null || true
    fi
    
    if bash "$SCRIPT_DIR/DELETE_Unraid_4K.sh" >> "$LOG_FILE" 2>&1; then
        log_success "Unraid 4K deletions complete"
    else
        log_error "Unraid 4K deletions failed!"
        exit 1
    fi
    
    save_state "4K_DELETED"
    log_success "PHASE 4 COMPLETE: Lower quality 4K movies deleted"
    log ""
fi

################################################################################
# COMPLETION
################################################################################

log "========================================================================"
log "PROJECT MOTHER - EXECUTION COMPLETE!"
log "========================================================================"
log ""
log "Summary:"
log "  - Movies synced bidirectionally"
log "  - 4K movies synced bidirectionally"
log "  - Lower quality files deleted"
log ""
log "End time: $(date)"
log "Log file: $LOG_FILE"
log ""
log "Next steps:"
log "  1. Review logs for any warnings"
log "  2. Verify file counts match expectations"
log "  3. Spot-check a few movies for quality"
log "  4. Update Radarr/Plex libraries"
log ""

# Clean up state file on success
rm -f "$STATE_FILE"

log_success "ALL PHASES COMPLETE - PROJECT MOTHER SUCCESS!"
