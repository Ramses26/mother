# Project Mother - Current Status
**Last Updated:** 2024-12-25 16:00
**Session:** Scans Running - Services Being Configured

---

## ✅ COMPLETED - Phase 1: Infrastructure

### Mother Server (10.0.0.162)
- ✅ Ubuntu 24.04 deployed
- ✅ Docker installed and running
- ✅ All containers deployed (10 total)
- ✅ Git repository configured

### Docker Containers Status
All containers running:
- ✅ qbittorrent (8080)
- ✅ cross-seed (2468)
- ✅ radarr-hd (7878)
- ✅ radarr-4k (7879)
- ✅ sonarr-hd (8989)
- ✅ sonarr-4k (8990)
- ✅ prowlarr (9696)
- ✅ recyclarr
- ✅ nginx-proxy-manager (81)
- ✅ dozzle (8888)
- ✅ portainer (9000)

### NFS Mounts
- ✅ Synology (5 mounts) - Working
- ⏳ Unraid - Pending (will mount after VPN)

---

## 🔄 CURRENT PHASE - Scanning & Configuration

### Inventory Scans Running

**Terminus (Ali's Libraries):**
- ⏳ Movies - Scanning from /mnt/media/Movies
- ⏳ 4K Movies - Scanning from /mnt/media/4K Movies
- ⏳ TV Shows - Scanning from /mnt/media/TV Shows
- ⏳ 4K TV Shows - Scanning from /mnt/media/4K TV Shows

**Mother (Chris's Libraries):**
- ⏳ Movies - Scanning from /mnt/synology/rs-movies
- ⏳ 4K Movies - Scanning from /mnt/synology/rs-4kmedia/4kmovies
- ⏳ TV Shows - Scanning from /mnt/synology/rs-tv
- ⏳ 4K TV Shows - Scanning from /mnt/synology/rs-4kmedia/4ktv

**Expected Completion:** 4-6 hours

### Service Configuration Status

| Service | Configuration | Status |
|---------|--------------|--------|
| qBittorrent | Password, categories, paths | ⏳ TODO |
| Prowlarr | Indexers, download client | ⏳ TODO |
| Radarr HD | Root folder, download client | ⏳ TODO |
| Radarr 4K | Root folder, download client | ⏳ TODO |
| Sonarr HD | Root folder, download client | ⏳ TODO |
| Sonarr 4K | Root folder, download client | ⏳ TODO |
| Recyclarr | Quality profiles sync | ⏳ TODO |
| Portainer | Admin account | ⏳ TODO |
| NPM | User accounts | ⏳ TODO |

---

## 📊 HDR Priority (Verified & Correct)

```python
HDR_SCORES = {
    'HDR10': 300,      # #1 - Universal compatibility
    'DV HDR10': 280,   # #2 - DV with HDR10 fallback
    'HDR': 250,        # #3 - Generic HDR
    'DV': 150,         # #4 - DV only
    'HDR10+': 100,     # #5 - Samsung (lowest)
}
```

---

## 🎯 Next Steps

### While Scans Run (Now):
1. Configure qBittorrent
2. Configure Prowlarr
3. Configure Radarr HD & 4K
4. Configure Sonarr HD & 4K
5. Update .env with API keys
6. Run Recyclarr sync
7. Test downloads

### After Scans Complete:
1. Copy Ali's inventories to Mother
2. Run comparison scripts
3. Review comparison reports
4. Plan initial sync strategy
5. Execute test sync
6. Full sync

---

## 📁 Important Paths

**On Mother:**
- Project: `/opt/mother`
- Configs: `/opt/mother/configs`
- Inventories: `/opt/mother/inventories`
- Scripts: `/opt/mother/scripts`

**On Terminus:**
- Unraid Mount: `/mnt/media`
- Inventories: `~/inventories`
- Script: `~/generate_inventory.py`

---

## 🔑 Credentials

**System:**
- Mother SSH: alig@10.0.0.162
- Webmin: https://10.0.0.162:10000 (alig/password)

**Docker (Defaults - CHANGE THESE!):**
- qBittorrent: admin/adminadmin
- NPM: admin@example.com/changeme

---

## 📝 Session Notes

**What We Fixed:**
- ✅ HDR detection in generate_inventory.py
- ✅ Proper priority: HDR10 > DV HDR10 > HDR > DV > HDR10+
- ✅ Git sync between WSL/GitHub/Mother
- ✅ Mounted Unraid on Terminus for fast scanning

**Current Focus:**
- Configure all services while scans run
- Prepare for library comparison
- Test download workflows

---

See: **docs/SERVICE_CONFIG_GUIDE.md** for step-by-step configuration!
