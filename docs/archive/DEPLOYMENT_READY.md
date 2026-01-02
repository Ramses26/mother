# Mother Deployment - Final Configuration

**Date:** 2024-12-25  
**Status:** Ready to Deploy

---

## ✅ What Changed

### Seerr Configuration Update

**OLD Setup:**
- seerr-ali on Mother (port 5055)
- seerr-chris on Mother (port 5056)

**NEW Setup (Correct):**
- ~~seerr-ali~~ → Runs on **Terminus** (Ali's local server)
- seerr-chris → Runs on **Mother** (port 5056)

**Why:** Ali already has Seerr running on Terminus locally, no need to duplicate it on Mother.

---

## 📝 Files Updated

### 1. ✅ docker-compose.yml
**Changes:**
- ❌ Removed entire `seerr-ali` container section
- ✅ Kept `seerr-chris` container
- ✅ Added note: "Ali runs his own Seerr instance on Terminus"

### 2. ✅ .env.example
**Changes:**
- ❌ Removed `SEERR_ALI_PORT=5055`
- ✅ Fixed `CONFIG_PATH=/opt/mother/configs` (added 's')
- ✅ Added note at bottom about Seerr setup

---

## 🔧 What You Need to Do on Mother

### Step 1: Replace docker-compose.yml

```bash
# SSH to Mother
ssh mother
cd /opt/mother

# Backup current file
cp docker-compose.yml docker-compose.yml.backup

# Download the corrected version from outputs folder
# (or manually edit to remove seerr-ali section)
```

### Step 2: Fix Your .env File

```bash
cd /opt/mother
nano .env

# Make these changes:

# Line 18: Fix CONFIG_PATH (add the 's')
CONFIG_PATH=/opt/mother/configs

# Line 45-46: Remove/comment out SEERR_ALI_PORT
# Delete this line or comment it:
# SEERR_ALI_PORT=5055

# Keep this line:
SEERR_CHRIS_PORT=5056

# Save and exit (Ctrl+X, Y, Enter)
```

### Step 3: Remove seerr-ali Config Directory

```bash
# This directory won't be used
rm -rf /opt/mother/configs/seerr-ali
```

---

## ✅ Final Pre-Deploy Checklist

### Configuration Files:
- [ ] docker-compose.yml updated (seerr-ali removed)
- [ ] .env file fixed: `CONFIG_PATH=/opt/mother/configs`
- [ ] .env file: SEERR_ALI_PORT removed/commented
- [ ] .env file: DB_ROOT_PASSWORD set
- [ ] .env file: SEERR_DB_PASSWORD set
- [ ] PUID/PGID verified (run `id`)

### Infrastructure:
- [ ] Synology NFS mounts working (5 mounts)
- [ ] Docker installed and running
- [ ] User in docker group
- [ ] configs directory exists with subdirectories

### Network:
- [ ] Mother IP: 10.0.0.162
- [ ] Can ping all Synology devices
- [ ] SSH access working

---

## 🚀 Ready to Deploy!

Once checklist is complete:

```bash
cd /opt/mother

# Run deploy
./scripts/deploy.sh

# Watch containers start
docker compose ps

# Should see these containers (NO seerr-ali):
# - qbittorrent
# - cross-seed
# - radarr-hd
# - radarr-4k
# - sonarr-hd
# - sonarr-4k
# - prowlarr
# - recyclarr
# - seerr-chris         ← Only Chris's Seerr
# - nginx-proxy-manager
# - dozzle
# - webmin

# Check logs if any issues
docker compose logs
```

---

## 🌐 Service Access URLs (After Deploy)

### Management & Monitoring:
- **Webmin:** https://10.0.0.162:10000 (Ubuntu credentials)
- **Dozzle:** http://10.0.0.162:8888 (Docker logs)
- **NPM:** http://10.0.0.162:81 (admin@example.com / changeme)

### Media Management:
- **qBittorrent:** http://10.0.0.162:8080 (admin / adminadmin)
- **Radarr HD:** http://10.0.0.162:7878
- **Radarr 4K:** http://10.0.0.162:7879
- **Sonarr HD:** http://10.0.0.162:8989
- **Sonarr 4K:** http://10.0.0.162:8990
- **Prowlarr:** http://10.0.0.162:9696

### Request Management:
- **Seerr (Chris):** http://10.0.0.162:5056
- **Seerr (Ali):** Running on Terminus (your local server)

---

## 📊 Container Count

**Total Containers:** 12 (down from 13)

**Removed:** seerr-ali  
**Reason:** Ali runs his own Seerr on Terminus

---

## 🎯 Architecture Overview

```
Ali's Side:
┌─────────────┐
│  Terminus   │
│  (Local)    │
├─────────────┤
│ Seerr-Ali   │ ← Ali's request interface
│ Unraid NAS  │ ← Ali's media storage
└─────────────┘
       ↕ VPN
┌─────────────┐
│   Mother    │
│ (10.0.0.162)│
├─────────────┤
│ Radarr HD   │
│ Radarr 4K   │
│ Sonarr HD   │
│ Sonarr 4K   │
│ qBittorrent │
│ Prowlarr    │
│ Seerr-Chris │ ← Chris's request interface
└─────────────┘
       ↕ Local Network
┌─────────────┐
│  Synology   │
│   Devices   │
├─────────────┤
│ RS-Movies   │
│ RS-TV       │
│ RS-4KMedia  │ ← Chris's media storage
└─────────────┘
```

**How it works:**
- Ali makes requests via Seerr on **Terminus**
- Chris makes requests via Seerr on **Mother**
- Both requests go to same Radarr/Sonarr instances on Mother
- Downloads go to Synology (Chris's local storage)
- Files sync to Unraid (Ali's storage via VPN)

---

## 🔄 After Successful Deploy

1. **Change Default Passwords**
   - qBittorrent: Tools → Options → Web UI
   - NPM: Login and change password

2. **Configure Services** (1-2 hours)
   - Set up Prowlarr with indexers
   - Connect Radarr/Sonarr to Prowlarr
   - Add download client (qBittorrent)
   - Get API keys for Recyclarr

3. **Update .env with API Keys**
   ```bash
   nano /opt/mother/.env
   # Add API keys from Radarr/Sonarr
   ```

4. **Run Recyclarr Sync**
   ```bash
   docker exec recyclarr recyclarr sync
   ```

5. **Start Inventory Scans**
   - On Terminus: Ali's 4 libraries
   - On Mother: Chris's 4 libraries

---

## ✅ Success Criteria

You'll know it's working when:
- [ ] All 12 containers show "Up"
- [ ] Can access all web UIs
- [ ] qBittorrent can connect to trackers
- [ ] Radarr/Sonarr can search indexers
- [ ] Test download completes successfully
- [ ] Chris can access Seerr at http://10.0.0.162:5056

---

## 📞 If Something Goes Wrong

```bash
# Check container status
docker compose ps

# Check logs for failed container
docker compose logs [container-name]

# Restart a container
docker compose restart [container-name]

# Restart everything
cd /opt/mother
docker compose down
docker compose up -d

# Check .env file
cat .env | grep -E "CONFIG_PATH|SEERR|DB_"
```

---

## 🎉 You're Ready!

Once you:
1. Replace docker-compose.yml with the corrected version
2. Fix CONFIG_PATH in .env (add 's')
3. Remove SEERR_ALI_PORT from .env
4. Verify all checklist items

**Run:** `./scripts/deploy.sh`

**Then configure services and start enjoying your unified media server!** 🚀
