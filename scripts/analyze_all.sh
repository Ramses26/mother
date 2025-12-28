#!/bin/bash
###############################################################################
# Full Library Analysis Workflow - Project Mother
#
# Purpose: Run complete analysis for all libraries (Movies + TV Shows)
#
# Usage:
#   ./analyze_all.sh                    # Run full analysis for everything
#   ./analyze_all.sh --movies           # Movies only
#   ./analyze_all.sh --tv               # TV shows only
#   ./analyze_all.sh --4k               # 4K libraries only
#   ./analyze_all.sh --1080p            # 1080p libraries only
#
# Last Updated: 2024-12-28
###############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_section() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║ $1${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

###############################################################################
# Main
###############################################################################

main() {
    local do_movies=true
    local do_tv=true
    local resolution_flag=""

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
                resolution_flag="--4k"
                shift
                ;;
            --1080p)
                resolution_flag="--1080p"
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --movies    Analyze movies only"
                echo "  --tv        Analyze TV shows only"
                echo "  --4k        Analyze 4K libraries only"
                echo "  --1080p     Analyze 1080p libraries only"
                echo "  -h, --help  Show this help"
                echo ""
                echo "Examples:"
                echo "  $0                     # Full analysis (Movies + TV, 4K + 1080p)"
                echo "  $0 --movies --4k       # Just 4K movies"
                echo "  $0 --tv --1080p        # Just 1080p TV shows"
                exit 0
                ;;
            *)
                echo -e "${RED}Unknown option: $1${NC}"
                exit 1
                ;;
        esac
    done

    log_section "PROJECT MOTHER - FULL LIBRARY ANALYSIS"
    echo "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo "Analysis scope:"
    echo "  Movies: $([ "$do_movies" = true ] && echo "YES" || echo "NO")"
    echo "  TV Shows: $([ "$do_tv" = true ] && echo "YES" || echo "NO")"
    echo "  Resolution: $([ -z "$resolution_flag" ] && echo "ALL" || echo "${resolution_flag#--}")"
    echo ""

    # Run Movies analysis
    if [ "$do_movies" = true ]; then
        log_section "ANALYZING MOVIES"
        "$SCRIPT_DIR/analyze_movies.sh" $resolution_flag
    fi

    # Run TV Shows analysis
    if [ "$do_tv" = true ]; then
        log_section "ANALYZING TV SHOWS"
        "$SCRIPT_DIR/analyze_tv.sh" $resolution_flag
    fi

    log_section "ALL ANALYSIS COMPLETE"
    echo ""
    echo "Summary:"
    echo "  Inventories: $(ls -1 "$SCRIPT_DIR/../inventories/"*.json 2>/dev/null | wc -l) files"
    echo "  Reports: $(ls -1d "$SCRIPT_DIR/../reports/"*/ 2>/dev/null | wc -l) directories"
    echo ""
    echo "Review reports in: $(dirname "$SCRIPT_DIR")/reports/"
    echo ""
}

main "$@"
