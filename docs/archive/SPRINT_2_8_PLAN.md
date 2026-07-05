# Sprint 2.8 — System Load Fix + Curatorr Bug Fixes

## Context

Multiple issues identified through logs, DB inspection, and code analysis. The system is laggy (load ~9) primarily due to an **infinite Plex sync loop** running multiple times concurrently. Additionally, several Curatorr UI bugs persist that were either missed in previous sprints or introduced by structural gaps in the API.

---

## Issue 1 — CRITICAL: Plex Sync Infinite Loop (primary load cause)

**Root cause confirmed:**
Section 13 (4K Movies, 153 items): Plex ignores `X-Plex-Start` when offset > total, always returning all 153 items. `len(items)=153 >= page_size=100` so `if len(items) < page_size: break` **never triggers**. Runs forever at ~2 req/sec. Confirmed: `X-Plex-Start=78500` still returns 153 items. `totalSize` attribute is `None` but `size=153` is present on the XML root.

**Fix — `services/curatorr/app/sync/plex.py` in `_sync_section()`:**

Read `root.get('size')` on first iteration and add `if total_size and offset >= total_size: break` guard at end of while loop.

---

## Issue 2 — CRITICAL: Concurrent Sync Jobs Stack Infinite Loops

**Root cause:** `asyncio.create_task(trigger_sync_by_source(source))` in `routes/sync.py` has NO concurrency control. APScheduler's `max_instances=1` prevents duplicate *scheduled* jobs only — not manual triggers. Each "Sync Plex" click spawns another infinite loop running simultaneously.

**Fix — `app/scheduler.py`:** Add `_running_syncs: set[str] = set()` module-level. In `trigger_sync_by_source`: add source to set on entry, remove in `finally`. Return early if source already in set.

**Fix — `app/routes/sync.py`:** Before creating the task, check `_running_syncs` and return `{'ok': False, 'message': 'Sync already running: ...'}` if occupied.

---

## Issue 3 — CIFS Hung (secondary load contributor)

**Confirmed:** 4 rsync processes in D-state (`cifs_call_async` in `/proc/<pid>/wchan`), `ls /mnt/unraid/media/` also D-state.

**Immediate fix (user must run with sudo):**
```bash
sudo kill -9 $(ps aux | grep rsync | grep '/mnt/unraid' | awk '{print $2}') 2>/dev/null
sudo umount -l /mnt/unraid/media && sudo mount /mnt/unraid/media
timeout 3 ls /mnt/unraid/media && echo "OK"
```

**To avoid babysitting — create `/opt/mother/scripts/fix-cifs.sh` + add NOPASSWD rule:**
```
alig ALL=(ALL) NOPASSWD: /opt/mother/scripts/fix-cifs.sh
```
User runs `sudo visudo -f /etc/sudoers.d/mother-fix-cifs` once, then I can call `sudo /opt/mother/scripts/fix-cifs.sh` whenever needed.

---

## Issue 4 — Posters Not Showing (Movies + TV)

**Root cause:** `poster_url` and `plex_key` excluded from list API SELECTs:
- `routes/movies.py` line 224: 31-column explicit SELECT, no `poster_url`, no `plex_key`
- `routes/tv.py` line 198: same omission

Frontend has `m.poster_url || /api/poster?plex_key=...` but both fields are null → no image shown in card/grid view.

**Fix:** Add `poster_url, plex_key` to both SELECT statements.

---

## Issue 5 — Purge Candidates Opens List, Not Detail

**Root cause:** `Dashboard.vue` line 60: `@click="$router.push('/movies?preset=purge_candidates')"` — ignores which item was clicked, navigates to filtered list.

**Fix:**
1. `Dashboard.vue`: change to `@click="$router.push('/movies?open=' + item.id)"`
2. `Movies.vue` `onMounted`: if `route.query.open` exists, fetch that movie and auto-call `openDetail()`

---

## Issue 6 — Logs Timezone Wrong

**Root cause:** SQLite `CURRENT_TIMESTAMP` = `'2026-03-21 23:13:12'` (no timezone marker). JS `new Date('2026-03-21 23:13:12')` treats it as **local time**, not UTC. Result: UTC 23:13 is shown as "11:13 PM" instead of the correct local conversion.

**Fix:** In every `fmtDate` helper, append `'Z'` before parsing:
```js
const dt = new Date(d.includes('Z') ? d : d + 'Z')
```

Files: `Logs.vue`, `Settings.vue`, `MediaDetail.vue`, `Movies.vue`, `TvShows.vue`

---

## Issue 7 — Sync Status Disappears on Navigation

**Root cause:** `syncMsg` in Settings.vue is component-local, cleared by `setTimeout(..., 5000)`. Navigating away and back loses all state.

**Fix:** After triggering sync, poll `GET /api/sync/status` every 3s and show per-source status inline. Stop polling when all sources reach terminal state (`ok`/`error`/`not_configured`). Use a `syncStatuses` reactive ref populated from the poll.

---

## Issue 8 — Tautulli-Ali Unreachable

**192.168.1.14 (Terminus) is on Ali's LAN** — only reachable from Mother via IPsec VPN. Verify VPN is up and URL was saved:
```bash
docker exec curatorr python3 -c "
import sqlite3; conn = sqlite3.connect('/data/curatorr.db')
print(conn.execute('SELECT key,value FROM config WHERE key LIKE \"%tautulli%\"').fetchall())"
```

If VPN is up and 192.168.1.14:8181 is reachable from Mother (`curl http://192.168.1.14:8181/api/v2?apikey=...&cmd=get_server_info`), the next scheduled sync at 02:00 will pick it up. No code change needed.

---

## Implementation Order

| # | File | Change |
|---|------|--------|
| 1 | `app/sync/plex.py` | `total_size` guard in `_sync_section` while loop |
| 2 | `app/scheduler.py` | `_running_syncs` set + early-return guard |
| 3 | `app/routes/sync.py` | Return conflict if sync already running |
| 4 | `app/routes/movies.py` | Add `poster_url, plex_key` to SELECT |
| 5 | `app/routes/tv.py` | Add `poster_url, plex_key` to SELECT |
| 6 | `frontend/src/views/Dashboard.vue` | `?open=<id>` instead of preset |
| 7 | `frontend/src/views/Movies.vue` | Handle `?open=<id>` on mount |
| 8 | All views with `fmtDate` | Append 'Z' to timestamp strings |
| 9 | `frontend/src/views/Settings.vue` | Sync status polling after trigger |
| 10 | `scripts/fix-cifs.sh` | New script for NOPASSWD sudo remount |
| 11 | Deploy | `docker compose build curatorr && docker compose up -d curatorr` |

---

## Verification

1. `docker logs curatorr --tail 20` — Plex sync completes section 13 in 2 pages, not 78,000+
2. `uptime` → load drops from ~9 to <2 within 5 minutes
3. Movies + TV poster view → posters visible
4. Dashboard → click purge candidate → detail panel opens for that specific item
5. Logs page → timestamps show correct local EST time (not "11:13 PM")
6. Settings → Sync Plex → navigate away → come back → status still showing
7. `GET /api/sync/status` → plex-chris: `ok` not `syncing`
