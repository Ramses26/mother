# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Environment

You are running **locally on Mother** (10.0.0.162, Ubuntu 24.04 LTS) at Chris's network. The working directory is `/opt/mother` — this is both the repo and the production environment. No SSH needed; all commands run directly.

## Network Topology

```
Ali's Location (192.168.1.0/24)         Chris's Location (10.0.0.0/23)
├── Unraid: 192.168.1.10                ├── Mother: 10.0.0.162  <-- YOU ARE HERE
├── Terminus: 192.168.1.14              ├── RS-4KMedia: 10.0.1.203
                                        ├── RS-TV: 10.0.0.88
                                        └── RS-Movies: 10.0.0.160
        <------- IPsec VPN Tunnel ------->
```

**Data flow**: Chris's Synology NAS devices → (rsync over NFS) → Ali's Unraid. One-way sync.

## Sync Strategy (READ THIS BEFORE TOUCHING SYNC CODE)

These rules define what gets synced and why. They are intentional design decisions — do not change them without explicit confirmation.

### What Is and Is NOT synced

**Policy changed 2026-07-25 — Ali's explicit instruction: "I no longer care if there are
lower quality on Unraid etc. I want absolute parity between synology and unraid for movies
and tv shows."** The quality-tier exclusion below (720p/SD, x265-without-HDR) that used to
block sync entirely for those files is **removed** for the Synology→Unraid direction. Every
Synology file now syncs to Unraid regardless of resolution/codec — a 720p or x265-no-HDR file
on Synology gets mirrored as-is rather than waiting indefinitely for Upgraderr to fix it
first. Synology remains authoritative and protected: the reverse direction (Unraid→Syn, TV
reconcile only) still refuses to push a quality-excluded Unraid file up to Synology.

| Content type | Synced? | Reason |
|---|---|---|
| 1080p movies/TV (non-x265 or x265+HDR) | ✅ Yes | Primary sync target |
| 4K movies/TV | ✅ Yes | Separate sync pass |
| 720p / SD movies or TV | ✅ Yes (since 2026-07-25) | Previously excluded — see policy change above. Upgraderr still independently searches for a better source; this only affects whether Unraid gets a copy of whatever Synology currently has. |
| x265 without HDR/DV at 1080p | ✅ Yes (since 2026-07-25) | Same as above. Recyclarr still blocks these at grab-time on Synology's side; this table entry is only about whether the file syncs to Unraid once it exists on Synology. |
| 1080p x265 WITH DV or HDR | ✅ Yes | Recyclarr allows these; DV/HDR is the reason to keep x265 |

**What did NOT change**: Recyclarr's quality profiles (still block 720p/x265-no-HDR at
grab-time), Upgraderr's tiers (still search for better sources — this is *more* urgent now
that Unraid mirrors Synology's current quality immediately), and dedup (still governed by
Profile Authority below, unrelated concern). This change is purely about the sync/reconcile
layer's willingness to copy a file, not about what Radarr/Sonarr are allowed to grab or what
Upgraderr searches for.

**Implementation**: `_should_sync_tv_episode()` (sync-webhook) and `_should_sync_tv()`
(curatorr/sync_status.py) both now always return "syncable" — kept as functions rather than
deleted so call sites don't need restructuring. See
`services/sync-webhook/app.py`'s `reconcile_tv_versions()`/`reconcile_movie_versions()`/
`scan_tv_gaps()` for the removed gates.

### Upgraderr → Sync Pipeline

```
Upgraderr detects 720p/bad codec on Chris's side
  → searches indexers → Radarr downloads 1080p
  → webhook sync fires immediately
  → OR: batch sync loop picks it up in next comparison
```

**Key invariant**: Upgraderr runs on Chris's side first. Sync propagates the result to Ali. Never sync the pre-upgrade version.

### Inventory Scanning

Ali's Unraid inventory is ALWAYS fetched via the Unraid Agent (192.168.1.10:8100) — **never via CIFS mount** (`/mnt/unraid/media/`), which is too slow and unreliable over VPN.

This applies to **all code that needs a folder/file list from Unraid**: gap scanners, duplicate scanners, reconciliation checks. Do not call `os.listdir('/mnt/unraid/...')` for bulk enumeration.

| Library | Endpoint |
|---|---|
| HD Movies | `GET /inventory?path=/mnt/user/Media/Movies` |
| 4K Movies | `GET /inventory?path=/mnt/user/Media/4K%20Movies` |
| HD TV | `GET /inventory?path=/mnt/user/Media/TV%20Shows` (~52s fresh, 30min cache) |
| 4K TV | `GET /inventory?path=/mnt/user/Media/4K%20TV%20Shows` |

**Auth**: `X-Api-Key: <UNRAID_AGENT_API_KEY>` header. Add `?refresh=true` to bypass cache.

**Response shape**: `{ "items": [{ "path": "/mnt/user/Media/Movies/<folder>/<file>", ... }] }`
Extract folder name: `path.split('/')[5]` (index 5 = folder under the library root).

Chris's Synology is scanned locally via NFS (`os.listdir('/mnt/synology/...')` — fast, no auth needed).

---

## Profile Authority (READ THIS BEFORE TOUCHING ANY QUALITY/SCORING LOGIC)

**The single most important cross-cutting rule in this codebase.** Radarr/Sonarr's
*assigned quality profile* — not a raw TRaSH/quality score comparison — is the
authority for what quality a movie or episode should be. This applies everywhere a
service compares "what quality is this file" against "what quality should it be":

- **sync-webhook reconcile**: Radarr's tracked file always wins over Unraid's file,
  even when Unraid's file scores higher (e.g. Unraid holds a Remux while Radarr tracks
  a Bluray-1080p because that's the assigned profile). No score gate on movies —
  `reconcile_movie_versions()` syncs Radarr's file regardless of raw TRaSH delta. TV
  reconcile uses score only to pick a *direction* when both sides are genuinely
  cross-tier-ambiguous; the 720p exclusion still applies both ways regardless.
- **Upgraderr Tier 7 (profile mismatch)**: fires whenever a file's quality ID isn't in
  its assigned profile's `allowed` list — **regardless of whether the current file is
  objectively "better."** A Remux sitting in a profile that doesn't allow Remux is
  wrong and gets replaced, even though a Remux is objectively higher fidelity. Do NOT
  add a "skip if the current file already scores higher than the profile's cutoff"
  comparison here — that inverts this exact rule and was tried and reverted on
  2026-07-02 (see incident below). Implemented for **both Radarr and Sonarr** as of
  2026-07-02 — Sonarr had no equivalent at all before that (a real, live gap: 48
  episodes across 5 shows had a Remux sitting in a non-Remux-allowed profile with
  nothing to ever correct it).
- **sync-webhook's reconcile — reverted a regression, not just documented a rule**:
  commit `ae46ea1` (2026-06-27, a *different* prior Claude session) reversed this
  exact Profile Authority rule in `reconcile_movie_versions()`, replacing it with pure
  score-based direction ("highest TRaSH score wins, regardless of tier"), reasoning it
  was protecting Unraid's "better" Remux from being overwritten. That's backwards, and
  it directly contradicted this rule which was already 11+ days old at the time, and
  the function's own docstring. It queued 391 successful `MovieReverseSync` jobs that
  restored old Remuxes from Unraid over Upgraderr's legitimate profile-compliant
  upgrades — including deleting the exact files Upgraderr had just correctly grabbed
  for Varsity Blues and Mazinger Z, which is what re-triggered Tier 7 and made the
  2026-07 incident (below) repeat on the same movies multiple times. Reverted
  2026-07-02: the only legitimate `MovieReverseSync` trigger now is Radarr's tracked
  file being genuinely missing from Synology's filesystem (real drift), never a score
  comparison. **If you ever find yourself reasoning "but Unraid's file scores
  higher, so keeping it there is safer" — stop. That reasoning has caused two separate
  incidents. Check CLAUDE.md and the relevant memory before writing that logic.**
- **Curatorr's Sync Status page** (`sync_status.py`) had the identical "Synology score
  > Unraid score" framing in a code comment for its "Unraid Has Better" tab — a third
  occurrence of the same wrong mental model, this time in read-only display logic (it
  doesn't execute syncs itself, sync-webhook does). Comment corrected 2026-07-02; the
  `syn_better`/`unraid_better` split in the UI is now informational only (which side
  scores higher) — both categories resolve identically via forward Syn→Unraid sync.
- **Curatorr scoring/dedup**: same principle — Radarr/Sonarr's tracked file is correct
  by definition; a higher-scored file elsewhere is the anomaly to fix, not a reason to
  keep divergence.

**Why:** the profile assignment reflects a deliberate curation decision (does this
title warrant Remux-level fidelity, or is a well-encoded Bluray-1080p enough to save
disk space). A higher raw score never overrides that decision. A Remux unexpectedly
sitting on a Bluray-only profile is almost always a legacy leftover from before
profiles were rigorously assigned — the profile is what's correct, not the file.

**This is orthogonal to release quality control.** Profile authority governs
*resolution/source tier* (Remux vs Bluray vs WEB-DL) — it does NOT mean "accept
whatever release gets grabbed to satisfy the profile." A release can still be
objectively unacceptable regardless of which profile tier it technically satisfies.
See Known-Bad Releases below — that list is enforced independently of, and in
addition to, profile authority.

### Known-Bad Releases (never acceptable, regardless of profile)

| Pattern | Why | Enforced by |
|---|---|---|
| Release group `BHDStudio` | Low-quality encode group | `configs/recyclarr/custom-formats/{radarr,sonarr}/bhdstudio.json` (CF score -50, **both services** as of 2026-07-02 — Sonarr had none before) **and** Upgraderr's `BAD_RELEASE_GROUPS` set + `_flag_if_bad_import()` in `services/upgraderr/app.py` (independent check — doesn't rely on recyclarr) **and** the dedup known-bad guard (see below) |
| MP4 container | Can't hold lossless audio (TrueHD/DTS-HD MA) | `configs/recyclarr/custom-formats/{radarr,sonarr}/bad-container-mp4.json` (CF score -1000, both services) **and** Upgraderr Tier 2 (file-extension check in `classify_tiers()`) **and** the dedup known-bad guard (see below) |

**Dedup known-bad guard — added 2026-07-19 (a fourth enforcement point, found live).**
Both dedup engines (`_dedup_enforce_profile_authority()` in `services/sync-webhook/app.py`
and `_enforce_profile_authority()` in `services/curatorr/app/routes/duplicates.py`) apply
Profile Authority — always keep whatever Radarr/Sonarr currently tracks — but neither used
to cross-check that tracked file against this Known-Bad-Releases list before deciding what
to delete. A live dry-run caught the gap: Mortal Kombat II (2026), The Devil Wears Prada 2
(2026), and 11 other movies + 6 old Looney Tunes episodes all had a known-bad file
(BHDStudio `.mp4`, or `.avi`) as the *tracked* file, with a clean alternative sitting right
next to it that dedup was about to delete to preserve the bad one. Fixed in both services:
if the kept/tracked file matches the known-bad check, every other version in that group is
marked un-deletable instead of ranked below it (`known_bad_tracked_file` flag) — the fix for
the *tracked* file being bad is Recyclarr's CFs / Upgraderr's Tier 2+BAD_RELEASE_GROUPS
above, not dedup destroying the fallback copy. Verified live: a real 50-item Unraid dedup
run after this fix correctly protected all 19 known-bad groups found and deleted 50
genuine duplicates (484.7GB) with zero mistakes.

Local custom format JSON files require a matching `resource_providers` entry in
`configs/recyclarr/settings.yml` per service (`radarr` and `sonarr` are registered
separately) — a file sitting in `custom-formats/sonarr/` with no `local-cfs-sonarr`
provider registered silently fails to load (`recyclarr sync ... --preview` reports
`Invalid trash_id` rather than erroring loudly). Check both exist before assuming a
local CF is live.

**2026-07-02 incident (read before changing Tier 7 or these custom formats again):**
the two custom formats above existed but used `ReleaseTitleSpecification` regexes
requiring a trailing file extension (`\.mp4$`, `-BHDStudio\.`) — Radarr matches
custom formats against the release *title* (no extension) at grab time, so neither
regex ever actually fired; confirmed via `customFormats: None` on an affected import.
Tier 7 was (correctly, per Profile Authority above) forcing searches for Remux-in-
Bluray-profile movies, and with the safety net silently broken, Radarr grabbed
whatever "allowed" release it found — including BHDStudio MP4s and 720p releases —
instead of a proper Bluray-1080p. 314 movies were downgraded over two weeks before it
was caught. Fixed via corrected regexes (`-BHDStudio\b`, `\bMP4\b|\.mp4$`) plus a
post-import safety net (`_flag_if_bad_import()`) that alerts and tags
`upgraderr-skip` when an imported file is *itself* objectively bad — independent of
whether it scored lower than what it replaced, since a profile-enforced score drop is
expected and correct.

### Radarr Quality Profile Configuration (READ BEFORE ADDING QUALITIES TO A PROFILE)

The "HD Bluray + WEB" Radarr-HD profile (id 7) had `Bluray-720p` in its **allowed**
qualities list — a stock TRaSH Guides template default. Since it was "allowed," Radarr
could legitimately grab and keep a 720p release any time a search (Tier 3, Tier 7, or
a plain search) turned one up, directly contradicting this project's Sync Strategy
rule that 720p is never an acceptable end state. This is what happened to Mazinger Z.
Fixed 2026-07-02 via a `qualities:` override in `configs/recyclarr/recyclarr.yml` for
that profile entry (keeps `trash_id:` for custom-format sync, overrides only the
allowed-quality list). Radarr-4K and both Sonarr instances were checked and don't have
this gap (no 720p/480p in any of their allowed lists). **Before enabling upgradeAllowed
on a profile or accepting a stock TRaSH template as-is, check its `allowed` items
list for any quality this project's Sync Strategy says should never be kept.**

### 2026-07-02 Full System Assessment (what was checked, what's confirmed)

A comprehensive pass across every service, triggered by the incidents documented
above. Recorded here so the state doesn't need to be re-derived:

- **Synology/Unraid parity**: live gap scans run for both movies and TV. Movies: 1
  new folder found missing, queued. TV: 25 episodes found missing, queued. Both are
  small, expected steady-state gaps (new downloads since the last nightly run), not
  evidence of a systemic sync failure.
- **TV/Sonarr audit**: found and fixed the Tier 7 gap (above) and the missing local
  custom formats (above). `reconcile_tv_versions()`'s score-based direction is
  confirmed *intentional* (not a bug) — TV genuinely uses score to pick direction
  because per-episode profile checks via Sonarr's API would be too slow; the 720p
  exclusion still applies both ways regardless of score.
- **Scoring audit**: full comparison table above updated; TV WEB-DL/Bluray fix
  verified applied in all three places that needed it (`sync-webhook`,
  `curatorr/sync_status.py`; the Python module already had it correct).
- **Duplicate scanner Profile Authority bug — the same regression, a fourth time,
  found and fixed**: neither Curatorr's filesystem duplicate scanner
  (`duplicates.py`) nor sync-webhook's automatic nightly dedup
  (`nightly_unraid_dedup()`) cross-checked Radarr/Sonarr's currently-tracked file
  against duplicate groups — both simply kept whichever version scored highest by
  raw TRaSH score, same mistake as the reconcile regression above. Verified live:
  **32 of 305 Unraid HD movie duplicate groups** had the scanner recommending
  deletion of the actively-tracked, profile-compliant file while keeping an orphaned
  Remux. The automatic nightly dedup is the more dangerous of the two (no human
  review) — it's currently blocked by `PAUSE_DEDUP` (see below), so hadn't caused
  live damage yet, but would have the moment that sentinel was lifted. Fixed in both:
  `_enforce_profile_authority()` (Curatorr) and `_dedup_enforce_profile_authority()`
  (sync-webhook) fetch Radarr's tracked filename per movie and Sonarr's per
  `(tvdbId, S##E##)`, then re-rank each duplicate group so the tracked file is always
  kept regardless of score. Verified 32→0 mismatches in both independently.
  sync-webhook's version fails closed (aborts the dedup run) if the Radarr/Sonarr
  fetch errors, since there's no human safety net there. **The Unraid Agent's own
  `/scan` endpoint is deliberately left unfixed** — it's a dumb filesystem+score
  scanner by design with no Radarr/Sonarr access; the correction belongs in the layer
  that has that access and runs right before any delete decision, which is now both
  Curatorr and sync-webhook.
- **Loop-safety audit** (explicit ask: verify no mechanism can recreate a duplicate
  after dedup removes one, the way the `ae46ea1` regression did): traced the full
  cycle — Upgraderr upgrades Synology → forward sync deletes Unraid's old file only
  after confirming the new one landed (`background_sync()`, already solid, sends a
  Telegram warning rather than failing silently if the delete fails) → dedup (now
  fixed above) only ever removes genuine orphans, never the tracked file → reconcile
  sees Radarr's file already matches Unraid's remaining file and takes no action. No
  gap found after the reconcile-direction fix and the dedup keep-selection fix; both
  were necessary and are now both closed.
- **Security review**: SQL injection check across all four services' f-string-built
  queries — clean everywhere (either whitelisted column/sort identifiers or values
  passed via proper parameterized placeholders, never raw string interpolation of
  user input). Auth decorators (`@require_auth` / `Depends(require_auth)`) present on
  all write endpoints checked in `upgraderr` and `curatorr`. No hardcoded secrets
  found. **One real fix**: `services/unraid-agent/app.py`'s `/delete` endpoint checked
  the raw input path string against allowed prefixes and only checked whether the
  *leaf* was a symlink — a symlinked *intermediate* directory could escape the
  allowed roots without tripping either check. Fixed to resolve the full realpath
  first (matching the `/inventory` endpoint's already-correct pattern) before the
  prefix check. This service runs on Unraid, not Mother, but SSH access from Mother to
  Unraid is available (`ssh -i ~/.ssh/unraid_key root@192.168.1.10`) — deployed
  directly the same session via `scp` + remote `docker compose build/up`, see its
  section below for the exact steps. Don't ask the user to deploy this kind of fix
  manually; do it.
- **Cross-app webhook wiring**: confirmed all 4 *arr instances (radarr-hd, radarr-4k,
  sonarr-hd, sonarr-4k) have both webhooks configured correctly — `Sync to Unraid` →
  `http://sync-webhook:5000/sync/{radarr,sonarr}` and `Upgraderr` →
  `http://upgraderr:5000/webhook/{radarr,sonarr}?source=<instance-name>` — with
  correct per-instance `source` params so Upgraderr's queue tracking doesn't
  cross-contaminate between HD/4K. No gaps found.

---

## Architecture Overview

Project Mother is a media management and synchronization system consolidating two users' (~160TB each) media libraries. Mother runs on an Ubuntu VM at Chris's location, managing Docker services for media acquisition (Radarr/Sonarr), quality automation (Recyclarr/Upgraderr), and real-time sync to Ali's Unraid via VPN.

### Three Sync Systems

1. **Batch Sync** — Initial 160TB bulk transfer via `screen` sessions running rsync with `PARALLEL=8`. Scripts generated by `compare_libraries.py`/`compare_tv_libraries.py`, stored in `reports/`. **Movie sync complete and disabled** (`/opt/mother/DISABLE_MOVIE_SYNC` sentinel). **TV batch sync (screen `tvsync`) ran Apr 26 – Jun 17 2026 and is now complete.** It completed all 64,818 rsync operations (Synology→Unraid) plus 44,854 `[MOVE TO DELETED]` operations (moved Ali's lower-quality episodes to `/mnt/unraid/media/Deleted TV Shows/` via CIFS). **The batch sync screen is no longer needed** — nightly gap scanner handles ongoing sync.

2. **Webhook Sync** (append-only) — Real-time sync of new downloads. Flask app (`services/sync-webhook/app.py`) receives Radarr/Sonarr webhooks, **copies new files to Unraid only — never deletes**. Auto-retry, history scanning failsafe, Telegram notifications. `MovieFileDelete`/`EpisodeFileDelete` events are intentionally ignored.

3. **Nightly Reconciliation** — Jobs run nightly to keep libraries in sync (all times Eastern / America/New_York, DST-aware):
   - **TV gap scan (11:00 PM ET)**: finds episodes on Synology missing from Unraid, queues them. Capped at `GAP_SCAN_MAX_QUEUE=500` per run.
   - **TV version reconcile (11:15 PM ET)**: for episodes present on BOTH sides, compares filenames. If Synology has a newer version (e.g. WEB-DL vs old Remux), queues `TVVersionSync` — rsyncs new file then deletes old Unraid file via Agent. Cap: `VERSION_SYNC_MAX_PER_RUN=20`.
   - **Movie gap scan (11:30 PM ET)**: finds movie folders on Synology missing from Unraid, queues them. Same cap.
   - **Movie version reconcile (11:45 PM ET)**: Uses Radarr's tracked file as the canonical answer (Profile Authority — see section above), not a raw score comparison. Also scans the ACTUAL Synology folder (`os.scandir`) for all video files to catch cases where Unraid already has Synology's best file under a name Radarr hasn't rescanned yet. Queues `MovieVersionSync` (Synology→Unraid) whenever Radarr's tracked file differs from Unraid's — even if Unraid's current file scores higher (e.g. Unraid holds a Remux, Radarr tracks Bluray-1080p). No score gate on the sync decision itself.
   - **Library health report (12:15 AM ET)**: Telegram summary of missing movies/episodes.
   - **Unraid dedup (8:00 AM ET)**: calls Unraid Agent to find and delete lower-quality duplicates. Runs in the morning to give the overnight rsync queue ~8 hours to drain before dedup evaluates what remains.

4. **Upgraderr** — Custom quality upgrade automation service (replaces Huntarr). Active once initial sync reaches ~99%+. See `services/upgraderr/`. UI at port 9706.

### Dedup ↔ Upgraderr Loop Safety (why this can't turn into an upgrade loop)

Asked explicitly 2026-07-19: could dedup deleting a file cause Upgraderr to think content
is missing and re-trigger a search, which re-downloads and re-triggers dedup, forever?
**Unraid-side dedup (`nightly_unraid_dedup`) cannot cause this by architecture** — Unraid
is a one-way sync *destination* (Synology → Unraid only, see Webhook Sync above); nothing
on Mother ever reads Unraid's state back into a decision. Upgraderr, Radarr, and Sonarr
only ever look at Synology. **Synology-side dedup (Curatorr's `_do_synology_dedup`) is the
one that could, in principle** — it deletes from the library Radarr/Sonarr actually track.
This is exactly what Profile Authority (never delete the tracked file) exists to prevent,
and it's now backed by an independent verification in both dedup engines (added
2026-07-19): every deletion candidate is checked against the group's own keeper path right
before deletion, refusing and logging an error if they ever match — not just trusting the
ranking logic upstream. If you ever see `"REFUSING to delete ... matches the group's own
kept/tracked file"` in the logs, that's this safety net catching a real bug — stop and
investigate immediately, don't just note it and move on.

### Dedup Safety Controls (CRITICAL — READ BEFORE MODIFYING)

The nightly dedup (`nightly_unraid_dedup` in `app.py`) caused a mass-deletion incident in June 2026 (6,038 files / 11 TB deleted). Multiple safety layers are now in place — **do not remove them**:

| Safety | Env var / file | Default | Purpose |
|---|---|---|---|
| Pause sentinel | `/opt/mother/PAUSE_DEDUP` | (create file) | Blocks dedup entirely when file exists. Create during active batch sync. |
| Pre-run warning | `DEDUP_WARN_MINUTES` | 10 | Sends Telegram N min before deletions; re-checks sentinel after wait so you can abort. |
| Safety limit | `DEDUP_SAFETY_LIMIT` | 200 | Aborts + alerts if more than N deletable files found. Prevents runaway. |
| Per-run cap | `DEDUP_MAX_PER_RUN` | 50 | Max deletions per run (enforced across all library types via flat loop). Remaining deferred. |
| Dry-run mode | `DEDUP_DRY_RUN` | false | Set `true` to preview deletions without executing. |
| Min age | `DEDUP_MIN_AGE_HOURS` | 6 (was 24 until 2026-07-19) | Skips dedup if any gap-sync job completed in last N hours OR is still in_progress/pending. |
| Active job check | (code) | always | Skips dedup if any TVGapSync/GapSync/TVVersionSync/MovieVersionSync jobs are `in_progress` OR `pending`. |
| Agent confirm | (code) | always | Counts deletion as success only if path appears in Agent `deleted[]` — not just HTTP 200. |
| Weekly forced run | APScheduler job `unraid_dedup_weekly_forced` | Sunday 9:00 AM ET | Calls `nightly_unraid_dedup(force=True)` — bypasses only the min-age defer (2b), still honors PAUSE_DEDUP and the active-job check. Added 2026-07-19 after dedup silently deferred every single day for 11+ days straight (2026-07-09 to 07-19) because the TV restore project completes a gap-sync job almost daily, so the 24h quiet window never happened. |

**PAUSE_DEDUP should exist while the batch sync screen is running.** Remove it only once the batch sync is complete and verified. **Status: `PAUSE_DEDUP` was removed 2026-07-02** — it had been continuously active since 2026-06-17 (2+ weeks), meaning dedup had not run at all in that window regardless of any `DEDUP_*` env var tuning.

**IMPORTANT — the `DEDUP_*` env vars in this table were documented and set in `.env` but never actually wired into `docker-compose.yml`'s `sync-webhook` service** until 2026-07-02 — the container always ran on the Python code's hardcoded defaults (200/50/false/10/24) no matter what `.env` said. Fixed by adding explicit `environment:` entries for all five in `docker-compose.yml`. **If you change any `DEDUP_*` value in `.env`, you must `docker compose up -d sync-webhook` to recreate the container — editing `.env` alone does nothing.** `DEDUP_SAFETY_LIMIT` raised to **700** on 2026-07-02 specifically to drain a 669-file backlog that accumulated during the `PAUSE_DEDUP` window. That backlog was **not** drained before this doc was last touched — dedup then went silent for 11 more days (see Min age row above), and a 2026-07-19 dry-run found the backlog had grown to **3,134** deletable duplicates, tripping the 700 limit outright. Raised to **3500** on 2026-07-19 as a one-time drain (same pattern as before) — **revert to 200 once confirmed drained, check this before assuming 3500 is still needed.**

**Dedup status reporting**: `reports/daily_report.py`'s Dedup section used to only check the `PAUSE_DEDUP` sentinel and always said "✅ Enabled" — this is why the 11-day silent defer above went unnoticed. Fixed 2026-07-19: `nightly_unraid_dedup()` now writes its actual outcome (ran/deferred/paused/blocked/error + reason) to `configs/sync-webhook/data/dedup_status.json` on every attempt, and the report reads it. If you ever see "no run recorded yet" in the report, the status file is missing or stale — check `sync-webhook` logs directly.

**PAUSE_VERSION_SYNC** (`/opt/mother/PAUSE_VERSION_SYNC`) — blocks both TV and movie version reconcile. Use during major library reorganization to prevent version sync from interfering.

### Upgraderr Tier Priority Note
The sweep randomizes movie order within each instance (`random.shuffle`), so there is no natural tier ordering. To prioritize 720p upgrades (Tier 3), disable Tiers 4–6 in the Settings UI (`http://mother:9706/settings`). This concentrates search budget on Tiers 1–3 only. Re-enable 4–6 once Tier 3 queue is empty.

### Upgraderr Queue-Starvation Bug — Fixed 2026-07-19 (READ BEFORE TOUCHING `get_queue_ids()`)

`get_queue_ids()` in `services/upgraderr/app.py` used to include **every** ID present anywhere in
Sonarr/Radarr's own download queue — including permanently dead entries ("stalled with no
connections"). `_sweep_sonarr`/`_sweep_radarr` skip a series/movie entirely if its ID is in that set,
regardless of which season/item is stalled. **Found live 2026-07-19**: Grey's Anatomy had 4 dead
season-11 downloads sitting in Sonarr's queue since 2026-07-09, which blocked *every* season —
including a Tier-3 (720p) job for season 15 that had been queued since **March 19** and never once
searched (`search_count=0`). Confirmed **14 Sonarr-HD series and 14 Radarr-HD movies** were stuck this
way, some since April. Fixed by filtering `errorMessage` for `'stalled'` before adding an ID to the
blocking set (`_DEAD_QUEUE_PATTERNS`) — a stalled download no longer blocks re-searching its title.
Deliberately does **not** filter `importPending`/`importBlocked`/parse-failure states — those mean a
release already landed and needs to actually finish importing, so re-triggering a search would just
grab a redundant duplicate on top of the stuck one; that class of problem is handled by Decluttarr's
`remove_failed_imports` job instead (see below) and the orphaned_data fix. One-time cleanup removed 54
dead queue entries from Sonarr-HD/Radarr-HD via `DELETE /api/v3/queue/{id}` the same session.

### Upgraderr Stuck 'found' Status Bug — Fixed 2026-07-25 (READ BEFORE TOUCHING `_validate_stale_queue()`)

The webhook handler (`/webhook/radarr`, `/webhook/sonarr`) marks an `upgrade_queue` row
`status='found'` on *any* tracked import event — a `Download` with `isUpgrade=True`, or **any**
`MovieFileRenamed`/episode-file-renamed event regardless of `isUpgrade` — without checking
whether the new file actually resolves the original problem. Once `status='found'`, every sweep
function skips the row entirely (`if row and row['status'] == 'found': continue`), and the old
nightly `_validate_stale_queue()` (05:00 UTC) only ever looked at `pending`/`searching` rows —
so a bad result just froze forever with zero path back into the queue, unless
`_flag_if_bad_import()` happened to independently catch and tag it `upgraderr-skip` (it doesn't
always fire — see below).

**Found live 2026-07-25**: Steamboy (radarr-hd) went Remux-1080p → 1080p Bluray (2026-06-21,
already a downgrade) → 720p Bluray (2026-07-01, a second downgrade) via two successive bad
grabs. A `found` webhook fired after the second one, and the row sat completely unevaluated for
24 days with **zero tags** — `_flag_if_bad_import` never caught it. The row's stored
`upgrade_reason` was `tier7_profile_mismatch` (from *before* the regression), which is why simply
re-checking the original reason isn't enough — the actual current problem (720p, tier3) is
unrelated to the stored reason and only shows up if you check the file against *every* simple
tier, not just the one it was originally queued for.

**Fix**: `_validate_stale_queue()` now also processes `status='found'` rows via a new
`_detect_simple_tier(fn)` helper that checks a file against all filename-detectable tiers
(1/2/3/5/8) regardless of the row's stored reason. If any tier still matches, the row reopens to
`pending` with the newly-detected reason and cleared cooldown. `tier8_x265_no_hdr` was added to
the detectable set at the same time (it didn't exist when tier8 shipped the day before). Verified
live: manually triggering validation reopened **147 previously-stuck 'found' movies** on
radarr-hd alone, Steamboy included. This is a **different** bug from the 2026-07-06 fix
mentioned elsewhere in this doc (that one was about clearing `found` rows that *were* already
resolved elsewhere so they don't block re-checks forever; this one is about `found` rows that
were *never actually resolved* in the first place).

**If you ever see a title that Upgraderr should clearly be upgrading just sitting there
unchanged for weeks, check `upgrade_queue.status` for that row before assuming the sweep or
search itself is broken** — `found` + no tag is the signature of this class of bug.

### Upgraderr Search Budget Was Tiny Relative to Backlog Size (raised 2026-07-25 — temporary)

`SweepBudget` (`searches_per_hour` / `UPGRADERR_SEARCHES_PER_HOUR`, and `downloads_per_day` /
`UPGRADERR_DOWNLOADS_PER_DAY`) resets fresh *every sweep run* (every 30 min) despite the env var
name suggesting a daily/hourly cap — so it's really "N new series/movies per instance, M total
across all 4 instances, per 30-minute sweep." Critically, `_sweep_sonarr`/`_sweep_radarr` check
this budget **before** calling `classify_tiers()` on a series/movie
(`if not budget.can_search(...) and not has_stale: continue`) — so once budget is exhausted for
that cycle, remaining series in that cycle's randomized order are never even classified, not
just left unsearched. Confirmed live: Tier 8 (x265-no-HDR-at-1080p, ~4600 episodes estimated
when the tier was added 2026-07-23) had only accumulated **88 queued items after 26 hours** at
the old default (5/instance, 10 global) — on the order of months to fully classify the backlog,
worse once the stuck-`found`-row fix above reopened 147 more movies into the same queue.

**Raised 2026-07-25**: `UPGRADERR_SEARCHES_PER_HOUR` 5→20, `UPGRADERR_DOWNLOADS_PER_DAY` 10→40
in `.env`, specifically to drain this backlog — same temporary-bump pattern as
`DEDUP_SAFETY_LIMIT` elsewhere in this doc. **Revert to 5/10 once the backlog is confirmed
drained** (check `SELECT priority_tier, status, COUNT(*) FROM upgrade_queue GROUP BY 1,2` — once
tier8 and the reopened `found` rows have worked through, there's no reason to keep searching
this aggressively for ongoing steady-state). Don't assume 20/40 is the intended long-term value
without checking this first.

### qbitmanage Orphaned-Data Race Condition (READ BEFORE MANUALLY RECOVERING A STUCK IMPORT)

**Root cause of most "unable to parse"/stuck-import complaints, found 2026-07-19**: qbitmanage runs
on the download Synology (10.0.1.203) with `QBT_REM_ORPHANED=true` on a 30-minute schedule
(`QBT_SCHEDULE=30`, config at `/volume1/docker/qbitmanage/config.yml` on that host). If a torrent
completes and gets removed from qBittorrent's active list before Radarr/Sonarr finishes importing it
(share-limit/cross-seed timing), qbitmanage's next sweep sees "file with no matching torrent" and
quarantines it into `/downloads/orphaned_data/<category>/`. Verified live: 287GB backlogged (227GB
radarr-hd + 60GB sonarr-hd), including releases Radarr/Sonarr were actively waiting to import (e.g.
The Pursuit of Happyness GPRS WEB-DL, grabbed 7/16, silently quarantined).

**`orphaned.empty_after_x_days` in that same config.yml auto-deletes this folder's contents** — was
60 days (oldest backlogged files were already 56.9 days old, ~3 days from permanent loss when found),
raised to **120 days** 2026-07-19 to match the seeding-retention theme (see torrent retention below).
This is a *different* setting from `share_limits`' `max_seeding_time` (also 120d for tracker groups) —
one governs the orphan quarantine folder, the other governs active torrent seeding/cleanup. Don't
conflate them.

**DO NOT just move a file back from `orphaned_data` to its expected download-client path and trigger
a `DownloadedMoviesScan`/`DownloadedEpisodesScan` and assume it's recovered** — confirmed live 2026-07-19
this does not reliably re-correlate to the pending queue grab (Radarr's scan matches by download
ID/history, not just "any video file present"), and worse, if qbitmanage's next 30-min cycle runs
before Sonarr/Radarr's import completes, **it will re-orphan the file you just moved back** — observed
happening in real time, with unpackerr additionally mangling the recovered file into a nested
duplicate-name folder in the process. **The reliable recovery path**: move the file back, then use
`POST /api/v3/command` with `name: "ManualImport"` and an explicit `files: [{path, movieId or
(seriesId + episodeIds), quality, languages}]` payload — this imports directly by path in one atomic
call without depending on qBittorrent/queue state at all, so it isn't subject to the race.
Stopping/pausing qbitmanage during recovery was considered but not done without explicit operator
sign-off, since it's a shared production service on that host.

### Key Path Mappings (Container → NFS → Destination)

```
/movies     → /mnt/synology/rs-movies        → /mnt/unraid/media/Movies
/movies-4k  → /mnt/synology/rs-4kmedia/4kmovies → /mnt/unraid/media/4K Movies
/tv         → /mnt/synology/rs-tv            → /mnt/unraid/media/TV Shows
/tv-4k      → /mnt/synology/rs-4kmedia/4ktv  → /mnt/unraid/media/4K TV Shows
```

## Shared TRaSH Scoring Config

**There are TWO scoring implementations in this codebase, not one — know which services
use which before assuming a value applies everywhere.**

| System | File | Used by |
|---|---|---|
| JSON config | `configs/scoring/trash_scoring.json` | `sync-webhook` (`_score_filename`), `curatorr/routes/duplicates.py` (`_score_plex_version`), `curatorr/routes/sync_status.py` (`_score`) |
| Python module | `scripts/lib/quality_scoring.py` | `services/upgraderr/app.py` (`get_current_score`/`calculate_quality_score`), `scripts/compare_libraries.py`, `scripts/compare_tv_libraries.py`, `scripts/cleanup_duplicates.py` |

The JSON is mounted read-only at `/app/scoring/trash_scoring.json` in `sync-webhook` and
`curatorr`; edit it and `docker compose restart sync-webhook curatorr` to apply. The
Python module requires a code change + `docker compose build upgraderr`. **These two
systems are NOT unified** — migrating Upgraderr onto the shared JSON is a known,
unfinished TODO (see `todo_unified_scoring.md` memory), not yet done.

### Consolidated scores (both systems, differences flagged)

| Concept | JSON (sync-webhook/curatorr) | Python module (Upgraderr/scripts) | Consistent? |
|---|---|---|---|
| Resolution 2160p/1080p/720p/SD | 4000/2000/0/−500 | 4000/2000/0/−500 | ✅ Same |
| Source, movies (Remux/Bluray/WEB-DL/WEBRip/HDTV) | 2000/1500/1000/800/200 | 2000/1500/1000/800/200 | ✅ Same |
| Source, TV (Remux/WEB-DL/Bluray/WEBRip/HDTV) | `tv_source` key added 2026-07-02: 2000/1200/1000/800/200, matches Python module | 2000/1200/1000/800/200 (`TV_SOURCE_SCORES`, WEB-DL intentionally beats Bluray) | ✅ Fixed 2026-07-02 — `_score_filename(media_type='tv')` in sync-webhook and `_score(media_type='tv')` in `curatorr/sync_status.py` both now use the TV table for TV call sites; movie call sites unaffected (still default `media_type='movie'`) |
| HDR (4K and HD tables) | Matches | Matches | ✅ Same |
| Audio (TrueHD Atmos/TrueHD/DTS-HD MA/DTS:X/DTS-HD/DTS/DD+/AC3/AAC) | Matches | Matches | ✅ Same |
| EAC3 Atmos vs generic Atmos | Distinguished: EAC3 Atmos=300, generic Atmos=500 | Not distinguished — anything tagged "Atmos" scores 500 | ⚠️ Diverges (minor) |
| Codec (AVC/x264/HEVC/x265/AV1/VC-1) | **Not scored at all** | AVC/x264=150, HEVC/x265=100, AV1=250, VC-1=100 | ⚠️ Only in Python module |
| x265 no-HDR-at-1080p penalty | −300 | −300 (same value, plus a +200 DV bonus the JSON lacks) | ✅ Value matches; module has one extra nuance |
| Container: MP4 | −100 | **Not scored at all** — this gap contributed to the 2026-07 Tier 7 incident (see Profile Authority section) | ⚠️ Only in JSON |
| Release group / `[Hybrid]` / Proper-Repack bonuses | +50 / +100 / +25 | **Not detected at all** | ⚠️ Only in JSON |
| Size bonus | +10/GB, cap 200 | +10/GB, cap 200 | ✅ Same |

**Practical implication:** the same file can score differently depending on which
service evaluates it. When debugging "why did X get picked over Y," check which
scoring system the relevant service actually uses before trusting a score you
computed with the other one.

See `docs/TRASHGUIDES_REFERENCE.md` for the full JSON-side reference and tuning instructions.

**gitignore**: `configs/scoring/` is whitelisted in `.gitignore` so the JSON is tracked in git.

## How the Applications Work Together

```
recyclarr  ──configures──▶  Radarr / Sonarr  ◀──triggers searches──  Upgraderr
   (quality profiles,           │                                        │
    custom formats,             │ webhooks on import                    │ sweep every 30 min:
    "allowed" qualities)        ▼                                        │ classify_tiers() +
                          sync-webhook                                   │ Tier 7 profile check
                     (copies new files to Unraid,                       │
                      nightly gap/version reconcile)                     ▼
                                │                                  webhook records
                                ▼                                  before/after quality,
                          Unraid Agent                             flags bad imports
                       (remote inventory API)                      (_flag_if_bad_import)
                                │
                                ▼
                            Curatorr
                  (browses both libraries, scoring,
                   dedup, rules engine, manual delete)
```

- **Recyclarr** is config-only (no runtime role) — it pushes TRaSH Guides quality
  profiles and custom formats into all 4 Radarr/Sonarr instances on a schedule.
  It decides what Radarr is *allowed* to grab and how releases are scored at
  grab-time. It does NOT decide which existing file wins a comparison — that's the
  scoring systems above.
- **Radarr/Sonarr** are the actual quality decision-makers at grab time, governed
  entirely by whatever profile/custom-format config recyclarr last pushed. Their
  assigned quality profile is authoritative — see Profile Authority above.
- **Upgraderr** doesn't grab anything itself — it only decides *when to ask Radarr/
  Sonarr to search* (via `POST /command`), based on 7 tiers (`classify_tiers()` +
  a profile-mismatch check). Once it triggers a search, the actual release selection
  is 100% Radarr's decision, governed by recyclarr's config. Upgraderr's own
  post-import check (`_flag_if_bad_import`) is the only place that verifies the
  *result* of that search was actually good.
- **sync-webhook** is one-way (Synology→Unraid) and append-only for real-time
  webhooks; nightly reconcile jobs are the only thing that can delete an Unraid file,
  and only to bring it in line with Radarr's tracked file (Profile Authority again).
  It has zero interaction with Upgraderr or recyclarr — it only cares what Radarr/
  Sonarr currently have on Synology.
- **Curatorr** is a read-heavy UI/analysis layer (browsing, scoring, watch history,
  rules) that also has direct-delete capability. It calls Radarr/Sonarr, Plex,
  Tautulli, and the Unraid Agent directly; it doesn't call sync-webhook or Upgraderr.
- **Unraid Agent** is the only thing anything on Mother uses to enumerate Unraid's
  filesystem — never CIFS listing (see Inventory Scanning above). Both sync-webhook
  and Curatorr depend on it.

**The chain that caused the 2026-07 incident**: recyclarr's custom formats were
broken (regex bug) → Radarr had no way to reject a bad release when Upgraderr's Tier
7 (correctly) forced a search → nothing downstream (sync-webhook, Curatorr) could
have caught it either, since they only mirror whatever Radarr/Sonarr currently track.
The fix had to happen at the recyclarr/Radarr layer, plus a new independent check
inside Upgraderr itself — no other service in the chain was positioned to catch it.

## Key Code Components

### `services/sync-webhook/app.py` (Flask app)
The largest and most critical codebase component. Handles:
- Webhook endpoints: `POST /sync/radarr`, `/sync/sonarr`, `/sync/manual`
- SQLite job tracking with retry logic (up to 20 retries)
- APScheduler tasks: daily summary, auto-retry (15min), history scanner (30min), **stall watchdog (15min)**, **TV gap scanner (11:00 PM ET)**, **movie gap scanner (11:30 PM ET)**, **library health report (12:15 AM ET)**, **Unraid dedup (8:00 AM ET)**
- Plex library scan integration (optional)
- Health/stats API: `GET /health`, `/stats`, `/jobs`
- Gap scan trigger: `POST /api/gap-scan/trigger`

**CRITICAL DESIGN RULE — APPEND-ONLY WEBHOOKS**: The webhook handlers NEVER delete files from Unraid. `MovieFileDelete` and `EpisodeFileDelete` events are intentionally ignored. Deletions happen exclusively through the nightly Unraid dedup job. This was implemented after a bug in the old sweep logic wiped 1,000+ episodes from Unraid.

**Stall Watchdog** (`check_stalled_syncs`): Self-healing mechanism that detects frozen rsync processes.
Monitors `/proc/<pid>/io` (rchar+wchar) every 15 min for each in-progress job. Kills the rsync
process group (`killpg`) if no I/O activity for `RSYNC_STALL_MINUTES` (default 15m) or if total
runtime exceeds `RSYNC_MAX_MINUTES` (default 240m). Uses `stall_killed` DB flag so the `do_sync()`
thread sends a "Stalled Sync Killed" Telegram alert instead of generic "Sync Failed".

**History scanner**: Uses `data.importedPath` (specific episode file) from Sonarr history
instead of `series.path` (entire show directory), preventing whole-show rsyncs that block the queue.
Catchup path only — no deletions. **Stale-entry guard**: Before queuing, checks `os.path.exists(source)`.
If the source file on Synology NFS no longer exists (Radarr/Sonarr upgraded it since import), the
scanner skips the entry and marks it `queued_this_scan` to avoid re-checking. This prevents phantom
jobs for replaced files from being recreated every 30 minutes.

**Movie Gap Scanner** (`scan_library_gaps`): Nightly at 11:30 PM ET. Compares Synology HD-movies
NFS listing vs Unraid folder list via Unraid Agent API. Queues missing folders as `GapSync` jobs.
HD movies only (4K excluded). Sends Telegram alert listing queued titles.
- Synology side: `os.listdir('/mnt/synology/rs-movies')` — NFS mount, fast local read
- Unraid side: `GET /inventory?path=/mnt/user/Media/Movies&refresh=true` via Unraid Agent — **never**
  use direct CIFS listing (`os.listdir('/mnt/unraid/media/Movies')`) which is unreliable over VPN
- Skips `#recycle`, `.lnk`, `.txt` entries and items already pending/in_progress in DB
- Skips items with a `success` record in the last 7 days

**TV Gap Scanner** (`scan_tv_gaps`): Nightly at 11:00 PM ET. Compares Synology rs-tv (per-episode NFS
scan) vs Unraid Agent TV inventory. Queues individual missing episode files as `TVGapSync` jobs.
- Quality filter (`_should_sync_tv_episode`): skips 720p/SD and x265 without HDR/DV — same rules as
  sync strategy table above. This prevents copying pre-upgrade versions to Unraid.
- Deduplicates gaps by (show, S##E##): if Synology has multiple versions of the same missing episode,
  picks the largest file (best-quality heuristic)
- Unraid inventory via `GET /inventory?path=/mnt/user/Media/TV%20Shows&refresh=true` on Agent

**Unraid Dedup** (`nightly_unraid_dedup`): Daily at **8:00 AM ET** (moved from midnight to morning to allow gap-scanner queue to drain overnight). Calls `GET /scan?refresh=true` on Unraid Agent. For each duplicate group, deletes lower-quality versions via `POST /delete` on Agent. Only deletes files marked `safe_to_delete=True` by Agent. Multiple safety checks in order: (1) `PAUSE_DEDUP` sentinel file, (2) active gap-sync jobs check, (3) `DEDUP_SAFETY_LIMIT` abort threshold, (4) `DEDUP_MAX_PER_RUN` per-run cap, (5) `DEDUP_DRY_RUN` preview mode. Sends Telegram with summary + top-10 largest deletions.

**Auto-retry stale-entry guard**: `auto_retry_failed()` also checks `os.path.exists(source)`. If source
is gone, sets all rows for that source path to `status='success', error_message='stale: source file upgraded'`
— permanently stops the retry loop for phantom entries without manual DB intervention.

**TRaSH scoring**: `_score_filename(fname, size_bytes)` loads constants from
`/app/scoring/trash_scoring.json` (shared volume mount) at module startup. All reconcile decisions
(movie version, TV version, gap scan quality filter) use this function. Resolution 2160p→1080p→4k/uhd
order prevents `[4K Remaster]` edition labels from overriding the real resolution tag.

**DB columns**: `rsync_pid`, `last_progress_bytes`, `last_progress_at`, `stall_killed` (added 2026-02-23)

### `scripts/compare_libraries.py` (~1500 lines) — Movies
Compares two movie library inventories using TMDB/IMDB matching and TRASH-format filename parsing. Generates three outputs: human-readable report, CSV sync plan, and executable sync shell script. Quality scoring prioritizes: Audio > HDR at 1080p (Atmos +500 > HDR +400).

### `scripts/compare_tv_libraries.py` (~900 lines) — TV
Compares two TV library inventories using TVDB + S##E## episode matching. Same output format as movie comparison but with TV-specific scoring (WEB-DL > BluRay for TV). Generated scripts use `do_rsync` for copies and `do_move` for deletions, with safety: `wait` before any deletes, and replacement file existence checks.

### `scripts/lib/quality_scoring.py` — Shared Quality Scoring
Single source of truth for TRaSH-aligned quality scoring. TV uses `TV_SOURCE_SCORES` (WEB-DL > BluRay), movies use `SOURCE_SCORES` (BluRay > WEB-DL). Used by both comparison scripts and `cleanup_duplicates.py`.

### `scripts/cleanup_duplicates.py` — Duplicate Cleanup
Finds and removes duplicate media files (movies and TV) on both Synology and Unraid. Uses shared quality scoring to keep the best version. Supports `--media-type movie|tv` and defaults to DRY_RUN=true.

### `scripts/generate_inventory.py` (~600 lines)
Scans media directories, extracts quality metadata from filenames via regex, outputs JSON/CSV inventories.

### `services/upgraderr/app.py` (Flask app)
Custom quality upgrade automation service replacing Huntarr. Handles:
- Discovery sweep every 30 min: classifies all 4 *arr instances into 7 upgrade tiers
- **7 Tiers**: m2ts/BDMV (1), non-MKV container (2), 720p/SD (3), TMDB BluRay available (4), no surround audio (5), low TRaSH score (6), quality profile mismatch (7 — file quality not in the assigned profile's allowed list; Radarr/Sonarr won't auto-search because `cutoffNotMet=false`; Upgraderr forces search **regardless of whether the current file scores higher than the profile allows — see Profile Authority above**). Tier 7 covers **both Radarr and Sonarr** as of 2026-07-02 (`_build_profile_allowed()` + the per-episode check in `_sweep_sonarr()`) — Sonarr had no equivalent before that.
- **Post-import safety net** (`_flag_if_bad_import`): independent of the tier system — after any webhook-recorded import, checks whether the *newly imported* file is itself objectively bad (matches Tiers 1-6, or a known-bad release group). If so, alerts via Telegram and tags `upgraderr-skip`. Does NOT alert on score drop alone — a Tier-7 profile-enforced swap is supposed to lower the raw score sometimes, and that's correct, not a bug.
- APScheduler tasks: sweep (every 30min), TMDB scan (02:30 UTC daily), DB backup (03:00 UTC daily), search log prune (04:00 UTC daily, keeps 90 days), **stale queue validation (05:00 UTC daily)** — removes queue entries whose upgrade reason no longer applies (e.g., show was upgraded outside the sweep flow)
- Global pause toggle + per-instance budget (searches/day from `config` table)
- Webhook endpoints: `POST /webhook/radarr`, `/webhook/sonarr` — records before/after quality on upgrades
- Manual search: `POST /api/queue/<id>/search`
- Bandwidth-aware: defers sweep if batch sync is actively writing (`/opt/sync_reports/` log mtime < 120s)
- Instance health indicators: 3s timeout check on each *arr's `/api/v3/system/status`
- JWT auth (bcrypt), rate-limited login (5/min per IP)
- Telegram notifications to `UPGRADERR_TELEGRAM_CHAT_ID`
- Tags: `upgraderr-skip` (permanent skip), `upgraderr-no-source` (no source found)

**DB tables**: `upgrade_queue`, `search_log`, `daily_stats`, `config`, `upgrade_history`, `tmdb_cache`

**TMDB Tier 4**: Calls TMDB `/movie/{id}/release_dates` to detect physical (BluRay/DVD) release.
Type 5 = Physical release. If physical release exists and ≥ `UPGRADERR_BLURAY_WAIT_DAYS` (90) days ago,
item is eligible for Tier 4 (better BluRay source likely available on indexers).
Results cached in `tmdb_cache` for 7 days.

**Port**: 9706 (host) → 5000 (container). UI: `http://mother:9706`

**Volumes**: `/opt/mother/reports` mounted read-only as `/opt/sync_reports` for sync activity detection.

### `services/curatorr/` (FastAPI + Vue 3 SPA)
Media intelligence and curation service. Comprehensive library browser with scoring, purge analysis, watch history, rules engine, and direct deletion. Handles:
- Full movie/TV library browser (7,659 movies, 1,660 shows) from Radarr + Sonarr + Plex
- Composite scoring: IMDb 35%, RT Critics 25%, MDBList 20%, Metacritic 15%, TMDB 5%
- Purge scoring (0-100): flags deletion candidates based on score, watch history, resolution, status
- Watch history from both Tautulli instances (Ali + Chris) via delta sync
- Rules engine: visual condition builder (AND/OR), schedule (daily/weekly/manual), actions (stage/unmonitor/notify/delete)
- TMDB collection tracking, duplicate detection
- Direct deletion: calls *arr API + removes file from Unraid NFS path
- **Filesystem duplicate scanner**: 4-tab UI — Synology Movies, Synology TV, Unraid Movies, Unraid TV. Scans NFS paths directly for Synology; calls Unraid Agent API for Unraid. TRaSH-scored, multi-select bulk delete with Synology `#recycle` purge.
- **Sync Status** (`/sync-status`): Real-time Synology↔Unraid parity view for HD Movies and TV. Shows In Sync / Missing / Version Mismatch / **Unraid Has Better** (amber — Unraid's TRaSH score > Radarr's Synology file; dedup handles Unraid; Upgraderr will upgrade Synology eventually) / **Radarr Out of Date** (amber — Synology folder has a higher-scored file than Radarr currently tracks; fix: trigger Radarr library rescan) / Not Downloaded. Has a **"Reconcile Now" button** that immediately triggers the reconcile jobs. All scoring via shared JSON config.
- APScheduler: 6h library sync, 02:00 watch history, 03:00 ratings, 04:00 rules, 04:30 backup, Sun 09:00 digest
- JWT dual-token auth (bcrypt, HttpOnly cookies, 1h access / 7d refresh)
- Telegram weekly digest via Apprise

**DB tables**: `movies`, `tv_shows`, `tv_seasons`, `ratings_cache`, `collections`, `watch_history`, `rules`, `rule_matches`, `deletion_log`, `config`, `sync_log`, `event_log`

**Sync sources**: Radarr (all instances), Sonarr (all instances), Plex XML API, Tautulli (both instances), OMDB, MDBList, TMDB

**Port**: 9707 (host) → 8000 (container). UI: `http://mother:9707`

**Tech stack**: FastAPI + aiosqlite (WAL, timeout=60) + Vue 3 + Pinia + Tailwind CSS + Vite (multi-stage Docker build)

**Key files**:
- `app/config.py` — env vars, path mappings (Synology NFS → Unraid), instance configs, `UNRAID_AGENT_URL`, `UNRAID_AGENT_API_KEY`
- `app/scoring.py` — composite + purge score computation
- `app/rules_engine.py` — condition evaluator, AND/OR logic, scheduled rule runner
- `app/log_events.py` — standalone `log_event(db, type, source, msg)` helper (no FastAPI imports)
- `app/routes/` — stats, movies, tv, collections, duplicates, rules, actions, sync, logs
- `app/routes/duplicates.py` — filesystem scanner; `GET /duplicates/scan` (30min cache); `POST /duplicates/bulk-delete` (Synology); `POST /duplicates/unraid-delete` (proxies to Unraid Agent)
- `app/sync/` — radarr, sonarr, plex, tautulli, omdb, mdblist, tmdb modules

**Duplicate scan details**:
- Synology scanned directly via NFS (fast). Results: ~514 movie groups, 0 TV groups (Synology is clean after duplicates removed).
- Unraid scanned via Unraid Agent HTTP API — avoids CIFS scan (200+ sec over VPN). Results: ~59 HD movie, ~1 4K movie, ~216 HD TV, ~12 4K TV groups (~1.1 TB deletable).
- Episode regex: `[Ss](\d{1,2})[Ee](\d{1,4})` — supports 4-digit episode numbers (One Piece S17E113).
- **Synology recycle bin**: Synology DSM intercepts NFS `unlink()` and moves files to `#recycle/`. `_purge_synology_recycle()` immediately removes the recycle copy so space is freed at delete time.
- **Safe route**: each server's cleanup is independent. Synology deletes go to `/duplicates/bulk-delete`. Unraid deletes proxy to the agent via `/duplicates/unraid-delete`.

### `services/unraid-agent/` (FastAPI on Unraid)
Lightweight FastAPI service deployed **on Unraid** (192.168.1.10:8100). Runs inside Docker with read-only bind mount of `/mnt/user/Media`. Provides fast local filesystem scanning that would be too slow over CIFS from Mother.

**Endpoints**:
- `GET /health` — liveness check, lists media root paths + existence
- `GET /inventory?path=<unraid_path>[&refresh=true]` — flat list of all video files under path; 30-min cache per path. Used by gap scanner, duplicate scanner. Response: `{ "items": [{ "path": "/mnt/user/Media/Movies/<folder>/<file>", "title", "size_bytes", "resolution", "source", "hdr", "audio_codec", ... }] }`
- `GET /scan[?refresh=true]` — full duplicate scan across all libraries; 30-min cache. Returns grouped duplicates for Curatorr UI
- `POST /delete` — delete files by path (validates against allowed prefixes, no symlink traversal). **Fixed and deployed 2026-07-02**: the prefix check used to run against the raw input path, and the symlink check only looked at whether the leaf itself was a symlink — a symlinked *intermediate* directory in the path could escape the allowed roots without tripping either check. Now resolves the full realpath first and checks that against the allowed prefixes, matching `/inventory`'s already-correct pattern.

**Auth**: `X-Api-Key` header, shared secret `AGENT_API_KEY` / `UNRAID_AGENT_API_KEY`

**TRaSH quality scoring**: Inline scoring identical to `scripts/lib/quality_scoring.py` — resolution (4K=4000, 1080p=2000, 720p=0), source (Remux=2000, BluRay=1500, WEB-DL=1000), HDR (DV HDR10+=800/4K, HDR10=700/4K), audio (TrueHD Atmos=500, DTS-HD MA=400), size bonus (+10/GB capped 200), HEVC penalty (-300 if no HDR).

**Media roots**: `/mnt/user/Media/Movies`, `/mnt/user/Media/4K Movies`, `/mnt/user/Media/TV Shows`, `/mnt/user/Media/4K TV Shows`

**Deployment — SSH access to Unraid IS available from Mother, use it directly (do not ask the user to do this manually, do not just flag a fix as "needs manual deployment"):**
```bash
ssh -i ~/.ssh/unraid_key root@192.168.1.10 "echo test"        # verify connectivity first
scp -i ~/.ssh/unraid_key services/unraid-agent/app.py \
    root@192.168.1.10:/boot/config/plugins/compose.manager/projects/unraid-agent/app.py
ssh -i ~/.ssh/unraid_key root@192.168.1.10 \
    "cd /boot/config/plugins/compose.manager/projects/unraid-agent && docker compose build && docker compose up -d"
```
Before overwriting `app.py` on Unraid, diff it against this repo's copy first (`diff <(ssh ... cat app.py) services/unraid-agent/app.py`) to confirm there's no Unraid-side-only drift before clobbering it. This is the *only* service in the project not managed by Mother's own `docker compose` — everything else (`sync-webhook`, `upgraderr`, `curatorr`, all *arr instances) rebuilds/redeploys locally via `docker compose build/up` from `/opt/mother`.

**Port**: 8100. Accessible from Mother at `http://192.168.1.10:8100` over VPN.

### `services/tracearr/` (Tracearr — stream analytics)
Node.js stream tracking service. Listens to Plex/Tautulli events and records per-stream metrics in TimescaleDB. Three containers: `tracearr` (3002), `tracearr-db` (TimescaleDB/PostgreSQL 18), `tracearr-redis` (Redis 8). Configured via env vars: `DATABASE_URL`, `REDIS_URL`, `JWT_SECRET`, `COOKIE_SECRET`. Data persisted in `configs/tracearr-db/`, `configs/tracearr-redis/`.

### Observability Stack (Loki + Grafana + Prometheus)
Added 2026-04-14. All three custom services (curatorr, upgraderr, sync-webhook) write structured logs to files under `/opt/mother/data/logs/` which Promtail ships to Loki.

| Component | Port | Config | Purpose |
|---|---|---|---|
| `grafana` | 3003 | `configs/grafana/` | Dashboards; login `admin` / env `GF_SECURITY_ADMIN_PASSWORD` |
| `prometheus` | 9090 | `configs/prometheus/prometheus.yml` | Scrapes node-exporter (9100), cAdvisor (8090), all *arr `/metrics` |
| `loki` | 3100 | `configs/loki/loki-config.yml` | Log storage; 30-day retention |
| `promtail` | — | `configs/promtail/promtail-config.yml` | Scrapes Docker stdout/stderr + file logs |
| `node-exporter` | 9100 | host network mode | Host CPU/RAM/disk/network metrics |
| `cadvisor` | 8090 | — | Per-container CPU/RAM/network metrics |

**File logging**: Each custom service writes rotating log files inside its container. Host mount paths
are **not uniform** — check the actual `docker-compose.yml` volume mount before assuming a path, since
this was previously undocumented incorrectly (see below). `curatorr` and `upgraderr` map to
`/opt/mother/data/logs/<service>/`; `sync-webhook` maps to `/opt/mother/configs/sync-webhook/logs/`
instead (a legacy path from before `data/logs/` existed — functions correctly, Promtail's config points
at the right place for each, just don't assume the `data/logs/` pattern applies to sync-webhook too).
All three keep **7 files total** (current + 6 rotated backups, `backupCount=6` in each service's
`RotatingFileHandler`/`RotatingFileHandler` setup — standardized 2026-07-19, was previously 10-11 files
for upgraderr/curatorr and 5-10 for sync-webhook's two log streams). Promtail picks all of these up
alongside Docker's own container-log scraping (see `configs/promtail/promtail-config.yml`).

### `reports/daily_report.py`
Unified status report (sync progress, VPN traffic, errors, Upgraderr queue summary). Sends via Apprise to Telegram. Runs from cron every 2 hours. Auto-discovers the most recent sync scripts by embedded timestamp.

## Common Commands

### Docker Operations
```bash
cd /opt/mother && docker compose up -d                # Start all
docker compose up -d sync-webhook                     # Restart one service
docker logs sync-webhook --tail 100                   # View logs
docker ps --format "table {{.Names}}\t{{.Status}}"   # Status
```

### Sync Management
```bash
/opt/mother/scripts/sync-control.sh status    # Check sync state
/opt/mother/scripts/sync-control.sh pause     # Pause batch syncs
/opt/mother/scripts/sync-control.sh resume    # Resume batch syncs
screen -r movie                               # Attach to movie sync
screen -r tvsync                              # Attach to TV sync
# Detach from screen: Ctrl+A, D
```

### Library Analysis
```bash
/opt/mother/scripts/analyze_all.sh                # Full analysis (Movies + TV)
/opt/mother/scripts/analyze_movies.sh --1080p     # 1080p movies only
/opt/mother/scripts/analyze_tv.sh --4k            # 4K TV only
python3 /opt/mother/scripts/generate_inventory.py /path/to/media -o output_name
python3 /opt/mother/scripts/compare_libraries.py ali.json chris.json
```

### Monitoring & Reporting
```bash
/opt/mother/reports/daily_report.py --dry-run        # Test report
curl http://localhost:5001/health                     # Webhook health
curl http://localhost:5001/stats                      # Sync stats
curl http://localhost:5001/jobs?limit=10              # Recent jobs
curl http://localhost:9706/health                     # Upgraderr health
# Upgraderr UI: http://mother:9706  (JWT login required)
```

### Deployment Script
```bash
/opt/mother/scripts/deploy.sh              # Full deployment
/opt/mother/scripts/deploy.sh status       # Container status
/opt/mother/scripts/deploy.sh restart      # Restart all
/opt/mother/scripts/backup.sh              # Create backup
```

## Cron Jobs on Mother

```
*/2 * * * *  /opt/mother/vpn_ping_monitor.sh                    # VPN health (ping 192.168.1.10; Telegram on state change)
*/10 * * * * /opt/mother/scripts/check-sync-health.sh           # Batch sync health
30 * * * *   /opt/mother/sync_stall_check.sh                    # Stall detection
0 0,2,4,6,8,10,12,14,16,18,20,22 * * * /opt/mother/reports/daily_report.py  # Status report (every 2h)
58 23 * * *  /opt/mother/reports/daily_report.py                # End-of-day report
```

**APScheduler jobs (inside containers — not cron):**
Note: sync-webhook times are Eastern (America/New_York, DST-aware). Other services still use UTC.
| Time (ET) | Service | Job |
|---|---|---|
| Every 15 min | sync-webhook | Auto-retry failed jobs (exponential backoff: 15m→1h→4h→12h) |
| Every 15 min | sync-webhook | Stall watchdog (kills frozen rsync after 15min no I/O) |
| Every 30 min | sync-webhook | History scanner (checks *arr history for missed downloads, last 6h) |
| Every 30 min | upgraderr | Quality sweep (classifies all *arr items into tiers, triggers searches) |
| 8:05 PM ET | sync-webhook | Daily summary Telegram notification |
| 10:00 PM ET | sync-webhook | DB backup |
| 02:00 UTC | curatorr | Watch history sync (Tautulli delta) |
| 02:30 UTC | upgraderr | TMDB BluRay release date scan (pre-caches Tier 4 eligibility) |
| 03:00 UTC | upgraderr | DB backup (keeps last 10) |
| 03:00 UTC | curatorr | Ratings refresh (OMDB/MDBList/TMDB) |
| 11:00 PM ET | sync-webhook | **TV gap scanner** (Synology rs-tv per-episode vs Unraid Agent; queues missing TV episodes) |
| 11:15 PM ET | sync-webhook | **TV version reconcile** (compares filenames for episodes on both sides; queues TVVersionSync + deletes old Unraid file on success) |
| 11:30 PM ET | sync-webhook | **Movie gap scanner** (Synology rs-movies folder vs Unraid Agent; queues missing HD movies) |
| 11:45 PM ET | sync-webhook | **Movie version reconcile** (same as TV reconcile but for movies; queues MovieVersionSync) |
| 12:15 AM ET | sync-webhook | **Library health report** (missing movies + TV summary to Telegram) |
| 04:00 UTC | upgraderr | Search log prune (keeps 90 days) |
| 04:00 UTC | curatorr | Rules engine run |
| 04:30 UTC | curatorr | DB backup |
| 8:00 AM ET | sync-webhook | **Unraid dedup** (Agent /scan → /delete lower-quality duplicates; runs in morning after overnight rsync queue drains) |
| 06:00 UTC | curatorr | Library sync (Radarr + Sonarr + Plex full rescan) |
| Sun 09:00 UTC | curatorr | Weekly digest (Telegram summary via Apprise) |

## Environment & Configuration

- **`.env`** — All secrets, API keys, IPs, ports, sync config. Never committed (`.gitignore`).
- **`.env.example`** — Template with placeholder values.
- **`docker-compose.yml`** — 29 services. Uses `mother_network` bridge network.
- **`configs/recyclarr/recyclarr.yml`** — TRASHGuides quality profiles for all 4 Radarr/Sonarr instances.

### Docker Services (full inventory)

**Custom-built services (from `services/`):**
| Service | Port | Purpose |
|---|---|---|
| `sync-webhook` | 5001 | Flask sync service; Radarr/Sonarr webhook receiver + rsync queue |
| `upgraderr` | 9706 | Quality upgrade automation; replaces Huntarr; TRaSH tier-based |
| `curatorr` | 9707 | Media intelligence & curation; FastAPI + Vue 3 SPA |

**Media management:**
| Service | Port | Purpose |
|---|---|---|
| `radarr-hd` | 7878 | HD movie management |
| `radarr-4k` | 7879 | 4K movie management |
| `sonarr-hd` | 8989 | HD TV management |
| `sonarr-4k` | 8990 | 4K TV management |
| `prowlarr` | 9696 | Indexer management (replaces Jackett) |
| `recyclarr` | — | TRaSHGuides quality profile sync (scheduled, no UI) |
| `unpackerr` | — | Auto-extracts downloads from qBittorrent |
| `overseerr` | 5055 | Media request management (Ali uses own Seerr on Terminus) |
| `flaresolverr` | 8191 | Cloudflare bypass for indexers |

**Monitoring & observability:**
| Service | Port | Purpose |
|---|---|---|
| `grafana` | 3003 | Dashboards; provisioned with Loki + Prometheus datasources |
| `prometheus` | 9090 | Metrics scraping; 30-day retention |
| `loki` | 3100 | Log aggregation; receives from Promtail |
| `promtail` | — | Log shipper; scrapes Docker container logs + `/opt/mother/data/logs` |
| `node-exporter` | 9100 | Host metrics (CPU, RAM, disk, network) |
| `cadvisor` | 8090 | Container-level metrics |
| `tautulli` | 8181 | Plex watch history (Chris's instance; Ali has own on Terminus) |
| `tracearr` | 3002 | Stream analytics; Node.js + TimescaleDB + Redis |
| `tracearr-db` | — | TimescaleDB (PostgreSQL 18 + TimescaleDB 2.25) |
| `tracearr-redis` | — | Redis 8 (Tracearr session cache) |
| `uptime-kuma` | 3001 | Service uptime monitoring — image tag `louislam/uptime-kuma:2` (upgraded from 1.23.17 to 2.4.0 on 2026-07-19; `:latest` does NOT track 2.x, use `:2` explicitly). Had monitors configured for Terminus's own network but none for Mother's own resources until this session — see monitor list sent to Ali 2026-07-19. No REST API for scripting monitor management (Socket.IO only); `uptime-kuma-api` PyPI package doesn't support 2.x — add/edit monitors via the UI. |
| `dozzle` | 8080 | Live Docker log viewer (web UI). `DOZZLE_REMOTE_AGENT=10.0.1.203:7007` added 2026-07-19 — see Download Synology section below for the agent side. |

**Infrastructure:**
| Service | Port | Purpose |
|---|---|---|
| `nginx-proxy-manager` | 80/443/81 | Reverse proxy + SSL termination |
| `dockhand` | 3000 | Container auto-update watcher (removed Portainer 2026-07-19 — redundant, Dockhand covers this) |
| `apprise` | 8000 | Notification hub (Telegram via `http://apprise:8000/notify/apprise`) |
| `backrest` | 9898 | Restic backup UI (replaced Duplicati) |

**Not on Mother (external/migrated):**
- qBittorrent — migrated to Synology RS2821RP+ at `10.0.1.203:8080`
- qbit-manage — migrated to Synology
- Unraid Agent — runs ON Unraid at `192.168.1.10:8100` (separate compose project)

### Download Synology (10.0.1.203) — SSH access added 2026-07-19

SSH access from Mother: `ssh synology-dl` (config in `~/.ssh/config`, key `~/.ssh/synology_dl_key`,
user `alig`, in the `administrators` group). Required enabling DSM's "User Home" service first
(Control Panel → User & Group → Advanced) — without it `/var/services/homes/<user>` doesn't exist and
`authorized_keys` has nowhere to live. `docker`/`docker-compose` aren't on the default PATH for
non-interactive SSH sessions — use the full path `/usr/local/bin/docker`, and it needs `sudo` (alig's
group membership alone isn't enough for the Docker socket). `sudo` requires a real TTY for non-`docker`
commands (`mkdir`, `tee`, etc. all fail non-interactively) — plain user permissions cover
`/volume1/docker/**` for file writes; reserve `sudo` for the `docker` binary itself.

**Migrated off DSM Container Manager to a real docker-compose stack, 2026-07-19.** Previously this
host's 6 containers (`qbittorrent`, `qui`, `cross-seed`, `qbitmanage`, `hawser`, `dozzle-agent`) were
GUI-managed by DSM's Container Manager with no on-disk compose file (confirmed via exhaustive
filesystem search — DSM keeps project state in its own internal DB, not a plain YAML). Now managed via
`/volume1/docker/qbittorrentstack/docker-compose.yml`, project name `mother-dlstack` (deliberately
**not** `qbittorrentstack` — that name collided with DSM's old internal project tracking during the
cutover, see incident below), secrets in a sibling `.env` (`QBITMANAGE_QBT_USER/PASS`, `HAWSER_TOKEN`).
Deploy/update: `ssh synology-dl "cd /volume1/docker/qbittorrentstack && sudo /usr/local/bin/docker
compose -p mother-dlstack up -d"`. All bind-mounted data (`/volume1/Downloads`, `/volume1/docker/*`)
is unaffected by container recreation — only the container *instances* changed, not the underlying
files.

**2026-07-19 migration incident — ~50 min of download-stack downtime, root cause found via `strace`.**
After the DSM→compose cutover, qBittorrent crash-looped continuously (new process every 5–60s, clean
`exit_group(0)` with no signal ever delivered — ruled out via `strace -f`, so not an OOM/kill/DSM
reconciliation issue despite that being the leading theory for a while). Root cause: a **stale
single-instance lockfile** (`/config/qBittorrent/lockfile`, holding the *old* container's hostname/PID)
survived the container swap. Every fresh qBittorrent-nox process detected the lock, tried to hand off
via `/config/qBittorrent/ipc-socket`, got `ECONNREFUSED` (no real process holds it), and — rather than
recovering — chose to exit gracefully. This produces **zero trace in `docker events`** since it's an
internal application decision, not something Docker or the host ever sees. Fix: `rm -f
/config/qBittorrent/lockfile /config/qBittorrent/ipc-socket` then restart. **If qBittorrent (or likely
any single-instance-locking app) ever crash-loops right after a container recreate/host move with no
Docker-level restart count increasing, check for a stale lockfile before anything else** — ruled out
first, in order: Dockhand (stopped it entirely, no change), DSM Container Manager project-name
collision (renamed the compose project, no change — though *did* independently confirm DSM's Container
Manager was fighting something, since the user ultimately had to clear stale container records from its
GUI before the compose stack could even come up cleanly a second time), memory/ulimits (fine, 29GB free
host memory throughout), and the torrent resume data itself (BT_backup) — a fresh empty profile started
fine, which correctly pointed at *some* file under `/config/qBittorrent/config`/`lockfile` rather than
BT_backup, narrowing it down. Confirmed fully recovered: all 8939 torrents reloaded, cross-seed and
qbitmanage both reconnected without further intervention.

**2026-07-24 recurrence — same stale-lockfile bug, now fixed permanently, plus monitoring gaps
closed.** The exact 2026-07-19 failure mode recurred: qBittorrent's container was recreated
(`RestartCount: 0` — a fresh container, not a crash-restarted one; trigger still unconfirmed,
`journalctl` on this host returns "No journal files were found" everywhere because
`journald.conf` has `Storage=volatile` and the relevant boot's ring buffer was already gone by
the time this was checked — not a permissions issue, a real dead end for retroactive
investigation) and the leftover `lockfile`/`ipc-socket` from the previous container blocked
every new qBittorrent-nox process from starting, crash-looping every ~1s. Radarr and decluttarr
both threw continuous connection errors against the dead WebUI for hours before it was noticed.
**Permanent fix, deployed same session**: this compose project is now git-tracked at
`/opt/mother/remote-hosts/download-synology/` (mirrors the live `/volume1/docker/qbittorrentstack/`
1:1 — deploy by editing the repo copy first, then `ssh synology-dl "cat > <host path>" < <repo
path>` per file since `scp`'s SFTP subsystem is unreliable on this host — plain SSH exec always
works — then `ssh synology-dl "cd /volume1/docker/qbittorrentstack && sudo /usr/local/bin/docker
compose -p mother-dlstack up -d"`). Three additions closed this failure mode for good:
1) `qbittorrent-init/clear-stale-lock.sh` mounted at `/custom-cont-init.d/` (LinuxServer.io's s6
   hook that runs once before the app starts) unconditionally deletes `lockfile`/`ipc-socket` —
   safe because every container recreation is guaranteed to be the only live process against that
   `/config` volume, so any lockfile present at startup is by definition stale, never a real
   conflict.
2) A Docker `HEALTHCHECK` on `qbittorrent` (curls the WebUI API; `start_period: 300s` since 8900+
   torrents take ~4min to restore from `BT_backup` on a fresh start — confirmed live 2026-07-24,
   don't shrink this without re-checking against current torrent count). **Required companion
   setting, not in the compose file**: qBittorrent returned 403 to the in-container healthcheck
   until `WebUI\LocalHostAuth=false` was set (qBittorrent's own preference, "bypass auth for
   localhost clients" — inverted boolean naming) via `POST /api/v2/app/setPreferences
   '{"bypass_local_auth": true}'`. The existing `AuthSubnetWhitelist` (10.0.0.0/23, 192.168.0.0/23,
   172.16.0.0/12) covers Mother/Unraid and the Docker bridge range but never covered `127.0.0.1`,
   which is what a healthcheck running *inside* the container uses. This persists in
   `qBittorrent.conf` on the `/config` volume, so it survives container recreation — but if
   `/config` is ever rebuilt from scratch, this has to be re-applied via the API call above or the
   healthcheck (and therefore autoheal) silently goes blind again.
3) An `autoheal` sidecar (`willfarrell/autoheal`, `AUTOHEAL_CONTAINER_LABEL=all`) added to this
   compose file — restarts any container Docker marks `unhealthy`. Safe to watch "all" here since
   `qbittorrent` is the only service in this stack with a healthcheck defined.
`qbitmanage/config.yml` and `qbitmanage_util_override.py` are also now mirrored into the repo
under `remote-hosts/download-synology/qbitmanage/` (the Notifiarr API key in `config.yml` is
redacted in the repo copy — real value stays host-only). **The "600 notifications" Ali received
during this incident were not from decluttarr or Radarr directly** — verified neither has any
Telegram/Apprise notification connection configured for this, and the Apprise hub logged zero
inbound requests during the whole outage window. The real source is almost certainly Dockhand's
own `container_events`/activity feed: it already tracks both Mother and this host (environment
id 2, `Synology-Downloaders`, connected via `hawser`) and logged a `health_status`/`die` pair
for decluttarr roughly every 30s throughout — that reads as "hundreds of notifications" if you're
watching Dockhand's UI, even though it wasn't an actual push alert (Dockhand's one configured
Apprise notification channel, id 1 "Server Notifications", has `event_types: []` — enabled but
subscribed to nothing, so it has never actually fired). See monitoring-architecture note below.

**Monitoring/alerting architecture decision, 2026-07-24 (don't re-litigate without re-reading this):**
Dockhand already does cross-host container-event capture (via `hawser` agents) and has an Apprise
channel wired to the same Telegram pipe every other service uses — it just isn't subscribed to any
`event_types` yet. It does **not** do health-triggered auto-restart itself (no such table/feature
found in its schema); that's what `autoheal` is for, added above. Recommended split going forward:
Dockhand = cross-host container/image lifecycle visibility + alerting (once `event_types` is
configured for `health_status`/`die`/image-update events — UI-only, no API access without a login
session, do this via the Dockhand web UI at `http://mother:3000`, not by writing to
`configs/dockhand/db/dockhand.db` directly, which is a live SQLite DB and editing it out-of-band
risks the same class of corruption documented in [[upgraderr_db_corruption_pattern]]). Uptime Kuma =
independent black-box HTTP/TCP/ping checks (catches an outage even if Docker's own health-check
pipeline is itself the thing broken) plus non-Docker service monitoring. They're complementary, not
redundant — don't replace one with the other.

Services: `qbittorrent`, `qui` (modern multi-instance WebUI, port 7476), `cross-seed` (hardlink
cross-seeding, port 2468, no deletion logic of its own), `qbitmanage` (tags/categories/share-limits/
orphan cleanup, config at `/volume1/docker/qbitmanage/config.yml` on that host, runs every 30 min).
Retention: all
tracker-based `share_limits` groups use `max_seeding_time: 120d` with `cleanup: true`; a torrent won't
actually get cut off at 120d if it's had peer activity within its group's `min_last_active` window
(varies 2–90 days per tracker — this, not a broken purge, is why some very old torrents are still
present). `orphaned.empty_after_x_days: 120` (raised from 60 on 2026-07-19) separately auto-deletes
the orphan quarantine folder — see the qbitmanage race-condition section above. **`orphaned.
min_file_age_minutes` raised 0→180 on 2026-07-19** — this was the actual root-cause knob for the
qbitmanage race condition: with 0, a file completed seconds ago could be swept into orphaned_data
before Radarr/Sonarr's own import cycle ever got a chance to see it. 180 min gives that cycle real
headroom. Config at `/volume1/docker/qbitmanage/config.yml` on 10.0.1.203 (backed up to `.backups/`
before editing — do the same for any future change there).

**cross-seed** (`/volume1/docker/cross-seed/config.js` on 10.0.1.203) — `includeSingleEpisodes`
flipped false→true 2026-07-19 for broader cross-seed coverage (matches individual TV episodes, not
just full releases/season packs). Note: cross-seed itself warns this combination
("includeSingleEpisodes is not recommended when using announce") isn't the officially-recommended
setup for an announce/RSS-based config like this one — left on per Ali's explicit choice, just
flagging the caveat for future reference if cross-seed behavior ever looks off.

**qbitmanage `rem_unregistered` matching gap — found and fixed 2026-07-19.** 235 torrents sat
permanently tagged `issue` but never removed, despite `rem_unregistered: true`. Root cause: qbitmanage's
built-in `UNREGISTERED_MSGS` list (in `/app/modules/util.py`) requires phrases like `"TORRENT NOT
FOUND"` — but TorrentLeech (and a couple other trackers) return bare `"Not Found"`, which never matches
that substring check (225 of the 235 cases; the remaining ~10 use phrasing that should already match and
weren't investigated further). Fixed via a **local override**: `qbitmanage_util_override.py` (a copy of
upstream's `util.py` with `"NOT FOUND"` added to `UNREGISTERED_MSGS`) bind-mounted over
`/app/modules/util.py` in the compose file — this is a strict superset of the upstream match list, so it
can't introduce new false-negatives, only catch cases upstream already misses. **Re-diff
`qbitmanage_util_override.py` against a fresh image's `/app/modules/util.py` before ever bumping the
`qbitmanage` image version** — if upstream restructures this file, the override could silently stop
applying or (worse) revert to an older match list.

**`decluttarr`** (`ghcr.io/manimatter/decluttarr`) — added to Mother's own `docker-compose.yml`
2026-07-19 for Radarr/Sonarr/qBittorrent queue hygiene (stalled/failed-import/orphaned/metadata-missing
removal). Config at `configs/decluttarr/config.yaml`. Deliberately does **not** own search-triggering
(`search_unmet_cutoff`/`search_missing` left disabled) — Upgraderr already owns that decision for this
stack. Started in `test_run: true` (dry-run); flip to `false` only after reviewing logs.

**`hawser`** (`ghcr.io/finsys/hawser`) — Dockhand's own remote-agent, already deployed on this Synology
(not something we added) but **found stopped for 6 days** on 2026-07-19 (`Exited (0)`, clean shutdown,
`FinishedAt` both prior stops at ~08:00 — looks tied to a periodic DSM/Container Manager restart, not a
crash) despite `restart: always`. This is *why* Dockhand couldn't manage/auto-update this Synology's
containers — its logs showed constant `Unable to connect` errors to `10.0.1.203:2376` the whole time.
Started back up 2026-07-19 (`docker start hawser` via SSH) — Dockhand reconnected within the next poll
cycle. **If Dockhand logs show `hawser` connection errors again, check `docker ps -a --filter
name=hawser` on that host first** — this exact silent-exit pattern is the known failure mode.
`docker inspect hawser` confirmed `RestartPolicy: always`, so the daemon-restart theory needs one more
occurrence to confirm; no fix attempted beyond restarting it, since the root cause of the *original*
6-day-old exit is still unconfirmed. Uptime Kuma monitoring for it (Docker-container monitor type,
already supported) was **not** set up via automation — Uptime Kuma has no plain REST API for adding
monitors (Socket.IO-only), and scripting around that risked touching its live DB. **Add this monitor
manually**: Uptime Kuma → Add New Monitor → Docker Container → host `10.0.1.203:2376` (or via hawser's
own proxy) → container `hawser`.

**`dozzle-agent`** (`amir20/dozzle:latest agent`, port 7007) — originally deployed via a standalone
`docker run --restart always` (no compose file existed yet at the time); now part of the
`mother-dlstack` compose project along with the other 5 services (see migration note above). Mother's
`dozzle` service has `DOZZLE_REMOTE_AGENT=10.0.1.203:7007` — confirmed working via its startup log
(`"clients":2`). This Synology's containers now show up in Mother's existing Dozzle UI at the usual
port.

## Python Dependencies

The sync-webhook service uses: `flask`, `gunicorn`, `requests`, `apprise`, `apscheduler` (see `services/sync-webhook/requirements.txt`).

Analysis scripts use: `tqdm` (optional, for progress bars). Some scripts use `pandas`.

## Key Documentation

| File | Purpose |
|------|---------|
| `docs/OPERATIONS.md` | Day-to-day operations, monitoring, troubleshooting |
| `docs/CURATORR.md` | Curatorr user guide — navigation, scoring, duplicates, rules, deletion |
| `services/upgraderr/README.md` | Upgraderr service — setup, tiers, webhooks, env vars |
| `docs/WORKFLOW.md` | Full system workflow diagrams — data flow, Upgraderr pipeline, network topology |
| `docs/SYNC_AUTOSTART.md` | Boot and health monitoring setup |
| `services/sync-webhook/README.md` | Webhook sync service documentation |
| `scripts/README.md` | All scripts with usage examples |

## Important Conventions

- Most destructive scripts default to **dry-run mode**. Check for `DRY_RUN` variables before running.
- Batch sync scripts use a `PAUSE_SYNC` sentinel file (`/opt/mother/PAUSE_SYNC`) to pause without killing running transfers.
- The webhook service translates container paths → NFS mount paths → Unraid destination paths. Path mapping logic is in `app.py`.
- Quality scoring follows TRASHGuides preferences: HDR formats, Atmos audio, Remux sources. At 1080p, audio quality trumps HDR.
- Generated sync scripts (in `reports/`) are timestamped and executable. They contain rsync commands with `--ignore-existing`.
- Movie batch sync is **disabled** via `/opt/mother/DISABLE_MOVIE_SYNC` sentinel file. Read by `scripts/check-sync-health.sh` and `scripts/start-sync-screens.sh` — prevents the obsolete `movie` batch-sync screen from being restarted. Does not affect webhooks, gap scanner, or reconcile.
- TV batch sync screen (`tvsync`) completed Jun 17 2026, disabled the same way via `/opt/mother/DISABLE_TV_SYNC` sentinel (same two scripts). The screen session can be closed; nightly gap scanner handles ongoing TV sync.
- `/opt/mother/PAUSE_DEDUP` sentinel **should exist while any batch sync is running**. Remove only after batch sync completes and gap scanner has had one clean verification run. **Status as of 2026-07-02: this sentinel has been present continuously since 2026-06-17 — Unraid dedup has not run in 2+ weeks.** Batch sync completed and verified long ago; whether to remove it is Ali's call given the June dedup mass-deletion incident, not something to do unilaterally.
- Dedup now runs at 8:00 AM ET (not midnight) — see Dedup Safety Controls section above.
