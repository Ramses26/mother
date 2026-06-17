#!/bin/bash
#==============================================================================
# Synology Full Scan + Summary - Project Mother
#
# Generates fresh inventories for all 4 Synology paths (skipping any that are
# < 24h old), then runs synology_summary.py to produce a full quality breakdown
# and non-media file report. Sends result to Telegram.
#
# Usage:
#   screen -dmS synology_scan /opt/mother/scripts/synology_full_scan.sh
#   # Then: screen -r synology_scan
#
# Options (env vars):
#   FORCE_RESCAN=true    Re-scan even if inventory is < 24h old
#   SKIP_EXTRAS=true     Skip non-media filesystem scan
#==============================================================================

set -euo pipefail

SCRIPTS_DIR="/opt/mother/scripts"
INVENTORIES_DIR="/opt/mother/inventories"
REPORTS_DIR="/opt/mother/reports"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
LOG="${REPORTS_DIR}/synology_scan_${TIMESTAMP}.log"
FORCE_RESCAN="${FORCE_RESCAN:-false}"
SKIP_EXTRAS="${SKIP_EXTRAS:-false}"

# Load env for Telegram (only valid KEY=VALUE lines, skip comments/blanks)
if [ -f /opt/mother/.env ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ "$line" =~ ^[[:space:]]*$ ]] && continue
        [[ "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]] && export "$line" 2>/dev/null || true
    done < /opt/mother/.env
fi

mkdir -p "$INVENTORIES_DIR" "$REPORTS_DIR"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG"
}

send_telegram() {
    local text="$1"
    if [ -n "${TELEGRAM_BOT_TOKEN:-}" ] && [ -n "${TELEGRAM_CHAT_ID:-}" ]; then
        curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
            --data-urlencode "chat_id=${TELEGRAM_CHAT_ID}" \
            --data-urlencode "text=${text}" \
            >/dev/null 2>&1 || true
    fi
}

is_fresh() {
    local file="$1"
    local max_age_hours=24
    if [ ! -f "$file" ]; then
        return 1  # not fresh
    fi
    local age_seconds=$(( $(date +%s) - $(stat -c %Y "$file") ))
    local max_age_seconds=$(( max_age_hours * 3600 ))
    [ "$age_seconds" -lt "$max_age_seconds" ]
}

#------------------------------------------------------------------------------
# Inventory definitions
#------------------------------------------------------------------------------
# Format: "media_path|output_base|label"
declare -a INVENTORY_DEFS=(
    "/mnt/synology/rs-movies|${INVENTORIES_DIR}/chris_movies|rs-movies (1080p)"
    "/mnt/synology/rs-tv|${INVENTORIES_DIR}/chris_tv|rs-tv (1080p)"
    "/mnt/synology/rs-4kmedia/4kmovies|${INVENTORIES_DIR}/chris_4kmovies|rs-4kmedia/4kmovies"
    "/mnt/synology/rs-4kmedia/4ktv|${INVENTORIES_DIR}/chris_4ktv|rs-4kmedia/4ktv"
)

log "=== Synology Full Scan ==="
send_telegram "Mother: Synology full scan started
Inventories → quality summary + non-media file report"

cd "$SCRIPTS_DIR"

#------------------------------------------------------------------------------
# Step 1: Generate/reuse inventories
#------------------------------------------------------------------------------
declare -a JSON_FILES=()
scanned_count=0
reused_count=0

for def in "${INVENTORY_DEFS[@]}"; do
    media_path=$(echo "$def" | cut -d'|' -f1)
    output_base=$(echo "$def" | cut -d'|' -f2)
    label=$(echo "$def" | cut -d'|' -f3)
    json_file="${output_base}.json"

    log ""
    log "--- $label ---"

    if [ ! -d "$media_path" ]; then
        log "WARNING: Path not found, skipping: $media_path"
        continue
    fi

    if [ "$FORCE_RESCAN" != "true" ] && is_fresh "$json_file"; then
        age_hours=$(( ( $(date +%s) - $(stat -c %Y "$json_file") ) / 3600 ))
        log "Reusing existing inventory (${age_hours}h old): $json_file"
        JSON_FILES+=("$json_file")
        reused_count=$((reused_count + 1))
        continue
    fi

    log "Scanning: $media_path → $output_base"
    log "Running: python3 generate_inventory.py \"$media_path\" -o \"$output_base\" --fast"

    if python3 generate_inventory.py "$media_path" -o "$output_base" --fast >> "$LOG" 2>&1; then
        log "Scan complete: $json_file"
        JSON_FILES+=("$json_file")
        scanned_count=$((scanned_count + 1))
    else
        log "ERROR: generate_inventory.py failed for $media_path"
    fi
done

log ""
log "Inventories ready: ${#JSON_FILES[@]} total (${scanned_count} new, ${reused_count} reused)"

if [ ${#JSON_FILES[@]} -eq 0 ]; then
    log "ERROR: No inventories available. Aborting."
    send_telegram "Mother: Synology scan FAILED — no inventories generated. Check log: $LOG"
    exit 1
fi

#------------------------------------------------------------------------------
# Step 2: Run summary
#------------------------------------------------------------------------------
log ""
log "--- Running synology_summary.py ---"

EXTRAS_FLAG=""
if [ "$SKIP_EXTRAS" != "true" ]; then
    EXTRAS_FLAG="--scan-extras"
    log "Including non-media filesystem scan (may take several minutes)"
fi

SUMMARY_ARGS=("${JSON_FILES[@]}")

summary_cmd="python3 synology_summary.py ${SUMMARY_ARGS[*]} ${EXTRAS_FLAG}"
log "Running: $summary_cmd"

if eval "$summary_cmd" >> "$LOG" 2>&1; then
    log "Summary complete"
else
    log "WARNING: synology_summary.py exited non-zero"
fi

# Find the report file just created
summary_report=$(ls -t "$REPORTS_DIR"/synology_summary_*.txt 2>/dev/null | head -1 || true)

#------------------------------------------------------------------------------
# Step 3: Notify Telegram with key stats
#------------------------------------------------------------------------------
if [ -n "$summary_report" ] && [ -f "$summary_report" ]; then
    # Extract per-library totals from the report
    stats_block=$(grep -A 1 "^=\{60\}" "$summary_report" 2>/dev/null | \
        grep "files.*GB total" || echo "  (see report)")

    # Count total files/GB from COMBINED section if present
    combined_line=$(grep -A 2 "COMBINED TOTAL" "$summary_report" 2>/dev/null | \
        grep "files.*GB total" || echo "")

    if [ -n "$combined_line" ]; then
        total_summary="Combined: $combined_line"
    else
        total_summary="(single library)"
    fi

    # Non-media summary
    nonmedia_line=""
    if [ "$SKIP_EXTRAS" != "true" ]; then
        nonmedia_line=$(grep "Non-Media Files" -A 1 "$summary_report" 2>/dev/null | \
            grep "files.*GB total" || echo "")
        if [ -n "$nonmedia_line" ]; then
            nonmedia_line="
Non-media: $nonmedia_line"
        fi
    fi

    msg="Mother: Synology Library Summary Complete
─────────────────────────────
${total_summary}${nonmedia_line}

Full report: $summary_report
Scan log: $LOG"
else
    msg="Mother: Synology scan complete (no summary report found)
Log: $LOG"
fi

log ""
log "=== COMPLETE ==="
log "$msg"
send_telegram "$msg"
