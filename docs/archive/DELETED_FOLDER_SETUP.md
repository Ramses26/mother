# Setup Deleted Folders - Quick Guide

**Date:** 2024-12-26  
**Purpose:** Create Deleted folder structure for safe media syncing

---

## 📊 Your Actual NFS Mounts (Verified)

```
HD Movies:     10.0.0.160:/volume1/MOVIES     → /mnt/synology/rs-movies
HD TV:         10.0.0.88:/volume1/TV          → /mnt/synology/rs-tv
4K Movies:     10.0.1.203:/volume1/4KMovies   → /mnt/synology/rs-4kmedia/4kmovies
4K TV:         10.0.1.203:/volume1/4KTV       → /mnt/synology/rs-4kmedia/4ktv
Downloads:     10.0.1.203:/volume1/Downloads  → /mnt/synology/rs-4kmedia/downloads
Ali's Unraid:  192.168.1.10:/mnt/user/Media   → /mnt/unraid/media
```

---

## 🗂️ Deleted Folder Strategy

### Centralized on 10.0.1.203 (Most Space: 184TB Free)

All Chris's deleted files will go to **one location** on 10.0.1.203:
```
/mnt/synology/rs-4kmedia/delete/
├── movies/      ← Replaced HD movies (from 10.0.0.160)
├── 4kmovies/    ← Replaced 4K movies (from 10.0.1.203)
├── tvshows/     ← Replaced HD TV (from 10.0.0.88)
└── 4ktvshows/   ← Replaced 4K TV (from 10.0.1.203)
```

**Why centralized?**
- ✅ All deleted files in one place
- ✅ 10.0.1.203 has most free space (184TB vs 72TB and 53TB)
- ✅ Easy to manage and review
- ✅ One mount point to configure

---

## 🚀 Setup Steps

### Step 1: Create Folder on Synology 10.0.1.203

**Option A: Via SSH to Synology**
```bash
# SSH to Synology 10.0.1.203
ssh admin@10.0.1.203

# Create folder structure
sudo mkdir -p /volume1/Deleted/{movies,4kmovies,tvshows,4ktvshows}

# Set permissions
sudo chmod 755 /volume1/Deleted
sudo chmod 755 /volume1/Deleted/*

# Verify
ls -la /volume1/Deleted/
```

**Option B: Via Synology Web UI**
1. Login to http://10.0.1.203:5000
2. File Station → volume1
3. Right-click → Create → Create Folder → "Deleted"
4. Inside "Deleted", create subfolders:
   - movies
   - 4kmovies
   - tvshows
   - 4ktvshows

---

### Step 2: Create NFS Share on Synology 10.0.1.203

**Via Synology Web UI:**

1. **Control Panel → Shared Folder**
2. **Create** → Name: "Deleted"
3. **Location:** volume1
4. **Click Edit → NFS Permissions**
5. **Create** NFS rule:
   ```
   Server or IP: 10.0.0.162
   Privilege: Read/Write
   Squash: No mapping
   Security: sys
   Allow async: Yes
   Allow connections from non-privileged ports: Yes
   Allow users to access mounted subfolders: Yes
   ```
6. **Click OK**

---

### Step 3: Mount on Mother Server

```bash
ssh mother

# Create mount point
sudo mkdir -p /mnt/synology/rs-4kmedia/delete

# Add to /etc/fstab
echo "10.0.1.203:/volume1/Deleted /mnt/synology/rs-4kmedia/delete nfs defaults,nofail 0 0" | sudo tee -a /etc/fstab

# Mount it
sudo mount -a

# Verify it's mounted
df -h | grep delete
```

**Expected output:**
```
10.0.1.203:/volume1/Deleted  192T  8.4T  184T   5% /mnt/synology/rs-4kmedia/delete
```

---

### Step 4: Verify Structure

```bash
ssh mother

# Check the mount
ls -la /mnt/synology/rs-4kmedia/delete/

# Should show:
# drwxr-xr-x movies
# drwxr-xr-x 4kmovies
# drwxr-xr-x tvshows
# drwxr-xr-x 4ktvshows
```

---

### Step 5: Create Deleted Folders on Ali's Unraid

**SSH to Terminus (Ali's Unraid):**
```bash
ssh terminus

# Create structure
mkdir -p /mnt/user/Media/Deleted/{Movies,4kMovies,tvshows,4ktvshows}

# Verify
ls -la /mnt/user/Media/Deleted/
```

**Or if accessing from Mother (via NFS):**
```bash
ssh mother

# Create via NFS mount
mkdir -p /mnt/unraid/media/Deleted/{Movies,4kMovies,tvshows,4ktvshows}

# Verify
ls -la /mnt/unraid/media/Deleted/
```

---

## ✅ Verification Checklist

Run these commands on Mother to verify everything:

```bash
ssh mother

echo "=== Checking Deleted folder mounts ==="

# Check Chris's deleted folder (centralized on 10.0.1.203)
echo "Chris's Deleted folder:"
ls -la /mnt/synology/rs-4kmedia/delete/
df -h /mnt/synology/rs-4kmedia/delete/

echo ""
echo "Ali's Deleted folder:"
ls -la /mnt/unraid/media/Deleted/
df -h /mnt/unraid/media/Deleted/

echo ""
echo "=== All mounts ==="
df -h | grep -E "(10.0|192.168)"
```

**Expected output:**
```
Chris's Deleted folder:
drwxr-xr-x movies
drwxr-xr-x 4kmovies
drwxr-xr-x tvshows
drwxr-xr-x 4ktvshows
10.0.1.203:/volume1/Deleted  192T  8.4T  184T   5% /mnt/synology/rs-4kmedia/delete

Ali's Deleted folder:
drwxr-xr-x Movies
drwxr-xr-x 4kMovies
drwxr-xr-x tvshows
drwxr-xr-x 4ktvshows
192.168.1.10:/mnt/user/Media  100T   50T   50T  50% /mnt/unraid/media
```

---

## 🎯 Summary

**Created:**
1. ✅ `/volume1/Deleted` on Synology 10.0.1.203
2. ✅ NFS share for `/volume1/Deleted`
3. ✅ Mount at `/mnt/synology/rs-4kmedia/delete` on Mother
4. ✅ Subfolders: movies, 4kmovies, tvshows, 4ktvshows
5. ✅ Deleted folders on Ali's Unraid

**Result:**
- All Chris's deleted files → `/mnt/synology/rs-4kmedia/delete/`
- All Ali's deleted files → `/mnt/unraid/media/Deleted/`
- Centralized, easy to manage, 184TB of space available

**Next Steps:**
1. Test sync with `--dry-run`
2. Verify files would go to correct Deleted folders
3. Execute real sync
4. Review Deleted folders periodically
5. Delete old files manually when satisfied

---

## 🔧 Troubleshooting

### Mount fails with "permission denied"
```bash
# Check NFS export on Synology
ssh admin@10.0.1.203
cat /etc/exports | grep Deleted

# Should include: /volume1/Deleted 10.0.0.162(rw,async,no_wdelay,...)
```

### Can't create files in Deleted folder
```bash
# Check permissions
ssh mother
touch /mnt/synology/rs-4kmedia/delete/test.txt

# If fails, check Synology NFS permissions
# Ensure "Read/Write" is enabled for 10.0.0.162
```

### Folder doesn't auto-mount on reboot
```bash
# Check fstab
cat /etc/fstab | grep Deleted

# Should have:
# 10.0.1.203:/volume1/Deleted /mnt/synology/rs-4kmedia/delete nfs defaults,nofail 0 0
```

---

**Ready to sync with Deleted folder protection! 🚀**
