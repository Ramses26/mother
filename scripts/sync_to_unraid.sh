#!/bin/bash

###############################################################################
# Synology to Unraid Sync Script
# 
# Purpose: Sync media from Chris's Synology to Ali's Unraid in real-time
# Method: rclone with real-time monitoring
# 
# This script syncs:
#   - RS-Movies (10.0.0.160) → Unraid Movies
#   - RS-TV (10.0.0.88) → Unraid TV Shows
#   - RS-4KMedia Movies (10.0.1.203) → Unraid 4K Movies
#   - RS-4KMedia TV (10.0.1.203) → Unraid 4K TV Shows
#
# Author: Project Mother
# Last Updated: 2024-12-23
###############################################################################

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="/opt/mother/logs"
LOG_FILE="${LOG_DIR}/sync_$(date +%Y%m%d).log"

# Source paths (Chris's Synology - already mounted)
SYNOLOGY_MOVIES="/mnt/synology/rs-movies"
SYNOLOGY_TV="/mnt/synology/rs-tv"
SYNOLOGY_4K_MOVIES="/mnt/synology/rs-4kmedia/4kmovies"
SYNOLOGY_4K_TV="/mnt/synology/rs-4kmedia/4ktv"

# Destination paths (Ali's Unraid - via VPN)
# All under the /mnt/user/Media share on Unraid
UNRAID_MOVIES="/mnt/unraid/media/Movies"
UNRAID_TV="/mnt/unraid/media/TV Shows"
UNRAID_4K_MOVIES="/mnt/unraid/media/4K Movies"
UNRAID_4K_TV="/mnt/unraid/media/4K TV Shows"

# Bandwidth limit (in MB/s) - 0 means unlimited
# Set to limit bandwidth usage across VPN
BANDWIDTH_LIMIT="${BANDWIDTH_LIMIT:-0}"

# Sync options
DRY_RUN="${DRY_RUN:-false}"
VERBOSE="${VERBOSE:-false}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

###############################################################################
# Functions
###############################################################################

log() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "${timestamp} - $1" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

log_section() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}" | tee -a "$LOG_FILE"
    echo -e "${BLUE}$1${NC}" | tee -a "$LOG_FILE"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n" | tee -a "$LOG_FILE"
}

# Check if rclone is installed
check_rclone() {
    if ! command -v rclone &> /dev/null; then
        log_error "rclone is not installed. Please install it first."
        exit 1
    fi
    
    log_info "rclone version: $(rclone version | head -n 1)"
}

# Sync a single library
sync_library() {
    local source=$1
    local destination=$2
    local library_name=$3
    
    log_section "Syncing: $library_name"
    log_info "Source: $source"
    log_info "Destination: $destination"
    
    # Build rclone command
    local rclone_cmd="rclone sync"
    
    # Add options
    local rclone_opts=(
        "--progress"
        "--stats 30s"
        "--transfers 4"
        "--checkers 8"
        "--contimeout 60s"
        "--timeout 300s"
        "--retries 3"
        "--low-level-retries 10"
        "--stats-file-name-length 0"
    )
    
    # Add bandwidth limit if set
    if [ "$BANDWIDTH_LIMIT" -gt 0 ]; then
        rclone_opts+=("--bwlimit ${BANDWIDTH_LIMIT}M")
        log_info "Bandwidth limit: ${BANDWIDTH_LIMIT} MB/s"
    fi
    
    # Add verbose if enabled
    if [ "$VERBOSE" == "true" ]; then
        rclone_opts+=("-v")
    fi
    
    # Add dry-run if enabled
    if [ "$DRY_RUN" == "true" ]; then
        rclone_opts+=("--dry-run")
        log_warn "DRY RUN MODE - No files will be transferred"
    fi
    
    # Execute sync
    log_info "Starting sync..."
    local start_time=$(date +%s)
    
    $rclone_cmd "${rclone_opts[@]}" "$source" "$destination" 2>&1 | tee -a "$LOG_FILE"
    
    local exit_code=${PIPESTATUS[0]}
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [ $exit_code -eq 0 ]; then
        log_info "✅ Sync completed successfully"
        log_info "Duration: ${duration} seconds"
    else
        log_error "❌ Sync failed with exit code: $exit_code"
        return $exit_code
    fi
    
    return 0
}

# Test connectivity to all systems
test_connectivity() {
    log_section "Testing Mount Points"
    
    local all_ok=true
    
    # Test Synology mounts
    log_info "Checking Synology Movies mount..."
    if [ -d "$SYNOLOGY_MOVIES" ] && mountpoint -q "$SYNOLOGY_MOVIES"; then
        log_info "✅ Synology Movies mounted"
    else
        log_error "❌ Synology Movies NOT mounted at $SYNOLOGY_MOVIES"
        all_ok=false
    fi
    
    log_info "Checking Synology TV mount..."
    if [ -d "$SYNOLOGY_TV" ] && mountpoint -q "$SYNOLOGY_TV"; then
        log_info "✅ Synology TV mounted"
    else
        log_error "❌ Synology TV NOT mounted at $SYNOLOGY_TV"
        all_ok=false
    fi
    
    log_info "Checking Synology 4K Movies mount..."
    if [ -d "$SYNOLOGY_4K_MOVIES" ] && mountpoint -q "$SYNOLOGY_4K_MOVIES"; then
        log_info "✅ Synology 4K Movies mounted"
    else
        log_error "❌ Synology 4K Movies NOT mounted at $SYNOLOGY_4K_MOVIES"
        all_ok=false
    fi
    
    log_info "Checking Synology 4K TV mount..."
    if [ -d "$SYNOLOGY_4K_TV" ] && mountpoint -q "$SYNOLOGY_4K_TV"; then
        log_info "✅ Synology 4K TV mounted"
    else
        log_error "❌ Synology 4K TV NOT mounted at $SYNOLOGY_4K_TV"
        all_ok=false
    fi
    
    # Test Unraid mounts
    log_info "Checking Unraid Movies mount..."
    if [ -d "$UNRAID_MOVIES" ] && mountpoint -q "$UNRAID_MOVIES"; then
        log_info "✅ Unraid Movies mounted"
    else
        log_error "❌ Unraid Movies NOT mounted at $UNRAID_MOVIES"
        all_ok=false
    fi
    
    log_info "Checking Unraid TV mount..."
    if [ -d "$UNRAID_TV" ] && mountpoint -q "$UNRAID_TV"; then
        log_info "✅ Unraid TV mounted"
    else
        log_error "❌ Unraid TV NOT mounted at $UNRAID_TV"
        all_ok=false
    fi
    
    log_info "Checking Unraid 4K Movies mount..."
    if [ -d "$UNRAID_4K_MOVIES" ] && mountpoint -q "$UNRAID_4K_MOVIES"; then
        log_info "✅ Unraid 4K Movies mounted"
    else
        log_error "❌ Unraid 4K Movies NOT mounted at $UNRAID_4K_MOVIES"
        all_ok=false
    fi
    
    log_info "Checking Unraid 4K TV mount..."
    if [ -d "$UNRAID_4K_TV" ] && mountpoint -q "$UNRAID_4K_TV"; then
        log_info "✅ Unraid 4K TV mounted"
    else
        log_error "❌ Unraid 4K TV NOT mounted at $UNRAID_4K_TV"
        all_ok=false
    fi
    
    if [ "$all_ok" == "false" ]; then
        log_error "Some mounts are not available. Cannot proceed."
        log_error "Run 'sudo mount -a' to mount all filesystems."
        exit 1
    fi
}

###############################################################################
# Main Script
###############################################################################

main() {
    log_section "Mother Sync Script Started"
    log_info "Mode: $([ "$DRY_RUN" == "true" ] && echo "DRY RUN" || echo "LIVE")"
    
    # Create log directory if it doesn't exist
    mkdir -p "$LOG_DIR"
    
    # Check prerequisites
    check_rclone
    
    # Test connectivity
    test_connectivity
    
    # Sync each library
    local sync_errors=0
    
    # HD Movies (Synology → Unraid)
    if ! sync_library \
        "$SYNOLOGY_MOVIES" \
        "$UNRAID_MOVIES" \
        "HD Movies"; then
        ((sync_errors++))
    fi
    
    # HD TV Shows (Synology → Unraid)
    if ! sync_library \
        "$SYNOLOGY_TV" \
        "$UNRAID_TV" \
        "HD TV Shows"; then
        ((sync_errors++))
    fi
    
    # 4K Movies (Synology → Unraid)
    if ! sync_library \
        "$SYNOLOGY_4K_MOVIES" \
        "$UNRAID_4K_MOVIES" \
        "4K Movies"; then
        ((sync_errors++))
    fi
    
    # 4K TV Shows (Synology → Unraid)
    if ! sync_library \
        "$SYNOLOGY_4K_TV" \
        "$UNRAID_4K_TV" \
        "4K TV Shows"; then
        ((sync_errors++))
    fi
    
    # Summary
    log_section "Sync Summary"
    if [ $sync_errors -eq 0 ]; then
        log_info "✅ All libraries synced successfully"
    else
        log_error "❌ $sync_errors libraries failed to sync"
    fi
    
    log_info "Log file: $LOG_FILE"
    log_section "Mother Sync Script Completed"
    
    return $sync_errors
}

# Handle command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --bwlimit)
            BANDWIDTH_LIMIT="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --dry-run       Run without making any changes"
            echo "  --verbose, -v   Enable verbose output"
            echo "  --bwlimit N     Limit bandwidth to N MB/s"
            echo "  --help, -h      Show this help message"
            echo ""
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Run main function
main "$@"
exit $?
