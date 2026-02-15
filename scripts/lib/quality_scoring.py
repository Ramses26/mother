#!/usr/bin/env python3
"""
Shared Quality Scoring Module - Project Mother

Centralized quality scoring aligned with Recyclarr/TRaSH Guides.
Used by compare_libraries.py, compare_tv_libraries.py, and cleanup_duplicates.py.

Key principles:
- 720p scores 0 (Huntarr will upgrade these)
- x265 without HDR/DV is penalized at 1080p (recyclarr blocks these)
- x265 WITH DV HDR10 remains preferred
- For TV: WEB-DL preferred over BluRay (except Remux)
- Audio trumps HDR at 1080p
"""

import re
from typing import Dict, Tuple

###############################################################################
# Score Dictionaries
###############################################################################

RESOLUTION_SCORES = {
    '2160p': 4000,
    '1080p': 2000,
    '720p': 0,
    '480p': -500,
    'Unknown': 0,
}

# Movie source scores (BluRay > WEB-DL)
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

# TV source scores (WEB-DL > BluRay per recyclarr config)
TV_SOURCE_SCORES = {
    'Remux': 2000,
    'WEB-DL': 1200,
    'WEBDL': 1200,
    'Bluray': 1000,
    'BluRay': 1000,
    'WEBRip': 800,
    'HDTV': 200,
    'DVDRip': 100,
    'Unknown': 0,
}

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

CODEC_SCORES = {
    'AV1': 250,
    'HEVC': 100,
    'H.265': 100,
    'x265': 100,
    'AVC': 150,
    'H.264': 150,
    'x264': 150,
    'VC1': 100,
    'VC-1': 100,
    'Unknown': 0,
    '': 0,
}


###############################################################################
# Scoring Function
###############################################################################

def calculate_quality_score(resolution: str, source: str, hdr: str,
                            audio: str, codec: str, size_gb: float,
                            is_4k: bool = False, media_type: str = 'movie') -> int:
    """
    Calculate overall quality score for a media file.

    Args:
        resolution: e.g. '1080p', '2160p', '720p'
        source: e.g. 'BluRay', 'WEB-DL', 'Remux'
        hdr: e.g. 'DV HDR10', 'HDR10', '' for none
        audio: e.g. 'TrueHD Atmos', 'DTS-HD MA', 'EAC3'
        codec: e.g. 'HEVC', 'AVC', 'x265'
        size_gb: File size in GB
        is_4k: Whether this is a 4K library file
        media_type: 'movie' or 'tv' (affects source scoring)

    Returns:
        Integer quality score (higher = better)
    """
    score = 0

    is_x265 = codec in ('HEVC', 'H.265', 'x265')
    has_hdr = hdr and hdr not in ('', 'None', 'SDR')
    has_dv = hdr and 'DV' in hdr

    # Resolution
    score += RESOLUTION_SCORES.get(resolution, 0)

    # Source (TV uses different scoring: WEB-DL > BluRay)
    if media_type == 'tv':
        score += TV_SOURCE_SCORES.get(source, 0)
    else:
        score += SOURCE_SCORES.get(source, 0)

    # HDR (different scoring for 4K vs 1080p)
    if is_4k:
        score += HDR_SCORES_4K.get(hdr, 0)
    else:
        score += HDR_SCORES_1080P.get(hdr, 0)

    # Audio
    score += AUDIO_SCORES.get(audio, 0)

    # Codec
    score += CODEC_SCORES.get(codec, 0)

    # x265 bonus/penalty based on HDR status (recyclarr alignment)
    if is_x265 and not is_4k:
        if has_dv:
            score += 200  # Bonus for DV + x265 efficiency
        elif has_hdr:
            score += 0    # Neutral
        else:
            score -= 300  # x265 without HDR at 1080p = BAD

    # File size bonus (larger generally better for same quality)
    score += min(int(size_gb * 10), 200)

    return score


###############################################################################
# Filename Parsing
###############################################################################

def parse_quality_from_filename(filename: str) -> Dict[str, str]:
    """
    Parse TRaSH-format filename for quality attributes.

    Example: Avatar (2009) {tmdb-19995} - [Bluray-1080p][DTS-HD MA 5.1][HDR][x265]-FraMeSToR.mkv

    Returns dict with keys: resolution, source, hdr, audio, codec, release_group
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
        res_match = re.search(
            r'(Remux|Bluray|WEBDL|WEB-DL|WEBRip|HDTV)[- ]?(2160p|1080p|720p|480p)',
            content, re.IGNORECASE
        )
        if res_match:
            result['source'] = res_match.group(1)
            result['resolution'] = res_match.group(2)
            continue

        # Just resolution
        if content in ('2160p', '1080p', '720p', '480p'):
            result['resolution'] = content
            continue

        # HDR formats (order matters - check most specific first)
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
        if content_upper in ('DV', 'DOLBY VISION', 'DOVI'):
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
        if content_upper in ('HEVC', 'H.265', 'X265', 'H265'):
            result['codec'] = 'HEVC'
            continue
        if content_upper in ('AVC', 'H.264', 'X264', 'H264'):
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


def parse_episode_info(filename: str) -> Tuple[int, int, int]:
    """
    Parse season/episode info from filename, including multi-episode ranges.

    Examples:
        S01E01 -> (1, 1, 1)
        S01E01-E02 -> (1, 1, 2)
        S01E01E02 -> (1, 1, 2)
        S10E15-E16 -> (10, 15, 16)

    Returns:
        (season, first_episode, last_episode)
        Returns (-1, -1, -1) if no match found.
    """
    # Multi-episode: S01E01-E02 or S01E01E02
    multi_match = re.search(
        r'S(\d{1,4})E(\d{1,3})(?:-?E(\d{1,3}))?',
        filename, re.IGNORECASE
    )
    if multi_match:
        season = int(multi_match.group(1))
        first_ep = int(multi_match.group(2))
        last_ep = int(multi_match.group(3)) if multi_match.group(3) else first_ep
        return season, first_ep, last_ep

    return -1, -1, -1
