#!/usr/bin/env python3
"""
Container watchdog — low-noise "is a container down?" detector + auto-heal.

Purpose (replaces Dockhand's noisy start/stop/kill stream):
  * Only alerts when a container that SHOULD be up is genuinely down/broken and
    STAYS that way — never on routine restarts, deploys, or one-shot exits.
  * Best-effort auto-heal: tries to restart a down container itself, on top of
    Docker's own `restart: unless-stopped` policy and the `autoheal` sidecar
    (which restarts `unhealthy` containers). This is the third safety net for
    the cases those two miss (restart policy exhausted, stuck `exited`).

How it stays quiet:
  * A container must be bad on TWO consecutive runs (>= GRACE) before it pages —
    that gives the restart policy / autoheal time to recover a transient blip.
  * One alert per incident (dedup via state file), plus one "recovered" message.
  * Only watches containers with restart policy always/unless-stopped (skips
    one-shots). On Mother today that's every service.

Runs from cron every few minutes on the Mother host (has docker + no sudo).
Notifies the "Mother Notifications" Telegram group. Set DRY_RUN=1 to preview.
"""
import json
import os
import subprocess
import sys
import urllib.parse
import urllib.request
from datetime import datetime, timezone

STATE_FILE = "/opt/mother/data/watchdog/state.json"
DRY_RUN = os.environ.get("DRY_RUN", "0") == "1"
MAX_HEAL_ATTEMPTS = 3          # stop trying to restart after this many, keep the alert up
WATCH_POLICIES = {"always", "unless-stopped"}
CHAT_ID = "-5498616604"        # Mother Notifications group


def _env_token():
    # Read TELEGRAM_BOT_TOKEN from /opt/mother/.env without extra deps.
    try:
        with open("/opt/mother/.env") as fh:
            for line in fh:
                if line.startswith("TELEGRAM_BOT_TOKEN="):
                    return line.split("=", 1)[1].strip().strip('"').strip("\r")
    except OSError:
        pass
    return os.environ.get("TELEGRAM_BOT_TOKEN", "")


def notify(text):
    if DRY_RUN:
        print(f"[dry-run] would notify: {text}")
        return
    token = _env_token()
    if not token:
        print("no telegram token; skipping notify", file=sys.stderr)
        return
    data = urllib.parse.urlencode({"chat_id": CHAT_ID, "text": text,
                                   "disable_web_page_preview": "true"}).encode()
    try:
        urllib.request.urlopen(
            f"https://api.telegram.org/bot{token}/sendMessage", data=data, timeout=15)
    except Exception as e:  # noqa: BLE001 - best effort, don't crash the watchdog
        print(f"notify failed: {e}", file=sys.stderr)


def docker(*args):
    return subprocess.run(["docker", *args], capture_output=True, text=True, timeout=60)


def inspect_all():
    """Return {name: {policy, state, health, exit_code}} for every container."""
    res = docker("ps", "-a", "--format", "{{.Names}}")
    if res.returncode != 0:
        print(f"docker ps failed: {res.stderr}", file=sys.stderr)
        sys.exit(1)
    names = [n for n in res.stdout.split() if n]
    out = {}
    fmt = ("{{.HostConfig.RestartPolicy.Name}}|{{.State.Status}}|"
           "{{if .State.Health}}{{.State.Health.Status}}{{else}}-{{end}}|"
           "{{.State.ExitCode}}|{{.RestartCount}}")
    for name in names:
        r = docker("inspect", "-f", fmt, name)
        if r.returncode != 0:
            continue
        policy, state, health, code, rc = (r.stdout.strip().split("|") + [""] * 5)[:5]
        try:
            rc = int(rc)
        except ValueError:
            rc = 0
        out[name] = {"policy": policy, "state": state, "health": health,
                     "exit_code": code, "restart_count": rc}
    return out


LOOP_DELTA = 3  # restart-policy restarts between checks that mean "crash-looping"


def bad_reason(info, prev):
    """Return a human reason string if the container is genuinely bad, else None."""
    if info["state"] in ("exited", "dead", "paused"):
        return describe(info)
    if info["state"] == "restarting":
        return "RESTARTING (crash-looping)"
    if info["state"] == "running" and info["health"] == "unhealthy":
        return "running but UNHEALTHY"
    # Fast crash-loop can flicker through 'running' — catch it via restart deltas.
    prev_rc = prev.get("restart_count")
    if prev_rc is not None and info["restart_count"] - prev_rc >= LOOP_DELTA:
        return (f"CRASH-LOOPING ({info['restart_count'] - prev_rc} restarts "
                f"since last check)")
    return None


def describe(info):
    s = info["state"]
    if s == "running" and info["health"] == "unhealthy":
        return "running but UNHEALTHY"
    if s == "exited":
        return f"EXITED (code {info['exit_code']})"
    return s.upper()


def try_heal(name, info, st):
    """Best-effort restart. Returns True if a heal action was taken."""
    attempts = st.get("heal_attempts", 0)
    if attempts >= MAX_HEAL_ATTEMPTS:
        return False
    # Don't fight Docker while it's already restarting the container itself.
    if info["state"] == "restarting":
        return False
    action = "start" if info["state"] in ("exited", "dead") else "restart"
    if DRY_RUN:
        print(f"[dry-run] would docker {action} {name}")
    else:
        docker(action, name)
    st["heal_attempts"] = attempts + 1
    return True


def main():
    # Maintenance escape hatch (matches PAUSE_DEDUP / PAUSE_SYNC convention):
    # create this file before deliberately stopping containers so the watchdog
    # doesn't fight the operator or page for an intentional stop.
    if os.path.exists("/opt/mother/PAUSE_WATCHDOG"):
        print("PAUSE_WATCHDOG present — skipping run")
        return
    os.makedirs(os.path.dirname(STATE_FILE), exist_ok=True)
    try:
        with open(STATE_FILE) as fh:
            state = json.load(fh)
    except (OSError, ValueError):
        state = {}

    now = datetime.now(timezone.utc).isoformat()
    containers = inspect_all()
    new_state = {}

    for name, info in sorted(containers.items()):
        if info["policy"] not in WATCH_POLICIES:
            continue  # one-shot / manually-managed — not our concern
        prev = state.get(name, {})
        reason = bad_reason(info, prev)

        if reason:
            st = {
                "bad": True,
                "restart_count": info["restart_count"],
                "since": prev.get("since", now),
                "alerted": prev.get("alerted", False),
                "heal_attempts": prev.get("heal_attempts", 0),
                "status": reason,
            }
            try_heal(name, info, st)
            # Alert only once per incident, and only after it's been bad across
            # >=2 runs — lets the restart policy / autoheal recover a blip first.
            if prev.get("bad") and not st["alerted"]:
                heal_note = (f" — auto-heal attempted ({st['heal_attempts']}/"
                             f"{MAX_HEAL_ATTEMPTS})" if st["heal_attempts"] else "")
                notify(f"🔴 Mother: container {name} is {reason}{heal_note}. "
                       f"Bad since {st['since'][:19]}Z.")
                st["alerted"] = True
            new_state[name] = st
        else:
            # Healthy now — if we'd alerted it was down, send an all-clear.
            if prev.get("alerted"):
                notify(f"🟢 Mother: container {name} recovered — now "
                       f"{describe(info)}.")
            # Keep a restart_count baseline so crash-loop deltas work next run.
            new_state[name] = {"bad": False, "restart_count": info["restart_count"]}

    with open(STATE_FILE, "w") as fh:
        json.dump(new_state, fh, indent=2)

    bad_now = [n for n, s in new_state.items() if s.get("bad")]
    print(f"{now} checked={len(containers)} watched-bad={len(bad_now)} "
          f"{'(' + ','.join(bad_now) + ')' if bad_now else ''}")


if __name__ == "__main__":
    main()
