# 🔧 RECYCLARR DIRECTORY FIX

## ❌ **What Was Wrong:**

I created the recyclarr config files in the **WRONG** directory:
- **Created in:** `~/projects/mother/config/recyclarr/`
- **Should be:** `~/projects/mother/configs/recyclarr/`

## 🔍 **Why This Matters:**

Your `docker-compose.yml` uses:
```yaml
recyclarr:
  volumes:
    - ${CONFIG_PATH}/recyclarr:/config
```

And your `.env` has:
```bash
CONFIG_PATH=/opt/mother/configs  # ← Note the 's'!
```

So Docker expects the config at `/opt/mother/configs/recyclarr`, not `/opt/mother/config/recyclarr`!

---

## ✅ **What I Fixed:**

### 1. **Updated `.gitignore`**
Added exception to allow `configs/recyclarr/` to be tracked:
```gitignore
configs/                    # Still ignore other configs
!configs/recyclarr/         # EXCEPT recyclarr
!configs/recyclarr/**       # And all its contents
```

### 2. **Created Directory Structure**
```
~/projects/mother/
├── configs/              ← Created (was gitignored)
│   └── recyclarr/        ← Created
│       └── (files will go here)
└── config/               ← Wrong location (to be removed)
    └── recyclarr/
        └── (files currently here)
```

### 3. **Created Fix Script**
`fix_recyclarr_location.sh` - will move files to correct location

---

## 🚀 **What You Need To Do:**

### **Step 1: Run the fix script**
```bash
cd ~/projects/mother
chmod +x fix_recyclarr_location.sh
./fix_recyclarr_location.sh
```

This will:
- Copy all files from `config/recyclarr/` to `configs/recyclarr/`
- Show you what was copied
- Ask if you want to remove the old `config/` directory

### **Step 2: Commit the changes**
```bash
git add .gitignore configs/recyclarr/
git commit -m "Fix recyclarr config location - moved to configs/ directory

- Updated .gitignore to allow configs/recyclarr/
- Moved all recyclarr files to correct configs/ directory
- Matches CONFIG_PATH in .env and docker-compose volumes"
git push origin main
```

### **Step 3: Deploy to Mother**
```bash
ssh mother
cd /opt/mother
git pull origin main
```

Now the recyclarr config will be at `/opt/mother/configs/recyclarr/` where Docker expects it!

---

## 📁 **Final Structure:**

```
/opt/mother/
├── configs/                    # Main configs directory (Docker uses this)
│   ├── radarr-hd/             # Existing (gitignored)
│   ├── radarr-4k/             # Existing (gitignored)
│   ├── sonarr-hd/             # Existing (gitignored)
│   ├── sonarr-4k/             # Existing (gitignored)
│   ├── prowlarr/              # Existing (gitignored)
│   ├── qbittorrent/           # Existing (gitignored)
│   ├── recyclarr/             # ✅ NEW! (tracked in git)
│   │   ├── recyclarr.yml
│   │   ├── .env.example
│   │   ├── README.md
│   │   ├── SETUP_GUIDE.md
│   │   ├── QUICK_REFERENCE.md
│   │   ├── TEMPLATE_BENEFITS.md
│   │   └── MISSING_FORMATS_ANALYSIS.md
│   └── nginx/                 # Existing (gitignored)
├── docker-compose.yml
├── .env
└── ... other files
```

---

## ✅ **Verification:**

After running the script, you should see:

```bash
$ ls -lh configs/recyclarr/
total 48K
-rw-rw-r-- 1 alig mother  157 Dec 26 22:00 .env.example
-rw-rw-r-- 1 alig mother 6.2K Dec 26 22:00 MISSING_FORMATS_ANALYSIS.md
-rw-rw-r-- 1 alig mother 4.8K Dec 26 22:00 QUICK_REFERENCE.md
-rw-rw-r-- 1 alig mother 5.1K Dec 26 22:00 README.md
-rw-rw-r-- 1 alig mother  11K Dec 26 22:00 recyclarr.yml
-rw-rw-r-- 1 alig mother 7.3K Dec 26 22:00 SETUP_GUIDE.md
-rw-rw-r-- 1 alig mother 8.9K Dec 26 22:00 TEMPLATE_BENEFITS.md
```

---

## 🎯 **Why .gitignore Exception:**

**Other configs (`radarr-hd/`, `sonarr-hd/`, etc.):**
- ✅ Contain API keys, credentials
- ✅ User-specific settings
- ✅ Should be gitignored

**Recyclarr config:**
- ✅ No credentials (uses env vars)
- ✅ Universal TRaSH-based config
- ✅ Should be tracked in git
- ✅ Easy to share and deploy

---

**Run the script and you're good to go!** 🚀
