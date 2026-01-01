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

# Mother's mount paths (rsync runs FROM Mother)
# Synology (Chris) - mounted on Mother via NFS
SYNOLOGY_PATHS = {
    'movies_1080p': '/mnt/synology/rs-movies',
    'movies_4k': '/mnt/synology/rs-4kmedia/4kmovies',
    'tv_1080p': '/mnt/synology/rs-tv',
    'tv_4k': '/mnt/synology/rs-4kmedia/4ktv',
    'downloads': '/mnt/synology/rs-4kmedia/downloads',
    'deleted': '/mnt/synology/rs-4kmedia/deleted',
    'deleted_movies': '/mnt/synology/rs-4kmedia/deleted/Movies',
    'deleted_4k_movies': '/mnt/synology/rs-4kmedia/deleted/4K Movies',
    'deleted_tv': '/mnt/synology/rs-4kmedia/deleted/TV Shows',
    'deleted_4k_tv': '/mnt/synology/rs-4kmedia/deleted/4K TV Shows',
}

# Unraid (Ali) - mounted on Mother via NFS over VPN
UNRAID_PATHS = {
    'movies_1080p': '/mnt/unraid/media/Movies',
    'movies_4k': '/mnt/unraid/media/4K Movies',
    'tv_1080p': '/mnt/unraid/media/TV Shows',
    'tv_4k': '/mnt/unraid/media/4K TV Shows',
    'deleted_movies': '/mnt/unraid/media/Deleted Movies',
    'deleted_4k_movies': '/mnt/unraid/media/Deleted Movies',  # Same folder for 4K
    'deleted_tv': '/mnt/unraid/media/Deleted TV',
    'deleted_4k_tv': '/mnt/unraid/media/Deleted TV',  # Same folder for 4K
}

# Path translations: Inventory paths → Mother mount paths
# Inventories are generated on Terminus (for Unraid) and Mother (for Synology)
PATH_TRANSLATIONS = [
    # Terminus inventory paths → Mother mount paths (Unraid)
    ('/mnt/media/4K Movies', '/mnt/unraid/media/4K Movies'),
    ('/mnt/media/4K TV Shows', '/mnt/unraid/media/4K TV Shows'),
    ('/mnt/media/Movies', '/mnt/unraid/media/Movies'),
    ('/mnt/media/TV Shows', '/mnt/unraid/media/TV Shows'),
    ('/mnt/media/Deleted', '/mnt/unraid/media/Deleted'),
    # Mother inventory paths are already correct (Synology)
    # '/mnt/synology/...' stays as-is
]

# Fan-made/custom media to exclude from comparison reports
# These won't have TMDB IDs and shouldn't be flagged as "missing"
EXCLUDED_TITLES = [
    # Fan edits
    'Despecialized Edition',
    'Sacred Timeline Cut',
    'Infinity Saga',
    # Concerts/live performances
    'Live in New York',
    'Live at',
    'Concert',
    # Extended versions split into parts
    'Extended Version.*Chapter',
    'Extended Version.*part',
]

# Files to completely skip during comparison (by partial path match)
EXCLUDED_PATHS = [
    'Despecialized Edition',
    'Sacred Timeline Cut',
    'Infinity Saga',
    'Adele Live in New York',
    'Hateful Eight, The - Extended Version',
]

def is_excluded(file_path: str, title: str) -> bool:
    """Check if a file should be excluded from comparison (fan edits, concerts, etc.)"""
    for pattern in EXCLUDED_PATHS:
        if pattern.lower() in file_path.lower():
            return True
    for pattern in EXCLUDED_TITLES:
        if re.search(pattern, title, re.IGNORECASE):
            return True
    return False

def translate_path_to_mother(path: str) -> str:
    """Translate inventory path to Mother's mount path for rsync"""
    for old_prefix, new_prefix in PATH_TRANSLATIONS:
        if path.startswith(old_prefix):
            return path.replace(old_prefix, new_prefix, 1)
    return path  # Already a Mother path (Synology)

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
    tmdb_id: str = ''  # TMDB ID extracted from filename (e.g., "530915")
    imdb_id: str = ''  # IMDB ID if available
    year: str = ''     # Year from title/filename

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
    match_type: str = ''  # 'tmdb', 'imdb', 'title_year', 'unmatched'

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

def extract_ids_from_filename(filename: str) -> Tuple[str, str, str]:
    """
    Extract TMDB ID, IMDB ID, and year from filename.

    TRaSH naming format examples:
        Movie (2019) {tmdb-530915} - [Bluray-1080p]...
        Movie (2019) {imdb-tt1234567} - [Bluray-1080p]...
        Movie (2019) {tmdb-530915} {imdb-tt1234567} - [Bluray-1080p]...

    Returns:
        Tuple of (tmdb_id, imdb_id, year)
    """
    tmdb_id = ''
    imdb_id = ''
    year = ''

    # Extract TMDB ID: {tmdb-123456}
    tmdb_match = re.search(r'\{tmdb-(\d+)\}', filename, re.IGNORECASE)
    if tmdb_match:
        tmdb_id = tmdb_match.group(1)

    # Extract IMDB ID: {imdb-tt1234567}
    imdb_match = re.search(r'\{imdb-(tt\d+)\}', filename, re.IGNORECASE)
    if imdb_match:
        imdb_id = imdb_match.group(1)

    # Extract year: (2019) or (1976)
    year_match = re.search(r'\((\d{4})\)', filename)
    if year_match:
        year = year_match.group(1)

    return tmdb_id, imdb_id, year


def parse_inventory_file(file_entry: Dict) -> MediaFile:
    """Convert inventory entry to MediaFile with parsed quality info"""
    path = file_entry.get('path', '')
    filename = file_entry.get('filename', '')

    # Parse filename for quality attributes
    parsed = parse_trash_filename(filename)

    # Extract TMDB/IMDB IDs and year from filename
    tmdb_id, imdb_id, year = extract_ids_from_filename(filename)

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
        tmdb_id=tmdb_id,
        imdb_id=imdb_id,
        year=year,
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

def get_match_key(media_file: MediaFile) -> Tuple[str, str]:
    """
    Get the best match key for a file.

    Priority:
    1. TMDB ID (most reliable)
    2. IMDB ID (also reliable)
    3. Normalized title + year (fallback, less reliable)

    Returns:
        Tuple of (key_type, key_value)
        key_type: 'tmdb', 'imdb', 'title', or 'title_no_year'
    """
    if media_file.tmdb_id:
        return ('tmdb', f'tmdb-{media_file.tmdb_id}')
    elif media_file.imdb_id:
        return ('imdb', f'imdb-{media_file.imdb_id}')
    elif media_file.year:
        # Title + year is reasonably unique
        normalized = normalize_title(media_file.title)
        return ('title', f'{normalized}_{media_file.year}')
    else:
        # No year - high risk of mismatch
        normalized = normalize_title(media_file.title)
        return ('title_no_year', normalized)


def match_files(ali_files: List[MediaFile], chris_files: List[MediaFile]) -> Dict[str, Tuple[List[MediaFile], List[MediaFile], str]]:
    """
    Match files between two inventories.

    Priority: TMDB ID > IMDB ID > Title+Year > Title only

    Returns:
        Dict mapping match_key to (ali_files, chris_files, match_type)
        match_type indicates how the match was made
    """
    matches = defaultdict(lambda: ([], [], ''))

    # Build indices for Ali's files
    ali_by_tmdb = defaultdict(list)
    ali_by_imdb = defaultdict(list)
    ali_by_title_year = defaultdict(list)
    ali_by_title = defaultdict(list)

    for f in ali_files:
        if f.tmdb_id:
            ali_by_tmdb[f.tmdb_id].append(f)
        if f.imdb_id:
            ali_by_imdb[f.imdb_id].append(f)
        normalized = normalize_title(f.title)
        if f.year:
            ali_by_title_year[f'{normalized}_{f.year}'].append(f)
        ali_by_title[normalized].append(f)

    # Build indices for Chris's files
    chris_by_tmdb = defaultdict(list)
    chris_by_imdb = defaultdict(list)
    chris_by_title_year = defaultdict(list)
    chris_by_title = defaultdict(list)

    for f in chris_files:
        if f.tmdb_id:
            chris_by_tmdb[f.tmdb_id].append(f)
        if f.imdb_id:
            chris_by_imdb[f.imdb_id].append(f)
        normalized = normalize_title(f.title)
        if f.year:
            chris_by_title_year[f'{normalized}_{f.year}'].append(f)
        chris_by_title[normalized].append(f)

    # Track which files have been matched
    ali_matched = set()
    chris_matched = set()

    # Pass 1: Match by TMDB ID (most reliable)
    all_tmdb_ids = set(ali_by_tmdb.keys()) | set(chris_by_tmdb.keys())
    for tmdb_id in all_tmdb_ids:
        key = f'tmdb-{tmdb_id}'
        ali_set = ali_by_tmdb.get(tmdb_id, [])
        chris_set = chris_by_tmdb.get(tmdb_id, [])
        matches[key] = (ali_set, chris_set, 'tmdb')
        for f in ali_set:
            ali_matched.add(id(f))
        for f in chris_set:
            chris_matched.add(id(f))

    # Pass 2: Match remaining by IMDB ID
    for imdb_id in set(ali_by_imdb.keys()) | set(chris_by_imdb.keys()):
        ali_set = [f for f in ali_by_imdb.get(imdb_id, []) if id(f) not in ali_matched]
        chris_set = [f for f in chris_by_imdb.get(imdb_id, []) if id(f) not in chris_matched]
        if ali_set or chris_set:
            key = f'imdb-{imdb_id}'
            matches[key] = (ali_set, chris_set, 'imdb')
            for f in ali_set:
                ali_matched.add(id(f))
            for f in chris_set:
                chris_matched.add(id(f))

    # Pass 3: Match remaining by Title + Year
    for title_year in set(ali_by_title_year.keys()) | set(chris_by_title_year.keys()):
        ali_set = [f for f in ali_by_title_year.get(title_year, []) if id(f) not in ali_matched]
        chris_set = [f for f in chris_by_title_year.get(title_year, []) if id(f) not in chris_matched]
        if ali_set or chris_set:
            key = f'title-{title_year}'
            matches[key] = (ali_set, chris_set, 'title_year')
            for f in ali_set:
                ali_matched.add(id(f))
            for f in chris_set:
                chris_matched.add(id(f))

    # Pass 4: Remaining files with no match (only one side has them)
    # These are unique to one library - DON'T match by title alone (too risky)
    for f in ali_files:
        if id(f) not in ali_matched:
            key = f'ali_only_{id(f)}'
            matches[key] = ([f], [], 'unmatched')

    for f in chris_files:
        if id(f) not in chris_matched:
            key = f'chris_only_{id(f)}'
            matches[key] = ([], [f], 'unmatched')

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

    # Find files missing TMDB ID (need renaming)
    files_missing_tmdb = []
    for r in all_results:
        if r.ali_file and not r.ali_file.tmdb_id:
            files_missing_tmdb.append(('Ali', r.ali_file))
        if r.chris_file and not r.chris_file.tmdb_id:
            files_missing_tmdb.append(('Chris', r.chris_file))

    # Statistics
    stats = {
        'total': len(all_results),
        'ali_only': len([r for r in all_results if r.winner == 'ali' and not r.chris_file]),
        'chris_only': len([r for r in all_results if r.winner == 'chris' and not r.ali_file]),
        'ali_better': len([r for r in all_results if r.winner == 'ali' and r.chris_file]),
        'chris_better': len([r for r in all_results if r.winner == 'chris' and r.ali_file]),
        'tie': len([r for r in all_results if r.winner == 'tie']),
        'misplaced': len(misplaced_files),
        'missing_tmdb': len(files_missing_tmdb),
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
        f.write(f"Misplaced files (wrong library): {stats['misplaced']}\n")
        f.write(f"Files missing TMDB ID: {stats['missing_tmdb']}\n\n")

        # Misplaced files warning
        if misplaced_files:
            f.write("="*100 + "\n")
            f.write("⚠️  MISPLACED FILES (WRONG LIBRARY)\n")
            f.write("="*100 + "\n\n")
            for mf in misplaced_files:
                f.write(f"  {mf.filename}\n")
                f.write(f"    Path: {mf.path}\n")
                f.write(f"    Warning: {mf.placement_warning}\n\n")

        # Files missing TMDB ID (need renaming)
        if files_missing_tmdb:
            f.write("="*100 + "\n")
            f.write("⚠️  FILES MISSING TMDB ID (NEED RENAMING)\n")
            f.write("="*100 + "\n")
            f.write("These files don't follow TRaSH naming format.\n")
            f.write("Rename to: Movie (Year) {tmdb-XXXXX} - [Quality][Audio][HDR][Codec]-Group.mkv\n")
            f.write("Use Radarr/Sonarr to rename, or FileBot with TMDB lookup.\n\n")

            ali_missing = [(o, f) for o, f in files_missing_tmdb if o == 'Ali']
            chris_missing = [(o, f) for o, f in files_missing_tmdb if o == 'Chris']

            if ali_missing:
                f.write(f"Ali's files missing TMDB ID ({len(ali_missing)}):\n")
                for _, mf in ali_missing[:50]:  # Limit to 50
                    f.write(f"  - {mf.filename}\n")
                    f.write(f"    Path: {mf.path}\n")
                if len(ali_missing) > 50:
                    f.write(f"  ... and {len(ali_missing) - 50} more\n")
                f.write("\n")

            if chris_missing:
                f.write(f"Chris's files missing TMDB ID ({len(chris_missing)}):\n")
                for _, mf in chris_missing[:50]:  # Limit to 50
                    f.write(f"  - {mf.filename}\n")
                    f.write(f"    Path: {mf.path}\n")
                if len(chris_missing) > 50:
                    f.write(f"  ... and {len(chris_missing) - 50} more\n")
                f.write("\n")

        # Files to sync
        f.write("="*100 + "\n")
        f.write("SYNC ACTIONS\n")
        f.write("="*100 + "\n\n")

        for result in all_results:
            if result.winner == 'tie':
                continue

            title = result.ali_file.title if result.ali_file else result.chris_file.title
            f.write(f"Title: {title}\n")

            # Show match type and IDs
            match_type_label = {
                'tmdb': 'TMDB ID (reliable)',
                'imdb': 'IMDB ID (reliable)',
                'title_year': 'Title+Year (verify manually)',
                'unmatched': 'Unique (no match found)'
            }.get(result.match_type, result.match_type)
            f.write(f"  Match: {match_type_label}\n")

            if result.ali_file:
                tmdb_info = f" [TMDB:{result.ali_file.tmdb_id}]" if result.ali_file.tmdb_id else ""
                f.write(f"  Ali: {result.ali_file.filename} (Score: {result.ali_score}){tmdb_info}\n")
                f.write(f"       [{result.ali_file.resolution}][{result.ali_file.source}][{result.ali_file.audio}][{result.ali_file.hdr}][{result.ali_file.codec}]\n")
            else:
                f.write(f"  Ali: (none)\n")

            if result.chris_file:
                tmdb_info = f" [TMDB:{result.chris_file.tmdb_id}]" if result.chris_file.tmdb_id else ""
                f.write(f"  Chris: {result.chris_file.filename} (Score: {result.chris_score}){tmdb_info}\n")
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

    # Generate sync script with progress tracking and error handling
    script_file = output_dir / f'sync_actions_{timestamp}.sh'
    progress_file = f"sync_progress_{timestamp}.log"
    error_log = f"sync_errors_{timestamp}.log"

    with open(script_file, 'w', encoding='utf-8') as f:
        f.write("#!/bin/bash\n")
        f.write("#" + "="*78 + "\n")
        f.write("# Project Mother Sync Script\n")
        f.write("# RUN THIS ON MOTHER (10.0.0.162)\n")
        f.write("#" + "="*78 + "\n")
        f.write(f"# Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write("#\n")
        f.write("# Features:\n")
        f.write("#   - Progress tracking: completed commands are logged and skipped on re-run\n")
        f.write("#   - Error handling: failures logged with exit code, script continues\n")
        f.write("#   - Set EXIT_ON_ERROR=true to stop on first error\n")
        f.write("#   - Timestamps in log for monitoring with: tail -f <logfile>\n")
        f.write("#\n")
        f.write("# This script uses Mother's mount paths:\n")
        f.write("#   Synology: /mnt/synology/rs-*\n")
        f.write("#   Unraid:   /mnt/unraid/media/*\n")
        f.write("#\n")
        f.write("# Usage:\n")
        f.write("#   ./sync_actions_XXXXX.sh                    # Normal run (4 parallel)\n")
        f.write("#   PARALLEL=8 ./sync_actions_XXXXX.sh         # 8 parallel transfers\n")
        f.write("#   PARALLEL=1 ./sync_actions_XXXXX.sh         # Sequential (safe)\n")
        f.write("#   EXIT_ON_ERROR=true ./sync_actions_XXXXX.sh # Stop on first error\n")
        f.write("#   DRY_RUN=true ./sync_actions_XXXXX.sh       # Preview only\n")
        f.write("#\n")
        f.write("# Bandwidth: 4 parallel = ~400 Mbps, 8 parallel = ~800 Mbps\n")
        f.write("#\n")
        f.write("#" + "="*78 + "\n\n")

        f.write("set -o pipefail\n\n")

        f.write(f'PROGRESS_FILE="${{PROGRESS_FILE:-{progress_file}}}"\n')
        f.write(f'ERROR_LOG="${{ERROR_LOG:-{error_log}}}"\n')
        f.write('EXIT_ON_ERROR="${EXIT_ON_ERROR:-false}"\n')
        f.write('DRY_RUN="${DRY_RUN:-false}"\n')
        f.write('PARALLEL="${PARALLEL:-4}"  # Number of parallel transfers\n\n')

        f.write('# Colors for output\n')
        f.write('RED="\\033[0;31m"\n')
        f.write('GREEN="\\033[0;32m"\n')
        f.write('YELLOW="\\033[0;33m"\n')
        f.write('BLUE="\\033[0;34m"\n')
        f.write('NC="\\033[0m" # No Color\n\n')

        f.write('# Statistics\n')
        f.write('TOTAL=0\n')
        f.write('COMPLETED=0\n')
        f.write('SKIPPED=0\n')
        f.write('FAILED=0\n\n')

        f.write('log() {\n')
        f.write('    echo -e "[$(date "+%Y-%m-%d %H:%M:%S")] $1"\n')
        f.write('}\n\n')

        f.write('log_error() {\n')
        f.write('    echo -e "[$(date "+%Y-%m-%d %H:%M:%S")] ${RED}ERROR${NC}: $1" | tee -a "$ERROR_LOG"\n')
        f.write('}\n\n')

        f.write('# Check if command was already completed\n')
        f.write('is_completed() {\n')
        f.write('    local hash="$1"\n')
        f.write('    grep -q "^$hash$" "$PROGRESS_FILE" 2>/dev/null\n')
        f.write('}\n\n')

        f.write('# Mark command as completed\n')
        f.write('mark_completed() {\n')
        f.write('    local hash="$1"\n')
        f.write('    echo "$hash" >> "$PROGRESS_FILE"\n')
        f.write('}\n\n')

        f.write('# Semaphore for parallel execution\n')
        f.write('wait_for_slot() {\n')
        f.write('    while [ $(jobs -r | wc -l) -ge $PARALLEL ]; do\n')
        f.write('        sleep 0.5\n')
        f.write('    done\n')
        f.write('}\n\n')

        f.write('# Execute command with progress tracking\n')
        f.write('run_cmd() {\n')
        f.write('    local desc="$1"\n')
        f.write('    shift\n')
        f.write('    local hash\n')
        f.write('    hash=$(echo "$@" | md5sum | cut -d" " -f1)\n')
        f.write('    \n')
        f.write('    ((TOTAL++))\n')
        f.write('    \n')
        f.write('    if is_completed "$hash"; then\n')
        f.write('        log "${YELLOW}SKIP${NC} [already done] $desc"\n')
        f.write('        ((SKIPPED++))\n')
        f.write('        return 0\n')
        f.write('    fi\n')
        f.write('    \n')
        f.write('    if [ "$DRY_RUN" = "true" ]; then\n')
        f.write('        log "${BLUE}[DRY RUN]${NC} $desc"\n')
        f.write('        log "  Command: $@"\n')
        f.write('        ((COMPLETED++))\n')
        f.write('        return 0\n')
        f.write('    fi\n')
        f.write('    \n')
        f.write('    # Wait for a slot if running parallel\n')
        f.write('    if [ "$PARALLEL" -gt 1 ]; then\n')
        f.write('        wait_for_slot\n')
        f.write('    fi\n')
        f.write('    \n')
        f.write('    log "RUNNING: $desc"\n')
        f.write('    \n')
        f.write('    # Run in background if parallel > 1\n')
        f.write('    if [ "$PARALLEL" -gt 1 ]; then\n')
        f.write('        (\n')
        f.write('            if "$@" 2>&1; then\n')
        f.write('                mark_completed "$hash"\n')
        f.write('                log "${GREEN}OK${NC}: $desc"\n')
        f.write('            else\n')
        f.write('                log_error "Failed: $desc"\n')
        f.write('            fi\n')
        f.write('        ) &\n')
        f.write('    else\n')
        f.write('        if "$@"; then\n')
        f.write('            mark_completed "$hash"\n')
        f.write('            log "${GREEN}OK${NC}: $desc"\n')
        f.write('            ((COMPLETED++))\n')
        f.write('        else\n')
        f.write('            local exit_code=$?\n')
        f.write('            log_error "Failed (exit $exit_code): $desc"\n')
        f.write('            log_error "  Command: $@"\n')
        f.write('            ((FAILED++))\n')
        f.write('            \n')
        f.write('            if [ "$EXIT_ON_ERROR" = "true" ]; then\n')
        f.write('                log "${RED}Stopping due to EXIT_ON_ERROR=true${NC}"\n')
        f.write('                print_summary\n')
        f.write('                exit $exit_code\n')
        f.write('            fi\n')
        f.write('        fi\n')
        f.write('    fi\n')
        f.write('}\n\n')

        f.write('# Print summary\n')
        f.write('print_summary() {\n')
        f.write('    echo ""\n')
        f.write('    echo "========================================"\n')
        f.write('    echo "SYNC SUMMARY"\n')
        f.write('    echo "========================================"\n')
        f.write('    echo "Total:     $TOTAL"\n')
        f.write('    echo -e "Completed: ${GREEN}$COMPLETED${NC}"\n')
        f.write('    echo -e "Skipped:   ${YELLOW}$SKIPPED${NC}"\n')
        f.write('    echo -e "Failed:    ${RED}$FAILED${NC}"\n')
        f.write('    echo "========================================"\n')
        f.write('    if [ $FAILED -gt 0 ]; then\n')
        f.write('        echo "See $ERROR_LOG for failure details"\n')
        f.write('    fi\n')
        f.write('}\n\n')

        f.write('trap print_summary EXIT\n\n')

        f.write('log "Starting sync..."\n')
        f.write('log "Progress file: $PROGRESS_FILE"\n')
        f.write('log "Error log: $ERROR_LOG"\n')
        f.write('if [ "$DRY_RUN" = "true" ]; then\n')
        f.write('    log "${BLUE}DRY RUN MODE - no changes will be made${NC}"\n')
        f.write('fi\n')
        f.write('echo ""\n\n')

        # Moves to deleted folders
        f.write("# === MOVE TO DELETED FOLDERS ===\n\n")
        for result in all_results:
            if result.deleted_path and result.winner != 'tie':
                if result.winner == 'ali' and result.chris_file:
                    src = translate_path_to_mother(result.chris_file.path)
                    deleted = translate_path_to_mother(result.deleted_path)
                    title = result.chris_file.title.replace('"', '\\"')
                    f.write(f'run_cmd "Move Chris lower quality: {title}" mv "{src}" "{deleted}/"\n\n')
                elif result.winner == 'chris' and result.ali_file:
                    src = translate_path_to_mother(result.ali_file.path)
                    deleted = translate_path_to_mother(result.deleted_path)
                    title = result.ali_file.title.replace('"', '\\"')
                    f.write(f'run_cmd "Move Ali lower quality: {title}" mv "{src}" "{deleted}/"\n\n')

        # Copies - Ali's files go to Synology, Chris's files go to Unraid
        # All paths translated to Mother's mount points
        # NOTE: For movies, we copy the movie folder to preserve structure
        # For TV, we create the show/season folder structure then copy
        f.write("\n# === COPY BETTER QUALITY FILES ===\n\n")
        for result in all_results:
            if result.winner == 'ali' and result.ali_file:
                # Ali has better version - copy from Unraid to Synology
                src_file = translate_path_to_mother(result.ali_file.path)
                lib_type = result.ali_file.library_type or ''
                is_tv = 'tv' in lib_type.lower() or 'TV Shows' in src_file

                if '4k' in lib_type.lower() or '4k' in src_file.lower():
                    if is_tv:
                        dest = SYNOLOGY_PATHS['tv_4k']
                    else:
                        dest = SYNOLOGY_PATHS['movies_4k']
                else:
                    if is_tv:
                        dest = SYNOLOGY_PATHS['tv_1080p']
                    else:
                        dest = SYNOLOGY_PATHS['movies_1080p']

                title = result.ali_file.title.replace('"', '\\"')

                if is_tv:
                    # TV: Create show/season folder structure, then copy file
                    src_path = Path(src_file)
                    # Get relative path from library root (Show/Season/file.mkv)
                    # Find the TV library root in the path
                    parts = src_path.parts
                    for i, part in enumerate(parts):
                        if 'TV' in part and 'Shows' in part or '4K TV' in part:
                            rel_parts = parts[i+1:]  # Everything after "TV Shows" or "4K TV Shows"
                            break
                    else:
                        rel_parts = parts[-3:]  # Fallback: Show/Season/file

                    dest_dir = Path(dest) / '/'.join(rel_parts[:-1])  # Show/Season
                    f.write(f'run_cmd "Create dir for: {title}" mkdir -p "{dest_dir}"\n')
                    f.write(f'run_cmd "Copy Ali->Chris: {title}" rsync -avhP "{src_file}" "{dest_dir}/"\n\n')
                else:
                    # Movies: Copy the entire movie folder to preserve structure
                    src_folder = str(Path(src_file).parent)
                    f.write(f'run_cmd "Copy Ali->Chris: {title}" rsync -avhP "{src_folder}" "{dest}/"\n\n')

            elif result.winner == 'chris' and result.chris_file:
                # Chris has better version - copy from Synology to Unraid
                src_file = translate_path_to_mother(result.chris_file.path)
                lib_type = result.chris_file.library_type or ''
                is_tv = 'tv' in lib_type.lower() or 'rs-tv' in src_file

                if '4k' in lib_type.lower() or '4k' in src_file.lower():
                    if is_tv:
                        dest = UNRAID_PATHS['tv_4k']
                    else:
                        dest = UNRAID_PATHS['movies_4k']
                else:
                    if is_tv:
                        dest = UNRAID_PATHS['tv_1080p']
                    else:
                        dest = UNRAID_PATHS['movies_1080p']

                title = result.chris_file.title.replace('"', '\\"')

                if is_tv:
                    # TV: Create show/season folder structure, then copy file
                    src_path = Path(src_file)
                    # Get relative path from library root (Show/Season/file.mkv)
                    parts = src_path.parts
                    for i, part in enumerate(parts):
                        if 'rs-tv' in part or '4ktv' in part.lower():
                            rel_parts = parts[i+1:]  # Everything after library root
                            break
                    else:
                        rel_parts = parts[-3:]  # Fallback: Show/Season/file

                    dest_dir = Path(dest) / '/'.join(rel_parts[:-1])  # Show/Season
                    f.write(f'run_cmd "Create dir for: {title}" mkdir -p "{dest_dir}"\n')
                    f.write(f'run_cmd "Copy Chris->Ali: {title}" rsync -avhP "{src_file}" "{dest_dir}/"\n\n')
                else:
                    # Movies: Copy the entire movie folder to preserve structure
                    src_folder = str(Path(src_file).parent)
                    f.write(f'run_cmd "Copy Chris->Ali: {title}" rsync -avhP "{src_folder}" "{dest}/"\n\n')

        # Wait for all parallel jobs to complete
        f.write('\n# Wait for all parallel jobs to complete\n')
        f.write('if [ "$PARALLEL" -gt 1 ]; then\n')
        f.write('    log "Waiting for parallel transfers to complete..."\n')
        f.write('    wait\n')
        f.write('fi\n')
        f.write('\nlog "Sync complete!"\n')

    # Make script executable
    script_file.chmod(0o755)

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
    ali_files_all = [parse_inventory_file(entry) for entry in ali_raw]
    # Filter out excluded fan edits, concerts, etc.
    ali_files = [f for f in ali_files_all if not is_excluded(f.path, f.title)]
    ali_excluded = len(ali_files_all) - len(ali_files)
    print(f"   Parsed {len(ali_files)} files ({ali_excluded} excluded fan edits/concerts)")

    print(f"📖 Loading Chris's inventory: {args.chris_inventory}")
    with open(args.chris_inventory, 'r', encoding='utf-8') as f:
        chris_raw = json.load(f)
    chris_files_all = [parse_inventory_file(entry) for entry in chris_raw]
    # Filter out excluded fan edits, concerts, etc.
    chris_files = [f for f in chris_files_all if not is_excluded(f.path, f.title)]
    chris_excluded = len(chris_files_all) - len(chris_files)
    print(f"   Parsed {len(chris_files)} files ({chris_excluded} excluded fan edits/concerts)")

    # Find misplaced files
    misplaced_files = [f for f in ali_files + chris_files if not f.is_valid_placement]
    if misplaced_files:
        print(f"\n⚠️  Found {len(misplaced_files)} misplaced files!")

    # Match files
    print("\n🔍 Matching files...")
    matches = match_files(ali_files, chris_files)

    # Count match types
    match_stats = {'tmdb': 0, 'imdb': 0, 'title_year': 0, 'unmatched': 0}
    for key, (ali_set, chris_set, match_type) in matches.items():
        match_stats[match_type] = match_stats.get(match_type, 0) + 1

    print(f"   Total matches: {len(matches)}")
    print(f"   By TMDB ID:    {match_stats.get('tmdb', 0)} (reliable)")
    print(f"   By IMDB ID:    {match_stats.get('imdb', 0)} (reliable)")
    print(f"   By Title+Year: {match_stats.get('title_year', 0)} (less reliable)")
    print(f"   Unmatched:     {match_stats.get('unmatched', 0)} (unique to one library)")

    # Compare files
    print("\n⚖️  Comparing quality (using Project Mother scoring)...")
    all_results = []
    for key, (ali_set, chris_set, match_type) in matches.items():
        results = compare_file_sets(ali_set, chris_set)
        # Add match_type to results for reporting
        for r in results:
            r.match_type = match_type
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
