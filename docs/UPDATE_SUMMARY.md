# Documentation Update Summary - Final Decisions

**Date:** 2024-12-23  
**Status:** ✅ ALL DOCUMENTATION UPDATED

---

## 🎯 Final Decisions Implemented

### 1. HDR Priority Order (FINAL)

✅ **Implemented across all documentation and scripts:**

1. **HDR10** - 300 points (Standard HDR - HIGHEST)
2. **DV HDR10** - 280 points (Dolby Vision with HDR10 fallback - Second)
3. **HDR** - 250 points (Generic HDR)
4. **DV** - 150 points (Dolby Vision only, no fallback)
5. **DV HLG** - 140 points (DV with HLG fallback)
6. **DV SDR** - 130 points (DV with SDR fallback)
7. **HDR10+** - 100 points (Samsung proprietary)
8. **HLG** - 100 points (Hybrid Log-Gamma)

**Rationale:**
- HDR10 is universal standard, works everywhere
- DV HDR10 gives best of both worlds (DV + HDR10 fallback)
- Pure DV only works on DV displays
- HDR10+ is Samsung-only, limited compatibility

---

### 2. Quality Profiles (FINAL)

✅ **4 Quality Profiles configured:**

**For Radarr-HD (1080p):**
1. **HD-Bluray + WEB** - Prefers Bluray-1080p (NOT Remux), accepts WEB-DL
   - For: Most movies
   - Upgrades to: Bluray-1080p (stops before Remux)

2. **HD-Remux ONLY** - Only accepts Bluray-1080p Remux
   - For: Special movies where you want maximum quality
   - Upgrades to: Bluray-1080p Remux only

**For Radarr-4K (2160p):**
3. **UHD-Bluray + WEB** - Prefers Bluray-2160p (NOT Remux), accepts WEB-DL
   - For: Most 4K movies
   - Upgrades to: Bluray-2160p (stops before Remux)

4. **UHD-Remux ONLY** - Only accepts Bluray-2160p Remux
   - For: Special 4K movies where you want maximum quality
   - Upgrades to: Bluray-2160p Remux only

**How to use:**
- Assign most movies to Bluray + WEB profiles
- Assign your favorite/special movies to Remux ONLY profiles
- Change profile per movie in Radarr

---

### 3. Inventory Scanning Location (FINAL)

✅ **Split approach for maximum speed:**

**Ali's 4 libraries → Run on Terminus:**
- Movies, 4K Movies, TV Shows, 4K TV Shows
- LOCAL access to Unraid (super fast)
- Estimated: 4-6 hours total
- Copy results to Mother after completion

**Chris's 4 libraries → Run on Mother:**
- Movies, 4K Movies, TV Shows, 4K TV Shows  
- LOCAL access to Synology (super fast)
- Estimated: 4-6 hours total

**Why split approach:**
- ✅ Avoids slow VPN scanning
- ✅ Cuts total time from 1-2 days to 4-6 hours per person
- ✅ Both can run simultaneously
- ✅ Simple scp to copy results together

---

## 📝 Files Updated

### Scripts:
1. ✅ `scripts/compare_libraries.py`
   - Updated HDR scoring: HDR10 (300) > DV HDR10 (280) > others

### Documentation:
2. ✅ `docs/TRASHGUIDES_REFERENCE.md`
   - Updated HDR priority order with full explanations
   - Added DV HDR10, DV HLG, DV SDR variants

3. ✅ `docs/RECYCLARR_SETUP.md`
   - **COMPLETELY REWRITTEN**
   - Added 4 quality profiles (HD-Bluray, HD-Remux, UHD-Bluray, UHD-Remux)
   - Updated all HDR scoring across all profiles
   - Detailed explanations of when to use each profile

4. ✅ `docs/INVENTORY_GUIDE.md`
   - Added Option 1: Split approach (Terminus + Mother) - RECOMMENDED
   - Added Option 2: All on Mother (slower)
   - Complete instructions for both methods
   - Added time estimates for each approach

5. ✅ `QUICK_START.md`
   - Added note to run Ali's inventories on Terminus
   - Reference to INVENTORY_GUIDE.md for details

---

## 🎬 Quality Profile Details

### Recyclarr Configuration

The `docs/RECYCLARR_SETUP.md` now includes a complete `recyclarr.yml` template with:

**For each of 4 profiles:**
- Separate HDR scoring (each format scored individually)
- Audio scoring (Atmos priority)
- Release group tiers
- Unwanted formats
- Quality upgrade paths

**HDR Scoring per profile:**
```yaml
# HDR10 - Highest
- trash_ids: [dfb86d5941bc9075d6af23b09c2aeecd]
  quality_profiles:
    - name: HD-Bluray + WEB
      score: 300

# DV HDR10 - Second  
- trash_ids: [e23edd2482476e595fb990b12e7c609c]
  quality_profiles:
    - name: HD-Bluray + WEB
      score: 280

# And so on...
```

---

## ⚡ Quick Reference

### HDR Priority (All Profiles):
```
HDR10 (300) > DV HDR10 (280) > HDR (250) > DV (150) > Others (100)
```

### Audio Priority:
```
TrueHD Atmos (300-400) > DTS:X (290-400) > ATMOS (280-400) > Others
```

### Quality Profiles Usage:
```
Most Movies:
  - HD → Use "HD-Bluray + WEB"
  - 4K → Use "UHD-Bluray + WEB"

Special Movies:
  - HD → Use "HD-Remux ONLY"  
  - 4K → Use "UHD-Remux ONLY"
```

### Inventory Scanning:
```
Terminus: Ali's 4 libraries (4-6 hours)
Mother:   Chris's 4 libraries (4-6 hours)
Then:     Copy Ali → Mother
Total:    ~6-8 hours (vs 1-2 days all on Mother)
```

---

## 📚 Documentation Structure

```
mother/
├── docs/
│   ├── INVENTORY_GUIDE.md          ✅ UPDATED - Split approach added
│   ├── RECYCLARR_SETUP.md          ✅ UPDATED - 4 profiles, correct HDR
│   ├── TRASHGUIDES_REFERENCE.md    ✅ UPDATED - Correct HDR priority
│   └── ...
│
├── scripts/
│   ├── compare_libraries.py        ✅ UPDATED - Correct HDR scoring
│   └── ...
│
├── QUICK_START.md                  ✅ UPDATED - Terminus scanning note
└── ...
```

---

## ✅ Verification Checklist

Before using these configs, verify:

- [ ] HDR10 is scored highest (300 points)
- [ ] DV HDR10 is second (280 points)
- [ ] 4 quality profiles exist in Recyclarr config
- [ ] Each profile has upgrade path set correctly
- [ ] HD-Bluray stops at Bluray-1080p (NOT Remux)
- [ ] UHD-Bluray stops at Bluray-2160p (NOT Remux)
- [ ] Remux ONLY profiles only accept Remux
- [ ] Inventory guide shows Terminus option first

---

## 🚀 Next Steps

1. **Deploy Mother** following QUICK_START.md
2. **Run Recyclarr sync** after configuring Radarr/Sonarr
3. **Verify 4 profiles** appear in each Radarr instance
4. **Start inventories** using split approach (Terminus + Mother)
5. **Compare libraries** after inventories complete

---

**All documentation is now consistent and reflects your final decisions! 🎉**
