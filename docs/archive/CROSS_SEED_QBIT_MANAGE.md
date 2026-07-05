# cross-seed + qbit-manage Configuration Guide
**Updated:** 2024-12-25
**Status:** To be implemented after core services configured

---

## 🎯 Overview

This document covers the setup and configuration of:
1. **cross-seed** - Automated cross-seeding to multiple trackers using hardlinks
2. **qbit-manage** - Automated torrent management with 120-day retention

**Key Benefits:**
- ✅ Build ratio on multiple trackers from ONE download (via hardlinks)
- ✅ ZERO additional disk space (hardlinks share the same data)
- ✅ Automated 120-day torrent removal
- ✅ Smart deletion that respects hardlinks (won't delete media files)
- ✅ RecycleBin safety net for accidental deletions

---

## 📚 Critical Concepts

### What Are Hardlinks?

**Definition:** A hardlink is a directory entry that points to the same physical data on disk.

**Example:**
```
Original file:     /downloads/movie.mkv (50GB)
Hardlink 1:        /movies/Movie (2023)/movie.mkv (0GB additional!)
Hardlink 2:        /downloads/cross-seed/movie.mkv (0GB additional!)

Total disk space: 50GB (NOT 150GB!)
```

**Key Properties:**
- Multiple filenames point to the SAME data
- Deleting one hardlink does NOT delete the data
- Data is only deleted when ALL hardlinks are removed
- Only works within the same filesystem/mount

**Why This Matters:**
- cross-seed can create torrents pointing to the same file
- You seed to multiple trackers WITHOUT duplicating data
- Triple your upload ratio from the same disk space!

---

## 🌱 cross-seed Setup

### Purpose
Automatically find and add cross-seeds across multiple trackers for torrents you already have.

### How It Works
```
1. You download Movie.mkv from TorrentLeech
         ↓
2. cross-seed monitors new downloads
         ↓
3. Searches Prowlarr indexers for same file
         ↓
4. Finds it on IPTorrents and PassThePopcorn
         ↓
5. Creates HARDLINKS in cross-seed directory
         ↓
6. Adds torrents to qBittorrent
         ↓
7. You're now seeding to 3 trackers (same file!)
         ↓
8. Upload counts for ALL trackers = HUGE ratio boost
```

### Docker Compose Configuration

**Already deployed! Just needs configuration.**

```yaml
cross-seed:
  image: ghcr.io/cross-seed/cross-seed:latest
  container_name: cross-seed
  user: 1000:1000
  volumes:
    - ${CONFIG_PATH}/cross-seed:/config
    - /downloads:/downloads  # qBittorrent download dir
    - /cross-seeds:/cross-seeds  # Where hardlinks are created
  ports:
    - 2468:2468
  restart: unless-stopped
  networks:
    - mother_network
```

### Configuration File: config.js

**Location:** `/opt/mother/configs/cross-seed/config.js`

```javascript
module.exports = {
  // Daemon mode - runs continuously
  daemon: true,
  
  // Prowlarr connection
  prowlarrUrl: "http://prowlarr:9696",
  prowlarrApiKey: "YOUR_PROWLARR_API_KEY",
  
  // qBittorrent connection
  qbittorrentUrl: "http://qbittorrent:8080",
  qbittorrentUsername: "MuThur",
  qbittorrentPassword: "YOUR_PASSWORD",
  
  // Paths - CRITICAL FOR HARDLINKS!
  torrentDir: "/downloads/torrents",  // Where qBit saves .torrent files
  outputDir: "/cross-seeds",  // Where new .torrents go
  
  // Linking - MUST USE HARDLINKS!
  linkType: "hardlink",  // "hardlink", NOT "copy"!
  linkDirs: ["/cross-seeds"],  // Where hardlinked files are created
  
  // Data directories - where original files are
  dataDirs: [
    "/downloads/radarr-hd",
    "/downloads/radarr-4k",
    "/downloads/sonarr-hd",
    "/downloads/sonarr-4k"
  ],
  
  // Matching - use "flexible" or "partial" for renamed media
  matchMode: "partial",  // Most thorough matching
  
  // When to search
  searchCadence: "24h",  // Search every 24 hours
  
  // Filtering
  excludeOlder: "30d",  // Don't search torrents older than 30 days
  excludeRecentSearch: "7d",  // Don't re-search recently searched
  
  // Include episodes and season packs
  includeEpisodes: true,
  includeSingleEpisodes: true,
  
  // Exclude non-video files
  includeNonVideos: false,
  
  // Notifications (optional)
  notificationWebhookUrl: null,  // Add webhook if desired
  
  // Verbose logging for troubleshooting
  verbose: true,
  
  // Port for web UI
  port: 2468,
};
```

### Critical Path Requirements

**For hardlinks to work, ALL paths must be in the SAME Docker volume!**

❌ **WRONG - Will NOT work:**
```yaml
volumes:
  - /downloads:/downloads
  - /different/path:/cross-seeds  # Different filesystem!
```

✅ **CORRECT - Will work:**
```yaml
volumes:
  - /data:/data  # Single mount containing everything
  # Then reference subdirectories in config
```

**Best practice:** Use a single parent directory mount:
```yaml
volumes:
  - /mnt/user/data:/data
  
# Then in config.js:
dataDirs: [
  "/data/downloads/radarr-hd",
  "/data/downloads/radarr-4k"
]
linkDirs: ["/data/cross-seeds"]
```

### Testing cross-seed

```bash
# SSH to Mother
ssh mother

# Check cross-seed logs
docker logs cross-seed -f

# Look for:
# - "Connected to qBittorrent"
# - "Connected to Prowlarr"
# - "Searching for cross-seeds..."

# Trigger manual search
docker exec cross-seed cross-seed search

# Check if hardlinks are created
ls -lhi /cross-seeds/
# Note: Files with same inode number are hardlinks!

# Verify in qBittorrent
# Should see new torrents with "cross-seed" tag
```

---

## 🛠️ qbit-manage Setup

### Purpose
Automate qBittorrent maintenance:
- Remove torrents after 120 days
- Detect hardlinks (won't delete media files)
- RecycleBin for safety
- Tag torrents without hardlinks
- Clean up orphaned files

### Why This is Safe

**Hardlink Detection:**
```
qbit-manage checks if torrent files have hardlinks:

Movie downloaded to /downloads/radarr-hd/Movie.mkv
  ↓
Radarr imports to /movies/Movie (2023)/Movie.mkv (HARDLINK!)
  ↓
qbit-manage checks: "Does this file have hardlinks outside /downloads?"
  ↓
YES! Found hardlink in /movies/
  ↓
Tags torrent as "HAS HARDLINKS"
  ↓
After 120 days, removes TORRENT but keeps file
  ↓
Movie still plays in Plex! ✓
```

**Without hardlink:**
```
Torrent in /downloads/ with NO hardlink to /movies/
  ↓
qbit-manage tags as "noHL" (no hardlinks)
  ↓
After 30 days (shorter time), removes torrent AND deletes file
  ↓
Safe to delete because file isn't in media library
```

### Docker Compose Addition

```yaml
qbit-manage:
  image: ghcr.io/stuffanthings/qbit_manage:latest
  container_name: qbit-manage
  environment:
    - QBT_RUN=false  # Set true after testing!
    - QBT_SCHEDULE=60  # Run every 60 minutes
    - QBT_CONFIG=config.yml
    - QBT_LOGFILE=activity.log
    - QBT_DRY_RUN=true  # ALWAYS START IN DRY RUN MODE!
    - QBT_LOG_LEVEL=INFO
    - QBT_CAT_UPDATE=true
    - QBT_TAG_UPDATE=true
    - QBT_REM_UNREGISTERED=true
    - QBT_TAG_NOHARDLINKS=true
    - QBT_SKIP_RECYCLE=false
  volumes:
    - ${CONFIG_PATH}/qbit-manage:/config
    - /downloads:/downloads  # MUST match qBittorrent mount!
    - /movies:/movies  # For hardlink detection
    - /tv:/tv  # For hardlink detection
    - /movies-4k:/movies-4k
    - /tv-4k:/tv-4k
  restart: unless-stopped
  networks:
    - mother_network
```

### Configuration File: config.yml

**Location:** `/opt/mother/configs/qbit-manage/config.yml`

```yaml
# qBittorrent connection
qbt:
  host: "qbittorrent:8080"
  user: "MuThur"
  pass: "YOUR_PASSWORD"

# Directories
directory:
  # Root directory for downloads
  root_dir: /downloads
  
  # Remote directory mapping (if needed)
  remote_dir: /downloads
  
  # Where qBittorrent stores .torrent files
  torrents_dir: /downloads/torrents
  
  # RecycleBin location
  recycle_bin: /downloads/.RecycleBin

# Categories
cat:
  radarr-hd: /downloads/radarr-hd
  radarr-4k: /downloads/radarr-4k
  sonarr-hd: /downloads/sonarr-hd
  sonarr-4k: /downloads/sonarr-4k
  cross-seed: /cross-seeds

# Trackers
tracker:
  torrentleech:
    tag: tl
  iptorrents:
    tag: ipt
  passthepopcorn:
    tag: ptp
  broadcastthenet:
    tag: btn
  # Add your trackers here

# Hardlink detection
nohardlinks:
  enabled: true
  
  # Ignore hardlinks within the same root_dir
  # This is CRITICAL - we want to detect hardlinks OUTSIDE /downloads
  ignore_root_dir: true
  
  # Tag torrents without hardlinks
  tag: noHL
  
  # Exclude certain tags from hardlink checking
  exclude_tags:
    - permaseed
    - manual

# Share limits - 120 day removal with hardlink protection
share_limits:
  # Global suffix for tagging
  tag_suffix: .SL
  
  groups:
    # Group 1: Movies WITH hardlinks (safe to keep longer)
    movies_hardlinked:
      priority: 10
      
      # Match criteria
      include_all_tags:
        - radarr-hd
        - radarr-4k
      exclude_tags:
        - noHL  # Exclude torrents without hardlinks
        - permaseed
      
      # Share limits
      max_seeding_time: 10368000  # 120 days in seconds
      min_seeding_time: 259200  # 3 days minimum (tracker rules)
      
      # What to do when limit reached
      cleanup: true  # Remove torrent
      resume_torrent_after_change: true
      add_group_to_tag: true
    
    # Group 2: Movies WITHOUT hardlinks (more aggressive)
    movies_no_hardlinks:
      priority: 20
      
      include_all_tags:
        - radarr-hd
        - radarr-4k
        - noHL  # Only torrents without hardlinks
      exclude_tags:
        - permaseed
      
      max_seeding_time: 2592000  # 30 days (shorter!)
      min_seeding_time: 259200
      cleanup: true
      resume_torrent_after_change: true
      add_group_to_tag: true
    
    # Group 3: TV Shows WITH hardlinks
    tv_hardlinked:
      priority: 30
      
      include_all_tags:
        - sonarr-hd
        - sonarr-4k
      exclude_tags:
        - noHL
        - permaseed
      
      max_seeding_time: 10368000  # 120 days
      min_seeding_time: 259200
      cleanup: true
      resume_torrent_after_change: true
      add_group_to_tag: true
    
    # Group 4: TV Shows WITHOUT hardlinks
    tv_no_hardlinks:
      priority: 40
      
      include_all_tags:
        - sonarr-hd
        - sonarr-4k
        - noHL
      exclude_tags:
        - permaseed
      
      max_seeding_time: 2592000  # 30 days
      min_seeding_time: 259200
      cleanup: true
      resume_torrent_after_change: true
      add_group_to_tag: true
    
    # Group 5: Cross-seeds (aggressive - many sources)
    cross_seeds:
      priority: 50
      
      include_all_tags:
        - cross-seed
      exclude_tags:
        - permaseed
      
      max_seeding_time: 5184000  # 60 days
      min_seeding_time: 259200
      cleanup: true
      resume_torrent_after_change: true
      add_group_to_tag: true

# RecycleBin configuration
recyclebin:
  enabled: true
  
  # Keep deleted files for 30 days before permanent deletion
  empty_after_x_days: 30
  
  # Save .torrent files before deletion (for recovery)
  save_torrents: true
  
  # Split recycle bin by category
  split_by_category: true

# Orphaned file cleanup
orphaned:
  enabled: true
  
  # Files in /downloads not referenced by any torrent
  # Keep for 7 days before deletion
  empty_after_x_days: 7
  
  # Exclude patterns
  exclude_patterns:
    - "*.partial"
    - "*.!qB"
    - ".DS_Store"
    - "Thumbs.db"
```

### Time Calculations

```
120 days = 10,368,000 seconds
90 days = 7,776,000 seconds
60 days = 5,184,000 seconds
30 days = 2,592,000 seconds
7 days = 604,800 seconds
3 days = 259,200 seconds
1 day = 86,400 seconds
```

### Testing Process

**CRITICAL: Start in DRY RUN mode!**

```bash
# 1. Deploy with DRY_RUN=true
docker compose up -d qbit-manage

# 2. Check logs
docker logs qbit-manage -f

# Look for:
# - "DRY RUN MODE - No changes will be made"
# - List of torrents that WOULD be removed
# - Hardlink detection results

# 3. Review what it wants to do
# Check if it's detecting hardlinks correctly
# Verify it's not deleting anything important

# 4. If everything looks good, disable dry run
nano /opt/mother/.env
# Change QBT_DRY_RUN=false

# 5. Restart
docker compose restart qbit-manage

# 6. Monitor closely for first week
docker logs qbit-manage -f

# 7. Check RecycleBin
ls -lh /downloads/.RecycleBin/
# Files should appear here, not immediately deleted
```

---

## 📊 Complete Workflow Example

### Scenario: Download Movie from TorrentLeech

```
Day 0: Download & Import
━━━━━━━━━━━━━━━━━━━━━━━
1. Radarr grabs from TorrentLeech
   → /downloads/radarr-hd/Movie.2023.1080p.mkv (50GB)
   
2. Radarr imports to library
   → /movies/Movie (2023)/Movie.2023.1080p.mkv (HARDLINK, 0GB additional!)
   
3. qbit-manage tags:
   → Checks hardlinks
   → Finds /movies/ hardlink
   → Does NOT tag as "noHL"
   
Total disk: 50GB

Day 1: cross-seed Finds It
━━━━━━━━━━━━━━━━━━━━━━━
4. cross-seed searches Prowlarr
   → Finds same file on IPTorrents
   → Creates hardlink: /cross-seeds/Movie.2023.1080p.mkv (0GB additional!)
   → Adds torrent to qBittorrent with "cross-seed" tag
   
5. Same for PassThePopcorn
   → /cross-seeds/Movie.2023.ptp.mkv (0GB additional!)
   
Total disk: STILL 50GB (3 torrents, 1 file!)

Days 2-119: Seeding
━━━━━━━━━━━━━━━━━━━━━━━
6. All 3 torrents seed:
   - TorrentLeech: +25GB uploaded
   - IPTorrents: +30GB uploaded
   - PassThePopcorn: +45GB uploaded
   
Total upload: 100GB
Total disk used: 50GB
Ratio gain: 2.0x from disk space!

Day 120: Automated Cleanup
━━━━━━━━━━━━━━━━━━━━━━━
7. qbit-manage runs:
   
   TorrentLeech torrent:
   - Seeding time: 120 days ✓
   - Has hardlink in /movies/ ✓
   - Action: Remove TORRENT only
   - Result: Torrent removed, file kept
   
   IPTorrents torrent:
   - Seeding time: 119 days
   - Has hardlink in /movies/ ✓
   - Action: Wait 1 more day
   
   PassThePopcorn torrent:
   - Seeding time: 119 days
   - Has hardlink in /movies/ ✓
   - Action: Wait 1 more day

Day 121: Cleanup Complete
━━━━━━━━━━━━━━━━━━━━━━━
8. All torrents removed
9. /downloads/ cleaned up
10. /movies/Movie (2023)/ still exists ✓
11. Movie still plays in Plex ✓
12. Disk space: Still 50GB (file not deleted!)
```

---

## ✅ Implementation Checklist

### Prerequisites
- [ ] qBittorrent configured with categories
- [ ] Prowlarr configured with indexers
- [ ] Radarr/Sonarr importing media to library folders
- [ ] All paths in same Docker volume/mount

### cross-seed Setup
- [ ] Verify cross-seed container running
- [ ] Create config.js with correct paths
- [ ] Verify linkType is "hardlink"
- [ ] Test Prowlarr connection
- [ ] Test qBittorrent connection
- [ ] Run manual search: `docker exec cross-seed cross-seed search`
- [ ] Verify hardlinks created (check inode numbers)
- [ ] Verify torrents added to qBittorrent
- [ ] Monitor for 1 week

### qbit-manage Setup
- [ ] Add to docker-compose.yml
- [ ] Create config.yml
- [ ] Set QBT_DRY_RUN=true
- [ ] Deploy container
- [ ] Review dry run logs
- [ ] Verify hardlink detection working
- [ ] Verify RecycleBin configured
- [ ] Set QBT_DRY_RUN=false (after testing!)
- [ ] Monitor for 2 weeks
- [ ] Verify no important files deleted
- [ ] Check RecycleBin regularly

### Monitoring
- [ ] Set up log monitoring
- [ ] Check disk space weekly
- [ ] Verify ratio building on trackers
- [ ] Monitor RecycleBin size
- [ ] Document any issues

---

## 🚨 Troubleshooting

### cross-seed Issues

**Problem: "Error linking file"**
```bash
# Check if paths are in same mount
df -h /downloads
df -h /cross-seeds
# Should show same filesystem

# Verify Docker volumes
docker inspect cross-seed | grep -A 10 Mounts
```

**Problem: No cross-seeds found**
```bash
# Check Prowlarr connection
docker exec cross-seed cross-seed test prowlarr

# Check if indexers are configured
# Open Prowlarr → Indexers
# Must have at least 2 indexers

# Try manual search
docker exec cross-seed cross-seed search --verbose
```

### qbit-manage Issues

**Problem: Deleting wrong files**
```bash
# STOP IMMEDIATELY
docker compose stop qbit-manage

# Check what it deleted
ls -lh /downloads/.RecycleBin/

# Restore from RecycleBin
mv /downloads/.RecycleBin/filename /downloads/radarr-hd/

# Fix config.yml
# Increase min_seeding_time
# Check hardlink detection settings
```

**Problem: Not detecting hardlinks**
```bash
# Manually check hardlinks
ls -lhi /downloads/radarr-hd/movie.mkv
ls -lhi /movies/Movie\ \(2023\)/movie.mkv
# Same inode number = hardlinked ✓
# Different inode = NOT hardlinked ✗

# Check config.yml
# Verify ignore_root_dir: true
# Verify mount paths match

# Check logs
docker logs qbit-manage | grep -i hardlink
```

---

## 📝 Summary

**What This Achieves:**

1. **Maximum Ratio Building**
   - One download = multiple tracker uploads
   - Zero additional disk space
   - Automated cross-seeding

2. **Smart Cleanup**
   - Remove torrents after 120 days
   - Preserve media files (hardlink detection)
   - RecycleBin safety net

3. **Set and Forget**
   - Runs automatically every hour
   - No manual intervention needed
   - Notifications for issues

**Disk Space:**
- WITHOUT this setup: Download same movie 3 times = 150GB
- WITH this setup: Download once, hardlink twice = 50GB
- **Space savings: 100GB per movie!**

**Ratio Building:**
- WITHOUT: Upload 50GB to 1 tracker = 1.0 ratio
- WITH: Upload 50GB to 3 trackers = 3.0 ratio
- **3x ratio improvement!**

---

**This is the optimal setup for private tracker users with limited disk space!** 🎯
