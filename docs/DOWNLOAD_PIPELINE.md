# Download Pipeline

**Last updated**: 2026-08-18

How a release actually gets from an indexer onto the Synology library. Most real-world
"why didn't this import?" issues originate here, so it's worth understanding the moving parts.

---

## The path a download takes

```
Prowlarr (indexer aggregation, :9696)
   → Radarr / Sonarr decide what to grab (governed by recyclarr profiles + custom formats)
   → qBittorrent  (on the DOWNLOAD Synology, RS-4KMedia 10.0.1.203)
   → download completes in /downloads/<category>/
   → unpackerr extracts archives if needed
   → Radarr/Sonarr import → cross-device COPY to the media Synology (RS-Movies / RS-TV)
   → cross-seed hardlinks the torrent for extra seeding; qbitmanage manages tags/limits/cleanup
```

Radarr/Sonarr never download anything themselves — they hand a release to qBittorrent and then
import the finished file. The **import is a cross-device copy** (downloads and library are on
different Synology boxes — see [Architecture](ARCHITECTURE.md)).

---

## The download stack lives on its own host

qBittorrent and its helpers do **not** run on Mother — they run on the **download Synology
(RS-4KMedia, 10.0.1.203)** as a real docker-compose stack (project name `mother-dlstack`,
git-tracked at `/opt/mother/remote-hosts/download-synology/`).

**SSH from Mother:** `ssh synology-dl` (key `~/.ssh/synology_dl_key`). Docker there needs the
full path and sudo: `sudo /usr/local/bin/docker compose -p mother-dlstack …`.

| Container | Port | Role |
|-----------|------|------|
| `qbittorrent` | 8080 | The download client. Autoheal + a startup hook clear stale lockfiles. |
| `qui` | 7476 | Modern multi-instance qBittorrent WebUI |
| `cross-seed` | 2468 | Hardlink cross-seeding (matches releases across trackers) |
| `qbitmanage` | — | Tags, categories, share-limits, orphaned-data cleanup (runs every 30 min) |
| `hawser` | — | Dockhand's remote agent (lets Mother's Dockhand manage this host) |
| `dozzle-agent` | 7007 | Streams this host's container logs into Mother's Dozzle |

---

## qbitmanage — the janitor (and its two footguns)

`qbitmanage` (config at `/volume1/docker/qbitmanage/config.yml` on the download Synology) runs
every 30 minutes to tag torrents, apply share limits, remove unregistered torrents, and clean
orphaned files. Two behaviours have caused real incidents:

1. **Orphaned-data race.** If a torrent finishes and is removed from qBittorrent *before*
   Radarr/Sonarr finish importing it, qbitmanage's sweep sees a "file with no torrent" and
   quarantines it into `/downloads/orphaned_data/`. Mitigations in place: `min_file_age_minutes`
   raised to **180** (give the import cycle time) and `empty_after_x_days` raised to **120**
   (don't auto-delete the quarantine too soon). **Recovery is NOT "move it back + rescan"** —
   that re-orphans it; use an explicit `ManualImport` by path. See [Operations](OPERATIONS.md).
2. **Unregistered-match gap.** Some trackers return bare `"Not Found"` which qbitmanage's stock
   match list missed, leaving torrents tagged `issue` forever. Fixed via a local
   `qbitmanage_util_override.py` that adds `"NOT FOUND"` to the match list (bind-mounted over
   the stock file — re-diff it before bumping the qbitmanage image).

---

## Acquisition vs. quality — two different engines

It's important to keep these separate:

- **Acquisition (speed):** Radarr/Sonarr **RSS sync** grabs new releases the moment they appear
  on an indexer feed — this is what gets a new episode/movie fast. RSS grabs *best-in-feed*.
- **Quality (best copy):** **Upgraderr** independently works the library toward the genuinely
  best release available (force-grab), correcting anything RSS grabbed that wasn't optimal.

> **RSS = speed, Upgraderr = quality.** See [Quality Upgrades](QUALITY_UPGRADES.md).

---

## decluttarr — queue hygiene on Mother

`decluttarr` (on Mother) watches the Radarr/Sonarr *download queues* and removes
stalled/failed-import/metadata-missing/orphaned items so the queue doesn't clog. It deliberately
does **not** own search-triggering (`search_missing`/`search_unmet_cutoff` disabled) — Upgraderr
owns that decision for this stack.

---

## Quick reference

```bash
# SSH to the download Synology
ssh synology-dl

# Restart the whole download stack
ssh synology-dl "cd /volume1/docker/qbittorrentstack && \
  sudo /usr/local/bin/docker compose -p mother-dlstack up -d"

# qBittorrent crash-looping right after a container recreate?  -> stale lockfile
#   rm -f /config/qBittorrent/lockfile /config/qBittorrent/ipc-socket  (then restart)
```
