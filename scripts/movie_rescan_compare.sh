#!/usr/bin/env bash
# =============================================================================
# movie_rescan_compare.sh — Movie Rescan, Compare, and Restart Sync
#
# Runs fully unattended (designed for screen session):
#   screen -dmS movie_rescan /opt/mother/scripts/movie_rescan_compare.sh
#
# Phases:
#   1. Validate SSH to Terminus
#   2. Detect Terminus movie path
#   3. Parallel inventory scans (local + remote)
#   4. Wait for both scans to finish
#   5. Fetch remote inventory
#   6. Compare libraries → generate sync script
#   7. Start new movie sync screen
#   8. Send Telegram notification
# =============================================================================

set -euo pipefail

# ── Config ──────────────────────────────────────────────────────────────────
MOTHER_MOVIES_PATH="/mnt/synology/rs-movies"
INVENTORIES_DIR="/opt/mother/inventories"
REPORTS_DIR="/opt/mother/reports"
SCRIPTS_DIR="/opt/mother/scripts"
LOG_FILE="/opt/mother/logs/movie_rescan_compare.log"
APPRISE_URL="http://192.168.1.14:8000/notify/apprise"
APPRISE_TAG="media"

# Remote (Terminus)
TERMINUS_HOST="terminus"
TERMINUS_SCRIPTS_DIR="/home/alig/mother_scripts"
TERMINUS_INVENTORIES_DIR="/home/alig/mother_inventories"

# Candidate paths for Ali's movie library on Terminus (checked in order)
TERMINUS_MOVIE_PATHS=(
    "/mnt/unraid/media/Movies"
    "/mnt/media/Movies"
    "/mnt/user/Media/Movies"
    "/mnt/user/media/Movies"
    "/mnt/media/movies"
)

# Scan screen session names
LOCAL_SCREEN="mother_chris_movies_1080p"
REMOTE_SCREEN="terminus_ali_movies_1080p"

# ── Helpers ──────────────────────────────────────────────────────────────────
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

notify() {
    local title="$1"
    local body="$2"
    local type="${3:-info}"
    log "NOTIFY: $title"
    curl -s -X POST "${APPRISE_URL}?tag=${APPRISE_TAG}" \
        --data-urlencode "title=${title}" \
        --data-urlencode "body=${body}" \
        --data-urlencode "type=${type}" \
        -o /dev/null || log "WARNING: Apprise notification failed"
}

die() {
    log "ERROR: $*"
    notify "Movie Rescan FAILED" "$*" "failure"
    exit 1
}

heartbeat_notify() {
    notify "Movie Rescan: Scan In Progress" \
        "Inventory scans still running...\nLocal: $(screen -ls | grep -c "$LOCAL_SCREEN" || echo 0) active\nCheck: screen -r movie_rescan" \
        "info"
}

# ── Setup ────────────────────────────────────────────────────────────────────
mkdir -p "$(dirname "$LOG_FILE")" "$INVENTORIES_DIR"
log "============================================================"
log "Movie Rescan & Compare starting"
log "============================================================"

# ── Phase 1: Validate SSH to Terminus ────────────────────────────────────────
log "Phase 1: Testing SSH to Terminus..."
if ! ssh -o BatchMode=yes -o ConnectTimeout=10 "$TERMINUS_HOST" echo "SSH_OK" &>/dev/null; then
    die "Cannot SSH to Terminus ($TERMINUS_HOST). Add Mother's public key to Terminus:
  echo \"$(cat /home/alig/.ssh/id_ed25519.pub)\" >> ~/.ssh/authorized_keys"
fi
log "SSH to Terminus: OK"

# ── Phase 2: Detect Terminus movie path ──────────────────────────────────────
log "Phase 2: Detecting Terminus movie path..."
TERMINUS_MOVIES_PATH=""
for candidate in "${TERMINUS_MOVIE_PATHS[@]}"; do
    if ssh -o BatchMode=yes "$TERMINUS_HOST" "test -d '${candidate}'" 2>/dev/null; then
        TERMINUS_MOVIES_PATH="$candidate"
        log "Found Terminus movie path: $TERMINUS_MOVIES_PATH"
        break
    fi
done
if [[ -z "$TERMINUS_MOVIES_PATH" ]]; then
    die "Could not detect movie library path on Terminus. Checked: ${TERMINUS_MOVIE_PATHS[*]}"
fi

# ── Phase 3: Check dependencies on Terminus ──────────────────────────────────
log "Phase 3: Checking Terminus dependencies..."
if ! ssh -o BatchMode=yes "$TERMINUS_HOST" "python3 -c 'import pymediainfo, tqdm, pandas' 2>/dev/null"; then
    log "Installing missing Python packages on Terminus..."
    ssh -o BatchMode=yes "$TERMINUS_HOST" \
        "pip3 install --break-system-packages pymediainfo tqdm pandas 2>&1 | tail -5" \
        | tee -a "$LOG_FILE" || die "Failed to install Python packages on Terminus"
fi

# ── Phase 4: Stage scripts on Terminus ───────────────────────────────────────
log "Phase 4: Staging generate_inventory.py on Terminus..."
ssh -o BatchMode=yes "$TERMINUS_HOST" "mkdir -p $TERMINUS_SCRIPTS_DIR $TERMINUS_INVENTORIES_DIR"
scp -o BatchMode=yes \
    "${SCRIPTS_DIR}/generate_inventory.py" \
    "${TERMINUS_HOST}:${TERMINUS_SCRIPTS_DIR}/" \
    | tee -a "$LOG_FILE" || die "Failed to scp generate_inventory.py to Terminus"
log "Scripts staged on Terminus"

# ── Phase 5: Launch parallel inventory scans ─────────────────────────────────
log "Phase 5: Launching parallel inventory scans..."

# Kill any leftover scan screens
screen -S "$LOCAL_SCREEN" -X quit 2>/dev/null || true
ssh -o BatchMode=yes "$TERMINUS_HOST" "screen -S '$REMOTE_SCREEN' -X quit 2>/dev/null; true" || true
sleep 2

# Local scan (Chris's Synology)
log "Starting LOCAL scan: $MOTHER_MOVIES_PATH → $INVENTORIES_DIR/chris_movies_1080p"
LOCAL_LOG="${INVENTORIES_DIR}/chris_movies_1080p_scan.log"
screen -dmS "$LOCAL_SCREEN" bash -c "
    echo \"[LOCAL SCAN STARTED: \$(date)]\" > '${LOCAL_LOG}'
    python3 '${SCRIPTS_DIR}/generate_inventory.py' \
        '${MOTHER_MOVIES_PATH}' \
        -o '${INVENTORIES_DIR}/chris_movies_1080p' \
        2>&1 | tee -a '${LOCAL_LOG}'
    echo \"[LOCAL SCAN DONE: \$(date)]\" >> '${LOCAL_LOG}'
"

# Remote scan (Ali's Unraid via Terminus)
log "Starting REMOTE scan: Terminus:${TERMINUS_MOVIES_PATH} → ${TERMINUS_INVENTORIES_DIR}/ali_movies_1080p"
REMOTE_LOG="${TERMINUS_INVENTORIES_DIR}/ali_movies_1080p_scan.log"
ssh -o BatchMode=yes "$TERMINUS_HOST" "
    screen -dmS '${REMOTE_SCREEN}' bash -c \"
        echo '[REMOTE SCAN STARTED: \$(date)]' > '${REMOTE_LOG}'
        python3 '${TERMINUS_SCRIPTS_DIR}/generate_inventory.py' \
            '${TERMINUS_MOVIES_PATH}' \
            -o '${TERMINUS_INVENTORIES_DIR}/ali_movies_1080p' \
            2>&1 | tee -a '${REMOTE_LOG}'
        echo '[REMOTE SCAN DONE: \$(date)]' >> '${REMOTE_LOG}'
    \"
"

log "Both scans launched. Waiting for completion..."
notify "Movie Rescan Started" \
    "Scanning both libraries in parallel.\nChris: ${MOTHER_MOVIES_PATH}\nAli: terminus:${TERMINUS_MOVIES_PATH}\n\nFollow progress: screen -r movie_rescan" \
    "info"

# ── Phase 6: Wait for both scans to complete ─────────────────────────────────
log "Phase 6: Waiting for scans to complete..."
LAST_HEARTBEAT=$(date +%s)
HEARTBEAT_INTERVAL=1800  # 30 minutes

while true; do
    LOCAL_RUNNING=0
    REMOTE_RUNNING=0

    screen -ls 2>/dev/null | grep -q "$LOCAL_SCREEN" && LOCAL_RUNNING=1
    ssh -o BatchMode=yes -o ConnectTimeout=10 "$TERMINUS_HOST" \
        "screen -ls 2>/dev/null | grep -q '${REMOTE_SCREEN}' && echo 1 || echo 0" \
        2>/dev/null | grep -q "1" && REMOTE_RUNNING=1 || true

    if [[ $LOCAL_RUNNING -eq 0 && $REMOTE_RUNNING -eq 0 ]]; then
        log "Both scans complete!"
        break
    fi

    NOW=$(date +%s)
    if (( NOW - LAST_HEARTBEAT >= HEARTBEAT_INTERVAL )); then
        local_status=$( [[ $LOCAL_RUNNING -eq 1 ]] && echo "running" || echo "done" )
        remote_status=$( [[ $REMOTE_RUNNING -eq 1 ]] && echo "running" || echo "done" )
        notify "Movie Rescan: Scan In Progress" \
            "Local scan: ${local_status}\nRemote scan: ${remote_status}" "info"
        LAST_HEARTBEAT=$NOW
    fi

    sleep 60
done

# ── Phase 7: Verify output files exist ───────────────────────────────────────
log "Phase 7: Verifying scan outputs..."

LOCAL_JSON="${INVENTORIES_DIR}/chris_movies_1080p.json"
if [[ ! -f "$LOCAL_JSON" ]]; then
    die "Local scan output missing: $LOCAL_JSON\nCheck: $LOCAL_LOG"
fi
CHRIS_COUNT=$(python3 -c "import json; d=json.load(open('${LOCAL_JSON}')); print(len(d))" 2>/dev/null || echo "?")
log "Chris inventory: ${CHRIS_COUNT} files"

REMOTE_JSON_REMOTE="${TERMINUS_INVENTORIES_DIR}/ali_movies_1080p.json"
if ! ssh -o BatchMode=yes "$TERMINUS_HOST" "test -f '${REMOTE_JSON_REMOTE}'"; then
    # Show tail of remote log to help debug
    REMOTE_LOG_TAIL=$(ssh -o BatchMode=yes "$TERMINUS_HOST" "tail -20 '${REMOTE_LOG}' 2>/dev/null || echo 'log not found'")
    die "Remote scan output missing: ${TERMINUS_HOST}:${REMOTE_JSON_REMOTE}\nRemote log tail:\n${REMOTE_LOG_TAIL}"
fi
log "Remote inventory verified on Terminus"

# ── Phase 8: Fetch remote inventory ──────────────────────────────────────────
log "Phase 8: Fetching Ali inventory from Terminus..."
scp -o BatchMode=yes \
    "${TERMINUS_HOST}:${REMOTE_JSON_REMOTE}" \
    "${INVENTORIES_DIR}/ali_movies_1080p.json" \
    || die "Failed to scp ali inventory from Terminus"

ALI_COUNT=$(python3 -c "import json; d=json.load(open('${INVENTORIES_DIR}/ali_movies_1080p.json')); print(len(d))" 2>/dev/null || echo "?")
log "Ali inventory: ${ALI_COUNT} files — fetched to ${INVENTORIES_DIR}/ali_movies_1080p.json"

# ── Phase 9: Compare libraries ───────────────────────────────────────────────
log "Phase 9: Running library comparison..."
COMPARE_OUTPUT="${REPORTS_DIR}"
COMPARE_LOG="${INVENTORIES_DIR}/compare_movies_1080p.log"

cd "$SCRIPTS_DIR"
python3 compare_libraries.py \
    "${INVENTORIES_DIR}/ali_movies_1080p.json" \
    "${INVENTORIES_DIR}/chris_movies_1080p.json" \
    -o "$COMPARE_OUTPUT" \
    2>&1 | tee "$COMPARE_LOG"

# Parse stats from compare output
MISSING_COUNT=$(grep "Copy Chris → Ali:" "$COMPARE_LOG" 2>/dev/null | grep -oP '\d+' | head -1 || echo "?")
UPGRADE_COUNT=$(grep "Replace Ali's" "$COMPARE_LOG" 2>/dev/null | grep -oP '\d+' | head -1 || echo "?")
log "Comparison done — Missing on Ali: ${MISSING_COUNT}, Upgrades: ${UPGRADE_COUNT}"

# ── Phase 10: Find new sync script ───────────────────────────────────────────
log "Phase 10: Finding new sync script..."
NEW_SCRIPT=$(ls -t "${REPORTS_DIR}"/sync_actions_*.sh 2>/dev/null | head -1)
if [[ -z "$NEW_SCRIPT" ]]; then
    die "No sync_actions_*.sh found in $REPORTS_DIR after compare!"
fi
chmod +x "$NEW_SCRIPT"
log "New sync script: $NEW_SCRIPT"

# ── Phase 11: Restart movie sync screen ──────────────────────────────────────
log "Phase 11: Starting movie sync screen..."
screen -S movie -X quit 2>/dev/null && log "Stopped existing movie screen" || true
sleep 2

SYNC_LOG="${INVENTORIES_DIR}/movie_sync_$(date +%Y%m%d_%H%M%S).log"
screen -dmS movie bash -c "
    echo \"[SYNC STARTED: \$(date), PARALLEL=8]\" > '${SYNC_LOG}'
    PARALLEL=8 '${NEW_SCRIPT}' 2>&1 | tee -a '${SYNC_LOG}'
    echo \"[SYNC DONE: \$(date)]\" >> '${SYNC_LOG}'
"
log "Movie sync started in screen 'movie' (PARALLEL=8)"

# ── Phase 12: Final notification ─────────────────────────────────────────────
SCRIPT_NAME=$(basename "$NEW_SCRIPT")
BODY="Chris (Synology): ${CHRIS_COUNT} movies scanned
Ali   (Unraid):   ${ALI_COUNT} movies scanned
Missing on Ali:   ${MISSING_COUNT:-?} movies
Quality upgrades: ${UPGRADE_COUNT:-?} files

New sync script: ${SCRIPT_NAME}
Movie sync screen restarted with PARALLEL=8"

log "Sending final notification..."
notify "Movie Rescan Complete" "$BODY" "success"

log "============================================================"
log "All done! Summary:"
log "  Chris: ${CHRIS_COUNT} movies"
log "  Ali:   ${ALI_COUNT} movies"
log "  Missing: ${MISSING_COUNT}"
log "  Upgrades: ${UPGRADE_COUNT}"
log "  Sync script: ${NEW_SCRIPT}"
log "  Movie sync: running in 'movie' screen"
log "============================================================"
