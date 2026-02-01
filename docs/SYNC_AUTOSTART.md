# Sync Auto-Start Setup

Automatically start and monitor the movie/TV sync scripts on Mother boot or failure.

## Overview

This setup provides:
1. **Systemd service** (`mother-sync.service`) - Starts sync screens on boot
2. **Health check cron job** - Monitors and restarts failed screens every 10 minutes
3. **Telegram notifications** - Alerts when screens are restarted

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         MOTHER SERVER                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  SYSTEMD (boot-time)              CRON (ongoing monitoring)     │
│  ┌─────────────────────┐          ┌─────────────────────────┐   │
│  │ mother-sync.service │          │ */10 * * * *            │   │
│  │ (runs on boot)      │          │ check-sync-health.sh    │   │
│  └─────────┬───────────┘          └───────────┬─────────────┘   │
│            │                                  │                 │
│            ▼                                  ▼                 │
│  ┌─────────────────────┐          ┌─────────────────────────┐   │
│  │start-sync-screens.sh│          │ Checks if screens alive │   │
│  └─────────┬───────────┘          │ Restarts if dead but    │   │
│            │                      │ sync not complete       │   │
│            ▼                      │ Sends Telegram alert    │   │
│  ┌─────────────────────────────┐  └─────────────────────────┘   │
│  │   SCREEN SESSIONS           │                                │
│  │  ┌───────────┐ ┌──────────┐ │                                │
│  │  │  movie    │ │  tvsync  │ │   PARALLEL=8                   │
│  │  │ (screen)  │ │ (screen) │ │                                │
│  │  └─────┬─────┘ └────┬─────┘ │                                │
│  └────────┼────────────┼───────┘                                │
│           ▼            ▼                                        │
│  sync_actions_*.sh    tv_sync_actions_*.sh                      │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Components

| File | Runs Under | Purpose |
|------|------------|---------|
| `/etc/systemd/system/mother-sync.service` | systemd | Starts screens on boot |
| `/opt/mother/scripts/start-sync-screens.sh` | systemd (via service) | Starts movie & TV sync in screen sessions |
| `/opt/mother/scripts/stop-sync-screens.sh` | systemd (via service) | Stops screen sessions |
| `/opt/mother/scripts/check-sync-health.sh` | **cron** (every 10 min) | Health monitor - restarts dead screens |

## Installation

```bash
# Copy scripts to Mother
scp scripts/start-sync-screens.sh mother:/opt/mother/scripts/
scp scripts/stop-sync-screens.sh mother:/opt/mother/scripts/
scp scripts/check-sync-health.sh mother:/opt/mother/scripts/

# Make executable
ssh mother 'chmod +x /opt/mother/scripts/{start,stop,check}-sync*.sh'

# Install systemd service (as root)
scp services/sync-autostart/mother-sync.service mother:/tmp/
ssh mother 'sudo mv /tmp/mother-sync.service /etc/systemd/system/'
ssh mother 'sudo systemctl daemon-reload'
ssh mother 'sudo systemctl enable mother-sync.service'
```

## Usage

### Manual Control

```bash
# Start sync screens
sudo systemctl start mother-sync

# Stop sync screens
sudo systemctl stop mother-sync

# Check status
sudo systemctl status mother-sync

# View logs
journalctl -u mother-sync -f
```

### Health Check Cron

Add to crontab for automatic recovery:

```bash
# Check every 10 minutes and restart if needed
*/10 * * * * /opt/mother/scripts/check-sync-health.sh
```

### View Running Screens

```bash
screen -ls                  # List all screens
screen -r movie            # Attach to movie sync
screen -r tvsync           # Attach to TV sync
# Detach with: Ctrl+A, D
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PARALLEL` | 8 | Number of parallel rsync transfers |

## Logs

| Log File | Contents |
|----------|----------|
| `/opt/mother/logs/sync-autostart.log` | Startup/shutdown events |
| `/opt/mother/logs/sync-health.log` | Health check results |
| `/opt/mother/logs/movie_sync.log` | Movie sync output |
| `/opt/mother/logs/tv_sync.log` | TV sync output |

## How It Works

1. **On boot**: Systemd runs `start-sync-screens.sh`
2. Script finds the most recent `sync_actions_*.sh` and `tv_sync_actions_*.sh`
3. Starts each in a detached screen session with `PARALLEL=8`
4. **Every 10 min** (via cron): `check-sync-health.sh` verifies screens are running
5. If a screen dies but sync isn't complete, it auto-restarts and sends a Telegram alert

## Sync Completion Detection

The health check script is smart:
- Reads the progress file to count completed items
- Compares against total items in the script
- **Won't restart** if sync is 100% complete
- **Will restart** if sync died mid-way

## Troubleshooting

### Screens not starting on boot
```bash
# Check service status
sudo systemctl status mother-sync

# Check logs
journalctl -u mother-sync --no-pager

# Verify scripts exist
ls -la /opt/mother/reports/sync_actions_*.sh
ls -la /opt/mother/reports/tv_sync_actions_*.sh
```

### NFS mounts not ready
The service waits for `remote-fs.target` and `nfs-client.target`, but if NFS is slow:
```bash
# Edit service to add delay
sudo systemctl edit mother-sync
# Add:
[Service]
ExecStartPre=/bin/sleep 30
```

### Manual restart of a sync
```bash
# Kill existing screen
screen -S movie -X quit

# Restart via health check
/opt/mother/scripts/check-sync-health.sh

# Or manually
cd /opt/mother/reports
PARALLEL=8 screen -dmS movie ./sync_actions_20260122_180402.sh
```
