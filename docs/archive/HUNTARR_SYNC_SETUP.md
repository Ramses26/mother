# Huntarr & Sync Optimization Setup

**Last Updated**: 2026-02-05

## Overview

This document covers the integration of Huntarr for automated quality upgrades and the optimized sync strategy that skips upgrade candidates.

## Current State

### Sync Progress (as of setup)
| Library | Total | Previous | Reduction |
|---------|-------|----------|-----------|
| Movies | 3,744 | 4,070 | -8% |
| TV Shows | 19,719 | 43,508 | **-55%** |
| **Total** | **23,463** | 47,578 | **-51%** |

### What's Skipped (Huntarr will upgrade these)
- **720p files**: 19,345 skipped (5,759 Ali + 13,586 Chris)
- **x265 (no HDR) at 1080p**: 6,561 skipped (156 Ali + 6,405 Chris)

## Huntarr Configuration

### Access
- **URL**: http://10.0.0.162:9705
- **Instances**: Radarr HD, Radarr 4K, Sonarr HD, Sonarr 4K

### Current Settings (Conservative)
| Setting | Value | Rationale |
|---------|-------|-----------|
| Missing Search Count | 0 | Disabled during initial sync |
| Upgrade Search Count | 2 | ~32 upgrades/day |
| Sleep Duration | 90 min | Gentle on indexers |
| Max Download Queue | 10 | Pause when queue full |
| Monitored Only | ON | Skip unmonitored items |

### Instance URLs (for Huntarr config)
```
Radarr HD:  http://radarr-hd:7878
Radarr 4K:  http://radarr-4k:7878
Sonarr HD:  http://sonarr-hd:8989
Sonarr 4K:  http://sonarr-4k:8989
```

## Recyclarr Quality Profiles

All profiles have upgrades **enabled**:

### Radarr HD
- HD Bluray + WEB → upgrades to Bluray-1080p
- Remux + WEB 1080p → upgrades to Remux-1080p

### Radarr 4K
- UHD Bluray + WEB → upgrades to Bluray-2160p
- Remux + WEB 2160p → upgrades to Remux-2160p

### Sonarr HD
- WEB-1080p, Bluray-1080p, Remux-1080p → all upgrade enabled

### Sonarr 4K
- Bluray-2160p, Remux-2160p → upgrade enabled

## Compare Libraries Script

### Usage
```bash
# Default: skips 720p and x265-no-HDR at 1080p
python3 scripts/compare_libraries.py ali.json chris.json -o reports/

# Include upgrade candidates (old behavior)
python3 scripts/compare_libraries.py --include-upgrade-candidates ali.json chris.json
```

### Scoring Changes (Recyclarr-aligned)
| Attribute | Old Score | New Score | Reason |
|-----------|-----------|-----------|--------|
| 720p resolution | 1000 | 0 | Huntarr upgrades |
| 480p resolution | 100 | -500 | Definitely upgrade |
| x265 (no HDR) at 1080p | +200 | -300 | Recyclarr blocks |
| x264 at 1080p | 100 | 150 | Preferred over x265 |

## List Sync Strategy

### Adding Ali's Libraries to Chris's *arr
1. **Radarr**: Settings → Lists → Add → Radarr
2. **Sonarr**: Settings → Import Lists → Add → Sonarr
3. **Critical Settings**:
   - Search on Add: **OFF**
   - Monitor: As desired

### Why Huntarr Missing Searches are Disabled
During initial sync, Ali's files need to copy to Chris first. If missing searches were enabled, Chris would download files Ali already has. Once sync is ~80% complete, re-enable missing searches.

## Batch Sync Screens

### Current Status
- **movie**: Running `sync_actions_20260205_180413.sh`
- **tvsync**: Running `tv_sync_actions_20260205_180436.sh`
- **Parallelism**: 8 concurrent rsyncs

### Health Monitoring
- Cron runs `/opt/mother/scripts/check-sync-health.sh` every 10 minutes
- Auto-restarts dead screens
- Sends Telegram notification on restart
- Auto-detects newest scripts (no manual update needed)

### Checking Progress
```bash
# View screens
screen -ls

# Attach to movie sync
screen -r movie

# Detach: Ctrl+A, D
```

## Post-Sync Checklist

When batch sync reaches ~90-100%:

1. **Stop batch sync screens**
   ```bash
   screen -S movie -X quit
   screen -S tvsync -X quit
   ```

2. **Disable health check restart** (edit crontab)
   ```bash
   crontab -e
   # Comment out check-sync-health.sh line
   ```

3. **Increase webhook concurrency**
   ```bash
   # Edit /opt/mother/.env
   SYNC_MAX_CONCURRENT=4  # or 8

   # Restart webhook
   cd /opt/mother && docker compose up -d sync-webhook
   ```

4. **Re-enable Huntarr missing searches**
   - Set Missing Search Count = 1 for each instance

5. **Run deletion scripts** (clean up replaced files)
   ```bash
   cd /opt/mother/reports
   ./chris_pending_deletions_*.sh
   ./chris_tv_pending_deletions_*.sh
   ```

## Monitoring

### Daily Report
- Runs every 2 hours via cron
- Shows sync progress, VPN traffic, errors
- Sent via Apprise to Telegram

### Cron Jobs on Mother
```
*/10 * * * * /opt/mother/scripts/check-sync-health.sh
0 0,2,4,...,22 * * * /opt/mother/reports/daily_report.py
*/2 * * * * /opt/mother/vpn_ping_monitor.sh
30 * * * * /opt/mother/sync_stall_check.sh
```

## Troubleshooting

### Huntarr not upgrading
1. Check quality profile has `upgrade: allowed: true`
2. Verify cutoff quality is set correctly
3. Check Huntarr logs for API errors

### Files not syncing
1. Check screen is running: `screen -ls`
2. Check progress file: `wc -l reports/sync_progress_*.log`
3. Check error log: `tail reports/sync_errors_*.log`

### Wrong files being synced
1. Regenerate sync scripts with `compare_libraries.py`
2. Verify `--skip-upgrade-candidates` is default (check argparse)
