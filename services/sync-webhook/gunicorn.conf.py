"""
Gunicorn config for sync-webhook.

The important part is the shutdown hooks. sync-webhook launches rsync in its own
process group (start_new_session=True) from daemon threads. On SIGTERM (autoheal
restart, redeploy, host stop) gunicorn stops the worker, but the rsync *children*
were being orphaned — and when the CIFS mount is slow they sit in uninterruptible
(D-state) I/O, which prevents the container task from ever reporting an exit
("tried to kill container, but did not receive an exit event"). That wedged the
container repeatedly (2026-08).

worker_exit / on_exit fire during gunicorn's own shutdown sequence — the reliable
place to run cleanup, since app-level signal handlers get overridden by gunicorn.
We SIGTERM then SIGKILL the in-progress rsync process groups so they don't orphan.
A genuinely D-state rsync still can't be killed (only the mount-performance fix
prevents that), but this removes the common orphan-wedge cause. graceful_timeout
is bounded so a stuck worker is force-killed instead of hanging the shutdown.
"""
import os
import signal
import sqlite3
import time

bind = "0.0.0.0:5000"
workers = 1                 # single worker: one scheduler; rsync runs in threads
threads = 4
timeout = 3600              # long request timeout for large syncs (unchanged)
graceful_timeout = 25       # don't wait forever for a stuck worker on shutdown

_DB = os.environ.get("SYNC_DB_PATH", "/data/sync_jobs.db")


def _kill_inprogress_rsyncs(log):
    try:
        conn = sqlite3.connect(_DB, timeout=5)
        pids = [r[0] for r in conn.execute(
            "SELECT rsync_pid FROM sync_jobs "
            "WHERE status='in_progress' AND rsync_pid IS NOT NULL")]
        conn.close()
    except Exception as e:  # noqa: BLE001
        try:
            log.warning("shutdown: cannot read rsync pids: %s", e)
        except Exception:
            pass
        return
    if not pids:
        return
    for pid in pids:
        try:
            os.killpg(os.getpgid(pid), signal.SIGTERM)
        except Exception:
            pass
    time.sleep(2)
    for pid in pids:
        try:
            os.killpg(os.getpgid(pid), signal.SIGKILL)
        except Exception:
            pass
    try:
        log.info("shutdown: signalled %d in-progress rsync group(s)", len(pids))
    except Exception:
        pass


def worker_exit(server, worker):
    _kill_inprogress_rsyncs(server.log)


def on_exit(server):
    _kill_inprogress_rsyncs(server.log)
