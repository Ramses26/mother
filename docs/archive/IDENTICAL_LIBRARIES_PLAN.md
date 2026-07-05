# Identical Libraries Plan
## Goal: Synology ≡ Unraid at all times

**Last updated**: 2026-03-28
**Status**: Phase 1 in progress (batch sync running)

---

## Overview

Chris's Synology and Ali's Unraid should be identical mirrors. Every file operation —
new download, upgrade, or delete — must propagate to both servers automatically.

```
Chris's LAN (10.0.0.x)                Ali's LAN (192.168.1.x)
┌─────────────────────┐  VPN tunnel   ┌──────────────────────────────────┐
│  Mother (10.0.0.162)│◄─────────────►│  Unraid (192.168.1.10)           │
│  - Radarr / Sonarr  │               │  - Media library (/mnt/user/...)  │
│  - Upgraderr        │               │  - Plex                          │
│  - Curatorr         │               │  - **Unraid Agent** (Docker)     │
│  - sync-webhook     │               │    port 9708, local disk access  │
└─────────────────────┘               └──────────────────────────────────┘
         │ NFS                         Also available:
┌─────────────────────┐               ┌──────────────────────────────────┐
│  Synology NAS       │               │  Terminus (192.168.1.14)         │
│  rs-movies (1080p)  │               │  - Docker host (alternative      │
│  rs-4kmedia (4K)    │               │    deploy target if needed)      │
│  rs-tv              │
└─────────────────────┘
```

**Key insight**: Unraid itself runs Docker natively. The agent runs directly on the
same machine as the files — zero network hop for file operations. Mother calls the
agent API over VPN, but the delete/scan/cleanup happens on local disk.

Terminus (192.168.1.14) is available as an alternative deploy target but is
unnecessary since Unraid Docker is the most direct option.

---

## Current State (2026-03-28)

| Item | Status |
|------|--------|
| Movie batch sync | ~10% complete (~875 tasks, Chris→Ali) |
| TV batch sync | ~73% complete (~12K tasks, Chris→Ali) |
| chris_pending_deletions script | Ready, 1407 lines — run AFTER movie sync |
| sync-webhook | Running, handles new downloads + upgrade deletions |
| Upgraderr | Paused until after sync completes |
| Unraid Agent | Not yet deployed (runs on Unraid Docker) |

**Sync direction note**: Current batch scripts copy Chris's Synology → Ali's Unraid
(the scripts are named from Ali's perspective as "Copy Ali→Chris" but they actually
copy Chris's files to Ali). After completion, both libraries will be ~equivalent.

---

## Phase 1 — Wait for Batch Sync (NOW)

**Do nothing special.** Let the batch syncs run to completion.

- `screen -r movie` — movie sync loop (auto-restarts via movie_sync_loop.sh)
- `screen -r tvsync` — TV sync script

After both complete:
1. Run `chris_pending_deletions_20260325_182027.sh` — removes Chris's inferior copies
   that were superseded by Ali's better versions
2. At this point: Synology ≈ Unraid (minor gaps may remain, will be caught by
   inventory re-compare after movie loop completes)

**Do NOT** run Upgraderr yet. New upgrades would create new divergence before parity.

---

## Phase 2 — Deploy Unraid Agent

A lightweight FastAPI service running as a Docker container directly on Unraid.
File operations are completely local — no network hop, no mount translation.
Mother calls the API over VPN; the agent handles everything on local disk.

### Why Unraid Docker vs CIFS from Mother

| | CIFS from Mother | Unraid Agent |
|-|-----------------|--------------|
| File op path | VPN → CIFS → kernel → disk | Local disk (same machine) |
| Mount dependency | Fragile (stale handles, Docker bind issues) | None |
| VPN dependency for file ops | Yes | No (API call over VPN, but op is local) |
| Visibility | Silent failures | Explicit API responses + logs |
| Future expansion | Hard | Easy — add endpoints, trigger Plex scans, etc. |

### Unraid Agent Endpoints

```
GET  /health                     — liveness check
POST /files/delete               — delete a file or folder
POST /files/cleanup-folder       — delete all video files in a folder EXCEPT keeper
GET  /files/exists?path=...      — check if path exists
```

### Deployment

Deployed directly on Unraid via Docker (Community Apps or manual docker run).
Media path mounted read-write: `/mnt/user/Media:/mnt/user/Media`

```bash
# Build on Mother, transfer image to Unraid, or build on Unraid directly
docker build -t unraid-agent services/unraid-agent/
docker save unraid-agent | ssh unraid "docker load"
ssh unraid "docker run -d --name unraid-agent \
  -p 9708:8000 \
  -v /mnt/user/Media:/mnt/user/Media \
  -e AGENT_TOKEN=<secret> \
  --restart unless-stopped unraid-agent"
```

Service lives at: `http://192.168.1.10:9708`

### Security

- Shared secret in header: `X-Agent-Token`
- Bind to `0.0.0.0` — Unraid's firewall / Docker network limits exposure
- All paths validated against `/mnt/user/Media` prefix before any operation

---

## Phase 3 — Update sync-webhook for Post-Rsync Cleanup

After every successful movie rsync, call Unraid Agent to clean up stale copies.

### The Gap Being Fixed

When a movie is in "missing" state in Radarr (no tracked file), `deletedFiles[]` in
the webhook payload is empty. Rsync copies the new file to Unraid, but any existing
file with a different name stays.

### Implementation in `services/sync-webhook/app.py`

```python
UNRAID_AGENT_URL = os.environ.get('UNRAID_AGENT_URL', 'http://192.168.1.10:9708')
UNRAID_AGENT_TOKEN = os.environ.get('UNRAID_AGENT_TOKEN', '')

def cleanup_unraid_movie_folder(dest_dir: str, keeper_filename: str, title: str):
    """After rsync, remove stale video files from Unraid movie folder via Unraid Agent."""
    try:
        r = requests.post(
            f"{TERMINUS_AGENT_URL}/files/cleanup-folder",
            json={"folder": dest_dir, "keeper": keeper_filename},
            headers={"X-Agent-Token": UNRAID_AGENT_TOKEN},
            timeout=15,
        )
        result = r.json()
        for deleted in result.get("deleted", []):
            send_telegram(f"🗑️ Stale duplicate removed: {title} — {deleted}")
    except Exception as e:
        log.warning(f"Terminus cleanup failed for {dest_dir}: {e}")
```

Called in `do_sync()` after `rsync_result == 0` for movie imports.

### Also add: MovieFileDeleted webhook handler

When Curatorr or Radarr triggers a manual delete, Radarr fires `MovieFileDeleted`.
The webhook should handle this event type and call Unraid Agent to delete the
corresponding Unraid file.

```python
elif event_type == 'MovieFileDeleted':
    deleted_path = data.get('movieFile', {}).get('path', '')
    if deleted_path:
        unraid_path = synology_to_unraid_path(deleted_path)
        # Call Unraid Agent to delete unraid_path
```

---

## Phase 4 — Update Curatorr to Use Unraid Agent

Replace the CIFS-dependent Unraid delete in `actions.py` with a Unraid Agent call.

### Current (fragile)

```python
# actions.py — requires /mnt/unraid/media CIFS bind mount in container
unraid_path = synology_to_unraid_path(file_path)
os.remove(unraid_path)
```

### Future (robust)

```python
# actions.py — calls Unraid Agent over HTTP
async with httpx.AsyncClient(timeout=15) as client:
    await client.post(
        f"{TERMINUS_AGENT_URL}/files/delete",
        json={"path": unraid_path},
        headers={"X-Agent-Token": TERMINUS_AGENT_TOKEN},
    )
```

Benefits:
- No CIFS bind mount needed in curatorr container
- Explicit success/failure response
- Unraid Agent logs the deletion locally
- Can be extended with Plex library rescan trigger after delete

---

## Phase 5 — Unpause Upgraderr

Once parity is confirmed:

1. Verify: run a fresh inventory compare — expect 0 or near-0 differences
2. Run `chris_pending_deletions` if not already done
3. Set Upgraderr budget back to active values in DB
4. Monitor first few upgrades end-to-end:
   - Upgraderr finds candidate → triggers Radarr search
   - Radarr downloads + imports → webhook fires
   - New file lands on Synology + rsync to Unraid
   - Old file deleted from Synology (Radarr) + Unraid (webhook/Unraid Agent)

---

## Ongoing Workflow (Post-Parity)

```
New release / Missing movie:
  Radarr RSS grab → import → webhook rsync → Unraid gets file
  (deletedFiles[] empty → folder scan via Unraid Agent cleans stale copies)

Upgrade (Upgraderr):
  Upgraderr → Radarr search → import → webhook:
    - rsync new file to Unraid
    - deletedFiles[] has old file → delete from Unraid
    - folder scan as safety net

Manual delete (Curatorr):
  Curatorr → Radarr deleteFiles=true (removes Synology)
           → Unraid Agent delete (removes Unraid)
           → DB record + Telegram notification

Plex duplicate cleanup (Curatorr):
  Already implemented — TRaSH scoring, delete via Radarr or Unraid Agent
```

---

## Radarr "Missing" List Remediation

After batch sync copies files from Ali→Chris, Radarr on Chris doesn't know about them
(they landed outside of Radarr's import workflow). Fix:

```bash
# Trigger Radarr RescanMovie for all movies in "missing" state
# This makes Radarr find the file and remove it from missing
curl -X POST "http://radarr-hd:7878/api/v3/command" \
  -H "X-Api-Key: $RADARR_HD_API_KEY" \
  -d '{"name": "RescanMovie"}' | jq .
```

Run after batch sync + chris_pending_deletions. Expected result: 195 missing → ~0.

---

## Future: Release Date Awareness in Upgraderr

Currently Radarr handles truly-missing movies via RSS (grabbing whatever appears).
Long-term improvement: add TMDB digital/streaming release date monitoring to Upgraderr
so it schedules a targeted search on the exact release day, rather than waiting for
something to appear on RSS (which may be a bad encode).

This is a future sprint item — not blocking parity.

---

## Checklist

### Phase 1 — Batch Sync
- [ ] Movie batch sync complete (movie_sync_loop.sh finishes)
- [ ] TV batch sync complete (tvsync screen finishes)
- [ ] Run `chris_pending_deletions_20260325_182027.sh`
- [ ] Run fresh inventory compare — verify near-zero differences
- [ ] Trigger Radarr RescanMovie (both HD and 4K instances)

### Phase 2 — Unraid Agent
- [ ] Build `services/unraid-agent/` (FastAPI, ~150 lines)
- [ ] Deploy to Terminus via SSH
- [ ] Add `TERMINUS_AGENT_URL` + `TERMINUS_AGENT_TOKEN` to `.env`
- [ ] Test `/health` and `/files/delete` endpoints

### Phase 3 — Webhook Updates
- [ ] Add `cleanup_unraid_movie_folder()` call after successful movie rsync
- [ ] Add `MovieFileDeleted` event handler
- [ ] Test with a real upgrade cycle

### Phase 4 — Curatorr Updates
- [ ] Replace CIFS-path delete in `actions.py` with Unraid Agent call
- [ ] Remove `/mnt/unraid/media` bind mount from compose (no longer needed)
- [ ] Test Curatorr delete → confirm file gone from both servers

### Phase 5 — Unpause Upgraderr
- [ ] Verify parity (inventory compare shows ~0 differences)
- [ ] Set Upgraderr budgets to active
- [ ] Monitor first 5 upgrades end-to-end
