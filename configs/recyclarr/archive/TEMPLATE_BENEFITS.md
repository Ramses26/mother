# 🎯 WHAT TRASH TEMPLATES GIVE US AUTOMATICALLY

This document shows EXACTLY what the TRaSH templates include automatically - so you can see why this approach is better!

---

## 📦 **radarr-custom-formats-hd-bluray-web Template**

When you include this template, you AUTOMATICALLY get:

### **HDR Formats (8):**
- ✅ HDR10
- ✅ HDR (generic)
- ✅ HDR (undefined)
- ✅ DV (Dolby Vision)
- ✅ DV HDR10
- ✅ DV HLG
- ✅ DV SDR
- ✅ HDR10+
- ✅ HLG

### **Audio Formats (14):**
- ✅ TrueHD Atmos
- ✅ DTS:X
- ✅ ATMOS (undefined)
- ✅ DD+ ATMOS
- ✅ TrueHD
- ✅ DTS-HD MA
- ✅ FLAC
- ✅ PCM
- ✅ DTS-HD HRA
- ✅ DD+
- ✅ DTS-ES
- ✅ DTS
- ✅ AAC
- ✅ DD (AC3)

### **Unwanted Formats (7):**
- ✅ BR-DISK
- ✅ LQ (Low Quality groups)
- ✅ LQ (Release Title) - terms like "HC", "KORSUB", "R5"
- ✅ x265 (HD) - blocks x265 for 1080p
- ✅ 3D
- ✅ Extras (bonus content)
- ✅ Upscaled

### **Release Groups (9):**
- ✅ HD Bluray Tier 01 (best Bluray groups)
- ✅ HD Bluray Tier 02
- ✅ HD Bluray Tier 03
- ✅ WEB Tier 01 (best WEB groups)
- ✅ WEB Tier 02
- ✅ WEB Tier 03
- ✅ Remux Tier 01 (for Remux profiles)
- ✅ Remux Tier 02
- ✅ Remux Tier 03

### **Streaming Services (15+):**
- ✅ HMAX (HBO Max)
- ✅ DSNP (Disney+)
- ✅ NF (Netflix)
- ✅ AMZN (Amazon)
- ✅ ATVP (Apple TV+)
- ✅ PMTP (Paramount+)
- ✅ MA (Movies Anywhere)
- ✅ PCOK (Peacock)
- ✅ SHO (Showtime)
- ✅ HBO
- ✅ MAX
- ✅ iT (iTunes)
- ✅ STAN (Stan)
- ✅ RED
- ✅ CC (Criterion Channel)
- And more!

### **Quality Enhancements (3):**
- ✅ Repack/Proper
- ✅ Repack v2
- ✅ Repack v3

### **Video Codecs (For tagging):**
- ✅ AV1 (marked for avoiding or preferring)
- ✅ SDR (for tagging SDR releases)

### **Special Features:**
- ✅ IMAX Enhanced (optional - can enable)
- ✅ Generated Dynamic HDR (blocks fake HDR)

---

## 📦 **radarr-custom-formats-uhd-bluray-web Template**

Same as HD template, PLUS:

### **4K-Specific Formats:**
- ✅ UHD Bluray Tier 01 (best 4K Bluray groups)
- ✅ UHD Bluray Tier 02
- ✅ UHD Bluray Tier 03
- ✅ Remux Tier 01 (4K Remux)
- ✅ Remux Tier 02
- ✅ Remux Tier 03

**Total 4K Formats:** Same 50+ as HD, optimized for 4K!

---

## 📦 **sonarr-v4-custom-formats-web-1080p Template**

### **Unwanted Formats (8):**
- ✅ BR-DISK
- ✅ LQ (Low Quality groups)
- ✅ LQ (Release Title)
- ✅ x265 (HD)
- ✅ Bad Dual Groups
- ✅ No-RlsGroup
- ✅ Obfuscated
- ✅ Retags
- ✅ Scene
- ✅ Extras

### **Release Groups (3):**
- ✅ WEB Tier 01 (best TV WEB groups)
- ✅ WEB Tier 02
- ✅ WEB Tier 03

### **Streaming Services (10+):**
- ✅ AMZN
- ✅ ATVP
- ✅ DSNP
- ✅ HBO
- ✅ HMAX
- ✅ MAX
- ✅ NF
- ✅ PCOK
- ✅ PMTP
- ✅ SHO

### **Quality (3):**
- ✅ Repack/Proper
- ✅ Repack v2
- ✅ Repack v3

### **HDR (2):**
- ✅ HDR10
- ✅ DV HDR10

---

## 📦 **sonarr-v4-custom-formats-web-2160p Template**

Same as 1080p template, optimized for 4K TV!

---

## 🎯 **What We Added On Top**

### **Optional Formats (Enabled by us):**

**For Radarr:**
- ✅ Bad Dual Groups (-10000) - TRaSH has it, we enabled it
- ✅ No-RlsGroup (-10000) - TRaSH has it, we enabled it
- ✅ Obfuscated (-10000) - TRaSH has it, we enabled it
- ✅ Retags (-10000) - TRaSH has it, we enabled it
- ✅ Scene (-10000) - TRaSH has it, we enabled it

**Movie Versions (We enabled):**
- ✅ Hybrid
- ✅ Remaster
- ✅ 4K Remaster
- ✅ Criterion Collection
- ✅ Masters of Cinema
- ✅ Vinegar Syndrome

**Custom Scoring (We overrode):**
- ✅ HDR10: 400 pts (HD), 500 pts (4K) - **Boosted!**
- ✅ DV HDR10: 350 pts (HD), 450 pts (4K)
- ✅ TrueHD Atmos / DTS:X: 400 pts (HD), 500 pts (4K)

**Additional Profiles (We created):**
- ✅ HD-Remux ONLY (Radarr)
- ✅ UHD-Remux ONLY (Radarr)
- ✅ Bluray-1080p (Sonarr)
- ✅ Remux-1080p (Sonarr)
- ✅ Bluray-2160p (Sonarr)
- ✅ Remux-2160p (Sonarr)

---

## 📊 **Total Format Count by Template**

| Template | Formats Included |
|----------|-----------------|
| radarr-custom-formats-hd-bluray-web | ~60 formats |
| radarr-custom-formats-uhd-bluray-web | ~65 formats |
| sonarr-v4-custom-formats-web-1080p | ~30 formats |
| sonarr-v4-custom-formats-web-2160p | ~32 formats |
| **TOTAL UNIQUE** | **100+ formats** |

---

## 🎯 **Why Templates Are Better**

### **OLD Manual Approach:**
```yaml
custom_formats:
  - trash_ids:
      - dfb86d5941bc9075d6af23b09c2aeecd  # HDR10
    quality_profiles:
      - name: HD-Bluray + WEB
        score: 400
  
  - trash_ids:
      - e23edd2482476e595fb990b12e7c609c  # DV HDR10
    quality_profiles:
      - name: HD-Bluray + WEB
        score: 350
  
  # ... repeat for ALL 100+ formats
  # ... 1500+ lines of config
  # ... manual maintenance
  # ... easy to miss formats
```

### **NEW Template Approach:**
```yaml
include:
  - template: radarr-custom-formats-hd-bluray-web  # Gets ALL 60+ formats!
  - template: radarr-quality-profile-hd-bluray-web

# Only customize what we want different
custom_formats:
  - trash_ids:
      - dfb86d5941bc9075d6af23b09c2aeecd  # HDR10
    quality_profiles:
      - name: HD-Bluray + WEB
        score: 400  # Override default
```

**Benefits:**
- ✅ 3 lines vs 300+ lines
- ✅ Nothing missed
- ✅ Auto-updates
- ✅ Only override what you need

---

## 🔄 **Auto-Update Flow**

1. TRaSH guides add new format
2. Template gets updated on GitHub
3. Next recyclarr sync pulls update
4. New format automatically applied
5. **You do NOTHING!** ✨

---

## ✅ **Verification Checklist**

After sync, you should see in your *arr instances:

### **Radarr-HD Custom Formats (60+):**
- [ ] 8 HDR formats
- [ ] 14 Audio formats
- [ ] 7 Unwanted formats (all -10000)
- [ ] 9 Release group tiers
- [ ] 15+ Streaming services
- [ ] 6 Movie versions
- [ ] 3 Repack formats
- [ ] 5 Optional unwanted (our additions)

### **Sonarr-HD Custom Formats (30+):**
- [ ] 10 Unwanted formats (all -10000)
- [ ] 3 WEB Tier groups
- [ ] 10+ Streaming services
- [ ] 3 Repack formats
- [ ] 2 HDR formats

---

## 🎉 **Summary**

**What templates give us:**
- 100+ custom formats automatically
- Proper scoring for everything
- Release group quality tiers
- All unwanted formats blocked
- All streaming services tagged
- Auto-updates

**What we added:**
- Enabled optional unwanted formats
- Added movie version preferences
- Boosted HDR scores for 1080p priority
- Created additional Bluray/Remux profiles

**Result:** COMPLETE coverage with minimal configuration! 🚀
