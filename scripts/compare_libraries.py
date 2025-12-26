#!/usr/bin/env python3
"""
Media Library Comparison Tool (FIXED VERSION)

Purpose: Compare two media library inventories and determine:
         1. What files each library is missing
         2. Which version of duplicate files is higher quality
         3. Generate sync plan with REVIEW folder for overwrites

FIXES:
- Handles multiple versions of same title properly
- Creates review folder for files that will be overwritten
- More detailed reporting

Author: Project Mother
Last Updated: 2024-12-26
"""

import json
import csv
import argparse
from pathlib import Path
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass
from datetime import datetime
from collections import defaultdict

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
    'HDR10': 300,
    'DV HDR10': 280,
    'HDR': 250,
    'DV': 150,
    'DV HLG': 140,
    'DV SDR': 130,
    'HDR10+': 100,
    'HLG': 100,
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
    'AV1': 250,
    'HEVC': 200,
    'AVC': 150,
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
    needs_review: bool = False  # If overwriting existing file

###############################################################################
# Comparison Functions
###############################################################################

def calculate_quality_score(file_entry: Dict) -> int:
    """Calculate overall quality score for a file"""
    score = 0
    
    # Resolution
    score += RESOLUTION_SCORES.get(file_entry.get('resolution', 'Unknown'), 0)
    
    # Source
    score += SOURCE_SCORES.get(file_entry.get('source', 'Unknown'), 0)
    
    # HDR
    score += HDR_SCORES.get(file_entry.get('hdr', 'None'), 0)
    
    # Audio
    score += AUDIO_SCORES.get(file_entry.get('audio_codec', 'Unknown'), 0)
    
    # Codec
    score += CODEC_SCORES.get(file_entry.get('video_codec', 'Unknown'), 0)
    
    # File size bonus (larger is generally better for same quality)
    size_gb = file_entry.get('size_gb', 0)
    score += min(int(size_gb * 0.01), 100)
    
    return score

def normalize_title(filename: str) -> str:
    """Normalize movie/show title for comparison"""
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
    name = re.sub(r'[.\-_]+', ' ', name)
    name = re.sub(r'\s+', ' ', name)
    name = name.strip().lower()
    
    return name

def match_files(ali_inventory: List[Dict], chris_inventory: List[Dict]) -> Dict[str, Tuple[List[Dict], List[Dict]]]:
    """Match files between two inventories by normalized title - SUPPORTS MULTIPLE VERSIONS"""
    matches = defaultdict(lambda: ([], []))
    
    # Index Ali's files by normalized title - KEEP ALL VERSIONS
    ali_index = defaultdict(list)
    for file_entry in ali_inventory:
        title = normalize_title(file_entry['title'])
        ali_index[title].append(file_entry)
    
    # Index Chris's files by normalized title - KEEP ALL VERSIONS
    chris_index = defaultdict(list)
    for file_entry in chris_inventory:
        title = normalize_title(file_entry['title'])
        chris_index[title].append(file_entry)
    
    # Find all unique titles
    all_titles = set(ali_index.keys()) | set(chris_index.keys())
    
    # Create matches
    for title in all_titles:
        matches[title] = (ali_index.get(title, []), chris_index.get(title, []))
    
    return matches

def compare_file_sets(ali_files: List[Dict], chris_files: List[Dict]) -> List[ComparisonResult]:
    """Compare sets of files for the same title - handles multiple versions"""
    results = []
    
    # If only one person has files
    if not ali_files:
        for chris_file in chris_files:
            score = calculate_quality_score(chris_file)
            results.append(ComparisonResult(
                ali_file=None,
                chris_file=chris_file,
                winner='chris',
                ali_score=0,
                chris_score=score,
                reason="Only Chris has this file",
                recommendation="Copy from Chris to Ali",
                needs_review=False
            ))
        return results
    
    if not chris_files:
        for ali_file in ali_files:
            score = calculate_quality_score(ali_file)
            results.append(ComparisonResult(
                ali_file=ali_file,
                chris_file=None,
                winner='ali',
                ali_score=score,
                chris_score=0,
                reason="Only Ali has this file",
                recommendation="Copy from Ali to Chris",
                needs_review=False
            ))
        return results
    
    # Both have files - find best version from each
    ali_files_scored = [(f, calculate_quality_score(f)) for f in ali_files]
    chris_files_scored = [(f, calculate_quality_score(f)) for f in chris_files]
    
    # Sort by score descending
    ali_files_scored.sort(key=lambda x: x[1], reverse=True)
    chris_files_scored.sort(key=lambda x: x[1], reverse=True)
    
    # Compare best versions
    best_ali, ali_score = ali_files_scored[0]
    best_chris, chris_score = chris_files_scored[0]
    
    if ali_score > chris_score:
        diff = ali_score - chris_score
        results.append(ComparisonResult(
            ali_file=best_ali,
            chris_file=best_chris,
            winner='ali',
            ali_score=ali_score,
            chris_score=chris_score,
            reason=f"Ali's version is higher quality (score: {ali_score} vs {chris_score}, diff: +{diff})",
            recommendation=f"Replace Chris's version ({best_chris['filename']}) with Ali's ({best_ali['filename']})",
            needs_review=True  # Will overwrite Chris's file!
        ))
    elif chris_score > ali_score:
        diff = chris_score - ali_score
        results.append(ComparisonResult(
            ali_file=best_ali,
            chris_file=best_chris,
            winner='chris',
            ali_score=ali_score,
            chris_score=chris_score,
            reason=f"Chris's version is higher quality (score: {chris_score} vs {ali_score}, diff: +{diff})",
            recommendation=f"Replace Ali's version ({best_ali['filename']}) with Chris's ({best_chris['filename']})",
            needs_review=True  # Will overwrite Ali's file!
        ))
    else:
        results.append(ComparisonResult(
            ali_file=best_ali,
            chris_file=best_chris,
            winner='tie',
            ali_score=ali_score,
            chris_score=chris_score,
            reason=f"Both versions are equal quality (score: {ali_score})",
            recommendation="Keep existing versions (no action needed)",
            needs_review=False
        ))
    
    # Report other versions
    if len(ali_files_scored) > 1:
        for file, score in ali_files_scored[1:]:
            results.append(ComparisonResult(
                ali_file=file,
                chris_file=None,
                winner='ali',
                ali_score=score,
                chris_score=0,
                reason=f"Ali has additional version (lower quality: {score} vs {ali_score})",
                recommendation="Keep as alternate version",
                needs_review=False
            ))
    
    if len(chris_files_scored) > 1:
        for file, score in chris_files_scored[1:]:
            results.append(ComparisonResult(
                ali_file=None,
                chris_file=file,
                winner='chris',
                ali_score=0,
                chris_score=score,
                reason=f"Chris has additional version (lower quality: {score} vs {chris_score})",
                recommendation="Keep as alternate version",
                needs_review=False
            ))
    
    return results

###############################################################################
# Report Generation
###############################################################################

def generate_report(all_results: List[ComparisonResult], output_dir: Path):
    """Generate comparison report"""
    
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    
    # Statistics
    stats = {
        'total_comparisons': len(all_results),
        'ali_only': 0,
        'chris_only': 0,
        'ali_better': 0,
        'chris_better': 0,
        'tie': 0,
        'needs_review': 0,
    }
    
    # Categorize
    ali_only = []
    chris_only = []
    ali_better = []
    chris_better = []
    ties = []
    needs_review = []
    
    for result in all_results:
        if result.winner == 'ali' and not result.chris_file:
            ali_only.append(result)
            stats['ali_only'] += 1
        elif result.winner == 'chris' and not result.ali_file:
            chris_only.append(result)
            stats['chris_only'] += 1
        elif result.winner == 'ali' and result.chris_file:
            ali_better.append(result)
            stats['ali_better'] += 1
            if result.needs_review:
                needs_review.append(result)
                stats['needs_review'] += 1
        elif result.winner == 'chris' and result.ali_file:
            chris_better.append(result)
            stats['chris_better'] += 1
            if result.needs_review:
                needs_review.append(result)
                stats['needs_review'] += 1
        else:
            ties.append(result)
            stats['tie'] += 1
    
    # Generate summary report
    summary_file = output_dir / f'comparison_summary_{timestamp}.txt'
    with open(summary_file, 'w', encoding='utf-8') as f:
        f.write("="*80 + "\n")
        f.write("MEDIA LIBRARY COMPARISON REPORT (FIXED VERSION)\n")
        f.write("="*80 + "\n\n")
        
        f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")
        
        f.write("STATISTICS\n")
        f.write("-"*80 + "\n")
        f.write(f"Total comparisons: {stats['total_comparisons']}\n")
        f.write(f"Ali only: {stats['ali_only']}\n")
        f.write(f"Chris only: {stats['chris_only']}\n")
        f.write(f"Ali has better version: {stats['ali_better']}\n")
        f.write(f"Chris has better version: {stats['chris_better']}\n")
        f.write(f"Equal quality: {stats['tie']}\n")
        f.write(f"⚠️  NEEDS REVIEW (will overwrite): {stats['needs_review']}\n\n")
        
        # Files that need review (overwrites)
        if needs_review:
            f.write("="*80 + "\n")
            f.write(f"⚠️  FILES THAT WILL OVERWRITE EXISTING (REVIEW REQUIRED)\n")
            f.write("="*80 + "\n\n")
            for result in needs_review:
                f.write(f"Title: {result.ali_file['title'] if result.ali_file else result.chris_file['title']}\n")
                if result.winner == 'ali':
                    f.write(f"  Will replace: {result.chris_file['filename']} (score: {result.chris_score})\n")
                    f.write(f"  With: {result.ali_file['filename']} (score: {result.ali_score})\n")
                else:
                    f.write(f"  Will replace: {result.ali_file['filename']} (score: {result.ali_score})\n")
                    f.write(f"  With: {result.chris_file['filename']} (score: {result.chris_score})\n")
                f.write(f"  Reason: {result.reason}\n")
                f.write(f"  ⚠️  Move old file to REVIEW folder before syncing!\n\n")
        
        # Files to copy to Chris
        f.write("="*80 + "\n")
        f.write(f"FILES TO COPY TO CHRIS ({len(ali_only) + len([r for r in ali_better if not r.needs_review])})\n")
        f.write("="*80 + "\n\n")
        
        for result in ali_only:
            f.write(f"Title: {result.ali_file['title']}\n")
            f.write(f"  File: {result.ali_file['filename']}\n")
            f.write(f"  Size: {result.ali_file['size_gb']:.2f} GB\n")
            f.write(f"  Quality Score: {result.ali_score}\n")
            f.write(f"  Reason: {result.reason}\n\n")
        
        # Files to copy to Ali
        f.write("="*80 + "\n")
        f.write(f"FILES TO COPY TO ALI ({len(chris_only) + len([r for r in chris_better if not r.needs_review])})\n")
        f.write("="*80 + "\n\n")
        
        for result in chris_only:
            f.write(f"Title: {result.chris_file['title']}\n")
            f.write(f"  File: {result.chris_file['filename']}\n")
            f.write(f"  Size: {result.chris_file['size_gb']:.2f} GB\n")
            f.write(f"  Quality Score: {result.chris_score}\n")
            f.write(f"  Reason: {result.reason}\n\n")
    
    print(f"\n✅ Summary report: {summary_file}")
    
    # Generate CSV for sync plan
    sync_plan_file = output_dir / f'sync_plan_{timestamp}.csv'
    with open(sync_plan_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow(['Direction', 'Title', 'Filename', 'Size_GB', 'Quality_Score', 'Reason', 'Needs_Review', 'Will_Replace'])
        
        for result in ali_only + ali_better:
            writer.writerow([
                'Ali → Chris',
                result.ali_file['title'],
                result.ali_file['filename'],
                f"{result.ali_file['size_gb']:.2f}",
                result.ali_score,
                result.reason,
                'YES' if result.needs_review else 'NO',
                result.chris_file['filename'] if result.chris_file else 'N/A'
            ])
        
        for result in chris_only + chris_better:
            writer.writerow([
                'Chris → Ali',
                result.chris_file['title'],
                result.chris_file['filename'],
                f"{result.chris_file['size_gb']:.2f}",
                result.chris_score,
                result.reason,
                'YES' if result.needs_review else 'NO',
                result.ali_file['filename'] if result.ali_file else 'N/A'
            ])
    
    print(f"✅ Sync plan CSV: {sync_plan_file}")
    
    return stats

###############################################################################
# Main
###############################################################################

def main():
    parser = argparse.ArgumentParser(
        description='Compare two media library inventories (FIXED VERSION)'
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
    print("\n🔍 Matching files (handles multiple versions)...")
    matches = match_files(ali_inventory, chris_inventory)
    print(f"   Found {len(matches)} unique titles")
    
    # Compare files
    print("\n⚖️  Comparing quality...")
    all_results = []
    for title, (ali_files, chris_files) in matches.items():
        results = compare_file_sets(ali_files, chris_files)
        all_results.extend(results)
    
    # Generate report
    print("\n📝 Generating report...")
    args.output_dir.mkdir(parents=True, exist_ok=True)
    stats = generate_report(all_results, args.output_dir)
    
    # Print summary
    print("\n" + "="*80)
    print("COMPARISON COMPLETE (FIXED VERSION)")
    print("="*80)
    print(f"Total comparisons: {stats['total_comparisons']}")
    print(f"Ali only: {stats['ali_only']}")
    print(f"Chris only: {stats['chris_only']}")
    print(f"Ali better: {stats['ali_better']}")
    print(f"Chris better: {stats['chris_better']}")
    print(f"Equal: {stats['tie']}")
    print(f"⚠️  Needs review (overwrites): {stats['needs_review']}")
    print("="*80)

if __name__ == '__main__':
    main()
