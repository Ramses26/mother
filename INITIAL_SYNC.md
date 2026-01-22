# Initial Data Synchronization - Project Mother

**Last Updated:** 2026-01-22

## Overview

This document outlines the process for analyzing, comparing, and performing the initial synchronization of media libraries between Ali's Unraid server and Chris's Synology devices.

## Current Library Stats

### Ali's Unraid (192.168.1.10)
- **4K Movies**: 8.38 TB
- **Movies**: 66.3 TB
- **TV Shows**: 82.3 TB
- **4K TV Shows**: 1.94 TB
- **Total**: ~159 TB
- **Quality**: TRASHGuides compliant, quality-focused releases

### Chris's Synology
- **Movies**: 73.7 TB (RS-Movies: 10.0.0.160)
- **TV Shows**: ~85 TB (RS-TV: 10.0.0.88)
- **4K Content**: Unknown (RS-4KMedia: 10.0.1.203)
- **Total**: ~159+ TB
- **Quality**: Mixed, not TRASHGuides compliant

### Expected Overlap
- High duplicate count expected
- Ali's library likely has superior quality releases
- Some unique content on each side

---

## Quick Start

The fastest way to get started:

```bash
# 1. SSH to terminus and run inventory scans
ssh terminus
cd ~/projects/mother/scripts
./scan_local.sh

# 2. Check progress
./scan_local.sh --status

# 3. When complete, copy inventories to mother
scp ../inventories/ali_*.json mother:/opt/mother/inventories/

# 4. SSH to mother and run comparisons
ssh mother
cd /opt/mother

# Movies use compare_libraries.py
python3 scripts/compare_libraries.py \
  inventories/ali_movies_1080p.json \
  inventories/chris_movies_1080p.json \
  -o reports

# TV Shows use compare_tv_libraries.py
python3 scripts/compare_tv_libraries.py \
  inventories/ali_tv_1080p.json \
  inventories/chris_tv_1080p.json \
  -o reports

# 5. Review reports and execute sync
cat reports/detailed_comparison_*.txt
```

---

## Phase 1: Data Collection & Analysis

### Step 1: Install Prerequisites

#### On Terminus
```bash
# Python dependencies
pip3 install tqdm

# Optional (only for full MediaInfo mode)
sudo apt install mediainfo
```

#### On Mother
```bash
pip3 install tqdm
sudo apt install mediainfo  # Optional
```

### Step 2: Generate Inventories

**See [docs/INVENTORY_GUIDE.md](docs/INVENTORY_GUIDE.md) for detailed instructions.**

#### Quick Version - Using scan_local.sh (RECOMMENDED)

```bash
# On Terminus (Ali's libraries)
ssh terminus
cd ~/projects/mother/scripts
./scan_local.sh              # Scans all 4 libraries with --fast mode

# On Mother (Chris's libraries)
ssh mother
cd /opt/mother/scripts
./scan_local.sh              # Scans all 4 libraries with --fast mode
```

#### Manual Version - Using generate_inventory.py

```bash
# On Terminus
cd ~/projects/mother/scripts

python3 generate_inventory.py "/mnt/media/Movies" \
  -o ../inventories/ali_movies_1080p --fast

python3 generate_inventory.py "/mnt/media/4K Movies" \
  -o ../inventories/ali_movies_4k --fast

python3 generate_inventory.py "/mnt/media/TV Shows" \
  -o ../inventories/ali_tv_1080p --fast

python3 generate_inventory.py "/mnt/media/4K TV Shows" \
  -o ../inventories/ali_tv_4k --fast
```

### Step 3: Copy Ali's Inventories to Mother

```bash
# From terminus
scp ~/projects/mother/inventories/ali_*.json mother:/opt/mother/inventories/
```

---

## Phase 2: Library Comparison

### Step 4: Run Comparisons

There are two comparison scripts:
- **`compare_libraries.py`** - For Movies (matches by TMDB ID)
- **`compare_tv_libraries.py`** - For TV Shows (matches by TVDB ID + Season + Episode)

```bash
# On mother
cd /opt/mother

# Compare Movies (use compare_libraries.py)
python3 scripts/compare_libraries.py \
  inventories/ali_movies_1080p.json \
  inventories/chris_movies_1080p.json \
  -o reports

python3 scripts/compare_libraries.py \
  inventories/ali_movies_4k.json \
  inventories/chris_movies_4k.json \
  -o reports

# Compare TV Shows (use compare_tv_libraries.py)
python3 scripts/compare_tv_libraries.py \
  inventories/ali_tv_1080p.json \
  inventories/chris_tv_1080p.json \
  -o reports

python3 scripts/compare_tv_libraries.py \
  inventories/ali_tv_4k.json \
  inventories/chris_tv_4k.json \
  -o reports
```

### Step 5: Review Reports

Each comparison generates 3 files:

| File | Description |
|------|-------------|
| `detailed_comparison_[timestamp].txt` | Human-readable report with statistics |
| `sync_plan_[timestamp].csv` | Spreadsheet format for review |
| `sync_actions_[timestamp].sh` | Executable bash script with rsync commands |

```bash
# View summary
cat reports/movies_1080p/detailed_comparison_*.txt | less

# Review sync plan in spreadsheet
# Copy CSV to your machine and open in Excel/Sheets

# Check action count
wc -l reports/movies_1080p/sync_actions_*.sh
```

---

## Phase 3: Sync Execution

### Pre-Sync Checklist

- [ ] All inventories generated
- [ ] Comparison reports reviewed
- [ ] Sync plans reviewed (check CSV files)
- [ ] Sufficient free space on destinations
- [ ] Network connectivity stable
- [ ] Test with dry-run first

### Step 6: Test Sync (Dry Run)

```bash
# Option 1: Use the generated sync script with dry-run
cd /opt/mother/reports/movies_1080p
DRY_RUN=true ./sync_actions_*.sh

# Option 2: Use sync_with_deleted.py with --dry-run
python3 /opt/mother/scripts/sync_with_deleted.py \
  -s sync_plan_*.csv \
  -si /opt/mother/inventories/ali_movies_1080p.json \
  -di /opt/mother/inventories/chris_movies_1080p.json \
  -t movies \
  -d "Ali→Chris" \
  --dry-run --max-files 10
```

### Step 7: Execute Sync

```bash
# Run in screen session
screen -S sync

# Execute sync script
cd /opt/mother/reports/movies_1080p
./sync_actions_*.sh

# Detach: Ctrl+A, D
# Reattach: screen -r sync
```

### Monitoring Progress

```bash
# Check sync status
python3 /opt/mother/scripts/sync_status.py \
  /opt/mother/reports/movies_1080p/sync_actions_*.sh

# With Telegram notification
python3 /opt/mother/scripts/sync_status.py \
  /opt/mother/reports/movies_1080p/sync_actions_*.sh --telegram

# List remaining files
python3 /opt/mother/scripts/sync_status.py \
  /opt/mother/reports/movies_1080p/sync_actions_*.sh --list-remaining
```

---

## Phase 4: Verification

### Step 8: Verify Sync

```bash
# Verify completed transfers
python3 /opt/mother/scripts/verify_sync.py \
  /opt/mother/reports/movies_1080p/sync_actions_*.sh

# Show issues
python3 /opt/mother/scripts/verify_sync.py \
  /opt/mother/reports/movies_1080p/sync_actions_*.sh --show-issues

# Attempt to fix issues
python3 /opt/mother/scripts/verify_sync.py \
  /opt/mother/reports/movies_1080p/sync_actions_*.sh --fix
```

### Post-Sync Verification Steps

1. Compare file counts between sources
2. Spot-check random files for playback
3. Verify library scans in Radarr/Sonarr
4. Check for any errors in logs

---

## Sync Strategy Options

### Option 1: Bidirectional Sync (RECOMMENDED)

Both Ali and Chris get the best version of each file:
- Unique files copied to the other side
- Higher quality versions replace lower quality
- Uses Deleted folder for replaced files (can recover if needed)

### Option 2: Single Direction

One library is authoritative:
- All files sync from authoritative → other
- Simpler but may overwrite some content

---

## File Naming Requirements

For best matching results, ensure files follow TRaSH naming conventions:

**Movies:**
```
Movie Name (2023) {tmdb-12345} [Remux-1080p][TrueHD Atmos 7.1][x265].mkv
```

**TV Shows:**
```
Show Name (2020) {tvdb-12345}/Season 01/Show Name - S01E01 - Episode Name [Bluray-1080p][DTS-HD MA 5.1][x265].mkv
```

Files without TMDB/TVDB IDs will be matched by title+year, which is less reliable.

---

## Troubleshooting

### Sync Interrupted
```bash
# Rsync resumes automatically
# Just re-run the sync script - it skips completed files
./sync_actions_*.sh
```

### Permission Errors
```bash
# Check mount permissions
ls -la /mnt/synology/rs-movies/
# Ensure PUID/PGID match
```

### Network Issues
```bash
# Add retry options to rsync (already in generated scripts)
# --timeout=300 --partial
```

### Insufficient Space
```bash
# Check space before starting
df -h /mnt/synology/rs-movies /mnt/unraid/media/Movies
```

---

## Scripts Reference

| Script | Purpose |
|--------|---------|
| `generate_inventory.py` | Scan library and create JSON/CSV inventory |
| `compare_libraries.py` | Compare movie inventories (uses TMDB ID) |
| `compare_tv_libraries.py` | Compare TV inventories (uses TVDB ID + Season/Episode) |
| `sync_with_deleted.py` | Execute sync with Deleted folder protection |
| `sync_status.py` | Check batch sync progress |
| `verify_sync.py` | Verify transfers completed correctly |
| `scan_local.sh` | Auto-detect server and scan all libraries |

---

## Next Steps After Initial Sync

1. Set up real-time sync - see [SYNC_STRATEGY.md](SYNC_STRATEGY.md)
2. Configure Radarr/Sonarr integration
3. Set up nightly reconciliation cron job
4. Configure Telegram notifications for sync status
