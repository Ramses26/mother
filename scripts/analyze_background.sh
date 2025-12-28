#!/bin/bash
###############################################################################
# Background Library Analysis - Project Mother
#
# Runs analysis in screen sessions so you can continue working
#
# Usage:
#   ./analyze_background.sh movies          # Analyze movies in background
#   ./analyze_background.sh tv              # Analyze TV shows in background
#   ./analyze_background.sh all             # Analyze everything
#   ./analyze_background.sh --status        # Check screen status
#   ./analyze_background.sh --attach TYPE   # Attach to screen (movies/tv/all)
#
# Last Updated: 2024-12-28
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

show_status() {
    echo ""
    echo -e "${CYAN}=== Analysis Screen Sessions ===${NC}"
    echo ""
    screen -ls 2>/dev/null | grep -E "mother_analyze" || echo "No analysis screens running"
    echo ""
    echo "To attach: screen -r <session_name>"
    echo "To detach: Ctrl+A, then D"
    echo ""
}

start_movies_analysis() {
    local screen_name="mother_analyze_movies"

    if screen -ls 2>/dev/null | grep -q "$screen_name"; then
        echo -e "${YELLOW}Movie analysis already running!${NC}"
        echo "Attach with: screen -r $screen_name"
        return 1
    fi

    echo -e "${GREEN}Starting movie analysis in background...${NC}"
    screen -dmS "$screen_name" bash -c "
        cd '$PROJECT_DIR'
        echo '=== Movie Analysis Started ==='
        echo 'Time: $(date)'
        echo ''
        ./scripts/analyze_movies.sh
        echo ''
        echo '=== Analysis Complete ==='
        echo 'Press Enter to close this screen session...'
        read
    "

    echo ""
    echo "Movie analysis running in screen: $screen_name"
    echo "  Attach: screen -r $screen_name"
    echo "  Status: $0 --status"
    echo ""
}

start_tv_analysis() {
    local screen_name="mother_analyze_tv"

    if screen -ls 2>/dev/null | grep -q "$screen_name"; then
        echo -e "${YELLOW}TV analysis already running!${NC}"
        echo "Attach with: screen -r $screen_name"
        return 1
    fi

    echo -e "${GREEN}Starting TV analysis in background...${NC}"
    screen -dmS "$screen_name" bash -c "
        cd '$PROJECT_DIR'
        echo '=== TV Shows Analysis Started ==='
        echo 'Time: $(date)'
        echo ''
        ./scripts/analyze_tv.sh
        echo ''
        echo '=== Analysis Complete ==='
        echo 'Press Enter to close this screen session...'
        read
    "

    echo ""
    echo "TV analysis running in screen: $screen_name"
    echo "  Attach: screen -r $screen_name"
    echo "  Status: $0 --status"
    echo ""
}

start_all_analysis() {
    local screen_name="mother_analyze_all"

    if screen -ls 2>/dev/null | grep -q "$screen_name"; then
        echo -e "${YELLOW}Full analysis already running!${NC}"
        echo "Attach with: screen -r $screen_name"
        return 1
    fi

    echo -e "${GREEN}Starting full analysis in background...${NC}"
    screen -dmS "$screen_name" bash -c "
        cd '$PROJECT_DIR'
        echo '=== Full Library Analysis Started ==='
        echo 'Time: $(date)'
        echo ''
        ./scripts/analyze_all.sh
        echo ''
        echo '=== Analysis Complete ==='
        echo 'Press Enter to close this screen session...'
        read
    "

    echo ""
    echo "Full analysis running in screen: $screen_name"
    echo "  Attach: screen -r $screen_name"
    echo "  Status: $0 --status"
    echo ""
}

attach_screen() {
    local type="$1"
    local screen_name="mother_analyze_$type"

    if screen -ls 2>/dev/null | grep -q "$screen_name"; then
        screen -r "$screen_name"
    else
        echo "No screen session found: $screen_name"
        show_status
    fi
}

# Main
case "${1:-}" in
    movies)
        start_movies_analysis
        ;;
    tv)
        start_tv_analysis
        ;;
    all)
        start_all_analysis
        ;;
    --status|-s)
        show_status
        ;;
    --attach|-a)
        attach_screen "${2:-all}"
        ;;
    -h|--help|"")
        echo "Usage: $0 <command>"
        echo ""
        echo "Commands:"
        echo "  movies              Start movie analysis in background"
        echo "  tv                  Start TV show analysis in background"
        echo "  all                 Start full analysis in background"
        echo "  --status, -s        Show running screen sessions"
        echo "  --attach TYPE, -a   Attach to screen (movies/tv/all)"
        echo ""
        echo "Examples:"
        echo "  $0 movies           # Start movie analysis"
        echo "  $0 --status         # Check if running"
        echo "  $0 --attach movies  # View movie analysis output"
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use --help for usage"
        exit 1
        ;;
esac
