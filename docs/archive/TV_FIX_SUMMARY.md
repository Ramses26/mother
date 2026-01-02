# TV Shows Comparison Fix - Summary

## 🐛 Root Cause Identified

Chris's TV shows use nested season folders, causing title extraction to fail:

```
Chris: /rs-tv/The IT Crowd/03/S03E02.m4v
              └─ should get: "The IT Crowd"
                          └─ but gets: "03" ❌

Ali:   /TV Shows/Battlestar Galactica/S01E01.mkv  
                 └─ correctly gets: "Battlestar Galactica" ✅
```

## 📝 The Fix

**File:** `scripts/generate_inventory.py`

**Added method `_get_show_title()` to detect season folders:**

```python
def _get_show_title(self, file_path: Path) -> str:
    """
    Extract show/movie title from file path
    Handles both flat and season-subfolder structures
    """
    parent_name = file_path.parent.name
    
    # Check if parent folder looks like a season folder
    season_patterns = [
        r'^\d{1,2}$',  # Just numbers: "01", "1", "15"
        r'^Season\s*\d+$',  # "Season 1", "Season 01"
        r'^S\d{1,2}$',  # "S1", "S01"
    ]
    
    is_season_folder = any(
        re.match(pattern, parent_name, re.IGNORECASE)
        for pattern in season_patterns
    )
    
    if is_season_folder:
        # Go up one more level to get show name
        return file_path.parent.parent.name
    else:
        # Use immediate parent
        return parent_name
```

**Changed line 165:**
```python
# OLD:
parent_dir = file_path.parent.name

# NEW:
parent_dir = self._get_show_title(file_path)
```

## ✅ Steps to Apply Fix

### 1. Replace Script in WSL
```bash
cd ~/projects/mother/scripts

# Backup old version
cp generate_inventory.py generate_inventory_old.py

# Copy fixed version
cp generate_inventory_fixed.py generate_inventory.py

# Or just delete the fixed one since it's now the main one
rm generate_inventory_fixed.py
```

### 2. Commit to GitHub
```bash
cd ~/projects/mother

git add scripts/generate_inventory.py docs/TV_INVENTORY_FIX.md
git commit -m "Fix TV show title extraction for nested season folders

- Added _get_show_title() method to detect season folders
- Now properly extracts show name from /Show/Season/Episode.mkv structure
- Fixes comparison matching for Chris's TV library"

git push origin main
```

### 3. Pull on Mother and Re-Scan
```bash
ssh mother
cd /opt/mother

# Pull latest
git pull origin main
chmod +x scripts/*.py

# Re-scan Chris's TV with FIXED script
python3 scripts/generate_inventory.py /mnt/synology/rs-tv -o inventories/chris_tv

# Verify titles are correct now
head -50 inventories/chris_tv.json | grep '"title"'
# Should show show names like "The IT Crowd", not "03"!
```

### 4. Re-Run TV Comparison
```bash
cd /opt/mother

# Compare TV shows again with fixed inventories
python3 scripts/compare_libraries.py \
  inventories/ali_tv.json \
  inventories/chris_tv.json \
  -o reports/tv_fixed

# Check the report
cat reports/tv_fixed/comparison_summary_*.txt | head -100
```

## 📊 Expected Results After Fix

**Before (BROKEN):**
```
Title: "03"
  Comparing: Ghost Adventures S02E04 vs Love on the Spectrum S02E01
  DIFFERENT SHOWS! ❌

Title: "Season 17"
  Comparing: Ghost Adventures S17E02 vs Family Guy S17E17
  DIFFERENT SHOWS! ❌
```

**After (FIXED):**
```
Title: "The IT Crowd"
  Comparing: The IT Crowd S03E02 vs The IT Crowd S03E02
  SAME SHOW! ✅

Title: "Ghost Adventures"
  Comparing: Ghost Adventures S02E04 vs Ghost Adventures S02E04
  SAME SHOW! ✅
```

## 🎯 What This Fixes

1. ✅ Title extraction from nested season folders
2. ✅ Proper show-to-show matching
3. ✅ Accurate quality comparisons
4. ✅ Correct sync planning for TV shows

## ⚠️ Important Notes

**Re-scan both inventories:**
- Chris's inventory MUST be re-generated
- Ali's inventory is fine but re-scan for consistency
- Delete old reports/tv/* before re-running comparison

**Folder structures handled:**
- ✅ `/Show Name/Episode.mkv` (Ali's structure)
- ✅ `/Show Name/01/Episode.mkv` (Chris's structure)
- ✅ `/Show Name/Season 01/Episode.mkv` (also supported)
- ✅ `/Show Name/S01/Episode.mkv` (also supported)

**NOT a comparison script issue:**
- The comparison script is fine
- The inventory generation was broken
- Now both produce correct titles for matching

---

**Status:** ✅ FIXED - Ready to deploy and re-scan!
