# Docker Setup - Project Mother

## Directory Structure

```
/opt/mother/
├── docker-compose.yml
├── .env
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
│   ├── seerr/
│   ├── jackett/
│   ├── flaresolverr/
│   └── cross-seed/
├── scripts/
│   ├── backup.sh
│   ├── update.sh
│   └── cleanup.sh
└── logs/
```

## Initial Setup

### Create Directory Structure
```bash
# Create main directory
sudo mkdir -p /opt/mother
cd /opt/mother

# Create subdirectories
sudo mkdir -p configs/{radarr-hd,radarr-4k,sonarr-hd,sonarr-4k,qbittorrent,recyclarr,nginx,authelia,seerr,jackett,flaresolverr,cross-seed}
sudo mkdir -p scripts logs

# Set permissions
sudo chown -R $USER:$USER /opt/mother
```

### Create Networks
```bash
docker network create mother-network
docker network create nginx-proxy
```

## Environment Variables

### .env File Template
Create `/opt/mother/.env`:

```bash
# PUID/PGID (get with: id -u and id -g)
PUID=1000
PGID=1000

# Timezone
TZ=America/New_York

# Domain (if using external access)
DOMAIN=stuttler.net

# Paths - Synology Mounts
DOWNLOADS_PATH=/mnt/synology/downloads
MOVIES_HD_PATH=/mnt/synology/movies
MOVIES_4K_PATH=/mnt/synology/4kmovies
TV_HD_PATH=/mnt/synology/tv
TV_4K_PATH=/mnt/synology/4ktv

# VPN Config (if using)
VPN_ENABLED=false
VPN_TYPE=openvpn

# qBittorrent
QB_WEBUI_PORT=8080
QB_CONNECTION_PORT=6881

# Radarr
RADARR_HD_PORT=7878
RADARR_4K_PORT=7879

# Sonarr
SONARR_HD_PORT=8989
SONARR_4K_PORT=8990

# Jackett
JACKETT_PORT=9117

# FlareSolverr
FLARESOLVERR_PORT=8191

# Seerr
SEERR_PORT=5055

# Nginx Proxy Manager
NPM_PORT_80=80
NPM_PORT_443=443
NPM_PORT_ADMIN=81

# Authelia
AUTHELIA_PORT=9091

# API Keys (generate these!)
RADARR_HD_API_KEY=
RADARR_4K_API_KEY=
SONARR_HD_API_KEY=
SONARR_4K_API_KEY=

# Recyclarr
RECYCLARR_SYNC_SCHEDULE=0 2 * * *
```

Create example file:
```bash
cp /opt/mother/.env /opt/mother/.env.example
# Remove sensitive values from .env.example
```

## Docker Compose Configuration

### Main docker-compose.yml
Create `/opt/mother/docker-compose.yml`:

```yaml
version: "3.8"

########################### NETWORKS
networks:
  mother-network:
    external: true
  nginx-proxy:
    external: true

########################### SERVICES
services:

  ########################### NGINX PROXY MANAGER
  nginx-proxy-manager:
    image: jc21/nginx-proxy-manager:latest
    container_name: nginx-proxy-manager
    restart: unless-stopped
    networks:
      - nginx-proxy
      - mother-network
    ports:
      - ${NPM_PORT_80}:80
      - ${NPM_PORT_443}:443
      - ${NPM_PORT_ADMIN}:81
    volumes:
      - ./configs/nginx/data:/data
      - ./configs/nginx/letsencrypt:/etc/letsencrypt
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}

  ########################### AUTHELIA
  authelia:
    image: authelia/authelia:latest
    container_name: authelia
    restart: unless-stopped
    networks:
      - nginx-proxy
    ports:
      - ${AUTHELIA_PORT}:9091
    volumes:
      - ./configs/authelia:/config
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}

  ########################### RADARR HD
  radarr-hd:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr-hd
    restart: unless-stopped
    networks:
      - mother-network
      - nginx-proxy
    ports:
      - ${RADARR_HD_PORT}:7878
    volumes:
      - ./configs/radarr-hd:/config
      - ${MOVIES_HD_PATH}:/movies
      - ${DOWNLOADS_PATH}:/downloads
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}

  ########################### RADARR 4K
  radarr-4k:
    image: lscr.io/linuxserver/radarr:latest
    container_name: radarr-4k
    restart: unless-stopped
    networks:
      - mother-network
      - nginx-proxy
    ports:
      - ${RADARR_4K_PORT}:7878
    volumes:
      - ./configs/radarr-4k:/config
      - ${MOVIES_4K_PATH}:/movies
      - ${DOWNLOADS_PATH}:/downloads
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}

  ########################### SONARR HD
  sonarr-hd:
    image: lscr.io/linuxserver/sonarr:latest
    container_name: sonarr-hd
    restart: unless-stopped
    networks:
      - mother-network
      - nginx-proxy
    ports:
      - ${SONARR_HD_PORT}:8989
    volumes:
      - ./configs/sonarr-hd:/config
      - ${TV_HD_PATH}:/tv
      - ${DOWNLOADS_PATH}:/downloads
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}

  ########################### SONARR 4K
  sonarr-4k:
    image: lscr.io/linuxserver/sonarr:latest
    container_name: sonarr-4k
    restart: unless-stopped
    networks:
      - mother-network
      - nginx-proxy
    ports:
      - ${SONARR_4K_PORT}:8989
    volumes:
      - ./configs/sonarr-4k:/config
      - ${TV_4K_PATH}:/tv
      - ${DOWNLOADS_PATH}:/downloads
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}

  ########################### QBITTORRENT
  qbittorrent:
    image: lscr.io/linuxserver/qbittorrent:latest
    container_name: qbittorrent
    restart: unless-stopped
    networks:
      - mother-network
      - nginx-proxy
    ports:
      - ${QB_WEBUI_PORT}:8080
      - ${QB_CONNECTION_PORT}:6881
      - ${QB_CONNECTION_PORT}:6881/udp
    volumes:
      - ./configs/qbittorrent:/config
      - ${DOWNLOADS_PATH}:/downloads
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
      - WEBUI_PORT=8080

  ########################### CROSS-SEED
  cross-seed:
    image: crossseed/cross-seed:latest
    container_name: cross-seed
    restart: unless-stopped
    networks:
      - mother-network
    ports:
      - 2468:2468
    volumes:
      - ./configs/cross-seed:/config
      - ${DOWNLOADS_PATH}:/downloads
      - ./configs/cross-seed/cache:/cache
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}

  ########################### RECYCLARR
  recyclarr:
    image: ghcr.io/recyclarr/recyclarr:latest
    container_name: recyclarr
    restart: unless-stopped
    networks:
      - mother-network
    volumes:
      - ./configs/recyclarr:/config
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
      - CRON_SCHEDULE=${RECYCLARR_SYNC_SCHEDULE}

  ########################### JACKETT
  jackett:
    image: lscr.io/linuxserver/jackett:latest
    container_name: jackett
    restart: unless-stopped
    networks:
      - mother-network
      - nginx-proxy
    ports:
      - ${JACKETT_PORT}:9117
    volumes:
      - ./configs/jackett:/config
      - ${DOWNLOADS_PATH}:/downloads
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
      - AUTO_UPDATE=true

  ########################### FLARESOLVERR
  flaresolverr:
    image: ghcr.io/flaresolverr/flaresolverr:latest
    container_name: flaresolverr
    restart: unless-stopped
    networks:
      - mother-network
    ports:
      - ${FLARESOLVERR_PORT}:8191
    environment:
      - LOG_LEVEL=info
      - TZ=${TZ}

  ########################### SEERR (Chris's Instance)
  seerr:
    image: ghcr.io/seerr-team/seerr:latest
    container_name: seerr
    restart: unless-stopped
    networks:
      - mother-network
      - nginx-proxy
    ports:
      - ${SEERR_PORT}:5055
    volumes:
      - ./configs/seerr:/app/config
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
```

## Application-Specific Configurations

### qBittorrent Configuration

#### Configure After First Start
1. Access WebUI: `http://10.0.1.10:8080`
2. Default credentials: `admin` / `adminadmin`
3. **Change password immediately!**

#### Settings to Configure:
- **Downloads**:
  - Default Save Path: `/downloads/complete`
  - Keep incomplete in: `/downloads/incomplete`
  - Copy .torrent files to: `/downloads/torrents`
  - Auto Management Mode: Off (let Radarr/Sonarr control)
  
- **Connection**:
  - Port: 6881
  - UPnP/NAT-PMP: Disable (using firewall rules)
  
- **Speed**:
  - Global rate limits based on your connection
  - Upload: 90 MB/s (720 Mbps)
  - Download: 90 MB/s (720 Mbps)
  
- **BitTorrent**:
  - DHT: Enable
  - PeX: Enable
  - LPD: Enable
  - Encryption: Require encryption
  
- **Advanced**:
  - Network Interface: eth0
  - Optional IP address to bind to: Leave blank

#### Categories for Auto-Management
Create categories matching Radarr/Sonarr:
- `radarr-hd`
- `radarr-4k`
- `sonarr-hd`
- `sonarr-4k`

Each category uses `/downloads` as save path.

#### Torrent Retention Configuration

**Option 1: Built-in qBittorrent Auto-Delete**
- **Settings → BitTorrent → Seeding Limits**:
  - When ratio reaches: 2.0 (or unlimited if sharing on private trackers)
  - When seeding time reaches: 129600 minutes (90 days) OR 172800 (120 days)
  - Then: Remove torrent

**Option 2: External Script** (more flexible)
Create `/opt/mother/scripts/cleanup_torrents.sh`:
```bash
#!/bin/bash
# Clean up torrents older than specified days
# Add to crontab: 0 3 * * * /opt/mother/scripts/cleanup_torrents.sh

QBITTORRENT_HOST="http://localhost:8080"
USERNAME="admin"
PASSWORD="your_password"
MAX_AGE_DAYS=90

# Login and get cookie
COOKIE=$(curl -s -i --data "username=${USERNAME}&password=${PASSWORD}" \
  "${QBITTORRENT_HOST}/api/v2/auth/login" | grep -oP 'SID=\K[^;]+')

# Get torrent list
TORRENTS=$(curl -s -b "SID=${COOKIE}" "${QBITTORRENT_HOST}/api/v2/torrents/info")

# Parse and remove old torrents
# (Implementation needed using jq)
echo "Cleanup complete"
```

### Radarr Configuration

#### Post-Installation Setup
1. Access WebUI: `http://10.0.1.10:7878`
2. Complete setup wizard
3. **Media Management**:
   - **Root Folders**: 
     - `/movies`
   - **File Management**:
     - Rename Movies: Yes
     - Replace Illegal Characters: Yes
     - Colon Replacement: Space Dash Space
   - **File Naming**: (Use TRASHGuides recommendations)
     - Movie Title
     - Movie Year
     - Quality Full
     - MediaInfo Simple
   - **Importing**:
     - Use Hardlinks: **NO** (we're using copy)
     - Import Extra Files: Yes (subs, nfo)
   - **Permissions**:
     - Set Permissions: No (handled by Docker)

4. **Download Clients**:
   - Add qBittorrent:
     - Host: qbittorrent
     - Port: 8080
     - Username/Password
     - Category: `radarr-hd` or `radarr-4k`
     - Remove Completed: No (keep for seeding)
     - Remove Failed: Yes

5. **Indexers**:
   - Add Jackett indexers
   - Or wait for Recyclarr to configure

6. **Connect**:
   - Custom Script (for notifications)
   - Webhook (for Discord/Telegram)

### Recyclarr Configuration

#### Create config file: `./configs/recyclarr/recyclarr.yml`

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/recyclarr/recyclarr/master/schemas/config-schema.json

radarr:
  radarr-hd:
    base_url: http://radarr-hd:7878
    api_key: !env RADARR_HD_API_KEY

    quality_definition:
      type: movie
      preferred_ratio: 0.5

    quality_profiles:
      - name: HD Bluray + WEB
        reset_unmatched_scores:
          enabled: true
        upgrade:
          allowed: true
          until_quality: Bluray-1080p
          until_score: 10000
        min_format_score: 0
        quality_sort: top
        qualities:
          - name: Bluray-1080p
            qualities:
              - Bluray-1080p
              - Remux-1080p
          - name: WEB 1080p
            qualities:
              - WEBRip-1080p
              - WEBDL-1080p
          - name: Bluray-720p
          - name: WEB 720p
            qualities:
              - WEBRip-720p
              - WEBDL-720p

    custom_formats:
      # HDR Formats - Prefer HDR over DV
      - trash_ids:
          - e23edd2482476e595fb990b12e7c609c  # DV HDR10
          - 58d6a88f13e2db7f5059c41047876f00  # DV
        assign_scores_to:
          - name: HD Bluray + WEB
            score: 50

      - trash_ids:
          - e61e28db95d22bedcadf030b8f156d96  # HDR
          - 2a4d9069cc1fe3242ff9bdaebed239bb  # HDR (undefined)
        assign_scores_to:
          - name: HD Bluray + WEB
            score: 75

      # Audio
      - trash_ids:
          - 496f355514737f7d83bf7aa4d24f8169  # TrueHD Atmos
          - 2f22d89048b01681dde8afe203bf2e95  # DTS X
          - 417804f7f2c4308c1f4c5d380d4c4475  # ATMOS (undefined)
        assign_scores_to:
          - name: HD Bluray + WEB
            score: 100

      - trash_ids:
          - 1af239278386be2919e1bcee0bde047e  # DD+ Atmos
          - 185f1dd7264c4562b9022d963ac37424  # DD+
        assign_scores_to:
          - name: HD Bluray + WEB
            score: 75

      # Streaming Services
      - trash_ids:
          - b3b3a6ac74ecbd56bcdbefa4799fb9df  # REMUX Tier 01
          - c20f169ef63c5f40c2def54abaf4438e  # WEB Tier 01
          - 403816d65392c79236dcb6dd591aeda4  # WEB Tier 02
        assign_scores_to:
          - name: HD Bluray + WEB

      # Release Groups (add your preferred groups)
      - trash_ids:
          - ed27ebfef2f323e964fb1f61391bcb35  # HD Bluray Tier 01
          - c20c8647f2bd1c2083df7a2a7c26b64d  # HD Bluray Tier 02
        assign_scores_to:
          - name: HD Bluray + WEB

      # Unwanted
      - trash_ids:
          - 90cedc1fea7ea5d11298bebd3d1d3223  # EVO (no WEBDL)
          - ae9b7c9ebde1f3bd336a8cbd1ec4c5e5  # No-RlsGroup
          - 7357cf5161efbf8c4d5d0c30b4815ee2  # Obfuscated
          - 5c44f52a8714fdd79bb4d98e2673be1f  # Retags
        assign_scores_to:
          - name: HD Bluray + WEB
            score: -10000

  radarr-4k:
    base_url: http://radarr-4k:7878
    api_key: !env RADARR_4K_API_KEY

    quality_definition:
      type: movie
      preferred_ratio: 0.5

    quality_profiles:
      - name: 4K Bluray + WEB
        reset_unmatched_scores:
          enabled: true
        upgrade:
          allowed: true
          until_quality: Bluray-2160p
          until_score: 10000
        min_format_score: 0
        quality_sort: top
        qualities:
          - name: Bluray-2160p
            qualities:
              - Bluray-2160p
              - Remux-2160p
          - name: WEB 2160p
            qualities:
              - WEBRip-2160p
              - WEBDL-2160p

    custom_formats:
      # 4K HDR Formats
      - trash_ids:
          - e23edd2482476e595fb990b12e7c609c  # DV HDR10
          - 58d6a88f13e2db7f5059c41047876f00  # DV
        assign_scores_to:
          - name: 4K Bluray + WEB
            score: 100

      - trash_ids:
          - e61e28db95d22bedcadf030b8f156d96  # HDR
          - 2a4d9069cc1fe3242ff9bdaebed239bb  # HDR (undefined)
        assign_scores_to:
          - name: 4K Bluray + WEB
            score: 150  # Prefer HDR over DV for 4K

      # Rest similar to HD config...

sonarr:
  sonarr-hd:
    base_url: http://sonarr-hd:8989
    api_key: !env SONARR_HD_API_KEY

    quality_definition:
      type: series
      preferred_ratio: 0.5

    quality_profiles:
      - name: HD WEB + Bluray
        # Similar structure to Radarr
        qualities:
          - name: Bluray-1080p
          - name: WEB 1080p
          - name: HDTV-1080p

  sonarr-4k:
    base_url: http://sonarr-4k:8989
    api_key: !env SONARR_4K_API_KEY
    # Similar to sonarr-hd but for 4K
```

#### Recyclarr Setup Steps
1. Generate API keys from each *arr instance
2. Add to `.env` file
3. Update `recyclarr.yml` configuration
4. Run initial sync:
   ```bash
   docker exec recyclarr recyclarr sync
   ```
5. Schedule automatic syncs (already in compose via CRON_SCHEDULE)

### Cross-Seed Configuration

#### Create config: `./configs/cross-seed/config.js`
```javascript
module.exports = {
  delay: 30,
  qbittorrentUrl: "http://qbittorrent:8080",
  torznab: [
    // Add your indexer URLs (via Jackett)
    "http://jackett:9117/api/v2.0/indexers/YOUR_INDEXER/results/torznab/",
  ],
  outputDir: "/downloads/cross-seed",
  includeEpisodes: true,
  includeNonVideos: false,
  duplicateCategories: true,
  linkCategory: "cross-seed",
  linkType: "hardlink", // Won't work across devices, may need to use "copy"
  dataDirs: [
    "/downloads/complete",
  ],
  matchMode: "safe",
  skipRecheck: true,
  maxDataDepth: 3,
  torrentDir: "/downloads/torrents",
  action: "inject",
  rtorrentRpcUrl: null,
  transmissionRpcUrl: null,
  delugeRpcUrl: null,
};
```

Note: Since we're using COPY instead of hardlinks, cross-seed may create duplicate data. Monitor storage usage.

## Docker Management

### Start Services
```bash
cd /opt/mother
docker-compose up -d
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f radarr-hd

# Last 50 lines
docker-compose logs --tail=50 qbittorrent
```

### Restart Service
```bash
docker-compose restart radarr-hd
```

### Update Containers
```bash
# Pull latest images
docker-compose pull

# Recreate containers
docker-compose up -d

# Clean up old images
docker image prune -f
```

### Stop All Services
```bash
docker-compose down
```

## Backup Configuration

See `scripts/backup.sh` for automated backup script.

```bash
#!/bin/bash
# Backup all configs
tar -czf /backups/mother-configs-$(date +%Y%m%d).tar.gz \
  /opt/mother/configs/ \
  /opt/mother/.env \
  /opt/mother/docker-compose.yml
```

## Monitoring

### Resource Usage
```bash
# Container stats
docker stats

# Disk usage
docker system df
```

### Health Checks
```bash
# Check running containers
docker ps

# Check container health
docker inspect --format='{{.State.Health.Status}}' radarr-hd
```

## Next Steps
1. ⏳ Create directory structure
2. ⏳ Create .env file with all variables
3. ⏳ Create docker-compose.yml
4. ⏳ Start services
5. ⏳ Configure each application
6. ⏳ Setup Recyclarr
7. ⏳ Configure qBittorrent retention
8. ⏳ Test download workflow
9. ⏳ Verify file copying works
10. ⏳ Setup monitoring
