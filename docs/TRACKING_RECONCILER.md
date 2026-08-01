# Tracking Reconciler — Design Doc

Status: **DRAFT / staged rollout** (created 2026-08-01)
Owner: Ali + Claude
Related: `CLAUDE.md` (Profile Authority, Dedup Safety Controls, Sync Strategy), the
2026-07/08 incident cluster (found-status freeze, orphaned jobs, datetime bug, Steamboy/Sleuth).

## 1. Problem statement

Every safety system in the stack is built on one of two assumptions, and the gap is the
space between them:

- **"Trust what Radarr/Sonarr tracks"** — Profile Authority (reconcile + dedup) faithfully
  propagates and *protects* the tracked file, even when it is objectively wrong.
- **"Re-download if it's wrong"** — Upgraderr triggers indexer searches (Tiers 3/7), which
  fail for obscure/old titles and had the found-status freeze bug (fixed 2026-07-25).

**Neither ever asks: "we physically have a better, profile-allowed copy right here — on
Unraid, or as a Synology duplicate — why not adopt it instead of re-downloading?"**

That is the exact hole **Steamboy (2004)** fell through: Radarr tracked a `Bluray-720p`
(a file profile 7 doesn't even allow), Synology held *only* that 720p, Upgraderr couldn't
find a download, and dedup was about to delete the 31 GB `Remux-1080p` + `Bluray-1080p` that
were sitting on Unraid — to *preserve the 720p bug*. Sleuth (2007) was the same shape.

### What already exists (and its blind spot)

| Component | Does for "correct tracking" | Blind spot |
|---|---|---|
| Curatorr Sync Status → "Radarr Out of Date" (`radarr_behind` in `sync_status.py`) | Flags when Radarr's tracked file scores lower than the best file **in the Synology folder** | Passive (UI note only) + only sees Synology-folder copies. For Steamboy, Synology had only the 720p, so it read "not behind" — never knew about the Unraid Bluray. **Misses exactly the class that bit us.** |
| `reconcile_movie_versions` (sync-webhook) | Scans Synology folder for best-scored file | Uses it only to detect "already in sync"; always defers to the tracked file. Never adopts a better one. |
| Upgraderr Tiers 3/7 | Detect 720p / profile-mismatch, trigger a **download** | Download-based; can't use a copy we already have; unreliable for old titles. |
| Dedup (Profile Authority + known-bad/multipart guards) | Keeps the tracked file, protects known-bad/multipart | Keeps whatever's tracked — so a *bad* tracked file is preserved and the good copies deleted. |

## 2. The parity insight (why this isn't solved by "just make Unraid == Synology")

Perfect parity would **not** prevent this — it would have made Steamboy **unrecoverable**.

- The dedup *dilemma* (delete good Remux to keep bad 720p) is a symptom of non-parity — extra
  Unraid copies Synology lacks.
- But the *root bug* (Radarr tracking a profile-forbidden 720p) is entirely Synology/Radarr-side
  and independent of parity.
- **The "extra" Unraid copies that create the dilemma are the same copies that let us fix
  Steamboy at all.** They survived only because dedup hadn't yet enforced parity.

If Unraid had been in continuous aggressive parity, the moment Radarr downgraded to the 720p,
parity-enforcement would have deleted the good Unraid copies to match — leaving the 720p as the
*only* copy anywhere, permanently. The temporary non-parity is accidentally acting as a
**recovery buffer**.

**Design consequence (the ordering invariant):** the reconciler must run **before**
dedup/parity-enforcement each night, using the temporary non-parity as its recovery pool —
adopt the best copy *while it still physically exists somewhere*, then let parity converge on
the correct file. **The reconciler is what makes aggressive parity safe to pursue.**

## 3. The Tracking Reconciler

A nightly job (in `sync-webhook`, scheduled **before** the 8:00 AM ET dedup) that, per title:

1. **Gather the candidate pool** = union of all physical video copies:
   - Synology folder scan (`os.scandir` on the NFS mount) — fast, local.
   - Unraid Agent inventory (`GET /inventory` — never CIFS bulk listing, per CLAUDE.md).
2. **Fetch tracking + profile**: Radarr/Sonarr API for the currently-tracked file and the
   assigned quality profile's `allowed` quality list.
3. **Compute the target** = the highest-scoring copy in the pool **that the assigned profile
   allows** (shared TRaSH scoring in `configs/scoring/trash_scoring.json`). A Remux is *not*
   the target on a Bluray-only profile — profile-allowed is a hard filter, matching Profile
   Authority. This deliberately will NOT chase a higher raw score outside the allowed list.
4. **Decide**:
   - Tracked file **is** the target → nothing to do.
   - Target is a **Synology copy Radarr hasn't adopted** (a duplicate in the folder) →
     trigger Radarr `RescanMovie` / `ManualImport` to adopt it (free, instant, no transfer).
   - Target is **Unraid-only** → reverse-sync it to Synology, then `ManualImport` (exactly the
     manual Steamboy/Sleuth fix, automated).
   - **No profile-allowed copy anywhere beats the tracked file** (only a non-allowed Remux, or
     nothing better) → leave to Upgraderr's download search (today's behavior); record so
     nothing churns.

### Ordering (the whole point)

```
nightly:  Tracking Reconciler  →  (tracking now correct)  →  Dedup / parity-enforcement
```

Dedup only ever deletes *after* tracking is verified-correct, so a good copy can never again be
deleted to preserve a bad tracked file. This closes the Steamboy class permanently.

## 4. Safety rails (non-negotiable, given the June 2026 11 TB incident)

- **Adopt-only. The reconciler NEVER deletes.** Dedup remains the sole deleter; it just runs
  second, now safely. Adding another autonomous deleter is precisely what caused June.
- **Profile-allowed is a hard filter** — never adopts a file the assigned profile disallows
  (no Remux-onto-Bluray-profile churn). Fully consistent with Profile Authority.
- **Every adoption alerts to Telegram** (routed to the same chat as dedup) with before/after.
- **Rate-limited per run** (`RECONCILE_MAX_ADOPTIONS_PER_RUN`, small default) — a scoring bug
  can't cause a mass re-shuffle in one night.
- **Reverse-sync verifies the new file landed at full size before the ManualImport**, and the
  old tracked file is only replaced via Radarr's own import (never a raw delete).
- **Fails closed**: any Radarr/Sonarr API or Agent error for a title → skip that title, log,
  continue; never guess.
- **Staged rollout** (see §7): dry-run → flag-only → act.

## 5. How this answers the two original ideas

- *"Nightly analysis + compare with Radarr so no good file is deleted"* → this job, run before
  dedup. Exactly it.
- *"Better Upgraderr logic to get the best copy"* → the real win isn't smarter downloading (an
  indexer may not have the release); it's **adopt the copy we already have before spending
  bandwidth re-downloading.** The reconciler does that; Upgraderr stays the fallback for when
  no acceptable copy exists anywhere.

## 6. Stuck-state alerting (parallel, high-ROI, low-risk)

The week's incidents share a pattern: safety checks that **defer/skip silently** rather than
**alert loudly** (dedup deferred 5–11+ days, found-status frozen 24 days, orphaned jobs 5
days). Add escalation to Telegram when:

- Dedup reports `deferred`/`blocked` **N days in a row** (from `dedup_status.json` history).
- Any sync job sits `pending` **> X hours** (complements the orphan-recovery job).
- The **same** missing episode/movie appears in **N consecutive** nightly reports.
- The Tracking Reconciler flags the **same title unadopted N runs running** (can't self-heal).

## 7. Staged rollout

1. **Dry-run / flag-only** (`RECONCILE_MODE=flag`, default): compute + report what it *would*
   adopt across the whole library. **No writes, no imports, no reverse-syncs.** Review the list.
2. **Act, rate-limited** (`RECONCILE_MODE=act`, small `RECONCILE_MAX_ADOPTIONS_PER_RUN`): enable
   real adoptions for a few nights, watch the Telegram alerts, verify outcomes.
3. **Steady state**: raise the per-run cap once trusted; keep it running before dedup nightly.

Env vars (wired through `docker-compose.yml`, like the `DEDUP_*` set):
`RECONCILE_MODE=flag|act`, `RECONCILE_MAX_ADOPTIONS_PER_RUN`, `RECONCILE_SCHEDULE` (default
07:00 AM ET, before dedup).

## 8. Open questions / future

- Sonarr/TV: same logic per `(series, S##E##)`; heavier (per-episode API) — phase 2 after movies
  prove out.
- Should a successful adoption also proactively clear the corresponding Upgraderr queue row
  (so Upgraderr stops re-searching a title we just fixed from an existing copy)? Likely yes.
- Interaction with the "absolute parity" policy: once tracking is reliably correct, aggressive
  Unraid dedup becomes safe — the reconciler is the precondition that unlocks it.
