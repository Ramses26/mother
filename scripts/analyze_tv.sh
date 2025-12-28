#!/bin/bash
###############################################################################
# TV Shows Library Analysis Workflow - Project Mother
#
# Purpose: Generate inventories and run comparisons for TV show libraries
#
# Usage:
#   ./analyze_tv.sh                    # Run full analysis
#   ./analyze_tv.sh --inventory-only   # Just generate inventories
#   ./analyze_tv.sh --compare-only     # Just run comparison (uses existing inventories)
#   ./analyze_tv.sh --4k               # Analyze 4K TV shows only
#   ./analyze_tv.sh --1080p            # Analyze 1080p TV shows only
#
# Last Updated: 2024-12-28
###############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
INVENTORY_DIR="$PROJECT_DIR/inventories"
REPORTS_DIR="$PROJECT_DIR/reports"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Library paths (from Mother server)
SYNOLOGY_TV_1080P="/mnt/synology/rs-tv"
SYNOLOGY_TV_4K="/mnt/synology/rs-4kmedia/4ktv"
UNRAID_TV_1080P="/mnt/unraid/media/TV Shows"
UNRAID_TV_4K="/mnt/unraid/media/4K TV Shows"

###############################################################################
# Functions
###############################################################################

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_section() {
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

check_path() {
    local path="$1"
    local name="$2"
    if [ -d "$path" ]; then
        log_info "✅ $name accessible: $path"
        return 0
    else
        log_warn "❌ $name not accessible: $path"
        return 1
    fi
}

generate_inventory() {
    local path="$1"
    local output_name="$2"
    local output_path="$INVENTORY_DIR/$output_name"

    log_info "Generating inventory for: $path"
    log_info "Output: $output_path"

    python3 "$SCRIPT_DIR/generate_inventory.py" "$path" -o "$output_path"

    if [ -f "${output_path}.json" ]; then
        local count=$(python3 -c "import json; print(len(json.load(open('${output_path}.json'))))")
        log_info "✅ Generated inventory with $count files"
    else
        log_error "Failed to generate inventory"
        return 1
    fi
}

run_comparison() {
    local ali_inventory="$1"
    local chris_inventory="$2"
    local output_dir="$3"

    log_info "Comparing: $ali_inventory vs $chris_inventory"
    log_info "Output directory: $output_dir"

    python3 "$SCRIPT_DIR/compare_libraries.py" "$ali_inventory" "$chris_inventory" -o "$output_dir"
}

###############################################################################
# Main
###############################################################################

main() {
    local do_inventory=true
    local do_compare=true
    local do_4k=true
    local do_1080p=true

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --inventory-only)
                do_compare=false
                shift
                ;;
            --compare-only)
                do_inventory=false
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
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --inventory-only   Only generate inventories"
                echo "  --compare-only     Only run comparisons (uses existing inventories)"
                echo "  --4k               Analyze 4K TV shows only"
                echo "  --1080p            Analyze 1080p TV shows only"
                echo "  -h, --help         Show this help"
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                exit 1
                ;;
        esac
    done

    log_section "PROJECT MOTHER - TV SHOWS LIBRARY ANALYSIS"
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""

    # Create directories
    mkdir -p "$INVENTORY_DIR"
    mkdir -p "$REPORTS_DIR"

    # Check paths
    log_section "Checking Library Access"
    local synology_1080p_ok=false
    local synology_4k_ok=false
    local unraid_1080p_ok=false
    local unraid_4k_ok=false

    check_path "$SYNOLOGY_TV_1080P" "Synology TV Shows (1080p)" && synology_1080p_ok=true
    check_path "$SYNOLOGY_TV_4K" "Synology 4K TV Shows" && synology_4k_ok=true
    check_path "$UNRAID_TV_1080P" "Unraid TV Shows (1080p)" && unraid_1080p_ok=true
    check_path "$UNRAID_TV_4K" "Unraid 4K TV Shows" && unraid_4k_ok=true

    # Generate inventories
    if [ "$do_inventory" = true ]; then
        log_section "Generating Inventories"

        if [ "$do_1080p" = true ]; then
            if [ "$synology_1080p_ok" = true ]; then
                generate_inventory "$SYNOLOGY_TV_1080P" "chris_tv_1080p"
            fi
            if [ "$unraid_1080p_ok" = true ]; then
                generate_inventory "$UNRAID_TV_1080P" "ali_tv_1080p"
            fi
        fi

        if [ "$do_4k" = true ]; then
            if [ "$synology_4k_ok" = true ]; then
                generate_inventory "$SYNOLOGY_TV_4K" "chris_tv_4k"
            fi
            if [ "$unraid_4k_ok" = true ]; then
                generate_inventory "$UNRAID_TV_4K" "ali_tv_4k"
            fi
        fi
    fi

    # Run comparisons
    if [ "$do_compare" = true ]; then
        log_section "Running Comparisons"

        local timestamp=$(date +%Y%m%d_%H%M%S)

        if [ "$do_1080p" = true ]; then
            local ali_1080p="$INVENTORY_DIR/ali_tv_1080p.json"
            local chris_1080p="$INVENTORY_DIR/chris_tv_1080p.json"

            if [ -f "$ali_1080p" ] && [ -f "$chris_1080p" ]; then
                log_info "Comparing 1080p TV shows..."
                local output_dir="$REPORTS_DIR/tv_1080p_$timestamp"
                mkdir -p "$output_dir"
                run_comparison "$ali_1080p" "$chris_1080p" "$output_dir"
            else
                log_warn "Missing inventory files for 1080p comparison"
                [ ! -f "$ali_1080p" ] && log_warn "  Missing: $ali_1080p"
                [ ! -f "$chris_1080p" ] && log_warn "  Missing: $chris_1080p"
            fi
        fi

        if [ "$do_4k" = true ]; then
            local ali_4k="$INVENTORY_DIR/ali_tv_4k.json"
            local chris_4k="$INVENTORY_DIR/chris_tv_4k.json"

            if [ -f "$ali_4k" ] && [ -f "$chris_4k" ]; then
                log_info "Comparing 4K TV shows..."
                local output_dir="$REPORTS_DIR/tv_4k_$timestamp"
                mkdir -p "$output_dir"
                run_comparison "$ali_4k" "$chris_4k" "$output_dir"
            else
                log_warn "Missing inventory files for 4K comparison"
                [ ! -f "$ali_4k" ] && log_warn "  Missing: $ali_4k"
                [ ! -f "$chris_4k" ] && log_warn "  Missing: $chris_4k"
            fi
        fi
    fi

    log_section "ANALYSIS COMPLETE"
    echo ""
    echo "Inventories saved to: $INVENTORY_DIR/"
    echo "Reports saved to: $REPORTS_DIR/"
    echo ""
    echo "Next steps:"
    echo "  1. Review the detailed comparison reports"
    echo "  2. Check for misplaced files (wrong library)"
    echo "  3. Review the sync scripts (DRY RUN mode by default)"
    echo "  4. Execute sync scripts after verification"
    echo ""
}

main "$@"
