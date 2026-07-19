#!/usr/bin/env python3
"""
Project Mother - Status Report (every 2 hours)

Shows what matters now that batch sync is complete:
- Webhook sync queue (active/pending/failed jobs)
- Gap scanner (missing episodes found nightly)
- Dedup status (PAUSE_DEDUP sentinel, last run)
- VPN traffic
- Upgraderr quality upgrades

Usage:
    ./daily_report.py              # Send via Apprise
    ./daily_report.py --dry-run   # Print without sending
    ./daily_report.py --console   # Console only
"""

import argparse
import json
import os
import re
import subprocess
import sys
from datetime import datetime, timedelta
from pathlib import Path
from urllib.parse import urlencode
from urllib.request import Request, urlopen, urlopen as _urlopen
from urllib.error import URLError


APPRISE_URL = "http://192.168.1.14:8000/notify/apprise"
APPRISE_TAG = "media"
WEBHOOK_API = "http://localhost:5001"
UPGRADERR_API = "http://localhost:9706"
PAUSE_DEDUP_FILE = "/opt/mother/PAUSE_DEDUP"
DELETED_TV_COUNT_CACHE = "/opt/mother/data/deleted_tv_count.json"
DEDUP_STATUS_FILE = "/opt/mother/configs/sync-webhook/data/dedup_status.json"


# ── helpers ─────────────────────────────────────────────────────────────────

def bytes_to_human(n: int) -> str:
    for unit, threshold in [("TB", 1 << 40), ("GB", 1 << 30), ("MB", 1 << 20)]:
        if n >= threshold:
            return f"{n / threshold:.1f} {unit}"
    return f"{n / 1024:.0f} KB"


def time_ago(dt: datetime) -> str:
    diff = datetime.now() - dt
    s = diff.total_seconds()
    if s < 60:
        return "just now"
    if s < 3600:
        return f"{int(s/60)}m ago"
    if s < 86400:
        return f"{int(s/3600)}h ago"
    return f"{int(s/86400)}d ago"


def api_get(url: str, timeout: int = 5) -> dict | None:
    try:
        with _urlopen(url, timeout=timeout) as r:
            return json.loads(r.read().decode())
    except Exception:
        return None


# ── sync queue (via API) ─────────────────────────────────────────────────────

def get_queue_stats() -> dict:
    """Get sync status from webhook API endpoints."""
    try:
        health = api_get(f"{WEBHOOK_API}/health") or {}
        stats  = api_get(f"{WEBHOOK_API}/stats") or {}

        sync_queue = health.get('sync_queue', {})
        active     = sync_queue.get('active_syncs', 0)
        max_conc   = sync_queue.get('max_concurrent', 12)
        jobs_24h   = health.get('jobs_24h', {})

        return {
            'active': active,
            'max_concurrent': max_conc,
            'success_24h': jobs_24h.get('success', 0),
            'failed_24h': jobs_24h.get('failed', 0),
            'pending': jobs_24h.get('pending', 0),
            'episodes_synced': stats.get('episodes_synced', 0),
            'movies_synced': stats.get('movies_synced', 0),
            'bytes_transferred': stats.get('bytes_transferred', 0),
            'failures_session': stats.get('failures', 0),
            'gap_pending_tv': 0,
            'gap_pending_movie': 0,
            'gap_active_tv': 0,
            'gap_active_movie': 0,
            'last_gap_scan_ts': None,
            'success_2h': 0,
        }
    except Exception as e:
        return {'error': str(e)}


# ── VPN traffic ──────────────────────────────────────────────────────────────

def get_vpn_traffic(snapshots_file: Path) -> dict | None:
    if not snapshots_file.exists():
        return None
    today = datetime.now().strftime('%Y-%m-%d')
    entries = []
    with open(snapshots_file) as f:
        next(f, None)
        for line in f:
            parts = line.strip().split(',')
            if len(parts) >= 5 and parts[1] == today:
                entries.append({'ts': int(parts[0]), 'to': int(parts[3]), 'from': int(parts[4])})
    if len(entries) < 2:
        return None
    first, last = entries[0], entries[-1]
    to_bytes = max(0, last['to'] - first['to']) or last['to']
    fr_bytes = max(0, last['from'] - first['from']) or last['from']
    total = to_bytes + fr_bytes
    hrs = max(1, (last['ts'] - first['ts']) / 3600)
    speed_mbps = (total / (hrs * 3600)) * 8 / 1_000_000
    return {'to': to_bytes, 'fr': fr_bytes, 'total': total, 'mbps': speed_mbps, 'hours': hrs}


# ── upgraderr ────────────────────────────────────────────────────────────────

def get_upgraderr_stats() -> dict | None:
    return api_get(f"{UPGRADERR_API}/api/stats")


# ── deleted TV shows count (from local cache written by restore script) ───────

def get_deleted_tv_count() -> int | None:
    try:
        with open(DELETED_TV_COUNT_CACHE) as f:
            d = json.load(f)
            return d.get('remaining'), d.get('restored'), d.get('ts')
    except Exception:
        return None, None, None


def get_dedup_status() -> dict | None:
    """Read the actual outcome of the last dedup attempt (written by sync-webhook's
    nightly_unraid_dedup on every run/defer/error). Added 2026-07-19 — the previous
    report only checked the PAUSE_DEDUP sentinel, which said "Enabled" every single
    day for 11+ days while dedup was silently deferring daily behind the scenes."""
    try:
        with open(DEDUP_STATUS_FILE) as f:
            return json.load(f)
    except Exception:
        return None


# ── VPN ping status ──────────────────────────────────────────────────────────

def vpn_is_up() -> bool:
    try:
        r = subprocess.run(['ping', '-c', '1', '-W', '3', '192.168.1.10'],
                           capture_output=True, timeout=5)
        return r.returncode == 0
    except Exception:
        return False


# ── report ───────────────────────────────────────────────────────────────────

def generate_report(snapshots_file: Path) -> tuple[str, str, str]:
    now = datetime.now()
    ts = now.strftime('%Y-%m-%d %H:%M')
    lines = [f"Mother — {ts}"]

    # ── Sync Queue ──────────────────────────────────────────────────────────
    stats = get_queue_stats()
    if 'error' not in stats:
        active     = stats['active']
        max_conc   = stats['max_concurrent']
        pending    = stats['pending']
        failed_24  = stats['failed_24h']
        done_24    = stats['success_24h']
        ep_synced  = stats['episodes_synced']
        mv_synced  = stats['movies_synced']
        xfr_bytes  = stats['bytes_transferred']

        lines.append("━━━ Sync Queue ━━━")
        lines.append(f"  Active: {active}/{max_conc} | Pending: {pending} | Done 24h: {done_24} | Failed: {failed_24}")
        if ep_synced or mv_synced:
            xfr = bytes_to_human(xfr_bytes) if xfr_bytes else "0 MB"
            lines.append(f"  This session: {ep_synced} episodes, {mv_synced} movies → {xfr}")
        lines.append("")

    # ── Dedup Status ────────────────────────────────────────────────────────
    lines.append("━━━ Dedup ━━━")
    if os.path.exists(PAUSE_DEDUP_FILE):
        lines.append("  ⏸ PAUSED (PAUSE_DEDUP sentinel active)")
    else:
        dedup_status = get_dedup_status()
        if not dedup_status:
            lines.append("  ⚪ Enabled, but no run recorded yet")
        else:
            outcome = dedup_status.get('outcome')
            reason = dedup_status.get('reason', '')
            try:
                ts = datetime.fromisoformat(dedup_status['timestamp'])
                ago = time_ago(ts)
            except Exception:
                ago = "unknown time"
            if outcome == 'ran':
                deleted = dedup_status.get('deleted', 0)
                freed = bytes_to_human(dedup_status.get('freed_bytes', 0))
                is_dry_run = '[DRY RUN]' in reason
                icon = "🧪" if is_dry_run else "✅"
                tag = " (DRY RUN — nothing actually deleted)" if is_dry_run else ""
                lines.append(f"  {icon} Ran {ago}{tag} — removed {deleted} duplicate(s), freed {freed}")
            elif outcome == 'deferred':
                lines.append(f"  ⏭ Deferred {ago} — {reason}")
            elif outcome == 'blocked':
                lines.append(f"  🚫 BLOCKED {ago} — {reason}")
            elif outcome == 'error':
                lines.append(f"  ❌ Errored {ago} — {reason}")
            else:
                lines.append(f"  ⚪ {outcome} {ago}")
    lines.append("")

    # ── Restoration Progress ────────────────────────────────────────────────
    remaining, restored, cache_ts = get_deleted_tv_count()
    if remaining is not None:
        lines.append("━━━ Deleted TV Restore ━━━")
        total_orig = (remaining or 0) + (restored or 0)
        pct = (restored / total_orig * 100) if total_orig else 0
        lines.append(f"  Restored: {restored:,} | Remaining: {remaining:,} ({pct:.0f}% done)")
        if cache_ts:
            lines.append(f"  Last update: {cache_ts}")
        lines.append("")

    # ── VPN ─────────────────────────────────────────────────────────────────
    up = vpn_is_up()
    vpn_icon = "✅" if up else "❌"
    traffic = get_vpn_traffic(snapshots_file)
    lines.append("━━━ VPN ━━━")
    lines.append(f"  {vpn_icon} {'UP' if up else 'DOWN'} (192.168.1.10)")
    if traffic:
        lines.append(f"  📤 {bytes_to_human(traffic['to'])} | ⚡ {traffic['mbps']:.1f} Mbps avg ({traffic['hours']:.0f}h)")
    lines.append("")

    # ── Upgraderr ───────────────────────────────────────────────────────────
    ustat = get_upgraderr_stats()
    if ustat:
        paused = ustat.get('paused', False)
        icon = "⏸" if paused else "▶"
        searches = ustat.get('searches_today', 0)
        q_total = ustat.get('queue_total', 0)
        tier_counts = ustat.get('tier_counts', {})
        lines.append("━━━ Upgraderr ━━━")
        lines.append(f"  {icon} {'PAUSED' if paused else 'Running'} | Searches today: {searches} | Queue: {q_total}")
        if tier_counts:
            labels = {1: 'm2ts', 2: 'non-MKV', 3: '720p', 4: 'BluRay', 5: 'audio', 6: 'score'}
            parts = [f"T{t}({labels.get(int(t),'?')}): {n}" for t, n in sorted(tier_counts.items(), key=lambda x: int(x[0])) if n > 0]
            if parts:
                lines.append(f"  {' | '.join(parts)}")
        lines.append("")

    title = "Mother Status"
    body = "\n".join(lines)

    has_critical = not up or (stats.get('failed_24h', 0) > 10 if 'error' not in stats else False)
    msg_type = "warning" if has_critical else "info"
    return title, body, msg_type


# ── notification ──────────────────────────────────────────────────────────────

def send_apprise(title: str, body: str, msg_type: str) -> bool:
    try:
        data = urlencode({'title': title, 'body': body, 'type': msg_type}).encode()
        req = Request(f"{APPRISE_URL}?tag={APPRISE_TAG}", data=data, method='POST')
        req.add_header('Content-Type', 'application/x-www-form-urlencoded')
        with urlopen(req, timeout=30) as r:
            return r.status == 200
    except Exception as e:
        print(f"Apprise error: {e}")
        return False


def send_telegram(title: str, body: str) -> bool:
    """Send via Telegram directly (fallback / alternative)."""
    try:
        import urllib.parse
        token = os.environ.get('TELEGRAM_BOT_TOKEN', '')
        chat_id = os.environ.get('TELEGRAM_CHAT_ID', '')
        if not token or not chat_id:
            return False
        text = f"*{title}*\n\n{body}"
        data = urllib.parse.urlencode({'chat_id': chat_id, 'text': text, 'parse_mode': 'Markdown'}).encode()
        req = Request(f"https://api.telegram.org/bot{token}/sendMessage", data=data)
        with urlopen(req, timeout=15) as r:
            return r.status == 200
    except Exception:
        return False


# ── main ─────────────────────────────────────────────────────────────────────

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--snapshots', type=Path, default=Path('/opt/mother/traffic_stats/snapshots.csv'))
    parser.add_argument('--dry-run', '-n', action='store_true')
    parser.add_argument('--console', '-c', action='store_true')
    args = parser.parse_args()

    # Load .env for Telegram credentials
    env_path = Path('/opt/mother/.env')
    if env_path.exists():
        with open(env_path) as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith('#') and '=' in line:
                    k, _, v = line.partition('=')
                    v = v.split('#')[0].strip()
                    os.environ.setdefault(k.strip(), v)

    title, body, msg_type = generate_report(args.snapshots)

    print("=" * 50)
    print(body)
    print("=" * 50)

    if args.console or args.dry_run:
        print(f"\n{'DRY RUN — ' if args.dry_run else ''}Not sending.")
        return

    sent = send_apprise(title, body, msg_type)
    if not sent:
        # Fallback to direct Telegram
        sent = send_telegram(title, body)

    if sent:
        print("✅ Notification sent")
        sys.exit(0)
    else:
        print("❌ Failed to send notification")
        sys.exit(1)


if __name__ == '__main__':
    main()
