#!/usr/bin/env python3

"""
Media Library Inventory Generator

Purpose: Generate comprehensive inventory of media library with file hashes
         for comparison and quality analysis

Features:
- Recursively scans media directories
- Calculates MD5 hashes for file comparison
- Extracts mediainfo metadata (resolution, codecs, bitrate)
- Organizes data for TRASHGuides quality comparison
- Exports to JSON and CSV formats

Author: Project Mother
Last Updated: 2024-12-23
"""

import os
import sys
import json
import csv
import hashlib
import argparse
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional
import subprocess
import re

# Try to import optional dependencies
try:
    from tqdm import tqdm
    HAS_TQDM = True
except ImportError:
    HAS_TQDM = False
    print("Warning: tqdm not installed. Progress bars disabled.")
    print("Install with: pip install tqdm")

###############################################################################
# Configuration
###############################################################################

# File extensions to include
VIDEO_EXTENSIONS = {
    '.mkv', '.mp4', '.avi', '.m4v', '.ts', '.m2ts',
    '.iso', '.img', '.vob', '.mpeg', '.mpg', '.wmv', '.flv'
}

# Quality indicators from filenames (TRASHGuides style)
QUALITY_PATTERNS = {
    'resolution': [
        (r'2160p|4K|UHD', '2160p'),
        (r'1080p|FHD', '1080p'),
        (r'720p|HD', '720p'),
        (r'480p|SD', '480p'),
    ],
    'source': [
        (r'BluRay|Blu-ray|BDMV|BDRip', 'BluRay'),
        (r'Remux|REMUX', 'Remux'),
        (r'WEB-DL|WEBDL|WEB DL', 'WEB-DL'),
        (r'WEBRip|WEB-Rip|WEB Rip', 'WEBRip'),
        (r'HDTV|HD-TV', 'HDTV'),
        (r'DVDRip|DVD-Rip', 'DVDRip'),
    ],
    'hdr': [
        (r'HDR10\+|HDR10Plus', 'HDR10+'),
        (r'HDR10|HDR', 'HDR'),
        (r'DV|DoVi|Dolby.?Vision', 'DV'),
        (r'HLG', 'HLG'),
    ],
    'audio': [
        (r'Atmos|ATMOS', 'Atmos'),
        (r'TrueHD|True-HD', 'TrueHD'),
        (r'DTS-HD.MA|DTS-HD|DTSHD', 'DTS-HD MA'),
        (r'DTS-X|DTSX', 'DTS:X'),
        (r'DD\+|DDP|E-AC-3', 'DD+'),
        (r'DD|AC3|AC-3', 'DD'),
        (r'AAC', 'AAC'),
    ],
    'codec': [
        (r'x265|HEVC|H\.265', 'HEVC'),
        (r'x264|AVC|H\.264', 'AVC'),
        (r'AV1', 'AV1'),
    ]
}

###############################################################################
# Helper Functions
###############################################################################

def calculate_md5(filepath: Path, chunk_size: int = 8192) -> str:
    """Calculate MD5 hash of a file"""
    md5 = hashlib.md5()
    try:
        with open(filepath, 'rb') as f:
            while chunk := f.read(chunk_size):
                md5.update(chunk)
        return md5.hexdigest()
    except Exception as e:
        print(f"Error hashing {filepath}: {e}")
        return ""

def extract_quality_info(filename: str) -> Dict[str, str]:
    """Extract quality indicators from filename"""
    info = {}
    
    for category, patterns in QUALITY_PATTERNS.items():
        for pattern, value in patterns:
            if re.search(pattern, filename, re.IGNORECASE):
                info[category] = value
                break
    
    return info

def get_mediainfo(filepath: Path) -> Optional[Dict]:
    """Get media information using mediainfo (if available)"""
    try:
        result = subprocess.run(
            ['mediainfo', '--Output=JSON', str(filepath)],
            capture_output=True,
            text=True,
            timeout=30
        )
        
        if result.returncode == 0:
            return json.loads(result.stdout)
    except (subprocess.TimeoutExpired, FileNotFoundError, json.JSONDecodeError):
        pass
    
    return None

def parse_mediainfo(mediainfo_data: Optional[Dict]) -> Dict:
    """Parse mediainfo JSON to extract relevant fields"""
    parsed = {
        'video_codec': None,
        'video_bitrate': None,
        'resolution': None,
        'hdr_format': None,
        'audio_codec': None,
        'audio_channels': None,
        'audio_bitrate': None,
        'runtime': None,
    }
    
    if not mediainfo_data or 'media' not in mediainfo_data:
        return parsed
    
    tracks = mediainfo_data['media'].get('track', [])
    
    for track in tracks:
        track_type = track.get('@type', '')
        
        if track_type == 'Video':
            parsed['video_codec'] = track.get('Format')
            parsed['video_bitrate'] = track.get('BitRate')
            
            width = track.get('Width')
            height = track.get('Height')
            if width and height:
                parsed['resolution'] = f"{width}x{height}"
            
            # HDR detection
            if track.get('HDR_Format'):
                parsed['hdr_format'] = track.get('HDR_Format')
            elif 'HDR' in track.get('transfer_characteristics', ''):
                parsed['hdr_format'] = 'HDR'
        
        elif track_type == 'Audio':
            if not parsed['audio_codec']:  # Take first audio track
                parsed['audio_codec'] = track.get('Format')
                parsed['audio_channels'] = track.get('Channels')
                parsed['audio_bitrate'] = track.get('BitRate')
        
        elif track_type == 'General':
            parsed['runtime'] = track.get('Duration')
    
    return parsed

def scan_directory(directory: Path, recursive: bool = True) -> List[Dict]:
    """Scan directory and create inventory"""
    inventory = []
    
    # Find all video files
    if recursive:
        video_files = [
            f for f in directory.rglob('*')
            if f.is_file() and f.suffix.lower() in VIDEO_EXTENSIONS
        ]
    else:
        video_files = [
            f for f in directory.iterdir()
            if f.is_file() and f.suffix.lower() in VIDEO_EXTENSIONS
        ]
    
    print(f"\nFound {len(video_files)} video files")
    
    # Process files
    iterator = tqdm(video_files, desc="Processing") if HAS_TQDM else video_files
    
    for filepath in iterator:
        if not HAS_TQDM:
            print(f"Processing: {filepath.name}")
        
        # Get file stats
        stats = filepath.stat()
        
        # Extract quality from filename
        quality_info = extract_quality_info(filepath.name)
        
        # Get mediainfo
        mediainfo_data = get_mediainfo(filepath)
        parsed_media = parse_mediainfo(mediainfo_data)
        
        # Calculate hash (optional, can be slow)
        file_hash = ""
        # Uncomment to enable hashing (will be very slow for large libraries)
        # file_hash = calculate_md5(filepath)
        
        # Create inventory entry
        entry = {
            'filepath': str(filepath),
            'filename': filepath.name,
            'directory': str(filepath.parent),
            'size_bytes': stats.st_size,
            'size_gb': round(stats.st_size / (1024**3), 2),
            'modified': datetime.fromtimestamp(stats.st_mtime).isoformat(),
            'created': datetime.fromtimestamp(stats.st_ctime).isoformat(),
            'extension': filepath.suffix.lower(),
            
            # Quality from filename
            'filename_resolution': quality_info.get('resolution', 'Unknown'),
            'filename_source': quality_info.get('source', 'Unknown'),
            'filename_hdr': quality_info.get('hdr', 'None'),
            'filename_audio': quality_info.get('audio', 'Unknown'),
            'filename_codec': quality_info.get('codec', 'Unknown'),
            
            # Mediainfo data
            'video_codec': parsed_media['video_codec'],
            'video_bitrate': parsed_media['video_bitrate'],
            'resolution': parsed_media['resolution'],
            'hdr_format': parsed_media['hdr_format'],
            'audio_codec': parsed_media['audio_codec'],
            'audio_channels': parsed_media['audio_channels'],
            'audio_bitrate': parsed_media['audio_bitrate'],
            'runtime': parsed_media['runtime'],
            
            # Hash (if calculated)
            'md5_hash': file_hash,
        }
        
        inventory.append(entry)
    
    return inventory

def save_json(inventory: List[Dict], output_file: Path):
    """Save inventory to JSON"""
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(inventory, f, indent=2, ensure_ascii=False)
    print(f"\n✅ Saved JSON: {output_file}")

def save_csv(inventory: List[Dict], output_file: Path):
    """Save inventory to CSV"""
    if not inventory:
        return
    
    with open(output_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=inventory[0].keys())
        writer.writeheader()
        writer.writerows(inventory)
    print(f"✅ Saved CSV: {output_file}")

def print_summary(inventory: List[Dict]):
    """Print inventory summary"""
    print("\n" + "="*60)
    print("INVENTORY SUMMARY")
    print("="*60)
    
    total_files = len(inventory)
    total_size_gb = sum(item['size_gb'] for item in inventory)
    
    print(f"Total Files: {total_files}")
    print(f"Total Size: {total_size_gb:.2f} GB ({total_size_gb/1024:.2f} TB)")
    
    # Resolution breakdown
    resolutions = {}
    for item in inventory:
        res = item['filename_resolution']
        resolutions[res] = resolutions.get(res, 0) + 1
    
    print("\nResolution Breakdown:")
    for res, count in sorted(resolutions.items(), key=lambda x: x[1], reverse=True):
        print(f"  {res}: {count} files")
    
    # Source breakdown
    sources = {}
    for item in inventory:
        src = item['filename_source']
        sources[src] = sources.get(src, 0) + 1
    
    print("\nSource Breakdown:")
    for src, count in sorted(sources.items(), key=lambda x: x[1], reverse=True):
        print(f"  {src}: {count} files")
    
    print("="*60)

###############################################################################
# Main
###############################################################################

def main():
    parser = argparse.ArgumentParser(
        description='Generate media library inventory with quality analysis'
    )
    parser.add_argument(
        'directory',
        type=Path,
        help='Directory to scan'
    )
    parser.add_argument(
        '-o', '--output',
        type=Path,
        help='Output file prefix (will create .json and .csv)',
        default=None
    )
    parser.add_argument(
        '--no-recursive',
        action='store_true',
        help='Do not scan subdirectories'
    )
    parser.add_argument(
        '--hash',
        action='store_true',
        help='Calculate MD5 hashes (SLOW for large libraries)'
    )
    
    args = parser.parse_args()
    
    # Validate directory
    if not args.directory.exists():
        print(f"Error: Directory not found: {args.directory}")
        sys.exit(1)
    
    if not args.directory.is_dir():
        print(f"Error: Not a directory: {args.directory}")
        sys.exit(1)
    
    # Determine output filename
    if args.output:
        output_prefix = args.output
    else:
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        output_prefix = Path(f"inventory_{timestamp}")
    
    # Scan directory
    print(f"\n📁 Scanning: {args.directory}")
    print(f"Recursive: {not args.no_recursive}")
    print(f"Hashing: {args.hash}")
    
    inventory = scan_directory(args.directory, recursive=not args.no_recursive)
    
    if not inventory:
        print("\n❌ No video files found")
        sys.exit(1)
    
    # Save results
    save_json(inventory, output_prefix.with_suffix('.json'))
    save_csv(inventory, output_prefix.with_suffix('.csv'))
    
    # Print summary
    print_summary(inventory)
    
    print(f"\n✅ Inventory generation complete!")
    print(f"📄 Files created:")
    print(f"   - {output_prefix}.json")
    print(f"   - {output_prefix}.csv")

if __name__ == '__main__':
    main()
