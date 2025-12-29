#!/bin/bash
#==============================================================================
# Project Mother Sync Script
# RUN THIS ON MOTHER (10.0.0.162)
#==============================================================================
# Generated: 2025-12-29 09:59:49
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
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/1917 (2019)/1917.2019.2160p.UHD.Blu-ray.Atmos.x265 - HQMUX.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Dracula (1992)/Bram Stoker's Dracula 1992 2160p UHD Blu-Ray Remux HEVC Atmos - BluDragon.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Return of the Jedi (1983)/Return of the Jedi (1983) Remux-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Interstellar (2014)/Interstellar.2014.2160p.UHD.BluRay.x265-TERMiNAL.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Star Trek VI The Undiscovered Country (1991)/Star Trek VI The Undiscovered Country (1991) Bluray-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Passengers (2016)/Passengers.2016.2160p.UHD.BluRay.REMUX.HDR.HEVC.Atmos-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Revenant (2015)/The.Revenant.2015.UHD.BluRay.2160p.DTS-HD.MA.7.1.HEVC.REMUX-FraMeSToR-AsRequested.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Earth One Amazing Day (2017)/Earth.One.Amazing.Day.2017.2160p.UHD.BluRay.REMUX.HDR.HEVC.Atmos-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Empire Strikes Back (1980)/The Empire Strikes Back (1980) Bluray-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Rocketman (2019)/Rocketman 2019 2160p UHD Blu-ray HEVC Atmos x265 - SumVision.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Spider-Man No Way Home (2021)/Spider-Man No Way Home (2021) WEBDL-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Kingdom of Heaven (2005)/Kingdom of Heaven (2005) {imdb-tt0320661} {edition-Theatrical} [WEBDL-2160p][HDR10][EAC3 5.1][h265]-SMURF.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Dunkirk (2017)/Dunkirk 2017 2160p UHD BluRay HDR DTS x265-SadeceBluRay.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Black Widow (2021)/Black.Widow.2021.2160p.UHD.BluRay.HDR.x265.Atmos.TrueHD7.1-HDChina.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Dark Knight (2008)/The Dark Knight 2008 2160p UHD Blu-ray Remux HEVC DTS-HD MA 5.1 - BluDragon.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Indiana Jones and the Temple of Doom (1984)/indiana.jones.and.the.temple.of.doom.1984.2160p.uhd.bluray.x265-seskapile.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Fast & Furious 6 (2013)/Fast & Furious 6 (2013) Remux-2160p Proper.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Jurassic Park (1993)/Jurassic.Park.1993.UHD.BluRay.2160p.DD.5.1.HDR.x265-BHDStudio.mp4" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Guardians of the Galaxy Vol. 2 (2017)/Guardians.of.the.Galaxy.Vol.2.2017.2160p.UHD.BluRay.x265-TERMiNAL.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Martian (2015)/The.Martian.2015.EXTENDED.2160p.BluRay.x265.10bit.HDR.TrueHD.7.1.Atmos-TERMiNAL.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Kong Skull Island (2017)/Kong.Skull Island.2017.2160p.UHD.BluRay.TrueHD7.1.Atmos.x265-HQMUX.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Indiana Jones and the Last Crusade (1989)/Indiana Jones and the Last Crusade (1989) Remux-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Hunger Games Mockingjay - Part 2 (2015)/The Hunger Games Mockingjay - Part 2 (2015) Remux-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Raiders of the Lost Ark (1981)/Raiders.Of.The.Lost.Ark.1981.2160p.UHD.Bluray.x265.HDR10.Atmos.TrueHD.7.1-4K4U.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Twisters (2024)/Twisters (2024) {imdb-tt12584954} [WEBDL-2160p][DV HDR10Plus][EAC3 Atmos 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Ready Player One (2018)/Ready Player One.2018.2160p.UHD.BluRay.TrueHD7.1.Atmos.x265-HQMUX.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Star Trek V The Final Frontier (1989)/Star Trek V The Final Frontier (1989) Bluray-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Star Trek III The Search for Spock (1984)/Star.Trek.III.The.Search.for.Spock.1984.UHD.BluRay.2160p.DD.5.1.HDR.x265-BHDStudio.mp4" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/John Wick Chapter 3 Parabellum (2019)/John.Wick.Chapter.3.Parabellum.2019.2160p.UHD.BluRay.TrueHD.7.1.HDR.x265-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Star Trek First Contact (1996)/Star.Trek.VIII.First.Contact.1996.2160p.WEB-DL.DDP5.1.H.265-ABBiE.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Indiana Jones and the Kingdom of the Crystal Skull (2008)/Indiana.Jones.and.the.Kingdom.of.the.Crystal.Skull.2008.2160p.HDR.UHD.BluRay.TrueHD.7.1.Atmos.2Audio.x265-10bit-HDS.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Bohemian Rhapsody (2018)/Bohemian Rhapsody (2018) Remux-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Apollo 13 (1995)/Apollo 13 (1995) Remux-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Captain America Civil War (2016)/Captain America - Civil War (2016) (2160p UHD BluRay x265 DV HDR DDP 7.1 English - Weasley HONE).mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Star Trek (2009)/Star.Trek.2009.2160p.UHD.BluRay.X265-IAMABLE.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Top Gun Maverick (2022)/Top Gun Maverick (2022) WEBDL-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Hacksaw Ridge (2016)/Hacksaw.Ridge.2016.2160p.UHD.BluRay.x265-TERMiNAL.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Dune (2021)/Dune (2021) Remux-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Black Panther Wakanda Forever (2022)/Black Panther Wakanda Forever (2022) {imdb-tt9114286} [Bluray-2160p][DV HDR10][EAC3 7.1][x265]-HONE.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/John Wick (2014)/John.Wick.2014.2160p.UHD.BluRay.HDR.TrueHD.Atmos.7.1.x265-Absinth.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Guardians of the Galaxy (2014)/Guardians.Of.The.Galaxy.2014.2160p.UHD.BluRay.TrueHD.7.1.HDR.x265-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Alien Romulus (2024)/Alien Romulus (2024) {imdb-tt18412256} [WEBDL-2160p][DV HDR10Plus][EAC3 Atmos 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Hobbit An Unexpected Journey (2012)/The.Hobbit.An.Unexpected.Journey.2012.Extended.Cut.UHD.BluRay.2160p.TrueHD.Atmos.7.1.DV.HEVC.REMUX-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Braveheart (1995)/Braveheart.1995.2160p.UHD.BluRay.X265-IAMABLE.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Iron Man 3 (2013)/Iron.Man.3.2013.2160p.UHD.BluRay.TrueHD.7.1.HDR.x265-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/300 (2006)/300.2006.UHD.BluRay.2160p.TrueHD.Atmos.7.1.HEVC.REMUX-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Hobbit The Desolation of Smaug (2013)/The.Hobbit.The.Desolation.of.Smaug.2013.Extended.Cut.UHD.BluRay.2160p.TrueHD.Atmos.7.1.DV.HEVC.REMUX-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Mad Max Fury Road (2015)/Mad Max Fury Road 2015 2160p UHD Blu-ray Remux HEVC Atmos 7.1 - BluDragon.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Jaws (1975)/Jaws.1975.UHD.BluRay.2160p.TrueHD.Atmos.7.1.HEVC.REMUX-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Ad Astra (2019)/Ad Astra (2019) Remux-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Edge of Tomorrow (2014)/Edge of Tomorrow.2014.2160p.UHD.BluRay.HDR.DoVi.TrueHD 7.1.Atmos.x265-SPHD.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Matrix Reloaded (2003)/The.Matrix.Reloaded.2003.2160p.UHD.BluRay.TrueHD.7.1.HDR.x265-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Star Trek Into Darkness (2013)/Star.Trek.Into.Darkness.2013.2160p.UHD.BluRay.REMUX.HDR.HEVC.Atmos-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Close Encounters of the Third Kind (1977)/Close Encounters of the Third Kind (1977) {tmdb-840} - {edition-Directors Cut} [Bluray-2160p][AC3 5.1][DV HDR10][x265]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Ghostbusters (1984)/Ghostbusters.1984.2160p.UHD.BluRay.REMUX.HDR.HEVC.Atmos-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Furious 7 (2015)/Furious 7 (2015) Remux-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Blade (1998)/Blade (1998) Bluray-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Hunger Games (2012)/The Hunger Games (2012) Remux-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Tenet (2020)/Tenet (2020) {imdb-tt6723592} [Bluray-2160p Proper][HDR10][DTS-HD MA 5.1][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Captain Marvel (2019)/Captain Marvel (2019) Remux-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Gladiator (2000)/Gladiator.2000.Extended.UHD.BluRay.2160p.DTS-X.7.1.HEVC.REMUX-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Pitch Black (2000)/Pitch.Black.2000.Directors.Cut.REPACK.2160p.UHD.BluRay.DTS-HD.MA.5.1.HDR.x265-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Hobbit The Battle of the Five Armies (2014)/The.Hobbit.The.Battle.of.the.Five.Armies.2014.Extended.Cut.UHD.BluRay.2160p.TrueHD.Atmos.7.1.DV.HEVC.REMUX-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Avatar The Way of Water (2022)/Avatar The Way of Water (2022) WEBDL-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Captain America The First Avenger (2011)/Captain.America.The.First.Avenger.2011.2160p.UHD.BluRay.HDR.Atmos.x265-Absinth.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Zombieland (2009)/Zombieland.2009.2160p.UHD.BluRay.X265-IAMABLE.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Thor Ragnarok (2017)/Thor Ragnarok 2017 2160p UHD HDR10+ BluRay x265 TrueHD Atmos 7 1-UnKn0wn.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Predator (2018)/The Predator 2018 2160p UHD Blu-ray Remux HEVC Atmos 7.1 - BluDragon.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Avengers Infinity War (2018)/Avengers.Infinity.War.2018.2160p.UHD.BluRay.REMUX.HDR.HEVC.Atmos-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/John Wick Chapter 2 (2017)/John Wick Chapter 2 (2017) {tmdb-324552} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-SPHD.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Star Wars (1977)/Star Wars (1977) Remux-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Star Trek IV The Voyage Home (1986)/Star.Trek.IV.The.Voyage.Home.1986.UHD.BluRay.2160p.DD.5.1.HDR.x265-BHDStudio.mp4" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Top Gun (1986)/Top Gun (1986) {tmdb-744} - [Bluray-2160p][EAC3 7.1][DV HDR10][x265]-hallowed.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Alien (1979)/Alien.1979.2160p.Director.Cut.UHD.HDR10+Remux.DTS-HD.MA5.1-SHD.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Deadpool (2016)/Deadpool (2016) Remux-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Shazam! Fury of the Gods (2023)/Shazam! Fury of the Gods (2023) Remux-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Deadpool 3 (2024)/Deadpool and Wolverine (2024) {imdb-tt6263850} [WEBDL-2160p][DV HDR10Plus][EAC3 Atmos 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Jungle Cruise (2021)/Jungle Cruise (2021) {tmdb-451048} - [Bluray-2160p][AC3 5.1][HDR10][x265]-BHDStudio.mp4" "/mnt/unraid/media/Deleted Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/E.T. the Extra-Terrestrial (1982)/E.T.the.Extra-Terrestrial.1982.2160p.UHD.BluRay.x265-DEPTH.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Captain America The Winter Soldier (2014)/Captain.America.The.Winter.Soldier.2014.UHD.BluRay.HDR10.2160p.AC-3.TrueHD.7.1.Atmos.HEVC-d3g.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Batman Begins (2005)/Batman.Begins.2005.2160p.UHD.BluRay.REMUX.HDR.HEVC.DTS-HD.MA.5.1-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Matrix Revolutions (2003)/The.Matrix-Revolutions.2003.UHD.BluRay.HDR.10Bit.2160p.DD.5.1.H265-d3g.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Heat (1995)/Heat.1995.Directors.Definitive.Edition.2160p.HDR.WEB-DL.DTS-HD.MA.5.1.HEVC-BLUTONiUM.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Black Adam (2022)/Black Adam (2022) WEBDL-2160p Proper.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Solo A Star Wars Story (2018)/Solo A Star Wars Story (2018) {imdb-tt3778644} [Bluray-2160p Proper][HDR10][TrueHD Atmos 7.1][x265]-TnP.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Lord of the Rings The Fellowship of the Ring (2001)/The Lord of the Rings The Fellowship of the Ring (2001) Remux-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Alita Battle Angel (2019)/Alita Battle Angel 2019 REPACK 2160p UHD BluRay HDR10+ TrueHD Atmos 7.1 x265-DON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Star Trek II The Wrath of Khan (1982)/Star.Trek.II.The.Wrath.of.Khan.1982.Director's.Cut.UHD.BluRay.2160p.DD.5.1.HDR.x265-BHDStudio.mp4" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Apocalypse Now (1979)/Apocalypse.Now.1979.Redux.2160p.UHD.BluRay.x265-JustWatch.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Ali's lower quality version
run_cmd mv "/mnt/unraid/media/4K Movies/Mortal Kombat (2021)/Mortal Kombat (2021) {tmdb-460465} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-HQMUX.mkv" "/mnt/unraid/media/Deleted Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Pacific Rim (2013)/Pacific.Rim.2013.UHD.BluRay.2160p.DD.5.1.HDR.x265-BHDStudio.mp4" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Inception (2010)/Inception.2010.2160p.UHD.BluRay.x265-TERMiNAL.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Blade Runner (1982)/Blade.Runner.1982.The.Final.Cut.2160p.UHD.BluRay.REMUX.HDR.HEVC.Atmos-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Lord of the Rings The Return of the King (2003)/The Lord of the Rings The Return of the King (2003) Remux-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Avengers (2012)/The.Avengers.2012.REPACK.2160p.UHD.BluRay.REMUX.HDR.HEVC.Atmos-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Uncharted (2022)/Uncharted (2022) WEBDL-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Dark Knight Rises (2012)/The Dark Knight Rises 2012 2160p UHD Blu-ray Remux HEVC DTS-HD MA 5.1 - BluDragon.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Saving Private Ryan (1998)/Saving.Private.Ryan.1998.2160p.UHD.BluRay.X265-IAMABLE.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Hunger Games Mockingjay - Part 1 (2014)/The Hunger Games Mockingjay - Part 1 (2014) Remux-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Godzilla vs. Kong (2021)/Godzilla.vs.Kong.2021.2160p.UHD.BluRay.HDR.x265.Atmos.TrueHD7.1-HDChina.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/War for the Planet of the Apes (2017)/War.for.the.Planet.of.the.Apes.2017.2160p.UHD.BluRay.HDR.Atmos.x265-Absinth.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Avengers Age of Ultron (2015)/Avengers.Age.of.Ultron.2015.2160p.UHD.BluRay.HDR.Atmos.x265-Absinth.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Iron Man 2 (2010)/Iron.Man.2.2010.2160p.UHD.BluRay.HDR.Atmos.x265-Absinth.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Hunt for Red October (1990)/The Hunt for Red October.1990.2160p.UHD.BluRay.TrueHD5.1.x265-HQMUX.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Suicide Squad (2021)/The.Suicide.Squad.2021.UHD.BluRay.2160p.DD.5.1.HDR.x265-BHDStudio.mp4" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Deadpool 2 (2018)/Deadpool 2 (2018) Remux-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Hunger Games Catching Fire (2013)/The Hunger Games Catching Fire (2013) Remux-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Avengers Endgame (2019)/Avengers.Endgame.2019.2160p.UHD.BluRay.REMUX.HDR.HEVC.Atmos-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Twister (1996)/Twister (1996) Remux-1080p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Wonder Woman (2017)/Wonder.Woman.2017.2160p.UHD.BluRay.TrueHD.7.1.HDR.x265-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Matrix Resurrections (2021)/The Matrix Resurrections (2021) WEBDL-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Red Sparrow (2018)/Red.Sparrow.2018.2160p.UHD.BluRay.x265-WhiteRhino.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Total Recall (1990)/Total Recall (1990) Remux-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/V for Vendetta (2005)/V.for.Vendetta.2005.UHD.BluRay.2160p.TrueHD.Atmos.7.1.HEVC.REMUX-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Lord of the Rings The Two Towers (2002)/The Lord of the Rings The Two Towers (2002) Remux-2160p.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Iron Man (2008)/Iron.Man.2008.2160p.UHD.Bluray.x265.HDR10.Atmos.TrueHD.7.1-4K4U.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Army of the Dead (2021)/Army.of.the.Dead.2021.2160p.HDR.NF.WEBRip.DDP.Atmos.5.1.x265-TrollUHD-FZ.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Lost World Jurassic Park (1997)/The.Lost.World.Jurassic.Park.1997.UHD.BluRay.2160p.DD.5.1.HDR.x265-BHDStudio.mp4" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/2001 A Space Odyssey (1968)/2001.A.Space.Odyssey.1968.REPACK.2160p.UHD.BluRay.REMUX.HDR.HEVC.DTS-HD.MA.5.1-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/Logan (2017)/Logan.2017.2160p.UHD.BluRay.x265-TERMiNAL.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"

# Move Chris's lower quality version
run_cmd mv "/mnt/synology/rs-4kmedia/4kmovies/The Matrix (1999)/The.Matrix.1999.UHD.BluRay.2160p.TrueHD.Atmos.7.1.HEVC.REMUX-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/deleted/4K Movies/"


# === COPY BETTER QUALITY FILES ===

# Ali has better: 1917 (2019)
# Score: Ali=7100 vs Chris=5900
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/1917 (2019)/1917 (2019) {tmdb-530915} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-HQMUX.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Dracula (1992)
# Score: Ali=7700 vs Chris=6400
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Dracula (1992)/Bram Stokers Dracula (1992) {tmdb-6114} - [Remux-2160p][TrueHD Atmos 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Cars 2 (2011)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Cars 2 (2011)/Cars 2 (2011) {tmdb-49013} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Return of the Jedi (1983)
# Score: Ali=7200 vs Chris=6400
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Return of the Jedi (1983)/Return of the Jedi (1983) {tmdb-1892} - [Hybrid][Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-HiDt.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Captain America Brave New World (2025)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Captain America Brave New World (2025)/Captain America Brave New World (2025) {tmdb-822119} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10Plus][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Mummy Returns (2001)
# Score: Ali=7000 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Mummy Returns (2001)/The Mummy Returns (2001) {tmdb-1734} - [Bluray-2160p][DTS-X 7.1][HDR10][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Interstellar (2014)
# Score: Ali=7100 vs Chris=5900
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Interstellar (2014)/Interstellar (2014) {tmdb-157336} - {edition-IMAX} [Bluray-2160p][DTS-HD MA 5.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Super Mario Bros. Movie (2023)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Super Mario Bros. Movie (2023)/The Super Mario Bros. Movie (2023) {tmdb-502356} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek VI The Undiscovered Country (1991)
# Score: Ali=6795 vs Chris=5900
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek VI The Undiscovered Country (1991)/Star Trek VI The Undiscovered Country (1991) {tmdb-174} - {edition-Theatrical Cut} [Bluray-2160p][EAC3 7.1][DV HDR10][x265]-hallowed.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Passengers (2016)
# Score: Ali=7700 vs Chris=7100
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Passengers (2016)/Passengers (2016) {tmdb-274870} - [Hybrid][Remux-2160p][TrueHD Atmos 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Terminator 2 Judgment Day (1991)
# Score: Ali=6800 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Terminator 2 Judgment Day (1991)/Terminator 2 Judgment Day (1991) {tmdb-280} - {edition-Theatrical Cut} [Remux-2160p][DTS-HD MA 5.1][PQ][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Terminator 2 Judgment Day (1991)
# Score: Ali=6750 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Terminator 2 Judgment Day (1991)/Terminator 2 Judgment Day 1991 Remastered Theatrical Cut GER 2160p UHD Blu-ray Remux HEVC DTS-HD MA 5.1 - BluDragon.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Revenant (2015)
# Score: Ali=7700 vs Chris=6800
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Revenant (2015)/The Revenant (2015) {tmdb-281957} - {edition-Open Matte} [Remux-2160p][TrueHD Atmos 7.1][DV HDR10Plus][h265]-Benflix.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Earth One Amazing Day (2017)
# Score: Ali=7700 vs Chris=7100
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Earth One Amazing Day (2017)/Earth One Amazing Day (2017) {tmdb-464593} - [Remux-2160p][TrueHD Atmos 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Furiosa A Mad Max Saga (2024)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Furiosa A Mad Max Saga (2024)/Furiosa A Mad Max Saga (2024) {tmdb-786892} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10Plus][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Furiosa A Mad Max Saga (2024)
# Score: Ali=6651 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Furiosa A Mad Max Saga (2024)/Furiosa A Mad Max Saga (2024) {imdb-tt12037194} [WEBDL-2160p][DV HDR10Plus][EAC3 Atmos 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Mission Impossible II (2000)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mission Impossible II (2000)/Mission Impossible II (2000) {tmdb-955} - [Bluray-2160p][TrueHD 5.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Coco (2017)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Coco (2017)/Coco (2017) {tmdb-354912} - [Hybrid][Remux-2160p][TrueHD Atmos 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Mission Impossible Rogue Nation (2015)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mission Impossible Rogue Nation (2015)/Mission Impossible Rogue Nation (2015) {tmdb-177677} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-HQMUX.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Northman (2022)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Northman (2022)/The Northman (2022) {tmdb-639933} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Kingdom of the Planet of the Apes (2024)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Kingdom of the Planet of the Apes (2024)/Kingdom of the Planet of the Apes (2024) {tmdb-653346} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10Plus][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Venom The Last Dance (2024)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Venom The Last Dance (2024)/Venom The Last Dance (2024) {tmdb-912649} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10Plus][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Empire Strikes Back (1980)
# Score: Ali=7100 vs Chris=5900
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Empire Strikes Back (1980)/The Empire Strikes Back (1980) {tmdb-1891} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-HQMUX.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Independence Day (1996)
# Score: Chris=6400 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Independence Day (1996)/Independence Day (1996) Remux-2160p Proper.mkv" "/mnt/unraid/media/4K Movies/"

# Ali has better: Rocketman (2019)
# Score: Ali=6803 vs Chris=5887
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Rocketman (2019)/Rocketman (2019) {tmdb-504608} - [Bluray-2160p][EAC3 7.1][DV HDR10][x265]-HONE.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Spider-Man No Way Home (2021)
# Score: Ali=7200 vs Chris=5400
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Spider-Man No Way Home (2021)/Spider-Man No Way Home (2021) {tmdb-634649} - [Bluray-2160p Proper][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Kingdom of Heaven (2005)
# Score: Ali=7200 vs Chris=6215
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Kingdom of Heaven (2005)/Kingdom of Heaven (2005) {tmdb-1495} - {edition-Director's Cut} [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Dunkirk (2017)
# Score: Ali=7099 vs Chris=6792
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Dunkirk (2017)/Dunkirk (2017) {tmdb-374720} - [Bluray-2160p][DTS-HD MA 5.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Godzilla (2014)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Godzilla (2014)/Godzilla (2014) {tmdb-124905} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-HQMUX.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Black Widow (2021)
# Score: Ali=7200 vs Chris=7100
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Black Widow (2021)/Black Widow (2021) {tmdb-497698} - [Bluray-2160p Proper][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Dark Knight (2008)
# Score: Ali=7650 vs Chris=6750
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Dark Knight (2008)/The Dark Knight (2008) {tmdb-155} - [Hybrid][Remux-2160p][TrueHD 5.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Brotherhood of the Wolf (2001)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Brotherhood of the Wolf (2001)/Brotherhood of the Wolf (2001) {tmdb-6312} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Indiana Jones and the Temple of Doom (1984)
# Score: Ali=7200 vs Chris=5900
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Indiana Jones and the Temple of Doom (1984)/Indiana Jones and the Temple of Doom (1984) {tmdb-87} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Fast & Furious 6 (2013)
# Score: Ali=7000 vs Chris=6400
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Fast & Furious 6 (2013)/Fast and Furious 6 (2013) {tmdb-82992} - {edition-Extended} [Bluray-2160p Proper][DTS-HD MA 5.1][HDR10][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Jurassic Park (1993)
# Score: Ali=7200 vs Chris=6644
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Jurassic Park (1993)/Jurassic Park (1993) {tmdb-329} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-HiDt.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Extraction (2020)
# Score: Ali=6630 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Extraction (2020)/Extraction (2020) {tmdb-545609} - [NF][WEBDL-2160p][EAC3 Atmos 5.1][DV HDR10][HEVC]-SiC.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: What Happened to Monday (2017)
# Score: Ali=7050 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/What Happened to Monday (2017)/What Happened to Monday (2017) {tmdb-406990} - [Bluray-2160p][TrueHD 5.1][HDR10][x265]-BEN.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Mission Impossible 8 (2025)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mission Impossible 8 (2025)/Mission Impossible The Final Reckoning (2025) {tmdb-575265} - {edition-IMAX} [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10Plus][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Guardians of the Galaxy Vol. 2 (2017)
# Score: Ali=7200 vs Chris=5877
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Guardians of the Galaxy Vol. 2 (2017)/Guardians of the Galaxy Vol. 2 (2017) {tmdb-283995} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Martian (2015)
# Score: Ali=7100 vs Chris=7050
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Martian (2015)/The Martian (2015) {tmdb-286217} - {edition-Extended Cut} [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Kong Skull Island (2017)
# Score: Ali=7100 vs Chris=6350
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Kong Skull Island (2017)/Kong Skull Island (2017) {tmdb-293167} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-HQMUX.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Indiana Jones and the Last Crusade (1989)
# Score: Ali=7700 vs Chris=6800
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Indiana Jones and the Last Crusade (1989)/Indiana Jones and the Last Crusade (1989) {tmdb-89} - [Remux-2160p][TrueHD Atmos 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Pirates of the Caribbean The Curse of the Black Pearl (2003)
# Score: Chris=5193 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Pirates of the Caribbean The Curse of the Black Pearl (2003)/Pirates of the Caribbean The Curse of the Black Pearl (2003) WEBRip-2160p.mkv" "/mnt/unraid/media/4K Movies/"

# Ali has better: The Hunger Games Mockingjay - Part 2 (2015)
# Score: Ali=7200 vs Chris=6800
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Hunger Games Mockingjay - Part 2 (2015)/The Hunger Games Mockingjay Part 2 (2015) {tmdb-131634} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Raiders of the Lost Ark (1981)
# Score: Ali=7200 vs Chris=7065
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Raiders of the Lost Ark (1981)/Raiders of the Lost Ark (1981) {tmdb-85} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Jurassic World Dominion (2022)
# Score: Chris=5800 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Jurassic World Dominion (2022)/Jurassic World Dominion (2022) WEBDL-2160p.mkv" "/mnt/unraid/media/4K Movies/"

# Ali has better: Pacific Rim Uprising (2018)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Pacific Rim Uprising (2018)/Pacific Rim Uprising (2018) {tmdb-268896} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Gladiator II (2024)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Gladiator II (2024)/Gladiator II (2024) {tmdb-558449} - [Remux-2160p][TrueHD Atmos 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Twisters (2024)
# Score: Ali=7200 vs Chris=6700
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Twisters (2024)/Twisters (2024) {tmdb-718821} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10Plus][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Ready Player One (2018)
# Score: Ali=7100 vs Chris=6350
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Ready Player One (2018)/Ready Player One (2018) {tmdb-333339} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-HQMUX.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek V The Final Frontier (1989)
# Score: Ali=6790 vs Chris=5900
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek V The Final Frontier (1989)/Star Trek V The Final Frontier (1989) {tmdb-172} - [Bluray-2160p][EAC3 7.1][DV HDR10][x265]-hallowed.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Wicked (2024)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Wicked (2024)/Wicked (2024) {tmdb-402431} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek III The Search for Spock (1984)
# Score: Ali=6788 vs Chris=6621
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek III The Search for Spock (1984)/Star Trek III The Search for Spock (1984) {tmdb-157} - [Bluray-2160p Proper][EAC3 7.1][DV HDR10][x265]-hallowed.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Fifth Element (1997)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Fifth Element (1997)/The Fifth Element (1997) {tmdb-18} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: John Wick Chapter 3 Parabellum (2019)
# Score: Ali=7100 vs Chris=7050
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/John Wick Chapter 3 Parabellum (2019)/John Wick Chapter 3 Parabellum (2019) {tmdb-458156} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek First Contact (1996)
# Score: Ali=7150 vs Chris=5403
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek First Contact (1996)/Star Trek First Contact (1996) {tmdb-199} - [Bluray-2160p][TrueHD 7.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Indiana Jones and the Kingdom of the Crystal Skull (2008)
# Score: Ali=7200 vs Chris=7045
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Indiana Jones and the Kingdom of the Crystal Skull (2008)/Indiana Jones and the Kingdom of the Crystal Skull (2008) {tmdb-217} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Bohemian Rhapsody (2018)
# Score: Ali=7100 vs Chris=6400
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Bohemian Rhapsody (2018)/Bohemian Rhapsody (2018) {tmdb-424694} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10Plus][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Apollo 13 (1995)
# Score: Ali=7500 vs Chris=6400
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Apollo 13 (1995)/Apollo 13 (1995) {tmdb-568} - [Remux-2160p][DTS-X 7.1][HDR10][HEVC]-Scrambled.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Captain America Civil War (2016)
# Score: Ali=7100 vs Chris=6400
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Captain America Civil War (2016)/Captain America Civil War (2016) {tmdb-271110} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek (2009)
# Score: Ali=7100 vs Chris=5900
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek (2009)/Star Trek (2009) {tmdb-13475} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Top Gun Maverick (2022)
# Score: Ali=7200 vs Chris=5800
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Top Gun Maverick (2022)/Top Gun Maverick (2022) {tmdb-361743} - {edition-IMAX} [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10Plus][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Hacksaw Ridge (2016)
# Score: Ali=7200 vs Chris=5871
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Hacksaw Ridge (2016)/Hacksaw Ridge (2016) {tmdb-324786} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Zombieland Double Tap (2019)
# Score: Ali=7076 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Zombieland Double Tap (2019)/Zombieland Double Tap (2019) {tmdb-338967} - [Bluray-2160p][DTS-X 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Dune (2021)
# Score: Ali=7200 vs Chris=6800
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Dune (2021)/Dune (2021) {tmdb-438631} - [Bluray-2160p Proper][TrueHD Atmos 7.1][DV HDR10Plus][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Black Panther Wakanda Forever (2022)
# Score: Ali=7200 vs Chris=6850
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Black Panther Wakanda Forever (2022)/Black Panther Wakanda Forever (2022) {tmdb-505642} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: John Wick (2014)
# Score: Ali=7200 vs Chris=7092
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/John Wick (2014)/John Wick (2014) {tmdb-245891} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Guardians of the Galaxy (2014)
# Score: Ali=7200 vs Chris=6998
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Guardians of the Galaxy (2014)/Guardians of the Galaxy (2014) {tmdb-118340} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Alien Romulus (2024)
# Score: Ali=7200 vs Chris=6700
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Alien Romulus (2024)/Alien Romulus (2024) {tmdb-945961} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Hobbit An Unexpected Journey (2012)
# Score: Ali=7700 vs Chris=7300
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Hobbit An Unexpected Journey (2012)/The Hobbit An Unexpected Journey (2012) {tmdb-49051} - {edition-Extended Cut} [Remux-2160p][TrueHD Atmos 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Braveheart (1995)
# Score: Ali=7200 vs Chris=5900
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Braveheart (1995)/Braveheart (1995) {tmdb-197} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Oblivion (2013)
# Score: Chris=6400 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Oblivion (2013)/Oblivion (2013) Remux-2160p.mkv" "/mnt/unraid/media/4K Movies/"

# Ali has better: Iron Man 3 (2013)
# Score: Ali=7187 vs Chris=7018
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Iron Man 3 (2013)/Iron Man 3 (2013) {tmdb-68721} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: 300 (2006)
# Score: Ali=7700 vs Chris=6900
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/300 (2006)/300 (2007) {tmdb-1271} - [Hybrid][Remux-2160p][TrueHD Atmos 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Hobbit The Desolation of Smaug (2013)
# Score: Ali=7700 vs Chris=7300
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Hobbit The Desolation of Smaug (2013)/The Hobbit The Desolation of Smaug (2013) {tmdb-57158} - {edition-Extended Cut} [Remux-2160p][TrueHD Atmos 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Mad Max Fury Road (2015)
# Score: Ali=7700 vs Chris=6400
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mad Max Fury Road (2015)/Mad Max Fury Road (2015) {tmdb-76341} - [Hybrid][Remux-2160p Proper][TrueHD Atmos 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Jaws (1975)
# Score: Ali=7100 vs Chris=6900
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Jaws (1975)/Jaws (1975) {tmdb-578} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-HQMUX.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Ad Astra (2019)
# Score: Ali=7200 vs Chris=6800
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Ad Astra (2019)/Ad Astra (2019) {tmdb-419704} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-KeYBLaDE.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Cars 3 (2017)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Cars 3 (2017)/Cars 3 (2017) {tmdb-260514} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Edge of Tomorrow (2014)
# Score: Ali=7200 vs Chris=6750
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Edge of Tomorrow (2014)/Edge of Tomorrow (2014) {tmdb-137113} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Lawrence of Arabia (1962)
# Score: Ali=7600 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Lawrence of Arabia (1962)/Lawrence of Arabia (1962) {tmdb-947} - [Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Lawrence of Arabia (1962)
# Score: Ali=6900 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Lawrence of Arabia (1962)/Lawrence.of.Arabia.1962.UHD.BluRay.2160p.TrueHD.Atmos.7.1.HEVC.REMUX-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Doctor Strange (2016)
# Score: Chris=6800 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Doctor Strange (2016)/Doctor Strange (2016) Remux-2160p.mkv" "/mnt/unraid/media/4K Movies/"

# Ali has better: The Matrix Reloaded (2003)
# Score: Ali=7200 vs Chris=7050
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Matrix Reloaded (2003)/The Matrix Reloaded (2003) {tmdb-604} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek Into Darkness (2013)
# Score: Ali=7700 vs Chris=7100
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek Into Darkness (2013)/Star Trek Into Darkness (2013) {tmdb-54138} - {edition-IMAX} [Hybrid][Remux-2160p][TrueHD Atmos 7.1][DV HDR10][HEVC]-Flights.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Close Encounters of the Third Kind (1977)
# Score: Chris=6946 vs Ali=6759
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Close Encounters of the Third Kind (1977)/Close.Encounters.Of.The.Third.Kind.1977.DC.2160p.BluRay.HDR10.10bit.x265.HEVC.DTS-HD.MA.5.1-PHOCiS.mkv" "/mnt/unraid/media/4K Movies/"

# Ali has better: Pulp Fiction (1994)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Pulp Fiction (1994)/Pulp Fiction (1994) {tmdb-680} - [Bluray-2160p][DTS-HD MA 5.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Ghostbusters (1984)
# Score: Ali=7700 vs Chris=7100
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Ghostbusters (1984)/Ghostbusters (1984) {tmdb-620} - [Remux-2160p Proper][TrueHD Atmos 7.1][DV HDR10][HEVC]-BLURANiUM.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Furious 7 (2015)
# Score: Ali=6950 vs Chris=6400
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Furious 7 (2015)/Furious 7 (2015) {tmdb-168259} - {edition-Extended} [Bluray-2160p][DTS-HD HRA 7.1][HDR10][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Blade (1998)
# Score: Ali=7200 vs Chris=5900
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Blade (1998)/Blade (1998) {tmdb-36647} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Hunger Games (2012)
# Score: Ali=7200 vs Chris=6800
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Hunger Games (2012)/The Hunger Games (2012) {tmdb-70160} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Tenet (2020)
# Score: Ali=7100 vs Chris=7000
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Tenet (2020)/Tenet (2020) {tmdb-577922} - {edition-IMAX} [Bluray-2160p][DTS-HD MA 5.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Captain Marvel (2019)
# Score: Ali=7200 vs Chris=6400
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Captain Marvel (2019)/Captain Marvel (2019) {tmdb-299537} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Gladiator (2000)
# Score: Ali=7600 vs Chris=6800
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Gladiator (2000)/Gladiator (2000) {tmdb-98} - {edition-Extended Cut} [Remux-2160p][DTS-X 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Wizard of Oz (1939)
# Score: Ali=7600 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Wizard of Oz (1939)/The Wizard of Oz (1939) {tmdb-630} - [Remux-2160p][DTS-HD MA 5.1][DV HDR10Plus][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: TRON Legacy (2010)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/TRON Legacy (2010)/TRON Legacy (2010) {tmdb-20526} - {edition-IMAX} [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Pitch Black (2000)
# Score: Ali=7700 vs Chris=7000
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Pitch Black (2000)/Pitch Black (2000) {tmdb-2787} - {edition-Director's Cut} [Remux-2160p][TrueHD Atmos 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Zack Snyders Justice League (2021)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Zack Snyders Justice League (2021)/Zack Snyders Justice League (2021) {tmdb-791373} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Mission Impossible III (2006)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mission Impossible III (2006)/Mission Impossible III (2006) {tmdb-956} - [Bluray-2160p][TrueHD 5.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Hobbit The Battle of the Five Armies (2014)
# Score: Ali=7700 vs Chris=7300
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Hobbit The Battle of the Five Armies (2014)/The Hobbit The Battle of the Five Armies (2014) {tmdb-122917} - {edition-Extended Cut} [Remux-2160p][TrueHD Atmos 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Avatar The Way of Water (2022)
# Score: Ali=7100 vs Chris=5400
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Avatar The Way of Water (2022)/Avatar The Way of Water (2022) {tmdb-76600} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Captain America The First Avenger (2011)
# Score: Ali=7200 vs Chris=6594
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Captain America The First Avenger (2011)/Captain America The First Avenger (2011) {tmdb-1771} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-KeYBLaDE.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Zombieland (2009)
# Score: Ali=7200 vs Chris=5840
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Zombieland (2009)/Zombieland (2009) {tmdb-19908} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Godfather Part II (1974)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Godfather Part II (1974)/The Godfather Part II (1974) {tmdb-240} - [Bluray-2160p][TrueHD 5.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Life of Pi (2012)
# Score: Ali=7500 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Life of Pi (2012)/Life of Pi (2012) {tmdb-87827} - [Remux-2160p][DTS-HD MA 7.1][HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Life of Pi (2012)
# Score: Ali=6800 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Life of Pi (2012)/Life.Of.Pi.2012.UHD.BluRay.2160p.DTS-HD.MA.7.1.HEVC.REMUX-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Thor Ragnarok (2017)
# Score: Ali=7200 vs Chris=6650
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Thor Ragnarok (2017)/Thor Ragnarok (2017) {tmdb-284053} - [Hybrid][Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-LEGi0N.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Ghostbusters Afterlife (2021)
# Score: Chris=5330 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Ghostbusters Afterlife (2021)/Ghostbusters Afterlife (2021) WEBDL-2160p.mkv" "/mnt/unraid/media/4K Movies/"

# Ali has better: Venom Let There Be Carnage (2021)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Venom Let There Be Carnage (2021)/Venom Let There Be Carnage (2021) {tmdb-580489} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Guardians of the Galaxy Vol. 3 (2023)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Guardians of the Galaxy Vol. 3 (2023)/Guardians of the Galaxy Vol. 3 (2023) {tmdb-447365} - {edition-IMAX} [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek Insurrection (1998) {imdb-tt0120844}
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek Insurrection (1998) {imdb-tt0120844}/Star Trek Insurrection (1998) {tmdb-200} - [Bluray-2160p][TrueHD 7.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Frankenstein (2025)
# Score: Ali=6700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Frankenstein (2025)/Frankenstein (2025) {tmdb-1062722} - [NF][WEBDL-2160p][EAC3 Atmos 5.1][DV HDR10][h265]-Kitsune.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Predator (2018)
# Score: Ali=7700 vs Chris=6400
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Predator (2018)/The Predator (2018) {tmdb-346910} - [Hybrid][Remux-2160p][TrueHD Atmos 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Avengers Infinity War (2018)
# Score: Ali=7700 vs Chris=7100
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Avengers Infinity War (2018)/Avengers Infinity War (2018) {tmdb-299536} - [Hybrid][Remux-2160p][TrueHD Atmos 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: John Wick Chapter 2 (2017)
# Score: Chris=7600 vs Ali=7200
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/John Wick Chapter 2 (2017)/John.Wick.Chapter.2.2017.2160p.UHD.Bluray.Remux.HDR10.HEVC.Atmos.TrueHD.7.1-4K4U.mkv" "/mnt/unraid/media/4K Movies/"

# Ali has better: Star Wars (1977)
# Score: Ali=7200 vs Chris=6800
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Wars (1977)/Star Wars (1977) {tmdb-11} - [Hybrid][Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-HiDt.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Resident Evil Welcome to Raccoon City (2021)
# Score: Chris=5314 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Resident Evil Welcome to Raccoon City (2021)/Resident Evil Welcome to Raccoon City (2021) WEBDL-2160p.mkv" "/mnt/unraid/media/4K Movies/"

# Ali has better: Superman (2025)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Superman (2025)/Superman (2025) {tmdb-1061474} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10Plus][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek Beyond (2016)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek Beyond (2016)/Star Trek Beyond (2016) {tmdb-188927} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek IV The Voyage Home (1986)
# Score: Ali=6806 vs Chris=6637
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek IV The Voyage Home (1986)/Star Trek IV The Voyage Home (1986) {tmdb-168} - [Bluray-2160p Proper][EAC3 7.1][DV HDR10][x265]-hallowed.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Prey (2022)
# Score: Chris=5342 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Prey (2022)/Prey (2022) WEBDL-2160p.mkv" "/mnt/unraid/media/4K Movies/"

# Ali has better: Star Trek Generations (1994) {imdb-tt0111280}
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek Generations (1994) {imdb-tt0111280}/Star Trek Generations (1994) {tmdb-193} - [Bluray-2160p][TrueHD 7.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Eternals (2021)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Eternals (2021)/Eternals (2021) {tmdb-524434} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Top Gun (1986)
# Score: Chris=7150 vs Ali=6794
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Top Gun (1986)/Top Gun 1986 2160p UHD DV HDR10 BluRay SL TrueHD Atmos7 1 H265-SHD.mkv" "/mnt/unraid/media/4K Movies/"

# Ali has better: Alien (1979)
# Score: Ali=7500 vs Chris=7100
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Alien (1979)/Alien (1979) {tmdb-348} - {edition-Theatrical Cut} [Remux-2160p][DTS-HD MA 5.1][HDR10Plus][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Deadpool (2016)
# Score: Ali=7200 vs Chris=6400
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Deadpool (2016)/Deadpool (2016) {tmdb-293660} - [Hybrid][Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-SEV.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Shazam! Fury of the Gods (2023)
# Score: Ali=7200 vs Chris=6800
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Shazam! Fury of the Gods (2023)/Shazam! Fury of the Gods (2023) {tmdb-594767} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Deadpool 3 (2024)
# Score: Ali=7200 vs Chris=6700
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Deadpool 3 (2024)/Deadpool and Wolverine (2024) {tmdb-533535} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Jungle Cruise (2021)
# Score: Chris=6800 vs Ali=6646
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Jungle Cruise (2021)/Jungle Cruise (2021) Remux-2160p.mkv" "/mnt/unraid/media/4K Movies/"

# Ali has better: Civil War (2024)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Civil War (2024)/Civil War (2024) {tmdb-929590} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10Plus][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: E.T. the Extra-Terrestrial (1982)
# Score: Ali=7000 vs Chris=5900
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/E.T. the Extra-Terrestrial (1982)/E.T. the Extra-Terrestrial (1982) {tmdb-601} - [Bluray-2160p][DTS-X 7.1][HDR10][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Warfare (2025)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Warfare (2025)/Warfare (2025) {tmdb-1241436} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10Plus][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Doctor Strange in the Multiverse of Madness (2022)
# Score: Chris=5800 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Doctor Strange in the Multiverse of Madness (2022)/Doctor Strange in the Multiverse of Madness (2022) WEBDL-2160p.mkv" "/mnt/unraid/media/4K Movies/"

# Ali has better: Rise of the Planet of the Apes (2011)
# Score: Ali=6830 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Rise of the Planet of the Apes (2011)/Rise of the Planet of the Apes (2011) {tmdb-61791} - [Bluray-2160p][EAC3 5.1][DV HDR10][x265]-HONE.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Venom (2018)
# Score: Ali=7190 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Venom (2018)/Venom (2018) {tmdb-335983} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Captain America The Winter Soldier (2014)
# Score: Ali=7100 vs Chris=7050
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Captain America The Winter Soldier (2014)/Captain America The Winter Soldier (2014) {tmdb-100402} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Batman Begins (2005)
# Score: Ali=7600 vs Chris=7500
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Batman Begins (2005)/Batman Begins (2005) {tmdb-272} - [Hybrid][Remux-2160p][DTS-HD MA 5.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Thor (2011)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Thor (2011)/Thor (2011) {tmdb-10195} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-KeYBLaDE.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Matrix Revolutions (2003)
# Score: Ali=7200 vs Chris=6700
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Matrix Revolutions (2003)/The Matrix Revolutions (2003) {tmdb-605} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Heat (1995)
# Score: Ali=7500 vs Chris=6500
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Heat (1995)/Heat (1995) {tmdb-949} - [Remux-2160p][DTS-HD MA 5.1][HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Extraction 2 (2023)
# Score: Ali=6670 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Extraction 2 (2023)/Extraction 2 (2023) {tmdb-697843} - [NF][WEBDL-2160p][EAC3 Atmos 5.1][DV HDR10][h265]-HONE.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Godzilla Minus One (2023)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Godzilla Minus One (2023)/Godzilla Minus One (2023) {tmdb-940721} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Constantine (2005)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Constantine (2005)/Constantine (2005) {tmdb-561} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Black Adam (2022)
# Score: Ali=7200 vs Chris=5800
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Black Adam (2022)/Black Adam (2022) {tmdb-436270} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Solo A Star Wars Story (2018)
# Score: Ali=7200 vs Chris=7100
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Solo A Star Wars Story (2018)/Solo A Star Wars Story (2018) {tmdb-348350} - [Hybrid][Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-HiDt.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Lord of the Rings The Fellowship of the Ring (2001)
# Score: Ali=7700 vs Chris=6400
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Lord of the Rings The Fellowship of the Ring (2001)/The Lord of the Rings The Fellowship of the Ring (2001) {tmdb-120} - {edition-Extended} [Remux-2160p][TrueHD Atmos 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Alita Battle Angel (2019)
# Score: Ali=7100 vs Chris=6650
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Alita Battle Angel (2019)/Alita Battle Angel (2019) {tmdb-399579} - [Bluray-2160p Proper][TrueHD Atmos 7.1][HDR10Plus][x265]-DON.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Godzilla x Kong The New Empire (2024)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Godzilla x Kong The New Empire (2024)/Godzilla x Kong The New Empire (2024) {tmdb-823464} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek II The Wrath of Khan (1982)
# Score: Ali=6799 vs Chris=6634
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek II The Wrath of Khan (1982)/Star Trek II The Wrath of Khan (1982) {tmdb-154} - {edition-Theatrical Cut} [Bluray-2160p Proper][EAC3 7.1][DV HDR10][x265]-hallowed.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Apocalypse Now (1979)
# Score: Ali=7200 vs Chris=5900
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Apocalypse Now (1979)/Apocalypse Now (1979) {tmdb-28} - {edition-Theatrical Cut} [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Phantom of the Opera (2004)
# Score: Ali=7500 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Phantom of the Opera (2004)/The Phantom of the Opera (2004) {tmdb-9833} - [Remux-2160p][DTS-HD MA 5.1][HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Mortal Kombat (2021)
# Score: Chris=7200 vs Ali=7100
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Mortal Kombat (2021)/Mortal Kombat (2021) {imdb-tt0293429} [Bluray-2160p][DV HDR10][TrueHD Atmos 7.1][x265]-LEGi0N.mkv" "/mnt/unraid/media/4K Movies/"

# Ali has better: Pacific Rim (2013)
# Score: Ali=7172 vs Chris=6651
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Pacific Rim (2013)/Pacific Rim (2013) {tmdb-68726} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Inception (2010)
# Score: Ali=7100 vs Chris=5900
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Inception (2010)/Inception (2010) {tmdb-27205} - [Bluray-2160p][DTS-HD MA 5.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Blade Runner 2049 (2017)
# Score: Ali=7600 vs Chris=7100
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Blade Runner 2049 (2017)/Blade Runner 2049 (2017) {tmdb-335984} - [Hybrid][Remux-2160p][TrueHD Atmos 7.1][HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Lord of the Rings The Return of the King (2003)
# Score: Ali=7700 vs Chris=6400
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Lord of the Rings The Return of the King (2003)/The Lord of the Rings The Return of the King (2003) {tmdb-122} - {edition-Extended} [Remux-2160p][TrueHD Atmos 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Avengers (2012)
# Score: Ali=7700 vs Chris=7100
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Avengers (2012)/The Avengers (2012) {tmdb-24428} - [Hybrid][Remux-2160p][TrueHD Atmos 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Spider-Man Homecoming (2017)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Spider-Man Homecoming (2017)/Spider-Man Homecoming (2017) {tmdb-315635} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Mission Impossible Fallout (2018)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mission Impossible Fallout (2018)/Mission Impossible Fallout (2018) {tmdb-353081} - {edition-IMAX} [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Uncharted (2022)
# Score: Ali=7200 vs Chris=5400
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Uncharted (2022)/Uncharted (2022) {tmdb-335787} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Dark Knight Rises (2012)
# Score: Ali=7600 vs Chris=6750
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Dark Knight Rises (2012)/The Dark Knight Rises (2012) {tmdb-49026} - [Hybrid][Remux-2160p][DTS-HD MA 5.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek Nemesis (2002) {imdb-tt0253754}
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek Nemesis (2002) {imdb-tt0253754}/Star Trek Nemesis (2002) {tmdb-201} - [Bluray-2160p][TrueHD 7.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Thor The Dark World (2013)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Thor The Dark World (2013)/Thor The Dark World (2013) {tmdb-76338} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-HQMUX.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Godfather (1972)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Godfather (1972)/The Godfather (1972) {tmdb-238} - [Bluray-2160p][TrueHD 5.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Ten Commandments (1956)
# Score: Ali=7600 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Ten Commandments (1956)/The Ten Commandments (1956) {tmdb-6844} - [Remux-2160p][DTS-HD MA 5.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Indiana Jones and the Dial of Destiny (2023)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Indiana Jones and the Dial of Destiny (2023)/Indiana Jones and the Dial of Destiny (2023) {tmdb-335977} - [Hybrid][Remux-2160p][TrueHD Atmos 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Saving Private Ryan (1998)
# Score: Ali=7100 vs Chris=5900
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Saving Private Ryan (1998)/Saving Private Ryan (1998) {tmdb-857} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-HQMUX.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Spy Who Loved Me (1977)
# Score: Ali=5774 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Spy Who Loved Me (1977)/The Spy Who Loved Me (1977) {tmdb-691} - [WEBDL-2160p][DTS-HD MA 5.1][h265]-DEFLATE.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Hunger Games Mockingjay - Part 1 (2014)
# Score: Ali=7200 vs Chris=6800
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Hunger Games Mockingjay - Part 1 (2014)/The Hunger Games Mockingjay Part 1 (2014) {tmdb-131631} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Godzilla vs. Kong (2021)
# Score: Ali=7200 vs Chris=7100
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Godzilla vs. Kong (2021)/Godzilla vs. Kong (2021) {tmdb-399566} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10Plus][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Forrest Gump (1994)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Forrest Gump (1994)/Forrest Gump (1994) {tmdb-13} - [Bluray-2160p Proper][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: War for the Planet of the Apes (2017)
# Score: Ali=7196 vs Chris=6600
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/War for the Planet of the Apes (2017)/War for the Planet of the Apes (2017) {tmdb-281338} - [Hybrid][Bluray-2160p][EAC3 Atmos 8.0][DV HDR10Plus][x265]-BiTOR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Shawshank Redemption (1994)
# Score: Ali=6817 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Shawshank Redemption (1994)/The Shawshank Redemption (1994) {tmdb-278} - [Bluray-2160p][EAC3 5.1][DV HDR10][x265]-hallowed.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Willy Wonka and the Chocolate Factory (1971)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Willy Wonka and the Chocolate Factory (1971)/Willy Wonka and the Chocolate Factory (1971) {tmdb-252} - [Bluray-2160p][DTS-HD MA 5.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Avengers Age of Ultron (2015)
# Score: Ali=7700 vs Chris=6565
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Avengers Age of Ultron (2015)/Avengers Age of Ultron (2015) {tmdb-99861} - [Hybrid][Remux-2160p][TrueHD Atmos 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: TRON Ares (2025)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/TRON Ares (2025)/TRON Ares (2025) {tmdb-533533} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-SPx.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Greatest Showman (2017)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Greatest Showman (2017)/The Greatest Showman (2017) {tmdb-316029} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Iron Man 2 (2010)
# Score: Ali=7200 vs Chris=6599
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Iron Man 2 (2010)/Iron Man 2 (2010) {tmdb-10138} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Cars (2006)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Cars (2006)/Cars (2006) {tmdb-920} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Hunt for Red October (1990)
# Score: Ali=7150 vs Chris=6350
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Hunt for Red October (1990)/The Hunt for Red October (1990) {tmdb-1669} - [Bluray-2160p][TrueHD 5.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Suicide Squad (2021)
# Score: Ali=7200 vs Chris=6653
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Suicide Squad (2021)/The Suicide Squad (2021) {tmdb-436969} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10Plus][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Deadpool 2 (2018)
# Score: Ali=7100 vs Chris=6400
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Deadpool 2 (2018)/Deadpool 2 (2018) {tmdb-383498} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Lion King (1994)
# Score: Ali=7190 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Lion King (1994)/The Lion King (1994) {tmdb-8587} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Lion King (2019)
# Score: Ali=6788 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Lion King (2019)/The Lion King (2019) {tmdb-420818} - [Bluray-2160p][EAC3 7.1][DV HDR10][x265]-BHDStudio.mp4" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Hunger Games Catching Fire (2013)
# Score: Ali=7200 vs Chris=6800
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Hunger Games Catching Fire (2013)/The Hunger Games Catching Fire (2013) {tmdb-101299} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Avengers Endgame (2019)
# Score: Ali=7700 vs Chris=7100
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Avengers Endgame (2019)/Avengers Endgame (2019) {tmdb-299534} - [Hybrid][Remux-2160p][TrueHD Atmos 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Dawn of the Planet of the Apes (2014)
# Score: Ali=6803 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Dawn of the Planet of the Apes (2014)/Dawn of the Planet of the Apes (2014) {tmdb-119450} - [Bluray-2160p][EAC3 7.1][DV HDR10][x265]-hallowed.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Twister (1996)
# Score: Ali=7200 vs Chris=4300
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Twister (1996)/Twister (1996) {tmdb-664} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Wonder Woman 1984 (2020)
# Score: Ali=7200 vs Chris=7050
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Wonder Woman 1984 (2020)/Wonder Woman 1984 (2020) {tmdb-464052} - {edition-IMAX} [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10Plus][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Spider-Man Far From Home (2019)
# Score: Ali=7189 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Spider-Man Far From Home (2019)/Spider-Man Far From Home (2019) {tmdb-429617} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Fantastic 4 First Steps (2025)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Fantastic 4 First Steps (2025)/The Fantastic 4 First Steps (2025) {tmdb-617126} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-SPx.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Mission Impossible Ghost Protocol (2011)
# Score: Ali=7050 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mission Impossible Ghost Protocol (2011)/Mission Impossible Ghost Protocol (2011) {tmdb-56292} - [Bluray-2160p][TrueHD 7.1][HDR10][x265]-HQMUX.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Matrix Resurrections (2021)
# Score: Ali=7200 vs Chris=5792
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Matrix Resurrections (2021)/The Matrix Resurrections (2021) {tmdb-624860} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Red Sparrow (2018)
# Score: Ali=7200 vs Chris=5841
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Red Sparrow (2018)/Red Sparrow (2018) {tmdb-401981} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Blade II (2002)
# Score: Ali=6600 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Blade II (2002)/Blade II (2002) {tmdb-36586} - [WEBDL-2160p][DTS-HD MA 7.1][DV HDR10][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Total Recall (1990)
# Score: Ali=7700 vs Chris=6800
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Total Recall (1990)/Total Recall (1990) {tmdb-861} - [Remux-2160p][TrueHD Atmos 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Thunderbolts- (2025)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Thunderbolts- (2025)/Thunderbolts- (2025) {tmdb-986056} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-D3US.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: V for Vendetta (2005)
# Score: Ali=7700 vs Chris=6900
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/V for Vendetta (2005)/V for Vendetta (2006) {tmdb-752} - [Hybrid][Remux-2160p][TrueHD Atmos 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: The Outfit (2022)
# Score: Chris=5310 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Outfit (2022)/The Outfit (2022) WEBDL-2160p.mkv" "/mnt/unraid/media/4K Movies/"

# Ali has better: The Lord of the Rings The Two Towers (2002)
# Score: Ali=7700 vs Chris=6400
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Lord of the Rings The Two Towers (2002)/The Lord of the Rings The Two Towers (2002) {tmdb-121} - {edition-Extended} [Remux-2160p][TrueHD Atmos 7.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Iron Man (2008)
# Score: Ali=7200 vs Chris=7072
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Iron Man (2008)/Iron Man (2008) {tmdb-1726} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-MainFrame.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Army of the Dead (2021)
# Score: Ali=6660 vs Chris=5983
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Army of the Dead (2021)/Army of the Dead (2021) {tmdb-503736} - [NF][WEBDL-2160p][EAC3 Atmos 5.1][DV HDR10][HEVC]-SiC.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Tron (1982)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Tron (1982)/Tron (1982) {tmdb-97} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-SPx.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Lost World Jurassic Park (1997)
# Score: Ali=7200 vs Chris=6648
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Lost World Jurassic Park (1997)/The Lost World Jurassic Park (1997) {tmdb-330} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-HiDt.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: 2001 A Space Odyssey (1968)
# Score: Ali=7600 vs Chris=7500
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/2001 A Space Odyssey (1968)/2001 A Space Odyssey (1968) {tmdb-62} - [Remux-2160p Proper][DTS-HD MA 5.1][DV HDR10][HEVC]-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Godfather Part III (1990)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Godfather Part III (1990)/The Godfather Part III (1990) {tmdb-242} - {edition-Directors Cut} [Bluray-2160p][TrueHD 5.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Logan (2017)
# Score: Ali=7095 vs Chris=5848
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Logan (2017)/Logan (2017) {tmdb-263115} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-CtrlHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Terminator (1984)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Terminator (1984)/The Terminator (1984) {tmdb-218} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-SPHD.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Matrix (1999)
# Score: Ali=7200 vs Chris=6900
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Matrix (1999)/The Matrix (1999) {tmdb-603} - [Bluray-2160p][TrueHD Atmos 7.1][DV HDR10][x265]-W4NK3R.mkv" "/mnt/synology/rs-4kmedia/4kmovies/"

