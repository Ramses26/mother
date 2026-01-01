# Project Mother - Recyclarr Configuration

## Overview

This configuration manages custom formats and quality profiles for Radarr and Sonarr using TRaSH Guides templates with minimal custom overrides.

**Last Updated:** 2026-01-01

---

## Quick Start

```bash
# Copy config to recyclarr location
cp recyclarr.yml ~/.config/recyclarr/recyclarr.yml

# Or for Docker
docker cp recyclarr.yml recyclarr:/config/recyclarr.yml

# Run sync
recyclarr sync

# Or for Docker
docker exec recyclarr recyclarr sync
```

---

## Instances & Profiles

### Radarr (Movies)

| Instance | Container | Profiles |
|----------|-----------|----------|
| **Radarr-HD** | `radarr-hd:7878` | HD Bluray + WEB, Remux + WEB 1080p |
| **Radarr-4K** | `radarr-4k:7878` | UHD Bluray + WEB, Remux + WEB 2160p |

### Sonarr (TV Shows)

| Instance | Container | Profiles |
|----------|-----------|----------|
| **Sonarr-HD** | `sonarr-hd:8989` | WEB-1080p, Bluray-1080p, Remux-1080p |
| **Sonarr-4K** | `sonarr-4k:8989` | WEB-2160p, Bluray-2160p, Remux-2160p |

---

## Profile Use Cases

| Profile | Use Case | Quality Priority |
|---------|----------|------------------|
| **HD/UHD Bluray + WEB** | Most movies | Bluray encode > WEB |
| **Remux + WEB 1080p/2160p** | Favorite movies | Remux > Bluray > WEB |
| **WEB-1080p/2160p** | Most TV shows | WEB-DL preferred |
| **Bluray-1080p/2160p** | Special TV shows | Bluray > WEB |
| **Remux-1080p/2160p** | Premium TV shows | Remux > Bluray > WEB |

---

## Key Customizations

### 1. x265 (no HDR/DV) Blocking

**Purpose:** Block low-quality x265 re-encodes while allowing high-quality HDR x265 releases.

| Scenario | Result |
|----------|--------|
| x265 **with** HDR/DV | ALLOWED (quality downscale from 4K) |
| x265 **without** HDR/DV | BLOCKED (-10000 score) |

**Trash IDs:**
- Radarr: `839bea857ed2c0a8e084f3cbdbd65ecb`
- Sonarr: `9b64dff695c2115facf1b6ea59c9bd07`

### 2. Unwanted Release Blockers

All profiles block these release types with -10000 score:

| Format | Radarr ID | Sonarr ID |
|--------|-----------|-----------|
| Bad Dual Groups | `b6832f586342ef70d9c128d40c07b872` | `32b367365729d530ca1c124a0b180c64` |
| EVO (no WEBDL) | `90cedc1fea7ea5d11298bebd3d1d3223` | N/A |
| No-RlsGroup | `ae9b7c9ebde1f3bd336a8cbd1ec4c5e5` | `82d40da2bc6923f41e14394075dd4b03` |
| Obfuscated | `7357cf5161efbf8c4d5d0c30b4815ee2` | `e1a997ddb54e3ecbfe06341ad323c458` |
| Retags | `5c44f52a8714fdd79bb4d98e2673be1f` | `06d66ab109d4d2eddb2794d21526d140` |
| Scene | `f537cf427b64c38c8e36298f657e4828` | `1b3994c551cbb92a2c781af061f4ab44` |

---

## Environment Variables

Set these in your `.env` file or environment:

```bash
RADARR_HD_API_KEY=your_api_key_here
RADARR_4K_API_KEY=your_api_key_here
SONARR_HD_API_KEY=your_api_key_here
SONARR_4K_API_KEY=your_api_key_here
```

---

## TRaSH Guide Templates Used

### Radarr
| Template | Purpose |
|----------|---------|
| `radarr-quality-definition-movie` | Quality size limits |
| `radarr-quality-profile-hd-bluray-web` | HD Bluray + WEB profile |
| `radarr-custom-formats-hd-bluray-web` | Custom formats for HD |
| `radarr-quality-profile-uhd-bluray-web` | UHD Bluray + WEB profile |
| `radarr-custom-formats-uhd-bluray-web` | Custom formats for UHD |
| `radarr-quality-profile-remux-web-1080p` | Remux 1080p profile |
| `radarr-custom-formats-remux-web-1080p` | Custom formats for Remux 1080p |
| `radarr-quality-profile-remux-web-2160p` | Remux 2160p profile |
| `radarr-custom-formats-remux-web-2160p` | Custom formats for Remux 2160p |

### Sonarr
| Template | Purpose |
|----------|---------|
| `sonarr-quality-definition-series` | Quality size limits |
| `sonarr-v4-quality-profile-web-1080p` | WEB-1080p profile |
| `sonarr-v4-custom-formats-web-1080p` | Custom formats for WEB 1080p |
| `sonarr-v4-quality-profile-web-2160p` | WEB-2160p profile |
| `sonarr-v4-custom-formats-web-2160p` | Custom formats for WEB 2160p |

---

## What Templates Provide Automatically

The TRaSH templates handle all of this (no manual configuration needed):

- **HDR Scoring:** DV HDR10, HDR10+, HDR10, DV, HLG, DV HLG, DV SDR
- **Audio Scoring:** TrueHD Atmos, DTS-HD MA, DTS:X, DD+ Atmos, TrueHD, FLAC, PCM
- **Release Group Tiers:** Tier 01/02/03 for HD Bluray, UHD Bluray, and WEB groups
- **Streaming Boosts:** AMZN, ATVP, NF, DSNP, HBO, HMAX, MAX, PMTP, etc.
- **Quality Definitions:** Proper size limits per quality level
- **Repack/Proper:** v1, v2, v3 handling
- **Unwanted Defaults:** BR-DISK, LQ, x265 (HD), 3D, Extras

---

## Troubleshooting

### Check for Invalid Trash IDs

```bash
# Look for warnings in recyclarr logs
grep -i "do not exist" ~/.config/recyclarr/logs/*.log

# Or for Docker
docker exec recyclarr cat /config/logs/recyclarr.log | grep -i "do not exist"
```

### Force Full Sync

```bash
recyclarr sync
```

The config has `delete_old_custom_formats: true` which removes orphaned formats automatically.

### Verify API Keys

```bash
# Test Radarr connection
curl -s "http://radarr-hd:7878/api/v3/system/status?apikey=YOUR_KEY"

# Test Sonarr connection
curl -s "http://sonarr-hd:8989/api/v3/system/status?apikey=YOUR_KEY"
```

### Common Issues

| Issue | Solution |
|-------|----------|
| "Custom Formats do not exist" | Trash ID is invalid/outdated - check TRaSH guides |
| "Profile not found" | Profile name doesn't match exactly - check Radarr/Sonarr |
| "API key invalid" | Check `.env` file and environment variables |
| Formats not applying | Run `recyclarr sync` again after profile changes |

---

## Maintenance

### Daily Sync (Recommended)

Add to crontab:
```bash
crontab -e
# Add this line:
0 3 * * * docker exec recyclarr recyclarr sync >> /var/log/recyclarr.log 2>&1
```

### Updating TRaSH Guide Templates

Templates update automatically when you run `recyclarr sync`. To force update:

```bash
# Clear cache and sync
recyclarr sync --force-update
```

---

## File Structure

```
configs/recyclarr/
├── recyclarr.yml              # Main configuration file
├── README.md                  # This documentation
├── QUICK_REFERENCE.md         # Quick command reference
└── HDR & Audio Format Preferences.md  # Scoring details
```

---

## References

- [TRaSH Guides](https://trash-guides.info/)
- [Recyclarr Documentation](https://recyclarr.dev/wiki/)
- [Radarr Custom Formats](https://trash-guides.info/Radarr/Radarr-collection-of-custom-formats/)
- [Sonarr Custom Formats](https://trash-guides.info/Sonarr/sonarr-collection-of-custom-formats/)

---

## Changelog

| Date | Change |
|------|--------|
| 2026-01-01 | Cleaned up config - removed invalid trash IDs, simplified to use templates |
| 2024-12-28 | Added custom HDR/Audio scoring overrides |
| 2024-12-26 | Initial setup with TRaSH templates |
