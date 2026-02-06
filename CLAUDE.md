# Claude Code Context - Project Mother

## Development Environment

**IMPORTANT**: This repository is being developed on WSL (Windows Subsystem for Linux). The Mother server is a remote machine that must be accessed via SSH.

### Local Development Machine
- **Platform**: WSL2 on Windows
- **Working Directory**: `/home/alig/projects/mother` (WSL path)
- **Windows Path**: `\\wsl.localhost\Ubuntu\home\alig\projects\mother`

### Mother Server (Remote)
- **IP Address**: 10.0.0.162
- **Hostname**: mother
- **OS**: Ubuntu 24.04 LTS
- **Location**: Chris's network (10.0.0.0/23)
- **Access**: SSH only - use `ssh mother` or `ssh alig@10.0.0.162`

### Key Points for AI Assistants

1. **Always use SSH to access Mother**: Commands that need to run on Mother must use SSH or the MCP terminus tools (remote-ssh, ssh-read-lines, etc.)

2. **Local files vs Remote files**:
   - This repository (`/home/alig/projects/mother`) is LOCAL on WSL
   - Production files on Mother are at `/opt/mother/` (REMOTE)
   - Cron jobs, services, and scripts run on MOTHER, not locally

3. **Log files**: Logs on Mother are typically at:
   - `/var/log/mother_*.log`
   - `/opt/mother/logs/`

4. **To check cron jobs on Mother**:
   ```bash
   ssh mother 'crontab -l'
   ```

5. **To check services on Mother**:
   ```bash
   ssh mother 'systemctl status <service>'
   ```

## Network Topology

```
Your Location (192.168.1.0/24)          Chris's Location (10.0.0.0/23)
├── Unraid: 192.168.1.10                ├── Mother: 10.0.0.162  <-- Main server
├── Terminus: 192.168.1.14              ├── RS-4KMedia: 10.0.1.203
└── WSL (development)                   ├── RS-TV: 10.0.0.88
                                        └── RS-Movies: 10.0.0.160
        <------- IPsec VPN Tunnel ------->
```

## SSH Configuration

The local `~/.ssh/config` should have:
```
Host mother
    HostName 10.0.0.162
    User alig
    IdentityFile ~/.ssh/id_ed25519
```

## Common Tasks

### Running scripts on Mother
```bash
ssh mother '/opt/mother/reports/daily_report.py --dry-run'
```

### Checking logs on Mother
```bash
ssh mother 'tail -50 /var/log/mother_daily_report.log'
```

### Deploying changes to Mother
```bash
# From local WSL
rsync -avz --exclude '.git' /home/alig/projects/mother/ mother:/opt/mother/
```

## Active Sync Systems

### 1. Batch Sync (Initial Transfer)
- **Purpose**: Bulk transfer of 160TB existing content
- **Runs in**: Screen sessions (`movie`, `tvsync`)
- **Parallelism**: `PARALLEL=8` (8 concurrent rsyncs)
- **Scripts**: `sync_actions_*.sh`, `tv_sync_actions_*.sh`
- **Monitoring**: `check-sync-health.sh` (cron every 10 min)
- **Optimized**: Skips 720p and x265-no-HDR files (Huntarr upgrades these)

### 2. Webhook Sync (Ongoing)
- **Purpose**: Real-time sync of new downloads
- **Runs in**: Docker container `sync-webhook`
- **Parallelism**: `SYNC_MAX_CONCURRENT=2` (increase after bulk sync)
- **Triggered by**: Radarr/Sonarr webhooks

### 3. Huntarr (Quality Upgrades)
- **Purpose**: Automatically search for quality upgrades
- **URL**: http://10.0.0.162:9705
- **Mode**: Upgrades only (missing searches disabled during initial sync)
- **Rate**: 2 upgrades per 90 minutes (~32/day)
- **Instances**: Radarr HD/4K, Sonarr HD/4K

## Sync Optimization (2026-02-05)

Files skipped from batch sync (Huntarr will upgrade):
- **720p files**: ~19,345 skipped
- **x265 (no HDR) at 1080p**: ~6,561 skipped
- **Total reduction**: 47,578 → 23,463 (**51% fewer files**)

## Key Operations Files

| File | Purpose |
|------|---------|
| `docs/OPERATIONS.md` | Full operations guide |
| `docs/HUNTARR_SYNC_SETUP.md` | Huntarr & sync optimization details |
| `docs/SYNC_AUTOSTART.md` | Boot and health monitoring setup |
| `services/sync-webhook/README.md` | Webhook sync documentation |

## Cron Jobs on Mother

```
*/10 * * * * /opt/mother/scripts/check-sync-health.sh  # Health monitor
0 0,2,4,6,8,10,12,14,16,18,20,22 * * * /opt/mother/reports/daily_report.py
*/2 * * * *  /opt/mother/vpn_ping_monitor.sh           # VPN health
30 * * * *   /opt/mother/sync_stall_check.sh           # Stall detection
```
