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

## 4. OPEN — Nostromo Plex backup takes Plex down 75 min every night

**Investigated 2026-09-02. Root cause fully confirmed. Fix written, NOT deployed —
Nostromo is Chris's server and the change stops Plex, so it needs his sign-off.**

The daily `plex_unreachable` alert is **not** a false positive and **not** a Plex fault. It
is a backup script stopping Plex for the entire duration of a 110 GB single-threaded gzip.

**Measured, 2026-09-02:**
```
05:15:01  CRON (root) /home/stutch/plexbackup.sh    # root crontab: 15 5 * * *
05:15:03  Plex STOPPED
          tar cz --exclude=./Cache -f /mnt/PLEX/buplex-....tar.gz .
06:30:40  Plex STARTED
          => 75m 37s of downtime, every single night
```
Alert replay over that window: crosses the `>200`/30m threshold at 05:25, peaks at **591**,
clears 06:55. (The "110 hits" in the resolved notification is just the trailing edge.)

**The waste is the striking part** — sizes measured on Nostromo:

| Path | Size | Backed up? | Replaceable? |
|---|---|---|---|
| `Plug-in Support/Databases` | 20 G | yes | **NO — the only irreplaceable data.** Main `library.db` is just **1.36 GB** |
| `Metadata` | 67 G | yes | yes (artwork; slow to refetch) |
| `Cache` | 32 G | excluded | yes |
| `Media/localhost` | 24 G | yes | yes (thumbnails/bundles) |

**Plex is taken down for 75 minutes nightly to protect 1.36 GB of data.**

Other problems found in the same script:
- **No retention at all** — 14 × ~105 GB = **1.4 TB** accumulated on the Synology.
- **No pre-flight checks** — it stops Plex *before* testing the destination. The identical
  script on Hathor ran silently broken from 2026-03-12 to 2026-08-28 for exactly this reason.
- **Schedule collides** with Synology Active Backup (`VM-vSphere-Task-2` 05:00 and
  `VM-vSphere-Task-3` 06:00, both daily) writing to the same NAS, plus Mother's own restic
  run at 04:00 into `/volume1/PlexBackup/mother-restic/`.
- Single-threaded `gzip` on a **16-core** box. `zstd` is installed and unused.
- `/etc/cron.d/plexbackup.sh` is a **stray copy of the script**, not a crontab entry. It is
  inert (cron ignores filenames containing a dot) but is misleading — delete it.

**Ali already solved this on his own box on 2026-08-28.** Hathor's
`plexbackup.sh.pre-2026-08-28.bak` is byte-for-byte the version Chris still runs. Ali's
current version adds pre-flight checks, extra excludes, `tar tzf` verification, retention 8,
Apprise notifications, and runs **weekly** rather than nightly.

**Proposed fix: `remote-hosts/nostromo/plexbackup.sh`** (written, syntax-checked, not deployed).
Ports Ali's improvements and adds a two-tier split:
- **Nightly** — stop Plex, `cp -a` the Databases dir locally, restart Plex, *then* compress
  with Plex already running. **Downtime ~30–60 s instead of 75 min.**
- **Weekly (Sun)** — full app-support tar taken **hot**, Plex never stops. Artwork is
  regenerable, so a slightly inconsistent copy is fine and beats refetching 67 GB.
- Plus `zstd -T0` (16 threads), retention 14 nightly / 4 weekly, integrity verification,
  Apprise alerts, and moved to **03:30** to clear both Active Backup windows.

**On the maintenance-window question (Ali asked 2026-09-02):** worth adding as a stopgap,
but it should not be the fix. Muting 05:15–06:45 would hide a genuine 75-minute nightly
outage during which Tautulli and Tracearr record nothing and **never backfill** — so the
data is permanently lost whether or not anyone is paged. Once downtime is ~60 s the alert
stops firing on its own with no mute needed. Recommended order: deploy the script first,
confirm one clean night, and only add a Grafana mute timing if the weekly full still trips it.

**Next step:** Ali to confirm before anything is deployed to Nostromo.

---

## 4b. TIME-SENSITIVE — Hathor's own Plex backup will fail tomorrow (2026-09-03 02:15)

Found while comparing Chris's script against Ali's. Two facts that only matter together:

1. **`/mnt/plexbackup` on Hathor is ESTALE.** The NFS4 mount to
   `unraid.gomaafam.net:/mnt/user/Home/Backups/Plex` is still *listed* in `mount`, but any
   access returns `Stale file handle` and `mountpoint -q` fails. Same failure class as the
   2026-08-30 Mother incident (`unraid_mount_estale_incident_2026_08_30`).
2. **The rewritten script has never run yet.** It was created Friday 2026-08-28 and is
   scheduled `15 2 * * 4` (Thursdays). No Thursday has occurred since. `/var/log/plexbackup.log`
   does not exist, which confirms zero runs. **First-ever scheduled run is 2026-09-03 02:15.**

So tomorrow's first run hits a stale mount. **The pre-flight check will do exactly what it was
written to do** — abort before touching Plex and send an Apprise failure notification, rather
than repeating the 5-month silent failure. That is the 2026-08-28 rewrite paying off on its
first outing. But the backup still will not happen.

**Action:** clear the stale mount on Hathor before 02:15 tomorrow —
`sudo umount -l /mnt/plexbackup && sudo mount /mnt/plexbackup`, then verify with
`ls /mnt/plexbackup`. Needs a password-bearing sudo session, so it has to be Ali.

Note: Hathor has **no passwordless sudo**, so `sudo -n crontab -l` returns nothing and looks
like an empty root crontab. That is a sudo failure, not evidence the cron entry is missing —
do not "fix" a missing schedule on that basis.

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
