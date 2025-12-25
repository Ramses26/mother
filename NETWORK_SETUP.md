# Network Setup - Project Mother

## Overview
This document covers all networking, VPN, SSH, and connectivity configuration for Project Mother.

## Network Topology

```
Internet
    │
    ├─── Your Location (192.168.1.0/24)
    │    ├─── Unraid: 192.168.1.10
    │    ├─── Terminus: 192.168.1.14
    │    └─── UniFi UCG: 74.215.149.185 (WAN)
    │
    └─── Chris's Location (10.0.0.0/23)
         ├─── Mother: TBD (10.0.x.x)
         ├─── RS-4KMedia: 10.0.1.203
         ├─── RS-TV: 10.0.0.88
         ├─── RS-Movies: 10.0.0.160
         └─── UniFi UCG: 74.83.151.194 (WAN)

VPN Tunnel (IPsec)
192.168.1.0/24 ←→ 10.0.0.0/23
```

## VPN Configuration

### Current Setup (IPsec Site-to-Site)
- **Protocol**: IPsec
- **Equipment**: UniFi UCG (both sides)
- **VPN Method**: Route-Based
- **Remote Networks**: Static route for 10.0.0.0/23

#### Your Side Configuration
- **Local IP (WAN)**: 74.215.149.185
- **Remote IP**: 74.83.151.194
- **Local Network**: 192.168.1.0/24
- **Remote Network**: 10.0.0.0/23

#### Encryption Settings
- **IKE**: IKEv2
  - Encryption: AES-256
  - Hash: SHA512
  - DH Group: 14
  - Lifetime: 28800
- **ESP**:
  - Encryption: AES-256
  - Hash: SHA512
  - DH Group: 14
  - Lifetime: 3600
- **Perfect Forward Secrecy (PFS)**: Enabled
- **MTU**: 1419 bytes

#### Bandwidth
- **Your Location**: 800/800 Mbps (Altafiber)
- **Chris's Location**: 800/800 Mbps (Altafiber)
- **Effective VPN Throughput**: ~700-750 Mbps (after overhead)

### Testing VPN Connectivity

```bash
# From your network, test Chris's devices
ping 10.0.1.203  # RS-4KMedia
ping 10.0.0.88   # RS-TV
ping 10.0.0.160  # RS-Movies

# From Chris's network, test your devices
ping 192.168.1.10  # Unraid
ping 192.168.1.14  # Terminus

# Speed test across VPN
iperf3 -s  # On one side
iperf3 -c <remote_ip>  # On other side
```

## Mother Server Network Configuration

### IP Address Assignment
**Recommended**: Static IP in 10.0.0.0/23 range
- **Suggested IP**: 10.0.1.10 (easy to remember)
- **Hostname**: mother
- **FQDN**: mother.stuttler.net (optional)

### Ubuntu Network Configuration

#### Using Netplan (Ubuntu 24.04)
**File**: `/etc/netplan/00-installer-config.yaml`

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens192:  # Interface name may vary
      addresses:
        - 10.0.1.10/23
      routes:
        - to: default
          via: 10.0.0.1  # Chris's gateway
      nameservers:
        addresses:
          - 1.1.1.1
          - 8.8.8.8
        search:
          - stuttler.net
```

Apply configuration:
```bash
sudo netplan apply
```

#### Set Hostname
```bash
sudo hostnamectl set-hostname mother
echo "10.0.1.10 mother mother.stuttler.net" | sudo tee -a /etc/hosts
```

### Firewall Configuration (UFW)

#### Enable UFW
```bash
sudo ufw enable
sudo ufw default deny incoming
sudo ufw default allow outgoing
```

#### Allow SSH
```bash
sudo ufw allow from 192.168.1.0/24 to any port 22
sudo ufw allow from 10.0.0.0/23 to any port 22
```

#### Allow Docker Services (later)
```bash
# Web interfaces (Nginx Proxy Manager will handle)
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# qBittorrent (if direct access needed)
sudo ufw allow from 10.0.0.0/23 to any port 8080

# *arr apps (internal only)
# Radarr: 7878
# Sonarr: 8989
# These will be accessed via Nginx
```

#### Allow VPN Traffic
```bash
# Already handled by UniFi UCG, but document for reference
# IPsec uses UDP 500, 4500 and ESP protocol
```

### DNS Configuration

#### Update DNS Records (if using)
```
mother.stuttler.net  A  10.0.1.10
```

#### Local DNS Resolution
Add to `/etc/hosts` on all machines:
```
# Mother Server
10.0.1.10  mother mother.stuttler.net

# Synology Devices
10.0.1.203  rs-4kmedia
10.0.0.88   rs-tv
10.0.0.160  rs-movies

# Your Network
192.168.1.10  unraid
192.168.1.14  terminus
```

## SSH Configuration

### SSH Key Generation

#### On Your WSL (if not already existing)
```bash
# Check for existing keys
ls -la ~/.ssh/

# Generate new key pair (if needed)
ssh-keygen -t ed25519 -C "mother-project" -f ~/.ssh/mother_ed25519

# Start ssh-agent
eval "$(ssh-agent -s)"

# Add key to agent
ssh-add ~/.ssh/mother_ed25519
```

### SSH Key Distribution

#### 1. Your WSL → Mother Server
```bash
# Copy public key to Mother
ssh-copy-id -i ~/.ssh/mother_ed25519.pub user@10.0.1.10

# Or manually
cat ~/.ssh/mother_ed25519.pub | ssh user@10.0.1.10 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

#### 2. Your WSL → GitHub
```bash
# Display public key
cat ~/.ssh/mother_ed25519.pub

# Add to GitHub: Settings → SSH and GPG keys → New SSH key
# Or use GitHub CLI
gh ssh-key add ~/.ssh/mother_ed25519.pub --title "Mother Project"
```

#### 3. Mother → GitHub
```bash
# On Mother server
ssh-keygen -t ed25519 -C "mother-server-github" -f ~/.ssh/github_ed25519

# Display public key
cat ~/.ssh/github_ed25519.pub

# Add to GitHub (deploy key or account key)
```

#### 4. Mother → Synology Devices
```bash
# On Mother, copy key to each Synology
ssh-copy-id -i ~/.ssh/id_ed25519.pub admin@10.0.1.203  # RS-4KMedia
ssh-copy-id -i ~/.ssh/id_ed25519.pub admin@10.0.0.88   # RS-TV
ssh-copy-id -i ~/.ssh/id_ed25519.pub admin@10.0.0.160  # RS-Movies
```

#### 5. Mother → Your Unraid
```bash
# From Mother
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@192.168.1.10
```

### SSH Config Files

#### On Your WSL (~/.ssh/config)
```
# Mother Server
Host mother
    HostName 10.0.1.10
    User <username>
    IdentityFile ~/.ssh/mother_ed25519
    ForwardAgent yes

# Terminus
Host terminus
    HostName 192.168.1.14
    User alig
    IdentityFile ~/.ssh/id_ed25519

# Unraid
Host unraid
    HostName 192.168.1.10
    User root
    IdentityFile ~/.ssh/id_ed25519

# GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/mother_ed25519
```

#### On Mother (~/.ssh/config)
```
# Synology Devices
Host rs-4kmedia
    HostName 10.0.1.203
    User admin
    IdentityFile ~/.ssh/id_ed25519

Host rs-tv
    HostName 10.0.0.88
    User admin
    IdentityFile ~/.ssh/id_ed25519

Host rs-movies
    HostName 10.0.0.160
    User admin
    IdentityFile ~/.ssh/id_ed25519

# Unraid
Host unraid
    HostName 192.168.1.10
    User root
    IdentityFile ~/.ssh/id_ed25519

# GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_ed25519
```

### SSH Hardening

#### On Mother Server
Edit `/etc/ssh/sshd_config`:
```bash
# Disable password authentication
PasswordAuthentication no
PubkeyAuthentication yes

# Disable root login (use sudo instead)
PermitRootLogin no

# Only allow specific users
AllowUsers <your_username>

# Change default port (optional, add UFW rule if changed)
# Port 2222

# Disable X11 forwarding (if not needed)
X11Forwarding no

# Set idle timeout
ClientAliveInterval 300
ClientAliveCountMax 2
```

Restart SSH:
```bash
sudo systemctl restart sshd
```

## Storage Mounts

### NFS vs SMB/CIFS
**Recommendation**: Use NFS for Linux-to-Linux/Synology connections (better performance)

### Synology NFS Setup

#### Enable NFS on Synology Devices
1. **Control Panel → File Services → NFS**
   - Enable NFS service
   - NFSv4 support: Enable
   - Enable NFSv4.1

2. **Control Panel → Shared Folder**
   - For each share (downloads, 4KMovies, 4ktv, tv, movies)
   - Edit → NFS Permissions → Create
   - Server: 10.0.1.10 (Mother's IP)
   - Privilege: Read/Write
   - Squash: Map all users to admin
   - Security: sys
   - Enable asynchronous
   - Allow non-privileged ports

### Mount Synology Shares on Mother

#### Install NFS Client
```bash
sudo apt update
sudo apt install nfs-common -y
```

#### Create Mount Points
```bash
sudo mkdir -p /mnt/synology/{downloads,4kmovies,4ktv,tv,movies}
```

#### Manual Mount (for testing)
```bash
# RS-4KMedia
sudo mount -t nfs -o vers=4.1 10.0.1.203:/volume1/downloads /mnt/synology/downloads
sudo mount -t nfs -o vers=4.1 10.0.1.203:/volume1/4KMovies /mnt/synology/4kmovies
sudo mount -t nfs -o vers=4.1 10.0.1.203:/volume1/4ktv /mnt/synology/4ktv

# RS-TV
sudo mount -t nfs -o vers=4.1 10.0.0.88:/volume1/tv /mnt/synology/tv

# RS-Movies
sudo mount -t nfs -o vers=4.1 10.0.0.160:/volume1/movies /mnt/synology/movies
```

#### Permanent Mounts (/etc/fstab)
```bash
# Add to /etc/fstab
10.0.1.203:/volume1/downloads /mnt/synology/downloads nfs vers=4.1,rw,hard,intr,rsize=8192,wsize=8192,timeo=14 0 0
10.0.1.203:/volume1/4KMovies /mnt/synology/4kmovies nfs vers=4.1,rw,hard,intr,rsize=8192,wsize=8192,timeo=14 0 0
10.0.1.203:/volume1/4ktv /mnt/synology/4ktv nfs vers=4.1,rw,hard,intr,rsize=8192,wsize=8192,timeo=14 0 0
10.0.0.88:/volume1/tv /mnt/synology/tv nfs vers=4.1,rw,hard,intr,rsize=8192,wsize=8192,timeo=14 0 0
10.0.0.160:/volume1/movies /mnt/synology/movies nfs vers=4.1,rw,hard,intr,rsize=8192,wsize=8192,timeo=14 0 0
```

Mount all:
```bash
sudo mount -a
```

#### Verify Mounts
```bash
df -h | grep synology
mount | grep nfs
```

### Mount Unraid on Mother (for sync verification)

#### SMB/CIFS Mount (Unraid typically uses SMB)
```bash
# Install CIFS utilities
sudo apt install cifs-utils -y

# Create mount point
sudo mkdir -p /mnt/unraid/media

# Create credentials file
sudo nano /root/.smbcredentials
```

**Content of `/root/.smbcredentials`**:
```
username=<unraid_user>
password=<unraid_password>
```

```bash
sudo chmod 600 /root/.smbcredentials
```

**Add to `/etc/fstab`**:
```
//192.168.1.10/media /mnt/unraid/media cifs credentials=/root/.smbcredentials,uid=1000,gid=1000,iocharset=utf8 0 0
```

Mount:
```bash
sudo mount -a
```

## Docker Network Configuration

### Docker Installation
```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add user to docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install docker-compose-plugin -y
```

### Docker Networks

#### Create Custom Bridge Network
```bash
docker network create \
  --driver=bridge \
  --subnet=172.20.0.0/16 \
  --gateway=172.20.0.1 \
  mother-network
```

#### Network for Proxy
```bash
docker network create nginx-proxy
```

### Docker Compose Network Configuration
```yaml
networks:
  mother-network:
    external: true
  nginx-proxy:
    external: true
```

## Port Mapping Reference

### Internal Ports (Docker)
```
Nginx Proxy Manager:  80, 443, 81 (admin)
Radarr-HD:           7878
Radarr-4K:           7879
Sonarr-HD:           8989
Sonarr-4K:           8990
qBittorrent:         8080 (WebUI), 6881 (torrents)
Recyclarr:           N/A (runs as cron)
Seerr (Chris):       5055
FlareSolverr:        8191
Jackett:             9117
Authelia:            9091
```

### External Access (via Nginx)
```
seerr.stuttler.net   → Seerr
radarr.stuttler.net  → Radarr-HD (auth required)
sonarr.stuttler.net  → Sonarr-HD (auth required)
mother.stuttler.net  → Nginx dashboard
```

## Network Security Checklist

- [ ] VPN tunnel tested and stable
- [ ] SSH keys distributed (password auth disabled)
- [ ] UFW enabled with proper rules
- [ ] NFS shares configured with IP restrictions
- [ ] SMB credentials secured (600 permissions)
- [ ] Docker networks isolated
- [ ] Nginx Proxy Manager configured with SSL
- [ ] Authelia/Authentik protecting external services
- [ ] No default passwords on any service
- [ ] Regular security updates scheduled

## Troubleshooting

### VPN Connection Issues
```bash
# Check VPN status on UniFi
# Network → VPN → Site-to-Site

# Test connectivity
ping 10.0.1.203
traceroute 10.0.1.203

# Check routing
ip route show

# Test bandwidth
iperf3 -s  # On remote
iperf3 -c <remote_ip> -t 30  # On local
```

### NFS Mount Issues
```bash
# Check NFS service
showmount -e 10.0.1.203

# Check mount status
mount | grep nfs

# Remount
sudo umount /mnt/synology/downloads
sudo mount -a

# Check NFS logs
sudo journalctl -u nfs-client.target
```

### SSH Connection Issues
```bash
# Verbose SSH
ssh -v user@10.0.1.10

# Check SSH service
sudo systemctl status sshd

# Check firewall
sudo ufw status

# Test from different networks
```

## Performance Optimization

### NFS Tuning
```bash
# In /etc/fstab, use these options:
vers=4.1,rw,hard,intr,rsize=131072,wsize=131072,timeo=600,retrans=2,_netdev

# For better performance over VPN
```

### Network Tuning (if needed)
```bash
# Increase network buffers
sudo sysctl -w net.core.rmem_max=134217728
sudo sysctl -w net.core.wmem_max=134217728
sudo sysctl -w net.ipv4.tcp_rmem='4096 87380 67108864'
sudo sysctl -w net.ipv4.tcp_wmem='4096 65536 67108864'

# Make permanent in /etc/sysctl.conf
```

## Network Monitoring

### Tools to Install
```bash
sudo apt install -y \
  iftop \
  nethogs \
  iperf3 \
  nload \
  vnstat
```

### Monitor Network Usage
```bash
# Real-time bandwidth by process
sudo nethogs

# Network speed
nload

# VPN tunnel traffic
sudo iftop -i <vpn_interface>
```

## Next Steps
1. ✅ Document network topology
2. ⏳ Configure Mother server IP address
3. ⏳ Test VPN connectivity
4. ⏳ Distribute SSH keys
5. ⏳ Configure NFS on Synology devices
6. ⏳ Mount all shares on Mother
7. ⏳ Test read/write access
8. ⏳ Configure Docker networks
9. ⏳ Setup firewall rules
10. ⏳ Performance testing
