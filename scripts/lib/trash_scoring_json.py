#!/usr/bin/env python3
"""
Shared Quality Scoring Module (JSON-backed) - Project Mother

Used by services/upgraderr/app.py. Reads point values from the same
configs/scoring/trash_scoring.json used by sync-webhook and curatorr, instead of
the private point tables in scripts/lib/quality_scoring.py (which is still used by
compare_libraries.py, compare_tv_libraries.py, and cleanup_duplicates.py — not
this module's concern, and not to be modified).

parse_quality_from_filename() intentionally ports scripts/lib/quality_scoring.py's
bracket-scoped parsing algorithm verbatim (same regexes, same branch order, same
output labels) rather than reimplementing sync-webhook's whole-string-regex
approach — the two algorithms can disagree on edge cases, and Upgraderr's Tier 3/5
logic reads these parsed fields directly, not just the aggregate score.

calculate_quality_score() looks up points via label -> JSON-key translation tables,
not by scanning the JSON's ordered audio/hdr lists against raw filename text. This
matters: the JSON's audio table has a `eac3 atmos` (300) entry that would wrongly
outrank the generic `atmos` (500) entry if matched against raw text, but the old
module's parser (ported below) always normalizes EAC3-Atmos content to the label
'Atmos', not a separate label — so scoring must key off that already-normalized
label, not re-scan the source text.
"""

import json
import os
import re
from pathlib import Path
from typing import Dict

###############################################################################
# JSON loading
###############################################################################

_DEFAULT_CANDIDATES = [
    os.environ.get('TRASH_SCORING_PATH'),
    '/app/scoring/trash_scoring.json',
    str(Path(__file__).resolve().parent.parent.parent / 'configs' / 'scoring' / 'trash_scoring.json'),
]


def _load_scoring_config(path=None):
    candidates = [path] if path else [c for c in _DEFAULT_CANDIDATES if c]
    for candidate in candidates:
        if candidate and os.path.isfile(candidate):
            with open(candidate) as f:
                return json.load(f)
    raise FileNotFoundError(f"trash_scoring.json not found; tried: {candidates}")


_SC = _load_scoring_config()

# Pre-build plain dicts from the JSON's ordered [tag, points] lists — safe here
# because we only ever look up already-canonicalized labels (from our own parser
# below), never scan raw text, so list order (which matters for substring
# matching against raw text) is irrelevant to us.
_HDR_4K = dict(_SC['hdr_4k'])
_HDR_HD = dict(_SC['hdr_hd'])
_AUDIO = dict(_SC['audio'])

###############################################################################
# Label -> JSON-key translation tables
#
# Only the labels parse_quality_from_filename() below can actually produce are
# listed. 'DVDRip' is a defined key in the old Python module's SOURCE_SCORES /
# TV_SOURCE_SCORES dicts, but the parser's source regex has no DVDRip
# alternative at all — it can never be produced as a parsed value — so no
# mapping is needed for it here; this is a documented non-issue, not a gap.
###############################################################################

_RESOLUTION_KEY = {'2160p': '2160p', '1080p': '1080p', '720p': '720p', '480p': 'sd'}

# NOTE: these keys are deliberately case-sensitive and match the old module's
# SOURCE_SCORES/TV_SOURCE_SCORES dict keys exactly (not normalized/lowercased).
# The parser's regex is case-insensitive but returns the filename's original
# matched text uncanonicalized, so a real-world filename in unexpected case
# would score 0 in the OLD module too (dict lookup miss) — preserving that
# exact quirk here, not "fixing" it, keeps behavior identical.
_SOURCE_KEY = {
    'Remux': 'remux', 'Bluray': 'bluray', 'BluRay': 'bluray',
    'WEB-DL': 'web_dl', 'WEBDL': 'web_dl', 'WEBRip': 'webrip', 'HDTV': 'hdtv',
}

_HDR_KEY = {
    'DV HDR10+': 'dv hdr10+', 'DV HDR10': 'dv hdr10', 'HDR10+': 'hdr10+',
    'HDR10': 'hdr10', 'DV HLG': 'dv hlg', 'DV SDR': 'dv sdr',
    'DV': 'dv', 'HDR': 'hdr', 'HLG': 'hlg',
}

_AUDIO_KEY = {
    'TrueHD Atmos': 'truehd atmos', 'Atmos': 'atmos', 'TrueHD': 'truehd',
    'DTS-HD MA': 'dts-hd ma', 'DTS:X': 'dts:x', 'DTS-HD': 'dts-hd',
    'DTS': 'dts', 'DD+': 'dd+', 'DD': 'ac3', 'AAC': 'aac',
}

_CODEC_KEY = {'HEVC': 'hevc', 'AVC': 'avc', 'AV1': 'av1', 'VC-1': 'vc1'}


###############################################################################
# Filename Parsing — ported verbatim from scripts/lib/quality_scoring.py
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

    bracket_contents = re.findall(r'\[([^\]]+)\]', filename)

    for content in bracket_contents:
        content_upper = content.upper()

        res_match = re.search(
            r'(Remux|Bluray|WEBDL|WEB-DL|WEBRip|HDTV)[- ]?(2160p|1080p|720p|480p)',
            content, re.IGNORECASE
        )
        if res_match:
            result['source'] = res_match.group(1)
            result['resolution'] = res_match.group(2)
            continue

        if content in ('2160p', '1080p', '720p', '480p'):
            result['resolution'] = content
            continue

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

        if content_upper in ('HEVC', 'H.265', 'X265', 'H265'):
            result['codec'] = 'HEVC'
            continue
        if content_upper in ('AVC', 'H.264', 'X264', 'H264'):
            result['codec'] = 'AVC'
            continue
        if content_upper == 'AV1':
            result['codec'] = 'AV1'
            continue
        if content_upper in ('VC-1', 'VC1'):
            result['codec'] = 'VC-1'
            continue

    group_match = re.search(r'-([A-Za-z0-9]+)(?:\.[a-z]{3})?$', filename)
    if group_match:
        result['release_group'] = group_match.group(1)

    return result


###############################################################################
# Scoring
###############################################################################

def calculate_quality_score_breakdown(resolution: str, source: str, hdr: str,
                                       audio: str, codec: str, size_gb: float,
                                       is_4k: bool = False, media_type: str = 'movie') -> Dict[str, int]:
    """
    Same inputs as calculate_quality_score(), but returns a component breakdown
    dict (resolution/source/hdr/audio/codec/hevc_adjustment/size_bonus/total)
    instead of just the total — powers the score-breakdown UI in Upgraderr's
    /upgrades and /queue pages. calculate_quality_score() is a thin wrapper
    around this so the two can never drift from each other.

    Deliberately does NOT read _SC['container_penalty_mp4'] or
    _SC['custom_formats'] — those exist in the JSON for sync-webhook/curatorr
    but including them here would silently change Upgraderr's scores beyond
    what scripts/lib/quality_scoring.py ever did. Do not "fix" this by wiring
    them in without a separate, explicit decision to do so.
    """
    is_x265 = codec == 'HEVC'
    has_hdr = bool(hdr) and hdr not in ('', 'None', 'SDR')
    has_dv = bool(hdr) and 'DV' in hdr

    breakdown = {
        'resolution': _SC['resolution'].get(_RESOLUTION_KEY.get(resolution), 0),
        'source': (_SC['tv_source'] if media_type == 'tv' else _SC['source']).get(
            _SOURCE_KEY.get(source), 0),
        'hdr': (_HDR_4K if is_4k else _HDR_HD).get(_HDR_KEY.get(hdr), 0),
        'audio': _AUDIO.get(_AUDIO_KEY.get(audio), 0),
        'codec': _SC['codec'].get(_CODEC_KEY.get(codec), 0),
        'hevc_adjustment': 0,
        'size_bonus': min(int(size_gb * _SC['size_bonus_per_gb']), _SC['size_bonus_cap']),
    }

    if is_x265 and not is_4k:
        if has_dv:
            breakdown['hevc_adjustment'] = _SC['hevc_dv_bonus_hd']
        elif not has_hdr:
            breakdown['hevc_adjustment'] = _SC['hevc_penalty_hd_no_hdr']
        # else: neutral, stays 0 — matches old module's "elif has_hdr: score += 0" branch

    breakdown['total'] = sum(v for k, v in breakdown.items() if k != 'total')
    return breakdown


def calculate_quality_score(resolution: str, source: str, hdr: str,
                            audio: str, codec: str, size_gb: float,
                            is_4k: bool = False, media_type: str = 'movie') -> int:
    """Same signature as scripts/lib/quality_scoring.py's calculate_quality_score —
    drop-in replacement for services/upgraderr/app.py's two call sites."""
    return calculate_quality_score_breakdown(
        resolution, source, hdr, audio, codec, size_gb, is_4k, media_type
    )['total']
