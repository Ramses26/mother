#!/bin/bash
###############################################################################
# Distributed Movie Analysis - Project Mother
#
# Runs inventory generation in parallel using screen sessions:
# - Synology scans run on Mother (local)
# - Unraid scans run on Terminus (local to Unraid)
# - Comparison runs on Mother after both complete
#
# Usage:
#   ./analyze_movies_distributed.sh              # Full analysis
#   ./analyze_movies_distributed.sh --4k         # 4K only
#   ./analyze_movies_distributed.sh --1080p      # 1080p only
#   ./analyze_movies_distributed.sh --status     # Check screen status
#
# Last Updated: 2024-12-28
###############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
INVENTORY_DIR="$PROJECT_DIR/inventories"
REPORTS_DIR="$PROJECT_DIR/reports"

# Remote settings
TERMINUS_HOST="terminus"  # Uses SSH config
TERMINUS_USER="alig"
MOTHER_INVENTORY_DIR="/opt/mother/inventories"

# Synology paths (Mother local)
SYNOLOGY_MOVIES_1080P="/mnt/synology/rs-movies"
SYNOLOGY_MOVIES_4K="/mnt/synology/rs-4kmedia/4kmovies"

# Unraid paths (Terminus local)
UNRAID_MOVIES_1080P="/mnt/user/Media/Movies"
UNRAID_MOVIES_4K="/mnt/user/Media/4K Movies"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

log_section() {
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

check_screen_status() {
    echo ""
    echo "=== Screen Sessions ==="
    echo ""
    echo "Local (Mother):"
    screen -ls 2>/dev/null | grep -E "mother_" || echo "  No mother screens running"
    echo ""
    echo "Remote (Terminus):"
    ssh $TERMINUS_HOST "screen -ls 2>/dev/null | grep -E 'terminus_'" 2>/dev/null || echo "  No terminus screens running (or SSH failed)"
    echo ""
}

wait_for_screens() {
    local screens=("$@")
    log_info "Waiting for screen sessions to complete..."

    while true; do
        local all_done=true
        for screen_name in "${screens[@]}"; do
            if screen -ls 2>/dev/null | grep -q "$screen_name"; then
                all_done=false
                break
            fi
        done

        if [ "$all_done" = true ]; then
            break
        fi

        echo -n "."
        sleep 10
    done
    echo ""
    log_info "All local screens completed!"
}

start_mother_scan() {
    local library_path="$1"
    local output_name="$2"
    local screen_name="mother_${output_name}"

    log_info "Starting Mother scan: $output_name"
    log_info "  Path: $library_path"
    log_info "  Screen: $screen_name"

    # Create screen session
    screen -dmS "$screen_name" bash -c "
        cd $PROJECT_DIR
        python3 scripts/generate_inventory.py '$library_path' -o '$INVENTORY_DIR/$output_name'
        echo 'Scan complete: $output_name'
        sleep 5
    "
}

start_terminus_scan() {
    local library_path="$1"
    local output_name="$2"
    local screen_name="terminus_${output_name}"

    log_info "Starting Terminus scan: $output_name"
    log_info "  Path: $library_path"
    log_info "  Screen: $screen_name"

    # Copy generate_inventory.py to Terminus if needed
    ssh $TERMINUS_HOST "mkdir -p ~/mother_scripts ~/mother_inventories" 2>/dev/null
    scp -q "$SCRIPT_DIR/generate_inventory.py" "$TERMINUS_HOST:~/mother_scripts/"

    # Start remote screen session
    ssh $TERMINUS_HOST "screen -dmS '$screen_name' bash -c '
        cd ~/mother_scripts
        python3 generate_inventory.py \"$library_path\" -o ~/mother_inventories/$output_name
        echo \"Scan complete: $output_name\"
        sleep 5
    '"
}

fetch_terminus_inventories() {
    log_info "Fetching inventories from Terminus..."

    mkdir -p "$INVENTORY_DIR"

    # Copy all inventory files from Terminus
    scp -q "$TERMINUS_HOST:~/mother_inventories/*.json" "$INVENTORY_DIR/" 2>/dev/null || log_warn "No JSON files to fetch"
    scp -q "$TERMINUS_HOST:~/mother_inventories/*.csv" "$INVENTORY_DIR/" 2>/dev/null || log_warn "No CSV files to fetch"

    log_info "Inventories fetched to: $INVENTORY_DIR/"
}

run_comparison() {
    local ali_inventory="$1"
    local chris_inventory="$2"
    local output_name="$3"

    local timestamp=$(date +%Y%m%d_%H%M%S)
    local output_dir="$REPORTS_DIR/${output_name}_$timestamp"

    mkdir -p "$output_dir"

    log_info "Running comparison: $output_name"
    python3 "$SCRIPT_DIR/compare_libraries.py" "$ali_inventory" "$chris_inventory" -o "$output_dir"
}

###############################################################################
# Main
###############################################################################

main() {
    local do_4k=true
    local do_1080p=true
    local status_only=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --4k)
                do_1080p=false
                shift
                ;;
            --1080p)
                do_4k=false
                shift
                ;;
            --status)
                status_only=true
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --4k       Analyze 4K movies only"
                echo "  --1080p    Analyze 1080p movies only"
                echo "  --status   Check screen session status"
                echo "  -h, --help Show this help"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    if [ "$status_only" = true ]; then
        check_screen_status
        exit 0
    fi

    log_section "DISTRIBUTED MOVIE ANALYSIS"
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo "Scan locations:"
    echo "  Synology (Chris) → Mother (local)"
    echo "  Unraid (Ali) → Terminus (local)"
    echo ""

    mkdir -p "$INVENTORY_DIR"
    mkdir -p "$REPORTS_DIR"

    # Start all scans in parallel using screen
    log_section "Starting Inventory Scans"

    local mother_screens=()
    local terminus_screens=()

    if [ "$do_1080p" = true ]; then
        # Synology 1080p on Mother
        if [ -d "$SYNOLOGY_MOVIES_1080P" ]; then
            start_mother_scan "$SYNOLOGY_MOVIES_1080P" "chris_movies_1080p"
            mother_screens+=("mother_chris_movies_1080p")
        fi

        # Unraid 1080p on Terminus
        start_terminus_scan "$UNRAID_MOVIES_1080P" "ali_movies_1080p"
        terminus_screens+=("terminus_ali_movies_1080p")
    fi

    if [ "$do_4k" = true ]; then
        # Synology 4K on Mother
        if [ -d "$SYNOLOGY_MOVIES_4K" ]; then
            start_mother_scan "$SYNOLOGY_MOVIES_4K" "chris_movies_4k"
            mother_screens+=("mother_chris_movies_4k")
        fi

        # Unraid 4K on Terminus
        start_terminus_scan "$UNRAID_MOVIES_4K" "ali_movies_4k"
        terminus_screens+=("terminus_ali_movies_4k")
    fi

    log_section "Scans Running in Background"
    echo ""
    echo "Monitor progress:"
    echo "  Local:  screen -r mother_chris_movies_1080p"
    echo "  Remote: ssh terminus 'screen -r terminus_ali_movies_1080p'"
    echo ""
    echo "Check status: $0 --status"
    echo ""
    echo "When complete, run:"
    echo "  $0 --fetch-and-compare"
    echo ""
}

main "$@"
