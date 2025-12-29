#!/bin/bash
#==============================================================================
# Project Mother Sync Script
# RUN THIS ON MOTHER (10.0.0.162)
#==============================================================================
# Generated: 2025-12-29 11:06:03
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


# === COPY BETTER QUALITY FILES ===

# Ali has better: Ghostbusters (1984)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Ghostbusters (1984)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: John Wick Chapter 4 (2022)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/John Wick Chapter 4 (2022)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Lost World Jurassic Park (1997)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Lost World Jurassic Park (1997)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Avengers Age of Ultron (2015)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Avengers Age of Ultron (2015)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek II The Wrath of Khan (1982)
# Score: Ali=6799 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek II The Wrath of Khan (1982)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Wicked (2024)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Wicked (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Rocketman (2019)
# Score: Ali=6803 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Rocketman (2019)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Batman Begins (2005)
# Score: Ali=7600 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Batman Begins (2005)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Spider-Man Far From Home (2019)
# Score: Ali=7189 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Spider-Man Far From Home (2019)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Kingdom of the Planet of the Apes (2024)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Kingdom of the Planet of the Apes (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Hobbit An Unexpected Journey (2012)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Hobbit An Unexpected Journey (2012)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Captain America The First Avenger (2011)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Captain America The First Avenger (2011)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Extraction 2 (2023)
# Score: Ali=6670 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Extraction 2 (2023)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Willy Wonka and the Chocolate Factory (1971)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Willy Wonka and the Chocolate Factory (1971)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Kingdom of Heaven (2005)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Kingdom of Heaven (2005)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Rise of the Planet of the Apes (2011)
# Score: Ali=6830 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Rise of the Planet of the Apes (2011)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Extraction (2020)
# Score: Ali=6630 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Extraction (2020)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Zack Snyders Justice League (2021)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Zack Snyders Justice League (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: 300 (2006)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/300 (2006)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Indiana Jones and the Dial of Destiny (2023)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Indiana Jones and the Dial of Destiny (2023)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Avengers Infinity War (2018)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Avengers Infinity War (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Godfather Part III (1990)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Godfather Part III (1990)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Avengers (2012)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Avengers (2012)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Apollo 13 (1995)
# Score: Ali=7500 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Apollo 13 (1995)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Mission Impossible Dead Reckoning Part One (2023)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mission Impossible Dead Reckoning Part One (2023)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Blade Runner (1982)
# Score: Ali=7600 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Blade Runner (1982)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Uncharted (2022)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Uncharted (2022)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Jungle Cruise (2021)
# Score: Ali=6646 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Jungle Cruise (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Dark Knight Rises (2012)
# Score: Ali=7600 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Dark Knight Rises (2012)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: TRON Ares (2025)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/TRON Ares (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Raiders of the Lost Ark (1981)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Raiders of the Lost Ark (1981)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Kong Skull Island (2017)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Kong Skull Island (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Venom The Last Dance (2024)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Venom The Last Dance (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Total Recall (1990)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Total Recall (1990)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Zombieland Double Tap (2019)
# Score: Ali=7076 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Zombieland Double Tap (2019)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Mission Impossible Fallout (2018)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mission Impossible Fallout (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Venom (2018)
# Score: Ali=7190 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Venom (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Hunger Games Mockingjay - Part 2 (2015)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Hunger Games Mockingjay - Part 2 (2015)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Fifth Element (1997)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Fifth Element (1997)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Godzilla vs. Kong (2021)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Godzilla vs. Kong (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: 1917 (2019)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/1917 (2019)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Captain America The Winter Soldier (2014)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Captain America The Winter Soldier (2014)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Avatar The Way of Water (2022)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Avatar The Way of Water (2022)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek V The Final Frontier (1989)
# Score: Ali=6790 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek V The Final Frontier (1989)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Lord of the Rings The Two Towers (2002)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Lord of the Rings The Two Towers (2002)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: John Wick Chapter 3 Parabellum (2019)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/John Wick Chapter 3 Parabellum (2019)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Brotherhood of the Wolf (2001)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Brotherhood of the Wolf (2001)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Indiana Jones and the Kingdom of the Crystal Skull (2008)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Indiana Jones and the Kingdom of the Crystal Skull (2008)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Heat (1995)
# Score: Ali=7500 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Heat (1995)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Ant-Man and the Wasp Quantumania (2023)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Ant-Man and the Wasp Quantumania (2023)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Dracula (1992)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Dracula (1992)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Saving Private Ryan (1998)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Saving Private Ryan (1998)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Aliens (1986)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Aliens (1986)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Wizard of Oz (1939)
# Score: Ali=7600 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Wizard of Oz (1939)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Earth One Amazing Day (2017)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Earth One Amazing Day (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Spider-Man No Way Home (2021)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Spider-Man No Way Home (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: V for Vendetta (2005)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/V for Vendetta (2005)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Shazam! (2019)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Shazam! (2019)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Gladiator (2000)
# Score: Ali=7600 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Gladiator (2000)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Gladiator (2000)
# Score: Ali=7500 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Gladiator (2000)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Dark Knight (2008)
# Score: Ali=7650 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Dark Knight (2008)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Deadpool 2 (2018)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Deadpool 2 (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Mummy (1999)
# Score: Ali=7000 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Mummy (1999)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Terminator (1984)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Terminator (1984)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Return of the Jedi (1983)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Return of the Jedi (1983)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Godfather Part II (1974)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Godfather Part II (1974)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Deadpool 3 (2024)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Deadpool 3 (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Zombieland (2009)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Zombieland (2009)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Lawrence of Arabia (1962)
# Score: Ali=7600 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Lawrence of Arabia (1962)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Logan (2017)
# Score: Ali=7095 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Logan (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Mission Impossible Ghost Protocol (2011)
# Score: Ali=7050 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mission Impossible Ghost Protocol (2011)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek Into Darkness (2013)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek Into Darkness (2013)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Life of Pi (2012)
# Score: Ali=7500 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Life of Pi (2012)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Hobbit The Battle of the Five Armies (2014)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Hobbit The Battle of the Five Armies (2014)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Alita Battle Angel (2019)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Alita Battle Angel (2019)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Revenant (2015)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Revenant (2015)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Iron Man (2008)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Iron Man (2008)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: E.T. the Extra-Terrestrial (1982)
# Score: Ali=7000 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/E.T. the Extra-Terrestrial (1982)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Northman (2022)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Northman (2022)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Mortal Kombat (2021)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mortal Kombat (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: A Beautiful Planet (2016)
# Score: Ali=7473 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/A Beautiful Planet (2016)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Suicide Squad (2021)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Suicide Squad (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Interstellar (2014)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Interstellar (2014)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Avatar (2009)
# Score: Ali=7600 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Avatar (2009)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek VI The Undiscovered Country (1991)
# Score: Ali=6795 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek VI The Undiscovered Country (1991)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Wonder Woman (2017)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Wonder Woman (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Blade II (2002)
# Score: Ali=6600 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Blade II (2002)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: 2001 A Space Odyssey (1968)
# Score: Ali=7600 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/2001 A Space Odyssey (1968)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Indiana Jones and the Last Crusade (1989)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Indiana Jones and the Last Crusade (1989)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Napoleon (2023)
# Score: Ali=6700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Napoleon (2023)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Godzilla Minus One (2023)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Godzilla Minus One (2023)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Alien Romulus (2024)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Alien Romulus (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Indiana Jones and the Temple of Doom (1984)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Indiana Jones and the Temple of Doom (1984)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Captain Marvel 2 (2022)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Captain Marvel 2 (2022)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Black Panther Wakanda Forever (2022)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Black Panther Wakanda Forever (2022)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: TRON Legacy (2010)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/TRON Legacy (2010)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Lion King (1994)
# Score: Ali=7190 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Lion King (1994)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Ready Player One (2018)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Ready Player One (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Captain Marvel (2019)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Captain Marvel (2019)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Hunger Games Catching Fire (2013)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Hunger Games Catching Fire (2013)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Iron Man 2 (2010)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Iron Man 2 (2010)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Furious 7 (2015)
# Score: Ali=6950 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Furious 7 (2015)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Guardians of the Galaxy Vol. 3 (2023)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Guardians of the Galaxy Vol. 3 (2023)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Pitch Black (2000)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Pitch Black (2000)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Forrest Gump (1994)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Forrest Gump (1994)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Jaws (1975)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Jaws (1975)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Venom Let There Be Carnage (2021)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Venom Let There Be Carnage (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek Insurrection (1998) {imdb-tt0120844}
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek Insurrection (1998) {imdb-tt0120844}" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Edge of Tomorrow (2014)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Edge of Tomorrow (2014)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Guardians of the Galaxy Vol. 2 (2017)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Guardians of the Galaxy Vol. 2 (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Hunt for Red October (1990)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Hunt for Red October (1990)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Blade (1998)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Blade (1998)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Spy Who Loved Me (1977)
# Score: Ali=5774 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Spy Who Loved Me (1977)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Thor Ragnarok (2017)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Thor Ragnarok (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Hacksaw Ridge (2016)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Hacksaw Ridge (2016)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Man of Steel (2013)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Man of Steel (2013)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Pacific Rim (2013)
# Score: Ali=7172 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Pacific Rim (2013)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Thunderbolts- (2025)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Thunderbolts- (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Mad Max Fury Road (2015)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mad Max Fury Road (2015)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Highlander (1986)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Highlander (1986)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Bumblebee (2018)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Bumblebee (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Solo A Star Wars Story (2018)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Solo A Star Wars Story (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Ant-Man (2015)
# Score: Ali=7178 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Ant-Man (2015)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Thor (2011)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Thor (2011)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Bohemian Rhapsody (2018)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Bohemian Rhapsody (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Wars (1977)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Wars (1977)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Mission Impossible II (2000)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mission Impossible II (2000)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Cars 3 (2017)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Cars 3 (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Godzilla (2014)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Godzilla (2014)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Blade Runner 2049 (2017)
# Score: Ali=7600 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Blade Runner 2049 (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Ant-Man and the Wasp (2018)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Ant-Man and the Wasp (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Fast & Furious 6 (2013)
# Score: Ali=7000 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Fast & Furious 6 (2013)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek IV The Voyage Home (1986)
# Score: Ali=6806 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek IV The Voyage Home (1986)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Lord of the Rings The Return of the King (2003)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Lord of the Rings The Return of the King (2003)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Shazam! Fury of the Gods (2023)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Shazam! Fury of the Gods (2023)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Dune Part Two (2024)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Dune Part Two (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Joker (2019)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Joker (2019)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek (2009)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek (2009)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Eternals (2021)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Eternals (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Inception (2010)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Inception (2010)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Lion King (2019)
# Score: Ali=6788 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Lion King (2019)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Chronicles of Riddick (2004)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Chronicles of Riddick (2004)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Batman v Superman Dawn of Justice (2016)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Batman v Superman Dawn of Justice (2016)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Hunger Games Mockingjay - Part 1 (2014)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Hunger Games Mockingjay - Part 1 (2014)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Predator (2018)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Predator (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Constantine (2005)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Constantine (2005)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Hunger Games (2012)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Hunger Games (2012)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Pulp Fiction (1994)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Pulp Fiction (1994)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Master and Commander The Far Side of the World (2003)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Master and Commander The Far Side of the World (2003)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Terminator 2 Judgment Day (1991)
# Score: Ali=6800 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Terminator 2 Judgment Day (1991)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek First Contact (1996)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek First Contact (1996)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Jurassic Park (1993)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Jurassic Park (1993)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Avengers Endgame (2019)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Avengers Endgame (2019)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Dawn of the Planet of the Apes (2014)
# Score: Ali=6803 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Dawn of the Planet of the Apes (2014)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Spider-Man Homecoming (2017)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Spider-Man Homecoming (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Tron (1982)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Tron (1982)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Close Encounters of the Third Kind (1977)
# Score: Ali=6759 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Close Encounters of the Third Kind (1977)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Alien (1979)
# Score: Ali=7500 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Alien (1979)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Tenet (2020)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Tenet (2020)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Dune (2021)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Dune (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Red Sparrow (2018)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Red Sparrow (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Oppenheimer (2023)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Oppenheimer (2023)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Mission Impossible Rogue Nation (2015)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mission Impossible Rogue Nation (2015)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek Beyond (2016)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek Beyond (2016)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Passengers (2016)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Passengers (2016)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Godfather (1972)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Godfather (1972)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Matrix Revolutions (2003)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Matrix Revolutions (2003)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Martian (2015)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Martian (2015)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek III The Search for Spock (1984)
# Score: Ali=6788 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek III The Search for Spock (1984)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Braveheart (1995)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Braveheart (1995)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Gladiator II (2024)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Gladiator II (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Fantastic 4 First Steps (2025)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Fantastic 4 First Steps (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Matrix Resurrections (2021)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Matrix Resurrections (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Guardians of the Galaxy (2014)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Guardians of the Galaxy (2014)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Frankenstein (2025)
# Score: Ali=6700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Frankenstein (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Iron Man 3 (2013)
# Score: Ali=7187 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Iron Man 3 (2013)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Matrix Reloaded (2003)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Matrix Reloaded (2003)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Shawshank Redemption (1994)
# Score: Ali=6817 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Shawshank Redemption (1994)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Abyss (1989)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Abyss (1989)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Twisters (2024)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Twisters (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Deadpool (2016)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Deadpool (2016)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Superman (2025)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Superman (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Dunkirk (2017)
# Score: Ali=7099 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Dunkirk (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Matrix (1999)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Matrix (1999)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Mission Impossible (1996)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mission Impossible (1996)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Army of the Dead (2021)
# Score: Ali=6660 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Army of the Dead (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Phantom of the Opera (2004)
# Score: Ali=7500 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Phantom of the Opera (2004)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Coco (2017)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Coco (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: War for the Planet of the Apes (2017)
# Score: Ali=7196 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/War for the Planet of the Apes (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Top Gun Maverick (2022)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Top Gun Maverick (2022)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: John Wick (2014)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/John Wick (2014)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Civil War (2024)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Civil War (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Ad Astra (2019)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Ad Astra (2019)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Terminator Dark Fate (2019)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Terminator Dark Fate (2019)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Lord of the Rings The Fellowship of the Ring (2001)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Lord of the Rings The Fellowship of the Ring (2001)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Apocalypse Now (1979)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Apocalypse Now (1979)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Ten Commandments (1956)
# Score: Ali=7600 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Ten Commandments (1956)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Thor The Dark World (2013)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Thor The Dark World (2013)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Captain America Civil War (2016)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Captain America Civil War (2016)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek The Motion Picture (1979)
# Score: Ali=6800 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek The Motion Picture (1979)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Empire Strikes Back (1980)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Empire Strikes Back (1980)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Pacific Rim Uprising (2018)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Pacific Rim Uprising (2018)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Warfare (2025)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Warfare (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Furiosa A Mad Max Saga (2024)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Furiosa A Mad Max Saga (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Wonder Woman 1984 (2020)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Wonder Woman 1984 (2020)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Cars (2006)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Cars (2006)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Batman (2022)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Batman (2022)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Greatest Showman (2017)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Greatest Showman (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Mummy Returns (2001)
# Score: Ali=7000 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Mummy Returns (2001)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: What Happened to Monday (2017)
# Score: Ali=7050 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/What Happened to Monday (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek Generations (1994) {imdb-tt0111280}
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek Generations (1994) {imdb-tt0111280}" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Cars 2 (2011)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Cars 2 (2011)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Hobbit The Desolation of Smaug (2013)
# Score: Ali=7700 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Hobbit The Desolation of Smaug (2013)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Top Gun (1986)
# Score: Ali=6794 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Top Gun (1986)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Mission Impossible III (2006)
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mission Impossible III (2006)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Twister (1996)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Twister (1996)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Black Widow (2021)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Black Widow (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Black Adam (2022)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Black Adam (2022)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Captain America Brave New World (2025)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Captain America Brave New World (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: John Wick Chapter 2 (2017)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/John Wick Chapter 2 (2017)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Godzilla King of the Monsters (2019)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Godzilla King of the Monsters (2019)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Godzilla x Kong The New Empire (2024)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Godzilla x Kong The New Empire (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Star Trek Nemesis (2002) {imdb-tt0253754}
# Score: Ali=7150 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Star Trek Nemesis (2002) {imdb-tt0253754}" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Riddick (2013)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Riddick (2013)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Super Mario Bros. Movie (2023)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Super Mario Bros. Movie (2023)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Mission Impossible 8 (2025)
# Score: Ali=7200 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Mission Impossible 8 (2025)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Ant-Man (2015)
# Score: Chris=7178 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Ant-Man (2015)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Furiosa A Mad Max Saga (2024)
# Score: Ali=6651 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Furiosa A Mad Max Saga (2024)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: Alien Romulus (2024)
# Score: Chris=6700 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Alien Romulus (2024)" "/mnt/unraid/media/4K Movies/"

# Chris has better: John Wick Chapter 4 (2022)
# Score: Chris=7200 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/John Wick Chapter 4 (2022)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Chronicles of Riddick (2004)
# Score: Chris=7100 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Chronicles of Riddick (2004)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Captain Marvel 2 (2022)
# Score: Chris=7200 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Captain Marvel 2 (2022)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Batman v Superman Dawn of Justice (2016)
# Score: Chris=7200 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Batman v Superman Dawn of Justice (2016)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Napoleon (2023)
# Score: Chris=6700 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Napoleon (2023)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Solo A Star Wars Story (2018)
# Score: Chris=7100 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Solo A Star Wars Story (2018)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Tenet (2020)
# Score: Chris=7000 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Tenet (2020)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Kingdom of Heaven (2005)
# Score: Chris=6215 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Kingdom of Heaven (2005)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Aliens (1986)
# Score: Chris=7200 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Aliens (1986)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Shazam! (2019)
# Score: Chris=7200 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Shazam! (2019)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Black Panther Wakanda Forever (2022)
# Score: Chris=6850 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Black Panther Wakanda Forever (2022)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Mortal Kombat (2021)
# Score: Chris=7200 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Mortal Kombat (2021)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Avatar (2009)
# Score: Chris=7600 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Avatar (2009)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Abyss (1989)
# Score: Chris=7200 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Abyss (1989)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Highlander (1986)
# Score: Chris=7100 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Highlander (1986)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Oppenheimer (2023)
# Score: Chris=7100 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Oppenheimer (2023)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Terminator Dark Fate (2019)
# Score: Chris=7200 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Terminator Dark Fate (2019)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Bumblebee (2018)
# Score: Chris=7200 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Bumblebee (2018)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Twisters (2024)
# Score: Chris=6700 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Twisters (2024)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Ant-Man and the Wasp Quantumania (2023)
# Score: Chris=7200 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Ant-Man and the Wasp Quantumania (2023)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Man of Steel (2013)
# Score: Chris=7200 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Man of Steel (2013)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Ant-Man and the Wasp (2018)
# Score: Chris=7200 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Ant-Man and the Wasp (2018)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Batman (2022)
# Score: Chris=7200 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Batman (2022)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Dune Part Two (2024)
# Score: Chris=7200 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Dune Part Two (2024)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Master and Commander The Far Side of the World (2003)
# Score: Chris=7200 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Master and Commander The Far Side of the World (2003)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Deadpool 3 (2024)
# Score: Chris=6700 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Deadpool 3 (2024)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Mission Impossible (1996)
# Score: Chris=7150 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Mission Impossible (1996)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Mummy (1999)
# Score: Chris=7000 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Mummy (1999)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Riddick (2013)
# Score: Chris=7100 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Riddick (2013)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Mission Impossible Dead Reckoning Part One (2023)
# Score: Chris=7200 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Mission Impossible Dead Reckoning Part One (2023)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Empire Strikes Back (1980)
# Score: Chris=5900 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Empire Strikes Back (1980)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Uncharted (2022)
# Score: Chris=5400 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Uncharted (2022)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Avatar The Way of Water (2022)
# Score: Chris=5400 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Avatar The Way of Water (2022)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Star Wars (1977)
# Score: Chris=6800 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Star Wars (1977)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Fast & Furious 6 (2013)
# Score: Chris=6400 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Fast & Furious 6 (2013)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Total Recall (1990)
# Score: Chris=6800 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Total Recall (1990)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Resident Evil Welcome to Raccoon City (2021)
# Score: Chris=5314 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Resident Evil Welcome to Raccoon City (2021)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Hunger Games Mockingjay - Part 1 (2014)
# Score: Chris=6800 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Hunger Games Mockingjay - Part 1 (2014)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Hunger Games Mockingjay - Part 2 (2015)
# Score: Chris=6800 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Hunger Games Mockingjay - Part 2 (2015)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Prey (2022)
# Score: Chris=5342 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Prey (2022)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Lord of the Rings The Two Towers (2002)
# Score: Chris=6400 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Lord of the Rings The Two Towers (2002)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Jurassic World Dominion (2022)
# Score: Chris=5800 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Jurassic World Dominion (2022)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Shazam! Fury of the Gods (2023)
# Score: Chris=6800 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Shazam! Fury of the Gods (2023)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Master and Commander The Far Side of the World (2003)
# Score: Chris=4300 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/#recycle/Master and Commander The Far Side of the World (2003)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Independence Day (1996)
# Score: Chris=6400 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Independence Day (1996)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Blade (1998)
# Score: Chris=5900 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Blade (1998)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Dune (2021)
# Score: Chris=6800 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Dune (2021)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Pirates of the Caribbean The Curse of the Black Pearl (2003)
# Score: Chris=5193 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Pirates of the Caribbean The Curse of the Black Pearl (2003)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Star Trek The Motion Picture (1979)
# Score: Chris=6800 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Star Trek The Motion Picture (1979)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Captain America Civil War (2016)
# Score: Chris=6400 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Captain America Civil War (2016)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Apollo 13 (1995)
# Score: Chris=6400 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Apollo 13 (1995)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Matrix Resurrections (2021)
# Score: Chris=5792 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Matrix Resurrections (2021)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Lord of the Rings The Return of the King (2003)
# Score: Chris=6400 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Lord of the Rings The Return of the King (2003)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Return of the Jedi (1983)
# Score: Chris=6400 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Return of the Jedi (1983)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Star Trek V The Final Frontier (1989)
# Score: Chris=5900 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Star Trek V The Final Frontier (1989)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Spider-Man No Way Home (2021)
# Score: Chris=5400 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Spider-Man No Way Home (2021)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Ghostbusters Afterlife (2021)
# Score: Chris=5330 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Ghostbusters Afterlife (2021)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Outfit (2022)
# Score: Chris=5310 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Outfit (2022)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Doctor Strange in the Multiverse of Madness (2022)
# Score: Chris=5800 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Doctor Strange in the Multiverse of Madness (2022)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Bohemian Rhapsody (2018)
# Score: Chris=6400 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Bohemian Rhapsody (2018)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Deadpool 2 (2018)
# Score: Chris=6400 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Deadpool 2 (2018)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Jungle Cruise (2021)
# Score: Chris=6800 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Jungle Cruise (2021)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Twister (1996)
# Score: Chris=4300 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Twister (1996)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Captain Marvel (2019)
# Score: Chris=6400 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Captain Marvel (2019)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Hunger Games Catching Fire (2013)
# Score: Chris=6800 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Hunger Games Catching Fire (2013)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Deadpool (2016)
# Score: Chris=6400 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Deadpool (2016)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Indiana Jones and the Last Crusade (1989)
# Score: Chris=6800 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Indiana Jones and the Last Crusade (1989)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Black Adam (2022)
# Score: Chris=5800 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Black Adam (2022)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Doctor Strange (2016)
# Score: Chris=6800 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Doctor Strange (2016)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Hunger Games (2012)
# Score: Chris=6800 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Hunger Games (2012)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Furious 7 (2015)
# Score: Chris=6400 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Furious 7 (2015)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Lord of the Rings The Fellowship of the Ring (2001)
# Score: Chris=6400 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Lord of the Rings The Fellowship of the Ring (2001)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Star Trek VI The Undiscovered Country (1991)
# Score: Chris=5900 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Star Trek VI The Undiscovered Country (1991)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Oblivion (2013)
# Score: Chris=6400 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Oblivion (2013)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Ad Astra (2019)
# Score: Chris=6800 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Ad Astra (2019)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Top Gun Maverick (2022)
# Score: Chris=5800 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Top Gun Maverick (2022)" "/mnt/unraid/media/4K Movies/"

# Ali has better: Terminator 2 Judgment Day (1991)
# Score: Ali=6750 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Terminator 2 Judgment Day (1991)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Ghostbusters (1984)
# Score: Ali=7100 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Ghostbusters (1984)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Life of Pi (2012)
# Score: Ali=6800 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Life of Pi (2012)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Apollo 13 (1995)
# Score: Ali=6800 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Apollo 13 (1995)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Lawrence of Arabia (1962)
# Score: Ali=6900 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Lawrence of Arabia (1962)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: The Hobbit The Desolation of Smaug (2013)
# Score: Ali=7300 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/The Hobbit The Desolation of Smaug (2013)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Ali has better: Jungle Cruise (2021)
# Score: Ali=6646 vs Chris=0
run_cmd rsync -avP "/mnt/unraid/media/4K Movies/Jungle Cruise (2021)" "/mnt/synology/rs-4kmedia/4kmovies/"

# Chris has better: 300 (2006)
# Score: Chris=6900 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/300 (2006)" "/mnt/unraid/media/4K Movies/"

# Chris has better: 1917 (2019)
# Score: Chris=5900 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/1917 (2019)" "/mnt/unraid/media/4K Movies/"

# Chris has better: 2001 A Space Odyssey (1968)
# Score: Chris=7500 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/2001 A Space Odyssey (1968)" "/mnt/unraid/media/4K Movies/"

# Chris has better: A Beautiful Planet (2016)
# Score: Chris=7473 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/A Beautiful Planet (2016)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Alien (1979)
# Score: Chris=7100 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Alien (1979)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Alien (1979)
# Score: Chris=5900 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Alien (1979)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Alita Battle Angel (2019)
# Score: Chris=6650 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Alita Battle Angel (2019)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Apocalypse Now (1979)
# Score: Chris=5900 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Apocalypse Now (1979)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Army of the Dead (2021)
# Score: Chris=5983 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Army of the Dead (2021)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Avengers Age of Ultron (2015)
# Score: Chris=6565 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Avengers Age of Ultron (2015)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Avengers Endgame (2019)
# Score: Chris=7100 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Avengers Endgame (2019)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Avengers Infinity War (2018)
# Score: Chris=7100 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Avengers Infinity War (2018)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Batman Begins (2005)
# Score: Chris=7500 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Batman Begins (2005)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Black Widow (2021)
# Score: Chris=7100 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Black Widow (2021)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Blade Runner (1982)
# Score: Chris=7100 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Blade Runner (1982)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Braveheart (1995)
# Score: Chris=5900 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Braveheart (1995)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Captain America The First Avenger (2011)
# Score: Chris=6594 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Captain America The First Avenger (2011)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Captain America The Winter Soldier (2014)
# Score: Chris=7050 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Captain America The Winter Soldier (2014)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Close Encounters of the Third Kind (1977)
# Score: Chris=6946 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Close Encounters of the Third Kind (1977)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Dracula (1992)
# Score: Chris=6400 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Dracula (1992)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Dunkirk (2017)
# Score: Chris=6792 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Dunkirk (2017)" "/mnt/unraid/media/4K Movies/"

# Chris has better: E.T. the Extra-Terrestrial (1982)
# Score: Chris=5900 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/E.T. the Extra-Terrestrial (1982)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Earth One Amazing Day (2017)
# Score: Chris=7100 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Earth One Amazing Day (2017)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Edge of Tomorrow (2014)
# Score: Chris=6750 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Edge of Tomorrow (2014)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Ghostbusters (1984)
# Score: Chris=7100 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Ghostbusters (1984)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Gladiator (2000)
# Score: Chris=6800 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Gladiator (2000)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Godzilla King of the Monsters (2019)
# Score: Chris=7100 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Godzilla King of the Monsters (2019)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Godzilla vs. Kong (2021)
# Score: Chris=7100 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Godzilla vs. Kong (2021)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Guardians of the Galaxy (2014)
# Score: Chris=6998 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Guardians of the Galaxy (2014)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Guardians of the Galaxy Vol. 2 (2017)
# Score: Chris=5877 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Guardians of the Galaxy Vol. 2 (2017)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Hacksaw Ridge (2016)
# Score: Chris=5871 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Hacksaw Ridge (2016)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Heat (1995)
# Score: Chris=6500 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Heat (1995)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Inception (2010)
# Score: Chris=5900 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Inception (2010)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Indiana Jones and the Kingdom of the Crystal Skull (2008)
# Score: Chris=7045 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Indiana Jones and the Kingdom of the Crystal Skull (2008)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Indiana Jones and the Temple of Doom (1984)
# Score: Chris=5900 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Indiana Jones and the Temple of Doom (1984)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Interstellar (2014)
# Score: Chris=5900 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Interstellar (2014)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Iron Man (2008)
# Score: Chris=7072 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Iron Man (2008)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Iron Man 2 (2010)
# Score: Chris=6599 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Iron Man 2 (2010)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Iron Man 3 (2013)
# Score: Chris=7018 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Iron Man 3 (2013)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Jaws (1975)
# Score: Chris=6900 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Jaws (1975)" "/mnt/unraid/media/4K Movies/"

# Chris has better: John Wick (2014)
# Score: Chris=7092 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/John Wick (2014)" "/mnt/unraid/media/4K Movies/"

# Chris has better: John Wick Chapter 2 (2017)
# Score: Chris=7600 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/John Wick Chapter 2 (2017)" "/mnt/unraid/media/4K Movies/"

# Chris has better: John Wick Chapter 3 Parabellum (2019)
# Score: Chris=7050 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/John Wick Chapter 3 Parabellum (2019)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Joker (2019)
# Score: Chris=7100 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Joker (2019)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Kong Skull Island (2017)
# Score: Chris=6350 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Kong Skull Island (2017)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Logan (2017)
# Score: Chris=5848 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Logan (2017)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Mad Max Fury Road (2015)
# Score: Chris=6400 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Mad Max Fury Road (2015)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Passengers (2016)
# Score: Chris=7100 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Passengers (2016)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Pitch Black (2000)
# Score: Chris=7000 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Pitch Black (2000)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Raiders of the Lost Ark (1981)
# Score: Chris=7065 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Raiders of the Lost Ark (1981)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Ready Player One (2018)
# Score: Chris=6350 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Ready Player One (2018)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Red Sparrow (2018)
# Score: Chris=5841 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Red Sparrow (2018)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Rocketman (2019)
# Score: Chris=5887 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Rocketman (2019)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Saving Private Ryan (1998)
# Score: Chris=5900 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Saving Private Ryan (1998)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Star Trek (2009)
# Score: Chris=5900 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Star Trek (2009)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Star Trek First Contact (1996)
# Score: Chris=5403 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Star Trek First Contact (1996)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Star Trek Into Darkness (2013)
# Score: Chris=7100 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Star Trek Into Darkness (2013)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Avengers (2012)
# Score: Chris=7100 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Avengers (2012)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Dark Knight (2008)
# Score: Chris=6750 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Dark Knight (2008)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Dark Knight Rises (2012)
# Score: Chris=6750 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Dark Knight Rises (2012)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Hobbit An Unexpected Journey (2012)
# Score: Chris=7300 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Hobbit An Unexpected Journey (2012)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Hobbit The Battle of the Five Armies (2014)
# Score: Chris=7300 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Hobbit The Battle of the Five Armies (2014)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Hobbit The Desolation of Smaug (2013)
# Score: Chris=7300 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Hobbit The Desolation of Smaug (2013)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Hunt for Red October (1990)
# Score: Chris=6350 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Hunt for Red October (1990)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Martian (2015)
# Score: Chris=7050 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Martian (2015)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Matrix (1999)
# Score: Chris=6900 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Matrix (1999)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Matrix Reloaded (2003)
# Score: Chris=7050 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Matrix Reloaded (2003)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Matrix Revolutions (2003)
# Score: Chris=6700 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Matrix Revolutions (2003)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Predator (2018)
# Score: Chris=6400 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Predator (2018)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Revenant (2015)
# Score: Chris=6800 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Revenant (2015)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Thor Ragnarok (2017)
# Score: Chris=6650 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Thor Ragnarok (2017)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Top Gun (1986)
# Score: Chris=7150 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Top Gun (1986)" "/mnt/unraid/media/4K Movies/"

# Chris has better: V for Vendetta (2005)
# Score: Chris=6900 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/V for Vendetta (2005)" "/mnt/unraid/media/4K Movies/"

# Chris has better: War for the Planet of the Apes (2017)
# Score: Chris=6600 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/War for the Planet of the Apes (2017)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Wonder Woman (2017)
# Score: Chris=7050 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Wonder Woman (2017)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Wonder Woman 1984 (2020)
# Score: Chris=6197 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Wonder Woman 1984 (2020)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Zombieland (2009)
# Score: Chris=5840 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Zombieland (2009)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Jurassic Park (1993)
# Score: Chris=6644 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Jurassic Park (1993)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Pacific Rim (2013)
# Score: Chris=6651 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Pacific Rim (2013)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Star Trek II The Wrath of Khan (1982)
# Score: Chris=6634 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Star Trek II The Wrath of Khan (1982)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Star Trek III The Search for Spock (1984)
# Score: Chris=6621 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Star Trek III The Search for Spock (1984)" "/mnt/unraid/media/4K Movies/"

# Chris has better: Star Trek IV The Voyage Home (1986)
# Score: Chris=6637 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/Star Trek IV The Voyage Home (1986)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Lost World Jurassic Park (1997)
# Score: Chris=6648 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Lost World Jurassic Park (1997)" "/mnt/unraid/media/4K Movies/"

# Chris has better: The Suicide Squad (2021)
# Score: Chris=6653 vs Ali=0
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4kmovies/The Suicide Squad (2021)" "/mnt/unraid/media/4K Movies/"

