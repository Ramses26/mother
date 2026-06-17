# Project Mother — Operations Guide

**Last Updated**: 2026-06-17

This document covers day-to-day operations, monitoring, and troubleshooting for Project Mother in its current **steady-state** configuration. Batch syncs are complete; ongoing sync is driven entirely by webhooks and nightly scheduled jobs.

---

## Current Status Overview

### Sync Phase

| Library | Phase | Mechanism |
|---------|-------|-----------|
| HD Movies | ✅ **Steady-state** | Webhook (real-time) + nightly gap scan (11:30 PM ET) + nightly version reconcile (11:45 PM ET) |
| 4K Movies | ✅ **Steady-state** | Webhook (real-time) only — no gap scan for 4K |
| HD TV | ✅ **Steady-state** | Webhook (real-time) + nightly gap scan (11:00 PM ET) + nightly version reconcile (11:15 PM ET) |
| 4K TV | ✅ **Steady-state** | Webhook (real-time) only — no gap scan for 4K |

- Movie batch sync **permanently disabled** — sentinel `/opt/mother/DISABLE_MOVIE_SYNC` present
- TV batch sync (`screen tvsync`) **completed June 17 2026** — screen session no longer needed
- Dedup runs daily at **8:00 AM ET** — currently **paused** (`/opt/mother/PAUSE_DEDUP` exists)

### Active Services

| Service | Port | Status |
|---------|------|--------|
| sync-webhook | 5001 | Running — real-time sync + nightly jobs |
| upgraderr | 9706 | Running — quality upgrade automation |
| curatorr | 9707 | Running — media intelligence + curation |
| grafana | 3003 | Running — dashboards |
| prometheus | 9090 | Running — metrics |
| loki | 3100 | Running — log aggregation |
| tracearr | 3002 | Running — stream analytics |
| tautulli | 8181 | Running — Chris's Plex watch history |
| uptime-kuma | 3001 | Running — service uptime |

---

## Sync Architecture (Steady-State)

Three layers work together to keep Synology → Unraid in sync:

### Layer 1: Webhook Sync (Real-Time)

Radarr and Sonarr fire `POST /sync/radarr` or `/sync/sonarr` webhooks to sync-webhook (port 5001) on every download/upgrade. The webhook:

1. Translates container path → NFS path → Unraid destination
2. Queues an rsync job (up to `SYNC_MAX_CONCURRENT=12` concurrent)
3. Auto-retries failures with exponential backoff (15m → 1h → 4h → 12h)
4. Sends Telegram on success/failure

**Critical rule**: Webhooks are **append-only** — they never delete from Unraid. `MovieFileDelete` and `EpisodeFileDelete` events are intentionally ignored.

### Layer 2: Nightly Gap Scanners (11:00–11:45 PM ET)

Nightly jobs catch anything the webhook missed (container restart, race condition, etc.):

| Time (ET) | Job | What it does |
|-----------|-----|-------------|
| 11:00 PM | TV gap scan | Compares Synology rs-tv vs Unraid Agent; queues missing HD episodes |
| 11:15 PM | TV version reconcile | For episodes on both sides, replaces Unraid copy if filename differs (Synology is source of truth) |
| 11:30 PM | Movie gap scan | Compares Synology rs-movies vs Unraid Agent; queues missing HD movie folders |
| 11:45 PM | Movie version reconcile | Same as TV version reconcile but for movies |
| 12:15 AM | Library health report | Telegram summary of remaining gaps |

**Quality filter**: 720p, SD, and x265-without-HDR/DV are **never** queued — Upgraderr upgrades Chris's side first, then the next gap scan picks up the upgraded version.

**Version reconcile**: When Synology has a better version of something already on Unraid (e.g., WEB-DL vs old Remux), version reconcile rsyncs the new file then calls the Unraid Agent to delete the old one. Guarded by `PAUSE_VERSION_SYNC` sentinel.

### Layer 3: Upgraderr Quality Sweep (Every 30 Min)

Upgraderr classifies all Radarr/Sonarr items into 6 upgrade tiers and triggers searches:

| Tier | Target |
|------|--------|
| 1 | m2ts/BDMV raw discs → proper encode |
| 2 | Non-MKV container → MKV |
| 3 | 720p/SD → 1080p |
| 4 | TMDB physical release available → better BluRay source |
| 5 | No surround audio → Atmos/DTS-HD |
| 6 | Low TRaSH score → better quality |

UI: `http://mother:9706` (JWT login required)

---

## Sentinel Files

These files control emergency pausing of specific operations. Create/remove them on the Mother host:

| File | Effect |
|------|--------|
| `/opt/mother/PAUSE_DEDUP` | Blocks nightly Unraid dedup (8:00 AM ET). **Currently present.** |
| `/opt/mother/PAUSE_VERSION_SYNC` | Blocks nightly TV + movie version reconcile. Use during major library changes. |
| `/opt/mother/DISABLE_MOVIE_SYNC` | Disables movie batch sync screen. **Permanently present.** |
| `/opt/mother/PAUSE_SYNC` | Pauses batch sync screens without killing running rsyncs. |

**When to pause dedup**: Any time the gap scanner queue is large or you're running bulk file operations. The 8:00 AM timing (vs midnight before) was specifically chosen to let the overnight rsync queue drain first, but create `PAUSE_DEDUP` if you're uncertain.

**Remove PAUSE_DEDUP** once: (1) all restorations from the June 2026 incident are confirmed, and (2) the gap scanner has had at least one clean nightly run with no new files queued.

---

## Monitoring

### Telegram Alerts You Receive

| Alert | Meaning |
|-------|---------|
| "Sync Complete" | Individual file synced OK |
| "Sync Failed" | rsync failed after 20 retries |
| "Stalled Sync Killed" | Watchdog killed a frozen rsync (no I/O for 15 min) |
| "Sync Retry" | Retrying a failed job |
| "TVGapSync queued N items" | Nightly TV gap scan found missing episodes |
| "GapSync queued N items" | Nightly movie gap scan found missing folders |
| "TVVersionSync queued N items" | Nightly TV version reconcile found mismatches |
| "MovieVersionSync queued N items" | Nightly movie version reconcile found mismatches |
| "⚠️ Version Sync: Old File Not Deleted" | rsync succeeded but Agent rejected old-file delete |
| "Unraid Dedup PAUSED" | PAUSE_DEDUP sentinel exists |
| "Unraid Dedup DEFERRED" | Gap/version sync jobs still in queue — dedup skipped |
| "Unraid Dedup Complete" | Daily dedup summary with deletion count |
| "Daily Summary" | 8:05 PM ET — stats snapshot |
| "Library Health Report" | 12:15 AM ET — nightly gap summary |

### Health Endpoints

```bash
curl http://localhost:5001/health      # sync-webhook health
curl http://localhost:5001/stats       # sync job counts
curl http://localhost:5001/jobs?limit=20  # recent jobs
curl http://localhost:9706/health      # Upgraderr health
```

### Key Dashboards

- **Grafana**: `http://mother:3003` — service metrics + log streams
- **Dozzle**: `http://mother:8080` — live Docker logs
- **Upgraderr UI**: `http://mother:9706` — upgrade queue + tier breakdown
- **Curatorr UI**: `http://mother:9707` — library browser + duplicates
- **Uptime Kuma**: `http://mother:3001` — service availability

---

## Common Operations

### Check Sync Queue

```bash
curl -s http://localhost:5001/stats | python3 -m json.tool
curl -s "http://localhost:5001/jobs?limit=20"
```

### Trigger Manual Sync

```bash
# Trigger a specific file
curl -X POST http://localhost:5001/sync/manual \
  -H "Content-Type: application/json" \
  -d '{"path": "/tv/Show Name/Season 1/Show.S01E01.mkv", "type": "tv", "title": "Show S01E01", "quality": "WEB-DL 1080p"}'

# Trigger gap scan immediately
curl -X POST http://localhost:5001/api/gap-scan/trigger
```

### Docker Management

```bash
# Status
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Restart a service
docker compose up -d sync-webhook

# View logs
docker logs sync-webhook --tail 100 -f

# Rebuild and restart after code change
docker compose build sync-webhook && docker compose up -d sync-webhook

# Fix mangled container name after force-remove
docker rename <hash>_sync-webhook sync-webhook
```

### Pause / Resume Dedup

```bash
# Pause
touch /opt/mother/PAUSE_DEDUP

# Resume
rm /opt/mother/PAUSE_DEDUP

# Status
ls -la /opt/mother/PAUSE_DEDUP 2>/dev/null && echo "PAUSED" || echo "active"
```

### Pause / Resume Version Sync

```bash
touch /opt/mother/PAUSE_VERSION_SYNC   # pause
rm /opt/mother/PAUSE_VERSION_SYNC      # resume
```

---

## Troubleshooting

### sync-webhook Container Stuck / Won't Stop

When many rsync processes are in D-state (uninterruptible NFS I/O wait), the container may hang on `docker stop`:

```bash
# Get the host PID of the container's init process
CONTAINER=$(docker inspect --format '{{.State.Pid}}' sync-webhook)
sudo kill -9 $CONTAINER

# Clean up and restart
docker rm -f sync-webhook
docker compose up -d sync-webhook
docker rename $(docker ps -q -f name=sync-webhook) sync-webhook 2>/dev/null || true
```

**Root cause**: D-state rsync processes hold SQLite DB connections. APScheduler threads can't acquire the lock → deadlock. Killing the container frees all connections.

### Stale Unraid CIFS Mount

The `/mnt/unraid/media/` CIFS mount can appear to hang because it contains 7,600+ folders — **listing is slow, not stale**.

```bash
# DON'T do this — will time out even on a healthy mount:
timeout 5 ls /mnt/unraid/media/

# DO check a specific subfolder:
timeout 5 ls /mnt/unraid/media/Movies/ | head -3

# True stale symptoms: D-state rsync processes + cifsoplockd kworkers
ps aux | grep rsync | grep 'mnt/unraid'
smbclient -L //192.168.1.10 -N  # SMB itself is almost always healthy

# Fix a genuinely stale mount
sudo umount -l /mnt/unraid/media && sudo mount /mnt/unraid/media
```

**Note**: Sync operations use the Unraid Agent API (192.168.1.10:8100), not CIFS. CIFS is only used for direct file writes (rsync destination). The Agent API is unaffected by CIFS state.

### sync-webhook DB Lock / 500 Errors

```bash
# Check for D-state rsync processes
ps aux | grep rsync | grep D

# Check container health
curl -s http://localhost:5001/health

# If DB locked: kill stuck rsync pids, then restart container
sudo kill -9 $(ps aux | grep rsync | grep '/mnt/unraid' | awk '{print $2}') 2>/dev/null
docker compose up -d sync-webhook
```

### Unraid Agent Unreachable

```bash
# Health check
curl -H "X-Api-Key: $(grep UNRAID_AGENT_API_KEY /opt/mother/.env | cut -d= -f2)" \
  http://192.168.1.10:8100/health

# VPN check (Agent is on Unraid, reachable via VPN)
ping -c 2 192.168.1.10
```

If Agent is down, gap scanners and version reconcile will fail gracefully (logged + Telegram alert). Retry tomorrow.

### rsync Jobs Stuck In-Progress After Restart

On container restart, `recover_interrupted_jobs()` re-queues all `pending` and `in_progress` jobs automatically. Check progress with:

```bash
curl -s "http://localhost:5001/jobs?limit=50" | python3 -m json.tool | grep -A3 '"status"'
```

---

## After Rebooting Mother

```bash
# 1. Verify containers started
docker ps --format "table {{.Names}}\t{{.Status}}"

# 2. Confirm sync-webhook is healthy
curl -s http://localhost:5001/health

# 3. CIFS spot-check (specific subfolder, not top-level)
timeout 5 ls /mnt/unraid/media/Movies/ | head -3 && echo "CIFS OK"

# 4. Confirm Unraid Agent is reachable
curl -s -H "X-Api-Key: $(grep UNRAID_AGENT_API_KEY /opt/mother/.env | cut -d= -f2)" \
  http://192.168.1.10:8100/health | python3 -m json.tool

# Note: batch sync screens (movie/tvsync) are NOT needed — batch sync is complete.
# Nightly gap scanner handles any remaining gaps automatically.
```

---

## Cron Jobs on Mother

```
*/2 * * * *   /opt/mother/vpn_ping_monitor.sh           # VPN health; Telegram on state change
*/10 * * * *  /opt/mother/scripts/check-sync-health.sh  # Container health check
0 0,2,4,6,8,10,12,14,16,18,20,22 * * *  /opt/mother/reports/daily_report.py  # Status (every 2h)
58 23 * * *   /opt/mother/reports/daily_report.py        # End-of-day report
```

**APScheduler jobs inside sync-webhook** (all times Eastern / America/New_York, DST-aware):

| Time | Job | Notes |
|------|-----|-------|
| Every 15 min | Auto-retry failed jobs | Exponential backoff: 15m→1h→4h→12h |
| Every 15 min | Stall watchdog | Kills rsync with no I/O after 15 min |
| Every 30 min | History scanner | Checks *arr history for missed downloads (last 48h) |
| 8:05 PM | Daily summary | Telegram snapshot |
| 10:00 PM | DB backup | Keeps last 10 |
| 11:00 PM | TV gap scan | Missing HD TV episodes → Unraid |
| 11:15 PM | TV version reconcile | Filename mismatches → replace on Unraid |
| 11:30 PM | Movie gap scan | Missing HD movie folders → Unraid |
| 11:45 PM | Movie version reconcile | Filename mismatches → replace on Unraid |
| 12:15 AM | Library health report | Telegram gap summary |
| 8:00 AM | Unraid dedup | Delete lower-quality duplicates (multiple safety gates) |

---

## Dedup Safety Gates (In Order)

1. **PAUSE_DEDUP sentinel** — blocks entirely
2. **Active gap/version-sync jobs** — defers if any pending/in-progress
3. **Recent gap/version-sync jobs** — defers if any completed within last 24h
4. **Pre-run warning** (`DEDUP_WARN_MINUTES=10`) — Telegram N min before deletions; re-checks sentinel
5. **Safety limit** (`DEDUP_SAFETY_LIMIT=200`) — aborts if more than N deletable files found
6. **Per-run cap** (`DEDUP_MAX_PER_RUN=50`) — max deletions per run
7. **Dry-run mode** (`DEDUP_DRY_RUN=true`) — preview without executing
8. **Agent confirmation** — counts success only if path appears in Agent `deleted[]`
