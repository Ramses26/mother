#!/bin/bash
###############################################################################
# Fetch Inventories and Run Comparisons - Project Mother
#
# Run this on WSL after scans complete on Terminus and Mother.
#
# Usage:
#   ./fetch_and_compare.sh              # Fetch + Compare all
#   ./fetch_and_compare.sh --fetch      # Fetch only
#   ./fetch_and_compare.sh --compare    # Compare only (already fetched)
#   ./fetch_and_compare.sh --movies     # Movies only
#   ./fetch_and_compare.sh --tv         # TV only
#
# Last Updated: 2024-12-28
###############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
INVENTORY_DIR="$PROJECT_DIR/inventories"
REPORTS_DIR="$PROJECT_DIR/reports"

# Remote hosts (uses ~/.ssh/config)
TERMINUS_HOST="terminus"
MOTHER_HOST="mother"

# Remote inventory paths
TERMINUS_INVENTORY_DIR="~/mother/inventories"
MOTHER_INVENTORY_DIR="~/mother/inventories"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

fetch_from_terminus() {
    log_info "Fetching from Terminus..."

    if ! ssh -o ConnectTimeout=10 -o BatchMode=yes $TERMINUS_HOST "echo ok" &>/dev/null; then
        log_warn "Cannot connect to Terminus - skipping"
        return 1
    fi

    mkdir -p "$INVENTORY_DIR"

    # Fetch JSON files
    local count=$(ssh $TERMINUS_HOST "ls -1 $TERMINUS_INVENTORY_DIR/*.json 2>/dev/null | wc -l")
    if [ "$count" -gt 0 ]; then
        scp -q "$TERMINUS_HOST:$TERMINUS_INVENTORY_DIR/*.json" "$INVENTORY_DIR/"
        log_info "  Fetched $count JSON files from Terminus"
    else
        log_warn "  No JSON files on Terminus"
    fi

    # Fetch CSV files
    count=$(ssh $TERMINUS_HOST "ls -1 $TERMINUS_INVENTORY_DIR/*.csv 2>/dev/null | wc -l")
    if [ "$count" -gt 0 ]; then
        scp -q "$TERMINUS_HOST:$TERMINUS_INVENTORY_DIR/*.csv" "$INVENTORY_DIR/"
        log_info "  Fetched $count CSV files from Terminus"
    fi
}

fetch_from_mother() {
    log_info "Fetching from Mother..."

    if ! ssh -o ConnectTimeout=10 -o BatchMode=yes $MOTHER_HOST "echo ok" &>/dev/null; then
        log_warn "Cannot connect to Mother - skipping"
        return 1
    fi

    mkdir -p "$INVENTORY_DIR"

    # Fetch JSON files
    local count=$(ssh $MOTHER_HOST "ls -1 $MOTHER_INVENTORY_DIR/*.json 2>/dev/null | wc -l")
    if [ "$count" -gt 0 ]; then
        scp -q "$MOTHER_HOST:$MOTHER_INVENTORY_DIR/*.json" "$INVENTORY_DIR/"
        log_info "  Fetched $count JSON files from Mother"
    else
        log_warn "  No JSON files on Mother"
    fi

    # Fetch CSV files
    count=$(ssh $MOTHER_HOST "ls -1 $MOTHER_INVENTORY_DIR/*.csv 2>/dev/null | wc -l")
    if [ "$count" -gt 0 ]; then
        scp -q "$MOTHER_HOST:$MOTHER_INVENTORY_DIR/*.csv" "$INVENTORY_DIR/"
        log_info "  Fetched $count CSV files from Mother"
    fi
}

run_comparison() {
    local ali_file="$1"
    local chris_file="$2"
    local report_name="$3"

    if [ ! -f "$ali_file" ]; then
        log_warn "Missing: $ali_file - skipping $report_name"
        return 1
    fi

    if [ ! -f "$chris_file" ]; then
        log_warn "Missing: $chris_file - skipping $report_name"
        return 1
    fi

    local timestamp=$(date +%Y%m%d_%H%M%S)
    local output_dir="$REPORTS_DIR/${report_name}_$timestamp"

    log_info "Comparing: $report_name"
    mkdir -p "$output_dir"
    python3 "$SCRIPT_DIR/compare_libraries.py" "$ali_file" "$chris_file" -o "$output_dir"
    log_info "  Report: $output_dir/"
}

show_inventory_status() {
    echo ""
    echo -e "${CYAN}=== Local Inventory Files ===${NC}"
    echo ""
    if [ -d "$INVENTORY_DIR" ]; then
        ls -lh "$INVENTORY_DIR"/*.json 2>/dev/null || echo "No JSON files"
    else
        echo "Inventory directory doesn't exist yet"
    fi
    echo ""
}

###############################################################################
# Main
###############################################################################

main() {
    local do_fetch=true
    local do_compare=true
    local do_movies=true
    local do_tv=true
    local do_4k=true
    local do_1080p=true

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --fetch|-f)
                do_compare=false
                shift
                ;;
            --compare|-c)
                do_fetch=false
                shift
                ;;
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
                show_inventory_status
                exit 0
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Actions:"
                echo "  (default)       Fetch inventories and run comparisons"
                echo "  --fetch, -f     Fetch inventories only"
                echo "  --compare, -c   Run comparisons only (skip fetch)"
                echo "  --status, -s    Show local inventory files"
                echo ""
                echo "Filters:"
                echo "  --movies        Movies only"
                echo "  --tv            TV Shows only"
                echo "  --4k            4K libraries only"
                echo "  --1080p         1080p libraries only"
                echo ""
                echo "Examples:"
                echo "  $0                      # Full workflow"
                echo "  $0 --fetch              # Just fetch"
                echo "  $0 --compare --movies   # Compare movies only"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}FETCH AND COMPARE - Project Mother${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Fetch inventories
    if [ "$do_fetch" = true ]; then
        echo -e "${CYAN}--- Fetching Inventories ---${NC}"
        echo ""
        fetch_from_terminus || true
        fetch_from_mother || true
        echo ""
    fi

    # Run comparisons
    if [ "$do_compare" = true ]; then
        echo -e "${CYAN}--- Running Comparisons ---${NC}"
        echo ""
        mkdir -p "$REPORTS_DIR"

        if [ "$do_movies" = true ]; then
            [ "$do_1080p" = true ] && run_comparison \
                "$INVENTORY_DIR/ali_movies_1080p.json" \
                "$INVENTORY_DIR/chris_movies_1080p.json" \
                "movies_1080p" || true

            [ "$do_4k" = true ] && run_comparison \
                "$INVENTORY_DIR/ali_movies_4k.json" \
                "$INVENTORY_DIR/chris_movies_4k.json" \
                "movies_4k" || true
        fi

        if [ "$do_tv" = true ]; then
            [ "$do_1080p" = true ] && run_comparison \
                "$INVENTORY_DIR/ali_tv_1080p.json" \
                "$INVENTORY_DIR/chris_tv_1080p.json" \
                "tv_1080p" || true

            [ "$do_4k" = true ] && run_comparison \
                "$INVENTORY_DIR/ali_tv_4k.json" \
                "$INVENTORY_DIR/chris_tv_4k.json" \
                "tv_4k" || true
        fi
        echo ""
    fi

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Inventories: $INVENTORY_DIR/"
    echo "Reports:     $REPORTS_DIR/"
    echo ""
}

main "$@"
