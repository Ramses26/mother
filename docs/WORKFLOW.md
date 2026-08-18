# Project Mother — System Workflow Diagram
*Last Updated: 2026-08-18*

> See also: [Architecture](ARCHITECTURE.md) · [Download Pipeline](DOWNLOAD_PIPELINE.md) ·
> [Quality Upgrades](QUALITY_UPGRADES.md) · [Profile Authority](PROFILE_AUTHORITY.md)

---

## Full Data Flow

```
                        ╔══════════════════════════════════════════╗
                        ║         CONTENT ACQUISITION              ║
                        ║                                          ║
                        ║   Prowlarr (9696) — indexer aggregator   ║
                        ║       │                │                 ║
                        ║  Radarr-HD (7878)  Sonarr-HD (8989)     ║
                        ║  Radarr-4K (7879)  Sonarr-4K (8990)     ║
                        ║       │                │                 ║
                        ║  qBittorrent (on Synology RS-4KMedia)    ║
                        ║       │                │                 ║
                        ║  [Downloaded to NFS-mounted Synology]    ║
                        ╚══════════════════════════╤═══════════════╝
                                                   │
                                    ┌──────────────┴──────────────┐
                                    │                             │
                           ┌────────▼────────┐         ┌─────────▼────────┐
                           │  WEBHOOK SYNC   │         │    UPGRADERR     │
                           │  (port 5001)    │         │    (port 9706)   │
                           │                 │         │                  │
                           │ Radarr/Sonarr   │         │ Sweep every 30m  │
                           │ fires webhook   │         │ Scans all *arr   │
                           │ on import       │         │ instances        │
                           │                 │         │                  │
                           │ Jobs queued in  │         │ 9 Tiers:         │
                           │ SQLite. rsync   │         │ T1 m2ts          │
                           │ over VPN.       │         │ T2 non-MKV       │
                           │ Auto-retry ×20  │         │ T3 720p/SD       │
                           │ Multi-ep aware  │         │ T4 BluRay avail  │
                           └────────┬────────┘         │ T5 no surround   │
                                    │                  │ T6 low score     │
                                    │                  │ T7 profile mism. │
                                    │                  │ T8 x265 no-HDR   │
                                    │                  │ T9 best-release  │
                                    │                  │   (FORCE-GRAB +  │
                                    │                  │    qBit-first)   │
                                    │                  └─────────┬────────┘
                                    │                            │ (webhook fires
                                    │                            │  on upgrade)
                                    └──────────────┬─────────────┘
                                                   │
                                                   │  rsync over IPsec VPN
                                                   │  Chris (10.0.0.x) →
                                                   │  Ali  (192.168.1.x)
                                                   │
                                    ╔══════════════▼══════════════╗
                                    ║       ALI'S UNRAID          ║
                                    ║    (192.168.1.10:8100)      ║
                                    ║                             ║
                                    ║  /mnt/user/Media/           ║
                                    ║  ├── Movies/                ║
                                    ║  ├── 4K Movies/             ║
                                    ║  ├── TV Shows/              ║
                                    ║  └── 4K TV Shows/           ║
                                    ║                             ║
                                    ║  Unraid Agent (port 8100)   ║
                                    ║  Fast inventory API         ║
                                    ╚═════════════════════════════╝
```

---

## Upgraderr Quality Pipeline

Full detail in **[Quality Upgrades](QUALITY_UPGRADES.md)**. Summary of the every-30-min sweep:

```
Query all 4 *arr instances → classify each file into the highest-priority tier (1–9)
        │
        │  Budget: 2 searches/instance, 3 global per sweep  (deliberately slow —
        │          the cross-device import copy is the bottleneck, not the download)
        ▼
   ┌───────────────────────────────┬────────────────────────────────────────┐
   │  Tiers 1–8                     │  Tier 9 (best-release / Remux→Bluray)    │
   │  → MoviesSearch/EpisodeSearch  │  → FORCE-GRAB the highest-CF release      │
   │    (Radarr/Sonarr picks)       │    Upgraderr picks the exact release;     │
   │                                │    qBit-FIRST imports an existing good    │
   │                                │    copy for free when one exists          │
   └───────────────────────────────┴────────────────────────────────────────┘
        │
        ▼
   Radarr/Sonarr import (cross-device copy) → webhook → sync-webhook mirrors to Unraid
   → Upgraderr /webhook records before/after and flags bad imports (_flag_if_bad_import)
```

Key points that changed in Aug 2026:
- **9 tiers** (added T8 x265-no-HDR, T9 release-group quality).
- **Tier 9 force-grabs** the genuinely-best release instead of a search-and-hope — because
  RSS/normal search only grabs best-*in-feed*, not best-*available*.
- **qBit-first** imports an existing good copy from qBittorrent instead of re-downloading.
- **Pace cut to 2/3** and **`until_score` raised to 5600** (radarr-hd) so upgrades can climb to
  the best releases. RSS = speed, Upgraderr = quality.

---

## Recyclarr Quality Profile Flow

```
recyclarr.yml (configs/recyclarr/recyclarr.yml)
        │
        │  docker compose run --rm recyclarr sync
        ▼
┌─────────────────────────────────────────────────────────┐
│              QUALITY PROFILES IN *ARR                    │
│                                                         │
│  Radarr-HD:                                             │
│  ├── HD Bluray + WEB   cutoff=Bluray-1080p              │
│  └── Remux + WEB 1080p cutoff=Remux-1080p              │
│                                                         │
│  Radarr-4K:                                             │
│  ├── UHD Bluray + WEB  cutoff=Bluray-2160p              │
│  └── Remux + WEB 2160p cutoff=Remux-2160p              │
│                                                         │
│  Sonarr-HD:                                             │
│  ├── WEB-1080p          cutoff=WEB 1080p                │
│  ├── Bluray-1080p       cutoff=Bluray-1080p             │
│  └── Remux-1080p        cutoff=Bluray-1080p Remux       │
│                                                         │
│  Sonarr-4K:                                             │
│  ├── WEB-2160p          cutoff=WEB 2160p                │
│  ├── Bluray-2160p       cutoff=Bluray-2160p             │
│  └── Remux-2160p        cutoff=Bluray-2160p Remux       │
│                                                         │
│  until_score: radarr-hd profiles 7 & 8 = 5600 (lets      │
│  upgrades reach the best releases); 4K + Sonarr vary.    │
│  See Quality Upgrades → Pacing.                          │
└─────────────────────────────────────────────────────────┘
```

---

## TV Sync — Steady State (as of June 17 2026)

TV batch sync (`tvsync` screen) completed June 17 2026. All 64,818 rsync operations completed.
The `tvsync` screen is no longer needed — nightly gap scanner handles ongoing sync.

```
Synology RS-TV (10.0.0.88)            Ali's Unraid (192.168.1.10)
  Radarr/Sonarr managed               Mirror of Synology
  Source of truth                             │
         │                                    │
         │  Nightly gap scan (11 PM ET)        │
         └──── finds missing episodes ────────►│
         │                                    │
         │  Nightly version reconcile (11:15)  │
         └──── replaces outdated files ───────►│
         │                                    │
         │  Real-time webhook sync             │
         └──── new downloads copied ──────────►│
```

---

## Network Topology

```
Chris's Location (10.0.0.0/23)              Ali's Location (192.168.1.0/24)
┌──────────────────────────┐                ┌──────────────────────────┐
│  Mother VM (10.0.0.162)  │                │  Unraid (192.168.1.10)   │
│  ├── All Docker services │                │  ├── 160TB media library  │
│  ├── Radarr/Sonarr x4    │                │  └── Unraid Agent :8100  │
│  ├── Upgraderr           │                │                          │
│  ├── sync-webhook        │  IPsec VPN     │  Terminus (192.168.1.14) │
│  ├── Curatorr            │ ◄────────────► │  ├── Plex server         │
│  └── Observability       │  ~200 Mbps     │  └── Tautulli            │
│                          │                │                          │
│  RS-TV (10.0.0.88)       │                └──────────────────────────┘
│  RS-Movies (10.0.0.160)  │
│  RS-4KMedia (10.0.1.203) │
└──────────────────────────┘
```

---

## Sync Path Mappings

| Content | Mother Container Path | NFS Source | Unraid Destination |
|---|---|---|---|
| HD Movies | `/movies` | `/mnt/synology/rs-movies` | `/mnt/user/Media/Movies` |
| 4K Movies | `/movies-4k` | `/mnt/synology/rs-4kmedia/4kmovies` | `/mnt/user/Media/4K Movies` |
| HD TV | `/tv` | `/mnt/synology/rs-tv` | `/mnt/user/Media/TV Shows` |
| 4K TV | `/tv-4k` | `/mnt/synology/rs-4kmedia/4ktv` | `/mnt/user/Media/4K TV Shows` |

---

## What Is and Is NOT Synced

**Since 2026-07-25 — absolute parity:** *every* Synology file syncs to Unraid regardless of
quality tier. The old 720p / x265-no-HDR sync exclusions are **gone** — Upgraderr upgrades those
independently, but Unraid mirrors whatever Synology currently has in the meantime.

| Content | Synced? | Reason |
|---|---|---|
| 1080p movies/TV | ✅ Yes | Primary target |
| 4K movies/TV | ✅ Yes | Separate sync pass |
| 1080p x265 with DV/HDR | ✅ Yes | HDR justifies x265 |
| 720p / SD | ✅ Yes (since 2026-07-25) | Absolute parity; Upgraderr still searches for a better source |
| x265 without HDR/DV | ✅ Yes (since 2026-07-25) | Absolute parity; recyclarr still blocks it at grab-time, Upgraderr Tier 8 upgrades it |

> Note on direction: Synology remains authoritative and protected. The reverse direction
> (Unraid→Synology) still refuses to push a quality-excluded Unraid file up to Synology.
