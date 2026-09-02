#!/usr/bin/env python3
"""Alert if Backrest hasn't completed a successful backup recently.

WHY THIS EXISTS AS AN ACTIVE CHECK RATHER THAN A LOKI ALERT
-----------------------------------------------------------
On 2026-09-01 Backrest was found to have **never backed up anything**. It had been
running since 2026-03-21, showed as healthy in `docker ps`, and its only recurring
log line was garbage-collecting an empty operation log. No repos, no plans, zero
rows in its oplog.

That failure mode is invisible to log-based alerting *by construction*: a backup
system that is doing nothing produces no error lines to match on. The only
reliable signal is the positive one — "when did a backup last SUCCEED?" — which
has to be polled. Hence this script rather than another rule in
configs/grafana/provisioning/alerting/rules.yaml.

Reads Backrest's oplog SQLite directly (read-only). Alerts to the Mother
Notifications Telegram group, same path as container_watchdog.py.

Cron:  0 9 * * *  /opt/mother/scripts/backup_freshness_check.py
"""
import json
import os
import sqlite3
import sys
import urllib.parse
import urllib.request
from datetime import datetime, timedelta, timezone

OPLOG = "/opt/mother/data/backrest/oplog.sqlite"
CHAT_ID = "-5498616604"          # Mother Notifications
MAX_AGE_HOURS = int(os.environ.get("BACKUP_MAX_AGE_HOURS", "36"))
STATE = "/opt/mother/data/watchdog/backup_freshness.json"
DRY_RUN = os.environ.get("DRY_RUN", "0") == "1"


def _token():
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
        print(f"[dry-run] would notify:\n{text}")
        return
    token = _token()
    if not token:
        print("no telegram token; skipping notify", file=sys.stderr)
        return
    data = urllib.parse.urlencode(
        {"chat_id": CHAT_ID, "text": text, "disable_web_page_preview": "true"}
    ).encode()
    try:
        urllib.request.urlopen(
            f"https://api.telegram.org/bot{token}/sendMessage", data=data, timeout=15)
    except Exception as e:  # noqa: BLE001 - best effort
        print(f"notify failed: {e}", file=sys.stderr)


def last_success():
    """(datetime|None, total_ops). None means no successful backup has EVER run."""
    if not os.path.exists(OPLOG):
        return None, 0
    con = sqlite3.connect(f"file:{OPLOG}?mode=ro", uri=True)
    try:
        total = con.execute("SELECT COUNT(*) FROM operations").fetchone()[0]
        # Verified against a live oplog 2026-09-01. Backrest's OperationStatus:
        # 1=PENDING 2=IN_PROGRESS 3=SUCCESS 4=WARNING 5=ERROR. There is no
        # unix_time_end_ms column -- only start_time_ms.
        #
        # Requiring a non-empty snapshot_id is what makes this meaningful: rows
        # with status=1 are FUTURE scheduled tasks whose start_time_ms is a
        # timestamp in the future, so counting them would make a system that has
        # never backed up look perpetually fresh.
        cols = {r[1] for r in con.execute("PRAGMA table_info(operations)")}
        if not {"start_time_ms", "status", "snapshot_id"} <= cols:
            return None, total
        row = con.execute(
            "SELECT MAX(start_time_ms) FROM operations "
            "WHERE status IN (3, 4) AND snapshot_id != ''"
        ).fetchone()
    finally:
        con.close()
    if not row or not row[0]:
        return None, total
    return datetime.fromtimestamp(row[0] / 1000, tz=timezone.utc), total


def recent_failures(hours=48):
    """Count backup operations that ERRORED recently.

    Staleness alone is not enough: a plan that runs on schedule but fails every
    time produces no new snapshot, so the staleness check only notices once the
    threshold elapses. An explicit error count catches it on the next poll and
    says what actually happened.
    Status 5 = ERROR, 6 = SYSTEM_CANCELLED, 7 = USER_CANCELLED.
    """
    if not os.path.exists(OPLOG):
        return 0
    since = int((datetime.now(timezone.utc) - timedelta(hours=hours)).timestamp() * 1000)
    con = sqlite3.connect(f"file:{OPLOG}?mode=ro", uri=True)
    try:
        return con.execute(
            "SELECT COUNT(*) FROM operations WHERE status IN (5, 6) "
            "AND start_time_ms > ?", (since,)
        ).fetchone()[0]
    except sqlite3.Error:
        return 0
    finally:
        con.close()


def load_state():
    try:
        with open(STATE) as fh:
            return json.load(fh)
    except (OSError, ValueError):
        return {}


def save_state(s):
    os.makedirs(os.path.dirname(STATE), exist_ok=True)
    with open(STATE, "w") as fh:
        json.dump(s, fh)


def main():
    ts, total = last_success()
    state = load_state()
    alerting = state.get("alerting", False)
    now = datetime.now(timezone.utc)

    if ts is None:
        msg = ("🚨 Backup: NO successful backup has ever been recorded.\n"
               f"oplog has {total} operation(s). Backrest may have no repo/plan "
               "configured at all — that exact state went unnoticed from "
               "2026-03-21 to 2026-09-01. Check http://mother:9898")
        ok = False
        age_h = None
    else:
        age_h = (now - ts).total_seconds() / 3600
        ok = age_h <= MAX_AGE_HOURS
        msg = (f"🚨 Backup is stale: last success {age_h:.1f}h ago "
               f"({ts.strftime('%Y-%m-%d %H:%M UTC')}), threshold {MAX_AGE_HOURS}h.\n"
               "Check Backrest at http://mother:9898 and the rest-server container "
               "on the download Synology (10.0.1.203:8500).")

    fails = recent_failures()
    if fails and ok:
        # Snapshots are still landing but something is erroring — worth saying so
        # even though freshness passes.
        msg = (f"⚠️ Backup: {fails} failed/cancelled operation(s) in the last 48h, "
               f"though the last successful snapshot is only {age_h:.1f}h old. "
               "Check http://mother:9898 for which task is failing.")
        ok = False

    if not ok and not alerting:
        notify(msg)
        state["alerting"] = True
    elif ok and alerting:
        notify(f"✅ Backup recovered: last success {age_h:.1f}h ago.")
        state["alerting"] = False

    state["last_check"] = now.isoformat()
    state["last_success"] = ts.isoformat() if ts else None
    save_state(state)
    print(f"last_success={ts} age_h={age_h if age_h is None else round(age_h,1)} "
          f"ops={total} ok={ok}")
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main())
