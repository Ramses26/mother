#!/bin/bash
###############################################################################
# Live Sync Script - Project Mother
#
# Syncs NEW content from Chris's Synology to Ali's Unraid
# Uses --ignore-existing to skip files already present
# Run this hourly while the main quality-comparison sync is running
#
# Usage:
#   ./live_sync.sh              # Normal run
#   DRY_RUN=true ./live_sync.sh # Preview only
#   PARALLEL=4 ./live_sync.sh   # 4 parallel transfers
###############################################################################

set -o pipefail

# Configuration
DRY_RUN="${DRY_RUN:-false}"
PARALLEL="${PARALLEL:-2}"
LOG_FILE="${LOG_FILE:-/var/log/live_sync.log}"

# Source paths (Chris's Synology via NFS on Mother)
SRC_MOVIES_1080="/mnt/synology/rs-movies/"
SRC_MOVIES_4K="/mnt/synology/rs-4kmedia/4kmovies/"
SRC_TV_1080="/mnt/synology/rs-tv/"
SRC_TV_4K="/mnt/synology/rs-4kmedia/4ktv/"

# Destination paths (Ali's Unraid via NFS on Mother)
DST_MOVIES_1080="/mnt/unraid/media/Movies/"
DST_MOVIES_4K="/mnt/unraid/media/4K Movies/"
DST_TV_1080="/mnt/unraid/media/TV Shows/"
DST_TV_4K="/mnt/unraid/media/4K TV Shows/"

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
NC="\033[0m"

log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

do_rsync() {
    local src="$1"
    local dst="$2"
    local name="$3"

    log "Syncing $name..."
    log "  From: $src"
    log "  To:   $dst"

    if [ "$DRY_RUN" = "true" ]; then
        rsync -avhn --ignore-existing --exclude='#recycle' --exclude='@eaDir' "$src" "$dst" 2>&1 | tail -20
        log "${YELLOW}[DRY RUN]${NC} $name"
    else
        if rsync -avh --ignore-existing --exclude='#recycle' --exclude='@eaDir' "$src" "$dst" 2>&1 | tee -a "$LOG_FILE"; then
            log "${GREEN}OK${NC}: $name"
        else
            log "${RED}FAILED${NC}: $name"
        fi
    fi
}

# Main
log "=========================================="
log "LIVE SYNC START"
log "=========================================="

if [ "$DRY_RUN" = "true" ]; then
    log "${YELLOW}DRY RUN MODE - No changes will be made${NC}"
fi

# Check mounts
if [ ! -d "$SRC_MOVIES_1080" ]; then
    log "${RED}ERROR: Synology mount not found: $SRC_MOVIES_1080${NC}"
    exit 1
fi

if [ ! -d "$DST_MOVIES_1080" ]; then
    log "${RED}ERROR: Unraid mount not found: $DST_MOVIES_1080${NC}"
    exit 1
fi

# Run syncs
do_rsync "$SRC_MOVIES_1080" "$DST_MOVIES_1080" "Movies 1080p"
do_rsync "$SRC_MOVIES_4K" "$DST_MOVIES_4K" "Movies 4K"
do_rsync "$SRC_TV_1080" "$DST_TV_1080" "TV Shows 1080p"
do_rsync "$SRC_TV_4K" "$DST_TV_4K" "TV Shows 4K"

log "=========================================="
log "LIVE SYNC COMPLETE"
log "=========================================="
