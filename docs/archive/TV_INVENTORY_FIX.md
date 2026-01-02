# TV Show Inventory Fix

**Issue:** Chris's TV shows use nested season folders, causing title extraction to fail.

## Folder Structure Comparison

**Ali's TV (works correctly):**
```
/TV Shows/Battlestar Galactica/S01E01.mkv
          └─ title: "Battlestar Galactica" ✅
```

**Chris's TV (broken):**
```
/rs-tv/The IT Crowd/03/S03E02.m4v
       └─ should be: "The IT Crowd" ✅
                  └─ but gets: "03" ❌
```

## Root Cause

In `generate_inventory.py` line 165:
```python
parent_dir = file_path.parent.name  # Gets immediate parent!
```

For files in season subfolders, this extracts the season number instead of show name.

## Solution

Detect if parent folder is a season folder (numeric or "Season XX") and go up one level:

```python
def _get_show_title(self, file_path: Path) -> str:
    """
    Extract show/movie title from file path
    Handles both flat and season-subfolder structures
    
    Examples:
        /Movies/Avatar (2009)/Avatar.mkv → "Avatar (2009)"
        /TV/Battlestar/S01E01.mkv → "Battlestar"
        /TV/IT Crowd/03/S03E02.mkv → "IT Crowd" (goes up 1 level!)
    """
    parent_name = file_path.parent.name
    
    # Check if parent folder looks like a season folder
    # Pattern: "01", "02", "Season 1", "Season 01", "S01", etc.
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

Then update line 165:
```python
# OLD:
parent_dir = file_path.parent.name

# NEW:
parent_dir = self._get_show_title(file_path)
```

## Testing

After fix, Chris's inventory should show:
```json
{
  "title": "The IT Crowd",  // ✅ Not "03"!
  "filename": "S03E02 - Are We Not Men HDTV-1080p.m4v",
  ...
}
```

## Re-generate Inventories

```bash
# On Mother
cd /opt/mother

# Re-scan Chris's TV with fixed script
python3 scripts/generate_inventory.py /mnt/synology/rs-tv -o inventories/chris_tv

# Verify titles
head -20 inventories/chris_tv.json | grep title
# Should show show names, not season numbers!

# Re-run comparison
python3 scripts/compare_libraries.py \
  inventories/ali_tv.json \
  inventories/chris_tv.json \
  -o reports/tv

# Should now match properly!
```

## Why This Fix Works

**Before:**
- Chris title: "03"
- Ali title: "Battlestar Galactica"
- normalize("03") → "03"
- normalize("Battlestar Galactica") → "battlestar galactica"
- ❌ Never match!

**After:**
- Chris title: "The IT Crowd" (extracted from grandparent folder)
- Ali title: "The IT Crowd"
- normalize("The IT Crowd") → "it crowd"
- normalize("The IT Crowd") → "it crowd"
- ✅ MATCH!

**Result:** Proper show-to-show matching across different folder structures!
