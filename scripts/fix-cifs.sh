#!/usr/bin/env bash
# fix-cifs.sh — Kill stuck rsync processes + remount the CIFS share
# Usage: sudo /opt/mother/scripts/fix-cifs.sh
# Add NOPASSWD rule via: sudo visudo -f /etc/sudoers.d/mother-fix-cifs
#   alig ALL=(ALL) NOPASSWD: /opt/mother/scripts/fix-cifs.sh

set -euo pipefail

MOUNT_POINT="/mnt/unraid/media"

echo "[fix-cifs] $(date -u '+%Y-%m-%dT%H:%M:%SZ') Starting CIFS recovery"

# Kill stuck rsync processes holding the mount
STUCK_PIDS=$(ps aux | grep rsync | grep "${MOUNT_POINT}" | awk '{print $2}' 2>/dev/null || true)
if [ -n "$STUCK_PIDS" ]; then
    echo "[fix-cifs] Killing stuck rsync PIDs: $STUCK_PIDS"
    kill -9 $STUCK_PIDS 2>/dev/null || true
    sleep 2
fi

# Lazy unmount + remount
echo "[fix-cifs] Unmounting $MOUNT_POINT (lazy)"
umount -l "$MOUNT_POINT" 2>/dev/null || true
sleep 2

echo "[fix-cifs] Mounting $MOUNT_POINT"
mount "$MOUNT_POINT"

# Verify
if timeout 5 ls "$MOUNT_POINT" &>/dev/null; then
    echo "[fix-cifs] OK — $MOUNT_POINT is accessible"
    exit 0
else
    echo "[fix-cifs] FAILED — $MOUNT_POINT still not accessible"
    exit 1
fi
