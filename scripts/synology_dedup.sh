#!/bin/bash
#==============================================================================
# Synology Dedup Scan - Project Mother
#
# Scans all 4 Synology paths for duplicate media files using TRaSH quality
# scoring. Generates cleanup_actions_*.sh scripts (DRY_RUN=true by default).
#
# Usage:
#   screen -dmS synology_dedup /opt/mother/scripts/synology_dedup.sh
#   # Then: screen -r synology_dedup
#
# After reviewing reports:
#   DRY_RUN=false /opt/mother/reports/dedup/YYYYMMDD_HHMMSS/cleanup_actions_TIMESTAMP.sh
#
# WARNING: Do NOT run cleanup while tvsync screen is still running.
#==============================================================================

set -euo pipefail

TIMESTAMP=$(date '+%Y%m%d_%H%M%S')
OUTDIR="/opt/mother/reports/dedup/${TIMESTAMP}"
LOG="${OUTDIR}/dedup_scan.log"
SCRIPTS_DIR="/opt/mother/scripts"

# Load env for Telegram (only valid KEY=VALUE lines, skip comments/blanks)
if [ -f /opt/mother/.env ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ "$line" =~ ^[[:space:]]*$ ]] && continue
        [[ "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*= ]] && export "$line" 2>/dev/null || true
    done < /opt/mother/.env
fi

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

parse_report() {
    local report_file="$1"
    local groups=0
    local files=0
    local gb=0
    if [ -f "$report_file" ]; then
        groups=$(grep "^Groups with duplicates:" "$report_file" | awk '{print $NF}' || echo 0)
        files=$(grep "^Total files to remove:" "$report_file" | awk '{print $NF}' || echo 0)
        gb=$(grep "^Total space to reclaim:" "$report_file" | awk '{print $NF}' || echo 0)
    fi
    echo "${groups}|${files}|${gb}"
}

mkdir -p "$OUTDIR"
log "=== Synology Dedup Scan ==="
log "Output dir: $OUTDIR"

send_telegram "Mother: Dedup scan started on 4 Synology paths
Output: $OUTDIR"

#------------------------------------------------------------------------------
# Define paths to scan
#------------------------------------------------------------------------------
declare -a PATHS=(
    "/mnt/synology/rs-movies"
    "/mnt/synology/rs-tv"
    "/mnt/synology/rs-4kmedia/4kmovies"
    "/mnt/synology/rs-4kmedia/4ktv"
)
declare -a TYPES=(
    "movies"
    "tv"
    "movies"
    "tv"
)
declare -a FLAGS=(
    ""
    ""
    "--4k"
    "--4k"
)
declare -a LABELS=(
    "rs-movies (1080p)"
    "rs-tv (1080p)"
    "rs-4kmedia/4kmovies"
    "rs-4kmedia/4ktv"
)

#------------------------------------------------------------------------------
# Run cleanup_duplicates.py for each path sequentially
#------------------------------------------------------------------------------
cd "$SCRIPTS_DIR"

declare -a STATS=()
declare -a REPORT_FILES=()

for i in "${!PATHS[@]}"; do
    path="${PATHS[$i]}"
    media_type="${TYPES[$i]}"
    flags="${FLAGS[$i]}"
    label="${LABELS[$i]}"

    log ""
    log "--- Scanning: $label ---"
    log "Path: $path"

    if [ ! -d "$path" ]; then
        log "WARNING: Path not found, skipping: $path"
        STATS+=("0|0|0")
        REPORT_FILES+=("")
        continue
    fi

    # Run cleanup_duplicates.py — outputs to OUTDIR
    cmd="python3 cleanup_duplicates.py \"$path\" --type $media_type --delete -o \"$OUTDIR\""
    if [ -n "$flags" ]; then
        cmd="python3 cleanup_duplicates.py \"$path\" --type $media_type $flags --delete -o \"$OUTDIR\""
    fi

    log "Running: $cmd"
    if eval "$cmd" >> "$LOG" 2>&1; then
        log "Completed: $label"
    else
        log "WARNING: cleanup_duplicates.py exited non-zero for $label (check log)"
    fi

    # Find the most recently generated report for this run
    latest_report=$(ls -t "$OUTDIR"/cleanup_report_*.txt 2>/dev/null | head -1 || true)
    REPORT_FILES+=("${latest_report:-}")

    if [ -n "$latest_report" ]; then
        stat_str=$(parse_report "$latest_report")
        STATS+=("$stat_str")
        gb=$(echo "$stat_str" | cut -d'|' -f3)
        log "Result: $stat_str (groups|files|GB)"
    else
        STATS+=("0|0|0")
        log "No report generated (no duplicates found?)"
    fi
done

#------------------------------------------------------------------------------
# Calculate totals
#------------------------------------------------------------------------------
total_groups=0
total_files=0
total_gb_int=0
total_gb_dec=""

# Use python3 for float addition
total_gb=$(python3 -c "
stats = [$(printf '"%s",' "${STATS[@]}" | sed 's/,$//' )]
total = sum(float(s.split(\"|\")[2]) for s in stats if s)
print(f'{total:.2f}')
" 2>/dev/null || echo "0.00")

for stat in "${STATS[@]}"; do
    g=$(echo "$stat" | cut -d'|' -f1)
    f=$(echo "$stat" | cut -d'|' -f2)
    total_groups=$((total_groups + g))
    total_files=$((total_files + f))
done

#------------------------------------------------------------------------------
# Build summary message
#------------------------------------------------------------------------------
LINE="─────────────────────────────"

summary="Synology Dedup Scan Complete
${LINE}"

for i in "${!LABELS[@]}"; do
    stat="${STATS[$i]}"
    g=$(echo "$stat" | cut -d'|' -f1)
    f=$(echo "$stat" | cut -d'|' -f2)
    gb_val=$(echo "$stat" | cut -d'|' -f3)
    summary="${summary}
$(printf '%-24s' "${LABELS[$i]}"):  ${g} groups, ${f} files, ${gb_val} GB"
done

summary="${summary}
${LINE}
Total to reclaim:     ${total_gb} GB

Scripts in: ${OUTDIR}
Review reports before executing. Wait for tvsync to finish.
Execute: DRY_RUN=false ./cleanup_actions_*.sh (one at a time)"

log ""
log "=== SUMMARY ==="
log "$summary"

send_telegram "$summary"

log ""
log "Dedup scan complete. Reports in: $OUTDIR"
log "Scripts generated:"
ls "$OUTDIR"/cleanup_actions_*.sh 2>/dev/null | while read f; do log "  $f"; done || log "  (none)"
