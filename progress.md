# Project Mother — working state

**Last updated: 2026-09-02** · Everything through commit `411e230` is committed and pushed.

This file is the "where are we" scratchpad for continuing work. Durable architecture and
rules live in `CLAUDE.md`; the open-items backlog lives in `docs/PROJECT_TODO.md`. This is
the short-lived layer on top: what just happened, what is mid-flight, what is waiting on Ali.

---

## 1. Waiting on Ali (nothing else is blocked by these, but both are real risk)

| # | Action | Why it matters |
|---|---|---|
| 🔴 1 | **Copy the restic repo password off-box.** `grep BACKREST_RESTIC_REPO_PASSWORD /opt/mother/.env` → password manager. | Its only off-box copy is *inside the backup it encrypts*. If Mother dies first, every backup is permanently unreadable. |
| ⚠️ 2 | **Set a Backrest UI password** at `http://mother:9898` → Settings. | No auth today, and the page shows the repo password in plaintext to anyone on the LAN. |

---

## 2. Current state

- **30/30 containers up.** Root disk 55% (76G/145G).
- **Backups exist and are verified** — first successful snapshot `3f5ab864` (2026-09-01).
  Backrest plan `mother-full`, nightly 04:00, repo `synology` = restic REST server on the
  download Synology `10.0.1.203:8500` → `/volume1/PlexBackup/mother-restic/`.
  Freshness checked by `scripts/backup_freshness_check.py` (cron 09:00) rather than a Loki
  alert, because a backup system that fails by *doing nothing* emits no error lines — which
  is exactly how it went unnoticed for 5 months.
- **Host state outside `/opt/mother`** (crontab, fstab, SSH keys, systemd units) captured by
  `scripts/snapshot_host_state.sh` into `data/host-state/` (gitignored — holds private keys)
  so it rides inside the same encrypted backup.
- **Upgraderr queue janitor is in Phase 1 / report-only.** It mutates nothing.
- **Agent bridge is live** — `authorized_tg_users=1`, reply-to-alert loop verified end to end.
- **decluttarr is gone** (removed 2026-09-01). Queue cleanup is manual until janitor Phase 2.

---

## 3. Dated checkpoints

| Date | What |
|---|---|
| **2026-09-08** | Tune alert thresholds from a week of real firing data. `plex_unreachable` is already a known false-positive generator — see §4. |
| **2026-09-15** | Queue janitor **Phase 2 gate**. Enable `already_imported` *only*. Everything else stays report-only. |

---

## 4. DONE 2026-09-02 — Plex backup rebuilt on both servers

**Nostromo's backup was stopping Plex for 75 minutes every night** (root cron `15 5 * * *`,
gzipping 110 GB of app-support with the service down: stopped 05:15:03, started 06:30:40).
That, not any Plex fault, is what fired `plex_unreachable` daily — the alert expression peaks
at 591 against a `>200`/30m threshold. Tautulli and Tracearr never backfill, so ~75 min of
watch history was permanently lost each night.

**The waste:** of 142 GB, the only irreplaceable data is `Plug-in Support/Databases`, and only
**4.25 GB of that is live** — the rest is Plex's own dated rolling copies. Metadata (67 G),
Cache (32 G) and Media/localhost (24 G) are all regenerable. Plex was being taken down for 75
minutes to protect 4.25 GB.

**Fix — two tiers.** Nightly: stop Plex, copy only the live DBs, restart Plex, *then* compress
with Plex already up. Weekly (Sun): full artwork tar taken **hot**, Plex never stops. Plus
`zstd -T0`, pre-flight checks that abort *before* touching Plex, integrity verification, and
retention.

**Verified live on Nostromo, 0 active streams:**
```
Plex restarted. Downtime was 22s.
Database backup complete. Size=3.0G Downtime=22s.
```
22 s against 75m37s. Plex `active` after, all 6 libraries responding, `NRestarts: 0`.
Restore-tested: archive extracts byte-exact, both DBs pass `PRAGMA integrity_check` = ok
(**under Plex's own SQLite binary** — the system `sqlite3` fails with `no such collation
sequence: icu_root`, which is Plex's ICU collation, NOT corruption), 144,150 metadata_items
and 123,410 watch-history rows readable.

Cron moved 05:15 → **03:30** (clears Synology Active Backup at 05:00/06:00). Stray inert
`/etc/cron.d/plexbackup.sh` retired to `/root`.

**Retention, deliberately asymmetric:** 30 nightly DB (~94 GB) + 2 weekly full (~164 GB) =
~258 GB per server, against ~1.4 TB with no pruning on *each* host before. The DB is the
irreplaceable data and is cheap, so buy a month of it; the weekly full is 25× bigger and only
protects regenerable artwork.

Scripts: `remote-hosts/{nostromo,hathor}/plexbackup.sh`.

### Hathor — deployed, one thing left for Ali

Script deployed and md5-verified; Ali cleared the ESTALE mount (the Unraid export had been
fixed 2026-08-28 but the client mount still held the pre-fix handle). Alloy on Hathor is a
**container**, not a systemd service as on Nostromo — config at `~/hathor/alloy/config.alloy`,
**no sudo needed**. Added the plexbackup tail there plus the `/var/log:ro` bind mount its
compose was missing (without it the container cannot see the file and the tail silently
matches nothing). Both mirrored into `remote-hosts/hathor/`.

**Done.** Cron confirmed nightly by Ali: `30 3 * * * /home/alig/plexbackup.sh`. First run
executed manually 2026-09-02 10:18 — **22s downtime, 3.1 GB** — and confirmed arriving in
Terminus's Loki. That was the first Hathor Plex backup since **2026-03-12**, 5.5 months.

### Alerting — Loki, not a notification credential

Rather than put a Telegram bot token on Chris's server, the backup alerts ride existing log
shipping. Nostromo's native Alloy already ships to Mother's Loki; added a
`/var/log/plexbackup.log` tail (`service="plexbackup"`, verified arriving) and two Grafana
rules — `plex_backup_failed` (ABORT/FAILED/integrity in 6h) and `plex_backup_stale` (no
completion in 36h, **`noDataState: Alerting`** on purpose: silence *is* the symptom, and that
is exactly how Hathor failed unnoticed for 5 months). 17 rules total, provisioned clean.

Hathor's equivalent ships to **Terminus's** Loki — asked Terminus's Claude to add the matching
rules there (see §4c).

---

## 4b. REMOVED 2026-09-02 — Mother's Apprise container

Found while verifying the backup script's failure alerts would arrive: **the container had
never delivered a single notification.** `apprise.yml` held literal `${TELEGRAM_BOT_TOKEN}`
placeholders and **Apprise does not expand environment variables in its YAML config** — every
URL logged `Unparseable Telegram URL`, and every POST was answered **HTTP 204 while delivering
nothing**. 204 is also the success code, which is why it hid for months.

Fixed it first (git-tracked template + a render step + an `apprise-init` container), then
established nothing wants it, and removed it at Ali's direction. 31 → 29 services.

**Why nothing broke:** Grafana, `container_watchdog.py` and `agent_bridge.py` post to
`api.telegram.org` **direct**; `sync-webhook`, `upgraderr` and `curatorr` use the **apprise
python library in-process** (keep it — unrelated to the container); `daily_report.py` and the
host shell scripts post to **Terminus's** Apprise (`192.168.1.14:8000`), which works and
returns **200**. That 200-vs-204 difference matters: `send_apprise()` checks `status == 200`,
so it succeeded against Terminus and always read as failure against Mother.

**Terminus's Apprise is fine and was left alone.** An earlier read of it as "broken" was wrong
— its `/config/apprise.yml` is a 0-byte reference file with the real config in the API store;
a live POST returns 200 and `Sent Telegram notification.`

Host-level alerting is Loki + Grafana instead. `nostromo/plexbackup.sh`'s `notify()` is now a
documented no-op; all 8 failure paths still write a logmsg the Grafana rules match.
**Do not re-add a notification-hub container without first checking whether a Grafana rule
over shipped logs covers the need.**

Side effect worth knowing: the one-shot `apprise-init` container tripped
`mother_container_down`, because that rule used `min by (name) (docker_container_up)` with no
concept of a container that is *supposed* to exit. Now excludes `.*-init`.
`container_watchdog.py` had it right already — it only watches `always`/`unless-stopped`.

---

## 4c. Cross-session coordination with Terminus

The two Claude sessions **can** message each other — `ListAgents` shows Terminus's session over
Remote Control, and `SendMessage` reaches it by name (`terminus-rustling-octopus`). Sent it a
request covering: the two `{service="plexbackup"}` alert rules for Hathor, the Apprise root
cause and fix, and whether `{host="hathor"}` is arriving in Terminus's Loki. Awaiting reply.

## 4d. ⚠️ Sunday 2026-09-06 — a large automatic deletion will happen

The weekly full backup runs on both hosts and then prunes `buplex-*.tar.*` to `retainFull=2`.
The **old** backups match that same glob, so they are in scope:

| Host | Matching files today | Size | After Sunday |
|---|---|---|---|
| Nostromo `/mnt/PLEX` | 14 | **1.4 TB** | 2 (new + newest old) |
| Hathor `/mnt/plexbackup` | 9 | **1.3 TB** | 2 |

≈ **2.4 TB freed**, which is almost certainly wanted (Unraid is at 92%), but it is a big
irreversible delete and should not be a surprise. Hathor's are Jan–Mar 2026; Nostromo's are
August. After Sunday each host holds 2 full + 30 nightly DB archives.

**If more history is wanted, raise `retainFull` in both scripts before Sunday.**

---

## 4e. Alert cadence — Mother now mirrors Terminus

`policies.yaml` used a blanket `repeat_interval: 4h` for every `team: infra` rule. Ali's
standing rule (he has already missed a real alert because of a 4h repeat): long intervals are
for the chronic/advisory class **only**.

| Class | Repeat | Rules |
|---|---|---|
| `advisory` | 24h | `mother_disk_space_low` |
| `noisy` | 12h | `arr_database_locked`, `qbitmanage_error_watchdog` |
| default | **10m** | the other 14 |

Routes are evaluated in order and first match wins, so the two specific routes **must** stay
above the catch-all.

---

## 4f. FIXED 2026-09-03 — Radarr's recycle bin was broken, blocking every movie import

Found during a routine morning health check: `radarr-hd` had logged **97,975**
`RecycleBinProvider` errors in 14h, starting **2026-08-31 22:00**.

**Cause:** three of the four *arr recycle-bin directories did not exist on the host.
`hd-movies`, `4kmovies` and `4ktv` had been deleted into Synology's `#recycle` on
2026-09-01 20:34 (`hd-tv` survived, which is why Sonarr-HD was unaffected). Two compounding
details:

1. The `.env` paths (`DELETED_MOVIES_PATH` etc.) pointed at the now-missing directories.
2. Recreating the directories was **not enough** — the containers held **stale bind mounts**
   to the deleted inodes, so `/deleted-movies` was still "No such file or directory" inside
   the container even once the host path was back. `docker restart` does not re-resolve a
   bind mount; the containers had to be **recreated** (`up -d --force-recreate`).

**Impact — no data loss.** Radarr throws `RecycleBinException` when it cannot create the
recycle folder, which **aborts the delete**, so the files survived (spot-checked four titles
from the error log: all still present with their video file). But the aborted delete blocked
the import that needed it, leaving **36 items stuck in `importBlocked`** on radarr-hd. That
is the real cost: movie imports had been silently failing for ~2.5 days.

**Fix:** recreated the three directories (mode 777, matching the working `hd-tv`), then
force-recreated `radarr-hd`, `radarr-4k`, `sonarr-4k`. Verified all four recycle bins
writable, last error 08:52:16 vs container recreate 08:52:41, and **zero** errors since. The
36 items moved `importBlocked` -> `importPending` immediately.

**Worth knowing: 17.6 TB is still sitting in Synology's `#recycle`** from that 2026-09-01
deletion (`hd-movies` 11 TB, `Movies` 6.3 TB, `4kmovies` 305 GB, `tvshows` 33 GB). Whoever
deleted those folders freed no space — DSM intercepted it. Volume is at 54% so it is not
urgent, but that space is recoverable by emptying `#recycle` on the download Synology.

**Lesson for next time:** an *arr silently failing every import looks like a download or
indexer problem. The signal was a specific, loud, repeating log line — 97,975 of them —
that nothing was watching. Same pattern as every other incident on this system. A Grafana
rule on `{service=~"radarr.*|sonarr.*"} |= "RecycleBinProvider"` would have caught this on
day one; consider adding it at the 2026-09-08 alert-tuning checkpoint.

---

## 5. Separately confirmed and already fixed — not today's cause

Nostromo Plex also crash-looped **602 times over 2.5 days** (Aug 30 → Sep 1 13:03),
`Failed with result 'watchdog'` / `status=6/ABRT` — systemd `WatchdogSec` killing Plex when
it missed keepalives, restarting every ~5m11s. Already diagnosed and fixed in commit
`9dbbc4b`; Plex has been stable since Sep 1 13:03. Noting it only so the restart counter in
`systemctl status` isn't re-investigated as a new problem.

---

## 6. Shelved / parked (deliberate, do not revive without asking)

- **Tier 10 — search for entirely missing movies/episodes.** Designed, then shelved
  2026-09-01 at Ali's direction: too much download volume and disk. Filter design is in
  `docs/PROJECT_TODO.md` §3b if revived. **Ali's preferred alternative is unmonitoring
  low-value shows in Sonarr directly** rather than building filters to work around them.
- **Release-group statistics UI** (Curatorr or Upgraderr) — parked, not started.
- **34 remaining `orphaned_data` entries** need a per-item library check before cleanup.

---

## 7. In flight

- **Doctor Who S19** — 12 episodes / 28.1 GB, 11 of 26 imported at last check.
  Recovered via per-episode search after the quarantined copy turned out to be a 0-byte
  `_unpackerred` shell. Just needs a completion check.

---

## 8. Reference — things that cost time, worth not rediscovering

- **The recurring lesson:** every incident in the 2026-09-01 session was *already being
  logged loudly for days* — 797 corruption errors, 193 auth failures, 407 NFS errors.
  Before building anything clever for a failure class, check whether the signal is already
  in Loki and just needs a rule.
- **Never `docker exec ... python3 -c` a reconcile/gap-scan** — the threads die with the
  exec'd process and leave orphaned `pending` rows that silently block dedup. Use the HTTP API.
- **Two Lokis, split by site.** A Gomaa-side host missing from Mother's Loki is *correct*.
  Check Terminus first.
- **Loki coverage checks need a ≥24 h window** — several containers are legitimately idle
  and look "missing" at 6 h.
