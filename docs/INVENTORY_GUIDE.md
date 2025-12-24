# Running Inventory Generation - Quick Guide

**Last Updated:** 2024-12-23

---

## 🎯 Where to Run

### Option 1: Split Approach (RECOMMENDED - FASTEST)

**Run Ali's inventories on Terminus** (local to Unraid):
- ✅ LOCAL access to Unraid (super fast)
- ✅ No VPN overhead
- ✅ Estimated time: 4-6 hours for all 4 libraries

**Run Chris's inventories on Mother** (local to Synology):
- ✅ LOCAL access to Synology (super fast)
- ✅ No VPN overhead
- ✅ Estimated time: 4-6 hours for all 4 libraries

**Then copy Ali's results to Mother for comparison.**

### Option 2: All on Mother (Slower)

**Run everything on Mother server**:
- ✅ Direct access to Chris's Synology (fast)
- ⚠️ VPN access to your Unraid (slower)
- ⏱️ Estimated time: 1-2 days for all 8 libraries

**Recommended:** Use Option 1 for much faster results!

---

## ⏱️ Expected Time

### Without Hashing (Recommended):
- **Per library**: 6-12 hours
- **All 8 libraries**: 1-2 days total
- **Why so long?**: 159 TB, tens of thousands of files, mediainfo extraction

### With Hashing (NOT Recommended):
- **Per library**: Could be WEEKS
- **Total**: Could be MONTHS
- **Why avoid**: MD5 hashing 159 TB is extremely slow and unnecessary

### The scripts have hashing DISABLED by default for this reason!

---

## 📋 Prerequisites on Mother

```bash
# 1. Install Python dependencies
pip3 install tqdm

# 2. Install mediainfo (HIGHLY RECOMMENDED)
sudo apt install mediainfo

# 3. Make scripts executable
chmod +x /opt/mother/scripts/*.sh
chmod +x /opt/mother/scripts/*.py

# 4. Verify storage mounts
df -h | grep -E "(unraid|synology)"

# You should see:
# /mnt/unraid             (Ali's Unraid via NFS/SMB)
# /mnt/synology/rs-movies (Chris's Movies)
# /mnt/synology/rs-tv     (Chris's TV)
# /mnt/synology/rs-4kmedia (Chris's 4K content)
```

---

## 🚀 Running the Inventories

### Method 1: Split Approach (FASTEST - Recommended)

**On Terminus (Ali's libraries):**

```bash
# SSH to Terminus
ssh terminus

# Copy the script from Mother project
scp mother:/opt/mother/scripts/generate_inventory.py ~/

# Install dependencies if needed
pip3 install tqdm
sudo apt install mediainfo

# Create output directory
mkdir -p ~/inventories

# Use screen
screen -S inventory

# Run for Ali's 4 libraries
python3 ~/generate_inventory.py \
  /mnt/user/Movies \
  -o ~/inventories/ali_movies

python3 ~/generate_inventory.py \
  "/mnt/user/4K Movies" \
  -o ~/inventories/ali_4kmovies

python3 ~/generate_inventory.py \
  "/mnt/user/TV Shows" \
  -o ~/inventories/ali_tv

python3 ~/generate_inventory.py \
  "/mnt/user/4K TV Shows" \
  -o ~/inventories/ali_4ktv

# Detach: Ctrl+A, D
```

**On Mother (Chris's libraries):**

```bash
# SSH to Mother
ssh mother

# Use screen
screen -S inventory

# Run for Chris's 4 libraries
cd /opt/mother

python3 scripts/generate_inventory.py \
  /mnt/synology/rs-movies/movies \
  -o /opt/mother/inventories/chris_movies

python3 scripts/generate_inventory.py \
  /mnt/synology/rs-4kmedia/4kmovies \
  -o /opt/mother/inventories/chris_4kmovies

python3 scripts/generate_inventory.py \
  /mnt/synology/rs-tv/tv \
  -o /opt/mother/inventories/chris_tv

python3 scripts/generate_inventory.py \
  /mnt/synology/rs-4kmedia/4ktv \
  -o /opt/mother/inventories/chris_4ktv

# Detach: Ctrl+A, D
```

**Copy Ali's results to Mother:**

```bash
# From Terminus, copy to Mother
scp ~/inventories/ali_*.{json,csv} mother:/opt/mother/inventories/
```

### Method 2: All on Mother (Automated)

```bash
# Use screen to run in background
screen -S inventory

# Run the comprehensive inventory script
cd /opt/mother
./scripts/run_all_inventories.sh

# This will generate all 8 inventories (takes longer due to VPN):
# - ali_movies.json/csv
# - ali_4kmovies.json/csv
# - ali_tv.json/csv
# - ali_4ktv.json/csv
# - chris_movies.json/csv
# - chris_4kmovies.json/csv
# - chris_tv.json/csv
# - chris_4ktv.json/csv

# Detach from screen: Ctrl+A, then D
# Reattach later: screen -r inventory
```

### Method 3: Manual (One at a Time)

```bash
# Ali's HD Movies
python3 scripts/generate_inventory.py \
  /mnt/unraid/Movies \
  -o /opt/mother/inventories/ali_movies

# Ali's 4K Movies
python3 scripts/generate_inventory.py \
  "/mnt/unraid/4K Movies" \
  -o /opt/mother/inventories/ali_4kmovies

# Ali's HD TV
python3 scripts/generate_inventory.py \
  "/mnt/unraid/TV Shows" \
  -o /opt/mother/inventories/ali_tv

# Ali's 4K TV
python3 scripts/generate_inventory.py \
  "/mnt/unraid/4K TV Shows" \
  -o /opt/mother/inventories/ali_4ktv

# Chris's HD Movies
python3 scripts/generate_inventory.py \
  /mnt/synology/rs-movies/movies \
  -o /opt/mother/inventories/chris_movies

# Chris's 4K Movies
python3 scripts/generate_inventory.py \
  /mnt/synology/rs-4kmedia/4kmovies \
  -o /opt/mother/inventories/chris_4kmovies

# Chris's HD TV
python3 scripts/generate_inventory.py \
  /mnt/synology/rs-tv/tv \
  -o /opt/mother/inventories/chris_tv

# Chris's 4K TV
python3 scripts/generate_inventory.py \
  /mnt/synology/rs-4kmedia/4ktv \
  -o /opt/mother/inventories/chris_4ktv
```

---

## 📊 Monitoring Progress

```bash
# Reattach to screen session
screen -r inventory

# Or tail the log file
tail -f /opt/mother/logs/inventory_generation.log

# Check what's been created
ls -lh /opt/mother/inventories/

# If using manual method, watch progress in real-time
# (script shows progress bars with tqdm)
```

---

## 🔍 What Gets Captured

For each file, the inventory includes:

**File Information:**
- Full file path
- File size (bytes and GB)
- Created/modified dates
- File extension

**Quality from Filename:**
- Resolution (2160p, 1080p, 720p, etc.)
- Source (BluRay, Remux, WEB-DL, WEBRip, etc.)
- HDR format (HDR10, HDR, DV, HDR10+, HLG)
- Audio format (Atmos, TrueHD, DTS-HD, etc.)
- Video codec (HEVC, AVC, AV1)

**Mediainfo Data (if installed):**
- Actual video codec
- Video bitrate
- Exact resolution
- Detected HDR format
- Audio codec details
- Channel layout
- Runtime

**NO MD5 Hashes:**
- Hashing is disabled by default (too slow)
- Not needed for quality comparison
- Can be enabled with `--hash` flag if you really want it

---

## 🔄 After Inventories Complete

### Compare Libraries

```bash
# Compare HD Movies
python3 scripts/compare_libraries.py \
  /opt/mother/inventories/ali_movies.json \
  /opt/mother/inventories/chris_movies.json \
  -o /opt/mother/inventories/reports/movies

# Compare 4K Movies
python3 scripts/compare_libraries.py \
  /opt/mother/inventories/ali_4kmovies.json \
  /opt/mother/inventories/chris_4kmovies.json \
  -o /opt/mother/inventories/reports/4kmovies

# Compare HD TV
python3 scripts/compare_libraries.py \
  /opt/mother/inventories/ali_tv.json \
  /opt/mother/inventories/chris_tv.json \
  -o /opt/mother/inventories/reports/tv

# Compare 4K TV
python3 scripts/compare_libraries.py \
  /opt/mother/inventories/ali_4ktv.json \
  /opt/mother/inventories/chris_4ktv.json \
  -o /opt/mother/inventories/reports/4ktv
```

### Review Reports

```bash
# Each comparison creates:
# - comparison_summary_[timestamp].txt (human readable)
# - sync_plan_[timestamp].csv (for sync script)

# Read the summaries
cat /opt/mother/inventories/reports/*/comparison_summary_*.txt | less

# The reports will tell you:
# - What files only Ali has
# - What files only Chris has  
# - When you both have a file, which version is better
# - Total items to sync in each direction
```

---

## 💡 Tips

### Use Screen or Tmux
```bash
# Screen commands:
screen -S inventory          # Create new session
Ctrl+A, then D              # Detach
screen -r inventory         # Reattach
screen -list                # List sessions

# Tmux commands:
tmux new -s inventory       # Create new session
Ctrl+B, then D              # Detach
tmux attach -t inventory    # Reattach
tmux ls                     # List sessions
```

### Check Disk Space
```bash
# Inventory files are small (few MB), but check anyway
df -h /opt/mother
```

### If Something Fails
```bash
# Check the log
tail -100 /opt/mother/logs/inventory_generation.log

# Common issues:
# - Mount not accessible: Check NFS/SMB mounts
# - Permission denied: Check PUID/PGID match
# - Python error: Install missing dependencies
```

---

## 🎬 Your Updated HDR Preferences

The comparison script now uses:

1. **HDR10** - 300 points (HIGHEST - standard HDR)
2. **HDR** - 250 points (generic HDR)
3. **DV** - 150 points (Dolby Vision)
4. **HDR10+** - 100 points (Samsung proprietary, LOWER)
5. **HLG** - 100 points (Hybrid Log-Gamma)

This matches your preference for standard HDR10 over Samsung's HDR10+.

See [docs/TRASHGUIDES_REFERENCE.md](../docs/TRASHGUIDES_REFERENCE.md) for complete scoring details.

---

## 📞 Next Steps

1. **Deploy Mother** following QUICK_START.md
2. **Configure storage mounts** (NFS/SMB)
3. **Run this inventory generation** (start it and let it run for 1-2 days)
4. **Compare libraries** using the compare script
5. **Review sync plans** to see what needs to be copied where
6. **Execute initial sync** when ready

The inventory generation can run while you continue setting up other parts of Mother!

---

**Remember**: This is a ONE-TIME process. After initial sync, ongoing changes will be handled by Radarr/Sonarr and the real-time sync script.
