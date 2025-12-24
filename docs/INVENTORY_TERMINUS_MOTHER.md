# Running Inventories on Terminus + Mother

**Last Updated:** 2024-12-23

---

## 🎯 Smart Approach: Split the Work!

You're absolutely right - run scans locally, then transfer results!

### Run Ali's Scans on Terminus
✅ **Local to Unraid** - No VPN overhead  
✅ **Much faster** - Direct local access  
✅ **Start immediately** - Don't wait for Mother  
✅ **Parallel processing** - While Mother is being built

### Run Chris's Scans on Mother
✅ **Local to Synology** - Direct access  
✅ **No VPN overhead** - Fast scanning  
✅ **Runs at Chris's location**

### Transfer Results to Mother
Small JSON/CSV files transfer quickly over VPN

---

## 📋 On Terminus (Ali's Libraries)

### 1. Install Prerequisites

```bash
# Install Python dependencies
pip3 install tqdm

# Install mediainfo (HIGHLY RECOMMENDED)
sudo apt install mediainfo

# Navigate to mother project
cd ~/projects/mother
```

### 2. Run Ali's Inventories

```bash
# Use screen to run in background
screen -S ali-inventory

# Generate all 4 of Ali's inventories
# This will take 12-24 hours total

# Ali's HD Movies
python3 scripts/generate_inventory.py \
  "/mnt/user/media/Movies" \
  -o ~/projects/mother/inventories/ali_movies

# Ali's 4K Movies  
python3 scripts/generate_inventory.py \
  "/mnt/user/media/4K Movies" \
  -o ~/projects/mother/inventories/ali_4kmovies

# Ali's HD TV
python3 scripts/generate_inventory.py \
  "/mnt/user/media/TV Shows" \
  -o ~/projects/mother/inventories/ali_tv

# Ali's 4K TV
python3 scripts/generate_inventory.py \
  "/mnt/user/media/4K TV Shows" \
  -o ~/projects/mother/inventories/ali_4ktv

# Detach: Ctrl+A, D
# Reattach: screen -r ali-inventory
```

### 3. Transfer to Mother

```bash
# After all scans complete
cd ~/projects/mother/inventories

# Transfer to Mother
rsync -avz ali_*.json ali_*.csv mother:/opt/mother/inventories/

# Or using scp
scp ali_*.json ali_*.csv mother:/opt/mother/inventories/
```

---

## 📋 On Mother (Chris's Libraries)

### 1. Install Prerequisites

```bash
# Install Python dependencies
pip3 install tqdm

# Install mediainfo
sudo apt install mediainfo

# Make scripts executable
chmod +x /opt/mother/scripts/*.sh
chmod +x /opt/mother/scripts/*.py
```

### 2. Run Chris's Inventories

```bash
# Use screen to run in background
screen -S chris-inventory

# Generate all 4 of Chris's inventories
# This will take 12-24 hours total

# Chris's HD Movies
python3 /opt/mother/scripts/generate_inventory.py \
  /mnt/synology/rs-movies/movies \
  -o /opt/mother/inventories/chris_movies

# Chris's 4K Movies
python3 /opt/mother/scripts/generate_inventory.py \
  /mnt/synology/rs-4kmedia/4kmovies \
  -o /opt/mother/inventories/chris_4kmovies

# Chris's HD TV
python3 /opt/mother/scripts/generate_inventory.py \
  /mnt/synology/rs-tv/tv \
  -o /opt/mother/inventories/chris_tv

# Chris's 4K TV
python3 /opt/mother/scripts/generate_inventory.py \
  /mnt/synology/rs-4kmedia/4ktv \
  -o /opt/mother/inventories/chris_4ktv

# Detach: Ctrl+A, D
# Reattach: screen -r chris-inventory
```

---

## ⚡ Parallel Timeline

### Day 1
- **On Terminus**: Start Ali's scans (begin immediately!)
- **On Mother**: Deploy Mother server, configure mounts

### Day 2  
- **On Terminus**: Ali's scans running in background
- **On Mother**: Start Chris's scans

### Day 3
- **Both running in parallel** - Maximum efficiency!

### When Both Complete (2-3 days)
- Transfer Ali's results to Mother
- Run comparisons on Mother
- Review sync plans

---

## 🔍 Compare on Mother

Once all inventories are on Mother:

```bash
cd /opt/mother

# Compare HD Movies
python3 scripts/compare_libraries.py \
  inventories/ali_movies.json \
  inventories/chris_movies.json \
  -o inventories/reports/movies

# Compare 4K Movies
python3 scripts/compare_libraries.py \
  inventories/ali_4kmovies.json \
  inventories/chris_4kmovies.json \
  -o inventories/reports/4kmovies

# Compare HD TV
python3 scripts/compare_libraries.py \
  inventories/ali_tv.json \
  inventories/chris_tv.json \
  -o inventories/reports/tv

# Compare 4K TV
python3 scripts/compare_libraries.py \
  inventories/ali_4ktv.json \
  inventories/chris_4ktv.json \
  -o inventories/reports/4ktv
```

---

## 📊 Verify Paths

### On Terminus (Your Unraid paths)

Adjust these to match your actual Unraid shares:

```bash
/mnt/user/media/Movies
/mnt/user/media/4K Movies
/mnt/user/media/TV Shows
/mnt/user/media/4K TV Shows
```

### On Mother (Chris's Synology mounts)

These should match your NFS mounts on Mother:

```bash
/mnt/synology/rs-movies/movies
/mnt/synology/rs-4kmedia/4kmovies
/mnt/synology/rs-tv/tv
/mnt/synology/rs-4kmedia/4ktv
```

---

## 💡 Benefits of This Approach

✅ **Faster** - No slow VPN scanning  
✅ **Parallel** - Both systems working at once  
✅ **Flexible** - Start Ali's scans immediately  
✅ **Efficient** - Only transfer small result files over VPN  
✅ **Smart** - Use local access where available

---

## ⏱️ Time Estimates

### Ali's Scans (on Terminus)
- Movies (66 TB): ~8-10 hours
- 4K Movies (8 TB): ~2-3 hours
- TV Shows (82 TB): ~10-12 hours
- 4K TV (2 TB): ~1-2 hours
- **Total: ~24 hours**

### Chris's Scans (on Mother)
- Movies (74 TB): ~8-10 hours
- TV Shows (85 TB): ~10-12 hours  
- 4K content (varies): ~3-5 hours
- **Total: ~24 hours**

### Parallel Processing
**Both complete in ~2 days instead of ~4 days!**

---

## 🚀 Start Now!

You can start Ali's inventory generation on Terminus **right now** while Mother is being built!

```bash
# On Terminus
cd ~/projects/mother
screen -S ali-inventory
# Run the commands above
```

Then when Mother is ready, start Chris's scans there!
