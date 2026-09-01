# Queue Janitor — research + design

**Status:** research complete, not yet built. Replaces decluttarr (removed 2026-09-01, commit `5905d54`).
**Home:** `services/upgraderr/app.py` — not a new service. See [Why Upgraderr](#why-it-lives-in-upgraderr).

---

## 1. Why decluttarr had to go

Not a tuning problem. Three independent design decisions made it structurally wrong for this stack.

### 1.1 It always deletes the data

Every removal path funnels through `RemovalHandler._remove_download` →
`arr.remove_queue_item(queue_id, blocklist)` → `_instances.py:328`:

```python
query = {"removeFromClient": True, "blocklist": blocklist}
```

`removeFromClient` is **hardcoded True**. There is no setting, per-job or global, that changes
it. Torrent gone, data gone, seeding stops — which is the definition of a tracker Hit-and-Run.

### 1.2 Its only safety valve is all-or-nothing, and every one of our indexers is private

`general.private_tracker_handling` (default `"remove"`, `_general.py:16`) is the only guard.
Valid values are `remove` / `skip` / `obsolete_tag`. All 8 Prowlarr indexers are private:

```
Aither  BeyondHD  HD-Torrents  IPTorrents  MoreThanTV  OldToonsWorld  PrivateHD  TorrentLeech
```

So the setting governs 100% of traffic, and the two safe values reduce decluttarr to a no-op or
a tagger. There is no configuration that leaves it both safe and useful here. Neutering it would
have left a container that does nothing.

### 1.3 `remove_orphans` deletes healthy downloads

Biggest single killer: 138 of 306 total removals, 48 of the 82 TorrentLeech ones.

Its detection (`queue_manager.py:40`) is a **whole-dict equality diff between two separate live
HTTP fetches** of the queue:

```python
full_queue   = await self._get_queue(full_queue=True)    # includeUnknownMovieItems=true
normal_queue = await self._get_queue(full_queue=False)
queue_items  = [fq for fq in full_queue if fq not in normal_queue]
```

Anything present in the first snapshot but not byte-identical in the second is deleted. Queue
records carry volatile fields (`sizeleft`, `timeleft`, `estimatedCompletionTime`, `status`,
`statusMessages`), and a `RefreshMonitoredDownloads` is fired immediately before both fetches.

Observed consequences — these movies are all still in Radarr, monitored, with a file:

| Title | Killed as "orphan" | Re-grabbed and imported |
|---|---|---|
| Uncharted 2022 …LEGi0N | 08-19 11:40 | 08-20 |
| The Outpost 2020 …HDChina | 08-23 13:44 | 08-26 |
| Tolkien 2019 …HDH | 08-22 + 08-23 (twice) | — |

Removals also arrive in same-second bursts (8 at 08-23 13:44, 4 at 08-19 19:16), which is the
signature of a snapshot mismatch rather than genuine orphans.

**Do not port this job.**

### 1.4 Blast radius was not TorrentLeech-only

306 removals in 29 days. By indexer (matched against *arr grab history):

```
TorrentLeech 82   IPTorrents 69   HD-Torrents 37   Aither 24
OldToonsWorld 6   BeyondHD 4      PrivateHD 2      (unmatched) 82
```

Current at-risk pool in the client (below both 1:1 and 144h) spans everything:

```
iptorrents 375   Beyond-HD 372   TorrentLeech 154   HDTorrents 68   aither 57   PrivateHD 6
```

TorrentLeech is just where it costs money, so it's where it got noticed.

---

## 2. Verified *arr API semantics

Tested live 2026-09-01 against Sonarr v4.0.19.2979 and Radarr v6.3.0.10514. **These are
measurements, not assumptions.**

### 2.1 The core call

```
DELETE /api/v3/queue/{id}?removeFromClient=false&blocklist=false&skipRedownload=true
```

Test case: `Breaking.Amish.S03…NTb`, 12 queue rows stuck at `completed/warning/importBlocked`
with `Episode file already imported`, torrent seeding on Beyond-HD at 43.8h / ratio 0.00 —
i.e. exactly the kind of thing decluttarr would have deleted into an HnR.

| Check | Result |
|---|---|
| Queue rows before → after | 12 → **0** |
| Torrent still in client | **yes**, `stalledUP`, still seeding (44.6h) |
| History event written | `downloadIgnored` ×12 |
| Survives `RefreshMonitoredDownloads` | **yes**, queue stays 0 |
| Survives full `docker restart sonarr-hd` + refresh | **yes**, queue stays 0 |

### 2.2 Deleting one row clears the whole download

All 12 rows shared one `downloadId` and one DELETE cleared every one of them. **The janitor must
deduplicate by `downloadId`, not iterate queue ids** — otherwise it issues N redundant deletes
and miscounts its own actions.

### 2.3 The ignore is persisted, not in-memory

This was the make-or-break unknown, and the answer is better than expected. Both `radarr.db` and
`sonarr.db` have a `DownloadHistory` table; the ignore writes `EventType = 4`:

```
sonarr-hd DownloadHistory EventType counts: 1:6902  2:6367  3:317  4:68  5:22857
radarr-hd                                   1:3207  2:2913  3:90   4:29  5:2908
```

(`1` grabbed, `2` imported, `3` failed, `4` **ignored**, `5` file imported.) Our test wrote row
`37309, EventType 4` at `22:34:52`. Because it is on disk, the *arr will not re-surface that
`downloadId` in the queue after a restart. **No local "already handled" table is required** —
though the janitor should still be idempotent (re-ignoring is a harmless 200).

### 2.4 `blocklist=true` writes to the `Blocklist` table

Persistent, with `TorrentInfoHash`, so the exact release is not re-grabbed. Current counts:
radarr-hd 90, sonarr-hd 317 — nearly all `Message = "Manually marked as failed"`, i.e.
decluttarr's own trail. History event is `downloadFailed`.

**Still to verify during report-only:** that `blocklist=true` combined with
`removeFromClient=false` behaves as expected (blocklists the release *and* leaves the torrent).
The parameters are independent in the controller signature, but both queues were empty at
research time so this specific combination was not exercised.

### 2.5 `changeCategory` / any category-move approach is OFF THE TABLE

Tempting alternative — move the torrent to a post-import category so the *arr stops tracking it.
It would destroy data. qBittorrent preferences:

```
auto_tmm_enabled             = True     (6,492 of 12,474 torrents have auto_tmm=true — all *arr ones)
category_changed_tmm_enabled = True     ("relocate when category changed")
save_path                    = /downloads
```

Every category has `savePath: ""`, so the path is derived as `/downloads/<category>`. Changing
category on an auto-TMM torrent therefore **relocates its files**. `movieImportedCategory` /
`tvImportedCategory` are both unset today; leave them unset. Do not set `changeCategory=true`.

---

## 3. The safety invariant

> **Never remove a torrent from the download client unless it has already satisfied the
> strictest HnR requirement we are subject to: `seeding_time >= 144h` OR `ratio >= 1.0`.**

144h / 1:1 is TorrentLeech's published rule ("Seed for 144 Hours (6 days)" OR "reach a ratio of
1:1"). Both fields come straight from qBittorrent's `/torrents/info`, so the check is local,
cheap, and needs no tracker API.

Validated against the live client: **11,438 of 12,474 torrents already pass**, only 1,036 are
protected at any moment. So this is not a straitjacket — it blocks exactly the window that
generates HnRs.

Corollaries:

- **Default action is always `removeFromClient=false`.** Removal-with-data is a separate,
  opt-in path gated on the invariant.
- **Incomplete torrents are never auto-deleted.** qbitmanage's `share_limits_filter_completed:
  true` means share limits only ever apply to completed torrents, so incomplete ones are never
  cleaned by it either. They get tagged for review instead (see §5). There are 180 incomplete
  torrents today; 72 TB free on `/volume1` means hoarding them is affordable.
- **`downloaded == 0` is NOT a safe proxy for "tracker saw no download."** 153 incomplete
  torrents report `downloaded == 0` while sitting at 99–100% progress (cross-seed hardlink
  injections, post-recheck counter resets). Do not build a deletion rule on that field.
- The 32 `missingFiles` torrents (data already gone, entry orphaned) are the one genuinely
  disposable population: 26 of them already pass the invariant.

---

## 4. Failure taxonomy

### 4.1 What we can act on today

Confirmed present in live queues and *arr history:

| Class | Signal | Action |
|---|---|---|
| Stale "already imported" | `trackedDownloadState=importBlocked` + `statusMessages` contains `already imported` | ignore, no blocklist, no re-search |
| Failed import | `importBlocked` / `importFailed` + message matches a pattern | ignore + blocklist + allow re-search |
| Stalled with no connections | `errorMessage` contains `stalled` | blocklist + allow re-search; **keep torrent seeding** |
| Data vanished underneath | qBittorrent `state=missingFiles` | tag; purge only if invariant passes |

### 4.2 Patterns inherited from decluttarr

The genuinely valuable artifact from decluttarr was our own **curated** `remove_failed_imports`
message list — it was tuned against real observed failures over months. Preserved verbatim
(retired config also at `configs/_archived/decluttarr-config.yaml.retired`):

```
Not a Custom Format upgrade for existing*
Not an upgrade for existing*
*Found potentially dangerous file with extension*
Invalid video file*
No files found are eligible for import*          # the qbitmanage orphan-race
One or more episodes expected in this release were not imported or missing from the release
Episode file on disk contains more episodes than this file contains
Invalid season or episode
Found matching series via grab history, but release was matched to series by ID*
```

### 4.3 Why the taxonomy must be observed, not assumed

Import rejection reasons are **not in the *arr logs at Info level**. 25 days of Loki logs for
`radarr-hd`/`sonarr-hd` filtered on import/reject/invalid/failed yielded 35 and 50 distinct
lines respectively, essentially all `ExistingExtraFileService` noise — zero rejection reasons.

The reasons live only in the queue record's `statusMessages[].messages[]`, which is transient.
This is the single strongest argument for the phased rollout in §6: we cannot enumerate our real
failure taxonomy from history, only by watching the queue over time.

### 4.4 Re-grab loops are real and must be capped

Blocklisting makes the *arr grab a different release, which can fail the same way. From the
`Blocklist` tables:

```
sonarr-hd: 6 targets blocklisted >=3 times, 22 entries (6% of 317)
  5x  Animaniacs 1993 S02 …D00oo00M
  5x  Naked and Afraid Shipwrecked S01E05 …
  3x  Naked And Afraid Shipwrecked S01E01/E02/E03/E04 …
radarr-hd: none
```

Each loop iteration is a fresh download and therefore fresh HnR exposure. **Hard cap attempts
per (instance, media_id, episode set); on cap, stop, tag `janitor-stuck`, alert once, and never
retry automatically.** This mirrors the existing `upgraderr-skip` tag convention.

---

## 5. Design

### Why it lives in Upgraderr

Not a new service. Upgraderr already owns every primitive needed, and queue hygiene is the same
decision as search-triggering — blocklist-and-re-search *is* what Upgraderr does:

| Need | Already in `services/upgraderr/app.py` |
|---|---|
| All 4 *arr clients | `get_instances_from_db()`, `arr_get/post/put/delete` (`arr_delete`, L562) |
| Reads the *arr queue | `get_queue_ids()` (L594), incl. `_DEAD_QUEUE_PATTERNS = ('stalled',)` |
| qBittorrent tagging | `_qb_tag_torrent()` (L488), with a login circuit breaker |
| Scheduler | `BackgroundScheduler` (L2335), 6 jobs registered |
| SQLite + backup + health check | `init_database()` (L229), daily backup, `_db_health_check` |
| Telegram with per-category opt-in | `send_telegram()` (L469), `NOTIFY_CATEGORIES` (L457) |
| Skip/stuck tagging convention | `upgraderr-skip`, `upgraderr-no-source` |

A standalone service would duplicate all of it. It also keeps one place that decides whether a
title gets searched, which avoids Upgraderr and a janitor fighting over the same item.

### Flow

```
every 30 min (piggyback the sweep, run BEFORE it):

  for each of the 4 instances:
    GET /queue?includeUnknown{Movie,Series}Items=true       # one fetch, no diffing
    group records by downloadId                             # §2.2
    for each download:
      classify -> (class, action) from §4.1
      if class == none: skip

      look up torrent in qBittorrent by downloadId (infohash)
      seeding_ok = seeding_time >= 144h or ratio >= 1.0      # §3

      REPORT-ONLY: log + record intent, do nothing
      LIVE:
        DELETE /queue/{first_id}?removeFromClient=false
                                &blocklist=<class wants it>
                                &skipRedownload=<class wants it>
        tag torrent in qBit: janitor-<class>
        if attempts(target) >= cap: tag janitor-stuck, alert once, stop
```

Deliberately **no orphan detection**, no second queue fetch, no dict diffing (§1.3).

### Schema

```sql
CREATE TABLE IF NOT EXISTS janitor_actions (
    id            INTEGER PRIMARY KEY,
    instance      TEXT NOT NULL,
    download_id   TEXT NOT NULL,        -- infohash; the real identity (§2.2)
    media_id      INTEGER,              -- movieId / seriesId
    episode_ids   TEXT,                 -- JSON list, sonarr only
    title         TEXT,
    class         TEXT NOT NULL,        -- already_imported | failed_import | stalled | missing_files
    status_msg    TEXT,                 -- raw statusMessages, feeds §4.3
    action        TEXT NOT NULL,        -- reported | ignored | ignored_blocklisted | capped
    blocklisted   INTEGER DEFAULT 0,
    seeding_time  INTEGER,              -- seconds, at decision time
    ratio         REAL,
    hnr_safe      INTEGER,              -- did it pass the §3 invariant
    created_at    TEXT NOT NULL         -- Python isoformat, T-separated
);
CREATE INDEX IF NOT EXISTS idx_janitor_target ON janitor_actions(instance, media_id, episode_ids);
CREATE INDEX IF NOT EXISTS idx_janitor_dl     ON janitor_actions(download_id);
```

> **Timestamps:** write `datetime.utcnow().isoformat()` (T-separated) and compare with
> `strftime('%Y-%m-%dT%H:%M:%S','now',…)`, never bare `datetime('now',…)`. See the
> `datetime('now')` section in CLAUDE.md — that exact mismatch has already caused two incidents.

### Config keys (`config` table, editable in the Settings UI)

| Key | Default | Purpose |
|---|---|---|
| `janitor_enabled` | `false` | Master switch |
| `janitor_report_only` | `true` | Phase 1. Same pattern as `tier9_report_only` |
| `janitor_hnr_min_seed_hours` | `144` | The §3 invariant |
| `janitor_hnr_min_ratio` | `1.0` | The §3 invariant |
| `janitor_max_attempts` | `3` | Re-grab loop cap (§4.4) |
| `janitor_allow_client_removal` | `false` | Gate on removal-with-data, even when the invariant passes |
| `notify_janitor` | `true` | Telegram category |

---

## 6. Rollout

**Phase 1 — report-only (2 weeks minimum).** `janitor_enabled=true`,
`janitor_report_only=true`. Writes `janitor_actions` rows and changes nothing. Purpose is §4.3:
build the real failure taxonomy from our own `statusMessages`, which cannot be reconstructed
from history. Weekly Telegram digest of what it *would* have done.

**Phase 2 — safe classes live.** Enable only `already_imported` (ignore, no blocklist, no
re-search). Lowest risk: the file is already imported, so nothing is lost, and the torrent is
untouched. The Breaking Amish case in §2.1 is exactly this class.

**Phase 3 — failed_import + stalled.** Adds `blocklist=true` and re-search. Verify §2.4's open
question first. Watch the loop cap.

**Phase 4 — optional client removal.** Only `missing_files`, only when the §3 invariant passes,
only with `janitor_allow_client_removal=true`. 26 torrents qualify today.

At every phase, `qbittorrent`'s log in Loki is the independent check — a
`Torrent removed` **without** a following `Torrent content removed` means files were kept:

```logql
{service="qbittorrent"} |= "Torrent content removed"
```

An alert on that query firing for anything the janitor touched is the tripwire that would have
caught decluttarr on day one.

---

## 7. Traps

1. **Never set `removeFromClient=true` by default.** This is the whole incident.
2. **Never port `remove_orphans`** (§1.3).
3. **Never change a torrent's category** (§2.5) — auto-TMM will relocate the data.
4. **Group by `downloadId`, not queue id** (§2.2).
5. **Don't trust `downloaded == 0`** as "tracker saw nothing" (§3).
6. **Cap re-grab attempts** (§4.4) — each retry is fresh HnR exposure.
7. **Don't rely on *arr logs for rejection reasons** (§4.3) — they aren't there at Info level.
8. **Ignoring a still-progressing download orphans it forever.** If the janitor ignores a
   download that later completes, the *arr will never import it (`DownloadHistory` EventType 4
   is persistent, §2.3). Only ignore genuinely terminal states; for `stalled`, blocklist so a
   replacement is grabbed, and leave the original seeding.

## 8. Related cleanup found during research

Not part of the janitor, tracked here so it isn't lost:

- **qBittorrent rotated logs:** 12,787 `qbittorrent.log.bakN` files / 850 MB in
  `/volume1/docker/qbittorrent/qBittorrent/logs/`, caused by `file_log_max_size` = 65 KiB.
  Raised to 10 MiB on 2026-09-01; the existing backlog was left in place for Ali's call.
- **`/volume1/Downloads/orphaned_data` is 659 GB** — qbitmanage's quarantine, auto-emptied at
  120 days. Worth a look for anything still wanted.
- **`Blocklist` tables carry decluttarr's legacy entries** (radarr-hd 90, sonarr-hd 317, almost
  all "Manually marked as failed"). Some are releases that were fine and got blocklisted by the
  `remove_orphans` bug. Worth reviewing before Phase 3 so the janitor isn't working around a
  poisoned blocklist.
