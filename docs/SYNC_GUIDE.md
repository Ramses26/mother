# Intelligent Sync Guide - With Deleted Folder Protection

**Created:** 2024-12-26  
**Updated:** 2024-12-26  
**Purpose:** Sync media with quality upgrades, moving replaced files to Deleted folder for manual review

---

## 🎯 Key Concept: Quality Upgrades with Safety Net

### Your Requirements:
1. ✅ **Different resolutions = different libraries** (1080p and 2160p can coexist)
2. ✅ **Same resolution = keep best quality** (upgrade with protection)
3. ✅ **Replaced files → Deleted folder** for manual review
4. ✅ **No automatic deletions** - you review and delete manually

---

## 📁 Folder Structure

### Ali's Unraid (`\\media\`):
```
Movies/                  ← HD/1080p movies
4K Movies/               ← 2160p movies
TV Shows/                ← HD/1080p TV
4K TV Shows/             ← 2160p TV

Deleted/                 ← Files moved here before deletion
├── Movies/              ← Replaced HD movies
├── 4kMovies/            ← Replaced 4K movies
├── tvshows/             ← Replaced HD TV
└── 4ktvshows/           ← Replaced 4K TV
```

### Chris's Synology:
```
rs-movies/               ← HD/1080p movies
rs-4kmedia/
├── 4kmovies/            ← 2160p movies
└── 4ktv/                ← 2160p TV
rs-tv/                   ← HD/1080p TV

Deleted/                 ← Files moved here before deletion
├── Movies/
├── 4kMovies/
├── tvshows/
└── 4ktvshows/
```

---

## 🔄 How Syncing Works

### Scenario 1: Different Resolutions (Both Kept)
```
Ali has:   Avatar (2009) 1080p BluRay.mkv → /Movies/
Chris has: Avatar (2009) 2160p Remux.mkv  → /4K Movies/

Result after sync:
Ali:
├── /Movies/Avatar (2009) 1080p BluRay.mkv        ← Original, kept!
└── /4K Movies/Avatar (2009) 2160p Remux.mkv      ← New from Chris!

Both versions coexist! ✅
```

### Scenario 2: Same Resolution, Better Quality (Upgrade with Protection)
```
Ali has:   Avatar (2009) 1080p BluRay.mkv (score: 1500)
Chris has: Avatar (2009) 1080p Remux.mkv (score: 1800)

Result after sync:
1. Move Ali's BluRay to /Deleted/Movies/Avatar (2009) 1080p BluRay.mkv
2. Copy Chris's Remux to /Movies/Avatar (2009) 1080p Remux.mkv

Ali now has better quality! Old version in Deleted for review! ✅
```

### Scenario 3: Same Resolution, Lower Quality (No Action)
```
Ali has:   Avatar (2009) 1080p Remux.mkv (score: 1800)
Chris has: Avatar (2009) 1080p BluRay.mkv (score: 1500)

Result: No action (Ali already has better version) ✅
```

### Scenario 4: New File (Simple Copy)
```
Ali has:   Nothing
Chris has: Matrix (1999) 1080p BluRay.mkv

Result: Copy to /Movies/Matrix (1999) 1080p BluRay.mkv ✅
```

---

## 📋 Fixed Scripts Overview

### 1. `compare_libraries.py` (FIXED VERSION)

**What Was Broken:**
```python
# OLD BUG: Only kept last version
for file in files:
    index[title] = file  # Overwrites previous!

Result: Lost track of multiple versions
        Showed "Equal: 1,412" when should show quality differences
```

**What's Fixed:**
```python
# NEW: Keeps ALL versions
for file in files:
    index[title].append(file)  # Keeps all!

Result: Correctly compares all versions
        Shows actual quality differences
```

**Usage:**
```bash
python3 scripts/compare_libraries.py \
  inventories/ali_movies.json \
  inventories/chris_movies.json \
  -o reports/movies
```

**Output:**
- `comparison_summary_TIMESTAMP.txt` - Detailed report with quality scores
- `sync_plan_TIMESTAMP.csv` - Plan for sync_with_deleted.py

---

### 2. `sync_with_deleted.py` (NEW!)

**What It Does:**
1. ✅ Copies new files (you don't have)
2. ✅ Upgrades quality (better version exists)
3. ✅ Moves old files to Deleted folder (for your review)
4. ✅ Never auto-deletes anything

**Key Features:**
- Dry run mode (test safely)
- Detailed progress tracking
- Automatic Deleted folder creation
- Timestamp-based naming (no conflicts)
- Safety confirmations

**Usage:**
```bash
# Sync FROM Chris TO Ali (movies)
python3 scripts/sync_with_deleted.py \
  -s reports/movies/sync_plan_20241226_184006.csv \
  -si inventories/chris_movies.json \
  -di inventories/ali_movies.json \
  -t movies \
  -d "Chris → Ali" \
  --dry-run

# Sync FROM Ali TO Chris (movies)
python3 scripts/sync_with_deleted.py \
  -s reports/movies/sync_plan_20241226_184006.csv \
  -si inventories/ali_movies.json \
  -di inventories/chris_movies.json \
  -t movies \
  -d "Ali → Chris" \
  --dry-run
```

---

## 🚀 Complete Workflow

### Step 1: Generate Inventories ✅ (Already Done!)

Scans completed on both systems.

### Step 2: Copy Ali's Inventories to Mother
```bash
ssh mother
cd /opt/mother
scp terminus:~/inventories/ali_*.json inventories/
```

### Step 3: Run Fixed Comparisons
```bash
cd /opt/mother

# Compare all libraries with FIXED script
./scripts/run_all_comparisons.sh

# Or run individually:
python3 scripts/compare_libraries.py \
  inventories/ali_movies.json \
  inventories/chris_movies.json \
  -o reports/movies
```

**Expected Results (FIXED):**
```
Before (BROKEN):
Ali better: 0
Chris better: 0
Equal: 1,412

After (FIXED):
Ali better: 200-500    ← Real differences!
Chris better: 150-400  ← Real differences!
Equal: 500-800         ← Actual ties
```

### Step 4: Review Comparison Reports
```bash
# Check the summary
cat reports/movies/comparison_summary_*.txt

# Look for:
# - FILES TO COPY TO ALI (Chris has, Ali doesn't)
# - FILES TO COPY TO CHRIS (Ali has, Chris doesn't)
# - NEEDS REVIEW (quality upgrades that will move old files to Deleted)
```

### Step 5: Sync Chris → Ali (DRY RUN FIRST!)
```bash
# Test with dry run
python3 scripts/sync_with_deleted.py \
  -s reports/movies/sync_plan_20241226_184006.csv \
  -si inventories/chris_movies.json \
  -di inventories/ali_movies.json \
  -t movies \
  -d "Chris → Ali" \
  --dry-run \
  --max-files 10

# Review output:
# - Which files will be copied
# - Which files will be moved to Deleted
# - Verify paths look correct
```

### Step 6: Execute Real Sync
```bash
# After confirming dry run looks good
python3 scripts/sync_with_deleted.py \
  -s reports/movies/sync_plan_20241226_184006.csv \
  -si inventories/chris_movies.json \
  -di inventories/ali_movies.json \
  -t movies \
  -d "Chris → Ali"

# Will prompt for confirmation before starting
```

### Step 7: Review Deleted Folder
```bash
# Check what was moved
ls -lh /mnt/media/Deleted/Movies/

# Review files
# Play a few to confirm they're the old versions
# Delete when satisfied

# Or keep for a while as backup
```

### Step 8: Repeat for Other Directions/Media Types
```bash
# Sync Ali → Chris (movies)
python3 scripts/sync_with_deleted.py \
  -s reports/movies/sync_plan_*.csv \
  -si inventories/ali_movies.json \
  -di inventories/chris_movies.json \
  -t movies \
  -d "Ali → Chris" \
  --dry-run

# Sync 4K Movies
python3 scripts/sync_with_deleted.py \
  -s reports/4kmovies/sync_plan_*.csv \
  -si inventories/chris_4kmovies.json \
  -di inventories/ali_4kmovies.json \
  -t 4kmovies \
  -d "Chris → Ali" \
  --dry-run

# Sync TV Shows
python3 scripts/sync_with_deleted.py \
  -s reports/tv/sync_plan_*.csv \
  -si inventories/chris_tv.json \
  -di inventories/ali_tv.json \
  -t tv \
  -d "Chris → Ali" \
  --dry-run
```

---

## 📊 Example Sync Output

```
================================================================================
INTELLIGENT SYNC - MOVIES
================================================================================
Mode: DRY RUN (no files will be moved/copied)

📖 Loading sync plan: reports/movies/sync_plan_20241226_184006.csv
   Found 5787 items in plan
Filtered to 5787 items for Chris → Ali

🔄 Processing 5787 files...

[1/5787] Avatar (2009) 2160p Remux.mkv
  Direction: Chris → Ali
  Source: /mnt/synology/rs-4kmedia/4kmovies/Avatar (2009)/Avatar (2009) 2160p Remux.mkv
  Destination: /mnt/media/4K Movies/Avatar (2009)/Avatar (2009) 2160p Remux.mkv
  [DRY RUN] Copying
  ✅ Would copy (new file)

[2/5787] Matrix (1999) 1080p Remux.mkv
  Direction: Chris → Ali
  ⚠️  UPGRADE: Will replace existing file
     Old file: Matrix (1999) 1080p BluRay.mkv
  📦 Moving to Deleted folder:
     From: /mnt/media/Movies/Matrix (1999)/Matrix (1999) 1080p BluRay.mkv
     To: /mnt/media/Deleted/Movies/Matrix (1999) 1080p BluRay.mkv
     [DRY RUN - not actually moved]
  [DRY RUN] Copying
  ✅ Would upgrade (better quality)

================================================================================
SYNC COMPLETE
================================================================================
Total files processed: 5787
📥 New files copied: 4500
⬆️  Quality upgrades: 287
📦 Files moved to Deleted: 287
❌ Failed: 0
⏭️  Skipped: 1000
📊 Total size: 45,678.90 GB
================================================================================

⚠️  IMPORTANT: Files moved to Deleted folder for manual review:
   /mnt/media/Deleted/Movies

   Review these files and delete manually when satisfied!
================================================================================
```

---

## ⚠️ Important Safety Notes

### 1. Always Dry Run First!
```bash
# NEVER skip dry run on first attempt
--dry-run --max-files 10

# Review output carefully
# Verify paths are correct
# Check Deleted folder logic

# Then run for real
```

### 2. Review Deleted Folder Regularly
```bash
# Don't let it fill up
ls -lh /mnt/media/Deleted/Movies/

# Review files
# Delete when satisfied
# Or keep as backup for a while
```

### 3. Monitor Disk Space
```bash
# Deleted folder uses space!
du -sh /mnt/media/Deleted/*

# Clean up old files periodically
find /mnt/media/Deleted/ -type f -mtime +30 -delete  # Delete files older than 30 days
```

### 4. Test with Small Batches
```bash
# Start with 10 files
--max-files 10

# Verify they sync correctly
# Check Deleted folder
# Verify quality upgrades worked

# Then scale up
--max-files 100
--max-files 1000
# Finally, no limit
```

---

## 🎯 Decision Matrix

| Scenario | Ali Has | Chris Has | Result |
|----------|---------|-----------|--------|
| **Different Res** | Avatar 1080p | Avatar 2160p | Both kept in separate folders |
| **Same Res, Ali Better** | Avatar 1080p Remux (1800) | Avatar 1080p BluRay (1500) | Keep Ali's, Chris gets nothing |
| **Same Res, Chris Better** | Avatar 1080p BluRay (1500) | Avatar 1080p Remux (1800) | Move Ali's to Deleted, copy Chris's |
| **Ali Only** | Matrix 1080p | Nothing | Chris gets copy |
| **Chris Only** | Nothing | Inception 1080p | Ali gets copy |
| **Equal Quality** | Avatar 1080p Remux (1800) | Avatar 1080p Remux (1800) | Keep both (no action) |

---

## 📁 Deleted Folder Management

### Automatic Timestamping
```
If conflict exists, timestamp is added:
Avatar (2009) 1080p BluRay.mkv
Avatar (2009) 1080p BluRay_20241226_143022.mkv  ← Timestamp added
```

### Cleanup Script (Optional)
```bash
#!/bin/bash
# cleanup_deleted.sh - Clean up old files from Deleted folder

# Delete files older than 30 days
find /mnt/media/Deleted/ -type f -mtime +30 -delete

# Or ask for confirmation
find /mnt/media/Deleted/ -type f -mtime +30 -exec rm -i {} \;
```

---

## 📝 Quick Reference Commands

### Upload to GitHub (WSL)
```bash
cd /home/alig/projects/mother
git add scripts/compare_libraries.py scripts/sync_with_deleted.py docs/SYNC_GUIDE.md
git commit -m "Fix comparison script and add sync with Deleted folder protection"
git push origin main
```

### Pull on Mother
```bash
ssh mother
cd /opt/mother
git pull origin main
chmod +x scripts/*.sh scripts/*.py
```

### Run Fixed Comparisons
```bash
cd /opt/mother
./scripts/run_all_comparisons.sh
```

### Execute Sync (Always Dry Run First!)
```bash
# Movies: Chris → Ali
python3 scripts/sync_with_deleted.py \
  -s reports/movies/sync_plan_*.csv \
  -si inventories/chris_movies.json \
  -di inventories/ali_movies.json \
  -t movies \
  -d "Chris → Ali" \
  --dry-run --max-files 10

# After testing, run for real
python3 scripts/sync_with_deleted.py \
  -s reports/movies/sync_plan_*.csv \
  -si inventories/chris_movies.json \
  -di inventories/ali_movies.json \
  -t movies \
  -d "Chris → Ali"
```

### Review Deleted Folder
```bash
# Check size
du -sh /mnt/media/Deleted/*

# List files
ls -lh /mnt/media/Deleted/Movies/

# Delete old files
find /mnt/media/Deleted/ -type f -mtime +30 -delete
```

---

## ✅ Summary

**What the Fixed Scripts Do:**
1. ✅ `compare_libraries.py` - Correctly handles multiple versions, shows real quality differences
2. ✅ `sync_with_deleted.py` - Syncs with protection, moves replaced files to Deleted folder
3. ✅ No automatic deletions - you review and delete manually
4. ✅ Safe testing with dry run mode

**Workflow:**
1. Generate inventories ✅ (done)
2. Run fixed comparisons
3. Review reports
4. Dry run sync (test with 10 files)
5. Execute real sync
6. Review Deleted folder
7. Delete old files manually when satisfied

**Result:**
- ✅ Best quality versions in active libraries
- ✅ Old versions safely in Deleted folder
- ✅ No accidental data loss
- ✅ Full control over what gets deleted

**Ready to sync! 🚀**
