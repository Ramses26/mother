#!/bin/bash
# VPN Ping Monitor - alerts on tunnel down/up events

APPRISE_URL="http://192.168.1.14:8000/notify/apprise"
STATE_FILE="/tmp/vpn_ping_state"
LOG_FILE="/opt/mother/logs/vpn_monitor.log"

# Targets to ping (one from each side of VPN)
UNRAID_IP="192.168.1.10"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Get previous state
PREV_STATE="unknown"
[ -f "$STATE_FILE" ] && PREV_STATE=$(cat "$STATE_FILE")

# Check connectivity
if ping -c 3 -W 5 "$UNRAID_IP" > /dev/null 2>&1; then
    CURR_STATE="up"
    
    if [ "$PREV_STATE" = "down" ]; then
        log "VPN RECOVERED - Unraid reachable"
        curl -sf -X POST "${APPRISE_URL}?tag=servers" \
            -d "title=✅ VPN Tunnel Recovered" \
            -d "body=Connection to Unraid ($UNRAID_IP) restored.

⚠️ NFS mounts may need attention if syncs are stalled." \
            -d "type=success" \
            --connect-timeout 5 \
            --max-time 10
    fi
else
    CURR_STATE="down"
    
    if [ "$PREV_STATE" != "down" ]; then
        log "VPN DOWN - Cannot reach Unraid"
        curl -sf -X POST "${APPRISE_URL}?tag=servers" \
            -d "title=🔴 VPN Tunnel Down" \
            -d "body=Cannot reach Unraid ($UNRAID_IP) from mother.

IPsec tunnel may be down. Check UniFi." \
            -d "type=failure" \
            --connect-timeout 5 \
            --max-time 10
    fi
fi

echo "$CURR_STATE" > "$STATE_FILE"
