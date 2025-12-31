#!/usr/bin/env python3
"""
Media Library Inventory Generator
Scans media directories and generates JSON/CSV inventory files

FIXED: Now properly handles nested season folders for TV shows
- /TV/Show/Episode.mkv → title: "Show" ✅
- /TV/Show/01/Episode.mkv → title: "Show" ✅ (was "01" ❌)
"""

import os
import sys
import json
import argparse
import re
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from datetime import datetime

try:
    from pymediainfo import MediaInfo
    from tqdm import tqdm
    import pandas as pd
except ImportError as e:
    print(f"Error: Missing required package: {e}")
    print("Install with: pip3 install --break-system-packages pymediainfo tqdm pandas")
    sys.exit(1)


class MediaInventory:
    """Generates inventory of media files with detailed metadata"""
    
    # Supported video file extensions
    VIDEO_EXTENSIONS = {'.mkv', '.mp4', '.avi', '.m4v', '.mov', '.wmv', '.flv', '.webm', '.ts'}
    
    # Regex patterns for metadata extraction
    PATTERNS = {
        # Resolution patterns
        'resolution': [
            (r'2160p|4K|UHD', '2160p'),
            (r'1080p|1920x1080', '1080p'),
            (r'720p|1280x720', '720p'),
            (r'576p', '576p'),
            (r'480p', '480p'),
        ],
        
        # Source/Quality patterns
        'source': [
            (r'Remux|REMUX', 'Remux'),
            (r'BluRay|Blu-ray|BLURAY|BDRip|BRRip', 'BluRay'),
            (r'WEB-DL|WEBDL|WEB\.DL', 'WEB-DL'),
            (r'WEBRip|WEB-Rip|WEB\.Rip', 'WEBRip'),
            (r'HDTV', 'HDTV'),
            (r'DVD|DVDRip', 'DVD'),
            (r'HDDVD|HD-DVD', 'HDDVD'),
        ],
        
        # Video codec patterns
        'video_codec': [
            (r'[xh]\.?265|HEVC', 'H.265'),
            (r'[xh]\.?264|AVC', 'H.264'),
            (r'VP9', 'VP9'),
            (r'AV1', 'AV1'),
            (r'VC-1|VC1', 'VC-1'),
            (r'MPEG-?2', 'MPEG-2'),
        ],
        
        # Audio codec patterns
        'audio_codec': [
            (r'TrueHD\.?Atmos|Atmos\.?TrueHD', 'TrueHD Atmos'),
            (r'TrueHD', 'TrueHD'),
            (r'DTS-HD\.?MA|DTS\.?HD\.?MA|DTSMA', 'DTS-HD MA'),
            (r'DTS-HD|DTSHD', 'DTS-HD'),
            (r'DTS-X|DTSX', 'DTS:X'),
            (r'DTS', 'DTS'),
            (r'DD\+\.?Atmos|EAC3\.?Atmos|Atmos\.?DD\+', 'DD+ Atmos'),
            (r'DD\+|E-?AC-?3|EAC3', 'DD+'),
            (r'DD|AC-?3|AC3(?!\.)', 'DD'),
            (r'AAC', 'AAC'),
            (r'FLAC', 'FLAC'),
            (r'PCM', 'PCM'),
            (r'Opus', 'Opus'),
        ],
        
        # HDR format detection - ORDER MATTERS! Most specific first
        'hdr': [
            # Dolby Vision variants (check most specific first)
            (r'DV.*HDR10\+|Dolby.?Vision.*HDR10\+|DoVi.*HDR10\+', 'DV HDR10+'),
            (r'DV.*HDR10|Dolby.?Vision.*HDR10|DoVi.*HDR10', 'DV HDR10'),
            (r'DV.*HLG|Dolby.?Vision.*HLG|DoVi.*HLG', 'DV HLG'),
            (r'DV.*SDR|Dolby.?Vision.*SDR|DoVi.*SDR', 'DV SDR'),
            (r'DV|DoVi|Dolby.?Vision', 'DV'),
            
            # HDR variants (specific to generic)
            (r'HDR10\+|HDR10Plus', 'HDR10+'),
            (r'HDR10(?!\+)', 'HDR10'),
            (r'HDR(?!10)', 'HDR'),
            (r'HLG', 'HLG'),
        ],
        
        # Release group
        'group': [
            (r'-([A-Za-z0-9]+)(?:\[.*\])?$', r'\1'),  # Capture group at end
        ],
    }

    def __init__(self, root_path: str, output_base: str, verbose: bool = False, fast: bool = False):
        """
        Initialize inventory generator

        Args:
            root_path: Root directory to scan
            output_base: Base path for output files (without extension)
            verbose: Enable verbose output
            fast: Skip MediaInfo (filename-only parsing, much faster for NFS)
        """
        self.root_path = Path(root_path)
        self.output_base = output_base
        self.verbose = verbose
        self.fast = fast
        self.inventory: List[Dict] = []

        if not self.root_path.exists():
            raise FileNotFoundError(f"Path does not exist: {root_path}")

        if not self.root_path.is_dir():
            raise NotADirectoryError(f"Path is not a directory: {root_path}")

    def _extract_pattern(self, text: str, pattern_list: List[Tuple], default: str = '') -> str:
        """
        Extract information using regex patterns
        
        Args:
            text: Text to search
            pattern_list: List of (pattern, replacement) tuples
            default: Default value if no match
            
        Returns:
            Extracted value or default
        """
        for pattern, replacement in pattern_list:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                if callable(replacement):
                    return replacement(match)
                elif '\\' in replacement:
                    return match.expand(replacement)
                else:
                    return replacement
        return default

    def _get_show_title(self, file_path: Path) -> str:
        """
        Extract show/movie title from file path
        Handles both flat and season-subfolder structures

        Examples:
            /Movies/Avatar (2009)/Avatar.mkv → "Avatar (2009)"
            /TV/Battlestar/S01E01.mkv → "Battlestar"
            /TV/IT Crowd/03/S03E02.mkv → "IT Crowd" (goes up 1 level!)

        Args:
            file_path: Path to media file

        Returns:
            Show or movie title
        """
        parent_name = file_path.parent.name

        # Check if parent folder looks like a season folder
        # Patterns: "01", "02", "Season 1", "Season 01", "S01", "1944" (year-based), "Specials", etc.
        season_patterns = [
            r'^\d{1,2}$',  # Just numbers: "01", "1", "15"
            r'^\d{4}$',  # Year-based: "1944", "1945" (for shows like Looney Tunes)
            r'^Season\s*\d+$',  # "Season 1", "Season 01"
            r'^S\d{1,2}$',  # "S1", "S01"
            r'^Specials?$',  # "Special" or "Specials"
            r'^Featurettes?$',  # "Featurette" or "Featurettes"
            r'^Extras?$',  # "Extra" or "Extras"
        ]

        is_season_folder = any(
            re.match(pattern, parent_name, re.IGNORECASE)
            for pattern in season_patterns
        )

        if is_season_folder:
            # Go up one more level to get show name
            return file_path.parent.parent.name
        else:
            # Use immediate parent
            return parent_name

    def _get_show_folder(self, file_path: Path) -> str:
        """Get the show's root folder name (for TV shows with season subfolders)"""
        parent_name = file_path.parent.name

        # Same patterns as _get_show_title
        season_patterns = [
            r'^\d{1,2}$',  # Just numbers: "01", "1", "15"
            r'^\d{4}$',  # Year-based: "1944", "1945"
            r'^Season\s*\d+$',  # "Season 1", "Season 01"
            r'^S\d{1,2}$',  # "S1", "S01"
            r'^Specials?$',  # "Special" or "Specials"
            r'^Featurettes?$',  # "Featurette" or "Featurettes"
            r'^Extras?$',  # "Extra" or "Extras"
        ]

        is_season_folder = any(
            re.match(pattern, parent_name, re.IGNORECASE)
            for pattern in season_patterns
        )

        if is_season_folder:
            return file_path.parent.parent.name
        else:
            return parent_name

    def _extract_tvdb_id(self, folder_name: str) -> str:
        """Extract TVDB ID from folder name like 'Show Name (2020) {tvdb-123456}'"""
        match = re.search(r'\{tvdb-(\d+)\}', folder_name, re.IGNORECASE)
        return match.group(1) if match else ''

    def _extract_episode_info(self, filename: str) -> dict:
        """Extract season/episode info from filename like 'Show - S01E05 - Title'"""
        info = {'season': None, 'episode': None, 'episode_title': ''}

        # Match S01E05 or S01E05E06 (multi-episode)
        match = re.search(r'S(\d{1,2})E(\d{1,2})(?:E\d{1,2})?', filename, re.IGNORECASE)
        if match:
            info['season'] = int(match.group(1))
            info['episode'] = int(match.group(2))

        # Try to extract episode title (between episode number and quality tags)
        title_match = re.search(r'S\d{1,2}E\d{1,2}(?:E\d{1,2})?\s*-\s*(.+?)(?:\s*[\[\(]|\s*\d{3,4}p|\s*$)', filename)
        if title_match:
            info['episode_title'] = title_match.group(1).strip()

        return info

    def _get_mediainfo(self, file_path: Path) -> Optional[MediaInfo]:
        """
        Get MediaInfo object for file
        
        Args:
            file_path: Path to media file
            
        Returns:
            MediaInfo object or None on error
        """
        try:
            return MediaInfo.parse(str(file_path))
        except Exception as e:
            if self.verbose:
                print(f"Error reading {file_path}: {e}")
            return None

    def _extract_metadata(self, file_path: Path) -> Dict:
        """
        Extract comprehensive metadata from media file

        Args:
            file_path: Path to media file

        Returns:
            Dictionary of metadata
        """
        filename = file_path.name

        # FIXED: Use _get_show_title() to handle nested season folders
        parent_dir = self._get_show_title(file_path)

        # Get show folder for TVDB extraction
        show_folder = self._get_show_folder(file_path)

        # Calculate relative path from root
        try:
            relative_path = file_path.relative_to(self.root_path)
        except ValueError:
            relative_path = file_path

        # Get MediaInfo data (skip in fast mode)
        media_info = None if self.fast else self._get_mediainfo(file_path)

        # Extract from filename
        resolution = self._extract_pattern(filename, self.PATTERNS['resolution'])
        source = self._extract_pattern(filename, self.PATTERNS['source'])
        video_codec_fn = self._extract_pattern(filename, self.PATTERNS['video_codec'])
        audio_codec_fn = self._extract_pattern(filename, self.PATTERNS['audio_codec'])
        hdr = self._extract_pattern(filename, self.PATTERNS['hdr'])
        group = self._extract_pattern(filename, self.PATTERNS['group'])

        # Extract TVDB ID from show folder (for TV shows)
        tvdb_id = self._extract_tvdb_id(show_folder)

        # Extract TMDB/IMDB from filename (for movies)
        tmdb_match = re.search(r'\{tmdb-(\d+)\}', filename, re.IGNORECASE)
        tmdb_id = tmdb_match.group(1) if tmdb_match else ''
        imdb_match = re.search(r'\{imdb-(tt\d+)\}', filename, re.IGNORECASE)
        imdb_id = imdb_match.group(1) if imdb_match else ''

        # Extract year from folder or filename
        year_match = re.search(r'\((\d{4})\)', show_folder) or re.search(r'\((\d{4})\)', filename)
        year = year_match.group(1) if year_match else ''

        # Extract episode info (for TV shows)
        episode_info = self._extract_episode_info(filename)

        # Initialize metadata
        metadata = {
            'title': parent_dir,
            'show_folder': show_folder,
            'filename': filename,
            'path': str(file_path),
            'relative_path': str(relative_path),
            'size_bytes': file_path.stat().st_size,
            'size_gb': round(file_path.stat().st_size / (1024**3), 2),
            'resolution': resolution,
            'width': None,
            'height': None,
            'video_codec': video_codec_fn,
            'audio_codec': audio_codec_fn,
            'hdr': hdr,
            'source': source,
            'group': group,
            'duration_minutes': None,
            'bitrate_mbps': None,
            # ID fields
            'tvdb_id': tvdb_id,
            'tmdb_id': tmdb_id,
            'imdb_id': imdb_id,
            'year': year,
            # Episode fields (for TV)
            'season': episode_info['season'],
            'episode': episode_info['episode'],
            'episode_title': episode_info['episode_title'],
        }
        
        # Extract from MediaInfo if available
        if media_info:
            for track in media_info.tracks:
                if track.track_type == 'General':
                    if track.duration:
                        metadata['duration_minutes'] = round(int(track.duration) / 60000, 1)
                    if track.overall_bit_rate:
                        metadata['bitrate_mbps'] = round(int(track.overall_bit_rate) / 1_000_000, 2)
                
                elif track.track_type == 'Video':
                    if track.width:
                        metadata['width'] = int(track.width)
                    if track.height:
                        metadata['height'] = int(track.height)
                    
                    # Override codec from MediaInfo if more accurate
                    if track.format:
                        if 'HEVC' in track.format or 'H.265' in track.format:
                            metadata['video_codec'] = 'H.265'
                        elif 'AVC' in track.format or 'H.264' in track.format:
                            metadata['video_codec'] = 'H.264'
                        elif 'AV1' in track.format:
                            metadata['video_codec'] = 'AV1'
                        elif 'VP9' in track.format:
                            metadata['video_codec'] = 'VP9'
                    
                    # Check for HDR in MediaInfo if not found in filename
                    if not metadata['hdr'] and hasattr(track, 'hdr_format'):
                        if track.hdr_format:
                            if 'Dolby Vision' in track.hdr_format:
                                metadata['hdr'] = 'DV'
                            elif 'HDR10+' in track.hdr_format:
                                metadata['hdr'] = 'HDR10+'
                            elif 'HDR10' in track.hdr_format:
                                metadata['hdr'] = 'HDR10'
                            elif 'HLG' in track.hdr_format:
                                metadata['hdr'] = 'HLG'
        
        return metadata

    def scan(self) -> int:
        """
        Scan directory for media files and build inventory
        
        Returns:
            Number of files processed
        """
        print(f"Scanning: {self.root_path}")
        
        # Find all video files
        video_files = []
        for ext in self.VIDEO_EXTENSIONS:
            video_files.extend(self.root_path.rglob(f'*{ext}'))
        
        print(f"Found {len(video_files)} video files")
        
        # Process each file with progress bar
        for file_path in tqdm(video_files, desc="Processing", unit="file"):
            try:
                metadata = self._extract_metadata(file_path)
                self.inventory.append(metadata)
            except Exception as e:
                if self.verbose:
                    print(f"Error processing {file_path}: {e}")
        
        return len(self.inventory)

    def save_json(self) -> str:
        """
        Save inventory as JSON
        
        Returns:
            Output file path
        """
        output_file = f"{self.output_base}.json"
        
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(self.inventory, f, indent=2, ensure_ascii=False)
        
        print(f"Saved JSON: {output_file}")
        return output_file

    def save_csv(self) -> str:
        """
        Save inventory as CSV
        
        Returns:
            Output file path
        """
        output_file = f"{self.output_base}.csv"
        
        if not self.inventory:
            print("No data to save")
            return ""
        
        df = pd.DataFrame(self.inventory)
        df.to_csv(output_file, index=False, encoding='utf-8')
        
        print(f"Saved CSV: {output_file}")
        return output_file

    def print_summary(self):
        """Print summary statistics"""
        if not self.inventory:
            print("No files in inventory")
            return
        
        df = pd.DataFrame(self.inventory)
        
        print("\n" + "="*60)
        print("INVENTORY SUMMARY")
        print("="*60)
        print(f"Total files: {len(self.inventory)}")
        print(f"Total size: {df['size_gb'].sum():.2f} GB")
        
        if 'resolution' in df.columns:
            print("\nResolutions:")
            print(df['resolution'].value_counts().to_string())
        
        if 'hdr' in df.columns and df['hdr'].notna().any():
            print("\nHDR Formats:")
            print(df[df['hdr'].notna()]['hdr'].value_counts().to_string())
        
        if 'source' in df.columns:
            print("\nSources:")
            print(df['source'].value_counts().to_string())
        
        print("="*60)


def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(
        description='Generate media library inventory with detailed metadata (FIXED for TV shows)',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  %(prog)s /mnt/media/Movies -o ~/inventories/movies
  %(prog)s "/mnt/media/TV Shows" -o ~/inventories/tv --verbose
  
FIXED: Now handles nested season folders correctly:
  /TV/Show Name/01/Episode.mkv  → title: "Show Name" (not "01")
        """
    )
    
    parser.add_argument(
        'path',
        help='Root directory to scan'
    )
    
    parser.add_argument(
        '-o', '--output',
        required=True,
        help='Output file base (without extension, will create .json and .csv)'
    )
    
    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        help='Enable verbose output'
    )

    parser.add_argument(
        '--fast',
        action='store_true',
        help='Fast mode: skip MediaInfo, parse filenames only (much faster for NFS/network)'
    )

    args = parser.parse_args()
    
    try:
        # Create inventory
        inventory = MediaInventory(
            root_path=args.path,
            output_base=args.output,
            verbose=args.verbose,
            fast=args.fast
        )
        
        # Scan directory
        count = inventory.scan()
        
        if count == 0:
            print("No video files found!")
            return 1
        
        # Save outputs
        inventory.save_json()
        inventory.save_csv()
        
        # Print summary
        inventory.print_summary()
        
        return 0
        
    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        if args.verbose:
            import traceback
            traceback.print_exc()
        return 1


if __name__ == '__main__':
    sys.exit(main())
