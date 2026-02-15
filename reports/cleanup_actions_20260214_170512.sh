#!/bin/bash
#==============================================================================
# Duplicate Cleanup Script - TV
# Generated: 2026-02-14 17:05:12
# Groups with duplicates: 296
# Files to remove: 459
# Space to reclaim: 716.81 GB
#
# Usage:
#   DRY_RUN=true ./cleanup_actions_20260214_170512.sh    # Preview (default)
#   DRY_RUN=false ./cleanup_actions_20260214_170512.sh   # Actually cleanup
#==============================================================================

DRY_RUN="${DRY_RUN:-true}"
REMOVED=0
FAILED=0
SKIPPED=0

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m"

log() { echo -e "[$(date "+%Y-%m-%d %H:%M:%S")] $1"; }

cleanup_file() {
    local file="$1"
    local desc="$2"
    if [ ! -e "$file" ]; then
        log "${YELLOW}SKIP${NC} [not found] $desc"
        ((SKIPPED++))
        return 0
    fi
    if [ "$DRY_RUN" = "true" ]; then
        log "${BLUE}[DRY RUN]${NC} Would remove: $desc"
        log "  $file"
        ((REMOVED++))
        return 0
    fi
    if rm -f "$file"; then
        log "${GREEN}REMOVED${NC}: $desc"
        ((REMOVED++))
    else
        log "${RED}FAILED${NC}: $desc"
        ((FAILED++))
    fi
}

log "Starting duplicate cleanup..."
if [ "$DRY_RUN" = "true" ]; then
    log "${BLUE}DRY RUN MODE - no files will be modified${NC}"
fi
echo ""

# Group: Anne with an E (2017) {tvdb-322971}/Season 01/S01E07
# KEEP: Anne with an E (2017) - S01E07 - Wherever You Are is My Home [Bluray-1080p][AC3 5.1][x264]-iNGOT.mkv (score: 3276)
cleanup_file "/mnt/synology/rs-tv/Anne with an E (2017) {tvdb-322971}/Season 01/Anne with an E (2017) - S01E07 - Wherever You Are is My Home [Bluray-1080p][AC3 5.1][x264].mkv" "Anne with an E (2017) - S01E07 - Wherever You Are is My Home [Bluray-1080p][AC3 5.1][x264].mkv (score: 3276 vs keeper 3276)"

# Group: Bel-Air (2022) {tvdb-388151}/Season 01/S01E01
# KEEP: Bel-Air (2022) - S01E01 - Dreams and Nightmares [WEBDL-1080p][EAC3 5.1][h264]-NTb.mkv (score: 3538)
cleanup_file "/mnt/synology/rs-tv/Bel-Air (2022) {tvdb-388151}/Season 01/Bel-Air (2022) - S01E01 - Dreams and Nightmares [WEBDL-1080p Proper][EAC3 5.1][x264]-NTb.mkv" "Bel-Air (2022) - S01E01 - Dreams and Nightmares [WEBDL-1080p Proper][EAC3 5.1][x264]-NTb.mkv (score: 3533 vs keeper 3538)"

# Group: Black Mirror (2011) {tvdb-253463}/Season 07/S07E02
# KEEP: Black Mirror (2011) - S07E02 - Bête Noire [WEBDL-720p][EAC3 Atmos 5.1][x264]-FLUX.mkv (score: 1857)
cleanup_file "/mnt/synology/rs-tv/Black Mirror (2011) {tvdb-253463}/Season 07/Black Mirror (2011) - S07E02 - Bête Noire [NF][WEBDL-720p][EAC3 Atmos 5.1][x264]-FLUX.mkv" "Black Mirror (2011) - S07E02 - Bête Noire [NF][WEBDL-720p][EAC3 Atmos 5.1][x264]-FLUX.mkv (score: 1857 vs keeper 1857)"

# Group: Black Mirror (2011) {tvdb-253463}/Season 07/S07E03
# KEEP: Black Mirror (2011) - S07E03 - Hotel Reverie [WEBDL-720p][EAC3 Atmos 5.1][x264]-FLUX.mkv (score: 1859)
cleanup_file "/mnt/synology/rs-tv/Black Mirror (2011) {tvdb-253463}/Season 07/Black Mirror (2011) - S07E03 - Hotel Reverie [NF][WEBDL-720p][EAC3 Atmos 5.1][x264]-FLUX.mkv" "Black Mirror (2011) - S07E03 - Hotel Reverie [NF][WEBDL-720p][EAC3 Atmos 5.1][x264]-FLUX.mkv (score: 1859 vs keeper 1859)"

# Group: Black Mirror (2011) {tvdb-253463}/Season 07/S07E04
# KEEP: Black Mirror (2011) - S07E04 - Plaything [NF][WEBDL-720p][EAC3 Atmos 5.1][x264]-FLUX.mkv (score: 1859)
cleanup_file "/mnt/synology/rs-tv/Black Mirror (2011) {tvdb-253463}/Season 07/Black Mirror (2011) - S07E04 - Plaything [WEBDL-720p][EAC3 Atmos 5.1][x264]-FLUX.mkv" "Black Mirror (2011) - S07E04 - Plaything [WEBDL-720p][EAC3 Atmos 5.1][x264]-FLUX.mkv (score: 1859 vs keeper 1859)"

# Group: Black Mirror (2011) {tvdb-253463}/Season 07/S07E05
# KEEP: Black Mirror (2011) - S07E05 - Eulogy [WEBDL-720p][EAC3 Atmos 5.1][x264]-FLUX.mkv (score: 1855)
cleanup_file "/mnt/synology/rs-tv/Black Mirror (2011) {tvdb-253463}/Season 07/Black Mirror (2011) - S07E05 - Eulogy [NF][WEBDL-720p][EAC3 Atmos 5.1][x264]-FLUX.mkv" "Black Mirror (2011) - S07E05 - Eulogy [NF][WEBDL-720p][EAC3 Atmos 5.1][x264]-FLUX.mkv (score: 1855 vs keeper 1855)"

# Group: Black Mirror (2011) {tvdb-253463}/Season 07/S07E06
# KEEP: Black Mirror (2011) - S07E06 - USS Callister Into Infinity [WEBDL-720p][EAC3 Atmos 5.1][x264]-FLUX.mkv (score: 1866)
cleanup_file "/mnt/synology/rs-tv/Black Mirror (2011) {tvdb-253463}/Season 07/Black Mirror (2011) - S07E06 - USS Callister Into Infinity [NF][WEBDL-720p][EAC3 Atmos 5.1][x264]-FLUX.mkv" "Black Mirror (2011) - S07E06 - USS Callister Into Infinity [NF][WEBDL-720p][EAC3 Atmos 5.1][x264]-FLUX.mkv (score: 1866 vs keeper 1866)"

# Group: Bob's Burgers (2011) {tvdb-194031}/Season 16/S16E10
# KEEP: Bob's Burgers (2011) - S16E10 - Heist Things Are Heist [DSNP][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3505)
cleanup_file "/mnt/synology/rs-tv/Bob's Burgers (2011) {tvdb-194031}/Season 16/Bob's Burgers (2011) - S16E10 - Heist Things Are Heist [[Trash] Release Sources (Streaming Service)_25_3 Release Sources (Streaming Service)_22_1][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv" "Bob's Burgers (2011) - S16E10 - Heist Things Are Heist [[Trash] Release Sources (Streaming Service)_25_3 Release Sources (Streaming Service)_22_1][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3505 vs keeper 3505)"

# Group: Challenger - The Final Flight (2020) {tvdb-387206}/Season 01/S01E01
# KEEP: Challenger - The Final Flight (2020) - S01E01 - Space for Everyone [NF][WEBDL-1080p][EAC3 5.1][x264]-BTN.mkv (score: 3520)
cleanup_file "/mnt/synology/rs-tv/Challenger - The Final Flight (2020) {tvdb-387206}/Season 01/Challenger - The Final Flight (2020) - S01E01 - Space for Everyone [WEBDL-1080p][EAC3 5.1][x264].mkv" "Challenger - The Final Flight (2020) - S01E01 - Space for Everyone [WEBDL-1080p][EAC3 5.1][x264].mkv (score: 3520 vs keeper 3520)"

# Group: Challenger - The Final Flight (2020) {tvdb-387206}/Season 01/S01E02
# KEEP: Challenger - The Final Flight (2020) - S01E02 - HELP! [WEBDL-1080p][EAC3 5.1][x264].mkv (score: 3523)
cleanup_file "/mnt/synology/rs-tv/Challenger - The Final Flight (2020) {tvdb-387206}/Season 01/Challenger - The Final Flight (2020) - S01E02 - HELP! [NF][WEBDL-1080p][EAC3 5.1][x264]-BTN.mkv" "Challenger - The Final Flight (2020) - S01E02 - HELP! [NF][WEBDL-1080p][EAC3 5.1][x264]-BTN.mkv (score: 3523 vs keeper 3523)"

# Group: Creepshow (2019) {tvdb-364865}/Season 01/S01E03
# KEEP: Creepshow (2019) - S01E03 - All Hallows Eve The Man in the Suitcase [AMZN][WEBDL-1080p][EAC3 2.0][h264]-NTG.mkv (score: 3528)
cleanup_file "/mnt/synology/rs-tv/Creepshow (2019) {tvdb-364865}/Season 01/Creepshow (2019) - S01E03 - All Hallows Eve The Man in the Suitcase [WEBRip-1080p][EAC3 5.1][h265].mkv" "Creepshow (2019) - S01E03 - All Hallows Eve The Man in the Suitcase [WEBRip-1080p][EAC3 5.1][h265].mkv (score: 2764 vs keeper 3528)"

# Group: Cross (2024) {tvdb-426501}/Season 01/S01E01
# KEEP: Cross (2024) - S01E01 - Hero Complex [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv (score: 3868)
cleanup_file "/mnt/synology/rs-tv/Cross (2024) {tvdb-426501}/Season 01/Cross (2024) - S01E01 - Hero Complex [WEBRip-1080p][AAC 5.1][x265]-KONTRAST.mp4" "Cross (2024) - S01E01 - Hero Complex [WEBRip-1080p][AAC 5.1][x265]-KONTRAST.mp4 (score: 2661 vs keeper 3868)"

# Group: Cross (2024) {tvdb-426501}/Season 01/S01E02
# KEEP: Cross (2024) - S01E02 - Ride the White Horsey [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv (score: 3866)
cleanup_file "/mnt/synology/rs-tv/Cross (2024) {tvdb-426501}/Season 01/Cross (2024) - S01E02 - Ride the White Horsey [WEBRip-1080p][AAC 5.1][x265]-KONTRAST.mp4" "Cross (2024) - S01E02 - Ride the White Horsey [WEBRip-1080p][AAC 5.1][x265]-KONTRAST.mp4 (score: 2659 vs keeper 3866)"

# Group: Cross (2024) {tvdb-426501}/Season 01/S01E03
# KEEP: Cross (2024) - S01E03 - The Good Book [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv (score: 3868)
cleanup_file "/mnt/synology/rs-tv/Cross (2024) {tvdb-426501}/Season 01/Cross (2024) - S01E03 - The Good Book [WEBRip-1080p][AAC 5.1][x265]-KONTRAST.mp4" "Cross (2024) - S01E03 - The Good Book [WEBRip-1080p][AAC 5.1][x265]-KONTRAST.mp4 (score: 2660 vs keeper 3868)"

# Group: Cross (2024) {tvdb-426501}/Season 01/S01E04
# KEEP: Cross (2024) - S01E04 - Masks [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv (score: 3869)
cleanup_file "/mnt/synology/rs-tv/Cross (2024) {tvdb-426501}/Season 01/Cross (2024) - S01E04 - Masks [WEBRip-1080p][AAC 5.1][x265]-KONTRAST.mp4" "Cross (2024) - S01E04 - Masks [WEBRip-1080p][AAC 5.1][x265]-KONTRAST.mp4 (score: 2660 vs keeper 3869)"

# Group: Cross (2024) {tvdb-426501}/Season 01/S01E05
# KEEP: Cross (2024) - S01E05 - What Happens At Ramsey's [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv (score: 3864)
cleanup_file "/mnt/synology/rs-tv/Cross (2024) {tvdb-426501}/Season 01/Cross (2024) - S01E05 - What Happens At Ramsey's [WEBRip-1080p][AAC 5.1][x265]-KONTRAST.mp4" "Cross (2024) - S01E05 - What Happens At Ramsey's [WEBRip-1080p][AAC 5.1][x265]-KONTRAST.mp4 (score: 2659 vs keeper 3864)"

# Group: Cross (2024) {tvdb-426501}/Season 01/S01E06
# KEEP: Cross (2024) - S01E06 - A Bang Not A Whimper [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv (score: 3867)
cleanup_file "/mnt/synology/rs-tv/Cross (2024) {tvdb-426501}/Season 01/Cross (2024) - S01E06 - A Bang Not A Whimper [WEBRip-1080p][AAC 5.1][x265]-KONTRAST.mp4" "Cross (2024) - S01E06 - A Bang Not A Whimper [WEBRip-1080p][AAC 5.1][x265]-KONTRAST.mp4 (score: 2659 vs keeper 3867)"

# Group: Cross (2024) {tvdb-426501}/Season 01/S01E07
# KEEP: Cross (2024) - S01E07 - Happy Birthday [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv (score: 3869)
cleanup_file "/mnt/synology/rs-tv/Cross (2024) {tvdb-426501}/Season 01/Cross (2024) - S01E07 - Happy Birthday [WEBRip-1080p][AAC 5.1][x265]-KONTRAST.mp4" "Cross (2024) - S01E07 - Happy Birthday [WEBRip-1080p][AAC 5.1][x265]-KONTRAST.mp4 (score: 2661 vs keeper 3869)"

# Group: Cross (2024) {tvdb-426501}/Season 01/S01E08
# KEEP: Cross (2024) - S01E08 - You Had Me At Motherfucker [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv (score: 3872)
cleanup_file "/mnt/synology/rs-tv/Cross (2024) {tvdb-426501}/Season 01/Cross (2024) - S01E08 - You Had Me At Motherfucker [WEBRip-1080p][AAC 5.1][x265]-KONTRAST.mp4" "Cross (2024) - S01E08 - You Had Me At Motherfucker [WEBRip-1080p][AAC 5.1][x265]-KONTRAST.mp4 (score: 2661 vs keeper 3872)"

# Group: Dark Matter (2015) {tvdb-292174}/Season 02/S02E02
# KEEP: Dark Matter (2015) - S02E02 - Kill Them All [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv (score: 2758)
cleanup_file "/mnt/synology/rs-tv/Dark Matter (2015) {tvdb-292174}/Season 02/Dark Matter (2015) - S02E02 - Kill Them All [[Trash] Release Sources (Streaming Service)_25_0 Release Sources (Streaming Service)_22_5][WEBDL-720p][EAC3 2.0][h264]-playWEB.mkv" "Dark Matter (2015) - S02E02 - Kill Them All [[Trash] Release Sources (Streaming Service)_25_0 Release Sources (Streaming Service)_22_5][WEBDL-720p][EAC3 2.0][h264]-playWEB.mkv (score: 1509 vs keeper 2758)"

# Group: Dark Matter (2015) {tvdb-292174}/Season 02/S02E03
# KEEP: Dark Matter (2015) - S02E03 - Ive Seen the Other Side of You [WEBDL-1080p Proper][AC3 5.1][h264]-VietHD.mkv (score: 3466)
cleanup_file "/mnt/synology/rs-tv/Dark Matter (2015) {tvdb-292174}/Season 02/Dark Matter (2015) - S02E03 - Ive Seen the Other Side of You [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv" "Dark Matter (2015) - S02E03 - Ive Seen the Other Side of You [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv (score: 2758 vs keeper 3466)"

# Group: Dark Matter (2015) {tvdb-292174}/Season 02/S02E04
# KEEP: Dark Matter (2015) - S02E04 - We Were Family [WEBDL-1080p Proper][AC3 5.1][h264]-VietHD.mkv (score: 3466)
cleanup_file "/mnt/synology/rs-tv/Dark Matter (2015) {tvdb-292174}/Season 02/Dark Matter (2015) - S02E04 - We Were Family [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv" "Dark Matter (2015) - S02E04 - We Were Family [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv (score: 2758 vs keeper 3466)"

# Group: Dark Matter (2015) {tvdb-292174}/Season 02/S02E05
# KEEP: Dark Matter (2015) - S02E05 - We Voted Not to Space You [WEBDL-1080p Proper][AC3 5.1][h264]-VietHD.mkv (score: 3466)
cleanup_file "/mnt/synology/rs-tv/Dark Matter (2015) {tvdb-292174}/Season 02/Dark Matter (2015) - S02E05 - We Voted Not to Space You [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv" "Dark Matter (2015) - S02E05 - We Voted Not to Space You [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv (score: 2758 vs keeper 3466)"

# Group: Dark Matter (2015) {tvdb-292174}/Season 02/S02E06
# KEEP: Dark Matter (2015) - S02E06 - We Should Have Seen This Coming [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv (score: 2758)
cleanup_file "/mnt/synology/rs-tv/Dark Matter (2015) {tvdb-292174}/Season 02/Dark Matter (2015) - S02E06 - We Should Have Seen This Coming [[Trash] Release Sources (Streaming Service)_25_0 Release Sources (Streaming Service)_22_5][WEBDL-720p][EAC3 2.0][h264]-playWEB.mkv" "Dark Matter (2015) - S02E06 - We Should Have Seen This Coming [[Trash] Release Sources (Streaming Service)_25_0 Release Sources (Streaming Service)_22_5][WEBDL-720p][EAC3 2.0][h264]-playWEB.mkv (score: 1509 vs keeper 2758)"

# Group: Dark Matter (2015) {tvdb-292174}/Season 02/S02E08
# KEEP: Dark Matter (2015) - S02E08 - Stuff to Steal People to Kill [WEBDL-1080p Proper][AC3 5.1][h264]-VietHD.mkv (score: 3466)
cleanup_file "/mnt/synology/rs-tv/Dark Matter (2015) {tvdb-292174}/Season 02/Dark Matter (2015) - S02E08 - Stuff to Steal People to Kill [WEBRip-1080p Proper][EAC3 5.1][HEVC]-d3g.mkv" "Dark Matter (2015) - S02E08 - Stuff to Steal People to Kill [WEBRip-1080p Proper][EAC3 5.1][HEVC]-d3g.mkv (score: 2758 vs keeper 3466)"

# Group: Dark Matter (2015) {tvdb-292174}/Season 02/S02E09
# KEEP: Dark Matter (2015) - S02E09 - Going Out Fighting [WEBDL-1080p Proper][AC3 5.1][h264]-VietHD.mkv (score: 3466)
cleanup_file "/mnt/synology/rs-tv/Dark Matter (2015) {tvdb-292174}/Season 02/Dark Matter (2015) - S02E09 - Going Out Fighting [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv" "Dark Matter (2015) - S02E09 - Going Out Fighting [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv (score: 2758 vs keeper 3466)"

# Group: Dark Matter (2015) {tvdb-292174}/Season 02/S02E10
# KEEP: Dark Matter (2015) - S02E10 - Take the Shot [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv (score: 2758)
cleanup_file "/mnt/synology/rs-tv/Dark Matter (2015) {tvdb-292174}/Season 02/Dark Matter (2015) - S02E10 - Take the Shot [[Trash] Release Sources (Streaming Service)_25_0 Release Sources (Streaming Service)_22_5][WEBDL-720p][EAC3 2.0][h264]-playWEB.mkv" "Dark Matter (2015) - S02E10 - Take the Shot [[Trash] Release Sources (Streaming Service)_25_0 Release Sources (Streaming Service)_22_5][WEBDL-720p][EAC3 2.0][h264]-playWEB.mkv (score: 1508 vs keeper 2758)"

# Group: Dark Matter (2015) {tvdb-292174}/Season 02/S02E11
# KEEP: Dark Matter (2015) - S02E11 - Wish Id Spaced You When I Had the Chance [WEBDL-1080p Proper][AC3 5.1][h264]-VietHD.mkv (score: 3466)
cleanup_file "/mnt/synology/rs-tv/Dark Matter (2015) {tvdb-292174}/Season 02/Dark Matter (2015) - S02E11 - Wish Id Spaced You When I Had the Chance [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv" "Dark Matter (2015) - S02E11 - Wish Id Spaced You When I Had the Chance [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv (score: 2758 vs keeper 3466)"

# Group: Dark Matter (2015) {tvdb-292174}/Season 02/S02E12
# KEEP: Dark Matter (2015) - S02E12 - Sometimes in Life You Dont Get to Choose [WEBDL-1080p Proper][AC3 5.1][h264]-VietHD.mkv (score: 3466)
cleanup_file "/mnt/synology/rs-tv/Dark Matter (2015) {tvdb-292174}/Season 02/Dark Matter (2015) - S02E12 - Sometimes in Life You Dont Get to Choose [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv" "Dark Matter (2015) - S02E12 - Sometimes in Life You Dont Get to Choose [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv (score: 2758 vs keeper 3466)"

# Group: Dark Matter (2015) {tvdb-292174}/Season 02/S02E13
# KEEP: Dark Matter (2015) - S02E13 - But First We Save the Galaxy [WEBDL-1080p Proper][AC3 5.1][h264]-VietHD.mkv (score: 3466)
cleanup_file "/mnt/synology/rs-tv/Dark Matter (2015) {tvdb-292174}/Season 02/Dark Matter (2015) - S02E13 - But First We Save the Galaxy [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv" "Dark Matter (2015) - S02E13 - But First We Save the Galaxy [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv (score: 2758 vs keeper 3466)"

# Group: Fresh Off the Boat (2015) {tvdb-281618}/Season 04/S04E05
# KEEP: Fresh Off the Boat (2015) - S04E05 - Four Funerals and a Wedding [WEBDL-1080p][EAC3 5.1][x264]-TrollHD.mkv (score: 3521)
cleanup_file "/mnt/synology/rs-tv/Fresh Off the Boat (2015) {tvdb-281618}/Season 04/Fresh Off the Boat (2015) - S04E05 - Four Funerals and a Wedding [HDTV-1080p][EAC3 5.1][h264].mkv" "Fresh Off the Boat (2015) - S04E05 - Four Funerals and a Wedding [HDTV-1080p][EAC3 5.1][h264].mkv (score: 2521 vs keeper 3521)"

# Group: Game of Thrones (2011) {tvdb-121361}/Season 08/S08E03
# KEEP: Game of Thrones (2011) - S08E03 - The Long Night [WEBDL-1080p][EAC3 Atmos 5.1][x264]-BANDOLEROS.mkv (score: 3900)
cleanup_file "/mnt/synology/rs-tv/Game of Thrones (2011) {tvdb-121361}/Season 08/Game of Thrones (2011) - S08E03 - The Long Night [HDTV-1080p][EAC3 5.1][h264].mkv" "Game of Thrones (2011) - S08E03 - The Long Night [HDTV-1080p][EAC3 5.1][h264].mkv (score: 2543 vs keeper 3900)"

# Group: Generation Kill (2008) {tvdb-82109}/Season 01/S01E01
# KEEP: Generation Kill (2008) - S01E01 - Get Some [HMAX][WEBDL-1080p][AC3 5.1][h264]-SLiGNOME.mkv (score: 3491)
cleanup_file "/mnt/synology/rs-tv/Generation Kill (2008) {tvdb-82109}/Season 01/Generation Kill (2008) - S01E01 - Get Some [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv" "Generation Kill (2008) - S01E01 - Get Some [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv (score: 2772 vs keeper 3491)"

# Group: Generation Kill (2008) {tvdb-82109}/Season 01/S01E02
# KEEP: Generation Kill (2008) - S01E02 - The Cradle of Civilization [HMAX][WEBDL-1080p][AC3 5.1][h264]-SLiGNOME.mkv (score: 3490)
cleanup_file "/mnt/synology/rs-tv/Generation Kill (2008) {tvdb-82109}/Season 01/Generation Kill (2008) - S01E02 - The Cradle of Civilization [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv" "Generation Kill (2008) - S01E02 - The Cradle of Civilization [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv (score: 2772 vs keeper 3490)"

# Group: Generation Kill (2008) {tvdb-82109}/Season 01/S01E03
# KEEP: Generation Kill (2008) - S01E03 - Screwby [HMAX][WEBDL-1080p][AC3 5.1][h264]-SLiGNOME.mkv (score: 3488)
cleanup_file "/mnt/synology/rs-tv/Generation Kill (2008) {tvdb-82109}/Season 01/Generation Kill (2008) - S01E03 - Screwby [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv" "Generation Kill (2008) - S01E03 - Screwby [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv (score: 2770 vs keeper 3488)"

# Group: Generation Kill (2008) {tvdb-82109}/Season 01/S01E04
# KEEP: Generation Kill (2008) - S01E04 - Combat Jack [HMAX][WEBDL-1080p][AC3 5.1][h264]-SLiGNOME.mkv (score: 3490)
cleanup_file "/mnt/synology/rs-tv/Generation Kill (2008) {tvdb-82109}/Season 01/Generation Kill (2008) - S01E04 - Combat Jack [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv" "Generation Kill (2008) - S01E04 - Combat Jack [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv (score: 2772 vs keeper 3490)"

# Group: Generation Kill (2008) {tvdb-82109}/Season 01/S01E05
# KEEP: Generation Kill (2008) - S01E05 - A Burning Dog [HMAX][WEBDL-1080p][AC3 5.1][h264]-SLiGNOME.mkv (score: 3491)
cleanup_file "/mnt/synology/rs-tv/Generation Kill (2008) {tvdb-82109}/Season 01/Generation Kill (2008) - S01E05 - A Burning Dog [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv" "Generation Kill (2008) - S01E05 - A Burning Dog [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv (score: 2773 vs keeper 3491)"

# Group: Generation Kill (2008) {tvdb-82109}/Season 01/S01E06
# KEEP: Generation Kill (2008) - S01E06 - Stay Frosty [HMAX][WEBDL-1080p][AC3 5.1][h264]-SLiGNOME.mkv (score: 3490)
cleanup_file "/mnt/synology/rs-tv/Generation Kill (2008) {tvdb-82109}/Season 01/Generation Kill (2008) - S01E06 - Stay Frosty [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv" "Generation Kill (2008) - S01E06 - Stay Frosty [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv (score: 2772 vs keeper 3490)"

# Group: Generation Kill (2008) {tvdb-82109}/Season 01/S01E07
# KEEP: Generation Kill (2008) - S01E07 - Bomb in the Garden [HMAX][WEBDL-1080p][AC3 5.1][h264]-SLiGNOME.mkv (score: 3490)
cleanup_file "/mnt/synology/rs-tv/Generation Kill (2008) {tvdb-82109}/Season 01/Generation Kill (2008) - S01E07 - Bomb in the Garden [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv" "Generation Kill (2008) - S01E07 - Bomb in the Garden [WEBRip-1080p][EAC3 5.1][HEVC]-d3g.mkv (score: 2772 vs keeper 3490)"

# Group: Harley Quinn (2019) {tvdb-365677}/Season 05/S05E06
# KEEP: Harley Quinn (2019) - S05E06 - Bottle My Heart [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3516)
cleanup_file "/mnt/synology/rs-tv/Harley Quinn (2019) {tvdb-365677}/Season 05/Harley Quinn (2019) - S05E06 - Bottle My Heart [WEBDL-1080p][EAC3 5.1][h264].mkv" "Harley Quinn (2019) - S05E06 - Bottle My Heart [WEBDL-1080p][EAC3 5.1][h264].mkv (score: 3516 vs keeper 3516)"

# Group: Helstrom (2020) {tvdb-364038}/Season 01/S01E10
# KEEP: Helstrom (2020) - S01E10 - Hell Storm [WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv (score: 3513)
cleanup_file "/mnt/synology/rs-tv/Helstrom (2020) {tvdb-364038}/Season 01/Helstrom (2020) - S01E10 - Hell Storm [HDTV-1080p][EAC3 5.1][h264].mkv" "Helstrom (2020) - S01E10 - Hell Storm [HDTV-1080p][EAC3 5.1][h264].mkv (score: 2513 vs keeper 3513)"

# Group: Homeland (2011) {tvdb-247897}/Season 07/S07E10
# KEEP: Homeland (2011) - S07E10 - Clarity [WEBDL-1080p Proper][EAC3 5.1][h264]-NTb.mkv (score: 3552)
cleanup_file "/mnt/synology/rs-tv/Homeland (2011) {tvdb-247897}/Season 07/Homeland (2011) - S07E10 - Clarity [HDTV-720p][EAC3 5.1][h264].mkv" "Homeland (2011) - S07E10 - Clarity [HDTV-720p][EAC3 5.1][h264].mkv (score: 508 vs keeper 3552)"

# Group: Invasion (2021) {tvdb-404492}/Season 02/S02E01
# KEEP: Invasion (2021) - S02E01 - Somethings Changed [WEBDL-1080p][EAC3 Atmos 5.1][h264].mkv (score: 3893)
cleanup_file "/mnt/synology/rs-tv/Invasion (2021) {tvdb-404492}/Season 02/Invasion (2021) - S02E01 - Somethings Changed [WEBRip-1080p][EAC3 Atmos 5.1][x265].mkv" "Invasion (2021) - S02E01 - Somethings Changed [WEBRip-1080p][EAC3 Atmos 5.1][x265].mkv (score: 3107 vs keeper 3893)"

# Group: Invasion (2021) {tvdb-404492}/Season 02/S02E02
# KEEP: Invasion (2021) - S02E02 - Chasing Ghosts [WEBDL-1080p][EAC3 Atmos 5.1][h264].mkv (score: 3889)
cleanup_file "/mnt/synology/rs-tv/Invasion (2021) {tvdb-404492}/Season 02/Invasion (2021) - S02E02 - Chasing Ghosts [WEBRip-1080p][EAC3 Atmos 5.1][x265].mkv" "Invasion (2021) - S02E02 - Chasing Ghosts [WEBRip-1080p][EAC3 Atmos 5.1][x265].mkv (score: 3106 vs keeper 3889)"

# Group: Invasion (2021) {tvdb-404492}/Season 02/S02E03
# KEEP: Invasion (2021) - S02E03 - Fireworks [WEBDL-1080p][EAC3 Atmos 5.1][h264].mkv (score: 3886)
cleanup_file "/mnt/synology/rs-tv/Invasion (2021) {tvdb-404492}/Season 02/Invasion (2021) - S02E03 - Fireworks [WEBRip-1080p][EAC3 Atmos 5.1][x265].mkv" "Invasion (2021) - S02E03 - Fireworks [WEBRip-1080p][EAC3 Atmos 5.1][x265].mkv (score: 3105 vs keeper 3886)"

# Group: Invasion (2021) {tvdb-404492}/Season 02/S02E04
# KEEP: Invasion (2021) - S02E04 - The Tunnel [WEBDL-1080p][EAC3 Atmos 5.1][h264].mkv (score: 3888)
cleanup_file "/mnt/synology/rs-tv/Invasion (2021) {tvdb-404492}/Season 02/Invasion (2021) - S02E04 - The Tunnel [WEBRip-1080p][EAC3 Atmos 5.1][x265].mkv" "Invasion (2021) - S02E04 - The Tunnel [WEBRip-1080p][EAC3 Atmos 5.1][x265].mkv (score: 3105 vs keeper 3888)"

# Group: Invasion (2021) {tvdb-404492}/Season 02/S02E05
# KEEP: Invasion (2021) - S02E05 - A Voice From the Other Side [WEBDL-1080p][EAC3 Atmos 5.1][h264].mkv (score: 3888)
cleanup_file "/mnt/synology/rs-tv/Invasion (2021) {tvdb-404492}/Season 02/Invasion (2021) - S02E05 - A Voice From the Other Side [WEBRip-1080p][EAC3 Atmos 5.1][x265].mkv" "Invasion (2021) - S02E05 - A Voice From the Other Side [WEBRip-1080p][EAC3 Atmos 5.1][x265].mkv (score: 3107 vs keeper 3888)"

# Group: Invasion (2021) {tvdb-404492}/Season 02/S02E06
# KEEP: Invasion (2021) - S02E06 - Pressure Points [WEBDL-1080p][EAC3 Atmos 5.1][h264].mkv (score: 3889)
cleanup_file "/mnt/synology/rs-tv/Invasion (2021) {tvdb-404492}/Season 02/Invasion (2021) - S02E06 - Pressure Points [WEBRip-1080p][EAC3 Atmos 5.1][x265].mkv" "Invasion (2021) - S02E06 - Pressure Points [WEBRip-1080p][EAC3 Atmos 5.1][x265].mkv (score: 3105 vs keeper 3889)"

# Group: Invasion (2021) {tvdb-404492}/Season 02/S02E07
# KEEP: Invasion (2021) - S02E07 - Down the Rabbit Hole [WEBDL-1080p][EAC3 Atmos 5.1][h264].mkv (score: 3886)
cleanup_file "/mnt/synology/rs-tv/Invasion (2021) {tvdb-404492}/Season 02/Invasion (2021) - S02E07 - Down the Rabbit Hole [WEBRip-1080p][EAC3 Atmos 5.1][x265].mkv" "Invasion (2021) - S02E07 - Down the Rabbit Hole [WEBRip-1080p][EAC3 Atmos 5.1][x265].mkv (score: 3106 vs keeper 3886)"

# Group: Invasion (2021) {tvdb-404492}/Season 02/S02E08
# KEEP: Invasion (2021) - S02E08 - Cosmic Ocean [WEBDL-1080p][EAC3 Atmos 5.1][h264].mkv (score: 3888)
cleanup_file "/mnt/synology/rs-tv/Invasion (2021) {tvdb-404492}/Season 02/Invasion (2021) - S02E08 - Cosmic Ocean [WEBRip-1080p][EAC3 Atmos 5.1][x265].mkv" "Invasion (2021) - S02E08 - Cosmic Ocean [WEBRip-1080p][EAC3 Atmos 5.1][x265].mkv (score: 3106 vs keeper 3888)"

# Group: Invasion (2021) {tvdb-404492}/Season 02/S02E09
# KEEP: Invasion (2021) - S02E09 - Breakthrough [WEBDL-1080p][EAC3 Atmos 5.1][h264].mkv (score: 3879)
cleanup_file "/mnt/synology/rs-tv/Invasion (2021) {tvdb-404492}/Season 02/Invasion (2021) - S02E09 - Breakthrough [WEBRip-1080p][EAC3 Atmos 5.1][x265].mkv" "Invasion (2021) - S02E09 - Breakthrough [WEBRip-1080p][EAC3 Atmos 5.1][x265].mkv (score: 3105 vs keeper 3879)"

# Group: Invasion (2021) {tvdb-404492}/Season 02/S02E10
# KEEP: Invasion (2021) - S02E10 - Old Friends New Frontiers [WEBDL-1080p][EAC3 Atmos 5.1][h264].mkv (score: 3887)
cleanup_file "/mnt/synology/rs-tv/Invasion (2021) {tvdb-404492}/Season 02/Invasion (2021) - S02E10 - Old Friends New Frontiers [WEBRip-1080p][EAC3 Atmos 5.1][x265].mkv" "Invasion (2021) - S02E10 - Old Friends New Frontiers [WEBRip-1080p][EAC3 Atmos 5.1][x265].mkv (score: 3106 vs keeper 3887)"

# Group: Jupiter's Legacy (2021) {tvdb-368388}/Season 01/S01E01
# KEEP: Jupiter's Legacy (2021) - S01E01 - By Dawns Early Light [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv (score: 3861)
cleanup_file "/mnt/synology/rs-tv/Jupiter's Legacy (2021) {tvdb-368388}/Season 01/Jupiter's Legacy (2021) - S01E01 - By Dawns Early Light [NF][WEBDL-1080p][EAC3 5.1][x264]-NTb.mkv" "Jupiter's Legacy (2021) - S01E01 - By Dawns Early Light [NF][WEBDL-1080p][EAC3 5.1][x264]-NTb.mkv (score: 3510 vs keeper 3861)"

# Group: Jupiter's Legacy (2021) {tvdb-368388}/Season 01/S01E02
# KEEP: Jupiter's Legacy (2021) - S01E02 - Paper and Stone [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv (score: 3857)
cleanup_file "/mnt/synology/rs-tv/Jupiter's Legacy (2021) {tvdb-368388}/Season 01/Jupiter's Legacy (2021) - S01E02 - Paper and Stone [NF][WEBDL-1080p][EAC3 5.1][x264]-NTb.mkv" "Jupiter's Legacy (2021) - S01E02 - Paper and Stone [NF][WEBDL-1080p][EAC3 5.1][x264]-NTb.mkv (score: 3506 vs keeper 3857)"

# Group: Jupiter's Legacy (2021) {tvdb-368388}/Season 01/S01E03
# KEEP: Jupiter's Legacy (2021) - S01E03 - Painting the Clouds With Sunshine [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv (score: 3867)
cleanup_file "/mnt/synology/rs-tv/Jupiter's Legacy (2021) {tvdb-368388}/Season 01/Jupiter's Legacy (2021) - S01E03 - Painting the Clouds With Sunshine [NF][WEBDL-1080p][EAC3 5.1][x264]-NTb.mkv" "Jupiter's Legacy (2021) - S01E03 - Painting the Clouds With Sunshine [NF][WEBDL-1080p][EAC3 5.1][x264]-NTb.mkv (score: 3517 vs keeper 3867)"

# Group: Jupiter's Legacy (2021) {tvdb-368388}/Season 01/S01E04
# KEEP: Jupiter's Legacy (2021) - S01E04 - All the Devils Are Here [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv (score: 3868)
cleanup_file "/mnt/synology/rs-tv/Jupiter's Legacy (2021) {tvdb-368388}/Season 01/Jupiter's Legacy (2021) - S01E04 - All the Devils Are Here [NF][WEBDL-1080p][EAC3 5.1][x264]-NTb.mkv" "Jupiter's Legacy (2021) - S01E04 - All the Devils Are Here [NF][WEBDL-1080p][EAC3 5.1][x264]-NTb.mkv (score: 3517 vs keeper 3868)"

# Group: Jupiter's Legacy (2021) {tvdb-368388}/Season 01/S01E05
# KEEP: Jupiter's Legacy (2021) - S01E05 - Whats the Use [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv (score: 3861)
cleanup_file "/mnt/synology/rs-tv/Jupiter's Legacy (2021) {tvdb-368388}/Season 01/Jupiter's Legacy (2021) - S01E05 - Whats the Use [NF][WEBDL-1080p][EAC3 5.1][x264]-NTb.mkv" "Jupiter's Legacy (2021) - S01E05 - Whats the Use [NF][WEBDL-1080p][EAC3 5.1][x264]-NTb.mkv (score: 3511 vs keeper 3861)"

# Group: Jupiter's Legacy (2021) {tvdb-368388}/Season 01/S01E06
# KEEP: Jupiter's Legacy (2021) - S01E06 - Cover Her Face [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv (score: 3863)
cleanup_file "/mnt/synology/rs-tv/Jupiter's Legacy (2021) {tvdb-368388}/Season 01/Jupiter's Legacy (2021) - S01E06 - Cover Her Face [NF][WEBDL-1080p][EAC3 5.1][x264]-NTb.mkv" "Jupiter's Legacy (2021) - S01E06 - Cover Her Face [NF][WEBDL-1080p][EAC3 5.1][x264]-NTb.mkv (score: 3513 vs keeper 3863)"

# Group: Jupiter's Legacy (2021) {tvdb-368388}/Season 01/S01E07
# KEEP: Jupiter's Legacy (2021) - S01E07 - Omnes Pro Uno [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv (score: 3865)
cleanup_file "/mnt/synology/rs-tv/Jupiter's Legacy (2021) {tvdb-368388}/Season 01/Jupiter's Legacy (2021) - S01E07 - Omnes Pro Uno [NF][WEBDL-1080p][EAC3 5.1][x264]-NTb.mkv" "Jupiter's Legacy (2021) - S01E07 - Omnes Pro Uno [NF][WEBDL-1080p][EAC3 5.1][x264]-NTb.mkv (score: 3515 vs keeper 3865)"

# Group: Jupiter's Legacy (2021) {tvdb-368388}/Season 01/S01E08
# KEEP: Jupiter's Legacy (2021) - S01E08 - How It All Ends [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv (score: 3859)
cleanup_file "/mnt/synology/rs-tv/Jupiter's Legacy (2021) {tvdb-368388}/Season 01/Jupiter's Legacy (2021) - S01E08 - How It All Ends [NF][WEBDL-1080p][EAC3 5.1][x264]-NTb.mkv" "Jupiter's Legacy (2021) - S01E08 - How It All Ends [NF][WEBDL-1080p][EAC3 5.1][x264]-NTb.mkv (score: 3509 vs keeper 3859)"

# Group: Jurassic World - Camp Cretaceous (2020) {tvdb-365066}/Season 01/S01E01
# KEEP: Jurassic World - Camp Cretaceous (2020) - S01E01 - Camp Cretaceous [WEBDL-1080p][EAC3 5.1][x264]-BTN.mkv (score: 3512)
cleanup_file "/mnt/synology/rs-tv/Jurassic World - Camp Cretaceous (2020) {tvdb-365066}/Season 01/Jurassic World - Camp Cretaceous (2020) - S01E01 - Camp Cretaceous [HDTV-1080p][EAC3 5.1][x264].mkv" "Jurassic World - Camp Cretaceous (2020) - S01E01 - Camp Cretaceous [HDTV-1080p][EAC3 5.1][x264].mkv (score: 2512 vs keeper 3512)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 02/S02E01
# KEEP: Knight Rider (1982) - S02E01-E02 - Goliath [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3315)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 02/Knight Rider (1982) - S02E01-E02 - Goliath [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S02E01-E02 - Goliath [HDTV-720p][AC3 2.0][x264].mkv (score: 482 vs keeper 3315)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 02/S02E03
# KEEP: Knight Rider (1982) - S02E03 - Brothers Keeper [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 02/Knight Rider (1982) - S02E03 - Brothers Keeper [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S02E03 - Brothers Keeper [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 02/S02E04
# KEEP: Knight Rider (1982) - S02E04 - Merchants of Death [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 02/Knight Rider (1982) - S02E04 - Merchants of Death [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S02E04 - Merchants of Death [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 02/S02E05
# KEEP: Knight Rider (1982) - S02E05 - Blind Spot [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 02/Knight Rider (1982) - S02E05 - Blind Spot [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S02E05 - Blind Spot [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 02/S02E06
# KEEP: Knight Rider (1982) - S02E06 - Return to Cadiz [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 02/Knight Rider (1982) - S02E06 - Return to Cadiz [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S02E06 - Return to Cadiz [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 02/S02E07
# KEEP: Knight Rider (1982) - S02E07 - K.I.T.T. the Cat [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 02/Knight Rider (1982) - S02E07 - K.I.T.T. the Cat [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S02E07 - K.I.T.T. the Cat [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 02/S02E08
# KEEP: Knight Rider (1982) - S02E08 - Custom K.I.T.T [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 02/Knight Rider (1982) - S02E08 - Custom K.I.T.T [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S02E08 - Custom K.I.T.T [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 02/S02E09
# KEEP: Knight Rider (1982) - S02E09 - Soul Survivor [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 02/Knight Rider (1982) - S02E09 - Soul Survivor [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S02E09 - Soul Survivor [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 02/S02E10
# KEEP: Knight Rider (1982) - S02E10 - Ring of Fire [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 02/Knight Rider (1982) - S02E10 - Ring of Fire [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S02E10 - Ring of Fire [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 02/S02E11
# KEEP: Knight Rider (1982) - S02E11 - Knightmares [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 02/Knight Rider (1982) - S02E11 - Knightmares [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S02E11 - Knightmares [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 02/S02E12
# KEEP: Knight Rider (1982) - S02E12 - Silent Knight [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 02/Knight Rider (1982) - S02E12 - Silent Knight [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S02E12 - Silent Knight [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 02/S02E13
# KEEP: Knight Rider (1982) - S02E13 - A Knight in Shining Armor [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 02/Knight Rider (1982) - S02E13 - A Knight in Shining Armor [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S02E13 - A Knight in Shining Armor [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 02/S02E14
# KEEP: Knight Rider (1982) - S02E14 - Diamonds Arent a Girls Best Friend [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 02/Knight Rider (1982) - S02E14 - Diamonds Arent a Girls Best Friend [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S02E14 - Diamonds Arent a Girls Best Friend [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 02/S02E15
# KEEP: Knight Rider (1982) - S02E15 - White-Line Warriors [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 02/Knight Rider (1982) - S02E15 - White-Line Warriors [HDTV-720p][AC3 2.0][x264]-Line.mkv" "Knight Rider (1982) - S02E15 - White-Line Warriors [HDTV-720p][AC3 2.0][x264]-Line.mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 02/S02E16
# KEEP: Knight Rider (1982) - S02E16 - Race for Life [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 02/Knight Rider (1982) - S02E16 - Race for Life [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S02E16 - Race for Life [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 02/S02E17
# KEEP: Knight Rider (1982) - S02E17 - Speed Demons [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 02/Knight Rider (1982) - S02E17 - Speed Demons [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S02E17 - Speed Demons [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 02/S02E18
# KEEP: Knight Rider (1982) - S02E18-E19 - Goliath Returns [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3315)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 02/Knight Rider (1982) - S02E18-E19 - Goliath Returns [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S02E18-E19 - Goliath Returns [HDTV-720p][AC3 2.0][x264].mkv (score: 482 vs keeper 3315)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 02/S02E20
# KEEP: Knight Rider (1982) - S02E20 - A Good Knights Work [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 02/Knight Rider (1982) - S02E20 - A Good Knights Work [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S02E20 - A Good Knights Work [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 02/S02E21
# KEEP: Knight Rider (1982) - S02E21-E22 - Mouth of the Snake a.k.a. All That Glitters [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3315)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 02/Knight Rider (1982) - S02E21-E22 - Mouth of the Snake a.k.a. All That Glitters [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S02E21-E22 - Mouth of the Snake a.k.a. All That Glitters [HDTV-720p][AC3 2.0][x264].mkv (score: 482 vs keeper 3315)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 02/S02E23
# KEEP: Knight Rider (1982) - S02E23 - Let It Be Me [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 02/Knight Rider (1982) - S02E23 - Let It Be Me [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S02E23 - Let It Be Me [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 02/S02E24
# KEEP: Knight Rider (1982) - S02E24 - Big Iron [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 02/Knight Rider (1982) - S02E24 - Big Iron [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S02E24 - Big Iron [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 03/S03E04
# KEEP: Knight Rider (1982) - S03E04 - Knights of the Fast Lane [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 03/Knight Rider (1982) - S03E04 - Knights of the Fast Lane [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S03E04 - Knights of the Fast Lane [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 03/S03E05
# KEEP: Knight Rider (1982) - S03E05 - Halloween Knight [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 03/Knight Rider (1982) - S03E05 - Halloween Knight [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S03E05 - Halloween Knight [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 03/S03E06
# KEEP: Knight Rider (1982) - S03E06 - K.I.T.T. vs. K.A.R.R [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 03/Knight Rider (1982) - S03E06 - K.I.T.T. vs. K.A.R.R [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S03E06 - K.I.T.T. vs. K.A.R.R [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 03/S03E07
# KEEP: Knight Rider (1982) - S03E07 - The Rotten Apples [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 03/Knight Rider (1982) - S03E07 - The Rotten Apples [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S03E07 - The Rotten Apples [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 03/S03E08
# KEEP: Knight Rider (1982) - S03E08 - Knight in Disgrace [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 03/Knight Rider (1982) - S03E08 - Knight in Disgrace [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S03E08 - Knight in Disgrace [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 03/S03E09
# KEEP: Knight Rider (1982) - S03E09 - Dead of Knight [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 03/Knight Rider (1982) - S03E09 - Dead of Knight [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S03E09 - Dead of Knight [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 03/S03E10
# KEEP: Knight Rider (1982) - S03E10 - Lost Knight [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 03/Knight Rider (1982) - S03E10 - Lost Knight [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S03E10 - Lost Knight [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 03/S03E11
# KEEP: Knight Rider (1982) - S03E11 - Knight of the Chameleon [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 03/Knight Rider (1982) - S03E11 - Knight of the Chameleon [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S03E11 - Knight of the Chameleon [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 03/S03E12
# KEEP: Knight Rider (1982) - S03E12 - Custom Made Killer [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 03/Knight Rider (1982) - S03E12 - Custom Made Killer [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S03E12 - Custom Made Killer [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 03/S03E13
# KEEP: Knight Rider (1982) - S03E13 - Knight by a Nose [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 03/Knight Rider (1982) - S03E13 - Knight by a Nose [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S03E13 - Knight by a Nose [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 03/S03E14
# KEEP: Knight Rider (1982) - S03E14 - Junk Yard Dog [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 03/Knight Rider (1982) - S03E14 - Junk Yard Dog [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S03E14 - Junk Yard Dog [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 03/S03E15
# KEEP: Knight Rider (1982) - S03E15 - Buy Out [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 03/Knight Rider (1982) - S03E15 - Buy Out [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S03E15 - Buy Out [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 03/S03E16
# KEEP: Knight Rider (1982) - S03E16 - Knightlines [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 03/Knight Rider (1982) - S03E16 - Knightlines [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S03E16 - Knightlines [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 03/S03E17
# KEEP: Knight Rider (1982) - S03E17 - The Nineteenth Hole [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 03/Knight Rider (1982) - S03E17 - The Nineteenth Hole [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S03E17 - The Nineteenth Hole [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 03/S03E18
# KEEP: Knight Rider (1982) - S03E18 - Knight and Knerd [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 03/Knight Rider (1982) - S03E18 - Knight and Knerd [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S03E18 - Knight and Knerd [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 03/S03E19
# KEEP: Knight Rider (1982) - S03E19 - Ten Wheel Trouble [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 03/Knight Rider (1982) - S03E19 - Ten Wheel Trouble [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S03E19 - Ten Wheel Trouble [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 04/S04E01
# KEEP: Knight Rider (1982) - S04E01-E02 - Knight of the Juggernaut [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3315)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 04/Knight Rider (1982) - S04E01 - Knight of the Juggernaut 1 [HDTV-720p][DTS 2.0][x264].mkv" "Knight Rider (1982) - S04E01 - Knight of the Juggernaut 1 [HDTV-720p][DTS 2.0][x264].mkv (score: 585 vs keeper 3315)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 04/S04E03
# KEEP: Knight Rider (1982) - S04E03 - KITTnap [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 04/Knight Rider (1982) - S04E03 - KITTnap [HDTV-720p][DTS 2.0][x264].mkv" "Knight Rider (1982) - S04E03 - KITTnap [HDTV-720p][DTS 2.0][x264].mkv (score: 580 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 04/S04E04
# KEEP: Knight Rider (1982) - S04E04 - Sky Knight [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 04/Knight Rider (1982) - S04E04 - Sky Knight [HDTV-720p][DTS 2.0][x264].mkv" "Knight Rider (1982) - S04E04 - Sky Knight [HDTV-720p][DTS 2.0][x264].mkv (score: 583 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 04/S04E05
# KEEP: Knight Rider (1982) - S04E05 - Burial Ground [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 04/Knight Rider (1982) - S04E05 - Burial Ground [HDTV-720p][DTS 2.0][x264].mkv" "Knight Rider (1982) - S04E05 - Burial Ground [HDTV-720p][DTS 2.0][x264].mkv (score: 573 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 04/S04E06
# KEEP: Knight Rider (1982) - S04E06 - The Wrong Crowd [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 04/Knight Rider (1982) - S04E06 - The Wrong Crowd [HDTV-720p][DTS 2.0][x264].mkv" "Knight Rider (1982) - S04E06 - The Wrong Crowd [HDTV-720p][DTS 2.0][x264].mkv (score: 579 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 04/S04E07
# KEEP: Knight Rider (1982) - S04E07 - Knight Sting [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 04/Knight Rider (1982) - S04E07 - Knight Sting [HDTV-720p][DTS 2.0][x264].mkv" "Knight Rider (1982) - S04E07 - Knight Sting [HDTV-720p][DTS 2.0][x264].mkv (score: 582 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 04/S04E08
# KEEP: Knight Rider (1982) - S04E08 - Many Happy Returns [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 04/Knight Rider (1982) - S04E08 - Many Happy Returns [HDTV-720p][DTS 2.0][x264].mkv" "Knight Rider (1982) - S04E08 - Many Happy Returns [HDTV-720p][DTS 2.0][x264].mkv (score: 576 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 04/S04E09
# KEEP: Knight Rider (1982) - S04E09 - Knight Racer [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 04/Knight Rider (1982) - S04E09 - Knight Racer [HDTV-720p][DTS 2.0][x264].mkv" "Knight Rider (1982) - S04E09 - Knight Racer [HDTV-720p][DTS 2.0][x264].mkv (score: 578 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 04/S04E10
# KEEP: Knight Rider (1982) - S04E10 - Knight Behind Bars [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 04/Knight Rider (1982) - S04E10 - Knight Behind Bars [HDTV-720p][DTS 2.0][x264].mkv" "Knight Rider (1982) - S04E10 - Knight Behind Bars [HDTV-720p][DTS 2.0][x264].mkv (score: 580 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 04/S04E11
# KEEP: Knight Rider (1982) - S04E11 - Knight Song [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 04/Knight Rider (1982) - S04E11 - Knight Song [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S04E11 - Knight Song [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 04/S04E12
# KEEP: Knight Rider (1982) - S04E12 - The Scent of Roses [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 04/Knight Rider (1982) - S04E12 - The Scent of Roses [HDTV-720p][DTS 2.0][x264].mkv" "Knight Rider (1982) - S04E12 - The Scent of Roses [HDTV-720p][DTS 2.0][x264].mkv (score: 577 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 04/S04E13
# KEEP: Knight Rider (1982) - S04E13 - Killer K.I.T.T [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 04/Knight Rider (1982) - S04E13 - Killer K.I.T.T [HDTV-720p][DTS 2.0][x264].mkv" "Knight Rider (1982) - S04E13 - Killer K.I.T.T [HDTV-720p][DTS 2.0][x264].mkv (score: 580 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 04/S04E14
# KEEP: Knight Rider (1982) - S04E14 - Out of the Woods [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 04/Knight Rider (1982) - S04E14 - Out of the Woods [HDTV-720p][DTS 2.0][x264].mkv" "Knight Rider (1982) - S04E14 - Out of the Woods [HDTV-720p][DTS 2.0][x264].mkv (score: 573 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 04/S04E15
# KEEP: Knight Rider (1982) - S04E15 - Deadly Knightshade [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 04/Knight Rider (1982) - S04E15 - Deadly Knightshade [HDTV-720p][DTS 2.0][x264].mkv" "Knight Rider (1982) - S04E15 - Deadly Knightshade [HDTV-720p][DTS 2.0][x264].mkv (score: 584 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 04/S04E16
# KEEP: Knight Rider (1982) - S04E16 - Redemption of a Champion [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 04/Knight Rider (1982) - S04E16 - Redemption of a Champion [HDTV-720p][DTS 2.0][x264].mkv" "Knight Rider (1982) - S04E16 - Redemption of a Champion [HDTV-720p][DTS 2.0][x264].mkv (score: 575 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 04/S04E17
# KEEP: Knight Rider (1982) - S04E17 - Knight of a Thousand Devils [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 04/Knight Rider (1982) - S04E17 - Knight of a Thousand Devils [HDTV-720p][DTS 2.0][x264].mkv" "Knight Rider (1982) - S04E17 - Knight of a Thousand Devils [HDTV-720p][DTS 2.0][x264].mkv (score: 574 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 04/S04E18
# KEEP: Knight Rider (1982) - S04E18 - Hills of Fire [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 04/Knight Rider (1982) - S04E18 - Hills of Fire [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S04E18 - Hills of Fire [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 04/S04E19
# KEEP: Knight Rider (1982) - S04E19 - Knight Flight to Freedom [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 04/Knight Rider (1982) - S04E19 - Knight Flight to Freedom [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S04E19 - Knight Flight to Freedom [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 04/S04E20
# KEEP: Knight Rider (1982) - S04E20 - Fright Knight [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 04/Knight Rider (1982) - S04E20 - Fright Knight [HDTV-720p][DTS 2.0][x264].mkv" "Knight Rider (1982) - S04E20 - Fright Knight [HDTV-720p][DTS 2.0][x264].mkv (score: 575 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 04/S04E21
# KEEP: Knight Rider (1982) - S04E21 - Knight of the Rising Sun [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 04/Knight Rider (1982) - S04E21 - Knight of the Rising Sun [HDTV-720p][AC3 2.0][x264].mkv" "Knight Rider (1982) - S04E21 - Knight of the Rising Sun [HDTV-720p][AC3 2.0][x264].mkv (score: 471 vs keeper 3282)"

# Group: Knight Rider (1982) {tvdb-77216}/Season 04/S04E22
# KEEP: Knight Rider (1982) - S04E22 - Voo Doo Knight [Bluray-1080p][AC3 2.0][x264]-YELLOWBiRD.mkv (score: 3282)
cleanup_file "/mnt/synology/rs-tv/Knight Rider (1982) {tvdb-77216}/Season 04/Knight Rider (1982) - S04E22 - Voo Doo Knight [HDTV-720p][DTS 2.0][x264].mkv" "Knight Rider (1982) - S04E22 - Voo Doo Knight [HDTV-720p][DTS 2.0][x264].mkv (score: 575 vs keeper 3282)"

# Group: Locke & Key (2020) {tvdb-361594}/Season 03/S03E01
# KEEP: Locke & Key (2020) - S03E01 - The Snow Globe [WEBDL-1080p Proper][EAC3 Atmos 5.1][x264].mkv (score: 3861)
cleanup_file "/mnt/synology/rs-tv/Locke & Key (2020) {tvdb-361594}/Season 03/Locke & Key (2020) - S03E01 - The Snow Globe [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTb.mkv" "Locke & Key (2020) - S03E01 - The Snow Globe [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTb.mkv (score: 3861 vs keeper 3861)"

# Group: Locke & Key (2020) {tvdb-361594}/Season 03/S03E02
# KEEP: Locke & Key (2020) - S03E02 - Wedding Crashers [WEBDL-1080p Proper][EAC3 Atmos 5.1][x264].mkv (score: 3861)
cleanup_file "/mnt/synology/rs-tv/Locke & Key (2020) {tvdb-361594}/Season 03/Locke & Key (2020) - S03E02 - Wedding Crashers [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTb.mkv" "Locke & Key (2020) - S03E02 - Wedding Crashers [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTb.mkv (score: 3861 vs keeper 3861)"

# Group: Locke & Key (2020) {tvdb-361594}/Season 03/S03E03
# KEEP: Locke & Key (2020) - S03E03 - Five Minutes Past [WEBDL-1080p Proper][EAC3 Atmos 5.1][x264].mkv (score: 3861)
cleanup_file "/mnt/synology/rs-tv/Locke & Key (2020) {tvdb-361594}/Season 03/Locke & Key (2020) - S03E03 - Five Minutes Past [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTb.mkv" "Locke & Key (2020) - S03E03 - Five Minutes Past [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTb.mkv (score: 3861 vs keeper 3861)"

# Group: Locke & Key (2020) {tvdb-361594}/Season 03/S03E04
# KEEP: Locke & Key (2020) - S03E04 - Deep Cover [WEBDL-1080p Proper][EAC3 Atmos 5.1][x264].mkv (score: 3862)
cleanup_file "/mnt/synology/rs-tv/Locke & Key (2020) {tvdb-361594}/Season 03/Locke & Key (2020) - S03E04 - Deep Cover [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTb.mkv" "Locke & Key (2020) - S03E04 - Deep Cover [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTb.mkv (score: 3862 vs keeper 3862)"

# Group: Locke & Key (2020) {tvdb-361594}/Season 03/S03E05
# KEEP: Locke & Key (2020) - S03E05 - Siege [WEBDL-1080p Proper][EAC3 Atmos 5.1][x264].mkv (score: 3862)
cleanup_file "/mnt/synology/rs-tv/Locke & Key (2020) {tvdb-361594}/Season 03/Locke & Key (2020) - S03E05 - Siege [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTb.mkv" "Locke & Key (2020) - S03E05 - Siege [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTb.mkv (score: 3862 vs keeper 3862)"

# Group: Locke & Key (2020) {tvdb-361594}/Season 03/S03E06
# KEEP: Locke & Key (2020) - S03E06 - Free Bird [WEBDL-1080p Proper][EAC3 Atmos 5.1][x264].mkv (score: 3858)
cleanup_file "/mnt/synology/rs-tv/Locke & Key (2020) {tvdb-361594}/Season 03/Locke & Key (2020) - S03E06 - Free Bird [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTb.mkv" "Locke & Key (2020) - S03E06 - Free Bird [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTb.mkv (score: 3858 vs keeper 3858)"

# Group: Locke & Key (2020) {tvdb-361594}/Season 03/S03E07
# KEEP: Locke & Key (2020) - S03E07 - Curtain [WEBDL-1080p Proper][EAC3 Atmos 5.1][x264].mkv (score: 3859)
cleanup_file "/mnt/synology/rs-tv/Locke & Key (2020) {tvdb-361594}/Season 03/Locke & Key (2020) - S03E07 - Curtain [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTb.mkv" "Locke & Key (2020) - S03E07 - Curtain [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTb.mkv (score: 3859 vs keeper 3859)"

# Group: Locke & Key (2020) {tvdb-361594}/Season 03/S03E08
# KEEP: Locke & Key (2020) - S03E08 - Farewell [WEBDL-1080p Proper][EAC3 Atmos 5.1][x264].mkv (score: 3861)
cleanup_file "/mnt/synology/rs-tv/Locke & Key (2020) {tvdb-361594}/Season 03/Locke & Key (2020) - S03E08 - Farewell [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTb.mkv" "Locke & Key (2020) - S03E08 - Farewell [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTb.mkv (score: 3861 vs keeper 3861)"

# Group: Murderbot (2025) {tvdb-443396}/Season 01/S01E01
# KEEP: Murderbot (2025) - S01E01 - FreeCommerce [ATVP][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv (score: 3872)
cleanup_file "/mnt/synology/rs-tv/Murderbot (2025) {tvdb-443396}/Season 01/Murderbot (2025) - S01E01 - FreeCommerce [WEBDL-1080p][EAC3 Atmos 5.1][h264]-ETHEL.mkv" "Murderbot (2025) - S01E01 - FreeCommerce [WEBDL-1080p][EAC3 Atmos 5.1][h264]-ETHEL.mkv (score: 3872 vs keeper 3872)"

# Group: Murderbot (2025) {tvdb-443396}/Season 01/S01E02
# KEEP: Murderbot (2025) - S01E02 - Eye Contact [ATVP][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv (score: 3868)
cleanup_file "/mnt/synology/rs-tv/Murderbot (2025) {tvdb-443396}/Season 01/Murderbot (2025) - S01E02 - Eye Contact [WEBDL-1080p][EAC3 Atmos 5.1][h264]-SuccessfulCrab.mkv" "Murderbot (2025) - S01E02 - Eye Contact [WEBDL-1080p][EAC3 Atmos 5.1][h264]-SuccessfulCrab.mkv (score: 3868 vs keeper 3868)"

# Group: Murderbot (2025) {tvdb-443396}/Season 01/S01E03
# KEEP: Murderbot (2025) - S01E03 - Risk Assessment [WEBDL-1080p][EAC3 Atmos 5.1][h264]-STC.mkv (score: 3866)
cleanup_file "/mnt/synology/rs-tv/Murderbot (2025) {tvdb-443396}/Season 01/Murderbot (2025) - S01E03 - Risk Assessment [ATVP][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv" "Murderbot (2025) - S01E03 - Risk Assessment [ATVP][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv (score: 3866 vs keeper 3866)"

# Group: Murderbot (2025) {tvdb-443396}/Season 01/S01E04
# KEEP: Murderbot (2025) - S01E04 - Escape Velocity Protocol [ATVP][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv (score: 3866)
cleanup_file "/mnt/synology/rs-tv/Murderbot (2025) {tvdb-443396}/Season 01/Murderbot (2025) - S01E04 - Escape Velocity Protocol [WEBDL-1080p][EAC3 Atmos 5.1][h264]-ETHEL.mkv" "Murderbot (2025) - S01E04 - Escape Velocity Protocol [WEBDL-1080p][EAC3 Atmos 5.1][h264]-ETHEL.mkv (score: 3866 vs keeper 3866)"

# Group: Power (2014) {tvdb-276562}/Season 02/S02E08
# KEEP: Power (2014) - S02E08 - Three Moves Ahead [WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv (score: 3543)
cleanup_file "/mnt/synology/rs-tv/Power (2014) {tvdb-276562}/Season 02/Power (2014) - S02E08 - Three Moves Ahead [HDTV-1080p][AC3 5.1][x264].mkv" "Power (2014) - S02E08 - Three Moves Ahead [HDTV-1080p][AC3 5.1][x264].mkv (score: 2489 vs keeper 3543)"

# Group: RIPLEY (2024) {tvdb-372727}/Season 01/S01E01
# KEEP: RIPLEY (2024) - S01E01 - I A HARD MAN TO FIND [WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv (score: 3868)
cleanup_file "/mnt/synology/rs-tv/RIPLEY (2024) {tvdb-372727}/Season 01/RIPLEY (2024) - S01E01 - I A HARD MAN TO FIND [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv" "RIPLEY (2024) - S01E01 - I A HARD MAN TO FIND [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv (score: 3868 vs keeper 3868)"

# Group: RIPLEY (2024) {tvdb-372727}/Season 01/S01E02
# KEEP: RIPLEY (2024) - S01E02 - II SEVEN MERCIES [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv (score: 3868)
cleanup_file "/mnt/synology/rs-tv/RIPLEY (2024) {tvdb-372727}/Season 01/RIPLEY (2024) - S01E02 - II SEVEN MERCIES [WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv" "RIPLEY (2024) - S01E02 - II SEVEN MERCIES [WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv (score: 3868 vs keeper 3868)"

# Group: RIPLEY (2024) {tvdb-372727}/Season 01/S01E03
# KEEP: RIPLEY (2024) - S01E03 - III SOMMERSO [WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv (score: 3868)
cleanup_file "/mnt/synology/rs-tv/RIPLEY (2024) {tvdb-372727}/Season 01/RIPLEY (2024) - S01E03 - III SOMMERSO [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv" "RIPLEY (2024) - S01E03 - III SOMMERSO [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv (score: 3868 vs keeper 3868)"

# Group: RIPLEY (2024) {tvdb-372727}/Season 01/S01E04
# KEEP: RIPLEY (2024) - S01E04 - IV LA DOLCE VITA [WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv (score: 3866)
cleanup_file "/mnt/synology/rs-tv/RIPLEY (2024) {tvdb-372727}/Season 01/RIPLEY (2024) - S01E04 - IV LA DOLCE VITA [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv" "RIPLEY (2024) - S01E04 - IV LA DOLCE VITA [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv (score: 3866 vs keeper 3866)"

# Group: RIPLEY (2024) {tvdb-372727}/Season 01/S01E05
# KEEP: RIPLEY (2024) - S01E05 - V LUCIO [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv (score: 3872)
cleanup_file "/mnt/synology/rs-tv/RIPLEY (2024) {tvdb-372727}/Season 01/RIPLEY (2024) - S01E05 - V LUCIO [WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv" "RIPLEY (2024) - S01E05 - V LUCIO [WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv (score: 3872 vs keeper 3872)"

# Group: RIPLEY (2024) {tvdb-372727}/Season 01/S01E06
# KEEP: RIPLEY (2024) - S01E06 - VI SOME HEAVY INSTRUMENT [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv (score: 3872)
cleanup_file "/mnt/synology/rs-tv/RIPLEY (2024) {tvdb-372727}/Season 01/RIPLEY (2024) - S01E06 - VI SOME HEAVY INSTRUMENT [WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv" "RIPLEY (2024) - S01E06 - VI SOME HEAVY INSTRUMENT [WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv (score: 3872 vs keeper 3872)"

# Group: RIPLEY (2024) {tvdb-372727}/Season 01/S01E07
# KEEP: RIPLEY (2024) - S01E07 - VII MACABRE ENTERTAINMENT [WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv (score: 3872)
cleanup_file "/mnt/synology/rs-tv/RIPLEY (2024) {tvdb-372727}/Season 01/RIPLEY (2024) - S01E07 - VII MACABRE ENTERTAINMENT [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv" "RIPLEY (2024) - S01E07 - VII MACABRE ENTERTAINMENT [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv (score: 3872 vs keeper 3872)"

# Group: RIPLEY (2024) {tvdb-372727}/Season 01/S01E08
# KEEP: RIPLEY (2024) - S01E08 - VIII NARCISSUS [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv (score: 3879)
cleanup_file "/mnt/synology/rs-tv/RIPLEY (2024) {tvdb-372727}/Season 01/RIPLEY (2024) - S01E08 - VIII NARCISSUS [WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv" "RIPLEY (2024) - S01E08 - VIII NARCISSUS [WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv (score: 3879 vs keeper 3879)"

# Group: Raised by Wolves (2020) {tvdb-368643}/Season 02/S02E03
# KEEP: Raised by Wolves (2020) - S02E03 - Good Creatures [WEBDL-1080p][EAC3 5.1][h264]-NTb.mkv (score: 3533)
cleanup_file "/mnt/synology/rs-tv/Raised by Wolves (2020) {tvdb-368643}/Season 02/Raised by Wolves (2020) - S02E03 - Good Creatures [WEBDL-720p][AC3 5.1][x264]-cakes.mkv" "Raised by Wolves (2020) - S02E03 - Good Creatures [WEBDL-720p][AC3 5.1][x264]-cakes.mkv (score: 1464 vs keeper 3533)"

# Group: Ray Donovan (2013) {tvdb-259866}/Season 03/S03E12
# KEEP: Ray Donovan (2013) - S03E12 - Exsuscito [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv (score: 3296)
cleanup_file "/mnt/synology/rs-tv/Ray Donovan (2013) {tvdb-259866}/Season 03/Ray Donovan (2013) - S03E12 - Exsuscito [HDTV-720p][AC3 2.0][x264].mkv" "Ray Donovan (2013) - S03E12 - Exsuscito [HDTV-720p][AC3 2.0][x264].mkv (score: 459 vs keeper 3296)"

# Group: Real Vikings (2016) {tvdb-320625}/Season 01/S01E01
# KEEP: Real Vikings (2016) - S01E01 - Age of Invasion [WEBDL-1080p][EAC3 5.1][h264]-RCVR.mkv (score: 3533)
cleanup_file "/mnt/synology/rs-tv/Real Vikings (2016) {tvdb-320625}/Season 01/Real Vikings (2016) - S01E01 - Age of Invasion [HDTV-720p][AC3 5.1][x264].mkv" "Real Vikings (2016) - S01E01 - Age of Invasion [HDTV-720p][AC3 5.1][x264].mkv (score: 460 vs keeper 3533)"

# Group: Resident Alien (2021) {tvdb-368166}/Season 01/S01E03
# KEEP: Resident Alien (2021) - S01E03 - Secrets [WEBDL-1080p][AAC 2.0][h264]-ggez.mkv (score: 3418)
cleanup_file "/mnt/synology/rs-tv/Resident Alien (2021) {tvdb-368166}/Season 01/Resident.Alien.S01E03.720p.WEB.H264-GGEZ.mkv" "Resident.Alien.S01E03.720p.WEB.H264-GGEZ.mkv (score: 156 vs keeper 3418)"

# Group: Robin Hood (2025) {tvdb-454834}/Season 01/S01E03
# KEEP: Robin Hood (2025) - S01E03 - No Man Can Hide Forever [AMZN][WEBDL-1080p][EAC3 5.1][h264]-RAWR.mkv (score: 3534)
cleanup_file "/mnt/synology/rs-tv/Robin Hood (2025) {tvdb-454834}/Season 01/Robin Hood (2025) - S01E03 - No Man Can Hide Forever [WEBDL-1080p][EAC3 5.1][h264]-RAWR.mkv" "Robin Hood (2025) - S01E03 - No Man Can Hide Forever [WEBDL-1080p][EAC3 5.1][h264]-RAWR.mkv (score: 3534 vs keeper 3534)"

# Group: Robin Hood (2025) {tvdb-454834}/Season 01/S01E04
# KEEP: Robin Hood (2025) - S01E04 - The Cause of This Unrest [AMZN][WEBDL-1080p][EAC3 5.1][h264]-RAWR.mkv (score: 3535)
cleanup_file "/mnt/synology/rs-tv/Robin Hood (2025) {tvdb-454834}/Season 01/Robin Hood (2025) - S01E04 - The Cause of This Unrest [WEBDL-1080p][EAC3 5.1][h264]-RAWR.mkv" "Robin Hood (2025) - S01E04 - The Cause of This Unrest [WEBDL-1080p][EAC3 5.1][h264]-RAWR.mkv (score: 3535 vs keeper 3535)"

# Group: Robin Hood (2025) {tvdb-454834}/Season 01/S01E05
# KEEP: Robin Hood (2025) - S01E05 - Go Back to Them [AMZN][WEBDL-1080p][EAC3 5.1][h264]-RAWR.mkv (score: 3536)
cleanup_file "/mnt/synology/rs-tv/Robin Hood (2025) {tvdb-454834}/Season 01/Robin Hood (2025) - S01E05 - Go Back to Them [WEBDL-1080p][EAC3 5.1][h264]-RAWR.mkv" "Robin Hood (2025) - S01E05 - Go Back to Them [WEBDL-1080p][EAC3 5.1][h264]-RAWR.mkv (score: 3536 vs keeper 3536)"

# Group: Robin Hood (2025) {tvdb-454834}/Season 01/S01E06
# KEEP: Robin Hood (2025) - S01E06 - Bound by Love Divided by Lies [WEBDL-1080p][EAC3 5.1][h264]-RAWR.mkv (score: 3540)
cleanup_file "/mnt/synology/rs-tv/Robin Hood (2025) {tvdb-454834}/Season 01/Robin Hood (2025) - S01E06 - Bound by Love Divided by Lies [AMZN][WEBDL-1080p][EAC3 5.1][h264]-RAWR.mkv" "Robin Hood (2025) - S01E06 - Bound by Love Divided by Lies [AMZN][WEBDL-1080p][EAC3 5.1][h264]-RAWR.mkv (score: 3540 vs keeper 3540)"

# Group: Robin Hood (2025) {tvdb-454834}/Season 01/S01E07
# KEEP: Robin Hood (2025) - S01E07 - Thieves with Purpose [AMZN][WEBDL-1080p][EAC3 5.1][h264]-RAWR.mkv (score: 3539)
cleanup_file "/mnt/synology/rs-tv/Robin Hood (2025) {tvdb-454834}/Season 01/Robin Hood (2025) - S01E07 - Thieves with Purpose [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv" "Robin Hood (2025) - S01E07 - Thieves with Purpose [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3539 vs keeper 3539)"

# Group: Robin Hood (2025) {tvdb-454834}/Season 01/S01E08
# KEEP: Robin Hood (2025) - S01E08 - The True Price of Defiance [AMZN][WEBDL-1080p][EAC3 5.1][h264]-RAWR.mkv (score: 3534)
cleanup_file "/mnt/synology/rs-tv/Robin Hood (2025) {tvdb-454834}/Season 01/Robin Hood (2025) - S01E08 - The True Price of Defiance [WEBDL-1080p][EAC3 5.1][h264]-RAWR.mkv" "Robin Hood (2025) - S01E08 - The True Price of Defiance [WEBDL-1080p][EAC3 5.1][h264]-RAWR.mkv (score: 3534 vs keeper 3534)"

# Group: Robin Hood (2025) {tvdb-454834}/Season 01/S01E09
# KEEP: Robin Hood (2025) - S01E09 - I Choose You [AMZN][WEBDL-1080p][EAC3 5.1][h264]-RAWR.mkv (score: 3537)
cleanup_file "/mnt/synology/rs-tv/Robin Hood (2025) {tvdb-454834}/Season 01/Robin Hood (2025) - S01E09 - I Choose You [WEBDL-1080p][EAC3 5.1][h264]-RAWR.mkv" "Robin Hood (2025) - S01E09 - I Choose You [WEBDL-1080p][EAC3 5.1][h264]-RAWR.mkv (score: 3537 vs keeper 3537)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 01/S01E01
# KEEP: Sealab 2021 (2000) - S01E01 - Radio Free Sealab [HMAX][WEBDL-1080p][EAC3 2.0][x264]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 01/Sealab 2021 (2000) - S01E01 - Radio Free Sealab [WEBRip-1080p][EAC3 2.0][x265]-iVy.mkv" "Sealab 2021 (2000) - S01E01 - Radio Free Sealab [WEBRip-1080p][EAC3 2.0][x265]-iVy.mkv (score: 2751 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 01/S01E02
# KEEP: Sealab 2021 (2000) - S01E02 - I Robot [WEBRip-1080p][EAC3 2.0][x265]-iVy.mkv (score: 2751)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 01/Sealab.2021.S01E02.I,.Robot.HBOMAX.WEB-DL1080.p.x264.EAC3.2.0-soopkitchen.mp4" "Sealab.2021.S01E02.I,.Robot.HBOMAX.WEB-DL1080.p.x264.EAC3.2.0-soopkitchen.mp4 (score: 1507 vs keeper 2751)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 01/S01E03
# KEEP: Sealab 2021 (2000) - S01E03 - Happy Cake [HMAX][WEBDL-1080p][EAC3 2.0][x264]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 01/Sealab 2021 (2000) - S01E03 - Happy Cake [WEBRip-1080p][EAC3 2.0][x265]-iVy.mkv" "Sealab 2021 (2000) - S01E03 - Happy Cake [WEBRip-1080p][EAC3 2.0][x265]-iVy.mkv (score: 2751 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 01/S01E04
# KEEP: Sealab 2021 (2000) - S01E04 - Chickmate [HMAX][WEBDL-1080p][EAC3 2.0][x264]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 01/Sealab 2021 (2000) - S01E04 - Chickmate [WEBRip-1080p][EAC3 2.0][x265]-iVy.mkv" "Sealab 2021 (2000) - S01E04 - Chickmate [WEBRip-1080p][EAC3 2.0][x265]-iVy.mkv (score: 2751 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 01/S01E05
# KEEP: Sealab 2021 (2000) - S01E05 - Predator [HMAX][WEBDL-1080p][EAC3 2.0][x264]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 01/Sealab 2021 (2000) - S01E05 - Predator [WEBRip-1080p][EAC3 2.0][x265]-iVy.mkv" "Sealab 2021 (2000) - S01E05 - Predator [WEBRip-1080p][EAC3 2.0][x265]-iVy.mkv (score: 2750 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 01/S01E06
# KEEP: Sealab 2021 (2000) - S01E06 - Lost in Time [HMAX][WEBDL-1080p][EAC3 2.0][x264]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 01/Sealab 2021 (2000) - S01E06 - Lost in Time [WEBRip-1080p][EAC3 2.0][x265]-iVy.mkv" "Sealab 2021 (2000) - S01E06 - Lost in Time [WEBRip-1080p][EAC3 2.0][x265]-iVy.mkv (score: 2751 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 01/S01E07
# KEEP: Sealab 2021 (2000) - S01E07 - Little Orphan Angry [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 01/Sealab 2021 (2000) - S01E07 - Little Orphan Angry [WEBRip-1080p][EAC3 2.0][x265]-iVy.mkv" "Sealab 2021 (2000) - S01E07 - Little Orphan Angry [WEBRip-1080p][EAC3 2.0][x265]-iVy.mkv (score: 2751 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 01/S01E08
# KEEP: Sealab 2021 (2000) - S01E08 - Waking Quinn [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 01/Sealab 2021 (2000) - S01E08 - Waking Quinn [WEBRip-1080p][EAC3 2.0][x265]-iVy.mkv" "Sealab 2021 (2000) - S01E08 - Waking Quinn [WEBRip-1080p][EAC3 2.0][x265]-iVy.mkv (score: 2751 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 01/S01E09
# KEEP: Sealab 2021 (2000) - S01E09 - All That Jazz [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 01/Sealab 2021 (2000) - S01E09 - All That Jazz [WEBRip-1080p][EAC3 2.0][x265]-iVy.mkv" "Sealab 2021 (2000) - S01E09 - All That Jazz [WEBRip-1080p][EAC3 2.0][x265]-iVy.mkv (score: 2750 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 01/S01E10
# KEEP: Sealab 2021 (2000) - S01E10 - Murphy Murph and the Feng Shui Bunch [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 01/Sealab 2021 (2000) - S01E10 - Murphy Murph and the Feng Shui Bunch [WEBRip-1080p][EAC3 2.0][x265]-iVy.mkv" "Sealab 2021 (2000) - S01E10 - Murphy Murph and the Feng Shui Bunch [WEBRip-1080p][EAC3 2.0][x265]-iVy.mkv (score: 2750 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 02/S02E01
# KEEP: Sealab 2021 (2000) - S02E01 - In The Closet [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 02/Sealab 2021 (2000) - S02E01 - In The Closet [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S02E01 - In The Closet [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 02/S02E02
# KEEP: Sealab 2021 (2000) - S02E02 - Stimutacs [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 02/Sealab 2021 (2000) - S02E02 - Stimutacs [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S02E02 - Stimutacs [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 02/S02E03
# KEEP: Sealab 2021 (2000) - S02E03 - Swimming in Oblivion [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 02/Sealab 2021 (2000) - S02E03 - Swimming in Oblivion [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S02E03 - Swimming in Oblivion [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 02/S02E04
# KEEP: Sealab 2021 (2000) - S02E04 - Der Dieb [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 02/Sealab 2021 (2000) - S02E04 - Der Dieb [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S02E04 - Der Dieb [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 02/S02E05
# KEEP: Sealab 2021 (2000) - S02E05 - The Policy [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 02/Sealab 2021 (2000) - S02E05 - The Policy [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S02E05 - The Policy [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 02/S02E06
# KEEP: Sealab 2021 (2000) - S02E06 - Hail Squishface [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 02/Sealab 2021 (2000) - S02E06 - Hail Squishface [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S02E06 - Hail Squishface [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 02/S02E07
# KEEP: Sealab 2021 (2000) - S02E07 - Bizzaro [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 02/Sealab 2021 (2000) - S02E07 - Bizzaro [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S02E07 - Bizzaro [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 02/S02E08
# KEEP: Sealab 2021 (2000) - S02E08 - Legend of Baggy Pants [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 02/Sealab 2021 (2000) - S02E08 - Legend of Baggy Pants [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S02E08 - Legend of Baggy Pants [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 02/S02E09
# KEEP: Sealab 2021 (2000) - S02E09 - Tinfins [WEBDL-1080p][EAC3 2.0][x264]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 02/Sealab 2021 (2000) - S02E09 - Tinfins [HMAX][WEBDL-1080p][EAC3 2.0][x264]-soopkitchen.mp4" "Sealab 2021 (2000) - S02E09 - Tinfins [HMAX][WEBDL-1080p][EAC3 2.0][x264]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 02/S02E10
# KEEP: Sealab 2021 (2000) - S02E10 - 7211 [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 02/Sealab 2021 (2000) - S02E10 - 7211 [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S02E10 - 7211 [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 02/S02E11
# KEEP: Sealab 2021 (2000) - S02E11 - Feast of Alvis [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 02/Sealab 2021 (2000) - S02E11 - Feast of Alvis [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S02E11 - Feast of Alvis [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 03/S03E01
# KEEP: Sealab 2021 (2000) - S03E01 - Brainswitch [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 03/Sealab 2021 (2000) - S03E01 - Brainswitch [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S03E01 - Brainswitch [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 03/S03E02
# KEEP: Sealab 2021 (2000) - S03E02 - Vacation [HMAX][WEBDL-1080p][EAC3 2.0][x264]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 03/Sealab 2021 (2000) - S03E02 - Vacation [WEBDL-1080p][EAC3 2.0][x264]-soopkitchen.mp4" "Sealab 2021 (2000) - S03E02 - Vacation [WEBDL-1080p][EAC3 2.0][x264]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 03/S03E03
# KEEP: Sealab 2021 (2000) - S03E03 - Fusebox [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3505)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 03/Sealab 2021 (2000) - S03E03 - Fusebox [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S03E03 - Fusebox [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3505 vs keeper 3505)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 03/S03E04
# KEEP: Sealab 2021 (2000) - S03E04 - Article 4 [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 03/Sealab 2021 (2000) - S03E04 - Article 4 [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S03E04 - Article 4 [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 03/S03E05
# KEEP: Sealab 2021 (2000) - S03E05 - Return to Oblivion [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 03/Sealab 2021 (2000) - S03E05 - Return to Oblivion [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S03E05 - Return to Oblivion [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 03/S03E06
# KEEP: Sealab 2021 (2000) - S03E06 - Splitsville [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 03/Sealab 2021 (2000) - S03E06 - Splitsville [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S03E06 - Splitsville [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 03/S03E07
# KEEP: Sealab 2021 (2000) - S03E07 - Tourist Season [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 03/Sealab 2021 (2000) - S03E07 - Tourist Season [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S03E07 - Tourist Season [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 03/S03E08
# KEEP: Sealab 2021 (2000) - S03E08 - Red Dawn [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 03/Sealab 2021 (2000) - S03E08 - Red Dawn [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S03E08 - Red Dawn [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 03/S03E09
# KEEP: Sealab 2021 (2000) - S03E09 - Meet Beck Bristow [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 03/Sealab 2021 (2000) - S03E09 - Meet Beck Bristow [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S03E09 - Meet Beck Bristow [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 03/S03E10
# KEEP: Sealab 2021 (2000) - S03E10 - I Robot Really [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 03/Sealab 2021 (2000) - S03E10 - I Robot Really [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S03E10 - I Robot Really [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 03/S03E11
# KEEP: Sealab 2021 (2000) - S03E11 - Frozen Dinner [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 03/Sealab 2021 (2000) - S03E11 - Frozen Dinner [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S03E11 - Frozen Dinner [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 03/S03E12
# KEEP: Sealab 2021 (2000) - S03E12 - Tornado Shanks [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 03/Sealab 2021 (2000) - S03E12 - Tornado Shanks [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S03E12 - Tornado Shanks [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 04/S04E01
# KEEP: Sealab 2021 (2000) - S04E01 - ASHDTV [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 04/Sealab 2021 (2000) - S04E01 - ASHDTV [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S04E01 - ASHDTV [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 04/S04E02
# KEEP: Sealab 2021 (2000) - S04E02 - Chalkboard Jungle [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 04/Sealab 2021 (2000) - S04E02 - Chalkboard Jungle [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S04E02 - Chalkboard Jungle [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 04/S04E03
# KEEP: Sealab 2021 (2000) - S04E03 - Dearly Beloved Seed [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 04/Sealab 2021 (2000) - S04E03 - Dearly Beloved Seed [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S04E03 - Dearly Beloved Seed [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 04/S04E04
# KEEP: Sealab 2021 (2000) - S04E04 - Craptastic Voyage [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 04/Sealab 2021 (2000) - S04E04 - Craptastic Voyage [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S04E04 - Craptastic Voyage [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 04/S04E05
# KEEP: Sealab 2021 (2000) - S04E05 - Let 'Em Eat Corn [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 04/Sealab 2021 (2000) - S04E05 - Let 'Em Eat Corn [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S04E05 - Let 'Em Eat Corn [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 04/S04E06
# KEEP: Sealab 2021 (2000) - S04E06 - Neptunati [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 04/Sealab 2021 (2000) - S04E06 - Neptunati [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S04E06 - Neptunati [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 04/S04E07
# KEEP: Sealab 2021 (2000) - S04E07 - Isla de las Chupracabras [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 04/Sealab 2021 (2000) - S04E07 - Isla de las Chupracabras [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S04E07 - Isla de las Chupracabras [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 04/S04E08
# KEEP: Sealab 2021 (2000) - S04E08 - Joy of Grief [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 04/Sealab 2021 (2000) - S04E08 - Joy of Grief [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S04E08 - Joy of Grief [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 04/S04E09
# KEEP: Sealab 2021 (2000) - S04E09 - Green Fever [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 04/Sealab 2021 (2000) - S04E09 - Green Fever [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S04E09 - Green Fever [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 04/S04E10
# KEEP: Sealab 2021 (2000) - S04E10 - Sharkos Machine [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 04/Sealab 2021 (2000) - S04E10 - Sharkos Machine [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S04E10 - Sharkos Machine [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Sealab 2021 (2000) {tvdb-76884}/Season 04/S04E11
# KEEP: Sealab 2021 (2000) - S04E11 - Return of Marco [HMAX][WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506)
cleanup_file "/mnt/synology/rs-tv/Sealab 2021 (2000) {tvdb-76884}/Season 04/Sealab 2021 (2000) - S04E11 - Return of Marco [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4" "Sealab 2021 (2000) - S04E11 - Return of Marco [WEBDL-1080p][EAC3 2.0][AVC]-soopkitchen.mp4 (score: 3506 vs keeper 3506)"

# Group: Secrets of the Whales (2021) {tvdb-393225}/Season 01/S01E01
# KEEP: Secrets of the Whales (2021) - S01E01 - Orca Dynasty [DSNP][WEBDL-1080p][EAC3 5.1][h264]-WH4L3S.mkv (score: 3528)
cleanup_file "/mnt/synology/rs-tv/Secrets of the Whales (2021) {tvdb-393225}/Season 01/Secrets of the Whales (2021) - S01E01 - Orca Dynasty [WEBDL-1080p][EAC3 5.1][h264].mkv" "Secrets of the Whales (2021) - S01E01 - Orca Dynasty [WEBDL-1080p][EAC3 5.1][h264].mkv (score: 3528 vs keeper 3528)"

# Group: Seinfeld (1989) {tvdb-79169}/Season 08/S08E04
# KEEP: Seinfeld (1989) - S08E04 - The Little Kicks [WEBDL-1080p][EAC3 2.0][h264].mkv (score: 3523)
cleanup_file "/mnt/synology/rs-tv/Seinfeld (1989) {tvdb-79169}/Season 08/Seinfeld (1989) - S08E04 - The Little Kicks [WEBRip-1080p][AC3 2.0][h265].mkv" "Seinfeld (1989) - S08E04 - The Little Kicks [WEBRip-1080p][AC3 2.0][h265].mkv (score: 2704 vs keeper 3523)"

# Group: Seinfeld (1989) {tvdb-79169}/Season 08/S08E07
# KEEP: Seinfeld (1989) - S08E07 - The Checks [WEBDL-1080p][EAC3 2.0][h264].mkv (score: 3523)
cleanup_file "/mnt/synology/rs-tv/Seinfeld (1989) {tvdb-79169}/Season 08/Seinfeld (1989) - S08E07 - The Checks [WEBRip-1080p][AC3 2.0][h265].mkv" "Seinfeld (1989) - S08E07 - The Checks [WEBRip-1080p][AC3 2.0][h265].mkv (score: 2704 vs keeper 3523)"

# Group: Seinfeld (1989) {tvdb-79169}/Season 08/S08E08
# KEEP: Seinfeld (1989) - S08E08 - The Chicken Roaster [WEBDL-1080p][EAC3 2.0][h264].mkv (score: 3523)
cleanup_file "/mnt/synology/rs-tv/Seinfeld (1989) {tvdb-79169}/Season 08/Seinfeld (1989) - S08E08 - The Chicken Roaster [WEBRip-1080p][AC3 2.0][h265].mkv" "Seinfeld (1989) - S08E08 - The Chicken Roaster [WEBRip-1080p][AC3 2.0][h265].mkv (score: 2704 vs keeper 3523)"

# Group: Seinfeld (1989) {tvdb-79169}/Season 08/S08E16
# KEEP: Seinfeld (1989) - S08E16 - The Pothole [WEBDL-1080p][EAC3 2.0][h264].mkv (score: 3523)
cleanup_file "/mnt/synology/rs-tv/Seinfeld (1989) {tvdb-79169}/Season 08/Seinfeld (1989) - S08E16 - The Pothole [WEBRip-1080p][AC3 2.0][h265].mkv" "Seinfeld (1989) - S08E16 - The Pothole [WEBRip-1080p][AC3 2.0][h265].mkv (score: 2704 vs keeper 3523)"

# Group: Seinfeld (1989) {tvdb-79169}/Season 08/S08E18
# KEEP: Seinfeld (1989) - S08E18 - The Nap [WEBDL-1080p][EAC3 2.0][h264].mkv (score: 3523)
cleanup_file "/mnt/synology/rs-tv/Seinfeld (1989) {tvdb-79169}/Season 08/Seinfeld (1989) - S08E18 - The Nap [WEBRip-1080p][AC3 2.0][h265].mkv" "Seinfeld (1989) - S08E18 - The Nap [WEBRip-1080p][AC3 2.0][h265].mkv (score: 2704 vs keeper 3523)"

# Group: Seinfeld (1989) {tvdb-79169}/Season 08/S08E19
# KEEP: Seinfeld (1989) - S08E19 - The Yada Yada [WEBDL-1080p][EAC3 2.0][h264].mkv (score: 3527)
cleanup_file "/mnt/synology/rs-tv/Seinfeld (1989) {tvdb-79169}/Season 08/Seinfeld (1989) - S08E19 - The Yada Yada [WEBRip-1080p][AC3 2.0][h265].mkv" "Seinfeld (1989) - S08E19 - The Yada Yada [WEBRip-1080p][AC3 2.0][h265].mkv (score: 2704 vs keeper 3527)"

# Group: Seinfeld (1989) {tvdb-79169}/Season 08/S08E22
# KEEP: Seinfeld (1989) - S08E22 - The Summer of George [WEBDL-1080p][EAC3 2.0][h264].mkv (score: 3523)
cleanup_file "/mnt/synology/rs-tv/Seinfeld (1989) {tvdb-79169}/Season 08/Seinfeld (1989) - S08E22 - The Summer of George [WEBRip-1080p][AC3 2.0][h265].mkv" "Seinfeld (1989) - S08E22 - The Summer of George [WEBRip-1080p][AC3 2.0][h265].mkv (score: 2704 vs keeper 3523)"

# Group: Seinfeld (1989) {tvdb-79169}/Season 09/S09E01
# KEEP: Seinfeld (1989) - S09E01 - The Butter Shave [WEBDL-1080p][EAC3 2.0][h264].mkv (score: 3523)
cleanup_file "/mnt/synology/rs-tv/Seinfeld (1989) {tvdb-79169}/Season 09/Seinfeld (1989) - S09E01 - The Butter Shave [WEBRip-1080p][AC3 2.0][h265].mkv" "Seinfeld (1989) - S09E01 - The Butter Shave [WEBRip-1080p][AC3 2.0][h265].mkv (score: 2704 vs keeper 3523)"

# Group: Seinfeld (1989) {tvdb-79169}/Season 09/S09E02
# KEEP: Seinfeld (1989) - S09E02 - The Voice [WEBDL-1080p][EAC3 2.0][h264].mkv (score: 3523)
cleanup_file "/mnt/synology/rs-tv/Seinfeld (1989) {tvdb-79169}/Season 09/Seinfeld (1989) - S09E02 - The Voice [WEBRip-1080p][AC3 2.0][h265].mkv" "Seinfeld (1989) - S09E02 - The Voice [WEBRip-1080p][AC3 2.0][h265].mkv (score: 2704 vs keeper 3523)"

# Group: Seinfeld (1989) {tvdb-79169}/Season 09/S09E03
# KEEP: Seinfeld (1989) - S09E03 - The Serenity Now [WEBDL-1080p][EAC3 2.0][h264].mkv (score: 3523)
cleanup_file "/mnt/synology/rs-tv/Seinfeld (1989) {tvdb-79169}/Season 09/Seinfeld (1989) - S09E03 - The Serenity Now [WEBRip-1080p][AC3 2.0][h265].mkv" "Seinfeld (1989) - S09E03 - The Serenity Now [WEBRip-1080p][AC3 2.0][h265].mkv (score: 2704 vs keeper 3523)"

# Group: Seinfeld (1989) {tvdb-79169}/Season 09/S09E08
# KEEP: Seinfeld (1989) - S09E08 - The Betrayal [WEBDL-1080p][EAC3 2.0][h264].mkv (score: 3524)
cleanup_file "/mnt/synology/rs-tv/Seinfeld (1989) {tvdb-79169}/Season 09/Seinfeld (1989) - S09E08 - The Betrayal [WEBRip-1080p][AC3 2.0][h265].mkv" "Seinfeld (1989) - S09E08 - The Betrayal [WEBRip-1080p][AC3 2.0][h265].mkv (score: 2704 vs keeper 3524)"

# Group: Seinfeld (1989) {tvdb-79169}/Season 09/S09E09
# KEEP: Seinfeld (1989) - S09E09 - The Apology [WEBDL-1080p][EAC3 2.0][h264].mkv (score: 3523)
cleanup_file "/mnt/synology/rs-tv/Seinfeld (1989) {tvdb-79169}/Season 09/Seinfeld (1989) - S09E09 - The Apology [WEBRip-1080p][AC3 2.0][h265].mkv" "Seinfeld (1989) - S09E09 - The Apology [WEBRip-1080p][AC3 2.0][h265].mkv (score: 2704 vs keeper 3523)"

# Group: Seinfeld (1989) {tvdb-79169}/Season 09/S09E12
# KEEP: Seinfeld (1989) - S09E12 - The Reverse Peephole [WEBDL-1080p][EAC3 2.0][h264].mkv (score: 3523)
cleanup_file "/mnt/synology/rs-tv/Seinfeld (1989) {tvdb-79169}/Season 09/Seinfeld (1989) - S09E12 - The Reverse Peephole [WEBRip-1080p][AC3 2.0][h265].mkv" "Seinfeld (1989) - S09E12 - The Reverse Peephole [WEBRip-1080p][AC3 2.0][h265].mkv (score: 2704 vs keeper 3523)"

# Group: Seinfeld (1989) {tvdb-79169}/Season 09/S09E16
# KEEP: Seinfeld (1989) - S09E16 - The Burning [WEBDL-1080p][EAC3 2.0][h264].mkv (score: 3523)
cleanup_file "/mnt/synology/rs-tv/Seinfeld (1989) {tvdb-79169}/Season 09/Seinfeld (1989) - S09E16 - The Burning [WEBRip-1080p][AC3 2.0][h265].mkv" "Seinfeld (1989) - S09E16 - The Burning [WEBRip-1080p][AC3 2.0][h265].mkv (score: 2704 vs keeper 3523)"

# Group: Seinfeld (1989) {tvdb-79169}/Season 09/S09E17
# KEEP: Seinfeld (1989) - S09E17 - The Bookstore [WEBDL-1080p][EAC3 2.0][h264].mkv (score: 3523)
cleanup_file "/mnt/synology/rs-tv/Seinfeld (1989) {tvdb-79169}/Season 09/Seinfeld (1989) - S09E17 - The Bookstore [WEBRip-1080p][AC3 2.0][h265].mkv" "Seinfeld (1989) - S09E17 - The Bookstore [WEBRip-1080p][AC3 2.0][h265].mkv (score: 2704 vs keeper 3523)"

# Group: Seinfeld (1989) {tvdb-79169}/Season 09/S09E19
# KEEP: Seinfeld (1989) - S09E19 - The Maid [WEBDL-1080p][EAC3 2.0][h264].mkv (score: 3523)
cleanup_file "/mnt/synology/rs-tv/Seinfeld (1989) {tvdb-79169}/Season 09/Seinfeld (1989) - S09E19 - The Maid [WEBRip-1080p][AC3 2.0][h265].mkv" "Seinfeld (1989) - S09E19 - The Maid [WEBRip-1080p][AC3 2.0][h265].mkv (score: 2704 vs keeper 3523)"

# Group: Snowpiercer (2020) {tvdb-364928}/Season 01/S01E01
# KEEP: Snowpiercer (2020) - S01E01 - First the Weather Changed [AMZN][WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv (score: 3534)
cleanup_file "/mnt/synology/rs-tv/Snowpiercer (2020) {tvdb-364928}/Season 01/Snowpiercer (2020) - S01E01 - First the Weather Changed [Bluray-1080p][EAC3 5.1][x264]-BTN.mkv" "Snowpiercer (2020) - S01E01 - First the Weather Changed [Bluray-1080p][EAC3 5.1][x264]-BTN.mkv (score: 3344 vs keeper 3534)"

# Group: Snowpiercer (2020) {tvdb-364928}/Season 01/S01E02
# KEEP: Snowpiercer (2020) - S01E02 - Prepare to Brace [AMZN][WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv (score: 3529)
cleanup_file "/mnt/synology/rs-tv/Snowpiercer (2020) {tvdb-364928}/Season 01/Snowpiercer (2020) - S01E02 - Prepare to Brace [Bluray-1080p][EAC3 5.1][x264]-BTN.mkv" "Snowpiercer (2020) - S01E02 - Prepare to Brace [Bluray-1080p][EAC3 5.1][x264]-BTN.mkv (score: 3338 vs keeper 3529)"

# Group: Snowpiercer (2020) {tvdb-364928}/Season 01/S01E03
# KEEP: Snowpiercer (2020) - S01E03 - Access Is Power [AMZN][WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv (score: 3527)
cleanup_file "/mnt/synology/rs-tv/Snowpiercer (2020) {tvdb-364928}/Season 01/Snowpiercer (2020) - S01E03 - Access Is Power [Bluray-1080p][EAC3 5.1][x264]-BTN.mkv" "Snowpiercer (2020) - S01E03 - Access Is Power [Bluray-1080p][EAC3 5.1][x264]-BTN.mkv (score: 3335 vs keeper 3527)"

# Group: Snowpiercer (2020) {tvdb-364928}/Season 01/S01E04
# KEEP: Snowpiercer (2020) - S01E04 - Without Their Maker [AMZN][WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv (score: 3526)
cleanup_file "/mnt/synology/rs-tv/Snowpiercer (2020) {tvdb-364928}/Season 01/Snowpiercer (2020) - S01E04 - Without Their Maker [Bluray-1080p][EAC3 5.1][x264]-BTN.mkv" "Snowpiercer (2020) - S01E04 - Without Their Maker [Bluray-1080p][EAC3 5.1][x264]-BTN.mkv (score: 3335 vs keeper 3526)"

# Group: Snowpiercer (2020) {tvdb-364928}/Season 01/S01E05
# KEEP: Snowpiercer (2020) - S01E05 - Justice Never Boarded [AMZN][WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv (score: 3528)
cleanup_file "/mnt/synology/rs-tv/Snowpiercer (2020) {tvdb-364928}/Season 01/Snowpiercer (2020) - S01E05 - Justice Never Boarded [Bluray-1080p][EAC3 5.1][x264]-BTN.mkv" "Snowpiercer (2020) - S01E05 - Justice Never Boarded [Bluray-1080p][EAC3 5.1][x264]-BTN.mkv (score: 3335 vs keeper 3528)"

# Group: Snowpiercer (2020) {tvdb-364928}/Season 01/S01E06
# KEEP: Snowpiercer (2020) - S01E06 - Trouble Comes Sideways [AMZN][WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv (score: 3527)
cleanup_file "/mnt/synology/rs-tv/Snowpiercer (2020) {tvdb-364928}/Season 01/Snowpiercer (2020) - S01E06 - Trouble Comes Sideways [Bluray-1080p][EAC3 5.1][x264]-BTN.mkv" "Snowpiercer (2020) - S01E06 - Trouble Comes Sideways [Bluray-1080p][EAC3 5.1][x264]-BTN.mkv (score: 3336 vs keeper 3527)"

# Group: Snowpiercer (2020) {tvdb-364928}/Season 01/S01E07
# KEEP: Snowpiercer (2020) - S01E07 - The Universe Is Indifferent [AMZN][WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv (score: 3528)
cleanup_file "/mnt/synology/rs-tv/Snowpiercer (2020) {tvdb-364928}/Season 01/Snowpiercer (2020) - S01E07 - The Universe Is Indifferent [Bluray-1080p][EAC3 5.1][x264]-BTN.mkv" "Snowpiercer (2020) - S01E07 - The Universe Is Indifferent [Bluray-1080p][EAC3 5.1][x264]-BTN.mkv (score: 3335 vs keeper 3528)"

# Group: Snowpiercer (2020) {tvdb-364928}/Season 01/S01E08
# KEEP: Snowpiercer (2020) - S01E08 - These Are His Revolutions [AMZN][WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv (score: 3530)
cleanup_file "/mnt/synology/rs-tv/Snowpiercer (2020) {tvdb-364928}/Season 01/Snowpiercer (2020) - S01E08 - These Are His Revolutions [Bluray-1080p][EAC3 5.1][x264]-BTN.mkv" "Snowpiercer (2020) - S01E08 - These Are His Revolutions [Bluray-1080p][EAC3 5.1][x264]-BTN.mkv (score: 3338 vs keeper 3530)"

# Group: Snowpiercer (2020) {tvdb-364928}/Season 01/S01E09
# KEEP: Snowpiercer (2020) - S01E09 - The Train Demanded Blood [AMZN][WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv (score: 3525)
cleanup_file "/mnt/synology/rs-tv/Snowpiercer (2020) {tvdb-364928}/Season 01/Snowpiercer (2020) - S01E09 - The Train Demanded Blood [Bluray-1080p][EAC3 5.1][x264]-BTN.mkv" "Snowpiercer (2020) - S01E09 - The Train Demanded Blood [Bluray-1080p][EAC3 5.1][x264]-BTN.mkv (score: 3334 vs keeper 3525)"

# Group: Snowpiercer (2020) {tvdb-364928}/Season 01/S01E10
# KEEP: Snowpiercer (2020) - S01E10 - 994 Cars Long [AMZN][WEBDL-1080p Proper][EAC3 5.1][h264]-NTG.mkv (score: 3528)
cleanup_file "/mnt/synology/rs-tv/Snowpiercer (2020) {tvdb-364928}/Season 01/Snowpiercer (2020) - S01E10 - 994 Cars Long [Bluray-1080p][EAC3 5.1][x264]-BTN.mkv" "Snowpiercer (2020) - S01E10 - 994 Cars Long [Bluray-1080p][EAC3 5.1][x264]-BTN.mkv (score: 3336 vs keeper 3528)"

# Group: Squid Game - The Challenge (2023) {tvdb-421260}/Season 02/S02E04
# KEEP: Squid Game - The Challenge (2023) - S02E04 - Mingle [WEBDL-1080p][EAC3 5.1][x264].mkv (score: 3528)
cleanup_file "/mnt/synology/rs-tv/Squid Game - The Challenge (2023) {tvdb-421260}/Season 02/Squid Game - The Challenge (2023) - S02E04 - Mingle [NF][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv" "Squid Game - The Challenge (2023) - S02E04 - Mingle [NF][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv (score: 3528 vs keeper 3528)"

# Group: Stargate SG-1 (1997) {tvdb-72449}/Season 07/S07E14
# KEEP: Stargate SG-1 (1997) - S07E14 - Fallout [Bluray-1080p][EAC3 2.0][AVC]-PiR8.mkv (score: 3329)
cleanup_file "/mnt/synology/rs-tv/Stargate SG-1 (1997) {tvdb-72449}/Season 07/Stargate SG-1 (1997) - S07E14 - Fallout [HDTV-1080p][MP2 2.0][h264]-SFM.mkv" "Stargate SG-1 (1997) - S07E14 - Fallout [HDTV-1080p][MP2 2.0][h264]-SFM.mkv (score: 2367 vs keeper 3329)"

# Group: Station 19 (2018) {tvdb-341852}/Season 01/S01E04
# KEEP: Station 19 (2018) - S01E04 - Reignited [AMZN][WEBDL-1080p][EAC3 5.1][h264]-NTb.mkv (score: 3535)
cleanup_file "/mnt/synology/rs-tv/Station 19 (2018) {tvdb-341852}/Season 01/Station 19 (2018) - S01E04 - Reignited [WEBDL-1080p][EAC3 5.1][h264].mkv" "Station 19 (2018) - S01E04 - Reignited [WEBDL-1080p][EAC3 5.1][h264].mkv (score: 3526 vs keeper 3535)"

# Group: Strike Back (2010) {tvdb-148581}/Season 08/S08E10
# KEEP: Strike Back (2010) - S08E10 - Episode 10 [WEBDL-1080p][EAC3 5.1][h264]-NTb.mkv (score: 3534)
cleanup_file "/mnt/synology/rs-tv/Strike Back (2010) {tvdb-148581}/Season 08/Strike Back (2010) - S08E10 - Episode 10 [HDTV-1080p][EAC3 5.1][h264].MKV" "Strike Back (2010) - S08E10 - Episode 10 [HDTV-1080p][EAC3 5.1][h264].MKV (score: 2534 vs keeper 3534)"

# Group: Terminator Zero (2024) {tvdb-442145}/Season 01/S01E01
# KEEP: Terminator Zero (2024) - S01E01 - Model 101 [WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv (score: 3512)
cleanup_file "/mnt/synology/rs-tv/Terminator Zero (2024) {tvdb-442145}/Season 01/Terminator Zero (2024) - S01E01 - 001 - Model 101 [WEBDL-1080p][EAC3 5.1][JA+EN][x264 8bit]-FLUX.mkv" "Terminator Zero (2024) - S01E01 - 001 - Model 101 [WEBDL-1080p][EAC3 5.1][JA+EN][x264 8bit]-FLUX.mkv (score: 3512 vs keeper 3512)"

# Group: Terminator Zero (2024) {tvdb-442145}/Season 01/S01E02
# KEEP: Terminator Zero (2024) - S01E02 - Model 102 [WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv (score: 3512)
cleanup_file "/mnt/synology/rs-tv/Terminator Zero (2024) {tvdb-442145}/Season 01/Terminator Zero (2024) - S01E02 - 002 - Model 102 [WEBDL-1080p][EAC3 5.1][JA+EN][x264 8bit]-FLUX.mkv" "Terminator Zero (2024) - S01E02 - 002 - Model 102 [WEBDL-1080p][EAC3 5.1][JA+EN][x264 8bit]-FLUX.mkv (score: 3512 vs keeper 3512)"

# Group: Terminator Zero (2024) {tvdb-442145}/Season 01/S01E03
# KEEP: Terminator Zero (2024) - S01E03 - Model 103 [WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv (score: 3512)
cleanup_file "/mnt/synology/rs-tv/Terminator Zero (2024) {tvdb-442145}/Season 01/Terminator Zero (2024) - S01E03 - 003 - Model 103 [WEBDL-1080p][EAC3 5.1][JA+EN][x264 8bit]-FLUX.mkv" "Terminator Zero (2024) - S01E03 - 003 - Model 103 [WEBDL-1080p][EAC3 5.1][JA+EN][x264 8bit]-FLUX.mkv (score: 3512 vs keeper 3512)"

# Group: Terminator Zero (2024) {tvdb-442145}/Season 01/S01E04
# KEEP: Terminator Zero (2024) - S01E04 - Model 104 [WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv (score: 3511)
cleanup_file "/mnt/synology/rs-tv/Terminator Zero (2024) {tvdb-442145}/Season 01/Terminator Zero (2024) - S01E04 - 004 - Model 104 [WEBDL-1080p][EAC3 5.1][JA+EN][x264 8bit]-FLUX.mkv" "Terminator Zero (2024) - S01E04 - 004 - Model 104 [WEBDL-1080p][EAC3 5.1][JA+EN][x264 8bit]-FLUX.mkv (score: 3511 vs keeper 3511)"

# Group: Terminator Zero (2024) {tvdb-442145}/Season 01/S01E05
# KEEP: Terminator Zero (2024) - S01E05 - Model 105 [WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv (score: 3512)
cleanup_file "/mnt/synology/rs-tv/Terminator Zero (2024) {tvdb-442145}/Season 01/Terminator Zero (2024) - S01E05 - 005 - Model 105 [WEBDL-1080p][EAC3 5.1][JA+EN][x264 8bit]-FLUX.mkv" "Terminator Zero (2024) - S01E05 - 005 - Model 105 [WEBDL-1080p][EAC3 5.1][JA+EN][x264 8bit]-FLUX.mkv (score: 3512 vs keeper 3512)"

# Group: Terminator Zero (2024) {tvdb-442145}/Season 01/S01E06
# KEEP: Terminator Zero (2024) - S01E06 - 006 - Model 106 [WEBDL-1080p][EAC3 5.1][JA+EN][x264 8bit]-FLUX.mkv (score: 3510)
cleanup_file "/mnt/synology/rs-tv/Terminator Zero (2024) {tvdb-442145}/Season 01/Terminator Zero (2024) - S01E06 - Model 106 [WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv" "Terminator Zero (2024) - S01E06 - Model 106 [WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv (score: 3510 vs keeper 3510)"

# Group: Terminator Zero (2024) {tvdb-442145}/Season 01/S01E07
# KEEP: Terminator Zero (2024) - S01E07 - Model 107 [WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv (score: 3512)
cleanup_file "/mnt/synology/rs-tv/Terminator Zero (2024) {tvdb-442145}/Season 01/Terminator Zero (2024) - S01E07 - 007 - Model 107 [WEBDL-1080p][EAC3 5.1][JA+EN][x264 8bit]-FLUX.mkv" "Terminator Zero (2024) - S01E07 - 007 - Model 107 [WEBDL-1080p][EAC3 5.1][JA+EN][x264 8bit]-FLUX.mkv (score: 3512 vs keeper 3512)"

# Group: Terminator Zero (2024) {tvdb-442145}/Season 01/S01E08
# KEEP: Terminator Zero (2024) - S01E08 - 008 - Model 108 [WEBDL-1080p][EAC3 5.1][JA+EN][x264 8bit]-FLUX.mkv (score: 3512)
cleanup_file "/mnt/synology/rs-tv/Terminator Zero (2024) {tvdb-442145}/Season 01/Terminator Zero (2024) - S01E08 - Model 108 [WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv" "Terminator Zero (2024) - S01E08 - Model 108 [WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv (score: 3512 vs keeper 3512)"

# Group: The Blacklist (2013) {tvdb-266189}/Season 06/S06E01
# KEEP: The Blacklist (2013) - S06E01 - Dr. Hans Koehler [Bluray-1080p][DTS 5.1][x264]-ROVERS.mkv (score: 3382)
cleanup_file "/mnt/synology/rs-tv/The Blacklist (2013) {tvdb-266189}/Season 06/The Blacklist (2013) - S06E01 - Dr. Hans Koehler [HDTV-720p][AC3 5.1][x264].mkv" "The Blacklist (2013) - S06E01 - Dr. Hans Koehler [HDTV-720p][AC3 5.1][x264].mkv (score: 458 vs keeper 3382)"

# Group: The Bondsman (2025) {tvdb-436695}/Season 01/S01E01
# KEEP: The Bondsman (2025) - S01E01 - Pot O’Gold [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3522)
cleanup_file "/mnt/synology/rs-tv/The Bondsman (2025) {tvdb-436695}/Season 01/The Bondsman (2025) - S01E01 - Pot O’Gold [WEBRip-1080p][EAC3 5.1][x265]-HODL.mkv" "The Bondsman (2025) - S01E01 - Pot O’Gold [WEBRip-1080p][EAC3 5.1][x265]-HODL.mkv (score: 2754 vs keeper 3522)"

# Group: The Bondsman (2025) {tvdb-436695}/Season 01/S01E02
# KEEP: The Bondsman (2025) - S01E02 - Valacor [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3517)
cleanup_file "/mnt/synology/rs-tv/The Bondsman (2025) {tvdb-436695}/Season 01/The Bondsman (2025) - S01E02 - Valacor [WEBRip-1080p][EAC3 5.1][x265]-HODL.mkv" "The Bondsman (2025) - S01E02 - Valacor [WEBRip-1080p][EAC3 5.1][x265]-HODL.mkv (score: 2753 vs keeper 3517)"

# Group: The Bondsman (2025) {tvdb-436695}/Season 01/S01E03
# KEEP: The Bondsman (2025) - S01E03 - Marphos [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3520)
cleanup_file "/mnt/synology/rs-tv/The Bondsman (2025) {tvdb-436695}/Season 01/The Bondsman (2025) - S01E03 - Marphos [WEBRip-1080p][EAC3 5.1][x265]-HODL.mkv" "The Bondsman (2025) - S01E03 - Marphos [WEBRip-1080p][EAC3 5.1][x265]-HODL.mkv (score: 2754 vs keeper 3520)"

# Group: The Bondsman (2025) {tvdb-436695}/Season 01/S01E04
# KEEP: The Bondsman (2025) - S01E04 - Erdos [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3518)
cleanup_file "/mnt/synology/rs-tv/The Bondsman (2025) {tvdb-436695}/Season 01/The Bondsman (2025) - S01E04 - Erdos [WEBRip-1080p][EAC3 5.1][x265]-HODL.mkv" "The Bondsman (2025) - S01E04 - Erdos [WEBRip-1080p][EAC3 5.1][x265]-HODL.mkv (score: 2754 vs keeper 3518)"

# Group: The Bondsman (2025) {tvdb-436695}/Season 01/S01E05
# KEEP: The Bondsman (2025) - S01E05 - Slypharis [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3519)
cleanup_file "/mnt/synology/rs-tv/The Bondsman (2025) {tvdb-436695}/Season 01/The Bondsman (2025) - S01E05 - Slypharis [WEBRip-1080p][EAC3 5.1][x265]-HODL.mkv" "The Bondsman (2025) - S01E05 - Slypharis [WEBRip-1080p][EAC3 5.1][x265]-HODL.mkv (score: 2754 vs keeper 3519)"

# Group: The Bondsman (2025) {tvdb-436695}/Season 01/S01E06
# KEEP: The Bondsman (2025) - S01E06 - Revelations [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3520)
cleanup_file "/mnt/synology/rs-tv/The Bondsman (2025) {tvdb-436695}/Season 01/The Bondsman (2025) - S01E06 - Revelations [WEBRip-1080p][EAC3 5.1][x265]-HODL.mkv" "The Bondsman (2025) - S01E06 - Revelations [WEBRip-1080p][EAC3 5.1][x265]-HODL.mkv (score: 2754 vs keeper 3520)"

# Group: The Bondsman (2025) {tvdb-436695}/Season 01/S01E07
# KEEP: The Bondsman (2025) - S01E07 - Pyralis [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3516)
cleanup_file "/mnt/synology/rs-tv/The Bondsman (2025) {tvdb-436695}/Season 01/The Bondsman (2025) - S01E07 - Pyralis [WEBRip-1080p][EAC3 5.1][x265]-HODL.mkv" "The Bondsman (2025) - S01E07 - Pyralis [WEBRip-1080p][EAC3 5.1][x265]-HODL.mkv (score: 2753 vs keeper 3516)"

# Group: The Bondsman (2025) {tvdb-436695}/Season 01/S01E08
# KEEP: The Bondsman (2025) - S01E08 - Lilith [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3518)
cleanup_file "/mnt/synology/rs-tv/The Bondsman (2025) {tvdb-436695}/Season 01/The Bondsman (2025) - S01E08 - Lilith [WEBRip-1080p][EAC3 5.1][x265]-HODL.mkv" "The Bondsman (2025) - S01E08 - Lilith [WEBRip-1080p][EAC3 5.1][x265]-HODL.mkv (score: 2754 vs keeper 3518)"

# Group: The Right Stuff (2020) {tvdb-362576}/Season 01/S01E04
# KEEP: The Right Stuff (2020) - S01E04 - Advent [WEBDL-1080p][EAC3 Atmos 5.1][h264]-LAZY.mkv (score: 3881)
cleanup_file "/mnt/synology/rs-tv/The Right Stuff (2020) {tvdb-362576}/Season 01/The Right Stuff (2020) - S01E04 - Advent [HDTV-720p][EAC3 5.1][h264].mkv" "The Right Stuff (2020) - S01E04 - Advent [HDTV-720p][EAC3 5.1][h264].mkv (score: 515 vs keeper 3881)"

# Group: The Righteous Gemstones (2019) {tvdb-357223}/Season 04/S04E09
# KEEP: The Righteous Gemstones (2019) - S04E09 - That Man of God May Be Complete [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv (score: 3881)
cleanup_file "/mnt/synology/rs-tv/The Righteous Gemstones (2019) {tvdb-357223}/Season 04/The Righteous Gemstones (2019) - S04E09 - That Man of God May Be Complete [WEBDL-1080p][EAC3 5.1][h264]-SuccessfulCrab.mkv" "The Righteous Gemstones (2019) - S04E09 - That Man of God May Be Complete [WEBDL-1080p][EAC3 5.1][h264]-SuccessfulCrab.mkv (score: 3531 vs keeper 3881)"

# Group: The Simpsons (1989) {tvdb-71663}/Season 37/S37E12
# KEEP: The Simpsons (1989) - S37E12 - ¡The Fall Guy-Yi-Yi! [DSNP][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3506)
cleanup_file "/mnt/synology/rs-tv/The Simpsons (1989) {tvdb-71663}/Season 37/The Simpsons (1989) - S37E12 - ¡The Fall Guy-Yi-Yi! [[Trash] Release Sources (Streaming Service)_25_3 Release Sources (Streaming Service)_22_1][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv" "The Simpsons (1989) - S37E12 - ¡The Fall Guy-Yi-Yi! [[Trash] Release Sources (Streaming Service)_25_3 Release Sources (Streaming Service)_22_1][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3506 vs keeper 3506)"

# Group: Twilight of the Gods (2024) {tvdb-404605}/Season 01/S01E01
# KEEP: Twilight of the Gods (2024) - S01E01 - The Bride-Price [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-BYNDR.mkv (score: 3862)
cleanup_file "/mnt/synology/rs-tv/Twilight of the Gods (2024) {tvdb-404605}/Season 01/Twilight of the Gods (2024) - S01E01 - The Bride-Price [WEBRip-1080p][EAC3 Atmos 5.1][x265]-iVy.mkv" "Twilight of the Gods (2024) - S01E01 - The Bride-Price [WEBRip-1080p][EAC3 Atmos 5.1][x265]-iVy.mkv (score: 3104 vs keeper 3862)"

# Group: Twilight of the Gods (2024) {tvdb-404605}/Season 01/S01E02
# KEEP: Twilight of the Gods (2024) - S01E02 - Heretic Spear [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-BYNDR.mkv (score: 3860)
cleanup_file "/mnt/synology/rs-tv/Twilight of the Gods (2024) {tvdb-404605}/Season 01/Twilight of the Gods (2024) - S01E02 - Heretic Spear [WEBRip-1080p][EAC3 Atmos 5.1][x265]-iVy.mkv" "Twilight of the Gods (2024) - S01E02 - Heretic Spear [WEBRip-1080p][EAC3 Atmos 5.1][x265]-iVy.mkv (score: 3103 vs keeper 3860)"

# Group: Twilight of the Gods (2024) {tvdb-404605}/Season 01/S01E03
# KEEP: Twilight of the Gods (2024) - S01E03 - You Will Gladden His Ravens [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-BYNDR.mkv (score: 3860)
cleanup_file "/mnt/synology/rs-tv/Twilight of the Gods (2024) {tvdb-404605}/Season 01/Twilight of the Gods (2024) - S01E03 - You Will Gladden His Ravens [WEBRip-1080p][EAC3 Atmos 5.1][x265]-iVy.mkv" "Twilight of the Gods (2024) - S01E03 - You Will Gladden His Ravens [WEBRip-1080p][EAC3 Atmos 5.1][x265]-iVy.mkv (score: 3103 vs keeper 3860)"

# Group: Twilight of the Gods (2024) {tvdb-404605}/Season 01/S01E04
# KEEP: Twilight of the Gods (2024) - S01E04 - The Worm [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-BYNDR.mkv (score: 3861)
cleanup_file "/mnt/synology/rs-tv/Twilight of the Gods (2024) {tvdb-404605}/Season 01/Twilight of the Gods (2024) - S01E04 - The Worm [WEBRip-1080p][EAC3 Atmos 5.1][x265]-iVy.mkv" "Twilight of the Gods (2024) - S01E04 - The Worm [WEBRip-1080p][EAC3 Atmos 5.1][x265]-iVy.mkv (score: 3103 vs keeper 3861)"

# Group: Twilight of the Gods (2024) {tvdb-404605}/Season 01/S01E05
# KEEP: Twilight of the Gods (2024) - S01E05 - The Scapegoat God [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-BYNDR.mkv (score: 3861)
cleanup_file "/mnt/synology/rs-tv/Twilight of the Gods (2024) {tvdb-404605}/Season 01/Twilight of the Gods (2024) - S01E05 - The Scapegoat God [WEBRip-1080p][EAC3 Atmos 5.1][x265]-iVy.mkv" "Twilight of the Gods (2024) - S01E05 - The Scapegoat God [WEBRip-1080p][EAC3 Atmos 5.1][x265]-iVy.mkv (score: 3104 vs keeper 3861)"

# Group: Twilight of the Gods (2024) {tvdb-404605}/Season 01/S01E06
# KEEP: Twilight of the Gods (2024) - S01E06 - Now Hear Of… [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-BYNDR.mkv (score: 3861)
cleanup_file "/mnt/synology/rs-tv/Twilight of the Gods (2024) {tvdb-404605}/Season 01/Twilight of the Gods (2024) - S01E06 - Now Hear Of… [WEBRip-1080p][EAC3 Atmos 5.1][x265]-iVy.mkv" "Twilight of the Gods (2024) - S01E06 - Now Hear Of… [WEBRip-1080p][EAC3 Atmos 5.1][x265]-iVy.mkv (score: 3104 vs keeper 3861)"

# Group: Twilight of the Gods (2024) {tvdb-404605}/Season 01/S01E07
# KEEP: Twilight of the Gods (2024) - S01E07 - If I Had a Hammer [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-BYNDR.mkv (score: 3860)
cleanup_file "/mnt/synology/rs-tv/Twilight of the Gods (2024) {tvdb-404605}/Season 01/Twilight of the Gods (2024) - S01E07 - If I Had a Hammer [WEBRip-1080p][EAC3 Atmos 5.1][x265]-iVy.mkv" "Twilight of the Gods (2024) - S01E07 - If I Had a Hammer [WEBRip-1080p][EAC3 Atmos 5.1][x265]-iVy.mkv (score: 3103 vs keeper 3860)"

# Group: Twilight of the Gods (2024) {tvdb-404605}/Season 01/S01E08
# KEEP: Twilight of the Gods (2024) - S01E08 - Song of Sigrid [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-BYNDR.mkv (score: 3866)
cleanup_file "/mnt/synology/rs-tv/Twilight of the Gods (2024) {tvdb-404605}/Season 01/Twilight of the Gods (2024) - S01E08 - Song of Sigrid [WEBRip-1080p][EAC3 Atmos 5.1][x265]-iVy.mkv" "Twilight of the Gods (2024) - S01E08 - Song of Sigrid [WEBRip-1080p][EAC3 Atmos 5.1][x265]-iVy.mkv (score: 3106 vs keeper 3866)"

# Group: UNPARSED:/mnt/synology/rs-tv/Burn Notice (2007) {tvdb-80270}/02
# KEEP: 2009-03-05 - Lesser Evil.mkv (score: 21)
cleanup_file "/mnt/synology/rs-tv/Burn Notice (2007) {tvdb-80270}/02/2008-09-11 - Double Booked.mkv" "2008-09-11 - Double Booked.mkv (score: 21 vs keeper 21)"
cleanup_file "/mnt/synology/rs-tv/Burn Notice (2007) {tvdb-80270}/02/2009-02-26 - Sins of Omission.mkv" "2009-02-26 - Sins of Omission.mkv (score: 21 vs keeper 21)"
cleanup_file "/mnt/synology/rs-tv/Burn Notice (2007) {tvdb-80270}/02/2009-02-12 - Bad Breaks.mkv" "2009-02-12 - Bad Breaks.mkv (score: 21 vs keeper 21)"
cleanup_file "/mnt/synology/rs-tv/Burn Notice (2007) {tvdb-80270}/02/2009-01-22 - Do No Harm.mkv" "2009-01-22 - Do No Harm.mkv (score: 21 vs keeper 21)"
cleanup_file "/mnt/synology/rs-tv/Burn Notice (2007) {tvdb-80270}/02/2009-02-19 - Truth and Reconciliation.mkv" "2009-02-19 - Truth and Reconciliation.mkv (score: 21 vs keeper 21)"
cleanup_file "/mnt/synology/rs-tv/Burn Notice (2007) {tvdb-80270}/02/2008-08-07 - Scatter Point.mkv" "2008-08-07 - Scatter Point.mkv (score: 21 vs keeper 21)"
cleanup_file "/mnt/synology/rs-tv/Burn Notice (2007) {tvdb-80270}/02/2008-08-14 - Bad Blood.mkv" "2008-08-14 - Bad Blood.mkv (score: 21 vs keeper 21)"
cleanup_file "/mnt/synology/rs-tv/Burn Notice (2007) {tvdb-80270}/02/2008-07-24 - Trust Me.mkv" "2008-07-24 - Trust Me.mkv (score: 21 vs keeper 21)"
cleanup_file "/mnt/synology/rs-tv/Burn Notice (2007) {tvdb-80270}/02/2008-09-18 - Good Soldier.mkv" "2008-09-18 - Good Soldier.mkv (score: 21 vs keeper 21)"
cleanup_file "/mnt/synology/rs-tv/Burn Notice (2007) {tvdb-80270}/02/2008-07-31 - Comrades.mkv" "2008-07-31 - Comrades.mkv (score: 21 vs keeper 21)"
cleanup_file "/mnt/synology/rs-tv/Burn Notice (2007) {tvdb-80270}/02/2008-07-17 - Turn and Burn.mkv" "2008-07-17 - Turn and Burn.mkv (score: 21 vs keeper 21)"
cleanup_file "/mnt/synology/rs-tv/Burn Notice (2007) {tvdb-80270}/02/2008-08-21 - Rough Seas.mkv" "2008-08-21 - Rough Seas.mkv (score: 21 vs keeper 21)"
cleanup_file "/mnt/synology/rs-tv/Burn Notice (2007) {tvdb-80270}/02/2009-02-05 - Seek and Destroy.mkv" "2009-02-05 - Seek and Destroy.mkv (score: 21 vs keeper 21)"
cleanup_file "/mnt/synology/rs-tv/Burn Notice (2007) {tvdb-80270}/02/2008-07-10 - Breaking and Entering.mkv" "2008-07-10 - Breaking and Entering.mkv (score: 21 vs keeper 21)"
cleanup_file "/mnt/synology/rs-tv/Burn Notice (2007) {tvdb-80270}/02/2009-01-29 - Hot Spot.mkv" "2009-01-29 - Hot Spot.mkv (score: 21 vs keeper 21)"

# Group: UNPARSED:/mnt/synology/rs-tv/Cunk on Britain (2018) {tvdb-339732}
# KEEP: Cunk on Christmas (2016) {imdb-tt6326816} [WEBDL-1080p][AAC 2.0][h264]-AEK.mkv (score: 3414)
cleanup_file "/mnt/synology/rs-tv/Cunk on Britain (2018) {tvdb-339732}/Cunk on Shakespeare (2016) {imdb-tt5715186} [WEBRip-720p][AAC 2.0][h264]-btw.mkv" "Cunk on Shakespeare (2016) {imdb-tt5715186} [WEBRip-720p][AAC 2.0][h264]-btw.mkv (score: 1004 vs keeper 3414)"

# Group: UNPARSED:/mnt/synology/rs-tv/Days of our Lives - The Digital Series (2019) {tvdb-368783}/01
# KEEP: Doraleous and Associates All Episodes Supercut.mkv (score: 200)
cleanup_file "/mnt/synology/rs-tv/Days of our Lives - The Digital Series (2019) {tvdb-368783}/01/HALO - [Fan Animation] - Remember.mkv" "HALO - [Fan Animation] - Remember.mkv (score: 5 vs keeper 200)"

# Group: UNPARSED:/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}
# KEEP: EP21 - Time Fugitives (Part 2).mkv (score: 18)
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP23 - Beauty & the Beast.mkv" "EP23 - Beauty & the Beast.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP32 - The Phoenix Saga (Part 4) The Starjammers.mkv" "EP32 - The Phoenix Saga (Part 4) The Starjammers.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP03 - Enter Magneto.mkv" "EP03 - Enter Magneto.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP28 - Out of the Past (Part 2).mkv" "EP28 - Out of the Past (Part 2).mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP22 - A Rogue's Tale.mkv" "EP22 - A Rogue's Tale.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP39 - Savage Land, Strange Heart (Part 2).mkv" "EP39 - Savage Land, Strange Heart (Part 2).mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP35 - Obsession.mkv" "EP35 - Obsession.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP18 - Repo Man.mkv" "EP18 - Repo Man.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP30 - The Phoenix Saga (Part 2) The Dark Shroud.mkv" "EP30 - The Phoenix Saga (Part 2) The Dark Shroud.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP37 - Cold Comfort.mkv" "EP37 - Cold Comfort.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP14 - Till Death Do Us Part (Part 1).mkv" "EP14 - Till Death Do Us Part (Part 1).mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP24 - Mojovision.mkv" "EP24 - Mojovision.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP68 - The Phalanx Covenant (Part 2).mkv" "EP68 - The Phalanx Covenant (Part 2).mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP20 - Time Fugitives (Part 1).mkv" "EP20 - Time Fugitives (Part 1).mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP57 - Proteus (Part 2).mkv" "EP57 - Proteus (Part 2).mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP26 - Reunion (Part 2).mkv" "EP26 - Reunion (Part 2).mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP44 - Orphan's End.mkv" "EP44 - Orphan's End.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP60 - Lotus and the Steel.mkv" "EP60 - Lotus and the Steel.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP25 - Reunion (Part 1).mkv" "EP25 - Reunion (Part 1).mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP34 - No Mutant Is an Island.mkv" "EP34 - No Mutant Is an Island.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP29 - The Phoenix Saga (Part 1) Sacrifice.mkv" "EP29 - The Phoenix Saga (Part 1) Sacrifice.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP55 - One Man's Worth (Part 2).mkv" "EP55 - One Man's Worth (Part 2).mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP70 - Storm Front (Part 2).mkv" "EP70 - Storm Front (Part 2).mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP41 - The Dark Phoenix (Part 2) The Inner Circle.mkv" "EP41 - The Dark Phoenix (Part 2) The Inner Circle.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP40 - The Dark Phoenix (Part 1) Dazzled.mkv" "EP40 - The Dark Phoenix (Part 1) Dazzled.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP15 - Till Death Do Us Part (Part 2).mkv" "EP15 - Till Death Do Us Part (Part 2).mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP31 - The Phoenix Saga (Part 3) The Cry of the Banshee.mkv" "EP31 - The Phoenix Saga (Part 3) The Cry of the Banshee.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP56 - Proteus (Part 1).mkv" "EP56 - Proteus (Part 1).mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP49 - Sanctuary (Part 2).mkv" "EP49 - Sanctuary (Part 2).mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP64 - Beyond Good and Evil (Part 2) Promise of Apocalypse.mkv" "EP64 - Beyond Good and Evil (Part 2) Promise of Apocalypse.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP16 - Whatever It Takes.mkv" "EP16 - Whatever It Takes.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP46 - The Juggernaut Returns.mkv" "EP46 - The Juggernaut Returns.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP19 - X-Ternally Yours.mkv" "EP19 - X-Ternally Yours.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP58 - Family Ties.mkv" "EP58 - Family Ties.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP33 - The Phoenix Saga (Part 5) Child of Light.mkv" "EP33 - The Phoenix Saga (Part 5) Child of Light.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP61 - Weapon X, Lies, and Video Tape.mkv" "EP61 - Weapon X, Lies, and Video Tape.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP08 - The Unstoppable Juggernaut.mkv" "EP08 - The Unstoppable Juggernaut.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP17 - Red Dawn.mkv" "EP17 - Red Dawn.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP48 - Sanctuary (Part 1).mkv" "EP48 - Sanctuary (Part 1).mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP06 - Cold Vengeance.mkv" "EP06 - Cold Vengeance.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP53 - Nightcrawler.mkv" "EP53 - Nightcrawler.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP10 - Come the Apocalypse.mkv" "EP10 - Come the Apocalypse.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP12 - Days of Future Past (Part 2).mkv" "EP12 - Days of Future Past (Part 2).mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP51 - Courage.mkv" "EP51 - Courage.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP52 - Secrets, Not Long Buried.mkv" "EP52 - Secrets, Not Long Buried.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP11 - Days of Future Past (Part 1).mkv" "EP11 - Days of Future Past (Part 1).mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP09 - The Cure.mkv" "EP09 - The Cure.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP07 - Slave Island.mkv" "EP07 - Slave Island.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP01 - Night of the Sentinels (Part 1).mkv" "EP01 - Night of the Sentinels (Part 1).mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP27 - Out of the Past (Part 1).mkv" "EP27 - Out of the Past (Part 1).mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP05 - Captive Hearts.mkv" "EP05 - Captive Hearts.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP13 - The Final Decision.mkv" "EP13 - The Final Decision.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP02 - Night of the Sentinels (Part 2).mkv" "EP02 - Night of the Sentinels (Part 2).mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP38 - Savage Land, Strange Heart (Part 1).mkv" "EP38 - Savage Land, Strange Heart (Part 1).mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP04 - Deadly Reunions.mkv" "EP04 - Deadly Reunions.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP43 - The Dark Phoenix (Part 4) The Fate of the Phoenix.mkv" "EP43 - The Dark Phoenix (Part 4) The Fate of the Phoenix.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP47 - A Deal with the Devil.mkv" "EP47 - A Deal with the Devil.mkv (score: 17 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP67 - The Phalanx Covenant (Part 1).mkv" "EP67 - The Phalanx Covenant (Part 1).mkv (score: 17 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP59 - Bloodlines.mkv" "EP59 - Bloodlines.mkv (score: 17 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP63 - Beyond Good and Evil (Part 1) The End of Time.mkv" "EP63 - Beyond Good and Evil (Part 1) The End of Time.mkv (score: 17 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP54 - One Man's Worth (Part 1).mkv" "EP54 - One Man's Worth (Part 1).mkv (score: 17 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP66 - Beyond Good and Evil (Part 4) End and Beginning.mkv" "EP66 - Beyond Good and Evil (Part 4) End and Beginning.mkv (score: 17 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP45 - Love in Vain.mkv" "EP45 - Love in Vain.mkv (score: 17 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP65 - Beyond Good and Evil (Part 3) The Lazarus Chamber.mkv" "EP65 - Beyond Good and Evil (Part 3) The Lazarus Chamber.mkv (score: 17 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP69 - Storm Front (Part 1).mkv" "EP69 - Storm Front (Part 1).mkv (score: 17 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP62 - Have Yourself a Morlock Little X-Mas.mkv" "EP62 - Have Yourself a Morlock Little X-Mas.mkv (score: 17 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP42 - The Dark Phoenix (Part 3) The Dark Phoenix.mkv" "EP42 - The Dark Phoenix (Part 3) The Dark Phoenix.mkv (score: 17 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP74 - Hidden Agendas.mkv" "EP74 - Hidden Agendas.mkv (score: 17 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP75 - Descent.mkv" "EP75 - Descent.mkv (score: 17 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP36 - Longshot.mkv" "EP36 - Longshot.mkv (score: 17 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP76 - Graduation Day.mkv" "EP76 - Graduation Day.mkv (score: 17 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP72 - Jubilee's Fairytale Theatre.mkv" "EP72 - Jubilee's Fairytale Theatre.mkv (score: 17 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP71 - The Fifth Horseman.mkv" "EP71 - The Fifth Horseman.mkv (score: 17 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP73 - Old Soldiers.mkv" "EP73 - Old Soldiers.mkv (score: 17 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/Fraggle Rock - The Animated Series (1987) {tvdb-139151}/EP50 - Xavier Remembers.mkv" "EP50 - Xavier Remembers.mkv (score: 17 vs keeper 18)"

# Group: UNPARSED:/mnt/synology/rs-tv/Minority Report (2015) {tvdb-295680}/01
# KEEP: 2015-11-02 - Honor Among Thieves.mkv (score: 14)
cleanup_file "/mnt/synology/rs-tv/Minority Report (2015) {tvdb-295680}/01/2015-11-30 - Everybody Runs.mkv" "2015-11-30 - Everybody Runs.mkv (score: 14 vs keeper 14)"
cleanup_file "/mnt/synology/rs-tv/Minority Report (2015) {tvdb-295680}/01/2015-11-16 - The American Dream.mkv" "2015-11-16 - The American Dream.mkv (score: 14 vs keeper 14)"
cleanup_file "/mnt/synology/rs-tv/Minority Report (2015) {tvdb-295680}/01/2015-09-28 - Mr. Nice Guy.mkv" "2015-09-28 - Mr. Nice Guy.mkv (score: 14 vs keeper 14)"
cleanup_file "/mnt/synology/rs-tv/Minority Report (2015) {tvdb-295680}/01/2015-09-21 - Pilot.mkv" "2015-09-21 - Pilot.mkv (score: 13 vs keeper 14)"
cleanup_file "/mnt/synology/rs-tv/Minority Report (2015) {tvdb-295680}/01/2015-10-05 - Hawk-Eye.mkv" "2015-10-05 - Hawk-Eye.mkv (score: 13 vs keeper 14)"
cleanup_file "/mnt/synology/rs-tv/Minority Report (2015) {tvdb-295680}/01/2015-11-23 - Memento Mori.mkv" "2015-11-23 - Memento Mori.mkv (score: 12 vs keeper 14)"
cleanup_file "/mnt/synology/rs-tv/Minority Report (2015) {tvdb-295680}/01/2015-10-12 - Fredi.mkv" "2015-10-12 - Fredi.mkv (score: 11 vs keeper 14)"
cleanup_file "/mnt/synology/rs-tv/Minority Report (2015) {tvdb-295680}/01/2015-10-26 - Fiddler's Neck.mkv" "2015-10-26 - Fiddler's Neck.mkv (score: 11 vs keeper 14)"
cleanup_file "/mnt/synology/rs-tv/Minority Report (2015) {tvdb-295680}/01/2015-10-19 - The Present.mkv" "2015-10-19 - The Present.mkv (score: 8 vs keeper 14)"

# Group: UNPARSED:/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 09
# KEEP: 09x17 - Flying Guillotine - HD TV.mkv (score: 18)
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 09/09x18 - Drain Disaster - HD TV.mkv" "09x18 - Drain Disaster - HD TV.mkv (score: 15 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 09/09x15 - Walk a Straight Line - HD TV.mkv" "09x15 - Walk a Straight Line - HD TV.mkv (score: 15 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 09/09x14 - Newton's Crane Cradle - HD TV.mkv" "09x14 - Newton's Crane Cradle - HD TV.mkv (score: 14 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 09/09x21 - Wheel of Mythfortune - HD TV.mkv" "09x21 - Wheel of Mythfortune - HD TV.mkv (score: 14 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 09/09x16 - Duct Tape Plane - HD TV.mkv" "09x16 - Duct Tape Plane - HD TV.mkv (score: 13 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 09/09x19 - Location, Location, Location - HD TV.mkv" "09x19 - Location, Location, Location - HD TV.mkv (score: 12 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 09/09x12 - Paper Armor - HD TV.mkv" "09x12 - Paper Armor - HD TV.mkv (score: 12 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 09/09x20 - Wet and Wild - HD TV.mkv" "09x20 - Wet and Wild - HD TV.mkv (score: 12 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 09/09x13 - Bikes and Bazookas - HD TV.mkv" "09x13 - Bikes and Bazookas - HD TV.mkv (score: 11 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 09/09x01 - Mission Impossible Face Off - HD TV.mkv" "09x01 - Mission Impossible Face Off - HD TV.mkv (score: 10 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 09/09x04 - Bubble Trouble - HD TV.mkv" "09x04 - Bubble Trouble - HD TV.mkv (score: 10 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 09/09x10 - Planes, Trains and Automobiles - HD TV.mkv" "09x10 - Planes, Trains and Automobiles - HD TV.mkv (score: 10 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 09/09x03 - Running on Water - HD TV.mkv" "09x03 - Running on Water - HD TV.mkv (score: 10 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 09/09x06 - Blow Your Own Sail - HD TV.mkv" "09x06 - Blow Your Own Sail - HD TV.mkv (score: 10 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 09/09x05 - Torpedo Tastic - HD TV.mkv" "09x05 - Torpedo Tastic - HD TV.mkv (score: 10 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 09/09x09 - Fixing a Flat - HD TV.mkv" "09x09 - Fixing a Flat - HD TV.mkv (score: 10 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 09/09x07 - Spy Car 2 - HD TV.mkv" "09x07 - Spy Car 2 - HD TV.mkv (score: 10 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 09/09x08 - Dodge a Bullet - HD TV.mkv" "09x08 - Dodge a Bullet - HD TV.mkv (score: 10 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 09/09x02 - Blue Ice - HD TV.mkv" "09x02 - Blue Ice - HD TV.mkv (score: 10 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 09/09x22 - Toilet Bomb - HD TV.mkv" "09x22 - Toilet Bomb - HD TV.mkv (score: 10 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 09/09x11 - Let There Be Light - HD TV.mkv" "09x11 - Let There Be Light - HD TV.mkv (score: 9 vs keeper 18)"

# Group: UNPARSED:/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 10
# KEEP: 10x08 - Bouncing Bullet - 720p WEB-DL.mp4 (score: 1212)
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 10/10x01 - Duct Tape Island - HD TV.mkv" "10x01 - Duct Tape Island - HD TV.mkv (score: 18 vs keeper 1212)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 10/10x04 - Swinging Pirates - HD TV.mkv" "10x04 - Swinging Pirates - HD TV.mkv (score: 15 vs keeper 1212)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 10/10x12 - Hollywood Gunslingers - HD TV.mkv" "10x12 - Hollywood Gunslingers - HD TV.mkv (score: 14 vs keeper 1212)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 10/10x05 - Battle Of The Sexes - HD TV.mkv" "10x05 - Battle Of The Sexes - HD TV.mkv (score: 14 vs keeper 1212)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 10/10x09 - Mailbag Special - HD TV.mkv" "10x09 - Mailbag Special - HD TV.mkv (score: 14 vs keeper 1212)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 10/10x13 - Jawsome Shark Special - HD TV.mkv" "10x13 - Jawsome Shark Special - HD TV.mkv (score: 14 vs keeper 1212)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 10/10x07 - Revenge of the Myth - HD TV.mkv" "10x07 - Revenge of the Myth - HD TV.mkv (score: 13 vs keeper 1212)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 10/10x11 - Duel Dilemmas - HD TV.mkv" "10x11 - Duel Dilemmas - HD TV.mkv (score: 12 vs keeper 1212)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 10/10x10 - Bubble Pack Plunge - HD TV.mkv" "10x10 - Bubble Pack Plunge - HD TV.mkv (score: 12 vs keeper 1212)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 10/10x06 - Mailbag Special - HD TV.mkv" "10x06 - Mailbag Special - HD TV.mkv (score: 12 vs keeper 1212)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 10/10x02 - Fire vs Ice - HD TV.mkv" "10x02 - Fire vs Ice - HD TV.mkv (score: 12 vs keeper 1212)"

# Group: UNPARSED:/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 11
# KEEP: 11x06 - Cannonball Chemistry - HD TV.mkv (score: 15)
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 11/11x02 - Trench Torpedo - HD TV.mkv" "11x02 - Trench Torpedo - HD TV.mkv (score: 13 vs keeper 15)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 11/11x03 - Hail Hijinx - HD TV.mkv" "11x03 - Hail Hijinx - HD TV.mkv (score: 13 vs keeper 15)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 11/11x05 - Mini Myth Medley - HD TV.mkv" "11x05 - Mini Myth Medley - HD TV.mkv (score: 13 vs keeper 15)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 11/11x08 - Explosions A to Z - HD TV.mkv" "11x08 - Explosions A to Z - HD TV.mkv (score: 12 vs keeper 15)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 11/11x07 - Surreal Gourmet Hour - HD TV.mkv" "11x07 - Surreal Gourmet Hour - HD TV.mkv (score: 12 vs keeper 15)"

# Group: UNPARSED:/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 12
# KEEP: 12x10 - Breaking Bad Special - 720p WEB-DL.mkv (score: 1213)
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 12/12x06 - Motorcycle Water Ski - 720p WEB-DL.mkv" "12x06 - Motorcycle Water Ski - 720p WEB-DL.mkv (score: 1213 vs keeper 1213)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 12/12x11 - Zombie Special - 720p WEB-DL.mkv" "12x11 - Zombie Special - 720p WEB-DL.mkv (score: 1213 vs keeper 1213)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 12/12x05 - Battle of the Sexes - Round 2 - 720p WEB-DL.mkv" "12x05 - Battle of the Sexes - Round 2 - 720p WEB-DL.mkv (score: 1213 vs keeper 1213)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 12/12x02 - Deadliest Catch Crabtastic Special - 720p WEB-DL.mkv" "12x02 - Deadliest Catch Crabtastic Special - 720p WEB-DL.mkv (score: 1213 vs keeper 1213)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 12/12x03 - Down and Dirty- Earthquake Survival - 720p WEB-DL.mkv" "12x03 - Down and Dirty- Earthquake Survival - 720p WEB-DL.mkv (score: 1213 vs keeper 1213)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 12/12x07 - Hypermilling-Crash Cushion - 720p WEB-DL.mkv" "12x07 - Hypermilling-Crash Cushion - 720p WEB-DL.mkv (score: 1212 vs keeper 1213)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 12/12x08 - Duct Tape Canyon - HD TV.mkv" "12x08 - Duct Tape Canyon - HD TV.mkv (score: 15 vs keeper 1213)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 12/12x09 - Painting With Explosives, Bifurcated Boat - HD TV.mkv" "12x09 - Painting With Explosives, Bifurcated Boat - HD TV.mkv (score: 12 vs keeper 1213)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 12/12x04 - Indy Car Special - HD TV.mkv" "12x04 - Indy Car Special - HD TV.mkv (score: 12 vs keeper 1213)"

# Group: UNPARSED:/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 13
# KEEP: 13x06 - Mythssion Impossible - HD TV.mkv (score: 15)
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 13/13x03 - Hollywood Car Crash Cliches - HD TV.mkv" "13x03 - Hollywood Car Crash Cliches - HD TV.mkv (score: 14 vs keeper 15)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 13/13x01 - Star Wars  Revenge of the Myth - HD TV.mkv" "13x01 - Star Wars  Revenge of the Myth - HD TV.mkv (score: 14 vs keeper 15)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 13/13x04 - Car Chase Chaos - Animal Antics - HD TV.mkv" "13x04 - Car Chase Chaos - Animal Antics - HD TV.mkv (score: 13 vs keeper 15)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 13/13x07 - Bullet Baloney - HD TV.mkv" "13x07 - Bullet Baloney - HD TV.mkv (score: 13 vs keeper 15)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 13/13x08 - Supersonic Ping Pong-Ice Cannon - HD TV.mkv" "13x08 - Supersonic Ping Pong-Ice Cannon - HD TV.mkv (score: 12 vs keeper 15)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 13/13x02 - Moonshiner Myths - HD TV.mkv" "13x02 - Moonshiner Myths - HD TV.mkv (score: 12 vs keeper 15)"
cleanup_file "/mnt/synology/rs-tv/MythBusters (2003) {tvdb-73388}/Season 13/13x05 - -Do- Try This At Home - HD TV.mkv" "13x05 - -Do- Try This At Home - HD TV.mkv (score: 11 vs keeper 15)"

# Group: UNPARSED:/mnt/synology/rs-tv/Son of Zorn (2016) {tvdb-311817}/01
# KEEP: 2016-12-11 - The War On Grafelnik.mkv (score: 6)
cleanup_file "/mnt/synology/rs-tv/Son of Zorn (2016) {tvdb-311817}/01/2016-10-23 - A Taste of Zephyria.mkv" "2016-10-23 - A Taste of Zephyria.mkv (score: 6 vs keeper 6)"
cleanup_file "/mnt/synology/rs-tv/Son of Zorn (2016) {tvdb-311817}/01/2016-10-02 - The War of the Workplace.mkv" "2016-10-02 - The War of the Workplace.mkv (score: 5 vs keeper 6)"
cleanup_file "/mnt/synology/rs-tv/Son of Zorn (2016) {tvdb-311817}/01/2016-11-06 - A Tale of Two Zorns.mkv" "2016-11-06 - A Tale of Two Zorns.mkv (score: 5 vs keeper 6)"
cleanup_file "/mnt/synology/rs-tv/Son of Zorn (2016) {tvdb-311817}/01/2016-11-13 - The Battle of Thanksgiving.mkv" "2016-11-13 - The Battle of Thanksgiving.mkv (score: 5 vs keeper 6)"
cleanup_file "/mnt/synology/rs-tv/Son of Zorn (2016) {tvdb-311817}/01/2016-12-04 - Return of the Drinking Buddy.mkv" "2016-12-04 - Return of the Drinking Buddy.mkv (score: 5 vs keeper 6)"
cleanup_file "/mnt/synology/rs-tv/Son of Zorn (2016) {tvdb-311817}/01/2016-10-16 - The Weekend Warrior.mkv" "2016-10-16 - The Weekend Warrior.mkv (score: 5 vs keeper 6)"
cleanup_file "/mnt/synology/rs-tv/Son of Zorn (2016) {tvdb-311817}/01/2016-09-25 - Defender of Teen Love.mkv" "2016-09-25 - Defender of Teen Love.mkv (score: 4 vs keeper 6)"

# Group: UNPARSED:/mnt/synology/rs-tv/Teenage Mutant Ninja Turtles (1987) {tvdb-74582}/10
# KEEP: Teenage Mutant Ninja Turtles - 10x10 - Planet of the Turtleoids.mp4 (score: 20)
cleanup_file "/mnt/synology/rs-tv/Teenage Mutant Ninja Turtles (1987) {tvdb-74582}/10/Teenage Mutant Ninja Turtles - 10x09 - Once Upon a Time Machine.mp4" "Teenage Mutant Ninja Turtles - 10x09 - Once Upon a Time Machine.mp4 (score: 9 vs keeper 20)"

# Group: UNPARSED:/mnt/synology/rs-tv/The Real Ghostbusters (1986) {tvdb-71824}/Extras
# KEEP: Real Ghostbusters Bonus-5.mkv (score: 2)
cleanup_file "/mnt/synology/rs-tv/The Real Ghostbusters (1986) {tvdb-71824}/Extras/Real Ghostbusters Bonus-7.mkv" "Real Ghostbusters Bonus-7.mkv (score: 2 vs keeper 2)"
cleanup_file "/mnt/synology/rs-tv/The Real Ghostbusters (1986) {tvdb-71824}/Extras/Real Ghostbusters Bonus-6.mkv" "Real Ghostbusters Bonus-6.mkv (score: 1 vs keeper 2)"
cleanup_file "/mnt/synology/rs-tv/The Real Ghostbusters (1986) {tvdb-71824}/Extras/Real Ghostbusters Bonus-3.mkv" "Real Ghostbusters Bonus-3.mkv (score: 1 vs keeper 2)"
cleanup_file "/mnt/synology/rs-tv/The Real Ghostbusters (1986) {tvdb-71824}/Extras/Real Ghostbusters Bonus-4.mkv" "Real Ghostbusters Bonus-4.mkv (score: 1 vs keeper 2)"
cleanup_file "/mnt/synology/rs-tv/The Real Ghostbusters (1986) {tvdb-71824}/Extras/Real Ghostbusters Bonus-9.mkv" "Real Ghostbusters Bonus-9.mkv (score: 0 vs keeper 2)"
cleanup_file "/mnt/synology/rs-tv/The Real Ghostbusters (1986) {tvdb-71824}/Extras/Real Ghostbusters Bonus-1.mkv" "Real Ghostbusters Bonus-1.mkv (score: 0 vs keeper 2)"
cleanup_file "/mnt/synology/rs-tv/The Real Ghostbusters (1986) {tvdb-71824}/Extras/Real Ghostbusters Bonus-8.mkv" "Real Ghostbusters Bonus-8.mkv (score: 0 vs keeper 2)"
cleanup_file "/mnt/synology/rs-tv/The Real Ghostbusters (1986) {tvdb-71824}/Extras/Real Ghostbusters Bonus-11.mkv" "Real Ghostbusters Bonus-11.mkv (score: 0 vs keeper 2)"
cleanup_file "/mnt/synology/rs-tv/The Real Ghostbusters (1986) {tvdb-71824}/Extras/Real Ghostbusters Bonus-2.mkv" "Real Ghostbusters Bonus-2.mkv (score: 0 vs keeper 2)"
cleanup_file "/mnt/synology/rs-tv/The Real Ghostbusters (1986) {tvdb-71824}/Extras/Real Ghostbusters Bonus-10.mkv" "Real Ghostbusters Bonus-10.mkv (score: 0 vs keeper 2)"

# Group: UNPARSED:/mnt/synology/rs-tv/World War II in Colour (2010) {tvdb-394418}/Season 02
# KEEP: world.war.ii.in.hd.colour.111.1080p.br-ifh.mkv (score: 2043)
cleanup_file "/mnt/synology/rs-tv/World War II in Colour (2010) {tvdb-394418}/Season 02/world.war.ii.in.hd.colour.109.1080p.br-ifh.mkv" "world.war.ii.in.hd.colour.109.1080p.br-ifh.mkv (score: 2043 vs keeper 2043)"
cleanup_file "/mnt/synology/rs-tv/World War II in Colour (2010) {tvdb-394418}/Season 02/world.war.ii.in.hd.colour.112.1080p.br-ifh.mkv" "world.war.ii.in.hd.colour.112.1080p.br-ifh.mkv (score: 2043 vs keeper 2043)"
cleanup_file "/mnt/synology/rs-tv/World War II in Colour (2010) {tvdb-394418}/Season 02/world.war.ii.in.hd.colour.113.1080p.br-ifh.mkv" "world.war.ii.in.hd.colour.113.1080p.br-ifh.mkv (score: 2043 vs keeper 2043)"
cleanup_file "/mnt/synology/rs-tv/World War II in Colour (2010) {tvdb-394418}/Season 02/world.war.ii.in.hd.colour.110.1080p.br-ifh.mkv" "world.war.ii.in.hd.colour.110.1080p.br-ifh.mkv (score: 2043 vs keeper 2043)"

# Group: UNPARSED:/mnt/synology/rs-tv/X-Men - The Animated Series (1992) {tvdb-76115}/00
# KEEP: EP35 - Obsession.mkv (score: 18)
cleanup_file "/mnt/synology/rs-tv/X-Men - The Animated Series (1992) {tvdb-76115}/00/EP37 - Cold Comfort.mkv" "EP37 - Cold Comfort.mkv (score: 18 vs keeper 18)"
cleanup_file "/mnt/synology/rs-tv/X-Men - The Animated Series (1992) {tvdb-76115}/00/EP14 - Till Death Do Us Part (Part 1).mkv" "EP14 - Till Death Do Us Part (Part 1).mkv (score: 18 vs keeper 18)"

# Group: Undone (2019) {tvdb-357756}/Season 01/S01E02
# KEEP: Undone (2019) - S01E02 - The Hospital [WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv (score: 3514)
cleanup_file "/mnt/synology/rs-tv/Undone (2019) {tvdb-357756}/Season 01/Undone (2019) - S01E02 - The Hospital [HDTV-1080p][EAC3 5.1][h264].mkv" "Undone (2019) - S01E02 - The Hospital [HDTV-1080p][EAC3 5.1][h264].mkv (score: 2514 vs keeper 3514)"

# Group: V (1984) {tvdb-76354}/Specials/S00E01
# KEEP: V (1984) - S00E01 - The Original Miniseries 1 [SDTV][AC3 2.0][XviD].avi (score: 106)
cleanup_file "/mnt/synology/rs-tv/V (1984) {tvdb-76354}/Specials/S00E01 - The Original Miniseries (1) SDTV.avi" "S00E01 - The Original Miniseries (1) SDTV.avi (score: 6 vs keeper 106)"

# Group: V (1984) {tvdb-76354}/Specials/S00E02
# KEEP: V (1984) - S00E02 - The Original Miniseries 2 [SDTV][AC3 2.0][XviD].avi (score: 106)
cleanup_file "/mnt/synology/rs-tv/V (1984) {tvdb-76354}/Specials/S00E02 - The Original Miniseries (2) SDTV.avi" "S00E02 - The Original Miniseries (2) SDTV.avi (score: 6 vs keeper 106)"

# Group: V (1984) {tvdb-76354}/Specials/S00E03
# KEEP: V (1984) - S00E03 - The Final Battle 1 [SDTV][AAC 1.0][x264].mp4 (score: 208)
cleanup_file "/mnt/synology/rs-tv/V (1984) {tvdb-76354}/Specials/S00E03 - The Final Battle (1) SDTV.mp4" "S00E03 - The Final Battle (1) SDTV.mp4 (score: 8 vs keeper 208)"

# Group: V (1984) {tvdb-76354}/Specials/S00E04
# KEEP: V (1984) - S00E04 - The Final Battle 2 [SDTV][AC3 1.0][XviD].avi (score: 110)
cleanup_file "/mnt/synology/rs-tv/V (1984) {tvdb-76354}/Specials/S00E04 - The Final Battle (2) SDTV.avi" "S00E04 - The Final Battle (2) SDTV.avi (score: 10 vs keeper 110)"

# Group: V (1984) {tvdb-76354}/Specials/S00E05
# KEEP: V (1984) - S00E05 - The Final Battle 3 [SDTV][AC3 1.0][XviD].avi (score: 110)
cleanup_file "/mnt/synology/rs-tv/V (1984) {tvdb-76354}/Specials/S00E05 - The Final Battle (3) SDTV.avi" "S00E05 - The Final Battle (3) SDTV.avi (score: 10 vs keeper 110)"

# Group: Washington Black (2025) {tvdb-410925}/Season 01/S01E01
# KEEP: Washington Black (2025) - S01E01 - The Flying Man and The Musician [DSNP][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3523)
cleanup_file "/mnt/synology/rs-tv/Washington Black (2025) {tvdb-410925}/Season 01/Washington Black (2025) - S01E01 - The Flying Man and The Musician [WEBDL-720p][EAC3 5.1][h264]-BiOMA.mkv" "Washington Black (2025) - S01E01 - The Flying Man and The Musician [WEBDL-720p][EAC3 5.1][h264]-BiOMA.mkv (score: 1512 vs keeper 3523)"

# Group: Washington Black (2025) {tvdb-410925}/Season 01/S01E02
# KEEP: Washington Black (2025) - S01E02 - Movements of Jah People [DSNP][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3520)
cleanup_file "/mnt/synology/rs-tv/Washington Black (2025) {tvdb-410925}/Season 01/Washington Black (2025) - S01E02 - Movements of Jah People [WEBDL-720p][EAC3 5.1][h264]-BiOMA.mkv" "Washington Black (2025) - S01E02 - Movements of Jah People [WEBDL-720p][EAC3 5.1][h264]-BiOMA.mkv (score: 1510 vs keeper 3520)"

# Group: Washington Black (2025) {tvdb-410925}/Season 01/S01E03
# KEEP: Washington Black (2025) - S01E03 - Of Love and Caribbean Rum [DSNP][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3512)
cleanup_file "/mnt/synology/rs-tv/Washington Black (2025) {tvdb-410925}/Season 01/Washington Black (2025) - S01E03 - Of Love and Caribbean Rum [WEBDL-720p][EAC3 5.1][h264]-BiOMA.mkv" "Washington Black (2025) - S01E03 - Of Love and Caribbean Rum [WEBDL-720p][EAC3 5.1][h264]-BiOMA.mkv (score: 1506 vs keeper 3512)"

# Group: Washington Black (2025) {tvdb-410925}/Season 01/S01E04
# KEEP: Washington Black (2025) - S01E04 - The Souls and Science of Black Folk [DSNP][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3517)
cleanup_file "/mnt/synology/rs-tv/Washington Black (2025) {tvdb-410925}/Season 01/Washington Black (2025) - S01E04 - The Souls and Science of Black Folk [WEBDL-720p][EAC3 5.1][h264]-BiOMA.mkv" "Washington Black (2025) - S01E04 - The Souls and Science of Black Folk [WEBDL-720p][EAC3 5.1][h264]-BiOMA.mkv (score: 1508 vs keeper 3517)"

# Group: Washington Black (2025) {tvdb-410925}/Season 01/S01E05
# KEEP: Washington Black (2025) - S01E05 - St. George and the Dragon [DSNP][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3513)
cleanup_file "/mnt/synology/rs-tv/Washington Black (2025) {tvdb-410925}/Season 01/Washington Black (2025) - S01E05 - St. George and the Dragon [WEBDL-720p][EAC3 5.1][h264]-BiOMA.mkv" "Washington Black (2025) - S01E05 - St. George and the Dragon [WEBDL-720p][EAC3 5.1][h264]-BiOMA.mkv (score: 1506 vs keeper 3513)"

# Group: Washington Black (2025) {tvdb-410925}/Season 01/S01E06
# KEEP: Washington Black (2025) - S01E06 - Selamiut [DSNP][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3517)
cleanup_file "/mnt/synology/rs-tv/Washington Black (2025) {tvdb-410925}/Season 01/Washington Black (2025) - S01E06 - Selamiut [WEBDL-720p][EAC3 5.1][h264]-BiOMA.mkv" "Washington Black (2025) - S01E06 - Selamiut [WEBDL-720p][EAC3 5.1][h264]-BiOMA.mkv (score: 1509 vs keeper 3517)"

# Group: Washington Black (2025) {tvdb-410925}/Season 01/S01E07
# KEEP: Washington Black (2025) - S01E07 - J’ouvert Morning [DSNP][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3516)
cleanup_file "/mnt/synology/rs-tv/Washington Black (2025) {tvdb-410925}/Season 01/Washington Black (2025) - S01E07 - J’ouvert Morning [WEBDL-720p][EAC3 5.1][h264]-BiOMA.mkv" "Washington Black (2025) - S01E07 - J’ouvert Morning [WEBDL-720p][EAC3 5.1][h264]-BiOMA.mkv (score: 1508 vs keeper 3516)"

# Group: Washington Black (2025) {tvdb-410925}/Season 01/S01E08
# KEEP: Washington Black (2025) - S01E08 - If You See My Mama Whisper Her This… [DSNP][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3519)
cleanup_file "/mnt/synology/rs-tv/Washington Black (2025) {tvdb-410925}/Season 01/Washington Black (2025) - S01E08 - If You See My Mama Whisper Her This… [WEBDL-720p][EAC3 5.1][h264]-BiOMA.mkv" "Washington Black (2025) - S01E08 - If You See My Mama Whisper Her This… [WEBDL-720p][EAC3 5.1][h264]-BiOMA.mkv (score: 1510 vs keeper 3519)"

# Group: Whose Line Is It Anyway! (US) (1998) {tvdb-76808}/Season 16/S16E20
# KEEP: Whose Line Is It Anyway! (US) (1998) - S16E20 - Jonathan Mangum 8 [WEBDL-1080p][AAC 2.0][h264]-BAE.mkv (score: 3411)
cleanup_file "/mnt/synology/rs-tv/Whose Line Is It Anyway! (US) (1998) {tvdb-76808}/Season 16/Whose Line Is It Anyway! (US) (1998) - S16E20 - Jonathan Mangum 8 [HDTV-720p][AC3 5.1][h264].ts" "Whose Line Is It Anyway! (US) (1998) - S16E20 - Jonathan Mangum 8 [HDTV-720p][AC3 5.1][h264].ts (score: 462 vs keeper 3411)"

# Group: Will Trent (2023) {tvdb-419879}/Season 02/S02E01
# KEEP: Will Trent (2023) - S02E01 - Me Llamo Will Trent [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3530)
cleanup_file "/mnt/synology/rs-tv/Will Trent (2023) {tvdb-419879}/Season 02/Will Trent (2023) - S02E01 - Me Llamo Will Trent [WEBDL-1080p][EAC3 5.1][h264].mkv" "Will Trent (2023) - S02E01 - Me Llamo Will Trent [WEBDL-1080p][EAC3 5.1][h264].mkv (score: 3518 vs keeper 3530)"

# Group: Will Trent (2023) {tvdb-419879}/Season 02/S02E02
# KEEP: Will Trent (2023) - S02E02 - Its the Work I Signed Up For [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3530)
cleanup_file "/mnt/synology/rs-tv/Will Trent (2023) {tvdb-419879}/Season 02/Will Trent (2023) - S02E02 - Its the Work I Signed Up For [WEBDL-1080p][EAC3 5.1][h264].mkv" "Will Trent (2023) - S02E02 - Its the Work I Signed Up For [WEBDL-1080p][EAC3 5.1][h264].mkv (score: 3518 vs keeper 3530)"

# Group: Will Trent (2023) {tvdb-419879}/Season 02/S02E03
# KEEP: Will Trent (2023) - S02E03 - You Dont Have to Understand [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3530)
cleanup_file "/mnt/synology/rs-tv/Will Trent (2023) {tvdb-419879}/Season 02/Will Trent (2023) - S02E03 - You Dont Have to Understand [WEBDL-1080p][EAC3 5.1][h264].mkv" "Will Trent (2023) - S02E03 - You Dont Have to Understand [WEBDL-1080p][EAC3 5.1][h264].mkv (score: 3518 vs keeper 3530)"

# Group: Will Trent (2023) {tvdb-419879}/Season 02/S02E04
# KEEP: Will Trent (2023) - S02E04 - Its Easier to Handcuff a Human Being [WEBDL-1080p][EAC3 5.1][h264]-ELEANOR.mkv (score: 3534)
cleanup_file "/mnt/synology/rs-tv/Will Trent (2023) {tvdb-419879}/Season 02/Will Trent (2023) - S02E04 - Its Easier to Handcuff a Human Being [WEBDL-1080p][EAC3 5.1][h264].mkv" "Will Trent (2023) - S02E04 - Its Easier to Handcuff a Human Being [WEBDL-1080p][EAC3 5.1][h264].mkv (score: 3534 vs keeper 3534)"

# Group: Will Trent (2023) {tvdb-419879}/Season 02/S02E05
# KEEP: Will Trent (2023) - S02E05 - Capt. Duke Wagners Daughter [WEBDL-1080p][EAC3 5.1][h264].mkv (score: 3530)
cleanup_file "/mnt/synology/rs-tv/Will Trent (2023) {tvdb-419879}/Season 02/Will Trent (2023) - S02E05 - Capt. Duke Wagners Daughter [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv" "Will Trent (2023) - S02E05 - Capt. Duke Wagners Daughter [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3529 vs keeper 3530)"

# Group: Will Trent (2023) {tvdb-419879}/Season 02/S02E06
# KEEP: Will Trent (2023) - S02E06 - We Are Family [WEBDL-1080p][EAC3 5.1][h264].mkv (score: 3531)
cleanup_file "/mnt/synology/rs-tv/Will Trent (2023) {tvdb-419879}/Season 02/Will Trent (2023) - S02E06 - We Are Family [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv" "Will Trent (2023) - S02E06 - We Are Family [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3530 vs keeper 3531)"

# Group: Will Trent (2023) {tvdb-419879}/Season 02/S02E07
# KEEP: Will Trent (2023) - S02E07 - Have You Never Been to a Wedding [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3530)
cleanup_file "/mnt/synology/rs-tv/Will Trent (2023) {tvdb-419879}/Season 02/Will Trent (2023) - S02E07 - Have You Never Been to a Wedding [WEBDL-1080p][EAC3 5.1][h264].mkv" "Will Trent (2023) - S02E07 - Have You Never Been to a Wedding [WEBDL-1080p][EAC3 5.1][h264].mkv (score: 3530 vs keeper 3530)"

# Group: Will Trent (2023) {tvdb-419879}/Season 02/S02E08
# KEEP: Will Trent (2023) - S02E08 - Why Is Jacks Arm Bleeding [WEBDL-1080p][EAC3 5.1][h264].mkv (score: 3530)
cleanup_file "/mnt/synology/rs-tv/Will Trent (2023) {tvdb-419879}/Season 02/Will Trent (2023) - S02E08 - Why Is Jacks Arm Bleeding [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv" "Will Trent (2023) - S02E08 - Why Is Jacks Arm Bleeding [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3529 vs keeper 3530)"

# Group: Will Trent (2023) {tvdb-419879}/Season 02/S02E09
# KEEP: Will Trent (2023) - S02E09 - Residente o Visitante [WEBDL-1080p][EAC3 5.1][h264].mkv (score: 3531)
cleanup_file "/mnt/synology/rs-tv/Will Trent (2023) {tvdb-419879}/Season 02/Will Trent (2023) - S02E09 - Residente o Visitante [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv" "Will Trent (2023) - S02E09 - Residente o Visitante [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3530 vs keeper 3531)"

# Group: Will Trent (2023) {tvdb-419879}/Season 02/S02E10
# KEEP: Will Trent (2023) - S02E10 - Do You See the Vision [WEBDL-1080p][EAC3 5.1][h264].mkv (score: 3533)
cleanup_file "/mnt/synology/rs-tv/Will Trent (2023) {tvdb-419879}/Season 02/Will Trent (2023) - S02E10 - Do You See the Vision [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv" "Will Trent (2023) - S02E10 - Do You See the Vision [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3531 vs keeper 3533)"

# Group: Will Trent (2023) {tvdb-419879}/Season 03/S03E01
# KEEP: Will Trent (2023) - S03E01 - Im a Guest Here 1 [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3531)
cleanup_file "/mnt/synology/rs-tv/Will Trent (2023) {tvdb-419879}/Season 03/Will Trent (2023) - S03E01 - Im a Guest Here 1 [WEBDL-1080p][EAC3 5.1][h264].mkv" "Will Trent (2023) - S03E01 - Im a Guest Here 1 [WEBDL-1080p][EAC3 5.1][h264].mkv (score: 3531 vs keeper 3531)"

# Group: X-Men - The Animated Series (1992) {tvdb-76115}/Season 02/S02E05
# KEEP: X-Men - The Animated Series (1992) - S02E05 - Repo Man [HDTV-1080p][AC3 2.0][h265]-Ternally.mkv (score: 2118)
cleanup_file "/mnt/synology/rs-tv/X-Men - The Animated Series (1992) {tvdb-76115}/Season 02/X-Men - The Animated Series (1992) - S02E05 - Repo Man [HDTV-1080p][AC3 2.0][h265].mkv" "X-Men - The Animated Series (1992) - S02E05 - Repo Man [HDTV-1080p][AC3 2.0][h265].mkv (score: 2118 vs keeper 2118)"

echo ""
echo "========================================"
echo "CLEANUP SUMMARY"
echo "========================================"
echo "Removed: $REMOVED"
echo "Skipped: $SKIPPED"
echo "Failed:  $FAILED"
echo "========================================"
if [ "$DRY_RUN" = "true" ]; then
    echo "This was a DRY RUN - no files were modified"
    echo "Run with DRY_RUN=false to actually cleanup"
fi
