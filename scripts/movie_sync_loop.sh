#!/usr/bin/env bash
# movie_sync_loop.sh — Continuous movie sync loop
#
# Cycle:
#   1. Run the most recent sync_actions_*.sh at PARALLEL=8
#   2. When complete, run fresh inventory (via Terminus for Ali side) + compare
#   3. If new tasks found, loop back to 1
#   4. If libraries are in sync, sleep and re-check periodically
#
# Run in a persistent screen:
#   screen -dmS movie bash /opt/mother/scripts/movie_sync_loop.sh
#   screen -r movie
#
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
REPORTS_DIR="$PROJECT_DIR/reports"
INVENTORIES_DIR="$PROJECT_DIR/inventories"
LOG_FILE="$PROJECT_DIR/logs/movie_sync_loop.log"
PARALLEL="${PARALLEL:-8}"
TERMINUS="terminus"
REMOTE_TMP="/tmp/mother_inventory"
ALI_MOVIES_PATH="/mnt/unraid/media/Movies"
CHRIS_MOVIES_PATH="/mnt/synology/rs-movies"
RECHECK_INTERVAL=3600   # seconds to wait between checks when in-sync

mkdir -p "$PROJECT_DIR/logs"

# Load env (ignore .env parse errors from comment lines)
set +e; set -a; source "$PROJECT_DIR/.env" 2>/dev/null; set +a; set -e

BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
CHAT_ID="${TELEGRAM_CHAT_ID:-}"

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
            -d text="🎬 Movie Sync | $msg" \
            -d parse_mode=HTML > /dev/null 2>&1 || true
    fi
}

find_latest_sync_script() {
    # Find by timestamp embedded in filename (not mtime)
    ls -1 "$REPORTS_DIR"/sync_actions_*.sh 2>/dev/null \
        | grep -oP '\d{8}_\d{6}' | sort | tail -1 \
        | xargs -I{} find "$REPORTS_DIR" -name "sync_actions_{}.sh" 2>/dev/null
}

sync_is_complete() {
    local script="$1"
    local progress_file
    progress_file=$(grep -oP 'PROGRESS_FILE="\$\{PROGRESS_FILE:-\K[^}]+' "$script" 2>/dev/null | head -1)
    [ -z "$progress_file" ] && return 1

    local progress_path="$REPORTS_DIR/$progress_file"
    local completed total
    completed=$(wc -l < "$progress_path" 2>/dev/null || echo 0)
    total=$(grep -cP '^run_cmd ' "$script" 2>/dev/null || echo 0)
    [ "$total" -eq 0 ] && return 0
    [ "$completed" -ge "$total" ]
}

run_inventory_and_compare() {
    tg "Starting fresh inventory (Terminus for Ali, local for Chris)..."

    # ── Chris inventory (local) ───────────────────────────────────────────────
    log "Scanning Chris side (${CHRIS_MOVIES_PATH})..."
    cd "$PROJECT_DIR"
    if python3 scripts/generate_inventory.py "$CHRIS_MOVIES_PATH" \
        -o "inventories/chris_movies_1080p" --fast 2>&1; then
        log "Chris inventory done."
    else
        tg "⚠️ Chris inventory failed — skipping compare this cycle"
        return 1
    fi

    # ── Ali inventory via Terminus ────────────────────────────────────────────
    log "Copying scripts to Terminus..."
    ssh "$TERMINUS" "mkdir -p ${REMOTE_TMP}/lib" 2>/dev/null
    scp -q "$SCRIPT_DIR/generate_inventory.py" "${TERMINUS}:${REMOTE_TMP}/"
    scp -q "$SCRIPT_DIR/lib/quality_scoring.py" "${TERMINUS}:${REMOTE_TMP}/lib/"
    ssh "$TERMINUS" "touch ${REMOTE_TMP}/lib/__init__.py" 2>/dev/null

    log "Running Ali inventory on Terminus..."
    if ssh "$TERMINUS" "cd ${REMOTE_TMP} && python3 generate_inventory.py '${ALI_MOVIES_PATH}' -o '${REMOTE_TMP}/ali_movies_1080p' --fast" 2>&1; then
        scp -q "${TERMINUS}:${REMOTE_TMP}/ali_movies_1080p.json" "${INVENTORIES_DIR}/ali_movies_1080p.json"
        scp -q "${TERMINUS}:${REMOTE_TMP}/ali_movies_1080p.csv"  "${INVENTORIES_DIR}/ali_movies_1080p.csv" 2>/dev/null || true
        ssh "$TERMINUS" "rm -rf ${REMOTE_TMP}" 2>/dev/null || true
        log "Ali inventory done — $(python3 -c "import json; d=json.load(open('${INVENTORIES_DIR}/ali_movies_1080p.json')); print(len(d.get('movies',d) if isinstance(d,dict) else d))" 2>/dev/null || echo '?') movies"
    else
        tg "⚠️ Ali inventory on Terminus failed — skipping compare this cycle"
        ssh "$TERMINUS" "rm -rf ${REMOTE_TMP}" 2>/dev/null || true
        return 1
    fi

    # ── Compare ───────────────────────────────────────────────────────────────
    log "Running comparison..."
    cd "$PROJECT_DIR"
    python3 scripts/compare_libraries.py \
        "${INVENTORIES_DIR}/ali_movies_1080p.json" \
        "${INVENTORIES_DIR}/chris_movies_1080p.json" \
        -o "${REPORTS_DIR}" 2>&1

    local new_script
    new_script=$(find_latest_sync_script)
    local task_count=0
    [ -n "$new_script" ] && task_count=$(grep -cP '^run_cmd ' "$new_script" 2>/dev/null || echo 0)
    tg "Comparison done — new script: $(basename "${new_script:-none}") | Tasks: ${task_count}"
    # Write count to file so callers can read it cleanly (avoids log output polluting $() capture)
    echo "$task_count" > /tmp/movie_sync_task_count
}

# ═════════════════════════════════════════════════════════════
# MAIN LOOP
# ═════════════════════════════════════════════════════════════
tg "Movie sync loop started (PARALLEL=${PARALLEL})"

while true; do
    SYNC_SCRIPT=$(find_latest_sync_script)

    if [ -z "$SYNC_SCRIPT" ]; then
        tg "No sync script found — running initial inventory..."
        run_inventory_and_compare
        SYNC_SCRIPT=$(find_latest_sync_script)
    fi

    if [ -z "$SYNC_SCRIPT" ]; then
        log "Still no sync script after inventory — waiting ${RECHECK_INTERVAL}s"
        sleep "$RECHECK_INTERVAL"
        continue
    fi

    TASK_COUNT=$(grep -cP '^run_cmd ' "$SYNC_SCRIPT" 2>/dev/null || echo 0)
    PROGRESS_FILE_NAME=$(grep -oP 'PROGRESS_FILE="\$\{PROGRESS_FILE:-\K[^}]+' "$SYNC_SCRIPT" 2>/dev/null | head -1)
    COMPLETED=$(wc -l < "$REPORTS_DIR/$PROGRESS_FILE_NAME" 2>/dev/null || echo 0)

    if [ "$TASK_COUNT" -gt 0 ] && [ "$COMPLETED" -lt "$TASK_COUNT" ]; then
        REMAINING=$((TASK_COUNT - COMPLETED))
        tg "Syncing: $(basename "$SYNC_SCRIPT") | ${COMPLETED}/${TASK_COUNT} done | ${REMAINING} left | PARALLEL=${PARALLEL}"
        cd "$REPORTS_DIR"
        PARALLEL=$PARALLEL bash "$SYNC_SCRIPT"
        SYNC_EXIT=$?
        tg "Sync run finished (exit ${SYNC_EXIT}) — running fresh inventory to find remaining work"
    else
        tg "Current sync script complete (${COMPLETED}/${TASK_COUNT}) — running inventory for next cycle"
    fi

    # Always re-inventory after a sync run
    run_inventory_and_compare
    NEW_TASK_COUNT=$(cat /tmp/movie_sync_task_count 2>/dev/null || echo 0)

    if [ "${NEW_TASK_COUNT}" -eq 0 ] 2>/dev/null; then
        tg "✅ Libraries appear in sync! Sleeping ${RECHECK_INTERVAL}s before next check..."
        sleep "$RECHECK_INTERVAL"
    else
        log "New tasks found (${NEW_TASK_COUNT}) — looping immediately"
        sleep 5
    fi
done
