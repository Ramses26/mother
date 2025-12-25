# Mother Project - Quick Start Guide

**Last Updated:** 2024-12-23

This guide will help you get started with Project Mother quickly.

---

## 📋 What You Have

### ✅ Complete Documentation
- PROJECT_OVERVIEW.md - Full project documentation
- NETWORK_SETUP.md - Network and VPN configuration
- DOCKER_SETUP.md - Docker and container setup
- INITIAL_SYNC.md - Initial data synchronization guide
- SYNC_STRATEGY.md - Ongoing sync implementation
- SECURITY.md - Security hardening
- TRACKER_MIGRATION.md - Private tracker migration
- GITHUB_WORKFLOW.md - Git and CI/CD setup
- RECYCLARR_SETUP.md (in docs/) - TRASHGuides automation
- TODO.md - Complete task list
- COMPLETED.md - Progress tracking

### ✅ Complete Scripts
- **qbittorrent_cleanup.sh** - Automatic torrent cleanup (90-120 days)
- **sync_to_unraid.sh** - Real-time sync from Synology to Unraid
- **generate_inventory.py** - Create media library inventories
- **compare_libraries.py** - Compare libraries and determine best versions
- **execute_initial_sync.sh** - Execute initial sync from comparison results
- **deploy.sh** - Deploy and manage Mother stack
- **backup.sh** - Backup and restore configurations
- **scripts/README.md** - Complete scripts documentation

### ✅ Configuration Files
- docker-compose.yml - Complete service definitions
- .env.example - Environment variables template
- .gitignore - Git ignore rules

---

## 🚀 Getting Started - Step by Step

### Phase 1: Infrastructure (1-2 days)

#### 1. Deploy Ubuntu Server on ESX
```bash
# On Chris's ESX host
# Create new VM with Ubuntu 24.04
# Recommended specs:
#   - 4 vCPUs
#   - 8 GB RAM
#   - 50 GB disk (configs only, media on Synology)
#   - Network: Connect to management network
```

#### 2. Basic Ubuntu Setup
```bash
# Set hostname
sudo hostnamectl set-hostname mother

# Update system
sudo apt update && sudo apt upgrade -y

# Install basic tools
sudo apt install -y vim curl wget git htop net-tools
```

#### 3. Assign Static IP
```bash
# Recommended: 10.0.1.10
# Edit /etc/netplan/00-installer-config.yaml
sudo nano /etc/netplan/00-installer-config.yaml

# Apply network config
sudo netplan apply

# Verify
ip addr show
```

#### 4. Setup SSH Access from Your WSL
```bash
# On your WSL machine
ssh-keygen -t ed25519 -C "mother-project"

# Copy key to Mother
ssh-copy-id user@10.0.1.10

# Test connection
ssh user@10.0.1.10
```

#### 5. Install Docker
```bash
# On Mother server
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in, then verify
docker --version
docker compose version
```

---

### Phase 2: Storage Setup (1 day)

#### 1. Enable NFS on Synology Devices
```bash
# On each Synology:
# Control Panel → File Services → NFS → Enable NFS
# Create NFS rules for Mother's IP (10.0.1.10)
```

#### 2. Create Mount Points on Mother
```bash
# On Mother
sudo mkdir -p /mnt/synology/rs-movies
sudo mkdir -p /mnt/synology/rs-tv
sudo mkdir -p /mnt/synology/rs-4kmedia/{4kmovies,4ktv,downloads}
sudo mkdir -p /mnt/unraid/media
```

#### 3. Install NFS Client
```bash
sudo apt install -y nfs-common
```

#### 4. Configure /etc/fstab

**See [docs/NFS_MOUNT_COMPLETE.md](docs/NFS_MOUNT_COMPLETE.md) for complete instructions!**

```bash
sudo nano /etc/fstab

# Add Synology mounts (5 mounts - adjust share names to match yours):
10.0.0.160:/volume1/MOVIES /mnt/synology/rs-movies nfs defaults,nofail 0 0
10.0.0.88:/volume1/TV /mnt/synology/rs-tv nfs defaults,nofail 0 0
10.0.1.203:/volume1/4KMovies /mnt/synology/rs-4kmedia/4kmovies nfs defaults,nofail 0 0
10.0.1.203:/volume1/4KTV /mnt/synology/rs-4kmedia/4ktv nfs defaults,nofail 0 0
10.0.1.203:/volume1/Downloads /mnt/synology/rs-4kmedia/downloads nfs defaults,nofail 0 0

# Add Unraid mount (1 mount - via VPN):
192.168.1.10:/mnt/user/Media /mnt/unraid/media nfs defaults,nofail 0 0
```

#### 5. Mount and Test
```bash
# Mount all
sudo mount -a

# Verify
df -h
touch /mnt/synology/rs-movies/test.txt
```

---

### Phase 3: Project Setup (30 minutes)

#### 1. Create Project Directory
```bash
# On Mother
sudo mkdir -p /opt/mother
sudo chown $USER:$USER /opt/mother
cd /opt/mother
```

#### 2. Clone from WSL
```bash
# On your WSL
cd ~/projects/mother

# Push to GitHub first (if not done)
git init
git add .
git commit -m "Initial Mother project structure"
git remote add origin git@github.com:yourusername/mother.git
git push -u origin main

# On Mother, clone
cd /opt/mother
git clone git@github.com:yourusername/mother.git .
```

#### 3. Create .env File
```bash
cd /opt/mother
cp .env.example .env
nano .env

# Configure all variables:
# - PUID/PGID (run `id` to get yours)
# - Ports
# - Paths
# - API keys (add after deployment)
```

#### 4. Create Directory Structure
```bash
mkdir -p /opt/mother/{configs,logs,backups}
mkdir -p /opt/mother/configs/{qbittorrent,radarr-hd,radarr-4k,sonarr-hd,sonarr-4k,prowlarr,recyclarr,seerr-ali,seerr-chris,nginx,authelia}
```

#### 5. Make Scripts Executable
```bash
chmod +x scripts/*.sh
chmod +x scripts/*.py
```

---

### Phase 4: Initial Deployment (1 hour)

#### 1. Deploy Stack
```bash
cd /opt/mother
./scripts/deploy.sh
```

#### 2. Verify All Services
```bash
docker compose ps

# All containers should show "Up"
```

#### 3. Access Services
```
Management & Monitoring:
- Webmin:     https://10.0.1.10:10000 (your Ubuntu user/pass)
- Dozzle:     http://10.0.1.10:8888 (Docker logs)
- NPM:        http://10.0.1.10:81 (default: admin@example.com/changeme)

Media Management:
- qBittorrent: http://10.0.1.10:8080 (default: admin/adminadmin)
- Radarr HD:   http://10.0.1.10:7878
- Radarr 4K:   http://10.0.1.10:7879
- Sonarr HD:   http://10.0.1.10:8989
- Sonarr 4K:   http://10.0.1.10:8990
- Prowlarr:    http://10.0.1.10:9696
```

#### 4. Change Default Passwords
```bash
# qBittorrent: Tools → Options → Web UI
# NPM: Default is admin@example.com / changeme
```

---

### Phase 5: Configure Services (2-3 hours)

#### 1. qBittorrent
- Change password
- Set download path: `/downloads`
- Create categories: `radarr-hd`, `radarr-4k`, `sonarr-hd`, `sonarr-4k`
- Configure connection settings

#### 2. Prowlarr (or Jackett)
- Add all your indexers
- Test each one
- Note: Use Jackett + FlareSolverr if needed for private trackers

#### 3. Radarr Instances
- Complete setup wizard
- Add root folders:
  - HD: `/movies` (maps to RS-Movies)
  - 4K: `/movies-4k` (maps to RS-4KMedia)
- Add download client (qBittorrent)
- Connect to Prowlarr
- Get API keys for Recyclarr

#### 4. Sonarr Instances
- Complete setup wizard
- Add root folders:
  - HD: `/tv` (maps to RS-TV)
  - 4K: `/tv-4k` (maps to RS-4KMedia)
- Add download client (qBittorrent)
- Connect to Prowlarr
- Get API keys for Recyclarr

#### 5. Recyclarr
```bash
# Update .env with API keys
nano /opt/mother/.env

# Add:
RADARR_HD_API_KEY=...
RADARR_4K_API_KEY=...
SONARR_HD_API_KEY=...
SONARR_4K_API_KEY=...

# Create config
mkdir -p /opt/mother/configs/recyclarr
nano /opt/mother/configs/recyclarr/recyclarr.yml
# (Use template from docs/RECYCLARR_SETUP.md)

# Run initial sync
docker exec recyclarr recyclarr sync

# Verify in Radarr/Sonarr: Settings → Profiles
```

---

### Phase 6: Initial Data Sync (3-4 weeks)

#### 1. Generate Inventories

**RECOMMENDED: Run Ali's inventories on Terminus (faster!)**

See [docs/INVENTORY_GUIDE.md](docs/INVENTORY_GUIDE.md) for complete instructions.

**Quick version:**
```bash
# On Terminus (Ali's libraries - LOCAL, FAST):
python3 generate_inventory.py /mnt/user/Media/Movies -o ~/inventories/ali_movies
python3 generate_inventory.py "/mnt/user/Media/4K Movies" -o ~/inventories/ali_4kmovies
python3 generate_inventory.py "/mnt/user/Media/TV Shows" -o ~/inventories/ali_tv
python3 generate_inventory.py "/mnt/user/Media/4K TV Shows" -o ~/inventories/ali_4ktv
# Then: scp ~/inventories/ali_*.{json,csv} mother:/opt/mother/inventories/

# On Mother (Chris's libraries - LOCAL, FAST):

# Ali's Libraries (if running on Mother via VPN - SLOWER)
python3 scripts/generate_inventory.py /mnt/unraid/media/Movies -o ali_movies
python3 scripts/generate_inventory.py "/mnt/unraid/media/4K Movies" -o ali_4kmovies
python3 scripts/generate_inventory.py "/mnt/unraid/media/TV Shows" -o ali_tv
python3 scripts/generate_inventory.py "/mnt/unraid/media/4K TV Shows" -o ali_4ktv

# Chris's Libraries (this will take DAYS)
python3 scripts/generate_inventory.py /mnt/synology/rs-movies -o chris_movies
python3 scripts/generate_inventory.py /mnt/synology/rs-4kmedia/4kmovies -o chris_4kmovies
python3 scripts/generate_inventory.py /mnt/synology/rs-tv -o chris_tv
python3 scripts/generate_inventory.py /mnt/synology/rs-4kmedia/4ktv -o chris_4ktv
```

#### 2. Compare Libraries
```bash
# Compare each library
python3 scripts/compare_libraries.py ali_movies.json chris_movies.json -o reports/movies
python3 scripts/compare_libraries.py ali_4kmovies.json chris_4kmovies.json -o reports/4kmovies
python3 scripts/compare_libraries.py ali_tv.json chris_tv.json -o reports/tv
python3 scripts/compare_libraries.py ali_4ktv.json chris_4ktv.json -o reports/4ktv

# Review reports
cat reports/*/comparison_summary_*.txt
```

#### 3. Execute Initial Sync (Carefully!)
```bash
# Start with dry run
./scripts/execute_initial_sync.sh -f reports/movies/sync_plan_*.csv

# When ready, execute live
./scripts/execute_initial_sync.sh -f reports/movies/sync_plan_*.csv --live -b 50

# Monitor progress
tail -f /opt/mother/logs/sync.log
```

---

### Phase 7: Ongoing Automation (1 hour)

#### 1. Setup Cron Jobs
```bash
crontab -e

# Add these lines:
# Backup daily at 2 AM
0 2 * * * /opt/mother/scripts/backup.sh >> /opt/mother/logs/backup.log 2>&1

# qBittorrent cleanup daily at 3 AM  
0 3 * * * /opt/mother/scripts/qbittorrent_cleanup.sh >> /opt/mother/logs/qbit_cleanup.log 2>&1

# Sync to Unraid every 15 minutes
*/15 * * * * /opt/mother/scripts/sync_to_unraid.sh >> /opt/mother/logs/sync.log 2>&1

# Recyclarr sync daily at 4 AM
0 4 * * * docker exec recyclarr recyclarr sync >> /opt/mother/logs/recyclarr.log 2>&1
```

#### 2. Test Each Script
```bash
# Test backup
./scripts/backup.sh

# Test cleanup (dry run)
./scripts/qbittorrent_cleanup.sh

# Test sync (dry run)
./scripts/sync_to_unraid.sh --dry-run
```

---

### Phase 8: Tracker Migration (Plan carefully!)

⚠️ **CRITICAL**: Follow TRACKER_MIGRATION.md exactly. Getting banned is permanent!

1. Document all current tracker accounts
2. Open tickets with trackers about IP change
3. Wait for approval
4. Migrate in small batches
5. Monitor for warnings

---

## 🔍 Monitoring & Maintenance

### Daily Checks
```bash
# Container health
docker compose ps

# Logs
docker compose logs --tail=50

# Disk usage
df -h
```

### Weekly Tasks
- Review sync logs
- Check backup completion
- Monitor download client

### Monthly Tasks
- Update containers: `./scripts/deploy.sh`
- Review quality profiles
- Check tracker ratios

---

## 📚 Important Files Reference

| File | Purpose |
|------|---------|
| PROJECT_OVERVIEW.md | Complete project documentation |
| TODO.md | All remaining tasks |
| COMPLETED.md | Progress tracking |
| scripts/README.md | All scripts documentation |
| docker-compose.yml | Service definitions |
| .env | Configuration (NEVER commit!) |

---

## 🆘 Troubleshooting

### Container Won't Start
```bash
# Check logs
docker compose logs [container-name]

# Check .env file
cat .env | grep -v "^#"

# Verify mounts
df -h | grep synology
```

### Can't Access Services
```bash
# Check ports
ss -tulpn | grep -E "(8080|7878|8989)"

# Check firewall
sudo ufw status
```

### Sync Not Working
```bash
# Test connectivity
ping 192.168.1.10
ping 10.0.1.203

# Test mount
ls -la /mnt/synology/rs-movies
ls -la /mnt/unraid
```

---

## 📞 Getting Help

1. Check logs: `/opt/mother/logs/`
2. Review documentation in project root
3. Check scripts/README.md for script-specific help
4. Review TODO.md for what's expected at each phase

---

## ✅ Success Criteria

You'll know it's working when:
- [ ] All containers show "Up" in `docker compose ps`
- [ ] You can access all web UIs
- [ ] Radarr/Sonarr can search and download
- [ ] Downloads appear in qBittorrent
- [ ] Files copy to final location (Synology)
- [ ] Files sync to Unraid (check logs)
- [ ] Backups run automatically
- [ ] Old torrents clean up after 90-120 days

---

**Ready to begin? Start with Phase 1!**

For complete details on any step, refer to the full documentation files.
