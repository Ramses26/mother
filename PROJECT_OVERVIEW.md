# Project Mother - Overview

## Project Goal
Consolidate media management between two locations (You & Chris Stuttler) into a unified system running on an Ubuntu server ("Mother") hosted at Chris's location, with real-time synchronization to maintain identical copies of all media at both locations.

## Key Participants
- **You**: Running Unraid server at 192.168.1.10
- **Chris Stuttler**: Running 3 Synology NAS devices at 10.0.0.x/10.0.1.x network
- **Connection**: Site-to-site IPsec VPN (800/800 Mbps Altafiber)

## Network Information

### Your Network (192.168.1.0/24)
- **Unraid Server**: 192.168.1.10
  - Path: `\\unraid\media`
  - Folders: `4K Movies`, `Movies`, `TV Shows`, `4K TV Shows`
  - Current Data: 
    - 4K Movies: 8.38 TB
    - Movies: 66.3 TB
    - TV Shows: 82.3 TB
    - 4K TV Shows: 1.94 TB
    - **Total: ~159 TB**

- **Terminus Server**: 192.168.1.14
  - HP G9 Ubuntu Docker server
  - Currently running Jellyseerr (to be migrated to Seerr)
  - GitHub: https://github.com/Ramses26/Terminus

### Chris's Network (10.0.0.0/23)
- **RS-4KMedia**: 10.0.1.203
  - `\\10.0.1.203\4KMovies`
  - `\\10.0.1.203\4ktv`
  - `\\10.0.1.203\downloads` - qBittorrent download destination
  - Current Data:
    - 4K Movies: Unknown
    - 4K TV: Unknown

- **RS-TV**: 10.0.0.88
  - `\\10.0.0.88\tv`
  - Current Data: ~85 TB

- **RS-Movies**: 10.0.0.160
  - `\\10.0.0.160\movies`
  - Current Data: 73.7 TB

- **Mother Server** (Ubuntu on ESXi)
  - Host: Proliant DL380 Gen 8
  - Resources: 64 Logical Processors, 191 GB RAM
  - Storage: Local ESXi datastore
  - Hostname: mother

### VPN Configuration
- **Type**: IPsec Site-to-Site
- **Equipment**: Unifi UCG (both sides)
- **Local IP**: 74.215.149.185
- **Remote IP**: 74.83.151.194
- **Remote Networks**: 10.0.0.0/23
- **Bandwidth**: 800/800 Mbps (both sites)
- **Encryption**: AES-256, SHA512, DH Group 14

## Architecture Decision: Copy-Based Workflow (Option 3)

### Why Copy Instead of Hardlink?
Due to media being split across 3 separate Synology devices, hardlinks cannot work across different filesystems. The decision is to accept doubled storage usage with these parameters:

**Workflow:**
1. qBittorrent downloads to: `\\10.0.1.203\downloads` (RS-4KMedia)
2. Radarr/Sonarr **COPY** files to final destinations:
   - Movies (1080p) → `\\10.0.0.160\movies` (RS-Movies)
   - TV Shows (1080p) → `\\10.0.0.88\tv` (RS-TV)
   - 4K Movies → `\\10.0.1.203\4KMovies` (RS-4KMedia)
   - 4K TV Shows → `\\10.0.1.203\4ktv` (RS-4KMedia)
3. Original torrents remain in downloads folder for seeding
4. Auto-deletion: Remove torrents after 90-120 days to reclaim space
5. Real-time sync to your Unraid server

### Storage Impact
- Downloads folder will contain active torrents (90-120 day retention)
- Final media locations contain the organized library
- Estimated overhead: 20-30% additional storage for active torrents

## Tech Stack on Mother

### Core Applications
- **OS**: Ubuntu 24.04 LTS
- **Container Runtime**: Docker + Docker Compose
- **Reverse Proxy**: Nginx Proxy Manager
- **Authentication**: Authelia (recommended) or Authentik

### Media Management (*arr Stack)
- **Radarr-HD**: 1080p Movies management
- **Radarr-4K**: 4K Movies management
- **Sonarr-HD**: 1080p TV Shows management
- **Sonarr-4K**: 4K TV Shows management
- **Recyclarr**: Apply TRASHGuides quality profiles automatically

### Download Management
- **qBittorrent**: Primary torrent client
- **Cross-seed**: Automatic cross-seeding across trackers
- **FlareSolverr**: Cloudflare bypass for Jackett (if used)

### Indexer Management
- **Current**: Jackett (decision pending)
- **Future**: Possibly migrate to Prowlarr

### Request Management
- **Seerr** (formerly Overseerr): 2 instances
  - Your instance: External access enabled
  - Chris's instance: LAN access
  - Migration from Jellyseerr/Overseerr required

### Monitoring & Management
- **TBD**: Monitoring solution (suggestions: Uptime Kuma, Netdata)
- **TBD**: Notification system (Discord, Telegram, email)

## Quality Standards (TRASHGuides)

### Preferences
- **HDR over Dolby Vision**: Preferred
- **Audio**: Atmos preferred, best audio profiles
- **Release Groups**: Quality-focused

### Quality Profiles (via Recyclarr)
- **1080p Movies**: Bluray, Bluray Remux
- **4K Movies**: 2160p Bluray, 2160p Bluray Remux  
- **1080p TV**: Bluray, WEB-DL
- **4K TV**: 2160p Bluray, WEB-DL

## Data Synchronization Strategy

### Initial Sync
1. Export file lists with hashes from both libraries
2. Analyze differences using hash comparison
3. Use TRASHGuides profiles to determine superior quality when both have same content
4. Create bidirectional sync script to:
   - Copy missing content from each side
   - Replace inferior quality with superior quality
   - Handle duplicates intelligently

### Ongoing Sync
- **Method**: Real-time sync (rclone, Syncthing, or custom solution)
- **Direction**: Chris's Synology → Your Unraid
- **Trigger**: File system events or scheduled intervals
- **Monitoring**: Sync status dashboard/notifications

## Migration Strategy

### Phase 1: Infrastructure Setup
1. Build Mother Ubuntu server on ESXi
2. Configure networking and VPN access
3. Setup SSH keys between all systems
4. Configure GitHub repository and Actions

### Phase 2: Application Deployment
1. Deploy Docker Compose stack on Mother
2. Configure Nginx Proxy Manager
3. Setup Authelia/Authentik
4. Deploy all *arr applications
5. Configure Recyclarr with TRASHGuides

### Phase 3: Data Analysis & Initial Sync
1. Generate file hashes from both libraries
2. Analyze differences and quality
3. Execute initial bidirectional sync
4. Verify data integrity

### Phase 4: Tracker Migration
1. Document all private tracker accounts
2. Update IP addresses with trackers (notify staff if required)
3. Migrate qBittorrent configuration
4. Configure torrent retention (90-120 days)
5. Setup cross-seed

### Phase 5: Request System Migration
1. Export data from existing Jellyseerr/Overseerr instances
2. Deploy Seerr on Mother (Chris's instance)
3. Migrate Seerr to Terminus (your instance)
4. Configure both to communicate with Mother's *arr apps

### Phase 6: Cutover
1. Stop your local *arr stack
2. Point all applications to Mother
3. Verify real-time sync functioning
4. Monitor for 48-72 hours
5. Decommission old infrastructure

### Phase 7: Ongoing Operations
1. Setup automated backups (Backrest or similar)
2. Configure monitoring and alerts
3. Document maintenance procedures
4. Establish update schedule

## Security Considerations

### SSH Access
- Public/private key authentication only (no passwords)
- Keys needed between:
  - Your WSL → Mother
  - Your WSL → GitHub
  - Mother → GitHub
  - Mother → All Synology devices
  - Mother → Your Unraid (if needed)

### Application Security
- Nginx Proxy Manager for all external access
- Authelia/Authentik for authentication
- HTTPS/SSL for all external services
- Firewall rules restricting external access

### Private Tracker Security
- IP change management
- Account security (2FA where available)
- API key rotation
- Rate limiting compliance

## Configuration Management

### GitHub Repository Structure
```
mother/
├── docker-compose.yml
├── .env (gitignored - secrets)
├── .env.example
├── configs/
│   ├── radarr-hd/
│   ├── radarr-4k/
│   ├── sonarr-hd/
│   ├── sonarr-4k/
│   ├── qbittorrent/
│   ├── recyclarr/
│   ├── nginx/
│   ├── authelia/
│   └── seerr/
├── scripts/
│   ├── sync/
│   ├── backup/
│   └── maintenance/
├── docs/
│   └── (all documentation files)
└── .github/
    └── workflows/
```

### Storage Locations for Configs
1. **GitHub Repository**: Version controlled, secrets excluded
2. **Mother Server**: Live configuration
3. **Your WSL**: Local development/testing
   - Path: `\\wsl.localhost\Ubuntu\home\alig\projects\mother`

### Secrets Management
- `.env` file for sensitive data (never committed)
- GitHub Secrets for CI/CD
- Consider: Vault, SOPS, or age for encryption

## Backup Strategy

### What to Backup
- All Docker configs
- Application databases
- Docker Compose files
- Custom scripts
- `.env` file (encrypted)

### Backup Methods
- **Backrest**: Docker-focused backup solution
- **ESXi Snapshots**: VM-level backups
- **Git**: Configuration version control
- **Cron Jobs**: Scheduled config backups to remote location

### Backup Destinations
- Your Unraid server
- Chris's Synology
- Cloud storage (optional)

## Success Criteria

### Technical Goals
- ✅ Unified *arr stack accessible to both users
- ✅ Real-time sync maintaining identical libraries
- ✅ Automated quality management via Recyclarr
- ✅ 90-120 day torrent retention with auto-cleanup
- ✅ Secure external access to services
- ✅ Zero downtime media access during migration

### Operational Goals
- ✅ Single source of truth for media management
- ✅ Reduced maintenance overhead
- ✅ Automated quality upgrades
- ✅ Protected private tracker accounts
- ✅ Documented and reproducible infrastructure

## Open Questions & Decisions Needed

### Decided
- ✅ Copy-based workflow (Option 3)
- ✅ Keep torrents 90-120 days
- ✅ Use your quality profile preferences
- ✅ Switch to Chris's IP for trackers
- ✅ Real-time sync to Unraid
- ✅ Docker Compose for everything

### To Decide
- ⏳ Jackett vs Prowlarr migration
- ⏳ Authelia vs Authentik
- ⏳ Specific sync tool (rclone vs Syncthing vs custom)
- ⏳ Monitoring solution
- ⏳ Notification platform
- ⏳ Backup schedule and retention
- ⏳ Auto-torrent deletion method (qBittorrent settings vs script)

## Project Timeline
- **Estimated Duration**: 4-6 weeks
- **Phase 1-2**: 1 week (Infrastructure & Deployment)
- **Phase 3**: 1-2 weeks (Initial sync - depends on data size)
- **Phase 4-5**: 1 week (Tracker & Seerr migration)
- **Phase 6-7**: 1 week (Cutover & stabilization)

## Risk Mitigation
- Keep existing infrastructure running until fully validated
- Test sync process with subset of data first
- Have rollback plan for tracker IP changes
- Document everything before decommissioning
- Maintain backups throughout migration
