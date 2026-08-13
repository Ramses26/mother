#!/usr/bin/env bash
# Installs the Unraid media mount self-healing units. Run with sudo:
#   sudo /opt/mother/deploy/host/install.sh
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"

install -m 0755 "$SRC/ensure-unraid-mount.sh" /usr/local/bin/ensure-unraid-mount.sh
install -m 0644 "$SRC/unraid-media-mount.service" /etc/systemd/system/unraid-media-mount.service
install -m 0644 "$SRC/unraid-media-mount.timer"   /etc/systemd/system/unraid-media-mount.timer

systemctl daemon-reload
systemctl enable --now unraid-media-mount.timer
# Run once immediately so the mount is ensured right now.
systemctl start unraid-media-mount.service

echo "Installed. Timer status:"
systemctl status unraid-media-mount.timer --no-pager | head -5
