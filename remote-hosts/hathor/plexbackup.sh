#!/bin/bash
#
# Plex backup for Hathor (192.168.1.52) -- Ali's Plex server.
#
# Replaces /home/alig/plexbackup.sh (root crontab `15 2 * * 4`, Thursdays).
#
# That script was itself a big improvement, written 2026-08-28 after the backup
# had failed silently from 2026-03-12 because the Unraid NFS export for this
# share had no `rw` grant. It added pre-flight checks, integrity verification,
# retention and Apprise alerts -- all kept here.
#
# What it did NOT change is the architecture: it still stops Plex for the ENTIRE
# duration of the tar. It reduced the cost by running weekly instead of nightly,
# rather than by shortening the outage.
#
# This version changes the architecture instead, so nightly becomes affordable:
#   NIGHTLY  stop Plex, copy ONLY the live databases, restart Plex, THEN
#            compress with Plex already back up.
#   WEEKLY   (Sun) full app-support tar taken HOT, Plex never stops.
#
# VERIFIED on Nostromo 2026-09-02 with the identical code path:
#   copy of live DBs .... 25 s   <-- the entire downtime window
#   zstd -T0 compress ... 27 s   (Plex UP)
#   integrity verify ...   7 s   (Plex UP)
#   restore test ........ both DBs extracted, PRAGMA integrity_check = ok,
#                         144,150 metadata_items / 123,410 watch rows readable
#
# NOTE for this host: /mnt/plexbackup was ESTALE as of 2026-09-02. The Unraid
# export is correct now (rw is granted to 192.168.1.52), but Hathor's existing
# NFS mount still holds the pre-fix handle -- it needs a remount:
#     sudo umount -l /mnt/plexbackup && sudo mount /mnt/plexbackup
# Until that is done the pre-flight below aborts (correctly, without stopping
# Plex) and sends a failure notification.
#
# Cron (root):
#   30 3 * * *   /home/alig/plexbackup.sh
#
set -uo pipefail

plexDatabase="/var/lib/plexmediaserver/Library/Application Support/Plex Media Server"
backupDirectory="/mnt/plexbackup"
localLog="/var/log/plexbackup.log"      # always writable, even if CIFS is down
nfsLog="$backupDirectory/logs/buplex.log"

# Retention. Deliberately asymmetric: the nightly DB archive is the
# irreplaceable data and is cheap (~3.1 GB each), so keep a month of it. The
# weekly full is 25x bigger and only protects REGENERABLE artwork, so keep two
# -- you would only ever restore the newest; the second exists in case the
# newest is bad. Measured on Nostromo 2026-09-02:
#   30 x 3.1 GB  =  ~94 GB
#    2 x ~82 GB  = ~164 GB
#   ---------------------------
#   total        = ~258 GB   (down from 1.4 TB with no pruning at all)
retainDb=30                             # nightly DB backups to keep (~1 month)
retainFull=2                            # weekly full backups to keep
fullBackupDay=7                         # 7 = Sunday (date +%u)

appriseUrl="http://192.168.1.14:8000/notify/apprise"
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
    notify "Plex Backup FAILED (Hathor)" "$backupDirectory is not mounted. Plex was not touched." "failure"
    exit 1
fi

testFile="$backupDirectory/.write_test.$$"
if ! touch "$testFile" 2>>"$localLog"; then
    logmsg "ABORT: $backupDirectory is not writable. Plex was NOT stopped."
    notify "Plex Backup FAILED (Hathor)" "$backupDirectory is not writable. Plex was not touched." "failure"
    exit 1
fi
rm -f "$testFile"

if [[ ! -d "$plexDatabase" ]]; then
    logmsg "ABORT: source directory missing: $plexDatabase"
    notify "Plex Backup FAILED (Hathor)" "Source dir missing: $plexDatabase. Plex was not touched." "failure"
    exit 1
fi

# Need room on / for the staging copy of the live databases (~4.3 GB).
availKb=$(df -Pk / | awk 'NR==2{print $4}')
if (( availKb < 15000000 )); then
    logmsg "ABORT: less than 15 GB free on / for staging (${availKb}K available)."
    notify "Plex Backup FAILED (Hathor)" "Insufficient free space on / to stage the DB copy. Plex was not touched." "failure"
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

mkdir -p "$staging/Databases"
copyExit=0
# Copy only the LIVE databases. Plex keeps its own dated rolling copies
# (com.plexapp.plugins.library.db-2026-08-20 etc) in the same directory -- those
# are 15.7 GB of the 20 GB and we do not need them, because this script keeps
# $retainDb nightly archives of its own. Skipping them cuts what gets copied
# while Plex is down from 20 GB to 4.25 GB (measured 2026-09-02).
#
# Plex is stopped at this point, so the SQLite files are closed and consistent;
# any -wal/-shm are copied alongside for completeness.
find "$plexDatabase/Plug-in Support/Databases" -maxdepth 1 -type f \
     ! -name '*.db-20??-??-??' -print0 2>>"$localLog" \
  | xargs -0 -r cp -a -t "$staging/Databases" 2>>"$localLog" || copyExit=$?
cp -a "$plexDatabase/Preferences.xml"           "$staging/"          2>>"$localLog" || true

# Plex comes back up immediately -- compression happens with it running.
service plexmediaserver start >> "$localLog" 2>&1
downSec=$(( $(date +%s) - downStart ))
logmsg "Plex restarted. Downtime was ${downSec}s."

if [[ $copyExit -ne 0 ]]; then
    rm -rf "$staging"
    logmsg "Database copy FAILED (exit $copyExit). Plex was restarted."
    notify "Plex Backup FAILED (Hathor)" "DB copy failed (exit $copyExit) after ${downSec}s downtime. Plex is back up." "failure"
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
    notify "Plex Backup FAILED (Hathor)" "DB archive failed (tar exit $tarExit). Plex is up; downtime was ${downSec}s." "failure"
    exit 1
fi

if ! tar -I "$compressor" -tf "$dbOut" >/dev/null 2>>"$localLog"; then
    logmsg "Database archive failed integrity check: $dbOut"
    notify "Plex Backup FAILED (Hathor)" "DB archive failed integrity check: $(basename "$dbOut")" "failure"
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
        notify "Plex Full Backup FAILED (Hathor)" "tar exited $fullExit. The nightly DB backup DID succeed." "warning"
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

notify "Plex Backup OK (Hathor)" \
       "DB backup $dbSize, Plex downtime ${downSec}s (was ~75 min).${fullNote}" \
       "success"
echo "***********" >> "$localLog"
