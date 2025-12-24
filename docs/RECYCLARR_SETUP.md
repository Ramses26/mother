# Recyclarr Setup - TRASHGuides Automation

**Last Updated:** 2024-12-23

---

## What is Recyclarr?

Recyclarr is an automation tool that syncs TRASHGuides quality profiles, custom formats, and quality definitions to your Radarr and Sonarr instances. It eliminates manual configuration and ensures consistent quality standards.

---

## Quality Profile Strategy

You'll have **4 quality profiles** in Radarr to handle different use cases:

### For 1080p Content (Radarr-HD):
1. **HD-Bluray + WEB** - Prefers Bluray-1080p (NOT Remux), accepts WEB-DL
   - Use for: Most movies
   - Upgrades to: Bluray-1080p (stops before Remux)

2. **HD-Remux ONLY** - Only accepts Remux quality
   - Use for: Special movies where you want max quality
   - Upgrades to: Bluray-1080p Remux

### For 4K Content (Radarr-4K):
3. **UHD-Bluray + WEB** - Prefers Bluray-2160p (NOT Remux), accepts WEB-DL
   - Use for: Most 4K movies
   - Upgrades to: Bluray-2160p (stops before Remux)

4. **UHD-Remux ONLY** - Only accepts Remux quality
   - Use for: Special 4K movies where you want max quality
   - Upgrades to: Bluray-2160p Remux

---

## Installation

Recyclarr is already included in the docker-compose.yml file.

### Verify Container

```bash
cd /opt/mother
docker compose ps | grep recyclarr
```

---

## Configuration

### Create recyclarr.yml

```bash
cd /opt/mother/config/recyclarr
nano recyclarr.yml
```

### Full Configuration Template

```yaml
# Recyclarr Configuration for Project Mother
# Based on TRASHGuides recommendations
# HDR Priority: HDR10 > DV HDR10 > HDR > DV > HDR10+ > HLG

# Radarr Instances
radarr:
  radarr-hd:
    base_url: http://radarr-hd:7878
    api_key: !env RADARR_HD_API_KEY
    
    quality_profiles:
      # Profile 1: HD-Bluray + WEB (Most Movies)
      - name: HD-Bluray + WEB
        reset_unmatched_scores:
          enabled: true
        upgrade:
          allowed: true
          until_quality: Bluray-1080p  # STOPS at Bluray, NOT Remux
          until_score: 10000
        min_format_score: 0
        quality_sort: top
        qualities:
          - name: Bluray-1080p
          - name: WEBDL-1080p
            qualities:
              - WEBDL-1080p
              - WEBRip-1080p
          - name: HDTV-1080p
      
      # Profile 2: HD-Remux ONLY (Special Movies)
      - name: HD-Remux ONLY
        reset_unmatched_scores:
          enabled: true
        upgrade:
          allowed: true
          until_quality: Bluray-1080p Remux
          until_score: 10000
        min_format_score: 0
        quality_sort: top
        qualities:
          - name: Bluray-1080p Remux
    
    custom_formats:
      # Movie Versions
      - trash_ids:
          - 0f12c086e289cf966fa5948eac571f44  # Hybrid
          - 570bc9ebecd92723d2d21500f4be314c  # Remaster
          - eca37840c13c6ef2dd0262b141a5482f  # 4K Remaster
          - e0c07d59beb37348e975a930d5e50319  # Criterion Collection
          - 9d27d9d2181838f76dee150882bdc58  # Masters of Cinema
          - db9b4c4b53d312a876a3dc8c28be97ee6  # Vinegar Syndrome
        quality_profiles:
          - name: HD-Bluray + WEB
          - name: HD-Remux ONLY

      # HDR Formats (Priority: HDR10 > DV HDR10 > HDR > DV > others)
      - trash_ids:
          - dfb86d5941bc9075d6af23b09c2aeecd  # HDR10
        quality_profiles:
          - name: HD-Bluray + WEB
            score: 300  # HIGHEST
          - name: HD-Remux ONLY
            score: 300
      
      - trash_ids:
          - e23edd2482476e595fb990b12e7c609c  # DV HDR10 (DV with HDR10 fallback)
        quality_profiles:
          - name: HD-Bluray + WEB
            score: 280  # Second priority
          - name: HD-Remux ONLY
            score: 280
      
      - trash_ids:
          - e61e28db95d22bedcadf030b8f156d96  # HDR
          - 2a4d9069cc1fe3242ff98b9b6b2a7d95  # HDR (undefined)
        quality_profiles:
          - name: HD-Bluray + WEB
            score: 250
          - name: HD-Remux ONLY
            score: 250
      
      - trash_ids:
          - 58d6a88f13e2db7f5059c41047876f00  # DV (no fallback)
        quality_profiles:
          - name: HD-Bluray + WEB
            score: 150
          - name: HD-Remux ONLY
            score: 150
      
      - trash_ids:
          - 55d53828b9d81cbe20cbe416988b0f26b  # DV HLG
        quality_profiles:
          - name: HD-Bluray + WEB
            score: 140
          - name: HD-Remux ONLY
            score: 140
      
      - trash_ids:
          - a3e19f8f627608af0aa89b7ac4c61dc  # DV SDR
        quality_profiles:
          - name: HD-Bluray + WEB
            score: 130
          - name: HD-Remux ONLY
            score: 130
      
      - trash_ids:
          - c465d6fc6bb816b6b39bef8c7a1add3c7  # HDR10+ (Samsung)
        quality_profiles:
          - name: HD-Bluray + WEB
            score: 100
          - name: HD-Remux ONLY
            score: 100
      
      - trash_ids:
          - b974a6cd08c1066250f1f177d7aa1225  # HLG
        quality_profiles:
          - name: HD-Bluray + WEB
            score: 100
          - name: HD-Remux ONLY
            score: 100

      # Unwanted
      - trash_ids:
          - ed38b889b31be83fda192888e2286d83  # BR-DISK
          - 90a6f9a284dff5103f6346090e6280c8  # LQ
          - dc98083864ea246d05a42df0d05f81cc  # x265 (HD)
          - b8cd450cbfa689c0259a01d9e29ba3d6  # 3D
        quality_profiles:
          - name: HD-Bluray + WEB
            score: -10000
          - name: HD-Remux ONLY
            score: -10000

      # Audio (Atmos priority)
      - trash_ids:
          - 496f355514737f7d83bf7aa4d24f8169  # TrueHD Atmos
          - 2f22d89048b01681dde8afe203bf2e95  # DTS:X
          - 417804f7f2c4308c1f4c5d380d4c4475  # ATMOS (undefined)
        quality_profiles:
          - name: HD-Bluray + WEB
            score: 300
          - name: HD-Remux ONLY
            score: 300
      
      - trash_ids:
          - 1af239278386be2919e1bcee0bde047e  # DD+ Atmos
        quality_profiles:
          - name: HD-Bluray + WEB
            score: 270
          - name: HD-Remux ONLY
            score: 270
      
      - trash_ids:
          - 3cafb66171b47f226146a0770576870f  # TrueHD
          - dcf3ec6938fa32445f590a4da84256cd  # DTS-HD MA
        quality_profiles:
          - name: HD-Bluray + WEB
            score: 250
          - name: HD-Remux ONLY
            score: 250

      # Release Groups
      - trash_ids:
          - c20f169ef63c5f40c2def54abaf4438e  # WEB Tier 01
          - 403816d65392c79236dcb6dd591be69c  # WEB Tier 02
          - af94e0fe497124d1f9ce732069ec8c3b  # WEB Tier 03
        quality_profiles:
          - name: HD-Bluray + WEB

  radarr-4k:
    base_url: http://radarr-4k:7878
    api_key: !env RADARR_4K_API_KEY
    
    quality_profiles:
      # Profile 3: UHD-Bluray + WEB (Most 4K Movies)
      - name: UHD-Bluray + WEB
        reset_unmatched_scores:
          enabled: true
        upgrade:
          allowed: true
          until_quality: Bluray-2160p  # STOPS at Bluray, NOT Remux
          until_score: 10000
        min_format_score: 0
        quality_sort: top
        qualities:
          - name: Bluray-2160p
          - name: WEBDL-2160p
            qualities:
              - WEBDL-2160p
              - WEBRip-2160p
          - name: HDTV-2160p
      
      # Profile 4: UHD-Remux ONLY (Special 4K Movies)
      - name: UHD-Remux ONLY
        reset_unmatched_scores:
          enabled: true
        upgrade:
          allowed: true
          until_quality: Bluray-2160p Remux
          until_score: 10000
        min_format_score: 0
        quality_sort: top
        qualities:
          - name: Bluray-2160p Remux
    
    custom_formats:
      # Same as HD but with higher scores for 4K HDR importance
      
      # HDR Formats (Even MORE important in 4K!)
      - trash_ids:
          - dfb86d5941bc9075d6af23b09c2aeecd  # HDR10
        quality_profiles:
          - name: UHD-Bluray + WEB
            score: 400  # Higher for 4K
          - name: UHD-Remux ONLY
            score: 400
      
      - trash_ids:
          - e23edd2482476e595fb990b12e7c609c  # DV HDR10
        quality_profiles:
          - name: UHD-Bluray + WEB
            score: 350
          - name: UHD-Remux ONLY
            score: 350
      
      - trash_ids:
          - e61e28db95d22bedcadf030b8f156d96  # HDR
          - 2a4d9069cc1fe3242ff98b9b6b2a7d95  # HDR (undefined)
        quality_profiles:
          - name: UHD-Bluray + WEB
            score: 300
          - name: UHD-Remux ONLY
            score: 300
      
      - trash_ids:
          - 58d6a88f13e2db7f5059c41047876f00  # DV
        quality_profiles:
          - name: UHD-Bluray + WEB
            score: 200
          - name: UHD-Remux ONLY
            score: 200
      
      - trash_ids:
          - c465d6fc6bb816b6b39bef8c7a1add3c7  # HDR10+
        quality_profiles:
          - name: UHD-Bluray + WEB
            score: 150
          - name: UHD-Remux ONLY
            score: 150

      # Audio (Atmos even more important in 4K)
      - trash_ids:
          - 496f355514737f7d83bf7aa4d24f8169  # TrueHD Atmos
          - 2f22d89048b01681dde8afe203bf2e95  # DTS:X
        quality_profiles:
          - name: UHD-Bluray + WEB
            score: 400
          - name: UHD-Remux ONLY
            score: 400

      # Unwanted
      - trash_ids:
          - ed38b889b31be83fda192888e2286d83  # BR-DISK
          - 90a6f9a284dff5103f6346090e6280c8  # LQ
          - b8cd450cbfa689c0259a01d9e29ba3d6  # 3D
        quality_profiles:
          - name: UHD-Bluray + WEB
            score: -10000
          - name: UHD-Remux ONLY
            score: -10000

# Sonarr Instances
sonarr:
  sonarr-hd:
    base_url: http://sonarr-hd:8989
    api_key: !env SONARR_HD_API_KEY
    
    quality_profiles:
      - name: WEB-1080p
        reset_unmatched_scores:
          enabled: true
        upgrade:
          allowed: true
          until_quality: Bluray-1080p
          until_score: 10000
        min_format_score: 0
        quality_sort: top
        qualities:
          - name: Bluray-1080p
          - name: WEBDL-1080p
            qualities:
              - WEBDL-1080p
              - WEBRip-1080p
          - name: HDTV-1080p
    
    custom_formats:
      # Repacks
      - trash_ids:
          - ec8fa7296b64e8cd390a1600981f3923  # Repack/Proper
          - eb3d5cc0a2be0db205fb823640db6a3c  # Repack v2
          - 44e7c4de10ae50265753082e5dc76047  # Repack v3
        quality_profiles:
          - name: WEB-1080p

      # Streaming Services (Release group quality tiers)
      - trash_ids:
          - d6819cba26b1a6508138d25fb5e32293  # AMZN
          - 1656adc6d7bb2c8cca6acfb6592db421  # ATVP
          - 89358767a60cc28783cdc3d0be9388a4  # DSNP
          - 7a235133c87f7da4c8cccceca7e3c7a6  # HBO
          - a880d6abc21e7c16884f3ae393f84179  # HMAX
          - 81d1fbf600e2540cee87f3a23f9d3c1c  # MAX
          - d34870697c9db575f17700212167be23  # NF
        quality_profiles:
          - name: WEB-1080p

  sonarr-4k:
    base_url: http://sonarr-4k:8989
    api_key: !env SONARR_4K_API_KEY
    
    quality_profiles:
      - name: WEB-2160p
        reset_unmatched_scores:
          enabled: true
        upgrade:
          allowed: true
          until_quality: Bluray-2160p
          until_score: 10000
        min_format_score: 0
        quality_sort: top
        qualities:
          - name: Bluray-2160p
          - name: WEBDL-2160p
            qualities:
              - WEBDL-2160p
              - WEBRip-2160p
          - name: HDTV-2160p
    
    custom_formats:
      # HDR for TV (same priority as movies)
      - trash_ids:
          - dfb86d5941bc9075d6af23b09c2aeecd  # HDR10
        quality_profiles:
          - name: WEB-2160p
            score: 400
      
      - trash_ids:
          - e23edd2482476e595fb990b12e7c609c  # DV HDR10
        quality_profiles:
          - name: WEB-2160p
            score: 350

      # Streaming Services
      - trash_ids:
          - d6819cba26b1a6508138d25fb5e32293  # AMZN
          - 1656adc6d7bb2c8cca6acfb6592db421  # ATVP
          - 89358767a60cc28783cdc3d0be9388a4  # DSNP
          - 7a235133c87f7da4c8cccceca7e3c7a6  # HBO
          - d34870697c9db575f17700212167be23  # NF
        quality_profiles:
          - name: WEB-2160p
```

### Using Environment Variables for API Keys

Update your `.env` file with API keys after Radarr/Sonarr are set up:

```bash
# Get API keys from:
# Radarr-HD: Settings → General → API Key
# Radarr-4K: Settings → General → API Key
# Sonarr-HD: Settings → General → API Key
# Sonarr-4K: Settings → General → API Key
```

---

## Running Recyclarr

### Manual Sync

```bash
# Sync all instances
docker exec recyclarr recyclarr sync

# Sync specific instance
docker exec recyclarr recyclarr sync radarr-hd
docker exec recyclarr recyclarr sync radarr-4k
docker exec recyclarr recyclarr sync sonarr-hd
docker exec recyclarr recyclarr sync sonarr-4k

# Preview changes (dry run)
docker exec recyclarr recyclarr sync --preview
```

### Automated Sync

Create a cron job to run Recyclarr daily:

```bash
# Edit crontab
crontab -e

# Add this line (runs at 3 AM daily)
0 3 * * * docker exec recyclarr recyclarr sync >> /opt/mother/logs/recyclarr.log 2>&1
```

---

## Using the Quality Profiles

### In Radarr-HD:

**For most movies** - Use "HD-Bluray + WEB":
- Accepts: Bluray-1080p, WEB-DL, WEBRip
- Upgrades to: Bluray-1080p (stops before Remux)
- Saves space vs Remux

**For special movies** - Use "HD-Remux ONLY":
- Only accepts: Bluray-1080p Remux
- Maximum quality, larger file sizes
- For your favorite movies

### In Radarr-4K:

**For most 4K movies** - Use "UHD-Bluray + WEB":
- Accepts: Bluray-2160p, WEB-DL 2160p
- Upgrades to: Bluray-2160p (stops before Remux)

**For special 4K movies** - Use "UHD-Remux ONLY":
- Only accepts: Bluray-2160p Remux
- Maximum quality for 4K

### How to Assign Profiles:

In Radarr, when adding/editing a movie:
1. Go to the movie page
2. Click "Edit"
3. Change "Quality Profile" dropdown
4. Choose the appropriate profile

---

## Verification

### Check Radarr/Sonarr

After running Recyclarr sync:

1. Go to Radarr → Settings → Profiles
2. Verify you see 4 profiles in Radarr-HD and Radarr-4K
3. Go to Settings → Custom Formats
4. Verify custom formats are imported
5. Check Settings → Quality → verify quality definitions updated

Repeat for all Radarr/Sonarr instances.

---

## Troubleshooting

### Connection Errors

```bash
# Check if Radarr/Sonarr are accessible
docker exec recyclarr ping radarr-hd
docker exec recyclarr curl http://radarr-hd:7878

# Check API keys
docker exec recyclarr cat /config/recyclarr.yml | grep api_key
```

### Profile Not Updating

```bash
# Use preview mode to see what would change
docker exec recyclarr recyclarr sync --preview radarr-hd

# Check Recyclarr logs
docker logs recyclarr
```

---

## Summary of Your Configuration

**HDR Priority (All Profiles):**
1. HDR10 - 300-400 points (HIGHEST)
2. DV HDR10 - 280-350 points (DV with HDR10 fallback)
3. HDR - 250-300 points (Generic)
4. DV - 150-200 points (DV only, no fallback)
5. HDR10+ - 100-150 points (Samsung)
6. HLG - 100 points

**Audio Priority:**
1. TrueHD Atmos / DTS:X - 300-400 points
2. ATMOS - 280-400 points
3. DD+ Atmos - 270 points
4. TrueHD / DTS-HD MA - 250 points

**Quality Profiles:**
- HD-Bluray + WEB (most HD movies)
- HD-Remux ONLY (special HD movies)
- UHD-Bluray + WEB (most 4K movies)
- UHD-Remux ONLY (special 4K movies)

---

## References

- [Recyclarr Documentation](https://recyclarr.dev/)
- [TRASHGuides](https://trash-guides.info/)
- [Project Mother TRASHGuides Reference](TRASHGUIDES_REFERENCE.md)
