#!/bin/bash
#==============================================================================
# Check Sync Health - Project Mother
#
# Monitors sync screens and restarts them if they've died.
# Can be run via cron every 5-10 minutes for automatic recovery.
#
# Cron example:
#   */10 * * * * /opt/mother/scripts/check-sync-health.sh
#==============================================================================

LOG_DIR="/opt/mother/logs"
REPORTS_DIR="/opt/mother/reports"
PARALLEL="${PARALLEL:-8}"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] HEALTH: $1" >> "$LOG_DIR/sync-health.log"
}

check_and_restart() {
    local screen_name="$1"
    local script_pattern="$2"

    # Check if screen exists
    if screen -list | grep -q "\.$screen_name"; then
        return 0  # Running
    fi

    # Check if the sync is actually complete (all items done)
    local script=$(ls -t "$REPORTS_DIR"/$script_pattern 2>/dev/null | head -1)
    if [ -z "$script" ]; then
        log "No script found for $screen_name"
        return 1
    fi

    # Extract progress file name from script
    local progress_file=$(grep "PROGRESS_FILE=" "$script" | head -1 | cut -d'"' -f2 | sed 's/\${PROGRESS_FILE:-//' | tr -d '}')
    local progress_path="$REPORTS_DIR/$progress_file"

    # Count total and completed
    if [ -f "$progress_path" ]; then
        local completed=$(wc -l < "$progress_path")
        local total=$(grep -c "run_cmd\|do_rsync" "$script" 2>/dev/null || echo "0")

        if [ "$completed" -ge "$total" ] && [ "$total" -gt 0 ]; then
            log "$screen_name: Sync complete ($completed/$total) - not restarting"
            return 0
        fi

        log "$screen_name: Not running, progress $completed/$total - RESTARTING"
    else
        log "$screen_name: Not running, no progress file - RESTARTING"
    fi

    # Restart the screen
    cd "$REPORTS_DIR"
    screen -dmS "$screen_name" bash -c "PARALLEL=$PARALLEL $script 2>&1 | tee -a $LOG_DIR/${screen_name}_sync.log"
    sleep 2

    if screen -list | grep -q "\.$screen_name"; then
        log "$screen_name: Restarted successfully"

        # Send notification
        if command -v curl &>/dev/null && [ -f /opt/mother/.env ]; then
            source /opt/mother/.env 2>/dev/null
            if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
                curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
                    -d "chat_id=${TELEGRAM_CHAT_ID}" \
                    -d "text=🔄 Mother: $screen_name sync screen was restarted automatically" \
                    >/dev/null 2>&1
            fi
        fi
    else
        log "$screen_name: Failed to restart!"
    fi
}

# Check both syncs
check_and_restart "movie" "sync_actions_*.sh"
check_and_restart "tvsync" "tv_sync_actions_*.sh"
