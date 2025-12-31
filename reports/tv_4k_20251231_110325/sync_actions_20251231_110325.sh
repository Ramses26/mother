#!/bin/bash
#==============================================================================
# Project Mother Sync Script
# RUN THIS ON MOTHER (10.0.0.162)
#==============================================================================
# Generated: 2025-12-31 11:03:25
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
run_cmd mv "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 01/Star Trek Strange New Worlds (2022) - S01E10 - A Quality of Mercy [PMTP PMTP PMTP WEBDL-2160p][DV][EAC3 5.1][h265].mkv" "/mnt/synology/rs-4kmedia/deleted/4K TV Shows/"


# === COPY BETTER QUALITY FILES ===

# Ali has better: Star Trek Discovery (2017)
# Score: Ali=6106 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Discovery (2017)/Season 04"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Discovery (2017)/Season 04/Star Trek Discovery (2017) - S04E03 - Choose to Live [[Trash] Release Sources (Streaming Service)_14_15 Release Sources (Streaming Service)_11_7 Release Sources (Streaming Service)_17_8 WEBDL-2160p][HDR10Plus][EAC3 5.1][HEVC]-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Discovery (2017)/Season 04/"

# Ali has better: Star Trek Discovery (2017)
# Score: Ali=6105 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Discovery (2017)/Season 04"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Discovery (2017)/Season 04/Star Trek Discovery (2017) - S04E04 - All Is Possible [[Trash] Release Sources (Streaming Service)_14_15 Release Sources (Streaming Service)_11_7 Release Sources (Streaming Service)_17_8 WEBDL-2160p][HDR10Plus][EAC3 5.1][HEVC]-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Discovery (2017)/Season 04/"

# Ali has better: Star Trek Discovery (2017)
# Score: Ali=6097 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Discovery (2017)/Season 04"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Discovery (2017)/Season 04/Star Trek Discovery (2017) - S04E06 - Stormy Weather [[Trash] Release Sources (Streaming Service)_14_15 Release Sources (Streaming Service)_11_7 Release Sources (Streaming Service)_17_8 WEBDL-2160p][HDR10Plus][EAC3 5.1][HEVC]-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Discovery (2017)/Season 04/"

# Ali has better: Star Trek Discovery (2017)
# Score: Ali=6100 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Discovery (2017)/Season 04"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Discovery (2017)/Season 04/Star Trek Discovery (2017) - S04E02 - Anomaly [[Trash] Release Sources (Streaming Service)_14_15 Release Sources (Streaming Service)_11_7 Release Sources (Streaming Service)_17_8 WEBDL-2160p][HDR10Plus][EAC3 5.1][HEVC]-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Discovery (2017)/Season 04/"

# Ali has better: Star Trek Discovery (2017)
# Score: Ali=6102 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Discovery (2017)/Season 04"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Discovery (2017)/Season 04/Star Trek Discovery (2017) - S04E05 - The Examples [[Trash] Release Sources (Streaming Service)_14_15 Release Sources (Streaming Service)_11_7 Release Sources (Streaming Service)_17_8 WEBDL-2160p][HDR10Plus][EAC3 5.1][HEVC]-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Discovery (2017)/Season 04/"

# Ali has better: Star Trek Strange New Worlds
# Score: Ali=6242 vs Chris=5812
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 03/Star Trek Strange New Worlds (2022) - S03E08 - Four-and-a-Half Vulcans [WEBDL-2160p][EAC3 5.1][DV HDR10Plus][h265]-HONE.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 03/"

# Ali has better: Fallout (2024)
# Score: Ali=6556 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Fallout (2024)/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Fallout (2024)/Season 02/Fallout (2024) - S02E03 - The Profligate [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 Atmos 5.1][DV HDR10Plus][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Fallout (2024)/Season 02/"

# Ali has better: Fallout (2024)
# Score: Ali=6463 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Fallout (2024)/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Fallout (2024)/Season 02/Fallout (2024) - S02E01 - The Father [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 Atmos 5.1][HDR10Plus][h265]-N1H4L.mkv" "/mnt/synology/rs-4kmedia/4ktv/Fallout (2024)/Season 02/"

# Ali has better: Fallout (2024)
# Score: Ali=6572 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Fallout (2024)/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Fallout (2024)/Season 02/Fallout (2024) - S02E02 - The Casino [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 Atmos 5.1][DV HDR10Plus][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Fallout (2024)/Season 02/"

# Ali has better: Fallout (2024)
# Score: Ali=6576 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Fallout (2024)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Fallout (2024)/Season 01/Fallout (2024) - S01E01 - The End [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DV HDR10Plus][EAC3 Atmos 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Fallout (2024)/Season 01/"

# Ali has better: Fallout (2024)
# Score: Ali=6566 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Fallout (2024)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Fallout (2024)/Season 01/Fallout (2024) - S01E02 - The Target [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DV HDR10Plus][EAC3 Atmos 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Fallout (2024)/Season 01/"

# Ali has better: Fallout (2024)
# Score: Ali=6557 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Fallout (2024)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Fallout (2024)/Season 01/Fallout (2024) - S01E03 - The Head [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DV HDR10Plus][EAC3 Atmos 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Fallout (2024)/Season 01/"

# Ali has better: Fallout (2024)
# Score: Ali=6548 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Fallout (2024)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Fallout (2024)/Season 01/Fallout (2024) - S01E04 - The Ghouls [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DV HDR10Plus][EAC3 Atmos 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Fallout (2024)/Season 01/"

# Ali has better: Fallout (2024)
# Score: Ali=6544 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Fallout (2024)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Fallout (2024)/Season 01/Fallout (2024) - S01E05 - The Past [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DV HDR10Plus][EAC3 Atmos 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Fallout (2024)/Season 01/"

# Ali has better: Fallout (2024)
# Score: Ali=6561 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Fallout (2024)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Fallout (2024)/Season 01/Fallout (2024) - S01E06 - The Trap [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DV HDR10Plus][EAC3 Atmos 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Fallout (2024)/Season 01/"

# Ali has better: Fallout (2024)
# Score: Ali=6561 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Fallout (2024)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Fallout (2024)/Season 01/Fallout (2024) - S01E07 - The Radio [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DV HDR10Plus][EAC3 Atmos 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Fallout (2024)/Season 01/"

# Ali has better: Fallout (2024)
# Score: Ali=6563 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Fallout (2024)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Fallout (2024)/Season 01/Fallout (2024) - S01E08 - The Beginning [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DV HDR10Plus][EAC3 Atmos 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Fallout (2024)/Season 01/"

# Ali has better: The Chosen (2019)
# Score: Ali=5415 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 05"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 05/The Chosen (2019) - S05E01 - Entry [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 05/"

# Ali has better: The Chosen (2019)
# Score: Ali=5403 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 05"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 05/The Chosen (2019) - S05E02 - House of Cards [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 05/"

# Ali has better: The Chosen (2019)
# Score: Ali=5398 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 05"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 05/The Chosen (2019) - S05E05 - Because of Me [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 05/"

# Ali has better: The Chosen (2019)
# Score: Ali=5407 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 05"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 05/The Chosen (2019) - S05E04 - The Same Coin [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 05/"

# Ali has better: The Chosen (2019)
# Score: Ali=5410 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 05"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 05/The Chosen (2019) - S05E03 - Woes [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 05/"

# Ali has better: The Chosen (2019)
# Score: Ali=5437 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 05"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 05/The Chosen (2019) - S05E08 - The Upper Room 2 [WEBDL-2160p][EAC3 5.1][h265]-radiantturacoofpremiumpride.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 05/"

# Ali has better: The Chosen (2019)
# Score: Ali=5831 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 05"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 05/The Chosen (2019) - S05E06 - Reunions [WEBDL-2160p][EAC3 5.1][h265]-loudvaliantlorikeetofmastery.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 05/"

# Ali has better: The Chosen (2019)
# Score: Ali=5435 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 05"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 05/The Chosen (2019) - S05E07 - The Upper Room 1 [WEBDL-2160p][EAC3 5.1][h265]-dexterouseggplantboobyofjoviality.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 05/"

# Ali has better: The Chosen (2019)
# Score: Ali=5418 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 02/The Chosen (2019) - S02E01 - Thunder [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 02/"

# Ali has better: The Chosen (2019)
# Score: Ali=5405 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 02/The Chosen (2019) - S02E02 - I Saw You [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 02/"

# Ali has better: The Chosen (2019)
# Score: Ali=5388 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 02/The Chosen (2019) - S02E03 - Matthew 424 [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 02/"

# Ali has better: The Chosen (2019)
# Score: Ali=5411 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 02/The Chosen (2019) - S02E04 - The Perfect Opportunity [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 02/"

# Ali has better: The Chosen (2019)
# Score: Ali=5400 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 02/The Chosen (2019) - S02E05 - Spirit [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 02/"

# Ali has better: The Chosen (2019)
# Score: Ali=5396 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 02/The Chosen (2019) - S02E06 - Unlawful [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 02/"

# Ali has better: The Chosen (2019)
# Score: Ali=5394 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 02/The Chosen (2019) - S02E07 - Reckoning [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 02/"

# Ali has better: The Chosen (2019)
# Score: Ali=5409 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 02/The Chosen (2019) - S02E08 - Beyond Mountains [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 02/"

# Ali has better: The Chosen (2019)
# Score: Ali=5407 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 01/The Chosen (2019) - S01E01 - I Have Called You by Name [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 01/"

# Ali has better: The Chosen (2019)
# Score: Ali=5390 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 01/The Chosen (2019) - S01E02 - Shabbat [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 01/"

# Ali has better: The Chosen (2019)
# Score: Ali=5381 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 01/The Chosen (2019) - S01E03 - Jesus Loves the Little Children [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 01/"

# Ali has better: The Chosen (2019)
# Score: Ali=5401 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 01/The Chosen (2019) - S01E04 - The Rock on Which It Is Built [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 01/"

# Ali has better: The Chosen (2019)
# Score: Ali=5407 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 01/The Chosen (2019) - S01E05 - The Wedding Gift [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 01/"

# Ali has better: The Chosen (2019)
# Score: Ali=5404 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 01/The Chosen (2019) - S01E06 - Indescribable Compassion [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 01/"

# Ali has better: The Chosen (2019)
# Score: Ali=5388 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 01/The Chosen (2019) - S01E07 - Invitations [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 01/"

# Ali has better: The Chosen (2019)
# Score: Ali=5413 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 01/The Chosen (2019) - S01E08 - I Am He [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 01/"

# Ali has better: The Chosen (2019)
# Score: Ali=5408 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 04"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 04/The Chosen (2019) - S04E01 - Promises [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 04/"

# Ali has better: The Chosen (2019)
# Score: Ali=5434 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 04"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 04/The Chosen (2019) - S04E02 - Confessions [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 04/"

# Ali has better: The Chosen (2019)
# Score: Ali=5409 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 04"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 04/The Chosen (2019) - S04E03 - Moon to Blood [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 04/"

# Ali has better: The Chosen (2019)
# Score: Ali=5418 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 04"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 04/The Chosen (2019) - S04E04 - Calm Before [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 04/"

# Ali has better: The Chosen (2019)
# Score: Ali=5421 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 04"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 04/The Chosen (2019) - S04E05 - Sitting Serving Scheming [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 04/"

# Ali has better: The Chosen (2019)
# Score: Ali=5417 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 04"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 04/The Chosen (2019) - S04E06 - Dedication [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 04/"

# Ali has better: The Chosen (2019)
# Score: Ali=5427 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 04"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 04/The Chosen (2019) - S04E07 - The Last Sign [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 04/"

# Ali has better: The Chosen (2019)
# Score: Ali=5436 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 04"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 04/The Chosen (2019) - S04E08 - Humble [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 04/"

# Ali has better: The Chosen (2019)
# Score: Ali=5414 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 03/The Chosen (2019) - S03E01 - Homecoming [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 03/"

# Ali has better: The Chosen (2019)
# Score: Ali=5423 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 03/The Chosen (2019) - S03E02 - Two by Two [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 03/"

# Ali has better: The Chosen (2019)
# Score: Ali=5405 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 03/The Chosen (2019) - S03E03 - Physician Heal Yourself [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 03/"

# Ali has better: The Chosen (2019)
# Score: Ali=5411 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 03/The Chosen (2019) - S03E04 - Clean 1 [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 03/"

# Ali has better: The Chosen (2019)
# Score: Ali=5407 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 03/The Chosen (2019) - S03E05 - Clean 2 [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 03/"

# Ali has better: The Chosen (2019)
# Score: Ali=5425 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 03/The Chosen (2019) - S03E06 - Intensity in Tent City [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 03/"

# Ali has better: The Chosen (2019)
# Score: Ali=5417 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 03/The Chosen (2019) - S03E07 - Ears to Hear [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 03/"

# Ali has better: The Chosen (2019)
# Score: Ali=5455 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Chosen (2019)/Season 03/The Chosen (2019) - S03E08 - Sustenance [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5][WEBDL-2160p][EAC3 5.1][h265]-playWEB.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Chosen (2019)/Season 03/"

# Ali has better: The Lord of the Rings The Rings of Power
# Score: Ali=6602 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 02/The Lord of the Rings The Rings of Power (2022) - S02E01 - Elv... [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DV HDR10Plus][EAC3 Atmos 5.1][h265]-HONE.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 02/"

# Ali has better: The Lord of the Rings The Rings of Power
# Score: Ali=6583 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 02/The Lord of the Rings The Rings of Power (2022) - S02E02 - Whe... [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DV HDR10Plus][EAC3 Atmos 5.1][h265]-HONE.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 02/"

# Ali has better: The Lord of the Rings The Rings of Power
# Score: Ali=6588 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 02/The Lord of the Rings The Rings of Power (2022) - S02E03 - The... [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DV HDR10Plus][EAC3 Atmos 5.1][h265]-HONE.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 02/"

# Ali has better: The Lord of the Rings The Rings of Power
# Score: Ali=6586 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 02/The Lord of the Rings The Rings of Power (2022) - S02E04 - Eldest [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DV HDR10Plus][EAC3 Atmos 5.1][h265]-HONE.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 02/"

# Ali has better: The Lord of the Rings The Rings of Power
# Score: Ali=6581 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 02/The Lord of the Rings The Rings of Power (2022) - S02E05 - Hal... [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DV HDR10Plus][EAC3 Atmos 5.1][h265]-HONE.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 02/"

# Ali has better: The Lord of the Rings The Rings of Power
# Score: Ali=6584 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 02/The Lord of the Rings The Rings of Power (2022) - S02E06 - Whe... [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DV HDR10Plus][EAC3 Atmos 5.1][h265]-HONE.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 02/"

# Ali has better: The Lord of the Rings The Rings of Power
# Score: Ali=6597 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 02/The Lord of the Rings The Rings of Power (2022) - S02E07 - Doo... [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DV HDR10Plus][EAC3 Atmos 5.1][h265]-HONE.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 02/"

# Ali has better: The Lord of the Rings The Rings of Power
# Score: Ali=6598 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 02/The Lord of the Rings The Rings of Power (2022) - S02E08 - Sha... [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DV HDR10Plus][EAC3 Atmos 5.1][h265]-HONE.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 02/"

# Ali has better: Shōgun (2024)
# Score: Ali=6207 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Shōgun (2024)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Shōgun (2024)/Season 01/Shōgun (2024) - S01E04 - The Eightfold Fence [[Trash] Release Sources (Streaming Service)_14_3 Release Sources (Streaming Service)_11_1 Release Sources (Streaming Service)_17_1 WEBDL-2160p][DV HDR10][EAC3 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Shōgun (2024)/Season 01/"

# Ali has better: Shōgun (2024)
# Score: Ali=6208 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Shōgun (2024)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Shōgun (2024)/Season 01/Shōgun (2024) - S01E05 - Broken to the Fist [[Trash] Release Sources (Streaming Service)_14_3 Release Sources (Streaming Service)_11_1 Release Sources (Streaming Service)_17_1 WEBDL-2160p][DV HDR10][EAC3 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Shōgun (2024)/Season 01/"

# Ali has better: Shōgun (2024)
# Score: Ali=6208 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Shōgun (2024)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Shōgun (2024)/Season 01/Shōgun (2024) - S01E06 - Ladies of the Willow World [[Trash] Release Sources (Streaming Service)_14_3 Release Sources (Streaming Service)_11_1 Release Sources (Streaming Service)_17_1 WEBDL-2160p][DV HDR10][EAC3 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Shōgun (2024)/Season 01/"

# Ali has better: Shōgun (2024)
# Score: Ali=6206 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Shōgun (2024)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Shōgun (2024)/Season 01/Shōgun (2024) - S01E07 - A Stick of Time [[Trash] Release Sources (Streaming Service)_14_3 Release Sources (Streaming Service)_11_1 Release Sources (Streaming Service)_17_1 WEBDL-2160p][DV HDR10][EAC3 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Shōgun (2024)/Season 01/"

# Ali has better: Shōgun (2024)
# Score: Ali=6214 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Shōgun (2024)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Shōgun (2024)/Season 01/Shōgun (2024) - S01E10 - A Dream of a Dream [[Trash] Release Sources (Streaming Service)_14_3 Release Sources (Streaming Service)_11_1 Release Sources (Streaming Service)_17_1 WEBDL-2160p][DV HDR10][EAC3 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Shōgun (2024)/Season 01/"

# Ali has better: Shōgun (2024)
# Score: Ali=6210 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Shōgun (2024)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Shōgun (2024)/Season 01/Shōgun (2024) - S01E02 - Servants of Two Masters [[Trash] Release Sources (Streaming Service)_14_3 Release Sources (Streaming Service)_11_1 Release Sources (Streaming Service)_17_1 WEBDL-2160p][DV HDR10][EAC3 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Shōgun (2024)/Season 01/"

# Ali has better: Shōgun (2024)
# Score: Ali=6220 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Shōgun (2024)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Shōgun (2024)/Season 01/Shōgun (2024) - S01E01 - Anjin [[Trash] Release Sources (Streaming Service)_14_3 Release Sources (Streaming Service)_11_1 Release Sources (Streaming Service)_17_1 WEBDL-2160p][DV HDR10][EAC3 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Shōgun (2024)/Season 01/"

# Ali has better: Shōgun (2024)
# Score: Ali=6204 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Shōgun (2024)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Shōgun (2024)/Season 01/Shōgun (2024) - S01E03 - Tomorrow Is Tomorrow [[Trash] Release Sources (Streaming Service)_14_3 Release Sources (Streaming Service)_11_1 Release Sources (Streaming Service)_17_1 WEBDL-2160p][DV HDR10][EAC3 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Shōgun (2024)/Season 01/"

# Ali has better: Shōgun (2024)
# Score: Ali=6210 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Shōgun (2024)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Shōgun (2024)/Season 01/Shōgun (2024) - S01E08 - Abyss of Life [[Trash] Release Sources (Streaming Service)_14_3 Release Sources (Streaming Service)_11_1 Release Sources (Streaming Service)_17_1 WEBDL-2160p][DV HDR10][EAC3 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Shōgun (2024)/Season 01/"

# Ali has better: Shōgun (2024)
# Score: Ali=6213 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Shōgun (2024)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Shōgun (2024)/Season 01/Shōgun (2024) - S01E09 - Crimson Sky [[Trash] Release Sources (Streaming Service)_14_3 Release Sources (Streaming Service)_11_1 Release Sources (Streaming Service)_17_1 WEBDL-2160p][DV HDR10][EAC3 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Shōgun (2024)/Season 01/"

# Ali has better: House of the Dragon (2022)
# Score: Ali=6606 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/House of the Dragon (2022)/Season 02/House of the Dragon (2022) - S02E08 - The Queen Who Ever Was [[Trash] Release Sources (Streaming Service)_14_7 Release Sources (Streaming Service)_11_2 Release Sources (Streaming Service)_17_2 WEBDL-2160p][DV HDR10][EAC3 Atmos 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 02/"

# Ali has better: House of the Dragon (2022)
# Score: Ali=6597 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/House of the Dragon (2022)/Season 02/House of the Dragon (2022) - S02E07 - The Red Sowing [[Trash] Release Sources (Streaming Service)_14_7 Release Sources (Streaming Service)_11_2 Release Sources (Streaming Service)_17_2 WEBDL-2160p][DV HDR10][EAC3 Atmos 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 02/"

# Ali has better: House of the Dragon (2022)
# Score: Ali=6607 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/House of the Dragon (2022)/Season 02/House of the Dragon (2022) - S02E02 - Rhaenyra the Cruel [[Trash] Release Sources (Streaming Service)_14_7 Release Sources (Streaming Service)_11_2 Release Sources (Streaming Service)_17_2 WEBDL-2160p][DV HDR10][EAC3 Atmos 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 02/"

# Ali has better: House of the Dragon (2022)
# Score: Ali=6589 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/House of the Dragon (2022)/Season 02/House of the Dragon (2022) - S02E01 - A Son for a Son [[Trash] Release Sources (Streaming Service)_14_7 Release Sources (Streaming Service)_11_2 Release Sources (Streaming Service)_17_2 WEBDL-2160p][DV HDR10][EAC3 Atmos 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 02/"

# Ali has better: House of the Dragon (2022)
# Score: Ali=6584 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/House of the Dragon (2022)/Season 02/House of the Dragon (2022) - S02E04 - A Dance of Dragons [[Trash] Release Sources (Streaming Service)_14_7 Release Sources (Streaming Service)_11_2 Release Sources (Streaming Service)_17_2 WEBDL-2160p][DV HDR10][EAC3 Atmos 5.1][h265]-APEX.mkv" "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 02/"

# Ali has better: House of the Dragon (2022)
# Score: Ali=6597 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/House of the Dragon (2022)/Season 02/House of the Dragon (2022) - S02E05 - Regent [[Trash] Release Sources (Streaming Service)_14_7 Release Sources (Streaming Service)_11_2 Release Sources (Streaming Service)_17_2 WEBDL-2160p][DV HDR10][EAC3 Atmos 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 02/"

# Ali has better: House of the Dragon (2022)
# Score: Ali=6603 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/House of the Dragon (2022)/Season 02/House of the Dragon (2022) - S02E06 - Smallfolk [[Trash] Release Sources (Streaming Service)_14_7 Release Sources (Streaming Service)_11_2 Release Sources (Streaming Service)_17_2 WEBDL-2160p][DV HDR10][EAC3 Atmos 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 02/"

# Ali has better: House of the Dragon (2022)
# Score: Ali=6602 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/House of the Dragon (2022)/Season 02/House of the Dragon (2022) - S02E03 - The Burning Mill [[Trash] Release Sources (Streaming Service)_14_7 Release Sources (Streaming Service)_11_2 Release Sources (Streaming Service)_17_2 WEBDL-2160p][DV HDR10][EAC3 Atmos 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 02/"

# Ali has better: Planet Earth III (2023)
# Score: Ali=5627 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Planet Earth III (2023)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Planet Earth III (2023)/Season 01/Planet Earth III (2023) - S01E01 - Coasts [WEBDL-2160p][HLG][AAC 2.0][HEVC]-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/Planet Earth III (2023)/Season 01/"

# Ali has better: Planet Earth III (2023)
# Score: Ali=5627 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Planet Earth III (2023)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Planet Earth III (2023)/Season 01/Planet Earth III (2023) - S01E02 - Ocean [WEBDL-2160p][HLG][AAC 2.0][HEVC]-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/Planet Earth III (2023)/Season 01/"

# Ali has better: Planet Earth III (2023)
# Score: Ali=5626 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Planet Earth III (2023)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Planet Earth III (2023)/Season 01/Planet Earth III (2023) - S01E03 - Deserts and Grasslands [WEBDL-2160p][HLG][AAC 2.0][HEVC]-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/Planet Earth III (2023)/Season 01/"

# Ali has better: Planet Earth III (2023)
# Score: Ali=5626 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Planet Earth III (2023)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Planet Earth III (2023)/Season 01/Planet Earth III (2023) - S01E04 - Freshwater [WEBDL-2160p][HLG][AAC 2.0][HEVC]-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/Planet Earth III (2023)/Season 01/"

# Ali has better: Planet Earth III (2023)
# Score: Ali=5625 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Planet Earth III (2023)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Planet Earth III (2023)/Season 01/Planet Earth III (2023) - S01E05 - Forests [WEBDL-2160p][HLG][AAC 2.0][HEVC]-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/Planet Earth III (2023)/Season 01/"

# Ali has better: Planet Earth III (2023)
# Score: Ali=5626 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Planet Earth III (2023)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Planet Earth III (2023)/Season 01/Planet Earth III (2023) - S01E06 - Extremes [WEBDL-2160p][HLG][AAC 2.0][HEVC]-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/Planet Earth III (2023)/Season 01/"

# Ali has better: Planet Earth III (2023)
# Score: Ali=5625 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Planet Earth III (2023)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Planet Earth III (2023)/Season 01/Planet Earth III (2023) - S01E07 - Human [WEBDL-2160p][HLG][AAC 2.0][HEVC]-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/Planet Earth III (2023)/Season 01/"

# Ali has better: Planet Earth III (2023)
# Score: Ali=5626 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Planet Earth III (2023)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Planet Earth III (2023)/Season 01/Planet Earth III (2023) - S01E08 - Heroes [WEBDL-2160p][HLG][AAC 2.0][HEVC]-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/Planet Earth III (2023)/Season 01/"

# Ali has better: Star Trek Picard
# Score: Ali=5660 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Picard/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Picard/Season 03/Star Trek Picard (2020) - S03E08 - Part Eight Surrender [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DTS-HD MA 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Picard/Season 03/"

# Ali has better: Star Trek Picard
# Score: Ali=5662 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Picard/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Picard/Season 03/Star Trek Picard (2020) - S03E01 - Part One The Next Generation [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DTS-HD MA 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Picard/Season 03/"

# Ali has better: Star Trek Picard
# Score: Ali=5656 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Picard/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Picard/Season 03/Star Trek Picard (2020) - S03E02 - Part Two Disengage [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DTS-HD MA 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Picard/Season 03/"

# Ali has better: Star Trek Picard
# Score: Ali=5654 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Picard/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Picard/Season 03/Star Trek Picard (2020) - S03E09 - Part Nine Võx [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DTS-HD MA 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Picard/Season 03/"

# Ali has better: Star Trek Picard
# Score: Ali=5665 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Picard/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Picard/Season 03/Star Trek Picard (2020) - S03E03 - Part Three Seventeen Seconds [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DTS-HD MA 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Picard/Season 03/"

# Ali has better: Star Trek Picard
# Score: Ali=5674 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Picard/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Picard/Season 03/Star Trek Picard (2020) - S03E10 - Part Ten The Last Generation [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DTS-HD MA 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Picard/Season 03/"

# Ali has better: Star Trek Picard
# Score: Ali=5667 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Picard/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Picard/Season 03/Star Trek Picard (2020) - S03E04 - Part Four No Win Scenario [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DTS-HD MA 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Picard/Season 03/"

# Ali has better: Star Trek Picard
# Score: Ali=5663 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Picard/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Picard/Season 03/Star Trek Picard (2020) - S03E05 - Part Five Imposters [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DTS-HD MA 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Picard/Season 03/"

# Ali has better: Star Trek Picard
# Score: Ali=5661 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Picard/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Picard/Season 03/Star Trek Picard (2020) - S03E06 - Part Six The Bounty [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DTS-HD MA 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Picard/Season 03/"

# Ali has better: Star Trek Picard
# Score: Ali=5653 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Picard/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Picard/Season 03/Star Trek Picard (2020) - S03E07 - Part Seven Dominion [[Trash] Release Sources (Streaming Service)_14_0 Release Sources (Streaming Service)_11_5 Release Sources (Streaming Service)_17_5 WEBDL-2160p][DTS-HD MA 5.1][h265]-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Picard/Season 03/"

# Ali has better: Star Trek Strange New Worlds
# Score: Ali=5751 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02/Star.Trek.Strange.New.Worlds.S02E01.The.Broken.Circle.2160p.PMTP.WEB-DL.DDP5.1.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02/"

# Ali has better: Star Trek Strange New Worlds
# Score: Ali=5755 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02/Star.Trek.Strange.New.Worlds.S02E02.Ad.Astra.per.Aspera.2160p.PMTP.WEB-DL.DDP5.1.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02/"

# Ali has better: Star Trek Strange New Worlds
# Score: Ali=5759 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02/Star.Trek.Strange.New.Worlds.S02E03.Tomorrow.and.Tomorrow.and.Tomorrow.2160p.PMTP.WEB-DL.DDP5.1.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02/"

# Ali has better: Star Trek Strange New Worlds
# Score: Ali=5757 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02/Star.Trek.Strange.New.Worlds.S02E04.Among.the.Lotus.Eaters.2160p.PMTP.WEB-DL.DDP5.1.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02/"

# Ali has better: Star Trek Strange New Worlds
# Score: Ali=5759 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02/Star.Trek.Strange.New.Worlds.S02E05.Charades.REPACK.2160p.PMTP.WEB-DL.DDP5.1.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02/"

# Ali has better: Star Trek Strange New Worlds
# Score: Ali=5753 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02/Star.Trek.Strange.New.Worlds.S02E06.Lost.in.Translation.2160p.PMTP.WEB-DL.DDP5.1.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02/"

# Ali has better: Star Trek Strange New Worlds
# Score: Ali=5747 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02/Star.Trek.Strange.New.Worlds.S02E07.Those.Old.Scientists.2160p.PMTP.WEB-DL.DDP5.1.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02/"

# Ali has better: Star Trek Strange New Worlds
# Score: Ali=5748 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02/Star.Trek.Strange.New.Worlds.S02E08.Under.the.Cloak.of.War.2160p.PMTP.WEB-DL.DDP5.1.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02/"

# Ali has better: Star Trek Strange New Worlds
# Score: Ali=5761 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02/Star.Trek.Strange.New.Worlds.S02E09.Subspace.Rhapsody.2160p.PMTP.WEB-DL.DDP5.1.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02/"

# Ali has better: Star Trek Strange New Worlds
# Score: Ali=5752 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02/Star.Trek.Strange.New.Worlds.S02E10.Hegemony.2160p.PMTP.WEB-DL.DDP5.1.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02/"

# Ali has better: The Lord of the Rings The Rings of Power
# Score: Ali=5786 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01/The.Lord.Of.The.Rings-The.Rings.Of.Power.2022.S01E01.2160p.AMZN.WEB-DL.Hybrid.HDR10.DV.HEVC.DDPA5.1.English-HONE.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01/"

# Ali has better: The Lord of the Rings The Rings of Power
# Score: Ali=5789 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01/The.Lord.Of.The.Rings-The.Rings.Of.Power.2022.S01E02.2160p.AMZN.WEB-DL.Hybrid.HDR10.DV.HEVC.DDPA5.1.English-HONE.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01/"

# Ali has better: The Lord of the Rings The Rings of Power
# Score: Ali=5793 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01/The.Lord.Of.The.Rings-The.Rings.Of.Power.2022.S01E03.2160p.AMZN.WEB-DL.Hybrid.HDR10.DV.HEVC.DDPA5.1.English-HONE.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01/"

# Ali has better: The Lord of the Rings The Rings of Power
# Score: Ali=5796 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01/The.Lord.Of.The.Rings-The.Rings.Of.Power.2022.S01E04.2160p.AMZN.WEB-DL.Hybrid.HDR10.DV.HEVC.DDPA5.1.English-HONE.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01/"

# Ali has better: The Lord of the Rings The Rings of Power
# Score: Ali=5797 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01/The.Lord.Of.The.Rings-The.Rings.Of.Power.2022.S01E05.2160p.AMZN.WEB-DL.Hybrid.HDR10.DV.HEVC.DDPA5.1.English-HONE.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01/"

# Ali has better: The Lord of the Rings The Rings of Power
# Score: Ali=5793 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01/The.Lord.Of.The.Rings-The.Rings.Of.Power.2022.S01E06.2160p.AMZN.WEB-DL.Hybrid.HDR10.DV.HEVC.DDPA5.1.English-HONE.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01/"

# Ali has better: The Lord of the Rings The Rings of Power
# Score: Ali=5797 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01/The.Lord.Of.The.Rings-The.Rings.Of.Power.2022.S01E08.2160p.AMZN.WEB-DL.Hybrid.HDR10.DV.HEVC.DDPA5.1.English-HONE.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01/"

# Ali has better: The Lord of the Rings The Rings of Power
# Score: Ali=5797 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01/The.Lord.Of.The.Rings-The.Rings.Of.Power.2022.S01E07.2160p.AMZN.WEB-DL.Hybrid.HDR10.DV.HEVC.DDPA5.1.English-HONE.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01/"

# Ali has better: Planet Earth II
# Score: Ali=6762 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Planet Earth II/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Planet Earth II/Season 01/Planet.Earth.II.S01E02.Mountains.2160p.DTS-HD.MA.5.1.HEVC.REMUX-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4ktv/Planet Earth II/Season 01/"

# Ali has better: Planet Earth II
# Score: Ali=6765 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Planet Earth II/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Planet Earth II/Season 01/Planet.Earth.II.S01E03.Jungles.2160p.DTS-HD.MA.5.1.HEVC.REMUX-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4ktv/Planet Earth II/Season 01/"

# Ali has better: Planet Earth II
# Score: Ali=6761 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Planet Earth II/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Planet Earth II/Season 01/Planet.Earth.II.S01E04.Deserts.2160p.DTS-HD.MA.5.1.HEVC.REMUX-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4ktv/Planet Earth II/Season 01/"

# Ali has better: Planet Earth II
# Score: Ali=6762 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Planet Earth II/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Planet Earth II/Season 01/Planet.Earth.II.S01E05.Grasslands.2160p.DTS-HD.MA.5.1.HEVC.REMUX-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4ktv/Planet Earth II/Season 01/"

# Ali has better: Planet Earth II
# Score: Ali=6761 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Planet Earth II/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Planet Earth II/Season 01/Planet.Earth.II.S01E06.Cities.2160p.DTS-HD.MA.5.1.HEVC.REMUX-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4ktv/Planet Earth II/Season 01/"

# Ali has better: Planet Earth II
# Score: Ali=6768 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Planet Earth II/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Planet Earth II/Season 01/Planet.Earth.II.S01E01.Islands.2160p.DTS-HD.MA.5.1.HEVC.REMUX-FraMeSToR.mkv" "/mnt/synology/rs-4kmedia/4ktv/Planet Earth II/Season 01/"

# Ali has better: The Mandalorian
# Score: Ali=5733 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 03/The.Mandalorian.S03E01.Chapter.17.2160p.DSNP.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 03/"

# Ali has better: The Mandalorian
# Score: Ali=5739 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 03/The.Mandalorian.S03E02.Chapter.18.2160p.DSNP.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 03/"

# Ali has better: The Mandalorian
# Score: Ali=5749 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 03/The.Mandalorian.S03E03.Chapter.19.2160p.DSNP.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 03/"

# Ali has better: The Mandalorian
# Score: Ali=5728 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 03/The.Mandalorian.S03E04.Chapter.20.2160p.DSNP.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 03/"

# Ali has better: The Mandalorian
# Score: Ali=5737 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 03/The.Mandalorian.S03E05.Episode.5.2160p.DSNP.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 03/"

# Ali has better: The Mandalorian
# Score: Ali=5741 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 03/The.Mandalorian.S03E06.Chapter.22.2160p.DSNP.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 03/"

# Ali has better: The Mandalorian
# Score: Ali=5747 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 03/The.Mandalorian.S03E07.Chapter.23.2160p.DSNP.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 03/"

# Ali has better: The Mandalorian
# Score: Ali=5735 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 03"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 03/The.Mandalorian.S03E08.Chapter.24.2160p.DSNP.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 03/"

# Ali has better: The Mandalorian
# Score: Ali=5746 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 1/The.Mandalorian.S01E01.Chapter.1.The.Mandalorian.2160p.DSNP.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 1/"

# Ali has better: The Mandalorian
# Score: Ali=5735 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 1/The.Mandalorian.S01E02.Chapter.2.The.Child.2160p.DSNP.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 1/"

# Ali has better: The Mandalorian
# Score: Ali=5740 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 1/The.Mandalorian.S01E03.Chapter.3.The.Sin.2160p.DSNP.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 1/"

# Ali has better: The Mandalorian
# Score: Ali=5745 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 1/The.Mandalorian.S01E04.Chapter.4.Sanctuary.2160p.DSNP.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 1/"

# Ali has better: The Mandalorian
# Score: Ali=5738 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 1/The.Mandalorian.S01E05.Chapter.5.The.Gunslinger.2160p.DSNP.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 1/"

# Ali has better: The Mandalorian
# Score: Ali=5748 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 1/The.Mandalorian.S01E06.Chapter.6.The.Prisoner.2160p.DSNP.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 1/"

# Ali has better: The Mandalorian
# Score: Ali=5745 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 1/The.Mandalorian.S01E07.Chapter.7.The.Reckoning.2160p.DSNP.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 1/"

# Ali has better: The Mandalorian
# Score: Ali=5754 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 1/The.Mandalorian.S01E08.Chapter.8.Redemption.2160p.DSNP.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 1/"

# Ali has better: The Mandalorian
# Score: Ali=5760 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 2"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 2/The.Mandalorian.S02E01.Chapter.9.The.Marshal.2160p.DSNP.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 2/"

# Ali has better: The Mandalorian
# Score: Ali=5747 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 2"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 2/The.Mandalorian.S02E02.Chapter.10.The.Passenger.2160p.DSNP.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 2/"

# Ali has better: The Mandalorian
# Score: Ali=5738 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 2"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 2/The.Mandalorian.S02E03.Chapter.11.The.Heiress.2160p.DSNP.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 2/"

# Ali has better: The Mandalorian
# Score: Ali=5743 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 2"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 2/The.Mandalorian.S02E04.Chapter.12.The.Siege.2160p.DSNP.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 2/"

# Ali has better: The Mandalorian
# Score: Ali=5752 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 2"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 2/The.Mandalorian.S02E05.Chapter.13.The.Jedi.2160p.DSNP.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 2/"

# Ali has better: The Mandalorian
# Score: Ali=5736 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 2"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 2/The.Mandalorian.S02E06.Chapter.14.The.Tragedy.2160p.DSNP.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 2/"

# Ali has better: The Mandalorian
# Score: Ali=5742 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 2"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 2/The.Mandalorian.S02E07.Chapter.15.The.Believer.2160p.DSNP.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 2/"

# Ali has better: The Mandalorian
# Score: Ali=5750 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 2"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Mandalorian/Season 2/The.Mandalorian.S02E08.Chapter.16.The.Rescue.2160p.DSNP.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Mandalorian/Season 2/"

# Ali has better: Life on Our Planet (2023)
# Score: Ali=5752 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Life on Our Planet (2023)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Life on Our Planet (2023)/Season 01/Life.on.Our.Planet.S01E01.Chapter.1.The.Rules.of.Life.2160p.NF.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Life on Our Planet (2023)/Season 01/"

# Ali has better: Life on Our Planet (2023)
# Score: Ali=5771 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Life on Our Planet (2023)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Life on Our Planet (2023)/Season 01/Life.on.Our.Planet.S01E02.Chapter.2.The.First.Frontier.2160p.NF.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Life on Our Planet (2023)/Season 01/"

# Ali has better: Life on Our Planet (2023)
# Score: Ali=5780 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Life on Our Planet (2023)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Life on Our Planet (2023)/Season 01/Life.on.Our.Planet.S01E03.Chapter.3.Invaders.of.the.Land.2160p.NF.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Life on Our Planet (2023)/Season 01/"

# Ali has better: Life on Our Planet (2023)
# Score: Ali=5771 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Life on Our Planet (2023)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Life on Our Planet (2023)/Season 01/Life.on.Our.Planet.S01E04.Chapter.4.In.Cold.Blood.2160p.NF.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Life on Our Planet (2023)/Season 01/"

# Ali has better: Life on Our Planet (2023)
# Score: Ali=5766 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Life on Our Planet (2023)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Life on Our Planet (2023)/Season 01/Life.on.Our.Planet.S01E05.Chapter.5.In.the.Shadow.of.Giants.2160p.NF.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Life on Our Planet (2023)/Season 01/"

# Ali has better: Life on Our Planet (2023)
# Score: Ali=5771 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Life on Our Planet (2023)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Life on Our Planet (2023)/Season 01/Life.on.Our.Planet.S01E06.Chapter.6.Out.of.the.Ashes.2160p.NF.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Life on Our Planet (2023)/Season 01/"

# Ali has better: Life on Our Planet (2023)
# Score: Ali=5771 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Life on Our Planet (2023)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Life on Our Planet (2023)/Season 01/Life.on.Our.Planet.S01E07.Chapter.7.Inheriting.the.Earth.2160p.NF.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Life on Our Planet (2023)/Season 01/"

# Ali has better: Life on Our Planet (2023)
# Score: Ali=5762 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Life on Our Planet (2023)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Life on Our Planet (2023)/Season 01/Life.on.Our.Planet.S01E08.Chapter.8.Age.of.Ice.and.Fire.2160p.NF.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Life on Our Planet (2023)/Season 01/"

# Ali has better: House of the Dragon (2022)
# Score: Ali=5783 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/House of the Dragon (2022)/Season 01/House.of.the.Dragon.S01E01.The.Heirs.of.the.Dragon.2160p.HMAX.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-CRFW.mkv" "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 01/"

# Ali has better: House of the Dragon (2022)
# Score: Ali=5769 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/House of the Dragon (2022)/Season 01/House.of.the.Dragon.S01E02.The.Rogue.Prince.2160p.HMAX.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-CRFW.mkv" "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 01/"

# Ali has better: House of the Dragon (2022)
# Score: Ali=5782 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/House of the Dragon (2022)/Season 01/House.of.the.Dragon.S01E03.Second.of.His.Name.2160p.HMAX.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-CRFW.mkv" "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 01/"

# Ali has better: House of the Dragon (2022)
# Score: Ali=5780 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/House of the Dragon (2022)/Season 01/House.of.the.Dragon.S01E04.King.of.the.Narrow.Sea.2160p.HMAX.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-CRFW.mkv" "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 01/"

# Ali has better: House of the Dragon (2022)
# Score: Ali=5777 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/House of the Dragon (2022)/Season 01/House.of.the.Dragon.S01E05.We.Light.the.Way.2160p.HMAX.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-CRFW.mkv" "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 01/"

# Ali has better: House of the Dragon (2022)
# Score: Ali=5788 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/House of the Dragon (2022)/Season 01/House.of.the.Dragon.S01E06.The.Princess.and.the.Queen.2160p.HMAX.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-CRFW.mkv" "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 01/"

# Ali has better: House of the Dragon (2022)
# Score: Ali=5775 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/House of the Dragon (2022)/Season 01/House.of.the.Dragon.S01E07.Driftmark.2160p.HMAX.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-CRFW.mkv" "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 01/"

# Ali has better: House of the Dragon (2022)
# Score: Ali=5788 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/House of the Dragon (2022)/Season 01/House.of.the.Dragon.S01E08.The.Lord.of.the.Tides.2160p.HMAX.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-CRFW.mkv" "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 01/"

# Ali has better: House of the Dragon (2022)
# Score: Ali=5775 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/House of the Dragon (2022)/Season 01/House.of.the.Dragon.S01E09.The.Green.Council.2160p.HMAX.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-CRFW.mkv" "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 01/"

# Ali has better: House of the Dragon (2022)
# Score: Ali=5776 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/House of the Dragon (2022)/Season 01/House.of.the.Dragon.S01E10.The.Black.Queen.2160p.HMAX.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-CRFW.mkv" "/mnt/synology/rs-4kmedia/4ktv/House of the Dragon (2022)/Season 01/"

# Ali has better: The Boys
# Score: Ali=6064 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Boys/Season 3/The.Boys.S03E01.Payback.2160p.AMZN.WEB-DL.DDP5.1.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3/"

# Ali has better: The Boys
# Score: Ali=6061 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Boys/Season 3/The.Boys.S03E02.The.Only.Man.In.The.Sky.2160p.AMZN.WEB-DL.DDP5.1.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3/"

# Ali has better: The Boys
# Score: Ali=6063 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Boys/Season 3/The.Boys.S03E03.Barbary.Coast.2160p.AMZN.WEB-DL.DDP5.1.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3/"

# Ali has better: The Boys
# Score: Ali=6063 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Boys/Season 3/The.Boys.S03E04.Glorious.Five.Year.Plan.2160p.AMZN.WEB-DL.DDP5.1.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3/"

# Ali has better: The Boys
# Score: Ali=6063 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Boys/Season 3/The.Boys.S03E05.The.Last.Time.To.Look.On.This.World.Of.Lies.2160p.AMZN.WEB-DL.DDP5.1.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3/"

# Ali has better: The Boys
# Score: Ali=6062 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Boys/Season 3/The.Boys.S03E06.Herogasm.2160p.AMZN.WEB-DL.DDP5.1.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3/"

# Ali has better: The Boys
# Score: Ali=6067 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Boys/Season 3/The.Boys.S03E07.Here.Comes.a.Candle.to.Light.You.to.Bed.2160p.AMZN.WEB-DL.DDP5.1.HDR.H.265.FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3/"

# Ali has better: The Boys
# Score: Ali=6064 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Boys/Season 3/The.Boys.S03E08.The.Instant.White-Hot.Wild.2160p.AMZN.WEB-DL.DDP5.1.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3/"

# Ali has better: The Boys
# Score: Ali=5128 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Boys/Season 1/The.Boys.S01E01.The.Name.Of.The.Game.2160p.AMZN.WEBRip.DDP5.1.x264-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1/"

# Ali has better: The Boys
# Score: Ali=5124 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Boys/Season 1/The.Boys.S01E02.Cherry.2160p.AMZN.WEBRip.DDP5.1.x264-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1/"

# Ali has better: The Boys
# Score: Ali=5117 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Boys/Season 1/The.Boys.S01E03.Get.Some.2160p.AMZN.WEBRip.DDP5.1.x264-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1/"

# Ali has better: The Boys
# Score: Ali=5129 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Boys/Season 1/The.Boys.S01E04.The.Female.Of.The.Species.2160p.AMZN.WEBRip.DDP5.1.x264-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1/"

# Ali has better: The Boys
# Score: Ali=5127 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Boys/Season 1/The.Boys.S01E05.Good.For.The.Soul.2160p.AMZN.WEBRip.DDP5.1.x264-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1/"

# Ali has better: The Boys
# Score: Ali=5126 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Boys/Season 1/The.Boys.S01E06.The.Innocents.2160p.AMZN.WEBRip.DDP5.1.x264-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1/"

# Ali has better: The Boys
# Score: Ali=5115 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Boys/Season 1/The.Boys.S01E07.The.Self-Preservation.Society.2160p.AMZN.WEBRip.DDP5.1.x264-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1/"

# Ali has better: The Boys
# Score: Ali=5141 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/The Boys/Season 1/The.Boys.S01E08.You.Found.Me.2160p.AMZN.WEBRip.DDP5.1.x264-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1/"

# Ali has better: Blue Planet II
# Score: Ali=7470 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Blue Planet II/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Blue Planet II/Season 01/Blue.Planet.II.S01E02.The.Deep.2160p.UHD.BluRay.REMUX.HDR.HEVC.DTS-HD.MA.5.1-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/4ktv/Blue Planet II/Season 01/"

# Ali has better: Blue Planet II
# Score: Ali=7462 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Blue Planet II/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Blue Planet II/Season 01/Blue.Planet.II.S01E03.Coral.Reefs.2160p.UHD.BluRay.REMUX.HDR.HEVC.DTS-HD.MA.5.1-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/4ktv/Blue Planet II/Season 01/"

# Ali has better: Blue Planet II
# Score: Ali=7500 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Blue Planet II/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Blue Planet II/Season 01/Blue.Planet.II.S01E04.Big.Blue.2160p.UHD.BluRay.REMUX.HDR.HEVC.DTS-HD.MA.5.1-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/4ktv/Blue Planet II/Season 01/"

# Ali has better: Blue Planet II
# Score: Ali=7500 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Blue Planet II/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Blue Planet II/Season 01/Blue.Planet.II.S01E05.Green.Seas.2160p.UHD.BluRay.REMUX.HDR.HEVC.DTS-HD.MA.5.1-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/4ktv/Blue Planet II/Season 01/"

# Ali has better: Blue Planet II
# Score: Ali=7500 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Blue Planet II/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Blue Planet II/Season 01/Blue.Planet.II.S01E06.Coasts.2160p.UHD.BluRay.REMUX.HDR.HEVC.DTS-HD.MA.5.1-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/4ktv/Blue Planet II/Season 01/"

# Ali has better: Blue Planet II
# Score: Ali=7500 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Blue Planet II/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Blue Planet II/Season 01/Blue.Planet.II.S01E07.Our.Blue.Planet.2160p.UHD.BluRay.REMUX.HDR.HEVC.DTS-HD.MA.5.1-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/4ktv/Blue Planet II/Season 01/"

# Ali has better: Blue Planet II
# Score: Ali=7464 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Blue Planet II/Season 01"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Blue Planet II/Season 01/Blue.Planet.II.S01E01.One.Ocean.2160p.UHD.BluRay.REMUX.HDR.HEVC.DTS-HD.MA.5.1-EPSiLON.mkv" "/mnt/synology/rs-4kmedia/4ktv/Blue Planet II/Season 01/"

# Ali has better: Our Planet
# Score: Ali=5765 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Our Planet/Season 02/Our.Planet.2019.S02E01.Chapter.1.World.on.the.Move.2160p.NF.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 02/"

# Ali has better: Our Planet
# Score: Ali=5745 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Our Planet/Season 02/Our.Planet.2019.S02E02.Chapter.2.Following.the.Sun.2160p.NF.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 02/"

# Ali has better: Our Planet
# Score: Ali=5768 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Our Planet/Season 02/Our.Planet.2019.S02E03.Chapter.3.The.Next.Generation.2160p.NF.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 02/"

# Ali has better: Our Planet
# Score: Ali=5768 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 02"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Our Planet/Season 02/Our.Planet.2019.S02E04.Chapter.4.Freedom.to.Roam.2160p.NF.WEB-DL.DDP5.1.Atmos.DV.HDR.H.265-FLUX.mkv" "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 02/"

# Ali has better: Our Planet
# Score: Ali=5754 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Our Planet/Season 1/Our.Planet.S01E01.One.Planet.2160p.NF.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 1/"

# Ali has better: Our Planet
# Score: Ali=5757 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Our Planet/Season 1/Our.Planet.S01E02.Frozen.Worlds.2160p.NF.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 1/"

# Ali has better: Our Planet
# Score: Ali=5758 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Our Planet/Season 1/Our.Planet.S01E03.Jungles.2160p.NF.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 1/"

# Ali has better: Our Planet
# Score: Ali=5757 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Our Planet/Season 1/Our.Planet.S01E04.Coastal.Seas.2160p.NF.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 1/"

# Ali has better: Our Planet
# Score: Ali=5755 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Our Planet/Season 1/Our.Planet.S01E05.From.Deserts.to.Grasslands.2160p.NF.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 1/"

# Ali has better: Our Planet
# Score: Ali=5755 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Our Planet/Season 1/Our.Planet.S01E06.The.High.Seas.2160p.NF.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 1/"

# Ali has better: Our Planet
# Score: Ali=5755 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Our Planet/Season 1/Our.Planet.S01E07.Fresh.Water.2160p.NF.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 1/"

# Ali has better: Our Planet
# Score: Ali=5754 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/Our Planet/Season 1/Our.Planet.S01E08.Forests.2160p.NF.WEB-DL.DDP.5.1.Atmos.DoVi.HDR.HEVC-SiC.mkv" "/mnt/synology/rs-4kmedia/4ktv/Our Planet/Season 1/"

# Ali has better: SuperNatural
# Score: Ali=5748 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/SuperNatural/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/SuperNatural/Season 1/Super-Natural.S01E01.Strange.Relations.2160p.DSNP.WEB-DL.DDP5.1.DoVi.H.265-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/SuperNatural/Season 1/"

# Ali has better: SuperNatural
# Score: Ali=5754 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/SuperNatural/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/SuperNatural/Season 1/Super-Natural.S01E02.Bloodline.2160p.DSNP.WEB-DL.DDP5.1.DoVi.H.265-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/SuperNatural/Season 1/"

# Ali has better: SuperNatural
# Score: Ali=5747 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/SuperNatural/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/SuperNatural/Season 1/Super-Natural.S01E03.Eat.or.Be.Eaten.2160p.DSNP.WEB-DL.DDP5.1.DoVi.H.265-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/SuperNatural/Season 1/"

# Ali has better: SuperNatural
# Score: Ali=5749 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/SuperNatural/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/SuperNatural/Season 1/Super-Natural.S01E04.Rivals.2160p.DSNP.WEB-DL.DDP5.1.DoVi.H.265-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/SuperNatural/Season 1/"

# Ali has better: SuperNatural
# Score: Ali=5755 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/SuperNatural/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/SuperNatural/Season 1/Super-Natural.S01E05.The.Mating.Game.2160p.DSNP.WEB-DL.DDP5.1.DoVi.H.265-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/SuperNatural/Season 1/"

# Ali has better: SuperNatural
# Score: Ali=5748 vs Chris=0
run_cmd mkdir -p "/mnt/synology/rs-4kmedia/4ktv/SuperNatural/Season 1"
run_cmd rsync -avP "/mnt/unraid/media/4K TV Shows/SuperNatural/Season 1/Super-Natural.S01E06.Impossible.Journeys.2160p.DSNP.WEB-DL.DDP5.1.DoVi.H.265-NTb.mkv" "/mnt/synology/rs-4kmedia/4ktv/SuperNatural/Season 1/"

# Chris has better: Star Trek Strange New Worlds
# Score: Chris=5751 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02/Star.Trek.Strange.New.Worlds.S02E01.The.Broken.Circle.2160p.PMTP.WEB-DL.DDP5.1.DV.HDR.H.265-FLUX.mkv" "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02/"

# Chris has better: Star Trek Strange New Worlds
# Score: Chris=5755 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02/Star.Trek.Strange.New.Worlds.S02E02.Ad.Astra.per.Aspera.2160p.PMTP.WEB-DL.DDP5.1.DV.HDR.H.265-FLUX.mkv" "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02/"

# Chris has better: Star Trek Strange New Worlds
# Score: Chris=5759 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02/Star.Trek.Strange.New.Worlds.S02E03.Tomorrow.and.Tomorrow.and.Tomorrow.2160p.PMTP.WEB-DL.DDP5.1.DV.HDR.H.265-FLUX.mkv" "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02/"

# Chris has better: Star Trek Strange New Worlds
# Score: Chris=5757 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02/Star.Trek.Strange.New.Worlds.S02E04.Among.the.Lotus.Eaters.2160p.PMTP.WEB-DL.DDP5.1.DV.HDR.H.265-FLUX.mkv" "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02/"

# Chris has better: Star Trek Strange New Worlds
# Score: Chris=5759 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02/Star.Trek.Strange.New.Worlds.S02E05.Charades.REPACK.2160p.PMTP.WEB-DL.DDP5.1.DV.HDR.H.265-FLUX.mkv" "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02/"

# Chris has better: Star Trek Strange New Worlds
# Score: Chris=5753 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02/Star.Trek.Strange.New.Worlds.S02E06.Lost.in.Translation.2160p.PMTP.WEB-DL.DDP5.1.DV.HDR.H.265-FLUX.mkv" "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02/"

# Chris has better: Star Trek Strange New Worlds
# Score: Chris=5747 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02/Star.Trek.Strange.New.Worlds.S02E07.Those.Old.Scientists.2160p.PMTP.WEB-DL.DDP5.1.DV.HDR.H.265-FLUX.mkv" "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02/"

# Chris has better: Star Trek Strange New Worlds
# Score: Chris=5748 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02/Star.Trek.Strange.New.Worlds.S02E08.Under.the.Cloak.of.War.2160p.PMTP.WEB-DL.DDP5.1.DV.HDR.H.265-FLUX.mkv" "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02/"

# Chris has better: Star Trek Strange New Worlds
# Score: Chris=5761 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02/Star.Trek.Strange.New.Worlds.S02E09.Subspace.Rhapsody.2160p.PMTP.WEB-DL.DDP5.1.DV.HDR.H.265-FLUX.mkv" "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02/"

# Chris has better: Star Trek Strange New Worlds
# Score: Chris=5752 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/Star Trek Strange New Worlds/Season 02/Star.Trek.Strange.New.Worlds.S02E10.Hegemony.2160p.PMTP.WEB-DL.DDP5.1.DV.HDR.H.265-FLUX.mkv" "/mnt/unraid/media/4K TV Shows/Star Trek Strange New Worlds/Season 02/"

# Chris has better: The Boys
# Score: Chris=5128 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Boys/Season 1"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1/The.Boys.S01E01.The.Name.Of.The.Game.2160p.AMZN.WEBRip.DDP5.1.x264-NTb.mkv" "/mnt/unraid/media/4K TV Shows/The Boys/Season 1/"

# Chris has better: The Boys
# Score: Chris=5124 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Boys/Season 1"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1/The.Boys.S01E02.Cherry.2160p.AMZN.WEBRip.DDP5.1.x264-NTb.mkv" "/mnt/unraid/media/4K TV Shows/The Boys/Season 1/"

# Chris has better: The Boys
# Score: Chris=5117 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Boys/Season 1"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1/The.Boys.S01E03.Get.Some.2160p.AMZN.WEBRip.DDP5.1.x264-NTb.mkv" "/mnt/unraid/media/4K TV Shows/The Boys/Season 1/"

# Chris has better: The Boys
# Score: Chris=5129 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Boys/Season 1"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1/The.Boys.S01E04.The.Female.Of.The.Species.2160p.AMZN.WEBRip.DDP5.1.x264-NTb.mkv" "/mnt/unraid/media/4K TV Shows/The Boys/Season 1/"

# Chris has better: The Boys
# Score: Chris=5127 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Boys/Season 1"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1/The.Boys.S01E05.Good.For.The.Soul.2160p.AMZN.WEBRip.DDP5.1.x264-NTb.mkv" "/mnt/unraid/media/4K TV Shows/The Boys/Season 1/"

# Chris has better: The Boys
# Score: Chris=5126 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Boys/Season 1"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1/The.Boys.S01E06.The.Innocents.2160p.AMZN.WEBRip.DDP5.1.x264-NTb.mkv" "/mnt/unraid/media/4K TV Shows/The Boys/Season 1/"

# Chris has better: The Boys
# Score: Chris=5115 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Boys/Season 1"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1/The.Boys.S01E07.The.Self-Preservation.Society.2160p.AMZN.WEBRip.DDP5.1.x264-NTb.mkv" "/mnt/unraid/media/4K TV Shows/The Boys/Season 1/"

# Chris has better: The Boys
# Score: Chris=5141 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Boys/Season 1"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 1/The.Boys.S01E08.You.Found.Me.2160p.AMZN.WEBRip.DDP5.1.x264-NTb.mkv" "/mnt/unraid/media/4K TV Shows/The Boys/Season 1/"

# Chris has better: The Boys
# Score: Chris=6064 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Boys/Season 3"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3/The.Boys.S03E01.Payback.2160p.AMZN.WEB-DL.DDP5.1.HDR.H.265-FLUX.mkv" "/mnt/unraid/media/4K TV Shows/The Boys/Season 3/"

# Chris has better: The Boys
# Score: Chris=6061 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Boys/Season 3"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3/The.Boys.S03E02.The.Only.Man.In.The.Sky.2160p.AMZN.WEB-DL.DDP5.1.HDR.H.265-FLUX.mkv" "/mnt/unraid/media/4K TV Shows/The Boys/Season 3/"

# Chris has better: The Boys
# Score: Chris=6063 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Boys/Season 3"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3/The.Boys.S03E03.Barbary.Coast.2160p.AMZN.WEB-DL.DDP5.1.HDR.H.265-FLUX.mkv" "/mnt/unraid/media/4K TV Shows/The Boys/Season 3/"

# Chris has better: The Boys
# Score: Chris=6063 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Boys/Season 3"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3/The.Boys.S03E04.Glorious.Five.Year.Plan.2160p.AMZN.WEB-DL.DDP5.1.HDR.H.265-FLUX.mkv" "/mnt/unraid/media/4K TV Shows/The Boys/Season 3/"

# Chris has better: The Boys
# Score: Chris=6063 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Boys/Season 3"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3/The.Boys.S03E05.The.Last.Time.To.Look.On.This.World.Of.Lies.2160p.AMZN.WEB-DL.DDP5.1.HDR.H.265-FLUX.mkv" "/mnt/unraid/media/4K TV Shows/The Boys/Season 3/"

# Chris has better: The Boys
# Score: Chris=6062 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Boys/Season 3"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3/The.Boys.S03E06.Herogasm.2160p.AMZN.WEB-DL.DDP5.1.HDR.H.265-FLUX.mkv" "/mnt/unraid/media/4K TV Shows/The Boys/Season 3/"

# Chris has better: The Boys
# Score: Chris=6067 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Boys/Season 3"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3/The.Boys.S03E07.Here.Comes.a.Candle.to.Light.You.to.Bed.2160p.AMZN.WEB-DL.DDP5.1.HDR.H.265.FLUX.mkv" "/mnt/unraid/media/4K TV Shows/The Boys/Season 3/"

# Chris has better: The Boys
# Score: Chris=6064 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Boys/Season 3"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Boys/Season 3/The.Boys.S03E08.The.Instant.White-Hot.Wild.2160p.AMZN.WEB-DL.DDP5.1.HDR.H.265-FLUX.mkv" "/mnt/unraid/media/4K TV Shows/The Boys/Season 3/"

# Chris has better: The Lord of the Rings The Rings of Power
# Score: Chris=5786 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01/The.Lord.Of.The.Rings-The.Rings.Of.Power.2022.S01E01.2160p.AMZN.WEB-DL.Hybrid.HDR10.DV.HEVC.DDPA5.1.English-HONE.mkv" "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01/"

# Chris has better: The Lord of the Rings The Rings of Power
# Score: Chris=5789 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01/The.Lord.Of.The.Rings-The.Rings.Of.Power.2022.S01E02.2160p.AMZN.WEB-DL.Hybrid.HDR10.DV.HEVC.DDPA5.1.English-HONE.mkv" "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01/"

# Chris has better: The Lord of the Rings The Rings of Power
# Score: Chris=5793 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01/The.Lord.Of.The.Rings-The.Rings.Of.Power.2022.S01E03.2160p.AMZN.WEB-DL.Hybrid.HDR10.DV.HEVC.DDPA5.1.English-HONE.mkv" "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01/"

# Chris has better: The Lord of the Rings The Rings of Power
# Score: Chris=5796 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01/The.Lord.Of.The.Rings-The.Rings.Of.Power.2022.S01E04.2160p.AMZN.WEB-DL.Hybrid.HDR10.DV.HEVC.DDPA5.1.English-HONE.mkv" "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01/"

# Chris has better: The Lord of the Rings The Rings of Power
# Score: Chris=5797 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01/The.Lord.Of.The.Rings-The.Rings.Of.Power.2022.S01E05.2160p.AMZN.WEB-DL.Hybrid.HDR10.DV.HEVC.DDPA5.1.English-HONE.mkv" "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01/"

# Chris has better: The Lord of the Rings The Rings of Power
# Score: Chris=5793 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01/The.Lord.Of.The.Rings-The.Rings.Of.Power.2022.S01E06.2160p.AMZN.WEB-DL.Hybrid.HDR10.DV.HEVC.DDPA5.1.English-HONE.mkv" "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01/"

# Chris has better: The Lord of the Rings The Rings of Power
# Score: Chris=5797 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01/The.Lord.Of.The.Rings-The.Rings.Of.Power.2022.S01E07.2160p.AMZN.WEB-DL.Hybrid.HDR10.DV.HEVC.DDPA5.1.English-HONE.mkv" "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01/"

# Chris has better: The Lord of the Rings The Rings of Power
# Score: Chris=5797 vs Ali=0
run_cmd mkdir -p "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01"
run_cmd rsync -avP "/mnt/synology/rs-4kmedia/4ktv/The Lord of the Rings The Rings of Power/Season 01/The.Lord.Of.The.Rings-The.Rings.Of.Power.2022.S01E08.2160p.AMZN.WEB-DL.Hybrid.HDR10.DV.HEVC.DDPA5.1.English-HONE.mkv" "/mnt/unraid/media/4K TV Shows/The Lord of the Rings The Rings of Power/Season 01/"

