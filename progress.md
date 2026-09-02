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

**Remaining:** root crontab still says `15 2 * * 4` (weekly). Needs Ali's sudo:
```bash
sudo crontab -l | sed 's|^15 2 \* \* 4 /home/alig/plexbackup.sh|30 3 * * * /home/alig/plexbackup.sh|' | sudo crontab -
```
Until then it runs correctly, just weekly. Last backup on Unraid is 2026-03-12, so tonight is
the first in 5.5 months.

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

## 4b. FIXED 2026-09-02 — Apprise had never delivered a single notification

Found while verifying the backup script's failure alerts would actually arrive. **Both**
Apprise instances were dead:

- `apprise.yml` held literal `${TELEGRAM_BOT_TOKEN}` / `${..._CHAT_ID}` placeholders, and
  **Apprise does not expand environment variables inside its YAML config.** Every URL logged
  `Unparseable Telegram URL`.
- Passing the vars into the container does **not** help — the expansion simply does not exist.
- Every POST was answered **HTTP 204 while delivering nothing**. 204 is also the success
  response, which is exactly why this hid for months.

**Nothing broke visibly** because nothing actually depends on the container: Grafana,
`container_watchdog.py` and `agent_bridge.py` post to `api.telegram.org` directly,
`sync-webhook` uses the Apprise *python library* in-process, and `daily_report.py` silently
falls back to direct Telegram when the POST fails. That is the answer to "how am I getting
notifications" — you never were, from this container.

**Fix:** `configs/apprise/apprise.yml.template` stays git-tracked with placeholders;
`configs/apprise/render.sh` substitutes real values into a **gitignored** `apprise.yml`; a new
`apprise-init` alpine container runs it to completion before apprise starts
(`service_completed_successfully`). It fails loudly on any unset var or leftover placeholder
rather than writing a half-rendered config. Added the missing `infra`/`servers` tag → Mother
Notifications.

**Verified:** 0 config errors, 5 targets resolve, real send returns `Sent Telegram
notification.` exit 0. Confirmed the previously-committed apprise.yml never held a real token,
so nothing leaked historically.

**Terminus's Apprise is still broken** — same symptom class, not yet diagnosed. Asked its
Claude to check (§4c). `daily_report.py` posts there, so it has been running on its fallback.

---

## 4c. Cross-session coordination with Terminus

The two Claude sessions **can** message each other — `ListAgents` shows Terminus's session over
Remote Control, and `SendMessage` reaches it by name (`terminus-rustling-octopus`). Sent it a
request covering: the two `{service="plexbackup"}` alert rules for Hathor, the Apprise root
cause and fix, and whether `{host="hathor"}` is arriving in Terminus's Loki. Awaiting reply.

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
