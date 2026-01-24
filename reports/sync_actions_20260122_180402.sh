#!/bin/bash
#==============================================================================
# Project Mother Sync Script
# RUN THIS ON MOTHER (10.0.0.162)
#==============================================================================
# Generated: 2026-01-22 18:04:02
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

PROGRESS_FILE="${PROGRESS_FILE:-sync_progress_20260122_180402.log}"
ERROR_LOG="${ERROR_LOG:-sync_errors_20260122_180402.log}"
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

# === MOVE ALI'S LOWER QUALITY TO DELETED (Unraid only) ===
# Note: Chris's files are NOT moved here - see chris_pending_deletions script

run_cmd "Move Ali lower quality: 20 Million Miles to Earth (1957)" mv "/mnt/unraid/media/Movies/20 Million Miles to Earth (1957)/20 Million Miles to Earth (1957) {tmdb-15096} - [Bluray-1080p][Opus 5.1][x264]-RetroPeeps.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Bio-Dome (1996)" mv "/mnt/unraid/media/Movies/Bio-Dome (1996)/Bio-Dome (1996) {tmdb-9536} - [Bluray-1080p][AAC 2.0][x264]-hallowed.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Girl Who Escaped The Kara Robinson Story (2023)" mv "/mnt/unraid/media/Movies/The Girl Who Escaped The Kara Robinson Story (2023)/The Girl Who Escaped The Kara Robinson Story (2023) {tmdb-1075334} - [HMAX][WEBDL-1080p][AC3 5.1][x264]-playWEB.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Miami Vice (2006)" mv "/mnt/unraid/media/Movies/Miami Vice (2006)/Miami Vice (2006) {tmdb-82} - {edition-Director's Cut} [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Prizefighter The Life of Jem Belcher (2022)" mv "/mnt/unraid/media/Movies/Prizefighter The Life of Jem Belcher (2022)/Prizefighter The Life of Jem Belcher (2022) {tmdb-943822} - [Bluray-1080p][AC3 5.1][x264]-TWA.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Music and Lyrics (2007)" mv "/mnt/unraid/media/Movies/Music and Lyrics (2007)/Music and Lyrics (2007) {tmdb-11172} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: About Cherry (2012)" mv "/mnt/unraid/media/Movies/About Cherry (2012)/About Cherry (2012) {tmdb-94901} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Do the Right Thing (1989)" mv "/mnt/unraid/media/Movies/Do the Right Thing (1989)/Do the Right Thing (1989) {tmdb-925} - [Bluray-1080p][FLAC 2.0][x264]-ATELiER.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Enemy of the State (1998)" mv "/mnt/unraid/media/Movies/Enemy of the State (1998)/Enemy of the State (1998) {tmdb-9798} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Keeping Up with the Joneses (2016)" mv "/mnt/unraid/media/Movies/Keeping Up with the Joneses (2016)/Keeping Up with the Joneses (2016) {tmdb-331313} - [Bluray-1080p][DTS-ES 5.1][x264]-TayTO.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Collateral Damage (2002)" mv "/mnt/unraid/media/Movies/Collateral Damage (2002)/Collateral Damage (2002) {tmdb-9884} - [Bluray-1080p][DTS 5.1][x264]-SbR.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Paddington (2014)" mv "/mnt/unraid/media/Movies/Paddington (2014)/Paddington (2014) {tmdb-116149} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Chaos Walking (2021)" mv "/mnt/unraid/media/Movies/Chaos Walking (2021)/Chaos Walking (2021) {tmdb-412656} - [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Romancing the Stone (1984)" mv "/mnt/unraid/media/Movies/Romancing the Stone (1984)/Romancing the Stone (1984) {tmdb-9326} - [Bluray-1080p][DTS 5.1][x264]-FoRM.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Northpole Open for Christmas (2015)" mv "/mnt/unraid/media/Movies/Northpole Open for Christmas (2015)/Northpole Open for Christmas (2015) {tmdb-339543} - [Bluray-1080p][DTS 5.1][x264]-JustWatch.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Be Cool (2005)" mv "/mnt/unraid/media/Movies/Be Cool (2005)/Be Cool (2005) {tmdb-4551} - [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Day of Reckoning (2025)" mv "/mnt/unraid/media/Movies/Day of Reckoning (2025)/Day of Reckoning (2025) {tmdb-1414048} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-APEX.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Hudas Salon (2022)" mv "/mnt/unraid/media/Movies/Hudas Salon (2022)/Hudas Salon (2022) {tmdb-782648} - [WEBDL-1080p][AC3 5.1][h264]-TEPES.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Ten Commandments (1956)" mv "/mnt/unraid/media/Movies/The Ten Commandments (1956)/The Ten Commandments (1956) {tmdb-6844} - [Bluray-1080p][EAC3 5.1][DV HDR10][x265]-SM737.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Help (2011)" mv "/mnt/unraid/media/Movies/The Help (2011)/The Help (2011) {tmdb-50014} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Play Dead (2022)" mv "/mnt/unraid/media/Movies/Play Dead (2022)/Play Dead (2022) {tmdb-1020696} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Evil Dead (2013)" mv "/mnt/unraid/media/Movies/Evil Dead (2013)/Evil Dead (2013) {tmdb-109428} - {edition-Unrated} [Bluray-1080p][EAC3 5.1][DV HDR10][x265]-SA89.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Superman Shazam! The Return of Black Adam (2010)" mv "/mnt/unraid/media/Movies/Superman Shazam! The Return of Black Adam (2010)/Superman Shazam! The Return of Black Adam (2010) {tmdb-43641} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Marauders (2016)" mv "/mnt/unraid/media/Movies/Marauders (2016)/Marauders (2016) {tmdb-359412} - [Bluray-1080p][DTS-HD MA 5.1][x264]-FraMeSToR.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Worth (2021)" mv "/mnt/unraid/media/Movies/Worth (2021)/Worth (2021) {tmdb-649394} - [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Alien Covenant (2017)" mv "/mnt/unraid/media/Movies/Alien Covenant (2017)/Alien Covenant (2017) {tmdb-126889} - [Bluray-1080p][DTS-ES 5.1][x264]-Geek.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Air Bud (1997)" mv "/mnt/unraid/media/Movies/Air Bud (1997)/Air Bud (1997) {tmdb-20737} - [Bluray-1080p][FLAC 2.0][x264]-GeneMige.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Ice Age Dawn of the Dinosaurs (2009)" mv "/mnt/unraid/media/Movies/Ice Age Dawn of the Dinosaurs (2009)/Ice Age Dawn of the Dinosaurs (2009) {tmdb-8355} - [Bluray-1080p][DTS-ES 5.1][x264]-D-Z0N3.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Nothing to Lose (1997)" mv "/mnt/unraid/media/Movies/Nothing to Lose (1997)/Nothing to Lose (1997) {tmdb-11676} - [WEBRip-1080p][EAC3 2.0][x264]-monkee.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Adventures of Ford Fairlane (1990)" mv "/mnt/unraid/media/Movies/The Adventures of Ford Fairlane (1990)/The Adventures of Ford Fairlane (1990) {tmdb-9548} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Free Fire (2017)" mv "/mnt/unraid/media/Movies/Free Fire (2017)/Free Fire (2017) {tmdb-334521} - [Bluray-1080p][AC3 5.1][x264]-decibeL.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Rons Gone Wrong (2021)" mv "/mnt/unraid/media/Movies/Rons Gone Wrong (2021)/Rons Gone Wrong (2021) {tmdb-482321} - [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Colombiana (2011)" mv "/mnt/unraid/media/Movies/Colombiana (2011)/Colombiana (2011) {tmdb-62835} - {edition-Unrated} [Bluray-1080p][AC3 5.1][x264]-EbP.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Replicas (2018)" mv "/mnt/unraid/media/Movies/Replicas (2018)/Replicas (2018) {tmdb-300681} - [Bluray-1080p][EAC3 5.1][x264]-SbR.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Jim Jefferies Alcoholocaust (2010)" mv "/mnt/unraid/media/Movies/Jim Jefferies Alcoholocaust (2010)/Jim Jefferies Alcoholocaust (2010) {tmdb-49505} - [WEBRip-1080p][EAC3 2.0][x264]-MXB.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Dazed and Confused (1993)" mv "/mnt/unraid/media/Movies/Dazed and Confused (1993)/Dazed and Confused (1993) {tmdb-9571} - [Bluray-1080p][EAC3 5.1][x264]-TayTO.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Abbott and Costello Meet the Keystone Kops (1955)" mv "/mnt/unraid/media/Movies/Abbott and Costello Meet the Keystone Kops (1955)/Abbott and Costello Meet the Keystone Kops (1955) {tmdb-33476} - [Bluray-1080p][FLAC 2.0][x264]-RetroPeeps.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Great Outdoors (1988)" mv "/mnt/unraid/media/Movies/The Great Outdoors (1988)/The Great Outdoors (1988) {tmdb-2617} - [Bluray-1080p][FLAC 2.0][x264]-Geek.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Paranormal Activity 3 (2011)" mv "/mnt/unraid/media/Movies/Paranormal Activity 3 (2011)/Paranormal Activity 3 (2011) {tmdb-72571} - {edition-Unrated} [Bluray-1080p][EAC3 5.1][x264]-j3rico.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The ChubbChubbs! (2002)" mv "/mnt/unraid/media/Movies/The ChubbChubbs! (2002)/The ChubbChubbs! (2002) {tmdb-27042} - [Bluray-1080p][EAC3 5.1][x264]-PERFETTO.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Manchurian Candidate (1962)" mv "/mnt/unraid/media/Movies/The Manchurian Candidate (1962)/The Manchurian Candidate (1962) {tmdb-982} - [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Tag (2018)" mv "/mnt/unraid/media/Movies/Tag (2018)/Tag (2018) {tmdb-455980} - [Bluray-1080p][DTS 5.1][x264]-TayTO.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: You Should Have Left (2020)" mv "/mnt/unraid/media/Movies/You Should Have Left (2020)/You Should Have Left (2020) {tmdb-514593} - [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: About My Father (2023)" mv "/mnt/unraid/media/Movies/About My Father (2023)/About My Father (2023) {tmdb-829051} - [Bluray-1080p][TrueHD Atmos 7.1][x264]-pignus.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: She Said (2022)" mv "/mnt/unraid/media/Movies/She Said (2022)/She Said (2022) {tmdb-837881} - [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Chitty Chitty Bang Bang (1968)" mv "/mnt/unraid/media/Movies/Chitty Chitty Bang Bang (1968)/Chitty Chitty Bang Bang (1968) {tmdb-11708} - [Bluray-1080p][EAC3 7.1][x264]-playHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Cargo (2017)" mv "/mnt/unraid/media/Movies/Cargo (2017)/Cargo (2017) {tmdb-425972} - [Bluray-1080p][AC3 5.1][x264]-playHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Bud Abbott and Lou Costello in the Foreign Legion (1950)" mv "/mnt/unraid/media/Movies/Bud Abbott and Lou Costello in the Foreign Legion (1950)/Bud Abbott and Lou Costello in the Foreign Legion (1950) {tmdb-33474} - [Bluray-1080p][FLAC 2.0][x264]-RetroPeeps.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Harold and Maude (1971)" mv "/mnt/unraid/media/Movies/Harold and Maude (1971)/Harold and Maude (1971) {tmdb-343} - [Bluray-1080p][EAC3 5.1][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: ¡Three Amigos! (1986)" mv "/mnt/unraid/media/Movies/¡Three Amigos! (1986)/¡Three Amigos! (1986) {tmdb-8388} - [Bluray-1080p][EAC3 5.1][x264]-Kanashii.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: City of Life and Death (2009)" mv "/mnt/unraid/media/Movies/City of Life and Death (2009)/City of Life and Death (2009) {tmdb-21345} - [Bluray-1080p][DTS 5.1][x264]-HDW.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Wall Street Money Never Sleeps (2010)" mv "/mnt/unraid/media/Movies/Wall Street Money Never Sleeps (2010)/Wall Street Money Never Sleeps (2010) {tmdb-33909} - [Bluray-1080p][AC3 5.1][x264]-EbP.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Tale of Despereaux (2008)" mv "/mnt/unraid/media/Movies/The Tale of Despereaux (2008)/The Tale of Despereaux (2008) {tmdb-10199} - [Bluray-1080p][DTS-HD MA 5.1][VC1]-GBS.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: National Treasure Book of Secrets (2007)" mv "/mnt/unraid/media/Movies/National Treasure Book of Secrets (2007)/National Treasure Book of Secrets (2007) {tmdb-6637} - [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Child 44 (2015)" mv "/mnt/unraid/media/Movies/Child 44 (2015)/Child 44 (2015) {tmdb-181283} - [Hybrid][Bluray-1080p][DTS 5.1][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: A Madea Family Funeral (2019)" mv "/mnt/unraid/media/Movies/A Madea Family Funeral (2019)/A Madea Family Funeral (2019) {tmdb-464504} - [Bluray-1080p][EAC3 5.1][x264]-j3rico.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Gremlins (1984)" mv "/mnt/unraid/media/Movies/Gremlins (1984)/Gremlins (1984) {tmdb-927} - [Bluray-1080p][EAC3 5.1][DV HDR10][x265]-SQS.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Moonshot (2022)" mv "/mnt/unraid/media/Movies/Moonshot (2022)/Moonshot (2022) {tmdb-767825} - [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Pacifiction (2022)" mv "/mnt/unraid/media/Movies/Pacifiction (2022)/Pacifiction (2022) {tmdb-691214} - [Bluray-1080p][EAC3 5.1][x264]-SbR.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Indiscreet (1958)" mv "/mnt/unraid/media/Movies/Indiscreet (1958)/Indiscreet (1958) {tmdb-22874} - [Bluray-1080p][Opus 1.0][x264]-RetroPeeps.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Godzilla Minus One (2023)" mv "/mnt/unraid/media/Movies/Godzilla Minus One (2023)/Godzilla Minus One (2023) {tmdb-940721} - [Bluray-1080p][EAC3 7.1][DV HDR10][x265]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Driving Miss Daisy (1989)" mv "/mnt/unraid/media/Movies/Driving Miss Daisy (1989)/Driving Miss Daisy (1989) {tmdb-403} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: American Wedding (2003)" mv "/mnt/unraid/media/Movies/American Wedding (2003)/American Wedding (2003) {tmdb-8273} - {edition-Unrated} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Adventures of Sharkboy and Lavagirl (2005)" mv "/mnt/unraid/media/Movies/The Adventures of Sharkboy and Lavagirl (2005)/The Adventures of Sharkboy and Lavagirl (2005) {tmdb-14199} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-ARTiCUN0.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Golden Child (1986)" mv "/mnt/unraid/media/Movies/The Golden Child (1986)/The Golden Child (1986) {tmdb-10136} - [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Step Up 2 The Streets (2008)" mv "/mnt/unraid/media/Movies/Step Up 2 The Streets (2008)/Step Up 2 The Streets (2008) {tmdb-8328} - [Bluray-1080p][EAC3 5.1][x264]-j3rico.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Fair Play (2023)" mv "/mnt/unraid/media/Movies/Fair Play (2023)/Fair Play (2023) {tmdb-910571} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Miss Congeniality (2000)" mv "/mnt/unraid/media/Movies/Miss Congeniality (2000)/Miss Congeniality (2000) {tmdb-1493} - [Bluray-1080p][DTS-HD MA 5.1][VC1]-TWA.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Karate Kid Part III (1989)" mv "/mnt/unraid/media/Movies/The Karate Kid Part III (1989)/The Karate Kid Part III (1989) {tmdb-10495} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: John Q (2002)" mv "/mnt/unraid/media/Movies/John Q (2002)/John Q (2002) {tmdb-8470} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Jimmys Hall (2014)" mv "/mnt/unraid/media/Movies/Jimmys Hall (2014)/Jimmys Hall (2014) {tmdb-262958} - [Bluray-1080p][DTS 5.1][x264]-WEST.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Downfall (2004)" mv "/mnt/unraid/media/Movies/Downfall (2004)/Downfall (2004) {tmdb-613} - [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Unfaithful (2002)" mv "/mnt/unraid/media/Movies/Unfaithful (2002)/Unfaithful (2002) {tmdb-2251} - [Bluray-1080p][EAC3 5.1][x264]-T0NY.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Antebellum (2020)" mv "/mnt/unraid/media/Movies/Antebellum (2020)/Antebellum (2020) {tmdb-627290} - [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Ernest Scared Stupid (1991)" mv "/mnt/unraid/media/Movies/Ernest Scared Stupid (1991)/Ernest Scared Stupid (1991) {tmdb-32685} - [Bluray-1080p][AC3 2.0][x264]-FoRM.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: No Other Land (2024)" mv "/mnt/unraid/media/Movies/No Other Land (2024)/No Other Land (2024) {tmdb-1232493} - [AMZN][WEBDL-1080p][EAC3 2.0][h264]-Kitsune.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: William Tell (2025)" mv "/mnt/unraid/media/Movies/William Tell (2025)/William Tell (2025) {tmdb-1195631} - [Bluray-1080p][DTS-HD MA 5.1][x264]-OVERTURE.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Darkman III Die Darkman Die (1996)" mv "/mnt/unraid/media/Movies/Darkman III Die Darkman Die (1996)/Darkman III Die Darkman Die (1996) {tmdb-19002} - [Bluray-1080p][DTS 2.0][x264]-saimorny.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Happening (2021)" mv "/mnt/unraid/media/Movies/Happening (2021)/Happening (2021) {tmdb-793998} - [Bluray-1080p][EAC3 5.1][x264]-EA.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: A Christmas Carol (1984)" mv "/mnt/unraid/media/Movies/A Christmas Carol (1984)/A Christmas Carol (1984) {tmdb-13189} - [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Patriots Day (2016)" mv "/mnt/unraid/media/Movies/Patriots Day (2016)/Patriots Day (2016) {tmdb-388399} - [Bluray-1080p][DTS-X 7.1][x264]-FraMeSToR.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Ant-Man and the Wasp (2018)" mv "/mnt/unraid/media/Movies/Ant-Man and the Wasp (2018)/Ant-Man and the Wasp (2018) {tmdb-363088} - [Bluray-1080p][EAC3 7.1][x264]-Geek.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Secret Life of Pets 2 (2019)" mv "/mnt/unraid/media/Movies/The Secret Life of Pets 2 (2019)/The Secret Life of Pets 2 (2019) {tmdb-412117} - [Bluray-1080p][AC3 5.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Shogun Assassin (1980)" mv "/mnt/unraid/media/Movies/Shogun Assassin (1980)/Shogun Assassin (1980) {tmdb-15119} - [Bluray-1080p][AC3 1.0][x264]-EA.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Red Sparrow (2018)" mv "/mnt/unraid/media/Movies/Red Sparrow (2018)/Red Sparrow (2018) {tmdb-401981} - [Bluray-1080p][DTS-ES 5.1][x264]-TDD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Baker (2023)" mv "/mnt/unraid/media/Movies/The Baker (2023)/The Baker (2023) {tmdb-823395} - [WEBDL-1080p][EAC3 5.1][h264]-EGEN.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Wrong Turn (2021)" mv "/mnt/unraid/media/Movies/Wrong Turn (2021)/Wrong Turn (2021) {tmdb-630586} - [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Sorcerer and the White Snake (2011)" mv "/mnt/unraid/media/Movies/The Sorcerer and the White Snake (2011)/The Sorcerer and the White Snake (2011) {tmdb-75948} - [Bluray-1080p][DTS 5.1][x264]-aBD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The School for Good and Evil (2022)" mv "/mnt/unraid/media/Movies/The School for Good and Evil (2022)/The School for Good and Evil (2022) {tmdb-779782} - [NF][WEBDL-1080p Proper][EAC3 Atmos 5.1][x264]-FLUX.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Proposition (2005)" mv "/mnt/unraid/media/Movies/The Proposition (2005)/The Proposition (2005) {tmdb-16608} - [Bluray-1080p][EAC3 5.1][DV HDR10][x265]-c0kE.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: No Exit (2022)" mv "/mnt/unraid/media/Movies/No Exit (2022)/No Exit (2022) {tmdb-833425} - [Hulu][WEBDL-1080p][EAC3 5.1][h264]-TEPES.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Superman Unbound (2013)" mv "/mnt/unraid/media/Movies/Superman Unbound (2013)/Superman Unbound (2013) {tmdb-166076} - [Bluray-1080p][DTS 5.1][x264]-PublicHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Orphan First Kill (2022)" mv "/mnt/unraid/media/Movies/Orphan First Kill (2022)/Orphan First Kill (2022) {tmdb-760161} - [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Ordinary Angels (2024)" mv "/mnt/unraid/media/Movies/Ordinary Angels (2024)/Ordinary Angels (2024) {tmdb-974036} - [Bluray-1080p][EAC3 7.1][x264]-PTer.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Snow White and the Seven Dwarfs (1938)" mv "/mnt/unraid/media/Movies/Snow White and the Seven Dwarfs (1938)/Snow White and the Seven Dwarfs (1938) {tmdb-408} - [Bluray-1080p][EAC3 7.1][x264]-c0kE.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Watership Down (1978)" mv "/mnt/unraid/media/Movies/Watership Down (1978)/Watership Down (1978) {tmdb-11837} - [Bluray-1080p][FLAC 2.0][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Three Musketeers (1993)" mv "/mnt/unraid/media/Movies/The Three Musketeers (1993)/The Three Musketeers (1993) {tmdb-10057} - [Bluray-1080p][EAC3 5.1][x264]-MainFrame.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Force of Nature The Dry 2 (2024)" mv "/mnt/unraid/media/Movies/Force of Nature The Dry 2 (2024)/Force of Nature The Dry 2 (2024) {tmdb-832262} - [Bluray-1080p][EAC3 5.1][x264]-SPHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Goods Live Hard Sell Hard (2009)" mv "/mnt/unraid/media/Movies/The Goods Live Hard Sell Hard (2009)/The Goods Live Hard Sell Hard (2009) {tmdb-19905} - [AMZN][WEBDL-1080p][EAC3 5.1][x264]-SiGMA.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Harley Davidson and the Marlboro Man (1991)" mv "/mnt/unraid/media/Movies/Harley Davidson and the Marlboro Man (1991)/Harley Davidson and the Marlboro Man (1991) {tmdb-2453} - [Bluray-1080p][FLAC 2.0][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: 12 Years a Slave (2013)" mv "/mnt/unraid/media/Movies/12 Years a Slave (2013)/12 Years a Slave (2013) {tmdb-76203} - [Bluray-1080p][DTS 5.1][x264]-SbR.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The DUFF (2015)" mv "/mnt/unraid/media/Movies/The DUFF (2015)/The DUFF (2015) {tmdb-272693} - [Bluray-1080p][DTS 5.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Babes (2024)" mv "/mnt/unraid/media/Movies/Babes (2024)/Babes (2024) {tmdb-999582} - [Bluray-1080p][EAC3 5.1][x264]-PTer.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Red Cliff II (2009)" mv "/mnt/unraid/media/Movies/Red Cliff II (2009)/Red Cliff II (2009) {tmdb-15384} - {edition-Open Matte} [Bluray-1080p][DTS 5.1][x264]-EbP.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Machinist (2004)" mv "/mnt/unraid/media/Movies/The Machinist (2004)/The Machinist (2004) {tmdb-4553} - [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Ju-on The Grudge (2002)" mv "/mnt/unraid/media/Movies/Ju-on The Grudge (2002)/Ju-on The Grudge (2002) {tmdb-11838} - [Bluray-1080p Proper][EAC3 5.1][x264]-c0kE.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: First Man (2018)" mv "/mnt/unraid/media/Movies/First Man (2018)/First Man (2018) {tmdb-369972} - [Bluray-1080p][EAC3 7.1][x264]-TayTO.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: For Love of the Game (1999)" mv "/mnt/unraid/media/Movies/For Love of the Game (1999)/For Love of the Game (1999) {tmdb-10390} - [Bluray-1080p][AC3 5.1][x264]-HANDJOB.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: ParaNorman (2012)" mv "/mnt/unraid/media/Movies/ParaNorman (2012)/ParaNorman (2012) {tmdb-77174} - [Bluray-1080p][EAC3 7.1][DV HDR10][x265]-GALAXY.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Grapes of Wrath (1940)" mv "/mnt/unraid/media/Movies/The Grapes of Wrath (1940)/The Grapes of Wrath (1940) {tmdb-596} - [Bluray-1080p][FLAC 1.0][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Sleeping with the Enemy (1991)" mv "/mnt/unraid/media/Movies/Sleeping with the Enemy (1991)/Sleeping with the Enemy (1991) {tmdb-7442} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Where the Crawdads Sing (2022)" mv "/mnt/unraid/media/Movies/Where the Crawdads Sing (2022)/Where the Crawdads Sing (2022) {tmdb-682507} - [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Frank and Lola (2016)" mv "/mnt/unraid/media/Movies/Frank and Lola (2016)/Frank and Lola (2016) {tmdb-316021} - [Bluray-1080p][DTS 5.1][x264]-PriMaLHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Lucas (1986)" mv "/mnt/unraid/media/Movies/Lucas (1986)/Lucas (1986) {tmdb-13346} - [Bluray-1080p][EAC3 5.1][x264]-MeeSta.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Escape from New York (1981)" mv "/mnt/unraid/media/Movies/Escape from New York (1981)/Escape from New York (1981) {tmdb-1103} - [Hybrid][Bluray-1080p][EAC3 5.1][x264]-c0kE.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Super 8 (2011)" mv "/mnt/unraid/media/Movies/Super 8 (2011)/Super 8 (2011) {tmdb-37686} - [Bluray-1080p][DTS-ES 6.1][x264]-D-Z0N3.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Alpha and Omega (2010)" mv "/mnt/unraid/media/Movies/Alpha and Omega (2010)/Alpha and Omega (2010) {tmdb-12819} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Lets Be Cops (2014)" mv "/mnt/unraid/media/Movies/Lets Be Cops (2014)/Lets Be Cops (2014) {tmdb-193893} - [Bluray-1080p][AC3 5.1][x264]-EbP.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The First Omen (2024)" mv "/mnt/unraid/media/Movies/The First Omen (2024)/The First Omen (2024) {tmdb-437342} - [Bluray-1080p][DTS-HD MA 7.1][x264]-KNiVES.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Mortal Kombat Legends Scorpions Revenge (2020)" mv "/mnt/unraid/media/Movies/Mortal Kombat Legends Scorpions Revenge (2020)/Mortal Kombat Legends Scorpions Revenge (2020) {tmdb-664767} - [Bluray-1080p][DTS-HD MA 5.1][x264]-yol0w.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Deck the Halls (2006)" mv "/mnt/unraid/media/Movies/Deck the Halls (2006)/Deck the Halls (2006) {tmdb-9969} - [Bluray-1080p][EAC3 5.1][x264]-BNL.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Whale (2022)" mv "/mnt/unraid/media/Movies/The Whale (2022)/The Whale (2022) {tmdb-785084} - [Bluray-1080p][EAC3 7.1][DV HDR10][x265]-c0kE.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Decoy Bride (2011)" mv "/mnt/unraid/media/Movies/The Decoy Bride (2011)/The Decoy Bride (2011) {tmdb-40161} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Atlantis Milos Return (2003)" mv "/mnt/unraid/media/Movies/Atlantis Milos Return (2003)/Atlantis Milos Return (2003) {tmdb-8965} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Book of Life (2014)" mv "/mnt/unraid/media/Movies/The Book of Life (2014)/The Book of Life (2014) {tmdb-228326} - [Bluray-1080p][DTS 5.1][x264]-VietHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Contraband (2012)" mv "/mnt/unraid/media/Movies/Contraband (2012)/Contraband (2012) {tmdb-77866} - [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Brigsby Bear (2017)" mv "/mnt/unraid/media/Movies/Brigsby Bear (2017)/Brigsby Bear (2017) {tmdb-403431} - [Bluray-1080p][DTS 5.1][x264]-VietHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Inception (2010)" mv "/mnt/unraid/media/Movies/Inception (2010)/Inception (2010) {tmdb-27205} - [Hybrid][Bluray-1080p][EAC3 5.1][DV HDR10][x265]-HiDt.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: A Bronx Tale (1993)" mv "/mnt/unraid/media/Movies/A Bronx Tale (1993)/A Bronx Tale (1993) {tmdb-1607} - [Bluray-1080p][FLAC 2.0][DV HDR10][x265]-PTer.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: G.I. Joe The Rise of Cobra (2009)" mv "/mnt/unraid/media/Movies/G.I. Joe The Rise of Cobra (2009)/G.I. Joe The Rise of Cobra (2009) {tmdb-14869} - [Bluray-1080p][DTS 5.1][x264]-EbP.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: American History X (1998)" mv "/mnt/unraid/media/Movies/American History X (1998)/American History X (1998) {tmdb-73} - [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Superman Red Son (2020)" mv "/mnt/unraid/media/Movies/Superman Red Son (2020)/Superman Red Son (2020) {tmdb-618355} - [Bluray-1080p][DTS 5.1][x264]-PbK.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Evita (1996)" mv "/mnt/unraid/media/Movies/Evita (1996)/Evita (1996) {tmdb-8818} - [Bluray-1080p][DTS 5.1][x264]-LolHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Mortal Kombat Legends Battle of the Realms (2021)" mv "/mnt/unraid/media/Movies/Mortal Kombat Legends Battle of the Realms (2021)/Mortal Kombat Legends Battle of the Realms (2021) {tmdb-841755} - [Bluray-1080p][AC3 5.1][x264]-HANDJOB.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Mexican (2001)" mv "/mnt/unraid/media/Movies/The Mexican (2001)/The Mexican (2001) {tmdb-6073} - [Bluray-1080p][EAC3 5.1][x264]-TayTO.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Knock Knock (2015)" mv "/mnt/unraid/media/Movies/Knock Knock (2015)/Knock Knock (2015) {tmdb-263472} - [Bluray-1080p][EAC3 Atmos 8.0][DV HDR10][x265]-PapitaHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Joyland (2022)" mv "/mnt/unraid/media/Movies/Joyland (2022)/Joyland (2022) {tmdb-962571} - [Bluray-1080p][EAC3 5.1][x264]-Dariush.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Delivery Man (2013)" mv "/mnt/unraid/media/Movies/Delivery Man (2013)/Delivery Man (2013) {tmdb-146239} - [Bluray-1080p][DTS 5.1][x264]-NTb.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Ted (2012)" mv "/mnt/unraid/media/Movies/Ted (2012)/Ted (2012) {tmdb-72105} - {edition-Unrated} [Bluray-1080p][AC3 5.1][x264]-EbP.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: U2 Rattle and Hum (1988)" mv "/mnt/unraid/media/Movies/U2 Rattle and Hum (1988)/U2 Rattle and Hum (1988) {tmdb-18161} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: R.I.P.D. 2 Rise of the Damned (2022)" mv "/mnt/unraid/media/Movies/R.I.P.D. 2 Rise of the Damned (2022)/R.I.P.D. 2 Rise of the Damned (2022) {tmdb-1013860} - [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Twilight Saga Breaking Dawn Part 1 (2011)" mv "/mnt/unraid/media/Movies/The Twilight Saga Breaking Dawn Part 1 (2011)/The Twilight Saga Breaking Dawn Part 1 (2011) {tmdb-50619} - [Bluray-1080p][AC3 5.1][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Union (2024)" mv "/mnt/unraid/media/Movies/The Union (2024)/The Union (2024) {tmdb-704239} - [NF][WEBDL-1080p Proper][EAC3 Atmos 5.1][x264]-FLUX.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Frosty the Snowman (1969)" mv "/mnt/unraid/media/Movies/Frosty the Snowman (1969)/Frosty the Snowman (1969) {tmdb-13675} - [Bluray-1080p][Opus 5.1][x264]-RetroPeeps.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Metal Lords (2022)" mv "/mnt/unraid/media/Movies/Metal Lords (2022)/Metal Lords (2022) {tmdb-739993} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-TEPES.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Great Escaper (2023)" mv "/mnt/unraid/media/Movies/The Great Escaper (2023)/The Great Escaper (2023) {tmdb-944194} - [Bluray-1080p][EAC3 5.1][x264]-SPHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Krull (1983)" mv "/mnt/unraid/media/Movies/Krull (1983)/Krull (1983) {tmdb-849} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Emily the Criminal (2022)" mv "/mnt/unraid/media/Movies/Emily the Criminal (2022)/Emily the Criminal (2022) {tmdb-862965} - [Bluray-1080p][EAC3 5.1][x264]-LEGi0N.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Kung Fury (2015)" mv "/mnt/unraid/media/Movies/Kung Fury (2015)/Kung Fury (2015) {tmdb-251516} - [Bluray-1080p][AC3 2.0][x264]-NTb.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: When the Game Stands Tall (2014)" mv "/mnt/unraid/media/Movies/When the Game Stands Tall (2014)/When the Game Stands Tall (2014) {tmdb-232679} - [Bluray-1080p][AC3 5.1][x264]-VietHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Meet the Fockers (2004)" mv "/mnt/unraid/media/Movies/Meet the Fockers (2004)/Meet the Fockers (2004) {tmdb-693} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Swordfish (2001)" mv "/mnt/unraid/media/Movies/Swordfish (2001)/Swordfish (2001) {tmdb-9705} - [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Sideways (2004)" mv "/mnt/unraid/media/Movies/Sideways (2004)/Sideways (2004) {tmdb-9675} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: E.T. the Extra-Terrestrial (1982)" mv "/mnt/unraid/media/Movies/E.T. the Extra-Terrestrial (1982)/E.T. the Extra-Terrestrial (1982) {tmdb-601} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Predator Killer of Killers (2025)" mv "/mnt/unraid/media/Movies/Predator Killer of Killers (2025)/Predator Killer of Killers (2025) {tmdb-1376434} - {edition-Extended} [DSNP][WEBDL-1080p][EAC3 Atmos 5.1][h264]-HONE.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Dark Knight Rises (2012)" mv "/mnt/unraid/media/Movies/The Dark Knight Rises (2012)/The Dark Knight Rises (2012) {tmdb-49026} - {edition-IMAX} [Hybrid][Bluray-1080p][AC3 5.1][x264]-SA89.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Showtime (2002)" mv "/mnt/unraid/media/Movies/Showtime (2002)/Showtime (2002) {tmdb-5851} - [AMZN][WEBRip-1080p][EAC3 2.0][x264]-SDCC.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Sneakers (1992)" mv "/mnt/unraid/media/Movies/Sneakers (1992)/Sneakers (1992) {tmdb-2322} - [Bluray-1080p][EAC3 5.1][DV HDR10][x265]-HiDt.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Hamilton (2025)" mv "/mnt/unraid/media/Movies/Hamilton (2025)/Hamilton (2025) {tmdb-556574} - [DSNP][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Rudy (1993)" mv "/mnt/unraid/media/Movies/Rudy (1993)/Rudy (1993) {tmdb-14534} - {edition-Directors Cut} [Bluray-1080p][EAC3 7.1][DV HDR10][x265]-ZQ.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Billie (2020)" mv "/mnt/unraid/media/Movies/Billie (2020)/Billie (2020) {tmdb-649137} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-ISA.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Hansan Rising Dragon (2022)" mv "/mnt/unraid/media/Movies/Hansan Rising Dragon (2022)/Hansan Rising Dragon (2022) {tmdb-588108} - [Bluray-1080p][EAC3 5.1][x264]-MeeSta.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Hard Candy (2005)" mv "/mnt/unraid/media/Movies/Hard Candy (2005)/Hard Candy (2005) {tmdb-2652} - [Bluray-1080p][AC3 5.1][x264]-RDK123.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: I Now Pronounce You Chuck and Larry (2007)" mv "/mnt/unraid/media/Movies/I Now Pronounce You Chuck and Larry (2007)/I Now Pronounce You Chuck and Larry (2007) {tmdb-3563} - [Bluray-1080p][EAC3 5.1][x264]-eMc2.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Daddy Day Care (2003)" mv "/mnt/unraid/media/Movies/Daddy Day Care (2003)/Daddy Day Care (2003) {tmdb-10708} - [NF][WEBDL-1080p][AC3 5.1][x264]-monkee.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Meatballs (1979)" mv "/mnt/unraid/media/Movies/Meatballs (1979)/Meatballs (1979) {tmdb-14035} - [Bluray-1080p][DTS 2.0][x264]-filmhd.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Masters of the Universe (1987)" mv "/mnt/unraid/media/Movies/Masters of the Universe (1987)/Masters of the Universe (1987) {tmdb-11649} - [Hybrid][Bluray-1080p][FLAC 2.0][x264]-MaG.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Daytrippers (1997)" mv "/mnt/unraid/media/Movies/The Daytrippers (1997)/The Daytrippers (1997) {tmdb-49806} - [Bluray-1080p][FLAC 2.0][x264]-PSYCHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The War with Grandpa (2020)" mv "/mnt/unraid/media/Movies/The War with Grandpa (2020)/The War with Grandpa (2020) {tmdb-425001} - [Bluray-1080p Proper][EAC3 5.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Predator (1987)" mv "/mnt/unraid/media/Movies/Predator (1987)/Predator (1987) {tmdb-106} - {edition-Ultimate Hunter Edition} [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Trainwreck (2015)" mv "/mnt/unraid/media/Movies/Trainwreck (2015)/Trainwreck (2015) {tmdb-271718} - [Bluray-1080p][AC3 5.1][x264]-VietHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Hulk (2003)" mv "/mnt/unraid/media/Movies/Hulk (2003)/Hulk (2003) {tmdb-1927} - [Bluray-1080p][DTS-X 7.1][x264]-TIGER.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Joyeux Noel (2005)" mv "/mnt/unraid/media/Movies/Joyeux Noel (2005)/Joyeux Noel (2005) {tmdb-11661} - [Bluray-1080p][EAC3 5.1][x264]-SbR.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Fist Fight (2017)" mv "/mnt/unraid/media/Movies/Fist Fight (2017)/Fist Fight (2017) {tmdb-345922} - [Bluray-1080p][DTS 5.1][x264]-VietHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Bill and Teds Excellent Adventure (1989)" mv "/mnt/unraid/media/Movies/Bill and Teds Excellent Adventure (1989)/Bill and Teds Excellent Adventure (1989) {tmdb-1648} - [Bluray-1080p][FLAC 2.0][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Midnight in the Garden of Good and Evil (1997)" mv "/mnt/unraid/media/Movies/Midnight in the Garden of Good and Evil (1997)/Midnight in the Garden of Good and Evil (1997) {tmdb-8197} - [Bluray-1080p][DTS 5.1][x264]-OmertaHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Sex and the City 2 (2010)" mv "/mnt/unraid/media/Movies/Sex and the City 2 (2010)/Sex and the City 2 (2010) {tmdb-37786} - [Bluray-1080p][EAC3 5.1][x264]-j3rico.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Bobs Burgers Movie (2022)" mv "/mnt/unraid/media/Movies/The Bobs Burgers Movie (2022)/The Bobs Burgers Movie (2022) {tmdb-504827} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Pink Floyd The Wall (1982)" mv "/mnt/unraid/media/Movies/Pink Floyd The Wall (1982)/Pink Floyd The Wall (1982) {tmdb-12104} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Manchurian Candidate (2004)" mv "/mnt/unraid/media/Movies/The Manchurian Candidate (2004)/The Manchurian Candidate (2004) {tmdb-14462} - [Bluray-1080p][EAC3 5.1][x264]-c0kE.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Tetsuo The Iron Man (1989)" mv "/mnt/unraid/media/Movies/Tetsuo The Iron Man (1989)/Tetsuo The Iron Man (1989) {tmdb-41428} - [Bluray-1080p][AAC 2.0][x264]-CALiGARi.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Corrective Measures (2022)" mv "/mnt/unraid/media/Movies/Corrective Measures (2022)/Corrective Measures (2022) {tmdb-872177} - [Bluray-1080p][EAC3 5.1][x264]-STATiK.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Dances with Wolves (1990)" mv "/mnt/unraid/media/Movies/Dances with Wolves (1990)/Dances with Wolves (1990) {tmdb-581} - {edition-Theatrical Cut} [Bluray-1080p][EAC3 5.1][x264]-TayTO.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Monster House (2006)" mv "/mnt/unraid/media/Movies/Monster House (2006)/Monster House (2006) {tmdb-9297} - [Bluray-1080p][AC3 5.1][x264]-CRiSC.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Annie (2014)" mv "/mnt/unraid/media/Movies/Annie (2014)/Annie (2014) {tmdb-196867} - [Bluray-1080p][EAC3 5.1][x264]-PTer.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Shattered (2022)" mv "/mnt/unraid/media/Movies/Shattered (2022)/Shattered (2022) {tmdb-844398} - [Bluray-1080p][DTS 5.1][x264]-SbR.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Ironweed (1987)" mv "/mnt/unraid/media/Movies/Ironweed (1987)/Ironweed (1987) {tmdb-40962} - [Bluray-1080p][DTS 2.0][x264]-PSYCHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Hellraiser Judgment (2018)" mv "/mnt/unraid/media/Movies/Hellraiser Judgment (2018)/Hellraiser Judgment (2018) {tmdb-444149} - [Bluray-1080p][DTS 5.1][x264]-PSYCHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Hampstead (2017)" mv "/mnt/unraid/media/Movies/Hampstead (2017)/Hampstead (2017) {tmdb-441728} - [Bluray-1080p][AC3 5.1][x264]-KASHMiR.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Alice in Wonderland (1951)" mv "/mnt/unraid/media/Movies/Alice in Wonderland (1951)/Alice in Wonderland (1951) {tmdb-12092} - [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: American Outlaws (2023)" mv "/mnt/unraid/media/Movies/American Outlaws (2023)/American Outlaws (2023) {tmdb-567610} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-GPRS.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Paris Je T'aime (2006)" mv "/mnt/unraid/media/Movies/Paris Je T'aime (2006)/Paris Je T'aime (2006) {tmdb-2266} - [Bluray-1080p][AC3 5.1][x264]-HD4U.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Batman and Superman Battle of the Super Sons (2022)" mv "/mnt/unraid/media/Movies/Batman and Superman Battle of the Super Sons (2022)/Batman and Superman Battle of the Super Sons (2022) {tmdb-886396} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Shell (2012)" mv "/mnt/unraid/media/Movies/Shell (2012)/Shell (2012) {tmdb-135990} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Ip Man The Awakening (2021)" mv "/mnt/unraid/media/Movies/Ip Man The Awakening (2021)/Ip Man The Awakening (2021) {tmdb-875104} - [Bluray-1080p][DTS 5.1][x264]-EVO.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Into the Blue (2005)" mv "/mnt/unraid/media/Movies/Into the Blue (2005)/Into the Blue (2005) {tmdb-11968} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Golden Compass (2007)" mv "/mnt/unraid/media/Movies/The Golden Compass (2007)/The Golden Compass (2007) {tmdb-2268} - [Bluray-1080p][DTS-HD MA 7.1][VC1]-REFRACTiON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Get Smart (2008)" mv "/mnt/unraid/media/Movies/Get Smart (2008)/Get Smart (2008) {tmdb-11665} - [Bluray-1080p][AC3 5.1][x264]-iLL.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Gia (1998)" mv "/mnt/unraid/media/Movies/Gia (1998)/Gia (1998) {tmdb-14533} - {edition-Unrated} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: A Separation (2011)" mv "/mnt/unraid/media/Movies/A Separation (2011)/A Separation (2011) {tmdb-60243} - [Bluray-1080p][DTS 3.0][x264]-Dariush.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Petes Dragon (2016)" mv "/mnt/unraid/media/Movies/Petes Dragon (2016)/Petes Dragon (2016) {tmdb-294272} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Pinocchio (1940)" mv "/mnt/unraid/media/Movies/Pinocchio (1940)/Pinocchio (1940) {tmdb-10895} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Scooby-Doo (2002)" mv "/mnt/unraid/media/Movies/Scooby-Doo (2002)/Scooby-Doo (2002) {tmdb-9637} - [Bluray-1080p][AC3 5.1][VC1]-GERUDO.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Theres Something About Mary (1998)" mv "/mnt/unraid/media/Movies/Theres Something About Mary (1998)/Theres Something About Mary (1998) {tmdb-544} - [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Varsity Blues (1999)" mv "/mnt/unraid/media/Movies/Varsity Blues (1999)/Varsity Blues (1999) {tmdb-14709} - [Bluray-1080p][EAC3 5.1][DV HDR10][x265]-PTer.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Pursuit of Happyness (2006)" mv "/mnt/unraid/media/Movies/The Pursuit of Happyness (2006)/The Pursuit of Happyness (2006) {tmdb-1402} - [Bluray-1080p][DTS 5.1][x264]-VietHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Flight of the Navigator (1986)" mv "/mnt/unraid/media/Movies/Flight of the Navigator (1986)/Flight of the Navigator (1986) {tmdb-10122} - [Bluray-1080p][AAC 2.0][x264]-PTer.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Gettysburg (1993)" mv "/mnt/unraid/media/Movies/Gettysburg (1993)/Gettysburg (1993) {tmdb-10655} - {edition-Directors Cut} [Bluray-1080p][EAC3 5.1][x264]-j3rico.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: West Side Story (2021)" mv "/mnt/unraid/media/Movies/West Side Story (2021)/West Side Story (2021) {tmdb-511809} - [Bluray-1080p Proper][EAC3 Atmos 7.1][x264]-NTb.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Bucket List (2007)" mv "/mnt/unraid/media/Movies/The Bucket List (2007)/The Bucket List (2007) {tmdb-7350} - [Bluray-1080p][AC3 5.1][x264]-SbR.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Tremors (1990)" mv "/mnt/unraid/media/Movies/Tremors (1990)/Tremors (1990) {tmdb-9362} - [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Children of Men (2006)" mv "/mnt/unraid/media/Movies/Children of Men (2006)/Children of Men (2006) {tmdb-9693} - [Bluray-1080p][EAC3 5.1][x264]-HiDt.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Miracle on 34th Street (1947)" mv "/mnt/unraid/media/Movies/Miracle on 34th Street (1947)/Miracle on 34th Street (1947) {tmdb-11881} - [Bluray-1080p][EAC3 5.1][x264]-Spyfox.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Fleshpot on 42nd Street (1973)" mv "/mnt/unraid/media/Movies/Fleshpot on 42nd Street (1973)/Fleshpot on 42nd Street (1973) {tmdb-29194} - [Bluray-1080p][FLAC 1.0][x264]-HANDJOB.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Injustice (2021)" mv "/mnt/unraid/media/Movies/Injustice (2021)/Injustice (2021) {tmdb-831405} - [Bluray-1080p][DTS 5.1][x264]-ADE.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: An American Tail (1986)" mv "/mnt/unraid/media/Movies/An American Tail (1986)/An American Tail (1986) {tmdb-4978} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Blind (2023)" mv "/mnt/unraid/media/Movies/The Blind (2023)/The Blind (2023) {tmdb-1032194} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Superman (1978)" mv "/mnt/unraid/media/Movies/Superman (1978)/Superman (1978) {tmdb-1924} - [Bluray-1080p][EAC3 5.1][x264]-ZoroSenpai.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Pinocchio (2019)" mv "/mnt/unraid/media/Movies/Pinocchio (2019)/Pinocchio (2019) {tmdb-413518} - [Bluray-1080p][EAC3 5.1][x264]-EA.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: In a World. (2013)" mv "/mnt/unraid/media/Movies/In a World. (2013)/In a World. (2013) {tmdb-157360} - [Bluray-1080p][AC3 5.1][x264]-EbP.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Bad Luck Banging or Loony Porn (2021)" mv "/mnt/unraid/media/Movies/Bad Luck Banging or Loony Porn (2021)/Bad Luck Banging or Loony Porn (2021) {tmdb-790496} - [Bluray-1080p][EAC3 5.1][x264]-SPHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Transporter Refueled (2015)" mv "/mnt/unraid/media/Movies/The Transporter Refueled (2015)/The Transporter Refueled (2015) {tmdb-287948} - [Bluray-1080p][DTS 5.1][x264]-VietHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Spy Kids (2001)" mv "/mnt/unraid/media/Movies/Spy Kids (2001)/Spy Kids (2001) {tmdb-10054} - [Bluray-1080p][EAC3 5.1][x264]-Spyfox.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Commando (1985)" mv "/mnt/unraid/media/Movies/Commando (1985)/Commando (1985) {tmdb-10999} - [Bluray-1080p][DTS-HD MA 5.1][x264]-FraMeSToR.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Ted 2 (2015)" mv "/mnt/unraid/media/Movies/Ted 2 (2015)/Ted 2 (2015) {tmdb-214756} - {edition-Unrated} [Bluray-1080p][AC3 5.1][x264]-SA89.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: King Kong (2005)" mv "/mnt/unraid/media/Movies/King Kong (2005)/King Kong (2005) {tmdb-254} - {edition-Extended Cut} [Bluray-1080p][EAC3 7.1][HDR10][x265]-TDD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Social Network (2010)" mv "/mnt/unraid/media/Movies/The Social Network (2010)/The Social Network (2010) {tmdb-37799} - [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The War at Home (1996)" mv "/mnt/unraid/media/Movies/The War at Home (1996)/The War at Home (1996) {tmdb-59232} - [Bluray-1080p][AC3 2.0][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: RoboCop 3 (1993)" mv "/mnt/unraid/media/Movies/RoboCop 3 (1993)/RoboCop 3 (1993) {tmdb-5550} - [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: 100% Wolf (2020)" mv "/mnt/unraid/media/Movies/100% Wolf (2020)/100% Wolf (2020) {tmdb-520946} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Sea of Trees (2016)" mv "/mnt/unraid/media/Movies/The Sea of Trees (2016)/The Sea of Trees (2016) {tmdb-291351} - [Bluray-1080p][AC3 5.1][x264]-TayTO.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Senior Year (2022)" mv "/mnt/unraid/media/Movies/Senior Year (2022)/Senior Year (2022) {tmdb-800937} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Holy Mountain (1973)" mv "/mnt/unraid/media/Movies/The Holy Mountain (1973)/The Holy Mountain (1973) {tmdb-8327} - [Bluray-1080p][EAC3 5.1][x264]-ZQ.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Philadelphia (1993)" mv "/mnt/unraid/media/Movies/Philadelphia (1993)/Philadelphia (1993) {tmdb-9800} - [Bluray-1080p][EAC3 7.1][DV HDR10][x265]-c0kE.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Inspector Gadget (1999)" mv "/mnt/unraid/media/Movies/Inspector Gadget (1999)/Inspector Gadget (1999) {tmdb-332} - [DSNP][WEBDL-1080p][EAC3 5.1][h264]-Dooky.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Ninja Assassin (2009)" mv "/mnt/unraid/media/Movies/Ninja Assassin (2009)/Ninja Assassin (2009) {tmdb-22832} - [Bluray-1080p][DTS 5.1][x264]-HighCode.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Deja Vu (2006)" mv "/mnt/unraid/media/Movies/Deja Vu (2006)/Deja Vu (2006) {tmdb-7551} - [Bluray-1080p][AC3 5.1][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Sketch (2025)" mv "/mnt/unraid/media/Movies/Sketch (2025)/Sketch (2025) {tmdb-1319969} - [Bluray-1080p][AC3 5.1][x264]-ZoroSenpai.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Spy Kids 2 The Island of Lost Dreams (2002)" mv "/mnt/unraid/media/Movies/Spy Kids 2 The Island of Lost Dreams (2002)/Spy Kids 2 The Island of Lost Dreams (2002) {tmdb-9488} - [Hybrid][Bluray-1080p Proper][EAC3 5.1][x264]-SbR.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Wasp (2024)" mv "/mnt/unraid/media/Movies/The Wasp (2024)/The Wasp (2024) {tmdb-1019404} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: George Carlin 40 Years of Comedy (1997)" mv "/mnt/unraid/media/Movies/George Carlin 40 Years of Comedy (1997)/George Carlin 40 Years of Comedy (1997) {tmdb-34508} - [SDTV][AC3 2.0][x264]-UNKNOWN.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Spy Who Loved Me (1977)" mv "/mnt/unraid/media/Movies/The Spy Who Loved Me (1977)/The Spy Who Loved Me (1977) {tmdb-691} - [Bluray-1080p][DTS 5.1][x264]-EbP.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Grease (1978)" mv "/mnt/unraid/media/Movies/Grease (1978)/Grease (1978) {tmdb-621} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Bad Lieutenant Port of Call New Orleans (2009)" mv "/mnt/unraid/media/Movies/Bad Lieutenant Port of Call New Orleans (2009)/Bad Lieutenant Port of Call New Orleans (2009) {tmdb-11699} - [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: 1944 (2015)" mv "/mnt/unraid/media/Movies/1944 (2015)/1944 (2015) {tmdb-321303} - [Bluray-1080p][DTS-HD MA 5.1][x264]-GeneMige.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Shallow Hal (2001)" mv "/mnt/unraid/media/Movies/Shallow Hal (2001)/Shallow Hal (2001) {tmdb-9889} - [Bluray-1080p][EAC3 5.1][x264]-PTer.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Superman II The Richard Donner Cut (2006)" mv "/mnt/unraid/media/Movies/Superman II The Richard Donner Cut (2006)/Superman II The Richard Donner Cut (2006) {tmdb-624479} - [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Caddyshack (1980)" mv "/mnt/unraid/media/Movies/Caddyshack (1980)/Caddyshack (1980) {tmdb-11977} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: LEGO Batman The Movie DC Super Heroes Unite (2013)" mv "/mnt/unraid/media/Movies/LEGO Batman The Movie DC Super Heroes Unite (2013)/LEGO Batman The Movie DC Super Heroes Unite (2013) {tmdb-177271} - [Bluray-1080p][DTS 5.1][x264]-FANDANGO.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Die My Love (2025)" mv "/mnt/unraid/media/Movies/Die My Love (2025)/Die My Love (2025) {tmdb-1033148} - [AMZN][WEBDL-1080p][AC3 5.1][h264]-FLUX.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Cats (2019)" mv "/mnt/unraid/media/Movies/Cats (2019)/Cats (2019) {tmdb-536869} - [AMZN][WEBDL-720p][EAC3 5.1][h264]-NTG.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Bully (2011)" mv "/mnt/unraid/media/Movies/Bully (2011)/Bully (2011) {tmdb-84404} - [Bluray-1080p][DTS 5.1][x264]-Counterfeit.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Results (2015)" mv "/mnt/unraid/media/Movies/Results (2015)/Results (2015) {tmdb-294132} - [Remux-1080p][AC3 5.1][x264].mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Hotel Rwanda (2004)" mv "/mnt/unraid/media/Movies/Hotel Rwanda (2004)/Hotel Rwanda (2004) {tmdb-205} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Black Warrant (2022)" mv "/mnt/unraid/media/Movies/Black Warrant (2022)/Black Warrant (2022) {tmdb-983768} - [Bluray-1080p][DTS-HD MA 7.1][x264]-CAUSTiC.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Skylines (2020)" mv "/mnt/unraid/media/Movies/Skylines (2020)/Skylines (2020) {tmdb-560144} - [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Jack Frost (1998)" mv "/mnt/unraid/media/Movies/Jack Frost (1998)/Jack Frost (1998) {tmdb-9745} - [AMZN][WEBDL-1080p][EAC3 5.1][x264]-monkee.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Soccer Football Movie (2022)" mv "/mnt/unraid/media/Movies/The Soccer Football Movie (2022)/The Soccer Football Movie (2022) {tmdb-1037858} - [NF][WEBDL-1080p][EAC3 5.1][x264]-SMURF.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: G.I. Joe Retaliation (2013)" mv "/mnt/unraid/media/Movies/G.I. Joe Retaliation (2013)/G.I. Joe Retaliation (2013) {tmdb-72559} - {edition-Extended} [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Believer (2001)" mv "/mnt/unraid/media/Movies/The Believer (2001)/The Believer (2001) {tmdb-4012} - [Bluray-1080p][EAC3 5.1][x264]-WiLDCAT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Blackcoats Daughter (2017)" mv "/mnt/unraid/media/Movies/The Blackcoats Daughter (2017)/The Blackcoats Daughter (2017) {tmdb-334536} - [Bluray-1080p][AC3 5.1][x264]-SA89.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Elvira Mistress of the Dark (1988)" mv "/mnt/unraid/media/Movies/Elvira Mistress of the Dark (1988)/Elvira Mistress of the Dark (1988) {tmdb-5680} - [Bluray-1080p][FLAC 2.0][DV HDR10][x265]-coffee.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Swan Princess (1994)" mv "/mnt/unraid/media/Movies/The Swan Princess (1994)/The Swan Princess (1994) {tmdb-22586} - [Bluray-1080p][AC3 2.0][x264]-AnimeToons.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Halloween H20 20 Years Later (1998)" mv "/mnt/unraid/media/Movies/Halloween H20 20 Years Later (1998)/Halloween H20 20 Years Later (1998) {tmdb-11675} - [Bluray-1080p][EAC3 5.1][x264]-c0kE.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Their Finest (2017)" mv "/mnt/unraid/media/Movies/Their Finest (2017)/Their Finest (2017) {tmdb-340101} - [Bluray-1080p][AC3 5.1][x264]-VietHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: I Love Trouble (1994)" mv "/mnt/unraid/media/Movies/I Love Trouble (1994)/I Love Trouble (1994) {tmdb-10879} - [Bluray-1080p][DTS 5.1][x264]-PSYCHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Batman The Killing Joke (2016)" mv "/mnt/unraid/media/Movies/Batman The Killing Joke (2016)/Batman The Killing Joke (2016) {tmdb-382322} - [Bluray-1080p][AC3 5.1][x264]-decibeL.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Thomas Crown Affair (1999)" mv "/mnt/unraid/media/Movies/The Thomas Crown Affair (1999)/The Thomas Crown Affair (1999) {tmdb-913} - [Bluray-1080p][AC3 5.1][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Red Planet (2000)" mv "/mnt/unraid/media/Movies/Red Planet (2000)/Red Planet (2000) {tmdb-8870} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: You Were Never Really Here (2017)" mv "/mnt/unraid/media/Movies/You Were Never Really Here (2017)/You Were Never Really Here (2017) {tmdb-398181} - [Bluray-1080p][DTS 5.1][x264]-NCmt.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Good the Bad and the Ugly (1966)" mv "/mnt/unraid/media/Movies/The Good the Bad and the Ugly (1966)/The Good the Bad and the Ugly (1966) {tmdb-429} - [Bluray-1080p][FLAC 1.0][x264]-ZoroSenpai.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Monster High The Movie (2022)" mv "/mnt/unraid/media/Movies/Monster High The Movie (2022)/Monster High The Movie (2022) {tmdb-335795} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Firestarter (1984)" mv "/mnt/unraid/media/Movies/Firestarter (1984)/Firestarter (1984) {tmdb-11495} - [Bluray-1080p][FLAC 2.0][x264]-SbR.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Father of the Year (2018)" mv "/mnt/unraid/media/Movies/Father of the Year (2018)/Father of the Year (2018) {tmdb-531949} - [NF][WEBRip-1080p][EAC3 5.1][x264]-NTb.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Official Competition (2021)" mv "/mnt/unraid/media/Movies/Official Competition (2021)/Official Competition (2021) {tmdb-668640} - [Bluray-1080p][DTS 5.1][x264]-NO.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Insomnia (2002)" mv "/mnt/unraid/media/Movies/Insomnia (2002)/Insomnia (2002) {tmdb-320} - [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Mummy (1999)" mv "/mnt/unraid/media/Movies/The Mummy (1999)/The Mummy (1999) {tmdb-564} - [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Wrecked (2010)" mv "/mnt/unraid/media/Movies/Wrecked (2010)/Wrecked (2010) {tmdb-50838} - [Bluray-1080p][DTS 5.1][x264]-OPS.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Home (2015)" mv "/mnt/unraid/media/Movies/Home (2015)/Home (2015) {tmdb-228161} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: For Your Eyes Only (1981)" mv "/mnt/unraid/media/Movies/For Your Eyes Only (1981)/For Your Eyes Only (1981) {tmdb-699} - [Bluray-1080p][DTS 5.1][x264]-SbR.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Santa Clause 2 (2002)" mv "/mnt/unraid/media/Movies/The Santa Clause 2 (2002)/The Santa Clause 2 (2002) {tmdb-9021} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Purple Rain (1984)" mv "/mnt/unraid/media/Movies/Purple Rain (1984)/Purple Rain (1984) {tmdb-13763} - [Bluray-1080p][EAC3 5.1][HDR10][x265]-BV.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Love at First Sight (2023)" mv "/mnt/unraid/media/Movies/Love at First Sight (2023)/Love at First Sight (2023) {tmdb-353577} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-Kitsune.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Breakfast at Tiffany's (1961)" mv "/mnt/unraid/media/Movies/Breakfast at Tiffany's (1961)/Breakfast at Tiffany's (1961) {tmdb-164} - [Bluray-1080p][DTS 5.1][x264]-CRiSC.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Runner Runner (2013)" mv "/mnt/unraid/media/Movies/Runner Runner (2013)/Runner Runner (2013) {tmdb-146238} - [Bluray-1080p][DTS 5.1][x264]-SbR.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: All the Beauty and the Bloodshed (2022)" mv "/mnt/unraid/media/Movies/All the Beauty and the Bloodshed (2022)/All the Beauty and the Bloodshed (2022) {tmdb-1004663} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Book of Eli (2010)" mv "/mnt/unraid/media/Movies/The Book of Eli (2010)/The Book of Eli (2010) {tmdb-20504} - [Bluray-1080p][DTS-HD MA 5.1][x264]-FraMeSToR.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Grown Ups (2010)" mv "/mnt/unraid/media/Movies/Grown Ups (2010)/Grown Ups (2010) {tmdb-38365} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Scary Movie 2 (2001)" mv "/mnt/unraid/media/Movies/Scary Movie 2 (2001)/Scary Movie 2 (2001) {tmdb-4248} - [Hybrid][Bluray-1080p][EAC3 5.1][x264]-ZoroSenpai.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Shall We Dance (2004)" mv "/mnt/unraid/media/Movies/Shall We Dance (2004)/Shall We Dance (2004) {tmdb-4380} - [Bluray-1080p][EAC3 5.1][x264]-ZoroSenpai.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Final Destination 3 (2006)" mv "/mnt/unraid/media/Movies/Final Destination 3 (2006)/Final Destination 3 (2006) {tmdb-9286} - [Bluray-1080p][EAC3 5.1][x264]-PTer.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Crossing Over (2009)" mv "/mnt/unraid/media/Movies/Crossing Over (2009)/Crossing Over (2009) {tmdb-15577} - [Hybrid][Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Polar (2019)" mv "/mnt/unraid/media/Movies/Polar (2019)/Polar (2019) {tmdb-483906} - [NF][WEBDL-1080p][EAC3 5.1][x264]-NTG.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The King of Staten Island (2020)" mv "/mnt/unraid/media/Movies/The King of Staten Island (2020)/The King of Staten Island (2020) {tmdb-579583} - [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Jason Goes to Hell The Final Friday (1993)" mv "/mnt/unraid/media/Movies/Jason Goes to Hell The Final Friday (1993)/Jason Goes to Hell The Final Friday (1993) {tmdb-10285} - [Bluray-1080p][DTS 5.1][x264]-LiViDiTY.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Transformers Dark of the Moon (2011)" mv "/mnt/unraid/media/Movies/Transformers Dark of the Moon (2011)/Transformers Dark of the Moon (2011) {tmdb-38356} - [Hybrid][Bluray-1080p][EAC3 Atmos 5.1][DV HDR10][x265]-SQS.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Mixed Nuts (1994)" mv "/mnt/unraid/media/Movies/Mixed Nuts (1994)/Mixed Nuts (1994) {tmdb-24070} - [AMZN][WEBRip-1080p][EAC3 2.0][x264]-ABM.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Big Chill (1983)" mv "/mnt/unraid/media/Movies/The Big Chill (1983)/The Big Chill (1983) {tmdb-12560} - [Bluray-1080p][DTS 5.1][x264]-HD4U.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Major League II (1994)" mv "/mnt/unraid/media/Movies/Major League II (1994)/Major League II (1994) {tmdb-11067} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Shoot 'Em Up (2007)" mv "/mnt/unraid/media/Movies/Shoot 'Em Up (2007)/Shoot 'Em Up (2007) {tmdb-4141} - [Bluray-1080p][EAC3 7.1][x264]-PIS.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Bambi (1942)" mv "/mnt/unraid/media/Movies/Bambi (1942)/Bambi (1942) {tmdb-3170} - [Bluray-1080p][DTS-ES 6.1][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Darkest Minds (2018)" mv "/mnt/unraid/media/Movies/The Darkest Minds (2018)/The Darkest Minds (2018) {tmdb-445651} - [Bluray-1080p][DTS-ES 5.1][x264]-TayTO.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Shanghai Knights (2003)" mv "/mnt/unraid/media/Movies/Shanghai Knights (2003)/Shanghai Knights (2003) {tmdb-6038} - [Bluray-1080p][DTS 5.1][x264]-BestHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Captain Underpants The First Epic Movie (2017)" mv "/mnt/unraid/media/Movies/Captain Underpants The First Epic Movie (2017)/Captain Underpants The First Epic Movie (2017) {tmdb-268531} - [Bluray-1080p][AC3 5.1][x264]-VietHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Machine (2023)" mv "/mnt/unraid/media/Movies/The Machine (2023)/The Machine (2023) {tmdb-647250} - [Bluray-1080p][DTS-HD MA 5.1][x264]-MiMESiS.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Friday the 13th Part III (1982)" mv "/mnt/unraid/media/Movies/Friday the 13th Part III (1982)/Friday the 13th Part III (1982) {tmdb-9728} - [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Free Willy (1993)" mv "/mnt/unraid/media/Movies/Free Willy (1993)/Free Willy (1993) {tmdb-1634} - [Bluray-1080p][AC3 5.1][x264]-EbP.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Silence (2016)" mv "/mnt/unraid/media/Movies/Silence (2016)/Silence (2016) {tmdb-68730} - [Bluray-1080p][DTS-HD MA 5.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Better Luck Tomorrow (2002)" mv "/mnt/unraid/media/Movies/Better Luck Tomorrow (2002)/Better Luck Tomorrow (2002) {tmdb-14290} - [Bluray-1080p][EAC3 5.1][x264]-PERFETTO.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Colony (2021)" mv "/mnt/unraid/media/Movies/The Colony (2021)/The Colony (2021) {tmdb-760873} - [Bluray-1080p][EAC3 5.1][x264]-HiDt.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Hard Eight (1997)" mv "/mnt/unraid/media/Movies/Hard Eight (1997)/Hard Eight (1997) {tmdb-8052} - [Bluray-1080p][FLAC 2.0][x264]-HANDJOB.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Elizabeth The Golden Age (2007)" mv "/mnt/unraid/media/Movies/Elizabeth The Golden Age (2007)/Elizabeth The Golden Age (2007) {tmdb-4517} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Escape Room (2019)" mv "/mnt/unraid/media/Movies/Escape Room (2019)/Escape Room (2019) {tmdb-522681} - [Bluray-1080p Proper][DTS 5.1][x264]-DRONES.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Purge Anarchy (2014)" mv "/mnt/unraid/media/Movies/The Purge Anarchy (2014)/The Purge Anarchy (2014) {tmdb-238636} - [Bluray-1080p][AC3 5.1][HDR10][x265]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Star Trek (2009)" mv "/mnt/unraid/media/Movies/Star Trek (2009)/Star Trek (2009) {tmdb-13475} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Escape from Pretoria (2020)" mv "/mnt/unraid/media/Movies/Escape from Pretoria (2020)/Escape from Pretoria (2020) {tmdb-502425} - [Bluray-1080p][EAC3 5.1][x264]-EDPH.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Glass (2019)" mv "/mnt/unraid/media/Movies/Glass (2019)/Glass (2019) {tmdb-450465} - [Hybrid][Bluray-1080p Proper][EAC3 7.1][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Sgt. Stubby An American Hero (2018)" mv "/mnt/unraid/media/Movies/Sgt. Stubby An American Hero (2018)/Sgt. Stubby An American Hero (2018) {tmdb-433694} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-GPRS.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Man Who Knew Infinity (2016)" mv "/mnt/unraid/media/Movies/The Man Who Knew Infinity (2016)/The Man Who Knew Infinity (2016) {tmdb-353326} - [Bluray-1080p][AC3 5.1][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Imaginarium of Doctor Parnassus (2009)" mv "/mnt/unraid/media/Movies/The Imaginarium of Doctor Parnassus (2009)/The Imaginarium of Doctor Parnassus (2009) {tmdb-8054} - [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Porky's (1981)" mv "/mnt/unraid/media/Movies/Porky's (1981)/Porky's (1981) {tmdb-10246} - [Bluray-1080p][AC3 1.0][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Radio Days (1987)" mv "/mnt/unraid/media/Movies/Radio Days (1987)/Radio Days (1987) {tmdb-30890} - [Bluray-1080p][DTS-HD MA 1.0][x264]-GeneMige.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: 27 Dresses (2008)" mv "/mnt/unraid/media/Movies/27 Dresses (2008)/27 Dresses (2008) {tmdb-6557} - [Bluray-1080p Proper][EAC3 5.1][x264]-hallowed.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Fight Club (1999)" mv "/mnt/unraid/media/Movies/Fight Club (1999)/Fight Club (1999) {tmdb-550} - [Bluray-1080p][EAC3 5.1][x264]-ATELiER.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Flying Leathernecks (1951)" mv "/mnt/unraid/media/Movies/Flying Leathernecks (1951)/Flying Leathernecks (1951) {tmdb-47555} - [AMZN][WEBDL-1080p][EAC3 2.0][h264]-GPRS.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Code 8 (2019)" mv "/mnt/unraid/media/Movies/Code 8 (2019)/Code 8 (2019) {tmdb-461130} - [Bluray-1080p][EAC3 5.1][x264]-EDPH.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Devils Advocate (1997)" mv "/mnt/unraid/media/Movies/The Devils Advocate (1997)/The Devils Advocate (1997) {tmdb-1813} - {edition-Unrated} [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Alice Through the Looking Glass (2016)" mv "/mnt/unraid/media/Movies/Alice Through the Looking Glass (2016)/Alice Through the Looking Glass (2016) {tmdb-241259} - [Bluray-1080p][DTS 5.1][x264]-VietHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Armageddon Time (2022)" mv "/mnt/unraid/media/Movies/Armageddon Time (2022)/Armageddon Time (2022) {tmdb-615952} - [Bluray-1080p][DTS-HD MA 5.1][x264]-PiGNUS.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Ghosts of the Abyss (2003)" mv "/mnt/unraid/media/Movies/Ghosts of the Abyss (2003)/Ghosts of the Abyss (2003) {tmdb-24982} - [Bluray-1080p][AC3 5.1][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Nightcrawler (2014)" mv "/mnt/unraid/media/Movies/Nightcrawler (2014)/Nightcrawler (2014) {tmdb-242582} - [Bluray-1080p Proper][AC3 5.1][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Lion King (2019)" mv "/mnt/unraid/media/Movies/The Lion King (2019)/The Lion King (2019) {tmdb-420818} - [Bluray-1080p][EAC3 Atmos 5.1][DV HDR10][x265]-SM737.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: All the Right Moves (1983)" mv "/mnt/unraid/media/Movies/All the Right Moves (1983)/All the Right Moves (1983) {tmdb-18172} - [Bluray-1080p][AC3 5.1][x264]-Spekt0r.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Smokey and the Bandit II (1980)" mv "/mnt/unraid/media/Movies/Smokey and the Bandit II (1980)/Smokey and the Bandit II (1980) {tmdb-12705} - [Bluray-1080p][AC3 2.0][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Moonrise Kingdom (2012)" mv "/mnt/unraid/media/Movies/Moonrise Kingdom (2012)/Moonrise Kingdom (2012) {tmdb-83666} - [Bluray-1080p][EAC3 5.1][x264]-ZoroSenpai.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Hasan Minhaj The Kings Jester (2022)" mv "/mnt/unraid/media/Movies/Hasan Minhaj The Kings Jester (2022)/Hasan Minhaj The Kings Jester (2022) {tmdb-1023901} - [NF][WEBDL-1080p][EAC3 5.1][x264]-SMURF.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Stripes (1981)" mv "/mnt/unraid/media/Movies/Stripes (1981)/Stripes (1981) {tmdb-10890} - {edition-Extended Cut} [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Peppermint (2018)" mv "/mnt/unraid/media/Movies/Peppermint (2018)/Peppermint (2018) {tmdb-458594} - [Bluray-1080p][EAC3 7.1][x264]-j3rico.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Better Watch Out (2017)" mv "/mnt/unraid/media/Movies/Better Watch Out (2017)/Better Watch Out (2017) {tmdb-406994} - [Bluray-1080p][DTS-HD MA 5.1][h264]-bluejester.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Charlie Wilsons War (2007)" mv "/mnt/unraid/media/Movies/Charlie Wilsons War (2007)/Charlie Wilsons War (2007) {tmdb-6538} - [Bluray-1080p][EAC3 5.1][x264]-HiDt.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Batman Under the Red Hood (2010)" mv "/mnt/unraid/media/Movies/Batman Under the Red Hood (2010)/Batman Under the Red Hood (2010) {tmdb-40662} - [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Dont Breathe 2 (2021)" mv "/mnt/unraid/media/Movies/Dont Breathe 2 (2021)/Dont Breathe 2 (2021) {tmdb-482373} - [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Aladdin (2019)" mv "/mnt/unraid/media/Movies/Aladdin (2019)/Aladdin (2019) {tmdb-420817} - [Bluray-1080p][EAC3 7.1][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Volumes of Blood (2015)" mv "/mnt/unraid/media/Movies/Volumes of Blood (2015)/Volumes of Blood (2015) {tmdb-342818} - [Bluray-1080p][AC3 2.0][x264]-HANDJOB.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Perfect Host (2010)" mv "/mnt/unraid/media/Movies/The Perfect Host (2010)/The Perfect Host (2010) {tmdb-66195} - [Bluray-1080p][DTS 5.1][x264]-aAF.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Network (1976)" mv "/mnt/unraid/media/Movies/Network (1976)/Network (1976) {tmdb-10774} - [Bluray-1080p][FLAC 1.0][x264]-IDE.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Exorcism of God (2022)" mv "/mnt/unraid/media/Movies/The Exorcism of God (2022)/The Exorcism of God (2022) {tmdb-836225} - [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Spaceballs (1987)" mv "/mnt/unraid/media/Movies/Spaceballs (1987)/Spaceballs (1987) {tmdb-957} - [Bluray-1080p][EAC3 5.1][DV HDR10][x265]-MovieMan.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Death of a Salesman (1985)" mv "/mnt/unraid/media/Movies/Death of a Salesman (1985)/Death of a Salesman (1985) {tmdb-12615} - [Bluray-1080p][AC3 2.0][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Mighty Ducks (1992)" mv "/mnt/unraid/media/Movies/The Mighty Ducks (1992)/The Mighty Ducks (1992) {tmdb-10414} - [Bluray-1080p][DTS 5.1][x264]-SbR.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Mickey Blue Eyes (1999)" mv "/mnt/unraid/media/Movies/Mickey Blue Eyes (1999)/Mickey Blue Eyes (1999) {tmdb-10154} - [WEBDL-1080p][AC3 5.1][x264]-DiMEPiECE.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: 8-Bit Christmas (2021)" mv "/mnt/unraid/media/Movies/8-Bit Christmas (2021)/8-Bit Christmas (2021) {tmdb-802217} - [HMAX][WEBDL-1080p][EAC3 Atmos 5.1][x264]-TEPES.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Finding Nemo (2003)" mv "/mnt/unraid/media/Movies/Finding Nemo (2003)/Finding Nemo (2003) {tmdb-12} - [Bluray-1080p][AC3 5.1][x264]-EbP.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The NeverEnding Story (1984)" mv "/mnt/unraid/media/Movies/The NeverEnding Story (1984)/The NeverEnding Story (1984) {tmdb-34584} - [Bluray-1080p][EAC3 5.1][x264]-PTer.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Anora (2024)" mv "/mnt/unraid/media/Movies/Anora (2024)/Anora (2024) {tmdb-1064213} - [Bluray-1080p][EAC3 5.1][x264]-TDD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Paycheck (2003)" mv "/mnt/unraid/media/Movies/Paycheck (2003)/Paycheck (2003) {tmdb-9620} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Revolver (2005)" mv "/mnt/unraid/media/Movies/Revolver (2005)/Revolver (2005) {tmdb-10851} - {edition-Directors Cut} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Harakiri (1962)" mv "/mnt/unraid/media/Movies/Harakiri (1962)/Harakiri (1962) {tmdb-14537} - [Bluray-1080p][FLAC 2.0][x264]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The SpongeBob SquarePants Movie (2004)" mv "/mnt/unraid/media/Movies/The SpongeBob SquarePants Movie (2004)/The SpongeBob SquarePants Movie (2004) {tmdb-11836} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: All Is Lost (2013)" mv "/mnt/unraid/media/Movies/All Is Lost (2013)/All Is Lost (2013) {tmdb-152747} - [Bluray-1080p][DTS 5.1][x264]-TayTO.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Heaven Knows What (2015)" mv "/mnt/unraid/media/Movies/Heaven Knows What (2015)/Heaven Knows What (2015) {tmdb-285024} - [Bluray-1080p][FLAC 2.0][x264]-PTer.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Moonlight (2016)" mv "/mnt/unraid/media/Movies/Moonlight (2016)/Moonlight (2016) {tmdb-376867} - [Bluray-1080p][DTS-HD MA 5.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Dave Chappelle The Closer (2021)" mv "/mnt/unraid/media/Movies/Dave Chappelle The Closer (2021)/Dave Chappelle The Closer (2021) {tmdb-879540} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-NPMS.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Nut Job 2 Nutty by Nature (2017)" mv "/mnt/unraid/media/Movies/The Nut Job 2 Nutty by Nature (2017)/The Nut Job 2 Nutty by Nature (2017) {tmdb-335777} - [Bluray-1080p][DTS 5.1][x264]-VietHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Birdcage (1996)" mv "/mnt/unraid/media/Movies/The Birdcage (1996)/The Birdcage (1996) {tmdb-11000} - [Bluray-1080p][AC3 5.1][x264]-BMF.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Striptease (1996)" mv "/mnt/unraid/media/Movies/Striptease (1996)/Striptease (1996) {tmdb-9879} - [Bluray-1080p][EAC3 5.1][x264]-coffee.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Spies Like Us (1985)" mv "/mnt/unraid/media/Movies/Spies Like Us (1985)/Spies Like Us (1985) {tmdb-9080} - [Bluray-1080p][DTS 2.0][x264]-HDC.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: War Horse (2011)" mv "/mnt/unraid/media/Movies/War Horse (2011)/War Horse (2011) {tmdb-57212} - [Bluray-1080p][AC3 5.1][x264]-EbP.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Batman Assault on Arkham (2014)" mv "/mnt/unraid/media/Movies/Batman Assault on Arkham (2014)/Batman Assault on Arkham (2014) {tmdb-242643} - [Bluray-1080p][DTS 5.1][x264]-SbR.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Night of the Demons 2 (1994)" mv "/mnt/unraid/media/Movies/Night of the Demons 2 (1994)/Night of the Demons 2 (1994) {tmdb-24925} - [Hybrid][Bluray-1080p][FLAC 2.0][x264]-MaG.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Jeepers Creepers (2001)" mv "/mnt/unraid/media/Movies/Jeepers Creepers (2001)/Jeepers Creepers (2001) {tmdb-8922} - [Bluray-1080p][DTS 5.1][x264]-TayTO.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Spiderhead (2022)" mv "/mnt/unraid/media/Movies/Spiderhead (2022)/Spiderhead (2022) {tmdb-615469} - [NF][WEBRip-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Back to the Future (1985)" mv "/mnt/unraid/media/Movies/Back to the Future (1985)/Back to the Future (1985) {tmdb-105} - [Bluray-1080p Proper][FLAC 2.0][DV HDR10Plus][x265]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Cannonball Run II (1984)" mv "/mnt/unraid/media/Movies/Cannonball Run II (1984)/Cannonball Run II (1984) {tmdb-11950} - [Bluray-1080p Proper][EAC3 5.1][x264]-Nufcfan.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Firewalker (1986)" mv "/mnt/unraid/media/Movies/Firewalker (1986)/Firewalker (1986) {tmdb-12715} - [Bluray-1080p][AC3 2.0][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Night at the Museum Battle of the Smithsonian (2009)" mv "/mnt/unraid/media/Movies/Night at the Museum Battle of the Smithsonian (2009)/Night at the Museum Battle of the Smithsonian (2009) {tmdb-18360} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Hoodwinked! (2005)" mv "/mnt/unraid/media/Movies/Hoodwinked! (2005)/Hoodwinked! (2005) {tmdb-10982} - [Bluray-1080p][EAC3 5.1][x264]-Spyfox.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Cell (2000)" mv "/mnt/unraid/media/Movies/The Cell (2000)/The Cell (2000) {tmdb-8843} - [Bluray-1080p][EAC3 5.1][x264]-c0kE.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Passenger 57 (1992)" mv "/mnt/unraid/media/Movies/Passenger 57 (1992)/Passenger 57 (1992) {tmdb-10538} - [Bluray-1080p][AC3 5.1][x264]-PTer.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Spider-Man No Way Home (2021)" mv "/mnt/unraid/media/Movies/Spider-Man No Way Home (2021)/Spider-Man No Way Home (2021) {tmdb-634649} - [Bluray-1080p][EAC3 5.1][x264]-Geek.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Sum of All Fears (2002)" mv "/mnt/unraid/media/Movies/The Sum of All Fears (2002)/The Sum of All Fears (2002) {tmdb-4614} - [Bluray-1080p][EAC3 5.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Disappearance of Alice Creed (2009)" mv "/mnt/unraid/media/Movies/The Disappearance of Alice Creed (2009)/The Disappearance of Alice Creed (2009) {tmdb-38542} - [Bluray-1080p][EAC3 5.1][x264]-MainFrame.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Cheaper by the Dozen 2 (2005)" mv "/mnt/unraid/media/Movies/Cheaper by the Dozen 2 (2005)/Cheaper by the Dozen 2 (2005) {tmdb-9641} - [Bluray-1080p][AC3 5.1][x264]-HANDJOB.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Snowman (1982)" mv "/mnt/unraid/media/Movies/The Snowman (1982)/The Snowman (1982) {tmdb-13396} - [WEBDL-1080p][AAC 2.0][h264]-SATS.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Regretting You (2025)" mv "/mnt/unraid/media/Movies/Regretting You (2025)/Regretting You (2025) {tmdb-1327862} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-Kitsune.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Outrun (2024)" mv "/mnt/unraid/media/Movies/The Outrun (2024)/The Outrun (2024) {tmdb-785542} - [Bluray-1080p][EAC3 7.1][x264]-SbR.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Flags of Our Fathers (2006)" mv "/mnt/unraid/media/Movies/Flags of Our Fathers (2006)/Flags of Our Fathers (2006) {tmdb-3683} - [Bluray-1080p][AC3 5.1][x264]-SA89.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: I Robot (2004)" mv "/mnt/unraid/media/Movies/I Robot (2004)/I Robot (2004) {tmdb-2048} - [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Passion of the Christ (2004)" mv "/mnt/unraid/media/Movies/The Passion of the Christ (2004)/The Passion of the Christ (2004) {tmdb-615} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Vision Quest (1985)" mv "/mnt/unraid/media/Movies/Vision Quest (1985)/Vision Quest (1985) {tmdb-30069} - [AMZN][WEBDL-1080p][EAC3 2.0][h264]-AESop.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Armor (2024)" mv "/mnt/unraid/media/Movies/Armor (2024)/Armor (2024) {tmdb-1182387} - [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Gary Owen #DoinWhatIDo (2019)" mv "/mnt/unraid/media/Movies/Gary Owen #DoinWhatIDo (2019)/Gary Owen #DoinWhatIDo (2019) {tmdb-625308} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-HOLUP.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Jersey Boys (2014)" mv "/mnt/unraid/media/Movies/Jersey Boys (2014)/Jersey Boys (2014) {tmdb-209451} - [Bluray-1080p][AC3 5.1][x264]-VietHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Medieval (2022)" mv "/mnt/unraid/media/Movies/Medieval (2022)/Medieval (2022) {tmdb-551271} - [Bluray-1080p][AC3 5.1][x264]-playHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Abbott and Costello Go to Mars (1953)" mv "/mnt/unraid/media/Movies/Abbott and Costello Go to Mars (1953)/Abbott and Costello Go to Mars (1953) {tmdb-33472} - [Bluray-1080p][FLAC 2.0][x264]-RetroPeeps.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Absent-Minded Professor (1961)" mv "/mnt/unraid/media/Movies/The Absent-Minded Professor (1961)/The Absent-Minded Professor (1961) {tmdb-17984} - [Bluray-1080p][AC3 2.0][x264]-RetroPeeps.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Retirement Plan (2023)" mv "/mnt/unraid/media/Movies/The Retirement Plan (2023)/The Retirement Plan (2023) {tmdb-866346} - [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Friday the 13th A New Beginning (1985)" mv "/mnt/unraid/media/Movies/Friday the 13th A New Beginning (1985)/Friday the 13th A New Beginning (1985) {tmdb-9731} - [Bluray-1080p][DTS 5.1][x264]-PublicHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The A-Team (2010)" mv "/mnt/unraid/media/Movies/The A-Team (2010)/The A-Team (2010) {tmdb-34544} - {edition-Extended Cut} [Bluray-1080p][AC3 5.1][x264]-EbP.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Alvin and the Chipmunks The Road Chip (2015)" mv "/mnt/unraid/media/Movies/Alvin and the Chipmunks The Road Chip (2015)/Alvin and the Chipmunks The Road Chip (2015) {tmdb-258509} - [Bluray-1080p][DTS-HD MA 7.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Fast Charlie (2023)" mv "/mnt/unraid/media/Movies/Fast Charlie (2023)/Fast Charlie (2023) {tmdb-945937} - [Bluray-1080p][EAC3 5.1][x264]-HiDt.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: We Bought a Zoo (2011)" mv "/mnt/unraid/media/Movies/We Bought a Zoo (2011)/We Bought a Zoo (2011) {tmdb-74465} - [Bluray-1080p][EAC3 5.1][x264]-TayTO.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Krampus (2015)" mv "/mnt/unraid/media/Movies/Krampus (2015)/Krampus (2015) {tmdb-287903} - [Bluray-1080p][EAC3 7.1][x264]-coffee.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Logans Run (1976)" mv "/mnt/unraid/media/Movies/Logans Run (1976)/Logans Run (1976) {tmdb-10803} - [Bluray-1080p][EAC3 5.1][x264]-BitHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: No Strings Attached (2011)" mv "/mnt/unraid/media/Movies/No Strings Attached (2011)/No Strings Attached (2011) {tmdb-41630} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Halloween 5 The Revenge of Michael Myers (1989)" mv "/mnt/unraid/media/Movies/Halloween 5 The Revenge of Michael Myers (1989)/Halloween 5 The Revenge of Michael Myers (1989) {tmdb-11361} - [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Assassins (1995)" mv "/mnt/unraid/media/Movies/Assassins (1995)/Assassins (1995) {tmdb-9691} - [Bluray-1080p][EAC3 5.1][x264]-LoRD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Short Circuit 2 (1988)" mv "/mnt/unraid/media/Movies/Short Circuit 2 (1988)/Short Circuit 2 (1988) {tmdb-11966} - [Bluray-1080p][FLAC 2.0][x264]-MaG.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Last Christmas (2019)" mv "/mnt/unraid/media/Movies/Last Christmas (2019)/Last Christmas (2019) {tmdb-549053} - [Bluray-1080p Proper][DTS 5.1][x264]-GUACAMOLE.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: National Lampoons Christmas Vacation (1989)" mv "/mnt/unraid/media/Movies/National Lampoons Christmas Vacation (1989)/National Lampoons Christmas Vacation (1989) {tmdb-5825} - [Bluray-1080p][FLAC 2.0][x264]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Bambi II (2006)" mv "/mnt/unraid/media/Movies/Bambi II (2006)/Bambi II (2006) {tmdb-13205} - [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: 1BR (2019)" mv "/mnt/unraid/media/Movies/1BR (2019)/1BR (2019) {tmdb-611605} - [Bluray-1080p][DTS 5.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Marmaduke (2010)" mv "/mnt/unraid/media/Movies/Marmaduke (2010)/Marmaduke (2010) {tmdb-38579} - [Bluray-1080p][DTS 5.1][x264]-LCHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Shrek (2001)" mv "/mnt/unraid/media/Movies/Shrek (2001)/Shrek (2001) {tmdb-808} - [Bluray-1080p][AC3 5.1][x264]-SA89.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Alice in Wonderland (2010)" mv "/mnt/unraid/media/Movies/Alice in Wonderland (2010)/Alice in Wonderland (2010) {tmdb-12155} - [Bluray-1080p][AC3 5.1][x264]-EbP.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Dumbo (2019)" mv "/mnt/unraid/media/Movies/Dumbo (2019)/Dumbo (2019) {tmdb-329996} - [Bluray-1080p][DTS 5.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Broken Arrow (1996)" mv "/mnt/unraid/media/Movies/Broken Arrow (1996)/Broken Arrow (1996) {tmdb-9208} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Wolfman (2010)" mv "/mnt/unraid/media/Movies/The Wolfman (2010)/The Wolfman (2010) {tmdb-7978} - [Bluray-1080p][EAC3 7.1][DV HDR10][x265]-BRUTE.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Winnie the Pooh (2011)" mv "/mnt/unraid/media/Movies/Winnie the Pooh (2011)/Winnie the Pooh (2011) {tmdb-51162} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Scary Movie 4 (2006)" mv "/mnt/unraid/media/Movies/Scary Movie 4 (2006)/Scary Movie 4 (2006) {tmdb-4257} - [Bluray-1080p Proper][AC3 5.1][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Ray Donovan The Movie (2022)" mv "/mnt/unraid/media/Movies/Ray Donovan The Movie (2022)/Ray Donovan The Movie (2022) {tmdb-800425} - [Bluray-1080p Proper][EAC3 5.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Little Mermaid Ariels Beginning (2008)" mv "/mnt/unraid/media/Movies/The Little Mermaid Ariels Beginning (2008)/The Little Mermaid Ariels Beginning (2008) {tmdb-13676} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Open Season 3 (2010)" mv "/mnt/unraid/media/Movies/Open Season 3 (2010)/Open Season 3 (2010) {tmdb-51170} - [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Moonraker (1979)" mv "/mnt/unraid/media/Movies/Moonraker (1979)/Moonraker (1979) {tmdb-698} - [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Shark Bait (2022)" mv "/mnt/unraid/media/Movies/Shark Bait (2022)/Shark Bait (2022) {tmdb-960258} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Fifty Shades Darker (2017)" mv "/mnt/unraid/media/Movies/Fifty Shades Darker (2017)/Fifty Shades Darker (2017) {tmdb-341174} - {edition-Unrated} [Bluray-1080p][AC3 5.1][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Lady and the Tramp (1955)" mv "/mnt/unraid/media/Movies/Lady and the Tramp (1955)/Lady and the Tramp (1955) {tmdb-10340} - [Bluray-1080p][DTS 5.1][x264]-EbP.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: All About Eve (1950)" mv "/mnt/unraid/media/Movies/All About Eve (1950)/All About Eve (1950) {tmdb-705} - [Bluray-1080p][FLAC 1.0][x264]-PTer.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Open Season 2 (2008)" mv "/mnt/unraid/media/Movies/Open Season 2 (2008)/Open Season 2 (2008) {tmdb-13690} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Anastasia (1997)" mv "/mnt/unraid/media/Movies/Anastasia (1997)/Anastasia (1997) {tmdb-9444} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Last Samurai (2003)" mv "/mnt/unraid/media/Movies/The Last Samurai (2003)/The Last Samurai (2003) {tmdb-616} - [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Machete (2010)" mv "/mnt/unraid/media/Movies/Machete (2010)/Machete (2010) {tmdb-23631} - [Bluray-1080p][AC3 5.1][x264]-EbP.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Fences (2016)" mv "/mnt/unraid/media/Movies/Fences (2016)/Fences (2016) {tmdb-393457} - [Bluray-1080p][AC3 5.1][x264]-DON.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Transcendence (2014)" mv "/mnt/unraid/media/Movies/Transcendence (2014)/Transcendence (2014) {tmdb-157353} - [Bluray-1080p][EAC3 7.1][x264]-playHD.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: LEGO DC Comics Super Heroes Batman Be-Leaguered (2014)" mv "/mnt/unraid/media/Movies/LEGO DC Comics Super Heroes Batman Be-Leaguered (2014)/LEGO DC Comics Super Heroes Batman Be-Leaguered (2014) {tmdb-300424} - [PCOK][WEBDL-1080p][AAC 2.0][x264]-Hurtom.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Fisher King (1991)" mv "/mnt/unraid/media/Movies/The Fisher King (1991)/The Fisher King (1991) {tmdb-177} - [Bluray-1080p][EAC3 5.1][DV HDR10][x265]-PTer.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: Jersey Girl (2004)" mv "/mnt/unraid/media/Movies/Jersey Girl (2004)/Jersey Girl (2004) {tmdb-9541} - [Bluray-1080p][EAC3 5.1][x264]-coffee.mkv" "/mnt/unraid/media/Deleted Movies/"

run_cmd "Move Ali lower quality: The Bad Guys (2022)" mv "/mnt/unraid/media/Movies/The Bad Guys (2022)/The Bad Guys (2022) {tmdb-629542} - [Bluray-1080p][EAC3 Atmos 7.1][x264]-iFT.mkv" "/mnt/unraid/media/Deleted Movies/"


# === COPY BETTER QUALITY FILES ===

run_cmd "Copy Chris->Ali: Krazy House (2024)" rsync -avhP "/mnt/synology/rs-movies/Krazy House (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Cirque du Freak The Vampires Assistant (2009)" rsync -avhP "/mnt/synology/rs-movies/Cirque du Freak The Vampires Assistant (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Post Grad (2009)" rsync -avhP "/mnt/unraid/media/Movies/Post Grad (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Falling (2006)" rsync -avhP "/mnt/synology/rs-movies/Falling (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Murder Mystery 2 (2023)" rsync -avhP "/mnt/unraid/media/Movies/Murder Mystery 2 (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: 17 Again (2009)" rsync -avhP "/mnt/synology/rs-movies/17 Again (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Valet (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Valet (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hold the Dark (2018)" rsync -avhP "/mnt/synology/rs-movies/Hold the Dark (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Percy Jackson and the Olympians The Lightning Thief (2010)" rsync -avhP "/mnt/unraid/media/Movies/Percy Jackson and the Olympians The Lightning Thief (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Three Wise Men and a Baby (2022)" rsync -avhP "/mnt/unraid/media/Movies/Three Wise Men and a Baby (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Slotherhouse (2023)" rsync -avhP "/mnt/unraid/media/Movies/Slotherhouse (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Reel Rock 17 (2023)" rsync -avhP "/mnt/unraid/media/Movies/Reel Rock 17 (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Burn After Reading (2008)" rsync -avhP "/mnt/unraid/media/Movies/Burn After Reading (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Babylon (2022)" rsync -avhP "/mnt/unraid/media/Movies/Babylon (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Its the Great Pumpkin Charlie Brown (1966)" rsync -avhP "/mnt/synology/rs-movies/Its the Great Pumpkin Charlie Brown (1966)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: 20 Million Miles to Earth (1957)" rsync -avhP "/mnt/synology/rs-movies/20 Million Miles to Earth (1957)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Field (1990)" rsync -avhP "/mnt/unraid/media/Movies/The Field (1990)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Woody Woodpecker Goes to Camp (2024)" rsync -avhP "/mnt/synology/rs-movies/Woody Woodpecker Goes to Camp (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: I Tonya (2017)" rsync -avhP "/mnt/synology/rs-movies/I Tonya (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Bio-Dome (1996)" rsync -avhP "/mnt/synology/rs-movies/Bio-Dome (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Swarm (1978)" rsync -avhP "/mnt/synology/rs-movies/The Swarm (1978)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Mulholland Falls (1996)" rsync -avhP "/mnt/synology/rs-movies/Mulholland Falls (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Case for Christ (2017)" rsync -avhP "/mnt/synology/rs-movies/The Case for Christ (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Can You Ever Forgive Me (2018)" rsync -avhP "/mnt/synology/rs-movies/Can You Ever Forgive Me (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Stuber (2019)" rsync -avhP "/mnt/unraid/media/Movies/Stuber (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Double (2011)" rsync -avhP "/mnt/unraid/media/Movies/The Double (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Who Am I (1998)" rsync -avhP "/mnt/unraid/media/Movies/Who Am I (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: X2 (2003)" rsync -avhP "/mnt/unraid/media/Movies/X2 (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Army of the Dead (2021)" rsync -avhP "/mnt/unraid/media/Movies/Army of the Dead (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Girl Who Escaped The Kara Robinson Story (2023)" rsync -avhP "/mnt/synology/rs-movies/The Girl Who Escaped The Kara Robinson Story (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Miami Vice (2006)" rsync -avhP "/mnt/synology/rs-movies/Miami Vice (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Dreamcatcher (2003)" rsync -avhP "/mnt/unraid/media/Movies/Dreamcatcher (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Tournament (2009)" rsync -avhP "/mnt/synology/rs-movies/The Tournament (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Everything Everywhere All at Once (2022)" rsync -avhP "/mnt/unraid/media/Movies/Everything Everywhere All at Once (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Ammonite (2020)" rsync -avhP "/mnt/unraid/media/Movies/Ammonite (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: V for Vendetta (2006)" rsync -avhP "/mnt/synology/rs-movies/V for Vendetta (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Hatchet (2006)" rsync -avhP "/mnt/unraid/media/Movies/Hatchet (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: 200 Cigarettes (1999)" rsync -avhP "/mnt/synology/rs-movies/200 Cigarettes (1999)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Superman IV The Quest for Peace (1987)" rsync -avhP "/mnt/unraid/media/Movies/Superman IV The Quest for Peace (1987)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Prizefighter The Life of Jem Belcher (2022)" rsync -avhP "/mnt/synology/rs-movies/Prizefighter The Life of Jem Belcher (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Batman (1989)" rsync -avhP "/mnt/unraid/media/Movies/Batman (1989)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Single White Female (1992)" rsync -avhP "/mnt/synology/rs-movies/Single White Female (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Cat Ballou (1965)" rsync -avhP "/mnt/synology/rs-movies/Cat Ballou (1965)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Messenger (2009)" rsync -avhP "/mnt/unraid/media/Movies/The Messenger (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Marked for Death (1990)" rsync -avhP "/mnt/synology/rs-movies/Marked for Death (1990)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Last Stop in Yuma County (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Last Stop in Yuma County (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Guardian (2006)" rsync -avhP "/mnt/unraid/media/Movies/The Guardian (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: If I Had Legs Id Kick You (2025)" rsync -avhP "/mnt/unraid/media/Movies/If I Had Legs Id Kick You (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Kill Me Again (1989)" rsync -avhP "/mnt/synology/rs-movies/Kill Me Again (1989)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Megan Leavey (2017)" rsync -avhP "/mnt/unraid/media/Movies/Megan Leavey (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Tolkien (2019)" rsync -avhP "/mnt/synology/rs-movies/Tolkien (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Scream VI (2023)" rsync -avhP "/mnt/unraid/media/Movies/Scream VI (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Ridiculous 6 (2015)" rsync -avhP "/mnt/synology/rs-movies/The Ridiculous 6 (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Music and Lyrics (2007)" rsync -avhP "/mnt/synology/rs-movies/Music and Lyrics (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Menashe (2017)" rsync -avhP "/mnt/unraid/media/Movies/Menashe (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Tooth Fairy (2010)" rsync -avhP "/mnt/synology/rs-movies/Tooth Fairy (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Office Christmas Party (2016)" rsync -avhP "/mnt/unraid/media/Movies/Office Christmas Party (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dave Chappelle The Kennedy Center Mark Twain Prize (2020)" rsync -avhP "/mnt/unraid/media/Movies/Dave Chappelle The Kennedy Center Mark Twain Prize (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Skyfall (2012)" rsync -avhP "/mnt/unraid/media/Movies/Skyfall (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Wicked (2024)" rsync -avhP "/mnt/unraid/media/Movies/Wicked (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: About Cherry (2012)" rsync -avhP "/mnt/synology/rs-movies/About Cherry (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Confidence (2003)" rsync -avhP "/mnt/synology/rs-movies/Confidence (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Bounty Hunter (2010)" rsync -avhP "/mnt/unraid/media/Movies/The Bounty Hunter (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Life Aquatic with Steve Zissou (2004)" rsync -avhP "/mnt/unraid/media/Movies/The Life Aquatic with Steve Zissou (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Miracles from Heaven (2016)" rsync -avhP "/mnt/synology/rs-movies/Miracles from Heaven (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Longlegs (2024)" rsync -avhP "/mnt/unraid/media/Movies/Longlegs (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dont Worry Darling (2022)" rsync -avhP "/mnt/unraid/media/Movies/Dont Worry Darling (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Children of the Corn (1984)" rsync -avhP "/mnt/unraid/media/Movies/Children of the Corn (1984)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: All Quiet on the Western Front (1979)" rsync -avhP "/mnt/unraid/media/Movies/All Quiet on the Western Front (1979)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Cooties (2014)" rsync -avhP "/mnt/unraid/media/Movies/Cooties (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Rising Hawk (2019)" rsync -avhP "/mnt/synology/rs-movies/The Rising Hawk (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Hellraiser III Hell on Earth (1992)" rsync -avhP "/mnt/synology/rs-movies/Hellraiser III Hell on Earth (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Earth Girls Are Easy (1988)" rsync -avhP "/mnt/synology/rs-movies/Earth Girls Are Easy (1988)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Hoodwinked Too! Hood VS. Evil (2011)" rsync -avhP "/mnt/synology/rs-movies/Hoodwinked Too! Hood VS. Evil (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Percy Jackson Sea of Monsters (2013)" rsync -avhP "/mnt/unraid/media/Movies/Percy Jackson Sea of Monsters (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Do the Right Thing (1989)" rsync -avhP "/mnt/synology/rs-movies/Do the Right Thing (1989)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Enemy of the State (1998)" rsync -avhP "/mnt/synology/rs-movies/Enemy of the State (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Joy Ride (2023)" rsync -avhP "/mnt/unraid/media/Movies/Joy Ride (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Abigail (2024)" rsync -avhP "/mnt/unraid/media/Movies/Abigail (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Keeping Up with the Joneses (2016)" rsync -avhP "/mnt/synology/rs-movies/Keeping Up with the Joneses (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Banker (2020)" rsync -avhP "/mnt/unraid/media/Movies/The Banker (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Hangover (2009)" rsync -avhP "/mnt/unraid/media/Movies/The Hangover (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Anthony Jeselnik Caligula (2013)" rsync -avhP "/mnt/unraid/media/Movies/Anthony Jeselnik Caligula (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Matrix Reloaded (2003)" rsync -avhP "/mnt/unraid/media/Movies/The Matrix Reloaded (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Morbius (2022)" rsync -avhP "/mnt/unraid/media/Movies/Morbius (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: In the Mouth of Madness (1995)" rsync -avhP "/mnt/synology/rs-movies/In the Mouth of Madness (1995)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Running Scared (2006)" rsync -avhP "/mnt/synology/rs-movies/Running Scared (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Boxtrolls (2014)" rsync -avhP "/mnt/synology/rs-movies/The Boxtrolls (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: A Walk Among the Tombstones (2014)" rsync -avhP "/mnt/unraid/media/Movies/A Walk Among the Tombstones (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Shang-Chi and the Legend of the Ten Rings (2021)" rsync -avhP "/mnt/unraid/media/Movies/Shang-Chi and the Legend of the Ten Rings (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Nutty Professor II The Klumps (2000)" rsync -avhP "/mnt/unraid/media/Movies/Nutty Professor II The Klumps (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Collateral Damage (2002)" rsync -avhP "/mnt/synology/rs-movies/Collateral Damage (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Money from Home (1953)" rsync -avhP "/mnt/synology/rs-movies/Money from Home (1953)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Paddington (2014)" rsync -avhP "/mnt/synology/rs-movies/Paddington (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Resurrection (2022)" rsync -avhP "/mnt/unraid/media/Movies/Resurrection (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: All That Breathes (2022)" rsync -avhP "/mnt/unraid/media/Movies/All That Breathes (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Killing of a Sacred Deer (2017)" rsync -avhP "/mnt/unraid/media/Movies/The Killing of a Sacred Deer (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Pink Panther 2 (2009)" rsync -avhP "/mnt/unraid/media/Movies/The Pink Panther 2 (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Chaos Walking (2021)" rsync -avhP "/mnt/synology/rs-movies/Chaos Walking (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Puppet Master X Axis Rising (2012)" rsync -avhP "/mnt/synology/rs-movies/Puppet Master X Axis Rising (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Resident Evil The Final Chapter (2016)" rsync -avhP "/mnt/unraid/media/Movies/Resident Evil The Final Chapter (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: LEGO Marvel Avengers Code Red (2023)" rsync -avhP "/mnt/synology/rs-movies/LEGO Marvel Avengers Code Red (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Max Manus Man of War (2008)" rsync -avhP "/mnt/unraid/media/Movies/Max Manus Man of War (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Romancing the Stone (1984)" rsync -avhP "/mnt/synology/rs-movies/Romancing the Stone (1984)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Northpole Open for Christmas (2015)" rsync -avhP "/mnt/synology/rs-movies/Northpole Open for Christmas (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Our Holiday Story (2024)" rsync -avhP "/mnt/synology/rs-movies/Our Holiday Story (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Worthy (2016)" rsync -avhP "/mnt/unraid/media/Movies/The Worthy (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Batman The Long Halloween Part One (2021)" rsync -avhP "/mnt/synology/rs-movies/Batman The Long Halloween Part One (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Io Capitano (2023)" rsync -avhP "/mnt/unraid/media/Movies/Io Capitano (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: 9 (2009)" rsync -avhP "/mnt/synology/rs-movies/9 (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Quicksand (2023)" rsync -avhP "/mnt/unraid/media/Movies/Quicksand (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Billy Lynns Long Halftime Walk (2016)" rsync -avhP "/mnt/synology/rs-movies/Billy Lynns Long Halftime Walk (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: All Eyez on Me (2017)" rsync -avhP "/mnt/synology/rs-movies/All Eyez on Me (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Present (2020)" rsync -avhP "/mnt/unraid/media/Movies/The Present (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Wifelike (2022)" rsync -avhP "/mnt/unraid/media/Movies/Wifelike (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Be Cool (2005)" rsync -avhP "/mnt/synology/rs-movies/Be Cool (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Andre the Giant (2018)" rsync -avhP "/mnt/unraid/media/Movies/Andre the Giant (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dirty Work (1998)" rsync -avhP "/mnt/synology/rs-movies/Dirty Work (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Vengeance (2022)" rsync -avhP "/mnt/unraid/media/Movies/Vengeance (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dragonheart Battle for the Heartfire (2017)" rsync -avhP "/mnt/synology/rs-movies/Dragonheart Battle for the Heartfire (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Day of Reckoning (2025)" rsync -avhP "/mnt/synology/rs-movies/Day of Reckoning (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Ill Be Home for Christmas (1998)" rsync -avhP "/mnt/unraid/media/Movies/Ill Be Home for Christmas (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: With Honors (1994)" rsync -avhP "/mnt/synology/rs-movies/With Honors (1994)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Hudas Salon (2022)" rsync -avhP "/mnt/synology/rs-movies/Hudas Salon (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Elizabeth Harvest (2018)" rsync -avhP "/mnt/synology/rs-movies/Elizabeth Harvest (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Women Talking (2022)" rsync -avhP "/mnt/unraid/media/Movies/Women Talking (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: La Dolce Villa (2025)" rsync -avhP "/mnt/unraid/media/Movies/La Dolce Villa (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Good Morning Neighbor 8 (2022)" rsync -avhP "/mnt/synology/rs-movies/Good Morning Neighbor 8 (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Bones and All (2022)" rsync -avhP "/mnt/unraid/media/Movies/Bones and All (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: SLC Punk (1998)" rsync -avhP "/mnt/synology/rs-movies/SLC Punk (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Space Cadet (2024)" rsync -avhP "/mnt/unraid/media/Movies/Space Cadet (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Grand Prix of Europe (2025)" rsync -avhP "/mnt/synology/rs-movies/Grand Prix of Europe (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Transformers The Movie (1986)" rsync -avhP "/mnt/unraid/media/Movies/The Transformers The Movie (1986)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Yin Yang Master (2021)" rsync -avhP "/mnt/unraid/media/Movies/The Yin Yang Master (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Neon Demon (2016)" rsync -avhP "/mnt/synology/rs-movies/The Neon Demon (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Skiptrace (2016)" rsync -avhP "/mnt/synology/rs-movies/Skiptrace (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Trainwreck The Astroworld Tragedy (2025)" rsync -avhP "/mnt/unraid/media/Movies/Trainwreck The Astroworld Tragedy (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Fido (2006)" rsync -avhP "/mnt/synology/rs-movies/Fido (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Little Boy (2015)" rsync -avhP "/mnt/unraid/media/Movies/Little Boy (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Palo Alto (2014)" rsync -avhP "/mnt/synology/rs-movies/Palo Alto (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Seven Pounds (2008)" rsync -avhP "/mnt/unraid/media/Movies/Seven Pounds (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Like Someone in Love (2012)" rsync -avhP "/mnt/synology/rs-movies/Like Someone in Love (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Janes (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Janes (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Ten Commandments (1956)" rsync -avhP "/mnt/synology/rs-movies/The Ten Commandments (1956)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Walking with Dinosaurs (2013)" rsync -avhP "/mnt/synology/rs-movies/Walking with Dinosaurs (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Resident Evil Extinction (2007)" rsync -avhP "/mnt/unraid/media/Movies/Resident Evil Extinction (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Cannibal! The Musical (1996)" rsync -avhP "/mnt/synology/rs-movies/Cannibal! The Musical (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Pink Panther (2006)" rsync -avhP "/mnt/unraid/media/Movies/The Pink Panther (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Kiss of the Dragon (2001)" rsync -avhP "/mnt/unraid/media/Movies/Kiss of the Dragon (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: In a Violent Nature (2024)" rsync -avhP "/mnt/unraid/media/Movies/In a Violent Nature (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Suicide Squad (2016)" rsync -avhP "/mnt/unraid/media/Movies/Suicide Squad (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Black Christmas (1974)" rsync -avhP "/mnt/synology/rs-movies/Black Christmas (1974)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Covenant (2023)" rsync -avhP "/mnt/synology/rs-movies/The Covenant (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Ghost in the Shell (2017)" rsync -avhP "/mnt/unraid/media/Movies/Ghost in the Shell (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Jennifer Eight (1992)" rsync -avhP "/mnt/synology/rs-movies/Jennifer Eight (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Hero (2017)" rsync -avhP "/mnt/synology/rs-movies/Hero (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Section 8 (2022)" rsync -avhP "/mnt/unraid/media/Movies/Section 8 (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Help (2011)" rsync -avhP "/mnt/synology/rs-movies/The Help (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: My Little Pony Equestria Girls Legend of Everfree (2016)" rsync -avhP "/mnt/synology/rs-movies/My Little Pony Equestria Girls Legend of Everfree (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Wicker Man (2006)" rsync -avhP "/mnt/synology/rs-movies/The Wicker Man (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Apartment (1960)" rsync -avhP "/mnt/synology/rs-movies/The Apartment (1960)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Sapphires (2012)" rsync -avhP "/mnt/synology/rs-movies/The Sapphires (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Amazing Spider-Man 2 (2014)" rsync -avhP "/mnt/unraid/media/Movies/The Amazing Spider-Man 2 (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Last Dance (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Last Dance (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Rookie of the Year (1993)" rsync -avhP "/mnt/synology/rs-movies/Rookie of the Year (1993)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Duchess (2008)" rsync -avhP "/mnt/unraid/media/Movies/The Duchess (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Requin (2022)" rsync -avhP "/mnt/synology/rs-movies/Requin (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Peter Rabbit 2 The Runaway (2021)" rsync -avhP "/mnt/synology/rs-movies/Peter Rabbit 2 The Runaway (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Why Him (2016)" rsync -avhP "/mnt/unraid/media/Movies/Why Him (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: National Lampoons Vacation (1983)" rsync -avhP "/mnt/synology/rs-movies/National Lampoons Vacation (1983)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Arthur and the Invisibles (2006)" rsync -avhP "/mnt/synology/rs-movies/Arthur and the Invisibles (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Clue (1985)" rsync -avhP "/mnt/unraid/media/Movies/Clue (1985)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Mean Girls (2004)" rsync -avhP "/mnt/unraid/media/Movies/Mean Girls (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Hard Way (1991)" rsync -avhP "/mnt/synology/rs-movies/The Hard Way (1991)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Family Guy Presents Something Something Something Dark Side (2009)" rsync -avhP "/mnt/synology/rs-movies/Family Guy Presents Something Something Something Dark Side (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Void (2016)" rsync -avhP "/mnt/unraid/media/Movies/The Void (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: In the Electric Mist (2009)" rsync -avhP "/mnt/synology/rs-movies/In the Electric Mist (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Joe Rogan Strange Times (2018)" rsync -avhP "/mnt/synology/rs-movies/Joe Rogan Strange Times (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Play Dead (2022)" rsync -avhP "/mnt/synology/rs-movies/Play Dead (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Happy Gilmore (1996)" rsync -avhP "/mnt/unraid/media/Movies/Happy Gilmore (1996)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Wild America (1997)" rsync -avhP "/mnt/unraid/media/Movies/Wild America (1997)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Primal Fear (1996)" rsync -avhP "/mnt/unraid/media/Movies/Primal Fear (1996)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Looking Glass (2018)" rsync -avhP "/mnt/synology/rs-movies/Looking Glass (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Weapons (2025)" rsync -avhP "/mnt/unraid/media/Movies/Weapons (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Chris D'Elia No Pain (2020)" rsync -avhP "/mnt/synology/rs-movies/Chris D'Elia No Pain (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Mother (2009)" rsync -avhP "/mnt/unraid/media/Movies/Mother (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Evil Dead (2013)" rsync -avhP "/mnt/synology/rs-movies/Evil Dead (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: PAW Patrol The Movie (2021)" rsync -avhP "/mnt/unraid/media/Movies/PAW Patrol The Movie (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Superman Shazam! The Return of Black Adam (2010)" rsync -avhP "/mnt/synology/rs-movies/Superman Shazam! The Return of Black Adam (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Marauders (2016)" rsync -avhP "/mnt/synology/rs-movies/Marauders (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Fantastic Mr. Fox (2009)" rsync -avhP "/mnt/unraid/media/Movies/Fantastic Mr. Fox (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Enforcer (1976)" rsync -avhP "/mnt/synology/rs-movies/The Enforcer (1976)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: RED 2 (2013)" rsync -avhP "/mnt/unraid/media/Movies/RED 2 (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Village Album (2004)" rsync -avhP "/mnt/synology/rs-movies/The Village Album (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Rocketman (2019)" rsync -avhP "/mnt/unraid/media/Movies/Rocketman (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: On a Wing and a Prayer (2023)" rsync -avhP "/mnt/unraid/media/Movies/On a Wing and a Prayer (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Abigail (2019)" rsync -avhP "/mnt/synology/rs-movies/Abigail (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Last Stand (2013)" rsync -avhP "/mnt/unraid/media/Movies/The Last Stand (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Fire Inside (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Fire Inside (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Midnight Son (2011)" rsync -avhP "/mnt/synology/rs-movies/Midnight Son (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Den of Thieves 2 Pantera (2025)" rsync -avhP "/mnt/unraid/media/Movies/Den of Thieves 2 Pantera (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: A Paw Patrol Christmas (2025)" rsync -avhP "/mnt/unraid/media/Movies/A Paw Patrol Christmas (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Worth (2021)" rsync -avhP "/mnt/synology/rs-movies/Worth (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Reagan (2011)" rsync -avhP "/mnt/synology/rs-movies/Reagan (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Teen Titans The Judas Contract (2017)" rsync -avhP "/mnt/synology/rs-movies/Teen Titans The Judas Contract (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Reign of the Supermen (2019)" rsync -avhP "/mnt/synology/rs-movies/Reign of the Supermen (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Christmas Secret (2014)" rsync -avhP "/mnt/synology/rs-movies/The Christmas Secret (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Indiana Jones and the Last Crusade (1989)" rsync -avhP "/mnt/unraid/media/Movies/Indiana Jones and the Last Crusade (1989)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Promises (2021)" rsync -avhP "/mnt/synology/rs-movies/Promises (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Lights Out (2024)" rsync -avhP "/mnt/unraid/media/Movies/Lights Out (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Alcarras (2022)" rsync -avhP "/mnt/unraid/media/Movies/Alcarras (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Running Scared (1986)" rsync -avhP "/mnt/synology/rs-movies/Running Scared (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Call of the Wild (2020)" rsync -avhP "/mnt/unraid/media/Movies/The Call of the Wild (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Riff Raff (2025)" rsync -avhP "/mnt/unraid/media/Movies/Riff Raff (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Grown Ups 2 (2013)" rsync -avhP "/mnt/unraid/media/Movies/Grown Ups 2 (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Garfields Halloween Adventure (1985)" rsync -avhP "/mnt/synology/rs-movies/Garfields Halloween Adventure (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Alien Covenant (2017)" rsync -avhP "/mnt/synology/rs-movies/Alien Covenant (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Die Hard (1988)" rsync -avhP "/mnt/unraid/media/Movies/Die Hard (1988)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Sandy Wexler (2017)" rsync -avhP "/mnt/synology/rs-movies/Sandy Wexler (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Doors (1991)" rsync -avhP "/mnt/unraid/media/Movies/The Doors (1991)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Ordinary People (1980)" rsync -avhP "/mnt/synology/rs-movies/Ordinary People (1980)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Guy Ritchies The Covenant (2023)" rsync -avhP "/mnt/unraid/media/Movies/Guy Ritchies The Covenant (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Mama (2013)" rsync -avhP "/mnt/unraid/media/Movies/Mama (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Diary of a New World (2005)" rsync -avhP "/mnt/synology/rs-movies/Diary of a New World (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Avengers (2012)" rsync -avhP "/mnt/unraid/media/Movies/The Avengers (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Out-Laws (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Out-Laws (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Ambulance (2022)" rsync -avhP "/mnt/unraid/media/Movies/Ambulance (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Evil Does Not Exist (2023)" rsync -avhP "/mnt/unraid/media/Movies/Evil Does Not Exist (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Jeepers Creepers Reborn (2022)" rsync -avhP "/mnt/unraid/media/Movies/Jeepers Creepers Reborn (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Stop! Or My Mom Will Shoot (1992)" rsync -avhP "/mnt/synology/rs-movies/Stop! Or My Mom Will Shoot (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Star Wars Episode II Attack of the Clones (2002)" rsync -avhP "/mnt/unraid/media/Movies/Star Wars Episode II Attack of the Clones (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Influencer (2023)" rsync -avhP "/mnt/unraid/media/Movies/Influencer (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Air Bud (1997)" rsync -avhP "/mnt/synology/rs-movies/Air Bud (1997)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Resident Evil Welcome to Raccoon City (2021)" rsync -avhP "/mnt/unraid/media/Movies/Resident Evil Welcome to Raccoon City (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Ice Age Dawn of the Dinosaurs (2009)" rsync -avhP "/mnt/synology/rs-movies/Ice Age Dawn of the Dinosaurs (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Invincible Iron Man (2007)" rsync -avhP "/mnt/synology/rs-movies/The Invincible Iron Man (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Repo Men (2010)" rsync -avhP "/mnt/unraid/media/Movies/Repo Men (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Silent Night (2012)" rsync -avhP "/mnt/synology/rs-movies/Silent Night (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Stans (2025)" rsync -avhP "/mnt/unraid/media/Movies/Stans (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Hard Rain (1998)" rsync -avhP "/mnt/unraid/media/Movies/Hard Rain (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The River Wild (1994)" rsync -avhP "/mnt/synology/rs-movies/The River Wild (1994)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Harriet (2019)" rsync -avhP "/mnt/unraid/media/Movies/Harriet (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: DOA Dead or Alive (2006)" rsync -avhP "/mnt/synology/rs-movies/DOA Dead or Alive (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Jay and Silent Bob Reboot (2019)" rsync -avhP "/mnt/synology/rs-movies/Jay and Silent Bob Reboot (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Gladiator (2000)" rsync -avhP "/mnt/unraid/media/Movies/Gladiator (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Beerfest (2006)" rsync -avhP "/mnt/unraid/media/Movies/Beerfest (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Disturbia (2007)" rsync -avhP "/mnt/synology/rs-movies/Disturbia (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Menendez Brothers (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Menendez Brothers (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Weekend in Taipei (2024)" rsync -avhP "/mnt/unraid/media/Movies/Weekend in Taipei (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Against the Sun (2014)" rsync -avhP "/mnt/synology/rs-movies/Against the Sun (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Nothing to Lose (1997)" rsync -avhP "/mnt/synology/rs-movies/Nothing to Lose (1997)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Mystic Christmas (2023)" rsync -avhP "/mnt/synology/rs-movies/Mystic Christmas (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Siege (1998)" rsync -avhP "/mnt/unraid/media/Movies/The Siege (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Automat (2021)" rsync -avhP "/mnt/unraid/media/Movies/The Automat (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: V H S 85 (2023)" rsync -avhP "/mnt/synology/rs-movies/V H S 85 (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Hunger (1983)" rsync -avhP "/mnt/synology/rs-movies/The Hunger (1983)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Troll Hunter (2010)" rsync -avhP "/mnt/synology/rs-movies/Troll Hunter (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Santa Claus The Movie (1985)" rsync -avhP "/mnt/synology/rs-movies/Santa Claus The Movie (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Bill Burr Why Do I Do This (2008)" rsync -avhP "/mnt/unraid/media/Movies/Bill Burr Why Do I Do This (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Prince of Persia The Sands of Time (2010)" rsync -avhP "/mnt/unraid/media/Movies/Prince of Persia The Sands of Time (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Mr. Monks Last Case A Monk Movie (2023)" rsync -avhP "/mnt/unraid/media/Movies/Mr. Monks Last Case A Monk Movie (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Adventures of Ford Fairlane (1990)" rsync -avhP "/mnt/synology/rs-movies/The Adventures of Ford Fairlane (1990)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The 33 (2015)" rsync -avhP "/mnt/unraid/media/Movies/The 33 (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Vanquish (2021)" rsync -avhP "/mnt/synology/rs-movies/Vanquish (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Saints and Soldiers (2003)" rsync -avhP "/mnt/synology/rs-movies/Saints and Soldiers (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Peanuts Movie (2015)" rsync -avhP "/mnt/synology/rs-movies/The Peanuts Movie (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Free Fire (2017)" rsync -avhP "/mnt/synology/rs-movies/Free Fire (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: An Elfs Story (2011)" rsync -avhP "/mnt/synology/rs-movies/An Elfs Story (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: I Am Legend (2007)" rsync -avhP "/mnt/unraid/media/Movies/I Am Legend (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Acts of Vengeance (2017)" rsync -avhP "/mnt/synology/rs-movies/Acts of Vengeance (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Just Go with It (2011)" rsync -avhP "/mnt/unraid/media/Movies/Just Go with It (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Sorry Baby (2025)" rsync -avhP "/mnt/unraid/media/Movies/Sorry Baby (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Shaggy Dog (1959)" rsync -avhP "/mnt/synology/rs-movies/The Shaggy Dog (1959)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Mickey Donald Goofy The Three Musketeers (2004)" rsync -avhP "/mnt/synology/rs-movies/Mickey Donald Goofy The Three Musketeers (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Rons Gone Wrong (2021)" rsync -avhP "/mnt/synology/rs-movies/Rons Gone Wrong (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Colombiana (2011)" rsync -avhP "/mnt/synology/rs-movies/Colombiana (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Last Starfighter (1984)" rsync -avhP "/mnt/unraid/media/Movies/The Last Starfighter (1984)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Poseidon Adventure (1972)" rsync -avhP "/mnt/synology/rs-movies/The Poseidon Adventure (1972)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Replicas (2018)" rsync -avhP "/mnt/synology/rs-movies/Replicas (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Jim Jefferies Alcoholocaust (2010)" rsync -avhP "/mnt/synology/rs-movies/Jim Jefferies Alcoholocaust (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Dazed and Confused (1993)" rsync -avhP "/mnt/synology/rs-movies/Dazed and Confused (1993)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Kindachi Kosuke The Queen Bee (2006)" rsync -avhP "/mnt/synology/rs-movies/Kindachi Kosuke The Queen Bee (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Abbott and Costello Meet the Keystone Kops (1955)" rsync -avhP "/mnt/synology/rs-movies/Abbott and Costello Meet the Keystone Kops (1955)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Femme Fatale (2002)" rsync -avhP "/mnt/unraid/media/Movies/Femme Fatale (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Talladega Nights The Ballad of Ricky Bobby (2006)" rsync -avhP "/mnt/unraid/media/Movies/Talladega Nights The Ballad of Ricky Bobby (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Great Outdoors (1988)" rsync -avhP "/mnt/synology/rs-movies/The Great Outdoors (1988)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Parenting (2025)" rsync -avhP "/mnt/unraid/media/Movies/The Parenting (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Homeward Bound The Incredible Journey (1993)" rsync -avhP "/mnt/unraid/media/Movies/Homeward Bound The Incredible Journey (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Domino (2005)" rsync -avhP "/mnt/unraid/media/Movies/Domino (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Paranormal Activity 3 (2011)" rsync -avhP "/mnt/synology/rs-movies/Paranormal Activity 3 (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Evil Dead Rise (2023)" rsync -avhP "/mnt/unraid/media/Movies/Evil Dead Rise (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Insatiable (2006)" rsync -avhP "/mnt/synology/rs-movies/The Insatiable (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Jimmy Carr His Dark Material (2021)" rsync -avhP "/mnt/synology/rs-movies/Jimmy Carr His Dark Material (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Ricky Gervais SuperNature (2022)" rsync -avhP "/mnt/unraid/media/Movies/Ricky Gervais SuperNature (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Grandmother (2022)" rsync -avhP "/mnt/synology/rs-movies/The Grandmother (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Resident Evil Apocalypse (2004)" rsync -avhP "/mnt/unraid/media/Movies/Resident Evil Apocalypse (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Coming 2 America (2021)" rsync -avhP "/mnt/unraid/media/Movies/Coming 2 America (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Martha Marcy May Marlene (2011)" rsync -avhP "/mnt/synology/rs-movies/Martha Marcy May Marlene (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Rio Bravo (1959)" rsync -avhP "/mnt/unraid/media/Movies/Rio Bravo (1959)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Encanto (2021)" rsync -avhP "/mnt/unraid/media/Movies/Encanto (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The ChubbChubbs! (2002)" rsync -avhP "/mnt/synology/rs-movies/The ChubbChubbs! (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: A Bramble House Christmas (2017)" rsync -avhP "/mnt/synology/rs-movies/A Bramble House Christmas (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Rurouni Kenshin Part I Origins (2012)" rsync -avhP "/mnt/unraid/media/Movies/Rurouni Kenshin Part I Origins (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: You Are Not My Mother (2022)" rsync -avhP "/mnt/unraid/media/Movies/You Are Not My Mother (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Together (2025)" rsync -avhP "/mnt/unraid/media/Movies/Together (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Freedomland (2006)" rsync -avhP "/mnt/synology/rs-movies/Freedomland (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Hill (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Hill (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: I Love You Beth Cooper (2009)" rsync -avhP "/mnt/synology/rs-movies/I Love You Beth Cooper (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Manchurian Candidate (1962)" rsync -avhP "/mnt/synology/rs-movies/The Manchurian Candidate (1962)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: JUNG_E (2023)" rsync -avhP "/mnt/unraid/media/Movies/JUNG_E (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Blade Runner Black Out 2022 (2017)" rsync -avhP "/mnt/synology/rs-movies/Blade Runner Black Out 2022 (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Tale of Tales (2015)" rsync -avhP "/mnt/synology/rs-movies/Tale of Tales (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Screamboat (2025)" rsync -avhP "/mnt/synology/rs-movies/Screamboat (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Total Recall (1990)" rsync -avhP "/mnt/unraid/media/Movies/Total Recall (1990)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Mother (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Mother (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Kids (1995)" rsync -avhP "/mnt/synology/rs-movies/Kids (1995)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Love Live! Superstar!! Liella! 2nd LoveLive! ～What a Wonderful Dream!!～ (2022)" rsync -avhP "/mnt/synology/rs-movies/Love Live! Superstar!! Liella! 2nd LoveLive! ～What a Wonderful Dream!!～ (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Perfect Storm (2000)" rsync -avhP "/mnt/synology/rs-movies/The Perfect Storm (2000)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Migration (2023)" rsync -avhP "/mnt/unraid/media/Movies/Migration (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: C.H.U.D. (1984)" rsync -avhP "/mnt/synology/rs-movies/C.H.U.D. (1984)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Tag (2018)" rsync -avhP "/mnt/synology/rs-movies/Tag (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Cold in July (2014)" rsync -avhP "/mnt/unraid/media/Movies/Cold in July (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Boiler Room (2000)" rsync -avhP "/mnt/unraid/media/Movies/Boiler Room (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Lord of the Rings The Two Towers (2002)" rsync -avhP "/mnt/unraid/media/Movies/The Lord of the Rings The Two Towers (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Breach (2007)" rsync -avhP "/mnt/synology/rs-movies/Breach (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Jan Dara The Beginning (2012)" rsync -avhP "/mnt/synology/rs-movies/Jan Dara The Beginning (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Poor Things (2023)" rsync -avhP "/mnt/unraid/media/Movies/Poor Things (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: How to Lose a Guy in 10 Days (2003)" rsync -avhP "/mnt/unraid/media/Movies/How to Lose a Guy in 10 Days (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Turner and Hooch (1989)" rsync -avhP "/mnt/unraid/media/Movies/Turner and Hooch (1989)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Old (2021)" rsync -avhP "/mnt/unraid/media/Movies/Old (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Revenant (2009)" rsync -avhP "/mnt/synology/rs-movies/The Revenant (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Moulin Rouge! (2001)" rsync -avhP "/mnt/unraid/media/Movies/Moulin Rouge! (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: You Should Have Left (2020)" rsync -avhP "/mnt/synology/rs-movies/You Should Have Left (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Kimi (2022)" rsync -avhP "/mnt/unraid/media/Movies/Kimi (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Karate Kid (2010)" rsync -avhP "/mnt/unraid/media/Movies/The Karate Kid (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Jackal (1997)" rsync -avhP "/mnt/unraid/media/Movies/The Jackal (1997)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Worlds Greatest Dad (2009)" rsync -avhP "/mnt/unraid/media/Movies/Worlds Greatest Dad (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Super Mario Bros. Movie (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Super Mario Bros. Movie (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Island (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Island (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: About My Father (2023)" rsync -avhP "/mnt/synology/rs-movies/About My Father (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Star Wars The Force Awakens (2015)" rsync -avhP "/mnt/unraid/media/Movies/Star Wars The Force Awakens (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Donbass (2018)" rsync -avhP "/mnt/unraid/media/Movies/Donbass (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Prosecutor (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Prosecutor (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: She Said (2022)" rsync -avhP "/mnt/synology/rs-movies/She Said (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Girl with a Pearl Earring (2003)" rsync -avhP "/mnt/synology/rs-movies/Girl with a Pearl Earring (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Chitty Chitty Bang Bang (1968)" rsync -avhP "/mnt/synology/rs-movies/Chitty Chitty Bang Bang (1968)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Cargo (2017)" rsync -avhP "/mnt/synology/rs-movies/Cargo (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Bud Abbott and Lou Costello in the Foreign Legion (1950)" rsync -avhP "/mnt/synology/rs-movies/Bud Abbott and Lou Costello in the Foreign Legion (1950)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Love and Monsters (2020)" rsync -avhP "/mnt/unraid/media/Movies/Love and Monsters (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Mask (1985)" rsync -avhP "/mnt/synology/rs-movies/Mask (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Eternity (2025)" rsync -avhP "/mnt/unraid/media/Movies/Eternity (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Venom Let There Be Carnage (2021)" rsync -avhP "/mnt/unraid/media/Movies/Venom Let There Be Carnage (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: What Women Want (2000)" rsync -avhP "/mnt/unraid/media/Movies/What Women Want (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Jupiter Ascending (2015)" rsync -avhP "/mnt/unraid/media/Movies/Jupiter Ascending (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Madeas Big Happy Family (2011)" rsync -avhP "/mnt/unraid/media/Movies/Madeas Big Happy Family (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Running Man (1987)" rsync -avhP "/mnt/synology/rs-movies/The Running Man (1987)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Christmas Evil (1980)" rsync -avhP "/mnt/synology/rs-movies/Christmas Evil (1980)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Rampart (2011)" rsync -avhP "/mnt/unraid/media/Movies/Rampart (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: In Like Flint (1967)" rsync -avhP "/mnt/synology/rs-movies/In Like Flint (1967)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Down Periscope (1996)" rsync -avhP "/mnt/synology/rs-movies/Down Periscope (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Breakfast on Pluto (2005)" rsync -avhP "/mnt/unraid/media/Movies/Breakfast on Pluto (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Doctor Dolittle (1998)" rsync -avhP "/mnt/unraid/media/Movies/Doctor Dolittle (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Harold and Maude (1971)" rsync -avhP "/mnt/synology/rs-movies/Harold and Maude (1971)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Ginger and Rosa (2012)" rsync -avhP "/mnt/unraid/media/Movies/Ginger and Rosa (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: ¡Three Amigos! (1986)" rsync -avhP "/mnt/synology/rs-movies/¡Three Amigos! (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The 5-Year Christmas Party (2024)" rsync -avhP "/mnt/synology/rs-movies/The 5-Year Christmas Party (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Dave Chappelle Sticks and Stones (2019)" rsync -avhP "/mnt/synology/rs-movies/Dave Chappelle Sticks and Stones (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Jason and the Argonauts (1963)" rsync -avhP "/mnt/synology/rs-movies/Jason and the Argonauts (1963)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Oppenheimer (2023)" rsync -avhP "/mnt/unraid/media/Movies/Oppenheimer (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Last Castle (2001)" rsync -avhP "/mnt/synology/rs-movies/The Last Castle (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Most Dangerous Game (2020)" rsync -avhP "/mnt/synology/rs-movies/Most Dangerous Game (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Mission Impossible Rogue Nation (2015)" rsync -avhP "/mnt/unraid/media/Movies/Mission Impossible Rogue Nation (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Surviving Christmas (2004)" rsync -avhP "/mnt/synology/rs-movies/Surviving Christmas (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Fear Cabin The Last Weekend of Summer (2024)" rsync -avhP "/mnt/synology/rs-movies/Fear Cabin The Last Weekend of Summer (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Boys from County Hell (2021)" rsync -avhP "/mnt/synology/rs-movies/Boys from County Hell (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Cloudy with a Chance of Meatballs 2 (2013)" rsync -avhP "/mnt/unraid/media/Movies/Cloudy with a Chance of Meatballs 2 (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: City of Life and Death (2009)" rsync -avhP "/mnt/synology/rs-movies/City of Life and Death (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Glory (1989)" rsync -avhP "/mnt/unraid/media/Movies/Glory (1989)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Gaia (2021)" rsync -avhP "/mnt/synology/rs-movies/Gaia (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: His Girl Friday (1940)" rsync -avhP "/mnt/synology/rs-movies/His Girl Friday (1940)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Wall Street Money Never Sleeps (2010)" rsync -avhP "/mnt/synology/rs-movies/Wall Street Money Never Sleeps (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: This Is 40 (2012)" rsync -avhP "/mnt/synology/rs-movies/This Is 40 (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Hell Is for Heroes (1962)" rsync -avhP "/mnt/synology/rs-movies/Hell Is for Heroes (1962)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Hand of God (2021)" rsync -avhP "/mnt/unraid/media/Movies/The Hand of God (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Eurovision Song Contest The Story of Fire Saga (2020)" rsync -avhP "/mnt/synology/rs-movies/Eurovision Song Contest The Story of Fire Saga (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Apollo 13 (1995)" rsync -avhP "/mnt/unraid/media/Movies/Apollo 13 (1995)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: The Tale of Despereaux (2008)" rsync -avhP "/mnt/synology/rs-movies/The Tale of Despereaux (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Zookeeper (2011)" rsync -avhP "/mnt/synology/rs-movies/Zookeeper (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Chateau Christmas (2020)" rsync -avhP "/mnt/synology/rs-movies/Chateau Christmas (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Retribution (2023)" rsync -avhP "/mnt/unraid/media/Movies/Retribution (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Mob Land (2023)" rsync -avhP "/mnt/unraid/media/Movies/Mob Land (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: John Wick Chapter 2 (2017)" rsync -avhP "/mnt/unraid/media/Movies/John Wick Chapter 2 (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Saint (2017)" rsync -avhP "/mnt/synology/rs-movies/The Saint (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: My Best Friend (2018)" rsync -avhP "/mnt/unraid/media/Movies/My Best Friend (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Lair (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Lair (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Young Frankenstein (1974)" rsync -avhP "/mnt/unraid/media/Movies/Young Frankenstein (1974)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Thicket (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Thicket (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: His Only Son (2023)" rsync -avhP "/mnt/synology/rs-movies/His Only Son (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Sorority Babes in the Slimeball Bowl-O-Rama (1988)" rsync -avhP "/mnt/unraid/media/Movies/Sorority Babes in the Slimeball Bowl-O-Rama (1988)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: 3 Ninjas (1992)" rsync -avhP "/mnt/unraid/media/Movies/3 Ninjas (1992)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Fred Claus (2007)" rsync -avhP "/mnt/unraid/media/Movies/Fred Claus (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Laggies (2014)" rsync -avhP "/mnt/unraid/media/Movies/Laggies (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Run All Night (2015)" rsync -avhP "/mnt/unraid/media/Movies/Run All Night (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Guest (2014)" rsync -avhP "/mnt/synology/rs-movies/The Guest (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: National Treasure Book of Secrets (2007)" rsync -avhP "/mnt/synology/rs-movies/National Treasure Book of Secrets (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Born in East L.A. (1987)" rsync -avhP "/mnt/unraid/media/Movies/Born in East L.A. (1987)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Child 44 (2015)" rsync -avhP "/mnt/synology/rs-movies/Child 44 (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Lightyear (2022)" rsync -avhP "/mnt/unraid/media/Movies/Lightyear (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Avatar (2009)" rsync -avhP "/mnt/synology/rs-movies/Avatar (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Locke (2014)" rsync -avhP "/mnt/synology/rs-movies/Locke (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: A Madea Family Funeral (2019)" rsync -avhP "/mnt/synology/rs-movies/A Madea Family Funeral (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Superman Batman Apocalypse (2010)" rsync -avhP "/mnt/unraid/media/Movies/Superman Batman Apocalypse (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: In Her Shoes (2005)" rsync -avhP "/mnt/synology/rs-movies/In Her Shoes (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Terror on the Prairie (2022)" rsync -avhP "/mnt/unraid/media/Movies/Terror on the Prairie (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Peaceful Warrior (2006)" rsync -avhP "/mnt/unraid/media/Movies/Peaceful Warrior (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Wonder Woman Bloodlines (2019)" rsync -avhP "/mnt/synology/rs-movies/Wonder Woman Bloodlines (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Gladiator II (2024)" rsync -avhP "/mnt/unraid/media/Movies/Gladiator II (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Gremlins (1984)" rsync -avhP "/mnt/synology/rs-movies/Gremlins (1984)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Sniper (1993)" rsync -avhP "/mnt/synology/rs-movies/Sniper (1993)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Sleepaway Camp (1983)" rsync -avhP "/mnt/synology/rs-movies/Sleepaway Camp (1983)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Holiday Affair (1949)" rsync -avhP "/mnt/unraid/media/Movies/Holiday Affair (1949)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Pearl (2022)" rsync -avhP "/mnt/unraid/media/Movies/Pearl (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: A Heavenly Christmas (2016)" rsync -avhP "/mnt/synology/rs-movies/A Heavenly Christmas (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Alpha Dog (2006)" rsync -avhP "/mnt/synology/rs-movies/Alpha Dog (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Moonshot (2022)" rsync -avhP "/mnt/synology/rs-movies/Moonshot (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Aquaman (2018)" rsync -avhP "/mnt/unraid/media/Movies/Aquaman (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Pacifiction (2022)" rsync -avhP "/mnt/synology/rs-movies/Pacifiction (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Commuter (2018)" rsync -avhP "/mnt/unraid/media/Movies/The Commuter (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Welcome to the Punch (2013)" rsync -avhP "/mnt/synology/rs-movies/Welcome to the Punch (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Things to Do in Denver When Youre Dead (1995)" rsync -avhP "/mnt/synology/rs-movies/Things to Do in Denver When Youre Dead (1995)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: True Memoirs of an International Assassin (2016)" rsync -avhP "/mnt/synology/rs-movies/True Memoirs of an International Assassin (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Infested (2023)" rsync -avhP "/mnt/unraid/media/Movies/Infested (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Good Dinosaur (2015)" rsync -avhP "/mnt/unraid/media/Movies/The Good Dinosaur (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: My Life (1993)" rsync -avhP "/mnt/unraid/media/Movies/My Life (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Indiscreet (1958)" rsync -avhP "/mnt/synology/rs-movies/Indiscreet (1958)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Spy Next Door (2010)" rsync -avhP "/mnt/synology/rs-movies/The Spy Next Door (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Three Thousand Years of Longing (2022)" rsync -avhP "/mnt/unraid/media/Movies/Three Thousand Years of Longing (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Wing Commander (1999)" rsync -avhP "/mnt/synology/rs-movies/Wing Commander (1999)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Snow Day (2000)" rsync -avhP "/mnt/unraid/media/Movies/Snow Day (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Mannequin (2025)" rsync -avhP "/mnt/synology/rs-movies/Mannequin (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Twins (1988)" rsync -avhP "/mnt/unraid/media/Movies/Twins (1988)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Batman v Superman Dawn of Justice (2016)" rsync -avhP "/mnt/unraid/media/Movies/Batman v Superman Dawn of Justice (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Black Hole (1979)" rsync -avhP "/mnt/synology/rs-movies/The Black Hole (1979)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Quiet Girl (2022)" rsync -avhP "/mnt/synology/rs-movies/The Quiet Girl (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Godzilla Minus One (2023)" rsync -avhP "/mnt/synology/rs-movies/Godzilla Minus One (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Avicii Im Tim (2024)" rsync -avhP "/mnt/unraid/media/Movies/Avicii Im Tim (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dragonslayer (1981)" rsync -avhP "/mnt/synology/rs-movies/Dragonslayer (1981)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Final Destination Bloodlines (2025)" rsync -avhP "/mnt/unraid/media/Movies/Final Destination Bloodlines (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Buffy the Vampire Slayer (1992)" rsync -avhP "/mnt/synology/rs-movies/Buffy the Vampire Slayer (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: My Blue Heaven (1990)" rsync -avhP "/mnt/unraid/media/Movies/My Blue Heaven (1990)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Driving Miss Daisy (1989)" rsync -avhP "/mnt/synology/rs-movies/Driving Miss Daisy (1989)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: A Cinderella Story (2004)" rsync -avhP "/mnt/unraid/media/Movies/A Cinderella Story (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: American Wedding (2003)" rsync -avhP "/mnt/synology/rs-movies/American Wedding (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Mechanic (2011)" rsync -avhP "/mnt/unraid/media/Movies/The Mechanic (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Showgirls (1995)" rsync -avhP "/mnt/unraid/media/Movies/Showgirls (1995)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Adventures of Sharkboy and Lavagirl (2005)" rsync -avhP "/mnt/synology/rs-movies/The Adventures of Sharkboy and Lavagirl (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: I.S.S. (2024)" rsync -avhP "/mnt/unraid/media/Movies/I.S.S. (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Itinerary of a Spoiled Child (1988)" rsync -avhP "/mnt/synology/rs-movies/Itinerary of a Spoiled Child (1988)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Hippopotamus (2017)" rsync -avhP "/mnt/unraid/media/Movies/The Hippopotamus (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Batman Mystery of the Batwoman (2003)" rsync -avhP "/mnt/unraid/media/Movies/Batman Mystery of the Batwoman (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Brothers (2024)" rsync -avhP "/mnt/unraid/media/Movies/Brothers (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Golden Child (1986)" rsync -avhP "/mnt/synology/rs-movies/The Golden Child (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Herbie Fully Loaded (2005)" rsync -avhP "/mnt/unraid/media/Movies/Herbie Fully Loaded (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Beekeeper (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Beekeeper (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Support Your Local Sheriff! (1969)" rsync -avhP "/mnt/synology/rs-movies/Support Your Local Sheriff! (1969)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Step Up 2 The Streets (2008)" rsync -avhP "/mnt/synology/rs-movies/Step Up 2 The Streets (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Inkheart (2008)" rsync -avhP "/mnt/unraid/media/Movies/Inkheart (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Fair Play (2023)" rsync -avhP "/mnt/synology/rs-movies/Fair Play (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Fear Below (2025)" rsync -avhP "/mnt/unraid/media/Movies/Fear Below (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Bill Burr Let It Go (2010)" rsync -avhP "/mnt/unraid/media/Movies/Bill Burr Let It Go (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Roadhouse 66 (1984)" rsync -avhP "/mnt/synology/rs-movies/Roadhouse 66 (1984)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Panda Plan (2024)" rsync -avhP "/mnt/unraid/media/Movies/Panda Plan (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Final Destination 5 (2011)" rsync -avhP "/mnt/synology/rs-movies/Final Destination 5 (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Bad Batch (2017)" rsync -avhP "/mnt/synology/rs-movies/The Bad Batch (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Pontypool (2009)" rsync -avhP "/mnt/unraid/media/Movies/Pontypool (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hubie Halloween (2020)" rsync -avhP "/mnt/synology/rs-movies/Hubie Halloween (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Old Dads (2023)" rsync -avhP "/mnt/unraid/media/Movies/Old Dads (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: They Shall Not Grow Old (2018)" rsync -avhP "/mnt/unraid/media/Movies/They Shall Not Grow Old (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Christmas Shepherd (2014)" rsync -avhP "/mnt/synology/rs-movies/The Christmas Shepherd (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: National Lampoons European Vacation (1985)" rsync -avhP "/mnt/unraid/media/Movies/National Lampoons European Vacation (1985)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Haywire (2011)" rsync -avhP "/mnt/synology/rs-movies/Haywire (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Let Me In (2010)" rsync -avhP "/mnt/synology/rs-movies/Let Me In (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Sleepy Hollow (1999)" rsync -avhP "/mnt/unraid/media/Movies/Sleepy Hollow (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Aladdin (1992)" rsync -avhP "/mnt/unraid/media/Movies/Aladdin (1992)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Zone of Interest (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Zone of Interest (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Pitch Perfect (2012)" rsync -avhP "/mnt/unraid/media/Movies/Pitch Perfect (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Annabelle Comes Home (2019)" rsync -avhP "/mnt/unraid/media/Movies/Annabelle Comes Home (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Emperor (2020)" rsync -avhP "/mnt/synology/rs-movies/Emperor (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Boudica (2023)" rsync -avhP "/mnt/synology/rs-movies/Boudica (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Miss Congeniality (2000)" rsync -avhP "/mnt/synology/rs-movies/Miss Congeniality (2000)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: L.A. Confidential (1997)" rsync -avhP "/mnt/unraid/media/Movies/L.A. Confidential (1997)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Derailed (2005)" rsync -avhP "/mnt/unraid/media/Movies/Derailed (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Karate Kid Part III (1989)" rsync -avhP "/mnt/synology/rs-movies/The Karate Kid Part III (1989)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Missing (2003)" rsync -avhP "/mnt/synology/rs-movies/The Missing (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: John Q (2002)" rsync -avhP "/mnt/synology/rs-movies/John Q (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Argylle (2024)" rsync -avhP "/mnt/unraid/media/Movies/Argylle (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Jimmys Hall (2014)" rsync -avhP "/mnt/synology/rs-movies/Jimmys Hall (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Name of the Rose (1986)" rsync -avhP "/mnt/synology/rs-movies/The Name of the Rose (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Shark Tale (2004)" rsync -avhP "/mnt/unraid/media/Movies/Shark Tale (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Mercury Rising (1998)" rsync -avhP "/mnt/unraid/media/Movies/Mercury Rising (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Cuckoo (2024)" rsync -avhP "/mnt/unraid/media/Movies/Cuckoo (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Final Fantasy The Spirits Within (2001)" rsync -avhP "/mnt/synology/rs-movies/Final Fantasy The Spirits Within (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Snowden (2016)" rsync -avhP "/mnt/synology/rs-movies/Snowden (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Exists (2014)" rsync -avhP "/mnt/synology/rs-movies/Exists (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Downfall (2004)" rsync -avhP "/mnt/synology/rs-movies/Downfall (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Justice League Dark (2017)" rsync -avhP "/mnt/unraid/media/Movies/Justice League Dark (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Sunset Boulevard (1950)" rsync -avhP "/mnt/unraid/media/Movies/Sunset Boulevard (1950)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Rispondimi One last goodbye (2025)" rsync -avhP "/mnt/synology/rs-movies/Rispondimi One last goodbye (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Abominable (2019)" rsync -avhP "/mnt/unraid/media/Movies/Abominable (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Unfaithful (2002)" rsync -avhP "/mnt/synology/rs-movies/Unfaithful (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Davy Crockett and the River Pirates (1956)" rsync -avhP "/mnt/synology/rs-movies/Davy Crockett and the River Pirates (1956)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Little Big League (1994)" rsync -avhP "/mnt/unraid/media/Movies/Little Big League (1994)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Amazing Grace (2006)" rsync -avhP "/mnt/synology/rs-movies/Amazing Grace (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Antebellum (2020)" rsync -avhP "/mnt/synology/rs-movies/Antebellum (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: My Stepmother Is an Alien (1988)" rsync -avhP "/mnt/synology/rs-movies/My Stepmother Is an Alien (1988)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Mean Girls (2024)" rsync -avhP "/mnt/unraid/media/Movies/Mean Girls (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Blood Father (2016)" rsync -avhP "/mnt/unraid/media/Movies/Blood Father (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Moon (2009)" rsync -avhP "/mnt/unraid/media/Movies/Moon (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Wonder Woman 1984 (2020)" rsync -avhP "/mnt/unraid/media/Movies/Wonder Woman 1984 (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Count of Monte Cristo (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Count of Monte Cristo (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Farm (2019)" rsync -avhP "/mnt/synology/rs-movies/The Farm (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Alexander and the Terrible Horrible No Good Very Bad Road Trip (2025)" rsync -avhP "/mnt/unraid/media/Movies/Alexander and the Terrible Horrible No Good Very Bad Road Trip (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Bird (2024)" rsync -avhP "/mnt/unraid/media/Movies/Bird (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Ernest Scared Stupid (1991)" rsync -avhP "/mnt/synology/rs-movies/Ernest Scared Stupid (1991)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Collector (2009)" rsync -avhP "/mnt/synology/rs-movies/The Collector (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Rare Breed (1966)" rsync -avhP "/mnt/synology/rs-movies/The Rare Breed (1966)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Airport (1970)" rsync -avhP "/mnt/synology/rs-movies/Airport (1970)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Beastie Boys Story (2020)" rsync -avhP "/mnt/synology/rs-movies/Beastie Boys Story (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: One Magic Christmas (1985)" rsync -avhP "/mnt/unraid/media/Movies/One Magic Christmas (1985)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Extremely Wicked Shockingly Evil and Vile (2019)" rsync -avhP "/mnt/synology/rs-movies/Extremely Wicked Shockingly Evil and Vile (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Minions (2015)" rsync -avhP "/mnt/unraid/media/Movies/Minions (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Better Man (2024)" rsync -avhP "/mnt/unraid/media/Movies/Better Man (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Lean On Me (1989)" rsync -avhP "/mnt/unraid/media/Movies/Lean On Me (1989)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Meet the Spartans (2008)" rsync -avhP "/mnt/synology/rs-movies/Meet the Spartans (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Being Maria (2024)" rsync -avhP "/mnt/synology/rs-movies/Being Maria (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Gabriel Fluffy Iglesias One Show Fits All (2019)" rsync -avhP "/mnt/unraid/media/Movies/Gabriel Fluffy Iglesias One Show Fits All (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Possum (2018)" rsync -avhP "/mnt/synology/rs-movies/Possum (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: A Night in the Life of Jimmy Reardon (1988)" rsync -avhP "/mnt/synology/rs-movies/A Night in the Life of Jimmy Reardon (1988)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: License to Drive (1988)" rsync -avhP "/mnt/synology/rs-movies/License to Drive (1988)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Mamma Mia! Here We Go Again (2018)" rsync -avhP "/mnt/unraid/media/Movies/Mamma Mia! Here We Go Again (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Savage Sam (1963)" rsync -avhP "/mnt/unraid/media/Movies/Savage Sam (1963)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: In the Mood for Love (2000)" rsync -avhP "/mnt/unraid/media/Movies/In the Mood for Love (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Money Plane (2020)" rsync -avhP "/mnt/unraid/media/Movies/Money Plane (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: No Other Land (2024)" rsync -avhP "/mnt/synology/rs-movies/No Other Land (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Dragged Across Concrete (2019)" rsync -avhP "/mnt/synology/rs-movies/Dragged Across Concrete (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Johnny English Reborn (2011)" rsync -avhP "/mnt/unraid/media/Movies/Johnny English Reborn (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Croods A New Age (2020)" rsync -avhP "/mnt/unraid/media/Movies/The Croods A New Age (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Aliens vs Predator Requiem (2007)" rsync -avhP "/mnt/unraid/media/Movies/Aliens vs Predator Requiem (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Song to Song (2017)" rsync -avhP "/mnt/synology/rs-movies/Song to Song (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Devil (2010)" rsync -avhP "/mnt/synology/rs-movies/Devil (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Colonia (2015)" rsync -avhP "/mnt/synology/rs-movies/Colonia (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Suicide Squad (2021)" rsync -avhP "/mnt/unraid/media/Movies/The Suicide Squad (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: William Tell (2025)" rsync -avhP "/mnt/synology/rs-movies/William Tell (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Death Machine (1995)" rsync -avhP "/mnt/synology/rs-movies/Death Machine (1995)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Longest Day (1962)" rsync -avhP "/mnt/unraid/media/Movies/The Longest Day (1962)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Jason X (2001)" rsync -avhP "/mnt/unraid/media/Movies/Jason X (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Gunpowder Milkshake (2021)" rsync -avhP "/mnt/unraid/media/Movies/Gunpowder Milkshake (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Nate Bargatzes Nashville Christmas (2024)" rsync -avhP "/mnt/unraid/media/Movies/Nate Bargatzes Nashville Christmas (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Spider-Man Into the Spider-Verse (2018)" rsync -avhP "/mnt/unraid/media/Movies/Spider-Man Into the Spider-Verse (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: After We Fell (2021)" rsync -avhP "/mnt/unraid/media/Movies/After We Fell (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Opus (2025)" rsync -avhP "/mnt/unraid/media/Movies/Opus (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Head in the Clouds (2004)" rsync -avhP "/mnt/unraid/media/Movies/Head in the Clouds (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Professor Marston and the Wonder Women (2017)" rsync -avhP "/mnt/unraid/media/Movies/Professor Marston and the Wonder Women (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Piranha (2010)" rsync -avhP "/mnt/synology/rs-movies/Piranha (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Mission Impossible (1996)" rsync -avhP "/mnt/unraid/media/Movies/Mission Impossible (1996)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Darkman III Die Darkman Die (1996)" rsync -avhP "/mnt/synology/rs-movies/Darkman III Die Darkman Die (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: River Wild (2023)" rsync -avhP "/mnt/unraid/media/Movies/River Wild (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Rebel Moon Part One A Child of Fire (2023)" rsync -avhP "/mnt/unraid/media/Movies/Rebel Moon Part One A Child of Fire (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hector and the Search for Happiness (2014)" rsync -avhP "/mnt/synology/rs-movies/Hector and the Search for Happiness (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Terminator 2 Judgment Day (1991)" rsync -avhP "/mnt/unraid/media/Movies/Terminator 2 Judgment Day (1991)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Enemies of the People (2009)" rsync -avhP "/mnt/unraid/media/Movies/Enemies of the People (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: One Hundred and One Dalmatians (1961)" rsync -avhP "/mnt/unraid/media/Movies/One Hundred and One Dalmatians (1961)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: 30 Minutes or Less (2011)" rsync -avhP "/mnt/synology/rs-movies/30 Minutes or Less (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Bambi The Reckoning (2025)" rsync -avhP "/mnt/synology/rs-movies/Bambi The Reckoning (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Apt Pupil (1998)" rsync -avhP "/mnt/synology/rs-movies/Apt Pupil (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Executive Decision (1996)" rsync -avhP "/mnt/unraid/media/Movies/Executive Decision (1996)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dont Make Me Go (2022)" rsync -avhP "/mnt/unraid/media/Movies/Dont Make Me Go (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: George Carlin Its Bad for Ya! (2008)" rsync -avhP "/mnt/unraid/media/Movies/George Carlin Its Bad for Ya! (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Happening (2021)" rsync -avhP "/mnt/synology/rs-movies/Happening (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Deepest Breath (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Deepest Breath (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Free Solo (2018)" rsync -avhP "/mnt/unraid/media/Movies/Free Solo (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: A Christmas Carol (1984)" rsync -avhP "/mnt/synology/rs-movies/A Christmas Carol (1984)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The In Between (2022)" rsync -avhP "/mnt/unraid/media/Movies/The In Between (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: I Still Know What You Did Last Summer (1998)" rsync -avhP "/mnt/unraid/media/Movies/I Still Know What You Did Last Summer (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Patriots Day (2016)" rsync -avhP "/mnt/synology/rs-movies/Patriots Day (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Babyteeth (2020)" rsync -avhP "/mnt/synology/rs-movies/Babyteeth (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Funny Farm (1988)" rsync -avhP "/mnt/synology/rs-movies/Funny Farm (1988)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Ant-Man and the Wasp (2018)" rsync -avhP "/mnt/synology/rs-movies/Ant-Man and the Wasp (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Secret Life of Pets 2 (2019)" rsync -avhP "/mnt/synology/rs-movies/The Secret Life of Pets 2 (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: One-Eyed Jacks (1961)" rsync -avhP "/mnt/synology/rs-movies/One-Eyed Jacks (1961)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Shogun Assassin (1980)" rsync -avhP "/mnt/synology/rs-movies/Shogun Assassin (1980)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Julie and Julia (2009)" rsync -avhP "/mnt/unraid/media/Movies/Julie and Julia (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Elio (2025)" rsync -avhP "/mnt/unraid/media/Movies/Elio (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Sharp Corner (2025)" rsync -avhP "/mnt/unraid/media/Movies/Sharp Corner (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Raiders of the Lost Ark (1981)" rsync -avhP "/mnt/unraid/media/Movies/Raiders of the Lost Ark (1981)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Forgotten Experiment (2023)" rsync -avhP "/mnt/synology/rs-movies/Forgotten Experiment (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Last Thing He Wanted (2020)" rsync -avhP "/mnt/synology/rs-movies/The Last Thing He Wanted (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Ghost in the Shell (1995)" rsync -avhP "/mnt/unraid/media/Movies/Ghost in the Shell (1995)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hello! Project presents. premier seat ~ANGERME Premium~ (2020)" rsync -avhP "/mnt/synology/rs-movies/Hello! Project presents. premier seat ~ANGERME Premium~ (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Monster Squad (1987)" rsync -avhP "/mnt/unraid/media/Movies/The Monster Squad (1987)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Nate Bargatze Full Time Magic (2015)" rsync -avhP "/mnt/unraid/media/Movies/Nate Bargatze Full Time Magic (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Earth Mama (2023)" rsync -avhP "/mnt/unraid/media/Movies/Earth Mama (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Untold Johnny Football (2023)" rsync -avhP "/mnt/unraid/media/Movies/Untold Johnny Football (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Witch Hunt (2021)" rsync -avhP "/mnt/synology/rs-movies/Witch Hunt (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Three Musketeers (1973)" rsync -avhP "/mnt/synology/rs-movies/The Three Musketeers (1973)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Prep and Landing The Snowball Protocol (2025)" rsync -avhP "/mnt/unraid/media/Movies/Prep and Landing The Snowball Protocol (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Lisa Frankenstein (2024)" rsync -avhP "/mnt/unraid/media/Movies/Lisa Frankenstein (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Red Sparrow (2018)" rsync -avhP "/mnt/synology/rs-movies/Red Sparrow (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Clovehitch Killer (2018)" rsync -avhP "/mnt/synology/rs-movies/The Clovehitch Killer (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Beckett (2021)" rsync -avhP "/mnt/synology/rs-movies/Beckett (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Zero Dark Thirty (2012)" rsync -avhP "/mnt/unraid/media/Movies/Zero Dark Thirty (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Twilight (2008)" rsync -avhP "/mnt/synology/rs-movies/Twilight (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Dont Move (2024)" rsync -avhP "/mnt/unraid/media/Movies/Dont Move (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Hulk Where Monsters Dwell (2016)" rsync -avhP "/mnt/unraid/media/Movies/Hulk Where Monsters Dwell (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Ride On (2023)" rsync -avhP "/mnt/unraid/media/Movies/Ride On (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Secret Garden (2020)" rsync -avhP "/mnt/synology/rs-movies/The Secret Garden (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: D-Tox (2002)" rsync -avhP "/mnt/synology/rs-movies/D-Tox (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Hunter (2011)" rsync -avhP "/mnt/synology/rs-movies/The Hunter (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Zathura A Space Adventure (2005)" rsync -avhP "/mnt/synology/rs-movies/Zathura A Space Adventure (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Green Book (2018)" rsync -avhP "/mnt/unraid/media/Movies/Green Book (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Devils Backbone (2001)" rsync -avhP "/mnt/unraid/media/Movies/The Devils Backbone (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Battleship Island (2017)" rsync -avhP "/mnt/unraid/media/Movies/The Battleship Island (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Tombstone (1993)" rsync -avhP "/mnt/unraid/media/Movies/Tombstone (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Lovebirds (2020)" rsync -avhP "/mnt/synology/rs-movies/The Lovebirds (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Home Again (2017)" rsync -avhP "/mnt/unraid/media/Movies/Home Again (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Baker (2023)" rsync -avhP "/mnt/synology/rs-movies/The Baker (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Flashdance (1983)" rsync -avhP "/mnt/unraid/media/Movies/Flashdance (1983)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Wrong Turn (2021)" rsync -avhP "/mnt/synology/rs-movies/Wrong Turn (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Valley Girl (1983)" rsync -avhP "/mnt/synology/rs-movies/Valley Girl (1983)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Shes Out of My League (2010)" rsync -avhP "/mnt/synology/rs-movies/Shes Out of My League (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Shadow (2018)" rsync -avhP "/mnt/unraid/media/Movies/Shadow (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: 47 Meters Down Uncaged (2019)" rsync -avhP "/mnt/synology/rs-movies/47 Meters Down Uncaged (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Talk to Me (2023)" rsync -avhP "/mnt/unraid/media/Movies/Talk to Me (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Wakefield (2017)" rsync -avhP "/mnt/synology/rs-movies/Wakefield (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: 'Twas the Night Before Christmas (1974)" rsync -avhP "/mnt/synology/rs-movies/'Twas the Night Before Christmas (1974)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Thir13en Ghosts (2001)" rsync -avhP "/mnt/unraid/media/Movies/Thir13en Ghosts (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Red Right Hand (2024)" rsync -avhP "/mnt/unraid/media/Movies/Red Right Hand (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: A Nightmare on Elm Street Part 2 Freddys Revenge (1985)" rsync -avhP "/mnt/unraid/media/Movies/A Nightmare on Elm Street Part 2 Freddys Revenge (1985)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Alpha (2018)" rsync -avhP "/mnt/synology/rs-movies/Alpha (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Creed II (2018)" rsync -avhP "/mnt/unraid/media/Movies/Creed II (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Churchill (2017)" rsync -avhP "/mnt/unraid/media/Movies/Churchill (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Mothers Instinct (2024)" rsync -avhP "/mnt/unraid/media/Movies/Mothers Instinct (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Curse of the Necklace (2024)" rsync -avhP "/mnt/synology/rs-movies/The Curse of the Necklace (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Holly and the Ivy (1952)" rsync -avhP "/mnt/synology/rs-movies/The Holly and the Ivy (1952)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Green Knight (2021)" rsync -avhP "/mnt/unraid/media/Movies/The Green Knight (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Cold Light of Day (2012)" rsync -avhP "/mnt/synology/rs-movies/The Cold Light of Day (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Friend (2025)" rsync -avhP "/mnt/unraid/media/Movies/The Friend (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Get Hard (2015)" rsync -avhP "/mnt/unraid/media/Movies/Get Hard (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Puppet Master III (1992)" rsync -avhP "/mnt/synology/rs-movies/Puppet Master III (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Blood Diner (1987)" rsync -avhP "/mnt/synology/rs-movies/Blood Diner (1987)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Lord of War (2005)" rsync -avhP "/mnt/unraid/media/Movies/Lord of War (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: How to Train Your Dragon 2 (2014)" rsync -avhP "/mnt/unraid/media/Movies/How to Train Your Dragon 2 (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Hostage (2005)" rsync -avhP "/mnt/unraid/media/Movies/Hostage (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: RETURN (2024)" rsync -avhP "/mnt/synology/rs-movies/RETURN (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Underdoggs (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Underdoggs (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Big Daddy (1999)" rsync -avhP "/mnt/synology/rs-movies/Big Daddy (1999)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: A League of Their Own (1992)" rsync -avhP "/mnt/synology/rs-movies/A League of Their Own (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Souvenir (2021)" rsync -avhP "/mnt/synology/rs-movies/Souvenir (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Knowing (2009)" rsync -avhP "/mnt/unraid/media/Movies/Knowing (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: King Kong vs. Godzilla (1962)" rsync -avhP "/mnt/synology/rs-movies/King Kong vs. Godzilla (1962)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Lighthouse (2019)" rsync -avhP "/mnt/unraid/media/Movies/The Lighthouse (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Harry Potter and the Half-Blood Prince (2009)" rsync -avhP "/mnt/unraid/media/Movies/Harry Potter and the Half-Blood Prince (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Sorcerer and the White Snake (2011)" rsync -avhP "/mnt/synology/rs-movies/The Sorcerer and the White Snake (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Conclave (2024)" rsync -avhP "/mnt/unraid/media/Movies/Conclave (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Overboard (2018)" rsync -avhP "/mnt/unraid/media/Movies/Overboard (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Mad Max Fury Road (2015)" rsync -avhP "/mnt/unraid/media/Movies/Mad Max Fury Road (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Breakwater (2023)" rsync -avhP "/mnt/unraid/media/Movies/Breakwater (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The School for Good and Evil (2022)" rsync -avhP "/mnt/synology/rs-movies/The School for Good and Evil (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Rugrats Movie (1998)" rsync -avhP "/mnt/synology/rs-movies/The Rugrats Movie (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Puppet Master Doktor Death (2022)" rsync -avhP "/mnt/synology/rs-movies/Puppet Master Doktor Death (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Home Sweet Home Rebirth (2025)" rsync -avhP "/mnt/synology/rs-movies/Home Sweet Home Rebirth (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Dragons Gift of the Night Fury (2011)" rsync -avhP "/mnt/unraid/media/Movies/Dragons Gift of the Night Fury (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Apparition (2012)" rsync -avhP "/mnt/synology/rs-movies/The Apparition (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Legends of the Fall (1994)" rsync -avhP "/mnt/unraid/media/Movies/Legends of the Fall (1994)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Infinitely Polar Bear (2014)" rsync -avhP "/mnt/unraid/media/Movies/Infinitely Polar Bear (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Eden (2025)" rsync -avhP "/mnt/unraid/media/Movies/Eden (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: 12 Angry Men (1957)" rsync -avhP "/mnt/unraid/media/Movies/12 Angry Men (1957)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Time for Them to Come Home for Christmas (2021)" rsync -avhP "/mnt/synology/rs-movies/Time for Them to Come Home for Christmas (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Sixth Sense (1999)" rsync -avhP "/mnt/unraid/media/Movies/The Sixth Sense (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Muppets (2011)" rsync -avhP "/mnt/unraid/media/Movies/The Muppets (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Crossing (2024)" rsync -avhP "/mnt/unraid/media/Movies/Crossing (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Proposition (2005)" rsync -avhP "/mnt/synology/rs-movies/The Proposition (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: She Will (2022)" rsync -avhP "/mnt/unraid/media/Movies/She Will (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Bastille Day (2016)" rsync -avhP "/mnt/synology/rs-movies/Bastille Day (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Bridge on the River Kwai (1957)" rsync -avhP "/mnt/unraid/media/Movies/The Bridge on the River Kwai (1957)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Childs Play (2019)" rsync -avhP "/mnt/synology/rs-movies/Childs Play (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Breakfast Club (1985)" rsync -avhP "/mnt/unraid/media/Movies/The Breakfast Club (1985)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Return to House on Haunted Hill (2007)" rsync -avhP "/mnt/synology/rs-movies/Return to House on Haunted Hill (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Ring Two (2005)" rsync -avhP "/mnt/synology/rs-movies/The Ring Two (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Beast of Burden (2018)" rsync -avhP "/mnt/synology/rs-movies/Beast of Burden (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Logan Lucky (2017)" rsync -avhP "/mnt/unraid/media/Movies/Logan Lucky (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Batman The Long Halloween Part Two (2021)" rsync -avhP "/mnt/unraid/media/Movies/Batman The Long Halloween Part Two (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Allegiant (2016)" rsync -avhP "/mnt/unraid/media/Movies/Allegiant (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Dig (2021)" rsync -avhP "/mnt/unraid/media/Movies/The Dig (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dora and the Search for Sol Dorado (2025)" rsync -avhP "/mnt/synology/rs-movies/Dora and the Search for Sol Dorado (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Bisping (2021)" rsync -avhP "/mnt/synology/rs-movies/Bisping (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Passing (2021)" rsync -avhP "/mnt/unraid/media/Movies/Passing (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: No Exit (2022)" rsync -avhP "/mnt/synology/rs-movies/No Exit (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Pink Panther (1963)" rsync -avhP "/mnt/unraid/media/Movies/The Pink Panther (1963)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Dukes of Hazzard (2005)" rsync -avhP "/mnt/synology/rs-movies/The Dukes of Hazzard (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Valentine (2001)" rsync -avhP "/mnt/unraid/media/Movies/Valentine (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Blood Brothers Malcolm X and Muhammad Ali (2021)" rsync -avhP "/mnt/unraid/media/Movies/Blood Brothers Malcolm X and Muhammad Ali (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Black Sheep (1996)" rsync -avhP "/mnt/synology/rs-movies/Black Sheep (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Hellboy The Crooked Man (2024)" rsync -avhP "/mnt/synology/rs-movies/Hellboy The Crooked Man (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Blank Check (1994)" rsync -avhP "/mnt/synology/rs-movies/Blank Check (1994)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Escape from Mogadishu (2021)" rsync -avhP "/mnt/unraid/media/Movies/Escape from Mogadishu (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: A Week Away (2021)" rsync -avhP "/mnt/unraid/media/Movies/A Week Away (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Superman Unbound (2013)" rsync -avhP "/mnt/synology/rs-movies/Superman Unbound (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Captain Marvel (2019)" rsync -avhP "/mnt/unraid/media/Movies/Captain Marvel (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Orphan First Kill (2022)" rsync -avhP "/mnt/synology/rs-movies/Orphan First Kill (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Dirty Dozen (1967)" rsync -avhP "/mnt/synology/rs-movies/The Dirty Dozen (1967)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Ordinary Angels (2024)" rsync -avhP "/mnt/synology/rs-movies/Ordinary Angels (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Lego Batman Movie (2017)" rsync -avhP "/mnt/unraid/media/Movies/The Lego Batman Movie (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Red Sonja (2025)" rsync -avhP "/mnt/unraid/media/Movies/Red Sonja (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Whos Got the Action (1962)" rsync -avhP "/mnt/synology/rs-movies/Whos Got the Action (1962)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Chris Rock Selective Outrage (2023)" rsync -avhP "/mnt/unraid/media/Movies/Chris Rock Selective Outrage (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Snow White and the Seven Dwarfs (1938)" rsync -avhP "/mnt/synology/rs-movies/Snow White and the Seven Dwarfs (1938)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Bruised (2021)" rsync -avhP "/mnt/unraid/media/Movies/Bruised (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: I Hope They Serve Beer in Hell (2009)" rsync -avhP "/mnt/synology/rs-movies/I Hope They Serve Beer in Hell (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Santa Clause (1994)" rsync -avhP "/mnt/unraid/media/Movies/The Santa Clause (1994)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Last Dragon (1985)" rsync -avhP "/mnt/unraid/media/Movies/The Last Dragon (1985)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Master and Commander The Far Side of the World (2003)" rsync -avhP "/mnt/unraid/media/Movies/Master and Commander The Far Side of the World (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Critters (1986)" rsync -avhP "/mnt/synology/rs-movies/Critters (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Woman King (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Woman King (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Supercell (2023)" rsync -avhP "/mnt/synology/rs-movies/Supercell (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Lady in the Water (2006)" rsync -avhP "/mnt/synology/rs-movies/Lady in the Water (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Dave Chappelle The Unstoppable. (2025)" rsync -avhP "/mnt/unraid/media/Movies/Dave Chappelle The Unstoppable. (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Poseidon (2006)" rsync -avhP "/mnt/unraid/media/Movies/Poseidon (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Transporter 3 (2008)" rsync -avhP "/mnt/unraid/media/Movies/Transporter 3 (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Vesper (2022)" rsync -avhP "/mnt/unraid/media/Movies/Vesper (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Blank (2022)" rsync -avhP "/mnt/synology/rs-movies/Blank (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: White Bird (2023)" rsync -avhP "/mnt/unraid/media/Movies/White Bird (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Watership Down (1978)" rsync -avhP "/mnt/synology/rs-movies/Watership Down (1978)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Byzantium (2013)" rsync -avhP "/mnt/synology/rs-movies/Byzantium (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Home for the Holidays (1995)" rsync -avhP "/mnt/unraid/media/Movies/Home for the Holidays (1995)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Heavyweights (1995)" rsync -avhP "/mnt/synology/rs-movies/Heavyweights (1995)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: I Know What You Did Last Summer (1997)" rsync -avhP "/mnt/unraid/media/Movies/I Know What You Did Last Summer (1997)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Happiest Season (2020)" rsync -avhP "/mnt/unraid/media/Movies/Happiest Season (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Kajaki (2014)" rsync -avhP "/mnt/unraid/media/Movies/Kajaki (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Non-Stop (2014)" rsync -avhP "/mnt/unraid/media/Movies/Non-Stop (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: A Dark Song (2016)" rsync -avhP "/mnt/unraid/media/Movies/A Dark Song (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Blob (1958)" rsync -avhP "/mnt/unraid/media/Movies/The Blob (1958)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Hobbit (1977)" rsync -avhP "/mnt/synology/rs-movies/The Hobbit (1977)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Sting (1973)" rsync -avhP "/mnt/unraid/media/Movies/The Sting (1973)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dumb Money (2023)" rsync -avhP "/mnt/unraid/media/Movies/Dumb Money (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: One Hour Photo (2002)" rsync -avhP "/mnt/unraid/media/Movies/One Hour Photo (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Orphanage (2007)" rsync -avhP "/mnt/unraid/media/Movies/The Orphanage (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dangerous Animals (2025)" rsync -avhP "/mnt/unraid/media/Movies/Dangerous Animals (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Judy Moody and the Not Bummer Summer (2011)" rsync -avhP "/mnt/synology/rs-movies/Judy Moody and the Not Bummer Summer (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Charlies Angels (2000)" rsync -avhP "/mnt/unraid/media/Movies/Charlies Angels (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: SpaceCamp (1986)" rsync -avhP "/mnt/synology/rs-movies/SpaceCamp (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Spotlight (2015)" rsync -avhP "/mnt/unraid/media/Movies/Spotlight (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Three Musketeers (1993)" rsync -avhP "/mnt/synology/rs-movies/The Three Musketeers (1993)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Force of Nature The Dry 2 (2024)" rsync -avhP "/mnt/synology/rs-movies/Force of Nature The Dry 2 (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Royal Hotel (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Royal Hotel (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Cloudy with a Chance of Meatballs (2009)" rsync -avhP "/mnt/synology/rs-movies/Cloudy with a Chance of Meatballs (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Every Which Way but Loose (1978)" rsync -avhP "/mnt/synology/rs-movies/Every Which Way but Loose (1978)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Alarum (2025)" rsync -avhP "/mnt/synology/rs-movies/Alarum (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Goods Live Hard Sell Hard (2009)" rsync -avhP "/mnt/synology/rs-movies/The Goods Live Hard Sell Hard (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Janet Planet (2024)" rsync -avhP "/mnt/unraid/media/Movies/Janet Planet (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: V H S 2 (2013)" rsync -avhP "/mnt/synology/rs-movies/V H S 2 (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Who Am I (2014)" rsync -avhP "/mnt/synology/rs-movies/Who Am I (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Imaginary (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Imaginary (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Iron Man 3 (2013)" rsync -avhP "/mnt/unraid/media/Movies/Iron Man 3 (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Outlaw Josey Wales (1976)" rsync -avhP "/mnt/synology/rs-movies/The Outlaw Josey Wales (1976)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Almost Heroes (1998)" rsync -avhP "/mnt/unraid/media/Movies/Almost Heroes (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dont Go Near the Park (1981)" rsync -avhP "/mnt/synology/rs-movies/Dont Go Near the Park (1981)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Harley Davidson and the Marlboro Man (1991)" rsync -avhP "/mnt/synology/rs-movies/Harley Davidson and the Marlboro Man (1991)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: 12 Years a Slave (2013)" rsync -avhP "/mnt/synology/rs-movies/12 Years a Slave (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Life List (2025)" rsync -avhP "/mnt/unraid/media/Movies/The Life List (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Drunk Bus (2021)" rsync -avhP "/mnt/synology/rs-movies/Drunk Bus (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: 8MM (1999)" rsync -avhP "/mnt/synology/rs-movies/8MM (1999)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: RRR (2022)" rsync -avhP "/mnt/synology/rs-movies/RRR (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Cowboys (1972)" rsync -avhP "/mnt/synology/rs-movies/The Cowboys (1972)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Gullivers Travels (2010)" rsync -avhP "/mnt/synology/rs-movies/Gullivers Travels (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Limitless (2011)" rsync -avhP "/mnt/unraid/media/Movies/Limitless (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Planes Trains and Automobiles (1987)" rsync -avhP "/mnt/unraid/media/Movies/Planes Trains and Automobiles (1987)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Agent Game (2022)" rsync -avhP "/mnt/unraid/media/Movies/Agent Game (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Rough Night in Jericho (1967)" rsync -avhP "/mnt/synology/rs-movies/Rough Night in Jericho (1967)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: A Fistful of Dollars (1964)" rsync -avhP "/mnt/synology/rs-movies/A Fistful of Dollars (1964)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Leave the World Behind (2023)" rsync -avhP "/mnt/unraid/media/Movies/Leave the World Behind (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The DUFF (2015)" rsync -avhP "/mnt/synology/rs-movies/The DUFF (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Man from Rome (2022)" rsync -avhP "/mnt/synology/rs-movies/The Man from Rome (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Dave Chappelle The Age of Spin (2017)" rsync -avhP "/mnt/unraid/media/Movies/Dave Chappelle The Age of Spin (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Aristocats (1970)" rsync -avhP "/mnt/unraid/media/Movies/The Aristocats (1970)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Mercy (2018)" rsync -avhP "/mnt/synology/rs-movies/The Mercy (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Lost in Translation (2003)" rsync -avhP "/mnt/unraid/media/Movies/Lost in Translation (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Perfect Days (2023)" rsync -avhP "/mnt/unraid/media/Movies/Perfect Days (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Cheaper by the Dozen (2003)" rsync -avhP "/mnt/synology/rs-movies/Cheaper by the Dozen (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Frost Bite (2011)" rsync -avhP "/mnt/synology/rs-movies/Frost Bite (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Overboard (1987)" rsync -avhP "/mnt/synology/rs-movies/Overboard (1987)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Reluctant Dragon (1941)" rsync -avhP "/mnt/unraid/media/Movies/The Reluctant Dragon (1941)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Babes (2024)" rsync -avhP "/mnt/synology/rs-movies/Babes (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Criminal (2004)" rsync -avhP "/mnt/synology/rs-movies/Criminal (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Wolf (1994)" rsync -avhP "/mnt/unraid/media/Movies/Wolf (1994)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Guyver (1991)" rsync -avhP "/mnt/synology/rs-movies/The Guyver (1991)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Merry Christmas Ted Cooper! (2025)" rsync -avhP "/mnt/synology/rs-movies/Merry Christmas Ted Cooper! (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Amityville Horror (2005)" rsync -avhP "/mnt/synology/rs-movies/The Amityville Horror (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Three Caballeros (1944)" rsync -avhP "/mnt/synology/rs-movies/The Three Caballeros (1944)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Tank (1984)" rsync -avhP "/mnt/synology/rs-movies/Tank (1984)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Day of the Dead (1985)" rsync -avhP "/mnt/synology/rs-movies/Day of the Dead (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Matrix Resurrections (2021)" rsync -avhP "/mnt/unraid/media/Movies/The Matrix Resurrections (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: An Alpine Holiday (2025)" rsync -avhP "/mnt/synology/rs-movies/An Alpine Holiday (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Fixed (2025)" rsync -avhP "/mnt/unraid/media/Movies/Fixed (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Promised Land (1975)" rsync -avhP "/mnt/synology/rs-movies/The Promised Land (1975)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Back to Black (2024)" rsync -avhP "/mnt/unraid/media/Movies/Back to Black (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Im Still Here (2024)" rsync -avhP "/mnt/unraid/media/Movies/Im Still Here (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: King of New York (1990)" rsync -avhP "/mnt/synology/rs-movies/King of New York (1990)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Monsters (2010)" rsync -avhP "/mnt/unraid/media/Movies/Monsters (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Red Cliff II (2009)" rsync -avhP "/mnt/synology/rs-movies/Red Cliff II (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Beau Is Afraid (2023)" rsync -avhP "/mnt/unraid/media/Movies/Beau Is Afraid (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: John Wick Chapter 4 (2023)" rsync -avhP "/mnt/unraid/media/Movies/John Wick Chapter 4 (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Joe Dirt (2001)" rsync -avhP "/mnt/synology/rs-movies/Joe Dirt (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Zookeepers Wife (2017)" rsync -avhP "/mnt/unraid/media/Movies/The Zookeepers Wife (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Cloud Atlas (2012)" rsync -avhP "/mnt/unraid/media/Movies/Cloud Atlas (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Wishmas Tree (2020)" rsync -avhP "/mnt/synology/rs-movies/The Wishmas Tree (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Five Nights at Freddy's (2023)" rsync -avhP "/mnt/unraid/media/Movies/Five Nights at Freddy's (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Control Freak (2025)" rsync -avhP "/mnt/synology/rs-movies/Control Freak (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Watch (2012)" rsync -avhP "/mnt/unraid/media/Movies/The Watch (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Justice League The New Frontier (2008)" rsync -avhP "/mnt/synology/rs-movies/Justice League The New Frontier (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Machinist (2004)" rsync -avhP "/mnt/synology/rs-movies/The Machinist (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Witches (1990)" rsync -avhP "/mnt/unraid/media/Movies/The Witches (1990)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Quest for Camelot (1998)" rsync -avhP "/mnt/synology/rs-movies/Quest for Camelot (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Ju-on The Grudge (2002)" rsync -avhP "/mnt/synology/rs-movies/Ju-on The Grudge (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Godzilla x Kong The New Empire (2024)" rsync -avhP "/mnt/unraid/media/Movies/Godzilla x Kong The New Empire (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: True Grit (2010)" rsync -avhP "/mnt/unraid/media/Movies/True Grit (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Hunger Games (2012)" rsync -avhP "/mnt/unraid/media/Movies/The Hunger Games (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: First Man (2018)" rsync -avhP "/mnt/synology/rs-movies/First Man (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: For Love of the Game (1999)" rsync -avhP "/mnt/synology/rs-movies/For Love of the Game (1999)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: ParaNorman (2012)" rsync -avhP "/mnt/synology/rs-movies/ParaNorman (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Frozen II (2019)" rsync -avhP "/mnt/unraid/media/Movies/Frozen II (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Thundermans Return (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Thundermans Return (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Beast (1988)" rsync -avhP "/mnt/unraid/media/Movies/The Beast (1988)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Grapes of Wrath (1940)" rsync -avhP "/mnt/synology/rs-movies/The Grapes of Wrath (1940)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The End of the Tour (2015)" rsync -avhP "/mnt/unraid/media/Movies/The End of the Tour (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Attack on Titan Chronicle (2020)" rsync -avhP "/mnt/synology/rs-movies/Attack on Titan Chronicle (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: A Drop of the Grapevine (2014)" rsync -avhP "/mnt/synology/rs-movies/A Drop of the Grapevine (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Dead Hot (2023)" rsync -avhP "/mnt/synology/rs-movies/Dead Hot (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Dracula A.D. 1972 (1972)" rsync -avhP "/mnt/synology/rs-movies/Dracula A.D. 1972 (1972)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Casper (1995)" rsync -avhP "/mnt/unraid/media/Movies/Casper (1995)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Sleeping with the Enemy (1991)" rsync -avhP "/mnt/synology/rs-movies/Sleeping with the Enemy (1991)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: You Again (2010)" rsync -avhP "/mnt/synology/rs-movies/You Again (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Dr. No (1962)" rsync -avhP "/mnt/unraid/media/Movies/Dr. No (1962)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Where the Crawdads Sing (2022)" rsync -avhP "/mnt/synology/rs-movies/Where the Crawdads Sing (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Hot Fuzz (2007)" rsync -avhP "/mnt/unraid/media/Movies/Hot Fuzz (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Boy (2016)" rsync -avhP "/mnt/synology/rs-movies/The Boy (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Frank and Lola (2016)" rsync -avhP "/mnt/synology/rs-movies/Frank and Lola (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Soul (2020)" rsync -avhP "/mnt/unraid/media/Movies/Soul (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Wish Dragon (2021)" rsync -avhP "/mnt/unraid/media/Movies/Wish Dragon (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Date Movie (2006)" rsync -avhP "/mnt/synology/rs-movies/Date Movie (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Incendies (2010)" rsync -avhP "/mnt/unraid/media/Movies/Incendies (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Kellys Heroes (1970)" rsync -avhP "/mnt/synology/rs-movies/Kellys Heroes (1970)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Open Wide (2024)" rsync -avhP "/mnt/unraid/media/Movies/Open Wide (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Lion King (1994)" rsync -avhP "/mnt/unraid/media/Movies/The Lion King (1994)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Lucas (1986)" rsync -avhP "/mnt/synology/rs-movies/Lucas (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Texas Chainsaw Massacre (2003)" rsync -avhP "/mnt/unraid/media/Movies/The Texas Chainsaw Massacre (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Escape from New York (1981)" rsync -avhP "/mnt/synology/rs-movies/Escape from New York (1981)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Trolls Holiday in Harmony (2021)" rsync -avhP "/mnt/unraid/media/Movies/Trolls Holiday in Harmony (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Nice Dreams (1981)" rsync -avhP "/mnt/synology/rs-movies/Nice Dreams (1981)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: A Midnight Clear (1992)" rsync -avhP "/mnt/unraid/media/Movies/A Midnight Clear (1992)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Sherlock Holmes A Game of Shadows (2011)" rsync -avhP "/mnt/unraid/media/Movies/Sherlock Holmes A Game of Shadows (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Super 8 (2011)" rsync -avhP "/mnt/synology/rs-movies/Super 8 (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Sea Beast (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Sea Beast (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Darkman (1990)" rsync -avhP "/mnt/unraid/media/Movies/Darkman (1990)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Money Pit (1986)" rsync -avhP "/mnt/synology/rs-movies/The Money Pit (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Last Action Hero (1993)" rsync -avhP "/mnt/unraid/media/Movies/Last Action Hero (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Paranoia (2013)" rsync -avhP "/mnt/synology/rs-movies/Paranoia (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Risen (2020)" rsync -avhP "/mnt/synology/rs-movies/Risen (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Seed of the Sacred Fig (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Seed of the Sacred Fig (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Rumble Fish (1983)" rsync -avhP "/mnt/unraid/media/Movies/Rumble Fish (1983)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Juror #2 (2024)" rsync -avhP "/mnt/unraid/media/Movies/Juror #2 (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Underworld Awakening (2012)" rsync -avhP "/mnt/unraid/media/Movies/Underworld Awakening (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Ride Along (2014)" rsync -avhP "/mnt/unraid/media/Movies/Ride Along (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Mission Impossible III (2006)" rsync -avhP "/mnt/unraid/media/Movies/Mission Impossible III (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Stewie Griffin The Untold Story (2005)" rsync -avhP "/mnt/synology/rs-movies/Stewie Griffin The Untold Story (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: In the Army Now (1994)" rsync -avhP "/mnt/synology/rs-movies/In the Army Now (1994)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Pirates! In an Adventure with Scientists! (2012)" rsync -avhP "/mnt/unraid/media/Movies/The Pirates! In an Adventure with Scientists! (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Alpha and Omega (2010)" rsync -avhP "/mnt/synology/rs-movies/Alpha and Omega (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Confessions of a Shopaholic (2009)" rsync -avhP "/mnt/synology/rs-movies/Confessions of a Shopaholic (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Nanny McPhee (2005)" rsync -avhP "/mnt/synology/rs-movies/Nanny McPhee (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: My Science Project (1985)" rsync -avhP "/mnt/synology/rs-movies/My Science Project (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Oceans Eleven (1960)" rsync -avhP "/mnt/synology/rs-movies/Oceans Eleven (1960)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Judas and the Black Messiah (2021)" rsync -avhP "/mnt/unraid/media/Movies/Judas and the Black Messiah (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Lets Be Cops (2014)" rsync -avhP "/mnt/synology/rs-movies/Lets Be Cops (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Superman Batman Public Enemies (2009)" rsync -avhP "/mnt/unraid/media/Movies/Superman Batman Public Enemies (2009)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: The Dive (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Dive (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Spy Kids 3-D Game Over (2003)" rsync -avhP "/mnt/synology/rs-movies/Spy Kids 3-D Game Over (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Holland (2025)" rsync -avhP "/mnt/unraid/media/Movies/Holland (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: 2067 (2020)" rsync -avhP "/mnt/synology/rs-movies/2067 (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Constantine (2005)" rsync -avhP "/mnt/unraid/media/Movies/Constantine (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The First Omen (2024)" rsync -avhP "/mnt/synology/rs-movies/The First Omen (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Pan (2015)" rsync -avhP "/mnt/unraid/media/Movies/Pan (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Mortal Kombat Legends Scorpions Revenge (2020)" rsync -avhP "/mnt/synology/rs-movies/Mortal Kombat Legends Scorpions Revenge (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Freddy vs. Jason (2003)" rsync -avhP "/mnt/unraid/media/Movies/Freddy vs. Jason (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Deck the Halls (2006)" rsync -avhP "/mnt/synology/rs-movies/Deck the Halls (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Rule of Jenny Pen (2025)" rsync -avhP "/mnt/unraid/media/Movies/The Rule of Jenny Pen (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Murder Party (2007)" rsync -avhP "/mnt/unraid/media/Movies/Murder Party (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Santa Claus Is Comin to Town (1970)" rsync -avhP "/mnt/unraid/media/Movies/Santa Claus Is Comin to Town (1970)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Mob Cops (2025)" rsync -avhP "/mnt/unraid/media/Movies/Mob Cops (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Trespass Against Us (2016)" rsync -avhP "/mnt/unraid/media/Movies/Trespass Against Us (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Support Your Local Gunfighter (1971)" rsync -avhP "/mnt/synology/rs-movies/Support Your Local Gunfighter (1971)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Whale (2022)" rsync -avhP "/mnt/synology/rs-movies/The Whale (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Silent Night Deadly Night III Better Watch Out! (1989)" rsync -avhP "/mnt/synology/rs-movies/Silent Night Deadly Night III Better Watch Out! (1989)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Lars and the Real Girl (2007)" rsync -avhP "/mnt/unraid/media/Movies/Lars and the Real Girl (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: 3 - 10 to Yuma (2007)" rsync -avhP "/mnt/unraid/media/Movies/3 - 10 to Yuma (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Multiplicity (1996)" rsync -avhP "/mnt/synology/rs-movies/Multiplicity (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Baramulla (2025)" rsync -avhP "/mnt/unraid/media/Movies/Baramulla (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Halloween II (1981)" rsync -avhP "/mnt/unraid/media/Movies/Halloween II (1981)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dragonkeeper (2024)" rsync -avhP "/mnt/synology/rs-movies/Dragonkeeper (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Heartbreak Ridge (1986)" rsync -avhP "/mnt/unraid/media/Movies/Heartbreak Ridge (1986)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Genie (2023)" rsync -avhP "/mnt/unraid/media/Movies/Genie (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Star Wars The Rise of Skywalker (2019)" rsync -avhP "/mnt/unraid/media/Movies/Star Wars The Rise of Skywalker (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Dyatlov Pass Incident (2013)" rsync -avhP "/mnt/synology/rs-movies/The Dyatlov Pass Incident (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Novocaine (2001)" rsync -avhP "/mnt/synology/rs-movies/Novocaine (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Expend4bles (2023)" rsync -avhP "/mnt/unraid/media/Movies/Expend4bles (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Reign Over Me (2007)" rsync -avhP "/mnt/synology/rs-movies/Reign Over Me (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Animal (2001)" rsync -avhP "/mnt/unraid/media/Movies/The Animal (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Babysitter (2017)" rsync -avhP "/mnt/synology/rs-movies/The Babysitter (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Dream House (2011)" rsync -avhP "/mnt/synology/rs-movies/Dream House (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Win Win (2011)" rsync -avhP "/mnt/unraid/media/Movies/Win Win (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Christmas Everlasting (2018)" rsync -avhP "/mnt/synology/rs-movies/Christmas Everlasting (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Untold Herstory (2022)" rsync -avhP "/mnt/synology/rs-movies/Untold Herstory (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Airplane! (1980)" rsync -avhP "/mnt/unraid/media/Movies/Airplane! (1980)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Ready Player One (2018)" rsync -avhP "/mnt/unraid/media/Movies/Ready Player One (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Dark Knight (2008)" rsync -avhP "/mnt/unraid/media/Movies/The Dark Knight (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: MLK FBI (2020)" rsync -avhP "/mnt/unraid/media/Movies/MLK FBI (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Heart of Stone (2023)" rsync -avhP "/mnt/unraid/media/Movies/Heart of Stone (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Arlington Road (1999)" rsync -avhP "/mnt/unraid/media/Movies/Arlington Road (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Early Man (2018)" rsync -avhP "/mnt/unraid/media/Movies/Early Man (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Juliet Naked (2018)" rsync -avhP "/mnt/unraid/media/Movies/Juliet Naked (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Wyrmwood Road of the Dead (2014)" rsync -avhP "/mnt/synology/rs-movies/Wyrmwood Road of the Dead (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Strays (2023)" rsync -avhP "/mnt/unraid/media/Movies/Strays (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Gunslingers (2025)" rsync -avhP "/mnt/unraid/media/Movies/Gunslingers (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Wanted (2008)" rsync -avhP "/mnt/unraid/media/Movies/Wanted (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Decoy Bride (2011)" rsync -avhP "/mnt/synology/rs-movies/The Decoy Bride (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Mars Express (2023)" rsync -avhP "/mnt/unraid/media/Movies/Mars Express (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Atlantis Milos Return (2003)" rsync -avhP "/mnt/synology/rs-movies/Atlantis Milos Return (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Prison Break The Final Break (2009)" rsync -avhP "/mnt/unraid/media/Movies/Prison Break The Final Break (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Crossing (2024)" rsync -avhP "/mnt/synology/rs-movies/Crossing (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: A History of Violence (2005)" rsync -avhP "/mnt/unraid/media/Movies/A History of Violence (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Emmet Otters Jug-Band Christmas (1977)" rsync -avhP "/mnt/synology/rs-movies/Emmet Otters Jug-Band Christmas (1977)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Monty Python and the Holy Grail (1975)" rsync -avhP "/mnt/unraid/media/Movies/Monty Python and the Holy Grail (1975)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Funny Girl (2018)" rsync -avhP "/mnt/unraid/media/Movies/Funny Girl (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Goldfinger (1964)" rsync -avhP "/mnt/unraid/media/Movies/Goldfinger (1964)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dirty Harry (1971)" rsync -avhP "/mnt/unraid/media/Movies/Dirty Harry (1971)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Menace II Society (1993)" rsync -avhP "/mnt/unraid/media/Movies/Menace II Society (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hiding Out (1987)" rsync -avhP "/mnt/synology/rs-movies/Hiding Out (1987)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Awake (2019)" rsync -avhP "/mnt/synology/rs-movies/Awake (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Book of Life (2014)" rsync -avhP "/mnt/synology/rs-movies/The Book of Life (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Tuesday (2024)" rsync -avhP "/mnt/unraid/media/Movies/Tuesday (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Bottoms (2023)" rsync -avhP "/mnt/unraid/media/Movies/Bottoms (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: 5 Days of War (2011)" rsync -avhP "/mnt/synology/rs-movies/5 Days of War (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Void (2016)" rsync -avhP "/mnt/synology/rs-movies/The Void (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Contraband (2012)" rsync -avhP "/mnt/synology/rs-movies/Contraband (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Anyone But You (2023)" rsync -avhP "/mnt/unraid/media/Movies/Anyone But You (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Last Voyage of the Demeter (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Last Voyage of the Demeter (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Magnificent Seven (1960)" rsync -avhP "/mnt/unraid/media/Movies/The Magnificent Seven (1960)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Jeremiah Johnson (1972)" rsync -avhP "/mnt/synology/rs-movies/Jeremiah Johnson (1972)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: BASEketball (1998)" rsync -avhP "/mnt/synology/rs-movies/BASEketball (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Pet Sematary (1989)" rsync -avhP "/mnt/unraid/media/Movies/Pet Sematary (1989)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Cash Out (2024)" rsync -avhP "/mnt/unraid/media/Movies/Cash Out (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Passengers (2016)" rsync -avhP "/mnt/unraid/media/Movies/Passengers (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Brigsby Bear (2017)" rsync -avhP "/mnt/synology/rs-movies/Brigsby Bear (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Borderline (2025)" rsync -avhP "/mnt/unraid/media/Movies/Borderline (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Daylight (1996)" rsync -avhP "/mnt/unraid/media/Movies/Daylight (1996)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Sloth Lane (2024)" rsync -avhP "/mnt/synology/rs-movies/The Sloth Lane (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Tangled Ever After (2012)" rsync -avhP "/mnt/synology/rs-movies/Tangled Ever After (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Home Alone 3 (1997)" rsync -avhP "/mnt/synology/rs-movies/Home Alone 3 (1997)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Sin City A Dame to Kill For (2014)" rsync -avhP "/mnt/unraid/media/Movies/Sin City A Dame to Kill For (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Star Trek Into Darkness (2013)" rsync -avhP "/mnt/unraid/media/Movies/Star Trek Into Darkness (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Christmas at the Palace (2018)" rsync -avhP "/mnt/synology/rs-movies/Christmas at the Palace (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Twitches (2005)" rsync -avhP "/mnt/synology/rs-movies/Twitches (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Nanny (2022)" rsync -avhP "/mnt/unraid/media/Movies/Nanny (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Order (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Order (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Beer League (2006)" rsync -avhP "/mnt/unraid/media/Movies/Beer League (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hereafter (2010)" rsync -avhP "/mnt/synology/rs-movies/Hereafter (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Romy and Micheles High School Reunion (1997)" rsync -avhP "/mnt/synology/rs-movies/Romy and Micheles High School Reunion (1997)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Deep Fear (2023)" rsync -avhP "/mnt/synology/rs-movies/Deep Fear (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Splitsville (2025)" rsync -avhP "/mnt/unraid/media/Movies/Splitsville (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Inception (2010)" rsync -avhP "/mnt/synology/rs-movies/Inception (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: USS Indianapolis Men of Courage (2016)" rsync -avhP "/mnt/synology/rs-movies/USS Indianapolis Men of Courage (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Rad (1986)" rsync -avhP "/mnt/synology/rs-movies/Rad (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Puppet Master Axis of Evil (2010)" rsync -avhP "/mnt/synology/rs-movies/Puppet Master Axis of Evil (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Oblivion (2013)" rsync -avhP "/mnt/unraid/media/Movies/Oblivion (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Alienoid (2022)" rsync -avhP "/mnt/unraid/media/Movies/Alienoid (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Kill Bill Vol. 1 (2003)" rsync -avhP "/mnt/unraid/media/Movies/Kill Bill Vol. 1 (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Gandhi (1982)" rsync -avhP "/mnt/unraid/media/Movies/Gandhi (1982)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Any Given Sunday (1999)" rsync -avhP "/mnt/synology/rs-movies/Any Given Sunday (1999)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: West Side Story (1961)" rsync -avhP "/mnt/unraid/media/Movies/West Side Story (1961)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Abduction (2011)" rsync -avhP "/mnt/synology/rs-movies/Abduction (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Apollo 18 (2011)" rsync -avhP "/mnt/synology/rs-movies/Apollo 18 (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Love Hurts (2025)" rsync -avhP "/mnt/unraid/media/Movies/Love Hurts (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dinner in America (2020)" rsync -avhP "/mnt/unraid/media/Movies/Dinner in America (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Lore (2024)" rsync -avhP "/mnt/synology/rs-movies/Lore (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Three Musketeers D'Artagnan (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Three Musketeers D'Artagnan (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: A Bronx Tale (1993)" rsync -avhP "/mnt/synology/rs-movies/A Bronx Tale (1993)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: G.I. Joe The Rise of Cobra (2009)" rsync -avhP "/mnt/synology/rs-movies/G.I. Joe The Rise of Cobra (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Colony (2013)" rsync -avhP "/mnt/synology/rs-movies/The Colony (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Circus World (1964)" rsync -avhP "/mnt/synology/rs-movies/Circus World (1964)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: American History X (1998)" rsync -avhP "/mnt/synology/rs-movies/American History X (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Galaxy Quest (1999)" rsync -avhP "/mnt/unraid/media/Movies/Galaxy Quest (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Secret Headquarters (2022)" rsync -avhP "/mnt/synology/rs-movies/Secret Headquarters (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Lost Highway (1997)" rsync -avhP "/mnt/unraid/media/Movies/Lost Highway (1997)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Trainspotting (1996)" rsync -avhP "/mnt/unraid/media/Movies/Trainspotting (1996)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Wolverine (2013)" rsync -avhP "/mnt/unraid/media/Movies/The Wolverine (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Final Countdown (1980)" rsync -avhP "/mnt/synology/rs-movies/The Final Countdown (1980)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Wicked (2013)" rsync -avhP "/mnt/unraid/media/Movies/The Wicked (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: TMNT (2007)" rsync -avhP "/mnt/synology/rs-movies/TMNT (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Humane (2024)" rsync -avhP "/mnt/unraid/media/Movies/Humane (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Frank and Penelope (2022)" rsync -avhP "/mnt/unraid/media/Movies/Frank and Penelope (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Cinderella II Dreams Come True (2002)" rsync -avhP "/mnt/unraid/media/Movies/Cinderella II Dreams Come True (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Cinderella (1950)" rsync -avhP "/mnt/unraid/media/Movies/Cinderella (1950)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: World War Z (2013)" rsync -avhP "/mnt/unraid/media/Movies/World War Z (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Arcadian (2024)" rsync -avhP "/mnt/unraid/media/Movies/Arcadian (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Observe and Report (2009)" rsync -avhP "/mnt/unraid/media/Movies/Observe and Report (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Cult Killer (2024)" rsync -avhP "/mnt/unraid/media/Movies/Cult Killer (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Superman Red Son (2020)" rsync -avhP "/mnt/synology/rs-movies/Superman Red Son (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Fury (2014)" rsync -avhP "/mnt/unraid/media/Movies/Fury (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Harry Potter and the Philosophers Stone (2001)" rsync -avhP "/mnt/unraid/media/Movies/Harry Potter and the Philosophers Stone (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Last Lions (2011)" rsync -avhP "/mnt/unraid/media/Movies/The Last Lions (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Reminiscence (2021)" rsync -avhP "/mnt/unraid/media/Movies/Reminiscence (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Evita (1996)" rsync -avhP "/mnt/synology/rs-movies/Evita (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Mortal Kombat Legends Battle of the Realms (2021)" rsync -avhP "/mnt/synology/rs-movies/Mortal Kombat Legends Battle of the Realms (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Knives Out (2019)" rsync -avhP "/mnt/unraid/media/Movies/Knives Out (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Sonic the Hedgehog 2 (2022)" rsync -avhP "/mnt/unraid/media/Movies/Sonic the Hedgehog 2 (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Client (1994)" rsync -avhP "/mnt/synology/rs-movies/The Client (1994)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Mystic River (2003)" rsync -avhP "/mnt/synology/rs-movies/Mystic River (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Damien Omen II (1978)" rsync -avhP "/mnt/synology/rs-movies/Damien Omen II (1978)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Madagascar 3 Europes Most Wanted (2012)" rsync -avhP "/mnt/unraid/media/Movies/Madagascar 3 Europes Most Wanted (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The More the Merrier (2025)" rsync -avhP "/mnt/synology/rs-movies/The More the Merrier (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Mexican (2001)" rsync -avhP "/mnt/synology/rs-movies/The Mexican (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: In a Valley of Violence (2016)" rsync -avhP "/mnt/unraid/media/Movies/In a Valley of Violence (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Splinter (2006)" rsync -avhP "/mnt/synology/rs-movies/Splinter (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Private Parts (1997)" rsync -avhP "/mnt/unraid/media/Movies/Private Parts (1997)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Knock Knock (2015)" rsync -avhP "/mnt/synology/rs-movies/Knock Knock (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Game (1997)" rsync -avhP "/mnt/unraid/media/Movies/The Game (1997)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Stranger (2022)" rsync -avhP "/mnt/synology/rs-movies/Stranger (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Errand Boy (1961)" rsync -avhP "/mnt/synology/rs-movies/The Errand Boy (1961)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Square (2008)" rsync -avhP "/mnt/synology/rs-movies/The Square (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Prophecy (1995)" rsync -avhP "/mnt/synology/rs-movies/Prophecy (1995)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Phoenician Scheme (2025)" rsync -avhP "/mnt/unraid/media/Movies/The Phoenician Scheme (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Valet (2006)" rsync -avhP "/mnt/synology/rs-movies/The Valet (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Bert Kreischer Secret Time (2018)" rsync -avhP "/mnt/synology/rs-movies/Bert Kreischer Secret Time (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Tom and Huck (1995)" rsync -avhP "/mnt/synology/rs-movies/Tom and Huck (1995)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Boss Baby Family Business (2021)" rsync -avhP "/mnt/unraid/media/Movies/The Boss Baby Family Business (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Unforgiven (1960)" rsync -avhP "/mnt/synology/rs-movies/The Unforgiven (1960)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: South Park the Streaming Wars Part 2 (2022)" rsync -avhP "/mnt/unraid/media/Movies/South Park the Streaming Wars Part 2 (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Hillbilly Elegy (2020)" rsync -avhP "/mnt/unraid/media/Movies/Hillbilly Elegy (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Disconnect (2013)" rsync -avhP "/mnt/unraid/media/Movies/Disconnect (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Winnie-the-Pooh Blood and Honey 2 (2024)" rsync -avhP "/mnt/synology/rs-movies/Winnie-the-Pooh Blood and Honey 2 (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Winnie-the-Pooh Blood and Honey 2 (2024)" rsync -avhP "/mnt/synology/rs-movies/Winnie-the-Pooh Blood and Honey 2 (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Invictus (2009)" rsync -avhP "/mnt/unraid/media/Movies/Invictus (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Fantasia 2000 (2000)" rsync -avhP "/mnt/unraid/media/Movies/Fantasia 2000 (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Landscape with Invisible Hand (2023)" rsync -avhP "/mnt/synology/rs-movies/Landscape with Invisible Hand (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Joyland (2022)" rsync -avhP "/mnt/synology/rs-movies/Joyland (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Princess and the Frog (2009)" rsync -avhP "/mnt/unraid/media/Movies/The Princess and the Frog (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Like Crazy (2011)" rsync -avhP "/mnt/synology/rs-movies/Like Crazy (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Bill and Ted Face the Music (2020)" rsync -avhP "/mnt/unraid/media/Movies/Bill and Ted Face the Music (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Firestarter (2022)" rsync -avhP "/mnt/unraid/media/Movies/Firestarter (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Hotel Transylvania 3 Summer Vacation (2018)" rsync -avhP "/mnt/unraid/media/Movies/Hotel Transylvania 3 Summer Vacation (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Little Bone Lodge (2023)" rsync -avhP "/mnt/unraid/media/Movies/Little Bone Lodge (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Delivery Man (2013)" rsync -avhP "/mnt/synology/rs-movies/Delivery Man (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Ted (2012)" rsync -avhP "/mnt/synology/rs-movies/Ted (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: U2 Rattle and Hum (1988)" rsync -avhP "/mnt/synology/rs-movies/U2 Rattle and Hum (1988)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Rush (1991)" rsync -avhP "/mnt/unraid/media/Movies/Rush (1991)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Roma (2018)" rsync -avhP "/mnt/unraid/media/Movies/Roma (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Gangster Squad (2013)" rsync -avhP "/mnt/unraid/media/Movies/Gangster Squad (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hellraiser Revelations (2011)" rsync -avhP "/mnt/synology/rs-movies/Hellraiser Revelations (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Young Guns (1988)" rsync -avhP "/mnt/unraid/media/Movies/Young Guns (1988)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Twice Born (2012)" rsync -avhP "/mnt/synology/rs-movies/Twice Born (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Its Hidden in the Dormitory (1987)" rsync -avhP "/mnt/synology/rs-movies/Its Hidden in the Dormitory (1987)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: R.I.P.D. 2 Rise of the Damned (2022)" rsync -avhP "/mnt/synology/rs-movies/R.I.P.D. 2 Rise of the Damned (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Twilight Saga Breaking Dawn Part 1 (2011)" rsync -avhP "/mnt/synology/rs-movies/The Twilight Saga Breaking Dawn Part 1 (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: 7500 (2019)" rsync -avhP "/mnt/synology/rs-movies/7500 (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Union (2024)" rsync -avhP "/mnt/synology/rs-movies/The Union (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: A Family Affair (2024)" rsync -avhP "/mnt/unraid/media/Movies/A Family Affair (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Bandolero! (1968)" rsync -avhP "/mnt/synology/rs-movies/Bandolero! (1968)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Frosty the Snowman (1969)" rsync -avhP "/mnt/synology/rs-movies/Frosty the Snowman (1969)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Christy (2025)" rsync -avhP "/mnt/unraid/media/Movies/Christy (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Bank Job (2008)" rsync -avhP "/mnt/unraid/media/Movies/The Bank Job (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Metal Lords (2022)" rsync -avhP "/mnt/synology/rs-movies/Metal Lords (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Bert Kreischer The Machine (2016)" rsync -avhP "/mnt/synology/rs-movies/Bert Kreischer The Machine (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Lighthouse (2010)" rsync -avhP "/mnt/synology/rs-movies/Lighthouse (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Sweet Country (2018)" rsync -avhP "/mnt/synology/rs-movies/Sweet Country (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Good Burger 2 (2023)" rsync -avhP "/mnt/unraid/media/Movies/Good Burger 2 (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Great Escaper (2023)" rsync -avhP "/mnt/synology/rs-movies/The Great Escaper (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Incredibles 2 (2018)" rsync -avhP "/mnt/unraid/media/Movies/Incredibles 2 (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Krull (1983)" rsync -avhP "/mnt/synology/rs-movies/Krull (1983)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Minions The Rise of Gru (2022)" rsync -avhP "/mnt/unraid/media/Movies/Minions The Rise of Gru (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Man in My Basement (2025)" rsync -avhP "/mnt/synology/rs-movies/The Man in My Basement (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Code Name Banshee (2022)" rsync -avhP "/mnt/unraid/media/Movies/Code Name Banshee (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Strangers (2008)" rsync -avhP "/mnt/unraid/media/Movies/The Strangers (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Another Simple Favor (2025)" rsync -avhP "/mnt/unraid/media/Movies/Another Simple Favor (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Guardians of the Galaxy Vol. 3 (2023)" rsync -avhP "/mnt/unraid/media/Movies/Guardians of the Galaxy Vol. 3 (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Crimes of the Future (2022)" rsync -avhP "/mnt/unraid/media/Movies/Crimes of the Future (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Starsky and Hutch (2004)" rsync -avhP "/mnt/unraid/media/Movies/Starsky and Hutch (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: I Am A Halo-Halo (2024)" rsync -avhP "/mnt/synology/rs-movies/I Am A Halo-Halo (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Panama (2022)" rsync -avhP "/mnt/unraid/media/Movies/Panama (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Thing (1982)" rsync -avhP "/mnt/unraid/media/Movies/The Thing (1982)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Into the Forest (2016)" rsync -avhP "/mnt/unraid/media/Movies/Into the Forest (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dirty Dancing (1987)" rsync -avhP "/mnt/unraid/media/Movies/Dirty Dancing (1987)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Stan Lees Mighty 7 (2014)" rsync -avhP "/mnt/synology/rs-movies/Stan Lees Mighty 7 (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Big City Greens the Movie Spacecation (2024)" rsync -avhP "/mnt/synology/rs-movies/Big City Greens the Movie Spacecation (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Death and Return of Superman (2019)" rsync -avhP "/mnt/unraid/media/Movies/The Death and Return of Superman (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Emily the Criminal (2022)" rsync -avhP "/mnt/synology/rs-movies/Emily the Criminal (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Act of Killing (2012)" rsync -avhP "/mnt/synology/rs-movies/The Act of Killing (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Underworld (2003)" rsync -avhP "/mnt/unraid/media/Movies/Underworld (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The First Power (1990)" rsync -avhP "/mnt/unraid/media/Movies/The First Power (1990)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Maz Jobrani Immigrant (2017)" rsync -avhP "/mnt/unraid/media/Movies/Maz Jobrani Immigrant (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Kung Fury (2015)" rsync -avhP "/mnt/synology/rs-movies/Kung Fury (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Stuart Little (1999)" rsync -avhP "/mnt/unraid/media/Movies/Stuart Little (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Snatch (2000)" rsync -avhP "/mnt/unraid/media/Movies/Snatch (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Eighth Grade (2018)" rsync -avhP "/mnt/unraid/media/Movies/Eighth Grade (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: America The Motion Picture (2021)" rsync -avhP "/mnt/synology/rs-movies/America The Motion Picture (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Ref (1994)" rsync -avhP "/mnt/unraid/media/Movies/The Ref (1994)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Green and Gold (2025)" rsync -avhP "/mnt/synology/rs-movies/Green and Gold (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Rookie (2002)" rsync -avhP "/mnt/unraid/media/Movies/The Rookie (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Anthony Jeselnik Thoughts and Prayers (2015)" rsync -avhP "/mnt/unraid/media/Movies/Anthony Jeselnik Thoughts and Prayers (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dark Phoenix (2019)" rsync -avhP "/mnt/unraid/media/Movies/Dark Phoenix (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: DC League of Super-Pets (2022)" rsync -avhP "/mnt/unraid/media/Movies/DC League of Super-Pets (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Selma (2014)" rsync -avhP "/mnt/synology/rs-movies/Selma (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Last Man Down (2021)" rsync -avhP "/mnt/synology/rs-movies/Last Man Down (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Dogtooth (2009)" rsync -avhP "/mnt/unraid/media/Movies/Dogtooth (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Sugarplummed (2024)" rsync -avhP "/mnt/synology/rs-movies/Sugarplummed (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Indiana Jones and the Temple of Doom (1984)" rsync -avhP "/mnt/unraid/media/Movies/Indiana Jones and the Temple of Doom (1984)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Out of Sight (1998)" rsync -avhP "/mnt/unraid/media/Movies/Out of Sight (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: A Quiet Place (2018)" rsync -avhP "/mnt/unraid/media/Movies/A Quiet Place (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Godfrey Regular Black (2016)" rsync -avhP "/mnt/unraid/media/Movies/Godfrey Regular Black (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: When the Game Stands Tall (2014)" rsync -avhP "/mnt/synology/rs-movies/When the Game Stands Tall (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Pelican Brief (1993)" rsync -avhP "/mnt/unraid/media/Movies/The Pelican Brief (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The 7th Voyage of Sinbad (1958)" rsync -avhP "/mnt/synology/rs-movies/The 7th Voyage of Sinbad (1958)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Double (2014)" rsync -avhP "/mnt/synology/rs-movies/The Double (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Reservoir Dogs (1992)" rsync -avhP "/mnt/unraid/media/Movies/Reservoir Dogs (1992)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Butt Boy (2020)" rsync -avhP "/mnt/synology/rs-movies/Butt Boy (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Spiderwick Chronicles (2008)" rsync -avhP "/mnt/unraid/media/Movies/The Spiderwick Chronicles (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Critters 3 (1991)" rsync -avhP "/mnt/synology/rs-movies/Critters 3 (1991)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Meet the Fockers (2004)" rsync -avhP "/mnt/synology/rs-movies/Meet the Fockers (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Double Impact (1991)" rsync -avhP "/mnt/synology/rs-movies/Double Impact (1991)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Joe Rogan Talking Monkeys in Space (2009)" rsync -avhP "/mnt/synology/rs-movies/Joe Rogan Talking Monkeys in Space (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Angel Heart (1987)" rsync -avhP "/mnt/unraid/media/Movies/Angel Heart (1987)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Smurfs (2011)" rsync -avhP "/mnt/unraid/media/Movies/The Smurfs (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Omen (1976)" rsync -avhP "/mnt/synology/rs-movies/The Omen (1976)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: 13 Minutes (2015)" rsync -avhP "/mnt/synology/rs-movies/13 Minutes (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Barry Lyndon (1975)" rsync -avhP "/mnt/unraid/media/Movies/Barry Lyndon (1975)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Swordfish (2001)" rsync -avhP "/mnt/synology/rs-movies/Swordfish (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Road to El Dorado (2000)" rsync -avhP "/mnt/synology/rs-movies/The Road to El Dorado (2000)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Clerks III (2022)" rsync -avhP "/mnt/unraid/media/Movies/Clerks III (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Hatchet II (2010)" rsync -avhP "/mnt/unraid/media/Movies/Hatchet II (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Escape Plan 2 Hades (2018)" rsync -avhP "/mnt/unraid/media/Movies/Escape Plan 2 Hades (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Wolf Man (2025)" rsync -avhP "/mnt/unraid/media/Movies/Wolf Man (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Sideways (2004)" rsync -avhP "/mnt/synology/rs-movies/Sideways (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Book of Clarence (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Book of Clarence (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Apocalypse Now (1979)" rsync -avhP "/mnt/unraid/media/Movies/Apocalypse Now (1979)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: A Babysitters Guide to Monster Hunting (2020)" rsync -avhP "/mnt/synology/rs-movies/A Babysitters Guide to Monster Hunting (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Hellraiser Hellseeker (2002)" rsync -avhP "/mnt/synology/rs-movies/Hellraiser Hellseeker (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Grudge 2 (2006)" rsync -avhP "/mnt/unraid/media/Movies/The Grudge 2 (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Iron Sky (2012)" rsync -avhP "/mnt/unraid/media/Movies/Iron Sky (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Octopus with Broken Arms (2024)" rsync -avhP "/mnt/unraid/media/Movies/Octopus with Broken Arms (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Tom Papa What a Day! (2022)" rsync -avhP "/mnt/synology/rs-movies/Tom Papa What a Day! (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Saturday Night (2024)" rsync -avhP "/mnt/unraid/media/Movies/Saturday Night (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Die Hard 2 (1990)" rsync -avhP "/mnt/unraid/media/Movies/Die Hard 2 (1990)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Valentines Day (2010)" rsync -avhP "/mnt/synology/rs-movies/Valentines Day (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: DodgeBall A True Underdog Story (2004)" rsync -avhP "/mnt/unraid/media/Movies/DodgeBall A True Underdog Story (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Eternal Daughter (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Eternal Daughter (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: E.T. the Extra-Terrestrial (1982)" rsync -avhP "/mnt/synology/rs-movies/E.T. the Extra-Terrestrial (1982)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Day Watch (2006)" rsync -avhP "/mnt/synology/rs-movies/Day Watch (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Southland Tales (2007)" rsync -avhP "/mnt/unraid/media/Movies/Southland Tales (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dave Chappelle Deep in the Heart of Texas (2017)" rsync -avhP "/mnt/unraid/media/Movies/Dave Chappelle Deep in the Heart of Texas (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Father Father (2019)" rsync -avhP "/mnt/synology/rs-movies/Father Father (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Green Room (2016)" rsync -avhP "/mnt/unraid/media/Movies/Green Room (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Paperboy (2012)" rsync -avhP "/mnt/unraid/media/Movies/The Paperboy (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Redwood Massacre Annihilation (2020)" rsync -avhP "/mnt/synology/rs-movies/Redwood Massacre Annihilation (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Foot Fist Way (2006)" rsync -avhP "/mnt/synology/rs-movies/The Foot Fist Way (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Last Kumite (2024)" rsync -avhP "/mnt/synology/rs-movies/The Last Kumite (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Virgin Territory (2007)" rsync -avhP "/mnt/synology/rs-movies/Virgin Territory (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Backstabbing for Beginners (2018)" rsync -avhP "/mnt/unraid/media/Movies/Backstabbing for Beginners (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Beowulf and Grendel (2005)" rsync -avhP "/mnt/synology/rs-movies/Beowulf and Grendel (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Deck the Walls (2024)" rsync -avhP "/mnt/synology/rs-movies/Deck the Walls (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Taxi Driver (1976)" rsync -avhP "/mnt/unraid/media/Movies/Taxi Driver (1976)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Malena (2000)" rsync -avhP "/mnt/unraid/media/Movies/Malena (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Predator Killer of Killers (2025)" rsync -avhP "/mnt/synology/rs-movies/Predator Killer of Killers (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Kickboxer (1989)" rsync -avhP "/mnt/synology/rs-movies/Kickboxer (1989)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Class Act (1992)" rsync -avhP "/mnt/synology/rs-movies/Class Act (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Dark Knight Rises (2012)" rsync -avhP "/mnt/synology/rs-movies/The Dark Knight Rises (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Architecton (2024)" rsync -avhP "/mnt/unraid/media/Movies/Architecton (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hombre (1967)" rsync -avhP "/mnt/synology/rs-movies/Hombre (1967)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: American Pie Presents Band Camp (2005)" rsync -avhP "/mnt/unraid/media/Movies/American Pie Presents Band Camp (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Lizzie McGuire Movie (2003)" rsync -avhP "/mnt/synology/rs-movies/The Lizzie McGuire Movie (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Avatar The Way of Water (2022)" rsync -avhP "/mnt/unraid/media/Movies/Avatar The Way of Water (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Men Who Stare at Goats (2009)" rsync -avhP "/mnt/synology/rs-movies/The Men Who Stare at Goats (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Showtime (2002)" rsync -avhP "/mnt/synology/rs-movies/Showtime (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: MoviePass MovieCrash (2024)" rsync -avhP "/mnt/unraid/media/Movies/MoviePass MovieCrash (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Sneakers (1992)" rsync -avhP "/mnt/synology/rs-movies/Sneakers (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Second Act (2018)" rsync -avhP "/mnt/unraid/media/Movies/Second Act (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: White Water Summer (1987)" rsync -avhP "/mnt/synology/rs-movies/White Water Summer (1987)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Hamilton (2025)" rsync -avhP "/mnt/synology/rs-movies/Hamilton (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Flash (2022)" rsync -avhP "/mnt/synology/rs-movies/The Flash (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Stone Cold (1991)" rsync -avhP "/mnt/unraid/media/Movies/Stone Cold (1991)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Doom Annihilation (2019)" rsync -avhP "/mnt/synology/rs-movies/Doom Annihilation (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Princess (2022)" rsync -avhP "/mnt/synology/rs-movies/Princess (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Downton Abbey The Grand Finale (2025)" rsync -avhP "/mnt/unraid/media/Movies/Downton Abbey The Grand Finale (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Kings Choice (2016)" rsync -avhP "/mnt/synology/rs-movies/The Kings Choice (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Stowaway (2021)" rsync -avhP "/mnt/unraid/media/Movies/Stowaway (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Andrew Schulz Infamous (2022)" rsync -avhP "/mnt/unraid/media/Movies/Andrew Schulz Infamous (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Natty Knocks (2023)" rsync -avhP "/mnt/synology/rs-movies/Natty Knocks (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Rudy (1993)" rsync -avhP "/mnt/synology/rs-movies/Rudy (1993)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: One Shot (2021)" rsync -avhP "/mnt/unraid/media/Movies/One Shot (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Ultimate Avengers The Movie (2006)" rsync -avhP "/mnt/synology/rs-movies/Ultimate Avengers The Movie (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Killer Joe (2012)" rsync -avhP "/mnt/synology/rs-movies/Killer Joe (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Day (2011)" rsync -avhP "/mnt/synology/rs-movies/The Day (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Once Upon a Snowman (2020)" rsync -avhP "/mnt/unraid/media/Movies/Once Upon a Snowman (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Boogeyman (2005)" rsync -avhP "/mnt/unraid/media/Movies/Boogeyman (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Street Kings (2008)" rsync -avhP "/mnt/unraid/media/Movies/Street Kings (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Occupied City (2023)" rsync -avhP "/mnt/unraid/media/Movies/Occupied City (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Billie (2020)" rsync -avhP "/mnt/synology/rs-movies/Billie (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Cosmic Sin (2021)" rsync -avhP "/mnt/synology/rs-movies/Cosmic Sin (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Sorority Babes in the Slimeball Bowl-O-Rama 2 (2022)" rsync -avhP "/mnt/unraid/media/Movies/Sorority Babes in the Slimeball Bowl-O-Rama 2 (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Hamlet (1990)" rsync -avhP "/mnt/unraid/media/Movies/Hamlet (1990)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: A Monster Calls (2016)" rsync -avhP "/mnt/synology/rs-movies/A Monster Calls (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Drag Me to Hell (2009)" rsync -avhP "/mnt/synology/rs-movies/Drag Me to Hell (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Boogeyman (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Boogeyman (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hansan Rising Dragon (2022)" rsync -avhP "/mnt/synology/rs-movies/Hansan Rising Dragon (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Hard Candy (2005)" rsync -avhP "/mnt/synology/rs-movies/Hard Candy (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Out of Death (2021)" rsync -avhP "/mnt/unraid/media/Movies/Out of Death (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: I Now Pronounce You Chuck and Larry (2007)" rsync -avhP "/mnt/synology/rs-movies/I Now Pronounce You Chuck and Larry (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Clash of the Titans (2010)" rsync -avhP "/mnt/unraid/media/Movies/Clash of the Titans (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Mitchells vs. the Machines (2021)" rsync -avhP "/mnt/unraid/media/Movies/The Mitchells vs. the Machines (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Mr. Holmes (2015)" rsync -avhP "/mnt/unraid/media/Movies/Mr. Holmes (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Monkey (2025)" rsync -avhP "/mnt/unraid/media/Movies/The Monkey (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Nun II (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Nun II (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Humanist Vampire Seeking Consenting Suicidal Person (2023)" rsync -avhP "/mnt/unraid/media/Movies/Humanist Vampire Seeking Consenting Suicidal Person (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: 10 Lives (2024)" rsync -avhP "/mnt/synology/rs-movies/10 Lives (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Shadow Force (2025)" rsync -avhP "/mnt/unraid/media/Movies/Shadow Force (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Daddy Day Care (2003)" rsync -avhP "/mnt/synology/rs-movies/Daddy Day Care (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Once Upon a Time in Mexico (2003)" rsync -avhP "/mnt/unraid/media/Movies/Once Upon a Time in Mexico (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Bad Boys (1995)" rsync -avhP "/mnt/unraid/media/Movies/Bad Boys (1995)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Antisocial Network Memes to Mayhem (2024)" rsync -avhP "/mnt/synology/rs-movies/The Antisocial Network Memes to Mayhem (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Callback Queen (2013)" rsync -avhP "/mnt/unraid/media/Movies/The Callback Queen (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Frighteners (1996)" rsync -avhP "/mnt/synology/rs-movies/The Frighteners (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Transylvania 6-5000 (1985)" rsync -avhP "/mnt/synology/rs-movies/Transylvania 6-5000 (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Closer (2004)" rsync -avhP "/mnt/synology/rs-movies/Closer (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Hope and Glory (1987)" rsync -avhP "/mnt/unraid/media/Movies/Hope and Glory (1987)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Vivarium (2019)" rsync -avhP "/mnt/unraid/media/Movies/Vivarium (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Teenage Mutant Ninja Turtles (1990)" rsync -avhP "/mnt/unraid/media/Movies/Teenage Mutant Ninja Turtles (1990)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Shakespeare in Love (1998)" rsync -avhP "/mnt/synology/rs-movies/Shakespeare in Love (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Sitter (2011)" rsync -avhP "/mnt/synology/rs-movies/The Sitter (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Blade Runner (1982)" rsync -avhP "/mnt/unraid/media/Movies/Blade Runner (1982)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Exterritorial (2025)" rsync -avhP "/mnt/unraid/media/Movies/Exterritorial (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Macbeth (2015)" rsync -avhP "/mnt/unraid/media/Movies/Macbeth (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Father (2020)" rsync -avhP "/mnt/unraid/media/Movies/The Father (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The 40 Year Old Virgin (2005)" rsync -avhP "/mnt/unraid/media/Movies/The 40 Year Old Virgin (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Meatballs (1979)" rsync -avhP "/mnt/synology/rs-movies/Meatballs (1979)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Crank High Voltage (2009)" rsync -avhP "/mnt/unraid/media/Movies/Crank High Voltage (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Angels in the Outfield (1994)" rsync -avhP "/mnt/unraid/media/Movies/Angels in the Outfield (1994)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Nobitas the Night Before a Wedding (1999)" rsync -avhP "/mnt/synology/rs-movies/Nobitas the Night Before a Wedding (1999)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Lonely Planet (2024)" rsync -avhP "/mnt/unraid/media/Movies/Lonely Planet (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Side Effects (2013)" rsync -avhP "/mnt/unraid/media/Movies/Side Effects (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Boy Who Could Fly (1986)" rsync -avhP "/mnt/synology/rs-movies/The Boy Who Could Fly (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Takeover (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Takeover (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Unstoppable (2010)" rsync -avhP "/mnt/unraid/media/Movies/Unstoppable (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Masters of the Universe (1987)" rsync -avhP "/mnt/synology/rs-movies/Masters of the Universe (1987)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Queenpins (2021)" rsync -avhP "/mnt/unraid/media/Movies/Queenpins (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Never Goin Back (2018)" rsync -avhP "/mnt/unraid/media/Movies/Never Goin Back (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Shelter (2014)" rsync -avhP "/mnt/unraid/media/Movies/Shelter (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Hunt (2020)" rsync -avhP "/mnt/unraid/media/Movies/The Hunt (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hellbender (2021)" rsync -avhP "/mnt/synology/rs-movies/Hellbender (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Departed (2006)" rsync -avhP "/mnt/unraid/media/Movies/The Departed (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Up the Creek (1984)" rsync -avhP "/mnt/synology/rs-movies/Up the Creek (1984)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Army of Thieves (2021)" rsync -avhP "/mnt/unraid/media/Movies/Army of Thieves (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Red Sonja (1985)" rsync -avhP "/mnt/unraid/media/Movies/Red Sonja (1985)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Room (2003)" rsync -avhP "/mnt/unraid/media/Movies/The Room (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Night Before (1988)" rsync -avhP "/mnt/synology/rs-movies/The Night Before (1988)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Mother (2023)" rsync -avhP "/mnt/synology/rs-movies/Mother (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Ip Man (2008)" rsync -avhP "/mnt/unraid/media/Movies/Ip Man (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Nun (2018)" rsync -avhP "/mnt/unraid/media/Movies/The Nun (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Paddington in Peru (2024)" rsync -avhP "/mnt/unraid/media/Movies/Paddington in Peru (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: What Is a Woman (2022)" rsync -avhP "/mnt/synology/rs-movies/What Is a Woman (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Day the Earth Stood Still (2008)" rsync -avhP "/mnt/unraid/media/Movies/The Day the Earth Stood Still (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Gamer (2009)" rsync -avhP "/mnt/synology/rs-movies/Gamer (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Wonder Woman (2017)" rsync -avhP "/mnt/unraid/media/Movies/Wonder Woman (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Cemetery Man (1994)" rsync -avhP "/mnt/unraid/media/Movies/Cemetery Man (1994)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Hunger Games Mockingjay Part 1 (2014)" rsync -avhP "/mnt/unraid/media/Movies/The Hunger Games Mockingjay Part 1 (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Interstate 60 (2002)" rsync -avhP "/mnt/synology/rs-movies/Interstate 60 (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Beastmaster (1982)" rsync -avhP "/mnt/unraid/media/Movies/The Beastmaster (1982)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Inside (2023)" rsync -avhP "/mnt/unraid/media/Movies/Inside (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Daytrippers (1997)" rsync -avhP "/mnt/synology/rs-movies/The Daytrippers (1997)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The War with Grandpa (2020)" rsync -avhP "/mnt/synology/rs-movies/The War with Grandpa (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Stakeout (1987)" rsync -avhP "/mnt/unraid/media/Movies/Stakeout (1987)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Predator (1987)" rsync -avhP "/mnt/synology/rs-movies/Predator (1987)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Crazy Rich Asians (2018)" rsync -avhP "/mnt/unraid/media/Movies/Crazy Rich Asians (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Rugrats Go Wild (2003)" rsync -avhP "/mnt/synology/rs-movies/Rugrats Go Wild (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Trainwreck (2015)" rsync -avhP "/mnt/synology/rs-movies/Trainwreck (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Resident Evil Death Island (2023)" rsync -avhP "/mnt/unraid/media/Movies/Resident Evil Death Island (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Men in Black International (2019)" rsync -avhP "/mnt/unraid/media/Movies/Men in Black International (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Life of David Gale (2003)" rsync -avhP "/mnt/unraid/media/Movies/The Life of David Gale (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Howl (2015)" rsync -avhP "/mnt/synology/rs-movies/Howl (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Hulk (2003)" rsync -avhP "/mnt/synology/rs-movies/Hulk (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Disclosure (1994)" rsync -avhP "/mnt/synology/rs-movies/Disclosure (1994)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Mission Impossible The Final Reckoning (2025)" rsync -avhP "/mnt/unraid/media/Movies/Mission Impossible The Final Reckoning (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: 1992 (2024)" rsync -avhP "/mnt/unraid/media/Movies/1992 (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Assassin (2023)" rsync -avhP "/mnt/unraid/media/Movies/Assassin (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Family for Christmas (2015)" rsync -avhP "/mnt/synology/rs-movies/Family for Christmas (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Hustlers (2019)" rsync -avhP "/mnt/unraid/media/Movies/Hustlers (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The K.E.O.P S System (2022)" rsync -avhP "/mnt/synology/rs-movies/The K.E.O.P S System (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Road Trip Beer Pong (2009)" rsync -avhP "/mnt/synology/rs-movies/Road Trip Beer Pong (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: A Cinderella Story Once Upon a Song (2011)" rsync -avhP "/mnt/synology/rs-movies/A Cinderella Story Once Upon a Song (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: We Were Soldiers (2002)" rsync -avhP "/mnt/unraid/media/Movies/We Were Soldiers (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Waitress The Musical (2023)" rsync -avhP "/mnt/synology/rs-movies/Waitress The Musical (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Grimcutty (2022)" rsync -avhP "/mnt/synology/rs-movies/Grimcutty (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Goosebumps 2 Haunted Halloween (2018)" rsync -avhP "/mnt/unraid/media/Movies/Goosebumps 2 Haunted Halloween (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Creator (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Creator (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: South Park Post COVID The Return of COVID (2021)" rsync -avhP "/mnt/unraid/media/Movies/South Park Post COVID The Return of COVID (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: X (2022)" rsync -avhP "/mnt/unraid/media/Movies/X (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dredd (2012)" rsync -avhP "/mnt/unraid/media/Movies/Dredd (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Outsider (1983)" rsync -avhP "/mnt/synology/rs-movies/The Outsider (1983)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Lake House (2006)" rsync -avhP "/mnt/synology/rs-movies/The Lake House (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Freaky (2020)" rsync -avhP "/mnt/unraid/media/Movies/Freaky (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: An Inconvenient Truth (2006)" rsync -avhP "/mnt/unraid/media/Movies/An Inconvenient Truth (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: La La Land (2016)" rsync -avhP "/mnt/unraid/media/Movies/La La Land (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Take Cover (2024)" rsync -avhP "/mnt/unraid/media/Movies/Take Cover (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Joyeux Noel (2005)" rsync -avhP "/mnt/synology/rs-movies/Joyeux Noel (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Batman (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Batman (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Rio 2 (2014)" rsync -avhP "/mnt/unraid/media/Movies/Rio 2 (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Runaway Jury (2003)" rsync -avhP "/mnt/unraid/media/Movies/Runaway Jury (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: K-PAX (2001)" rsync -avhP "/mnt/unraid/media/Movies/K-PAX (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Hallow (2015)" rsync -avhP "/mnt/synology/rs-movies/The Hallow (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Amityville The Awakening (2017)" rsync -avhP "/mnt/unraid/media/Movies/Amityville The Awakening (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Mr. Destiny (1990)" rsync -avhP "/mnt/unraid/media/Movies/Mr. Destiny (1990)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Addiction (1995)" rsync -avhP "/mnt/synology/rs-movies/The Addiction (1995)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Escape Room Tournament of Champions (2021)" rsync -avhP "/mnt/unraid/media/Movies/Escape Room Tournament of Champions (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Casa de Mi Padre (2012)" rsync -avhP "/mnt/synology/rs-movies/Casa de Mi Padre (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Wind River (2017)" rsync -avhP "/mnt/unraid/media/Movies/Wind River (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: 18 Again! (1988)" rsync -avhP "/mnt/synology/rs-movies/18 Again! (1988)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Saint (1997)" rsync -avhP "/mnt/synology/rs-movies/Saint (1997)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Leopard Head Lin Chong 1 The White Tiger Hall (2019)" rsync -avhP "/mnt/synology/rs-movies/Leopard Head Lin Chong 1 The White Tiger Hall (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Brave Little Toaster (1987)" rsync -avhP "/mnt/synology/rs-movies/The Brave Little Toaster (1987)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Mike and Dave Need Wedding Dates (2016)" rsync -avhP "/mnt/unraid/media/Movies/Mike and Dave Need Wedding Dates (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Airplane II The Sequel (1982)" rsync -avhP "/mnt/unraid/media/Movies/Airplane II The Sequel (1982)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Poughkeepsie Tapes (2007)" rsync -avhP "/mnt/synology/rs-movies/The Poughkeepsie Tapes (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Trigger Point (2021)" rsync -avhP "/mnt/unraid/media/Movies/Trigger Point (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Borderlands (2024)" rsync -avhP "/mnt/unraid/media/Movies/Borderlands (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Trainwreck Balloon Boy (2025)" rsync -avhP "/mnt/unraid/media/Movies/Trainwreck Balloon Boy (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Jailhouse Rock (1957)" rsync -avhP "/mnt/synology/rs-movies/Jailhouse Rock (1957)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Vampires vs. the Bronx (2020)" rsync -avhP "/mnt/synology/rs-movies/Vampires vs. the Bronx (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Australia Land Beyond Time (2002)" rsync -avhP "/mnt/synology/rs-movies/Australia Land Beyond Time (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Fist Fight (2017)" rsync -avhP "/mnt/synology/rs-movies/Fist Fight (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Annabelle (2014)" rsync -avhP "/mnt/unraid/media/Movies/Annabelle (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Monster (2016)" rsync -avhP "/mnt/unraid/media/Movies/The Monster (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dog Man (2025)" rsync -avhP "/mnt/unraid/media/Movies/Dog Man (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Days of Thunder (1990)" rsync -avhP "/mnt/unraid/media/Movies/Days of Thunder (1990)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Flight of the Phoenix (2004)" rsync -avhP "/mnt/synology/rs-movies/Flight of the Phoenix (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Bill and Teds Excellent Adventure (1989)" rsync -avhP "/mnt/synology/rs-movies/Bill and Teds Excellent Adventure (1989)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Whip It (2009)" rsync -avhP "/mnt/synology/rs-movies/Whip It (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Lumina (2024)" rsync -avhP "/mnt/synology/rs-movies/Lumina (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Baby Driver (2017)" rsync -avhP "/mnt/unraid/media/Movies/Baby Driver (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Edge of Seventeen (2016)" rsync -avhP "/mnt/synology/rs-movies/The Edge of Seventeen (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Little Women (2019)" rsync -avhP "/mnt/unraid/media/Movies/Little Women (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Serena (2014)" rsync -avhP "/mnt/synology/rs-movies/Serena (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Lamb of God (2020)" rsync -avhP "/mnt/synology/rs-movies/Lamb of God (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Tailor of Panama (2001)" rsync -avhP "/mnt/unraid/media/Movies/The Tailor of Panama (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Midnight in the Garden of Good and Evil (1997)" rsync -avhP "/mnt/synology/rs-movies/Midnight in the Garden of Good and Evil (1997)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Dont Look Now (1973)" rsync -avhP "/mnt/synology/rs-movies/Dont Look Now (1973)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Riotsville USA (2022)" rsync -avhP "/mnt/unraid/media/Movies/Riotsville USA (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: A Christmas Story (2022)" rsync -avhP "/mnt/synology/rs-movies/A Christmas Story (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: DC Showcase Blue Beetle (2021)" rsync -avhP "/mnt/synology/rs-movies/DC Showcase Blue Beetle (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Green Berets (1968)" rsync -avhP "/mnt/synology/rs-movies/The Green Berets (1968)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: After the Sunset (2004)" rsync -avhP "/mnt/synology/rs-movies/After the Sunset (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Iron Claw (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Iron Claw (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Home Alone The Holiday Heist (2012)" rsync -avhP "/mnt/synology/rs-movies/Home Alone The Holiday Heist (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Dead Like Me Life After Death (2009)" rsync -avhP "/mnt/synology/rs-movies/Dead Like Me Life After Death (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Igor (2008)" rsync -avhP "/mnt/synology/rs-movies/Igor (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Breadwinner (2017)" rsync -avhP "/mnt/synology/rs-movies/The Breadwinner (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Awake (2021)" rsync -avhP "/mnt/unraid/media/Movies/Awake (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Scorpion King (2002)" rsync -avhP "/mnt/unraid/media/Movies/The Scorpion King (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Sex and the City 2 (2010)" rsync -avhP "/mnt/synology/rs-movies/Sex and the City 2 (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Bobs Burgers Movie (2022)" rsync -avhP "/mnt/synology/rs-movies/The Bobs Burgers Movie (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Pink Floyd The Wall (1982)" rsync -avhP "/mnt/synology/rs-movies/Pink Floyd The Wall (1982)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Doc Hollywood (1991)" rsync -avhP "/mnt/synology/rs-movies/Doc Hollywood (1991)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Frida (2002)" rsync -avhP "/mnt/unraid/media/Movies/Frida (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Copycat (2016)" rsync -avhP "/mnt/synology/rs-movies/Copycat (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Witness (1985)" rsync -avhP "/mnt/unraid/media/Movies/Witness (1985)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Detective Dee The Four Heavenly Kings (2018)" rsync -avhP "/mnt/synology/rs-movies/Detective Dee The Four Heavenly Kings (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Furious 7 (2015)" rsync -avhP "/mnt/unraid/media/Movies/Furious 7 (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Bone Collector (1999)" rsync -avhP "/mnt/unraid/media/Movies/The Bone Collector (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Jonah Hex (2010)" rsync -avhP "/mnt/synology/rs-movies/Jonah Hex (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Foul Play (1978)" rsync -avhP "/mnt/synology/rs-movies/Foul Play (1978)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Wretched (2019)" rsync -avhP "/mnt/synology/rs-movies/The Wretched (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Journey 2 The Mysterious Island (2012)" rsync -avhP "/mnt/unraid/media/Movies/Journey 2 The Mysterious Island (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hollow Man (2000)" rsync -avhP "/mnt/synology/rs-movies/Hollow Man (2000)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Elvis (2022)" rsync -avhP "/mnt/unraid/media/Movies/Elvis (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Woman in Gold (2015)" rsync -avhP "/mnt/unraid/media/Movies/Woman in Gold (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Spirit Untamed (2021)" rsync -avhP "/mnt/unraid/media/Movies/Spirit Untamed (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Oz the Great and Powerful (2013)" rsync -avhP "/mnt/unraid/media/Movies/Oz the Great and Powerful (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dragon The Bruce Lee Story (1993)" rsync -avhP "/mnt/unraid/media/Movies/Dragon The Bruce Lee Story (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Bad Education (2019)" rsync -avhP "/mnt/unraid/media/Movies/Bad Education (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Masterminds (2016)" rsync -avhP "/mnt/synology/rs-movies/Masterminds (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Manchurian Candidate (2004)" rsync -avhP "/mnt/synology/rs-movies/The Manchurian Candidate (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Munich – The Edge of War (2021)" rsync -avhP "/mnt/unraid/media/Movies/Munich – The Edge of War (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Asteroid City (2023)" rsync -avhP "/mnt/unraid/media/Movies/Asteroid City (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Unforgiven (1992)" rsync -avhP "/mnt/unraid/media/Movies/Unforgiven (1992)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Heads of State (2025)" rsync -avhP "/mnt/unraid/media/Movies/Heads of State (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Snowman (2017)" rsync -avhP "/mnt/unraid/media/Movies/The Snowman (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Gone Baby Gone (2007)" rsync -avhP "/mnt/unraid/media/Movies/Gone Baby Gone (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Please Dont Destroy The Treasure of Foggy Mountain (2023)" rsync -avhP "/mnt/unraid/media/Movies/Please Dont Destroy The Treasure of Foggy Mountain (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: An American Haunting (2005)" rsync -avhP "/mnt/synology/rs-movies/An American Haunting (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Night Before (2015)" rsync -avhP "/mnt/unraid/media/Movies/The Night Before (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Good Boys (2019)" rsync -avhP "/mnt/synology/rs-movies/Good Boys (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: School of Rock (2003)" rsync -avhP "/mnt/unraid/media/Movies/School of Rock (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Hero (2017)" rsync -avhP "/mnt/unraid/media/Movies/The Hero (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Making of 'Crimson Tide (1995)" rsync -avhP "/mnt/synology/rs-movies/The Making of 'Crimson Tide (1995)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Bricklayer (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Bricklayer (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Starman (1984)" rsync -avhP "/mnt/unraid/media/Movies/Starman (1984)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Painted Bird (2019)" rsync -avhP "/mnt/unraid/media/Movies/The Painted Bird (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Caddyshack II (1988)" rsync -avhP "/mnt/synology/rs-movies/Caddyshack II (1988)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Taken 3 (2014)" rsync -avhP "/mnt/unraid/media/Movies/Taken 3 (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Tetsuo The Iron Man (1989)" rsync -avhP "/mnt/synology/rs-movies/Tetsuo The Iron Man (1989)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Thaw (2009)" rsync -avhP "/mnt/synology/rs-movies/The Thaw (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Midway (1976)" rsync -avhP "/mnt/synology/rs-movies/Midway (1976)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Eight Legged Freaks (2002)" rsync -avhP "/mnt/synology/rs-movies/Eight Legged Freaks (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Woman in the Window (2021)" rsync -avhP "/mnt/unraid/media/Movies/The Woman in the Window (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Intern (2015)" rsync -avhP "/mnt/unraid/media/Movies/The Intern (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Sister Death (2023)" rsync -avhP "/mnt/unraid/media/Movies/Sister Death (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Definitely Maybe (2008)" rsync -avhP "/mnt/unraid/media/Movies/Definitely Maybe (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: El Camino A Breaking Bad Movie (2019)" rsync -avhP "/mnt/unraid/media/Movies/El Camino A Breaking Bad Movie (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Pig the Snake and the Pigeon (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Pig the Snake and the Pigeon (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Felon (2008)" rsync -avhP "/mnt/synology/rs-movies/Felon (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Skyline (2010)" rsync -avhP "/mnt/synology/rs-movies/Skyline (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Fall Guy (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Fall Guy (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Table 19 (2017)" rsync -avhP "/mnt/synology/rs-movies/Table 19 (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: All of Us Strangers (2023)" rsync -avhP "/mnt/unraid/media/Movies/All of Us Strangers (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: O Brother Where Art Thou (2000)" rsync -avhP "/mnt/unraid/media/Movies/O Brother Where Art Thou (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Art of War (2000)" rsync -avhP "/mnt/synology/rs-movies/The Art of War (2000)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Once Upon a Time in the West (1968)" rsync -avhP "/mnt/unraid/media/Movies/Once Upon a Time in the West (1968)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Grind (2003)" rsync -avhP "/mnt/unraid/media/Movies/Grind (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Firefox (1982)" rsync -avhP "/mnt/synology/rs-movies/Firefox (1982)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Kill Bill Vol. 2 (2004)" rsync -avhP "/mnt/unraid/media/Movies/Kill Bill Vol. 2 (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Halloween Kills (2021)" rsync -avhP "/mnt/unraid/media/Movies/Halloween Kills (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Corrective Measures (2022)" rsync -avhP "/mnt/synology/rs-movies/Corrective Measures (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Game Over Man! (2018)" rsync -avhP "/mnt/unraid/media/Movies/Game Over Man! (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Christmas Is Canceled (2021)" rsync -avhP "/mnt/unraid/media/Movies/Christmas Is Canceled (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Takeover (2022)" rsync -avhP "/mnt/synology/rs-movies/The Takeover (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Avengers Age of Ultron (2015)" rsync -avhP "/mnt/unraid/media/Movies/Avengers Age of Ultron (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dances with Wolves (1990)" rsync -avhP "/mnt/synology/rs-movies/Dances with Wolves (1990)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Dark Kingdom (2018)" rsync -avhP "/mnt/unraid/media/Movies/The Dark Kingdom (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Next Goal Wins (2023)" rsync -avhP "/mnt/unraid/media/Movies/Next Goal Wins (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Annette (2021)" rsync -avhP "/mnt/unraid/media/Movies/Annette (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Into the Blue 2 The Reef (2009)" rsync -avhP "/mnt/synology/rs-movies/Into the Blue 2 The Reef (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: They Cloned Tyrone (2023)" rsync -avhP "/mnt/unraid/media/Movies/They Cloned Tyrone (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Revelations (2025)" rsync -avhP "/mnt/unraid/media/Movies/Revelations (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Charlie and the Chocolate Factory (2005)" rsync -avhP "/mnt/synology/rs-movies/Charlie and the Chocolate Factory (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Last Night in Soho (2021)" rsync -avhP "/mnt/unraid/media/Movies/Last Night in Soho (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Strangers Chapter 2 (2025)" rsync -avhP "/mnt/synology/rs-movies/The Strangers Chapter 2 (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: No Sudden Move (2021)" rsync -avhP "/mnt/unraid/media/Movies/No Sudden Move (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Munich (2005)" rsync -avhP "/mnt/unraid/media/Movies/Munich (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Mea Culpa (2024)" rsync -avhP "/mnt/unraid/media/Movies/Mea Culpa (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dont Look Back (2009)" rsync -avhP "/mnt/synology/rs-movies/Dont Look Back (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Man of the House (2005)" rsync -avhP "/mnt/synology/rs-movies/Man of the House (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Crazies (2010)" rsync -avhP "/mnt/unraid/media/Movies/The Crazies (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Vampires Kiss (1989)" rsync -avhP "/mnt/synology/rs-movies/Vampires Kiss (1989)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Coming Home for Christmas (2017)" rsync -avhP "/mnt/synology/rs-movies/Coming Home for Christmas (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Sinister (2012)" rsync -avhP "/mnt/synology/rs-movies/Sinister (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Fortress (2021)" rsync -avhP "/mnt/unraid/media/Movies/Fortress (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Monster House (2006)" rsync -avhP "/mnt/synology/rs-movies/Monster House (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Hotel Transylvania (2012)" rsync -avhP "/mnt/unraid/media/Movies/Hotel Transylvania (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Extraction (2020)" rsync -avhP "/mnt/unraid/media/Movies/Extraction (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Good Neighbor (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Good Neighbor (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Private Princess Christmas (2024)" rsync -avhP "/mnt/synology/rs-movies/Private Princess Christmas (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Life in a Day (2011)" rsync -avhP "/mnt/unraid/media/Movies/Life in a Day (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Stars and Stripes Forever (1952)" rsync -avhP "/mnt/synology/rs-movies/Stars and Stripes Forever (1952)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Joes Apartment (1996)" rsync -avhP "/mnt/synology/rs-movies/Joes Apartment (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Scrooged (1988)" rsync -avhP "/mnt/unraid/media/Movies/Scrooged (1988)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Toy Soldiers (1991)" rsync -avhP "/mnt/synology/rs-movies/Toy Soldiers (1991)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Annie (2014)" rsync -avhP "/mnt/synology/rs-movies/Annie (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: McVeigh (2024)" rsync -avhP "/mnt/synology/rs-movies/McVeigh (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Corpse Bride (2005)" rsync -avhP "/mnt/unraid/media/Movies/Corpse Bride (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Red Riding Hood (2011)" rsync -avhP "/mnt/synology/rs-movies/Red Riding Hood (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Valkyrie (2008)" rsync -avhP "/mnt/unraid/media/Movies/Valkyrie (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Becky (2020)" rsync -avhP "/mnt/synology/rs-movies/Becky (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Bad Guys 2 (2025)" rsync -avhP "/mnt/unraid/media/Movies/The Bad Guys 2 (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Run Hide Fight (2021)" rsync -avhP "/mnt/unraid/media/Movies/Run Hide Fight (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Perks of Being a Wallflower (2012)" rsync -avhP "/mnt/synology/rs-movies/The Perks of Being a Wallflower (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Pathaan (2023)" rsync -avhP "/mnt/synology/rs-movies/Pathaan (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: I Am Mother (2019)" rsync -avhP "/mnt/unraid/media/Movies/I Am Mother (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Runaway Bride (1999)" rsync -avhP "/mnt/unraid/media/Movies/Runaway Bride (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Silent Running (1972)" rsync -avhP "/mnt/synology/rs-movies/Silent Running (1972)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Back to the Future Part II (1989)" rsync -avhP "/mnt/unraid/media/Movies/Back to the Future Part II (1989)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: DuckTales The Movie Treasure of the Lost Lamp (1990)" rsync -avhP "/mnt/unraid/media/Movies/DuckTales The Movie Treasure of the Lost Lamp (1990)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: 365 Days This Day (2022)" rsync -avhP "/mnt/synology/rs-movies/365 Days This Day (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Moonfall (2022)" rsync -avhP "/mnt/unraid/media/Movies/Moonfall (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Shattered (2022)" rsync -avhP "/mnt/synology/rs-movies/Shattered (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Ghost Ship (2002)" rsync -avhP "/mnt/synology/rs-movies/Ghost Ship (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: To the Wonder (2013)" rsync -avhP "/mnt/synology/rs-movies/To the Wonder (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Willow (1988)" rsync -avhP "/mnt/unraid/media/Movies/Willow (1988)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Real McCoy (1993)" rsync -avhP "/mnt/synology/rs-movies/The Real McCoy (1993)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Bob Lazar Area 51 and Flying Saucers (2018)" rsync -avhP "/mnt/unraid/media/Movies/Bob Lazar Area 51 and Flying Saucers (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Ironweed (1987)" rsync -avhP "/mnt/synology/rs-movies/Ironweed (1987)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Babygirl (2024)" rsync -avhP "/mnt/unraid/media/Movies/Babygirl (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Manhunter (1986)" rsync -avhP "/mnt/synology/rs-movies/Manhunter (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Never Say Never Again (1983)" rsync -avhP "/mnt/unraid/media/Movies/Never Say Never Again (1983)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Night School (2018)" rsync -avhP "/mnt/unraid/media/Movies/Night School (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Survivor (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Survivor (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Thunderball (1965)" rsync -avhP "/mnt/unraid/media/Movies/Thunderball (1965)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Off the Grid (2025)" rsync -avhP "/mnt/unraid/media/Movies/Off the Grid (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Impractical Jokers The Movie (2020)" rsync -avhP "/mnt/unraid/media/Movies/Impractical Jokers The Movie (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Fortress Snipers Eye (2022)" rsync -avhP "/mnt/synology/rs-movies/Fortress Snipers Eye (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Graveyard Shift (1990)" rsync -avhP "/mnt/synology/rs-movies/Graveyard Shift (1990)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Peter Rabbit (2018)" rsync -avhP "/mnt/unraid/media/Movies/Peter Rabbit (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Red Cliff (2008)" rsync -avhP "/mnt/unraid/media/Movies/Red Cliff (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hellraiser Judgment (2018)" rsync -avhP "/mnt/synology/rs-movies/Hellraiser Judgment (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Flash Point (2007)" rsync -avhP "/mnt/unraid/media/Movies/Flash Point (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hampstead (2017)" rsync -avhP "/mnt/synology/rs-movies/Hampstead (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Hole (2001)" rsync -avhP "/mnt/synology/rs-movies/The Hole (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Alice in Wonderland (1951)" rsync -avhP "/mnt/synology/rs-movies/Alice in Wonderland (1951)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Detained (2024)" rsync -avhP "/mnt/unraid/media/Movies/Detained (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Vortex (2021)" rsync -avhP "/mnt/unraid/media/Movies/Vortex (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: American Outlaws (2023)" rsync -avhP "/mnt/synology/rs-movies/American Outlaws (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Chief of Station (2024)" rsync -avhP "/mnt/synology/rs-movies/Chief of Station (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Madman and The Cathedral (2021)" rsync -avhP "/mnt/synology/rs-movies/The Madman and The Cathedral (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Deep House (2021)" rsync -avhP "/mnt/synology/rs-movies/The Deep House (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Bridget Jones Mad About the Boy (2025)" rsync -avhP "/mnt/unraid/media/Movies/Bridget Jones Mad About the Boy (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Frequency (2000)" rsync -avhP "/mnt/unraid/media/Movies/Frequency (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Beverly Hills Cop Axel F (2024)" rsync -avhP "/mnt/unraid/media/Movies/Beverly Hills Cop Axel F (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Eternals (2021)" rsync -avhP "/mnt/unraid/media/Movies/Eternals (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Labor Pains (2009)" rsync -avhP "/mnt/synology/rs-movies/Labor Pains (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: 1900 (1976)" rsync -avhP "/mnt/synology/rs-movies/1900 (1976)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Artemis Fowl (2020)" rsync -avhP "/mnt/synology/rs-movies/Artemis Fowl (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: American Pie Presents Beta House (2007)" rsync -avhP "/mnt/unraid/media/Movies/American Pie Presents Beta House (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Inspection (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Inspection (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Saloum (2023)" rsync -avhP "/mnt/unraid/media/Movies/Saloum (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Spectral (2016)" rsync -avhP "/mnt/synology/rs-movies/Spectral (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Diamonds Are Forever (1971)" rsync -avhP "/mnt/unraid/media/Movies/Diamonds Are Forever (1971)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Pirates of the Caribbean The Curse of the Black Pearl (2003)" rsync -avhP "/mnt/unraid/media/Movies/Pirates of the Caribbean The Curse of the Black Pearl (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: mid90s (2018)" rsync -avhP "/mnt/synology/rs-movies/mid90s (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Santa Sangre (1989)" rsync -avhP "/mnt/unraid/media/Movies/Santa Sangre (1989)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Paris Je T'aime (2006)" rsync -avhP "/mnt/synology/rs-movies/Paris Je T'aime (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Re-Animator (1985)" rsync -avhP "/mnt/synology/rs-movies/Re-Animator (1985)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: PAW Patrol The Mighty Movie (2023)" rsync -avhP "/mnt/unraid/media/Movies/PAW Patrol The Mighty Movie (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Venom (2018)" rsync -avhP "/mnt/unraid/media/Movies/Venom (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Wyrmwood Apocalypse (2022)" rsync -avhP "/mnt/synology/rs-movies/Wyrmwood Apocalypse (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Dumb and Dumber (1994)" rsync -avhP "/mnt/unraid/media/Movies/Dumb and Dumber (1994)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Pitch Black (2000)" rsync -avhP "/mnt/unraid/media/Movies/Pitch Black (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Changing Lanes (2002)" rsync -avhP "/mnt/synology/rs-movies/Changing Lanes (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Maggie (2015)" rsync -avhP "/mnt/synology/rs-movies/Maggie (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Home (2024)" rsync -avhP "/mnt/synology/rs-movies/Home (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Batman and Superman Battle of the Super Sons (2022)" rsync -avhP "/mnt/synology/rs-movies/Batman and Superman Battle of the Super Sons (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Shell (2012)" rsync -avhP "/mnt/synology/rs-movies/Shell (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Russell Peters Almost Famous (2016)" rsync -avhP "/mnt/unraid/media/Movies/Russell Peters Almost Famous (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Jolt (2021)" rsync -avhP "/mnt/unraid/media/Movies/Jolt (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dr. Dolittle 2 (2001)" rsync -avhP "/mnt/synology/rs-movies/Dr. Dolittle 2 (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: To All the Boys Ive Loved Before (2018)" rsync -avhP "/mnt/unraid/media/Movies/To All the Boys Ive Loved Before (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Ip Man The Awakening (2021)" rsync -avhP "/mnt/synology/rs-movies/Ip Man The Awakening (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Bent (2018)" rsync -avhP "/mnt/synology/rs-movies/Bent (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Copshop (2021)" rsync -avhP "/mnt/unraid/media/Movies/Copshop (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hellboy (2019)" rsync -avhP "/mnt/synology/rs-movies/Hellboy (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Blade Runner 2049 (2017)" rsync -avhP "/mnt/unraid/media/Movies/Blade Runner 2049 (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: My Favourite Fabric (2018)" rsync -avhP "/mnt/synology/rs-movies/My Favourite Fabric (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Hustle (2019)" rsync -avhP "/mnt/unraid/media/Movies/The Hustle (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Air (2023)" rsync -avhP "/mnt/unraid/media/Movies/Air (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Tom and Jerry (2021)" rsync -avhP "/mnt/unraid/media/Movies/Tom and Jerry (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Southpaw (2015)" rsync -avhP "/mnt/unraid/media/Movies/Southpaw (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Whistleblower (2010)" rsync -avhP "/mnt/unraid/media/Movies/The Whistleblower (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Chronicles of Narnia The Voyage of the Dawn Treader (2010)" rsync -avhP "/mnt/synology/rs-movies/The Chronicles of Narnia The Voyage of the Dawn Treader (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Defendor (2009)" rsync -avhP "/mnt/synology/rs-movies/Defendor (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Smokin Aces (2006)" rsync -avhP "/mnt/unraid/media/Movies/Smokin Aces (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Dirt (2019)" rsync -avhP "/mnt/synology/rs-movies/The Dirt (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Finestkind (2023)" rsync -avhP "/mnt/synology/rs-movies/Finestkind (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Librarian Return to King Solomons Mines (2006)" rsync -avhP "/mnt/synology/rs-movies/The Librarian Return to King Solomons Mines (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Into the Blue (2005)" rsync -avhP "/mnt/synology/rs-movies/Into the Blue (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Golden Compass (2007)" rsync -avhP "/mnt/synology/rs-movies/The Golden Compass (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Son of a Gun (2014)" rsync -avhP "/mnt/unraid/media/Movies/Son of a Gun (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Twin Peaks Fire Walk with Me (1992)" rsync -avhP "/mnt/unraid/media/Movies/Twin Peaks Fire Walk with Me (1992)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Welcome to Marwen (2018)" rsync -avhP "/mnt/synology/rs-movies/Welcome to Marwen (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Antwone Fisher (2002)" rsync -avhP "/mnt/synology/rs-movies/Antwone Fisher (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: House of Gucci (2021)" rsync -avhP "/mnt/unraid/media/Movies/House of Gucci (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Get Smart (2008)" rsync -avhP "/mnt/synology/rs-movies/Get Smart (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Leahs Perfect Gift (2024)" rsync -avhP "/mnt/synology/rs-movies/Leahs Perfect Gift (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Lucy in the Sky (2019)" rsync -avhP "/mnt/synology/rs-movies/Lucy in the Sky (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Queen Rock Montreal 1981 (2024)" rsync -avhP "/mnt/synology/rs-movies/Queen Rock Montreal 1981 (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: It Ends with Us (2024)" rsync -avhP "/mnt/unraid/media/Movies/It Ends with Us (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Licorice Pizza (2021)" rsync -avhP "/mnt/synology/rs-movies/Licorice Pizza (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Wont You Be My Neighbor (2018)" rsync -avhP "/mnt/unraid/media/Movies/Wont You Be My Neighbor (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Wolf Hour (2019)" rsync -avhP "/mnt/synology/rs-movies/The Wolf Hour (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Schindlers List (1993)" rsync -avhP "/mnt/unraid/media/Movies/Schindlers List (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Gnomeo and Juliet (2011)" rsync -avhP "/mnt/synology/rs-movies/Gnomeo and Juliet (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Raw Deal (1986)" rsync -avhP "/mnt/synology/rs-movies/Raw Deal (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Canary Black (2024)" rsync -avhP "/mnt/unraid/media/Movies/Canary Black (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Thelma (2024)" rsync -avhP "/mnt/unraid/media/Movies/Thelma (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Beetlejuice Beetlejuice (2024)" rsync -avhP "/mnt/unraid/media/Movies/Beetlejuice Beetlejuice (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dont Tell Mom the Babysitters Dead (1991)" rsync -avhP "/mnt/synology/rs-movies/Dont Tell Mom the Babysitters Dead (1991)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Gia (1998)" rsync -avhP "/mnt/synology/rs-movies/Gia (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: A Good Person (2023)" rsync -avhP "/mnt/unraid/media/Movies/A Good Person (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Miracle Mile (1989)" rsync -avhP "/mnt/synology/rs-movies/Miracle Mile (1989)" "/mnt/unraid/media/4K Movies/"

run_cmd "Copy Ali->Chris: 18½ (2022)" rsync -avhP "/mnt/unraid/media/Movies/18½ (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Through My Window 3 Looking at You (2024)" rsync -avhP "/mnt/unraid/media/Movies/Through My Window 3 Looking at You (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Goodrich (2024)" rsync -avhP "/mnt/unraid/media/Movies/Goodrich (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: A Separation (2011)" rsync -avhP "/mnt/synology/rs-movies/A Separation (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Men in Black 3 (2012)" rsync -avhP "/mnt/unraid/media/Movies/Men in Black 3 (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: American Pie (1999)" rsync -avhP "/mnt/unraid/media/Movies/American Pie (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Guilty (2021)" rsync -avhP "/mnt/unraid/media/Movies/The Guilty (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: 28 Years Later (2025)" rsync -avhP "/mnt/unraid/media/Movies/28 Years Later (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Bring It On (2000)" rsync -avhP "/mnt/unraid/media/Movies/Bring It On (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Puppet Master 4 (1993)" rsync -avhP "/mnt/synology/rs-movies/Puppet Master 4 (1993)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Rooster Cogburn (1975)" rsync -avhP "/mnt/synology/rs-movies/Rooster Cogburn (1975)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Hot Tub Time Machine 2 (2015)" rsync -avhP "/mnt/unraid/media/Movies/Hot Tub Time Machine 2 (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Transformers Rise of the Beasts (2023)" rsync -avhP "/mnt/unraid/media/Movies/Transformers Rise of the Beasts (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Internship (2013)" rsync -avhP "/mnt/unraid/media/Movies/The Internship (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Last Shoot Out (2021)" rsync -avhP "/mnt/unraid/media/Movies/Last Shoot Out (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Baise-moi (2000)" rsync -avhP "/mnt/unraid/media/Movies/Baise-moi (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: On the Rocks (2020)" rsync -avhP "/mnt/unraid/media/Movies/On the Rocks (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Elizabethtown (2005)" rsync -avhP "/mnt/synology/rs-movies/Elizabethtown (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Muppets Most Wanted (2014)" rsync -avhP "/mnt/unraid/media/Movies/Muppets Most Wanted (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: A Man Called Otto (2022)" rsync -avhP "/mnt/unraid/media/Movies/A Man Called Otto (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Burnt (2015)" rsync -avhP "/mnt/unraid/media/Movies/Burnt (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: A Quiet Place Part II (2021)" rsync -avhP "/mnt/unraid/media/Movies/A Quiet Place Part II (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Oceans Eleven (2001)" rsync -avhP "/mnt/unraid/media/Movies/Oceans Eleven (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Shaun the Sheep Movie (2015)" rsync -avhP "/mnt/synology/rs-movies/Shaun the Sheep Movie (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Great Dictator (1940)" rsync -avhP "/mnt/synology/rs-movies/The Great Dictator (1940)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Clifford (1994)" rsync -avhP "/mnt/synology/rs-movies/Clifford (1994)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Jerk (1979)" rsync -avhP "/mnt/synology/rs-movies/The Jerk (1979)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Warm Bodies (2013)" rsync -avhP "/mnt/unraid/media/Movies/Warm Bodies (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Vice (2015)" rsync -avhP "/mnt/synology/rs-movies/Vice (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Man on a Ledge (2012)" rsync -avhP "/mnt/synology/rs-movies/Man on a Ledge (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Hotel for Dogs (2009)" rsync -avhP "/mnt/synology/rs-movies/Hotel for Dogs (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Spider-Man Far From Home (2019)" rsync -avhP "/mnt/unraid/media/Movies/Spider-Man Far From Home (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Petes Dragon (2016)" rsync -avhP "/mnt/synology/rs-movies/Petes Dragon (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Jackass 3D (2010)" rsync -avhP "/mnt/synology/rs-movies/Jackass 3D (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Mass Effect Paragon Lost (2012)" rsync -avhP "/mnt/synology/rs-movies/Mass Effect Paragon Lost (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Blast from the Past (1999)" rsync -avhP "/mnt/unraid/media/Movies/Blast from the Past (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Source Code (2011)" rsync -avhP "/mnt/unraid/media/Movies/Source Code (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Max Steel (2016)" rsync -avhP "/mnt/unraid/media/Movies/Max Steel (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: De Palma (2016)" rsync -avhP "/mnt/unraid/media/Movies/De Palma (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Ace Ventura When Nature Calls (1995)" rsync -avhP "/mnt/unraid/media/Movies/Ace Ventura When Nature Calls (1995)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Mothers Day (2016)" rsync -avhP "/mnt/synology/rs-movies/Mothers Day (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Pinocchio (1940)" rsync -avhP "/mnt/synology/rs-movies/Pinocchio (1940)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Edge of the World (2021)" rsync -avhP "/mnt/unraid/media/Movies/Edge of the World (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: V H S Viral (2014)" rsync -avhP "/mnt/synology/rs-movies/V H S Viral (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Scanners (1981)" rsync -avhP "/mnt/synology/rs-movies/Scanners (1981)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Heaven Is for Real (2014)" rsync -avhP "/mnt/synology/rs-movies/Heaven Is for Real (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Scooby-Doo (2002)" rsync -avhP "/mnt/synology/rs-movies/Scooby-Doo (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Theres Something About Mary (1998)" rsync -avhP "/mnt/synology/rs-movies/Theres Something About Mary (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Fantastic Four (2015)" rsync -avhP "/mnt/unraid/media/Movies/Fantastic Four (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Our Fault (2025)" rsync -avhP "/mnt/unraid/media/Movies/Our Fault (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Scarface (1983)" rsync -avhP "/mnt/unraid/media/Movies/Scarface (1983)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Gaslight (1944)" rsync -avhP "/mnt/synology/rs-movies/Gaslight (1944)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Anaconda (1997)" rsync -avhP "/mnt/synology/rs-movies/Anaconda (1997)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Journey to the West Conquering the Demons (2013)" rsync -avhP "/mnt/synology/rs-movies/Journey to the West Conquering the Demons (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Cashback (2007)" rsync -avhP "/mnt/unraid/media/Movies/Cashback (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Death of Superman (2018)" rsync -avhP "/mnt/synology/rs-movies/The Death of Superman (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The French Connection (1971)" rsync -avhP "/mnt/unraid/media/Movies/The French Connection (1971)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Christmas on Duty (2025)" rsync -avhP "/mnt/synology/rs-movies/Christmas on Duty (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Vantage Point (2008)" rsync -avhP "/mnt/unraid/media/Movies/Vantage Point (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Buried Alive (1990)" rsync -avhP "/mnt/unraid/media/Movies/Buried Alive (1990)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Home Sweet Home Alone (2021)" rsync -avhP "/mnt/synology/rs-movies/Home Sweet Home Alone (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Calling (2014)" rsync -avhP "/mnt/synology/rs-movies/The Calling (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Guinea Pig Part 2 Flower of Flesh and Blood (1985)" rsync -avhP "/mnt/synology/rs-movies/Guinea Pig Part 2 Flower of Flesh and Blood (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Close Encounters of the Third Kind (1977)" rsync -avhP "/mnt/unraid/media/Movies/Close Encounters of the Third Kind (1977)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Grand Budapest Hotel (2014)" rsync -avhP "/mnt/unraid/media/Movies/The Grand Budapest Hotel (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Varsity Blues (1999)" rsync -avhP "/mnt/synology/rs-movies/Varsity Blues (1999)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Night Hunter (2019)" rsync -avhP "/mnt/unraid/media/Movies/Night Hunter (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Midway (2019)" rsync -avhP "/mnt/synology/rs-movies/Midway (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Hollow (2015)" rsync -avhP "/mnt/synology/rs-movies/Hollow (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Twilight Saga New Moon (2009)" rsync -avhP "/mnt/unraid/media/Movies/The Twilight Saga New Moon (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Kill Command (2016)" rsync -avhP "/mnt/synology/rs-movies/Kill Command (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: 3 Idiots (2009)" rsync -avhP "/mnt/synology/rs-movies/3 Idiots (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Fast Five (2011)" rsync -avhP "/mnt/unraid/media/Movies/Fast Five (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Pursuit of Happyness (2006)" rsync -avhP "/mnt/synology/rs-movies/The Pursuit of Happyness (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Lincoln (2012)" rsync -avhP "/mnt/unraid/media/Movies/Lincoln (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dave (1993)" rsync -avhP "/mnt/synology/rs-movies/Dave (1993)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Starship Troopers Invasion (2012)" rsync -avhP "/mnt/synology/rs-movies/Starship Troopers Invasion (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Akira (1988)" rsync -avhP "/mnt/unraid/media/Movies/Akira (1988)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Mortal Kombat (1995)" rsync -avhP "/mnt/unraid/media/Movies/Mortal Kombat (1995)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Fast X (2023)" rsync -avhP "/mnt/unraid/media/Movies/Fast X (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Fahrenheit 451 (2018)" rsync -avhP "/mnt/synology/rs-movies/Fahrenheit 451 (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Outsiders (1983)" rsync -avhP "/mnt/unraid/media/Movies/The Outsiders (1983)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Night of the Hunter (1955)" rsync -avhP "/mnt/synology/rs-movies/The Night of the Hunter (1955)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Harry and the Hendersons (1987)" rsync -avhP "/mnt/synology/rs-movies/Harry and the Hendersons (1987)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Mission Impossible II (2000)" rsync -avhP "/mnt/unraid/media/Movies/Mission Impossible II (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Never Let Go (2024)" rsync -avhP "/mnt/unraid/media/Movies/Never Let Go (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Pale Blue Eye (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Pale Blue Eye (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Born on the Fourth of July (1989)" rsync -avhP "/mnt/unraid/media/Movies/Born on the Fourth of July (1989)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Hacksaw Ridge (2016)" rsync -avhP "/mnt/unraid/media/Movies/Hacksaw Ridge (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Uncut Gems (2019)" rsync -avhP "/mnt/unraid/media/Movies/Uncut Gems (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Woman of the Hour (2024)" rsync -avhP "/mnt/unraid/media/Movies/Woman of the Hour (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Wrong Turn 2 Dead End (2007)" rsync -avhP "/mnt/synology/rs-movies/Wrong Turn 2 Dead End (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Flight of the Navigator (1986)" rsync -avhP "/mnt/synology/rs-movies/Flight of the Navigator (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Tomb Raider (2018)" rsync -avhP "/mnt/unraid/media/Movies/Tomb Raider (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Way Back (2010)" rsync -avhP "/mnt/unraid/media/Movies/The Way Back (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: District 9 (2009)" rsync -avhP "/mnt/unraid/media/Movies/District 9 (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Outpost (2020)" rsync -avhP "/mnt/synology/rs-movies/Outpost (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Kinda Pregnant (2025)" rsync -avhP "/mnt/synology/rs-movies/Kinda Pregnant (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Caught Stealing (2025)" rsync -avhP "/mnt/unraid/media/Movies/Caught Stealing (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Until Dawn (2025)" rsync -avhP "/mnt/unraid/media/Movies/Until Dawn (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Gettysburg (1993)" rsync -avhP "/mnt/synology/rs-movies/Gettysburg (1993)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Legion (2010)" rsync -avhP "/mnt/synology/rs-movies/Legion (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Outfit (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Outfit (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Concrete Utopia (2023)" rsync -avhP "/mnt/unraid/media/Movies/Concrete Utopia (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Ready or Not (2019)" rsync -avhP "/mnt/unraid/media/Movies/Ready or Not (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Surrogates (2009)" rsync -avhP "/mnt/unraid/media/Movies/Surrogates (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Nobodys Fool (1994)" rsync -avhP "/mnt/unraid/media/Movies/Nobodys Fool (1994)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Oliver! (1968)" rsync -avhP "/mnt/unraid/media/Movies/Oliver! (1968)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Timecop (1994)" rsync -avhP "/mnt/unraid/media/Movies/Timecop (1994)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: West Side Story (2021)" rsync -avhP "/mnt/synology/rs-movies/West Side Story (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: A Make or Break Holiday (2025)" rsync -avhP "/mnt/synology/rs-movies/A Make or Break Holiday (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Terminator (1984)" rsync -avhP "/mnt/unraid/media/Movies/The Terminator (1984)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Warriors of Future (2022)" rsync -avhP "/mnt/synology/rs-movies/Warriors of Future (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Justice League Gods and Monsters (2015)" rsync -avhP "/mnt/unraid/media/Movies/Justice League Gods and Monsters (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Heat (1995)" rsync -avhP "/mnt/unraid/media/Movies/Heat (1995)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Chris->Ali: Red Wing (2013)" rsync -avhP "/mnt/synology/rs-movies/Red Wing (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Bucket List (2007)" rsync -avhP "/mnt/synology/rs-movies/The Bucket List (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Man Who Killed Don Quixote (2018)" rsync -avhP "/mnt/synology/rs-movies/The Man Who Killed Don Quixote (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Batman Return of the Caped Crusaders (2016)" rsync -avhP "/mnt/synology/rs-movies/Batman Return of the Caped Crusaders (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Dungeons and Dragons The Book of Vile Darkness (2012)" rsync -avhP "/mnt/synology/rs-movies/Dungeons and Dragons The Book of Vile Darkness (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Tremors (1990)" rsync -avhP "/mnt/synology/rs-movies/Tremors (1990)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Abandon (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Abandon (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Incredibles (2004)" rsync -avhP "/mnt/unraid/media/Movies/The Incredibles (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The English Patient (1996)" rsync -avhP "/mnt/synology/rs-movies/The English Patient (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: What Happened to Monday (2017)" rsync -avhP "/mnt/unraid/media/Movies/What Happened to Monday (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dane Cook Vicious Circle (2006)" rsync -avhP "/mnt/synology/rs-movies/Dane Cook Vicious Circle (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Reign of Fire (2002)" rsync -avhP "/mnt/unraid/media/Movies/Reign of Fire (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: A Thunder of Drums (1961)" rsync -avhP "/mnt/synology/rs-movies/A Thunder of Drums (1961)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Children of Men (2006)" rsync -avhP "/mnt/synology/rs-movies/Children of Men (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: My Friend Irma (1949)" rsync -avhP "/mnt/synology/rs-movies/My Friend Irma (1949)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Jack (1996)" rsync -avhP "/mnt/synology/rs-movies/Jack (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Perfect (2019)" rsync -avhP "/mnt/synology/rs-movies/Perfect (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Blue Velvet (1986)" rsync -avhP "/mnt/unraid/media/Movies/Blue Velvet (1986)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Polar Express (2004)" rsync -avhP "/mnt/unraid/media/Movies/The Polar Express (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Hunted (1995)" rsync -avhP "/mnt/synology/rs-movies/The Hunted (1995)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: White Noise (2022)" rsync -avhP "/mnt/unraid/media/Movies/White Noise (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Necessary Evil Super-Villains of DC Comics (2013)" rsync -avhP "/mnt/synology/rs-movies/Necessary Evil Super-Villains of DC Comics (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Tango and Cash (1989)" rsync -avhP "/mnt/unraid/media/Movies/Tango and Cash (1989)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Nope (2022)" rsync -avhP "/mnt/unraid/media/Movies/Nope (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Nights in Rodanthe (2008)" rsync -avhP "/mnt/synology/rs-movies/Nights in Rodanthe (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Spellbound (2024)" rsync -avhP "/mnt/unraid/media/Movies/Spellbound (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Sword and the Sorcerer (1982)" rsync -avhP "/mnt/synology/rs-movies/The Sword and the Sorcerer (1982)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Labyrinth (1986)" rsync -avhP "/mnt/synology/rs-movies/Labyrinth (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Angel Has Fallen (2019)" rsync -avhP "/mnt/unraid/media/Movies/Angel Has Fallen (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Deep Impact (1998)" rsync -avhP "/mnt/unraid/media/Movies/Deep Impact (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: In America (2003)" rsync -avhP "/mnt/synology/rs-movies/In America (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Maleficent Mistress of Evil (2019)" rsync -avhP "/mnt/unraid/media/Movies/Maleficent Mistress of Evil (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: A River Runs Through It (1992)" rsync -avhP "/mnt/synology/rs-movies/A River Runs Through It (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Father of Invention (2010)" rsync -avhP "/mnt/synology/rs-movies/Father of Invention (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Star Trek Section 31 (2025)" rsync -avhP "/mnt/unraid/media/Movies/Star Trek Section 31 (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Darjeeling Limited (2007)" rsync -avhP "/mnt/synology/rs-movies/The Darjeeling Limited (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Ferrari (2023)" rsync -avhP "/mnt/unraid/media/Movies/Ferrari (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Pacific Rim Uprising (2018)" rsync -avhP "/mnt/unraid/media/Movies/Pacific Rim Uprising (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Widows (2018)" rsync -avhP "/mnt/unraid/media/Movies/Widows (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Winter Spring Summer or Fall (2024)" rsync -avhP "/mnt/unraid/media/Movies/Winter Spring Summer or Fall (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Wonderful World of Mickey Mouse Steamboat Silly (2023)" rsync -avhP "/mnt/synology/rs-movies/The Wonderful World of Mickey Mouse Steamboat Silly (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Disaster Holiday (2024)" rsync -avhP "/mnt/synology/rs-movies/Disaster Holiday (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Christmas Comes Twice (2020)" rsync -avhP "/mnt/synology/rs-movies/Christmas Comes Twice (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Robot Dreams (2023)" rsync -avhP "/mnt/unraid/media/Movies/Robot Dreams (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Babysitters (2008)" rsync -avhP "/mnt/synology/rs-movies/The Babysitters (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Home Alone (1990)" rsync -avhP "/mnt/unraid/media/Movies/Home Alone (1990)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Coffee Table (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Coffee Table (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Kingdom (2007)" rsync -avhP "/mnt/unraid/media/Movies/The Kingdom (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Beaver (2011)" rsync -avhP "/mnt/synology/rs-movies/The Beaver (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Luckiest Man in America (2025)" rsync -avhP "/mnt/unraid/media/Movies/The Luckiest Man in America (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Mr. Brooks (2007)" rsync -avhP "/mnt/unraid/media/Movies/Mr. Brooks (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Gambler (2014)" rsync -avhP "/mnt/unraid/media/Movies/The Gambler (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Bernie (2012)" rsync -avhP "/mnt/synology/rs-movies/Bernie (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Take Care of Maya (2023)" rsync -avhP "/mnt/unraid/media/Movies/Take Care of Maya (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Mystery Men (1999)" rsync -avhP "/mnt/unraid/media/Movies/Mystery Men (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Garfield Gets Real (2008)" rsync -avhP "/mnt/synology/rs-movies/Garfield Gets Real (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Central Intelligence (2016)" rsync -avhP "/mnt/unraid/media/Movies/Central Intelligence (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hellraiser Deader (2005)" rsync -avhP "/mnt/synology/rs-movies/Hellraiser Deader (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Tales from the Darkside The Movie (1990)" rsync -avhP "/mnt/synology/rs-movies/Tales from the Darkside The Movie (1990)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Bandit (2022)" rsync -avhP "/mnt/unraid/media/Movies/Bandit (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dead Shot (2023)" rsync -avhP "/mnt/synology/rs-movies/Dead Shot (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Fallen (1998)" rsync -avhP "/mnt/synology/rs-movies/Fallen (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Miracle on 34th Street (1947)" rsync -avhP "/mnt/synology/rs-movies/Miracle on 34th Street (1947)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Trading Places (1983)" rsync -avhP "/mnt/unraid/media/Movies/Trading Places (1983)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Fleshpot on 42nd Street (1973)" rsync -avhP "/mnt/synology/rs-movies/Fleshpot on 42nd Street (1973)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Hellraiser Inferno (2000)" rsync -avhP "/mnt/synology/rs-movies/Hellraiser Inferno (2000)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Injustice (2021)" rsync -avhP "/mnt/synology/rs-movies/Injustice (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Snow White (2025)" rsync -avhP "/mnt/synology/rs-movies/Snow White (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Collateral Beauty (2016)" rsync -avhP "/mnt/unraid/media/Movies/Collateral Beauty (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: My Mercury (2025)" rsync -avhP "/mnt/unraid/media/Movies/My Mercury (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Lover Stalker Killer (2024)" rsync -avhP "/mnt/unraid/media/Movies/Lover Stalker Killer (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Golden Blood (2023)" rsync -avhP "/mnt/synology/rs-movies/Golden Blood (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: An American Tail (1986)" rsync -avhP "/mnt/synology/rs-movies/An American Tail (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Blind (2023)" rsync -avhP "/mnt/synology/rs-movies/The Blind (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Superman (1978)" rsync -avhP "/mnt/synology/rs-movies/Superman (1978)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Me Myself and Irene (2000)" rsync -avhP "/mnt/unraid/media/Movies/Me Myself and Irene (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Big Red One (1980)" rsync -avhP "/mnt/synology/rs-movies/The Big Red One (1980)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Northman (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Northman (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Shes Out of Control (1989)" rsync -avhP "/mnt/synology/rs-movies/Shes Out of Control (1989)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Pinocchio (2019)" rsync -avhP "/mnt/synology/rs-movies/Pinocchio (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Absolute Power (1997)" rsync -avhP "/mnt/unraid/media/Movies/Absolute Power (1997)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Spirit (2008)" rsync -avhP "/mnt/synology/rs-movies/The Spirit (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Dune (1984)" rsync -avhP "/mnt/unraid/media/Movies/Dune (1984)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: True Spirit (2023)" rsync -avhP "/mnt/synology/rs-movies/True Spirit (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: American Insurrection (2021)" rsync -avhP "/mnt/synology/rs-movies/American Insurrection (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Before I Wake (2016)" rsync -avhP "/mnt/synology/rs-movies/Before I Wake (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Extremities (1986)" rsync -avhP "/mnt/synology/rs-movies/Extremities (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Den of Thieves (2018)" rsync -avhP "/mnt/unraid/media/Movies/Den of Thieves (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: George and the Dragon (2004)" rsync -avhP "/mnt/synology/rs-movies/George and the Dragon (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Thunderheart (1992)" rsync -avhP "/mnt/synology/rs-movies/Thunderheart (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Marmalade (2024)" rsync -avhP "/mnt/unraid/media/Movies/Marmalade (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Hate U Give (2018)" rsync -avhP "/mnt/synology/rs-movies/The Hate U Give (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Desert Dawn (2025)" rsync -avhP "/mnt/synology/rs-movies/Desert Dawn (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Choose or Die (2022)" rsync -avhP "/mnt/synology/rs-movies/Choose or Die (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Greta (2019)" rsync -avhP "/mnt/synology/rs-movies/Greta (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Captain Fantastic (2016)" rsync -avhP "/mnt/unraid/media/Movies/Captain Fantastic (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Untold Sign Stealer (2024)" rsync -avhP "/mnt/synology/rs-movies/Untold Sign Stealer (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Beneath the Valley of the Ultra-Vixens (1979)" rsync -avhP "/mnt/synology/rs-movies/Beneath the Valley of the Ultra-Vixens (1979)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Deadpool and Wolverine (2024)" rsync -avhP "/mnt/unraid/media/Movies/Deadpool and Wolverine (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Joker Folie a Deux (2024)" rsync -avhP "/mnt/unraid/media/Movies/Joker Folie a Deux (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Bad Times at the El Royale (2018)" rsync -avhP "/mnt/unraid/media/Movies/Bad Times at the El Royale (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hardbodies (1984)" rsync -avhP "/mnt/synology/rs-movies/Hardbodies (1984)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Love Hard (2021)" rsync -avhP "/mnt/unraid/media/Movies/Love Hard (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Risky Business (1983)" rsync -avhP "/mnt/unraid/media/Movies/Risky Business (1983)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Sleeping Beauty (1959)" rsync -avhP "/mnt/unraid/media/Movies/Sleeping Beauty (1959)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Sharknado 3 Oh Hell No! (2015)" rsync -avhP "/mnt/unraid/media/Movies/Sharknado 3 Oh Hell No! (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Here Before (2022)" rsync -avhP "/mnt/unraid/media/Movies/Here Before (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Didi 弟弟 (2024)" rsync -avhP "/mnt/unraid/media/Movies/Didi 弟弟 (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: In a World. (2013)" rsync -avhP "/mnt/synology/rs-movies/In a World. (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Naked Gun (2025)" rsync -avhP "/mnt/unraid/media/Movies/The Naked Gun (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Hundred-Foot Journey (2014)" rsync -avhP "/mnt/unraid/media/Movies/The Hundred-Foot Journey (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Kung Pow Enter the Fist (2002)" rsync -avhP "/mnt/unraid/media/Movies/Kung Pow Enter the Fist (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Undefeated (1969)" rsync -avhP "/mnt/synology/rs-movies/The Undefeated (1969)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Bad Luck Banging or Loony Porn (2021)" rsync -avhP "/mnt/synology/rs-movies/Bad Luck Banging or Loony Porn (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Resident Evil Retribution (2012)" rsync -avhP "/mnt/unraid/media/Movies/Resident Evil Retribution (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Garden Party (2008)" rsync -avhP "/mnt/synology/rs-movies/Garden Party (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Muppet Christmas Carol (1992)" rsync -avhP "/mnt/synology/rs-movies/The Muppet Christmas Carol (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Last Seen Alive (2022)" rsync -avhP "/mnt/unraid/media/Movies/Last Seen Alive (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: I See You (2019)" rsync -avhP "/mnt/unraid/media/Movies/I See You (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Resistance (2020)" rsync -avhP "/mnt/unraid/media/Movies/Resistance (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Desire (2011)" rsync -avhP "/mnt/unraid/media/Movies/Desire (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Program (1993)" rsync -avhP "/mnt/unraid/media/Movies/The Program (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Mike Birbiglia Thank God for Jokes (2017)" rsync -avhP "/mnt/synology/rs-movies/Mike Birbiglia Thank God for Jokes (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Mike Birbiglia The New One (2019)" rsync -avhP "/mnt/synology/rs-movies/Mike Birbiglia The New One (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Cocoon The Return (1988)" rsync -avhP "/mnt/synology/rs-movies/Cocoon The Return (1988)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Let the Right One In (2008)" rsync -avhP "/mnt/unraid/media/Movies/Let the Right One In (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Prophecy (1995)" rsync -avhP "/mnt/unraid/media/Movies/The Prophecy (1995)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Transporter Refueled (2015)" rsync -avhP "/mnt/synology/rs-movies/The Transporter Refueled (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Skin (2019)" rsync -avhP "/mnt/unraid/media/Movies/Skin (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Buddy Games (2019)" rsync -avhP "/mnt/unraid/media/Movies/Buddy Games (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dark Places (2015)" rsync -avhP "/mnt/unraid/media/Movies/Dark Places (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Incoming (2024)" rsync -avhP "/mnt/unraid/media/Movies/Incoming (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Gabriel Iglesias Im Sorry for What I Said When I Was Hungry (2016)" rsync -avhP "/mnt/synology/rs-movies/Gabriel Iglesias Im Sorry for What I Said When I Was Hungry (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Thing (2011)" rsync -avhP "/mnt/synology/rs-movies/The Thing (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Superman Man of Tomorrow (2020)" rsync -avhP "/mnt/unraid/media/Movies/Superman Man of Tomorrow (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Thats My Boy (2012)" rsync -avhP "/mnt/synology/rs-movies/Thats My Boy (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Weekend at Bernies II (1993)" rsync -avhP "/mnt/synology/rs-movies/Weekend at Bernies II (1993)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Hoffa (1992)" rsync -avhP "/mnt/unraid/media/Movies/Hoffa (1992)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Youth in Revolt (2009)" rsync -avhP "/mnt/synology/rs-movies/Youth in Revolt (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Spy Kids (2001)" rsync -avhP "/mnt/synology/rs-movies/Spy Kids (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Switch (2010)" rsync -avhP "/mnt/unraid/media/Movies/The Switch (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Upside Down (2012)" rsync -avhP "/mnt/synology/rs-movies/Upside Down (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Catch Me If You Can (2002)" rsync -avhP "/mnt/unraid/media/Movies/Catch Me If You Can (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Hot Shots! (1991)" rsync -avhP "/mnt/unraid/media/Movies/Hot Shots! (1991)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: In Vitro (2025)" rsync -avhP "/mnt/synology/rs-movies/In Vitro (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Commando (1985)" rsync -avhP "/mnt/synology/rs-movies/Commando (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: A Call to Spy (2020)" rsync -avhP "/mnt/unraid/media/Movies/A Call to Spy (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: DC Showcase Catwoman (2011)" rsync -avhP "/mnt/synology/rs-movies/DC Showcase Catwoman (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Josie and the Pussycats (2001)" rsync -avhP "/mnt/synology/rs-movies/Josie and the Pussycats (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The House with a Clock in Its Walls (2018)" rsync -avhP "/mnt/unraid/media/Movies/The House with a Clock in Its Walls (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Ted 2 (2015)" rsync -avhP "/mnt/synology/rs-movies/Ted 2 (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Cold Pursuit (2019)" rsync -avhP "/mnt/unraid/media/Movies/Cold Pursuit (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Trouble (2024)" rsync -avhP "/mnt/unraid/media/Movies/Trouble (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Rugrats in Paris The Movie (2000)" rsync -avhP "/mnt/synology/rs-movies/Rugrats in Paris The Movie (2000)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: DC Showcase The Spectre (2010)" rsync -avhP "/mnt/synology/rs-movies/DC Showcase The Spectre (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: King Kong (2005)" rsync -avhP "/mnt/synology/rs-movies/King Kong (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Chained Heat 2 (1993)" rsync -avhP "/mnt/unraid/media/Movies/Chained Heat 2 (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Enemy (2014)" rsync -avhP "/mnt/unraid/media/Movies/Enemy (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Cats Eye (1985)" rsync -avhP "/mnt/synology/rs-movies/Cats Eye (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Risen (2016)" rsync -avhP "/mnt/synology/rs-movies/Risen (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Muzzle (2023)" rsync -avhP "/mnt/unraid/media/Movies/Muzzle (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Sing (2016)" rsync -avhP "/mnt/synology/rs-movies/Sing (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Five Star Christmas (2020)" rsync -avhP "/mnt/synology/rs-movies/Five Star Christmas (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Cold Skin (2017)" rsync -avhP "/mnt/synology/rs-movies/Cold Skin (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: How to Make Millions Before Grandma Dies (2024)" rsync -avhP "/mnt/synology/rs-movies/How to Make Millions Before Grandma Dies (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Nausicaa of the Valley of the Wind (1984)" rsync -avhP "/mnt/synology/rs-movies/Nausicaa of the Valley of the Wind (1984)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Iron Man and Hulk Heroes United (2013)" rsync -avhP "/mnt/synology/rs-movies/Iron Man and Hulk Heroes United (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Louis C.K. Sorry (2021)" rsync -avhP "/mnt/unraid/media/Movies/Louis C.K. Sorry (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Red Eye (2005)" rsync -avhP "/mnt/unraid/media/Movies/Red Eye (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Social Network (2010)" rsync -avhP "/mnt/synology/rs-movies/The Social Network (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Enola Holmes 2 (2022)" rsync -avhP "/mnt/unraid/media/Movies/Enola Holmes 2 (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Flow (2024)" rsync -avhP "/mnt/unraid/media/Movies/Flow (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The War at Home (1996)" rsync -avhP "/mnt/synology/rs-movies/The War at Home (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Leo Reich Literally Who Cares!! (2023)" rsync -avhP "/mnt/unraid/media/Movies/Leo Reich Literally Who Cares!! (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Nest of Vampires (2021)" rsync -avhP "/mnt/synology/rs-movies/Nest of Vampires (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: RoboCop 3 (1993)" rsync -avhP "/mnt/synology/rs-movies/RoboCop 3 (1993)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: 100% Wolf (2020)" rsync -avhP "/mnt/synology/rs-movies/100% Wolf (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Sea of Trees (2016)" rsync -avhP "/mnt/synology/rs-movies/The Sea of Trees (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: House (1985)" rsync -avhP "/mnt/synology/rs-movies/House (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Star Wars The Clone Wars (2008)" rsync -avhP "/mnt/unraid/media/Movies/Star Wars The Clone Wars (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Lean on Pete (2018)" rsync -avhP "/mnt/unraid/media/Movies/Lean on Pete (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Brutalist (2024)" rsync -avhP "/mnt/synology/rs-movies/The Brutalist (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Hellraiser (2022)" rsync -avhP "/mnt/unraid/media/Movies/Hellraiser (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Senior Year (2022)" rsync -avhP "/mnt/synology/rs-movies/Senior Year (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Holy Mountain (1973)" rsync -avhP "/mnt/synology/rs-movies/The Holy Mountain (1973)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Lost in the Stars (2023)" rsync -avhP "/mnt/unraid/media/Movies/Lost in the Stars (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Ugly Stepsister (2025)" rsync -avhP "/mnt/unraid/media/Movies/The Ugly Stepsister (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Live Free or Die Hard (2007)" rsync -avhP "/mnt/unraid/media/Movies/Live Free or Die Hard (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Suicide Kings (1997)" rsync -avhP "/mnt/unraid/media/Movies/Suicide Kings (1997)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Funny Lady (1975)" rsync -avhP "/mnt/unraid/media/Movies/Funny Lady (1975)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Emoji Movie (2017)" rsync -avhP "/mnt/unraid/media/Movies/The Emoji Movie (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Philadelphia (1993)" rsync -avhP "/mnt/synology/rs-movies/Philadelphia (1993)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Matt Rife Only Fans (2021)" rsync -avhP "/mnt/unraid/media/Movies/Matt Rife Only Fans (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Saiyaara (2025)" rsync -avhP "/mnt/unraid/media/Movies/Saiyaara (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: So I Married an Axe Murderer (1993)" rsync -avhP "/mnt/unraid/media/Movies/So I Married an Axe Murderer (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Circle (2017)" rsync -avhP "/mnt/synology/rs-movies/The Circle (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Inspector Gadget (1999)" rsync -avhP "/mnt/synology/rs-movies/Inspector Gadget (1999)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: We Met in December (2025)" rsync -avhP "/mnt/synology/rs-movies/We Met in December (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Hotel Chevalier (2007)" rsync -avhP "/mnt/unraid/media/Movies/Hotel Chevalier (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Metro Manila (2013)" rsync -avhP "/mnt/unraid/media/Movies/Metro Manila (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Chef (2014)" rsync -avhP "/mnt/unraid/media/Movies/Chef (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Ninja Assassin (2009)" rsync -avhP "/mnt/synology/rs-movies/Ninja Assassin (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Abyss (1989)" rsync -avhP "/mnt/unraid/media/Movies/The Abyss (1989)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: King of Killers (2023)" rsync -avhP "/mnt/unraid/media/Movies/King of Killers (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Coriolanus (2011)" rsync -avhP "/mnt/synology/rs-movies/Coriolanus (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: A Monster in Paris (2011)" rsync -avhP "/mnt/unraid/media/Movies/A Monster in Paris (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Man Who Shot Liberty Valance (1962)" rsync -avhP "/mnt/synology/rs-movies/The Man Who Shot Liberty Valance (1962)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Deja Vu (2006)" rsync -avhP "/mnt/synology/rs-movies/Deja Vu (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Pet Sematary (2019)" rsync -avhP "/mnt/synology/rs-movies/Pet Sematary (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: 48 Hrs. (1982)" rsync -avhP "/mnt/unraid/media/Movies/48 Hrs. (1982)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Amazing Panda Adventure (1995)" rsync -avhP "/mnt/unraid/media/Movies/The Amazing Panda Adventure (1995)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Grey (2012)" rsync -avhP "/mnt/unraid/media/Movies/The Grey (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Alien Nation (1988)" rsync -avhP "/mnt/unraid/media/Movies/Alien Nation (1988)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dangerous Waters (2023)" rsync -avhP "/mnt/unraid/media/Movies/Dangerous Waters (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Hard Home (2024)" rsync -avhP "/mnt/unraid/media/Movies/Hard Home (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Scoob! (2020)" rsync -avhP "/mnt/synology/rs-movies/Scoob! (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Losin It (1983)" rsync -avhP "/mnt/synology/rs-movies/Losin It (1983)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Seems Like Old Times (1980)" rsync -avhP "/mnt/synology/rs-movies/Seems Like Old Times (1980)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Menu (2022)" rsync -avhP "/mnt/synology/rs-movies/Menu (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Pineapple Express (2008)" rsync -avhP "/mnt/unraid/media/Movies/Pineapple Express (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Minority Report (2002)" rsync -avhP "/mnt/unraid/media/Movies/Minority Report (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Gods of Egypt (2016)" rsync -avhP "/mnt/unraid/media/Movies/Gods of Egypt (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Lady and the Tramp II Scamps Adventure (2001)" rsync -avhP "/mnt/unraid/media/Movies/Lady and the Tramp II Scamps Adventure (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Poser (2022)" rsync -avhP "/mnt/unraid/media/Movies/Poser (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: A Wrinkle in Time (2018)" rsync -avhP "/mnt/unraid/media/Movies/A Wrinkle in Time (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: I Saw the TV Glow (2024)" rsync -avhP "/mnt/unraid/media/Movies/I Saw the TV Glow (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: My Dinner with Andre (1981)" rsync -avhP "/mnt/synology/rs-movies/My Dinner with Andre (1981)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Catharsys or The Afina Tales of the Lost World (2018)" rsync -avhP "/mnt/synology/rs-movies/Catharsys or The Afina Tales of the Lost World (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Streets of Fire (1984)" rsync -avhP "/mnt/synology/rs-movies/Streets of Fire (1984)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Nomads (2019)" rsync -avhP "/mnt/unraid/media/Movies/The Nomads (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Blackwater Lane (2024)" rsync -avhP "/mnt/unraid/media/Movies/Blackwater Lane (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Ghostland (2018)" rsync -avhP "/mnt/unraid/media/Movies/Ghostland (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Return of the Killer Tomatoes! (1988)" rsync -avhP "/mnt/synology/rs-movies/Return of the Killer Tomatoes! (1988)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Imperium (2016)" rsync -avhP "/mnt/synology/rs-movies/Imperium (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Idiocracy (2006)" rsync -avhP "/mnt/unraid/media/Movies/Idiocracy (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Duke (2021)" rsync -avhP "/mnt/unraid/media/Movies/The Duke (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Ringer (2005)" rsync -avhP "/mnt/synology/rs-movies/The Ringer (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Trolls Band Together (2023)" rsync -avhP "/mnt/synology/rs-movies/Trolls Band Together (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Follow That Dream (1962)" rsync -avhP "/mnt/synology/rs-movies/Follow That Dream (1962)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Tinker Bell (2008)" rsync -avhP "/mnt/unraid/media/Movies/Tinker Bell (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: O'Dessa (2025)" rsync -avhP "/mnt/synology/rs-movies/O'Dessa (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Forces of Nature (1999)" rsync -avhP "/mnt/synology/rs-movies/Forces of Nature (1999)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Prince of Egypt (1998)" rsync -avhP "/mnt/unraid/media/Movies/The Prince of Egypt (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Saw X (2023)" rsync -avhP "/mnt/unraid/media/Movies/Saw X (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Island of Dr. Moreau (1996)" rsync -avhP "/mnt/synology/rs-movies/The Island of Dr. Moreau (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Sketch (2025)" rsync -avhP "/mnt/synology/rs-movies/Sketch (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Troy (2004)" rsync -avhP "/mnt/unraid/media/Movies/Troy (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Cocktail (1988)" rsync -avhP "/mnt/unraid/media/Movies/Cocktail (1988)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Magicians Elephant (2023)" rsync -avhP "/mnt/synology/rs-movies/The Magicians Elephant (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: UHF (1989)" rsync -avhP "/mnt/unraid/media/Movies/UHF (1989)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Hugo (2011)" rsync -avhP "/mnt/unraid/media/Movies/Hugo (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Coal Miners Daughter (1980)" rsync -avhP "/mnt/synology/rs-movies/Coal Miners Daughter (1980)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Taking of Deborah Logan (2014)" rsync -avhP "/mnt/synology/rs-movies/The Taking of Deborah Logan (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Death Wish (2018)" rsync -avhP "/mnt/unraid/media/Movies/Death Wish (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Heretic (2024)" rsync -avhP "/mnt/unraid/media/Movies/Heretic (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Here (2024)" rsync -avhP "/mnt/unraid/media/Movies/Here (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Stolen Girl (2025)" rsync -avhP "/mnt/unraid/media/Movies/Stolen Girl (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Spy Kids 2 The Island of Lost Dreams (2002)" rsync -avhP "/mnt/synology/rs-movies/Spy Kids 2 The Island of Lost Dreams (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Whiskey Tango Foxtrot (2016)" rsync -avhP "/mnt/synology/rs-movies/Whiskey Tango Foxtrot (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Justice League Dark Apokolips War (2020)" rsync -avhP "/mnt/unraid/media/Movies/Justice League Dark Apokolips War (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Ali Wong Don Wong (2022)" rsync -avhP "/mnt/unraid/media/Movies/Ali Wong Don Wong (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Mississippi Grind (2015)" rsync -avhP "/mnt/unraid/media/Movies/Mississippi Grind (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Shrouds (2025)" rsync -avhP "/mnt/synology/rs-movies/The Shrouds (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Last Word (2017)" rsync -avhP "/mnt/unraid/media/Movies/The Last Word (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Net Worth (1995)" rsync -avhP "/mnt/synology/rs-movies/Net Worth (1995)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Bullet to the Head (2012)" rsync -avhP "/mnt/synology/rs-movies/Bullet to the Head (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Distant (2024)" rsync -avhP "/mnt/synology/rs-movies/Distant (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Wasp (2024)" rsync -avhP "/mnt/synology/rs-movies/The Wasp (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Superman Doomsday (2007)" rsync -avhP "/mnt/unraid/media/Movies/Superman Doomsday (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Christmas Card (2006)" rsync -avhP "/mnt/synology/rs-movies/The Christmas Card (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Open Range (2003)" rsync -avhP "/mnt/synology/rs-movies/Open Range (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: George Carlin 40 Years of Comedy (1997)" rsync -avhP "/mnt/synology/rs-movies/George Carlin 40 Years of Comedy (1997)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Pumping Iron (1977)" rsync -avhP "/mnt/synology/rs-movies/Pumping Iron (1977)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The War Zone (1999)" rsync -avhP "/mnt/unraid/media/Movies/The War Zone (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Chasing Amy (1997)" rsync -avhP "/mnt/synology/rs-movies/Chasing Amy (1997)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Saw 3D (2010)" rsync -avhP "/mnt/synology/rs-movies/Saw 3D (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Justice League vs. Teen Titans (2016)" rsync -avhP "/mnt/unraid/media/Movies/Justice League vs. Teen Titans (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Operation Endgame (2010)" rsync -avhP "/mnt/synology/rs-movies/Operation Endgame (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Skinwalker Ranch (2013)" rsync -avhP "/mnt/synology/rs-movies/Skinwalker Ranch (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Nocturnal Animals (2016)" rsync -avhP "/mnt/unraid/media/Movies/Nocturnal Animals (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Jerry and Marge Go Large (2022)" rsync -avhP "/mnt/unraid/media/Movies/Jerry and Marge Go Large (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Long Kiss Goodnight (1996)" rsync -avhP "/mnt/unraid/media/Movies/The Long Kiss Goodnight (1996)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Fabelmans (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Fabelmans (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Shark Exorcist (2015)" rsync -avhP "/mnt/unraid/media/Movies/Shark Exorcist (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Spy Who Loved Me (1977)" rsync -avhP "/mnt/synology/rs-movies/The Spy Who Loved Me (1977)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Shaft (2000)" rsync -avhP "/mnt/unraid/media/Movies/Shaft (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Marcel the Shell with Shoes On (2022)" rsync -avhP "/mnt/unraid/media/Movies/Marcel the Shell with Shoes On (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Backcountry (2015)" rsync -avhP "/mnt/synology/rs-movies/Backcountry (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Poltergeist (2015)" rsync -avhP "/mnt/synology/rs-movies/Poltergeist (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Gunner (2024)" rsync -avhP "/mnt/unraid/media/Movies/Gunner (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Prisoners of the Ghostland (2021)" rsync -avhP "/mnt/unraid/media/Movies/Prisoners of the Ghostland (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Monsters Ball (2001)" rsync -avhP "/mnt/unraid/media/Movies/Monsters Ball (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Attack the Block (2011)" rsync -avhP "/mnt/synology/rs-movies/Attack the Block (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Grease (1978)" rsync -avhP "/mnt/synology/rs-movies/Grease (1978)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Three O'Clock High (1987)" rsync -avhP "/mnt/synology/rs-movies/Three O'Clock High (1987)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Place Beyond the Pines (2013)" rsync -avhP "/mnt/unraid/media/Movies/The Place Beyond the Pines (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Mechanic Resurrection (2016)" rsync -avhP "/mnt/unraid/media/Movies/Mechanic Resurrection (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Lego Movie (2014)" rsync -avhP "/mnt/unraid/media/Movies/The Lego Movie (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Sisters Brothers (2018)" rsync -avhP "/mnt/unraid/media/Movies/The Sisters Brothers (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: King Richard (2021)" rsync -avhP "/mnt/unraid/media/Movies/King Richard (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: 300 (2007)" rsync -avhP "/mnt/unraid/media/Movies/300 (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Three Kings (1999)" rsync -avhP "/mnt/unraid/media/Movies/Three Kings (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Return of the Jedi (1983)" rsync -avhP "/mnt/unraid/media/Movies/Return of the Jedi (1983)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Punisher (2004)" rsync -avhP "/mnt/unraid/media/Movies/The Punisher (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Locked (2025)" rsync -avhP "/mnt/unraid/media/Movies/Locked (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Grimsby (2016)" rsync -avhP "/mnt/unraid/media/Movies/Grimsby (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Kids in the Hall Brain Candy (1996)" rsync -avhP "/mnt/synology/rs-movies/Kids in the Hall Brain Candy (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Candyman (2021)" rsync -avhP "/mnt/unraid/media/Movies/Candyman (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Catwoman (2004)" rsync -avhP "/mnt/synology/rs-movies/Catwoman (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Freddys Dead The Final Nightmare (1991)" rsync -avhP "/mnt/unraid/media/Movies/Freddys Dead The Final Nightmare (1991)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dave Chappelle The Bird Revelation (2017)" rsync -avhP "/mnt/unraid/media/Movies/Dave Chappelle The Bird Revelation (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Laundromat (2019)" rsync -avhP "/mnt/unraid/media/Movies/The Laundromat (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Adventures of Ichabod and Mr. Toad (1949)" rsync -avhP "/mnt/synology/rs-movies/The Adventures of Ichabod and Mr. Toad (1949)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: S.W.A.T. (2003)" rsync -avhP "/mnt/synology/rs-movies/S.W.A.T. (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Chopping Mall (1986)" rsync -avhP "/mnt/synology/rs-movies/Chopping Mall (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Delicatessen (1991)" rsync -avhP "/mnt/unraid/media/Movies/Delicatessen (1991)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: How to Blow Up a Pipeline (2023)" rsync -avhP "/mnt/unraid/media/Movies/How to Blow Up a Pipeline (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Lewis Black In God We Rust (2012)" rsync -avhP "/mnt/unraid/media/Movies/Lewis Black In God We Rust (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Holes (2003)" rsync -avhP "/mnt/unraid/media/Movies/Holes (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Napoleon (2023)" rsync -avhP "/mnt/unraid/media/Movies/Napoleon (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Transylmania (2009)" rsync -avhP "/mnt/synology/rs-movies/Transylmania (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Four Rooms (1995)" rsync -avhP "/mnt/unraid/media/Movies/Four Rooms (1995)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hudson Hawk (1991)" rsync -avhP "/mnt/synology/rs-movies/Hudson Hawk (1991)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Bad Lieutenant Port of Call New Orleans (2009)" rsync -avhP "/mnt/synology/rs-movies/Bad Lieutenant Port of Call New Orleans (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Thor Love and Thunder (2022)" rsync -avhP "/mnt/unraid/media/Movies/Thor Love and Thunder (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dark City (1998)" rsync -avhP "/mnt/unraid/media/Movies/Dark City (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Louis C.K. at the Dolby (2023)" rsync -avhP "/mnt/synology/rs-movies/Louis C.K. at the Dolby (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Gift (2015)" rsync -avhP "/mnt/synology/rs-movies/The Gift (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Childs Play (1988)" rsync -avhP "/mnt/unraid/media/Movies/Childs Play (1988)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Queer (2024)" rsync -avhP "/mnt/unraid/media/Movies/Queer (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Julias Eyes (2010)" rsync -avhP "/mnt/unraid/media/Movies/Julias Eyes (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: I Am Sam (2001)" rsync -avhP "/mnt/unraid/media/Movies/I Am Sam (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Umma (2022)" rsync -avhP "/mnt/unraid/media/Movies/Umma (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: 1944 (2015)" rsync -avhP "/mnt/synology/rs-movies/1944 (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Adrift (2018)" rsync -avhP "/mnt/synology/rs-movies/Adrift (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: All Quiet on the Western Front (2022)" rsync -avhP "/mnt/unraid/media/Movies/All Quiet on the Western Front (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: 360 (2012)" rsync -avhP "/mnt/synology/rs-movies/360 (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Battle Los Angeles (2011)" rsync -avhP "/mnt/unraid/media/Movies/Battle Los Angeles (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Sunrise (2024)" rsync -avhP "/mnt/synology/rs-movies/Sunrise (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: LBJ (2017)" rsync -avhP "/mnt/synology/rs-movies/LBJ (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Jerrod Carmichael 8 (2017)" rsync -avhP "/mnt/unraid/media/Movies/Jerrod Carmichael 8 (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Terrifier 3 (2024)" rsync -avhP "/mnt/unraid/media/Movies/Terrifier 3 (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Biloxi Blues (1988)" rsync -avhP "/mnt/unraid/media/Movies/Biloxi Blues (1988)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Happy Howlidays (2024)" rsync -avhP "/mnt/synology/rs-movies/Happy Howlidays (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Delta Force 2 The Colombian Connection (1990)" rsync -avhP "/mnt/unraid/media/Movies/Delta Force 2 The Colombian Connection (1990)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Shallow Hal (2001)" rsync -avhP "/mnt/synology/rs-movies/Shallow Hal (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Last Kingdom Seven Kings Must Die (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Last Kingdom Seven Kings Must Die (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Abigail (2023)" rsync -avhP "/mnt/synology/rs-movies/Abigail (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Trolls World Tour (2020)" rsync -avhP "/mnt/unraid/media/Movies/Trolls World Tour (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Curse (1987)" rsync -avhP "/mnt/synology/rs-movies/The Curse (1987)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Sinbad Legend of the Seven Seas (2003)" rsync -avhP "/mnt/synology/rs-movies/Sinbad Legend of the Seven Seas (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Hyperions (2022)" rsync -avhP "/mnt/synology/rs-movies/The Hyperions (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: 2 Days in the Valley (1996)" rsync -avhP "/mnt/unraid/media/Movies/2 Days in the Valley (1996)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: You Kill Me (2007)" rsync -avhP "/mnt/synology/rs-movies/You Kill Me (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Kingdom of Heaven (2005)" rsync -avhP "/mnt/unraid/media/Movies/Kingdom of Heaven (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: About Dry Grasses (2023)" rsync -avhP "/mnt/synology/rs-movies/About Dry Grasses (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Red Dawn (1984)" rsync -avhP "/mnt/unraid/media/Movies/Red Dawn (1984)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Cinderella (2021)" rsync -avhP "/mnt/unraid/media/Movies/Cinderella (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: American Fiction (2023)" rsync -avhP "/mnt/unraid/media/Movies/American Fiction (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Twister (1996)" rsync -avhP "/mnt/unraid/media/Movies/Twister (1996)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Bird Box Barcelona (2023)" rsync -avhP "/mnt/unraid/media/Movies/Bird Box Barcelona (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Forrest Gump (1994)" rsync -avhP "/mnt/unraid/media/Movies/Forrest Gump (1994)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: United 93 (2006)" rsync -avhP "/mnt/unraid/media/Movies/United 93 (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Promising Young Woman (2020)" rsync -avhP "/mnt/unraid/media/Movies/Promising Young Woman (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Mr. Woodcock (2007)" rsync -avhP "/mnt/unraid/media/Movies/Mr. Woodcock (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Darlin (2019)" rsync -avhP "/mnt/synology/rs-movies/Darlin (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Superman II The Richard Donner Cut (2006)" rsync -avhP "/mnt/synology/rs-movies/Superman II The Richard Donner Cut (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Collective (2023)" rsync -avhP "/mnt/synology/rs-movies/The Collective (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Caddyshack (1980)" rsync -avhP "/mnt/synology/rs-movies/Caddyshack (1980)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Steel Magnolias (1989)" rsync -avhP "/mnt/synology/rs-movies/Steel Magnolias (1989)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Fugitive (1993)" rsync -avhP "/mnt/unraid/media/Movies/The Fugitive (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Watchmen (2009)" rsync -avhP "/mnt/synology/rs-movies/Watchmen (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Widow Clicquot (2024)" rsync -avhP "/mnt/unraid/media/Movies/Widow Clicquot (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: -batteries not included (1987)" rsync -avhP "/mnt/unraid/media/Movies/-batteries not included (1987)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Eagle Has Landed (1976)" rsync -avhP "/mnt/synology/rs-movies/The Eagle Has Landed (1976)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Jumanji The Next Level (2019)" rsync -avhP "/mnt/unraid/media/Movies/Jumanji The Next Level (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Fox and the Hound (1981)" rsync -avhP "/mnt/synology/rs-movies/The Fox and the Hound (1981)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Dunkirk (2017)" rsync -avhP "/mnt/unraid/media/Movies/Dunkirk (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Passages (2023)" rsync -avhP "/mnt/unraid/media/Movies/Passages (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Kill Me Three Times (2015)" rsync -avhP "/mnt/synology/rs-movies/Kill Me Three Times (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Redemption (2013)" rsync -avhP "/mnt/unraid/media/Movies/Redemption (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: We Need to Talk About Kevin (2011)" rsync -avhP "/mnt/unraid/media/Movies/We Need to Talk About Kevin (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Companion (2025)" rsync -avhP "/mnt/unraid/media/Movies/Companion (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Champions (2023)" rsync -avhP "/mnt/unraid/media/Movies/Champions (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dead for a Dollar (2022)" rsync -avhP "/mnt/synology/rs-movies/Dead for a Dollar (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Immaculate (2024)" rsync -avhP "/mnt/unraid/media/Movies/Immaculate (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Emperor (2012)" rsync -avhP "/mnt/synology/rs-movies/Emperor (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Devil Conspiracy (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Devil Conspiracy (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Lord of the Rings The Return of the King (2003)" rsync -avhP "/mnt/unraid/media/Movies/The Lord of the Rings The Return of the King (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Lair (2021)" rsync -avhP "/mnt/synology/rs-movies/Lair (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Shaft (2019)" rsync -avhP "/mnt/unraid/media/Movies/Shaft (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Christmas Waltz (2020)" rsync -avhP "/mnt/synology/rs-movies/Christmas Waltz (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Mad God (2021)" rsync -avhP "/mnt/unraid/media/Movies/Mad God (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Upgrade (2018)" rsync -avhP "/mnt/unraid/media/Movies/Upgrade (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Hatchet III (2013)" rsync -avhP "/mnt/unraid/media/Movies/Hatchet III (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Mothman Prophecies (2002)" rsync -avhP "/mnt/unraid/media/Movies/The Mothman Prophecies (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Man of Steel (2013)" rsync -avhP "/mnt/unraid/media/Movies/Man of Steel (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Naked Gun From the Files of Police Squad! (1988)" rsync -avhP "/mnt/unraid/media/Movies/The Naked Gun From the Files of Police Squad! (1988)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: My Fair Lady (1964)" rsync -avhP "/mnt/unraid/media/Movies/My Fair Lady (1964)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: LEGO Batman The Movie DC Super Heroes Unite (2013)" rsync -avhP "/mnt/synology/rs-movies/LEGO Batman The Movie DC Super Heroes Unite (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Sixth (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Sixth (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: I Am Bolt (2016)" rsync -avhP "/mnt/unraid/media/Movies/I Am Bolt (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Aftermath (2017)" rsync -avhP "/mnt/unraid/media/Movies/Aftermath (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Stagecoach (1966)" rsync -avhP "/mnt/synology/rs-movies/Stagecoach (1966)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Meet Dave (2008)" rsync -avhP "/mnt/unraid/media/Movies/Meet Dave (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Requiem for a Dream (2000)" rsync -avhP "/mnt/unraid/media/Movies/Requiem for a Dream (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Memoirs of an Invisible Man (1992)" rsync -avhP "/mnt/synology/rs-movies/Memoirs of an Invisible Man (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Night of the Demons (2009)" rsync -avhP "/mnt/synology/rs-movies/Night of the Demons (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Ring (2002)" rsync -avhP "/mnt/unraid/media/Movies/The Ring (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Intruder (1989)" rsync -avhP "/mnt/synology/rs-movies/Intruder (1989)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Sonic the Hedgehog 3 (2024)" rsync -avhP "/mnt/unraid/media/Movies/Sonic the Hedgehog 3 (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Die My Love (2025)" rsync -avhP "/mnt/synology/rs-movies/Die My Love (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Fatherhood (2021)" rsync -avhP "/mnt/unraid/media/Movies/Fatherhood (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Christmas Baby (2025)" rsync -avhP "/mnt/synology/rs-movies/The Christmas Baby (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Aladdin and the King of Thieves (1996)" rsync -avhP "/mnt/unraid/media/Movies/Aladdin and the King of Thieves (1996)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Live and Let Die (1973)" rsync -avhP "/mnt/unraid/media/Movies/Live and Let Die (1973)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Raging Bull (1980)" rsync -avhP "/mnt/synology/rs-movies/Raging Bull (1980)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Conspirator (2011)" rsync -avhP "/mnt/unraid/media/Movies/The Conspirator (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: A Garfield Christmas (1987)" rsync -avhP "/mnt/synology/rs-movies/A Garfield Christmas (1987)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Girl vs. Monster (2012)" rsync -avhP "/mnt/unraid/media/Movies/Girl vs. Monster (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Warrior (2011)" rsync -avhP "/mnt/unraid/media/Movies/Warrior (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Freaks (2019)" rsync -avhP "/mnt/synology/rs-movies/Freaks (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Falling Down (1993)" rsync -avhP "/mnt/unraid/media/Movies/Falling Down (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: DC Showcase Batman Death in the Family (2020)" rsync -avhP "/mnt/unraid/media/Movies/DC Showcase Batman Death in the Family (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Long Goodbye (2020)" rsync -avhP "/mnt/unraid/media/Movies/The Long Goodbye (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Lords of Chaos (2018)" rsync -avhP "/mnt/unraid/media/Movies/Lords of Chaos (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: North (1994)" rsync -avhP "/mnt/synology/rs-movies/North (1994)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Bourne Legacy (2012)" rsync -avhP "/mnt/unraid/media/Movies/The Bourne Legacy (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Geostorm (2017)" rsync -avhP "/mnt/unraid/media/Movies/Geostorm (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Batman Soul of the Dragon (2021)" rsync -avhP "/mnt/unraid/media/Movies/Batman Soul of the Dragon (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Mortal Instruments City of Bones (2013)" rsync -avhP "/mnt/unraid/media/Movies/The Mortal Instruments City of Bones (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dead Ringers (1988)" rsync -avhP "/mnt/synology/rs-movies/Dead Ringers (1988)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Cats (2019)" rsync -avhP "/mnt/synology/rs-movies/Cats (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Bully (2011)" rsync -avhP "/mnt/synology/rs-movies/Bully (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: An American Werewolf in Paris (1997)" rsync -avhP "/mnt/synology/rs-movies/An American Werewolf in Paris (1997)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: What Still Remains (2018)" rsync -avhP "/mnt/synology/rs-movies/What Still Remains (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Notting Hill (1999)" rsync -avhP "/mnt/unraid/media/Movies/Notting Hill (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Results (2015)" rsync -avhP "/mnt/synology/rs-movies/Results (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Trolls (2016)" rsync -avhP "/mnt/unraid/media/Movies/Trolls (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hotel Rwanda (2004)" rsync -avhP "/mnt/synology/rs-movies/Hotel Rwanda (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Old Way (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Old Way (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Porkys Revenge (1985)" rsync -avhP "/mnt/synology/rs-movies/Porkys Revenge (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Toy Story 4 (2019)" rsync -avhP "/mnt/unraid/media/Movies/Toy Story 4 (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: I Know What You Did Last Summer (2025)" rsync -avhP "/mnt/unraid/media/Movies/I Know What You Did Last Summer (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Fear of Rain (2021)" rsync -avhP "/mnt/synology/rs-movies/Fear of Rain (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Black Warrant (2022)" rsync -avhP "/mnt/synology/rs-movies/Black Warrant (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Safety Not Guaranteed (2012)" rsync -avhP "/mnt/synology/rs-movies/Safety Not Guaranteed (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Home Alone 2 Lost in New York (1992)" rsync -avhP "/mnt/unraid/media/Movies/Home Alone 2 Lost in New York (1992)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Spring Breakers (2013)" rsync -avhP "/mnt/unraid/media/Movies/Spring Breakers (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Skylines (2020)" rsync -avhP "/mnt/synology/rs-movies/Skylines (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Good Time (2017)" rsync -avhP "/mnt/unraid/media/Movies/Good Time (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Commando (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Commando (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: A Christmas Angel Match (2025)" rsync -avhP "/mnt/synology/rs-movies/A Christmas Angel Match (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Astronaut (2025)" rsync -avhP "/mnt/synology/rs-movies/Astronaut (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Levels (2024)" rsync -avhP "/mnt/unraid/media/Movies/Levels (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Hunt for Red October (1990)" rsync -avhP "/mnt/unraid/media/Movies/The Hunt for Red October (1990)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: You Me and Dupree (2006)" rsync -avhP "/mnt/unraid/media/Movies/You Me and Dupree (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Raya and the Last Dragon (2021)" rsync -avhP "/mnt/unraid/media/Movies/Raya and the Last Dragon (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Jack Frost (1998)" rsync -avhP "/mnt/synology/rs-movies/Jack Frost (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Hayride (2012)" rsync -avhP "/mnt/unraid/media/Movies/Hayride (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Soccer Football Movie (2022)" rsync -avhP "/mnt/synology/rs-movies/The Soccer Football Movie (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Jim Gaffigan King Baby (2009)" rsync -avhP "/mnt/synology/rs-movies/Jim Gaffigan King Baby (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Enchanted (2007)" rsync -avhP "/mnt/unraid/media/Movies/Enchanted (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Star Wars The Last Jedi (2017)" rsync -avhP "/mnt/unraid/media/Movies/Star Wars The Last Jedi (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Herbie Goes to Monte Carlo (1977)" rsync -avhP "/mnt/synology/rs-movies/Herbie Goes to Monte Carlo (1977)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Captive (2014)" rsync -avhP "/mnt/unraid/media/Movies/The Captive (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Wonderland (2003)" rsync -avhP "/mnt/synology/rs-movies/Wonderland (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Lady Killers (2004)" rsync -avhP "/mnt/synology/rs-movies/The Lady Killers (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Power of One (1992)" rsync -avhP "/mnt/unraid/media/Movies/The Power of One (1992)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: G.I. Joe Retaliation (2013)" rsync -avhP "/mnt/synology/rs-movies/G.I. Joe Retaliation (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Forgiven (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Forgiven (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Believer (2001)" rsync -avhP "/mnt/synology/rs-movies/The Believer (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: 22 Jump Street (2014)" rsync -avhP "/mnt/unraid/media/Movies/22 Jump Street (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Natures Colors with the Worlds Greatest Music (2007)" rsync -avhP "/mnt/synology/rs-movies/Natures Colors with the Worlds Greatest Music (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Sweeney (2012)" rsync -avhP "/mnt/synology/rs-movies/The Sweeney (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Wrong Turn 6 Last Resort (2014)" rsync -avhP "/mnt/synology/rs-movies/Wrong Turn 6 Last Resort (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Greatest Showman (2017)" rsync -avhP "/mnt/unraid/media/Movies/The Greatest Showman (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Shut In (2022)" rsync -avhP "/mnt/unraid/media/Movies/Shut In (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Space Cowboys (2000)" rsync -avhP "/mnt/unraid/media/Movies/Space Cowboys (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Ape vs Mecha Ape (2023)" rsync -avhP "/mnt/synology/rs-movies/Ape vs Mecha Ape (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Self and Others (2001)" rsync -avhP "/mnt/synology/rs-movies/Self and Others (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Apocalypto (2006)" rsync -avhP "/mnt/unraid/media/Movies/Apocalypto (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: EuroTrip (2004)" rsync -avhP "/mnt/unraid/media/Movies/EuroTrip (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Beverly Hills Cop II (1987)" rsync -avhP "/mnt/unraid/media/Movies/Beverly Hills Cop II (1987)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: El Dorado (1966)" rsync -avhP "/mnt/unraid/media/Movies/El Dorado (1966)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Forever My Girl (2018)" rsync -avhP "/mnt/synology/rs-movies/Forever My Girl (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Doom (2005)" rsync -avhP "/mnt/synology/rs-movies/Doom (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Silent Zone (2025)" rsync -avhP "/mnt/unraid/media/Movies/Silent Zone (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The X-Files (1998)" rsync -avhP "/mnt/synology/rs-movies/The X-Files (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Puss in Boots (2011)" rsync -avhP "/mnt/unraid/media/Movies/Puss in Boots (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Star Wars Episode I The Phantom Menace (1999)" rsync -avhP "/mnt/unraid/media/Movies/Star Wars Episode I The Phantom Menace (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Righteous (2021)" rsync -avhP "/mnt/unraid/media/Movies/The Righteous (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Front Room (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Front Room (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Weird Science (1985)" rsync -avhP "/mnt/unraid/media/Movies/Weird Science (1985)" "/mnt/synology/rs-4kmedia/4kmovies/"

run_cmd "Copy Ali->Chris: RocknRolla (2008)" rsync -avhP "/mnt/unraid/media/Movies/RocknRolla (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Infinite Storm (2022)" rsync -avhP "/mnt/unraid/media/Movies/Infinite Storm (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Game Plan (2007)" rsync -avhP "/mnt/unraid/media/Movies/The Game Plan (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Croupier (1998)" rsync -avhP "/mnt/unraid/media/Movies/Croupier (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Trust (2025)" rsync -avhP "/mnt/synology/rs-movies/Trust (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Alien (1979)" rsync -avhP "/mnt/unraid/media/Movies/Alien (1979)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Funhouse Massacre (2015)" rsync -avhP "/mnt/unraid/media/Movies/The Funhouse Massacre (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Blink Twice (2024)" rsync -avhP "/mnt/unraid/media/Movies/Blink Twice (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Ill Be Home for Christmas (2016)" rsync -avhP "/mnt/synology/rs-movies/Ill Be Home for Christmas (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: MaXXXine (2024)" rsync -avhP "/mnt/unraid/media/Movies/MaXXXine (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Cruel Intentions (1999)" rsync -avhP "/mnt/unraid/media/Movies/Cruel Intentions (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: A Passage to India (1984)" rsync -avhP "/mnt/unraid/media/Movies/A Passage to India (1984)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Blackcoats Daughter (2017)" rsync -avhP "/mnt/synology/rs-movies/The Blackcoats Daughter (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Craft Legacy (2020)" rsync -avhP "/mnt/synology/rs-movies/The Craft Legacy (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Street Fighter The Legend of Chun-Li (2009)" rsync -avhP "/mnt/synology/rs-movies/Street Fighter The Legend of Chun-Li (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Desperately Seeking Susan (1985)" rsync -avhP "/mnt/synology/rs-movies/Desperately Seeking Susan (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Hand That Rocks the Cradle (2025)" rsync -avhP "/mnt/synology/rs-movies/The Hand That Rocks the Cradle (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Oceans (2010)" rsync -avhP "/mnt/unraid/media/Movies/Oceans (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: V H S Beyond (2024)" rsync -avhP "/mnt/unraid/media/Movies/V H S Beyond (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Secret of My Success (1987)" rsync -avhP "/mnt/synology/rs-movies/The Secret of My Success (1987)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Gifted (2017)" rsync -avhP "/mnt/synology/rs-movies/Gifted (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: To End All War Oppenheimer and the Atomic Bomb (2023)" rsync -avhP "/mnt/unraid/media/Movies/To End All War Oppenheimer and the Atomic Bomb (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: In the Tall Grass (2019)" rsync -avhP "/mnt/synology/rs-movies/In the Tall Grass (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: When in Rome (2010)" rsync -avhP "/mnt/synology/rs-movies/When in Rome (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: She Wore a Yellow Ribbon (1949)" rsync -avhP "/mnt/synology/rs-movies/She Wore a Yellow Ribbon (1949)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Christmas at the Catnip Cafe (2025)" rsync -avhP "/mnt/synology/rs-movies/Christmas at the Catnip Cafe (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Beauty and the Beast (1991)" rsync -avhP "/mnt/unraid/media/Movies/Beauty and the Beast (1991)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Halo Legends (2010)" rsync -avhP "/mnt/synology/rs-movies/Halo Legends (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Journey of Natty Gann (1985)" rsync -avhP "/mnt/synology/rs-movies/The Journey of Natty Gann (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Elvira Mistress of the Dark (1988)" rsync -avhP "/mnt/synology/rs-movies/Elvira Mistress of the Dark (1988)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Swan Princess (1994)" rsync -avhP "/mnt/synology/rs-movies/The Swan Princess (1994)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Swan Song (2021)" rsync -avhP "/mnt/synology/rs-movies/Swan Song (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Halloween H20 20 Years Later (1998)" rsync -avhP "/mnt/synology/rs-movies/Halloween H20 20 Years Later (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Ali (2001)" rsync -avhP "/mnt/unraid/media/Movies/Ali (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Warlock (1959)" rsync -avhP "/mnt/synology/rs-movies/Warlock (1959)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Man Who Knew Too Much (1956)" rsync -avhP "/mnt/unraid/media/Movies/The Man Who Knew Too Much (1956)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: State of Play (2009)" rsync -avhP "/mnt/unraid/media/Movies/State of Play (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Blue Beetle (2023)" rsync -avhP "/mnt/unraid/media/Movies/Blue Beetle (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Last Breath (2025)" rsync -avhP "/mnt/unraid/media/Movies/Last Breath (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Their Finest (2017)" rsync -avhP "/mnt/synology/rs-movies/Their Finest (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Ironclad (2011)" rsync -avhP "/mnt/unraid/media/Movies/Ironclad (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Fire with Fire (2012)" rsync -avhP "/mnt/synology/rs-movies/Fire with Fire (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Interstellar (2014)" rsync -avhP "/mnt/unraid/media/Movies/Interstellar (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Black Cauldron (1985)" rsync -avhP "/mnt/synology/rs-movies/The Black Cauldron (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Tom Papa Youre Doing Great! (2020)" rsync -avhP "/mnt/synology/rs-movies/Tom Papa Youre Doing Great! (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Self less (2015)" rsync -avhP "/mnt/unraid/media/Movies/Self less (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Jack and Jill (2011)" rsync -avhP "/mnt/unraid/media/Movies/Jack and Jill (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Our House (2018)" rsync -avhP "/mnt/synology/rs-movies/Our House (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: I Love Trouble (1994)" rsync -avhP "/mnt/synology/rs-movies/I Love Trouble (1994)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: G20 (2025)" rsync -avhP "/mnt/unraid/media/Movies/G20 (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Settlers (2021)" rsync -avhP "/mnt/synology/rs-movies/Settlers (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Rise Blood Hunter (2007)" rsync -avhP "/mnt/synology/rs-movies/Rise Blood Hunter (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Vampire Hunter D Bloodlust (2001)" rsync -avhP "/mnt/synology/rs-movies/Vampire Hunter D Bloodlust (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Locksmith (2023)" rsync -avhP "/mnt/synology/rs-movies/The Locksmith (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: My Friend Dahmer (2017)" rsync -avhP "/mnt/synology/rs-movies/My Friend Dahmer (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: A Knights War (2025)" rsync -avhP "/mnt/synology/rs-movies/A Knights War (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Blacklight (2022)" rsync -avhP "/mnt/unraid/media/Movies/Blacklight (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Prom Pact (2023)" rsync -avhP "/mnt/synology/rs-movies/Prom Pact (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Disaster Artist (2017)" rsync -avhP "/mnt/unraid/media/Movies/The Disaster Artist (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Amen. (2002)" rsync -avhP "/mnt/synology/rs-movies/Amen. (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: PCU (1994)" rsync -avhP "/mnt/synology/rs-movies/PCU (1994)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Batman The Killing Joke (2016)" rsync -avhP "/mnt/synology/rs-movies/Batman The Killing Joke (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Crown for Christmas (2015)" rsync -avhP "/mnt/synology/rs-movies/Crown for Christmas (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Thomas Crown Affair (1999)" rsync -avhP "/mnt/synology/rs-movies/The Thomas Crown Affair (1999)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Land of the Dead (2005)" rsync -avhP "/mnt/unraid/media/Movies/Land of the Dead (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Night Teeth (2021)" rsync -avhP "/mnt/unraid/media/Movies/Night Teeth (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Pleasantville (1998)" rsync -avhP "/mnt/unraid/media/Movies/Pleasantville (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Star Trek Nemesis (2002)" rsync -avhP "/mnt/unraid/media/Movies/Star Trek Nemesis (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Puppet Master 5 (1994)" rsync -avhP "/mnt/synology/rs-movies/Puppet Master 5 (1994)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Little Shop of Horrors (1986)" rsync -avhP "/mnt/synology/rs-movies/Little Shop of Horrors (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Spirited Away (2001)" rsync -avhP "/mnt/synology/rs-movies/Spirited Away (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: F9 (2021)" rsync -avhP "/mnt/synology/rs-movies/F9 (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Fidelity (2019)" rsync -avhP "/mnt/unraid/media/Movies/Fidelity (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Breaking Away (1979)" rsync -avhP "/mnt/synology/rs-movies/Breaking Away (1979)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Malignant (2021)" rsync -avhP "/mnt/unraid/media/Movies/Malignant (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Big Lebowski (1998)" rsync -avhP "/mnt/unraid/media/Movies/The Big Lebowski (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Coyote Ugly (2000)" rsync -avhP "/mnt/synology/rs-movies/Coyote Ugly (2000)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Project Legion (2022)" rsync -avhP "/mnt/synology/rs-movies/Project Legion (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Jimmy Carr Funny Business (2016)" rsync -avhP "/mnt/unraid/media/Movies/Jimmy Carr Funny Business (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Chasing Mavericks (2012)" rsync -avhP "/mnt/unraid/media/Movies/Chasing Mavericks (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Courage Under Fire (1996)" rsync -avhP "/mnt/unraid/media/Movies/Courage Under Fire (1996)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Santa Class (2024)" rsync -avhP "/mnt/synology/rs-movies/The Santa Class (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Deathstalker (1983)" rsync -avhP "/mnt/synology/rs-movies/Deathstalker (1983)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Ill Be Right There (2024)" rsync -avhP "/mnt/unraid/media/Movies/Ill Be Right There (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Scalphunters (1968)" rsync -avhP "/mnt/synology/rs-movies/The Scalphunters (1968)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Red Planet (2000)" rsync -avhP "/mnt/synology/rs-movies/Red Planet (2000)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Voyeurs (2020)" rsync -avhP "/mnt/synology/rs-movies/Voyeurs (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Rat Race (2001)" rsync -avhP "/mnt/unraid/media/Movies/Rat Race (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Once Upon a Time. in Hollywood (2019)" rsync -avhP "/mnt/unraid/media/Movies/Once Upon a Time. in Hollywood (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Star Trek First Contact (1996)" rsync -avhP "/mnt/unraid/media/Movies/Star Trek First Contact (1996)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Unbelievable!!!!! (2020)" rsync -avhP "/mnt/synology/rs-movies/Unbelievable!!!!! (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Elemental (2023)" rsync -avhP "/mnt/unraid/media/Movies/Elemental (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Peggy Sue Got Married (1986)" rsync -avhP "/mnt/synology/rs-movies/Peggy Sue Got Married (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Would You Rather (2013)" rsync -avhP "/mnt/synology/rs-movies/Would You Rather (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Chernobyl Diaries (2012)" rsync -avhP "/mnt/synology/rs-movies/Chernobyl Diaries (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Armageddon (1998)" rsync -avhP "/mnt/unraid/media/Movies/Armageddon (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Revolutionary Road (2008)" rsync -avhP "/mnt/unraid/media/Movies/Revolutionary Road (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Father of the Bride Part II (1995)" rsync -avhP "/mnt/unraid/media/Movies/Father of the Bride Part II (1995)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Clown in a Cornfield (2025)" rsync -avhP "/mnt/unraid/media/Movies/Clown in a Cornfield (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Winchester (2018)" rsync -avhP "/mnt/unraid/media/Movies/Winchester (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Cant Hardly Wait (1998)" rsync -avhP "/mnt/unraid/media/Movies/Cant Hardly Wait (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Carrie (1976)" rsync -avhP "/mnt/unraid/media/Movies/Carrie (1976)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Bruno (2009)" rsync -avhP "/mnt/synology/rs-movies/Bruno (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Hairspray (2007)" rsync -avhP "/mnt/unraid/media/Movies/Hairspray (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: You Were Never Really Here (2017)" rsync -avhP "/mnt/synology/rs-movies/You Were Never Really Here (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Prospect (2018)" rsync -avhP "/mnt/synology/rs-movies/Prospect (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Good the Bad and the Ugly (1966)" rsync -avhP "/mnt/synology/rs-movies/The Good the Bad and the Ugly (1966)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Dungeons and Dragons Honor Among Thieves (2023)" rsync -avhP "/mnt/unraid/media/Movies/Dungeons and Dragons Honor Among Thieves (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: When Harry Met Sally. (1989)" rsync -avhP "/mnt/unraid/media/Movies/When Harry Met Sally. (1989)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Traveler (2010)" rsync -avhP "/mnt/synology/rs-movies/The Traveler (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: October Sky (1999)" rsync -avhP "/mnt/unraid/media/Movies/October Sky (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Imagine That (2009)" rsync -avhP "/mnt/synology/rs-movies/Imagine That (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Woodshock (2017)" rsync -avhP "/mnt/unraid/media/Movies/Woodshock (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Equilibrium (2002)" rsync -avhP "/mnt/unraid/media/Movies/Equilibrium (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Vault (2021)" rsync -avhP "/mnt/unraid/media/Movies/The Vault (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Monster High The Movie (2022)" rsync -avhP "/mnt/synology/rs-movies/Monster High The Movie (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Kiss Me Stupid (1964)" rsync -avhP "/mnt/synology/rs-movies/Kiss Me Stupid (1964)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Grandma (2015)" rsync -avhP "/mnt/synology/rs-movies/Grandma (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: A Beautiful Day in the Neighborhood (2019)" rsync -avhP "/mnt/unraid/media/Movies/A Beautiful Day in the Neighborhood (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Spine of Night (2021)" rsync -avhP "/mnt/synology/rs-movies/The Spine of Night (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Children Act (2018)" rsync -avhP "/mnt/unraid/media/Movies/The Children Act (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Indiana Jones and the Kingdom of the Crystal Skull (2008)" rsync -avhP "/mnt/unraid/media/Movies/Indiana Jones and the Kingdom of the Crystal Skull (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: See You Up There (2017)" rsync -avhP "/mnt/unraid/media/Movies/See You Up There (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Cut Bank (2014)" rsync -avhP "/mnt/unraid/media/Movies/Cut Bank (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Saving Private Ryan (1998)" rsync -avhP "/mnt/unraid/media/Movies/Saving Private Ryan (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Murder Mystery (2019)" rsync -avhP "/mnt/unraid/media/Movies/Murder Mystery (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Oy to the World (2025)" rsync -avhP "/mnt/synology/rs-movies/Oy to the World (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Shade (2003)" rsync -avhP "/mnt/synology/rs-movies/Shade (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Firestarter (1984)" rsync -avhP "/mnt/synology/rs-movies/Firestarter (1984)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: A Compassionate Spy (2022)" rsync -avhP "/mnt/synology/rs-movies/A Compassionate Spy (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Father of the Year (2018)" rsync -avhP "/mnt/synology/rs-movies/Father of the Year (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Vampire Academy (2014)" rsync -avhP "/mnt/synology/rs-movies/Vampire Academy (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Mindhunters (2004)" rsync -avhP "/mnt/synology/rs-movies/Mindhunters (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Chris D'Elia Incorrigible (2015)" rsync -avhP "/mnt/synology/rs-movies/Chris D'Elia Incorrigible (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Official Competition (2021)" rsync -avhP "/mnt/synology/rs-movies/Official Competition (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Sunshine (1999)" rsync -avhP "/mnt/unraid/media/Movies/Sunshine (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Expendables 3 (2014)" rsync -avhP "/mnt/unraid/media/Movies/The Expendables 3 (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Justice League The Flashpoint Paradox (2013)" rsync -avhP "/mnt/unraid/media/Movies/Justice League The Flashpoint Paradox (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: My Sisters Keeper (2009)" rsync -avhP "/mnt/synology/rs-movies/My Sisters Keeper (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Insomnia (2002)" rsync -avhP "/mnt/synology/rs-movies/Insomnia (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Gleaming the Cube (1989)" rsync -avhP "/mnt/synology/rs-movies/Gleaming the Cube (1989)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Martian (2015)" rsync -avhP "/mnt/unraid/media/Movies/The Martian (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Misery (1990)" rsync -avhP "/mnt/synology/rs-movies/Misery (1990)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Shining (1980)" rsync -avhP "/mnt/unraid/media/Movies/The Shining (1980)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Mummy (1999)" rsync -avhP "/mnt/synology/rs-movies/The Mummy (1999)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Joe (2014)" rsync -avhP "/mnt/synology/rs-movies/Joe (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Invitation (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Invitation (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Maria (2024)" rsync -avhP "/mnt/unraid/media/Movies/Maria (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Megamind vs. the Doom Syndicate (2024)" rsync -avhP "/mnt/synology/rs-movies/Megamind vs. the Doom Syndicate (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Hurt Locker (2008)" rsync -avhP "/mnt/unraid/media/Movies/The Hurt Locker (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: St. Elmos Fire (1985)" rsync -avhP "/mnt/unraid/media/Movies/St. Elmos Fire (1985)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Turbulence (2025)" rsync -avhP "/mnt/unraid/media/Movies/Turbulence (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The King (2019)" rsync -avhP "/mnt/unraid/media/Movies/The King (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: 30 Days of Night (2007)" rsync -avhP "/mnt/unraid/media/Movies/30 Days of Night (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Geralds Game (2017)" rsync -avhP "/mnt/unraid/media/Movies/Geralds Game (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Mr. Hobbs Takes a Vacation (1962)" rsync -avhP "/mnt/synology/rs-movies/Mr. Hobbs Takes a Vacation (1962)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Lawnmower Man (1992)" rsync -avhP "/mnt/synology/rs-movies/The Lawnmower Man (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Groundhog Day (1993)" rsync -avhP "/mnt/unraid/media/Movies/Groundhog Day (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Bugsy (1991)" rsync -avhP "/mnt/unraid/media/Movies/Bugsy (1991)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Wrecked (2010)" rsync -avhP "/mnt/synology/rs-movies/Wrecked (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Vacation Friends 2 (2023)" rsync -avhP "/mnt/unraid/media/Movies/Vacation Friends 2 (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Outside the Wire (2021)" rsync -avhP "/mnt/unraid/media/Movies/Outside the Wire (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Cinderella (2015)" rsync -avhP "/mnt/unraid/media/Movies/Cinderella (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Bullet Train (2022)" rsync -avhP "/mnt/unraid/media/Movies/Bullet Train (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Black Site (2022)" rsync -avhP "/mnt/unraid/media/Movies/Black Site (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Home (2015)" rsync -avhP "/mnt/synology/rs-movies/Home (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Monuments Men (2014)" rsync -avhP "/mnt/unraid/media/Movies/The Monuments Men (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Teenage Mutant Ninja Turtles III (1993)" rsync -avhP "/mnt/unraid/media/Movies/Teenage Mutant Ninja Turtles III (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Predator (2018)" rsync -avhP "/mnt/synology/rs-movies/The Predator (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Raise the Titanic (1980)" rsync -avhP "/mnt/synology/rs-movies/Raise the Titanic (1980)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Project Gemini (2022)" rsync -avhP "/mnt/unraid/media/Movies/Project Gemini (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Kingsman The Secret Service (2015)" rsync -avhP "/mnt/unraid/media/Movies/Kingsman The Secret Service (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Break-Up (2006)" rsync -avhP "/mnt/unraid/media/Movies/The Break-Up (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: First Reformed (2018)" rsync -avhP "/mnt/unraid/media/Movies/First Reformed (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Killers of the Flower Moon (2023)" rsync -avhP "/mnt/unraid/media/Movies/Killers of the Flower Moon (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Resident Evil Afterlife (2010)" rsync -avhP "/mnt/unraid/media/Movies/Resident Evil Afterlife (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: For Your Eyes Only (1981)" rsync -avhP "/mnt/synology/rs-movies/For Your Eyes Only (1981)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Paws of Fury The Legend of Hank (2022)" rsync -avhP "/mnt/unraid/media/Movies/Paws of Fury The Legend of Hank (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Fall (2022)" rsync -avhP "/mnt/unraid/media/Movies/Fall (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Nightmare Before Christmas (1993)" rsync -avhP "/mnt/unraid/media/Movies/The Nightmare Before Christmas (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Rebel Without a Cause (1955)" rsync -avhP "/mnt/unraid/media/Movies/Rebel Without a Cause (1955)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Last Unicorn (1982)" rsync -avhP "/mnt/synology/rs-movies/The Last Unicorn (1982)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Mr. Magoo (1997)" rsync -avhP "/mnt/synology/rs-movies/Mr. Magoo (1997)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Baywatch (2017)" rsync -avhP "/mnt/unraid/media/Movies/Baywatch (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Sleuth (2007)" rsync -avhP "/mnt/synology/rs-movies/Sleuth (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Lee (2024)" rsync -avhP "/mnt/unraid/media/Movies/Lee (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Santa Clause 2 (2002)" rsync -avhP "/mnt/synology/rs-movies/The Santa Clause 2 (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Eileen (2023)" rsync -avhP "/mnt/unraid/media/Movies/Eileen (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Visit (2015)" rsync -avhP "/mnt/synology/rs-movies/The Visit (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Paul (2011)" rsync -avhP "/mnt/synology/rs-movies/Paul (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Mickeys Christmas Carol (1983)" rsync -avhP "/mnt/synology/rs-movies/Mickeys Christmas Carol (1983)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Purple Rain (1984)" rsync -avhP "/mnt/synology/rs-movies/Purple Rain (1984)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Logan (2017)" rsync -avhP "/mnt/unraid/media/Movies/Logan (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Star Trek Renegades (2015)" rsync -avhP "/mnt/synology/rs-movies/Star Trek Renegades (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Saw (2004)" rsync -avhP "/mnt/unraid/media/Movies/Saw (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dream a Little Dream (1989)" rsync -avhP "/mnt/synology/rs-movies/Dream a Little Dream (1989)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Volition (2019)" rsync -avhP "/mnt/synology/rs-movies/Volition (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Teenage Mutant Ninja Turtles II The Secret of the Ooze (1991)" rsync -avhP "/mnt/synology/rs-movies/Teenage Mutant Ninja Turtles II The Secret of the Ooze (1991)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Legend (1985)" rsync -avhP "/mnt/synology/rs-movies/Legend (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Captive State (2019)" rsync -avhP "/mnt/synology/rs-movies/Captive State (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Come True (2020)" rsync -avhP "/mnt/synology/rs-movies/Come True (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Extremely Loud and Incredibly Close (2011)" rsync -avhP "/mnt/synology/rs-movies/Extremely Loud and Incredibly Close (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Fantastic Beasts and Where to Find Them (2016)" rsync -avhP "/mnt/unraid/media/Movies/Fantastic Beasts and Where to Find Them (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Let It Shine (2012)" rsync -avhP "/mnt/unraid/media/Movies/Let It Shine (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Frankenweenie (2012)" rsync -avhP "/mnt/unraid/media/Movies/Frankenweenie (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Siege of Jadotville (2016)" rsync -avhP "/mnt/unraid/media/Movies/The Siege of Jadotville (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Other Guys (2010)" rsync -avhP "/mnt/unraid/media/Movies/The Other Guys (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Quigley Down Under (1990)" rsync -avhP "/mnt/synology/rs-movies/Quigley Down Under (1990)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Tell Me Who I Am (2019)" rsync -avhP "/mnt/unraid/media/Movies/Tell Me Who I Am (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Friendship (2025)" rsync -avhP "/mnt/unraid/media/Movies/Friendship (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: A Ghost Story (2017)" rsync -avhP "/mnt/unraid/media/Movies/A Ghost Story (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Hidden (1987)" rsync -avhP "/mnt/unraid/media/Movies/The Hidden (1987)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Creepshow (1982)" rsync -avhP "/mnt/synology/rs-movies/Creepshow (1982)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Fast and Furious Presents Hobbs and Shaw (2019)" rsync -avhP "/mnt/unraid/media/Movies/Fast and Furious Presents Hobbs and Shaw (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Havoc (2005)" rsync -avhP "/mnt/synology/rs-movies/Havoc (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Harry Potter and the Goblet of Fire (2005)" rsync -avhP "/mnt/unraid/media/Movies/Harry Potter and the Goblet of Fire (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Eat Pray Love (2010)" rsync -avhP "/mnt/synology/rs-movies/Eat Pray Love (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Joe Versus the Volcano (1990)" rsync -avhP "/mnt/synology/rs-movies/Joe Versus the Volcano (1990)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Bert Kreischer Lucky (2025)" rsync -avhP "/mnt/synology/rs-movies/Bert Kreischer Lucky (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Love at First Sight (2023)" rsync -avhP "/mnt/synology/rs-movies/Love at First Sight (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Handling the Undead (2024)" rsync -avhP "/mnt/unraid/media/Movies/Handling the Undead (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Blowback (2022)" rsync -avhP "/mnt/synology/rs-movies/Blowback (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Long Distance (2024)" rsync -avhP "/mnt/unraid/media/Movies/Long Distance (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Others (2001)" rsync -avhP "/mnt/unraid/media/Movies/The Others (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Comancheros (1961)" rsync -avhP "/mnt/synology/rs-movies/The Comancheros (1961)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Nozomi Witches (1990)" rsync -avhP "/mnt/synology/rs-movies/Nozomi Witches (1990)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Murina (2022)" rsync -avhP "/mnt/unraid/media/Movies/Murina (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Krisha (2016)" rsync -avhP "/mnt/unraid/media/Movies/Krisha (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Jurassic World (2015)" rsync -avhP "/mnt/unraid/media/Movies/Jurassic World (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Kingdom of the Planet of the Apes (2024)" rsync -avhP "/mnt/unraid/media/Movies/Kingdom of the Planet of the Apes (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Royal-ish (2025)" rsync -avhP "/mnt/synology/rs-movies/Royal-ish (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Ice Cream Man (1995)" rsync -avhP "/mnt/synology/rs-movies/Ice Cream Man (1995)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Princess Diaries 2 Royal Engagement (2004)" rsync -avhP "/mnt/unraid/media/Movies/The Princess Diaries 2 Royal Engagement (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Fantastic Beasts The Secrets of Dumbledore (2022)" rsync -avhP "/mnt/unraid/media/Movies/Fantastic Beasts The Secrets of Dumbledore (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Undisputed (2002)" rsync -avhP "/mnt/synology/rs-movies/Undisputed (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Ghost Dog The Way of the Samurai (1999)" rsync -avhP "/mnt/unraid/media/Movies/Ghost Dog The Way of the Samurai (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Night Shift (2023)" rsync -avhP "/mnt/unraid/media/Movies/Night Shift (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Legend of Billie Jean (1985)" rsync -avhP "/mnt/synology/rs-movies/The Legend of Billie Jean (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Breakfast at Tiffany's (1961)" rsync -avhP "/mnt/synology/rs-movies/Breakfast at Tiffany's (1961)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Six Days Seven Nights (1998)" rsync -avhP "/mnt/unraid/media/Movies/Six Days Seven Nights (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Runner Runner (2013)" rsync -avhP "/mnt/synology/rs-movies/Runner Runner (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Host (2020)" rsync -avhP "/mnt/synology/rs-movies/Host (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Devils Rejects (2005)" rsync -avhP "/mnt/synology/rs-movies/The Devils Rejects (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Drive-Away Dolls (2024)" rsync -avhP "/mnt/unraid/media/Movies/Drive-Away Dolls (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Kneecap (2024)" rsync -avhP "/mnt/unraid/media/Movies/Kneecap (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Fighter (2010)" rsync -avhP "/mnt/unraid/media/Movies/The Fighter (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Girlfriend Experience (2009)" rsync -avhP "/mnt/unraid/media/Movies/The Girlfriend Experience (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Air Bud Golden Receiver (1998)" rsync -avhP "/mnt/synology/rs-movies/Air Bud Golden Receiver (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Old Guy (2024)" rsync -avhP "/mnt/unraid/media/Movies/Old Guy (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Big Jake (1971)" rsync -avhP "/mnt/synology/rs-movies/Big Jake (1971)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Road to Paloma (2014)" rsync -avhP "/mnt/synology/rs-movies/Road to Paloma (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: All the Beauty and the Bloodshed (2022)" rsync -avhP "/mnt/synology/rs-movies/All the Beauty and the Bloodshed (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Assignment (2016)" rsync -avhP "/mnt/unraid/media/Movies/The Assignment (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Monster Hunter (2020)" rsync -avhP "/mnt/unraid/media/Movies/Monster Hunter (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Van Helsing (2004)" rsync -avhP "/mnt/unraid/media/Movies/Van Helsing (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: X-Men First Class (2011)" rsync -avhP "/mnt/unraid/media/Movies/X-Men First Class (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Space Jam A New Legacy (2021)" rsync -avhP "/mnt/unraid/media/Movies/Space Jam A New Legacy (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Mummy Returns (2001)" rsync -avhP "/mnt/unraid/media/Movies/The Mummy Returns (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Book of Eli (2010)" rsync -avhP "/mnt/synology/rs-movies/The Book of Eli (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Rambo First Blood Part II (1985)" rsync -avhP "/mnt/unraid/media/Movies/Rambo First Blood Part II (1985)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Palm Springs (2020)" rsync -avhP "/mnt/unraid/media/Movies/Palm Springs (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Grown Ups (2010)" rsync -avhP "/mnt/synology/rs-movies/Grown Ups (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Confessions of a Christmas Letter (2024)" rsync -avhP "/mnt/synology/rs-movies/Confessions of a Christmas Letter (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Coach Carter (2005)" rsync -avhP "/mnt/unraid/media/Movies/Coach Carter (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Star Trek Generations (1994)" rsync -avhP "/mnt/unraid/media/Movies/Star Trek Generations (1994)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Company of Heroes (2013)" rsync -avhP "/mnt/synology/rs-movies/Company of Heroes (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: You Only Live Twice (1967)" rsync -avhP "/mnt/unraid/media/Movies/You Only Live Twice (1967)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Patriot Games (1992)" rsync -avhP "/mnt/unraid/media/Movies/Patriot Games (1992)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Hobbit An Unexpected Journey (2012)" rsync -avhP "/mnt/unraid/media/Movies/The Hobbit An Unexpected Journey (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Menu (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Menu (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Cobweb (2023)" rsync -avhP "/mnt/unraid/media/Movies/Cobweb (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Necessary Roughness (1991)" rsync -avhP "/mnt/synology/rs-movies/Necessary Roughness (1991)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Polite Society (2023)" rsync -avhP "/mnt/synology/rs-movies/Polite Society (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Wrath of the Titans (2012)" rsync -avhP "/mnt/unraid/media/Movies/Wrath of the Titans (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Post (2017)" rsync -avhP "/mnt/unraid/media/Movies/The Post (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Ambushers (1967)" rsync -avhP "/mnt/synology/rs-movies/The Ambushers (1967)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Cloverfield Paradox (2018)" rsync -avhP "/mnt/unraid/media/Movies/The Cloverfield Paradox (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Madagascar (2005)" rsync -avhP "/mnt/unraid/media/Movies/Madagascar (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Settlers (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Settlers (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Goon (2012)" rsync -avhP "/mnt/synology/rs-movies/Goon (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Malcolm X (1992)" rsync -avhP "/mnt/unraid/media/Movies/Malcolm X (1992)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Life After Beth (2014)" rsync -avhP "/mnt/unraid/media/Movies/Life After Beth (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: One for the Money (2012)" rsync -avhP "/mnt/synology/rs-movies/One for the Money (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: A Long Goodbye (2019)" rsync -avhP "/mnt/synology/rs-movies/A Long Goodbye (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Paranormal Activity 2 (2010)" rsync -avhP "/mnt/unraid/media/Movies/Paranormal Activity 2 (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Lego Ninjago Movie (2017)" rsync -avhP "/mnt/unraid/media/Movies/The Lego Ninjago Movie (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Minari (2021)" rsync -avhP "/mnt/unraid/media/Movies/Minari (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Conference (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Conference (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Borat Subsequent Moviefilm (2020)" rsync -avhP "/mnt/unraid/media/Movies/Borat Subsequent Moviefilm (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Sicario Day of the Soldado (2018)" rsync -avhP "/mnt/unraid/media/Movies/Sicario Day of the Soldado (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Guernsey Literary and Potato Peel Pie Society (2018)" rsync -avhP "/mnt/unraid/media/Movies/The Guernsey Literary and Potato Peel Pie Society (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Scary Movie 2 (2001)" rsync -avhP "/mnt/synology/rs-movies/Scary Movie 2 (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Nefarious (2023)" rsync -avhP "/mnt/unraid/media/Movies/Nefarious (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Kraven the Hunter (2024)" rsync -avhP "/mnt/unraid/media/Movies/Kraven the Hunter (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Shall We Dance (2004)" rsync -avhP "/mnt/synology/rs-movies/Shall We Dance (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Christmas Above the Clouds (2025)" rsync -avhP "/mnt/synology/rs-movies/Christmas Above the Clouds (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Gretel and Hansel (2020)" rsync -avhP "/mnt/synology/rs-movies/Gretel and Hansel (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Final Destination 3 (2006)" rsync -avhP "/mnt/synology/rs-movies/Final Destination 3 (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Bird Box (2018)" rsync -avhP "/mnt/unraid/media/Movies/Bird Box (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dragon Blade (2015)" rsync -avhP "/mnt/unraid/media/Movies/Dragon Blade (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Ip Man 2 (2010)" rsync -avhP "/mnt/synology/rs-movies/Ip Man 2 (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Crossing Over (2009)" rsync -avhP "/mnt/synology/rs-movies/Crossing Over (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Life (2017)" rsync -avhP "/mnt/unraid/media/Movies/Life (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: American Ninja (1985)" rsync -avhP "/mnt/synology/rs-movies/American Ninja (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Holiday (2006)" rsync -avhP "/mnt/unraid/media/Movies/The Holiday (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Cursed (2021)" rsync -avhP "/mnt/synology/rs-movies/Cursed (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Hats Off to Christmas! (2013)" rsync -avhP "/mnt/synology/rs-movies/Hats Off to Christmas! (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Undisputed III Redemption (2010)" rsync -avhP "/mnt/synology/rs-movies/Undisputed III Redemption (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: City of God (2002)" rsync -avhP "/mnt/unraid/media/Movies/City of God (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Polar (2019)" rsync -avhP "/mnt/synology/rs-movies/Polar (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: 10 Cloverfield Lane (2016)" rsync -avhP "/mnt/unraid/media/Movies/10 Cloverfield Lane (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Midsommar (2019)" rsync -avhP "/mnt/unraid/media/Movies/Midsommar (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Sleepaway Camp III Teenage Wasteland (1989)" rsync -avhP "/mnt/synology/rs-movies/Sleepaway Camp III Teenage Wasteland (1989)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Get Carter (2000)" rsync -avhP "/mnt/synology/rs-movies/Get Carter (2000)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Restraint (2008)" rsync -avhP "/mnt/unraid/media/Movies/Restraint (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Shaun of the Dead (2004)" rsync -avhP "/mnt/unraid/media/Movies/Shaun of the Dead (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Great Mouse Detective (1986)" rsync -avhP "/mnt/synology/rs-movies/The Great Mouse Detective (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Cool Hand Luke (1967)" rsync -avhP "/mnt/unraid/media/Movies/Cool Hand Luke (1967)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Sing 2 (2021)" rsync -avhP "/mnt/unraid/media/Movies/Sing 2 (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: High Crimes (2002)" rsync -avhP "/mnt/synology/rs-movies/High Crimes (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Nightmare Alley (2021)" rsync -avhP "/mnt/unraid/media/Movies/Nightmare Alley (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Ride Along 2 (2016)" rsync -avhP "/mnt/unraid/media/Movies/Ride Along 2 (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Jurassic World Rebirth (2025)" rsync -avhP "/mnt/unraid/media/Movies/Jurassic World Rebirth (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Tall in the Saddle (1944)" rsync -avhP "/mnt/synology/rs-movies/Tall in the Saddle (1944)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Witcher Sirens of the Deep (2025)" rsync -avhP "/mnt/unraid/media/Movies/The Witcher Sirens of the Deep (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The First Slam Dunk (2022)" rsync -avhP "/mnt/synology/rs-movies/The First Slam Dunk (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Battleship Potemkin (1925)" rsync -avhP "/mnt/unraid/media/Movies/Battleship Potemkin (1925)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Bert Kreischer Razzle Dazzle (2023)" rsync -avhP "/mnt/synology/rs-movies/Bert Kreischer Razzle Dazzle (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Petes Dragon (1977)" rsync -avhP "/mnt/synology/rs-movies/Petes Dragon (1977)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Twixt (2011)" rsync -avhP "/mnt/synology/rs-movies/Twixt (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Traffic (2000)" rsync -avhP "/mnt/unraid/media/Movies/Traffic (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Will Penny (1967)" rsync -avhP "/mnt/synology/rs-movies/Will Penny (1967)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Inheritance (2025)" rsync -avhP "/mnt/unraid/media/Movies/Inheritance (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Trauma Center (2019)" rsync -avhP "/mnt/synology/rs-movies/Trauma Center (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The King of Staten Island (2020)" rsync -avhP "/mnt/synology/rs-movies/The King of Staten Island (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Little Things (2021)" rsync -avhP "/mnt/unraid/media/Movies/The Little Things (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Jason Goes to Hell The Final Friday (1993)" rsync -avhP "/mnt/synology/rs-movies/Jason Goes to Hell The Final Friday (1993)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Infinity Pool (2023)" rsync -avhP "/mnt/unraid/media/Movies/Infinity Pool (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Captain Ron (1992)" rsync -avhP "/mnt/synology/rs-movies/Captain Ron (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: American Hustle (2013)" rsync -avhP "/mnt/unraid/media/Movies/American Hustle (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Ghostbusters (2016)" rsync -avhP "/mnt/unraid/media/Movies/Ghostbusters (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Sex Tape (2014)" rsync -avhP "/mnt/synology/rs-movies/Sex Tape (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Weird The Al Yankovic Story (2022)" rsync -avhP "/mnt/unraid/media/Movies/Weird The Al Yankovic Story (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hack-O-Lantern (1988)" rsync -avhP "/mnt/synology/rs-movies/Hack-O-Lantern (1988)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Batman Returns (1992)" rsync -avhP "/mnt/unraid/media/Movies/Batman Returns (1992)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Nosferatu (2024)" rsync -avhP "/mnt/unraid/media/Movies/Nosferatu (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: North Country (2005)" rsync -avhP "/mnt/synology/rs-movies/North Country (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Christmas at Dollywood (2019)" rsync -avhP "/mnt/synology/rs-movies/Christmas at Dollywood (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Bud Abbott and Lou Costello Meet the Invisible Man (1951)" rsync -avhP "/mnt/synology/rs-movies/Bud Abbott and Lou Costello Meet the Invisible Man (1951)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Wander (2020)" rsync -avhP "/mnt/unraid/media/Movies/Wander (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Rounders (1998)" rsync -avhP "/mnt/unraid/media/Movies/Rounders (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Transformers Dark of the Moon (2011)" rsync -avhP "/mnt/synology/rs-movies/Transformers Dark of the Moon (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Dumb and Dumber To (2014)" rsync -avhP "/mnt/synology/rs-movies/Dumb and Dumber To (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Adventures of Huck Finn (1993)" rsync -avhP "/mnt/unraid/media/Movies/The Adventures of Huck Finn (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Star Trek II The Wrath of Khan (1982)" rsync -avhP "/mnt/unraid/media/Movies/Star Trek II The Wrath of Khan (1982)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: T-34 (2018)" rsync -avhP "/mnt/synology/rs-movies/T-34 (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Layover (2017)" rsync -avhP "/mnt/unraid/media/Movies/The Layover (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Wandering Earth (2019)" rsync -avhP "/mnt/unraid/media/Movies/The Wandering Earth (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Its Such a Beautiful Day (2012)" rsync -avhP "/mnt/unraid/media/Movies/Its Such a Beautiful Day (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Snitch (2013)" rsync -avhP "/mnt/unraid/media/Movies/Snitch (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Freaked (1993)" rsync -avhP "/mnt/synology/rs-movies/Freaked (1993)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: American Ninja 2 The Confrontation (1987)" rsync -avhP "/mnt/synology/rs-movies/American Ninja 2 The Confrontation (1987)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Wanderlust (2012)" rsync -avhP "/mnt/synology/rs-movies/Wanderlust (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Best Little Whorehouse in Texas (1982)" rsync -avhP "/mnt/synology/rs-movies/The Best Little Whorehouse in Texas (1982)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Speed (1994)" rsync -avhP "/mnt/unraid/media/Movies/Speed (1994)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Mr. Baseball (1992)" rsync -avhP "/mnt/synology/rs-movies/Mr. Baseball (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Bert Kreischer Hey Big Boy (2020)" rsync -avhP "/mnt/synology/rs-movies/Bert Kreischer Hey Big Boy (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Black Phone (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Black Phone (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Exorcist (1973)" rsync -avhP "/mnt/unraid/media/Movies/The Exorcist (1973)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Constantine City of Demons The Movie (2018)" rsync -avhP "/mnt/synology/rs-movies/Constantine City of Demons The Movie (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Rushmore (1998)" rsync -avhP "/mnt/synology/rs-movies/Rushmore (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Freedom Writers (2007)" rsync -avhP "/mnt/synology/rs-movies/Freedom Writers (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: True Lies (1994)" rsync -avhP "/mnt/unraid/media/Movies/True Lies (1994)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Appleseed Alpha (2014)" rsync -avhP "/mnt/synology/rs-movies/Appleseed Alpha (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Blue Lagoon (1980)" rsync -avhP "/mnt/synology/rs-movies/The Blue Lagoon (1980)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Twin Sisters (2002)" rsync -avhP "/mnt/unraid/media/Movies/Twin Sisters (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Equalizer 2 (2018)" rsync -avhP "/mnt/unraid/media/Movies/The Equalizer 2 (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Damsel (2018)" rsync -avhP "/mnt/synology/rs-movies/Damsel (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Cheech and Chongs Last Movie (2025)" rsync -avhP "/mnt/synology/rs-movies/Cheech and Chongs Last Movie (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Mixed Nuts (1994)" rsync -avhP "/mnt/synology/rs-movies/Mixed Nuts (1994)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Snow Must Go On (2025)" rsync -avhP "/mnt/synology/rs-movies/The Snow Must Go On (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Big Chill (1983)" rsync -avhP "/mnt/synology/rs-movies/The Big Chill (1983)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Major League II (1994)" rsync -avhP "/mnt/synology/rs-movies/Major League II (1994)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Matt Rife Natural Selection (2023)" rsync -avhP "/mnt/synology/rs-movies/Matt Rife Natural Selection (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Hotel Room (2003)" rsync -avhP "/mnt/synology/rs-movies/The Hotel Room (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Between Worlds (2018)" rsync -avhP "/mnt/synology/rs-movies/Between Worlds (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Lilo and Stitch (2025)" rsync -avhP "/mnt/unraid/media/Movies/Lilo and Stitch (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Guns Akimbo (2020)" rsync -avhP "/mnt/unraid/media/Movies/Guns Akimbo (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Equalizer 3 (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Equalizer 3 (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Invention of Lying (2009)" rsync -avhP "/mnt/synology/rs-movies/The Invention of Lying (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Shane (1953)" rsync -avhP "/mnt/synology/rs-movies/Shane (1953)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Summer Rental (1985)" rsync -avhP "/mnt/unraid/media/Movies/Summer Rental (1985)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Jack Reacher Never Go Back (2016)" rsync -avhP "/mnt/unraid/media/Movies/Jack Reacher Never Go Back (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Beauty and the Beast (2017)" rsync -avhP "/mnt/unraid/media/Movies/Beauty and the Beast (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Lone Survivor (2013)" rsync -avhP "/mnt/unraid/media/Movies/Lone Survivor (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Unhuman (2022)" rsync -avhP "/mnt/unraid/media/Movies/Unhuman (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Meg 2 The Trench (2023)" rsync -avhP "/mnt/unraid/media/Movies/Meg 2 The Trench (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: American Gangster (2007)" rsync -avhP "/mnt/unraid/media/Movies/American Gangster (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: A Christmas Prince The Royal Baby (2019)" rsync -avhP "/mnt/synology/rs-movies/A Christmas Prince The Royal Baby (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Infinite (2021)" rsync -avhP "/mnt/unraid/media/Movies/Infinite (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Tactical Force (2011)" rsync -avhP "/mnt/synology/rs-movies/Tactical Force (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Prey (2022)" rsync -avhP "/mnt/unraid/media/Movies/Prey (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Aliens Expanded (2024)" rsync -avhP "/mnt/synology/rs-movies/Aliens Expanded (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Master (2012)" rsync -avhP "/mnt/unraid/media/Movies/The Master (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Introducing Selma Blair (2021)" rsync -avhP "/mnt/synology/rs-movies/Introducing Selma Blair (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: A Bridge Too Far (1977)" rsync -avhP "/mnt/unraid/media/Movies/A Bridge Too Far (1977)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Piglet (2025)" rsync -avhP "/mnt/synology/rs-movies/Piglet (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Changeland (2019)" rsync -avhP "/mnt/unraid/media/Movies/Changeland (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Rhinestone (1984)" rsync -avhP "/mnt/synology/rs-movies/Rhinestone (1984)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Damaged (2024)" rsync -avhP "/mnt/unraid/media/Movies/Damaged (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Paper Man (2009)" rsync -avhP "/mnt/synology/rs-movies/Paper Man (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: 42 (2013)" rsync -avhP "/mnt/synology/rs-movies/42 (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: My Girl (1991)" rsync -avhP "/mnt/synology/rs-movies/My Girl (1991)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: American Psycho (2000)" rsync -avhP "/mnt/unraid/media/Movies/American Psycho (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Puppy Love (2023)" rsync -avhP "/mnt/unraid/media/Movies/Puppy Love (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: High School Musical (2006)" rsync -avhP "/mnt/unraid/media/Movies/High School Musical (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Shoot 'Em Up (2007)" rsync -avhP "/mnt/synology/rs-movies/Shoot 'Em Up (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: XX (2017)" rsync -avhP "/mnt/synology/rs-movies/XX (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Mother Night (1996)" rsync -avhP "/mnt/unraid/media/Movies/Mother Night (1996)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Black Widow (2021)" rsync -avhP "/mnt/unraid/media/Movies/Black Widow (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Poltergeist II The Other Side (1986)" rsync -avhP "/mnt/synology/rs-movies/Poltergeist II The Other Side (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: In Time (2011)" rsync -avhP "/mnt/unraid/media/Movies/In Time (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Smokey and the Bandit (1977)" rsync -avhP "/mnt/unraid/media/Movies/Smokey and the Bandit (1977)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Lost Battalion (2001)" rsync -avhP "/mnt/synology/rs-movies/The Lost Battalion (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Buddha Mountain (2011)" rsync -avhP "/mnt/unraid/media/Movies/Buddha Mountain (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Arthur (2011)" rsync -avhP "/mnt/synology/rs-movies/Arthur (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: American Assassin (2017)" rsync -avhP "/mnt/unraid/media/Movies/American Assassin (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Driven (2001)" rsync -avhP "/mnt/synology/rs-movies/Driven (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Bambi (1942)" rsync -avhP "/mnt/synology/rs-movies/Bambi (1942)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Rumor Has It. (2005)" rsync -avhP "/mnt/unraid/media/Movies/Rumor Has It. (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Strangers Chapter 1 (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Strangers Chapter 1 (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Eraser (1996)" rsync -avhP "/mnt/unraid/media/Movies/Eraser (1996)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Apollo 11 (2019)" rsync -avhP "/mnt/unraid/media/Movies/Apollo 11 (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Leatherheads (2008)" rsync -avhP "/mnt/synology/rs-movies/Leatherheads (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: McLintock! (1963)" rsync -avhP "/mnt/synology/rs-movies/McLintock! (1963)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Sure Thing (1985)" rsync -avhP "/mnt/synology/rs-movies/The Sure Thing (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Great Escape (1963)" rsync -avhP "/mnt/unraid/media/Movies/The Great Escape (1963)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Darkest Minds (2018)" rsync -avhP "/mnt/synology/rs-movies/The Darkest Minds (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Ezra (2024)" rsync -avhP "/mnt/unraid/media/Movies/Ezra (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Danger Close The Battle of Long Tan (2019)" rsync -avhP "/mnt/synology/rs-movies/Danger Close The Battle of Long Tan (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: X-Men Origins Wolverine (2009)" rsync -avhP "/mnt/unraid/media/Movies/X-Men Origins Wolverine (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Angry Birds Movie 2 (2019)" rsync -avhP "/mnt/unraid/media/Movies/The Angry Birds Movie 2 (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: A Month by the Lake (1995)" rsync -avhP "/mnt/unraid/media/Movies/A Month by the Lake (1995)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dead Again (1991)" rsync -avhP "/mnt/unraid/media/Movies/Dead Again (1991)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: How the Grinch Stole Christmas! (1966)" rsync -avhP "/mnt/unraid/media/Movies/How the Grinch Stole Christmas! (1966)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Hard Kill (2020)" rsync -avhP "/mnt/unraid/media/Movies/Hard Kill (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Mio in the Land of Faraway (1987)" rsync -avhP "/mnt/synology/rs-movies/Mio in the Land of Faraway (1987)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Sanctuary (2023)" rsync -avhP "/mnt/unraid/media/Movies/Sanctuary (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Nutcrackers (2024)" rsync -avhP "/mnt/unraid/media/Movies/Nutcrackers (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Little Things (2021)" rsync -avhP "/mnt/synology/rs-movies/Little Things (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Practical Magic (1998)" rsync -avhP "/mnt/unraid/media/Movies/Practical Magic (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Christmas Charade (2024)" rsync -avhP "/mnt/synology/rs-movies/The Christmas Charade (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Triple Frontier (2019)" rsync -avhP "/mnt/unraid/media/Movies/Triple Frontier (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Fast and the Furious Tokyo Drift (2006)" rsync -avhP "/mnt/unraid/media/Movies/The Fast and the Furious Tokyo Drift (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Cutting Edge (1992)" rsync -avhP "/mnt/synology/rs-movies/The Cutting Edge (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Constant Gardener (2005)" rsync -avhP "/mnt/unraid/media/Movies/The Constant Gardener (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Smurfs (2025)" rsync -avhP "/mnt/unraid/media/Movies/Smurfs (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Lookout (2025)" rsync -avhP "/mnt/synology/rs-movies/Lookout (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Sydney White (2007)" rsync -avhP "/mnt/synology/rs-movies/Sydney White (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Shanghai Knights (2003)" rsync -avhP "/mnt/synology/rs-movies/Shanghai Knights (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Matilda (1996)" rsync -avhP "/mnt/unraid/media/Movies/Matilda (1996)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Bill Burr Walk Your Way Out (2017)" rsync -avhP "/mnt/unraid/media/Movies/Bill Burr Walk Your Way Out (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Midnight Special (2016)" rsync -avhP "/mnt/synology/rs-movies/Midnight Special (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Blades of Glory (2007)" rsync -avhP "/mnt/unraid/media/Movies/Blades of Glory (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Captain Underpants The First Epic Movie (2017)" rsync -avhP "/mnt/synology/rs-movies/Captain Underpants The First Epic Movie (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Bumblebee (2018)" rsync -avhP "/mnt/unraid/media/Movies/Bumblebee (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: National Lampoons Van Wilder (2002)" rsync -avhP "/mnt/synology/rs-movies/National Lampoons Van Wilder (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Best in Show (2000)" rsync -avhP "/mnt/synology/rs-movies/Best in Show (2000)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Jay Kelly (2025)" rsync -avhP "/mnt/unraid/media/Movies/Jay Kelly (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Brother Bear 2 (2006)" rsync -avhP "/mnt/unraid/media/Movies/Brother Bear 2 (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: How to Train Your Dragon (2010)" rsync -avhP "/mnt/unraid/media/Movies/How to Train Your Dragon (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Body of Lies (2008)" rsync -avhP "/mnt/synology/rs-movies/Body of Lies (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Rebel Moon Part Two The Scargiver (2024)" rsync -avhP "/mnt/unraid/media/Movies/Rebel Moon Part Two The Scargiver (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Leo (2023)" rsync -avhP "/mnt/unraid/media/Movies/Leo (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Scrapper (2023)" rsync -avhP "/mnt/unraid/media/Movies/Scrapper (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: TRON Ares (2025)" rsync -avhP "/mnt/unraid/media/Movies/TRON Ares (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Brotherhood of the Wolf (2001)" rsync -avhP "/mnt/unraid/media/Movies/Brotherhood of the Wolf (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Marine (2006)" rsync -avhP "/mnt/synology/rs-movies/The Marine (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Charlottes Web (2006)" rsync -avhP "/mnt/unraid/media/Movies/Charlottes Web (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Oceans Eight (2018)" rsync -avhP "/mnt/unraid/media/Movies/Oceans Eight (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Witch (2016)" rsync -avhP "/mnt/unraid/media/Movies/The Witch (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Upside-Down Magic (2020)" rsync -avhP "/mnt/synology/rs-movies/Upside-Down Magic (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Platform (2019)" rsync -avhP "/mnt/unraid/media/Movies/The Platform (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Meatballs Part II (1984)" rsync -avhP "/mnt/synology/rs-movies/Meatballs Part II (1984)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Toxic Avenger Unrated (2025)" rsync -avhP "/mnt/unraid/media/Movies/The Toxic Avenger Unrated (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Gasoline Alley (2022)" rsync -avhP "/mnt/unraid/media/Movies/Gasoline Alley (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Machine (2023)" rsync -avhP "/mnt/synology/rs-movies/The Machine (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Never Say Never (2023)" rsync -avhP "/mnt/synology/rs-movies/Never Say Never (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Wizards (1977)" rsync -avhP "/mnt/synology/rs-movies/Wizards (1977)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Nickel Boys (2024)" rsync -avhP "/mnt/unraid/media/Movies/Nickel Boys (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Chronicles of Narnia Prince Caspian (2008)" rsync -avhP "/mnt/synology/rs-movies/The Chronicles of Narnia Prince Caspian (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Cursed (2021)" rsync -avhP "/mnt/unraid/media/Movies/The Cursed (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Christmas Quest (2024)" rsync -avhP "/mnt/synology/rs-movies/The Christmas Quest (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Free Guy (2021)" rsync -avhP "/mnt/synology/rs-movies/Free Guy (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Breach (2020)" rsync -avhP "/mnt/synology/rs-movies/Breach (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Plankton The Movie (2025)" rsync -avhP "/mnt/unraid/media/Movies/Plankton The Movie (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: 57 Seconds (2023)" rsync -avhP "/mnt/unraid/media/Movies/57 Seconds (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Liar Liar (1997)" rsync -avhP "/mnt/unraid/media/Movies/Liar Liar (1997)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Death to Smoochy (2002)" rsync -avhP "/mnt/unraid/media/Movies/Death to Smoochy (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Friday the 13th Part III (1982)" rsync -avhP "/mnt/synology/rs-movies/Friday the 13th Part III (1982)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Shut In (2016)" rsync -avhP "/mnt/synology/rs-movies/Shut In (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Free Willy (1993)" rsync -avhP "/mnt/synology/rs-movies/Free Willy (1993)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Something the Lord Made (2004)" rsync -avhP "/mnt/synology/rs-movies/Something the Lord Made (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Home Makeover (2010)" rsync -avhP "/mnt/unraid/media/Movies/Home Makeover (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: X (2011)" rsync -avhP "/mnt/unraid/media/Movies/X (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Happy Feet (2006)" rsync -avhP "/mnt/unraid/media/Movies/Happy Feet (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Once Bitten (1985)" rsync -avhP "/mnt/synology/rs-movies/Once Bitten (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Sasquatch Sunset (2024)" rsync -avhP "/mnt/unraid/media/Movies/Sasquatch Sunset (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Larger Than Life (1996)" rsync -avhP "/mnt/synology/rs-movies/Larger Than Life (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Men Behind the Sun (1988)" rsync -avhP "/mnt/unraid/media/Movies/Men Behind the Sun (1988)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Jurassic Park III (2001)" rsync -avhP "/mnt/unraid/media/Movies/Jurassic Park III (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Farewell (2019)" rsync -avhP "/mnt/unraid/media/Movies/The Farewell (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Keanu (2016)" rsync -avhP "/mnt/unraid/media/Movies/Keanu (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Nothing But Trouble (1991)" rsync -avhP "/mnt/synology/rs-movies/Nothing But Trouble (1991)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Surfer (2025)" rsync -avhP "/mnt/unraid/media/Movies/The Surfer (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Captain Phillips (2013)" rsync -avhP "/mnt/unraid/media/Movies/Captain Phillips (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Gran Turismo (2023)" rsync -avhP "/mnt/unraid/media/Movies/Gran Turismo (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Paradise (2024)" rsync -avhP "/mnt/synology/rs-movies/Paradise (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Detective Knight Redemption (2022)" rsync -avhP "/mnt/synology/rs-movies/Detective Knight Redemption (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Fear the Night (2023)" rsync -avhP "/mnt/unraid/media/Movies/Fear the Night (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Meg (2018)" rsync -avhP "/mnt/unraid/media/Movies/The Meg (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Silence (2016)" rsync -avhP "/mnt/synology/rs-movies/Silence (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Vivo (2021)" rsync -avhP "/mnt/unraid/media/Movies/Vivo (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Club Dread (2004)" rsync -avhP "/mnt/synology/rs-movies/Club Dread (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: 31 (2016)" rsync -avhP "/mnt/unraid/media/Movies/31 (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Better Luck Tomorrow (2002)" rsync -avhP "/mnt/synology/rs-movies/Better Luck Tomorrow (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Homestead (2024)" rsync -avhP "/mnt/unraid/media/Movies/Homestead (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Paint (2023)" rsync -avhP "/mnt/synology/rs-movies/Paint (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Marry My Dead Body (2023)" rsync -avhP "/mnt/unraid/media/Movies/Marry My Dead Body (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dead Men Dont Wear Plaid (1982)" rsync -avhP "/mnt/synology/rs-movies/Dead Men Dont Wear Plaid (1982)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Ne Zha 2 (2025)" rsync -avhP "/mnt/unraid/media/Movies/Ne Zha 2 (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hunters (2021)" rsync -avhP "/mnt/synology/rs-movies/Hunters (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Christmas Cup (2025)" rsync -avhP "/mnt/synology/rs-movies/The Christmas Cup (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Bikeriders (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Bikeriders (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Fried Green Tomatoes (1991)" rsync -avhP "/mnt/synology/rs-movies/Fried Green Tomatoes (1991)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: DC Showcase Constantine The House of Mystery (2022)" rsync -avhP "/mnt/synology/rs-movies/DC Showcase Constantine The House of Mystery (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Big (1988)" rsync -avhP "/mnt/unraid/media/Movies/Big (1988)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Noah (2014)" rsync -avhP "/mnt/unraid/media/Movies/Noah (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Colony (2021)" rsync -avhP "/mnt/synology/rs-movies/The Colony (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Lady and the Tramp (2019)" rsync -avhP "/mnt/unraid/media/Movies/Lady and the Tramp (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Carriers (2009)" rsync -avhP "/mnt/unraid/media/Movies/Carriers (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Christmas with the Singhs (2024)" rsync -avhP "/mnt/synology/rs-movies/Christmas with the Singhs (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Aviator (2004)" rsync -avhP "/mnt/unraid/media/Movies/The Aviator (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Liar Liar Vampire (2015)" rsync -avhP "/mnt/synology/rs-movies/Liar Liar Vampire (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Deadlock (1970)" rsync -avhP "/mnt/synology/rs-movies/Deadlock (1970)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: I Spy (2002)" rsync -avhP "/mnt/synology/rs-movies/I Spy (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Mule (2018)" rsync -avhP "/mnt/unraid/media/Movies/The Mule (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Woman in Black (2012)" rsync -avhP "/mnt/synology/rs-movies/The Woman in Black (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: LEGO Star Wars Holiday Special (2020)" rsync -avhP "/mnt/unraid/media/Movies/LEGO Star Wars Holiday Special (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Doctor Strange in the Multiverse of Madness (2022)" rsync -avhP "/mnt/unraid/media/Movies/Doctor Strange in the Multiverse of Madness (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Lore (2012)" rsync -avhP "/mnt/unraid/media/Movies/Lore (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Legend (2015)" rsync -avhP "/mnt/unraid/media/Movies/Legend (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hanukkah on the Rocks (2024)" rsync -avhP "/mnt/synology/rs-movies/Hanukkah on the Rocks (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Synecdoche New York (2008)" rsync -avhP "/mnt/unraid/media/Movies/Synecdoche New York (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Warlock (1989)" rsync -avhP "/mnt/synology/rs-movies/Warlock (1989)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Collection (2012)" rsync -avhP "/mnt/unraid/media/Movies/The Collection (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Last Witch Hunter (2015)" rsync -avhP "/mnt/unraid/media/Movies/The Last Witch Hunter (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Way of the Dragon (1972)" rsync -avhP "/mnt/unraid/media/Movies/The Way of the Dragon (1972)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hard Eight (1997)" rsync -avhP "/mnt/synology/rs-movies/Hard Eight (1997)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Hotel Artemis (2018)" rsync -avhP "/mnt/unraid/media/Movies/Hotel Artemis (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: IO (2019)" rsync -avhP "/mnt/unraid/media/Movies/IO (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Alice Darling (2022)" rsync -avhP "/mnt/synology/rs-movies/Alice Darling (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Mr. Harrigans Phone (2022)" rsync -avhP "/mnt/synology/rs-movies/Mr. Harrigans Phone (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Uncharted (2022)" rsync -avhP "/mnt/unraid/media/Movies/Uncharted (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: An American Tail Fievel Goes West (1991)" rsync -avhP "/mnt/unraid/media/Movies/An American Tail Fievel Goes West (1991)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Heart of Stone (2016)" rsync -avhP "/mnt/synology/rs-movies/Heart of Stone (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Justice League Doom (2012)" rsync -avhP "/mnt/unraid/media/Movies/Justice League Doom (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Never Been Kissed (1999)" rsync -avhP "/mnt/unraid/media/Movies/Never Been Kissed (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Are You There God Its Me Margaret. (2023)" rsync -avhP "/mnt/unraid/media/Movies/Are You There God Its Me Margaret. (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Houses October Built (2014)" rsync -avhP "/mnt/synology/rs-movies/The Houses October Built (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Dolittle (2020)" rsync -avhP "/mnt/unraid/media/Movies/Dolittle (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Jumanji Welcome to the Jungle (2017)" rsync -avhP "/mnt/unraid/media/Movies/Jumanji Welcome to the Jungle (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Battered Bastards of Baseball (2014)" rsync -avhP "/mnt/synology/rs-movies/The Battered Bastards of Baseball (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Cliffhanger (1993)" rsync -avhP "/mnt/unraid/media/Movies/Cliffhanger (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Cronos (1993)" rsync -avhP "/mnt/synology/rs-movies/Cronos (1993)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Robert the Bruce (2019)" rsync -avhP "/mnt/synology/rs-movies/Robert the Bruce (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Elizabeth The Golden Age (2007)" rsync -avhP "/mnt/synology/rs-movies/Elizabeth The Golden Age (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Chained Heat (1983)" rsync -avhP "/mnt/unraid/media/Movies/Chained Heat (1983)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Nacho Libre (2006)" rsync -avhP "/mnt/synology/rs-movies/Nacho Libre (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Escape Room (2019)" rsync -avhP "/mnt/synology/rs-movies/Escape Room (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Man on the Moon (1999)" rsync -avhP "/mnt/synology/rs-movies/Man on the Moon (1999)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Die Hard With a Vengeance (1995)" rsync -avhP "/mnt/unraid/media/Movies/Die Hard With a Vengeance (1995)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dear Evan Hansen (2021)" rsync -avhP "/mnt/unraid/media/Movies/Dear Evan Hansen (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Ip Man 4 The Finale (2019)" rsync -avhP "/mnt/synology/rs-movies/Ip Man 4 The Finale (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Purge Anarchy (2014)" rsync -avhP "/mnt/synology/rs-movies/The Purge Anarchy (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Species (1995)" rsync -avhP "/mnt/unraid/media/Movies/Species (1995)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dampyr (2022)" rsync -avhP "/mnt/unraid/media/Movies/Dampyr (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Paranormal Activity Next of Kin (2021)" rsync -avhP "/mnt/unraid/media/Movies/Paranormal Activity Next of Kin (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Brazil (1985)" rsync -avhP "/mnt/synology/rs-movies/Brazil (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Reindeer Games (2000)" rsync -avhP "/mnt/unraid/media/Movies/Reindeer Games (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Isnt It Romantic (2019)" rsync -avhP "/mnt/unraid/media/Movies/Isnt It Romantic (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Behemoth (2021)" rsync -avhP "/mnt/synology/rs-movies/Behemoth (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Sleeping Dogs (2024)" rsync -avhP "/mnt/unraid/media/Movies/Sleeping Dogs (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Birds of Prey and the Fantabulous Emancipation of One Harley Quinn (2020)" rsync -avhP "/mnt/unraid/media/Movies/Birds of Prey and the Fantabulous Emancipation of One Harley Quinn (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: One Night in Miami. (2020)" rsync -avhP "/mnt/unraid/media/Movies/One Night in Miami. (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: White House Down (2013)" rsync -avhP "/mnt/unraid/media/Movies/White House Down (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Spectre (2015)" rsync -avhP "/mnt/unraid/media/Movies/Spectre (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Stealth (2005)" rsync -avhP "/mnt/synology/rs-movies/Stealth (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Thunderbolts- (2025)" rsync -avhP "/mnt/unraid/media/Movies/Thunderbolts- (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Juno (2007)" rsync -avhP "/mnt/synology/rs-movies/Juno (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Edge of Tomorrow (2014)" rsync -avhP "/mnt/unraid/media/Movies/Edge of Tomorrow (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Big Trouble in Little China (1986)" rsync -avhP "/mnt/unraid/media/Movies/Big Trouble in Little China (1986)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Woman Walks Ahead (2018)" rsync -avhP "/mnt/unraid/media/Movies/Woman Walks Ahead (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Roxanne (1987)" rsync -avhP "/mnt/unraid/media/Movies/Roxanne (1987)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: A Scanner Darkly (2006)" rsync -avhP "/mnt/unraid/media/Movies/A Scanner Darkly (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Transformers Age of Extinction (2014)" rsync -avhP "/mnt/unraid/media/Movies/Transformers Age of Extinction (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Season of the Witch (2011)" rsync -avhP "/mnt/unraid/media/Movies/Season of the Witch (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Star Trek (2009)" rsync -avhP "/mnt/synology/rs-movies/Star Trek (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: D.A.R.Y.L. (1985)" rsync -avhP "/mnt/unraid/media/Movies/D.A.R.Y.L. (1985)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hellbound Hellraiser II (1988)" rsync -avhP "/mnt/synology/rs-movies/Hellbound Hellraiser II (1988)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Monster Trucks (2016)" rsync -avhP "/mnt/unraid/media/Movies/Monster Trucks (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Spider-Man Homecoming (2017)" rsync -avhP "/mnt/unraid/media/Movies/Spider-Man Homecoming (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Escape from Planet Earth (2013)" rsync -avhP "/mnt/unraid/media/Movies/Escape from Planet Earth (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Tidings for the Season (2025)" rsync -avhP "/mnt/synology/rs-movies/Tidings for the Season (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Dawn of the Dead (2004)" rsync -avhP "/mnt/unraid/media/Movies/Dawn of the Dead (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Maestro (2023)" rsync -avhP "/mnt/unraid/media/Movies/Maestro (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: White Men Cant Jump (2023)" rsync -avhP "/mnt/unraid/media/Movies/White Men Cant Jump (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Little Fockers (2010)" rsync -avhP "/mnt/unraid/media/Movies/Little Fockers (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Monster Island (2017)" rsync -avhP "/mnt/unraid/media/Movies/Monster Island (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The BFG (2016)" rsync -avhP "/mnt/unraid/media/Movies/The BFG (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Spider-Man Across the Spider-Verse (2023)" rsync -avhP "/mnt/unraid/media/Movies/Spider-Man Across the Spider-Verse (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Escape from Pretoria (2020)" rsync -avhP "/mnt/synology/rs-movies/Escape from Pretoria (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Arctic Dogs (2019)" rsync -avhP "/mnt/synology/rs-movies/Arctic Dogs (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Code 3 (2025)" rsync -avhP "/mnt/synology/rs-movies/Code 3 (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Shepherd (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Shepherd (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Charlies Angels (2019)" rsync -avhP "/mnt/unraid/media/Movies/Charlies Angels (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: A Working Man (2025)" rsync -avhP "/mnt/unraid/media/Movies/A Working Man (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Gloria Bell (2019)" rsync -avhP "/mnt/unraid/media/Movies/Gloria Bell (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Freakier Friday (2025)" rsync -avhP "/mnt/unraid/media/Movies/Freakier Friday (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Hoax (2006)" rsync -avhP "/mnt/synology/rs-movies/The Hoax (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Prey (2024)" rsync -avhP "/mnt/unraid/media/Movies/Prey (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Flubber (1997)" rsync -avhP "/mnt/unraid/media/Movies/Flubber (1997)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Guardians of the Galaxy (2014)" rsync -avhP "/mnt/unraid/media/Movies/Guardians of the Galaxy (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Glass (2019)" rsync -avhP "/mnt/synology/rs-movies/Glass (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Bubble (2022)" rsync -avhP "/mnt/synology/rs-movies/Bubble (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Narvik (2022)" rsync -avhP "/mnt/unraid/media/Movies/Narvik (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: You Cant Run Forever (2024)" rsync -avhP "/mnt/unraid/media/Movies/You Cant Run Forever (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Operation Fortune Ruse de Guerre (2023)" rsync -avhP "/mnt/unraid/media/Movies/Operation Fortune Ruse de Guerre (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Sgt. Stubby An American Hero (2018)" rsync -avhP "/mnt/synology/rs-movies/Sgt. Stubby An American Hero (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Sinners (2025)" rsync -avhP "/mnt/unraid/media/Movies/Sinners (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Shape of Water (2017)" rsync -avhP "/mnt/unraid/media/Movies/The Shape of Water (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Man Who Knew Infinity (2016)" rsync -avhP "/mnt/synology/rs-movies/The Man Who Knew Infinity (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Imaginarium of Doctor Parnassus (2009)" rsync -avhP "/mnt/synology/rs-movies/The Imaginarium of Doctor Parnassus (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Daybreakers (2010)" rsync -avhP "/mnt/unraid/media/Movies/Daybreakers (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Porky's (1981)" rsync -avhP "/mnt/synology/rs-movies/Porky's (1981)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Dear Santa (2024)" rsync -avhP "/mnt/unraid/media/Movies/Dear Santa (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Die Another Day (2002)" rsync -avhP "/mnt/unraid/media/Movies/Die Another Day (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Mistletoe Promise (2016)" rsync -avhP "/mnt/synology/rs-movies/The Mistletoe Promise (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Radio Days (1987)" rsync -avhP "/mnt/synology/rs-movies/Radio Days (1987)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The New Mutants (2020)" rsync -avhP "/mnt/unraid/media/Movies/The New Mutants (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Skyscraper (2018)" rsync -avhP "/mnt/unraid/media/Movies/Skyscraper (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: 27 Dresses (2008)" rsync -avhP "/mnt/synology/rs-movies/27 Dresses (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: 20th Century Women (2016)" rsync -avhP "/mnt/unraid/media/Movies/20th Century Women (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Ash (2025)" rsync -avhP "/mnt/unraid/media/Movies/Ash (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Blade Trinity (2004)" rsync -avhP "/mnt/unraid/media/Movies/Blade Trinity (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Fight Club (1999)" rsync -avhP "/mnt/synology/rs-movies/Fight Club (1999)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Aftermath (2024)" rsync -avhP "/mnt/unraid/media/Movies/Aftermath (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Air Force Elite Thunderbirds (2025)" rsync -avhP "/mnt/unraid/media/Movies/Air Force Elite Thunderbirds (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Psycho (1960)" rsync -avhP "/mnt/unraid/media/Movies/Psycho (1960)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Crocodile Dundee II (1988)" rsync -avhP "/mnt/synology/rs-movies/Crocodile Dundee II (1988)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Ruby Gillman Teenage Kraken (2023)" rsync -avhP "/mnt/unraid/media/Movies/Ruby Gillman Teenage Kraken (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Seven Psychopaths (2012)" rsync -avhP "/mnt/unraid/media/Movies/Seven Psychopaths (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Old Dogs (2009)" rsync -avhP "/mnt/synology/rs-movies/Old Dogs (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Shotgun Wedding (2022)" rsync -avhP "/mnt/unraid/media/Movies/Shotgun Wedding (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: How to Have Sex (2023)" rsync -avhP "/mnt/unraid/media/Movies/How to Have Sex (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: One Battle After Another (2025)" rsync -avhP "/mnt/unraid/media/Movies/One Battle After Another (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hell of a Summer (2025)" rsync -avhP "/mnt/synology/rs-movies/Hell of a Summer (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Channel (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Channel (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Friday the 13th (2009)" rsync -avhP "/mnt/unraid/media/Movies/Friday the 13th (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Underworld Rise of the Lycans (2009)" rsync -avhP "/mnt/unraid/media/Movies/Underworld Rise of the Lycans (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hunter Hunter (2020)" rsync -avhP "/mnt/synology/rs-movies/Hunter Hunter (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Flying Leathernecks (1951)" rsync -avhP "/mnt/synology/rs-movies/Flying Leathernecks (1951)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Blow Out (1981)" rsync -avhP "/mnt/synology/rs-movies/Blow Out (1981)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Popeyes Revenge (2025)" rsync -avhP "/mnt/synology/rs-movies/Popeyes Revenge (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Mickeys Twice Upon a Christmas (2004)" rsync -avhP "/mnt/synology/rs-movies/Mickeys Twice Upon a Christmas (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Code 8 (2019)" rsync -avhP "/mnt/synology/rs-movies/Code 8 (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Johnny Got His Gun (1971)" rsync -avhP "/mnt/synology/rs-movies/Johnny Got His Gun (1971)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Mummies (2023)" rsync -avhP "/mnt/unraid/media/Movies/Mummies (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Devils Advocate (1997)" rsync -avhP "/mnt/synology/rs-movies/The Devils Advocate (1997)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Four Lions (2010)" rsync -avhP "/mnt/unraid/media/Movies/Four Lions (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Ben-Hur (1959)" rsync -avhP "/mnt/unraid/media/Movies/Ben-Hur (1959)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Indecent Proposal (1993)" rsync -avhP "/mnt/unraid/media/Movies/Indecent Proposal (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Z-O-M-B-I-E-S (2018)" rsync -avhP "/mnt/synology/rs-movies/Z-O-M-B-I-E-S (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Holiday Touchdown A Bills Love Story (2025)" rsync -avhP "/mnt/synology/rs-movies/Holiday Touchdown A Bills Love Story (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Alice Through the Looking Glass (2016)" rsync -avhP "/mnt/synology/rs-movies/Alice Through the Looking Glass (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Big Ugly (2020)" rsync -avhP "/mnt/unraid/media/Movies/The Big Ugly (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hawk the Slayer (1980)" rsync -avhP "/mnt/synology/rs-movies/Hawk the Slayer (1980)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Armageddon Time (2022)" rsync -avhP "/mnt/synology/rs-movies/Armageddon Time (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Steam Experiment (2009)" rsync -avhP "/mnt/synology/rs-movies/The Steam Experiment (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Ghosts of the Abyss (2003)" rsync -avhP "/mnt/synology/rs-movies/Ghosts of the Abyss (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Amores Perros (2000)" rsync -avhP "/mnt/unraid/media/Movies/Amores Perros (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Back from Hell (2012)" rsync -avhP "/mnt/synology/rs-movies/Back from Hell (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: WWE Royal Rumble 2025 (2025)" rsync -avhP "/mnt/unraid/media/Movies/WWE Royal Rumble 2025 (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Courier (2024)" rsync -avhP "/mnt/synology/rs-movies/The Courier (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Town (2010)" rsync -avhP "/mnt/unraid/media/Movies/The Town (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Spirit of St. Louis (1957)" rsync -avhP "/mnt/synology/rs-movies/The Spirit of St. Louis (1957)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Our Man Flint (1966)" rsync -avhP "/mnt/synology/rs-movies/Our Man Flint (1966)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: South Park Bigger Longer and Uncut (1999)" rsync -avhP "/mnt/unraid/media/Movies/South Park Bigger Longer and Uncut (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Cleaner (2025)" rsync -avhP "/mnt/unraid/media/Movies/Cleaner (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Curse of the Puppet Master (1998)" rsync -avhP "/mnt/synology/rs-movies/Curse of the Puppet Master (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Family Switch (2023)" rsync -avhP "/mnt/unraid/media/Movies/Family Switch (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Mist (2007)" rsync -avhP "/mnt/unraid/media/Movies/The Mist (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Marriage Story (2019)" rsync -avhP "/mnt/unraid/media/Movies/Marriage Story (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Bridge to Terabithia (2007)" rsync -avhP "/mnt/synology/rs-movies/Bridge to Terabithia (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Double Team (1997)" rsync -avhP "/mnt/unraid/media/Movies/Double Team (1997)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Jury Duty (1995)" rsync -avhP "/mnt/synology/rs-movies/Jury Duty (1995)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: King Arthur (2004)" rsync -avhP "/mnt/unraid/media/Movies/King Arthur (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Animal House (1978)" rsync -avhP "/mnt/unraid/media/Movies/Animal House (1978)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: There Are No Saints (2022)" rsync -avhP "/mnt/unraid/media/Movies/There Are No Saints (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Old Guard (2020)" rsync -avhP "/mnt/unraid/media/Movies/The Old Guard (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Inheritance (2020)" rsync -avhP "/mnt/synology/rs-movies/Inheritance (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Nightcrawler (2014)" rsync -avhP "/mnt/synology/rs-movies/Nightcrawler (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Kiss of the Damned (2012)" rsync -avhP "/mnt/synology/rs-movies/Kiss of the Damned (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Killing Fields (1984)" rsync -avhP "/mnt/unraid/media/Movies/The Killing Fields (1984)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Bean (1997)" rsync -avhP "/mnt/unraid/media/Movies/Bean (1997)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Books of Blood (2020)" rsync -avhP "/mnt/synology/rs-movies/Books of Blood (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Guns of Fort Petticoat (1957)" rsync -avhP "/mnt/synology/rs-movies/The Guns of Fort Petticoat (1957)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Murder on the Orient Express (1974)" rsync -avhP "/mnt/synology/rs-movies/Murder on the Orient Express (1974)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Erin Brockovich (2000)" rsync -avhP "/mnt/unraid/media/Movies/Erin Brockovich (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Sing Sing (2024)" rsync -avhP "/mnt/unraid/media/Movies/Sing Sing (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: A Newport Christmas (2025)" rsync -avhP "/mnt/synology/rs-movies/A Newport Christmas (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Lion King (2019)" rsync -avhP "/mnt/synology/rs-movies/The Lion King (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Hollow (2015)" rsync -avhP "/mnt/unraid/media/Movies/The Hollow (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: All the Right Moves (1983)" rsync -avhP "/mnt/synology/rs-movies/All the Right Moves (1983)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: A Gingerbread Romance (2018)" rsync -avhP "/mnt/synology/rs-movies/A Gingerbread Romance (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Smokey and the Bandit II (1980)" rsync -avhP "/mnt/synology/rs-movies/Smokey and the Bandit II (1980)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Black Adam (2022)" rsync -avhP "/mnt/unraid/media/Movies/Black Adam (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Bridget Jones The Edge of Reason (2004)" rsync -avhP "/mnt/synology/rs-movies/Bridget Jones The Edge of Reason (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Black Panther (2018)" rsync -avhP "/mnt/unraid/media/Movies/Black Panther (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Disappearance of Haruhi Suzumiya (2010)" rsync -avhP "/mnt/unraid/media/Movies/The Disappearance of Haruhi Suzumiya (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Moonrise Kingdom (2012)" rsync -avhP "/mnt/synology/rs-movies/Moonrise Kingdom (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Z-O-M-B-I-E-S 3 (2022)" rsync -avhP "/mnt/synology/rs-movies/Z-O-M-B-I-E-S 3 (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Universal Soldier (1992)" rsync -avhP "/mnt/unraid/media/Movies/Universal Soldier (1992)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Other (2025)" rsync -avhP "/mnt/synology/rs-movies/Other (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: First Blood (1982)" rsync -avhP "/mnt/unraid/media/Movies/First Blood (1982)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Vampire Hunter D (1985)" rsync -avhP "/mnt/synology/rs-movies/Vampire Hunter D (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: South Park Joining the Panderverse (2023)" rsync -avhP "/mnt/unraid/media/Movies/South Park Joining the Panderverse (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Lovers (2017)" rsync -avhP "/mnt/unraid/media/Movies/The Lovers (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Curfew (2012)" rsync -avhP "/mnt/synology/rs-movies/Curfew (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Hasan Minhaj The Kings Jester (2022)" rsync -avhP "/mnt/synology/rs-movies/Hasan Minhaj The Kings Jester (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The American Society of Magical Negroes (2024)" rsync -avhP "/mnt/synology/rs-movies/The American Society of Magical Negroes (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Here Comes the Boom (2012)" rsync -avhP "/mnt/unraid/media/Movies/Here Comes the Boom (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Melt My Heart This Christmas (2025)" rsync -avhP "/mnt/synology/rs-movies/Melt My Heart This Christmas (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Gatekeepers (2012)" rsync -avhP "/mnt/synology/rs-movies/The Gatekeepers (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Mamma Mia! (2008)" rsync -avhP "/mnt/synology/rs-movies/Mamma Mia! (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Stripes (1981)" rsync -avhP "/mnt/synology/rs-movies/Stripes (1981)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Peppermint (2018)" rsync -avhP "/mnt/synology/rs-movies/Peppermint (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Bohemian Rhapsody (2018)" rsync -avhP "/mnt/unraid/media/Movies/Bohemian Rhapsody (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Training Day (2001)" rsync -avhP "/mnt/synology/rs-movies/Training Day (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: House (2008)" rsync -avhP "/mnt/synology/rs-movies/House (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Better Watch Out (2017)" rsync -avhP "/mnt/synology/rs-movies/Better Watch Out (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Boy Kills World (2024)" rsync -avhP "/mnt/unraid/media/Movies/Boy Kills World (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Thanksgiving (2023)" rsync -avhP "/mnt/unraid/media/Movies/Thanksgiving (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Final Destination (2000)" rsync -avhP "/mnt/unraid/media/Movies/Final Destination (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Slingshot (2024)" rsync -avhP "/mnt/unraid/media/Movies/Slingshot (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Hell or High Water (2016)" rsync -avhP "/mnt/unraid/media/Movies/Hell or High Water (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Justice League Warworld (2023)" rsync -avhP "/mnt/unraid/media/Movies/Justice League Warworld (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Velveteen Rabbit (2023)" rsync -avhP "/mnt/synology/rs-movies/The Velveteen Rabbit (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Bourne Identity (2002)" rsync -avhP "/mnt/unraid/media/Movies/The Bourne Identity (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dungeons and Dragons (2000)" rsync -avhP "/mnt/unraid/media/Movies/Dungeons and Dragons (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Awakenings (1990)" rsync -avhP "/mnt/synology/rs-movies/Awakenings (1990)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: In the Lost Lands (2025)" rsync -avhP "/mnt/unraid/media/Movies/In the Lost Lands (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Charlie Wilsons War (2007)" rsync -avhP "/mnt/synology/rs-movies/Charlie Wilsons War (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Popeye the Slayer Man (2025)" rsync -avhP "/mnt/synology/rs-movies/Popeye the Slayer Man (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Smurfs and the Magic Flute (1975)" rsync -avhP "/mnt/synology/rs-movies/The Smurfs and the Magic Flute (1975)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Antlers (2021)" rsync -avhP "/mnt/unraid/media/Movies/Antlers (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Jurassic Park (1993)" rsync -avhP "/mnt/unraid/media/Movies/Jurassic Park (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Slice (2018)" rsync -avhP "/mnt/unraid/media/Movies/Slice (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dumplin (2018)" rsync -avhP "/mnt/synology/rs-movies/Dumplin (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Price of Parenting (2021)" rsync -avhP "/mnt/synology/rs-movies/Price of Parenting (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Misfits (2021)" rsync -avhP "/mnt/synology/rs-movies/Misfits (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Pain Hustlers (2023)" rsync -avhP "/mnt/unraid/media/Movies/Pain Hustlers (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Trailer Park Boys The Movie (2006)" rsync -avhP "/mnt/synology/rs-movies/Trailer Park Boys The Movie (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Batman Under the Red Hood (2010)" rsync -avhP "/mnt/synology/rs-movies/Batman Under the Red Hood (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Inferno (2016)" rsync -avhP "/mnt/unraid/media/Movies/Inferno (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Boss Baby (2017)" rsync -avhP "/mnt/unraid/media/Movies/The Boss Baby (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Look Whos Back (2015)" rsync -avhP "/mnt/unraid/media/Movies/Look Whos Back (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Sorry to Bother You (2018)" rsync -avhP "/mnt/synology/rs-movies/Sorry to Bother You (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Sputnik (2020)" rsync -avhP "/mnt/synology/rs-movies/Sputnik (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Sister Act (1992)" rsync -avhP "/mnt/unraid/media/Movies/Sister Act (1992)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Woman Knight of Mirror Lake (2011)" rsync -avhP "/mnt/synology/rs-movies/The Woman Knight of Mirror Lake (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Thriller 40 (2023)" rsync -avhP "/mnt/unraid/media/Movies/Thriller 40 (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Memento (2000)" rsync -avhP "/mnt/synology/rs-movies/Memento (2000)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: As You Are (2016)" rsync -avhP "/mnt/unraid/media/Movies/As You Are (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Invisible Man (2020)" rsync -avhP "/mnt/unraid/media/Movies/The Invisible Man (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Natural Born Killers (1994)" rsync -avhP "/mnt/unraid/media/Movies/Natural Born Killers (1994)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Horton Hears a Who! (2008)" rsync -avhP "/mnt/unraid/media/Movies/Horton Hears a Who! (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Auntie Edna (2018)" rsync -avhP "/mnt/unraid/media/Movies/Auntie Edna (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Sebastian Maniscalco Is it Me (2022)" rsync -avhP "/mnt/unraid/media/Movies/Sebastian Maniscalco Is it Me (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Adventures of Buckaroo Banzai Across the 8th Dimension (1984)" rsync -avhP "/mnt/synology/rs-movies/The Adventures of Buckaroo Banzai Across the 8th Dimension (1984)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Matt Rife Only Fans (2021)" rsync -avhP "/mnt/synology/rs-movies/Matt Rife Only Fans (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Just Cause (1995)" rsync -avhP "/mnt/synology/rs-movies/Just Cause (1995)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Equalizer (2014)" rsync -avhP "/mnt/unraid/media/Movies/The Equalizer (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Kinky Kitchen (2019)" rsync -avhP "/mnt/synology/rs-movies/Kinky Kitchen (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Dont Breathe 2 (2021)" rsync -avhP "/mnt/synology/rs-movies/Dont Breathe 2 (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Devils Bath (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Devils Bath (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Black Mirror Bandersnatch (2018)" rsync -avhP "/mnt/unraid/media/Movies/Black Mirror Bandersnatch (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: What Dreams May Come (1998)" rsync -avhP "/mnt/unraid/media/Movies/What Dreams May Come (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: American Reunion (2012)" rsync -avhP "/mnt/synology/rs-movies/American Reunion (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: LEGO DC Comics Super Heroes Justice League Gotham City Breakout (2016)" rsync -avhP "/mnt/unraid/media/Movies/LEGO DC Comics Super Heroes Justice League Gotham City Breakout (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Your Lucky Day (2023)" rsync -avhP "/mnt/unraid/media/Movies/Your Lucky Day (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Joker (2019)" rsync -avhP "/mnt/unraid/media/Movies/Joker (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Kronks New Groove (2005)" rsync -avhP "/mnt/unraid/media/Movies/Kronks New Groove (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Aladdin (2019)" rsync -avhP "/mnt/synology/rs-movies/Aladdin (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Volumes of Blood (2015)" rsync -avhP "/mnt/synology/rs-movies/Volumes of Blood (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Eyes Wide Shut (1999)" rsync -avhP "/mnt/unraid/media/Movies/Eyes Wide Shut (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: South Park The End of Obesity (2024)" rsync -avhP "/mnt/unraid/media/Movies/South Park The End of Obesity (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Stephen Curry Underrated (2023)" rsync -avhP "/mnt/unraid/media/Movies/Stephen Curry Underrated (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Perfect Host (2010)" rsync -avhP "/mnt/synology/rs-movies/The Perfect Host (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Network (1976)" rsync -avhP "/mnt/synology/rs-movies/Network (1976)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Lion in Winter (1968)" rsync -avhP "/mnt/unraid/media/Movies/The Lion in Winter (1968)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Werewolves (2024)" rsync -avhP "/mnt/unraid/media/Movies/Werewolves (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: This Is the End (2013)" rsync -avhP "/mnt/unraid/media/Movies/This Is the End (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Exorcism of God (2022)" rsync -avhP "/mnt/synology/rs-movies/The Exorcism of God (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: How to Train Your Dragon The Hidden World (2019)" rsync -avhP "/mnt/unraid/media/Movies/How to Train Your Dragon The Hidden World (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Oceans Thirteen (2007)" rsync -avhP "/mnt/unraid/media/Movies/Oceans Thirteen (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Invincible (2006)" rsync -avhP "/mnt/synology/rs-movies/Invincible (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Zack Snyders Justice League (2021)" rsync -avhP "/mnt/unraid/media/Movies/Zack Snyders Justice League (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Spaceballs (1987)" rsync -avhP "/mnt/synology/rs-movies/Spaceballs (1987)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Little Rascals (1994)" rsync -avhP "/mnt/synology/rs-movies/The Little Rascals (1994)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: My Blue Heaven (1990)" rsync -avhP "/mnt/synology/rs-movies/My Blue Heaven (1990)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Chronicles of Narnia The Lion the Witch and the Wardrobe (2005)" rsync -avhP "/mnt/unraid/media/Movies/The Chronicles of Narnia The Lion the Witch and the Wardrobe (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Super Mario Bros. (1993)" rsync -avhP "/mnt/synology/rs-movies/Super Mario Bros. (1993)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Cool World (1992)" rsync -avhP "/mnt/synology/rs-movies/Cool World (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Planet of the Apes (2001)" rsync -avhP "/mnt/unraid/media/Movies/Planet of the Apes (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Natural (1984)" rsync -avhP "/mnt/unraid/media/Movies/The Natural (1984)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: She Rides Shotgun (2025)" rsync -avhP "/mnt/unraid/media/Movies/She Rides Shotgun (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Charade (1963)" rsync -avhP "/mnt/synology/rs-movies/Charade (1963)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Good the Bart and the Loki (2021)" rsync -avhP "/mnt/unraid/media/Movies/The Good the Bart and the Loki (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Better Off Dead. (1985)" rsync -avhP "/mnt/unraid/media/Movies/Better Off Dead. (1985)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Gathering Storm (2002)" rsync -avhP "/mnt/unraid/media/Movies/The Gathering Storm (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Shrek 2 (2004)" rsync -avhP "/mnt/unraid/media/Movies/Shrek 2 (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Superintelligence (2020)" rsync -avhP "/mnt/unraid/media/Movies/Superintelligence (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Strange Days (1995)" rsync -avhP "/mnt/unraid/media/Movies/Strange Days (1995)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Keep Waiting for Me (1983)" rsync -avhP "/mnt/synology/rs-movies/Keep Waiting for Me (1983)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Shes Making a List (2025)" rsync -avhP "/mnt/synology/rs-movies/Shes Making a List (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: A Simple Favor (2018)" rsync -avhP "/mnt/unraid/media/Movies/A Simple Favor (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: South Park Not Suitable for Children (2023)" rsync -avhP "/mnt/unraid/media/Movies/South Park Not Suitable for Children (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Lego Movie 2 The Second Part (2019)" rsync -avhP "/mnt/unraid/media/Movies/The Lego Movie 2 The Second Part (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Rules of Engagement (2000)" rsync -avhP "/mnt/unraid/media/Movies/Rules of Engagement (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Snowpiercer (2013)" rsync -avhP "/mnt/unraid/media/Movies/Snowpiercer (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Scream (2022)" rsync -avhP "/mnt/unraid/media/Movies/Scream (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: T2 Trainspotting (2017)" rsync -avhP "/mnt/unraid/media/Movies/T2 Trainspotting (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Suicide Squad Hell to Pay (2018)" rsync -avhP "/mnt/unraid/media/Movies/Suicide Squad Hell to Pay (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: A Star Is Born (2018)" rsync -avhP "/mnt/unraid/media/Movies/A Star Is Born (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Death of a Salesman (1985)" rsync -avhP "/mnt/synology/rs-movies/Death of a Salesman (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Hotel Desire (2011)" rsync -avhP "/mnt/synology/rs-movies/Hotel Desire (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Mighty Ducks (1992)" rsync -avhP "/mnt/synology/rs-movies/The Mighty Ducks (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Mickey Blue Eyes (1999)" rsync -avhP "/mnt/synology/rs-movies/Mickey Blue Eyes (1999)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: After the Hunt (2025)" rsync -avhP "/mnt/synology/rs-movies/After the Hunt (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Dead Man Down (2013)" rsync -avhP "/mnt/synology/rs-movies/Dead Man Down (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Star Trek V The Final Frontier (1989)" rsync -avhP "/mnt/unraid/media/Movies/Star Trek V The Final Frontier (1989)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Monkey Man (2024)" rsync -avhP "/mnt/unraid/media/Movies/Monkey Man (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: 8-Bit Christmas (2021)" rsync -avhP "/mnt/synology/rs-movies/8-Bit Christmas (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Asphalt City (2024)" rsync -avhP "/mnt/unraid/media/Movies/Asphalt City (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Finding Nemo (2003)" rsync -avhP "/mnt/synology/rs-movies/Finding Nemo (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Crow (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Crow (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Subservience (2024)" rsync -avhP "/mnt/unraid/media/Movies/Subservience (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Holiday for Heroes (2019)" rsync -avhP "/mnt/synology/rs-movies/Holiday for Heroes (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Prisoners (2013)" rsync -avhP "/mnt/unraid/media/Movies/Prisoners (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Snake Eyes G.I. Joe Origins (2021)" rsync -avhP "/mnt/unraid/media/Movies/Snake Eyes G.I. Joe Origins (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Bring Her Back (2025)" rsync -avhP "/mnt/unraid/media/Movies/Bring Her Back (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Stillwater (2021)" rsync -avhP "/mnt/unraid/media/Movies/Stillwater (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Neptune Frost (2022)" rsync -avhP "/mnt/unraid/media/Movies/Neptune Frost (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Flash Gordon (1980)" rsync -avhP "/mnt/unraid/media/Movies/Flash Gordon (1980)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Hunger Games The Ballad of Songbirds and Snakes (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Hunger Games The Ballad of Songbirds and Snakes (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Would It Kill You to Laugh Starring Kate Berlant + John Early (2022)" rsync -avhP "/mnt/unraid/media/Movies/Would It Kill You to Laugh Starring Kate Berlant + John Early (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Magnificent Seven (2016)" rsync -avhP "/mnt/unraid/media/Movies/The Magnificent Seven (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The NeverEnding Story (1984)" rsync -avhP "/mnt/synology/rs-movies/The NeverEnding Story (1984)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Lawrence of Arabia (1962)" rsync -avhP "/mnt/unraid/media/Movies/Lawrence of Arabia (1962)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Batman Mask of the Phantasm (1993)" rsync -avhP "/mnt/unraid/media/Movies/Batman Mask of the Phantasm (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Anora (2024)" rsync -avhP "/mnt/synology/rs-movies/Anora (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Smashing Machine (2025)" rsync -avhP "/mnt/unraid/media/Movies/The Smashing Machine (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: DarkGame (2024)" rsync -avhP "/mnt/synology/rs-movies/DarkGame (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Sometimes I Think About Dying (2024)" rsync -avhP "/mnt/unraid/media/Movies/Sometimes I Think About Dying (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Blown Away (1993)" rsync -avhP "/mnt/synology/rs-movies/Blown Away (1993)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: A Night at the Roxbury (1998)" rsync -avhP "/mnt/synology/rs-movies/A Night at the Roxbury (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Swimmers (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Swimmers (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Queen of the Damned (2002)" rsync -avhP "/mnt/synology/rs-movies/Queen of the Damned (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Paycheck (2003)" rsync -avhP "/mnt/synology/rs-movies/Paycheck (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Modern Problems (1981)" rsync -avhP "/mnt/synology/rs-movies/Modern Problems (1981)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: A Beautiful Planet (2016)" rsync -avhP "/mnt/unraid/media/Movies/A Beautiful Planet (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Stand by Me (1986)" rsync -avhP "/mnt/unraid/media/Movies/Stand by Me (1986)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Revolver (2005)" rsync -avhP "/mnt/synology/rs-movies/Revolver (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Rip in Time (2022)" rsync -avhP "/mnt/unraid/media/Movies/Rip in Time (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Harakiri (1962)" rsync -avhP "/mnt/synology/rs-movies/Harakiri (1962)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Enemy Below (1957)" rsync -avhP "/mnt/synology/rs-movies/The Enemy Below (1957)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Nobody 2 (2025)" rsync -avhP "/mnt/unraid/media/Movies/Nobody 2 (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Origin (2023)" rsync -avhP "/mnt/unraid/media/Movies/Origin (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Chinatown (1974)" rsync -avhP "/mnt/unraid/media/Movies/Chinatown (1974)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Murphys Romance (1985)" rsync -avhP "/mnt/synology/rs-movies/Murphys Romance (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: BMX Bandits (1983)" rsync -avhP "/mnt/synology/rs-movies/BMX Bandits (1983)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Ant-Man and the Wasp Quantumania (2023)" rsync -avhP "/mnt/unraid/media/Movies/Ant-Man and the Wasp Quantumania (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The SpongeBob SquarePants Movie (2004)" rsync -avhP "/mnt/synology/rs-movies/The SpongeBob SquarePants Movie (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Sixty Minutes (2024)" rsync -avhP "/mnt/synology/rs-movies/Sixty Minutes (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Three Musketeers Milady (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Three Musketeers Milady (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Lara Croft Tomb Raider (2001)" rsync -avhP "/mnt/unraid/media/Movies/Lara Croft Tomb Raider (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Parallel (2024)" rsync -avhP "/mnt/unraid/media/Movies/Parallel (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Middle Men (2009)" rsync -avhP "/mnt/unraid/media/Movies/Middle Men (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dave Chappelle The Kennedy Center Mark Twain Prize for American Humor (2020)" rsync -avhP "/mnt/synology/rs-movies/Dave Chappelle The Kennedy Center Mark Twain Prize for American Humor (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: History of the World Part I (1981)" rsync -avhP "/mnt/synology/rs-movies/History of the World Part I (1981)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Operation Mincemeat (2022)" rsync -avhP "/mnt/unraid/media/Movies/Operation Mincemeat (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Coolie (2025)" rsync -avhP "/mnt/unraid/media/Movies/Coolie (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Cockneys vs Zombies (2012)" rsync -avhP "/mnt/synology/rs-movies/Cockneys vs Zombies (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Superman Returns (2006)" rsync -avhP "/mnt/unraid/media/Movies/Superman Returns (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: One Summer in Austin The Story of Filming 'A Scanner Darkly (2006)" rsync -avhP "/mnt/synology/rs-movies/One Summer in Austin The Story of Filming 'A Scanner Darkly (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Millers Crossing (1990)" rsync -avhP "/mnt/unraid/media/Movies/Millers Crossing (1990)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Phantom Thread (2017)" rsync -avhP "/mnt/unraid/media/Movies/Phantom Thread (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: St. Vincent (2014)" rsync -avhP "/mnt/synology/rs-movies/St. Vincent (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: A Prayer Before Dawn (2018)" rsync -avhP "/mnt/unraid/media/Movies/A Prayer Before Dawn (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Emma. (2020)" rsync -avhP "/mnt/unraid/media/Movies/Emma. (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Chariot (2022)" rsync -avhP "/mnt/synology/rs-movies/Chariot (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Queen Rock Montreal (2024)" rsync -avhP "/mnt/unraid/media/Movies/Queen Rock Montreal (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Tinsel Town (2025)" rsync -avhP "/mnt/unraid/media/Movies/Tinsel Town (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Vice (2018)" rsync -avhP "/mnt/unraid/media/Movies/Vice (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: F X (1986)" rsync -avhP "/mnt/synology/rs-movies/F X (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Public Enemies (2009)" rsync -avhP "/mnt/unraid/media/Movies/Public Enemies (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: La Bamba (1987)" rsync -avhP "/mnt/synology/rs-movies/La Bamba (1987)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Penelope (2007)" rsync -avhP "/mnt/synology/rs-movies/Penelope (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Attack of the Killer Tomatoes! (1978)" rsync -avhP "/mnt/synology/rs-movies/Attack of the Killer Tomatoes! (1978)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Fire and Ice (1983)" rsync -avhP "/mnt/synology/rs-movies/Fire and Ice (1983)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: All Is Lost (2013)" rsync -avhP "/mnt/synology/rs-movies/All Is Lost (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Flowers of War (2011)" rsync -avhP "/mnt/unraid/media/Movies/The Flowers of War (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Adults (2023)" rsync -avhP "/mnt/synology/rs-movies/The Adults (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Other Woman (2014)" rsync -avhP "/mnt/synology/rs-movies/The Other Woman (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: For a Few Dollars More (1965)" rsync -avhP "/mnt/unraid/media/Movies/For a Few Dollars More (1965)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: From Russia with Love (1963)" rsync -avhP "/mnt/unraid/media/Movies/From Russia with Love (1963)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Haunted Mansion (2023)" rsync -avhP "/mnt/unraid/media/Movies/Haunted Mansion (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: In the Heart of the Sea (2015)" rsync -avhP "/mnt/unraid/media/Movies/In the Heart of the Sea (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Smile (2022)" rsync -avhP "/mnt/unraid/media/Movies/Smile (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Following Yonder Star (2024)" rsync -avhP "/mnt/synology/rs-movies/Following Yonder Star (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Wonder Woman (2009)" rsync -avhP "/mnt/synology/rs-movies/Wonder Woman (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: After.Life (2009)" rsync -avhP "/mnt/synology/rs-movies/After.Life (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Meet Me Next Christmas (2024)" rsync -avhP "/mnt/synology/rs-movies/Meet Me Next Christmas (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Heaven Knows What (2015)" rsync -avhP "/mnt/synology/rs-movies/Heaven Knows What (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Take Shelter (2011)" rsync -avhP "/mnt/synology/rs-movies/Take Shelter (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Gemini Man (2019)" rsync -avhP "/mnt/unraid/media/Movies/Gemini Man (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Agora (2009)" rsync -avhP "/mnt/unraid/media/Movies/Agora (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: No Way Out (1987)" rsync -avhP "/mnt/unraid/media/Movies/No Way Out (1987)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Ted Bundy American Boogeyman (2021)" rsync -avhP "/mnt/synology/rs-movies/Ted Bundy American Boogeyman (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Retro Puppet Master (1999)" rsync -avhP "/mnt/synology/rs-movies/Retro Puppet Master (1999)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Thrashin (1986)" rsync -avhP "/mnt/synology/rs-movies/Thrashin (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Moonlight (2016)" rsync -avhP "/mnt/synology/rs-movies/Moonlight (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: To Have and to Holiday (2024)" rsync -avhP "/mnt/synology/rs-movies/To Have and to Holiday (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Street Fighter II The Animated Movie (1994)" rsync -avhP "/mnt/unraid/media/Movies/Street Fighter II The Animated Movie (1994)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: James and the Giant Peach (1996)" rsync -avhP "/mnt/unraid/media/Movies/James and the Giant Peach (1996)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Your Highness (2011)" rsync -avhP "/mnt/unraid/media/Movies/Your Highness (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Breaking (2022)" rsync -avhP "/mnt/unraid/media/Movies/Breaking (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Assassination of Jesse James by the Coward Robert Ford (2007)" rsync -avhP "/mnt/unraid/media/Movies/The Assassination of Jesse James by the Coward Robert Ford (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Death Proof (2007)" rsync -avhP "/mnt/unraid/media/Movies/Death Proof (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Twilight of the Warriors Walled In (2024)" rsync -avhP "/mnt/unraid/media/Movies/Twilight of the Warriors Walled In (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Stoned Age (1994)" rsync -avhP "/mnt/synology/rs-movies/The Stoned Age (1994)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Anthony Jeselnik Fire in the Maternity Ward (2019)" rsync -avhP "/mnt/unraid/media/Movies/Anthony Jeselnik Fire in the Maternity Ward (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Lone Ranger (2013)" rsync -avhP "/mnt/unraid/media/Movies/The Lone Ranger (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Tarot (2024)" rsync -avhP "/mnt/unraid/media/Movies/Tarot (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Pretty in Pink (1986)" rsync -avhP "/mnt/synology/rs-movies/Pretty in Pink (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Ghosts of War (2020)" rsync -avhP "/mnt/synology/rs-movies/Ghosts of War (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Monster High 2 (2023)" rsync -avhP "/mnt/synology/rs-movies/Monster High 2 (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: My Son Hunter (2022)" rsync -avhP "/mnt/synology/rs-movies/My Son Hunter (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Charlie St. Cloud (2010)" rsync -avhP "/mnt/synology/rs-movies/Charlie St. Cloud (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Radical (2023)" rsync -avhP "/mnt/unraid/media/Movies/Radical (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Home on the Range (2004)" rsync -avhP "/mnt/synology/rs-movies/Home on the Range (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Against the Ice (2022)" rsync -avhP "/mnt/unraid/media/Movies/Against the Ice (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Conan the Destroyer (1984)" rsync -avhP "/mnt/synology/rs-movies/Conan the Destroyer (1984)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Justice League (2017)" rsync -avhP "/mnt/unraid/media/Movies/Justice League (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Young Lions (1958)" rsync -avhP "/mnt/synology/rs-movies/The Young Lions (1958)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Remember (2015)" rsync -avhP "/mnt/unraid/media/Movies/Remember (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Alien Romulus (2024)" rsync -avhP "/mnt/unraid/media/Movies/Alien Romulus (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Sons of Katie Elder (1965)" rsync -avhP "/mnt/synology/rs-movies/The Sons of Katie Elder (1965)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Shrek the Halls (2007)" rsync -avhP "/mnt/synology/rs-movies/Shrek the Halls (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Holiday Touchdown A Chiefs Love Story (2024)" rsync -avhP "/mnt/synology/rs-movies/Holiday Touchdown A Chiefs Love Story (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Men in Black (1997)" rsync -avhP "/mnt/unraid/media/Movies/Men in Black (1997)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Jolly LLB 3 (2025)" rsync -avhP "/mnt/unraid/media/Movies/Jolly LLB 3 (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The NeverEnding Story II The Next Chapter (1990)" rsync -avhP "/mnt/synology/rs-movies/The NeverEnding Story II The Next Chapter (1990)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Island of Forgiveness (2022)" rsync -avhP "/mnt/synology/rs-movies/The Island of Forgiveness (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Scent of a Woman (1992)" rsync -avhP "/mnt/unraid/media/Movies/Scent of a Woman (1992)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Diego Maradona (2019)" rsync -avhP "/mnt/unraid/media/Movies/Diego Maradona (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Rio Grande (1950)" rsync -avhP "/mnt/synology/rs-movies/Rio Grande (1950)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Breathe In (2013)" rsync -avhP "/mnt/unraid/media/Movies/Breathe In (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Orange County (2002)" rsync -avhP "/mnt/synology/rs-movies/Orange County (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Class Action Park (2020)" rsync -avhP "/mnt/synology/rs-movies/Class Action Park (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Lost City (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Lost City (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Home (2025)" rsync -avhP "/mnt/unraid/media/Movies/The Home (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Shaggy Dog (2006)" rsync -avhP "/mnt/synology/rs-movies/The Shaggy Dog (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: High School Musical 2 (2007)" rsync -avhP "/mnt/unraid/media/Movies/High School Musical 2 (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Kalki 2898-AD (2024)" rsync -avhP "/mnt/unraid/media/Movies/Kalki 2898-AD (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Nikki Glaser Someday Youll Die (2024)" rsync -avhP "/mnt/unraid/media/Movies/Nikki Glaser Someday Youll Die (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Revenge of the Green Dragons (2014)" rsync -avhP "/mnt/unraid/media/Movies/Revenge of the Green Dragons (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Beast of War (2025)" rsync -avhP "/mnt/unraid/media/Movies/Beast of War (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: SAS Red Notice (2021)" rsync -avhP "/mnt/synology/rs-movies/SAS Red Notice (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Big George Foreman (2023)" rsync -avhP "/mnt/unraid/media/Movies/Big George Foreman (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Age of Innocence (1993)" rsync -avhP "/mnt/unraid/media/Movies/The Age of Innocence (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dave Chappelle The Closer (2021)" rsync -avhP "/mnt/synology/rs-movies/Dave Chappelle The Closer (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Spoiler Alert (2022)" rsync -avhP "/mnt/unraid/media/Movies/Spoiler Alert (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Nut Job 2 Nutty by Nature (2017)" rsync -avhP "/mnt/synology/rs-movies/The Nut Job 2 Nutty by Nature (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: It Chapter Two (2019)" rsync -avhP "/mnt/unraid/media/Movies/It Chapter Two (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Namesake (2006)" rsync -avhP "/mnt/synology/rs-movies/The Namesake (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Salton Sea (2002)" rsync -avhP "/mnt/synology/rs-movies/The Salton Sea (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Night Flier (1997)" rsync -avhP "/mnt/synology/rs-movies/The Night Flier (1997)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Playground (2021)" rsync -avhP "/mnt/unraid/media/Movies/Playground (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: I Think Were Alone Now (2018)" rsync -avhP "/mnt/synology/rs-movies/I Think Were Alone Now (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Memphis Belle (1990)" rsync -avhP "/mnt/synology/rs-movies/Memphis Belle (1990)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Mickey 17 (2025)" rsync -avhP "/mnt/unraid/media/Movies/Mickey 17 (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: On Becoming a Guinea Fowl (2024)" rsync -avhP "/mnt/unraid/media/Movies/On Becoming a Guinea Fowl (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: No Hard Feelings (2023)" rsync -avhP "/mnt/unraid/media/Movies/No Hard Feelings (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Birdcage (1986)" rsync -avhP "/mnt/synology/rs-movies/The Birdcage (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Devil in a Blue Dress (1995)" rsync -avhP "/mnt/synology/rs-movies/Devil in a Blue Dress (1995)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Taylor Swift The Eras Tour The Final Show (2025)" rsync -avhP "/mnt/synology/rs-movies/Taylor Swift The Eras Tour The Final Show (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Bob Marley One Love (2024)" rsync -avhP "/mnt/unraid/media/Movies/Bob Marley One Love (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Deadpool 2 (2018)" rsync -avhP "/mnt/unraid/media/Movies/Deadpool 2 (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Foreigner (2017)" rsync -avhP "/mnt/unraid/media/Movies/The Foreigner (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Vampires Los Muertos (2002)" rsync -avhP "/mnt/synology/rs-movies/Vampires Los Muertos (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Twilight Saga Eclipse (2010)" rsync -avhP "/mnt/unraid/media/Movies/The Twilight Saga Eclipse (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Ice Pirates (1984)" rsync -avhP "/mnt/synology/rs-movies/The Ice Pirates (1984)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Office Space (1999)" rsync -avhP "/mnt/unraid/media/Movies/Office Space (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Wizard of Oz (1939)" rsync -avhP "/mnt/unraid/media/Movies/The Wizard of Oz (1939)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The House of Yes (1997)" rsync -avhP "/mnt/unraid/media/Movies/The House of Yes (1997)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Peninsula (2020)" rsync -avhP "/mnt/synology/rs-movies/Peninsula (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Megalopolis (2024)" rsync -avhP "/mnt/unraid/media/Movies/Megalopolis (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Because of Winn-Dixie (2005)" rsync -avhP "/mnt/synology/rs-movies/Because of Winn-Dixie (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Risque (2025)" rsync -avhP "/mnt/synology/rs-movies/Risque (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Brightburn (2019)" rsync -avhP "/mnt/synology/rs-movies/Brightburn (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Oxygen (2021)" rsync -avhP "/mnt/unraid/media/Movies/Oxygen (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Outlander (2008)" rsync -avhP "/mnt/synology/rs-movies/Outlander (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Ill Follow You Down (2013)" rsync -avhP "/mnt/unraid/media/Movies/Ill Follow You Down (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Notebook (2004)" rsync -avhP "/mnt/unraid/media/Movies/The Notebook (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Striptease (1996)" rsync -avhP "/mnt/synology/rs-movies/Striptease (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Fletch Lives (1989)" rsync -avhP "/mnt/synology/rs-movies/Fletch Lives (1989)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Stigmata (1999)" rsync -avhP "/mnt/synology/rs-movies/Stigmata (1999)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Spies Like Us (1985)" rsync -avhP "/mnt/synology/rs-movies/Spies Like Us (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Humanity Bureau (2017)" rsync -avhP "/mnt/unraid/media/Movies/The Humanity Bureau (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: War Horse (2011)" rsync -avhP "/mnt/synology/rs-movies/War Horse (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Tom and Jerry Robin Hood and His Merry Mouse (2012)" rsync -avhP "/mnt/synology/rs-movies/Tom and Jerry Robin Hood and His Merry Mouse (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: I Spit on Your Grave (2010)" rsync -avhP "/mnt/synology/rs-movies/I Spit on Your Grave (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Spartan (2004)" rsync -avhP "/mnt/synology/rs-movies/Spartan (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Twilight Zone The Movie (1983)" rsync -avhP "/mnt/unraid/media/Movies/Twilight Zone The Movie (1983)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Robin Hood Prince of Thieves (1991)" rsync -avhP "/mnt/unraid/media/Movies/Robin Hood Prince of Thieves (1991)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Saw III (2006)" rsync -avhP "/mnt/unraid/media/Movies/Saw III (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Batman Assault on Arkham (2014)" rsync -avhP "/mnt/synology/rs-movies/Batman Assault on Arkham (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Kinds of Kindness (2024)" rsync -avhP "/mnt/unraid/media/Movies/Kinds of Kindness (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Clara Sola (2021)" rsync -avhP "/mnt/unraid/media/Movies/Clara Sola (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Blob (1988)" rsync -avhP "/mnt/synology/rs-movies/The Blob (1988)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: A Suite Holiday Romance (2025)" rsync -avhP "/mnt/synology/rs-movies/A Suite Holiday Romance (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Phantasm (1979)" rsync -avhP "/mnt/synology/rs-movies/Phantasm (1979)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Remnant (2024)" rsync -avhP "/mnt/synology/rs-movies/Remnant (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Irresistible (2020)" rsync -avhP "/mnt/synology/rs-movies/Irresistible (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Anemone (2025)" rsync -avhP "/mnt/synology/rs-movies/Anemone (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Pinocchio (2022)" rsync -avhP "/mnt/unraid/media/Movies/Pinocchio (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Glass Onion A Knives Out Mystery (2022)" rsync -avhP "/mnt/unraid/media/Movies/Glass Onion A Knives Out Mystery (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Pump Up the Volume (1990)" rsync -avhP "/mnt/synology/rs-movies/Pump Up the Volume (1990)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Last of the Mohicans (1992)" rsync -avhP "/mnt/synology/rs-movies/The Last of the Mohicans (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Night of the Demons 2 (1994)" rsync -avhP "/mnt/synology/rs-movies/Night of the Demons 2 (1994)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Mill (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Mill (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Critters 2 (1988)" rsync -avhP "/mnt/synology/rs-movies/Critters 2 (1988)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Shadow Land (2024)" rsync -avhP "/mnt/unraid/media/Movies/Shadow Land (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Jeepers Creepers (2001)" rsync -avhP "/mnt/synology/rs-movies/Jeepers Creepers (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: To Wong Foo Thanks for Everything! Julie Newmar (1995)" rsync -avhP "/mnt/synology/rs-movies/To Wong Foo Thanks for Everything! Julie Newmar (1995)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Justice (2024)" rsync -avhP "/mnt/unraid/media/Movies/Justice (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Dreamers (2003)" rsync -avhP "/mnt/unraid/media/Movies/The Dreamers (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Muzzle City of Wolves (2025)" rsync -avhP "/mnt/unraid/media/Movies/Muzzle City of Wolves (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Long Game (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Long Game (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Lamb (2021)" rsync -avhP "/mnt/unraid/media/Movies/Lamb (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Irish Wish (2024)" rsync -avhP "/mnt/unraid/media/Movies/Irish Wish (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Vanishing of Sidney Hall (2018)" rsync -avhP "/mnt/unraid/media/Movies/The Vanishing of Sidney Hall (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: LEGO DC Super Hero Girls Super-Villain High (2018)" rsync -avhP "/mnt/unraid/media/Movies/LEGO DC Super Hero Girls Super-Villain High (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: TRON Legacy (2010)" rsync -avhP "/mnt/unraid/media/Movies/TRON Legacy (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Tomcats (2001)" rsync -avhP "/mnt/synology/rs-movies/Tomcats (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Spiderhead (2022)" rsync -avhP "/mnt/synology/rs-movies/Spiderhead (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Initiation Silent Night Deadly Night 4 (1990)" rsync -avhP "/mnt/synology/rs-movies/Initiation Silent Night Deadly Night 4 (1990)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Be My Valentine Charlie Brown (1975)" rsync -avhP "/mnt/unraid/media/Movies/Be My Valentine Charlie Brown (1975)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Back to the Future (1985)" rsync -avhP "/mnt/synology/rs-movies/Back to the Future (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: A Warriors Fighting Spirit (1979)" rsync -avhP "/mnt/synology/rs-movies/A Warriors Fighting Spirit (1979)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: A Grand Ole Opry Christmas (2025)" rsync -avhP "/mnt/synology/rs-movies/A Grand Ole Opry Christmas (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Cannonball Run II (1984)" rsync -avhP "/mnt/synology/rs-movies/Cannonball Run II (1984)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: You Wont Be Alone (2022)" rsync -avhP "/mnt/synology/rs-movies/You Wont Be Alone (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Lilo and Stitch (2002)" rsync -avhP "/mnt/unraid/media/Movies/Lilo and Stitch (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Art of Racing in the Rain (2019)" rsync -avhP "/mnt/unraid/media/Movies/The Art of Racing in the Rain (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Chameleon Street (1991)" rsync -avhP "/mnt/unraid/media/Movies/Chameleon Street (1991)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Silent Night (2023)" rsync -avhP "/mnt/unraid/media/Movies/Silent Night (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Firewalker (1986)" rsync -avhP "/mnt/synology/rs-movies/Firewalker (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Battle of the Sexes (2017)" rsync -avhP "/mnt/synology/rs-movies/Battle of the Sexes (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Hour of the Gun (1967)" rsync -avhP "/mnt/synology/rs-movies/Hour of the Gun (1967)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Locksmith (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Locksmith (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Planet 51 (2009)" rsync -avhP "/mnt/unraid/media/Movies/Planet 51 (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Rescue Dawn (2007)" rsync -avhP "/mnt/unraid/media/Movies/Rescue Dawn (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Thor (2011)" rsync -avhP "/mnt/unraid/media/Movies/Thor (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Watcher in the Woods (1980)" rsync -avhP "/mnt/synology/rs-movies/The Watcher in the Woods (1980)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Eddington (2025)" rsync -avhP "/mnt/unraid/media/Movies/Eddington (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Stalking Moon (1968)" rsync -avhP "/mnt/synology/rs-movies/The Stalking Moon (1968)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Wrecking Crew (1968)" rsync -avhP "/mnt/synology/rs-movies/The Wrecking Crew (1968)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The 13th Warrior (1999)" rsync -avhP "/mnt/unraid/media/Movies/The 13th Warrior (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Traitor (2008)" rsync -avhP "/mnt/unraid/media/Movies/Traitor (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Marvel Studios The Fantastic Four First Steps World Premiere (2025)" rsync -avhP "/mnt/synology/rs-movies/Marvel Studios The Fantastic Four First Steps World Premiere (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Twilight Saga Breaking Dawn Part 2 (2012)" rsync -avhP "/mnt/unraid/media/Movies/The Twilight Saga Breaking Dawn Part 2 (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Caligula (1979)" rsync -avhP "/mnt/unraid/media/Movies/Caligula (1979)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Barton Fink (1991)" rsync -avhP "/mnt/synology/rs-movies/Barton Fink (1991)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Dead Zone (1983)" rsync -avhP "/mnt/unraid/media/Movies/The Dead Zone (1983)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Bad Lieutenant (1992)" rsync -avhP "/mnt/synology/rs-movies/Bad Lieutenant (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: What Ever Happened to Baby Jane (1962)" rsync -avhP "/mnt/synology/rs-movies/What Ever Happened to Baby Jane (1962)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Hunger Games Mockingjay Part 2 (2015)" rsync -avhP "/mnt/unraid/media/Movies/The Hunger Games Mockingjay Part 2 (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Troll (2022)" rsync -avhP "/mnt/unraid/media/Movies/Troll (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Night at the Museum Battle of the Smithsonian (2009)" rsync -avhP "/mnt/synology/rs-movies/Night at the Museum Battle of the Smithsonian (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Harry Potter and the Deathly Hallows Part 2 (2011)" rsync -avhP "/mnt/unraid/media/Movies/Harry Potter and the Deathly Hallows Part 2 (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Evil Dead II (1987)" rsync -avhP "/mnt/unraid/media/Movies/Evil Dead II (1987)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: 300 Rise of an Empire (2014)" rsync -avhP "/mnt/unraid/media/Movies/300 Rise of an Empire (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Blood Machines (2020)" rsync -avhP "/mnt/synology/rs-movies/Blood Machines (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: 1941 (1979)" rsync -avhP "/mnt/synology/rs-movies/1941 (1979)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Robotech The Shadow Chronicles (2006)" rsync -avhP "/mnt/synology/rs-movies/Robotech The Shadow Chronicles (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Return to Me (2000)" rsync -avhP "/mnt/synology/rs-movies/Return to Me (2000)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Blood and Money (2020)" rsync -avhP "/mnt/synology/rs-movies/Blood and Money (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Go (1999)" rsync -avhP "/mnt/synology/rs-movies/Go (1999)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Bob Ross Happy Accidents Betrayal and Greed (2021)" rsync -avhP "/mnt/unraid/media/Movies/Bob Ross Happy Accidents Betrayal and Greed (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Undisputed II Last Man Standing (2006)" rsync -avhP "/mnt/synology/rs-movies/Undisputed II Last Man Standing (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Total Recall (2012)" rsync -avhP "/mnt/unraid/media/Movies/Total Recall (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Mulan (2020)" rsync -avhP "/mnt/unraid/media/Movies/Mulan (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Missing (2023)" rsync -avhP "/mnt/unraid/media/Movies/Missing (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Starship Troopers (1997)" rsync -avhP "/mnt/unraid/media/Movies/Starship Troopers (1997)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Baghead (2023)" rsync -avhP "/mnt/unraid/media/Movies/Baghead (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Killer (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Killer (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: A Haunted House (2013)" rsync -avhP "/mnt/synology/rs-movies/A Haunted House (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: A Minecraft Movie (2025)" rsync -avhP "/mnt/unraid/media/Movies/A Minecraft Movie (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Civil War (2024)" rsync -avhP "/mnt/unraid/media/Movies/Civil War (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Most Dangerous Game (2020)" rsync -avhP "/mnt/unraid/media/Movies/Most Dangerous Game (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Strange Wilderness (2008)" rsync -avhP "/mnt/synology/rs-movies/Strange Wilderness (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Elevation (2024)" rsync -avhP "/mnt/unraid/media/Movies/Elevation (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Rudolph the Red-Nosed Reindeer (1964)" rsync -avhP "/mnt/unraid/media/Movies/Rudolph the Red-Nosed Reindeer (1964)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Doghouse (2009)" rsync -avhP "/mnt/synology/rs-movies/Doghouse (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Perpetrator (2023)" rsync -avhP "/mnt/unraid/media/Movies/Perpetrator (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hoodwinked! (2005)" rsync -avhP "/mnt/synology/rs-movies/Hoodwinked! (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Guilty (2018)" rsync -avhP "/mnt/synology/rs-movies/The Guilty (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Soul Surfer (2011)" rsync -avhP "/mnt/synology/rs-movies/Soul Surfer (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: 1917 (2019)" rsync -avhP "/mnt/unraid/media/Movies/1917 (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Winter War (1989)" rsync -avhP "/mnt/unraid/media/Movies/The Winter War (1989)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Hercules (2014)" rsync -avhP "/mnt/unraid/media/Movies/Hercules (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: A Nightmare on Elm Street (1984)" rsync -avhP "/mnt/unraid/media/Movies/A Nightmare on Elm Street (1984)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Jurassic World Dominion (2022)" rsync -avhP "/mnt/unraid/media/Movies/Jurassic World Dominion (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Wrong Turn (2003)" rsync -avhP "/mnt/unraid/media/Movies/Wrong Turn (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Cell (2000)" rsync -avhP "/mnt/synology/rs-movies/The Cell (2000)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Starship Troopers Traitor of Mars (2017)" rsync -avhP "/mnt/synology/rs-movies/Starship Troopers Traitor of Mars (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Angel (2018)" rsync -avhP "/mnt/unraid/media/Movies/The Angel (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Midnight in the Switchgrass (2021)" rsync -avhP "/mnt/synology/rs-movies/Midnight in the Switchgrass (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Passenger 57 (1992)" rsync -avhP "/mnt/synology/rs-movies/Passenger 57 (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Uncle Buck (1989)" rsync -avhP "/mnt/unraid/media/Movies/Uncle Buck (1989)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Jungle Cruise (2021)" rsync -avhP "/mnt/unraid/media/Movies/Jungle Cruise (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Beast (2022)" rsync -avhP "/mnt/unraid/media/Movies/Beast (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Daddys Head (2024)" rsync -avhP "/mnt/unraid/media/Movies/Daddys Head (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: There Will Be Blood (2007)" rsync -avhP "/mnt/unraid/media/Movies/There Will Be Blood (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Puppy Love (2023)" rsync -avhP "/mnt/synology/rs-movies/Puppy Love (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: 65 (2023)" rsync -avhP "/mnt/unraid/media/Movies/65 (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Naked Gun 33⅓ The Final Insult (1994)" rsync -avhP "/mnt/unraid/media/Movies/Naked Gun 33⅓ The Final Insult (1994)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Fear and Loathing in Las Vegas (1998)" rsync -avhP "/mnt/synology/rs-movies/Fear and Loathing in Las Vegas (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Trinity and Beyond The Atomic Bomb Movie (1995)" rsync -avhP "/mnt/unraid/media/Movies/Trinity and Beyond The Atomic Bomb Movie (1995)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Pokemon Zoroark Master of Illusions (2010)" rsync -avhP "/mnt/synology/rs-movies/Pokemon Zoroark Master of Illusions (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Orgazmo (1998)" rsync -avhP "/mnt/synology/rs-movies/Orgazmo (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Songbird (2020)" rsync -avhP "/mnt/unraid/media/Movies/Songbird (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Spider-Man No Way Home (2021)" rsync -avhP "/mnt/synology/rs-movies/Spider-Man No Way Home (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Despicable Me 4 (2024)" rsync -avhP "/mnt/unraid/media/Movies/Despicable Me 4 (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Land Before Time II The Great Valley Adventure (1994)" rsync -avhP "/mnt/unraid/media/Movies/The Land Before Time II The Great Valley Adventure (1994)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Expendables (2010)" rsync -avhP "/mnt/unraid/media/Movies/The Expendables (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Burning (1981)" rsync -avhP "/mnt/unraid/media/Movies/The Burning (1981)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Sum of All Fears (2002)" rsync -avhP "/mnt/synology/rs-movies/The Sum of All Fears (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Disappearance of Alice Creed (2009)" rsync -avhP "/mnt/synology/rs-movies/The Disappearance of Alice Creed (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Se7en (1995)" rsync -avhP "/mnt/unraid/media/Movies/Se7en (1995)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Kung Fu Panda 4 (2024)" rsync -avhP "/mnt/unraid/media/Movies/Kung Fu Panda 4 (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Must Love Dogs (2005)" rsync -avhP "/mnt/unraid/media/Movies/Must Love Dogs (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Macbeth (2015)" rsync -avhP "/mnt/synology/rs-movies/Macbeth (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Dont Tell Mom the Babysitters Dead (2024)" rsync -avhP "/mnt/synology/rs-movies/Dont Tell Mom the Babysitters Dead (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Transporter 2 (2005)" rsync -avhP "/mnt/unraid/media/Movies/Transporter 2 (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Phenomenon (1996)" rsync -avhP "/mnt/unraid/media/Movies/Phenomenon (1996)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Marching Powder (2025)" rsync -avhP "/mnt/unraid/media/Movies/Marching Powder (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Empire Strikes Back (1980)" rsync -avhP "/mnt/unraid/media/Movies/The Empire Strikes Back (1980)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Setup (2011)" rsync -avhP "/mnt/unraid/media/Movies/Setup (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Toymaker (2017)" rsync -avhP "/mnt/synology/rs-movies/The Toymaker (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Cheaper by the Dozen 2 (2005)" rsync -avhP "/mnt/synology/rs-movies/Cheaper by the Dozen 2 (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Exorcism of Hannah Stevenson (2022)" rsync -avhP "/mnt/synology/rs-movies/The Exorcism of Hannah Stevenson (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: In the Line of Fire (1993)" rsync -avhP "/mnt/unraid/media/Movies/In the Line of Fire (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Last Full Measure (2020)" rsync -avhP "/mnt/unraid/media/Movies/The Last Full Measure (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Gold (2022)" rsync -avhP "/mnt/unraid/media/Movies/Gold (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Roses (2025)" rsync -avhP "/mnt/unraid/media/Movies/The Roses (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Shift (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Shift (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Phantom (1996)" rsync -avhP "/mnt/synology/rs-movies/The Phantom (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Transformers One (2024)" rsync -avhP "/mnt/unraid/media/Movies/Transformers One (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Fit for a Prince (2021)" rsync -avhP "/mnt/unraid/media/Movies/Fit for a Prince (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Little Dixie (2023)" rsync -avhP "/mnt/unraid/media/Movies/Little Dixie (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Surfs Up (2007)" rsync -avhP "/mnt/synology/rs-movies/Surfs Up (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Rental (2020)" rsync -avhP "/mnt/synology/rs-movies/The Rental (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Dark Crystal (1982)" rsync -avhP "/mnt/synology/rs-movies/The Dark Crystal (1982)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Terrifier (2018)" rsync -avhP "/mnt/unraid/media/Movies/Terrifier (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Happily Ever After (1989)" rsync -avhP "/mnt/synology/rs-movies/Happily Ever After (1989)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Heaven Knows Mr. Allison (1957)" rsync -avhP "/mnt/synology/rs-movies/Heaven Knows Mr. Allison (1957)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Deadly Friend (1986)" rsync -avhP "/mnt/unraid/media/Movies/Deadly Friend (1986)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hard Target (1993)" rsync -avhP "/mnt/synology/rs-movies/Hard Target (1993)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Vicious (2025)" rsync -avhP "/mnt/synology/rs-movies/Vicious (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Onward (2020)" rsync -avhP "/mnt/unraid/media/Movies/Onward (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Librarian Quest for the Spear (2004)" rsync -avhP "/mnt/synology/rs-movies/The Librarian Quest for the Spear (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Hack Your Health The Secrets of Your Gut (2024)" rsync -avhP "/mnt/synology/rs-movies/Hack Your Health The Secrets of Your Gut (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Rumble (2021)" rsync -avhP "/mnt/unraid/media/Movies/Rumble (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Conan the Barbarian (1982)" rsync -avhP "/mnt/unraid/media/Movies/Conan the Barbarian (1982)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The East (2013)" rsync -avhP "/mnt/synology/rs-movies/The East (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Off Limits (1988)" rsync -avhP "/mnt/unraid/media/Movies/Off Limits (1988)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Batman The Doom That Came to Gotham (2023)" rsync -avhP "/mnt/unraid/media/Movies/Batman The Doom That Came to Gotham (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Lagaan Once Upon a Time in India (2001)" rsync -avhP "/mnt/unraid/media/Movies/Lagaan Once Upon a Time in India (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Downton Abbey A New Era (2022)" rsync -avhP "/mnt/unraid/media/Movies/Downton Abbey A New Era (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Wham! Last Christmas Unwrapped (2024)" rsync -avhP "/mnt/synology/rs-movies/Wham! Last Christmas Unwrapped (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Midnight Sky (2020)" rsync -avhP "/mnt/unraid/media/Movies/The Midnight Sky (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Bad Boys II (2003)" rsync -avhP "/mnt/unraid/media/Movies/Bad Boys II (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Murderers Row (1966)" rsync -avhP "/mnt/synology/rs-movies/Murderers Row (1966)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Cruella (2021)" rsync -avhP "/mnt/unraid/media/Movies/Cruella (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Small Things Like These (2024)" rsync -avhP "/mnt/unraid/media/Movies/Small Things Like These (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Ghost in the Shell 2 Innocence (2004)" rsync -avhP "/mnt/synology/rs-movies/Ghost in the Shell 2 Innocence (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: American Pie Presents The Naked Mile (2006)" rsync -avhP "/mnt/unraid/media/Movies/American Pie Presents The Naked Mile (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: BRATS (2024)" rsync -avhP "/mnt/unraid/media/Movies/BRATS (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Hercules (1997)" rsync -avhP "/mnt/unraid/media/Movies/Hercules (1997)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dracula Dead and Loving It (1995)" rsync -avhP "/mnt/synology/rs-movies/Dracula Dead and Loving It (1995)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Snowman (1982)" rsync -avhP "/mnt/synology/rs-movies/The Snowman (1982)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Kuffs (1992)" rsync -avhP "/mnt/synology/rs-movies/Kuffs (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Linoleum (2023)" rsync -avhP "/mnt/synology/rs-movies/Linoleum (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Stalag 17 (1953)" rsync -avhP "/mnt/unraid/media/Movies/Stalag 17 (1953)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Regretting You (2025)" rsync -avhP "/mnt/synology/rs-movies/Regretting You (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Louis C.K. Hilarious (2010)" rsync -avhP "/mnt/synology/rs-movies/Louis C.K. Hilarious (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Fantasy Island (2020)" rsync -avhP "/mnt/synology/rs-movies/Fantasy Island (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Zombeavers (2014)" rsync -avhP "/mnt/unraid/media/Movies/Zombeavers (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Score (2001)" rsync -avhP "/mnt/unraid/media/Movies/The Score (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Public (2019)" rsync -avhP "/mnt/unraid/media/Movies/The Public (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Boogie Nights (1997)" rsync -avhP "/mnt/unraid/media/Movies/Boogie Nights (1997)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: An American in Paris (1951)" rsync -avhP "/mnt/unraid/media/Movies/An American in Paris (1951)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Starship Troopers 3 Marauder (2008)" rsync -avhP "/mnt/synology/rs-movies/Starship Troopers 3 Marauder (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: 22 vs. Earth (2021)" rsync -avhP "/mnt/synology/rs-movies/22 vs. Earth (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: My Little Pony Equestria Girls Forgotten Friendship (2018)" rsync -avhP "/mnt/synology/rs-movies/My Little Pony Equestria Girls Forgotten Friendship (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Theres Something Wrong with the Children (2023)" rsync -avhP "/mnt/synology/rs-movies/Theres Something Wrong with the Children (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Nymphomaniac Vol. II (2013)" rsync -avhP "/mnt/unraid/media/Movies/Nymphomaniac Vol. II (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Fractured (2019)" rsync -avhP "/mnt/synology/rs-movies/Fractured (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Tom Segura Ball Hog (2020)" rsync -avhP "/mnt/synology/rs-movies/Tom Segura Ball Hog (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: 18 (2022)" rsync -avhP "/mnt/synology/rs-movies/18 (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Black Lotus (2023)" rsync -avhP "/mnt/unraid/media/Movies/Black Lotus (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Fort Apache (1948)" rsync -avhP "/mnt/synology/rs-movies/Fort Apache (1948)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Snow White (2025)" rsync -avhP "/mnt/unraid/media/Movies/Snow White (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Outrun (2024)" rsync -avhP "/mnt/synology/rs-movies/The Outrun (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Curse of the Jade Scorpion (2001)" rsync -avhP "/mnt/synology/rs-movies/The Curse of the Jade Scorpion (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Hollywoodland (2006)" rsync -avhP "/mnt/synology/rs-movies/Hollywoodland (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Broke (2025)" rsync -avhP "/mnt/synology/rs-movies/Broke (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Amelie (2001)" rsync -avhP "/mnt/unraid/media/Movies/Amelie (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: F1 (2025)" rsync -avhP "/mnt/unraid/media/Movies/F1 (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Man of the Year (2006)" rsync -avhP "/mnt/unraid/media/Movies/Man of the Year (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: End of the Road (2022)" rsync -avhP "/mnt/unraid/media/Movies/End of the Road (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Enders Game (2013)" rsync -avhP "/mnt/unraid/media/Movies/Enders Game (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: My Own Private Idaho (1991)" rsync -avhP "/mnt/synology/rs-movies/My Own Private Idaho (1991)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Last Sharknado Its About Time (2018)" rsync -avhP "/mnt/unraid/media/Movies/The Last Sharknado Its About Time (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: A Knights Tale (2001)" rsync -avhP "/mnt/unraid/media/Movies/A Knights Tale (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dracula (1931)" rsync -avhP "/mnt/synology/rs-movies/Dracula (1931)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Look Into My Eyes (2024)" rsync -avhP "/mnt/unraid/media/Movies/Look Into My Eyes (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: As Above So Below (2014)" rsync -avhP "/mnt/synology/rs-movies/As Above So Below (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Flags of Our Fathers (2006)" rsync -avhP "/mnt/synology/rs-movies/Flags of Our Fathers (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Swiss Army Man (2016)" rsync -avhP "/mnt/unraid/media/Movies/Swiss Army Man (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: 47 Meters Down (2017)" rsync -avhP "/mnt/unraid/media/Movies/47 Meters Down (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Over the Hedge (2006)" rsync -avhP "/mnt/unraid/media/Movies/Over the Hedge (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Nandor Fodor and the Talking Mongoose (2023)" rsync -avhP "/mnt/synology/rs-movies/Nandor Fodor and the Talking Mongoose (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Its Christmas Eve (2018)" rsync -avhP "/mnt/synology/rs-movies/Its Christmas Eve (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Jim Jefferies Two Limb Policy (2025)" rsync -avhP "/mnt/unraid/media/Movies/Jim Jefferies Two Limb Policy (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Shadow in the Cloud (2021)" rsync -avhP "/mnt/synology/rs-movies/Shadow in the Cloud (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: A Shine of Rainbows (2009)" rsync -avhP "/mnt/unraid/media/Movies/A Shine of Rainbows (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: I Robot (2004)" rsync -avhP "/mnt/synology/rs-movies/I Robot (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Flight (2012)" rsync -avhP "/mnt/synology/rs-movies/Flight (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: 10 Minutes Gone (2019)" rsync -avhP "/mnt/synology/rs-movies/10 Minutes Gone (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Summer of 84 (2018)" rsync -avhP "/mnt/synology/rs-movies/Summer of 84 (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Drop (2014)" rsync -avhP "/mnt/unraid/media/Movies/The Drop (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Sound of Hope The Story of Possum Trot (2024)" rsync -avhP "/mnt/synology/rs-movies/Sound of Hope The Story of Possum Trot (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Punisher (1989)" rsync -avhP "/mnt/unraid/media/Movies/The Punisher (1989)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Passion of the Christ (2004)" rsync -avhP "/mnt/synology/rs-movies/The Passion of the Christ (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Jobs (2013)" rsync -avhP "/mnt/synology/rs-movies/Jobs (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Brainscan (1994)" rsync -avhP "/mnt/synology/rs-movies/Brainscan (1994)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Vision Quest (1985)" rsync -avhP "/mnt/synology/rs-movies/Vision Quest (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: First Shift (2024)" rsync -avhP "/mnt/synology/rs-movies/First Shift (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Mickeys Magical Christmas Snowed in at the House of Mouse (2001)" rsync -avhP "/mnt/synology/rs-movies/Mickeys Magical Christmas Snowed in at the House of Mouse (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Coffee Town (2013)" rsync -avhP "/mnt/unraid/media/Movies/Coffee Town (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Universal Soldier Regeneration (2010)" rsync -avhP "/mnt/synology/rs-movies/Universal Soldier Regeneration (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Naked Gun 2½ The Smell of Fear (1991)" rsync -avhP "/mnt/unraid/media/Movies/The Naked Gun 2½ The Smell of Fear (1991)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Goosebumps (2015)" rsync -avhP "/mnt/unraid/media/Movies/Goosebumps (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Art Attack! The Dissection of Terrifier 3 (2025)" rsync -avhP "/mnt/synology/rs-movies/Art Attack! The Dissection of Terrifier 3 (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Armor (2024)" rsync -avhP "/mnt/synology/rs-movies/Armor (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Pianist (2002)" rsync -avhP "/mnt/unraid/media/Movies/The Pianist (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Clash of the Titans (1981)" rsync -avhP "/mnt/synology/rs-movies/Clash of the Titans (1981)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Papillon (2017)" rsync -avhP "/mnt/unraid/media/Movies/Papillon (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Blue Hawaii (1961)" rsync -avhP "/mnt/synology/rs-movies/Blue Hawaii (1961)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Graduate (1967)" rsync -avhP "/mnt/unraid/media/Movies/The Graduate (1967)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Souvenir Part II (2021)" rsync -avhP "/mnt/unraid/media/Movies/The Souvenir Part II (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Horse Soldiers (1959)" rsync -avhP "/mnt/synology/rs-movies/The Horse Soldiers (1959)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Gary Owen #DoinWhatIDo (2019)" rsync -avhP "/mnt/synology/rs-movies/Gary Owen #DoinWhatIDo (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: While You Were Sleeping (1995)" rsync -avhP "/mnt/synology/rs-movies/While You Were Sleeping (1995)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Riddick (2013)" rsync -avhP "/mnt/unraid/media/Movies/Riddick (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Big 4 (2022)" rsync -avhP "/mnt/synology/rs-movies/The Big 4 (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Gamera Guardian of the Universe (1995)" rsync -avhP "/mnt/synology/rs-movies/Gamera Guardian of the Universe (1995)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Atlantis The Lost Empire (2001)" rsync -avhP "/mnt/unraid/media/Movies/Atlantis The Lost Empire (2001)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Meet the Parents (2000)" rsync -avhP "/mnt/unraid/media/Movies/Meet the Parents (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Watchmen Chapter I (2024)" rsync -avhP "/mnt/unraid/media/Movies/Watchmen Chapter I (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Apprentice (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Apprentice (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Interview (2014)" rsync -avhP "/mnt/unraid/media/Movies/The Interview (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Azrael (2024)" rsync -avhP "/mnt/unraid/media/Movies/Azrael (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Zombieland (2009)" rsync -avhP "/mnt/unraid/media/Movies/Zombieland (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Survive the Night (2020)" rsync -avhP "/mnt/synology/rs-movies/Survive the Night (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: 21 Bridges (2019)" rsync -avhP "/mnt/unraid/media/Movies/21 Bridges (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Around the World in 80 Days (2004)" rsync -avhP "/mnt/unraid/media/Movies/Around the World in 80 Days (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: She Came to Me (2023)" rsync -avhP "/mnt/synology/rs-movies/She Came to Me (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Substance (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Substance (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Jersey Boys (2014)" rsync -avhP "/mnt/synology/rs-movies/Jersey Boys (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Miss Americana (2020)" rsync -avhP "/mnt/synology/rs-movies/Miss Americana (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Over the Moon (2020)" rsync -avhP "/mnt/unraid/media/Movies/Over the Moon (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Velvet Queen (2021)" rsync -avhP "/mnt/unraid/media/Movies/The Velvet Queen (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Backtrace (2018)" rsync -avhP "/mnt/synology/rs-movies/Backtrace (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Rescuers (1977)" rsync -avhP "/mnt/unraid/media/Movies/The Rescuers (1977)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Land of Bad (2024)" rsync -avhP "/mnt/unraid/media/Movies/Land of Bad (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Heathers (1988)" rsync -avhP "/mnt/unraid/media/Movies/Heathers (1988)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Puss in Boots The Last Wish (2022)" rsync -avhP "/mnt/unraid/media/Movies/Puss in Boots The Last Wish (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Voices (2014)" rsync -avhP "/mnt/synology/rs-movies/The Voices (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Night of the Hunted (2023)" rsync -avhP "/mnt/unraid/media/Movies/Night of the Hunted (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Chronicles of Riddick (2004)" rsync -avhP "/mnt/unraid/media/Movies/The Chronicles of Riddick (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Medieval (2022)" rsync -avhP "/mnt/synology/rs-movies/Medieval (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Sebastian Maniscalco Stay Hungry (2019)" rsync -avhP "/mnt/unraid/media/Movies/Sebastian Maniscalco Stay Hungry (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: My Father the Spy (2019)" rsync -avhP "/mnt/synology/rs-movies/My Father the Spy (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Prisoner of War (2025)" rsync -avhP "/mnt/unraid/media/Movies/Prisoner of War (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Abbott and Costello Go to Mars (1953)" rsync -avhP "/mnt/synology/rs-movies/Abbott and Costello Go to Mars (1953)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Saint (1997)" rsync -avhP "/mnt/unraid/media/Movies/The Saint (1997)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Absent-Minded Professor (1961)" rsync -avhP "/mnt/synology/rs-movies/The Absent-Minded Professor (1961)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Sling Blade (1996)" rsync -avhP "/mnt/synology/rs-movies/Sling Blade (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: A Good Day to Die Hard (2013)" rsync -avhP "/mnt/unraid/media/Movies/A Good Day to Die Hard (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Denial (2016)" rsync -avhP "/mnt/synology/rs-movies/Denial (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Raising Arizona (1987)" rsync -avhP "/mnt/synology/rs-movies/Raising Arizona (1987)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Zootopia (2016)" rsync -avhP "/mnt/unraid/media/Movies/Zootopia (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Oklahoma City Bombing American Terror (2025)" rsync -avhP "/mnt/unraid/media/Movies/Oklahoma City Bombing American Terror (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Brokeback Mountain (2005)" rsync -avhP "/mnt/unraid/media/Movies/Brokeback Mountain (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Ford v Ferrari (2019)" rsync -avhP "/mnt/unraid/media/Movies/Ford v Ferrari (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Underworld Blood Wars (2016)" rsync -avhP "/mnt/unraid/media/Movies/Underworld Blood Wars (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Red One (2024)" rsync -avhP "/mnt/unraid/media/Movies/Red One (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Childs Play 2 (1990)" rsync -avhP "/mnt/unraid/media/Movies/Childs Play 2 (1990)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Portable Door (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Portable Door (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Brothers Solomon (2007)" rsync -avhP "/mnt/synology/rs-movies/The Brothers Solomon (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Us Again (2021)" rsync -avhP "/mnt/unraid/media/Movies/Us Again (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Howling (1981)" rsync -avhP "/mnt/synology/rs-movies/The Howling (1981)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: No Time for Sergeants (1958)" rsync -avhP "/mnt/synology/rs-movies/No Time for Sergeants (1958)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Along Came Polly (2004)" rsync -avhP "/mnt/unraid/media/Movies/Along Came Polly (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Retirement Plan (2023)" rsync -avhP "/mnt/synology/rs-movies/The Retirement Plan (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Crawl (2019)" rsync -avhP "/mnt/synology/rs-movies/Crawl (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Nude Nuns with Big Guns (2010)" rsync -avhP "/mnt/unraid/media/Movies/Nude Nuns with Big Guns (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: First They Killed My Father (2017)" rsync -avhP "/mnt/unraid/media/Movies/First They Killed My Father (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Your Place or Mine (2023)" rsync -avhP "/mnt/synology/rs-movies/Your Place or Mine (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Unbreakable (2000)" rsync -avhP "/mnt/unraid/media/Movies/Unbreakable (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: No Man of God (2021)" rsync -avhP "/mnt/unraid/media/Movies/No Man of God (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dragonball Evolution (2009)" rsync -avhP "/mnt/synology/rs-movies/Dragonball Evolution (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Bubba Ho-tep (2002)" rsync -avhP "/mnt/unraid/media/Movies/Bubba Ho-tep (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Cathedral (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Cathedral (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Tropic Thunder (2008)" rsync -avhP "/mnt/unraid/media/Movies/Tropic Thunder (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Air Strike (2018)" rsync -avhP "/mnt/synology/rs-movies/Air Strike (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Titanic (1997)" rsync -avhP "/mnt/unraid/media/Movies/Titanic (1997)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Freaks (1932)" rsync -avhP "/mnt/synology/rs-movies/Freaks (1932)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Batman vs. Dracula (2005)" rsync -avhP "/mnt/synology/rs-movies/The Batman vs. Dracula (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Tom and Jerry Snowmans Land (2022)" rsync -avhP "/mnt/unraid/media/Movies/Tom and Jerry Snowmans Land (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Ballerina (2025)" rsync -avhP "/mnt/unraid/media/Movies/Ballerina (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: MR-9 Do or Die (2023)" rsync -avhP "/mnt/synology/rs-movies/MR-9 Do or Die (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: American Ninja 4 The Annihilation (1990)" rsync -avhP "/mnt/synology/rs-movies/American Ninja 4 The Annihilation (1990)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Relic (2020)" rsync -avhP "/mnt/synology/rs-movies/Relic (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Forgetting Sarah Marshall (2008)" rsync -avhP "/mnt/unraid/media/Movies/Forgetting Sarah Marshall (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Friday the 13th A New Beginning (1985)" rsync -avhP "/mnt/synology/rs-movies/Friday the 13th A New Beginning (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Legend of Tarzan (2016)" rsync -avhP "/mnt/unraid/media/Movies/The Legend of Tarzan (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Donbass (2016)" rsync -avhP "/mnt/synology/rs-movies/Donbass (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Pacific Rim (2013)" rsync -avhP "/mnt/unraid/media/Movies/Pacific Rim (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Furiosa A Mad Max Saga (2024)" rsync -avhP "/mnt/unraid/media/Movies/Furiosa A Mad Max Saga (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Terminator Dark Fate (2019)" rsync -avhP "/mnt/unraid/media/Movies/Terminator Dark Fate (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Star Wars (1977)" rsync -avhP "/mnt/unraid/media/Movies/Star Wars (1977)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Deep Blue Sea (1999)" rsync -avhP "/mnt/unraid/media/Movies/Deep Blue Sea (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Cat in the Hat (2003)" rsync -avhP "/mnt/unraid/media/Movies/The Cat in the Hat (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Super (2018)" rsync -avhP "/mnt/synology/rs-movies/The Super (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Maximum Ride (2016)" rsync -avhP "/mnt/synology/rs-movies/Maximum Ride (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Rubikon (2022)" rsync -avhP "/mnt/unraid/media/Movies/Rubikon (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Burning Sea (2021)" rsync -avhP "/mnt/unraid/media/Movies/The Burning Sea (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Homesman (2014)" rsync -avhP "/mnt/synology/rs-movies/The Homesman (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Song of the South (1946)" rsync -avhP "/mnt/synology/rs-movies/Song of the South (1946)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Dirty Rotten Scoundrels (1988)" rsync -avhP "/mnt/unraid/media/Movies/Dirty Rotten Scoundrels (1988)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Margaret (2011)" rsync -avhP "/mnt/unraid/media/Movies/Margaret (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Sixteen Candles (1984)" rsync -avhP "/mnt/unraid/media/Movies/Sixteen Candles (1984)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Cannonball Run (1981)" rsync -avhP "/mnt/unraid/media/Movies/The Cannonball Run (1981)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Miraculous Ladybug and Cat Noir The Movie (2023)" rsync -avhP "/mnt/unraid/media/Movies/Miraculous Ladybug and Cat Noir The Movie (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Legend of the Lost (1957)" rsync -avhP "/mnt/synology/rs-movies/Legend of the Lost (1957)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Justice League x RWBY Super Heroes and Huntsmen Part One (2023)" rsync -avhP "/mnt/unraid/media/Movies/Justice League x RWBY Super Heroes and Huntsmen Part One (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Love Never Dies (2012)" rsync -avhP "/mnt/unraid/media/Movies/Love Never Dies (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Christina P Mom Genes (2022)" rsync -avhP "/mnt/synology/rs-movies/Christina P Mom Genes (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Mortal Kombat Legends Snow Blind (2022)" rsync -avhP "/mnt/synology/rs-movies/Mortal Kombat Legends Snow Blind (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Cars 2 (2011)" rsync -avhP "/mnt/unraid/media/Movies/Cars 2 (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Mask (1994)" rsync -avhP "/mnt/unraid/media/Movies/The Mask (1994)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Journey to Bethlehem (2023)" rsync -avhP "/mnt/synology/rs-movies/Journey to Bethlehem (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Dolemite Is My Name (2019)" rsync -avhP "/mnt/unraid/media/Movies/Dolemite Is My Name (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The A-Team (2010)" rsync -avhP "/mnt/synology/rs-movies/The A-Team (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Mission Impossible Fallout (2018)" rsync -avhP "/mnt/unraid/media/Movies/Mission Impossible Fallout (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Come Out Fighting (2023)" rsync -avhP "/mnt/synology/rs-movies/Come Out Fighting (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Flow (2024)" rsync -avhP "/mnt/synology/rs-movies/Flow (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Land and Freedom (1995)" rsync -avhP "/mnt/unraid/media/Movies/Land and Freedom (1995)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: River of Blood (2024)" rsync -avhP "/mnt/synology/rs-movies/River of Blood (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Winters Bone (2010)" rsync -avhP "/mnt/unraid/media/Movies/Winters Bone (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Long Walk (2025)" rsync -avhP "/mnt/unraid/media/Movies/The Long Walk (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: A Christmas Story Christmas (2022)" rsync -avhP "/mnt/unraid/media/Movies/A Christmas Story Christmas (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Bonjour Tristesse (2025)" rsync -avhP "/mnt/synology/rs-movies/Bonjour Tristesse (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Bird on a Wire (1990)" rsync -avhP "/mnt/synology/rs-movies/Bird on a Wire (1990)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Alvin and the Chipmunks The Road Chip (2015)" rsync -avhP "/mnt/synology/rs-movies/Alvin and the Chipmunks The Road Chip (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Endless (2017)" rsync -avhP "/mnt/synology/rs-movies/The Endless (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Shadow (2018)" rsync -avhP "/mnt/synology/rs-movies/Shadow (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Parker (2013)" rsync -avhP "/mnt/unraid/media/Movies/Parker (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Whitney Houston I Wanna Dance with Somebody (2022)" rsync -avhP "/mnt/unraid/media/Movies/Whitney Houston I Wanna Dance with Somebody (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Russell Peters Deported (2020)" rsync -avhP "/mnt/unraid/media/Movies/Russell Peters Deported (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Men in Black II (2002)" rsync -avhP "/mnt/unraid/media/Movies/Men in Black II (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Fast Charlie (2023)" rsync -avhP "/mnt/synology/rs-movies/Fast Charlie (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: City Slickers (1991)" rsync -avhP "/mnt/unraid/media/Movies/City Slickers (1991)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Altered Carbon Resleeved (2020)" rsync -avhP "/mnt/unraid/media/Movies/Altered Carbon Resleeved (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: We Bought a Zoo (2011)" rsync -avhP "/mnt/synology/rs-movies/We Bought a Zoo (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Krampus (2015)" rsync -avhP "/mnt/synology/rs-movies/Krampus (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Virus (1999)" rsync -avhP "/mnt/synology/rs-movies/Virus (1999)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Logans Run (1976)" rsync -avhP "/mnt/synology/rs-movies/Logans Run (1976)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: No Strings Attached (2011)" rsync -avhP "/mnt/synology/rs-movies/No Strings Attached (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Yossi and Jagger (2002)" rsync -avhP "/mnt/unraid/media/Movies/Yossi and Jagger (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Halloween 5 The Revenge of Michael Myers (1989)" rsync -avhP "/mnt/synology/rs-movies/Halloween 5 The Revenge of Michael Myers (1989)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Fix (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Fix (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: EverAfter (1998)" rsync -avhP "/mnt/unraid/media/Movies/EverAfter (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: One Ranger (2023)" rsync -avhP "/mnt/unraid/media/Movies/One Ranger (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Extinction (2018)" rsync -avhP "/mnt/synology/rs-movies/Extinction (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Assassins (1995)" rsync -avhP "/mnt/synology/rs-movies/Assassins (1995)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Semi-Pro (2008)" rsync -avhP "/mnt/synology/rs-movies/Semi-Pro (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Enter the Dragon (1973)" rsync -avhP "/mnt/unraid/media/Movies/Enter the Dragon (1973)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Sleepaway Camp II Unhappy Campers (1988)" rsync -avhP "/mnt/synology/rs-movies/Sleepaway Camp II Unhappy Campers (1988)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Those Who Wish Me Dead (2021)" rsync -avhP "/mnt/unraid/media/Movies/Those Who Wish Me Dead (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Oliver and Company (1988)" rsync -avhP "/mnt/unraid/media/Movies/Oliver and Company (1988)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Short Circuit 2 (1988)" rsync -avhP "/mnt/synology/rs-movies/Short Circuit 2 (1988)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The 4 - 30 Movie (2024)" rsync -avhP "/mnt/unraid/media/Movies/The 4 - 30 Movie (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Hook (1991)" rsync -avhP "/mnt/unraid/media/Movies/Hook (1991)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Snakes on a Plane (2006)" rsync -avhP "/mnt/unraid/media/Movies/Snakes on a Plane (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Luckiest Girl Alive (2022)" rsync -avhP "/mnt/unraid/media/Movies/Luckiest Girl Alive (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Kentucky Fried Movie (1977)" rsync -avhP "/mnt/synology/rs-movies/The Kentucky Fried Movie (1977)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Skulls (2000)" rsync -avhP "/mnt/synology/rs-movies/The Skulls (2000)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Trick or Treat (1986)" rsync -avhP "/mnt/synology/rs-movies/Trick or Treat (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Firebird (2021)" rsync -avhP "/mnt/unraid/media/Movies/Firebird (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The War Wagon (1967)" rsync -avhP "/mnt/synology/rs-movies/The War Wagon (1967)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Last Christmas (2019)" rsync -avhP "/mnt/synology/rs-movies/Last Christmas (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Star Wars Episode III Revenge of the Sith (2005)" rsync -avhP "/mnt/unraid/media/Movies/Star Wars Episode III Revenge of the Sith (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Easy Money (1983)" rsync -avhP "/mnt/synology/rs-movies/Easy Money (1983)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Dont Be a Menace to South Central While Drinking Your Juice in the Hood (1996)" rsync -avhP "/mnt/synology/rs-movies/Dont Be a Menace to South Central While Drinking Your Juice in the Hood (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: National Lampoons Christmas Vacation (1989)" rsync -avhP "/mnt/synology/rs-movies/National Lampoons Christmas Vacation (1989)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Queen (2006)" rsync -avhP "/mnt/unraid/media/Movies/The Queen (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Bambi II (2006)" rsync -avhP "/mnt/synology/rs-movies/Bambi II (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Man Who Fell to Earth (1976)" rsync -avhP "/mnt/unraid/media/Movies/The Man Who Fell to Earth (1976)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Eli (2019)" rsync -avhP "/mnt/synology/rs-movies/Eli (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Day Shift (2022)" rsync -avhP "/mnt/unraid/media/Movies/Day Shift (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Major Payne (1995)" rsync -avhP "/mnt/synology/rs-movies/Major Payne (1995)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Weekend at Bernie's (1989)" rsync -avhP "/mnt/synology/rs-movies/Weekend at Bernie's (1989)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Black Scorpion (1957)" rsync -avhP "/mnt/unraid/media/Movies/The Black Scorpion (1957)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Chicken Run Dawn of the Nugget (2023)" rsync -avhP "/mnt/unraid/media/Movies/Chicken Run Dawn of the Nugget (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Studio 54 (2018)" rsync -avhP "/mnt/synology/rs-movies/Studio 54 (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Warlock The Armageddon (1993)" rsync -avhP "/mnt/synology/rs-movies/Warlock The Armageddon (1993)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Land Before Time (1988)" rsync -avhP "/mnt/unraid/media/Movies/The Land Before Time (1988)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Ali and Ava (2022)" rsync -avhP "/mnt/unraid/media/Movies/Ali and Ava (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: April and the Extraordinary World (2015)" rsync -avhP "/mnt/synology/rs-movies/April and the Extraordinary World (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Sister Act 2 Back in the Habit (1993)" rsync -avhP "/mnt/unraid/media/Movies/Sister Act 2 Back in the Habit (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Careful What You Wish For (2015)" rsync -avhP "/mnt/synology/rs-movies/Careful What You Wish For (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Driven to Kill (2009)" rsync -avhP "/mnt/synology/rs-movies/Driven to Kill (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Descent (2005)" rsync -avhP "/mnt/unraid/media/Movies/The Descent (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Eternal Sunshine of the Spotless Mind (2004)" rsync -avhP "/mnt/unraid/media/Movies/Eternal Sunshine of the Spotless Mind (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Jawan (2023)" rsync -avhP "/mnt/unraid/media/Movies/Jawan (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The American President (1995)" rsync -avhP "/mnt/synology/rs-movies/The American President (1995)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: CODA (2021)" rsync -avhP "/mnt/unraid/media/Movies/CODA (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: IF (2024)" rsync -avhP "/mnt/unraid/media/Movies/IF (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The 355 (2022)" rsync -avhP "/mnt/unraid/media/Movies/The 355 (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Nightbitch (2024)" rsync -avhP "/mnt/synology/rs-movies/Nightbitch (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Afflicted (2014)" rsync -avhP "/mnt/synology/rs-movies/Afflicted (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: 1BR (2019)" rsync -avhP "/mnt/synology/rs-movies/1BR (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Wolves at the Door (2016)" rsync -avhP "/mnt/synology/rs-movies/Wolves at the Door (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Ant-Man (2015)" rsync -avhP "/mnt/unraid/media/Movies/Ant-Man (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Star Trek The Motion Picture (1979)" rsync -avhP "/mnt/unraid/media/Movies/Star Trek The Motion Picture (1979)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Greedy People (2024)" rsync -avhP "/mnt/unraid/media/Movies/Greedy People (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hypnotic (2021)" rsync -avhP "/mnt/synology/rs-movies/Hypnotic (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Hobbit The Battle of the Five Armies (2014)" rsync -avhP "/mnt/unraid/media/Movies/The Hobbit The Battle of the Five Armies (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Freelance (2023)" rsync -avhP "/mnt/unraid/media/Movies/Freelance (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: What If (2013)" rsync -avhP "/mnt/synology/rs-movies/What If (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Event Horizon (1997)" rsync -avhP "/mnt/unraid/media/Movies/Event Horizon (1997)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Mazinger Z Infinity (2017)" rsync -avhP "/mnt/synology/rs-movies/Mazinger Z Infinity (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Blind Side (2009)" rsync -avhP "/mnt/unraid/media/Movies/The Blind Side (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dune (2021)" rsync -avhP "/mnt/unraid/media/Movies/Dune (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: This Place Rules (2022)" rsync -avhP "/mnt/unraid/media/Movies/This Place Rules (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Marmaduke (2010)" rsync -avhP "/mnt/synology/rs-movies/Marmaduke (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Castle in the Sky (1986)" rsync -avhP "/mnt/synology/rs-movies/Castle in the Sky (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Return to the Batcave The Misadventures of Adam and Burt (2003)" rsync -avhP "/mnt/synology/rs-movies/Return to the Batcave The Misadventures of Adam and Burt (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Vast of Night (2019)" rsync -avhP "/mnt/synology/rs-movies/The Vast of Night (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Taxi (2004)" rsync -avhP "/mnt/synology/rs-movies/Taxi (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Dont Breathe (2016)" rsync -avhP "/mnt/unraid/media/Movies/Dont Breathe (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Ultimate Wolverine vs. Hulk (2013)" rsync -avhP "/mnt/synology/rs-movies/Ultimate Wolverine vs. Hulk (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Godzilla vs. Kong (2021)" rsync -avhP "/mnt/unraid/media/Movies/Godzilla vs. Kong (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Ant Bully (2006)" rsync -avhP "/mnt/synology/rs-movies/The Ant Bully (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Good Nurse (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Good Nurse (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: After Death (2023)" rsync -avhP "/mnt/synology/rs-movies/After Death (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Shrek (2001)" rsync -avhP "/mnt/synology/rs-movies/Shrek (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Ticket to Paradise (2022)" rsync -avhP "/mnt/unraid/media/Movies/Ticket to Paradise (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: LEGO Jurassic Park The Unofficial Retelling (2023)" rsync -avhP "/mnt/synology/rs-movies/LEGO Jurassic Park The Unofficial Retelling (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Searching for Bobby Fischer (1993)" rsync -avhP "/mnt/synology/rs-movies/Searching for Bobby Fischer (1993)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Ne Zha (2019)" rsync -avhP "/mnt/synology/rs-movies/Ne Zha (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: I Hate Valentines Day (2009)" rsync -avhP "/mnt/unraid/media/Movies/I Hate Valentines Day (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Slow (2023)" rsync -avhP "/mnt/unraid/media/Movies/Slow (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Luca (2021)" rsync -avhP "/mnt/unraid/media/Movies/Luca (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Flight of Dragons (1982)" rsync -avhP "/mnt/synology/rs-movies/The Flight of Dragons (1982)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Its Kind of a Funny Story (2010)" rsync -avhP "/mnt/synology/rs-movies/Its Kind of a Funny Story (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Navy Seals (1990)" rsync -avhP "/mnt/synology/rs-movies/Navy Seals (1990)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Memory (2023)" rsync -avhP "/mnt/unraid/media/Movies/Memory (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: V H S 94 (2021)" rsync -avhP "/mnt/synology/rs-movies/V H S 94 (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Only the River Flows (2023)" rsync -avhP "/mnt/unraid/media/Movies/Only the River Flows (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: G.I. Joe The Movie (1987)" rsync -avhP "/mnt/synology/rs-movies/G.I. Joe The Movie (1987)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Promise (2016)" rsync -avhP "/mnt/unraid/media/Movies/The Promise (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: LEGO DC Super Hero Girls Brain Drain (2017)" rsync -avhP "/mnt/unraid/media/Movies/LEGO DC Super Hero Girls Brain Drain (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Chupa (2023)" rsync -avhP "/mnt/unraid/media/Movies/Chupa (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Black Noise (2023)" rsync -avhP "/mnt/synology/rs-movies/Black Noise (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Crush (1993)" rsync -avhP "/mnt/synology/rs-movies/The Crush (1993)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Street Fighter (1994)" rsync -avhP "/mnt/synology/rs-movies/Street Fighter (1994)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Paradise (2023)" rsync -avhP "/mnt/unraid/media/Movies/Paradise (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Undercover (2022)" rsync -avhP "/mnt/synology/rs-movies/Undercover (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: American Pie Presents Girls Rules (2020)" rsync -avhP "/mnt/unraid/media/Movies/American Pie Presents Girls Rules (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: All We Imagine as Light (2024)" rsync -avhP "/mnt/unraid/media/Movies/All We Imagine as Light (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Boys in the Boat (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Boys in the Boat (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Marvels (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Marvels (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Halloween (1978)" rsync -avhP "/mnt/unraid/media/Movies/Halloween (1978)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Assassins Creed (2016)" rsync -avhP "/mnt/unraid/media/Movies/Assassins Creed (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Picture This (2025)" rsync -avhP "/mnt/synology/rs-movies/Picture This (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Blood Simple (1985)" rsync -avhP "/mnt/synology/rs-movies/Blood Simple (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Bring Him to Me (2023)" rsync -avhP "/mnt/unraid/media/Movies/Bring Him to Me (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: '71 (2014)" rsync -avhP "/mnt/unraid/media/Movies/'71 (2014)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Bad Boys for Life (2020)" rsync -avhP "/mnt/unraid/media/Movies/Bad Boys for Life (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Assessment (2025)" rsync -avhP "/mnt/unraid/media/Movies/The Assessment (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Swan Song (2021)" rsync -avhP "/mnt/unraid/media/Movies/Swan Song (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Cujo (1983)" rsync -avhP "/mnt/synology/rs-movies/Cujo (1983)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Harry Potter and the Prisoner of Azkaban (2004)" rsync -avhP "/mnt/unraid/media/Movies/Harry Potter and the Prisoner of Azkaban (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Rock (1996)" rsync -avhP "/mnt/unraid/media/Movies/The Rock (1996)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Walk the Line (2005)" rsync -avhP "/mnt/unraid/media/Movies/Walk the Line (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Gremlins 2 The New Batch (1990)" rsync -avhP "/mnt/unraid/media/Movies/Gremlins 2 The New Batch (1990)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Russell Peters The Green Card Tour (2011)" rsync -avhP "/mnt/unraid/media/Movies/Russell Peters The Green Card Tour (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Spy Hard (1996)" rsync -avhP "/mnt/synology/rs-movies/Spy Hard (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Bent (1997)" rsync -avhP "/mnt/synology/rs-movies/Bent (1997)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Strange Brew (1983)" rsync -avhP "/mnt/synology/rs-movies/Strange Brew (1983)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Girl Next Door (2004)" rsync -avhP "/mnt/synology/rs-movies/The Girl Next Door (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Float (2024)" rsync -avhP "/mnt/unraid/media/Movies/Float (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Braveheart (1995)" rsync -avhP "/mnt/unraid/media/Movies/Braveheart (1995)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Solomon Kane (2009)" rsync -avhP "/mnt/unraid/media/Movies/Solomon Kane (2009)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Thelma and Louise (1991)" rsync -avhP "/mnt/unraid/media/Movies/Thelma and Louise (1991)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Christmas in Evergreen (2017)" rsync -avhP "/mnt/synology/rs-movies/Christmas in Evergreen (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Rio (2011)" rsync -avhP "/mnt/unraid/media/Movies/Rio (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: A Cure for Wellness (2017)" rsync -avhP "/mnt/unraid/media/Movies/A Cure for Wellness (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Map That Leads to You (2025)" rsync -avhP "/mnt/unraid/media/Movies/The Map That Leads to You (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Tucker and Dale vs. Evil (2010)" rsync -avhP "/mnt/unraid/media/Movies/Tucker and Dale vs. Evil (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Hocus Pocus (1993)" rsync -avhP "/mnt/unraid/media/Movies/Hocus Pocus (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Summer of 69 (2025)" rsync -avhP "/mnt/unraid/media/Movies/Summer of 69 (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Being Eddie (2025)" rsync -avhP "/mnt/unraid/media/Movies/Being Eddie (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Eddie and the Cruisers (1983)" rsync -avhP "/mnt/synology/rs-movies/Eddie and the Cruisers (1983)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Alice in Wonderland (2010)" rsync -avhP "/mnt/synology/rs-movies/Alice in Wonderland (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Escort (2015)" rsync -avhP "/mnt/synology/rs-movies/The Escort (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Hammer of the Gods (2013)" rsync -avhP "/mnt/synology/rs-movies/Hammer of the Gods (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Brave (2012)" rsync -avhP "/mnt/unraid/media/Movies/Brave (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Trick 'r Treat (2007)" rsync -avhP "/mnt/synology/rs-movies/Trick 'r Treat (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Harlem Nights (1989)" rsync -avhP "/mnt/unraid/media/Movies/Harlem Nights (1989)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Ralph Breaks the Internet (2018)" rsync -avhP "/mnt/unraid/media/Movies/Ralph Breaks the Internet (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Pig (2021)" rsync -avhP "/mnt/unraid/media/Movies/Pig (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Silent Hill (2006)" rsync -avhP "/mnt/synology/rs-movies/Silent Hill (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Popes Exorcist (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Popes Exorcist (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Disobedience (2018)" rsync -avhP "/mnt/unraid/media/Movies/Disobedience (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Black Book (2006)" rsync -avhP "/mnt/synology/rs-movies/Black Book (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Porkys II The Next Day (1983)" rsync -avhP "/mnt/synology/rs-movies/Porkys II The Next Day (1983)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Red Heat (1988)" rsync -avhP "/mnt/unraid/media/Movies/Red Heat (1988)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Afterburn (2025)" rsync -avhP "/mnt/unraid/media/Movies/Afterburn (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: White Chicks (2004)" rsync -avhP "/mnt/unraid/media/Movies/White Chicks (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: They Were Expendable (1945)" rsync -avhP "/mnt/synology/rs-movies/They Were Expendable (1945)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Dumbo (2019)" rsync -avhP "/mnt/synology/rs-movies/Dumbo (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Reality (2023)" rsync -avhP "/mnt/unraid/media/Movies/Reality (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Barely Lethal (2015)" rsync -avhP "/mnt/unraid/media/Movies/Barely Lethal (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Bugonia (2025)" rsync -avhP "/mnt/unraid/media/Movies/Bugonia (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: My Big Fat Greek Wedding (2002)" rsync -avhP "/mnt/unraid/media/Movies/My Big Fat Greek Wedding (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Oculus (2014)" rsync -avhP "/mnt/synology/rs-movies/Oculus (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Woody Woodpecker (2017)" rsync -avhP "/mnt/synology/rs-movies/Woody Woodpecker (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Fist of Legend (1994)" rsync -avhP "/mnt/unraid/media/Movies/Fist of Legend (1994)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Venture Bros. Radiant Is the Blood of the Baboon Heart (2023)" rsync -avhP "/mnt/synology/rs-movies/The Venture Bros. Radiant Is the Blood of the Baboon Heart (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Ride with the Devil (1999)" rsync -avhP "/mnt/synology/rs-movies/Ride with the Devil (1999)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Fantastic Beasts The Crimes of Grindelwald (2018)" rsync -avhP "/mnt/unraid/media/Movies/Fantastic Beasts The Crimes of Grindelwald (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: One Direction This Is Us (2013)" rsync -avhP "/mnt/synology/rs-movies/One Direction This Is Us (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: No Escape (1994)" rsync -avhP "/mnt/synology/rs-movies/No Escape (1994)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: To Kill a Mockingbird (1962)" rsync -avhP "/mnt/unraid/media/Movies/To Kill a Mockingbird (1962)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Giant (1956)" rsync -avhP "/mnt/unraid/media/Movies/Giant (1956)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Lords of Discipline (1983)" rsync -avhP "/mnt/synology/rs-movies/The Lords of Discipline (1983)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: In the Land of Saints and Sinners (2023)" rsync -avhP "/mnt/unraid/media/Movies/In the Land of Saints and Sinners (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Color Purple (1985)" rsync -avhP "/mnt/unraid/media/Movies/The Color Purple (1985)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Remember the Titans (2000)" rsync -avhP "/mnt/synology/rs-movies/Remember the Titans (2000)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Quicksand (2023)" rsync -avhP "/mnt/synology/rs-movies/Quicksand (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: To Gerard (2020)" rsync -avhP "/mnt/unraid/media/Movies/To Gerard (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dont Look Up (2021)" rsync -avhP "/mnt/unraid/media/Movies/Dont Look Up (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Royal Treatment (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Royal Treatment (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Highlander II The Quickening (1991)" rsync -avhP "/mnt/unraid/media/Movies/Highlander II The Quickening (1991)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Blade (1998)" rsync -avhP "/mnt/unraid/media/Movies/Blade (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Deep Rising (1998)" rsync -avhP "/mnt/synology/rs-movies/Deep Rising (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Simulant (2023)" rsync -avhP "/mnt/unraid/media/Movies/Simulant (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Toy Story 3 (2010)" rsync -avhP "/mnt/unraid/media/Movies/Toy Story 3 (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: A Christmas Melody (2015)" rsync -avhP "/mnt/synology/rs-movies/A Christmas Melody (2015)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Broken Arrow (1996)" rsync -avhP "/mnt/synology/rs-movies/Broken Arrow (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Battleship (2012)" rsync -avhP "/mnt/unraid/media/Movies/Battleship (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Assassination of a High School President (2008)" rsync -avhP "/mnt/synology/rs-movies/Assassination of a High School President (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Alfie (2004)" rsync -avhP "/mnt/unraid/media/Movies/Alfie (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Arkansas (2020)" rsync -avhP "/mnt/synology/rs-movies/Arkansas (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Square (2013)" rsync -avhP "/mnt/unraid/media/Movies/The Square (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Victor Crowley (2017)" rsync -avhP "/mnt/unraid/media/Movies/Victor Crowley (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Ghosts of Girlfriends Past (2009)" rsync -avhP "/mnt/synology/rs-movies/Ghosts of Girlfriends Past (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Blood River (2009)" rsync -avhP "/mnt/synology/rs-movies/Blood River (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: How to Train Your Dragon (2025)" rsync -avhP "/mnt/unraid/media/Movies/How to Train Your Dragon (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Pee-wees Big Adventure (1985)" rsync -avhP "/mnt/unraid/media/Movies/Pee-wees Big Adventure (1985)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Horns (2013)" rsync -avhP "/mnt/synology/rs-movies/Horns (2013)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Oscar (1991)" rsync -avhP "/mnt/synology/rs-movies/Oscar (1991)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Ace Ventura Pet Detective (1994)" rsync -avhP "/mnt/synology/rs-movies/Ace Ventura Pet Detective (1994)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Florida Project (2017)" rsync -avhP "/mnt/unraid/media/Movies/The Florida Project (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Jim Gaffigan Cinco (2017)" rsync -avhP "/mnt/synology/rs-movies/Jim Gaffigan Cinco (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Supervized (2019)" rsync -avhP "/mnt/unraid/media/Movies/Supervized (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: September 5 (2024)" rsync -avhP "/mnt/unraid/media/Movies/September 5 (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Horizon An American Saga Chapter 1 (2024)" rsync -avhP "/mnt/unraid/media/Movies/Horizon An American Saga Chapter 1 (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Ratatouille (2007)" rsync -avhP "/mnt/unraid/media/Movies/Ratatouille (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dead Sea (2024)" rsync -avhP "/mnt/unraid/media/Movies/Dead Sea (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Captain America The First Avenger (2011)" rsync -avhP "/mnt/unraid/media/Movies/Captain America The First Avenger (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Halloweentown (1998)" rsync -avhP "/mnt/synology/rs-movies/Halloweentown (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Caveman (1981)" rsync -avhP "/mnt/synology/rs-movies/Caveman (1981)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Fear (1996)" rsync -avhP "/mnt/synology/rs-movies/Fear (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: A Clockwork Orange (1971)" rsync -avhP "/mnt/unraid/media/Movies/A Clockwork Orange (1971)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Man of the West (1958)" rsync -avhP "/mnt/synology/rs-movies/Man of the West (1958)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Cabin in the Woods (2012)" rsync -avhP "/mnt/unraid/media/Movies/The Cabin in the Woods (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: X-Men The Last Stand (2006)" rsync -avhP "/mnt/unraid/media/Movies/X-Men The Last Stand (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Critters 4 (1992)" rsync -avhP "/mnt/synology/rs-movies/Critters 4 (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Alexander (2004)" rsync -avhP "/mnt/synology/rs-movies/Alexander (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Kokoda (2006)" rsync -avhP "/mnt/synology/rs-movies/Kokoda (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Before the Rain (1994)" rsync -avhP "/mnt/unraid/media/Movies/Before the Rain (1994)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Millers Girl (2024)" rsync -avhP "/mnt/unraid/media/Movies/Millers Girl (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Shame (2011)" rsync -avhP "/mnt/unraid/media/Movies/Shame (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Retrograde (2022)" rsync -avhP "/mnt/synology/rs-movies/Retrograde (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Midnight Cowboy (1969)" rsync -avhP "/mnt/unraid/media/Movies/Midnight Cowboy (1969)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Christopher Titus Neverlution (2011)" rsync -avhP "/mnt/unraid/media/Movies/Christopher Titus Neverlution (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Reign of Chaos (2022)" rsync -avhP "/mnt/unraid/media/Movies/Reign of Chaos (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Wall (2017)" rsync -avhP "/mnt/synology/rs-movies/Wall (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Rumble Through the Dark (2023)" rsync -avhP "/mnt/unraid/media/Movies/Rumble Through the Dark (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Curfew (2012)" rsync -avhP "/mnt/unraid/media/Movies/Curfew (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Beales of Grey Gardens (2006)" rsync -avhP "/mnt/unraid/media/Movies/The Beales of Grey Gardens (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: End of Days (1999)" rsync -avhP "/mnt/unraid/media/Movies/End of Days (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Ferry 2 (2024)" rsync -avhP "/mnt/unraid/media/Movies/Ferry 2 (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Beavis and Butt-Head Do America (1996)" rsync -avhP "/mnt/synology/rs-movies/Beavis and Butt-Head Do America (1996)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Once Upon a Time in America (1984)" rsync -avhP "/mnt/unraid/media/Movies/Once Upon a Time in America (1984)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Longest Yard (2005)" rsync -avhP "/mnt/unraid/media/Movies/The Longest Yard (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Exit Wounds (2001)" rsync -avhP "/mnt/synology/rs-movies/Exit Wounds (2001)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The New World (2005)" rsync -avhP "/mnt/unraid/media/Movies/The New World (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: 10 (1979)" rsync -avhP "/mnt/synology/rs-movies/10 (1979)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Tarzan (1999)" rsync -avhP "/mnt/unraid/media/Movies/Tarzan (1999)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Wizard of Lies (2017)" rsync -avhP "/mnt/unraid/media/Movies/The Wizard of Lies (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Peter Pans Neverland Nightmare (2025)" rsync -avhP "/mnt/synology/rs-movies/Peter Pans Neverland Nightmare (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Wolfman (2010)" rsync -avhP "/mnt/synology/rs-movies/The Wolfman (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Abominable Snowman (1957)" rsync -avhP "/mnt/synology/rs-movies/The Abominable Snowman (1957)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Justice League Crisis on Infinite Earths Part Three (2024)" rsync -avhP "/mnt/unraid/media/Movies/Justice League Crisis on Infinite Earths Part Three (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Joe Rogan Rocky Mountain High (2014)" rsync -avhP "/mnt/synology/rs-movies/Joe Rogan Rocky Mountain High (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Stop Making Sense (1984)" rsync -avhP "/mnt/synology/rs-movies/Stop Making Sense (1984)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Dune Part Two (2024)" rsync -avhP "/mnt/unraid/media/Movies/Dune Part Two (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Winnie the Pooh (2011)" rsync -avhP "/mnt/synology/rs-movies/Winnie the Pooh (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Metro (1997)" rsync -avhP "/mnt/synology/rs-movies/Metro (1997)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Steve Martin and Martin Short An Evening You Will Forget for the Rest of Your Life (2018)" rsync -avhP "/mnt/synology/rs-movies/Steve Martin and Martin Short An Evening You Will Forget for the Rest of Your Life (2018)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Take Me to the River (2015)" rsync -avhP "/mnt/unraid/media/Movies/Take Me to the River (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Scary Movie 4 (2006)" rsync -avhP "/mnt/synology/rs-movies/Scary Movie 4 (2006)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Arrival (2016)" rsync -avhP "/mnt/unraid/media/Movies/Arrival (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Waiting. (2005)" rsync -avhP "/mnt/synology/rs-movies/Waiting. (2005)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Reluctant Astronaut (1967)" rsync -avhP "/mnt/synology/rs-movies/The Reluctant Astronaut (1967)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Red Rocket (2021)" rsync -avhP "/mnt/unraid/media/Movies/Red Rocket (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Pride and Glory (2008)" rsync -avhP "/mnt/synology/rs-movies/Pride and Glory (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Ray Donovan The Movie (2022)" rsync -avhP "/mnt/synology/rs-movies/Ray Donovan The Movie (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Gone with the Wind (1939)" rsync -avhP "/mnt/unraid/media/Movies/Gone with the Wind (1939)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Trust (2010)" rsync -avhP "/mnt/synology/rs-movies/Trust (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Eyes of Tammy Faye (2021)" rsync -avhP "/mnt/unraid/media/Movies/The Eyes of Tammy Faye (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Man in the White Van (2024)" rsync -avhP "/mnt/unraid/media/Movies/The Man in the White Van (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Nobody (2021)" rsync -avhP "/mnt/unraid/media/Movies/Nobody (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dog (2022)" rsync -avhP "/mnt/unraid/media/Movies/Dog (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Predator 2 (1990)" rsync -avhP "/mnt/synology/rs-movies/Predator 2 (1990)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: How to Date Billy Walsh (2024)" rsync -avhP "/mnt/synology/rs-movies/How to Date Billy Walsh (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Holdovers (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Holdovers (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Little Mermaid Ariels Beginning (2008)" rsync -avhP "/mnt/synology/rs-movies/The Little Mermaid Ariels Beginning (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Desperation Road (2023)" rsync -avhP "/mnt/unraid/media/Movies/Desperation Road (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Hypnotic (2023)" rsync -avhP "/mnt/unraid/media/Movies/Hypnotic (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Open Season 3 (2010)" rsync -avhP "/mnt/synology/rs-movies/Open Season 3 (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Footloose (2011)" rsync -avhP "/mnt/synology/rs-movies/Footloose (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Explant (2021)" rsync -avhP "/mnt/synology/rs-movies/Explant (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Moonraker (1979)" rsync -avhP "/mnt/synology/rs-movies/Moonraker (1979)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Favourite (2018)" rsync -avhP "/mnt/unraid/media/Movies/The Favourite (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Unhinged (2020)" rsync -avhP "/mnt/unraid/media/Movies/Unhinged (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Luther Never Too Much (2024)" rsync -avhP "/mnt/unraid/media/Movies/Luther Never Too Much (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: HIM (2025)" rsync -avhP "/mnt/unraid/media/Movies/HIM (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: iHostage (2025)" rsync -avhP "/mnt/unraid/media/Movies/iHostage (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Snake Eyes (1998)" rsync -avhP "/mnt/unraid/media/Movies/Snake Eyes (1998)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Bram Stokers Van Helsing (2021)" rsync -avhP "/mnt/synology/rs-movies/Bram Stokers Van Helsing (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Legion of Super-Heroes (2023)" rsync -avhP "/mnt/unraid/media/Movies/Legion of Super-Heroes (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Mad Max 2 (1981)" rsync -avhP "/mnt/unraid/media/Movies/Mad Max 2 (1981)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Youre Killing Me (2023)" rsync -avhP "/mnt/synology/rs-movies/Youre Killing Me (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Murder at Yellowstone City (2022)" rsync -avhP "/mnt/unraid/media/Movies/Murder at Yellowstone City (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: I Used to Be Funny (2024)" rsync -avhP "/mnt/unraid/media/Movies/I Used to Be Funny (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Colossal (2017)" rsync -avhP "/mnt/synology/rs-movies/Colossal (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Dave Chappelle Equanimity (2017)" rsync -avhP "/mnt/unraid/media/Movies/Dave Chappelle Equanimity (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Fullmetal Alchemist The Revenge of Scar (2022)" rsync -avhP "/mnt/unraid/media/Movies/Fullmetal Alchemist The Revenge of Scar (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Princess (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Princess (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Arthur the King (2024)" rsync -avhP "/mnt/unraid/media/Movies/Arthur the King (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Thank You for Your Service (2017)" rsync -avhP "/mnt/unraid/media/Movies/Thank You for Your Service (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Report (2019)" rsync -avhP "/mnt/synology/rs-movies/The Report (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Attack of the Meth Gator (2024)" rsync -avhP "/mnt/synology/rs-movies/Attack of the Meth Gator (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Prometheus (2012)" rsync -avhP "/mnt/unraid/media/Movies/Prometheus (2012)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Shark Bait (2022)" rsync -avhP "/mnt/synology/rs-movies/Shark Bait (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: About Fate (2022)" rsync -avhP "/mnt/unraid/media/Movies/About Fate (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Diary of a Wimpy Kid The Last Straw (2025)" rsync -avhP "/mnt/synology/rs-movies/Diary of a Wimpy Kid The Last Straw (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Killer Klowns from Outer Space (1988)" rsync -avhP "/mnt/synology/rs-movies/Killer Klowns from Outer Space (1988)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: kid 90 (2021)" rsync -avhP "/mnt/unraid/media/Movies/kid 90 (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Under Wraps 2 (2022)" rsync -avhP "/mnt/synology/rs-movies/Under Wraps 2 (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Fifty Shades Darker (2017)" rsync -avhP "/mnt/synology/rs-movies/Fifty Shades Darker (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Courier (2020)" rsync -avhP "/mnt/unraid/media/Movies/The Courier (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Duke (2021)" rsync -avhP "/mnt/synology/rs-movies/Duke (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Split Second (1992)" rsync -avhP "/mnt/synology/rs-movies/Split Second (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Crimson Tide (1995)" rsync -avhP "/mnt/unraid/media/Movies/Crimson Tide (1995)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Killing Gunther (2017)" rsync -avhP "/mnt/synology/rs-movies/Killing Gunther (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Barbie (2023)" rsync -avhP "/mnt/unraid/media/Movies/Barbie (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: A Walk to Remember (2002)" rsync -avhP "/mnt/synology/rs-movies/A Walk to Remember (2002)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Birds (1963)" rsync -avhP "/mnt/unraid/media/Movies/The Birds (1963)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: When You Finish Saving the World (2023)" rsync -avhP "/mnt/unraid/media/Movies/When You Finish Saving the World (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Lady and the Tramp (1955)" rsync -avhP "/mnt/synology/rs-movies/Lady and the Tramp (1955)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Uprising (2024)" rsync -avhP "/mnt/unraid/media/Movies/Uprising (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Thor Tales of Asgard (2011)" rsync -avhP "/mnt/synology/rs-movies/Thor Tales of Asgard (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: A '90s Christmas (2024)" rsync -avhP "/mnt/synology/rs-movies/A '90s Christmas (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Full Metal Jacket (1987)" rsync -avhP "/mnt/unraid/media/Movies/Full Metal Jacket (1987)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Mufasa The Lion King (2024)" rsync -avhP "/mnt/unraid/media/Movies/Mufasa The Lion King (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Balls of Fury (2007)" rsync -avhP "/mnt/synology/rs-movies/Balls of Fury (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Billy Madison (1995)" rsync -avhP "/mnt/unraid/media/Movies/Billy Madison (1995)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: FernGully The Last Rainforest (1992)" rsync -avhP "/mnt/synology/rs-movies/FernGully The Last Rainforest (1992)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Primal (2019)" rsync -avhP "/mnt/synology/rs-movies/Primal (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Fear Street 1666 (2021)" rsync -avhP "/mnt/synology/rs-movies/Fear Street 1666 (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Birth Rebirth (2023)" rsync -avhP "/mnt/unraid/media/Movies/Birth Rebirth (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Nevada Smith (1966)" rsync -avhP "/mnt/synology/rs-movies/Nevada Smith (1966)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Tenacious D in The Pick of Destiny (2006)" rsync -avhP "/mnt/unraid/media/Movies/Tenacious D in The Pick of Destiny (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Hunter Killer (2018)" rsync -avhP "/mnt/unraid/media/Movies/Hunter Killer (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Quiet Earth (1985)" rsync -avhP "/mnt/unraid/media/Movies/The Quiet Earth (1985)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: We Live in Time (2024)" rsync -avhP "/mnt/unraid/media/Movies/We Live in Time (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Tell Me a Creepy Story (2023)" rsync -avhP "/mnt/synology/rs-movies/Tell Me a Creepy Story (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Spiral From the Book of Saw (2021)" rsync -avhP "/mnt/unraid/media/Movies/Spiral From the Book of Saw (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Im Not An Actor (2025)" rsync -avhP "/mnt/synology/rs-movies/Im Not An Actor (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Alice (2022)" rsync -avhP "/mnt/unraid/media/Movies/Alice (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Treasure Island (2012)" rsync -avhP "/mnt/synology/rs-movies/Treasure Island (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Christopher Robin (2018)" rsync -avhP "/mnt/unraid/media/Movies/Christopher Robin (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Tommy (1975)" rsync -avhP "/mnt/synology/rs-movies/Tommy (1975)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Extraction 2 (2023)" rsync -avhP "/mnt/unraid/media/Movies/Extraction 2 (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Devil All the Time (2020)" rsync -avhP "/mnt/unraid/media/Movies/The Devil All the Time (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Donnie Brasco (1997)" rsync -avhP "/mnt/unraid/media/Movies/Donnie Brasco (1997)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Three Wisest Men (2025)" rsync -avhP "/mnt/synology/rs-movies/Three Wisest Men (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Tower Heist (2011)" rsync -avhP "/mnt/unraid/media/Movies/Tower Heist (2011)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Starve Acre (2024)" rsync -avhP "/mnt/unraid/media/Movies/Starve Acre (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Playground (2021)" rsync -avhP "/mnt/synology/rs-movies/Playground (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Occupation Rainfall (2020)" rsync -avhP "/mnt/unraid/media/Movies/Occupation Rainfall (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Capone (2020)" rsync -avhP "/mnt/unraid/media/Movies/Capone (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Dead of Winter (2025)" rsync -avhP "/mnt/unraid/media/Movies/Dead of Winter (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: All About Eve (1950)" rsync -avhP "/mnt/synology/rs-movies/All About Eve (1950)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: M3GAN 2.0 (2025)" rsync -avhP "/mnt/unraid/media/Movies/M3GAN 2.0 (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Frog Dreaming (1986)" rsync -avhP "/mnt/synology/rs-movies/Frog Dreaming (1986)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Suncoast (2024)" rsync -avhP "/mnt/unraid/media/Movies/Suncoast (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Prep and Landing Totally Tinsel Collection (2012)" rsync -avhP "/mnt/synology/rs-movies/Prep and Landing Totally Tinsel Collection (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Last Days of American Crime (2020)" rsync -avhP "/mnt/synology/rs-movies/The Last Days of American Crime (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: How to Build a Girl (2020)" rsync -avhP "/mnt/unraid/media/Movies/How to Build a Girl (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Maid in Manhattan (2002)" rsync -avhP "/mnt/unraid/media/Movies/Maid in Manhattan (2002)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Stepmom (1998)" rsync -avhP "/mnt/synology/rs-movies/Stepmom (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Mary Poppins (1964)" rsync -avhP "/mnt/unraid/media/Movies/Mary Poppins (1964)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Sleepless in Seattle (1993)" rsync -avhP "/mnt/unraid/media/Movies/Sleepless in Seattle (1993)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Babies Dont Come with Instructions (2024)" rsync -avhP "/mnt/unraid/media/Movies/Babies Dont Come with Instructions (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Gacy (2003)" rsync -avhP "/mnt/synology/rs-movies/Gacy (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Open Season 2 (2008)" rsync -avhP "/mnt/synology/rs-movies/Open Season 2 (2008)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Fountain of Youth (2025)" rsync -avhP "/mnt/unraid/media/Movies/Fountain of Youth (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Good Liar (2019)" rsync -avhP "/mnt/synology/rs-movies/The Good Liar (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Underground (1995)" rsync -avhP "/mnt/unraid/media/Movies/Underground (1995)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Time Cut (2024)" rsync -avhP "/mnt/unraid/media/Movies/Time Cut (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Beasts of No Nation (2015)" rsync -avhP "/mnt/unraid/media/Movies/Beasts of No Nation (2015)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Under Wraps (2021)" rsync -avhP "/mnt/synology/rs-movies/Under Wraps (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: No Country for Old Men (2007)" rsync -avhP "/mnt/unraid/media/Movies/No Country for Old Men (2007)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: House at the End of the Street (2012)" rsync -avhP "/mnt/synology/rs-movies/House at the End of the Street (2012)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Butchers Crossing (2023)" rsync -avhP "/mnt/unraid/media/Movies/Butchers Crossing (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: A Bugs Life (1998)" rsync -avhP "/mnt/synology/rs-movies/A Bugs Life (1998)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Made of Honor (2008)" rsync -avhP "/mnt/unraid/media/Movies/Made of Honor (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Christmas House (2020)" rsync -avhP "/mnt/synology/rs-movies/The Christmas House (2020)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Witcher Nightmare of the Wolf (2021)" rsync -avhP "/mnt/synology/rs-movies/The Witcher Nightmare of the Wolf (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Cheeky (2000)" rsync -avhP "/mnt/unraid/media/Movies/Cheeky (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Watchmen Chapter II (2024)" rsync -avhP "/mnt/unraid/media/Movies/Watchmen Chapter II (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Skin I Live In (2011)" rsync -avhP "/mnt/synology/rs-movies/The Skin I Live In (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Anastasia (1997)" rsync -avhP "/mnt/synology/rs-movies/Anastasia (1997)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Last Samurai (2003)" rsync -avhP "/mnt/synology/rs-movies/The Last Samurai (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Teen Wolf (1985)" rsync -avhP "/mnt/synology/rs-movies/Teen Wolf (1985)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Machete (2010)" rsync -avhP "/mnt/synology/rs-movies/Machete (2010)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Fences (2016)" rsync -avhP "/mnt/synology/rs-movies/Fences (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: North by Northwest (1959)" rsync -avhP "/mnt/unraid/media/Movies/North by Northwest (1959)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Santa Clause 3 The Escape Clause (2006)" rsync -avhP "/mnt/unraid/media/Movies/The Santa Clause 3 The Escape Clause (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Morris from America (2016)" rsync -avhP "/mnt/unraid/media/Movies/Morris from America (2016)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Little Mermaid (2023)" rsync -avhP "/mnt/synology/rs-movies/The Little Mermaid (2023)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Cold Mountain (2003)" rsync -avhP "/mnt/unraid/media/Movies/Cold Mountain (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Killer (2023)" rsync -avhP "/mnt/unraid/media/Movies/The Killer (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Greenland (2020)" rsync -avhP "/mnt/unraid/media/Movies/Greenland (2020)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Something Wicked This Way Comes (1983)" rsync -avhP "/mnt/synology/rs-movies/Something Wicked This Way Comes (1983)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Motherhood (2009)" rsync -avhP "/mnt/synology/rs-movies/Motherhood (2009)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: A Wrinkle in Time (2003)" rsync -avhP "/mnt/synology/rs-movies/A Wrinkle in Time (2003)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: 9th Company (2005)" rsync -avhP "/mnt/unraid/media/Movies/9th Company (2005)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Aztec Batman Clash of Empires (2025)" rsync -avhP "/mnt/unraid/media/Movies/Aztec Batman Clash of Empires (2025)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Invasion of the Body Snatchers (1978)" rsync -avhP "/mnt/synology/rs-movies/Invasion of the Body Snatchers (1978)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: I Will Revenge This World With Love S. Paradjanov (2024)" rsync -avhP "/mnt/synology/rs-movies/I Will Revenge This World With Love S. Paradjanov (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Battlestar Galactica Razor (2007)" rsync -avhP "/mnt/synology/rs-movies/Battlestar Galactica Razor (2007)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Piggy (2022)" rsync -avhP "/mnt/unraid/media/Movies/Piggy (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Immaculate Room (2022)" rsync -avhP "/mnt/unraid/media/Movies/The Immaculate Room (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Transcendence (2014)" rsync -avhP "/mnt/synology/rs-movies/Transcendence (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: LEGO DC Comics Super Heroes Batman Be-Leaguered (2014)" rsync -avhP "/mnt/synology/rs-movies/LEGO DC Comics Super Heroes Batman Be-Leaguered (2014)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Strange World (2022)" rsync -avhP "/mnt/unraid/media/Movies/Strange World (2022)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Vicky Cristina Barcelona (2008)" rsync -avhP "/mnt/unraid/media/Movies/Vicky Cristina Barcelona (2008)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: How the West Was Won (1962)" rsync -avhP "/mnt/synology/rs-movies/How the West Was Won (1962)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Children of the Atom Filming X-Men First Class (2011)" rsync -avhP "/mnt/synology/rs-movies/Children of the Atom Filming X-Men First Class (2011)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Quiet Man (1952)" rsync -avhP "/mnt/synology/rs-movies/The Quiet Man (1952)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Believers (1987)" rsync -avhP "/mnt/unraid/media/Movies/The Believers (1987)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Many Adventures of Winnie the Pooh (1977)" rsync -avhP "/mnt/synology/rs-movies/The Many Adventures of Winnie the Pooh (1977)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: David A. Arnold It Aint for the Weak (2022)" rsync -avhP "/mnt/synology/rs-movies/David A. Arnold It Aint for the Weak (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The End We Start From (2023)" rsync -avhP "/mnt/unraid/media/Movies/The End We Start From (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Trollhunters Rise of the Titans (2021)" rsync -avhP "/mnt/unraid/media/Movies/Trollhunters Rise of the Titans (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Hannah Berner We Ride at Dawn (2024)" rsync -avhP "/mnt/synology/rs-movies/Hannah Berner We Ride at Dawn (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Joint Security Area (2000)" rsync -avhP "/mnt/unraid/media/Movies/Joint Security Area (2000)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Nomadland (2021)" rsync -avhP "/mnt/unraid/media/Movies/Nomadland (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Girl on the Train (2016)" rsync -avhP "/mnt/synology/rs-movies/The Girl on the Train (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Fisher King (1991)" rsync -avhP "/mnt/synology/rs-movies/The Fisher King (1991)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Lara Croft Tomb Raider The Cradle of Life (2003)" rsync -avhP "/mnt/unraid/media/Movies/Lara Croft Tomb Raider The Cradle of Life (2003)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Abbott and Costello Meet the Mummy (1955)" rsync -avhP "/mnt/unraid/media/Movies/Abbott and Costello Meet the Mummy (1955)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Sorceress (1982)" rsync -avhP "/mnt/synology/rs-movies/Sorceress (1982)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Mummy (2017)" rsync -avhP "/mnt/unraid/media/Movies/The Mummy (2017)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: 80 for Brady (2023)" rsync -avhP "/mnt/unraid/media/Movies/80 for Brady (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Treasure Island (1950)" rsync -avhP "/mnt/synology/rs-movies/Treasure Island (1950)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Predators (2010)" rsync -avhP "/mnt/unraid/media/Movies/Predators (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: The Smurfs 2 (2013)" rsync -avhP "/mnt/unraid/media/Movies/The Smurfs 2 (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The First Great Train Robbery (1978)" rsync -avhP "/mnt/synology/rs-movies/The First Great Train Robbery (1978)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Moxie (2021)" rsync -avhP "/mnt/synology/rs-movies/Moxie (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Rings (2017)" rsync -avhP "/mnt/synology/rs-movies/Rings (2017)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: The Girl Who Got Away (2021)" rsync -avhP "/mnt/synology/rs-movies/The Girl Who Got Away (2021)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: A Carol for Two (2024)" rsync -avhP "/mnt/synology/rs-movies/A Carol for Two (2024)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Nate Bargatze The Greatest Average American (2021)" rsync -avhP "/mnt/unraid/media/Movies/Nate Bargatze The Greatest Average American (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Annihilation (2018)" rsync -avhP "/mnt/unraid/media/Movies/Annihilation (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Halloween III Season of the Witch (1982)" rsync -avhP "/mnt/synology/rs-movies/Halloween III Season of the Witch (1982)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Iron Man 2 (2010)" rsync -avhP "/mnt/unraid/media/Movies/Iron Man 2 (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: A Different Man (2024)" rsync -avhP "/mnt/unraid/media/Movies/A Different Man (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Sergeant York (1941)" rsync -avhP "/mnt/synology/rs-movies/Sergeant York (1941)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Kiff Lore of the Ring Light (2025)" rsync -avhP "/mnt/synology/rs-movies/Kiff Lore of the Ring Light (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Challengers (2024)" rsync -avhP "/mnt/unraid/media/Movies/Challengers (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Nymphomaniac Vol. I (2013)" rsync -avhP "/mnt/unraid/media/Movies/Nymphomaniac Vol. I (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Love Lies Bleeding (2024)" rsync -avhP "/mnt/unraid/media/Movies/Love Lies Bleeding (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Spies in Disguise (2019)" rsync -avhP "/mnt/synology/rs-movies/Spies in Disguise (2019)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Eddie and the Cruisers II Eddie Lives! (1989)" rsync -avhP "/mnt/synology/rs-movies/Eddie and the Cruisers II Eddie Lives! (1989)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: A Real Pain (2024)" rsync -avhP "/mnt/unraid/media/Movies/A Real Pain (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Ip Man Kung Fu Master (2019)" rsync -avhP "/mnt/unraid/media/Movies/Ip Man Kung Fu Master (2019)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Dark Crimes (2016)" rsync -avhP "/mnt/synology/rs-movies/Dark Crimes (2016)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Clueless (1995)" rsync -avhP "/mnt/synology/rs-movies/Clueless (1995)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Chris->Ali: Jersey Girl (2004)" rsync -avhP "/mnt/synology/rs-movies/Jersey Girl (2004)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Long Gone Heroes (2024)" rsync -avhP "/mnt/unraid/media/Movies/Long Gone Heroes (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: AKA (2023)" rsync -avhP "/mnt/unraid/media/Movies/AKA (2023)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Lucky Number Slevin (2006)" rsync -avhP "/mnt/unraid/media/Movies/Lucky Number Slevin (2006)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Ghostbusters Afterlife (2021)" rsync -avhP "/mnt/unraid/media/Movies/Ghostbusters Afterlife (2021)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Inside Out 2 (2024)" rsync -avhP "/mnt/unraid/media/Movies/Inside Out 2 (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Operation Finale (2018)" rsync -avhP "/mnt/unraid/media/Movies/Operation Finale (2018)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Venom The Last Dance (2024)" rsync -avhP "/mnt/unraid/media/Movies/Venom The Last Dance (2024)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: The Bad Guys (2022)" rsync -avhP "/mnt/synology/rs-movies/The Bad Guys (2022)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: Spider-Man 2 (2004)" rsync -avhP "/mnt/unraid/media/Movies/Spider-Man 2 (2004)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Bride Hard (2025)" rsync -avhP "/mnt/synology/rs-movies/Bride Hard (2025)" "/mnt/unraid/media/Movies/"

run_cmd "Copy Ali->Chris: The Armstrong Lie (2013)" rsync -avhP "/mnt/unraid/media/Movies/The Armstrong Lie (2013)" "/mnt/synology/rs-movies/"

run_cmd "Copy Ali->Chris: Banana (2010)" rsync -avhP "/mnt/unraid/media/Movies/Banana (2010)" "/mnt/synology/rs-movies/"

run_cmd "Copy Chris->Ali: Doraleous and Associates" rsync -avhP "/mnt/synology/rs-movies/Doraleous and Associates" "/mnt/unraid/media/Movies/"


# Wait for all parallel jobs to complete
if [ "$PARALLEL" -gt 1 ]; then
    log "Waiting for parallel transfers to complete..."
    wait
fi

log "Sync complete!"
