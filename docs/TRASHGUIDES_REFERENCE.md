# TRASHGuides Profile Reference for Project Mother

**Last Updated:** 2024-12-23

---

## HDR Format Scoring (Your Preferences)

### Priority Order:
1. **HDR10** - 300 points (Standard HDR, HIGHEST priority)
2. **DV HDR10** - 280 points (Dolby Vision with HDR10 fallback)
3. **HDR** - 250 points (Generic HDR)
4. **DV** - 150 points (Dolby Vision only, no fallback)
5. **DV HLG** - 140 points (DV with HLG fallback)
6. **DV SDR** - 130 points (DV with SDR fallback)
7. **HDR10+** - 100 points (Samsung proprietary)
8. **HLG** - 100 points (Hybrid Log-Gamma)

### Why This Order:
- **HDR10** is the universal standard, widest compatibility - HIGHEST
- **DV HDR10** gives you DV on compatible displays + HDR10 fallback for everything else
- **HDR** catches generic HDR releases
- **DV** (without fallback) works only on DV displays, less universal
- **HDR10+** is Samsung-only, limited compatibility
- **HLG** is broadcast-focused, less common for movies

---

## Audio Format Scoring

### Priority Order:
1. **TrueHD Atmos** - 300 points (Best of the best)
2. **DTS:X** - 290 points (Immersive audio)
3. **ATMOS (undefined)** - 280 points (Atmos without TrueHD)
4. **DD+ Atmos** - 270 points (Lossy Atmos)
5. **TrueHD** - 250 points (Lossless without Atmos)
6. **DTS-HD MA** - 240 points (DTS lossless)
7. **FLAC** - 230 points (Lossless)
8. **PCM** - 220 points (Uncompressed)
9. **DTS-HD HRA** - 210 points (High-resolution DTS)
10. **DD+** - 150 points (Lossy but good)
11. **DTS-ES** - 140 points (DTS Extended Surround)
12. **DTS** - 130 points (Standard DTS)
13. **AAC** - 100 points (Decent lossy)
14. **DD (AC3)** - 90 points (Basic Dolby Digital)

---

## Source Quality Scoring

### Priority Order (1080p):
1. **Bluray-1080p Remux** - 1000 points (Uncompressed)
2. **Bluray-1080p** - 800 points (Compressed but high quality)
3. **WEB-DL 1080p** - 600 points (Streaming source, high quality)
4. **WEBRip 1080p** - 500 points (Ripped streaming)
5. **HDTV 1080p** - 300 points (TV broadcast)

### Priority Order (4K):
1. **Bluray-2160p Remux** - 1000 points (Uncompressed 4K)
2. **Bluray-2160p** - 800 points (Compressed 4K)
3. **WEB-DL 2160p** - 600 points (4K streaming)
4. **WEBRip 2160p** - 500 points (Ripped 4K streaming)

---

## Video Codec Scoring

1. **AV1** - 250 points (Best compression, future-proof)
2. **HEVC (x265)** - 200 points (Great compression for 4K)
3. **AVC (x264)** - 150 points (Standard, widely compatible)

---

## Unwanted Formats (Negative Scores)

These get **-10000 points** (effectively rejected):
- **BR-DISK** - Raw Blu-ray disc structure
- **LQ** - Low quality releases
- **x265 (HD)** - x265 for 1080p (not worth it, use for 4K only)
- **3D** - 3D releases

---

## Release Group Tiers

### WEB Tier 01 (Highest Quality Web):
- HMAX, DSNP, MA, ATVP, SHO, NF

### WEB Tier 02 (Good Quality Web):
- AMZN, PMTP, PCOK, iT

### WEB Tier 03 (Standard Quality Web):
- HBO, RED, CC, STAN, VDL

---

## Complete TRASHGuides Custom Format IDs

### HDR Formats:
```yaml
# HDR10 (Preferred)
- dfb86d5941bc9075d6af23b09c2aeecd  # HDR10

# HDR (Generic)
- e61e28db95d22bedcadf030b8f156d96  # HDR
- 2a4d9069cc1fe3242ff98b9b6b2a7d95  # HDR (undefined)

# Dolby Vision
- 58d6a88f13e2db7f5059c41047876f00  # DV
- e23edd2482476e595fb990b12e7c609c  # DV HDR10
- 55d53828b9d81cbe20cbe416988b0f26b  # DV HLG
- a3e19f8f627608af0aa89b7ac4c61dc   # DV SDR

# HDR10+ (Samsung)
- c465d6fc6bb816b6b39bef8c7a1add3c7  # HDR10Plus

# HLG
- b974a6cd08c1066250f1f177d7aa1225  # HLG
```

### Audio Formats:
```yaml
- 496f355514737f7d83bf7aa4d24f8169  # TrueHD Atmos
- 2f22d89048b01681dde8afe203bf2e95  # DTS:X
- 417804f7f2c4308c1f4c5d380d4c4475  # ATMOS (undefined)
- 1af239278386be2919e1bcee0bde047e  # DD+ Atmos
- 3cafb66171b47f226146a0770576870f  # TrueHD
- dcf3ec6938fa32445f590a4da84256cd  # DTS-HD MA
- a570d4a0e56a2874b64e5bfa55202a1b  # FLAC
- e7c2fcae07cbada050a0af3357491d7b  # PCM
- 8e109e50e0a0b83a5098b056e13bf6db  # DTS-HD HRA
- 185f1dd7264c4562b9022d963ac37424  # DD+
- f9f847ac70a0af62ea4a08280b859636  # DTS-ES
- 1c1a4c5e823891c75bc50380a6866f73  # DTS
- 240770601cc226190c367ef59aba7463  # AAC
- c2998bd0d90ed5621d8df281e839436e  # DD (AC3)
```

### Movie Versions:
```yaml
- 0f12c086e289cf966fa5948eac571f44  # Hybrid
- 570bc9ebecd92723d2d21500f4be314c  # Remaster
- eca37840c13c6ef2dd0262b141a5482f  # 4K Remaster
- e0c07d59beb37348e975a930d5e50319  # Criterion Collection
- 9d27d9d2181838f76dee150882bdc58   # Masters of Cinema
- db9b4c4b53d312a876a3dc8c28be97ee6 # Vinegar Syndrome
```

### Unwanted:
```yaml
- ed38b889b31be83fda192888e2286d83  # BR-DISK
- 90a6f9a284dff5103f6346090e6280c8  # LQ
- dc98083864ea246d05a42df0d05f81cc  # x265 (HD) - Don't use x265 for 1080p
- b8cd450cbfa689c0259a01d9e29ba3d6  # 3D
```

### Release Groups (WEB):
```yaml
# Tier 01
- c20f169ef63c5f40c2def54abaf4438e  # WEB Tier 01

# Tier 02
- 403816d65392c79236dcb6dd591be69c  # WEB Tier 02

# Tier 03
- af94e0fe497124d1f9ce732069ec8c3b  # WEB Tier 03
```

---

## What Recyclarr Does

When you run `recyclarr sync`, it:

1. **Connects to your Radarr/Sonarr instances**
2. **Imports these custom formats** (creates them automatically)
3. **Applies the scores** you've configured
4. **Sets up quality profiles** according to your preferences
5. **Keeps everything in sync** with TRASHGuides updates

---

## Quality Profile Summary

### Radarr HD Profile: "HD-Bluray + WEB"
- Prefers Remux quality
- HDR10 > HDR > DV > HDR10+
- Atmos audio preferred
- Upgrades until Bluray-1080p Remux

### Radarr 4K Profile: "UHD-Bluray + WEB"  
- Prefers 4K Remux quality
- HDR10 > HDR > DV > HDR10+ (even more important in 4K!)
- Atmos audio highly preferred
- Upgrades until Bluray-2160p Remux

### Sonarr HD Profile: "WEB-1080p"
- WEB-DL preferred for TV shows
- HDR formats less critical (most TV is SDR)
- Streaming service quality tiers matter

### Sonarr 4K Profile: "WEB-2160p"
- 4K WEB-DL for TV
- HDR10 preferred when available
- Streaming service quality tiers matter

---

## How to Customize

If you want to adjust scores, edit the `recyclarr.yml` file:

```yaml
custom_formats:
  - trash_ids:
      - dfb86d5941bc9075d6af23b09c2aeecd  # HDR10
    quality_profiles:
      - name: HD-Bluray + WEB
        score: 300  # Change this number
```

Higher number = higher priority!

---

## References

- [TRASHGuides Main Site](https://trash-guides.info/)
- [Radarr Custom Formats](https://trash-guides.info/Radarr/Radarr-collection-of-custom-formats/)
- [Sonarr Release Profiles](https://trash-guides.info/Sonarr/sonarr-release-profile-regex/)
- [Recyclarr Documentation](https://recyclarr.dev/)
