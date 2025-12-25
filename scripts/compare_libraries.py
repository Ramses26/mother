#!/usr/bin/env python3

"""
Media Library Comparison Tool

Purpose: Compare two media library inventories and determine:
         1. What files each library is missing
         2. Which version of duplicate files is higher quality (TRASHGuides based)
         3. Generate sync plan for initial synchronization

Author: Project Mother
Last Updated: 2024-12-23
"""

import json
import csv
import argparse
from pathlib import Path
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass
from datetime import datetime

###############################################################################
# Quality Scoring (Based on TRASHGuides)
###############################################################################

# Resolution scores
RESOLUTION_SCORES = {
    '2160p': 1000,
    '1080p': 500,
    '720p': 250,
    '480p': 100,
    'Unknown': 0,
}

# Source scores (higher is better)
SOURCE_SCORES = {
    'Remux': 1000,
    'BluRay': 800,
    'WEB-DL': 600,
    'WEBRip': 500,
    'HDTV': 300,
    'DVDRip': 200,
    'Unknown': 0,
}

# HDR scores (Ali's preference: HDR10 > DV HDR10 > HDR > DV > others)
HDR_SCORES = {
    'HDR10': 300,     # Standard HDR - HIGHEST priority
    'DV HDR10': 280,  # Dolby Vision with HDR10 fallback - Second
    'HDR': 250,       # Generic HDR
    'DV': 150,        # Dolby Vision only (no fallback)
    'DV HLG': 140,    # DV with HLG fallback
    'DV SDR': 130,    # DV with SDR fallback
    'HDR10+': 100,    # Samsung proprietary
    'HLG': 100,       # Hybrid Log-Gamma
    'None': 0,
}

# Audio scores
AUDIO_SCORES = {
    'Atmos': 300,
    'TrueHD': 250,
    'DTS-HD MA': 240,
    'DTS:X': 230,
    'DD+': 150,
    'DD': 100,
    'AAC': 80,
    'Unknown': 0,
}

# Codec scores
CODEC_SCORES = {
    'HEVC': 200,  # Better compression
    'AVC': 150,
    'AV1': 250,   # Best compression
    'Unknown': 0,
}

###############################################################################
# Data Classes
###############################################################################

@dataclass
class ComparisonResult:
    """Result of comparing two files"""
    ali_file: Optional[Dict]
    chris_file: Optional[Dict]
    winner: str  # 'ali', 'chris', or 'tie'
    ali_score: int
    chris_score: int
    reason: str
    recommendation: str

###############################################################################
# Comparison Functions
###############################################################################

def calculate_quality_score(file_entry: Dict) -> int:
    """Calculate overall quality score for a file"""
    score = 0
    
    # Resolution
    score += RESOLUTION_SCORES.get(file_entry.get('filename_resolution', 'Unknown'), 0)
    
    # Source
    score += SOURCE_SCORES.get(file_entry.get('filename_source', 'Unknown'), 0)
    
    # HDR
    score += HDR_SCORES.get(file_entry.get('filename_hdr', 'None'), 0)
    
    # Audio
    score += AUDIO_SCORES.get(file_entry.get('filename_audio', 'Unknown'), 0)
    
    # Codec
    score += CODEC_SCORES.get(file_entry.get('filename_codec', 'Unknown'), 0)
    
    # File size bonus (larger is generally better for same quality)
    # 0.01 points per GB (max 100 points at 10TB)
    size_gb = file_entry.get('size_gb', 0)
    score += min(int(size_gb * 0.01), 100)
    
    return score

def normalize_title(filename: str) -> str:
    """Normalize movie/show title for comparison"""
    # Remove year, resolution, quality indicators, etc.
    import re
    
    # Remove common patterns
    name = filename
    name = re.sub(r'\(?\d{4}\)?', '', name)  # Year
    name = re.sub(r'\b(2160p|1080p|720p|480p|4K|UHD|HD|SD)\b', '', name, flags=re.IGNORECASE)
    name = re.sub(r'\b(BluRay|Remux|WEB-DL|WEBRip|HDTV|DVDRip)\b', '', name, flags=re.IGNORECASE)
    name = re.sub(r'\b(x264|x265|HEVC|AVC|H\.264|H\.265)\b', '', name, flags=re.IGNORECASE)
    name = re.sub(r'\b(HDR|DV|Atmos|TrueHD|DTS|DD\+?|AAC)\b', '', name, flags=re.IGNORECASE)
    name = re.sub(r'\[.*?\]', '', name)  # Remove brackets
    name = re.sub(r'\{.*?\}', '', name)  # Remove braces
    
    # Clean up
    name = re.sub(r'[.\-_]+', ' ', name)  # Replace separators with spaces
    name = re.sub(r'\s+', ' ', name)  # Collapse spaces
    name = name.strip().lower()
    
    return name

def match_files(ali_inventory: List[Dict], chris_inventory: List[Dict]) -> Dict[str, Tuple[Optional[Dict], Optional[Dict]]]:
    """Match files between two inventories by normalized title"""
    matches = {}
    
    # Index Ali's files by normalized title
    ali_index = {}
    for file_entry in ali_inventory:
        title = normalize_title(file_entry['filename'])
        ali_index[title] = file_entry
    
    # Index Chris's files by normalized title
    chris_index = {}
    for file_entry in chris_inventory:
        title = normalize_title(file_entry['filename'])
        chris_index[title] = file_entry
    
    # Find all unique titles
    all_titles = set(ali_index.keys()) | set(chris_index.keys())
    
    # Create matches
    for title in all_titles:
        matches[title] = (
            ali_index.get(title),
            chris_index.get(title)
        )
    
    return matches

def compare_files(ali_file: Optional[Dict], chris_file: Optional[Dict]) -> ComparisonResult:
    """Compare two files and determine which is better"""
    
    # Calculate scores
    ali_score = calculate_quality_score(ali_file) if ali_file else 0
    chris_score = calculate_quality_score(chris_file) if chris_file else 0
    
    # Determine winner
    if not ali_file and chris_file:
        winner = 'chris'
        reason = "Only Chris has this file"
        recommendation = "Copy from Chris to Ali"
    elif ali_file and not chris_file:
        winner = 'ali'
        reason = "Only Ali has this file"
        recommendation = "Copy from Ali to Chris"
    elif ali_score > chris_score:
        winner = 'ali'
        diff = ali_score - chris_score
        reason = f"Ali's version is higher quality (score: {ali_score} vs {chris_score}, diff: +{diff})"
        recommendation = "Replace Chris's version with Ali's version"
    elif chris_score > ali_score:
        winner = 'chris'
        diff = chris_score - ali_score
        reason = f"Chris's version is higher quality (score: {chris_score} vs {ali_score}, diff: +{diff})"
        recommendation = "Replace Ali's version with Chris's version"
    else:
        winner = 'tie'
        reason = f"Both versions are equal quality (score: {ali_score})"
        recommendation = "Keep existing versions (no action needed)"
    
    return ComparisonResult(
        ali_file=ali_file,
        chris_file=chris_file,
        winner=winner,
        ali_score=ali_score,
        chris_score=chris_score,
        reason=reason,
        recommendation=recommendation
    )

###############################################################################
# Report Generation
###############################################################################

def generate_report(comparisons: Dict[str, ComparisonResult], output_dir: Path):
    """Generate comparison report"""
    
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    
    # Statistics
    stats = {
        'total': len(comparisons),
        'ali_only': 0,
        'chris_only': 0,
        'ali_better': 0,
        'chris_better': 0,
        'tie': 0,
    }
    
    # Categorize
    ali_only = []
    chris_only = []
    ali_better = []
    chris_better = []
    ties = []
    
    for title, result in comparisons.items():
        if result.winner == 'ali' and not result.chris_file:
            ali_only.append((title, result))
            stats['ali_only'] += 1
        elif result.winner == 'chris' and not result.ali_file:
            chris_only.append((title, result))
            stats['chris_only'] += 1
        elif result.winner == 'ali':
            ali_better.append((title, result))
            stats['ali_better'] += 1
        elif result.winner == 'chris':
            chris_better.append((title, result))
            stats['chris_better'] += 1
        else:
            ties.append((title, result))
            stats['tie'] += 1
    
    # Generate summary report
    summary_file = output_dir / f'comparison_summary_{timestamp}.txt'
    with open(summary_file, 'w', encoding='utf-8') as f:
        f.write("="*80 + "\n")
        f.write("MEDIA LIBRARY COMPARISON REPORT\n")
        f.write("="*80 + "\n\n")
        
        f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        
        f.write("STATISTICS\n")
        f.write("-"*80 + "\n")
        f.write(f"Total titles compared: {stats['total']}\n")
        f.write(f"Ali only: {stats['ali_only']}\n")
        f.write(f"Chris only: {stats['chris_only']}\n")
        f.write(f"Ali has better version: {stats['ali_better']}\n")
        f.write(f"Chris has better version: {stats['chris_better']}\n")
        f.write(f"Equal quality: {stats['tie']}\n\n")
        
        # Files to copy to Chris
        f.write("="*80 + "\n")
        f.write(f"FILES TO COPY TO CHRIS ({len(ali_only) + len(ali_better)})\n")
        f.write("="*80 + "\n\n")
        
        for title, result in sorted(ali_only + ali_better, key=lambda x: x[0]):
            f.write(f"Title: {title}\n")
            if result.ali_file:
                f.write(f"  File: {result.ali_file['filename']}\n")
                f.write(f"  Size: {result.ali_file['size_gb']:.2f} GB\n")
                f.write(f"  Quality Score: {result.ali_score}\n")
            f.write(f"  Reason: {result.reason}\n")
            f.write(f"  Action: {result.recommendation}\n\n")
        
        # Files to copy to Ali
        f.write("="*80 + "\n")
        f.write(f"FILES TO COPY TO ALI ({len(chris_only) + len(chris_better)})\n")
        f.write("="*80 + "\n\n")
        
        for title, result in sorted(chris_only + chris_better, key=lambda x: x[0]):
            f.write(f"Title: {title}\n")
            if result.chris_file:
                f.write(f"  File: {result.chris_file['filename']}\n")
                f.write(f"  Size: {result.chris_file['size_gb']:.2f} GB\n")
                f.write(f"  Quality Score: {result.chris_score}\n")
            f.write(f"  Reason: {result.reason}\n")
            f.write(f"  Action: {result.recommendation}\n\n")
    
    print(f"\n✅ Summary report: {summary_file}")
    
    # Generate CSV for sync plan
    sync_plan_file = output_dir / f'sync_plan_{timestamp}.csv'
    with open(sync_plan_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['Direction', 'Title', 'Filename', 'Size_GB', 'Quality_Score', 'Reason'])
        
        for title, result in ali_only + ali_better:
            writer.writerow([
                'Ali → Chris',
                title,
                result.ali_file['filename'] if result.ali_file else '',
                f"{result.ali_file['size_gb']:.2f}" if result.ali_file else '',
                result.ali_score,
                result.reason
            ])
        
        for title, result in chris_only + chris_better:
            writer.writerow([
                'Chris → Ali',
                title,
                result.chris_file['filename'] if result.chris_file else '',
                f"{result.chris_file['size_gb']:.2f}" if result.chris_file else '',
                result.chris_score,
                result.reason
            ])
    
    print(f"✅ Sync plan CSV: {sync_plan_file}")
    
    return stats

###############################################################################
# Main
###############################################################################

def main():
    parser = argparse.ArgumentParser(
        description='Compare two media library inventories'
    )
    parser.add_argument(
        'ali_inventory',
        type=Path,
        help='Ali\'s inventory JSON file'
    )
    parser.add_argument(
        'chris_inventory',
        type=Path,
        help='Chris\'s inventory JSON file'
    )
    parser.add_argument(
        '-o', '--output-dir',
        type=Path,
        default=Path('.'),
        help='Output directory for reports'
    )
    
    args = parser.parse_args()
    
    # Load inventories
    print(f"📖 Loading Ali's inventory: {args.ali_inventory}")
    with open(args.ali_inventory, 'r', encoding='utf-8') as f:
        ali_inventory = json.load(f)
    print(f"   Found {len(ali_inventory)} files")
    
    print(f"📖 Loading Chris's inventory: {args.chris_inventory}")
    with open(args.chris_inventory, 'r', encoding='utf-8') as f:
        chris_inventory = json.load(f)
    print(f"   Found {len(chris_inventory)} files")
    
    # Match files
    print("\n🔍 Matching files...")
    matches = match_files(ali_inventory, chris_inventory)
    print(f"   Found {len(matches)} unique titles")
    
    # Compare files
    print("\n⚖️  Comparing quality...")
    comparisons = {}
    for title, (ali_file, chris_file) in matches.items():
        comparisons[title] = compare_files(ali_file, chris_file)
    
    # Generate report
    print("\n📝 Generating report...")
    args.output_dir.mkdir(parents=True, exist_ok=True)
    stats = generate_report(comparisons, args.output_dir)
    
    # Print summary
    print("\n" + "="*80)
    print("COMPARISON COMPLETE")
    print("="*80)
    print(f"Total titles: {stats['total']}")
    print(f"Ali only: {stats['ali_only']}")
    print(f"Chris only: {stats['chris_only']}")
    print(f"Ali better: {stats['ali_better']}")
    print(f"Chris better: {stats['chris_better']}")
    print(f"Equal: {stats['tie']}")
    print("="*80)

if __name__ == '__main__':
    main()
