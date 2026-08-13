#!/usr/bin/env bash
# Ensure the Unraid media CIFS mount is up.
#
# Why this exists: the IPsec tunnel to Ali's site lives on the gateway
# (10.0.0.1), NOT on Mother. At boot, Mother's local network-online.target is
# reached before the tunnel/remote Unraid is actually reachable, so the one-shot
# fstab mount attempt fails with `mount error(115): Operation now in progress`
# and — because a systemd .mount unit does not retry — stays failed forever with
# nothing to remount it (observed 2026-08-12). This script, driven by
# unraid-media-mount.timer, retries idempotently: it mounts once Unraid's SMB
# port is reachable, and re-mounts after any later VPN blip that drops the share.
#
# Pairs with the `rslave` bind propagation on the sync-webhook/curatorr volumes
# in docker-compose.yml: the host mount is `shared`, so once this script mounts
# it the mount propagates INTO the already-running containers automatically — no
# container restart needed.
set -u

MP=/mnt/unraid/media
HOST=192.168.1.10
PORT=445

# Already mounted -> nothing to do.
if mountpoint -q "$MP"; then
    exit 0
fi

# Wait (briefly) for the tunnel/SMB to be reachable before attempting a mount.
# If it never comes up this cycle, exit 0 quietly; the timer retries in 2 min.
reachable=0
for _ in $(seq 1 10); do
    if timeout 2 bash -c "cat < /dev/null > /dev/tcp/$HOST/$PORT" 2>/dev/null; then
        reachable=1
        break
    fi
    sleep 2
done

if [ "$reachable" -ne 1 ]; then
    echo "unraid-media-mount: $HOST:$PORT not reachable yet, will retry next cycle"
    exit 0
fi

# All mount options come from /etc/fstab (credentials, vers=3.0, _netdev, nofail).
mount "$MP" 2>&1

if mountpoint -q "$MP"; then
    echo "unraid-media-mount: mounted $MP"
else
    echo "unraid-media-mount: mount of $MP did not succeed, will retry next cycle"
fi

# Always succeed so the unit does not enter a 'failed' state on a transient VPN
# outage; the timer handles retries and sync-webhook /health reports real status.
exit 0
