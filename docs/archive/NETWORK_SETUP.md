# Network Setup - Project Mother

**Last Updated:** 2024-12-23

---

## Table of Contents
- [Network Topology](#network-topology)
- [VPN Configuration](#vpn-configuration)
- [IP Address Allocation](#ip-address-allocation)
- [Firewall Rules](#firewall-rules)
- [DNS Configuration](#dns-configuration)
- [SSH Key Setup](#ssh-key-setup)
- [Testing & Validation](#testing--validation)

---

## Network Topology

```
Internet
    │
    ├─── Ali's Location (74.215.149.185)
    │     │
    │     └─── Unifi UCG ─── 192.168.1.0/24
    │              │
    │              ├─── Unraid (192.168.1.10)
    │              ├─── Terminus (192.168.1.14)
    │              └─── Other devices
    │
    │                IPsec VPN Tunnel
    │                      ═══
    │
    └─── Chris's Location (74.83.151.194)
          │
          └─── Unifi UCG ─── 10.0.0.0/23
                   │
                   ├─── ESX Host (10.0.x.x)
                   │      │
                   │      └─── Mother VM (10.0.x.x) [TBD]
                   │
                   ├─── RS-4KMedia (10.0.1.203)
                   ├─── RS-TV (10.0.0.88)
                   └─── RS-Movies (10.0.0.160)
```

---

## VPN Configuration

### Current IPsec Site-to-Site VPN

**Configuration Details:**
```
VPN Type: IPsec
Method: Route-based
Local IP: 74.215.149.185 (Ali's WAN)
Remote IP: 74.83.151.194 (Chris's WAN)
Remote Networks: 10.0.0.0/23 (Static)
Encryption: AES-256
Hash: SHA512
DH Group: 14
Perfect Forward Secrecy: Enabled
```

**Bandwidth:**
- Both sides: 800 Mbps / 800 Mbps (Altafiber)
- Expected VPN throughput: ~600-750 Mbps (accounting for encryption overhead)

### Routing

**Ali's Side:**
```bash
# Route to Chris's network
Destination: 10.0.0.0/23
Gateway: VPN Tunnel
```

**Chris's Side:**
```bash
# Route to Ali's network (assumed)
Destination: 192.168.1.0/24
Gateway: VPN Tunnel
```

### Connectivity Testing

**From Ali's Network:**
```bash
# Test ping to Chris's Synology devices
ping 10.0.1.203  # RS-4KMedia
ping 10.0.0.88   # RS-TV
ping 10.0.0.160  # RS-Movies

# Test SMB connectivity
smbclient -L //10.0.1.203 -U <username>

# Test bandwidth
iperf3 -c 10.0.1.203  # If iperf3 server running on Synology
```

**From Chris's Network:**
```bash
# Test ping to Ali's Unraid
ping 192.168.1.10

# Test bandwidth
iperf3 -c 192.168.1.10
```

---

## IP Address Allocation

### Chris's Network (10.0.0.0/23)

| Device | IP Address | Purpose | Notes |
|--------|------------|---------|-------|
| ESX Host | TBD | Hypervisor | |
| **Mother VM** | **TBD** | **Media server** | **Needs static assignment** |
| RS-4KMedia | 10.0.1.203 | 4K content + downloads | Static |
| RS-TV | 10.0.0.88 | HD TV shows | Static |
| RS-Movies | 10.0.0.160 | HD movies | Static |

**Recommended Mother IP:** 10.0.1.10 or 10.0.0.10 (memorable, low number)

### Ali's Network (192.168.1.0/24)

| Device | IP Address | Purpose | Notes |
|--------|------------|---------|-------|
| Unraid | 192.168.1.10 | Media storage | Static |
| Terminus | 192.168.1.14 | Docker server | Static |

### External Access

| Purpose | Current IP | New IP (Post-Migration) |
|---------|------------|-------------------------|
| Private Trackers | 74.215.149.185 | 74.83.151.194 |
| External Seerr Access | 74.215.149.185 | TBD (via NPM on Mother) |

---

## Firewall Rules

### Mother Server (Ubuntu ufw)

```bash
# Allow SSH from management networks
sudo ufw allow from 192.168.1.0/24 to any port 22 proto tcp
sudo ufw allow from 10.0.0.0/23 to any port 22 proto tcp

# Allow Docker services (internal only initially)
# Radarr-HD
sudo ufw allow from 10.0.0.0/23 to any port 7878 proto tcp
sudo ufw allow from 192.168.1.0/24 to any port 7878 proto tcp

# Radarr-4K
sudo ufw allow from 10.0.0.0/23 to any port 7879 proto tcp
sudo ufw allow from 192.168.1.0/24 to any port 7879 proto tcp

# Sonarr-HD
sudo ufw allow from 10.0.0.0/23 to any port 8989 proto tcp
sudo ufw allow from 192.168.1.0/24 to any port 8989 proto tcp

# Sonarr-4K
sudo ufw allow from 10.0.0.0/23 to any port 8990 proto tcp
sudo ufw allow from 192.168.1.0/24 to any port 8990 proto tcp

# qBittorrent Web UI
sudo ufw allow from 10.0.0.0/23 to any port 8080 proto tcp
sudo ufw allow from 192.168.1.0/24 to any port 8080 proto tcp

# qBittorrent incoming connections (if not using VPN)
sudo ufw allow 6881/tcp
sudo ufw allow 6881/udp

# Nginx Proxy Manager
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow from 10.0.0.0/23 to any port 81 proto tcp  # Admin UI

# Enable firewall
sudo ufw enable
```

### Unifi UCG Rules

**Chris's UCG (for external Seerr access):**
```
Port Forward:
- External Port: 443
- Internal IP: Mother IP (10.0.x.x)
- Internal Port: 443
- Protocol: TCP
- Description: Seerr External Access
```

**Ali's UCG:**
- No additional rules needed (outbound connections only)

---

## DNS Configuration

### Internal DNS (Recommended)

**Option 1: Local hosts file on Mother:**
```bash
# /etc/hosts
10.0.1.203    rs-4kmedia rs-4kmedia.local
10.0.0.88     rs-tv rs-tv.local
10.0.0.160    rs-movies rs-movies.local
192.168.1.10  unraid unraid.local
192.168.1.14  terminus terminus.local
```

**Option 2: Use IPs directly in configs**
- More portable
- No DNS dependencies
- Recommended for docker-compose

### External DNS (for Seerr)

If using custom domain for external access:
```
seerr.yourdomain.com → Chris's Public IP (74.83.151.194)
    ↓ Port Forward
    Mother's Nginx Proxy Manager → Seerr-Ali container
```

**Alternative:** Use Cloudflare Tunnel (no port forwarding needed)

---

## SSH Key Setup

### 1. WSL → Mother SSH Access

**On WSL (Ali's machine):**
```bash
# Generate SSH key if not already present
ssh-keygen -t ed25519 -C "ali@mother-project"
# Save to: /home/alig/.ssh/id_mother

# Copy public key to Mother
ssh-copy-id -i ~/.ssh/id_mother.pub user@10.0.x.x

# Test connection
ssh -i ~/.ssh/id_mother user@10.0.x.x

# Add to ~/.ssh/config for convenience
cat >> ~/.ssh/config << EOF
Host mother
    HostName 10.0.x.x
    User <username>
    IdentityFile ~/.ssh/id_mother
    ServerAliveInterval 60
EOF

# Now can connect with just:
ssh mother
```

### 2. Mother → GitHub SSH Access

**On Mother:**
```bash
# Generate deploy key for GitHub
ssh-keygen -t ed25519 -C "mother@github-deploy"
# Save to: /home/<user>/.ssh/id_github

# Display public key
cat ~/.ssh/id_github.pub

# Copy this key and add to GitHub repository:
# Settings → Deploy Keys → Add deploy key
# ✓ Allow write access (for GitHub Actions to pull)

# Test GitHub connection
ssh -T git@github.com -i ~/.ssh/id_github
```

**Configure git to use SSH key:**
```bash
# Clone repository using SSH
git clone git@github.com:yourusername/mother.git

# Or set remote URL for existing repo
git remote set-url origin git@github.com:yourusername/mother.git

# Configure git to use SSH key
git config core.sshCommand "ssh -i ~/.ssh/id_github"
```

### 3. Ali's WSL → GitHub SSH Access

**On WSL:**
```bash
# Generate SSH key if not present
ssh-keygen -t ed25519 -C "ali@github"
# Save to: /home/alig/.ssh/id_github_ali

# Add public key to GitHub:
# GitHub → Settings → SSH and GPG keys → New SSH key

# Test connection
ssh -T git@github.com -i ~/.ssh/id_github_ali

# Clone mother repository
cd ~/projects
git clone git@github.com:yourusername/mother.git
```

### SSH Key Summary

| Machine | Purpose | Key Location | Destination |
|---------|---------|--------------|-------------|
| WSL | Access Mother | `~/.ssh/id_mother` | Mother server |
| WSL | Push to GitHub | `~/.ssh/id_github_ali` | GitHub |
| Mother | Pull from GitHub | `~/.ssh/id_github` | GitHub (deploy key) |

---

## SMB/CIFS Mount Configuration

### Mother → Synology Shares

**Install CIFS utilities:**
```bash
sudo apt update
sudo apt install cifs-utils
```

**Create mount points:**
```bash
sudo mkdir -p /mnt/synology/{downloads,movies,tv,4kmovies,4ktv}
```

**Create credentials file:**
```bash
sudo mkdir -p /root/.credentials
sudo nano /root/.credentials/synology

# Add:
username=<synology-username>
password=<synology-password>
domain=WORKGROUP

# Secure it
sudo chmod 600 /root/.credentials/synology
```

**Add to /etc/fstab:**
```bash
sudo nano /etc/fstab

# Add these lines:
//10.0.1.203/downloads  /mnt/synology/downloads  cifs  credentials=/root/.credentials/synology,iocharset=utf8,vers=3.0,uid=1000,gid=1000  0  0
//10.0.0.160/movies     /mnt/synology/movies     cifs  credentials=/root/.credentials/synology,iocharset=utf8,vers=3.0,uid=1000,gid=1000  0  0
//10.0.0.88/tv          /mnt/synology/tv         cifs  credentials=/root/.credentials/synology,iocharset=utf8,vers=3.0,uid=1000,gid=1000  0  0
//10.0.1.203/4KMovies   /mnt/synology/4kmovies   cifs  credentials=/root/.credentials/synology,iocharset=utf8,vers=3.0,uid=1000,gid=1000  0  0
//10.0.1.203/4ktv       /mnt/synology/4ktv       cifs  credentials=/root/.credentials/synology,iocharset=utf8,vers=3.0,uid=1000,gid=1000  0  0
```

**Note:** Replace uid=1000,gid=1000 with your user's actual UID/GID

**Mount all:**
```bash
sudo mount -a

# Verify mounts
df -h | grep synology
ls -la /mnt/synology/downloads
```

**Docker Compose volume mapping:**
```yaml
volumes:
  - /mnt/synology/downloads:/downloads
  - /mnt/synology/movies:/movies
  - /mnt/synology/tv:/tv
  - /mnt/synology/4kmovies:/4kmovies
  - /mnt/synology/4ktv:/4ktv
```

---

## Testing & Validation

### Network Connectivity Checklist

**From Mother:**
```bash
# Test all Synology devices
ping -c 4 10.0.1.203
ping -c 4 10.0.0.88
ping -c 4 10.0.0.160

# Test Ali's Unraid
ping -c 4 192.168.1.10

# Test SMB access
smbclient -L //10.0.1.203 -U <username>
smbclient -L //10.0.0.88 -U <username>
smbclient -L //10.0.0.160 -U <username>

# Test mount points
ls /mnt/synology/downloads
ls /mnt/synology/movies
ls /mnt/synology/tv

# Test write access
touch /mnt/synology/downloads/test.txt
rm /mnt/synology/downloads/test.txt
```

**From WSL:**
```bash
# Test SSH to Mother
ssh mother

# Test Synology access through VPN
ping -c 4 10.0.1.203

# Test GitHub SSH
ssh -T git@github.com
```

### Bandwidth Testing

**Install iperf3 on both sides:**
```bash
# On Chris's side (server mode)
iperf3 -s

# On Ali's side (client mode)
iperf3 -c 10.0.1.203 -t 60

# Expected results: 600-750 Mbps through VPN tunnel
```

### Troubleshooting

**VPN tunnel down:**
```bash
# Check VPN status on UCG
# Restart VPN tunnel if needed
# Verify static routes configured
```

**SMB mounts fail:**
```bash
# Check credentials
cat /root/.credentials/synology

# Test manual mount
sudo mount -t cifs //10.0.1.203/downloads /mnt/synology/downloads -o credentials=/root/.credentials/synology,vers=3.0

# Check Synology SMB logs
# Verify user has access to shares
```

**SSH connection issues:**
```bash
# Verbose SSH for debugging
ssh -vvv mother

# Check SSH key permissions
ls -la ~/.ssh/

# Verify key is correct
ssh-keygen -lf ~/.ssh/id_mother.pub
```

---

## Security Best Practices

1. **SSH Keys Only:** Disable password authentication on Mother
2. **Firewall:** Use ufw to restrict access to necessary ports only
3. **VPN:** All cross-site traffic through VPN tunnel only
4. **Credentials:** Store Synology credentials securely (root-owned files)
5. **Updates:** Enable automatic security updates on Ubuntu
6. **Monitoring:** Set up alerts for VPN tunnel failures

---

## Next Steps

After network setup is complete:
1. Verify all connectivity tests pass
2. Document actual Mother IP address
3. Update firewall rules as services are added
4. Proceed to Docker service deployment
5. Configure external access through Nginx Proxy Manager

---

**Configuration Files Location:**
- `/etc/fstab` - Mount configurations
- `/etc/hosts` - Local DNS entries
- `/root/.credentials/synology` - SMB credentials
- `~/.ssh/config` - SSH connection shortcuts
- `/etc/ufw/` - Firewall rules
