# TRaSH Guides Scoring Reference — Project Mother

**Last Updated:** 2026-06-27

All scoring constants live in one place:

```
configs/scoring/trash_scoring.json
```

This file is the **single source of truth** for quality scoring across all three services.
Edit it once — restart the containers — all services apply the new values immediately.

---

## How It Works

Three services score filenames:

| Service | Function | Used For |
|---|---|---|
| `sync-webhook` | `_score_filename(fname, size_bytes)` | Version reconcile: which copy wins? |
| `curatorr/duplicates.py` | `_score_plex_version(v)` | Duplicate scan: which copy to keep? |
| `curatorr/sync_status.py` | `_score(fname, size_bytes)` | Sync Status UI: Synology vs Unraid comparison |

All three load `/app/scoring/trash_scoring.json` on startup via docker-compose volume mount:

```yaml
- /opt/mother/configs/scoring/trash_scoring.json:/app/scoring/trash_scoring.json:ro
```

---

## Scoring Constants

### Resolution

| Tag detected in filename | Score | Notes |
|---|---|---|
| `\b2160p\b` | **4000** | Checked first — catches `[Remux-2160p]` before edition labels |
| `\b1080p\b` | **2000** | |
| `\b720p\b` | **0** | Intentionally 0 — always upgrade target |
| `\b(4k\|uhd)\b` | **4000** | Fallback for edition labels without explicit pixel count |
| SD / unrecognized | **−500** | |

> **Critical**: `2160p` and `1080p` are matched before the generic `4k|uhd` pattern.
> This prevents `[4K Remaster][Remux-1080p]` edition labels from being misclassified as 4K.

### Source

| Tag | Score |
|---|---|
| remux | **2000** |
| bluray / blu-ray / bdrip / bdremux | **1500** |
| web-dl / webdl | **1000** |
| webrip | **800** |
| hdtv | **200** |

### HDR — 4K content

Ordered list — first match wins:

| Format | Score | Notes |
|---|---|---|
| DV HDR10+ | 800 | Best: broadest compatibility + max HDR |
| DV HDR10 | 800 | DV with HDR10 fallback |
| HDR10 | 700 | Universal standard |
| HDR | 700 | |
| DV HLG | 400 | |
| DV SDR | 300 | |
| Dolby Vision | 400 | |
| DV | 400 | |
| HDR10+ | 300 | Samsung-only, limited compatibility |
| HLG | 300 | Broadcast format |

### HDR — HD (1080p) content

| Format | Score |
|---|---|
| DV HDR10+ | 400 |
| DV HDR10 | 400 |
| HDR10 | 400 |
| HDR | 400 |
| HDR10+ | 350 |
| DV HLG | 350 |
| Dolby Vision | 350 |
| DV | 350 |
| DV SDR | 300 |
| HLG | 300 |

### Audio — first match wins

| Format | Score |
|---|---|
| TrueHD Atmos | **500** |
| Atmos (generic) | **500** |
| TrueHD | 450 |
| DTS-HD MA | 400 |
| DTS:X | 400 |
| DTS-HD | 350 |
| EAC3 Atmos | 300 |
| DTS | 200 |
| EAC3 / DD+ | 150 |
| AC3 | 100 |
| AAC | 50 |

### HEVC Penalty

`−300` when filename contains `x265 / h265 / hevc / x.265` AND resolution is HD (not 4K) AND no HDR detected.
DV or HDR at 1080p with x265 is fine — that's the legitimate reason to use x265 at 1080p.

### Size Bonus

`+10 per GB`, capped at `+200`. Breaks ties between files with identical format tags (larger = less compressed).

### Container Penalty

`−100` for `.mp4` container. MP4 cannot carry lossless audio (TrueHD, DTS-HD MA).

### Custom Format Bonuses

| Format | Score | How Detected |
|---|---|---|
| `[Hybrid]` | **+100** | `\[hybrid\]` in filename |
| Release group | **+50** | `-GROUP.ext` suffix (e.g. `-FraMeSToR.mkv`, `-FLUX.mkv`) |
| Proper / Repack | **+25** | `\b(proper\|repack\|rerip)\b` in filename |

---

## Tuning Scores

```bash
# 1. Edit the constants
nano /opt/mother/configs/scoring/trash_scoring.json

# 2. Restart both consumers
docker compose restart sync-webhook curatorr
```

No code changes needed — the JSON is the only thing to edit.

---

## Version Reconcile: Profile Authority, Not a Score Gate

**Corrected 2026-07-02 — this section previously described a removed behavior.** See
CLAUDE.md's "Profile Authority" section for the full rule.

- **Movie version reconcile** (11:45 PM ET): Radarr's tracked file is the target,
  full stop — `MovieVersionSync` (Synology→Unraid) fires whenever Radarr's file
  differs from Unraid's, **even if Unraid's current file scores higher** (e.g. Unraid
  holds a Remux, Radarr tracks Bluray-1080p because that's the assigned profile).
  There is no "only sync if Synology scores higher" gate — that was removed.
- **TV version reconcile** (11:15 PM ET): score is used to pick a *direction* only
  when both sides are genuinely cross-tier-ambiguous; the 720p exclusion applies both
  ways regardless of score.

The `VERSION_SYNC_MAX_PER_RUN` cap (default 100) limits nightly churn.

**Known gap (not yet fixed, flagged 2026-07-02):** `_score_filename()` uses the same
source ranking (Bluray=1500 > WEB-DL=1000) for both movies and TV. `scripts/lib/quality_scoring.py`
(used by Upgraderr and the compare_*.py scripts) intentionally inverts this for TV
(WEB-DL=1200 > Bluray=1000 > WEBRip=800), per this project's established convention
that WEB-DL is generally preferred for episodic TV. `reconcile_tv_versions()` doesn't
apply that inversion — it could pick the wrong side in a Bluray-vs-WEB-DL TV episode
comparison. Not fixed pending confirmation this matters in practice (most TV episode
comparisons aren't cross-tier).

---

## Recyclarr Quality Profiles

Recyclarr syncs TRaSH Guides quality profiles to all 4 *arr instances via `configs/recyclarr/recyclarr.yml`.
Recyclarr profiles govern what Radarr/Sonarr will *auto-search for* — separate from the in-house scoring
above which determines which *existing file* wins in a version comparison.

| Instance | Profile | Key Rule |
|---|---|---|
| Radarr HD | SQP-1 (1080p) | Blocks x265 without HDR/DV |
| Radarr 4K | SQP-1 (2160p) | Allows DV/HDR10 x265 |
| Sonarr HD | WEB-1080p | WEB-DL preferred over BluRay for TV |
| Sonarr 4K | WEB-2160p | 4K WEB-DL / Remux |
