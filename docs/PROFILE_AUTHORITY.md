# Profile Authority

**Last updated**: 2026-08-18

The single most important cross-cutting rule in the system. If you touch **any** quality,
scoring, dedup, or reconcile logic, understand this first.

---

## The rule

> **Radarr/Sonarr's *assigned quality profile* — not a raw TRaSH/score comparison — is the
> authority for what quality a title should be.** The file Radarr/Sonarr currently tracks is
> correct *by definition*; a higher-scored file somewhere else is the anomaly to fix, not a
> reason to keep divergence.

A concrete example: Unraid holds a **Remux** while Radarr tracks a **Bluray-1080p** (because
that's the assigned profile). The Remux objectively scores higher. **Radarr's Bluray-1080p
still wins** — reconcile pushes it to Unraid and the Remux is replaced. The profile assignment
is a deliberate curation decision (does this title warrant Remux fidelity, or is a
space-efficient encode enough), and a higher raw score never overrides it.

---

## Where it applies

| Layer | Behaviour |
|-------|-----------|
| **Movie version reconcile** (sync-webhook) | Radarr's tracked file is synced to Unraid regardless of raw score delta — **no score gate** on the Syn→Unraid direction. |
| **TV version reconcile** | Score picks *direction* only when both sides are genuinely cross-tier-ambiguous; the tracked file otherwise wins. |
| **Dedup** (sync-webhook nightly + Curatorr) | Always keep whatever Radarr/Sonarr currently tracks; never delete the tracked file even if an orphan scores higher. |
| **Upgraderr Tier 7** | Fires when a file's quality isn't in the profile's *allowed* list — even if the current file is objectively "better." A Remux in a Bluray-only profile is wrong and gets replaced. |
| **Curatorr** (scoring, sync-status, dedup) | Same principle in the read/analysis layer. |

---

## Why this exists — the reasoning trap

This rule was written *after* it was violated, more than once. The tempting mistake:

> "But Unraid's file scores higher, so keeping it there is safer."

That reasoning is **backwards** and has caused real incidents — including reconcile jobs that
restored old Remuxes over legitimate profile-compliant upgrades, deleting the exact files
Upgraderr had just correctly grabbed. **If you ever find yourself writing "keep the
higher-scored file" logic, stop** and re-read this page.

An unexpected Remux sitting on a Bluray-only profile is almost always a legacy leftover from
before profiles were rigorously assigned — the profile is what's correct, not the file.

---

## Orthogonal: release quality control

Profile Authority governs the **resolution/source tier** (Remux vs Bluray vs WEB-DL). It does
**not** mean "accept whatever release satisfies the profile." A release can be independently
unacceptable regardless of tier:

- **Known-bad release groups** (e.g. BHDStudio) — blocked by recyclarr custom formats,
  Upgraderr's bad-group check, *and* the dedup known-bad guard.
- **Bad containers** (MP4 can't hold lossless audio) — blocked the same three ways.

These are enforced **in addition to** Profile Authority, not instead of it.

---

## Nuance: profile 7 now allows Remux (2026-08-01)

The "HD Bluray + WEB" profile (id 7) was changed to **allow** Remux-1080p, ranked *below*
Bluray-1080p (the preferred cutoff). So a Remux on profile 7 is a valid keepable quality — but
because Bluray-1080p is still ranked higher, Upgraderr's Tier 9 will replace it with a good
Bluray-1080p encode when one exists (and keep the Remux otherwise). This is Profile Authority
working exactly as intended: the profile's *ranking* decides, not the raw source score. See
[Quality Upgrades](QUALITY_UPGRADES.md).
