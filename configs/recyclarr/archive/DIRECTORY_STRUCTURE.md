# 📁 Recyclarr Directory Structure

## 🎯 **What Gets Committed to Git:**

```
configs/recyclarr/
├── .gitignore              ✅ Commit - Ignores Docker runtime files
├── recyclarr.yml           ✅ Commit - Main config with TRaSH templates
├── .env.example            ✅ Commit - API key template
├── README.md               ✅ Commit - Overview
├── SETUP_GUIDE.md          ✅ Commit - Deployment guide
├── QUICK_REFERENCE.md      ✅ Commit - Profile selection guide
├── TEMPLATE_BENEFITS.md    ✅ Commit - What templates provide
├── MISSING_FORMATS_ANALYSIS.md  ✅ Commit - What we were missing
└── DIRECTORY_STRUCTURE.md  ✅ Commit - This file
```

## 🚫 **What Gets Ignored (Docker Runtime):**

```
configs/recyclarr/
├── cache/           ❌ Ignore - Recyclarr cache
├── configs/         ❌ Ignore - Downloaded TRaSH configs
├── includes/        ❌ Ignore - TRaSH includes
├── logs/            ❌ Ignore - Runtime logs
├── repos/           ❌ Ignore - Git repos from TRaSH
└── settings.yml     ❌ Ignore - Runtime settings
```

These are created by Docker/recyclarr when it runs and should **NOT** be committed!

---

## 🐳 **How Docker Uses This:**

### **Volume Mount:**
```yaml
recyclarr:
  volumes:
    - ${CONFIG_PATH}/recyclarr:/config
```

Maps to: `/opt/mother/configs/recyclarr/` → `/config` inside container

### **When Container Runs:**
1. Reads `/config/recyclarr.yml` (our file)
2. Creates `/config/cache/` (runtime)
3. Downloads to `/config/configs/` (TRaSH data)
4. Downloads to `/config/includes/` (TRaSH includes)
5. Writes logs to `/config/logs/` (runtime)
6. Creates `/config/settings.yml` (runtime)

---

## ✅ **What This Means:**

### **On Your Dev Machine (WSL):**
```bash
~/projects/mother/configs/recyclarr/
├── recyclarr.yml        # Your config (git tracked)
├── .env.example         # Template (git tracked)
├── *.md                 # Docs (git tracked)
└── .gitignore           # Ignore rules (git tracked)
```

Clean! Only source files tracked in git.

### **On Mother Server (After First Run):**
```bash
/opt/mother/configs/recyclarr/
├── recyclarr.yml        # From git
├── .env.example         # From git
├── *.md                 # From git
├── .gitignore           # From git
├── cache/               # Created by Docker ❌ not in git
├── configs/             # Created by Docker ❌ not in git
├── includes/            # Created by Docker ❌ not in git
├── logs/                # Created by Docker ❌ not in git
└── settings.yml         # Created by Docker ❌ not in git
```

Runtime files exist but aren't tracked!

---

## 🔄 **Workflow:**

### **1. Development (WSL):**
```bash
cd ~/projects/mother/configs/recyclarr/

# Edit config
nano recyclarr.yml

# Check what will be committed
git status

# Should only show:
# - recyclarr.yml
# - *.md files
# NOT cache/, logs/, etc.

# Commit
git add .
git commit -m "Update recyclarr config"
git push
```

### **2. Deployment (Mother):**
```bash
ssh mother
cd /opt/mother
git pull

# Docker creates runtime files automatically
docker exec recyclarr recyclarr sync
```

---

## 🎯 **Benefits:**

### ✅ **Clean Git History:**
- Only config and docs tracked
- No cache/logs bloat
- No merge conflicts on runtime files

### ✅ **Portable:**
- Clone repo anywhere
- Docker creates runtime files automatically
- Works immediately

### ✅ **Secure:**
- No API keys in git (use .env)
- No cached data in git
- No logs in git

---

## 📝 **File Purposes:**

| File | Purpose | Commit? |
|------|---------|---------|
| `recyclarr.yml` | Main config with TRaSH templates | ✅ Yes |
| `.env.example` | Template for API keys | ✅ Yes |
| `*.md` | Documentation | ✅ Yes |
| `.gitignore` | Ignore Docker runtime | ✅ Yes |
| `cache/` | Recyclarr cache | ❌ No |
| `configs/` | Downloaded TRaSH configs | ❌ No |
| `includes/` | Downloaded TRaSH includes | ❌ No |
| `logs/` | Runtime logs | ❌ No |
| `settings.yml` | Recyclarr runtime settings | ❌ No |

---

## 🔧 **If You See Runtime Files in Git:**

```bash
# Remove from git tracking (keeps local files)
git rm -r --cached configs/recyclarr/cache
git rm -r --cached configs/recyclarr/configs
git rm -r --cached configs/recyclarr/includes
git rm -r --cached configs/recyclarr/logs
git rm --cached configs/recyclarr/settings.yml

# Commit the removal
git commit -m "Remove recyclarr runtime files from git"
git push
```

The `.gitignore` will prevent them from being added again!

---

## ✅ **Verification:**

```bash
# Check what git sees
cd ~/projects/mother
git status configs/recyclarr/

# Should only show tracked files:
# - .gitignore
# - recyclarr.yml
# - .env.example
# - *.md files

# Should NOT show:
# - cache/
# - configs/
# - includes/
# - logs/
# - settings.yml
```

---

**This keeps your git repo clean while Docker handles runtime files!** 🎉
