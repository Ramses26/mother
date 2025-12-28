#!/bin/bash
# FINAL Movies Sync Actions for Project Mother
# Generated: 2025-12-28 01:49:48.235162
# IMPORTANT: Move misplaced 4K movies FIRST before running this!

# Set to 'true' to execute, 'false' for dry-run
EXECUTE=false

move_to_deleted() {
  local file="$1"
  local movie_folder="$2"
  local dest="/media/Deleted/Movies/${movie_folder}/"
  
  if [ "$EXECUTE" = "true" ]; then
    mkdir -p "$dest"
    mv "$file" "$dest"
    echo "MOVED: $file -> $dest"
  else
    echo "DRY-RUN: Would move $file -> $dest"
  fi
}

# ========================================
# WARNING: MISPLACED 4K MOVIES DETECTED!
# ========================================
# Before running deletions, manually move these 4K movies
# from Movies folder to 4K Movies folder!
# Ali: 7 misplaced 4K movies
# Chris: 4 misplaced 4K movies
# See detailed report for full list and paths.

# ========================================
# STEP 1: Move Chris's lower quality/resolution files
# ========================================

# 12 Angry Men (1957) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/12 Angry Men (1957)/12 Angry Men (1957) {imdb-tt0050083} [Criterion Collection][Bluray-1080p][FLAC 1.0][x264]-decibeL.mkv' '12 Angry Men (1957)'

# 12 Strong (2018)
move_to_deleted '/mnt/synology/rs-movies/12 Strong (2018)/12 Strong (2018) {imdb-tt1413492} [Bluray-1080p][HDR10][EAC3 7.1][x265]-DON.mkv' '12 Strong (2018)'

# 13 Hours The Secret Soldiers of Benghazi (2016)
move_to_deleted '/mnt/synology/rs-movies/13 Hours The Secret Soldiers of Benghazi (2016)/13 Hours The Secret Soldiers of Benghazi (2016) {imdb-tt4172430} [Bluray-1080p][HDR10][EAC3 7.1][x265]-CtrlHD.mkv' '13 Hours The Secret Soldiers of Benghazi (2016)'

# The 13th Warrior (1999)
move_to_deleted '/mnt/synology/rs-movies/The 13th Warrior (1999)/The 13th Warrior (1999) {imdb-tt0120657} [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv' 'The 13th Warrior (1999)'

# 1917 (2019)
move_to_deleted '/mnt/synology/rs-movies/1917 (2019)/1917 (2019) {imdb-tt8579674} [WEBDL-1080p][AC3 5.1][h264].mkv' '1917 (2019)'

# 1992 (2024)
move_to_deleted '/mnt/synology/rs-movies/1992 (2024)/1992 (2024) {imdb-tt4959750} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' '1992 (2024)'

# 2 Days in the Valley (1996)
move_to_deleted '/mnt/synology/rs-movies/2 Days in the Valley (1996)/2 Days in the Valley (1996) {imdb-tt0115438} [WEBRip-1080p][EAC3 5.1][x264].mkv' '2 Days in the Valley (1996)'

# 21 Bridges (2019)
move_to_deleted '/mnt/synology/rs-movies/21 Bridges (2019)/21 Bridges (2019) {imdb-tt8688634} [Bluray-1080p][DTS 5.1][x264]-AAA.mkv' '21 Bridges (2019)'

# 21 Jump Street (2012)
move_to_deleted '/mnt/synology/rs-movies/21 Jump Street (2012)/21 Jump Street (2012) {imdb-tt1232829} [Bluray-1080p][HDR10][EAC3 7.1][x265]-NCmt.mkv' '21 Jump Street (2012)'

# 22 Jump Street (2014)
move_to_deleted '/mnt/synology/rs-movies/22 Jump Street (2014)/22 Jump Street (2014) {imdb-tt2294449} [Bluray-1080p][DTS-HD MA 5.1][x264].mkv' '22 Jump Street (2014)'

# 28 Years Later (2025)
move_to_deleted '/mnt/synology/rs-movies/28 Years Later (2025)/28 Years Later (2025) {imdb-tt10548174} - [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-BYNDR.mkv' '28 Years Later (2025)'

# 3 -10 to Yuma (2007)
move_to_deleted '/mnt/synology/rs-movies/3 -10 to Yuma (2007)/310 to Yuma (2007) {imdb-tt0381849} {edition-Open Matte} [AMZN MA][WEBDL-1080p][DTS-ES 5.1][AVC].mkv' '3 -10 to Yuma (2007)'

# 3 Ninjas (1992)
move_to_deleted '/mnt/synology/rs-movies/3 Ninjas (1992)/3 Ninjas (1992) {imdb-tt0103596} [AMZN][WEBDL-1080p][EAC3 2.0][x264]-ABM.mkv' '3 Ninjas (1992)'

# 355, The (2022)
move_to_deleted '/mnt/synology/rs-movies/355, The (2022)/The 355 (2022) {imdb-tt8356942} [WEBDL-1080p][AC3 5.1][h264]-DKV.mkv' '355, The (2022)'

# The 40 Year Old Virgin (2005)
move_to_deleted '/mnt/synology/rs-movies/The 40 Year Old Virgin (2005)/The 40 Year Old Virgin (2005) {imdb-tt0405422} {edition-Unrated} [Bluray-1080p][DTS 5.1][x264]-SeeNHD.mkv' 'The 40 Year Old Virgin (2005)'

# 48 Hrs. (1982)
move_to_deleted '/mnt/synology/rs-movies/48 Hrs. (1982)/48 Hrs. (1982) {imdb-tt0083511} [Bluray-1080p][AC3 5.1][x264].mkv' '48 Hrs. (1982)'

# 57 Seconds (2023)
move_to_deleted '/mnt/synology/rs-movies/57 Seconds (2023)/57 Seconds (2023) {imdb-tt18083578} [WEBDL-1080p][EAC3 5.1][x264]-EniaHD.mkv' '57 Seconds (2023)'

# 65 (2023)
move_to_deleted '/mnt/synology/rs-movies/65 (2023)/65 (2023) {imdb-tt12261776} [MA][WEBDL-1080p Proper][EAC3 Atmos 5.1][x264]-FLUX.mkv' '65 (2023)'

# 8 Mile (2002)
move_to_deleted '/mnt/synology/rs-movies/8 Mile (2002)/8 Mile (2002) {imdb-tt0298203} [Bluray-1080p][HDR10][EAC3 7.1][x265]-NTb.mkv' '8 Mile (2002)'

# 80 for Brady (2023)
move_to_deleted '/mnt/synology/rs-movies/80 for Brady (2023)/80 for Brady (2023) {imdb-tt18079362} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' '80 for Brady (2023)'

# 9 Bullets (2022)
move_to_deleted '/mnt/synology/rs-movies/9 Bullets (2022)/9 Bullets (2022) {imdb-tt13680520} [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv' '9 Bullets (2022)'

# A Complete Unknown (2024)
move_to_deleted '/mnt/synology/rs-movies/A Complete Unknown (2024)/A Complete Unknown (2024) {imdb-tt11563598} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-APEX.mkv' 'A Complete Unknown (2024)'

# A Different Man (2024)
move_to_deleted '/mnt/synology/rs-movies/A Different Man (2024)/A Different Man (2024) {imdb-tt21097228} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'A Different Man (2024)'

# A Family Affair (2024)
move_to_deleted '/mnt/synology/rs-movies/A Family Affair (2024)/A Family Affair (2024) {imdb-tt21051906} [WEBDL-1080p][EAC3 5.1][x264]-ETHEL.mkv' 'A Family Affair (2024)'

# A Haunting in Venice (2023)
move_to_deleted '/mnt/synology/rs-movies/A Haunting in Venice (2023)/A Haunting in Venice (2023) {imdb-tt22687790} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'A Haunting in Venice (2023)'

# A Knight\'s Tale (2001)
move_to_deleted '/mnt/synology/rs-movies/A Knight\'s Tale (2001)/A Knight\'s Tale (2001) {imdb-tt0183790} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv' 'A Knight\'s Tale (2001)'

# A Minecraft Movie (2025)
move_to_deleted '/mnt/synology/rs-movies/A Minecraft Movie (2025)/A Minecraft Movie (2025) {imdb-tt3566834} [WEBDL-1080p][EAC3 5.1][h264]-ETHEL.mkv' 'A Minecraft Movie (2025)'

# A Nightmare on Elm Street (1984)
move_to_deleted '/mnt/synology/rs-movies/A Nightmare on Elm Street (1984)/A Nightmare on Elm Street (1984) {imdb-tt0087800} [Bluray-1080p][EAC3 5.1][x264]-WiNHD.mkv' 'A Nightmare on Elm Street (1984)'

# A Quiet Place Day One (2024)
move_to_deleted '/mnt/synology/rs-movies/A Quiet Place Day One (2024)/A Quiet Place Day One (2024) {imdb-tt13433802} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-AccomplishedYak.mkv' 'A Quiet Place Day One (2024)'

# AVPR - Aliens vs Predator - Requiem (2007)
move_to_deleted '/mnt/synology/rs-movies/AVPR - Aliens vs Predator - Requiem (2007)/Aliens vs Predator Requiem (2007) {imdb-tt0758730} {edition-Theatrical} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-EMb.mkv' 'AVPR - Aliens vs Predator - Requiem (2007)'

# Abbott and Costello Meet the Mummy (1955)
move_to_deleted '/mnt/synology/rs-movies/Abbott and Costello Meet the Mummy (1955)/Abbott and Costello Meet the Mummy (1955) {imdb-tt0047795} [AMZN][WEBDL-1080p][EAC3 2.0][x264]-ABM.mkv' 'Abbott and Costello Meet the Mummy (1955)'

# Abigail (2024)
move_to_deleted '/mnt/synology/rs-movies/Abigail (2024)/Abigail (2024) {imdb-tt27489557} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Abigail (2024)'

# Abominable (2019)
move_to_deleted '/mnt/synology/rs-movies/Abominable (2019)/Abominable (2019) {imdb-tt6324278} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Abominable (2019)'

# Absolute Power (1997)
move_to_deleted '/mnt/synology/rs-movies/Absolute Power (1997)/Absolute Power (1997) {imdb-tt0118548} [HDTV-1080p][DTS 5.1][x264].mkv' 'Absolute Power (1997)'

# The Abyss (1989)
move_to_deleted '/mnt/synology/rs-movies/The Abyss (1989)/The Abyss (1989) {imdb-tt0096754} [WEBDL-1080p][EAC3 5.1][h264].mkv' 'The Abyss (1989)'

# Accountant 2, The (2025)
move_to_deleted '/mnt/synology/rs-movies/Accountant 2, The (2025)/The Accountant² (2025) {imdb-tt7068946} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-WADU.mkv' 'Accountant 2, The (2025)'

# Accountant, The (2016)
move_to_deleted '/mnt/synology/rs-movies/Accountant, The (2016)/The Accountant (2016) {imdb-tt2140479} [Bluray-1080p][DTS 5.1][x264]-DON.mkv' 'Accountant, The (2016)'

# Ace Ventura When Nature Calls (1995)
move_to_deleted '/mnt/synology/rs-movies/Ace Ventura When Nature Calls (1995)/Ace Ventura When Nature Calls (1995) {imdb-tt0112281} [HDTV-1080p][AAC 2.0][h264].mkv' 'Ace Ventura When Nature Calls (1995)'

# Ad Astra (2019)
move_to_deleted '/mnt/synology/rs-movies/Ad Astra (2019)/Ad Astra (2019) {imdb-tt2935510} [WEBDL-1080p][EAC3 5.1][h264].mkv' 'Ad Astra (2019)'

# Addams Family, The (2019)
move_to_deleted '/mnt/synology/rs-movies/Addams Family, The (2019)/The Addams Family (2019) {imdb-tt1620981} [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv' 'Addams Family, The (2019)'

# Adore (2013) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Adore (2013)/Adore (2013) {imdb-tt2103267} [Bluray-720p][AC3 5.1][x264]-CRiSC.mkv' 'Adore (2013)'

# Afraid (2024)
move_to_deleted '/mnt/synology/rs-movies/Afraid (2024)/Afraid (2024) {imdb-tt24577462} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Afraid (2024)'

# After We Fell (2021)
move_to_deleted '/mnt/synology/rs-movies/After We Fell (2021)/After We Fell (2021) {imdb-tt13069986} [Bluray-1080p][AC3 5.1][x264]-eMc2.mkv' 'After We Fell (2021)'

# Afterburn (2025)
move_to_deleted '/mnt/synology/rs-movies/Afterburn (2025)/Afterburn (2025) {imdb-tt1210027} - [AMZN][WEBDL-1080p Proper][EAC3 5.1][h264]-FLUX.mkv' 'Afterburn (2025)'

# Against the Ice (2022)
move_to_deleted '/mnt/synology/rs-movies/Against the Ice (2022)/Against the Ice (2022) {imdb-tt13873302} [NF][WEBDL-1080p Proper][EAC3 Atmos 5.1][x264]-TEPES.mkv' 'Against the Ice (2022)'

# Agent Game (2022)
move_to_deleted '/mnt/synology/rs-movies/Agent Game (2022)/Agent Game (2022) {imdb-tt14168394} [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv' 'Agent Game (2022)'

# Air (2023)
move_to_deleted '/mnt/synology/rs-movies/Air (2023)/Air (2023) {imdb-tt16419074} [WEBDL-1080p Proper][EAC3 Atmos 5.1][h264]-NAISU.mkv' 'Air (2023)'

# Airplane II The Sequel (1982)
move_to_deleted '/mnt/synology/rs-movies/Airplane II The Sequel (1982)/Airplane II The Sequel (1982) {imdb-tt0083530} [Bluray-1080p][DTS 2.0][x264].mkv' 'Airplane II The Sequel (1982)'

# Airplane! (1980)
move_to_deleted '/mnt/synology/rs-movies/Airplane! (1980)/Airplane! (1980) {imdb-tt0080339} [Bluray-1080p][DTS 5.1][x264].mkv' 'Airplane! (1980)'

# Akira (1988)
move_to_deleted '/mnt/synology/rs-movies/Akira (1988)/Akira (1988) {imdb-tt0094625} [Bluray-1080p][AC3 5.1][x264]-D-Z0N3.mkv' 'Akira (1988)'

# Alien (1979)
move_to_deleted '/mnt/synology/rs-movies/Alien (1979)/Alien (1979) {imdb-tt0078748} [Bluray-1080p][DTS-HD MA 5.1][x264].mkv' 'Alien (1979)'

# Alien Nation (1988)
move_to_deleted '/mnt/synology/rs-movies/Alien Nation (1988)/Alien Nation (1988) {imdb-tt0094631} [Bluray-1080p][DTS 5.1][x264]-FGT.mkv' 'Alien Nation (1988)'

# Alien Romulus (2024)
move_to_deleted '/mnt/synology/rs-movies/Alien Romulus (2024)/Alien Romulus (2024) {imdb-tt18412256} [WEBDL-1080p][EAC3 7.1][h264]-Spidey.mkv' 'Alien Romulus (2024)'

# Alita Battle Angel (2019)
move_to_deleted '/mnt/synology/rs-movies/Alita Battle Angel (2019)/Alita Battle Angel (2019) {imdb-tt0437086} [Bluray-1080p][EAC3 7.1][x264]-TDD.mkv' 'Alita Battle Angel (2019)'

# All Quiet on the Western Front (1979)
move_to_deleted '/mnt/synology/rs-movies/All Quiet on the Western Front (1979)/All Quiet on the Western Front (1979) {imdb-tt0078753} [AMZN][WEBDL-1080p][EAC3 2.0][h264]-EDGE2020.mkv' 'All Quiet on the Western Front (1979)'

# All Quiet on the Western Front (2022)
move_to_deleted '/mnt/synology/rs-movies/All Quiet on the Western Front (2022)/All Quiet on the Western Front (2022) {imdb-tt1016150} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-playWEB.mkv' 'All Quiet on the Western Front (2022)'

# All That Breathes (2022)
move_to_deleted '/mnt/synology/rs-movies/All That Breathes (2022)/All That Breathes (2022) {imdb-tt16377862} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'All That Breathes (2022)'

# All We Imagine as Light (2024)
move_to_deleted '/mnt/synology/rs-movies/All We Imagine as Light (2024)/All We Imagine as Light (2024) {imdb-tt32086077} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BLiNDEDBYLIGHTS.mkv' 'All We Imagine as Light (2024)'

# All of Us Strangers (2023)
move_to_deleted '/mnt/synology/rs-movies/All of Us Strangers (2023)/All of Us Strangers (2023) {imdb-tt21192142} [Bluray-1080p][EAC3 5.1][x264]-refresh.mkv' 'All of Us Strangers (2023)'

# Amadeus (1984)
move_to_deleted '/mnt/synology/rs-movies/Amadeus (1984)/Amadeus (1984) {imdb-tt0086879} [Bluray-1080p Proper][DTS 5.1][x264]-PerfectionHD.mkv' 'Amadeus (1984)'

# Ambulance (2022)
move_to_deleted '/mnt/synology/rs-movies/Ambulance (2022)/Ambulance (2022) {imdb-tt4998632} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-slot.mkv' 'Ambulance (2022)'

# Ambush (2023)
move_to_deleted '/mnt/synology/rs-movies/Ambush (2023)/Ambush (2023) {imdb-tt8270664} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Ambush (2023)'

# American Fiction (2023)
move_to_deleted '/mnt/synology/rs-movies/American Fiction (2023)/American Fiction (2023) {imdb-tt23561236} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'American Fiction (2023)'

# American Gangster (2007)
move_to_deleted '/mnt/synology/rs-movies/American Gangster (2007)/American Gangster (2007) {imdb-tt0765429} {edition-Unrated} [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv' 'American Gangster (2007)'

# American Hustle (2013)
move_to_deleted '/mnt/synology/rs-movies/American Hustle (2013)/American Hustle (2013) {imdb-tt1800241} [Bluray-1080p][DTS 5.1][x264]-DON.mkv' 'American Hustle (2013)'

# American Pie (1999)
move_to_deleted '/mnt/synology/rs-movies/American Pie (1999)/American Pie (1999) {imdb-tt0163651} {edition-Unrated} [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv' 'American Pie (1999)'

# American Pie Presents Band Camp (2005)
move_to_deleted '/mnt/synology/rs-movies/American Pie Presents Band Camp (2005)/American Pie Presents Band Camp (2005) {imdb-tt0436058} {edition-Unrated} [AMZN][WEBRip-1080p][EAC3 5.1][x264]-KiNGS.mkv' 'American Pie Presents Band Camp (2005)'

# American Pie Presents Beta House (2007)
move_to_deleted '/mnt/synology/rs-movies/American Pie Presents Beta House (2007)/American Pie Presents Beta House (2007) {imdb-tt0974959} {edition-Unrated} [WEBRip-1080p][EAC3 5.1][x264]-KiNGS.mkv' 'American Pie Presents Beta House (2007)'

# American Pie Presents The Naked Mile (2006)
move_to_deleted '/mnt/synology/rs-movies/American Pie Presents The Naked Mile (2006)/American Pie Presents The Naked Mile (2006) {imdb-tt0808146} [WEBRip-1080p][EAC3 5.1][x264]-KiNGS.mkv' 'American Pie Presents The Naked Mile (2006)'

# American Psycho (2000)
move_to_deleted '/mnt/synology/rs-movies/American Psycho (2000)/American Psycho (2000) {imdb-tt0144084} [Bluray-1080p][EAC3 7.1][x264]-c0kE.mkv' 'American Psycho (2000)'

# An American Tail Fievel Goes West (1991) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/An American Tail Fievel Goes West (1991)/An American Tail Fievel Goes West (1991) {imdb-tt0101329} [HDTV-720p][AC3 2.0][x264].mkv' 'An American Tail Fievel Goes West (1991)'

# Amsterdam (2022)
move_to_deleted '/mnt/synology/rs-movies/Amsterdam (2022)/Amsterdam (2022) {imdb-tt10304142} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv' 'Amsterdam (2022)'

# Angels & Demons (2009)
move_to_deleted '/mnt/synology/rs-movies/Angels & Demons (2009)/Angels & Demons (2009) {imdb-tt0808151} [Bluray-1080p][HDR10][EAC3 7.1][x265]-CtrlHD.mkv' 'Angels & Demons (2009)'

# Anna (2019)
move_to_deleted '/mnt/synology/rs-movies/Anna (2019)/Anna (2019) {imdb-tt7456310} [Bluray-1080p][HDR10][EAC3 7.1][x265]-SA89.mkv' 'Anna (2019)'

# Annabelle (2014) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Annabelle (2014)/Annabelle (2014) {imdb-tt3322940} [Bluray-720p][DTS 5.1][x264].mkv' 'Annabelle (2014)'

# Annabelle Comes Home (2019)
move_to_deleted '/mnt/synology/rs-movies/Annabelle Comes Home (2019)/Annabelle Comes Home (2019) {imdb-tt8350360} [WEBDL-1080p][AC3 5.1][x264]-DKV.mkv' 'Annabelle Comes Home (2019)'

# Annette (2021)
move_to_deleted '/mnt/synology/rs-movies/Annette (2021)/Annette (2021) {imdb-tt6217926} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv' 'Annette (2021)'

# Annihilation (2018)
move_to_deleted '/mnt/synology/rs-movies/Annihilation (2018)/Annihilation (2018) {imdb-tt2798920} [Bluray-1080p][DTS 5.1][x264].mkv' 'Annihilation (2018)'

# Another 48 Hrs. (1990)
move_to_deleted '/mnt/synology/rs-movies/Another 48 Hrs. (1990)/Another 48 Hrs. (1990) {imdb-tt0099044} [WEBDL-1080p][EAC3 5.1][x264].mkv' 'Another 48 Hrs. (1990)'

# Another Simple Favor (2025) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Another Simple Favor (2025)/Another Simple Favor (2025) {imdb-tt20214908} [WEBDL-720p][EAC3 Atmos 5.1][h264]-SKYFiRE.mkv' 'Another Simple Favor (2025)'

# Ant-Man and the Wasp Quantumania (2023)
move_to_deleted '/mnt/synology/rs-movies/Ant-Man and the Wasp Quantumania (2023)/Ant-Man and the Wasp Quantumania (2023) {imdb-tt10954600} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-CMRG.mkv' 'Ant-Man and the Wasp Quantumania (2023)'

# Anthony Jeselnik Thoughts and Prayers (2015)
move_to_deleted '/mnt/synology/rs-movies/Anthony Jeselnik Thoughts and Prayers (2015)/Anthony Jeselnik Thoughts and Prayers (2015) {imdb-tt5087554} [NF][WEBRip-1080p][AC3 5.1][x264]-monkee.mkv' 'Anthony Jeselnik Thoughts and Prayers (2015)'

# Antlers (2021)
move_to_deleted '/mnt/synology/rs-movies/Antlers (2021)/Antlers (2021) {imdb-tt7740510} [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv' 'Antlers (2021)'

# Anyone But You (2023)
move_to_deleted '/mnt/synology/rs-movies/Anyone But You (2023)/Anyone But You (2023) {imdb-tt26047818} [WEBDL-1080p][AC3 5.1][h264]-HowIFeelAboutDonaldTrump.mkv' 'Anyone But You (2023)'

# Apocalypse Now (1979)
move_to_deleted '/mnt/synology/rs-movies/Apocalypse Now (1979)/Apocalypse Now (1979) {imdb-tt0078788} {edition-Final Cut} [Bluray-1080p][HDR10][EAC3 7.1][x265]-Z0N3.mkv' 'Apocalypse Now (1979)'

# Apocalypto (2006)
move_to_deleted '/mnt/synology/rs-movies/Apocalypto (2006)/Apocalypto (2006) {imdb-tt0472043} [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv' 'Apocalypto (2006)'

# Apollo 13 (1995)
move_to_deleted '/mnt/synology/rs-movies/Apollo 13 (1995)/Apollo 13 (1995) {imdb-tt0112384} [Bluray-1080p][DTS 5.1][x264].mkv' 'Apollo 13 (1995)'

# Aquaman (2018)
move_to_deleted '/mnt/synology/rs-movies/Aquaman (2018)/Aquaman (2018) {imdb-tt1477834} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Aquaman (2018)'

# Arcadian (2024)
move_to_deleted '/mnt/synology/rs-movies/Arcadian (2024)/Arcadian (2024) {imdb-tt22939186} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Arcadian (2024)'

# Are You There God Its Me Margaret. (2023)
move_to_deleted '/mnt/synology/rs-movies/Are You There God Its Me Margaret. (2023)/Are You There God! It\'s Me, Margaret. (2023) {imdb-tt9185206} [WEBDL-1080p][AC3 5.1][h264]-DKV.mkv' 'Are You There God Its Me Margaret. (2023)'

# Army of the Dead ()
move_to_deleted '/mnt/synology/rs-movies/Army of the Dead ()/Army of the Dead (2021) {imdb-tt0993840} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-MZABI.mkv' 'Army of the Dead ()'

# Around the World in 80 Days (2004)
move_to_deleted '/mnt/synology/rs-movies/Around the World in 80 Days (2004)/Around the World in 80 Days (2004) {imdb-tt0327437} {edition-Open Matte} [WEBDL-1080p][EAC3 5.1][h264].mkv' 'Around the World in 80 Days (2004)'

# Arrival (2016)
move_to_deleted '/mnt/synology/rs-movies/Arrival (2016)/Arrival (2016) {imdb-tt2543164} [HDTV-1080p][AC3 5.1][h264].mkv' 'Arrival (2016)'

# Art of Racing in the Rain, The (2019)
move_to_deleted '/mnt/synology/rs-movies/Art of Racing in the Rain, The (2019)/The Art of Racing in the Rain (2019) {imdb-tt1478839} [WEBDL-2160p][PQ][DTS-HD MA 7.1][HEVC]-TEPES.mkv' 'Art of Racing in the Rain, The (2019)'

# Arthur the King (2024)
move_to_deleted '/mnt/synology/rs-movies/Arthur the King (2024)/Arthur the King (2024) {imdb-tt10720352} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Arthur the King (2024)'

# As Good As It Gets (1997)
move_to_deleted '/mnt/synology/rs-movies/As Good As It Gets (1997)/As Good as It Gets (1997) {imdb-tt0119822} [Bluray-1080p][DV HDR10][EAC3 7.1][x265]-c0kE.mkv' 'As Good As It Gets (1997)'

# Ash (2025)
move_to_deleted '/mnt/synology/rs-movies/Ash (2025)/Ash (2025) {imdb-tt17489650} [WEBDL-1080p][EAC3 5.1][h264]-DiligentSpectralCougarOfPassion.mkv' 'Ash (2025)'

# Asphalt City (2024)
move_to_deleted '/mnt/synology/rs-movies/Asphalt City (2024)/Asphalt City (2024) {imdb-tt9663896} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Asphalt City (2024)'

# Assassin (2023)
move_to_deleted '/mnt/synology/rs-movies/Assassin (2023)/Assassin (2023) {imdb-tt14555174} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Assassin (2023)'

# Assassins Creed (2016)
move_to_deleted '/mnt/synology/rs-movies/Assassins Creed (2016)/Assassin\'s Creed (2016) {imdb-tt2094766} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Assassins Creed (2016)'

# The Assassination of Jesse James by the Coward Robert Ford (2007) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/The Assassination of Jesse James by the Coward Robert Ford (2007)/The Assassination of Jesse James by the Coward Robert Ford (2007) {imdb-tt0443680} [Bluray-720p][AC3 5.1][x264].mkv' 'The Assassination of Jesse James by the Coward Robert Ford (2007)'

# Atlantis The Lost Empire (2001)
move_to_deleted '/mnt/synology/rs-movies/Atlantis The Lost Empire (2001)/Atlantis The Lost Empire (2001) {imdb-tt0230011} [Bluray-1080p][AC3 5.1][x264]-HDMaNiAcS.mkv' 'Atlantis The Lost Empire (2001)'

# Atomic Blonde (2017)
move_to_deleted '/mnt/synology/rs-movies/Atomic Blonde (2017)/Atomic Blonde (2017) {imdb-tt2406566} [Bluray-1080p][DTS 5.1][x264]-ZQ.mkv' 'Atomic Blonde (2017)'

# Avengers Infinity War (2018)
move_to_deleted '/mnt/synology/rs-movies/Avengers Infinity War (2018)/Avengers Infinity War (2018) {imdb-tt4154756} [Bluray-1080p][DTS-HD MA 7.1][x264].mkv' 'Avengers Infinity War (2018)'

# The Aviator (2004)
move_to_deleted '/mnt/synology/rs-movies/The Aviator (2004)/The Aviator (2004) {imdb-tt0338751} [AMZN][WEBDL-1080p][DTS 5.1][h264].mkv' 'The Aviator (2004)'

# Azrael (2024)
move_to_deleted '/mnt/synology/rs-movies/Azrael (2024)/Azrael (2024) {imdb-tt22173666} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Azrael (2024)'

# Aztec Batman Clash of Empires (2025)
move_to_deleted '/mnt/synology/rs-movies/Aztec Batman Clash of Empires (2025)/Aztec Batman Clash of Empires (2025) {imdb-tt21110654} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'Aztec Batman Clash of Empires (2025)'

# Baby Driver (2017)
move_to_deleted '/mnt/synology/rs-movies/Baby Driver (2017)/Baby Driver (2017) {imdb-tt3890160} [Bluray-1080p][HDR10][EAC3 7.1][x265]-NCmt.mkv' 'Baby Driver (2017)'

# Babygirl (2024)
move_to_deleted '/mnt/synology/rs-movies/Babygirl (2024)/Babygirl (2024) {imdb-tt30057084} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-APEX.mkv' 'Babygirl (2024)'

# Babylon (2022)
move_to_deleted '/mnt/synology/rs-movies/Babylon (2022)/Babylon (2022) {imdb-tt10640346} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-CMRG.mkv' 'Babylon (2022)'

# Back to Black (2024)
move_to_deleted '/mnt/synology/rs-movies/Back to Black (2024)/Back to Black (2024) {imdb-tt21261712} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Back to Black (2024)'

# Back to the Future (1985)
move_to_deleted '/mnt/synology/rs-movies/Back to the Future (1985)/Back to the Future (1985) {imdb-tt0088763} [Bluray-1080p][HDR10Plus][EAC3 7.1][x265]-DON.mkv' 'Back to the Future (1985)'

# Back to the Future Part II (1989)
move_to_deleted '/mnt/synology/rs-movies/Back to the Future Part II (1989)/Back to the Future Part II (1989) {imdb-tt0096874} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv' 'Back to the Future Part II (1989)'

# Back to the Future Part III (1990)
move_to_deleted '/mnt/synology/rs-movies/Back to the Future Part III (1990)/Back to the Future Part III (1990) {imdb-tt0099088} [Bluray-1080p][HDR10Plus][EAC3 7.1][x265]-DON.mkv' 'Back to the Future Part III (1990)'

# Bad Boys (1995)
move_to_deleted '/mnt/synology/rs-movies/Bad Boys (1995)/Bad Boys (1995) {imdb-tt0112442} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv' 'Bad Boys (1995)'

# Bad Boys II (2003)
move_to_deleted '/mnt/synology/rs-movies/Bad Boys II (2003)/Bad Boys II (2003) {imdb-tt0172156} [Bluray-1080p][DTS 5.1][x264]-DON.mkv' 'Bad Boys II (2003)'

# Bad Boys for Life (2020)
move_to_deleted '/mnt/synology/rs-movies/Bad Boys for Life (2020)/Bad Boys for Life (2020) {imdb-tt1502397} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Bad Boys for Life (2020)'

# Bad Education (2019)
move_to_deleted '/mnt/synology/rs-movies/Bad Education (2019)/Bad Education (2019) {imdb-tt8206668} [WEBDL-1080p][EAC3 5.1][h264]-SECRECY.mkv' 'Bad Education (2019)'

# Baghead (2023)
move_to_deleted '/mnt/synology/rs-movies/Baghead (2023)/Baghead (2023) {imdb-tt14030816} [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Baghead (2023)'

# Bagman (2024)
move_to_deleted '/mnt/synology/rs-movies/Bagman (2024)/Bagman (2024) {imdb-tt21201300} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Bagman (2024)'

# Ballerina (2025)
move_to_deleted '/mnt/synology/rs-movies/Ballerina (2025)/Ballerina (2025) {imdb-tt7181546} - [Bluray-1080p][TrueHD Atmos 7.1][x264]-ROEN.mkv' 'Ballerina (2025)'

# Bandit (2022)
move_to_deleted '/mnt/synology/rs-movies/Bandit (2022)/Bandit (2022) {imdb-tt9853500} [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv' 'Bandit (2022)'

# Barbie (2023)
move_to_deleted '/mnt/synology/rs-movies/Barbie (2023)/Barbie (2023) {imdb-tt1517268} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Barbie (2023)'

# Batman (1989)
move_to_deleted '/mnt/synology/rs-movies/Batman (1989)/Batman (1989) {imdb-tt0096895} [Bluray-1080p][EAC3 7.1][x264]-LoRD.mkv' 'Batman (1989)'

# Batman - The Dark Knight Returns, Part 2 (2013)
move_to_deleted '/mnt/synology/rs-movies/Batman - The Dark Knight Returns, Part 2 (2013)/Batman The Dark Knight Returns Part 2 (2013) {imdb-tt2166834} [WEBDL-1080p][EAC3 5.1][x264]-Kitsune.mkv' 'Batman - The Dark Knight Returns, Part 2 (2013)'

# Batman Begins (2005)
move_to_deleted '/mnt/synology/rs-movies/Batman Begins (2005)/Batman Begins (2005) {imdb-tt0372784} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv' 'Batman Begins (2005)'

# Batman Mystery of the Batwoman (2003)
move_to_deleted '/mnt/synology/rs-movies/Batman Mystery of the Batwoman (2003)/Batman Mystery of the Batwoman (2003) {imdb-tt0346578} [WEBDL-1080p][DTS 5.1][x264].mkv' 'Batman Mystery of the Batwoman (2003)'

# Batman Returns (1992)
move_to_deleted '/mnt/synology/rs-movies/Batman Returns (1992)/Batman Returns (1992) {imdb-tt0103776} [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv' 'Batman Returns (1992)'

# Batman Soul of the Dragon (2021)
move_to_deleted '/mnt/synology/rs-movies/Batman Soul of the Dragon (2021)/Batman Soul of the Dragon (2021) {imdb-tt12885852} [WEBDL-1080p][EAC3 5.1][x264]-CMRG.mkv' 'Batman Soul of the Dragon (2021)'

# Batman The Doom That Came to Gotham (2023)
move_to_deleted '/mnt/synology/rs-movies/Batman The Doom That Came to Gotham (2023)/Batman The Doom That Came to Gotham (2023) {imdb-tt24223450} [WEBDL-1080p][EAC3 5.1][h264]-SKiZOiD.mkv' 'Batman The Doom That Came to Gotham (2023)'

# Batman The Long Halloween, Part Two (2021)
move_to_deleted '/mnt/synology/rs-movies/Batman The Long Halloween, Part Two (2021)/Batman The Long Halloween, Part Two (2021) {imdb-tt14402926} [WEBDL-1080p][EAC3 5.1][x264]-EVO.mkv' 'Batman The Long Halloween, Part Two (2021)'

# Batman v Superman Dawn of Justice (2016)
move_to_deleted '/mnt/synology/rs-movies/Batman v Superman Dawn of Justice (2016)/Batman v Superman Dawn of Justice (2016) {imdb-tt2975590} [Bluray-1080p][AC3 5.1][x264].mkv' 'Batman v Superman Dawn of Justice (2016)'

# The Batman (2022)
move_to_deleted '/mnt/synology/rs-movies/The Batman (2022)/The Batman (2022) {imdb-tt1877830} [WEBDL-1080p][AAC 2.0][h264]-CMRG.mkv' 'The Batman (2022)'

# Battle for the Planet of the Apes (1973)
move_to_deleted '/mnt/synology/rs-movies/Battle for the Planet of the Apes (1973)/Battle for the Planet of the Apes (1973) {imdb-tt0069768} [WEBDL-1080p][AAC 2.0][h264]-PiRaTeS.mkv' 'Battle for the Planet of the Apes (1973)'

# Battleship (2012)
move_to_deleted '/mnt/synology/rs-movies/Battleship (2012)/Battleship (2012) {imdb-tt1440129} [Bluray-1080p][HDR10][DTS 5.1][x265]-HQMUX.mkv' 'Battleship (2012)'

# Baywatch (2017)
move_to_deleted '/mnt/synology/rs-movies/Baywatch (2017)/Baywatch (2017) {imdb-tt1469304} [Bluray-1080p][AC3 5.1][x264].mkv' 'Baywatch (2017)'

# Bean (1997)
move_to_deleted '/mnt/synology/rs-movies/Bean (1997)/Bean (1997) {imdb-tt0118689} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Bean (1997)'

# Beast (2022)
move_to_deleted '/mnt/synology/rs-movies/Beast (2022)/Beast (2022) {imdb-tt13223398} [NF][WEBDL-1080p][EAC3 5.1][x264]-KHN.mkv' 'Beast (2022)'

# Beast of War (2025)
move_to_deleted '/mnt/synology/rs-movies/Beast of War (2025)/Beast of War (2025) {imdb-tt29468874} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-KyoGo.mkv' 'Beast of War (2025)'

# Beau Is Afraid (2023)
move_to_deleted '/mnt/synology/rs-movies/Beau Is Afraid (2023)/Beau Is Afraid (2023) {imdb-tt13521006} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-CMRG.mkv' 'Beau Is Afraid (2023)'

# A Beautiful Day in the Neighborhood (2019)
move_to_deleted '/mnt/synology/rs-movies/A Beautiful Day in the Neighborhood (2019)/A Beautiful Day in the Neighborhood (2019) {imdb-tt3224458} [WEBDL-1080p][AC3 5.1][h264].mkv' 'A Beautiful Day in the Neighborhood (2019)'

# Beauty and the Beast (2017)
move_to_deleted '/mnt/synology/rs-movies/Beauty and the Beast (2017)/Beauty and the Beast (2017) {imdb-tt2771200} [Bluray-1080p][DTS 5.1][x264].mkv' 'Beauty and the Beast (2017)'

# Beetlejuice Beetlejuice (2024)
move_to_deleted '/mnt/synology/rs-movies/Beetlejuice Beetlejuice (2024)/Beetlejuice Beetlejuice (2024) {imdb-tt2049403} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Beetlejuice Beetlejuice (2024)'

# Beowulf (1999)
move_to_deleted '/mnt/synology/rs-movies/Beowulf (1999)/Beowulf (1999) {imdb-tt0120604} [WEBDL-1080p][EAC3 2.0][x264]-FOCUS.mkv' 'Beowulf (1999)'

# Better Man (2024)
move_to_deleted '/mnt/synology/rs-movies/Better Man (2024)/Better Man (2024) {imdb-tt14260836} [WEBDL-1080p][AAC 5.1][AV1]-AV1-LuCY.mkv' 'Better Man (2024)'

# Better Off Dead. (1985)
move_to_deleted '/mnt/synology/rs-movies/Better Off Dead. (1985)/Better Off Dead. (1985) {imdb-tt0088794} [Bluray-1080p][DTS 5.1][x264]-mintHD.mkv' 'Better Off Dead. (1985)'

# Beverly Hills Cop Axel F ()
move_to_deleted '/mnt/synology/rs-movies/Beverly Hills Cop Axel F ()/Beverly Hills Cop Axel F (2024) {imdb-tt3083016} [WEBDL-1080p][EAC3 Atmos 5.1][x264]-ETHEL.mkv' 'Beverly Hills Cop Axel F ()'

# Beverly Hills Ninja (1997)
move_to_deleted '/mnt/synology/rs-movies/Beverly Hills Ninja (1997)/Beverly Hills Ninja (1997) {imdb-tt0118708} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-monkee.mkv' 'Beverly Hills Ninja (1997)'

# Beyond the Stars (1989)
move_to_deleted '/mnt/synology/rs-movies/Beyond the Stars (1989)/Beyond the Stars (1989) {imdb-tt0096921} [WEBDL-1080p][EAC3 2.0][h264]-ISA.mkv' 'Beyond the Stars (1989)'

# Big (1988)
move_to_deleted '/mnt/synology/rs-movies/Big (1988)/Big (1988) {imdb-tt0094737} {edition-Extended} [HDTV-1080p][DTS 5.1][x264]-CHD.mkv' 'Big (1988)'

# Big Green, The (1995)
move_to_deleted '/mnt/synology/rs-movies/Big Green, The (1995)/The Big Green (1995) {imdb-tt0112499} [DSNP][WEBDL-1080p][AAC 2.0][h264]-CineFun.mkv' 'Big Green, The (1995)'

# Bill & Ted Face the Music (2020)
move_to_deleted '/mnt/synology/rs-movies/Bill & Ted Face the Music (2020)/Bill & Ted Face the Music (2020) {imdb-tt1086064} [WEBDL-1080p][EAC3 5.1][h264].mkv' 'Bill & Ted Face the Music (2020)'

# Bill Burr Walk Your Way Out (2017)
move_to_deleted '/mnt/synology/rs-movies/Bill Burr Walk Your Way Out (2017)/Bill Burr Walk Your Way Out (2017) {imdb-tt6184894} [NF][WEBRip-1080p][AC3 5.1][x264]-TrollHD.mkv' 'Bill Burr Walk Your Way Out (2017)'

# Bird (2024)
move_to_deleted '/mnt/synology/rs-movies/Bird (2024)/Bird (2024) {imdb-tt28277817} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv' 'Bird (2024)'

# Bird Box (2018)
move_to_deleted '/mnt/synology/rs-movies/Bird Box (2018)/Bird Box (2018) {imdb-tt2737304} [WEBDL-1080p][AC3 5.1][x264].mkv' 'Bird Box (2018)'

# Bird Box Barcelona (2023)
move_to_deleted '/mnt/synology/rs-movies/Bird Box Barcelona (2023)/Bird Box Barcelona (2023) {imdb-tt14400246} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-GERALT.mkv' 'Bird Box Barcelona (2023)'

# Birds of Prey (And the Fantabulous Emancipation of One Harley Quinn) (2020)
move_to_deleted '/mnt/synology/rs-movies/Birds of Prey (And the Fantabulous Emancipation of One Harley Quinn) (2020)/Birds of Prey (and the Fantabulous Emancipation of One Harley Quinn) (2020) {imdb-tt7713068} [WEBDL-1080p][EAC3 Atmos 5.1][h264].mkv' 'Birds of Prey (And the Fantabulous Emancipation of One Harley Quinn) (2020)'

# Birth Rebirth (2023)
move_to_deleted '/mnt/synology/rs-movies/Birth Rebirth (2023)/Birth+Rebirth (2023) {imdb-tt9048804} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Birth Rebirth (2023)'

# Black Clover Sword of the Wizard King (2023)
move_to_deleted '/mnt/synology/rs-movies/Black Clover Sword of the Wizard King (2023)/Black Clover Sword of the Wizard King (2023) {imdb-tt22868844} [NF][WEBDL-1080p Proper][EAC3 5.1][x264]-Kitsune.mkv' 'Black Clover Sword of the Wizard King (2023)'

# Black Hawk Down (2001)
move_to_deleted '/mnt/synology/rs-movies/Black Hawk Down (2001)/Black Hawk Down (2001) {imdb-tt0265086} {edition-Extended Cut} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Black Hawk Down (2001)'

# Black Lotus (2023)
move_to_deleted '/mnt/synology/rs-movies/Black Lotus (2023)/Black Lotus (2023) {imdb-tt15895490} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-DarQ.mkv' 'Black Lotus (2023)'

# Black Mirror Bandersnatch (2018)
move_to_deleted '/mnt/synology/rs-movies/Black Mirror Bandersnatch (2018)/Black Mirror Bandersnatch (2018) {imdb-tt9495224} [WEBDL-1080p Proper][EAC3 5.1][x264]-DEFLATE.mkv' 'Black Mirror Bandersnatch (2018)'

# Black Panther (2018)
move_to_deleted '/mnt/synology/rs-movies/Black Panther (2018)/Black Panther (2018) {imdb-tt1825683} [Bluray-1080p][DTS 5.1][x264].mkv' 'Black Panther (2018)'

# Black Phone 2 (2025)
move_to_deleted '/mnt/synology/rs-movies/Black Phone 2 (2025)/Black Phone 2 (2025) {imdb-tt29644189} - [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Black Phone 2 (2025)'

# The Black Phone (2022)
move_to_deleted '/mnt/synology/rs-movies/The Black Phone (2022)/The Black Phone (2022) {imdb-tt7144666} [WEBDL-1080p][EAC3 5.1][h264].mkv' 'The Black Phone (2022)'

# Black Widow (2021)
move_to_deleted '/mnt/synology/rs-movies/Black Widow (2021)/Black Widow (2021) {imdb-tt3480822} [DSNP][WEBDL-1080p][EAC3 Atmos 5.1][h264]-CMRG.mkv' 'Black Widow (2021)'

# Blacklight (2022)
move_to_deleted '/mnt/synology/rs-movies/Blacklight (2022)/Blacklight (2022) {imdb-tt14060094} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Blacklight (2022)'

# Blackwater Lane (2024)
move_to_deleted '/mnt/synology/rs-movies/Blackwater Lane (2024)/Blackwater Lane (2024) {imdb-tt22767628} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'Blackwater Lane (2024)'

# Blade (1998)
move_to_deleted '/mnt/synology/rs-movies/Blade (1998)/Blade (1998) {imdb-tt0120611} [Bluray-1080p][DTS-ES 6.1][x264]-Z0N3.mkv' 'Blade (1998)'

# Blade Runner (1982)
move_to_deleted '/mnt/synology/rs-movies/Blade Runner (1982)/Blade Runner (1982) {imdb-tt0083658} [Bluray-1080p][AC3 5.1][x264].mkv' 'Blade Runner (1982)'

# Blade Runner 2049 (2017)
move_to_deleted '/mnt/synology/rs-movies/Blade Runner 2049 (2017)/Blade Runner 2049 (2017) {imdb-tt1856101} [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv' 'Blade Runner 2049 (2017)'

# Blink Twice (2024)
move_to_deleted '/mnt/synology/rs-movies/Blink Twice (2024)/Blink Twice (2024) {imdb-tt14858658} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Blink Twice (2024)'

# Blood Brothers Malcolm X & Muhammad Ali (2021)
move_to_deleted '/mnt/synology/rs-movies/Blood Brothers Malcolm X & Muhammad Ali (2021)/Blood Brothers Malcolm X & Muhammad Ali (2021) {imdb-tt15095938} [WEBDL-1080p][EAC3 Atmos 5.1][x264]-PECULATE.mkv' 'Blood Brothers Malcolm X & Muhammad Ali (2021)'

# Bloodshot (2020)
move_to_deleted '/mnt/synology/rs-movies/Bloodshot (2020)/Bloodshot (2020) {imdb-tt1634106} [WEBDL-1080p][EAC3 5.1][h264].mkv' 'Bloodshot (2020)'

# Blue Beetle (2023)
move_to_deleted '/mnt/synology/rs-movies/Blue Beetle (2023)/Blue Beetle (2023) {imdb-tt9362930} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Blue Beetle (2023)'

# Blue Velvet (1986)
move_to_deleted '/mnt/synology/rs-movies/Blue Velvet (1986)/Blue Velvet (1986) {imdb-tt0090756} [Bluray-1080p][AC3 5.1][x264].mkv' 'Blue Velvet (1986)'

# Blues Brothers 2000 (1998)
move_to_deleted '/mnt/synology/rs-movies/Blues Brothers 2000 (1998)/The Blues Brothers (1980) {imdb-tt0080455} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-GPRS.mkv' 'Blues Brothers 2000 (1998)'

# Bob Marley One Love (2024)
move_to_deleted '/mnt/synology/rs-movies/Bob Marley One Love (2024)/Bob Marley One Love (2024) {imdb-tt8521778} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-ETHEL.mkv' 'Bob Marley One Love (2024)'

# Bones and All (2022)
move_to_deleted '/mnt/synology/rs-movies/Bones and All (2022)/Bones and All (2022) {imdb-tt10168670} [Bluray-1080p][EAC3 Atmos 7.1][x264]-PTer.mkv' 'Bones and All (2022)'

# Boogie Nights (1997)
move_to_deleted '/mnt/synology/rs-movies/Boogie Nights (1997)/Boogie Nights (1997) {imdb-tt0118749} [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv' 'Boogie Nights (1997)'

# Borderlands (2024)
move_to_deleted '/mnt/synology/rs-movies/Borderlands (2024)/Borderlands (2024) {imdb-tt4978420} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-BreakYourKevinHart.mkv' 'Borderlands (2024)'

# Borderline (2025)
move_to_deleted '/mnt/synology/rs-movies/Borderline (2025)/Borderline (2025) {imdb-tt13650814} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'Borderline (2025)'

# Born on the Fourth of July (1989)
move_to_deleted '/mnt/synology/rs-movies/Born on the Fourth of July (1989)/Born on the Fourth of July (1989) {imdb-tt0096969} [Bluray-1080p][DTS 5.1][x264]-CRiSC.mkv' 'Born on the Fourth of July (1989)'

# The Boss Baby Family Business (2021)
move_to_deleted '/mnt/synology/rs-movies/The Boss Baby Family Business (2021)/The Boss Baby Family Business (2021) {imdb-tt6932874} [PCOK][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv' 'The Boss Baby Family Business (2021)'

# Boss Level (2020)
move_to_deleted '/mnt/synology/rs-movies/Boss Level (2020)/Boss Level (2021) {imdb-tt7638348} [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv' 'Boss Level (2020)'

# Bottoms (2023)
move_to_deleted '/mnt/synology/rs-movies/Bottoms (2023)/Bottoms (2023) {imdb-tt17527468} [WEBDL-1080p][EAC3 5.1][h264]-HUZZAH.mkv' 'Bottoms (2023)'

# The Bourne Identity (2002)
move_to_deleted '/mnt/synology/rs-movies/The Bourne Identity (2002)/The Bourne Identity (2002) {imdb-tt0258463} [Bluray-1080p][HDR10][EAC3 5.1][h265].mkv' 'The Bourne Identity (2002)'

# Boy Kills World (2024)
move_to_deleted '/mnt/synology/rs-movies/Boy Kills World (2024)/Boy Kills World (2024) {imdb-tt13923084} [WEBDL-1080p][AC3 5.1][h264]-SLOT.mkv' 'Boy Kills World (2024)'

# Boyz n the Hood (1991)
move_to_deleted '/mnt/synology/rs-movies/Boyz n the Hood (1991)/Boyz n the Hood (1991) {imdb-tt0101507} [Bluray-1080p][HDR10][EAC3 7.1][x265]-SA89.mkv' 'Boyz n the Hood (1991)'

# Braveheart (1995)
move_to_deleted '/mnt/synology/rs-movies/Braveheart (1995)/Braveheart (1995) {imdb-tt0112573} [Bluray-1080p][HDR10][AC3 5.1][x265]-DON.mkv' 'Braveheart (1995)'

# The Break-Up (2006) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/The Break-Up (2006)/The Break-Up (2006) {imdb-tt0452594} [Bluray-720p][DTS 5.1][x264].mkv' 'The Break-Up (2006)'

# Breakfast Club, The (1985)
move_to_deleted '/mnt/synology/rs-movies/Breakfast Club, The (1985)/The Breakfast Club (1985) {imdb-tt0088847} [Bluray-1080p][DTS 5.1][x264].mkv' 'Breakfast Club, The (1985)'

# Breakfast on Pluto (2005)
move_to_deleted '/mnt/synology/rs-movies/Breakfast on Pluto (2005)/Breakfast on Pluto (2005) {imdb-tt0411195} [AMZN][WEBDL-1080p][EAC3 5.1][x264]-ABM.mkv' 'Breakfast on Pluto (2005)'

# Breakwater (2023)
move_to_deleted '/mnt/synology/rs-movies/Breakwater (2023)/Breakwater (2023) {imdb-tt13924484} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Breakwater (2023)'

# Breathe (2024)
move_to_deleted '/mnt/synology/rs-movies/Breathe (2024)/Breathe (2024) {imdb-tt11540468} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-notASorSF.mkv' 'Breathe (2024)'

# Breathe In (2013) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Breathe In (2013)/Breathe In (2013) {imdb-tt1999987} [Bluray-720p][DTS 5.1][x264]-iNK.mkv' 'Breathe In (2013)'

# Bridge on the River Kwai, The (1957)
move_to_deleted '/mnt/synology/rs-movies/Bridge on the River Kwai, The (1957)/The Bridge on the River Kwai (1957) {imdb-tt0050212} [WEBDL-1080p][DTS 5.1][x264].mkv' 'Bridge on the River Kwai, The (1957)'

# Bridget Jones Mad About the Boy (2025)
move_to_deleted '/mnt/synology/rs-movies/Bridget Jones Mad About the Boy (2025)/Bridget Jones Mad About the Boy (2025) {imdb-tt32063050} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Bridget Jones Mad About the Boy (2025)'

# Bright (2017)
move_to_deleted '/mnt/synology/rs-movies/Bright (2017)/Bright (2017) {imdb-tt5519340} [HDTV-1080p][AC3 5.1][x264].mkv' 'Bright (2017)'

# Bring Her Back (2025)
move_to_deleted '/mnt/synology/rs-movies/Bring Her Back (2025)/Bring Her Back (2025) {imdb-tt32246771} [Bluray-1080p][TrueHD Atmos 7.1][h264]-RiSEHD.mkv' 'Bring Her Back (2025)'

# Bring Him to Me (2023)
move_to_deleted '/mnt/synology/rs-movies/Bring Him to Me (2023)/Bring Him to Me (2023) {imdb-tt24131660} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Bring Him to Me (2023)'

# Bring It On (2000)
move_to_deleted '/mnt/synology/rs-movies/Bring It On (2000)/Bring It On (2000) {imdb-tt0204946} [Bluray-1080p][DTS 5.1][x264]-ero.mkv' 'Bring It On (2000)'

# Brotherhood of the Wolf (2001)
move_to_deleted '/mnt/synology/rs-movies/Brotherhood of the Wolf (2001)/Brotherhood of the Wolf (2001) {imdb-tt0237534} [Bluray-1080p][DTS-HD MA 5.1][x264]-EUBDS.mkv' 'Brotherhood of the Wolf (2001)'

# Bruised (2021)
move_to_deleted '/mnt/synology/rs-movies/Bruised (2021)/Bruised (2020) {imdb-tt8310474} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-EVO.mkv' 'Bruised (2021)'

# Bubba Ho-tep (2002)
move_to_deleted '/mnt/synology/rs-movies/Bubba Ho-tep (2002)/Bubba Ho-tep (2002) {imdb-tt0281686} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv' 'Bubba Ho-tep (2002)'

# Bugonia (2025)
move_to_deleted '/mnt/synology/rs-movies/Bugonia (2025)/Bugonia (2025) {imdb-tt12300742} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Bugonia (2025)'

# Bugsy (1991)
move_to_deleted '/mnt/synology/rs-movies/Bugsy (1991)/Bugsy (1991) {imdb-tt0101516} [WEBRip-1080p][EAC3 5.1][x264]-NTb.mkv' 'Bugsy (1991)'

# Bullet Train (2022)
move_to_deleted '/mnt/synology/rs-movies/Bullet Train (2022)/Bullet Train (2022) {imdb-tt12593682} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Bullet Train (2022)'

# Bumblebee (2018)
move_to_deleted '/mnt/synology/rs-movies/Bumblebee (2018)/Bumblebee (2018) {imdb-tt4701182} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Bumblebee (2018)'

# Burn After Reading (2008)
move_to_deleted '/mnt/synology/rs-movies/Burn After Reading (2008)/Burn After Reading (2008) {imdb-tt0887883} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Burn After Reading (2008)'

# Butchers Crossing (2023)
move_to_deleted '/mnt/synology/rs-movies/Butchers Crossing (2023)/Butcher\'s Crossing (2023) {imdb-tt1462759} [WEBDL-1080p][EAC3 5.1][h264].mkv' 'Butchers Crossing (2023)'

# CODA (2021)
move_to_deleted '/mnt/synology/rs-movies/CODA (2021)/CODA (2021) {imdb-tt10366460} [ATVP][WEBDL-1080p][HDR10][EAC3 Atmos 5.1][h265]-FLUX.mkv' 'CODA (2021)'

# Caligula (1979)
move_to_deleted '/mnt/synology/rs-movies/Caligula (1979)/Caligula (1979) {imdb-tt0080491} [Bluray-1080p][AC3 5.0][x264]-BHDStudio.mp4' 'Caligula (1979)'

# The Call of the Wild (2020)
move_to_deleted '/mnt/synology/rs-movies/The Call of the Wild (2020)/The Call of the Wild (2020) {imdb-tt7504726} [WEBDL-1080p][AC3 5.1][x264].mkv' 'The Call of the Wild (2020)'

# A Call to Spy (2020)
move_to_deleted '/mnt/synology/rs-movies/A Call to Spy (2020)/A Call to Spy (2020) {imdb-tt7698468} [WEBDL-1080p][AC3 5.1][h264].mkv' 'A Call to Spy (2020)'

# Can\'t Hardly Wait (1998)
move_to_deleted '/mnt/synology/rs-movies/Can\'t Hardly Wait (1998)/Can\'t Hardly Wait (1998) {imdb-tt0127723} [Bluray-1080p Proper][EAC3 5.1][x264]-playHD.mkv' 'Can\'t Hardly Wait (1998)'

# Canary Black (2024)
move_to_deleted '/mnt/synology/rs-movies/Canary Black (2024)/Canary Black (2024) {imdb-tt20048582} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Canary Black (2024)'

# Captain America Civil War (2016)
move_to_deleted '/mnt/synology/rs-movies/Captain America Civil War (2016)/Captain America Civil War (2016) {imdb-tt3498820} [Bluray-1080p][HDR10][EAC3 7.1][x265]-NCmt.mkv' 'Captain America Civil War (2016)'

# Captain Marvel (2019)
move_to_deleted '/mnt/synology/rs-movies/Captain Marvel (2019)/Captain Marvel (2019) {imdb-tt4154664} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Captain Marvel (2019)'

# Carls Date (2023)
move_to_deleted '/mnt/synology/rs-movies/Carls Date (2023)/Carl\'s Date (2023) {imdb-tt26736061} [DSNP][WEBDL-1080p][EAC3 Atmos 5.1][h264]-AirForceOne.mkv' 'Carls Date (2023)'

# Carrie (1976)
move_to_deleted '/mnt/synology/rs-movies/Carrie (1976)/Carrie (1976) {imdb-tt0074285} [Bluray-1080p][DTS 5.1][x264]-AMIABLE.mkv' 'Carrie (1976)'

# Casablanca (1942)
move_to_deleted '/mnt/synology/rs-movies/Casablanca (1942)/Casablanca (1943) {imdb-tt0034583} [Bluray-1080p][HDR10][FLAC 1.0][x265]-c0kE.mkv' 'Casablanca (1942)'

# Cash Out (2024)
move_to_deleted '/mnt/synology/rs-movies/Cash Out (2024)/Cash Out (2024) {imdb-tt24131288} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'Cash Out (2024)'

# Casino (1995)
move_to_deleted '/mnt/synology/rs-movies/Casino (1995)/Casino (1995) {imdb-tt0112641} [Bluray-1080p][HDR10][EAC3 7.1][x265]-TDD.mkv' 'Casino (1995)'

# Casino Royale (2006)
move_to_deleted '/mnt/synology/rs-movies/Casino Royale (2006)/Casino Royale (2006) {imdb-tt0381061} [Bluray-1080p][DTS 5.1][x264].mkv' 'Casino Royale (2006)'

# Casper (1995)
move_to_deleted '/mnt/synology/rs-movies/Casper (1995)/Casper (1995) {imdb-tt0112642} [Remux-1080p][DTS-HD MA 5.1][AVC]-ShocK.mkv' 'Casper (1995)'

# Catch .44 (2011)
move_to_deleted '/mnt/synology/rs-movies/Catch .44 (2011)/Catch.44 (2011) {imdb-tt1886493} [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv' 'Catch .44 (2011)'

# Catch Me If You Can (2002)
move_to_deleted '/mnt/synology/rs-movies/Catch Me If You Can (2002)/Catch Me If You Can (2002) {imdb-tt0264464} [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv' 'Catch Me If You Can (2002)'

# Cathedral, The (2021) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Cathedral, The (2021)/The Cathedral (2022) {imdb-tt13658076} [WEBDL-1080p][AAC 2.0][x264]-KUCHU.mkv' 'Cathedral, The (2021)'

# Caught Stealing (2025)
move_to_deleted '/mnt/synology/rs-movies/Caught Stealing (2025)/Caught Stealing (2025) {imdb-tt1493274} [WEBRip-1080p][EAC3 Atmos 5.1][x264]-HiDt.mkv' 'Caught Stealing (2025)'

# Central Intelligence (2016)
move_to_deleted '/mnt/synology/rs-movies/Central Intelligence (2016)/Central Intelligence (2016) {imdb-tt1489889} [HDTV-1080p][AC3 2.0][h264].mkv' 'Central Intelligence (2016)'

# Challengers (2024)
move_to_deleted '/mnt/synology/rs-movies/Challengers (2024)/Challengers (2024) {imdb-tt16426418} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Challengers (2024)'

# Chameleon Street (1991)
move_to_deleted '/mnt/synology/rs-movies/Chameleon Street (1991)/Chameleon Street (1989) {imdb-tt0101561} [WEBDL-1080p][AAC 2.0][x264]-KUCHU.mkv' 'Chameleon Street (1991)'

# Champions (2023)
move_to_deleted '/mnt/synology/rs-movies/Champions (2023)/Champions (2023) {imdb-tt15339570} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Champions (2023)'

# Changeland (2019)
move_to_deleted '/mnt/synology/rs-movies/Changeland (2019)/Changeland (2019) {imdb-tt6612946} [WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv' 'Changeland (2019)'

# Charlie Brown Christmas, A (1965)
move_to_deleted '/mnt/synology/rs-movies/Charlie Brown Christmas, A (1965)/A Charlie Brown Christmas (1965) {imdb-tt0059026} [Bluray-1080p][HDR10][AC3 5.1][x265]-D-Z0N3.mkv' 'Charlie Brown Christmas, A (1965)'

# Charlie\'s Angels (2000)
move_to_deleted '/mnt/synology/rs-movies/Charlie\'s Angels (2000)/Charlie\'s Angels (2000) {imdb-tt0160127} [Bluray-1080p][DTS 5.1][x264]-SbR.mkv' 'Charlie\'s Angels (2000)'

# Charlie\'s Angels (2019)
move_to_deleted '/mnt/synology/rs-movies/Charlie\'s Angels (2019)/Charlie\'s Angels (2019) {imdb-tt5033998} [WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv' 'Charlie\'s Angels (2019)'

# Chicken Run Dawn of the Nugget (2023)
move_to_deleted '/mnt/synology/rs-movies/Chicken Run Dawn of the Nugget (2023)/Chicken Run Dawn of the Nugget (2023) {imdb-tt8337264} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Chicken Run Dawn of the Nugget (2023)'

# Child\'s Play (1988)
move_to_deleted '/mnt/synology/rs-movies/Child\'s Play (1988)/Child\'s Play (1988) {imdb-tt0094862} [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv' 'Child\'s Play (1988)'

# Child\'s Play 2 (1990)
move_to_deleted '/mnt/synology/rs-movies/Child\'s Play 2 (1990)/Child\'s Play 2 (1990) {imdb-tt0099253} [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv' 'Child\'s Play 2 (1990)'

# Child\'s Play 3 (1991)
move_to_deleted '/mnt/synology/rs-movies/Child\'s Play 3 (1991)/Child\'s Play 3 (1991) {imdb-tt0103956} [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv' 'Child\'s Play 3 (1991)'

# Chinatown (1974)
move_to_deleted '/mnt/synology/rs-movies/Chinatown (1974)/Chinatown (1974) {imdb-tt0071315} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv' 'Chinatown (1974)'

# Christmas is Cancelled (2021)
move_to_deleted '/mnt/synology/rs-movies/Christmas is Cancelled (2021)/Christmas Is Canceled (2021) {imdb-tt15186426} [WEBDL-1080p][EAC3 5.1][h264]-RUMOUR.mkv' 'Christmas is Cancelled (2021)'

# Chupa (2023)
move_to_deleted '/mnt/synology/rs-movies/Chupa (2023)/Chupa (2023) {imdb-tt14923260} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv' 'Chupa (2023)'

# Cinderella (1950)
move_to_deleted '/mnt/synology/rs-movies/Cinderella (1950)/Cinderella (1950) {imdb-tt0042332} [HDTV-1080p][DTS 5.1][x264].mkv' 'Cinderella (1950)'

# Cinderella (2021)
move_to_deleted '/mnt/synology/rs-movies/Cinderella (2021)/Cinderella (2021) {imdb-tt10155932} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv' 'Cinderella (2021)'

# Cinderella Man (2005)
move_to_deleted '/mnt/synology/rs-movies/Cinderella Man (2005)/Cinderella Man (2005) {imdb-tt0352248} [Remux-1080p][DTS-HD MA 5.1][VC1]-SiCFoI.mkv' 'Cinderella Man (2005)'

# Civil War (2024)
move_to_deleted '/mnt/synology/rs-movies/Civil War (2024)/Civil War (2024) {imdb-tt17279496} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Civil War (2024)'

# Clara Sola (2021)
move_to_deleted '/mnt/synology/rs-movies/Clara Sola (2021)/Clara Sola (2021) {imdb-tt12637442} [WEBDL-1080p][AAC 5.1][x264]-Kururun.mkv' 'Clara Sola (2021)'

# Clash of the Titans (2010)
move_to_deleted '/mnt/synology/rs-movies/Clash of the Titans (2010)/Clash of the Titans (2010) {imdb-tt0800320} [Bluray-1080p][AC3 5.1][x264]-EbP.mkv' 'Clash of the Titans (2010)'

# Clear and Present Danger (1994)
move_to_deleted '/mnt/synology/rs-movies/Clear and Present Danger (1994)/Clear and Present Danger (1994) {imdb-tt0109444} [Bluray-1080p][DV HDR10][EAC3 5.1][x265]-c0kE.mkv' 'Clear and Present Danger (1994)'

# Clerks III (2022)
move_to_deleted '/mnt/synology/rs-movies/Clerks III (2022)/Clerks III (2022) {imdb-tt11128440} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-SMURF.mkv' 'Clerks III (2022)'

# Cliffhanger (1993)
move_to_deleted '/mnt/synology/rs-movies/Cliffhanger (1993)/Cliffhanger (1993) {imdb-tt0106582} [Bluray-1080p][HDR10][EAC3 7.1][x265]-ACRONYM.mkv' 'Cliffhanger (1993)'

# Clockwork Orange, A (1971)
move_to_deleted '/mnt/synology/rs-movies/Clockwork Orange, A (1971)/A Clockwork Orange (1971) {imdb-tt0066921} [Bluray-1080p Proper][DTS 5.1][x264]-SADPANDA.mkv' 'Clockwork Orange, A (1971)'

# Close Encounters of the Third Kind (1977)
move_to_deleted '/mnt/synology/rs-movies/Close Encounters of the Third Kind (1977)/Close Encounters of the Third Kind (1977) {imdb-tt0075860} {edition-Director\'s Cut} [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv' 'Close Encounters of the Third Kind (1977)'

# Cloud Atlas (2012)
move_to_deleted '/mnt/synology/rs-movies/Cloud Atlas (2012)/Cloud Atlas (2012) {imdb-tt1371111} [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv' 'Cloud Atlas (2012)'

# Cloverfield Paradox, The (2018)
move_to_deleted '/mnt/synology/rs-movies/Cloverfield Paradox, The (2018)/The Cloverfield Paradox (2018) {imdb-tt2548396} [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv' 'Cloverfield Paradox, The (2018)'

# Clown in a Cornfield (2025)
move_to_deleted '/mnt/synology/rs-movies/Clown in a Cornfield (2025)/Clown in a Cornfield (2025) {imdb-tt23060698} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'Clown in a Cornfield (2025)'

# Clue The Movie (1985)
move_to_deleted '/mnt/synology/rs-movies/Clue The Movie (1985)/Clue (1985) {imdb-tt0088930} [Bluray-1080p][FLAC 2.0][x264].mkv' 'Clue The Movie (1985)'

# Cobra (1986)
move_to_deleted '/mnt/synology/rs-movies/Cobra (1986)/Cobra (1986) {imdb-tt0090859} [Bluray-1080p][DTS 5.1][x264]-CRiSC.mkv' 'Cobra (1986)'

# Cobweb (2023)
move_to_deleted '/mnt/synology/rs-movies/Cobweb (2023)/Cobweb (2023) {imdb-tt9100018} [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Cobweb (2023)'

# Cocaine Bear (2023)
move_to_deleted '/mnt/synology/rs-movies/Cocaine Bear (2023)/Cocaine Bear (2023) {imdb-tt14209916} [AMZN][WEBDL-1080p][EAC3 5.1][h264].mkv' 'Cocaine Bear (2023)'

# Code Name Banshee (2022)
move_to_deleted '/mnt/synology/rs-movies/Code Name Banshee (2022)/Code Name Banshee (2022) {imdb-tt15438542} [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv' 'Code Name Banshee (2022)'

# Color Purple, The (1985)
move_to_deleted '/mnt/synology/rs-movies/Color Purple, The (1985)/The.Color.Purple.1985.1080p.BluRay.x264-EbP.mkv' 'Color Purple, The (1985)'

# Coming 2 America (2021)
move_to_deleted '/mnt/synology/rs-movies/Coming 2 America (2021)/Coming 2 America (2021) {imdb-tt6802400} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv' 'Coming 2 America (2021)'

# Companion (2025)
move_to_deleted '/mnt/synology/rs-movies/Companion (2025)/Companion (2025) {imdb-tt26584495} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-APEX.mkv' 'Companion (2025)'

# Conan the Barbarian (1982)
move_to_deleted '/mnt/synology/rs-movies/Conan the Barbarian (1982)/Conan the Barbarian (1982) {imdb-tt0082198} [Bluray-1080p][DTS 5.1][x264].mkv' 'Conan the Barbarian (1982)'

# Conan The Barbarian (2011)
move_to_deleted '/mnt/synology/rs-movies/Conan The Barbarian (2011)/Conan the Barbarian (2011) {imdb-tt0816462} [Bluray-1080p][DV HDR10][TrueHD Atmos 7.1][x265]-LEGi0N.mkv' 'Conan The Barbarian (2011)'

# Conclave (2024)
move_to_deleted '/mnt/synology/rs-movies/Conclave (2024)/Conclave (2024) {imdb-tt20215234} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Conclave (2024)'

# Concrete Utopia (2023)
move_to_deleted '/mnt/synology/rs-movies/Concrete Utopia (2023)/Concrete Utopia (2023) {imdb-tt13086266} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-PSTX.mkv' 'Concrete Utopia (2023)'

# Congo (1995)
move_to_deleted '/mnt/synology/rs-movies/Congo (1995)/Congo (1995) {imdb-tt0112715} [Remux-1080p][DTS-HD MA 5.1][h264].mkv' 'Congo (1995)'

# Constantine (2005)
move_to_deleted '/mnt/synology/rs-movies/Constantine (2005)/Constantine (2005) {imdb-tt0360486} [Bluray-1080p][DTS 5.1][x264]-HiDt.mkv' 'Constantine (2005)'

# Copshop (2021)
move_to_deleted '/mnt/synology/rs-movies/Copshop (2021)/Copshop (2021) {imdb-tt5748448} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv' 'Copshop (2021)'

# Coraline (2009)
move_to_deleted '/mnt/synology/rs-movies/Coraline (2009)/Coraline (2009) {imdb-tt0327597} [Remux-1080p][3D][DTS-HD MA 5.1][AVC]-E.N.D.mkv' 'Coraline (2009)'

# Corpse Bride (2005)
move_to_deleted '/mnt/synology/rs-movies/Corpse Bride (2005)/Corpse Bride (2005) {imdb-tt0121164} [Remux-1080p][DTS-HD MA 5.1][VC1].mkv' 'Corpse Bride (2005)'

# Courage Under Fire (1996)
move_to_deleted '/mnt/synology/rs-movies/Courage Under Fire (1996)/Courage Under Fire (1996) {imdb-tt0115956} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Courage Under Fire (1996)'

# The Crazies (2010)
move_to_deleted '/mnt/synology/rs-movies/The Crazies (2010)/The Crazies (2010) {imdb-tt0455407} [Remux-1080p][DTS-HD MA 5.1][AVC]-FraMeSToR.mkv' 'The Crazies (2010)'

# Crazy Rich Asians (2018)
move_to_deleted '/mnt/synology/rs-movies/Crazy Rich Asians (2018)/Crazy Rich Asians (2018) {imdb-tt3104988} [Bluray-1080p][AC3 5.1][x264].mkv' 'Crazy Rich Asians (2018)'

# Creation of the Gods I Kingdom of Storms (2023)
move_to_deleted '/mnt/synology/rs-movies/Creation of the Gods I Kingdom of Storms (2023)/Creation of the Gods I Kingdom of Storms (2023) {imdb-tt6979756} [WEBDL-1080p][EAC3 2.0][h264]-AOC.mp4' 'Creation of the Gods I Kingdom of Storms (2023)'

# Creed II (2018)
move_to_deleted '/mnt/synology/rs-movies/Creed II (2018)/Creed II (2018) {imdb-tt6343314} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Creed II (2018)'

# Creed III (2023)
move_to_deleted '/mnt/synology/rs-movies/Creed III (2023)/Creed III (2023) {imdb-tt11145118} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Creed III (2023)'

# Crimes of the Future (2022)
move_to_deleted '/mnt/synology/rs-movies/Crimes of the Future (2022)/Crimes of the Future (2022) {imdb-tt14549466} [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv' 'Crimes of the Future (2022)'

# Crisis (2021)
move_to_deleted '/mnt/synology/rs-movies/Crisis (2021)/Crisis (2021) {imdb-tt9731682} [WEBDL-1080p][EAC3 5.1][h264].mkv' 'Crisis (2021)'

# The Croods A New Age (2020)
move_to_deleted '/mnt/synology/rs-movies/The Croods A New Age (2020)/The Croods A New Age (2020) {imdb-tt2850386} [WEBDL-1080p][AC3 5.1][x264].mkv' 'The Croods A New Age (2020)'

# Crossing (2024)
move_to_deleted '/mnt/synology/rs-movies/Crossing (2024)/Crossing (2024) {imdb-tt27417166} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Crossing (2024)'

# Cruella (2021)
move_to_deleted '/mnt/synology/rs-movies/Cruella (2021)/Cruella (2021) {imdb-tt3228774} [DSNP][WEBDL-1080p][EAC3 Atmos 5.1][h264]-TOMMY.mkv' 'Cruella (2021)'

# Cry Macho (2021)
move_to_deleted '/mnt/synology/rs-movies/Cry Macho (2021)/Cry Macho (2021) {imdb-tt1924245} [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv' 'Cry Macho (2021)'

# Cryptozoo (2021) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Cryptozoo (2021)/Cryptozoo (2021) {imdb-tt13622118} [Bluray-720p][AC3 5.1][x264]-PTer.mkv' 'Cryptozoo (2021)'

# Cuckoo (2024)
move_to_deleted '/mnt/synology/rs-movies/Cuckoo (2024)/Cuckoo (2024) {imdb-tt12349832} [AMZN][WEBDL-1080p Proper][EAC3 5.1][h264]-FLUX.mkv' 'Cuckoo (2024)'

# Cult Killer (2024)
move_to_deleted '/mnt/synology/rs-movies/Cult Killer (2024)/Cult Killer (2024) {imdb-tt21151212} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Cult Killer (2024)'

# DC League of Super-Pets (2022)
move_to_deleted '/mnt/synology/rs-movies/DC League of Super-Pets (2022)/DC League of Super-Pets (2022) {imdb-tt8912936} [HMAX][WEBDL-1080p][AC3 5.1][x264]-DKV.mkv' 'DC League of Super-Pets (2022)'

# Daddys Head (2024)
move_to_deleted '/mnt/synology/rs-movies/Daddys Head (2024)/Daddy\'s Head (2024) {imdb-tt26682012} [WEBDL-1080p][EAC3 5.1][h264]-SoundsDirty.mkv' 'Daddys Head (2024)'

# Damaged (2024)
move_to_deleted '/mnt/synology/rs-movies/Damaged (2024)/Damaged (2024) {imdb-tt27304026} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'Damaged (2024)'

# Dampyr (2022)
move_to_deleted '/mnt/synology/rs-movies/Dampyr (2022)/Dampyr (2022) {imdb-tt10315050} [MA][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv' 'Dampyr (2022)'

# Dangerous Animals (2025)
move_to_deleted '/mnt/synology/rs-movies/Dangerous Animals (2025)/Dangerous Animals (2025) {imdb-tt32299316} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'Dangerous Animals (2025)'

# Dangerous Waters (2023)
move_to_deleted '/mnt/synology/rs-movies/Dangerous Waters (2023)/Dangerous Waters (2023) {imdb-tt20024428} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Dangerous Waters (2023)'

# Dark City (1998)
move_to_deleted '/mnt/synology/rs-movies/Dark City (1998)/Dark City (1998) {imdb-tt0118929} [Bluray-1080p][DTS 5.1][x264]-MaG.mkv' 'Dark City (1998)'

# Dark Tower, The (2017)
move_to_deleted '/mnt/synology/rs-movies/Dark Tower, The (2017)/The Dark Tower (2017) {imdb-tt1648190} [Bluray-1080p][HDR10][EAC3 7.1][x265]-D-Z0N3.mkv' 'Dark Tower, The (2017)'

# Darkman (1990)
move_to_deleted '/mnt/synology/rs-movies/Darkman (1990)/Darkman (1990) {imdb-tt0099365} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv' 'Darkman (1990)'

# Das Boot (1981)
move_to_deleted '/mnt/synology/rs-movies/Das Boot (1981)/Das.Boot.1981.DC.1080p.BluRay.x264-CtrlHD.mkv' 'Das Boot (1981)'

# Dave Chappelle Deep in the Heart of Texas (2017)
move_to_deleted '/mnt/synology/rs-movies/Dave Chappelle Deep in the Heart of Texas (2017)/Dave Chappelle Deep in the Heart of Texas (2017) {imdb-tt6649108} [NF][WEBRip-1080p][AC3 5.1][x264]-TrollHD.mkv' 'Dave Chappelle Deep in the Heart of Texas (2017)'

# Dave Chappelle Sticks & Stones (2019)
move_to_deleted '/mnt/synology/rs-movies/Dave Chappelle Sticks & Stones (2019)/Dave Chappelle Sticks & Stones (2019) {imdb-tt10810424} [NF][WEBDL-1080p][HDR10][EAC3 Atmos 5.1][HEVC]-SKiZOiD.mkv' 'Dave Chappelle Sticks & Stones (2019)'

# Dave Chappelle The Age of Spin (2017)
move_to_deleted '/mnt/synology/rs-movies/Dave Chappelle The Age of Spin (2017)/Dave Chappelle The Age of Spin (2017) {imdb-tt6648926} [NF][WEBRip-1080p][AC3 5.1][x264]-TrollHD.mkv' 'Dave Chappelle The Age of Spin (2017)'

# Dawn of the Dead (1978)
move_to_deleted '/mnt/synology/rs-movies/Dawn of the Dead (1978)/Dawn of the Dead (1978) {imdb-tt0077402} [Bluray-1080p][EAC3 5.1][x264]-DON.mkv' 'Dawn of the Dead (1978)'

# Dawn of the Dead (2004)
move_to_deleted '/mnt/synology/rs-movies/Dawn of the Dead (2004)/Dawn of the Dead (2004) {imdb-tt0363547} {edition-Unrated} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv' 'Dawn of the Dead (2004)'

# Daybreakers (2009)
move_to_deleted '/mnt/synology/rs-movies/Daybreakers (2009)/Daybreakers (2010) {imdb-tt0433362} [Bluray-1080p][AC3 5.1][x264]-EbP.mkv' 'Daybreakers (2009)'

# Daylight (1996)
move_to_deleted '/mnt/synology/rs-movies/Daylight (1996)/Daylight (1996) {imdb-tt0116040} [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv' 'Daylight (1996)'

# Days of Thunder (1990)
move_to_deleted '/mnt/synology/rs-movies/Days of Thunder (1990)/Days of Thunder (1990) {imdb-tt0099371} [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv' 'Days of Thunder (1990)'

# Dead Again (1991)
move_to_deleted '/mnt/synology/rs-movies/Dead Again (1991)/Dead Again (1991) {imdb-tt0101669} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Dead Again (1991)'

# Dead Sea (2024)
move_to_deleted '/mnt/synology/rs-movies/Dead Sea (2024)/Dead Sea (2024) {imdb-tt11724920} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-HypStu.mkv' 'Dead Sea (2024)'

# Dead Zone, The (1983)
move_to_deleted '/mnt/synology/rs-movies/Dead Zone, The (1983)/The Dead Zone (1983) {imdb-tt0085407} [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv' 'Dead Zone, The (1983)'

# Dead of Winter (2025)
move_to_deleted '/mnt/synology/rs-movies/Dead of Winter (2025)/Dead of Winter (2025) {imdb-tt7574556} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Dead of Winter (2025)'

# Deadly Friend (1986)
move_to_deleted '/mnt/synology/rs-movies/Deadly Friend (1986)/Deadly Friend (1986) {imdb-tt0090917} [AMZN][WEBDL-1080p][EAC3 2.0][h264]-PHOENiX.mkv' 'Deadly Friend (1986)'

# Deadpool (2016)
move_to_deleted '/mnt/synology/rs-movies/Deadpool (2016)/Deadpool (2016) {imdb-tt1431045} [Bluray-1080p][DTS-ES 5.1][x264].mkv' 'Deadpool (2016)'

# Deadpool 2 (2018)
move_to_deleted '/mnt/synology/rs-movies/Deadpool 2 (2018)/Deadpool 2 (2018) {imdb-tt5463162} [Bluray-1080p][DTS-ES 5.1][x264]-HDChina.mkv' 'Deadpool 2 (2018)'

# Deadwood The Movie (2019)
move_to_deleted '/mnt/synology/rs-movies/Deadwood The Movie (2019)/Deadwood The Movie (2019) {imdb-tt4943998} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-NTb.mkv' 'Deadwood The Movie (2019)'

# Dear Evan Hansen (2021)
move_to_deleted '/mnt/synology/rs-movies/Dear Evan Hansen (2021)/Dear Evan Hansen (2021) {imdb-tt9357050} [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv' 'Dear Evan Hansen (2021)'

# Dear John (2010) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Dear John (2010)/Dear John (2010) {imdb-tt0989757} [Bluray-720p][DTS 5.1][x264].mkv' 'Dear John (2010)'

# Death Wish (2018)
move_to_deleted '/mnt/synology/rs-movies/Death Wish (2018)/Death Wish (2018) {imdb-tt1137450} [Bluray-1080p][DTS 5.1][x264]-uRaMeSHi.mkv' 'Death Wish (2018)'

# Death and Return of Superman, The (2019)
move_to_deleted '/mnt/synology/rs-movies/Death and Return of Superman, The (2019)/Death.And.Return.Of.Superman.2019.Multi.Complete.Bluray-Itwasntme.mkv' 'Death and Return of Superman, The (2019)'

# Death to Smoochy (2002)
move_to_deleted '/mnt/synology/rs-movies/Death to Smoochy (2002)/Death to Smoochy (2002) {imdb-tt0266452} [Bluray-1080p][EAC3 5.1][x264]-MaG.mkv' 'Death to Smoochy (2002)'

# Deep Blue Sea (1999)
move_to_deleted '/mnt/synology/rs-movies/Deep Blue Sea (1999)/Deep Blue Sea (1999) {imdb-tt0149261} [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv' 'Deep Blue Sea (1999)'

# Deep Impact (1998)
move_to_deleted '/mnt/synology/rs-movies/Deep Impact (1998)/Deep Impact (1998) {imdb-tt0120647} [WEBDL-1080p][DTS 5.1][h264].mkv' 'Deep Impact (1998)'

# Deepwater Horizon (2016)
move_to_deleted '/mnt/synology/rs-movies/Deepwater Horizon (2016)/Deepwater Horizon (2016) {imdb-tt1860357} [Bluray-1080p][HDR10][EAC3 7.1][x265]-DON.mkv' 'Deepwater Horizon (2016)'

# Deer Hunter, The (1978)
move_to_deleted '/mnt/synology/rs-movies/Deer Hunter, The (1978)/The Deer Hunter (1978) {imdb-tt0077416} [Bluray-1080p][DTS 5.1][x264]-PbK.mkv' 'Deer Hunter, The (1978)'

# Delicatessen (1991)
move_to_deleted '/mnt/synology/rs-movies/Delicatessen (1991)/Delicatessen (1991) {imdb-tt0101700} [Bluray-1080p][FLAC 2.0][x264]-Skazhutin.mkv' 'Delicatessen (1991)'

# Den of Thieves (2018)
move_to_deleted '/mnt/synology/rs-movies/Den of Thieves (2018)/Den of Thieves (2018) {imdb-tt1259528} {edition-Unrated} [Bluray-1080p][DTS 5.1][x264]-DON.mkv' 'Den of Thieves (2018)'

# Den of Thieves 2 Pantera (2025)
move_to_deleted '/mnt/synology/rs-movies/Den of Thieves 2 Pantera (2025)/Den of Thieves 2 Pantera (2025) {imdb-tt8008948} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-APEX.mkv' 'Den of Thieves 2 Pantera (2025)'

# Desperation Road (2023)
move_to_deleted '/mnt/synology/rs-movies/Desperation Road (2023)/Desperation Road (2023) {imdb-tt14633464} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Desperation Road (2023)'

# Despicable Me 4 (2024)
move_to_deleted '/mnt/synology/rs-movies/Despicable Me 4 (2024)/Despicable Me 4 (2024) {imdb-tt7510222} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Despicable Me 4 (2024)'

# Detained (2024)
move_to_deleted '/mnt/synology/rs-movies/Detained (2024)/Detained (2024) {imdb-tt8178762} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Detained (2024)'

# Devotion (2022)
move_to_deleted '/mnt/synology/rs-movies/Devotion (2022)/Devotion (2022) {imdb-tt7693316} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-CMRG.mkv' 'Devotion (2022)'

# Diamonds Are Forever (1971)
move_to_deleted '/mnt/synology/rs-movies/Diamonds Are Forever (1971)/Diamonds Are Forever (1971) {imdb-tt0066995} [Bluray-1080p][DTS 5.1][x264].mkv' 'Diamonds Are Forever (1971)'

# Diego Maradona (2019)
move_to_deleted '/mnt/synology/rs-movies/Diego Maradona (2019)/Diego Maradona (2019) {imdb-tt5433114} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv' 'Diego Maradona (2019)'

# Dig, The (2021)
move_to_deleted '/mnt/synology/rs-movies/Dig, The (2021)/The Dig (2021) {imdb-tt3661210} [WEBDL-1080p][EAC3 Atmos 5.1][x264]-MZABI.mkv' 'Dig, The (2021)'

# Dirty Angels (2024)
move_to_deleted '/mnt/synology/rs-movies/Dirty Angels (2024)/Dirty Angels (2024) {imdb-tt23872640} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Dirty Angels (2024)'

# Dirty Dancing (1987)
move_to_deleted '/mnt/synology/rs-movies/Dirty Dancing (1987)/Dirty Dancing (1987) {imdb-tt0092890} [Bluray-1080p][DTS 5.1][x264].mkv' 'Dirty Dancing (1987)'

# Dirty Harry (1971)
move_to_deleted '/mnt/synology/rs-movies/Dirty Harry (1971)/Dirty Harry (1971) {imdb-tt0066999} [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv' 'Dirty Harry (1971)'

# Divergent Series Allegiant, The (2016) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Divergent Series Allegiant, The (2016)/Allegiant (2016) {imdb-tt3410834} [Bluray-720p][AC3 5.1][x264].mkv' 'Divergent Series Allegiant, The (2016)'

# Doctor Sleep (2019)
move_to_deleted '/mnt/synology/rs-movies/Doctor Sleep (2019)/Doctor Sleep (2019) {imdb-tt5606664} [WEBDL-1080p][AC3 5.1][x264].mkv' 'Doctor Sleep (2019)'

# Doctor Strange in the Multiverse of Madness (2022)
move_to_deleted '/mnt/synology/rs-movies/Doctor Strange in the Multiverse of Madness (2022)/Doctor Strange in the Multiverse of Madness (2022) {imdb-tt9419884} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-EVO.mkv' 'Doctor Strange in the Multiverse of Madness (2022)'

# Dog (2022)
move_to_deleted '/mnt/synology/rs-movies/Dog (2022)/Dog (2022) {imdb-tt11252248} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv' 'Dog (2022)'

# Dog Man (2025)
move_to_deleted '/mnt/synology/rs-movies/Dog Man (2025)/Dog Man (2025) {imdb-tt10954718} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-APEX.mkv' 'Dog Man (2025)'

# Dolemite Is My Name (2019)
move_to_deleted '/mnt/synology/rs-movies/Dolemite Is My Name (2019)/Dolemite Is My Name (2019) {imdb-tt8526872} [WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTG.mkv' 'Dolemite Is My Name (2019)'

# Don\'t Breathe (2016) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Don\'t Breathe (2016)/Don\'t Breathe (2016) {imdb-tt4160708} [Bluray-720p][DTS 5.1][x264]-UnKn0wn.mkv' 'Don\'t Breathe (2016)'

# Don\'t Look Up (2021)
move_to_deleted '/mnt/synology/rs-movies/Don\'t Look Up (2021)/Don\'t Look Up (2021) {imdb-tt11286314} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-EVO.mkv' 'Don\'t Look Up (2021)'

# Don\'t Worry Darling (2022)
move_to_deleted '/mnt/synology/rs-movies/Don\'t Worry Darling (2022)/Don\'t Worry Darling (2022) {imdb-tt10731256} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-CMRG.mkv' 'Don\'t Worry Darling (2022)'

# Donovan\'s Reef (1963)
move_to_deleted '/mnt/synology/rs-movies/Donovan\'s Reef (1963)/Donovan\'s Reef (1963) {imdb-tt0057007} [WEBRip-1080p][EAC3 2.0][x264].mkv' 'Donovan\'s Reef (1963)'

# Dora and the Lost City of Gold (2019)
move_to_deleted '/mnt/synology/rs-movies/Dora and the Lost City of Gold (2019)/Dora and the Lost City of Gold (2019) {imdb-tt7547410} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Dora and the Lost City of Gold (2019)'

# Downton Abbey The Grand Finale (2025)
move_to_deleted '/mnt/synology/rs-movies/Downton Abbey The Grand Finale (2025)/Downton Abbey The Grand Finale (2025) {imdb-tt31888477} - [WEBDL-1080p][EAC3 Atmos 5.1][h264]-ETHEL.mkv' 'Downton Abbey The Grand Finale (2025)'

# Dr. No (1962)
move_to_deleted '/mnt/synology/rs-movies/Dr. No (1962)/Dr. No (1962) {imdb-tt0055928} [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv' 'Dr. No (1962)'

# Dr. Seuss The Lorax (2012) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Dr. Seuss The Lorax (2012)/The Lorax (2012) {imdb-tt1482459} [Bluray-720p][DTS 5.1][x264].mkv' 'Dr. Seuss The Lorax (2012)'

# Dr. Strangelove or How I Learned to Stop Worrying and Love the Bomb (1964)
move_to_deleted '/mnt/synology/rs-movies/Dr. Strangelove or How I Learned to Stop Worrying and Love the Bomb (1964)/Dr. Strangelove or How I Learned to Stop Worrying and Love the Bomb (1964) {imdb-tt0057012} [Bluray-1080p][HDR10][EAC3 5.1][x265]-PTer.mkv' 'Dr. Strangelove or How I Learned to Stop Worrying and Love the Bomb (1964)'

# Dracula Untold (2014)
move_to_deleted '/mnt/synology/rs-movies/Dracula Untold (2014)/Dracula Untold (2014) {imdb-tt0829150} [Bluray-1080p][HDR10][EAC3 7.1][x265]-DON.mkv' 'Dracula Untold (2014)'

# Dragon Blade (2015) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Dragon Blade (2015)/Dragon Blade (2015) {imdb-tt3672840} [Bluray-720p][AC3 5.1][x264]-VietHD.mkv' 'Dragon Blade (2015)'

# Dream Scenario (2023)
move_to_deleted '/mnt/synology/rs-movies/Dream Scenario (2023)/Dream Scenario (2023) {imdb-tt21942866} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Dream Scenario (2023)'

# Dredd (2012)
move_to_deleted '/mnt/synology/rs-movies/Dredd (2012)/Dredd (2012) {imdb-tt1343727} [Bluray-1080p][DTS 5.1][x264].mkv' 'Dredd (2012)'

# Drive-Away Dolls (2024)
move_to_deleted '/mnt/synology/rs-movies/Drive-Away Dolls (2024)/Drive-Away Dolls (2024) {imdb-tt19356262} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-ShowMeOnTheDollWhereHeTouchedYou.mkv' 'Drive-Away Dolls (2024)'

# DuckTales The Movie Treasure of the Lost Lamp (1990)
move_to_deleted '/mnt/synology/rs-movies/DuckTales The Movie Treasure of the Lost Lamp (1990)/DuckTales The Movie - Treasure of the Lost Lamp (1990) {imdb-tt0099472} [WEBDL-1080p][AAC 2.0][h264].mkv' 'DuckTales The Movie Treasure of the Lost Lamp (1990)'

# Dumb Money (2023)
move_to_deleted '/mnt/synology/rs-movies/Dumb Money (2023)/Dumb Money (2023) {imdb-tt13957560} [MA][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv' 'Dumb Money (2023)'

# Dumb and Dumber (1994)
move_to_deleted '/mnt/synology/rs-movies/Dumb and Dumber (1994)/Dumb and Dumber (1994) {imdb-tt0109686} {edition-Theatrical Cut} [AMZN][WEBDL-1080p][EAC3 2.0][x264]-KADENZZA.mkv' 'Dumb and Dumber (1994)'

# Dune (2021)
move_to_deleted '/mnt/synology/rs-movies/Dune (2021)/Dune (2021) {imdb-tt1160419} [WEBRip-1080p][AC3 5.1][x264]-SHITBOX.mkv' 'Dune (2021)'

# Dunkirk (2017)
move_to_deleted '/mnt/synology/rs-movies/Dunkirk (2017)/Dunkirk (2017) {imdb-tt5013056} [Bluray-1080p][DTS-HD MA 5.1][x264].mkv' 'Dunkirk (2017)'

# Early Man (2018)
move_to_deleted '/mnt/synology/rs-movies/Early Man (2018)/Early Man (2018) {imdb-tt4701724} [Bluray-1080p][AC3 5.1][x264].mkv' 'Early Man (2018)'

# Earth One Amazing Day (2017)
move_to_deleted '/mnt/synology/rs-movies/Earth One Amazing Day (2017)/Earth One Amazing Day (2017) {imdb-tt6238896} [Bluray-1080p][HDR10][EAC3 7.1][x265]-DON.mkv' 'Earth One Amazing Day (2017)'

# Eden (2025)
move_to_deleted '/mnt/synology/rs-movies/Eden (2025)/Eden (2025) {imdb-tt23149780} [WEBDL-1080p][EAC3 5.1][h264]-MGE.mkv' 'Eden (2025)'

# Edge of Tomorrow (2014)
move_to_deleted '/mnt/synology/rs-movies/Edge of Tomorrow (2014)/Edge of Tomorrow (2014) {imdb-tt1631867} [Bluray-1080p][DTS 5.1][x264].mkv' 'Edge of Tomorrow (2014)'

# Edge of the World (2021)
move_to_deleted '/mnt/synology/rs-movies/Edge of the World (2021)/Edge of the World (2021) {imdb-tt3006472} [AMZN][WEBDL-1080p][EAC3 2.0][h264]-CMRG.mkv' 'Edge of the World (2021)'

# Edward Scissorhands (1990)
move_to_deleted '/mnt/synology/rs-movies/Edward Scissorhands (1990)/Edward Scissorhands (1990) {imdb-tt0099487} [Bluray-1080p][DTS 4.0][x264]-CtrlHD.mkv' 'Edward Scissorhands (1990)'

# El Camino A Breaking Bad Movie (2019)
move_to_deleted '/mnt/synology/rs-movies/El Camino A Breaking Bad Movie (2019)/El Camino A Breaking Bad Movie (2019) {imdb-tt9243946} [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv' 'El Camino A Breaking Bad Movie (2019)'

# El Dorado (1966) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/El Dorado (1966)/El Dorado (1966) {imdb-tt0061619} [WEBDL-720p][AC3 2.0][x264].mkv' 'El Dorado (1966)'

# Elemental (2023)
move_to_deleted '/mnt/synology/rs-movies/Elemental (2023)/Elemental (2023) {imdb-tt15789038} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Elemental (2023)'

# Elevation (2024)
move_to_deleted '/mnt/synology/rs-movies/Elevation (2024)/Elevation (2024) {imdb-tt23558280} [WEBDL-1080p][AC3 5.1][h264]-ETHEL.mkv' 'Elevation (2024)'

# Elf (2003)
move_to_deleted '/mnt/synology/rs-movies/Elf (2003)/Elf (2003) {imdb-tt0319343} [Bluray-1080p][DTS 5.1][x264].mkv' 'Elf (2003)'

# Elio (2025)
move_to_deleted '/mnt/synology/rs-movies/Elio (2025)/Elio (2025) {imdb-tt4900148} [WEBDL-1080p][AC3 5.1][h264]-ETHEL.mkv' 'Elio (2025)'

# Elvis (2022)
move_to_deleted '/mnt/synology/rs-movies/Elvis (2022)/Elvis (2022) {imdb-tt3704428} [WEBDL-1080p][AC3 5.1][x264]-EVO.mkv' 'Elvis (2022)'

# Emoji Movie, The (2017) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Emoji Movie, The (2017)/The Emoji Movie (2017) {imdb-tt4877122} [Bluray-720p][AC3 5.1][x264].mkv' 'Emoji Movie, The (2017)'

# Encanto (2021)
move_to_deleted '/mnt/synology/rs-movies/Encanto (2021)/Encanto (2021) {imdb-tt2953050} [WEBRip-1080p][EAC3 5.1][x264]-SiTiAO.mkv' 'Encanto (2021)'

# Enchanted (2007)
move_to_deleted '/mnt/synology/rs-movies/Enchanted (2007)/Enchanted (2007) {imdb-tt0461770} [Bluray-1080p Proper REAL][AC3 5.1][x264]-PHOBOS.mkv' 'Enchanted (2007)'

# End of Days (1999)
move_to_deleted '/mnt/synology/rs-movies/End of Days (1999)/End of Days (1999) {imdb-tt0146675} {edition-Open Matte} [WEBDL-1080p][DTS 5.1][AVC].mkv' 'End of Days (1999)'

# End of the Road (2022)
move_to_deleted '/mnt/synology/rs-movies/End of the Road (2022)/End of the Road (2022) {imdb-tt13655328} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-EVO.mkv' 'End of the Road (2022)'

# Ender\'s Game (2013)
move_to_deleted '/mnt/synology/rs-movies/Ender\'s Game (2013)/Ender\'s Game (2013) {imdb-tt1731141} [Bluray-1080p Proper][DTS 5.1][x264]-DON.mkv' 'Ender\'s Game (2013)'

# Enemies of the People (2009)
move_to_deleted '/mnt/synology/rs-movies/Enemies of the People (2009)/Enemies of the People (2009) {imdb-tt1568328} [WEBDL-1080p][AAC 2.0][h264]-CBFM.mkv' 'Enemies of the People (2009)'

# Enola Holmes 2 (2022)
move_to_deleted '/mnt/synology/rs-movies/Enola Holmes 2 (2022)/Enola Holmes 2 (2022) {imdb-tt14641788} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv' 'Enola Holmes 2 (2022)'

# Equalizer 2, The (2018)
move_to_deleted '/mnt/synology/rs-movies/Equalizer 2, The (2018)/The Equalizer 2 (2018) {imdb-tt3766354} [Bluray-1080p][DTS 5.1][x264]-LoRD.mkv' 'Equalizer 2, The (2018)'

# Equilibrium (2002)
move_to_deleted '/mnt/synology/rs-movies/Equilibrium (2002)/Equilibrium (2002) {imdb-tt0238380} [Bluray-1080p][AC3 2.0][x264].mkv' 'Equilibrium (2002)'

# Eraser (1996)
move_to_deleted '/mnt/synology/rs-movies/Eraser (1996)/Eraser (1996) {imdb-tt0116213} [Bluray-1080p][AC3 5.1][x264].mkv' 'Eraser (1996)'

# Erin Brockovich (2000)
move_to_deleted '/mnt/synology/rs-movies/Erin Brockovich (2000)/Erin Brockovich (2000) {imdb-tt0195685} [Bluray-1080p][DTS 5.1][x264]-LoRD.mkv' 'Erin Brockovich (2000)'

# Escape From L.A. (1996)
move_to_deleted '/mnt/synology/rs-movies/Escape From L.A. (1996)/Escape from L.A. (1996) {imdb-tt0116225} [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv' 'Escape From L.A. (1996)'

# Eternals (2021)
move_to_deleted '/mnt/synology/rs-movies/Eternals (2021)/Eternals (2021) {imdb-tt9032400} [WEBDL-1080p][EAC3 5.1][x264]-EVO.mkv' 'Eternals (2021)'

# Eurotrip (2004) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Eurotrip (2004)/EuroTrip (2004) {imdb-tt0356150} {edition-Unrated} [Bluray-720p][AC3 5.1][x264]-MANBEARPIG.mkv' 'Eurotrip (2004)'

# Everest (2015)
move_to_deleted '/mnt/synology/rs-movies/Everest (2015)/Everest (2015) {imdb-tt2719848} [Bluray-1080p][AC3 5.1][x264]-TayTO.mkv' 'Everest (2015)'

# Everything Everywhere All at Once (2022)
move_to_deleted '/mnt/synology/rs-movies/Everything Everywhere All at Once (2022)/Everything Everywhere All at Once (2022) {imdb-tt6710474} [WEBDL-1080p][EAC3 5.1][x264]-EVO.mkv' 'Everything Everywhere All at Once (2022)'

# Evil Dead (2013)
move_to_deleted '/mnt/synology/rs-movies/Evil Dead (2013)/Evil Dead (2013) {imdb-tt1288558} [Remux-1080p][DTS-HD MA 5.1][h264].mkv' 'Evil Dead (2013)'

# Evil Dead II (1987)
move_to_deleted '/mnt/synology/rs-movies/Evil Dead II (1987)/Evil Dead II (1987) {imdb-tt0092991} {edition-Remastered} [Bluray-1080p][DTS-HD MA 5.1][x264]-MgB.mkv' 'Evil Dead II (1987)'

# Evil Dead Rise (2023)
move_to_deleted '/mnt/synology/rs-movies/Evil Dead Rise (2023)/Evil Dead Rise (2023) {imdb-tt13345606} [WEBRip-1080p][EAC3 7.1][x264]-HiDt.mkv' 'Evil Dead Rise (2023)'

# Ex Machina (2015)
move_to_deleted '/mnt/synology/rs-movies/Ex Machina (2015)/Ex Machina (2015) {imdb-tt0470752} [Bluray-1080p][DTS 5.1][x264].mkv' 'Ex Machina (2015)'

# Excalibur (1981)
move_to_deleted '/mnt/synology/rs-movies/Excalibur (1981)/Excalibur (1981) {imdb-tt0082348} [Bluray-1080p][DTS 5.1][x264].mkv' 'Excalibur (1981)'

# Exodus Gods and Kings (2014)
move_to_deleted '/mnt/synology/rs-movies/Exodus Gods and Kings (2014)/Exodus Gods and Kings (2014) {imdb-tt1528100} [Bluray-1080p][HDR10][EAC3 7.1][x265]-DON.mkv' 'Exodus Gods and Kings (2014)'

# Extraction (2020)
move_to_deleted '/mnt/synology/rs-movies/Extraction (2020)/Extraction (2020) {imdb-tt8936646} [WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTG.mkv' 'Extraction (2020)'

# Extraction 2 (2023)
move_to_deleted '/mnt/synology/rs-movies/Extraction 2 (2023)/Extraction 2 (2023) {imdb-tt12263384} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Extraction 2 (2023)'

# Fabelmans, The (2022)
move_to_deleted '/mnt/synology/rs-movies/Fabelmans, The (2022)/The Fabelmans (2022) {imdb-tt14208870} [MA][WEBDL-1080p][EAC3 7.1][x264]-FLUX.mkv' 'Fabelmans, The (2022)'

# Fall (2022)
move_to_deleted '/mnt/synology/rs-movies/Fall (2022)/Fall (2022) {imdb-tt15325794} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Fall (2022)'

# Fall, The (2006)
move_to_deleted '/mnt/synology/rs-movies/Fall, The (2006)/Before the Fall (2004) {imdb-tt0384369} [Bluray-1080p][DTS 5.1][x264]-iLL.mkv' 'Fall, The (2006)'

# Falling for Christmas (2022)
move_to_deleted '/mnt/synology/rs-movies/Falling for Christmas (2022)/Falling for Christmas (2022) {imdb-tt14715170} [WEBRip-1080p][AAC 5.1][x264]-LAMA.mp4' 'Falling for Christmas (2022)'

# Fantastic Beasts The Crimes of Grindelwald (2018)
move_to_deleted '/mnt/synology/rs-movies/Fantastic Beasts The Crimes of Grindelwald (2018)/Fantastic Beasts The Crimes of Grindelwald (2018) {imdb-tt4123430} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Fantastic Beasts The Crimes of Grindelwald (2018)'

# Fantastic Beasts The Secrets of Dumbledore (2022)
move_to_deleted '/mnt/synology/rs-movies/Fantastic Beasts The Secrets of Dumbledore (2022)/Fantastic Beasts The Secrets of Dumbledore (2022) {imdb-tt4123432} [WEBDL-1080p][EAC3 Atmos 5.1][x264]-SMURF.mkv' 'Fantastic Beasts The Secrets of Dumbledore (2022)'

# Fantastic Four ()
move_to_deleted '/mnt/synology/rs-movies/#recycle/Fantastic Four ()/The Fantastic 4 First Steps (2025) {imdb-tt10676052} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-BYNDR.mkv' 'Fantastic Four ()'

# Fantastic Four (2015)
move_to_deleted '/mnt/synology/rs-movies/Fantastic Four (2015)/Fantastic Four (2015) {imdb-tt1502712} [Bluray-1080p][DTS-ES 5.1][x264]-NCmt.mkv' 'Fantastic Four (2015)'

# Fast & Furious Presents Hobbs & Shaw (2019)
move_to_deleted '/mnt/synology/rs-movies/Fast & Furious Presents Hobbs & Shaw (2019)/Fast & Furious Presents Hobbs & Shaw (2019) {imdb-tt6806448} [WEBDL-1080p][AC3 2.0][h264].mkv' 'Fast & Furious Presents Hobbs & Shaw (2019)'

# Fast Five (2011)
move_to_deleted '/mnt/synology/rs-movies/Fast Five (2011)/Fast Five (2011) {imdb-tt1596343} {edition-Extended} [Bluray-1080p][DTS 5.1][x264]-DON.mkv' 'Fast Five (2011)'

# Fatale (2020)
move_to_deleted '/mnt/synology/rs-movies/Fatale (2020)/Fatale (2020) {imdb-tt8829830} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Fatale (2020)'

# Fatherhood (2021)
move_to_deleted '/mnt/synology/rs-movies/Fatherhood (2021)/Fatherhood (2021) {imdb-tt4733624} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-EVO.mkv' 'Fatherhood (2021)'

# Fear Below (2025) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Fear Below (2025)/Fear Below (2025) {imdb-tt13098590} [Bluray-720p][AC3 5.1][x264]-JustWatch.mkv' 'Fear Below (2025)'

# Fear Street Part One 1994 (2021)
move_to_deleted '/mnt/synology/rs-movies/Fear Street Part One 1994 (2021)/Fear Street 1994 (2021) {imdb-tt6566576} [NF][WEBDL-1080p][HDR10][EAC3 Atmos 5.1][HEVC]-CMRG.mkv' 'Fear Street Part One 1994 (2021)'

# Fear the Night (2023)
move_to_deleted '/mnt/synology/rs-movies/Fear the Night (2023)/Fear the Night (2023) {imdb-tt19848268} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FGRADE.mkv' 'Fear the Night (2023)'

# Fearless (2020)
move_to_deleted '/mnt/synology/rs-movies/Fearless (2020)/Fearless (2020) {imdb-tt8675288} [WEBDL-1080p][EAC3 5.1][x264].mkv' 'Fearless (2020)'

# Femme fatale (2002)
move_to_deleted '/mnt/synology/rs-movies/Femme fatale (2002)/Femme Fatale (2002) {imdb-tt0280665} [WEBDL-1080p][EAC3 2.0][h264].mkv' 'Femme fatale (2002)'

# Ferdinand (2017)
move_to_deleted '/mnt/synology/rs-movies/Ferdinand (2017)/Ferdinand (2017) {imdb-tt3411444} [Bluray-1080p][HDR10][EAC3 7.1][x265]-HQMUX.mkv' 'Ferdinand (2017)'

# Ferrari (2023)
move_to_deleted '/mnt/synology/rs-movies/Ferrari (2023)/Ferrari (2023) {imdb-tt3758542} [AMZN][WEBDL-1080p Proper][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Ferrari (2023)'

# Field of Dreams (1989)
move_to_deleted '/mnt/synology/rs-movies/Field of Dreams (1989)/Field of Dreams (1989) {imdb-tt0097351} [Hybrid][Remux-1080p][DTS-X 7.1][AVC]-decibeL.mkv' 'Field of Dreams (1989)'

# Finch (2021)
move_to_deleted '/mnt/synology/rs-movies/Finch (2021)/Finch (2021) {imdb-tt3420504} [ATVP][WEBDL-1080p][EAC3 Atmos 5.1][h264]-TEPES.mkv' 'Finch (2021)'

# Firestarter (2022)
move_to_deleted '/mnt/synology/rs-movies/Firestarter (2022)/Firestarter (2022) {imdb-tt1798632} [WEBDL-1080p][EAC3 5.1][x264]-EVO.mkv' 'Firestarter (2022)'

# Firm, The (1993)
move_to_deleted '/mnt/synology/rs-movies/Firm, The (1993)/The Firm (1993) {imdb-tt0106918} [Bluray-1080p][AC3 5.1][x264]-RDK123.mkv' 'Firm, The (1993)'

# First Purge, The (2018)
move_to_deleted '/mnt/synology/rs-movies/First Purge, The (2018)/The First Purge (2018) {imdb-tt6133466} [Bluray-1080p][HDR10][EAC3 Atmos 7.1][x265]-CtrlHD.mkv' 'First Purge, The (2018)'

# Five Nights at Freddy\'s (2023)
move_to_deleted '/mnt/synology/rs-movies/Five Nights at Freddy\'s (2023)/Five Nights at Freddy\'s (2023) {imdb-tt4589218} [PCOK][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv' 'Five Nights at Freddy\'s (2023)'

# Flash Point (2007)
move_to_deleted '/mnt/synology/rs-movies/Flash Point (2007)/Flash Point (2007) {imdb-tt0992911} [Bluray-1080p][DTS-ES 5.1][x264]-aBD.mkv' 'Flash Point (2007)'

# The Flash (2022)
move_to_deleted '/mnt/synology/rs-movies/The Flash (2022)/The Flash (2023) {imdb-tt0439572} [WEBDL-1080p][EAC3 5.1][x264]-RiGHTNOW.mkv' 'The Flash (2022)'

# Flow (2024)
move_to_deleted '/mnt/synology/rs-movies/Flow (2024)/Flow (2024) {imdb-tt4772188} [WEBRip-1080p][AAC 2.0][x264]-Taru.mkv' 'Flow (2024)'

# Flubber (1997)
move_to_deleted '/mnt/synology/rs-movies/Flubber (1997)/Flubber (1997) {imdb-tt0119137} [WEBRip-1080p][EAC3 5.1][x264]-NTb.mkv' 'Flubber (1997)'

# For a Few Dollars More (1965)
move_to_deleted '/mnt/synology/rs-movies/For a Few Dollars More (1965)/For a Few Dollars More (1965) {imdb-tt0059578} {edition-Uncut} [Bluray-1080p][FLAC 2.0][x264]-DON.mkv' 'For a Few Dollars More (1965)'

# Forrest Gump (1994)
move_to_deleted '/mnt/synology/rs-movies/Forrest Gump (1994)/Forrest Gump (1994) {imdb-tt0109830} [WEBDL-1080p][HDR10][DTS-ES 6.1][x265]-D-Z0N3.mkv' 'Forrest Gump (1994)'

# Four Christmases (2008) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Four Christmases (2008)/Four Christmases (2008) {imdb-tt0369436} [Bluray-720p][AAC 5.1][x264].mp4' 'Four Christmases (2008)'

# Frank and Penelope (2022)
move_to_deleted '/mnt/synology/rs-movies/Frank and Penelope (2022)/Frank and Penelope (2022) {imdb-tt4459134} [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv' 'Frank and Penelope (2022)'

# Frankenstein (1994)
move_to_deleted '/mnt/synology/rs-movies/Frankenstein (1994)/Mary Shelley\'s Frankenstein (1994) {imdb-tt0109836} [Bluray-1080p][AC3 5.1][x264].mkv' 'Frankenstein (1994)'

# Frankenweenie (2012)
move_to_deleted '/mnt/synology/rs-movies/Frankenweenie (2012)/Frankenweenie (2012) {imdb-tt1142977} [HDTV-1080p][DTS 5.1][x264].mkv' 'Frankenweenie (2012)'

# Freakier Friday (2025)
move_to_deleted '/mnt/synology/rs-movies/Freakier Friday (2025)/Freakier Friday (2025) {imdb-tt31956415} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-ETHEL.mkv' 'Freakier Friday (2025)'

# Freaky (2020)
move_to_deleted '/mnt/synology/rs-movies/Freaky (2020)/Freaky (2020) {imdb-tt10919380} [WEBDL-1080p][EAC3 5.1][h264].mkv' 'Freaky (2020)'

# Freddy vs. Jason (2003)
move_to_deleted '/mnt/synology/rs-movies/Freddy vs. Jason (2003)/Freddy vs. Jason (2003) {imdb-tt0329101} {edition-Open Matte} [WEBDL-1080p][EAC3 5.1][h264]-spartanec163.mkv' 'Freddy vs. Jason (2003)'

# Freddy\'s Dead The Final Nightmare (1991)
move_to_deleted '/mnt/synology/rs-movies/Freddy\'s Dead The Final Nightmare (1991)/Freddy\'s Dead The Final Nightmare (1991) {imdb-tt0101917} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Freddy\'s Dead The Final Nightmare (1991)'

# Free Solo (2018)
move_to_deleted '/mnt/synology/rs-movies/Free Solo (2018)/Free Solo (2018) {imdb-tt7775622} [Bluray-1080p][DTS-HD MA 5.1][x264]-LAE.mkv' 'Free Solo (2018)'

# Freelance (2023)
move_to_deleted '/mnt/synology/rs-movies/Freelance (2023)/Freelance (2023) {imdb-tt15744298} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Freelance (2023)'

# Friday the 13th (2009)
move_to_deleted '/mnt/synology/rs-movies/Friday the 13th (2009)/Friday the 13th (2009) {imdb-tt0758746} [Bluray-1080p][DTS 5.1][x264]-DON.mkv' 'Friday the 13th (2009)'

# Friendship (2025)
move_to_deleted '/mnt/synology/rs-movies/Friendship (2025)/Friendship (2025) {imdb-tt30505698} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'Friendship (2025)'

# From Russia With Love (1963)
move_to_deleted '/mnt/synology/rs-movies/From Russia With Love (1963)/From Russia with Love (1963) {imdb-tt0057076} [Bluray-1080p][DTS 5.1][x264].mkv' 'From Russia With Love (1963)'

# Frozen II (2019)
move_to_deleted '/mnt/synology/rs-movies/Frozen II (2019)/Frozen II (2019) {imdb-tt4520988} [Bluray-1080p][DTS 5.1][x264].mkv' 'Frozen II (2019)'

# Fury (2014)
move_to_deleted '/mnt/synology/rs-movies/Fury (2014)/Fury (2014) {imdb-tt2713180} [Bluray-1080p][DTS 5.1][x264].mkv' 'Fury (2014)'

# Galaxy Quest (1999)
move_to_deleted '/mnt/synology/rs-movies/Galaxy Quest (1999)/Galaxy Quest (1999) {imdb-tt0177789} [Bluray-1080p][DTS 5.1][x264]-FTW-HD.mkv' 'Galaxy Quest (1999)'

# Game Over, Man! (2018)
move_to_deleted '/mnt/synology/rs-movies/Game Over, Man! (2018)/Game Over, Man! (2018) {imdb-tt3317234} [WEBRip-1080p][AC3 5.1][x264]-NTb.mkv' 'Game Over, Man! (2018)'

# Gandhi (1982)
move_to_deleted '/mnt/synology/rs-movies/Gandhi (1982)/Gandhi (1982) {imdb-tt0083987} [Bluray-1080p][HDR10][EAC3 7.1][x265]-CtrlHD.mkv' 'Gandhi (1982)'

# Gasoline Alley (2022)
move_to_deleted '/mnt/synology/rs-movies/Gasoline Alley (2022)/Gasoline Alley (2022) {imdb-tt14174168} [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv' 'Gasoline Alley (2022)'

# Gemini Man (2019)
move_to_deleted '/mnt/synology/rs-movies/Gemini Man (2019)/Gemini Man (2019) {imdb-tt1025100} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Gemini Man (2019)'

# George Carlin Back in Town (1996)
move_to_deleted '/mnt/synology/rs-movies/George Carlin Back in Town (1996)/George Carlin Back in Town (1996) {imdb-tt0246641} [DVD][AC3 2.0][MPEG2]-S0NNY.mkv' 'George Carlin Back in Town (1996)'

# George Carlin Complaints & Grievances (2001)
move_to_deleted '/mnt/synology/rs-movies/George Carlin Complaints & Grievances (2001)/George Carlin Complaints & Grievances (2001) {imdb-tt0287460} [DVD][AC3 2.0][MPEG2]-S0NNY.mkv' 'George Carlin Complaints & Grievances (2001)'

# Geostorm (2017)
move_to_deleted '/mnt/synology/rs-movies/Geostorm (2017)/Geostorm (2017) {imdb-tt1981128} [WEBDL-1080p][EAC3 5.1][h264].mkv' 'Geostorm (2017)'

# Ghost in the Shell (1995) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Ghost in the Shell (1995)/Ghost in the Shell (1995) {imdb-tt0113568} [Bluray-1080p Proper REAL][AC3 2.0][x264]-MOOVEE-001.mkv' 'Ghost in the Shell (1995)'

# Ghost in the Shell (2017)
move_to_deleted '/mnt/synology/rs-movies/Ghost in the Shell (2017)/Ghost in the Shell (2017) {imdb-tt1219827} [Bluray-1080p][EAC3 5.1][x264].mkv' 'Ghost in the Shell (2017)'

# Ghostbusters (2016)
move_to_deleted '/mnt/synology/rs-movies/Ghostbusters (2016)/Ghostbusters (2016) {imdb-tt1289401} {edition-Extended} [Bluray-1080p][AC3 5.1][x264]-NTb.mkv' 'Ghostbusters (2016)'

# Ghostbusters Afterlife (2021)
move_to_deleted '/mnt/synology/rs-movies/Ghostbusters Afterlife (2021)/Ghostbusters Afterlife (2021) {imdb-tt4513678} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv' 'Ghostbusters Afterlife (2021)'

# Ghostbusters II (1989)
move_to_deleted '/mnt/synology/rs-movies/Ghostbusters II (1989)/Ghostbusters II (1989) {imdb-tt0097428} [Bluray-1080p][DTS 5.1][x264].mkv' 'Ghostbusters II (1989)'

# Girl vs. Monster (2012)
move_to_deleted '/mnt/synology/rs-movies/Girl vs. Monster (2012)/Girl vs. Monster (2012) {imdb-tt2326087} [WEBRip-1080p][AAC 2.0][x264]-QCF.mkv' 'Girl vs. Monster (2012)'

# Gladiator II (2024)
move_to_deleted '/mnt/synology/rs-movies/Gladiator II (2024)/Gladiator II (2024) {imdb-tt9218128} [WEBDL-1080p][EAC3 5.1][h264]-ETHEL.mkv' 'Gladiator II (2024)'

# Glass Onion A Knives Out Mystery (2022)
move_to_deleted '/mnt/synology/rs-movies/Glass Onion A Knives Out Mystery (2022)/Glass Onion A Knives Out Mystery (2022) {imdb-tt11564570} [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv' 'Glass Onion A Knives Out Mystery (2022)'

# Glitch in the Matrix, A (2021)
move_to_deleted '/mnt/synology/rs-movies/Glitch in the Matrix, A (2021)/A Glitch in the Matrix (2021) {imdb-tt9847360} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-TEPES.mkv' 'Glitch in the Matrix, A (2021)'

# Glory (1989)
move_to_deleted '/mnt/synology/rs-movies/Glory (1989)/Glory (1989) {imdb-tt0097441} {edition-Remastered} [4K Remaster][HDTV-1080p][FLAC 5.1][x264]-SkipTT.mkv' 'Glory (1989)'

# God Is a Bullet (2023)
move_to_deleted '/mnt/synology/rs-movies/God Is a Bullet (2023)/God Is a Bullet (2023) {imdb-tt14270702} {edition-Uncut} [WEBDL-1080p][EAC3 5.1][h264]-BobDobbs.mkv' 'God Is a Bullet (2023)'

# Godfrey Regular Black (2016) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Godfrey Regular Black (2016)/Godfrey Regular Black (2016) {imdb-tt5932662} [Hulu][WEBDL-720p][AAC 2.0][h264]-monkee.mkv' 'Godfrey Regular Black (2016)'

# Godzilla (1998)
move_to_deleted '/mnt/synology/rs-movies/Godzilla (1998)/Godzilla (1998) {imdb-tt0120685} [Bluray-1080p][DTS 5.1][x264].mkv' 'Godzilla (1998)'

# Godzilla (2014)
move_to_deleted '/mnt/synology/rs-movies/Godzilla (2014)/Godzilla (2014) {imdb-tt0831387} [Bluray-1080p][DV HDR10][EAC3 7.1][x265]-DON.mkv' 'Godzilla (2014)'

# Godzilla King of the Monsters (2019)
move_to_deleted '/mnt/synology/rs-movies/Godzilla King of the Monsters (2019)/Godzilla King of the Monsters (2019) {imdb-tt3741700} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Godzilla King of the Monsters (2019)'

# Godzilla vs. Kong (2021)
move_to_deleted '/mnt/synology/rs-movies/Godzilla vs. Kong (2021)/Godzilla vs. Kong (2021) {imdb-tt5034838} [HMAX][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv' 'Godzilla vs. Kong (2021)'

# Godzilla x Kong The New Empire (2024)
move_to_deleted '/mnt/synology/rs-movies/Godzilla x Kong The New Empire (2024)/Godzilla x Kong The New Empire (2024) {imdb-tt14539740} [AMZN][WEBDL-1080p Proper][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Godzilla x Kong The New Empire (2024)'

# Gold (2022)
move_to_deleted '/mnt/synology/rs-movies/Gold (2022)/Gold (2022) {imdb-tt6020800} [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv' 'Gold (2022)'

# Golda (2023)
move_to_deleted '/mnt/synology/rs-movies/Golda (2023)/Golda (2023) {imdb-tt14454876} [WEBDL-1080p Proper][EAC3 5.1][h264]-OWiE.mkv' 'Golda (2023)'

# Goldfinger (1964)
move_to_deleted '/mnt/synology/rs-movies/Goldfinger (1964)/Goldfinger (1964) {imdb-tt0058150} [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv' 'Goldfinger (1964)'

# Good Burger 2 (2023)
move_to_deleted '/mnt/synology/rs-movies/Good Burger 2 (2023)/Good Burger 2 (2023) {imdb-tt25289836} [Bluray-1080p][AC3 5.1][x264]-ArMor.mkv' 'Good Burger 2 (2023)'

# Good Dinosaur, The (2015)
move_to_deleted '/mnt/synology/rs-movies/Good Dinosaur, The (2015)/The Good Dinosaur (2015) {imdb-tt1979388} [Bluray-1080p][DTS-HD MA 7.1][x264]-FuzerHD.mkv' 'Good Dinosaur, The (2015)'

# Good Nurse, The (2022)
move_to_deleted '/mnt/synology/rs-movies/Good Nurse, The (2022)/The Good Nurse (2022) {imdb-tt4273800} [NF][WEBDL-1080p][EAC3 Atmos 5.1][HEVC]-NPMS.mkv' 'Good Nurse, The (2022)'

# Good Time (2017)
move_to_deleted '/mnt/synology/rs-movies/Good Time (2017)/Good Time (2017) {imdb-tt4846232} [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv' 'Good Time (2017)'

# Goodfellas (1990)
move_to_deleted '/mnt/synology/rs-movies/Goodfellas (1990)/GoodFellas (1990) {imdb-tt0099685} [Bluray-1080p][HDR10][EAC3 5.1][x265]-DON.mkv' 'Goodfellas (1990)'

# Goodrich (2024)
move_to_deleted '/mnt/synology/rs-movies/Goodrich (2024)/Goodrich (2024) {imdb-tt10171472} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Goodrich (2024)'

# Goon (2011) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Goon (2011)/Goon (2012) {imdb-tt1456635} [Bluray-720p][AAC 2.0][x264]-npuer.mkv' 'Goon (2011)'

# Goonies, The (1985)
move_to_deleted '/mnt/synology/rs-movies/Goonies, The (1985)/The Goonies (1985) {imdb-tt0089218} [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv' 'Goonies, The (1985)'

# Goosebumps 2 Haunted Halloween (2018)
move_to_deleted '/mnt/synology/rs-movies/Goosebumps 2 Haunted Halloween (2018)/Goosebumps 2 Haunted Halloween (2018) {imdb-tt5664636} [Bluray-1080p][AC3 5.1][x264]-VietHD.mkv' 'Goosebumps 2 Haunted Halloween (2018)'

# Graduate, The (1967)
move_to_deleted '/mnt/synology/rs-movies/Graduate, The (1967)/The Graduate (1967) {imdb-tt0061722} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Graduate, The (1967)'

# Gran Turismo (2023)
move_to_deleted '/mnt/synology/rs-movies/Gran Turismo (2023)/Gran Turismo (2023) {imdb-tt4495098} [WEBRip-1080p][AC3 5.1][x264].mp4' 'Gran Turismo (2023)'

# Gray Man, The (2022)
move_to_deleted '/mnt/synology/rs-movies/Gray Man, The (2022)/The Gray Man (2022) WEBDL-1080p Proper.mkv' 'Gray Man, The (2022)'

# Great Escape, The (1963)
move_to_deleted '/mnt/synology/rs-movies/Great Escape, The (1963)/The Great Escape (1963) {imdb-tt0057115} [WEBDL-1080p][DTS 5.1][x264].mkv' 'Great Escape, The (1963)'

# Greatest Showman, The (2017)
move_to_deleted '/mnt/synology/rs-movies/Greatest Showman, The (2017)/The Greatest Showman (2017) {imdb-tt1485796} [Bluray-1080p][DTS-ES 5.1][x264].mkv' 'Greatest Showman, The (2017)'

# Greedy People (2024)
move_to_deleted '/mnt/synology/rs-movies/Greedy People (2024)/Greedy People (2024) {imdb-tt20201748} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Greedy People (2024)'

# Green Book (2018)
move_to_deleted '/mnt/synology/rs-movies/Green Book (2018)/Green Book (2018) {imdb-tt6966692} [Bluray-1080p][EAC3 7.1][x264]-LoRD.mkv' 'Green Book (2018)'

# Green Knight, The (2021)
move_to_deleted '/mnt/synology/rs-movies/Green Knight, The (2021)/The Green Knight (2021) {imdb-tt9243804} [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv' 'Green Knight, The (2021)'

# Gremlins (1984)
move_to_deleted '/mnt/synology/rs-movies/Gremlins (1984)/Gremlins (1984) {imdb-tt0087363} [Bluray-1080p][HDR10][EAC3 5.1][x265]-JM.mkv' 'Gremlins (1984)'

# Grimsby (2016) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Grimsby (2016)/Grimsby (2016) {imdb-tt3381008} [Bluray-720p][AC3 5.1][x264].mkv' 'Grimsby (2016)'

# Grinch, The (2018)
move_to_deleted '/mnt/synology/rs-movies/Grinch, The (2018)/The Grinch (2018) {imdb-tt2709692} [Bluray-1080p][AC3 5.1][x264]-RAPiDCOWS.mkv' 'Grinch, The (2018)'

# Groundhog Day (1993)
move_to_deleted '/mnt/synology/rs-movies/Groundhog Day (1993)/Groundhog Day (1993) {imdb-tt0107048} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv' 'Groundhog Day (1993)'

# Guardians of the Galaxy (2014)
move_to_deleted '/mnt/synology/rs-movies/Guardians of the Galaxy (2014)/Guardians of the Galaxy (2014) {imdb-tt2015381} [Bluray-1080p][HDR10][EAC3 7.1][x265]-NCmt.mkv' 'Guardians of the Galaxy (2014)'

# Guardians of the Galaxy Vol. 2 (2017)
move_to_deleted '/mnt/synology/rs-movies/Guardians of the Galaxy Vol. 2 (2017)/Guardians of the Galaxy Vol. 2 (2017) {imdb-tt3896198} [Bluray-1080p][HDR10][EAC3 7.1][x265]-NCmt.mkv' 'Guardians of the Galaxy Vol. 2 (2017)'

# Guillermo del Toro\'s Pinocchio (2022)
move_to_deleted '/mnt/synology/rs-movies/Guillermo del Toro\'s Pinocchio (2022)/Guillermo del Toro\'s Pinocchio (2022) {imdb-tt1488589} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-SMURF.mkv' 'Guillermo del Toro\'s Pinocchio (2022)'

# Gunner (2024)
move_to_deleted '/mnt/synology/rs-movies/Gunner (2024)/Gunner (2024) {imdb-tt12598606} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Gunner (2024)'

# HIM (2025)
move_to_deleted '/mnt/synology/rs-movies/HIM (2025)/HIM (2025) {imdb-tt20990442} - [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-Draken02.mkv' 'HIM (2025)'

# Hallelujah Leonard Cohen, A Journey, A Song (2022)
move_to_deleted '/mnt/synology/rs-movies/Hallelujah Leonard Cohen, A Journey, A Song (2022)/Hallelujah Leonard Cohen, a Journey, a Song (2022) {imdb-tt7600742} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-HONE.mkv' 'Hallelujah Leonard Cohen, A Journey, A Song (2022)'

# Halloween (1978)
move_to_deleted '/mnt/synology/rs-movies/Halloween (1978)/Halloween (1978) {imdb-tt0077651} [Bluray-1080p][AC3 5.1][x264]-EbP.mkv' 'Halloween (1978)'

# Halloween Ends (2022)
move_to_deleted '/mnt/synology/rs-movies/Halloween Ends (2022)/Halloween Ends (2022) {imdb-tt10665342} [PCOK][WEBDL-1080p][EAC3 5.1][x264]-NTb.mkv' 'Halloween Ends (2022)'

# Halloween II (1981)
move_to_deleted '/mnt/synology/rs-movies/Halloween II (1981)/Halloween II (1981) {imdb-tt0082495} [Bluray-1080p][EAC3 7.1][x264]-LoRD.mkv' 'Halloween II (1981)'

# Halloween Kills (2021)
move_to_deleted '/mnt/synology/rs-movies/Halloween Kills (2021)/Halloween Kills (2021) {imdb-tt10665338} [PCOK][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Halloween Kills (2021)'

# Halloween The Curse of Michael Myers (1995)
move_to_deleted '/mnt/synology/rs-movies/Halloween The Curse of Michael Myers (1995)/Halloween The Curse of Michael Myers (1995) {imdb-tt0113253} [Bluray-1080p][DTS 5.1][x264]-MgB.mkv' 'Halloween The Curse of Michael Myers (1995)'

# Hamlet (1990)
move_to_deleted '/mnt/synology/rs-movies/Hamlet (1990)/Hamlet (1990) {imdb-tt0099726} [WEBDL-1080p][DTS 2.0][x264].mkv' 'Hamlet (1990)'

# Hand of God, The (2021)
move_to_deleted '/mnt/synology/rs-movies/Hand of God, The (2021)/The Hand of God (2021) {imdb-tt12680684} [NF][WEBDL-1080p][EAC3 5.1][HEVC]-TEPES.mkv' 'Hand of God, The (2021)'

# Handling the Undead (2024)
move_to_deleted '/mnt/synology/rs-movies/Handling the Undead (2024)/Handling the Undead (2024) {imdb-tt2118648} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Handling the Undead (2024)'

# Hans Zimmer and Friends Diamond in the Desert (2025)
move_to_deleted '/mnt/synology/rs-movies/Hans Zimmer and Friends Diamond in the Desert (2025)/Hans Zimmer and Friends Diamond in the Desert (2025) {imdb-tt35616060} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Hans Zimmer and Friends Diamond in the Desert (2025)'

# Hansel & Gretel - Witch Hunters (2013)
move_to_deleted '/mnt/synology/rs-movies/Hansel & Gretel - Witch Hunters (2013)/Hansel.&.Gretel.Witch.Hunters.2013.1080p.BluRay.DTS.x264.D-Z0N3.mkv' 'Hansel & Gretel - Witch Hunters (2013)'

# Happiest Season (2020)
move_to_deleted '/mnt/synology/rs-movies/Happiest Season (2020)/Happiest Season (2020) {imdb-tt8522006} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-NTb.mkv' 'Happiest Season (2020)'

# Happiness for Beginners (2023)
move_to_deleted '/mnt/synology/rs-movies/Happiness for Beginners (2023)/Happiness for Beginners (2023) {imdb-tt15509244} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv' 'Happiness for Beginners (2023)'

# Happy Feet (2006)
move_to_deleted '/mnt/synology/rs-movies/Happy Feet (2006)/Happy Feet (2006) {imdb-tt0366548} [HDTV-1080p][AC3 5.1][x264]-x264.mkv' 'Happy Feet (2006)'

# Happy Gilmore (1996)
move_to_deleted '/mnt/synology/rs-movies/Happy Gilmore (1996)/Happy Gilmore (1996) {imdb-tt0116483} [Bluray-1080p][DTS 5.1][x264]-LCHD.mkv' 'Happy Gilmore (1996)'

# Harlem Nights (1989)
move_to_deleted '/mnt/synology/rs-movies/Harlem Nights (1989)/Harlem Nights (1989) {imdb-tt0097481} [WEBDL-1080p][AC3 5.1][x264]-DiMEPiECE.mkv' 'Harlem Nights (1989)'

# Harriet (2019)
move_to_deleted '/mnt/synology/rs-movies/Harriet (2019)/Harriet (2019) {imdb-tt4648786} [WEBDL-1080p][EAC3 5.1][h264].mkv' 'Harriet (2019)'

# Harry Potter and the Goblet of Fire (2005)
move_to_deleted '/mnt/synology/rs-movies/Harry Potter and the Goblet of Fire (2005)/Harry Potter and the Goblet of Fire (2005) {imdb-tt0330373} [Bluray-1080p][AC3 5.1][x264]-NTb.mkv' 'Harry Potter and the Goblet of Fire (2005)'

# Harry Potter and the Order of the Phoenix (2007)
move_to_deleted '/mnt/synology/rs-movies/Harry Potter and the Order of the Phoenix (2007)/Harry Potter and the Order of the Phoenix (2007) {imdb-tt0373889} [Bluray-1080p][AC3 5.1][x264]-NTb.mkv' 'Harry Potter and the Order of the Phoenix (2007)'

# Harry Potter and the Prisoner of Azkaban (2004)
move_to_deleted '/mnt/synology/rs-movies/Harry Potter and the Prisoner of Azkaban (2004)/Harry Potter and the Prisoner of Azkaban (2004) {imdb-tt0304141} [Bluray-1080p][AC3 5.1][x264]-NTb.mkv' 'Harry Potter and the Prisoner of Azkaban (2004)'

# Harry Potter and the Sorcerer\'s Stone (2001)
move_to_deleted '/mnt/synology/rs-movies/Harry Potter and the Sorcerer\'s Stone (2001)/Harry Potter and the Philosopher\'s Stone (2001) {imdb-tt0241527} {edition-Extended Cut} [Bluray-1080p][DTS 5.1][x264]-NTb.mkv' 'Harry Potter and the Sorcerer\'s Stone (2001)'

# Hatchet (2006)
move_to_deleted '/mnt/synology/rs-movies/Hatchet (2006)/Hatchet (2006) {imdb-tt0422401} {edition-Unrated} [Bluray-1080p][AC3 5.1][x264]-MaG.mkv' 'Hatchet (2006)'

# Haunted Mansion (2023)
move_to_deleted '/mnt/synology/rs-movies/Haunted Mansion (2023)/Haunted Mansion (2023) {imdb-tt1695843} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Haunted Mansion (2023)'

# Heartbreak Ridge (1986) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Heartbreak Ridge (1986)/Heartbreak Ridge (1986) {imdb-tt0091187} [Bluray-720p][DTS 5.1][x264].mkv' 'Heartbreak Ridge (1986)'

# Heat (1995)
move_to_deleted '/mnt/synology/rs-movies/Heat (1995)/Heat (1995) {imdb-tt0113277} [Bluray-1080p][DTS 5.1][x264].mkv' 'Heat (1995)'

# Heathers (1988)
move_to_deleted '/mnt/synology/rs-movies/Heathers (1988)/Heathers (1989) {imdb-tt0097493} {edition-Remastered} [Bluray-1080p][DTS 5.1][x264]-AMIABLE.mkv' 'Heathers (1988)'

# Hell or High Water (2016)
move_to_deleted '/mnt/synology/rs-movies/Hell or High Water (2016)/Hell or High Water (2016) {imdb-tt2582782} [Bluray-1080p][DTS 5.1][x264]-VECTOR.mkv' 'Hell or High Water (2016)'

# Hellboy II - The Golden Army (2008)
move_to_deleted '/mnt/synology/rs-movies/Hellboy II - The Golden Army (2008)/Hellboy II The Golden Army (2008) {imdb-tt0411477} [Bluray-1080p][DTS 5.1][x264].mkv' 'Hellboy II - The Golden Army (2008)'

# Hellraiser (1987)
move_to_deleted '/mnt/synology/rs-movies/Hellraiser (1987)/Hellraiser (1987) {imdb-tt0093177} [Remux-1080p][PCM 2.0][x264].mkv' 'Hellraiser (1987)'

# Hellraiser (2022)
move_to_deleted '/mnt/synology/rs-movies/Hellraiser (2022)/Hellraiser (2022) {imdb-tt0887261} [Hulu][WEBDL-1080p][EAC3 5.1][h264]-HELLRAiZER.mkv' 'Hellraiser (2022)'

# Herbie Fully Loaded (2005)
move_to_deleted '/mnt/synology/rs-movies/Herbie Fully Loaded (2005)/Herbie Fully Loaded (2005) {imdb-tt0400497} [WEBDL-1080p][EAC3 5.1][h264]-monkee.mkv' 'Herbie Fully Loaded (2005)'

# Here (2024)
move_to_deleted '/mnt/synology/rs-movies/Here (2024)/Here (2024) {imdb-tt18272208} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv' 'Here (2024)'

# Heretic (2024)
move_to_deleted '/mnt/synology/rs-movies/Heretic (2024)/Heretic (2024) {imdb-tt28015403} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-APEX.mkv' 'Heretic (2024)'

# Herstory (2024)
move_to_deleted '/mnt/synology/rs-movies/Herstory (2024)/Herstory (2024) {imdb-tt31807233} [WEBDL-1080p][AAC 2.0][h264]-HHWEB.mkv' 'Herstory (2024)'

# High School Musical 2 (2007)
move_to_deleted '/mnt/synology/rs-movies/High School Musical 2 (2007)/High School Musical 2 (2007) {imdb-tt0810900} {edition-Extended Cut} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'High School Musical 2 (2007)'

# Hillbilly Elegy (2020)
move_to_deleted '/mnt/synology/rs-movies/Hillbilly Elegy (2020)/Hillbilly Elegy (2020) {imdb-tt6772802} [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv' 'Hillbilly Elegy (2020)'

# History of Violence, A (2005)
move_to_deleted '/mnt/synology/rs-movies/History of Violence, A (2005)/A History of Violence (2005) {imdb-tt0399146} [Bluray-1080p][DTS 5.1][x264]-MR.mkv' 'History of Violence, A (2005)'

# Hit Man (2024)
move_to_deleted '/mnt/synology/rs-movies/Hit Man (2024)/Hit Man (2024) {imdb-tt20215968} [WEBDL-1080p][EAC3 Atmos 5.1][x264]-HeKilledAnyStream.mkv' 'Hit Man (2024)'

# The Hitman\'s Bodyguard (2017)
move_to_deleted '/mnt/synology/rs-movies/The Hitman\'s Bodyguard (2017)/The Hitman\'s Bodyguard (2017) {imdb-tt1959563} [Bluray-1080p][AC3 5.1][x264].mkv' 'The Hitman\'s Bodyguard (2017)'

# Hitman\'s Wife\'s Bodyguard (2021)
move_to_deleted '/mnt/synology/rs-movies/Hitman\'s Wife\'s Bodyguard (2021)/Hitman\'s Wife\'s Bodyguard (2021) {imdb-tt8385148} [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv' 'Hitman\'s Wife\'s Bodyguard (2021)'

# Hocus Pocus (1993)
move_to_deleted '/mnt/synology/rs-movies/Hocus Pocus (1993)/Hocus Pocus (1993) {imdb-tt0107120} [HDTV-1080p][DTS-HD MA 5.1][x264].mkv' 'Hocus Pocus (1993)'

# Home Alone (1990)
move_to_deleted '/mnt/synology/rs-movies/Home Alone (1990)/Home Alone (1990) {imdb-tt0099785} [Bluray-1080p][AC3 5.1][x265].mkv' 'Home Alone (1990)'

# Home Alone 2 Lost in New York (1992)
move_to_deleted '/mnt/synology/rs-movies/Home Alone 2 Lost in New York (1992)/Home Alone 2 Lost in New York (1992) {imdb-tt0104431} [Bluray-1080p][AC3 5.1][x265].mkv' 'Home Alone 2 Lost in New York (1992)'

# Home Team (2022)
move_to_deleted '/mnt/synology/rs-movies/Home Team (2022)/Home Team (2022) {imdb-tt14592064} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-TEPES.mkv' 'Home Team (2022)'

# Home for the Holidays (1995)
move_to_deleted '/mnt/synology/rs-movies/Home for the Holidays (1995)/Home for the Holidays (1995) {imdb-tt0113321} [AMZN][WEBDL-1080p][EAC3 2.0][x264]-monkee.mkv' 'Home for the Holidays (1995)'

# Homestead (2024)
move_to_deleted '/mnt/synology/rs-movies/Homestead (2024)/Homestead (2024) {imdb-tt29137778} [WEBDL-1080p][AAC 2.0][AV1]-LuCY.mkv' 'Homestead (2024)'

# Hook (1991)
move_to_deleted '/mnt/synology/rs-movies/Hook (1991)/Hook (1991) {imdb-tt0102057} [Bluray-1080p][DTS 5.1][x264].mkv' 'Hook (1991)'

# Horizon An American Saga Chapter 1 (2024)
move_to_deleted '/mnt/synology/rs-movies/Horizon An American Saga Chapter 1 (2024)/Horizon An American Saga Chapter 1 (2024) {imdb-tt17505010} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-Kitsune.mkv' 'Horizon An American Saga Chapter 1 (2024)'

# Hot Fuzz (2007)
move_to_deleted '/mnt/synology/rs-movies/Hot Fuzz (2007)/Hot Fuzz (2007) {imdb-tt0425112} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv' 'Hot Fuzz (2007)'

# Hot Rod (2007)
move_to_deleted '/mnt/synology/rs-movies/Hot Rod (2007)/Hot Rod (2007) {imdb-tt0787475} [Bluray-1080p][AC3 5.1][x264]-OFT.mkv' 'Hot Rod (2007)'

# Hot Shots! (1991)
move_to_deleted '/mnt/synology/rs-movies/Hot Shots! (1991)/Hot Shots! (1991) {imdb-tt0102059} [Bluray-1080p][DTS 5.1][x264]-AMIABLE.mkv' 'Hot Shots! (1991)'

# Hotel Artemis (2018)
move_to_deleted '/mnt/synology/rs-movies/Hotel Artemis (2018)/Hotel Artemis (2018) {imdb-tt5834262} [Bluray-1080p][AC3 5.1][x264]-LoRD.mkv' 'Hotel Artemis (2018)'

# Hotel Chevalier (2007)
move_to_deleted '/mnt/synology/rs-movies/Hotel Chevalier (2007)/Hotel Chevalier (2007) {imdb-tt1094249} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Hotel Chevalier (2007)'

# Hotel Transylvania (2012)
move_to_deleted '/mnt/synology/rs-movies/Hotel Transylvania (2012)/Hotel Transylvania (2012) {imdb-tt0837562} [HDTV-1080p][DTS 5.1][x264].mkv' 'Hotel Transylvania (2012)'

# Hotel Transylvania Transformania (2022)
move_to_deleted '/mnt/synology/rs-movies/Hotel Transylvania Transformania (2022)/Hotel Transylvania Transformania (2022) {imdb-tt9848626} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-MZABI.mkv' 'Hotel Transylvania Transformania (2022)'

# Hounds of War (2024)
move_to_deleted '/mnt/synology/rs-movies/Hounds of War (2024)/Hounds of War (2024) {imdb-tt12972134} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Hounds of War (2024)'

# House Party (2023)
move_to_deleted '/mnt/synology/rs-movies/House Party (2023)/House Party (2023) {imdb-tt8005118} [AMZN][WEBDL-1080p Proper][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'House Party (2023)'

# House of Gucci (2021)
move_to_deleted '/mnt/synology/rs-movies/House of Gucci (2021)/House of Gucci (2021) {imdb-tt11214590} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv' 'House of Gucci (2021)'

# How the Grinch Stole Christmas (2000)
move_to_deleted '/mnt/synology/rs-movies/How the Grinch Stole Christmas (2000)/How the Grinch Stole Christmas (2000) {imdb-tt0170016} [Bluray-1080p][DTS 5.1][x264]-EbP.mkv' 'How the Grinch Stole Christmas (2000)'

# How the Grinch Stole Christmas! (1966) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/How the Grinch Stole Christmas! (1966)/How the Grinch Stole Christmas! (1966) {imdb-tt0060345} [Bluray-1080p Proper][AC3 2.0][x264]-BHDStudio.mp4' 'How the Grinch Stole Christmas! (1966)'

# How to Have Sex (2023)
move_to_deleted '/mnt/synology/rs-movies/How to Have Sex (2023)/How to Have Sex (2023) {imdb-tt22890246} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'How to Have Sex (2023)'

# How to Steal a Million (1966)
move_to_deleted '/mnt/synology/rs-movies/How to Steal a Million (1966)/How to Steal a Million (1966) {imdb-tt0060522} [Bluray-1080p][FLAC 2.0][x264]-SADPANDA.mkv' 'How to Steal a Million (1966)'

# How to Train Your Dragon (2025)
move_to_deleted '/mnt/synology/rs-movies/How to Train Your Dragon (2025)/How to Train Your Dragon (2025) {imdb-tt26743210} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-BYNDR.mkv' 'How to Train Your Dragon (2025)'

# How to Train Your Dragon The Hidden World (2019)
move_to_deleted '/mnt/synology/rs-movies/How to Train Your Dragon The Hidden World (2019)/How to Train Your Dragon The Hidden World (2019) {imdb-tt2386490} [Bluray-1080p][DTS 5.1][x264].mkv' 'How to Train Your Dragon The Hidden World (2019)'

# Howards End (1992)
move_to_deleted '/mnt/synology/rs-movies/Howards End (1992)/Howards End (1992) {imdb-tt0104454} [Bluray-1080p][AC3 5.1][x264]-EbP.mkv' 'Howards End (1992)'

# Hulk Where Monsters Dwell (2016)
move_to_deleted '/mnt/synology/rs-movies/Hulk Where Monsters Dwell (2016)/Hulk Where Monsters Dwell (2016) {imdb-tt6173902} [WEBRip-1080p][EAC3 5.1][x264]-monkee.mkv' 'Hulk Where Monsters Dwell (2016)'

# Humanity Bureau, The (2017)
move_to_deleted '/mnt/synology/rs-movies/Humanity Bureau, The (2017)/The Humanity Bureau (2017) {imdb-tt6143568} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv' 'Humanity Bureau, The (2017)'

# Hunt, The (2020)
move_to_deleted '/mnt/synology/rs-movies/Hunt, The (2020)/Time to Hunt (2020) {imdb-tt11777040} [Bluray-1080p][DTS-HD MA 7.1][x264]-CHD.mkv' 'Hunt, The (2020)'

# Hunter Killer (2018)
move_to_deleted '/mnt/synology/rs-movies/Hunter Killer (2018)/Hunter Killer (2018) {imdb-tt1846589} [Bluray-1080p][EAC3 5.1][x264]-LoRD.mkv' 'Hunter Killer (2018)'

# Hunting Season (2025)
move_to_deleted '/mnt/synology/rs-movies/Hunting Season (2025)/Hunting Season (2025) {imdb-tt32537226} [WEBRip-1080p][AAC 5.1][h264]-LAMA.mp4' 'Hunting Season (2025)'

# Huntsman Winter\'s War, The (2016)
move_to_deleted '/mnt/synology/rs-movies/Huntsman Winter\'s War, The (2016)/The Huntsman Winter\'s War (2016) {imdb-tt2381991} {edition-Extended} [Bluray-1080p][HDR10][EAC3 7.1][x265]-CtrlHD.mkv' 'Huntsman Winter\'s War, The (2016)'

# Hustle, The (2019)
move_to_deleted '/mnt/synology/rs-movies/Hustle, The (2019)/The Hustle (2019) {imdb-tt1298644} [Bluray-1080p][DTS 5.1][x264]-drones.mkv' 'Hustle, The (2019)'

# Hypnotic (2023)
move_to_deleted '/mnt/synology/rs-movies/Hypnotic (2023)/Hypnotic (2023) {imdb-tt8080204} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Hypnotic (2023)'

# I Am Sam (2001) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/I Am Sam (2001)/I Am Sam (2001) {imdb-tt0277027} [Bluray-720p][DTS 5.1][x264].mkv' 'I Am Sam (2001)'

# I Know What You Did Last Summer (1997)
move_to_deleted '/mnt/synology/rs-movies/I Know What You Did Last Summer (1997)/I Know What You Did Last Summer (1997) {imdb-tt0119345} [Bluray-1080p][AC3 5.1][x264].mkv' 'I Know What You Did Last Summer (1997)'

# I Know What You Did Last Summer (2025)
move_to_deleted '/mnt/synology/rs-movies/I Know What You Did Last Summer (2025)/I Know What You Did Last Summer (2025) {imdb-tt4045450} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-BYNDR.mkv' 'I Know What You Did Last Summer (2025)'

# I Saw the TV Glow (2024)
move_to_deleted '/mnt/synology/rs-movies/I Saw the TV Glow (2024)/I Saw the TV Glow (2024) {imdb-tt15574270} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'I Saw the TV Glow (2024)'

# I See You (2019)
move_to_deleted '/mnt/synology/rs-movies/I See You (2019)/I See You (2019) {imdb-tt6079516} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv' 'I See You (2019)'

# I Still Know What You Did Last Summer (1998)
move_to_deleted '/mnt/synology/rs-movies/I Still Know What You Did Last Summer (1998)/I Still Know What You Did Last Summer (1998) {imdb-tt0130018} [Bluray-1080p][AC3 5.1][x264]-TFiN.mkv' 'I Still Know What You Did Last Summer (1998)'

# I Used to Be Famous (2022)
move_to_deleted '/mnt/synology/rs-movies/I Used to Be Famous (2022)/I Used to Be Famous (2022) {imdb-tt15807910} [WEBRip-1080p Proper][AAC 5.1][x264]-LAMA.mp4' 'I Used to Be Famous (2022)'

# I\'ll Follow You Down (2013) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/I\'ll Follow You Down (2013)/I\'ll Follow You Down (2013) {imdb-tt2048770} [Bluray-720p][DTS 5.1][x264].mkv' 'I\'ll Follow You Down (2013)'

# IF (2024)
move_to_deleted '/mnt/synology/rs-movies/IF (2024)/IF (2024) {imdb-tt11152168} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-POKE.mkv' 'IF (2024)'

# Idiocracy (2006)
move_to_deleted '/mnt/synology/rs-movies/Idiocracy (2006)/Idiocracy (2006) {imdb-tt0387808} [WEBDL-1080p][EAC3 5.1][x264].mkv' 'Idiocracy (2006)'

# If I Had Legs Id Kick You (2025) (480p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/If I Had Legs Id Kick You (2025)/If I Had Legs I\'d Kick You (2025) {imdb-tt18382850} [AMZN][WEBDL-720p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'If I Had Legs Id Kick You (2025)'

# Immaculate (2024)
move_to_deleted '/mnt/synology/rs-movies/Immaculate (2024)/Immaculate (2024) {imdb-tt23137390} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Immaculate (2024)'

# Impractical Jokers The Movie (2020)
move_to_deleted '/mnt/synology/rs-movies/Impractical Jokers The Movie (2020)/Impractical Jokers The Movie (2020) {imdb-tt9208444} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Impractical Jokers The Movie (2020)'

# In Bruges (2008)
move_to_deleted '/mnt/synology/rs-movies/In Bruges (2008)/In Bruges (2008) {imdb-tt0780536} [Bluray-1080p][AC3 5.1][x264].mkv' 'In Bruges (2008)'

# In The Heights (2021)
move_to_deleted '/mnt/synology/rs-movies/In The Heights (2021)/In the Heights (2021) {imdb-tt1321510} [HMAX][WEBDL-1080p][EAC3 Atmos 5.1][x264]-EVO.mkv' 'In The Heights (2021)'

# In Time (2011)
move_to_deleted '/mnt/synology/rs-movies/In Time (2011)/In Time (2011) {imdb-tt1637688} [WEBDL-1080p][DTS 5.1][h264].mkv' 'In Time (2011)'

# In a Violent Nature (2024)
move_to_deleted '/mnt/synology/rs-movies/In a Violent Nature (2024)/In a Violent Nature (2024) {imdb-tt30321146} [WEBDL-1080p][EAC3 5.1][h264]-CalmNiceToucanetOfCompletion.mkv' 'In a Violent Nature (2024)'

# In the Heart of the Sea (2015)
move_to_deleted '/mnt/synology/rs-movies/In the Heart of the Sea (2015)/In the Heart of the Sea (2015) {imdb-tt1390411} [Bluray-1080p][DTS-HD MA 7.1][x264]-FraMeSToR.mkv' 'In the Heart of the Sea (2015)'

# In the Land of Saints and Sinners (2023)
move_to_deleted '/mnt/synology/rs-movies/In the Land of Saints and Sinners (2023)/In the Land of Saints and Sinners (2023) {imdb-tt15782690} [WEBDL-1080p][AC3 5.1][h264]-DKV.mkv' 'In the Land of Saints and Sinners (2023)'

# In the Line of Fire (1993)
move_to_deleted '/mnt/synology/rs-movies/In the Line of Fire (1993)/In the Line of Fire (1993) {imdb-tt0107206} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv' 'In the Line of Fire (1993)'

# In the Lost Lands (2025)
move_to_deleted '/mnt/synology/rs-movies/In the Lost Lands (2025)/In the Lost Lands (2025) {imdb-tt4419684} [Bluray-1080p][DTS-HD MA 5.1][x264]-COCAIN.mkv' 'In the Lost Lands (2025)'

# Incendies (2010)
move_to_deleted '/mnt/synology/rs-movies/Incendies (2010)/Incendies (2010) {imdb-tt1255953} [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv' 'Incendies (2010)'

# Inception (2010)
move_to_deleted '/mnt/synology/rs-movies/Inception (2010)/Inception (2010) {imdb-tt1375666} [Bluray-1080p][HDR10][DTS 5.1][x265]-D-Z0N3.mkv' 'Inception (2010)'

# Indecent Proposal (1993)
move_to_deleted '/mnt/synology/rs-movies/Indecent Proposal (1993)/Indecent Proposal (1993) {imdb-tt0107211} [Bluray-1080p Proper][AC3 5.1][x264]-PUZZLE.mkv' 'Indecent Proposal (1993)'

# Independence Day Resurgence (2016)
move_to_deleted '/mnt/synology/rs-movies/Independence Day Resurgence (2016)/Independence Day Resurgence (2016) {imdb-tt1628841} [Bluray-1080p][HDR10][EAC3 7.1][x265]-CtrlHD.mkv' 'Independence Day Resurgence (2016)'

# Indiana Jones and the Kingdom of the Crystal Skull (2008)
move_to_deleted '/mnt/synology/rs-movies/Indiana Jones and the Kingdom of the Crystal Skull (2008)/Indiana Jones and the Kingdom of the Crystal Skull (2008) {imdb-tt0367882} [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv' 'Indiana Jones and the Kingdom of the Crystal Skull (2008)'

# Indiana Jones and the Last Crusade (1989)
move_to_deleted '/mnt/synology/rs-movies/Indiana Jones and the Last Crusade (1989)/Indiana Jones and the Last Crusade (1989) {imdb-tt0097576} [HDTV-1080p][AC3 5.1][x264].mkv' 'Indiana Jones and the Last Crusade (1989)'

# Indiana Jones and the Temple of Doom (1984)
move_to_deleted '/mnt/synology/rs-movies/Indiana Jones and the Temple of Doom (1984)/Indiana Jones and the Temple of Doom (1984) {imdb-tt0087469} [Bluray-1080p][DTS 5.1][x264].mkv' 'Indiana Jones and the Temple of Doom (1984)'

# Inferno (2016)
move_to_deleted '/mnt/synology/rs-movies/Inferno (2016)/Inferno (2016) {imdb-tt3062096} [HDTV-1080p][AC3 2.0][x264].mkv' 'Inferno (2016)'

# Infested (2023)
move_to_deleted '/mnt/synology/rs-movies/Infested (2023)/Infested (2023) {imdb-tt26744289} [WEBDL-1080p][EAC3 5.1][h264]-heretofuckspiders.mkv' 'Infested (2023)'

# Infinite (2021)
move_to_deleted '/mnt/synology/rs-movies/Infinite (2021)/Infinite (2021) {imdb-tt6654210} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv' 'Infinite (2021)'

# Infinitely Polar Bear (2014) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Infinitely Polar Bear (2014)/Infinitely Polar Bear (2014) {imdb-tt1969062} [Bluray-720p][AC3 5.1][x264]-IDE.mkv' 'Infinitely Polar Bear (2014)'

# Infinity Pool (2023)
move_to_deleted '/mnt/synology/rs-movies/Infinity Pool (2023)/Infinity Pool (2023) {imdb-tt10365998} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Infinity Pool (2023)'

# Influencer (2023)
move_to_deleted '/mnt/synology/rs-movies/Influencer (2023)/Influencer (2023) {imdb-tt13309170} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv' 'Influencer (2023)'

# Inside (2023)
move_to_deleted '/mnt/synology/rs-movies/Inside (2023)/Inside (2023) {imdb-tt14781036} [WEBDL-1080p][AC3 5.1][h264]-SLOT.mkv' 'Inside (2023)'

# Inside Out 2 (2024)
move_to_deleted '/mnt/synology/rs-movies/Inside Out 2 (2024)/Inside Out 2 (2024) {imdb-tt22022452} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Inside Out 2 (2024)'

# Interceptor (2022)
move_to_deleted '/mnt/synology/rs-movies/Interceptor (2022)/Interceptor (2022) {imdb-tt14174940} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv' 'Interceptor (2022)'

# Interstellar (2014)
move_to_deleted '/mnt/synology/rs-movies/Interstellar (2014)/Interstellar (2014) {imdb-tt0816692} {edition-Imax} [Bluray-1080p Proper][DTS 5.1][x264]-TayTO.mkv' 'Interstellar (2014)'

# Invisible Man, The (2020)
move_to_deleted '/mnt/synology/rs-movies/Invisible Man, The (2020)/The Invisible Man (2020) {imdb-tt1051906} [WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv' 'Invisible Man, The (2020)'

# Ip Man Kung Fu Master (2019)
move_to_deleted '/mnt/synology/rs-movies/Ip Man Kung Fu Master (2019)/Ip Man Kung Fu Master (2019) {imdb-tt12567246} [WEBDL-1080p][EAC3 5.1][h264]-CBFM.mkv' 'Ip Man Kung Fu Master (2019)'

# Iron Man (2008)
move_to_deleted '/mnt/synology/rs-movies/Iron Man (2008)/Iron Man (2008) {imdb-tt0371746} [Bluray-1080p][EAC3 Atmos 5.1][x264]-BiTOR.mkv' 'Iron Man (2008)'

# Iron Man 2 (2010)
move_to_deleted '/mnt/synology/rs-movies/Iron Man 2 (2010)/Iron Man 2 (2010) {imdb-tt1228705} {edition-Open Matte} [WEBDL-1080p][DTS 5.1][x264].mkv' 'Iron Man 2 (2010)'

# Iron Man 3 (2013)
move_to_deleted '/mnt/synology/rs-movies/Iron Man 3 (2013)/Iron Man 3 (2013) {imdb-tt1300854} [Bluray-1080p][DTS 5.1][x264].mkv' 'Iron Man 3 (2013)'

# Ironclad (2011) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Ironclad (2011)/Ironclad (2011) {imdb-tt1233301} [HDTV-720p][DTS 5.1][x264].mkv' 'Ironclad (2011)'

# It Chapter Two (2019)
move_to_deleted '/mnt/synology/rs-movies/It Chapter Two (2019)/It Chapter Two (2019) {imdb-tt7349950} [WEBDL-1080p][AC3 5.1][h264].mkv' 'It Chapter Two (2019)'

# It Ends with Us (2024)
move_to_deleted '/mnt/synology/rs-movies/It Ends with Us (2024)/It Ends with Us (2024) {imdb-tt10655524} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'It Ends with Us (2024)'

# It\'s a Wonderful Life (1946)
move_to_deleted '/mnt/synology/rs-movies/It\'s a Wonderful Life (1946)/It\'s a Wonderful Life (1946) {imdb-tt0038650} [Bluray-1080p][DV HDR10][FLAC 2.0][x265]-PTer.mkv' 'It\'s a Wonderful Life (1946)'

# Jack Reacher Never Go Back (2016)
move_to_deleted '/mnt/synology/rs-movies/Jack Reacher Never Go Back (2016)/Jack Reacher Never Go Back (2016) {imdb-tt3393786} [Bluray-1080p][AC3 5.1][x264].mkv' 'Jack Reacher Never Go Back (2016)'

# Jack and Jill (2011)
move_to_deleted '/mnt/synology/rs-movies/Jack and Jill (2011)/Jack and Jill (2011) {imdb-tt0810913} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Jack and Jill (2011)'

# Jackass Forever (2022)
move_to_deleted '/mnt/synology/rs-movies/Jackass Forever (2022)/Jackass Forever (2022) {imdb-tt11466222} [WEBDL-1080p Proper][AC3 5.1][h264]-SLOT.mkv' 'Jackass Forever (2022)'

# Jackie Brown (1997)
move_to_deleted '/mnt/synology/rs-movies/Jackie Brown (1997)/Jackie Brown (1997) {imdb-tt0119396} [Bluray-1080p][DTS 5.1][x264]-FoRM.mkv' 'Jackie Brown (1997)'

# James and the Giant Peach (1996)
move_to_deleted '/mnt/synology/rs-movies/James and the Giant Peach (1996)/James and the Giant Peach (1996) {imdb-tt0116683} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'James and the Giant Peach (1996)'

# Jarhead (2005)
move_to_deleted '/mnt/synology/rs-movies/Jarhead (2005)/Jarhead (2005) {imdb-tt0418763} [Bluray-1080p][DTS 5.1][x264]-EuReKA.mkv' 'Jarhead (2005)'

# Jason Bourne (2016)
move_to_deleted '/mnt/synology/rs-movies/Jason Bourne (2016)/Jason Bourne (2016) {imdb-tt4196776} [Bluray-1080p][HDR10][EAC3 7.1][x265]-CtrlHD.mkv' 'Jason Bourne (2016)'

# Jason X (2001)
move_to_deleted '/mnt/synology/rs-movies/Jason X (2001)/Jason X (2001) {imdb-tt0211443} {edition-Unrated} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Jason X (2001)'

# Jawan (2023)
move_to_deleted '/mnt/synology/rs-movies/Jawan (2023)/Jawan (2023) {imdb-tt15354916} {edition-Extended Cut} [NF][WEBDL-1080p][EAC3 5.1][x264]-KiNGKHAN.mkv' 'Jawan (2023)'

# Jaws (1975)
move_to_deleted '/mnt/synology/rs-movies/Jaws (1975)/Jaws (1975) {imdb-tt0073195} [Bluray-1080p][HDR10][EAC3 7.1][x265].mkv' 'Jaws (1975)'

# Jeepers Creepers Reborn (2022)
move_to_deleted '/mnt/synology/rs-movies/Jeepers Creepers Reborn (2022)/Jeepers Creepers Reborn (2022) {imdb-tt14121726} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv' 'Jeepers Creepers Reborn (2022)'

# Jerome Bixby\'s The Man from Earth (2007)
move_to_deleted '/mnt/synology/rs-movies/Jerome Bixby\'s The Man from Earth (2007)/The Man from Earth (2007) {imdb-tt0756683} [AMZN][WEBDL-1080p][EAC3 5.1][h264].mkv' 'Jerome Bixby\'s The Man from Earth (2007)'

# Jerry & Marge Go Large (2022)
move_to_deleted '/mnt/synology/rs-movies/Jerry & Marge Go Large (2022)/Jerry & Marge Go Large (2022) {imdb-tt8323668} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv' 'Jerry & Marge Go Large (2022)'

# Jimmy Carr Funny Business (2016)
move_to_deleted '/mnt/synology/rs-movies/Jimmy Carr Funny Business (2016)/Jimmy Carr Funny Business (2016) {imdb-tt5222724} [WEBRip-1080p][AC3 5.1][x264]-RARBG.mkv' 'Jimmy Carr Funny Business (2016)'

# John Wick (2014)
move_to_deleted '/mnt/synology/rs-movies/John Wick (2014)/John Wick (2014) {imdb-tt2911666} [WEBDL-1080p][AC3 5.1][h264]-TWA.mkv' 'John Wick (2014)'

# Jojo Rabbit (2019)
move_to_deleted '/mnt/synology/rs-movies/Jojo Rabbit (2019)/Jojo Rabbit (2019) {imdb-tt2584384} [WEBDL-1080p][EAC3 5.1][h264].mkv' 'Jojo Rabbit (2019)'

# Joker (2019)
move_to_deleted '/mnt/synology/rs-movies/Joker (2019)/Joker (2019) {imdb-tt7286456} [Bluray-1080p][HDR10][EAC3 7.1][x265].mkv' 'Joker (2019)'

# Journey to China The Mystery of Iron Mask (2019)
move_to_deleted '/mnt/synology/rs-movies/Journey to China The Mystery of Iron Mask (2019)/Iron Mask (2019) {imdb-tt6218010} [Bluray-1080p][EAC3 5.1][x264]-LoRD.mkv' 'Journey to China The Mystery of Iron Mask (2019)'

# Joy Ride (2023)
move_to_deleted '/mnt/synology/rs-movies/Joy Ride (2023)/Joy Ride (2023) {imdb-tt15268244} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Joy Ride (2023)'

# Judas and the Black Messiah (2021)
move_to_deleted '/mnt/synology/rs-movies/Judas and the Black Messiah (2021)/Judas and the Black Messiah (2021) {imdb-tt9784798} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-naisu.mkv' 'Judas and the Black Messiah (2021)'

# Jujutsu Kaisen 0 (2021)
move_to_deleted '/mnt/synology/rs-movies/Jujutsu Kaisen 0 (2021)/Jujutsu Kaisen 0 (2021) {imdb-tt14331144} [WEBDL-1080p Proper][AAC 2.0][x264]-Kitsune.mkv' 'Jujutsu Kaisen 0 (2021)'

# Jules (2023)
move_to_deleted '/mnt/synology/rs-movies/Jules (2023)/Jules (2023) {imdb-tt15428940} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-AirForceOne.mkv' 'Jules (2023)'

# Jumanji (1995)
move_to_deleted '/mnt/synology/rs-movies/Jumanji (1995)/Jumanji (1995) {imdb-tt0113497} [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv' 'Jumanji (1995)'

# Jumanji The Next Level (2019)
move_to_deleted '/mnt/synology/rs-movies/Jumanji The Next Level (2019)/Jumanji The Next Level (2019) {imdb-tt7975244} [WEBDL-1080p][AC3 5.1][x264].mkv' 'Jumanji The Next Level (2019)'

# Jumanji Welcome to the Jungle (2017)
move_to_deleted '/mnt/synology/rs-movies/Jumanji Welcome to the Jungle (2017)/Jumanji Welcome to the Jungle (2017) {imdb-tt2283362} [Bluray-1080p][DTS 5.1][x264].mkv' 'Jumanji Welcome to the Jungle (2017)'

# Jurassic Park (1993)
move_to_deleted '/mnt/synology/rs-movies/Jurassic Park (1993)/Jurassic Park (1993) {imdb-tt0107290} [Bluray-1080p][DTS-ES 6.1][x264].mkv' 'Jurassic Park (1993)'

# Jurassic Park III (2001)
move_to_deleted '/mnt/synology/rs-movies/Jurassic Park III (2001)/Jurassic Park III (2001) {imdb-tt0163025} [Bluray-1080p][DTS 5.1][x264].mkv' 'Jurassic Park III (2001)'

# Jurassic World (2015)
move_to_deleted '/mnt/synology/rs-movies/Jurassic World (2015)/Jurassic World (2015) {imdb-tt0369610} [Bluray-1080p][DTS 5.1][x264].mkv' 'Jurassic World (2015)'

# Jurassic World Dominion (2022)
move_to_deleted '/mnt/synology/rs-movies/Jurassic World Dominion (2022)/Jurassic World Dominion (2022) {imdb-tt8041270} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-CMRG.mkv' 'Jurassic World Dominion (2022)'

# Jurassic World Rebirth (2025)
move_to_deleted '/mnt/synology/rs-movies/#recycle/Jurassic World Rebirth (2025)/Jurassic World Rebirth (2025) {imdb-tt31036941} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-BYNDR.mkv' 'Jurassic World Rebirth (2025)'

# Juror #2 (2024)
move_to_deleted '/mnt/synology/rs-movies/Juror #2 (2024)/Juror #2 (2024) {imdb-tt27403986} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv' 'Juror #2 (2024)'

# Justice League (2017)
move_to_deleted '/mnt/synology/rs-movies/Justice League (2017)/Justice League (2017) {imdb-tt0974015} [Bluray-1080p][DTS 5.1][x264].mkv' 'Justice League (2017)'

# Justice League Crisis on Infinite Earths Part Three (2024)
move_to_deleted '/mnt/synology/rs-movies/Justice League Crisis on Infinite Earths Part Three (2024)/Justice League Crisis on Infinite Earths Part Three (2024) {imdb-tt30150917} [WEBDL-1080p][AC3 5.1][h264]-XEBEC.mkv' 'Justice League Crisis on Infinite Earths Part Three (2024)'

# Justice League Dark (2017)
move_to_deleted '/mnt/synology/rs-movies/Justice League Dark (2017)/Justice League Dark (2017) {imdb-tt2494376} [WEBDL-1080p][AC3 5.1][h264]-FGT.mkv' 'Justice League Dark (2017)'

# Justice League Dark Apokolips War (2020)
move_to_deleted '/mnt/synology/rs-movies/Justice League Dark Apokolips War (2020)/Justice League Dark Apokolips War (2020) {imdb-tt11079148} [WEBDL-1080p][AC3 5.1][x264].mkv' 'Justice League Dark Apokolips War (2020)'

# Justice League Doom (2012)
move_to_deleted '/mnt/synology/rs-movies/Justice League Doom (2012)/Justice League Doom (2012) {imdb-tt2027128} [WEBDL-1080p][EAC3 5.1][x264]-Kitsune.mkv' 'Justice League Doom (2012)'

# Justice League Gods and Monsters (2015)
move_to_deleted '/mnt/synology/rs-movies/Justice League Gods and Monsters (2015)/Justice League Gods and Monsters (2015) {imdb-tt4324302} [Bluray-1080p][AC3 5.1][x264].mkv' 'Justice League Gods and Monsters (2015)'

# Justice League Warworld (2023)
move_to_deleted '/mnt/synology/rs-movies/Justice League Warworld (2023)/Justice League Warworld (2023) {imdb-tt27687527} [WEBDL-1080p][AC3 5.1][h264]-LouLaVie.mkv' 'Justice League Warworld (2023)'

# Justice League x RWBY Super Heroes and Huntsmen Part One (2023)
move_to_deleted '/mnt/synology/rs-movies/Justice League x RWBY Super Heroes and Huntsmen Part One (2023)/Justice League x RWBY Super Heroes & Huntsmen, Part One (2023) {imdb-tt24548912} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-playWEB.mkv' 'Justice League x RWBY Super Heroes and Huntsmen Part One (2023)'

# K-PAX (2001) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/K-PAX (2001)/K-PAX (2001) {imdb-tt0272152} [HDTV-720p][DTS 5.1][x264].mkv' 'K-PAX (2001)'

# KPop Demon Hunters (2025)
move_to_deleted '/mnt/synology/rs-movies/KPop Demon Hunters (2025)/KPop Demon Hunters (2025) {imdb-tt14205554} [WEBDL-1080p][EAC3 Atmos 5.1][x264]-EDITH.mkv' 'KPop Demon Hunters (2025)'

# Kalki 2898-AD (2024)
move_to_deleted '/mnt/synology/rs-movies/Kalki 2898-AD (2024)/Kalki 2898-AD (2024) {imdb-tt12735488} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-XEBEC.mkv' 'Kalki 2898-AD (2024)'

# Kandahar (2023)
move_to_deleted '/mnt/synology/rs-movies/Kandahar (2023)/Kandahar (2023) {imdb-tt5761544} [MA][WEBDL-1080p][EAC3 5.1][x264]-HONE.mkv' 'Kandahar (2023)'

# Karate Kid Legends (2025)
move_to_deleted '/mnt/synology/rs-movies/Karate Kid Legends (2025)/Karate Kid Legends (2025) {imdb-tt1674782} [WEBDL-1080p][EAC3 5.1][h264]-PreciseCherubicHoatzinOfPoliteness.mkv' 'Karate Kid Legends (2025)'

# Karate Kid, The (1984)
move_to_deleted '/mnt/synology/rs-movies/Karate Kid, The (1984)/The Karate Kid (1984) {imdb-tt0087538} [Bluray-1080p][HDR10][EAC3 7.1][x265]-TDD.mkv' 'Karate Kid, The (1984)'

# Karate Kid, The (2010)
move_to_deleted '/mnt/synology/rs-movies/Karate Kid, The (2010)/The Karate Kid (2010) {imdb-tt1155076} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-GPRS.mkv' 'Karate Kid, The (2010)'

# Killers of the Flower Moon ()
move_to_deleted '/mnt/synology/rs-movies/Killers of the Flower Moon ()/Killers of the Flower Moon (2023) {imdb-tt5537002} [AMZN][WEBDL-1080p Proper][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Killers of the Flower Moon ()'

# Kindergarten Cop (1990)
move_to_deleted '/mnt/synology/rs-movies/Kindergarten Cop (1990)/Kindergarten Cop (1990) {imdb-tt0099938} [Bluray-1080p][DTS 2.0][x264].mkv' 'Kindergarten Cop (1990)'

# Kinds of Kindness (2024)
move_to_deleted '/mnt/synology/rs-movies/Kinds of Kindness (2024)/Kinds of Kindness (2024) {imdb-tt22408160} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Kinds of Kindness (2024)'

# King Richard (2021)
move_to_deleted '/mnt/synology/rs-movies/King Richard (2021)/King Richard (2021) {imdb-tt9620288} [HMAX][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv' 'King Richard (2021)'

# King of Killers (2023)
move_to_deleted '/mnt/synology/rs-movies/King of Killers (2023)/King of Killers (2023) {imdb-tt14057604} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-SCOPE.mkv' 'King of Killers (2023)'

# Kingdom of Heaven (2005)
move_to_deleted '/mnt/synology/rs-movies/Kingdom of Heaven (2005)/Kingdom of Heaven (2005) {imdb-tt0320661} [Bluray-1080p][DTS 5.1][x264].mkv' 'Kingdom of Heaven (2005)'

# Kingdom of the Planet of the Apes (2024)
move_to_deleted '/mnt/synology/rs-movies/Kingdom of the Planet of the Apes (2024)/Kingdom of the Planet of the Apes (2024) {imdb-tt11389872} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-ETHEL.mkv' 'Kingdom of the Planet of the Apes (2024)'

# Kingpin (1996)
move_to_deleted '/mnt/synology/rs-movies/Kingpin (1996)/Kingpin (1996) {imdb-tt0116778} {edition-Extended Cut} [Bluray-1080p Proper][AC3 5.1][x264]-BHDStudio.mp4' 'Kingpin (1996)'

# Kingsman The Secret Service (2014)
move_to_deleted '/mnt/synology/rs-movies/Kingsman The Secret Service (2014)/Kingsman The Secret Service (2015) {imdb-tt2802144} {edition-Uncut} [Bluray-1080p][DTS-ES 5.1][x264]-WiKi.mkv' 'Kingsman The Secret Service (2014)'

# Kiss of the Dragon (2001)
move_to_deleted '/mnt/synology/rs-movies/Kiss of the Dragon (2001)/Kiss of the Dragon (2001) {imdb-tt0271027} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Kiss of the Dragon (2001)'

# Knives Out (2019)
move_to_deleted '/mnt/synology/rs-movies/Knives Out (2019)/Knives Out (2019) {imdb-tt8946378} [Bluray-1080p][EAC3 5.1][x264]-LoRD.mkv' 'Knives Out (2019)'

# Knock Knock (2015)
move_to_deleted '/mnt/synology/rs-movies/Knock Knock (2015)/Knock Knock (2015) {imdb-tt3605418} [Remux-1080p][DTS-HD MA 5.1][h264]-KRaLiMaRKo.mkv' 'Knock Knock (2015)'

# Knock at the Cabin (2023)
move_to_deleted '/mnt/synology/rs-movies/Knock at the Cabin (2023)/Knock at the Cabin (2023) {imdb-tt15679400} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv' 'Knock at the Cabin (2023)'

# Knox Goes Away (2024)
move_to_deleted '/mnt/synology/rs-movies/Knox Goes Away (2024)/Knox Goes Away (2024) {imdb-tt20115766} [WEBDL-1080p][AC3 5.1][h264]-SLOT.mkv' 'Knox Goes Away (2024)'

# Kung Fu Panda 2 (2011)
move_to_deleted '/mnt/synology/rs-movies/Kung Fu Panda 2 (2011)/Kung Fu Panda 2 (2011) {imdb-tt1302011} [Bluray-1080p][AC3 5.1][x264].mkv' 'Kung Fu Panda 2 (2011)'

# Kung Fu Panda 3 (2016)
move_to_deleted '/mnt/synology/rs-movies/Kung Fu Panda 3 (2016)/Kung Fu Panda 3 (2016) {imdb-tt2267968} [WEBDL-1080p][AC3 5.1][h264]-CiNEMiX.mkv' 'Kung Fu Panda 3 (2016)'

# Kung Fu Panda 4 (2024)
move_to_deleted '/mnt/synology/rs-movies/Kung Fu Panda 4 (2024)/Kung Fu Panda 4 (2024) {imdb-tt21692408} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-ETHEL.mkv' 'Kung Fu Panda 4 (2024)'

# LEGO DC Super Hero Girls Brain Drain (2017) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/LEGO DC Super Hero Girls Brain Drain (2017)/LEGO DC Super Hero Girls Brain Drain (2017) {imdb-tt7158814} [WEBDL-720p][AC3 5.1][h264]-EVO.mkv' 'LEGO DC Super Hero Girls Brain Drain (2017)'

# LEGO Ninjago Movie, The (2017) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/LEGO Ninjago Movie, The (2017)/The Lego Ninjago Movie (2017) {imdb-tt3014284} [Bluray-720p][DTS 5.1][x264].mkv' 'LEGO Ninjago Movie, The (2017)'

# The Lego Star Wars Holiday Special (2020)
move_to_deleted '/mnt/synology/rs-movies/The Lego Star Wars Holiday Special (2020)/LEGO Star Wars Holiday Special (2020) {imdb-tt12885438} [WEBRip-1080p][AC3 5.1][x264].mkv' 'The Lego Star Wars Holiday Special (2020)'

# La Chimera (2023)
move_to_deleted '/mnt/synology/rs-movies/La Chimera (2023)/La Chimera (2023) {imdb-tt14561712} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CODROiPO.mkv' 'La Chimera (2023)'

# La Femme Nikita (1990)
move_to_deleted '/mnt/synology/rs-movies/La Femme Nikita (1990)/La Femme Nikita (1990) {imdb-tt0100263} [Bluray-1080p Proper][AC3 5.1][x264]-SADPANDA.mkv' 'La Femme Nikita (1990)'

# La La Land (2016)
move_to_deleted '/mnt/synology/rs-movies/La La Land (2016)/La La Land (2016) {imdb-tt3783958} [Bluray-1080p][AC3 5.1][x264]-LoRD.mkv' 'La La Land (2016)'

# Ladder 49 (2004) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Ladder 49 (2004)/Ladder 49 (2004) {imdb-tt0349710} [Bluray-720p][AC3 5.1][x264].mkv' 'Ladder 49 (2004)'

# Lagaan Once Upon a Time in India (2001)
move_to_deleted '/mnt/synology/rs-movies/Lagaan Once Upon a Time in India (2001)/Lagaan Once Upon a Time in India (2001) {imdb-tt0169102} [WEBRip-1080p][AC3 5.1][x264]-AMRAP.mkv' 'Lagaan Once Upon a Time in India (2001)'

# Lamb (2021)
move_to_deleted '/mnt/synology/rs-movies/Lamb (2021)/Lamb (2021) {imdb-tt9812474} [Bluray-1080p][EAC3 5.1][x264]-TayTO.mkv' 'Lamb (2021)'

# Land of Bad (2024)
move_to_deleted '/mnt/synology/rs-movies/Land of Bad (2024)/Land of Bad (2024) {imdb-tt19864802} [WEBDL-1080p Proper][EAC3 5.1][h264]-RABBITS.mkv' 'Land of Bad (2024)'

# Land of the Dead (2005)
move_to_deleted '/mnt/synology/rs-movies/Land of the Dead (2005)/Land of the Dead (2005) {imdb-tt0418819} [Bluray-1080p][DTS 5.1][x264]-de.mkv' 'Land of the Dead (2005)'

# Lara Croft Tomb Raider (2001)
move_to_deleted '/mnt/synology/rs-movies/Lara Croft Tomb Raider (2001)/Lara Croft Tomb Raider (2001) {imdb-tt0146316} [Bluray-1080p][AC3 5.1][x264].mkv' 'Lara Croft Tomb Raider (2001)'

# Last Action Hero (1993)
move_to_deleted '/mnt/synology/rs-movies/Last Action Hero (1993)/Last Action Hero (1993) {imdb-tt0107362} [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv' 'Last Action Hero (1993)'

# Last Breath (2025)
move_to_deleted '/mnt/synology/rs-movies/Last Breath (2025)/Last Breath (2025) {imdb-tt14403504} [MA][WEBDL-1080p Proper][EAC3 Atmos 5.1][x264]-BYNDR.mkv' 'Last Breath (2025)'

# Last Dragon, The (1985)
move_to_deleted '/mnt/synology/rs-movies/Last Dragon, The (1985)/The.Last.Dragon.1985.1080p.BluRay.DTS.x264-DON.mkv' 'Last Dragon, The (1985)'

# Last Night in Soho (2021)
move_to_deleted '/mnt/synology/rs-movies/Last Night in Soho (2021)/Last Night in Soho (2021) {imdb-tt9639470} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv' 'Last Night in Soho (2021)'

# Last Seen Alive (2022)
move_to_deleted '/mnt/synology/rs-movies/Last Seen Alive (2022)/Last Seen Alive (2022) {imdb-tt10242388} [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv' 'Last Seen Alive (2022)'

# Last Shoot Out (2021)
move_to_deleted '/mnt/synology/rs-movies/Last Shoot Out (2021)/Last Shoot Out (2021) {imdb-tt11833670} [Bluray-1080p][AC3 5.1][x264]-eMc2.mkv' 'Last Shoot Out (2021)'

# Last Starfighter, The (1984)
move_to_deleted '/mnt/synology/rs-movies/Last Starfighter, The (1984)/The Last Starfighter (1984) {imdb-tt0087597} {edition-25Th Anniversary Edition} [Bluray-1080p][AAC 2.0][x264]-ext.mkv' 'Last Starfighter, The (1984)'

# Last Straw (2024)
move_to_deleted '/mnt/synology/rs-movies/Last Straw (2024)/Last Straw (2024) {imdb-tt24249072} [AMZN][WEBDL-1080p Proper][EAC3 5.1][h264]-FLUX.mkv' 'Last Straw (2024)'

# Last Witch Hunter, The (2015)
move_to_deleted '/mnt/synology/rs-movies/Last Witch Hunter, The (2015)/The Last Witch Hunter (2015) {imdb-tt1618442} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-DKV.mkv' 'Last Witch Hunter, The (2015)'

# Last Word, The (2017) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Last Word, The (2017)/The Last Word (2017) {imdb-tt5023260} [Bluray-720p][AC3 5.1][x264]-CRiME.mkv' 'Last Word, The (2017)'

# Late Night with the Devil (2024)
move_to_deleted '/mnt/synology/rs-movies/Late Night with the Devil (2024)/Late Night with the Devil (2024) {imdb-tt14966898} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Late Night with the Devil (2024)'

# Laundromat, The (2019)
move_to_deleted '/mnt/synology/rs-movies/Laundromat, The (2019)/The Laundromat (2019) {imdb-tt5865326} [WEBDL-1080p][EAC3 5.1][x264]-NTG.mkv' 'Laundromat, The (2019)'

# Law Abiding Citizen (2009)
move_to_deleted '/mnt/synology/rs-movies/Law Abiding Citizen (2009)/Law Abiding Citizen (2009) {imdb-tt1197624} [HDTV-1080p][AC3 5.1][x264].mkv' 'Law Abiding Citizen (2009)'

# Lawrence of Arabia (1962)
move_to_deleted '/mnt/synology/rs-movies/Lawrence of Arabia (1962)/Lawrence of Arabia (1962) {imdb-tt0056172} [HDTV-1080p][DTS 5.1][x264].mkv' 'Lawrence of Arabia (1962)'

# Layover, The (2017)
move_to_deleted '/mnt/synology/rs-movies/Layover, The (2017)/The Layover (2017) {imdb-tt4565520} [WEBDL-1080p][EAC3 5.1][h264].mkv' 'Layover, The (2017)'

# Lean On Me (1989)
move_to_deleted '/mnt/synology/rs-movies/Lean On Me (1989)/Lean On Me (1989) {imdb-tt0097722} [AMZN][WEBDL-1080p][EAC3 2.0][x264]-alfaHD.mkv' 'Lean On Me (1989)'

# Leave the World Behind (2023)
move_to_deleted '/mnt/synology/rs-movies/Leave the World Behind (2023)/Leave the World Behind (2023) {imdb-tt12747748} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Leave the World Behind (2023)'

# Leaving Las Vegas (1995)
move_to_deleted '/mnt/synology/rs-movies/Leaving Las Vegas (1995)/Leaving Las Vegas (1995) {imdb-tt0113627} {edition-Unrated} [Bluray-1080p][DTS-HD MA 5.1][x264]-TUSAHD.mkv' 'Leaving Las Vegas (1995)'

# Lee (2024)
move_to_deleted '/mnt/synology/rs-movies/Lee (2024)/Lee (2024) {imdb-tt5112584} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Lee (2024)'

# Legends of the Fall (1994)
move_to_deleted '/mnt/synology/rs-movies/Legends of the Fall (1994)/Legends of the Fall (1994) {imdb-tt0110322} [Bluray-1080p][DTS 5.1][x264]-SbR.mkv' 'Legends of the Fall (1994)'

# Legion of Super-Heroes (2023)
move_to_deleted '/mnt/synology/rs-movies/Legion of Super-Heroes (2023)/Legion of Super-Heroes (2023) {imdb-tt22769820} [WEBDL-1080p][AC3 5.1][x264]-DKV.mkv' 'Legion of Super-Heroes (2023)'

# Leo (2023)
move_to_deleted '/mnt/synology/rs-movies/Leo (2023)/Leo (2023) {imdb-tt5755238} [WEBDL-1080p][EAC3 Atmos 5.1][x264]-EDITH.mkv' 'Leo (2023)'

# Let It Shine (2012)
move_to_deleted '/mnt/synology/rs-movies/Let It Shine (2012)/Let It Shine (2012) {imdb-tt2165933} {edition-Extended} [AMZN][WEBRip-1080p][EAC3 5.1][x264]-TVSmash.mkv' 'Let It Shine (2012)'

# Lethal Weapon (1987)
move_to_deleted '/mnt/synology/rs-movies/Lethal Weapon (1987)/Lethal Weapon (1987) {imdb-tt0093409} [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv' 'Lethal Weapon (1987)'

# Levels (2024)
move_to_deleted '/mnt/synology/rs-movies/Levels (2024)/Levels (2024) {imdb-tt10831486} [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Levels (2024)'

# Lewis Black - In God We Rust (2012)
move_to_deleted '/mnt/synology/rs-movies/Lewis Black - In God We Rust (2012)/Lewis Black In God We Rust (2012) {imdb-tt2271387} [Bluray-1080p][DTS 5.1][x264].mkv' 'Lewis Black - In God We Rust (2012)'

# Life (2017)
move_to_deleted '/mnt/synology/rs-movies/Life (2017)/Life (2017) {imdb-tt5442430} [Bluray-1080p][DTS 5.1][x264]-Geek.mkv' 'Life (2017)'

# Life Aquatic with Steve Zissou, The (2004)
move_to_deleted '/mnt/synology/rs-movies/Life Aquatic with Steve Zissou, The (2004)/The Life Aquatic with Steve Zissou (2004) {imdb-tt0362270} [Bluray-1080p][DTS 5.1][x264]-HD4U.mkv' 'Life Aquatic with Steve Zissou, The (2004)'

# Life in a Day (2011) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Life in a Day (2011)/Life in a Day (2011) {imdb-tt1687247} [Bluray-720p][DTS 5.1][x264]-WiKi.mkv' 'Life in a Day (2011)'

# Lift (2024)
move_to_deleted '/mnt/synology/rs-movies/Lift (2024)/Lift (2024) {imdb-tt14371878} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Lift (2024)'

# Lightyear (2022)
move_to_deleted '/mnt/synology/rs-movies/Lightyear (2022)/Lightyear (2022) {imdb-tt10298810} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-EVO.mkv' 'Lightyear (2022)'

# Lilo and Stitch (2002)
move_to_deleted '/mnt/synology/rs-movies/Lilo and Stitch (2002)/Lilo & Stitch (2002) {imdb-tt0275847} [Bluray-1080p][DTS 5.1][x264]-SbR.mkv' 'Lilo and Stitch (2002)'

# Lilo and Stitch (2025)
move_to_deleted '/mnt/synology/rs-movies/Lilo and Stitch (2025)/Lilo & Stitch (2025) {imdb-tt11655566} [WEBDL-1080p][EAC3 Atmos 5.1][x264]-BANDOLEROS.mkv' 'Lilo and Stitch (2025)'

# Lincoln (2012)
move_to_deleted '/mnt/synology/rs-movies/Lincoln (2012)/Lincoln (2012) {imdb-tt0443272} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Lincoln (2012)'

# Lion King 1½, The (2004)
move_to_deleted '/mnt/synology/rs-movies/Lion King 1½, The (2004)/The Lion King 1½ (2004) {imdb-tt0318403} [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv' 'Lion King 1½, The (2004)'

# Lion King, The (1994)
move_to_deleted '/mnt/synology/rs-movies/Lion King, The (1994)/The Lion King (1994) {imdb-tt0110357} [Bluray-1080p][DTS 5.1][x264].mkv' 'Lion King, The (1994)'

# Lion King, The (2019)
move_to_deleted '/mnt/synology/rs-movies/Lion King, The (2019)/The Lion King (2019) {imdb-tt6105098} [Bluray-1080p][HDR10][EAC3 Atmos 7.1][x265]-JM.mkv' 'Lion King, The (2019)'

# Lion in Winter, The (1968)
move_to_deleted '/mnt/synology/rs-movies/Lion in Winter, The (1968)/The Lion in Winter (1968) {imdb-tt0063227} [Bluray-1080p][FLAC 2.0][x264]-ADE.mkv' 'Lion in Winter, The (1968)'

# Lisa Frankenstein (2024)
move_to_deleted '/mnt/synology/rs-movies/Lisa Frankenstein (2024)/Lisa Frankenstein (2024) {imdb-tt21188080} [WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Lisa Frankenstein (2024)'

# Little Bone Lodge (2023)
move_to_deleted '/mnt/synology/rs-movies/Little Bone Lodge (2023)/Little Bone Lodge (2023) {imdb-tt19858164} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-THR.mkv' 'Little Bone Lodge (2023)'

# Little Dixie (2023)
move_to_deleted '/mnt/synology/rs-movies/Little Dixie (2023)/Little Dixie (2023) {imdb-tt13614388} [WEBRip-1080p][AAC 5.1][x264]-AOC.mkv' 'Little Dixie (2023)'

# The Little Mermaid (1989)
move_to_deleted '/mnt/synology/rs-movies/The Little Mermaid (1989)/The Little Mermaid (1989) {imdb-tt0097757} [WEBDL-1080p][PCM 2.0][x264].mkv' 'The Little Mermaid (1989)'

# Little Nicky (2000)
move_to_deleted '/mnt/synology/rs-movies/Little Nicky (2000)/Little Nicky (2000) {imdb-tt0185431} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Little Nicky (2000)'

# Little Things, The (2021)
move_to_deleted '/mnt/synology/rs-movies/Little Things, The (2021)/The Little Things (2021) {imdb-tt10016180} [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv' 'Little Things, The (2021)'

# Little Women (2019)
move_to_deleted '/mnt/synology/rs-movies/Little Women (2019)/Little Women (2019) {imdb-tt3281548} [WEBDL-1080p][EAC3 5.1][h264]-TEPES.mkv' 'Little Women (2019)'

# Locked (2025)
move_to_deleted '/mnt/synology/rs-movies/Locked (2025)/Locked (2025) {imdb-tt26671996} [WEBRip-1080p][AAC 5.1][x264]-LAMA.mp4' 'Locked (2025)'

# Locked Down (2021)
move_to_deleted '/mnt/synology/rs-movies/Locked Down (2021)/Locked Down (2021) {imdb-tt13061914} [WEBDL-1080p][AC3 5.1][h264]-MZABI.mkv' 'Locked Down (2021)'

# Locksmith, The (2023)
move_to_deleted '/mnt/synology/rs-movies/Locksmith, The (2023)/The Locksmith (2023) {imdb-tt15829724} [WEBDL-1080p][AC3 5.1][h264]-SMURF.mkv' 'Locksmith, The (2023)'

# Logan (2017)
move_to_deleted '/mnt/synology/rs-movies/Logan (2017)/Logan (2017) {imdb-tt3315342} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Logan (2017)'

# Logan Lucky (2017)
move_to_deleted '/mnt/synology/rs-movies/Logan Lucky (2017)/Logan Lucky (2017) {imdb-tt5439796} [Bluray-1080p][DTS 5.1][x264]-CHD.mkv' 'Logan Lucky (2017)'

# London Calling (2025)
move_to_deleted '/mnt/synology/rs-movies/London Calling (2025)/London Calling (2025) {imdb-tt30425872} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'London Calling (2025)'

# Lone Survivor (2013)
move_to_deleted '/mnt/synology/rs-movies/Lone Survivor (2013)/Lone Survivor (2013) {imdb-tt1091191} [Bluray-1080p][AC3 5.1][x264].mkv' 'Lone Survivor (2013)'

# Long Gone Heroes (2024)
move_to_deleted '/mnt/synology/rs-movies/Long Gone Heroes (2024)/Long Gone Heroes (2024) {imdb-tt6001846} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Long Gone Heroes (2024)'

# Long Kiss Goodnight, The (1996)
move_to_deleted '/mnt/synology/rs-movies/Long Kiss Goodnight, The (1996)/The Long Kiss Goodnight (1996) {imdb-tt0116908} [Bluray-1080p][AC3 5.1][x264]-ETH.mkv' 'Long Kiss Goodnight, The (1996)'

# Longest Yard, The (2005)
move_to_deleted '/mnt/synology/rs-movies/Longest Yard, The (2005)/The Longest Yard (2005) {imdb-tt0398165} [WEBDL-1080p][EAC3 5.1][x264].mkv' 'Longest Yard, The (2005)'

# Longlegs (2024)
move_to_deleted '/mnt/synology/rs-movies/Longlegs (2024)/Longlegs (2024) {imdb-tt23468450} [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Longlegs (2024)'

# Look Who\'s Back (2015) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Look Who\'s Back (2015)/Look Who\'s Back (2015) {imdb-tt4176826} [Bluray-720p Proper][DTS 5.1][x264]-usury.mkv' 'Look Who\'s Back (2015)'

# Lord of War (2005)
move_to_deleted '/mnt/synology/rs-movies/Lord of War (2005)/Lord of War (2005) {imdb-tt0399295} [Bluray-1080p][DTS-ES 6.1][x264]-HiDt.mkv' 'Lord of War (2005)'

# Lore (2012) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Lore (2012)/Lore (2012) {imdb-tt1996310} [Bluray-720p][DTS 5.1][x264].mkv' 'Lore (2012)'

# Lost Highway (1997)
move_to_deleted '/mnt/synology/rs-movies/Lost Highway (1997)/Lost Highway (1997) {imdb-tt0116922} [Bluray-1080p][AC3 5.1][x264].mkv' 'Lost Highway (1997)'

# Lost in the Stars (2023)
move_to_deleted '/mnt/synology/rs-movies/Lost in the Stars (2023)/Lost in the Stars (2023) {imdb-tt17507018} [WEBDL-1080p][MP3 2.0][h264]-OurTV.mp4' 'Lost in the Stars (2023)'

# Love Hard (2021)
move_to_deleted '/mnt/synology/rs-movies/Love Hard (2021)/Love Hard (2021) {imdb-tt10752004} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv' 'Love Hard (2021)'

# Love Hurts (2025)
move_to_deleted '/mnt/synology/rs-movies/Love Hurts (2025)/Love Hurts (2025) {imdb-tt30788842} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-APEX.mkv' 'Love Hurts (2025)'

# Love Lies Bleeding (2024)
move_to_deleted '/mnt/synology/rs-movies/Love Lies Bleeding (2024)/Love Lies Bleeding (2024) {imdb-tt19637052} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Love Lies Bleeding (2024)'

# Love Never Dies (2012) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Love Never Dies (2012)/Love Never Dies (2012) {imdb-tt2243393} [Bluray-720p][DTS 5.1][x264].mkv' 'Love Never Dies (2012)'

# Love and Monsters (2020)
move_to_deleted '/mnt/synology/rs-movies/Love and Monsters (2020)/Love and Monsters (2020) {imdb-tt2222042} [Bluray-1080p][EAC3 7.1][x264]-LoRD.mkv' 'Love and Monsters (2020)'

# Luca (2021)
move_to_deleted '/mnt/synology/rs-movies/Luca (2021)/Luca (2021) {imdb-tt12801262} [DSNP][WEBDL-1080p][EAC3 Atmos 5.1][h264]-CMRG.mkv' 'Luca (2021)'

# Luckiest Girl Alive (2022)
move_to_deleted '/mnt/synology/rs-movies/Luckiest Girl Alive (2022)/Luckiest Girl Alive (2022) {imdb-tt4595186} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv' 'Luckiest Girl Alive (2022)'

# Lyle, Lyle, Crocodile (2022)
move_to_deleted '/mnt/synology/rs-movies/Lyle, Lyle, Crocodile (2022)/Lyle, Lyle, Crocodile (2022) {imdb-tt14668630} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-SMURF.mkv' 'Lyle, Lyle, Crocodile (2022)'

# M3GAN 2.0 (2025)
move_to_deleted '/mnt/synology/rs-movies/M3GAN 2.0 (2025)/M3GAN 2.0 (2025) {imdb-tt26342662} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-KyoGo.mkv' 'M3GAN 2.0 (2025)'

# MLK+FBI (2020)
move_to_deleted '/mnt/synology/rs-movies/MLK+FBI (2020)/MLK+FBI (2020) {imdb-tt12801356} [WEBDL-1080p][EAC3 5.1][h264]-ISA.mkv' 'MLK+FBI (2020)'

# MaXXXine (2024)
move_to_deleted '/mnt/synology/rs-movies/MaXXXine (2024)/MaXXXine (2024) {imdb-tt22048412} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'MaXXXine (2024)'

# Mad God (2022)
move_to_deleted '/mnt/synology/rs-movies/Mad God (2022)/Mad God (2021) {imdb-tt15090124} [WEBDL-1080p][AAC 2.0][h264].mkv' 'Mad God (2022)'

# Mad Max Fury Road (2015)
move_to_deleted '/mnt/synology/rs-movies/Mad Max Fury Road (2015)/Mad Max Fury Road (2015) {imdb-tt1392190} [Bluray-1080p][HDR10][EAC3 7.1][x265]-D-Z0N3.mkv' 'Mad Max Fury Road (2015)'

# Madame Web (2024)
move_to_deleted '/mnt/synology/rs-movies/Madame Web (2024)/Madame Web (2024) {imdb-tt11057302} [WEBRip-1080p][AC3 5.1][x264].mp4' 'Madame Web (2024)'

# Made of Honor (2008)
move_to_deleted '/mnt/synology/rs-movies/Made of Honor (2008)/Made of Honor (2008) {imdb-tt0866439} [Bluray-1080p][EAC3 5.1][x264]-LoRD.mkv' 'Made of Honor (2008)'

# Maestro (2023)
move_to_deleted '/mnt/synology/rs-movies/Maestro (2023)/Maestro (2023) {imdb-tt5535276} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-playWEB.mkv' 'Maestro (2023)'

# Magnificent Seven, The (2016)
move_to_deleted '/mnt/synology/rs-movies/Magnificent Seven, The (2016)/The Magnificent Seven (2016) {imdb-tt2404435} [Bluray-1080p][DTS 5.1][x264]-TayTO.mkv' 'Magnificent Seven, The (2016)'

# Maleficent Mistress of Evil (2019)
move_to_deleted '/mnt/synology/rs-movies/Maleficent Mistress of Evil (2019)/Maleficent Mistress of Evil (2019) {imdb-tt4777008} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Maleficent Mistress of Evil (2019)'

# Maltese Falcon, The (1941)
move_to_deleted '/mnt/synology/rs-movies/Maltese Falcon, The (1941)/The Maltese Falcon (1941) {imdb-tt0033870} [Bluray-1080p][AC3 1.0][x264]-CtrlHD.mkv' 'Maltese Falcon, The (1941)'

# Mama (2013)
move_to_deleted '/mnt/synology/rs-movies/Mama (2013)/Mama (2013) {imdb-tt2023587} [Bluray-1080p][DTS 5.1][x264].mkv' 'Mama (2013)'

# Mamma Mia! Here We Go Again (2018)
move_to_deleted '/mnt/synology/rs-movies/Mamma Mia! Here We Go Again (2018)/Mamma Mia! Here We Go Again (2018) {imdb-tt6911608} [Bluray-1080p][AC3 5.1][x264]-LoRD.mkv' 'Mamma Mia! Here We Go Again (2018)'

# Man Called Otto, A (2022)
move_to_deleted '/mnt/synology/rs-movies/Man Called Otto, A (2022)/A Man Called Otto (2022) {imdb-tt7405458} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-CMRG.mkv' 'Man Called Otto, A (2022)'

# Man Who Fell to Earth, The (1976)
move_to_deleted '/mnt/synology/rs-movies/Man Who Fell to Earth, The (1976)/The Man Who Fell to Earth (1976) {imdb-tt0074851} [Bluray-1080p][AC3 2.0][x264]-CtrlHD.mkv' 'Man Who Fell to Earth, The (1976)'

# Man Who Knew Too Much, The (1956)
move_to_deleted '/mnt/synology/rs-movies/Man Who Knew Too Much, The (1956)/The Man Who Knew Too Much (1956) {imdb-tt0049470} [Bluray-1080p][FLAC 2.0][x264]-TayTO.mkv' 'Man Who Knew Too Much, The (1956)'

# Man of Steel (2013)
move_to_deleted '/mnt/synology/rs-movies/Man of Steel (2013)/Man of Steel (2013) {imdb-tt0770828} [Bluray-1080p][AC3 5.1][x264].mkv' 'Man of Steel (2013)'

# Man of Tai Chi (2013) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Man of Tai Chi (2013)/Man of Tai Chi (2013) {imdb-tt2016940} [Bluray-720p][DTS 5.1][x264].mkv' 'Man of Tai Chi (2013)'

# Man of the Year (2006)
move_to_deleted '/mnt/synology/rs-movies/Man of the Year (2006)/Man of the Year (2006) {imdb-tt0483726} [AMZN][WEBRip-1080p][EAC3 5.1][x264]-monkee.mkv' 'Man of the Year (2006)'

# Marcel the Shell with Shoes On (2022) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Marcel the Shell with Shoes On (2022)/Marcel the Shell with Shoes On (2022) {imdb-tt15339456} [Bluray-1080p][TrueHD Atmos 7.1][x264]-MiMiC.mkv' 'Marcel the Shell with Shoes On (2022)'

# Margaret (2011) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Margaret (2011)/Margaret (2011) {imdb-tt0466893} [Bluray-720p][AC3 5.1][x264].mkv' 'Margaret (2011)'

# Maria (2024)
move_to_deleted '/mnt/synology/rs-movies/Maria (2024)/Maria (2024) {imdb-tt22893404} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Maria (2024)'

# Marlowe (2023)
move_to_deleted '/mnt/synology/rs-movies/Marlowe (2023)/Marlowe (2023) {imdb-tt6722802} [MA][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv' 'Marlowe (2023)'

# Marry Me (2022)
move_to_deleted '/mnt/synology/rs-movies/Marry Me (2022)/Marry Me (2022) {imdb-tt10223460} [WEBDL-1080p][EAC3 5.1][x264]-EVO.mkv' 'Marry Me (2022)'

# Marry My Dead Body (2023)
move_to_deleted '/mnt/synology/rs-movies/Marry My Dead Body (2023)/Marry My Dead Body (2023) {imdb-tt22742964} [NF][WEBDL-1080p][EAC3 5.1][x264]-Kitsune.mkv' 'Marry My Dead Body (2023)'

# Mars Express (2023)
move_to_deleted '/mnt/synology/rs-movies/Mars Express (2023)/Mars Express (2023) {imdb-tt26915336} [WEBDL-1080p][EAC3 5.1][h264]-FW.mkv' 'Mars Express (2023)'

# Mary (2024)
move_to_deleted '/mnt/synology/rs-movies/Mary (2024)/Mary (2024) {imdb-tt32084246} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-Kitsune.mkv' 'Mary (2024)'

# Mary Poppins Returns (2018)
move_to_deleted '/mnt/synology/rs-movies/Mary Poppins Returns (2018)/Mary Poppins Returns (2018) {imdb-tt5028340} [Bluray-1080p][DV HDR10][EAC3 7.1][x265]-DON.mkv' 'Mary Poppins Returns (2018)'

# Mask, The (1994)
move_to_deleted '/mnt/synology/rs-movies/Mask, The (1994)/The Mask (1994) {imdb-tt0110475} [Bluray-1080p][DTS-ES 6.1][x264]-WiLDCAT.mkv' 'Mask, The (1994)'

# Master and Commander The Far Side of the World (2003)
move_to_deleted '/mnt/synology/rs-movies/Master and Commander The Far Side of the World (2003)/Master and Commander The Far Side of the World (2003) {imdb-tt0311113} [Bluray-1080p][DTS 5.1][x264]-FSiHD.mkv' 'Master and Commander The Far Side of the World (2003)'

# Materialists (2025)
move_to_deleted '/mnt/synology/rs-movies/Materialists (2025)/Materialists (2025) {imdb-tt30253473} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-SLOT.mkv' 'Materialists (2025)'

# Matilda (1996)
move_to_deleted '/mnt/synology/rs-movies/Matilda (1996)/Matilda (1996) {imdb-tt0117008} [Bluray-1080p][AC3 5.1][x264]-Friday.mkv' 'Matilda (1996)'

# Matrix Resurrections, The (2021)
move_to_deleted '/mnt/synology/rs-movies/Matrix Resurrections, The (2021)/The.Matrix.Resurrections.2021.1080p.BluRay.DD+7.1.x264-iFT.mkv' 'Matrix Resurrections, The (2021)'

# Max Payne (2008) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Max Payne (2008)/Max Payne (2008) {imdb-tt0467197} [Bluray-720p][DTS 5.1][x264].mkv' 'Max Payne (2008)'

# May December (2023)
move_to_deleted '/mnt/synology/rs-movies/May December (2023)/May December (2023) {imdb-tt13651794} [NF][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv' 'May December (2023)'

# Maz Jobrani Immigrant (2017)
move_to_deleted '/mnt/synology/rs-movies/Maz Jobrani Immigrant (2017)/Maz Jobrani Immigrant (2017) {imdb-tt7164714} [WEBRip-1080p][AC3 5.1][x264]-strife.mkv' 'Maz Jobrani Immigrant (2017)'

# Mean Girls (2004)
move_to_deleted '/mnt/synology/rs-movies/Mean Girls (2004)/Mean Girls (2004) {imdb-tt0377092} [Bluray-1080p][AC3 5.1][h264]-CtrlHD.mkv' 'Mean Girls (2004)'

# Mechanic Resurrection (2016) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Mechanic Resurrection (2016)/Mechanic Resurrection (2016) {imdb-tt3522806} [Bluray-720p][AC3 5.1][x264].mkv' 'Mechanic Resurrection (2016)'

# Meet Dave (2008)
move_to_deleted '/mnt/synology/rs-movies/Meet Dave (2008)/Meet Dave (2008) {imdb-tt0765476} [NF][WEBDL-1080p][EAC3 5.1][x264]-NINJACENTRAL.mkv' 'Meet Dave (2008)'

# Meet the Parents (2000)
move_to_deleted '/mnt/synology/rs-movies/Meet the Parents (2000)/Meet the Parents (2000) {imdb-tt0212338} [Bluray-1080p][DTS 5.1][x264].mkv' 'Meet the Parents (2000)'

# Meg 2 The Trench (2023)
move_to_deleted '/mnt/synology/rs-movies/Meg 2 The Trench (2023)/Meg 2 The Trench (2023) {imdb-tt9224104} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Meg 2 The Trench (2023)'

# Megalopolis (2024)
move_to_deleted '/mnt/synology/rs-movies/Megalopolis (2024)/Megalopolis (2024) {imdb-tt10128846} [AMZN][WEBDL-1080p Proper][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Megalopolis (2024)'

# Mektoub, My Love Canto Uno (2017)
move_to_deleted '/mnt/synology/rs-movies/Mektoub, My Love Canto Uno (2017)/Mektoub, My Love Canto Uno (2017) {imdb-tt6121444} [Bluray-1080p][DTS 5.1][x264]-DuSS.mkv' 'Mektoub, My Love Canto Uno (2017)'

# Memoir of a Snail (2024)
move_to_deleted '/mnt/synology/rs-movies/Memoir of a Snail (2024)/Memoir of a Snail (2024) {imdb-tt23770030} [WEBDL-1080p Proper][EAC3 5.1][h264]-FLUX.mkv' 'Memoir of a Snail (2024)'

# Memory (2022)
move_to_deleted '/mnt/synology/rs-movies/Memory (2022)/Memory (2022) {imdb-tt11827628} [WEBRip-1080p][AC3 5.1][x264]-EVO.mkv' 'Memory (2022)'

# Men in Black (1997)
move_to_deleted '/mnt/synology/rs-movies/Men in Black (1997)/Men in Black (1997) {imdb-tt0119654} [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv' 'Men in Black (1997)'

# Men In Black II (2002)
move_to_deleted '/mnt/synology/rs-movies/Men In Black II (2002)/Men in Black II (2002) {imdb-tt0120912} [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv' 'Men In Black II (2002)'

# Men in Black International (2019)
move_to_deleted '/mnt/synology/rs-movies/Men in Black International (2019)/Men in Black International (2019) {imdb-tt2283336} [WEBDL-1080p][EAC3 5.1][h264].mkv' 'Men in Black International (2019)'

# Men of Honor (2000)
move_to_deleted '/mnt/synology/rs-movies/Men of Honor (2000)/Men of Honor (2000) {imdb-tt0203019} [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv' 'Men of Honor (2000)'

# Menace II Society (1993)
move_to_deleted '/mnt/synology/rs-movies/Menace II Society (1993)/Menace II Society (1993) {imdb-tt0107554} {edition-Directors Cut} [Bluray-1080p][AC3 5.1][x264]-CiNEFiLE.mkv' 'Menace II Society (1993)'

# Menu, The (2022)
move_to_deleted '/mnt/synology/rs-movies/Menu, The (2022)/The Menu (2022) {imdb-tt9764362} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv' 'Menu, The (2022)'

# Metro Manila (2013) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Metro Manila (2013)/Metro Manila (2013) {imdb-tt1845838} [Bluray-720p][AC3 5.1][x264]-EbP.mkv' 'Metro Manila (2013)'

# Mickey 17 (2025)
move_to_deleted '/mnt/synology/rs-movies/Mickey 17 (2025)/Mickey 17 (2025) {imdb-tt12299608} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-BYNDR.mkv' 'Mickey 17 (2025)'

# Midnight Sky, The (2020)
move_to_deleted '/mnt/synology/rs-movies/Midnight Sky, The (2020)/The Midnight Sky (2020) {imdb-tt10539608} [WEBDL-1080p][EAC3 Atmos 5.1][x264]-EVO.mkv' 'Midnight Sky, The (2020)'

# Midway (2019)
move_to_deleted '/mnt/synology/rs-movies/Midway (2019)/Midway (2019) {imdb-tt6924650} [Remux-1080p][TrueHD Atmos 7.1][h264].mkv' 'Midway (2019)'

# Migration (2023)
move_to_deleted '/mnt/synology/rs-movies/Migration (2023)/Migration (2023) {imdb-tt6495056} [WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Migration (2023)'

# Mike and Dave Need Wedding Dates (2016)
move_to_deleted '/mnt/synology/rs-movies/Mike and Dave Need Wedding Dates (2016)/Mike and Dave Need Wedding Dates (2016) {imdb-tt2823054} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-PiRaTeS.mkv' 'Mike and Dave Need Wedding Dates (2016)'

# Miller\'s Crossing (1990)
move_to_deleted '/mnt/synology/rs-movies/Miller\'s Crossing (1990)/Miller\'s Crossing (1990) {imdb-tt0100150} [WEBDL-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv' 'Miller\'s Crossing (1990)'

# Millers Girl (2024)
move_to_deleted '/mnt/synology/rs-movies/Millers Girl (2024)/Miller\'s Girl (2024) {imdb-tt8310486} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Millers Girl (2024)'

# Minions The Rise of Gru (2022)
move_to_deleted '/mnt/synology/rs-movies/Minions The Rise of Gru (2022)/Minions The Rise of Gru (2022) {imdb-tt5113044} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv' 'Minions The Rise of Gru (2022)'

# Miracle on 34th Street (1947) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Miracle on 34th Street (1947)/Miracle on 34th Street (1947) {imdb-tt0039628} [Bluray-1080p][DTS 5.1][x264]-CiNEFiLE.mkv' 'Miracle on 34th Street (1947)'

# Miss Peregrine\'s Home for Peculiar Children (2016)
move_to_deleted '/mnt/synology/rs-movies/Miss Peregrine\'s Home for Peculiar Children (2016)/Miss Peregrine\'s Home for Peculiar Children (2016) {imdb-tt1935859} [Bluray-1080p][HDR10][EAC3 7.1][x265]-NCmt.mkv' 'Miss Peregrine\'s Home for Peculiar Children (2016)'

# Missing (2023)
move_to_deleted '/mnt/synology/rs-movies/Missing (2023)/Missing (2023) {imdb-tt10855768} [MA][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv' 'Missing (2023)'

# Mission Impossible - Fallout (2018)
move_to_deleted '/mnt/synology/rs-movies/Mission Impossible - Fallout (2018)/Mission Impossible - Fallout (2018) {imdb-tt4912910} [Bluray-1080p][AC3 5.1][x264].mkv' 'Mission Impossible - Fallout (2018)'

# Mission Impossible Rogue Nation (2015)
move_to_deleted '/mnt/synology/rs-movies/Mission Impossible Rogue Nation (2015)/Mission Impossible - Rogue Nation (2015) {imdb-tt2381249} [WEBDL-1080p][AC3 2.0][h264]-TWA.mkv' 'Mission Impossible Rogue Nation (2015)'

# Mississippi Burning (1988)
move_to_deleted '/mnt/synology/rs-movies/Mississippi Burning (1988)/Mississippi Burning (1988) {imdb-tt0095647} [Bluray-1080p][HDR10][FLAC 2.0][x265]-BRUTE.mkv' 'Mississippi Burning (1988)'

# Mitchells vs. The Machines, The (2021)
move_to_deleted '/mnt/synology/rs-movies/Mitchells vs. The Machines, The (2021)/The Mitchells vs. the Machines (2021) {imdb-tt7979580} [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv' 'Mitchells vs. The Machines, The (2021)'

# Moana (2016)
move_to_deleted '/mnt/synology/rs-movies/Moana (2016)/Moana (2016) {imdb-tt3521164} [WEBDL-1080p][AAC 2.0][AV1].mkv' 'Moana (2016)'

# Moana 2 (2024)
move_to_deleted '/mnt/synology/rs-movies/Moana 2 (2024)/Moana 2 (2024) {imdb-tt13622970} [WEBDL-1080p Proper][EAC3 7.1][h264]-YOLAND.mkv' 'Moana 2 (2024)'

# Mob Land (2023)
move_to_deleted '/mnt/synology/rs-movies/Mob Land (2023)/Mob Land (2023) {imdb-tt20424130} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-ChipsAHoy.mkv' 'Mob Land (2023)'

# Money Plane (2020)
move_to_deleted '/mnt/synology/rs-movies/Money Plane (2020)/Money Plane (2020) {imdb-tt7286966} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Money Plane (2020)'

# Monkey Man (2024)
move_to_deleted '/mnt/synology/rs-movies/Monkey Man (2024)/Monkey Man (2024) {imdb-tt9214772} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Monkey Man (2024)'

# Monster Hunter (2020)
move_to_deleted '/mnt/synology/rs-movies/Monster Hunter (2020)/Monster Hunter (2020) {imdb-tt6475714} [AMZN][WEBDL-1080p Proper][EAC3 5.1][h264]-NTG.mkv' 'Monster Hunter (2020)'

# Monster Island (2017)
move_to_deleted '/mnt/synology/rs-movies/Monster Island (2017)/Monster Island (2017) {imdb-tt6269658} [WEBDL-1080p][AC3 5.1][x264]-strife.mkv' 'Monster Island (2017)'

# Monster Squad, The (1987)
move_to_deleted '/mnt/synology/rs-movies/Monster Squad, The (1987)/The Monster Squad 1987 1080p BluRay DTS x264-CtrlHD.mkv' 'Monster Squad, The (1987)'

# Monster Summer (2024)
move_to_deleted '/mnt/synology/rs-movies/Monster Summer (2024)/Monster Summer (2024) {imdb-tt3954936} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'Monster Summer (2024)'

# Monster Trucks (2016)
move_to_deleted '/mnt/synology/rs-movies/Monster Trucks (2016)/Monster Trucks (2016) {imdb-tt3095734} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Monster Trucks (2016)'

# Monster\'s Ball (2001)
move_to_deleted '/mnt/synology/rs-movies/Monster\'s Ball (2001)/Monster\'s Ball (2001) {imdb-tt0285742} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Monster\'s Ball (2001)'

# Month by the Lake, A (1995)
move_to_deleted '/mnt/synology/rs-movies/Month by the Lake, A (1995)/A Month by the Lake (1995) {imdb-tt0113849} [AMZN][WEBRip-1080p][EAC3 2.0][x264]-TEPES.mkv' 'Month by the Lake, A (1995)'

# Monty Python and the Holy Grail (1975)
move_to_deleted '/mnt/synology/rs-movies/Monty Python and the Holy Grail (1975)/Monty Python and the Holy Grail (1975) {imdb-tt0071853} [WEBDL-1080p][AAC 2.0][AV1].mkv' 'Monty Python and the Holy Grail (1975)'

# Moon (2009)
move_to_deleted '/mnt/synology/rs-movies/Moon (2009)/The Twilight Saga New Moon (2009) {imdb-tt1259571} [Bluray-1080p][AC3 5.1][x264].mkv' 'Moon (2009)'

# Moonfall (2022)
move_to_deleted '/mnt/synology/rs-movies/Moonfall (2022)/Moonfall (2022) {imdb-tt5834426} [WEBDL-1080p][EAC3 5.1][x264]-EVO.mkv' 'Moonfall (2022)'

# Moulin Rouge! (2001)
move_to_deleted '/mnt/synology/rs-movies/Moulin Rouge! (2001)/Moulin Rouge! (2001) {imdb-tt0203009} [Bluray-1080p][DTS 5.1][x264]-xander.mkv' 'Moulin Rouge! (2001)'

# Mr. Monks Last Case A Monk Movie (2023)
move_to_deleted '/mnt/synology/rs-movies/Mr. Monks Last Case A Monk Movie (2023)/Mr. Monk\'s Last Case A Monk Movie (2023) {imdb-tt27145269} [WEBDL-1080p][EAC3 5.1][h264]-DiMEPiECE.mkv' 'Mr. Monks Last Case A Monk Movie (2023)'

# Mrs. Doubtfire (1993)
move_to_deleted '/mnt/synology/rs-movies/Mrs. Doubtfire (1993)/Mrs.Doubtfire.1993.REPACK.Bluray.1080p.DD5.1.x264-BHDStudio.mp4' 'Mrs. Doubtfire (1993)'

# Mufasa The Lion King (2024)
move_to_deleted '/mnt/synology/rs-movies/Mufasa The Lion King (2024)/Mufasa The Lion King (2024) {imdb-tt13186482} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-KiNGOFTHEJUNGLE.mkv' 'Mufasa The Lion King (2024)'

# Mulan (2020)
move_to_deleted '/mnt/synology/rs-movies/Mulan (2020)/Mulan (2020) {imdb-tt4566758} [Bluray-1080p][DTS-HD MA 7.1][x264]-CHD.mkv' 'Mulan (2020)'

# The Mule (2018)
move_to_deleted '/mnt/synology/rs-movies/The Mule (2018)/The Mule (2018) {imdb-tt7959026} [WEBDL-1080p][AC3 5.1][h264].mkv' 'The Mule (2018)'

# Mulholland Dr. (2001)
move_to_deleted '/mnt/synology/rs-movies/Mulholland Dr. (2001)/Mulholland Drive (2001) {imdb-tt0166924} [Bluray-1080p][DV HDR10][EAC3 5.1][x265]-c0kE.mkv' 'Mulholland Dr. (2001)'

# Mummies (2023)
move_to_deleted '/mnt/synology/rs-movies/Mummies (2023)/Mummies (2023) {imdb-tt23177868} [HMAX][WEBDL-1080p][AC3 5.1][x264]-DKV.mkv' 'Mummies (2023)'

# Murder Mystery (2019)
move_to_deleted '/mnt/synology/rs-movies/Murder Mystery (2019)/Murder Mystery (2019) {imdb-tt1618434} [NF][WEBDL-1080p][EAC3 5.1][x264]-NTG.mkv' 'Murder Mystery (2019)'

# Murder Mystery 2 (2023)
move_to_deleted '/mnt/synology/rs-movies/Murder Mystery 2 (2023)/Murder Mystery 2 (2023) {imdb-tt15255288} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv' 'Murder Mystery 2 (2023)'

# Murder Party (2007)
move_to_deleted '/mnt/synology/rs-movies/Murder Party (2007)/Murder Party (2007) {imdb-tt0878695} [NF][WEBDL-1080p][AC3 5.1][x264]-NTG.mkv' 'Murder Party (2007)'

# Murder at Yellowstone City (2022)
move_to_deleted '/mnt/synology/rs-movies/Murder at Yellowstone City (2022)/Murder at Yellowstone City (2022) {imdb-tt11552344} [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv' 'Murder at Yellowstone City (2022)'

# Murder on the Orient Express (2017)
move_to_deleted '/mnt/synology/rs-movies/Murder on the Orient Express (2017)/Murder on the Orient Express (2017) {imdb-tt3402236} [Bluray-1080p][DTS-ES 5.1][x264].mkv' 'Murder on the Orient Express (2017)'

# Murina (2022)
move_to_deleted '/mnt/synology/rs-movies/Murina (2022)/Murina (2022) {imdb-tt8434110} [WEBDL-1080p][AAC 2.0][x264]-KUCHU.mkv' 'Murina (2022)'

# Must Love Dogs (2005)
move_to_deleted '/mnt/synology/rs-movies/Must Love Dogs (2005)/Must Love Dogs (2005) {imdb-tt0417001} [AMZN][WEBDL-1080p][EAC3 5.1][h264].mkv' 'Must Love Dogs (2005)'

# Muzzle (2023)
move_to_deleted '/mnt/synology/rs-movies/Muzzle (2023)/Muzzle (2023) {imdb-tt17663876} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-SCOPE.mkv' 'Muzzle (2023)'

# My Best Friend\'s Girl (2008) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/My Best Friend\'s Girl (2008)/My Best Friend\'s Girl (2008) {imdb-tt1046163} [Bluray-720p][DTS 5.1][x264].mkv' 'My Best Friend\'s Girl (2008)'

# My Big Fat Greek Wedding (2002) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/My Big Fat Greek Wedding (2002)/My Big Fat Greek Wedding (2002) {imdb-tt0259446} [Bluray-720p][DTS 5.1][x264].mkv' 'My Big Fat Greek Wedding (2002)'

# My Big Fat Greek Wedding 3 (2023)
move_to_deleted '/mnt/synology/rs-movies/My Big Fat Greek Wedding 3 (2023)/My Big Fat Greek Wedding 3 (2023) {imdb-tt21103300} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'My Big Fat Greek Wedding 3 (2023)'

# My Fair Lady (1964)
move_to_deleted '/mnt/synology/rs-movies/My Fair Lady (1964)/My Fair Lady (1964) {imdb-tt0058385} [Bluray-1080p][AC3 5.1][x264].mkv' 'My Fair Lady (1964)'

# Naked Gun 2½ The Smell of Fear, The (1991)
move_to_deleted '/mnt/synology/rs-movies/Naked Gun 2½ The Smell of Fear, The (1991)/The Naked Gun 2½ The Smell of Fear (1991) {imdb-tt0102510} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Naked Gun 2½ The Smell of Fear, The (1991)'

# Naked Gun From the Files of Police Squad!, The (1988)
move_to_deleted '/mnt/synology/rs-movies/Naked Gun From the Files of Police Squad!, The (1988)/The Naked Gun From the Files of Police Squad! (1988) {imdb-tt0095705} [Bluray-1080p][DTS 5.1][x264]-FoRM.mkv' 'Naked Gun From the Files of Police Squad!, The (1988)'

# Nanny (2022)
move_to_deleted '/mnt/synology/rs-movies/Nanny (2022)/Nanny (2022) {imdb-tt10931784} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Nanny (2022)'

# Narvik (2022)
move_to_deleted '/mnt/synology/rs-movies/Narvik (2022)/Narvik (2022) {imdb-tt9737876} [NF][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv' 'Narvik (2022)'

# National Lampoon\'s European Vacation (1985) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/National Lampoon\'s European Vacation (1985)/National Lampoon\'s European Vacation (1985) {imdb-tt0089670} [Bluray-720p][AC3 1.0][x264]-CtrlHD.mkv' 'National Lampoon\'s European Vacation (1985)'

# Natural Born Killers (1994)
move_to_deleted '/mnt/synology/rs-movies/Natural Born Killers (1994)/Natural Born Killers (1994) {imdb-tt0110632} {edition-Directors Cut} [Bluray-1080p][DTS 5.1][x264]-NTb.mkv' 'Natural Born Killers (1994)'

# Nefarious (2023)
move_to_deleted '/mnt/synology/rs-movies/Nefarious (2023)/Nefarious (2023) {imdb-tt14537248} [AMZN][WEBDL-1080p][EAC3 2.0][h264]-FLUX.mkv' 'Nefarious (2023)'

# Never Let Go (2024)
move_to_deleted '/mnt/synology/rs-movies/Never Let Go (2024)/Never Let Go (2024) {imdb-tt14415204} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Never Let Go (2024)'

# New Mutants, The (2020)
move_to_deleted '/mnt/synology/rs-movies/New Mutants, The (2020)/The New Mutants (2020) {imdb-tt4682266} [Bluray-1080p][EAC3 7.1][x264]-LoRD.mkv' 'New Mutants, The (2020)'

# News of the World (2020)
move_to_deleted '/mnt/synology/rs-movies/News of the World (2020)/News of the World (2020) {imdb-tt6878306} [WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv' 'News of the World (2020)'

# Next Goal Wins (2023)
move_to_deleted '/mnt/synology/rs-movies/Next Goal Wins (2023)/Next Goal Wins (2023) {imdb-tt10767052} [WEBDL-1080p Proper][EAC3 5.1][x264]-FLUX.mkv' 'Next Goal Wins (2023)'

# Nice Guys, The (2016)
move_to_deleted '/mnt/synology/rs-movies/Nice Guys, The (2016)/The Nice Guys (2016) {imdb-tt3799694} [Bluray-1080p][DTS 5.1][x264]-DON.mkv' 'Nice Guys, The (2016)'

# Night Hunter (2019)
move_to_deleted '/mnt/synology/rs-movies/Night Hunter (2019)/Night Hunter (2019) {imdb-tt6533240} [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv' 'Night Hunter (2019)'

# Night Teeth (2021)
move_to_deleted '/mnt/synology/rs-movies/Night Teeth (2021)/Night Teeth (2021) {imdb-tt10763820} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-EVO.mkv' 'Night Teeth (2021)'

# Night of the Demons (1988)
move_to_deleted '/mnt/synology/rs-movies/Night of the Demons (1988)/Night of the Demons (1988) {imdb-tt0093624} {edition-Collectors} [Bluray-1080p][DTS 5.1][x264]-MaG.mkv' 'Night of the Demons (1988)'

# Night of the Hunted (2023)
move_to_deleted '/mnt/synology/rs-movies/Night of the Hunted (2023)/Night of the Hunted (2023) {imdb-tt23642744} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Night of the Hunted (2023)'

# Nightmare Alley (2021)
move_to_deleted '/mnt/synology/rs-movies/Nightmare Alley (2021)/Nightmare Alley (2021) {imdb-tt7740496} [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv' 'Nightmare Alley (2021)'

# No Escape (2015) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/No Escape (2015)/No Escape (2015) {imdb-tt1781922} [Bluray-720p][DTS 5.1][x264].mkv' 'No Escape (2015)'

# No Hard Feelings (2023)
move_to_deleted '/mnt/synology/rs-movies/No Hard Feelings (2023)/No Hard Feelings (2023) {imdb-tt15671028} [MA][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv' 'No Hard Feelings (2023)'

# No Man of God (2021)
move_to_deleted '/mnt/synology/rs-movies/No Man of God (2021)/No Man of God (2021) {imdb-tt13507778} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv' 'No Man of God (2021)'

# No Sudden Move (2021)
move_to_deleted '/mnt/synology/rs-movies/No Sudden Move (2021)/No Sudden Move (2021) {imdb-tt11525644} [HMAX][WEBDL-1080p][AC3 5.1][x264]-EVO.mkv' 'No Sudden Move (2021)'

# No Time to Die (2021)
move_to_deleted '/mnt/synology/rs-movies/No Time to Die (2021)/No Time to Die (2021) {imdb-tt2382320} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv' 'No Time to Die (2021)'

# No Way Out (1987)
move_to_deleted '/mnt/synology/rs-movies/No Way Out (1987)/No Way Out (1987) {imdb-tt0093640} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-GPRS.mkv' 'No Way Out (1987)'

# No Way Up (2024)
move_to_deleted '/mnt/synology/rs-movies/No Way Up (2024)/No Way Up (2024) {imdb-tt16253418} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'No Way Up (2024)'

# Nobody (2021)
move_to_deleted '/mnt/synology/rs-movies/Nobody (2021)/Nobody (2021) {imdb-tt7888964} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv' 'Nobody (2021)'

# Nobody 2 (2025)
move_to_deleted '/mnt/synology/rs-movies/Nobody 2 (2025)/Nobody 2 (2025) {imdb-tt28996126} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-BYNDR.mkv' 'Nobody 2 (2025)'

# Nocturnal Animals (2016) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Nocturnal Animals (2016)/Nocturnal Animals (2016) {imdb-tt4550098} [Bluray-720p][DTS 5.1][x264]-IDE.mkv' 'Nocturnal Animals (2016)'

# Noel Diary, The (2022)
move_to_deleted '/mnt/synology/rs-movies/Noel Diary, The (2022)/The Noel Diary (2022) {imdb-tt13007592} [WEBRip-1080p][AAC 5.1][x264]-LAMA.mp4' 'Noel Diary, The (2022)'

# Non-Stop (2014) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Non-Stop (2014)/Non-Stop (2014) {imdb-tt2024469} [Bluray-720p][DTS 5.1][x264].mkv' 'Non-Stop (2014)'

# Nonnas (2025) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Nonnas (2025)/Nonnas (2025) {imdb-tt28309594} [WEBDL-720p][EAC3 Atmos 5.1][x264]-SYLiX.mkv' 'Nonnas (2025)'

# Nope (2022)
move_to_deleted '/mnt/synology/rs-movies/Nope (2022)/Nope (2022) {imdb-tt10954984} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Nope (2022)'

# North by Northwest (1959)
move_to_deleted '/mnt/synology/rs-movies/North by Northwest (1959)/North by Northwest (1959) {imdb-tt0053125} [Bluray-1080p][AC3 5.1][x264]-EbP.mkv' 'North by Northwest (1959)'

# Nosferatu (2024)
move_to_deleted '/mnt/synology/rs-movies/Nosferatu (2024)/Nosferatu (2024) {imdb-tt5040012} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-APEX.mkv' 'Nosferatu (2024)'

# Novocaine (2025)
move_to_deleted '/mnt/synology/rs-movies/Novocaine (2025)/Novocaine (2025) {imdb-tt29603959} [WEBDL-1080p][EAC3 5.1][h264]-ETHEL.mkv' 'Novocaine (2025)'

# Now You See Me 2 (2016)
move_to_deleted '/mnt/synology/rs-movies/Now You See Me 2 (2016)/Now You See Me 2 (2016) {imdb-tt3110958} [Bluray-1080p][DV HDR10][EAC3 7.1][x265]-LEGi0N.mp4' 'Now You See Me 2 (2016)'

# Nutcracker and the Four Realms, The (2018)
move_to_deleted '/mnt/synology/rs-movies/Nutcracker and the Four Realms, The (2018)/The Nutcracker and the Four Realms (2018) {imdb-tt5523010} [Bluray-1080p][EAC3 5.1][x264]-LoRD.mkv' 'Nutcracker and the Four Realms, The (2018)'

# Oblivion (2013)
move_to_deleted '/mnt/synology/rs-movies/Oblivion (2013)/Oblivion (2013) {imdb-tt1483013} {edition-Open Matte} [WEBDL-1080p][DTS 5.1][x264].mkv' 'Oblivion (2013)'

# Observe and Report (2009)
move_to_deleted '/mnt/synology/rs-movies/Observe and Report (2009)/Observe and Report (2009) {imdb-tt1197628} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv' 'Observe and Report (2009)'

# Occupation Rainfall (2021)
move_to_deleted '/mnt/synology/rs-movies/Occupation Rainfall (2021)/Occupation Rainfall (2020) {imdb-tt8615822} [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv' 'Occupation Rainfall (2021)'

# Ocean\'s Eight (2018)
move_to_deleted '/mnt/synology/rs-movies/Ocean\'s Eight (2018)/Ocean\'s Eight (2018) {imdb-tt5164214} [Bluray-1080p][AC3 5.1][x264].mkv' 'Ocean\'s Eight (2018)'

# Ocean\'s Eleven (2001)
move_to_deleted '/mnt/synology/rs-movies/Ocean\'s Eleven (2001)/Ocean\'s Eleven (2001) {imdb-tt0240772} [Bluray-1080p][AC3 5.1][x264]-HiDt.mkv' 'Ocean\'s Eleven (2001)'

# Ocean\'s Thirteen (2007)
move_to_deleted '/mnt/synology/rs-movies/Ocean\'s Thirteen (2007)/Ocean\'s Thirteen (2007) {imdb-tt0496806} [Bluray-1080p][AC3 5.1][x264]-HiDt.mkv' 'Ocean\'s Thirteen (2007)'

# October Sky (1999)
move_to_deleted '/mnt/synology/rs-movies/October Sky (1999)/October Sky (1999) {imdb-tt0132477} [WEBDL-1080p][EAC3 2.0][x264].mkv' 'October Sky (1999)'

# Oddity (2024)
move_to_deleted '/mnt/synology/rs-movies/Oddity (2024)/Oddity (2024) {imdb-tt26470109} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'Oddity (2024)'

# Office Christmas Party (2016)
move_to_deleted '/mnt/synology/rs-movies/Office Christmas Party (2016)/Office Christmas Party (2016) {imdb-tt1711525} {edition-Unrated} [Bluray-1080p][DTS 5.1][x264]-KASHMiR.mkv' 'Office Christmas Party (2016)'

# Official Secrets (2019)
move_to_deleted '/mnt/synology/rs-movies/Official Secrets (2019)/Official Secrets (2019) {imdb-tt5431890} [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv' 'Official Secrets (2019)'

# Old (2021)
move_to_deleted '/mnt/synology/rs-movies/Old (2021)/Old (2021) {imdb-tt10954652} [WEBDL-1080p][AC3 5.1][x264]-EVO.mkv' 'Old (2021)'

# Old Dads (2023)
move_to_deleted '/mnt/synology/rs-movies/Old Dads (2023)/Old Dads (2023) {imdb-tt18394190} [NF][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv' 'Old Dads (2023)'

# Old Guard, The (2020)
move_to_deleted '/mnt/synology/rs-movies/Old Guard, The (2020)/The Old Guard (2020) {imdb-tt7556122} [NF][WEBRip-1080p][EAC3 Atmos 5.1][x264]-NTb.mkv' 'Old Guard, The (2020)'

# Old Guy (2024)
move_to_deleted '/mnt/synology/rs-movies/Old Guy (2024)/Old Guy (2024) {imdb-tt26442053} [WEBDL-1080p][AC3 5.1][h264]-KBOX.mkv' 'Old Guy (2024)'

# Old School (2003)
move_to_deleted '/mnt/synology/rs-movies/Old School (2003)/Old School (2003) {imdb-tt0302886} [Bluray-1080p][AC3 5.1][x264].mkv' 'Old School (2003)'

# Old Way, The (2023)
move_to_deleted '/mnt/synology/rs-movies/Old Way, The (2023)/The Old Way (2023) {imdb-tt8593824} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Old Way, The (2023)'

# Oliver! (1968)
move_to_deleted '/mnt/synology/rs-movies/Oliver! (1968)/Oliver! (1968) {imdb-tt0063385} [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv' 'Oliver! (1968)'

# Omni Loop (2024)
move_to_deleted '/mnt/synology/rs-movies/Omni Loop (2024)/Omni Loop (2024) {imdb-tt28150132} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Omni Loop (2024)'

# On a Wing and a Prayer (2023)
move_to_deleted '/mnt/synology/rs-movies/On a Wing and a Prayer (2023)/On a Wing and a Prayer (2023) {imdb-tt13929998} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-dBBd.mkv' 'On a Wing and a Prayer (2023)'

# On the Rocks (2020)
move_to_deleted '/mnt/synology/rs-movies/On the Rocks (2020)/On the Rocks (2020) {imdb-tt9606374} [WEBRip-1080p][DTS-HD MA 5.1][h264]-CREATiVE24.mkv' 'On the Rocks (2020)'

# Once Upon a Time in America (1984)
move_to_deleted '/mnt/synology/rs-movies/Once Upon a Time in America (1984)/Once Upon a Time in America (1984) {imdb-tt0087843} [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv' 'Once Upon a Time in America (1984)'

# Once Upon a Time in the West (1968)
move_to_deleted '/mnt/synology/rs-movies/Once Upon a Time in the West (1968)/Once Upon a Time in the West (1968) {imdb-tt0064116} [Bluray-1080p][DTS 5.1][x264].mkv' 'Once Upon a Time in the West (1968)'

# One Night in Miami. (2021)
move_to_deleted '/mnt/synology/rs-movies/One Night in Miami. (2021)/One Night in Miami. (2020) {imdb-tt10612922} [WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv' 'One Night in Miami. (2021)'

# One Ranger (2023)
move_to_deleted '/mnt/synology/rs-movies/One Ranger (2023)/One Ranger (2023) {imdb-tt23037488} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'One Ranger (2023)'

# One Shot (2021)
move_to_deleted '/mnt/synology/rs-movies/One Shot (2021)/One Shot (2021) {imdb-tt14199590} [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv' 'One Shot (2021)'

# Only the River Flows (2023)
move_to_deleted '/mnt/synology/rs-movies/Only the River Flows (2023)/Only the River Flows (2023) {imdb-tt27590147} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-ERBiUM.mkv' 'Only the River Flows (2023)'

# Onward (2020)
move_to_deleted '/mnt/synology/rs-movies/Onward (2020)/Onward (2020) {imdb-tt7146812} [WEBDL-1080p][EAC3 5.1][x264]-BLUTONiUM.mkv' 'Onward (2020)'

# Operation Finale (2018)
move_to_deleted '/mnt/synology/rs-movies/Operation Finale (2018)/Operation Finale (2018) {imdb-tt5208252} [Bluray-1080p][DTS 5.1][x264]-CHD.mkv' 'Operation Finale (2018)'

# Oppenheimer (2023)
move_to_deleted '/mnt/synology/rs-movies/Oppenheimer (2023)/Oppenheimer (2023) {imdb-tt15398776} [Remux-1080p][DTS-HD MA 5.1][AVC]-FraMeSToR.mkv' 'Oppenheimer (2023)'

# Opus (2025)
move_to_deleted '/mnt/synology/rs-movies/Opus (2025)/Opus (2025) {imdb-tt29929565} [WEBDL-1080p][EAC3 5.1][h264]-ETHEL.mkv' 'Opus (2025)'

# Out of Sight (1998)
move_to_deleted '/mnt/synology/rs-movies/Out of Sight (1998)/Out of Sight (1998) {imdb-tt0120780} [Bluray-1080p][DTS 5.1][x264]-tranc.mkv' 'Out of Sight (1998)'

# The Outfit (2022)
move_to_deleted '/mnt/synology/rs-movies/The Outfit (2022)/The Outfit (2022) {imdb-tt14114802} [Bluray-1080p][EAC3 5.1][x264]-SPHD.mkv' 'The Outfit (2022)'

# Outpost, The (2020)
move_to_deleted '/mnt/synology/rs-movies/Outpost, The (2020)/Outpost (2020) {imdb-tt3748390} {edition-Director\'s Cut} [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv' 'Outpost, The (2020)'

# Outside the Wire (2021)
move_to_deleted '/mnt/synology/rs-movies/Outside the Wire (2021)/Outside the Wire (2021) {imdb-tt10451914} [WEBRip-1080p][DTS-HD MA 5.1][h264]-CREATiVE24.mkv' 'Outside the Wire (2021)'

# Outsiders, The (1983)
move_to_deleted '/mnt/synology/rs-movies/Outsiders, The (1983)/The Outsiders (1983) {imdb-tt0086066} {edition-Directors Cut} [Bluray-1080p][EAC3 4.1][x264]-LoRD.mkv' 'Outsiders, The (1983)'

# Overboard (2018)
move_to_deleted '/mnt/synology/rs-movies/Overboard (2018)/Overboard (2018) {imdb-tt1563742} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Overboard (2018)'

# Overlord (2018)
move_to_deleted '/mnt/synology/rs-movies/Overlord (2018)/Overlord (2018) {imdb-tt4530422} [Bluray-1080p][AC3 5.1][x264]-DRONES.mkv' 'Overlord (2018)'

# Oxygen (2021)
move_to_deleted '/mnt/synology/rs-movies/Oxygen (2021)/Oxygen (2021) {imdb-tt6341832} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-EVO.mkv' 'Oxygen (2021)'

# Oz - The Great and Powerful (2013)
move_to_deleted '/mnt/synology/rs-movies/Oz - The Great and Powerful (2013)/Oz the Great and Powerful (2013) {imdb-tt1623205} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Oz - The Great and Powerful (2013)'

# PAW Patrol The Mighty Movie (2023)
move_to_deleted '/mnt/synology/rs-movies/PAW Patrol The Mighty Movie (2023)/PAW Patrol The Mighty Movie (2023) {imdb-tt15837338} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'PAW Patrol The Mighty Movie (2023)'

# PAW Patrol The Movie (2021)
move_to_deleted '/mnt/synology/rs-movies/PAW Patrol The Movie (2021)/PAW Patrol The Movie (2021) {imdb-tt11832046} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv' 'PAW Patrol The Movie (2021)'

# Pacific Rim Uprising (2018)
move_to_deleted '/mnt/synology/rs-movies/Pacific Rim Uprising (2018)/Pacific Rim Uprising (2018) {imdb-tt2557478} [Bluray-1080p][AC3 5.1][x264].mkv' 'Pacific Rim Uprising (2018)'

# Paddington in Peru (2024)
move_to_deleted '/mnt/synology/rs-movies/Paddington in Peru (2024)/Paddington in Peru (2024) {imdb-tt5822536} [WEBDL-1080p][EAC3 5.1][h264]-AOC.mkv' 'Paddington in Peru (2024)'

# Pain Hustlers (2023)
move_to_deleted '/mnt/synology/rs-movies/Pain Hustlers (2023)/Pain Hustlers (2023) {imdb-tt15257160} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Pain Hustlers (2023)'

# Pale Blue Eye, The (2022)
move_to_deleted '/mnt/synology/rs-movies/Pale Blue Eye, The (2022)/The Pale Blue Eye (2022) {imdb-tt14138650} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv' 'Pale Blue Eye, The (2022)'

# Pan (2015)
move_to_deleted '/mnt/synology/rs-movies/Pan (2015)/Pan (2015) {imdb-tt3332064} [Bluray-1080p][AC3 5.1][x264]-TayTO.mkv' 'Pan (2015)'

# Panama (2022)
move_to_deleted '/mnt/synology/rs-movies/Panama (2022)/Panama (2022) {imdb-tt4029412} [MA][WEBDL-1080p][AC3 5.1][h264]-EVO.mkv' 'Panama (2022)'

# Paranormal Activity 2 (2010) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Paranormal Activity 2 (2010)/Paranormal Activity 2 (2010) {imdb-tt1536044} [Bluray-720p][AAC 5.1][x264].mp4' 'Paranormal Activity 2 (2010)'

# Parker (2013) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Parker (2013)/Parker (2013) {imdb-tt1904996} [Bluray-720p][DTS 5.1][x264].mkv' 'Parker (2013)'

# Passages (2023)
move_to_deleted '/mnt/synology/rs-movies/Passages (2023)/Passages (2023) {imdb-tt16252698} [AMZN][WEBDL-1080p][EAC3 2.0][h264]-XEBEC.mkv' 'Passages (2023)'

# Passengers (2016)
move_to_deleted '/mnt/synology/rs-movies/Passengers (2016)/Passengers (2016) {imdb-tt1355644} [Bluray-1080p][DTS 5.1][x264].mkv' 'Passengers (2016)'

# Patriot Games (1992)
move_to_deleted '/mnt/synology/rs-movies/Patriot Games (1992)/Patriot Games (1992) {imdb-tt0105112} [Bluray-1080p][DTS 5.1][x264]-HiDt.mkv' 'Patriot Games (1992)'

# Paws of Fury The Legend of Hank (2022)
move_to_deleted '/mnt/synology/rs-movies/Paws of Fury The Legend of Hank (2022)/Paws of Fury The Legend of Hank (2022) {imdb-tt4428398} [WEBDL-1080p][EAC3 5.1][h264]-SMURF.mkv' 'Paws of Fury The Legend of Hank (2022)'

# Peaceful Warrior (2006)
move_to_deleted '/mnt/synology/rs-movies/Peaceful Warrior (2006)/Peaceful Warrior (2006) {imdb-tt0438315} [Bluray-1080p][AC3 5.1][x264]-FGT.mkv' 'Peaceful Warrior (2006)'

# Pearl (2022)
move_to_deleted '/mnt/synology/rs-movies/Pearl (2022)/Pearl (2022) {imdb-tt18925334} [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv' 'Pearl (2022)'

# Pee-wees Big Adventure (1985) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Pee-wees Big Adventure (1985)/Pee-wee\'s Big Adventure (1985) {imdb-tt0089791} [Bluray-720p][AC3 5.1][x264]-TBB.mkv' 'Pee-wees Big Adventure (1985)'

# Percy Jackson & the Olympians - The Lightning Thief (2010) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Percy Jackson & the Olympians - The Lightning Thief (2010)/Percy Jackson & the Olympians The Lightning Thief (2010) {imdb-tt0814255} [Bluray-720p][DTS 5.1][x264].mkv' 'Percy Jackson & the Olympians - The Lightning Thief (2010)'

# Perpetrator (2023)
move_to_deleted '/mnt/synology/rs-movies/Perpetrator (2023)/Perpetrator (2023) {imdb-tt24082454} [WEBDL-1080p][EAC3 5.1][h264]-EDITH.mkv' 'Perpetrator (2023)'

# Pet Sematary (1989)
move_to_deleted '/mnt/synology/rs-movies/Pet Sematary (1989)/Pet Sematary (1989) {imdb-tt0098084} [WEBDL-1080p][AAC 2.0][AV1].mkv' 'Pet Sematary (1989)'

# Pet Sematary Bloodlines (2023)
move_to_deleted '/mnt/synology/rs-movies/Pet Sematary Bloodlines (2023)/Pet Sematary Bloodlines (2023) {imdb-tt14145436} [WEBDL-1080p][EAC3 Atmos 5.1][x264]-HUZZAH.mkv' 'Pet Sematary Bloodlines (2023)'

# Peter Pan (1953)
move_to_deleted '/mnt/synology/rs-movies/Peter Pan (1953)/Peter Pan (1953) {imdb-tt0046183} [HDTV-1080p][DTS 5.1][x264].mkv' 'Peter Pan (1953)'

# Peter Rabbit (2018)
move_to_deleted '/mnt/synology/rs-movies/Peter Rabbit (2018)/Peter Rabbit (2018) {imdb-tt5117670} [Bluray-1080p][DTS 5.1][x264]-SbR.mkv' 'Peter Rabbit (2018)'

# Philadelphia (1993)
move_to_deleted '/mnt/synology/rs-movies/Philadelphia (1993)/Philadelphia (1993) {imdb-tt0107818} [Remux-1080p][DTS-HD MA 5.1][AVC]-KRaLiMaRKo.mkv' 'Philadelphia (1993)'

# Pig (2021)
move_to_deleted '/mnt/synology/rs-movies/Pig (2021)/Pig (2021) {imdb-tt11003218} [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv' 'Pig (2021)'

# Pineapple Express (2008)
move_to_deleted '/mnt/synology/rs-movies/Pineapple Express (2008)/Pineapple Express (2008) {imdb-tt0910936} [Bluray-1080p][HDR10][EAC3 5.1][h265].mkv' 'Pineapple Express (2008)'

# Pinocchio (2019)
move_to_deleted '/mnt/synology/rs-movies/Pinocchio (2019)/Pinocchio 2019 Bluray-1080p.mkv' 'Pinocchio (2019)'

# Pinocchio (2022)
move_to_deleted '/mnt/synology/rs-movies/Pinocchio (2022)/Pinocchio (2022) {imdb-tt4593060} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-KOGi.mkv' 'Pinocchio (2022)'

# Pirates of the Caribbean - Dead Man\'s Chest (2006)
move_to_deleted '/mnt/synology/rs-movies/Pirates of the Caribbean - Dead Man\'s Chest (2006)/Pirates of the Caribbean Dead Man\'s Chest (2006) {imdb-tt0383574} [Bluray-1080p][AC3 5.1][x264].mkv' 'Pirates of the Caribbean - Dead Man\'s Chest (2006)'

# Pirates of the Caribbean Dead Men Tell No Tales (2017)
move_to_deleted '/mnt/synology/rs-movies/Pirates of the Caribbean Dead Men Tell No Tales (2017)/Pirates of the Caribbean Dead Men Tell No Tales (2017) {imdb-tt1790809} [Bluray-1080p][DTS 5.1][x264].mkv' 'Pirates of the Caribbean Dead Men Tell No Tales (2017)'

# Pitch Black (2000)
move_to_deleted '/mnt/synology/rs-movies/Pitch Black (2000)/Pitch Black (2000) {imdb-tt0134847} {edition-Director\'s Cut} [Bluray-1080p][HDR10][EAC3 5.1][x265]-DON.mkv' 'Pitch Black (2000)'

# Plane (2023)
move_to_deleted '/mnt/synology/rs-movies/Plane (2023)/Plane (2023) {imdb-tt5884796} [WEBDL-1080p][EAC3 5.1][h264]-NAISU.mkv' 'Plane (2023)'

# Planet 51 (2009) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Planet 51 (2009)/Planet 51 (2009) {imdb-tt0762125} [Bluray-720p][AAC 5.1][x264].mp4' 'Planet 51 (2009)'

# Planet of the Apes (2001) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Planet of the Apes (2001)/Planet of the Apes (1968) {imdb-tt0063442} [Bluray-720p][DTS 5.1][x264].mkv' 'Planet of the Apes (2001)'

# Plankton The Movie (2025)
move_to_deleted '/mnt/synology/rs-movies/Plankton The Movie (2025)/Plankton The Movie (2025) {imdb-tt32560777} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-Kitsune.mkv' 'Plankton The Movie (2025)'

# Pleasantville (1998) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Pleasantville (1998)/Pleasantville (1998) {imdb-tt0120789} [Bluray-720p][DTS 5.1][x264].mkv' 'Pleasantville (1998)'

# Please Don\'t Destroy The Treasure of Foggy Mountain (2023)
move_to_deleted '/mnt/synology/rs-movies/Please Don\'t Destroy The Treasure of Foggy Mountain (2023)/Please Don\'t Destroy The Treasure of Foggy Mountain (2023) {imdb-tt21335356} [PCOK][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv' 'Please Don\'t Destroy The Treasure of Foggy Mountain (2023)'

# Point Break (2015)
move_to_deleted '/mnt/synology/rs-movies/Point Break (2015)/Point Break (2015) {imdb-tt2058673} [Bluray-1080p][HDR10][EAC3 7.1][x265]-DON.mkv' 'Point Break (2015)'

# Polar (2019)
move_to_deleted '/mnt/synology/rs-movies/Polar (2019)/Polar (2019) {imdb-tt4139588} [WEBRip-1080p Proper][EAC3 Atmos 5.1][x264]-DEFLATE.mkv' 'Polar (2019)'

# The Polar Express (2004) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/The Polar Express (2004)/The Polar Express (2004) {imdb-tt0338348} [HDTV-720p][AC3 5.1][x264].mkv' 'The Polar Express (2004)'

# Poltergeist (1982)
move_to_deleted '/mnt/synology/rs-movies/Poltergeist (1982)/Poltergeist (1982) {imdb-tt0084516} [Bluray-1080p][DV HDR10][EAC3 5.1][x265]-DON.mkv' 'Poltergeist (1982)'

# Poseidon (2006)
move_to_deleted '/mnt/synology/rs-movies/Poseidon (2006)/Poseidon (2006) {imdb-tt0409182} [Bluray-1080p][DTS 5.1][x264]-SbR.mkv' 'Poseidon (2006)'

# Poser (2021)
move_to_deleted '/mnt/synology/rs-movies/Poser (2021)/Poser (2021) {imdb-tt11175956} [WEBDL-1080p][EAC3 5.1][h264]-DiMEPiECE.mkv' 'Poser (2021)'

# Post Grad (2009)
move_to_deleted '/mnt/synology/rs-movies/Post Grad (2009)/Post Grad (2009) {imdb-tt1142433} [DSNP][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Post Grad (2009)'

# Power of One, The (1992)
move_to_deleted '/mnt/synology/rs-movies/Power of One, The (1992)/The Power of One (1992) {imdb-tt0105159} [WEBDL-1080p][EAC3 2.0][h264].mkv' 'Power of One, The (1992)'

# Predators (2010)
move_to_deleted '/mnt/synology/rs-movies/Predators (2010)/Predators (2010) {imdb-tt1424381} {edition-Open Matte} [AMZN][WEBDL-1080p][DTS 5.1][h264].mkv' 'Predators (2010)'

# Prey (2024)
move_to_deleted '/mnt/synology/rs-movies/Prey (2024)/Prey (2024) {imdb-tt27682129} [WEBDL-1080p][EAC3 5.1][h264]-M-NLsubs.mkv' 'Prey (2024)'

# Primal Fear (1996)
move_to_deleted '/mnt/synology/rs-movies/Primal Fear (1996)/Primal Fear (1996) {imdb-tt0117381} [Bluray-1080p][DTS 5.1][x264]-NTb.mkv' 'Primal Fear (1996)'

# Prince of Egypt, The (1998) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Prince of Egypt, The (1998)/The Prince of Egypt (1998) {imdb-tt0120794} [WEBDL-720p][AC3 5.1][h264]-CtrlHD.mkv' 'Prince of Egypt, The (1998)'

# Priscilla (2023)
move_to_deleted '/mnt/synology/rs-movies/Priscilla (2023)/Priscilla (2023) {imdb-tt22041854} [Bluray-1080p][EAC3 5.1][x264]-c0kE.mkv' 'Priscilla (2023)'

# Prisoner of War (2025)
move_to_deleted '/mnt/synology/rs-movies/Prisoner of War (2025)/Prisoner of War (2025) {imdb-tt33057137} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'Prisoner of War (2025)'

# Prisoners of the Ghostland (2021)
move_to_deleted '/mnt/synology/rs-movies/Prisoners of the Ghostland (2021)/Prisoners of the Ghostland (2021) {imdb-tt6372694} [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv' 'Prisoners of the Ghostland (2021)'

# Private Parts (1997)
move_to_deleted '/mnt/synology/rs-movies/Private Parts (1997)/Private Parts (1997) {imdb-tt0119951} [WEBDL-1080p][EAC3 5.1][h264].mkv' 'Private Parts (1997)'

# Project Gemini (2022)
move_to_deleted '/mnt/synology/rs-movies/Project Gemini (2022)/Project \'Gemini\' (2022) {imdb-tt5656994} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv' 'Project Gemini (2022)'

# Prometheus (2012)
move_to_deleted '/mnt/synology/rs-movies/Prometheus (2012)/Prometheus (2012) {imdb-tt1446714} [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv' 'Prometheus (2012)'

# Promising Young Woman (2020)
move_to_deleted '/mnt/synology/rs-movies/Promising Young Woman (2020)/Promising Young Woman (2020) {imdb-tt9620292} [WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv' 'Promising Young Woman (2020)'

# Prophecy, The (1995)
move_to_deleted '/mnt/synology/rs-movies/Prophecy, The (1995)/The.Prophecy.1995.1080p.BluRay.x264-PSYCHD.mkv' 'Prophecy, The (1995)'

# Psycho (1960)
move_to_deleted '/mnt/synology/rs-movies/Psycho (1960)/Psycho (1960) {imdb-tt0054215} {edition-Uncut} [Bluray-1080p][AC3 5.1][x264]-LoRD.mkv' 'Psycho (1960)'

# Public, The (2019)
move_to_deleted '/mnt/synology/rs-movies/Public, The (2019)/Public Enemies (2009) {imdb-tt1152836} [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv' 'Public, The (2019)'

# Pulp Fiction (1994)
move_to_deleted '/mnt/synology/rs-movies/Pulp Fiction (1994)/Pulp Fiction (1994) {imdb-tt0110912} [Bluray-1080p][DV HDR10][EAC3 5.1][x265]-NTb.mkv' 'Pulp Fiction (1994)'

# Punisher, The (1989) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Punisher, The (1989)/The Punisher (1989) {imdb-tt0098141} [Bluray-720p][AC3 2.0][x264].mkv' 'Punisher, The (1989)'

# Purge, The (2013)
move_to_deleted '/mnt/synology/rs-movies/Purge, The (2013)/Purge (2013) {imdb-tt1557843} [Bluray-1080p][HDR10][EAC3 7.1][x265]-CtrlHD.mkv' 'Purge, The (2013)'

# Pusher (2012) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Pusher (2012)/Pusher (1996) {imdb-tt0117407} [Bluray-720p][DTS 5.1][x264].mkv' 'Pusher (2012)'

# Puss in Boots (2011)
move_to_deleted '/mnt/synology/rs-movies/Puss in Boots (2011)/Puss in Boots (2011) {imdb-tt0448694} [Bluray-1080p][AC3 5.1][x264]-EbP.mkv' 'Puss in Boots (2011)'

# Puss in Boots The Last Wish (2022)
move_to_deleted '/mnt/synology/rs-movies/Puss in Boots The Last Wish (2022)/Puss in Boots The Last Wish (2022) {imdb-tt3915174} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv' 'Puss in Boots The Last Wish (2022)'

# Queen Rock Montreal (2024)
move_to_deleted '/mnt/synology/rs-movies/Queen Rock Montreal (2024)/We Will Rock You (1982) {imdb-tt0084892} {edition-Remastered} [DSNP][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Queen Rock Montreal (2024)'

# Queenpins (2021)
move_to_deleted '/mnt/synology/rs-movies/Queenpins (2021)/Queenpins (2021) {imdb-tt9054192} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv' 'Queenpins (2021)'

# Quicksand (2023)
move_to_deleted '/mnt/synology/rs-movies/Quicksand (2023)/Quicksand (2023) {imdb-tt19056070} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-LouLaVie.mkv' 'Quicksand (2023)'

# A Quiet Place Part II (2021)
move_to_deleted '/mnt/synology/rs-movies/A Quiet Place Part II (2021)/A Quiet Place Part II (2021) {imdb-tt8332922} [Bluray-1080p][EAC3 7.1][x264]-LoRD.mkv' 'A Quiet Place Part II (2021)'

# Quiet Place, A (2018)
move_to_deleted '/mnt/synology/rs-movies/Quiet Place, A (2018)/A Quiet Place (2018) {imdb-tt6644200} [Bluray-1080p][AC3 5.1][x264].mkv' 'Quiet Place, A (2018)'

# Red 2 (2013)
move_to_deleted '/mnt/synology/rs-movies/Red 2 (2013)/RED 2 (2013) {imdb-tt1821694} [Bluray-1080p][DTS 5.1][x264].mkv' 'Red 2 (2013)'

# Race for Glory Audi vs Lancia (2024)
move_to_deleted '/mnt/synology/rs-movies/Race for Glory Audi vs Lancia (2024)/Race for Glory Audi vs Lancia (2024) {imdb-tt20112600} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Race for Glory Audi vs Lancia (2024)'

# Radical (2023)
move_to_deleted '/mnt/synology/rs-movies/Radical (2023)/Radical (2023) {imdb-tt14570440} [WEBDL-1080p][EAC3 2.0][h264]-PSTX.mkv' 'Radical (2023)'

# Raging Bull (1980)
move_to_deleted '/mnt/synology/rs-movies/Raging Bull (1980)/Raging Bull (1980) {imdb-tt0081398} [Remux-1080p][DTS-HD MA 5.1][AVC]-FraMeSToR.mkv' 'Raging Bull (1980)'

# Ralph Breaks the Internet (2018)
move_to_deleted '/mnt/synology/rs-movies/Ralph Breaks the Internet (2018)/Ralph Breaks the Internet (2018) {imdb-tt5848272} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Ralph Breaks the Internet (2018)'

# Rambo First Blood (1982)
move_to_deleted '/mnt/synology/rs-movies/Rambo First Blood (1982)/First Blood (1982) {imdb-tt0083944} [Bluray-1080p][DTS 5.1][x264].mkv' 'Rambo First Blood (1982)'

# Ratatouille (2007)
move_to_deleted '/mnt/synology/rs-movies/Ratatouille (2007)/Ratatouille (2007) {imdb-tt0382932} [Bluray-1080p Proper][DTS 5.1][x264]-hv.mkv' 'Ratatouille (2007)'

# Raw Deal (1986)
move_to_deleted '/mnt/synology/rs-movies/Raw Deal (1986)/Raw Deal (1986) {imdb-tt0091828} [Remux-1080p Proper][DTS-HD MA 5.1][AVC]-KRaLiMaRKo.mkv' 'Raw Deal (1986)'

# Raya and the Last Dragon (2021)
move_to_deleted '/mnt/synology/rs-movies/Raya and the Last Dragon (2021)/Raya and the Last Dragon (2021) {imdb-tt5109280} [DSNP][WEBDL-1080p][EAC3 5.1][h264]-TOMMY.mkv' 'Raya and the Last Dragon (2021)'

# Ready Player One (2018)
move_to_deleted '/mnt/synology/rs-movies/Ready Player One (2018)/Ready Player One (2018) {imdb-tt1677720} [Bluray-1080p][DTS 5.1][x264].mkv' 'Ready Player One (2018)'

# Reality (2023)
move_to_deleted '/mnt/synology/rs-movies/Reality (2023)/Reality (2023) {imdb-tt24068064} [WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Reality (2023)'

# Red Cliff (2008) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Red Cliff (2008)/Red Cliff (2008) {imdb-tt0425637} [Bluray-720p][DTS 5.1][x264]-ESiR.mkv' 'Red Cliff (2008)'

# Red One (2024)
move_to_deleted '/mnt/synology/rs-movies/Red One (2024)/Red One (2024) {imdb-tt14948432} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Red One (2024)'

# Red Right Hand (2024)
move_to_deleted '/mnt/synology/rs-movies/Red Right Hand (2024)/Red Right Hand (2024) {imdb-tt19244260} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'Red Right Hand (2024)'

# Red Sonja (2025)
move_to_deleted '/mnt/synology/rs-movies/Red Sonja (2025)/Red Sonja (2025) {imdb-tt0800175} - [WEBDL-1080p][EAC3 5.1][h264]-AOC.mkv' 'Red Sonja (2025)'

# Ref, The (1994)
move_to_deleted '/mnt/synology/rs-movies/Ref, The (1994)/The Ref (1994) {imdb-tt0110955} [AMZN][WEBRip-1080p][EAC3 5.1][x264]-hV.mkv' 'Ref, The (1994)'

# Reminiscence (2021)
move_to_deleted '/mnt/synology/rs-movies/Reminiscence (2021)/Reminiscence (2021) {imdb-tt3272066} [HMAX][WEBDL-1080p][EAC3 Atmos 5.1][x264]-EVO.mkv' 'Reminiscence (2021)'

# Renfield (2023)
move_to_deleted '/mnt/synology/rs-movies/Renfield (2023)/Renfield (2023) {imdb-tt11358390} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv' 'Renfield (2023)'

# Requiem for a Dream (2000)
move_to_deleted '/mnt/synology/rs-movies/Requiem for a Dream (2000)/Requiem for a Dream (2000) {imdb-tt0180093} {edition-Director\'s Cut} [Bluray-1080p][DTS-HD MA 7.1][h264].mkv' 'Requiem for a Dream (2000)'

# Resident Evil (2002)
move_to_deleted '/mnt/synology/rs-movies/Resident Evil (2002)/Resident Evil (2002) {imdb-tt0120804} [Bluray-1080p][DV HDR10][EAC3 7.1][x265]-ZQ.mkv' 'Resident Evil (2002)'

# Resident Evil - Afterlife (2010)
move_to_deleted '/mnt/synology/rs-movies/Resident Evil - Afterlife (2010)/Resident Evil Afterlife (2010) {imdb-tt1220634} [Bluray-1080p][HDR10][EAC3 7.1][x265]-DON.mkv' 'Resident Evil - Afterlife (2010)'

# Resident Evil Retribution (2012)
move_to_deleted '/mnt/synology/rs-movies/Resident Evil Retribution (2012)/Resident Evil Retribution (2012) {imdb-tt1855325} {edition-Open Matte} [WEBDL-1080p][AC3 5.1][x264].mkv' 'Resident Evil Retribution (2012)'

# Resident Evil Welcome to Raccoon City (2021)
move_to_deleted '/mnt/synology/rs-movies/Resident Evil Welcome to Raccoon City (2021)/Resident Evil Welcome to Raccoon City (2021) {imdb-tt6920084} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv' 'Resident Evil Welcome to Raccoon City (2021)'

# Resistance (2020)
move_to_deleted '/mnt/synology/rs-movies/Resistance (2020)/Resistance (2020) {imdb-tt6914122} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Resistance (2020)'

# Resurrection (2022)
move_to_deleted '/mnt/synology/rs-movies/Resurrection (2022)/Resurrection (2022) {imdb-tt11540726} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Resurrection (2022)'

# Retribution (2023)
move_to_deleted '/mnt/synology/rs-movies/Retribution (2023)/Retribution (2023) {imdb-tt6906292} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-IWiLLFiNDyouANDiWiLLKiLLYOU.mkv' 'Retribution (2023)'

# Ricky Gervais SuperNature (2022)
move_to_deleted '/mnt/synology/rs-movies/Ricky Gervais SuperNature (2022)/Ricky Gervais SuperNature (2022) {imdb-tt19885626} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-KHN.mkv' 'Ricky Gervais SuperNature (2022)'

# Riddick (2013)
move_to_deleted '/mnt/synology/rs-movies/Riddick (2013)/Riddick (2013) {imdb-tt1411250} {edition-Extended} [Bluray-1080p][AC3 5.1][x264]-HDMaNiAcS.mkv' 'Riddick (2013)'

# Ride Along (2014)
move_to_deleted '/mnt/synology/rs-movies/Ride Along (2014)/Ride Along (2014) {imdb-tt1408253} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Ride Along (2014)'

# Ride Along 2 (2016)
move_to_deleted '/mnt/synology/rs-movies/Ride Along 2 (2016)/Ride Along 2 (2016) {imdb-tt2869728} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Ride Along 2 (2016)'

# Ride On (2023)
move_to_deleted '/mnt/synology/rs-movies/Ride On (2023)/Ride On (2023) {imdb-tt15430628} [WEBDL-1080p][AC3 5.1][x264]-CRO-DiAMOND.mkv' 'Ride On (2023)'

# Rio (2011) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Rio (2011)/Rio (2011) {imdb-tt1436562} [HDTV-720p][AC3 5.1][x264].mkv' 'Rio (2011)'

# Rio Bravo (1959) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Rio Bravo (1959)/Rio Bravo (1959) {imdb-tt0053221} [Bluray-720p][AC3 1.0][x264].mkv' 'Rio Bravo (1959)'

# Risky Business (1983)
move_to_deleted '/mnt/synology/rs-movies/Risky Business (1983)/Risky Business (1983) {imdb-tt0086200} [Bluray-1080p][DTS 5.1][x264].mkv' 'Risky Business (1983)'

# River Wild (2023)
move_to_deleted '/mnt/synology/rs-movies/River Wild (2023)/River Wild (2023) {imdb-tt21291992} [NF][WEBDL-1080p][EAC3 5.1][x264]-playWEB.mkv' 'River Wild (2023)'

# Road Trip (2000)
move_to_deleted '/mnt/synology/rs-movies/Road Trip (2000)/Road Trip (2000) {imdb-tt0215129} {edition-Extended} [Remux-1080p][DTS-HD MA 5.1][AVC]-EPSiLON.mkv' 'Road Trip (2000)'

# The Road (2009) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/The Road (2009)/The Road (2009) {imdb-tt0898367} [Bluray-720p][DTS 5.1][x264].mkv' 'The Road (2009)'

# Robin Hood (2010)
move_to_deleted '/mnt/synology/rs-movies/Robin Hood (2010)/Robin Hood (2010) {imdb-tt0955308} {edition-Directors Cut} [Bluray-1080p][HDR10][EAC3 7.1][x265]-iFT.mkv' 'Robin Hood (2010)'

# Robin Hood (2018)
move_to_deleted '/mnt/synology/rs-movies/Robin Hood (2018)/Robin Hood The Rebellion (2018) {imdb-tt7052244} [Bluray-1080p][EAC3 5.1][x264]-LoRD.mkv' 'Robin Hood (2018)'

# Robin Hood Men in Tights (1993)
move_to_deleted '/mnt/synology/rs-movies/Robin Hood Men in Tights (1993)/Robin Hood Men in Tights (1993) {imdb-tt0107977} [Bluray-1080p][AAC 2.0][x264]-DON.mkv' 'Robin Hood Men in Tights (1993)'

# Robin Hood Prince of Thieves (1991)
move_to_deleted '/mnt/synology/rs-movies/Robin Hood Prince of Thieves (1991)/Robin Hood Prince of Thieves (1991) {imdb-tt0102798} {edition-Extended Cut} [Bluray-1080p][AC3 5.1][x264]-CRiSC.mkv' 'Robin Hood Prince of Thieves (1991)'

# RoboCop 2 (1990)
move_to_deleted '/mnt/synology/rs-movies/RoboCop 2 (1990)/RoboCop 2 (1990) {imdb-tt0100502} [Bluray-1080p][DTS 5.1][x264]-aNDy.mkv' 'RoboCop 2 (1990)'

# Robot Dreams (2023)
move_to_deleted '/mnt/synology/rs-movies/Robot Dreams (2023)/Robot Dreams (2023) {imdb-tt13429870} [WEBDL-1080p][AC3 2.0][h264].mkv' 'Robot Dreams (2023)'

# Rocketman (2019)
move_to_deleted '/mnt/synology/rs-movies/Rocketman (2019)/Rocketman (2019) {imdb-tt2066051} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Rocketman (2019)'

# RocknRolla (2008)
move_to_deleted '/mnt/synology/rs-movies/RocknRolla (2008)/RocknRolla (2008) {imdb-tt1032755} [WEBDL-1080p][TrueHD 5.1][VC1].mkv' 'RocknRolla (2008)'

# Rocky (1976)
move_to_deleted '/mnt/synology/rs-movies/Rocky (1976)/Rocky (1976) {imdb-tt0075148} {edition-Remastered} [Bluray-1080p][DTS 5.1][x264]-NCmt.mkv' 'Rocky (1976)'

# Rogue Agent (2022)
move_to_deleted '/mnt/synology/rs-movies/Rogue Agent (2022)/Rogue Agent (2022) {imdb-tt9731386} [NF][WEBDL-1080p][EAC3 5.1][x264]-NTb.mkv' 'Rogue Agent (2022)'

# Room, The (2003) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Room, The (2003)/The Room (2003) {imdb-tt0368226} [Bluray-720p][AC3 5.1][x264]-DON.mkv' 'Room, The (2003)'

# Roxanne (1987)
move_to_deleted '/mnt/synology/rs-movies/Roxanne (1987)/Roxanne (1987) {imdb-tt0093886} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Roxanne (1987)'

# Royal Treatment, The (2022)
move_to_deleted '/mnt/synology/rs-movies/Royal Treatment, The (2022)/The Royal Treatment (2022) {imdb-tt13989030} [WEBDL-1080p][EAC3 Atmos 5.1][x264]-cupcakes.mkv' 'Royal Treatment, The (2022)'

# Rubikon (2022)
move_to_deleted '/mnt/synology/rs-movies/Rubikon (2022)/Rubikon (2022) {imdb-tt13829262} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Rubikon (2022)'

# Ruby Gillman Teenage Kraken (2023)
move_to_deleted '/mnt/synology/rs-movies/Ruby Gillman Teenage Kraken (2023)/Ruby Gillman, Teenage Kraken (2023) {imdb-tt27155038} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-XEBEC.mkv' 'Ruby Gillman Teenage Kraken (2023)'

# Rudolph, the Red-Nosed Reindeer (1964) (480p → 720p)
move_to_deleted '/mnt/synology/rs-movies/Rudolph, the Red-Nosed Reindeer (1964)/Rudolph the Red-Nosed Reindeer (1964) {imdb-tt0058536} [Bluray-720p][AC3 5.1][x264].mkv' 'Rudolph, the Red-Nosed Reindeer (1964)'

# Rudy (1993)
move_to_deleted '/mnt/synology/rs-movies/Rudy (1993)/Rudy (1993) {imdb-tt0108002} [Remux-1080p][TrueHD 5.1][AVC]-HDH.mkv' 'Rudy (1993)'

# Rules of Engagement (2000)
move_to_deleted '/mnt/synology/rs-movies/Rules of Engagement (2000)/Rules of Engagement (2000) {imdb-tt0160797} [Bluray-1080p][DTS 5.1][x264]-FANDANGO.mkv' 'Rules of Engagement (2000)'

# Rumble (2021)
move_to_deleted '/mnt/synology/rs-movies/Rumble (2021)/Rumble (2021) {imdb-tt8337158} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv' 'Rumble (2021)'

# Rumble Fish (1983)
move_to_deleted '/mnt/synology/rs-movies/Rumble Fish (1983)/Rumble Fish (1983) {imdb-tt0086216} [Bluray-1080p][AC3 2.0][x264]-nikt0.mkv' 'Rumble Fish (1983)'

# Rumble Through the Dark (2023)
move_to_deleted '/mnt/synology/rs-movies/Rumble Through the Dark (2023)/Rumble Through the Dark (2023) {imdb-tt10950320} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Rumble Through the Dark (2023)'

# Run Hide Fight (2020)
move_to_deleted '/mnt/synology/rs-movies/Run Hide Fight (2020)/Run Hide Fight (2021) {imdb-tt11456054} [WEBDL-1080p][AAC 2.0][h264].mkv' 'Run Hide Fight (2020)'

# Runaway Bride (1999)
move_to_deleted '/mnt/synology/rs-movies/Runaway Bride (1999)/Runaway Bride (1999) {imdb-tt0163187} [Bluray-1080p][AC3 5.1][x264]-LCHD.mkv' 'Runaway Bride (1999)'

# Runaway Jury (2003) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Runaway Jury (2003)/Runaway Jury (2003) {imdb-tt0313542} [Bluray-720p][AC3 5.1][x264].mkv' 'Runaway Jury (2003)'

# Rush (2013)
move_to_deleted '/mnt/synology/rs-movies/Rush (2013)/Rush (2013) {imdb-tt1979320} [Bluray-1080p][DTS 5.1][x264]-EbP.mkv' 'Rush (2013)'

# Rush Hour 2 (2001)
move_to_deleted '/mnt/synology/rs-movies/Rush Hour 2 (2001)/Rush Hour 2 (2001) {imdb-tt0266915} [Bluray-1080p][DTS 5.1][x264]-EbP.mkv' 'Rush Hour 2 (2001)'

# Rust (2025)
move_to_deleted '/mnt/synology/rs-movies/Rust (2025)/Rust (2025) {imdb-tt11001074} [Bluray-1080p][EAC3 5.1][x264]-hallowed.mkv' 'Rust (2025)'

# Saloum (2021)
move_to_deleted '/mnt/synology/rs-movies/Saloum (2021)/Saloum (2021) {imdb-tt10756184} [WEBDL-1080p][AAC 2.0][h264]-SCARECREW.mkv' 'Saloum (2021)'

# San Andreas (2015)
move_to_deleted '/mnt/synology/rs-movies/San Andreas (2015)/San Andreas (2015) {imdb-tt2126355} [Bluray-1080p][DV HDR10][EAC3 7.1][x265]-LEGi0N.mkv' 'San Andreas (2015)'

# Sanctuary (2023)
move_to_deleted '/mnt/synology/rs-movies/Sanctuary (2023)/Sanctuary (2023) {imdb-tt15364972} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-SCOPE.mkv' 'Sanctuary (2023)'

# Santa Clause 3 The Escape Clause, The (2006)
move_to_deleted '/mnt/synology/rs-movies/Santa Clause 3 The Escape Clause, The (2006)/The.Santa.Clause.3.The.Escape.Clause.2006.1080p.Bluray.x264-hV.mkv' 'Santa Clause 3 The Escape Clause, The (2006)'

# Santa Sangre (1989)
move_to_deleted '/mnt/synology/rs-movies/Santa Sangre (1989)/Santa Sangre (1989) {imdb-tt0098253} [Bluray-1080p][DTS 2.0][x264]-aAF.mkv' 'Santa Sangre (1989)'

# Sasquatch Sunset (2024)
move_to_deleted '/mnt/synology/rs-movies/Sasquatch Sunset (2024)/Sasquatch Sunset (2024) {imdb-tt30180830} [WEBDL-1080p][EAC3 5.1][h264]-AOC.mkv' 'Sasquatch Sunset (2024)'

# Saturday Night (2024)
move_to_deleted '/mnt/synology/rs-movies/Saturday Night (2024)/Saturday Night (2024) {imdb-tt27657135} [WEBDL-1080p][EAC3 5.1][h264]-WiseCormorantOfInspiringArtistry.mkv' 'Saturday Night (2024)'

# Saving Private Ryan (1998)
move_to_deleted '/mnt/synology/rs-movies/Saving Private Ryan (1998)/Saving Private Ryan (1998) {imdb-tt0120815} [Bluray-1080p][HDR10][EAC3 7.1][x265]-NCmt.mkv' 'Saving Private Ryan (1998)'

# Saw (2004)
move_to_deleted '/mnt/synology/rs-movies/Saw (2004)/Saw (2004) {imdb-tt0387564} [Bluray-1080p][EAC3 7.1][x264]-iFT.mkv' 'Saw (2004)'

# Saw III (2006)
move_to_deleted '/mnt/synology/rs-movies/Saw III (2006)/Saw III (2006) {imdb-tt0489270} [Bluray-1080p][DTS-ES 6.1][x264]-HDMaNiAcS.mkv' 'Saw III (2006)'

# Saw X (2023)
move_to_deleted '/mnt/synology/rs-movies/Saw X (2023)/Saw X (2023) {imdb-tt21807222} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Saw X (2023)'

# Scarface (1983) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Scarface (1983)/Scarface (1983) {imdb-tt0086250} [Bluray-720p][DTS 5.1][x264].mkv' 'Scarface (1983)'

# Scent of a Woman (1992) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Scent of a Woman (1992)/Scent of a Woman (1992) {imdb-tt0105323} [Bluray-720p][AC3 5.1][x264].mkv' 'Scent of a Woman (1992)'

# Schindler\'s List (1993) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Schindler\'s List (1993)/Schindler\'s List (1993) {imdb-tt0108052} [Bluray-720p][DTS 5.1][x264].mkv' 'Schindler\'s List (1993)'

# Scream (2022)
move_to_deleted '/mnt/synology/rs-movies/Scream (2022)/Scream (2022) {imdb-tt11245972} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-TEPES.mkv' 'Scream (2022)'

# Se7en (1995)
move_to_deleted '/mnt/synology/rs-movies/Se7en (1995)/Se7en (1995) {imdb-tt0114369} {edition-Remastered} [Bluray-1080p][DTS-ES 5.1][x264]-D-Z0N3.mkv' 'Se7en (1995)'

# The Sea Beast (2022)
move_to_deleted '/mnt/synology/rs-movies/The Sea Beast (2022)/The Sea Beast (2022) {imdb-tt9288046} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv' 'The Sea Beast (2022)'

# Season Of The Witch (2011) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Season Of The Witch (2011)/Season of the Witch (2011) {imdb-tt0479997} [Bluray-720p][AAC 5.1][x264].mp4' 'Season Of The Witch (2011)'

# Section 8 (2022)
move_to_deleted '/mnt/synology/rs-movies/Section 8 (2022)/Section 8 (2022) {imdb-tt14950412} [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv' 'Section 8 (2022)'

# Serenity (2005)
move_to_deleted '/mnt/synology/rs-movies/Serenity (2005)/Serenity (2005) {imdb-tt0379786} {edition-Open Matte} [WEBDL-1080p][EAC3 5.1][h264].mkv' 'Serenity (2005)'

# Serpico (1973)
move_to_deleted '/mnt/synology/rs-movies/Serpico (1973)/Serpico (1973) {imdb-tt0070666} {edition-Remastered} [Remux-1080p][PCM 2.0][x264]-HiGUCHi.mkv' 'Serpico (1973)'

# Setup (2011) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Setup (2011)/Setup (2011) {imdb-tt1748197} [Bluray-720p][DTS 5.1][x264].mkv' 'Setup (2011)'

# Seven Pounds (2008) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Seven Pounds (2008)/Seven Pounds (2008) {imdb-tt0814314} [Bluray-720p][AC3 5.1][x264].mkv' 'Seven Pounds (2008)'

# Shadow Force (2025)
move_to_deleted '/mnt/synology/rs-movies/Shadow Force (2025)/Shadow Force (2025) {imdb-tt11092020} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-HONE.mkv' 'Shadow Force (2025)'

# Shape of Water, The (2017)
move_to_deleted '/mnt/synology/rs-movies/Shape of Water, The (2017)/The Shape of Water (2017) {imdb-tt5580390} [Bluray-1080p][HDR10][AC3 5.1][x265]-D-Z0N3.mkv' 'Shape of Water, The (2017)'

# Shark Tale (2004)
move_to_deleted '/mnt/synology/rs-movies/Shark Tale (2004)/Shark Tale (2004) {imdb-tt0307453} [HDTV-1080p][AC3 5.1][h264].mkv' 'Shark Tale (2004)'

# Shaun of the Dead (2004)
move_to_deleted '/mnt/synology/rs-movies/Shaun of the Dead (2004)/Shaun of the Dead (2004) {imdb-tt0365748} [Bluray-1080p][HDR10Plus][EAC3 7.1][x265]-NCmt.mkv' 'Shaun of the Dead (2004)'

# Shazam! (2019)
move_to_deleted '/mnt/synology/rs-movies/Shazam! (2019)/Shazam! (2019) {imdb-tt0448115} [Bluray-1080p][AC3 5.1][x264].mkv' 'Shazam! (2019)'

# Shazam! Fury of the Gods (2023)
move_to_deleted '/mnt/synology/rs-movies/Shazam! Fury of the Gods (2023)/Shazam! Fury of the Gods (2023) {imdb-tt10151854} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv' 'Shazam! Fury of the Gods (2023)'

# She Will (2022)
move_to_deleted '/mnt/synology/rs-movies/She Will (2022)/She Will (2022) {imdb-tt9340916} [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv' 'She Will (2022)'

# Shelter (2014)
move_to_deleted '/mnt/synology/rs-movies/Shelter (2014)/Shelter (2014) {imdb-tt3136112} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv' 'Shelter (2014)'

# Sherlock Holmes (2009)
move_to_deleted '/mnt/synology/rs-movies/Sherlock Holmes (2009)/Sherlock Holmes (2009) {imdb-tt0988045} [Bluray-1080p][HDR10][EAC3 5.1][x265]-TDD.mkv' 'Sherlock Holmes (2009)'

# Shine of Rainbows, A (2009) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Shine of Rainbows, A (2009)/A Shine of Rainbows (2009) {imdb-tt1014774} [Bluray-720p][DTS 5.1][x264]-VETO.mkv' 'Shine of Rainbows, A (2009)'

# Shooter (2007)
move_to_deleted '/mnt/synology/rs-movies/Shooter (2007)/Shooter (2007) {imdb-tt0822854} [Bluray-1080p][AC3 5.1][x264].mkv' 'Shooter (2007)'

# Short Circuit (1986)
move_to_deleted '/mnt/synology/rs-movies/Short Circuit (1986)/Short Circuit (1986) {imdb-tt0091949} [HDTV-1080p][DTS 5.1][x264].mkv' 'Short Circuit (1986)'

# Shotgun Wedding (2022)
move_to_deleted '/mnt/synology/rs-movies/Shotgun Wedding (2022)/Shotgun Wedding (2022) {imdb-tt9686790} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv' 'Shotgun Wedding (2022)'

# Showgirls (1995)
move_to_deleted '/mnt/synology/rs-movies/Showgirls (1995)/Showgirls (1995) {imdb-tt0114436} [Bluray-1080p][EAC3 5.1][x264]-LoRD.mkv' 'Showgirls (1995)'

# Shrek 2 (2004)
move_to_deleted '/mnt/synology/rs-movies/Shrek 2 (2004)/Shrek 2 (2004) {imdb-tt0298148} [Bluray-1080p][DTS 5.1][x264].mkv' 'Shrek 2 (2004)'

# Shut In (2022)
move_to_deleted '/mnt/synology/rs-movies/Shut In (2022)/Shut In (2022) {imdb-tt10131024} [WEBDL-1080p][AAC 2.0][h264]-EVO.mkv' 'Shut In (2022)'

# Sicario (2015)
move_to_deleted '/mnt/synology/rs-movies/Sicario (2015)/Sicario (2015) {imdb-tt3397884} [HDTV-1080p][AC3 5.1][x264].mkv' 'Sicario (2015)'

# Sick (2022)
move_to_deleted '/mnt/synology/rs-movies/Sick (2022)/Sick (2022) {imdb-tt14642626} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Sick (2022)'

# Side Effects (2013)
move_to_deleted '/mnt/synology/rs-movies/Side Effects (2013)/Side Effects (2013) {imdb-tt2053463} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Side Effects (2013)'

# Silent Night (2023)
move_to_deleted '/mnt/synology/rs-movies/Silent Night (2023)/Silent Night (2023) {imdb-tt15799866} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Silent Night (2023)'

# Simple Favor, A (2018)
move_to_deleted '/mnt/synology/rs-movies/Simple Favor, A (2018)/A Simple Favor (2018) {imdb-tt7040874} [Bluray-1080p][EAC3 7.1][x264]-NCmt.mkv' 'Simple Favor, A (2018)'

# Simple Plan, A (1998)
move_to_deleted '/mnt/synology/rs-movies/Simple Plan, A (1998)/A Simple Plan (1998) {imdb-tt0120324} [Bluray-1080p][DTS 5.1][x264]-AMIABLE.mkv' 'Simple Plan, A (1998)'

# Simpsons The Good, the Bart, and the Loki, The (2021)
move_to_deleted '/mnt/synology/rs-movies/Simpsons The Good, the Bart, and the Loki, The (2021)/The Good, the Bart, and the Loki (2021) {imdb-tt14957270} [DSNP][WEBRip-1080p][EAC3 5.1][x264]-TOMMY.mkv' 'Simpsons The Good, the Bart, and the Loki, The (2021)'

# Simulant (2023)
move_to_deleted '/mnt/synology/rs-movies/Simulant (2023)/Simulant (2023) {imdb-tt13130024} [HMAX][WEBDL-1080p][EAC3 5.1][x264]-PTerWEB.mkv' 'Simulant (2023)'

# Sin City A Dame to Kill For (2014)
move_to_deleted '/mnt/synology/rs-movies/Sin City A Dame to Kill For (2014)/Sin City A Dame to Kill For (2014) {imdb-tt0458481} [PCOK][WEBDL-1080p][EAC3 5.1][x264]-ARTiCUN0.mkv' 'Sin City A Dame to Kill For (2014)'

# Sing 2 (2021)
move_to_deleted '/mnt/synology/rs-movies/Sing 2 (2021)/Sing 2 (2021) {imdb-tt6467266} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-EVO.mkv' 'Sing 2 (2021)'

# Sinners (2025)
move_to_deleted '/mnt/synology/rs-movies/Sinners (2025)/Sinners (2025) {imdb-tt31193180} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-BYNDR.mkv' 'Sinners (2025)'

# Sirat (2025)
move_to_deleted '/mnt/synology/rs-movies/Sirat (2025)/Sirat (2025) {imdb-tt32298285} - [WEBDL-1080p][EAC3 5.1][h264]-TeBaS.mkv' 'Sirat (2025)'

# Sister Death (2023)
move_to_deleted '/mnt/synology/rs-movies/Sister Death (2023)/Sister Death (2023) {imdb-tt19175696} [WEBDL-1080p][EAC3 Atmos 5.1][x264]-AOC.mp4' 'Sister Death (2023)'

# Sisters Brothers, The (2018)
move_to_deleted '/mnt/synology/rs-movies/Sisters Brothers, The (2018)/The Sisters Brothers (2018) {imdb-tt4971344} [Bluray-1080p][DTS 5.1][x264]-RightSiZE.mkv' 'Sisters Brothers, The (2018)'

# Six Days Seven Nights (1998)
move_to_deleted '/mnt/synology/rs-movies/Six Days Seven Nights (1998)/Six Days Seven Nights (1998) {imdb-tt0120828} [WEBDL-1080p][EAC3 5.1][h264]-DiMEPiECE.mkv' 'Six Days Seven Nights (1998)'

# Sky Captain and the World of Tomorrow (2004)
move_to_deleted '/mnt/synology/rs-movies/Sky Captain and the World of Tomorrow (2004)/Sky Captain and the World of Tomorrow (2004) {imdb-tt0346156} [Bluray-1080p][DTS 5.1][x264].mkv' 'Sky Captain and the World of Tomorrow (2004)'

# Skyfall (2012)
move_to_deleted '/mnt/synology/rs-movies/Skyfall (2012)/Skyfall (2012) {imdb-tt1074638} [Bluray-1080p][DTS 5.1][x264].mkv' 'Skyfall (2012)'

# Sleeping Dogs (2024)
move_to_deleted '/mnt/synology/rs-movies/Sleeping Dogs (2024)/Sleeping Dogs (2024) {imdb-tt8542964} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Sleeping Dogs (2024)'

# Sleepless in Seattle (1993)
move_to_deleted '/mnt/synology/rs-movies/Sleepless in Seattle (1993)/Sleepless in Seattle (1993) {imdb-tt0108160} [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv' 'Sleepless in Seattle (1993)'

# Sleepy Hollow (1999)
move_to_deleted '/mnt/synology/rs-movies/Sleepy Hollow (1999)/Sleepy Hollow (1999) {imdb-tt0162661} [WEBDL-1080p][EAC3 5.1][h264].mkv' 'Sleepy Hollow (1999)'

# Slingshot (2024)
move_to_deleted '/mnt/synology/rs-movies/Slingshot (2024)/Slingshot (2024) {imdb-tt12616480} [WEBDL-1080p][EAC3 5.1][h264]-NeatPristineCoyoteOfAssurance.mkv' 'Slingshot (2024)'

# Smile (2022)
move_to_deleted '/mnt/synology/rs-movies/Smile (2022)/Smile (2022) {imdb-tt15474916} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv' 'Smile (2022)'

# Smile 2 (2024)
move_to_deleted '/mnt/synology/rs-movies/Smile 2 (2024)/Smile 2 (2024) {imdb-tt29268110} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-APEX.mkv' 'Smile 2 (2024)'

# Smokey and the Bandit (1977)
move_to_deleted '/mnt/synology/rs-movies/Smokey and the Bandit (1977)/Smokey and the Bandit (1977) {imdb-tt0076729} [Bluray-1080p][AC3 5.1][x264].mkv' 'Smokey and the Bandit (1977)'

# Smokin Aces (2006) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Smokin Aces (2006)/Smokin\' Aces (2006) {imdb-tt0475394} [Bluray-720p][AC3 5.1][x264]-HiDt.mkv' 'Smokin Aces (2006)'

# Smurfs (2025)
move_to_deleted '/mnt/synology/rs-movies/Smurfs (2025)/Smurfs (2025) {imdb-tt18069420} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-BYNDR.mkv' 'Smurfs (2025)'

# Snake Eyes (1998) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Snake Eyes (1998)/Snake Eyes (1998) {imdb-tt0120832} [Bluray-720p][AC3 5.1][x264].mkv' 'Snake Eyes (1998)'

# Snake Eyes G.I. Joe Origins (2021)
move_to_deleted '/mnt/synology/rs-movies/Snake Eyes G.I. Joe Origins (2021)/Snake Eyes G.I. Joe Origins (2021) {imdb-tt8404256} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv' 'Snake Eyes G.I. Joe Origins (2021)'

# Snatch (2000)
move_to_deleted '/mnt/synology/rs-movies/Snatch (2000)/Snatch (2000) {imdb-tt0208092} [Bluray-1080p][HDR10][EAC3 7.1][x265]-c0kE.mkv' 'Snatch (2000)'

# Sneakers (1992)
move_to_deleted '/mnt/synology/rs-movies/Sneakers (1992)/Sneakers (1992) {imdb-tt0105435} [Remux-1080p][DTS-HD MA 5.1][VC1]-decibeL.mkv' 'Sneakers (1992)'

# Sniper Rogue Mission (2022)
move_to_deleted '/mnt/synology/rs-movies/Sniper Rogue Mission (2022)/Sniper Rogue Mission (2022) {imdb-tt21222434} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Sniper Rogue Mission (2022)'

# Snitch (2013)
move_to_deleted '/mnt/synology/rs-movies/Snitch (2013)/Snitch (2013) {imdb-tt0882977} [Bluray-1080p][DTS 5.1][x264]-HDMaNiAcS.mkv' 'Snitch (2013)'

# Snowpiercer (2013)
move_to_deleted '/mnt/synology/rs-movies/Snowpiercer (2013)/Snowpiercer (2013) {imdb-tt1706620} [Bluray-1080p][AC3 5.1][x264]-EbP.mkv' 'Snowpiercer (2013)'

# So I Married an Axe Murderer (1993)
move_to_deleted '/mnt/synology/rs-movies/So I Married an Axe Murderer (1993)/So I Married an Axe Murderer (1993) {imdb-tt0108174} [Bluray-1080p][DTS 5.1][x264]-EuReKA.mkv' 'So I Married an Axe Murderer (1993)'

# Solomon Kane (2009)
move_to_deleted '/mnt/synology/rs-movies/Solomon Kane (2009)/Solomon Kane (2009) {imdb-tt0970452} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-RegEdits.mkv' 'Solomon Kane (2009)'

# Some Like It Hot (1959)
move_to_deleted '/mnt/synology/rs-movies/Some Like It Hot (1959)/Some Like It Hot (1959) {imdb-tt0053291} [Bluray-1080p][DV HDR10][EAC3 5.1][x265]-c0kE.mkv' 'Some Like It Hot (1959)'

# Son in Law (1993)
move_to_deleted '/mnt/synology/rs-movies/Son in Law (1993)/Son in Law (1993) {imdb-tt0108186} [AMZN][WEBRip-1080p][EAC3 2.0][x264]-monkee.mkv' 'Son in Law (1993)'

# Songbird (2020)
move_to_deleted '/mnt/synology/rs-movies/Songbird (2020)/Songbird (2020) {imdb-tt12592252} [WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv' 'Songbird (2020)'

# Sonic the Hedgehog (2020)
move_to_deleted '/mnt/synology/rs-movies/Sonic the Hedgehog (2020)/Sonic the Hedgehog (2020) {imdb-tt3794354} [WEBDL-1080p][EAC3 5.1][h264]-TEPES.mkv' 'Sonic the Hedgehog (2020)'

# Sonic the Hedgehog 2 (2022)
move_to_deleted '/mnt/synology/rs-movies/Sonic the Hedgehog 2 (2022)/Sonic the Hedgehog 2 (2022) {imdb-tt12412888} [WEBDL-1080p][AAC 2.0][h264]-EVO.mkv' 'Sonic the Hedgehog 2 (2022)'

# Sonic the Hedgehog 3 (2024)
move_to_deleted '/mnt/synology/rs-movies/Sonic the Hedgehog 3 (2024)/Sonic the Hedgehog 3 (2024) {imdb-tt18259086} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-APEX.mkv' 'Sonic the Hedgehog 3 (2024)'

# Sorority Babes in the Slimeball Bowl-O-Rama (1988)
move_to_deleted '/mnt/synology/rs-movies/Sorority Babes in the Slimeball Bowl-O-Rama (1988)/Sorority Babes in the Slimeball Bowl-O-Rama (1988) {imdb-tt0096142} [AMZN MA][WEBDL-1080p][EAC3 2.0][h264]-Kitsune.mkv' 'Sorority Babes in the Slimeball Bowl-O-Rama (1988)'

# Sorority Babes in the Slimeball Bowl-O-Rama 2 (2022)
move_to_deleted '/mnt/synology/rs-movies/Sorority Babes in the Slimeball Bowl-O-Rama 2 (2022)/Sorority Babes in the Slimeball Bowl-O-Rama 2 (2022) {imdb-tt12472174} [AMZN MA][WEBDL-1080p][EAC3 2.0][h264]-Kitsune.mkv' 'Sorority Babes in the Slimeball Bowl-O-Rama 2 (2022)'

# Soul (2020)
move_to_deleted '/mnt/synology/rs-movies/Soul (2020)/Soul (2020) {imdb-tt2948372} [WEBDL-1080p][EAC3 Atmos 5.1][h264].mkv' 'Soul (2020)'

# Sound of Freedom (2023)
move_to_deleted '/mnt/synology/rs-movies/Sound of Freedom (2023)/Sound of Freedom (2023) {imdb-tt7599146} [WEBDL-1080p][AC3 5.1][h264]-XEBEC.mkv' 'Sound of Freedom (2023)'

# Source Code (2011)
move_to_deleted '/mnt/synology/rs-movies/Source Code (2011)/Source Code (2011) {imdb-tt0945513} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv' 'Source Code (2011)'

# South Park Joining the Panderverse (2023)
move_to_deleted '/mnt/synology/rs-movies/South Park Joining the Panderverse (2023)/South Park Joining the Panderverse (2023) {imdb-tt29474455} [AMZN][WEBDL-1080p Proper][EAC3 5.1][h264]-FLUX.mkv' 'South Park Joining the Panderverse (2023)'

# South Park Not Suitable for Children (2023)
move_to_deleted '/mnt/synology/rs-movies/South Park Not Suitable for Children (2023)/South Park (Not Suitable for Children) (2023) {imdb-tt30505159} [WEBDL-1080p][EAC3 5.1][h264]-DiMEPiECE.mkv' 'South Park Not Suitable for Children (2023)'

# South Park Post COVID The Return of COVID (2021)
move_to_deleted '/mnt/synology/rs-movies/South Park Post COVID The Return of COVID (2021)/South Park Post COVID The Return of COVID (2021) {imdb-tt16375288} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv' 'South Park Post COVID The Return of COVID (2021)'

# South Park The End Of Obesity (2024)
move_to_deleted '/mnt/synology/rs-movies/South Park The End Of Obesity (2024)/South Park The End of Obesity (2024) {imdb-tt32375562} [WEBDL-1080p][EAC3 5.1][h264]-thistlequokkaofscientificchampagne.mkv' 'South Park The End Of Obesity (2024)'

# South Park The Streaming Wars (2022)
move_to_deleted '/mnt/synology/rs-movies/South Park The Streaming Wars (2022)/South Park the Streaming Wars (2022) {imdb-tt15783698} [WEBDL-1080p][EAC3 5.1][h264]-naisu.mkv' 'South Park The Streaming Wars (2022)'

# South Park the Streaming Wars Part 2 (2022)
move_to_deleted '/mnt/synology/rs-movies/South Park the Streaming Wars Part 2 (2022)/South Park the Streaming Wars Part 2 (2022) {imdb-tt21198156} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv' 'South Park the Streaming Wars Part 2 (2022)'

# Southland Tales (2007) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Southland Tales (2007)/Southland Tales (2007) {imdb-tt0405336} [Bluray-720p][AC3 5.1][x264]-LoRD.mkv' 'Southland Tales (2007)'

# Southpaw (2015)
move_to_deleted '/mnt/synology/rs-movies/Southpaw (2015)/Southpaw (2015) {imdb-tt1798684} [Bluray-1080p][AC3 5.1][x264]-SA89.mkv' 'Southpaw (2015)'

# Space Jam A New Legacy (2021)
move_to_deleted '/mnt/synology/rs-movies/Space Jam A New Legacy (2021)/Space Jam A New Legacy (2021) {imdb-tt3554046} [HMAX][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv' 'Space Jam A New Legacy (2021)'

# Spanglish (2004) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Spanglish (2004)/Spanglish (2004) {imdb-tt0371246} [Bluray-720p][AC3 2.0][x264]-BHDStudio.mp4' 'Spanglish (2004)'

# Speak No Evil (2024)
move_to_deleted '/mnt/synology/rs-movies/Speak No Evil (2024)/Speak No Evil (2024) {imdb-tt27534307} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Speak No Evil (2024)'

# Species (1995)
move_to_deleted '/mnt/synology/rs-movies/Species (1995)/Species (1995) {imdb-tt0114508} [Bluray-1080p][EAC3 5.1][x264]-iFT.mkv' 'Species (1995)'

# Spectre (2015)
move_to_deleted '/mnt/synology/rs-movies/Spectre (2015)/Spectre (2015) {imdb-tt2379713} [Bluray-1080p][DTS 5.1][x264].mkv' 'Spectre (2015)'

# Speed (1994)
move_to_deleted '/mnt/synology/rs-movies/Speed (1994)/Speed (1994) {imdb-tt0111257} [Bluray-1080p][AC3 5.1][x264]-LoRD.mkv' 'Speed (1994)'

# Spellbound (2024)
move_to_deleted '/mnt/synology/rs-movies/Spellbound (2024)/Spellbound (2024) {imdb-tt7215232} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-APEX.mkv' 'Spellbound (2024)'

# Spider-Man (2002)
move_to_deleted '/mnt/synology/rs-movies/Spider-Man (2002)/Spider-Man (2002) {imdb-tt0145487} [Bluray-1080p][HDR10][EAC3 Atmos 7.1][x265]-NCmt.mkv' 'Spider-Man (2002)'

# Spider-Man 2 (2004)
move_to_deleted '/mnt/synology/rs-movies/Spider-Man 2 (2004)/Spider-Man 2 (2004) {imdb-tt0316654} [Bluray-1080p][HDR10][EAC3 7.1][x265]-NCmt.mkv' 'Spider-Man 2 (2004)'

# Spider-Man 3 (2007)
move_to_deleted '/mnt/synology/rs-movies/Spider-Man 3 (2007)/Spider-Man 3 (2007) {imdb-tt0413300} {edition-Open Matte} [Hulu][WEBDL-1080p][EAC3 7.1][h264]-QOQ.mkv' 'Spider-Man 3 (2007)'

# Spider-Man Far from Home (2019)
move_to_deleted '/mnt/synology/rs-movies/Spider-Man Far from Home (2019)/Spider-Man Far From Home (2019) {imdb-tt6320628} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Spider-Man Far from Home (2019)'

# Spider-Man Homecoming (2017)
move_to_deleted '/mnt/synology/rs-movies/Spider-Man Homecoming (2017)/Spider-Man Homecoming (2017) {imdb-tt2250912} [Bluray-1080p][HDR10][EAC3 7.1][x265]-NCmt.mkv' 'Spider-Man Homecoming (2017)'

# Spider-Man Into the Spider-Verse (2018)
move_to_deleted '/mnt/synology/rs-movies/Spider-Man Into the Spider-Verse (2018)/Spider-Man Into the Spider-Verse (2018) {imdb-tt4633694} [WEBDL-1080p][EAC3 5.1][h264].mkv' 'Spider-Man Into the Spider-Verse (2018)'

# Spirit Untamed (2021)
move_to_deleted '/mnt/synology/rs-movies/Spirit Untamed (2021)/Spirit Untamed (2021) {imdb-tt11084896} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv' 'Spirit Untamed (2021)'

# Splitsville (2025)
move_to_deleted '/mnt/synology/rs-movies/Splitsville (2025)/Splitsville (2025) {imdb-tt33247023} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'Splitsville (2025)'

# Spring Breakers (2013) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Spring Breakers (2013)/Spring Breakers (2013) {imdb-tt2101441} [Bluray-720p][DTS 5.1][x264].mkv' 'Spring Breakers (2013)'

# St. Elmo\'s Fire (1985)
move_to_deleted '/mnt/synology/rs-movies/St. Elmo\'s Fire (1985)/St. Elmo\'s Fire (1985) {imdb-tt0090060} [Bluray-1080p Proper][AC3 5.1][x264]-TFiN.mkv' 'St. Elmo\'s Fire (1985)'

# Stakeout (1987)
move_to_deleted '/mnt/synology/rs-movies/Stakeout (1987)/Stakeout (1987) {imdb-tt0094025} [WEBDL-1080p][EAC3 5.1][x264]-AM.mkv' 'Stakeout (1987)'

# Stalag 17 (1953) (480p → 720p)
move_to_deleted '/mnt/synology/rs-movies/Stalag 17 (1953)/Stalag 17 (1953) {imdb-tt0046359} {edition-Remastered} [Bluray-720p][FLAC 2.0][x264]-ORBS.mkv' 'Stalag 17 (1953)'

# Stand and Deliver (1988)
move_to_deleted '/mnt/synology/rs-movies/Stand and Deliver (1988)/Stand and Deliver (1988) {imdb-tt0094027} [AMZN][WEBDL-1080p][EAC3 2.0][x264]-ABM.mkv' 'Stand and Deliver (1988)'

# Stand by Me (1986) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Stand by Me (1986)/Stand by Me (1986) {imdb-tt0092005} [HDTV-720p][AC3 5.1][x264].mkv' 'Stand by Me (1986)'

# Star Is Born, A (2018)
move_to_deleted '/mnt/synology/rs-movies/Star Is Born, A (2018)/A Star Is Born (2018) {imdb-tt1517451} [Bluray-1080p][AC3 5.1][x264]-iFT.mkv' 'Star Is Born, A (2018)'

# Star Trek - The Motion Picture (1979)
move_to_deleted '/mnt/synology/rs-movies/Star Trek - The Motion Picture (1979)/Star.Trek.The.Motion.Picture.1979.1080p.BluRay.x264-CtrlHD.mkv' 'Star Trek - The Motion Picture (1979)'

# Star Trek Beyond (2016) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Star Trek Beyond (2016)/Star Trek Beyond (2016) {imdb-tt2660888} [Bluray-720p][AC3 5.1][x264].mkv' 'Star Trek Beyond (2016)'

# Star Trek Into Darkness (2013)
move_to_deleted '/mnt/synology/rs-movies/Star Trek Into Darkness (2013)/Star Trek Into Darkness (2013) {imdb-tt1408101} [Bluray-1080p][HDR10][EAC3 7.1][x265]-NCmt.mkv' 'Star Trek Into Darkness (2013)'

# Star Trek Section 31 (2025)
move_to_deleted '/mnt/synology/rs-movies/Star Trek Section 31 (2025)/Star Trek Section 31 (2025) {imdb-tt9603060} [WEBDL-1080p][EAC3 5.1][h264]-AccomplishedYak.mkv' 'Star Trek Section 31 (2025)'

# Star Wars The Rise of Skywalker (2019)
move_to_deleted '/mnt/synology/rs-movies/Star Wars The Rise of Skywalker (2019)/Star Wars The Rise of Skywalker (2019) {imdb-tt2527338} [Bluray-1080p][DTS 5.1][x264]-CHD.mkv' 'Star Wars The Rise of Skywalker (2019)'

# Starman (1984)
move_to_deleted '/mnt/synology/rs-movies/Starman (1984)/Starman (1984) {imdb-tt0088172} [Bluray-1080p][AC3 5.1][x264].mkv' 'Starman (1984)'

# Starve Acre (2024)
move_to_deleted '/mnt/synology/rs-movies/Starve Acre (2024)/Starve Acre (2024) {imdb-tt17521612} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'Starve Acre (2024)'

# Stillwater (2021)
move_to_deleted '/mnt/synology/rs-movies/Stillwater (2021)/Stillwater (2021) {imdb-tt10696896} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv' 'Stillwater (2021)'

# Sting, The (1973)
move_to_deleted '/mnt/synology/rs-movies/Sting, The (1973)/The Sting (1973) {imdb-tt0070735} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv' 'Sting, The (1973)'

# Stowaway (2021)
move_to_deleted '/mnt/synology/rs-movies/Stowaway (2021)/Stowaway (2021) {imdb-tt9203694} [AMZN][WEBDL-1080p][EAC3 2.0][h264]-CMRG.mkv' 'Stowaway (2021)'

# Strange World (2022)
move_to_deleted '/mnt/synology/rs-movies/Strange World (2022)/Strange World (2022) {imdb-tt10298840} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Strange World (2022)'

# Strays (2023)
move_to_deleted '/mnt/synology/rs-movies/Strays (2023)/Strays (2023) {imdb-tt15153532} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Strays (2023)'

# Stuart Little (1999)
move_to_deleted '/mnt/synology/rs-movies/Stuart Little (1999)/Stuart Little (1999) {imdb-tt0164912} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Stuart Little (1999)'

# Stuber (2019)
move_to_deleted '/mnt/synology/rs-movies/Stuber (2019)/Stuber (2019) {imdb-tt7734218} [WEBDL-1080p][EAC3 5.1][h264].mkv' 'Stuber (2019)'

# Subservience (2024)
move_to_deleted '/mnt/synology/rs-movies/Subservience (2024)/Subservience (2024) {imdb-tt24871974} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Subservience (2024)'

# Suicide Squad Hell to Pay (2018)
move_to_deleted '/mnt/synology/rs-movies/Suicide Squad Hell to Pay (2018)/Suicide Squad Hell to Pay (2018) {imdb-tt7167602} [WEBDL-1080p][EAC3 5.1][x264]-Kitsune.mkv' 'Suicide Squad Hell to Pay (2018)'

# Suicide Squad, The (2021)
move_to_deleted '/mnt/synology/rs-movies/Suicide Squad, The (2021)/The.Suicide.Squad.2021.1080p.BluRay.DD+7.1.x264-iFT.mkv' 'Suicide Squad, The (2021)'

# Sully (2016)
move_to_deleted '/mnt/synology/rs-movies/Sully (2016)/Sully (2016) {imdb-tt3263904} [Bluray-1080p][AC3 5.1][x264].mkv' 'Sully (2016)'

# Summer Rental (1985)
move_to_deleted '/mnt/synology/rs-movies/Summer Rental (1985)/Summer Rental (1985) {imdb-tt0090098} [WEBDL-1080p][EAC3 2.0][h264]-ETHiCS.mkv' 'Summer Rental (1985)'

# Super Troopers 2 (2018)
move_to_deleted '/mnt/synology/rs-movies/Super Troopers 2 (2018)/Super Troopers 2 (2018) {imdb-tt0859635} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Super Troopers 2 (2018)'

# Superman (2025)
move_to_deleted '/mnt/synology/rs-movies/Superman (2025)/Superman (2025) {imdb-tt5950044} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-ETHEL.mkv' 'Superman (2025)'

# Superman Batman Public Enemies (2009)
move_to_deleted '/mnt/synology/rs-movies/Superman Batman Public Enemies (2009)/Superman.Batman.Public.Enemies.2009.1080p.BluRay.x264-CiNEFiLE.mkv' 'Superman Batman Public Enemies (2009)'

# Superman Doomsday (2007) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Superman Doomsday (2007)/Superman Doomsday (2007) {imdb-tt0934706} [Bluray-720p][AC3 5.1][x264]-PRoDJi.mkv' 'Superman Doomsday (2007)'

# Superman Returns (2006)
move_to_deleted '/mnt/synology/rs-movies/Superman Returns (2006)/Superman Returns (2006) {imdb-tt0348150} [WEBDL-1080p][AC3 5.1][x264]-TWA.mkv' 'Superman Returns (2006)'

# Surrogates (2009)
move_to_deleted '/mnt/synology/rs-movies/Surrogates (2009)/Surrogates (2009) {imdb-tt0986263} {edition-Open Matte} [WEBDL-1080p][EAC3 5.1][h264].mkv' 'Surrogates (2009)'

# Survivor, The (2022)
move_to_deleted '/mnt/synology/rs-movies/Survivor, The (2022)/The.Survivor.2021.1080p.BluRay.x264-KNiVES.mkv' 'Survivor, The (2022)'

# Swimmers, The (2022)
move_to_deleted '/mnt/synology/rs-movies/Swimmers, The (2022)/The Swimmers (2022) {imdb-tt8745676} [WEBRip-1080p][AAC 5.1][x264]-LAMA.mp4' 'Swimmers, The (2022)'

# Swiss Army Man (2016)
move_to_deleted '/mnt/synology/rs-movies/Swiss Army Man (2016)/Swiss Army Man (2016) {imdb-tt4034354} [Bluray-1080p][AC3 5.1][x264].mkv' 'Swiss Army Man (2016)'

# Synecdoche, New York (2008)
move_to_deleted '/mnt/synology/rs-movies/Synecdoche, New York (2008)/Synecdoche, New York (2008) {imdb-tt0383028} [Bluray-1080p][DTS 5.1][x264]-HiFi.mkv' 'Synecdoche, New York (2008)'

# T2 Trainspotting (2017)
move_to_deleted '/mnt/synology/rs-movies/T2 Trainspotting (2017)/T2 Trainspotting (2017) {imdb-tt2763304} [Bluray-1080p][DTS 5.1][x264]-ZQ.mkv' 'T2 Trainspotting (2017)'

# Take Cover (2024)
move_to_deleted '/mnt/synology/rs-movies/Take Cover (2024)/Take Cover (2024) {imdb-tt28129054} [WEBDL-1080p][EAC3 5.1][h264]-BANDOLEROS.mkv' 'Take Cover (2024)'

# Talk to Me (2023)
move_to_deleted '/mnt/synology/rs-movies/Talk to Me (2023)/Talk to Me (2023) {imdb-tt10638522} [WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Talk to Me (2023)'

# Tango & Cash (1989)
move_to_deleted '/mnt/synology/rs-movies/Tango & Cash (1989)/Tango & Cash (1989) {imdb-tt0098439} [Bluray-1080p][AC3 5.1][x264].mkv' 'Tango & Cash (1989)'

# Tarot (2024)
move_to_deleted '/mnt/synology/rs-movies/Tarot (2024)/Tarot (2024) {imdb-tt14088510} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'Tarot (2024)'

# Tarzan (1999)
move_to_deleted '/mnt/synology/rs-movies/Tarzan (1999)/Tarzan (1999) {imdb-tt0120855} [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv' 'Tarzan (1999)'

# Taxi Driver (1976)
move_to_deleted '/mnt/synology/rs-movies/Taxi Driver (1976)/Taxi Driver (1976) {imdb-tt0075314} [Bluray-1080p][DTS 5.1][x264]-FANDANGO.mkv' 'Taxi Driver (1976)'

# Teenage Mutant Ninja Turtles (1990)
move_to_deleted '/mnt/synology/rs-movies/Teenage Mutant Ninja Turtles (1990)/Teenage Mutant Ninja Turtles (1990) {imdb-tt0100758} [WEBDL-1080p][EAC3 5.1][x264]-APPLETARTS.mkv' 'Teenage Mutant Ninja Turtles (1990)'

# Teenage Mutant Ninja Turtles III (1993) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Teenage Mutant Ninja Turtles III (1993)/Teenage Mutant Ninja Turtles III (1993) {imdb-tt0108308} [Bluray-720p][AC3 5.1][x264].mkv' 'Teenage Mutant Ninja Turtles III (1993)'

# Teenage Mutant Ninja Turtles Mutant Mayhem (2023)
move_to_deleted '/mnt/synology/rs-movies/Teenage Mutant Ninja Turtles Mutant Mayhem (2023)/Teenage Mutant Ninja Turtles Mutant Mayhem (2023) {imdb-tt8589698} [AMZN][WEBDL-1080p Proper][EAC3 Atmos 5.1][h264]-Raphael.mkv' 'Teenage Mutant Ninja Turtles Mutant Mayhem (2023)'

# Tenacious D in The Pick of Destiny (2006)
move_to_deleted '/mnt/synology/rs-movies/Tenacious D in The Pick of Destiny (2006)/Tenacious D in The Pick of Destiny (2006) {imdb-tt0365830} [AMZN][WEBDL-1080p][DTS-ES 6.1][x264]-TenaciousD.mkv' 'Tenacious D in The Pick of Destiny (2006)'

# Terminator 2 - Judgment Day (1991)
move_to_deleted '/mnt/synology/rs-movies/Terminator 2 - Judgment Day (1991)/Terminator.2.Judgment.Day.1991.Directors.Cut.1080p.BluRay.DTS.x264-CtrlHD.mkv' 'Terminator 2 - Judgment Day (1991)'

# Terminator Dark Fate (2019)
move_to_deleted '/mnt/synology/rs-movies/Terminator Dark Fate (2019)/Terminator Dark Fate (2019) {imdb-tt6450804} [WEBDL-1080p][EAC3 5.1][h264].mkv' 'Terminator Dark Fate (2019)'

# The Terminator (1984)
move_to_deleted '/mnt/synology/rs-movies/The Terminator (1984)/The Terminator (1984) {imdb-tt0088247} [Remux-1080p][FLAC 1.0][AVC]-CiNEPHiLES.mkv' 'The Terminator (1984)'

# Terrifier (2016)
move_to_deleted '/mnt/synology/rs-movies/Terrifier (2016)/Terrifier (2018) {imdb-tt4281724} {edition-Uncut} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Terrifier (2016)'

# Terrifier 2 (2022)
move_to_deleted '/mnt/synology/rs-movies/Terrifier 2 (2022)/Terrifier 2 (2022) {imdb-tt10403420} [AMZN][WEBDL-1080p][EAC3 2.0][h264]-EVO.mkv' 'Terrifier 2 (2022)'

# Terrifier 3 (2024)
move_to_deleted '/mnt/synology/rs-movies/Terrifier 3 (2024)/Terrifier 3 (2024) {imdb-tt27911000} [WEBDL-1080p][AC3 5.1][h264]-BulkyMeekSpoonbillOfCookies.mkv' 'Terrifier 3 (2024)'

# Texas Chainsaw Massacre (2022)
move_to_deleted '/mnt/synology/rs-movies/Texas Chainsaw Massacre (2022)/Texas Chainsaw Massacre (2022) {imdb-tt11755740} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-EVO.mkv' 'Texas Chainsaw Massacre (2022)'

# Texas Chainsaw Massacre, The (2003)
move_to_deleted '/mnt/synology/rs-movies/Texas Chainsaw Massacre, The (2003)/The Texas Chainsaw Massacre (2003) {imdb-tt0324216} [Bluray-1080p][DTS 5.1][x264].mkv' 'Texas Chainsaw Massacre, The (2003)'

# Thanksgiving (2023)
move_to_deleted '/mnt/synology/rs-movies/Thanksgiving (2023)/Thanksgiving (2023) {imdb-tt1448754} [WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv' 'Thanksgiving (2023)'

# The 430 Movie (2024)
move_to_deleted '/mnt/synology/rs-movies/The 430 Movie (2024)/The 430 Movie (2024) {imdb-tt28658276} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'The 430 Movie (2024)'

# The Abandon (2024)
move_to_deleted '/mnt/synology/rs-movies/The Abandon (2024)/The Abandon (2024) {imdb-tt10273738} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'The Abandon (2024)'

# The Aftermath (2019)
move_to_deleted '/mnt/synology/rs-movies/The Aftermath (2019)/The Aftermath (2019) {imdb-tt5977276} [WEBDL-1080p][AC3 5.1][h264].mkv' 'The Aftermath (2019)'

# Alto Knights, The (2025)
move_to_deleted '/mnt/synology/rs-movies/Alto Knights, The (2025)/The Alto Knights (2025) {imdb-tt21815562} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-BYNDR.mkv' 'Alto Knights, The (2025)'

# Amateur, The (2025)
move_to_deleted '/mnt/synology/rs-movies/Amateur, The (2025)/The Amateur (2025) {imdb-tt0899043} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-DaffyCheerfulOrangutanFromUranus.mkv' 'Amateur, The (2025)'

# The Amazing Spider-Man 2 (2014)
move_to_deleted '/mnt/synology/rs-movies/The Amazing Spider-Man 2 (2014)/The Amazing Spider-Man 2 (2014) {imdb-tt1872181} [Bluray-1080p][AC3 5.1][x264]-decibeL.mkv' 'The Amazing Spider-Man 2 (2014)'

# The Art of the Steal (2014) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/The Art of the Steal (2014)/The Art of the Steal (2013) {imdb-tt2172985} [Bluray-720p][DTS 5.1][x264].mkv' 'The Art of the Steal (2014)'

# The Astronaut (2025)
move_to_deleted '/mnt/synology/rs-movies/The Astronaut (2025)/The Astronaut (2025) {imdb-tt13964560} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-KyoGo.mkv' 'The Astronaut (2025)'

# The Avengers (2012)
move_to_deleted '/mnt/synology/rs-movies/The Avengers (2012)/The Avengers (2012) {imdb-tt0848228} [DSNP][WEBDL-1080p][EAC3 Atmos 5.1][h264]-TAGWEB.mkv' 'The Avengers (2012)'

# The Bad Guys 2 (2025)
move_to_deleted '/mnt/synology/rs-movies/The Bad Guys 2 (2025)/The Bad Guys 2 (2025) {imdb-tt30017619} - [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-BYNDR.mkv' 'The Bad Guys 2 (2025)'

# The Beekeeper (2024)
move_to_deleted '/mnt/synology/rs-movies/The Beekeeper (2024)/The Beekeeper (2024) {imdb-tt15314262} [WEBDL-1080p][EAC3 5.1][h264]-LilKim.mkv' 'The Beekeeper (2024)'

# The Best Christmas Pageant Ever (2024)
move_to_deleted '/mnt/synology/rs-movies/The Best Christmas Pageant Ever (2024)/The Best Christmas Pageant Ever (2024) {imdb-tt2347285} [WEBDL-1080p Proper][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'The Best Christmas Pageant Ever (2024)'

# The Big Ugly (2020)
move_to_deleted '/mnt/synology/rs-movies/The Big Ugly (2020)/The Big Ugly (2020) {imdb-tt9441638} [WEBDL-1080p][AC3 5.1][h264].mkv' 'The Big Ugly (2020)'

# The Bikeriders (2024)
move_to_deleted '/mnt/synology/rs-movies/The Bikeriders (2024)/The Bikeriders (2024) {imdb-tt21454134} [WEBDL-1080p][EAC3 5.1][h264]-VillanelleOnABike.mkv' 'The Bikeriders (2024)'

# The Bone Collector (1999)
move_to_deleted '/mnt/synology/rs-movies/The Bone Collector (1999)/The Bone Collector (1999) {imdb-tt0145681} [Bluray-1080p][AC3 5.1][x264].mkv' 'The Bone Collector (1999)'

# The Boogeyman (2023)
move_to_deleted '/mnt/synology/rs-movies/The Boogeyman (2023)/The Boogeyman (2023) {imdb-tt3427252} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'The Boogeyman (2023)'

# The Book Thief (2013) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/The Book Thief (2013)/The Book Thief (2013) {imdb-tt0816442} [Bluray-720p][DTS 5.1][x264].mkv' 'The Book Thief (2013)'

# The Book of Clarence (2024)
move_to_deleted '/mnt/synology/rs-movies/The Book of Clarence (2024)/The Book of Clarence (2024) {imdb-tt22866358} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'The Book of Clarence (2024)'

# The Bourne Legacy (2012)
move_to_deleted '/mnt/synology/rs-movies/The Bourne Legacy (2012)/The Bourne Legacy (2012) {imdb-tt1194173} [Bluray-1080p][DTS 5.1][x264]-DON.mkv' 'The Bourne Legacy (2012)'

# The Boys in the Boat (2023)
move_to_deleted '/mnt/synology/rs-movies/The Boys in the Boat (2023)/The Boys in the Boat (2023) {imdb-tt1856080} [AMZN][WEBDL-1080p Proper][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'The Boys in the Boat (2023)'

# The Bricklayer (2023)
move_to_deleted '/mnt/synology/rs-movies/The Bricklayer (2023)/The Bricklayer (2023) {imdb-tt2016303} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-chr00t.mkv' 'The Bricklayer (2023)'

# The Channel (2023)
move_to_deleted '/mnt/synology/rs-movies/The Channel (2023)/The Channel (2023) {imdb-tt15665274} [WEBDL-1080p][EAC3 5.1][h264]-ETHEL.mkv' 'The Channel (2023)'

# The Chronicles of Riddick (2004)
move_to_deleted '/mnt/synology/rs-movies/The Chronicles of Riddick (2004)/The Chronicles of Riddick (2004) {imdb-tt0296572} {edition-Director\'s Cut} [Bluray-1080p][DTS 5.1][x264]-DON.mkv' 'The Chronicles of Riddick (2004)'

# The Coffee Table (2022)
move_to_deleted '/mnt/synology/rs-movies/The Coffee Table (2022)/The Coffee Table (2022) {imdb-tt21874760} [AMZN][WEBDL-1080p][EAC3 2.0][h264]-BYNDR.mkv' 'The Coffee Table (2022)'

# The Color Purple (2023)
move_to_deleted '/mnt/synology/rs-movies/The Color Purple (2023)/The Color Purple (2023) {imdb-tt1200263} [WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'The Color Purple (2023)'

# The Conjuring (2013)
move_to_deleted '/mnt/synology/rs-movies/The Conjuring (2013)/The Conjuring (2013) {imdb-tt1457767} [Bluray-1080p][DTS 5.1][x264]-decibeL.mkv' 'The Conjuring (2013)'

# The Conjuring 2 (2016)
move_to_deleted '/mnt/synology/rs-movies/The Conjuring 2 (2016)/The Conjuring 2 (2016) {imdb-tt3065204} [WEBDL-1080p][AC3 5.1][x264]-TWA.mkv' 'The Conjuring 2 (2016)'

# The Conspirator (2010) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/The Conspirator (2010)/The Conspirator (2011) {imdb-tt0968264} [Bluray-720p][AC3 5.1][x264].mkv' 'The Conspirator (2010)'

# The Convert (2024)
move_to_deleted '/mnt/synology/rs-movies/The Convert (2024)/The Convert (2024) {imdb-tt20113412} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'The Convert (2024)'

# The Count of Monte-Cristo (2024)
move_to_deleted '/mnt/synology/rs-movies/The Count of Monte-Cristo (2024)/The Count of Monte-Cristo (2024) {imdb-tt26446278} [Bluray-1080p][EAC3 7.1][x264]-SPHD.mkv' 'The Count of Monte-Cristo (2024)'

# The Cowboy Way (1994)
move_to_deleted '/mnt/synology/rs-movies/The Cowboy Way (1994)/The Cowboy Way (1994) {imdb-tt0109493} [WEBDL-1080p][DTS 5.1][x264]-GUACAMOLE.mkv' 'The Cowboy Way (1994)'

# The Creator (2023)
move_to_deleted '/mnt/synology/rs-movies/The Creator (2023)/The Creator (2023) {imdb-tt11858890} [MA][WEBDL-1080p Proper][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'The Creator (2023)'

# The Crow (1994)
move_to_deleted '/mnt/synology/rs-movies/The Crow (1994)/The Crow (1994) {imdb-tt0109506} [Bluray-1080p][DV HDR10][EAC3 5.1][x265]-BV.mkv' 'The Crow (1994)'

# The Crow (2024)
move_to_deleted '/mnt/synology/rs-movies/The Crow (2024)/The Crow (2024) {imdb-tt1340094} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-SLOT.mkv' 'The Crow (2024)'

# The Dark Knight (2008)
move_to_deleted '/mnt/synology/rs-movies/The Dark Knight (2008)/The Dark Knight (2008) {imdb-tt0468569} {edition-Imax} [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv' 'The Dark Knight (2008)'

# The Day the Earth Stood Still (2008)
move_to_deleted '/mnt/synology/rs-movies/The Day the Earth Stood Still (2008)/The Day the Earth Stood Still (2008) {imdb-tt0970416} {edition-Open Matte} [AMZN][WEBDL-1080p][AC3 5.1][AVC].mkv' 'The Day the Earth Stood Still (2008)'

# The Dead Don\'t Hurt (2024)
move_to_deleted '/mnt/synology/rs-movies/The Dead Don\'t Hurt (2024)/The Dead Don\'t Hurt (2024) {imdb-tt22773644} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-SLOT.mkv' 'The Dead Don\'t Hurt (2024)'

# The Departed (2006)
move_to_deleted '/mnt/synology/rs-movies/The Departed (2006)/The Departed (2006) {imdb-tt0407887} [Bluray-1080p][DTS 5.1][x264]-D-Z0N3.mkv' 'The Departed (2006)'

# The Devil All the Time (2020)
move_to_deleted '/mnt/synology/rs-movies/The Devil All the Time (2020)/The Devil All the Time (2020) {imdb-tt7395114} [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv' 'The Devil All the Time (2020)'

# Devil Conspiracy, The (2023)
move_to_deleted '/mnt/synology/rs-movies/Devil Conspiracy, The (2023)/The Devil Conspiracy (2023) {imdb-tt9663168} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Devil Conspiracy, The (2023)'

# The Dive (2023)
move_to_deleted '/mnt/synology/rs-movies/The Dive (2023)/The Dive (2023) {imdb-tt13566172} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'The Dive (2023)'

# The Doors (1991)
move_to_deleted '/mnt/synology/rs-movies/The Doors (1991)/The Doors (1991) {imdb-tt0101761} [Bluray-1080p][DTS 5.1][x264].mkv' 'The Doors (1991)'

# The Double (2011)
move_to_deleted '/mnt/synology/rs-movies/The Double (2011)/The Double (2011) {imdb-tt1646980} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-RegEdits.mkv' 'The Double (2011)'

# The Emperor\'s New Groove 2 Kronk\'s New Groove (2005) (480p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/The Emperor\'s New Groove 2 Kronk\'s New Groove (2005)/Kronk\'s New Groove (2005) {imdb-tt0401398} [DVD][DTS 5.1][MPEG2].mkv' 'The Emperor\'s New Groove 2 Kronk\'s New Groove (2005)'

# The End We Start From (2023)
move_to_deleted '/mnt/synology/rs-movies/The End We Start From (2023)/The End We Start From (2023) {imdb-tt21810682} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'The End We Start From (2023)'

# The Equalizer (2014)
move_to_deleted '/mnt/synology/rs-movies/The Equalizer (2014)/The Equalizer (2014) {imdb-tt0455944} [Bluray-1080p][DTS 5.1][x264].mkv' 'The Equalizer (2014)'

# The Equalizer 3 (2023)
move_to_deleted '/mnt/synology/rs-movies/The Equalizer 3 (2023)/The Equalizer 3 (2023) {imdb-tt17024450} [MA][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv' 'The Equalizer 3 (2023)'

# The Expendables 3 (2014)
move_to_deleted '/mnt/synology/rs-movies/The Expendables 3 (2014)/The Expendables 3 (2014) {imdb-tt2333784} [Bluray-1080p][AC3 5.1][x264].mkv' 'The Expendables 3 (2014)'

# The Faculty (1998)
move_to_deleted '/mnt/synology/rs-movies/The Faculty (1998)/The Faculty (1998) {imdb-tt0133751} [Bluray-1080p][DTS 5.1][x264]-SbR.mkv' 'The Faculty (1998)'

# The Fall Guy (2024)
move_to_deleted '/mnt/synology/rs-movies/The Fall Guy (2024)/The Fall Guy (2024) {imdb-tt1684562} {edition-Extended Version} [WEBDL-1080p Proper][EAC3 5.1][x264]-FLUX.mkv' 'The Fall Guy (2024)'

# The Fast and the Furious - Tokyo Drift (2006)
move_to_deleted '/mnt/synology/rs-movies/The Fast and the Furious - Tokyo Drift (2006)/The Fast and the Furious Tokyo Drift (2006) {imdb-tt0463985} {edition-Open Matte} [WEBDL-1080p][EAC3 5.1][h264]-spartanec163.mkv' 'The Fast and the Furious - Tokyo Drift (2006)'

# The Fifth Element (1997)
move_to_deleted '/mnt/synology/rs-movies/The Fifth Element (1997)/The Fifth Element (1997) {imdb-tt0119116} {edition-Remastered} [Bluray-1080p][DTS 5.1][x264]-HiDt.mkv' 'The Fifth Element (1997)'

# The First Omen (2024)
move_to_deleted '/mnt/synology/rs-movies/The First Omen (2024)/The First Omen (2024) {imdb-tt5672290} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'The First Omen (2024)'

# The Five-Year Engagement (2012)
move_to_deleted '/mnt/synology/rs-movies/The Five-Year Engagement (2012)/The Five-Year Engagement (2012) {imdb-tt1195478} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-NAN0.mkv' 'The Five-Year Engagement (2012)'

# The Fix (2024)
move_to_deleted '/mnt/synology/rs-movies/The Fix (2024)/The Fix (2024) {imdb-tt10284944} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'The Fix (2024)'

# The Flying Swords of Dragon Gate (2011) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/The Flying Swords of Dragon Gate (2011)/Flying Swords of Dragon Gate (2011) {imdb-tt1686784} [Bluray-720p][AC3 5.1][x264]-EbP.mkv' 'The Flying Swords of Dragon Gate (2011)'

# Front Room, The (2024)
move_to_deleted '/mnt/synology/rs-movies/Front Room, The (2024)/The Front Room (2024) {imdb-tt21905744} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Front Room, The (2024)'

# The Fugitive (1993)
move_to_deleted '/mnt/synology/rs-movies/The Fugitive (1993)/The Fugitive (1993) {imdb-tt0106977} [Bluray-1080p][AC3 5.1][x264].mkv' 'The Fugitive (1993)'

# The Girlfriend Experience (2009) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/The Girlfriend Experience (2009)/The Girlfriend Experience (2009) {imdb-tt1103982} [Bluray-720p][DTS 5.1][x264].mkv' 'The Girlfriend Experience (2009)'

# The Grand Budapest Hotel (2014)
move_to_deleted '/mnt/synology/rs-movies/The Grand Budapest Hotel (2014)/The Grand Budapest Hotel (2014) {imdb-tt2278388} [Bluray-1080p][DTS 5.1][x264]-DON.mkv' 'The Grand Budapest Hotel (2014)'

# The Great Gatsby (2013)
move_to_deleted '/mnt/synology/rs-movies/The Great Gatsby (2013)/The Great Gatsby (2013) {imdb-tt1343092} [Bluray-1080p Proper][HDR10][EAC3 5.1][x265]-DON.mkv' 'The Great Gatsby (2013)'

# The Green Mile (1999)
move_to_deleted '/mnt/synology/rs-movies/The Green Mile (1999)/The Green Mile (1999) {imdb-tt0120689} [WEBRip-1080p][EAC3 Atmos 7.1][x264]-HiDt.mkv' 'The Green Mile (1999)'

# The Guest (2014)
move_to_deleted '/mnt/synology/rs-movies/The Guest (2014)/The Guest (2014) {imdb-tt2980592} [Remux-1080p][DTS-HD MA 5.1][h264].mkv' 'The Guest (2014)'

# The Hangover (2009)
move_to_deleted '/mnt/synology/rs-movies/The Hangover (2009)/The Hangover (2009) {imdb-tt1119646} {edition-Unrated} [Bluray-1080p][AC3 5.1][x264]-REFiNED.mkv' 'The Hangover (2009)'

# The Hill (2023)
move_to_deleted '/mnt/synology/rs-movies/The Hill (2023)/The Hill (2023) {imdb-tt8051894} [NF][WEBDL-1080p][EAC3 5.1][x264]-Kitsune.mkv' 'The Hill (2023)'

# The Hobbit An Unexpected Journey (2012)
move_to_deleted '/mnt/synology/rs-movies/The Hobbit An Unexpected Journey (2012)/The Hobbit An Unexpected Journey (2012) {imdb-tt0903624} [Bluray-1080p][DTS 5.1][x264].mkv' 'The Hobbit An Unexpected Journey (2012)'

# Home, The (2025)
move_to_deleted '/mnt/synology/rs-movies/Home, The (2025)/The Home (2025) {imdb-tt17023012} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-KBOX.mkv' 'Home, The (2025)'

# The Hunger Games (2012)
move_to_deleted '/mnt/synology/rs-movies/The Hunger Games (2012)/The Hunger Games (2012) {imdb-tt1392170} [Bluray-1080p][HDR10][EAC3 7.1][x265]-D-Z0N3.mkv' 'The Hunger Games (2012)'

# The Hunger Games The Ballad of Songbirds and Snakes (2023)
move_to_deleted '/mnt/synology/rs-movies/The Hunger Games The Ballad of Songbirds and Snakes (2023)/The Hunger Games The Ballad of Songbirds & Snakes (2023) {imdb-tt10545296} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'The Hunger Games The Ballad of Songbirds and Snakes (2023)'

# The Hunt for Red October (1990)
move_to_deleted '/mnt/synology/rs-movies/The Hunt for Red October (1990)/The Hunt for Red October (1990) {imdb-tt0099810} [Bluray-1080p][DTS 5.1][x264].mkv' 'The Hunt for Red October (1990)'

# The Interview (2014)
move_to_deleted '/mnt/synology/rs-movies/The Interview (2014)/The Interview (2014) {imdb-tt2788710} [HDTV-1080p][AAC 2.0][h264].mkv' 'The Interview (2014)'

# The Iron Claw (2023)
move_to_deleted '/mnt/synology/rs-movies/The Iron Claw (2023)/The Iron Claw (2023) {imdb-tt21064584} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'The Iron Claw (2023)'

# The Island (2023)
move_to_deleted '/mnt/synology/rs-movies/The Island (2023)/Island of the Dolls (2023) {imdb-tt16158790} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv' 'The Island (2023)'

# The Kill Room (2023)
move_to_deleted '/mnt/synology/rs-movies/The Kill Room (2023)/The Kill Room (2023) {imdb-tt11908172} [WEBDL-1080p][EAC3 5.1][h264]-ZeroTwo.mkv' 'The Kill Room (2023)'

# The Killer (2023)
move_to_deleted '/mnt/synology/rs-movies/The Killer (2023)/The Killer (2023) {imdb-tt1136617} [NF][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv' 'The Killer (2023)'

# The Kingdom (2007)
move_to_deleted '/mnt/synology/rs-movies/The Kingdom (2007)/The Kingdom (2007) {imdb-tt0431197} {edition-Open Matte} [WEBDL-1080p][DTS-HD MA 5.1][h264].mkv' 'The Kingdom (2007)'

# The Land Before Time (1988)
move_to_deleted '/mnt/synology/rs-movies/The Land Before Time (1988)/The Land Before Time (1988) {imdb-tt0095489} [WEBDL-1080p][AAC 2.0][h264]-PiTBULL.mkv' 'The Land Before Time (1988)'

# The Land Before Time II The Great Valley Adventure (1994)
move_to_deleted '/mnt/synology/rs-movies/The Land Before Time II The Great Valley Adventure (1994)/The Land Before Time II The Great Valley Adventure (1994) {imdb-tt0110300} [AMZN][WEBRip-1080p][EAC3 2.0][x264]-SiGMA.mkv' 'The Land Before Time II The Great Valley Adventure (1994)'

# The Last Lions (2011) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/The Last Lions (2011)/The Last Lions (2011) {imdb-tt1692928} [HDTV-720p][DTS 5.1][x264].mkv' 'The Last Lions (2011)'

# The Last Stop in Yuma County (2024)
move_to_deleted '/mnt/synology/rs-movies/The Last Stop in Yuma County (2024)/The Last Stop in Yuma County (2024) {imdb-tt11674730} [AMZN MA][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'The Last Stop in Yuma County (2024)'

# The Last Voyage of the Demeter (2023)
move_to_deleted '/mnt/synology/rs-movies/The Last Voyage of the Demeter (2023)/The Last Voyage of the Demeter (2023) {imdb-tt1001520} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'The Last Voyage of the Demeter (2023)'

# The Lego Batman Movie (2017)
move_to_deleted '/mnt/synology/rs-movies/The Lego Batman Movie (2017)/The Lego Batman Movie (2017) {imdb-tt4116284} [WEBDL-1080p][AC3 5.1][h264]-MiDWEEK.mp4' 'The Lego Batman Movie (2017)'

# Life of Chuck, The (2025)
move_to_deleted '/mnt/synology/rs-movies/Life of Chuck, The (2025)/The Life of Chuck (2025) {imdb-tt12908150} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'Life of Chuck, The (2025)'

# The Life of David Gale (2003)
move_to_deleted '/mnt/synology/rs-movies/The Life of David Gale (2003)/The Life of David Gale (2003) {imdb-tt0289992} [WEBDL-1080p][DTS 5.1][x264]-CtrlHD.mkv' 'The Life of David Gale (2003)'

# Little Mermaid, The (2023)
move_to_deleted '/mnt/synology/rs-movies/Little Mermaid, The (2023)/The Little Mermaid (2023) {imdb-tt5971474} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Little Mermaid, The (2023)'

# The Long Walk (2025)
move_to_deleted '/mnt/synology/rs-movies/The Long Walk (2025)/The Long Walk (2025) {imdb-tt10374610} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'The Long Walk (2025)'

# The Lord of the Rings The War of the Rohirrim (2024)
move_to_deleted '/mnt/synology/rs-movies/The Lord of the Rings The War of the Rohirrim (2024)/The Lord of the Rings The War of the Rohirrim (2024) {imdb-tt14824600} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'The Lord of the Rings The War of the Rohirrim (2024)'

# The Magnificent Seven (1960)
move_to_deleted '/mnt/synology/rs-movies/The Magnificent Seven (1960)/The Magnificent Seven (1960) {imdb-tt0054047} [Bluray-1080p][DTS 5.1][x264]-DON.mkv' 'The Magnificent Seven (1960)'

# The Man in the White Van (2024)
move_to_deleted '/mnt/synology/rs-movies/The Man in the White Van (2024)/The Man in the White Van (2024) {imdb-tt13232552} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-HypStu.mkv' 'The Man in the White Van (2024)'

# The Martian (2015)
move_to_deleted '/mnt/synology/rs-movies/The Martian (2015)/The Martian (2015) {imdb-tt3659388} {edition-Extended Cut} [Bluray-1080p][DTS 5.1][x264]-VietHD.mkv' 'The Martian (2015)'

# The Matrix (1999)
move_to_deleted '/mnt/synology/rs-movies/The Matrix (1999)/The Matrix (1999) {imdb-tt0133093} [Bluray-1080p][DTS 5.1][x264].mkv' 'The Matrix (1999)'

# The Matrix Reloaded (2003)
move_to_deleted '/mnt/synology/rs-movies/The Matrix Reloaded (2003)/The Matrix Reloaded (2003) {imdb-tt0234215} [Bluray-1080p][DTS 5.1][x264].mkv' 'The Matrix Reloaded (2003)'

# The Matrix Revolutions (2003)
move_to_deleted '/mnt/synology/rs-movies/The Matrix Revolutions (2003)/The Matrix Revolutions (2003) {imdb-tt0242653} [Bluray-1080p][DTS 5.1][x264].mkv' 'The Matrix Revolutions (2003)'

# The Mechanic (2011)
move_to_deleted '/mnt/synology/rs-movies/The Mechanic (2011)/The Mechanic (2011) {imdb-tt0472399} [Bluray-1080p][AC3 5.1][x264].mkv' 'The Mechanic (2011)'

# The Menendez Brothers (2024)
move_to_deleted '/mnt/synology/rs-movies/The Menendez Brothers (2024)/The Menendez Brothers (2024) {imdb-tt33481094} [WEBRip-1080p][AAC 5.1][x265]-DH.mkv' 'The Menendez Brothers (2024)'

# The Ministry of Ungentlemanly Warfare (2024)
move_to_deleted '/mnt/synology/rs-movies/The Ministry of Ungentlemanly Warfare (2024)/The Ministry of Ungentlemanly Warfare (2024) {imdb-tt5177120} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'The Ministry of Ungentlemanly Warfare (2024)'

# The Mist (2007) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/The Mist (2007)/The Mist (2007) {imdb-tt0884328} [Bluray-720p][DTS 5.1][x264].mkv' 'The Mist (2007)'

# Mother, The (2023)
move_to_deleted '/mnt/synology/rs-movies/Mother, The (2023)/Mother\'s Day (2023) {imdb-tt19724192} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv' 'Mother, The (2023)'

# The Mummy - Tomb of the Dragon Emperor (2008)
move_to_deleted '/mnt/synology/rs-movies/The Mummy - Tomb of the Dragon Emperor (2008)/The Mummy Tomb of the Dragon Emperor (2008) {imdb-tt0859163} [Bluray-1080p][EAC3 7.1][x264].mkv' 'The Mummy - Tomb of the Dragon Emperor (2008)'

# The Mummy Returns (2001)
move_to_deleted '/mnt/synology/rs-movies/The Mummy Returns (2001)/The Mummy Returns (2001) {imdb-tt0209163} [Bluray-1080p][EAC3 7.1][x264].mkv' 'The Mummy Returns (2001)'

# The Muppets (2011)
move_to_deleted '/mnt/synology/rs-movies/The Muppets (2011)/The Muppets (2011) {imdb-tt1204342} [WEBDL-1080p][EAC3 5.1][h264]-CiNEMiX.mkv' 'The Muppets (2011)'

# The Naked Gun (2025)
move_to_deleted '/mnt/synology/rs-movies/The Naked Gun (2025)/The Naked Gun (2025) {imdb-tt3402138} - [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-BYNDR.mkv' 'The Naked Gun (2025)'

# The Notebook (2004) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/The Notebook (2004)/The Notebook (2004) {imdb-tt0332280} [Bluray-720p][AC3 5.1][x264].mkv' 'The Notebook (2004)'

# The Nun (2018)
move_to_deleted '/mnt/synology/rs-movies/The Nun (2018)/The Nun (2018) {imdb-tt5814060} [Bluray-1080p][DTS 5.1][x264].mkv' 'The Nun (2018)'

# Nun II, The (2023)
move_to_deleted '/mnt/synology/rs-movies/Nun II, The (2023)/The Nun II (2023) {imdb-tt10160976} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Nun II, The (2023)'

# The Out-Laws (2023)
move_to_deleted '/mnt/synology/rs-movies/The Out-Laws (2023)/The Out-Laws (2023) {imdb-tt11274492} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-CMRG.mkv' 'The Out-Laws (2023)'

# The Patriot (2000)
move_to_deleted '/mnt/synology/rs-movies/The Patriot (2000)/The Patriot (2000) {imdb-tt0187393} {edition-Theatrical Cut Open Matte} [AMZN][WEBDL-1080p][EAC3 5.1][AVC].mkv' 'The Patriot (2000)'

# The Pelican Brief (1993) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/The Pelican Brief (1993)/The Pelican Brief (1993) {imdb-tt0107798} [Bluray-720p][DTS 5.1][x264].mkv' 'The Pelican Brief (1993)'

# The Penguin Lessons (2025)
move_to_deleted '/mnt/synology/rs-movies/The Penguin Lessons (2025)/The Penguin Lessons (2025) {imdb-tt26677014} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'The Penguin Lessons (2025)'

# The Place Beyond the Pines (2012)
move_to_deleted '/mnt/synology/rs-movies/The Place Beyond the Pines (2012)/The Place Beyond the Pines (2013) {imdb-tt1817273} [Bluray-1080p][AC3 5.1][x264]-EbP.mkv' 'The Place Beyond the Pines (2012)'

# The Popes Exorcist (2023)
move_to_deleted '/mnt/synology/rs-movies/The Popes Exorcist (2023)/The Pope\'s Exorcist (2023) {imdb-tt13375076} [MA][WEBDL-1080p][EAC3 5.1][x264]-APEX.mkv' 'The Popes Exorcist (2023)'

# The Portable Door (2023)
move_to_deleted '/mnt/synology/rs-movies/The Portable Door (2023)/The Portable Door (2023) {imdb-tt11820950} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'The Portable Door (2023)'

# The Prosecutor (2024)
move_to_deleted '/mnt/synology/rs-movies/The Prosecutor (2024)/The Prosecutor (2024) {imdb-tt30024043} [WEBDL-1080p][AAC 2.0][h264]-HHWEB.mkv' 'The Prosecutor (2024)'

# The Raid - Redemption (2011)
move_to_deleted '/mnt/synology/rs-movies/The Raid - Redemption (2011)/The Raid (2012) {imdb-tt1899353} [Bluray-1080p][AAC 5.1][x265].mkv' 'The Raid - Redemption (2011)'

# The Rescuers Down Under (1990)
move_to_deleted '/mnt/synology/rs-movies/The Rescuers Down Under (1990)/The Rescuers Down Under (1990) {imdb-tt0100477} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'The Rescuers Down Under (1990)'

# The Roses (2025)
move_to_deleted '/mnt/synology/rs-movies/The Roses (2025)/The Roses (2025) {imdb-tt31973693} - [AMZN][WEBDL-1080p][EAC3 5.1][h264]-KyoGo.mkv' 'The Roses (2025)'

# The Roundup Punishment (2024)
move_to_deleted '/mnt/synology/rs-movies/The Roundup Punishment (2024)/The Roundup Punishment (2024) {imdb-tt27811040} [WEBDL-1080p][EAC3 5.1][h264]-MaDongSech.mkv' 'The Roundup Punishment (2024)'

# The Royal Hotel (2023)
move_to_deleted '/mnt/synology/rs-movies/The Royal Hotel (2023)/The Royal Hotel (2023) {imdb-tt18363072} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'The Royal Hotel (2023)'

# Secret of NIMH, The (1982)
move_to_deleted '/mnt/synology/rs-movies/Secret of NIMH, The (1982)/The Secret of NIMH (1982) {imdb-tt0084649} [WEBDL-1080p][DTS 2.0][x264].mkv' 'Secret of NIMH, The (1982)'

# The Seed of the Sacred Fig (2024)
move_to_deleted '/mnt/synology/rs-movies/The Seed of the Sacred Fig (2024)/The Seed of the Sacred Fig (2024) {imdb-tt32178949} [WEBDL-1080p][AAC 2.0][h264]-NaNi.mkv' 'The Seed of the Sacred Fig (2024)'

# The Settlers (2023)
move_to_deleted '/mnt/synology/rs-movies/The Settlers (2023)/The Settlers (2023) {imdb-tt10370812} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'The Settlers (2023)'

# The Shawshank Redemption (1994)
move_to_deleted '/mnt/synology/rs-movies/The Shawshank Redemption (1994)/The Shawshank Redemption (1994) {imdb-tt0111161} [Bluray-1080p][DV HDR10][EAC3 5.1][x265]-SA89.mkv' 'The Shawshank Redemption (1994)'

# Six Triple Eight, The (2024) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Six Triple Eight, The (2024)/The Six Triple Eight (2024) {imdb-tt24458622} [NF][WEBDL-720p][EAC3 Atmos 5.1][x264]-NoRBiT.mkv' 'Six Triple Eight, The (2024)'

# The Sixth Sense (1999)
move_to_deleted '/mnt/synology/rs-movies/The Sixth Sense (1999)/The Sixth Sense (1999) {imdb-tt0167404} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv' 'The Sixth Sense (1999)'

# The Strangers Chapter 1 (2024)
move_to_deleted '/mnt/synology/rs-movies/The Strangers Chapter 1 (2024)/The Strangers Chapter 1 (2024) {imdb-tt22050754} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'The Strangers Chapter 1 (2024)'

# The Substance (2024)
move_to_deleted '/mnt/synology/rs-movies/The Substance (2024)/The Substance (2024) {imdb-tt17526714} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv' 'The Substance (2024)'

# Sum of All Fears, The (2002)
move_to_deleted '/mnt/synology/rs-movies/Sum of All Fears, The (2002)/The Sum of All Fears (2002) {imdb-tt0164184} [Remux-1080p][TrueHD 5.1][AVC]-KRaLiMaRKo.mkv' 'Sum of All Fears, The (2002)'

# The Surfer (2025)
move_to_deleted '/mnt/synology/rs-movies/The Surfer (2025)/The Surfer (2025) {imdb-tt27813235} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'The Surfer (2025)'

# The Thicket (2024)
move_to_deleted '/mnt/synology/rs-movies/The Thicket (2024)/The Thicket (2024) {imdb-tt4058618} [AMZN][WEBDL-1080p][EAC3 2.0][h264]-BYNDR.mkv' 'The Thicket (2024)'

# The Tourist (2010)
move_to_deleted '/mnt/synology/rs-movies/The Tourist (2010)/The Tourist (2010) {imdb-tt1243957} [Bluray-1080p][EAC3 5.1][x264]-playHD.mkv' 'The Tourist (2010)'

# The Town (2010)
move_to_deleted '/mnt/synology/rs-movies/The Town (2010)/The Town (2010) {imdb-tt0840361} {edition-Extended} [Bluray-1080p][AC3 5.1][x264]-EbP.mkv' 'The Town (2010)'

# The Toxic Avenger Unrated (2025)
move_to_deleted '/mnt/synology/rs-movies/The Toxic Avenger Unrated (2025)/The Toxic Avenger Unrated (2025) {imdb-tt1633359} - {edition-Unrated} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-HONE.mkv' 'The Toxic Avenger Unrated (2025)'

# The Ugly Stepsister (2025)
move_to_deleted '/mnt/synology/rs-movies/The Ugly Stepsister (2025)/The Ugly Stepsister (2025) {imdb-tt29344903} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-HONE.mkv' 'The Ugly Stepsister (2025)'

# The Wandering Earth II (2023)
move_to_deleted '/mnt/synology/rs-movies/The Wandering Earth II (2023)/The Wandering Earth II (2023) {imdb-tt13539646} [WEBDL-1080p][AAC 2.0][x264]-AOC.mkv' 'The Wandering Earth II (2023)'

# The Watch (2012)
move_to_deleted '/mnt/synology/rs-movies/The Watch (2012)/The Watch (2012) {imdb-tt1298649} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'The Watch (2012)'

# The Water Horse (2007) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/The Water Horse (2007)/The Water Horse (2007) {imdb-tt0760329} [Bluray-720p][AC3 5.1][x264]-LolHD.mkv' 'The Water Horse (2007)'

# Witcher Sirens of the Deep, The (2025)
move_to_deleted '/mnt/synology/rs-movies/Witcher Sirens of the Deep, The (2025)/The Witcher Sirens of the Deep (2025) {imdb-tt15495150} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Witcher Sirens of the Deep, The (2025)'

# The Wrath of Becky (2023)
move_to_deleted '/mnt/synology/rs-movies/The Wrath of Becky (2023)/The Wrath of Becky (2023) {imdb-tt20916568} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-SCOPE.mkv' 'The Wrath of Becky (2023)'

# The Zone of Interest (2023)
move_to_deleted '/mnt/synology/rs-movies/The Zone of Interest (2023)/The Zone of Interest (2023) {imdb-tt7160372} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'The Zone of Interest (2023)'

# Thelma & Louise (1991)
move_to_deleted '/mnt/synology/rs-movies/Thelma & Louise (1991)/Thelma & Louise (1991) {imdb-tt0103074} [Bluray-1080p][DTS 5.1][x264].mkv' 'Thelma & Louise (1991)'

# There Are No Saints (2022)
move_to_deleted '/mnt/synology/rs-movies/There Are No Saints (2022)/There Are No Saints (2022) {imdb-tt1655444} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv' 'There Are No Saints (2022)'

# Thir13en Ghosts (2001)
move_to_deleted '/mnt/synology/rs-movies/Thir13en Ghosts (2001)/Thir13en Ghosts (2001) {imdb-tt0245674} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-YUUNMY.mkv' 'Thir13en Ghosts (2001)'

# Thor (2011)
move_to_deleted '/mnt/synology/rs-movies/Thor (2011)/Thor (2011) {imdb-tt0800369} [DSNP][WEBDL-1080p][EAC3 Atmos 5.1][h264]-Samuel.mkv' 'Thor (2011)'

# Thor Love and Thunder (2022)
move_to_deleted '/mnt/synology/rs-movies/Thor Love and Thunder (2022)/Thor Love and Thunder (2022) {imdb-tt10648342} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-CMRG.mkv' 'Thor Love and Thunder (2022)'

# Thor Ragnarok (2017)
move_to_deleted '/mnt/synology/rs-movies/Thor Ragnarok (2017)/Thor Ragnarok (2017) {imdb-tt3501632} [Bluray-1080p][AC3 5.1][x264].mkv' 'Thor Ragnarok (2017)'

# Those Who Wish Me Dead (2021)
move_to_deleted '/mnt/synology/rs-movies/Those Who Wish Me Dead (2021)/Those Who Wish Me Dead (2021) {imdb-tt3215824} [HMAX][WEBDL-1080p][AC3 5.1][x264]-CMRG.mkv' 'Those Who Wish Me Dead (2021)'

# Three Musketeers D\'Artagnan, The (2023)
move_to_deleted '/mnt/synology/rs-movies/Three Musketeers D\'Artagnan, The (2023)/The Three Musketeers D\'Artagnan (2023) {imdb-tt12672536} [Bluray-1080p][PCM 2.0][h264].mkv' 'Three Musketeers D\'Artagnan, The (2023)'

# Three Musketeers Milady, The (2023)
move_to_deleted '/mnt/synology/rs-movies/Three Musketeers Milady, The (2023)/The Three Musketeers Milady (2023) {imdb-tt12672620} [Bluray-1080p][EAC3 7.1][x264]-PTer.mkv' 'Three Musketeers Milady, The (2023)'

# Three Thousand Years of Longing (2022)
move_to_deleted '/mnt/synology/rs-movies/Three Thousand Years of Longing (2022)/Three Thousand Years of Longing (2022) {imdb-tt9198364} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-SMURF.mkv' 'Three Thousand Years of Longing (2022)'

# Thunderball (1965)
move_to_deleted '/mnt/synology/rs-movies/Thunderball (1965)/Thunderball (1965) {imdb-tt0059800} [Bluray-1080p][DTS 5.1][x264]-NTb.mkv' 'Thunderball (1965)'

# Thunderbolts (2024)
move_to_deleted '/mnt/synology/rs-movies/Thunderbolts (2024)/Thunderbolts- (2025) {imdb-tt20969586} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-ETHEL.mkv' 'Thunderbolts (2024)'

# Ticket to Paradise (2022)
move_to_deleted '/mnt/synology/rs-movies/Ticket to Paradise (2022)/Ticket to Paradise (2022) {imdb-tt14109724} [Bluray-1080p][EAC3 7.1][x264]-PTer.mkv' 'Ticket to Paradise (2022)'

# Time Cut (2024)
move_to_deleted '/mnt/synology/rs-movies/Time Cut (2024)/Time Cut (2024) {imdb-tt14857528} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-OzONE.mkv' 'Time Cut (2024)'

# Timecop (1994)
move_to_deleted '/mnt/synology/rs-movies/Timecop (1994)/Timecop (1994) {imdb-tt0111438} [Bluray-1080p][DTS 5.1][x264]-FoRM.mkv' 'Timecop (1994)'

# Tinker Bell (2008)
move_to_deleted '/mnt/synology/rs-movies/Tinker Bell (2008)/Tinker Bell (2008) {imdb-tt0823671} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Tinker Bell (2008)'

# Titanic (1997)
move_to_deleted '/mnt/synology/rs-movies/Titanic (1997)/Titanic (1997) {imdb-tt0120338} [Bluray-1080p][DTS 5.1][x264]-DON.mkv' 'Titanic (1997)'

# To End All War Oppenheimer and the Atomic Bomb (2023)
move_to_deleted '/mnt/synology/rs-movies/To End All War Oppenheimer and the Atomic Bomb (2023)/To End All War Oppenheimer & the Atomic Bomb (2023) {imdb-tt28240284} [PCOK][WEBDL-1080p][EAC3 5.1][x264]-PTerWEB.mkv' 'To End All War Oppenheimer and the Atomic Bomb (2023)'

# To Gerard (2020)
move_to_deleted '/mnt/synology/rs-movies/To Gerard (2020)/To Gerard (2020) {imdb-tt11952320} [WEBDL-1080p][EAC3 5.1][x264]-KOGi.mkv' 'To Gerard (2020)'

# To Kill a Mockingbird (1962)
move_to_deleted '/mnt/synology/rs-movies/To Kill a Mockingbird (1962)/To Kill a Mockingbird (1962) {imdb-tt0056592} [Bluray-1080p][AAC 5.1][x265].mkv' 'To Kill a Mockingbird (1962)'

# Together (2025)
move_to_deleted '/mnt/synology/rs-movies/Together (2025)/Together (2025) {imdb-tt31184028} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'Together (2025)'

# Tom & Jerry (2021)
move_to_deleted '/mnt/synology/rs-movies/Tom & Jerry (2021)/Tom & Jerry (2021) {imdb-tt1361336} [HMAX][WEBDL-1080p][EAC3 Atmos 5.1][h264]-MZABI.mkv' 'Tom & Jerry (2021)'

# Tombstone (1993)
move_to_deleted '/mnt/synology/rs-movies/Tombstone (1993)/Tombstone (1993) {imdb-tt0108358} [Bluray-1080p][DTS-HD MA 5.1][h264].mkv' 'Tombstone (1993)'

# Tomorrow War, The (2021)
move_to_deleted '/mnt/synology/rs-movies/Tomorrow War, The (2021)/The.Tomorrow.War.2021.PROPER.1080p.WEB.H264-NAISU.mkv' 'Tomorrow War, The (2021)'

# Total Recall (1990)
move_to_deleted '/mnt/synology/rs-movies/Total Recall (1990)/Total Recall (1990) {imdb-tt0100802} [Bluray-1080p][DTS 5.1][x264]-HiDt.mkv' 'Total Recall (1990)'

# Toy Story (1995)
move_to_deleted '/mnt/synology/rs-movies/Toy Story (1995)/Toy Story (1995) {imdb-tt0114709} [Bluray-1080p][DTS-ES 5.1][x264].mkv' 'Toy Story (1995)'

# Toy Story 3 (2010)
move_to_deleted '/mnt/synology/rs-movies/Toy Story 3 (2010)/Toy Story 3 (2010) {imdb-tt0435761} [Bluray-1080p][DTS-ES 5.1][x264]-ViSTA.mkv' 'Toy Story 3 (2010)'

# Trainspotting (1996)
move_to_deleted '/mnt/synology/rs-movies/Trainspotting (1996)/Trainspotting (1996) {imdb-tt0117951} [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv' 'Trainspotting (1996)'

# Transformers (2007)
move_to_deleted '/mnt/synology/rs-movies/Transformers (2007)/Transformers (2007) {imdb-tt0418279} [Bluray-1080p][DTS 5.1][x264].mkv' 'Transformers (2007)'

# Transformers Age of Extinction (2014)
move_to_deleted '/mnt/synology/rs-movies/Transformers Age of Extinction (2014)/Transformers Age of Extinction (2014) {imdb-tt2109248} [Bluray-1080p][AC3 5.1][x264].mkv' 'Transformers Age of Extinction (2014)'

# Transformers One (2024)
move_to_deleted '/mnt/synology/rs-movies/Transformers One (2024)/Transformers One (2024) {imdb-tt8864596} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Transformers One (2024)'

# Transformers Revenge of the Fallen (2009)
move_to_deleted '/mnt/synology/rs-movies/Transformers Revenge of the Fallen (2009)/Transformers Revenge of the Fallen (2009) {imdb-tt1055369} [Bluray-1080p][DTS 5.1][h264].mkv' 'Transformers Revenge of the Fallen (2009)'

# Transformers Rise of the Beasts (2023)
move_to_deleted '/mnt/synology/rs-movies/Transformers Rise of the Beasts (2023)/Transformers Rise of the Beasts (2023) {imdb-tt5090568} [WEBDL-1080p Proper][EAC3 Atmos 5.1][h264]-APEX.mkv' 'Transformers Rise of the Beasts (2023)'

# Transformers The Movie, The (1986)
move_to_deleted '/mnt/synology/rs-movies/Transformers The Movie, The (1986)/The Transformers The Movie (1986) {imdb-tt0092106} [Bluray-1080p][AC3 5.1][x264]-CtrlHD.mkv' 'Transformers The Movie, The (1986)'

# Transfusion (2023)
move_to_deleted '/mnt/synology/rs-movies/Transfusion (2023)/Transfusion (2023) {imdb-tt14873054} [WEBDL-1080p][EAC3 5.1][h264]-playWEB.mkv' 'Transfusion (2023)'

# Transporter 2 (2005) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Transporter 2 (2005)/Transporter 2 (2005) {imdb-tt0388482} [Bluray-720p][DTS 5.1][x264].mkv' 'Transporter 2 (2005)'

# Transporter 3 (2008) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Transporter 3 (2008)/Transporter 3 (2008) {imdb-tt1129442} [Bluray-720p][DTS 5.1][x264].mkv' 'Transporter 3 (2008)'

# Trial of the Chicago 7, The (2020)
move_to_deleted '/mnt/synology/rs-movies/Trial of the Chicago 7, The (2020)/The Trial of the Chicago 7 (2020) {imdb-tt1070874} [WEBDL-1080p][EAC3 5.1][x264]-EVO.mkv' 'Trial of the Chicago 7, The (2020)'

# Trick \'r Treat (2007)
move_to_deleted '/mnt/synology/rs-movies/Trick \'r Treat (2007)/Trick \'r Treat (2007) {imdb-tt0862856} [Remux-1080p Proper][TrueHD 5.1][AVC]-KRaLiMaRKo.mkv' 'Trick \'r Treat (2007)'

# Triple Frontier (2019)
move_to_deleted '/mnt/synology/rs-movies/Triple Frontier (2019)/Triple Frontier (2019) {imdb-tt1488606} [WEBRip-1080p][EAC3 Atmos 5.1][x264]-DEFLATE.mkv' 'Triple Frontier (2019)'

# Troll (2022)
move_to_deleted '/mnt/synology/rs-movies/Troll (2022)/Troll (2022) {imdb-tt11116912} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-playWEB.mkv' 'Troll (2022)'

# Trollhunters Rise of the Titans (2021)
move_to_deleted '/mnt/synology/rs-movies/Trollhunters Rise of the Titans (2021)/Trollhunters Rise of the Titans (2021) {imdb-tt12851396} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-EVO.mkv' 'Trollhunters Rise of the Titans (2021)'

# Trolls (2016)
move_to_deleted '/mnt/synology/rs-movies/Trolls (2016)/Trolls (2016) {imdb-tt1679335} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-DKV.mkv' 'Trolls (2016)'

# Trolls Holiday in Harmony (2021)
move_to_deleted '/mnt/synology/rs-movies/Trolls Holiday in Harmony (2021)/Trolls Holiday in Harmony (2021) {imdb-tt15720718} [WEBDL-1080p][AAC 2.0][x264]-DiRT.mkv' 'Trolls Holiday in Harmony (2021)'

# Trolls World Tour (2020)
move_to_deleted '/mnt/synology/rs-movies/Trolls World Tour (2020)/Trolls World Tour (2020) {imdb-tt6587640} [WEBDL-1080p][EAC3 5.1][h264].mkv' 'Trolls World Tour (2020)'

# Tron (1982)
move_to_deleted '/mnt/synology/rs-movies/Tron (1982)/Tron (1982) {imdb-tt0084827} [Bluray-1080p][DTS 5.1][x264].mkv' 'Tron (1982)'

# Trouble with the Curve (2012) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Trouble with the Curve (2012)/Trouble with the Curve (2012) {imdb-tt2083383} [Bluray-720p][AC3 5.1][x264]-EbP.mkv' 'Trouble with the Curve (2012)'

# Troy (2004)
move_to_deleted '/mnt/synology/rs-movies/Troy (2004)/Troy (2004) {imdb-tt0332452} {edition-Open Matte} [WEBDL-1080p][TrueHD 5.1][x264].mkv' 'Troy (2004)'

# True Lies (1994)
move_to_deleted '/mnt/synology/rs-movies/True Lies (1994)/True Lies (1994) {imdb-tt0111503} [Bluray-1080p][EAC3 5.1][x264].mkv' 'True Lies (1994)'

# Twilight Saga New Moon, The (2009)
move_to_deleted '/mnt/synology/rs-movies/Twilight Saga New Moon, The (2009)/The.Twilight.Saga.New.Moon.2009.Bluray.1080p.DTSMA.x264.dxva-FraMeSToR.mkv' 'Twilight Saga New Moon, The (2009)'

# Twilight of the Warriors Walled In (2024)
move_to_deleted '/mnt/synology/rs-movies/Twilight of the Warriors Walled In (2024)/Twilight of the Warriors Walled In (2024) {imdb-tt20316748} [WEBDL-1080p][EAC3 5.1][h264]-HDSWEB.mkv' 'Twilight of the Warriors Walled In (2024)'

# Twister (1996)
move_to_deleted '/mnt/synology/rs-movies/Twister (1996)/Twister (1996) {imdb-tt0117998} [Bluray-1080p][DTS 5.1][x264].mkv' 'Twister (1996)'

# Twisters (2024)
move_to_deleted '/mnt/synology/rs-movies/Twisters (2024)/Twisters (2024) {imdb-tt12584954} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Twisters (2024)'

# Umma (2022)
move_to_deleted '/mnt/synology/rs-movies/Umma (2022)/Umma (2022) {imdb-tt13235822} [MA][WEBDL-1080p][AC3 5.1][h265]-RUMOUR.mkv' 'Umma (2022)'

# The Unbearable Weight of Massive Talent (2022)
move_to_deleted '/mnt/synology/rs-movies/The Unbearable Weight of Massive Talent (2022)/The Unbearable Weight of Massive Talent (2022) {imdb-tt11291274} [Bluray-1080p][DV HDR10][EAC3 7.1][x265]-NTb.mkv' 'The Unbearable Weight of Massive Talent (2022)'

# Unbreakable (2000)
move_to_deleted '/mnt/synology/rs-movies/Unbreakable (2000)/Unbreakable (2000) {imdb-tt0217869} [Bluray-1080p][HDR10][EAC3 5.1][x265]-SA89.mkv' 'Unbreakable (2000)'

# Uncharted (2022)
move_to_deleted '/mnt/synology/rs-movies/Uncharted (2022)/Uncharted (2022) {imdb-tt1464335} [WEBDL-1080p][EAC3 5.1][x264]-EVO.mkv' 'Uncharted (2022)'

# Uncle Buck (1989)
move_to_deleted '/mnt/synology/rs-movies/Uncle Buck (1989)/Uncle Buck (1989) {imdb-tt0098554} [Bluray-1080p][DTS 2.0][x264].mkv' 'Uncle Buck (1989)'

# Uncut Gems (2019)
move_to_deleted '/mnt/synology/rs-movies/Uncut Gems (2019)/Uncut Gems (2019) {imdb-tt5727208} [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv' 'Uncut Gems (2019)'

# Underworld (2003)
move_to_deleted '/mnt/synology/rs-movies/Underworld (2003)/Underworld (2003) {imdb-tt0320691} {edition-Unrated} [Bluray-1080p][HDR10][EAC3 7.1][x265]-iFT.mkv' 'Underworld (2003)'

# Underworld Blood Wars (2016)
move_to_deleted '/mnt/synology/rs-movies/Underworld Blood Wars (2016)/Underworld Blood Wars (2016) {imdb-tt3717252} [Bluray-1080p][DTS 5.1][x264].mkv' 'Underworld Blood Wars (2016)'

# Unforgivable, The (2021)
move_to_deleted '/mnt/synology/rs-movies/Unforgivable, The (2021)/The Unforgivable (2021) {imdb-tt11233960} [WEBRip-1080p][EAC3 Atmos 5.1][x264]-playHD.mkv' 'Unforgivable, The (2021)'

# Unforgiven (1992)
move_to_deleted '/mnt/synology/rs-movies/Unforgiven (1992)/Unforgiven (1992) {imdb-tt0105695} [Bluray-1080p][AC3 2.0][x264].mkv' 'Unforgiven (1992)'

# Until Dawn (2025)
move_to_deleted '/mnt/synology/rs-movies/Until Dawn (2025)/Until Dawn (2025) {imdb-tt30955489} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-HONE.mkv' 'Until Dawn (2025)'

# Untold Johnny Football (2023)
move_to_deleted '/mnt/synology/rs-movies/Untold Johnny Football (2023)/Untold Johnny Football (2023) {imdb-tt28089651} [WEBDL-1080p][EAC3 5.1][x264]-EDITH.mkv' 'Untold Johnny Football (2023)'

# Untouchables, The (1987)
move_to_deleted '/mnt/synology/rs-movies/Untouchables, The (1987)/The Untouchables (1987) {imdb-tt0094226} [Bluray-1080p][DTS-ES 6.1][x264]-CtrlHD.mkv' 'Untouchables, The (1987)'

# Upgrade (2018)
move_to_deleted '/mnt/synology/rs-movies/Upgrade (2018)/Upgrade (2018) {imdb-tt6499752} [Bluray-1080p Proper][DTS 5.1][x264]-LoRD.mkv' 'Upgrade (2018)'

# Us Again (2021)
move_to_deleted '/mnt/synology/rs-movies/Us Again (2021)/Us Again (2021) {imdb-tt14062858} [WEBDL-1080p][AAC 2.0][h264]-Instinctive.mkv' 'Us Again (2021)'

# Usual Suspects, The (1995)
move_to_deleted '/mnt/synology/rs-movies/Usual Suspects, The (1995)/The Usual Suspects (1995) {imdb-tt0114814} [Remux-1080p][DTS-HD MA 5.1][MPEG2].mkv' 'Usual Suspects, The (1995)'

# V H S Beyond (2024)
move_to_deleted '/mnt/synology/rs-movies/V H S Beyond (2024)/V+H+S+Beyond (2024) {imdb-tt32880932} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'V H S Beyond (2024)'

# V for Vendetta (2005)
move_to_deleted '/mnt/synology/rs-movies/V for Vendetta (2005)/V for Vendetta (2006) {imdb-tt0434409} [Bluray-1080p][AC3 5.1][x264].mkv' 'V for Vendetta (2005)'

# Van Helsing (2004)
move_to_deleted '/mnt/synology/rs-movies/Van Helsing (2004)/Van Helsing (2004) {imdb-tt0338526} [Bluray-1080p][AC3 5.1][x264]-nikt0.mkv' 'Van Helsing (2004)'

# Vantage Point (2008)
move_to_deleted '/mnt/synology/rs-movies/Vantage Point (2008)/Vantage Point (2008) {imdb-tt0443274} [AMZN][WEBDL-1080p][EAC3 5.1][x264].mkv' 'Vantage Point (2008)'

# Varsity Blues (1999)
move_to_deleted '/mnt/synology/rs-movies/Varsity Blues (1999)/Varsity Blues (1999) {imdb-tt0139699} [Remux-1080p][TrueHD 5.1][AVC].mkv' 'Varsity Blues (1999)'

# Venom Let There Be Carnage (2021)
move_to_deleted '/mnt/synology/rs-movies/Venom Let There Be Carnage (2021)/Venom Let There Be Carnage (2021) {imdb-tt7097896} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv' 'Venom Let There Be Carnage (2021)'

# Vesper (2022)
move_to_deleted '/mnt/synology/rs-movies/Vesper (2022)/Vesper (2022) {imdb-tt20225374} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-SMURF.mkv' 'Vesper (2022)'

# Violent Night (2022)
move_to_deleted '/mnt/synology/rs-movies/Violent Night (2022)/Violent Night (2022) {imdb-tt12003946} [MA][WEBDL-1080p][EAC3 Atmos 5.1][x264]-FLUX.mkv' 'Violent Night (2022)'

# Vivarium (2019)
move_to_deleted '/mnt/synology/rs-movies/Vivarium (2019)/Vivarium (2019) {imdb-tt8368406} [WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv' 'Vivarium (2019)'

# Vivo (2021)
move_to_deleted '/mnt/synology/rs-movies/Vivo (2021)/Vivo (2021) {imdb-tt6338498} [NF][WEBDL-1080p][EAC3 Atmos 5.1][x264]-EVO.mkv' 'Vivo (2021)'

# Voyagers (2021)
move_to_deleted '/mnt/synology/rs-movies/Voyagers (2021)/Voyagers (2021) {imdb-tt9664108} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-EVO.mkv' 'Voyagers (2021)'

# Wander (2020)
move_to_deleted '/mnt/synology/rs-movies/Wander (2020)/Wander (2020) {imdb-tt9689696} [WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv' 'Wander (2020)'

# Wandering Earth, The (2019)
move_to_deleted '/mnt/synology/rs-movies/Wandering Earth, The (2019)/The Wandering Earth (2019) {imdb-tt7605074} [WEBDL-1080p][EAC3 Atmos 5.1][x264]-NTG.mkv' 'Wandering Earth, The (2019)'

# Wanted (2008)
move_to_deleted '/mnt/synology/rs-movies/Wanted (2008)/Wanted (2008) {imdb-tt0493464} [Bluray-1080p][DTS 5.1][x264].mkv' 'Wanted (2008)'

# War (2007)
move_to_deleted '/mnt/synology/rs-movies/War (2007)/War (2007) {imdb-tt0499556} [HMAX][WEBDL-1080p][AC3 5.1][x264]-DKV.mkv' 'War (2007)'

# War for the Planet of the Apes (2017)
move_to_deleted '/mnt/synology/rs-movies/War for the Planet of the Apes (2017)/War for the Planet of the Apes (2017) {imdb-tt3450958} [WEBDL-1080p][DTS 5.1][x264].mkv' 'War for the Planet of the Apes (2017)'

# War of the Worlds (2005)
move_to_deleted '/mnt/synology/rs-movies/War of the Worlds (2005)/War of the Worlds (2005) {imdb-tt0407304} [Bluray-1080p][DV HDR10][EAC3 7.1][x265]-SA89.mkv' 'War of the Worlds (2005)'

# WarGames (1983)
move_to_deleted '/mnt/synology/rs-movies/WarGames (1983)/WarGames (1983) {imdb-tt0086567} [Bluray-1080p][DTS 5.1][x264]-ZQ.mkv' 'WarGames (1983)'

# Warcraft (2016)
move_to_deleted '/mnt/synology/rs-movies/Warcraft (2016)/Warcraft (2016) {imdb-tt0803096} [Bluray-1080p][HDR10][EAC3 7.1][x265]-CtrlHD.mkv' 'Warcraft (2016)'

# Warhorse One (2023)
move_to_deleted '/mnt/synology/rs-movies/Warhorse One (2023)/Warhorse One (2023) {imdb-tt16527824} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-SCOPE.mkv' 'Warhorse One (2023)'

# Warhunt (2022)
move_to_deleted '/mnt/synology/rs-movies/Warhunt (2022)/WarHunt (2022) {imdb-tt6442686} [WEBDL-1080p][AC3 5.1][h264]-EVO.mkv' 'Warhunt (2022)'

# Warm Bodies (2013)
move_to_deleted '/mnt/synology/rs-movies/Warm Bodies (2013)/Warm Bodies (2013) {imdb-tt1588173} [Bluray-1080p][DTS 5.1][x264]-EbP.mkv' 'Warm Bodies (2013)'

# Warrant, The (2020)
move_to_deleted '/mnt/synology/rs-movies/Warrant, The (2020)/The Warrant (2020) {imdb-tt10880084} [WEBDL-1080p][EAC3 5.1][h264]-NTG.mkv' 'Warrant, The (2020)'

# Warriors, The (1979)
move_to_deleted '/mnt/synology/rs-movies/Warriors, The (1979)/The Warriors (1979) {imdb-tt0080120} [Bluray-1080p][AC3 5.1][x264]-SeeNHD.mkv' 'Warriors, The (1979)'

# Watcher (2022)
move_to_deleted '/mnt/synology/rs-movies/Watcher (2022)/Watcher (2022) {imdb-tt12004038} [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv' 'Watcher (2022)'

# Watchmen Chapter II (2024)
move_to_deleted '/mnt/synology/rs-movies/Watchmen Chapter II (2024)/Watchmen Chapter II (2024) {imdb-tt32627545} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Watchmen Chapter II (2024)'

# Wave, The (2015)
move_to_deleted '/mnt/synology/rs-movies/Wave, The (2015)/Bridal Wave (2015) {imdb-tt4368496} [AMZN][WEBDL-1080p][EAC3 2.0][h264]-EDGE2020.mkv' 'Wave, The (2015)'

# Way of the Dragon, The (1972)
move_to_deleted '/mnt/synology/rs-movies/Way of the Dragon, The (1972)/The Way of the Dragon (1972) {imdb-tt0068935} {edition-Remastered} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Way of the Dragon, The (1972)'

# Wayne\'s World 2 (1993)
move_to_deleted '/mnt/synology/rs-movies/Wayne\'s World 2 (1993)/Wayne\'s World 2 (1993) {imdb-tt0108525} [WEBDL-1080p][EAC3 5.1][h264]-PiRaTeS.mkv' 'Wayne\'s World 2 (1993)'

# We Live in Time (2024)
move_to_deleted '/mnt/synology/rs-movies/We Live in Time (2024)/We Live in Time (2024) {imdb-tt27131358} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-Kitsune.mkv' 'We Live in Time (2024)'

# Weapons (2025)
move_to_deleted '/mnt/synology/rs-movies/Weapons (2025)/Weapons (2025) {imdb-tt26581740} [MA][WEBDL-1080p Proper][EAC3 Atmos 5.1][x264]-BYNDR.mkv' 'Weapons (2025)'

# Weird Science (1985)
move_to_deleted '/mnt/synology/rs-movies/Weird Science (1985)/Weird Science (1985) {imdb-tt0090305} [Bluray-1080p][DTS 5.1][x264].mkv' 'Weird Science (1985)'

# Weird The Al Yankovic Story (2022)
move_to_deleted '/mnt/synology/rs-movies/Weird The Al Yankovic Story (2022)/Weird The Al Yankovic Story (2022) {imdb-tt17076046} [WEBDL-1080p][AC3 5.1][h264]-SMURF.mkv' 'Weird The Al Yankovic Story (2022)'

# Wendell & Wild (2022)
move_to_deleted '/mnt/synology/rs-movies/Wendell & Wild (2022)/Wendell & Wild (2022) {imdb-tt5181830} [WEBRip-1080p Proper][AAC 5.1][x264]-LAMA.mp4' 'Wendell & Wild (2022)'

# Werewolves (2024)
move_to_deleted '/mnt/synology/rs-movies/Werewolves (2024)/Werewolves (2024) {imdb-tt15041836} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Werewolves (2024)'

# West Side Story (1961)
move_to_deleted '/mnt/synology/rs-movies/West Side Story (1961)/West Side Story (1961) {imdb-tt0055614} [WEBDL-1080p][DTS 5.1][x264].mkv' 'West Side Story (1961)'

# Wham! (2023)
move_to_deleted '/mnt/synology/rs-movies/Wham! (2023)/WHAM! (2023) {imdb-tt27726927} [NF][WEBDL-1080p][EAC3 5.1][x264]-FLUX.mkv' 'Wham! (2023)'

# What Happened to Monday (2017)
move_to_deleted '/mnt/synology/rs-movies/What Happened to Monday (2017)/What Happened to Monday (2017) {imdb-tt1536537} [WEBDL-1080p][AC3 5.1][x264].mkv' 'What Happened to Monday (2017)'

# Whiplash (2014)
move_to_deleted '/mnt/synology/rs-movies/Whiplash (2014)/Whiplash (2014) {imdb-tt2582802} [Bluray-1080p][HDR10][EAC3 7.1][x265]-NCmt.mkv' 'Whiplash (2014)'

# White Noise (2022)
move_to_deleted '/mnt/synology/rs-movies/White Noise (2022)/White Noise (2022) {imdb-tt6160448} [WEBDL-1080p][EAC3 Atmos 5.1][x264].mkv' 'White Noise (2022)'

# Whitney Houston I Wanna Dance with Somebody (2022)
move_to_deleted '/mnt/synology/rs-movies/Whitney Houston I Wanna Dance with Somebody (2022)/Whitney Houston I Wanna Dance with Somebody (2022) {imdb-tt12193804} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Whitney Houston I Wanna Dance with Somebody (2022)'

# Who Invited Them (2022)
move_to_deleted '/mnt/synology/rs-movies/Who Invited Them (2022)/Who Invited Them (2022) {imdb-tt17677178} [AMZN][WEBDL-1080p][EAC3 2.0][h264]-EVO.mkv' 'Who Invited Them (2022)'

# Widow Clicquot (2024)
move_to_deleted '/mnt/synology/rs-movies/Widow Clicquot (2024)/Widow Clicquot (2024) {imdb-tt3234122} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'Widow Clicquot (2024)'

# Wild Things (1998)
move_to_deleted '/mnt/synology/rs-movies/Wild Things (1998)/Wild Things (1998) {imdb-tt0120890} [Bluray-1080p][AC3 5.1][x264].mkv' 'Wild Things (1998)'

# Willow (1988)
move_to_deleted '/mnt/synology/rs-movies/Willow (1988)/Willow (1988) {imdb-tt0096446} [Bluray-1080p][AC3 5.1][x264]-eMc2.mkv' 'Willow (1988)'

# Willy\'s Wonderland (2021)
move_to_deleted '/mnt/synology/rs-movies/Willy\'s Wonderland (2021)/Willy\'s Wonderland (2021) {imdb-tt8114980} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv' 'Willy\'s Wonderland (2021)'

# Wind River (2017)
move_to_deleted '/mnt/synology/rs-movies/Wind River (2017)/Wind River (2017) {imdb-tt5362988} [Bluray-1080p][DTS 5.1][x264]-TayTO.mkv' 'Wind River (2017)'

# Wish (2023)
move_to_deleted '/mnt/synology/rs-movies/Wish (2023)/Wish (2023) {imdb-tt11304740} [WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Wish (2023)'

# Witcher Nightmare of the Wolf, The (2021)
move_to_deleted '/mnt/synology/rs-movies/Witcher Nightmare of the Wolf, The (2021)/The Witcher Nightmare of the Wolf (2021) {imdb-tt11657662} [NF][WEBDL-1080p][HDR10][EAC3 Atmos 5.1][h265]-TEPES.mkv' 'Witcher Nightmare of the Wolf, The (2021)'

# Witness (1985)
move_to_deleted '/mnt/synology/rs-movies/Witness (1985)/Witness (1985) {imdb-tt0090329} [Bluray-1080p][AC3 5.1][x264]-EbP.mkv' 'Witness (1985)'

# Wizard of Oz, The (1939)
move_to_deleted '/mnt/synology/rs-movies/Wizard of Oz, The (1939)/The Wizard of Oz (1939) {imdb-tt0032138} [Bluray-1080p][HDR10Plus][EAC3 5.1][x265]-D-Z0N3.mkv' 'Wizard of Oz, The (1939)'

# Wolf Man (2025)
move_to_deleted '/mnt/synology/rs-movies/Wolf Man (2025)/Wolf Man (2025) {imdb-tt4216984} [WEBDL-1080p][EAC3 5.1][h264]-ETHEL.mkv' 'Wolf Man (2025)'

# Wolf of Wall Street, The (2013)
move_to_deleted '/mnt/synology/rs-movies/Wolf of Wall Street, The (2013)/The Wolf of Wall Street (2013) {imdb-tt0993846} [Bluray-1080p][DV HDR10][EAC3 5.1][x265]-TayTO.mkv' 'Wolf of Wall Street, The (2013)'

# The Wolfman (2010)
move_to_deleted '/mnt/synology/rs-movies/The Wolfman (2010)/The Wolfman (2010) {imdb-tt0780653} {edition-Remastered} [Remux-1080p][DTS-HD MA 5.1][AVC]-UnKn0wn.mkv' 'The Wolfman (2010)'

# Woman King, The (2022)
move_to_deleted '/mnt/synology/rs-movies/Woman King, The (2022)/The Woman King (2022) {imdb-tt8093700} [WEBDL-1080p][EAC3 5.1][x264]-EVO.mkv' 'Woman King, The (2022)'

# Woman in the Window, The (2021)
move_to_deleted '/mnt/synology/rs-movies/Woman in the Window, The (2021)/The Woman in the Window (2021) {imdb-tt6111574} [NF][WEBRip-1080p][EAC3 Atmos 5.1][x264]-TOMMY.mkv' 'Woman in the Window, The (2021)'

# Woman of the Hour (2024)
move_to_deleted '/mnt/synology/rs-movies/Woman of the Hour (2024)/Woman of the Hour (2024) {imdb-tt7737800} [WEBDL-1080p][EAC3 Atmos 5.1][x264]-ETHEL.mkv' 'Woman of the Hour (2024)'

# Women Talking (2022)
move_to_deleted '/mnt/synology/rs-movies/Women Talking (2022)/Women Talking (2022) {imdb-tt13669038} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv' 'Women Talking (2022)'

# Won\'t You Be My Neighbor! (2018) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Won\'t You Be My Neighbor! (2018)/Won\'t You Be My Neighbor! (2018) {imdb-tt7681902} [Bluray-720p][DTS 5.1][x264]-CADAVER.mkv' 'Won\'t You Be My Neighbor! (2018)'

# Wonder (2017)
move_to_deleted '/mnt/synology/rs-movies/Wonder (2017)/Wonder (2017) {imdb-tt2543472} [Bluray-1080p][HDR10][EAC3 7.1][x265]-D-Z0N3.mkv' 'Wonder (2017)'

# Wonder Woman (2017)
move_to_deleted '/mnt/synology/rs-movies/Wonder Woman (2017)/Wonder Woman (2017) {imdb-tt0451279} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Wonder Woman (2017)'

# Wonder Woman 1984 (2020)
move_to_deleted '/mnt/synology/rs-movies/Wonder Woman 1984 (2020)/Wonder Woman 1984 (2020) {imdb-tt7126948} [WEBDL-1080p][AC3 5.1][h264].mkv' 'Wonder Woman 1984 (2020)'

# Wonder, The (2022)
move_to_deleted '/mnt/synology/rs-movies/Wonder, The (2022)/Valerie and Her Week of Wonders (1970) {imdb-tt0066516} [WEBRip-1080p][AAC 5.1][x264]-LAMA.mp4' 'Wonder, The (2022)'

# Wonka (2023)
move_to_deleted '/mnt/synology/rs-movies/Wonka (2023)/Wonka (2023) {imdb-tt6166392} [AMZN][WEBDL-1080p][EAC3 Atmos 5.1][h264]-FLUX.mkv' 'Wonka (2023)'

# World War Z (2013)
move_to_deleted '/mnt/synology/rs-movies/World War Z (2013)/World War Z (2013) {imdb-tt0816711} [Bluray-1080p][AC3 5.1][x264].mkv' 'World War Z (2013)'

# World\'s Greatest Dad (2009)
move_to_deleted '/mnt/synology/rs-movies/World\'s Greatest Dad (2009)/World\'s Greatest Dad (2009) {imdb-tt1262981} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'World\'s Greatest Dad (2009)'

# Wrath of Man (2021)
move_to_deleted '/mnt/synology/rs-movies/Wrath of Man (2021)/Wrath of Man (2021) {imdb-tt11083552} [WEBDL-1080p][AC3 5.1][x264]-EVO.mkv' 'Wrath of Man (2021)'

# Wrath of the Titans (2012)
move_to_deleted '/mnt/synology/rs-movies/Wrath of the Titans (2012)/Wrath of the Titans (2012) {imdb-tt1646987} [WEBDL-1080p][DTS 5.1][x264].mkv' 'Wrath of the Titans (2012)'

# X (2022)
move_to_deleted '/mnt/synology/rs-movies/X (2022)/X (2022) {imdb-tt13560574} [WEBDL-1080p][EAC3 5.1][x264]-EVO.mkv' 'X (2022)'

# X-Men First Class (2011)
move_to_deleted '/mnt/synology/rs-movies/X-Men First Class (2011)/X-Men First Class (2011) {imdb-tt1270798} [Bluray-1080p][DTS 5.1][x264]-HDC.mkv' 'X-Men First Class (2011)'

# X2 (2003)
move_to_deleted '/mnt/synology/rs-movies/X2 (2003)/X2 (2003) {imdb-tt0290334} [Bluray-1080p][DTS 5.1][x264]-DON.mkv' 'X2 (2003)'

# Ying xiong (2002)
move_to_deleted '/mnt/synology/rs-movies/Ying xiong (2002)/Fist.Of.Legend.1994.1080p.BluRay.x264.iNT-aAF.mkv' 'Ying xiong (2002)'

# You Are Not My Mother (2022)
move_to_deleted '/mnt/synology/rs-movies/You Are Not My Mother (2022)/You Are Not My Mother (2022) {imdb-tt10406596} [WEBDL-1080p][AC3 5.1][h264]-CMRG.mkv' 'You Are Not My Mother (2022)'

# You Can\'t Run Forever (2024)
move_to_deleted '/mnt/synology/rs-movies/You Can\'t Run Forever (2024)/You Can\'t Run Forever (2024) {imdb-tt15451150} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-BYNDR.mkv' 'You Can\'t Run Forever (2024)'

# You Only Live Twice (1967)
move_to_deleted '/mnt/synology/rs-movies/You Only Live Twice (1967)/You Only Live Twice (1967) {imdb-tt0062512} [Bluray-1080p][DTS 5.1][x264].mkv' 'You Only Live Twice (1967)'

# Young Guns (1988)
move_to_deleted '/mnt/synology/rs-movies/Young Guns (1988)/Young Guns (1988) {imdb-tt0096487} [Bluray-1080p][Opus 5.1][x264]-RetroPeeps.mkv' 'Young Guns (1988)'

# Young People Fucking (2007) (720p → 1080p)
move_to_deleted '/mnt/synology/rs-movies/Young People Fucking (2007)/Young People Fucking (2007) {imdb-tt0913445} [Bluray-720p][DTS 5.1][x264].mkv' 'Young People Fucking (2007)'

# Your Lucky Day (2023)
move_to_deleted '/mnt/synology/rs-movies/Your Lucky Day (2023)/Your Lucky Day (2023) {imdb-tt16424988} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-FLUX.mkv' 'Your Lucky Day (2023)'

# Zack Snyder\'s Justice League (2021)
move_to_deleted '/mnt/synology/rs-movies/Zack Snyder\'s Justice League (2021)/Zack Snyder\'s Justice League (2021) {imdb-tt12361974} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-CMRG.mkv' 'Zack Snyder\'s Justice League (2021)'

# Zack and Miri Make a Porno (2008)
move_to_deleted '/mnt/synology/rs-movies/Zack and Miri Make a Porno (2008)/Zack and Miri Make a Porno (2008) {imdb-tt1007028} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-RegEdits.mkv' 'Zack and Miri Make a Porno (2008)'

# Zero Dark Thirty (2012)
move_to_deleted '/mnt/synology/rs-movies/Zero Dark Thirty (2012)/Zero Dark Thirty (2012) {imdb-tt1790885} [Bluray-1080p][HDR10][EAC3 7.1][x265]-CtrlHD.mkv' 'Zero Dark Thirty (2012)'

# Zombeavers (2014)
move_to_deleted '/mnt/synology/rs-movies/Zombeavers (2014)/Zombeavers (2014) {imdb-tt2784512} [AMZN][WEBDL-1080p][EAC3 5.1][h264]-Kitsune.mkv' 'Zombeavers (2014)'

# Zombieland (2009)
move_to_deleted '/mnt/synology/rs-movies/Zombieland (2009)/Zombieland (2009) {imdb-tt1156398} {edition-Open Matte} [WEBDL-1080p][EAC3 5.1][h264]-spartanec163.mkv' 'Zombieland (2009)'

# Zootopia (2016)
move_to_deleted '/mnt/synology/rs-movies/Zootopia (2016)/Zootopia (2016) {imdb-tt2948356} [Bluray-1080p][AC3 5.1][x264]-BHDStudio.mp4' 'Zootopia (2016)'

# mother! (2017)
move_to_deleted '/mnt/synology/rs-movies/mother! (2017)/mother! (2017) {imdb-tt5109784} [Bluray-1080p][DV HDR10][EAC3 7.1][x265]-NTb.mkv' 'mother! (2017)'

# ========================================
# STEP 2: Move Ali's lower quality/resolution files
# ========================================

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
