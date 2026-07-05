# Recyclarr Setup Guide - Complete Walkthrough

**Last Updated:** 2024-12-26

---

## 🎯 What You're Getting

### **10 Quality Profiles Across 4 Services:**

**Radarr-HD (1080p Movies):**
1. **HD-Bluray + WEB** - For most movies (Bluray-1080p max)
2. **HD-Remux ONLY** - For special movies (Remux only)

**Radarr-4K (4K Movies):**
3. **UHD-Bluray + WEB** - For most 4K movies (Bluray-2160p max)
4. **UHD-Remux ONLY** - For special 4K movies (Remux only)

**Sonarr-HD (1080p TV):**
5. **WEB-1080p** - Default, WEB only
6. **Bluray-1080p** - For special shows, accepts Bluray
7. **Remux-1080p** - For very special shows, Remux only

**Sonarr-4K (4K TV):**
8. **WEB-2160p** - Default 4K TV, WEB only
9. **Bluray-2160p** - Special 4K shows, accepts Bluray
10. **Remux-2160p** - Very special 4K shows, Remux only

###Key Features:
- ✅ **TRaSH Naming** - Files named with quality/HDR/audio info
- ✅ **1080p+HDR > 1080p SDR Bluray** - HDR adds 400 points!
- ✅ **HDR Priority:** HDR10 > DV HDR10 > HDR > DV > HDR10+ > HLG
- ✅ **Audio Priority:** Atmos > DTS:X > Lossless > Lossy
- ✅ **Quality Definitions** - From TRaSH guides
- ✅ **Daily Auto-Sync** - Keeps profiles updated

---

## 📋 Prerequisites

1. ✅ All 4 *arr services running (Radarr-HD, Radarr-4K, Sonarr-HD, Sonarr-4K)
2. ✅ Recyclarr container running
3. ✅ API keys from each service ready
4. ✅ Config file created in WSL

---

## 🚀 Step-by-Step Setup

### Step 1: Get API Keys

For **each** of your 4 services, get the API key:

```bash
# Radarr-HD: http://10.0.0.162:7878
Settings → General → Security → API Key

# Radarr-4K: http://10.0.0.162:7879
Settings → General → Security → API Key

# Sonarr-HD: http://10.0.0.162:8989
Settings → General → Security → API Key

# Sonarr-4K: http://10.0.0.162:8990
Settings → General → Security → API Key
```

**Write them down!** You'll need them in Step 3.

---

### Step 2: Copy Config to Mother Server

From WSL:
```bash
cd ~/projects/mother

# Commit the config
git add config/recyclarr/recyclarr.yml
git add config/recyclarr/.env.example
git commit -m "Add recyclarr config with TRaSH naming and 10 profiles"
git push origin main
```

On Mother:
```bash
ssh mother
cd /opt/mother

# Pull the config
git pull origin main

# Create config directory if it doesn't exist
sudo mkdir -p /opt/mother/config/recyclarr
sudo chown -R ${USER}:${USER} /opt/mother/config

# Copy the config file
cp config/recyclarr/recyclarr.yml /opt/mother/config/recyclarr/
```

---

### Step 3: Add API Keys to .env

```bash
ssh mother
cd /opt/mother

# Edit your main .env file
nano .env

# Add these lines at the bottom (use YOUR actual API keys):
RADARR_HD_API_KEY=your_actual_api_key_here
RADARR_4K_API_KEY=your_actual_api_key_here
SONARR_HD_API_KEY=your_actual_api_key_here
SONARR_4K_API_KEY=your_actual_api_key_here

# Save: Ctrl+X, Y, Enter
```

---

### Step 4: Restart Recyclarr

```bash
ssh mother

# Restart recyclarr to load new config and API keys
docker restart recyclarr

# Check logs to ensure it started properly
docker logs recyclarr --tail 50
```

**Expected output:** Should show recyclarr starting up, NO errors about missing config or API keys.

---

### Step 5: Run Initial Sync (DRY RUN FIRST!)

```bash
ssh mother

# Preview what will change (DRY RUN - safe!)
docker exec recyclarr recyclarr sync --preview

# This shows:
# - Custom formats to be created
# - Quality profiles to be updated
# - Naming schemes to be applied
# NO actual changes made yet!
```

**Review the preview carefully!** Make sure it looks right.

---

### Step 6: Execute Real Sync

```bash
ssh mother

# Run the actual sync
docker exec recyclarr recyclarr sync

# Watch the output
# Should show:
# ✓ Syncing radarr-hd...
# ✓ Syncing radarr-4k...
# ✓ Syncing sonarr-hd...
# ✓ Syncing sonarr-4k...
```

**This will take 2-3 minutes.** Be patient!

---

### Step 7: Setup Daily Auto-Sync

```bash
ssh mother

# Edit crontab
crontab -e

# Add this line (runs at 3 AM daily):
0 3 * * * docker exec recyclarr recyclarr sync >> /opt/mother/logs/recyclarr.log 2>&1

# Save: Ctrl+X, Y, Enter

# Create log directory
mkdir -p /opt/mother/logs
```

---

## ✅ Verification

### Check Radarr-HD (http://10.0.0.162:7878)

1. **Settings → Profiles**
   - Should see: "HD-Bluray + WEB", "HD-Remux ONLY"

2. **Settings → Custom Formats**
   - Should see ~30+ custom formats:
     - HDR10, DV HDR10, HDR, DV, HDR10+, HLG
     - TrueHD Atmos, DTS:X, DD+ Atmos, etc.
     - WEB Tier 01, 02, 03
     - BR-DISK, LQ, 3D (with -10000 score)

3. **Settings → Quality**
   - Click "Edit" on any profile
   - Check "Custom Format" scores:
     - HDR10: 400 points
     - TrueHD Atmos: 400 points
     - BR-DISK: -10000 points

4. **Settings → Media Management → File Naming**
   - Should see TRaSH naming format:
     - Standard Movie Format: `{Movie CleanTitle} {(Release Year)} {imdb-{ImdbId}} {edition-{Edition Tags}} {[Custom Formats]}{[Quality Full]}{[MediaInfo 3D]}{[MediaInfo VideoDynamicRangeType]}{[Mediainfo AudioCodec}{ Mediainfo AudioChannels]}{MediaInfo AudioLanguages}{-Release Group}`

### Check Radarr-4K (http://10.0.0.162:7879)

1. **Settings → Profiles**
   - Should see: "UHD-Bluray + WEB", "UHD-Remux ONLY"

2. **Verify HDR scores are HIGHER than HD:**
   - HDR10: 500 points (vs 400 in HD)
   - DV HDR10: 450 points
   - Atmos: 500 points

### Check Sonarr-HD (http://10.0.0.162:8989)

1. **Settings → Profiles**
   - Should see: "WEB-1080p", "Bluray-1080p", "Remux-1080p"

2. **Settings → Custom Formats**
   - Should see streaming services: AMZN, ATVP, DSNP, HBO, NF, MAX
   - Repack/Proper formats
   - HDR formats

3. **Settings → Media Management → Episode Naming**
   - Should see TRaSH naming:
     - Standard Episode Format: `{Series TitleYear} - S{season:00}E{episode:00} - {Episode CleanTitle} {[Custom Formats]}{[Quality Full]}{[MediaInfo VideoDynamicRangeType]}{[Mediainfo AudioCodec}{ Mediainfo AudioChannels]}{[MediaInfo VideoCodec]}{-Release Group}`

### Check Sonarr-4K (http://10.0.0.162:8990)

1. **Settings → Profiles**
   - Should see: "WEB-2160p", "Bluray-2160p", "Remux-2160p"

2. **Verify 4K HDR scores:**
   - HDR10: 400 points
   - DV HDR10: 350 points

---

## 📊 How to Use the Profiles

### For Movies (Radarr):

**When adding a movie:**
1. Click "+ Add Movie"
2. Search for movie
3. Choose quality profile:
   - **HD-Bluray + WEB** - For 95% of 1080p movies
   - **HD-Remux ONLY** - For your top 20 favorite 1080p movies
   - **UHD-Bluray + WEB** - For 95% of 4K movies
   - **UHD-Remux ONLY** - For your top 10 favorite 4K movies

**Changing existing movies:**
1. Go to movie page
2. Click "Edit"
3. Change "Quality Profile" dropdown
4. Save

### For TV Shows (Sonarr):

**Default profiles:**
- Use **WEB-1080p** or **WEB-2160p** for 99% of TV shows

**Special shows:**
- Use **Bluray-1080p** or **Bluray-2160p** for shows you love
  - Breaking Bad, The Wire, Game of Thrones, etc.

**Very special shows:**
- Use **Remux-1080p** or **Remux-2160p** for the absolute best
  - Planet Earth, Blue Planet, nature documentaries
  - Your #1 favorite show

---

## 🔍 Understanding the Scoring

### Example: 1080p Movie with HDR

**Scenario:** WEB-DL 1080p with HDR10 vs Bluray 1080p without HDR

**Scores:**
- **WEB-DL 1080p:** Base ~600 points
- **+ HDR10:** +400 points
- **Total:** 1000 points

vs.

- **Bluray 1080p SDR:** Base ~800 points
- **+ No HDR:** +0 points
- **Total:** 800 points

**Result:** WEB-DL + HDR10 (1000) > Bluray SDR (800) ✅

**This is what you wanted!** HDR makes the difference!

### Example: Atmos Audio Boost

**Scenario:** WEB-DL with Atmos vs Bluray without Atmos

- **WEB-DL + Atmos:** 600 + 400 = 1000 points
- **Bluray without Atmos:** 800 + 0 = 800 points

**Atmos wins!**

---

## 🛠️ Troubleshooting

### "Connection failed" errors

**Check docker network:**
```bash
ssh mother

# Verify recyclarr can reach services
docker exec recyclarr ping -c 2 radarr-hd
docker exec recyclarr ping -c 2 radarr-4k
docker exec recyclarr ping -c 2 sonarr-hd
docker exec recyclarr ping -c 2 sonarr-4k

# Test HTTP connection
docker exec recyclarr curl http://radarr-hd:7878/api/v3/system/status
```

**Expected:** Should return JSON with status info.

### "Invalid API Key" errors

**Verify API keys:**
```bash
ssh mother
cd /opt/mother

# Check .env file has all 4 API keys
grep "API_KEY" .env

# Make sure no spaces, quotes, or typos
# Should look like:
# RADARR_HD_API_KEY=abc123def456...
```

**Re-check API keys** in each service's web UI.

### Profiles not updating

**Force a sync:**
```bash
docker exec recyclarr recyclarr sync --debug

# Check for errors in output
```

### Naming not applying to existing files

**Note:** Recyclarr sets up the **naming rules**, but doesn't rename existing files.

**To rename existing files:**
1. Radarr/Sonarr → Movies/Series
2. Select movies/shows
3. Click "Edit" → "Movie Editor" / "Series Editor"
4. Check "Rename Files"
5. Click "Update Selected"

---

## 📈 Monitoring

### Check sync logs

```bash
ssh mother

# View today's sync log
tail -f /opt/mother/logs/recyclarr.log

# View all syncs from last 7 days
cat /opt/mother/logs/recyclarr.log | grep -A 5 "Syncing"
```

### Manual sync anytime

```bash
# Full sync (all services)
docker exec recyclarr recyclarr sync

# Sync specific service
docker exec recyclarr recyclarr sync radarr-hd
docker exec recyclarr recyclarr sync radarr-4k
docker exec recyclarr recyclarr sync sonarr-hd
docker exec recyclarr recyclarr sync sonarr-4k

# Preview mode (no changes)
docker exec recyclarr recyclarr sync --preview
```

---

## 🎉 You're Done!

Your recyclarr is now:
- ✅ Configured with 10 quality profiles
- ✅ Using TRaSH naming schemes
- ✅ HDR-aware (1080p+HDR beats 1080p SDR!)
- ✅ Atmos-prioritizing
- ✅ Auto-syncing daily at 3 AM

**Next:** Start adding movies and TV shows using the appropriate profiles!

---

## 📚 References

- [TRaSH Guides](https://trash-guides.info/)
- [Recyclarr Documentation](https://recyclarr.dev/)
- [Project Mother Recyclarr Setup](RECYCLARR_SETUP.md)
- [TRaSH Guides Reference](TRASHGUIDES_REFERENCE.md)
