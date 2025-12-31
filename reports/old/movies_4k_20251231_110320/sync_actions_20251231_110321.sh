#!/bin/bash
#==============================================================================
# Project Mother Sync Script
# RUN THIS ON MOTHER (10.0.0.162)
#==============================================================================
# Generated: 2025-12-31 11:03:21
#
# This script uses Mother's mount paths:
#   Synology: /mnt/synology/rs-*
#   Unraid:   /mnt/unraid/media/*
#
# Review carefully before executing!
#==============================================================================

set -e

# DRY RUN MODE - Remove 'echo' to execute
DRY_RUN=true

run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        echo "[DRY RUN] $@"
    else
        "$@"
    fi
}

# === MOVE TO DELETED FOLDERS ===

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Matrix Resurrections (2021)/The Matrix Resurrections (2021) {tmdb-624860} - [WEBDL-2160p][EAC3 Atmos 5.1][DV HDR10][x265].mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/V for Vendetta (2006)/V for Vendetta (2006) {tmdb-752} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Earth One Amazing Day (2017)/Earth One Amazing Day (2017) {tmdb-464593} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Solo A Star Wars Story (2018)/Solo A Star Wars Story (2018) {tmdb-348350} - [Bluray-2160p Proper][TrueHD Atmos 7.1][HDR10][x265]-TnP.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Pitch Black (2000)/Pitch Black (2000) {tmdb-2787} - {edition-Directors Cut} [Bluray-2160p Proper][DTS-HD MA 5.1][HDR10][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Lord of the Rings The Fellowship of the Ring (2001)/The Lord of the Rings The Fellowship of the Ring (2001) {tmdb-120} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][h265].mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Star Trek IV The Voyage Home (1986)/Star Trek IV The Voyage Home (1986) {tmdb-168} - [Bluray-2160p][AC3 5.1][HDR10][x265]-BHDStudio.mp4" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Iron Man 2 (2010)/Iron Man 2 (2010) {tmdb-10138} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-Absinth.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Blade (1998)/Blade (1998) {tmdb-36647} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265].mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Dark Knight (2008)/The Dark Knight (2008) {tmdb-155} - [Remux-2160p][DTS-HD MA 5.1][HDR10][HEVC]-BluDragon.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Dark Knight Rises (2012)/The Dark Knight Rises (2012) {tmdb-49026} - [Remux-2160p][DTS-HD MA 5.1][HDR10][HEVC]-BluDragon.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Pacific Rim (2013)/Pacific Rim (2013) {tmdb-68726} - [Bluray-2160p][AC3 5.1][HDR10][x265]-BHDStudio.mp4" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Bohemian Rhapsody (2018)/Bohemian Rhapsody (2018) {tmdb-424694} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10Plus][x265]-W4NK3R.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Inception (2010)/Inception (2010) {tmdb-27205} - [Bluray-2160p][DTS-HD MA 5.1][PQ][x265]-TERMiNAL.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Avengers (2012)/The Avengers (2012) {tmdb-24428} - [Remux-2160p Proper][TrueHD Atmos 7.1][HDR10][HEVC]-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Lord of the Rings The Return of the King (2003)/The Lord of the Rings The Return of the King (2003) {tmdb-122} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][h265].mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Alien (1979)/Alien (1979) {tmdb-348} - [WEBDL-2160p][DTS-HD MA 5.1][HDR10Plus][h265]-SHD.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Kingdom of Heaven (2005)/Kingdom of Heaven (2005) {tmdb-1495} - {edition-Theatrical} [WEBDL-2160p][EAC3 5.1][HDR10][h265]-SMURF.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Army of the Dead (2021)/Army of the Dead (2021) {tmdb-503736} - [NF][WEBRip-2160p][EAC3 Atmos 5.1][HDR10][x265]-TrollUHD-FZ.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Captain America The First Avenger (2011)/Captain America The First Avenger (2011) {tmdb-1771} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-Absinth.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Dunkirk (2017)/Dunkirk (2017) {tmdb-374720} - [Bluray-2160p][DTS 5.1][HDR10][x265]-SadeceBluRay.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/The Hunger Games Catching Fire (2013)/The Hunger Games Catching Fire (2013) {tmdb-101299} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/The Hunger Games Mockingjay Part 1 (2014)/The Hunger Games Mockingjay Part 1 (2014) {tmdb-131631} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Captain Marvel (2019)/Captain Marvel (2019) {tmdb-299537} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Thor Ragnarok (2017)/Thor Ragnarok (2017) {tmdb-284053} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10Plus][x265]-UnKn0wn.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Zombieland (2009)/Zombieland (2009) {tmdb-19908} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-IAMABLE.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Tenet (2020)/Tenet (2020) {tmdb-577922} - [Bluray-2160p Proper][DTS-HD MA 5.1][HDR10][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/300 (2007)/300 (2007) {tmdb-1271} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Raiders of the Lost Ark (1981)/Raiders of the Lost Ark (1981) {tmdb-85} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-4K4U.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Avengers Endgame (2019)/Avengers Endgame (2019) {tmdb-299534} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Predator (2018)/The Predator (2018) {tmdb-346910} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-BluDragon.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Star Trek The Motion Picture (1979)/Star Trek The Motion Picture (1979) {tmdb-152} - [Bluray-2160p][TrueHD Atmos 7.1][DV][x265]-VD0N.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Star Wars (1977)/Star Wars (1977) {tmdb-11} - [Hybrid][Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-HiDt.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Mortal Kombat (2021)/Mortal Kombat (2021) {tmdb-460465} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-HQMUX.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Braveheart (1995)/Braveheart (1995) {tmdb-197} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-IAMABLE.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Black Adam (2022)/Black Adam (2022) {tmdb-436270} - [WEBDL-2160p Proper][EAC3 Atmos 5.1][DV HDR10][h265].mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Logan (2017)/Logan (2017) {tmdb-263115} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-TERMiNAL.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Batman Begins (2005)/Batman Begins (2005) {tmdb-272} - [Remux-2160p][DTS-HD MA 5.1][HDR10][HEVC]-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Joker (2019)/Joker (2019) {tmdb-475557} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-MgB.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Ad Astra (2019)/Ad Astra (2019) {tmdb-419704} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-KeYBLaDE.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Rocketman (2019)/Rocketman (2019) {tmdb-504608} - [Bluray-2160p][EAC3 7.1][DV HDR10][x265]-HONE.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Deadpool and Wolverine (2024)/Deadpool and Wolverine (2024) {tmdb-533535} - [WEBDL-2160p][EAC3 Atmos 5.1][DV HDR10Plus][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Star Trek Into Darkness (2013)/Star Trek Into Darkness (2013) {tmdb-54138} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Twister (1996)/Twister (1996) {tmdb-664} - [Remux-1080p][TrueHD Atmos 7.1][x264].mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Shazam! Fury of the Gods (2023)/Shazam! Fury of the Gods (2023) {tmdb-594767} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Guardians of the Galaxy (2014)/Guardians of the Galaxy (2014) {tmdb-118340} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Hunt for Red October (1990)/The Hunt for Red October (1990) {tmdb-1669} - [Bluray-2160p][TrueHD 5.1][HDR10][x265]-HQMUX.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Mad Max Fury Road (2015)/Mad Max Fury Road (2015) {tmdb-76341} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-BluDragon.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Jaws (1975)/Jaws (1975) {tmdb-578} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-HQMUX.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Dune (2021)/Dune (2021) {tmdb-438631} - [Bluray-2160p Proper][TrueHD Atmos 7.1][DV HDR10Plus][x265]-W4NK3R.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Star Trek VI The Undiscovered Country (1991)/Star Trek VI The Undiscovered Country (1991) {tmdb-174} - {edition-Theatrical Cut} [Bluray-2160p][EAC3 7.1][DV HDR10][x265]-hallowed.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/John Wick Chapter 2 (2017)/John Wick Chapter 2 (2017) {tmdb-324552} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-SPHD.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Guardians of the Galaxy Vol. 2 (2017)/Guardians of the Galaxy Vol. 2 (2017) {tmdb-283995} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-TERMiNAL.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Fast and Furious 6 (2013)/Fast and Furious 6 (2013) {tmdb-82992} - {edition-Extended} [Bluray-2160p Proper][DTS-HD MA 5.1][HDR10][x265]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Star Trek V The Final Frontier (1989)/Star Trek V The Final Frontier (1989) {tmdb-172} - [Bluray-2160p][EAC3 7.1][DV HDR10][x265]-hallowed.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Iron Man (2008)/Iron Man (2008) {tmdb-1726} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-4K4U.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/John Wick (2014)/John Wick (2014) {tmdb-245891} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-Absinth.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Top Gun (1986)/Top Gun (1986) {tmdb-744} - [Bluray-2160p][EAC3 7.1][DV HDR10][x265]-hallowed.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Wonder Woman (2017)/Wonder Woman (2017) {tmdb-297762} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Twisters (2024)/Twisters (2024) {tmdb-718821} - [WEBDL-2160p][EAC3 Atmos 5.1][DV HDR10Plus][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Star Trek III The Search for Spock (1984)/Star Trek III The Search for Spock (1984) {tmdb-157} - [Bluray-2160p][AC3 5.1][HDR10][x265]-BHDStudio.mp4" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Revenant (2015)/The Revenant (2015) {tmdb-281957} - [Remux-2160p][DTS-HD MA 7.1][HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Top Gun Maverick (2022)/Top Gun Maverick (2022) {tmdb-361743} - [WEBDL-2160p][EAC3 Atmos 5.1][DV HDR10Plus][h265].mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Bram Stokers Dracula (1992)/Bram Stokers Dracula (1992) {tmdb-6114} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-BluDragon.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Captain America Civil War (2016)/Captain America Civil War (2016) {tmdb-271110} - [Bluray-2160p][EAC3 7.1][DV HDR10][x265]-HONE.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Furious 7 (2015)/Furious 7 (2015) {tmdb-168259} - {edition-Extended} [Bluray-2160p][DTS-HD HRA 7.1][HDR10][x265]-CtrlHD.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Interstellar (2014)/Interstellar (2014) {tmdb-157336} - [Bluray-2160p][DTS-HD MA 5.1][HDR10][x265]-TERMiNAL.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Iron Man 3 (2013)/Iron Man 3 (2013) {tmdb-68721} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Avengers Age of Ultron (2015)/Avengers Age of Ultron (2015) {tmdb-99861} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-Absinth.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Indiana Jones and the Kingdom of the Crystal Skull (2008)/Indiana Jones and the Kingdom of the Crystal Skull (2008) {tmdb-217} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-10bit-HDS.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Suicide Squad (2021)/The Suicide Squad (2021) {tmdb-436969} - [Bluray-2160p][AC3 5.1][HDR10Plus][x265]-BHDStudio.mp4" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Hacksaw Ridge (2016)/Hacksaw Ridge (2016) {tmdb-324786} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-TERMiNAL.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Ghostbusters (1984)/Ghostbusters (1984) {tmdb-620} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Lost World Jurassic Park (1997)/The Lost World Jurassic Park (1997) {tmdb-330} - [Bluray-2160p][AC3 5.1][HDR10][x265]-BHDStudio.mp4" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Spider-Man No Way Home (2021)/Spider-Man No Way Home (2021) {tmdb-634649} - [WEBDL-2160p][AC3 5.1][h265].mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Close Encounters of the Third Kind (1977)/Close Encounters of the Third Kind (1977) {tmdb-840} - {edition-Directors Cut} [Bluray-2160p][AC3 5.1][DV HDR10][x265]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Jungle Cruise (2021)/Jungle Cruise (2021) {tmdb-451048} - [Bluray-2160p][AC3 5.1][HDR10][x265]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/War for the Planet of the Apes (2017)/War for the Planet of the Apes (2017) {tmdb-281338} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-Absinth.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Indiana Jones and the Temple of Doom (1984)/Indiana Jones and the Temple of Doom (1984) {tmdb-87} - [Bluray-2160p][AC3 5.1][HDR10][x265]-seskapile.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Uncharted (2022)/Uncharted (2022) {tmdb-335787} - [WEBDL-2160p][EAC3 Atmos 5.1][h265].mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Lord of the Rings The Two Towers (2002)/The Lord of the Rings The Two Towers (2002) {tmdb-121} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][h265].mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/The Hunger Games Mockingjay Part 2 (2015)/The Hunger Games Mockingjay Part 2 (2015) {tmdb-131634} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Alien Romulus (2024)/Alien Romulus (2024) {tmdb-945961} - [WEBDL-2160p][EAC3 Atmos 5.1][DV HDR10Plus][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/The Hunger Games (2012)/The Hunger Games (2012) {tmdb-70160} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Avatar The Way of Water (2022)/Avatar The Way of Water (2022) {tmdb-76600} - [WEBDL-2160p][EAC3 Atmos 5.1][h265].mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Gladiator (2000)/Gladiator (2000) {tmdb-98} - {edition-Extended} [Remux-2160p][DTS-X 7.1][HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Jurassic Park (1993)/Jurassic Park (1993) {tmdb-329} - [Bluray-2160p][AC3 5.1][HDR10][x265]-BHDStudio.mp4" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Avengers Infinity War (2018)/Avengers Infinity War (2018) {tmdb-299536} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Star Trek First Contact (1996)/Star Trek First Contact (1996) {tmdb-199} - [WEBDL-2160p][EAC3 5.1][x265]-ABBiE.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Apocalypse Now (1979)/Apocalypse Now (1979) {tmdb-28} - [Bluray-2160p][TrueHD 5.1][HDR10][x265]-JustWatch.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Heat (1995)/Heat (1995) {tmdb-949} - {edition-Directors} [WEBDL-2160p][DTS-HD MA 5.1][HDR10][HEVC]-BLUTONiUM.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Matrix Revolutions (2003)/The Matrix Revolutions (2003) {tmdb-605} - [Bluray-2160p][EAC3 5.1][HDR10][x265]-d3g.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Deadpool (2016)/Deadpool (2016) {tmdb-293660} - [Hybrid][Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-SEV.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Matrix Reloaded (2003)/The Matrix Reloaded (2003) {tmdb-604} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Star Trek II The Wrath of Khan (1982)/Star Trek II The Wrath of Khan (1982) {tmdb-154} - {edition-Director's Cut} [Bluray-2160p][AC3 5.1][HDR10][x265]-BHDStudio.mp4" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Deadpool 2 (2018)/Deadpool 2 (2018) {tmdb-383498} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-MainFrame.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Passengers (2016)/Passengers (2016) {tmdb-274870} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Black Panther Wakanda Forever (2022)/Black Panther Wakanda Forever (2022) {tmdb-505642} - [Bluray-2160p][EAC3 7.1][DV HDR10][x265]-HONE.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Return of the Jedi (1983)/Return of the Jedi (1983) {tmdb-1892} - [Hybrid][Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-HiDt.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Wonder Woman 1984 (2020)/Wonder Woman 1984 (2020) {tmdb-464052} - [HMAX][WEBDL-2160p][EAC3 Atmos 5.1][HDR10][HEVC]-TOMMY.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/The Matrix (1999)/The Matrix (1999) {tmdb-603} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Red Sparrow (2018)/Red Sparrow (2018) {tmdb-401981} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-WhiteRhino.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/2001 A Space Odyssey (1968)/2001 A Space Odyssey (1968) {tmdb-62} - [Remux-2160p Proper][DTS-HD MA 5.1][HDR10][HEVC]-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Black Widow (2021)/Black Widow (2021) {tmdb-497698} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-HDChina.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"


# === COPY BETTER QUALITY FILES ===

# Ali has better: Mission Impossible The Final Reckoning (2025)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mission Impossible The Final Reckoning (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Matrix Resurrections (2021)
# Score: Ali=7200 vs Chris=6692
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Matrix Resurrections (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: V for Vendetta (2006)
# Score: Ali=7700 vs Chris=7600
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/V for Vendetta (2006)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Earth One Amazing Day (2017)
# Score: Ali=7700 vs Chris=7600
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Earth One Amazing Day (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Solo A Star Wars Story (2018)
# Score: Ali=7200 vs Chris=7100
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Solo A Star Wars Story (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek Insurrection (1998)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek Insurrection (1998)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Lion King (1994)
# Score: Ali=7190 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Lion King (1994)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Pitch Black (2000)
# Score: Ali=7700 vs Chris=7000
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Pitch Black (2000)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Lord of the Rings The Fellowship of the Ring (2001)
# Score: Ali=7700 vs Chris=7600
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Lord of the Rings The Fellowship of the Ring (2001)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek IV The Voyage Home (1986)
# Score: Ali=6806 vs Chris=6637
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek IV The Voyage Home (1986)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Iron Man 2 (2010)
# Score: Ali=7200 vs Chris=7099
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Iron Man 2 (2010)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Pulp Fiction (1994)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Pulp Fiction (1994)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Blade (1998)
# Score: Ali=7200 vs Chris=7100
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Blade (1998)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Dark Knight (2008)
# Score: Ali=7650 vs Chris=7500
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Dark Knight (2008)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Dark Knight Rises (2012)
# Score: Ali=7600 vs Chris=7500
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Dark Knight Rises (2012)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Pacific Rim (2013)
# Score: Ali=7172 vs Chris=6651
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Pacific Rim (2013)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Bohemian Rhapsody (2018)
# Score: Chris=7600 vs Ali=7100
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Bohemian Rhapsody (2018)" "/mnt/unraid/media/4K Movies/"

# Ali has better: The Fantastic 4 First Steps (2025)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Fantastic 4 First Steps (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Inception (2010)
# Score: Ali=7100 vs Chris=6300
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Inception (2010)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Superman (2025)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Superman (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Mission Impossible Fallout (2018)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mission Impossible Fallout (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Lion King (2019)
# Score: Ali=6788 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Lion King (2019)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Avengers (2012)
# Score: Ali=7700 vs Chris=7600
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Avengers (2012)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Venom The Last Dance (2024)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Venom The Last Dance (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Lord of the Rings The Return of the King (2003)
# Score: Ali=7700 vs Chris=7600
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Lord of the Rings The Return of the King (2003)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Alien (1979)
# Score: Ali=7500 vs Chris=6500
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Alien (1979)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Kingdom of Heaven (2005)
# Score: Ali=7200 vs Chris=6215
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Kingdom of Heaven (2005)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Extraction 2 (2023)
# Score: Ali=6670 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Extraction 2 (2023)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Army of the Dead (2021)
# Score: Ali=6660 vs Chris=6383
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Army of the Dead (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Captain America The First Avenger (2011)
# Score: Ali=7200 vs Chris=7094
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Captain America The First Avenger (2011)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Phantom of the Opera (2004)
# Score: Ali=7500 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Phantom of the Opera (2004)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Ghostbusters Afterlife (2021)
# Score: Chris=6530 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Ghostbusters Afterlife (2021)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Coco (2017)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Coco (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Godzilla x Kong The New Empire (2024)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Godzilla x Kong The New Empire (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Wicked (2024)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Wicked (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: The Outfit (2022)
# Score: Chris=6110 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Outfit (2022)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Dunkirk (2017)
# Score: Ali=7099 vs Chris=6792
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Dunkirk (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek Nemesis (2002)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek Nemesis (2002)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: The Hunger Games Catching Fire (2013)
# Score: Chris=7700 vs Ali=7200
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Hunger Games Catching Fire (2013)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Thunderbolts- (2025)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Thunderbolts- (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Constantine (2005)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Constantine (2005)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: The Hunger Games Mockingjay Part 1 (2014)
# Score: Chris=7700 vs Ali=7200
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Hunger Games Mockingjay Part 1 (2014)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Captain Marvel (2019)
# Score: Chris=7600 vs Ali=7200
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Captain Marvel (2019)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Thor Ragnarok (2017)
# Score: Ali=7200 vs Chris=7100
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Thor Ragnarok (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Zombieland (2009)
# Score: Ali=7200 vs Chris=7040
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Zombieland (2009)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Captain America Brave New World (2025)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Captain America Brave New World (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Tenet (2020)
# Score: Ali=7100 vs Chris=7000
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Tenet (2020)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: 300 (2007)
# Score: Ali=7700 vs Chris=7600
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/300 (2007)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Spy Who Loved Me (1977)
# Score: Ali=5774 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Spy Who Loved Me (1977)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Fifth Element (1997)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Fifth Element (1997)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek Generations (1994)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek Generations (1994)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: King Kong vs. Godzilla (1962)
# Score: Chris=7100 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/King Kong vs. Godzilla (1962)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Rise of the Planet of the Apes (2011)
# Score: Ali=6830 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Rise of the Planet of the Apes (2011)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Raiders of the Lost Ark (1981)
# Score: Ali=7200 vs Chris=7065
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Raiders of the Lost Ark (1981)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Avengers Endgame (2019)
# Score: Ali=7700 vs Chris=7600
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Avengers Endgame (2019)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Pirates of the Caribbean The Curse of the Black Pearl (2003)
# Score: Chris=6293 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Pirates of the Caribbean The Curse of the Black Pearl (2003)" "/mnt/unraid/media/4K Movies/"

# Ali has better: The Predator (2018)
# Score: Ali=7700 vs Chris=7600
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Predator (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Star Trek The Motion Picture (1979)
# Score: Chris=7700 vs Ali=6800
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Star Trek The Motion Picture (1979)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Furiosa A Mad Max Saga (2024)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Furiosa A Mad Max Saga (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Greatest Showman (2017)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Greatest Showman (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Star Wars (1977)
# Score: Chris=7700 vs Ali=7200
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Star Wars (1977)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Mortal Kombat (2021)
# Score: Chris=7200 vs Ali=7100
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Mortal Kombat (2021)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Braveheart (1995)
# Score: Ali=7200 vs Chris=7100
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Braveheart (1995)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Black Adam (2022)
# Score: Ali=7200 vs Chris=6700
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Black Adam (2022)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Logan (2017)
# Score: Ali=7095 vs Chris=7048
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Logan (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Godzilla (2014)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Godzilla (2014)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: What Happened to Monday (2017)
# Score: Ali=7050 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/What Happened to Monday (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Batman Begins (2005)
# Score: Ali=7600 vs Chris=7500
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Batman Begins (2005)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Joker (2019)
# Score: Chris=7600 vs Ali=7100
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Joker (2019)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Ad Astra (2019)
# Score: Chris=7700 vs Ali=7200
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Ad Astra (2019)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Rocketman (2019)
# Score: Chris=7087 vs Ali=6803
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Rocketman (2019)" "/mnt/unraid/media/4K Movies/"

# Ali has better: The Godfather (1972)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Godfather (1972)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Brotherhood of the Wolf (2001)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Brotherhood of the Wolf (2001)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Deadpool and Wolverine (2024)
# Score: Ali=7200 vs Chris=6700
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Deadpool and Wolverine (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek Into Darkness (2013)
# Score: Ali=7700 vs Chris=7600
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek Into Darkness (2013)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Twister (1996)
# Score: Ali=7200 vs Chris=4800
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Twister (1996)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Shazam! Fury of the Gods (2023)
# Score: Chris=7700 vs Ali=7200
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Shazam! Fury of the Gods (2023)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Guardians of the Galaxy (2014)
# Score: Ali=7200 vs Chris=7048
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Guardians of the Galaxy (2014)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: War of the Worlds (2005)
# Score: Chris=7300 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/War of the Worlds (2005)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Tron (1982)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Tron (1982)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Spider-Man Homecoming (2017)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Spider-Man Homecoming (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Hunt for Red October (1990)
# Score: Ali=7150 vs Chris=7050
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Hunt for Red October (1990)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Mummy Returns (2001)
# Score: Ali=7000 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Mummy Returns (2001)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Mad Max Fury Road (2015)
# Score: Ali=7700 vs Chris=7600
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mad Max Fury Road (2015)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Terminator (1984)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Terminator (1984)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Jaws (1975)
# Score: Chris=7600 vs Ali=7100
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Jaws (1975)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Dune (2021)
# Score: Chris=7700 vs Ali=7200
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Dune (2021)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Star Trek VI The Undiscovered Country (1991)
# Score: Chris=7050 vs Ali=6795
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Star Trek VI The Undiscovered Country (1991)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Independence Day (1996)
# Score: Chris=7500 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Independence Day (1996)" "/mnt/unraid/media/4K Movies/"

# Ali has better: The Wizard of Oz (1939)
# Score: Ali=7600 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Wizard of Oz (1939)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: John Wick Chapter 2 (2017)
# Score: Chris=7600 vs Ali=7200
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/John Wick Chapter 2 (2017)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Guardians of the Galaxy Vol. 2 (2017)
# Score: Ali=7200 vs Chris=7077
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Guardians of the Galaxy Vol. 2 (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Fast and Furious 6 (2013)
# Score: Chris=7500 vs Ali=7000
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Fast and Furious 6 (2013)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Warfare (2025)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Warfare (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Star Trek V The Final Frontier (1989)
# Score: Chris=7050 vs Ali=6790
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Star Trek V The Final Frontier (1989)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Iron Man (2008)
# Score: Ali=7200 vs Chris=7072
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Iron Man (2008)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Godfather Part II (1974)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Godfather Part II (1974)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Cars 3 (2017)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Cars 3 (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: John Wick (2014)
# Score: Ali=7200 vs Chris=7092
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/John Wick (2014)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Top Gun (1986)
# Score: Chris=6800 vs Ali=6794
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Top Gun (1986)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Wonder Woman (2017)
# Score: Ali=7200 vs Chris=7100
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Wonder Woman (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Prey (2022)
# Score: Chris=5842 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Prey (2022)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Thor The Dark World (2013)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Thor The Dark World (2013)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Terminator 2 Judgment Day (1991)
# Score: Ali=6800 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Terminator 2 Judgment Day (1991)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Twisters (2024)
# Score: Ali=7200 vs Chris=6700
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Twisters (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek III The Search for Spock (1984)
# Score: Ali=6788 vs Chris=6621
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek III The Search for Spock (1984)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Extraction (2020)
# Score: Ali=6630 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Extraction (2020)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Revenant (2015)
# Score: Ali=7700 vs Chris=7500
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Revenant (2015)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Blade Runner 2049 (2017)
# Score: Ali=7600 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Blade Runner 2049 (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Jurassic World Dominion (2022)
# Score: Chris=6300 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Jurassic World Dominion (2022)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Top Gun Maverick (2022)
# Score: Ali=7200 vs Chris=6700
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Top Gun Maverick (2022)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Bram Stokers Dracula (1992)
# Score: Ali=7700 vs Chris=7600
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Bram Stokers Dracula (1992)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Zombieland Double Tap (2019)
# Score: Ali=7076 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Zombieland Double Tap (2019)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Captain America Civil War (2016)
# Score: Ali=7100 vs Chris=6850
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Captain America Civil War (2016)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Furious 7 (2015)
# Score: Chris=7500 vs Ali=6950
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Furious 7 (2015)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Interstellar (2014)
# Score: Ali=7100 vs Chris=7000
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Interstellar (2014)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Resident Evil Welcome to Raccoon City (2021)
# Score: Chris=6164 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Resident Evil Welcome to Raccoon City (2021)" "/mnt/unraid/media/4K Movies/"

# Ali has better: TRON Ares (2025)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/TRON Ares (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Iron Man 3 (2013)
# Score: Ali=7187 vs Chris=7068
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Iron Man 3 (2013)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Avengers Age of Ultron (2015)
# Score: Ali=7700 vs Chris=7065
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Avengers Age of Ultron (2015)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Northman (2022)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Northman (2022)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Mission Impossible Rogue Nation (2015)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mission Impossible Rogue Nation (2015)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Indiana Jones and the Kingdom of the Crystal Skull (2008)
# Score: Ali=7200 vs Chris=7095
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Indiana Jones and the Kingdom of the Crystal Skull (2008)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek Beyond (2016)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek Beyond (2016)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Cars (2006)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Cars (2006)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Doctor Strange in the Multiverse of Madness (2022)
# Score: Chris=6300 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Doctor Strange in the Multiverse of Madness (2022)" "/mnt/unraid/media/4K Movies/"

# Ali has better: The Suicide Squad (2021)
# Score: Ali=7200 vs Chris=6653
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Suicide Squad (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Hacksaw Ridge (2016)
# Score: Ali=7200 vs Chris=7071
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Hacksaw Ridge (2016)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Venom Let There Be Carnage (2021)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Venom Let There Be Carnage (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Ghostbusters (1984)
# Score: Ali=7700 vs Chris=7600
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Ghostbusters (1984)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Lost World Jurassic Park (1997)
# Score: Ali=7200 vs Chris=6648
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Lost World Jurassic Park (1997)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Venom (2018)
# Score: Ali=7190 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Venom (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Mission Impossible Ghost Protocol (2011)
# Score: Ali=7050 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mission Impossible Ghost Protocol (2011)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Spider-Man No Way Home (2021)
# Score: Ali=7200 vs Chris=5500
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Spider-Man No Way Home (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Close Encounters of the Third Kind (1977)
# Score: Chris=6946 vs Ali=6759
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Close Encounters of the Third Kind (1977)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Jungle Cruise (2021)
# Score: Chris=7700 vs Ali=6646
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Jungle Cruise (2021)" "/mnt/unraid/media/4K Movies/"

# Ali has better: War for the Planet of the Apes (2017)
# Score: Ali=7196 vs Chris=7100
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/War for the Planet of the Apes (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Indiana Jones and the Temple of Doom (1984)
# Score: Ali=7200 vs Chris=6700
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Indiana Jones and the Temple of Doom (1984)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Pacific Rim Uprising (2018)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Pacific Rim Uprising (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Uncharted (2022)
# Score: Ali=7200 vs Chris=5900
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Uncharted (2022)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Oblivion (2013)
# Score: Chris=7600 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Oblivion (2013)" "/mnt/unraid/media/4K Movies/"

# Ali has better: The Lord of the Rings The Two Towers (2002)
# Score: Ali=7700 vs Chris=7600
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Lord of the Rings The Two Towers (2002)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: The Hunger Games Mockingjay Part 2 (2015)
# Score: Chris=7700 vs Ali=7200
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Hunger Games Mockingjay Part 2 (2015)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Blade II (2002)
# Score: Ali=6600 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Blade II (2002)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Alien Romulus (2024)
# Score: Ali=7200 vs Chris=6700
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Alien Romulus (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: The Hunger Games (2012)
# Score: Chris=7700 vs Ali=7200
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Hunger Games (2012)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Cars 2 (2011)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Cars 2 (2011)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Avatar The Way of Water (2022)
# Score: Ali=7100 vs Chris=5900
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Avatar The Way of Water (2022)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Gladiator (2000)
# Score: Ali=7600 vs Chris=7500
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Gladiator (2000)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Spider-Man Far From Home (2019)
# Score: Ali=7189 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Spider-Man Far From Home (2019)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Thor (2011)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Thor (2011)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Eternals (2021)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Eternals (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Mission Impossible III (2006)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mission Impossible III (2006)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Forrest Gump (1994)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Forrest Gump (1994)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Ten Commandments (1956)
# Score: Ali=7600 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Ten Commandments (1956)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Jurassic Park (1993)
# Score: Ali=7200 vs Chris=6644
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Jurassic Park (1993)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Avengers Infinity War (2018)
# Score: Ali=7700 vs Chris=7600
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Avengers Infinity War (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Life of Pi (2012)
# Score: Ali=7500 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Life of Pi (2012)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek First Contact (1996)
# Score: Ali=7150 vs Chris=5453
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek First Contact (1996)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Guardians of the Galaxy Vol. 3 (2023)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Guardians of the Galaxy Vol. 3 (2023)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: TRON Legacy (2010)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/TRON Legacy (2010)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Apocalypse Now (1979)
# Score: Ali=7200 vs Chris=7050
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Apocalypse Now (1979)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Heat (1995)
# Score: Ali=7500 vs Chris=6500
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Heat (1995)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Godfather Part III (1990)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Godfather Part III (1990)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Matrix Revolutions (2003)
# Score: Ali=7200 vs Chris=6750
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Matrix Revolutions (2003)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Deadpool (2016)
# Score: Chris=7600 vs Ali=7200
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Deadpool (2016)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Kingdom of the Planet of the Apes (2024)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Kingdom of the Planet of the Apes (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Godzilla vs. Kong (2021)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Godzilla vs. Kong (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Shawshank Redemption (1994)
# Score: Ali=6817 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Shawshank Redemption (1994)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Lawrence of Arabia (1962)
# Score: Ali=7600 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Lawrence of Arabia (1962)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Matrix Reloaded (2003)
# Score: Ali=7200 vs Chris=7100
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Matrix Reloaded (2003)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek II The Wrath of Khan (1982)
# Score: Ali=6799 vs Chris=6634
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek II The Wrath of Khan (1982)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Deadpool 2 (2018)
# Score: Chris=7600 vs Ali=7100
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Deadpool 2 (2018)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Gladiator II (2024)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Gladiator II (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Passengers (2016)
# Score: Ali=7700 vs Chris=7600
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Passengers (2016)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Black Panther Wakanda Forever (2022)
# Score: Ali=7200 vs Chris=6850
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Black Panther Wakanda Forever (2022)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Super Mario Bros. Movie (2023)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Super Mario Bros. Movie (2023)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Return of the Jedi (1983)
# Score: Chris=7600 vs Ali=7200
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Return of the Jedi (1983)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Civil War (2024)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Civil War (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Wonder Woman 1984 (2020)
# Score: Ali=7200 vs Chris=6597
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Wonder Woman 1984 (2020)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: The Matrix (1999)
# Score: Chris=7600 vs Ali=7200
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Matrix (1999)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Frankenstein (2025)
# Score: Ali=6700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Frankenstein (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Mission Impossible II (2000)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mission Impossible II (2000)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Godzilla Minus One (2023)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Godzilla Minus One (2023)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Indiana Jones and the Dial of Destiny (2023)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Indiana Jones and the Dial of Destiny (2023)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Red Sparrow (2018)
# Score: Ali=7200 vs Chris=7041
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Red Sparrow (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Doctor Strange (2016)
# Score: Chris=7700 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Doctor Strange (2016)" "/mnt/unraid/media/4K Movies/"

# Ali has better: 2001 A Space Odyssey (1968)
# Score: Ali=7600 vs Chris=7500
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/2001 A Space Odyssey (1968)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Dawn of the Planet of the Apes (2014)
# Score: Ali=6803 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Dawn of the Planet of the Apes (2014)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Willy Wonka and the Chocolate Factory (1971)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Willy Wonka and the Chocolate Factory (1971)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Black Widow (2021)
# Score: Ali=7200 vs Chris=7100
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Black Widow (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Zack Snyders Justice League (2021)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Zack Snyders Justice League (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Alien (1979)
# Score: Chris=5900 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Alien (1979)" "/mnt/unraid/media/4K Movies/"

