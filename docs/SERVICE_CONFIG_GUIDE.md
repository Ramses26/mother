# Service Configuration Guide
**Do This While Scans Are Running!**
**Estimated Time:** 1.5 hours total

---

## 🎯 Overview

Configure all services in this order while inventory scans run in the background. This takes advantage of the 4-6 hour scanning window.

---

## 📋 Configuration Order

1. qBittorrent (10 min) - Download client
2. Prowlarr (20 min) - Indexer manager
3. Radarr HD (15 min) - HD Movies
4. Radarr 4K (15 min) - 4K Movies
5. Sonarr HD (15 min) - HD TV
6. Sonarr 4K (15 min) - 4K TV
7. Update .env with API keys (5 min)
8. Recyclarr (10 min) - Quality profiles

**Total: ~1.5 hours**

---

## 🔧 1. qBittorrent Configuration (10 min)

### Access qBittorrent
```
URL: http://10.0.0.162:8080
Default: admin / adminadmin
```

### Step 1: Change Password
1. Tools → Options
2. Web UI tab
3. **Authentication:**
   - Username: `admin`
   - Password: `[new secure password]`
4. Click **Save**

### Step 2: Set Paths
1. Tools → Options
2. **Downloads tab:**
   - Default Save Path: `/downloads`
   - Keep incomplete torrents in: `/downloads/incomplete`
   - ✓ Copy .torrent files for finished downloads to: `/downloads/torrents`

### Step 3: Create Categories
1. Right-click in left sidebar → **Add category**
2. Create these categories:
   ```
   radarr-hd       → /downloads/radarr-hd
   radarr-4k       → /downloads/radarr-4k
   sonarr-hd       → /downloads/sonarr-hd
   sonarr-4k       → /downloads/sonarr-4k
   ```

### Step 4: Connection Settings
1. Tools → Options → Connection tab
2. **Listening Port:** 6881
3. **Use UPnP/NAT-PMP:** ✓ (if needed)
4. **Connections Limits:**
   - Global: 500
   - Per torrent: 100
   - Upload slots: 20

### Step 5: BitTorrent Settings
1. Tools → Options → BitTorrent tab
2. **Privacy:**
   - ✓ Enable DHT
   - ✓ Enable PeX
   - ✓ Enable Local Peer Discovery
3. **Torrent Queueing:**
   - Maximum active downloads: 5
   - Maximum active uploads: 10
   - Maximum active torrents: 15

### Step 6: Test Download (Optional)
1. Add a test torrent (legal content!)
2. Verify it downloads to `/downloads`
3. Check category assignment works

✅ **qBittorrent Configured!**

---

## 🔎 2. Prowlarr Configuration (20 min)

### Access Prowlarr
```
URL: http://10.0.0.162:9696
```

### Step 1: Complete Setup Wizard
1. Click through welcome screens
2. **Authentication:** Set username/password
3. Click **Save**

### Step 2: Add Download Client (qBittorrent)
1. Settings → Download Clients
2. Click **+** → **qBittorrent**
3. **Configuration:**
   ```
   Name: qBittorrent
   Enable: ✓
   Host: qbittorrent (container name)
   Port: 8080
   Username: admin
   Password: [your new qBittorrent password]
   Category: (leave blank - Prowlarr doesn't use categories)
   ```
4. **Test** → **Save**

### Step 3: Add Your Indexers
1. Indexers → Add Indexer
2. **Search for your private trackers:**
   - Search: "[your tracker name]"
   - Click **+** next to your tracker
3. **For each indexer:**
   - Enable: ✓
   - Name: [tracker name]
   - URL: [tracker URL]
   - API Key: [your tracker API key]
   - Cookie: [if required]
   - **Test** → **Save**

**Common Private Trackers:**
- TorrentLeech
- IPTorrents
- PassThePopcorn (PTP)
- BroadcastTheNet (BTN)
- Add yours here...

### Step 4: Connect to *arr Apps (Do After Configuring Them)
**Skip this for now - we'll come back after Radarr/Sonarr are configured!**

### Step 5: Get Prowlarr API Key
1. Settings → General
2. **API Key:** Copy this - you'll need it for .env

✅ **Prowlarr Configured!**

---

## 🎬 3. Radarr HD Configuration (15 min)

### Access Radarr HD
```
URL: http://10.0.0.162:7878
```

### Step 1: Complete Setup Wizard
1. Click through welcome
2. **Media Management:**
   - Movie Naming: ✓ Rename Movies
   - Format: `{Movie Title} ({Release Year})`
3. Click **Next**

### Step 2: Add Root Folder
1. Settings → Media Management → Root Folders
2. Click **Add Root Folder**
3. **Path:** `/movies`
4. Click **OK**

### Step 3: Add Download Client
1. Settings → Download Clients
2. Click **+** → **qBittorrent**
3. **Configuration:**
   ```
   Name: qBittorrent
   Enable: ✓
   Host: qbittorrent
   Port: 8080
   Username: admin
   Password: [your qBittorrent password]
   Category: radarr-hd
   ```
4. **Test** → **Save**

### Step 4: Connect to Prowlarr
1. Settings → Indexers
2. **Indexers section:** Click **+** → **Prowlarr**
3. **Configuration:**
   ```
   Sync Level: Full Sync
   Prowlarr Server: http://prowlarr:9696
   API Key: [Prowlarr API key from earlier]
   ```
4. **Test** → **Save**

### Step 5: Get Radarr API Key
1. Settings → General → Security
2. **API Key:** Copy this for .env

### Step 6: Test Everything
1. Movies → Add New
2. Search for a movie
3. Select a movie
4. **Root Folder:** /movies
5. **Quality Profile:** Any (we'll fix with Recyclarr later)
6. Click **Add Movie** (but don't search/download yet!)

✅ **Radarr HD Configured!**

---

## 🎬 4. Radarr 4K Configuration (15 min)

### Access Radarr 4K
```
URL: http://10.0.0.162:7879
```

**Same process as Radarr HD, but with these differences:**

### Step 2: Add Root Folder
- **Path:** `/movies-4k` (NOT /movies!)

### Step 3: Add Download Client
- **Category:** `radarr-4k` (NOT radarr-hd!)

### Step 5: Get Radarr 4K API Key
- Copy for .env (different from Radarr HD!)

✅ **Radarr 4K Configured!**

---

## 📺 5. Sonarr HD Configuration (15 min)

### Access Sonarr HD
```
URL: http://10.0.0.162:8989
```

### Step 1: Complete Setup Wizard
1. Click through welcome
2. **Media Management:**
   - Episode Naming: ✓ Rename Episodes
   - Format: `{Series Title} - S{season:00}E{episode:00} - {Episode Title}`

### Step 2: Add Root Folder
- **Path:** `/tv`

### Step 3: Add Download Client
- **Category:** `sonarr-hd`
- (Same qBittorrent settings as before)

### Step 4: Connect to Prowlarr
- (Same Prowlarr settings as before)

### Step 5: Get Sonarr HD API Key
- Copy for .env

### Step 6: Test
1. Series → Add New
2. Search for a TV show
3. **Root Folder:** /tv
4. Click **Add Series** (don't search yet!)

✅ **Sonarr HD Configured!**

---

## 📺 6. Sonarr 4K Configuration (15 min)

### Access Sonarr 4K
```
URL: http://10.0.0.162:8990
```

**Same as Sonarr HD, but:**

### Step 2: Add Root Folder
- **Path:** `/tv-4k`

### Step 3: Add Download Client
- **Category:** `sonarr-4k`

### Step 5: Get Sonarr 4K API Key
- Copy for .env (different from Sonarr HD!)

✅ **Sonarr 4K Configured!**

---

## 🔑 7. Update .env with API Keys (5 min)

### Edit .env File

```bash
ssh mother
cd /opt/mother
nano .env
```

### Add These Lines

```bash
# ===== API KEYS (Generated during setup) =====
RADARR_HD_API_KEY=abc123...
RADARR_4K_API_KEY=def456...
SONARR_HD_API_KEY=ghi789...
SONARR_4K_API_KEY=jkl012...
PROWLARR_API_KEY=mno345...
```

**Save and exit** (Ctrl+X, Y, Enter)

✅ **API Keys Stored!**

---

## ⚙️ 8. Recyclarr Configuration (10 min)

### Recyclarr is Already Configured!

The recyclarr.yml file should already be set up. Let's verify and run the sync:

```bash
ssh mother
cd /opt/mother

# Check if recyclarr.yml exists
ls -la configs/recyclarr/recyclarr.yml

# View the configuration
cat configs/recyclarr/recyclarr.yml
```

### Run Recyclarr Sync

```bash
# Run sync to apply quality profiles
docker exec recyclarr recyclarr sync

# Watch output - should see:
# Processing radarr-hd...
# Processing radarr-4k...
# Processing sonarr-hd...
# Processing sonarr-4k...
# Sync completed!
```

### Verify in Radarr/Sonarr

1. **Open Radarr HD** → Settings → Profiles
2. Should see **HD-1080p** profile with quality settings
3. **Open Radarr 4K** → Should see **UHD-2160p** profile
4. **Open Sonarr HD** → Should see **HD-1080p** profile
5. **Open Sonarr 4K** → Should see **UHD-2160p** profile

✅ **Recyclarr Configured and Synced!**

---

## 🧪 9. Test Everything (5 min)

### Test Download Flow

1. **In Radarr HD:**
   - Movies → Add New
   - Search for a movie
   - Select movie
   - Quality Profile: **HD-1080p**
   - Click **Add Movie**
   - Click **Search** (manual search)
   - Select a release
   - Click **Grab**

2. **In qBittorrent:**
   - Should see torrent appear
   - Category: `radarr-hd`
   - Downloading to: `/downloads/radarr-hd/`

3. **After Download:**
   - Radarr should import it
   - Move to: `/movies/Movie Name (Year)/`
   - Remove from qBittorrent (if configured)

### If Test Works:
✅ **Everything is configured correctly!**

### If Test Fails:
- Check qBittorrent credentials
- Check category in qBittorrent
- Check Prowlarr indexers
- Check Radarr logs: System → Logs

---

## ✅ Configuration Complete Checklist

- [ ] qBittorrent password changed
- [ ] qBittorrent categories created
- [ ] Prowlarr indexers added
- [ ] Radarr HD configured
- [ ] Radarr 4K configured
- [ ] Sonarr HD configured
- [ ] Sonarr 4K configured
- [ ] All API keys in .env
- [ ] Recyclarr sync completed
- [ ] Test download successful

---

## 📝 Configuration Summary

### Credentials Changed
- qBittorrent: admin / [new password]

### API Keys Saved to .env
- Radarr HD API Key
- Radarr 4K API Key
- Sonarr HD API Key
- Sonarr 4K API Key
- Prowlarr API Key

### Quality Profiles Applied
- Radarr HD: HD-1080p (via Recyclarr)
- Radarr 4K: UHD-2160p (via Recyclarr)
- Sonarr HD: HD-1080p (via Recyclarr)
- Sonarr 4K: UHD-2160p (via Recyclarr)

### Download Categories
- radarr-hd → /downloads/radarr-hd
- radarr-4k → /downloads/radarr-4k
- sonarr-hd → /downloads/sonarr-hd
- sonarr-4k → /downloads/sonarr-4k

---

## 🎯 What's Next?

**While scans are still running:**
- Review this guide and fix any issues
- Test a few downloads in each category
- Verify quality profiles are working
- Check qBittorrent is organizing properly

**After scans complete:**
- Copy Ali's inventories to Mother
- Run comparison scripts
- Review reports
- Plan initial sync

---

**You now have a fully configured media management stack!** 🎉
