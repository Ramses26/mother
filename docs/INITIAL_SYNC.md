# Initial Data Sync - Project Mother

**Last Updated:** 2024-12-23

---

## Overview

This document outlines the process for performing the initial data synchronization between Ali's Unraid library and Chris's Synology libraries using hash-based comparison and TRASHGuides quality scoring.

---

## Current Library Status

**Ali's Unraid (192.168.1.10):**
- 4K Movies: 8.38 TB
- Movies: 66.3 TB  
- TV Shows: 82.3 TB
- 4K TV Shows: 1.94 TB
- **Total: ~158.9 TB**

**Chris's Synology:**
- Movies: 73.7 TB
- TV Shows: ~85 TB
- **Total: ~158.7 TB**

---

## Phase 1: Library Export & Hashing

### Export Ali's Library

Create script to export Ali's library with file hashes:

```bash
#!/bin/bash
# /opt/mother/scripts/sync/export-ali-library.sh

OUTPUT_DIR="/opt/mother/scripts/sync/data"
mkdir -p "$OUTPUT_DIR"

echo "Exporting Ali's Unraid library..."

# Movies (1080p)
echo "Processing Movies..."
find /mnt/unraid/media/Movies -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" \) \
  -exec sh -c 'echo "$(md5sum "$1" | cut -d" " -f1)|$(stat -c%s "$1")|$1"' _ {} \; \
  > "$OUTPUT_DIR/ali-movies.txt"

# 4K Movies
echo "Processing 4K Movies..."
find /mnt/unraid/media/"4K Movies" -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" \) \
  -exec sh -c 'echo "$(md5sum "$1" | cut -d" " -f1)|$(stat -c%s "$1")|$1"' _ {} \; \
  > "$OUTPUT_DIR/ali-movies-4k.txt"

# TV Shows (1080p)
echo "Processing TV Shows..."
find /mnt/unraid/media/"TV Shows" -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" \) \
  -exec sh -c 'echo "$(md5sum "$1" | cut -d" " -f1)|$(stat -c%s "$1")|$1"' _ {} \; \
  > "$OUTPUT_DIR/ali-tv.txt"

# 4K TV Shows
echo "Processing 4K TV Shows..."
find /mnt/unraid/media/"4K TV Shows" -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" \) \
  -exec sh -c 'echo "$(md5sum "$1" | cut -d" " -f1)|$(stat -c%s "$1")|$1"' _ {} \; \
  > "$OUTPUT_DIR/ali-tv-4k.txt"

echo "Export complete! Files saved to $OUTPUT_DIR"
```

### Export Chris's Library

```bash
#!/bin/bash
# /opt/mother/scripts/sync/export-chris-library.sh

OUTPUT_DIR="/opt/mother/scripts/sync/data"
mkdir -p "$OUTPUT_DIR"

echo "Exporting Chris's Synology library..."

# Movies (1080p)
echo "Processing Movies..."
find /mnt/synology/movies -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" \) \
  -exec sh -c 'echo "$(md5sum "$1" | cut -d" " -f1)|$(stat -c%s "$1")|$1"' _ {} \; \
  > "$OUTPUT_DIR/chris-movies.txt"

# 4K Movies
echo "Processing 4K Movies..."
find /mnt/synology/4kmovies -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" \) \
  -exec sh -c 'echo "$(md5sum "$1" | cut -d" " -f1)|$(stat -c%s "$1")|$1"' _ {} \; \
  > "$OUTPUT_DIR/chris-movies-4k.txt"

# TV Shows (1080p)
echo "Processing TV Shows..."
find /mnt/synology/tv -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" \) \
  -exec sh -c 'echo "$(md5sum "$1" | cut -d" " -f1)|$(stat -c%s "$1")|$1"' _ {} \; \
  > "$OUTPUT_DIR/chris-tv.txt"

# 4K TV Shows
echo "Processing 4K TV Shows..."
find /mnt/synology/4ktv -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" \) \
  -exec sh -c 'echo "$(md5sum "$1" | cut -d" " -f1)|$(stat -c%s "$1")|$1"' _ {}  \; \
  > "$OUTPUT_DIR/chris-tv-4k.txt"

echo "Export complete! Files saved to $OUTPUT_DIR"
```

**Run exports:**
```bash
chmod +x /opt/mother/scripts/sync/export-*.sh
/opt/mother/scripts/sync/export-ali-library.sh
/opt/mother/scripts/sync/export-chris-library.sh
```

**Note:** This will take several hours depending on library size. Consider using `parallel` for faster processing.

---

## Phase 2: Analysis & Comparison

### Python Analysis Script

```python
#!/usr/bin/env python3
# /opt/mother/scripts/sync/analyze-libraries.py

import os
import re
from pathlib import Path
from collections import defaultdict

def parse_filename(filepath):
    """Extract media info from filename using common patterns"""
    filename = Path(filepath).stem
    
    # Movie pattern: Title (Year) [quality] [audio] [group]
    # TV pattern: Show SxxExx [quality] [audio] [group]
    
    # Try to extract year
    year_match = re.search(r'\((\d{4})\)', filename)
    year = year_match.group(1) if year_match else None
    
    # Try to extract quality indicators
    quality_indicators = []
    if '2160p' in filename.lower() or '4k' in filename.lower():
        quality_indicators.append('4K')
    elif '1080p' in filename.lower():
        quality_indicators.append('1080p')
    elif '720p' in filename.lower():
        quality_indicators.append('720p')
    
    # Try to extract release type
    if 'remux' in filename.lower():
        quality_indicators.append('REMUX')
    elif 'bluray' in filename.lower() or 'bdrip' in filename.lower():
        quality_indicators.append('BluRay')
    elif 'web-dl' in filename.lower() or 'webdl' in filename.lower():
        quality_indicators.append('WEB-DL')
    elif 'webrip' in filename.lower():
        quality_indicators.append('WEBRip')
    
    # Audio
    audio_formats = []
    if 'atmos' in filename.lower():
        audio_formats.append('Atmos')
    if 'truehd' in filename.lower():
        audio_formats.append('TrueHD')
    if 'dts-hd' in filename.lower() or 'dts.hd' in filename.lower():
        audio_formats.append('DTS-HD')
    if 'dts-x' in filename.lower():
        audio_formats.append('DTS:X')
    
    # HDR
    hdr_formats = []
    if 'dv' in filename.lower() or 'dolby.vision' in filename.lower():
        hdr_formats.append('DV')
    if 'hdr' in filename.lower():
        hdr_formats.append('HDR')
    if 'hdr10+' in filename.lower() or 'hdr10plus' in filename.lower():
        hdr_formats.append('HDR10+')
    elif 'hdr10' in filename.lower():
        hdr_formats.append('HDR10')
    
    return {
        'year': year,
        'quality': quality_indicators,
        'audio': audio_formats,
        'hdr': hdr_formats,
        'filename': filename
    }

def score_quality(metadata, size_bytes):
    """Score media quality based on TRASHGuides principles"""
    score = 0
    
    # Resolution scoring
    if '4K' in metadata['quality']:
        score += 100
    elif '1080p' in metadata['quality']:
        score += 50
    
    # Release type scoring
    if 'REMUX' in metadata['quality']:
        score += 200
    elif 'BluRay' in metadata['quality']:
        score += 150
    elif 'WEB-DL' in metadata['quality']:
        score += 100
    elif 'WEBRip' in metadata['quality']:
        score += 75
    
    # Audio scoring (Ali prefers Atmos)
    if 'Atmos' in metadata['audio']:
        score += 150
    if 'DTS:X' in metadata['audio']:
        score += 140
    if 'TrueHD' in metadata['audio']:
        score += 130
    if 'DTS-HD' in metadata['audio']:
        score += 120
    
    # HDR scoring (Ali prefers HDR over DV)
    if 'HDR10+' in metadata['hdr']:
        score += 100
    elif 'HDR10' in metadata['hdr']:
        score += 90
    elif 'HDR' in metadata['hdr']:
        score += 80
    if 'DV' in metadata['hdr']:
        score += 50  # Lower than HDR
    
    # File size (larger usually better for same quality)
    # Normalize to GB
    size_gb = size_bytes / (1024**3)
    score += min(size_gb / 10, 50)  # Cap at 50 points
    
    return score

def load_library(filepath):
    """Load library export file"""
    library = {}
    with open(filepath, 'r') as f:
        for line in f:
            parts = line.strip().split('|')
            if len(parts) == 3:
                md5, size, path = parts
                library[md5] = {
                    'size': int(size),
                    'path': path,
                    'metadata': parse_filename(path),
                    'md5': md5
                }
    return library

def find_title_matches(ali_lib, chris_lib):
    """Find potential matches based on title/year even if hash differs"""
    ali_titles = defaultdict(list)
    chris_titles = defaultdict(list)
    
    # Group by basic title
    for md5, data in ali_lib.items():
        filename = Path(data['path']).stem
        # Remove quality indicators for matching
        clean_title = re.sub(r'\[.*?\]|\(.*?\)|2160p|1080p|720p|remux|bluray|web-dl|webrip', '', filename, flags=re.IGNORECASE)
        clean_title = re.sub(r'\s+', ' ', clean_title).strip()
        ali_titles[clean_title].append((md5, data))
    
    for md5, data in chris_lib.items():
        filename = Path(data['path']).stem
        clean_title = re.sub(r'\[.*?\]|\(.*?\)|2160p|1080p|720p|remux|bluray|web-dl|webrip', '', filename, flags=re.IGNORECASE)
        clean_title = re.sub(r'\s+', ' ', clean_title).strip()
        chris_titles[clean_title].append((md5, data))
    
    return ali_titles, chris_titles

def analyze_category(ali_file, chris_file, output_file, category_name):
    """Analyze a specific category (movies, tv, etc.)"""
    print(f"\nAnalyzing {category_name}...")
    
    ali_lib = load_library(ali_file)
    chris_lib = load_library(chris_file)
    
    # Find exact matches (same file hash)
    exact_matches = set(ali_lib.keys()) & set(chris_lib.keys())
    ali_only = set(ali_lib.keys()) - set(chris_lib.keys())
    chris_only = set(chris_lib.keys()) - set(ali_lib.keys())
    
    # Find title matches with different quality
    ali_titles, chris_titles = find_title_matches(
        {k: ali_lib[k] for k in ali_only},
        {k: chris_lib[k] for k in chris_only}
    )
    
    quality_conflicts = []
    for title in set(ali_titles.keys()) & set(chris_titles.keys()):
        for ali_md5, ali_data in ali_titles[title]:
            for chris_md5, chris_data in chris_titles[title]:
                ali_score = score_quality(ali_data['metadata'], ali_data['size'])
                chris_score = score_quality(chris_data['metadata'], chris_data['size'])
                
                quality_conflicts.append({
                    'title': title,
                    'ali_file': ali_data['path'],
                    'ali_score': ali_score,
                    'chris_file': chris_data['path'],
                    'chris_score': chris_score,
                    'recommended': 'ali' if ali_score > chris_score else 'chris'
                })
    
    # Generate report
    with open(output_file, 'w') as f:
        f.write(f"=== {category_name} Analysis Report ===\n\n")
        f.write(f"Total files - Ali: {len(ali_lib)}, Chris: {len(chris_lib)}\n\n")
        f.write(f"Exact matches (identical files): {len(exact_matches)}\n")
        f.write(f"Ali has, Chris missing: {len(ali_only) - len([x for x in ali_titles.keys() if x in chris_titles])}\n")
        f.write(f"Chris has, Ali missing: {len(chris_only) - len([x for x in chris_titles.keys() if x in ali_titles])}\n")
        f.write(f"Quality conflicts (same title, different quality): {len(quality_conflicts)}\n\n")
        
        f.write("=== Quality Conflicts (Recommendations) ===\n\n")
        for conflict in sorted(quality_conflicts, key=lambda x: x['ali_score'] + x['chris_score'], reverse=True)[:50]:
            f.write(f"Title: {conflict['title']}\n")
            f.write(f"  Ali:   {conflict['ali_file']} (Score: {conflict['ali_score']})\n")
            f.write(f"  Chris: {conflict['chris_file']} (Score: {conflict['chris_score']})\n")
            f.write(f"  → RECOMMENDED: {conflict['recommended'].upper()}\n\n")
        
        f.write("\n=== Files to sync to Chris ===\n\n")
        for md5 in list(ali_only)[:100]:  # Limit to first 100
            f.write(f"{ali_lib[md5]['path']}\n")
        
        f.write("\n=== Files to sync to Ali ===\n\n")
        for md5 in list(chris_only)[:100]:
            f.write(f"{chris_lib[md5]['path']}\n")
    
    print(f"Report saved to {output_file}")
    return {
        'exact_matches': len(exact_matches),
        'ali_only': len(ali_only),
        'chris_only': len(chris_only),
        'conflicts': len(quality_conflicts)
    }

if __name__ == "__main__":
    data_dir = "/opt/mother/scripts/sync/data"
    
    categories = [
        ("ali-movies.txt", "chris-movies.txt", "report-movies.txt", "Movies (1080p)"),
        ("ali-movies-4k.txt", "chris-movies-4k.txt", "report-movies-4k.txt", "Movies (4K)"),
        ("ali-tv.txt", "chris-tv.txt", "report-tv.txt", "TV Shows (1080p)"),
        ("ali-tv-4k.txt", "chris-tv-4k.txt", "report-tv-4k.txt", "TV Shows (4K)")
    ]
    
    for ali_file, chris_file, output_file, category in categories:
        analyze_category(
            os.path.join(data_dir, ali_file),
            os.path.join(data_dir, chris_file),
            os.path.join(data_dir, output_file),
            category
        )
    
    print("\nAll analyses complete!")
```

**Run analysis:**
```bash
chmod +x /opt/mother/scripts/sync/analyze-libraries.py
python3 /opt/mother/scripts/sync/analyze-libraries.py
```

---

## Phase 3: Review & Decision

After analysis completes, review reports:

```bash
cd /opt/mother/scripts/sync/data
less report-movies.txt
less report-movies-4k.txt
less report-tv.txt
less report-tv-4k.txt
```

**Decision Points:**
1. For exact matches: No action needed (already identical)
2. For quality conflicts: Follow "RECOMMENDED" (based on TRASHGuides scoring)
3. For unique files: Sync to other location

---

## Phase 4: Generate Sync Scripts

Based on analysis reports, create sync scripts:

```bash
#!/bin/bash
# /opt/mother/scripts/sync/sync-to-chris.sh
# Sync files Ali has that Chris doesn't

rsync -avh --progress \
  --files-from=/opt/mother/scripts/sync/data/to-chris-movies.txt \
  /mnt/unraid/media/Movies/ \
  /mnt/synology/movies/

rsync -avh --progress \
  --files-from=/opt/mother/scripts/sync/data/to-chris-tv.txt \
  /mnt/unraid/media/"TV Shows"/ \
  /mnt/synology/tv/
```

```bash
#!/bin/bash
# /opt/mother/scripts/sync/sync-to-ali.sh
# Sync files Chris has that Ali doesn't

rsync -avh --progress \
  --files-from=/opt/mother/scripts/sync/data/to-ali-movies.txt \
  /mnt/synology/movies/ \
  /mnt/unraid/media/Movies/

rsync -avh --progress \
  --files-from=/opt/mother/scripts/sync/data/to-ali-tv.txt \
  /mnt/synology/tv/ \
  /mnt/unraid/media/"TV Shows"/
```

---

## Phase 5: Execute Initial Sync

**Dry run first:**
```bash
rsync -avhn --files-from=... source/ dest/
```

**Execute:**
```bash
chmod +x /opt/mother/scripts/sync/sync-to-chris.sh
chmod +x /opt/mother/scripts/sync/sync-to-ali.sh

# Run with logging
/opt/mother/scripts/sync/sync-to-chris.sh 2>&1 | tee /opt/mother/logs/initial-sync-to-chris.log
/opt/mother/scripts/sync/sync-to-ali.sh 2>&1 | tee /opt/mother/logs/initial-sync-to-ali.log
```

---

## Timeline Estimate

Based on library sizes and 800 Mbps connection:

| Task | Duration |
|------|----------|
| Export Ali's library (hashing) | 8-12 hours |
| Export Chris's library | 8-12 hours |
| Analysis | 1-2 hours |
| Review reports & decisions | 2-4 hours |
| Initial sync (assume 50% unique data) | 3-7 days |

**Total:** ~1-2 weeks for complete initial synchronization

---

## Verification

After sync completes:

```bash
# Re-run exports
/opt/mother/scripts/sync/export-ali-library.sh
/opt/mother/scripts/sync/export-chris-library.sh

# Re-run analysis
python3 /opt/mother/scripts/sync/analyze-libraries.py

# Should show:
# - Exact matches: ~100% of total
# - Ali only: ~0
# - Chris only: ~0
# - Quality conflicts: ~0
```

---

## Next Steps

Once initial sync is complete:
1. Proceed to ongoing real-time sync setup (see SYNC_STRATEGY.md)
2. Configure Radarr/Sonarr to manage new acquisitions
3. Set up automated quality upgrades based on TRASHGuides
