# USB Transfer Plan - Project Mother

**Created:** 2026-01-24

## Overview

After ~1 month of network transfers, only ~4.3% has been synced. With ~159 TB per side and slow VPN transfers, a USB "sneakernet" approach is much faster.

**Hardware:** 20 TB USB 3.0 Hard Drive

## Current Sync Status

### Transfers Needed (from sync scripts dated 2026-01-22)

| Direction | Movies | TV Episodes | Estimated Size |
|-----------|--------|-------------|----------------|
| Ali → Chris | 2,175 | 20,739 | TBD |
| Chris → Ali | 1,895 | 22,769 | TBD |

### Library Stats (from INITIAL_SYNC.md)

**Ali's Unraid:**
- Movies: 66.3 TB
- TV Shows: 82.3 TB
- 4K: ~10 TB
- **Total: ~159 TB**

**Chris's Synology:**
- Movies: 73.7 TB
- TV Shows: ~85 TB
- **Total: ~159 TB**

---

## USB 3.0 Transfer Time Estimates

| Data Size | Est. Time (300 MB/s avg) |
|-----------|--------------------------|
| 5 TB | ~4.5 hours |
| 10 TB | ~9 hours |
| 15 TB | ~14 hours |
| 19.5 TB | ~18 hours |

**Note:** Real-world USB 3.0 averages 300-400 MB/s for large sequential files. Small files will be slower.

---

## Phase 1: Calculate Actual Sizes

Before deciding what to transfer, run these size calculation scripts.

### Step 1: Calculate Ali→Chris Sizes

Run this on Mother when mounts are accessible:

```bash
# Calculate movie sizes (Ali→Chris)
/home/alig/projects/mother/scripts/usb_calculate_sizes.py \
  --script /home/alig/projects/mother/reports/sync_actions_20260122_180402.sh \
  --direction ali-to-chris \
  --output /home/alig/projects/mother/reports/ali_to_chris_sizes.csv

# Calculate TV sizes (Ali→Chris)
/home/alig/projects/mother/scripts/usb_calculate_sizes.py \
  --script /home/alig/projects/mother/reports/tv_sync_actions_20260122_180402.sh \
  --direction ali-to-chris \
  --output /home/alig/projects/mother/reports/ali_to_chris_tv_sizes.csv
```

### Step 2: Calculate Chris→Ali Sizes

```bash
# Calculate movie sizes (Chris→Ali)
/home/alig/projects/mother/scripts/usb_calculate_sizes.py \
  --script /home/alig/projects/mother/reports/sync_actions_20260122_180402.sh \
  --direction chris-to-ali \
  --output /home/alig/projects/mother/reports/chris_to_ali_sizes.csv

# Calculate TV sizes (Chris→Ali)
/home/alig/projects/mother/scripts/usb_calculate_sizes.py \
  --script /home/alig/projects/mother/reports/tv_sync_actions_20260122_180402.sh \
  --direction chris-to-ali \
  --output /home/alig/projects/mother/reports/chris_to_ali_tv_sizes.csv
```

---

## Phase 2: Prioritization Strategy

Since we likely have more than 20TB to transfer each way, we need to prioritize.

### Recommended Priority Order:

1. **Movies first** - Higher visibility, fewer files, faster to copy
2. **Popular/recent TV shows** - Can be identified by file date or show name
3. **Remaining TV shows** - May need multiple trips

### Decision Points:

After calculating sizes, decide:
- If Ali→Chris total ≤ 19.5 TB: Do it all in one trip
- If total > 19.5 TB: Prioritize movies, then largest TV shows
- Save remaining for second trip or continued network sync

---

## Phase 3: USB Transfer Scripts

### Trip 1: Ali's House → Chris's House

**Step A: Copy Ali's data TO USB (at Ali's house)**

Mount the USB drive and run:
```bash
# Mount USB (adjust device as needed)
sudo mount /dev/sdb1 /mnt/usb

# Run the copy script
/home/alig/projects/mother/scripts/usb_copy_ali_to_usb.sh /mnt/usb
```

**Step B: Copy FROM USB to Chris's Synology (at Chris's house)**

```bash
# On a machine with access to Chris's Synology
# Mount USB and run:
/home/alig/projects/mother/scripts/usb_copy_usb_to_chris.sh /mnt/usb
```

### Trip 1 Return: Chris's data → Ali

**Step C: Copy Chris's data TO USB (at Chris's house)**

```bash
/home/alig/projects/mother/scripts/usb_copy_chris_to_usb.sh /mnt/usb
```

**Step D: Copy FROM USB to Ali's Unraid (at Ali's house)**

```bash
/home/alig/projects/mother/scripts/usb_copy_usb_to_ali.sh /mnt/usb
```

---

## Phase 4: Post-Transfer Verification

After USB transfers complete:

1. Run inventory scans on both sides
2. Re-run compare scripts to verify sync
3. Network sync handles any stragglers

---

## Script Locations

| Script | Purpose |
|--------|---------|
| `usb_calculate_sizes.py` | Calculate sizes from sync scripts |
| `usb_copy_ali_to_usb.sh` | Copy Ali's files to USB |
| `usb_copy_usb_to_chris.sh` | Copy from USB to Chris's Synology |
| `usb_copy_chris_to_usb.sh` | Copy Chris's files to USB |
| `usb_copy_usb_to_ali.sh` | Copy from USB to Ali's Unraid |

---

## Questions to Consider

1. **USB Drive Format:** exFAT recommended (works on Linux, macOS, Windows, no 4GB file limit)

2. **Multiple Trips:** If >20TB each way, plan for multiple trips

3. **What about already-synced files?** The scripts should check progress files and skip completed items

4. **Verification:** Use checksums or rsync's verify mode?

---

## Next Steps

1. **Reboot Mother** to clear stuck NFS state (processes in D state)
2. **Run size calculation** to see if we're under 19.5 TB per direction:
   ```bash
   cd /home/alig/projects/mother/scripts

   # Check Ali->Chris sizes
   ./usb_calculate_sizes.py \
     --script ../reports/sync_actions_20260122_180402.sh \
     --direction ali-to-chris \
     --output ../reports/ali_to_chris_movie_sizes.csv

   ./usb_calculate_sizes.py \
     --script ../reports/tv_sync_actions_20260122_180402.sh \
     --direction ali-to-chris \
     --output ../reports/ali_to_chris_tv_sizes.csv
   ```
3. **Generate USB copy scripts**:
   ```bash
   ./usb_generate_copy_scripts.py \
     --movie-script ../reports/sync_actions_20260122_180402.sh \
     --tv-script ../reports/tv_sync_actions_20260122_180402.sh \
     --output-dir ../reports/usb_scripts
   ```
4. **Execute the plan** (see script usage below)

---

## Generated Scripts Location

After running the generator, scripts will be at:
```
/home/alig/projects/mother/reports/usb_scripts/
├── usb_copy_ali_to_usb.sh      # Step 1: At Ali's house
├── usb_copy_usb_to_chris.sh    # Step 2: At Chris's house
├── usb_copy_chris_to_usb.sh    # Step 3: At Chris's house
└── usb_copy_usb_to_ali.sh      # Step 4: Back at Ali's house
```

---

## Gaps & Considerations

1. **If total > 19.5 TB**: Need to prioritize or make multiple trips
2. **USB Format**: Use exFAT for cross-platform compatibility (no 4GB limit)
3. **Already completed items**: Scripts use progress files to skip already-done items
4. **Verification**: rsync uses checksums for data integrity
