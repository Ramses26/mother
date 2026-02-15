# Project Mother - Operations Guide

**Last Updated**: 2026-02-14

This document covers day-to-day operations, monitoring, alerting, and optimization for Project Mother.

---

## Current Status Overview

### Sync Progress (as of 2026-02-14)
- **Movies**: Starting fresh sync after duplicate cleanup (3,744 operations)
- **TV Shows**: Starting fresh sync after duplicate cleanup (46,113 operations)
- Duplicate cleanup removed 585 files (~1,814 GB) across both libraries

### Active Components

| Component | Status | Purpose |
|-----------|--------|---------|
| Batch Movie Sync | Running (screen: `movie`) | Initial bulk transfer with PARALLEL=8 |
| Batch TV Sync | Running (screen: `tvsync`) | Initial bulk transfer with PARALLEL=8 |
| sync-webhook | Docker container | Real-time sync for new downloads |
| Daily Report | Cron (8 AM) | Telegram status summary |
| Health Check | Cron (every 10 min) | Auto-restart dead sync screens |

---

## Monitoring & Alerting

### What's Currently Monitored

| Check | Method | Frequency | Alert |
|-------|--------|-----------|-------|
| Sync screen health | `check-sync-health.sh` | Every 10 min | Telegram on restart |
| Daily progress | `daily_report.py` | 8 AM daily | Telegram summary |
| sync-webhook health | Docker healthcheck | Every 30 sec | Docker restart |
| sync-webhook failures | Built-in auto-retry | Every 15 min | Telegram on failure |
| sync-webhook daily summary | Built-in scheduler | 00:05 daily | Telegram summary |
| sync-webhook history scanner | Built-in scheduler | Every 30 min | Catches missed webhooks |

### Telegram Notifications You Receive

1. **Daily Report (8 AM)** - Sync progress, VPN traffic, errors
2. **Sync Webhook Failures** - Immediate alert when rsync fails
3. **Sync Webhook Daily Summary** - Failed titles, items needing attention
4. **Screen Restart Alerts** - When health check restarts a dead screen

### What's NOT Currently Monitored (Future Enhancements)

| Gap | Recommendation | Priority |
|-----|----------------|----------|
| NFS mount failures | Add mount check to health script | Medium |
| VPN tunnel down | Add ping check to daily report | Medium |
| Disk space on Mother | Add df check | Low |
| Docker container crashes | Uptime Kuma or similar | Low |

---

## Scheduled Jobs (Cron)

Current crontab on Mother:
```
# Status report every 2 hours + end-of-day at 11:58 PM
0 0,2,4,6,8,10,12,14,16,18,20,22 * * * /opt/mother/reports/daily_report.py
58 23 * * * /opt/mother/reports/daily_report.py

# Health check every 10 minutes - restarts dead sync screens
*/10 * * * * /opt/mother/scripts/check-sync-health.sh

# VPN ping monitor - every 2 minutes
*/2 * * * * /opt/mother/vpn_ping_monitor.sh

# Sync stall detector - every hour at :30
30 * * * * /opt/mother/sync_stall_check.sh
```

---

## Sync Architecture

### Two Sync Systems Running in Parallel

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           SYNC SYSTEMS                                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  1. BATCH SYNC (Initial Transfer)        2. WEBHOOK SYNC (Ongoing)     │
│  ┌─────────────────────────────┐         ┌─────────────────────────┐   │
│  │ sync_actions_*.sh           │         │ sync-webhook container  │   │
│  │ tv_sync_actions_*.sh        │         │                         │   │
│  ├─────────────────────────────┤         ├─────────────────────────┤   │
│  │ PARALLEL=8                  │         │ SYNC_MAX_CONCURRENT=2   │   │
│  │ (8 concurrent rsyncs)       │         │ (2 concurrent rsyncs)   │   │
│  ├─────────────────────────────┤         ├─────────────────────────┤   │
│  │ Runs in screen sessions     │         │ Triggered by Radarr/    │   │
│  │ Progress tracked in .log    │         │ Sonarr webhooks         │   │
│  │ Skips already-done files    │         │ Jobs stored in SQLite   │   │
│  └─────────────────────────────┘         │ Auto-retry on failure   │   │
│                                          └─────────────────────────┘   │
│  Purpose: Catch up on 160TB              Purpose: Keep up with new     │
│  of existing content                     downloads in real-time        │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

### Why Two Systems?

- **Batch Sync**: Handles the initial 160TB bulk transfer. Uses high parallelism (8) because it's dedicated.
- **Webhook Sync**: Handles new content as it's downloaded. Uses lower parallelism (2) to avoid overwhelming NFS during bulk transfer.

### After Bulk Sync Completes

Once the batch sync finishes (movies and TV both at 100%):
1. **Disable batch sync** - No longer needed
2. **Increase webhook concurrency** - Set `SYNC_MAX_CONCURRENT=4` or `8`
3. **Enable nightly reconcile** - Catch any edge cases

---

## Tuning Parameters

### Batch Sync (sync_actions_*.sh)

| Variable | Current | Range | Notes |
|----------|---------|-------|-------|
| `PARALLEL` | 8 | 1-16 | Higher = faster but more NFS load |
| `DRY_RUN` | false | true/false | Preview mode |
| `EXIT_ON_ERROR` | false | true/false | Stop on first error |

### Webhook Sync (sync-webhook)

| Variable | Current | Recommended After Bulk | Notes |
|----------|---------|------------------------|-------|
| `SYNC_MAX_CONCURRENT` | 2 | 4-8 | Increase after bulk sync completes |
| `SYNC_DRY_RUN` | false | false | Preview mode |
| `SYNC_LOG_LEVEL` | INFO | INFO | DEBUG for troubleshooting |

### How to Increase SYNC_MAX_CONCURRENT

1. Edit `.env` on Mother:
   ```bash
   ssh mother 'echo "SYNC_MAX_CONCURRENT=4" >> /opt/mother/.env'
   ```

2. Or edit docker-compose.yml and redeploy:
   ```yaml
   environment:
     - SYNC_MAX_CONCURRENT=4
   ```

3. Restart container:
   ```bash
   ssh mother 'cd /opt/mother && docker compose up -d sync-webhook'
   ```

---

## VPN Performance

### Current Throughput (IPsec)

Based on traffic snapshots:
- **Average**: ~200-210 Mbps bidirectional
- **Peak observed**: ~300+ Mbps during off-hours
- **Theoretical max** (IPsec on UCG): ~250 Mbps

### Bottleneck Analysis

| Component | Theoretical | Observed | Bottleneck? |
|-----------|-------------|----------|-------------|
| Altafiber (both sides) | 800/800 Mbps | N/A | No |
| IPsec on UCG | ~250 Mbps | ~210 Mbps | **Yes** |
| NFS mounts | 1 Gbps+ | N/A | No |
| Synology disk I/O | 500+ MB/s | N/A | No |

### Site Magic Consideration

Site Magic (WireGuard) could improve throughput to 400-600+ Mbps, but:
- Requires account transfer to Chris
- Would affect your AP and switch management
- Bulk sync is 93%+ done - limited benefit now

**Recommendation**: Keep IPsec for now. Consider Site Magic for future projects.

---

## Common Operations

### View Sync Progress

```bash
# Attach to movie sync screen
ssh mother 'screen -r movie'
# Detach: Ctrl+A, D

# Attach to TV sync screen
ssh mother 'screen -r tvsync'

# Quick status
ssh mother '/opt/mother/reports/daily_report.py --dry-run'
```

### Pause/Resume Batch Syncs

Use the sync-control script to pause and resume batch syncs without killing them:

```bash
# Pause syncs (current jobs finish, new ones wait)
ssh mother '/opt/mother/scripts/sync-control.sh pause'

# Resume syncs
ssh mother '/opt/mother/scripts/sync-control.sh resume'

# Check status
ssh mother '/opt/mother/scripts/sync-control.sh status'

# Stop sync screens entirely
ssh mother '/opt/mother/scripts/sync-control.sh stop'

# Start sync screens
ssh mother '/opt/mother/scripts/sync-control.sh start'
```

**How it works:** Creates/removes `/opt/mother/PAUSE_SYNC` file. Sync scripts check this file before starting new transfers.

### Restart a Stuck Sync

```bash
# Kill and restart movie sync
ssh mother 'screen -S movie -X quit'
ssh mother '/opt/mother/scripts/check-sync-health.sh'

# Or use the screen management scripts:
ssh mother '/opt/mother/scripts/stop-sync-screens.sh'
ssh mother '/opt/mother/scripts/start-sync-screens.sh'
# start-sync-screens.sh auto-discovers the most recent sync scripts
```

### Check sync-webhook Status

```bash
# Health endpoint
curl http://10.0.0.162:5001/health

# Recent jobs
curl http://10.0.0.162:5001/jobs?limit=10

# Stats
curl http://10.0.0.162:5001/stats
```

### View Logs

```bash
# Batch sync logs
ssh mother 'tail -100 /opt/mother/logs/movie_sync.log'
ssh mother 'tail -100 /opt/mother/logs/tv_sync.log'

# Webhook sync logs
ssh mother 'docker logs sync-webhook --tail 100'

# Daily report log
ssh mother 'tail -50 /opt/mother/logs/daily_report.log'

# Health check log
ssh mother 'tail -50 /opt/mother/logs/sync-health.log'
```

---

## Optimization Checklist

### Current Status

- [x] Batch sync with PARALLEL=8
- [x] Auto-restart on screen death (health check cron)
- [x] Daily Telegram progress report
- [x] Webhook sync for new content
- [x] Auto-retry for failed webhook syncs
- [ ] Nightly reconciliation (not scheduled)
- [ ] NFS mount monitoring
- [ ] VPN tunnel monitoring

### After Bulk Sync Completes

- [ ] Disable/remove batch sync screens
- [ ] Increase `SYNC_MAX_CONCURRENT` to 4-8
- [ ] Enable `nightly_reconcile.py` in cron
- [ ] Consider Site Magic for future speed needs
- [ ] Review and archive batch sync scripts

---

## Troubleshooting

### Sync Not Making Progress

1. Check if screens are running:
   ```bash
   ssh mother 'screen -ls'
   ```

2. Check NFS mounts:
   ```bash
   ssh mother 'df -h | grep synology'
   ssh mother 'df -h | grep unraid'
   ```

3. Check for errors:
   ```bash
   ssh mother 'tail -50 /opt/mother/reports/sync_errors_*.log'
   ```

### No Telegram Notifications

1. Check .env has credentials:
   ```bash
   ssh mother 'grep TELEGRAM /opt/mother/.env'
   ```

2. Test manually:
   ```bash
   ssh mother '/opt/mother/reports/daily_report.py'
   ```

### Webhook Sync Not Triggering

1. Check container is running:
   ```bash
   ssh mother 'docker ps | grep sync-webhook'
   ```

2. Check webhook is configured in Radarr/Sonarr

3. Test webhook endpoint:
   ```bash
   curl -X POST http://10.0.0.162:5001/test
   ```

---

## Files Reference

### Scripts
| Path | Purpose |
|------|---------|
| `/opt/mother/scripts/start-sync-screens.sh` | Start batch sync screens (auto-discovers latest scripts) |
| `/opt/mother/scripts/stop-sync-screens.sh` | Stop batch sync screens |
| `/opt/mother/scripts/sync-control.sh` | Pause/resume/status for batch syncs |
| `/opt/mother/scripts/check-sync-health.sh` | Health monitor (cron) |
| `/opt/mother/scripts/compare_libraries.py` | Movie library comparison & sync script generation |
| `/opt/mother/scripts/compare_tv_libraries.py` | TV library comparison & sync script generation |
| `/opt/mother/scripts/cleanup_duplicates.py` | Duplicate file cleanup (movies & TV) |
| `/opt/mother/scripts/lib/quality_scoring.py` | Shared TRaSH-aligned quality scoring |
| `/opt/mother/reports/daily_report.py` | Telegram status report (every 2 hours) |

### Logs
| Path | Contents |
|------|----------|
| `/opt/mother/logs/daily_report.log` | Daily report output |
| `/opt/mother/logs/sync-health.log` | Health check results |
| `/opt/mother/logs/sync-autostart.log` | Startup/shutdown events |
| `/opt/mother/logs/movie_sync.log` | Movie batch sync output |
| `/opt/mother/logs/tv_sync.log` | TV batch sync output |

### Progress Files
| Path | Contents |
|------|----------|
| `/opt/mother/reports/sync_progress_*.log` | Completed movie transfers |
| `/opt/mother/reports/tv_sync_progress_*.log` | Completed TV transfers |
| `/opt/mother/reports/sync_errors_*.log` | Movie sync errors |
| `/opt/mother/reports/tv_sync_errors_*.log` | TV sync errors |
