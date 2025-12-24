# Quality Profiles Strategy - Multiple Profiles

**Last Updated:** 2024-12-23

---

## 🎯 Why Multiple Profiles?

You want flexibility to choose quality **per movie** rather than one-size-fits-all.

### The Profiles:

**1080p:**
- **HD-Bluray + WEB** - Standard profile, stops at Bluray-1080p (most movies)
- **HD-Remux** - Premium profile, only Remux quality (special movies)

**4K:**
- **UHD-Bluray + WEB** - Standard profile, stops at Bluray-2160p (most movies)
- **UHD-Remux** - Premium profile, only Remux quality (special movies)

---

## 📊 Profile Comparison

| Feature | Standard (Bluray) | Remux |
|---------|------------------|-------|
| **Quality** | Excellent | Perfect |
| **File Size** | 8-15 GB (1080p)<br>25-40 GB (4K) | 20-50 GB (1080p)<br>50-100 GB (4K) |
| **Use For** | 95% of your library | Special favorites |
| **Upgrade Path** | Stops at Bluray | Stops at Remux |

---

## 🎬 When to Use Each Profile

### Use Standard (HD-Bluray + WEB / UHD-Bluray + WEB)

**For most movies:**
- Regular viewing
- Movies you like but aren't obsessed with
- Movies you might delete later
- Space-conscious choices

**95% of your library should use this**

### Use Remux (HD-Remux / UHD-Remux)

**For special movies:**
- Your absolute favorites
- Movies with incredible audio/video
- Films you'll watch repeatedly
- Movies you'll never delete
- Reference-quality content

**Only 5% of your library needs this**

---

## ⚙️ How to Use in Radarr

### Adding a New Movie

1. Search for the movie
2. Click "Add Movie"
3. **Choose Quality Profile:**
   - Select "HD-Bluray + WEB" (default for most)
   - OR select "HD-Remux" (for special movies)
4. Add movie

### Changing Existing Movies

1. Go to movie details
2. Click "Edit"
3. Change "Quality Profile" dropdown
4. Save

Radarr will:
- Search for new releases matching the new profile
- Upgrade if better quality is found

### Bulk Changes

1. Go to Movies → Mass Editor
2. Select multiple movies
3. Change "Quality Profile"
4. Apply to all selected

---

## 🎨 HDR Priority (Updated!)

### Correct Priority Order:

1. **DV HDR10** (350 points) ⭐ **HIGHEST**
   - Dolby Vision with HDR10 fallback
   - Best of both worlds!
   - DV on compatible displays, HDR10 otherwise

2. **HDR10** (300 points)
   - Standard HDR, universal compatibility

3. **HDR** (250 points)
   - Generic HDR

4. **DV** (150 points)
   - Dolby Vision only (no fallback)
   - Only works on DV displays

5. **DV HLG** (140 points)
   - DV with HLG fallback

6. **DV SDR** (130 points)
   - DV with SDR fallback

7. **HDR10+** (100 points)
   - Samsung proprietary
   - Limited compatibility

8. **HLG** (100 points)
   - Hybrid Log-Gamma

---

## 🔊 Audio Priority (Same for All Profiles)

1. **TrueHD Atmos** (300-350 points) - Best!
2. **DTS:X** (290-350 points)
3. **Atmos** (280-350 points)
4. **DD+ Atmos** (270-320 points)
5. **TrueHD** (250-300 points)
6. **DTS-HD MA** (240-300 points)
7. Lower quality formats...

Higher scores in 4K profiles because audio is more critical for 4K content.

---

## 📁 Example Library Distribution

### Ali's 66 TB Movie Library

**Recommended split:**
- **63 TB** → HD-Bluray + WEB (standard)
- **3 TB** → HD-Remux (special favorites)

This gives you:
- Great quality for everything
- Perfect quality for your favorites
- Reasonable file sizes overall

### Example Remux Movies:
- The Godfather trilogy
- Lord of the Rings
- Inception
- Interstellar
- Mad Max: Fury Road
- Blade Runner 2049
- Dune
- Your personal top 50 favorites

---

## 🔄 Recyclarr Configuration

The recyclarr.yml file in `/opt/mother/config/recyclarr/` creates all 4 profiles automatically:

```yaml
radarr-hd:
  quality_profiles:
    - name: HD-Bluray + WEB      # Profile 1
    - name: HD-Remux             # Profile 2

radarr-4k:
  quality_profiles:
    - name: UHD-Bluray + WEB     # Profile 1  
    - name: UHD-Remux            # Profile 2
```

After running `recyclarr sync`, all 4 profiles will be available in Radarr!

---

## 🎯 Quality Profile Upgrade Paths

### HD-Bluray + WEB
```
HDTV-1080p → WEBRip-1080p → WEBDL-1080p → Bluray-1080p ✓ STOP
                                                ↓
                                      (Won't upgrade to Remux)
```

### HD-Remux
```
Any quality → Bluray-1080p Remux ✓ STOP
```

### UHD-Bluray + WEB
```
HDTV-2160p → WEBRip-2160p → WEBDL-2160p → Bluray-2160p ✓ STOP
                                                ↓
                                      (Won't upgrade to Remux)
```

### UHD-Remux
```
Any quality → Bluray-2160p Remux ✓ STOP
```

---

## 💡 Pro Tips

### Start Conservatively
- Use standard profiles for everything initially
- Upgrade select favorites to Remux later
- Don't go Remux-crazy (you'll fill your drives!)

### Monitor Storage
```bash
# Check disk usage regularly
df -h | grep synology

# If running low, downgrade some Remux movies back to Bluray
```

### Use Tags in Radarr
- Tag movies as "favorites" in Radarr
- Makes it easy to bulk-change to Remux profile
- Or bulk-downgrade if needed

### Custom Format Scores Override
The custom format scores (HDR, Audio) apply to BOTH profiles equally:
- DV HDR10 always gets highest priority
- Atmos always preferred
- Profiles only control the quality cutoff point

---

## 📝 Setup Checklist

- [ ] Deploy Mother
- [ ] Install Radarr-HD and Radarr-4K
- [ ] Get API keys from both instances
- [ ] Add API keys to .env file
- [ ] Copy recyclarr.yml to `/opt/mother/config/recyclarr/`
- [ ] Run `docker exec recyclarr recyclarr sync`
- [ ] Verify all 4 profiles exist in Radarr
- [ ] Set default profile to "HD-Bluray + WEB" / "UHD-Bluray + WEB"
- [ ] Enjoy flexible quality management!

---

## 🔍 Verifying Profiles

After running `recyclarr sync`:

1. **Open Radarr-HD** → Settings → Profiles
   - Should see "HD-Bluray + WEB" and "HD-Remux"

2. **Open Radarr-4K** → Settings → Profiles
   - Should see "UHD-Bluray + WEB" and "UHD-Remux"

3. **Check Custom Formats** → Settings → Custom Formats
   - Should see all HDR, Audio, Release Group formats

4. **Check Quality Definitions** → Settings → Quality
   - Should see updated quality definitions

---

## Summary

**You now have:**
- ✅ 4 quality profiles (2 per Radarr instance)
- ✅ Correct HDR priority (DV HDR10 fallback highest!)
- ✅ Flexibility to choose per-movie quality
- ✅ Space-efficient defaults
- ✅ Perfect quality for favorites

**This is the best of both worlds!** 🎬
