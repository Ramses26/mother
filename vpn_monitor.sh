#!/bin/bash
#==============================================================================
# Project Mother - VPN Traffic Monitor
# Tracks data transferred between mother (10.0.0.162) and Unraid (192.168.1.10)
# Sends daily reports via Apprise on Terminus
#==============================================================================
#
# SETUP:
#   1. Copy to mother: scp vpn_monitor.sh alig@mother:/opt/mother/
#   2. Make executable: chmod +x /opt/mother/vpn_monitor.sh
#   3. Install bc: sudo apt install -y bc
#   4. Run setup: sudo /opt/mother/vpn_monitor.sh setup
#   5. Install cron: sudo /opt/mother/vpn_monitor.sh install-cron
#
# Uses Apprise on Terminus (192.168.1.14:8000) with tag "servers"
#
#==============================================================================

set -euo pipefail

# Configuration
UNRAID_IP="192.168.1.10"
APPRISE_URL="http://192.168.1.14:8000/notify/apprise"
APPRISE_TAG="servers"  # Sends to Server Alerts Telegram group
DATA_DIR="/opt/mother/traffic_stats"
TODAY=$(date +%Y-%m-%d)

# Remaining TB to sync (update this as needed)
REMAINING_TB="${REMAINING_TB:-0}"

# Ensure data directory exists
mkdir -p "$DATA_DIR"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Bytes to human readable
bytes_hr() {
    local bytes=${1:-0}
    if (( bytes >= 1099511627776 )); then
        printf "%.2f TB" "$(echo "scale=2; $bytes/1099511627776" | bc)"
    elif (( bytes >= 1073741824 )); then
        printf "%.2f GB" "$(echo "scale=2; $bytes/1073741824" | bc)"
    elif (( bytes >= 1048576 )); then
        printf "%.2f MB" "$(echo "scale=2; $bytes/1048576" | bc)"
    else
        printf "%.2f KB" "$(echo "scale=2; $bytes/1024" | bc)"
    fi
}

# Setup iptables accounting rules
setup_iptables() {
    log "Setting up iptables accounting rules for $UNRAID_IP..."
    
    # Create accounting chain if it doesn't exist
    sudo iptables -N MOTHER_ACCOUNTING 2>/dev/null || true
    
    # Remove old rules if they exist (to avoid duplicates)
    sudo iptables -D INPUT -j MOTHER_ACCOUNTING 2>/dev/null || true
    sudo iptables -D OUTPUT -j MOTHER_ACCOUNTING 2>/dev/null || true
    sudo iptables -F MOTHER_ACCOUNTING 2>/dev/null || true
    
    # Add rules to track Unraid traffic
    sudo iptables -A MOTHER_ACCOUNTING -s "$UNRAID_IP" -j RETURN -m comment --comment "from_unraid"
    sudo iptables -A MOTHER_ACCOUNTING -d "$UNRAID_IP" -j RETURN -m comment --comment "to_unraid"
    
    # Hook into INPUT and OUTPUT
    sudo iptables -I INPUT 1 -j MOTHER_ACCOUNTING
    sudo iptables -I OUTPUT 1 -j MOTHER_ACCOUNTING
    
    log "✅ iptables rules configured"
}

# Get current byte counts from iptables
get_bytes() {
    local from_unraid=0
    local to_unraid=0
    
    # Parse iptables output
    while read -r pkts bytes target prot opt in out source destination rest; do
        if [[ "$source" == "$UNRAID_IP" ]]; then
            from_unraid=$bytes
        elif [[ "$destination" == "$UNRAID_IP" ]]; then
            to_unraid=$bytes
        fi
    done < <(sudo iptables -L MOTHER_ACCOUNTING -v -n -x 2>/dev/null | tail -n +3)
    
    echo "$to_unraid $from_unraid"
}

# Record a snapshot
snapshot() {
    local timestamp=$(date +%s)
    local snapshot_file="$DATA_DIR/snapshots.csv"
    
    read to_unraid from_unraid <<< $(get_bytes)
    
    # Create header if file doesn't exist
    if [[ ! -f "$snapshot_file" ]]; then
        echo "timestamp,date,time,to_unraid,from_unraid" > "$snapshot_file"
    fi
    
    echo "$timestamp,$TODAY,$(date +%H:%M:%S),$to_unraid,$from_unraid" >> "$snapshot_file"
    log "📊 Snapshot: To=$(bytes_hr $to_unraid), From=$(bytes_hr $from_unraid)"
}

# Calculate daily transfer from snapshots
calc_daily() {
    local snapshot_file="$DATA_DIR/snapshots.csv"
    local date_filter="${1:-$TODAY}"
    
    if [[ ! -f "$snapshot_file" ]]; then
        echo "0 0"
        return
    fi
    
    # Get first and last entries for the date
    local first_line=$(grep ",$date_filter," "$snapshot_file" | head -1)
    local last_line=$(grep ",$date_filter," "$snapshot_file" | tail -1)
    
    if [[ -z "$first_line" || -z "$last_line" ]]; then
        echo "0 0"
        return
    fi
    
    local first_to=$(echo "$first_line" | cut -d',' -f4)
    local first_from=$(echo "$first_line" | cut -d',' -f5)
    local last_to=$(echo "$last_line" | cut -d',' -f4)
    local last_from=$(echo "$last_line" | cut -d',' -f5)
    
    local daily_to=$((last_to - first_to))
    local daily_from=$((last_from - first_from))
    
    # Handle counter reset (if iptables was flushed)
    [[ $daily_to -lt 0 ]] && daily_to=$last_to
    [[ $daily_from -lt 0 ]] && daily_from=$last_from
    
    echo "$daily_to $daily_from"
}

# Show current status
status() {
    read to_unraid from_unraid <<< $(get_bytes)
    local total=$((to_unraid + from_unraid))
    
    read daily_to daily_from <<< $(calc_daily)
    local daily_total=$((daily_to + daily_from))
    
    echo ""
    echo "╔══════════════════════════════════════════════════╗"
    echo "║     🖥️  Project Mother - VPN Traffic Monitor     ║"
    echo "╠══════════════════════════════════════════════════╣"
    echo "║ Target: Unraid ($UNRAID_IP) via IPsec VPN       ║"
    echo "╠══════════════════════════════════════════════════╣"
    printf "║ 📤 Sent to Unraid:     %-24s ║\n" "$(bytes_hr $to_unraid)"
    printf "║ 📥 From Unraid:        %-24s ║\n" "$(bytes_hr $from_unraid)"
    printf "║ 📦 Total (cumulative): %-24s ║\n" "$(bytes_hr $total)"
    echo "╠══════════════════════════════════════════════════╣"
    echo "║ 📅 Today's Transfer ($TODAY):                 ║"
    printf "║    📤 Sent:     %-32s ║\n" "$(bytes_hr $daily_to)"
    printf "║    📥 Received: %-32s ║\n" "$(bytes_hr $daily_from)"
    printf "║    📦 Total:    %-32s ║\n" "$(bytes_hr $daily_total)"
    echo "╚══════════════════════════════════════════════════╝"
    echo ""
}

# Send notification via Apprise
send_apprise() {
    local title="$1"
    local body="$2"
    local type="${3:-info}"
    
    curl -sf -X POST "${APPRISE_URL}?tag=${APPRISE_TAG}" \
        -d "title=${title}" \
        -d "body=${body}" \
        -d "type=${type}" \
        --connect-timeout 10 \
        --max-time 30 || {
            log "⚠️ Failed to send Apprise notification"
            return 1
        }
    
    log "✅ Notification sent via Apprise"
}

# Generate daily report
report() {
    read daily_to daily_from <<< $(calc_daily)
    local daily_total=$((daily_to + daily_from))
    
    # Get cumulative totals
    read total_to total_from <<< $(get_bytes)
    local cumulative_total=$((total_to + total_from))
    
    # Average speed calculation
    local hours_elapsed=$(date +%H)
    [[ $hours_elapsed -eq 0 ]] && hours_elapsed=24
    local seconds_elapsed=$((hours_elapsed * 3600))
    local avg_speed_bps=0
    [[ $seconds_elapsed -gt 0 ]] && avg_speed_bps=$((daily_total / seconds_elapsed))
    local avg_speed_mbps=$(echo "scale=1; $avg_speed_bps * 8 / 1000000" | bc 2>/dev/null || echo "0")
    
    # Max theoretical daily transfer at 166 Mbps = ~1.79 TB
    local max_daily=$((166 * 1000000 / 8 * 86400))
    local utilization=0
    [[ $max_daily -gt 0 ]] && utilization=$(echo "scale=1; $daily_total * 100 / $max_daily" | bc 2>/dev/null || echo "0")
    
    # Days remaining estimate
    local days_left="N/A"
    if [[ "$REMAINING_TB" != "0" ]] && [[ $daily_total -gt 0 ]]; then
        local remaining_bytes=$(echo "$REMAINING_TB * 1099511627776" | bc 2>/dev/null || echo "0")
        days_left=$(echo "scale=0; $remaining_bytes / $daily_total" | bc 2>/dev/null || echo "N/A")
    fi

    # Build Telegram message (using basic formatting)
    local title="📊 Project Mother - Daily VPN Report"
    
    local body="📅 Date: ${TODAY}

📤 To Unraid: $(bytes_hr $daily_to)
📥 From Unraid: $(bytes_hr $daily_from)
📦 Total Today: $(bytes_hr $daily_total)

⚡ Avg Speed: ${avg_speed_mbps} Mbps
📈 Utilization: ${utilization}%
🎯 Max Capacity: ~1.79 TB/day (166 Mbps)"

    if [[ "$REMAINING_TB" != "0" ]]; then
        body+="

⏱️ Est. Days Left: ${days_left}
📁 Remaining: ${REMAINING_TB} TB"
    fi

    # Add recommendation based on utilization
    local rec_type="info"
    if (( $(echo "$utilization > 70" | bc -l 2>/dev/null || echo 0) )); then
        body+="

✅ High utilization! WireGuard upgrade recommended (~2x speed)."
        rec_type="success"
    elif (( $(echo "$utilization > 40" | bc -l 2>/dev/null || echo 0) )); then
        body+="

🔶 Moderate utilization. WireGuard would speed up large transfers."
        rec_type="warning"
    else
        body+="

ℹ️ Low utilization. Current IPsec setup is sufficient."
    fi

    # Display report
    echo ""
    echo "═══════════════════════════════════════════════════"
    echo "$title"
    echo "═══════════════════════════════════════════════════"
    echo -e "$body"
    echo "═══════════════════════════════════════════════════"
    echo ""
    
    # Save to file
    echo -e "$body" > "$DATA_DIR/report_${TODAY}.txt"
    
    # Send via Apprise
    send_apprise "$title" "$body" "$rec_type"
}

# Reset iptables counters
reset() {
    log "Resetting iptables counters..."
    sudo iptables -Z MOTHER_ACCOUNTING
    log "✅ Counters reset to zero"
}

# Make iptables rules persistent
persist() {
    if command -v netfilter-persistent &>/dev/null; then
        sudo netfilter-persistent save
        log "✅ iptables rules saved"
    else
        log "Installing iptables-persistent..."
        sudo apt install -y iptables-persistent
        sudo netfilter-persistent save
        log "✅ iptables rules saved"
    fi
}

# Install cron jobs
install_cron() {
    local script_path=$(readlink -f "$0")
    
    # Create cron entries
    (
        crontab -l 2>/dev/null | grep -v "vpn_monitor.sh" || true
        echo ""
        echo "# Project Mother VPN Traffic Monitor"
        echo "# Snapshot every hour at :00"
        echo "0 * * * * $script_path snapshot >> /var/log/mother_vpn.log 2>&1"
        echo "# Daily report at 8:00 AM"
        echo "0 8 * * * $script_path report >> /var/log/mother_vpn.log 2>&1"
    ) | crontab -
    
    log "✅ Cron jobs installed:"
    echo ""
    echo "  ⏰ Hourly snapshot:  Every hour at :00"
    echo "  📧 Daily report:     8:00 AM → Telegram (Server Alerts)"
    echo ""
    echo "Logs: /var/log/mother_vpn.log"
    echo ""
    echo "Optional: Set REMAINING_TB for time estimates:"
    echo "  Edit this script and change REMAINING_TB=\"5\" (or your estimate)"
}

# Show history
history_cmd() {
    local snapshot_file="$DATA_DIR/snapshots.csv"
    
    if [[ ! -f "$snapshot_file" ]]; then
        echo "No history available yet. Run 'setup' and wait for snapshots."
        return
    fi
    
    echo ""
    echo "📊 Daily Transfer History (Last 10 Days)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "%-12s %14s %14s %14s\n" "Date" "Sent" "Received" "Total"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Get unique dates (last 10)
    local dates=$(cut -d',' -f2 "$snapshot_file" | sort -u | grep -v "date" | tail -10)
    
    for date in $dates; do
        read to from <<< $(calc_daily "$date")
        local total=$((to + from))
        printf "%-12s %14s %14s %14s\n" "$date" "$(bytes_hr $to)" "$(bytes_hr $from)" "$(bytes_hr $total)"
    done
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Test Apprise connectivity
test_apprise() {
    log "Testing Apprise connection to terminus (192.168.1.14)..."
    
    local title="🧪 VPN Monitor Test"
    local body="Test notification from mother VPN monitor.
    
If you see this, Apprise is working correctly!"
    
    if send_apprise "$title" "$body" "info"; then
        log "✅ Test notification sent successfully!"
        echo "Check your Telegram 'Server Alerts' group."
    else
        log "❌ Failed to send test notification"
        echo ""
        echo "Troubleshooting:"
        echo "  1. Check if terminus is reachable: ping 192.168.1.14"
        echo "  2. Check if Apprise is running: curl http://192.168.1.14:8000"
        echo "  3. Check Apprise logs on terminus: docker logs apprise"
    fi
}

# Main
case "${1:-}" in
    setup)
        setup_iptables
        snapshot
        persist
        status
        echo "Next steps:"
        echo "  1. Test Apprise: $0 test"
        echo "  2. Install cron: $0 install-cron"
        ;;
    snapshot)
        snapshot
        ;;
    status)
        status
        ;;
    report)
        report
        ;;
    reset)
        reset
        ;;
    persist)
        persist
        ;;
    history)
        history_cmd
        ;;
    test)
        test_apprise
        ;;
    install-cron)
        install_cron
        ;;
    *)
        echo "🖥️  Project Mother - VPN Traffic Monitor"
        echo ""
        echo "Usage: $0 <command>"
        echo ""
        echo "Commands:"
        echo "  setup        - Initialize iptables rules (run first, with sudo)"
        echo "  status       - Show current transfer statistics"
        echo "  snapshot     - Record current byte counts (cron does this hourly)"
        echo "  report       - Generate and send daily report to Telegram"
        echo "  history      - Show transfer history by day"
        echo "  test         - Test Apprise notification"
        echo "  reset        - Reset byte counters to zero"
        echo "  persist      - Save iptables rules to survive reboot"
        echo "  install-cron - Install automated hourly snapshots & daily reports"
        echo ""
        echo "Notifications: Sent to Telegram via Apprise on terminus"
        echo "               → Server Alerts group (tag: servers)"
        ;;
esac
