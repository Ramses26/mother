# Quality Upgrades — Getting the *Best* Copy of Everything

**Last updated**: 2026-08-18

This document covers the quality-upgrade system built out in August 2026: how Upgraderr
now **deterministically acquires the best available release** of every movie, rather than
only fixing gross quality problems (720p, bad containers, etc.).

The short version: **RSS = speed, Upgraderr = quality.** Radarr/Sonarr's RSS still grabs
new releases the moment they appear (fast acquisition for eager viewers), and Upgraderr
independently works the whole library toward the best encode/audio available.

---

## The Tiers (now 9)

Upgraderr's 30-minute sweep classifies every tracked file into tiers and acts on the
highest-priority problem it finds. Tiers 8 and 9 were added in July–August 2026.

| Tier | Problem | Action |
|------|---------|--------|
| 1 | m2ts/BDMV raw disc | Search for an encode |
| 2 | Non-MKV container (mp4/avi/…) | Search for MKV |
| 3 | 720p / SD | Search for 1080p |
| 4 | WEB-DL where a physical BluRay is ≥7 days old (TMDB) | Search for BluRay |
| 5 | No surround audio | Search for Atmos/DTS-HD |
| 6 | Low absolute TRaSH score | Search |
| 7 | Quality not allowed by the assigned profile | Force a search (Profile Authority) |
| 8 | 1080p x265 **without** HDR/DV | Search for HDR or non-x265 |
| **9** | **Release-group quality** — not a TRaSH Tier-1 group for its source, a known-bad group, **or a Remux on a profile that prefers a Bluray-1080p encode** | **Force-grab the best release** |

Tiers 1–8 trigger a normal Radarr/Sonarr search. **Tier 9 uses force-grab** (below).

---

## How the non-obvious tiers decide

Most tiers are read straight from the filename (resolution, container, codec, audio). Three
are worth understanding because they reach outside the file:

### Tier 4 — "is the Blu-ray out yet?" (TMDB)
Upgraderr does **not** blindly assume a WEB-DL movie can be upgraded to Blu-ray — it checks
whether a Blu-ray actually *exists* first, via TMDB:

1. Query `GET /movie/{tmdb_id}/release_dates`.
2. Scan every country for **release type 5 = Physical** (Blu-ray/DVD); take the **earliest** date.
3. Fire Tier 4 only once that physical date is **≥ `UPGRADERR_BLURAY_WAIT_DAYS` (7) days old**
   — a deliberate buffer so a rip has had time to appear on the indexers.
4. If TMDB shows releases but **no** physical date, the title is flagged **streaming-only** and
   Tier 4 is skipped (nothing to chase — e.g. a Netflix-exclusive).

Results are cached 7 days (`tmdb_cache` table), and a **nightly TMDB scan at 02:30 UTC**
pre-caches eligibility so the sweep doesn't hammer the API. Requires `TMDB_API_KEY`;
tunable via `UPGRADERR_BLURAY_WAIT_DAYS`.

> A Blu-ray *scheduled in the future* won't trigger (its age is negative), so Upgraderr never
> wastes searches hunting a release that isn't out.

### Tier 7 — Profile Authority
Fires when a file's quality **isn't in its assigned profile's allowed list** — *regardless of
whether the current file is objectively "better."* A Remux sitting in a Bluray-only profile is
wrong for that profile and gets replaced. The assigned profile is the source of truth, always.
Radarr/Sonarr won't self-search these (`cutoffNotMet=false`), so Upgraderr forces it. Covers
both Radarr and Sonarr.

### Tier 8 — x265 without HDR
1080p **x265/HEVC without HDR or Dolby Vision** is undesirable (the whole point of x265 is the
HDR). Tier 3 (720p) and Tier 6 (absolute score) both miss this class, so Tier 8 catches it
explicitly and searches for an HDR or non-x265 1080p release.

---

## Force-Grab — Upgraderr picks the release, not Radarr

**The problem it solves:** Radarr's RSS/search grabs the *best release currently in the
feed*, which is often **not** the best release *available*. Example (Mars Attacks!, Aug
2026): RSS grabbed an `SM737` x265 copy (CF 3600) because it was newest-in-feed, while a
much better `HiDt` hybrid (CF 5450, DV+HDR + Atmos) was sitting on the indexers, off-feed.
Per the Servarr wiki, *"custom formats have no influence on what is searched, only how
results are evaluated"* — Radarr has no native "find the best release across all indexers"
behaviour. That is exactly what force-grab adds.

**How it works** (`_radarr_force_grab` in `services/upgraderr/app.py`):
1. Interactive search: `GET /api/v3/release?movieId=…` — a full query across every indexer.
2. Filter to **grabbable** releases (no rejections), of the wanted quality, not a known-bad group.
3. Pick the **highest custom-format score**.
4. Grab that exact release: `POST /api/v3/release {guid, indexerId}`.

Because Upgraderr chooses the specific release, the library converges on the genuinely-best
copy instead of whatever RSS happened to grab first.

---

## qBit-First — import an existing good copy for free

Many upgrades are already sitting completed in qBittorrent (e.g. a good Bluray a movie
briefly had before a bug reverted it to Remux). **qBit-first checks qBit before downloading**
and imports the existing file rather than re-downloading it.

- `_qbit_find_good_bluray` matches a movie to a completed qBit torrent that is a genuinely
  good encode (**tier-1/2/3 release group, not known-bad, not mp4/avi**) — never a scene
  or BHDStudio copy.
- `_radarr_manual_import` imports it via Radarr `ManualImport` (importMode `copy`). Imports
  are **serialized** and slow: `/downloads` (rs-4kmedia) and `/movies` (rs-movies) are on
  *different* Synology devices, so every import is a real ~12 GB cross-NAS copy, not a hardlink.
- Safe de-dup: the old Remux file is only ever deleted once a verified **new** Bluray-1080p
  movieFile is confirmed in hand.

**Run the one-time backlog** (dry-run by default):

```bash
# Preview which Remux have a good Bluray already in qBit
curl -s -X POST "http://localhost:9706/api/qbit-remux-backlog?dry_run=true" | python3 -m json.tool

# Go live (serialized, slow — runs in the background)
curl -s -X POST "http://localhost:9706/api/qbit-remux-backlog?dry_run=false"
```

> ⚠️ The backlog runs in a background thread — **do not `docker compose up -d upgraderr`
> while it is running**, or the thread dies. It is re-runnable (fixed movies drop out).

---

## Remux → Bluray-1080p (profile 7)

The "HD Bluray + WEB" profile (id 7) **prefers a space-efficient Bluray-1080p encode** and
only keeps a Remux as a fallback when no encode exists (the 2026-08-01 "quality over disk"
decision ranks Bluray-1080p *above* Remux). Tier 9 enforces this: `_remux_below_cutoff_profiles`
detects profiles whose cutoff ranks Bluray-1080p above Remux, and Tier 9 replaces those
Remux with the best Bluray-1080p (qBit-first, else force-grab). The dedicated Remux profile
(id 8) keeps its Remux untouched.

---

## Pacing — why it's deliberately slow

The upgrade backlog is large (thousands of Tier 9 candidates) and the **import copy is the
bottleneck** (cross-NAS, ~12 GB each). Running too fast piles up downloads faster than Radarr
can import them.

| Knob | Value | Notes |
|------|-------|-------|
| `UPGRADERR_SEARCHES_PER_HOUR` | **2** | per-instance searches per 30-min sweep |
| `UPGRADERR_DOWNLOADS_PER_DAY` | **3** | global cap per sweep (shared across all instances) |
| `until_score` (radarr-hd profiles 7 & 8) | **5600** | in `recyclarr.yml`; lets upgrades climb to the best releases (HiDt ≈ 5450) instead of capping |

> The global download cap is shared across radarr-hd **and** sonarr-hd, so TV upgrades draw
> from the same slow, safe budget — adding TV cannot overload Radarr.

**History:** `.env` was accidentally left at `20/40` (an un-reverted July drain bump), which
overwhelmed the slow import path. Reverted to `2/3` on 2026-08-15.

---

## Monitoring

- **Upgraderr dashboard** (`http://mother:9706`): the tier grid now includes Tier 9
  "Release-Group Quality"; the queue filter goes 1–9.
- **Progress**: `SELECT priority_tier, status, COUNT(*) FROM upgrade_queue GROUP BY 1,2`.
- **Radarr queue** should stay small (imports keeping up). A growing queue means the pace is
  too high for the cross-NAS import throughput.
- Tier 9 force-grabs log as `Tier 9 force-grab <title>: <group> CF=<score> [<quality>]`.

---

## Known-good vs known-bad, restated

- **Kept:** files already from a TRaSH Tier-1 group for their source; any Remux on the
  dedicated Remux profile (8); Remux where no Bluray-1080p encode exists.
- **Upgraded:** Tier-2/3/unknown/scene groups; known-bad groups (BHDStudio); Remux on a
  profile that prefers an encode.
- **Never imported:** scene/BHDStudio/mp4 copies from qBit (quality-filtered out).

See also: [TRaSH Scoring Reference](TRASHGUIDES_REFERENCE.md), [Quality Profiles](QUALITY_PROFILES.md),
[Operations Guide](OPERATIONS.md).
