# Project Mother 🏗️

Unified media management server consolidating Ali's Unraid and Chris's Synology infrastructure.

## 🚀 NEW: Start Here!

**Ready to build Mother?** → [QUICK_START.md](QUICK_START.md) - Step-by-step implementation guide

## 📚 Documentation

### Essential Guides
- 🎯 [**QUICK_START.md**](QUICK_START.md) - **START HERE!** Step-by-step implementation
- 📋 [TODO.md](TODO.md) - Complete task list and progress tracking  
- ✅ [COMPLETED.md](COMPLETED.md) - What's done and verified
- 📖 [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md) - Full architecture and goals

### Setup Guides
- 🌐 [NETWORK_SETUP.md](NETWORK_SETUP.md) - VPN, SSH, and connectivity
- 🐳 [DOCKER_SETUP.md](DOCKER_SETUP.md) - All container configurations
- 🔄 [INITIAL_SYNC.md](INITIAL_SYNC.md) - Data comparison and migration
- 📡 [SYNC_STRATEGY.md](SYNC_STRATEGY.md) - Real-time replication
- 🎬 [docs/RECYCLARR_SETUP.md](docs/RECYCLARR_SETUP.md) - TRASHGuides quality profiles

### Migration & Security
- 🔐 [SECURITY.md](SECURITY.md) - SSH, authentication, hardening
- 📻 [TRACKER_MIGRATION.md](TRACKER_MIGRATION.md) - Private tracker IP change
- 🔧 [GITHUB_WORKFLOW.md](GITHUB_WORKFLOW.md) - Git, CI/CD, automation

### Scripts
- 🛠️ [scripts/README.md](scripts/README.md) - Complete scripts documentation

## Project Team

- **Ali** (You) - Unraid @ 192.168.1.10
- **Chris Stuttler** - Synology Infrastructure @ 10.0.0.0/23
- **Mother** - Ubuntu Server @ Chris's location (TBD IP)

## Current Library Sizes

**Ali's Unraid:**
- 4K Movies: 8.38 TB
- Movies: 66.3 TB
- TV Shows: 82.3 TB
- 4K TV Shows: 1.94 TB
- **Total: ~158.9 TB**

**Chris's Synology:**
- Movies: 73.7 TB
- TV Shows: ~85 TB
- **Total: ~158.7 TB**

## Key Decisions Made

✅ Storage Strategy: Copy files (not hardlink) with 90-120 day torrent retention  
✅ Sync Direction: Chris's Synology → Ali's Unraid (one-way, real-time)  
✅ Quality Profiles: Ali's TRASHGuides preferences (HDR > DV, Atmos priority)  
✅ Private Trackers: Switch to Chris's IP, use Ali's credentials  
✅ Authentication: External access protected (Authelia or Authentik - TBD)  
✅ Seerr Instances: Each person gets their own, both talk to Mother's Radarr/Sonarr  

## Architecture Summary

```
Mother (Ubuntu Docker Server @ Chris's ESX)
├── Radarr-HD        → RS-Movies (\\10.0.0.160\movies)
├── Radarr-4K        → RS-4KMedia (\\10.0.1.203\4kmovies)
├── Sonarr-HD        → RS-TV (\\10.0.0.88\tv)
├── Sonarr-4K        → RS-4KMedia (\\10.0.1.203\4ktv)
├── qBittorrent      → RS-4KMedia (\\10.0.1.203\downloads)
├── Cross-seed
├── Recyclarr
├── Seerr-Ali        → External access
├── Seerr-Chris      → Local access
├── Nginx Proxy Manager
└── Authelia/Authentik

Storage Flow:
qBittorrent downloads → \\10.0.1.203\downloads
    ↓ (Copy after completion)
Radarr/Sonarr → Appropriate Synology share
    ↓ (Real-time sync)
Ali's Unraid ← Syncthing/rclone sync

Cleanup: Auto-delete torrents from downloads after 90-120 days
```

## Getting Started

1. Review [Project Overview](docs/PROJECT_OVERVIEW.md)
2. Check [Current Status](docs/TODO.md) to see progress
3. Follow the phase-by-phase implementation plan

## 📦 What's Included

### ✅ Complete Documentation (v0.2.0)
- Full project planning and architecture
- Network setup guides with VPN configuration  
- Docker deployment procedures
- Data synchronization strategy
- Security hardening guidelines
- Private tracker migration plan
- 350+ tasks identified and organized

### ✅ Complete Scripts (v0.2.0)
- **qbittorrent_cleanup.sh** - Auto-delete torrents after 90-120 days
- **sync_to_unraid.sh** - Real-time sync from Synology to Unraid
- **generate_inventory.py** - Scan libraries and create inventories
- **compare_libraries.py** - Compare libraries using TRASHGuides scoring
- **execute_initial_sync.sh** - Execute initial sync from comparison
- **deploy.sh** - Deploy and manage the Mother stack
- **backup.sh** - Backup/restore all configurations
- All scripts include dry-run modes and comprehensive logging

### ✅ Production-Ready Configs
- docker-compose.yml with all services
- .env.example template
- Recyclarr configurations for quality profiles
- GitHub Actions workflows (ready to use)

## 📁 Repository Structure

```
mother/
├── README.md                    # This file
├── QUICK_START.md              # ⭐ Start here!
├── TODO.md                      # All tasks and progress
├── COMPLETED.md                 # What's done
├── PROJECT_OVERVIEW.md          # Full documentation
├── NETWORK_SETUP.md            # Network configuration
├── DOCKER_SETUP.md             # Docker setup
├── INITIAL_SYNC.md             # Data sync procedures
├── SYNC_STRATEGY.md            # Ongoing sync
├── SECURITY.md                 # Security setup
├── TRACKER_MIGRATION.md        # Tracker migration
├── GITHUB_WORKFLOW.md          # Git and CI/CD
│
├── .env.example                # Environment template
├── .gitignore                  # Git ignore rules
├── docker-compose.yml          # Service definitions
│
├── docs/                       # Additional docs
│   └── RECYCLARR_SETUP.md     # Quality profiles
│
├── scripts/                    # ⭐ Automation scripts
│   ├── README.md              # Scripts documentation
│   ├── qbittorrent_cleanup.sh
│   ├── sync_to_unraid.sh
│   ├── generate_inventory.py
│   ├── compare_libraries.py
│   ├── execute_initial_sync.sh
│   ├── deploy.sh
│   └── backup.sh
│
└── configs/                    # (Created during deployment)
    ├── qbittorrent/
    ├── radarr-hd/
    ├── radarr-4k/
    ├── sonarr-hd/
    ├── sonarr-4k/
    ├── prowlarr/
    ├── recyclarr/
    ├── seerr-ali/
    ├── seerr-chris/
    ├── nginx/
    └── authelia/
```

## 🎯 Current Status

**Phase:** Documentation & Scripts Complete ✅  
**Next:** Infrastructure Setup

### Completed ✅
- [x] Full project documentation
- [x] All automation scripts created
- [x] Docker compose configuration
- [x] Network architecture defined
- [x] Quality profiles configured (TRASHGuides)
- [x] Backup and restore procedures
- [x] Initial sync methodology
- [x] Security hardening plan

### In Progress 🔄
- [ ] Ubuntu server deployment on ESX
- [ ] Network configuration
- [ ] SSH key setup
- [ ] Storage mounts (NFS)

### Upcoming ⏳
- [ ] Docker stack deployment
- [ ] Service configuration
- [ ] Initial data sync (3-4 weeks)
- [ ] Private tracker migration
- [ ] Production cutover

See [TODO.md](TODO.md) for complete task list.

## 💡 Key Features

- **Unified Management**: Single Radarr/Sonarr stack for both users
- **Redundancy**: 1:1 copy of all media on both Ali's and Chris's infrastructure
- **Quality First**: TRASHGuides profiles with preference for HDR and Atmos
- **Smart Cleanup**: Automatic torrent deletion after 90-120 days
- **Real-Time Sync**: Changes replicate within 15 minutes
- **Secure**: SSH keys, authentication, firewall, best practices
- **Automated**: Scripts handle deployment, backup, sync, and cleanup
- **Documented**: Every aspect thoroughly documented with examples

## 🛠️ Technology Stack

- **OS**: Ubuntu 24.04 LTS
- **Containerization**: Docker + Docker Compose
- **Media Management**: Radarr, Sonarr (4 instances total)
- **Download Client**: qBittorrent + Cross-seed
- **Quality Automation**: Recyclarr + TRASHGuides
- **Indexer**: Prowlarr or Jackett + FlareSolverr
- **Request Management**: Seerr (2 instances)
- **Reverse Proxy**: Nginx Proxy Manager
- **Monitoring**: Dozzle (Docker logs), Webmin (system management)
- **Synchronization**: rclone
- **Version Control**: Git + GitHub Actions

## 📊 Scale

- **Total Media**: ~159 TB
- **Files**: Tens of thousands
- **Services**: 12+ Docker containers
- **Networks**: 2 locations via VPN
- **Storage**: 4 Synology devices + 1 Unraid server
- **Users**: 2 primary, potentially more via Seerr

## ⚙️ Next Steps

1. **Read**: [QUICK_START.md](QUICK_START.md)
2. **Deploy**: Ubuntu server on Chris's ESX
3. **Configure**: Network, SSH, storage mounts
4. **Run**: `./scripts/deploy.sh`
5. **Sync**: Generate inventories and compare libraries
6. **Migrate**: Private trackers (carefully!)
7. **Monitor**: Verify sync and automation

## 📝 Notes

- All scripts default to dry-run mode for safety
- Comprehensive logging throughout
- Option 3 workflow: Copy files with retention cleanup
- VPN already configured: IPsec site-to-site (800/800 Mbps)
- Mother will be at Chris's location (10.0.1.x network)

---

**Version**: 0.2.0  
**Last Updated**: 2024-12-23  
**Status**: Ready for infrastructure deployment
