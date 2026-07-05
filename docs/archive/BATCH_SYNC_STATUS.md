# Batch Sync Status Tools

> **Note:** The nightly Telegram report has been consolidated into `daily_report.py` which runs at 8 AM and includes both sync status and VPN traffic. See [DAILY_REPORT.md](DAILY_REPORT.md) for details.

Tools for monitoring and managing the initial batch sync between Ali and Chris libraries.

## Overview

The batch sync (DR sync) runs large sync scripts that copy movies and TV shows between:
- Ali's Unraid server (192.168.1.10)
- Chris's Synology NAS systems

These tools help monitor progress and troubleshoot issues.

## Scripts

### 1. sync_status.py - Check Sync Progress

Shows progress of a batch sync script by analyzing the progress file.

```bash
# On Mother server (10.0.0.162)
cd /opt/mother

# Check movie sync status
./scripts/sync_status.py sync_actions_20251231_171646_bw600.sh

# Check TV sync status
./scripts/sync_status.py tv_sync_actions_20251231_171035.sh

# Send status to Telegram
./scripts/sync_status.py sync_actions_20251231_171646_bw600.sh --telegram

# List remaining items
./scripts/sync_status.py sync_actions_20251231_171646_bw600.sh --list-remaining
```

**Output:**
```
================================================================
PROJECT MOTHER - MOVIES SYNC STATUS
================================================================
Timestamp: 2026-01-21 09:00:00
Script: sync_actions_20251231_171646_bw600.sh
Progress file: sync_progress_20251231_171646.log
Running: No

----------------------------------------
OVERALL PROGRESS
----------------------------------------
[████████░░░░░░░░░░░░░░░░░░░░░░] 27.3%
Completed: 1,412 / 5,166
Remaining: 3,754
```

### 2. verify_sync.py - Verify Completed Transfers

Checks that items marked as "completed" actually exist at their destinations.
Identifies partial transfers that need to be re-synced.

```bash
# Verify completed syncs
./scripts/verify_sync.py sync_actions_20251231_171646_bw600.sh

# Show details of issues found
./scripts/verify_sync.py sync_actions_20251231_171646_bw600.sh --show-issues

# Fix issues (remove from progress file so they'll be re-synced)
./scripts/verify_sync.py sync_actions_20251231_171646_bw600.sh --fix

# Limit verification to first 500 entries (faster check)
./scripts/verify_sync.py sync_actions_20251231_171646_bw600.sh --limit 500
```

**Output:**
```
================================================================
VERIFICATION RESULTS
================================================================
Verified OK:      1,400
Missing at dest:  8
Partial transfer: 4
Source missing:   0

⚠️  12 operations need to be re-synced!
```

### 3. batch_sync_report.py - Sync Status Report (Legacy)

> **Deprecated:** This script has been replaced by `daily_report.py` which combines sync status with VPN traffic monitoring. Keep this script for manual checks only.

Sends a combined status report for both Movies and TV sync to Telegram.

```bash
# Run manually (for quick status check)
./reports/batch_sync_report.py --scripts-dir /opt/mother

# Dry run (print without sending)
./reports/batch_sync_report.py --dry-run
```

**For automated daily reports, use `daily_report.py` instead.** See [DAILY_REPORT.md](DAILY_REPORT.md).

## Daily Reports

Daily reports are now handled by `daily_report.py` which runs at 8 AM and includes:
- Movies and TV sync progress
- VPN traffic statistics
- Error counts
- Last activity timestamps

See [DAILY_REPORT.md](DAILY_REPORT.md) for setup instructions.

## Troubleshooting

### Sync Appears Stuck

1. **Check if script is running:**
   ```bash
   ps aux | grep sync_actions
   ```

2. **Check the progress:**
   ```bash
   ./scripts/sync_status.py sync_actions_20251231_171646_bw600.sh
   ```

3. **If not running, restart it:**
   ```bash
   # Use screen or tmux for persistence
   screen -S movie_sync
   PARALLEL=8 ./sync_actions_20251231_171646_bw600.sh
   # Ctrl+A, D to detach
   ```

### Items Marked Complete But Missing

1. **Verify completed items:**
   ```bash
   ./scripts/verify_sync.py sync_actions_20251231_171646_bw600.sh --show-issues
   ```

2. **Fix and re-sync:**
   ```bash
   # This removes bad entries from progress file
   ./scripts/verify_sync.py sync_actions_20251231_171646_bw600.sh --fix

   # Re-run the sync script
   PARALLEL=8 ./sync_actions_20251231_171646_bw600.sh
   ```

### Internet Disconnected During Sync

The sync scripts use:
- `rsync --partial --inplace` - Partial files are kept and can be resumed
- MD5 hash-based progress tracking - Only marks complete after rsync succeeds

If rsync fails mid-transfer:
- The file remains partially transferred
- The command is NOT marked as complete
- Re-running the script will retry the transfer

**However**, when using parallel mode (`PARALLEL > 1`), if the script is killed (Ctrl+C, terminal closed, etc.):
- Background rsync jobs may have completed but not recorded
- Or may have been interrupted

**Recommendation after disconnect:**
1. Wait for any background jobs to finish (check with `ps aux | grep rsync`)
2. Run verification: `./scripts/verify_sync.py <script> --fix`
3. Re-run the sync script

## File Locations

On Mother (10.0.0.162):
- Sync scripts: `/opt/mother/` or `/opt/mother/reports/`
- Progress files: Same directory as scripts (e.g., `sync_progress_20251231_171646.log`)
- Error logs: Same directory (e.g., `sync_errors_20251231_171646.log`)

## Quick Reference

| Task | Command |
|------|---------|
| Check movie sync status | `./sync_status.py sync_actions_*.sh` |
| Check TV sync status | `./sync_status.py tv_sync_actions_*.sh` |
| Send status to Telegram | Add `--telegram` flag |
| Verify completed items | `./verify_sync.py sync_actions_*.sh` |
| Fix partial transfers | `./verify_sync.py sync_actions_*.sh --fix` |
| Nightly Telegram report | `./batch_sync_report.py` (add to cron) |
