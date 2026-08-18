# Architecture & Environment

**Last updated**: 2026-08-18

Project Mother consolidates two people's media libraries (~160 TB each) across **two physical
locations** joined by an IPsec VPN. This page is the mental model everything else depends on —
especially *which machine holds what*, because that drives most real-world behaviour (and the
one performance gotcha: cross-device copies).

---

## The two locations

```
 Ali's Location — 192.168.1.0/24            Chris's Location — 10.0.0.0/23
 ┌─────────────────────────────┐           ┌──────────────────────────────────────┐
 │ Unraid        192.168.1.10  │           │ Mother (VM)   10.0.0.162  ← all apps  │
 │  • 160 TB media (the mirror)│           │ RS-Movies     10.0.0.160  (media NAS) │
 │  • Unraid Agent :8100       │           │ RS-TV         10.0.0.88   (media NAS) │
 │ Terminus      192.168.1.14  │           │ RS-4KMedia    10.0.1.203  (4K + DL)   │
 │  • Ali's Plex + Tautulli    │           │                                       │
 └─────────────────────────────┘           └──────────────────────────────────────┘
                 └────────────── IPsec VPN tunnel ──────────────┘
```

- **Mother** (10.0.0.162, Ubuntu VM at Chris's) runs *every* Docker service — Radarr/Sonarr,
  Upgraderr, Curatorr, sync-webhook, the observability stack, etc. This repo *is* Mother.
- **Chris's Synology devices** hold the primary/managed library:
  - **RS-Movies** (10.0.0.160) → HD movies
  - **RS-TV** (10.0.0.88) → HD TV
  - **RS-4KMedia** (10.0.1.203) → 4K movies + 4K TV **and the qBittorrent download stack**
- **Ali's Unraid** (192.168.1.10) is the **one-way mirror** — a full backup copy of Chris's
  library plus Ali's own originals. Mother reaches it over the VPN.
- **Terminus** (192.168.1.14) is Ali's own Plex/Tautulli host (separate from Chris's Plex).

---

## Who is the source of truth?

**Chris's Synology is authoritative.** Radarr/Sonarr manage files *on the Synology NAS*, and
Unraid mirrors them. Data flows **one way**: Synology → Unraid. The only reverse writes are
deliberate reconcile actions (e.g. restoring an Ali-original the Synology never had — see the
Highlander case) and are gated by Profile Authority. See [Sync Guide](SYNC_GUIDE.md).

---

## Path mappings (container → NAS → Unraid)

Every app sees the library through container mounts that map to the Synology NFS shares, which
in turn mirror to Unraid:

| App path | Synology (source of truth) | Unraid (mirror) |
|----------|----------------------------|-----------------|
| `/movies` | `/mnt/synology/rs-movies` (RS-Movies) | `/mnt/unraid/media/Movies` |
| `/movies-4k` | `/mnt/synology/rs-4kmedia/4kmovies` (RS-4KMedia) | `/mnt/unraid/media/4K Movies` |
| `/tv` | `/mnt/synology/rs-tv` (RS-TV) | `/mnt/unraid/media/TV Shows` |
| `/tv-4k` | `/mnt/synology/rs-4kmedia/4ktv` (RS-4KMedia) | `/mnt/unraid/media/4K TV Shows` |
| `/downloads` | `/mnt/synology/rs-4kmedia/downloads` (RS-4KMedia) | — |

Full detail: [Path Reference](PATH_REFERENCE.md).

---

## ⚠️ The cross-device import gotcha (read this)

**Downloads land on RS-4KMedia (10.0.1.203); the movie/TV libraries live on RS-Movies /
RS-TV (different devices).** So when Radarr imports a finished download, it is **copying the
file from one Synology to another** — it **cannot hardlink** across devices. Every import is a
real ~10–15 GB network copy that takes minutes.

This single fact explains a lot of operational behaviour:
- Bulk quality upgrades are **paced deliberately slowly** — the import copy, not the download,
  is the bottleneck. See [Quality Upgrades → Pacing](QUALITY_UPGRADES.md).
- qBit-first imports are still worth it (they skip the *indexer download*), but not "free" —
  they still pay the cross-device import copy.
- A growing Radarr download queue usually means "grabbing faster than it can import," not a
  stall.

---

## Reaching Unraid: always the Agent, never CIFS

Unraid is across the VPN, and CIFS listing of its 7,600+ folders is slow and flaky. **Every
service enumerates Unraid through the Unraid Agent** (`http://192.168.1.10:8100`, `X-Api-Key`),
never `os.listdir('/mnt/unraid/...')`. The CIFS mount at `/mnt/unraid/media` is used only for
actual rsync file transfers, not directory scans. See [Operations Guide](OPERATIONS.md) for
the CIFS-stale test.

---

## How a title moves through the system (end to end)

```
request (Overseerr/Seerr)
   → Radarr/Sonarr grab  → qBittorrent on RS-4KMedia (10.0.1.203)
   → import (cross-device copy) → Synology library (RS-Movies / RS-TV)
   → sync-webhook rsync over VPN → Unraid mirror
   → Upgraderr later force-grabs a better copy → repeats the flow
```

The acquisition/download half is detailed in the [Download Pipeline](DOWNLOAD_PIPELINE.md);
the quality half in [Quality Upgrades](QUALITY_UPGRADES.md); the mirror half in the
[Sync Guide](SYNC_GUIDE.md). Every container is listed in the [Service Reference](SERVICES.md).
