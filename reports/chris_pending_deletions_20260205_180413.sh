#!/bin/bash
#==============================================================================
# Chris's Synology - Pending Deletions Script
# RUN THIS AFTER sync_actions script completes!
#==============================================================================
# Generated: 2026-02-05 18:04:13
# Total files to delete: 1207
#
# These files on Chris's Synology have been replaced with better quality
# versions from Ali's Unraid. Run this script to clean up the old files.
#
# Features:
#   - Progress tracking: completed deletions are logged and skipped on re-run
#   - Error handling: failures logged with details
#   - DRY_RUN mode to preview deletions first
#
# Usage:
#   DRY_RUN=true ./chris_pending_deletions_XXXXX.sh   # Preview only
#   ./chris_pending_deletions_XXXXX.sh                # Actually delete
#
#==============================================================================

set -o pipefail

PROGRESS_FILE="${PROGRESS_FILE:-chris_deletions_progress_20260205_180413.log}"
ERROR_LOG="${ERROR_LOG:-chris_deletions_errors_20260205_180413.log}"
DRY_RUN="${DRY_RUN:-false}"

# Colors for output
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m" # No Color

# Statistics
TOTAL=0
DELETED=0
SKIPPED=0
FAILED=0

log() {
    echo -e "[$(date "+%Y-%m-%d %H:%M:%S")] $1"
}

log_error() {
    echo -e "[$(date "+%Y-%m-%d %H:%M:%S")] ${RED}ERROR${NC}: $1" | tee -a "$ERROR_LOG"
}

is_completed() {
    local hash="$1"
    grep -q "^$hash$" "$PROGRESS_FILE" 2>/dev/null
}

mark_completed() {
    local hash="$1"
    echo "$hash" >> "$PROGRESS_FILE"
}

do_delete() {
    local desc="$1"
    local file="$2"
    local hash
    hash=$(echo "$file" | md5sum | cut -d" " -f1)
    
    ((TOTAL++))
    
    if is_completed "$hash"; then
        log "${YELLOW}SKIP${NC} [already done] $desc"
        ((SKIPPED++))
        return 0
    fi
    
    if [ ! -e "$file" ]; then
        log "${YELLOW}SKIP${NC} [not found] $desc"
        mark_completed "$hash"
        ((SKIPPED++))
        return 0
    fi
    
    if [ "$DRY_RUN" = "true" ]; then
        log "${BLUE}[DRY RUN]${NC} Would delete: $desc"
        log "  File: $file"
        ((DELETED++))
        return 0
    fi
    
    log "DELETING: $desc"
    
    if rm -f "$file"; then
        mark_completed "$hash"
        log "${GREEN}DELETED${NC}: $desc"
        ((DELETED++))
    else
        log_error "Failed to delete: $desc"
        log_error "  File: $file"
        ((FAILED++))
    fi
}

print_summary() {
    echo ""
    echo "========================================"
    echo "DELETION SUMMARY"
    echo "========================================"
    echo "Total:   $TOTAL"
    echo -e "Deleted: ${GREEN}$DELETED${NC}"
    echo -e "Skipped: ${YELLOW}$SKIPPED${NC}"
    echo -e "Failed:  ${RED}$FAILED${NC}"
    echo "========================================"
    if [ $FAILED -gt 0 ]; then
        echo "See $ERROR_LOG for failure details"
    fi
}

trap print_summary EXIT

log "Starting Chris Synology cleanup..."
log "Progress file: $PROGRESS_FILE"
log "Error log: $ERROR_LOG"
if [ "$DRY_RUN" = "true" ]; then
    log "${BLUE}DRY RUN MODE - no files will be deleted${NC}"
fi
echo ""

# === FILES TO DELETE ON CHRIS'S SYNOLOGY ===

do_delete "Chris lower quality: Here (2024)" "/mnt/synology/rs-movies/Here (2024)/Here (2024) {tmdb-940139} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv"

do_delete "Chris lower quality: Puss in Boots The Last Wish (2022)" "/mnt/synology/rs-movies/Puss in Boots The Last Wish (2022)/Puss in Boots The Last Wish (2022) {tmdb-315162} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Ride Along (2014)" "/mnt/synology/rs-movies/Ride Along (2014)/Ride Along (2014) {tmdb-168530} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Blackwater Lane (2024)" "/mnt/synology/rs-movies/Blackwater Lane (2024)/Blackwater Lane (2024) {tmdb-1215918} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: Cuckoo (2024)" "/mnt/synology/rs-movies/Cuckoo (2024)/Cuckoo (2024) {tmdb-869291} - [AMZN][WEBDL-1080p Proper][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Fantastic Beasts and Where to Find Them (2016)" "/mnt/synology/rs-movies/Fantastic Beasts and Where to Find Them (2016)/Fantastic Beasts and Where to Find Them (2016) {tmdb-259316} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: 2 Days in the Valley (1996)" "/mnt/synology/rs-movies/2 Days in the Valley (1996)/2 Days in the Valley (1996) {tmdb-9401} - [WEBRip-1080p][EAC3 5.1][x264].mkv"

do_delete "Chris lower quality: Damaged (2024)" "/mnt/synology/rs-movies/Damaged (2024)/Damaged (2024) {tmdb-1105407} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: Knock Knock (2015)" "/mnt/synology/rs-movies/Knock Knock (2015)/Knock Knock (2015) {tmdb-263472} - [Remux-1080p][DTS-HD MA 5.1][h264]-KRaLiMaRKo.mkv"

do_delete "Chris lower quality: Papillon (2017)" "/mnt/synology/rs-movies/Papillon (2017)/Papillon (2017) {tmdb-433498} - [Bluray-1080p][DTS 5.1][x264]-cinefile.mkv"

do_delete "Chris lower quality: The Shape of Water (2017)" "/mnt/synology/rs-movies/The Shape of Water (2017)/The Shape of Water (2017) {tmdb-399055} - [Bluray-1080p][AC3 5.1][HDR10][x265]-D-Z0N3.mkv"

do_delete "Chris lower quality: Stuber (2019)" "/mnt/synology/rs-movies/Stuber (2019)/Stuber (2019) {tmdb-513045} - [WEBDL-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Greenland (2020)" "/mnt/synology/rs-movies/Greenland (2020)/Greenland (2020) {tmdb-524047} - [Bluray-1080p Proper][EAC3 7.1][x264]-iFT.mkv"

do_delete "Chris lower quality: IO (2019)" "/mnt/synology/rs-movies/IO (2019)/IO (2019) {tmdb-433249} - [WEBRip-1080p][EAC3 5.1][x264]-DEFLATE.mkv"

do_delete "Chris lower quality: The Expendables 3 (2014)" "/mnt/synology/rs-movies/The Expendables 3 (2014)/The Expendables 3 (2014) {tmdb-138103} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Fast X (2023)" "/mnt/synology/rs-movies/Fast X (2023)/Fast X (2023) {tmdb-385687} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FAMiLYFOREVER.mkv"

do_delete "Chris lower quality: Self less (2015)" "/mnt/synology/rs-movies/Self less (2015)/Self less (2015) {tmdb-238615} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Den of Thieves (2018)" "/mnt/synology/rs-movies/Den of Thieves (2018)/Den of Thieves (2018) {tmdb-449443} - {edition-Unrated} [Bluray-1080p][DTS 5.1][x264]-DON.mkv"

do_delete "Chris lower quality: Rumor Has It. (2005)" "/mnt/synology/rs-movies/Rumor Has It. (2005)/Rumor Has It. (2005) {tmdb-2800} - [Bluray-1080p][AC3 5.1][x264]-SUNSPOT.mkv"

do_delete "Chris lower quality: Strange World (2022)" "/mnt/synology/rs-movies/Strange World (2022)/Strange World (2022) {tmdb-877269} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Big (1988)" "/mnt/synology/rs-movies/Big (1988)/Big (1988) {tmdb-2280} - {edition-Extended} [HDTV-1080p][DTS 5.1][x264]-CHD.mkv"

do_delete "Chris lower quality: Birth Rebirth (2023)" "/mnt/synology/rs-movies/Birth Rebirth (2023)/Birth Rebirth (2023) {tmdb-1058638} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Three Wise Men and a Baby (2022)" "/mnt/synology/rs-movies/Three Wise Men and a Baby (2022)/Three Wise Men and a Baby (2022) {tmdb-1028541} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-MERRY.mkv"

do_delete "Chris lower quality: The Bad Guys 2 (2025)" "/mnt/synology/rs-movies/The Bad Guys 2 (2025)/The Bad Guys 2 (2025) {tmdb-1175942} - [WEBRip-1080p][EAC3 Atmos 5.1][x264]-HiDt.mkv"

do_delete "Chris lower quality: The Scorpion King (2002)" "/mnt/synology/rs-movies/The Scorpion King (2002)/The Scorpion King (2002) {tmdb-9334} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: MLK FBI (2020)" "/mnt/synology/rs-movies/MLK FBI (2020)/MLK FBI (2020) {tmdb-728868} - [WEBDL-1080p][EAC3 5.1][h264]-ISA.mkv"

do_delete "Chris lower quality: The Naked Gun 2½ The Smell of Fear (1991)" "/mnt/synology/rs-movies/The Naked Gun 2½ The Smell of Fear (1991)/The Naked Gun 2½ The Smell of Fear (1991) {tmdb-37137} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Warm Bodies (2013)" "/mnt/synology/rs-movies/Warm Bodies (2013)/Warm Bodies (2013) {tmdb-82654} - [Bluray-1080p][DTS 5.1][x264]-EbP.mkv"

do_delete "Chris lower quality: The Holiday (2006)" "/mnt/synology/rs-movies/The Holiday (2006)/The Holiday (2006) {tmdb-1581} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv"

do_delete "Chris lower quality: Terrifier (2018)" "/mnt/synology/rs-movies/Terrifier (2018)/Terrifier (2018) {tmdb-420634} - {edition-Uncut} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: The Mothman Prophecies (2002)" "/mnt/synology/rs-movies/The Mothman Prophecies (2002)/The Mothman Prophecies (2002) {tmdb-2637} - [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv"

do_delete "Chris lower quality: Observe and Report (2009)" "/mnt/synology/rs-movies/Observe and Report (2009)/Observe and Report (2009) {tmdb-16991} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv"

do_delete "Chris lower quality: Nutty Professor II The Klumps (2000)" "/mnt/synology/rs-movies/Nutty Professor II The Klumps (2000)/Nutty Professor II The Klumps (2000) {tmdb-12107} - {edition-Remastered} [Bluray-1080p][AC3 5.1][x264]-PSYCHD.mkv"

do_delete "Chris lower quality: The Seed of the Sacred Fig (2024)" "/mnt/synology/rs-movies/The Seed of the Sacred Fig (2024)/The Seed of the Sacred Fig (2024) {tmdb-1278263} - [WEBDL-1080p][AAC 2.0][h264]-NaNi.mkv"

do_delete "Chris lower quality: House of Gucci (2021)" "/mnt/synology/rs-movies/House of Gucci (2021)/House of Gucci (2021) {tmdb-644495} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Inferno (2016)" "/mnt/synology/rs-movies/Inferno (2016)/Inferno (2016) {tmdb-207932} - [HDTV-1080p][AC3 2.0][x264].mkv"

do_delete "Chris lower quality: Practical Magic (1998)" "/mnt/synology/rs-movies/Practical Magic (1998)/Practical Magic (1998) {tmdb-6435} - [Bluray-1080p][AC3 5.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: Sister Act (1992)" "/mnt/synology/rs-movies/Sister Act (1992)/Sister Act (1992) {tmdb-2005} - [Bluray-1080p][AC3 5.1][x264]-CiNEFiLE.mkv"

do_delete "Chris lower quality: The Lego Movie (2014)" "/mnt/synology/rs-movies/The Lego Movie (2014)/The Lego Movie (2014) {tmdb-137106} - [Bluray-1080p][DTS 5.1][x264]-CyTSuNee.mkv"

do_delete "Chris lower quality: Winters Bone (2010)" "/mnt/synology/rs-movies/Winters Bone (2010)/Winters Bone (2010) {tmdb-39013} - [Bluray-1080p][DTS 5.1][x264]-SECTOR7.mkv"

do_delete "Chris lower quality: Jerry and Marge Go Large (2022)" "/mnt/synology/rs-movies/Jerry and Marge Go Large (2022)/Jerry and Marge Go Large (2022) {tmdb-843847} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Ferrari (2023)" "/mnt/synology/rs-movies/Ferrari (2023)/Ferrari (2023) {tmdb-365620} - [AMZN][WEBDL-1080p Proper][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Life (2017)" "/mnt/synology/rs-movies/Life (2017)/Life (2017) {tmdb-395992} - [Bluray-1080p][DTS 5.1][x264]-Geek.mkv"

do_delete "Chris lower quality: Bring Her Back (2025)" "/mnt/synology/rs-movies/Bring Her Back (2025)/Bring Her Back (2025) {tmdb-1151031} - [Bluray-1080p][TrueHD Atmos 7.1][h264]-RiSEHD.mkv"

do_delete "Chris lower quality: Dumb and Dumber (1994)" "/mnt/synology/rs-movies/Dumb and Dumber (1994)/Dumb and Dumber (1994) {tmdb-8467} - {edition-Theatrical Cut} [AMZN][WEBDL-1080p][EAC3 2.0][x264]-KADENZZA.mkv"

do_delete "Chris lower quality: 10 Cloverfield Lane (2016)" "/mnt/synology/rs-movies/10 Cloverfield Lane (2016)/10 Cloverfield Lane (2016) {tmdb-333371} - [Bluray-1080p][AC3 5.1][x264]-Chotab.mkv"

do_delete "Chris lower quality: Childs Play 2 (1990)" "/mnt/synology/rs-movies/Childs Play 2 (1990)/Childs Play 2 (1990) {tmdb-11186} - [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv"

do_delete "Chris lower quality: Must Love Dogs (2005)" "/mnt/synology/rs-movies/Must Love Dogs (2005)/Must Love Dogs (2005) {tmdb-11648} - [AMZN][WEBDL-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Diego Maradona (2019)" "/mnt/synology/rs-movies/Diego Maradona (2019)/Diego Maradona (2019) {tmdb-536841} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv"

do_delete "Chris lower quality: Constantine (2005)" "/mnt/synology/rs-movies/Constantine (2005)/Constantine (2005) {tmdb-561} - [Bluray-1080p][DTS 5.1][x264]-HiDt.mkv"

do_delete "Chris lower quality: Phenomenon (1996)" "/mnt/synology/rs-movies/Phenomenon (1996)/Phenomenon (1996) {tmdb-9294} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: The House with a Clock in Its Walls (2018)" "/mnt/synology/rs-movies/The House with a Clock in Its Walls (2018)/The House with a Clock in Its Walls (2018) {tmdb-463821} - [MA][WEBDL-1080p][EAC3 5.1][x264]-HHWEB.mkv"

do_delete "Chris lower quality: Pitch Black (2000)" "/mnt/synology/rs-movies/Pitch Black (2000)/Pitch Black (2000) {tmdb-2787} - {edition-Director's Cut} [Bluray-1080p][EAC3 5.1][HDR10][x265]-DON.mkv"

do_delete "Chris lower quality: Journey 2 The Mysterious Island (2012)" "/mnt/synology/rs-movies/Journey 2 The Mysterious Island (2012)/Journey 2 The Mysterious Island (2012) {tmdb-72545} - [WEBDL-1080p][EAC3 5.1][x264]-GPRS.mkv"

do_delete "Chris lower quality: American Psycho (2000)" "/mnt/synology/rs-movies/American Psycho (2000)/American Psycho (2000) {tmdb-1359} - [Bluray-1080p][EAC3 7.1][x264]-c0kE.mkv"

do_delete "Chris lower quality: Juliet Naked (2018)" "/mnt/synology/rs-movies/Juliet Naked (2018)/Juliet Naked (2018) {tmdb-458344} - [Bluray-1080p][DTS 5.1][x264]-DRONES.mkv"

do_delete "Chris lower quality: Natural Born Killers (1994)" "/mnt/synology/rs-movies/Natural Born Killers (1994)/Natural Born Killers (1994) {tmdb-241} - {edition-Directors Cut} [Bluray-1080p][DTS 5.1][x264]-NTb.mkv"

do_delete "Chris lower quality: The Mask (1994)" "/mnt/synology/rs-movies/The Mask (1994)/The Mask (1994) {tmdb-854} - [Bluray-1080p][DTS-ES 6.1][x264]-WiLDCAT.mkv"

do_delete "Chris lower quality: In a Valley of Violence (2016)" "/mnt/synology/rs-movies/In a Valley of Violence (2016)/In a Valley of Violence (2016) {tmdb-291356} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: I Hate Valentines Day (2009)" "/mnt/synology/rs-movies/I Hate Valentines Day (2009)/I Hate Valentines Day (2009) {tmdb-20825} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Dampyr (2022)" "/mnt/synology/rs-movies/Dampyr (2022)/Dampyr (2022) {tmdb-644124} - [MA][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Army of Thieves (2021)" "/mnt/synology/rs-movies/Army of Thieves (2021)/Army of Thieves (2021) {tmdb-796499} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Minority Report (2002)" "/mnt/synology/rs-movies/Minority Report (2002)/Minority Report (2002) {tmdb-180} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: The Spiderwick Chronicles (2008)" "/mnt/synology/rs-movies/The Spiderwick Chronicles (2008)/The Spiderwick Chronicles (2008) {tmdb-8204} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Dead Sea (2024)" "/mnt/synology/rs-movies/Dead Sea (2024)/Dead Sea (2024) {tmdb-1308757} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-HypStu.mkv"

do_delete "Chris lower quality: Frida (2002)" "/mnt/synology/rs-movies/Frida (2002)/Frida (2002) {tmdb-1360} - [Bluray-1080p][DTS 5.1][x264]-CHD.mkv"

do_delete "Chris lower quality: Saturday Night (2024)" "/mnt/synology/rs-movies/Saturday Night (2024)/Saturday Night (2024) {tmdb-1120911} - [WEBDL-1080p][EAC3 5.1][h264]-WiseCormorantOfInspiringArtistry.mkv"

do_delete "Chris lower quality: All That Breathes (2022)" "/mnt/synology/rs-movies/All That Breathes (2022)/All That Breathes (2022) {tmdb-913838} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Madeas Big Happy Family (2011)" "/mnt/synology/rs-movies/Madeas Big Happy Family (2011)/Madeas Big Happy Family (2011) {tmdb-51017} - [Bluray-1080p][DTS 5.1][x264]-AMIABLE.mkv"

do_delete "Chris lower quality: The Creator (2023)" "/mnt/synology/rs-movies/The Creator (2023)/The Creator (2023) {tmdb-670292} - [MA][WEBDL-1080p Proper][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Ballerina (2025)" "/mnt/synology/rs-movies/Ballerina (2025)/Ballerina (2025) {tmdb-541671} - [Bluray-1080p][TrueHD Atmos 7.1][x264]-ROEN.mkv"

do_delete "Chris lower quality: Pineapple Express (2008)" "/mnt/synology/rs-movies/Pineapple Express (2008)/Pineapple Express (2008) {tmdb-10189} - [Bluray-1080p][EAC3 5.1][HDR10][h265].mkv"

do_delete "Chris lower quality: Marcel the Shell with Shoes On (2022)" "/mnt/synology/rs-movies/Marcel the Shell with Shoes On (2022)/Marcel the Shell with Shoes On (2022) {tmdb-869626} - [Bluray-1080p][TrueHD Atmos 7.1][x264]-MiMiC.mkv"

do_delete "Chris lower quality: Eraser (1996)" "/mnt/synology/rs-movies/Eraser (1996)/Eraser (1996) {tmdb-9268} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Erin Brockovich (2000)" "/mnt/synology/rs-movies/Erin Brockovich (2000)/Erin Brockovich (2000) {tmdb-462} - [Bluray-1080p][DTS 5.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: Batman The Doom That Came to Gotham (2023)" "/mnt/synology/rs-movies/Batman The Doom That Came to Gotham (2023)/Batman The Doom That Came to Gotham (2023) {tmdb-1003579} - [WEBDL-1080p][EAC3 5.1][h264]-SKiZOiD.mkv"

do_delete "Chris lower quality: Blade Runner 2049 (2017)" "/mnt/synology/rs-movies/Blade Runner 2049 (2017)/Blade Runner 2049 (2017) {tmdb-335984} - [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv"

do_delete "Chris lower quality: Star Wars The Rise of Skywalker (2019)" "/mnt/synology/rs-movies/Star Wars The Rise of Skywalker (2019)/Star Wars The Rise of Skywalker (2019) {tmdb-181812} - [Bluray-1080p][DTS 5.1][x264]-CHD.mkv"

do_delete "Chris lower quality: Freelance (2023)" "/mnt/synology/rs-movies/Freelance (2023)/Freelance (2023) {tmdb-897087} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Thir13en Ghosts (2001)" "/mnt/synology/rs-movies/Thir13en Ghosts (2001)/Thir13en Ghosts (2001) {tmdb-9378} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-YUUNMY.mkv"

do_delete "Chris lower quality: Desperation Road (2023)" "/mnt/synology/rs-movies/Desperation Road (2023)/Desperation Road (2023) {tmdb-1039690} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: The Dreamers (2003)" "/mnt/synology/rs-movies/The Dreamers (2003)/The Dreamers (2003) {tmdb-1278} - [Bluray-1080p][AC3 5.1][x264]-Geek.mkv"

do_delete "Chris lower quality: The Boys in the Boat (2023)" "/mnt/synology/rs-movies/The Boys in the Boat (2023)/The Boys in the Boat (2023) {tmdb-823452} - [AMZN][WEBDL-1080p Proper][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Oliver and Company (1988)" "/mnt/synology/rs-movies/Oliver and Company (1988)/Oliver and Company (1988) {tmdb-12233} - [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv"

do_delete "Chris lower quality: Flashdance (1983)" "/mnt/synology/rs-movies/Flashdance (1983)/Flashdance (1983) {tmdb-535} - [Bluray-1080p][EAC3 5.1][DV HDR10][x265]-PTer.mkv"

do_delete "Chris lower quality: Jumanji The Next Level (2019)" "/mnt/synology/rs-movies/Jumanji The Next Level (2019)/Jumanji The Next Level (2019) {tmdb-512200} - [WEBDL-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Wanted (2008)" "/mnt/synology/rs-movies/Wanted (2008)/Wanted (2008) {tmdb-8909} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Dirty Harry (1971)" "/mnt/synology/rs-movies/Dirty Harry (1971)/Dirty Harry (1971) {tmdb-984} - [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: In Time (2011)" "/mnt/synology/rs-movies/In Time (2011)/In Time (2011) {tmdb-49530} - [WEBDL-1080p][DTS 5.1][h264].mkv"

do_delete "Chris lower quality: Jurassic Park (1993)" "/mnt/synology/rs-movies/Jurassic Park (1993)/Jurassic Park (1993) {tmdb-329} - [Bluray-1080p][DTS-ES 6.1][x264].mkv"

do_delete "Chris lower quality: Ezra (2024)" "/mnt/synology/rs-movies/Ezra (2024)/Ezra (2024) {tmdb-977262} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv"

do_delete "Chris lower quality: Jack Reacher Never Go Back (2016)" "/mnt/synology/rs-movies/Jack Reacher Never Go Back (2016)/Jack Reacher Never Go Back (2016) {tmdb-343611} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Legend (2015)" "/mnt/synology/rs-movies/Legend (2015)/Legend (2015) {tmdb-276907} - [Bluray-1080p][DTS-HD MA 7.1][x264]-FraMeSToR.mkv"

do_delete "Chris lower quality: Smurfs (2025)" "/mnt/synology/rs-movies/Smurfs (2025)/Smurfs (2025) {tmdb-936108} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: The 4 - 30 Movie (2024)" "/mnt/synology/rs-movies/The 4 - 30 Movie (2024)/The 4 - 30 Movie (2024) {tmdb-1146556} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: She Rides Shotgun (2025)" "/mnt/synology/rs-movies/She Rides Shotgun (2025)/She Rides Shotgun (2025) {tmdb-1196573} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: The Bridge on the River Kwai (1957)" "/mnt/synology/rs-movies/The Bridge on the River Kwai (1957)/The Bridge on the River Kwai (1957) {tmdb-826} - [WEBDL-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Uncle Buck (1989)" "/mnt/synology/rs-movies/Uncle Buck (1989)/Uncle Buck (1989) {tmdb-2616} - [Bluray-1080p][DTS 2.0][x264].mkv"

do_delete "Chris lower quality: Paranormal Activity Next of Kin (2021)" "/mnt/synology/rs-movies/Paranormal Activity Next of Kin (2021)/Paranormal Activity Next of Kin (2021) {tmdb-609972} - [WEBDL-1080p Proper][EAC3 5.1][x264]-GS88.mkv"

do_delete "Chris lower quality: Old Guy (2024)" "/mnt/synology/rs-movies/Old Guy (2024)/Old Guy (2024) {tmdb-1077782} - [WEBDL-1080p][AC3 5.1][h264]-KBOX.mkv"

do_delete "Chris lower quality: Requiem for a Dream (2000)" "/mnt/synology/rs-movies/Requiem for a Dream (2000)/Requiem for a Dream (2000) {tmdb-641} - {edition-Director's Cut} [Bluray-1080p][DTS-HD MA 7.1][h264].mkv"

do_delete "Chris lower quality: One Night in Miami. (2020)" "/mnt/synology/rs-movies/One Night in Miami. (2020)/One Night in Miami. (2020) {tmdb-661914} - [WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Mickey 17 (2025)" "/mnt/synology/rs-movies/Mickey 17 (2025)/Mickey 17 (2025) {tmdb-696506} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: Clown in a Cornfield (2025)" "/mnt/synology/rs-movies/Clown in a Cornfield (2025)/Clown in a Cornfield (2025) {tmdb-713364} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: Lee (2024)" "/mnt/synology/rs-movies/Lee (2024)/Lee (2024) {tmdb-832964} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: The Hobbit An Unexpected Journey (2012)" "/mnt/synology/rs-movies/The Hobbit An Unexpected Journey (2012)/The Hobbit An Unexpected Journey (2012) {tmdb-49051} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Fantasia 2000 (2000)" "/mnt/synology/rs-movies/Fantasia 2000 (2000)/Fantasia 2000 (2000) {tmdb-49948} - [Bluray-1080p][DTS 5.1][x264]-EbP.mkv"

do_delete "Chris lower quality: Derailed (2005)" "/mnt/synology/rs-movies/Derailed (2005)/Derailed (2005) {tmdb-8999} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: The Life Aquatic with Steve Zissou (2004)" "/mnt/synology/rs-movies/The Life Aquatic with Steve Zissou (2004)/The Life Aquatic with Steve Zissou (2004) {tmdb-421} - [Bluray-1080p][DTS 5.1][x264]-HD4U.mkv"

do_delete "Chris lower quality: The Cursed (2021)" "/mnt/synology/rs-movies/The Cursed (2021)/The Cursed (2021) {tmdb-630392} - [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: Little Bone Lodge (2023)" "/mnt/synology/rs-movies/Little Bone Lodge (2023)/Little Bone Lodge (2023) {tmdb-1075335} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-THR.mkv"

do_delete "Chris lower quality: Clara Sola (2021)" "/mnt/synology/rs-movies/Clara Sola (2021)/Clara Sola (2021) {tmdb-785212} - [WEBDL-1080p][AAC 5.1][x264]-Kururun.mkv"

do_delete "Chris lower quality: Knives Out (2019)" "/mnt/synology/rs-movies/Knives Out (2019)/Knives Out (2019) {tmdb-546554} - [Bluray-1080p][EAC3 5.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: Dear Evan Hansen (2021)" "/mnt/synology/rs-movies/Dear Evan Hansen (2021)/Dear Evan Hansen (2021) {tmdb-567690} - [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: Perpetrator (2023)" "/mnt/synology/rs-movies/Perpetrator (2023)/Perpetrator (2023) {tmdb-1061656} - [WEBDL-1080p][EAC3 5.1][h264]-EDITH.mkv"

do_delete "Chris lower quality: Infinite Storm (2022)" "/mnt/synology/rs-movies/Infinite Storm (2022)/Infinite Storm (2022) {tmdb-811631} - [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv"

do_delete "Chris lower quality: Tenacious D in The Pick of Destiny (2006)" "/mnt/synology/rs-movies/Tenacious D in The Pick of Destiny (2006)/Tenacious D in The Pick of Destiny (2006) {tmdb-2179} - [AMZN][WEBDL-1080p][DTS-ES 6.1][x264]-TenaciousD.mkv"

do_delete "Chris lower quality: Eternals (2021)" "/mnt/synology/rs-movies/Eternals (2021)/Eternals (2021) {tmdb-524434} - [WEBDL-1080p][EAC3 5.1][x264]-EVO.mkv"

do_delete "Chris lower quality: Definitely Maybe (2008)" "/mnt/synology/rs-movies/Definitely Maybe (2008)/Definitely Maybe (2008) {tmdb-8390} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-GPRS.mkv"

do_delete "Chris lower quality: Eddington (2025)" "/mnt/synology/rs-movies/Eddington (2025)/Eddington (2025) {tmdb-648878} - [Bluray-1080p][TrueHD Atmos 7.1][h264]-COCAIN.mkv"

do_delete "Chris lower quality: The Great Escape (1963)" "/mnt/synology/rs-movies/The Great Escape (1963)/The Great Escape (1963) {tmdb-5925} - [WEBDL-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Side Effects (2013)" "/mnt/synology/rs-movies/Side Effects (2013)/Side Effects (2013) {tmdb-109421} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Justice League The Flashpoint Paradox (2013)" "/mnt/synology/rs-movies/Justice League The Flashpoint Paradox (2013)/Justice League The Flashpoint Paradox (2013) {tmdb-183011} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Happiest Season (2020)" "/mnt/synology/rs-movies/Happiest Season (2020)/Happiest Season (2020) {tmdb-520172} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-NTb.mkv"

do_delete "Chris lower quality: Zero Dark Thirty (2012)" "/mnt/synology/rs-movies/Zero Dark Thirty (2012)/Zero Dark Thirty (2012) {tmdb-97630} - [Bluray-1080p][EAC3 7.1][HDR10][x265]-CtrlHD.mkv"

do_delete "Chris lower quality: The Nightmare Before Christmas (1993)" "/mnt/synology/rs-movies/The Nightmare Before Christmas (1993)/The Nightmare Before Christmas (1993) {tmdb-9479} - [DSNP][WEBDL-1080p][EAC3 5.1][h264]-GPRS.mkv"

do_delete "Chris lower quality: Four Rooms (1995)" "/mnt/synology/rs-movies/Four Rooms (1995)/Four Rooms (1995) {tmdb-5} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Ace Ventura When Nature Calls (1995)" "/mnt/synology/rs-movies/Ace Ventura When Nature Calls (1995)/Ace Ventura When Nature Calls (1995) {tmdb-9273} - [HDTV-1080p][AAC 2.0][h264].mkv"

do_delete "Chris lower quality: Thelma and Louise (1991)" "/mnt/synology/rs-movies/Thelma and Louise (1991)/Thelma and Louise (1991) {tmdb-1541} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: 65 (2023)" "/mnt/synology/rs-movies/65 (2023)/65 (2023) {tmdb-700391} - [MA][WEBDL-1080p Proper][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Love Lies Bleeding (2024)" "/mnt/synology/rs-movies/Love Lies Bleeding (2024)/Love Lies Bleeding (2024) {tmdb-948549} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Assassin (2023)" "/mnt/synology/rs-movies/Assassin (2023)/Assassin (2023) {tmdb-921355} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Spider-Man Across the Spider-Verse (2023)" "/mnt/synology/rs-movies/Spider-Man Across the Spider-Verse (2023)/Spider-Man Across the Spider-Verse (2023) {tmdb-569094} - [WEBDL-1080p][EAC3 5.1][x264]-XEBEC.mkv"

do_delete "Chris lower quality: Clerks III (2022)" "/mnt/synology/rs-movies/Clerks III (2022)/Clerks III (2022) {tmdb-635891} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-SMURF.mkv"

do_delete "Chris lower quality: Poor Things (2023)" "/mnt/synology/rs-movies/Poor Things (2023)/Poor Things (2023) {tmdb-792307} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv"

do_delete "Chris lower quality: Uncut Gems (2019)" "/mnt/synology/rs-movies/Uncut Gems (2019)/Uncut Gems (2019) {tmdb-473033} - [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv"

do_delete "Chris lower quality: To End All War Oppenheimer and the Atomic Bomb (2023)" "/mnt/synology/rs-movies/To End All War Oppenheimer and the Atomic Bomb (2023)/To End All War Oppenheimer and the Atomic Bomb (2023) {tmdb-1149947} - [PCOK][WEBDL-1080p][EAC3 5.1][x264]-PTerWEB.mkv"

do_delete "Chris lower quality: Old Dads (2023)" "/mnt/synology/rs-movies/Old Dads (2023)/Old Dads (2023) {tmdb-987917} - [NF][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Muzzle (2023)" "/mnt/synology/rs-movies/Muzzle (2023)/Muzzle (2023) {tmdb-939335} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-SCOPE.mkv"

do_delete "Chris lower quality: Men in Black II (2002)" "/mnt/synology/rs-movies/Men in Black II (2002)/Men in Black II (2002) {tmdb-608} - [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv"

do_delete "Chris lower quality: Rebel Without a Cause (1955)" "/mnt/synology/rs-movies/Rebel Without a Cause (1955)/Rebel Without a Cause (1955) {tmdb-221} - [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv"

do_delete "Chris lower quality: Charlies Angels (2019)" "/mnt/synology/rs-movies/Charlies Angels (2019)/Charlies Angels (2019) {tmdb-458897} - [WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv"

do_delete "Chris lower quality: Elvis (2022)" "/mnt/synology/rs-movies/Elvis (2022)/Elvis (2022) {tmdb-614934} - [WEBDL-1080p][AC3 5.1][x264]-EVO.mkv"

do_delete "Chris lower quality: The Other Guys (2010)" "/mnt/synology/rs-movies/The Other Guys (2010)/The Other Guys (2010) {tmdb-27581} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: The Cannonball Run (1981)" "/mnt/synology/rs-movies/The Cannonball Run (1981)/The Cannonball Run (1981) {tmdb-11286} - [Bluray-1080p][AC3 5.1][x264]-HDMaNiAcS.mkv"

do_delete "Chris lower quality: Death Wish (2018)" "/mnt/synology/rs-movies/Death Wish (2018)/Death Wish (2018) {tmdb-395990} - [Bluray-1080p][DTS 5.1][x264]-uRaMeSHi.mkv"

do_delete "Chris lower quality: The Prosecutor (2024)" "/mnt/synology/rs-movies/The Prosecutor (2024)/The Prosecutor (2024) {tmdb-1128650} - [WEBDL-1080p][AAC 2.0][h264]-HHWEB.mkv"

do_delete "Chris lower quality: Hamlet (1990)" "/mnt/synology/rs-movies/Hamlet (1990)/Hamlet (1990) {tmdb-10264} - [WEBDL-1080p][DTS 2.0][x264].mkv"

do_delete "Chris lower quality: Moon (2009)" "/mnt/synology/rs-movies/Moon (2009)/Moon (2009) {tmdb-17431} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: A Working Man (2025)" "/mnt/synology/rs-movies/A Working Man (2025)/A Working Man (2025) {tmdb-1197306} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-ETHEL.mkv"

do_delete "Chris lower quality: Unhuman (2022)" "/mnt/synology/rs-movies/Unhuman (2022)/Unhuman (2022) {tmdb-839678} - [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: Red Sonja (2025)" "/mnt/synology/rs-movies/Red Sonja (2025)/Red Sonja (2025) {tmdb-13494} - [WEBDL-1080p][EAC3 5.1][h264]-AOC.mkv"

do_delete "Chris lower quality: Batman The Long Halloween Part Two (2021)" "/mnt/synology/rs-movies/Batman The Long Halloween Part Two (2021)/Batman The Long Halloween Part Two (2021) {tmdb-736074} - [WEBDL-1080p][EAC3 5.1][x264]-EVO.mkv"

do_delete "Chris lower quality: Mary Poppins (1964)" "/mnt/synology/rs-movies/Mary Poppins (1964)/Mary Poppins (1964) {tmdb-433} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Brotherhood of the Wolf (2001)" "/mnt/synology/rs-movies/Brotherhood of the Wolf (2001)/Brotherhood of the Wolf (2001) {tmdb-6312} - [Bluray-1080p][DTS-HD MA 5.1][x264]-EUBDS.mkv"

do_delete "Chris lower quality: Wonder Woman (2017)" "/mnt/synology/rs-movies/Wonder Woman (2017)/Wonder Woman (2017) {tmdb-297762} - [WEBDL-1080p][AC3 5.1][h264].mkv"

do_delete "Chris lower quality: Shark Tale (2004)" "/mnt/synology/rs-movies/Shark Tale (2004)/Shark Tale (2004) {tmdb-10555} - [HDTV-1080p][AC3 5.1][h264].mkv"

do_delete "Chris lower quality: Escape from Planet Earth (2013)" "/mnt/synology/rs-movies/Escape from Planet Earth (2013)/Escape from Planet Earth (2013) {tmdb-68179} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Psycho (1960)" "/mnt/synology/rs-movies/Psycho (1960)/Psycho (1960) {tmdb-539} - {edition-Uncut} [Bluray-1080p][AC3 5.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: Annette (2021)" "/mnt/synology/rs-movies/Annette (2021)/Annette (2021) {tmdb-424277} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Chinatown (1974)" "/mnt/synology/rs-movies/Chinatown (1974)/Chinatown (1974) {tmdb-829} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: Woman of the Hour (2024)" "/mnt/synology/rs-movies/Woman of the Hour (2024)/Woman of the Hour (2024) {tmdb-835113} - [WEBDL-1080p][EAC3 Atmos 5.1][x264]-ETHEL.mkv"

do_delete "Chris lower quality: Haunted Mansion (2023)" "/mnt/synology/rs-movies/Haunted Mansion (2023)/Haunted Mansion (2023) {tmdb-616747} - [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: The Boogeyman (2023)" "/mnt/synology/rs-movies/The Boogeyman (2023)/The Boogeyman (2023) {tmdb-532408} - [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Smile (2022)" "/mnt/synology/rs-movies/Smile (2022)/Smile (2022) {tmdb-882598} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Savage Sam (1963)" "/mnt/synology/rs-movies/Savage Sam (1963)/Savage Sam (1963) {tmdb-50033} - [AMZN][WEBRip-1080p][EAC3 5.1][x264]-ABM.mkv"

do_delete "Chris lower quality: Bird (2024)" "/mnt/synology/rs-movies/Bird (2024)/Bird (2024) {tmdb-1128752} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv"

do_delete "Chris lower quality: The Amazing Spider-Man 2 (2014)" "/mnt/synology/rs-movies/The Amazing Spider-Man 2 (2014)/The Amazing Spider-Man 2 (2014) {tmdb-102382} - [Bluray-1080p][AC3 5.1][x264]-decibeL.mkv"

do_delete "Chris lower quality: Mike and Dave Need Wedding Dates (2016)" "/mnt/synology/rs-movies/Mike and Dave Need Wedding Dates (2016)/Mike and Dave Need Wedding Dates (2016) {tmdb-316023} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-PiRaTeS.mkv"

do_delete "Chris lower quality: Beverly Hills Cop Axel F (2024)" "/mnt/synology/rs-movies/Beverly Hills Cop Axel F (2024)/Beverly Hills Cop Axel F (2024) {tmdb-280180} - [WEBDL-1080p][EAC3 Atmos 5.1][x264]-ETHEL.mkv"

do_delete "Chris lower quality: Star Trek Nemesis (2002)" "/mnt/synology/rs-movies/Star Trek Nemesis (2002)/Star Trek Nemesis (2002) {tmdb-201} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv"

do_delete "Chris lower quality: Kronks New Groove (2005)" "/mnt/synology/rs-movies/Kronks New Groove (2005)/Kronks New Groove (2005) {tmdb-13417} - [DVD][DTS 5.1][MPEG2].mkv"

do_delete "Chris lower quality: Sorority Babes in the Slimeball Bowl-O-Rama (1988)" "/mnt/synology/rs-movies/Sorority Babes in the Slimeball Bowl-O-Rama (1988)/Sorority Babes in the Slimeball Bowl-O-Rama (1988) {tmdb-27390} - [AMZN MA][WEBDL-1080p][EAC3 2.0][h264]-Kitsune.mkv"

do_delete "Chris lower quality: Prince of Persia The Sands of Time (2010)" "/mnt/synology/rs-movies/Prince of Persia The Sands of Time (2010)/Prince of Persia The Sands of Time (2010) {tmdb-9543} - {edition-Open Matte} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-spartanec163.mkv"

do_delete "Chris lower quality: The Hobbit The Battle of the Five Armies (2014)" "/mnt/synology/rs-movies/The Hobbit The Battle of the Five Armies (2014)/The Hobbit The Battle of the Five Armies (2014) {tmdb-122917} - [Bluray-1080p][DTS-HD MA 7.1][x264].mkv"

do_delete "Chris lower quality: Murina (2022)" "/mnt/synology/rs-movies/Murina (2022)/Murina (2022) {tmdb-838148} - [WEBDL-1080p][AAC 2.0][x264]-KUCHU.mkv"

do_delete "Chris lower quality: The Transformers The Movie (1986)" "/mnt/synology/rs-movies/The Transformers The Movie (1986)/The Transformers The Movie (1986) {tmdb-1857} - [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: No Way Out (1987)" "/mnt/synology/rs-movies/No Way Out (1987)/No Way Out (1987) {tmdb-10083} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-GPRS.mkv"

do_delete "Chris lower quality: Middle Men (2009)" "/mnt/synology/rs-movies/Middle Men (2009)/Middle Men (2009) {tmdb-38842} - [Bluray-1080p][DTS 5.1][x264]-SECTOR7.mkv"

do_delete "Chris lower quality: The Princess and the Frog (2009)" "/mnt/synology/rs-movies/The Princess and the Frog (2009)/The Princess and the Frog (2009) {tmdb-10198} - [DSNP][WEBDL-1080p][EAC3 Atmos 5.1][h264]-GPRS.mkv"

do_delete "Chris lower quality: Justice League x RWBY Super Heroes and Huntsmen Part One (2023)" "/mnt/synology/rs-movies/Justice League x RWBY Super Heroes and Huntsmen Part One (2023)/Justice League x RWBY Super Heroes and Huntsmen Part One (2023) {tmdb-997776} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-playWEB.mkv"

do_delete "Chris lower quality: Talk to Me (2023)" "/mnt/synology/rs-movies/Talk to Me (2023)/Talk to Me (2023) {tmdb-1008042} - [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Maestro (2023)" "/mnt/synology/rs-movies/Maestro (2023)/Maestro (2023) {tmdb-523607} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-playWEB.mkv"

do_delete "Chris lower quality: MaXXXine (2024)" "/mnt/synology/rs-movies/MaXXXine (2024)/MaXXXine (2024) {tmdb-1023922} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Batman Mystery of the Batwoman (2003)" "/mnt/synology/rs-movies/Batman Mystery of the Batwoman (2003)/Batman Mystery of the Batwoman (2003) {tmdb-21683} - [WEBDL-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Ghost in the Shell (2017)" "/mnt/synology/rs-movies/Ghost in the Shell (2017)/Ghost in the Shell (2017) {tmdb-315837} - [Bluray-1080p][EAC3 5.1][x264].mkv"

do_delete "Chris lower quality: Killers of the Flower Moon (2023)" "/mnt/synology/rs-movies/Killers of the Flower Moon (2023)/Killers of the Flower Moon (2023) {tmdb-466420} - [AMZN][WEBDL-1080p Proper][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Neptune Frost (2022)" "/mnt/synology/rs-movies/Neptune Frost (2022)/Neptune Frost (2022) {tmdb-671109} - [Bluray-1080p][AC3 5.1][x264]-OFT.mkv"

do_delete "Chris lower quality: Tombstone (1993)" "/mnt/synology/rs-movies/Tombstone (1993)/Tombstone (1993) {tmdb-11969} - [Bluray-1080p][DTS-HD MA 5.1][h264].mkv"

do_delete "Chris lower quality: Teenage Mutant Ninja Turtles (1990)" "/mnt/synology/rs-movies/Teenage Mutant Ninja Turtles (1990)/Teenage Mutant Ninja Turtles (1990) {tmdb-1498} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv"

do_delete "Chris lower quality: Blood Brothers Malcolm X and Muhammad Ali (2021)" "/mnt/synology/rs-movies/Blood Brothers Malcolm X and Muhammad Ali (2021)/Blood Brothers Malcolm X and Muhammad Ali (2021) {tmdb-861604} - [WEBDL-1080p][EAC3 Atmos 5.1][x264]-PECULATE.mkv"

do_delete "Chris lower quality: Airplane II The Sequel (1982)" "/mnt/synology/rs-movies/Airplane II The Sequel (1982)/Airplane II The Sequel (1982) {tmdb-2665} - [Bluray-1080p][DTS 2.0][x264].mkv"

do_delete "Chris lower quality: Cold Mountain (2003)" "/mnt/synology/rs-movies/Cold Mountain (2003)/Cold Mountain (2003) {tmdb-2289} - [Bluray-1080p][AC3 5.1][x264]-SA89.mkv"

do_delete "Chris lower quality: Mad God (2021)" "/mnt/synology/rs-movies/Mad God (2021)/Mad God (2021) {tmdb-846867} - [WEBDL-1080p][AAC 2.0][h264].mkv"

do_delete "Chris lower quality: Ant-Man (2015)" "/mnt/synology/rs-movies/Ant-Man (2015)/Ant-Man (2015) {tmdb-102899} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Kiss of the Dragon (2001)" "/mnt/synology/rs-movies/Kiss of the Dragon (2001)/Kiss of the Dragon (2001) {tmdb-2140} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Eden (2025)" "/mnt/synology/rs-movies/Eden (2025)/Eden (2025) {tmdb-1042834} - [Bluray-1080p][FLAC 2.0][x264]-PTP.mkv"

do_delete "Chris lower quality: 3 Ninjas (1992)" "/mnt/synology/rs-movies/3 Ninjas (1992)/3 Ninjas (1992) {tmdb-16314} - [AMZN][WEBDL-1080p][EAC3 2.0][x264]-ABM.mkv"

do_delete "Chris lower quality: Charlies Angels (2000)" "/mnt/synology/rs-movies/Charlies Angels (2000)/Charlies Angels (2000) {tmdb-4327} - [Bluray-1080p][DTS 5.1][x264]-SbR.mkv"

do_delete "Chris lower quality: Captain America The First Avenger (2011)" "/mnt/synology/rs-movies/Captain America The First Avenger (2011)/Captain America The First Avenger (2011) {tmdb-1771} - [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv"

do_delete "Chris lower quality: Carrie (1976)" "/mnt/synology/rs-movies/Carrie (1976)/Carrie (1976) {tmdb-7340} - [Bluray-1080p][DTS 5.1][x264]-AMIABLE.mkv"

do_delete "Chris lower quality: Wrong Turn (2003)" "/mnt/synology/rs-movies/Wrong Turn (2003)/Wrong Turn (2003) {tmdb-9902} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: The Quiet Earth (1985)" "/mnt/synology/rs-movies/The Quiet Earth (1985)/The Quiet Earth (1985) {tmdb-10176} - [AMZN][WEBDL-1080p][EAC3 2.0][h264]-GPRS.mkv"

do_delete "Chris lower quality: Ash (2025)" "/mnt/synology/rs-movies/Ash (2025)/Ash (2025) {tmdb-931349} - [WEBDL-1080p][EAC3 5.1][h264]-DiligentSpectralCougarOfPassion.mkv"

do_delete "Chris lower quality: Oliver! (1968)" "/mnt/synology/rs-movies/Oliver! (1968)/Oliver! (1968) {tmdb-17917} - [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv"

do_delete "Chris lower quality: Creed II (2018)" "/mnt/synology/rs-movies/Creed II (2018)/Creed II (2018) {tmdb-480530} - [WEBDL-1080p][AC3 5.1][h264].mkv"

do_delete "Chris lower quality: Jimmy Carr Funny Business (2016)" "/mnt/synology/rs-movies/Jimmy Carr Funny Business (2016)/Jimmy Carr Funny Business (2016) {tmdb-387054} - [WEBRip-1080p][AC3 5.1][x264]-RARBG.mkv"

do_delete "Chris lower quality: Borderline (2025)" "/mnt/synology/rs-movies/Borderline (2025)/Borderline (2025) {tmdb-1013482} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: El Camino A Breaking Bad Movie (2019)" "/mnt/synology/rs-movies/El Camino A Breaking Bad Movie (2019)/El Camino A Breaking Bad Movie (2019) {tmdb-559969} - [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv"

do_delete "Chris lower quality: Slotherhouse (2023)" "/mnt/synology/rs-movies/Slotherhouse (2023)/Slotherhouse (2023) {tmdb-1040892} - [WEBDL-1080p][EAC3 5.1][h264]-BobDobbs.mkv"

do_delete "Chris lower quality: Cliffhanger (1993)" "/mnt/synology/rs-movies/Cliffhanger (1993)/Cliffhanger (1993) {tmdb-9350} - [Bluray-1080p][DTS-HD MA 5.1][x264]-HDH.mkv"

do_delete "Chris lower quality: Venom The Last Dance (2024)" "/mnt/synology/rs-movies/Venom The Last Dance (2024)/Venom The Last Dance (2024) {tmdb-912649} - {edition-Extended Cut} [Bluray-1080p][EAC3 7.1][x264]-RO.mkv"

do_delete "Chris lower quality: Mortal Kombat (1995)" "/mnt/synology/rs-movies/Mortal Kombat (1995)/Mortal Kombat (1995) {tmdb-9312} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Lost in Translation (2003)" "/mnt/synology/rs-movies/Lost in Translation (2003)/Lost in Translation (2003) {tmdb-153} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Daffodils.mkv"

do_delete "Chris lower quality: I Know What You Did Last Summer (1997)" "/mnt/synology/rs-movies/I Know What You Did Last Summer (1997)/I Know What You Did Last Summer (1997) {tmdb-3597} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: 21 Bridges (2019)" "/mnt/synology/rs-movies/21 Bridges (2019)/21 Bridges (2019) {tmdb-535292} - [Bluray-1080p][DTS 5.1][x264]-AAA.mkv"

do_delete "Chris lower quality: 12 Angry Men (1957)" "/mnt/synology/rs-movies/12 Angry Men (1957)/12 Angry Men (1957) {tmdb-389} - [Criterion Collection][Bluray-1080p][FLAC 1.0][x264]-decibeL.mkv"

do_delete "Chris lower quality: Love and Monsters (2020)" "/mnt/synology/rs-movies/Love and Monsters (2020)/Love and Monsters (2020) {tmdb-590223} - [Bluray-1080p][EAC3 7.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: Justice League Gods and Monsters (2015)" "/mnt/synology/rs-movies/Justice League Gods and Monsters (2015)/Justice League Gods and Monsters (2015) {tmdb-323027} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Troll (2022)" "/mnt/synology/rs-movies/Troll (2022)/Troll (2022) {tmdb-736526} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-playWEB.mkv"

do_delete "Chris lower quality: Jurassic World (2015)" "/mnt/synology/rs-movies/Jurassic World (2015)/Jurassic World (2015) {tmdb-135397} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Dungeons and Dragons (2000)" "/mnt/synology/rs-movies/Dungeons and Dragons (2000)/Dungeons and Dragons (2000) {tmdb-11849} - [Bluray-1080p][DTS 5.1][x264]-besthd.mkv"

do_delete "Chris lower quality: Mad Max 2 (1981)" "/mnt/synology/rs-movies/Mad Max 2 (1981)/Mad Max 2 (1981) {tmdb-8810} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: For a Few Dollars More (1965)" "/mnt/synology/rs-movies/For a Few Dollars More (1965)/For a Few Dollars More (1965) {tmdb-938} - {edition-Uncut} [Bluray-1080p][FLAC 2.0][x264]-DON.mkv"

do_delete "Chris lower quality: The Survivor (2022)" "/mnt/synology/rs-movies/The Survivor (2022)/The Survivor (2022) {tmdb-606870} - [WEBDL-1080p][EAC3 5.1][x264]-EVO.mkv"

do_delete "Chris lower quality: American Pie Presents Band Camp (2005)" "/mnt/synology/rs-movies/American Pie Presents Band Camp (2005)/American Pie Presents Band Camp (2005) {tmdb-8274} - {edition-Unrated} [AMZN][WEBRip-1080p][EAC3 5.1][x264]-KiNGS.mkv"

do_delete "Chris lower quality: Star Trek V The Final Frontier (1989)" "/mnt/synology/rs-movies/Star Trek V The Final Frontier (1989)/Star Trek V The Final Frontier (1989) {tmdb-172} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv"

do_delete "Chris lower quality: The Age of Innocence (1993)" "/mnt/synology/rs-movies/The Age of Innocence (1993)/The Age of Innocence (1993) {tmdb-10436} - [Bluray-1080p][DTS 5.1][x264]-LolHD.mkv"

do_delete "Chris lower quality: The Ref (1994)" "/mnt/synology/rs-movies/The Ref (1994)/The Ref (1994) {tmdb-10872} - [AMZN][WEBRip-1080p][EAC3 5.1][x264]-hV.mkv"

do_delete "Chris lower quality: The Woman in the Window (2021)" "/mnt/synology/rs-movies/The Woman in the Window (2021)/The Woman in the Window (2021) {tmdb-520663} - [NF][WEBRip-1080p][EAC3 Atmos 5.1][x264]-TOMMY.mkv"

do_delete "Chris lower quality: The Crow (2024)" "/mnt/synology/rs-movies/The Crow (2024)/The Crow (2024) {tmdb-957452} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-SLOT.mkv"

do_delete "Chris lower quality: How to Lose a Guy in 10 Days (2003)" "/mnt/synology/rs-movies/How to Lose a Guy in 10 Days (2003)/How to Lose a Guy in 10 Days (2003) {tmdb-9919} - [Bluray-1080p][AC3 5.1][x264]-CiNEFiLE.mkv"

do_delete "Chris lower quality: Mulan (2020)" "/mnt/synology/rs-movies/Mulan (2020)/Mulan (2020) {tmdb-337401} - [Bluray-1080p][DTS-HD MA 7.1][x264]-CHD.mkv"

do_delete "Chris lower quality: The Cloverfield Paradox (2018)" "/mnt/synology/rs-movies/The Cloverfield Paradox (2018)/The Cloverfield Paradox (2018) {tmdb-384521} - [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv"

do_delete "Chris lower quality: Infested (2023)" "/mnt/synology/rs-movies/Infested (2023)/Infested (2023) {tmdb-1063879} - [WEBDL-1080p][EAC3 5.1][h264]-heretofuckspiders.mkv"

do_delete "Chris lower quality: The Bone Collector (1999)" "/mnt/synology/rs-movies/The Bone Collector (1999)/The Bone Collector (1999) {tmdb-9481} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Asteroid City (2023)" "/mnt/synology/rs-movies/Asteroid City (2023)/Asteroid City (2023) {tmdb-747188} - [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv"

do_delete "Chris lower quality: Last Shoot Out (2021)" "/mnt/synology/rs-movies/Last Shoot Out (2021)/Last Shoot Out (2021) {tmdb-887767} - [Bluray-1080p][AC3 5.1][x264]-eMc2.mkv"

do_delete "Chris lower quality: The Boss Baby (2017)" "/mnt/synology/rs-movies/The Boss Baby (2017)/The Boss Baby (2017) {tmdb-295693} - [Bluray-1080p][AC3 5.1][x264]-TayTO.mkv"

do_delete "Chris lower quality: Disconnect (2013)" "/mnt/synology/rs-movies/Disconnect (2013)/Disconnect (2013) {tmdb-127517} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: American Pie Presents The Naked Mile (2006)" "/mnt/synology/rs-movies/American Pie Presents The Naked Mile (2006)/American Pie Presents The Naked Mile (2006) {tmdb-8275} - [WEBRip-1080p][EAC3 5.1][x264]-KiNGS.mkv"

do_delete "Chris lower quality: We Live in Time (2024)" "/mnt/synology/rs-movies/We Live in Time (2024)/We Live in Time (2024) {tmdb-1100099} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-Kitsune.mkv"

do_delete "Chris lower quality: Meg 2 The Trench (2023)" "/mnt/synology/rs-movies/Meg 2 The Trench (2023)/Meg 2 The Trench (2023) {tmdb-615656} - [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Office Space (1999)" "/mnt/synology/rs-movies/Office Space (1999)/Office Space (1999) {tmdb-1542} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Marriage Story (2019)" "/mnt/synology/rs-movies/Marriage Story (2019)/Marriage Story (2019) {tmdb-492188} - [WEBDL-1080p][EAC3 5.1][x264]-CMRG.mkv"

do_delete "Chris lower quality: One Battle After Another (2025)" "/mnt/synology/rs-movies/One Battle After Another (2025)/One Battle After Another (2025) {tmdb-1054867} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-KyoGo.mkv"

do_delete "Chris lower quality: Breakwater (2023)" "/mnt/synology/rs-movies/Breakwater (2023)/Breakwater (2023) {tmdb-1006228} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Enola Holmes 2 (2022)" "/mnt/synology/rs-movies/Enola Holmes 2 (2022)/Enola Holmes 2 (2022) {tmdb-829280} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv"

do_delete "Chris lower quality: Smokey and the Bandit (1977)" "/mnt/synology/rs-movies/Smokey and the Bandit (1977)/Smokey and the Bandit (1977) {tmdb-11006} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: She Will (2022)" "/mnt/synology/rs-movies/She Will (2022)/She Will (2022) {tmdb-852485} - [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: Street Kings (2008)" "/mnt/synology/rs-movies/Street Kings (2008)/Street Kings (2008) {tmdb-1266} - [Bluray-1080p][DTS 5.1][x264]-ESiR.mkv"

do_delete "Chris lower quality: Matilda (1996)" "/mnt/synology/rs-movies/Matilda (1996)/Matilda (1996) {tmdb-10830} - [Bluray-1080p][AC3 5.1][x264]-Friday.mkv"

do_delete "Chris lower quality: Missing (2023)" "/mnt/synology/rs-movies/Missing (2023)/Missing (2023) {tmdb-768362} - [MA][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: The Croods A New Age (2020)" "/mnt/synology/rs-movies/The Croods A New Age (2020)/The Croods A New Age (2020) {tmdb-529203} - [WEBDL-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Venom (2018)" "/mnt/synology/rs-movies/Venom (2018)/Venom (2018) {tmdb-335983} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: True Grit (2010)" "/mnt/synology/rs-movies/True Grit (2010)/True Grit (2010) {tmdb-44264} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: The Hunger Games (2012)" "/mnt/synology/rs-movies/The Hunger Games (2012)/The Hunger Games (2012) {tmdb-70160} - [Bluray-1080p][EAC3 7.1][HDR10][x265]-D-Z0N3.mkv"

do_delete "Chris lower quality: The Watch (2012)" "/mnt/synology/rs-movies/The Watch (2012)/The Watch (2012) {tmdb-80035} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Post Grad (2009)" "/mnt/synology/rs-movies/Post Grad (2009)/Post Grad (2009) {tmdb-25704} - [DSNP][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Onward (2020)" "/mnt/synology/rs-movies/Onward (2020)/Onward (2020) {tmdb-508439} - [WEBDL-1080p][EAC3 5.1][x264]-BLUTONiUM.mkv"

do_delete "Chris lower quality: Shaun of the Dead (2004)" "/mnt/synology/rs-movies/Shaun of the Dead (2004)/Shaun of the Dead (2004) {tmdb-747} - [Bluray-1080p][EAC3 7.1][HDR10Plus][x265]-NCmt.mkv"

do_delete "Chris lower quality: RED 2 (2013)" "/mnt/synology/rs-movies/RED 2 (2013)/RED 2 (2013) {tmdb-146216} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Children of the Corn (1984)" "/mnt/synology/rs-movies/Children of the Corn (1984)/Children of the Corn (1984) {tmdb-10823} - [Bluray-1080p][DTS 5.1][x264]-DiVULGED.mkv"

do_delete "Chris lower quality: Conan the Barbarian (1982)" "/mnt/synology/rs-movies/Conan the Barbarian (1982)/Conan the Barbarian (1982) {tmdb-9387} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Cant Hardly Wait (1998)" "/mnt/synology/rs-movies/Cant Hardly Wait (1998)/Cant Hardly Wait (1998) {tmdb-15037} - [Bluray-1080p Proper][EAC3 5.1][x264]-playHD.mkv"

do_delete "Chris lower quality: Nefarious (2023)" "/mnt/synology/rs-movies/Nefarious (2023)/Nefarious (2023) {tmdb-913673} - [AMZN][WEBDL-1080p][EAC3 2.0][h264]-FLUX.mkv"

do_delete "Chris lower quality: Napoleon (2023)" "/mnt/synology/rs-movies/Napoleon (2023)/Napoleon (2023) {tmdb-753342} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: American Pie Presents Girls Rules (2020)" "/mnt/synology/rs-movies/American Pie Presents Girls Rules (2020)/American Pie Presents Girls Rules (2020) {tmdb-660982} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: The Channel (2023)" "/mnt/synology/rs-movies/The Channel (2023)/The Channel (2023) {tmdb-1140692} - [WEBDL-1080p][EAC3 5.1][h264]-ETHEL.mkv"

do_delete "Chris lower quality: Fast Five (2011)" "/mnt/synology/rs-movies/Fast Five (2011)/Fast Five (2011) {tmdb-51497} - {edition-Extended} [Bluray-1080p][DTS 5.1][x264]-DON.mkv"

do_delete "Chris lower quality: Bugonia (2025)" "/mnt/synology/rs-movies/Bugonia (2025)/Bugonia (2025) {tmdb-701387} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: First Blood (1982)" "/mnt/synology/rs-movies/First Blood (1982)/First Blood (1982) {tmdb-1368} - [Bluray-1080p][AC3 5.1][x264]-HDH.mkv"

do_delete "Chris lower quality: Galaxy Quest (1999)" "/mnt/synology/rs-movies/Galaxy Quest (1999)/Galaxy Quest (1999) {tmdb-926} - [Bluray-1080p][DTS 5.1][x264]-FTW-HD.mkv"

do_delete "Chris lower quality: Baywatch (2017)" "/mnt/synology/rs-movies/Baywatch (2017)/Baywatch (2017) {tmdb-339846} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Sonic the Hedgehog 2 (2022)" "/mnt/synology/rs-movies/Sonic the Hedgehog 2 (2022)/Sonic the Hedgehog 2 (2022) {tmdb-675353} - [WEBDL-1080p][AAC 2.0][h264]-EVO.mkv"

do_delete "Chris lower quality: Trolls World Tour (2020)" "/mnt/synology/rs-movies/Trolls World Tour (2020)/Trolls World Tour (2020) {tmdb-446893} - [WEBDL-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Mission Impossible The Final Reckoning (2025)" "/mnt/synology/rs-movies/Mission Impossible The Final Reckoning (2025)/Mission Impossible The Final Reckoning (2025) {tmdb-575265} - {edition-IMAX} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-WADU.mkv"

do_delete "Chris lower quality: The Magnificent Seven (1960)" "/mnt/synology/rs-movies/The Magnificent Seven (1960)/The Magnificent Seven (1960) {tmdb-966} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv"

do_delete "Chris lower quality: Snitch (2013)" "/mnt/synology/rs-movies/Snitch (2013)/Snitch (2013) {tmdb-134411} - [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv"

do_delete "Chris lower quality: The Equalizer (2014)" "/mnt/synology/rs-movies/The Equalizer (2014)/The Equalizer (2014) {tmdb-156022} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: The Angry Birds Movie 2 (2019)" "/mnt/synology/rs-movies/The Angry Birds Movie 2 (2019)/The Angry Birds Movie 2 (2019) {tmdb-454640} - [Bluray-1080p][DTS 5.1][x264]-GECKOS.mkv"

do_delete "Chris lower quality: American Assassin (2017)" "/mnt/synology/rs-movies/American Assassin (2017)/American Assassin (2017) {tmdb-415842} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: The Last Kingdom Seven Kings Must Die (2023)" "/mnt/synology/rs-movies/The Last Kingdom Seven Kings Must Die (2023)/The Last Kingdom Seven Kings Must Die (2023) {tmdb-948713} - [NF][WEBDL-1080p][EAC3 5.1][x264]-CMRG.mkv"

do_delete "Chris lower quality: Friday the 13th (2009)" "/mnt/synology/rs-movies/Friday the 13th (2009)/Friday the 13th (2009) {tmdb-13207} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv"

do_delete "Chris lower quality: The Power of One (1992)" "/mnt/synology/rs-movies/The Power of One (1992)/The Power of One (1992) {tmdb-13823} - [WEBDL-1080p][EAC3 2.0][h264].mkv"

do_delete "Chris lower quality: Splitsville (2025)" "/mnt/synology/rs-movies/Splitsville (2025)/Splitsville (2025) {tmdb-1337562} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: The Land Before Time II The Great Valley Adventure (1994)" "/mnt/synology/rs-movies/The Land Before Time II The Great Valley Adventure (1994)/The Land Before Time II The Great Valley Adventure (1994) {tmdb-15997} - [AMZN][WEBRip-1080p][EAC3 2.0][x264]-SiGMA.mkv"

do_delete "Chris lower quality: Black Mirror Bandersnatch (2018)" "/mnt/synology/rs-movies/Black Mirror Bandersnatch (2018)/Black Mirror Bandersnatch (2018) {tmdb-569547} - [WEBDL-1080p Proper][EAC3 5.1][x264]-DEFLATE.mkv"

do_delete "Chris lower quality: Hot Tub Time Machine 2 (2015)" "/mnt/synology/rs-movies/Hot Tub Time Machine 2 (2015)/Hot Tub Time Machine 2 (2015) {tmdb-243938} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Spectre (2015)" "/mnt/synology/rs-movies/Spectre (2015)/Spectre (2015) {tmdb-206647} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Daylight (1996)" "/mnt/synology/rs-movies/Daylight (1996)/Daylight (1996) {tmdb-11228} - [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv"

do_delete "Chris lower quality: Home for the Holidays (1995)" "/mnt/synology/rs-movies/Home for the Holidays (1995)/Home for the Holidays (1995) {tmdb-9089} - [AMZN][WEBDL-1080p][EAC3 2.0][x264]-monkee.mkv"

do_delete "Chris lower quality: The Shift (2023)" "/mnt/synology/rs-movies/The Shift (2023)/The Shift (2023) {tmdb-1108658} - [Bluray-1080p][AC3 5.1][x264]-BLOW.mkv"

do_delete "Chris lower quality: Sleeping Dogs (2024)" "/mnt/synology/rs-movies/Sleeping Dogs (2024)/Sleeping Dogs (2024) {tmdb-978592} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Lilo and Stitch (2002)" "/mnt/synology/rs-movies/Lilo and Stitch (2002)/Lilo and Stitch (2002) {tmdb-11544} - [Bluray-1080p][DTS 5.1][x264]-SbR.mkv"

do_delete "Chris lower quality: The Pale Blue Eye (2022)" "/mnt/synology/rs-movies/The Pale Blue Eye (2022)/The Pale Blue Eye (2022) {tmdb-800815} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv"

do_delete "Chris lower quality: Fall (2022)" "/mnt/synology/rs-movies/Fall (2022)/Fall (2022) {tmdb-985939} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: A History of Violence (2005)" "/mnt/synology/rs-movies/A History of Violence (2005)/A History of Violence (2005) {tmdb-59} - [Bluray-1080p][DTS 5.1][x264]-MR.mkv"

do_delete "Chris lower quality: Take Cover (2024)" "/mnt/synology/rs-movies/Take Cover (2024)/Take Cover (2024) {tmdb-1094974} - [WEBDL-1080p][EAC3 5.1][h264]-BANDOLEROS.mkv"

do_delete "Chris lower quality: The Boss Baby Family Business (2021)" "/mnt/synology/rs-movies/The Boss Baby Family Business (2021)/The Boss Baby Family Business (2021) {tmdb-459151} - [PCOK][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: Miraculous Ladybug and Cat Noir The Movie (2023)" "/mnt/synology/rs-movies/Miraculous Ladybug and Cat Noir The Movie (2023)/Miraculous Ladybug and Cat Noir The Movie (2023) {tmdb-496450} - [NF][WEBDL-1080p][EAC3 5.1][DV][HEVC]-LADYBUG.mkv"

do_delete "Chris lower quality: Hook (1991)" "/mnt/synology/rs-movies/Hook (1991)/Hook (1991) {tmdb-879} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Chupa (2023)" "/mnt/synology/rs-movies/Chupa (2023)/Chupa (2023) {tmdb-736790} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv"

do_delete "Chris lower quality: The Day the Earth Stood Still (2008)" "/mnt/synology/rs-movies/The Day the Earth Stood Still (2008)/The Day the Earth Stood Still (2008) {tmdb-10200} - {edition-Open Matte} [AMZN][WEBDL-1080p][AC3 5.1][AVC].mkv"

do_delete "Chris lower quality: Pain Hustlers (2023)" "/mnt/synology/rs-movies/Pain Hustlers (2023)/Pain Hustlers (2023) {tmdb-862968} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Private Parts (1997)" "/mnt/synology/rs-movies/Private Parts (1997)/Private Parts (1997) {tmdb-9403} - [WEBDL-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Greedy People (2024)" "/mnt/synology/rs-movies/Greedy People (2024)/Greedy People (2024) {tmdb-974250} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: 57 Seconds (2023)" "/mnt/synology/rs-movies/57 Seconds (2023)/57 Seconds (2023) {tmdb-937249} - [WEBDL-1080p][EAC3 5.1][x264]-EniaHD.mkv"

do_delete "Chris lower quality: A Minecraft Movie (2025)" "/mnt/synology/rs-movies/A Minecraft Movie (2025)/A Minecraft Movie (2025) {tmdb-950387} - [WEBDL-1080p][EAC3 5.1][h264]-ETHEL.mkv"

do_delete "Chris lower quality: Hairspray (2007)" "/mnt/synology/rs-movies/Hairspray (2007)/Hairspray (2007) {tmdb-2976} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Elemental (2023)" "/mnt/synology/rs-movies/Elemental (2023)/Elemental (2023) {tmdb-976573} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Agent Game (2022)" "/mnt/synology/rs-movies/Agent Game (2022)/Agent Game (2022) {tmdb-872542} - [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: Boogie Nights (1997)" "/mnt/synology/rs-movies/Boogie Nights (1997)/Boogie Nights (1997) {tmdb-4995} - [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: Heathers (1988)" "/mnt/synology/rs-movies/Heathers (1988)/Heathers (1988) {tmdb-2640} - {edition-Remastered} [Bluray-1080p][DTS 5.1][x264]-AMIABLE.mkv"

do_delete "Chris lower quality: DC Showcase Batman Death in the Family (2020)" "/mnt/synology/rs-movies/DC Showcase Batman Death in the Family (2020)/DC Showcase Batman Death in the Family (2020) {tmdb-618353} - [Bluray-1080p][AC3 5.1][x264]-nikt0.mkv"

do_delete "Chris lower quality: Made of Honor (2008)" "/mnt/synology/rs-movies/Made of Honor (2008)/Made of Honor (2008) {tmdb-10761} - [Bluray-1080p][EAC3 5.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: Gladiator (2000)" "/mnt/synology/rs-movies/Gladiator (2000)/Gladiator (2000) {tmdb-98} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Night School (2018)" "/mnt/synology/rs-movies/Night School (2018)/Night School (2018) {tmdb-454293} - {edition-Extended Cut} [Bluray-1080p][DTS 5.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: Rampart (2011)" "/mnt/synology/rs-movies/Rampart (2011)/Rampart (2011) {tmdb-75622} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Hotel Transylvania 3 Summer Vacation (2018)" "/mnt/synology/rs-movies/Hotel Transylvania 3 Summer Vacation (2018)/Hotel Transylvania 3 Summer Vacation (2018) {tmdb-400155} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Extraction (2020)" "/mnt/synology/rs-movies/Extraction (2020)/Extraction (2020) {tmdb-545609} - [WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTG.mkv"

do_delete "Chris lower quality: Infinity Pool (2023)" "/mnt/synology/rs-movies/Infinity Pool (2023)/Infinity Pool (2023) {tmdb-667216} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: The Hunt (2020)" "/mnt/synology/rs-movies/The Hunt (2020)/The Hunt (2020) {tmdb-514847} - [Bluray-1080p][EAC3 Atmos 7.1][x264]-Rose3Thorn.mkv"

do_delete "Chris lower quality: Home Makeover (2010)" "/mnt/synology/rs-movies/Home Makeover (2010)/Home Makeover (2010) {tmdb-54553} - [Bluray-1080p][AC3 5.1][x264]-HDEX.mkv"

do_delete "Chris lower quality: Bottoms (2023)" "/mnt/synology/rs-movies/Bottoms (2023)/Bottoms (2023) {tmdb-814776} - [WEBDL-1080p][EAC3 5.1][h264]-HUZZAH.mkv"

do_delete "Chris lower quality: Lone Survivor (2013)" "/mnt/synology/rs-movies/Lone Survivor (2013)/Lone Survivor (2013) {tmdb-193756} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Concrete Utopia (2023)" "/mnt/synology/rs-movies/Concrete Utopia (2023)/Concrete Utopia (2023) {tmdb-729854} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-PSTX.mkv"

do_delete "Chris lower quality: The Mechanic (2011)" "/mnt/synology/rs-movies/The Mechanic (2011)/The Mechanic (2011) {tmdb-27582} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: The Witcher Sirens of the Deep (2025)" "/mnt/synology/rs-movies/The Witcher Sirens of the Deep (2025)/The Witcher Sirens of the Deep (2025) {tmdb-1203329} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Peter Rabbit (2018)" "/mnt/synology/rs-movies/Peter Rabbit (2018)/Peter Rabbit (2018) {tmdb-381719} - [Bluray-1080p][DTS 5.1][x264]-SbR.mkv"

do_delete "Chris lower quality: A Beautiful Day in the Neighborhood (2019)" "/mnt/synology/rs-movies/A Beautiful Day in the Neighborhood (2019)/A Beautiful Day in the Neighborhood (2019) {tmdb-501907} - [WEBDL-1080p][AC3 5.1][h264].mkv"

do_delete "Chris lower quality: The Last Dragon (1985)" "/mnt/synology/rs-movies/The Last Dragon (1985)/The Last Dragon (1985) {tmdb-13938} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv"

do_delete "Chris lower quality: Pet Sematary (1989)" "/mnt/synology/rs-movies/Pet Sematary (1989)/Pet Sematary (1989) {tmdb-8913} - [WEBDL-1080p][AAC 2.0][AV1].mkv"

do_delete "Chris lower quality: Tinker Bell (2008)" "/mnt/synology/rs-movies/Tinker Bell (2008)/Tinker Bell (2008) {tmdb-13179} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: The Devil All the Time (2020)" "/mnt/synology/rs-movies/The Devil All the Time (2020)/The Devil All the Time (2020) {tmdb-499932} - [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv"

do_delete "Chris lower quality: X (2022)" "/mnt/synology/rs-movies/X (2022)/X (2022) {tmdb-760104} - [WEBDL-1080p][EAC3 5.1][x264]-EVO.mkv"

do_delete "Chris lower quality: X2 (2003)" "/mnt/synology/rs-movies/X2 (2003)/X2 (2003) {tmdb-36658} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv"

do_delete "Chris lower quality: Minions The Rise of Gru (2022)" "/mnt/synology/rs-movies/Minions The Rise of Gru (2022)/Minions The Rise of Gru (2022) {tmdb-438148} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: The Grand Budapest Hotel (2014)" "/mnt/synology/rs-movies/The Grand Budapest Hotel (2014)/The Grand Budapest Hotel (2014) {tmdb-120467} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv"

do_delete "Chris lower quality: The Man Who Knew Too Much (1956)" "/mnt/synology/rs-movies/The Man Who Knew Too Much (1956)/The Man Who Knew Too Much (1956) {tmdb-574} - [Bluray-1080p][FLAC 2.0][x264]-TayTO.mkv"

do_delete "Chris lower quality: Cleaner (2025)" "/mnt/synology/rs-movies/Cleaner (2025)/Cleaner (2025) {tmdb-1125899} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv"

do_delete "Chris lower quality: Ricky Gervais SuperNature (2022)" "/mnt/synology/rs-movies/Ricky Gervais SuperNature (2022)/Ricky Gervais SuperNature (2022) {tmdb-973164} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-KHN.mkv"

do_delete "Chris lower quality: Dangerous Animals (2025)" "/mnt/synology/rs-movies/Dangerous Animals (2025)/Dangerous Animals (2025) {tmdb-1285965} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: Bad Boys II (2003)" "/mnt/synology/rs-movies/Bad Boys II (2003)/Bad Boys II (2003) {tmdb-8961} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv"

do_delete "Chris lower quality: Total Recall (1990)" "/mnt/synology/rs-movies/Total Recall (1990)/Total Recall (1990) {tmdb-861} - [Bluray-1080p][DTS 5.1][x264]-HiDt.mkv"

do_delete "Chris lower quality: CODA (2021)" "/mnt/synology/rs-movies/CODA (2021)/CODA (2021) {tmdb-776503} - [ATVP][WEBDL-1080p][EAC3 Atmos 5.1][HDR10][h265]-FLUX.mkv"

do_delete "Chris lower quality: High School Musical (2006)" "/mnt/synology/rs-movies/High School Musical (2006)/High School Musical (2006) {tmdb-10947} - [Bluray-1080p][DTS 5.1][x264]-FSiHD.mkv"

do_delete "Chris lower quality: Levels (2024)" "/mnt/synology/rs-movies/Levels (2024)/Levels (2024) {tmdb-791042} - [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Ratatouille (2007)" "/mnt/synology/rs-movies/Ratatouille (2007)/Ratatouille (2007) {tmdb-2062} - [Bluray-1080p Proper][DTS 5.1][x264]-hv.mkv"

do_delete "Chris lower quality: Freakier Friday (2025)" "/mnt/synology/rs-movies/Freakier Friday (2025)/Freakier Friday (2025) {tmdb-1125257} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-ETHEL.mkv"

do_delete "Chris lower quality: The Bikeriders (2024)" "/mnt/synology/rs-movies/The Bikeriders (2024)/The Bikeriders (2024) {tmdb-1008409} - [WEBDL-1080p][EAC3 5.1][h264]-VillanelleOnABike.mkv"

do_delete "Chris lower quality: The Muppets (2011)" "/mnt/synology/rs-movies/The Muppets (2011)/The Muppets (2011) {tmdb-64328} - [WEBDL-1080p][EAC3 5.1][h264]-CiNEMiX.mkv"

do_delete "Chris lower quality: Moulin Rouge! (2001)" "/mnt/synology/rs-movies/Moulin Rouge! (2001)/Moulin Rouge! (2001) {tmdb-824} - [Bluray-1080p][DTS 5.1][x264]-xander.mkv"

do_delete "Chris lower quality: Resident Evil Extinction (2007)" "/mnt/synology/rs-movies/Resident Evil Extinction (2007)/Resident Evil Extinction (2007) {tmdb-7737} - {edition-Open Matte} [WEBDL-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Downton Abbey A New Era (2022)" "/mnt/synology/rs-movies/Downton Abbey A New Era (2022)/Downton Abbey A New Era (2022) {tmdb-820446} - [Bluray-1080p][AC3 5.1][x264]-EVO.mkv"

do_delete "Chris lower quality: Maid in Manhattan (2002)" "/mnt/synology/rs-movies/Maid in Manhattan (2002)/Maid in Manhattan (2002) {tmdb-7303} - [Bluray-1080p][AC3 5.1][x264]-DON.mkv"

do_delete "Chris lower quality: The Hunt for Red October (1990)" "/mnt/synology/rs-movies/The Hunt for Red October (1990)/The Hunt for Red October (1990) {tmdb-1669} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Flash Point (2007)" "/mnt/synology/rs-movies/Flash Point (2007)/Flash Point (2007) {tmdb-35854} - [Bluray-1080p][DTS-ES 5.1][x264]-aBD.mkv"

do_delete "Chris lower quality: Oceans Thirteen (2007)" "/mnt/synology/rs-movies/Oceans Thirteen (2007)/Oceans Thirteen (2007) {tmdb-298} - [Bluray-1080p][AC3 5.1][x264]-HiDt.mkv"

do_delete "Chris lower quality: Tango and Cash (1989)" "/mnt/synology/rs-movies/Tango and Cash (1989)/Tango and Cash (1989) {tmdb-9618} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: American Hustle (2013)" "/mnt/synology/rs-movies/American Hustle (2013)/American Hustle (2013) {tmdb-168672} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv"

do_delete "Chris lower quality: 3 - 10 to Yuma (2007)" "/mnt/synology/rs-movies/3 - 10 to Yuma (2007)/3 - 10 to Yuma (2007) {tmdb-5176} - {edition-Open Matte} [AMZN MA][WEBDL-1080p][DTS-ES 5.1][AVC].mkv"

do_delete "Chris lower quality: You Me and Dupree (2006)" "/mnt/synology/rs-movies/You Me and Dupree (2006)/You Me and Dupree (2006) {tmdb-1819} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Taxi Driver (1976)" "/mnt/synology/rs-movies/Taxi Driver (1976)/Taxi Driver (1976) {tmdb-103} - [Bluray-1080p][DTS 5.1][x264]-FANDANGO.mkv"

do_delete "Chris lower quality: The Hill (2023)" "/mnt/synology/rs-movies/The Hill (2023)/The Hill (2023) {tmdb-862557} - [NF][WEBDL-1080p][EAC3 5.1][x264]-Kitsune.mkv"

do_delete "Chris lower quality: The Matrix Reloaded (2003)" "/mnt/synology/rs-movies/The Matrix Reloaded (2003)/The Matrix Reloaded (2003) {tmdb-604} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: South Park Not Suitable for Children (2023)" "/mnt/synology/rs-movies/South Park Not Suitable for Children (2023)/South Park Not Suitable for Children (2023) {tmdb-1219926} - [WEBDL-1080p][EAC3 5.1][h264]-DiMEPiECE.mkv"

do_delete "Chris lower quality: Star Trek Into Darkness (2013)" "/mnt/synology/rs-movies/Star Trek Into Darkness (2013)/Star Trek Into Darkness (2013) {tmdb-54138} - [Bluray-1080p][EAC3 7.1][HDR10][x265]-NCmt.mkv"

do_delete "Chris lower quality: 22 Jump Street (2014)" "/mnt/synology/rs-movies/22 Jump Street (2014)/22 Jump Street (2014) {tmdb-187017} - [Bluray-1080p][DTS-HD MA 5.1][x264].mkv"

do_delete "Chris lower quality: Mars Express (2023)" "/mnt/synology/rs-movies/Mars Express (2023)/Mars Express (2023) {tmdb-586810} - [WEBDL-1080p][EAC3 5.1][h264]-FW.mkv"

do_delete "Chris lower quality: Star Wars Episode II Attack of the Clones (2002)" "/mnt/synology/rs-movies/Star Wars Episode II Attack of the Clones (2002)/Star Wars Episode II Attack of the Clones (2002) {tmdb-1894} - [Bluray-1080p][EAC3 7.1][x264].mkv"

do_delete "Chris lower quality: How to Train Your Dragon The Hidden World (2019)" "/mnt/synology/rs-movies/How to Train Your Dragon The Hidden World (2019)/How to Train Your Dragon The Hidden World (2019) {tmdb-166428} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Christmas Is Canceled (2021)" "/mnt/synology/rs-movies/Christmas Is Canceled (2021)/Christmas Is Canceled (2021) {tmdb-899382} - [WEBDL-1080p][EAC3 5.1][h264]-RUMOUR.mkv"

do_delete "Chris lower quality: You Only Live Twice (1967)" "/mnt/synology/rs-movies/You Only Live Twice (1967)/You Only Live Twice (1967) {tmdb-667} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Resident Evil Afterlife (2010)" "/mnt/synology/rs-movies/Resident Evil Afterlife (2010)/Resident Evil Afterlife (2010) {tmdb-35791} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv"

do_delete "Chris lower quality: Songbird (2020)" "/mnt/synology/rs-movies/Songbird (2020)/Songbird (2020) {tmdb-721625} - [WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: Mississippi Burning (1988)" "/mnt/synology/rs-movies/Mississippi Burning (1988)/Mississippi Burning (1988) {tmdb-1632} - [Bluray-1080p][FLAC 2.0][HDR10][x265]-BRUTE.mkv"

do_delete "Chris lower quality: All We Imagine as Light (2024)" "/mnt/synology/rs-movies/All We Imagine as Light (2024)/All We Imagine as Light (2024) {tmdb-927547} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BLiNDEDBYLIGHTS.mkv"

do_delete "Chris lower quality: The Long Game (2024)" "/mnt/synology/rs-movies/The Long Game (2024)/The Long Game (2024) {tmdb-1079810} - [WEBDL-1080p][AC3 5.1][h264]-ETHEL.mkv"

do_delete "Chris lower quality: Weird The Al Yankovic Story (2022)" "/mnt/synology/rs-movies/Weird The Al Yankovic Story (2022)/Weird The Al Yankovic Story (2022) {tmdb-928344} - [WEBDL-1080p][AC3 5.1][h264]-SMURF.mkv"

do_delete "Chris lower quality: Superman IV The Quest for Peace (1987)" "/mnt/synology/rs-movies/Superman IV The Quest for Peace (1987)/Superman IV The Quest for Peace (1987) {tmdb-11411} - [WEBDL-1080p][EAC3 Atmos 5.1][x264]-GPRS.mkv"

do_delete "Chris lower quality: Ghost in the Shell (1995)" "/mnt/synology/rs-movies/Ghost in the Shell (1995)/Ghost in the Shell (1995) {tmdb-9323} - [Bluray-1080p Proper REAL][AC3 2.0][x264]-MOOVEE-001.mkv"

do_delete "Chris lower quality: Dunkirk (2017)" "/mnt/synology/rs-movies/Dunkirk (2017)/Dunkirk (2017) {tmdb-374720} - [Bluray-1080p][DTS-HD MA 5.1][x264].mkv"

do_delete "Chris lower quality: Vesper (2022)" "/mnt/synology/rs-movies/Vesper (2022)/Vesper (2022) {tmdb-976720} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-SMURF.mkv"

do_delete "Chris lower quality: Fullmetal Alchemist The Revenge of Scar (2022)" "/mnt/synology/rs-movies/Fullmetal Alchemist The Revenge of Scar (2022)/Fullmetal Alchemist The Revenge of Scar (2022) {tmdb-960700} - [NF][WEBDL-1080p][EAC3 5.1][x264]-NPMS.mkv"

do_delete "Chris lower quality: Zack Snyders Justice League (2021)" "/mnt/synology/rs-movies/Zack Snyders Justice League (2021)/Zack Snyders Justice League (2021) {tmdb-791373} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: The Lone Ranger (2013)" "/mnt/synology/rs-movies/The Lone Ranger (2013)/The Lone Ranger (2013) {tmdb-57201} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Red Right Hand (2024)" "/mnt/synology/rs-movies/Red Right Hand (2024)/Red Right Hand (2024) {tmdb-1227816} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: Superman Batman Apocalypse (2010)" "/mnt/synology/rs-movies/Superman Batman Apocalypse (2010)/Superman Batman Apocalypse (2010) {tmdb-45162} - [WEBDL-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: The Tailor of Panama (2001)" "/mnt/synology/rs-movies/The Tailor of Panama (2001)/The Tailor of Panama (2001) {tmdb-2575} - [Bluray-1080p][AC3 5.1][x264]-HDS.mkv"

do_delete "Chris lower quality: Darkman (1990)" "/mnt/synology/rs-movies/Darkman (1990)/Darkman (1990) {tmdb-9556} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: A Different Man (2024)" "/mnt/synology/rs-movies/A Different Man (2024)/A Different Man (2024) {tmdb-989662} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Army of the Dead (2021)" "/mnt/synology/rs-movies/Army of the Dead (2021)/Army of the Dead (2021) {tmdb-503736} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-MZABI.mkv"

do_delete "Chris lower quality: The 355 (2022)" "/mnt/synology/rs-movies/The 355 (2022)/The 355 (2022) {tmdb-522016} - [WEBDL-1080p][AC3 5.1][h264]-DKV.mkv"

do_delete "Chris lower quality: Operation Fortune Ruse de Guerre (2023)" "/mnt/synology/rs-movies/Operation Fortune Ruse de Guerre (2023)/Operation Fortune Ruse de Guerre (2023) {tmdb-739405} - [WEBDL-1080p][EAC3 5.1][h264]-RiGHTNOW.mkv"

do_delete "Chris lower quality: Oceans Eight (2018)" "/mnt/synology/rs-movies/Oceans Eight (2018)/Oceans Eight (2018) {tmdb-402900} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: The Surfer (2025)" "/mnt/synology/rs-movies/The Surfer (2025)/The Surfer (2025) {tmdb-1128655} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: Once Upon a Time. in Hollywood (2019)" "/mnt/synology/rs-movies/Once Upon a Time. in Hollywood (2019)/Once Upon a Time. in Hollywood (2019) {tmdb-466272} - [WEBDL-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: The Death and Return of Superman (2019)" "/mnt/synology/rs-movies/The Death and Return of Superman (2019)/The Death and Return of Superman (2019) {tmdb-630656} - [Bluray-1080p][EAC3 5.1][x264]-Itwasntme.mkv"

do_delete "Chris lower quality: Tom and Jerry (2021)" "/mnt/synology/rs-movies/Tom and Jerry (2021)/Tom and Jerry (2021) {tmdb-587807} - [HMAX][WEBDL-1080p][EAC3 Atmos 5.1][h264]-MZABI.mkv"

do_delete "Chris lower quality: The Zone of Interest (2023)" "/mnt/synology/rs-movies/The Zone of Interest (2023)/The Zone of Interest (2023) {tmdb-467244} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Mean Girls (2004)" "/mnt/synology/rs-movies/Mean Girls (2004)/Mean Girls (2004) {tmdb-10625} - [Bluray-1080p][TrueHD Atmos 7.1][x264]-KNiVES.mkv"

do_delete "Chris lower quality: Green Book (2018)" "/mnt/synology/rs-movies/Green Book (2018)/Green Book (2018) {tmdb-490132} - [Bluray-1080p][EAC3 7.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: Sebastian Maniscalco Stay Hungry (2019)" "/mnt/synology/rs-movies/Sebastian Maniscalco Stay Hungry (2019)/Sebastian Maniscalco Stay Hungry (2019) {tmdb-567525} - [NF][WEBRip-1080p][EAC3 5.1][x264]-iKA.mkv"

do_delete "Chris lower quality: Resident Evil Apocalypse (2004)" "/mnt/synology/rs-movies/Resident Evil Apocalypse (2004)/Resident Evil Apocalypse (2004) {tmdb-1577} - {edition-Theatrical Cut Open Matte} [Bluray-1080p][DTS-HD MA 5.1][x264].mkv"

do_delete "Chris lower quality: Cars 2 (2011)" "/mnt/synology/rs-movies/Cars 2 (2011)/Cars 2 (2011) {tmdb-49013} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Blue Beetle (2023)" "/mnt/synology/rs-movies/Blue Beetle (2023)/Blue Beetle (2023) {tmdb-565770} - [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Girl vs. Monster (2012)" "/mnt/synology/rs-movies/Girl vs. Monster (2012)/Girl vs. Monster (2012) {tmdb-138038} - [WEBRip-1080p][AAC 2.0][x264]-QCF.mkv"

do_delete "Chris lower quality: Ready Player One (2018)" "/mnt/synology/rs-movies/Ready Player One (2018)/Ready Player One (2018) {tmdb-333339} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: L.A. Confidential (1997)" "/mnt/synology/rs-movies/L.A. Confidential (1997)/L.A. Confidential (1997) {tmdb-2118} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Tropic Thunder (2008)" "/mnt/synology/rs-movies/Tropic Thunder (2008)/Tropic Thunder (2008) {tmdb-7446} - {edition-Uncut} [Bluray-1080p][TrueHD 5.1][x264]-BluHD.mkv"

do_delete "Chris lower quality: The Commuter (2018)" "/mnt/synology/rs-movies/The Commuter (2018)/The Commuter (2018) {tmdb-399035} - [Bluray-1080p][AC3 5.1][x264]-iLoveHD.mkv"

do_delete "Chris lower quality: Gone Baby Gone (2007)" "/mnt/synology/rs-movies/Gone Baby Gone (2007)/Gone Baby Gone (2007) {tmdb-4771} - [Bluray-1080p][EAC3 5.1][x264]-honeyvera.mkv"

do_delete "Chris lower quality: Almost Heroes (1998)" "/mnt/synology/rs-movies/Almost Heroes (1998)/Almost Heroes (1998) {tmdb-14342} - [WEBDL-1080p][AC3 5.1][x264]-ETRG.mkv"

do_delete "Chris lower quality: South Park Joining the Panderverse (2023)" "/mnt/synology/rs-movies/South Park Joining the Panderverse (2023)/South Park Joining the Panderverse (2023) {tmdb-1190012} - [AMZN][WEBDL-1080p Proper][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Hotel Transylvania (2012)" "/mnt/synology/rs-movies/Hotel Transylvania (2012)/Hotel Transylvania (2012) {tmdb-76492} - [HDTV-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Bad Boys for Life (2020)" "/mnt/synology/rs-movies/Bad Boys for Life (2020)/Bad Boys for Life (2020) {tmdb-38700} - [WEBDL-1080p][AC3 5.1][h264].mkv"

do_delete "Chris lower quality: Terminator 2 Judgment Day (1991)" "/mnt/synology/rs-movies/Terminator 2 Judgment Day (1991)/Terminator 2 Judgment Day (1991) {tmdb-280} - {edition-Directors Cut} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: Aliens vs Predator Requiem (2007)" "/mnt/synology/rs-movies/Aliens vs Predator Requiem (2007)/Aliens vs Predator Requiem (2007) {tmdb-440} - {edition-Theatrical} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-EMb.mkv"

do_delete "Chris lower quality: Money Plane (2020)" "/mnt/synology/rs-movies/Money Plane (2020)/Money Plane (2020) {tmdb-694919} - [WEBDL-1080p][AC3 5.1][h264].mkv"

do_delete "Chris lower quality: Drive-Away Dolls (2024)" "/mnt/synology/rs-movies/Drive-Away Dolls (2024)/Drive-Away Dolls (2024) {tmdb-957304} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-ShowMeOnTheDollWhereHeTouchedYou.mkv"

do_delete "Chris lower quality: The BFG (2016)" "/mnt/synology/rs-movies/The BFG (2016)/The BFG (2016) {tmdb-267935} - [Bluray-1080p][AC3 5.1][x264]-DON.mkv"

do_delete "Chris lower quality: Cashback (2007)" "/mnt/synology/rs-movies/Cashback (2007)/Cashback (2007) {tmdb-12225} - [Bluray-1080p][DTS 5.1][x264]-CRiSC.mkv"

do_delete "Chris lower quality: Pontypool (2009)" "/mnt/synology/rs-movies/Pontypool (2009)/Pontypool (2009) {tmdb-23963} - [Bluray-1080p][DTS 5.1][x264]-thugline.mkv"

do_delete "Chris lower quality: Goosebumps 2 Haunted Halloween (2018)" "/mnt/synology/rs-movies/Goosebumps 2 Haunted Halloween (2018)/Goosebumps 2 Haunted Halloween (2018) {tmdb-442062} - [Bluray-1080p][AC3 5.1][x264]-VietHD.mkv"

do_delete "Chris lower quality: Harry Potter and the Half-Blood Prince (2009)" "/mnt/synology/rs-movies/Harry Potter and the Half-Blood Prince (2009)/Harry Potter and the Half-Blood Prince (2009) {tmdb-767} - [Bluray-1080p][DTS 5.1][x264]-HiDt.mkv"

do_delete "Chris lower quality: Hot Shots! (1991)" "/mnt/synology/rs-movies/Hot Shots! (1991)/Hot Shots! (1991) {tmdb-9595} - [Bluray-1080p][DTS 5.1][x264]-AMIABLE.mkv"

do_delete "Chris lower quality: F1 (2025)" "/mnt/synology/rs-movies/F1 (2025)/F1 (2025) {tmdb-911430} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: The Dark Knight (2008)" "/mnt/synology/rs-movies/The Dark Knight (2008)/The Dark Knight (2008) {tmdb-155} - {edition-IMAX} [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv"

do_delete "Chris lower quality: The Abyss (1989)" "/mnt/synology/rs-movies/The Abyss (1989)/The Abyss (1989) {tmdb-2756} - [WEBDL-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: The Kingdom (2007)" "/mnt/synology/rs-movies/The Kingdom (2007)/The Kingdom (2007) {tmdb-4349} - {edition-Open Matte} [WEBDL-1080p][DTS-HD MA 5.1][h264].mkv"

do_delete "Chris lower quality: Fast and Furious Presents Hobbs and Shaw (2019)" "/mnt/synology/rs-movies/Fast and Furious Presents Hobbs and Shaw (2019)/Fast and Furious Presents Hobbs and Shaw (2019) {tmdb-384018} - [WEBDL-1080p][AC3 2.0][h264].mkv"

do_delete "Chris lower quality: The Fix (2024)" "/mnt/synology/rs-movies/The Fix (2024)/The Fix (2024) {tmdb-931940} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: Beauty and the Beast (2017)" "/mnt/synology/rs-movies/Beauty and the Beast (2017)/Beauty and the Beast (2017) {tmdb-321612} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: This Place Rules (2022)" "/mnt/synology/rs-movies/This Place Rules (2022)/This Place Rules (2022) {tmdb-1024433} - [WEBDL-1080p][EAC3 5.1][x264]-Muffin.mkv"

do_delete "Chris lower quality: The Mummy Returns (2001)" "/mnt/synology/rs-movies/The Mummy Returns (2001)/The Mummy Returns (2001) {tmdb-1734} - [Bluray-1080p][EAC3 7.1][x264].mkv"

do_delete "Chris lower quality: The Portable Door (2023)" "/mnt/synology/rs-movies/The Portable Door (2023)/The Portable Door (2023) {tmdb-830896} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: The Aviator (2004)" "/mnt/synology/rs-movies/The Aviator (2004)/The Aviator (2004) {tmdb-2567} - [AMZN][WEBDL-1080p][DTS 5.1][h264].mkv"

do_delete "Chris lower quality: North by Northwest (1959)" "/mnt/synology/rs-movies/North by Northwest (1959)/North by Northwest (1959) {tmdb-213} - [Bluray-1080p][AC3 5.1][x264]-EbP.mkv"

do_delete "Chris lower quality: Slingshot (2024)" "/mnt/synology/rs-movies/Slingshot (2024)/Slingshot (2024) {tmdb-916728} - [WEBDL-1080p][EAC3 5.1][h264]-NeatPristineCoyoteOfAssurance.mkv"

do_delete "Chris lower quality: Max Steel (2016)" "/mnt/synology/rs-movies/Max Steel (2016)/Max Steel (2016) {tmdb-286567} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: V H S Beyond (2024)" "/mnt/synology/rs-movies/V H S Beyond (2024)/V H S Beyond (2024) {tmdb-1190868} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Godzilla x Kong The New Empire (2024)" "/mnt/synology/rs-movies/Godzilla x Kong The New Empire (2024)/Godzilla x Kong The New Empire (2024) {tmdb-823464} - [AMZN][WEBDL-1080p Proper][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Night Hunter (2019)" "/mnt/synology/rs-movies/Night Hunter (2019)/Night Hunter (2019) {tmdb-441282} - [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: Vantage Point (2008)" "/mnt/synology/rs-movies/Vantage Point (2008)/Vantage Point (2008) {tmdb-7461} - [AMZN][WEBDL-1080p][EAC3 5.1][x264].mkv"

do_delete "Chris lower quality: TRON Ares (2025)" "/mnt/synology/rs-movies/TRON Ares (2025)/TRON Ares (2025) {tmdb-533533} - [WEBDL-1080p Proper][EAC3 Atmos 5.1][x264]-BANDOLEROS.mkv"

do_delete "Chris lower quality: We Were Soldiers (2002)" "/mnt/synology/rs-movies/We Were Soldiers (2002)/We Were Soldiers (2002) {tmdb-10590} - [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: Apollo 13 (1995)" "/mnt/synology/rs-movies/Apollo 13 (1995)/Apollo 13 (1995) {tmdb-568} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: In the Line of Fire (1993)" "/mnt/synology/rs-movies/In the Line of Fire (1993)/In the Line of Fire (1993) {tmdb-9386} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: King Arthur (2004)" "/mnt/synology/rs-movies/King Arthur (2004)/King Arthur (2004) {tmdb-9477} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: The Call of the Wild (2020)" "/mnt/synology/rs-movies/The Call of the Wild (2020)/The Call of the Wild (2020) {tmdb-481848} - [WEBDL-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: The Legend of Tarzan (2016)" "/mnt/synology/rs-movies/The Legend of Tarzan (2016)/The Legend of Tarzan (2016) {tmdb-258489} - [Bluray-1080p][EAC3 7.1][DV HDR10][x265]-W4NK3R.mkv"

do_delete "Chris lower quality: How to Have Sex (2023)" "/mnt/synology/rs-movies/How to Have Sex (2023)/How to Have Sex (2023) {tmdb-1075175} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Resurrection (2022)" "/mnt/synology/rs-movies/Resurrection (2022)/Resurrection (2022) {tmdb-872497} - [WEBDL-1080p][AC3 5.1][h264].mkv"

do_delete "Chris lower quality: Van Helsing (2004)" "/mnt/synology/rs-movies/Van Helsing (2004)/Van Helsing (2004) {tmdb-7131} - [Bluray-1080p][AC3 5.1][x264]-nikt0.mkv"

do_delete "Chris lower quality: Sister Act 2 Back in the Habit (1993)" "/mnt/synology/rs-movies/Sister Act 2 Back in the Habit (1993)/Sister Act 2 Back in the Habit (1993) {tmdb-6279} - [Bluray-1080p][AC3 5.1][x264]-CiNEFiLE.mkv"

do_delete "Chris lower quality: The Blob (1958)" "/mnt/synology/rs-movies/The Blob (1958)/The Blob (1958) {tmdb-8851} - [WEBDL-1080p][EAC3 2.0][x264]-GPRS.mkv"

do_delete "Chris lower quality: Bubba Ho-tep (2002)" "/mnt/synology/rs-movies/Bubba Ho-tep (2002)/Bubba Ho-tep (2002) {tmdb-9707} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: Mad Max Fury Road (2015)" "/mnt/synology/rs-movies/Mad Max Fury Road (2015)/Mad Max Fury Road (2015) {tmdb-76341} - [Bluray-1080p][EAC3 7.1][HDR10][x265]-D-Z0N3.mkv"

do_delete "Chris lower quality: Blade (1998)" "/mnt/synology/rs-movies/Blade (1998)/Blade (1998) {tmdb-36647} - [Bluray-1080p][DTS-ES 6.1][x264]-Z0N3.mkv"

do_delete "Chris lower quality: Meet Dave (2008)" "/mnt/synology/rs-movies/Meet Dave (2008)/Meet Dave (2008) {tmdb-11260} - [NF][WEBDL-1080p][EAC3 5.1][x264]-NINJACENTRAL.mkv"

do_delete "Chris lower quality: The Phoenician Scheme (2025)" "/mnt/synology/rs-movies/The Phoenician Scheme (2025)/The Phoenician Scheme (2025) {tmdb-1137350} - [WEBDL-1080p][EAC3 Atmos 5.1][x264]-HONE.mkv"

do_delete "Chris lower quality: Flubber (1997)" "/mnt/synology/rs-movies/Flubber (1997)/Flubber (1997) {tmdb-9574} - [WEBRip-1080p][EAC3 5.1][x264]-NTb.mkv"

do_delete "Chris lower quality: Skyfall (2012)" "/mnt/synology/rs-movies/Skyfall (2012)/Skyfall (2012) {tmdb-37724} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Narvik (2022)" "/mnt/synology/rs-movies/Narvik (2022)/Narvik (2022) {tmdb-619930} - [NF][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Malcolm X (1992)" "/mnt/synology/rs-movies/Malcolm X (1992)/Malcolm X (1992) {tmdb-1883} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Chameleon Street (1991)" "/mnt/synology/rs-movies/Chameleon Street (1991)/Chameleon Street (1991) {tmdb-102831} - [WEBDL-1080p][AAC 2.0][x264]-KUCHU.mkv"

do_delete "Chris lower quality: Dragon The Bruce Lee Story (1993)" "/mnt/synology/rs-movies/Dragon The Bruce Lee Story (1993)/Dragon The Bruce Lee Story (1993) {tmdb-10423} - [Bluray-1080p][DTS 5.1][x264]-AIRLINE.mkv"

do_delete "Chris lower quality: Santa Claus Is Comin to Town (1970)" "/mnt/synology/rs-movies/Santa Claus Is Comin to Town (1970)/Santa Claus Is Comin to Town (1970) {tmdb-13400} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Second Act (2018)" "/mnt/synology/rs-movies/Second Act (2018)/Second Act (2018) {tmdb-503616} - [Bluray-1080p][AC3 5.1][x264]-DON.mkv"

do_delete "Chris lower quality: Warrior (2011)" "/mnt/synology/rs-movies/Warrior (2011)/Warrior (2011) {tmdb-59440} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Baghead (2023)" "/mnt/synology/rs-movies/Baghead (2023)/Baghead (2023) {tmdb-845783} - [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Better Off Dead. (1985)" "/mnt/synology/rs-movies/Better Off Dead. (1985)/Better Off Dead. (1985) {tmdb-13667} - [Bluray-1080p][DTS 5.1][x264]-mintHD.mkv"

do_delete "Chris lower quality: The Chronicles of Riddick (2004)" "/mnt/synology/rs-movies/The Chronicles of Riddick (2004)/The Chronicles of Riddick (2004) {tmdb-2789} - {edition-Director's Cut} [Bluray-1080p][DTS 5.1][x264]-DON.mkv"

do_delete "Chris lower quality: Risky Business (1983)" "/mnt/synology/rs-movies/Risky Business (1983)/Risky Business (1983) {tmdb-9346} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Star Trek Generations (1994)" "/mnt/synology/rs-movies/Star Trek Generations (1994)/Star Trek Generations (1994) {tmdb-193} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv"

do_delete "Chris lower quality: Thanksgiving (2023)" "/mnt/synology/rs-movies/Thanksgiving (2023)/Thanksgiving (2023) {tmdb-1071215} - [WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Never Say Never Again (1983)" "/mnt/synology/rs-movies/Never Say Never Again (1983)/Never Say Never Again (1983) {tmdb-36670} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Locked (2025)" "/mnt/synology/rs-movies/Locked (2025)/Locked (2025) {tmdb-1083968} - [WEBRip-1080p][AAC 5.1][x264]-LAMA.mp4"

do_delete "Chris lower quality: How to Build a Girl (2020)" "/mnt/synology/rs-movies/How to Build a Girl (2020)/How to Build a Girl (2020) {tmdb-572299} - [WEBDL-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Night of the Hunted (2023)" "/mnt/synology/rs-movies/Night of the Hunted (2023)/Night of the Hunted (2023) {tmdb-1160003} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: The Humanity Bureau (2017)" "/mnt/synology/rs-movies/The Humanity Bureau (2017)/The Humanity Bureau (2017) {tmdb-456048} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv"

do_delete "Chris lower quality: The Lego Batman Movie (2017)" "/mnt/synology/rs-movies/The Lego Batman Movie (2017)/The Lego Batman Movie (2017) {tmdb-324849} - [WEBDL-1080p][AC3 5.1][h264]-MiDWEEK.mp4"

do_delete "Chris lower quality: Deep Impact (1998)" "/mnt/synology/rs-movies/Deep Impact (1998)/Deep Impact (1998) {tmdb-8656} - [WEBDL-1080p][DTS 5.1][h264].mkv"

do_delete "Chris lower quality: Alice (2022)" "/mnt/synology/rs-movies/Alice (2022)/Alice (2022) {tmdb-714676} - [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Glass Onion A Knives Out Mystery (2022)" "/mnt/synology/rs-movies/Glass Onion A Knives Out Mystery (2022)/Glass Onion A Knives Out Mystery (2022) {tmdb-661374} - [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv"

do_delete "Chris lower quality: Handling the Undead (2024)" "/mnt/synology/rs-movies/Handling the Undead (2024)/Handling the Undead (2024) {tmdb-1020896} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Around the World in 80 Days (2004)" "/mnt/synology/rs-movies/Around the World in 80 Days (2004)/Around the World in 80 Days (2004) {tmdb-10204} - {edition-Open Matte} [WEBDL-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Office Christmas Party (2016)" "/mnt/synology/rs-movies/Office Christmas Party (2016)/Office Christmas Party (2016) {tmdb-384682} - {edition-Unrated} [Bluray-1080p][DTS 5.1][x264]-KASHMiR.mkv"

do_delete "Chris lower quality: The Matrix Resurrections (2021)" "/mnt/synology/rs-movies/The Matrix Resurrections (2021)/The Matrix Resurrections (2021) {tmdb-624860} - [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv"

do_delete "Chris lower quality: American Pie Presents Beta House (2007)" "/mnt/synology/rs-movies/American Pie Presents Beta House (2007)/American Pie Presents Beta House (2007) {tmdb-8277} - {edition-Unrated} [WEBRip-1080p][EAC3 5.1][x264]-KiNGS.mkv"

do_delete "Chris lower quality: The Texas Chainsaw Massacre (2003)" "/mnt/synology/rs-movies/The Texas Chainsaw Massacre (2003)/The Texas Chainsaw Massacre (2003) {tmdb-9373} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Pig (2021)" "/mnt/synology/rs-movies/Pig (2021)/Pig (2021) {tmdb-635731} - [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: West Side Story (1961)" "/mnt/synology/rs-movies/West Side Story (1961)/West Side Story (1961) {tmdb-1725} - [WEBDL-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Worlds Greatest Dad (2009)" "/mnt/synology/rs-movies/Worlds Greatest Dad (2009)/Worlds Greatest Dad (2009) {tmdb-20178} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Arrival (2016)" "/mnt/synology/rs-movies/Arrival (2016)/Arrival (2016) {tmdb-329865} - [HDTV-1080p][AC3 5.1][h264].mkv"

do_delete "Chris lower quality: Black Panther (2018)" "/mnt/synology/rs-movies/Black Panther (2018)/Black Panther (2018) {tmdb-284054} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Batman v Superman Dawn of Justice (2016)" "/mnt/synology/rs-movies/Batman v Superman Dawn of Justice (2016)/Batman v Superman Dawn of Justice (2016) {tmdb-209112} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Gremlins (1984)" "/mnt/synology/rs-movies/Gremlins (1984)/Gremlins (1984) {tmdb-927} - [Bluray-1080p][EAC3 5.1][HDR10][x265]-JM.mkv"

do_delete "Chris lower quality: Over the Moon (2020)" "/mnt/synology/rs-movies/Over the Moon (2020)/Over the Moon (2020) {tmdb-560050} - [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv"

do_delete "Chris lower quality: Champions (2023)" "/mnt/synology/rs-movies/Champions (2023)/Champions (2023) {tmdb-933419} - [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Charlottes Web (2006)" "/mnt/synology/rs-movies/Charlottes Web (2006)/Charlottes Web (2006) {tmdb-9986} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Beetlejuice Beetlejuice (2024)" "/mnt/synology/rs-movies/Beetlejuice Beetlejuice (2024)/Beetlejuice Beetlejuice (2024) {tmdb-917496} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Halloween II (1981)" "/mnt/synology/rs-movies/Halloween II (1981)/Halloween II (1981) {tmdb-11281} - [Bluray-1080p][EAC3 7.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: Jawan (2023)" "/mnt/synology/rs-movies/Jawan (2023)/Jawan (2023) {tmdb-872906} - {edition-Extended Cut} [NF][WEBDL-1080p][EAC3 5.1][x264]-KiNGKHAN.mkv"

do_delete "Chris lower quality: Dog Man (2025)" "/mnt/synology/rs-movies/Dog Man (2025)/Dog Man (2025) {tmdb-774370} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-APEX.mkv"

do_delete "Chris lower quality: Shelter (2014)" "/mnt/synology/rs-movies/Shelter (2014)/Shelter (2014) {tmdb-287426} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv"

do_delete "Chris lower quality: Guardians of the Galaxy (2014)" "/mnt/synology/rs-movies/Guardians of the Galaxy (2014)/Guardians of the Galaxy (2014) {tmdb-118340} - [Bluray-1080p][EAC3 7.1][HDR10][x265]-NCmt.mkv"

do_delete "Chris lower quality: Inception (2010)" "/mnt/synology/rs-movies/Inception (2010)/Inception (2010) {tmdb-27205} - [Bluray-1080p][DTS 5.1][HDR10][x265]-D-Z0N3.mkv"

do_delete "Chris lower quality: Suicide Squad (2016)" "/mnt/synology/rs-movies/Suicide Squad (2016)/Suicide Squad (2016) {tmdb-297761} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Vacation Friends 2 (2023)" "/mnt/synology/rs-movies/Vacation Friends 2 (2023)/Vacation Friends 2 (2023) {tmdb-869641} - [Hulu][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Churchill (2017)" "/mnt/synology/rs-movies/Churchill (2017)/Churchill (2017) {tmdb-399790} - [Bluray-1080p][AC3 5.1][x264]-DON.mkv"

do_delete "Chris lower quality: Starman (1984)" "/mnt/synology/rs-movies/Starman (1984)/Starman (1984) {tmdb-9663} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Monsters Ball (2001)" "/mnt/synology/rs-movies/Monsters Ball (2001)/Monsters Ball (2001) {tmdb-1365} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Run All Night (2015)" "/mnt/synology/rs-movies/Run All Night (2015)/Run All Night (2015) {tmdb-241554} - [Bluray-1080p][AC3 5.1][x264]-HDMaNiAcS.mkv"

do_delete "Chris lower quality: Aladdin (1992)" "/mnt/synology/rs-movies/Aladdin (1992)/Aladdin (1992) {tmdb-812} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: The Rescuers (1977)" "/mnt/synology/rs-movies/The Rescuers (1977)/The Rescuers (1977) {tmdb-11319} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Twilight of the Warriors Walled In (2024)" "/mnt/synology/rs-movies/Twilight of the Warriors Walled In (2024)/Twilight of the Warriors Walled In (2024) {tmdb-923667} - [WEBDL-1080p][EAC3 5.1][h264]-HDSWEB.mkv"

do_delete "Chris lower quality: The Beekeeper (2024)" "/mnt/synology/rs-movies/The Beekeeper (2024)/The Beekeeper (2024) {tmdb-866398} - [WEBDL-1080p][EAC3 5.1][h264]-LilKim.mkv"

do_delete "Chris lower quality: Gunpowder Milkshake (2021)" "/mnt/synology/rs-movies/Gunpowder Milkshake (2021)/Gunpowder Milkshake (2021) {tmdb-574060} - [Bluray-1080p][EAC3 5.1][x264]-TayTO.mkv"

do_delete "Chris lower quality: Airplane! (1980)" "/mnt/synology/rs-movies/Airplane! (1980)/Airplane! (1980) {tmdb-813} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Here Comes the Boom (2012)" "/mnt/synology/rs-movies/Here Comes the Boom (2012)/Here Comes the Boom (2012) {tmdb-87826} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Sinners (2025)" "/mnt/synology/rs-movies/Sinners (2025)/Sinners (2025) {tmdb-1233413} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: Star Trek Section 31 (2025)" "/mnt/synology/rs-movies/Star Trek Section 31 (2025)/Star Trek Section 31 (2025) {tmdb-1114894} - [WEBDL-1080p][EAC3 5.1][h264]-AccomplishedYak.mkv"

do_delete "Chris lower quality: Doctor Strange in the Multiverse of Madness (2022)" "/mnt/synology/rs-movies/Doctor Strange in the Multiverse of Madness (2022)/Doctor Strange in the Multiverse of Madness (2022) {tmdb-453395} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: Lost Highway (1997)" "/mnt/synology/rs-movies/Lost Highway (1997)/Lost Highway (1997) {tmdb-638} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Trolls Holiday in Harmony (2021)" "/mnt/synology/rs-movies/Trolls Holiday in Harmony (2021)/Trolls Holiday in Harmony (2021) {tmdb-896221} - [WEBDL-1080p][AAC 2.0][x264]-DiRT.mkv"

do_delete "Chris lower quality: Silent Night (2023)" "/mnt/synology/rs-movies/Silent Night (2023)/Silent Night (2023) {tmdb-891699} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Lucky Number Slevin (2006)" "/mnt/synology/rs-movies/Lucky Number Slevin (2006)/Lucky Number Slevin (2006) {tmdb-186} - [Bluray-1080p][DTS 5.1][x264]-HiDt.mkv"

do_delete "Chris lower quality: Ride Along 2 (2016)" "/mnt/synology/rs-movies/Ride Along 2 (2016)/Ride Along 2 (2016) {tmdb-323675} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Shut In (2022)" "/mnt/synology/rs-movies/Shut In (2022)/Shut In (2022) {tmdb-629015} - [WEBDL-1080p][AAC 2.0][h264]-EVO.mkv"

do_delete "Chris lower quality: Aquaman (2018)" "/mnt/synology/rs-movies/Aquaman (2018)/Aquaman (2018) {tmdb-297802} - [WEBDL-1080p][AC3 5.1][h264].mkv"

do_delete "Chris lower quality: Holes (2003)" "/mnt/synology/rs-movies/Holes (2003)/Holes (2003) {tmdb-8326} - [Bluray-1080p][DTS 5.1][x264]-AMIABLE.mkv"

do_delete "Chris lower quality: The Jackal (1997)" "/mnt/synology/rs-movies/The Jackal (1997)/The Jackal (1997) {tmdb-4824} - [Bluray-1080p][DTS 5.1][x264]-HiDt.mkv"

do_delete "Chris lower quality: Horton Hears a Who! (2008)" "/mnt/synology/rs-movies/Horton Hears a Who! (2008)/Horton Hears a Who! (2008) {tmdb-12222} - [Bluray-1080p][DTS 5.1][x264]-ESiR.mkv"

do_delete "Chris lower quality: Delicatessen (1991)" "/mnt/synology/rs-movies/Delicatessen (1991)/Delicatessen (1991) {tmdb-892} - [Bluray-1080p][FLAC 2.0][x264]-Skazhutin.mkv"

do_delete "Chris lower quality: The Last Sharknado Its About Time (2018)" "/mnt/synology/rs-movies/The Last Sharknado Its About Time (2018)/The Last Sharknado Its About Time (2018) {tmdb-523849} - [Bluray-1080p][DTS 5.1][x264]-GETiT.mkv"

do_delete "Chris lower quality: Witness (1985)" "/mnt/synology/rs-movies/Witness (1985)/Witness (1985) {tmdb-9281} - [Bluray-1080p][AC3 5.1][x264]-EbP.mkv"

do_delete "Chris lower quality: Nickel Boys (2024)" "/mnt/synology/rs-movies/Nickel Boys (2024)/Nickel Boys (2024) {tmdb-1028196} - [AMZN][WEBDL-1080p][EAC3 5.1][x264].mkv"

do_delete "Chris lower quality: It Ends with Us (2024)" "/mnt/synology/rs-movies/It Ends with Us (2024)/It Ends with Us (2024) {tmdb-1079091} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Pan (2015)" "/mnt/synology/rs-movies/Pan (2015)/Pan (2015) {tmdb-266647} - [Bluray-1080p][AC3 5.1][x264]-TayTO.mkv"

do_delete "Chris lower quality: The Land Before Time (1988)" "/mnt/synology/rs-movies/The Land Before Time (1988)/The Land Before Time (1988) {tmdb-12144} - [WEBDL-1080p][AAC 2.0][h264]-PiTBULL.mkv"

do_delete "Chris lower quality: Invictus (2009)" "/mnt/synology/rs-movies/Invictus (2009)/Invictus (2009) {tmdb-22954} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Bones and All (2022)" "/mnt/synology/rs-movies/Bones and All (2022)/Bones and All (2022) {tmdb-791177} - [Bluray-1080p][EAC3 Atmos 7.1][x264]-PTer.mkv"

do_delete "Chris lower quality: Woman in Gold (2015)" "/mnt/synology/rs-movies/Woman in Gold (2015)/Woman in Gold (2015) {tmdb-304357} - [Bluray-1080p][AC3 5.1][x264]-DON.mkv"

do_delete "Chris lower quality: Ill Be Home for Christmas (1998)" "/mnt/synology/rs-movies/Ill Be Home for Christmas (1998)/Ill Be Home for Christmas (1998) {tmdb-17037} - [Bluray-1080p][DTS 5.1][x264]-SNOW.mkv"

do_delete "Chris lower quality: The Florida Project (2017)" "/mnt/synology/rs-movies/The Florida Project (2017)/The Florida Project (2017) {tmdb-394117} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Last Breath (2025)" "/mnt/synology/rs-movies/Last Breath (2025)/Last Breath (2025) {tmdb-972533} - [MA][WEBDL-1080p Proper][EAC3 Atmos 5.1][x264]-BYNDR.mkv"

do_delete "Chris lower quality: Widows (2018)" "/mnt/synology/rs-movies/Widows (2018)/Widows (2018) {tmdb-401469} - [Bluray-1080p][EAC3 5.1][x264].mkv"

do_delete "Chris lower quality: The Lion King (1994)" "/mnt/synology/rs-movies/The Lion King (1994)/The Lion King (1994) {tmdb-8587} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Dangerous Waters (2023)" "/mnt/synology/rs-movies/Dangerous Waters (2023)/Dangerous Waters (2023) {tmdb-980285} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Saw III (2006)" "/mnt/synology/rs-movies/Saw III (2006)/Saw III (2006) {tmdb-214} - [Bluray-1080p][DTS-ES 6.1][x264]-HDMaNiAcS.mkv"

do_delete "Chris lower quality: Fatherhood (2021)" "/mnt/synology/rs-movies/Fatherhood (2021)/Fatherhood (2021) {tmdb-607259} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-EVO.mkv"

do_delete "Chris lower quality: Harry Potter and the Philosophers Stone (2001)" "/mnt/synology/rs-movies/Harry Potter and the Philosophers Stone (2001)/Harry Potter and the Philosophers Stone (2001) {tmdb-671} - {edition-Extended Cut} [Bluray-1080p][DTS 5.1][x264]-NTb.mkv"

do_delete "Chris lower quality: Cheeky (2000)" "/mnt/synology/rs-movies/Cheeky (2000)/Cheeky (2000) {tmdb-22705} - [Bluray-1080p][AC3 2.0][x264]-HDMaNiAcS.mkv"

do_delete "Chris lower quality: Radical (2023)" "/mnt/synology/rs-movies/Radical (2023)/Radical (2023) {tmdb-1058694} - [WEBDL-1080p][EAC3 2.0][h264]-PSTX.mkv"

do_delete "Chris lower quality: Kill Bill Vol. 1 (2003)" "/mnt/synology/rs-movies/Kill Bill Vol. 1 (2003)/Kill Bill Vol. 1 (2003) {tmdb-24} - [Bluray-1080p][PCM 6.0][x264]-TABULARiA.mkv"

do_delete "Chris lower quality: The Breakfast Club (1985)" "/mnt/synology/rs-movies/The Breakfast Club (1985)/The Breakfast Club (1985) {tmdb-2108} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Subservience (2024)" "/mnt/synology/rs-movies/Subservience (2024)/Subservience (2024) {tmdb-1064028} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: One Ranger (2023)" "/mnt/synology/rs-movies/One Ranger (2023)/One Ranger (2023) {tmdb-1093994} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Little Dixie (2023)" "/mnt/synology/rs-movies/Little Dixie (2023)/Little Dixie (2023) {tmdb-1058949} - [WEBRip-1080p][AAC 5.1][x264]-AOC.mkv"

do_delete "Chris lower quality: Raya and the Last Dragon (2021)" "/mnt/synology/rs-movies/Raya and the Last Dragon (2021)/Raya and the Last Dragon (2021) {tmdb-527774} - [DSNP][WEBDL-1080p][EAC3 5.1][h264]-TOMMY.mkv"

do_delete "Chris lower quality: Black Widow (2021)" "/mnt/synology/rs-movies/Black Widow (2021)/Black Widow (2021) {tmdb-497698} - [DSNP][WEBDL-1080p][EAC3 Atmos 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Uncharted (2022)" "/mnt/synology/rs-movies/Uncharted (2022)/Uncharted (2022) {tmdb-335787} - [WEBDL-1080p][EAC3 5.1][x264]-EVO.mkv"

do_delete "Chris lower quality: Saving Private Ryan (1998)" "/mnt/synology/rs-movies/Saving Private Ryan (1998)/Saving Private Ryan (1998) {tmdb-857} - [Bluray-1080p][EAC3 7.1][HDR10][x265]-NCmt.mkv"

do_delete "Chris lower quality: Lost in the Stars (2023)" "/mnt/synology/rs-movies/Lost in the Stars (2023)/Lost in the Stars (2023) {tmdb-1108211} - [WEBDL-1080p][MP3 2.0][h264]-OurTV.mp4"

do_delete "Chris lower quality: I See You (2019)" "/mnt/synology/rs-movies/I See You (2019)/I See You (2019) {tmdb-524251} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv"

do_delete "Chris lower quality: Apocalypse Now (1979)" "/mnt/synology/rs-movies/Apocalypse Now (1979)/Apocalypse Now (1979) {tmdb-28} - {edition-Theatrical Cut} [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv"

do_delete "Chris lower quality: Justice League vs. Teen Titans (2016)" "/mnt/synology/rs-movies/Justice League vs. Teen Titans (2016)/Justice League vs. Teen Titans (2016) {tmdb-379291} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Pacific Rim Uprising (2018)" "/mnt/synology/rs-movies/Pacific Rim Uprising (2018)/Pacific Rim Uprising (2018) {tmdb-268896} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Zombeavers (2014)" "/mnt/synology/rs-movies/Zombeavers (2014)/Zombeavers (2014) {tmdb-254474} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv"

do_delete "Chris lower quality: Gone with the Wind (1939)" "/mnt/synology/rs-movies/Gone with the Wind (1939)/Gone with the Wind (1939) {tmdb-770} - [Bluray-1080p][AC3 5.1][x264]-EbP.mkv"

do_delete "Chris lower quality: The Siege (1998)" "/mnt/synology/rs-movies/The Siege (1998)/The Siege (1998) {tmdb-9882} - [Bluray-1080p][DTS 5.1][x264]-HiDt.mkv"

do_delete "Chris lower quality: White Chicks (2004)" "/mnt/synology/rs-movies/White Chicks (2004)/White Chicks (2004) {tmdb-12153} - {edition-Unrated} [NF][WEBDL-1080p][AC3 5.1][x264]-monkee.mkv"

do_delete "Chris lower quality: Anthony Jeselnik Thoughts and Prayers (2015)" "/mnt/synology/rs-movies/Anthony Jeselnik Thoughts and Prayers (2015)/Anthony Jeselnik Thoughts and Prayers (2015) {tmdb-364089} - [NF][WEBRip-1080p][AC3 5.1][x264]-monkee.mkv"

do_delete "Chris lower quality: Billy Madison (1995)" "/mnt/synology/rs-movies/Billy Madison (1995)/Billy Madison (1995) {tmdb-11017} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: Candyman (2021)" "/mnt/synology/rs-movies/Candyman (2021)/Candyman (2021) {tmdb-565028} - [Bluray-1080p][EAC3 7.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: A Family Affair (2024)" "/mnt/synology/rs-movies/A Family Affair (2024)/A Family Affair (2024) {tmdb-987686} - [WEBDL-1080p][EAC3 5.1][x264]-ETHEL.mkv"

do_delete "Chris lower quality: Sometimes I Think About Dying (2024)" "/mnt/synology/rs-movies/Sometimes I Think About Dying (2024)/Sometimes I Think About Dying (2024) {tmdb-891933} - [AMZN][WEBDL-1080p][EAC3 2.0][h264]-FLUX.mkv"

do_delete "Chris lower quality: Hotel Chevalier (2007)" "/mnt/synology/rs-movies/Hotel Chevalier (2007)/Hotel Chevalier (2007) {tmdb-6418} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Hercules (1997)" "/mnt/synology/rs-movies/Hercules (1997)/Hercules (1997) {tmdb-11970} - [Bluray-1080p][DTS 5.1][x264]-AMIABLE.mkv"

do_delete "Chris lower quality: Spirit Untamed (2021)" "/mnt/synology/rs-movies/Spirit Untamed (2021)/Spirit Untamed (2021) {tmdb-637693} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: State of Play (2009)" "/mnt/synology/rs-movies/State of Play (2009)/State of Play (2009) {tmdb-16995} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Wind River (2017)" "/mnt/synology/rs-movies/Wind River (2017)/Wind River (2017) {tmdb-395834} - [Bluray-1080p][DTS 5.1][x264]-TayTO.mkv"

do_delete "Chris lower quality: Strays (2023)" "/mnt/synology/rs-movies/Strays (2023)/Strays (2023) {tmdb-912908} - [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: The Fighter (2010)" "/mnt/synology/rs-movies/The Fighter (2010)/The Fighter (2010) {tmdb-45317} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: The Outfit (2022)" "/mnt/synology/rs-movies/The Outfit (2022)/The Outfit (2022) {tmdb-799876} - [Bluray-1080p][EAC3 5.1][x264]-SPHD.mkv"

do_delete "Chris lower quality: The Ugly Stepsister (2025)" "/mnt/synology/rs-movies/The Ugly Stepsister (2025)/The Ugly Stepsister (2025) {tmdb-1284120} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-HONE.mkv"

do_delete "Chris lower quality: Star Wars (1977)" "/mnt/synology/rs-movies/Star Wars (1977)/Star Wars (1977) {tmdb-11} - [Bluray-1080p][EAC3 7.1][x264].mkv"

do_delete "Chris lower quality: Jason X (2001)" "/mnt/synology/rs-movies/Jason X (2001)/Jason X (2001) {tmdb-11470} - {edition-Unrated} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: James and the Giant Peach (1996)" "/mnt/synology/rs-movies/James and the Giant Peach (1996)/James and the Giant Peach (1996) {tmdb-10539} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: The Karate Kid (2010)" "/mnt/synology/rs-movies/The Karate Kid (2010)/The Karate Kid (2010) {tmdb-38575} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-GPRS.mkv"

do_delete "Chris lower quality: The Worthy (2016)" "/mnt/synology/rs-movies/The Worthy (2016)/The Worthy (2016) {tmdb-413780} - [NF][WEBDL-1080p][AC3 5.1][x264]-SadeceBluRay.mkv"

do_delete "Chris lower quality: The Hurt Locker (2008)" "/mnt/synology/rs-movies/The Hurt Locker (2008)/The Hurt Locker (2008) {tmdb-12162} - [Bluray-1080p Proper REAL][DTS 5.1][x264]-FSiHD.mkv"

do_delete "Chris lower quality: Freaky (2020)" "/mnt/synology/rs-movies/Freaky (2020)/Freaky (2020) {tmdb-551804} - [WEBDL-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Werewolves (2024)" "/mnt/synology/rs-movies/Werewolves (2024)/Werewolves (2024) {tmdb-970450} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: -batteries not included (1987)" "/mnt/synology/rs-movies/-batteries not included (1987)/-batteries not included (1987) {tmdb-11548} - [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv"

do_delete "Chris lower quality: Oxygen (2021)" "/mnt/synology/rs-movies/Oxygen (2021)/Oxygen (2021) {tmdb-471498} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-EVO.mkv"

do_delete "Chris lower quality: Jurassic World Rebirth (2025)" "/mnt/synology/rs-movies/Jurassic World Rebirth (2025)/Jurassic World Rebirth (2025) {tmdb-1234821} - [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-ThisMovieIsDINOmite.mkv"

do_delete "Chris lower quality: Lara Croft Tomb Raider (2001)" "/mnt/synology/rs-movies/Lara Croft Tomb Raider (2001)/Lara Croft Tomb Raider (2001) {tmdb-1995} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Annihilation (2018)" "/mnt/synology/rs-movies/Annihilation (2018)/Annihilation (2018) {tmdb-300668} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Humanist Vampire Seeking Consenting Suicidal Person (2023)" "/mnt/synology/rs-movies/Humanist Vampire Seeking Consenting Suicidal Person (2023)/Humanist Vampire Seeking Consenting Suicidal Person (2023) {tmdb-988402} - [Bluray-1080p][EAC3 5.1][x264]-Kitsune.mkv"

do_delete "Chris lower quality: Avengers Age of Ultron (2015)" "/mnt/synology/rs-movies/Avengers Age of Ultron (2015)/Avengers Age of Ultron (2015) {tmdb-99861} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Rumble Through the Dark (2023)" "/mnt/synology/rs-movies/Rumble Through the Dark (2023)/Rumble Through the Dark (2023) {tmdb-844416} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Vice (2018)" "/mnt/synology/rs-movies/Vice (2018)/Vice (2018) {tmdb-429197} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: The Mitchells vs. the Machines (2021)" "/mnt/synology/rs-movies/The Mitchells vs. the Machines (2021)/The Mitchells vs. the Machines (2021) {tmdb-501929} - [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv"

do_delete "Chris lower quality: Twin Peaks Fire Walk with Me (1992)" "/mnt/synology/rs-movies/Twin Peaks Fire Walk with Me (1992)/Twin Peaks Fire Walk with Me (1992) {tmdb-1923} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: The Disaster Artist (2017)" "/mnt/synology/rs-movies/The Disaster Artist (2017)/The Disaster Artist (2017) {tmdb-371638} - [Bluray-1080p][AC3 5.1][x264]-TayTO.mkv"

do_delete "Chris lower quality: Against the Ice (2022)" "/mnt/synology/rs-movies/Against the Ice (2022)/Against the Ice (2022) {tmdb-836009} - [NF][WEBDL-1080p Proper][EAC3 Atmos 5.1][x264]-TEPES.mkv"

do_delete "Chris lower quality: Expend4bles (2023)" "/mnt/synology/rs-movies/Expend4bles (2023)/Expend4bles (2023) {tmdb-299054} - [WEBDL-1080p Proper][EAC3 5.1][h264]-HUZZAH.mkv"

do_delete "Chris lower quality: Escape Room Tournament of Champions (2021)" "/mnt/synology/rs-movies/Escape Room Tournament of Champions (2021)/Escape Room Tournament of Champions (2021) {tmdb-585216} - [Bluray-1080p][EAC3 5.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: George Carlin Its Bad for Ya! (2008)" "/mnt/synology/rs-movies/George Carlin Its Bad for Ya! (2008)/George Carlin Its Bad for Ya! (2008) {tmdb-13643} - [Bluray-1080p][AC3 2.0][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: A Month by the Lake (1995)" "/mnt/synology/rs-movies/A Month by the Lake (1995)/A Month by the Lake (1995) {tmdb-41007} - [AMZN][WEBRip-1080p][EAC3 2.0][x264]-TEPES.mkv"

do_delete "Chris lower quality: Alien (1979)" "/mnt/synology/rs-movies/Alien (1979)/Alien (1979) {tmdb-348} - [Bluray-1080p][DTS-HD MA 5.1][x264].mkv"

do_delete "Chris lower quality: Toy Story 3 (2010)" "/mnt/synology/rs-movies/Toy Story 3 (2010)/Toy Story 3 (2010) {tmdb-10193} - [Bluray-1080p][DTS-ES 5.1][x264]-ViSTA.mkv"

do_delete "Chris lower quality: Frozen II (2019)" "/mnt/synology/rs-movies/Frozen II (2019)/Frozen II (2019) {tmdb-330457} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Revolutionary Road (2008)" "/mnt/synology/rs-movies/Revolutionary Road (2008)/Revolutionary Road (2008) {tmdb-4148} - [Bluray-1080p][AC3 5.1][x264]-FuzerHD.mkv"

do_delete "Chris lower quality: Just Go with It (2011)" "/mnt/synology/rs-movies/Just Go with It (2011)/Just Go with It (2011) {tmdb-50546} - [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv"

do_delete "Chris lower quality: Prey (2022)" "/mnt/synology/rs-movies/Prey (2022)/Prey (2022) {tmdb-766507} - [Bluray-1080p][EAC3 7.1][x264]-HiDt.mkv"

do_delete "Chris lower quality: Poseidon (2006)" "/mnt/synology/rs-movies/Poseidon (2006)/Poseidon (2006) {tmdb-503} - [Bluray-1080p][DTS 5.1][x264]-SbR.mkv"

do_delete "Chris lower quality: Pacific Rim (2013)" "/mnt/synology/rs-movies/Pacific Rim (2013)/Pacific Rim (2013) {tmdb-68726} - [Bluray-1080p][EAC3 7.1][DV HDR10][x265]-SM737.mkv"

do_delete "Chris lower quality: Birds of Prey and the Fantabulous Emancipation of One Harley Quinn (2020)" "/mnt/synology/rs-movies/Birds of Prey and the Fantabulous Emancipation of One Harley Quinn (2020)/Birds of Prey and the Fantabulous Emancipation of One Harley Quinn (2020) {tmdb-495764} - [WEBDL-1080p][EAC3 Atmos 5.1][h264].mkv"

do_delete "Chris lower quality: About Fate (2022)" "/mnt/synology/rs-movies/About Fate (2022)/About Fate (2022) {tmdb-828613} - [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: The Magnificent Seven (2016)" "/mnt/synology/rs-movies/The Magnificent Seven (2016)/The Magnificent Seven (2016) {tmdb-333484} - [Bluray-1080p][DTS 5.1][x264]-TayTO.mkv"

do_delete "Chris lower quality: Bob Marley One Love (2024)" "/mnt/synology/rs-movies/Bob Marley One Love (2024)/Bob Marley One Love (2024) {tmdb-802219} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-ETHEL.mkv"

do_delete "Chris lower quality: Star Wars The Force Awakens (2015)" "/mnt/synology/rs-movies/Star Wars The Force Awakens (2015)/Star Wars The Force Awakens (2015) {tmdb-140607} - [Bluray-1080p][EAC3 7.1][x264].mkv"

do_delete "Chris lower quality: So I Married an Axe Murderer (1993)" "/mnt/synology/rs-movies/So I Married an Axe Murderer (1993)/So I Married an Axe Murderer (1993) {tmdb-10442} - [Bluray-1080p][DTS 5.1][x264]-EuReKA.mkv"

do_delete "Chris lower quality: Snatch (2000)" "/mnt/synology/rs-movies/Snatch (2000)/Snatch (2000) {tmdb-107} - [Bluray-1080p][EAC3 7.1][HDR10][x265]-c0kE.mkv"

do_delete "Chris lower quality: The Longest Day (1962)" "/mnt/synology/rs-movies/The Longest Day (1962)/The Longest Day (1962) {tmdb-9289} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: No Hard Feelings (2023)" "/mnt/synology/rs-movies/No Hard Feelings (2023)/No Hard Feelings (2023) {tmdb-884605} - [MA][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Sicario Day of the Soldado (2018)" "/mnt/synology/rs-movies/Sicario Day of the Soldado (2018)/Sicario Day of the Soldado (2018) {tmdb-400535} - [Bluray-1080p][DTS 5.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: Project Gemini (2022)" "/mnt/synology/rs-movies/Project Gemini (2022)/Project Gemini (2022) {tmdb-575322} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: Dawn of the Dead (2004)" "/mnt/synology/rs-movies/Dawn of the Dead (2004)/Dawn of the Dead (2004) {tmdb-924} - {edition-Unrated} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: Coach Carter (2005)" "/mnt/synology/rs-movies/Coach Carter (2005)/Coach Carter (2005) {tmdb-7214} - [Bluray-1080p][AC3 5.1][x264]-HD1080.mkv"

do_delete "Chris lower quality: The Color Purple (1985)" "/mnt/synology/rs-movies/The Color Purple (1985)/The Color Purple (1985) {tmdb-873} - [Bluray-1080p][AC3 5.1][x264]-EbP.mkv"

do_delete "Chris lower quality: Lewis Black In God We Rust (2012)" "/mnt/synology/rs-movies/Lewis Black In God We Rust (2012)/Lewis Black In God We Rust (2012) {tmdb-96683} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Evil Does Not Exist (2023)" "/mnt/synology/rs-movies/Evil Does Not Exist (2023)/Evil Does Not Exist (2023) {tmdb-1156125} - [Bluray-1080p][EAC3 5.1][x264]-BV.mkv"

do_delete "Chris lower quality: 30 Days of Night (2007)" "/mnt/synology/rs-movies/30 Days of Night (2007)/30 Days of Night (2007) {tmdb-4513} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv"

do_delete "Chris lower quality: Me Myself and Irene (2000)" "/mnt/synology/rs-movies/Me Myself and Irene (2000)/Me Myself and Irene (2000) {tmdb-2123} - [Bluray-1080p][DTS 5.1][x264]-PerfectionHD.mkv"

do_delete "Chris lower quality: Leo (2023)" "/mnt/synology/rs-movies/Leo (2023)/Leo (2023) {tmdb-1075794} - [WEBDL-1080p][EAC3 Atmos 5.1][x264]-EDITH.mkv"

do_delete "Chris lower quality: Justice League Dark (2017)" "/mnt/synology/rs-movies/Justice League Dark (2017)/Justice League Dark (2017) {tmdb-408220} - [WEBDL-1080p][AC3 5.1][h264]-FGT.mkv"

do_delete "Chris lower quality: A Star Is Born (2018)" "/mnt/synology/rs-movies/A Star Is Born (2018)/A Star Is Born (2018) {tmdb-332562} - [Bluray-1080p][AC3 5.1][x264]-iFT.mkv"

do_delete "Chris lower quality: Summer Rental (1985)" "/mnt/synology/rs-movies/Summer Rental (1985)/Summer Rental (1985) {tmdb-19357} - [WEBDL-1080p][EAC3 2.0][h264]-ETHiCS.mkv"

do_delete "Chris lower quality: The Dive (2023)" "/mnt/synology/rs-movies/The Dive (2023)/The Dive (2023) {tmdb-1109534} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Air (2023)" "/mnt/synology/rs-movies/Air (2023)/Air (2023) {tmdb-964980} - [WEBDL-1080p Proper][EAC3 Atmos 5.1][h264]-NAISU.mkv"

do_delete "Chris lower quality: The Smurfs 2 (2013)" "/mnt/synology/rs-movies/The Smurfs 2 (2013)/The Smurfs 2 (2013) {tmdb-77931} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: The Batman (2022)" "/mnt/synology/rs-movies/The Batman (2022)/The Batman (2022) {tmdb-414906} - [WEBDL-1080p][AAC 2.0][h264]-CMRG.mkv"

do_delete "Chris lower quality: Traffic (2000)" "/mnt/synology/rs-movies/Traffic (2000)/Traffic (2000) {tmdb-1900} - [Bluray-1080p][EAC3 5.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: Murder Party (2007)" "/mnt/synology/rs-movies/Murder Party (2007)/Murder Party (2007) {tmdb-13561} - [NF][WEBDL-1080p][AC3 5.1][x264]-NTG.mkv"

do_delete "Chris lower quality: The Hunger Games Mockingjay Part 1 (2014)" "/mnt/synology/rs-movies/The Hunger Games Mockingjay Part 1 (2014)/The Hunger Games Mockingjay Part 1 (2014) {tmdb-131631} - [Bluray-1080p][AC3 2.0][h264]-RMXTRAS.mkv"

do_delete "Chris lower quality: The Roses (2025)" "/mnt/synology/rs-movies/The Roses (2025)/The Roses (2025) {tmdb-1267905} - [WEBRip-1080p][EAC3 Atmos 5.1][x264]-SPHD.mkv"

do_delete "Chris lower quality: Forgetting Sarah Marshall (2008)" "/mnt/synology/rs-movies/Forgetting Sarah Marshall (2008)/Forgetting Sarah Marshall (2008) {tmdb-9870} - [Bluray-1080p][DTS 5.1][x264]-CiNEFiLE.mkv"

do_delete "Chris lower quality: Bugsy (1991)" "/mnt/synology/rs-movies/Bugsy (1991)/Bugsy (1991) {tmdb-10337} - [WEBRip-1080p][EAC3 5.1][x264]-NTb.mkv"

do_delete "Chris lower quality: There Are No Saints (2022)" "/mnt/synology/rs-movies/There Are No Saints (2022)/There Are No Saints (2022) {tmdb-267805} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Blood Father (2016)" "/mnt/synology/rs-movies/Blood Father (2016)/Blood Father (2016) {tmdb-309886} - [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv"

do_delete "Chris lower quality: In a Violent Nature (2024)" "/mnt/synology/rs-movies/In a Violent Nature (2024)/In a Violent Nature (2024) {tmdb-1214509} - [WEBDL-1080p][EAC3 5.1][h264]-CalmNiceToucanetOfCompletion.mkv"

do_delete "Chris lower quality: Hell or High Water (2016)" "/mnt/synology/rs-movies/Hell or High Water (2016)/Hell or High Water (2016) {tmdb-338766} - [Bluray-1080p][DTS 5.1][x264]-VECTOR.mkv"

do_delete "Chris lower quality: Nightmare Alley (2021)" "/mnt/synology/rs-movies/Nightmare Alley (2021)/Nightmare Alley (2021) {tmdb-597208} - [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv"

do_delete "Chris lower quality: Wolf Man (2025)" "/mnt/synology/rs-movies/Wolf Man (2025)/Wolf Man (2025) {tmdb-710295} - [WEBDL-1080p][EAC3 5.1][h264]-ETHEL.mkv"

do_delete "Chris lower quality: Nobody 2 (2025)" "/mnt/synology/rs-movies/Nobody 2 (2025)/Nobody 2 (2025) {tmdb-1007734} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: Fortress (2021)" "/mnt/synology/rs-movies/Fortress (2021)/Fortress (2021) {tmdb-826749} - [Bluray-1080p][AC3 5.1][x264]-BdC.mkv"

do_delete "Chris lower quality: Daybreakers (2010)" "/mnt/synology/rs-movies/Daybreakers (2010)/Daybreakers (2010) {tmdb-19901} - [Bluray-1080p][AC3 5.1][x264]-EbP.mkv"

do_delete "Chris lower quality: Grown Ups 2 (2013)" "/mnt/synology/rs-movies/Grown Ups 2 (2013)/Grown Ups 2 (2013) {tmdb-109418} - [Bluray-1080p][AC3 5.1][x264]-playHD.mkv"

do_delete "Chris lower quality: Daddys Head (2024)" "/mnt/synology/rs-movies/Daddys Head (2024)/Daddys Head (2024) {tmdb-1089123} - [WEBDL-1080p][EAC3 5.1][h264]-SoundsDirty.mkv"

do_delete "Chris lower quality: The Out-Laws (2023)" "/mnt/synology/rs-movies/The Out-Laws (2023)/The Out-Laws (2023) {tmdb-921636} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv"

do_delete "Chris lower quality: Monster Trucks (2016)" "/mnt/synology/rs-movies/Monster Trucks (2016)/Monster Trucks (2016) {tmdb-262841} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Mr. Woodcock (2007)" "/mnt/synology/rs-movies/Mr. Woodcock (2007)/Mr. Woodcock (2007) {tmdb-13257} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Rio 2 (2014)" "/mnt/synology/rs-movies/Rio 2 (2014)/Rio 2 (2014) {tmdb-172385} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Kingsman The Secret Service (2015)" "/mnt/synology/rs-movies/Kingsman The Secret Service (2015)/Kingsman The Secret Service (2015) {tmdb-207703} - {edition-Uncut} [Bluray-1080p][DTS-ES 5.1][x264]-WiKi.mkv"

do_delete "Chris lower quality: Cinderella (1950)" "/mnt/synology/rs-movies/Cinderella (1950)/Cinderella (1950) {tmdb-11224} - [HDTV-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Murder Mystery 2 (2023)" "/mnt/synology/rs-movies/Murder Mystery 2 (2023)/Murder Mystery 2 (2023) {tmdb-638974} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv"

do_delete "Chris lower quality: Beerfest (2006)" "/mnt/synology/rs-movies/Beerfest (2006)/Beerfest (2006) {tmdb-9988} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: The Iron Claw (2023)" "/mnt/synology/rs-movies/The Iron Claw (2023)/The Iron Claw (2023) {tmdb-850165} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Small Things Like These (2024)" "/mnt/synology/rs-movies/Small Things Like These (2024)/Small Things Like These (2024) {tmdb-1102493} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv"

do_delete "Chris lower quality: Day Shift (2022)" "/mnt/synology/rs-movies/Day Shift (2022)/Day Shift (2022) {tmdb-755566} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv"

do_delete "Chris lower quality: Those Who Wish Me Dead (2021)" "/mnt/synology/rs-movies/Those Who Wish Me Dead (2021)/Those Who Wish Me Dead (2021) {tmdb-578701} - [HMAX][WEBDL-1080p][AC3 5.1][x264]-CMRG.mkv"

do_delete "Chris lower quality: Titanic (1997)" "/mnt/synology/rs-movies/Titanic (1997)/Titanic (1997) {tmdb-597} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv"

do_delete "Chris lower quality: Sonic the Hedgehog 3 (2024)" "/mnt/synology/rs-movies/Sonic the Hedgehog 3 (2024)/Sonic the Hedgehog 3 (2024) {tmdb-939243} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-APEX.mkv"

do_delete "Chris lower quality: Mamma Mia! Here We Go Again (2018)" "/mnt/synology/rs-movies/Mamma Mia! Here We Go Again (2018)/Mamma Mia! Here We Go Again (2018) {tmdb-458423} - [Bluray-1080p][AC3 5.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: Nobody (2021)" "/mnt/synology/rs-movies/Nobody (2021)/Nobody (2021) {tmdb-615457} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: Cash Out (2024)" "/mnt/synology/rs-movies/Cash Out (2024)/Cash Out (2024) {tmdb-1116490} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: Big Trouble in Little China (1986)" "/mnt/synology/rs-movies/Big Trouble in Little China (1986)/Big Trouble in Little China (1986) {tmdb-6978} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Margaret (2011)" "/mnt/synology/rs-movies/Margaret (2011)/Margaret (2011) {tmdb-44754} - [DSNP][WEBDL-1080p][EAC3 5.1][h264]-Tulips.mkv"

do_delete "Chris lower quality: Iron Man 3 (2013)" "/mnt/synology/rs-movies/Iron Man 3 (2013)/Iron Man 3 (2013) {tmdb-68721} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Night Teeth (2021)" "/mnt/synology/rs-movies/Night Teeth (2021)/Night Teeth (2021) {tmdb-669671} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-EVO.mkv"

do_delete "Chris lower quality: Luckiest Girl Alive (2022)" "/mnt/synology/rs-movies/Luckiest Girl Alive (2022)/Luckiest Girl Alive (2022) {tmdb-799546} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv"

do_delete "Chris lower quality: Dolemite Is My Name (2019)" "/mnt/synology/rs-movies/Dolemite Is My Name (2019)/Dolemite Is My Name (2019) {tmdb-528888} - [WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTG.mkv"

do_delete "Chris lower quality: Hustlers (2019)" "/mnt/synology/rs-movies/Hustlers (2019)/Hustlers (2019) {tmdb-540901} - [Bluray-1080p][AC3 5.1][x264]-AAA.mkv"

do_delete "Chris lower quality: Dont Make Me Go (2022)" "/mnt/synology/rs-movies/Dont Make Me Go (2022)/Dont Make Me Go (2022) {tmdb-861072} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: The Bourne Legacy (2012)" "/mnt/synology/rs-movies/The Bourne Legacy (2012)/The Bourne Legacy (2012) {tmdb-49040} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv"

do_delete "Chris lower quality: Born on the Fourth of July (1989)" "/mnt/synology/rs-movies/Born on the Fourth of July (1989)/Born on the Fourth of July (1989) {tmdb-2604} - [Bluray-1080p][DTS 5.1][x264]-CRiSC.mkv"

do_delete "Chris lower quality: The Killing Fields (1984)" "/mnt/synology/rs-movies/The Killing Fields (1984)/The Killing Fields (1984) {tmdb-625} - [Bluray-1080p][DTS 5.1][x264]-TiMELORDS.mkv"

do_delete "Chris lower quality: Fist of Legend (1994)" "/mnt/synology/rs-movies/Fist of Legend (1994)/Fist of Legend (1994) {tmdb-17809} - [Bluray-1080p][DTS 5.1][x264]-aAF.mkv"

do_delete "Chris lower quality: Blink Twice (2024)" "/mnt/synology/rs-movies/Blink Twice (2024)/Blink Twice (2024) {tmdb-840705} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Madagascar 3 Europes Most Wanted (2012)" "/mnt/synology/rs-movies/Madagascar 3 Europes Most Wanted (2012)/Madagascar 3 Europes Most Wanted (2012) {tmdb-80321} - [WEBDL-1080p][AC3 5.1][h264]-CiNEMiX.mkv"

do_delete "Chris lower quality: Femme Fatale (2002)" "/mnt/synology/rs-movies/Femme Fatale (2002)/Femme Fatale (2002) {tmdb-9280} - [WEBDL-1080p][EAC3 2.0][h264].mkv"

do_delete "Chris lower quality: Peaceful Warrior (2006)" "/mnt/synology/rs-movies/Peaceful Warrior (2006)/Peaceful Warrior (2006) {tmdb-13689} - [Bluray-1080p][AC3 5.1][x264]-FGT.mkv"

do_delete "Chris lower quality: Section 8 (2022)" "/mnt/synology/rs-movies/Section 8 (2022)/Section 8 (2022) {tmdb-893228} - [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Eternity (2025)" "/mnt/synology/rs-movies/Eternity (2025)/Eternity (2025) {tmdb-1259102} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: Abbott and Costello Meet the Mummy (1955)" "/mnt/synology/rs-movies/Abbott and Costello Meet the Mummy (1955)/Abbott and Costello Meet the Mummy (1955) {tmdb-26661} - [AMZN][WEBDL-1080p][EAC3 2.0][x264]-ABM.mkv"

do_delete "Chris lower quality: Borderlands (2024)" "/mnt/synology/rs-movies/Borderlands (2024)/Borderlands (2024) {tmdb-365177} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-BreakYourKevinHart.mkv"

do_delete "Chris lower quality: Jumanji Welcome to the Jungle (2017)" "/mnt/synology/rs-movies/Jumanji Welcome to the Jungle (2017)/Jumanji Welcome to the Jungle (2017) {tmdb-353486} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Puss in Boots (2011)" "/mnt/synology/rs-movies/Puss in Boots (2011)/Puss in Boots (2011) {tmdb-417859} - [Bluray-1080p][AC3 5.1][x264]-EbP.mkv"

do_delete "Chris lower quality: Poser (2022)" "/mnt/synology/rs-movies/Poser (2022)/Poser (2022) {tmdb-820967} - [WEBDL-1080p][EAC3 5.1][h264]-DiMEPiECE.mkv"

do_delete "Chris lower quality: Blue Velvet (1986)" "/mnt/synology/rs-movies/Blue Velvet (1986)/Blue Velvet (1986) {tmdb-793} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: The Twilight Saga New Moon (2009)" "/mnt/synology/rs-movies/The Twilight Saga New Moon (2009)/The Twilight Saga New Moon (2009) {tmdb-18239} - [Bluray-1080p][DTS-HD MA 5.1][x264]-FraMeSToR.mkv"

do_delete "Chris lower quality: Good Burger 2 (2023)" "/mnt/synology/rs-movies/Good Burger 2 (2023)/Good Burger 2 (2023) {tmdb-1101582} - [Bluray-1080p][AC3 5.1][x264]-ArMor.mkv"

do_delete "Chris lower quality: The Longest Yard (2005)" "/mnt/synology/rs-movies/The Longest Yard (2005)/The Longest Yard (2005) {tmdb-9291} - [WEBDL-1080p][EAC3 5.1][x264].mkv"

do_delete "Chris lower quality: Childs Play (1988)" "/mnt/synology/rs-movies/Childs Play (1988)/Childs Play (1988) {tmdb-10585} - [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv"

do_delete "Chris lower quality: Piggy (2022)" "/mnt/synology/rs-movies/Piggy (2022)/Piggy (2022) {tmdb-848058} - [Bluray-1080p][AC3 5.1][x264]-playHD.mkv"

do_delete "Chris lower quality: Boogeyman (2005)" "/mnt/synology/rs-movies/Boogeyman (2005)/Boogeyman (2005) {tmdb-8968} - [WEBDL-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Whitney Houston I Wanna Dance with Somebody (2022)" "/mnt/synology/rs-movies/Whitney Houston I Wanna Dance with Somebody (2022)/Whitney Houston I Wanna Dance with Somebody (2022) {tmdb-696157} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: The Fugitive (1993)" "/mnt/synology/rs-movies/The Fugitive (1993)/The Fugitive (1993) {tmdb-5503} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Tom and Jerry Snowmans Land (2022)" "/mnt/synology/rs-movies/Tom and Jerry Snowmans Land (2022)/Tom and Jerry Snowmans Land (2022) {tmdb-1018403} - [WEBDL-1080p][AC3 2.0][h264]-HDM.mkv"

do_delete "Chris lower quality: The Grey (2012)" "/mnt/synology/rs-movies/The Grey (2012)/The Grey (2012) {tmdb-75174} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Ride On (2023)" "/mnt/synology/rs-movies/Ride On (2023)/Ride On (2023) {tmdb-931102} - [WEBDL-1080p][AC3 5.1][x264]-CRO-DiAMOND.mkv"

do_delete "Chris lower quality: You Are Not My Mother (2022)" "/mnt/synology/rs-movies/You Are Not My Mother (2022)/You Are Not My Mother (2022) {tmdb-771536} - [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Enemies of the People (2009)" "/mnt/synology/rs-movies/Enemies of the People (2009)/Enemies of the People (2009) {tmdb-75450} - [WEBDL-1080p][AAC 2.0][h264]-CBFM.mkv"

do_delete "Chris lower quality: Once Upon a Time in Mexico (2003)" "/mnt/synology/rs-movies/Once Upon a Time in Mexico (2003)/Once Upon a Time in Mexico (2003) {tmdb-1428} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Occupation Rainfall (2020)" "/mnt/synology/rs-movies/Occupation Rainfall (2020)/Occupation Rainfall (2020) {tmdb-688258} - [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: Munich (2005)" "/mnt/synology/rs-movies/Munich (2005)/Munich (2005) {tmdb-612} - [Bluray-1080p][AC3 5.1][x264]-HiFi.mkv"

do_delete "Chris lower quality: Gladiator II (2024)" "/mnt/synology/rs-movies/Gladiator II (2024)/Gladiator II (2024) {tmdb-558449} - [WEBDL-1080p][EAC3 5.1][h264]-ETHEL.mkv"

do_delete "Chris lower quality: Friendship (2025)" "/mnt/synology/rs-movies/Friendship (2025)/Friendship (2025) {tmdb-1239655} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: Joker (2019)" "/mnt/synology/rs-movies/Joker (2019)/Joker (2019) {tmdb-475557} - [Bluray-1080p][EAC3 7.1][HDR10][x265].mkv"

do_delete "Chris lower quality: Red Sonja (1985)" "/mnt/synology/rs-movies/Red Sonja (1985)/Red Sonja (1985) {tmdb-9626} - [Bluray-1080p][DTS 5.1][x264]-Japhson.mkv"

do_delete "Chris lower quality: Justice League Warworld (2023)" "/mnt/synology/rs-movies/Justice League Warworld (2023)/Justice League Warworld (2023) {tmdb-1003581} - [WEBDL-1080p][AC3 5.1][h264]-LouLaVie.mkv"

do_delete "Chris lower quality: Here Before (2022)" "/mnt/synology/rs-movies/Here Before (2022)/Here Before (2022) {tmdb-669400} - [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: High School Musical 2 (2007)" "/mnt/synology/rs-movies/High School Musical 2 (2007)/High School Musical 2 (2007) {tmdb-13649} - {edition-Extended Cut} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Fury (2014)" "/mnt/synology/rs-movies/Fury (2014)/Fury (2014) {tmdb-228150} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: There Will Be Blood (2007)" "/mnt/synology/rs-movies/There Will Be Blood (2007)/There Will Be Blood (2007) {tmdb-7345} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Ralph Breaks the Internet (2018)" "/mnt/synology/rs-movies/Ralph Breaks the Internet (2018)/Ralph Breaks the Internet (2018) {tmdb-404368} - [WEBDL-1080p][AC3 5.1][h264].mkv"

do_delete "Chris lower quality: American Fiction (2023)" "/mnt/synology/rs-movies/American Fiction (2023)/American Fiction (2023) {tmdb-1056360} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: The Dead Zone (1983)" "/mnt/synology/rs-movies/The Dead Zone (1983)/The Dead Zone (1983) {tmdb-11336} - [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv"

do_delete "Chris lower quality: Kingdom of the Planet of the Apes (2024)" "/mnt/synology/rs-movies/Kingdom of the Planet of the Apes (2024)/Kingdom of the Planet of the Apes (2024) {tmdb-653346} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-ETHEL.mkv"

do_delete "Chris lower quality: The Substance (2024)" "/mnt/synology/rs-movies/The Substance (2024)/The Substance (2024) {tmdb-933260} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv"

do_delete "Chris lower quality: The Program (1993)" "/mnt/synology/rs-movies/The Program (1993)/The Program (1993) {tmdb-18133} - [AMZN][WEBDL-1080p][EAC3 2.0][h264]-monkee.mkv"

do_delete "Chris lower quality: One Shot (2021)" "/mnt/synology/rs-movies/One Shot (2021)/One Shot (2021) {tmdb-811592} - [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: The Incredibles (2004)" "/mnt/synology/rs-movies/The Incredibles (2004)/The Incredibles (2004) {tmdb-9806} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv"

do_delete "Chris lower quality: Spoiler Alert (2022)" "/mnt/synology/rs-movies/Spoiler Alert (2022)/Spoiler Alert (2022) {tmdb-507903} - [Bluray-1080p][DTS-HD MA 5.1][x264]-PiGNUS.mkv"

do_delete "Chris lower quality: Dark City (1998)" "/mnt/synology/rs-movies/Dark City (1998)/Dark City (1998) {tmdb-2666} - [Bluray-1080p][DTS 5.1][x264]-MaG.mkv"

do_delete "Chris lower quality: The Terminator (1984)" "/mnt/synology/rs-movies/The Terminator (1984)/The Terminator (1984) {tmdb-218} - [Remux-1080p][FLAC 1.0][AVC]-CiNEPHiLES.mkv"

do_delete "Chris lower quality: The Life of David Gale (2003)" "/mnt/synology/rs-movies/The Life of David Gale (2003)/The Life of David Gale (2003) {tmdb-11615} - [WEBDL-1080p][DTS 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: Barbie (2023)" "/mnt/synology/rs-movies/Barbie (2023)/Barbie (2023) {tmdb-346698} - [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Disobedience (2018)" "/mnt/synology/rs-movies/Disobedience (2018)/Disobedience (2018) {tmdb-419743} - [Bluray-1080p][DTS 5.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: The Fabelmans (2022)" "/mnt/synology/rs-movies/The Fabelmans (2022)/The Fabelmans (2022) {tmdb-804095} - [MA][WEBDL-1080p][EAC3 7.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Why Him (2016)" "/mnt/synology/rs-movies/Why Him (2016)/Why Him (2016) {tmdb-356305} - [Bluray-1080p][AC3 5.1][x264]-DON.mkv"

do_delete "Chris lower quality: The Book of Clarence (2024)" "/mnt/synology/rs-movies/The Book of Clarence (2024)/The Book of Clarence (2024) {tmdb-976584} - [Bluray-1080p Proper][EAC3 Atmos 5.1][x264]-BiTOR.mkv"

do_delete "Chris lower quality: Indiana Jones and the Last Crusade (1989)" "/mnt/synology/rs-movies/Indiana Jones and the Last Crusade (1989)/Indiana Jones and the Last Crusade (1989) {tmdb-89} - [HDTV-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: The Chronicles of Narnia The Lion the Witch and the Wardrobe (2005)" "/mnt/synology/rs-movies/The Chronicles of Narnia The Lion the Witch and the Wardrobe (2005)/The Chronicles of Narnia The Lion the Witch and the Wardrobe (2005) {tmdb-411} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Bridget Jones Mad About the Boy (2025)" "/mnt/synology/rs-movies/Bridget Jones Mad About the Boy (2025)/Bridget Jones Mad About the Boy (2025) {tmdb-1272149} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Changeland (2019)" "/mnt/synology/rs-movies/Changeland (2019)/Changeland (2019) {tmdb-575381} - [WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv"

do_delete "Chris lower quality: Suicide Squad Hell to Pay (2018)" "/mnt/synology/rs-movies/Suicide Squad Hell to Pay (2018)/Suicide Squad Hell to Pay (2018) {tmdb-487242} - [WEBDL-1080p][EAC3 5.1][x264]-Kitsune.mkv"

do_delete "Chris lower quality: Fantastic Four (2015)" "/mnt/synology/rs-movies/Fantastic Four (2015)/Fantastic Four (2015) {tmdb-166424} - [Bluray-1080p][DTS-ES 5.1][x264]-NCmt.mkv"

do_delete "Chris lower quality: Mr. Holmes (2015)" "/mnt/synology/rs-movies/Mr. Holmes (2015)/Mr. Holmes (2015) {tmdb-280996} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Minari (2021)" "/mnt/synology/rs-movies/Minari (2021)/Minari (2021) {tmdb-615643} - [WEBDL-1080p][AC3 2.0][x264]-EVO.mkv"

do_delete "Chris lower quality: Detained (2024)" "/mnt/synology/rs-movies/Detained (2024)/Detained (2024) {tmdb-1282960} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Opus (2025)" "/mnt/synology/rs-movies/Opus (2025)/Opus (2025) {tmdb-1202479} - [WEBDL-1080p][EAC3 5.1][h264]-ETHEL.mkv"

do_delete "Chris lower quality: Shotgun Wedding (2022)" "/mnt/synology/rs-movies/Shotgun Wedding (2022)/Shotgun Wedding (2022) {tmdb-758009} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: LEGO DC Comics Super Heroes Justice League Gotham City Breakout (2016)" "/mnt/synology/rs-movies/LEGO DC Comics Super Heroes Justice League Gotham City Breakout (2016)/LEGO DC Comics Super Heroes Justice League Gotham City Breakout (2016) {tmdb-396330} - [Bluray-1080p][DTS 5.1][x264]-ROVERS.mkv"

do_delete "Chris lower quality: The Big Lebowski (1998)" "/mnt/synology/rs-movies/The Big Lebowski (1998)/The Big Lebowski (1998) {tmdb-115} - [Bluray-1080p][AC3 5.1][x264]-SA89.mkv"

do_delete "Chris lower quality: Heretic (2024)" "/mnt/synology/rs-movies/Heretic (2024)/Heretic (2024) {tmdb-1138194} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-APEX.mkv"

do_delete "Chris lower quality: Wolf (1994)" "/mnt/synology/rs-movies/Wolf (1994)/Wolf (1994) {tmdb-10395} - [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv"

do_delete "Chris lower quality: Rebel Moon Part Two The Scargiver (2024)" "/mnt/synology/rs-movies/Rebel Moon Part Two The Scargiver (2024)/Rebel Moon Part Two The Scargiver (2024) {tmdb-934632} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-OzONE.mkv"

do_delete "Chris lower quality: Outside the Wire (2021)" "/mnt/synology/rs-movies/Outside the Wire (2021)/Outside the Wire (2021) {tmdb-775996} - [WEBRip-1080p][DTS-HD MA 5.1][h264]-CREATiVE24.mkv"

do_delete "Chris lower quality: Solomon Kane (2009)" "/mnt/synology/rs-movies/Solomon Kane (2009)/Solomon Kane (2009) {tmdb-32985} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-RegEdits.mkv"

do_delete "Chris lower quality: Master and Commander The Far Side of the World (2003)" "/mnt/synology/rs-movies/Master and Commander The Far Side of the World (2003)/Master and Commander The Far Side of the World (2003) {tmdb-8619} - [Bluray-1080p][DTS 5.1][x264]-FSiHD.mkv"

do_delete "Chris lower quality: Eyes Wide Shut (1999)" "/mnt/synology/rs-movies/Eyes Wide Shut (1999)/Eyes Wide Shut (1999) {tmdb-345} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Soul (2020)" "/mnt/synology/rs-movies/Soul (2020)/Soul (2020) {tmdb-508442} - [WEBDL-1080p][EAC3 Atmos 5.1][h264].mkv"

do_delete "Chris lower quality: The Town (2010)" "/mnt/synology/rs-movies/The Town (2010)/The Town (2010) {tmdb-23168} - {edition-Extended} [Bluray-1080p][AC3 5.1][x264]-EbP.mkv"

do_delete "Chris lower quality: Mission Impossible II (2000)" "/mnt/synology/rs-movies/Mission Impossible II (2000)/Mission Impossible II (2000) {tmdb-955} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv"

do_delete "Chris lower quality: Bean (1997)" "/mnt/synology/rs-movies/Bean (1997)/Bean (1997) {tmdb-1281} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: The Green Knight (2021)" "/mnt/synology/rs-movies/The Green Knight (2021)/The Green Knight (2021) {tmdb-559907} - [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv"

do_delete "Chris lower quality: End of the Road (2022)" "/mnt/synology/rs-movies/End of the Road (2022)/End of the Road (2022) {tmdb-773975} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-EVO.mkv"

do_delete "Chris lower quality: Captain Marvel (2019)" "/mnt/synology/rs-movies/Captain Marvel (2019)/Captain Marvel (2019) {tmdb-299537} - [WEBDL-1080p][AC3 5.1][h264].mkv"

do_delete "Chris lower quality: Monty Python and the Holy Grail (1975)" "/mnt/synology/rs-movies/Monty Python and the Holy Grail (1975)/Monty Python and the Holy Grail (1975) {tmdb-762} - [WEBDL-1080p][AAC 2.0][AV1].mkv"

do_delete "Chris lower quality: The Assessment (2025)" "/mnt/synology/rs-movies/The Assessment (2025)/The Assessment (2025) {tmdb-1317088} - [WEBDL-1080p][EAC3 5.1][h264]-StrangeBrilliantWarthogOfFreedom.mkv"

do_delete "Chris lower quality: Gunner (2024)" "/mnt/synology/rs-movies/Gunner (2024)/Gunner (2024) {tmdb-5492} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Bill Burr Walk Your Way Out (2017)" "/mnt/synology/rs-movies/Bill Burr Walk Your Way Out (2017)/Bill Burr Walk Your Way Out (2017) {tmdb-437752} - [NF][WEBRip-1080p][AC3 5.1][x264]-TrollHD.mkv"

do_delete "Chris lower quality: Sharknado 3 Oh Hell No! (2015)" "/mnt/synology/rs-movies/Sharknado 3 Oh Hell No! (2015)/Sharknado 3 Oh Hell No! (2015) {tmdb-331446} - [Bluray-1080p][DTS 5.1][x264]-VETO.mkv"

do_delete "Chris lower quality: The Last Starfighter (1984)" "/mnt/synology/rs-movies/The Last Starfighter (1984)/The Last Starfighter (1984) {tmdb-11884} - {edition-25th Anniversary Edition} [Bluray-1080p][AAC 2.0][x264]-ext.mkv"

do_delete "Chris lower quality: Shadow Force (2025)" "/mnt/synology/rs-movies/Shadow Force (2025)/Shadow Force (2025) {tmdb-757725} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-HONE.mkv"

do_delete "Chris lower quality: The Crazies (2010)" "/mnt/synology/rs-movies/The Crazies (2010)/The Crazies (2010) {tmdb-29427} - [Remux-1080p][DTS-HD MA 5.1][AVC]-FraMeSToR.mkv"

do_delete "Chris lower quality: The Black Phone (2022)" "/mnt/synology/rs-movies/The Black Phone (2022)/The Black Phone (2022) {tmdb-756999} - [WEBDL-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Resistance (2020)" "/mnt/synology/rs-movies/Resistance (2020)/Resistance (2020) {tmdb-491926} - [WEBDL-1080p][AC3 5.1][h264].mkv"

do_delete "Chris lower quality: Ant-Man and the Wasp Quantumania (2023)" "/mnt/synology/rs-movies/Ant-Man and the Wasp Quantumania (2023)/Ant-Man and the Wasp Quantumania (2023) {tmdb-640146} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Hellraiser (1987)" "/mnt/synology/rs-movies/Hellraiser (1987)/Hellraiser (1987) {tmdb-9003} - [Remux-1080p][PCM 2.0][x264].mkv"

do_delete "Chris lower quality: American Pie (1999)" "/mnt/synology/rs-movies/American Pie (1999)/American Pie (1999) {tmdb-2105} - {edition-Unrated} [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: Love Hard (2021)" "/mnt/synology/rs-movies/Love Hard (2021)/Love Hard (2021) {tmdb-734265} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv"

do_delete "Chris lower quality: Central Intelligence (2016)" "/mnt/synology/rs-movies/Central Intelligence (2016)/Central Intelligence (2016) {tmdb-302699} - [HDTV-1080p][AC3 2.0][h264].mkv"

do_delete "Chris lower quality: Lightyear (2022)" "/mnt/synology/rs-movies/Lightyear (2022)/Lightyear (2022) {tmdb-718789} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: Jolt (2021)" "/mnt/synology/rs-movies/Jolt (2021)/Jolt (2021) {tmdb-617502} - [Bluray-1080p][EAC3 7.1][x264]-HiDt.mkv"

do_delete "Chris lower quality: Civil War (2024)" "/mnt/synology/rs-movies/Civil War (2024)/Civil War (2024) {tmdb-929590} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: The Internship (2013)" "/mnt/synology/rs-movies/The Internship (2013)/The Internship (2013) {tmdb-116741} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Scooby-Doo (2002)" "/mnt/synology/rs-movies/Scooby-Doo (2002)/Scooby-Doo (2002) {tmdb-9637} - [Bluray-1080p][AC3 5.1][x264]-hV.mkv"

do_delete "Chris lower quality: Diamonds Are Forever (1971)" "/mnt/synology/rs-movies/Diamonds Are Forever (1971)/Diamonds Are Forever (1971) {tmdb-681} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: How to Train Your Dragon (2025)" "/mnt/synology/rs-movies/How to Train Your Dragon (2025)/How to Train Your Dragon (2025) {tmdb-1087192} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: The Cabin in the Woods (2012)" "/mnt/synology/rs-movies/The Cabin in the Woods (2012)/The Cabin in the Woods (2012) {tmdb-22970} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: Nomadland (2021)" "/mnt/synology/rs-movies/Nomadland (2021)/Nomadland (2021) {tmdb-581734} - [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv"

do_delete "Chris lower quality: Brother Bear 2 (2006)" "/mnt/synology/rs-movies/Brother Bear 2 (2006)/Brother Bear 2 (2006) {tmdb-10010} - [Bluray-1080p][DTS 5.1][x264]-VETO.mkv"

do_delete "Chris lower quality: Escape Plan 2 Hades (2018)" "/mnt/synology/rs-movies/Escape Plan 2 Hades (2018)/Escape Plan 2 Hades (2018) {tmdb-440471} - [Bluray-1080p][DTS 5.1][x264]-HDC.mkv"

do_delete "Chris lower quality: The 40 Year Old Virgin (2005)" "/mnt/synology/rs-movies/The 40 Year Old Virgin (2005)/The 40 Year Old Virgin (2005) {tmdb-6957} - {edition-Unrated} [Bluray-1080p][DTS 5.1][x264]-SeeNHD.mkv"

do_delete "Chris lower quality: Influencer (2023)" "/mnt/synology/rs-movies/Influencer (2023)/Influencer (2023) {tmdb-1020910} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv"

do_delete "Chris lower quality: EverAfter (1998)" "/mnt/synology/rs-movies/EverAfter (1998)/EverAfter (1998) {tmdb-9454} - [Bluray-1080p][DTS 5.1][x264]-aAF.mkv"

do_delete "Chris lower quality: Bullet Train (2022)" "/mnt/synology/rs-movies/Bullet Train (2022)/Bullet Train (2022) {tmdb-718930} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Prisoner of War (2025)" "/mnt/synology/rs-movies/Prisoner of War (2025)/Prisoner of War (2025) {tmdb-1328803} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: The Fall Guy (2024)" "/mnt/synology/rs-movies/The Fall Guy (2024)/The Fall Guy (2024) {tmdb-746036} - {edition-Extended Version} [WEBDL-1080p Proper][EAC3 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Mob Land (2023)" "/mnt/synology/rs-movies/Mob Land (2023)/Mob Land (2023) {tmdb-979275} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-ChipsAHoy.mkv"

do_delete "Chris lower quality: Anyone But You (2023)" "/mnt/synology/rs-movies/Anyone But You (2023)/Anyone But You (2023) {tmdb-1072790} - [WEBDL-1080p][AC3 5.1][h264]-HowIFeelAboutDonaldTrump.mkv"

do_delete "Chris lower quality: White Noise (2022)" "/mnt/synology/rs-movies/White Noise (2022)/White Noise (2022) {tmdb-744594} - [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv"

do_delete "Chris lower quality: 300 (2007)" "/mnt/synology/rs-movies/300 (2007)/300 (2007) {tmdb-1271} - [Bluray-1080p][EAC3 7.1][DV HDR10][x265]-SM737.mkv"

do_delete "Chris lower quality: Hunter Killer (2018)" "/mnt/synology/rs-movies/Hunter Killer (2018)/Hunter Killer (2018) {tmdb-399402} - [Bluray-1080p][EAC3 5.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: The Royal Hotel (2023)" "/mnt/synology/rs-movies/The Royal Hotel (2023)/The Royal Hotel (2023) {tmdb-944952} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Percy Jackson Sea of Monsters (2013)" "/mnt/synology/rs-movies/Percy Jackson Sea of Monsters (2013)/Percy Jackson Sea of Monsters (2013) {tmdb-76285} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: The Big Ugly (2020)" "/mnt/synology/rs-movies/The Big Ugly (2020)/The Big Ugly (2020) {tmdb-714521} - [WEBDL-1080p][AC3 5.1][h264].mkv"

do_delete "Chris lower quality: Bird Box (2018)" "/mnt/synology/rs-movies/Bird Box (2018)/Bird Box (2018) {tmdb-405774} - [WEBDL-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Let It Shine (2012)" "/mnt/synology/rs-movies/Let It Shine (2012)/Let It Shine (2012) {tmdb-114955} - {edition-Extended} [AMZN][WEBRip-1080p][EAC3 5.1][x264]-TVSmash.mkv"

do_delete "Chris lower quality: The Settlers (2023)" "/mnt/synology/rs-movies/The Settlers (2023)/The Settlers (2023) {tmdb-989589} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Hypnotic (2023)" "/mnt/synology/rs-movies/Hypnotic (2023)/Hypnotic (2023) {tmdb-536437} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Back to the Future Part II (1989)" "/mnt/synology/rs-movies/Back to the Future Part II (1989)/Back to the Future Part II (1989) {tmdb-165} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: Furious 7 (2015)" "/mnt/synology/rs-movies/Furious 7 (2015)/Furious 7 (2015) {tmdb-168259} - {edition-Extended Cut} [Bluray-1080p][EAC3 7.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: The Doors (1991)" "/mnt/synology/rs-movies/The Doors (1991)/The Doors (1991) {tmdb-10537} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Deep Blue Sea (1999)" "/mnt/synology/rs-movies/Deep Blue Sea (1999)/Deep Blue Sea (1999) {tmdb-8914} - [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv"

do_delete "Chris lower quality: Legends of the Fall (1994)" "/mnt/synology/rs-movies/Legends of the Fall (1994)/Legends of the Fall (1994) {tmdb-4476} - [Bluray-1080p][DTS 5.1][x264]-SbR.mkv"

do_delete "Chris lower quality: Days of Thunder (1990)" "/mnt/synology/rs-movies/Days of Thunder (1990)/Days of Thunder (1990) {tmdb-2119} - [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: Firestarter (2022)" "/mnt/synology/rs-movies/Firestarter (2022)/Firestarter (2022) {tmdb-532710} - [WEBDL-1080p][EAC3 5.1][x264]-EVO.mkv"

do_delete "Chris lower quality: Swiss Army Man (2016)" "/mnt/synology/rs-movies/Swiss Army Man (2016)/Swiss Army Man (2016) {tmdb-347031} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Dave Chappelle The Age of Spin (2017)" "/mnt/synology/rs-movies/Dave Chappelle The Age of Spin (2017)/Dave Chappelle The Age of Spin (2017) {tmdb-444705} - [NF][WEBRip-1080p][AC3 5.1][x264]-TrollHD.mkv"

do_delete "Chris lower quality: Monster Island (2017)" "/mnt/synology/rs-movies/Monster Island (2017)/Monster Island (2017) {tmdb-420279} - [WEBDL-1080p][AC3 5.1][x264]-strife.mkv"

do_delete "Chris lower quality: Liar Liar (1997)" "/mnt/synology/rs-movies/Liar Liar (1997)/Liar Liar (1997) {tmdb-1624} - [Bluray-1080p][EAC3 5.1][x264]-honeyvera.mkv"

do_delete "Chris lower quality: The Marvels (2023)" "/mnt/synology/rs-movies/The Marvels (2023)/The Marvels (2023) {tmdb-609681} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: School of Rock (2003)" "/mnt/synology/rs-movies/School of Rock (2003)/School of Rock (2003) {tmdb-1584} - [Bluray-1080p][AC3 5.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: The Empire Strikes Back (1980)" "/mnt/synology/rs-movies/The Empire Strikes Back (1980)/The Empire Strikes Back (1980) {tmdb-1891} - [Bluray-1080p][EAC3 7.1][x264].mkv"

do_delete "Chris lower quality: Enemy (2014)" "/mnt/synology/rs-movies/Enemy (2014)/Enemy (2014) {tmdb-181886} - [WEBDL-1080p][AC3 5.1][h264]-PublicHD.mkv"

do_delete "Chris lower quality: Hulk Where Monsters Dwell (2016)" "/mnt/synology/rs-movies/Hulk Where Monsters Dwell (2016)/Hulk Where Monsters Dwell (2016) {tmdb-422153} - [WEBRip-1080p][EAC3 5.1][x264]-monkee.mkv"

do_delete "Chris lower quality: The Fast and the Furious Tokyo Drift (2006)" "/mnt/synology/rs-movies/The Fast and the Furious Tokyo Drift (2006)/The Fast and the Furious Tokyo Drift (2006) {tmdb-9615} - {edition-Open Matte} [WEBDL-1080p][EAC3 5.1][h264]-spartanec163.mkv"

do_delete "Chris lower quality: Heat (1995)" "/mnt/synology/rs-movies/Heat (1995)/Heat (1995) {tmdb-949} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Geostorm (2017)" "/mnt/synology/rs-movies/Geostorm (2017)/Geostorm (2017) {tmdb-274855} - [WEBDL-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Judas and the Black Messiah (2021)" "/mnt/synology/rs-movies/Judas and the Black Messiah (2021)/Judas and the Black Messiah (2021) {tmdb-583406} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-naisu.mkv"

do_delete "Chris lower quality: Star Trek The Motion Picture (1979)" "/mnt/synology/rs-movies/Star Trek The Motion Picture (1979)/Star Trek The Motion Picture (1979) {tmdb-152} - [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: Your Lucky Day (2023)" "/mnt/synology/rs-movies/Your Lucky Day (2023)/Your Lucky Day (2023) {tmdb-923993} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: The Hustle (2019)" "/mnt/synology/rs-movies/The Hustle (2019)/The Hustle (2019) {tmdb-449562} - [Bluray-1080p][DTS 5.1][x264]-drones.mkv"

do_delete "Chris lower quality: DC League of Super-Pets (2022)" "/mnt/synology/rs-movies/DC League of Super-Pets (2022)/DC League of Super-Pets (2022) {tmdb-539681} - [HMAX][WEBDL-1080p][AC3 5.1][x264]-DKV.mkv"

do_delete "Chris lower quality: The Laundromat (2019)" "/mnt/synology/rs-movies/The Laundromat (2019)/The Laundromat (2019) {tmdb-517909} - [WEBDL-1080p][EAC3 5.1][x264]-NTG.mkv"

do_delete "Chris lower quality: Halloween (1978)" "/mnt/synology/rs-movies/Halloween (1978)/Halloween (1978) {tmdb-948} - [Bluray-1080p][AC3 5.1][x264]-EbP.mkv"

do_delete "Chris lower quality: Conclave (2024)" "/mnt/synology/rs-movies/Conclave (2024)/Conclave (2024) {tmdb-974576} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Cruel Intentions (1999)" "/mnt/synology/rs-movies/Cruel Intentions (1999)/Cruel Intentions (1999) {tmdb-796} - [Bluray-1080p][AC3 5.1][x264]-TiMELORDS.mkv"

do_delete "Chris lower quality: Sasquatch Sunset (2024)" "/mnt/synology/rs-movies/Sasquatch Sunset (2024)/Sasquatch Sunset (2024) {tmdb-1015634} - [WEBDL-1080p][EAC3 5.1][h264]-AOC.mkv"

do_delete "Chris lower quality: Horizon An American Saga Chapter 1 (2024)" "/mnt/synology/rs-movies/Horizon An American Saga Chapter 1 (2024)/Horizon An American Saga Chapter 1 (2024) {tmdb-932086} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-Kitsune.mkv"

do_delete "Chris lower quality: Abominable (2019)" "/mnt/synology/rs-movies/Abominable (2019)/Abominable (2019) {tmdb-431580} - [WEBDL-1080p][AC3 5.1][h264].mkv"

do_delete "Chris lower quality: Hot Fuzz (2007)" "/mnt/synology/rs-movies/Hot Fuzz (2007)/Hot Fuzz (2007) {tmdb-4638} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: Companion (2025)" "/mnt/synology/rs-movies/Companion (2025)/Companion (2025) {tmdb-1084199} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-APEX.mkv"

do_delete "Chris lower quality: Ambulance (2022)" "/mnt/synology/rs-movies/Ambulance (2022)/Ambulance (2022) {tmdb-763285} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-slot.mkv"

do_delete "Chris lower quality: Pirates of the Caribbean The Curse of the Black Pearl (2003)" "/mnt/synology/rs-movies/Pirates of the Caribbean The Curse of the Black Pearl (2003)/Pirates of the Caribbean The Curse of the Black Pearl (2003) {tmdb-22} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv"

do_delete "Chris lower quality: Clash of the Titans (2010)" "/mnt/synology/rs-movies/Clash of the Titans (2010)/Clash of the Titans (2010) {tmdb-18823} - [Bluray-1080p][AC3 5.1][x264]-EbP.mkv"

do_delete "Chris lower quality: Sanctuary (2023)" "/mnt/synology/rs-movies/Sanctuary (2023)/Sanctuary (2023) {tmdb-870518} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-SCOPE.mkv"

do_delete "Chris lower quality: Strange Days (1995)" "/mnt/synology/rs-movies/Strange Days (1995)/Strange Days (1995) {tmdb-281} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Scrooged (1988)" "/mnt/synology/rs-movies/Scrooged (1988)/Scrooged (1988) {tmdb-9647} - [Bluray-1080p][DTS 5.1][x264]-AMIABLE.mkv"

do_delete "Chris lower quality: Close Encounters of the Third Kind (1977)" "/mnt/synology/rs-movies/Close Encounters of the Third Kind (1977)/Close Encounters of the Third Kind (1977) {tmdb-840} - {edition-Director's Cut} [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv"

do_delete "Chris lower quality: Trainspotting (1996)" "/mnt/synology/rs-movies/Trainspotting (1996)/Trainspotting (1996) {tmdb-627} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: St. Elmos Fire (1985)" "/mnt/synology/rs-movies/St. Elmos Fire (1985)/St. Elmos Fire (1985) {tmdb-11557} - [Bluray-1080p Proper][AC3 5.1][x264]-TFiN.mkv"

do_delete "Chris lower quality: Chef (2014)" "/mnt/synology/rs-movies/Chef (2014)/Chef (2014) {tmdb-212778} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: The Three Musketeers Milady (2023)" "/mnt/synology/rs-movies/The Three Musketeers Milady (2023)/The Three Musketeers Milady (2023) {tmdb-845111} - [Bluray-1080p][EAC3 7.1][x264]-PTer.mkv"

do_delete "Chris lower quality: G20 (2025)" "/mnt/synology/rs-movies/G20 (2025)/G20 (2025) {tmdb-1045938} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-PiRaTeS.mkv"

do_delete "Chris lower quality: Family Switch (2023)" "/mnt/synology/rs-movies/Family Switch (2023)/Family Switch (2023) {tmdb-798021} - [WEBDL-1080p][EAC3 Atmos 5.1][x264]-EDITH.mkv"

do_delete "Chris lower quality: Untold Johnny Football (2023)" "/mnt/synology/rs-movies/Untold Johnny Football (2023)/Untold Johnny Football (2023) {tmdb-1151353} - [WEBDL-1080p][EAC3 5.1][x264]-EDITH.mkv"

do_delete "Chris lower quality: Roma (2018)" "/mnt/synology/rs-movies/Roma (2018)/Roma (2018) {tmdb-426426} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Frank and Penelope (2022)" "/mnt/synology/rs-movies/Frank and Penelope (2022)/Frank and Penelope (2022) {tmdb-899294} - [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Taken 3 (2014)" "/mnt/synology/rs-movies/Taken 3 (2014)/Taken 3 (2014) {tmdb-260346} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Maleficent Mistress of Evil (2019)" "/mnt/synology/rs-movies/Maleficent Mistress of Evil (2019)/Maleficent Mistress of Evil (2019) {tmdb-420809} - [WEBDL-1080p][AC3 5.1][h264].mkv"

do_delete "Chris lower quality: Enchanted (2007)" "/mnt/synology/rs-movies/Enchanted (2007)/Enchanted (2007) {tmdb-4523} - [Bluray-1080p Proper REAL][AC3 5.1][x264]-PHOBOS.mkv"

do_delete "Chris lower quality: The Way of the Dragon (1972)" "/mnt/synology/rs-movies/The Way of the Dragon (1972)/The Way of the Dragon (1972) {tmdb-9462} - {edition-Remastered} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Noah (2014)" "/mnt/synology/rs-movies/Noah (2014)/Noah (2014) {tmdb-86834} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Forrest Gump (1994)" "/mnt/synology/rs-movies/Forrest Gump (1994)/Forrest Gump (1994) {tmdb-13} - [WEBDL-1080p][DTS-ES 6.1][HDR10][x265]-D-Z0N3.mkv"

do_delete "Chris lower quality: One Hundred and One Dalmatians (1961)" "/mnt/synology/rs-movies/One Hundred and One Dalmatians (1961)/One Hundred and One Dalmatians (1961) {tmdb-12230} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Batman Soul of the Dragon (2021)" "/mnt/synology/rs-movies/Batman Soul of the Dragon (2021)/Batman Soul of the Dragon (2021) {tmdb-732450} - [WEBDL-1080p][EAC3 5.1][x264]-CMRG.mkv"

do_delete "Chris lower quality: O Brother Where Art Thou (2000)" "/mnt/synology/rs-movies/O Brother Where Art Thou (2000)/O Brother Where Art Thou (2000) {tmdb-134} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: The Place Beyond the Pines (2013)" "/mnt/synology/rs-movies/The Place Beyond the Pines (2013)/The Place Beyond the Pines (2013) {tmdb-97367} - [Bluray-1080p][AC3 5.1][x264]-EbP.mkv"

do_delete "Chris lower quality: Sister Death (2023)" "/mnt/synology/rs-movies/Sister Death (2023)/Sister Death (2023) {tmdb-955531} - [WEBDL-1080p][EAC3 Atmos 5.1][x264]-AOC.mp4"

do_delete "Chris lower quality: Hellraiser (2022)" "/mnt/synology/rs-movies/Hellraiser (2022)/Hellraiser (2022) {tmdb-338947} - [Hulu][WEBDL-1080p][EAC3 5.1][h264]-HELLRAiZER.mkv"

do_delete "Chris lower quality: A Clockwork Orange (1971)" "/mnt/synology/rs-movies/A Clockwork Orange (1971)/A Clockwork Orange (1971) {tmdb-185} - [Bluray-1080p Proper][DTS 5.1][x264]-SADPANDA.mkv"

do_delete "Chris lower quality: Babylon (2022)" "/mnt/synology/rs-movies/Babylon (2022)/Babylon (2022) {tmdb-615777} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Trollhunters Rise of the Titans (2021)" "/mnt/synology/rs-movies/Trollhunters Rise of the Titans (2021)/Trollhunters Rise of the Titans (2021) {tmdb-730840} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-EVO.mkv"

do_delete "Chris lower quality: Twister (1996)" "/mnt/synology/rs-movies/Twister (1996)/Twister (1996) {tmdb-664} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: The Naked Gun From the Files of Police Squad! (1988)" "/mnt/synology/rs-movies/The Naked Gun From the Files of Police Squad! (1988)/The Naked Gun From the Files of Police Squad! (1988) {tmdb-37136} - [Bluray-1080p][DTS 5.1][x264]-FoRM.mkv"

do_delete "Chris lower quality: The Last Stop in Yuma County (2024)" "/mnt/synology/rs-movies/The Last Stop in Yuma County (2024)/The Last Stop in Yuma County (2024) {tmdb-1047020} - [AMZN MA][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: A Man Called Otto (2022)" "/mnt/synology/rs-movies/A Man Called Otto (2022)/A Man Called Otto (2022) {tmdb-937278} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Five Nights at Freddy's (2023)" "/mnt/synology/rs-movies/Five Nights at Freddy's (2023)/Five Nights at Freddy's (2023) {tmdb-507089} - [PCOK][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Happy Gilmore (1996)" "/mnt/synology/rs-movies/Happy Gilmore (1996)/Happy Gilmore (1996) {tmdb-9614} - [Bluray-1080p][DTS 5.1][x264]-LCHD.mkv"

do_delete "Chris lower quality: Avatar The Way of Water (2022)" "/mnt/synology/rs-movies/Avatar The Way of Water (2022)/Avatar The Way of Water (2022) {tmdb-76600} - [AMZN][WEBDL-1080p Proper][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Chicken Run Dawn of the Nugget (2023)" "/mnt/synology/rs-movies/Chicken Run Dawn of the Nugget (2023)/Chicken Run Dawn of the Nugget (2023) {tmdb-520758} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: True Lies (1994)" "/mnt/synology/rs-movies/True Lies (1994)/True Lies (1994) {tmdb-36955} - [Bluray-1080p][EAC3 5.1][x264].mkv"

do_delete "Chris lower quality: Rounders (1998)" "/mnt/synology/rs-movies/Rounders (1998)/Rounders (1998) {tmdb-10220} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Nanny (2022)" "/mnt/synology/rs-movies/Nanny (2022)/Nanny (2022) {tmdb-843932} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Land of Bad (2024)" "/mnt/synology/rs-movies/Land of Bad (2024)/Land of Bad (2024) {tmdb-969492} - [WEBDL-1080p Proper][EAC3 5.1][h264]-RABBITS.mkv"

do_delete "Chris lower quality: Return of the Jedi (1983)" "/mnt/synology/rs-movies/Return of the Jedi (1983)/Return of the Jedi (1983) {tmdb-1892} - [Bluray-1080p][EAC3 7.1][x264].mkv"

do_delete "Chris lower quality: It Chapter Two (2019)" "/mnt/synology/rs-movies/It Chapter Two (2019)/It Chapter Two (2019) {tmdb-474350} - [WEBDL-1080p][AC3 5.1][h264].mkv"

do_delete "Chris lower quality: The Lord of the Rings The Return of the King (2003)" "/mnt/synology/rs-movies/The Lord of the Rings The Return of the King (2003)/The Lord of the Rings The Return of the King (2003) {tmdb-122} - [Bluray-1080p][DTS-ES 6.1][x264].mkv"

do_delete "Chris lower quality: Legion of Super-Heroes (2023)" "/mnt/synology/rs-movies/Legion of Super-Heroes (2023)/Legion of Super-Heroes (2023) {tmdb-1003580} - [WEBDL-1080p][AC3 5.1][x264]-DKV.mkv"

do_delete "Chris lower quality: Donnie Brasco (1997)" "/mnt/synology/rs-movies/Donnie Brasco (1997)/Donnie Brasco (1997) {tmdb-9366} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Wicked (2024)" "/mnt/synology/rs-movies/Wicked (2024)/Wicked (2024) {tmdb-402431} - [MA][WEBRip-1080p][Opus 5.1][AV1]-RAV1NE.mkv"

do_delete "Chris lower quality: Shrek 2 (2004)" "/mnt/synology/rs-movies/Shrek 2 (2004)/Shrek 2 (2004) {tmdb-809} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Tomb Raider (2018)" "/mnt/synology/rs-movies/Tomb Raider (2018)/Tomb Raider (2018) {tmdb-338970} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Public Enemies (2009)" "/mnt/synology/rs-movies/Public Enemies (2009)/Public Enemies (2009) {tmdb-11322} - [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: Ghostbusters Afterlife (2021)" "/mnt/synology/rs-movies/Ghostbusters Afterlife (2021)/Ghostbusters Afterlife (2021) {tmdb-425909} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Arthur the King (2024)" "/mnt/synology/rs-movies/Arthur the King (2024)/Arthur the King (2024) {tmdb-618588} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: The Last Voyage of the Demeter (2023)" "/mnt/synology/rs-movies/The Last Voyage of the Demeter (2023)/The Last Voyage of the Demeter (2023) {tmdb-635910} - [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Harlem Nights (1989)" "/mnt/synology/rs-movies/Harlem Nights (1989)/Harlem Nights (1989) {tmdb-9085} - [WEBDL-1080p][AC3 5.1][x264]-DiMEPiECE.mkv"

do_delete "Chris lower quality: Starsky and Hutch (2004)" "/mnt/synology/rs-movies/Starsky and Hutch (2004)/Starsky and Hutch (2004) {tmdb-9384} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Kinds of Kindness (2024)" "/mnt/synology/rs-movies/Kinds of Kindness (2024)/Kinds of Kindness (2024) {tmdb-1029955} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: The Royal Treatment (2022)" "/mnt/synology/rs-movies/The Royal Treatment (2022)/The Royal Treatment (2022) {tmdb-790142} - [WEBDL-1080p][EAC3 Atmos 5.1][x264]-cupcakes.mkv"

do_delete "Chris lower quality: Breakfast on Pluto (2005)" "/mnt/synology/rs-movies/Breakfast on Pluto (2005)/Breakfast on Pluto (2005) {tmdb-1420} - [AMZN][WEBDL-1080p][EAC3 5.1][x264]-ABM.mkv"

do_delete "Chris lower quality: Indiana Jones and the Temple of Doom (1984)" "/mnt/synology/rs-movies/Indiana Jones and the Temple of Doom (1984)/Indiana Jones and the Temple of Doom (1984) {tmdb-87} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Animal House (1978)" "/mnt/synology/rs-movies/Animal House (1978)/Animal House (1978) {tmdb-8469} - [Bluray-1080p][EAC3 7.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: Over the Hedge (2006)" "/mnt/synology/rs-movies/Over the Hedge (2006)/Over the Hedge (2006) {tmdb-7518} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Cooties (2014)" "/mnt/synology/rs-movies/Cooties (2014)/Cooties (2014) {tmdb-241843} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Wifelike (2022)" "/mnt/synology/rs-movies/Wifelike (2022)/Wifelike (2022) {tmdb-1001835} - [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: The End We Start From (2023)" "/mnt/synology/rs-movies/The End We Start From (2023)/The End We Start From (2023) {tmdb-973778} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Beverly Hills Cop II (1987)" "/mnt/synology/rs-movies/Beverly Hills Cop II (1987)/Beverly Hills Cop II (1987) {tmdb-96} - [Bluray-1080p][AC3 2.0][x264].mkv"

do_delete "Chris lower quality: John Wick Chapter 4 (2023)" "/mnt/synology/rs-movies/John Wick Chapter 4 (2023)/John Wick Chapter 4 (2023) {tmdb-603692} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-WDYM.mkv"

do_delete "Chris lower quality: Long Gone Heroes (2024)" "/mnt/synology/rs-movies/Long Gone Heroes (2024)/Long Gone Heroes (2024) {tmdb-1276825} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Mr. Brooks (2007)" "/mnt/synology/rs-movies/Mr. Brooks (2007)/Mr. Brooks (2007) {tmdb-3432} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-NAN0.mkv"

do_delete "Chris lower quality: Crimes of the Future (2022)" "/mnt/synology/rs-movies/Crimes of the Future (2022)/Crimes of the Future (2022) {tmdb-819876} - [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: The Hunger Games The Ballad of Songbirds and Snakes (2023)" "/mnt/synology/rs-movies/The Hunger Games The Ballad of Songbirds and Snakes (2023)/The Hunger Games The Ballad of Songbirds and Snakes (2023) {tmdb-695721} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Showgirls (1995)" "/mnt/synology/rs-movies/Showgirls (1995)/Showgirls (1995) {tmdb-10802} - [Bluray-1080p][EAC3 5.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: Big George Foreman (2023)" "/mnt/synology/rs-movies/Big George Foreman (2023)/Big George Foreman (2023) {tmdb-878361} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Inside (2023)" "/mnt/synology/rs-movies/Inside (2023)/Inside (2023) {tmdb-958196} - [WEBDL-1080p][AC3 5.1][h264]-SLOT.mkv"

do_delete "Chris lower quality: Kill Bill Vol. 2 (2004)" "/mnt/synology/rs-movies/Kill Bill Vol. 2 (2004)/Kill Bill Vol. 2 (2004) {tmdb-393} - {edition-Open Matte} [WEBDL-1080p][EAC3 5.1][h264]-spartanec163.mkv"

do_delete "Chris lower quality: Saw (2004)" "/mnt/synology/rs-movies/Saw (2004)/Saw (2004) {tmdb-176} - [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv"

do_delete "Chris lower quality: Cinderella (2021)" "/mnt/synology/rs-movies/Cinderella (2021)/Cinderella (2021) {tmdb-593910} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Shang-Chi and the Legend of the Ten Rings (2021)" "/mnt/synology/rs-movies/Shang-Chi and the Legend of the Ten Rings (2021)/Shang-Chi and the Legend of the Ten Rings (2021) {tmdb-566525} - [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv"

do_delete "Chris lower quality: The Funhouse Massacre (2015)" "/mnt/synology/rs-movies/The Funhouse Massacre (2015)/The Funhouse Massacre (2015) {tmdb-363889} - [Bluray-1080p][DTS 5.1][x264]-SADPANDA.mkv"

do_delete "Chris lower quality: Frankenweenie (2012)" "/mnt/synology/rs-movies/Frankenweenie (2012)/Frankenweenie (2012) {tmdb-62214} - [HDTV-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: The Northman (2022)" "/mnt/synology/rs-movies/The Northman (2022)/The Northman (2022) {tmdb-639933} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: Goldfinger (1964)" "/mnt/synology/rs-movies/Goldfinger (1964)/Goldfinger (1964) {tmdb-658} - [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv"

do_delete "Chris lower quality: Cinderella II Dreams Come True (2002)" "/mnt/synology/rs-movies/Cinderella II Dreams Come True (2002)/Cinderella II Dreams Come True (2002) {tmdb-14128} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Lean On Me (1989)" "/mnt/synology/rs-movies/Lean On Me (1989)/Lean On Me (1989) {tmdb-14621} - [AMZN][WEBDL-1080p][EAC3 2.0][x264]-alfaHD.mkv"

do_delete "Chris lower quality: Stakeout (1987)" "/mnt/synology/rs-movies/Stakeout (1987)/Stakeout (1987) {tmdb-10859} - [WEBDL-1080p][EAC3 5.1][x264]-AM.mkv"

do_delete "Chris lower quality: M3GAN 2.0 (2025)" "/mnt/synology/rs-movies/M3GAN 2.0 (2025)/M3GAN 2.0 (2025) {tmdb-1071585} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-KyoGo.mkv"

do_delete "Chris lower quality: The Killer (2023)" "/mnt/synology/rs-movies/The Killer (2023)/The Killer (2023) {tmdb-800158} - [NF][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Abigail (2024)" "/mnt/synology/rs-movies/Abigail (2024)/Abigail (2024) {tmdb-1111873} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Courage Under Fire (1996)" "/mnt/synology/rs-movies/Courage Under Fire (1996)/Courage Under Fire (1996) {tmdb-10684} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: No Man of God (2021)" "/mnt/synology/rs-movies/No Man of God (2021)/No Man of God (2021) {tmdb-716594} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: Star Trek First Contact (1996)" "/mnt/synology/rs-movies/Star Trek First Contact (1996)/Star Trek First Contact (1996) {tmdb-199} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv"

do_delete "Chris lower quality: Promising Young Woman (2020)" "/mnt/synology/rs-movies/Promising Young Woman (2020)/Promising Young Woman (2020) {tmdb-582014} - [WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: Paws of Fury The Legend of Hank (2022)" "/mnt/synology/rs-movies/Paws of Fury The Legend of Hank (2022)/Paws of Fury The Legend of Hank (2022) {tmdb-366672} - [WEBDL-1080p][EAC3 5.1][h264]-SMURF.mkv"

do_delete "Chris lower quality: Den of Thieves 2 Pantera (2025)" "/mnt/synology/rs-movies/Den of Thieves 2 Pantera (2025)/Den of Thieves 2 Pantera (2025) {tmdb-604685} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-APEX.mkv"

do_delete "Chris lower quality: Timecop (1994)" "/mnt/synology/rs-movies/Timecop (1994)/Timecop (1994) {tmdb-8831} - [Bluray-1080p][DTS 5.1][x264]-FoRM.mkv"

do_delete "Chris lower quality: Lara Croft Tomb Raider The Cradle of Life (2003)" "/mnt/synology/rs-movies/Lara Croft Tomb Raider The Cradle of Life (2003)/Lara Croft Tomb Raider The Cradle of Life (2003) {tmdb-1996} - [HDTV-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Copshop (2021)" "/mnt/synology/rs-movies/Copshop (2021)/Copshop (2021) {tmdb-738652} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Spider-Man 2 (2004)" "/mnt/synology/rs-movies/Spider-Man 2 (2004)/Spider-Man 2 (2004) {tmdb-558} - [Bluray-1080p][EAC3 7.1][HDR10][x265]-NCmt.mkv"

do_delete "Chris lower quality: Gods of Egypt (2016)" "/mnt/synology/rs-movies/Gods of Egypt (2016)/Gods of Egypt (2016) {tmdb-205584} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Freddy vs. Jason (2003)" "/mnt/synology/rs-movies/Freddy vs. Jason (2003)/Freddy vs. Jason (2003) {tmdb-6466} - {edition-Open Matte} [WEBDL-1080p][EAC3 5.1][h264]-spartanec163.mkv"

do_delete "Chris lower quality: Man of the Year (2006)" "/mnt/synology/rs-movies/Man of the Year (2006)/Man of the Year (2006) {tmdb-9895} - [AMZN][WEBRip-1080p][EAC3 5.1][x264]-monkee.mkv"

do_delete "Chris lower quality: Death to Smoochy (2002)" "/mnt/synology/rs-movies/Death to Smoochy (2002)/Death to Smoochy (2002) {tmdb-9275} - [Bluray-1080p][EAC3 5.1][x264]-MaG.mkv"

do_delete "Chris lower quality: T2 Trainspotting (2017)" "/mnt/synology/rs-movies/T2 Trainspotting (2017)/T2 Trainspotting (2017) {tmdb-180863} - [Bluray-1080p][DTS 5.1][x264]-ZQ.mkv"

do_delete "Chris lower quality: Early Man (2018)" "/mnt/synology/rs-movies/Early Man (2018)/Early Man (2018) {tmdb-387592} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Crazy Rich Asians (2018)" "/mnt/synology/rs-movies/Crazy Rich Asians (2018)/Crazy Rich Asians (2018) {tmdb-455207} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Highlander II The Quickening (1991)" "/mnt/synology/rs-movies/Highlander II The Quickening (1991)/Highlander II The Quickening (1991) {tmdb-8010} - [Bluray-1080p][EAC3 5.1][x264]-eckomega.mkv"

do_delete "Chris lower quality: Young Frankenstein (1974)" "/mnt/synology/rs-movies/Young Frankenstein (1974)/Young Frankenstein (1974) {tmdb-3034} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: South Park Post COVID The Return of COVID (2021)" "/mnt/synology/rs-movies/South Park Post COVID The Return of COVID (2021)/South Park Post COVID The Return of COVID (2021) {tmdb-874300} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: Space Cowboys (2000)" "/mnt/synology/rs-movies/Space Cowboys (2000)/Space Cowboys (2000) {tmdb-5551} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Be My Valentine Charlie Brown (1975)" "/mnt/synology/rs-movies/Be My Valentine Charlie Brown (1975)/Be My Valentine Charlie Brown (1975) {tmdb-31726} - [ATVP][WEBDL-1080p][AC3 5.1][h264]-SiGLA.mkv"

do_delete "Chris lower quality: Deadly Friend (1986)" "/mnt/synology/rs-movies/Deadly Friend (1986)/Deadly Friend (1986) {tmdb-33278} - [AMZN][WEBDL-1080p][EAC3 2.0][h264]-PHOENiX.mkv"

do_delete "Chris lower quality: The Blind Side (2009)" "/mnt/synology/rs-movies/The Blind Side (2009)/The Blind Side (2009) {tmdb-22881} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-GPRS.mkv"

do_delete "Chris lower quality: The Hippopotamus (2017)" "/mnt/synology/rs-movies/The Hippopotamus (2017)/The Hippopotamus (2017) {tmdb-442750} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-GPRS.mkv"

do_delete "Chris lower quality: A Passage to India (1984)" "/mnt/synology/rs-movies/A Passage to India (1984)/A Passage to India (1984) {tmdb-15927} - [Bluray-1080p Proper][AC3 5.1][x264]-Japhson.mkv"

do_delete "Chris lower quality: Oppenheimer (2023)" "/mnt/synology/rs-movies/Oppenheimer (2023)/Oppenheimer (2023) {tmdb-872585} - [Remux-1080p][DTS-HD MA 5.1][AVC]-FraMeSToR.mkv"

do_delete "Chris lower quality: Harry Potter and the Deathly Hallows Part 2 (2011)" "/mnt/synology/rs-movies/Harry Potter and the Deathly Hallows Part 2 (2011)/Harry Potter and the Deathly Hallows Part 2 (2011) {tmdb-12445} - [Bluray-1080p][AC3 2.0][h264]-RMXTRAS.mkv"

do_delete "Chris lower quality: My Fair Lady (1964)" "/mnt/synology/rs-movies/My Fair Lady (1964)/My Fair Lady (1964) {tmdb-11113} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Beast of War (2025)" "/mnt/synology/rs-movies/Beast of War (2025)/Beast of War (2025) {tmdb-1244531} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-KyoGo.mkv"

do_delete "Chris lower quality: The Last Stand (2013)" "/mnt/synology/rs-movies/The Last Stand (2013)/The Last Stand (2013) {tmdb-76640} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: RocknRolla (2008)" "/mnt/synology/rs-movies/RocknRolla (2008)/RocknRolla (2008) {tmdb-13809} - [WEBDL-1080p][TrueHD 5.1][VC1].mkv"

do_delete "Chris lower quality: Dune (1984)" "/mnt/synology/rs-movies/Dune (1984)/Dune (1984) {tmdb-841} - [Bluray-1080p][DTS 5.1][x264]-HiDt.mkv"

do_delete "Chris lower quality: Watchmen Chapter II (2024)" "/mnt/synology/rs-movies/Watchmen Chapter II (2024)/Watchmen Chapter II (2024) {tmdb-1299652} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Retribution (2023)" "/mnt/synology/rs-movies/Retribution (2023)/Retribution (2023) {tmdb-762430} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-IWiLLFiNDyouANDiWiLLKiLLYOU.mkv"

do_delete "Chris lower quality: 80 for Brady (2023)" "/mnt/synology/rs-movies/80 for Brady (2023)/80 for Brady (2023) {tmdb-942922} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: The Front Room (2024)" "/mnt/synology/rs-movies/The Front Room (2024)/The Front Room (2024) {tmdb-1016848} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Women Talking (2022)" "/mnt/synology/rs-movies/Women Talking (2022)/Women Talking (2022) {tmdb-777245} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Space Jam A New Legacy (2021)" "/mnt/synology/rs-movies/Space Jam A New Legacy (2021)/Space Jam A New Legacy (2021) {tmdb-379686} - [HMAX][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv"

do_delete "Chris lower quality: How to Train Your Dragon 2 (2014)" "/mnt/synology/rs-movies/How to Train Your Dragon 2 (2014)/How to Train Your Dragon 2 (2014) {tmdb-82702} - [Bluray-1080p][DTS-ES 5.1][x264].mkv"

do_delete "Chris lower quality: Mr. Monks Last Case A Monk Movie (2023)" "/mnt/synology/rs-movies/Mr. Monks Last Case A Monk Movie (2023)/Mr. Monks Last Case A Monk Movie (2023) {tmdb-1100795} - [WEBDL-1080p][EAC3 5.1][h264]-DiMEPiECE.mkv"

do_delete "Chris lower quality: The Long Kiss Goodnight (1996)" "/mnt/synology/rs-movies/The Long Kiss Goodnight (1996)/The Long Kiss Goodnight (1996) {tmdb-11412} - [Bluray-1080p][AC3 5.1][x264]-ETH.mkv"

do_delete "Chris lower quality: The Strangers Chapter 1 (2024)" "/mnt/synology/rs-movies/The Strangers Chapter 1 (2024)/The Strangers Chapter 1 (2024) {tmdb-1010600} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Gangster Squad (2013)" "/mnt/synology/rs-movies/Gangster Squad (2013)/Gangster Squad (2013) {tmdb-82682} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: A Good Person (2023)" "/mnt/synology/rs-movies/A Good Person (2023)/A Good Person (2023) {tmdb-800787} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Once Upon a Time in the West (1968)" "/mnt/synology/rs-movies/Once Upon a Time in the West (1968)/Once Upon a Time in the West (1968) {tmdb-335} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Red Heat (1988)" "/mnt/synology/rs-movies/Red Heat (1988)/Red Heat (1988) {tmdb-9604} - [Bluray-1080p][DTS-HD MA 5.1][x264]-BluEvo.mkv"

do_delete "Chris lower quality: Black Lotus (2023)" "/mnt/synology/rs-movies/Black Lotus (2023)/Black Lotus (2023) {tmdb-996154} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-DarQ.mkv"

do_delete "Chris lower quality: Wrath of the Titans (2012)" "/mnt/synology/rs-movies/Wrath of the Titans (2012)/Wrath of the Titans (2012) {tmdb-57165} - [WEBDL-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Halloween Kills (2021)" "/mnt/synology/rs-movies/Halloween Kills (2021)/Halloween Kills (2021) {tmdb-610253} - [PCOK][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Baby Driver (2017)" "/mnt/synology/rs-movies/Baby Driver (2017)/Baby Driver (2017) {tmdb-339403} - [Bluray-1080p][EAC3 7.1][HDR10][x265]-NCmt.mkv"

do_delete "Chris lower quality: Resident Evil Death Island (2023)" "/mnt/synology/rs-movies/Resident Evil Death Island (2023)/Resident Evil Death Island (2023) {tmdb-1083862} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-KBOX.mkv"

do_delete "Chris lower quality: Star Wars Episode I The Phantom Menace (1999)" "/mnt/synology/rs-movies/Star Wars Episode I The Phantom Menace (1999)/Star Wars Episode I The Phantom Menace (1999) {tmdb-1893} - [Bluray-1080p][EAC3 7.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: Code Name Banshee (2022)" "/mnt/synology/rs-movies/Code Name Banshee (2022)/Code Name Banshee (2022) {tmdb-916719} - [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: The Greatest Showman (2017)" "/mnt/synology/rs-movies/The Greatest Showman (2017)/The Greatest Showman (2017) {tmdb-316029} - [Bluray-1080p][DTS-ES 5.1][x264].mkv"

do_delete "Chris lower quality: Zombieland (2009)" "/mnt/synology/rs-movies/Zombieland (2009)/Zombieland (2009) {tmdb-19908} - {edition-Open Matte} [WEBDL-1080p][EAC3 5.1][h264]-spartanec163.mkv"

do_delete "Chris lower quality: Mission Impossible Rogue Nation (2015)" "/mnt/synology/rs-movies/Mission Impossible Rogue Nation (2015)/Mission Impossible Rogue Nation (2015) {tmdb-177677} - [WEBDL-1080p][AC3 2.0][h264]-TWA.mkv"

do_delete "Chris lower quality: All of Us Strangers (2023)" "/mnt/synology/rs-movies/All of Us Strangers (2023)/All of Us Strangers (2023) {tmdb-994108} - [Bluray-1080p][EAC3 5.1][x264]-refresh.mkv"

do_delete "Chris lower quality: The Lion in Winter (1968)" "/mnt/synology/rs-movies/The Lion in Winter (1968)/The Lion in Winter (1968) {tmdb-18988} - [Bluray-1080p][FLAC 2.0][x264]-ADE.mkv"

do_delete "Chris lower quality: Scream VI (2023)" "/mnt/synology/rs-movies/Scream VI (2023)/Scream VI (2023) {tmdb-934433} - [AMZN][WEBDL-1080p Proper][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Coming 2 America (2021)" "/mnt/synology/rs-movies/Coming 2 America (2021)/Coming 2 America (2021) {tmdb-484718} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Full Metal Jacket (1987)" "/mnt/synology/rs-movies/Full Metal Jacket (1987)/Full Metal Jacket (1987) {tmdb-600} - {edition-Remastered} [Bluray-1080p][DTS 5.1][x264]-FoRM.mkv"

do_delete "Chris lower quality: Overboard (2018)" "/mnt/synology/rs-movies/Overboard (2018)/Overboard (2018) {tmdb-454619} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: 1992 (2024)" "/mnt/synology/rs-movies/1992 (2024)/1992 (2024) {tmdb-413846} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Battleship (2012)" "/mnt/synology/rs-movies/Battleship (2012)/Battleship (2012) {tmdb-44833} - [Bluray-1080p][DTS 5.1][HDR10][x265]-HQMUX.mkv"

do_delete "Chris lower quality: Bad Boys (1995)" "/mnt/synology/rs-movies/Bad Boys (1995)/Bad Boys (1995) {tmdb-9737} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: 300 Rise of an Empire (2014)" "/mnt/synology/rs-movies/300 Rise of an Empire (2014)/300 Rise of an Empire (2014) {tmdb-53182} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Aladdin and the King of Thieves (1996)" "/mnt/synology/rs-movies/Aladdin and the King of Thieves (1996)/Aladdin and the King of Thieves (1996) {tmdb-11238} - [Bluray-1080p][AC3 5.1][x264]-OB1.mkv"

do_delete "Chris lower quality: The Lego Movie 2 The Second Part (2019)" "/mnt/synology/rs-movies/The Lego Movie 2 The Second Part (2019)/The Lego Movie 2 The Second Part (2019) {tmdb-280217} - [Bluray-1080p][AC3 5.1][x264]-HDChina.mkv"

do_delete "Chris lower quality: Trolls (2016)" "/mnt/synology/rs-movies/Trolls (2016)/Trolls (2016) {tmdb-136799} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-DKV.mkv"

do_delete "Chris lower quality: Rebel Moon Part One A Child of Fire (2023)" "/mnt/synology/rs-movies/Rebel Moon Part One A Child of Fire (2023)/Rebel Moon Part One A Child of Fire (2023) {tmdb-848326} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Mufasa The Lion King (2024)" "/mnt/synology/rs-movies/Mufasa The Lion King (2024)/Mufasa The Lion King (2024) {tmdb-762509} - [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-KiNGOFTHEJUNGLE.mkv"

do_delete "Chris lower quality: Rambo First Blood Part II (1985)" "/mnt/synology/rs-movies/Rambo First Blood Part II (1985)/Rambo First Blood Part II (1985) {tmdb-1369} - [PMTP][WEBDL-1080p][EAC3 5.1][x264]-GRiMM.mkv"

do_delete "Chris lower quality: DuckTales The Movie Treasure of the Lost Lamp (1990)" "/mnt/synology/rs-movies/DuckTales The Movie Treasure of the Lost Lamp (1990)/DuckTales The Movie Treasure of the Lost Lamp (1990) {tmdb-10837} - [WEBDL-1080p][AAC 2.0][h264].mkv"

do_delete "Chris lower quality: What Happened to Monday (2017)" "/mnt/synology/rs-movies/What Happened to Monday (2017)/What Happened to Monday (2017) {tmdb-406990} - [WEBDL-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Immaculate (2024)" "/mnt/synology/rs-movies/Immaculate (2024)/Immaculate (2024) {tmdb-1041613} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Alien Nation (1988)" "/mnt/synology/rs-movies/Alien Nation (1988)/Alien Nation (1988) {tmdb-10128} - [Bluray-1080p][DTS 5.1][x264]-FGT.mkv"

do_delete "Chris lower quality: Robot Dreams (2023)" "/mnt/synology/rs-movies/Robot Dreams (2023)/Robot Dreams (2023) {tmdb-838240} - [WEBDL-1080p][AC3 2.0][h264].mkv"

do_delete "Chris lower quality: The Adventures of Huck Finn (1993)" "/mnt/synology/rs-movies/The Adventures of Huck Finn (1993)/The Adventures of Huck Finn (1993) {tmdb-34723} - [DSNP][WEBDL-1080p][EAC3 5.1][h264]-PD.mkv"

do_delete "Chris lower quality: Crank High Voltage (2009)" "/mnt/synology/rs-movies/Crank High Voltage (2009)/Crank High Voltage (2009) {tmdb-15092} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-GPRS.mkv"

do_delete "Chris lower quality: Hatchet (2006)" "/mnt/synology/rs-movies/Hatchet (2006)/Hatchet (2006) {tmdb-11908} - {edition-Unrated} [Bluray-1080p][AC3 5.1][x264]-MaG.mkv"

do_delete "Chris lower quality: Robin Hood Prince of Thieves (1991)" "/mnt/synology/rs-movies/Robin Hood Prince of Thieves (1991)/Robin Hood Prince of Thieves (1991) {tmdb-8367} - {edition-Extended Cut} [Bluray-1080p][AC3 5.1][x264]-CRiSC.mkv"

do_delete "Chris lower quality: Lady and the Tramp II Scamps Adventure (2001)" "/mnt/synology/rs-movies/Lady and the Tramp II Scamps Adventure (2001)/Lady and the Tramp II Scamps Adventure (2001) {tmdb-18269} - [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv"

do_delete "Chris lower quality: Six Days Seven Nights (1998)" "/mnt/synology/rs-movies/Six Days Seven Nights (1998)/Six Days Seven Nights (1998) {tmdb-6068} - [WEBDL-1080p][EAC3 5.1][h264]-DiMEPiECE.mkv"

do_delete "Chris lower quality: Upgrade (2018)" "/mnt/synology/rs-movies/Upgrade (2018)/Upgrade (2018) {tmdb-500664} - [Bluray-1080p Proper][DTS 5.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: Downton Abbey The Grand Finale (2025)" "/mnt/synology/rs-movies/Downton Abbey The Grand Finale (2025)/Downton Abbey The Grand Finale (2025) {tmdb-1289936} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-ETHEL.mkv"

do_delete "Chris lower quality: The Pink Panther 2 (2009)" "/mnt/synology/rs-movies/The Pink Panther 2 (2009)/The Pink Panther 2 (2009) {tmdb-15159} - [WEBDL-1080p][EAC3 5.1][x264]-GPRS.mkv"

do_delete "Chris lower quality: The Smashing Machine (2025)" "/mnt/synology/rs-movies/The Smashing Machine (2025)/The Smashing Machine (2025) {tmdb-760329} - [Bluray-1080p][EAC3 Atmos 5.1][DV HDR10Plus][x265]-SM737.mkv"

do_delete "Chris lower quality: The Toxic Avenger Unrated (2025)" "/mnt/synology/rs-movies/The Toxic Avenger Unrated (2025)/The Toxic Avenger Unrated (2025) {tmdb-338969} - {edition-Unrated} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-HONE.mkv"

do_delete "Chris lower quality: Hacksaw Ridge (2016)" "/mnt/synology/rs-movies/Hacksaw Ridge (2016)/Hacksaw Ridge (2016) {tmdb-324786} - [Bluray-1080p][EAC3 7.1][HDR10][x265]-D-Z0N3.mkv"

do_delete "Chris lower quality: Herbie Fully Loaded (2005)" "/mnt/synology/rs-movies/Herbie Fully Loaded (2005)/Herbie Fully Loaded (2005) {tmdb-11451} - [WEBDL-1080p][EAC3 5.1][h264]-monkee.mkv"

do_delete "Chris lower quality: The Nun II (2023)" "/mnt/synology/rs-movies/The Nun II (2023)/The Nun II (2023) {tmdb-968051} - [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: The Man Who Fell to Earth (1976)" "/mnt/synology/rs-movies/The Man Who Fell to Earth (1976)/The Man Who Fell to Earth (1976) {tmdb-991} - [Bluray-1080p][AC3 2.0][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: On the Rocks (2020)" "/mnt/synology/rs-movies/On the Rocks (2020)/On the Rocks (2020) {tmdb-575417} - [WEBRip-1080p][DTS-HD MA 5.1][h264]-CREATiVE24.mkv"

do_delete "Chris lower quality: Santa Sangre (1989)" "/mnt/synology/rs-movies/Santa Sangre (1989)/Santa Sangre (1989) {tmdb-19236} - [Bluray-1080p][DTS 2.0][x264]-aAF.mkv"

do_delete "Chris lower quality: Spider-Man Homecoming (2017)" "/mnt/synology/rs-movies/Spider-Man Homecoming (2017)/Spider-Man Homecoming (2017) {tmdb-315635} - [Bluray-1080p][EAC3 7.1][HDR10][x265]-NCmt.mkv"

do_delete "Chris lower quality: Thor Love and Thunder (2022)" "/mnt/synology/rs-movies/Thor Love and Thunder (2022)/Thor Love and Thunder (2022) {tmdb-616037} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: HIM (2025)" "/mnt/synology/rs-movies/HIM (2025)/HIM (2025) {tmdb-986097} - [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-Draken02.mkv"

do_delete "Chris lower quality: Terminator Dark Fate (2019)" "/mnt/synology/rs-movies/Terminator Dark Fate (2019)/Terminator Dark Fate (2019) {tmdb-290859} - [WEBDL-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: 31 (2016)" "/mnt/synology/rs-movies/31 (2016)/31 (2016) {tmdb-284564} - [Bluray-1080p][DTS 5.1][x264]-GECKOS.mkv"

do_delete "Chris lower quality: Jurassic Park III (2001)" "/mnt/synology/rs-movies/Jurassic Park III (2001)/Jurassic Park III (2001) {tmdb-331} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Panama (2022)" "/mnt/synology/rs-movies/Panama (2022)/Panama (2022) {tmdb-628878} - [MA][WEBDL-1080p][AC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: Tower Heist (2011)" "/mnt/synology/rs-movies/Tower Heist (2011)/Tower Heist (2011) {tmdb-59108} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Reality (2023)" "/mnt/synology/rs-movies/Reality (2023)/Reality (2023) {tmdb-985617} - [WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Absolute Power (1997)" "/mnt/synology/rs-movies/Absolute Power (1997)/Absolute Power (1997) {tmdb-66} - [HDTV-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Red Dawn (1984)" "/mnt/synology/rs-movies/Red Dawn (1984)/Red Dawn (1984) {tmdb-1880} - [Bluray-1080p][DTS 5.1][x264]-hd4u.mkv"

do_delete "Chris lower quality: Kimi (2022)" "/mnt/synology/rs-movies/Kimi (2022)/Kimi (2022) {tmdb-800510} - [WEBDL-1080p][AC3 5.1][x264]-TEPES.mkv"

do_delete "Chris lower quality: Apocalypto (2006)" "/mnt/synology/rs-movies/Apocalypto (2006)/Apocalypto (2006) {tmdb-1579} - [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv"

do_delete "Chris lower quality: Dogtooth (2009)" "/mnt/synology/rs-movies/Dogtooth (2009)/Dogtooth (2009) {tmdb-38810} - [Bluray-1080p][DTS 5.1][x264]-PHOBOS.mkv"

do_delete "Chris lower quality: Back to the Future (1985)" "/mnt/synology/rs-movies/Back to the Future (1985)/Back to the Future (1985) {tmdb-105} - [Bluray-1080p][EAC3 7.1][HDR10Plus][x265]-DON.mkv"

do_delete "Chris lower quality: The Double (2011)" "/mnt/synology/rs-movies/The Double (2011)/The Double (2011) {tmdb-73499} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-RegEdits.mkv"

do_delete "Chris lower quality: Oblivion (2013)" "/mnt/synology/rs-movies/Oblivion (2013)/Oblivion (2013) {tmdb-75612} - {edition-Open Matte} [WEBDL-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: The Good Dinosaur (2015)" "/mnt/synology/rs-movies/The Good Dinosaur (2015)/The Good Dinosaur (2015) {tmdb-105864} - [Bluray-1080p][DTS-HD MA 7.1][x264]-FuzerHD.mkv"

do_delete "Chris lower quality: Snowpiercer (2013)" "/mnt/synology/rs-movies/Snowpiercer (2013)/Snowpiercer (2013) {tmdb-110415} - [Bluray-1080p][AC3 5.1][x264]-EbP.mkv"

do_delete "Chris lower quality: Impractical Jokers The Movie (2020)" "/mnt/synology/rs-movies/Impractical Jokers The Movie (2020)/Impractical Jokers The Movie (2020) {tmdb-566927} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: The Long Walk (2025)" "/mnt/synology/rs-movies/The Long Walk (2025)/The Long Walk (2025) {tmdb-604079} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-SLOT.mkv"

do_delete "Chris lower quality: The Princess (2022)" "/mnt/synology/rs-movies/The Princess (2022)/The Princess (2022) {tmdb-759175} - [DSNP][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Delta Force 2 The Colombian Connection (1990)" "/mnt/synology/rs-movies/Delta Force 2 The Colombian Connection (1990)/Delta Force 2 The Colombian Connection (1990) {tmdb-19086} - [Bluray-1080p][AC3 2.0][x264]-PTNK.mkv"

do_delete "Chris lower quality: Dr. No (1962)" "/mnt/synology/rs-movies/Dr. No (1962)/Dr. No (1962) {tmdb-646} - [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv"

do_delete "Chris lower quality: Vengeance (2022)" "/mnt/synology/rs-movies/Vengeance (2022)/Vengeance (2022) {tmdb-683340} - [Bluray-1080p][DTS 5.1][x264]-EVO.mkv"

do_delete "Chris lower quality: Fidelity (2019)" "/mnt/synology/rs-movies/Fidelity (2019)/Fidelity (2019) {tmdb-575299} - [Bluray-1080p][AC3 5.1][x264]-HANDJOB.mkv"

do_delete "Chris lower quality: The Count of Monte Cristo (2024)" "/mnt/synology/rs-movies/The Count of Monte Cristo (2024)/The Count of Monte Cristo (2024) {tmdb-1084736} - [Bluray-1080p][EAC3 7.1][x264]-SPHD.mkv"

do_delete "Chris lower quality: Get Hard (2015)" "/mnt/synology/rs-movies/Get Hard (2015)/Get Hard (2015) {tmdb-257091} - {edition-Unrated} [Bluray-1080p][AC3 5.1][x264]-iNK.mkv"

do_delete "Chris lower quality: Synecdoche New York (2008)" "/mnt/synology/rs-movies/Synecdoche New York (2008)/Synecdoche New York (2008) {tmdb-4960} - [Bluray-1080p][DTS 5.1][x264]-HiFi.mkv"

do_delete "Chris lower quality: Thunderbolts- (2025)" "/mnt/synology/rs-movies/Thunderbolts- (2025)/Thunderbolts- (2025) {tmdb-986056} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-ETHEL.mkv"

do_delete "Chris lower quality: Dungeons and Dragons Honor Among Thieves (2023)" "/mnt/synology/rs-movies/Dungeons and Dragons Honor Among Thieves (2023)/Dungeons and Dragons Honor Among Thieves (2023) {tmdb-493529} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv"

do_delete "Chris lower quality: Red One (2024)" "/mnt/synology/rs-movies/Red One (2024)/Red One (2024) {tmdb-845781} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Wonder Woman 1984 (2020)" "/mnt/synology/rs-movies/Wonder Woman 1984 (2020)/Wonder Woman 1984 (2020) {tmdb-464052} - [WEBDL-1080p][AC3 5.1][h264].mkv"

do_delete "Chris lower quality: Cloud Atlas (2012)" "/mnt/synology/rs-movies/Cloud Atlas (2012)/Cloud Atlas (2012) {tmdb-83542} - [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv"

do_delete "Chris lower quality: Ip Man (2008)" "/mnt/synology/rs-movies/Ip Man (2008)/Ip Man (2008) {tmdb-14756} - [Bluray-1080p][AC3 5.1][x264]-HiDt.mkv"

do_delete "Chris lower quality: Bird Box Barcelona (2023)" "/mnt/synology/rs-movies/Bird Box Barcelona (2023)/Bird Box Barcelona (2023) {tmdb-805320} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-GERALT.mkv"

do_delete "Chris lower quality: In the Lost Lands (2025)" "/mnt/synology/rs-movies/In the Lost Lands (2025)/In the Lost Lands (2025) {tmdb-324544} - [Bluray-1080p][DTS-HD MA 5.1][x264]-COCAIN.mkv"

do_delete "Chris lower quality: Star Wars Episode III Revenge of the Sith (2005)" "/mnt/synology/rs-movies/Star Wars Episode III Revenge of the Sith (2005)/Star Wars Episode III Revenge of the Sith (2005) {tmdb-1895} - [Bluray-1080p][EAC3 7.1][x264].mkv"

do_delete "Chris lower quality: Gremlins 2 The New Batch (1990)" "/mnt/synology/rs-movies/Gremlins 2 The New Batch (1990)/Gremlins 2 The New Batch (1990) {tmdb-928} - [Bluray-1080p][AC3 2.0][x264]-ULSHD.mkv"

do_delete "Chris lower quality: Cool Hand Luke (1967)" "/mnt/synology/rs-movies/Cool Hand Luke (1967)/Cool Hand Luke (1967) {tmdb-903} - [Bluray-1080p][AC3 1.0][x264]-ESiR.mkv"

do_delete "Chris lower quality: Blade Trinity (2004)" "/mnt/synology/rs-movies/Blade Trinity (2004)/Blade Trinity (2004) {tmdb-36648} - [Bluray-1080p][DTS-ES 6.1][x264]-Z0N3.mkv"

do_delete "Chris lower quality: 9th Company (2005)" "/mnt/synology/rs-movies/9th Company (2005)/9th Company (2005) {tmdb-14097} - [Bluray-1080p][AC3 5.1][x264]-CiNEHD.mkv"

do_delete "Chris lower quality: Goodrich (2024)" "/mnt/synology/rs-movies/Goodrich (2024)/Goodrich (2024) {tmdb-1088096} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Corpse Bride (2005)" "/mnt/synology/rs-movies/Corpse Bride (2005)/Corpse Bride (2005) {tmdb-3933} - [Remux-1080p][DTS-HD MA 5.1][VC1].mkv"

do_delete "Chris lower quality: Venom Let There Be Carnage (2021)" "/mnt/synology/rs-movies/Venom Let There Be Carnage (2021)/Venom Let There Be Carnage (2021) {tmdb-580489} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: Operation Mincemeat (2022)" "/mnt/synology/rs-movies/Operation Mincemeat (2022)/Operation Mincemeat (2022) {tmdb-661231} - [NF][WEBDL-1080p][EAC3 5.1][HDR10][HEVC]-SiGLA.mkv"

do_delete "Chris lower quality: Lisa Frankenstein (2024)" "/mnt/synology/rs-movies/Lisa Frankenstein (2024)/Lisa Frankenstein (2024) {tmdb-993784} - [WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Vivarium (2019)" "/mnt/synology/rs-movies/Vivarium (2019)/Vivarium (2019) {tmdb-458305} - [WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv"

do_delete "Chris lower quality: The Suicide Squad (2021)" "/mnt/synology/rs-movies/The Suicide Squad (2021)/The Suicide Squad (2021) {tmdb-436969} - [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv"

do_delete "Chris lower quality: Cult Killer (2024)" "/mnt/synology/rs-movies/Cult Killer (2024)/Cult Killer (2024) {tmdb-1059345} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: The Rock (1996)" "/mnt/synology/rs-movies/The Rock (1996)/The Rock (1996) {tmdb-9802} - [Bluray-1080p][DTS 5.1][x264]-ESiR.mkv"

do_delete "Chris lower quality: Deadpool 2 (2018)" "/mnt/synology/rs-movies/Deadpool 2 (2018)/Deadpool 2 (2018) {tmdb-383498} - [Bluray-1080p][DTS-ES 5.1][x264]-HDChina.mkv"

do_delete "Chris lower quality: In the Heart of the Sea (2015)" "/mnt/synology/rs-movies/In the Heart of the Sea (2015)/In the Heart of the Sea (2015) {tmdb-205775} - [Bluray-1080p][DTS-HD MA 7.1][x264]-FraMeSToR.mkv"

do_delete "Chris lower quality: All Quiet on the Western Front (2022)" "/mnt/synology/rs-movies/All Quiet on the Western Front (2022)/All Quiet on the Western Front (2022) {tmdb-49046} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-playWEB.mkv"

do_delete "Chris lower quality: Along Came Polly (2004)" "/mnt/synology/rs-movies/Along Came Polly (2004)/Along Came Polly (2004) {tmdb-5966} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Zootopia (2016)" "/mnt/synology/rs-movies/Zootopia (2016)/Zootopia (2016) {tmdb-269149} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: The Interview (2014)" "/mnt/synology/rs-movies/The Interview (2014)/The Interview (2014) {tmdb-228967} - [HDTV-1080p][AAC 2.0][h264].mkv"

do_delete "Chris lower quality: Lilo and Stitch (2025)" "/mnt/synology/rs-movies/Lilo and Stitch (2025)/Lilo and Stitch (2025) {tmdb-552524} - [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-BYNDR.mkv"

do_delete "Chris lower quality: Evil Dead Rise (2023)" "/mnt/synology/rs-movies/Evil Dead Rise (2023)/Evil Dead Rise (2023) {tmdb-713704} - [WEBRip-1080p][EAC3 7.1][x264]-HiDt.mkv"

do_delete "Chris lower quality: On a Wing and a Prayer (2023)" "/mnt/synology/rs-movies/On a Wing and a Prayer (2023)/On a Wing and a Prayer (2023) {tmdb-878375} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-dBBd.mkv"

do_delete "Chris lower quality: Twins (1988)" "/mnt/synology/rs-movies/Twins (1988)/Twins (1988) {tmdb-9493} - [Bluray-1080p][AC3 2.0][x264].mkv"

do_delete "Chris lower quality: Incredibles 2 (2018)" "/mnt/synology/rs-movies/Incredibles 2 (2018)/Incredibles 2 (2018) {tmdb-260513} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Lagaan Once Upon a Time in India (2001)" "/mnt/synology/rs-movies/Lagaan Once Upon a Time in India (2001)/Lagaan Once Upon a Time in India (2001) {tmdb-19666} - [WEBRip-1080p][AC3 5.1][x264]-AMRAP.mkv"

do_delete "Chris lower quality: Bandit (2022)" "/mnt/synology/rs-movies/Bandit (2022)/Bandit (2022) {tmdb-842942} - [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: I Still Know What You Did Last Summer (1998)" "/mnt/synology/rs-movies/I Still Know What You Did Last Summer (1998)/I Still Know What You Did Last Summer (1998) {tmdb-3600} - [Bluray-1080p][AC3 5.1][x264]-TFiN.mkv"

do_delete "Chris lower quality: Hocus Pocus (1993)" "/mnt/synology/rs-movies/Hocus Pocus (1993)/Hocus Pocus (1993) {tmdb-10439} - [HDTV-1080p][DTS-HD MA 5.1][x264].mkv"

do_delete "Chris lower quality: Fantastic Beasts The Secrets of Dumbledore (2022)" "/mnt/synology/rs-movies/Fantastic Beasts The Secrets of Dumbledore (2022)/Fantastic Beasts The Secrets of Dumbledore (2022) {tmdb-338953} - [WEBDL-1080p][EAC3 Atmos 5.1][x264]-SMURF.mkv"

do_delete "Chris lower quality: Shaft (2000)" "/mnt/synology/rs-movies/Shaft (2000)/Shaft (2000) {tmdb-479} - [Bluray-1080p][DTS 5.1][x264]-HD4U.mkv"

do_delete "Chris lower quality: Dave Chappelle Deep in the Heart of Texas (2017)" "/mnt/synology/rs-movies/Dave Chappelle Deep in the Heart of Texas (2017)/Dave Chappelle Deep in the Heart of Texas (2017) {tmdb-444706} - [NF][WEBRip-1080p][AC3 5.1][x264]-TrollHD.mkv"

do_delete "Chris lower quality: Kingdom of Heaven (2005)" "/mnt/synology/rs-movies/Kingdom of Heaven (2005)/Kingdom of Heaven (2005) {tmdb-1495} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Justice League Doom (2012)" "/mnt/synology/rs-movies/Justice League Doom (2012)/Justice League Doom (2012) {tmdb-76589} - [WEBDL-1080p][EAC3 5.1][x264]-Kitsune.mkv"

do_delete "Chris lower quality: Migration (2023)" "/mnt/synology/rs-movies/Migration (2023)/Migration (2023) {tmdb-940551} - [WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: X-Men The Last Stand (2006)" "/mnt/synology/rs-movies/X-Men The Last Stand (2006)/X-Men The Last Stand (2006) {tmdb-36668} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv"

do_delete "Chris lower quality: Assassins Creed (2016)" "/mnt/synology/rs-movies/Assassins Creed (2016)/Assassins Creed (2016) {tmdb-121856} - [WEBDL-1080p][AC3 5.1][h264].mkv"

do_delete "Chris lower quality: Riddick (2013)" "/mnt/synology/rs-movies/Riddick (2013)/Riddick (2013) {tmdb-87421} - {edition-Extended} [Bluray-1080p][AC3 5.1][x264]-HDMaNiAcS.mkv"

do_delete "Chris lower quality: Vortex (2021)" "/mnt/synology/rs-movies/Vortex (2021)/Vortex (2021) {tmdb-807070} - [Bluray-1080p][DTS 5.1][x264]-ADE.mkv"

do_delete "Chris lower quality: Tarzan (1999)" "/mnt/synology/rs-movies/Tarzan (1999)/Tarzan (1999) {tmdb-37135} - [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: The Way Back (2010)" "/mnt/synology/rs-movies/The Way Back (2010)/The Way Back (2010) {tmdb-49009} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: The New Mutants (2020)" "/mnt/synology/rs-movies/The New Mutants (2020)/The New Mutants (2020) {tmdb-340102} - [Bluray-1080p][EAC3 7.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: Willow (1988)" "/mnt/synology/rs-movies/Willow (1988)/Willow (1988) {tmdb-847} - [Bluray-1080p][AC3 5.1][x264]-eMc2.mkv"

do_delete "Chris lower quality: A Simple Favor (2018)" "/mnt/synology/rs-movies/A Simple Favor (2018)/A Simple Favor (2018) {tmdb-484247} - [Bluray-1080p][EAC3 7.1][x264]-NCmt.mkv"

do_delete "Chris lower quality: Prey (2024)" "/mnt/synology/rs-movies/Prey (2024)/Prey (2024) {tmdb-1129598} - [WEBDL-1080p][EAC3 5.1][h264]-M-NLsubs.mkv"

do_delete "Chris lower quality: The Midnight Sky (2020)" "/mnt/synology/rs-movies/The Midnight Sky (2020)/The Midnight Sky (2020) {tmdb-614911} - [WEBDL-1080p][EAC3 Atmos 5.1][x264]-EVO.mkv"

do_delete "Chris lower quality: Rumble Fish (1983)" "/mnt/synology/rs-movies/Rumble Fish (1983)/Rumble Fish (1983) {tmdb-232} - [Bluray-1080p][AC3 2.0][x264]-nikt0.mkv"

do_delete "Chris lower quality: When Harry Met Sally. (1989)" "/mnt/synology/rs-movies/When Harry Met Sally. (1989)/When Harry Met Sally. (1989) {tmdb-639} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-GPRS.mkv"

do_delete "Chris lower quality: Prometheus (2012)" "/mnt/synology/rs-movies/Prometheus (2012)/Prometheus (2012) {tmdb-70981} - [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv"

do_delete "Chris lower quality: Jurassic World Dominion (2022)" "/mnt/synology/rs-movies/Jurassic World Dominion (2022)/Jurassic World Dominion (2022) {tmdb-507086} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Once Upon a Time in America (1984)" "/mnt/synology/rs-movies/Once Upon a Time in America (1984)/Once Upon a Time in America (1984) {tmdb-311} - [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv"

do_delete "Chris lower quality: Monkey Man (2024)" "/mnt/synology/rs-movies/Monkey Man (2024)/Monkey Man (2024) {tmdb-560016} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Nosferatu (2024)" "/mnt/synology/rs-movies/Nosferatu (2024)/Nosferatu (2024) {tmdb-426063} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-APEX.mkv"

do_delete "Chris lower quality: Rocketman (2019)" "/mnt/synology/rs-movies/Rocketman (2019)/Rocketman (2019) {tmdb-504608} - [WEBDL-1080p][AC3 5.1][h264].mkv"

do_delete "Chris lower quality: The Bourne Identity (2002)" "/mnt/synology/rs-movies/The Bourne Identity (2002)/The Bourne Identity (2002) {tmdb-2501} - [Bluray-1080p][EAC3 5.1][HDR10][h265].mkv"

do_delete "Chris lower quality: Aztec Batman Clash of Empires (2025)" "/mnt/synology/rs-movies/Aztec Batman Clash of Empires (2025)/Aztec Batman Clash of Empires (2025) {tmdb-987400} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: One Magic Christmas (1985)" "/mnt/synology/rs-movies/One Magic Christmas (1985)/One Magic Christmas (1985) {tmdb-13380} - [WEBDL-1080p][AC3 5.1][h264]-OOO.mkv"

do_delete "Chris lower quality: Sin City A Dame to Kill For (2014)" "/mnt/synology/rs-movies/Sin City A Dame to Kill For (2014)/Sin City A Dame to Kill For (2014) {tmdb-189} - [PCOK][WEBDL-1080p][EAC3 5.1][x264]-ARTiCUN0.mkv"

do_delete "Chris lower quality: La La Land (2016)" "/mnt/synology/rs-movies/La La Land (2016)/La La Land (2016) {tmdb-313369} - [Bluray-1080p][AC3 5.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: Superintelligence (2020)" "/mnt/synology/rs-movies/Superintelligence (2020)/Superintelligence (2020) {tmdb-521007} - [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: The Lion King (2019)" "/mnt/synology/rs-movies/The Lion King (2019)/The Lion King (2019) {tmdb-420818} - [Bluray-1080p][EAC3 Atmos 7.1][HDR10][x265]-JM.mkv"

do_delete "Chris lower quality: Beau Is Afraid (2023)" "/mnt/synology/rs-movies/Beau Is Afraid (2023)/Beau Is Afraid (2023) {tmdb-798286} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: The Monuments Men (2014)" "/mnt/synology/rs-movies/The Monuments Men (2014)/The Monuments Men (2014) {tmdb-152760} - [Bluray-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: The Lord of the Rings The Two Towers (2002)" "/mnt/synology/rs-movies/The Lord of the Rings The Two Towers (2002)/The Lord of the Rings The Two Towers (2002) {tmdb-121} - [Bluray-1080p][DTS-ES 6.1][x264].mkv"

do_delete "Chris lower quality: The Monster Squad (1987)" "/mnt/synology/rs-movies/The Monster Squad (1987)/The Monster Squad (1987) {tmdb-13509} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: Monster Hunter (2020)" "/mnt/synology/rs-movies/Monster Hunter (2020)/Monster Hunter (2020) {tmdb-458576} - [AMZN][WEBDL-1080p Proper][EAC3 5.1][h264]-NTG.mkv"

do_delete "Chris lower quality: They Cloned Tyrone (2023)" "/mnt/synology/rs-movies/They Cloned Tyrone (2023)/They Cloned Tyrone (2023) {tmdb-736769} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: Incendies (2010)" "/mnt/synology/rs-movies/Incendies (2010)/Incendies (2010) {tmdb-46738} - [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv"

do_delete "Chris lower quality: Time Cut (2024)" "/mnt/synology/rs-movies/Time Cut (2024)/Time Cut (2024) {tmdb-827931} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-OzONE.mkv"

do_delete "Chris lower quality: 28 Years Later (2025)" "/mnt/synology/rs-movies/28 Years Later (2025)/28 Years Later (2025) {tmdb-1100988} - [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-BYNDR.mkv"

do_delete "Chris lower quality: Spider-Man Into the Spider-Verse (2018)" "/mnt/synology/rs-movies/Spider-Man Into the Spider-Verse (2018)/Spider-Man Into the Spider-Verse (2018) {tmdb-324857} - [WEBDL-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: The Wandering Earth (2019)" "/mnt/synology/rs-movies/The Wandering Earth (2019)/The Wandering Earth (2019) {tmdb-535167} - [WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTG.mkv"

do_delete "Chris lower quality: Ali (2001)" "/mnt/synology/rs-movies/Ali (2001)/Ali (2001) {tmdb-8489} - [Bluray-1080p][AC3 5.1][x264]-CRiSC.mkv"

do_delete "Chris lower quality: Enders Game (2013)" "/mnt/synology/rs-movies/Enders Game (2013)/Enders Game (2013) {tmdb-80274} - [Bluray-1080p Proper][DTS 5.1][x264]-DON.mkv"

do_delete "Chris lower quality: Extraction 2 (2023)" "/mnt/synology/rs-movies/Extraction 2 (2023)/Extraction 2 (2023) {tmdb-697843} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-OzONE.mkv"

do_delete "Chris lower quality: Cruella (2021)" "/mnt/synology/rs-movies/Cruella (2021)/Cruella (2021) {tmdb-337404} - [DSNP][WEBDL-1080p][EAC3 Atmos 5.1][h264]-TOMMY.mkv"

do_delete "Chris lower quality: To Gerard (2020)" "/mnt/synology/rs-movies/To Gerard (2020)/To Gerard (2020) {tmdb-680941} - [WEBDL-1080p][EAC3 5.1][x264]-KOGi.mkv"

do_delete "Chris lower quality: Good Time (2017)" "/mnt/synology/rs-movies/Good Time (2017)/Good Time (2017) {tmdb-429200} - [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: Murder at Yellowstone City (2022)" "/mnt/synology/rs-movies/Murder at Yellowstone City (2022)/Murder at Yellowstone City (2022) {tmdb-974961} - [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Kraven the Hunter (2024)" "/mnt/synology/rs-movies/Kraven the Hunter (2024)/Kraven the Hunter (2024) {tmdb-539972} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-APEX.mkv"

do_delete "Chris lower quality: Passages (2023)" "/mnt/synology/rs-movies/Passages (2023)/Passages (2023) {tmdb-898673} - [AMZN][WEBDL-1080p][EAC3 2.0][h264]-XEBEC.mkv"

do_delete "Chris lower quality: City of God (2002)" "/mnt/synology/rs-movies/City of God (2002)/City of God (2002) {tmdb-598} - [Bluray-1080p][DTS 5.1][x264]-HDC.mkv"

do_delete "Chris lower quality: Millers Crossing (1990)" "/mnt/synology/rs-movies/Millers Crossing (1990)/Millers Crossing (1990) {tmdb-379} - [WEBDL-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv"

do_delete "Chris lower quality: After We Fell (2021)" "/mnt/synology/rs-movies/After We Fell (2021)/After We Fell (2021) {tmdb-744275} - [Bluray-1080p][AC3 5.1][x264]-eMc2.mkv"

do_delete "Chris lower quality: The Avengers (2012)" "/mnt/synology/rs-movies/The Avengers (2012)/The Avengers (2012) {tmdb-24428} - [DSNP][WEBDL-1080p][EAC3 Atmos 5.1][h264]-TAGWEB.mkv"

do_delete "Chris lower quality: The Coffee Table (2023)" "/mnt/synology/rs-movies/The Coffee Table (2023)/The Coffee Table (2023) {tmdb-1056380} - [AMZN][WEBDL-1080p][EAC3 2.0][h264]-BYNDR.mkv"

do_delete "Chris lower quality: Dont Look Up (2021)" "/mnt/synology/rs-movies/Dont Look Up (2021)/Dont Look Up (2021) {tmdb-646380} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-EVO.mkv"

do_delete "Chris lower quality: The Martian (2015)" "/mnt/synology/rs-movies/The Martian (2015)/The Martian (2015) {tmdb-286217} - {edition-Extended Cut} [Bluray-1080p][DTS 5.1][x264]-VietHD.mkv"

do_delete "Chris lower quality: Mama (2013)" "/mnt/synology/rs-movies/Mama (2013)/Mama (2013) {tmdb-132232} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Lawrence of Arabia (1962)" "/mnt/synology/rs-movies/Lawrence of Arabia (1962)/Lawrence of Arabia (1962) {tmdb-947} - [HDTV-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: The Three Musketeers D'Artagnan (2023)" "/mnt/synology/rs-movies/The Three Musketeers D'Artagnan (2023)/The Three Musketeers D'Artagnan (2023) {tmdb-796185} - [Bluray-1080p][PCM 2.0][h264].mkv"

do_delete "Chris lower quality: Iron Man 2 (2010)" "/mnt/synology/rs-movies/Iron Man 2 (2010)/Iron Man 2 (2010) {tmdb-10138} - {edition-Open Matte} [WEBDL-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Stuart Little (1999)" "/mnt/synology/rs-movies/Stuart Little (1999)/Stuart Little (1999) {tmdb-10137} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: Bring It On (2000)" "/mnt/synology/rs-movies/Bring It On (2000)/Bring It On (2000) {tmdb-1588} - [Bluray-1080p][DTS 5.1][x264]-ero.mkv"

do_delete "Chris lower quality: The Old Way (2023)" "/mnt/synology/rs-movies/The Old Way (2023)/The Old Way (2023) {tmdb-872954} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Reign of Fire (2002)" "/mnt/synology/rs-movies/Reign of Fire (2002)/Reign of Fire (2002) {tmdb-6278} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Wish Dragon (2021)" "/mnt/synology/rs-movies/Wish Dragon (2021)/Wish Dragon (2021) {tmdb-550205} - [WEBDL-1080p][EAC3 Atmos 5.1][x264]-RUMOUR.mkv"

do_delete "Chris lower quality: UHF (1989)" "/mnt/synology/rs-movies/UHF (1989)/UHF (1989) {tmdb-11959} - [Bluray-1080p][AC3 2.0][x264].mkv"

do_delete "Chris lower quality: South Park the Streaming Wars Part 2 (2022)" "/mnt/synology/rs-movies/South Park the Streaming Wars Part 2 (2022)/South Park the Streaming Wars Part 2 (2022) {tmdb-993729} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv"

do_delete "Chris lower quality: Pearl (2022)" "/mnt/synology/rs-movies/Pearl (2022)/Pearl (2022) {tmdb-949423} - [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv"

do_delete "Chris lower quality: Limitless (2011)" "/mnt/synology/rs-movies/Limitless (2011)/Limitless (2011) {tmdb-51876} - {edition-Unrated} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: Out of Sight (1998)" "/mnt/synology/rs-movies/Out of Sight (1998)/Out of Sight (1998) {tmdb-1389} - [Bluray-1080p][DTS 5.1][x264]-tranc.mkv"

do_delete "Chris lower quality: Holland (2025)" "/mnt/synology/rs-movies/Holland (2025)/Holland (2025) {tmdb-257094} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-PiRaTeS.mkv"

do_delete "Chris lower quality: Men in Black (1997)" "/mnt/synology/rs-movies/Men in Black (1997)/Men in Black (1997) {tmdb-607} - [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv"

do_delete "Chris lower quality: Bumblebee (2018)" "/mnt/synology/rs-movies/Bumblebee (2018)/Bumblebee (2018) {tmdb-424783} - [WEBDL-1080p][AC3 5.1][h264].mkv"

do_delete "Chris lower quality: Clue (1985)" "/mnt/synology/rs-movies/Clue (1985)/Clue (1985) {tmdb-15196} - [Bluray-1080p][FLAC 2.0][x264].mkv"

do_delete "Chris lower quality: The Twilight Saga Breaking Dawn Part 2 (2012)" "/mnt/synology/rs-movies/The Twilight Saga Breaking Dawn Part 2 (2012)/The Twilight Saga Breaking Dawn Part 2 (2012) {tmdb-50620} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv"

do_delete "Chris lower quality: Heads of State (2025)" "/mnt/synology/rs-movies/Heads of State (2025)/Heads of State (2025) {tmdb-749170} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-WADU.mkv"

do_delete "Chris lower quality: Carriers (2009)" "/mnt/synology/rs-movies/Carriers (2009)/Carriers (2009) {tmdb-25769} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4"

do_delete "Chris lower quality: The Popes Exorcist (2023)" "/mnt/synology/rs-movies/The Popes Exorcist (2023)/The Popes Exorcist (2023) {tmdb-758323} - [WEBDL-1080p][EAC3 5.1][x264]-DKV.mkv"

do_delete "Chris lower quality: Terrifier 3 (2024)" "/mnt/synology/rs-movies/Terrifier 3 (2024)/Terrifier 3 (2024) {tmdb-1034541} - [WEBDL-1080p][AC3 5.1][h264]-BulkyMeekSpoonbillOfCookies.mkv"

do_delete "Chris lower quality: Naked Gun 33⅓ The Final Insult (1994)" "/mnt/synology/rs-movies/Naked Gun 33⅓ The Final Insult (1994)/Naked Gun 33⅓ The Final Insult (1994) {tmdb-36593} - [Bluray-1080p][DTS 5.1][x264]-HD4U.mkv"

do_delete "Chris lower quality: Cemetery Man (1994)" "/mnt/synology/rs-movies/Cemetery Man (1994)/Cemetery Man (1994) {tmdb-21588} - [Bluray-1080p][AC3 2.0][x264]-LiViDiTY.mkv"

do_delete "Chris lower quality: Sing 2 (2021)" "/mnt/synology/rs-movies/Sing 2 (2021)/Sing 2 (2021) {tmdb-438695} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: Men in Black International (2019)" "/mnt/synology/rs-movies/Men in Black International (2019)/Men in Black International (2019) {tmdb-479455} - [WEBDL-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Justice League Dark Apokolips War (2020)" "/mnt/synology/rs-movies/Justice League Dark Apokolips War (2020)/Justice League Dark Apokolips War (2020) {tmdb-618344} - [WEBDL-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: You Cant Run Forever (2024)" "/mnt/synology/rs-movies/You Cant Run Forever (2024)/You Cant Run Forever (2024) {tmdb-879412} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv"

do_delete "Chris lower quality: Afterburn (2025)" "/mnt/synology/rs-movies/Afterburn (2025)/Afterburn (2025) {tmdb-507244} - [AMZN][WEBDL-1080p Proper][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Spiral From the Book of Saw (2021)" "/mnt/synology/rs-movies/Spiral From the Book of Saw (2021)/Spiral From the Book of Saw (2021) {tmdb-602734} - [Bluray-1080p][EAC3 7.1][x264]-LoRD.mkv"

do_delete "Chris lower quality: Gold (2022)" "/mnt/synology/rs-movies/Gold (2022)/Gold (2022) {tmdb-760926} - [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv"

do_delete "Chris lower quality: IF (2024)" "/mnt/synology/rs-movies/IF (2024)/IF (2024) {tmdb-639720} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-POKE.mkv"

do_delete "Chris lower quality: Your Highness (2011)" "/mnt/synology/rs-movies/Your Highness (2011)/Your Highness (2011) {tmdb-38319} - {edition-Unrated} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv"

do_delete "Chris lower quality: The Apprentice (2024)" "/mnt/synology/rs-movies/The Apprentice (2024)/The Apprentice (2024) {tmdb-1182047} - [WEBDL-1080p][EAC3 5.1][h264]-VoteKamala.mkv"

do_delete "Chris lower quality: Blast from the Past (1999)" "/mnt/synology/rs-movies/Blast from the Past (1999)/Blast from the Past (1999) {tmdb-11622} - [Bluray-1080p][DTS-HD MA 5.1][h264]-REFRACTiON.mkv"

do_delete "Chris lower quality: Asphalt City (2024)" "/mnt/synology/rs-movies/Asphalt City (2024)/Asphalt City (2024) {tmdb-628922} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Triple Frontier (2019)" "/mnt/synology/rs-movies/Triple Frontier (2019)/Triple Frontier (2019) {tmdb-399361} - [WEBRip-1080p][EAC3 Atmos 5.1][x264]-DEFLATE.mkv"

do_delete "Chris lower quality: Meet the Parents (2000)" "/mnt/synology/rs-movies/Meet the Parents (2000)/Meet the Parents (2000) {tmdb-1597} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: River Wild (2023)" "/mnt/synology/rs-movies/River Wild (2023)/River Wild (2023) {tmdb-1000475} - [NF][WEBDL-1080p][EAC3 5.1][x264]-playWEB.mkv"

do_delete "Chris lower quality: Executive Decision (1996)" "/mnt/synology/rs-movies/Executive Decision (1996)/Executive Decision (1996) {tmdb-2320} - [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv"

do_delete "Chris lower quality: A Cinderella Story (2004)" "/mnt/synology/rs-movies/A Cinderella Story (2004)/A Cinderella Story (2004) {tmdb-11247} - [Bluray-1080p][DTS 5.1][x264]-KaKa.mkv"

do_delete "Chris lower quality: Juror #2 (2024)" "/mnt/synology/rs-movies/Juror #2 (2024)/Juror #2 (2024) {tmdb-1106739} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv"

do_delete "Chris lower quality: Are You There God Its Me Margaret. (2023)" "/mnt/synology/rs-movies/Are You There God Its Me Margaret. (2023)/Are You There God Its Me Margaret. (2023) {tmdb-555285} - [WEBDL-1080p][AC3 5.1][h264]-DKV.mkv"

do_delete "Chris lower quality: Hillbilly Elegy (2020)" "/mnt/synology/rs-movies/Hillbilly Elegy (2020)/Hillbilly Elegy (2020) {tmdb-592984} - [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv"

do_delete "Chris lower quality: Thank You for Your Service (2017)" "/mnt/synology/rs-movies/Thank You for Your Service (2017)/Thank You for Your Service (2017) {tmdb-347629} - [Bluray-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Simulant (2023)" "/mnt/synology/rs-movies/Simulant (2023)/Simulant (2023) {tmdb-942199} - [HMAX][WEBDL-1080p][EAC3 5.1][x264]-PTerWEB.mkv"


log "Deletion script complete!"
