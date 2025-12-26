# TV Fix Screen Session - Quick Start

## 🗑️ Step 1: Clean Up Old Files (Run First!)

```bash
ssh mother
cd /opt/mother

# Delete old broken TV inventories
rm inventories/chris_tv.json
rm inventories/chris_tv.csv
rm inventories/chris_tv_old.json 2>/dev/null
rm inventories/chris_tv_old.csv 2>/dev/null

# Delete old broken TV reports
rm -rf reports/tv/*

# Verify cleanup
ls inventories/chris_tv* 2>/dev/null || echo "✅ Old files deleted"
```

---

## 🖥️ Step 2: Run in Screen Session

```bash
# Start a new screen session named "tv-fix"
screen -S tv-fix

# Inside screen, run the inventory scan
cd /opt/mother
python3 scripts/generate_inventory.py /mnt/synology/rs-tv -o inventories/chris_tv

# This will take 5-10 minutes...
```

---

## 🔌 Step 3: Detach and Work

**To detach from screen (leave it running):**
```
Press: Ctrl+A then D
```

You'll see: `[detached from 12345.tv-fix]`

Now you can close SSH, work on other things, etc!

---

## 👀 Step 4: Check Progress

```bash
# Re-attach to see progress
screen -r tv-fix

# Or just check if it's still running
screen -ls

# Check how many files processed so far
wc -l /opt/mother/inventories/chris_tv.json
```

---

## ✅ Step 5: After It Finishes

```bash
# Re-attach to screen
screen -r tv-fix

# Verify the file looks good
head -50 inventories/chris_tv.json | grep '"title"'

# Should show show names like:
# "title": "The IT Crowd"
# "title": "Van Helsing"
# NOT: "title": "03", "title": "Season 17"

# Exit screen session
exit
```

---

## 🔄 Step 6: Run Comparison

```bash
ssh mother
cd /opt/mother

# Start another screen for comparison
screen -S tv-compare

# Run comparison
python3 scripts/compare_libraries.py \
  inventories/ali_tv.json \
  inventories/chris_tv.json \
  -o reports/tv

# Detach: Ctrl+A then D
```

---

## 📊 Step 7: Check Results

```bash
ssh mother
cd /opt/mother

# View the report
cat reports/tv/comparison_summary_*.txt | head -100

# Should now show proper matches!
```

---

## 🛠️ Useful Screen Commands

```bash
# List all screens
screen -ls

# Attach to a screen
screen -r tv-fix

# Detach from screen (while inside)
Ctrl+A then D

# Kill a screen (if stuck)
screen -X -S tv-fix quit

# Create new screen
screen -S my-name

# Attach to specific screen if multiple
screen -r 12345  # Use the number from screen -ls
```

---

## 🎯 Complete Workflow (One-Liner)

```bash
ssh mother "cd /opt/mother && rm -f inventories/chris_tv.* reports/tv/* && screen -dmS tv-fix bash -c 'python3 scripts/generate_inventory.py /mnt/synology/rs-tv -o inventories/chris_tv'"

# Check if it's running
ssh mother "screen -ls"

# Check progress
ssh mother "wc -l /opt/mother/inventories/chris_tv.json"
```

---

## ⏱️ Estimated Time

- Delete old files: 5 seconds
- Start screen: 2 seconds  
- Inventory scan: **5-10 minutes** (runs in background)
- Comparison: 2-3 minutes
- **Total: ~10-15 minutes** (but you can work during this!)

---

**Ready to start! Use the commands above! 🚀**
