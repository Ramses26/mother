#!/bin/bash
###############################################################################
# Distributed Library Analysis - Project Mother
#
# Runs inventory generation in parallel using screen sessions:
# - Synology scans run on Mother (local to Synology)
# - Unraid scans run on Terminus (local NFS mount to Unraid)
# - Comparison runs on WSL after both complete
#
# Usage:
#   ./analyze_distributed.sh                    # Full analysis (Movies + TV)
#   ./analyze_distributed.sh --movies           # Movies only
#   ./analyze_distributed.sh --tv               # TV Shows only
#   ./analyze_distributed.sh --4k               # 4K only
#   ./analyze_distributed.sh --1080p            # 1080p only
#   ./analyze_distributed.sh --status           # Check screen status
#   ./analyze_distributed.sh --fetch            # Fetch inventories from Terminus
#   ./analyze_distributed.sh --compare          # Run comparisons (after fetch)
#
# Last Updated: 2024-12-28
###############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
INVENTORY_DIR="$PROJECT_DIR/inventories"
REPORTS_DIR="$PROJECT_DIR/reports"

# Remote settings
TERMINUS_HOST="terminus"  # Uses SSH config (192.168.1.14)

# Unraid paths on Terminus (via NFS mount at /mnt/media)
TERMINUS_MOVIES_1080P="/mnt/media/Movies"
TERMINUS_MOVIES_4K="/mnt/media/4K Movies"
TERMINUS_TV_1080P="/mnt/media/TV Shows"
TERMINUS_TV_4K="/mnt/media/4K TV Shows"

# Synology paths on Mother (via NFS/SMB mounts)
# These would be scanned from Mother server, not WSL
MOTHER_HOST="mother"  # Uses SSH config (10.0.0.162)
MOTHER_MOVIES_1080P="/mnt/synology/rs-movies"
MOTHER_MOVIES_4K="/mnt/synology/rs-4kmedia/4kmovies"
MOTHER_TV_1080P="/mnt/synology/rs-tv"
MOTHER_TV_4K="/mnt/synology/rs-4kmedia/4ktv"

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
    echo "Local (WSL):"
    screen -ls 2>/dev/null | grep -E "scan_" || echo "  No scan screens running locally"
    echo ""
    echo "Terminus (192.168.1.14):"
    ssh -o ConnectTimeout=5 $TERMINUS_HOST "screen -ls 2>/dev/null | grep -E 'scan_'" 2>/dev/null || echo "  No scan screens running on Terminus"
    echo ""
    echo "Mother (10.0.0.162):"
    ssh -o ConnectTimeout=5 $MOTHER_HOST "screen -ls 2>/dev/null | grep -E 'scan_'" 2>/dev/null || echo "  No scan screens running on Mother (or SSH failed)"
    echo ""
}

start_terminus_scan() {
    local library_path="$1"
    local output_name="$2"
    local screen_name="scan_${output_name}"

    log_info "Starting Terminus scan: $output_name"
    log_info "  Path: $library_path"
    log_info "  Screen: $screen_name"

    # Copy generate_inventory.py to Terminus if needed
    ssh $TERMINUS_HOST "mkdir -p ~/mother/scripts ~/mother/inventories" 2>/dev/null
    scp -q "$SCRIPT_DIR/generate_inventory.py" "$TERMINUS_HOST:~/mother/scripts/"

    # Start remote screen session
    ssh $TERMINUS_HOST "screen -dmS '$screen_name' bash -c '
        cd ~/mother/scripts
        echo \"=== Starting scan: $output_name ===\"
        echo \"Path: $library_path\"
        echo \"Time: \$(date)\"
        echo \"\"
        python3 generate_inventory.py \"$library_path\" -o ~/mother/inventories/$output_name
        echo \"\"
        echo \"=== Scan complete: $output_name ===\"
        echo \"Time: \$(date)\"
        sleep 10
    '"

    log_info "  Started on Terminus"
}

start_mother_scan() {
    local library_path="$1"
    local output_name="$2"
    local screen_name="scan_${output_name}"

    log_info "Starting Mother scan: $output_name"
    log_info "  Path: $library_path"
    log_info "  Screen: $screen_name"

    # Check if Mother is reachable
    if ! ssh -o ConnectTimeout=5 $MOTHER_HOST "echo ok" &>/dev/null; then
        log_warn "Mother not reachable via SSH - skipping $output_name"
        return 1
    fi

    # Copy generate_inventory.py to Mother if needed
    ssh $MOTHER_HOST "mkdir -p ~/mother/scripts ~/mother/inventories" 2>/dev/null
    scp -q "$SCRIPT_DIR/generate_inventory.py" "$MOTHER_HOST:~/mother/scripts/"

    # Start remote screen session
    ssh $MOTHER_HOST "screen -dmS '$screen_name' bash -c '
        cd ~/mother/scripts
        echo \"=== Starting scan: $output_name ===\"
        echo \"Path: $library_path\"
        echo \"Time: \$(date)\"
        echo \"\"
        python3 generate_inventory.py \"$library_path\" -o ~/mother/inventories/$output_name
        echo \"\"
        echo \"=== Scan complete: $output_name ===\"
        echo \"Time: \$(date)\"
        sleep 10
    '"

    log_info "  Started on Mother"
}

fetch_inventories() {
    log_section "Fetching Inventories"

    mkdir -p "$INVENTORY_DIR"

    # Fetch from Terminus
    log_info "Fetching from Terminus..."
    scp -q "$TERMINUS_HOST:~/mother/inventories/*.json" "$INVENTORY_DIR/" 2>/dev/null && \
        log_info "  JSON files fetched" || log_warn "  No JSON files on Terminus"
    scp -q "$TERMINUS_HOST:~/mother/inventories/*.csv" "$INVENTORY_DIR/" 2>/dev/null && \
        log_info "  CSV files fetched" || log_warn "  No CSV files on Terminus"

    # Fetch from Mother
    log_info "Fetching from Mother..."
    if ssh -o ConnectTimeout=5 $MOTHER_HOST "echo ok" &>/dev/null; then
        scp -q "$MOTHER_HOST:~/mother/inventories/*.json" "$INVENTORY_DIR/" 2>/dev/null && \
            log_info "  JSON files fetched" || log_warn "  No JSON files on Mother"
        scp -q "$MOTHER_HOST:~/mother/inventories/*.csv" "$INVENTORY_DIR/" 2>/dev/null && \
            log_info "  CSV files fetched" || log_warn "  No CSV files on Mother"
    else
        log_warn "Mother not reachable - skipping"
    fi

    echo ""
    log_info "Inventories in: $INVENTORY_DIR/"
    ls -la "$INVENTORY_DIR/"*.json 2>/dev/null | tail -10 || echo "  No JSON files found"
}

run_comparisons() {
    local do_movies="$1"
    local do_tv="$2"
    local do_4k="$3"
    local do_1080p="$4"

    log_section "Running Comparisons"

    mkdir -p "$REPORTS_DIR"
    local timestamp=$(date +%Y%m%d_%H%M%S)

    # Movies 1080p
    if [ "$do_movies" = true ] && [ "$do_1080p" = true ]; then
        if [ -f "$INVENTORY_DIR/ali_movies_1080p.json" ] && [ -f "$INVENTORY_DIR/chris_movies_1080p.json" ]; then
            log_info "Comparing: Movies 1080p"
            python3 "$SCRIPT_DIR/compare_libraries.py" \
                "$INVENTORY_DIR/ali_movies_1080p.json" \
                "$INVENTORY_DIR/chris_movies_1080p.json" \
                -o "$REPORTS_DIR/movies_1080p_$timestamp"
        else
            log_warn "Missing inventories for Movies 1080p comparison"
        fi
    fi

    # Movies 4K
    if [ "$do_movies" = true ] && [ "$do_4k" = true ]; then
        if [ -f "$INVENTORY_DIR/ali_movies_4k.json" ] && [ -f "$INVENTORY_DIR/chris_movies_4k.json" ]; then
            log_info "Comparing: Movies 4K"
            python3 "$SCRIPT_DIR/compare_libraries.py" \
                "$INVENTORY_DIR/ali_movies_4k.json" \
                "$INVENTORY_DIR/chris_movies_4k.json" \
                -o "$REPORTS_DIR/movies_4k_$timestamp"
        else
            log_warn "Missing inventories for Movies 4K comparison"
        fi
    fi

    # TV Shows 1080p
    if [ "$do_tv" = true ] && [ "$do_1080p" = true ]; then
        if [ -f "$INVENTORY_DIR/ali_tv_1080p.json" ] && [ -f "$INVENTORY_DIR/chris_tv_1080p.json" ]; then
            log_info "Comparing: TV Shows 1080p"
            python3 "$SCRIPT_DIR/compare_libraries.py" \
                "$INVENTORY_DIR/ali_tv_1080p.json" \
                "$INVENTORY_DIR/chris_tv_1080p.json" \
                -o "$REPORTS_DIR/tv_1080p_$timestamp"
        else
            log_warn "Missing inventories for TV Shows 1080p comparison"
        fi
    fi

    # TV Shows 4K
    if [ "$do_tv" = true ] && [ "$do_4k" = true ]; then
        if [ -f "$INVENTORY_DIR/ali_tv_4k.json" ] && [ -f "$INVENTORY_DIR/chris_tv_4k.json" ]; then
            log_info "Comparing: TV Shows 4K"
            python3 "$SCRIPT_DIR/compare_libraries.py" \
                "$INVENTORY_DIR/ali_tv_4k.json" \
                "$INVENTORY_DIR/chris_tv_4k.json" \
                -o "$REPORTS_DIR/tv_4k_$timestamp"
        else
            log_warn "Missing inventories for TV Shows 4K comparison"
        fi
    fi

    echo ""
    log_info "Reports in: $REPORTS_DIR/"
    ls -ltd "$REPORTS_DIR"/*/ 2>/dev/null | head -5 || echo "  No report directories found"
}

###############################################################################
# Main
###############################################################################

main() {
    local do_movies=true
    local do_tv=true
    local do_4k=true
    local do_1080p=true
    local action="scan"  # scan, status, fetch, compare

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
                action="status"
                shift
                ;;
            --fetch|-f)
                action="fetch"
                shift
                ;;
            --compare|-c)
                action="compare"
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Actions:"
                echo "  (default)       Start scans on remote servers"
                echo "  --status, -s    Check screen session status"
                echo "  --fetch, -f     Fetch inventories from remote servers"
                echo "  --compare, -c   Run comparisons on fetched inventories"
                echo ""
                echo "Filters:"
                echo "  --movies        Movies only"
                echo "  --tv            TV Shows only"
                echo "  --4k            4K libraries only"
                echo "  --1080p         1080p libraries only"
                echo ""
                echo "Examples:"
                echo "  $0                      # Start all scans"
                echo "  $0 --movies --4k        # Scan 4K movies only"
                echo "  $0 --status             # Check progress"
                echo "  $0 --fetch              # Fetch completed inventories"
                echo "  $0 --compare            # Run comparisons"
                echo ""
                echo "Workflow:"
                echo "  1. $0                   # Start scans (runs in background)"
                echo "  2. $0 --status          # Monitor progress"
                echo "  3. $0 --fetch           # Fetch when done"
                echo "  4. $0 --compare         # Generate reports"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    case "$action" in
        status)
            check_screen_status
            exit 0
            ;;
        fetch)
            fetch_inventories
            exit 0
            ;;
        compare)
            run_comparisons "$do_movies" "$do_tv" "$do_4k" "$do_1080p"
            exit 0
            ;;
    esac

    # Default action: start scans
    log_section "DISTRIBUTED LIBRARY ANALYSIS"
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo "Architecture:"
    echo "  Unraid (Ali)    -> Terminus scans locally via NFS"
    echo "  Synology (Chris) -> Mother scans locally"
    echo ""
    echo "Scope:"
    echo "  Movies: $([ "$do_movies" = true ] && echo "YES" || echo "NO")"
    echo "  TV Shows: $([ "$do_tv" = true ] && echo "YES" || echo "NO")"
    echo "  4K: $([ "$do_4k" = true ] && echo "YES" || echo "NO")"
    echo "  1080p: $([ "$do_1080p" = true ] && echo "YES" || echo "NO")"
    echo ""

    # Start Terminus scans (Unraid/Ali)
    log_section "Starting Terminus Scans (Unraid)"

    if [ "$do_movies" = true ]; then
        [ "$do_1080p" = true ] && start_terminus_scan "$TERMINUS_MOVIES_1080P" "ali_movies_1080p"
        [ "$do_4k" = true ] && start_terminus_scan "$TERMINUS_MOVIES_4K" "ali_movies_4k"
    fi

    if [ "$do_tv" = true ]; then
        [ "$do_1080p" = true ] && start_terminus_scan "$TERMINUS_TV_1080P" "ali_tv_1080p"
        [ "$do_4k" = true ] && start_terminus_scan "$TERMINUS_TV_4K" "ali_tv_4k"
    fi

    # Start Mother scans (Synology/Chris)
    log_section "Starting Mother Scans (Synology)"

    if [ "$do_movies" = true ]; then
        [ "$do_1080p" = true ] && start_mother_scan "$MOTHER_MOVIES_1080P" "chris_movies_1080p"
        [ "$do_4k" = true ] && start_mother_scan "$MOTHER_MOVIES_4K" "chris_movies_4k"
    fi

    if [ "$do_tv" = true ]; then
        [ "$do_1080p" = true ] && start_mother_scan "$MOTHER_TV_1080P" "chris_tv_1080p"
        [ "$do_4k" = true ] && start_mother_scan "$MOTHER_TV_4K" "chris_tv_4k"
    fi

    log_section "Scans Running in Background"
    echo ""
    echo "Monitor progress:"
    echo "  $0 --status"
    echo ""
    echo "Attach to screen:"
    echo "  Terminus: ssh terminus 'screen -r scan_ali_movies_1080p'"
    echo "  Mother:   ssh mother 'screen -r scan_chris_movies_1080p'"
    echo ""
    echo "When complete:"
    echo "  $0 --fetch     # Fetch inventories"
    echo "  $0 --compare   # Generate reports"
    echo ""
}

main "$@"
