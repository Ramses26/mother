#!/bin/bash
#==============================================================================
# Cleanup Junk Files - Project Mother
#
# Deletes from Synology media library paths:
#   1. .m2ts files that have a companion .mkv/.mp4 in the same folder
#   2. .filepart (incomplete downloads)
#   3. Temp extension files (SABnzbd/NZBGet hidden dotfiles: .foo.mkv.XXXXXX)
#   4. .nzb files
#
# Does NOT touch the downloads/ directory.
# DRY_RUN=true by default.
#==============================================================================

DRY_RUN="${DRY_RUN:-true}"

MEDIA_PATHS=(
    "/mnt/synology/rs-movies"
    "/mnt/synology/rs-tv"
    "/mnt/synology/rs-4kmedia/4kmovies"
    "/mnt/synology/rs-4kmedia/4ktv"
)
EXCLUDED=( "#recycle" "@eaDir" ".Trash" "downloads" )

REMOVED=0
SKIPPED=0
TOTAL_BYTES=0
LOG="/opt/mother/logs/cleanup_junk_$(date +%Y%m%d_%H%M%S).log"

mkdir -p /opt/mother/logs

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG"; }

delete_file() {
    local f="$1"
    local reason="$2"
    local size
    size=$(stat -c%s "$f" 2>/dev/null || echo 0)
    if [ "$DRY_RUN" = "true" ]; then
        log "${BLUE}[DRY RUN]${NC} Would delete ($reason): $f"
        ((REMOVED++))
        TOTAL_BYTES=$((TOTAL_BYTES + size))
    else
        if rm -f "$f"; then
            log "${GREEN}DELETED${NC} ($reason): $f"
            ((REMOVED++))
            TOTAL_BYTES=$((TOTAL_BYTES + size))
        else
            log "${RED}FAILED${NC}: $f"
        fi
    fi
}

build_prune_args() {
    local args=()
    for ex in "${EXCLUDED[@]}"; do
        args+=( -name "$ex" -prune -o )
    done
    echo "${args[@]}"
}

log "=== Junk File Cleanup ==="
[ "$DRY_RUN" = "true" ] && log "${BLUE}DRY RUN MODE — no files will be deleted${NC}"
log ""

#------------------------------------------------------------------------------
# 1. .m2ts files with a companion .mkv or .mp4 in same folder
#------------------------------------------------------------------------------
log "--- Pass 1: .m2ts with companion .mkv ---"
for root in "${MEDIA_PATHS[@]}"; do
    [ -d "$root" ] || continue
    while IFS= read -r m2ts; do
        dir=$(dirname "$m2ts")
        companion=$(find "$dir" -maxdepth 1 \( -name "*.mkv" -o -name "*.mp4" -o -name "*.MKV" \) -not -name "$(basename "$m2ts")" 2>/dev/null | head -1)
        if [ -n "$companion" ]; then
            delete_file "$m2ts" "m2ts+mkv duplicate"
        fi
    done < <(find "$root" \( -name "#recycle" -o -name "@eaDir" -o -name "downloads" \) -prune -o -name "*.m2ts" -print 2>/dev/null)
done

#------------------------------------------------------------------------------
# 2. .filepart files
#------------------------------------------------------------------------------
log ""
log "--- Pass 2: .filepart files ---"
for root in "${MEDIA_PATHS[@]}"; do
    [ -d "$root" ] || continue
    while IFS= read -r f; do
        delete_file "$f" "incomplete download"
    done < <(find "$root" \( -name "#recycle" -o -name "@eaDir" -o -name "downloads" \) -prune -o -name "*.filepart" -print 2>/dev/null)
done

#------------------------------------------------------------------------------
# 3. Temp extension files (hidden dotfiles: .Movie.Name.mkv.XXXXXX)
#    Pattern: hidden file whose name contains .mkv. .mp4. .avi. .ts. followed
#    by 4-8 alphanumeric chars as the final extension
#------------------------------------------------------------------------------
log ""
log "--- Pass 3: Temp extension files (stalled downloads) ---"
for root in "${MEDIA_PATHS[@]}"; do
    [ -d "$root" ] || continue
    while IFS= read -r f; do
        delete_file "$f" "stalled download temp file"
    done < <(find "$root" \( -name "#recycle" -o -name "@eaDir" -o -name "downloads" \) -prune -o \
        -name ".*" -type f -print 2>/dev/null | \
        grep -E '\.(mkv|mp4|avi|ts|MKV)\.[a-zA-Z0-9]{4,8}$')
done

#------------------------------------------------------------------------------
# 4. .nzb files
#------------------------------------------------------------------------------
log ""
log "--- Pass 4: .nzb files ---"
for root in "${MEDIA_PATHS[@]}"; do
    [ -d "$root" ] || continue
    while IFS= read -r f; do
        delete_file "$f" "old NZB source"
    done < <(find "$root" \( -name "#recycle" -o -name "@eaDir" -o -name "downloads" \) -prune -o -name "*.nzb" -print 2>/dev/null)
done

#------------------------------------------------------------------------------
# Summary
#------------------------------------------------------------------------------
gb=$(echo "scale=2; $TOTAL_BYTES / 1073741824" | bc)
log ""
log "=== SUMMARY ==="
log "Files processed: $REMOVED"
log "Space freed:     ${gb} GB"
[ "$DRY_RUN" = "true" ] && log "** DRY RUN — rerun with DRY_RUN=false to actually delete **"
log "Log: $LOG"
