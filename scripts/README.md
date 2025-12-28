# Mother Scripts Directory

This directory contains all automation scripts for the Mother project.

**Last Updated:** 2024-12-28

## Quick Start - Movie Analysis Workflow

```bash
# Full analysis (inventory + comparison)
./scripts/analyze_movies.sh

# Just 1080p movies
./scripts/analyze_movies.sh --1080p

# Just 4K movies
./scripts/analyze_movies.sh --4k

# Regenerate inventories only
./scripts/analyze_movies.sh --inventory-only

# Compare using existing inventories
./scripts/analyze_movies.sh --compare-only
```

---

## Scripts Overview

### 📊 Library Analysis

#### `analyze_movies.sh`
**NEW!** Automated workflow for movie library analysis.

**Usage:**
```bash
./scripts/analyze_movies.sh              # Full analysis
./scripts/analyze_movies.sh --4k         # 4K movies only
./scripts/analyze_movies.sh --1080p      # 1080p movies only
./scripts/analyze_movies.sh --inventory-only   # Just generate inventories
./scripts/analyze_movies.sh --compare-only     # Just run comparison
```

**Features:**
- Generates inventories for both Ali (Unraid) and Chris (Synology)
- Runs quality comparisons with Project Mother scoring
- Outputs detailed reports and sync scripts
- Flags misplaced files (wrong library)

---

### 📦 Deployment & Management

#### `deploy.sh`
Full deployment and management script for Mother server.

**Usage:**
```bash
./scripts/deploy.sh              # Full deployment
./scripts/deploy.sh pull         # Pull latest images only
./scripts/deploy.sh stop         # Stop all containers
./scripts/deploy.sh start        # Start all containers
./scripts/deploy.sh restart      # Restart all containers
./scripts/deploy.sh status       # Show container status
./scripts/deploy.sh logs [name]  # Show logs
```

**Features:**
- Checks prerequisites (Docker, Docker Compose)
- Backs up configs before deployment
- Pulls latest images
- Stops/starts containers gracefully
- Verifies container health
- Shows access URLs

---

### 💾 Backup & Restore

#### `backup.sh`
Comprehensive backup script for all Mother configurations and databases.

**Usage:**
```bash
./scripts/backup.sh              # Create backup
./scripts/backup.sh list         # List available backups
./scripts/backup.sh restore FILE # Restore from backup
```

**What gets backed up:**
- All container configurations
- Docker Compose files (.env, docker-compose.yml)
- All scripts
- Application databases (qBittorrent, Radarr, Sonarr, Prowlarr, Seerr)
- Compressed into .tar.gz archive

**Features:**
- Automatic retention management (30 days default)
- Optional remote backup support
- Full restore capability
- Safe - backs up before any deployment

**Configuration:**
```bash
# In .env file
RETENTION_DAYS=30
REMOTE_BACKUP_ENABLED=false
REMOTE_BACKUP_PATH=/remote/backup/path
```

---

### 🗑️ qBittorrent Cleanup

#### `qbittorrent_cleanup.sh`
Automated torrent cleanup script for 90-120 day retention (Option 3 workflow).

**Usage:**
```bash
# Dry run (recommended first)
./scripts/qbittorrent_cleanup.sh

# Edit script and uncomment deletion line when ready
# Then run via cron:
0 2 * * * /opt/mother/scripts/qbittorrent_cleanup.sh
```

**Features:**
- Deletes completed torrents after 90-120 days
- Randomized deletion window to prevent mass deletions
- Dry-run mode by default (SAFE)
- Detailed logging
- Respects seeding state

**Configuration:**
```bash
# In .env file or export
export QBITTORRENT_HOST=localhost
export QBITTORRENT_PORT=8080
export QBITTORRENT_USERNAME=admin
export QBITTORRENT_PASSWORD=your_password
export MIN_RETENTION_DAYS=90
export MAX_RETENTION_DAYS=120
```

**⚠️ IMPORTANT:** Script is in DRY-RUN mode by default. Edit the script and uncomment the deletion line to enable actual deletion.

---

### 🔄 Sync to Unraid

#### `sync_to_unraid.sh`
Real-time sync script from Chris's Synology to Ali's Unraid.

**Usage:**
```bash
# Full sync (live)
./scripts/sync_to_unraid.sh

# Dry run (see what would be transferred)
./scripts/sync_to_unraid.sh --dry-run

# With bandwidth limit (10 MB/s)
./scripts/sync_to_unraid.sh --bwlimit 10

# Verbose output
./scripts/sync_to_unraid.sh --verbose
```

**Syncs:**
- RS-Movies (10.0.0.160) → Unraid Movies
- RS-TV (10.0.0.88) → Unraid TV Shows
- RS-4KMedia Movies (10.0.1.203) → Unraid 4K Movies
- RS-4KMedia TV (10.0.1.203) → Unraid 4K TV Shows

**Features:**
- Uses rclone for efficient syncing
- Bandwidth limiting
- Progress reporting
- Retry logic
- Connectivity testing
- Detailed logging

**Run via cron for continuous sync:**
```bash
# Every 15 minutes
*/15 * * * * /opt/mother/scripts/sync_to_unraid.sh >> /opt/mother/logs/sync.log 2>&1
```

---

### 📊 Inventory & Comparison

#### `generate_inventory.py`
Generate comprehensive media library inventory with quality analysis.

**Requirements:**
```bash
pip install tqdm  # Optional, for progress bars
```

**Usage:**
```bash
# Generate inventory for a library
python3 scripts/generate_inventory.py /path/to/media

# With custom output name
python3 scripts/generate_inventory.py /path/to/media -o ali_movies

# Enable MD5 hashing (SLOW)
python3 scripts/generate_inventory.py /path/to/media --hash

# Non-recursive (current directory only)
python3 scripts/generate_inventory.py /path/to/media --no-recursive
```

**Output:**
- JSON file with complete inventory
- CSV file for spreadsheet analysis
- Summary statistics
- Quality indicators extracted from filenames
- Mediainfo data (if mediainfo installed)

**Example workflow for Ali:**
```bash
# Generate inventories for all libraries
python3 scripts/generate_inventory.py \\\\unraid\\media\\Movies -o ali_movies
python3 scripts/generate_inventory.py \\\\unraid\\media\\4K Movies -o ali_4kmovies
python3 scripts/generate_inventory.py \\\\unraid\\media\\TV Shows -o ali_tv
python3 scripts/generate_inventory.py \\\\unraid\\media\\4K TV Shows -o ali_4ktv
```

---

#### `compare_libraries.py`
**UPDATED 2024-12-28** - Compare two library inventories using Project Mother scoring.

**Usage:**
```bash
python3 scripts/compare_libraries.py ali_movies.json chris_movies.json

# With custom output directory
python3 scripts/compare_libraries.py ali_movies.json chris_movies.json -o /path/to/reports
```

**Output:**
- `detailed_comparison_[timestamp].txt` - Human-readable report with all actions
- `sync_plan_[timestamp].csv` - CSV file for review
- `sync_actions_[timestamp].sh` - Executable sync script (DRY RUN by default)

**Key Features:**
- **Option C Analysis:** Uses path to determine library type (4K vs 1080p)
- **TRaSH Filename Parsing:** Extracts quality from `[Bluray-1080p][DTS-HD MA 5.1][HDR]` format
- **Misplaced File Detection:** Flags 4K files in 1080p libraries (and vice versa)
- **Deleted Folder Handling:** Generates moves to proper deleted folders

**Quality Scoring (from HDR & Audio Format Preferences.md):**
- **Resolution:** 2160p (+4000) > 1080p (+2000) > 720p (+1000)
- **Source:** Remux (+2000) > BluRay (+1500) > WEB-DL (+1000)
- **Audio:** TrueHD Atmos (+500) > DTS-HD MA (+400) > DTS (+200)
- **HDR 4K:** DV HDR10 (+800) > HDR10 (+700) > DV (+400)
- **HDR 1080p:** Any HDR (+400) - bonus for downscaled 4K releases
- **Codec:** AV1 (+250) > HEVC (+200) > AVC (+100)

**Priority Note:** Audio trumps HDR at 1080p (Atmos +500 > HDR +400)

**Example workflow:**
```bash
# Compare movie libraries
python3 scripts/compare_libraries.py ali_movies.json chris_movies.json

# Review the reports
cat comparison_summary_*.txt
```

---

## Installation

### Make Scripts Executable

```bash
cd /opt/mother
chmod +x scripts/*.sh
```

### Install Python Dependencies

```bash
# For inventory and comparison scripts
pip3 install tqdm

# For mediainfo support (optional but recommended)
sudo apt install mediainfo
```

---

## Automation Setup

### Cron Jobs

Add to crontab (`crontab -e`):

```bash
# Backup daily at 2 AM
0 2 * * * /opt/mother/scripts/backup.sh >> /opt/mother/logs/backup.log 2>&1

# qBittorrent cleanup daily at 3 AM
0 3 * * * /opt/mother/scripts/qbittorrent_cleanup.sh >> /opt/mother/logs/qbit_cleanup.log 2>&1

# Sync to Unraid every 15 minutes
*/15 * * * * /opt/mother/scripts/sync_to_unraid.sh >> /opt/mother/logs/sync.log 2>&1
```

---

## Logging

All scripts log to `/opt/mother/logs/`:

```bash
# View logs
tail -f /opt/mother/logs/backup.log
tail -f /opt/mother/logs/qbit_cleanup.log
tail -f /opt/mother/logs/sync.log
tail -f /opt/mother/logs/deployment_*.log
```

---

## Troubleshooting

### Script Permissions
```bash
# If you get "Permission denied"
chmod +x scripts/script_name.sh
```

### Environment Variables
```bash
# Scripts use .env file
# Make sure /opt/mother/.env exists and is configured
cat /opt/mother/.env
```

### Docker Access
```bash
# If you get Docker permission errors
sudo usermod -aG docker $USER
# Then log out and back in
```

---

## Safety Features

- **Dry-run modes** - Most scripts support testing before execution
- **Automatic backups** - Deploy script backs up before changes
- **Logging** - All actions are logged for audit
- **Error handling** - Scripts exit on errors to prevent damage
- **Retention** - Old backups automatically cleaned up

---

## Next Steps

1. Make all scripts executable
2. Configure .env file with passwords and settings
3. Test each script in dry-run mode
4. Set up cron jobs for automation
5. Monitor logs for issues

For questions or issues, check the main project documentation in the parent directory.
