#!/bin/bash
#==============================================================================
# Project Mother Sync Script
# RUN THIS ON MOTHER (10.0.0.162)
#==============================================================================
# Generated: 2025-12-31 17:18:04
#
# Features:
#   - Progress tracking: completed commands are logged and skipped on re-run
#   - Error handling: failures logged with exit code, script continues
#   - Set EXIT_ON_ERROR=true to stop on first error
#   - Timestamps in log for monitoring with: tail -f <logfile>
#
# This script uses Mother's mount paths:
#   Synology: /mnt/synology/rs-*
#   Unraid:   /mnt/unraid/media/*
#
# Usage:
#   ./sync_actions_XXXXX.sh                    # Normal run (4 parallel)
#   PARALLEL=8 ./sync_actions_XXXXX.sh         # 8 parallel transfers
#   PARALLEL=1 ./sync_actions_XXXXX.sh         # Sequential (safe)
#   EXIT_ON_ERROR=true ./sync_actions_XXXXX.sh # Stop on first error
#   DRY_RUN=true ./sync_actions_XXXXX.sh       # Preview only
#
# Bandwidth: 4 parallel = ~400 Mbps, 8 parallel = ~800 Mbps
#
#==============================================================================

set -o pipefail

PROGRESS_FILE="${PROGRESS_FILE:-sync_progress_20251231_171804.log}"
ERROR_LOG="${ERROR_LOG:-sync_errors_20251231_171804.log}"
EXIT_ON_ERROR="${EXIT_ON_ERROR:-false}"
DRY_RUN="${DRY_RUN:-false}"
PARALLEL="${PARALLEL:-4}"  # Number of parallel transfers

# Colors for output
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

# Statistics
TOTAL=0
COMPLETED=0
SKIPPED=0
FAILED=0

log() {
    echo -e "[$(date "+%Y-%m-%d %H:%M:%S")] $1"
}

log_error() {
    echo -e "[$(date "+%Y-%m-%d %H:%M:%S")] ${RED}ERROR${NC}: $1" | tee -a "$ERROR_LOG"
}

# Check if command was already completed
is_completed() {
    local hash="$1"
    grep -q "^$hash$" "$PROGRESS_FILE" 2>/dev/null
}

# Mark command as completed
mark_completed() {
    local hash="$1"
    echo "$hash" >> "$PROGRESS_FILE"
}

# Semaphore for parallel execution
wait_for_slot() {
    while [ $(jobs -r | wc -l) -ge $PARALLEL ]; do
        sleep 0.5
    done
}

# Execute command with progress tracking
run_cmd() {
    local desc="$1"
    shift
    local hash
    hash=$(echo "$@" | md5sum | cut -d" " -f1)
    
    ((TOTAL++))
    
    if is_completed "$hash"; then
        log "${YELLOW}SKIP${NC} [already done] $desc"
        ((SKIPPED++))
        return 0
    fi
    
    if [ "$DRY_RUN" = "true" ]; then
        log "${BLUE}[DRY RUN]${NC} $desc"
        log "  Command: $@"
        ((COMPLETED++))
        return 0
    fi
    
    # Wait for a slot if running parallel
    if [ "$PARALLEL" -gt 1 ]; then
        wait_for_slot
    fi
    
    log "RUNNING: $desc"
    
    # Run in background if parallel > 1
    if [ "$PARALLEL" -gt 1 ]; then
        (
            if "$@" 2>&1; then
                mark_completed "$hash"
                log "${GREEN}OK${NC}: $desc"
            else
                log_error "Failed: $desc"
            fi
        ) &
    else
        if "$@"; then
            mark_completed "$hash"
            log "${GREEN}OK${NC}: $desc"
            ((COMPLETED++))
        else
            local exit_code=$?
            log_error "Failed (exit $exit_code): $desc"
            log_error "  Command: $@"
            ((FAILED++))
            
            if [ "$EXIT_ON_ERROR" = "true" ]; then
                log "${RED}Stopping due to EXIT_ON_ERROR=true${NC}"
                print_summary
                exit $exit_code
            fi
        fi
    fi
}

# Print summary
print_summary() {
    echo ""
    echo "========================================"
    echo "SYNC SUMMARY"
    echo "========================================"
    echo "Total:     $TOTAL"
    echo -e "Completed: ${GREEN}$COMPLETED${NC}"
    echo -e "Skipped:   ${YELLOW}$SKIPPED${NC}"
    echo -e "Failed:    ${RED}$FAILED${NC}"
    echo "========================================"
    if [ $FAILED -gt 0 ]; then
        echo "See $ERROR_LOG for failure details"
    fi
}

trap print_summary EXIT

log "Starting sync..."
log "Progress file: $PROGRESS_FILE"
log "Error log: $ERROR_LOG"
if [ "$DRY_RUN" = "true" ]; then
    log "${BLUE}DRY RUN MODE - no changes will be made${NC}"
fi
echo ""

# === MOVE TO DELETED FOLDERS ===

run_cmd "Move Chris lower quality: Gladiator (2000)" mv "/mnt/synology/rs-4kmedia/4kmovies/Gladiator (2000)/Gladiator (2000) {tmdb-98} - {edition-Extended} [Remux-2160p][DTS-X 7.1][HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: War for the Planet of the Apes (2017)" mv "/mnt/synology/rs-4kmedia/4kmovies/War for the Planet of the Apes (2017)/War for the Planet of the Apes (2017) {tmdb-281338} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-Absinth.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Avengers Endgame (2019)" mv "/mnt/synology/rs-4kmedia/4kmovies/Avengers Endgame (2019)/Avengers Endgame (2019) {tmdb-299534} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Mad Max Fury Road (2015)" mv "/mnt/synology/rs-4kmedia/4kmovies/Mad Max Fury Road (2015)/Mad Max Fury Road (2015) {tmdb-76341} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-BluDragon.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Ali lower quality: Top Gun (1986)" mv "/mnt/unraid/media/4K Movies/Top Gun (1986)/Top Gun (1986) {tmdb-744} - [Bluray-2160p][EAC3 7.1][DV HDR10][x265]-hallowed.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Chris lower quality: Pitch Black (2000)" mv "/mnt/synology/rs-4kmedia/4kmovies/Pitch Black (2000)/Pitch Black (2000) {tmdb-2787} - {edition-Directors Cut} [Bluray-2160p Proper][DTS-HD MA 5.1][HDR10][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Alien Romulus (2024)" mv "/mnt/synology/rs-4kmedia/4kmovies/Alien Romulus (2024)/Alien Romulus (2024) {tmdb-945961} - [WEBDL-2160p][EAC3 Atmos 5.1][DV HDR10Plus][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Ali lower quality: Fast and Furious 6 (2013)" mv "/mnt/unraid/media/4K Movies/Fast and Furious 6 (2013)/Fast and Furious 6 (2013) {tmdb-82992} - {edition-Extended} [Bluray-2160p Proper][DTS-HD MA 5.1][HDR10][x265]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Chris lower quality: Wonder Woman (2017)" mv "/mnt/synology/rs-4kmedia/4kmovies/Wonder Woman (2017)/Wonder Woman (2017) {tmdb-297762} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Captain America The First Avenger (2011)" mv "/mnt/synology/rs-4kmedia/4kmovies/Captain America The First Avenger (2011)/Captain America The First Avenger (2011) {tmdb-1771} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-Absinth.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Guardians of the Galaxy (2014)" mv "/mnt/synology/rs-4kmedia/4kmovies/Guardians of the Galaxy (2014)/Guardians of the Galaxy (2014) {tmdb-118340} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Ali lower quality: Close Encounters of the Third Kind (1977)" mv "/mnt/unraid/media/4K Movies/Close Encounters of the Third Kind (1977)/Close Encounters of the Third Kind (1977) {tmdb-840} - {edition-Directors Cut} [Bluray-2160p][AC3 5.1][DV HDR10][x265]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Hunger Games Mockingjay Part 2 (2015)" mv "/mnt/unraid/media/4K Movies/The Hunger Games Mockingjay Part 2 (2015)/The Hunger Games Mockingjay Part 2 (2015) {tmdb-131634} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Chris lower quality: The Matrix Resurrections (2021)" mv "/mnt/synology/rs-4kmedia/4kmovies/The Matrix Resurrections (2021)/The Matrix Resurrections (2021) {tmdb-624860} - [WEBDL-2160p][EAC3 Atmos 5.1][DV HDR10][x265].mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Ali lower quality: Deadpool 2 (2018)" mv "/mnt/unraid/media/4K Movies/Deadpool 2 (2018)/Deadpool 2 (2018) {tmdb-383498} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-MainFrame.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Chris lower quality: V for Vendetta (2006)" mv "/mnt/synology/rs-4kmedia/4kmovies/V for Vendetta (2006)/V for Vendetta (2006) {tmdb-752} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Avengers Infinity War (2018)" mv "/mnt/synology/rs-4kmedia/4kmovies/Avengers Infinity War (2018)/Avengers Infinity War (2018) {tmdb-299536} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Ali lower quality: Mortal Kombat (2021)" mv "/mnt/unraid/media/4K Movies/Mortal Kombat (2021)/Mortal Kombat (2021) {tmdb-460465} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-HQMUX.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Chris lower quality: Indiana Jones and the Kingdom of the Crystal Skull (2008)" mv "/mnt/synology/rs-4kmedia/4kmovies/Indiana Jones and the Kingdom of the Crystal Skull (2008)/Indiana Jones and the Kingdom of the Crystal Skull (2008) {tmdb-217} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-10bit-HDS.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: The Dark Knight (2008)" mv "/mnt/synology/rs-4kmedia/4kmovies/The Dark Knight (2008)/The Dark Knight (2008) {tmdb-155} - [Remux-2160p][DTS-HD MA 5.1][HDR10][HEVC]-BluDragon.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: The Lord of the Rings The Fellowship of the Ring (2001)" mv "/mnt/synology/rs-4kmedia/4kmovies/The Lord of the Rings The Fellowship of the Ring (2001)/The Lord of the Rings The Fellowship of the Ring (2001) {tmdb-120} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][h265].mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Batman Begins (2005)" mv "/mnt/synology/rs-4kmedia/4kmovies/Batman Begins (2005)/Batman Begins (2005) {tmdb-272} - [Remux-2160p][DTS-HD MA 5.1][HDR10][HEVC]-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Star Trek Into Darkness (2013)" mv "/mnt/synology/rs-4kmedia/4kmovies/Star Trek Into Darkness (2013)/Star Trek Into Darkness (2013) {tmdb-54138} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: The Suicide Squad (2021)" mv "/mnt/synology/rs-4kmedia/4kmovies/The Suicide Squad (2021)/The Suicide Squad (2021) {tmdb-436969} - [Bluray-2160p][AC3 5.1][HDR10Plus][x265]-BHDStudio.mp4" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Ali lower quality: Star Trek V The Final Frontier (1989)" mv "/mnt/unraid/media/4K Movies/Star Trek V The Final Frontier (1989)/Star Trek V The Final Frontier (1989) {tmdb-172} - [Bluray-2160p][EAC3 7.1][DV HDR10][x265]-hallowed.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Chris lower quality: Wonder Woman 1984 (2020)" mv "/mnt/synology/rs-4kmedia/4kmovies/Wonder Woman 1984 (2020)/Wonder Woman 1984 (2020) {tmdb-464052} - [HMAX][WEBDL-2160p][EAC3 Atmos 5.1][HDR10][HEVC]-TOMMY.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: 300 (2007)" mv "/mnt/synology/rs-4kmedia/4kmovies/300 (2007)/300 (2007) {tmdb-1271} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Heat (1995)" mv "/mnt/synology/rs-4kmedia/4kmovies/Heat (1995)/Heat (1995) {tmdb-949} - {edition-Directors} [WEBDL-2160p][DTS-HD MA 5.1][HDR10][HEVC]-BLUTONiUM.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Kingdom of Heaven (2005)" mv "/mnt/synology/rs-4kmedia/4kmovies/Kingdom of Heaven (2005)/Kingdom of Heaven (2005) {tmdb-1495} - {edition-Theatrical} [WEBDL-2160p][EAC3 5.1][HDR10][h265]-SMURF.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Ali lower quality: The Hunger Games Catching Fire (2013)" mv "/mnt/unraid/media/4K Movies/The Hunger Games Catching Fire (2013)/The Hunger Games Catching Fire (2013) {tmdb-101299} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Rocketman (2019)" mv "/mnt/unraid/media/4K Movies/Rocketman (2019)/Rocketman (2019) {tmdb-504608} - [Bluray-2160p][EAC3 7.1][DV HDR10][x265]-HONE.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Chris lower quality: Interstellar (2014)" mv "/mnt/synology/rs-4kmedia/4kmovies/Interstellar (2014)/Interstellar (2014) {tmdb-157336} - [Bluray-2160p][DTS-HD MA 5.1][HDR10][x265]-TERMiNAL.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: John Wick (2014)" mv "/mnt/synology/rs-4kmedia/4kmovies/John Wick (2014)/John Wick (2014) {tmdb-245891} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-Absinth.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Deadpool and Wolverine (2024)" mv "/mnt/synology/rs-4kmedia/4kmovies/Deadpool and Wolverine (2024)/Deadpool and Wolverine (2024) {tmdb-533535} - [WEBDL-2160p][EAC3 Atmos 5.1][DV HDR10Plus][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: The Avengers (2012)" mv "/mnt/synology/rs-4kmedia/4kmovies/The Avengers (2012)/The Avengers (2012) {tmdb-24428} - [Remux-2160p Proper][TrueHD Atmos 7.1][HDR10][HEVC]-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Ali lower quality: John Wick Chapter 2 (2017)" mv "/mnt/unraid/media/4K Movies/John Wick Chapter 2 (2017)/John Wick Chapter 2 (2017) {tmdb-324552} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-SPHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Chris lower quality: The Hunt for Red October (1990)" mv "/mnt/synology/rs-4kmedia/4kmovies/The Hunt for Red October (1990)/The Hunt for Red October (1990) {tmdb-1669} - [Bluray-2160p][TrueHD 5.1][HDR10][x265]-HQMUX.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Inception (2010)" mv "/mnt/synology/rs-4kmedia/4kmovies/Inception (2010)/Inception (2010) {tmdb-27205} - [Bluray-2160p][DTS-HD MA 5.1][PQ][x265]-TERMiNAL.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Logan (2017)" mv "/mnt/synology/rs-4kmedia/4kmovies/Logan (2017)/Logan (2017) {tmdb-263115} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-TERMiNAL.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Red Sparrow (2018)" mv "/mnt/synology/rs-4kmedia/4kmovies/Red Sparrow (2018)/Red Sparrow (2018) {tmdb-401981} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-WhiteRhino.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Iron Man 3 (2013)" mv "/mnt/synology/rs-4kmedia/4kmovies/Iron Man 3 (2013)/Iron Man 3 (2013) {tmdb-68721} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Twister (1996)" mv "/mnt/synology/rs-4kmedia/4kmovies/Twister (1996)/Twister (1996) {tmdb-664} - [Remux-1080p][TrueHD Atmos 7.1][x264].mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: The Matrix Revolutions (2003)" mv "/mnt/synology/rs-4kmedia/4kmovies/The Matrix Revolutions (2003)/The Matrix Revolutions (2003) {tmdb-605} - [Bluray-2160p][EAC3 5.1][HDR10][x265]-d3g.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Ali lower quality: Captain Marvel (2019)" mv "/mnt/unraid/media/4K Movies/Captain Marvel (2019)/Captain Marvel (2019) {tmdb-299537} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Chris lower quality: The Lost World Jurassic Park (1997)" mv "/mnt/synology/rs-4kmedia/4kmovies/The Lost World Jurassic Park (1997)/The Lost World Jurassic Park (1997) {tmdb-330} - [Bluray-2160p][AC3 5.1][HDR10][x265]-BHDStudio.mp4" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Alien (1979)" mv "/mnt/synology/rs-4kmedia/4kmovies/Alien (1979)/Alien (1979) {tmdb-348} - [Bluray-2160p][DTS-HD MA 5.1][HDR10][x265]-IAMABLE.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Iron Man 2 (2010)" mv "/mnt/synology/rs-4kmedia/4kmovies/Iron Man 2 (2010)/Iron Man 2 (2010) {tmdb-10138} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-Absinth.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Ali lower quality: Deadpool (2016)" mv "/mnt/unraid/media/4K Movies/Deadpool (2016)/Deadpool (2016) {tmdb-293660} - [Hybrid][Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-SEV.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Shazam! Fury of the Gods (2023)" mv "/mnt/unraid/media/4K Movies/Shazam! Fury of the Gods (2023)/Shazam! Fury of the Gods (2023) {tmdb-594767} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Ad Astra (2019)" mv "/mnt/unraid/media/4K Movies/Ad Astra (2019)/Ad Astra (2019) {tmdb-419704} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-KeYBLaDE.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Chris lower quality: Tenet (2020)" mv "/mnt/synology/rs-4kmedia/4kmovies/Tenet (2020)/Tenet (2020) {tmdb-577922} - [Bluray-2160p Proper][DTS-HD MA 5.1][HDR10][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: The Revenant (2015)" mv "/mnt/synology/rs-4kmedia/4kmovies/The Revenant (2015)/The Revenant (2015) {tmdb-281957} - [Remux-2160p][DTS-HD MA 7.1][HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: The Lord of the Rings The Two Towers (2002)" mv "/mnt/synology/rs-4kmedia/4kmovies/The Lord of the Rings The Two Towers (2002)/The Lord of the Rings The Two Towers (2002) {tmdb-121} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][h265].mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Ali lower quality: Star Wars (1977)" mv "/mnt/unraid/media/4K Movies/Star Wars (1977)/Star Wars (1977) {tmdb-11} - [Hybrid][Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-HiDt.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Star Trek The Motion Picture (1979)" mv "/mnt/unraid/media/4K Movies/Star Trek The Motion Picture (1979)/Star Trek The Motion Picture (1979) {tmdb-152} - [Bluray-2160p][TrueHD Atmos 7.1][DV][x265]-VD0N.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Chris lower quality: Passengers (2016)" mv "/mnt/synology/rs-4kmedia/4kmovies/Passengers (2016)/Passengers (2016) {tmdb-274870} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Spider-Man No Way Home (2021)" mv "/mnt/synology/rs-4kmedia/4kmovies/Spider-Man No Way Home (2021)/Spider-Man No Way Home (2021) {tmdb-634649} - [WEBDL-2160p][AC3 5.1][h265].mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Black Panther Wakanda Forever (2022)" mv "/mnt/synology/rs-4kmedia/4kmovies/Black Panther Wakanda Forever (2022)/Black Panther Wakanda Forever (2022) {tmdb-505642} - [Bluray-2160p][EAC3 7.1][DV HDR10][x265]-HONE.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Black Widow (2021)" mv "/mnt/synology/rs-4kmedia/4kmovies/Black Widow (2021)/Black Widow (2021) {tmdb-497698} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-HDChina.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Ali lower quality: The Hunger Games Mockingjay Part 1 (2014)" mv "/mnt/unraid/media/4K Movies/The Hunger Games Mockingjay Part 1 (2014)/The Hunger Games Mockingjay Part 1 (2014) {tmdb-131631} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Chris lower quality: Indiana Jones and the Temple of Doom (1984)" mv "/mnt/synology/rs-4kmedia/4kmovies/Indiana Jones and the Temple of Doom (1984)/Indiana Jones and the Temple of Doom (1984) {tmdb-87} - [Bluray-2160p][AC3 5.1][HDR10][x265]-seskapile.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Star Trek IV The Voyage Home (1986)" mv "/mnt/synology/rs-4kmedia/4kmovies/Star Trek IV The Voyage Home (1986)/Star Trek IV The Voyage Home (1986) {tmdb-168} - [Bluray-2160p][AC3 5.1][HDR10][x265]-BHDStudio.mp4" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Ali lower quality: The Matrix (1999)" mv "/mnt/unraid/media/4K Movies/The Matrix (1999)/The Matrix (1999) {tmdb-603} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Chris lower quality: Star Trek First Contact (1996)" mv "/mnt/synology/rs-4kmedia/4kmovies/Star Trek First Contact (1996)/Star Trek First Contact (1996) {tmdb-199} - [WEBDL-2160p][EAC3 5.1][x265]-ABBiE.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Pacific Rim (2013)" mv "/mnt/synology/rs-4kmedia/4kmovies/Pacific Rim (2013)/Pacific Rim (2013) {tmdb-68726} - [Bluray-2160p][AC3 5.1][HDR10][x265]-BHDStudio.mp4" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Hacksaw Ridge (2016)" mv "/mnt/synology/rs-4kmedia/4kmovies/Hacksaw Ridge (2016)/Hacksaw Ridge (2016) {tmdb-324786} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-TERMiNAL.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: The Matrix Reloaded (2003)" mv "/mnt/synology/rs-4kmedia/4kmovies/The Matrix Reloaded (2003)/The Matrix Reloaded (2003) {tmdb-604} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Army of the Dead (2021)" mv "/mnt/synology/rs-4kmedia/4kmovies/Army of the Dead (2021)/Army of the Dead (2021) {tmdb-503736} - [NF][WEBRip-2160p][EAC3 Atmos 5.1][HDR10][x265]-TrollUHD-FZ.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Top Gun Maverick (2022)" mv "/mnt/synology/rs-4kmedia/4kmovies/Top Gun Maverick (2022)/Top Gun Maverick (2022) {tmdb-361743} - [WEBDL-2160p][EAC3 Atmos 5.1][DV HDR10Plus][h265].mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Ali lower quality: Jaws (1975)" mv "/mnt/unraid/media/4K Movies/Jaws (1975)/Jaws (1975) {tmdb-578} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-HQMUX.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Chris lower quality: 2001 A Space Odyssey (1968)" mv "/mnt/synology/rs-4kmedia/4kmovies/2001 A Space Odyssey (1968)/2001 A Space Odyssey (1968) {tmdb-62} - [Remux-2160p Proper][DTS-HD MA 5.1][HDR10][HEVC]-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Ali lower quality: Return of the Jedi (1983)" mv "/mnt/unraid/media/4K Movies/Return of the Jedi (1983)/Return of the Jedi (1983) {tmdb-1892} - [Hybrid][Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-HiDt.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Chris lower quality: The Predator (2018)" mv "/mnt/synology/rs-4kmedia/4kmovies/The Predator (2018)/The Predator (2018) {tmdb-346910} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-BluDragon.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Ghostbusters (1984)" mv "/mnt/synology/rs-4kmedia/4kmovies/Ghostbusters (1984)/Ghostbusters (1984) {tmdb-620} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Braveheart (1995)" mv "/mnt/synology/rs-4kmedia/4kmovies/Braveheart (1995)/Braveheart (1995) {tmdb-197} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-IAMABLE.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Ali lower quality: Joker (2019)" mv "/mnt/unraid/media/4K Movies/Joker (2019)/Joker (2019) {tmdb-475557} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-MgB.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Star Trek VI The Undiscovered Country (1991)" mv "/mnt/unraid/media/4K Movies/Star Trek VI The Undiscovered Country (1991)/Star Trek VI The Undiscovered Country (1991) {tmdb-174} - {edition-Theatrical Cut} [Bluray-2160p][EAC3 7.1][DV HDR10][x265]-hallowed.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Chris lower quality: Solo A Star Wars Story (2018)" mv "/mnt/synology/rs-4kmedia/4kmovies/Solo A Star Wars Story (2018)/Solo A Star Wars Story (2018) {tmdb-348350} - [Bluray-2160p Proper][TrueHD Atmos 7.1][HDR10][x265]-TnP.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: The Lord of the Rings The Return of the King (2003)" mv "/mnt/synology/rs-4kmedia/4kmovies/The Lord of the Rings The Return of the King (2003)/The Lord of the Rings The Return of the King (2003) {tmdb-122} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][h265].mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Twisters (2024)" mv "/mnt/synology/rs-4kmedia/4kmovies/Twisters (2024)/Twisters (2024) {tmdb-718821} - [WEBDL-2160p][EAC3 Atmos 5.1][DV HDR10Plus][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Thor Ragnarok (2017)" mv "/mnt/synology/rs-4kmedia/4kmovies/Thor Ragnarok (2017)/Thor Ragnarok (2017) {tmdb-284053} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10Plus][x265]-UnKn0wn.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Blade (1998)" mv "/mnt/synology/rs-4kmedia/4kmovies/Blade (1998)/Blade (1998) {tmdb-36647} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265].mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Zombieland (2009)" mv "/mnt/synology/rs-4kmedia/4kmovies/Zombieland (2009)/Zombieland (2009) {tmdb-19908} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-IAMABLE.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Star Trek II The Wrath of Khan (1982)" mv "/mnt/synology/rs-4kmedia/4kmovies/Star Trek II The Wrath of Khan (1982)/Star Trek II The Wrath of Khan (1982) {tmdb-154} - {edition-Director's Cut} [Bluray-2160p][AC3 5.1][HDR10][x265]-BHDStudio.mp4" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Avatar The Way of Water (2022)" mv "/mnt/synology/rs-4kmedia/4kmovies/Avatar The Way of Water (2022)/Avatar The Way of Water (2022) {tmdb-76600} - [WEBDL-2160p][EAC3 Atmos 5.1][h265].mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Black Adam (2022)" mv "/mnt/synology/rs-4kmedia/4kmovies/Black Adam (2022)/Black Adam (2022) {tmdb-436270} - [WEBDL-2160p Proper][EAC3 Atmos 5.1][DV HDR10][h265].mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Ali lower quality: The Hunger Games (2012)" mv "/mnt/unraid/media/4K Movies/The Hunger Games (2012)/The Hunger Games (2012) {tmdb-70160} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Jungle Cruise (2021)" mv "/mnt/unraid/media/4K Movies/Jungle Cruise (2021)/Jungle Cruise (2021) {tmdb-451048} - [Bluray-2160p][AC3 5.1][HDR10][x265]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Dune (2021)" mv "/mnt/unraid/media/4K Movies/Dune (2021)/Dune (2021) {tmdb-438631} - [Bluray-2160p Proper][TrueHD Atmos 7.1][DV HDR10Plus][x265]-W4NK3R.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Furious 7 (2015)" mv "/mnt/unraid/media/4K Movies/Furious 7 (2015)/Furious 7 (2015) {tmdb-168259} - {edition-Extended} [Bluray-2160p][DTS-HD HRA 7.1][HDR10][x265]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Bohemian Rhapsody (2018)" mv "/mnt/unraid/media/4K Movies/Bohemian Rhapsody (2018)/Bohemian Rhapsody (2018) {tmdb-424694} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10Plus][x265]-W4NK3R.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Chris lower quality: Iron Man (2008)" mv "/mnt/synology/rs-4kmedia/4kmovies/Iron Man (2008)/Iron Man (2008) {tmdb-1726} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-4K4U.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Earth One Amazing Day (2017)" mv "/mnt/synology/rs-4kmedia/4kmovies/Earth One Amazing Day (2017)/Earth One Amazing Day (2017) {tmdb-464593} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Raiders of the Lost Ark (1981)" mv "/mnt/synology/rs-4kmedia/4kmovies/Raiders of the Lost Ark (1981)/Raiders of the Lost Ark (1981) {tmdb-85} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-4K4U.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Apocalypse Now (1979)" mv "/mnt/synology/rs-4kmedia/4kmovies/Apocalypse Now (1979)/Apocalypse Now (1979) {tmdb-28} - [Bluray-2160p][TrueHD 5.1][HDR10][x265]-JustWatch.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Dunkirk (2017)" mv "/mnt/synology/rs-4kmedia/4kmovies/Dunkirk (2017)/Dunkirk (2017) {tmdb-374720} - [Bluray-2160p][DTS 5.1][HDR10][x265]-SadeceBluRay.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: The Dark Knight Rises (2012)" mv "/mnt/synology/rs-4kmedia/4kmovies/The Dark Knight Rises (2012)/The Dark Knight Rises (2012) {tmdb-49026} - [Remux-2160p][DTS-HD MA 5.1][HDR10][HEVC]-BluDragon.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Avengers Age of Ultron (2015)" mv "/mnt/synology/rs-4kmedia/4kmovies/Avengers Age of Ultron (2015)/Avengers Age of Ultron (2015) {tmdb-99861} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-Absinth.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Bram Stokers Dracula (1992)" mv "/mnt/synology/rs-4kmedia/4kmovies/Bram Stokers Dracula (1992)/Bram Stokers Dracula (1992) {tmdb-6114} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-BluDragon.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Guardians of the Galaxy Vol. 2 (2017)" mv "/mnt/synology/rs-4kmedia/4kmovies/Guardians of the Galaxy Vol. 2 (2017)/Guardians of the Galaxy Vol. 2 (2017) {tmdb-283995} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-TERMiNAL.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Captain America Civil War (2016)" mv "/mnt/synology/rs-4kmedia/4kmovies/Captain America Civil War (2016)/Captain America Civil War (2016) {tmdb-271110} - [Bluray-2160p][EAC3 7.1][DV HDR10][x265]-HONE.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Star Trek III The Search for Spock (1984)" mv "/mnt/synology/rs-4kmedia/4kmovies/Star Trek III The Search for Spock (1984)/Star Trek III The Search for Spock (1984) {tmdb-157} - [Bluray-2160p][AC3 5.1][HDR10][x265]-BHDStudio.mp4" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Jurassic Park (1993)" mv "/mnt/synology/rs-4kmedia/4kmovies/Jurassic Park (1993)/Jurassic Park (1993) {tmdb-329} - [Bluray-2160p][AC3 5.1][HDR10][x265]-BHDStudio.mp4" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

run_cmd "Move Chris lower quality: Uncharted (2022)" mv "/mnt/synology/rs-4kmedia/4kmovies/Uncharted (2022)/Uncharted (2022) {tmdb-335787} - [WEBDL-2160p][EAC3 Atmos 5.1][h265].mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"


# === COPY BETTER QUALITY FILES ===

run_cmd "Copy Ali->Chris: Gladiator (2000)" rsync -avhP "/mnt/unraid/media/4K Movies/Gladiator (2000)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Venom The Last Dance (2024)" rsync -avhP "/mnt/unraid/media/4K Movies/Venom The Last Dance (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Mummy Returns (2001)" rsync -avhP "/mnt/unraid/media/4K Movies/The Mummy Returns (2001)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Warfare (2025)" rsync -avhP "/mnt/unraid/media/4K Movies/Warfare (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: War for the Planet of the Apes (2017)" rsync -avhP "/mnt/unraid/media/4K Movies/War for the Planet of the Apes (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Avengers Endgame (2019)" rsync -avhP "/mnt/unraid/media/4K Movies/Avengers Endgame (2019)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Mad Max Fury Road (2015)" rsync -avhP "/mnt/unraid/media/4K Movies/Mad Max Fury Road (2015)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: Top Gun (1986)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Top Gun (1986)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: Pitch Black (2000)" rsync -avhP "/mnt/unraid/media/4K Movies/Pitch Black (2000)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Indiana Jones and the Dial of Destiny (2023)" rsync -avhP "/mnt/unraid/media/4K Movies/Indiana Jones and the Dial of Destiny (2023)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Life of Pi (2012)" rsync -avhP "/mnt/unraid/media/4K Movies/Life of Pi (2012)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Alien Romulus (2024)" rsync -avhP "/mnt/unraid/media/4K Movies/Alien Romulus (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: Independence Day (1996)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Independence Day (1996)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Chris->Ali: Fast and Furious 6 (2013)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Fast and Furious 6 (2013)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: Civil War (2024)" rsync -avhP "/mnt/unraid/media/4K Movies/Civil War (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Wonder Woman (2017)" rsync -avhP "/mnt/unraid/media/4K Movies/Wonder Woman (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: Resident Evil Welcome to Raccoon City (2021)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Resident Evil Welcome to Raccoon City (2021)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: Cars (2006)" rsync -avhP "/mnt/unraid/media/4K Movies/Cars (2006)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Captain America The First Avenger (2011)" rsync -avhP "/mnt/unraid/media/4K Movies/Captain America The First Avenger (2011)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Guardians of the Galaxy (2014)" rsync -avhP "/mnt/unraid/media/4K Movies/Guardians of the Galaxy (2014)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: Doctor Strange in the Multiverse of Madness (2022)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Doctor Strange in the Multiverse of Madness (2022)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Chris->Ali: Close Encounters of the Third Kind (1977)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Close Encounters of the Third Kind (1977)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: Mission Impossible III (2006)" rsync -avhP "/mnt/unraid/media/4K Movies/Mission Impossible III (2006)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Star Trek Nemesis (2002)" rsync -avhP "/mnt/unraid/media/4K Movies/Star Trek Nemesis (2002)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Godzilla Minus One (2023)" rsync -avhP "/mnt/unraid/media/4K Movies/Godzilla Minus One (2023)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: The Hunger Games Mockingjay Part 2 (2015)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/The Hunger Games Mockingjay Part 2 (2015)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Chris->Ali: The Outfit (2022)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/The Outfit (2022)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Chris->Ali: Prey (2022)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Prey (2022)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: The Matrix Resurrections (2021)" rsync -avhP "/mnt/unraid/media/4K Movies/The Matrix Resurrections (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Godfather Part III (1990)" rsync -avhP "/mnt/unraid/media/4K Movies/The Godfather Part III (1990)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: What Happened to Monday (2017)" rsync -avhP "/mnt/unraid/media/4K Movies/What Happened to Monday (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Lion King (2019)" rsync -avhP "/mnt/unraid/media/4K Movies/The Lion King (2019)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: Deadpool 2 (2018)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Deadpool 2 (2018)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: V for Vendetta (2006)" rsync -avhP "/mnt/unraid/media/4K Movies/V for Vendetta (2006)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: Oblivion (2013)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Oblivion (2013)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: The Fifth Element (1997)" rsync -avhP "/mnt/unraid/media/4K Movies/The Fifth Element (1997)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Kingdom of the Planet of the Apes (2024)" rsync -avhP "/mnt/unraid/media/4K Movies/Kingdom of the Planet of the Apes (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Avengers Infinity War (2018)" rsync -avhP "/mnt/unraid/media/4K Movies/Avengers Infinity War (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: Mortal Kombat (2021)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Mortal Kombat (2021)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: Indiana Jones and the Kingdom of the Crystal Skull (2008)" rsync -avhP "/mnt/unraid/media/4K Movies/Indiana Jones and the Kingdom of the Crystal Skull (2008)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Forrest Gump (1994)" rsync -avhP "/mnt/unraid/media/4K Movies/Forrest Gump (1994)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Spy Who Loved Me (1977)" rsync -avhP "/mnt/unraid/media/4K Movies/The Spy Who Loved Me (1977)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Dark Knight (2008)" rsync -avhP "/mnt/unraid/media/4K Movies/The Dark Knight (2008)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Frankenstein (2025)" rsync -avhP "/mnt/unraid/media/4K Movies/Frankenstein (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Lord of the Rings The Fellowship of the Ring (2001)" rsync -avhP "/mnt/unraid/media/4K Movies/The Lord of the Rings The Fellowship of the Ring (2001)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Batman Begins (2005)" rsync -avhP "/mnt/unraid/media/4K Movies/Batman Begins (2005)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Star Trek Into Darkness (2013)" rsync -avhP "/mnt/unraid/media/4K Movies/Star Trek Into Darkness (2013)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Dawn of the Planet of the Apes (2014)" rsync -avhP "/mnt/unraid/media/4K Movies/Dawn of the Planet of the Apes (2014)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Suicide Squad (2021)" rsync -avhP "/mnt/unraid/media/4K Movies/The Suicide Squad (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: Star Trek V The Final Frontier (1989)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Star Trek V The Final Frontier (1989)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: Wonder Woman 1984 (2020)" rsync -avhP "/mnt/unraid/media/4K Movies/Wonder Woman 1984 (2020)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: 300 (2007)" rsync -avhP "/mnt/unraid/media/4K Movies/300 (2007)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Terminator 2 Judgment Day (1991)" rsync -avhP "/mnt/unraid/media/4K Movies/Terminator 2 Judgment Day (1991)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: King Kong vs. Godzilla (1962)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/King Kong vs. Godzilla (1962)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: Star Trek Generations (1994)" rsync -avhP "/mnt/unraid/media/4K Movies/Star Trek Generations (1994)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Fantastic 4 First Steps (2025)" rsync -avhP "/mnt/unraid/media/4K Movies/The Fantastic 4 First Steps (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Heat (1995)" rsync -avhP "/mnt/unraid/media/4K Movies/Heat (1995)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Eternals (2021)" rsync -avhP "/mnt/unraid/media/4K Movies/Eternals (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Kingdom of Heaven (2005)" rsync -avhP "/mnt/unraid/media/4K Movies/Kingdom of Heaven (2005)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: The Hunger Games Catching Fire (2013)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/The Hunger Games Catching Fire (2013)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Chris->Ali: Rocketman (2019)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Rocketman (2019)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Chris->Ali: Ghostbusters Afterlife (2021)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Ghostbusters Afterlife (2021)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: Interstellar (2014)" rsync -avhP "/mnt/unraid/media/4K Movies/Interstellar (2014)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: John Wick (2014)" rsync -avhP "/mnt/unraid/media/4K Movies/John Wick (2014)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Mission Impossible Rogue Nation (2015)" rsync -avhP "/mnt/unraid/media/4K Movies/Mission Impossible Rogue Nation (2015)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Deadpool and Wolverine (2024)" rsync -avhP "/mnt/unraid/media/4K Movies/Deadpool and Wolverine (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Lawrence of Arabia (1962)" rsync -avhP "/mnt/unraid/media/4K Movies/Lawrence of Arabia (1962)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Avengers (2012)" rsync -avhP "/mnt/unraid/media/4K Movies/The Avengers (2012)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Extraction (2020)" rsync -avhP "/mnt/unraid/media/4K Movies/Extraction (2020)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: John Wick Chapter 2 (2017)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/John Wick Chapter 2 (2017)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: Cars 2 (2011)" rsync -avhP "/mnt/unraid/media/4K Movies/Cars 2 (2011)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Godzilla x Kong The New Empire (2024)" rsync -avhP "/mnt/unraid/media/4K Movies/Godzilla x Kong The New Empire (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Godfather (1972)" rsync -avhP "/mnt/unraid/media/4K Movies/The Godfather (1972)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Pulp Fiction (1994)" rsync -avhP "/mnt/unraid/media/4K Movies/Pulp Fiction (1994)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Hunt for Red October (1990)" rsync -avhP "/mnt/unraid/media/4K Movies/The Hunt for Red October (1990)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Venom (2018)" rsync -avhP "/mnt/unraid/media/4K Movies/Venom (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Venom Let There Be Carnage (2021)" rsync -avhP "/mnt/unraid/media/4K Movies/Venom Let There Be Carnage (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Guardians of the Galaxy Vol. 3 (2023)" rsync -avhP "/mnt/unraid/media/4K Movies/Guardians of the Galaxy Vol. 3 (2023)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Inception (2010)" rsync -avhP "/mnt/unraid/media/4K Movies/Inception (2010)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Logan (2017)" rsync -avhP "/mnt/unraid/media/4K Movies/Logan (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Red Sparrow (2018)" rsync -avhP "/mnt/unraid/media/4K Movies/Red Sparrow (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Iron Man 3 (2013)" rsync -avhP "/mnt/unraid/media/4K Movies/Iron Man 3 (2013)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Twister (1996)" rsync -avhP "/mnt/unraid/media/4K Movies/Twister (1996)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Phantom of the Opera (2004)" rsync -avhP "/mnt/unraid/media/4K Movies/The Phantom of the Opera (2004)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Ten Commandments (1956)" rsync -avhP "/mnt/unraid/media/4K Movies/The Ten Commandments (1956)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Matrix Revolutions (2003)" rsync -avhP "/mnt/unraid/media/4K Movies/The Matrix Revolutions (2003)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Zombieland Double Tap (2019)" rsync -avhP "/mnt/unraid/media/4K Movies/Zombieland Double Tap (2019)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: Captain Marvel (2019)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Captain Marvel (2019)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: Thunderbolts- (2025)" rsync -avhP "/mnt/unraid/media/4K Movies/Thunderbolts- (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Lost World Jurassic Park (1997)" rsync -avhP "/mnt/unraid/media/4K Movies/The Lost World Jurassic Park (1997)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Rise of the Planet of the Apes (2011)" rsync -avhP "/mnt/unraid/media/4K Movies/Rise of the Planet of the Apes (2011)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Alien (1979)" rsync -avhP "/mnt/unraid/media/4K Movies/Alien (1979)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Iron Man 2 (2010)" rsync -avhP "/mnt/unraid/media/4K Movies/Iron Man 2 (2010)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Wicked (2024)" rsync -avhP "/mnt/unraid/media/4K Movies/Wicked (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Willy Wonka and the Chocolate Factory (1971)" rsync -avhP "/mnt/unraid/media/4K Movies/Willy Wonka and the Chocolate Factory (1971)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: Deadpool (2016)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Deadpool (2016)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: Extraction 2 (2023)" rsync -avhP "/mnt/unraid/media/4K Movies/Extraction 2 (2023)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: Pirates of the Caribbean The Curse of the Black Pearl (2003)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Pirates of the Caribbean The Curse of the Black Pearl (2003)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Chris->Ali: Shazam! Fury of the Gods (2023)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Shazam! Fury of the Gods (2023)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: The Lion King (1994)" rsync -avhP "/mnt/unraid/media/4K Movies/The Lion King (1994)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: Ad Astra (2019)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Ad Astra (2019)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: Tenet (2020)" rsync -avhP "/mnt/unraid/media/4K Movies/Tenet (2020)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Godzilla vs. Kong (2021)" rsync -avhP "/mnt/unraid/media/4K Movies/Godzilla vs. Kong (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Mission Impossible Fallout (2018)" rsync -avhP "/mnt/unraid/media/4K Movies/Mission Impossible Fallout (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Revenant (2015)" rsync -avhP "/mnt/unraid/media/4K Movies/The Revenant (2015)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Lord of the Rings The Two Towers (2002)" rsync -avhP "/mnt/unraid/media/4K Movies/The Lord of the Rings The Two Towers (2002)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: Star Wars (1977)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Star Wars (1977)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Chris->Ali: Star Trek The Motion Picture (1979)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Star Trek The Motion Picture (1979)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Chris->Ali: War of the Worlds (2005)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/War of the Worlds (2005)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: Spider-Man Homecoming (2017)" rsync -avhP "/mnt/unraid/media/4K Movies/Spider-Man Homecoming (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Passengers (2016)" rsync -avhP "/mnt/unraid/media/4K Movies/Passengers (2016)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Mission Impossible II (2000)" rsync -avhP "/mnt/unraid/media/4K Movies/Mission Impossible II (2000)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Spider-Man No Way Home (2021)" rsync -avhP "/mnt/unraid/media/4K Movies/Spider-Man No Way Home (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Black Panther Wakanda Forever (2022)" rsync -avhP "/mnt/unraid/media/4K Movies/Black Panther Wakanda Forever (2022)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Shawshank Redemption (1994)" rsync -avhP "/mnt/unraid/media/4K Movies/The Shawshank Redemption (1994)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Black Widow (2021)" rsync -avhP "/mnt/unraid/media/4K Movies/Black Widow (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Star Trek Insurrection (1998)" rsync -avhP "/mnt/unraid/media/4K Movies/Star Trek Insurrection (1998)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: The Hunger Games Mockingjay Part 1 (2014)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/The Hunger Games Mockingjay Part 1 (2014)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: Coco (2017)" rsync -avhP "/mnt/unraid/media/4K Movies/Coco (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Captain America Brave New World (2025)" rsync -avhP "/mnt/unraid/media/4K Movies/Captain America Brave New World (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Indiana Jones and the Temple of Doom (1984)" rsync -avhP "/mnt/unraid/media/4K Movies/Indiana Jones and the Temple of Doom (1984)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Star Trek IV The Voyage Home (1986)" rsync -avhP "/mnt/unraid/media/4K Movies/Star Trek IV The Voyage Home (1986)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: The Matrix (1999)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/The Matrix (1999)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: Star Trek First Contact (1996)" rsync -avhP "/mnt/unraid/media/4K Movies/Star Trek First Contact (1996)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Pacific Rim (2013)" rsync -avhP "/mnt/unraid/media/4K Movies/Pacific Rim (2013)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Hacksaw Ridge (2016)" rsync -avhP "/mnt/unraid/media/4K Movies/Hacksaw Ridge (2016)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Thor The Dark World (2013)" rsync -avhP "/mnt/unraid/media/4K Movies/Thor The Dark World (2013)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Godzilla (2014)" rsync -avhP "/mnt/unraid/media/4K Movies/Godzilla (2014)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Matrix Reloaded (2003)" rsync -avhP "/mnt/unraid/media/4K Movies/The Matrix Reloaded (2003)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Mission Impossible The Final Reckoning (2025)" rsync -avhP "/mnt/unraid/media/4K Movies/Mission Impossible The Final Reckoning (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Army of the Dead (2021)" rsync -avhP "/mnt/unraid/media/4K Movies/Army of the Dead (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Top Gun Maverick (2022)" rsync -avhP "/mnt/unraid/media/4K Movies/Top Gun Maverick (2022)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Greatest Showman (2017)" rsync -avhP "/mnt/unraid/media/4K Movies/The Greatest Showman (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: Jaws (1975)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Jaws (1975)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: The Northman (2022)" rsync -avhP "/mnt/unraid/media/4K Movies/The Northman (2022)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: 2001 A Space Odyssey (1968)" rsync -avhP "/mnt/unraid/media/4K Movies/2001 A Space Odyssey (1968)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: Return of the Jedi (1983)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Return of the Jedi (1983)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: The Predator (2018)" rsync -avhP "/mnt/unraid/media/4K Movies/The Predator (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Ghostbusters (1984)" rsync -avhP "/mnt/unraid/media/4K Movies/Ghostbusters (1984)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Braveheart (1995)" rsync -avhP "/mnt/unraid/media/4K Movies/Braveheart (1995)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Thor (2011)" rsync -avhP "/mnt/unraid/media/4K Movies/Thor (2011)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Zack Snyders Justice League (2021)" rsync -avhP "/mnt/unraid/media/4K Movies/Zack Snyders Justice League (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: Joker (2019)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Joker (2019)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Chris->Ali: Star Trek VI The Undiscovered Country (1991)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Star Trek VI The Undiscovered Country (1991)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: Furiosa A Mad Max Saga (2024)" rsync -avhP "/mnt/unraid/media/4K Movies/Furiosa A Mad Max Saga (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: TRON Legacy (2010)" rsync -avhP "/mnt/unraid/media/4K Movies/TRON Legacy (2010)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Superman (2025)" rsync -avhP "/mnt/unraid/media/4K Movies/Superman (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Solo A Star Wars Story (2018)" rsync -avhP "/mnt/unraid/media/4K Movies/Solo A Star Wars Story (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Lord of the Rings The Return of the King (2003)" rsync -avhP "/mnt/unraid/media/4K Movies/The Lord of the Rings The Return of the King (2003)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Godfather Part II (1974)" rsync -avhP "/mnt/unraid/media/4K Movies/The Godfather Part II (1974)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: Doctor Strange (2016)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Doctor Strange (2016)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: Twisters (2024)" rsync -avhP "/mnt/unraid/media/4K Movies/Twisters (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Thor Ragnarok (2017)" rsync -avhP "/mnt/unraid/media/4K Movies/Thor Ragnarok (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Blade (1998)" rsync -avhP "/mnt/unraid/media/4K Movies/Blade (1998)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Zombieland (2009)" rsync -avhP "/mnt/unraid/media/4K Movies/Zombieland (2009)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Star Trek II The Wrath of Khan (1982)" rsync -avhP "/mnt/unraid/media/4K Movies/Star Trek II The Wrath of Khan (1982)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Avatar The Way of Water (2022)" rsync -avhP "/mnt/unraid/media/4K Movies/Avatar The Way of Water (2022)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Black Adam (2022)" rsync -avhP "/mnt/unraid/media/4K Movies/Black Adam (2022)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: The Hunger Games (2012)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/The Hunger Games (2012)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: Spider-Man Far From Home (2019)" rsync -avhP "/mnt/unraid/media/4K Movies/Spider-Man Far From Home (2019)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: Jungle Cruise (2021)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Jungle Cruise (2021)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: The Super Mario Bros. Movie (2023)" rsync -avhP "/mnt/unraid/media/4K Movies/The Super Mario Bros. Movie (2023)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: Dune (2021)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Dune (2021)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Chris->Ali: Furious 7 (2015)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Furious 7 (2015)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Chris->Ali: Bohemian Rhapsody (2018)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Bohemian Rhapsody (2018)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: Pacific Rim Uprising (2018)" rsync -avhP "/mnt/unraid/media/4K Movies/Pacific Rim Uprising (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Cars 3 (2017)" rsync -avhP "/mnt/unraid/media/4K Movies/Cars 3 (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Iron Man (2008)" rsync -avhP "/mnt/unraid/media/4K Movies/Iron Man (2008)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Mission Impossible Ghost Protocol (2011)" rsync -avhP "/mnt/unraid/media/4K Movies/Mission Impossible Ghost Protocol (2011)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Earth One Amazing Day (2017)" rsync -avhP "/mnt/unraid/media/4K Movies/Earth One Amazing Day (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Wizard of Oz (1939)" rsync -avhP "/mnt/unraid/media/4K Movies/The Wizard of Oz (1939)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Terminator (1984)" rsync -avhP "/mnt/unraid/media/4K Movies/The Terminator (1984)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Raiders of the Lost Ark (1981)" rsync -avhP "/mnt/unraid/media/4K Movies/Raiders of the Lost Ark (1981)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Apocalypse Now (1979)" rsync -avhP "/mnt/unraid/media/4K Movies/Apocalypse Now (1979)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Dunkirk (2017)" rsync -avhP "/mnt/unraid/media/4K Movies/Dunkirk (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Blade II (2002)" rsync -avhP "/mnt/unraid/media/4K Movies/Blade II (2002)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Blade Runner 2049 (2017)" rsync -avhP "/mnt/unraid/media/4K Movies/Blade Runner 2049 (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Dark Knight Rises (2012)" rsync -avhP "/mnt/unraid/media/4K Movies/The Dark Knight Rises (2012)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: Jurassic World Dominion (2022)" rsync -avhP "/mnt/synology/rs-4kmedia/4kmovies/Jurassic World Dominion (2022)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: Avengers Age of Ultron (2015)" rsync -avhP "/mnt/unraid/media/4K Movies/Avengers Age of Ultron (2015)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Bram Stokers Dracula (1992)" rsync -avhP "/mnt/unraid/media/4K Movies/Bram Stokers Dracula (1992)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Guardians of the Galaxy Vol. 2 (2017)" rsync -avhP "/mnt/unraid/media/4K Movies/Guardians of the Galaxy Vol. 2 (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Captain America Civil War (2016)" rsync -avhP "/mnt/unraid/media/4K Movies/Captain America Civil War (2016)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Gladiator II (2024)" rsync -avhP "/mnt/unraid/media/4K Movies/Gladiator II (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Brotherhood of the Wolf (2001)" rsync -avhP "/mnt/unraid/media/4K Movies/Brotherhood of the Wolf (2001)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Star Trek III The Search for Spock (1984)" rsync -avhP "/mnt/unraid/media/4K Movies/Star Trek III The Search for Spock (1984)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Jurassic Park (1993)" rsync -avhP "/mnt/unraid/media/4K Movies/Jurassic Park (1993)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Constantine (2005)" rsync -avhP "/mnt/unraid/media/4K Movies/Constantine (2005)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Star Trek Beyond (2016)" rsync -avhP "/mnt/unraid/media/4K Movies/Star Trek Beyond (2016)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Uncharted (2022)" rsync -avhP "/mnt/unraid/media/4K Movies/Uncharted (2022)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: Tron (1982)" rsync -avhP "/mnt/unraid/media/4K Movies/Tron (1982)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: TRON Ares (2025)" rsync -avhP "/mnt/unraid/media/4K Movies/TRON Ares (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"


# Wait for all parallel jobs to complete
if [ "$PARALLEL" -gt 1 ]; then
    log "Waiting for parallel transfers to complete..."
    wait
fi

log "Sync complete!"
