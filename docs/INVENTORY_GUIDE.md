# Running Inventory Generation - Quick Guide

**Last Updated:** 2026-01-22

---

## Quick Summary

**The fastest way to run inventory scans:**

```bash
# SSH to terminus
ssh terminus

# Run the scan script (uses --fast mode by default)
cd ~/projects/mother/scripts
./scan_local.sh

# Check progress
./scan_local.sh --status
```

---

## Where to Run

### Recommended: Split Approach (FASTEST)

**Run Ali's inventories on Terminus** (local to Unraid):
- LOCAL access to Unraid (super fast)
- No VPN overhead
- Estimated time: 1-2 hours with `--fast` mode

**Run Chris's inventories on Mother** (local to Synology):
- LOCAL access to Synology (super fast)
- No VPN overhead
- Estimated time: 1-2 hours with `--fast` mode

**Then copy Ali's results to Mother for comparison.**

---

## Using scan_local.sh (RECOMMENDED)

The `scan_local.sh` script auto-detects which server you're on and scans the appropriate libraries.

### On Terminus (Ali's Unraid)

```bash
# SSH to terminus
ssh terminus

# Navigate to scripts
cd ~/projects/mother/scripts

# Scan all 4 libraries (default: --fast mode)
./scan_local.sh

# OR scan specific libraries:
./scan_local.sh --movies           # Movies only (1080p + 4K)
./scan_local.sh --tv               # TV only (1080p + 4K)
./scan_local.sh --movies --1080p   # 1080p Movies only
./scan_local.sh --tv --4k          # 4K TV only

# Check progress
./scan_local.sh --status

# Attach to a running scan
screen -r scan_ali_movies_1080p
# Detach: Ctrl+A, then D
```

### On Mother (Chris's Synology)

```bash
# SSH to mother
ssh mother

# Navigate to scripts
cd /opt/mother/scripts

# Scan all 4 libraries
./scan_local.sh

# Check progress
./scan_local.sh --status
```

### Paths Used by scan_local.sh

| Server   | Library      | Path                           |
|----------|--------------|--------------------------------|
| Terminus | Movies 1080p | `/mnt/media/Movies`            |
| Terminus | Movies 4K    | `/mnt/media/4K Movies`         |
| Terminus | TV 1080p     | `/mnt/media/TV Shows`          |
| Terminus | TV 4K        | `/mnt/media/4K TV Shows`       |
| Mother   | Movies 1080p | `/mnt/synology/rs-movies`      |
| Mother   | Movies 4K    | `/mnt/synology/rs-4kmedia/4kmovies` |
| Mother   | TV 1080p     | `/mnt/synology/rs-tv`          |
| Mother   | TV 4K        | `/mnt/synology/rs-4kmedia/4ktv`|

---

## Using generate_inventory.py Directly

If you need more control, use the Python script directly.

### Script Location

The script is at: `~/projects/mother/scripts/generate_inventory.py` (on terminus)
Or: `/opt/mother/scripts/generate_inventory.py` (on mother)

### Syntax

```bash
python3 generate_inventory.py <path> -o <output_base> [OPTIONS]

Options:
  -o, --output OUTPUT  Output file base (without extension) - REQUIRED
  -v, --verbose        Enable verbose error output
  --fast               Fast mode: skip MediaInfo (RECOMMENDED for NFS)
```

### Examples

```bash
# On Terminus - with --fast mode (RECOMMENDED)
cd ~/projects/mother/scripts

python3 generate_inventory.py "/mnt/media/Movies" \
  -o ../inventories/ali_movies_1080p --fast

python3 generate_inventory.py "/mnt/media/4K Movies" \
  -o ../inventories/ali_movies_4k --fast

python3 generate_inventory.py "/mnt/media/TV Shows" \
  -o ../inventories/ali_tv_1080p --fast

python3 generate_inventory.py "/mnt/media/4K TV Shows" \
  -o ../inventories/ali_tv_4k --fast

# On Mother - with --fast mode
cd /opt/mother/scripts

python3 generate_inventory.py /mnt/synology/rs-movies \
  -o ../inventories/chris_movies_1080p --fast

python3 generate_inventory.py /mnt/synology/rs-4kmedia/4kmovies \
  -o ../inventories/chris_movies_4k --fast

python3 generate_inventory.py /mnt/synology/rs-tv \
  -o ../inventories/chris_tv_1080p --fast

python3 generate_inventory.py /mnt/synology/rs-4kmedia/4ktv \
  -o ../inventories/chris_tv_4k --fast
```

---

## The --fast Flag

### What --fast Does

- **Skips MediaInfo**: No video codec/bitrate/duration extraction from file headers
- **Uses filename parsing only**: Extracts quality info from TRaSH-style filenames
- **Much faster**: 1-2 hours vs 6-12 hours per library

### Why Use --fast

1. **compare_libraries.py doesn't use MediaInfo data** - it only needs filename metadata
2. **Network speed**: MediaInfo is extremely slow over NFS/VPN
3. **Same quality comparison results**: Filenames contain all needed quality indicators

### When to Skip --fast

- If you need exact video dimensions, bitrate, or duration
- For detailed analysis beyond quality comparison
- For local drives with fast I/O

**Recommendation: Always use `--fast` for inventory generation before compare_libraries.py**

---

## After Inventories Complete

### Copy Ali's Inventories to Mother

```bash
# From terminus
scp ~/projects/mother/inventories/ali_*.json mother:/opt/mother/inventories/
```

### Run Compare Libraries

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

### Review Reports

Each comparison generates:

| File | Purpose |
|------|---------|
| `detailed_comparison_[timestamp].txt` | Human readable report |
| `sync_plan_[timestamp].csv` | Spreadsheet format for review |
| `sync_actions_[timestamp].sh` | Main sync script (copies + Ali moves) |
| `chris_pending_deletions_[timestamp].sh` | Chris's old movie files to delete later |
| `chris_tv_pending_deletions_[timestamp].sh` | Chris's old TV files to delete later |

### Run Sync Scripts

```bash
cd /opt/mother/reports

# Run the main sync (copies files, moves Ali's old files to Deleted)
./sync_actions_[timestamp].sh

# For TV shows
./tv_sync_actions_[timestamp].sh
```

### After Sync: Run Deletion Scripts

Chris's Synology deletions are in separate scripts (because Synology moves are slow).
Run these **after** the main sync completes:

```bash
# Preview first (recommended)
DRY_RUN=true ./chris_pending_deletions_[timestamp].sh
DRY_RUN=true ./chris_tv_pending_deletions_[timestamp].sh

# Then actually delete
./chris_pending_deletions_[timestamp].sh
./chris_tv_pending_deletions_[timestamp].sh
```

---

## What Gets Captured

For each file, the inventory includes:

**File Information:**
- Full file path (relative and absolute)
- File size (bytes and GB)
- File extension

**Quality from Filename (TRaSH format):**
- Resolution (2160p, 1080p, 720p, etc.)
- Source (BluRay, Remux, WEB-DL, WEBRip, etc.)
- HDR format (HDR10, HDR, DV, HDR10+, HLG)
- Audio format (Atmos, TrueHD, DTS-HD MA, etc.)
- Video codec (HEVC, AVC, AV1)
- Release group

**Database IDs (from folder/filename):**
- TVDB ID: `{tvdb-123456}`
- TMDB ID: `{tmdb-530915}`
- IMDB ID: `{imdb-tt1234567}`
- Year: `(2019)`

**MediaInfo Data (only without --fast):**
- Actual video codec and bitrate
- Exact resolution (width x height)
- Duration in minutes
- Detected HDR format from video tracks

---

## Prerequisites

### On Terminus

```bash
# Usually already installed, but verify:
pip3 install tqdm

# Optional (only needed for full mode):
sudo apt install mediainfo
```

### On Mother

```bash
pip3 install tqdm
sudo apt install mediainfo  # Optional
```

---

## Troubleshooting

### "Unknown hostname" Error

The `scan_local.sh` script only works on `terminus` or `mother`. If running elsewhere:

```bash
# Override with environment variables
OWNER=ali \
MOVIES_1080P="/path/to/movies" \
MOVIES_4K="/path/to/4kmovies" \
TV_1080P="/path/to/tv" \
TV_4K="/path/to/4ktv" \
./scan_local.sh
```

### Script Not Found

```bash
# Wrong: Don't use ~/generate_inventory.py
python3 ~/generate_inventory.py ...  # WRONG!

# Right: Use the project script
cd ~/projects/mother/scripts
python3 generate_inventory.py ...    # CORRECT!
```

### Path Not Found

Verify mounts are accessible:
```bash
ls -la "/mnt/media/Movies" 2>/dev/null && echo "OK" || echo "Not mounted"
```

### Check Running Scans

```bash
# List screen sessions
screen -ls

# Attach to a scan
screen -r scan_ali_movies_1080p

# Detach without stopping
# Press Ctrl+A, then D
```

---

## Tips

### Use Screen (Already Built Into scan_local.sh)

The `scan_local.sh` script automatically uses screen sessions, so you can:
- Disconnect SSH and scans continue running
- Check progress later with `./scan_local.sh --status`
- Attach to watch progress: `screen -r <session_name>`

### Running Manually with Screen

```bash
# Create named session
screen -S inventory

# Run your commands...
python3 generate_inventory.py ...

# Detach: Ctrl+A, then D
# Reattach later: screen -r inventory
```

---

## Complete Workflow Summary

1. **SSH to terminus**: `ssh terminus`
2. **Run scans**: `cd ~/projects/mother/scripts && ./scan_local.sh`
3. **Wait** (check with `./scan_local.sh --status`)
4. **Copy to mother**: `scp ../inventories/ali_*.json mother:/opt/mother/inventories/`
5. **SSH to mother**: `ssh mother`
6. **Run comparisons**: `python3 scripts/compare_libraries.py ...`
7. **Review reports** in `/opt/mother/reports/`
8. **Execute sync** using generated scripts
