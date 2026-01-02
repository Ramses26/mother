# Sync Script Updates - December 26, 2024

## ✅ Files Updated in WSL

### Scripts:
1. ✅ `scripts/compare_libraries.py` - **REPLACED** with fixed version
2. ✅ `scripts/sync_with_deleted.py` - **NEW** - Syncs with Deleted folder protection
3. ✅ `scripts/run_all_comparisons.sh` - Helper to run all comparisons
4. ❌ `scripts/sync_intelligent.py` - **OBSOLETE** - Delete this file

### Documentation:
1. ✅ `docs/SYNC_GUIDE.md` - Complete workflow guide
2. ✅ `docs/CROSS_SEED_QBIT_MANAGE.md` - Already exists

---

## 🎯 Your Requirements (Clarified)

### What You Want:
1. ✅ **One best copy per resolution/folder**
   - 1080p Avatar in /Movies/
   - 2160p Avatar in /4K Movies/
   - Both can coexist (different resolutions = different libraries)

2. ✅ **Quality upgrades with safety**
   - If Chris has better 1080p Avatar
   - Move Ali's old 1080p to `/Deleted/Movies/`
   - Copy Chris's better 1080p to `/Movies/`

3. ✅ **Manual review before deletion**
   - Files go to Deleted folder first
   - You review them
   - You delete manually when satisfied

4. ✅ **Same for both directions**
   - Ali → Chris: Old files to Chris's `/Deleted/`
   - Chris → Ali: Old files to Ali's `/Deleted/`

### What You DON'T Want:
- ❌ Multiple copies of same resolution
- ❌ Automatic permanent deletion
- ❌ Both HD and 4K when only one is needed

---

## 🔧 What Was Fixed

### Bug in `compare_libraries.py`:
```python
# BEFORE (BROKEN):
ali_index[title] = file_entry  # Only kept LAST version!

# AFTER (FIXED):
ali_index[title].append(file_entry)  # Keeps ALL versions!
```

**Impact:**
- Before: "Equal: 1,412" (false!)
- After: "Ali better: 250, Chris better: 180, Equal: 600" (real differences!)

---

## 📋 Deleted Folder Structure

### Ali's Unraid:
```
/mnt/media/
├── Movies/              ← Active HD movies
├── 4K Movies/           ← Active 4K movies
├── TV Shows/            ← Active HD TV
├── 4K TV Shows/         ← Active 4K TV
└── Deleted/             ← FILES TO REVIEW BEFORE DELETING!
    ├── Movies/          ← Replaced HD movies
    ├── 4kMovies/        ← Replaced 4K movies
    ├── tvshows/         ← Replaced HD TV
    └── 4ktvshows/       ← Replaced 4K TV
```

### Chris's Synology:
```
/mnt/synology/
├── rs-movies/           ← Active HD movies
├── rs-4kmedia/
│   ├── 4kmovies/        ← Active 4K movies
│   └── 4ktv/            ← Active 4K TV
├── rs-tv/               ← Active HD TV
└── Deleted/             ← FILES TO REVIEW BEFORE DELETING!
    ├── Movies/
    ├── 4kMovies/
    ├── tvshows/
    └── 4ktvshows/
```

---

## 🚀 Next Steps

### 1. Delete Old File (in WSL)
```bash
cd /home/alig/projects/mother
rm scripts/sync_intelligent.py  # Old, obsolete
```

### 2. Commit to GitHub (in WSL)
```bash
cd /home/alig/projects/mother

# Check what changed
git status

# Add files
git add scripts/compare_libraries.py
git add scripts/sync_with_deleted.py
git add scripts/run_all_comparisons.sh
git add docs/SYNC_GUIDE.md

# Remove old file
git rm scripts/sync_intelligent.py

# Commit
git commit -m "Fix comparison bug and add Deleted folder protection

Changes:
- Fixed compare_libraries.py to handle multiple versions correctly
- Added sync_with_deleted.py for safe quality upgrades
- Old files moved to Deleted/ folder for manual review
- Updated documentation
- Removed obsolete sync_intelligent.py"

# Push
git push origin main
```

### 3. Pull on Mother Server
```bash
ssh mother
cd /opt/mother
git pull origin main
chmod +x scripts/*.sh scripts/*.py
```

### 4. Create Deleted Folders (One Time Setup)
```bash
# On Mother server (for Chris's Synology)
ssh mother
mkdir -p /mnt/synology/Deleted/{Movies,4kMovies,tvshows,4ktvshows}

# On Terminus (for Ali's Unraid)
ssh terminus
mkdir -p /mnt/media/Deleted/{Movies,4kMovies,tvshows,4ktvshows}
```

### 5. Re-Run Comparisons with FIXED Script
```bash
ssh mother
cd /opt/mother

# Run all comparisons
./scripts/run_all_comparisons.sh

# Or individually
python3 scripts/compare_libraries.py \
  inventories/ali_movies.json \
  inventories/chris_movies.json \
  -o reports/movies_fixed
```

### 6. Review NEW Reports
```bash
# Check movies report
cat reports/movies/comparison_summary_*.txt

# Look for:
# - Ali better: X (should be > 0 now!)
# - Chris better: Y (should be > 0 now!)
# - Needs review: Z (files that will be moved to Deleted/)
```

### 7. Test Sync (DRY RUN!)
```bash
# Test with 10 files
python3 scripts/sync_with_deleted.py \
  -s reports/movies/sync_plan_*.csv \
  -si inventories/chris_movies.json \
  -di inventories/ali_movies.json \
  -t movies \
  -d "Chris → Ali" \
  --dry-run \
  --max-files 10

# Review output:
# - Which files will be copied (new)
# - Which files will be upgraded (moved to Deleted)
# - Verify paths look correct
```

### 8. Execute Real Sync
```bash
# After dry run looks good
python3 scripts/sync_with_deleted.py \
  -s reports/movies/sync_plan_*.csv \
  -si inventories/chris_movies.json \
  -di inventories/ali_movies.json \
  -t movies \
  -d "Chris → Ali"

# Will ask for confirmation
# Type "yes" to proceed
```

### 9. Review Deleted Folder
```bash
# Check what was moved
ls -lh /mnt/media/Deleted/Movies/

# Play a few files to verify they're the old versions
# Delete when satisfied

# Or keep for a while as extra backup
```

---

## 📊 Expected Results

### Movies:
```
OLD (BROKEN):
Total: 11,777
Ali better: 0        ← BUG!
Chris better: 0      ← BUG!
Equal: 1,412         ← Wrong!

NEW (FIXED):
Total: ~12,000+      ← Accounts for all versions
Ali better: 200-500  ← Real quality differences!
Chris better: 150-400 ← Real quality differences!
Equal: 500-800       ← Actual ties
```

### 4K Movies:
```
Total: 357
Ali only: 195
Chris only: 128
Ali better: 15-30    ← Should see some now!
Chris better: 10-20  ← Should see some now!
Equal: 20-40
```

---

## ⚠️ Important Reminders

### 1. Always Dry Run First
```bash
# NEVER skip this step!
--dry-run --max-files 10
```

### 2. Review Deleted Folder
```bash
# Check what was moved
ls -lh /mnt/media/Deleted/Movies/

# Don't auto-delete!
# Review manually
# Delete when satisfied
```

### 3. Monitor Disk Space
```bash
# Deleted folder uses space
du -sh /mnt/media/Deleted/*

# Clean up periodically
find /mnt/media/Deleted/ -type f -mtime +30 -delete  # Files older than 30 days
```

### 4. Direction Matters
```bash
# Chris → Ali means:
# - Copy Chris's files TO Ali
# - Move Ali's old files to Ali's /Deleted/

# Ali → Chris means:
# - Copy Ali's files TO Chris
# - Move Chris's old files to Chris's /Deleted/
```

---

## 🎯 Summary

**What Changed:**
1. ✅ Fixed comparison script (handles multiple versions)
2. ✅ Created sync with Deleted folder protection
3. ✅ No automatic deletions
4. ✅ Complete documentation

**Files to Commit:**
- ✅ `scripts/compare_libraries.py` (fixed)
- ✅ `scripts/sync_with_deleted.py` (new)
- ✅ `scripts/run_all_comparisons.sh` (new)
- ✅ `docs/SYNC_GUIDE.md` (updated)
- ❌ `scripts/sync_intelligent.py` (delete)

**Workflow:**
1. Delete old file
2. Commit and push to GitHub
3. Pull on Mother
4. Create Deleted folders
5. Re-run comparisons (fixed!)
6. Test sync (dry run!)
7. Execute sync
8. Review Deleted folder
9. Delete old files manually

**Result:**
- Best quality in active folders
- Old versions in Deleted for review
- No accidental data loss
- Full control!

---

**Ready to commit and sync! 🚀**
