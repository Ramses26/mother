#!/bin/bash
###############################################################################
# Local Library Scanner - Project Mother
#
# Run this script directly on each server to scan local libraries.
# Uses screen sessions so you can detach and let it run.
#
# On Terminus (Unraid via NFS):
#   ./scan_local.sh                    # Scan all Ali libraries
#   ./scan_local.sh --movies           # Movies only
#   ./scan_local.sh --tv               # TV only
#
# On Mother (Synology mounts):
#   ./scan_local.sh                    # Scan all Chris libraries
#   ./scan_local.sh --movies           # Movies only
#   ./scan_local.sh --tv               # TV only
#
# Last Updated: 2024-12-28
###############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INVENTORY_DIR="$SCRIPT_DIR/../inventories"

# Detect which server we're on
HOSTNAME=$(hostname)

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Configure paths based on hostname
configure_paths() {
    case "$HOSTNAME" in
        terminus|terminus.*)
            OWNER="ali"
            MOVIES_1080P="/mnt/media/Movies"
            MOVIES_4K="/mnt/media/4K Movies"
            TV_1080P="/mnt/media/TV Shows"
            TV_4K="/mnt/media/4K TV Shows"
            log_info "Detected: Terminus (scanning Unraid/Ali libraries)"
            ;;
        mother|mother.*)
            OWNER="chris"
            MOVIES_1080P="/mnt/synology/rs-movies"
            MOVIES_4K="/mnt/synology/rs-4kmedia/4kmovies"
            TV_1080P="/mnt/synology/rs-tv"
            TV_4K="/mnt/synology/rs-4kmedia/4ktv"
            log_info "Detected: Mother (scanning Synology/Chris libraries)"
            ;;
        *)
            log_error "Unknown hostname: $HOSTNAME"
            log_error "This script should run on 'terminus' or 'mother'"
            echo ""
            echo "You can override by setting environment variables:"
            echo "  OWNER=ali MOVIES_1080P=/path/to/movies ./scan_local.sh"
            exit 1
            ;;
    esac
}

scan_library() {
    local path="$1"
    local output_name="$2"
    local screen_name="scan_${output_name}"

    if [ ! -d "$path" ]; then
        log_warn "Path not found: $path - skipping"
        return 0
    fi

    # Check if already running
    if screen -ls 2>/dev/null | grep -q "$screen_name"; then
        log_warn "Screen '$screen_name' already running - skipping"
        return 0
    fi

    log_info "Starting scan: $output_name"
    log_info "  Path: $path"
    log_info "  Screen: $screen_name"

    screen -dmS "$screen_name" bash -c "
        cd '$SCRIPT_DIR'
        echo '============================================'
        echo 'Scan: $output_name'
        echo 'Path: $path'
        echo 'Started: \$(date)'
        echo '============================================'
        echo ''
        python3 generate_inventory.py '$path' -o '$INVENTORY_DIR/$output_name'
        echo ''
        echo '============================================'
        echo 'Completed: \$(date)'
        echo '============================================'
        echo 'Press Enter to close this screen...'
        read
    "

    log_info "  Started in screen"
}

show_status() {
    echo ""
    echo -e "${CYAN}=== Screen Sessions ===${NC}"
    echo ""
    screen -ls 2>/dev/null | grep -E "scan_" || echo "No scan screens running"
    echo ""
    echo "To attach: screen -r <session_name>"
    echo "To detach: Ctrl+A, then D"
    echo ""

    echo -e "${CYAN}=== Inventory Files ===${NC}"
    echo ""
    if [ -d "$INVENTORY_DIR" ]; then
        ls -lh "$INVENTORY_DIR"/*.json 2>/dev/null || echo "No inventory files yet"
    else
        echo "Inventory directory not created yet"
    fi
    echo ""
}

###############################################################################
# Main
###############################################################################

main() {
    local do_movies=true
    local do_tv=true
    local do_4k=true
    local do_1080p=true
    local status_only=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --movies)
                do_tv=false
                shift
                ;;
            --tv)
                do_movies=false
                shift
                ;;
            --4k)
                do_1080p=false
                shift
                ;;
            --1080p)
                do_4k=false
                shift
                ;;
            --status|-s)
                status_only=true
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --movies        Scan movies only"
                echo "  --tv            Scan TV shows only"
                echo "  --4k            Scan 4K libraries only"
                echo "  --1080p         Scan 1080p libraries only"
                echo "  --status, -s    Show running scans and inventory files"
                echo "  -h, --help      Show this help"
                echo ""
                echo "Examples:"
                echo "  $0                # Scan everything"
                echo "  $0 --movies       # Movies only (1080p + 4K)"
                echo "  $0 --tv --1080p   # 1080p TV only"
                echo "  $0 --status       # Check progress"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    configure_paths

    if [ "$status_only" = true ]; then
        show_status
        exit 0
    fi

    mkdir -p "$INVENTORY_DIR"

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}LOCAL LIBRARY SCAN - $HOSTNAME${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Owner: $OWNER"
    echo "Output: $INVENTORY_DIR/"
    echo ""

    # Start scans
    if [ "$do_movies" = true ]; then
        [ "$do_1080p" = true ] && scan_library "$MOVIES_1080P" "${OWNER}_movies_1080p"
        [ "$do_4k" = true ] && scan_library "$MOVIES_4K" "${OWNER}_movies_4k"
    fi

    if [ "$do_tv" = true ]; then
        [ "$do_1080p" = true ] && scan_library "$TV_1080P" "${OWNER}_tv_1080p"
        [ "$do_4k" = true ] && scan_library "$TV_4K" "${OWNER}_tv_4k"
    fi

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Scans running in background screens."
    echo ""
    echo "Commands:"
    echo "  $0 --status              # Check progress"
    echo "  screen -r scan_${OWNER}_movies_1080p  # Attach to a scan"
    echo ""
    echo "When complete, inventories will be in:"
    echo "  $INVENTORY_DIR/"
    echo ""
}

main "$@"
