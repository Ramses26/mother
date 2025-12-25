# Initial Data Synchronization - Project Mother

## Overview
This document outlines the process for analyzing, comparing, and performing the initial synchronization of media libraries between your Unraid server and Chris's Synology devices.

## Current Library Stats

### Your Unraid (192.168.1.10)
- **4K Movies**: 8.38 TB
- **Movies**: 66.3 TB
- **TV Shows**: 82.3 TB
- **4K TV Shows**: 1.94 TB
- **Total**: ~159 TB
- **Quality**: TRASHGuides compliant, quality-focused releases

### Chris's Synology
- **Movies**: 73.7 TB (RS-Movies: 10.0.0.160)
- **TV Shows**: ~85 TB (RS-TV: 10.0.0.88)
- **4K Content**: Unknown (RS-4KMedia: 10.0.1.203)
- **Total**: ~159+ TB
- **Quality**: Mixed, not TRASHGuides compliant

### Expected Overlap
- High duplicate count expected
- Your library likely has superior quality releases
- Some unique content on each side

## Phase 1: Data Collection & Analysis

### Step 1: Install Required Tools

#### On Mother Server
```bash
# File hashing and analysis tools
sudo apt install -y \
  python3 \
  python3-pip \
  mediainfo \
  ffmpeg \
  jq

# Python packages
pip3 install \
  tqdm \
  pandas \
  guessit \
  pymediainfo
```

#### On Your WSL
```bash
# Same as above
sudo apt update
sudo apt install -y python3 python3-pip mediainfo ffmpeg jq
pip3 install tqdm pandas guessit pymediainfo
```

### Step 2: Create File Inventory Scripts

#### Script: `generate_inventory.py`
```python
#!/usr/bin/env python3
"""
Generate comprehensive media inventory with hashes and metadata
"""
import os
import sys
import json
import hashlib
from pathlib import Path
from tqdm import tqdm
from pymediainfo import MediaInfo
import guessit

def get_file_hash(filepath, chunk_size=8192):
    """Calculate MD5 hash of file"""
    hasher = hashlib.md5()
    try:
        with open(filepath, 'rb') as f:
            while chunk := f.read(chunk_size):
                hasher.update(chunk)
        return hasher.hexdigest()
    except Exception as e:
        print(f"Error hashing {filepath}: {e}")
        return None

def get_media_info(filepath):
    """Extract media information"""
    try:
        media_info = MediaInfo.parse(filepath)
        
        video_track = next((t for t in media_info.tracks if t.track_type == "Video"), None)
        audio_tracks = [t for t in media_info.tracks if t.track_type == "Audio"]
        
        info = {
            "resolution": getattr(video_track, 'height', None) if video_track else None,
            "codec": getattr(video_track, 'codec', None) if video_track else None,
            "bitrate": getattr(video_track, 'bit_rate', None) if video_track else None,
            "hdr": "HDR" in str(getattr(video_track, 'colour_primaries', '')) if video_track else False,
            "dolby_vision": "Dolby Vision" in str(getattr(video_track, 'transfer_characteristics', '')) if video_track else False,
            "audio_codecs": [getattr(t, 'codec', '') for t in audio_tracks],
            "audio_channels": [getattr(t, 'channel_s', 0) for t in audio_tracks],
            "atmos": any("Atmos" in str(getattr(t, 'codec', '')) for t in audio_tracks),
            "file_size": os.path.getsize(filepath)
        }
        return info
    except Exception as e:
        print(f"Error getting media info for {filepath}: {e}")
        return {}

def parse_filename(filepath):
    """Parse filename using guessit"""
    try:
        guess = guessit.guessit(os.path.basename(filepath))
        return {
            "title": guess.get('title', ''),
            "year": guess.get('year', None),
            "season": guess.get('season', None),
            "episode": guess.get('episode', None),
            "release_group": guess.get('release_group', ''),
            "source": guess.get('source', ''),
            "resolution": guess.get('screen_size', ''),
            "video_codec": guess.get('video_codec', ''),
            "audio_codec": guess.get('audio_codec', ''),
        }
    except Exception as e:
        print(f"Error parsing {filepath}: {e}")
        return {}

def scan_directory(root_path, output_file, media_type="movie"):
    """Scan directory and create inventory"""
    inventory = []
    
    # Video extensions
    video_exts = {'.mkv', '.mp4', '.avi', '.m4v', '.ts'}
    
    print(f"Scanning {root_path}...")
    
    # Get all video files
    video_files = []
    for ext in video_exts:
        video_files.extend(Path(root_path).rglob(f"*{ext}"))
    
    print(f"Found {len(video_files)} video files")
    
    for filepath in tqdm(video_files, desc="Processing files"):
        try:
            file_str = str(filepath)
            
            # Parse filename
            parsed = parse_filename(file_str)
            
            # Get file hash (sample-based for speed)
            file_hash = get_file_hash(file_str)
            
            # Get media info
            media_info = get_media_info(file_str)
            
            entry = {
                "path": file_str,
                "filename": filepath.name,
                "hash": file_hash,
                "media_type": media_type,
                **parsed,
                **media_info
            }
            
            inventory.append(entry)
            
        except Exception as e:
            print(f"Error processing {filepath}: {e}")
            continue
    
    # Save to JSON
    with open(output_file, 'w') as f:
        json.dump(inventory, f, indent=2)
    
    print(f"Inventory saved to {output_file}")
    print(f"Total files: {len(inventory)}")

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python3 generate_inventory.py <root_path> <output_file> <media_type>")
        print("Example: python3 generate_inventory.py /mnt/media/Movies movies_inventory.json movie")
        sys.exit(1)
    
    root_path = sys.argv[1]
    output_file = sys.argv[2]
    media_type = sys.argv[3]
    
    scan_directory(root_path, output_file, media_type)
```

Save to: `\\wsl.localhost\Ubuntu\home\alig\projects\mother\scripts\sync\generate_inventory.py`

### Step 3: Generate Inventories

#### On Your Unraid (via WSL)
```bash
cd /home/alig/projects/mother/scripts/sync

# Mount Unraid if not already
# sudo mkdir -p /mnt/unraid
# sudo mount -t cifs //192.168.1.10/media /mnt/unraid -o credentials=/home/alig/.smbcreds

# Generate inventories
python3 generate_inventory.py "/mnt/unraid/Movies" "your_movies_hd.json" "movie"
python3 generate_inventory.py "/mnt/unraid/4K Movies" "your_movies_4k.json" "movie"
python3 generate_inventory.py "/mnt/unraid/TV Shows" "your_tv_hd.json" "tv"
python3 generate_inventory.py "/mnt/unraid/4K TV Shows" "your_tv_4k.json" "tv"
```

#### On Mother (for Chris's Synology)
```bash
cd /opt/mother/scripts/sync

# Generate inventories from mounted Synology shares
python3 generate_inventory.py "/mnt/synology/movies" "chris_movies_hd.json" "movie"
python3 generate_inventory.py "/mnt/synology/4kmovies" "chris_movies_4k.json" "movie"
python3 generate_inventory.py "/mnt/synology/tv" "chris_tv_hd.json" "tv"
python3 generate_inventory.py "/mnt/synology/4ktv" "chris_tv_4k.json" "tv"
```

**Note**: This will take a LONG time (possibly days) for 150+ TB. Consider:
- Running in `screen` or `tmux` sessions
- Processing in parallel if possible
- Starting with smaller subsets for testing

### Step 4: Compare Inventories

#### Script: `compare_libraries.py`
```python
#!/usr/bin/env python3
"""
Compare two media library inventories and generate sync plan
"""
import json
import sys
from collections import defaultdict

def load_inventory(filepath):
    """Load inventory JSON"""
    with open(filepath, 'r') as f:
        return json.load(f)

def normalize_title(title, year=None):
    """Normalize title for comparison"""
    # Remove special chars, lowercase, remove 'the'
    normalized = title.lower().strip()
    normalized = normalized.replace('the ', '').replace(' the', '')
    normalized = ''.join(c for c in normalized if c.isalnum() or c.isspace())
    
    if year:
        return f"{normalized}_{year}"
    return normalized

def quality_score(entry):
    """Calculate quality score based on TRASHGuides priorities"""
    score = 0
    
    # Resolution points
    if entry.get('resolution'):
        if entry['resolution'] >= 2160:
            score += 100
        elif entry['resolution'] >= 1080:
            score += 50
        elif entry['resolution'] >= 720:
            score += 25
    
    # Source points (Remux > Bluray > WEB-DL > WEBRip)
    source = entry.get('source', '').upper()
    if 'REMUX' in source or entry.get('source') == 'Blu-ray':
        score += 50
    elif 'BLURAY' in source or 'BRD' in source:
        score += 40
    elif 'WEB-DL' in source:
        score += 30
    elif 'WEBRIP' in source:
        score += 20
    
    # Codec points (x265/HEVC preferred for 4K)
    codec = entry.get('video_codec', '').upper()
    if entry.get('resolution', 0) >= 2160:
        if 'HEVC' in codec or 'H.265' in codec or 'X265' in codec:
            score += 20
    else:
        if 'H.264' in codec or 'X264' in codec:
            score += 10
    
    # HDR vs Dolby Vision (prefer HDR per requirements)
    if entry.get('hdr'):
        score += 30
    if entry.get('dolby_vision'):
        score += 20  # Lower than HDR
    
    # Audio points
    if entry.get('atmos'):
        score += 25
    
    audio_channels = max(entry.get('audio_channels', [0]))
    if audio_channels >= 8:
        score += 15
    elif audio_channels >= 6:
        score += 10
    
    # File size (bigger usually better for same release type)
    size_gb = entry.get('file_size', 0) / (1024**3)
    if size_gb > 0:
        score += min(size_gb / 10, 20)  # Cap at 20 points
    
    # Known good release groups (add more as needed)
    good_groups = ['FRAMESTOR', 'DON', 'HONE', 'iFT', 'TEPES', 'FLUX', 'EPSiLON']
    if entry.get('release_group') in good_groups:
        score += 15
    
    return score

def compare_inventories(inv1, inv2, name1="Library 1", name2="Library 2"):
    """Compare two inventories"""
    
    # Build lookup dicts
    lookup1 = defaultdict(list)
    lookup2 = defaultdict(list)
    
    for entry in inv1:
        key = normalize_title(entry.get('title', ''), entry.get('year'))
        if entry.get('media_type') == 'tv':
            key += f"_s{entry.get('season', 0):02d}e{entry.get('episode', 0):02d}"
        lookup1[key].append(entry)
    
    for entry in inv2:
        key = normalize_title(entry.get('title', ''), entry.get('year'))
        if entry.get('media_type') == 'tv':
            key += f"_s{entry.get('season', 0):02d}e{entry.get('episode', 0):02d}"
        lookup2[key].append(entry)
    
    # Comparison results
    only_in_1 = []
    only_in_2 = []
    in_both = []
    upgrade_from_1 = []  # Better in library 1
    upgrade_from_2 = []  # Better in library 2
    
    all_keys = set(lookup1.keys()) | set(lookup2.keys())
    
    for key in all_keys:
        entries1 = lookup1.get(key, [])
        entries2 = lookup2.get(key, [])
        
        if entries1 and not entries2:
            # Only in library 1
            only_in_1.extend(entries1)
        elif entries2 and not entries1:
            # Only in library 2
            only_in_2.extend(entries2)
        else:
            # In both - compare quality
            best1 = max(entries1, key=quality_score)
            best2 = max(entries2, key=quality_score)
            
            score1 = quality_score(best1)
            score2 = quality_score(best2)
            
            in_both.append({
                'key': key,
                'lib1_entry': best1,
                'lib2_entry': best2,
                'lib1_score': score1,
                'lib2_score': score2
            })
            
            # 10% threshold to avoid minor differences
            if score1 > score2 * 1.1:
                upgrade_from_1.append({
                    'key': key,
                    'source': best1,
                    'replace': best2,
                    'score_diff': score1 - score2
                })
            elif score2 > score1 * 1.1:
                upgrade_from_2.append({
                    'key': key,
                    'source': best2,
                    'replace': best1,
                    'score_diff': score2 - score1
                })
    
    # Generate report
    report = {
        'summary': {
            f'total_{name1}': len(inv1),
            f'total_{name2}': len(inv2),
            f'only_in_{name1}': len(only_in_1),
            f'only_in_{name2}': len(only_in_2),
            'in_both': len(in_both),
            f'upgrade_from_{name1}': len(upgrade_from_1),
            f'upgrade_from_{name2}': len(upgrade_from_2),
        },
        f'only_in_{name1}': only_in_1,
        f'only_in_{name2}': only_in_2,
        'in_both': in_both,
        f'upgrade_from_{name1}': upgrade_from_1,
        f'upgrade_from_{name2}': upgrade_from_2,
    }
    
    return report

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: python3 compare_libraries.py <inventory1.json> <inventory2.json> [name1] [name2]")
        sys.exit(1)
    
    inv1_path = sys.argv[1]
    inv2_path = sys.argv[2]
    name1 = sys.argv[3] if len(sys.argv) > 3 else "Your Library"
    name2 = sys.argv[4] if len(sys.argv) > 4 else "Chris's Library"
    
    print(f"Loading {inv1_path}...")
    inv1 = load_inventory(inv1_path)
    
    print(f"Loading {inv2_path}...")
    inv2 = load_inventory(inv2_path)
    
    print(f"Comparing libraries...")
    report = compare_inventories(inv1, inv2, name1, name2)
    
    # Print summary
    print("\n" + "="*60)
    print("COMPARISON SUMMARY")
    print("="*60)
    for key, value in report['summary'].items():
        print(f"{key}: {value}")
    
    # Save full report
    output_file = "comparison_report.json"
    with open(output_file, 'w') as f:
        json.dump(report, f, indent=2)
    
    print(f"\nFull report saved to {output_file}")
```

Save to: `\\wsl.localhost\Ubuntu\home\alig\projects\mother\scripts\sync\compare_libraries.py`

### Step 5: Run Comparisons

```bash
cd /home/alig/projects/mother/scripts/sync

# Compare Movies HD
python3 compare_libraries.py \
  your_movies_hd.json \
  chris_movies_hd.json \
  "Your_HD" \
  "Chris_HD" > movies_hd_comparison.txt

# Compare Movies 4K
python3 compare_libraries.py \
  your_movies_4k.json \
  chris_movies_4k.json \
  "Your_4K" \
  "Chris_4K" > movies_4k_comparison.txt

# Compare TV HD
python3 compare_libraries.py \
  your_tv_hd.json \
  chris_tv_hd.json \
  "Your_TV_HD" \
  "Chris_TV_HD" > tv_hd_comparison.txt

# Compare TV 4K
python3 compare_libraries.py \
  your_tv_4k.json \
  chris_tv_4k.json \
  "Your_TV_4K" \
  "Chris_TV_4K" > tv_4k_comparison.txt
```

## Phase 2: Sync Plan Generation

### Step 6: Generate Sync Scripts

#### Script: `generate_sync_plan.py`
```python
#!/usr/bin/env python3
"""
Generate rsync commands based on comparison report
"""
import json
import sys
from pathlib import Path

def generate_sync_commands(comparison_report, source_root, dest_root):
    """Generate rsync commands"""
    
    commands = []
    
    # Files only in source (need to copy to dest)
    only_in_source = comparison_report.get('only_in_Your Library', [])
    for entry in only_in_source:
        source_path = entry['path']
        # Determine relative path
        rel_path = source_path.replace(source_root, '').lstrip('/')
        dest_path = f"{dest_root}/{rel_path}"
        
        # Create rsync command
        cmd = f'rsync -avP --info=progress2 "{source_path}" "{dest_path}"'
        commands.append(cmd)
    
    # Files to upgrade (better quality in source)
    upgrades = comparison_report.get('upgrade_from_Your Library', [])
    for entry in upgrades:
        source_entry = entry['source']
        replace_entry = entry['replace']
        
        source_path = source_entry['path']
        dest_path = replace_entry['path']
        
        # Backup old file first
        backup_cmd = f'mv "{dest_path}" "{dest_path}.bak"'
        commands.append(backup_cmd)
        
        # Copy new file
        cmd = f'rsync -avP --info=progress2 "{source_path}" "{dest_path}"'
        commands.append(cmd)
    
    return commands

def write_sync_script(commands, output_file):
    """Write commands to bash script"""
    
    with open(output_file, 'w') as f:
        f.write("#!/bin/bash\n")
        f.write("# Auto-generated sync script\n")
        f.write("# Review carefully before executing!\n\n")
        f.write("set -e  # Exit on error\n\n")
        
        for i, cmd in enumerate(commands, 1):
            f.write(f"# Command {i}\n")
            f.write(f"{cmd}\n\n")
    
    print(f"Sync script written to {output_file}")
    print(f"Total commands: {len(commands)}")
    print("\nReview the script carefully, then make it executable:")
    print(f"chmod +x {output_file}")

if __name__ == "__main__":
    if len(sys.argv) < 4:
        print("Usage: python3 generate_sync_plan.py <comparison_report.json> <source_root> <dest_root>")
        sys.exit(1)
    
    report_path = sys.argv[1]
    source_root = sys.argv[2]
    dest_root = sys.argv[3]
    
    with open(report_path, 'r') as f:
        report = json.load(f)
    
    commands = generate_sync_commands(report, source_root, dest_root)
    
    output_file = "sync_plan.sh"
    write_sync_script(commands, output_file)
```

Save to: `\\wsl.localhost\Ubuntu\home\alig\projects\mother\scripts\sync\generate_sync_plan.py`

### Step 7: Create Sync Plans

```bash
# Generate sync plan for Movies HD (Your Unraid → Chris's Synology)
python3 generate_sync_plan.py \
  comparison_report.json \
  "/mnt/unraid/Movies" \
  "/mnt/synology/movies" > sync_movies_hd_to_chris.sh

# Generate reverse sync plan (Chris's → Your Unraid)
python3 generate_sync_plan.py \
  comparison_report.json \
  "/mnt/synology/movies" \
  "/mnt/unraid/Movies" > sync_movies_hd_to_you.sh

# Review generated scripts before running!
```

## Phase 3: Initial Sync Execution

### Pre-Sync Checklist
- [ ] Both inventories generated
- [ ] Comparison report reviewed
- [ ] Sync plans generated and reviewed
- [ ] Sufficient free space on destination
- [ ] Backup critical data
- [ ] Test sync with small subset first
- [ ] Network connectivity stable
- [ ] Estimated time calculated

### Sync Strategy Options

#### Option 1: Bidirectional Sync (Recommended)
```bash
# 1. Copy unique files from Your Unraid → Chris's Synology
# 2. Copy unique files from Chris's Synology → Your Unraid
# 3. Replace inferior quality files on both sides
```

#### Option 2: Single Source of Truth
```bash
# Decide one library as authoritative
# Sync everything from authoritative → other
# Simpler but may lose some content
```

### Sync Execution

#### Dry Run First!
```bash
# Add --dry-run to all rsync commands
rsync -avP --dry-run --info=progress2 <source> <dest>
```

#### Actual Sync
```bash
# Run in screen/tmux
screen -S mother-sync

# Execute sync script
cd /home/alig/projects/mother/scripts/sync
chmod +x sync_movies_hd_to_chris.sh
./sync_movies_hd_to_chris.sh

# Monitor progress
# Ctrl+A, D to detach
# screen -r mother-sync to reattach
```

### Monitoring Sync Progress

```bash
# Check rsync progress
watch -n 5 'ps aux | grep rsync'

# Monitor network usage
nload

# Check disk usage
df -h

# Estimated completion time
# Based on file size and network speed
# 159 TB at 700 Mbps = ~423 hours = ~18 days
# Plan for 3-4 weeks with overhead
```

## Phase 4: Verification

### Post-Sync Verification Script

#### Script: `verify_sync.py`
```python
#!/usr/bin/env python3
"""
Verify sync completed successfully
"""
import json
import os
import hashlib

def verify_file(source_path, dest_path):
    """Verify file copied correctly"""
    if not os.path.exists(dest_path):
        return False, "Destination file missing"
    
    source_size = os.path.getsize(source_path)
    dest_size = os.path.getsize(dest_path)
    
    if source_size != dest_size:
        return False, f"Size mismatch: {source_size} vs {dest_size}"
    
    # Optional: Hash verification (slow)
    # source_hash = hash_file(source_path)
    # dest_hash = hash_file(dest_path)
    # if source_hash != dest_hash:
    #     return False, "Hash mismatch"
    
    return True, "OK"

# Implementation details...
```

### Verification Steps
1. Compare file counts
2. Compare total sizes
3. Spot-check random files
4. Verify playback of sample files
5. Check for corruption

## Ongoing Sync Strategy

See: `SYNC_STRATEGY.md` for real-time synchronization setup

## Troubleshooting

### Sync Interrupted
```bash
# Rsync is resumable
# Just re-run the sync script
# It will skip already-copied files
```

### Insufficient Space
```bash
# Check space before starting
df -h

# Free up space if needed
# Or sync in batches
```

### Network Issues
```bash
# Use rsync with resume capability
# Add to rsync options:
--partial --timeout=300
```

### Permission Errors
```bash
# Ensure proper mount permissions
# Check NFS/SMB user mapping
sudo chown -R <user>:<group> /mnt/synology/
```

## Next Steps
1. ⏳ Install analysis tools
2. ⏳ Create inventory generation scripts
3. ⏳ Generate inventories (both sides)
4. ⏳ Create comparison scripts
5. ⏳ Run comparisons
6. ⏳ Review comparison reports
7. ⏳ Generate sync plans
8. ⏳ Review sync plans manually
9. ⏳ Test with small subset
10. ⏳ Execute full sync
11. ⏳ Verify sync completion
12. ⏳ Document findings

## Time Estimates

**Inventory Generation**: 1-3 days per library (depending on file count)
**Comparison**: 1-2 hours
**Sync Plan Generation**: 30 minutes
**Initial Sync**: 3-4 weeks (for ~159 TB over VPN)
**Verification**: 2-3 days

**Total**: Approximately 1-1.5 months for complete initial sync
