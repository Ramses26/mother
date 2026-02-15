#!/bin/bash
#==============================================================================
# Duplicate Cleanup Script - MOVIES
# Generated: 2026-02-14 17:05:30
# Groups with duplicates: 124
# Files to remove: 124
# Space to reclaim: 1093.42 GB
#
# Usage:
#   DRY_RUN=true ./cleanup_actions_20260214_170530.sh    # Preview (default)
#   DRY_RUN=false ./cleanup_actions_20260214_170530.sh   # Actually cleanup
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

# Group: /mnt/synology/rs-movies/American Psycho (2000)
# KEEP: American Psycho (2000) {tmdb-1359} - {edition-Uncut} [Bluray-1080p][EAC3 Atmos 5.1][DV HDR10][x265]-SQS.mkv (score: 4754)
cleanup_file "/mnt/synology/rs-movies/American Psycho (2000)/American Psycho (2000) {tmdb-1359} - [Bluray-1080p][EAC3 7.1][x264]-c0kE.mkv" "American Psycho (2000) {tmdb-1359} - [Bluray-1080p][EAC3 7.1][x264]-c0kE.mkv (score: 3933 vs keeper 4754)"

# Group: /mnt/synology/rs-movies/Baby Driver (2017)
# KEEP: Baby Driver (2017) {tmdb-339403} - [Bluray-1080p][EAC3 Atmos 5.1][DV HDR10][x265]-SM737.mkv (score: 4756)
cleanup_file "/mnt/synology/rs-movies/Baby Driver (2017)/Baby Driver (2017) {tmdb-339403} - [Bluray-1080p][EAC3 7.1][HDR10][x265]-NCmt.mkv" "Baby Driver (2017) {tmdb-339403} - [Bluray-1080p][EAC3 7.1][HDR10][x265]-NCmt.mkv (score: 4322 vs keeper 4756)"

# Group: /mnt/synology/rs-movies/Big Trouble in Little China (1986)
# KEEP: Big Trouble in Little China (1986) {tmdb-6978} - [Hybrid][Bluray-1080p][EAC3 5.1][x264]-MaG.mkv (score: 3964)
cleanup_file "/mnt/synology/rs-movies/Big Trouble in Little China (1986)/Big Trouble in Little China (1986) {tmdb-6978} - [Bluray-1080p][DTS 5.1][x264].mkv" "Big Trouble in Little China (1986) {tmdb-6978} - [Bluray-1080p][DTS 5.1][x264].mkv (score: 3933 vs keeper 3964)"

# Group: /mnt/synology/rs-movies/Bob Marley One Love (2024)
# KEEP: Bob Marley One Love (2024) {tmdb-802219} - [Bluray-1080p][EAC3 7.1][DV HDR10][x265]-BRUTE.mkv (score: 4428)
cleanup_file "/mnt/synology/rs-movies/Bob Marley One Love (2024)/Bob Marley One Love (2024) {tmdb-802219} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-ETHEL.mkv" "Bob Marley One Love (2024) {tmdb-802219} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-ETHEL.mkv (score: 3704 vs keeper 4428)"

# Group: /mnt/synology/rs-movies/Borderline (2025)
# KEEP: Borderline (2025) {tmdb-1013482} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv (score: 3870)
cleanup_file "/mnt/synology/rs-movies/Borderline (2025)/Borderline (2025) {tmdb-1013482} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv" "Borderline (2025) {tmdb-1013482} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv (score: 3362 vs keeper 3870)"

# Group: /mnt/synology/rs-movies/Breakwater (2023)
# KEEP: Breakwater (2023) {tmdb-1006228} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv (score: 3872)
cleanup_file "/mnt/synology/rs-movies/Breakwater (2023)/Breakwater (2023) {tmdb-1006228} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv" "Breakwater (2023) {tmdb-1006228} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3365 vs keeper 3872)"

# Group: /mnt/synology/rs-movies/Bring It On (2000)
# KEEP: Bring It On (2000) {tmdb-1588} - [Bluray-1080p][EAC3 5.1][DV HDR10][x265]-SM737.mkv (score: 4404)
cleanup_file "/mnt/synology/rs-movies/Bring It On (2000)/Bring It On (2000) {tmdb-1588} - [Bluray-1080p][DTS 5.1][x264]-ero.mkv" "Bring It On (2000) {tmdb-1588} - [Bluray-1080p][DTS 5.1][x264]-ero.mkv (score: 3995 vs keeper 4404)"

# Group: /mnt/synology/rs-movies/Champions (2023)
# KEEP: Champions (2023) {tmdb-933419} - [Bluray-1080p][EAC3 5.1][x264]-HiDt.mkv (score: 3923)
cleanup_file "/mnt/synology/rs-movies/Champions (2023)/Champions (2023) {tmdb-933419} - [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv" "Champions (2023) {tmdb-933419} - [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv (score: 3725 vs keeper 3923)"

# Group: /mnt/synology/rs-movies/Childs Play 2 (1990)
# KEEP: Childs Play 2 (1990) {tmdb-11186} - [Bluray-1080p][EAC3 Atmos 7.1][DV HDR10][x265]-NTb.mkv (score: 4824)
cleanup_file "/mnt/synology/rs-movies/Childs Play 2 (1990)/Childs Play 2 (1990) {tmdb-11186} - [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv" "Childs Play 2 (1990) {tmdb-11186} - [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv (score: 3924 vs keeper 4824)"

# Group: /mnt/synology/rs-movies/City of God (2002)
# KEEP: City of God (2002) {tmdb-598} - [Bluray-1080p][EAC3 5.1][x264]-PTer.mkv (score: 4000)
cleanup_file "/mnt/synology/rs-movies/City of God (2002)/City of God (2002) {tmdb-598} - [Bluray-1080p][DTS 5.1][x264]-HDC.mkv" "City of God (2002) {tmdb-598} - [Bluray-1080p][DTS 5.1][x264]-HDC.mkv (score: 3956 vs keeper 4000)"

# Group: /mnt/synology/rs-movies/Cool Hand Luke (1967)
# KEEP: Cool Hand Luke (1967) {tmdb-903} - [Bluray-1080p][FLAC 2.0][HDR10][x265]-DON.mkv (score: 4200)
cleanup_file "/mnt/synology/rs-movies/Cool Hand Luke (1967)/Cool Hand Luke (1967) {tmdb-903} - [Bluray-1080p][AC3 1.0][x264]-ESiR.mkv" "Cool Hand Luke (1967) {tmdb-903} - [Bluray-1080p][AC3 1.0][x264]-ESiR.mkv (score: 3829 vs keeper 4200)"

# Group: /mnt/synology/rs-movies/Corpse Bride (2005)
# KEEP: Corpse Bride (2005) {tmdb-3933} - [Hybrid][Bluray-1080p][EAC3 Atmos 5.1][DV HDR10][x265]-HiDt.mkv (score: 4815)
cleanup_file "/mnt/synology/rs-movies/Corpse Bride (2005)/Corpse Bride (2005) {tmdb-3933} - [Remux-1080p][DTS-HD MA 5.1][VC1].mkv" "Corpse Bride (2005) {tmdb-3933} - [Remux-1080p][DTS-HD MA 5.1][VC1].mkv (score: 4521 vs keeper 4815)"

# Group: /mnt/synology/rs-movies/DC League of Super-Pets (2022)
# KEEP: DC League of Super-Pets (2022) {tmdb-539681} - [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv (score: 3930)
cleanup_file "/mnt/synology/rs-movies/DC League of Super-Pets (2022)/DC League of Super-Pets (2022) {tmdb-539681} - [HMAX][WEBDL-1080p][AC3 5.1][x264]-DKV.mkv" "DC League of Super-Pets (2022) {tmdb-539681} - [HMAX][WEBDL-1080p][AC3 5.1][x264]-DKV.mkv (score: 3327 vs keeper 3930)"

# Group: /mnt/synology/rs-movies/Daddys Head (2024)
# KEEP: Daddys Head (2024) {tmdb-1089123} - [Bluray-1080p][DTS-HD MA 5.1][x264]-GUACAMOLE.mkv (score: 4118)
cleanup_file "/mnt/synology/rs-movies/Daddys Head (2024)/Daddys Head (2024) {tmdb-1089123} - [WEBDL-1080p][EAC3 5.1][h264]-SoundsDirty.mkv" "Daddys Head (2024) {tmdb-1089123} - [WEBDL-1080p][EAC3 5.1][h264]-SoundsDirty.mkv (score: 3332 vs keeper 4118)"

# Group: /mnt/synology/rs-movies/Dampyr (2022)
# KEEP: Dampyr (2022) {tmdb-644124} - [Bluray-1080p][EAC3 5.1][x264]-PSTX.mkv (score: 3885)
cleanup_file "/mnt/synology/rs-movies/Dampyr (2022)/Dampyr (2022) {tmdb-644124} - [MA][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv" "Dampyr (2022) {tmdb-644124} - [MA][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv (score: 3363 vs keeper 3885)"

# Group: /mnt/synology/rs-movies/Dave Chappelle Deep in the Heart of Texas (2017)
# KEEP: Dave Chappelle Deep in the Heart of Texas (2017) {tmdb-444706} - [NF][WEBDL-1080p][EAC3 5.1][x264]-Kitsune.mkv (score: 3326)
cleanup_file "/mnt/synology/rs-movies/Dave Chappelle Deep in the Heart of Texas (2017)/Dave Chappelle Deep in the Heart of Texas (2017) {tmdb-444706} - [NF][WEBRip-1080p][AC3 5.1][x264]-TrollHD.mkv" "Dave Chappelle Deep in the Heart of Texas (2017) {tmdb-444706} - [NF][WEBRip-1080p][AC3 5.1][x264]-TrollHD.mkv (score: 3083 vs keeper 3326)"

# Group: /mnt/synology/rs-movies/Dave Chappelle The Age of Spin (2017)
# KEEP: Dave Chappelle The Age of Spin (2017) {tmdb-444705} - [NF][WEBDL-1080p][EAC3 5.1][x264]-Kitsune.mkv (score: 3326)
cleanup_file "/mnt/synology/rs-movies/Dave Chappelle The Age of Spin (2017)/Dave Chappelle The Age of Spin (2017) {tmdb-444705} - [NF][WEBRip-1080p][AC3 5.1][x264]-TrollHD.mkv" "Dave Chappelle The Age of Spin (2017) {tmdb-444705} - [NF][WEBRip-1080p][AC3 5.1][x264]-TrollHD.mkv (score: 3117 vs keeper 3326)"

# Group: /mnt/synology/rs-movies/Deep Blue Sea (1999)
# KEEP: Deep Blue Sea (1999) {tmdb-8914} - [Bluray-1080p][EAC3 Atmos 7.1][DV HDR10][x265]-BRUTE.mkv (score: 4900)
cleanup_file "/mnt/synology/rs-movies/Deep Blue Sea (1999)/Deep Blue Sea (1999) {tmdb-8914} - [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv" "Deep Blue Sea (1999) {tmdb-8914} - [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv (score: 3950 vs keeper 4900)"

# Group: /mnt/synology/rs-movies/Delicatessen (1991)
# KEEP: Delicatessen (1991) {tmdb-892} - [Bluray-1080p][EAC3 5.1][DV HDR10][x265]-W4NK3R.mkv (score: 4457)
cleanup_file "/mnt/synology/rs-movies/Delicatessen (1991)/Delicatessen (1991) {tmdb-892} - [Bluray-1080p][FLAC 2.0][x264]-Skazhutin.mkv" "Delicatessen (1991) {tmdb-892} - [Bluray-1080p][FLAC 2.0][x264]-Skazhutin.mkv (score: 3771 vs keeper 4457)"

# Group: /mnt/synology/rs-movies/Dont Look Up (2021)
# KEEP: Dont Look Up (2021) {tmdb-646380} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][HDR10][h265]-TEPES.mkv (score: 4062)
cleanup_file "/mnt/synology/rs-movies/Dont Look Up (2021)/Dont Look Up (2021) {tmdb-646380} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-EVO.mkv" "Dont Look Up (2021) {tmdb-646380} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-EVO.mkv (score: 3726 vs keeper 4062)"

# Group: /mnt/synology/rs-movies/Dr. No (1962)
# KEEP: Dr. No (1962) {tmdb-646} - [Bluray-1080p][EAC3 Atmos 5.1][DV HDR10][x265]-HiDt.mkv (score: 4900)
cleanup_file "/mnt/synology/rs-movies/Dr. No (1962)/Dr. No (1962) {tmdb-646} - [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv" "Dr. No (1962) {tmdb-646} - [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv (score: 3988 vs keeper 4900)"

# Group: /mnt/synology/rs-movies/Enders Game (2013)
# KEEP: Enders Game (2013) {tmdb-80274} - [Bluray-1080p Proper][EAC3 Atmos 5.1][HDR10][x265]-SM737.mkv (score: 4564)
cleanup_file "/mnt/synology/rs-movies/Enders Game (2013)/Enders Game (2013) {tmdb-80274} - [Bluray-1080p Proper][DTS 5.1][x264]-DON.mkv" "Enders Game (2013) {tmdb-80274} - [Bluray-1080p Proper][DTS 5.1][x264]-DON.mkv (score: 4028 vs keeper 4564)"

# Group: /mnt/synology/rs-movies/Freakier Friday (2025)
# KEEP: Freakier Friday (2025) {tmdb-1125257} - [Bluray-1080p][DTS-HD MA 7.1][x264]-VoV.mkv (score: 4223)
cleanup_file "/mnt/synology/rs-movies/Freakier Friday (2025)/Freakier Friday (2025) {tmdb-1125257} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-ETHEL.mkv" "Freakier Friday (2025) {tmdb-1125257} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-ETHEL.mkv (score: 3731 vs keeper 4223)"

# Group: /mnt/synology/rs-movies/Friendship (2025)
# KEEP: Friendship (2025) {tmdb-1239655} - [Bluray-1080p][EAC3 5.1][x264]-ATELiER.mkv (score: 3950)
cleanup_file "/mnt/synology/rs-movies/Friendship (2025)/Friendship (2025) {tmdb-1239655} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv" "Friendship (2025) {tmdb-1239655} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv (score: 3370 vs keeper 3950)"

# Group: /mnt/synology/rs-movies/Godfrey Regular Black (2016)
# KEEP: Godfrey Regular Black (2016) {tmdb-415730} - [AMZN][WEBDL-1080p][EAC3 2.0][x264]-monkee.mkv (score: 3336)
cleanup_file "/mnt/synology/rs-movies/Godfrey Regular Black (2016)/Godfrey Regular Black (2016) {tmdb-415730} - [Hulu][WEBDL-720p][AAC 2.0][h264]-monkee.mkv" "Godfrey Regular Black (2016) {tmdb-415730} - [Hulu][WEBDL-720p][AAC 2.0][h264]-monkee.mkv (score: 1209 vs keeper 3336)"

# Group: /mnt/synology/rs-movies/Gone Baby Gone (2007)
# KEEP: Gone Baby Gone (2007) {tmdb-4771} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv (score: 3951)
cleanup_file "/mnt/synology/rs-movies/Gone Baby Gone (2007)/Gone Baby Gone (2007) {tmdb-4771} - [Bluray-1080p][EAC3 5.1][x264]-honeyvera.mkv" "Gone Baby Gone (2007) {tmdb-4771} - [Bluray-1080p][EAC3 5.1][x264]-honeyvera.mkv (score: 3917 vs keeper 3951)"

# Group: /mnt/synology/rs-movies/Good Burger 2 (2023)
# KEEP: Good Burger 2 (2023) {tmdb-1101582} - [Bluray-1080p][DTS 5.1][x264]-fl00f.mkv (score: 3941)
cleanup_file "/mnt/synology/rs-movies/Good Burger 2 (2023)/Good Burger 2 (2023) {tmdb-1101582} - [Bluray-1080p][AC3 5.1][x264]-ArMor.mkv" "Good Burger 2 (2023) {tmdb-1101582} - [Bluray-1080p][AC3 5.1][x264]-ArMor.mkv (score: 3802 vs keeper 3941)"

# Group: /mnt/synology/rs-movies/Handling the Undead (2024)
# KEEP: Handling the Undead (2024) {tmdb-1020896} - [Bluray-1080p][EAC3 5.1][x264]-SbR.mkv (score: 3908)
cleanup_file "/mnt/synology/rs-movies/Handling the Undead (2024)/Handling the Undead (2024) {tmdb-1020896} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv" "Handling the Undead (2024) {tmdb-1020896} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3367 vs keeper 3908)"

# Group: /mnt/synology/rs-movies/Home Alone 2 Lost in New York (1992)
# KEEP: Home Alone 2 Lost in New York (1992) {tmdb-772} - [Bluray-1080p][DTS-HD MA 5.1][x264]-MgB.mkv (score: 4184)
cleanup_file "/mnt/synology/rs-movies/Home Alone 2 Lost in New York (1992)/Home Alone 2 Lost in New York (1992) {tmdb-772} - [Bluray-1080p][AC3 5.1][x265].mkv" "Home Alone 2 Lost in New York (1992) {tmdb-772} - [Bluray-1080p][AC3 5.1][x265].mkv (score: 3440 vs keeper 4184)"

# Group: /mnt/synology/rs-movies/Hustlers (2019)
# KEEP: Hustlers (2019) {tmdb-540901} - [Bluray-1080p][EAC3 7.1][x264]-LoRD.mkv (score: 3932)
cleanup_file "/mnt/synology/rs-movies/Hustlers (2019)/Hustlers (2019) {tmdb-540901} - [Bluray-1080p][AC3 5.1][x264]-AAA.mkv" "Hustlers (2019) {tmdb-540901} - [Bluray-1080p][AC3 5.1][x264]-AAA.mkv (score: 3826 vs keeper 3932)"

# Group: /mnt/synology/rs-movies/In a Valley of Violence (2016)
# KEEP: In a Valley of Violence (2016) {tmdb-291356} - [Bluray-1080p][DTS-HD MA 5.1][x264]-iFT.mkv (score: 4180)
cleanup_file "/mnt/synology/rs-movies/In a Valley of Violence (2016)/In a Valley of Violence (2016) {tmdb-291356} - [Bluray-1080p][DTS 5.1][x264].mkv" "In a Valley of Violence (2016) {tmdb-291356} - [Bluray-1080p][DTS 5.1][x264].mkv (score: 3980 vs keeper 4180)"

# Group: /mnt/synology/rs-movies/Incendies (2010)
# KEEP: Incendies (2010) {tmdb-46738} - [Bluray-1080p][EAC3 5.1][DV HDR10][x265]-PTer.mkv (score: 4501)
cleanup_file "/mnt/synology/rs-movies/Incendies (2010)/Incendies (2010) {tmdb-46738} - [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv" "Incendies (2010) {tmdb-46738} - [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv (score: 4048 vs keeper 4501)"

# Group: /mnt/synology/rs-movies/Incredibles 2 (2018)
# KEEP: Incredibles 2 (2018) {tmdb-260513} - [Bluray-1080p][EAC3 7.1][x264]-NCmt.mkv (score: 3925)
cleanup_file "/mnt/synology/rs-movies/Incredibles 2 (2018)/Incredibles 2 (2018) {tmdb-260513} - [Bluray-1080p][DTS 5.1][x264].mkv" "Incredibles 2 (2018) {tmdb-260513} - [Bluray-1080p][DTS 5.1][x264].mkv (score: 3904 vs keeper 3925)"

# Group: /mnt/synology/rs-movies/Indiana Jones and the Temple of Doom (1984)
# KEEP: Indiana Jones and the Temple of Doom (1984) {tmdb-87} - [Bluray-1080p][EAC3 7.1][DV HDR10][x265]-DON.mkv (score: 4550)
cleanup_file "/mnt/synology/rs-movies/Indiana Jones and the Temple of Doom (1984)/Indiana Jones and the Temple of Doom (1984) {tmdb-87} - [Bluray-1080p][DTS 5.1][x264].mkv" "Indiana Jones and the Temple of Doom (1984) {tmdb-87} - [Bluray-1080p][DTS 5.1][x264].mkv (score: 3937 vs keeper 4550)"

# Group: /mnt/synology/rs-movies/Jay Kelly (2025)
# KEEP: Jay Kelly (2025) {tmdb-1069905} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv (score: 3702)
cleanup_file "/mnt/synology/rs-movies/Jay Kelly (2025)/Jay Kelly (2025) {tmdb-1069905} - [NF][WEBDL-720p][EAC3 Atmos 5.1][x264]-NoRBiT.mkv" "Jay Kelly (2025) {tmdb-1069905} - [NF][WEBDL-720p][EAC3 Atmos 5.1][x264]-NoRBiT.mkv (score: 1680 vs keeper 3702)"

# Group: /mnt/synology/rs-movies/Jimmy Carr Funny Business (2016)
# KEEP: Jimmy Carr Funny Business (2016) {tmdb-387054} - [NF][WEBDL-1080p][EAC3 5.1][x264]-12GaugeShotgun.mkv (score: 3333)
cleanup_file "/mnt/synology/rs-movies/Jimmy Carr Funny Business (2016)/Jimmy Carr Funny Business (2016) {tmdb-387054} - [WEBRip-1080p][AC3 5.1][x264]-RARBG.mkv" "Jimmy Carr Funny Business (2016) {tmdb-387054} - [WEBRip-1080p][AC3 5.1][x264]-RARBG.mkv (score: 3099 vs keeper 3333)"

# Group: /mnt/synology/rs-movies/Judas and the Black Messiah (2021)
# KEEP: Judas and the Black Messiah (2021) {tmdb-583406} - [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv (score: 3932)
cleanup_file "/mnt/synology/rs-movies/Judas and the Black Messiah (2021)/Judas and the Black Messiah (2021) {tmdb-583406} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-naisu.mkv" "Judas and the Black Messiah (2021) {tmdb-583406} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-naisu.mkv (score: 3667 vs keeper 3932)"

# Group: /mnt/synology/rs-movies/Kinds of Kindness (2024)
# KEEP: Kinds of Kindness (2024) {tmdb-1029955} - [Bluray-1080p][EAC3 5.1][x264]-HiP.mkv (score: 4000)
cleanup_file "/mnt/synology/rs-movies/Kinds of Kindness (2024)/Kinds of Kindness (2024) {tmdb-1029955} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv" "Kinds of Kindness (2024) {tmdb-1029955} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv (score: 3735 vs keeper 4000)"

# Group: /mnt/synology/rs-movies/King Arthur (2004)
# KEEP: King Arthur (2004) {tmdb-9477} - {edition-Director's Cut} [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv (score: 4015)
cleanup_file "/mnt/synology/rs-movies/King Arthur (2004)/King Arthur (2004) {tmdb-9477} - [Bluray-1080p][DTS 5.1][x264].mkv" "King Arthur (2004) {tmdb-9477} - [Bluray-1080p][DTS 5.1][x264].mkv (score: 3973 vs keeper 4015)"

# Group: /mnt/synology/rs-movies/Kraven the Hunter (2024)
# KEEP: Kraven the Hunter (2024) {tmdb-539972} - [Bluray-1080p][TrueHD Atmos 7.1][x264]-PirateM.mkv (score: 4242)
cleanup_file "/mnt/synology/rs-movies/Kraven the Hunter (2024)/Kraven the Hunter (2024) {tmdb-539972} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-APEX.mkv" "Kraven the Hunter (2024) {tmdb-539972} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-APEX.mkv (score: 3372 vs keeper 4242)"

# Group: /mnt/synology/rs-movies/L.A. Confidential (1997)
# KEEP: L.A. Confidential (1997) {tmdb-2118} - [Bluray-1080p][EAC3 5.1][x264]-c0kE.mkv (score: 3971)
cleanup_file "/mnt/synology/rs-movies/L.A. Confidential (1997)/L.A. Confidential (1997) {tmdb-2118} - [Bluray-1080p][AC3 5.1][x264].mkv" "L.A. Confidential (1997) {tmdb-2118} - [Bluray-1080p][AC3 5.1][x264].mkv (score: 3880 vs keeper 3971)"

# Group: /mnt/synology/rs-movies/La La Land (2016)
# KEEP: La La Land (2016) {tmdb-313369} - [Bluray-1080p][EAC3 Atmos 7.1][HDR10][x265]-NCmt.mkv (score: 4666)
cleanup_file "/mnt/synology/rs-movies/La La Land (2016)/La La Land (2016) {tmdb-313369} - [Bluray-1080p][AC3 5.1][x264]-LoRD.mkv" "La La Land (2016) {tmdb-313369} - [Bluray-1080p][AC3 5.1][x264]-LoRD.mkv (score: 3900 vs keeper 4666)"

# Group: /mnt/synology/rs-movies/Lady and the Tramp II Scamps Adventure (2001)
# KEEP: Lady and the Tramp II Scamps Adventure (2001) {tmdb-18269} - [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv (score: 3903)
cleanup_file "/mnt/synology/rs-movies/Lady and the Tramp II Scamps Adventure (2001)/Lady and the Tramp II Scamps Adventure (2001) {tmdb-18269} - [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv" "Lady and the Tramp II Scamps Adventure (2001) {tmdb-18269} - [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv (score: 3900 vs keeper 3903)"

# Group: /mnt/synology/rs-movies/Land of Bad (2024)
# KEEP: Land of Bad (2024) {tmdb-969492} - [Hybrid][Bluray-1080p][EAC3 5.1][DV HDR10Plus][x265]-HiDt.mkv (score: 4516)
cleanup_file "/mnt/synology/rs-movies/Land of Bad (2024)/Land of Bad (2024) {tmdb-969492} - [WEBDL-1080p Proper][EAC3 5.1][h264]-RABBITS.mkv" "Land of Bad (2024) {tmdb-969492} - [WEBDL-1080p Proper][EAC3 5.1][h264]-RABBITS.mkv (score: 3374 vs keeper 4516)"

# Group: /mnt/synology/rs-movies/Last Breath (2025)
# KEEP: Last Breath (2025) {tmdb-972533} - [Bluray-1080p][TrueHD 5.1][x264]-KNiVES.mkv (score: 4250)
cleanup_file "/mnt/synology/rs-movies/Last Breath (2025)/Last Breath (2025) {tmdb-972533} - [MA][WEBDL-1080p Proper][EAC3 Atmos 5.1][x264]-BYNDR.mkv" "Last Breath (2025) {tmdb-972533} - [MA][WEBDL-1080p Proper][EAC3 Atmos 5.1][x264]-BYNDR.mkv (score: 3705 vs keeper 4250)"

# Group: /mnt/synology/rs-movies/Little Dixie (2023)
# KEEP: Little Dixie (2023) {tmdb-1058949} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3370)
cleanup_file "/mnt/synology/rs-movies/Little Dixie (2023)/Little Dixie (2023) {tmdb-1058949} - [WEBRip-1080p][AAC 5.1][x264]-AOC.mkv" "Little Dixie (2023) {tmdb-1058949} - [WEBRip-1080p][AAC 5.1][x264]-AOC.mkv (score: 3022 vs keeper 3370)"

# Group: /mnt/synology/rs-movies/Live and Let Die (1973)
# KEEP: Live and Let Die (1973) {tmdb-253} - [Bluray-1080p][DTS 5.1][x264]-NTb.mkv (score: 4005)
cleanup_file "/mnt/synology/rs-movies/Live and Let Die (1973)/Live and Let Die (1973) {tmdb-253} - [Bluray-1080p][AC3 5.1][x265].mkv" "Live and Let Die (1973) {tmdb-253} - [Bluray-1080p][AC3 5.1][x265].mkv (score: 3439 vs keeper 4005)"

# Group: /mnt/synology/rs-movies/Luckiest Girl Alive (2022)
# KEEP: Luckiest Girl Alive (2022) {tmdb-799546} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][DV][HEVC]-FLUX.mkv (score: 4175)
cleanup_file "/mnt/synology/rs-movies/Luckiest Girl Alive (2022)/Luckiest Girl Alive (2022) {tmdb-799546} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv" "Luckiest Girl Alive (2022) {tmdb-799546} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv (score: 3701 vs keeper 4175)"

# Group: /mnt/synology/rs-movies/MLK FBI (2020)
# KEEP: MLK FBI (2020) {tmdb-728868} - [Bluray-1080p][DTS-HD MA 5.1][x264]-SCARE.mkv (score: 4179)
cleanup_file "/mnt/synology/rs-movies/MLK FBI (2020)/MLK FBI (2020) {tmdb-728868} - [WEBDL-1080p][EAC3 5.1][h264]-ISA.mkv" "MLK FBI (2020) {tmdb-728868} - [WEBDL-1080p][EAC3 5.1][h264]-ISA.mkv (score: 3369 vs keeper 4179)"

# Group: /mnt/synology/rs-movies/Madagascar 3 Europes Most Wanted (2012)
# KEEP: Madagascar 3 Europes Most Wanted (2012) {tmdb-80321} - [Bluray-1080p][AC3 5.1][x264]-EbP.mkv (score: 3836)
cleanup_file "/mnt/synology/rs-movies/Madagascar 3 Europes Most Wanted (2012)/Madagascar 3 Europes Most Wanted (2012) {tmdb-80321} - [WEBDL-1080p][AC3 5.1][h264]-CiNEMiX.mkv" "Madagascar 3 Europes Most Wanted (2012) {tmdb-80321} - [WEBDL-1080p][AC3 5.1][h264]-CiNEMiX.mkv (score: 3292 vs keeper 3836)"

# Group: /mnt/synology/rs-movies/Maestro (2023)
# KEEP: Maestro (2023) {tmdb-523607} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][DV][h265]-Kitsune.mkv (score: 4186)
cleanup_file "/mnt/synology/rs-movies/Maestro (2023)/Maestro (2023) {tmdb-523607} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-playWEB.mkv" "Maestro (2023) {tmdb-523607} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-playWEB.mkv (score: 3726 vs keeper 4186)"

# Group: /mnt/synology/rs-movies/Meet Dave (2008)
# KEEP: Meet Dave (2008) {tmdb-11260} - [Bluray-1080p][DTS-HD MA 5.1][h264]-PRiSTiNE.mkv (score: 4250)
cleanup_file "/mnt/synology/rs-movies/Meet Dave (2008)/Meet Dave (2008) {tmdb-11260} - [Bluray-1080p][EAC3 7.1][x264]-NZT.mkv" "Meet Dave (2008) {tmdb-11260} - [Bluray-1080p][EAC3 7.1][x264]-NZT.mkv (score: 3930 vs keeper 4250)"

# Group: /mnt/synology/rs-movies/Midnight Cowboy (1969)
# KEEP: Midnight Cowboy (1969) {tmdb-3116} - [Bluray-1080p][DTS-HD MA 5.1][x264]-Grym.MKV (score: 4195)
cleanup_file "/mnt/synology/rs-movies/Midnight Cowboy (1969)/Midnight Cowboy (1969) {tmdb-3116} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv" "Midnight Cowboy (1969) {tmdb-3116} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv (score: 3983 vs keeper 4195)"

# Group: /mnt/synology/rs-movies/Mission Impossible II (2000)
# KEEP: Mission Impossible II (2000) {tmdb-955} - [Bluray-1080p][EAC3 5.1][HDR10][x265]-NCmt.mkv (score: 4350)
cleanup_file "/mnt/synology/rs-movies/Mission Impossible II (2000)/Mission Impossible II (2000) {tmdb-955} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv" "Mission Impossible II (2000) {tmdb-955} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv (score: 3909 vs keeper 4350)"

# Group: /mnt/synology/rs-movies/Monster Island (2017)
# KEEP: Monster Island (2017) {tmdb-420279} - [Bluray-1080p][DTS 5.1][x264]-GUACAMOLE.mkv (score: 3915)
cleanup_file "/mnt/synology/rs-movies/Monster Island (2017)/Monster Island (2017) {tmdb-420279} - [WEBDL-1080p][AC3 5.1][x264]-strife.mkv" "Monster Island (2017) {tmdb-420279} - [WEBDL-1080p][AC3 5.1][x264]-strife.mkv (score: 3282 vs keeper 3915)"

# Group: /mnt/synology/rs-movies/Monsters Ball (2001)
# KEEP: Monsters Ball (2001) {tmdb-1365} - [Bluray-1080p][DTS 5.1][x264]-MCR.mkv (score: 3937)
cleanup_file "/mnt/synology/rs-movies/Monsters Ball (2001)/Monsters Ball (2001) {tmdb-1365} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "Monsters Ball (2001) {tmdb-1365} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4 (score: 3817 vs keeper 3937)"

# Group: /mnt/synology/rs-movies/Noah (2014)
# KEEP: Noah (2014) {tmdb-86834} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv (score: 4015)
cleanup_file "/mnt/synology/rs-movies/Noah (2014)/Noah (2014) {tmdb-86834} - [Bluray-1080p][AC3 5.1][x264].mkv" "Noah (2014) {tmdb-86834} - [Bluray-1080p][AC3 5.1][x264].mkv (score: 3848 vs keeper 4015)"

# Group: /mnt/synology/rs-movies/Nosferatu (2024)
# KEEP: Nosferatu (2024) {tmdb-426063} - {edition-Extended} [Bluray-1080p][TrueHD Atmos 7.1][x264]-KNiVES.mkv (score: 4298)
cleanup_file "/mnt/synology/rs-movies/Nosferatu (2024)/Nosferatu (2024) {tmdb-426063} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-APEX.mkv" "Nosferatu (2024) {tmdb-426063} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-APEX.mkv (score: 3387 vs keeper 4298)"

# Group: /mnt/synology/rs-movies/Old Guy (2024)
# KEEP: Old Guy (2024) {tmdb-1077782} - [Bluray-1080p][EAC3 5.1][x264]-HiDt.mkv (score: 3876)
cleanup_file "/mnt/synology/rs-movies/Old Guy (2024)/Old Guy (2024) {tmdb-1077782} - [WEBDL-1080p][AC3 5.1][h264]-KBOX.mkv" "Old Guy (2024) {tmdb-1077782} - [WEBDL-1080p][AC3 5.1][h264]-KBOX.mkv (score: 3295 vs keeper 3876)"

# Group: /mnt/synology/rs-movies/Oliver! (1968)
# KEEP: Oliver! (1968) {tmdb-17917} - [Hybrid][Bluray-1080p][EAC3 7.1][DV HDR10][x265]-PTer.mkv (score: 4550)
cleanup_file "/mnt/synology/rs-movies/Oliver! (1968)/Oliver! (1968) {tmdb-17917} - [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv" "Oliver! (1968) {tmdb-17917} - [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv (score: 4050 vs keeper 4550)"

# Group: /mnt/synology/rs-movies/On the Rocks (2020)
# KEEP: On the Rocks (2020) {tmdb-575417} - [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv (score: 3923)
cleanup_file "/mnt/synology/rs-movies/On the Rocks (2020)/On the Rocks (2020) {tmdb-575417} - [WEBRip-1080p][DTS-HD MA 5.1][h264]-CREATiVE24.mkv" "On the Rocks (2020) {tmdb-575417} - [WEBRip-1080p][DTS-HD MA 5.1][h264]-CREATiVE24.mkv (score: 3479 vs keeper 3923)"

# Group: /mnt/synology/rs-movies/Once Upon a Time. in Hollywood (2019)
# KEEP: Once Upon a Time. in Hollywood (2019) {tmdb-466272} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv (score: 3943)
cleanup_file "/mnt/synology/rs-movies/Once Upon a Time. in Hollywood (2019)/Once Upon a Time. in Hollywood (2019) {tmdb-466272} - [WEBDL-1080p][AC3 5.1][x264].mkv" "Once Upon a Time. in Hollywood (2019) {tmdb-466272} - [WEBDL-1080p][AC3 5.1][x264].mkv (score: 3325 vs keeper 3943)"

# Group: /mnt/synology/rs-movies/Over the Moon (2020)
# KEEP: Over the Moon (2020) {tmdb-560050} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-NINJACENTRAL.mkv (score: 3692)
cleanup_file "/mnt/synology/rs-movies/Over the Moon (2020)/Over the Moon (2020) {tmdb-560050} - [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv" "Over the Moon (2020) {tmdb-560050} - [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv (score: 3692 vs keeper 3692)"

# Group: /mnt/synology/rs-movies/Pacific Rim Uprising (2018)
# KEEP: Pacific Rim Uprising (2018) {tmdb-268896} - [Bluray-1080p][EAC3 Atmos 7.1][DV HDR10][x265]-DON.mkv (score: 4900)
cleanup_file "/mnt/synology/rs-movies/Pacific Rim Uprising (2018)/Pacific Rim Uprising (2018) {tmdb-268896} - [Bluray-1080p][AC3 5.1][x264].mkv" "Pacific Rim Uprising (2018) {tmdb-268896} - [Bluray-1080p][AC3 5.1][x264].mkv (score: 3899 vs keeper 4900)"

# Group: /mnt/synology/rs-movies/Passages (2023)
# KEEP: Passages (2023) {tmdb-898673} - [Bluray-1080p][DTS-HD MA 5.1][x264]-PiTBULL.mkv (score: 4165)
cleanup_file "/mnt/synology/rs-movies/Passages (2023)/Passages (2023) {tmdb-898673} - [AMZN][WEBDL-1080p][EAC3 2.0][h264]-XEBEC.mkv" "Passages (2023) {tmdb-898673} - [AMZN][WEBDL-1080p][EAC3 2.0][h264]-XEBEC.mkv (score: 3362 vs keeper 4165)"

# Group: /mnt/synology/rs-movies/Pitch Black (2000)
# KEEP: Pitch Black (2000) {tmdb-2787} - {edition-Directors Cut} [Bluray-1080p][EAC3 Atmos 5.1][DV HDR10][x265]-SQS.mkv (score: 4804)
cleanup_file "/mnt/synology/rs-movies/Pitch Black (2000)/Pitch Black (2000) {tmdb-2787} - {edition-Director's Cut} [Bluray-1080p][EAC3 5.1][HDR10][x265]-DON.mkv" "Pitch Black (2000) {tmdb-2787} - {edition-Director's Cut} [Bluray-1080p][EAC3 5.1][HDR10][x265]-DON.mkv (score: 4350 vs keeper 4804)"

# Group: /mnt/synology/rs-movies/Pontypool (2009)
# KEEP: Pontypool (2009) {tmdb-23963} - [Bluray-1080p][DTS 5.1][x264]-MaG.mkv (score: 3934)
cleanup_file "/mnt/synology/rs-movies/Pontypool (2009)/Pontypool (2009) {tmdb-23963} - [Bluray-1080p][DTS 5.1][x264]-thugline.mkv" "Pontypool (2009) {tmdb-23963} - [Bluray-1080p][DTS 5.1][x264]-thugline.mkv (score: 3915 vs keeper 3934)"

# Group: /mnt/synology/rs-movies/Prey (2022)
# KEEP: Prey (2022) {tmdb-766507} - [Bluray-1080p Proper][TrueHD Atmos 7.1][x264]-Xewdy.mkv (score: 4282)
cleanup_file "/mnt/synology/rs-movies/Prey (2022)/Prey (2022) {tmdb-766507} - [Bluray-1080p][EAC3 7.1][x264]-HiDt.mkv" "Prey (2022) {tmdb-766507} - [Bluray-1080p][EAC3 7.1][x264]-HiDt.mkv (score: 3889 vs keeper 4282)"

# Group: /mnt/synology/rs-movies/Rambo First Blood Part II (1985)
# KEEP: Rambo First Blood Part II (1985) {tmdb-1369} - {edition-Remastered} [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv (score: 3884)
cleanup_file "/mnt/synology/rs-movies/Rambo First Blood Part II (1985)/Rambo First Blood Part II (1985) {tmdb-1369} - [PMTP][WEBDL-1080p][EAC3 5.1][x264]-GRiMM.mkv" "Rambo First Blood Part II (1985) {tmdb-1369} - [PMTP][WEBDL-1080p][EAC3 5.1][x264]-GRiMM.mkv (score: 3330 vs keeper 3884)"

# Group: /mnt/synology/rs-movies/Redemption (2013)
# KEEP: Redemption (2013) {tmdb-271779} - [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv (score: 3951)
cleanup_file "/mnt/synology/rs-movies/Redemption (2013)/Redemption (2013) {tmdb-271779} - [Bluray-720p][DTS 5.1][x264].mkv" "Redemption (2013) {tmdb-271779} - [Bluray-720p][DTS 5.1][x264].mkv (score: 1893 vs keeper 3951)"

# Group: /mnt/synology/rs-movies/Retribution (2023)
# KEEP: Retribution (2023) {tmdb-762430} - [Bluray-1080p][EAC3 Atmos 5.1][x264]-HiDt.mkv (score: 4227)
cleanup_file "/mnt/synology/rs-movies/Retribution (2023)/Retribution (2023) {tmdb-762430} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-IWiLLFiNDyouANDiWiLLKiLLYOU.mkv" "Retribution (2023) {tmdb-762430} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-IWiLLFiNDyouANDiWiLLKiLLYOU.mkv (score: 3718 vs keeper 4227)"

# Group: /mnt/synology/rs-movies/Showgirls (1995)
# KEEP: Showgirls (1995) {tmdb-10802} - [Bluray-1080p Proper][EAC3 5.1][HDR10][x265]-rodeO.mkv (score: 4350)
cleanup_file "/mnt/synology/rs-movies/Showgirls (1995)/Showgirls (1995) {tmdb-10802} - [Bluray-1080p][EAC3 5.1][x264]-LoRD.mkv" "Showgirls (1995) {tmdb-10802} - [Bluray-1080p][EAC3 5.1][x264]-LoRD.mkv (score: 3975 vs keeper 4350)"

# Group: /mnt/synology/rs-movies/Sister Death (2023)
# KEEP: Sister Death (2023) {tmdb-955531} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][DV HDR10][h265]-FLUX.mkv (score: 4220)
cleanup_file "/mnt/synology/rs-movies/Sister Death (2023)/Sister Death (2023) {tmdb-955531} - [WEBDL-1080p][EAC3 Atmos 5.1][x264]-AOC.mp4" "Sister Death (2023) {tmdb-955531} - [WEBDL-1080p][EAC3 Atmos 5.1][x264]-AOC.mp4 (score: 3680 vs keeper 4220)"

# Group: /mnt/synology/rs-movies/Sleeping Dogs (2024)
# KEEP: Sleeping Dogs (2024) {tmdb-978592} - [Bluray-1080p][DTS-HD MA 5.1][x264]-Replica.mkv (score: 4143)
cleanup_file "/mnt/synology/rs-movies/Sleeping Dogs (2024)/Sleeping Dogs (2024) {tmdb-978592} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv" "Sleeping Dogs (2024) {tmdb-978592} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3359 vs keeper 4143)"

# Group: /mnt/synology/rs-movies/Smile (2022)
# KEEP: Smile (2022) {tmdb-882598} - [Bluray-1080p][EAC3 7.1][DV HDR10][x265]-LEGi0N.mkv (score: 4534)
cleanup_file "/mnt/synology/rs-movies/Smile (2022)/Smile (2022) {tmdb-882598} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv" "Smile (2022) {tmdb-882598} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv (score: 3371 vs keeper 4534)"

# Group: /mnt/synology/rs-movies/Snatch (2000)
# KEEP: Snatch (2000) {tmdb-107} - [Hybrid][Bluray-1080p][EAC3 Atmos 5.1][DV HDR10][x265]-HiDt.mkv (score: 4900)
cleanup_file "/mnt/synology/rs-movies/Snatch (2000)/Snatch (2000) {tmdb-107} - [Bluray-1080p][EAC3 7.1][HDR10][x265]-c0kE.mkv" "Snatch (2000) {tmdb-107} - [Bluray-1080p][EAC3 7.1][HDR10][x265]-c0kE.mkv (score: 4326 vs keeper 4900)"

# Group: /mnt/synology/rs-movies/Snitch (2013)
# KEEP: Snitch (2013) {tmdb-134411} - [Bluray-1080p][EAC3 7.1][HDR10][x265]-SoLaR.mkv (score: 4256)
cleanup_file "/mnt/synology/rs-movies/Snitch (2013)/Snitch (2013) {tmdb-134411} - [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv" "Snitch (2013) {tmdb-134411} - [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv (score: 3938 vs keeper 4256)"

# Group: /mnt/synology/rs-movies/Sorority Babes in the Slimeball Bowl-O-Rama (1988)
# KEEP: Sorority Babes in the Slimeball Bowl-O-Rama (1988) {tmdb-27390} - [Bluray-1080p][FLAC 2.0][x264]-MaG.mkv (score: 3730)
cleanup_file "/mnt/synology/rs-movies/Sorority Babes in the Slimeball Bowl-O-Rama (1988)/Sorority Babes in the Slimeball Bowl-O-Rama (1988) {tmdb-27390} - [AMZN MA][WEBDL-1080p][EAC3 2.0][h264]-Kitsune.mkv" "Sorority Babes in the Slimeball Bowl-O-Rama (1988) {tmdb-27390} - [AMZN MA][WEBDL-1080p][EAC3 2.0][h264]-Kitsune.mkv (score: 3354 vs keeper 3730)"

# Group: /mnt/synology/rs-movies/Soul (2020)
# KEEP: Soul (2020) {tmdb-508442} - [Bluray-1080p Proper][EAC3 7.1][x264]-SbR.mkv (score: 3905)
cleanup_file "/mnt/synology/rs-movies/Soul (2020)/Soul (2020) {tmdb-508442} - [WEBDL-1080p][EAC3 Atmos 5.1][h264].mkv" "Soul (2020) {tmdb-508442} - [WEBDL-1080p][EAC3 Atmos 5.1][h264].mkv (score: 3702 vs keeper 3905)"

# Group: /mnt/synology/rs-movies/Spider-Man Into the Spider-Verse (2018)
# KEEP: Spider-Man Into the Spider-Verse (2018) {tmdb-324857} - [Bluray-1080p][TrueHD Atmos 7.1][DV HDR10][x265]-PirateM.mkv (score: 4792)
cleanup_file "/mnt/synology/rs-movies/Spider-Man Into the Spider-Verse (2018)/Spider-Man Into the Spider-Verse (2018) {tmdb-324857} - [WEBDL-1080p][EAC3 5.1][h264].mkv" "Spider-Man Into the Spider-Verse (2018) {tmdb-324857} - [WEBDL-1080p][EAC3 5.1][h264].mkv (score: 3375 vs keeper 4792)"

# Group: /mnt/synology/rs-movies/Spiral From the Book of Saw (2021)
# KEEP: Spiral From the Book of Saw (2021) {tmdb-602734} - [Bluray-1080p][EAC3 Atmos 7.1][x264]-iFT.mkv (score: 4271)
cleanup_file "/mnt/synology/rs-movies/Spiral From the Book of Saw (2021)/Spiral From the Book of Saw (2021) {tmdb-602734} - [Bluray-1080p][EAC3 7.1][x264]-LoRD.mkv" "Spiral From the Book of Saw (2021) {tmdb-602734} - [Bluray-1080p][EAC3 7.1][x264]-LoRD.mkv (score: 3911 vs keeper 4271)"

# Group: /mnt/synology/rs-movies/Spirit Untamed (2021)
# KEEP: Spirit Untamed (2021) {tmdb-637693} - [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv (score: 3892)
cleanup_file "/mnt/synology/rs-movies/Spirit Untamed (2021)/Spirit Untamed (2021) {tmdb-637693} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv" "Spirit Untamed (2021) {tmdb-637693} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv (score: 3345 vs keeper 3892)"

# Group: /mnt/synology/rs-movies/Splitsville (2025)
# KEEP: Splitsville (2025) {tmdb-1337562} - [Bluray-1080p][DTS-HD MA 5.1][x264]-KNiVES.mkv (score: 4160)
cleanup_file "/mnt/synology/rs-movies/Splitsville (2025)/Splitsville (2025) {tmdb-1337562} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv" "Splitsville (2025) {tmdb-1337562} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv (score: 3372 vs keeper 4160)"

# Group: /mnt/synology/rs-movies/Spoiler Alert (2022)
# KEEP: Spoiler Alert (2022) {tmdb-507903} - [Bluray-1080p][EAC3 Atmos 5.1][x264]-Kitsune.mkv (score: 4234)
cleanup_file "/mnt/synology/rs-movies/Spoiler Alert (2022)/Spoiler Alert (2022) {tmdb-507903} - [Bluray-1080p][DTS-HD MA 5.1][x264]-PiGNUS.mkv" "Spoiler Alert (2022) {tmdb-507903} - [Bluray-1080p][DTS-HD MA 5.1][x264]-PiGNUS.mkv (score: 4217 vs keeper 4234)"

# Group: /mnt/synology/rs-movies/Starman (1984)
# KEEP: Starman (1984) {tmdb-9663} - [Bluray-1080p][EAC3 Atmos 5.1][DV HDR10][x265]-SQS.mkv (score: 4766)
cleanup_file "/mnt/synology/rs-movies/Starman (1984)/Starman (1984) {tmdb-9663} - [Bluray-1080p][AC3 5.1][x264].mkv" "Starman (1984) {tmdb-9663} - [Bluray-1080p][AC3 5.1][x264].mkv (score: 3829 vs keeper 4766)"

# Group: /mnt/synology/rs-movies/Summer Rental (1985)
# KEEP: Summer Rental (1985) {tmdb-19357} - [Bluray-1080p][AC3 2.0][x264]-BHDStudio.mp4 (score: 3800)
cleanup_file "/mnt/synology/rs-movies/Summer Rental (1985)/Summer Rental (1985) {tmdb-19357} - [WEBDL-1080p][EAC3 2.0][h264]-ETHiCS.mkv" "Summer Rental (1985) {tmdb-19357} - [WEBDL-1080p][EAC3 2.0][h264]-ETHiCS.mkv (score: 3385 vs keeper 3800)"

# Group: /mnt/synology/rs-movies/Swiss Army Man (2016)
# KEEP: Swiss Army Man (2016) {tmdb-347031} - [Bluray-1080p][DTS-ES 6.1][x264]-D-Z0N3.mkv (score: 4003)
cleanup_file "/mnt/synology/rs-movies/Swiss Army Man (2016)/Swiss Army Man (2016) {tmdb-347031} - [Bluray-1080p][AC3 5.1][x264].mkv" "Swiss Army Man (2016) {tmdb-347031} - [Bluray-1080p][AC3 5.1][x264].mkv (score: 3882 vs keeper 4003)"

# Group: /mnt/synology/rs-movies/Terminator 2 Judgment Day (1991)
# KEEP: Terminator 2 Judgment Day (1991) {tmdb-280} - [Bluray-1080p][EAC3 5.1][HDR10][x265]-CtrlHD.mkv (score: 4256)
cleanup_file "/mnt/synology/rs-movies/Terminator 2 Judgment Day (1991)/Terminator 2 Judgment Day (1991) {tmdb-280} - {edition-Directors Cut} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv" "Terminator 2 Judgment Day (1991) {tmdb-280} - {edition-Directors Cut} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv (score: 4032 vs keeper 4256)"

# Group: /mnt/synology/rs-movies/Terrifier 3 (2024)
# KEEP: Terrifier 3 (2024) {tmdb-1034541} - [Bluray-1080p][EAC3 Atmos 5.1][DV HDR10][x265]-SQS.mkv (score: 4778)
cleanup_file "/mnt/synology/rs-movies/Terrifier 3 (2024)/Terrifier 3 (2024) {tmdb-1034541} - [WEBDL-1080p][AC3 5.1][h264]-BulkyMeekSpoonbillOfCookies.mkv" "Terrifier 3 (2024) {tmdb-1034541} - [WEBDL-1080p][AC3 5.1][h264]-BulkyMeekSpoonbillOfCookies.mkv (score: 3310 vs keeper 4778)"

# Group: /mnt/synology/rs-movies/The 355 (2022)
# KEEP: The 355 (2022) {tmdb-522016} - [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv (score: 3932)
cleanup_file "/mnt/synology/rs-movies/The 355 (2022)/The 355 (2022) {tmdb-522016} - [WEBDL-1080p][AC3 5.1][h264]-DKV.mkv" "The 355 (2022) {tmdb-522016} - [WEBDL-1080p][AC3 5.1][h264]-DKV.mkv (score: 3284 vs keeper 3932)"

# Group: /mnt/synology/rs-movies/The Bad Guys 2 (2025)
# KEEP: The Bad Guys 2 (2025) {tmdb-1175942} - [Hybrid][Bluray-1080p][EAC3 Atmos 5.1][DV HDR10Plus][x265]-HiDt.mkv (score: 4847)
cleanup_file "/mnt/synology/rs-movies/The Bad Guys 2 (2025)/The Bad Guys 2 (2025) {tmdb-1175942} - [WEBRip-1080p][EAC3 Atmos 5.1][x264]-HiDt.mkv" "The Bad Guys 2 (2025) {tmdb-1175942} - [WEBRip-1080p][EAC3 Atmos 5.1][x264]-HiDt.mkv (score: 3584 vs keeper 4847)"

# Group: /mnt/synology/rs-movies/The Beekeeper (2024)
# KEEP: The Beekeeper (2024) {tmdb-866398} - [Hybrid][Bluray-1080p][EAC3 Atmos 5.1][DV HDR10Plus][x265]-HiDt.mkv (score: 4826)
cleanup_file "/mnt/synology/rs-movies/The Beekeeper (2024)/The Beekeeper (2024) {tmdb-866398} - [WEBDL-1080p][EAC3 5.1][h264]-LilKim.mkv" "The Beekeeper (2024) {tmdb-866398} - [WEBDL-1080p][EAC3 5.1][h264]-LilKim.mkv (score: 3368 vs keeper 4826)"

# Group: /mnt/synology/rs-movies/The Boss Baby Family Business (2021)
# KEEP: The Boss Baby Family Business (2021) {tmdb-459151} - [Bluray-1080p][EAC3 7.1][DV HDR10][x265]-c0kE.mkv (score: 4451)
cleanup_file "/mnt/synology/rs-movies/The Boss Baby Family Business (2021)/The Boss Baby Family Business (2021) {tmdb-459151} - [PCOK][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv" "The Boss Baby Family Business (2021) {tmdb-459151} - [PCOK][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv (score: 3356 vs keeper 4451)"

# Group: /mnt/synology/rs-movies/The Chronicles of Narnia The Lion the Witch and the Wardrobe (2005)
# KEEP: The Chronicles of Narnia The Lion the Witch and the Wardrobe (2005) {tmdb-411} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv (score: 3976)
cleanup_file "/mnt/synology/rs-movies/The Chronicles of Narnia The Lion the Witch and the Wardrobe (2005)/The Chronicles of Narnia The Lion the Witch and the Wardrobe (2005) {tmdb-411} - [Bluray-1080p][DTS 5.1][x264].mkv" "The Chronicles of Narnia The Lion the Witch and the Wardrobe (2005) {tmdb-411} - [Bluray-1080p][DTS 5.1][x264].mkv (score: 3960 vs keeper 3976)"

# Group: /mnt/synology/rs-movies/The Death and Return of Superman (2019)
# KEEP: The Death and Return of Superman (2019) {tmdb-630656} - [Bluray-1080p][DTS 5.1][x264]-getit.mkv (score: 3937)
cleanup_file "/mnt/synology/rs-movies/The Death and Return of Superman (2019)/The Death and Return of Superman (2019) {tmdb-630656} - [Bluray-1080p][EAC3 5.1][x264]-Itwasntme.mkv" "The Death and Return of Superman (2019) {tmdb-630656} - [Bluray-1080p][EAC3 5.1][x264]-Itwasntme.mkv (score: 3839 vs keeper 3937)"

# Group: /mnt/synology/rs-movies/The Dreamers (2003)
# KEEP: The Dreamers (2003) {tmdb-1278} - [Bluray-1080p][EAC3 5.1][x264]-c0kE.mkv (score: 4000)
cleanup_file "/mnt/synology/rs-movies/The Dreamers (2003)/The Dreamers (2003) {tmdb-1278} - [Bluray-1080p][AC3 5.1][x264]-Geek.mkv" "The Dreamers (2003) {tmdb-1278} - [Bluray-1080p][AC3 5.1][x264]-Geek.mkv (score: 3937 vs keeper 4000)"

# Group: /mnt/synology/rs-movies/The Florida Project (2017)
# KEEP: The Florida Project (2017) {tmdb-394117} - [Bluray-1080p][DTS 5.1][x264]-NCmt.mkv (score: 4024)
cleanup_file "/mnt/synology/rs-movies/The Florida Project (2017)/The Florida Project (2017) {tmdb-394117} - [Bluray-1080p][DTS 5.1][x264].mkv" "The Florida Project (2017) {tmdb-394117} - [Bluray-1080p][DTS 5.1][x264].mkv (score: 3937 vs keeper 4024)"

# Group: /mnt/synology/rs-movies/The Fugitive (1993)
# KEEP: The Fugitive (1993) {tmdb-5503} - [Bluray-1080p][EAC3 5.1][HDR10][x265]-c0kE.mkv (score: 4350)
cleanup_file "/mnt/synology/rs-movies/The Fugitive (1993)/The Fugitive (1993) {tmdb-5503} - [Bluray-1080p][AC3 5.1][x264].mkv" "The Fugitive (1993) {tmdb-5503} - [Bluray-1080p][AC3 5.1][x264].mkv (score: 3829 vs keeper 4350)"

# Group: /mnt/synology/rs-movies/The Good Dinosaur (2015)
# KEEP: The Good Dinosaur (2015) {tmdb-105864} - [Bluray-1080p][EAC3 5.1][DV HDR10][AV1]-TiZU.mkv (score: 4353)
cleanup_file "/mnt/synology/rs-movies/The Good Dinosaur (2015)/The Good Dinosaur (2015) {tmdb-105864} - [Bluray-1080p][DTS-HD MA 7.1][x264]-FuzerHD.mkv" "The Good Dinosaur (2015) {tmdb-105864} - [Bluray-1080p][DTS-HD MA 7.1][x264]-FuzerHD.mkv (score: 4149 vs keeper 4353)"

# Group: /mnt/synology/rs-movies/The House with a Clock in Its Walls (2018)
# KEEP: The House with a Clock in Its Walls (2018) {tmdb-463821} - [Bluray-1080p][TrueHD Atmos 7.1][x264]-iFT.mkv (score: 4281)
cleanup_file "/mnt/synology/rs-movies/The House with a Clock in Its Walls (2018)/The House with a Clock in Its Walls (2018) {tmdb-463821} - [MA][WEBDL-1080p][EAC3 5.1][x264]-HHWEB.mkv" "The House with a Clock in Its Walls (2018) {tmdb-463821} - [MA][WEBDL-1080p][EAC3 5.1][x264]-HHWEB.mkv (score: 3360 vs keeper 4281)"

# Group: /mnt/synology/rs-movies/The Hunger Games The Ballad of Songbirds and Snakes (2023)
# KEEP: The Hunger Games The Ballad of Songbirds and Snakes (2023) {tmdb-695721} - [Bluray-1080p][TrueHD Atmos 7.1][x264]-ROEN.mkv (score: 4335)
cleanup_file "/mnt/synology/rs-movies/The Hunger Games The Ballad of Songbirds and Snakes (2023)/The Hunger Games The Ballad of Songbirds and Snakes (2023) {tmdb-695721} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv" "The Hunger Games The Ballad of Songbirds and Snakes (2023) {tmdb-695721} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv (score: 3740 vs keeper 4335)"

# Group: /mnt/synology/rs-movies/The Hustle (2019)
# KEEP: The Hustle (2019) {tmdb-449562} - [Bluray-1080p][DTS-HD MA 7.1][x264]-HDChina.mkv (score: 4187)
cleanup_file "/mnt/synology/rs-movies/The Hustle (2019)/The Hustle (2019) {tmdb-449562} - [Bluray-1080p][DTS 5.1][x264]-drones.mkv" "The Hustle (2019) {tmdb-449562} - [Bluray-1080p][DTS 5.1][x264]-drones.mkv (score: 3926 vs keeper 4187)"

# Group: /mnt/synology/rs-movies/The Iron Claw (2023)
# KEEP: The Iron Claw (2023) {tmdb-850165} - [Bluray-1080p][DTS-HD MA 5.1][x264]-PiGNUS.mkv (score: 4218)
cleanup_file "/mnt/synology/rs-movies/The Iron Claw (2023)/The Iron Claw (2023) {tmdb-850165} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv" "The Iron Claw (2023) {tmdb-850165} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv (score: 3745 vs keeper 4218)"

# Group: /mnt/synology/rs-movies/The Killing Fields (1984)
# KEEP: The Killing Fields (1984) {tmdb-625} - [Bluray-1080p][EAC3 5.1][x264]-EA.mkv (score: 3987)
cleanup_file "/mnt/synology/rs-movies/The Killing Fields (1984)/The Killing Fields (1984) {tmdb-625} - [Bluray-1080p][DTS 5.1][x264]-TiMELORDS.mkv" "The Killing Fields (1984) {tmdb-625} - [Bluray-1080p][DTS 5.1][x264]-TiMELORDS.mkv (score: 3959 vs keeper 3987)"

# Group: /mnt/synology/rs-movies/The Lego Movie (2014)
# KEEP: The Lego Movie (2014) {tmdb-137106} - [Bluray-1080p][DTS 5.1][x264]-LolHD.mkv (score: 3945)
cleanup_file "/mnt/synology/rs-movies/The Lego Movie (2014)/The Lego Movie (2014) {tmdb-137106} - [Bluray-1080p][DTS 5.1][x264]-CyTSuNee.mkv" "The Lego Movie (2014) {tmdb-137106} - [Bluray-1080p][DTS 5.1][x264]-CyTSuNee.mkv (score: 3929 vs keeper 3945)"

# Group: /mnt/synology/rs-movies/The Lion King (1994)
# KEEP: The Lion King (1994) {tmdb-8587} - [Bluray-1080p][EAC3 7.1][HDR10][x265]-D-Z0N3.mkv (score: 4200)
cleanup_file "/mnt/synology/rs-movies/The Lion King (1994)/The Lion King (1994) {tmdb-8587} - [Bluray-1080p][DTS 5.1][x264].mkv" "The Lion King (1994) {tmdb-8587} - [Bluray-1080p][DTS 5.1][x264].mkv (score: 3973 vs keeper 4200)"

# Group: /mnt/synology/rs-movies/The Magnificent Seven (1960)
# KEEP: The Magnificent Seven (1960) {tmdb-966} - [Bluray-1080p][EAC3 5.1][DV HDR10][x265]-c0kE.mkv (score: 4549)
cleanup_file "/mnt/synology/rs-movies/The Magnificent Seven (1960)/The Magnificent Seven (1960) {tmdb-966} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv" "The Magnificent Seven (1960) {tmdb-966} - [Bluray-1080p][DTS 5.1][x264]-DON.mkv (score: 3968 vs keeper 4549)"

# Group: /mnt/synology/rs-movies/The Mummy Returns (2001)
# KEEP: The Mummy Returns (2001) {tmdb-1734} - [Bluray-1080p][EAC3 5.1][HDR10][x265]-SQS.mkv (score: 4222)
cleanup_file "/mnt/synology/rs-movies/The Mummy Returns (2001)/The Mummy Returns (2001) {tmdb-1734} - [Bluray-1080p][EAC3 7.1][x264].mkv" "The Mummy Returns (2001) {tmdb-1734} - [Bluray-1080p][EAC3 7.1][x264].mkv (score: 3987 vs keeper 4222)"

# Group: /mnt/synology/rs-movies/The Outfit (2022)
# KEEP: The Outfit (2022) {tmdb-799876} - [Bluray-1080p][EAC3 7.1][HDR10][x265]-c0kE.mkv (score: 4246)
cleanup_file "/mnt/synology/rs-movies/The Outfit (2022)/The Outfit (2022) {tmdb-799876} - [Bluray-1080p][EAC3 5.1][x264]-SPHD.mkv" "The Outfit (2022) {tmdb-799876} - [Bluray-1080p][EAC3 5.1][x264]-SPHD.mkv (score: 3911 vs keeper 4246)"

# Group: /mnt/synology/rs-movies/The Pirates! In an Adventure with Scientists! (2012)
# KEEP: The Pirates! In an Adventure with Scientists! (2012) {tmdb-72197} - [Bluray-1080p][DTS 5.1][x264]-EbP.mkv (score: 3912)
cleanup_file "/mnt/synology/rs-movies/The Pirates! In an Adventure with Scientists! (2012)/The Pirates! In an Adventure with Scientists! (2012) {tmdb-72197} - [Bluray-720p][DTS 5.1][x264].mkv" "The Pirates! In an Adventure with Scientists! (2012) {tmdb-72197} - [Bluray-720p][DTS 5.1][x264].mkv (score: 1882 vs keeper 3912)"

# Group: /mnt/synology/rs-movies/The Rock (1996)
# KEEP: The Rock (1996) {tmdb-9802} - [Bluray-1080p][DTS-HD MA 5.1][x264]-BluEvo.mkv (score: 4212)
cleanup_file "/mnt/synology/rs-movies/The Rock (1996)/The Rock (1996) {tmdb-9802} - [Bluray-1080p][DTS 5.1][x264]-ESiR.mkv" "The Rock (1996) {tmdb-9802} - [Bluray-1080p][DTS 5.1][x264]-ESiR.mkv (score: 3973 vs keeper 4212)"

# Group: /mnt/synology/rs-movies/The Substance (2024)
# KEEP: The Substance (2024) {tmdb-933260} - [Bluray-1080p][EAC3 5.1][DV HDR10][x265]-HiDt.mkv (score: 4517)
cleanup_file "/mnt/synology/rs-movies/The Substance (2024)/The Substance (2024) {tmdb-933260} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv" "The Substance (2024) {tmdb-933260} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv (score: 3359 vs keeper 4517)"

# Group: /mnt/synology/rs-movies/The Tailor of Panama (2001)
# KEEP: The Tailor of Panama (2001) {tmdb-2575} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv (score: 3897)
cleanup_file "/mnt/synology/rs-movies/The Tailor of Panama (2001)/The Tailor of Panama (2001) {tmdb-2575} - [Bluray-1080p][AC3 5.1][x264]-HDS.mkv" "The Tailor of Panama (2001) {tmdb-2575} - [Bluray-1080p][AC3 5.1][x264]-HDS.mkv (score: 3883 vs keeper 3897)"

# Group: /mnt/synology/rs-movies/Traffic (2000)
# KEEP: Traffic (2000) {tmdb-1900} - [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv (score: 4050)
cleanup_file "/mnt/synology/rs-movies/Traffic (2000)/Traffic (2000) {tmdb-1900} - [Bluray-1080p][EAC3 5.1][x264]-LoRD.mkv" "Traffic (2000) {tmdb-1900} - [Bluray-1080p][EAC3 5.1][x264]-LoRD.mkv (score: 3967 vs keeper 4050)"

# Group: /mnt/synology/rs-movies/Trollhunters Rise of the Titans (2021)
# KEEP: Trollhunters Rise of the Titans (2021) {tmdb-730840} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][HDR10][HEVC]-TEPES.mkv (score: 4043)
cleanup_file "/mnt/synology/rs-movies/Trollhunters Rise of the Titans (2021)/Trollhunters Rise of the Titans (2021) {tmdb-730840} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-EVO.mkv" "Trollhunters Rise of the Titans (2021) {tmdb-730840} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-EVO.mkv (score: 3694 vs keeper 4043)"

# Group: /mnt/synology/rs-movies/Trolls Holiday in Harmony (2021)
# KEEP: Trolls Holiday in Harmony (2021) {tmdb-896221} - [Bluray-1080p][DTS 5.1][x264]-fl00f.mkv (score: 3871)
cleanup_file "/mnt/synology/rs-movies/Trolls Holiday in Harmony (2021)/Trolls Holiday in Harmony (2021) {tmdb-896221} - [WEBDL-1080p][AAC 2.0][x264]-DiRT.mkv" "Trolls Holiday in Harmony (2021) {tmdb-896221} - [WEBDL-1080p][AAC 2.0][x264]-DiRT.mkv (score: 3212 vs keeper 3871)"

# Group: /mnt/synology/rs-movies/V H S Beyond (2024)
# KEEP: V H S Beyond (2024) {tmdb-1190868} - [Bluray-1080p][EAC3 5.1][x264]-PTer.mkv (score: 3948)
cleanup_file "/mnt/synology/rs-movies/V H S Beyond (2024)/V H S Beyond (2024) {tmdb-1190868} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv" "V H S Beyond (2024) {tmdb-1190868} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv (score: 3377 vs keeper 3948)"

# Group: /mnt/synology/rs-movies/Wanted (2008)
# KEEP: Wanted (2008) {tmdb-8909} - [Bluray-1080p Proper][EAC3 5.1][DV HDR10][x265]-c0kE.mkv (score: 4518)
cleanup_file "/mnt/synology/rs-movies/Wanted (2008)/Wanted (2008) {tmdb-8909} - [Bluray-1080p][DTS 5.1][x264].mkv" "Wanted (2008) {tmdb-8909} - [Bluray-1080p][DTS 5.1][x264].mkv (score: 3929 vs keeper 4518)"

# Group: /mnt/synology/rs-movies/We Live in Time (2024)
# KEEP: We Live in Time (2024) {tmdb-1100099} - [Bluray-1080p][TrueHD Atmos 7.1][x264]-knives.mkv (score: 4329)
cleanup_file "/mnt/synology/rs-movies/We Live in Time (2024)/We Live in Time (2024) {tmdb-1100099} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-Kitsune.mkv" "We Live in Time (2024) {tmdb-1100099} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-Kitsune.mkv (score: 3724 vs keeper 4329)"

# Group: /mnt/synology/rs-movies/Woman of the Hour (2024)
# KEEP: Woman of the Hour (2024) {tmdb-835113} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv (score: 3870)
cleanup_file "/mnt/synology/rs-movies/Woman of the Hour (2024)/Woman of the Hour (2024) {tmdb-835113} - [WEBDL-1080p][EAC3 Atmos 5.1][x264]-ETHEL.mkv" "Woman of the Hour (2024) {tmdb-835113} - [WEBDL-1080p][EAC3 Atmos 5.1][x264]-ETHEL.mkv (score: 3686 vs keeper 3870)"

# Group: /mnt/synology/rs-movies/You Me and Dupree (2006)
# KEEP: You Me and Dupree (2006) {tmdb-1819} - [Bluray-1080p][EAC3 5.1][x264]-RiCO.mkv (score: 3970)
cleanup_file "/mnt/synology/rs-movies/You Me and Dupree (2006)/You Me and Dupree (2006) {tmdb-1819} - [Bluray-1080p][DTS 5.1][x264].mkv" "You Me and Dupree (2006) {tmdb-1819} - [Bluray-1080p][DTS 5.1][x264].mkv (score: 3969 vs keeper 3970)"

# Group: /mnt/synology/rs-movies/Zombeavers (2014)
# KEEP: Zombeavers (2014) {tmdb-254474} - [Bluray-1080p][DTS-HD MA 5.1][x264]-Grym.mkv (score: 4133)
cleanup_file "/mnt/synology/rs-movies/Zombeavers (2014)/Zombeavers (2014) {tmdb-254474} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv" "Zombeavers (2014) {tmdb-254474} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv (score: 3351 vs keeper 4133)"

# Group: /mnt/synology/rs-movies/Zombieland (2009)
# KEEP: Zombieland (2009) {tmdb-19908} - [Hybrid][Bluray-1080p][EAC3 Atmos 5.1][DV HDR10][x265]-SQS.mkv (score: 4756)
cleanup_file "/mnt/synology/rs-movies/Zombieland (2009)/Zombieland (2009) {tmdb-19908} - {edition-Open Matte} [WEBDL-1080p][EAC3 5.1][h264]-spartanec163.mkv" "Zombieland (2009) {tmdb-19908} - {edition-Open Matte} [WEBDL-1080p][EAC3 5.1][h264]-spartanec163.mkv (score: 3358 vs keeper 4756)"

# Group: /mnt/synology/rs-movies/Zootopia (2016)
# KEEP: Zootopia (2016) {tmdb-269149} - [Bluray-1080p][DTS 5.1][x264]-TAiCHi.mkv (score: 3967)
cleanup_file "/mnt/synology/rs-movies/Zootopia (2016)/Zootopia (2016) {tmdb-269149} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4" "Zootopia (2016) {tmdb-269149} - [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4 (score: 3815 vs keeper 3967)"

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
