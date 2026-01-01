#!/bin/bash
#==============================================================================
# Project Mother Sync Script
# RUN THIS ON MOTHER (10.0.0.162)
#==============================================================================
# Generated: 2025-12-31 17:16:46
#
# Features:
#   - Progress tracking: completed commands are logged and skipped on re-run
#   - Error handling: failures logged with exit code, script continues
#   - Set EXIT_ON_ERROR=true to stop on first error
#   - Timestamps in log for monitoring with: tail -f <logfile>
#
# This script uses Mother's mount paths:
#   Synology: /mnt/synology/rs-*
#   Unraid:   /mnt/unraid/media/*
#
# Usage:
#   ./sync_actions_XXXXX.sh                    # Normal run (4 parallel)
#   PARALLEL=8 ./sync_actions_XXXXX.sh         # 8 parallel transfers
#   PARALLEL=1 ./sync_actions_XXXXX.sh         # Sequential (safe)
#   EXIT_ON_ERROR=true ./sync_actions_XXXXX.sh # Stop on first error
#   DRY_RUN=true ./sync_actions_XXXXX.sh       # Preview only
#
# Bandwidth: 4 parallel = ~400 Mbps, 8 parallel = ~800 Mbps
#
#==============================================================================

set -o pipefail

PROGRESS_FILE="${PROGRESS_FILE:-sync_progress_20251231_171646.log}"
ERROR_LOG="${ERROR_LOG:-sync_errors_20251231_171646.log}"
EXIT_ON_ERROR="${EXIT_ON_ERROR:-false}"
DRY_RUN="${DRY_RUN:-false}"
PARALLEL="${PARALLEL:-4}"  # Number of parallel transfers

# Colors for output
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

# Statistics
TOTAL=0
COMPLETED=0
SKIPPED=0
FAILED=0

log() {
    echo -e "[$(date "+%Y-%m-%d %H:%M:%S")] $1"
}

log_error() {
    echo -e "[$(date "+%Y-%m-%d %H:%M:%S")] ${RED}ERROR${NC}: $1" | tee -a "$ERROR_LOG"
}

# Check if command was already completed
is_completed() {
    local hash="$1"
    grep -q "^$hash$" "$PROGRESS_FILE" 2>/dev/null
}

# Mark command as completed
mark_completed() {
    local hash="$1"
    echo "$hash" >> "$PROGRESS_FILE"
}

# Semaphore for parallel execution
wait_for_slot() {
    while [ $(jobs -r | wc -l) -ge $PARALLEL ]; do
        sleep 0.5
    done
}

# Execute command with progress tracking
run_cmd() {
    local desc="$1"
    shift
    local hash
    hash=$(echo "$@" | md5sum | cut -d" " -f1)
    
    ((TOTAL++))
    
    if is_completed "$hash"; then
        log "${YELLOW}SKIP${NC} [already done] $desc"
        ((SKIPPED++))
        return 0
    fi
    
    if [ "$DRY_RUN" = "true" ]; then
        log "${BLUE}[DRY RUN]${NC} $desc"
        log "  Command: $@"
        ((COMPLETED++))
        return 0
    fi
    
    # Wait for a slot if running parallel
    if [ "$PARALLEL" -gt 1 ]; then
        wait_for_slot
    fi
    
    log "RUNNING: $desc"
    
    # Run in background if parallel > 1
    if [ "$PARALLEL" -gt 1 ]; then
        (
            if "$@" 2>&1; then
                mark_completed "$hash"
                log "${GREEN}OK${NC}: $desc"
            else
                log_error "Failed: $desc"
            fi
        ) &
    else
        if "$@"; then
            mark_completed "$hash"
            log "${GREEN}OK${NC}: $desc"
            ((COMPLETED++))
        else
            local exit_code=$?
            log_error "Failed (exit $exit_code): $desc"
            log_error "  Command: $@"
            ((FAILED++))
            
            if [ "$EXIT_ON_ERROR" = "true" ]; then
                log "${RED}Stopping due to EXIT_ON_ERROR=true${NC}"
                print_summary
                exit $exit_code
            fi
        fi
    fi
}

# Print summary
print_summary() {
    echo ""
    echo "========================================"
    echo "SYNC SUMMARY"
    echo "========================================"
    echo "Total:     $TOTAL"
    echo -e "Completed: ${GREEN}$COMPLETED${NC}"
    echo -e "Skipped:   ${YELLOW}$SKIPPED${NC}"
    echo -e "Failed:    ${RED}$FAILED${NC}"
    echo "========================================"
    if [ $FAILED -gt 0 ]; then
        echo "See $ERROR_LOG for failure details"
    fi
}
