#!/usr/bin/env bash
# tv_sync_loop.sh — Continuous TV sync loop
#
# Cycle:
#   1. Run the most recent tv_sync_actions_*.sh at PARALLEL=8
#   2. When complete, run fresh inventory (Unraid Agent for Ali, local for Chris) + compare
#   3. If new tasks found, loop back to 1
#   4. If libraries are in sync, sleep and re-check periodically
#
# Run in a persistent screen:
#   screen -dmS tvsync bash /opt/mother/scripts/tv_sync_loop.sh
#   screen -r tvsync
#
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
REPORTS_DIR="$PROJECT_DIR/reports"
INVENTORIES_DIR="$PROJECT_DIR/inventories"
LOG_FILE="$PROJECT_DIR/logs/tv_sync_loop.log"
PARALLEL="${PARALLEL:-16}"
ALI_TV_PATH="/mnt/user/Media/TV Shows"
CHRIS_TV_PATH="/mnt/synology/rs-tv"
RECHECK_INTERVAL=3600   # seconds to wait between checks when in-sync

mkdir -p "$PROJECT_DIR/logs"

# Load env
set +e; set -a; source "$PROJECT_DIR/.env" 2>/dev/null; set +a; set -e

BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
CHAT_ID="${TELEGRAM_CHAT_ID:-}"
UNRAID_AGENT_URL="${UNRAID_AGENT_URL:-http://192.168.1.10:8100}"
UNRAID_AGENT_API_KEY="${UNRAID_AGENT_API_KEY:-}"

log() {
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] $1"
    echo "$msg"
    echo "$msg" >> "$LOG_FILE"
}

tg() {
    local msg="$1"
    log "$msg"
    if [ -n "$BOT_TOKEN" ] && [ -n "$CHAT_ID" ]; then
        curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
            -d chat_id="${CHAT_ID}" \
            -d text="📺 TV Sync | $msg" \
            -d parse_mode=HTML > /dev/null 2>&1 || true
    fi
}

find_latest_tv_script() {
    ls -1 "$REPORTS_DIR"/tv_sync_actions_*.sh 2>/dev/null \
        | grep -oP '\d{8}_\d{6}' | sort | tail -1 \
        | xargs -I{} find "$REPORTS_DIR" -name "tv_sync_actions_{}.sh" 2>/dev/null
}

run_inventory_and_compare() {
    tg "Starting fresh TV inventory (Unraid Agent for Ali, local for Chris)..."

    # ── Chris inventory (local scan) ──────────────────────────────────────────
    log "Scanning Chris TV side (${CHRIS_TV_PATH})..."
    cd "$PROJECT_DIR"
    if python3 scripts/generate_inventory.py "$CHRIS_TV_PATH" \
        -o "inventories/chris_tv_1080p" --fast 2>&1; then
        log "Chris TV inventory done."
    else
        tg "⚠️ Chris TV inventory failed — skipping compare this cycle"
        return 1
    fi

    # ── Ali TV inventory via Unraid Agent ─────────────────────────────────────
    log "Fetching Ali TV inventory from Unraid Agent (${UNRAID_AGENT_URL})..."
    local encoded_path="${ALI_TV_PATH// /%20}"
    local inv_tmp inv_http_code
    inv_tmp=$(mktemp)
    inv_http_code=$(curl -s -o "$inv_tmp" -w '%{http_code}' \
        -H "X-Api-Key: ${UNRAID_AGENT_API_KEY}" \
        "${UNRAID_AGENT_URL}/inventory?path=${encoded_path}&refresh=true" 2>/dev/null)

    if [ "$inv_http_code" != "200" ]; then
        tg "⚠️ Unraid Agent TV inventory failed (HTTP ${inv_http_code}) — skipping compare this cycle"
        rm -f "$inv_tmp"
        return 1
    fi

    # Transform agent response: add tvdb_id, show_folder, relative_path
    python3 -c "
import json, re

data = json.load(open('$inv_tmp'))
items = data.get('items', data) if isinstance(data, dict) else data
lib_root = '${ALI_TV_PATH}/'

result = []
for item in items:
    show_folder = item.get('title', '')
    tvdb_match = re.search(r'\{tvdb-(\d+)\}', show_folder, re.IGNORECASE)
    tvdb_id = tvdb_match.group(1) if tvdb_match else ''
    item_path = item.get('path', '')
    rel_path = item_path[len(lib_root):] if item_path.startswith(lib_root) else item.get('filename', '')
    result.append({
        'show_folder': show_folder,
        'title': show_folder,
        'filename': item.get('filename', ''),
        'path': item_path,
        'relative_path': rel_path,
        'size_bytes': item.get('size_bytes', 0),
        'size_gb': item.get('size_gb', 0),
        'resolution': item.get('resolution', ''),
        'source': item.get('source', ''),
        'hdr': item.get('hdr', ''),
        'audio_codec': item.get('audio_codec', ''),
        'video_codec': item.get('video_codec', ''),
        'tvdb_id': tvdb_id,
    })

json.dump(result, open('${INVENTORIES_DIR}/ali_tv_1080p.json', 'w'), indent=2)
print(len(result))
" 2>/dev/null && log "Ali TV inventory done — $(python3 -c "import json; print(len(json.load(open('${INVENTORIES_DIR}/ali_tv_1080p.json'))))" 2>/dev/null || echo '?') episodes" || {
        tg "⚠️ Failed to parse Unraid Agent TV response — skipping compare this cycle"
        rm -f "$inv_tmp"
        return 1
    }
    rm -f "$inv_tmp"

    # ── Compare ───────────────────────────────────────────────────────────────
    log "Running TV comparison..."
    cd "$PROJECT_DIR"
    python3 scripts/compare_tv_libraries.py \
        "${INVENTORIES_DIR}/ali_tv_1080p.json" \
        "${INVENTORIES_DIR}/chris_tv_1080p.json" \
        -o "${REPORTS_DIR}" 2>&1

    local new_script
    new_script=$(find_latest_tv_script)
    local task_count=0
    if [ -n "$new_script" ]; then
        task_count=$(grep -cP '^do_rsync ' "$new_script" 2>/dev/null; true)
        task_count=${task_count:-0}
    fi
    tg "TV comparison done — new script: $(basename "${new_script:-none}") | Tasks: ${task_count}"
    printf '%s\n' "$task_count" > /tmp/tv_sync_task_count
}

# ═════════════════════════════════════════════════════════════
# MAIN LOOP
# ═════════════════════════════════════════════════════════════
tg "TV sync loop started (PARALLEL=${PARALLEL})"

while true; do
    SYNC_SCRIPT=$(find_latest_tv_script)

    if [ -z "$SYNC_SCRIPT" ]; then
        tg "No TV sync script found — running initial inventory..."
        run_inventory_and_compare
        SYNC_SCRIPT=$(find_latest_tv_script)
    fi

    if [ -z "$SYNC_SCRIPT" ]; then
        log "Still no TV sync script after inventory — waiting ${RECHECK_INTERVAL}s"
        sleep "$RECHECK_INTERVAL"
        continue
    fi

    TASK_COUNT=$(grep -cP '^do_rsync ' "$SYNC_SCRIPT" 2>/dev/null; true)
    TASK_COUNT=${TASK_COUNT:-0}
    PROGRESS_FILE_NAME=$(grep -oP 'PROGRESS_FILE="\$\{PROGRESS_FILE:-\K[^}]+' "$SYNC_SCRIPT" 2>/dev/null | head -1)
    COMPLETED=$(wc -l < "$REPORTS_DIR/$PROGRESS_FILE_NAME" 2>/dev/null || echo 0)

    if [ "$TASK_COUNT" -gt 0 ] && [ "$COMPLETED" -lt "$TASK_COUNT" ]; then
        REMAINING=$((TASK_COUNT - COMPLETED))
        tg "TV Syncing: $(basename "$SYNC_SCRIPT") | ${COMPLETED}/${TASK_COUNT} done | ${REMAINING} left | PARALLEL=${PARALLEL}"
        cd "$REPORTS_DIR"
        PARALLEL=$PARALLEL bash "$SYNC_SCRIPT"
        SYNC_EXIT=$?
        tg "TV sync run finished (exit ${SYNC_EXIT}) — running fresh inventory to find remaining work"
    else
        tg "Current TV sync script complete (${COMPLETED}/${TASK_COUNT}) — running inventory for next cycle"
    fi

    # Always re-inventory after a sync run
    run_inventory_and_compare
    NEW_TASK_COUNT=$(cat /tmp/tv_sync_task_count 2>/dev/null || echo 0)

    if [ "${NEW_TASK_COUNT}" -eq 0 ] 2>/dev/null; then
        tg "✅ TV libraries appear in sync! Sleeping ${RECHECK_INTERVAL}s before next check..."
        sleep "$RECHECK_INTERVAL"
    else
        log "New TV tasks found (${NEW_TASK_COUNT}) — looping immediately"
        sleep 5
    fi
done
