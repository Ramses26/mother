# Scanning Progress - Monitor & Verify

**Scans Started:** 2024-12-25
**Expected Duration:** 4-6 hours total

---

## 🔍 Quick Status Check

### On Terminus (Ali's Scans)
```bash
ssh terminus

# Check screen sessions
screen -ls

# Should show 4 sessions:
# - movies
# - 4kmovies
# - tv
# - 4ktv

# Check output files
ls -lh ~/inventories/

# Watch files grow
watch -n 10 'ls -lh ~/inventories/'
```

### On Mother (Chris's Scans)
```bash
ssh mother

# Check screen sessions
screen -ls

# Should show 4 sessions:
# - chris_movies
# - chris_4kmovies
# - chris_tv
# - chris_4ktv

# Check output files
ls -lh /opt/mother/inventories/

# Watch files grow
watch -n 10 'ls -lh /opt/mother/inventories/'
```

---

## 👀 Watch Live Progress

### Attach to a Screen Session
```bash
# On Terminus
screen -r movies

# See live output:
# Processing: /mnt/media/Movies/Avatar (2009)/Avatar.2009.mkv
# [Progress bar]

# Detach: Press Ctrl+A, then D
```

### Check File Counts
```bash
# On Terminus
wc -l ~/inventories/ali_movies.csv
# Shows how many movies processed so far

# On Mother
wc -l /opt/mother/inventories/chris_movies.csv
```

---

## 📊 Verify Scans Are Working

### All-in-One Status Script

**On Terminus:**
```bash
echo "=== Screen Sessions ==="
screen -ls
echo -e "\n=== Files ==="
ls -lh ~/inventories/ 2>/dev/null || echo "No files yet"
echo -e "\n=== Counts ==="
for f in ~/inventories/*.csv; do [ -f "$f" ] && echo "$(basename $f): $(wc -l < $f) entries"; done
```

**On Mother:**
```bash
echo "=== Screen Sessions ==="
screen -ls
echo -e "\n=== Files ==="
ls -lh /opt/mother/inventories/
echo -e "\n=== Counts ==="
for f in /opt/mother/inventories/*.csv; do [ -f "$f" ] && echo "$(basename $f): $(wc -l < $f) entries"; done
```

---

## ✅ Expected Results

### When Complete

**Terminus (~/inventories/):**
- ali_movies.json
- ali_movies.csv
- ali_4kmovies.json
- ali_4kmovies.csv
- ali_tv.json
- ali_tv.csv
- ali_4ktv.json
- ali_4ktv.csv

**Mother (/opt/mother/inventories/):**
- chris_movies.json
- chris_movies.csv
- chris_4kmovies.json
- chris_4kmovies.csv
- chris_tv.json
- chris_tv.csv
- chris_4ktv.json
- chris_4ktv.csv

**Total:** 16 files (8 Ali + 8 Chris)

---

## 🆘 If Something Goes Wrong

### Scan Stopped
```bash
# Reattach to see error
screen -r movies

# If crashed, restart
python3 ~/generate_inventory.py "/mnt/media/Movies" -o ~/inventories/ali_movies
```

### No Files Being Created
```bash
# Check directory exists
ls -la ~/inventories/

# Check permissions
mkdir -p ~/inventories
```

### Mount Missing
```bash
# Check Unraid mount
df -h | grep media

# Remount if needed
sudo mount -a
```

---

## 📋 After Scans Complete

### 1. Copy Ali's Files to Mother
```bash
# From Terminus, copy to Mother
scp ~/inventories/ali_*.* mother:/opt/mother/inventories/

# Verify on Mother
ssh mother
ls -lh /opt/mother/inventories/
# Should see all 16 files
```

### 2. Run Comparisons
```bash
# On Mother
cd /opt/mother

# Compare movies
python3 scripts/compare_libraries.py \
  inventories/ali_movies.json \
  inventories/chris_movies.json \
  -o reports/movies

# Compare 4K movies
python3 scripts/compare_libraries.py \
  inventories/ali_4kmovies.json \
  inventories/chris_4kmovies.json \
  -o reports/4kmovies

# Compare TV
python3 scripts/compare_libraries.py \
  inventories/ali_tv.json \
  inventories/chris_tv.json \
  -o reports/tv

# Compare 4K TV
python3 scripts/compare_libraries.py \
  inventories/ali_4ktv.json \
  inventories/chris_4ktv.json \
  -o reports/4ktv
```

### 3. Review Reports
```bash
cd /opt/mother/reports

# View summaries
cat movies/comparison_summary_*.txt
cat 4kmovies/comparison_summary_*.txt
cat tv/comparison_summary_*.txt
cat 4ktv/comparison_summary_*.txt
```

---

## ⏱️ Progress Tracking

Check every hour or so:

```bash
# Quick check - how many files processed?
# On Terminus:
wc -l ~/inventories/*.csv

# On Mother:
wc -l /opt/mother/inventories/*.csv
```

---

**Don't obsess over checking - let the scans run! Configure services instead!** 🎯
