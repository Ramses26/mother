# Weekly Review — started 2026-07-19, revisit 2026-07-24/25

Baseline snapshot from a long working session on 2026-07-19. Revisit this file Friday/Saturday
(2026-07-24 or 2026-07-25) to check progress against each item below.

## 1. Dedup — waiting on the scheduled run to confirm

**Decision**: explicitly left the small remaining backlog for the normal **8:00 AM ET scheduled run**
instead of running it manually, specifically to confirm the automated path works correctly end-to-end
on its own.

- Backlog at time of writing: **17 items, ~82GB**, confirmed via `DEDUP_DRY_RUN` — all 17 cross-checked
  against real `upgrade_history` entries from the same day (Riders of Justice, Purple Rain, Summer of
  84, Legend of the Lost, The Last Kumite) and matched exactly. Nothing questionable in the list.
- Safety limits confirmed at steady state: `DEDUP_SAFETY_LIMIT=200`, `DEDUP_MAX_PER_RUN=50` (reverted
  down from the temporary 3500/3200 used to drain the big backlog earlier in the week).
- No `PAUSE_DEDUP` or `PAUSE_VERSION_SYNC` sentinels present.
- **To check Friday/Saturday**:
  - `cat /opt/mother/configs/sync-webhook/data/dedup_status.json` — should show `"outcome": "ran"` with
    a recent timestamp, ~17 deleted, ~82GB freed (or possibly more if new duplicates accumulated during
    the week).
  - Re-run a duplicate scan (`curl -s -G "http://192.168.1.10:8100/scan" --data-urlencode
    "refresh=true" -H "X-Api-Key: $UNRAID_AGENT_API_KEY"`) and confirm the actionable backlog (via a
    `DEDUP_DRY_RUN` pass through `nightly_unraid_dedup`, not the raw Agent group count — see the
    "known false-alarm" note below) stayed low, not climbing back up.
  - **Known false-alarm to avoid re-triggering**: the raw Unraid Agent `/scan` and Curatorr's duplicate
    UI report a much larger "group" count (183 movies + 23 TV as of 2026-07-19) than what's actually
    actionable. Most of those groups are legitimately protected (known-bad-release guards, multi-part
    guards, editions). Don't panic at that raw number — always verify against a `DEDUP_DRY_RUN` pass
    before assuming there's a real problem.

## 2. Upgrade → delete flow — confirmed working, verify it's still holding

Confirmed end-to-end this session: Radarr/Sonarr delete the old file from Synology automatically at
import time (to their recycle bins); sync-webhook copies the new file to Unraid but never deletes
(`MovieFileDelete`/`EpisodeFileDelete` webhooks intentionally ignored — append-only by design since the
June 2026 incident); the nightly nightly dedup run is what cleans up the old Unraid copy. Verified with
5 concrete real examples from `upgrade_history` all appearing in the dedup dry-run's "would delete" list.

**To check Friday/Saturday**: pick 2-3 titles from `upgrade_history` (`docker exec upgraderr python3 -c
"..."` against `/data/upgraderr.db`) that upgraded earlier in the week and confirm their *old* file is
now gone from Unraid (proving dedup caught up on them across the week, not just today's batch).

## 3. Parity — HD good, 4K gap still open

Snapshot from `parity_check.py` (script lives in the session's scratchpad — ask to have it re-run, it's
not currently checked into the repo):

| Library | Tracked | OK | Missing | Stale |
|---|---|---|---|---|
| Radarr HD Movies | 7943 | 7934 (99.9%) | 1 | 8 |
| Radarr 4K Movies | 151 | 52 (34%) | 25 | 74 |
| Sonarr HD TV (episodes) | 65,136 | 63,648 (97.7%) | 0 | 1,488 |
| Sonarr 4K TV (episodes) | 105 | 60 (57%) | 0 | 45 |

- **HD is in very good shape.** The 1,488 HD TV "stale" entries (file exists but not the current exact
  filename) are expected to self-heal via the nightly TV version-reconcile job — capped at
  `VERSION_SYNC_MAX_PER_RUN=500`/run, so could take ~3 nights to fully clear from this snapshot alone.
- **4K gap is real and still untouched** — 25 movies + TV stale entries reflect genuinely missing/
  outdated 4K content on Unraid. This was explicitly deferred by Ali earlier in the week, not started.

**To check Friday/Saturday**: re-run the parity check, compare HD stale counts (should trend toward 0)
and decide whether to finally tackle the 4K gap.

## 4. Other fixes shipped this week (verify they held)

- **qbittorrentstack migrated to real docker-compose** (`/volume1/docker/qbittorrentstack/`, project
  `mother-dlstack`) — check all 6 containers are still up (`ssh synology-dl "sudo /usr/local/bin/docker
  ps"`), no recurrence of the stale-lockfile crash-loop.
- **qbitmanage "Not Found" matching fix** — check the 235-torrent backlog (mostly TorrentLeech) is
  actually draining now (`rem_unregistered` logs should show real removals, not "No unregistered
  torrents found" every run).
- **Upgraderr Dragon Ball Z alert fix** — confirm no more repeat Telegram spam for already-tagged
  `upgraderr-skip` titles.
- **Log retention standardized to 7 files** across upgraderr/curatorr/sync-webhook — spot check file
  counts haven't crept back up.
- **Silo S03E03 Kitsune recovery** — confirmed complete both sides (Synology + Unraid), DUDU removed.

## 5. Still open / not started

- **4K parity gap** (see above) — deferred, needs a real decision on priority.
- **X-Men '97 S01E08** — flagged, not investigated. History shows 3 release swaps across 3 days
  including an odd score downgrade. Worth a Silo-style history deep-dive if it recurs.
- **Grey's Anatomy S13/S16/S17** (tier3_720p) — left to Upgraderr's own cooldown/retry cycle, not
  manually intervened. S16E13 specifically has a badly-scored (-9900) tracked file; check if Upgraderr's
  retry actually landed something better by Friday.
- **Infinity Saga restore** (Marvel's Infinity Saga - The Sacred Timeline Cut, 5 parts) — still running
  as of this writing, PART 2/5 at 57%, crawling at 8-11MB/s due to VPN bandwidth contention with other
  syncs. At this rate PART 2 alone has hours left, plus 3 more parts after it — this will very likely
  still be running or only just finishing by Friday/Saturday. The sequenced follow-up restore (11
  known-bad-release movies, Unraid→Synology) is waiting on it and hasn't started yet. Check
  `/tmp/claude-1000/-opt-mother/d10b182d-a308-46e1-ab2d-818f3367c16f/scratchpad/infinity_saga_restore.log`
  for `ALL_PARTS_DONE`, and `sequenced_restore.log`/`restore_known_bad.log` for the follow-up — note
  these live in a session-scoped scratchpad directory, not the repo, so they may not survive if that
  session's temp space gets cleaned up; if the restore is still needed by Friday, worth moving the
  in-progress tracking to a more durable location.
