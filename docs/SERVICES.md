# Service Reference

**Last updated**: 2026-08-18

Every container in the environment, what it does, and where it runs. All services run on
**Mother** (`docker compose` from `/opt/mother`) unless noted otherwise.

---

## Custom-built services (the heart of the system)

| Service | Port | Role |
|---------|------|------|
| **sync-webhook** | 5001 | Flask app. Receives Radarr/Sonarr webhooks and rsyncs new files to Unraid (append-only). Runs the nightly gap scan, version reconcile, library health report, and Unraid dedup. |
| **upgraderr** | 9706 | Quality-upgrade engine. 9-tier sweep every 30 min; force-grabs the best release; qBit-first imports; Remux→Bluray. See [Quality Upgrades](QUALITY_UPGRADES.md). |
| **curatorr** | 9707 | Media intelligence & curation UI (FastAPI + Vue). Library browser, composite/purge scoring, watch history, rules engine, duplicate scanner, **Sync Status** parity dashboard, direct deletion. |

## Media management

| Service | Port | Role |
|---------|------|------|
| radarr-hd / radarr-4k | 7878 / 7879 | HD / 4K movie management |
| sonarr-hd / sonarr-4k | 8989 / 8990 | HD / 4K TV management |
| prowlarr | 9696 | Indexer aggregation (feeds all *arr instances) |
| recyclarr | — | Pushes TRaSH quality profiles + custom formats into the *arr instances (config-only, scheduled). See [Recyclarr Setup](RECYCLARR_SETUP.md). |
| unpackerr | — | Auto-extracts archived downloads |
| decluttarr | — | Radarr/Sonarr download-queue hygiene (does NOT trigger searches — Upgraderr owns that) |
| overseerr / seerr | 5055 | Media requests |
| flaresolverr | 8191 | Cloudflare bypass for indexers |

## Monitoring & observability

| Service | Port | Role |
|---------|------|------|
| grafana | 3003 | Dashboards (Loki + Prometheus datasources) |
| prometheus | 9090 | Metrics scraping (30-day retention) |
| loki | 3100 | Log aggregation |
| promtail | — | Ships container + file logs to Loki |
| node-exporter / cadvisor | 9100 / 8090 | Host / per-container metrics |
| tautulli | 8181 | Chris's Plex watch history |
| tracearr (+ db, redis) | 3002 | Stream analytics (Node + TimescaleDB + Redis) |
| uptime-kuma | 3001 | Black-box availability checks |
| dozzle | 8080 | Live Docker log viewer (also fans in the download Synology's logs) |
| dockhand | 3000 | Cross-host container/image lifecycle + auto-update |

## Infrastructure

| Service | Port | Role |
|---------|------|------|
| nginx-proxy-manager | 80/443/81 | Reverse proxy + SSL |
| apprise | 8000 | Notification hub (Telegram) |
| backrest | 9898 | Restic backup UI |

---

## Not on Mother

| Service | Where | Role |
|---------|-------|------|
| **Unraid Agent** | Unraid (192.168.1.10:8100) | Fast Unraid filesystem inventory + scan + delete API. The **only** way anything enumerates Unraid — never CIFS listing. |
| **qBittorrent stack** | Download Synology (RS-4KMedia, 10.0.1.203) | qbittorrent, qui, cross-seed, qbitmanage, hawser, dozzle-agent. See [Download Pipeline](DOWNLOAD_PIPELINE.md). |
| Ali's Plex / Tautulli | Terminus (192.168.1.14) | Ali's own playback + history (separate from Chris's) |

---

## How they fit together

```
recyclarr ──config──▶ Radarr/Sonarr ◀──triggers searches── Upgraderr
                          │ webhook on import                    │ 9-tier sweep +
                          ▼                                      │ force-grab / qBit-first
                    sync-webhook ──rsync──▶ Unraid Agent          ▼
                          │                                  records before/after,
                          ▼                                  flags bad imports
                       Curatorr (browse, score, dedup, rules, sync-status)
```

- **recyclarr** decides what Radarr is *allowed* to grab and how releases score.
- **Radarr/Sonarr** are the grab-time decision-makers, governed by that config and by
  [Profile Authority](PROFILE_AUTHORITY.md).
- **Upgraderr** decides *when to search* and force-grabs the best release; it never downloads
  anything itself.
- **sync-webhook** mirrors Synology→Unraid (append-only webhooks; nightly reconcile is the only
  thing that deletes on Unraid, and only per Profile Authority).
- **Curatorr** is the read/analysis + manual-action UI over everything.

Deployment and troubleshooting: [Operations Guide](OPERATIONS.md).
Overall layout: [Architecture](ARCHITECTURE.md).
