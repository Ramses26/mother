#!/bin/bash

################################################################################
# PROJECT MOTHER - UNRAID DELETION SCRIPT (Movies)
################################################################################
#
# RUNS ON: Unraid server (locally)
# DELETES: Ali's lower quality movies
# DESTINATION: /mnt/user/Media/Deleted/Movies/
#
# This script moves Ali's lower quality movie files to the deleted folder.
# Files are moved (not permanently deleted), so you can recover them if needed.
#
# USAGE:
#   1. Copy this script to Unraid
#   2. Run in dry-run mode: bash DELETE_Unraid_Movies.sh
#   3. Review the output
#   4. Edit this file: Change EXECUTE=false to EXECUTE=true
#   5. Run again: bash DELETE_Unraid_Movies.sh
#
################################################################################

# Set to "true" to actually move files, "false" for dry-run
EXECUTE=false

################################################################################
# FUNCTION: Move to Deleted
################################################################################

move_to_deleted() {
  local file="$1"
  local movie_folder="$2"
  
  # Convert /mnt/media to /mnt/user/Media (Unraid's local path)
  local fixed_file="${file//\/mnt\/media\//\/mnt\/user\/Media\/}"
  local dest="/mnt/user/Media/Deleted/Movies/${movie_folder}/"
  
  if [ "$EXECUTE" = "true" ]; then
    mkdir -p "$dest"
    mv "$fixed_file" "$dest"
    echo "✓ MOVED: $fixed_file"
    echo "     TO: $dest"
  else
    echo "DRY-RUN: Would move $fixed_file"
    echo "     TO: $dest"
  fi
}

################################################################################
# DELETIONS: Ali's Lower Quality Movies
################################################################################

if [ "$EXECUTE" = "false" ]; then
  echo "========================================================================"
  echo "DRY-RUN MODE - No files will be moved"
  echo "========================================================================"
  echo ""
fi

echo "========================================================================"
echo "UNRAID MOVIES DELETION"
echo "========================================================================"
echo "Deleting Ali's lower quality movies..."
echo "Destination: /mnt/user/Media/Deleted/Movies/"
echo ""


# 10 Cloverfield Lane (2016)
move_to_deleted '/mnt/media/Movies/10 Cloverfield Lane (2016)/10 Cloverfield Lane 2016 1080p BluRay DDP 7.1 DV x265-LEGi0N.mkv' '10 Cloverfield Lane (2016)'

# 100% Wolf (2020)
move_to_deleted '/mnt/media/Movies/100% Wolf (2020)/100% Wolf (2020) {imdb-tt8774798} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' '100% Wolf (2020)'

# 16 Blocks (2006)
move_to_deleted '/mnt/media/Movies/16 Blocks (2006)/16.Blocks.2006.1080p.HDDVD.DTS.x264-CtrlHD.mkv' '16 Blocks (2006)'

# 1944 (2015)
move_to_deleted '/mnt/media/Movies/1944 (2015)/1944 (2015) {imdb-tt3213684} [Bluray-1080p][DTS-HD MA 5.1][x264]-GeneMige.mkv' '1944 (2015)'

# 1BR (2019)
move_to_deleted '/mnt/media/Movies/1BR (2019)/1BR (2019) {imdb-tt7541106} [Bluray-1080p][DTS 5.1][x264]-iFT.mkv' '1BR (2019)'

# 20 Million Miles to Earth (1957)
move_to_deleted '/mnt/media/Movies/20 Million Miles to Earth (1957)/20 Million Miles to Earth (1957) {imdb-tt0050084} [Bluray-1080p][Opus 5.1][x264]-RetroPeeps.mkv' '20 Million Miles to Earth (1957)'

# 42 (2013)
move_to_deleted '/mnt/media/Movies/42 (2013)/42 2013 1080p BluRay DTS x264-TayTO.mkv' '42 (2013)'

# 6 Underground (2019)
move_to_deleted '/mnt/media/Movies/6 Underground (2019)/6.Underground.2019.1080p.NF.WEB.DDP5.1.Atmos.x264-AJP69.mkv' '6 Underground (2019)'

# 7th Voyage of Sinbad, The (1958)
move_to_deleted '/mnt/media/Movies/7th Voyage of Sinbad, The (1958)/The 7th Voyage of Sinbad (1958) {imdb-tt0051337} [Bluray-1080p][Opus 1.0][x264]-RetroPeeps.mkv' '7th Voyage of Sinbad, The (1958)'

# 8-Bit Christmas (2021)
move_to_deleted '/mnt/media/Movies/8-Bit Christmas (2021)/8-Bit Christmas (2021) {imdb-tt11540284} [HMAX][WEBDL-1080p][EAC3 Atmos 5.1][x264]-TEPES.mkv' '8-Bit Christmas (2021)'

# 9 (2009)
move_to_deleted '/mnt/media/Movies/9 (2009)/9.2009.US.1080p.BluRay.DTS.x264-EbP.mkv' '9 (2009)'

# Bug\'s Life, A (1998)
move_to_deleted '/mnt/media/Movies/Bug\'s Life, A (1998)/A Bugs Life (1998) {imdb-tt0120623} [Bluray-1080p][HDR10][EAC3 Atmos 7.1][x265]-NCmt.mkv' 'Bug\'s Life, A (1998)'

# Christmas Carol, A (1984) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/Christmas Carol, A (1984)/A Christmas Carol (1984) {imdb-tt0087056} - [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv' 'Christmas Carol, A (1984)'

# A Dangerous Method (2011)
move_to_deleted '/mnt/media/Movies/A Dangerous Method (2011)/A.Dangerous.Method.2011.1080p.BluRay.DD5.1.x264-EbP.mkv' 'A Dangerous Method (2011)'

# Abandoned Mine (2013)
move_to_deleted '/mnt/media/Movies/Abandoned Mine (2013)/Abandoned.Mine.2013.1080p.BluRay.x264-NOSCREENS.mkv' 'Abandoned Mine (2013)'

# Abbott and Costello Go to Mars (1953) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/Abbott and Costello Go to Mars (1953)/Abbott and Costello Go to Mars (1953) {imdb-tt0045468} - [Bluray-1080p][FLAC 2.0][x264]-RetroPeeps.mkv' 'Abbott and Costello Go to Mars (1953)'

# Abbott and Costello Meet Dr. Jekyll and Mr. Hyde (1953) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/Abbott and Costello Meet Dr. Jekyll and Mr. Hyde (1953)/Abbott and Costello Meet Dr. Jekyll and Mr. Hyde (1953) {imdb-tt0045469} [Bluray-1080p][FLAC 2.0][x264]-RetroPeeps.mkv' 'Abbott and Costello Meet Dr. Jekyll and Mr. Hyde (1953)'

# Abbott and Costello Meet the Keystone Kops (1955)
move_to_deleted '/mnt/media/Movies/Abbott and Costello Meet the Keystone Kops (1955)/Abbott and Costello Meet the Keystone Kops (1955) {imdb-tt0047794} [Bluray-1080p][FLAC 2.0][x264]-RetroPeeps.mkv' 'Abbott and Costello Meet the Keystone Kops (1955)'

# Abbott and Costello in the Foreign Legion (1950) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/Abbott and Costello in the Foreign Legion (1950)/Bud Abbott and Lou Costello in the Foreign Legion (1950) {imdb-tt0042179} - [Bluray-1080p][FLAC 2.0][x264]-RetroPeeps.mkv' 'Abbott and Costello in the Foreign Legion (1950)'

# Abominable Snowman, The (1957)
move_to_deleted '/mnt/media/Movies/Abominable Snowman, The (1957)/The Abominable Snowman (1957) {imdb-tt0050095} [Bluray-1080p][AC3 2.0][x264]-KESH.mkv' 'Abominable Snowman, The (1957)'

# About Cherry (2012)
move_to_deleted '/mnt/media/Movies/About Cherry (2012)/About Cherry (2012) {imdb-tt1945062} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'About Cherry (2012)'

# About My Father (2023)
move_to_deleted '/mnt/media/Movies/About My Father (2023)/About My Father (2023) {imdb-tt8373206} [Bluray-1080p][TrueHD Atmos 7.1][x264]-pignus.mkv' 'About My Father (2023)'

# Absent-Minded Professor, The (1961) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/Absent-Minded Professor, The (1961)/The Absent-Minded Professor (1961) {imdb-tt0054594} [Bluray-1080p][AC3 2.0][x264]-RetroPeeps.mkv' 'Absent-Minded Professor, The (1961)'

# Addams Family Values (1993)
move_to_deleted '/mnt/media/Movies/Addams Family Values (1993)/Addams Family Values (1993) {imdb-tt0106220} [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv' 'Addams Family Values (1993)'

# Adventures of Ford Fairlane, The (1990)
move_to_deleted '/mnt/media/Movies/Adventures of Ford Fairlane, The (1990)/The Adventures of Ford Fairlane (1990) {imdb-tt0098987} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Adventures of Ford Fairlane, The (1990)'

# Adventures of Sharkboy and Lavagirl, The (2005)
move_to_deleted '/mnt/media/Movies/Adventures of Sharkboy and Lavagirl, The (2005)/The Adventures of Sharkboy and Lavagirl (2005) {imdb-tt0424774} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-ARTiCUN0.mkv' 'Adventures of Sharkboy and Lavagirl, The (2005)'

# Airheads (1994)
move_to_deleted '/mnt/media/Movies/Airheads (1994)/Airheads (1994) {imdb-tt0109068} [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv' 'Airheads (1994)'

# Aladdin (2019)
move_to_deleted '/mnt/media/Movies/Aladdin (2019)/Aladdin (2019) {imdb-tt6139732} [Bluray-1080p][EAC3 7.1][x264]-DON.mkv' 'Aladdin (2019)'

# Alice in Wonderland (1951) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/Alice in Wonderland (1951)/Alice in Wonderland (1951) {imdb-tt0043274} [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv' 'Alice in Wonderland (1951)'

# Alice in Wonderland (2010)
move_to_deleted '/mnt/media/Movies/Alice in Wonderland (2010)/Alice.in.Wonderland.2010.1080p.BluRay.x264-EbP.mkv' 'Alice in Wonderland (2010)'

# Alien Covenant (2017)
move_to_deleted '/mnt/media/Movies/Alien Covenant (2017)/Alien.Covenant.2017.1080p.BluRay.DTS-ES.x264-Geek.mkv' 'Alien Covenant (2017)'

# All About Eve (1950)
move_to_deleted '/mnt/media/Movies/All About Eve (1950)/All.About.Eve.1950.1080p.Bluray.FLAC1.0.x264-PTer.mkv' 'All About Eve (1950)'

# All the Right Moves (1983)
move_to_deleted '/mnt/media/Movies/All the Right Moves (1983)/All the Right Moves (1983) {imdb-tt0085154} [Bluray-1080p][AC3 5.1][x264]-Spekt0r.mkv' 'All the Right Moves (1983)'

# Alpha and Omega (2010)
move_to_deleted '/mnt/media/Movies/Alpha and Omega (2010)/Alpha and Omega (2010) {imdb-tt1213012} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv' 'Alpha and Omega (2010)'

# Always (1989)
move_to_deleted '/mnt/media/Movies/Always (1989)/Always.1989.MULTi.1080p.BluRay.x264-ULSHD.mkv' 'Always (1989)'

# American Heist (2014)
move_to_deleted '/mnt/media/Movies/American Heist (2014)/american.heist.2014.1080p.bluray.x264-veto.mkv' 'American Heist (2014)'

# American Horror House (2012)
move_to_deleted '/mnt/media/Movies/American Horror House (2012)/American.Horror.House.2012.1080p.BluRay.x264-iFPD.mkv' 'American Horror House (2012)'

# American Reunion (2012)
move_to_deleted '/mnt/media/Movies/American Reunion (2012)/American.Reunion.2012.UNRATED.1080p.BluRay.DTS.x264-CtrlHD.mkv' 'American Reunion (2012)'

# American Siege (2022)
move_to_deleted '/mnt/media/Movies/American Siege (2022)/American.Siege.2021.1080p.BluRay.x264-PiGNUS.mkv' 'American Siege (2022)'

# American Wedding (2003)
move_to_deleted '/mnt/media/Movies/American Wedding (2003)/American.Wedding.2003.UNRATED.1080p.BluRay.DTS.x264-CtrlHD.mkv' 'American Wedding (2003)'

# American in Paris, An (1951)
move_to_deleted '/mnt/media/Movies/American in Paris, An (1951)/ah63jka93jf0jh26ahjas544.mkv' 'American in Paris, An (1951)'

# American Tail, An (1986)
move_to_deleted '/mnt/media/Movies/American Tail, An (1986)/An American Tail (1986) {imdb-tt0090633} [Bluray-1080p][DTS 5.1][x264]-DON.mkv' 'American Tail, An (1986)'

# Analyze That (2002)
move_to_deleted '/mnt/media/Movies/Analyze That (2002)/Analyze That (2002) {imdb-tt0289848} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Analyze That (2002)'

# Anastasia (1997)
move_to_deleted '/mnt/media/Movies/Anastasia (1997)/Anastasia.1997.1080p.BluRay.DTS.x264-DON.mkv' 'Anastasia (1997)'

# Animal House (1978)
move_to_deleted '/mnt/media/Movies/Animal House (1978)/Animal House (1978) {imdb-tt0077975} - [Bluray-1080p Proper][EAC3 7.1][HDR10][x265]-JKP.mkv' 'Animal House (1978)'

# Anora (2024)
move_to_deleted '/mnt/media/Movies/Anora (2024)/Anora (2024) {imdb-tt28607951} [Bluray-1080p][EAC3 5.1][x264]-TDD.mkv' 'Anora (2024)'

# Antebellum (2020)
move_to_deleted '/mnt/media/Movies/Antebellum (2020)/Antebellum (2020) {imdb-tt10065694} [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv' 'Antebellum (2020)'

# Antichrist (2009)
move_to_deleted '/mnt/media/Movies/Antichrist (2009)/Antichrist (2009) {imdb-tt0870984} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv' 'Antichrist (2009)'

# Apollo 10½ A Space Age Childhood (2022)
move_to_deleted '/mnt/media/Movies/Apollo 10½ A Space Age Childhood (2022)/Apollo 10½ A Space Age Childhood (2022) {imdb-tt7978758} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-TEPES.mkv' 'Apollo 10½ A Space Age Childhood (2022)'

# Armageddon Time (2022)
move_to_deleted '/mnt/media/Movies/Armageddon Time (2022)/Armageddon.Time.2022.1080p.BluRay.x264-PiGNUS.mkv' 'Armageddon Time (2022)'

# Armor (2024)
move_to_deleted '/mnt/media/Movies/Armor (2024)/Armor (2024) {imdb-tt29252358} - [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv' 'Armor (2024)'

# Army of Darkness (1992)
move_to_deleted '/mnt/media/Movies/Army of Darkness (1992)/Army of Darkness (1992) {imdb-tt0106308} {edition-Theatrical} [Bluray-1080p][DV HDR10][FLAC 2.0][x265]-SQS.mkv' 'Army of Darkness (1992)'

# Arthur (1981)
move_to_deleted '/mnt/media/Movies/Arthur (1981)/Arthur.1981.1080p.BluRay.x264-KaKa.mkv' 'Arthur (1981)'

# Automata (2014)
move_to_deleted '/mnt/media/Movies/Automata (2014)/Automata (2014) {imdb-tt1971325} [Bluray-1080p][DTS 5.1][x264]-iFT.mkv' 'Automata (2014)'

# Babe (1995)
move_to_deleted '/mnt/media/Movies/Babe (1995)/Babe.1995.1080p.BluRay.DTS.x264-DON.mkv' 'Babe (1995)'

# Babes (2024)
move_to_deleted '/mnt/media/Movies/Babes (2024)/Babes (2024) {imdb-tt21276958} [Bluray-1080p][EAC3 5.1][x264]-PTer.mkv' 'Babes (2024)'

# Bad Luck Banging or Loony Porn (2021)
move_to_deleted '/mnt/media/Movies/Bad Luck Banging or Loony Porn (2021)/Bad Luck Banging or Loony Porn (2021) {imdb-tt14033502} [Bluray-1080p][EAC3 5.1][x264]-SPHD.mkv' 'Bad Luck Banging or Loony Porn (2021)'

# Batman Assault on Arkham (2014)
move_to_deleted '/mnt/media/Movies/Batman Assault on Arkham (2014)/Batman.Assault.on.Arkham.2014.1080p.BluRay.DTS.x264-SbR.mkv' 'Batman Assault on Arkham (2014)'

# Batman The Long Halloween, Part One (2021)
move_to_deleted '/mnt/media/Movies/Batman The Long Halloween, Part One (2021)/Batman The Long Halloween Part One (2021) {imdb-tt14324650} [Bluray-1080p][DTS 5.1][x264]-ORBS.mkv' 'Batman The Long Halloween, Part One (2021)'

# Batman Under the Red Hood (2010)
move_to_deleted '/mnt/media/Movies/Batman Under the Red Hood (2010)/Batman Under the Red Hood (2010) {imdb-tt1569923} [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv' 'Batman Under the Red Hood (2010)'

# Batman and Superman Battle of the Super Sons (2022)
move_to_deleted '/mnt/media/Movies/Batman and Superman Battle of the Super Sons (2022)/Batman and Superman Battle of the Super Sons (2022) {imdb-tt21197740} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Batman and Superman Battle of the Super Sons (2022)'

# Batman vs. Robin (2015)
move_to_deleted '/mnt/media/Movies/Batman vs. Robin (2015)/Batman.vs.Robin.2015.1080p.BluRay.x264-ROVERS.mkv' 'Batman vs. Robin (2015)'

# Battlefield Earth (2000)
move_to_deleted '/mnt/media/Movies/Battlefield Earth (2000)/Battlefield.Earth.2000.1080p.BluRay.x264-MAJESTiC.mkv' 'Battlefield Earth (2000)'

# Be Cool (2005)
move_to_deleted '/mnt/media/Movies/Be Cool (2005)/Be Cool (2005) {imdb-tt0377471} [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv' 'Be Cool (2005)'

# Beckett (2021)
move_to_deleted '/mnt/media/Movies/Beckett (2021)/Beckett (2021) {imdb-tt10230994} [NF][WEBDL-1080p][EAC3 5.1][x264]-CMRG.mkv' 'Beckett (2021)'

# Bedazzled (2000)
move_to_deleted '/mnt/media/Movies/Bedazzled (2000)/Bedazzled.2000.1080p.BluRay.DTS.x264.D-Z0N3.mkv' 'Bedazzled (2000)'

# Beethoven\'s 2nd (1993)
move_to_deleted '/mnt/media/Movies/Beethoven\'s 2nd (1993)/Beethoven.2.1993.1080p.BluRay.x264-SPOOKS.mkv' 'Beethoven\'s 2nd (1993)'

# Believer, The (2001) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/Believer, The (2001)/The Believer (2001) {imdb-tt0247199} [Bluray-1080p][EAC3 5.1][x264]-WiLDCAT.mkv' 'Believer, The (2001)'

# Berkshire County (2014)
move_to_deleted '/mnt/media/Movies/Berkshire County (2014)/Berkshire.County.2014.1080p.BluRay.x264-AN0NYM0US.mkv' 'Berkshire County (2014)'

# Better Luck Tomorrow (2002)
move_to_deleted '/mnt/media/Movies/Better Luck Tomorrow (2002)/Better Luck Tomorrow (2002) {imdb-tt0280477} [Bluray-1080p][EAC3 5.1][x264]-PERFETTO.mkv' 'Better Luck Tomorrow (2002)'

# Big Chill, The (1983)
move_to_deleted '/mnt/media/Movies/Big Chill, The (1983)/The Big Chill (1983) {imdb-tt0085244} [Bluray-1080p][DTS 5.1][x264]-HD4U.mkv' 'Big Chill, The (1983)'

# Black Warrant (2023)
move_to_deleted '/mnt/media/Movies/Black Warrant (2023)/Black Warrant (2022) {imdb-tt11696342} [Bluray-1080p][DTS-HD MA 7.1][x264]-CAUSTiC.mkv' 'Black Warrant (2023)'

# Blob, The (1958)
move_to_deleted '/mnt/media/Movies/Blob, The (1958)/The Blob (1958) {imdb-tt0051418} [Criterion Collection][Bluray-1080p][FLAC 1.0][x264]-MaG.mkv' 'Blob, The (1958)'

# Blood and Gold (2023)
move_to_deleted '/mnt/media/Movies/Blood and Gold (2023)/Blood and Gold (2023) {imdb-tt18073328} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-WDYM.mkv' 'Blood and Gold (2023)'

# Blowback (2022)
move_to_deleted '/mnt/media/Movies/Blowback (2022)/Blowback (2022) {imdb-tt1551614} [Bluray-1080p][EAC3 5.1][x264]-GS88.mkv' 'Blowback (2022)'

# Bolero (1984)
move_to_deleted '/mnt/media/Movies/Bolero (1984)/Bolero.1984.1080p.BluRay.x264-SADPANDA.mkv' 'Bolero (1984)'

# Boogeyman (2005)
move_to_deleted '/mnt/media/Movies/Boogeyman (2005)/besthd-boogeyman-1080p.mkv' 'Boogeyman (2005)'

# Borat Cultural Learnings of America for Make Benefit Glorious Nation of Kazakhstan (2006)
move_to_deleted '/mnt/media/Movies/Borat Cultural Learnings of America for Make Benefit Glorious Nation of Kazakhstan (2006)/Borat Cultural Learnings of America for Make Benefit Glorious Nation of Kazakhstan (2006) {imdb-tt0443453} [Bluray-1080p][EAC3 5.1][AV1]-TiZU.mkv' 'Borat Cultural Learnings of America for Make Benefit Glorious Nation of Kazakhstan (2006)'

# The Brutalist (2024) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/The Brutalist (2024)/The Brutalist (2024) {imdb-tt8999762} [Bluray-1080p][EAC3 5.1][x264]-ZoroSenpai.mkv' 'The Brutalist (2024)'

# Bully (2011)
move_to_deleted '/mnt/media/Movies/Bully (2011)/Bully (2011) {imdb-tt1682181} [Bluray-1080p][DTS 5.1][x264]-Counterfeit.mkv' 'Bully (2011)'

# Buried Alive (1990) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/Buried Alive (1990)/Buried Alive (1990) {imdb-tt0099188} [Bluray-1080p Proper][FLAC 2.0][x264]-HANDJOB.mkv' 'Buried Alive (1990)'

# Candyman Farewell to the Flesh (1995)
move_to_deleted '/mnt/media/Movies/Candyman Farewell to the Flesh (1995)/Candyman Farewell to the Flesh (1995) {imdb-tt0112625} [Bluray-1080p][EAC3 5.1][x264]-coffee.mkv' 'Candyman Farewell to the Flesh (1995)'

# Cannonball Run II (1984)
move_to_deleted '/mnt/media/Movies/Cannonball Run II (1984)/Cannonball Run II (1984) {imdb-tt0087032} [Bluray-1080p Proper][EAC3 5.1][x264]-Nufcfan.mkv' 'Cannonball Run II (1984)'

# Casshern (2004)
move_to_deleted '/mnt/media/Movies/Casshern (2004)/Casshern.2004.Japanese.1080p.BluRay.x264-aBD.mkv' 'Casshern (2004)'

# Cats (2019) (480p → 1080p)
move_to_deleted '/mnt/media/Movies/Cats (2019)/Cats (2019) {imdb-tt5697572} [AMZN][WEBDL-720p][EAC3 5.1][h264]-NTG.mkv' 'Cats (2019)'

# Cell, The (2000)
move_to_deleted '/mnt/media/Movies/Cell, The (2000)/The Cell (2000) {imdb-tt0209958} - [Bluray-1080p][EAC3 5.1][x264]-c0kE.mkv' 'Cell, The (2000)'

# Cemetery Man (1994) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/Cemetery Man (1994)/Cemetery Man (1994) {imdb-tt0109592} [Bluray-1080p][DV HDR10][AC3 2.0][x265]-PTer.mkv' 'Cemetery Man (1994)'

# Changing Lanes (2002)
move_to_deleted '/mnt/media/Movies/Changing Lanes (2002)/Changing Lanes (2002) {imdb-tt0264472} [Bluray-1080p][EAC3 5.1][x264]-c0kE.mkv' 'Changing Lanes (2002)'

# Charlie Wilson\'s War (2007)
move_to_deleted '/mnt/media/Movies/Charlie Wilson\'s War (2007)/Charlie Wilsons War (2007) {imdb-tt0472062} [Bluray-1080p][EAC3 5.1][x264]-HiDt.mkv' 'Charlie Wilson\'s War (2007)'

# Charlie\'s Angels Full Throttle (2003)
move_to_deleted '/mnt/media/Movies/Charlie\'s Angels Full Throttle (2003)/Charlies Angels Full Throttle (2003) {imdb-tt0305357} {edition-Unrated} [Bluray-1080p][EAC3 5.1][x264]-PTer.mkv' 'Charlie\'s Angels Full Throttle (2003)'

# Chasing Amy (1997)
move_to_deleted '/mnt/media/Movies/Chasing Amy (1997)/Chasing.Amy.1997.1080p.BluRay.DTS.x264-FoRM.mkv' 'Chasing Amy (1997)'

# Cheeky (2000) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/Cheeky (2000)/Cheeky (2000) {imdb-tt0200192} [Bluray-1080p][EAC3 5.1][x264]-c0kE.mkv' 'Cheeky (2000)'

# Chickenhare and the Hamster of Darkness (2022)
move_to_deleted '/mnt/media/Movies/Chickenhare and the Hamster of Darkness (2022)/Chickenhare.and.the.Hamster.of.Darkness.2022.1080p.BluRay.x264-JustWatch.mkv' 'Chickenhare and the Hamster of Darkness (2022)'

# Choose or Die (2022)
move_to_deleted '/mnt/media/Movies/Choose or Die (2022)/Choose or Die (2022) {imdb-tt11514780} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv' 'Choose or Die (2022)'

# Christmas Chronicles Part Two, The (2020)
move_to_deleted '/mnt/media/Movies/Christmas Chronicles Part Two, The (2020)/The.Christmas.Chronicles.PartTwo.2020.1080p.NF.WEB.DDP5.1.Atmos.x264-AJP69.mkv' 'Christmas Chronicles Part Two, The (2020)'

# Christmas with the Kranks (2004)
move_to_deleted '/mnt/media/Movies/Christmas with the Kranks (2004)/Christmas with the Kranks (2004) {imdb-tt0388419} - [Bluray-1080p][EAC3 5.1][x264]-coffee.mkv' 'Christmas with the Kranks (2004)'

# ChubbChubbs!, The (2002)
move_to_deleted '/mnt/media/Movies/ChubbChubbs!, The (2002)/The ChubbChubbs! (2002) {imdb-tt0331218} - [Bluray-1080p][EAC3 5.1][x264]-PERFETTO.mkv' 'ChubbChubbs!, The (2002)'

# Chuck (2016)
move_to_deleted '/mnt/media/Movies/Chuck (2016)/Chuck.2016.LIMITED.1080p.BluRay.x264-GECKOS.mkv' 'Chuck (2016)'

# Circle of Friends (1995)
move_to_deleted '/mnt/media/Movies/Circle of Friends (1995)/Circle.Of.Friends.1995.1080p.BluRay.x264-VETO.mkv' 'Circle of Friends (1995)'

# City Island (2009)
move_to_deleted '/mnt/media/Movies/City Island (2009)/City.Island.2009.LiMiTED.1080p.BluRay.x264-CiNEFiLE.mkv' 'City Island (2009)'

# City of Life and Death (2009)
move_to_deleted '/mnt/media/Movies/City of Life and Death (2009)/City of Life and Death (2009) {imdb-tt1124052} [Bluray-1080p][DTS 5.1][x264]-HDW.mkv' 'City of Life and Death (2009)'

# Cocoon (1985)
move_to_deleted '/mnt/media/Movies/Cocoon (1985)/Cocoon (1985) {imdb-tt0088933} - [Bluray-1080p][AC3 4.1][x264]-ZoroSenpai.mkv' 'Cocoon (1985)'

# Code 8 (2019)
move_to_deleted '/mnt/media/Movies/Code 8 (2019)/Code 8 (2019) {imdb-tt6259380} - [Bluray-1080p][AC3 5.1][x264]-playHD.mkv' 'Code 8 (2019)'

# Collateral Damage (2002)
move_to_deleted '/mnt/media/Movies/Collateral Damage (2002)/Collateral Damage (2002) {imdb-tt0233469} [Bluray-1080p][DTS 5.1][x264]-SbR.mkv' 'Collateral Damage (2002)'

# Colombiana (2011)
move_to_deleted '/mnt/media/Movies/Colombiana (2011)/Colombiana (2011) {imdb-tt1657507} - {edition-Unrated} [Bluray-1080p][AC3 5.1][x264]-EbP.mkv' 'Colombiana (2011)'

# Color of Money, The (1986)
move_to_deleted '/mnt/media/Movies/Color of Money, The (1986)/the.color.of.money.1986.1080p.bluray.x264-hd4u.mkv' 'Color of Money, The (1986)'

# Commando (1985)
move_to_deleted '/mnt/media/Movies/Commando (1985)/Commando (1985) {imdb-tt0088944} [Bluray-1080p][DTS-HD MA 5.1][x264]-FraMeSToR.mkv' 'Commando (1985)'

# Consenting Adults (1992)
move_to_deleted '/mnt/media/Movies/Consenting Adults (1992)/Consenting Adults (1992) {imdb-tt0104006} [Bluray-1080p][AC3 2.0][x264]-BHDStudio.mp4' 'Consenting Adults (1992)'

# Coyote Ugly (2000)
move_to_deleted '/mnt/media/Movies/Coyote Ugly (2000)/Coyote Ugly (2000) {imdb-tt0200550} [Bluray-1080p][DTS 5.1][x264]-TFiN.mkv' 'Coyote Ugly (2000)'

# Crocodile Dundee II (1988)
move_to_deleted '/mnt/media/Movies/Crocodile Dundee II (1988)/Crocodile Dundee II (1988) {imdb-tt0092493} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv' 'Crocodile Dundee II (1988)'

# Crossing Over (2009)
move_to_deleted '/mnt/media/Movies/Crossing Over (2009)/Crossing.Over.2009.Hybrid.1080p.BluRay.x264-CtrlHD.mkv' 'Crossing Over (2009)'

# Crucible, The (1996)
move_to_deleted '/mnt/media/Movies/Crucible, The (1996)/The.Crucible.1996.1080p.BluRay.x264-SiNNERS.mkv' 'Crucible, The (1996)'

# Darkman III Die Darkman Die (1996)
move_to_deleted '/mnt/media/Movies/Darkman III Die Darkman Die (1996)/Darkman III Die Darkman Die (1996) {imdb-tt0116033} [Bluray-1080p][DTS 2.0][x264]-saimorny.mkv' 'Darkman III Die Darkman Die (1996)'

# Dave Chappelle The Closer (2021)
move_to_deleted '/mnt/media/Movies/Dave Chappelle The Closer (2021)/Dave Chappelle The Closer (2021) {imdb-tt15523010} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-NPMS.mkv' 'Dave Chappelle The Closer (2021)'

# Daytrippers, The (1997)
move_to_deleted '/mnt/media/Movies/Daytrippers, The (1997)/The Daytrippers (1997) {imdb-tt0116041} [Bluray-1080p][FLAC 2.0][x264]-PSYCHD.mkv' 'Daytrippers, The (1997)'

# Dead West (2010)
move_to_deleted '/mnt/media/Movies/Dead West (2010)/Dead.West.2010.720p.BluRay.x264-NOSCREENS.mkv' 'Dead West (2010)'

# Death of Superman, The (2018)
move_to_deleted '/mnt/media/Movies/Death of Superman, The (2018)/The Death of Superman (2018) {imdb-tt7167658} [Bluray-1080p][DTS 5.1][x264]-TayTO.mkv' 'Death of Superman, The (2018)'

# Death of a Salesman (1985)
move_to_deleted '/mnt/media/Movies/Death of a Salesman (1985)/Death of a Salesman (1985) {imdb-tt0089006} [Bluray-1080p][AC3 2.0][x264]-BHDStudio.mp4' 'Death of a Salesman (1985)'

# Decoy Bride, The (2011)
move_to_deleted '/mnt/media/Movies/Decoy Bride, The (2011)/The Decoy Bride (2011) {imdb-tt1657299} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Decoy Bride, The (2011)'

# Detective Knight Rogue (2022)
move_to_deleted '/mnt/media/Movies/Detective Knight Rogue (2022)/Detective Knight Rogue 2022 Hybrid 1080p BluRay DDP 5.1 DV x265-LEGi0N.mkv' 'Detective Knight Rogue (2022)'

# Devil in a Blue Dress (1995)
move_to_deleted '/mnt/media/Movies/Devil in a Blue Dress (1995)/Devil.in.a.Blue.Dress.1995.1080p.BluRay.DDP5.1.x264-iFT.mkv' 'Devil in a Blue Dress (1995)'

# Do the Right Thing (1989)
move_to_deleted '/mnt/media/Movies/Do the Right Thing (1989)/Do the Right Thing (1989) {imdb-tt0097216} - [Bluray-1080p][FLAC 2.0][x264]-ATELiER.mkv' 'Do the Right Thing (1989)'

# Dolittle (2019)
move_to_deleted '/mnt/media/Movies/Dolittle (2019)/Dolittle (2020) {imdb-tt6673612} [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv' 'Dolittle (2019)'

# Don\'t Breathe 2 (2021)
move_to_deleted '/mnt/media/Movies/Don\'t Breathe 2 (2021)/Dont.Breathe.2.2021.1080p.BluRay.DD+7.1.x264-iFT.mkv' 'Don\'t Breathe 2 (2021)'

# Draft Day (2014)
move_to_deleted '/mnt/media/Movies/Draft Day (2014)/Draft Day (2014) {imdb-tt2223990} [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv' 'Draft Day (2014)'

# Driving Miss Daisy (1989)
move_to_deleted '/mnt/media/Movies/Driving Miss Daisy (1989)/Driving Miss Daisy (1989) {imdb-tt0097239} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Driving Miss Daisy (1989)'

# Drumline (2002)
move_to_deleted '/mnt/media/Movies/Drumline (2002)/Drumline.2002.Extended.1080p.Bluray.x264-Japhson.mkv' 'Drumline (2002)'

# Duchess, The (2008)
move_to_deleted '/mnt/media/Movies/Duchess, The (2008)/The Duchess (2008) {imdb-tt0864761} - {edition-Unrated} [Bluray-1080p][AC3 5.1][x264]-DON.mkv' 'Duchess, The (2008)'

# Dumbo (2019)
move_to_deleted '/mnt/media/Movies/Dumbo (2019)/Dumbo (2019) {imdb-tt3861390} [Bluray-1080p][DTS 5.1][x264]-iFT.mkv' 'Dumbo (2019)'

# E.T. the Extra-Terrestrial (1982)
move_to_deleted '/mnt/media/Movies/E.T. the Extra-Terrestrial (1982)/E.T.The.Extra-Terrestrial.1982.1080p.BluRay.DTS.x264-CtrlHD.mkv' 'E.T. the Extra-Terrestrial (1982)'

# Easter Parade (1948)
move_to_deleted '/mnt/media/Movies/Easter Parade (1948)/Easter.Parade.1948.1080p.BluRay.x264-CiNEFiLE.mkv' 'Easter Parade (1948)'

# Easy Money (1983)
move_to_deleted '/mnt/media/Movies/Easy Money (1983)/Easy Money (1983) {imdb-tt0085470} - [AMZN][WEBDL-1080p][EAC3 2.0][h264]-GPRS.mkv' 'Easy Money (1983)'

# Educating Rita (1983)
move_to_deleted '/mnt/media/Movies/Educating Rita (1983)/Educating.Rita.1983.BluRay.1080i.DTS-HD.MA.2.0.AVC.REMUX-FraMeSToR.mkv' 'Educating Rita (1983)'

# Eight Men Out (1988)
move_to_deleted '/mnt/media/Movies/Eight Men Out (1988)/Eight.Men.Out.1988.1080p.BluRay.x264-SiNNERS.mkv' 'Eight Men Out (1988)'

# Eileen (2023) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/Eileen (2023)/Eileen (2023) {imdb-tt5198890} [Bluray-1080p][EAC3 5.1][x264]-HiDt.mkv' 'Eileen (2023)'

# El mariachi (1992)
move_to_deleted '/mnt/media/Movies/El mariachi (1992)/El mariachi.bluray.mkv' 'El mariachi (1992)'

# Elizabeth The Golden Age (2007)
move_to_deleted '/mnt/media/Movies/Elizabeth The Golden Age (2007)/Elizabeth The Golden Age (2007) {imdb-tt0414055} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Elizabeth The Golden Age (2007)'

# Emily the Criminal (2022)
move_to_deleted '/mnt/media/Movies/Emily the Criminal (2022)/Emily the Criminal 2022 BluRay 1080p DDP5.1 x264-LEGi0N.mkv' 'Emily the Criminal (2022)'

# Enforcer, The (2022)
move_to_deleted '/mnt/media/Movies/Enforcer, The (2022)/The Enforcer (2022) {imdb-tt14857730} [Bluray-1080p][AC3 5.1][x264]-playHD.mkv' 'Enforcer, The (2022)'

# Ernest Saves Christmas (1988)
move_to_deleted '/mnt/media/Movies/Ernest Saves Christmas (1988)/Ernest Saves Christmas (1988) {imdb-tt0095107} [WEBRip-1080p][EAC3 2.0][x264]-NTb.mkv' 'Ernest Saves Christmas (1988)'

# Ernest Scared Stupid (1991)
move_to_deleted '/mnt/media/Movies/Ernest Scared Stupid (1991)/Ernest Scared Stupid (1991) {imdb-tt0101821} [Bluray-1080p][AC3 2.0][x264]-FoRM.mkv' 'Ernest Scared Stupid (1991)'

# Escape from Pretoria (2020)
move_to_deleted '/mnt/media/Movies/Escape from Pretoria (2020)/Escape.from.Pretoria.2020.1080p.BluRay.DD+5.1.x264-EDPH.mkv' 'Escape from Pretoria (2020)'

# Evil Dead, The (1981)
move_to_deleted '/mnt/media/Movies/Evil Dead, The (1981)/The Evil Dead (1981) {imdb-tt0083907} {edition-Uncut} [Bluray-1080p][DV HDR10][EAC3 5.1][x265]-SQS.mkv' 'Evil Dead, The (1981)'

# Evita (1996)
move_to_deleted '/mnt/media/Movies/Evita (1996)/Evita (1996) {imdb-tt0116250} [Bluray-1080p][DTS 5.1][x264]-LolHD.mkv' 'Evita (1996)'

# Explorers (1985)
move_to_deleted '/mnt/media/Movies/Explorers (1985)/Explorers.1985.EXTENDED.1080p.BluRay.x264-GAZER.mkv' 'Explorers (1985)'

# Fair Play (2023)
move_to_deleted '/mnt/media/Movies/Fair Play (2023)/Fair Play (2023) {imdb-tt16304446} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Fair Play (2023)'

# Fast Charlie (2023)
move_to_deleted '/mnt/media/Movies/Fast Charlie (2023)/Fast Charlie (2023) {imdb-tt6722400} [Bluray-1080p][EAC3 5.1][x264]-HiDt.mkv' 'Fast Charlie (2023)'

# Fences (2016)
move_to_deleted '/mnt/media/Movies/Fences (2016)/Fences (2016) {imdb-tt2671706} [Bluray-1080p][AC3 5.1][x264]-DON.mkv' 'Fences (2016)'

# Fight or Flight (2025)
move_to_deleted '/mnt/media/Movies/Fight or Flight (2025)/Fight or Flight (2025) {imdb-tt13652286} - [Bluray-1080p][DTS-HD MA 5.1][x264]-GeneMige.mkv' 'Fight or Flight (2025)'

# Film with Me in It, A (2008)
move_to_deleted '/mnt/media/Movies/Film with Me in It, A (2008)/A.Film.With.Me.In.It.2008.1080p.BluRay.x264-PSV.mkv' 'Film with Me in It, A (2008)'

# Firestarter (1984)
move_to_deleted '/mnt/media/Movies/Firestarter (1984)/Firestarter.1984.1080p.BluRay.FLAC2.0.x264-SbR.mkv' 'Firestarter (1984)'

# Firewalker (1986)
move_to_deleted '/mnt/media/Movies/Firewalker (1986)/Firewalker (1986) {imdb-tt0091055} [Bluray-1080p][AC3 2.0][x264]-BHDStudio.mp4' 'Firewalker (1986)'

# First Man (2018)
move_to_deleted '/mnt/media/Movies/First Man (2018)/First.Man.2018.1080p.BluRay.DDP7.1.x264-TayTO.mkv' 'First Man (2018)'

# Fleshpot on 42nd Street (1973) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/Fleshpot on 42nd Street (1973)/Fleshpot on 42nd Street (1973) {imdb-tt0062980} [Bluray-1080p][FLAC 1.0][x264]-HANDJOB.mkv' 'Fleshpot on 42nd Street (1973)'

# Flight of the Phoenix (2004)
move_to_deleted '/mnt/media/Movies/Flight of the Phoenix (2004)/Flight of the Phoenix (2004) {imdb-tt0377062} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Flight of the Phoenix (2004)'

# Flintstones, The (1994)
move_to_deleted '/mnt/media/Movies/Flintstones, The (1994)/The Flintstones (1994) {imdb-tt0109813} [Bluray-1080p Proper][DTS 5.1][x264]-PHOBOS.mkv' 'Flintstones, The (1994)'

# Flying Leathernecks (1951) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/Flying Leathernecks (1951)/Flying Leathernecks (1951) {imdb-tt0043547} - [AMZN][WEBDL-1080p][EAC3 2.0][h264]-GPRS.mkv' 'Flying Leathernecks (1951)'

# For Love of the Game (1999)
move_to_deleted '/mnt/media/Movies/For Love of the Game (1999)/For Love of the Game (1999) {imdb-tt0126916} [Bluray-1080p][AC3 5.1][x264]-HANDJOB.mkv' 'For Love of the Game (1999)'

# Forgiven, The (2022)
move_to_deleted '/mnt/media/Movies/Forgiven, The (2022)/The.Forgiven.2021.1080p.BluRay.x264-PiGNUS.mkv' 'Forgiven, The (2022)'

# Forgotten Battle, The (2020)
move_to_deleted '/mnt/media/Movies/Forgotten Battle, The (2020)/The.Forgotten.Battle.2020.1080p.BluRay.x264-JustWatch.mkv' 'Forgotten Battle, The (2020)'

# Fox and the Hound, The (1981) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/Fox and the Hound, The (1981)/The Fox and the Hound (1981) {imdb-tt0082406} [Bluray-1080p][EAC3 5.1][AV1]-TiZU.mkv' 'Fox and the Hound, The (1981)'

# Frank & Lola (2016)
move_to_deleted '/mnt/media/Movies/Frank & Lola (2016)/Frank and Lola (2016) {imdb-tt1290138} [Bluray-1080p][DTS 5.1][x264]-PriMaLHD.mkv' 'Frank & Lola (2016)'

# Fred Claus (2007)
move_to_deleted '/mnt/media/Movies/Fred Claus (2007)/hd1080-fc.mkv' 'Fred Claus (2007)'

# Free Fire (2017)
move_to_deleted '/mnt/media/Movies/Free Fire (2017)/Free Fire (2017) {imdb-tt4158096} [Bluray-1080p][AC3 5.1][x264]-decibeL.mkv' 'Free Fire (2017)'

# Free Willy (1993)
move_to_deleted '/mnt/media/Movies/Free Willy (1993)/Free Willy (1993) {imdb-tt0106965} [Bluray-1080p][AC3 5.1][x264]-EbP.mkv' 'Free Willy (1993)'

# Freelancers (2012)
move_to_deleted '/mnt/media/Movies/Freelancers (2012)/Freelancers (2012) {imdb-tt1815708} [Bluray-1080p][DTS 5.1][x264]-DON.mkv' 'Freelancers (2012)'

# Friday the 13th Part VIII Jason Takes Manhattan (1989)
move_to_deleted '/mnt/media/Movies/Friday the 13th Part VIII Jason Takes Manhattan (1989)/Friday the 13th Part VIII Jason Takes Manhattan (1989) {imdb-tt0097388} [Bluray-1080p][EAC3 5.1][x264]-hdalx.mkv' 'Friday the 13th Part VIII Jason Takes Manhattan (1989)'

# Fright Night (1985)
move_to_deleted '/mnt/media/Movies/Fright Night (1985)/Fright Night.1985.1080p.BluRay.DDP7.1.x264-iFT.mkv' 'Fright Night (1985)'

# Frosty the Snowman (1969)
move_to_deleted '/mnt/media/Movies/Frosty the Snowman (1969)/Frosty the Snowman (1969) {imdb-tt0064349} [Bluray-1080p][Opus 5.1][x264]-RetroPeeps.mkv' 'Frosty the Snowman (1969)'

# G.I. Joe - The Rise of Cobra (2009)
move_to_deleted '/mnt/media/Movies/G.I. Joe - The Rise of Cobra (2009)/G.I. Joe The Rise of Cobra (2009) {imdb-tt1046173} [Bluray-1080p][DTS 5.1][x264]-EbP.mkv' 'G.I. Joe - The Rise of Cobra (2009)'

# Gabriel Iglesias Hot and Fluffy (2007)
move_to_deleted '/mnt/media/Movies/Gabriel Iglesias Hot and Fluffy (2007)/Gabriel.Iglesias.Hot.and.Fluffy.2007.1080p.BluRay.x264-SADPANDA.mkv' 'Gabriel Iglesias Hot and Fluffy (2007)'

# Game of Death (1978)
move_to_deleted '/mnt/media/Movies/Game of Death (1978)/Game of Death (1978) {imdb-tt0077594} - [Criterion Collection][Bluray-1080p][FLAC 1.0][x264]-HDH.mkv' 'Game of Death (1978)'

# George Carlin 40 Years of Comedy (1997)
move_to_deleted '/mnt/media/Movies/George Carlin 40 Years of Comedy (1997)/MeftbBGWGZAOsQeMCIkrqZLllPNUzqBO.mkv' 'George Carlin 40 Years of Comedy (1997)'

# The Ghost & Mr. Chicken (1966)
move_to_deleted '/mnt/media/Movies/The Ghost & Mr. Chicken (1966)/The.Ghost.and.Mr.Chicken.1966.1080p.BluRay.X264-PSYCHD.mkv' 'The Ghost & Mr. Chicken (1966)'

# Ghosts of the Abyss (2003)
move_to_deleted '/mnt/media/Movies/Ghosts of the Abyss (2003)/Ghosts of the Abyss (2003) {imdb-tt0297144} [Bluray-1080p][AC3 5.1][x264]-DON.mkv' 'Ghosts of the Abyss (2003)'

# Gia (1998)
move_to_deleted '/mnt/media/Movies/Gia (1998)/Gia.1998.Unrated.BluRay.1080p.DD.5.1.x264-BHDStudio.mp4' 'Gia (1998)'

# Girl with a Pearl Earring (2003)
move_to_deleted '/mnt/media/Movies/Girl with a Pearl Earring (2003)/Girl with a Pearl Earring (2003) {imdb-tt0335119} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Girl with a Pearl Earring (2003)'

# Gladiator (1992)
move_to_deleted '/mnt/media/Movies/Gladiator (1992)/Gladiator (1992) {imdb-tt0104346} [AMZN][WEBRip-1080p][EAC3 2.0][x264]-pawel2006.mkv' 'Gladiator (1992)'

# Glass (2019)
move_to_deleted '/mnt/media/Movies/Glass (2019)/Glass (2019) {imdb-tt6823368} - [Hybrid][Bluray-1080p Proper][EAC3 7.1][x264]-DON.mkv' 'Glass (2019)'

# Goblin (2010)
move_to_deleted '/mnt/media/Movies/Goblin (2010)/Goblin.2010.1080p.BluRay.x264-THUGLiNE.mkv' 'Goblin (2010)'

# Goofy Movie, A (1995)
move_to_deleted '/mnt/media/Movies/Goofy Movie, A (1995)/A.Goofy.Movie.1995.1080p.BluRay.DD2.0.x264.D-Z0N3.mkv' 'Goofy Movie, A (1995)'

# Grapes of Wrath, The (1940) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/Grapes of Wrath, The (1940)/The Grapes of Wrath (1940) {imdb-tt0032551} [Bluray-1080p][FLAC 1.0][x264]-DON.mkv' 'Grapes of Wrath, The (1940)'

# Gravy (2015)
move_to_deleted '/mnt/media/Movies/Gravy (2015)/Gravy.2015.1080p.BluRay.x264-ROVERS.mkv' 'Gravy (2015)'

# Grease (1978)
move_to_deleted '/mnt/media/Movies/Grease (1978)/Grease (1978) {imdb-tt0077631} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv' 'Grease (1978)'

# Great Outdoors, The (1988)
move_to_deleted '/mnt/media/Movies/Great Outdoors, The (1988)/The Great Outdoors (1988) {imdb-tt0095253} [Bluray-1080p][FLAC 2.0][x264]-Geek.mkv' 'Great Outdoors, The (1988)'

# Green Lantern Beware My Power (2022)
move_to_deleted '/mnt/media/Movies/Green Lantern Beware My Power (2022)/Green.Lantern.Beware.My.Power.2022.1080p.BluRay.x264-PiGNUS.mkv' 'Green Lantern Beware My Power (2022)'

# Green Zone (2010)
move_to_deleted '/mnt/media/Movies/Green Zone (2010)/Green Zone (2010) {imdb-tt0947810} [Hybrid][Bluray-1080p][AC3 5.1][x264]-SA89.mkv' 'Green Zone (2010)'

# Greenland (2020)
move_to_deleted '/mnt/media/Movies/Greenland (2020)/Greenland.2020.1080p.Repack2.BluRay.DD+7.1.x264-iFT.mkv' 'Greenland (2020)'

# Guys and Dolls (1955)
move_to_deleted '/mnt/media/Movies/Guys and Dolls (1955)/Guys.and.Dolls.1955.1080p.BluRay.x264-PSYCHD.mkv' 'Guys and Dolls (1955)'

# Hack-O-Lantern (1988)
move_to_deleted '/mnt/media/Movies/Hack-O-Lantern (1988)/Hack-O-Lantern (1988) {imdb-tt0093135} [Bluray-1080p][AC3 2.0][x264]-WiSDOM.mkv' 'Hack-O-Lantern (1988)'

# Halloween H20 20 Years Later (1998)
move_to_deleted '/mnt/media/Movies/Halloween H20 20 Years Later (1998)/Halloween H20 20 Years Later (1998) {imdb-tt0120694} [Bluray-1080p][EAC3 5.1][x264]-c0kE.mkv' 'Halloween H20 20 Years Later (1998)'

# Hampstead (2017)
move_to_deleted '/mnt/media/Movies/Hampstead (2017)/Hampstead (2017) {imdb-tt5153236} [Bluray-1080p][AC3 5.1][x264]-KASHMiR.mkv' 'Hampstead (2017)'

# Hansan Rising Dragon (2022)
move_to_deleted '/mnt/media/Movies/Hansan Rising Dragon (2022)/Hansan Rising Dragon (2022) {imdb-tt21109538} [Bluray-1080p][EAC3 5.1][x264]-MeeSta.mkv' 'Hansan Rising Dragon (2022)'

# Happening (2021)
move_to_deleted '/mnt/media/Movies/Happening (2021)/Happening (2021) {imdb-tt13880104} [Bluray-1080p][EAC3 5.1][x264]-EA.mkv' 'Happening (2021)'

# Hard Candy (2005) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/Hard Candy (2005)/Hard Candy 2005 1080p BluRay DD5.1 x264-RDK123.mkv' 'Hard Candy (2005)'

# Harley Davidson and the Marlboro Man (1991)
move_to_deleted '/mnt/media/Movies/Harley Davidson and the Marlboro Man (1991)/Harley Davidson and the Marlboro Man (1991) {imdb-tt0102005} [Bluray-1080p][FLAC 2.0][x264]-iFT.mkv' 'Harley Davidson and the Marlboro Man (1991)'

# Harold and Maude (1971)
move_to_deleted '/mnt/media/Movies/Harold and Maude (1971)/Harold and Maude (1971) {imdb-tt0067185} [Bluray-1080p][EAC3 5.1][x264]-DON.mkv' 'Harold and Maude (1971)'

# Hasan Minhaj The King\'s Jester (2022)
move_to_deleted '/mnt/media/Movies/Hasan Minhaj The King\'s Jester (2022)/Hasan Minhaj The Kings Jester (2022) {imdb-tt21994438} [NF][WEBDL-1080p][EAC3 5.1][x264]-SMURF.mkv' 'Hasan Minhaj The King\'s Jester (2022)'

# Hateful Eight, The - Extended Version (2015)
move_to_deleted '/mnt/media/Movies/Hateful Eight, The - Extended Version (2015)/The.Hateful.Eight.2015.{Edition-Extended Version}.Chapter.4.The.Last.Chapter.1080p.NF.WEB-DL.DDP5.1.HEVC-MZABI part4.mkv' 'Hateful Eight, The - Extended Version (2015)'

# Heavyweights (1995)
move_to_deleted '/mnt/media/Movies/Heavyweights (1995)/Heavyweights (1995) {imdb-tt0110006} [Bluray-1080p][DTS 5.1][x264]-Japhson.mkv' 'Heavyweights (1995)'

# Hellbender (2021)
move_to_deleted '/mnt/media/Movies/Hellbender (2021)/Hellbender (2021) {imdb-tt14905650} - [Bluray-1080p][EAC3 5.1][x264]-GS88.mkv' 'Hellbender (2021)'

# Hellboy (2019)
move_to_deleted '/mnt/media/Movies/Hellboy (2019)/Hellboy (2019) {imdb-tt2274648} [Bluray-1080p][EAC3 7.1][x264]-SbR.mkv' 'Hellboy (2019)'

# Hellraiser Judgment (2018)
move_to_deleted '/mnt/media/Movies/Hellraiser Judgment (2018)/Hellraiser Judgment (2018) {imdb-tt5476182} [Bluray-1080p][DTS 5.1][x264]-PSYCHD.mkv' 'Hellraiser Judgment (2018)'

# Henry V (1989)
move_to_deleted '/mnt/media/Movies/Henry V (1989)/Henry V (1989) {imdb-tt0097499} - [Bluray-1080p][FLAC 2.0][x264]-dps.mkv' 'Henry V (1989)'

# Hero and the Terror (1988)
move_to_deleted '/mnt/media/Movies/Hero and the Terror (1988)/Hero.and.the.Terror.1988.1080p.BluRay.x264-SADPANDA.mkv' 'Hero and the Terror (1988)'

# Hero, The (2017)
move_to_deleted '/mnt/media/Movies/Hero, The (2017)/The Hero (2017) {imdb-tt5655222} [Bluray-1080p][DTS 5.1][x264]-TayTO.mkv' 'Hero, The (2017)'

# Hollow, The (2015)
move_to_deleted '/mnt/media/Movies/Hollow, The (2015)/The.Hollow.2015.1080p.BluRay.x264-PussyFoot.mkv' 'Hollow, The (2015)'

# Holy Man (1998)
move_to_deleted '/mnt/media/Movies/Holy Man (1998)/Holy.Man.1998.1080p.BluRay.x264-HD4U.mkv' 'Holy Man (1998)'

# Home (2015)
move_to_deleted '/mnt/media/Movies/Home (2015)/Home (2015) {imdb-tt2224026} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Home (2015)'

# Hoodwinked! (2005)
move_to_deleted '/mnt/media/Movies/Hoodwinked! (2005)/Hoodwinked! (2005) {imdb-tt0443536} - [Bluray-1080p][EAC3 5.1][x264]-Spyfox.mkv' 'Hoodwinked! (2005)'

# Hotel Desire (2011)
move_to_deleted '/mnt/media/Movies/Hotel Desire (2011)/Hotel Desire (2011) {imdb-tt2080323} [Bluray-1080p][DTS 5.1][x264]-HDChina.mkv' 'Hotel Desire (2011)'

# Hotel Rwanda (2004)
move_to_deleted '/mnt/media/Movies/Hotel Rwanda (2004)/Hotel.Rwanda.2004.1080p.BluRay.DTS.x264-CtrlHD.mkv' 'Hotel Rwanda (2004)'

# Hubie Halloween (2020)
move_to_deleted '/mnt/media/Movies/Hubie Halloween (2020)/Hubie Halloween (2020) {imdb-tt10682266} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv' 'Hubie Halloween (2020)'

# Huda\'s Salon (2022)
move_to_deleted '/mnt/media/Movies/Huda\'s Salon (2022)/Hudas Salon (2022) {imdb-tt11897340} [WEBDL-1080p][AC3 5.1][h264]-TEPES.mkv' 'Huda\'s Salon (2022)'

# Hudson Hawk (1991)
move_to_deleted '/mnt/media/Movies/Hudson Hawk (1991)/Hudson Hawk (1991) {imdb-tt0102070} [Bluray-1080p][FLAC 2.0][x264]-SbR.mkv' 'Hudson Hawk (1991)'

# Hudsucker Proxy, The (1994)
move_to_deleted '/mnt/media/Movies/Hudsucker Proxy, The (1994)/The Hudsucker Proxy (1994) {imdb-tt0110074} [Bluray-1080p][EAC3 5.1][x264]-RO.mkv' 'Hudsucker Proxy, The (1994)'

# Hulk (2003)
move_to_deleted '/mnt/media/Movies/Hulk (2003)/Hulk (2003) {imdb-tt0286716} [Bluray-1080p][DTS-X 7.1][x264]-TIGER.mkv' 'Hulk (2003)'

# I Love Trouble (1994)
move_to_deleted '/mnt/media/Movies/I Love Trouble (1994)/I Love Trouble (1994) {imdb-tt0110093} [Bluray-1080p][DTS 5.1][x264]-PSYCHD.mkv' 'I Love Trouble (1994)'

# IMAX Australia - Land Beyond Time (2002)
move_to_deleted '/mnt/media/Movies/IMAX Australia - Land Beyond Time (2002)/Australia Land Beyond Time (2002) {imdb-tt0325033} [Bluray-1080p][AC3 5.1][x264]-vHD.mkv' 'IMAX Australia - Land Beyond Time (2002)'

# Impossible, The (2012)
move_to_deleted '/mnt/media/Movies/Impossible, The (2012)/The Impossible (2012) {imdb-tt1649419} [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv' 'Impossible, The (2012)'

# In the Shadow of the Moon (2019)
move_to_deleted '/mnt/media/Movies/In the Shadow of the Moon (2019)/In.the.Shadow.of.the.Moon.2019.1080p.NF.WEB-DL.DDP5.1.Atmos.x264-CMRG.mkv' 'In the Shadow of the Moon (2019)'

# Incredibles, The (2004)
move_to_deleted '/mnt/media/Movies/Incredibles, The (2004)/The Incredibles (2004) {imdb-tt0317705} [Bluray-1080p Proper][EAC3 7.1][x264]-c0kE.mkv' 'Incredibles, The (2004)'

# Independence Day (1996)
move_to_deleted '/mnt/media/Movies/Independence Day (1996)/Independence Day (1996) {imdb-tt0116629} {edition-Theatrical Cut} [Bluray-1080p][DTS 5.1][x264]-NTb.mkv' 'Independence Day (1996)'

# Indiscreet (1958)
move_to_deleted '/mnt/media/Movies/Indiscreet (1958)/Indiscreet (1958) {imdb-tt0051773} [Bluray-1080p][Opus 1.0][x264]-RetroPeeps.mkv' 'Indiscreet (1958)'

# Inherent Vice (2014)
move_to_deleted '/mnt/media/Movies/Inherent Vice (2014)/Inherent.Vice.2014.1080p.BluRay.DTS.x264-EbP.mkv' 'Inherent Vice (2014)'

# Injustice (2021)
move_to_deleted '/mnt/media/Movies/Injustice (2021)/Injustice (2021) {imdb-tt5012504} [Bluray-1080p][DTS 5.1][x264]-ADE.mkv' 'Injustice (2021)'

# Insomnia (2002)
move_to_deleted '/mnt/media/Movies/Insomnia (2002)/Insomnia.2002.1080p.BluRay.DD5.1.x264-CtrlHD.mkv' 'Insomnia (2002)'

# Into the Blue (2005)
move_to_deleted '/mnt/media/Movies/Into the Blue (2005)/Into the Blue (2005) {imdb-tt0378109} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv' 'Into the Blue (2005)'

# Ip Man 4 The Finale (2019)
move_to_deleted '/mnt/media/Movies/Ip Man 4 The Finale (2019)/Ip Man 4 The Finale (2019) {imdb-tt2076298} [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv' 'Ip Man 4 The Finale (2019)'

# Ip Man The Awakening (2022)
move_to_deleted '/mnt/media/Movies/Ip Man The Awakening (2022)/Ip Man The Awakening (2021) {imdb-tt21028848} - [Bluray-1080p][DTS 5.1][x264]-EVO.mkv' 'Ip Man The Awakening (2022)'

# Iron Sky The Coming Race (2019)
move_to_deleted '/mnt/media/Movies/Iron Sky The Coming Race (2019)/Iron Sky The Coming Race (2019) {imdb-tt3038708} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Iron Sky The Coming Race (2019)'

# Ironweed (1987)
move_to_deleted '/mnt/media/Movies/Ironweed (1987)/Ironweed (1987) {imdb-tt0093277} [Bluray-1080p][DTS 2.0][x264]-PSYCHD.mkv' 'Ironweed (1987)'

# It\'s the Great Pumpkin, Charlie Brown (1966) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/It\'s the Great Pumpkin, Charlie Brown (1966)/Its the Great Pumpkin Charlie Brown (1966) {imdb-tt0060550} [Bluray-1080p Proper][DTS 5.1][x264]-cinefile.mkv' 'It\'s the Great Pumpkin, Charlie Brown (1966)'

# Jason Goes to Hell The Final Friday (1993)
move_to_deleted '/mnt/media/Movies/Jason Goes to Hell The Final Friday (1993)/Jason Goes to Hell The Final Friday (1993) {imdb-tt0107254} [Bluray-1080p][DTS 5.1][x264]-LiViDiTY.mkv' 'Jason Goes to Hell The Final Friday (1993)'

# Jay and Silent Bob Strike Back (2001)
move_to_deleted '/mnt/media/Movies/Jay and Silent Bob Strike Back (2001)/Jay and Silent Bob Strike Back (2001) {imdb-tt0261392} [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv' 'Jay and Silent Bob Strike Back (2001)'

# Jeepers Creepers (2001)
move_to_deleted '/mnt/media/Movies/Jeepers Creepers (2001)/Jeepers Creepers 2001 1080p Bluray DTS x264-TayTO.mkv' 'Jeepers Creepers (2001)'

# Jerk, The (1979)
move_to_deleted '/mnt/media/Movies/Jerk, The (1979)/The Jerk (1979) {imdb-tt0079367} [Bluray-1080p][EAC3 5.1][x264]-MeeSta.mkv' 'Jerk, The (1979)'

# Jim Jefferies Alcoholocaust (2010)
move_to_deleted '/mnt/media/Movies/Jim Jefferies Alcoholocaust (2010)/Jim.Jefferies.Alcoholocaust.2010.1080p.WEBRip.DD2.0.x264-MXB.mkv' 'Jim Jefferies Alcoholocaust (2010)'

# Jimmy\'s Hall (2014)
move_to_deleted '/mnt/media/Movies/Jimmy\'s Hall (2014)/Jimmys Hall (2014) {imdb-tt3110960} [Bluray-1080p][DTS 5.1][x264]-WEST.mkv' 'Jimmy\'s Hall (2014)'

# John Q (2002)
move_to_deleted '/mnt/media/Movies/John Q (2002)/John Q (2002) {imdb-tt0251160} [Bluray-1080p][DTS 5.1][x264]-DON.mkv' 'John Q (2002)'

# Ju-on The Grudge (2002)
move_to_deleted '/mnt/media/Movies/Ju-on The Grudge (2002)/Ju-on The Grudge (2002) {imdb-tt0364385} - [Bluray-1080p Proper][EAC3 5.1][x264]-c0kE.mkv' 'Ju-on The Grudge (2002)'

# Just Friends (2005)
move_to_deleted '/mnt/media/Movies/Just Friends (2005)/Just.Friends.2005.1080p.Bluray.X264-DIMENSION.mkv' 'Just Friends (2005)'

# Just Getting Started (2017)
move_to_deleted '/mnt/media/Movies/Just Getting Started (2017)/Just.Getting.Started.2017.1080p.BluRay.x264-DRONES.mkv' 'Just Getting Started (2017)'

# Justice League The New Frontier (2008)
move_to_deleted '/mnt/media/Movies/Justice League The New Frontier (2008)/Justice League The New Frontier (2008) {imdb-tt0902272} [WEBDL-1080p][EAC3 5.1][x264]-Kitsune.mkv' 'Justice League The New Frontier (2008)'

# Keeping Up with the Joneses (2016)
move_to_deleted '/mnt/media/Movies/Keeping Up with the Joneses (2016)/Keeping Up with the Joneses (2016) {imdb-tt2387499} [Bluray-1080p][DTS-ES 5.1][x264]-TayTO.mkv' 'Keeping Up with the Joneses (2016)'

# King of Staten Island, The (2020)
move_to_deleted '/mnt/media/Movies/King of Staten Island, The (2020)/The King of Staten Island (2020) {imdb-tt9686708} - [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv' 'King of Staten Island, The (2020)'

# Krampus (2015)
move_to_deleted '/mnt/media/Movies/Krampus (2015)/Krampus (2015) {imdb-tt3850590} - [Bluray-1080p][EAC3 7.1][x264]-coffee.mkv' 'Krampus (2015)'

# Krull (1983)
move_to_deleted '/mnt/media/Movies/Krull (1983)/Krull.1983.BluRay.1080p.DD.5.1.x264-BHDStudio.mp4' 'Krull (1983)'

# Kung Fury (2015)
move_to_deleted '/mnt/media/Movies/Kung Fury (2015)/Kung Fury (2015) {imdb-tt3472226} [Bluray-1080p][AC3 2.0][x264]-NTb.mkv' 'Kung Fury (2015)'

# LEGO DC Comics Super Heroes Batman Be-Leaguered (2014)
move_to_deleted '/mnt/media/Movies/LEGO DC Comics Super Heroes Batman Be-Leaguered (2014)/LEGO DC Comics Super Heroes Batman Be-Leaguered (2014) {imdb-tt4189294} - [PCOK][WEBDL-1080p][AAC 2.0][x264]-Hurtom.mkv' 'LEGO DC Comics Super Heroes Batman Be-Leaguered (2014)'

# LEGO DC Comics Super Heroes Justice League vs. Bizarro League (2015)
move_to_deleted '/mnt/media/Movies/LEGO DC Comics Super Heroes Justice League vs. Bizarro League (2015)/LEGO.DC.Justice.League.vs.Bizarro.League.2015.1080p.BluRay.x264-KAZETV.mkv' 'LEGO DC Comics Super Heroes Justice League vs. Bizarro League (2015)'

# LEGO Star Wars Terrifying Tales (2021)
move_to_deleted '/mnt/media/Movies/LEGO Star Wars Terrifying Tales (2021)/Lego Star Wars Terrifying Tales.2021.1080p.DSNYP.WEB-DL.H264.Atmos-EVO.mkv' 'LEGO Star Wars Terrifying Tales (2021)'

# Ladybugs (1992)
move_to_deleted '/mnt/media/Movies/Ladybugs (1992)/Ladybugs.1992.1080p.BluRay.x264-LCHD.mkv' 'Ladybugs (1992)'

# Lamborghini The Man Behind the Legend (2022)
move_to_deleted '/mnt/media/Movies/Lamborghini The Man Behind the Legend (2022)/Lamborghini The Man Behind the Legend (2022) {imdb-tt5533370} [Bluray-1080p][EAC3 5.1][x264]-BiTOR.mkv' 'Lamborghini The Man Behind the Legend (2022)'

# Last Christmas (2019)
move_to_deleted '/mnt/media/Movies/Last Christmas (2019)/Last.Christmas.2019.RERiP.1080p.BluRay.x264-GUACAMOLE.mkv' 'Last Christmas (2019)'

# Last Looks (2021)
move_to_deleted '/mnt/media/Movies/Last Looks (2021)/Last Looks (2022) {imdb-tt9244554} [Bluray-1080p][EAC3 5.1][x264]-NTb.mkv' 'Last Looks (2021)'

# Last Survivors (2022)
move_to_deleted '/mnt/media/Movies/Last Survivors (2022)/Last.Survivors.2021.1080p.BluRay.x264-UNVEiL.mkv' 'Last Survivors (2022)'

# Legend (2015)
move_to_deleted '/mnt/media/Movies/Legend (2015)/Legend (2015) {imdb-tt3569230} - [Bluray-1080p][EAC3 Atmos 5.1][x264]-hallowed.mkv' 'Legend (2015)'

# Lego Batman The Movie DC Superheroes Unite (2013)
move_to_deleted '/mnt/media/Movies/Lego Batman The Movie DC Superheroes Unite (2013)/LEGO Batman The Movie DC Super Heroes Unite (2013) {imdb-tt2465238} [Bluray-1080p][DTS 5.1][x264]-FANDANGO.mkv' 'Lego Batman The Movie DC Superheroes Unite (2013)'

# Lego DC Comics Super Heroes The Flash (2018)
move_to_deleted '/mnt/media/Movies/Lego DC Comics Super Heroes The Flash (2018)/Lego.DC.Comics.Super.Heroes.The.Flash.2018.1080p.BluRay.X264-iNVANDRAREN.mkv' 'Lego DC Comics Super Heroes The Flash (2018)'

# Let\'s Be Cops (2014)
move_to_deleted '/mnt/media/Movies/Let\'s Be Cops (2014)/Let\'s Be Cops 2014 1080p BluRay DD5.1 x264-EbP.mkv' 'Let\'s Be Cops (2014)'

# Lifeforce (1985)
move_to_deleted '/mnt/media/Movies/Lifeforce (1985)/Lifeforce (1985) {imdb-tt0089489} - {edition-Directors Cut} [Bluray-1080p][FLAC 2.0][x264]-ZoroSenpai.mkv' 'Lifeforce (1985)'

# Lilting (2014)
move_to_deleted '/mnt/media/Movies/Lilting (2014)/Lilting (2014) {imdb-tt2560102} [Bluray-1080p][DTS 5.1][x264]-GECKOS.mkv' 'Lilting (2014)'

# Logan\'s Run (1976)
move_to_deleted '/mnt/media/Movies/Logan\'s Run (1976)/Logans Run (1976) {imdb-tt0074812} [Bluray-1080p][EAC3 5.1][x264]-BitHD.mkv' 'Logan\'s Run (1976)'

# Lone Wolf McQuade (1983)
move_to_deleted '/mnt/media/Movies/Lone Wolf McQuade (1983)/Lone Wolf McQuade (1983) {imdb-tt0085862} [Bluray-1080p][FLAC 2.0][x264]-iFT.mkv' 'Lone Wolf McQuade (1983)'

# Lost Illusions (2021)
move_to_deleted '/mnt/media/Movies/Lost Illusions (2021)/Lost.Illusions.2021.1080p.BluRay.x264-JustWatch.mkv' 'Lost Illusions (2021)'

# Lost in Translation (2003)
move_to_deleted '/mnt/media/Movies/Lost in Translation (2003)/Lost in Translation (2003) {imdb-tt0335266} [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv' 'Lost in Translation (2003)'

# Love at First Sight (2023)
move_to_deleted '/mnt/media/Movies/Love at First Sight (2023)/Love at First Sight (2023) {imdb-tt2183014} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-Kitsune.mkv' 'Love at First Sight (2023)'

# Loving Adults (2022)
move_to_deleted '/mnt/media/Movies/Loving Adults (2022)/Loving.Adults.2022.1080p.NF.WEB-DL.DDP5.1.DoVi.H.265-FiB.mkv' 'Loving Adults (2022)'

# Lucas (1986)
move_to_deleted '/mnt/media/Movies/Lucas (1986)/Lucas (1986) {imdb-tt0091445} [Bluray-1080p][EAC3 5.1][x264]-MeeSta.mkv' 'Lucas (1986)'

# Machete (2010)
move_to_deleted '/mnt/media/Movies/Machete (2010)/Machete (2010) {imdb-tt0985694} - [Bluray-1080p][AC3 5.1][x264]-EbP.mkv' 'Machete (2010)'

# Major League II (1994)
move_to_deleted '/mnt/media/Movies/Major League II (1994)/Major League II (1994) {imdb-tt0110442} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Major League II (1994)'

# Major Payne (1995)
move_to_deleted '/mnt/media/Movies/Major Payne (1995)/Major Payne (1995) {imdb-tt0110443} [Bluray-1080p][DTS 5.1][x264]-DON.mkv' 'Major Payne (1995)'

# Malicious (1973)
move_to_deleted '/mnt/media/Movies/Malicious (1973)/Malicious (1973) {imdb-tt0070358} [Bluray-1080p][DTS 5.1][x264]-ADE.mkv' 'Malicious (1973)'

# Mallrats (1995)
move_to_deleted '/mnt/media/Movies/Mallrats (1995)/Mallrats.1995.Extended.Cut.1080p.BluRay.DD+5.1.x264-iFT.mkv' 'Mallrats (1995)'

# Mamma Mia! (2008)
move_to_deleted '/mnt/media/Movies/Mamma Mia! (2008)/Mamma Mia! (2008) {imdb-tt0795421} [Bluray-1080p][EAC3 7.1][x264]-TayTO.mkv' 'Mamma Mia! (2008)'

# Man Who Knew Infinity, The (2015)
move_to_deleted '/mnt/media/Movies/Man Who Knew Infinity, The (2015)/The Man Who Knew Infinity (2016) {imdb-tt0787524} [Bluray-1080p][AC3 5.1][x264]-DON.mkv' 'Man Who Knew Infinity, The (2015)'

# Marauders (2016)
move_to_deleted '/mnt/media/Movies/Marauders (2016)/Marauders.2016.BluRay.1080p.DTS-HD.MA.5.1.x264.dxva-FraMeSToR.mkv' 'Marauders (2016)'

# Marriage Story (2019) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/Marriage Story (2019)/Marriage.Story.2019.1080p.BluRay.DTS.x264-PbK.mkv' 'Marriage Story (2019)'

# Mask (1985)
move_to_deleted '/mnt/media/Movies/Mask (1985)/Mask (1985) {imdb-tt0089560} {edition-Directors Cut} [Bluray-1080p][EAC3 5.1][x264]-PiNE.mkv' 'Mask (1985)'

# Masters of the Universe (1987)
move_to_deleted '/mnt/media/Movies/Masters of the Universe (1987)/Masters of the Universe (1987) {imdb-tt0093507} [Hybrid][Bluray-1080p][FLAC 2.0][x264]-MaG.mkv' 'Masters of the Universe (1987)'

# Matt Rife Natural Selection (2023)
move_to_deleted '/mnt/media/Movies/Matt Rife Natural Selection (2023)/Matt Rife Natural Selection (2023) {imdb-tt29650142} - [NF][WEBDL-1080p][EAC3 5.1][x264]-Kitsune.mkv' 'Matt Rife Natural Selection (2023)'

# Mazinger Z Infinity (2017)
move_to_deleted '/mnt/media/Movies/Mazinger Z Infinity (2017)/Mazinger Z Infinity (2017) {imdb-tt6470762} [Bluray-1080p][DTS-HD MA 5.1][x264]-PbK.mkv' 'Mazinger Z Infinity (2017)'

# Meatballs (1979)
move_to_deleted '/mnt/media/Movies/Meatballs (1979)/meatballs.1979.1080p.bluray.x264-filmhd.mkv' 'Meatballs (1979)'

# Medieval (2022)
move_to_deleted '/mnt/media/Movies/Medieval (2022)/Medieval (2022) {imdb-tt8883486} [Bluray-1080p][AC3 5.1][x264]-playHD.mkv' 'Medieval (2022)'

# Meet Me Next Christmas (2024)
move_to_deleted '/mnt/media/Movies/Meet Me Next Christmas (2024)/Meet Me Next Christmas (2024) {imdb-tt20502488} - [NF][WEBDL-1080p Proper][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Meet Me Next Christmas (2024)'

# Meg, The (2018)
move_to_deleted '/mnt/media/Movies/Meg, The (2018)/The.Meg.2018.1080p.BluRay.DDP.7.1.DV.x265-LEGi0N.mkv' 'Meg, The (2018)'

# Megamind The Button of Doom (2011)
move_to_deleted '/mnt/media/Movies/Megamind The Button of Doom (2011)/Megamind The Button Of Doom.2011.BluRay.1080p.DTS.x264.dxva-decibeL.mkv' 'Megamind The Button of Doom (2011)'

# Memoirs of an Invisible Man (1992)
move_to_deleted '/mnt/media/Movies/Memoirs of an Invisible Man (1992)/Memoirs of an Invisible Man (1992) {imdb-tt0104850} [Bluray-1080p][FLAC 2.0][x264]-Kitsune.mkv' 'Memoirs of an Invisible Man (1992)'

# Men (2022)
move_to_deleted '/mnt/media/Movies/Men (2022)/Men.2022.1080p.BluRay.DDP.5.1.DV.x265-LEGi0N.mkv' 'Men (2022)'

# Metal Lords (2022)
move_to_deleted '/mnt/media/Movies/Metal Lords (2022)/Metal Lords (2022) {imdb-tt12141112} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-TEPES.mkv' 'Metal Lords (2022)'

# Michael Bublé Meets Madison Square Garden (2009)
move_to_deleted '/mnt/media/Movies/Michael Bublé Meets Madison Square Garden (2009)/Michael Bublé Meets Madison Square Garden.bluray.mkv' 'Michael Bublé Meets Madison Square Garden (2009)'

# Midnight in the Garden of Good and Evil (1997)
move_to_deleted '/mnt/media/Movies/Midnight in the Garden of Good and Evil (1997)/Midnight in the Garden of Good and Evil (1997) {imdb-tt0119668} [Bluray-1080p][DTS 5.1][x264]-OmertaHD.mkv' 'Midnight in the Garden of Good and Evil (1997)'

# Miss Congeniality (2000)
move_to_deleted '/mnt/media/Movies/Miss Congeniality (2000)/Miss Congeniality (2000) {imdb-tt0212346} [Bluray-1080p][DTS-HD MA 5.1][VC1]-TWA.mkv' 'Miss Congeniality (2000)'

# Mixed Nuts (1994)
move_to_deleted '/mnt/media/Movies/Mixed Nuts (1994)/Mixed Nuts (1994) {imdb-tt0110538} [AMZN][WEBRip-1080p][EAC3 2.0][x264]-ABM.mkv' 'Mixed Nuts (1994)'

# Moonraker (1979)
move_to_deleted '/mnt/media/Movies/Moonraker (1979)/Moonraker (1979) {imdb-tt0079574} [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv' 'Moonraker (1979)'

# Mortal Kombat Legends Battle of the Realms (2021)
move_to_deleted '/mnt/media/Movies/Mortal Kombat Legends Battle of the Realms (2021)/Mortal Kombat Legends Battle of the Realms (2021) {imdb-tt14901058} [Bluray-1080p][AC3 5.1][x264]-HANDJOB.mkv' 'Mortal Kombat Legends Battle of the Realms (2021)'

# Mortal Kombat Legends Scorpion\'s Revenge (2020)
move_to_deleted '/mnt/media/Movies/Mortal Kombat Legends Scorpion\'s Revenge (2020)/mortal.kombat.legends.scorpions.revenge.2020.1080p.bluray.x264-yol0w.mkv' 'Mortal Kombat Legends Scorpion\'s Revenge (2020)'

# Most Wonderful Time of the Year, The (2008)
move_to_deleted '/mnt/media/Movies/Most Wonderful Time of the Year, The (2008)/The.Most.Wonderful.Time.Of.The.Year.2008.1080p.BluRay.x264-UNTOUCHABLES.mkv' 'Most Wonderful Time of the Year, The (2008)'

# Mostly Ghostly Have You Met My Ghoulfriend! (2014)
move_to_deleted '/mnt/media/Movies/Mostly Ghostly Have You Met My Ghoulfriend! (2014)/mostly.ghostly.have.you.met.my.ghoulfriend.2014.1080p.bluray.x264-rusted.mkv' 'Mostly Ghostly Have You Met My Ghoulfriend! (2014)'

# Mr. Brooks (2007)
move_to_deleted '/mnt/media/Movies/Mr. Brooks (2007)/Mr. Brooks (2007) {imdb-tt0780571} [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv' 'Mr. Brooks (2007)'

# Mr. Harrigan\'s Phone (2022)
move_to_deleted '/mnt/media/Movies/Mr. Harrigan\'s Phone (2022)/Mr. Harrigans Phone (2022) {imdb-tt12908110} - [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Mr. Harrigan\'s Phone (2022)'

# Mr. Magoo (1997)
move_to_deleted '/mnt/media/Movies/Mr. Magoo (1997)/Mr. Magoo (1997) {imdb-tt0119718} [AMZN][WEBRip-1080p][EAC3 5.1][x264]-ABM.mkv' 'Mr. Magoo (1997)'

# Mulan II (2004)
move_to_deleted '/mnt/media/Movies/Mulan II (2004)/mulan.ii.2004.1080p.bluray.x264-hd4u.mkv' 'Mulan II (2004)'

# Mummies - Secrets of the Pharaohs (2007)
move_to_deleted '/mnt/media/Movies/Mummies - Secrets of the Pharaohs (2007)/IMAX.Mummies.Secrets.Of.The.Pharohs.2007.1080p.BluRay.x264-PUZZLE.mkv' 'Mummies - Secrets of the Pharaohs (2007)'

# Munsters, The (2022)
move_to_deleted '/mnt/media/Movies/Munsters, The (2022)/The Munsters (2022) {imdb-tt14813212} [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv' 'Munsters, The (2022)'

# Muppets Take Manhattan, The (1984)
move_to_deleted '/mnt/media/Movies/Muppets Take Manhattan, The (1984)/The.Muppets.Take.Manhattan.1984.1080p.BluRay.x264-SHORTBREHD.mkv' 'Muppets Take Manhattan, The (1984)'

# My Babysitter\'s a Vampire (2010)
move_to_deleted '/mnt/media/Movies/My Babysitter\'s a Vampire (2010)/My.Babysitter\'s.a.Vampire.The.Movie.2010.NF.WEB-DL.DD+.5.1.H.264-MateusFoxx.mkv' 'My Babysitter\'s a Vampire (2010)'

# My Brother the Devil (2012)
move_to_deleted '/mnt/media/Movies/My Brother the Devil (2012)/7s-mbtd-720p-rp.mkv' 'My Brother the Devil (2012)'

# My Neighbor Totoro (1988)
move_to_deleted '/mnt/media/Movies/My Neighbor Totoro (1988)/My Neighbor Totoro (1988) {imdb-tt0096283} [Bluray-1080p][AC3 2.0][x264]-CtrlHD.mkv' 'My Neighbor Totoro (1988)'

# National Lampoon\'s Vacation (1983)
move_to_deleted '/mnt/media/Movies/National Lampoon\'s Vacation (1983)/National Lampoons Vacation (1983) {imdb-tt0085995} [Bluray-1080p][HDR10][FLAC 1.0][x265]-ATELiER.mkv' 'National Lampoon\'s Vacation (1983)'

# Ne Zha (2019)
move_to_deleted '/mnt/media/Movies/Ne Zha (2019)/Ne Zha (2019) {imdb-tt10627720} [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv' 'Ne Zha (2019)'

# Neptune Frost (2022) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/Neptune Frost (2022)/Neptune Frost (2022) {imdb-tt11873472} [Bluray-1080p][EAC3 7.1][x264]-KG.mkv' 'Neptune Frost (2022)'

# Network (1976)
move_to_deleted '/mnt/media/Movies/Network (1976)/Network (1976) {imdb-tt0074958} [Bluray-1080p][FLAC 1.0][x264]-IDE.mkv' 'Network (1976)'

# Night of the Demons 2 (1994)
move_to_deleted '/mnt/media/Movies/Night of the Demons 2 (1994)/Night of the Demons 2 (1994) {imdb-tt0110667} [Bluray-1080p][FLAC 2.0][x264]-MaG.mkv' 'Night of the Demons 2 (1994)'

# Nightingale Falling, A (2014)
move_to_deleted '/mnt/media/Movies/Nightingale Falling, A (2014)/A.Nightingale.Falling.2014.1080p.BluRay.x264-RUSTED.mkv' 'Nightingale Falling, A (2014)'

# Nine Months (1995)
move_to_deleted '/mnt/media/Movies/Nine Months (1995)/Nine Months (1995) {imdb-tt0113986} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv' 'Nine Months (1995)'

# Ninja Assassin (2009)
move_to_deleted '/mnt/media/Movies/Ninja Assassin (2009)/Ninja Assassin (2009) {imdb-tt1186367} [Bluray-1080p][DTS 5.1][x264]-HighCode.mkv' 'Ninja Assassin (2009)'

# Ninotchka (1939)
move_to_deleted '/mnt/media/Movies/Ninotchka (1939)/Ninotchka.1939.1080p.BluRay.x264-HD4U.mkv' 'Ninotchka (1939)'

# Norm of the North (2016)
move_to_deleted '/mnt/media/Movies/Norm of the North (2016)/Norm.of.the.North.2016.1080p.BluRay.x264-GECKOS.mkv' 'Norm of the North (2016)'

# North (1994)
move_to_deleted '/mnt/media/Movies/North (1994)/North (1994) {imdb-tt0110687} [AMZN][WEBRip-1080p][EAC3 5.1][x264]-QOQ.mkv' 'North (1994)'

# Northpole Open for Christmas (2015)
move_to_deleted '/mnt/media/Movies/Northpole Open for Christmas (2015)/Northpole Open for Christmas (2015) {imdb-tt4843046} [Bluray-1080p][DTS 5.1][x264]-JustWatch.mkv' 'Northpole Open for Christmas (2015)'

# Nut Job 2 Nutty by Nature, The (2017)
move_to_deleted '/mnt/media/Movies/Nut Job 2 Nutty by Nature, The (2017)/The Nut Job 2 Nutty by Nature (2017) {imdb-tt3486626} [Bluray-1080p][DTS 5.1][x264]-VietHD.mkv' 'Nut Job 2 Nutty by Nature, The (2017)'

# Octopussy (1983)
move_to_deleted '/mnt/media/Movies/Octopussy (1983)/Octopussy (1983) {imdb-tt0086034} [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv' 'Octopussy (1983)'

# Of Fathers and Sons (2017)
move_to_deleted '/mnt/media/Movies/Of Fathers and Sons (2017)/Of.Fathers.and.Sons.2017.1080p.BluRay.x264-USURY.mkv' 'Of Fathers and Sons (2017)'

# Official Competition (2021)
move_to_deleted '/mnt/media/Movies/Official Competition (2021)/Official Competition (2021) {imdb-tt11700260} - [Bluray-1080p][DTS 5.1][x264]-NO.mkv' 'Official Competition (2021)'

# Oliver & Company (1988)
move_to_deleted '/mnt/media/Movies/Oliver & Company (1988)/Oliver and Company (1988) {imdb-tt0095776} [Bluray-1080p][EAC3 5.1][AV1]-TiZU.mkv' 'Oliver & Company (1988)'

# Open Season 3 (2010)
move_to_deleted '/mnt/media/Movies/Open Season 3 (2010)/Open Season 3 (2010) {imdb-tt1646926} [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv' 'Open Season 3 (2010)'

# Ordinary Angels (2024)
move_to_deleted '/mnt/media/Movies/Ordinary Angels (2024)/Ordinary Angels (2024) {imdb-tt4996328} [Bluray-1080p][EAC3 7.1][x264]-PTer.mkv' 'Ordinary Angels (2024)'

# The Outrun (2024)
move_to_deleted '/mnt/media/Movies/The Outrun (2024)/The Outrun (2024) {imdb-tt11687002} [Bluray-1080p][EAC3 7.1][x264]-SbR.mkv' 'The Outrun (2024)'

# Overboard (1987)
move_to_deleted '/mnt/media/Movies/Overboard (1987)/Overboard (1987) {imdb-tt0093693} [Bluray-1080p Proper][FLAC 2.0][x264]-VD.mkv' 'Overboard (1987)'

# Paranormal Activity Next of Kin (2021)
move_to_deleted '/mnt/media/Movies/Paranormal Activity Next of Kin (2021)/Paranormal.Activity.Next.Of.Kin.2021.RERiP.1080p.DD+5.1.x264-GS88.mkv' 'Paranormal Activity Next of Kin (2021)'

# Passion (2012)
move_to_deleted '/mnt/media/Movies/Passion (2012)/Passion.2012.1080p.BluRay.x264-PFa.mkv' 'Passion (2012)'

# Passion of the Christ, The (2004)
move_to_deleted '/mnt/media/Movies/Passion of the Christ, The (2004)/The Passion of the Christ 2004 1080p BluRay DTS x264-CtrlHD.mkv' 'Passion of the Christ, The (2004)'

# Past Lives (2023)
move_to_deleted '/mnt/media/Movies/Past Lives (2023)/Past Lives (2023) {imdb-tt13238346} [Bluray-1080p][EAC3 5.1][x264]-c0kE.mkv' 'Past Lives (2023)'

# Patriots Day (2016)
move_to_deleted '/mnt/media/Movies/Patriots Day (2016)/Patriots Day (2016) {imdb-tt4572514} [Bluray-1080p][DTS-X 7.1][x264]-FraMeSToR.mkv' 'Patriots Day (2016)'

# Paycheck (2003)
move_to_deleted '/mnt/media/Movies/Paycheck (2003)/Paycheck (2003) {imdb-tt0338337} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv' 'Paycheck (2003)'

# Peggy Sue Got Married (1986)
move_to_deleted '/mnt/media/Movies/Peggy Sue Got Married (1986)/Peggy Sue Got Married (1986) {imdb-tt0091738} [Bluray-1080p][FLAC 1.0][x264]-RO.mkv' 'Peggy Sue Got Married (1986)'

# Perfect Host, The (2010)
move_to_deleted '/mnt/media/Movies/Perfect Host, The (2010)/The Perfect Host (2010) {imdb-tt1334553} [Bluray-1080p][DTS 5.1][x264]-aAF.mkv' 'Perfect Host, The (2010)'

# Pest, The (1997)
move_to_deleted '/mnt/media/Movies/Pest, The (1997)/The Pest (1997) {imdb-tt0119887} [AMZN][WEBRip-1080p][EAC3 5.1][x264]-ABM.mkv' 'Pest, The (1997)'

# Pet Sematary II (1992)
move_to_deleted '/mnt/media/Movies/Pet Sematary II (1992)/Pet Sematary II (1992) {imdb-tt0105128} [Bluray-1080p][DTS-HD MA 5.1][x264]-OLDTiME.mkv' 'Pet Sematary II (1992)'

# Pete\'s Dragon (2016)
move_to_deleted '/mnt/media/Movies/Pete\'s Dragon (2016)/Petes Dragon (2016) {imdb-tt2788732} [Bluray-1080p][DTS 5.1][x264]-DON.mkv' 'Pete\'s Dragon (2016)'

# Piglet\'s Big Movie (2003)
move_to_deleted '/mnt/media/Movies/Piglet\'s Big Movie (2003)/Piglets Big Movie (2003) {imdb-tt0323642} [Bluray-1080p][AC3 5.1][x264]-HANDJOB.mkv' 'Piglet\'s Big Movie (2003)'

# Pilgrimage (2017)
move_to_deleted '/mnt/media/Movies/Pilgrimage (2017)/pilgrimage.2017.1080p.bluray.x264-rovers.mkv' 'Pilgrimage (2017)'

# Pink Floyd The Wall (1982)
move_to_deleted '/mnt/media/Movies/Pink Floyd The Wall (1982)/Pink.Floyd.The.Wall.1982.BluRay.1080p.DD.5.1.x264-BHDStudio.mp4' 'Pink Floyd The Wall (1982)'

# Pink Panther, The (2006)
move_to_deleted '/mnt/media/Movies/Pink Panther, The (2006)/The Pink Panther (2006) {imdb-tt0383216} [Bluray-1080p][AC3 5.1][x264]-DON.mkv' 'Pink Panther, The (2006)'

# Play Dead (2022)
move_to_deleted '/mnt/media/Movies/Play Dead (2022)/Play Dead (2022) {imdb-tt20198774} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Play Dead (2022)'

# Playground (2021)
move_to_deleted '/mnt/media/Movies/Playground (2021)/Playground (2021) {imdb-tt11087960} [Bluray-1080p][EAC3 5.1][x264]-SbR.mkv' 'Playground (2021)'

# Pocahontas (1995)
move_to_deleted '/mnt/media/Movies/Pocahontas (1995)/Pocahontas (1995) {imdb-tt0114148} [Bluray-1080p][EAC3 5.1][x264]-NCmt.mkv' 'Pocahontas (1995)'

# Pocahontas II Journey to a New World (1998)
move_to_deleted '/mnt/media/Movies/Pocahontas II Journey to a New World (1998)/Pocahontas II Journey to a New World (1998) {imdb-tt0143808} [Bluray-1080p][AC3 5.1][x264]-EbP.mkv' 'Pocahontas II Journey to a New World (1998)'

# Poms (2019)
move_to_deleted '/mnt/media/Movies/Poms (2019)/Poms (2019) {imdb-tt5125894} [Bluray-1080p][DTS 5.1][x264]-iFT.mkv' 'Poms (2019)'

# Powder Blue (2009)
move_to_deleted '/mnt/media/Movies/Powder Blue (2009)/Powder Blue 2009 1080p BluRay x264 CiNEFiLE.mkv' 'Powder Blue (2009)'

# Private Benjamin (1980)
move_to_deleted '/mnt/media/Movies/Private Benjamin (1980)/Private Benjamin (1980) {imdb-tt0081375} [AMZN][WEBRip-1080p][EAC3 2.0][x264]-SiGMA.mkv' 'Private Benjamin (1980)'

# Prizefighter The Life of Jem Belcher (2022)
move_to_deleted '/mnt/media/Movies/Prizefighter The Life of Jem Belcher (2022)/Prizefighter.The.Life.of.Jem.Belcher.2022.NORDiC.1080p.BluRay.x264.DTS-HD.MA.5.1-TWA.mkv' 'Prizefighter The Life of Jem Belcher (2022)'

# Prospect (2018)
move_to_deleted '/mnt/media/Movies/Prospect (2018)/Prospect (2018) {imdb-tt7946422} [Bluray-1080p][DTS 5.1][x264]-SillyBird.mkv' 'Prospect (2018)'

# Purple Rose of Cairo, The (1985)
move_to_deleted '/mnt/media/Movies/Purple Rose of Cairo, The (1985)/The Purple Rose of Cairo (1985) {imdb-tt0089853} - [AMZN][WEBDL-1080p][EAC3 2.0][h264]-GPRS.mkv' 'Purple Rose of Cairo, The (1985)'

# Puss in Boots The Three Diablos (2012)
move_to_deleted '/mnt/media/Movies/Puss in Boots The Three Diablos (2012)/Puss in Boots The Three Diablos (2012) {imdb-tt2268617} [Bluray-1080p][TrueHD 7.1][h264]-RMX.mkv' 'Puss in Boots The Three Diablos (2012)'

# Queen Days of Our Lives (2011)
move_to_deleted '/mnt/media/Movies/Queen Days of Our Lives (2011)/Queen Days of Our Lives (2011) {imdb-tt1977894} - [AMZN][WEBDL-1080p][EAC3 2.0][h264]-GPRS.mkv' 'Queen Days of Our Lives (2011)'

# Queen, The (2006)
move_to_deleted '/mnt/media/Movies/Queen, The (2006)/The Queen (2006) {imdb-tt0436697} [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv' 'Queen, The (2006)'

# Quest, The (1996)
move_to_deleted '/mnt/media/Movies/Quest, The (1996)/airline-the.quest_1080p.mkv' 'Quest, The (1996)'

# R.I.P.D. 2 Rise of the Damned (2022)
move_to_deleted '/mnt/media/Movies/R.I.P.D. 2 Rise of the Damned (2022)/R.I.P.D. 2 Rise of the Damned (2022) {imdb-tt21094994} [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv' 'R.I.P.D. 2 Rise of the Damned (2022)'

# RBG (2018)
move_to_deleted '/mnt/media/Movies/RBG (2018)/RBG.2018.1080p.BluRay.x264-CiNEFiLE.mkv' 'RBG (2018)'

# Radio Days (1987)
move_to_deleted '/mnt/media/Movies/Radio Days (1987)/Radio Days (1987) {imdb-tt0093818} [Bluray-1080p][DTS-HD MA 1.0][x264]-GeneMige.mkv' 'Radio Days (1987)'

# Rain Man (1988)
move_to_deleted '/mnt/media/Movies/Rain Man (1988)/Rain Man (1988) {imdb-tt0095953} - [Bluray-1080p][FLAC 2.0][x264]-c0kE.mkv' 'Rain Man (1988)'

# Ransom (1996)
move_to_deleted '/mnt/media/Movies/Ransom (1996)/Ransom (1996) {imdb-tt0117438} [Bluray-1080p][DTS 5.1][x264]-iFT.mkv' 'Ransom (1996)'

# Ray Donovan The Movie (2022)
move_to_deleted '/mnt/media/Movies/Ray Donovan The Movie (2022)/Ray Donovan The Movie (2022) {imdb-tt14124268} - [Bluray-1080p Proper][EAC3 5.1][x264]-iFT.mkv' 'Ray Donovan The Movie (2022)'

# Reagan (2024)
move_to_deleted '/mnt/media/Movies/Reagan (2024)/Reagan (2024) {imdb-tt1723808} [Bluray-1080p][EAC3 5.1][x264]-HiDt.mkv' 'Reagan (2024)'

# Rebel Moon Part Two The Scargiver (2024)
move_to_deleted '/mnt/media/Movies/Rebel Moon Part Two The Scargiver (2024)/Rebel Moon Part Two The Scargiver (2024) {imdb-tt23137904} - {edition-Directors Cut} [NF][WEBDL-1080p Proper][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Rebel Moon Part Two The Scargiver (2024)'

# Red Cliff Part II (2009)
move_to_deleted '/mnt/media/Movies/Red Cliff Part II (2009)/Red Cliff II (2009) {imdb-tt1326972} {edition-Open Matte} [Bluray-1080p][DTS 5.1][x264]-EbP.mkv' 'Red Cliff Part II (2009)'

# Remember the Night (1940) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/Remember the Night (1940)/Remember the Night (1940) {imdb-tt0032981} - [Bluray-1080p][DTS 2.0][x264]-SiNNERS.mkv' 'Remember the Night (1940)'

# Remember the Titans (2000)
move_to_deleted '/mnt/media/Movies/Remember the Titans (2000)/Remember.The.Titans.2000.1080p.BluRay.DD5.1.x264-CtrlHD.mkv' 'Remember the Titans (2000)'

# Requin, The (2022)
move_to_deleted '/mnt/media/Movies/Requin, The (2022)/The Requin (2022) {imdb-tt11348232} - [Bluray-1080p][EAC3 5.1][x264]-GS88.mkv' 'Requin, The (2022)'

# Resident Evil - Degeneration (2008)
move_to_deleted '/mnt/media/Movies/Resident Evil - Degeneration (2008)/Resident Evil Degeneration (2008) {imdb-tt1174954} [Bluray-1080p][DTS 5.1][x264]-HDC.mkv' 'Resident Evil - Degeneration (2008)'

# Resident Evil Vendetta (2017)
move_to_deleted '/mnt/media/Movies/Resident Evil Vendetta (2017)/Resident Evil Vendetta 2017 1080p BluRay DDP 7.1 DV x265-LEGi0N.mkv' 'Resident Evil Vendetta (2017)'

# The Retirement Plan (2023)
move_to_deleted '/mnt/media/Movies/The Retirement Plan (2023)/The Retirement Plan (2023) {imdb-tt14827638} [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv' 'The Retirement Plan (2023)'

# The Return (2024)
move_to_deleted '/mnt/media/Movies/The Return (2024)/The Return (2024) {imdb-tt19861162} [Bluray-1080p][FLAC 2.0][x264]-PTer.mkv' 'The Return (2024)'

# Revenge of the Nerds (1984)
move_to_deleted '/mnt/media/Movies/Revenge of the Nerds (1984)/Revenge of the Nerds (1984) {imdb-tt0088000} [Bluray-1080p][FLAC 1.0][x264]-Geek.mkv' 'Revenge of the Nerds (1984)'

# Ri¢hie Ri¢h (1994)
move_to_deleted '/mnt/media/Movies/Ri¢hie Ri¢h (1994)/Ri¢hie Ri¢h (1994) {imdb-tt0110989} [WEBRip-1080p][EAC3 2.0][x264]-NTb.mkv' 'Ri¢hie Ri¢h (1994)'

# Robin and the 7 Hoods (1964)
move_to_deleted '/mnt/media/Movies/Robin and the 7 Hoods (1964)/Robin.and.the.7.Hoods.1964.1080p.BluRay.x264-SADPANDA.mkv' 'Robin and the 7 Hoods (1964)'

# Romancing the Stone (1984)
move_to_deleted '/mnt/media/Movies/Romancing the Stone (1984)/Romancing.the.Stone.1984.1080p.BluRay.DTS.x264-FoRM.mkv' 'Romancing the Stone (1984)'

# Ron\'s Gone Wrong (2021)
move_to_deleted '/mnt/media/Movies/Ron\'s Gone Wrong (2021)/Rons.Gone.Wrong.2021.1080p.BluRay.DD+7.1.x264-iFT.mkv' 'Ron\'s Gone Wrong (2021)'

# Run, Fatboy, Run (2007)
move_to_deleted '/mnt/media/Movies/Run, Fatboy, Run (2007)/Run Fatboy Run (2007) {imdb-tt0425413} [Bluray-1080p][DTS-ES 5.1][x264]-RVL.mkv' 'Run, Fatboy, Run (2007)'

# Runner Runner (2013)
move_to_deleted '/mnt/media/Movies/Runner Runner (2013)/Runner.Runner.2013.1080p.BluRay.DTS.x264-SbR.mkv' 'Runner Runner (2013)'

# SAS Red Notice (2021)
move_to_deleted '/mnt/media/Movies/SAS Red Notice (2021)/SAS Red Notice (2021) {imdb-tt4479380} [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv' 'SAS Red Notice (2021)'

# Scarehouse, The (2014)
move_to_deleted '/mnt/media/Movies/Scarehouse, The (2014)/The.Scarehouse.2014.1080p.BluRay.x264-VALUE.mkv' 'Scarehouse, The (2014)'

# Scary Movie (2000)
move_to_deleted '/mnt/media/Movies/Scary Movie (2000)/Scary.Movie.2000.1080p.BluRay.DD5.1.x264-CtrlHD.mkv' 'Scary Movie (2000)'

# Scary Movie 2 (2001)
move_to_deleted '/mnt/media/Movies/Scary Movie 2 (2001)/Scary Movie 2 (2001) {imdb-tt0257106} - [Hybrid][Bluray-1080p][EAC3 5.1][x264]-ZoroSenpai.mkv' 'Scary Movie 2 (2001)'

# Scary Movie 3 (2003)
move_to_deleted '/mnt/media/Movies/Scary Movie 3 (2003)/Scary Movie 3 (2003) {imdb-tt0306047} - {edition-Unrated} [Bluray-1080p][EAC3 5.1][x264]-coffee.mkv' 'Scary Movie 3 (2003)'

# Scary Movie 4 (2006)
move_to_deleted '/mnt/media/Movies/Scary Movie 4 (2006)/Scary Movie 4 (2006) {imdb-tt0362120} - [Bluray-1080p Proper][AC3 5.1][x264]-BHDStudio.mp4' 'Scary Movie 4 (2006)'

# Scary Movie 5 (2013)
move_to_deleted '/mnt/media/Movies/Scary Movie 5 (2013)/Scary Movie 5 (2013) {imdb-tt0795461} - [Bluray-1080p][AC3 5.1][x264]-playHD.mkv' 'Scary Movie 5 (2013)'

# School for Good and Evil, The (2022)
move_to_deleted '/mnt/media/Movies/School for Good and Evil, The (2022)/The School for Good and Evil (2022) {imdb-tt2935622} - [NF][WEBDL-1080p Proper][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'School for Good and Evil, The (2022)'

# Secret Life of Pets 2, The (2019)
move_to_deleted '/mnt/media/Movies/Secret Life of Pets 2, The (2019)/The Secret Life of Pets 2 (2019) {imdb-tt5113040} [Bluray-1080p][AC3 5.1][x264]-iFT.mkv' 'Secret Life of Pets 2, The (2019)'

# Secret Life of Pets, The (2016)
move_to_deleted '/mnt/media/Movies/Secret Life of Pets, The (2016)/The Secret Life of Pets (2016) {imdb-tt2709768} - [Bluray-1080p Proper][AC3 5.1][x264]-VietHD.mkv' 'Secret Life of Pets, The (2016)'

# Secret Window (2004)
move_to_deleted '/mnt/media/Movies/Secret Window (2004)/Secret Window (2004) {imdb-tt0363988} [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv' 'Secret Window (2004)'

# Senior Year (2022)
move_to_deleted '/mnt/media/Movies/Senior Year (2022)/Senior Year (2022) {imdb-tt5315212} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv' 'Senior Year (2022)'

# Separation, A (2011)
move_to_deleted '/mnt/media/Movies/Separation, A (2011)/A.Separation.2011.1080p.BluRay.DTS.x264-Dariush.mkv' 'Separation, A (2011)'

# September 5 (2024)
move_to_deleted '/mnt/media/Movies/September 5 (2024)/September 5 (2024) {imdb-tt28082769} [Hybrid][Bluray-1080p][EAC3 Atmos 7.1][x264]-c0kE.mkv' 'September 5 (2024)'

# Sgt. Stubby An American Hero (2018)
move_to_deleted '/mnt/media/Movies/Sgt. Stubby An American Hero (2018)/Sgt. Stubby An American Hero (2018) {imdb-tt5314190} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-GPRS.mkv' 'Sgt. Stubby An American Hero (2018)'

# Shadow (2018)
move_to_deleted '/mnt/media/Movies/Shadow (2018)/Shadow (2018) {imdb-tt6864046} [Bluray-1080p][DTS-HD MA 5.1][x264]-PTer.mkv' 'Shadow (2018)'

# Shanghai Knights (2003)
move_to_deleted '/mnt/media/Movies/Shanghai Knights (2003)/Shanghai Knights (2003) {imdb-tt0300471} [Bluray-1080p][DTS 5.1][x264]-BestHD.mkv' 'Shanghai Knights (2003)'

# Shark Bait (2022)
move_to_deleted '/mnt/media/Movies/Shark Bait (2022)/Shark Bait (2022) {imdb-tt12550376} [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv' 'Shark Bait (2022)'

# Shell (2012)
move_to_deleted '/mnt/media/Movies/Shell (2012)/Shell (2012) {imdb-tt2088893} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv' 'Shell (2012)'

# Shogun Assassin (1980)
move_to_deleted '/mnt/media/Movies/Shogun Assassin (1980)/Shogun Assassin (1980) {imdb-tt0081506} [Bluray-1080p][AC3 1.0][x264]-EA.mkv' 'Shogun Assassin (1980)'

# Shoot \'Em Up (2007)
move_to_deleted '/mnt/media/Movies/Shoot \'Em Up (2007)/Shoot \'Em Up (2007) {imdb-tt0465602} - [Bluray-1080p][EAC3 7.1][x264]-PIS.mkv' 'Shoot \'Em Up (2007)'

# Showtime (2002)
move_to_deleted '/mnt/media/Movies/Showtime (2002)/Showtime (2002) {imdb-tt0284490} [AMZN][WEBRip-1080p][EAC3 2.0][x264]-SDCC.mkv' 'Showtime (2002)'

# Sideways (2004)
move_to_deleted '/mnt/media/Movies/Sideways (2004)/Sideways.2004.1080p.BluRay.DTS.x264-CtrlHD.mkv' 'Sideways (2004)'

# Simpsons Movie, The (2007)
move_to_deleted '/mnt/media/Movies/Simpsons Movie, The (2007)/The.Simpsons.Movie.2007.BluRay.DTS.x264.D-Z0N3.mkv' 'Simpsons Movie, The (2007)'

# Sincerely Louis C.K. (2020)
move_to_deleted '/mnt/media/Movies/Sincerely Louis C.K. (2020)/Sincerely.Louis.CK.2020.720p.WEB.AAC.2.0.h264-SaL.mkv' 'Sincerely Louis C.K. (2020)'

# Sleeping with the Enemy (1991)
move_to_deleted '/mnt/media/Movies/Sleeping with the Enemy (1991)/Sleeping with the Enemy (1991) {imdb-tt0102945} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Sleeping with the Enemy (1991)'

# Sleuth (2007)
move_to_deleted '/mnt/media/Movies/Sleuth (2007)/Sleuth (2007) {imdb-tt0857265} [Bluray-1080p][DTS 5.1][x264]-EuReKA.mkv' 'Sleuth (2007)'

# Small Things Like These (2024) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/Small Things Like These (2024)/Small Things Like These (2024) {imdb-tt27196021} [Bluray-1080p][DTS-HD MA 5.1][x264]-Replica.mkv' 'Small Things Like These (2024)'

# Smokey and the Bandit II (1980)
move_to_deleted '/mnt/media/Movies/Smokey and the Bandit II (1980)/Smokey and the Bandit II (1980) {imdb-tt0081529} [Bluray-1080p][AC3 2.0][x264]-BHDStudio.mp4' 'Smokey and the Bandit II (1980)'

# Snowman, The (1982)
move_to_deleted '/mnt/media/Movies/Snowman, The (1982)/The Snowman (1982) {imdb-tt0084701} [WEBDL-1080p][AAC 2.0][h264]-SATS.mkv' 'Snowman, The (1982)'

# Son of Batman (2014)
move_to_deleted '/mnt/media/Movies/Son of Batman (2014)/Son.of.Batman.2014.1080p.BluRay.x264-ROVERS.mkv' 'Son of Batman (2014)'

# Sorry to Bother You (2018)
move_to_deleted '/mnt/media/Movies/Sorry to Bother You (2018)/Sorry to Bother You (2018) {imdb-tt5688932} [Bluray-1080p][DTS 5.1][x264]-NCmt.mkv' 'Sorry to Bother You (2018)'

# Souvenir, The (2019) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/Souvenir, The (2019)/The Souvenir (2019) {imdb-tt6920356} [Bluray-1080p][EAC3 5.1][x264]-EA.mkv' 'Souvenir, The (2019)'

# Space Jam (1996)
move_to_deleted '/mnt/media/Movies/Space Jam (1996)/Space.Jam.1996.1080p.BluRay.DTS.x264-TayTO.mkv' 'Space Jam (1996)'

# Spiderhead (2022)
move_to_deleted '/mnt/media/Movies/Spiderhead (2022)/Spiderhead (2022) {imdb-tt9783600} [NF][WEBRip-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv' 'Spiderhead (2022)'

# Spies Like Us (1985)
move_to_deleted '/mnt/media/Movies/Spies Like Us (1985)/Spies Like Us (1985) {imdb-tt0090056} [Bluray-1080p][DTS 2.0][x264]-HDC.mkv' 'Spies Like Us (1985)'

# Spoiler Alert (2022)
move_to_deleted '/mnt/media/Movies/Spoiler Alert (2022)/Spoiler Alert (2022) {imdb-tt7775720} [Bluray-1080p][EAC3 Atmos 5.1][x264]-Kitsune.mkv' 'Spoiler Alert (2022)'

# The SpongeBob SquarePants Movie (2004)
move_to_deleted '/mnt/media/Movies/The SpongeBob SquarePants Movie (2004)/The SpongeBob SquarePants Movie (2004) {imdb-tt0345950} [Bluray-1080p][DTS 5.1][x264]-DON.mkv' 'The SpongeBob SquarePants Movie (2004)'

# Stan Helsing (2009)
move_to_deleted '/mnt/media/Movies/Stan Helsing (2009)/Stan.Helsing.2009.STV.1080p.BluRay.x264-PROFiLE.mkv' 'Stan Helsing (2009)'

# Strawberry Mansion (2021)
move_to_deleted '/mnt/media/Movies/Strawberry Mansion (2021)/Strawberry Mansion (2021) Bluray-1080p.mkv' 'Strawberry Mansion (2021)'

# Strictly Ballroom (1992)
move_to_deleted '/mnt/media/Movies/Strictly Ballroom (1992)/Strictly.Ballroom.1992.PROPER.1080p.BluRay.x264-USURY.mkv' 'Strictly Ballroom (1992)'

# Studio 54 (2018)
move_to_deleted '/mnt/media/Movies/Studio 54 (2018)/Studio 54 (2018) {imdb-tt5773986} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BLOOM.mkv' 'Studio 54 (2018)'

# Superman II The Richard Donner Cut (2006)
move_to_deleted '/mnt/media/Movies/Superman II The Richard Donner Cut (2006)/Superman II The Richard Donner Cut (2006) {imdb-tt0839995} - [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv' 'Superman II The Richard Donner Cut (2006)'

# Superman Red Son (2020)
move_to_deleted '/mnt/media/Movies/Superman Red Son (2020)/Superman Red Son (2020) {imdb-tt10985510} [Bluray-1080p][DTS 5.1][x264]-PbK.mkv' 'Superman Red Son (2020)'

# Superman Unbound (2013)
move_to_deleted '/mnt/media/Movies/Superman Unbound (2013)/Superman.Unbound.2013.1080p.BluRay.DTS.x264-PublicHD.mkv' 'Superman Unbound (2013)'

# Superman+Shazam! The Return of Black Adam (2010)
move_to_deleted '/mnt/media/Movies/Superman+Shazam! The Return of Black Adam (2010)/Superman Shazam! The Return of Black Adam (2010) {imdb-tt1701223} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Superman+Shazam! The Return of Black Adam (2010)'

# Sword in the Stone, The (1963)
move_to_deleted '/mnt/media/Movies/Sword in the Stone, The (1963)/The Sword in the Stone (1963) {imdb-tt0057546} [Bluray-1080p][EAC3 5.1][AV1]-TiZU.mkv' 'Sword in the Stone, The (1963)'

# Sydney White (2007)
move_to_deleted '/mnt/media/Movies/Sydney White (2007)/Sydney White (2007) {imdb-tt0815244} [Bluray-1080p][EAC3 5.1][x264]-Telesto.mkv' 'Sydney White (2007)'

# Takeover, The (2022)
move_to_deleted '/mnt/media/Movies/Takeover, The (2022)/The Takeover (2022) {imdb-tt18082758} - [NF][WEBDL-1080p Proper][EAC3 5.1][x264]-FLUX.mkv' 'Takeover, The (2022)'

# Tales from the Crypt Demon Knight (1995)
move_to_deleted '/mnt/media/Movies/Tales from the Crypt Demon Knight (1995)/Tales.From.The.Crypt.Demon.Knight.1995.1080p.BluRay.DTS.x264.D-Z0N3.mkv' 'Tales from the Crypt Demon Knight (1995)'

# Animatrix, The (2003)
move_to_deleted '/mnt/media/Movies/Animatrix, The (2003)/The.Animatrix.2003.1080p.BluRay.x264-DON.mkv' 'Animatrix, The (2003)'

# The Apprentice (2024) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/The Apprentice (2024)/The Apprentice (2024) {imdb-tt8368368} - [Bluray-1080p Proper][EAC3 5.1][x264]-ZoroSenpai.mkv' 'The Apprentice (2024)'

# Bad Guys, The (2022)
move_to_deleted '/mnt/media/Movies/Bad Guys, The (2022)/The Bad Guys (2022) {imdb-tt8115900} - [Bluray-1080p][EAC3 Atmos 7.1][x264]-iFT.mkv' 'Bad Guys, The (2022)'

# The Blind (2023)
move_to_deleted '/mnt/media/Movies/The Blind (2023)/The Blind (2023) {imdb-tt16374352} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'The Blind (2023)'

# The Bodyguard (1992)
move_to_deleted '/mnt/media/Movies/The Bodyguard (1992)/The Bodyguard (1992) {imdb-tt0103855} [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv' 'The Bodyguard (1992)'

# Book of Eli, The (2010)
move_to_deleted '/mnt/media/Movies/Book of Eli, The (2010)/The.Book.Of.Eli.2010.Bluray.1080p.DTS-HDMA-x264.dxva-FraMeSToR.mkv' 'Book of Eli, The (2010)'

# Brothers Grimm, The (2005)
move_to_deleted '/mnt/media/Movies/Brothers Grimm, The (2005)/The Brothers Grimm (2005) {imdb-tt0355295} [Bluray-1080p][DTS 5.1][x264]-CyTSuNee.mkv' 'Brothers Grimm, The (2005)'

# Bucket List, The (2007)
move_to_deleted '/mnt/media/Movies/Bucket List, The (2007)/The.Bucket.List.2007.1080p.BluRay.DD.5.1x264-SbR.mkv' 'Bucket List, The (2007)'

# The Dilemma (2011)
move_to_deleted '/mnt/media/Movies/The Dilemma (2011)/The Dilemma (2011) {imdb-tt1578275} [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv' 'The Dilemma (2011)'

# The Fountain (2006)
move_to_deleted '/mnt/media/Movies/The Fountain (2006)/The Fountain (2006) {imdb-tt0414993} [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv' 'The Fountain (2006)'

# The Gift (2015)
move_to_deleted '/mnt/media/Movies/The Gift (2015)/The Gift (2015) {imdb-tt4178092} [Bluray-1080p][AC3 5.1][x264]-EbP.mkv' 'The Gift (2015)'

# Golden Child, The (1986)
move_to_deleted '/mnt/media/Movies/Golden Child, The (1986)/The.Golden.Child.1986.1080p.BluRay.DD+5.1.x264-iFT.mkv' 'Golden Child, The (1986)'

# The Golden Compass (2007)
move_to_deleted '/mnt/media/Movies/The Golden Compass (2007)/The Golden Compass (2007) {imdb-tt0385752} [Bluray-1080p][DTS-HD MA 7.1][VC1]-REFRACTiON.mkv' 'The Golden Compass (2007)'

# The Good, the Bad and the Ugly (1966)
move_to_deleted '/mnt/media/Movies/The Good, the Bad and the Ugly (1966)/The Good the Bad and the Ugly (1966) {imdb-tt0060196} - [Bluray-1080p][FLAC 1.0][x264]-ZoroSenpai.mkv' 'The Good, the Bad and the Ugly (1966)'

# The Great Escaper (2023)
move_to_deleted '/mnt/media/Movies/The Great Escaper (2023)/The Great Escaper (2023) {imdb-tt14124080} [Bluray-1080p][EAC3 5.1][x264]-SPHD.mkv' 'The Great Escaper (2023)'

# The Guard (2011)
move_to_deleted '/mnt/media/Movies/The Guard (2011)/The.Guard.2011.PROPER.1080p.BluRay.x264-SADPANDA.mkv' 'The Guard (2011)'

# The Holdovers (2023) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/The Holdovers (2023)/The Holdovers (2023) {imdb-tt14849194} [Bluray-1080p Proper][EAC3 3.0][x264]-HiDt.mkv' 'The Holdovers (2023)'

# Last Samurai, The (2003)
move_to_deleted '/mnt/media/Movies/Last Samurai, The (2003)/The Last Samurai (2003) {imdb-tt0325710} [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv' 'Last Samurai, The (2003)'

# The Machine (2023)
move_to_deleted '/mnt/media/Movies/The Machine (2023)/The Machine (2023) {imdb-tt11040844} [Bluray-1080p][DTS-HD MA 5.1][x264]-MiMESiS.mkv' 'The Machine (2023)'

# The Manchurian Candidate (2004)
move_to_deleted '/mnt/media/Movies/The Manchurian Candidate (2004)/The Manchurian Candidate (2004) {imdb-tt0368008} [Bluray-1080p][EAC3 5.1][x264]-c0kE.mkv' 'The Manchurian Candidate (2004)'

# Name of the Rose, The (1986)
move_to_deleted '/mnt/media/Movies/Name of the Rose, The (1986)/The Name of the Rose (1986) {imdb-tt0091605} [Bluray-1080p][EAC3 5.1][x264]-PTer.mkv' 'Name of the Rose, The (1986)'

# The Nutcracker (2009)
move_to_deleted '/mnt/media/Movies/The Nutcracker (2009)/The Nutcracker.bluray.mkv' 'The Nutcracker (2009)'

# The Phoenician Scheme (2025) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/The Phoenician Scheme (2025)/The Phoenician Scheme (2025) {imdb-tt30840798} - [Bluray-1080p][EAC3 Atmos 5.1][DV HDR10][x265]-HiDt.mkv' 'The Phoenician Scheme (2025)'

# Predator, The (2018)
move_to_deleted '/mnt/media/Movies/Predator, The (2018)/The.Predator.2018.1080p.BluRay.DTS-HD.MA7.1.X264-iFT.mkv' 'Predator, The (2018)'

# The Pursuit of Happyness (2006)
move_to_deleted '/mnt/media/Movies/The Pursuit of Happyness (2006)/The.Pursuit.of.Happyness.2006.1080p.BluRay.DTS.x264-VietHD.mkv' 'The Pursuit of Happyness (2006)'

# The Running Man (1987)
move_to_deleted '/mnt/media/Movies/The Running Man (1987)/The Running Man (1987) {imdb-tt0093894} - [Bluray-1080p][EAC3 5.1][x264]-ZoroSenpai.mkv' 'The Running Man (1987)'

# The Social Network (2010)
move_to_deleted '/mnt/media/Movies/The Social Network (2010)/The Social Network (2010) {imdb-tt1285016} - [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv' 'The Social Network (2010)'

# The Square (2013)
move_to_deleted '/mnt/media/Movies/The Square (2013)/The.Square.2013.1080p.WEBRip.x264.DD5.1-Absinth.mkv' 'The Square (2013)'

# The Taste of Things (2023)
move_to_deleted '/mnt/media/Movies/The Taste of Things (2023)/The Taste of Things (2023) {imdb-tt19760052} [Bluray-1080p][EAC3 5.1][x264]-c0kE.mkv' 'The Taste of Things (2023)'

# The Three Musketeers (1993)
move_to_deleted '/mnt/media/Movies/The Three Musketeers (1993)/The Three Musketeers (1993) {imdb-tt0108333} [Bluray-1080p][EAC3 5.1][x264]-MainFrame.mkv' 'The Three Musketeers (1993)'

# Transporter Refueled, The (2015)
move_to_deleted '/mnt/media/Movies/Transporter Refueled, The (2015)/The.Transporter.Refueled.2015.1080p.BluRay.DTS.x264-VietHD.mkv' 'Transporter Refueled, The (2015)'

# The War of the Roses (1989)
move_to_deleted '/mnt/media/Movies/The War of the Roses (1989)/The War of the Roses (1989) {imdb-tt0098621} [Bluray-1080p][DTS-HD MA 5.1][x264]-HDH.mkv' 'The War of the Roses (1989)'

# Their Finest (2017)
move_to_deleted '/mnt/media/Movies/Their Finest (2017)/Their Finest (2017) {imdb-tt1661275} [Bluray-1080p][AC3 5.1][x264]-VietHD.mkv' 'Their Finest (2017)'

# There\'s Something About Mary (1998)
move_to_deleted '/mnt/media/Movies/There\'s Something About Mary (1998)/Theres Something About Mary (1998) {imdb-tt0129387} [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv' 'There\'s Something About Mary (1998)'

# Thing, The (1982)
move_to_deleted '/mnt/media/Movies/Thing, The (1982)/The Thing (1982) {imdb-tt0084787} [Bluray-1080p][PQ][AC3 4.1][x265]-DON.mkv' 'Thing, The (1982)'

# This Is 40 (2012)
move_to_deleted '/mnt/media/Movies/This Is 40 (2012)/This Is 40 (2012) {imdb-tt1758830} [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv' 'This Is 40 (2012)'

# Till Death (2021)
move_to_deleted '/mnt/media/Movies/Till Death (2021)/Till.Death.2021.1080p.BluRay.DD+5.1.x264-iFT.mkv' 'Till Death (2021)'

# Tim (1979)
move_to_deleted '/mnt/media/Movies/Tim (1979)/Tim.1979.1080p.BluRay.x264-RUSTED.mkv' 'Tim (1979)'

# Time Machine, The (2002)
move_to_deleted '/mnt/media/Movies/Time Machine, The (2002)/The Time Machine (2002) {imdb-tt0268695} [Bluray-1080p][EAC3 5.1][x264]-TayTO.mkv' 'Time Machine, The (2002)'

# Tooth Fairy (2010)
move_to_deleted '/mnt/media/Movies/Tooth Fairy (2010)/Tooth Fairy (2010) {imdb-tt0808510} - [Bluray-1080p][AC3 5.1][x264]-CRiSC.mkv' 'Tooth Fairy (2010)'

# Trainwreck (2015)
move_to_deleted '/mnt/media/Movies/Trainwreck (2015)/Trainwreck (2015) {imdb-tt3152624} [Bluray-1080p][AC3 5.1][x264]-VietHD.mkv' 'Trainwreck (2015)'

# Trick or Treat (1986)
move_to_deleted '/mnt/media/Movies/Trick or Treat (1986)/Trick or Treat (1986) {imdb-tt0092112} [Bluray-1080p][FLAC 2.0][x264]-MaG.mkv' 'Trick or Treat (1986)'

# Trolls Band Together (2023)
move_to_deleted '/mnt/media/Movies/Trolls Band Together (2023)/Trolls Band Together (2023) {imdb-tt14362112} [Bluray-1080p][TrueHD Atmos 7.1][x264]-KNiVES.mkv' 'Trolls Band Together (2023)'

# Tropic Thunder (2008)
move_to_deleted '/mnt/media/Movies/Tropic Thunder (2008)/Tropic Thunder (2008) {imdb-tt0942385} {edition-Theatrical Cut} [Bluray-1080p][DV HDR10][EAC3 5.1][x265]-SA89.mkv' 'Tropic Thunder (2008)'

# True Things (2022)
move_to_deleted '/mnt/media/Movies/True Things (2022)/True.Things.2021.1080p.BluRay.x264-SCARE.mkv' 'True Things (2022)'

# Tucker and Dale vs Evil (2010)
move_to_deleted '/mnt/media/Movies/Tucker and Dale vs Evil (2010)/Tucker and Dale vs. Evil (2010) {imdb-tt1465522} [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv' 'Tucker and Dale vs Evil (2010)'

# Twilight (2008)
move_to_deleted '/mnt/media/Movies/Twilight (2008)/Twilight (2008) {imdb-tt1099212} [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv' 'Twilight (2008)'

# U2 Rattle and Hum (1988)
move_to_deleted '/mnt/media/Movies/U2 Rattle and Hum (1988)/U2 Rattle and Hum (1988) {imdb-tt0096328} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'U2 Rattle and Hum (1988)'

# Untraceable (2008)
move_to_deleted '/mnt/media/Movies/Untraceable (2008)/Untraceable.bluray.mkv' 'Untraceable (2008)'

# Valentine\'s Day (2010)
move_to_deleted '/mnt/media/Movies/Valentine\'s Day (2010)/Valentines Day (2010) {imdb-tt0817230} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Valentine\'s Day (2010)'

# Valiant (2005)
move_to_deleted '/mnt/media/Movies/Valiant (2005)/Valiant.2005.1080p.BluRay.x264-LEVERAGE.mkv' 'Valiant (2005)'

# Vampire Hunter D (1985) (720p → 1080p)
move_to_deleted '/mnt/media/Movies/Vampire Hunter D (1985)/Vampire Hunter D (1985) {imdb-tt0090248} [Bluray-1080p][FLAC 2.0][x264]-D-Z0N3.mkv' 'Vampire Hunter D (1985)'

# Vanquish (2021)
move_to_deleted '/mnt/media/Movies/Vanquish (2021)/Vanquish (2021) {imdb-tt5932368} [Bluray-1080p][EAC3 5.1][x264]-PTer.mkv' 'Vanquish (2021)'

# Vegas Vacation (1997)
move_to_deleted '/mnt/media/Movies/Vegas Vacation (1997)/Vegas Vacation (1997) {imdb-tt0120434} - [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv' 'Vegas Vacation (1997)'

# Vision Quest (1985)
move_to_deleted '/mnt/media/Movies/Vision Quest (1985)/Vision Quest (1985) {imdb-tt0090270} [AMZN][WEBDL-1080p][EAC3 2.0][h264]-AESop.mkv' 'Vision Quest (1985)'

# Volumes of Blood (2015)
move_to_deleted '/mnt/media/Movies/Volumes of Blood (2015)/Volumes of Blood (2015) {imdb-tt3857092} [Bluray-1080p][AC3 2.0][x264]-HANDJOB.mkv' 'Volumes of Blood (2015)'

# W.E. (2011)
move_to_deleted '/mnt/media/Movies/W.E. (2011)/W.E. (2011) {imdb-tt1536048} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-GPRS.mkv' 'W.E. (2011)'

# Wanderlust (2012)
move_to_deleted '/mnt/media/Movies/Wanderlust (2012)/Wanderlust (2012) {imdb-tt1655460} - [Bluray-1080p][EAC3 5.1][x264]-coffee.mkv' 'Wanderlust (2012)'

# War Horse (2011)
move_to_deleted '/mnt/media/Movies/War Horse (2011)/War Horse (2011) {imdb-tt1568911} [Bluray-1080p][AC3 5.1][x264]-EbP.mkv' 'War Horse (2011)'

# War at Home, The (1996)
move_to_deleted '/mnt/media/Movies/War at Home, The (1996)/The War at Home (1996) {imdb-tt0118117} [Bluray-1080p][AC3 2.0][x264]-BHDStudio.mp4' 'War at Home, The (1996)'

# Warfare (2025)
move_to_deleted '/mnt/media/Movies/Warfare (2025)/Warfare (2025) {imdb-tt31434639} - [Hybrid][Bluray-1080p][EAC3 Atmos 5.1][x264]-BiTOR.mkv' 'Warfare (2025)'

# Watchmen (2009)
move_to_deleted '/mnt/media/Movies/Watchmen (2009)/Watchmen (2009) {imdb-tt0409459} - {edition-Ultimate Cut} [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv' 'Watchmen (2009)'

# Watership Down (1978)
move_to_deleted '/mnt/media/Movies/Watership Down (1978)/Watership Down (1978) {imdb-tt0078480} - [Bluray-1080p][FLAC 2.0][x264]-DON.mkv' 'Watership Down (1978)'

# Wayne\'s World (1992)
move_to_deleted '/mnt/media/Movies/Wayne\'s World (1992)/Wayne\'s World 1992 1080p BluRay DDP 7.1 DV x265-LEGi0N.mkv' 'Wayne\'s World (1992)'

# West Side Story (2021)
move_to_deleted '/mnt/media/Movies/West Side Story (2021)/West.Side.Story.2021.REPACK.1080p.BluRay.DDP7.1.x264-NTb.mkv' 'West Side Story (2021)'

# What\'s Love Got to Do with It (1993)
move_to_deleted '/mnt/media/Movies/What\'s Love Got to Do with It (1993)/Whats.Love.Got.to.Do.with.It.1993.1080p.BluRay.x264-PSYCHD.mkv' 'What\'s Love Got to Do with It (1993)'

# When the Game Stands Tall (2014)
move_to_deleted '/mnt/media/Movies/When the Game Stands Tall (2014)/When the Game Stands Tall (2014) {imdb-tt2247476} [Bluray-1080p][AC3 5.1][x264]-VietHD.mkv' 'When the Game Stands Tall (2014)'

# Where the Crawdads Sing (2022)
move_to_deleted '/mnt/media/Movies/Where the Crawdads Sing (2022)/Where.the.Crawdads.Sing.2022.1080p.BluRay.DDP5.1.x264-iFT.mkv' 'Where the Crawdads Sing (2022)'

# While You Were Sleeping (1995)
move_to_deleted '/mnt/media/Movies/While You Were Sleeping (1995)/While You Were Sleeping (1995) {imdb-tt0114924} - [Bluray-1080p][EAC3 5.1][x264]-DON.mkv' 'While You Were Sleeping (1995)'

# White Elephant (2022)
move_to_deleted '/mnt/media/Movies/White Elephant (2022)/White.Elephant.2022.1080p.BluRay.x264-PiGNUS.mkv' 'White Elephant (2022)'

# Winchester \'73 (1950)
move_to_deleted '/mnt/media/Movies/Winchester \'73 (1950)/Winchester \'73 (1950) {imdb-tt0043137} [Bluray-1080p][FLAC 1.0][x264]-ZoroSenpai.mkv' 'Winchester \'73 (1950)'

# Wonder Park (2019)
move_to_deleted '/mnt/media/Movies/Wonder Park (2019)/Wonder Park (2019) {imdb-tt6428676} [Bluray-1080p][EAC3 Atmos 7.1][x264]-iFT.mkv' 'Wonder Park (2019)'

# Worth (2021)
move_to_deleted '/mnt/media/Movies/Worth (2021)/Worth (2021) {imdb-tt8009744} [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv' 'Worth (2021)'

# The Worthy (2016)
move_to_deleted '/mnt/media/Movies/The Worthy (2016)/The Worthy (2016) {imdb-tt4943218} [NF][WEBDL-1080p][EAC3 5.1][x264]-PTerWEB.mkv' 'The Worthy (2016)'

# Wrecked (2011)
move_to_deleted '/mnt/media/Movies/Wrecked (2011)/Wrecked (2010) {imdb-tt1316622} [Bluray-1080p][DTS 5.1][x264]-OPS.mkv' 'Wrecked (2011)'

# Wrong Turn (2021)
move_to_deleted '/mnt/media/Movies/Wrong Turn (2021)/Wrong Turn (2021) {imdb-tt9110170} [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv' 'Wrong Turn (2021)'

# Wyatt Earp (1994)
move_to_deleted '/mnt/media/Movies/Wyatt Earp (1994)/Wyatt Earp (1994) {imdb-tt0111756} [Bluray-1080p][AC3 5.1][x264]-SbR.mkv' 'Wyatt Earp (1994)'

# You Should Have Left (2020)
move_to_deleted '/mnt/media/Movies/You Should Have Left (2020)/You Should Have Left (2020) {imdb-tt8201852} [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv' 'You Should Have Left (2020)'

# Zeros and Ones (2021)
move_to_deleted '/mnt/media/Movies/Zeros and Ones (2021)/Zeros.and.Ones.2021.1080p.BluRay.x264-PiGNUS.mkv' 'Zeros and Ones (2021)'

# xXx Return of Xander Cage (2017)
move_to_deleted '/mnt/media/Movies/xXx Return of Xander Cage (2017)/xXx Return of Xander Cage (2017) {imdb-tt1293847} - [Bluray-1080p][DTS-ES 6.1][x264]-NCmt.mkv' 'xXx Return of Xander Cage (2017)'

echo 'Action script completed.'
echo 'Set EXECUTE=true and re-run to perform actual moves.'

echo ""
echo "========================================================================"
if [ "$EXECUTE" = "true" ]; then
  echo "COMPLETE: Files moved to /mnt/user/Media/Deleted/Movies/"
else
  echo "DRY-RUN COMPLETE"
  echo ""
  echo "To execute:"
  echo "  1. Edit this script"
  echo "  2. Change EXECUTE=false to EXECUTE=true"
  echo "  3. Run: bash DELETE_Unraid_Movies.sh"
fi
echo "========================================================================"
