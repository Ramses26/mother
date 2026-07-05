# RECYCLARR CONFIG - WHAT WE'RE MISSING! 🚨

## Current Status: INCOMPLETE ❌

After deep research into TRaSH guides, we're missing **CRITICAL** custom formats!

---

## 📊 RADARR - WHAT WE HAVE VS WHAT WE NEED

### ✅ **CURRENTLY INCLUDED:**
- HDR Formats (HDR10, DV HDR10, HDR, DV, HDR10+, HLG, DV HLG, DV SDR)
- Audio Formats (All Atmos, DTS:X, TrueHD, DTS-HD MA, FLAC, PCM, etc.)
- Movie Versions (Remaster, 4K Remaster, Criterion, Masters of Cinema, Vinegar Syndrome, Hybrid)
- Unwanted (BR-DISK, LQ, x265 HD, 3D)
- WEB Release Groups (Tier 01, 02, 03)

### ❌ **MISSING (CRITICAL!):**

#### **1. LQ (Release Title)** - Score: -10000
**trash_id:** `e2315f990da2e2cbfc9fa5b7a6fcfe48`
**Why:** Catches low-quality terms in titles that group names miss
**Examples:** "HC", "KORSUB", "R5", "screener"

#### **2. Upscaled** - Score: -10000
**trash_id:** `43bb5f09c79641e7a22e48d440bd8868`
**Why:** Prevents fake 4K (upscaled from 1080p)

#### **3. x265 (no HDR/DV)** - Score: -10000
**trash_id:** `47435ece6b99a0b477caf360e79ba0bb`
**Why:** Blocks x265 encodes WITHOUT HDR (use x265 HD instead, OR both with one scored 0)
**Note:** We have "x265 (HD)" - this is MORE restrictive. Consider this alternative.

#### **4. Bad Dual Groups** - Score: -10000 [OPTIONAL but RECOMMENDED]
**trash_id:** `b6832f586342ef70d9c128d40c07b872`
**Why:** Groups that add foreign audio tracks incorrectly

#### **5. No-RlsGroup** - Score: -10000 [OPTIONAL but RECOMMENDED]
**trash_id:** `ae9b7c9ebde1f3bd336a8cbd1ec4c5e5`
**Why:** Some indexers strip release groups → LQ groups score incorrectly
**Example:** EVO releases appear as upgrades without this

#### **6. Obfuscated** - Score: -10000 [OPTIONAL but RECOMMENDED]
**trash_id:** `7357cf5161efbf8c4d5d0c30b4815ee2`
**Why:** Renamed/obfuscated releases

#### **7. Retags** - Score: -10000 [OPTIONAL but RECOMMENDED]
**trash_id:** `5c44f52a8714fdd79bb4d98e2673be1f`
**Why:** Retagged releases by LQ groups

#### **8. Scene** - Score: -10000 [OPTIONAL but RECOMMENDED]
**trash_id:** `f537cf427b64c38c8e36298f657e4828`
**Why:** Scene releases (lower quality)

#### **9. HD Bluray Tier Release Groups** - Score: Variable
**Why:** We only have WEB tiers! Missing Bluray quality tiers!
- **HD Bluray Tier 01** - `ed27ebfef2f323e964fb1f61391bcb35` - Score: ~1700
- **HD Bluray Tier 02** - `c20c8647f2746a1f4c4262b0fbbeeeae` - Score: ~1650
- **HD Bluray Tier 03** - `5608c71bcebba0a5e666223bae8c9227` - Score: ~1600

#### **10. UHD Bluray Tier Release Groups** - Score: Variable
- **UHD Bluray Tier 01** - `4d74ac4c4db0b64bff6ce0cffb1903be` - Score: ~1800
- **UHD Bluray Tier 02** - `a58f517a70193f8e578056642178419d` - Score: ~1750
- **UHD Bluray Tier 03** - `e71939fae1e88e1b1e14f436e69491c` - Score: ~1700

#### **11. Repack/Proper Formats** - Score: 5-25
**Why:** Prefer fixed releases
- **Repack/Proper** - `ec8fa7296b64e8cd390a1600981f3923` - Score: 5
- **Repack v2** - `eb3d5cc0a2be0db205fb823640db6a3c` - Score: 6
- **Repack v3** - `44e7c4de10ae50265753082e5dc76047` - Score: 7

#### **12. Streaming Services** - Score: Variable (FOR NAMING!)
**Purpose:** Add service name to filename
- **HMAX** - `a880d6abc21e7c16884f3ae393f84179` - Score: 0
- **DSNP** - `81d1fbf600e2540cee87f3a23f9d3c1c` - Score: 0
- **NF** - `d34870697c9db575f17700212167be23` - Score: 0
- **AMZN** - `b3b3a6ac74ecbd56bcdbefa4799fb9df` - Score: 0
- **ATVP** - `40e9380490e748672c2522eaaeb692f7` - Score: 0
- **PMTP** - `cc5e51a9e85a6296ceefe097a77f12f4` - Score: 0
- **MA** - `f6ff65b3f4b464a79dcc75950fe20382` - Score: 0

**Note:** TRaSH recommends scoring these. Some services have better quality:
- **BCore** (BluTV in TR) - Higher bitrate
- **CRiT** (Criterion) - High quality
- **MA** (Movies Anywhere) - Higher bitrate

#### **13. Extras** - Score: -10000
**trash_id:** `fb3ccc5d5cc8f77c9055d4cb4561dded`
**Why:** Exclude bonus content, deleted scenes

#### **14. IMAX Enhanced** - Score: Variable [OPTIONAL]
**trash_id:** `9f6cbff8cfe4ebbc1bde14c7b7bec0de`
**Why:** 1.90:1 aspect ratio (26% more picture)
**Score:** 0 or positive if you want it

#### **15. SDR** - Score: 0 [FOR NAMING ONLY]
**trash_id:** `2016d1676f5ee13a5b7257ff86ac9a93`
**Why:** Tag SDR releases in filename

---

## 📊 SONARR - WHAT WE HAVE VS WHAT WE NEED

### ✅ **CURRENTLY INCLUDED:**
- Repack/Proper (v1, v2, v3)
- Streaming Services (AMZN, ATVP, DSNP, HBO, HMAX, MAX, NF)
- HDR (HDR10, DV HDR10)
- Bad Dual Groups
- No-RlsGroup
- Obfuscated
- Retags
- Scene

### ❌ **MISSING (IMPORTANT!):**

#### **1. LQ (Release Title)** - Score: -10000
**trash_id:** `e2315f990da2e2cbfc9fa5b7a6fcfe48`
**Why:** Low-quality terms in titles

#### **2. BR-DISK** - Score: -10000
**trash_id:** `85c61753df5da1fb2aab6f2a47426b09`
**Why:** Block Bluray disc structure

#### **3. LQ** - Score: -10000
**trash_id:** `9c11cd3f07101cdba90a2d81cf0e56b4`
**Why:** Low quality groups

#### **4. x265 (HD)** - Score: -10000
**trash_id:** `47435ece6b99a0b477caf360e79ba0bb`
**Why:** Block x265 for 1080p TV

#### **5. Extras** - Score: -10000
**trash_id:** `fbcb31d8dabd2a319072b84fc0b7249c`
**Why:** Exclude bonus content

#### **6. Upscaled** - Score: -10000
**trash_id:** `32b367365729d530ca1c124a0b180c64`
**Why:** Prevent upscaled releases

#### **7. WEB Tier Release Groups** - Score: Variable
**Missing from TV!** Only have streaming services, no release group tiers!
- **WEB Tier 01** - Score: ~1700
- **WEB Tier 02** - Score: ~1650
- **WEB Tier 03** - Score: ~1600

#### **8. HD Bluray Tier Groups (for Bluray/Remux profiles)** - Score: Variable
- **HD Bluray Tier 01**
- **HD Bluray Tier 02**
- **HD Bluray Tier 03**

#### **9. More Audio Formats**
Currently missing most audio formats! Should add at minimum:
- TrueHD Atmos
- DTS:X
- DD+ Atmos
- TrueHD
- DTS-HD MA
- DD+

---

## 🎯 RECOMMENDATION

We need to **COMPLETELY REWRITE** the recyclarr config to use the **TRaSH TEMPLATES** as the base, then ADD our customizations on top!

### **Better Approach:**

```yaml
radarr:
  radarr-hd:
    include:
      - template: radarr-quality-definition-movie
      - template: radarr-quality-profile-hd-bluray-web  # This includes EVERYTHING
      - template: radarr-custom-formats-hd-bluray-web   # This too!
    
    # THEN override/add our customizations
    custom_formats:
      # Enable the OPTIONAL ones
      - trash_ids:
          - b6832f586342ef70d9c128d40c07b872  # Bad Dual Groups
          - ae9b7c9ebde1f3bd336a8cbd1ec4c5e5  # No-RlsGroup
          - 7357cf5161efbf8c4d5d0c30b4815ee2  # Obfuscated
          - 5c44f52a8714fdd79bb4d98e2673be1f  # Retags
          - f537cf427b64c38c8e36298f657e4828  # Scene
        quality_profiles:
          - name: HD-Bluray + WEB
            score: -10000
      
      # Add movie versions
      - trash_ids:
          - 570bc9ebecd92723d2d21500f4be314c  # Remaster
          - eca37840c13c6ef2dd0262b141a5482f  # 4K Remaster
        quality_profiles:
          - name: HD-Bluray + WEB
```

This way:
1. ✅ We get ALL the TRaSH defaults
2. ✅ We can customize scores
3. ✅ Nothing is missed
4. ✅ Auto-updates with TRaSH changes

---

## 🚨 ACTION REQUIRED

**Do you want me to:**
1. **Use the TRaSH templates** as base (RECOMMENDED)
2. **Manually add all missing formats** to our current config

**Option 1 is MUCH better** because:
- Includes EVERYTHING from TRaSH
- Auto-updates when TRaSH updates
- Less maintenance
- Guaranteed complete

**Option 2 means:**
- We manually list every single format
- Have to update manually
- Risk missing future additions
- More verbose config

---

## 📝 SUMMARY OF WHAT'S MISSING

**RADARR:**
- ❌ 8 CRITICAL unwanted formats
- ❌ HD/UHD Bluray Tier release groups (6 formats!)
- ❌ Repack/Proper formats (3 formats)
- ❌ 8+ Streaming service tags
- ❌ Extras blocker
- ❌ Optional quality formats (IMAX, SDR tagging)

**SONARR:**
- ❌ 6 unwanted formats
- ❌ WEB Tier release groups
- ❌ HD Bluray Tiers (for Bluray profiles)
- ❌ Most audio formats

**TOTAL MISSING: 40+ custom formats!**

---

**Which approach do you want?** 🤔
