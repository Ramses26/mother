# Project Mother - Security Setup (Home Lab Edition)

**Last Updated:** 2024-12-23

---

## Overview

This is a **home lab environment** - we're keeping security **simple but sensible**. No corporate paranoia, just basic protections against the obvious stuff.

### What We're Protecting:
- Your private tracker credentials (getting banned sucks)
- API keys and passwords
- External access to services
- SSH from random internet bots

### What We're NOT Doing:
- ❌ Over-engineering with complex firewall rules
- ❌ Isolating Docker containers from each other (they need to talk!)
- ❌ Extensive logging and monitoring (you're not reading those logs)
- ❌ Enterprise-grade hardening for a home media server

---

## Security Philosophy

**"Secure enough for a home lab, simple enough to actually use"**

1. Lock down external access
2. Use SSH keys (passwords are annoying anyway)
3. Change default passwords
4. Don't commit secrets to Git
5. Let Docker services talk to each other freely
6. Done!

---

## 1. SSH Security (Do This First!)

### Generate SSH Key on Your WSL

```bash
# On your WSL machine
cd ~/.ssh
ssh-keygen -t ed25519 -C "mother-server"

# When prompted:
# File: mother_ed25519
# Passphrase: (optional, up to you)
```

### Copy Key to Mother

```bash
# Copy your public key to Mother
ssh-copy-id -i ~/.ssh/mother_ed25519.pub user@10.0.1.10

# Test it works
ssh -i ~/.ssh/mother_ed25519 user@10.0.1.10
```

### Disable Password Authentication

```bash
# On Mother server
sudo nano /etc/ssh/sshd_config

# Change these lines:
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no

# Restart SSH
sudo systemctl restart sshd
```

### Create SSH Config (Convenience)

```bash
# On your WSL
nano ~/.ssh/config

# Add:
Host mother
    HostName 10.0.1.10
    User your_username
    IdentityFile ~/.ssh/mother_ed25519
    
# Now you can just: ssh mother
```

**That's it for SSH! No password prompts, reasonably secure.**

---

## 2. Basic Firewall (UFW - Keep It Simple)

### Install and Configure

```bash
# On Mother server
sudo apt install ufw

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (important!)
sudo ufw allow ssh

# Allow from your internal networks (Chris's and Ali's)
sudo ufw allow from 10.0.0.0/23 comment "Chris internal network"
sudo ufw allow from 192.168.1.0/24 comment "Ali internal network"

# If you want external access to specific services (optional)
# sudo ufw allow 80/tcp comment "HTTP"
# sudo ufw allow 443/tcp comment "HTTPS"

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status verbose
```

### That's Your Firewall!

Simple rules:
- ✅ Allow traffic from internal networks (everything works)
- ✅ Allow SSH
- ✅ Block everything else from internet
- ✅ Docker services can talk to each other (UFW doesn't block Docker by default)

---

## 3. Docker Security (Minimal Fuss)

### Use Standard Bridge Network

Your docker-compose.yml already has this - **don't change it**:

```yaml
networks:
  mother_network:
    driver: bridge
```

This means:
- ✅ All containers can talk to each other
- ✅ Containers can reach the internet
- ✅ Host can reach containers
- ✅ It just works

### Run as Non-Root (Already doing this)

Your docker-compose.yml uses PUID/PGID - this is good enough:

```yaml
environment:
  - PUID=1000
  - PGID=1000
```

**No need to overthink Docker security for a home lab.**

---

## 4. Passwords & Secrets

### Change Default Passwords (Do This!)

**qBittorrent:**
- Default: `admin` / `adminadmin`
- Change: Tools → Options → Web UI → Authentication

**Nginx Proxy Manager:**
- Default: `admin@example.com` / `changeme`
- Change: After first login

**Webmin:**
- Set during first login
- Change: Webmin → Webmin Configuration → Webmin Users

**All *arr Apps:**
- Set authentication: Settings → General → Authentication

### Store Secrets in .env File

```bash
# Your .env file should have:
QBITTORRENT_USERNAME=admin
QBITTORRENT_PASSWORD=your_secure_password_here
RADARR_HD_API_KEY=generated_by_radarr
RADARR_4K_API_KEY=generated_by_radarr
# etc...
```

### Never Commit .env to Git!

```bash
# Your .gitignore already has this:
.env
```

**Good practices:**
- Use `.env` file for all secrets
- Use `.env.example` with fake values for Git
- Generate strong random passwords: `openssl rand -base64 32`

---

## 5. External Access (If You Want It)

### Option A: No External Access (Simplest)

Only access services when:
- Connected to Chris's network directly
- Connected via your VPN to Chris's network

**This is the simplest and most secure option.**

### Option B: External Access via NPM (Recommended if needed)

Use Nginx Proxy Manager for SSL and basic auth:

1. **Setup domain** (optional) or use IP
2. **Create proxy hosts** in NPM for each service
3. **Enable SSL** (Let's Encrypt - NPM does this automatically)
4. **Add Access Lists** in NPM for basic authentication

**NPM handles:**
- ✅ SSL certificates (automatic)
- ✅ Basic authentication (simple username/password)
- ✅ Reverse proxy
- ✅ No complex configuration needed

**Skip Authelia/Authentik** - that's overkill for a home lab!

---

## 6. Private Tracker Safety

### Protect Your Credentials

```bash
# Store in .env
TRACKER_USERNAME=your_username
TRACKER_PASSWORD=your_password

# Use in Prowlarr/Jackett
# Don't hardcode in compose files
```

### IP Change Process

When migrating trackers to Chris's IP:

1. **Before**: Note your current IP in tracker profiles
2. **Contact**: Open tickets with strict trackers
3. **Test**: Add one tracker at a time
4. **Monitor**: Check for warnings in first 48 hours
5. **Wait**: Give it a week before bulk migration

**Follow TRACKER_MIGRATION.md for details**

---

## 7. Monitoring with Dozzle

### Access Docker Logs

Dozzle is already included in your docker-compose.yml:

```
Access: http://10.0.1.10:8888
```

**What you can do:**
- ✅ View real-time logs from all containers
- ✅ Search and filter logs
- ✅ Multi-container view
- ✅ No authentication needed (internal network only)

**Simple log monitoring without complexity!**

### Basic Log Checks

```bash
# Via Dozzle web interface
http://10.0.1.10:8888

# Or via command line when needed
docker compose logs --tail=100 [container-name]
docker compose logs -f radarr-hd  # Follow logs
```

---

## 8. Webmin for System Management

### Access Webmin

```
Access: https://10.0.1.10:10000
```

**What you can do:**
- ✅ Manage system updates
- ✅ Monitor disk usage
- ✅ Manage users and groups
- ✅ View system stats
- ✅ Configure services

**Initial Setup:**
1. Access https://10.0.1.10:10000
2. Login with your Ubuntu username/password
3. Accept the self-signed certificate warning (it's on your local network)
4. Recommended: Create a separate admin user
5. Recommended: Change the default port if desired

**Security Note:** Webmin is only accessible from your internal networks (firewall blocks external access).

---

## 9. Backup Your Configs (Simple)

```bash
# Backup script already exists
/opt/mother/scripts/backup.sh

# Backs up:
# - All container configs
# - .env file
# - docker-compose.yml
# - Databases

# Run it:
./scripts/backup.sh

# That's it!
```

Set up a cron job:
```bash
# Backup daily at 2 AM
0 2 * * * /opt/mother/scripts/backup.sh
```

---

## 10. Fail2Ban (Optional but Easy)

Protects SSH from brute force attempts:

```bash
# Install
sudo apt install fail2ban

# Enable for SSH
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Check status
sudo fail2ban-client status sshd
```

**Default config is fine for home lab.**

---

## Security Checklist

### Initial Setup
- [ ] SSH keys configured
- [ ] Password authentication disabled
- [ ] UFW firewall enabled
- [ ] Allowed internal networks in firewall
- [ ] Changed all default passwords
- [ ] Created .env file with secrets
- [ ] Verified .env in .gitignore
- [ ] (Optional) Installed fail2ban
- [ ] Configured Webmin admin user
- [ ] Bookmarked Dozzle for log monitoring

### Regular Maintenance
- [ ] Monthly: Update Ubuntu via Webmin or `sudo apt update && sudo apt upgrade`
- [ ] Monthly: Update Docker containers (`./scripts/deploy.sh`)
- [ ] Monthly: Check Dozzle for any error patterns
- [ ] Quarterly: Review firewall rules (`sudo ufw status`)
- [ ] Quarterly: Change important passwords

### Before Going Live
- [ ] Test SSH access
- [ ] Test all services are accessible
- [ ] Test firewall isn't blocking needed traffic
- [ ] Verify backups are working
- [ ] Document all passwords somewhere safe
- [ ] Test Dozzle access
- [ ] Test Webmin access

---

## What About...?

### "Should I use a VPN for all torrent traffic?"

If you're already on private trackers with good ratios, probably not necessary. But if you want to:
- Use a VPN container (like gluetun)
- Route qBittorrent through it
- This is a separate decision from Mother's security

### "Should I set up intrusion detection?"

No. This is a home lab. You're not being targeted by nation-states.

### "Should I isolate Docker networks?"

No. Your containers need to talk to each other. Isolation adds complexity without benefit in a home lab.

### "Should I monitor logs?"

Use Dozzle! It's already set up. Quick glance when something breaks.

That's enough. Don't set up ELK stack or Prometheus for a media server.

### "Should I use certificate pinning?"

No. Just use HTTPS via NPM if you want external access.

### "What about SELinux or AppArmor?"

Ubuntu comes with AppArmor enabled by default. Leave it alone. Don't mess with it.

---

## Troubleshooting

### Locked Yourself Out via SSH

**Prevention:** Test SSH keys BEFORE disabling password auth!

```bash
# Always test from a NEW terminal window:
ssh -i ~/.ssh/mother_ed25519 user@10.0.1.10

# Only disable passwords after this works!
```

**If you did lock yourself out:**
- Use ESXi console to access Mother
- Re-enable password auth in `/etc/ssh/sshd_config`
- Fix your SSH keys
- Try again

### Firewall Blocking Needed Traffic

```bash
# Check what's blocked
sudo ufw status verbose

# Allow specific port
sudo ufw allow from 10.0.0.0/23 to any port 8080

# Or temporarily disable to test
sudo ufw disable
# (re-enable after testing!)
```

### Can't Access Service from Your Network

```bash
# Check if service is running
docker compose ps

# Check if port is listening
sudo ss -tlnp | grep 8080

# Check firewall
sudo ufw status | grep 8080

# Check from Mother itself
curl localhost:8080

# Check logs in Dozzle
http://10.0.1.10:8888
```

### Webmin Certificate Warning

This is normal! Webmin uses a self-signed certificate.

```
1. Click "Advanced" or "Details"
2. Click "Accept Risk and Continue" or "Proceed"
3. You're on your local network - this is safe
```

---

## Summary

**You're doing this right if:**
- ✅ You can SSH without passwords
- ✅ Firewall is on but not blocking your internal networks
- ✅ All default passwords are changed
- ✅ Secrets are in .env and not in Git
- ✅ Services can talk to each other
- ✅ You can access everything you need
- ✅ Dozzle shows you logs when you need them
- ✅ Webmin helps you manage the server
- ✅ Setup took 30 minutes, not 3 days

**Remember:** Perfect is the enemy of good. This is a media server, not a bank. You want it **secure enough** and **usable**, not **maximum security** and **unusable**.

---

## Quick Access URLs

Once everything is deployed:

```
Management:
- Webmin:     https://10.0.1.10:10000
- Dozzle:     http://10.0.1.10:8888
- NPM:        http://10.0.1.10:81

Media Management:
- Radarr HD:  http://10.0.1.10:7878
- Radarr 4K:  http://10.0.1.10:7879
- Sonarr HD:  http://10.0.1.10:8989
- Sonarr 4K:  http://10.0.1.10:8990
- Prowlarr:   http://10.0.1.10:9696

Download:
- qBittorrent: http://10.0.1.10:8080

Request:
- Seerr (Ali):   http://10.0.1.10:5055
- Seerr (Chris): http://10.0.1.10:5056
```

---

**That's it! Simple, practical security for a home lab. Now go build something cool! 🚀**
