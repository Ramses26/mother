# Project Mother — Documentation Wiki

Project Mother is a media management and synchronization system consolidating two users' (~160 TB each) media libraries across two locations connected by IPsec VPN.

**Last updated**: 2026-08-18

---

## Quick Links

| Document | Description |
|----------|-------------|
| [Operations Guide](OPERATIONS.md) | Day-to-day operations, monitoring, troubleshooting |
| [Quality Upgrades](QUALITY_UPGRADES.md) | **Force-grab, qBit-first, Remux→Bluray, Tier 9 — getting the best copy of everything** |
| [Workflow Diagrams](WORKFLOW.md) | Full system data flow, Upgraderr pipeline, network topology |
| [Sync Guide](SYNC_GUIDE.md) | Sync strategy, what is and is NOT synced, sentinel files |
| [Curatorr Guide](CURATORR.md) | Curatorr navigation, scoring, sync status, duplicates, rules, deletion |
| [TRaSH Scoring Reference](TRASHGUIDES_REFERENCE.md) | Unified scoring system — all constants, how to tune |
| [Path Reference](PATH_REFERENCE.md) | Container → NFS → Unraid path mappings |
| [Quality Profiles](QUALITY_PROFILES.md) | TRaSH quality profile configurations |
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

## Sync Status: August 2026

| Library | Phase | Notes |
|---------|-------|-------|
| HD Movies | ✅ Steady-state | Batch sync complete; webhook + nightly jobs active |
| 4K Movies | ✅ Steady-state | Webhook only (no gap scan for 4K) |
| HD TV | ✅ Steady-state | Batch sync completed Jun 17 2026 |
| 4K TV | ✅ Steady-state | Webhook only |

**Sentinels active**: `DISABLE_MOVIE_SYNC`, `DISABLE_TV_SYNC` (batch syncs complete). `PAUSE_DEDUP` was removed 2026-07-02; dedup runs daily at 8 AM ET behind its safety gates.

---

## Three Sync Layers

### 1. Webhook Sync (Real-Time)
Radarr/Sonarr fire webhooks on every download → sync-webhook (port 5001) rsyncs immediately.
**Append-only — never deletes from Unraid.** Concurrent rsyncs capped by `SYNC_MAX_CONCURRENT=6`.

### 2. Nightly Reconciliation (11 PM – 12:15 AM ET)
| Time | Job | Notes |
|------|-----|-------|
| 11:00 PM | TV gap scan | Missing episodes Synology→Unraid |
| 11:15 PM | TV version reconcile | TRaSH score comparison; TVVersionSync or TVReverseSync |
| 11:30 PM | Movie gap scan | Missing movie folders Synology→Unraid |
| 11:45 PM | Movie version reconcile | Synology folder scan vs Unraid; Radarr's tracked file wins (Profile Authority); cap `VERSION_SYNC_MAX_PER_RUN=500`/run |
| 12:15 AM | Library health report | Telegram summary |
| 8:00 AM | Unraid dedup | Morning run after overnight queue drains; multiple safety gates |

### 3. Upgraderr Quality Sweep (Every 30 Min)
Classifies all media into **9 tiers** and acts on the highest-priority problem:

| Tier | What | Priority |
|------|------|----------|
| 1 | m2ts/BDMV raw disc → encode | Highest |
| 2 | Non-MKV container → MKV | |
| 3 | 720p/SD → 1080p | |
| 4 | WEB-DL + TMDB BluRay ≥90 days available | |
| 5 | No surround audio → Atmos/DTS-HD | |
| 6 | Low TRaSH score | |
| 7 | Quality profile mismatch (Radarr won't search; Upgraderr forces it) | |
| 8 | 1080p x265 without HDR/DV | |
| 9 | Release-group quality / Remux→Bluray → **force-grab the best release** | Lowest |

Tiers 1–8 trigger a normal search; **Tier 9 force-grabs the best available release** (and
imports an existing good copy from qBittorrent for free when one exists). This is the system
that acquires the genuinely-best copy of every title — see **[Quality Upgrades](QUALITY_UPGRADES.md)**.

Upgraderr also runs **nightly stale queue validation** (5 AM UTC) to remove entries whose upgrade reason no longer applies.

---

## Unified TRaSH Scoring

All three services (sync-webhook, curatorr/duplicates, curatorr/sync_status) share one scoring config:

```
configs/scoring/trash_scoring.json
```

To tune: edit the JSON → `docker compose restart sync-webhook curatorr`. See [TRaSH Reference](TRASHGUIDES_REFERENCE.md).

**Score order (typical 1080p Remux)**: `res(2000) + src(2000) + audio(500) + rg(50) + size(~50)` ≈ **4600**

---

## Service URLs

| Service | URL | Purpose |
|---------|-----|---------|
| Upgraderr | http://mother:9706 | Quality upgrade queue + 9-tier breakdown |
| Curatorr | http://mother:9707 | Library browser, sync status, duplicates |
| Curatorr Sync Status | http://mother:9707/sync-status | Synology↔Unraid parity dashboard |
| Grafana | http://mother:3003 | Metrics dashboards (login: admin) |
| Dozzle | http://mother:8080 | Live Docker logs |
| Uptime Kuma | http://mother:3001 | Service availability |
| Queue UI | http://mother:5001/ui/queue | sync-webhook job queue |

---

## Sync Status Dashboard

Navigate to `http://mother:9707/sync-status` for real-time parity:

| Card | Meaning | Action |
|------|---------|--------|
| 🟢 In Sync | Files match both sides | Nothing needed |
| 🔴 Missing | Folder on Synology, not Unraid | Gap scan queues tonight at 11:30 PM |
| 🟣 Version Mismatch | Synology has higher TRaSH-scored file | Version reconcile tonight at 11:45 PM |
| 🟡 Unraid Has Better | Unraid score > Radarr's Synology file | Dedup handles Unraid; Upgraderr upgrades Synology |
| 🟡 Radarr Out of Date | Synology folder has better file than Radarr tracks | Trigger Radarr library rescan |
| ⚫ Not Downloaded | No file in Radarr yet | Monitor Radarr queue |

Use **"Reconcile Now"** button to trigger reconcile jobs immediately without waiting for 11:45 PM.

---

## Key Principles

1. **Synology is source of truth** — Radarr/Sonarr manage Synology; Unraid mirrors it
2. **Webhooks are append-only** — never delete from Unraid via webhook
3. **Absolute parity (since 2026-07-25)** — *every* Synology file syncs to Unraid regardless of quality tier; 720p/x265-no-HDR are no longer excluded from sync (Upgraderr independently upgrades them). Synology remains authoritative and protected on the reverse direction.
4. **Never scan Unraid via CIFS** — always use Unraid Agent API (192.168.1.10:8100)
5. **TRaSH scoring is unified** — one JSON config, three services, no drift
6. **Stale-entry protection** — history scanner and auto-retry auto-detect replaced source files and mark them `success` instead of looping forever
7. **SYNC_MAX_CONCURRENT** — never change this without confirmation; tuned to avoid saturating the VPN during peak sync
8. **Multi-episode aware** — the gap scanner, reconcile, and health report expand dual files (`S01E01-E02` → both episodes) so kids'/anime shows don't produce false "extra episode" reports (fixed 2026-08-16)
9. **Upgraderr owns *best-copy* upgrades** — RSS acquires fast, Upgraderr force-grabs the best release; see [Quality Upgrades](QUALITY_UPGRADES.md)

---

## Emergency Quick Reference

```bash
# Check sync queue
curl -s http://localhost:5001/stats | python3 -m json.tool

# Pause dedup (if uncertain about library state)
touch /opt/mother/PAUSE_DEDUP

# Pause version reconcile (during bulk library changes)
touch /opt/mother/PAUSE_VERSION_SYNC

# Container restart after code change
docker compose build sync-webhook && docker compose up -d sync-webhook
docker rename $(docker ps -q -f name=sync-webhook) sync-webhook 2>/dev/null || true

# Trigger reconcile now
curl -X POST http://localhost:5001/api/reconcile/trigger

# Check a stale CIFS mount (specific folder only — root listing always times out)
timeout 10 ls "/mnt/unraid/media/Movies/Heat (1995)/" && echo "CIFS OK"
```
