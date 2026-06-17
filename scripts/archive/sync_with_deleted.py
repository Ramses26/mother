#!/usr/bin/env python3
"""
Intelligent Sync Script - WITH DELETED FOLDER PROTECTION

Purpose: Sync media and upgrade quality, moving replaced files to Deleted folder

Paths updated for actual Mother server NFS mounts:
- HD Movies:  /mnt/synology/rs-movies (10.0.0.160)
- HD TV:      /mnt/synology/rs-tv (10.0.0.88)
- 4K Movies:  /mnt/synology/rs-4kmedia/4kmovies (10.0.1.203)
- 4K TV:      /mnt/synology/rs-4kmedia/4ktv (10.0.1.203)
- Deleted:    /mnt/synology/rs-4kmedia/deleted (10.0.1.203) ← FIXED: lowercase!
- Ali Unraid: /mnt/unraid/media (192.168.1.10)

Author: Project Mother
Last Updated: 2024-12-26
"""

import csv
import argparse
import subprocess
import json
import shutil
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Optional

###############################################################################
# Configuration - ACTUAL PATHS FROM MOTHER SERVER
###############################################################################

# Deleted folder paths - ALL on 10.0.1.203 (most space: 184TB free)
DELETED_FOLDERS = {
    # Ali's Unraid
    'ali_movies': '/mnt/unraid/media/Deleted/Movies',
    'ali_4kmovies': '/mnt/unraid/media/Deleted/4kMovies',
    'ali_tv': '/mnt/unraid/media/Deleted/tvshows',
    'ali_4ktv': '/mnt/unraid/media/Deleted/4ktvshows',
    
    # Chris's Synology - ALL centralized on 10.0.1.203 (FIXED: lowercase!)
    'chris_movies': '/mnt/synology/rs-4kmedia/deleted/movies',
    'chris_4kmovies': '/mnt/synology/rs-4kmedia/deleted/4kmovies',
    'chris_tv': '/mnt/synology/rs-4kmedia/deleted/tvshows',
    'chris_4ktv': '/mnt/synology/rs-4kmedia/deleted/4ktv',
}

# Destination folders - ACTUAL NFS MOUNT PATHS
DESTINATIONS = {
    # Ali's Unraid (via VPN)
    'ali_movies': '/mnt/unraid/media/Movies',
    'ali_4kmovies': '/mnt/unraid/media/4K Movies',
    'ali_tv': '/mnt/unraid/media/TV Shows',
    'ali_4ktv': '/mnt/unraid/media/4K TV Shows',
    
    # Chris's Synology - ACTUAL MOUNT POINTS
    'chris_movies': '/mnt/synology/rs-movies',              # 10.0.0.160
    'chris_4kmovies': '/mnt/synology/rs-4kmedia/4kmovies',  # 10.0.1.203
    'chris_tv': '/mnt/synology/rs-tv',                      # 10.0.0.88
    'chris_4ktv': '/mnt/synology/rs-4kmedia/4ktv',          # 10.0.1.203
}

###############################################################################
# Helper Functions
###############################################################################

def get_deleted_folder(direction: str, media_type: str) -> str:
    """Get the deleted folder path"""
    # Direction is like "Ali → Chris" or "Chris → Ali"
    if '→ Ali' in direction or 'Ali' in direction:
        prefix = 'ali'
    else:
        prefix = 'chris'
    
    key = f"{prefix}_{media_type}"
    return DELETED_FOLDERS.get(key, f"/tmp/deleted_{media_type}")

def get_destination_folder(direction: str, media_type: str) -> str:
    """Get the destination folder path"""
    if '→ Ali' in direction or 'Ali' in direction:
        prefix = 'ali'
    else:
        prefix = 'chris'
    
    key = f"{prefix}_{media_type}"
    return DESTINATIONS.get(key, f"/tmp/dest_{media_type}")

def parse_sync_plan(csv_file: Path) -> List[Dict]:
    """Parse sync plan CSV"""
    sync_items = []
    
    with open(csv_file, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            sync_items.append(row)
    
    return sync_items

def load_inventory(inventory_file: Path) -> Dict:
    """Load inventory JSON and create filename lookup"""
    with open(inventory_file, 'r', encoding='utf-8') as f:
        inventory = json.load(f)
    
    # Create lookup by filename
    lookup = {}
    for item in inventory:
        lookup[item['filename']] = item
    
    return lookup

def move_to_deleted(file_path: Path, deleted_folder: str, dry_run: bool = True) -> bool:
    """Move file to deleted folder for manual review"""
    
    deleted_path = Path(deleted_folder) / file_path.name
    
    # Add timestamp to avoid conflicts
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    if deleted_path.exists():
        stem = deleted_path.stem
        suffix = deleted_path.suffix
        deleted_path = deleted_path.parent / f"{stem}_{timestamp}{suffix}"
    
    print(f"  📦 Moving to Deleted folder:")
    print(f"     From: {file_path}")
    print(f"     To: {deleted_path}")
    
    if dry_run:
        print(f"     [DRY RUN - not actually moved]")
        return True
    
    try:
        # Create deleted folder if needed
        deleted_path.parent.mkdir(parents=True, exist_ok=True)
        
        # Move file
        shutil.move(str(file_path), str(deleted_path))
        print(f"     ✅ Moved successfully")
        return True
    except Exception as e:
        print(f"     ❌ Error: {e}")
        return False

def execute_rsync(source: Path, destination: Path, dry_run: bool = True) -> bool:
    """Execute rsync command"""
    
    # Build rsync command
    cmd = [
        'rsync',
        '-avh',  # archive, verbose, human-readable
        '--progress',  # show progress
        '--partial',  # keep partial transfers
        '--stats',  # show transfer stats
    ]
    
    if dry_run:
        cmd.append('--dry-run')
    
    cmd.extend([
        str(source),
        str(destination)
    ])
    
    print(f"\n  {'[DRY RUN] ' if dry_run else ''}Copying:")
    print(f"    From: {source}")
    print(f"    To: {destination}")
    
    if dry_run:
        return True
    
    try:
        result = subprocess.run(cmd, check=True, capture_output=True, text=True)
        if result.stdout and '--progress' not in cmd:
            print(f"    {result.stdout}")
        return True
    except subprocess.CalledProcessError as e:
        print(f"    ❌ Error: {e}")
        if e.stderr:
            print(f"    Stderr: {e.stderr}")
        return False

###############################################################################
# Main Sync Function
###############################################################################

def sync_from_plan(
    sync_plan_csv: Path,
    source_inventory: Path,
    dest_inventory: Path,
    media_type: str,
    dry_run: bool = True,
    max_files: int = None
) -> Dict:
    """
    Execute sync based on comparison report
    
    Args:
        sync_plan_csv: CSV file from compare_libraries.py
        source_inventory: Source person's inventory JSON
        dest_inventory: Destination person's inventory JSON
        media_type: 'movies', '4kmovies', 'tv', or '4ktv'
        dry_run: If True, only simulate (don't actually copy)
        max_files: Maximum number of files to sync (for testing)
    """
    
    print("="*80)
    print(f"INTELLIGENT SYNC - {media_type.upper()}")
    print("="*80)
    print(f"Mode: {'DRY RUN (no files will be moved/copied)' if dry_run else 'LIVE (files will be moved/copied)'}")
    print()
    
    # Load sync plan
    print(f"📖 Loading sync plan: {sync_plan_csv}")
    sync_items = parse_sync_plan(sync_plan_csv)
    print(f"   Found {len(sync_items)} items in plan")
    
    # Load inventories
    print(f"\n📖 Loading source inventory: {source_inventory}")
    source_lookup = load_inventory(source_inventory)
    
    print(f"📖 Loading destination inventory: {dest_inventory}")
    dest_lookup = load_inventory(dest_inventory)
    
    # Statistics
    stats = {
        'total': len(sync_items),
        'new_files': 0,  # Files that don't exist at destination
        'upgrades': 0,  # Better quality replacements
        'moved_to_deleted': 0,  # Files moved to deleted folder
        'failed': 0,
        'skipped': 0,
        'total_size_gb': 0,
    }
    
    # Limit files if requested
    if max_files:
        sync_items = sync_items[:max_files]
        print(f"\n⚠️  Limited to {max_files} files for testing")
    
    # Process each file
    print(f"\n🔄 Processing {len(sync_items)} files...")
    print()
    
    for i, item in enumerate(sync_items, 1):
        filename = item['Filename']
        direction = item['Direction']
        needs_review = item.get('Needs_Review', 'NO') == 'YES'
        will_replace = item.get('Will_Replace', 'N/A')
        
        print(f"[{i}/{len(sync_items)}] {filename}")
        print(f"  Direction: {direction}")
        
        # Get file details from source inventory
        if filename not in source_lookup:
            print(f"  ⚠️  File not found in source inventory, skipping")
            stats['skipped'] += 1
            continue
        
        source_info = source_lookup[filename]
        
        # Determine folders
        deleted_folder = get_deleted_folder(direction, media_type)
        dest_folder = get_destination_folder(direction, media_type)
        
        # Build paths
        source_base = Path(DESTINATIONS[f"chris_{media_type}"]) if 'Chris →' in direction else Path(DESTINATIONS[f"ali_{media_type}"])
        source_path = source_base / source_info['relative_path']
        dest_path = Path(dest_folder) / source_info['relative_path']
        
        print(f"  Source: {source_path}")
        print(f"  Destination: {dest_path}")
        
        # Check if this will replace an existing file
        if needs_review and will_replace != 'N/A':
            print(f"  ⚠️  UPGRADE: Will replace existing file")
            print(f"     Old file: {will_replace}")
            
            # Find the old file in destination inventory
            old_file_path = dest_path  # Same path, different quality
            
            if old_file_path.exists() or dry_run:
                # Move old file to deleted folder
                if move_to_deleted(old_file_path, deleted_folder, dry_run):
                    stats['moved_to_deleted'] += 1
                else:
                    print(f"  ❌ Failed to move old file to deleted folder")
                    stats['failed'] += 1
                    continue
                
                stats['upgrades'] += 1
            else:
                print(f"  ⚠️  Old file not found at destination, treating as new file")
                stats['new_files'] += 1
        else:
            # New file (doesn't exist at destination)
            if dest_path.exists() and not dry_run:
                print(f"  ⚠️  Destination already exists, skipping")
                stats['skipped'] += 1
                continue
            
            stats['new_files'] += 1
        
        # Check if source exists
        if not dry_run and not source_path.exists():
            print(f"  ❌ Source file not found: {source_path}")
            stats['failed'] += 1
            continue
        
        # Execute copy
        if execute_rsync(source_path, dest_path, dry_run):
            stats['total_size_gb'] += source_info.get('size_gb', 0)
        else:
            stats['failed'] += 1
        
        print()
    
    # Print summary
    print("="*80)
    print("SYNC COMPLETE")
    print("="*80)
    print(f"Total files processed: {stats['total']}")
    print(f"📥 New files copied: {stats['new_files']}")
    print(f"⬆️  Quality upgrades: {stats['upgrades']}")
    print(f"📦 Files moved to Deleted: {stats['moved_to_deleted']}")
    print(f"❌ Failed: {stats['failed']}")
    print(f"⏭️  Skipped: {stats['skipped']}")
    print(f"📊 Total size: {stats['total_size_gb']:.2f} GB")
    print("="*80)
    
    if stats['moved_to_deleted'] > 0:
        print()
        print("⚠️  IMPORTANT: Files moved to Deleted folder for manual review:")
        print(f"   {deleted_folder}")
        print()
        print("   Review these files and delete manually when satisfied!")
        print("="*80)
    
    return stats

###############################################################################
# CLI
###############################################################################

def main():
    parser = argparse.ArgumentParser(
        description='Intelligent sync with Deleted folder protection',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Dry run - sync Chris's movies to Ali
  python3 sync_with_deleted.py \\
    -s reports/movies/sync_plan_20241226_184006.csv \\
    -si inventories/chris_movies.json \\
    -di inventories/ali_movies.json \\
    -t movies \\
    -d "Chris → Ali" \\
    --dry-run
  
  # Test with 5 files
  python3 sync_with_deleted.py \\
    -s reports/movies/sync_plan_20241226_184006.csv \\
    -si inventories/chris_movies.json \\
    -di inventories/ali_movies.json \\
    -t movies \\
    -d "Chris → Ali" \\
    --dry-run \\
    --max-files 5
  
  # Execute for real
  python3 sync_with_deleted.py \\
    -s reports/movies/sync_plan_20241226_184006.csv \\
    -si inventories/chris_movies.json \\
    -di inventories/ali_movies.json \\
    -t movies \\
    -d "Chris → Ali"

Actual Mount Paths on Mother Server:
  HD Movies:  /mnt/synology/rs-movies (10.0.0.160)
  HD TV:      /mnt/synology/rs-tv (10.0.0.88)
  4K Movies:  /mnt/synology/rs-4kmedia/4kmovies (10.0.1.203)
  4K TV:      /mnt/synology/rs-4kmedia/4ktv (10.0.1.203)
  Deleted:    /mnt/synology/rs-4kmedia/deleted (10.0.1.203 - lowercase!)
  Ali Unraid: /mnt/unraid/media (192.168.1.10)

Deleted Folder Structure:
  All Chris's deleted files centralized on 10.0.1.203 (184TB free):
    /mnt/synology/rs-4kmedia/deleted/
    ├── movies/      ← Replaced HD movies (from 10.0.0.160)
    ├── 4kmovies/    ← Replaced 4K movies (from 10.0.1.203)
    ├── tvshows/     ← Replaced HD TV (from 10.0.0.88)
    └── 4ktv/        ← Replaced 4K TV (from 10.0.1.203) - FIXED!
  
  Ali's deleted files on Unraid:
    /mnt/unraid/media/Deleted/
    ├── Movies/
    ├── 4kMovies/
    ├── tvshows/
    └── 4ktvshows/

How It Works:
  1. New files → Just copy to destination
  2. Better quality exists → Move old to Deleted/, copy new
  3. You manually review Deleted/ and remove when satisfied
        """
    )
    
    parser.add_argument(
        '-s', '--sync-plan',
        type=Path,
        required=True,
        help='Sync plan CSV from compare_libraries.py'
    )
    parser.add_argument(
        '-si', '--source-inventory',
        type=Path,
        required=True,
        help='Source inventory JSON file (person giving files)'
    )
    parser.add_argument(
        '-di', '--dest-inventory',
        type=Path,
        required=True,
        help='Destination inventory JSON file (person receiving files)'
    )
    parser.add_argument(
        '-t', '--media-type',
        choices=['movies', '4kmovies', 'tv', '4ktv'],
        required=True,
        help='Type of media being synced'
    )
    parser.add_argument(
        '-d', '--direction',
        choices=['Chris → Ali', 'Ali → Chris'],
        required=True,
        help='Direction of sync'
    )
    parser.add_argument(
        '--dry-run',
        action='store_true',
        help='Simulate sync without moving/copying files (RECOMMENDED FIRST!)'
    )
    parser.add_argument(
        '--max-files',
        type=int,
        help='Limit number of files to sync (for testing)'
    )
    
    args = parser.parse_args()
    
    # Validate files exist
    if not args.sync_plan.exists():
        print(f"❌ Sync plan not found: {args.sync_plan}")
        return 1
    
    if not args.source_inventory.exists():
        print(f"❌ Source inventory not found: {args.source_inventory}")
        return 1
    
    if not args.dest_inventory.exists():
        print(f"❌ Destination inventory not found: {args.dest_inventory}")
        return 1
    
    # Filter sync plan by direction
    print(f"Filtering sync plan for: {args.direction}")
    all_items = parse_sync_plan(args.sync_plan)
    filtered_items = [item for item in all_items if item['Direction'] == args.direction]
    
    if not filtered_items:
        print(f"⚠️  No items found for direction: {args.direction}")
        print(f"   Total items in plan: {len(all_items)}")
        print(f"   Directions found: {set(item['Direction'] for item in all_items)}")
        return 0
    
    # Create temporary filtered CSV
    temp_csv = args.sync_plan.parent / f"temp_{args.direction.replace(' → ', '_to_')}.csv"
    with open(temp_csv, 'w', newline='', encoding='utf-8') as f:
        if filtered_items:
            writer = csv.DictWriter(f, fieldnames=filtered_items[0].keys())
            writer.writeheader()
            writer.writerows(filtered_items)
    
    print(f"Filtered to {len(filtered_items)} items for {args.direction}")
    print()
    
    # Confirm if not dry run
    if not args.dry_run:
        print("\n" + "="*80)
        print("⚠️  WARNING: LIVE MODE")
        print("="*80)
        print("This will:")
        print("  1. Copy new files to destination")
        print("  2. Move replaced files to Deleted folder")
        print("  3. Copy better quality replacements")
        print()
        print("Make sure you've tested with --dry-run first!")
        print()
        response = input("Continue? (yes/no): ")
        if response.lower() != 'yes':
            print("Aborted.")
            temp_csv.unlink()
            return 0
    
    # Execute sync
    stats = sync_from_plan(
        sync_plan_csv=temp_csv,
        source_inventory=args.source_inventory,
        dest_inventory=args.dest_inventory,
        media_type=args.media_type,
        dry_run=args.dry_run,
        max_files=args.max_files
    )
    
    # Cleanup temp file
    temp_csv.unlink()
    
    return 0

if __name__ == '__main__':
    exit(main())
