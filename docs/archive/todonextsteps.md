# qBittorrent Migration: Mother → Synology RS2821RP+

## Summary of Conversation

### Initial Questions
1. **Cross-seed setup** - User asked about cross-seed and whether hardlinks are necessary
   - **Answer**: Yes, hardlinks are strongly recommended to avoid duplicate data
   - User's setup WILL support hardlinks because all downloads are on `/mnt/synology/rs-4kmedia/downloads` (single mount)
   - Discussed QUI vs cross-seed docker - recommended QUI for its integrated approach, but user decided to think about it

2. **qBittorrent Performance Issues** - User reported slow download/upload speeds
   - Analyzed logs from `qbit-analysis/` folder (copied from mother)
   - **Root Cause Found**: Logs flooded with `"max outstanding piece requests reached"` performance warnings
   - This indicates **NFS disk I/O bottleneck** - writing over network to Synology causes latency issues
   - Ports are correctly configured (52525 in both .env and qBittorrent config)

### Decision Made
**Move qBittorrent from Mother to Synology RS2821RP+** to eliminate NFS write overhead.

### Why Synology is Better
- Direct disk writes (no NFS latency)
- RS2821RP+ is powerful (AMD Ryzen V1500B, up to 32GB RAM)
- Data lives where it downloads
- The *arr apps reading via NFS for imports is fine (read-heavy, not write-heavy)

---

## Synology Details Gathered

- **IP Address**: 10.0.1.203 (CHRIS_RS_4KMEDIA in .env)
- **Docker Subnet**: 172.17.0.1/16
- **Container Manager**: Installed

### Volume Structure (`/volume1/`)
```
/volume1/Downloads      - for torrent downloads
/volume1/4KMovies       - 4K movies library
/volume1/4KTV           - 4K TV library
/volume1/docker         - for container configs (will use /volume1/docker/qbittorrent)
```

### User ID Decision (PENDING)
- User `alig` is UID=1027, GID=100 - but user doesn't want to run under their personal account
- Options discussed:
  1. Create `dockeruser` via DSM (best practice)
  2. Use PUID=1029, PGID=100 (quick approach, folders are 777 anyway)
- **Decision needed on next session**

---

## Migration Plan

### Phase 1: Set Up qBittorrent on Synology
- [ ] Decide on PUID/PGID (create dockeruser or use 1029/100)
- [ ] Create docker-compose.yml for Synology
- [ ] Store config in `/volume1/docker/qbittorrent`
- [ ] Use host networking for better torrent performance
- [ ] Deploy container via Container Manager or SSH

### Phase 2: Migrate Data from Mother
- [ ] Download data is ALREADY on Synology (it's the NFS source, just need correct paths)
- [ ] Copy BT_backup folder from mother (`/opt/mother/configs/qbittorrent/qBittorrent/BT_backup/`)
  - Contains .torrent files + resume data (critical for continued seeding)
- [ ] Copy qBittorrent config (`/opt/mother/configs/qbittorrent/qBittorrent/qBittorrent.conf`)
- [ ] Adjust paths in config to match Synology local paths

### Phase 3: Update Mother Services
- [ ] Update Radarr HD download client → point to 10.0.1.203:8080
- [ ] Update Radarr 4K download client → point to 10.0.1.203:8080
- [ ] Update Sonarr HD download client → point to 10.0.1.203:8080
- [ ] Update Sonarr 4K download client → point to 10.0.1.203:8080
- [ ] Update Prowlarr (if configured to push to qBittorrent)
- [ ] Update qbit_manage config (`/opt/mother/configs/qbitmanage/`) → point to new host
- [ ] Update .env file with new qBittorrent host

### sync-webhook (NO CHANGES NEEDED)
The sync-webhook Python app (`services/sync-webhook/app.py`) syncs from Synology → Unraid
after Radarr/Sonarr imports. It does NOT interact with qBittorrent directly.

**Why it still works:**
- Triggered by Radarr/Sonarr webhooks (after import completes)
- Reads from NFS mounts (`/mnt/synology/...`) - these paths don't change
- PATH_MAPPINGS in the code map library paths, not download paths
- The download location change is transparent to sync-webhook

**Flow after migration:**
1. qBittorrent (Synology) downloads to `/volume1/Downloads`
2. Radarr/Sonarr (mother) sees via NFS → `/mnt/synology/rs-4kmedia/downloads`
3. Radarr/Sonarr imports to library → triggers webhook
4. sync-webhook syncs from `/mnt/synology/...` to `/mnt/unraid/...` (unchanged)

### Phase 4: Cleanup
- [ ] Verify all torrents are seeding correctly on Synology
- [ ] Disable/remove qBittorrent container on mother
- [ ] Update docker-compose.yml on mother (comment out qBittorrent service)

---

## Path Mapping Reference

| Mother (NFS mount) | Synology (local) |
|-------------------|------------------|
| /mnt/synology/rs-4kmedia/downloads | /volume1/Downloads |
| /mnt/synology/rs-4kmedia/4kmovies | /volume1/4KMovies |
| /mnt/synology/rs-4kmedia/4ktv | /volume1/4KTV |

---

## Docker Compose Template (To Be Finalized)

```yaml
services:
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    network_mode: host  # Better for torrents
    environment:
      - PUID=XXXX  # TBD - dockeruser or 1029
      - PGID=100
      - TZ=America/New_York
      - WEBUI_PORT=8080
    volumes:
      - /volume1/docker/qbittorrent:/config
      - /volume1/Downloads:/downloads
    restart: unless-stopped
```

---

## Files to Reference
- `/home/alig/projects/mother/.env` - environment variables
- `/home/alig/projects/mother/docker-compose.yml` - current mother setup
- `/home/alig/projects/mother/qbit-analysis/` - copied qBittorrent config/logs from mother

---

## Next Steps for Claude
1. Ask user: Create `dockeruser` or use PUID=1029?
2. Finalize and create docker-compose for Synology
3. Provide migration commands for BT_backup and config
4. Help update mother services (Radarr/Sonarr/Prowlarr/qbit_manage)
5. sync-webhook: NO CHANGES NEEDED (already verified - it reads from NFS mounts, not qBittorrent)
