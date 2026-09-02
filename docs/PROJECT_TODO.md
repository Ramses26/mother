# Project Mother — open items & audit state

Last full audit: **2026-09-01**. Keep this file current; it is the single place to look
for "what's outstanding".

---

## Scheduled checkpoints

| When | What |
|---|---|
| **2026-09-15** (2 weeks) | **Queue janitor Phase 2 review.** Read `GET /api/janitor/findings?days=14` and the Sunday digest. Decide: which classes are safe to act on, what new patterns showed up as `unclassified`. See §Phase 2 below. |
| 2026-09-08 (1 week) | Sanity-check the 14 Grafana alert rules — any firing constantly is mistuned and will cause alert fatigue. Adjust thresholds, don't disable. |
| Ongoing | First real `hnr_content_removed` alert: verify it correlates with a qbitmanage 120d cleanup before assuming benign. |

---

## 1. Queue janitor — Phase 2 (the main open work)

**State:** Phase 1 live since 2026-09-01, `janitor_report_only=true`, scanning every 30 min.
Design + measured API semantics: `docs/research/queue-janitor-design.md`.

Phase 1 already earned its place. Within an hour of going live it recorded **12 Doctor Who
S19 episode downloads as `stalled` with `hnr_safe=0`** — old 1982 BluRay releases with few
seeders. Decluttarr would have deleted and blocklisted all 12 inside 30 minutes (3 strikes
× 10 min), producing 12 fresh HnRs on the exact releases being recovered. The janitor
recorded them and did nothing. **That false-positive class is the whole reason for the
rewrite** — a stalled private-tracker torrent is usually just short of peers.

**Phase 2 gate — do not skip:**
1. Pull ≥14 days of findings. Review the `unclassified` bucket — those are candidate rules.
2. Confirm `blocklist=true` + `removeFromClient=false` behave together as expected. This is
   the one API combination not yet exercised live (§2.4 of the design doc).
3. Enable `already_imported` **only** (ignore, no blocklist, no re-search). Lowest risk: the
   file is already in the library and the torrent is untouched.
4. Leave `stalled` and `failed_import` in report-only until at least one more cycle — the
   Doctor Who case above shows how easily `stalled` misfires here.

**Phases 3–4** (failed_import + stalled; then optional client removal for `missing_files`
only, gated on the HnR invariant) — see the design doc.

**Never** port decluttarr's `remove_orphans`. **Never** default `removeFromClient=true`.

---

## 2. Auto-remediation / triggered agent

Ali's ask: an alert should be able to start an investigation without waiting for him to
relay it, which can take hours.

**Agreed direction (not yet built):** an alert webhook that launches a *diagnose-only*
headless Claude Code run with the repo + CLAUDE.md as context, posting findings to the
Mother Notifications Telegram group. Read-only first; no write access until it has proven
itself over real incidents.

**Local LLM — hardware is no longer the objection.** Mother's ESXi host is a ProLiant DL380
Gen10, 2× Xeon Gold 6246R (64 logical CPUs), **191 GB RAM with 161 GB free**, 5.29 TB free,
3 VMs. Plenty of headroom. The remaining objections are:
- **No GPU.** CPU-only inference on 64 threads is usable for background batch analysis, not
  interactive work. The DL380 Gen10 *can* take a GPU — that changes the calculus.
- **Model quality.** A 7–14B model is not good enough to safely diagnose this stack.
- **Write access is the real risk, not compute.** This project's incident history is
  automation acting confidently and wrongly: 6,038 files deleted by dedup, 314 movies
  downgraded, 55 HnRs from decluttarr. Adding an autonomous actor with delete authority
  repeats that pattern.

**Order of work:** deterministic auto-heal for known failures → alerts that carry their own
runbook → triggered diagnose-only agent → (only then) consider anything that acts on its own.

---

## 3. Open items found during the 2026-09-01 audit

| Priority | Item |
|---|---|
| Medium | **34 entries left in `orphaned_data` (~496 GB).** The 86 provably-safe ones were deleted (362 GiB reclaimed). What remains is mostly `cross-seed/` hardlink copies plus 4 standalone .mkv files. Needs a per-item check against the library before deletion. qbitmanage auto-empties at 120 days regardless. |
| ~~Medium~~ | ~~`sync_stall_check.sh` cron drift~~ — **RESOLVED 2026-09-01: obsolete, correctly retired.** Written 2026-02-02 to alert if <100 MB/hour moved *during batch sync*; both batch syncs are complete and sentinel-disabled, and it last ran 2026-07-04. Its job is now covered by sync-webhook's own `check_stalled_syncs` (per-rsync, every 15 min). CLAUDE.md's cron table was the stale part and has been corrected. |
| Medium | **Radarr/Sonarr `database is locked` ~54/day.** Benign at this rate but it is the same SQLite-under-load theme as the Upgraderr corruption. Now alerted above background. |
| ~~Medium~~ | ~~Mother root filesystem at 78%~~ — **RESOLVED 2026-09-01: 78% -> 54%**, 36 GB reclaimed (31.5 GB unused images + 4.7 GB build cache). No VM expansion needed. **Dangling volumes were deliberately NOT pruned** — 4.9 GB, but they include `mother_tracearr_postgres` / `mother_tracearr_data` / `overseerr-data`, which may hold historical data. Not worth the risk. |
| Low | **`hawser` on the download Synology emits zero stdout**, so it cannot be observed in Loki. It has a healthcheck + autoheal, and it has silently exited for 6 days before (2026-07-19). Consider an Uptime Kuma docker-container monitor. |
| Low | **Stale Loki host labels** `unifi` and `unifi-stuttler` (0 lines/24h); `stuttler-udm` is the live one at ~67k lines/24h. Cosmetic, ages out at 30d retention. |
| Low | **Tautulli/Tracearr lose Plex periodically.** Now alerted at a high threshold. Watch history is not backfilled, so sustained outages lose data permanently. |
| Low | **12,787 rotated `qbittorrent.log.bak*` files (850 MB)** still on the download Synology. `file_log_max_size` is fixed (65 KiB → 10 MiB) so it won't regrow; the existing backlog is Ali's call. |



---

## 3b. Shelved / parked (Ali, 2026-09-01)

### Tier 10 — search for missing content — **SHELVED**
Deliberately not built: it would add a lot of downloads and disk usage, and the other work
comes first. Research is done and the filter is already sized against the live library, so
this is ready to pick up whenever wanted.

**Better approach Ali proposed — do this instead of the filters:** *unmonitor the junk shows
in Sonarr.* That fixes the data at the source rather than working around it, and it benefits
Sonarr's own searches, Curatorr and the reports too — not just Upgraderr. If the library is
cleaned up that way, Tier 10 becomes a thin "search monitored+missing" tier with almost no
filtering logic.

Measured 2026-09-01 (keep — it is the sizing argument):

```
8,073 missing episodes (sonarr-hd)          82 released monitored+missing movies (radarr-hd)
  -3,926  aired >20y ago .... Looney Tunes 681, Doctor Who 556, El Chapulin 260, Garfield 180
  -1,799  reality/game show/talk show/news
  -1,037  series with >100 missing .... Ridiculousness 991, Dateline 209
= 1,311 episodes across 90 shows
```

Note: **Dateline is genre `Crime/Documentary`, so a genre filter alone does not catch it** —
it takes the per-series volume cap. Radarr needs no age filter (only 82 items).

### Release-group statistics — **parked, wanted**
Ali's idea: show which release groups the library holds and how many of each, the same way
codecs/resolutions are already broken out. Natural home is **Curatorr** (it is the analysis
/ browsing layer and already computes library-wide stats); Upgraderr's `_tier9_candidate`
already reads `releaseGroup` and the TRaSH group-tier custom formats, so the tier mapping to
join against exists. Would make Tier 9's behaviour legible — "we hold N files from Tier-3
groups" — instead of a 6,993-item queue with no visible shape.

### Dozzle — **keep**
Asked whether it is redundant now everything ships to Loki. It overlaps, but keep it:
- It costs ~39 MB RAM and 0.9% CPU.
- It is an **independent path**. Grafana/Loki only helps when the Loki pipeline is working;
  the failures this project actually hits (Alloy config error taking the agent down, a bad
  Loki datasource, a wedged container) are exactly when Dozzle is the thing that still works.
- Live tail with no LogQL is faster for "what is this container doing right now".

Revisit only if it starts costing something.

---

## 3a. CRITICAL — there is no file-level backup running

**Found 2026-09-01. Backrest has never backed up anything.**

It has run since 2026-03-21 and looks healthy in `docker ps`, which is exactly why this went
unnoticed — it presents as "we have backups". Evidence:

- No `config.json` anywhere in its data dir — **no repos and no plans are configured**.
- `oplog.sqlite` → `operations` table: **0 rows**. Not one backup operation, ever.
- Its only recurring log line is `running task {"task": "collect garbage"}` on an empty log.
- No restic repository exists on disk.

Its mounts are already correct (`/opt/mother` → `/backups/mother`, `/opt/mother/data` →
`/backups/data`), so only a repo + plan is missing.

**So the current off-box protection is: VMware snapshots, plus git for whatever is committed.**
Not covered by either: `.env` (gitignored, holds every API key), all four *arr `/config`
databases, Upgraderr/Curatorr SQLite, Grafana/Prometheus/Loki data, and `configs/` content
that is gitignored.

**Needs a decision from Ali before it can be finished** — restic destination:
1. Local path on Mother (weakest — same VM, dies with it)
2. NFS/SMB to the Synology or Unraid (good, off-box, no credentials to manage)
3. Cloud (B2/S3 — best durability, needs an account + keys)

**Then:** a plan covering `/backups/mother` + `/backups/data`, a retention policy, and a
"last successful backup is older than N days" check. A Loki alert will NOT work for this —
backrest logs nothing when idle, which is the whole failure mode. It needs an active check
(`operations` table freshness) in `container_watchdog.py` or a small cron.

---

## 4. Should Upgraderr move off SQLite?

Corruptions: 2026-05-22, 06-21, 07-03, 07-06, 07-09, 08-30 — **six**, not ten.

**Recommendation: don't migrate yet.** Two things were fixed on 2026-09-01 that address most
of the pain:
- `create_backup` no longer raw-copies a live WAL database (it now uses SQLite's online
  backup API and verifies with `quick_check`). **The backups themselves were unreliable** —
  that is what made past corruptions so costly, and three of the ten stored backups were
  malformed.
- A `upgraderr_db_corruption` alert now exists. The last one logged **797 times over 3 days**
  and nobody knew.

Also: the 08-30 corruption cost **zero rows**. It was isolated to `sqlite_sequence`, and a
table-by-table rebuild recovered everything. Corruption correlates with hard reboots of the
VM, not with SQLite's normal operation.

**If it recurs after these fixes, migrate — and use `tracearr-db`** (PostgreSQL 18, already
running) rather than standing up new infrastructure. Upgraderr only, to start.

---

## 5. Observability coverage — verified 2026-09-01

| Host | Containers | Shipping to | Status |
|---|---|---|---|
| Mother | 30 | own Loki `10.0.0.162:3100` | **30/30** over a 3-day window |
| Download Synology | 8 | Mother's Loki | 7/8 — `hawser` emits no stdout |
| Nostromo | Plex | Mother's Loki | ✅ |
| Stuttler UDM | syslog | Mother's Loki | ✅ ~67k lines/24h |
| Unraid, Terminus, hathor, wadjet, Gomaa UDM | 77 services | **Terminus's Loki `192.168.1.14:3100`** | ✅ — absent from Mother's Loki **by design** |

Checking a 6-hour window gives false negatives: 6 Mother containers are simply idle
(`apprise`, `dozzle`, `node-exporter` emit nothing for hours). Use ≥24h.

**qBittorrent writes nothing to stdout** — its file log is tailed separately by Alloy. The
`Torrent removed` + `Torrent content removed` pair is the Hit-and-Run fingerprint and is now
alerted.

### The 14 alert rules

`qbitmanage_error_watchdog` · `unifi_tunnel_down` · `unifi_wan_down` · `mother_container_down`
· `mother_disk_space_low` · `mother_watchdog_heartbeat_stale` · `upgraderr_db_corruption` ·
`qbittorrent_auth_failure` · `hnr_content_removed` · `upgraderr_backup_failed` ·
`sync_webhook_nfs_missing` · `arr_indexer_disabled` · `plex_unreachable` ·
`arr_database_locked`

All labelled `team: infra` → Mother Notifications Telegram group.

> **The lesson worth keeping:** every incident in this session was *already being logged*,
> loudly, for days. 797 corruption errors. 193 login failures. 407 NFS-mount errors. The gap
> was never detection or intelligence — nothing was reading logs we already had. **Before
> building anything clever for a failure class, check whether the signal is already in Loki
> and just needs a rule.**

---

## 6. Done 2026-09-01 (for reference)

- Decluttarr **removed** — 306 torrents deleted in 29 days (82 TorrentLeech) = 55 HnRs.
- qBittorrent's file log now shipped to Loki; `file_log_max_size` 65 KiB → 10 MiB.
- Blocklist purged: 406 decluttarr-era entries (89 radarr-hd + 317 sonarr-hd), one
  pre-decluttarr entry kept. Export at `data/backups/blocklist-pre-purge-2026-09-01.json`.
- `orphaned_data`: 362 GiB reclaimed, 86 entries; zero torrents harmed (`missingFiles`
  stayed at exactly 32).
- Queue janitor Phase 1 shipped (report-only).
- **Bug:** qBittorrent login broken since 2026-06-17 (5.x returns HTTP 204 + empty body, not
  `"Ok."`). Upgraderr tagging had never worked. Fixed.
- **Bug:** `create_backup` raw-copied a live WAL DB. Fixed + verified.
- **Incident:** Upgraderr DB corrupt since 2026-08-30; rebuilt with zero row loss.
- Doctor Who S19: 15 missing episodes re-searched per-episode (~35 GB) after aborting a
  330 GB season pack that had already failed import twice.
