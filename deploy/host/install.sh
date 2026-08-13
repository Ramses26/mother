#!/usr/bin/env bash
# Installs (or updates) the Unraid media mount self-healing unit. Run with sudo:
#   sudo /opt/mother/deploy/host/install.sh
# Idempotent — safe to re-run. Also cleans up the retired timer from the earlier
# 2-minute-polling design if it's still present.
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"

# Remove the retired timer (old design polled every 2 min; replaced by a
# retry-only-while-down service).
if systemctl list-unit-files unraid-media-mount.timer >/dev/null 2>&1; then
    systemctl disable --now unraid-media-mount.timer 2>/dev/null || true
fi
rm -f /etc/systemd/system/unraid-media-mount.timer

install -m 0755 "$SRC/ensure-unraid-mount.sh" /usr/local/bin/ensure-unraid-mount.sh
install -m 0644 "$SRC/unraid-media-mount.service" /etc/systemd/system/unraid-media-mount.service

systemctl daemon-reload
systemctl enable unraid-media-mount.service
# Kick it once now so the mount is ensured immediately (no-op if already mounted).
systemctl restart unraid-media-mount.service || true

echo "Installed. Service state:"
systemctl status unraid-media-mount.service --no-pager | head -6
