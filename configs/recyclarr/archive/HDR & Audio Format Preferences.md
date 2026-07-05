# PROJECT MOTHER - HDR & AUDIO FORMAT PREFERENCES

## Quality Scoring System

This document details the HDR formats, audio formats, and quality profiles for Project Mother. Higher scores = Better quality.

**Last Updated:** 2024-12-28

---

## Architecture Overview

### Radarr Instances (Movies)

| Instance | Docker Container | Purpose | Library Path (Synology) | Library Path (Unraid) |
|----------|-----------------|---------|-------------------------|----------------------|
| **Radarr-HD** | `radarr-hd:7878` | 1080p Movies | `/mnt/synology/rs-movies` | `/mnt/unraid/media/Movies` |
| **Radarr-4K** | `radarr-4k:7878` | 4K Movies | `/mnt/synology/rs-4kmedia/4kmovies` | `/mnt/unraid/media/4K Movies` |

### Sonarr Instances (TV Shows)

| Instance | Docker Container | Purpose | Library Path (Synology) | Library Path (Unraid) |
|----------|-----------------|---------|-------------------------|----------------------|
| **Sonarr-HD** | `sonarr-hd:8989` | 1080p TV Shows | `/mnt/synology/rs-tv` | `/mnt/unraid/media/TV Shows` |
| **Sonarr-4K** | `sonarr-4k:8989` | 4K TV Shows | `/mnt/synology/rs-4kmedia/4ktv` | `/mnt/unraid/media/4K TV Shows` |

### Deleted Folders (for sync removals)

| Library | Synology Path | Unraid Path |
|---------|---------------|-------------|
| Movies | `/mnt/synology/Deleted/Movies` | `/mnt/unraid/media/Deleted/Movies` |
| 4K Movies | `/mnt/synology/Deleted/4kMovies` | `/mnt/unraid/media/Deleted/4kMovies` |
| TV Shows | `/mnt/synology/Deleted/tvshows` | `/mnt/unraid/media/Deleted/tvshows` |
| 4K TV Shows | `/mnt/synology/Deleted/4ktvshows` | `/mnt/unraid/media/Deleted/4ktvshows` |

---

## Quality Profiles

### Radarr-HD (1080p Movies) Profiles

| Profile Name | Starting Quality | Final/Cutoff Quality | Use Case |
|--------------|-----------------|---------------------|----------|
| **HD Bluray + WEB** | WEB-DL 1080p | Bluray-1080p | Most movies |
| **Remux + WEB 1080p** | WEB-DL 1080p | Remux-1080p | Special/favorite movies |

### Radarr-4K (4K Movies) Profiles

| Profile Name | Starting Quality | Final/Cutoff Quality | Use Case |
|--------------|-----------------|---------------------|----------|
| **UHD Bluray + WEB** | WEB-DL 2160p | Bluray-2160p | Most 4K movies |
| **Remux + WEB 2160p** | WEB-DL 2160p | Remux-2160p | Special/favorite 4K movies |

### Sonarr-HD (1080p TV Shows) Profiles

| Profile Name | Starting Quality | Final/Cutoff Quality | Use Case |
|--------------|-----------------|---------------------|----------|
| **WEB-1080p** | WEB-DL 1080p | WEB-DL 1080p | Most TV shows (TRaSH default) |
| **Bluray-1080p** | WEB-DL 1080p | Bluray-1080p | Special shows |
| **Remux-1080p** | WEB-DL 1080p | Remux-1080p | Very special shows |

### Sonarr-4K (4K TV Shows) Profiles

| Profile Name | Starting Quality | Final/Cutoff Quality | Use Case |
|--------------|-----------------|---------------------|----------|
| **WEB-2160p** | WEB-DL 2160p | WEB-DL 2160p | Most 4K TV shows (TRaSH default) |
| **Bluray-2160p** | WEB-DL 2160p | Bluray-2160p | Special 4K shows |
| **Remux-2160p** | WEB-DL 2160p | Remux-2160p | Very special 4K shows |

---

## Naming Formats

### Radarr (Movies)

**Movie Folder Format:**
```
{Movie CleanTitle} ({Release Year})
```
Example: `Avatar (2009)/`

**Standard Movie Format:**
```
{Movie CleanTitle} {(Release Year)} {tmdb-{TmdbId}} - {edition-{Edition Tags}} {[MediaInfo 3D]}{[Custom Formats]}{[Quality Full]}{[Mediainfo AudioCodec}{ Mediainfo AudioChannels]}{[MediaInfo VideoDynamicRangeType]}{[Mediainfo VideoCodec]}{-Release Group}
```
Example: `Avatar (2009) {tmdb-19995} - [Bluray-1080p][DTS-HD MA 5.1][HDR][x265]-FraMeSToR.mkv`

### Sonarr (TV Shows)

**Series Folder Format:**
```
{Series TitleYear}
```
Example: `Breaking Bad (2008)/`

**Season Folder Format:**
```
Season {season:00}
```
Example: `Season 01/`

**Episode Format:**
```
{Series TitleYear} - S{season:00}E{episode:00} - {Episode CleanTitle:90} {[Custom Formats]}{[Quality Full]}{[Mediainfo AudioCodec}{ Mediainfo AudioChannels]}{[MediaInfo VideoDynamicRangeType]}{[Mediainfo VideoCodec]}{-Release Group}
```
Example: `Breaking Bad (2008) - S01E01 - Pilot [WEBDL-1080p][EAC3 5.1][x264]-NTb.mkv`

---

## HDR FORMATS (Video Dynamic Range)

### 4K HDR Scoring

| Rank | Format | Score | Description |
|------|--------|-------|-------------|
| 1 | **DV + HDR10** | +800 | Dolby Vision with HDR10 fallback (best compatibility + quality) |
| 2 | **HDR10 / HDR** | +700 | Standard HDR10 |
| 3 | **DV (Dolby Vision)** | +400 | Dolby Vision only |
| 4 | **HDR10+** | +300 | Samsung's dynamic HDR format |
| 5 | **SDR** | 0 | Standard Dynamic Range (no bonus) |

### 1080p HDR Scoring

**Important:** 1080p HDR content DOES exist - these are typically high-quality downscales from 4K masters, encoded in x265 with HDR preserved. These releases are valuable and should receive a bonus.

| Format | Score | Notes |
|--------|-------|-------|
| **HDR (any format)** | +400 | Bonus for 1080p HDR releases (downscaled 4K) |

**Priority Note:** Audio quality (Atmos = +500) trumps HDR (+400) at 1080p. A 1080p SDR with TrueHD Atmos is preferred over 1080p HDR with DD+.

### HDR Preference Summary

**Best:** `DV HDR10` (Dual-layer - best of both worlds)
**Good:** `HDR10`
**Acceptable:** `DV` or `HDR10+`
**Avoid when 4K:** SDR 4K releases (prefer 1080p HDR or 4K HDR)

---

## AUDIO FORMATS

### Ranking (Best to Worst)

| Rank | Format | Score | Description |
|------|--------|-------|-------------|
| 1 | **TrueHD Atmos** | +500 | Lossless Dolby Atmos (Blu-ray standard) |
| 2 | **TrueHD** | +450 | Lossless audio without Atmos |
| 3 | **DTS-HD MA** | +400 | DTS Master Audio (lossless) |
| 4 | **DTS** | +200 | Standard DTS |
| 5 | **DD+ / EAC3** | +150 | Enhanced AC3 (common on streaming) |
| 6 | **AC3** | +100 | Standard Dolby Digital |
| 7 | **AAC** | +50 | Advanced Audio Coding (lowest priority) |

### Channel Configuration Priorities

**Preferred order:**
1. **Atmos 7.1** or higher (immersive audio)
2. **7.1** (full surround)
3. **5.1** (standard surround)
4. **2.0** (stereo)

### Audio Preference Summary

**Best:** `TrueHD Atmos 7.1` (Blu-ray remux quality)
**Great:** `DTS-HD MA 5.1` or `DTS-HD MA 7.1`
**Good:** `DTS 5.1`
**Acceptable:** `DD+ 5.1` / `EAC3 Atmos 5.1` (streaming quality)
**Minimum:** `AC3 5.1`
**Avoid:** `AAC 2.0` (only if nothing better available)

---

## COMPLETE QUALITY SCORING BREAKDOWN

### Resolution Scores

| Resolution | Score |
|------------|-------|
| 2160p (4K) | +4000 |
| 1080p | +2000 |
| 720p | +1000 |
| 480p | +100 |

**Rule:** For 1080p libraries, 1080p trumps everything. A 1080p WEB-DL beats a 720p Remux.

### Source Quality Scores

| Source | Score | Description |
|--------|-------|-------------|
| Remux | +2000 | Untouched disc rip |
| Blu-ray encode | +1500 | High-quality encode |
| WEB-DL | +1000 | Direct streaming rip |
| WEBRip | +800 | Recorded stream |
| HDTV | +200 | TV broadcast |

### Video Codec Scores

| Codec | Score | Notes |
|-------|-------|-------|
| HEVC / H.265 / x265 | +200 | Better compression, required for HDR |
| AVC / H.264 / x264 | +100 | Universal compatibility |

**x265 Policy:** Use `x265 (no HDR/DV)` custom format at -10000 to:
- Block low-quality x265 re-encodes (SDR, low bitrate)
- Allow high-quality HDR 1080p releases (downscaled 4K with x265)

### HDR Scores (4K)

| Format | Score |
|--------|-------|
| DV + HDR10 | +800 |
| HDR10 / HDR | +700 |
| DV | +400 |
| HDR10+ | +300 |

### HDR Scores (1080p)

| Format | Score |
|--------|-------|
| Any HDR | +400 |

### Audio Scores

| Format | Score |
|--------|-------|
| TrueHD Atmos | +500 |
| TrueHD | +450 |
| DTS-HD MA | +400 |
| DTS | +200 |
| DD+ / EAC3 | +150 |
| AC3 | +100 |
| AAC | +50 |

### Bitrate Bonus

| Bitrate | Score |
|---------|-------|
| ≥50 Mbps | +200 |
| ≥30 Mbps | +150 |
| ≥20 Mbps | +100 |
| ≥10 Mbps | +50 |

---

## RELEASE GROUP TIERS

Using TRaSH defaults for release group scoring:

### HD Bluray Tiers (Radarr/Sonarr HD)
- **Tier 01:** Premium groups (highest quality encodes)
- **Tier 02:** High-quality groups
- **Tier 03:** Good quality groups

### UHD Bluray Tiers (Radarr/Sonarr 4K)
- **Tier 01:** Premium 4K groups
- **Tier 02:** High-quality 4K groups
- **Tier 03:** Good quality 4K groups

### WEB Tiers (All instances)
- **Tier 01:** Premium WEB groups (NTb, etc.)
- **Tier 02:** High-quality WEB groups
- **Tier 03:** Good quality WEB groups

---

## IDEAL FILE EXAMPLES

### Perfect 4K Movie
```
The Matrix (1999) {tmdb-603} - [Remux-2160p][DV HDR10][TrueHD Atmos 7.1][HEVC]-FraMeSToR.mkv
Score: 4000 + 2000 + 800 + 500 + 200 = 7,500
```

### Excellent 1080p Movie (SDR)
```
Inception (2010) {tmdb-27205} - [Remux-1080p][DTS-HD MA 7.1][AVC]-FraMeSToR.mkv
Score: 2000 + 2000 + 400 + 100 = 4,500
```

### Excellent 1080p Movie (HDR - downscaled 4K)
```
Dune (2021) {tmdb-438631} - [Bluray-1080p][HDR][TrueHD Atmos 7.1][x265]-DON.mkv
Score: 2000 + 1500 + 400 + 500 + 200 = 4,600
```

### Good Streaming 4K
```
Dune (2021) {tmdb-438631} - [WEBDL-2160p][DV HDR10][EAC3 Atmos 5.1][HEVC]-NTb.mkv
Score: 4000 + 1000 + 800 + 150 + 200 = 6,150
```

### Standard 1080p Blu-ray
```
The Dark Knight (2008) {tmdb-155} - [Bluray-1080p][DTS 5.1][x264]-CtrlHD.mkv
Score: 2000 + 1500 + 200 + 100 = 3,800
```

### TV Show Episode (WEB)
```
Breaking Bad (2008) - S01E01 - Pilot [WEBDL-1080p][EAC3 5.1][x264]-NTb.mkv
Score: 2000 + 1000 + 150 + 100 = 3,250
```

### TV Show Episode (Bluray)
```
Game of Thrones (2011) - S01E01 - Winter Is Coming [Bluray-1080p][DTS-HD MA 5.1][x264]-CtrlHD.mkv
Score: 2000 + 1500 + 400 + 100 = 4,000
```

---

## KEY TAKEAWAYS

### For 4K Content (Radarr-4K / Sonarr-4K)
1. **Must have:** HDR (prefer DV + HDR10)
2. **Audio priority:** TrueHD Atmos > DTS-HD MA > DD+ Atmos
3. **Source priority:** Remux > Blu-ray > WEB-DL
4. **Codec:** HEVC required for 4K HDR

### For 1080p Content (Radarr-HD / Sonarr-HD)
1. **Resolution:** 1080p trumps everything (1080p WEB-DL > 720p Remux)
2. **Audio priority:** TrueHD Atmos (+500) > HDR (+400) - Audio trumps HDR!
3. **Source priority:** Remux > Blu-ray > WEB-DL
4. **HDR Bonus:** 1080p HDR releases (downscaled 4K) get +400 bonus
5. **Codec:** x265 allowed WITH HDR, blocked without HDR (use `x265 no HDR/DV` format)

### For TV Shows
1. **Default:** WEB-1080p / WEB-2160p profiles (TRaSH recommended)
2. **Special shows:** Use Bluray or Remux profiles
3. **Same HDR/Audio rules as movies**

### General Rules
- **Remux > Encode** (when storage allows)
- **Lossless audio > Lossy** (TrueHD/DTS-HD MA preferred)
- **More channels = Better** (7.1 > 5.1 > 2.0)
- **Atmos adds immersion** (but needs compatible system)
- **Audio trumps HDR at 1080p**

---

## NOTES

- **Dolby Vision (DV):** Requires compatible TV/player
- **HDR10+:** Mainly Samsung TVs
- **TrueHD Atmos:** Requires HDMI passthrough to receiver
- **DTS-HD MA:** Near-universal compatibility
- **Bitrate matters:** Higher bitrate = better quality (generally)
- **1080p HDR:** Exists! Downscaled 4K releases use x265 with HDR preserved

---

## FILE ANALYSIS METHODOLOGY

When analyzing libraries for sync comparison:

1. **Determine library type from path:**
   - `/rs-movies/` or `/Movies/` = 1080p library
   - `/rs-4kmedia/4kmovies/` or `/4K Movies/` = 4K library
   - `/rs-tv/` or `/TV Shows/` = 1080p TV library
   - `/rs-4kmedia/4ktv/` or `/4K TV Shows/` = 4K TV library

2. **Parse filename for quality attributes:**
   - Resolution: `[Bluray-1080p]`, `[WEBDL-2160p]`, etc.
   - Audio: `[DTS-HD MA 5.1]`, `[TrueHD Atmos 7.1]`, etc.
   - HDR: `[HDR]`, `[DV HDR10]`, `[HDR10+]`, etc.
   - Codec: `[x264]`, `[x265]`, `[HEVC]`, etc.
   - Release Group: `-FraMeSToR`, `-NTb`, etc.

3. **Validate file placement:**
   - Flag any 4K files in 1080p libraries
   - Flag any 1080p files in 4K libraries

4. **Calculate quality score using this document's scoring system**

5. **Compare matching titles between Ali and Chris libraries**

6. **Generate sync plan:**
   - Keep higher-scoring version
   - Move lower-scoring version to Deleted folder

This scoring system is used for Project Mother library sync decisions.
