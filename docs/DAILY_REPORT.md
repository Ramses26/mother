# Daily Report - Project Mother

Unified daily status report combining sync progress and VPN traffic monitoring.

## Overview

The `daily_report.py` script sends a consolidated status report at 8 AM daily via Apprise to the Server Alerts Telegram group. It replaces the separate `batch_sync_report.py` (sync status) and `vpn_monitor.sh report` (VPN stats) notifications.

## What's Included

| Section | Information |
|---------|-------------|
| **Movies Sync** | Progress %, completed/total count, remaining items, running status, last activity |
| **TV Shows Sync** | Progress %, completed/total count, remaining items, running status, last activity |
| **VPN Traffic** | Data sent/received today, total transfer, average speed (Mbps), utilization % |
| **Health** | Error count (only shown if errors > 0) |
| **Overall** | Combined sync progress percentage |

## Sample Report

```
📊 Project Mother - Daily Report
📅 2026-01-30 08:00

━━━ Sync Progress ━━━
🎬 Movies [████████░░░░░░░] 53.2%
   ✅ 2,750 / 5,166 | ⏳ 2,416 left | 🔴
   ⏱️ Last activity: 2h ago

📺 TV Shows [████████████░░░] 81.0%
   ✅ 149 / 184 | ⏳ 35 left | 🟢
   ⏱️ Last activity: 5m ago

━━━ VPN Traffic ━━━
📤 892.45 GB sent | 📥 156.32 GB received
📦 1.02 TB today | ⚡ 142.3 Mbps avg
📈 57.1% utilization (23.0h tracked)

📈 Overall: 2,899/5,350 (54.2%)
```

## Installation on Mother

### 1. Copy Script

```bash
# From your dev machine
scp reports/daily_report.py alig@mother:/opt/mother/reports/

# Or on mother
cp /path/to/daily_report.py /opt/mother/reports/
chmod +x /opt/mother/reports/daily_report.py
```

### 2. Test the Script

```bash
# Dry run (prints report without sending)
/opt/mother/reports/daily_report.py --dry-run

# Console only
/opt/mother/reports/daily_report.py --console

# Verbose mode (shows paths being used)
/opt/mother/reports/daily_report.py --verbose --dry-run

# Actually send notification
/opt/mother/reports/daily_report.py
```

### 3. Update Cron Jobs

```bash
crontab -e
```

**Remove old entries:**
```bash
# DELETE this line:
0 21 * * * /opt/mother/reports/batch_sync_report.py 2>&1 | logger -t batch_sync

# DELETE this line (if present):
0 8 * * * /opt/mother/vpn_monitor.sh report >> /var/log/mother_vpn.log 2>&1
```

**Add new entries:**
```bash
# Project Mother - VPN Traffic Monitor (hourly snapshots)
0 * * * * /opt/mother/vpn_monitor.sh snapshot >> /var/log/mother_vpn.log 2>&1

# Project Mother - Daily Report (8 AM)
0 8 * * * /opt/mother/reports/daily_report.py >> /var/log/mother_daily_report.log 2>&1
```

### 4. Verify Cron

```bash
crontab -l | grep -E "(vpn_monitor|daily_report)"
```

Expected output:
```
0 * * * * /opt/mother/vpn_monitor.sh snapshot >> /var/log/mother_vpn.log 2>&1
0 8 * * * /opt/mother/reports/daily_report.py >> /var/log/mother_daily_report.log 2>&1
```

## Configuration

### Paths

The script uses these default paths:

| Setting | Default | Description |
|---------|---------|-------------|
| Scripts directory | `/opt/mother/reports` | Location of sync scripts and progress files |
| Snapshots file | `/opt/mother/traffic_stats/snapshots.csv` | VPN traffic data from vpn_monitor.sh |

Override via command line:
```bash
./daily_report.py --scripts-dir /custom/path --snapshots /custom/snapshots.csv
```

### Notification

Notifications are sent via Apprise on Terminus:
- **URL:** `http://192.168.1.14:8000/notify/apprise`
- **Tag:** `servers` (Server Alerts Telegram group)

To change these, edit the constants at the top of `daily_report.py`:
```python
APPRISE_URL = "http://192.168.1.14:8000/notify/apprise"
APPRISE_TAG = "servers"
```

### Error Threshold

By default, errors are shown only if count > 0. To change:
```python
ERROR_THRESHOLD = 0  # Show if errors > this value
```

## Manual Usage

```bash
# Check status without sending notification
/opt/mother/reports/daily_report.py --console

# Test notification delivery
/opt/mother/reports/daily_report.py --dry-run

# Force send report now
/opt/mother/reports/daily_report.py
```

## Dependencies

- **Python 3.6+** (uses f-strings, pathlib)
- **vpn_monitor.sh** - Must be running hourly snapshots for VPN stats
- **Apprise on Terminus** - For notifications

No external Python packages required (uses only stdlib).

## Related Scripts

| Script | Purpose | Status |
|--------|---------|--------|
| `daily_report.py` | Unified daily report | **Active** - runs at 8 AM |
| `vpn_monitor.sh` | VPN traffic monitoring | **Active** - hourly snapshots only |
| `batch_sync_report.py` | Sync status (legacy) | Deprecated - use for manual checks |
| `sync_status.py` | Detailed sync status | Active - manual use |
| `verify_sync.py` | Verify completed syncs | Active - manual use |

## Troubleshooting

### Report Not Sending

1. **Test Apprise connectivity:**
   ```bash
   curl -X POST "http://192.168.1.14:8000/notify/apprise?tag=servers" \
     -d "title=Test" -d "body=Test message" -d "type=info"
   ```

2. **Check script paths:**
   ```bash
   /opt/mother/reports/daily_report.py --verbose --dry-run
   ```

3. **Check logs:**
   ```bash
   tail -50 /var/log/mother_daily_report.log
   ```

### No VPN Traffic Data

1. **Verify snapshots are being collected:**
   ```bash
   tail -5 /opt/mother/traffic_stats/snapshots.csv
   ```

2. **Check vpn_monitor cron is running:**
   ```bash
   crontab -l | grep vpn_monitor
   ```

3. **Run snapshot manually:**
   ```bash
   sudo /opt/mother/vpn_monitor.sh snapshot
   ```

### Missing Sync Progress

1. **Verify sync scripts exist:**
   ```bash
   ls -la /opt/mother/reports/sync_actions_*.sh
   ls -la /opt/mother/reports/tv_sync_actions_*.sh
   ```

2. **Check progress files:**
   ```bash
   ls -la /opt/mother/reports/*progress*.log
   ```
