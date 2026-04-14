#!/usr/bin/env bash
# ali_inventory_via_terminus.sh
# SSH into Terminus, run the Ali movies inventory scan locally (direct NFS access),
# copy the result back to Mother, then run the comparison + generate a new sync script.
#
# Usage: bash /opt/mother/scripts/ali_inventory_via_terminus.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
INVENTORIES_DIR="$PROJECT_DIR/inventories"
REPORTS_DIR="$PROJECT_DIR/reports"

TERMINUS="terminus"
REMOTE_TMP="/tmp/mother_inventory"
ALI_MOVIES_PATH="/mnt/unraid/media/Movies"
OUTPUT_BASE="ali_movies_1080p"

# Load env for Telegram creds (ignore errors from comment lines in .env)
set +e; set -a; source "$PROJECT_DIR/.env" 2>/dev/null; set +a; set -e
BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
CHAT_ID="${TELEGRAM_CHAT_ID:-}"

tg() {
    local msg="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg"
    if [ -n "$BOT_TOKEN" ] && [ -n "$CHAT_ID" ]; then
        curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
            -d chat_id="${CHAT_ID}" \
            -d text="🎬 Ali Inventory | $msg" \
            -d parse_mode=HTML > /dev/null
    fi
}

tg "Starting Ali movies inventory scan via Terminus"

# ── Step 1: Copy scripts to Terminus ─────────────────────────────────────────
tg "Copying inventory scripts to Terminus..."
ssh "$TERMINUS" "mkdir -p ${REMOTE_TMP}/lib"
scp -q "$SCRIPT_DIR/generate_inventory.py" "${TERMINUS}:${REMOTE_TMP}/"
scp -q "$SCRIPT_DIR/lib/quality_scoring.py" "${TERMINUS}:${REMOTE_TMP}/lib/"
# Create an __init__.py so lib is importable
ssh "$TERMINUS" "touch ${REMOTE_TMP}/lib/__init__.py"

# ── Step 2: Run the fast inventory scan on Terminus ──────────────────────────
tg "Running fast inventory scan on Terminus (${ALI_MOVIES_PATH})..."
ssh "$TERMINUS" "cd ${REMOTE_TMP} && python3 generate_inventory.py '${ALI_MOVIES_PATH}' -o '${REMOTE_TMP}/${OUTPUT_BASE}' --fast" 2>&1

tg "Inventory scan complete. Copying results back to Mother..."

# ── Step 3: Copy inventory files back to Mother ───────────────────────────────
scp -q "${TERMINUS}:${REMOTE_TMP}/${OUTPUT_BASE}.json" "${INVENTORIES_DIR}/${OUTPUT_BASE}.json"
# Copy CSV too if it exists
scp -q "${TERMINUS}:${REMOTE_TMP}/${OUTPUT_BASE}.csv" "${INVENTORIES_DIR}/${OUTPUT_BASE}.csv" 2>/dev/null || true

ITEM_COUNT=$(python3 -c "import json; d=json.load(open('${INVENTORIES_DIR}/${OUTPUT_BASE}.json')); print(len(d.get('movies', d) if isinstance(d, dict) else d))" 2>/dev/null || echo "?")
tg "Copied ${ITEM_COUNT} movie entries. Running comparison..."

# ── Step 4: Run comparison on Mother ─────────────────────────────────────────
cd "$PROJECT_DIR"
python3 scripts/compare_libraries.py \
    "${INVENTORIES_DIR}/${OUTPUT_BASE}.json" \
    "${INVENTORIES_DIR}/chris_movies_1080p.json" \
    -o "${REPORTS_DIR}"
COMPARE_EXIT=$?

# Find the newly generated sync script
NEW_SYNC=$(ls -t "${REPORTS_DIR}"/sync_actions_*.sh 2>/dev/null | head -1)
tg "Comparison done (exit ${COMPARE_EXIT}). New sync script: $(basename "${NEW_SYNC}" 2>/dev/null || echo 'none')"

# ── Step 5: Run new sync if it has work ──────────────────────────────────────
if [ -n "$NEW_SYNC" ]; then
    TASK_COUNT=$(grep -c "^run_cmd" "$NEW_SYNC" 2>/dev/null || echo 0)
    if [ "$TASK_COUNT" -gt 0 ]; then
        tg "Step 5: Running new sync — ${TASK_COUNT} tasks (PARALLEL=4)"
        cd "$REPORTS_DIR"
        PARALLEL=4 bash "$NEW_SYNC"
        NEW_SYNC_EXIT=$?
        tg "Sync complete (exit ${NEW_SYNC_EXIT}). Check curatorr.stuttler.net for status."
    else
        tg "Step 5: Sync script has 0 tasks — libraries are in sync!"
    fi
else
    tg "Step 5: No sync script generated."
fi

# ── Cleanup on Terminus ───────────────────────────────────────────────────────
ssh "$TERMINUS" "rm -rf ${REMOTE_TMP}" 2>/dev/null || true

tg "✅ All done."
echo ""
echo "=== Ali inventory via Terminus complete ==="
echo "Inventory: ${INVENTORIES_DIR}/${OUTPUT_BASE}.json"
echo "Latest sync script: ${NEW_SYNC:-none}"
