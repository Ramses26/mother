#!/usr/bin/env bash
# movie_overnight.sh — Unattended movie sync + inventory + compare + re-sync
# Run in a screen session: screen -S movie bash /opt/mother/scripts/movie_overnight.sh
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
REPORTS_DIR="$PROJECT_DIR/reports"
INVENTORIES_DIR="$PROJECT_DIR/inventories"

# Load env for Telegram creds
set -a; source "$PROJECT_DIR/.env"; set +a

BOT_TOKEN="${TELEGRAM_BOT_TOKEN}"
CHAT_ID="${TELEGRAM_CHAT_ID}"

tg() {
    local msg="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg"
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d chat_id="${CHAT_ID}" \
        -d text="🎬 Movie Overnight | $msg" \
        -d parse_mode=HTML > /dev/null
}

# ──────────────────────────────────────────────
# Step 1 — Re-run existing sync (retries failures)
# ──────────────────────────────────────────────
tg "Starting Step 1: Re-running movie sync (retrying failed transfers)"

cd "$REPORTS_DIR"
PARALLEL=4 bash sync_actions_20260319_182509.sh
SYNC_EXIT=$?

ERRORS=$(grep -c "ERROR" sync_errors_20260319_182509.log 2>/dev/null || echo 0)
tg "Step 1 done (exit $SYNC_EXIT). Error log entries: $ERRORS — starting fresh inventory scan"

# ──────────────────────────────────────────────
# Step 2 — Fresh fast inventory (filename-only, no MediaInfo)
# ──────────────────────────────────────────────
cd "$PROJECT_DIR"

tg "Step 2: Scanning Chris side (/mnt/synology/rs-movies)..."
python3 scripts/generate_inventory.py \
    /mnt/synology/rs-movies \
    -o inventories/chris_movies_1080p \
    --fast
tg "Chris scan done. Scanning Ali side (/mnt/unraid/media/Movies)..."

python3 scripts/generate_inventory.py \
    "/mnt/unraid/media/Movies" \
    -o inventories/ali_movies_1080p \
    --fast
tg "Ali scan done. Running comparison..."

# ──────────────────────────────────────────────
# Step 3 — Compare
# ──────────────────────────────────────────────
python3 scripts/compare_libraries.py \
    inventories/ali_movies_1080p.json \
    inventories/chris_movies_1080p.json \
    -o "$REPORTS_DIR"
COMPARE_EXIT=$?

# Find the newly generated sync script (most recent)
NEW_SYNC=$(ls -t "$REPORTS_DIR"/sync_actions_*.sh 2>/dev/null | head -1)
tg "Comparison done. New sync script: $(basename "$NEW_SYNC" 2>/dev/null || 'none')"

# ──────────────────────────────────────────────
# Step 4 — Run new sync if it has work to do
# ──────────────────────────────────────────────
if [ -n "$NEW_SYNC" ] && [ "$(basename "$NEW_SYNC")" != "sync_actions_20260319_182509.sh" ]; then
    TASK_COUNT=$(grep -c "^run_cmd" "$NEW_SYNC" 2>/dev/null || echo 0)
    tg "Step 4: Running new sync script — $TASK_COUNT tasks"
    cd "$REPORTS_DIR"
    PARALLEL=4 bash "$NEW_SYNC"
    NEW_SYNC_EXIT=$?
    NEW_ERRORS=$(grep -c "ERROR" "$REPORTS_DIR"/sync_errors_*.log 2>/dev/null | tail -1 || echo 0)
    tg "New sync done (exit $NEW_SYNC_EXIT). Errors: $NEW_ERRORS"
else
    tg "Step 4: No new sync tasks — libraries are in sync!"
fi

# ──────────────────────────────────────────────
# Done
# ──────────────────────────────────────────────
tg "✅ All steps complete. Check curatorr.stuttler.net for library status."
echo ""
echo "=== OVERNIGHT RUN COMPLETE ==="
echo "Check $REPORTS_DIR for detailed logs."
