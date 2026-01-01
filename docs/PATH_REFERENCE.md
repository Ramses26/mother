# Project Mother - Path Reference

## Server Overview

| Server | Hostname | IP | Role |
|--------|----------|-----|------|
| Terminus | terminus | 192.168.1.14 | Ali's Unraid - runs scans locally |
| Mother | mother | 10.0.0.162 | Chris's Synology - has NFS mounts to both |

---

## Terminus (Ali's Unraid) - Local Paths

Use these paths when running scans **on Terminus**:

| Library | Path |
|---------|------|
| Movies 1080p | `/mnt/media/Movies` |
| Movies 4K | `/mnt/media/4K Movies` |
| TV 1080p | `/mnt/media/TV Shows` |
| TV 4K | `/mnt/media/4K TV Shows` |

---

## Mother Server - NFS Mount Paths

### Chris's (Synology) Libraries

| Library | Path |
|---------|------|
| Movies 1080p | `/mnt/synology/rs-movies` |
| Movies 4K | `/mnt/synology/rs-4kmedia/4kmovies` |
| TV 1080p | `/mnt/synology/rs-tv` |
| TV 4K | `/mnt/synology/rs-4kmedia/4ktv` |
| Deleted | `/mnt/synology/rs-4kmedia/deleted` |

### Ali's (Unraid) Libraries via NFS on Mother

| Library | Path |
|---------|------|
| Movies 1080p | `/mnt/unraid/media/Movies` |
| Movies 4K | `/mnt/unraid/media/4K Movies` |
| TV 1080p | `/mnt/unraid/media/TV Shows` |
| TV 4K | `/mnt/unraid/media/4K TV Shows` |
| Deleted Movies | `/mnt/unraid/media/Deleted Movies` |

---

## Scan Commands

### On Terminus (Ali's libraries)

```bash
cd ~/mother

# Movies
python3 scripts/generate_inventory.py /mnt/media/Movies -o inventories/ali_movies_1080p --fast
python3 scripts/generate_inventory.py "/mnt/media/4K Movies" -o inventories/ali_movies_4k --fast

# TV
python3 scripts/generate_inventory.py "/mnt/media/TV Shows" -o inventories/ali_tv_1080p --fast
python3 scripts/generate_inventory.py "/mnt/media/4K TV Shows" -o inventories/ali_tv_4k --fast
```

### On Mother (Chris's libraries)

```bash
cd /opt/mother

# Movies
python3 scripts/generate_inventory.py /mnt/synology/rs-movies -o inventories/chris_movies_1080p --fast
python3 scripts/generate_inventory.py /mnt/synology/rs-4kmedia/4kmovies -o inventories/chris_movies_4k --fast

# TV
python3 scripts/generate_inventory.py /mnt/synology/rs-tv -o inventories/chris_tv_1080p --fast
python3 scripts/generate_inventory.py /mnt/synology/rs-4kmedia/4ktv -o inventories/chris_tv_4k --fast
```

---

## After Scans - Run Comparison

Copy Ali's inventories to Mother, then run comparison:

```bash
# On Mother
scp alig@terminus:~/mother/inventories/ali_*.json /opt/mother/inventories/

# Run MOVIE comparisons (uses TMDB ID from filename)
cd /opt/mother
python3 scripts/compare_libraries.py inventories/ali_movies_1080p.json inventories/chris_movies_1080p.json -o reports
python3 scripts/compare_libraries.py inventories/ali_movies_4k.json inventories/chris_movies_4k.json -o reports

# Run TV comparisons (uses TVDB ID from folder + Season/Episode)
python3 scripts/compare_tv_libraries.py inventories/ali_tv_1080p.json inventories/chris_tv_1080p.json -o reports
python3 scripts/compare_tv_libraries.py inventories/ali_tv_4k.json inventories/chris_tv_4k.json -o reports
```

## Running Sync Scripts

The sync scripts have built-in progress tracking and error handling:

```bash
# Normal run - continues on errors, logs failures
./sync_actions_XXXXX.sh

# Stop on first error
EXIT_ON_ERROR=true ./sync_actions_XXXXX.sh

# Monitor progress in another terminal
tail -f sync_progress_XXXXX.log
```

Features:
- Commands are hashed and recorded in progress file when successful
- Re-running skips already-completed commands automatically
- Failures logged with exit code; script continues unless EXIT_ON_ERROR=true
- Timestamps for monitoring with tail

---

## NFS Mounts on Mother

```
10.0.0.88:/volume1/TV          -> /mnt/synology/rs-tv
10.0.0.160:/volume1/MOVIES     -> /mnt/synology/rs-movies
10.0.1.203:/volume1/4KMovies   -> /mnt/synology/rs-4kmedia/4kmovies
10.0.1.203:/volume1/4KTV       -> /mnt/synology/rs-4kmedia/4ktv
10.0.1.203:/volume1/deleted    -> /mnt/synology/rs-4kmedia/deleted
192.168.1.10:/mnt/user/Media   -> /mnt/unraid/media
```
