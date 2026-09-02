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
| Medium | **`sync_stall_check.sh` is in CLAUDE.md's cron table but NOT in the live crontab.** Either it was deliberately retired (then fix the doc) or it was lost. Verify which. |
| Medium | **Radarr/Sonarr `database is locked` ~54/day.** Benign at this rate but it is the same SQLite-under-load theme as the Upgraderr corruption. Now alerted above background. |
| Medium | **Mother root filesystem at 78%** (32 GB free of 145 GB). Alert fires at 90%. Worth trimming before it gets there. |
| Low | **`hawser` on the download Synology emits zero stdout**, so it cannot be observed in Loki. It has a healthcheck + autoheal, and it has silently exited for 6 days before (2026-07-19). Consider an Uptime Kuma docker-container monitor. |
| Low | **Stale Loki host labels** `unifi` and `unifi-stuttler` (0 lines/24h); `stuttler-udm` is the live one at ~67k lines/24h. Cosmetic, ages out at 30d retention. |
| Low | **Tautulli/Tracearr lose Plex periodically.** Now alerted at a high threshold. Watch history is not backfilled, so sustained outages lose data permanently. |
| Low | **12,787 rotated `qbittorrent.log.bak*` files (850 MB)** still on the download Synology. `file_log_max_size` is fixed (65 KiB → 10 MiB) so it won't regrow; the existing backlog is Ali's call. |

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
