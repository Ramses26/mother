#!/bin/bash
#==============================================================================
# Monitor Sync-Webhook Container
#
# Checks if sync-webhook container is running and healthy.
# Sends Telegram alert if down and attempts to restart.
#
# Cron (every 5 minutes):
#   */5 * * * * /opt/mother/scripts/monitor-sync-webhook.sh
#==============================================================================

LOG_FILE="/opt/mother/logs/sync-webhook-monitor.log"
CONTAINER="sync-webhook"

# Load environment for Telegram credentials
source /opt/mother/.env 2>/dev/null

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

send_telegram() {
    local message="$1"
    if [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
        curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
            -d "chat_id=${TELEGRAM_CHAT_ID}" \
            -d "text=${message}" \
            -d "parse_mode=HTML" \
            >/dev/null 2>&1
    fi
}

# Check if container is running
if ! docker ps --filter "name=${CONTAINER}" --filter "status=running" --format "{{.Names}}" | grep -q "^${CONTAINER}$"; then
    log "ALERT: ${CONTAINER} is NOT running!"

    # Check if container exists but is stopped
    if docker ps -a --filter "name=${CONTAINER}" --format "{{.Names}}" | grep -q "^${CONTAINER}$"; then
        log "Attempting to restart ${CONTAINER}..."

        cd /opt/mother
        docker compose up -d ${CONTAINER} 2>&1 | tee -a "$LOG_FILE"

        sleep 5

        # Verify restart
        if docker ps --filter "name=${CONTAINER}" --filter "status=running" --format "{{.Names}}" | grep -q "^${CONTAINER}$"; then
            log "SUCCESS: ${CONTAINER} restarted successfully"
            send_telegram "🔄 <b>Mother Alert</b>: sync-webhook was down and has been restarted automatically"
        else
            log "FAILED: Could not restart ${CONTAINER}"
            send_telegram "🚨 <b>Mother Alert</b>: sync-webhook is DOWN and restart FAILED! Manual intervention required."
        fi
    else
        log "ERROR: ${CONTAINER} container does not exist!"
        send_telegram "🚨 <b>Mother Alert</b>: sync-webhook container does not exist! Check docker-compose."
    fi
else
    # Container is running, check health endpoint
    HEALTH=$(curl -s --max-time 10 http://localhost:5001/health 2>/dev/null)

    if [ -z "$HEALTH" ]; then
        log "WARNING: Health endpoint not responding"
    elif echo "$HEALTH" | grep -q '"status":"healthy"'; then
        # All good - only log every hour to reduce noise
        MINUTE=$(date +%M)
        if [ "$MINUTE" = "00" ]; then
            log "OK: ${CONTAINER} is running and healthy"
        fi
    else
        log "WARNING: ${CONTAINER} health check returned: $HEALTH"
    fi
fi
