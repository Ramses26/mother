#!/usr/bin/env python3
"""
TV Library Naming Validator
Checks TV show folders and episodes against TRaSH guide / Sonarr naming conventions

Expected Folder Format:
    Show Name (Year) {tvdb-123456}

Expected Episode Format:
    Show Name (Year) - S01E05 - Episode Title [Quality][Audio][HDR][Codec]-Group.mkv

Usage:
    python3 validate_tv_naming.py inventories/ali_tv_1080p.json -o reports/tv_naming
"""

import json
import re
import argparse
from pathlib import Path
from collections import defaultdict


class TVNamingValidator:
    """Validates TV show naming against Sonarr/TRaSH guide conventions"""

    # Expected folder format regex: "Show Name (Year) {tvdb-123456}"
    FOLDER_PATTERN = re.compile(
        r'^(.+?)\s*\((\d{4})\)\s*\{tvdb-(\d+)\}$',
        re.IGNORECASE
    )

    # Expected episode filename format: "Show Name (Year) - S01E05 - Episode Title..."
<<<<<<< HEAD
    # Supports year-based seasons (S1944E15), 3-digit episodes (S01E101), multi-episode formats
    EPISODE_PATTERN = re.compile(
        r'^(.+?)\s*\((\d{4})\)\s*-\s*S(\d{1,4})E(\d{1,3})(?:[-E]\d{1,3})*\s*-\s*(.+?)(?:\s*[\[\(]|\s*\d{3,4}p)',
        re.IGNORECASE
    )

    # Simpler check: just verify S##E## exists (supports 2-4 digit seasons for year-based, 1-3 digit episodes)
    EPISODE_BASIC_PATTERN = re.compile(r'S(\d{1,4})E(\d{1,3})', re.IGNORECASE)
=======
    EPISODE_PATTERN = re.compile(
        r'^(.+?)\s*\((\d{4})\)\s*-\s*S(\d{2})E(\d{2})(?:E\d{2})*\s*-\s*(.+?)(?:\s*[\[\(]|\s*\d{3,4}p)',
        re.IGNORECASE
    )

    # Simpler check: just verify S##E## exists
    EPISODE_BASIC_PATTERN = re.compile(r'S(\d{1,2})E(\d{1,2})', re.IGNORECASE)
>>>>>>> cf3d0c0652e9209e32d63321c39a0b72beae05f6

    def __init__(self, inventory_path: Path):
        """Load inventory from JSON file"""
        with open(inventory_path, 'r') as f:
            self.items = json.load(f)
        self.inventory_path = inventory_path

    def validate_folder(self, folder_name: str) -> dict:
        """
        Validate a folder name against expected format.

        Returns dict with:
            - valid: bool
            - has_year: bool
            - has_tvdb: bool
            - issues: list of specific issues
        """
        result = {
            'valid': False,
            'has_year': False,
            'has_tvdb': False,
            'issues': [],
            'folder': folder_name,
        }

        # Check for year
        year_match = re.search(r'\((\d{4})\)', folder_name)
        if year_match:
            result['has_year'] = True
            result['year'] = year_match.group(1)
        else:
            result['issues'].append('Missing year (YYYY)')

        # Check for TVDB ID
        tvdb_match = re.search(r'\{tvdb-(\d+)\}', folder_name, re.IGNORECASE)
        if tvdb_match:
            result['has_tvdb'] = True
            result['tvdb_id'] = tvdb_match.group(1)
        else:
            result['issues'].append('Missing {tvdb-ID}')

        # Full pattern match
        full_match = self.FOLDER_PATTERN.match(folder_name)
        if full_match:
            result['valid'] = True
            result['parsed_title'] = full_match.group(1).strip()
        elif result['has_year'] and result['has_tvdb']:
            # Has required parts but maybe wrong order/format
            result['issues'].append('Format issue: Should be "Show Name (Year) {tvdb-ID}"')

        return result

    def validate_episode(self, filename: str, show_folder: str) -> dict:
        """
        Validate an episode filename against expected format.

        Returns dict with:
            - valid: bool
            - has_episode_code: bool (S##E##)
            - has_episode_title: bool
            - matches_folder: bool (show name matches)
            - issues: list of specific issues
        """
        result = {
            'valid': False,
            'has_episode_code': False,
            'has_episode_title': False,
            'has_year_in_filename': False,
            'issues': [],
            'filename': filename,
        }

        # Basic check: has S##E## pattern
        basic_match = self.EPISODE_BASIC_PATTERN.search(filename)
        if basic_match:
            result['has_episode_code'] = True
            result['season'] = int(basic_match.group(1))
            result['episode'] = int(basic_match.group(2))
        else:
            result['issues'].append('Missing S##E## episode code')
            return result  # Can't be valid without this

        # Check for year in filename
        year_match = re.search(r'\((\d{4})\)', filename)
        if year_match:
            result['has_year_in_filename'] = True

        # Check for episode title (text between S##E## and quality tags)
<<<<<<< HEAD
        # Supports year-based seasons (S1944E15), 3-digit episodes (S01E101), multi-episode (E05E06, E05-E06)
        title_pattern = re.search(
            r'S\d{1,4}E\d{1,3}(?:[-E]\d{1,3})*\s*-\s*(.+?)(?:\s*[\[\(]|\s*\d{3,4}p|\s*$)',
=======
        title_pattern = re.search(
            r'S\d{1,2}E\d{1,2}(?:E\d{1,2})?\s*-\s*(.+?)(?:\s*[\[\(]|\s*\d{3,4}p|\s*$)',
>>>>>>> cf3d0c0652e9209e32d63321c39a0b72beae05f6
            filename
        )
        if title_pattern:
            title = title_pattern.group(1).strip()
            if title and len(title) > 1:
                result['has_episode_title'] = True
                result['episode_title'] = title

        if not result['has_episode_title']:
            result['issues'].append('Missing episode title after S##E## -')

        # Full pattern match for ideal format
        full_match = self.EPISODE_PATTERN.match(filename)
        if full_match:
            result['valid'] = True
            result['parsed_show'] = full_match.group(1).strip()
        else:
            if not result['has_year_in_filename']:
                result['issues'].append('Missing (Year) in filename')

        return result

    def validate_all(self) -> dict:
        """
        Validate all items in inventory.

        Returns comprehensive validation results.
        """
        results = {
            'folder_issues': defaultdict(dict),  # folder_name -> {issues, files}
            'episode_issues': [],  # List of files with episode naming issues
            'valid_folders': [],
            'valid_episodes': 0,
            'total_folders': 0,
            'total_episodes': len(self.items),
            'folders_missing_tvdb': [],
            'folders_missing_year': [],
            'episodes_missing_code': [],
            'episodes_missing_title': [],
        }

        # Group by show folder
        shows = defaultdict(list)
        for item in self.items:
            folder = item.get('show_folder', item.get('title', ''))
            shows[folder].append(item)

        results['total_folders'] = len(shows)

        # Validate each show folder
        for folder_name, episodes in shows.items():
            folder_result = self.validate_folder(folder_name)

            if folder_result['valid']:
                results['valid_folders'].append(folder_name)
            else:
                results['folder_issues'][folder_name] = {
                    'validation': folder_result,
                    'episode_count': len(episodes),
                    'sample_path': episodes[0].get('path', '') if episodes else '',
                }

                if not folder_result['has_tvdb']:
                    results['folders_missing_tvdb'].append({
                        'folder': folder_name,
                        'path': episodes[0].get('path', '') if episodes else '',
                    })

                if not folder_result['has_year']:
                    results['folders_missing_year'].append({
                        'folder': folder_name,
                        'path': episodes[0].get('path', '') if episodes else '',
                    })

            # Validate each episode in the show
            for ep in episodes:
                filename = ep.get('filename', '')
                ep_result = self.validate_episode(filename, folder_name)

                if ep_result['valid']:
                    results['valid_episodes'] += 1
                else:
                    results['episode_issues'].append({
                        'filename': filename,
                        'path': ep.get('path', ''),
                        'show_folder': folder_name,
                        'validation': ep_result,
                    })

                    if not ep_result['has_episode_code']:
                        results['episodes_missing_code'].append({
                            'filename': filename,
                            'path': ep.get('path', ''),
                        })

                    if ep_result['has_episode_code'] and not ep_result['has_episode_title']:
                        results['episodes_missing_title'].append({
                            'filename': filename,
                            'path': ep.get('path', ''),
                        })

        return results


def write_report(results: dict, output_path: Path, library_name: str):
    """Write validation report to file"""
    output_path.mkdir(parents=True, exist_ok=True)

    # Summary report
    summary_file = output_path / f'{library_name}_naming_summary.txt'
    with open(summary_file, 'w') as f:
        f.write("=" * 80 + "\n")
        f.write(f"TV NAMING VALIDATION REPORT - {library_name.upper()}\n")
        f.write("=" * 80 + "\n\n")

        f.write("SUMMARY\n")
        f.write("-" * 50 + "\n")

        total_folders = results['total_folders']
        valid_folders = len(results['valid_folders'])
        invalid_folders = total_folders - valid_folders

        total_episodes = results['total_episodes']
        valid_episodes = results['valid_episodes']
        invalid_episodes = total_episodes - valid_episodes

        folder_pct = (valid_folders / total_folders * 100) if total_folders > 0 else 0
        episode_pct = (valid_episodes / total_episodes * 100) if total_episodes > 0 else 0

        f.write(f"Folders:  {valid_folders:>5} / {total_folders:<5} valid ({folder_pct:.1f}%)\n")
        f.write(f"Episodes: {valid_episodes:>5} / {total_episodes:<5} valid ({episode_pct:.1f}%)\n\n")

        f.write(f"Issues Breakdown:\n")
        f.write(f"  Folders missing TVDB ID:    {len(results['folders_missing_tvdb'])}\n")
        f.write(f"  Folders missing year:       {len(results['folders_missing_year'])}\n")
        f.write(f"  Episodes missing S##E##:    {len(results['episodes_missing_code'])}\n")
        f.write(f"  Episodes missing title:     {len(results['episodes_missing_title'])}\n")
        f.write("-" * 50 + "\n\n")

        # Quick wins - folders just missing TVDB
        if results['folders_missing_tvdb']:
            f.write("\n" + "=" * 60 + "\n")
            f.write("FOLDERS MISSING TVDB ID (run through Sonarr to fix)\n")
            f.write("=" * 60 + "\n\n")
            for item in sorted(results['folders_missing_tvdb'], key=lambda x: x['folder']):
                f.write(f"  {item['folder']}\n")

    print(f"Summary: {summary_file}")

    # Detailed folder issues
    folder_file = output_path / f'{library_name}_folder_issues.txt'
    with open(folder_file, 'w') as f:
        f.write("=" * 80 + "\n")
        f.write("FOLDER NAMING ISSUES\n")
        f.write("Expected format: Show Name (Year) {tvdb-123456}\n")
        f.write("=" * 80 + "\n\n")

        if not results['folder_issues']:
            f.write("No folder naming issues found!\n")
        else:
            for folder, data in sorted(results['folder_issues'].items()):
                f.write(f"\nFolder: {folder}\n")
                f.write(f"  Episodes: {data['episode_count']}\n")
                f.write(f"  Issues: {', '.join(data['validation']['issues'])}\n")
                f.write(f"  Sample: {data['sample_path']}\n")

    print(f"Folder issues: {folder_file}")

    # Detailed episode issues
    episode_file = output_path / f'{library_name}_episode_issues.txt'
    with open(episode_file, 'w') as f:
        f.write("=" * 80 + "\n")
        f.write("EPISODE NAMING ISSUES\n")
        f.write("Expected format: Show Name (Year) - S01E05 - Episode Title [Quality].mkv\n")
        f.write("=" * 80 + "\n\n")

        if not results['episode_issues']:
            f.write("No episode naming issues found!\n")
        else:
            # Group by show for readability
            by_show = defaultdict(list)
            for ep in results['episode_issues']:
                by_show[ep['show_folder']].append(ep)

            for show, episodes in sorted(by_show.items()):
                f.write(f"\n{'='*60}\n")
                f.write(f"{show} ({len(episodes)} issues)\n")
                f.write(f"{'='*60}\n\n")

                for ep in sorted(episodes, key=lambda x: x['filename']):
                    f.write(f"  File: {ep['filename']}\n")
                    f.write(f"  Issues: {', '.join(ep['validation']['issues'])}\n")
                    f.write(f"  Path: {ep['path']}\n\n")

    print(f"Episode issues: {episode_file}")

    # Simple list for Sonarr bulk operations
    fixlist_file = output_path / f'{library_name}_needs_rename.txt'
    with open(fixlist_file, 'w') as f:
        f.write("# Shows that need renaming in Sonarr\n")
        f.write("# Use Sonarr Mass Editor > Rename Files\n\n")

        all_shows = set()
        for folder in results['folder_issues'].keys():
            all_shows.add(folder)
        for ep in results['episode_issues']:
            all_shows.add(ep['show_folder'])

        for show in sorted(all_shows):
            f.write(f"{show}\n")

    print(f"Shows needing rename: {fixlist_file}")

    return {
        'summary': summary_file,
        'folders': folder_file,
        'episodes': episode_file,
        'fixlist': fixlist_file,
    }


def main():
    parser = argparse.ArgumentParser(
        description='Validate TV library naming against Sonarr/TRaSH conventions'
    )
    parser.add_argument(
        'inventory',
        type=Path,
        help='TV inventory JSON file'
    )
    parser.add_argument(
        '-o', '--output',
        required=True,
        type=Path,
        help='Output directory for reports'
    )
    parser.add_argument(
        '-n', '--name',
        default='tv',
        help='Library name for report titles'
    )

    args = parser.parse_args()

    if not args.inventory.exists():
        print(f"Error: Inventory file not found: {args.inventory}")
        return 1

    print(f"Loading inventory: {args.inventory}")
    validator = TVNamingValidator(args.inventory)

    print(f"Validating {len(validator.items)} episodes...")
    results = validator.validate_all()

    print(f"\nGenerating reports...")
    write_report(results, args.output, args.name)

    # Print quick summary
    print("\n" + "=" * 50)
    valid_f = len(results['valid_folders'])
    total_f = results['total_folders']
    valid_e = results['valid_episodes']
    total_e = results['total_episodes']
    print(f"Folders:  {valid_f}/{total_f} valid ({valid_f/total_f*100:.1f}%)" if total_f else "No folders")
    print(f"Episodes: {valid_e}/{total_e} valid ({valid_e/total_e*100:.1f}%)" if total_e else "No episodes")
    print("=" * 50)

    return 0


if __name__ == '__main__':
    exit(main())
