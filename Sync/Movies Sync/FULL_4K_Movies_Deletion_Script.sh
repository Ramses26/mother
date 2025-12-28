#!/bin/bash
# FINAL 4K Movies Sync Actions for Project Mother
# Generated: 2025-12-28 01:49:48.791695

# Set to 'true' to execute, 'false' for dry-run
EXECUTE=false

move_to_deleted() {
  local file="$1"
  local movie_folder="$2"
  local dest="/media/Deleted/4K Movies/${movie_folder}/"
  
  if [ "$EXECUTE" = "true" ]; then
    mkdir -p "$dest"
    mv "$file" "$dest"
    echo "MOVED: $file -> $dest"
  else
    echo "DRY-RUN: Would move $file -> $dest"
  fi
}

# ========================================
# STEP 1: Move Chris's lower quality/resolution files
# ========================================

# 2001 A Space Odyssey (1968)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/2001 A Space Odyssey (1968)/2001.A.Space.Odyssey.1968.REPACK.2160p.UHD.BluRay.REMUX.HDR.HEVC.DTS-HD.MA.5.1-EPSiLON.mkv' '2001 A Space Odyssey (1968)'

# 300 (2006)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/300 (2006)/300.2006.UHD.BluRay.2160p.TrueHD.Atmos.7.1.HEVC.REMUX-FraMeSToR.mkv' '300 (2006)'

# Alien Romulus (2024)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Alien Romulus (2024)/Alien Romulus (2024) {imdb-tt18412256} [WEBDL-2160p][DV HDR10Plus][EAC3 Atmos 5.1][h265]-FLUX.mkv' 'Alien Romulus (2024)'

# Apocalypse Now (1979)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Apocalypse Now (1979)/Apocalypse.Now.1979.Redux.2160p.UHD.BluRay.x265-JustWatch.mkv' 'Apocalypse Now (1979)'

# Apollo 13 (1995)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Apollo 13 (1995)/Apollo 13 (1995) Remux-2160p.mkv' 'Apollo 13 (1995)'

# Army of the Dead (2021)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Army of the Dead (2021)/Army.of.the.Dead.2021.2160p.HDR.NF.WEBRip.DDP.Atmos.5.1.x265-TrollUHD-FZ.mkv' 'Army of the Dead (2021)'

# Avatar The Way of Water (2022)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Avatar The Way of Water (2022)/Avatar The Way of Water (2022) WEBDL-2160p.mkv' 'Avatar The Way of Water (2022)'

# Avengers Age of Ultron (2015)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Avengers Age of Ultron (2015)/Avengers.Age.of.Ultron.2015.2160p.UHD.BluRay.HDR.Atmos.x265-Absinth.mkv' 'Avengers Age of Ultron (2015)'

# Avengers Endgame (2019)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Avengers Endgame (2019)/Avengers.Endgame.2019.2160p.UHD.BluRay.REMUX.HDR.HEVC.Atmos-EPSiLON.mkv' 'Avengers Endgame (2019)'

# Avengers Infinity War (2018)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Avengers Infinity War (2018)/Avengers.Infinity.War.2018.2160p.UHD.BluRay.REMUX.HDR.HEVC.Atmos-EPSiLON.mkv' 'Avengers Infinity War (2018)'

# Batman Begins (2005)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Batman Begins (2005)/Batman.Begins.2005.2160p.UHD.BluRay.REMUX.HDR.HEVC.DTS-HD.MA.5.1-EPSiLON.mkv' 'Batman Begins (2005)'

# Black Adam (2022)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Black Adam (2022)/Black Adam (2022) WEBDL-2160p Proper.mkv' 'Black Adam (2022)'

# Black Panther Wakanda Forever (2022)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Black Panther Wakanda Forever (2022)/Black Panther Wakanda Forever (2022) {imdb-tt9114286} [Bluray-2160p][DV HDR10][EAC3 7.1][x265]-HONE.mkv' 'Black Panther Wakanda Forever (2022)'

# Black Widow (2021)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Black Widow (2021)/Black.Widow.2021.2160p.UHD.BluRay.HDR.x265.Atmos.TrueHD7.1-HDChina.mkv' 'Black Widow (2021)'

# Blade (1998)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Blade (1998)/Blade (1998) Bluray-2160p.mkv' 'Blade (1998)'

# Blade Runner (1982)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Blade Runner (1982)/Blade.Runner.1982.The.Final.Cut.2160p.UHD.BluRay.REMUX.HDR.HEVC.Atmos-EPSiLON.mkv' 'Blade Runner (1982)'

# Bohemian Rhapsody (2018)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Bohemian Rhapsody (2018)/Bohemian Rhapsody (2018) Remux-2160p.mkv' 'Bohemian Rhapsody (2018)'

# Braveheart (1995)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Braveheart (1995)/Braveheart.1995.2160p.UHD.BluRay.X265-IAMABLE.mkv' 'Braveheart (1995)'

# Captain America The First Avenger (2011)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Captain America The First Avenger (2011)/Captain.America.The.First.Avenger.2011.2160p.UHD.BluRay.HDR.Atmos.x265-Absinth.mkv' 'Captain America The First Avenger (2011)'

# Captain Marvel (2019)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Captain Marvel (2019)/Captain Marvel (2019) Remux-2160p.mkv' 'Captain Marvel (2019)'

# Deadpool (2016)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Deadpool (2016)/Deadpool (2016) Remux-2160p.mkv' 'Deadpool (2016)'

# Deadpool 2 (2018)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Deadpool 2 (2018)/Deadpool 2 (2018) Remux-2160p.mkv' 'Deadpool 2 (2018)'

# Deadpool 3 (2024)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Deadpool 3 (2024)/Deadpool and Wolverine (2024) {imdb-tt6263850} [WEBDL-2160p][DV HDR10Plus][EAC3 Atmos 5.1][h265]-FLUX.mkv' 'Deadpool 3 (2024)'

# Dracula (1992)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Dracula (1992)/Bram Stoker\'s Dracula 1992 2160p UHD Blu-Ray Remux HEVC Atmos - BluDragon.mkv' 'Dracula (1992)'

# Dunkirk (2017)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Dunkirk (2017)/Dunkirk 2017 2160p UHD BluRay HDR DTS x265-SadeceBluRay.mkv' 'Dunkirk (2017)'

# E.T. the Extra-Terrestrial (1982)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/E.T. the Extra-Terrestrial (1982)/E.T.the.Extra-Terrestrial.1982.2160p.UHD.BluRay.x265-DEPTH.mkv' 'E.T. the Extra-Terrestrial (1982)'

# Earth One Amazing Day (2017)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Earth One Amazing Day (2017)/Earth.One.Amazing.Day.2017.2160p.UHD.BluRay.REMUX.HDR.HEVC.Atmos-EPSiLON.mkv' 'Earth One Amazing Day (2017)'

# Fast & Furious 6 (2013)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Fast & Furious 6 (2013)/Fast & Furious 6 (2013) Remux-2160p Proper.mkv' 'Fast & Furious 6 (2013)'

# Furious 7 (2015)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Furious 7 (2015)/Furious 7 (2015) Remux-2160p.mkv' 'Furious 7 (2015)'

# Ghostbusters (1984)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Ghostbusters (1984)/Ghostbusters.1984.2160p.UHD.BluRay.REMUX.HDR.HEVC.Atmos-EPSiLON.mkv' 'Ghostbusters (1984)'

# Gladiator (2000)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Gladiator (2000)/Gladiator.2000.Extended.UHD.BluRay.2160p.DTS-X.7.1.HEVC.REMUX-FraMeSToR.mkv' 'Gladiator (2000)'

# Godzilla vs. Kong (2021)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Godzilla vs. Kong (2021)/Godzilla.vs.Kong.2021.2160p.UHD.BluRay.HDR.x265.Atmos.TrueHD7.1-HDChina.mkv' 'Godzilla vs. Kong (2021)'

# Guardians of the Galaxy (2014)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Guardians of the Galaxy (2014)/Guardians.Of.The.Galaxy.2014.2160p.UHD.BluRay.TrueHD.7.1.HDR.x265-CtrlHD.mkv' 'Guardians of the Galaxy (2014)'

# Guardians of the Galaxy Vol. 2 (2017)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Guardians of the Galaxy Vol. 2 (2017)/Guardians.of.the.Galaxy.Vol.2.2017.2160p.UHD.BluRay.x265-TERMiNAL.mkv' 'Guardians of the Galaxy Vol. 2 (2017)'

# Hacksaw Ridge (2016)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Hacksaw Ridge (2016)/Hacksaw.Ridge.2016.2160p.UHD.BluRay.x265-TERMiNAL.mkv' 'Hacksaw Ridge (2016)'

# Heat (1995)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Heat (1995)/Heat.1995.Directors.Definitive.Edition.2160p.HDR.WEB-DL.DTS-HD.MA.5.1.HEVC-BLUTONiUM.mkv' 'Heat (1995)'

# Inception (2010)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Inception (2010)/Inception.2010.2160p.UHD.BluRay.x265-TERMiNAL.mkv' 'Inception (2010)'

# Indiana Jones and the Kingdom of the Crystal Skull (2008)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Indiana Jones and the Kingdom of the Crystal Skull (2008)/Indiana.Jones.and.the.Kingdom.of.the.Crystal.Skull.2008.2160p.HDR.UHD.BluRay.TrueHD.7.1.Atmos.2Audio.x265-10bit-HDS.mkv' 'Indiana Jones and the Kingdom of the Crystal Skull (2008)'

# Indiana Jones and the Last Crusade (1989)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Indiana Jones and the Last Crusade (1989)/Indiana Jones and the Last Crusade (1989) Remux-2160p.mkv' 'Indiana Jones and the Last Crusade (1989)'

# Indiana Jones and the Temple of Doom (1984)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Indiana Jones and the Temple of Doom (1984)/indiana.jones.and.the.temple.of.doom.1984.2160p.uhd.bluray.x265-seskapile.mkv' 'Indiana Jones and the Temple of Doom (1984)'

# Interstellar (2014)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Interstellar (2014)/Interstellar.2014.2160p.UHD.BluRay.x265-TERMiNAL.mkv' 'Interstellar (2014)'

# Iron Man (2008)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Iron Man (2008)/Iron.Man.2008.2160p.UHD.Bluray.x265.HDR10.Atmos.TrueHD.7.1-4K4U.mkv' 'Iron Man (2008)'

# Iron Man 2 (2010)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Iron Man 2 (2010)/Iron.Man.2.2010.2160p.UHD.BluRay.HDR.Atmos.x265-Absinth.mkv' 'Iron Man 2 (2010)'

# Iron Man 3 (2013)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Iron Man 3 (2013)/Iron.Man.3.2013.2160p.UHD.BluRay.TrueHD.7.1.HDR.x265-CtrlHD.mkv' 'Iron Man 3 (2013)'

# John Wick (2014)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/John Wick (2014)/John.Wick.2014.2160p.UHD.BluRay.HDR.TrueHD.Atmos.7.1.x265-Absinth.mkv' 'John Wick (2014)'

# Jurassic Park (1993)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Jurassic Park (1993)/Jurassic.Park.1993.UHD.BluRay.2160p.DD.5.1.HDR.x265-BHDStudio.mp4' 'Jurassic Park (1993)'

# Kingdom of Heaven (2005)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Kingdom of Heaven (2005)/Kingdom of Heaven (2005) {imdb-tt0320661} {edition-Theatrical} [WEBDL-2160p][HDR10][EAC3 5.1][h265]-SMURF.mkv' 'Kingdom of Heaven (2005)'

# Logan (2017)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Logan (2017)/Logan.2017.2160p.UHD.BluRay.x265-TERMiNAL.mkv' 'Logan (2017)'

# Mad Max Fury Road (2015)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Mad Max Fury Road (2015)/Mad Max Fury Road 2015 2160p UHD Blu-ray Remux HEVC Atmos 7.1 - BluDragon.mkv' 'Mad Max Fury Road (2015)'

# Pacific Rim (2013)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Pacific Rim (2013)/Pacific.Rim.2013.UHD.BluRay.2160p.DD.5.1.HDR.x265-BHDStudio.mp4' 'Pacific Rim (2013)'

# Passengers (2016)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Passengers (2016)/Passengers.2016.2160p.UHD.BluRay.REMUX.HDR.HEVC.Atmos-EPSiLON.mkv' 'Passengers (2016)'

# Pitch Black (2000)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Pitch Black (2000)/Pitch.Black.2000.Directors.Cut.REPACK.2160p.UHD.BluRay.DTS-HD.MA.5.1.HDR.x265-CtrlHD.mkv' 'Pitch Black (2000)'

# Raiders of the Lost Ark (1981)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Raiders of the Lost Ark (1981)/Raiders.Of.The.Lost.Ark.1981.2160p.UHD.Bluray.x265.HDR10.Atmos.TrueHD.7.1-4K4U.mkv' 'Raiders of the Lost Ark (1981)'

# Red Sparrow (2018)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Red Sparrow (2018)/Red.Sparrow.2018.2160p.UHD.BluRay.x265-WhiteRhino.mkv' 'Red Sparrow (2018)'

# Return of the Jedi (1983)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Return of the Jedi (1983)/Return of the Jedi (1983) Remux-2160p.mkv' 'Return of the Jedi (1983)'

# Rocketman (2019)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Rocketman (2019)/Rocketman 2019 2160p UHD Blu-ray HEVC Atmos x265 - SumVision.mkv' 'Rocketman (2019)'

# Saving Private Ryan (1998)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Saving Private Ryan (1998)/Saving.Private.Ryan.1998.2160p.UHD.BluRay.X265-IAMABLE.mkv' 'Saving Private Ryan (1998)'

# Solo A Star Wars Story (2018)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Solo A Star Wars Story (2018)/Solo A Star Wars Story (2018) {imdb-tt3778644} [Bluray-2160p Proper][HDR10][TrueHD Atmos 7.1][x265]-TnP.mkv' 'Solo A Star Wars Story (2018)'

# Spider-Man No Way Home (2021)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Spider-Man No Way Home (2021)/Spider-Man No Way Home (2021) WEBDL-2160p.mkv' 'Spider-Man No Way Home (2021)'

# Star Trek (2009)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Star Trek (2009)/Star.Trek.2009.2160p.UHD.BluRay.X265-IAMABLE.mkv' 'Star Trek (2009)'

# Star Trek First Contact (1996)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Star Trek First Contact (1996)/Star.Trek.VIII.First.Contact.1996.2160p.WEB-DL.DDP5.1.H.265-ABBiE.mkv' 'Star Trek First Contact (1996)'

# Star Trek II The Wrath of Khan (1982)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Star Trek II The Wrath of Khan (1982)/Star.Trek.II.The.Wrath.of.Khan.1982.Director\'s.Cut.UHD.BluRay.2160p.DD.5.1.HDR.x265-BHDStudio.mp4' 'Star Trek II The Wrath of Khan (1982)'

# Star Trek III The Search for Spock (1984)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Star Trek III The Search for Spock (1984)/Star.Trek.III.The.Search.for.Spock.1984.UHD.BluRay.2160p.DD.5.1.HDR.x265-BHDStudio.mp4' 'Star Trek III The Search for Spock (1984)'

# Star Trek IV The Voyage Home (1986)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Star Trek IV The Voyage Home (1986)/Star.Trek.IV.The.Voyage.Home.1986.UHD.BluRay.2160p.DD.5.1.HDR.x265-BHDStudio.mp4' 'Star Trek IV The Voyage Home (1986)'

# Star Trek Into Darkness (2013)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Star Trek Into Darkness (2013)/Star.Trek.Into.Darkness.2013.2160p.UHD.BluRay.REMUX.HDR.HEVC.Atmos-EPSiLON.mkv' 'Star Trek Into Darkness (2013)'

# Star Trek V The Final Frontier (1989)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Star Trek V The Final Frontier (1989)/Star Trek V The Final Frontier (1989) Bluray-2160p.mkv' 'Star Trek V The Final Frontier (1989)'

# Star Trek VI The Undiscovered Country (1991)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Star Trek VI The Undiscovered Country (1991)/Star Trek VI The Undiscovered Country (1991) Bluray-2160p.mkv' 'Star Trek VI The Undiscovered Country (1991)'

# Tenet (2020)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Tenet (2020)/Tenet (2020) {imdb-tt6723592} [Bluray-2160p Proper][HDR10][DTS-HD MA 5.1][x265]-CtrlHD.mkv' 'Tenet (2020)'

# The Avengers (2012)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/The Avengers (2012)/The.Avengers.2012.REPACK.2160p.UHD.BluRay.REMUX.HDR.HEVC.Atmos-EPSiLON.mkv' 'The Avengers (2012)'

# The Dark Knight (2008)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/The Dark Knight (2008)/The Dark Knight 2008 2160p UHD Blu-ray Remux HEVC DTS-HD MA 5.1 - BluDragon.mkv' 'The Dark Knight (2008)'

# The Dark Knight Rises (2012)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/The Dark Knight Rises (2012)/The Dark Knight Rises 2012 2160p UHD Blu-ray Remux HEVC DTS-HD MA 5.1 - BluDragon.mkv' 'The Dark Knight Rises (2012)'

# The Empire Strikes Back (1980)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/The Empire Strikes Back (1980)/The Empire Strikes Back (1980) Bluray-2160p.mkv' 'The Empire Strikes Back (1980)'

# The Hunt for Red October (1990)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/The Hunt for Red October (1990)/The Hunt for Red October.1990.2160p.UHD.BluRay.TrueHD5.1.x265-HQMUX.mkv' 'The Hunt for Red October (1990)'

# The Lord of the Rings The Fellowship of the Ring (2001)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/The Lord of the Rings The Fellowship of the Ring (2001)/The Lord of the Rings The Fellowship of the Ring (2001) Remux-2160p.mkv' 'The Lord of the Rings The Fellowship of the Ring (2001)'

# The Lord of the Rings The Return of the King (2003)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/The Lord of the Rings The Return of the King (2003)/The Lord of the Rings The Return of the King (2003) Remux-2160p.mkv' 'The Lord of the Rings The Return of the King (2003)'

# The Lord of the Rings The Two Towers (2002)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/The Lord of the Rings The Two Towers (2002)/The Lord of the Rings The Two Towers (2002) Remux-2160p.mkv' 'The Lord of the Rings The Two Towers (2002)'

# The Lost World Jurassic Park (1997)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/The Lost World Jurassic Park (1997)/The.Lost.World.Jurassic.Park.1997.UHD.BluRay.2160p.DD.5.1.HDR.x265-BHDStudio.mp4' 'The Lost World Jurassic Park (1997)'

# The Matrix (1999)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/The Matrix (1999)/The.Matrix.1999.UHD.BluRay.2160p.TrueHD.Atmos.7.1.HEVC.REMUX-FraMeSToR.mkv' 'The Matrix (1999)'

# The Matrix Reloaded (2003)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/The Matrix Reloaded (2003)/The.Matrix.Reloaded.2003.2160p.UHD.BluRay.TrueHD.7.1.HDR.x265-CtrlHD.mkv' 'The Matrix Reloaded (2003)'

# The Matrix Resurrections (2021)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/The Matrix Resurrections (2021)/The Matrix Resurrections (2021) WEBDL-2160p.mkv' 'The Matrix Resurrections (2021)'

# The Matrix Revolutions (2003)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/The Matrix Revolutions (2003)/The.Matrix-Revolutions.2003.UHD.BluRay.HDR.10Bit.2160p.DD.5.1.H265-d3g.mkv' 'The Matrix Revolutions (2003)'

# The Predator (2018)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/The Predator (2018)/The Predator 2018 2160p UHD Blu-ray Remux HEVC Atmos 7.1 - BluDragon.mkv' 'The Predator (2018)'

# The Revenant (2015)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/The Revenant (2015)/The.Revenant.2015.UHD.BluRay.2160p.DTS-HD.MA.7.1.HEVC.REMUX-FraMeSToR-AsRequested.mkv' 'The Revenant (2015)'

# The Suicide Squad (2021)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/The Suicide Squad (2021)/The.Suicide.Squad.2021.UHD.BluRay.2160p.DD.5.1.HDR.x265-BHDStudio.mp4' 'The Suicide Squad (2021)'

# Thor Ragnarok (2017)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Thor Ragnarok (2017)/Thor Ragnarok 2017 2160p UHD HDR10+ BluRay x265 TrueHD Atmos 7 1-UnKn0wn.mkv' 'Thor Ragnarok (2017)'

# Top Gun Maverick (2022)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Top Gun Maverick (2022)/Top Gun Maverick (2022) WEBDL-2160p.mkv' 'Top Gun Maverick (2022)'

# Total Recall (1990)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Total Recall (1990)/Total Recall (1990) Remux-2160p.mkv' 'Total Recall (1990)'

# Twisters (2024)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Twisters (2024)/Twisters (2024) {imdb-tt12584954} [WEBDL-2160p][DV HDR10Plus][EAC3 Atmos 5.1][h265]-FLUX.mkv' 'Twisters (2024)'

# Uncharted (2022)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Uncharted (2022)/Uncharted (2022) WEBDL-2160p.mkv' 'Uncharted (2022)'

# V for Vendetta (2005)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/V for Vendetta (2005)/V.for.Vendetta.2005.UHD.BluRay.2160p.TrueHD.Atmos.7.1.HEVC.REMUX-FraMeSToR.mkv' 'V for Vendetta (2005)'

# War for the Planet of the Apes (2017)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/War for the Planet of the Apes (2017)/War.for.the.Planet.of.the.Apes.2017.2160p.UHD.BluRay.HDR.Atmos.x265-Absinth.mkv' 'War for the Planet of the Apes (2017)'

# Wonder Woman (2017)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Wonder Woman (2017)/Wonder.Woman.2017.2160p.UHD.BluRay.TrueHD.7.1.HDR.x265-CtrlHD.mkv' 'Wonder Woman (2017)'

# Wonder Woman 1984 (2020)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Wonder Woman 1984 (2020)/Wonder.Woman.1984.2020.2160p.HMAX.WEB-DL.DDP5.1.Atmos.HDR.HEVC-TOMMY.mkv' 'Wonder Woman 1984 (2020)'

# Zombieland (2009)
move_to_deleted '/mnt/synology/rs-4kmedia/4kmovies/Zombieland (2009)/Zombieland.2009.2160p.UHD.BluRay.X265-IAMABLE.mkv' 'Zombieland (2009)'

# ========================================
# STEP 2: Move Ali's lower quality/resolution files
# ========================================

# Captain America Civil War (2016)
move_to_deleted '/mnt/media/4K Movies/Captain America Civil War (2016)/Captain.America.Civil.War.2016.2160p.UHD.BluRay.ATMOS.HDR.x265-W4NK3R.mkv' 'Captain America Civil War (2016)'

# Jaws (1975)
move_to_deleted '/mnt/media/4K Movies/Jaws (1975)/Jaws (1975) {imdb-tt0073195} [Bluray-2160p][HDR10][TrueHD Atmos 7.1][x265]-HQMUX.mkv' 'Jaws (1975)'

# John Wick Chapter 2 (2017)
move_to_deleted '/mnt/media/4K Movies/John Wick Chapter 2 (2017)/John Wick Chapter 2 (2017) {imdb-tt4425200} [Bluray-2160p][DV HDR10][TrueHD Atmos 7.1][x265]-SPHD.mkv' 'John Wick Chapter 2 (2017)'

# Jungle Cruise (2021)
move_to_deleted '/mnt/media/4K Movies/Jungle Cruise (2021)/Jungle.Cruise.2021.UHD.BluRay.2160p.DD.5.1.HDR.x265-BHDStudio.mp4' 'Jungle Cruise (2021)'

# Mortal Kombat (2021)
move_to_deleted '/mnt/media/4K Movies/Mortal Kombat (2021)/Mortal Kombat (2021) {imdb-tt0293429} - [Bluray-2160p][TrueHD Atmos 7.1][HDR10][x265]-HQMUX.mkv' 'Mortal Kombat (2021)'

# Top Gun (1986)
move_to_deleted '/mnt/media/4K Movies/Top Gun (1986)/Top Gun (1986) {imdb-tt0092099} [Bluray-2160p][DV HDR10][EAC3 7.1][x265]-hallowed.mkv' 'Top Gun (1986)'

echo 'Action script completed.'
echo 'Set EXECUTE=true and re-run to perform actual moves.'
