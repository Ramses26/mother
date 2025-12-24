# Project Mother - Overview

**Version:** 1.0  
**Last Updated:** 2024-12-23  
**Status:** Planning Phase

---

## Table of Contents
- [Executive Summary](#executive-summary)
- [Goals & Objectives](#goals--objectives)
- [Current Infrastructure](#current-infrastructure)
- [Target Architecture](#target-architecture)
- [Storage Strategy](#storage-strategy)
- [Technology Stack](#technology-stack)
- [Timeline & Phases](#timeline--phases)

---

## Executive Summary

Project Mother is a comprehensive media server consolidation initiative that unifies Ali's Unraid-based media infrastructure with Chris Stuttler's Synology-based setup. The project creates a centralized management server ("Mother") hosted on Chris's ESX infrastructure while maintaining redundant storage across both locations.

**Key Benefits:**
- Single point of management for all media acquisition and organization
- Redundant storage across two physical locations
- Consistent quality standards using TRASHGuides profiles
- Automated synchronization ensuring 1:1 data copies
- Improved private tracker ratio through unified cross-seeding

---

## Goals & Objectives

### Primary Goals
1. **Unified Management:** Single Radarr/Sonarr stack managing both libraries
2. **Data Redundancy:** Maintain identical copies at both locations
3. **Quality Standardization:** Apply TRASHGuides profiles consistently
4. **Simplified Access:** Centralized request system (Seerr) for both users
5. **Optimal Seeding:** Long-term seeding with cross-seed automation

### Success Criteria
- ✅ All media accessible from both locations
- ✅ Radarr/Sonarr successfully managing downloads
- ✅ Real-time sync operational (< 1 hour delay)
- ✅ Private tracker accounts healthy (no bans)
- ✅ Zero data loss during migration
- ✅ Both users can request content through Seerr

---

## Current Infrastructure

### Ali's Setup (192.168.1.x Network)

#### Hardware
- **System:** Unraid Server
- **IP:** 192.168.1.10
- **Root Path:** `\\unraid\media`

#### Storage Structure
```
\\unraid\media\
├── 4K Movies/      (8.38 TB)
├── Movies/         (66.3 TB)
├── TV Shows/       (82.3 TB)
└── 4K TV Shows/    (1.94 TB)
Total: ~158.9 TB
```

#### Current Services
- Radarr (1080p & 4K) - Running on Unraid
- Sonarr (1080p & 4K) - Running on Unraid
- Overseerr - Running on Docker (migrating to Seerr on Terminus 192.168.1.14)
- Private tracker accounts (using IP: 74.215.149.185)
- TRASHGuides quality profiles implemented

#### Terminus Server
- **System:** HP G9 Ubuntu Docker Server
- **IP:** 192.168.1.14
- **Purpose:** Main Docker server, secondary to Unraid
- **GitHub:** [Ramses26/Terminus](https://github.com/Ramses26/Terminus)
- **WSL Path:** `\\wsl.localhost\Ubuntu\home\alig\projects\terminus`

---

### Chris's Setup (10.0.0.0/23 Network)

#### Hardware
- **ESX Host:** Proliant DL380 Gen8
  - 64 Logical Processors
  - 191 GB RAM (116 GB Free)
  - Local storage for VMs

#### Storage Infrastructure

**RS-4KMedia (10.0.1.203)**
```
\\10.0.1.203\4KMovies      (4K movie library)
\\10.0.1.203\4ktv          (4K TV library)
\\10.0.1.203\downloads     (Torrent download staging)
```

**RS-TV (10.0.0.88)**
```
\\10.0.0.88\tv             (1080p TV library)
```

**RS-Movies (10.0.0.160)**
```
\\10.0.0.160\movies        (1080p movie library)
```

#### Library Sizes
- Movies: 73.7 TB
- TV Shows: ~85 TB
- Total: ~158.7 TB

#### Current Services
- Overseerr (migrating to Seerr)
- Download clients (details TBD)

---

### Network Connectivity

#### VPN Configuration
- **Type:** IPsec Site-to-Site VPN
- **Equipment:** Unifi UCG (both sides)
- **Ali's Public IP:** 74.215.149.185
- **Chris's Public IP:** 74.83.151.194
- **Bandwidth:** 800 Mbps / 800 Mbps (Altafiber on both sides)

#### Network Topology
```
Ali's Network (192.168.1.x)
    ↕ IPsec VPN Tunnel (10.0.0.0/23 static route)
Chris's Network (10.0.0.x, 10.0.1.x)
```

#### Routing
- Ali can access: 10.0.0.0/23
- Chris can access: 192.168.1.0/24 (assumed)
- VPN is route-based with static routing

---

## Target Architecture

### Mother Server

**Location:** Chris's ESX Host  
**OS:** Ubuntu Server (version TBD)  
**IP:** TBD (10.0.x.x)  
**Hostname:** mother

#### Server Specifications
- **CPU:** Virtual (from 64-core host pool)
- **RAM:** TBD (recommend 16-32 GB)
- **Storage:** 
  - Local ESX storage for configs/databases (~100 GB)
  - Remote mounts to all Synology shares

#### Services Stack
```
Mother Docker Stack:
├── Download Management
│   ├── qBittorrent          (port 8080, 6881)
│   ├── Cross-seed           (port TBD)
│   └── FlareSolverr         (port 8191) [if using Jackett]
│
├── Media Management
│   ├── Radarr-HD            (port 7878) → RS-Movies
│   ├── Radarr-4K            (port 7879) → RS-4KMedia
│   ├── Sonarr-HD            (port 8989) → RS-TV
│   └── Sonarr-4K            (port 8990) → RS-4KMedia
│
├── Quality Management
│   └── Recyclarr            (TRASHGuides automation)
│
├── Indexer Management
│   └── Jackett/Prowlarr     (port 9117/9696) [TBD]
│
├── Request Management
│   ├── Seerr-Ali            (port 5055) [external access]
│   └── Seerr-Chris          (port 5056) [local access]
│
└── Security & Access
    ├── Nginx Proxy Manager  (ports 80, 443, 81)
    └── Authelia/Authentik   (port TBD) [TBD]
```

---

## Storage Strategy

### Download & File Management Flow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. User requests content via Seerr                          │
│    ↓                                                         │
│ 2. Radarr/Sonarr searches trackers via Jackett/Prowlarr     │
│    ↓                                                         │
│ 3. Torrent sent to qBittorrent                              │
│    ↓                                                         │
│ 4. qBittorrent downloads to:                                │
│    \\10.0.1.203\downloads                                   │
│    (RS-4KMedia Synology)                                    │
│    ↓                                                         │
│ 5. Download completes, cross-seed checks for matches        │
│    ↓                                                         │
│ 6. Radarr/Sonarr COPIES file to final location:             │
│    • Radarr-HD    → \\10.0.0.160\movies                     │
│    • Radarr-4K    → \\10.0.1.203\4kmovies                   │
│    • Sonarr-HD    → \\10.0.0.88\tv                          │
│    • Sonarr-4K    → \\10.0.1.203\4ktv                       │
│    ↓                                                         │
│ 7. Original torrent remains in downloads folder             │
│    (continues seeding)                                       │
│    ↓                                                         │
│ 8. Sync service detects new file                            │
│    ↓                                                         │
│ 9. File syncs to Ali's Unraid:                              │
│    • Movies       → \\unraid\media\Movies                   │
│    • 4K Movies    → \\unraid\media\4K Movies                │
│    • TV Shows     → \\unraid\media\TV Shows                 │
│    • 4K TV Shows  → \\unraid\media\4K TV Shows              │
│    ↓                                                         │
│ 10. After 90-120 days:                                      │
│     Cleanup script removes torrent from downloads folder    │
└─────────────────────────────────────────────────────────────┘
```

### Key Storage Decisions

#### ✅ Copy (Not Hardlink)
- **Reason:** Multi-Synology setup prevents hardlinks across devices
- **Trade-off:** Double storage usage in exchange for simpler architecture
- **Benefit:** Allows continued seeding while organizing content

#### ✅ 90-120 Day Retention
- **Purpose:** Balance ratio building with storage management
- **Implementation:** Automated cleanup script
- **Safety:** Verify seeding stats before deletion

#### ✅ One-Way Sync
- **Direction:** Chris's Synology → Ali's Unraid
- **Reason:** Mother is authoritative source
- **Method:** Real-time sync (Syncthing or rclone)

---

## Technology Stack

### Core Components

#### Operating System
- **Mother:** Ubuntu Server 22.04 LTS or 24.04 LTS
- **Container Runtime:** Docker + Docker Compose

#### Media Management
| Service | Version | Purpose |
|---------|---------|---------|
| Radarr | Latest (v5.x) | Movie management (HD & 4K instances) |
| Sonarr | Latest (v4.x) | TV show management (HD & 4K instances) |
| Recyclarr | Latest | TRASHGuides profile automation |

#### Download Stack
| Service | Version | Purpose |
|---------|---------|---------|
| qBittorrent | Latest (4.6.x) | Primary torrent client |
| Cross-seed | Latest | Automated cross-seeding |
| FlareSolverr | Latest | CAPTCHA solving (if using Jackett) |

#### Indexer Management (Choose One)
| Option | Pros | Cons |
|--------|------|------|
| Jackett | Familiar, stable, works with FlareSolverr | Manual sync to each *arr app |
| Prowlarr | Auto-sync to *arr apps, modern UI | May not support all trackers yet |

**Decision:** TBD (requires evaluation)

#### Request Management
| Service | Version | Purpose |
|---------|---------|---------|
| Seerr | Latest | Unified request system (2 instances) |

**Migration:** Overseerr → Seerr using [official guide](https://github.com/seerr-team/seerr/blob/develop/docs/migration-guide.mdx)

#### Security & Access
| Service | Version | Purpose |
|---------|---------|---------|
| Nginx Proxy Manager | Latest | Reverse proxy with SSL |
| Authelia OR Authentik | Latest | Authentication & 2FA |

**Decision:** TBD (requires feature comparison)

#### Synchronization (Choose One)
| Option | Pros | Cons |
|--------|------|------|
| Syncthing | Real-time, bi-directional capable, GUI | More overhead |
| rclone | Lightweight, scriptable, scheduling | Not truly real-time |

**Decision:** TBD (requires testing)

#### Automation & Tools
- **Git:** Configuration version control
- **GitHub Actions:** Automated deployments
- **Bash/Python:** Custom scripts (cleanup, sync, analysis)
- **SSH:** Secure remote management

---

## Quality Profile Strategy

### TRASHGuides Implementation

#### Ali's Preferences (Standard for Project)
- **Preferred:** HDR over Dolby Vision
- **Audio:** Atmos prioritized, best available quality
- **Codecs:** Prefer modern efficient codecs
- **Release Groups:** Tier-based preference

#### Profiles by Type

**1080p Content:**
- Bluray 1080p
- Bluray Remux 1080p
- Quality cutoff: Remux

**4K Content:**
- 2160p Bluray
- 2160p Bluray Remux  
- Quality cutoff: Remux
- HDR preferred over DV

#### Recyclarr Configuration
```yaml
# Automatic sync of TRASHGuides profiles
radarr:
  radarr-hd:
    base_url: http://localhost:7878
    quality_profiles:
      - name: HD-Bluray + WEB
        trash_ids: [list from TRASHGuides]
  
  radarr-4k:
    base_url: http://localhost:7879
    quality_profiles:
      - name: UHD Bluray + WEB
        trash_ids: [list from TRASHGuides]

sonarr:
  # Similar configuration for Sonarr instances
```

---

## Timeline & Phases

### Phase Overview

| Phase | Name | Duration (Est.) | Status |
|-------|------|-----------------|--------|
| 0 | Planning & Documentation | 1 week | ✅ In Progress |
| 1 | Infrastructure Setup | 1 week | ⏳ Not Started |
| 2 | Initial Data Analysis | 3-5 days | ⏳ Not Started |
| 3 | Mother Server Deployment | 1 week | ⏳ Not Started |
| 4 | GitHub Repository Setup | 2 days | ⏳ Not Started |
| 5 | Docker Service Deployment | 2 weeks | ⏳ Not Started |
| 6 | Automation & Cleanup | 1 week | ⏳ Not Started |
| 7 | Data Synchronization | 2-4 weeks* | ⏳ Not Started |
| 8 | Private Tracker Migration | 1 week | ⏳ Not Started |
| 9 | Testing & Validation | 1 week | ⏳ Not Started |
| 10 | Cutover & Migration | 3 days | ⏳ Not Started |
| 11 | Optimization & Monitoring | Ongoing | ⏳ Not Started |

*Duration depends on data volume and bandwidth utilization

### Estimated Total Timeline
- **Optimistic:** 8-10 weeks (full-time work)
- **Realistic:** 12-16 weeks (part-time, evenings/weekends)
- **Conservative:** 20+ weeks (limited time availability)

---

## Risk Management

### High-Priority Risks

#### 1. Private Tracker Account Bans
- **Likelihood:** Medium
- **Impact:** High
- **Mitigation:** 
  - Follow each tracker's IP change policy
  - Notify staff where required
  - Test with least critical trackers first
  - Document successful migrations

#### 2. Data Loss During Initial Sync
- **Likelihood:** Low
- **Impact:** Critical
- **Mitigation:**
  - Checksum verification
  - Keep source data until verified
  - Test with small subset first
  - Maintain backups

#### 3. VPN Tunnel Instability
- **Likelihood:** Low
- **Impact:** High
- **Mitigation:**
  - Monitor tunnel uptime
  - Configure automatic reconnection
  - Set up alerting for tunnel failures

#### 4. Storage Space Exhaustion
- **Likelihood:** Medium (with copy strategy)
- **Impact:** Medium
- **Mitigation:**
  - Monitor disk usage closely
  - Adjust retention period as needed
  - Set up low-space alerts

#### 5. Sync Performance Issues
- **Likelihood:** Medium
- **Impact:** Medium
- **Mitigation:**
  - Test sync tools with real data
  - Optimize bandwidth allocation
  - Consider incremental sync strategies

---

## Success Metrics

### Technical Metrics
- [ ] All services operational (99.9% uptime target)
- [ ] Sync delay < 1 hour for new content
- [ ] Private tracker ratio maintained or improved
- [ ] Zero data corruption incidents
- [ ] Automated cleanup functioning correctly

### User Experience Metrics
- [ ] Content request fulfillment < 24 hours
- [ ] Both users satisfied with quality
- [ ] External access working reliably
- [ ] Mobile app integration functional

### Operational Metrics
- [ ] Backup/restore tested successfully
- [ ] Documentation complete and accurate
- [ ] No manual intervention required for normal operations
- [ ] Clear troubleshooting procedures documented

---

## Future Enhancements (Out of Scope)

- Plex/Jellyfin/Emby integration
- Additional user accounts
- Content discovery automation
- Advanced analytics/dashboards
- Multi-region expansion
- Automated video encoding/transcoding

---

## References

- [TRASHGuides](https://trash-guides.info/)
- [Seerr Migration Guide](https://github.com/seerr-team/seerr/blob/develop/docs/migration-guide.mdx)
- [Terminus GitHub Repository](https://github.com/Ramses26/Terminus)
- [Radarr Documentation](https://wiki.servarr.com/radarr)
- [Sonarr Documentation](https://wiki.servarr.com/sonarr)
- [Recyclarr Documentation](https://recyclarr.dev/)

---

**Document Version History:**
- v1.0 (2024-12-23): Initial creation with complete architecture and requirements
