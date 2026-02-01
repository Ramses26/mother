# Project Mother - Operations Guide

**Last Updated**: 2026-02-01

This document covers day-to-day operations, monitoring, alerting, and optimization for Project Mother.

---

## Current Status Overview

### Sync Progress (as of 2026-02-01)
- **Movies**: 17.0% complete (691 / 4,070)
- **TV Shows**: 5.2% complete (2,267 / 43,508)
- **Overall**: 6.2% complete (2,958 / 47,578)

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
# Daily status report at 8 AM
0 8 * * * /opt/mother/reports/daily_report.py >> /opt/mother/logs/daily_report.log 2>&1

# Health check every 10 minutes - restarts dead sync screens
*/10 * * * * /opt/mother/scripts/check-sync-health.sh
```

### NOT Scheduled (Available for Future Use)

| Script | Purpose | Suggested Schedule |
|--------|---------|-------------------|
| `nightly_reconcile.py` | Compare source/dest, find missed files | `0 3 * * *` (3 AM daily) |

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

### Restart a Stuck Sync

```bash
# Kill and restart movie sync
ssh mother 'screen -S movie -X quit'
ssh mother '/opt/mother/scripts/check-sync-health.sh'

# Or manually:
ssh mother 'cd /opt/mother/reports && PARALLEL=8 screen -dmS movie ./sync_actions_20260122_180402.sh'
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
| `/opt/mother/scripts/start-sync-screens.sh` | Start batch sync screens |
| `/opt/mother/scripts/stop-sync-screens.sh` | Stop batch sync screens |
| `/opt/mother/scripts/check-sync-health.sh` | Health monitor (cron) |
| `/opt/mother/scripts/nightly_reconcile.py` | Compare and find missing files |
| `/opt/mother/reports/daily_report.py` | Daily Telegram report |

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
