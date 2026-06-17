# Project Mother - TODO

**Last Updated**: 2024-12-23

This document tracks all tasks that need to be completed for Project Mother. Update this file as tasks are completed and move them to COMPLETED.md.

## Legend
- 🔴 **Critical** - Blocks other work
- 🟡 **High Priority** - Important but not blocking
- 🟢 **Normal** - Standard priority
- ⚪ **Low Priority** - Nice to have

---

## Phase 1: Infrastructure Setup

### Network Configuration
- [ ] 🔴 Assign static IP to Mother server (suggested: 10.0.1.10)
- [ ] 🔴 Configure Ubuntu network settings (/etc/netplan/)
- [ ] 🔴 Set hostname to "mother"
- [ ] 🔴 Test VPN connectivity between networks
- [ ] 🟡 Setup DNS records (if using domain)
- [ ] 🟡 Configure local /etc/hosts on all machines
- [ ] 🟢 Test ping from your network to Chris's network
- [ ] 🟢 Test ping from Chris's network to your network
- [ ] 🟢 Run iperf3 speed test across VPN
- [ ] ⚪ Document actual VPN throughput

### SSH Configuration
- [ ] 🔴 Generate SSH key pair on your WSL
- [ ] 🔴 Copy SSH key to Mother server
- [ ] 🔴 Disable password authentication on Mother
- [ ] 🔴 Test SSH connection from WSL to Mother
- [ ] 🟡 Generate SSH key on Mother for GitHub
- [ ] 🟡 Add Mother's SSH key to GitHub
- [ ] 🟡 Configure SSH keys for Synology devices
- [ ] 🟡 Configure SSH key for Unraid access
- [ ] 🟢 Create ~/.ssh/config on WSL
- [ ] 🟢 Create ~/.ssh/config on Mother
- [ ] 🟢 Test passwordless SSH to all systems
- [ ] ⚪ Setup SSH key rotation reminder (annual)

### Storage Mounts
- [ ] 🔴 Enable NFS on RS-4KMedia (10.0.1.203)
- [ ] 🔴 Enable NFS on RS-TV (10.0.0.88)
- [ ] 🔴 Enable NFS on RS-Movies (10.0.0.160)
- [ ] 🔴 Create mount points on Mother (/mnt/synology/*)
- [ ] 🔴 Configure NFS mounts in /etc/fstab
- [ ] 🔴 Test manual mount of all Synology shares
- [ ] 🔴 Test write access to all mounts
- [ ] 🟡 Configure SMB mount for Unraid
- [ ] 🟡 Test read/write to Unraid from Mother
- [ ] 🟢 Verify mount persistence after reboot
- [ ] ⚪ Optimize NFS mount parameters

### Firewall & Security
- [ ] 🔴 Install and configure UFW
- [ ] 🔴 Setup firewall rules (see SECURITY.md)
- [ ] 🔴 Test firewall rules
- [ ] 🟡 Install and configure Fail2Ban
- [ ] 🟡 Harden SSH configuration
- [ ] 🟢 Configure kernel security parameters
- [ ] 🟢 Install security audit tools (Lynis, rkhunter)
- [ ] 🟢 Run initial security audit
- [ ] ⚪ Setup automatic security updates

---

## Phase 2: Docker Setup

### Docker Installation
- [ ] 🔴 Install Docker on Mother
- [ ] 🔴 Install Docker Compose plugin
- [ ] 🔴 Add user to docker group
- [ ] 🔴 Test Docker installation
- [ ] 🟡 Create Docker networks (mother-network, nginx-proxy)
- [ ] 🟢 Configure Docker daemon settings
- [ ] ⚪ Setup Docker logging rotation

### Directory Structure
- [ ] 🔴 Create /opt/mother directory structure
- [ ] 🔴 Create config subdirectories for all services
- [ ] 🔴 Set proper ownership and permissions
- [ ] 🟢 Create scripts directory
- [ ] 🟢 Create logs directory

### Environment & Compose Files
- [ ] 🔴 Create .env file with all variables
- [ ] 🔴 Generate API keys for all services
- [ ] 🔴 Create .env.example (with sanitized values)
- [ ] 🔴 Create docker-compose.yml
- [ ] 🟡 Add .env to .gitignore
- [ ] 🟢 Validate docker-compose syntax
- [ ] ⚪ Create separate compose files per service (optional)

### Deploy Core Services
- [ ] 🔴 Deploy Nginx Proxy Manager
- [ ] 🔴 Configure NPM initial access
- [ ] 🟡 Deploy Authelia
- [ ] 🟡 Configure Authelia users
- [ ] 🟢 Test Authelia authentication
- [ ] ⚪ Setup Authelia 2FA

---

## Phase 3: Application Deployment

### Radarr
- [ ] 🔴 Deploy Radarr-HD container
- [ ] 🔴 Deploy Radarr-4K container
- [ ] 🔴 Complete Radarr-HD setup wizard
- [ ] 🔴 Complete Radarr-4K setup wizard
- [ ] 🔴 Configure root folders
- [ ] 🔴 Configure file naming (TRASHGuides)
- [ ] 🟡 Add qBittorrent as download client
- [ ] 🟡 Test manual download
- [ ] 🟢 Configure custom scripts (if needed)
- [ ] ⚪ Setup notifications

### Sonarr
- [ ] 🔴 Deploy Sonarr-HD container
- [ ] 🔴 Deploy Sonarr-4K container
- [ ] 🔴 Complete Sonarr-HD setup wizard
- [ ] 🔴 Complete Sonarr-4K setup wizard
- [ ] 🔴 Configure root folders
- [ ] 🔴 Configure file naming (TRASHGuides)
- [ ] 🟡 Add qBittorrent as download client
- [ ] 🟡 Test manual download
- [ ] 🟢 Configure season monitoring
- [ ] ⚪ Setup notifications

### qBittorrent
- [ ] 🔴 Deploy qBittorrent container
- [ ] 🔴 Change default password
- [ ] 🔴 Configure download paths
- [ ] 🔴 Configure connection settings
- [ ] 🔴 Create categories (radarr-hd, radarr-4k, sonarr-hd, sonarr-4k)
- [ ] 🟡 Configure speed limits
- [ ] 🟡 Setup torrent retention (90-120 days)
- [ ] 🟡 Test download and verify file location
- [ ] 🟢 Configure encryption
- [ ] ⚪ Optimize performance settings

### Recyclarr
- [ ] 🔴 Deploy Recyclarr container
- [ ] 🔴 Create recyclarr.yml configuration
- [ ] 🔴 Configure TRASHGuides profiles for Radarr-HD
- [ ] 🔴 Configure TRASHGuides profiles for Radarr-4K
- [ ] 🔴 Configure TRASHGuides profiles for Sonarr-HD
- [ ] 🔴 Configure TRASHGuides profiles for Sonarr-4K
- [ ] 🔴 Set HDR preference over Dolby Vision
- [ ] 🔴 Set Atmos audio preference
- [ ] 🟡 Run initial Recyclarr sync
- [ ] 🟡 Verify quality profiles applied
- [ ] 🟢 Setup automatic sync schedule
- [ ] ⚪ Fine-tune custom format scores

### Indexers
- [ ] 🔴 Deploy Jackett container
- [ ] 🔴 Add all your indexers to Jackett
- [ ] 🔴 Test each indexer
- [ ] 🟡 Deploy FlareSolverr (if using)
- [ ] 🟡 Configure FlareSolverr in Jackett
- [ ] 🟢 Add Jackett feeds to Radarr instances
- [ ] 🟢 Add Jackett feeds to Sonarr instances
- [ ] ⚪ Decide: Migrate to Prowlarr? (future)

### Cross-Seed
- [ ] 🟡 Deploy cross-seed container
- [ ] 🟡 Create cross-seed config.js
- [ ] 🟡 Configure indexer feeds
- [ ] 🟡 Test cross-seed functionality
- [ ] 🟢 Monitor cross-seed performance
- [ ] ⚪ Evaluate cross-seed storage impact

### Seerr
- [ ] 🔴 Deploy Seerr container (Chris's instance)
- [ ] 🟡 Complete Seerr setup wizard
- [ ] 🟡 Connect Seerr to Radarr instances
- [ ] 🟡 Connect Seerr to Sonarr instances
- [ ] 🟡 Import users from Jellyseerr/Overseerr
- [ ] 🟢 Test request workflow
- [ ] 🟢 Configure user permissions
- [ ] ⚪ Setup notifications

---

## Phase 4: Initial Data Sync

### Preparation
- [ ] 🔴 Install Python and required libraries
- [ ] 🔴 Create inventory generation script
- [ ] 🔴 Create library comparison script
- [ ] 🔴 Create sync plan generator
- [ ] 🟡 Test scripts on small dataset
- [ ] 🟢 Setup screen/tmux sessions for long-running tasks

### Generate Inventories
- [ ] 🔴 Generate inventory: Your HD Movies
- [ ] 🔴 Generate inventory: Your 4K Movies
- [ ] 🔴 Generate inventory: Your HD TV
- [ ] 🔴 Generate inventory: Your 4K TV
- [ ] 🔴 Generate inventory: Chris's HD Movies
- [ ] 🔴 Generate inventory: Chris's 4K Movies
- [ ] 🔴 Generate inventory: Chris's HD TV
- [ ] 🔴 Generate inventory: Chris's 4K TV

**Note**: These tasks will take days/weeks. Plan accordingly.

### Compare Libraries
- [ ] 🔴 Compare HD Movies inventories
- [ ] 🔴 Compare 4K Movies inventories
- [ ] 🔴 Compare HD TV inventories
- [ ] 🔴 Compare 4K TV inventories
- [ ] 🟡 Review comparison reports
- [ ] 🟡 Analyze quality differences
- [ ] 🟢 Document findings

### Execute Initial Sync
- [ ] 🔴 Generate sync plan: HD Movies
- [ ] 🔴 Generate sync plan: 4K Movies
- [ ] 🔴 Generate sync plan: HD TV
- [ ] 🔴 Generate sync plan: 4K TV
- [ ] 🔴 Review sync plans manually
- [ ] 🔴 Test sync with small subset
- [ ] 🟡 Execute full sync (Your → Chris)
- [ ] 🟡 Execute full sync (Chris → You)
- [ ] 🟡 Verify sync completion
- [ ] 🟢 Document total sync time
- [ ] 🟢 Document any issues encountered

**Note**: Full sync estimated at 3-4 weeks.

---

## Phase 5: Ongoing Sync Setup

### Rclone Configuration
- [ ] 🔴 Install rclone on Mother
- [ ] 🔴 Configure rclone remotes
- [ ] 🔴 Test rclone sync (dry-run)
- [ ] 🟡 Create sync scripts for each library
- [ ] 🟡 Setup bandwidth limiting
- [ ] 🟢 Configure logging
- [ ] ⚪ Optimize rclone performance

### Scheduling
- [ ] 🔴 Setup cron job for sync (every 15-30 min)
- [ ] 🟡 Create sync monitoring script
- [ ] 🟡 Setup log rotation
- [ ] 🟢 Test scheduled sync execution
- [ ] 🟢 Verify sync triggers after Radarr/Sonarr download
- [ ] ⚪ Create sync statistics dashboard

---

## Phase 6: Private Tracker Migration

### Pre-Migration
- [ ] 🔴 Document all tracker accounts (use template)
- [ ] 🔴 Research IP change policy for each tracker
- [ ] 🔴 Confirm Chris has no conflicting accounts
- [ ] 🔴 Open tickets with strict trackers
- [ ] 🟡 Backup qBittorrent settings
- [ ] 🟡 Export torrent list
- [ ] 🟢 Screenshot account stats
- [ ] ⚪ Enable 2FA on all trackers

### Migration Execution
- [ ] 🔴 Wait for tracker staff approvals
- [ ] 🔴 Add indexers to Jackett on Mother
- [ ] 🔴 Test each indexer from new IP
- [ ] 🔴 Monitor for IP warnings (24-48 hours)
- [ ] 🟡 Migrate torrents in batches (start with 10-20)
- [ ] 🟡 Gradually increase batch sizes
- [ ] 🟡 Update announce URLs if needed
- [ ] 🟢 Monitor ratio and stats
- [ ] 🟢 Address any warnings/issues
- [ ] ⚪ Document lessons learned

### Post-Migration
- [ ] 🟡 Monitor accounts daily (first week)
- [ ] 🟡 Monitor accounts weekly (first month)
- [ ] 🟢 Close tracker tickets
- [ ] 🟢 Update tracker documentation
- [ ] ⚪ Setup account health monitoring

---

## Phase 7: External Access & Authentication

### Nginx Proxy Manager
- [ ] 🔴 Create proxy hosts for all services
- [ ] 🔴 Configure SSL certificates (Let's Encrypt)
- [ ] 🔴 Test HTTP to HTTPS redirect
- [ ] 🟡 Add security headers
- [ ] 🟡 Configure access lists
- [ ] 🟢 Test external access to services
- [ ] ⚪ Setup custom error pages

### Authentication
- [ ] 🔴 Configure Authelia for external services
- [ ] 🔴 Test authentication flow
- [ ] 🟡 Setup 2FA for Authelia
- [ ] 🟡 Create users for all team members
- [ ] 🟢 Configure different access policies
- [ ] ⚪ Setup LDAP (if needed)

### DNS & Domain
- [ ] 🟡 Point domain to Chris's IP (if using)
- [ ] 🟡 Create A records for subdomains
- [ ] 🟢 Test domain resolution
- [ ] ⚪ Setup dynamic DNS (if IP changes)

---

## Phase 8: Seerr Migration

### Your Instance (on Terminus)
- [ ] 🟡 Export data from current Jellyseerr/Overseerr
- [ ] 🟡 Deploy Seerr on Terminus (192.168.1.14)
- [ ] 🟡 Import data to Seerr
- [ ] 🟡 Connect to Mother's Radarr/Sonarr
- [ ] 🟡 Test request workflow
- [ ] 🟢 Configure external access
- [ ] 🟢 Migrate users
- [ ] ⚪ Decommission old instance

### Chris's Instance (on Mother)
- [ ] 🟡 Export data from current Overseerr
- [ ] 🟡 Import data to Seerr on Mother
- [ ] 🟡 Connect to local Radarr/Sonarr
- [ ] 🟢 Test request workflow
- [ ] ⚪ Configure local access

---

## Phase 9: GitHub & CI/CD

### Repository Setup
- [ ] 🟡 Create GitHub repository
- [ ] 🟡 Initialize local git repo
- [ ] 🟡 Create .gitignore file
- [ ] 🟡 Create README.md
- [ ] 🟡 Commit initial code
- [ ] 🟡 Push to GitHub
- [ ] 🟢 Add collaborators
- [ ] ⚪ Setup branch protection

### GitHub Actions
- [ ] 🟡 Create docker-update workflow
- [ ] 🟡 Create backup workflow
- [ ] 🟡 Create security-scan workflow
- [ ] 🟢 Add GitHub secrets
- [ ] 🟢 Test workflows
- [ ] ⚪ Setup deployment workflow

### Scripts
- [ ] 🟡 Create deployment script
- [ ] 🟡 Create backup script
- [ ] 🟡 Create update script
- [ ] 🟢 Make scripts executable
- [ ] 🟢 Test all scripts
- [ ] ⚪ Add error handling to scripts

---

## Phase 10: Backups & Monitoring

### Backup System
- [ ] 🟡 Install backup tool (Backrest or similar)
- [ ] 🟡 Configure backup schedules
- [ ] 🟡 Test backup creation
- [ ] 🟡 Test backup restoration
- [ ] 🟢 Setup encrypted backups
- [ ] 🟢 Configure backup retention
- [ ] 🟢 Setup offsite backup
- [ ] ⚪ Document backup procedures

### Monitoring
- [ ] 🟢 Install monitoring tools (decide which)
- [ ] 🟢 Setup service health checks
- [ ] 🟢 Configure alerts
- [ ] 🟢 Create monitoring dashboard
- [ ] ⚪ Setup log aggregation
- [ ] ⚪ Configure metrics collection

---

## Phase 11: Cutover & Decommission

### Pre-Cutover Testing
- [ ] 🔴 Verify all services running on Mother
- [ ] 🔴 Test complete download workflow
- [ ] 🔴 Verify sync working to Unraid
- [ ] 🔴 Test all authentication
- [ ] 🟡 Load test system
- [ ] 🟢 Document any issues

### Cutover
- [ ] 🔴 Stop your local *arr stack
- [ ] 🔴 Point all clients to Mother
- [ ] 🔴 Monitor for 48-72 hours
- [ ] 🟡 Address any issues
- [ ] 🟢 Confirm everything stable

### Decommission
- [ ] 🟢 Backup old *arr configs
- [ ] 🟢 Document old setup
- [ ] 🟢 Decommission old containers
- [ ] ⚪ Repurpose old infrastructure

---

## Phase 12: Documentation & Handoff

### Documentation
- [ ] 🟡 Complete all documentation files
- [ ] 🟡 Document any deviations from plan
- [ ] 🟢 Create runbook for common tasks
- [ ] 🟢 Document troubleshooting procedures
- [ ] ⚪ Create video walkthrough

### Knowledge Transfer
- [ ] 🟢 Train Chris on system management
- [ ] 🟢 Share all credentials securely
- [ ] 🟢 Document emergency procedures
- [ ] ⚪ Create maintenance schedule

---

## Ongoing Tasks

### Daily
- [ ] Check service health
- [ ] Monitor sync logs
- [ ] Review tracker accounts

### Weekly
- [ ] Review logs for errors
- [ ] Check disk usage
- [ ] Monitor bandwidth usage
- [ ] Review security logs

### Monthly
- [ ] Update Docker containers
- [ ] Review and update quality profiles
- [ ] Check backup integrity
- [ ] Security audit
- [ ] Review sync efficiency

### Quarterly
- [ ] Rotate API keys
- [ ] Review access controls
- [ ] Update documentation
- [ ] Capacity planning

### Annually
- [ ] Rotate SSH keys
- [ ] Full security audit
- [ ] Review and update procedures
- [ ] Disaster recovery drill

---

## Future Enhancements (Post-Launch)

- [ ] ⚪ Migrate from Jackett to Prowlarr
- [ ] ⚪ Add Bazarr for subtitles
- [ ] ⚪ Add Tdarr for transcoding
- [ ] ⚪ Setup Plex/Jellyfin/Emby (if desired)
- [ ] ⚪ Implement advanced monitoring (Prometheus/Grafana)
- [ ] ⚪ Add Lidarr for music
- [ ] ⚪ Add Readarr for books
- [ ] ⚪ Automate more with scripts
- [ ] ⚪ Optimize storage usage
- [ ] ⚪ Performance tuning

---

## Notes

- Update this file regularly as tasks are completed
- Move completed tasks to COMPLETED.md
- Add new tasks as they are discovered
- Prioritize based on dependencies and blockers
- Review weekly during project execution

**Last Task Count**: Check COMPLETED.md for tasks completed
