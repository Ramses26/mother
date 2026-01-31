# VPN Traffic Monitor - Project Mother

> **Note:** The daily VPN report has been consolidated into `daily_report.py` which runs at 8 AM. The vpn_monitor.sh script now only runs hourly snapshots. See [DAILY_REPORT.md](DAILY_REPORT.md) for the unified report.

## Setup

```bash
# 1. Create directory and copy script
sudo mkdir -p /opt/mother
# Copy the script content to /opt/mother/vpn_monitor.sh

# 2. Make executable
sudo chmod +x /opt/mother/vpn_monitor.sh

# 3. Install bc (likely already installed)
sudo apt install -y bc

# 4. Setup iptables rules and take first snapshot
sudo /opt/mother/vpn_monitor.sh setup

# 5. Test that snapshots work
sudo /opt/mother/vpn_monitor.sh status
```

## Cron Setup

The vpn_monitor.sh script should run hourly to collect traffic snapshots. The daily report is handled by `daily_report.py`.

**In root's crontab (`sudo crontab -e`):**
```bash
# Hourly VPN traffic snapshot
0 * * * * /opt/mother/vpn_monitor.sh snapshot >> /var/log/mother_vpn.log 2>&1

# REMOVE the report cron if present - now handled by daily_report.py
# DELETE: 0 8 * * * /opt/mother/vpn_monitor.sh report >> /var/log/mother_vpn.log 2>&1
```

---

## How It Works

| Component        | Details                                   |
| ---------------- | ----------------------------------------- |
| **Apprise URL**  | `http://192.168.1.14:8000/notify/apprise` |
| **Tag**          | `servers` → Server Alerts Telegram group  |
| **Snapshots**    | Every hour at :00                         |
| **Daily Report** | 8:00 AM to Telegram                       |
| **Data Storage** | `/opt/mother/traffic_stats/`              |

---

## Commands

| Command                       | Description            |
| ----------------------------- | ---------------------- |
| `sudo ./vpn_monitor.sh setup` | Initialize (run once)  |
| `./vpn_monitor.sh status`     | Show current stats     |
| `./vpn_monitor.sh test`       | Send test notification |
| `./vpn_monitor.sh report`     | Send report now        |
| `./vpn_monitor.sh history`    | Show daily history     |

---

## Sample Telegram Report
```
📊 Project Mother - Daily VPN Report

📅 Date: 2026-01-29

📤 To Unraid: 892.45 GB
📥 From Unraid: 156.32 GB
📦 Total Today: 1.02 TB

⚡ Avg Speed: 142 Mbps
📈 Utilization: 57%
🎯 Max Capacity: ~1.79 TB/day (166 Mbps)

🔶 Moderate utilization. WireGuard would speed up large transfers.

To Uninstall
# 1. Remove cron jobs
crontab -l | grep -v "vpn_monitor.sh" | crontab -

# 2. Remove iptables rules
sudo iptables -D INPUT -j MOTHER_ACCOUNTING 2>/dev/null
sudo iptables -D OUTPUT -j MOTHER_ACCOUNTING 2>/dev/null
sudo iptables -F MOTHER_ACCOUNTING 2>/dev/null
sudo iptables -X MOTHER_ACCOUNTING 2>/dev/null

# 3. Save iptables (so rules don't come back after reboot)
sudo netfilter-persistent save

# 4. Remove script and data
sudo rm -rf /opt/mother/vpn_monitor.sh
sudo rm -rf /opt/mother/traffic_stats/

# 5. Remove log file
sudo rm -f /var/log/mother_vpn.log

One Liner Version

crontab -l | grep -v "vpn_monitor.sh" | crontab - && \
sudo iptables -D INPUT -j MOTHER_ACCOUNTING 2>/dev/null; \
sudo iptables -D OUTPUT -j MOTHER_ACCOUNTING 2>/dev/null; \
sudo iptables -F MOTHER_ACCOUNTING 2>/dev/null; \
sudo iptables -X MOTHER_ACCOUNTING 2>/dev/null; \
sudo netfilter-persistent save; \
sudo rm -rf /opt/mother/vpn_monitor.sh /opt/mother/traffic_stats/ /var/log/mother_vpn.log && \
echo "✅ VPN Monitor uninstalled"

