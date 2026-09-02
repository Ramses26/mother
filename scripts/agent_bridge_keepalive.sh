#!/bin/bash
# Keep scripts/agent_bridge.py running. Cron-based rather than systemd because
# this host has no passwordless sudo, so a system unit can't be installed --
# same reason container_watchdog.py runs from cron.
#
# Cron:  * * * * *  /opt/mother/scripts/agent_bridge_keepalive.sh
#        @reboot    /opt/mother/scripts/agent_bridge_keepalive.sh
#
# Idempotent: exits immediately if the bridge is already listening.
set -uo pipefail

BRIDGE=/opt/mother/scripts/agent_bridge.py
OUT=/opt/mother/data/logs/agent_bridge.out
SENTINEL=/opt/mother/PAUSE_AGENT_BRIDGE

[ -e "$SENTINEL" ] && exit 0          # maintenance switch

# Match on the script BASENAME, not the full path. The bridge may have been
# started as `python3 scripts/agent_bridge.py` (relative) or with the absolute
# path; matching the absolute path missed the relative case and happily started
# a SECOND bridge -- which would double-process every alert. Caught in testing
# 2026-09-01.
#
# "agent_bridge\.py" cannot match this keepalive script's own command line
# (agent_bridge_keepalive.sh), so no self-match guard is needed.
if pgrep -f "agent_bridge\.py" >/dev/null 2>&1; then
    exit 0
fi

mkdir -p "$(dirname "$OUT")"
echo "$(date -Is) keepalive: bridge not running, starting" >> "$OUT"
cd /opt/mother || exit 1
nohup python3 "$BRIDGE" >> "$OUT" 2>&1 &
