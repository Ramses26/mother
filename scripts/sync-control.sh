#!/bin/bash
#==============================================================================
# Sync Control Script - Pause/Resume batch syncs
#
# Usage:
#   ./sync-control.sh pause     # Pause all syncs (current jobs finish, new ones wait)
#   ./sync-control.sh resume    # Resume syncs
#   ./sync-control.sh status    # Check pause status
#   ./sync-control.sh stop      # Stop sync screens entirely
#   ./sync-control.sh start     # Start sync screens
#==============================================================================

PAUSE_FILE="/opt/mother/PAUSE_SYNC"

case "$1" in
    pause)
        touch "$PAUSE_FILE"
        echo "✅ Sync PAUSED - current transfers will finish, new ones will wait"
        echo "   Pause file: $PAUSE_FILE"
        echo "   Run '$0 resume' to continue"
        ;;
    resume)
        rm -f "$PAUSE_FILE"
        echo "✅ Sync RESUMED - transfers will continue"
        ;;
    status)
        if [ -f "$PAUSE_FILE" ]; then
            echo "⏸️  Syncs are PAUSED"
            echo "   Pause file exists: $PAUSE_FILE"
            echo "   Run '$0 resume' to continue"
        else
            echo "▶️  Syncs are RUNNING"
        fi
        # Show screen status
        echo ""
        echo "Screen sessions:"
        screen -ls 2>/dev/null | grep -E "movie|tvsync" || echo "  No sync screens running"
        ;;
    stop)
        # Kill screen sessions
        screen -S movie -X quit 2>/dev/null && echo "Stopped: movie screen"
        screen -S tvsync -X quit 2>/dev/null && echo "Stopped: tvsync screen"
        echo "✅ Sync screens stopped"
        ;;
    start)
        # Start from start-sync-screens.sh if it exists
        if [ -f /opt/mother/scripts/start-sync-screens.sh ]; then
            /opt/mother/scripts/start-sync-screens.sh
            echo "✅ Sync screens started"
        else
            echo "❌ start-sync-screens.sh not found"
        fi
        ;;
    *)
        echo "Usage: $0 {pause|resume|status|stop|start}"
        echo ""
        echo "  pause   - Pause syncs (current jobs finish, new ones wait)"
        echo "  resume  - Resume syncs"
        echo "  status  - Check pause status and screen sessions"
        echo "  stop    - Stop sync screen sessions entirely"
        echo "  start   - Start sync screen sessions"
        exit 1
        ;;
esac
