# Project Mother - TODO & Status

**Last Updated:** 2024-12-23  
**Current Phase:** Planning & Documentation  
**Overall Progress:** 5%

---

## ✅ COMPLETED

### Phase 0: Planning & Documentation
- [x] Initial project discussion and requirements gathering
- [x] VPN configuration documented (IPsec site-to-site, 10.0.0.0/23)
- [x] Storage strategy decided (Copy with 90-120 day retention)
- [x] Quality profile ownership established (Ali's TRASHGuides preferences)
- [x] Architecture diagram created
- [x] Project documentation structure created
- [x] GitHub repository structure planned

---

## 🚧 IN PROGRESS

### Phase 1: Infrastructure Setup
- [ ] **Network & Connectivity**
  - [ ] Document current VPN routing
  - [ ] Test connectivity between all systems
  - [ ] Verify Mother can reach all Synology shares
  - [ ] Verify Mother can reach Ali's Unraid
  - [ ] Set up SSH key authentication (WSL → Mother)
  - [ ] Set up SSH key authentication (Mother → GitHub)
  - [ ] Configure Mother's static IP address (TBD)

### Phase 2: Initial Data Analysis
- [ ] **Data Inventory**
  - [ ] Export Ali's library with file hashes (MD5/SHA256)
  - [ ] Export Chris's library with file hashes
  - [ ] Compare libraries to identify:
    - [ ] Duplicates (same content)
    - [ ] Missing files (Ali has, Chris doesn't)
    - [ ] Missing files (Chris has, Ali doesn't)
    - [ ] Quality differences (using TRASHGuides scoring)
  - [ ] Generate sync plan report
  - [ ] Estimate sync time and bandwidth requirements

---

## 📋 TODO - NOT STARTED

### Phase 3: Mother Server Setup
- [ ] **Ubuntu Server Preparation**
  - [ ] Provision Ubuntu VM on ESX
  - [ ] Assign static IP address
  - [ ] Install Docker and Docker Compose
  - [ ] Configure SMB/NFS client for Synology mounts
  - [ ] Mount all required Synology shares
  - [ ] Verify mount persistence (fstab)
  - [ ] Configure firewall rules (ufw)
  - [ ] Set up automatic security updates

- [ ] **Directory Structure**
  - [ ] Create `/opt/mother` for configs
  - [ ] Create mount points for Synology shares
  - [ ] Set up proper permissions
  - [ ] Create backup directory structure

### Phase 4: GitHub Repository Setup
- [ ] **Repository Configuration**
  - [ ] Initialize GitHub repository
  - [ ] Create `.gitignore` (exclude secrets, local configs)
  - [ ] Create `.env.example` file
  - [ ] Set up branch protection rules
  - [ ] Configure GitHub Actions workflows
  - [ ] Document commit message conventions

- [ ] **SSH Key Setup**
  - [ ] Generate SSH key on WSL
  - [ ] Add public key to GitHub
  - [ ] Generate SSH key on Mother
  - [ ] Add Mother's public key to GitHub (deploy key)
  - [ ] Test SSH access from both systems

### Phase 5: Docker Service Deployment

#### Core Download Stack
- [ ] **qBittorrent**
  - [ ] Create docker-compose service definition
  - [ ] Configure download path to `\\10.0.1.203\downloads`
  - [ ] Import existing configuration
  - [ ] Set up categories (movies-hd, movies-4k, tv-hd, tv-4k)
  - [ ] Configure port forwarding
  - [ ] Test download functionality
  - [ ] Verify VPN binding (if applicable)

- [ ] **Cross-seed**
  - [ ] Create docker-compose service definition
  - [ ] Import existing configuration
  - [ ] Configure for all private trackers
  - [ ] Set up automated scanning schedule
  - [ ] Test cross-seeding functionality

- [ ] **FlareSolverr** (if keeping Jackett)
  - [ ] Create docker-compose service definition
  - [ ] Configure for Jackett integration
  - [ ] Test CAPTCHA solving

#### Media Management Stack
- [ ] **Radarr-HD (1080p Movies)**
  - [ ] Create docker-compose service definition
  - [ ] Configure root folder: `\\10.0.0.160\movies`
  - [ ] Configure Recyclarr integration
  - [ ] Add download client (qBittorrent)
  - [ ] Add indexers (Jackett or Prowlarr)
  - [ ] Import existing library
  - [ ] Set up quality profiles
  - [ ] Configure file management (COPY, not hardlink)
  - [ ] Test download workflow

- [ ] **Radarr-4K (4K Movies)**
  - [ ] Create docker-compose service definition
  - [ ] Configure root folder: `\\10.0.1.203\4kmovies`
  - [ ] Configure Recyclarr integration
  - [ ] Add download client (qBittorrent)
  - [ ] Add indexers (Jackett or Prowlarr)
  - [ ] Import existing library
  - [ ] Set up quality profiles (4K-specific)
  - [ ] Configure file management (COPY, not hardlink)
  - [ ] Test download workflow

- [ ] **Sonarr-HD (1080p TV Shows)**
  - [ ] Create docker-compose service definition
  - [ ] Configure root folder: `\\10.0.0.88\tv`
  - [ ] Configure Recyclarr integration
  - [ ] Add download client (qBittorrent)
  - [ ] Add indexers (Jackett or Prowlarr)
  - [ ] Import existing library
  - [ ] Set up quality profiles
  - [ ] Configure file management (COPY, not hardlink)
  - [ ] Test download workflow

- [ ] **Sonarr-4K (4K TV Shows)**
  - [ ] Create docker-compose service definition
  - [ ] Configure root folder: `\\10.0.1.203\4ktv`
  - [ ] Configure Recyclarr integration
  - [ ] Add download client (qBittorrent)
  - [ ] Add indexers (Jackett or Prowlarr)
  - [ ] Import existing library
  - [ ] Set up quality profiles (4K-specific)
  - [ ] Configure file management (COPY, not hardlink)
  - [ ] Test download workflow

- [ ] **Recyclarr**
  - [ ] Create docker-compose service definition
  - [ ] Create recyclarr.yml configuration
  - [ ] Configure TRASHGuides profiles for Radarr-HD
  - [ ] Configure TRASHGuides profiles for Radarr-4K
  - [ ] Configure TRASHGuides profiles for Sonarr-HD
  - [ ] Configure TRASHGuides profiles for Sonarr-4K
  - [ ] Set up automated sync schedule
  - [ ] Document quality profile preferences
  - [ ] Test profile application

#### Indexer Management
- [ ] **Jackett vs Prowlarr Decision**
  - [ ] Evaluate pros/cons of each
  - [ ] Make final decision
  - [ ] Document reasoning

- [ ] **Jackett** (if chosen)
  - [ ] Create docker-compose service definition
  - [ ] Configure FlareSolverr integration
  - [ ] Add all private tracker indexers
  - [ ] Configure API keys
  - [ ] Test indexer functionality

- [ ] **Prowlarr** (if chosen)
  - [ ] Create docker-compose service definition
  - [ ] Add all private tracker indexers
  - [ ] Configure sync to Radarr/Sonarr instances
  - [ ] Configure API keys
  - [ ] Test indexer functionality

#### Request Management
- [ ] **Seerr - Ali's Instance**
  - [ ] Create docker-compose service definition
  - [ ] Configure for external access
  - [ ] Connect to Mother's Radarr/Sonarr instances
  - [ ] Set up user account for Ali
  - [ ] Configure request rules
  - [ ] Configure notifications
  - [ ] Test request workflow

- [ ] **Seerr - Chris's Instance**
  - [ ] Create docker-compose service definition
  - [ ] Configure for local access
  - [ ] Connect to Mother's Radarr/Sonarr instances
  - [ ] Set up user account for Chris
  - [ ] Configure request rules
  - [ ] Configure notifications
  - [ ] Test request workflow

- [ ] **Migrate from Overseerr to Seerr**
  - [ ] Export Ali's Overseerr database
  - [ ] Export Chris's Overseerr database
  - [ ] Follow Seerr migration guide
  - [ ] Import data to respective Seerr instances
  - [ ] Verify all users and requests migrated
  - [ ] Decommission old Overseerr instances

#### Security & Access
- [ ] **Nginx Proxy Manager**
  - [ ] Create docker-compose service definition
  - [ ] Configure SSL certificates (Let's Encrypt)
  - [ ] Set up proxy hosts for all services
  - [ ] Configure access logs
  - [ ] Test external access

- [ ] **Authelia vs Authentik Decision**
  - [ ] Research features and complexity
  - [ ] Make final decision based on requirements
  - [ ] Document reasoning

- [ ] **Authelia** (if chosen)
  - [ ] Create docker-compose service definition
  - [ ] Configure LDAP or file-based backend
  - [ ] Set up 2FA (TOTP)
  - [ ] Integrate with Nginx Proxy Manager
  - [ ] Configure access policies for each service
  - [ ] Test authentication flow

- [ ] **Authentik** (if chosen)
  - [ ] Create docker-compose service definition
  - [ ] Configure user database
  - [ ] Set up 2FA (TOTP, WebAuthn)
  - [ ] Integrate with Nginx Proxy Manager
  - [ ] Configure access policies for each service
  - [ ] Test authentication flow

### Phase 6: Advanced Torrent Management
**Reference:** `docs/CROSS_SEED_QBIT_MANAGE.md` (Complete setup guide)

- [ ] **cross-seed Setup (Hardlink-based Cross-Seeding)**
  - [ ] Review CROSS_SEED_QBIT_MANAGE.md documentation
  - [ ] Verify cross-seed container running (already deployed)
  - [ ] Create config.js with Prowlarr/qBittorrent connection
  - [ ] Configure hardlink settings (linkType: "hardlink")
  - [ ] Set up linkDirs and dataDirs (MUST be same Docker volume!)
  - [ ] Configure matching mode (partial for renamed media)
  - [ ] Set search cadence (24h recommended)
  - [ ] Test Prowlarr connection
  - [ ] Test qBittorrent connection
  - [ ] Run manual search: `docker exec cross-seed cross-seed search`
  - [ ] Verify hardlinks created (check inode numbers: `ls -lhi`)
  - [ ] Verify torrents added to qBittorrent with cross-seed tag
  - [ ] Monitor for 1 week to ensure working correctly
  - [ ] Document any tracker-specific issues

- [ ] **qbit-manage Setup (120-Day Automated Removal)**
  - [ ] Review CROSS_SEED_QBIT_MANAGE.md documentation
  - [ ] Add qbit-manage to docker-compose.yml
  - [ ] Create config.yml with qBittorrent connection
  - [ ] Configure categories and tracker tags
  - [ ] Enable hardlink detection (nohardlinks section)
  - [ ] Configure share limits:
    - [ ] Movies with hardlinks: 120 days (10,368,000 seconds)
    - [ ] Movies without hardlinks: 30 days (2,592,000 seconds)
    - [ ] TV with hardlinks: 120 days
    - [ ] TV without hardlinks: 30 days
    - [ ] Cross-seeds: 60 days (5,184,000 seconds)
  - [ ] Enable RecycleBin (30 day retention)
  - [ ] Set QBT_DRY_RUN=true (CRITICAL: Test first!)
  - [ ] Deploy container
  - [ ] Review dry run logs thoroughly
  - [ ] Verify hardlink detection working correctly
  - [ ] Verify it's not planning to delete anything important
  - [ ] Test RecycleBin functionality
  - [ ] Set QBT_DRY_RUN=false (after thorough testing)
  - [ ] Monitor closely for 2 weeks
  - [ ] Check RecycleBin regularly
  - [ ] Verify media files NOT being deleted (only torrents)
  - [ ] Document any issues or edge cases

- [ ] **Integration Verification**
  - [ ] Download test movie via Radarr
  - [ ] Verify imported to /movies/ (hardlink created)
  - [ ] Wait for cross-seed to find it (may take up to 24h)
  - [ ] Verify cross-seed creates hardlink (not copy!)
  - [ ] Check disk space: `du -sh /downloads/` vs `du -sh /movies/`
  - [ ] Verify qbit-manage detects hardlink
  - [ ] Confirm torrent NOT tagged as "noHL"
  - [ ] Test manual torrent removal (verify file remains)
  - [ ] Monitor ratio improvements across multiple trackers

- [ ] **Benefits Verification**
  - [ ] Calculate disk space savings from hardlinks
  - [ ] Monitor ratio improvements (expect 2-3x from cross-seeds)
  - [ ] Verify 120-day cleanup working as expected
  - [ ] Confirm no important files deleted
  - [ ] Document actual vs expected performance

### Phase 7: Data Synchronization
- [ ] **Initial Sync Strategy**
  - [ ] Review data comparison report from Phase 2
  - [ ] Create prioritized sync plan
  - [ ] Estimate total sync time
  - [ ] Plan sync execution window

- [ ] **Sync Tool Selection**
  - [ ] Evaluate Syncthing vs rclone
  - [ ] Make decision based on:
    - [ ] Real-time capability
    - [ ] Bandwidth efficiency
    - [ ] Error handling
    - [ ] Monitoring/logging

- [ ] **Syncthing** (if chosen)
  - [ ] Install on Mother
  - [ ] Install on Ali's Unraid
  - [ ] Configure sync folders:
    - [ ] `\\10.0.0.160\movies` → `\\unraid\media\Movies`
    - [ ] `\\10.0.0.88\tv` → `\\unraid\media\TV Shows`
    - [ ] `\\10.0.1.203\4kmovies` → `\\unraid\media\4K Movies`
    - [ ] `\\10.0.1.203\4ktv` → `\\unraid\media\4K TV Shows`
  - [ ] Set sync to one-way (Chris → Ali)
  - [ ] Configure ignore patterns
  - [ ] Test with sample folder
  - [ ] Monitor sync performance

- [ ] **rclone** (if chosen)
  - [ ] Install and configure on Mother or Ali's Unraid
  - [ ] Set up remote configurations
  - [ ] Create sync scripts for each media type
  - [ ] Configure bandwidth limits
  - [ ] Set up systemd service or cron jobs
  - [ ] Test with sample folder
  - [ ] Monitor sync performance

- [ ] **Initial Data Migration**
  - [ ] Execute sync for files Chris is missing
  - [ ] Execute sync for files Ali is missing
  - [ ] Handle quality conflicts (prefer TRASHGuides higher score)
  - [ ] Verify all files copied successfully
  - [ ] Validate file integrity (checksums)

- [ ] **Ongoing Sync Monitoring**
  - [ ] Set up monitoring dashboards
  - [ ] Configure sync failure alerts
  - [ ] Document troubleshooting procedures

### Phase 8: Private Tracker Migration
- [ ] **Pre-Migration**
  - [ ] Document all current private trackers
  - [ ] Document current IP: 74.215.149.185
  - [ ] Document new IP: 74.83.151.194
  - [ ] Review each tracker's rules on IP changes
  - [ ] Identify trackers requiring staff notification
  - [ ] Prepare announcement messages

- [ ] **Tracker-by-Tracker Cutover**
  - [ ] For each tracker:
    - [ ] Notify staff (if required)
    - [ ] Update qBittorrent configuration
    - [ ] Update Jackett/Prowlarr indexer
    - [ ] Test search and download
    - [ ] Monitor for 24-48 hours
    - [ ] Document any issues

- [ ] **Post-Migration**
  - [ ] Verify all trackers working on new IP
  - [ ] Monitor ratio and stats for anomalies
  - [ ] Update documentation with final configs

### Phase 9: Testing & Validation
- [ ] **End-to-End Testing**
  - [ ] Request movie via Seerr (Ali's instance)
  - [ ] Verify request appears in Radarr
  - [ ] Verify torrent added to qBittorrent
  - [ ] Verify download to correct Synology share
  - [ ] Verify Radarr copies file to final location
  - [ ] Verify sync to Ali's Unraid
  - [ ] Verify cross-seed picks up torrent
  - [ ] Repeat for TV show
  - [ ] Repeat for 4K content

- [ ] **Failure Scenarios**
  - [ ] Test qBittorrent failure/restart
  - [ ] Test Radarr/Sonarr failure/restart
  - [ ] Test network disconnection
  - [ ] Test Synology share unavailability
  - [ ] Verify graceful degradation

- [ ] **Performance Testing**
  - [ ] Measure download speeds
  - [ ] Measure copy times (downloads → final location)
  - [ ] Measure sync times (Synology → Unraid)
  - [ ] Identify bottlenecks
  - [ ] Optimize as needed

### Phase 10: Cutover & Migration
- [ ] **Final Preparation**
  - [ ] Create rollback plan
  - [ ] Backup all current configurations
  - [ ] Schedule maintenance window
  - [ ] Notify users (if applicable)

- [ ] **Stop Old Systems**
  - [ ] Stop Ali's Radarr/Sonarr instances
  - [ ] Stop Chris's download clients (if any)
  - [ ] Document final state

- [ ] **Activate Mother**
  - [ ] Enable all services on Mother
  - [ ] Verify all services healthy
  - [ ] Begin monitoring

- [ ] **Post-Cutover**
  - [ ] Monitor for 7 days
  - [ ] Address any issues
  - [ ] Fine-tune configurations
  - [ ] Update documentation

### Phase 11: Optimization & Maintenance
- [ ] **Backup Strategy**
  - [ ] Set up config backups (Mother → GitHub)
  - [ ] Set up database backups (Radarr/Sonarr)
  - [ ] Set up ESX VM snapshots
  - [ ] Test restore procedures
  - [ ] Document backup/restore process

- [ ] **Monitoring**
  - [ ] Set up service health checks
  - [ ] Configure alerting (disk space, service failures)
  - [ ] Create dashboards (optional)

- [ ] **Documentation Finalization**
  - [ ] Create runbook for common tasks
  - [ ] Document troubleshooting procedures
  - [ ] Create disaster recovery plan
  - [ ] Write user guides for Seerr

---

## 🎯 MILESTONES

- [ ] **Milestone 1:** Documentation Complete (Target: TBD)
- [ ] **Milestone 2:** Mother Server Deployed (Target: TBD)
- [ ] **Milestone 3:** All Docker Services Running (Target: TBD)
- [ ] **Milestone 4:** Initial Data Sync Complete (Target: TBD)
- [ ] **Milestone 5:** Private Trackers Migrated (Target: TBD)
- [ ] **Milestone 6:** Old Systems Decommissioned (Target: TBD)

---

## 📊 STATISTICS

- **Total Tasks:** ~200
- **Completed:** ~7
- **In Progress:** ~8
- **Not Started:** ~185
- **Estimated Completion:** TBD (depends on weekly time commitment)

---

## 🚨 BLOCKERS & RISKS

### Current Blockers
- None

### Identified Risks
1. **Private Tracker Bans:** IP change could trigger bans if not handled carefully
   - Mitigation: Follow each tracker's rules, notify staff where required
2. **Data Loss During Migration:** Initial sync could fail or corrupt data
   - Mitigation: Checksums, verification, maintain source data until fully validated
3. **Performance Issues:** Sync over VPN might be slow
   - Mitigation: Monitor bandwidth, optimize sync scheduling
4. **Storage Space:** 90-120 day retention requires significant space
   - Mitigation: Monitor disk usage, adjust retention as needed

---

## 📝 NOTES & DECISIONS

### Key Decisions Log
- **2024-12-23:** Storage strategy - COPY files, 90-120 day torrent retention
- **2024-12-23:** Quality profiles - Ali's TRASHGuides preferences are standard
- **2024-12-23:** Sync direction - One-way from Chris's Synology to Ali's Unraid
- **2024-12-23:** Private trackers - Switch to Chris's IP (74.83.151.194)
- **2024-12-25:** HDR Priority - HDR10 (300pts) > DV HDR10 (280pts) > HDR (250pts) > DV (150pts) > HDR10+ (100pts)
- **2024-12-25:** Indexer Choice - Prowlarr (modern, auto-sync to all *arr apps)
- **2024-12-25:** Cross-Seeding - Use cross-seed with hardlinks (zero disk space overhead)
- **2024-12-25:** Torrent Management - Use qbit-manage for automated 120-day removal with hardlink protection

### Questions for Later
- Authelia vs Authentik - needs evaluation
- Syncthing vs rclone - needs evaluation
- Final Mother IP address - needs assignment
