#!/usr/bin/env python3
"""
Media Library Comparison Tool - Project Mother

Purpose: Compare two media library inventories and determine:
         1. What files each library is missing
         2. Which version of duplicate files is higher quality
         3. Generate sync plan with deleted folder handling

Features:
- Option C: Uses path to determine library type (4K vs 1080p)
- Parses TRaSH-format filenames for quality attributes
- Validates file placement (flags misplaced files)
- Updated scoring from HDR & Audio Format Preferences.md
- Audio trumps HDR at 1080p

Author: Project Mother
Last Updated: 2024-12-28
"""

import json
import csv
import argparse
import re
from pathlib import Path
from typing import Dict, List, Tuple, Optional
from dataclasses import dataclass, field
from datetime import datetime
from collections import defaultdict

###############################################################################
# Library Path Configuration
###############################################################################

# Synology paths
SYNOLOGY_PATHS = {
    'movies_1080p': '/mnt/synology/rs-movies',
    'movies_4k': '/mnt/synology/rs-4kmedia/4kmovies',
    'tv_1080p': '/mnt/synology/rs-tv',
    'tv_4k': '/mnt/synology/rs-4kmedia/4ktv',
    'deleted_movies': '/mnt/synology/Deleted/Movies',
    'deleted_4k_movies': '/mnt/synology/Deleted/4kMovies',
    'deleted_tv': '/mnt/synology/Deleted/tvshows',
    'deleted_4k_tv': '/mnt/synology/Deleted/4ktvshows',
}

# Unraid paths
UNRAID_PATHS = {
    'movies_1080p': '/mnt/unraid/media/Movies',
    'movies_4k': '/mnt/unraid/media/4K Movies',
    'tv_1080p': '/mnt/unraid/media/TV Shows',
    'tv_4k': '/mnt/unraid/media/4K TV Shows',
    'deleted_movies': '/mnt/unraid/media/Deleted/Movies',
    'deleted_4k_movies': '/mnt/unraid/media/Deleted/4kMovies',
    'deleted_tv': '/mnt/unraid/media/Deleted/tvshows',
    'deleted_4k_tv': '/mnt/unraid/media/Deleted/4ktvshows',
}

###############################################################################
# Quality Scoring (From HDR & Audio Format Preferences.md)
###############################################################################

# Resolution scores
RESOLUTION_SCORES = {
    '2160p': 4000,
    '1080p': 2000,
    '720p': 1000,
    '480p': 100,
    'Unknown': 0,
}

# Source scores
SOURCE_SCORES = {
    'Remux': 2000,
    'Bluray': 1500,
    'BluRay': 1500,
    'WEB-DL': 1000,
    'WEBDL': 1000,
    'WEBRip': 800,
    'HDTV': 200,
    'DVDRip': 100,
    'Unknown': 0,
}

# HDR scores for 4K
HDR_SCORES_4K = {
    'DV HDR10': 800,
    'DV HDR10+': 800,
    'HDR10': 700,
    'HDR': 700,
    'DV': 400,
    'DV HLG': 400,
    'DV SDR': 300,
    'HDR10+': 300,
    'HLG': 300,
    'SDR': 0,
    'None': 0,
    '': 0,
}

# HDR scores for 1080p (bonus for downscaled 4K releases)
HDR_SCORES_1080P = {
    'DV HDR10': 400,
    'DV HDR10+': 400,
    'HDR10': 400,
    'HDR': 400,
    'DV': 350,
    'DV HLG': 350,
    'DV SDR': 300,
    'HDR10+': 350,
    'HLG': 300,
    'SDR': 0,
    'None': 0,
    '': 0,
}

# Audio scores (Audio trumps HDR at 1080p!)
AUDIO_SCORES = {
    'TrueHD Atmos': 500,
    'Atmos': 500,
    'TrueHD': 450,
    'DTS-HD MA': 400,
    'DTS-HD': 350,
    'DTS:X': 400,
    'DTSX': 400,
    'DTS': 200,
    'DD+': 150,
    'EAC3': 150,
    'DD': 100,
    'AC3': 100,
    'AAC': 50,
    'Unknown': 0,
    '': 0,
}

# Codec scores
CODEC_SCORES = {
    'AV1': 250,
    'HEVC': 200,
    'H.265': 200,
    'x265': 200,
    'AVC': 100,
    'H.264': 100,
    'x264': 100,
    'Unknown': 0,
    '': 0,
}

###############################################################################
# Filename Parsing (TRaSH Format)
###############################################################################

def detect_library_type(path: str) -> str:
    """
    Detect library type from file path

    Returns: '4k_movies', '1080p_movies', '4k_tv', '1080p_tv', or 'unknown'
    """
    path_lower = path.lower()

    # Check for 4K indicators
    if any(x in path_lower for x in ['4kmovies', '4k movies', 'rs-4kmedia/4kmovies', '/4k movies/']):
        return '4k_movies'
    if any(x in path_lower for x in ['4ktv', '4k tv', 'rs-4kmedia/4ktv', '/4k tv shows/']):
        return '4k_tv'

    # Check for 1080p/standard indicators
    if any(x in path_lower for x in ['rs-movies', '/movies/']):
        if '4k' not in path_lower:
            return '1080p_movies'
    if any(x in path_lower for x in ['rs-tv', '/tv shows/', '/tv/']):
        if '4k' not in path_lower:
            return '1080p_tv'

    return 'unknown'

def parse_trash_filename(filename: str) -> Dict:
    """
    Parse TRaSH-format filename for quality attributes

    Example: Avatar (2009) {tmdb-19995} - [Bluray-1080p][DTS-HD MA 5.1][HDR][x265]-FraMeSToR.mkv
    """
    result = {
        'resolution': '',
        'source': '',
        'hdr': '',
        'audio': '',
        'codec': '',
        'release_group': '',
    }

    # Extract content in square brackets
    bracket_contents = re.findall(r'\[([^\]]+)\]', filename)

    for content in bracket_contents:
        content_upper = content.upper()

        # Resolution + Source (e.g., "Bluray-1080p", "WEBDL-2160p", "Remux-1080p")
        res_match = re.search(r'(Remux|Bluray|WEBDL|WEB-DL|WEBRip|HDTV)[- ]?(2160p|1080p|720p|480p)', content, re.IGNORECASE)
        if res_match:
            result['source'] = res_match.group(1)
            result['resolution'] = res_match.group(2)
            continue

        # Just resolution
        if content in ['2160p', '1080p', '720p', '480p']:
            result['resolution'] = content
            continue

        # HDR formats
        if 'DV HDR10+' in content_upper or 'DOLBY VISION HDR10+' in content_upper:
            result['hdr'] = 'DV HDR10+'
            continue
        if 'DV HDR10' in content_upper or 'DOLBY VISION HDR10' in content_upper:
            result['hdr'] = 'DV HDR10'
            continue
        if 'DV HLG' in content_upper:
            result['hdr'] = 'DV HLG'
            continue
        if 'DV SDR' in content_upper:
            result['hdr'] = 'DV SDR'
            continue
        if content_upper in ['DV', 'DOLBY VISION', 'DOVI']:
            result['hdr'] = 'DV'
            continue
        if 'HDR10+' in content_upper:
            result['hdr'] = 'HDR10+'
            continue
        if 'HDR10' in content_upper:
            result['hdr'] = 'HDR10'
            continue
        if content_upper == 'HDR':
            result['hdr'] = 'HDR'
            continue
        if content_upper == 'HLG':
            result['hdr'] = 'HLG'
            continue

        # Audio formats
        if 'TRUEHD ATMOS' in content_upper or 'TRUEHD.ATMOS' in content_upper:
            result['audio'] = 'TrueHD Atmos'
            continue
        if 'TRUEHD' in content_upper:
            result['audio'] = 'TrueHD'
            continue
        if 'DTS-HD MA' in content_upper or 'DTS-HD.MA' in content_upper or 'DTSHD MA' in content_upper:
            result['audio'] = 'DTS-HD MA'
            continue
        if 'DTS-X' in content_upper or 'DTSX' in content_upper:
            result['audio'] = 'DTS:X'
            continue
        if 'DTS-HD' in content_upper or 'DTSHD' in content_upper:
            result['audio'] = 'DTS-HD'
            continue
        if 'DTS' in content_upper and 'HD' not in content_upper:
            result['audio'] = 'DTS'
            continue
        if 'ATMOS' in content_upper and 'TRUEHD' not in content_upper:
            result['audio'] = 'Atmos'
            continue
        if 'EAC3' in content_upper or 'DD+' in content_upper or 'DDP' in content_upper:
            result['audio'] = 'DD+'
            continue
        if 'AC3' in content_upper or content_upper == 'DD':
            result['audio'] = 'DD'
            continue
        if 'AAC' in content_upper:
            result['audio'] = 'AAC'
            continue

        # Codec
        if content_upper in ['HEVC', 'H.265', 'X265', 'H265']:
            result['codec'] = 'HEVC'
            continue
        if content_upper in ['AVC', 'H.264', 'X264', 'H264']:
            result['codec'] = 'AVC'
            continue
        if content_upper == 'AV1':
            result['codec'] = 'AV1'
            continue

    # Extract release group (after last hyphen)
    group_match = re.search(r'-([A-Za-z0-9]+)(?:\.[a-z]{3})?$', filename)
    if group_match:
        result['release_group'] = group_match.group(1)

    return result

def validate_file_placement(path: str, parsed_info: Dict) -> Tuple[bool, str]:
    """
    Validate that file is in the correct library based on resolution

    Returns: (is_valid, warning_message)
    """
    library_type = detect_library_type(path)
    resolution = parsed_info.get('resolution', '')

    if library_type in ['4k_movies', '4k_tv']:
        if resolution and resolution != '2160p':
            return False, f"WARNING: {resolution} file in 4K library!"
    elif library_type in ['1080p_movies', '1080p_tv']:
        if resolution == '2160p':
            return False, f"WARNING: 4K file in 1080p library!"

    return True, ""

###############################################################################
# Data Classes
###############################################################################

@dataclass
class MediaFile:
    """Represents a media file with parsed quality info"""
    path: str
    filename: str
    title: str
    size_gb: float
    resolution: str = ''
    source: str = ''
    hdr: str = ''
    audio: str = ''
    codec: str = ''
    release_group: str = ''
    library_type: str = ''
    is_valid_placement: bool = True
    placement_warning: str = ''
    quality_score: int = 0

@dataclass
class ComparisonResult:
    """Result of comparing two files"""
    ali_file: Optional[MediaFile]
    chris_file: Optional[MediaFile]
    winner: str  # 'ali', 'chris', or 'tie'
    ali_score: int
    chris_score: int
    reason: str
    action: str
    deleted_path: str = ''  # Path to move loser file

###############################################################################
# Scoring Functions
###############################################################################

def calculate_quality_score(media_file: MediaFile) -> int:
    """Calculate overall quality score for a file"""
    score = 0
    is_4k = media_file.library_type in ['4k_movies', '4k_tv']

    # Resolution (1080p trumps everything in 1080p library)
    score += RESOLUTION_SCORES.get(media_file.resolution, 0)

    # Source
    score += SOURCE_SCORES.get(media_file.source, 0)

    # HDR (different scoring for 4K vs 1080p)
    if is_4k:
        score += HDR_SCORES_4K.get(media_file.hdr, 0)
    else:
        score += HDR_SCORES_1080P.get(media_file.hdr, 0)

    # Audio (most important at 1080p - trumps HDR!)
    score += AUDIO_SCORES.get(media_file.audio, 0)

    # Codec
    score += CODEC_SCORES.get(media_file.codec, 0)

    # File size bonus (larger is generally better for same quality)
    score += min(int(media_file.size_gb * 10), 200)

    return score

def parse_inventory_file(file_entry: Dict) -> MediaFile:
    """Convert inventory entry to MediaFile with parsed quality info"""
    path = file_entry.get('path', '')
    filename = file_entry.get('filename', '')

    # Parse filename for quality attributes
    parsed = parse_trash_filename(filename)

    # Detect library type from path
    library_type = detect_library_type(path)

    # Use parsed values, fallback to inventory values
    resolution = parsed['resolution'] or file_entry.get('resolution', '')
    source = parsed['source'] or file_entry.get('source', '')
    hdr = parsed['hdr'] or file_entry.get('hdr', '')
    audio = parsed['audio'] or file_entry.get('audio_codec', '')
    codec = parsed['codec'] or file_entry.get('video_codec', '')

    media_file = MediaFile(
        path=path,
        filename=filename,
        title=file_entry.get('title', ''),
        size_gb=file_entry.get('size_gb', 0),
        resolution=resolution,
        source=source,
        hdr=hdr,
        audio=audio,
        codec=codec,
        release_group=parsed['release_group'],
        library_type=library_type,
    )

    # Validate placement
    is_valid, warning = validate_file_placement(path, parsed)
    media_file.is_valid_placement = is_valid
    media_file.placement_warning = warning

    # Calculate quality score
    media_file.quality_score = calculate_quality_score(media_file)

    return media_file

###############################################################################
# Comparison Functions
###############################################################################

def normalize_title(title: str) -> str:
    """Normalize movie/show title for comparison"""
    name = title
    name = re.sub(r'\(?\d{4}\)?', '', name)  # Year
    name = re.sub(r'\b(2160p|1080p|720p|480p|4K|UHD|HD|SD)\b', '', name, flags=re.IGNORECASE)
    name = re.sub(r'\b(BluRay|Remux|WEB-DL|WEBRip|HDTV|DVDRip)\b', '', name, flags=re.IGNORECASE)
    name = re.sub(r'\[.*?\]', '', name)
    name = re.sub(r'\{.*?\}', '', name)
    name = re.sub(r'[.\-_]+', ' ', name)
    name = re.sub(r'\s+', ' ', name)
    name = name.strip().lower()
    return name

def get_deleted_path(media_file: MediaFile, owner: str) -> str:
    """Get the deleted folder path for a file"""
    paths = SYNOLOGY_PATHS if 'synology' in media_file.path.lower() else UNRAID_PATHS

    if media_file.library_type == '4k_movies':
        return paths['deleted_4k_movies']
    elif media_file.library_type == '1080p_movies':
        return paths['deleted_movies']
    elif media_file.library_type == '4k_tv':
        return paths['deleted_4k_tv']
    elif media_file.library_type == '1080p_tv':
        return paths['deleted_tv']
    else:
        return paths['deleted_movies']  # Default

def match_files(ali_files: List[MediaFile], chris_files: List[MediaFile]) -> Dict[str, Tuple[List[MediaFile], List[MediaFile]]]:
    """Match files between two inventories by normalized title"""
    matches = defaultdict(lambda: ([], []))

    # Index by normalized title
    ali_index = defaultdict(list)
    for f in ali_files:
        title = normalize_title(f.title)
        ali_index[title].append(f)

    chris_index = defaultdict(list)
    for f in chris_files:
        title = normalize_title(f.title)
        chris_index[title].append(f)

    # Find all unique titles
    all_titles = set(ali_index.keys()) | set(chris_index.keys())

    for title in all_titles:
        matches[title] = (ali_index.get(title, []), chris_index.get(title, []))

    return matches

def compare_file_sets(ali_files: List[MediaFile], chris_files: List[MediaFile]) -> List[ComparisonResult]:
    """Compare sets of files for the same title"""
    results = []

    # If only one person has files
    if not ali_files:
        for chris_file in chris_files:
            results.append(ComparisonResult(
                ali_file=None,
                chris_file=chris_file,
                winner='chris',
                ali_score=0,
                chris_score=chris_file.quality_score,
                reason="Only Chris has this file",
                action="COPY Chris → Ali",
                deleted_path='',
            ))
        return results

    if not chris_files:
        for ali_file in ali_files:
            results.append(ComparisonResult(
                ali_file=ali_file,
                chris_file=None,
                winner='ali',
                ali_score=ali_file.quality_score,
                chris_score=0,
                reason="Only Ali has this file",
                action="COPY Ali → Chris",
                deleted_path='',
            ))
        return results

    # Both have files - find best version from each
    ali_files_sorted = sorted(ali_files, key=lambda x: x.quality_score, reverse=True)
    chris_files_sorted = sorted(chris_files, key=lambda x: x.quality_score, reverse=True)

    best_ali = ali_files_sorted[0]
    best_chris = chris_files_sorted[0]

    if best_ali.quality_score > best_chris.quality_score:
        diff = best_ali.quality_score - best_chris.quality_score
        deleted_path = get_deleted_path(best_chris, 'chris')
        results.append(ComparisonResult(
            ali_file=best_ali,
            chris_file=best_chris,
            winner='ali',
            ali_score=best_ali.quality_score,
            chris_score=best_chris.quality_score,
            reason=f"Ali's version is higher quality (+{diff})",
            action=f"MOVE Chris's to Deleted, COPY Ali's to Chris",
            deleted_path=deleted_path,
        ))
    elif best_chris.quality_score > best_ali.quality_score:
        diff = best_chris.quality_score - best_ali.quality_score
        deleted_path = get_deleted_path(best_ali, 'ali')
        results.append(ComparisonResult(
            ali_file=best_ali,
            chris_file=best_chris,
            winner='chris',
            ali_score=best_ali.quality_score,
            chris_score=best_chris.quality_score,
            reason=f"Chris's version is higher quality (+{diff})",
            action=f"MOVE Ali's to Deleted, COPY Chris's to Ali",
            deleted_path=deleted_path,
        ))
    else:
        results.append(ComparisonResult(
            ali_file=best_ali,
            chris_file=best_chris,
            winner='tie',
            ali_score=best_ali.quality_score,
            chris_score=best_chris.quality_score,
            reason=f"Both versions are equal quality ({best_ali.quality_score})",
            action="NO ACTION (keep both)",
            deleted_path='',
        ))

    return results

###############################################################################
# Report Generation
###############################################################################

def generate_reports(all_results: List[ComparisonResult], misplaced_files: List[MediaFile], output_dir: Path):
    """Generate comparison reports and sync scripts"""
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')

    # Statistics
    stats = {
        'total': len(all_results),
        'ali_only': len([r for r in all_results if r.winner == 'ali' and not r.chris_file]),
        'chris_only': len([r for r in all_results if r.winner == 'chris' and not r.ali_file]),
        'ali_better': len([r for r in all_results if r.winner == 'ali' and r.chris_file]),
        'chris_better': len([r for r in all_results if r.winner == 'chris' and r.ali_file]),
        'tie': len([r for r in all_results if r.winner == 'tie']),
        'misplaced': len(misplaced_files),
    }

    # Generate detailed report
    report_file = output_dir / f'detailed_comparison_{timestamp}.txt'
    with open(report_file, 'w', encoding='utf-8') as f:
        f.write("="*100 + "\n")
        f.write("PROJECT MOTHER - MEDIA LIBRARY COMPARISON REPORT\n")
        f.write("="*100 + "\n\n")
        f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n\n")

        f.write("STATISTICS\n")
        f.write("-"*50 + "\n")
        f.write(f"Total comparisons: {stats['total']}\n")
        f.write(f"Ali only (copy to Chris): {stats['ali_only']}\n")
        f.write(f"Chris only (copy to Ali): {stats['chris_only']}\n")
        f.write(f"Ali better (replace Chris's): {stats['ali_better']}\n")
        f.write(f"Chris better (replace Ali's): {stats['chris_better']}\n")
        f.write(f"Equal quality (no action): {stats['tie']}\n")
        f.write(f"Misplaced files (wrong library): {stats['misplaced']}\n\n")

        # Misplaced files warning
        if misplaced_files:
            f.write("="*100 + "\n")
            f.write("⚠️  MISPLACED FILES (WRONG LIBRARY)\n")
            f.write("="*100 + "\n\n")
            for mf in misplaced_files:
                f.write(f"  {mf.filename}\n")
                f.write(f"    Path: {mf.path}\n")
                f.write(f"    Warning: {mf.placement_warning}\n\n")

        # Files to sync
        f.write("="*100 + "\n")
        f.write("SYNC ACTIONS\n")
        f.write("="*100 + "\n\n")

        for result in all_results:
            if result.winner == 'tie':
                continue

            title = result.ali_file.title if result.ali_file else result.chris_file.title
            f.write(f"Title: {title}\n")

            if result.ali_file:
                f.write(f"  Ali: {result.ali_file.filename} (Score: {result.ali_score})\n")
                f.write(f"       [{result.ali_file.resolution}][{result.ali_file.source}][{result.ali_file.audio}][{result.ali_file.hdr}][{result.ali_file.codec}]\n")
            else:
                f.write(f"  Ali: (none)\n")

            if result.chris_file:
                f.write(f"  Chris: {result.chris_file.filename} (Score: {result.chris_score})\n")
                f.write(f"         [{result.chris_file.resolution}][{result.chris_file.source}][{result.chris_file.audio}][{result.chris_file.hdr}][{result.chris_file.codec}]\n")
            else:
                f.write(f"  Chris: (none)\n")

            f.write(f"  Winner: {result.winner.upper()}\n")
            f.write(f"  Reason: {result.reason}\n")
            f.write(f"  Action: {result.action}\n")
            if result.deleted_path:
                f.write(f"  Deleted folder: {result.deleted_path}\n")
            f.write("\n")

    print(f"✅ Detailed report: {report_file}")

    # Generate sync script
    script_file = output_dir / f'sync_actions_{timestamp}.sh'
    with open(script_file, 'w', encoding='utf-8') as f:
        f.write("#!/bin/bash\n")
        f.write("# Project Mother Sync Script\n")
        f.write(f"# Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write("# Review carefully before executing!\n\n")
        f.write("set -e\n\n")

        f.write("# DRY RUN MODE - Remove 'echo' to execute\n")
        f.write("DRY_RUN=true\n\n")

        f.write('run_cmd() {\n')
        f.write('    if [ "$DRY_RUN" = true ]; then\n')
        f.write('        echo "[DRY RUN] $@"\n')
        f.write('    else\n')
        f.write('        "$@"\n')
        f.write('    fi\n')
        f.write('}\n\n')

        # Moves to deleted folders
        f.write("# === MOVE TO DELETED FOLDERS ===\n\n")
        for result in all_results:
            if result.deleted_path and result.winner != 'tie':
                if result.winner == 'ali' and result.chris_file:
                    src = result.chris_file.path
                    f.write(f'# Move Chris\'s lower quality version\n')
                    f.write(f'run_cmd mv "{src}" "{result.deleted_path}/"\n\n')
                elif result.winner == 'chris' and result.ali_file:
                    src = result.ali_file.path
                    f.write(f'# Move Ali\'s lower quality version\n')
                    f.write(f'run_cmd mv "{src}" "{result.deleted_path}/"\n\n')

        # Copies
        f.write("\n# === COPY FILES ===\n\n")
        for result in all_results:
            if result.winner == 'ali' and result.ali_file:
                # Determine destination based on library type
                if 'synology' in result.ali_file.path.lower():
                    # Ali file is on synology, copy to unraid
                    if result.ali_file.library_type == '4k_movies':
                        dest = UNRAID_PATHS['movies_4k']
                    else:
                        dest = UNRAID_PATHS['movies_1080p']
                else:
                    # Ali file is on unraid, copy to synology
                    if result.ali_file.library_type == '4k_movies':
                        dest = SYNOLOGY_PATHS['movies_4k']
                    else:
                        dest = SYNOLOGY_PATHS['movies_1080p']

                f.write(f'# Copy Ali\'s version\n')
                f.write(f'run_cmd rsync -avP "{result.ali_file.path}" "{dest}/"\n\n')

            elif result.winner == 'chris' and result.chris_file:
                if 'synology' in result.chris_file.path.lower():
                    if result.chris_file.library_type == '4k_movies':
                        dest = UNRAID_PATHS['movies_4k']
                    else:
                        dest = UNRAID_PATHS['movies_1080p']
                else:
                    if result.chris_file.library_type == '4k_movies':
                        dest = SYNOLOGY_PATHS['movies_4k']
                    else:
                        dest = SYNOLOGY_PATHS['movies_1080p']

                f.write(f'# Copy Chris\'s version\n')
                f.write(f'run_cmd rsync -avP "{result.chris_file.path}" "{dest}/"\n\n')

    print(f"✅ Sync script: {script_file}")

    # Generate CSV
    csv_file = output_dir / f'sync_plan_{timestamp}.csv'
    with open(csv_file, 'w', newline='', encoding='utf-8') as f:
        writer = csv.writer(f)
        writer.writerow([
            'Title', 'Winner', 'Ali_File', 'Ali_Score', 'Chris_File', 'Chris_Score',
            'Action', 'Deleted_Path', 'Reason'
        ])

        for result in all_results:
            writer.writerow([
                result.ali_file.title if result.ali_file else result.chris_file.title,
                result.winner,
                result.ali_file.filename if result.ali_file else '',
                result.ali_score,
                result.chris_file.filename if result.chris_file else '',
                result.chris_score,
                result.action,
                result.deleted_path,
                result.reason,
            ])

    print(f"✅ CSV plan: {csv_file}")

    return stats

###############################################################################
# Main
###############################################################################

def main():
    parser = argparse.ArgumentParser(
        description='Compare media libraries - Project Mother (Updated 2024-12-28)'
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

    # Load and parse inventories
    print(f"📖 Loading Ali's inventory: {args.ali_inventory}")
    with open(args.ali_inventory, 'r', encoding='utf-8') as f:
        ali_raw = json.load(f)
    ali_files = [parse_inventory_file(entry) for entry in ali_raw]
    print(f"   Parsed {len(ali_files)} files")

    print(f"📖 Loading Chris's inventory: {args.chris_inventory}")
    with open(args.chris_inventory, 'r', encoding='utf-8') as f:
        chris_raw = json.load(f)
    chris_files = [parse_inventory_file(entry) for entry in chris_raw]
    print(f"   Parsed {len(chris_files)} files")

    # Find misplaced files
    misplaced_files = [f for f in ali_files + chris_files if not f.is_valid_placement]
    if misplaced_files:
        print(f"\n⚠️  Found {len(misplaced_files)} misplaced files!")

    # Match files
    print("\n🔍 Matching files by title...")
    matches = match_files(ali_files, chris_files)
    print(f"   Found {len(matches)} unique titles")

    # Compare files
    print("\n⚖️  Comparing quality (using Project Mother scoring)...")
    all_results = []
    for title, (ali_set, chris_set) in matches.items():
        results = compare_file_sets(ali_set, chris_set)
        all_results.extend(results)

    # Generate reports
    print("\n📝 Generating reports...")
    args.output_dir.mkdir(parents=True, exist_ok=True)
    stats = generate_reports(all_results, misplaced_files, args.output_dir)

    # Print summary
    print("\n" + "="*60)
    print("COMPARISON COMPLETE")
    print("="*60)
    print(f"Total comparisons: {stats['total']}")
    print(f"Copy Ali → Chris: {stats['ali_only']}")
    print(f"Copy Chris → Ali: {stats['chris_only']}")
    print(f"Replace Chris's (Ali better): {stats['ali_better']}")
    print(f"Replace Ali's (Chris better): {stats['chris_better']}")
    print(f"No action (equal): {stats['tie']}")
    print(f"Misplaced files: {stats['misplaced']}")
    print("="*60)

if __name__ == '__main__':
    main()
