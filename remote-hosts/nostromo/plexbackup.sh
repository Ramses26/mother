#!/bin/bash
#
# Plex backup for Nostromo (10.0.0.250) -- Chris's Plex server.
#
# Replaces the original script (root crontab `15 5 * * *`, source at
# /home/stutch/plexbackup.sh) which stopped Plex for the ENTIRE duration of a
# 110 GB single-threaded gzip -- measured 75m37s of downtime EVERY night
# (2026-09-02: stopped 05:15:03, started 06:30:40). That is what fires the
# `plex_unreachable` Grafana alert daily, and Tautulli/Tracearr do not backfill,
# so ~75 min of watch history is permanently lost each night.
#
# WHAT ACTUALLY NEEDS BACKING UP (measured on Nostromo 2026-09-02):
#   Plug-in Support/Databases   20 G   <-- the ONLY irreplaceable data.
#                                          main library.db is just 1.36 GB.
#   Metadata                    67 G   regenerable (artwork/posters), slow to refetch
#   Cache                       32 G   regenerable, already excluded
#   Media/localhost             24 G   regenerable thumbnails/bundles
#   ---------------------------------
#   total                      142 G
#
# So the old script took Plex down for 75 minutes to protect 1.36 GB of data.
#
# THIS VERSION -- two tiers:
#   NIGHTLY  stop Plex, copy Databases + Preferences.xml, restart Plex, THEN
#            compress with Plex already back up.  Downtime ~30-60s, not 75m.
#   WEEKLY   (Sun) additionally tar the full app-support dir, hot, with Plex
#            RUNNING -- the artwork is regenerable, so a slightly inconsistent
#            copy is fine and is still far better than refetching it all.
#
# Also fixed vs the original:
#   * pre-flight mount/write/source checks BEFORE stopping Plex (a broken CIFS
#     share must never cost downtime -- this is what bit Hathor for 5 months)
#   * zstd -T0 (16 cores available) instead of single-threaded gzip
#   * retention -- the original had NONE; 14 x ~105 GB = 1.4 TB had accumulated
#   * tar integrity verification (a file existing is not proof of a good backup)
#   * Apprise notifications on success and failure
#   * moved off 05:15 -- Synology Active Backup VM tasks run 05:00 and 06:00
#     against the SAME NAS this writes to
#
# Cron (root):
#   30 3 * * *   /home/stutch/plexbackup.sh
#
set -uo pipefail

plexDatabase="/var/lib/plexmediaserver/Library/Application Support/Plex Media Server"
backupDirectory="/mnt/PLEX"
localLog="/var/log/plexbackup.log"      # always writable, even if CIFS is down
nfsLog="$backupDirectory/logs/buplex.log"

retainDb=14                             # nightly DB backups to keep (~2 weeks)
retainFull=4                            # weekly full backups to keep (~1 month)
fullBackupDay=7                         # 7 = Sunday (date +%u)

appriseUrl="http://10.0.0.162:8000/notify/apprise"
appriseTag="servers"

ts() { date '+%Y-%b-%d at %k:%M:%S'; }

logmsg() {
    local line="$(ts) :: $1"
    echo -e "$line" | tee -a "$localLog"
    echo -e "$line" >> "$nfsLog" 2>/dev/null || true
}

notify() {
    # Best-effort: a notification failure must never break the backup.
    curl -fsS -m 10 -X POST "${appriseUrl}?tag=${appriseTag}" \
        -d "title=$1" -d "body=$2" -d "type=$3" >/dev/null 2>&1 || true
}

if [[ $EUID -ne 0 ]]; then
    echo "This script requires root privileges (run via root's crontab)." >&2
    exit 1
fi

echo "***********" >> "$localLog"

# --- Pre-flight. Never stop Plex for a destination that cannot be written. ---
if ! mountpoint -q "$backupDirectory"; then
    logmsg "ABORT: $backupDirectory is not mounted. Plex was NOT stopped."
    notify "Plex Backup FAILED (Nostromo)" "$backupDirectory is not mounted. Plex was not touched." "failure"
    exit 1
fi

testFile="$backupDirectory/.write_test.$$"
if ! touch "$testFile" 2>>"$localLog"; then
    logmsg "ABORT: $backupDirectory is not writable. Plex was NOT stopped."
    notify "Plex Backup FAILED (Nostromo)" "$backupDirectory is not writable. Plex was not touched." "failure"
    exit 1
fi
rm -f "$testFile"

if [[ ! -d "$plexDatabase" ]]; then
    logmsg "ABORT: source directory missing: $plexDatabase"
    notify "Plex Backup FAILED (Nostromo)" "Source dir missing: $plexDatabase. Plex was not touched." "failure"
    exit 1
fi

# Need room on / for the staging copy of Databases (~20 GB).
availKb=$(df -Pk / | awk 'NR==2{print $4}')
if (( availKb < 40000000 )); then
    logmsg "ABORT: less than 40 GB free on / for staging (${availKb}K available)."
    notify "Plex Backup FAILED (Nostromo)" "Insufficient free space on / to stage the DB copy. Plex was not touched." "failure"
    exit 1
fi

mkdir -p "$backupDirectory/logs"
stamp=$(date '+%Y-%m-%d_%H%M')
staging="/var/tmp/plexbackup.$$"
compressor="zstd -T0 -3"
command -v zstd >/dev/null 2>&1 || compressor="gzip"     # fall back if zstd is ever removed

# ---------------------------------------------------------------------------
# TIER 1 -- nightly. Plex is down ONLY for the local file copy of Databases.
# ---------------------------------------------------------------------------
logmsg "Pre-flight OK. Stopping Plex for database copy."
downStart=$(date +%s)
service plexmediaserver stop >> "$localLog" 2>&1

mkdir -p "$staging"
copyExit=0
cp -a "$plexDatabase/Plug-in Support/Databases" "$staging/Databases" 2>>"$localLog" || copyExit=$?
cp -a "$plexDatabase/Preferences.xml"           "$staging/"          2>>"$localLog" || true

# Plex comes back up immediately -- compression happens with it running.
service plexmediaserver start >> "$localLog" 2>&1
downSec=$(( $(date +%s) - downStart ))
logmsg "Plex restarted. Downtime was ${downSec}s."

if [[ $copyExit -ne 0 ]]; then
    rm -rf "$staging"
    logmsg "Database copy FAILED (exit $copyExit). Plex was restarted."
    notify "Plex Backup FAILED (Nostromo)" "DB copy failed (exit $copyExit) after ${downSec}s downtime. Plex is back up." "failure"
    exit 1
fi

dbOut="$backupDirectory/plexdb-${stamp}.tar.zst"
[[ $compressor == gzip ]] && dbOut="$backupDirectory/plexdb-${stamp}.tar.gz"

tarExit=0
( cd "$staging" && tar -I "$compressor" -cf "$dbOut" . ) >> "$localLog" 2>&1 || tarExit=$?
rm -rf "$staging"

if [[ $tarExit -ne 0 ]]; then
    rm -f "$dbOut"
    logmsg "Database archive FAILED (tar exit $tarExit)."
    notify "Plex Backup FAILED (Nostromo)" "DB archive failed (tar exit $tarExit). Plex is up; downtime was ${downSec}s." "failure"
    exit 1
fi

if ! tar -I "$compressor" -tf "$dbOut" >/dev/null 2>>"$localLog"; then
    logmsg "Database archive failed integrity check: $dbOut"
    notify "Plex Backup FAILED (Nostromo)" "DB archive failed integrity check: $(basename "$dbOut")" "failure"
    exit 1
fi

dbSize=$(du -h "$dbOut" | cut -f1)
logmsg "Database backup complete. Size=$dbSize Downtime=${downSec}s."

# ---------------------------------------------------------------------------
# TIER 2 -- weekly full, taken HOT (Plex stays running).
# ---------------------------------------------------------------------------
fullNote=""
if [[ $(date +%u) -eq $fullBackupDay ]]; then
    logmsg "Sunday: starting full app-support backup (Plex stays running)."
    fullOut="$backupDirectory/buplex-${stamp}.tar.zst"
    [[ $compressor == gzip ]] && fullOut="$backupDirectory/buplex-${stamp}.tar.gz"
    fullStart=$(date +%s)
    fullExit=0
    ( cd "$plexDatabase" && tar -I "$compressor" \
        --exclude='./Cache' \
        --exclude='./Media/localhost' \
        --exclude='./Logs' \
        --exclude='./Crash Reports' \
        --exclude='*-tmp' \
        --exclude='*.backup' \
        --exclude='*-wal' \
        --exclude='*-shm' \
        --warning=no-file-changed \
        -cf "$fullOut" . ) >> "$localLog" 2>&1 || fullExit=$?

    # tar exit 1 = "file changed as we read it", expected on a hot copy of a
    # running Plex and not a failure. Exit 2 is a real error.
    if [[ $fullExit -gt 1 ]]; then
        rm -f "$fullOut"
        logmsg "Full backup FAILED (tar exit $fullExit)."
        notify "Plex Full Backup FAILED (Nostromo)" "tar exited $fullExit. The nightly DB backup DID succeed." "warning"
    else
        fullMin=$(( ($(date +%s) - fullStart) / 60 ))
        fullSize=$(du -h "$fullOut" | cut -f1)
        logmsg "Full backup complete. Size=$fullSize Duration=${fullMin}m (zero downtime)."
        fullNote=" Weekly full: $fullSize in ${fullMin}m, no downtime."
        mapfile -t oldFull < <(ls -1t "$backupDirectory"/buplex-*.tar.* 2>/dev/null | tail -n +$((retainFull + 1)))
        for f in "${oldFull[@]:-}"; do
            [[ -n "$f" ]] || continue
            rm -f "$f"; logmsg "Pruned old full backup: $(basename "$f")"
        done
    fi
fi

# --- Retention for the nightly DB archives ---
mapfile -t oldDb < <(ls -1t "$backupDirectory"/plexdb-*.tar.* 2>/dev/null | tail -n +$((retainDb + 1)))
for f in "${oldDb[@]:-}"; do
    [[ -n "$f" ]] || continue
    rm -f "$f"; logmsg "Pruned old DB backup: $(basename "$f")"
done

notify "Plex Backup OK (Nostromo)" \
       "DB backup $dbSize, Plex downtime ${downSec}s (was ~75 min).${fullNote}" \
       "success"
echo "***********" >> "$localLog"
