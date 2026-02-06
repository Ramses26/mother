#!/bin/bash
#==============================================================================
# Chris's Synology - Pending Deletions Script
# RUN THIS AFTER sync_actions script completes!
#==============================================================================
# Generated: 2026-02-05 18:04:36
# Total files to delete: 196
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

PROGRESS_FILE="${PROGRESS_FILE:-chris_deletions_progress_20260205_180436.log}"
ERROR_LOG="${ERROR_LOG:-chris_deletions_errors_20260205_180436.log}"
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

do_delete "Chris lower quality: Ray Donovan (2013) {tvdb-259866}" "/mnt/synology/rs-tv/Ray Donovan (2013) {tvdb-259866}/Season 07/Ray Donovan (2013) - S07E10 - Youll Never Walk Alone [HDTV-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Game of Thrones (2011) {tvdb-121361}" "/mnt/synology/rs-tv/Game of Thrones (2011) {tvdb-121361}/Season 08/Game of Thrones (2011) - S08E06 - The Iron Throne [WEBDL-1080p][EAC3 5.1][h264]-GoT.mkv"

do_delete "Chris lower quality: The Crew (2021) {tvdb-395174}" "/mnt/synology/rs-tv/The Crew (2021) {tvdb-395174}/Season 01/The Crew (2021) - S01E01 - I Guess That Cake Did Need To Be Refrigerated [WEBDL-1080p][EAC3 Atmos 5.1][x264]-iKA.mkv"

do_delete "Chris lower quality: Swamp Thing (2019) {tvdb-361735}" "/mnt/synology/rs-tv/Swamp Thing (2019) {tvdb-361735}/Season 01/Swamp Thing (2019) - S01E10 - Loose Ends [HDTV-1080p][AAC 2.0][h264].mkv"

do_delete "Chris lower quality: Knightfall (2017) {tvdb-323608}" "/mnt/synology/rs-tv/Knightfall (2017) {tvdb-323608}/Season 01/Knightfall (2017) - S01E10 - Do You See the Blue [HDTV-1080p][EAC3 2.0][h264].mkv"

do_delete "Chris lower quality: 2 Broke Girls (2011) {tvdb-248741}" "/mnt/synology/rs-tv/2 Broke Girls (2011) {tvdb-248741}/Season 02/2 Broke Girls (2011) - S02E10 - And the Big Opening [WEBRip-1080p][EAC3 5.1][x264]-CasStudio.mkv"

do_delete "Chris lower quality: Bluey (2018) {tvdb-353546}" "/mnt/synology/rs-tv/Bluey (2018) {tvdb-353546}/Season 03/Bluey (2018) - S03E49 - The Sign [WEBDL-1080p][EAC3 5.1][h264]-DOLORES.mkv"

do_delete "Chris lower quality: Peaky Blinders (2013) {tvdb-270915}" "/mnt/synology/rs-tv/Peaky Blinders (2013) {tvdb-270915}/Season 06/Peaky Blinders (2013) - S06E05 - The Road to Hell [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: The Day of the Jackal (2024) {tvdb-426866}" "/mnt/synology/rs-tv/The Day of the Jackal (2024) {tvdb-426866}/Season 01/The Day of the Jackal (2024) - S01E10 - Episode 10 [WEBDL-1080p][EAC3 5.1][x264]-ETHEL.mkv"

do_delete "Chris lower quality: Wynonna Earp (2016) {tvdb-305582}" "/mnt/synology/rs-tv/Wynonna Earp (2016) {tvdb-305582}/Season 04/Wynonna Earp (2016) - S04E12 - Old Souls [WEBDL-1080p][AAC 2.0][h264]-CAKES.mkv"

do_delete "Chris lower quality: Britannia (2018) {tvdb-333644}" "/mnt/synology/rs-tv/Britannia (2018) {tvdb-333644}/Season 03/Britannia (2018) - S03E06 - A Precious Asset [WEBDL-1080p][EAC3 5.1][h264]-NTb.mkv"

do_delete "Chris lower quality: Hunting Hitler (2015) {tvdb-302621}" "/mnt/synology/rs-tv/Hunting Hitler (2015) {tvdb-302621}/Season 02/Hunting Hitler (2015) - S02E04 - The Web [WEBDL-1080p][EAC3 2.0][h264]-CINEFEEL.mkv"

do_delete "Chris lower quality: Legion (2017) {tvdb-320724}" "/mnt/synology/rs-tv/Legion (2017) {tvdb-320724}/Season 03/Legion (2017) - S03E08 - Chapter 27 [HDTV-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Spartacus - House of Ashur (2025) {tvdb-465189}" "/mnt/synology/rs-tv/Spartacus - House of Ashur (2025) {tvdb-465189}/Season 01/Spartacus - House of Ashur (2025) - S01E05 - Goddess of Death [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-NTb.mkv"

do_delete "Chris lower quality: Boston Legal (2004) {tvdb-74058}" "/mnt/synology/rs-tv/Boston Legal (2004) {tvdb-74058}/Season 01/Boston Legal (2004) - S01E02 - Still Crazy After All These Years [HDTV-1080p][AC3 2.0][h264].mkv"

do_delete "Chris lower quality: Star Trek - The Next Generation (1987) {tvdb-71470}" "/mnt/synology/rs-tv/Star Trek - The Next Generation (1987) {tvdb-71470}/Season 03/Star Trek - The Next Generation (1987) - S03E15 - Yesterdays Enterprise [WEBDL-1080p][EAC3 5.1][AV1].mkv"

do_delete "Chris lower quality: Marvel Studios - Legends (2021) {tvdb-393438}" "/mnt/synology/rs-tv/Marvel Studios - Legends (2021) {tvdb-393438}/Season 02/Marvel Studios - Legends (2021) - S02E19 - Monica Rambeau [WEBDL-1080p][EAC3 5.1][h264]-EDITH.mkv"

do_delete "Chris lower quality: Lost in Space (2018) {tvdb-343253}" "/mnt/synology/rs-tv/Lost in Space (2018) {tvdb-343253}/Season 02/Lost in Space (2018) - S02E10 - Ninety-Seven [HDTV-1080p][EAC3 Atmos 5.1][x264].mkv"

do_delete "Chris lower quality: The Count of Monte Cristo (2024) {tvdb-448042}" "/mnt/synology/rs-tv/The Count of Monte Cristo (2024) {tvdb-448042}/Season 01/The Count of Monte Cristo (2024) - S01E08 - The Last Two [WEBDL-1080p][AC3 5.1][x264]-playWEB.mkv"

do_delete "Chris lower quality: Love, Death & Robots (2019) {tvdb-357888}" "/mnt/synology/rs-tv/Love, Death & Robots (2019) {tvdb-357888}/Season 03/Love, Death & Robots (2019) - S03E02 - Bad Travelling [WEBDL-1080p][EAC3 Atmos 5.1][x264]-SMURF.mkv"

do_delete "Chris lower quality: The Righteous Gemstones (2019) {tvdb-357223}" "/mnt/synology/rs-tv/The Righteous Gemstones (2019) {tvdb-357223}/Season 04/The Righteous Gemstones (2019) - S04E07 - For Jealousy Is the Rage of a Man [WEBDL-1080p Proper][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Star Wars - The Clone Wars (2008) {tvdb-83268}" "/mnt/synology/rs-tv/Star Wars - The Clone Wars (2008) {tvdb-83268}/Season 04/Star Wars - The Clone Wars (2008) - S04E02 - Gungan Attack 2 [[Trash] Release Sources (Streaming Service)_25_3 Release Sources (Streaming Service)_22_1][WEBDL-1080p][EAC3 5.1][h264]-playWEB.mkv"

do_delete "Chris lower quality: Billions (2016) {tvdb-279536}" "/mnt/synology/rs-tv/Billions (2016) {tvdb-279536}/Season 07/Billions (2016) - S07E02 - Original Sin [WEBDL-1080p][EAC3 5.1][h264]-NTb.mkv"

do_delete "Chris lower quality: Orange Is the New Black (2013) {tvdb-264586}" "/mnt/synology/rs-tv/Orange Is the New Black (2013) {tvdb-264586}/Season 01/Orange Is the New Black (2013) - S01E03 - Lesbian Request Denied [WEBRip-1080p][AAC 2.0][h264].mkv"

do_delete "Chris lower quality: Avenue 5 (2020) {tvdb-364106}" "/mnt/synology/rs-tv/Avenue 5 (2020) {tvdb-364106}/Season 02/Avenue 5 (2020) - S02E08 - Thats Why They Call It a Missile [WEBDL-1080p][AC3 5.1][x264]-ggwp.mkv"

do_delete "Chris lower quality: Orphan Black - Echoes (2024) {tvdb-418712}" "/mnt/synology/rs-tv/Orphan Black - Echoes (2024) {tvdb-418712}/Season 01/Orphan Black - Echoes (2024) - S01E01 - Pilot [WEBDL-1080p][AAC 5.1][h264]-NHTFS.mkv"

do_delete "Chris lower quality: Person of Interest (2011) {tvdb-248742}" "/mnt/synology/rs-tv/Person of Interest (2011) {tvdb-248742}/Season 05/Person of Interest (2011) - S05E12 - exe [HDTV-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Frozen Planet (2011) {tvdb-251418}" "/mnt/synology/rs-tv/Frozen Planet (2011) {tvdb-251418}/Specials/Frozen Planet (2011) - S00E01 - Freeze Frame – Secrets of the Volcano [Bluray-1080p][DTS 2.0][x264]-Z0N3.mkv"

do_delete "Chris lower quality: Homeland (2011) {tvdb-247897}" "/mnt/synology/rs-tv/Homeland (2011) {tvdb-247897}/Season 08/Homeland (2011) - S08E12 - Prisoners of War [HDTV-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Vikings - Valhalla (2022) {tvdb-372700}" "/mnt/synology/rs-tv/Vikings - Valhalla (2022) {tvdb-372700}/Season 02/Vikings - Valhalla (2022) - S02E06 - Leap of Faith [WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: The 100 (2014) {tvdb-268592}" "/mnt/synology/rs-tv/The 100 (2014) {tvdb-268592}/Season 07/The 100 (2014) - S07E03 - False Gods [WEBDL-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Altered Carbon (2018) {tvdb-332331}" "/mnt/synology/rs-tv/Altered Carbon (2018) {tvdb-332331}/Season 02/Altered Carbon (2018) - S02E05 - I Wake Up Screaming [HDTV-1080p][EAC3 Atmos 5.1][x264].mkv"

do_delete "Chris lower quality: Halo (2022) {tvdb-366524}" "/mnt/synology/rs-tv/Halo (2022) {tvdb-366524}/Season 01/Halo (2022) - S01E08 - Allegiance [WEBDL-1080p][EAC3 Atmos 5.1][h264]-NTb.mkv"

do_delete "Chris lower quality: Marvel's Agents of S.H.I.E.L.D. (2013) {tvdb-263365}" "/mnt/synology/rs-tv/Marvel's Agents of S.H.I.E.L.D. (2013) {tvdb-263365}/Season 06/Marvel's Agents of S.H.I.E.L.D. (2013) - S06E11 - From the Ashes [WEBDL-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Ballers (2015) {tvdb-281714}" "/mnt/synology/rs-tv/Ballers (2015) {tvdb-281714}/Season 05/Ballers (2015) - S05E04 - Municipal [HDTV-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Grotesquerie (2024) {tvdb-446581}" "/mnt/synology/rs-tv/Grotesquerie (2024) {tvdb-446581}/Season 01/Grotesquerie (2024) - S01E10 - I Think Im Dead [WEBDL-1080p][EAC3 5.1][h264]-SuccessfulCrab.mkv"

do_delete "Chris lower quality: Under the Bridge (2024) {tvdb-425386}" "/mnt/synology/rs-tv/Under the Bridge (2024) {tvdb-425386}/Season 01/Under the Bridge (2024) - S01E01 - Looking Glass [WEBDL-1080p][EAC3 5.1][h264]-SuccessfulCrab.mkv"

do_delete "Chris lower quality: The Right Stuff (2020) {tvdb-362576}" "/mnt/synology/rs-tv/The Right Stuff (2020) {tvdb-362576}/Season 01/The Right Stuff (2020) - S01E06 - Vostok [HDTV-1080p][EAC3 Atmos 5.1][x264].mkv"

do_delete "Chris lower quality: Task (2025) {tvdb-451873}" "/mnt/synology/rs-tv/Task (2025) {tvdb-451873}/Season 01/Task (2025) - S01E01 - Crossings [WEBDL-1080p][EAC3 5.1][h264]-ETHEL.mkv"

do_delete "Chris lower quality: Justified - City Primeval (2023) {tvdb-414677}" "/mnt/synology/rs-tv/Justified - City Primeval (2023) {tvdb-414677}/Season 01/Justified - City Primeval (2023) - S01E08 - The Question [WEBDL-1080p][EAC3 5.1][h264]-NTb.mkv"

do_delete "Chris lower quality: Doom Patrol (2019) {tvdb-355622}" "/mnt/synology/rs-tv/Doom Patrol (2019) {tvdb-355622}/Season 04/Doom Patrol (2019) - S04E09 - Immortimas Patrol [WEBDL-1080p][EAC3 5.1][h264]-ETHEL.mkv"

do_delete "Chris lower quality: Lovecraft Country (2020) {tvdb-357864}" "/mnt/synology/rs-tv/Lovecraft Country (2020) {tvdb-357864}/Season 01/Lovecraft Country (2020) - S01E08 - Jig-a-Bobo [WEBDL-1080p][EAC3 5.1][h264]-Bobo.mkv"

do_delete "Chris lower quality: Ozark (2017) {tvdb-329089}" "/mnt/synology/rs-tv/Ozark (2017) {tvdb-329089}/Season 04/Ozark (2017) - S04E02 - Let the Great World Spin [WEBDL-1080p][EAC3 5.1][x264]-cakes.mkv"

do_delete "Chris lower quality: Berlin Station (2016) {tvdb-314995}" "/mnt/synology/rs-tv/Berlin Station (2016) {tvdb-314995}/Season 01/Berlin Station (2016) - S01E10 - Oratorio Berlin [WEBDL-1080p][EAC3 5.1][h264]-DiMEPiECE.mkv"

do_delete "Chris lower quality: Mad Men (2007) {tvdb-80337}" "/mnt/synology/rs-tv/Mad Men (2007) {tvdb-80337}/Season 03/Mad Men (2007) - S03E06 - Guy Walks Into an Advertising Agency [HDTV-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Top Gear (2002) {tvdb-74608}" "/mnt/synology/rs-tv/Top Gear (2002) {tvdb-74608}/Season 21/Top Gear (2002) - S21E01 - Episode 1 [WEBDL-1080p][EAC3 2.0][h264].mkv"

do_delete "Chris lower quality: Reprisal (2019) {tvdb-367554}" "/mnt/synology/rs-tv/Reprisal (2019) {tvdb-367554}/Season 01/Reprisal (2019) - S01E06 - For Love of the Archipelago [WEBDL-1080p][EAC3 5.1][h264]-bamboozle.mkv"

do_delete "Chris lower quality: Raised by Wolves (2020) {tvdb-368643}" "/mnt/synology/rs-tv/Raised by Wolves (2020) {tvdb-368643}/Season 02/Raised by Wolves (2020) - S02E05 - King [WEBDL-1080p][AC3 5.1][x264]-NTb.mkv"

do_delete "Chris lower quality: Future Man (2017) {tvdb-330997}" "/mnt/synology/rs-tv/Future Man (2017) {tvdb-330997}/Season 03/Future Man (2017) - S03E03 - Trappers Delight [HDTV-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Castle Rock (2018) {tvdb-331600}" "/mnt/synology/rs-tv/Castle Rock (2018) {tvdb-331600}/Season 01/Castle Rock (2018) - S01E07 - The Queen [HDTV-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Peacemaker (2022) {tvdb-391153}" "/mnt/synology/rs-tv/Peacemaker (2022) {tvdb-391153}/Season 02/Peacemaker (2022) - S02E04 - Need I Say Door [WEBDL-1080p][EAC3 Atmos 5.1][h264]-Kitsune.mkv"

do_delete "Chris lower quality: The Lost Pirate Kingdom (2021) {tvdb-396840}" "/mnt/synology/rs-tv/The Lost Pirate Kingdom (2021) {tvdb-396840}/Season 01/The Lost Pirate Kingdom (2021) - S01E01 - Hoist the Black Flag [WEBDL-1080p][EAC3 2.0][x264]-NTb.mkv"

do_delete "Chris lower quality: Welcome to Wrexham (2022) {tvdb-403119}" "/mnt/synology/rs-tv/Welcome to Wrexham (2022) {tvdb-403119}/Season 03/Welcome to Wrexham (2022) - S03E05 - Temporary [WEBDL-1080p][EAC3 5.1][h264]-ELEANOR.mkv"

do_delete "Chris lower quality: The Handmaid's Tale (2017) {tvdb-321239}" "/mnt/synology/rs-tv/The Handmaid's Tale (2017) {tvdb-321239}/Season 05/The Handmaid's Tale (2017) - S05E10 - Safe [WEBDL-1080p][EAC3 5.1][h264]-ggez.mkv"

do_delete "Chris lower quality: Watchmen (2019) {tvdb-360733}" "/mnt/synology/rs-tv/Watchmen (2019) {tvdb-360733}/Season 01/Watchmen (2019) - S01E09 - See How They Fly [HDTV-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: The Blacklist (2013) {tvdb-266189}" "/mnt/synology/rs-tv/The Blacklist (2013) {tvdb-266189}/Season 10/The Blacklist (2013) - S10E22 - Raymond Reddington Good Night 2 [WEBDL-1080p][EAC3 5.1][h264]-NTb.mkv"

do_delete "Chris lower quality: DuckTales (2017) {tvdb-330134}" "/mnt/synology/rs-tv/DuckTales (2017) {tvdb-330134}/Season 03/DuckTales (2017) - S03E20 - The Lost Cargo of Kit Cloudkicker! [WEBDL-1080p][EAC3 2.0][h264]-LAZY.mkv"

do_delete "Chris lower quality: The War of the Worlds (2019) {tvdb-348204}" "/mnt/synology/rs-tv/The War of the Worlds (2019) {tvdb-348204}/Season 01/The War of the Worlds (2019) - S01E01 - Episode 1 [HDTV-1080p][EAC3 2.0][h264].mkv"

do_delete "Chris lower quality: Supergirl (2015) {tvdb-295759}" "/mnt/synology/rs-tv/Supergirl (2015) {tvdb-295759}/Season 02/Supergirl (2015) - S02E01 - The Adventures of Supergirl [WEBRip-1080p][EAC3 5.1][x264]-RTN.mkv"

do_delete "Chris lower quality: Agatha All Along (2024) {tvdb-412429}" "/mnt/synology/rs-tv/Agatha All Along (2024) {tvdb-412429}/Season 01/Agatha All Along (2024) - S01E04 - If I Cant Reach You Let My Song Teach You [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Modern Family (2009) {tvdb-95011}" "/mnt/synology/rs-tv/Modern Family (2009) {tvdb-95011}/Season 11/Modern Family (2009) - S11E18 - Finale 2 [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: WWII in HD (2009) {tvdb-124511}" "/mnt/synology/rs-tv/WWII in HD (2009) {tvdb-124511}/Season 01/WWII in HD (2009) - S01E02 - Hard Way Back [Bluray-1080p Remux][DTS-HD MA 5.1][VC1]-FraMeSToR.mkv"

do_delete "Chris lower quality: Marvel's The Punisher (2017) {tvdb-331980}" "/mnt/synology/rs-tv/Marvel's The Punisher (2017) {tvdb-331980}/Season 02/Marvel's The Punisher (2017) - S02E13 - The Whirlwind [HDTV-1080p][EAC3 Atmos 5.1][HDR10][h265].mkv"

do_delete "Chris lower quality: Benjamin Franklin (2022) {tvdb-415024}" "/mnt/synology/rs-tv/Benjamin Franklin (2022) {tvdb-415024}/Season 01/Benjamin Franklin (2022) - S01E02 - An American 1775–1790 [WEBDL-1080p][AAC 2.0][h264]-BAE.mkv"

do_delete "Chris lower quality: Stargate SG-1 (1997) {tvdb-72449}" "/mnt/synology/rs-tv/Stargate SG-1 (1997) {tvdb-72449}/Season 06/Stargate SG-1 (1997) - S06E07 - Shadow Play [HDTV-1080p][MP2 2.0][h264]-SFM.mkv"

do_delete "Chris lower quality: X-Men '97 (2024) {tvdb-412432}" "/mnt/synology/rs-tv/X-Men '97 (2024) {tvdb-412432}/Season 01/X-Men '97 (2024) - S01E10 - Tolerance is Extinction 3 [WEBDL-1080p][EAC3 Atmos 5.1][h264]-TheCuteness.mkv"

do_delete "Chris lower quality: Solar Opposites (2020) {tvdb-375892}" "/mnt/synology/rs-tv/Solar Opposites (2020) {tvdb-375892}/Season 06/Solar Opposites (2020) - S06E10 - What is the Mission Anyway [WEBDL-1080p][EAC3 5.1][h264]-ETHEL.mkv"

do_delete "Chris lower quality: The Witcher (2019) {tvdb-362696}" "/mnt/synology/rs-tv/The Witcher (2019) {tvdb-362696}/Season 01/The Witcher (2019) - S01E06 - Rare Species [WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTG.mkv"

do_delete "Chris lower quality: Space Force (2020) {tvdb-368667}" "/mnt/synology/rs-tv/Space Force (2020) {tvdb-368667}/Season 02/Space Force (2020) - S02E02 - BUDGET CUTS [WEBDL-1080p][EAC3 Atmos 5.1][x264]-TEPES.mkv"

do_delete "Chris lower quality: V (1984) {tvdb-76354}" "/mnt/synology/rs-tv/V (1984) {tvdb-76354}/Season 01/V (1984) - S01E18 - The Secret Underground [DVD][MP3 1.0][XviD]-SFM.avi"

do_delete "Chris lower quality: Letterkenny (2016) {tvdb-302938}" "/mnt/synology/rs-tv/Letterkenny (2016) {tvdb-302938}/Season 10/Letterkenny (2016) - S10E05 - VidVok [WEBDL-1080p][AC3 5.1][h264]-NTb.mkv"

do_delete "Chris lower quality: The Morning Show (2019) {tvdb-361563}" "/mnt/synology/rs-tv/The Morning Show (2019) {tvdb-361563}/Season 02/The Morning Show (2019) - S02E10 - Fever [WEBDL-1080p][EAC3 Atmos 5.1][h264]-PECULATE.mkv"

do_delete "Chris lower quality: Marvel's Daredevil (2015) {tvdb-281662}" "/mnt/synology/rs-tv/Marvel's Daredevil (2015) {tvdb-281662}/Season 01/Marvel's Daredevil (2015) - S01E09 - Speak of the Devil [HDTV-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Rome (2005) {tvdb-73508}" "/mnt/synology/rs-tv/Rome (2005) {tvdb-73508}/Season 02/Rome (2005) - S02E10 - De Patre Vostro About Your Father [HDTV-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Young Rock (2021) {tvdb-375995}" "/mnt/synology/rs-tv/Young Rock (2021) {tvdb-375995}/Season 02/Young Rock (2021) - S02E02 - Seven Bucks [WEBDL-1080p][EAC3 5.1][h264]-GOSSIP.mkv"

do_delete "Chris lower quality: Star Wars Resistance (2018) {tvdb-351575}" "/mnt/synology/rs-tv/Star Wars Resistance (2018) {tvdb-351575}/Season 01/Star Wars Resistance (2018) - S01E18 - Descent [WEBDL-1080p][AC3 5.1][h264].mkv"

do_delete "Chris lower quality: Moonbase 8 (2020) {tvdb-366383}" "/mnt/synology/rs-tv/Moonbase 8 (2020) {tvdb-366383}/Season 01/Moonbase 8 (2020) - S01E01 - Dry [HDTV-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: The Magicians (2015) {tvdb-299139}" "/mnt/synology/rs-tv/The Magicians (2015) {tvdb-299139}/Season 04/The Magicians (2015) - S04E06 - A Timeline and Place [HDTV-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Marvel's Guardians of the Galaxy (2015) {tvdb-293614}" "/mnt/synology/rs-tv/Marvel's Guardians of the Galaxy (2015) {tvdb-293614}/Season 03/Marvel's Guardians of the Galaxy (2015) - S03E16 - Black Vortex 3 [HDTV-1080p][EAC3 5.1][x264].mkv"

do_delete "Chris lower quality: The Spanish Princess (2019) {tvdb-360667}" "/mnt/synology/rs-tv/The Spanish Princess (2019) {tvdb-360667}/Season 02/The Spanish Princess (2019) - S02E07 - Faith [HDTV-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: The Buccaneers (2023) {tvdb-421633}" "/mnt/synology/rs-tv/The Buccaneers (2023) {tvdb-421633}/Season 01/The Buccaneers (2023) - S01E03 - The Perfect Duchess [ATVP][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: DAVE (2020) {tvdb-354905}" "/mnt/synology/rs-tv/DAVE (2020) {tvdb-354905}/Season 02/DAVE (2020) - S02E10 - Dave [WEBDL-1080p][EAC3 5.1][h264]-TEPES.mkv"

do_delete "Chris lower quality: Rick and Morty (2013) {tvdb-275274}" "/mnt/synology/rs-tv/Rick and Morty (2013) {tvdb-275274}/Season 05/Rick and Morty (2013) - S05E07 - Gotron Jerrysis Rickvangelion [WEBDL-1080p][EAC3 5.1][h264]-FAST.mkv"

do_delete "Chris lower quality: Cobra Kai (2018) {tvdb-332858}" "/mnt/synology/rs-tv/Cobra Kai (2018) {tvdb-332858}/Season 04/Cobra Kai (2018) - S04E10 - The Rise [WEBDL-1080p][EAC3 5.1][x264]-TEPES.mkv"

do_delete "Chris lower quality: Family Guy (1999) {tvdb-75978}" "/mnt/synology/rs-tv/Family Guy (1999) {tvdb-75978}/Season 04/Family Guy (1999) - S04E30 - Stu and Stewies Excellent Adventure [[Trash] Release Sources (Streaming Service)_25_3 Release Sources (Streaming Service)_22_1][WEBDL-1080p][AAC 2.0][h264]-PHOENiX.mkv"

do_delete "Chris lower quality: Murderbot (2025) {tvdb-443396}" "/mnt/synology/rs-tv/Murderbot (2025) {tvdb-443396}/Season 01/Murderbot (2025) - S01E01 - FreeCommerce [ATVP][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Marvel's Spider-Man (2017) {tvdb-329456}" "/mnt/synology/rs-tv/Marvel's Spider-Man (2017) {tvdb-329456}/Season 03/Marvel's Spider-Man (2017) - S03E03 - Vengeance of Venom [HDTV-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Survivor (2000) {tvdb-76733}" "/mnt/synology/rs-tv/Survivor (2000) {tvdb-76733}/Season 45/Survivor (2000) - S45E13 - Living the Survivor Dream [WEBDL-1080p][EAC3 5.1][h264]-EDITH.mkv"

do_delete "Chris lower quality: Star Trek - Voyager (1995) {tvdb-74550}" "/mnt/synology/rs-tv/Star Trek - Voyager (1995) {tvdb-74550}/Season 05/Star Trek - Voyager (1995) - S05E16 - Dark Frontier 2 [WEBDL-480p][EAC3 2.0][x264]-N3TFL1X.mkv"

do_delete "Chris lower quality: Real Vikings (2016) {tvdb-320625}" "/mnt/synology/rs-tv/Real Vikings (2016) {tvdb-320625}/Season 01/Real Vikings (2016) - S01E04 - Ragnar and his Sons [SDTV][AAC 2.0][x264].mkv"

do_delete "Chris lower quality: Power (2014) {tvdb-276562}" "/mnt/synology/rs-tv/Power (2014) {tvdb-276562}/Season 06/Power (2014) - S06E01 - Murderers [HDTV-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: The Sinner (2017) {tvdb-326866}" "/mnt/synology/rs-tv/The Sinner (2017) {tvdb-326866}/Season 04/The Sinner (2017) - S04E01 - Part I [WEBDL-1080p][EAC3 5.1][h264]-GOSSIP.mkv"

do_delete "Chris lower quality: Stranger Things (2016) {tvdb-305288}" "/mnt/synology/rs-tv/Stranger Things (2016) {tvdb-305288}/Season 05/Stranger Things (2016) - S05E08 - Chapter Eight The Rightside Up [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: The Dark Crystal - Age of Resistance (2019) {tvdb-361549}" "/mnt/synology/rs-tv/The Dark Crystal - Age of Resistance (2019) {tvdb-361549}/Season 01/The Dark Crystal - Age of Resistance (2019) - S01E01 - End. Begin. All the Same [HDTV-1080p][EAC3 Atmos 5.1][x264].mkv"

do_delete "Chris lower quality: A Small Light (2023) {tvdb-428632}" "/mnt/synology/rs-tv/A Small Light (2023) {tvdb-428632}/Season 01/A Small Light (2023) - S01E05 - Scheißfeld [WEBDL-1080p][EAC3 5.1][h264]-NTb.mkv"

do_delete "Chris lower quality: SpongeBob SquarePants (1999) {tvdb-75886}" "/mnt/synology/rs-tv/SpongeBob SquarePants (1999) {tvdb-75886}/Season 16/SpongeBob SquarePants (1999) - S16E01 - SpongeBob and Patricks Timeline Twist-Up [WEBDL-1080p][EAC3 2.0][h264]-NTb.mkv"

do_delete "Chris lower quality: Disney Twisted-Wonderland - The Animation (2025) {tvdb-411393}" "/mnt/synology/rs-tv/Disney Twisted-Wonderland - The Animation (2025) {tvdb-411393}/Season 01/Disney Twisted-Wonderland - The Animation (2025) - S01E01 - Stranger Waking [DSNP][WEBDL-1080p][AAC 2.0][h264]-VARYG.mkv"

do_delete "Chris lower quality: Abbott Elementary (2021) {tvdb-402910}" "/mnt/synology/rs-tv/Abbott Elementary (2021) {tvdb-402910}/Season 03/Abbott Elementary (2021) - S03E01 - Career Day 1 [WEBDL-1080p][EAC3 5.1][h264]-ETHEL.mkv"

do_delete "Chris lower quality: This Is Us (2016) {tvdb-311714}" "/mnt/synology/rs-tv/This Is Us (2016) {tvdb-311714}/Season 06/This Is Us (2016) - S06E01 - The Challenger [WEBDL-1080p][EAC3 5.1][h264]-dexterous.mkv"

do_delete "Chris lower quality: Once Upon a Time (2011) {tvdb-248835}" "/mnt/synology/rs-tv/Once Upon a Time (2011) {tvdb-248835}/Season 02/Once Upon a Time (2011) - S02E11 - The Outsider [WEBDL-1080p][EAC3 5.1][h264]-HDCTV.mkv"

do_delete "Chris lower quality: Talamasca - The Secret Order (2025) {tvdb-433933}" "/mnt/synology/rs-tv/Talamasca - The Secret Order (2025) {tvdb-433933}/Season 01/Talamasca - The Secret Order (2025) - S01E01 - We Watch. And We Are Always There [STAN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Arrow (2012) {tvdb-257655}" "/mnt/synology/rs-tv/Arrow (2012) {tvdb-257655}/Season 06/Arrow (2012) - S06E20 - Shifting Allegiances [HDTV-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Community (2009) {tvdb-94571}" "/mnt/synology/rs-tv/Community (2009) {tvdb-94571}/Season 02/Community (2009) - S02E13 - Celebrity Pharmacology [HDTV-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: The Man in the High Castle (2015) {tvdb-295829}" "/mnt/synology/rs-tv/The Man in the High Castle (2015) {tvdb-295829}/Season 04/The Man in the High Castle (2015) - S04E02 - Every Door Out [HDTV-1080p][EAC3 5.1][x264].mkv"

do_delete "Chris lower quality: Big Little Lies (2017) {tvdb-305719}" "/mnt/synology/rs-tv/Big Little Lies (2017) {tvdb-305719}/Season 02/Big Little Lies (2017) - S02E06 - The Bad Mother [WEBDL-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Brooklyn Nine-Nine (2013) {tvdb-269586}" "/mnt/synology/rs-tv/Brooklyn Nine-Nine (2013) {tvdb-269586}/Season 08/Brooklyn Nine-Nine (2013) - S08E10 - The Last Day 2 [WEBDL-1080p][EAC3 5.1][h264]-NTb.mkv"

do_delete "Chris lower quality: Catch-22 (2019) {tvdb-357558}" "/mnt/synology/rs-tv/Catch-22 (2019) {tvdb-357558}/Season 01/Catch-22 (2019) - S01E01 - Episode 1 [HDTV-1080p][AAC 2.0][h264].mkv"

do_delete "Chris lower quality: Lupin (2021) {tvdb-375921}" "/mnt/synology/rs-tv/Lupin (2021) {tvdb-375921}/Season 02/Lupin (2021) - S02E07 - Chapter 7 [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: The Boss Baby - Back in Business (2018) {tvdb-342858}" "/mnt/synology/rs-tv/The Boss Baby - Back in Business (2018) {tvdb-342858}/Season 04/The Boss Baby - Back in Business (2018) - S04E12 - Theo 100 [WEBDL-1080p][EAC3 5.1][x264].mkv"

do_delete "Chris lower quality: Star Trek - Picard (2020) {tvdb-364093}" "/mnt/synology/rs-tv/Star Trek - Picard (2020) {tvdb-364093}/Season 02/Star Trek - Picard (2020) - S02E04 - Watcher [WEBDL-1080p][EAC3 5.1][h264]-KOGi.mkv"

do_delete "Chris lower quality: How I Met Your Mother (2005) {tvdb-75760}" "/mnt/synology/rs-tv/How I Met Your Mother (2005) {tvdb-75760}/Season 02/How I Met Your Mother (2005) - S02E04 - Ted Mosby Architect [HDTV-1080p][AC3 5.1][h264].mkv"

do_delete "Chris lower quality: Tell Me Lies (2022) {tvdb-393269}" "/mnt/synology/rs-tv/Tell Me Lies (2022) {tvdb-393269}/Season 03/Tell Me Lies (2022) - S03E01 - You F-cked It Friend [DSNP][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: The Penguin (2024) {tvdb-417648}" "/mnt/synology/rs-tv/The Penguin (2024) {tvdb-417648}/Season 01/The Penguin (2024) - S01E03 - Bliss [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Marco Polo (2014) {tvdb-266091}" "/mnt/synology/rs-tv/Marco Polo (2014) {tvdb-266091}/Season 01/Marco Polo (2014) - S01E06 - White Moon [HDTV-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: See (2019) {tvdb-361565}" "/mnt/synology/rs-tv/See (2019) {tvdb-361565}/Season 02/See (2019) - S02E01 - Brothers and Sisters [WEBDL-1080p][EAC3 Atmos 5.1][h264]-iLLiCiT.mkv"

do_delete "Chris lower quality: Fargo (2014) {tvdb-269613}" "/mnt/synology/rs-tv/Fargo (2014) {tvdb-269613}/Season 04/Fargo (2014) - S04E01 - Welcome to the Alternate Economy [WEBDL-1080p][EAC3 5.1][h264]-STRONTiUM.mkv"

do_delete "Chris lower quality: Ash vs Evil Dead (2015) {tvdb-296295}" "/mnt/synology/rs-tv/Ash vs Evil Dead (2015) {tvdb-296295}/Season 02/Ash vs Evil Dead (2015) - S02E01 - Home [HDTV-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Teacup (2024) {tvdb-446180}" "/mnt/synology/rs-tv/Teacup (2024) {tvdb-446180}/Season 01/Teacup (2024) - S01E08 - This Is Nowhere 2 [WEBDL-1080p][EAC3 5.1][x264]-SuccessfulCrab.mkv"

do_delete "Chris lower quality: Blue Planet II (2017) {tvdb-330942}" "/mnt/synology/rs-tv/Blue Planet II (2017) {tvdb-330942}/Season 01/Blue Planet II (2017) - S01E05 - Green Seas [HDTV-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Curb Your Enthusiasm (2000) {tvdb-76203}" "/mnt/synology/rs-tv/Curb Your Enthusiasm (2000) {tvdb-76203}/Season 11/Curb Your Enthusiasm (2000) - S11E10 - The Mormon Advantage [WEBDL-1080p][AC3 5.1][x264]-NTb.mkv"

do_delete "Chris lower quality: Suits (2011) {tvdb-247808}" "/mnt/synology/rs-tv/Suits (2011) {tvdb-247808}/Season 09/Suits (2011) - S09E10 - One Last Con [WEBDL-1080p][EAC3 5.1][h264]-NDy.mkv"

do_delete "Chris lower quality: True Detective (2014) {tvdb-270633}" "/mnt/synology/rs-tv/True Detective (2014) {tvdb-270633}/Season 04/True Detective (2014) - S04E01 - Night Country Part 1 [WEBDL-1080p Proper][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Dune - Prophecy (2024) {tvdb-367118}" "/mnt/synology/rs-tv/Dune - Prophecy (2024) {tvdb-367118}/Season 01/Dune - Prophecy (2024) - S01E04 - Twice Born [WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv"

do_delete "Chris lower quality: History of the World, Part II (2023) {tvdb-412421}" "/mnt/synology/rs-tv/History of the World, Part II (2023) {tvdb-412421}/Season 01/History of the World, Part II (2023) - S01E02 - II [WEBDL-1080p][EAC3 5.1][h264]-GGEZ.mkv"

do_delete "Chris lower quality: Carnival Row (2019) {tvdb-365026}" "/mnt/synology/rs-tv/Carnival Row (2019) {tvdb-365026}/Season 02/Carnival Row (2019) - S02E02 - New Dawn [WEBDL-1080p Proper][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Helstrom (2020) {tvdb-364038}" "/mnt/synology/rs-tv/Helstrom (2020) {tvdb-364038}/Season 01/Helstrom (2020) - S01E10 - Hell Storm [HDTV-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Bodyguard (2018) {tvdb-349310}" "/mnt/synology/rs-tv/Bodyguard (2018) {tvdb-349310}/Season 01/Bodyguard (2018) - S01E02 - Episode 2 [HDTV-1080p][EAC3 2.0][h264].mkv"

do_delete "Chris lower quality: Frontier (2016) {tvdb-316517}" "/mnt/synology/rs-tv/Frontier (2016) {tvdb-316517}/Season 03/Frontier (2016) - S03E04 - All for All and None for One [HDTV-1080p][EAC3 5.1][x264].mkv"

do_delete "Chris lower quality: Stick (2025) {tvdb-455562}" "/mnt/synology/rs-tv/Stick (2025) {tvdb-455562}/Season 01/Stick (2025) - S01E10 - Déjà Vu All Over Again [WEBDL-1080p][EAC3 Atmos 5.1][h264]-Kitsune.mkv"

do_delete "Chris lower quality: Gotham (2014) {tvdb-274431}" "/mnt/synology/rs-tv/Gotham (2014) {tvdb-274431}/Season 05/Gotham (2014) - S05E11 - They Did What [HDTV-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Mythic Quest (2020) {tvdb-362829}" "/mnt/synology/rs-tv/Mythic Quest (2020) {tvdb-362829}/Season 04/Mythic Quest (2020) - S04E04 - The Villains Feast [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: The A-Team (1983) {tvdb-77904}" "/mnt/synology/rs-tv/The A-Team (1983) {tvdb-77904}/Season 03/The A-Team (1983) - S03E11 - The Bells of St. Mary's [HDTV-1080p][DTS 2.0][x264].mkv"

do_delete "Chris lower quality: Fresh Off the Boat (2015) {tvdb-281618}" "/mnt/synology/rs-tv/Fresh Off the Boat (2015) {tvdb-281618}/Season 06/Fresh Off the Boat (2015) - S06E05 - Hal-Lou-Ween [WEBDL-1080p][EAC3 5.1][h264]-NTb.mkv"

do_delete "Chris lower quality: The X-Files (1993) {tvdb-77398}" "/mnt/synology/rs-tv/The X-Files (1993) {tvdb-77398}/Season 11/The X-Files (1993) - S11E06 - Kitten [Bluray-1080p][AC3 5.1][x264]-SA89.mkv"

do_delete "Chris lower quality: Vikings (2013) {tvdb-260449}" "/mnt/synology/rs-tv/Vikings (2013) {tvdb-260449}/Season 05/Vikings (2013) - S05E02 - The Departed Part 2 [[Trash] Release Sources (Streaming Service)_25_0 Release Sources (Streaming Service)_22_5][WEBDL-1080p][EAC3 5.1][h264]-NTb.mkv"

do_delete "Chris lower quality: Nightflyers (2018) {tvdb-347648}" "/mnt/synology/rs-tv/Nightflyers (2018) {tvdb-347648}/Season 01/Nightflyers (2018) - S01E05 - Greywing [HDTV-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Nine Perfect Strangers (2021) {tvdb-376815}" "/mnt/synology/rs-tv/Nine Perfect Strangers (2021) {tvdb-376815}/Season 01/Nine Perfect Strangers (2021) - S01E03 - Earth Day [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: John Adams (2008) {tvdb-81547}" "/mnt/synology/rs-tv/John Adams (2008) {tvdb-81547}/Season 01/John Adams (2008) - S01E02 - Independence [HDTV-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Poker Face (2023) {tvdb-398822}" "/mnt/synology/rs-tv/Poker Face (2023) {tvdb-398822}/Season 02/Poker Face (2023) - S02E01 - The Game Is a Foot [WEBDL-1080p][EAC3 5.1][x264]-ETHEL.mkv"

do_delete "Chris lower quality: Mr. Robot (2015) {tvdb-289590}" "/mnt/synology/rs-tv/Mr. Robot (2015) {tvdb-289590}/Season 04/Mr. Robot (2015) - S04E05 - 405 Method Not Allowed [WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv"

do_delete "Chris lower quality: The Outsider (2020) {tvdb-365480}" "/mnt/synology/rs-tv/The Outsider (2020) {tvdb-365480}/Season 01/The Outsider (2020) - S01E08 - Foxhead [HDTV-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Treadstone (2019) {tvdb-366090}" "/mnt/synology/rs-tv/Treadstone (2019) {tvdb-366090}/Season 01/Treadstone (2019) - S01E01 - The Cicada Protocol [HDTV-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Stumptown (2019) {tvdb-359581}" "/mnt/synology/rs-tv/Stumptown (2019) {tvdb-359581}/Season 01/Stumptown (2019) - S01E08 - The Other Woman [HDTV-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Joe Pickett (2021) {tvdb-399244}" "/mnt/synology/rs-tv/Joe Pickett (2021) {tvdb-399244}/Season 02/Joe Pickett (2021) - S02E05 - Heads Will Roll [WEBDL-1080p][EAC3 5.1][h264]-EDITH.mkv"

do_delete "Chris lower quality: Marvel's Iron Fist (2017) {tvdb-317953}" "/mnt/synology/rs-tv/Marvel's Iron Fist (2017) {tvdb-317953}/Season 02/Marvel's Iron Fist (2017) - S02E05 - Heart of the Dragon [HDTV-1080p][EAC3 5.1][x264].mkv"

do_delete "Chris lower quality: Longmire (2012) {tvdb-253491}" "/mnt/synology/rs-tv/Longmire (2012) {tvdb-253491}/Season 03/Longmire (2012) - S03E10 - Ashes to Ashes [WEBDL-1080p][AC3 5.1][h264]-KiNGS.mkv"

do_delete "Chris lower quality: Shōgun (2024) {tvdb-392573}" "/mnt/synology/rs-tv/Shōgun (2024) {tvdb-392573}/Season 01/Shōgun (2024) - S01E01 - Anjin [WEBDL-1080p][EAC3 5.1][h264]-SuccessfulCrab.mkv"

do_delete "Chris lower quality: NOS4A2 (2019) {tvdb-359637}" "/mnt/synology/rs-tv/NOS4A2 (2019) {tvdb-359637}/Season 02/NOS4A2 (2019) - S02E07 - Cripple Creek [HDTV-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Godless (2017) {tvdb-333801}" "/mnt/synology/rs-tv/Godless (2017) {tvdb-333801}/Season 01/Godless (2017) - S01E04 - Fathers and Sons [HDTV-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: black-ish (2014) {tvdb-281511}" "/mnt/synology/rs-tv/black-ish (2014) {tvdb-281511}/Season 07/black-ish (2014) - S07E13 - The Mother and Child De-Union [WEBDL-1080p][EAC3 5.1][h264]-NTb.mkv"

do_delete "Chris lower quality: Jurassic World - Camp Cretaceous (2020) {tvdb-365066}" "/mnt/synology/rs-tv/Jurassic World - Camp Cretaceous (2020) {tvdb-365066}/Season 02/Jurassic World - Camp Cretaceous (2020) - S02E03 - The Watering Hole [WEBDL-1080p][EAC3 5.1][x264]-NTb.mkv"

do_delete "Chris lower quality: The Newsroom (2012) {tvdb-256227}" "/mnt/synology/rs-tv/The Newsroom (2012) {tvdb-256227}/Season 03/The Newsroom (2012) - S03E06 - What Kind of Day Has It Been [WEBDL-1080p][EAC3 5.1][h264]-WADU.mkv"

do_delete "Chris lower quality: Lucifer (2016) {tvdb-295685}" "/mnt/synology/rs-tv/Lucifer (2016) {tvdb-295685}/Season 05/Lucifer (2016) - S05E14 - Nothing Lasts Forever [WEBDL-1080p][EAC3 5.1][x264]-ggez.mkv"

do_delete "Chris lower quality: Marvel's Jessica Jones (2015) {tvdb-284190}" "/mnt/synology/rs-tv/Marvel's Jessica Jones (2015) {tvdb-284190}/Season 03/Marvel's Jessica Jones (2015) - S03E02 - AKA Youre Welcome [HDTV-1080p][EAC3 Atmos 5.1][x264].mkv"

do_delete "Chris lower quality: The Winter King (2023) {tvdb-428022}" "/mnt/synology/rs-tv/The Winter King (2023) {tvdb-428022}/Season 01/The Winter King (2023) - S01E09 - Episode 9 [WEBDL-1080p][EAC3 5.1][h264]-EDITH.mkv"

do_delete "Chris lower quality: Last Man Standing (2011) {tvdb-248834}" "/mnt/synology/rs-tv/Last Man Standing (2011) {tvdb-248834}/Season 09/Last Man Standing (2011) - S09E08 - Lost and Found [WEBDL-1080p][EAC3 5.1][h264]-NTb.mkv"

do_delete "Chris lower quality: V-Wars (2019) {tvdb-371610}" "/mnt/synology/rs-tv/V-Wars (2019) {tvdb-371610}/Season 01/V-Wars (2019) - S01E01 - Down with the Sickness [HDTV-1080p][EAC3 Atmos 5.1][x264].mkv"

do_delete "Chris lower quality: That '90s Show (2023) {tvdb-411173}" "/mnt/synology/rs-tv/That '90s Show (2023) {tvdb-411173}/Season 02/That '90s Show (2023) - S02E01 - You Oughta Know [WEBDL-1080p][EAC3 5.1][x264]-ETHEL.mkv"

do_delete "Chris lower quality: Westworld (2016) {tvdb-296762}" "/mnt/synology/rs-tv/Westworld (2016) {tvdb-296762}/Season 04/Westworld (2016) - S04E08 - Que Será Será [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: The Big Bang Theory (2007) {tvdb-80379}" "/mnt/synology/rs-tv/The Big Bang Theory (2007) {tvdb-80379}/Season 08/The Big Bang Theory (2007) - S08E08 - The Prom Equivalency [HDTV-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: Charlie's Angels (1976) {tvdb-77170}" "/mnt/synology/rs-tv/Charlie's Angels (1976) {tvdb-77170}/Season 02/Charlie's Angels (1976) - S02E04 - Angels on Ice 2 [WEBDL-1080p][AAC 2.0][h264]-PiRaTeS.mkv"

do_delete "Chris lower quality: His Dark Materials (2019) {tvdb-360295}" "/mnt/synology/rs-tv/His Dark Materials (2019) {tvdb-360295}/Season 02/His Dark Materials (2019) - S02E07 - Æsahættr [WEBDL-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: A Murder at the End of the World (2023) {tvdb-408696}" "/mnt/synology/rs-tv/A Murder at the End of the World (2023) {tvdb-408696}/Season 01/A Murder at the End of the World (2023) - S01E01 - Homme Fatale [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: Archer (2009) {tvdb-110381}" "/mnt/synology/rs-tv/Archer (2009) {tvdb-110381}/Season 14/Archer (2009) - S14E09 - Into the Cold [WEBDL-1080p][EAC3 5.1][h264]-NTb.mkv"

do_delete "Chris lower quality: Your Friendly Neighborhood Spider-Man (2025) {tvdb-412427}" "/mnt/synology/rs-tv/Your Friendly Neighborhood Spider-Man (2025) {tvdb-412427}/Season 01/Your Friendly Neighborhood Spider-Man (2025) - S01E02 - The Parker Luck [DSNP][WEBDL-1080p][EAC3 Atmos 5.1][h264]-APEX.mkv"

do_delete "Chris lower quality: Silicon Valley (2014) {tvdb-277165}" "/mnt/synology/rs-tv/Silicon Valley (2014) {tvdb-277165}/Season 03/Silicon Valley (2014) - S03E09 - Daily Active Users [HDTV-1080p][DTS-HD MA 5.1][h264].mkv"

do_delete "Chris lower quality: Cursed (2020) {tvdb-369950}" "/mnt/synology/rs-tv/Cursed (2020) {tvdb-369950}/Season 01/Cursed (2020) - S01E01 - Nimue [WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTG.mkv"

do_delete "Chris lower quality: The White Lotus (2021) {tvdb-390430}" "/mnt/synology/rs-tv/The White Lotus (2021) {tvdb-390430}/Season 03/The White Lotus (2021) - S03E08 - Amor Fati [WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTb.mkv"

do_delete "Chris lower quality: Bob's Burgers (2011) {tvdb-194031}" "/mnt/synology/rs-tv/Bob's Burgers (2011) {tvdb-194031}/Season 15/Bob's Burgers (2011) - S15E10 - Advice Things Are Ad-nice [WEBDL-1080p][EAC3 5.1][h264]-EDITH.mkv"

do_delete "Chris lower quality: Californication (2007) {tvdb-80349}" "/mnt/synology/rs-tv/Californication (2007) {tvdb-80349}/Season 04/Californication (2007) - S04E01 - Exile on Main St [HDTV-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: Van Helsing (2016) {tvdb-308772}" "/mnt/synology/rs-tv/Van Helsing (2016) {tvdb-308772}/Season 05/Van Helsing (2016) - S05E13 - Novissima Solis [WEBDL-1080p][AAC 2.0][h264]-ggez.mkv"

do_delete "Chris lower quality: ALF (1986) {tvdb-78020}" "/mnt/synology/rs-tv/ALF (1986) {tvdb-78020}/Season 01/ALF (1986) - S01E17 - Try to Remember 2 [[Trash] Release Sources (Streaming Service)_25_6 Release Sources (Streaming Service)_22_3][WEBDL-1080p][AC3 2.0][x264]-dB.mkv"

do_delete "Chris lower quality: Riverdale (2017) {tvdb-311954}" "/mnt/synology/rs-tv/Riverdale (2017) {tvdb-311954}/Season 03/Riverdale (2017) - S03E15 - Chapter Fifty American Dreams [WEBDL-1080p][EAC3 5.1][x264]-NTb.mkv"

do_delete "Chris lower quality: The Haunting (2018) {tvdb-345246}" "/mnt/synology/rs-tv/The Haunting (2018) {tvdb-345246}/Season 01/The Haunting (2018) - S01E10 - Silence Lay Steadily [WEBDL-1080p Proper][EAC3 Atmos 5.1][x264]-DEFLATE.mkv"

do_delete "Chris lower quality: Twisted Metal (2023) {tvdb-366532}" "/mnt/synology/rs-tv/Twisted Metal (2023) {tvdb-366532}/Season 02/Twisted Metal (2023) - S02E11 - OHLYNTE [WEBDL-1080p][EAC3 5.1][h264]-lazycunts.mkv"

do_delete "Chris lower quality: Clarkson's Farm (2021) {tvdb-378165}" "/mnt/synology/rs-tv/Clarkson's Farm (2021) {tvdb-378165}/Season 02/Clarkson's Farm (2021) - S02E08 - Climaxing [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv"

do_delete "Chris lower quality: A Series of Unfortunate Events (2017) {tvdb-306304}" "/mnt/synology/rs-tv/A Series of Unfortunate Events (2017) {tvdb-306304}/Season 03/A Series of Unfortunate Events (2017) - S03E07 - The End [HDTV-1080p][EAC3 5.1][x264].mkv"

do_delete "Chris lower quality: Strike Back (2010) {tvdb-148581}" "/mnt/synology/rs-tv/Strike Back (2010) {tvdb-148581}/Season 03/Strike Back (2010) - S03E02 - Episode 2 [Bluray-1080p][AC3 5.1][x264]-SA89.mkv"

do_delete "Chris lower quality: The Librarians (2014) {tvdb-281709}" "/mnt/synology/rs-tv/The Librarians (2014) {tvdb-281709}/Season 04/The Librarians (2014) - S04E01 - And the Dark Secret [WEBDL-1080p][EAC3 5.1][h264]-QOQ.mkv"

do_delete "Chris lower quality: The Orville (2017) {tvdb-328487}" "/mnt/synology/rs-tv/The Orville (2017) {tvdb-328487}/Season 03/The Orville (2017) - S03E08 - Midnight Blue [WEBDL-1080p][EAC3 5.1][h264]-ggez.mkv"

do_delete "Chris lower quality: Killjoys (2015) {tvdb-281534}" "/mnt/synology/rs-tv/Killjoys (2015) {tvdb-281534}/Season 02/Killjoys (2015) - S02E08 - Full Metal Monk [HDTV-1080p][DTS 5.1][x264].mkv"

do_delete "Chris lower quality: A Discovery of Witches (2018) {tvdb-351291}" "/mnt/synology/rs-tv/A Discovery of Witches (2018) {tvdb-351291}/Season 02/A Discovery of Witches (2018) - S02E01 - Episode 1 [WEBDL-1080p][EAC3 2.0][h264].mkv"

do_delete "Chris lower quality: Succession (2018) {tvdb-338186}" "/mnt/synology/rs-tv/Succession (2018) {tvdb-338186}/Season 04/Succession (2018) - S04E06 - Living+ [WEBDL-1080p][EAC3 5.1][h264]-NTb.mkv"

do_delete "Chris lower quality: Star Wars Rebels (2014) {tvdb-283468}" "/mnt/synology/rs-tv/Star Wars Rebels (2014) {tvdb-283468}/Season 03/Star Wars Rebels (2014) - S03E10 - Visions and Voices [HDTV-1080p][AC3 5.1][h264].mkv"

do_delete "Chris lower quality: Band of Brothers (2001) {tvdb-74205}" "/mnt/synology/rs-tv/Band of Brothers (2001) {tvdb-74205}/Specials/Band of Brothers (2001) - S00E01 - Premiere in Normandy [Bluray-1080p][DTS 5.1][x264]-WiKi.mkv"

do_delete "Chris lower quality: The Transformers (1984) {tvdb-72499}" "/mnt/synology/rs-tv/The Transformers (1984) {tvdb-72499}/Season 02/The Transformers (1984) - S02E08 - A Prime Problem [SDTV][MP3 2.0][x264].mkv"

do_delete "Chris lower quality: Chernobyl (2019) {tvdb-360893}" "/mnt/synology/rs-tv/Chernobyl (2019) {tvdb-360893}/Season 01/Chernobyl (2019) - S01E05 - Vichnaya Pamyat [HDTV-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: American Gods (2017) {tvdb-253573}" "/mnt/synology/rs-tv/American Gods (2017) {tvdb-253573}/Season 03/American Gods (2017) - S03E01 - A Winters Tale [WEBDL-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Planet Earth II (2016) {tvdb-318408}" "/mnt/synology/rs-tv/Planet Earth II (2016) {tvdb-318408}/Season 01/Planet Earth II (2016) - S01E02 - Mountains [HDTV-1080p][DTS-HD MA 5.1][x264].mkv"

do_delete "Chris lower quality: Batman - The Animated Series (1992) {tvdb-76168}" "/mnt/synology/rs-tv/Batman - The Animated Series (1992) {tvdb-76168}/Season 02/Batman - The Animated Series (1992) - S02E08 - Avatar [WEBDL-1080p][AC3 2.0][x264]-SLiGNOME.mkv"

do_delete "Chris lower quality: Our Flag Means Death (2022) {tvdb-390093}" "/mnt/synology/rs-tv/Our Flag Means Death (2022) {tvdb-390093}/Season 02/Our Flag Means Death (2022) - S02E08 - Mermen [WEBDL-1080p][EAC3 Atmos 5.1][x264]-successfulcrab.mkv"

do_delete "Chris lower quality: Undone (2019) {tvdb-357756}" "/mnt/synology/rs-tv/Undone (2019) {tvdb-357756}/Season 01/Undone (2019) - S01E02 - The Hospital [HDTV-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: A Teacher (2020) {tvdb-352440}" "/mnt/synology/rs-tv/A Teacher (2020) {tvdb-352440}/Season 01/A Teacher (2020) - S01E09 - Episode 9 [WEBDL-1080p][EAC3 5.1][h264].mkv"

do_delete "Chris lower quality: Bel-Air (2022) {tvdb-388151}" "/mnt/synology/rs-tv/Bel-Air (2022) {tvdb-388151}/Season 01/Bel-Air (2022) - S01E01 - Dreams and Nightmares [WEBDL-1080p Proper][EAC3 5.1][x264]-NTb.mkv"

do_delete "Chris lower quality: Planet Earth (2006) {tvdb-79257}" "/mnt/synology/rs-tv/Planet Earth (2006) {tvdb-79257}/Season 01/Planet Earth (2006) - S01E03 - Fresh Water [HDTV-1080p][AC3 5.1][x264].mkv"

do_delete "Chris lower quality: The Summer I Turned Pretty (2022) {tvdb-396505}" "/mnt/synology/rs-tv/The Summer I Turned Pretty (2022) {tvdb-396505}/Season 02/The Summer I Turned Pretty (2022) - S02E08 - Love Triangle [WEBDL-1080p][EAC3 5.1][h264]-NTb.mkv"


log "Deletion script complete!"
