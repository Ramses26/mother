#!/usr/bin/env bash
# Single-attempt "is the Unraid CIFS mount up?" check, driven by
# unraid-media-mount.service (Type=simple, Restart=on-failure).
#
# Why: the IPsec tunnel to Ali's site lives on the gateway (10.0.0.1), NOT on
# Mother, and its public IP is dynamic. After a power outage everything is
# powered back up by hand and the tunnel only re-establishes once the gateway
# picks up its new dynamic IP — which can be well after Mother has finished
# booting. Mother's boot-time fstab mount therefore races the tunnel and fails
# with `mount error(115)`, and a systemd .mount unit does not retry on its own
# (observed 2026-08-12).
#
# This script does ONE attempt and exits:
#   0  -> mounted (or already mounted)         -> service completes, goes quiet
#   1  -> tunnel/mount not up yet              -> systemd retries in 60s
# So it only runs while the share is actually down (i.e. during an outage), and
# stops the moment the tunnel is back and the mount succeeds. There is NO
# steady-state polling once things are healthy.
#
# Pairs with `rslave` bind propagation on the sync-webhook/curatorr volumes: the
# host mount is `shared`, so once this mounts it, it propagates INTO the running
# containers automatically — no container restart needed.
set -u

MP=/mnt/unraid/media
HOST=192.168.1.10
PORT=445

# Already mounted -> success, nothing to do (service will go inactive).
if mountpoint -q "$MP"; then
    exit 0
fi

# Is the tunnel/SMB reachable yet? If not, fail so systemd retries later.
if ! timeout 3 bash -c "cat < /dev/null > /dev/tcp/$HOST/$PORT" 2>/dev/null; then
    echo "unraid-media-mount: $HOST:$PORT unreachable (VPN tunnel down?) — will retry in 60s"
    exit 1
fi

# All mount options come from /etc/fstab (credentials, vers=3.0, _netdev, nofail).
mount "$MP" 2>&1

if mountpoint -q "$MP"; then
    echo "unraid-media-mount: mounted $MP"
    exit 0
fi

echo "unraid-media-mount: reachable but mount of $MP failed — will retry in 60s"
exit 1
