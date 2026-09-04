#!/bin/bash
#
# ONE-SHOT Plex maintenance for Nostromo. Scheduled 04:00, i.e. after the 03:30
# backup has finished (that takes ~90s). Removes its OWN cron entry once it
# succeeds, so it runs exactly once; if a safety gate blocks it, the entry stays
# and it simply tries again the next night.
#
# Does two things, both agreed with Ali 2026-09-03:
#
#  1. REFRESH THE EAE CODEC. Plex routes ALL E-AC3 decoding through the Easy
#     Audio Encoder, a helper daemon using a watchfolder under /tmp. It has
#     failed twice in a week (2026-08-30, 2026-09-03) at ~34,000 errors/MINUTE:
#         [aist#0:1/eac3] Error submitting packet to decoder: Invalid data found
#         [eac3_eae]      Cannot group in blocks of 6!
#     Playback fails for that viewer while the server stays up and answers every
#     health check -- so it reads as "Plex is crashing" while nothing looks wrong.
#     Every affected file was [EAC3 5.1], across 12+ titles, so it is not bad media.
#     Ruled out already: /tmp noexec, PrivateTmp, systemd tmp cleanup, a Plex
#     restart mid-burst, and a background analysis job. What remains suspect is the
#     on-disk EAE build: dated 2026-01-28, sitting next to a 2021 zip, against Plex
#     1.43.3. This MOVES it aside (never deletes) so Plex re-downloads the build
#     matching the current server on next use.
#
#  2. APPLY logDebug=0. Already set via the API and persisted to Preferences.xml,
#     but Plex keeps emitting DEBUG until it restarts. Plex was 78% of ALL Loki
#     ingest across the estate (3.48M of 4.44M lines/24h).
#
# Deliberately CONSERVATIVE: it aborts rather than forces. It will not interrupt a
# viewer, and it will not run if the night's backup did not complete -- no point
# touching Plex when the thing that protects it did not run.
#
set -uo pipefail

LOG=/var/log/plex-maintenance.log
PREFS='/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Preferences.xml'
CODECS='/var/lib/plexmediaserver/Library/Application Support/Plex Media Server/Codecs'
BACKUPLOG=/var/log/plexbackup.log
STAMP=$(date '+%Y-%m-%d_%H%M')
CRON_TAG='#PlexEAERefresh'

log() { echo "$(date '+%Y-%b-%d at %H:%M:%S') :: $*" | tee -a "$LOG"; }

[[ $EUID -eq 0 ]] || { echo "must run as root" >&2; exit 1; }
echo "***********" >> "$LOG"

# --- Gate 1: tonight's backup must have completed ---------------------------
if ! grep -q "$(date '+%Y-%b-%d')" "$BACKUPLOG" 2>/dev/null \
   || ! awk -v d="$(date '+%Y-%b-%d')" '$0 ~ d && /Database backup complete/' "$BACKUPLOG" 2>/dev/null | grep -q .; then
    log "DEFER: no 'Database backup complete' for today in $BACKUPLOG. Leaving cron entry in place to retry tomorrow."
    exit 0
fi
log "Gate 1 OK: tonight's backup completed."

# --- Gate 2: nobody may be watching -----------------------------------------
TOKEN=$(grep -oP 'PlexOnlineToken="\K[^"]+' "$PREFS" 2>/dev/null)
if [[ -z "$TOKEN" ]]; then
    log "DEFER: could not read PlexOnlineToken; refusing to restart blind."
    exit 0
fi
SESSIONS=$(curl -s --max-time 15 "http://127.0.0.1:32400/status/sessions?X-Plex-Token=$TOKEN" \
           | grep -oP 'MediaContainer size="\K[0-9]+' | head -1)
if [[ -z "$SESSIONS" ]]; then
    log "DEFER: could not query sessions (Plex not responding?). Retrying tomorrow."
    exit 0
fi
if [[ "$SESSIONS" -gt 0 ]]; then
    log "DEFER: $SESSIONS active stream(s). Will not interrupt a viewer. Retrying tomorrow."
    exit 0
fi
log "Gate 2 OK: 0 active streams."

# --- Do it ------------------------------------------------------------------
log "Stopping Plex."
systemctl stop plexmediaserver >> "$LOG" 2>&1
sleep 3

DEST="/var/lib/plexmediaserver/eae-backup-$STAMP"
mkdir -p "$DEST"
moved=0
shopt -s nullglob
for d in "$CODECS"/EasyAudioEncoder*; do
    mv -f "$d" "$DEST"/ 2>>"$LOG" && { log "Moved aside: $(basename "$d")"; moved=$((moved+1)); }
done
shopt -u nullglob
if [[ $moved -eq 0 ]]; then
    log "WARNING: no EasyAudioEncoder* entries found in Codecs -- nothing to refresh."
else
    log "Moved $moved EAE item(s) to $DEST (NOT deleted -- restore with mv if needed)."
fi

log "Starting Plex."
systemctl start plexmediaserver >> "$LOG" 2>&1

# --- Verify -----------------------------------------------------------------
ok=0
for i in $(seq 1 30); do
    code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 \
           "http://127.0.0.1:32400/identity?X-Plex-Token=$TOKEN" 2>/dev/null)
    [[ "$code" == "200" ]] && { ok=1; break; }
    sleep 5
done
if [[ $ok -ne 1 ]]; then
    log "ERROR: Plex did not answer /identity within 150s after restart. INVESTIGATE."
    log "       To roll back the codec change:  mv $DEST/* '$CODECS'/ && systemctl restart plexmediaserver"
    exit 1
fi
log "Plex is back and answering (HTTP 200)."

dbg=$(grep -oP 'logDebug="\K[0-9]' "$PREFS" 2>/dev/null)
log "logDebug is now '$dbg' (0 = debug logging off, which this restart applies)."

# --- Self-remove the cron entry so this runs exactly once -------------------
if crontab -l 2>/dev/null | grep -q "$CRON_TAG"; then
    crontab -l 2>/dev/null | grep -v "$CRON_TAG" | crontab -
    log "Removed own cron entry ($CRON_TAG). This was a one-shot."
fi

log "Maintenance complete. Watch {service=\"plex\"} for 'Cannot group in blocks of 6' -- if it"
log "  recurs, the stale EAE build was NOT the cause and the next suspect is the /tmp watchfolder."
echo "***********" >> "$LOG"
