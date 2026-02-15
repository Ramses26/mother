#!/bin/bash
###############################################################################
# Full Library Analysis Workflow - Project Mother
#
# Purpose: Run complete analysis for all libraries (Movies + TV Shows)
#          Includes optional dedup step before cross-site comparison.
#
# Usage:
#   ./analyze_all.sh                    # Run full analysis for everything
#   ./analyze_all.sh --movies           # Movies only
#   ./analyze_all.sh --tv               # TV shows only
#   ./analyze_all.sh --4k               # 4K libraries only
#   ./analyze_all.sh --1080p            # 1080p libraries only
#   ./analyze_all.sh --dedup            # Run dedup before analysis
#   ./analyze_all.sh --dedup-only       # Only run dedup (no comparison)
#
# Last Updated: 2026-02-14
###############################################################################

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log_section() {
    echo ""
    echo -e "${CYAN}+==============================================================+${NC}"
    echo -e "${CYAN}| $1${NC}"
    echo -e "${CYAN}+==============================================================+${NC}"
    echo ""
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

###############################################################################
# Main
###############################################################################

main() {
    local do_movies=true
    local do_tv=true
    local do_dedup=false
    local dedup_only=false
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
            --dedup)
                do_dedup=true
                shift
                ;;
            --dedup-only)
                do_dedup=true
                dedup_only=true
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --movies      Analyze movies only"
                echo "  --tv          Analyze TV shows only"
                echo "  --4k          Analyze 4K libraries only"
                echo "  --1080p       Analyze 1080p libraries only"
                echo "  --dedup       Run local dedup before cross-site comparison"
                echo "  --dedup-only  Only run dedup (no inventory/comparison)"
                echo "  -h, --help    Show this help"
                echo ""
                echo "Examples:"
                echo "  $0                     # Full analysis (Movies + TV, 4K + 1080p)"
                echo "  $0 --movies --4k       # Just 4K movies"
                echo "  $0 --tv --1080p        # Just 1080p TV shows"
                echo "  $0 --dedup             # Dedup + full analysis"
                echo "  $0 --dedup-only        # Just dedup, no comparison"
                echo ""
                echo "Workflow:"
                echo "  1. [--dedup] Local dedup on both servers"
                echo "  2. Generate fresh inventories"
                echo "  3. Cross-site comparison (movies -> compare_libraries.py, TV -> compare_tv_libraries.py)"
                echo "  4. Review reports, then run sync scripts"
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
    echo "  Dedup: $([ "$do_dedup" = true ] && echo "YES" || echo "NO")"
    echo ""

    # Step 1: Local dedup (if requested)
    if [ "$do_dedup" = true ]; then
        log_section "STEP 1: LOCAL DEDUP (dry-run reports)"

        if [ "$do_movies" = true ]; then
            log_info "Dedup: Chris's Movies (Synology)"
            if [ -d "/mnt/synology/rs-movies" ]; then
                python3 "$SCRIPT_DIR/cleanup_duplicates.py" /mnt/synology/rs-movies --type movies --dry-run -o "$PROJECT_DIR/reports"
            else
                log_warn "Synology movies path not accessible"
            fi

            log_info "Dedup: Ali's Movies (Unraid)"
            if [ -d "/mnt/unraid/media/Movies" ]; then
                python3 "$SCRIPT_DIR/cleanup_duplicates.py" /mnt/unraid/media/Movies --type movies --dry-run --deleted-dir "/mnt/unraid/media/Deleted Movies" -o "$PROJECT_DIR/reports"
            else
                log_warn "Unraid movies path not accessible"
            fi
        fi

        if [ "$do_tv" = true ]; then
            log_info "Dedup: Chris's TV (Synology)"
            if [ -d "/mnt/synology/rs-tv" ]; then
                python3 "$SCRIPT_DIR/cleanup_duplicates.py" /mnt/synology/rs-tv --type tv --dry-run -o "$PROJECT_DIR/reports"
            else
                log_warn "Synology TV path not accessible"
            fi

            log_info "Dedup: Ali's TV (Unraid)"
            if [ -d "/mnt/unraid/media/TV Shows" ]; then
                python3 "$SCRIPT_DIR/cleanup_duplicates.py" "/mnt/unraid/media/TV Shows" --type tv --dry-run --deleted-dir "/mnt/unraid/media/Deleted TV" -o "$PROJECT_DIR/reports"
            else
                log_warn "Unraid TV path not accessible"
            fi
        fi

        echo ""
        log_info "Dedup reports generated in: $PROJECT_DIR/reports/"
        log_info "Review cleanup_report_*.txt and run cleanup_actions_*.sh with DRY_RUN=false to execute"

        if [ "$dedup_only" = true ]; then
            log_section "DEDUP COMPLETE"
            exit 0
        fi
    fi

    # Step 2+3: Run movie and TV analysis (inventory + comparison)
    if [ "$do_movies" = true ]; then
        log_section "STEP 2: ANALYZING MOVIES"
        "$SCRIPT_DIR/analyze_movies.sh" $resolution_flag
    fi

    if [ "$do_tv" = true ]; then
        log_section "STEP 3: ANALYZING TV SHOWS"
        "$SCRIPT_DIR/analyze_tv.sh" $resolution_flag
    fi

    log_section "ALL ANALYSIS COMPLETE"
    echo ""
    echo "Summary:"
    echo "  Inventories: $(ls -1 "$SCRIPT_DIR/../inventories/"*.json 2>/dev/null | wc -l) files"
    echo "  Reports: $(ls -1 "$SCRIPT_DIR/../reports/"*.txt 2>/dev/null | wc -l) report files"
    echo ""
    echo "Review reports in: $PROJECT_DIR/reports/"
    echo ""
    echo "Next steps:"
    echo "  1. Review cleanup_report_*.txt for local duplicates"
    echo "  2. Review comparison reports for cross-site sync actions"
    echo "  3. Run cleanup scripts with DRY_RUN=false (dedup first)"
    echo "  4. Run sync scripts after cleanup"
    echo ""
}

main "$@"
