# TV Show Fix - Quick Action Plan

## 🎯 The Problem

TV comparison is matching **different shows**! 

Example bad matches:
- "Season 17": Ghost Adventures S17E02 vs Family Guy S17E17 ❌
- "03": Random show S03E02 vs Different show S03E04 ❌

**Root cause:** Chris's TV folder structure has nested season folders:
```
/rs-tv/The IT Crowd/03/S03E02.m4v
```

The inventory script extracted "03" as the title instead of "The IT Crowd"!

---

## ✅ The Solution

**File created:** `scripts/generate_inventory_fixed.py`

This fixed script detects season folders ("01", "Season 01", "S01", etc.) and goes up one level to get the actual show name.

---

## 🚀 Steps to Fix (Copy/Paste)

### Step 1: Rename Files in WSL

**Manual steps (can't script this from WSL):**

1. Open File Explorer
2. Navigate to: `\\wsl.localhost\Ubuntu\home\alig\projects\mother\scripts\`
3. Rename `generate_inventory.py` → `generate_inventory_old.py` (backup)
4. Rename `generate_inventory_fixed.py` → `generate_inventory.py`

**OR use Git Bash:**
```bash
cd /home/alig/projects/mother/scripts
mv generate_inventory.py generate_inventory_old.py
mv generate_inventory_fixed.py generate_inventory.py
```

### Step 2: Commit to GitHub
```bash
cd /home/alig/projects/mother

git add scripts/generate_inventory.py
git add docs/TV_INVENTORY_FIX.md
git add docs/TV_FIX_SUMMARY.md
git commit -m "Fix TV show title extraction for nested season folders"
git push origin main
```

### Step 3: Pull on Mother
```bash
ssh mother
cd /opt/mother
git pull origin main
chmod +x scripts/*.py
```

### Step 4: Re-Generate Chris's TV Inventory
```bash
# On Mother
cd /opt/mother

# Backup old inventory
mv inventories/chris_tv.json inventories/chris_tv_old.json
mv inventories/chris_tv.csv inventories/chris_tv_old.csv

# Re-scan with FIXED script
python3 scripts/generate_inventory.py /mnt/synology/rs-tv -o inventories/chris_tv

# Verify titles are correct
head -50 inventories/chris_tv.json | grep '"title"'
# Should show: "The IT Crowd", "Van Helsing", etc.
# NOT: "01", "03", "Season 17", etc.
```

### Step 5: Re-Run TV Comparison
```bash
cd /opt/mother

# Delete old reports
rm -rf reports/tv/*

# Run fresh comparison
python3 scripts/compare_libraries.py \
  inventories/ali_tv.json \
  inventories/chris_tv.json \
  -o reports/tv

# Check the results
cat reports/tv/comparison_summary_*.txt | head -100
```

### Step 6: Verify Results

Look for proper show matching:
```
✅ GOOD: Title: "The IT Crowd"
         Comparing: IT Crowd S03E02 vs IT Crowd S03E04

❌ BAD:  Title: "03"
         Comparing: Random show vs Different show
```

---

## 📊 What You Should See

**Old (BROKEN):**
```
Title: "03"
Title: "Season 17"  
Title: "1933"
Title: "06"
```

**New (FIXED):**
```
Title: "The IT Crowd"
Title: "Ghost Adventures"
Title: "Family Guy"
Title: "Van Helsing"
```

---

## ⏱️ Time Estimate

- Rename files: 1 minute
- Commit & push: 1 minute
- Pull on Mother: 30 seconds
- Re-scan Chris TV: ~5-10 minutes (depends on library size)
- Re-run comparison: ~2 minutes
- **Total: ~10-15 minutes**

---

## 🎯 Files to Commit

```bash
git add scripts/generate_inventory.py  # The fixed version
git add docs/TV_INVENTORY_FIX.md
git add docs/TV_FIX_SUMMARY.md
```

---

**Ready to fix! This will make TV comparisons actually work! 🎬**
