# Project Mother — Documentation Wiki

Project Mother is a media management and synchronization system consolidating two users' (~160 TB each) media libraries across two locations connected by IPsec VPN.

**Last updated**: 2026-06-18

---

## Quick Links

| Document | Description |
|----------|-------------|
| [Operations Guide](OPERATIONS.md) | Day-to-day operations, monitoring, troubleshooting |
| [Workflow Diagrams](WORKFLOW.md) | Full system data flow, Upgraderr pipeline, network topology |
| [Sync Guide](SYNC_GUIDE.md) | Sync strategy, what is and is NOT synced, sentinel files |
| [Curatorr Guide](CURATORR.md) | Curatorr navigation, scoring, sync status, duplicates, rules, deletion |
| [Path Reference](PATH_REFERENCE.md) | Container → NFS → Unraid path mappings |
| [Quality Profiles](QUALITY_PROFILES.md) | TRaSH quality profile configurations |
| [TRaSH Reference](TRASHGUIDES_REFERENCE.md) | TRaSH scoring methodology used across all services |
| [Service Config](SERVICE_CONFIG_GUIDE.md) | Environment variables and service configuration |
| [Inventory Guide](INVENTORY_GUIDE.md) | Scanning and analyzing media inventories |
| [Recyclarr Setup](RECYCLARR_SETUP.md) | Recyclarr quality profile sync configuration |
| [Sync Autostart](SYNC_AUTOSTART.md) | Boot and health monitoring setup |
| [Daily Report](DAILY_REPORT.md) | Unified status report configuration |

---

## System Overview

```
Ali's Location (192.168.1.0/24)          Chris's Location (10.0.0.0/23)
├── Unraid (192.168.1.10)                ├── Mother VM (10.0.0.162) ← YOU ARE HERE
│   ├── 160 TB media library             │   ├── All Docker services
│   └── Unraid Agent :8100               │   ├── Radarr/Sonarr x4
│                                        │   ├── Upgraderr (9706)
├── Terminus (192.168.1.14)              │   ├── Curatorr (9707)
│   ├── Ali's Plex                       │   └── Observability stack
│   └── Ali's Tautulli                   │
                                         ├── RS-TV (10.0.0.88)
        ←── IPsec VPN Tunnel ──►         ├── RS-Movies (10.0.0.160)
                                         └── RS-4KMedia (10.0.1.203)
```

**Data flow**: Chris's Synology NAS → rsync over VPN → Ali's Unraid (one-way mirror)

---

## Three Sync Layers

### 1. Webhook Sync (Real-Time)
Radarr/Sonarr fire webhooks on every download → sync-webhook (port 5001) rsyncs immediately. **Append-only — never deletes from Unraid.**

### 2. Nightly Reconciliation (11 PM – 12:15 AM ET)
| Time | Job |
|------|-----|
| 11:00 PM | TV gap scan — missing episodes |
| 11:15 PM | TV version reconcile — Synology file ≠ Unraid file |
| 11:30 PM | Movie gap scan — missing movie folders |
| 11:45 PM | Movie version reconcile — Synology folder scan + TRaSH score gate |
| 12:15 AM | Library health report (Telegram) |
| 8:00 AM | Unraid dedup (morning run after overnight queue drains) |

### 3. Upgraderr Quality Sweep (Every 30 Min)
Classifies all media into 7 tiers and triggers searches in Radarr/Sonarr:

| Tier | What | Priority |
|------|------|----------|
| 1 | m2ts/BDMV raw disc → encode | Highest |
| 2 | Non-MKV container → MKV | |
| 3 | 720p/SD → 1080p | |
| 4 | WEB-DL + TMDB BluRay available | |
| 5 | No surround audio → Atmos/DTS-HD | |
| 6 | Low TRaSH score | |
| 7 | Quality profile mismatch | Lowest |

---

## Service URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Upgraderr | http://mother:9706 | Quality upgrade queue + 7-tier breakdown |
| Curatorr | http://mother:9707 | Library browser, sync status, duplicates |
| Curatorr Sync Status | http://mother:9707/sync-status | Synology→Unraid parity dashboard |
| Grafana | http://mother:3003 | Metrics dashboards |
| Dozzle | http://mother:8080 | Live Docker logs |
| Uptime Kuma | http://mother:3001 | Service availability |

---

## Sync Status Dashboard

Navigate to `http://mother:9707/sync-status` for real-time Synology→Unraid parity:

| Card | Meaning | Fix |
|------|---------|-----|
| 🟢 In Sync | Files match | Nothing needed |
| 🔴 Missing | Folder on Synology, not Unraid | Gap scan queues tonight |
| 🟣 Version Mismatch | Synology has higher-scored file | Version reconcile tonight |
| 🟡 Radarr Out of Date | Folder has better file than Radarr tracks | Trigger Radarr library rescan |
| ⚫ Not Downloaded | No file in Radarr yet | Monitor Radarr queue |

---

## Key Principles

1. **Synology is source of truth** — Radarr/Sonarr manage Synology; Unraid mirrors it exactly
2. **Webhooks are append-only** — never delete from Unraid via webhook
3. **Never sync 720p/x265-no-HDR** — Upgraderr upgrades first, then gap scan copies the result
4. **Never scan Unraid via CIFS** — always use Unraid Agent API (192.168.1.10:8100)
5. **TRaSH scoring** includes custom format bonuses: `[Hybrid]`=+100, release group=+50, Proper/Repack=+25
