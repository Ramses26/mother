#!/bin/bash
#
# restore-terminus.sh — rebuild Terminus from scratch after total loss (disk
# failure, host replacement, etc.). Restores from the Backrest/restic repo
# that lives on Unraid (/mnt/unraid/home/Backups/terminus) -- NOT dependent
# on the Backrest container itself being alive, since in a real disaster it
# won't be. Uses the native `restic` CLI directly against the repo.
#
# ============================================================================
# PREREQUISITES YOU MUST HANDLE MANUALLY BEFORE RUNNING THIS SCRIPT
# ============================================================================
# These cannot be restored FROM the backup, because the backup itself is
# unreachable without them (a bootstrapping problem, not an oversight):
#
#   1. Fresh Ubuntu 24.04 host, Docker + docker compose installed.
#   2. The Unraid CIFS share must be mountable BEFORE this script can reach
#      the backup repo at all:
#        sudo mkdir -p /etc/smbcredentials
#        sudo tee /etc/smbcredentials/unraid <<'CRED'
#        username=<see your password manager>
#        password=<see your password manager>
#        CRED
#        sudo chmod 600 /etc/smbcredentials/unraid
#        sudo mkdir -p /mnt/unraid/home /mnt/unraid/media
#        # add both lines from Terminus's /etc/fstab (see the wiki doc) to
#        # the new host's /etc/fstab, then:
#        sudo mount -a
#   3. RESTIC_PASSWORD (the repo's own encryption password) -- must come
#      from an external durable source (password manager), NOT from inside
#      the backup itself. Terminus's own Backrest config.json has it, but
#      that file is only reachable once you can already open the repo --
#      circular. Export it before running:
#        export RESTIC_PASSWORD='...'
#
# ============================================================================
# What this script does, in order:
#   1. Verify the repo is reachable and RESTIC_PASSWORD is set.
#   2. git clone the Terminus stack repo (tracked config/code).
#   3. restic restore: /secrets, /docker_volumes, /backrest-config,
#      /backrest-ssh (everything the 'terminusbackup' plan covers).
#   4. restic restore: outline + paperless plans (their bind-mounted data,
#      not covered by /docker_volumes since those are bind mounts).
#   5. Print the remaining manual steps (docker compose up, verify).
#
# Nothing here is destructive to an existing running Terminus -- it refuses
# to overwrite a non-empty target directory unless FORCE=1 is set. Meant for
# an empty/fresh host.
set -euo pipefail

REPO="/mnt/unraid/home/Backups/terminus/terminus"
GIT_REMOTE="git@github.com:Ramses26/Terminus.git"
STACK_DIR="/home/alig/terminus"
SECRETS_DIR="/home/alig/secrets"
RESTORE_STAGING="/tmp/terminus-restore-$$"
FORCE="${FORCE:-0}"

log() { echo "[$(date '+%H:%M:%S')] $*"; }
die() { echo "ERROR: $*" >&2; exit 1; }

[[ -n "${RESTIC_PASSWORD:-}" ]] || die "RESTIC_PASSWORD not set -- see prerequisites at the top of this script."
[[ -d "$REPO" ]] || die "$REPO not reachable -- mount the Unraid share first (see prerequisites)."
command -v restic >/dev/null || die "restic not installed (apt install restic)."
command -v docker >/dev/null || die "docker not installed."

if [[ -d "$STACK_DIR" && "$(ls -A "$STACK_DIR" 2>/dev/null)" && "$FORCE" != "1" ]]; then
    die "$STACK_DIR already exists and is non-empty. Set FORCE=1 to proceed anyway (will not delete existing files, restic/git handle merging)."
fi

export RESTIC_REPOSITORY="$REPO"

log "Checking repo integrity (quick check, not a full --read-data pass)..."
restic check --no-lock || die "Repo check failed -- the backup itself may be damaged. Stop and investigate before restoring."

log "Cloning the Terminus stack repo..."
if [[ ! -d "$STACK_DIR/.git" ]]; then
    git clone "$GIT_REMOTE" "$STACK_DIR"
else
    log "  $STACK_DIR/.git already exists, skipping clone (git pull manually if you want latest)."
fi

log "Restoring secrets, docker volumes, and backrest's own config from the 'unraidnfs' repo..."
mkdir -p "$RESTORE_STAGING"
restic restore latest --target "$RESTORE_STAGING" \
    --include /secrets --include /docker_volumes --include /backrest-config --include /backrest-ssh

log "Placing restored files..."
sudo mkdir -p "$SECRETS_DIR"
sudo rsync -a "$RESTORE_STAGING/secrets/" "$SECRETS_DIR/"
sudo mkdir -p /var/lib/docker/volumes
sudo rsync -a "$RESTORE_STAGING/docker_volumes/" /var/lib/docker/volumes/
sudo mkdir -p /opt/backrest/config
sudo rsync -a "$RESTORE_STAGING/backrest-config/" /opt/backrest/config/
mkdir -p "$HOME/.config/backrest/ssh"
rsync -a "$RESTORE_STAGING/backrest-ssh/" "$HOME/.config/backrest/ssh/"

log "Restoring Outline's data (bind mount, separate plan)..."
mkdir -p "$RESTORE_STAGING/outline"
restic restore latest --target "$RESTORE_STAGING/outline-restore" --path /outline-data 2>/dev/null || \
    log "  (outline plan restore skipped/empty -- check manually if Outline is needed)"

log "Restoring Paperless's data (bind mount, separate plan)..."
restic restore latest --target "$RESTORE_STAGING/paperless-restore" \
    --path /opt/paperless/data --path /opt/paperless/export --path /opt/paperless/media 2>/dev/null || \
    log "  (paperless plan restore skipped/empty -- check manually if Paperless is needed)"

log ""
log "=== Restore staged. Remaining manual steps: ==="
log "  1. Move restored Outline/Paperless data from $RESTORE_STAGING/*-restore into their real bind-mount paths (check docker-compose.yml for exact targets)."
log "  2. cd $STACK_DIR && docker compose config   # validate before starting anything"
log "  3. docker compose up -d"
log "  4. Verify each service comes up healthy: docker compose ps"
log "  5. Re-point this host's Alloy/other configs at the correct IPs if the host's own IP changed."
log "  6. Clean up: rm -rf $RESTORE_STAGING"
log ""
log "Staging directory left at $RESTORE_STAGING for you to inspect before moving anything."
