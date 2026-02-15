#!/bin/bash
#==============================================================================
# Cleanup Duplicates Script - Project Mother
#
# Actions:
#   1. Delete 4K (2160p) files if 1080p version exists in same folder
#   2. Delete lower quality duplicates based on TRaSH guide scoring
#
# TRaSH Quality Hierarchy (best to worst):
#   Remux-1080p > Bluray-1080p > WEBDL-1080p > WEBRip-1080p > HDTV-1080p
#   For same quality: newer file wins (likely the upgrade)
#
# Usage:
#   DRY_RUN=true ./cleanup_duplicates.sh   # Preview only (default)
#   DRY_RUN=false ./cleanup_duplicates.sh  # Actually delete files
#
#==============================================================================

set -o pipefail

DRY_RUN="${DRY_RUN:-true}"
LOG_FILE="${LOG_FILE:-/opt/mother/logs/cleanup_duplicates_$(date +%Y%m%d_%H%M%S).log}"
MOVIES_PATH="/mnt/synology/rs-movies"

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m"

# Counters
DELETED_4K=0
DELETED_DUPE=0
TOTAL_SAVED_GB=0

log() {
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Get quality score based on TRaSH guide (higher = better)
get_quality_score() {
    local filename="$1"
    local score=0

    # Base quality scores
    if [[ "$filename" =~ Remux-1080p ]]; then
        score=1000
    elif [[ "$filename" =~ Bluray-1080p ]]; then
        score=800
    elif [[ "$filename" =~ WEBDL-1080p ]]; then
        score=600
    elif [[ "$filename" =~ WEBRip-1080p ]]; then
        score=400
    elif [[ "$filename" =~ HDTV-1080p ]]; then
        score=200
    elif [[ "$filename" =~ 720p ]]; then
        score=100
    else
        score=300  # Unknown, assume mid-range
    fi

    # Bonus for preferred attributes
    [[ "$filename" =~ "Proper" ]] && ((score += 50))
    [[ "$filename" =~ "Repack" ]] && ((score += 40))
    [[ "$filename" =~ "IMAX" ]] && ((score += 30))
    [[ "$filename" =~ "Remaster" ]] && ((score += 20))

    # Penalty for x265 without HDR at 1080p (per TRaSH guide)
    if [[ "$filename" =~ x265 ]] || [[ "$filename" =~ h265 ]] || [[ "$filename" =~ HEVC ]]; then
        if [[ ! "$filename" =~ HDR ]] && [[ ! "$filename" =~ "DV" ]] && [[ ! "$filename" =~ "Dolby Vision" ]]; then
            ((score -= 300))
        fi
    fi

    echo "$score"
}

# Get file size in bytes
get_file_size() {
    stat -c%s "$1" 2>/dev/null || echo 0
}

# Format bytes to human readable
format_size() {
    local bytes=$1
    if [ "$bytes" -gt 1073741824 ]; then
        echo "$(echo "scale=2; $bytes / 1073741824" | bc)GB"
    elif [ "$bytes" -gt 1048576 ]; then
        echo "$(echo "scale=2; $bytes / 1048576" | bc)MB"
    else
        echo "${bytes}B"
    fi
}

delete_file() {
    local file="$1"
    local reason="$2"
    local size=$(get_file_size "$file")
    local size_gb=$(echo "scale=2; $size / 1073741824" | bc)

    if [ "$DRY_RUN" = "true" ]; then
        log "${YELLOW}[DRY RUN]${NC} Would delete: $(basename "$file")"
        log "  Reason: $reason"
        log "  Size: $(format_size $size)"
    else
        if rm -f "$file"; then
            log "${GREEN}DELETED${NC}: $(basename "$file")"
            log "  Reason: $reason"
            log "  Size: $(format_size $size)"
        else
            log "${RED}FAILED${NC}: Could not delete $(basename "$file")"
            return 1
        fi
    fi

    TOTAL_SAVED_GB=$(echo "$TOTAL_SAVED_GB + $size_gb" | bc)
    return 0
}

log "=========================================="
log "Cleanup Duplicates Script"
log "DRY_RUN: $DRY_RUN"
log "Movies Path: $MOVIES_PATH"
log "=========================================="

#------------------------------------------------------------------------------
# Step 1: Delete 4K files if 1080p exists
#------------------------------------------------------------------------------
log ""
log "${BLUE}=== Step 1: Remove 4K files where 1080p exists ===${NC}"

while IFS= read -r file_4k; do
    [ -z "$file_4k" ] && continue

    dir=$(dirname "$file_4k")

    # Check if any 1080p file exists in same folder
    has_1080p=$(ls -1 "$dir" 2>/dev/null | grep -iE "1080p\.(mkv|mp4|avi)$" | head -1)

    if [ -n "$has_1080p" ]; then
        log ""
        log "Found 4K with 1080p alternative:"
        log "  4K: $(basename "$file_4k")"
        log "  1080p: $has_1080p"
        delete_file "$file_4k" "4K file with 1080p alternative available"
        ((DELETED_4K++))
    fi
done < <(find "$MOVIES_PATH" -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" \) | grep -E "2160p|WEBDL-2160p|Remux-2160p|Bluray-2160p" 2>/dev/null)

log ""
log "4K files to delete: $DELETED_4K"

#------------------------------------------------------------------------------
# Step 2: Delete lower quality duplicates
#------------------------------------------------------------------------------
log ""
log "${BLUE}=== Step 2: Remove lower quality duplicates ===${NC}"

# Find all movie folders
find "$MOVIES_PATH" -mindepth 1 -maxdepth 1 -type d | while read -r movie_dir; do
    # Get all video files in this folder
    mapfile -t video_files < <(find "$movie_dir" -maxdepth 1 -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" \) 2>/dev/null | grep -v "\.nfo$" | grep -v "\.jpg$" | grep -v "\.png$")

    # Skip if only 0 or 1 video file
    [ ${#video_files[@]} -le 1 ] && continue

    log ""
    log "Processing: $(basename "$movie_dir")"
    log "  Found ${#video_files[@]} video files"

    # Score each file
    declare -A file_scores
    best_file=""
    best_score=-999999

    for vfile in "${video_files[@]}"; do
        score=$(get_quality_score "$(basename "$vfile")")
        file_scores["$vfile"]=$score
        log "  Score $score: $(basename "$vfile")"

        if [ "$score" -gt "$best_score" ]; then
            best_score=$score
            best_file="$vfile"
        fi
    done

    log "  ${GREEN}Keeping${NC}: $(basename "$best_file") (score: $best_score)"

    # Delete all except best
    for vfile in "${video_files[@]}"; do
        if [ "$vfile" != "$best_file" ]; then
            delete_file "$vfile" "Lower quality duplicate (score: ${file_scores[$vfile]} vs $best_score)"
            ((DELETED_DUPE++))
        fi
    done

    unset file_scores
done

#------------------------------------------------------------------------------
# Summary
#------------------------------------------------------------------------------
log ""
log "=========================================="
log "${GREEN}SUMMARY${NC}"
log "=========================================="
log "4K files removed: $DELETED_4K"
log "Duplicate files removed: $DELETED_DUPE"
log "Total files removed: $((DELETED_4K + DELETED_DUPE))"
log "Space saved: ${TOTAL_SAVED_GB}GB"
log ""

if [ "$DRY_RUN" = "true" ]; then
    log "${YELLOW}This was a DRY RUN - no files were actually deleted${NC}"
    log "Run with DRY_RUN=false to delete files"
fi
