# Recyclarr Profile Quick Reference

**Last Updated:** 2024-12-26

---

## 🎬 **MOVIES (Radarr)**

### **1080p Movies (Radarr-HD - Port 7878)**

| Profile | When to Use | Max Quality | File Size |
|---------|-------------|-------------|-----------|
| **HD-Bluray + WEB** | 95% of your movies | Bluray-1080p | 6-20 GB |
| **HD-Remux ONLY** | Your top 20 favorites | Remux-1080p | 20-60 GB |

**Use HD-Bluray + WEB for:**
- Action movies, comedies, dramas
- Most newer releases
- Space-conscious collecting

**Use HD-Remux ONLY for:**
- Your absolute favorite films
- Visual masterpieces (Dune, Blade Runner 2049)
- Reference quality films

---

### **4K Movies (Radarr-4K - Port 7879)**

| Profile | When to Use | Max Quality | File Size |
|---------|-------------|-------------|-----------|
| **UHD-Bluray + WEB** | 95% of 4K movies | Bluray-2160p | 20-60 GB |
| **UHD-Remux ONLY** | Top 10 4K favorites | Remux-2160p | 50-100+ GB |

**Use UHD-Bluray + WEB for:**
- Any movie you want in 4K
- HDR content
- Good balance of quality/space

**Use UHD-Remux ONLY for:**
- Visual spectacles (Avatar, Interstellar)
- Nature documentaries
- Your ultimate favorites

---

## 📺 **TV SHOWS (Sonarr)**

### **1080p TV (Sonarr-HD - Port 8989)**

| Profile | When to Use | Max Quality | File Size/Episode |
|---------|-------------|-------------|-------------------|
| **WEB-1080p** | 99% of TV shows | WEB-DL 1080p | 2-4 GB |
| **Bluray-1080p** | Special shows | Bluray-1080p | 4-8 GB |
| **Remux-1080p** | Very special shows | Remux-1080p | 10-20 GB |

**Use WEB-1080p for:**
- All current TV shows
- Netflix/Disney+/HBO series
- Weekly releases
- Reality TV, sitcoms

**Use Bluray-1080p for:**
- Premium shows (Breaking Bad, The Wire)
- Limited series you love
- Shows you'll rewatch

**Use Remux-1080p for:**
- Nature documentaries (Planet Earth)
- Your #1 favorite show
- Visual masterpieces

---

### **4K TV (Sonarr-4K - Port 8990)**

| Profile | When to Use | Max Quality | File Size/Episode |
|---------|-------------|-------------|-------------------|
| **WEB-2160p** | Most 4K TV | WEB-DL 2160p | 8-15 GB |
| **Bluray-2160p** | Special 4K shows | Bluray-2160p | 15-30 GB |
| **Remux-2160p** | Ultimate 4K shows | Remux-2160p | 30-60 GB |

**Use WEB-2160p for:**
- Apple TV+ / Disney+ 4K shows
- Current 4K releases
- Most 4K content

**Use Bluray-2160p for:**
- Premium 4K shows
- Shows with great HDR
- Favorites in 4K

**Use Remux-2160p for:**
- Nature docs in 4K (Our Planet, Blue Planet II)
- Ultimate viewing experiences

---

## 🎯 **Quick Decision Tree**

### For Movies:
```
Is it 4K? → YES → Use UHD-Bluray + WEB
         → NO  → Use HD-Bluray + WEB

Is it one of your top favorites? → YES → Use Remux profile
                                  → NO  → Use regular profile
```

### For TV Shows:
```
Is it airing weekly/currently? → YES → Use WEB profile

Is it finished and you love it? → SOMEWHAT → Use Bluray profile
                                → ABSOLUTELY → Use Remux profile

Is it nature documentary? → YES → Consider Remux profile (visual quality!)
```

---

## 💡 **Pro Tips**

### **HDR is King (especially for 1080p!)**
- 1080p WEB-DL + HDR10 scores **HIGHER** than 1080p Bluray without HDR
- Always prefer HDR when available
- HDR adds 400 points in 1080p, 500 points in 4K!

### **Atmos Matters**
- TrueHD Atmos / DTS:X adds 400-500 points
- Dramatically improves the experience
- Worth getting even for action movies

### **File Size Estimates**

**1080p:**
- WEB-DL: 2-6 GB (movies), 2-4 GB (TV)
- Bluray: 6-20 GB (movies), 4-8 GB (TV)
- Remux: 20-60 GB (movies), 10-20 GB (TV)

**4K:**
- WEB-DL: 15-40 GB (movies), 8-15 GB (TV)
- Bluray: 40-80 GB (movies), 15-30 GB (TV)
- Remux: 60-100+ GB (movies), 30-60 GB (TV)

### **Naming Examples**

**Movies:**
```
Avatar (2009) {imdb-tt0499549} [Bluray-2160p][HDR10][TrueHD Atmos 7.1]-FGT.mkv
```

**TV Shows:**
```
Breaking Bad (2008) - S01E01 - Pilot [WEBDL-1080p][DDP5.1]-NTb.mkv
```

---

## 🔄 **Changing Profiles**

### In Radarr:
1. Go to movie
2. Click "Edit"
3. Change "Quality Profile" dropdown
4. Save

### In Sonarr:
1. Go to series
2. Click "Edit"
3. Change "Quality Profile" dropdown
4. Save

### Bulk Change:
1. Movies/Series list
2. Select multiple
3. "Edit" → "Movie/Series Editor"
4. Change profile for all
5. Save

---

## 📊 **Space Planning**

### Example Collections:

**HD Collection (500 movies):**
- Using HD-Bluray + WEB: ~5-10 TB
- Using HD-Remux: ~15-30 TB

**4K Collection (100 movies):**
- Using UHD-Bluray + WEB: ~3-6 TB
- Using UHD-Remux: ~6-10 TB

**TV Shows (50 complete series, 10 seasons avg):**
- Using WEB: ~3-5 TB
- Using Bluray: ~8-12 TB
- Using Remux: ~20-30 TB

---

## ⚡ **Quick Commands**

```bash
# Sync all profiles
docker exec recyclarr recyclarr sync

# Preview changes
docker exec recyclarr recyclarr sync --preview

# Sync one service
docker exec recyclarr recyclarr sync radarr-hd

# Check logs
docker logs recyclarr --tail 50
```

---

**Remember:** Start with the standard profiles, upgrade to Remux for your absolute favorites!

**Quality → Space → Choose wisely! 🎯**
