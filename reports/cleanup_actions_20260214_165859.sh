#!/bin/bash
#==============================================================================
# Duplicate Cleanup Script - TV
# Generated: 2026-02-14 16:58:59
# Groups with duplicates: 2
# Files to remove: 2
# Space to reclaim: 3.75 GB
#
# Usage:
#   DRY_RUN=true ./cleanup_actions_20260214_165859.sh    # Preview (default)
#   DRY_RUN=false ./cleanup_actions_20260214_165859.sh   # Actually cleanup
#==============================================================================

DRY_RUN="${DRY_RUN:-true}"
REMOVED=0
FAILED=0
SKIPPED=0

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m"

log() { echo -e "[$(date "+%Y-%m-%d %H:%M:%S")] $1"; }

cleanup_file() {
    local file="$1"
    local desc="$2"
    local ssh_target="unraid"
    if [ "$DRY_RUN" = "true" ]; then
        log "${BLUE}[DRY RUN]${NC} Would remove: $desc"
        log "  $file"
        ((REMOVED++))
        return 0
    fi
    local deleted_dir="/mnt/user/Media/Deleted TV"
    if ssh "$ssh_target" "mkdir -p \"$deleted_dir\" && mv \"$file\" \"$deleted_dir/\""; then
        log "${GREEN}REMOVED${NC}: $desc"
        ((REMOVED++))
    else
        log "${RED}FAILED${NC}: $desc"
        ((FAILED++))
    fi
}

log "Starting duplicate cleanup..."
if [ "$DRY_RUN" = "true" ]; then
    log "${BLUE}DRY RUN MODE - no files will be modified${NC}"
fi
echo ""

# Group: The Bad Guys - Breaking In (2025) {tvdb-469095}/Season 01/S01E01
# KEEP: The Bad Guys - Breaking In (2025) - S01E01 - Bad Beginnings [WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv (score: 3509)
cleanup_file "/mnt/user/Media/TV Shows/The Bad Guys - Breaking In (2025) {tvdb-469095}/Season 01/The Bad Guys - Breaking In (2025) - S01E01 - Bad Beginnings [NF][WEBDL-1080p][AAC 5.1][x264]-OldT.mkv" "The Bad Guys - Breaking In (2025) - S01E01 - Bad Beginnings [NF][WEBDL-1080p][AAC 5.1][x264]-OldT.mkv (score: 3418 vs keeper 3509)"

# Group: The Bad Guys - Breaking In (2025) {tvdb-469095}/Season 01/S01E02
# KEEP: The Bad Guys - Breaking In (2025) - S01E02 - The Sweet Sweet Steal [WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv (score: 3509)
cleanup_file "/mnt/user/Media/TV Shows/The Bad Guys - Breaking In (2025) {tvdb-469095}/Season 01/The Bad Guys - Breaking In (2025) - S01E02 - The Sweet Sweet Steal [NF][WEBDL-1080p][AAC 5.1][x264]-OldT.mkv" "The Bad Guys - Breaking In (2025) - S01E02 - The Sweet Sweet Steal [NF][WEBDL-1080p][AAC 5.1][x264]-OldT.mkv (score: 3418 vs keeper 3509)"

echo ""
echo "========================================"
echo "CLEANUP SUMMARY"
echo "========================================"
echo "Removed: $REMOVED"
echo "Skipped: $SKIPPED"
echo "Failed:  $FAILED"
echo "========================================"
if [ "$DRY_RUN" = "true" ]; then
    echo "This was a DRY RUN - no files were modified"
    echo "Run with DRY_RUN=false to actually cleanup"
fi
