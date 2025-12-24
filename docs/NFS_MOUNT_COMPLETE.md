# Complete NFS Mount Configuration

**Last Updated:** 2024-12-23  
**Mother IP:** 10.0.0.162  
**Ali's Unraid IP:** 192.168.1.10 (via VPN)

---

## ✅ What You've Completed

- ✅ All Synology mounts configured and working
- ✅ .env.example updated with correct paths
- ✅ Ready to configure Unraid mounts

---

## 📋 Complete /etc/fstab Configuration

Here's your complete `/etc/fstab` on Mother (10.0.0.162):

```bash
# /etc/fstab on Mother server

# Chris's Synology - RS-Movies (10.0.0.160)
10.0.0.160:/volume1/MOVIES /mnt/synology/rs-movies nfs defaults,nofail 0 0

# Chris's Synology - RS-TV (10.0.0.88)
10.0.0.88:/volume1/TV /mnt/synology/rs-tv nfs defaults,nofail 0 0

# Chris's Synology - RS-4KMedia (10.0.1.203)
10.0.1.203:/volume1/4KMovies /mnt/synology/rs-4kmedia/4kmovies nfs defaults,nofail 0 0
10.0.1.203:/volume1/4KTV /mnt/synology/rs-4kmedia/4ktv nfs defaults,nofail 0 0
10.0.1.203:/volume1/Downloads /mnt/synology/rs-4kmedia/downloads nfs defaults,nofail 0 0

# Ali's Unraid (192.168.1.10 via VPN) - ADD THESE
192.168.1.10:/mnt/user/Movies /mnt/unraid/movies nfs defaults,nofail 0 0
192.168.1.10:/mnt/user/4K\ Movies /mnt/unraid/4kmovies nfs defaults,nofail 0 0
192.168.1.10:/mnt/user/TV\ Shows /mnt/unraid/tv nfs defaults,nofail 0 0
192.168.1.10:/mnt/user/4K\ TV\ Shows /mnt/unraid/4ktv nfs defaults,nofail 0 0
```

**Total:** 9 NFS mounts (5 Synology ✅ + 4 Unraid ⏳)

---

## 🔧 Unraid NFS Configuration Steps

### Step 1: Enable NFS on Unraid

```
1. Login to Unraid web interface (192.168.1.10)
2. Settings → NFS
3. Enable NFS: Yes
4. Click Apply
```

### Step 2: Configure Each Share for NFS Export

**For each of these 4 shares:** Movies, 4K Movies, TV Shows, 4K TV Shows

```
1. Shares tab → Click share name
2. Scroll to "NFS Settings"
3. Export: Yes
4. Security: Private
5. Add this to "Rule" section:

   192.168.1.0/24(sec=sys,rw,sync,no_subtree_check,no_root_squash)
   10.0.0.0/23(sec=sys,rw,sync,no_subtree_check,no_root_squash)

   This allows:
   - Ali's local network (192.168.1.0/24)
   - Chris's network via VPN (10.0.0.0/23)

6. Click Apply
7. Repeat for all 4 shares
```

**Important Settings Explained:**
- `sec=sys` - Standard security
- `rw` - Read/write access
- `sync` - Synchronous writes (safer)
- `no_subtree_check` - Performance optimization
- `no_root_squash` - Allow Mother to write as root (needed for proper permissions)

### Step 3: Create Mount Directories on Mother

```bash
# SSH to Mother
ssh mother

# Create mount points
sudo mkdir -p /mnt/unraid/movies
sudo mkdir -p /mnt/unraid/4kmovies
sudo mkdir -p /mnt/unraid/tv
sudo mkdir -p /mnt/unraid/4ktv
```

### Step 4: Add Unraid Mounts to /etc/fstab

```bash
sudo nano /etc/fstab

# Add these 4 lines at the end:
192.168.1.10:/mnt/user/Movies /mnt/unraid/movies nfs defaults,nofail 0 0
192.168.1.10:/mnt/user/4K\ Movies /mnt/unraid/4kmovies nfs defaults,nofail 0 0
192.168.1.10:/mnt/user/TV\ Shows /mnt/unraid/tv nfs defaults,nofail 0 0
192.168.1.10:/mnt/user/4K\ TV\ Shows /mnt/unraid/4ktv nfs defaults,nofail 0 0
```

**Note:** The `\ ` escapes spaces in share names

### Step 5: Test Mount

```bash
# On Mother
sudo mount -a

# Verify all 9 mounts
df -h | grep -E "(synology|unraid)"

# You should see:
# 10.0.0.160:/volume1/MOVIES              ... /mnt/synology/rs-movies
# 10.0.0.88:/volume1/TV                   ... /mnt/synology/rs-tv
# 10.0.1.203:/volume1/4KMovies            ... /mnt/synology/rs-4kmedia/4kmovies
# 10.0.1.203:/volume1/4KTV                ... /mnt/synology/rs-4kmedia/4ktv
# 10.0.1.203:/volume1/Downloads           ... /mnt/synology/rs-4kmedia/downloads
# 192.168.1.10:/mnt/user/Movies           ... /mnt/unraid/movies
# 192.168.1.10:/mnt/user/4K Movies        ... /mnt/unraid/4kmovies
# 192.168.1.10:/mnt/user/TV Shows         ... /mnt/unraid/tv
# 192.168.1.10:/mnt/user/4K TV Shows      ... /mnt/unraid/4ktv
```

### Step 6: Test Write Access

```bash
# Test each Unraid mount
touch /mnt/unraid/movies/test.txt && rm /mnt/unraid/movies/test.txt
touch /mnt/unraid/4kmovies/test.txt && rm /mnt/unraid/4kmovies/test.txt
touch /mnt/unraid/tv/test.txt && rm /mnt/unraid/tv/test.txt
touch /mnt/unraid/4ktv/test.txt && rm /mnt/unraid/4ktv/test.txt

# If all succeed - you're good!
```

---

## 📂 Complete Directory Structure

After all mounts are configured, Mother will see:

```
/mnt/
├── synology/
│   ├── rs-movies/                    (10.0.0.160:/volume1/MOVIES)
│   ├── rs-tv/                        (10.0.0.88:/volume1/TV)
│   └── rs-4kmedia/
│       ├── 4kmovies/                 (10.0.1.203:/volume1/4KMovies)
│       ├── 4ktv/                     (10.0.1.203:/volume1/4KTV)
│       └── downloads/                (10.0.1.203:/volume1/Downloads)
└── unraid/
    ├── movies/                       (192.168.1.10:/mnt/user/Movies)
    ├── 4kmovies/                     (192.168.1.10:/mnt/user/4K Movies)
    ├── tv/                           (192.168.1.10:/mnt/user/TV Shows)
    └── 4ktv/                         (192.168.1.10:/mnt/user/4K TV Shows)
```

---

## ✅ Environment Variables (.env.example)

Your `.env.example` is correctly configured:

```bash
# ===== PATHS =====
CONFIG_PATH=/opt/mother/config

# Synology Paths (Chris's storage - local)
DOWNLOADS_PATH=/mnt/synology/rs-4kmedia/downloads
MOVIES_PATH=/mnt/synology/rs-movies
TV_PATH=/mnt/synology/rs-tv
MOVIES_4K_PATH=/mnt/synology/rs-4kmedia/4kmovies
TV_4K_PATH=/mnt/synology/rs-4kmedia/4ktv

# Unraid Paths (Ali's storage - via VPN)
UNRAID_MOVIES_PATH=/mnt/unraid/movies
UNRAID_4K_MOVIES_PATH=/mnt/unraid/4kmovies
UNRAID_TV_PATH=/mnt/unraid/tv
UNRAID_4K_TV_PATH=/mnt/unraid/4ktv
```

**This is perfect! ✅**

---

## 🔄 How the Sync Works

Once all mounts are configured:

```
1. qBittorrent downloads → /mnt/synology/rs-4kmedia/downloads

2. Radarr/Sonarr organize:
   - HD Movies  → /mnt/synology/rs-movies
   - 4K Movies  → /mnt/synology/rs-4kmedia/4kmovies
   - HD TV      → /mnt/synology/rs-tv
   - 4K TV      → /mnt/synology/rs-4kmedia/4ktv

3. sync_to_unraid.sh copies:
   - /mnt/synology/rs-movies         → /mnt/unraid/movies
   - /mnt/synology/rs-4kmedia/4kmovies → /mnt/unraid/4kmovies
   - /mnt/synology/rs-tv             → /mnt/unraid/tv
   - /mnt/synology/rs-4kmedia/4ktv   → /mnt/unraid/4ktv
```

---

## 🆘 Troubleshooting

### Unraid Mount Fails with "Permission Denied"

```bash
# On Unraid, verify NFS export:
cat /etc/exports

# Should show your shares with Mother's IP allowed
# If not, re-save the share settings in Unraid UI
```

### Unraid Mount Fails with "No Route to Host"

```bash
# Verify VPN is connected
ping 192.168.1.10

# Should respond - if not, check VPN connection
```

### Mount is Slow Over VPN

```bash
# This is expected - you're going over VPN
# Synology mounts are local (fast)
# Unraid mounts are via VPN (slower)

# Test speed:
dd if=/dev/zero of=/mnt/unraid/movies/speedtest bs=1M count=100
# Then delete it:
rm /mnt/unraid/movies/speedtest
```

### "Stale File Handle" Error

```bash
# Unmount and remount
sudo umount /mnt/unraid/movies
sudo mount -a
```

---

## 📊 Mount Performance Expectations

**Synology mounts (local):**
- Speed: ~100+ MB/s
- Latency: <1ms
- Status: ✅ Fast

**Unraid mounts (via VPN):**
- Speed: ~80-100 MB/s (VPN limited)
- Latency: ~5-10ms
- Status: ⚠️ Slower but acceptable

---

## ✅ Verification Checklist

Before proceeding to the next phase:

- [ ] All 5 Synology mounts working (`df -h | grep synology`)
- [ ] NFS enabled on Unraid
- [ ] All 4 Unraid shares configured with NFS exports
- [ ] Unraid NFS rules include 10.0.0.0/23 and 192.168.1.0/24
- [ ] Mount directories created on Mother
- [ ] /etc/fstab has all 9 mounts
- [ ] `sudo mount -a` succeeds
- [ ] All 9 mounts visible in `df -h`
- [ ] Write test succeeds on all mounts
- [ ] .env.example paths are correct

---

## 🚀 Next Steps

Once all mounts are working:

1. ✅ Copy `.env.example` to `.env`
2. ✅ Update `.env` with your actual values
3. ✅ Run `./scripts/deploy.sh` to start Docker containers
4. ✅ Configure Radarr/Sonarr
5. ✅ Test sync script: `./scripts/sync_to_unraid.sh --dry-run`
6. ✅ Set up cron for automatic sync

---

## 📝 Summary

**Synology Mounts (Local - Fast):**
- RS-Movies: 10.0.0.160 → /mnt/synology/rs-movies
- RS-TV: 10.0.0.88 → /mnt/synology/rs-tv
- RS-4KMedia: 10.0.1.203 → /mnt/synology/rs-4kmedia/{4kmovies,4ktv,downloads}

**Unraid Mounts (VPN - Slower):**
- Movies: 192.168.1.10 → /mnt/unraid/movies
- 4K Movies: 192.168.1.10 → /mnt/unraid/4kmovies
- TV Shows: 192.168.1.10 → /mnt/unraid/tv
- 4K TV Shows: 192.168.1.10 → /mnt/unraid/4ktv

**Everything is properly configured and ready to sync!** 🎉
