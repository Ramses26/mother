#!/bin/bash
###############################################################################
# Compare Only - Project Mother
#
# Runs comparisons on inventory files already in ./inventories/
# Copy inventory files there manually before running this.
#
# Usage:
#   ./compare_only.sh              # Compare all (movies + TV, 1080p + 4K)
#   ./compare_only.sh --movies     # Movies only
#   ./compare_only.sh --tv         # TV only
#   ./compare_only.sh --status     # Show inventory files
#
# Last Updated: 2024-12-29
###############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
INVENTORY_DIR="$PROJECT_DIR/inventories"
REPORTS_DIR="$PROJECT_DIR/reports"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

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
    log_info "  Ali:   $ali_file"
    log_info "  Chris: $chris_file"
    mkdir -p "$output_dir"
    python3 "$SCRIPT_DIR/compare_libraries.py" "$ali_file" "$chris_file" -o "$output_dir"
    log_info "  Report: $output_dir/"
    echo ""
}

show_status() {
    echo ""
    echo -e "${CYAN}=== Inventory Files ===${NC}"
    echo ""
    echo "Expected files in: $INVENTORY_DIR/"
    echo ""
    echo "Ali (Unraid):"
    for f in ali_movies_1080p ali_movies_4k ali_tv_1080p ali_tv_4k; do
        if [ -f "$INVENTORY_DIR/${f}.json" ]; then
            echo -e "  ${GREEN}✓${NC} ${f}.json"
        else
            echo -e "  ${RED}✗${NC} ${f}.json (missing)"
        fi
    done
    echo ""
    echo "Chris (Synology):"
    for f in chris_movies_1080p chris_movies_4k chris_tv_1080p chris_tv_4k; do
        if [ -f "$INVENTORY_DIR/${f}.json" ]; then
            echo -e "  ${GREEN}✓${NC} ${f}.json"
        else
            echo -e "  ${RED}✗${NC} ${f}.json (missing)"
        fi
    done
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
                show_status
                exit 0
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --movies        Movies only"
                echo "  --tv            TV Shows only"
                echo "  --4k            4K libraries only"
                echo "  --1080p         1080p libraries only"
                echo "  --status, -s    Show inventory files"
                echo "  -h, --help      Show this help"
                echo ""
                echo "Before running, copy inventory files to:"
                echo "  $INVENTORY_DIR/"
                echo ""
                echo "Expected files:"
                echo "  ali_movies_1080p.json, ali_movies_4k.json"
                echo "  ali_tv_1080p.json, ali_tv_4k.json"
                echo "  chris_movies_1080p.json, chris_movies_4k.json"
                echo "  chris_tv_1080p.json, chris_tv_4k.json"
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
    echo -e "${CYAN}COMPARE LIBRARIES - Project Mother${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Check inventory directory
    if [ ! -d "$INVENTORY_DIR" ]; then
        log_error "Inventory directory not found: $INVENTORY_DIR"
        log_error "Create it and copy inventory files there first."
        exit 1
    fi

    mkdir -p "$REPORTS_DIR"

    # Run comparisons
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

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "Reports saved to: $REPORTS_DIR/"
    ls -ltd "$REPORTS_DIR"/*/ 2>/dev/null | head -5
    echo ""
}

main "$@"
