# Project Mother — System Workflow Diagram
*Last Updated: 2026-06-18*

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
                           │ Jobs queued in  │         │ 6 Tiers:         │
                           │ SQLite. rsync   │         │ T1 m2ts          │
                           │ over VPN.       │         │ T2 non-MKV       │
                           │ Auto-retry ×20  │         │ T3 720p/SD ←NOW  │
                           │                 │         │ T4 BluRay avail  │
                           └────────┬────────┘         │ T5 no surround   │
                                    │                  │ T6 low score     │
                                    │                  │                  │
                                    │                  │ Triggers search  │
                                    │                  │ in *arr. After   │
                                    │                  │ 2 failed tries → │
                                    │                  │ fallback sync    │
                                    │                  │ (sync 720p now,  │
                                    │                  │ upgrade later)   │
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

```
Every 30 minutes:
┌──────────────────────────────────────────────────────────────┐
│                     UPGRADERR SWEEP                          │
│                                                              │
│  Query all 4 *arr instances → classify each file by tier     │
│                                                              │
│  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐  ┌─────┐  ┌──────┐│
│  │ T1   │  │ T2   │  │ T3   │  │ T4   │  │ T5   │  │ T6  │  │ T7   ││
│  │m2ts  │  │non   │  │720p  │  │BluRay│  │no    │  │low  │  │prof. ││
│  │      │  │MKV   │  │SD    │  │avail │  │surr. │  │score│  │mis-  ││
│  │      │  │      │  │      │  │      │  │      │  │     │  │match ││
│  └──┬───┘  └──┬───┘  └──┬───┘  └──┬───┘  └──┬───┘  └──┬──┘  └──┬───┘│
│     └─────────┴──────────┴─────────┴──────────┴─────────┴─────────┘   │
│                           │                                   │
│              Budget: 5 searches/instance/sweep                │
│              (random order within tier)                       │
│                           │                                   │
│              ┌────────────▼───────────────┐                  │
│              │  Send MoviesSearch or       │                  │
│              │  EpisodeSearch API call     │                  │
│              │  to Radarr/Sonarr           │                  │
│              └────────────┬───────────────┘                  │
│                           │                                   │
│              ┌────────────▼───────────────┐                  │
│              │  search_count >= 2 AND      │                  │
│              │  tier == 3 (720p)?          │                  │
│              │                             │                  │
│              │  YES → trigger fallback     │                  │
│              │  sync: POST /sync/manual    │                  │
│              │  (sync current 720p to Ali) │                  │
│              └─────────────────────────────┘                  │
└──────────────────────────────────────────────────────────────┘

  Radarr/Sonarr grabs upgrade → fires webhook → sync-webhook
  syncs new file → Upgraderr /webhook/radarr records before/after
```

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
│  Key: until_score = -9999 on all profiles               │
│  (prevents autonomous CF-score-chasing searches)        │
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

| Content | Synced? | Reason |
|---|---|---|
| 1080p movies/TV | ✅ Yes | Primary target |
| 4K movies/TV | ✅ Yes | Separate sync pass |
| 1080p x265 with DV/HDR | ✅ Yes | HDR justifies x265 |
| **720p / SD** | ❌ No | Upgraderr handles upgrade on Chris's side first |
| **x265 without HDR/DV** | ❌ No | Recyclarr blocks; Upgraderr finds proper source |
