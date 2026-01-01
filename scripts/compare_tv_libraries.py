#!/usr/bin/env python3
"""
TV Library Comparison Script - Project Mother
Compares TV show libraries between Ali and Chris using TVDB ID + Season + Episode

Key differences from movie comparison:
- Matches by TVDB ID (from folder) instead of TMDB ID (from filename)
- Uses show_folder + season + episode as the matching key
- Groups episodes by show for cleaner reporting

Usage:
    python3 compare_tv_libraries.py inventories/ali_tv_1080p.json inventories/chris_tv_1080p.json -o reports
"""

import json
import re
import argparse
from pathlib import Path
from datetime import datetime
from collections import defaultdict
from dataclasses import dataclass, field
from typing import Dict, List, Tuple, Optional

###############################################################################
# Path Configuration (same as movies)
###############################################################################

SYNOLOGY_PATHS = {
    'tv_1080p': '/mnt/synology/rs-tv',
    'tv_4k': '/mnt/synology/rs-4kmedia/4ktv',
}

UNRAID_PATHS = {
    'tv_1080p': '/mnt/unraid/media/TV Shows',
    'tv_4k': '/mnt/unraid/media/4K TV Shows',
}

# Shows to exclude from comparison (fan edits, custom content)
EXCLUDED_SHOWS = [
    'despecialized',
    'infinity saga',
    'sacred timeline',
]

###############################################################################
# Data Classes
###############################################################################

@dataclass
class TVEpisode:
    """Represents a single TV episode file"""
    filename: str
    path: str
    relative_path: str
    show_folder: str
    tvdb_id: str
    season: Optional[int]
    episode: Optional[int]
    episode_title: str
    size_bytes: int
    size_gb: float
    resolution: str
    video_codec: str
    audio_codec: str
    hdr: str
    source: str

    @property
    def episode_key(self) -> str:
        """Unique key for matching: tvdb_id + season + episode"""
        if self.tvdb_id and self.season is not None and self.episode is not None:
            return f"{self.tvdb_id}-S{self.season:02d}E{self.episode:02d}"
        return ""

    @property
    def show_key(self) -> str:
        """Key for grouping by show"""
        if self.tvdb_id:
            return f"tvdb-{self.tvdb_id}"
        # Fallback to normalized show name
        return self._normalize_show_name(self.show_folder)

    @staticmethod
    def _normalize_show_name(name: str) -> str:
        """Normalize show name for matching"""
        # Remove TVDB ID, year, and special characters
        name = re.sub(r'\{tvdb-\d+\}', '', name, flags=re.IGNORECASE)
        name = re.sub(r'\(\d{4}\)', '', name)
        name = re.sub(r'[^\w\s]', '', name)
        name = ' '.join(name.lower().split())
        return name

    @property
    def quality_score(self) -> int:
        """Score for quality comparison (higher = better)

        For TV: Web-DL > BluRay (except Remux)
        TV shows are mastered for streaming, so Web-DL is typically preferred.
        Remux is still king for shows like Band of Brothers, Planet Earth.
        """
        score = 0

        # Resolution
        res_scores = {'2160p': 4000, '1080p': 3000, '720p': 2000, '480p': 1000}
        score += res_scores.get(self.resolution, 0)

        # Source - Web-DL preferred over BluRay for TV (except Remux)
        source_scores = {'Remux': 500, 'WEB-DL': 400, 'BluRay': 300, 'WEBRip': 200, 'HDTV': 100}
        score += source_scores.get(self.source, 0)

        # HDR
        if self.hdr:
            score += 50

        return score


@dataclass
class EpisodeComparison:
    """Comparison result for a single episode"""
    ep_key: str  # S01E01
    ali_ep: Optional[TVEpisode]
    chris_ep: Optional[TVEpisode]
    winner: str  # 'ali', 'chris', 'tie', 'ali_only', 'chris_only'
    reason: str

    @property
    def ali_score(self) -> int:
        return self.ali_ep.quality_score if self.ali_ep else 0

    @property
    def chris_score(self) -> int:
        return self.chris_ep.quality_score if self.chris_ep else 0


@dataclass
class ShowComparison:
    """Comparison result for a single show"""
    show_name: str
    tvdb_id: str
    ali_episodes: Dict[str, TVEpisode] = field(default_factory=dict)  # key: S01E01
    chris_episodes: Dict[str, TVEpisode] = field(default_factory=dict)
    episode_results: List[EpisodeComparison] = field(default_factory=list)

    @property
    def ali_only(self) -> List[str]:
        """Episodes only Ali has"""
        return sorted(set(self.ali_episodes.keys()) - set(self.chris_episodes.keys()))

    @property
    def chris_only(self) -> List[str]:
        """Episodes only Chris has"""
        return sorted(set(self.chris_episodes.keys()) - set(self.ali_episodes.keys()))

    @property
    def both_have(self) -> List[str]:
        """Episodes both have"""
        return sorted(set(self.ali_episodes.keys()) & set(self.chris_episodes.keys()))

    def compare_episodes(self):
        """Compare quality for episodes both have"""
        self.episode_results = []

        # Episodes only one has
        for ep_key in self.ali_only:
            self.episode_results.append(EpisodeComparison(
                ep_key=ep_key,
                ali_ep=self.ali_episodes[ep_key],
                chris_ep=None,
                winner='ali_only',
                reason='Only Ali has this episode'
            ))

        for ep_key in self.chris_only:
            self.episode_results.append(EpisodeComparison(
                ep_key=ep_key,
                ali_ep=None,
                chris_ep=self.chris_episodes[ep_key],
                winner='chris_only',
                reason='Only Chris has this episode'
            ))

        # Episodes both have - compare quality
        for ep_key in self.both_have:
            ali_ep = self.ali_episodes[ep_key]
            chris_ep = self.chris_episodes[ep_key]

            ali_score = ali_ep.quality_score
            chris_score = chris_ep.quality_score

            if ali_score > chris_score:
                reason = f"Ali better: {ali_ep.resolution}/{ali_ep.source} ({ali_score}) vs {chris_ep.resolution}/{chris_ep.source} ({chris_score})"
                winner = 'ali'
            elif chris_score > ali_score:
                reason = f"Chris better: {chris_ep.resolution}/{chris_ep.source} ({chris_score}) vs {ali_ep.resolution}/{ali_ep.source} ({ali_score})"
                winner = 'chris'
            else:
                reason = f"Tie: both {ali_ep.resolution}/{ali_ep.source} ({ali_score})"
                winner = 'tie'

            self.episode_results.append(EpisodeComparison(
                ep_key=ep_key,
                ali_ep=ali_ep,
                chris_ep=chris_ep,
                winner=winner,
                reason=reason
            ))


###############################################################################
# Loading Functions
###############################################################################

def is_excluded(show_folder: str) -> bool:
    """Check if show should be excluded"""
    lower = show_folder.lower()
    return any(excl in lower for excl in EXCLUDED_SHOWS)


def load_tv_inventory(inventory_path: Path) -> List[TVEpisode]:
    """Load TV inventory from JSON"""
    with open(inventory_path, 'r') as f:
        items = json.load(f)

    episodes = []
    for item in items:
        show_folder = item.get('show_folder', item.get('title', ''))

        # Skip excluded shows
        if is_excluded(show_folder):
            continue

        # Extract season/episode from filename if not in inventory
        season = item.get('season')
        episode = item.get('episode')

        if season is None or episode is None:
            # Try to extract from filename
            match = re.search(r'S(\d{1,4})E(\d{1,3})', item.get('filename', ''), re.IGNORECASE)
            if match:
                season = int(match.group(1))
                episode = int(match.group(2))

        ep = TVEpisode(
            filename=item.get('filename', ''),
            path=item.get('path', ''),
            relative_path=item.get('relative_path', ''),
            show_folder=show_folder,
            tvdb_id=item.get('tvdb_id', ''),
            season=season,
            episode=episode,
            episode_title=item.get('episode_title', ''),
            size_bytes=item.get('size_bytes', 0),
            size_gb=item.get('size_gb', 0),
            resolution=item.get('resolution', ''),
            video_codec=item.get('video_codec', ''),
            audio_codec=item.get('audio_codec', ''),
            hdr=item.get('hdr', ''),
            source=item.get('source', ''),
        )
        episodes.append(ep)

    return episodes


###############################################################################
# Comparison Functions
###############################################################################

def compare_libraries(ali_episodes: List[TVEpisode], chris_episodes: List[TVEpisode]) -> Dict[str, ShowComparison]:
    """Compare two TV libraries by show"""

    # Group by show
    shows: Dict[str, ShowComparison] = {}

    # Process Ali's episodes
    for ep in ali_episodes:
        show_key = ep.show_key
        if show_key not in shows:
            shows[show_key] = ShowComparison(
                show_name=ep.show_folder,
                tvdb_id=ep.tvdb_id,
            )

        if ep.season is not None and ep.episode is not None:
            ep_key = f"S{ep.season:02d}E{ep.episode:02d}"
            # Keep best quality if duplicate
            if ep_key not in shows[show_key].ali_episodes or ep.quality_score > shows[show_key].ali_episodes[ep_key].quality_score:
                shows[show_key].ali_episodes[ep_key] = ep

    # Process Chris's episodes
    for ep in chris_episodes:
        show_key = ep.show_key
        if show_key not in shows:
            shows[show_key] = ShowComparison(
                show_name=ep.show_folder,
                tvdb_id=ep.tvdb_id,
            )

        if ep.season is not None and ep.episode is not None:
            ep_key = f"S{ep.season:02d}E{ep.episode:02d}"
            # Keep best quality if duplicate
            if ep_key not in shows[show_key].chris_episodes or ep.quality_score > shows[show_key].chris_episodes[ep_key].quality_score:
                shows[show_key].chris_episodes[ep_key] = ep

    # Compare episode quality for each show
    for show in shows.values():
        show.compare_episodes()

    return shows


def translate_path_for_rsync(path: str, source: str) -> str:
    """Translate inventory path to rsync-compatible path on Mother"""
    if source == 'ali':
        # Ali's paths: /mnt/media/TV Shows/... -> /mnt/unraid/media/TV Shows/...
        path = path.replace('/mnt/media/', '/mnt/unraid/media/')
    # Chris's paths are already correct for Mother
    return path


###############################################################################
# Report Generation
###############################################################################

def generate_reports(shows: Dict[str, ShowComparison], output_dir: Path, timestamp: str,
                     ali_episodes: List[TVEpisode], chris_episodes: List[TVEpisode]):
    """Generate all comparison reports"""
    output_dir.mkdir(parents=True, exist_ok=True)

    # Statistics
    total_shows = len(shows)
    ali_only_shows = sum(1 for s in shows.values() if s.ali_episodes and not s.chris_episodes)
    chris_only_shows = sum(1 for s in shows.values() if s.chris_episodes and not s.ali_episodes)
    both_shows = sum(1 for s in shows.values() if s.ali_episodes and s.chris_episodes)

    total_ali_eps = sum(len(s.ali_episodes) for s in shows.values())
    total_chris_eps = sum(len(s.chris_episodes) for s in shows.values())

    ali_only_eps = sum(len(s.ali_only) for s in shows.values())
    chris_only_eps = sum(len(s.chris_only) for s in shows.values())
    both_eps = sum(len(s.both_have) for s in shows.values())

    # Quality comparison stats
    ali_better = 0
    chris_better = 0
    ties = 0
    for show in shows.values():
        for result in show.episode_results:
            if result.winner == 'ali':
                ali_better += 1
            elif result.winner == 'chris':
                chris_better += 1
            elif result.winner == 'tie':
                ties += 1

    # Shows missing TVDB ID - track which owner
    ali_missing_tvdb = []
    chris_missing_tvdb = []
    for ep in ali_episodes:
        if not ep.tvdb_id and ep.show_folder not in [x['folder'] for x in ali_missing_tvdb]:
            ali_missing_tvdb.append({'folder': ep.show_folder, 'path': ep.path})
    for ep in chris_episodes:
        if not ep.tvdb_id and ep.show_folder not in [x['folder'] for x in chris_missing_tvdb]:
            chris_missing_tvdb.append({'folder': ep.show_folder, 'path': ep.path})

    # === Summary Report ===
    summary_file = output_dir / f'tv_comparison_summary_{timestamp}.txt'
    with open(summary_file, 'w') as f:
        f.write("=" * 80 + "\n")
        f.write("TV LIBRARY COMPARISON - PROJECT MOTHER\n")
        f.write(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write("=" * 80 + "\n\n")

        f.write("SHOW SUMMARY\n")
        f.write("-" * 50 + "\n")
        f.write(f"{'Total shows:':<30} {total_shows}\n")
        f.write(f"{'Ali only:':<30} {ali_only_shows}\n")
        f.write(f"{'Chris only:':<30} {chris_only_shows}\n")
        f.write(f"{'Both have:':<30} {both_shows}\n\n")

        f.write("EPISODE SUMMARY\n")
        f.write("-" * 50 + "\n")
        f.write(f"{'Ali total episodes:':<30} {total_ali_eps}\n")
        f.write(f"{'Chris total episodes:':<30} {total_chris_eps}\n")
        f.write(f"{'Ali unique episodes:':<30} {ali_only_eps}\n")
        f.write(f"{'Chris unique episodes:':<30} {chris_only_eps}\n")
        f.write(f"{'Episodes both have:':<30} {both_eps}\n\n")

        f.write("QUALITY COMPARISON (Episodes Both Have)\n")
        f.write("-" * 50 + "\n")
        f.write(f"{'Ali has better quality:':<30} {ali_better}\n")
        f.write(f"{'Chris has better quality:':<30} {chris_better}\n")
        f.write(f"{'Same quality (tie):':<30} {ties}\n\n")

        f.write("SYNC ACTIONS NEEDED\n")
        f.write("-" * 50 + "\n")
        f.write(f"{'Copy Ali -> Chris (unique):':<30} {ali_only_eps} episodes\n")
        f.write(f"{'Copy Chris -> Ali (unique):':<30} {chris_only_eps} episodes\n")
        f.write(f"{'Upgrade Ali -> Chris (better):':<30} {ali_better} episodes\n")
        f.write(f"{'Upgrade Chris -> Ali (better):':<30} {chris_better} episodes\n\n")

        # Missing TVDB - only show Ali's (Chris's deleted junk is ignored)
        if ali_missing_tvdb:
            f.write("\n" + "=" * 60 + "\n")
            f.write("ALI'S SHOWS MISSING TVDB ID (need to fix in Sonarr)\n")
            f.write("=" * 60 + "\n\n")

            for item in sorted(ali_missing_tvdb, key=lambda x: x['folder']):
                f.write(f"  Folder: {item['folder']}\n")
                f.write(f"  Path:   {item['path']}\n\n")

    print(f"Summary: {summary_file}")

    # === Detailed Report ===
    detail_file = output_dir / f'tv_comparison_detail_{timestamp}.txt'
    with open(detail_file, 'w') as f:
        f.write("=" * 80 + "\n")
        f.write("TV LIBRARY DETAILED COMPARISON\n")
        f.write("=" * 80 + "\n\n")

        # Shows only Ali has
        ali_only_list = [(k, s) for k, s in shows.items() if s.ali_episodes and not s.chris_episodes]
        if ali_only_list:
            f.write("\n" + "=" * 60 + "\n")
            f.write(f"SHOWS ONLY ALI HAS ({len(ali_only_list)} shows)\n")
            f.write("=" * 60 + "\n")
            for _, show in sorted(ali_only_list, key=lambda x: x[1].show_name):
                f.write(f"\n{show.show_name}\n")
                f.write(f"  TVDB: {show.tvdb_id or 'N/A'}\n")
                f.write(f"  Episodes: {len(show.ali_episodes)}\n")

        # Shows only Chris has
        chris_only_list = [(k, s) for k, s in shows.items() if s.chris_episodes and not s.ali_episodes]
        if chris_only_list:
            f.write("\n" + "=" * 60 + "\n")
            f.write(f"SHOWS ONLY CHRIS HAS ({len(chris_only_list)} shows)\n")
            f.write("=" * 60 + "\n")
            for _, show in sorted(chris_only_list, key=lambda x: x[1].show_name):
                f.write(f"\n{show.show_name}\n")
                f.write(f"  TVDB: {show.tvdb_id or 'N/A'}\n")
                f.write(f"  Episodes: {len(show.chris_episodes)}\n")

        # Shows both have with episode or quality differences
        both_list = [(k, s) for k, s in shows.items() if s.ali_episodes and s.chris_episodes]

        # Shows with quality differences (someone has better version)
        shows_with_quality_diff = []
        for k, s in both_list:
            ali_wins = sum(1 for r in s.episode_results if r.winner == 'ali')
            chris_wins = sum(1 for r in s.episode_results if r.winner == 'chris')
            if ali_wins > 0 or chris_wins > 0:
                shows_with_quality_diff.append((k, s, ali_wins, chris_wins))

        if shows_with_quality_diff:
            f.write("\n" + "=" * 60 + "\n")
            f.write(f"SHOWS WITH QUALITY DIFFERENCES ({len(shows_with_quality_diff)} shows)\n")
            f.write("=" * 60 + "\n")
            f.write("(These shows have episodes where one person has better quality)\n\n")

            for _, show, ali_wins, chris_wins in sorted(shows_with_quality_diff, key=lambda x: x[1].show_name):
                f.write(f"\n{show.show_name}\n")
                f.write(f"  TVDB: {show.tvdb_id or 'N/A'}\n")
                f.write(f"  Ali better: {ali_wins} episodes | Chris better: {chris_wins} episodes\n")

                # Show specific episodes with quality diff (first 5)
                quality_diffs = [r for r in show.episode_results if r.winner in ('ali', 'chris')]
                for r in quality_diffs[:5]:
                    f.write(f"    {r.ep_key}: {r.reason}\n")
                if len(quality_diffs) > 5:
                    f.write(f"    ... +{len(quality_diffs) - 5} more\n")

        # Shows with missing episodes
        shows_with_diff = [(k, s) for k, s in both_list if s.ali_only or s.chris_only]

        if shows_with_diff:
            f.write("\n" + "=" * 60 + "\n")
            f.write(f"SHOWS WITH MISSING EPISODES ({len(shows_with_diff)} shows)\n")
            f.write("=" * 60 + "\n")
            f.write("(These shows have episodes one person doesn't have at all)\n\n")

            for _, show in sorted(shows_with_diff, key=lambda x: x[1].show_name):
                f.write(f"\n{show.show_name}\n")
                f.write(f"  TVDB: {show.tvdb_id or 'N/A'}\n")

                if show.ali_only:
                    f.write(f"  Ali only ({len(show.ali_only)}): {', '.join(show.ali_only[:20])}")
                    if len(show.ali_only) > 20:
                        f.write(f" ... +{len(show.ali_only) - 20} more")
                    f.write("\n")

                if show.chris_only:
                    f.write(f"  Chris only ({len(show.chris_only)}): {', '.join(show.chris_only[:20])}")
                    if len(show.chris_only) > 20:
                        f.write(f" ... +{len(show.chris_only) - 20} more")
                    f.write("\n")

    print(f"Detail: {detail_file}")

    return {
        'summary': summary_file,
        'detail': detail_file,
        'stats': {
            'ali_only_eps': ali_only_eps,
            'chris_only_eps': chris_only_eps,
            'ali_better': ali_better,
            'chris_better': chris_better,
        }
    }


def generate_sync_script(shows: Dict[str, ShowComparison], output_dir: Path, timestamp: str):
    """Generate rsync script with progress tracking and error handling"""

    script_file = output_dir / f'tv_sync_actions_{timestamp}.sh'
    progress_file = f"tv_sync_progress_{timestamp}.log"
    error_log = f"tv_sync_errors_{timestamp}.log"

    with open(script_file, 'w') as f:
        f.write("#!/bin/bash\n")
        f.write("#" + "=" * 78 + "\n")
        f.write("# TV Library Sync Script - Project Mother\n")
        f.write(f"# Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write("#" + "=" * 78 + "\n")
        f.write("#\n")
        f.write("# Features:\n")
        f.write("#   - Progress tracking: completed commands are logged and skipped on re-run\n")
        f.write("#   - Error handling: failures logged with exit code, script continues\n")
        f.write("#   - Set EXIT_ON_ERROR=true to stop on first error\n")
        f.write("#   - Timestamps in log for monitoring with: tail -f <logfile>\n")
        f.write("#\n")
        f.write("# Usage:\n")
        f.write("#   ./tv_sync_actions_XXXXX.sh                    # Normal run (4 parallel)\n")
        f.write("#   PARALLEL=8 ./tv_sync_actions_XXXXX.sh         # 8 parallel transfers\n")
        f.write("#   PARALLEL=1 ./tv_sync_actions_XXXXX.sh         # Sequential (safe)\n")
        f.write("#   EXIT_ON_ERROR=true ./tv_sync_actions_XXXXX.sh # Stop on first error\n")
        f.write("#\n")
        f.write("# Bandwidth: 4 parallel = ~400 Mbps, 8 parallel = ~800 Mbps\n")
        f.write("#\n")
        f.write("#" + "=" * 78 + "\n\n")

        f.write("set -o pipefail\n\n")

        f.write(f'PROGRESS_FILE="${{PROGRESS_FILE:-{progress_file}}}"\n')
        f.write(f'ERROR_LOG="${{ERROR_LOG:-{error_log}}}"\n')
        f.write('EXIT_ON_ERROR="${EXIT_ON_ERROR:-false}"\n')
        f.write('PARALLEL="${PARALLEL:-4}"  # Number of parallel transfers\n\n')

        f.write('# Colors for output\n')
        f.write('RED="\\033[0;31m"\n')
        f.write('GREEN="\\033[0;32m"\n')
        f.write('YELLOW="\\033[0;33m"\n')
        f.write('NC="\\033[0m" # No Color\n\n')

        f.write('# Statistics\n')
        f.write('TOTAL=0\n')
        f.write('COMPLETED=0\n')
        f.write('SKIPPED=0\n')
        f.write('FAILED=0\n\n')

        f.write('log() {\n')
        f.write('    echo "[$(date "+%Y-%m-%d %H:%M:%S")] $1"\n')
        f.write('}\n\n')

        f.write('log_error() {\n')
        f.write('    echo "[$(date "+%Y-%m-%d %H:%M:%S")] ERROR: $1" | tee -a "$ERROR_LOG"\n')
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

        f.write('# Execute rsync with error handling (runs in background for parallel)\n')
        f.write('do_rsync() {\n')
        f.write('    local src="$1"\n')
        f.write('    local dst="$2"\n')
        f.write('    local desc="$3"\n')
        f.write('    local hash\n')
        f.write('    hash=$(echo "$src|$dst" | md5sum | cut -d" " -f1)\n')
        f.write('    \n')
        f.write('    ((TOTAL++))\n')
        f.write('    \n')
        f.write('    if is_completed "$hash"; then\n')
        f.write('        log "${YELLOW}SKIP${NC} [already done] $desc"\n')
        f.write('        ((SKIPPED++))\n')
        f.write('        return 0\n')
        f.write('    fi\n')
        f.write('    \n')
        f.write('    # Wait for a slot if running parallel\n')
        f.write('    if [ "$PARALLEL" -gt 1 ]; then\n')
        f.write('        wait_for_slot\n')
        f.write('    fi\n')
        f.write('    \n')
        f.write('    log "SYNC: $desc"\n')
        f.write('    \n')
        f.write('    # Create destination directory if needed\n')
        f.write('    local dst_dir\n')
        f.write('    dst_dir=$(dirname "$dst")\n')
        f.write('    mkdir -p "$dst_dir" 2>/dev/null\n')
        f.write('    \n')
        f.write('    # Run rsync (in background if parallel > 1)\n')
        f.write('    if [ "$PARALLEL" -gt 1 ]; then\n')
        f.write('        (\n')
        f.write('            if rsync -avh "$src" "$dst" 2>&1; then\n')
        f.write('                mark_completed "$hash"\n')
        f.write('                log "${GREEN}OK${NC}: $desc"\n')
        f.write('            else\n')
        f.write('                log_error "Failed: $desc"\n')
        f.write('            fi\n')
        f.write('        ) &\n')
        f.write('    else\n')
        f.write('        if rsync -avh --progress "$src" "$dst"; then\n')
        f.write('            mark_completed "$hash"\n')
        f.write('            log "${GREEN}OK${NC}: $desc"\n')
        f.write('            ((COMPLETED++))\n')
        f.write('        else\n')
        f.write('            local exit_code=$?\n')
        f.write('            log_error "Failed (exit $exit_code): $desc"\n')
        f.write('            log_error "  Source: $src"\n')
        f.write('            log_error "  Dest: $dst"\n')
        f.write('            ((FAILED++))\n')
        f.write('            \n')
        f.write('            if [ "$EXIT_ON_ERROR" = "true" ]; then\n')
        f.write('                log "${RED}Stopping due to EXIT_ON_ERROR=true${NC}"\n')
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

        f.write('log "Starting TV sync..."\n')
        f.write('log "Progress file: $PROGRESS_FILE"\n')
        f.write('log "Error log: $ERROR_LOG"\n')
        f.write('echo ""\n\n')

        # Generate sync commands
        ali_to_chris_unique = []  # Episodes only Ali has
        chris_to_ali_unique = []  # Episodes only Chris has
        ali_to_chris_upgrade = []  # Ali has better quality
        chris_to_ali_upgrade = []  # Chris has better quality

        for show in shows.values():
            for result in show.episode_results:
                if result.winner == 'ali_only' and result.ali_ep:
                    # Ali has episode Chris doesn't have
                    ep = result.ali_ep
                    src = translate_path_for_rsync(ep.path, 'ali')
                    dst_base = SYNOLOGY_PATHS['tv_1080p']
                    dst = f"{dst_base}/{ep.relative_path}"
                    ali_to_chris_unique.append((src, dst, f"[UNIQUE] {show.show_name} {result.ep_key}"))

                elif result.winner == 'chris_only' and result.chris_ep:
                    # Chris has episode Ali doesn't have
                    ep = result.chris_ep
                    src = ep.path
                    dst_base = UNRAID_PATHS['tv_1080p']
                    dst = f"{dst_base}/{ep.relative_path}"
                    chris_to_ali_unique.append((src, dst, f"[UNIQUE] {show.show_name} {result.ep_key}"))

                elif result.winner == 'ali' and result.ali_ep:
                    # Ali has better quality - upgrade Chris
                    ep = result.ali_ep
                    src = translate_path_for_rsync(ep.path, 'ali')
                    dst_base = SYNOLOGY_PATHS['tv_1080p']
                    dst = f"{dst_base}/{ep.relative_path}"
                    ali_to_chris_upgrade.append((src, dst, f"[UPGRADE] {show.show_name} {result.ep_key} ({ep.resolution}/{ep.source})"))

                elif result.winner == 'chris' and result.chris_ep:
                    # Chris has better quality - upgrade Ali
                    ep = result.chris_ep
                    src = ep.path
                    dst_base = UNRAID_PATHS['tv_1080p']
                    dst = f"{dst_base}/{ep.relative_path}"
                    chris_to_ali_upgrade.append((src, dst, f"[UPGRADE] {show.show_name} {result.ep_key} ({ep.resolution}/{ep.source})"))

        # Write sync commands
        f.write("#" + "=" * 78 + "\n")
        f.write(f"# COPY ALI -> CHRIS: UNIQUE EPISODES ({len(ali_to_chris_unique)})\n")
        f.write("#" + "=" * 78 + "\n\n")
        for src, dst, desc in ali_to_chris_unique:
            f.write(f'do_rsync "{src}" "{dst}" "{desc}"\n')

        f.write("\n#" + "=" * 78 + "\n")
        f.write(f"# COPY ALI -> CHRIS: QUALITY UPGRADES ({len(ali_to_chris_upgrade)})\n")
        f.write("#" + "=" * 78 + "\n\n")
        for src, dst, desc in ali_to_chris_upgrade:
            f.write(f'do_rsync "{src}" "{dst}" "{desc}"\n')

        f.write("\n#" + "=" * 78 + "\n")
        f.write(f"# COPY CHRIS -> ALI: UNIQUE EPISODES ({len(chris_to_ali_unique)})\n")
        f.write("#" + "=" * 78 + "\n\n")
        for src, dst, desc in chris_to_ali_unique:
            f.write(f'do_rsync "{src}" "{dst}" "{desc}"\n')

        f.write("\n#" + "=" * 78 + "\n")
        f.write(f"# COPY CHRIS -> ALI: QUALITY UPGRADES ({len(chris_to_ali_upgrade)})\n")
        f.write("#" + "=" * 78 + "\n\n")
        for src, dst, desc in chris_to_ali_upgrade:
            f.write(f'do_rsync "{src}" "{dst}" "{desc}"\n')

        f.write('\n# Wait for all parallel jobs to complete\n')
        f.write('if [ "$PARALLEL" -gt 1 ]; then\n')
        f.write('    log "Waiting for parallel transfers to complete..."\n')
        f.write('    wait\n')
        f.write('fi\n')
        f.write('\nlog "Sync complete!"\n')

    # Make executable
    script_file.chmod(0o755)

    print(f"Sync script: {script_file}")
    return script_file


###############################################################################
# Main
###############################################################################

def main():
    parser = argparse.ArgumentParser(
        description='Compare TV libraries - Project Mother'
    )
    parser.add_argument('ali_inventory', type=Path, help="Ali's TV inventory JSON")
    parser.add_argument('chris_inventory', type=Path, help="Chris's TV inventory JSON")
    parser.add_argument('-o', '--output-dir', type=Path, default=Path('.'), help='Output directory')

    args = parser.parse_args()

    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')

    print(f"Loading Ali's inventory: {args.ali_inventory}")
    ali_episodes = load_tv_inventory(args.ali_inventory)
    print(f"  Loaded {len(ali_episodes)} episodes")

    print(f"Loading Chris's inventory: {args.chris_inventory}")
    chris_episodes = load_tv_inventory(args.chris_inventory)
    print(f"  Loaded {len(chris_episodes)} episodes")

    print("\nComparing libraries...")
    shows = compare_libraries(ali_episodes, chris_episodes)
    print(f"  Found {len(shows)} unique shows")

    print("\nGenerating reports...")
    reports = generate_reports(shows, args.output_dir, timestamp, ali_episodes, chris_episodes)

    print("\nGenerating sync script...")
    generate_sync_script(shows, args.output_dir, timestamp)

    # Print quick summary
    print("\n" + "=" * 50)
    print("UNIQUE EPISODES (one person doesn't have):")
    print(f"  Copy Ali -> Chris: {reports['stats']['ali_only_eps']}")
    print(f"  Copy Chris -> Ali: {reports['stats']['chris_only_eps']}")
    print("\nQUALITY UPGRADES (both have, but one is better):")
    print(f"  Upgrade Chris with Ali's: {reports['stats']['ali_better']}")
    print(f"  Upgrade Ali with Chris's: {reports['stats']['chris_better']}")
    print("=" * 50)


if __name__ == '__main__':
    main()
