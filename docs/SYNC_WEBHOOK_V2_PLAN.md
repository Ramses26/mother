# Sync Webhook V2 - Bulletproof Architecture

**Created:** 2026-01-01
**Status:** Planning/Implementation

---

## Problem Statement

The current sync-webhook has several failure points:
1. No persistence - webhooks lost if container is down
2. No retry logic - failed syncs disappear
3. No audit trail - can't see what synced or failed
4. Single notification channel - if Telegram fails, no alert
5. No health monitoring - container could be down for hours unnoticed
6. No catch-up mechanism - missed files stay missed

---

## V2 Architecture

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           WEBHOOK LAYER                                  │
├─────────────────────────────────────────────────────────────────────────┤
│  Radarr/Sonarr ──webhook──► sync-webhook ──► Auth Check                 │
│                              (Flask)           │                         │
│                                                ▼                         │
│                                         NFS Health Check                 │
│                                                │                         │
│                                                ▼                         │
│                                    ┌──────────────────┐                 │
│                                    │   SQLite Queue   │                 │
│                                    │   (jobs.db)      │                 │
│                                    └────────┬─────────┘                 │
│                                                │                         │
├─────────────────────────────────────────────────────────────────────────┤
│                           WORKER LAYER                                   │
├─────────────────────────────────────────────────────────────────────────┤
│                                    ┌──────────────────┐                 │
│                              ┌─────┤  Job Processor   ├─────┐           │
│                              │     │  (background)    │     │           │
│                              │     └──────────────────┘     │           │
│                              ▼                              ▼           │
│                    ┌─────────────────┐          ┌─────────────────┐    │
│                    │     rsync       │          │   Retry Queue   │    │
│                    │   (with logs)   │          │  (15 min cycle) │    │
│                    └────────┬────────┘          └─────────────────┘    │
│                              │                                          │
├─────────────────────────────────────────────────────────────────────────┤
│                         LOGGING LAYER                                    │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌────────────────┐   ┌────────────────┐   ┌────────────────┐          │
│  │ sync_history   │   │  JSON Logs     │   │  /metrics      │          │
│  │    .log        │   │  (structured)  │   │  (Prometheus)  │          │
│  └────────────────┘   └────────────────┘   └────────────────┘          │
│                                                                          │
├─────────────────────────────────────────────────────────────────────────┤
│                       NOTIFICATION LAYER                                 │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌────────────────┐   ┌────────────────┐   ┌────────────────┐          │
│  │   Telegram     │   │    Discord     │   │  Daily Digest  │          │
│  │   (primary)    │   │   (backup)     │   │  (midnight)    │          │
│  └────────────────┘   └────────────────┘   └────────────────┘          │
│                                                                          │
├─────────────────────────────────────────────────────────────────────────┤
│                       MONITORING LAYER                                   │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌────────────────┐   ┌────────────────┐   ┌────────────────┐          │
│  │  Uptime Kuma   │   │   Loggifly     │   │   Dozzle       │          │
│  │ (health check) │   │ (log alerts)   │   │ (log viewer)   │          │
│  └────────────────┘   └────────────────┘   └────────────────┘          │
│                                                                          │
├─────────────────────────────────────────────────────────────────────────┤
│                       RECONCILIATION LAYER                               │
├─────────────────────────────────────────────────────────────────────────┤
│  ┌────────────────────────────────────────────────────────────┐        │
│  │  Nightly Cron (3 AM)                                        │        │
│  │  - Compare Radarr/Sonarr libraries                          │        │
│  │  - Find files on source not on destination                  │        │
│  │  - Queue missing files for sync                             │        │
│  │  - Send summary report                                      │        │
│  └────────────────────────────────────────────────────────────┘        │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Implementation Phases

### Phase 1: Immediate Catch-Up (TODAY)
- [ ] Query Radarr/Sonarr APIs for recently imported files (last 24-48 hours)
- [ ] Generate list of files to sync
- [ ] Run targeted sync for missed files

### Phase 2: Core Improvements
- [ ] Add SQLite database for job queue
  - Jobs table: id, source, dest, status, created_at, completed_at, retry_count, error
  - Webhook inserts job → worker processes → updates status
- [ ] Add retry logic
  - Failed jobs retry after 15 minutes
  - Max 5 retries before marking as "failed_permanent"
- [ ] Add persistent logging
  - Structured JSON logs with rotation
  - sync_history.log for human-readable audit trail
- [ ] Add NFS health checks
  - Check mount accessibility before sync
  - Queue job for retry if mount unavailable
  - Alert immediately on mount failure

### Phase 3: Webhook Hardening
- [ ] Add authentication
  - Shared secret in header (X-Webhook-Secret)
  - Reject unauthorized requests
- [ ] Add rate limiting
  - Prevent webhook flood
- [ ] Add payload validation
  - Verify required fields exist

### Phase 4: Monitoring & Alerting
- [ ] Deploy Loggifly
  - Monitor sync-webhook logs for ERROR/CRITICAL
  - Send alerts on failures
- [ ] Deploy Uptime Kuma
  - Monitor /health endpoint
  - Alert on downtime
- [ ] Add Discord as backup notification
  - Primary: Telegram
  - Critical failures: Both
- [ ] Add daily summary
  - Cron at midnight
  - Summary of syncs, failures, retries

### Phase 5: Reconciliation
- [ ] Nightly audit script
  - Query Radarr/Sonarr for all files
  - Compare with destination
  - Queue missing files
- [ ] Weekly full comparison
  - Use existing comparison scripts
  - Generate report

---

## Database Schema

```sql
-- jobs.db

CREATE TABLE sync_jobs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    job_type TEXT NOT NULL,           -- 'movie' or 'episode'
    source_path TEXT NOT NULL,
    dest_path TEXT NOT NULL,
    title TEXT,
    quality TEXT,
    file_size INTEGER,
    status TEXT DEFAULT 'pending',    -- pending, running, success, failed, failed_permanent
    retry_count INTEGER DEFAULT 0,
    error_message TEXT,
    webhook_payload TEXT,             -- Store full payload for replay
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    started_at TIMESTAMP,
    completed_at TIMESTAMP,
    duration_seconds REAL,
    bytes_transferred INTEGER
);

CREATE INDEX idx_status ON sync_jobs(status);
CREATE INDEX idx_created ON sync_jobs(created_at);

CREATE TABLE sync_stats (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    movies_synced INTEGER DEFAULT 0,
    episodes_synced INTEGER DEFAULT 0,
    bytes_transferred INTEGER DEFAULT 0,
    failures INTEGER DEFAULT 0,
    retries INTEGER DEFAULT 0
);
```

---

## API Endpoints (V2)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check with queue stats |
| `/metrics` | GET | Prometheus metrics |
| `/stats` | GET | Sync statistics |
| `/sync/radarr` | POST | Radarr webhook (auth required) |
| `/sync/sonarr` | POST | Sonarr webhook (auth required) |
| `/sync/manual` | POST | Manual sync trigger |
| `/jobs` | GET | List recent jobs |
| `/jobs/<id>` | GET | Get job details |
| `/jobs/<id>/retry` | POST | Retry specific job |
| `/queue/retry-failed` | POST | Retry all failed jobs |

---

## Environment Variables (V2)

```bash
# Existing
TELEGRAM_BOT_TOKEN=xxx
TELEGRAM_CHAT_ID=xxx

# New - Authentication
WEBHOOK_SECRET=your_secret_here

# New - Discord backup
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/xxx

# New - Database
SYNC_DB_PATH=/data/jobs.db

# New - Logging
SYNC_LOG_PATH=/logs/sync_history.log
SYNC_LOG_JSON_PATH=/logs/sync.json

# New - Retry settings
SYNC_RETRY_INTERVAL=900    # 15 minutes
SYNC_MAX_RETRIES=5

# New - Reconciliation
RADARR_HD_URL=http://radarr-hd:7878
RADARR_4K_URL=http://radarr-4k:7878
SONARR_HD_URL=http://sonarr-hd:8989
SONARR_4K_URL=http://sonarr-4k:8989
```

---

## Tools to Add

### 1. Loggifly
Monitor Docker logs, alert on keywords.
```yaml
loggifly:
  image: ghcr.io/clemcer/loggifly:latest
  container_name: loggifly
  environment:
    - CONTAINERS=sync-webhook
    - KEYWORDS=ERROR,CRITICAL,FAILED,Exception
    - TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
    - TELEGRAM_CHAT_ID=${TELEGRAM_CHAT_ID}
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock:ro
```

### 2. Uptime Kuma
Health monitoring with notifications.
```yaml
uptime-kuma:
  image: louislam/uptime-kuma:latest
  container_name: uptime-kuma
  volumes:
    - ${CONFIG_PATH}/uptime-kuma:/app/data
  ports:
    - "3001:3001"
```

---

## Catch-Up Script (Immediate Need)

Query Radarr/Sonarr APIs for files imported in last 48 hours:

```bash
# Get recent imports from Radarr
curl "http://radarr-hd:7878/api/v3/history?eventType=downloadFolderImported&pageSize=100" \
  -H "X-Api-Key: $RADARR_HD_API_KEY"

# Get recent imports from Sonarr
curl "http://sonarr-hd:8989/api/v3/history?eventType=downloadFolderImported&pageSize=100" \
  -H "X-Api-Key: $SONARR_HD_API_KEY"
```

---

## Priority Order

1. **Catch-up script** - Recover missed syncs from today
2. **Persistent logging** - Start tracking everything
3. **SQLite job queue** - Durability
4. **Retry logic** - Automatic recovery
5. **NFS health checks** - Prevent silent failures
6. **Loggifly** - Alert on errors
7. **Daily summary** - Visibility
8. **Reconciliation cron** - Belt and suspenders

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-01 | V2 plan created |
