# Private Tracker Migration - Project Mother

## Overview
Critical checklist for migrating private tracker accounts from your current IP to Chris's IP without getting banned.

## Current Setup
- **Your current IP**: 74.215.149.185 (via 192.168.1.0/24)
- **Chris's IP** (new): 74.83.151.194 (via 10.0.0.0/23)
- **Action**: Switching qBittorrent and all tracker access to Chris's IP

## Tracker Accounts Inventory

### Document Your Trackers
Please provide the following for each tracker:

```
Tracker Name:
Username:
Current IP used:
IP change policy:
Requires staff notification: Yes/No
API key (if applicable):
2FA enabled: Yes/No
Ratio requirements:
Hit and run rules:
Seeding requirements:
Notes:
```

## Common Private Tracker Rules

### IP Change Policies

#### Strict (Notification Required)
- PTP, BTN, HDBits, others
- **Action**: Open ticket BEFORE changing IP
- **Info to provide**: 
  - Old IP
  - New IP
  - Reason for change
  - Confirm only one account

#### Moderate (Logged but Allowed)
- Most trackers
- **Action**: Change allowed, may trigger security review
- **Monitor**: Account for suspension/warnings

#### Lenient (No Issue)
- Some trackers auto-allow
- **Action**: Just update and monitor

### One Account Per IP Rule
**CRITICAL**: Most private trackers enforce "one account per IP"

**Current Risk**: 
- If Chris also has accounts on same trackers
- Both accounts accessed from same IP = INSTANT BAN

**Solutions**:
1. **Confirm Chris doesn't have accounts** on your trackers
2. **Or**: Keep your trackers on your IP, add new ones on Chris's IP
3. **Or**: Chris disables his accounts before you switch

## Pre-Migration Checklist

### 1-2 Weeks Before
- [ ] Document all tracker accounts (see template above)
- [ ] Check tracker rules and IP policies
- [ ] Verify Chris doesn't have conflicting accounts
- [ ] Open tickets with strict trackers
- [ ] Enable 2FA on all accounts (if not already)
- [ ] Document current stats (ratio, buffer, HnR)
- [ ] Screenshot account pages
- [ ] Backup .torrent files
- [ ] Export torrent list from qBittorrent

### 1 Week Before
- [ ] Final confirmation from strict trackers
- [ ] Verify all tickets resolved
- [ ] Prepare rollback plan
- [ ] Test VPN from Chris's location (if needed as backup)

### Day Before
- [ ] Final data backup
- [ ] Export qBittorrent settings
- [ ] Document all announce URLs
- [ ] Prepare emergency contact (IRC, forum) if issues arise

## Migration Procedure

### Phase 1: Jackett/Prowlarr Migration

#### Step 1: Update Jackett Configuration
```bash
# Access Jackett at current location
http://192.168.1.x:9117

# For each indexer:
1. Test connection (should work from current IP)
2. Export indexer settings
3. Document API keys
```

#### Step 2: Deploy Jackett on Mother
```bash
# Jackett starts on Mother (Chris's IP)
docker-compose up -d jackett

# Access: http://10.0.1.10:9117
```

#### Step 3: Re-add Indexers on Mother
```bash
# For EACH tracker:
1. Add indexer in Jackett
2. Enter credentials
3. Test (this will come from Chris's IP)
4. Monitor tracker site for IP change warnings
```

**WAIT 24-48 hours** - Monitor for any tracker issues before proceeding

### Phase 2: qBittorrent Migration

#### Step 1: Backup Current qBittorrent
```bash
# On your current system
# Export torrent list
# Backup ~/.config/qBittorrent/
# Backup torrent files
# Screenshot download queue
```

#### Step 2: Prepare New qBittorrent
```bash
# On Mother (Chris's IP)
docker-compose up -d qbittorrent

# Initial setup:
1. Set port (6881)
2. Disable DHT/PEX initially (reduce tracker load)
3. Set connection limits
```

#### Step 3: Gradual Torrent Migration

**DO NOT** add all torrents at once!

```bash
# Day 1: Add 10-20 torrents
# Monitor tracker responses
# Check for warnings/bans

# Day 2-3: Add 50 more torrents
# Continue monitoring

# Week 1: Add remaining torrents in batches
# 100-200 per day maximum
```

#### Step 4: Update Announce URLs

For each torrent migrated:
```bash
# The announce URL may be different on new IP
# Jackett provides new announce URLs
# Update in qBittorrent if needed
```

### Phase 3: Radarr/Sonarr Migration

#### Step 1: Configure Download Client
```yaml
# In each *arr app
Download Client:
  Type: qBittorrent
  Host: qbittorrent (Docker network)
  Port: 8080
  Username: admin
  Password: <your_password>
  Category: radarr-hd / radarr-4k / sonarr-hd / sonarr-4k
```

#### Step 2: Update Indexers
```yaml
# Add Jackett indexers to Radarr/Sonarr
# Use Jackett's Torznab feeds
# Test each indexer
```

#### Step 3: Test Download
```bash
# Do manual search in Radarr/Sonarr
# Download 1-2 test files
# Verify:
  1. Download starts in qBittorrent
  2. Tracker accepts connection
  3. File copies to final location
  4. Sync to your Unraid works
```

## Tracker-Specific Migration Notes

### Upload tracker information here when ready

#### Example Template:
```
Tracker: PassThePopcorn
IP Policy: Strict - requires staff notification
Migration Steps:
  1. Open ticket 1 week before
  2. Provide old IP: 74.215.149.185
  3. Provide new IP: 74.83.151.194
  4. Wait for staff approval
  5. Change IP
  6. Monitor for 48 hours
  7. Close ticket confirming success
```

## Common Migration Issues

### Issue 1: Tracker Bans New IP
**Symptoms**: 
- "Unregistered torrent" errors
- "IP not authorized" errors
- Account locked

**Solution**:
1. Immediately stop qBittorrent
2. Contact tracker staff via IRC/forum
3. Explain IP change
4. Provide old IP as proof of identity
5. Wait for unlock
6. Gradually resume

### Issue 2: Hit and Run Warnings
**Symptoms**:
- Existing torrents flagged as HnR
- New IP triggers re-evaluation

**Solution**:
1. Continue seeding affected torrents
2. Contact staff if warnings unfair
3. May need to seed longer from new IP

### Issue 3: Ratio Drop
**Symptoms**:
- Stats not transferring properly
- Upload not counting

**Solution**:
1. Verify account page shows correct stats
2. Check torrent client reporting upload
3. Contact staff if discrepancy

## Monitoring Post-Migration

### Daily (First Week)
- [ ] Check each tracker account
- [ ] Review warnings/messages
- [ ] Monitor ratio changes
- [ ] Check for IP bans
- [ ] Review qBittorrent logs

### Weekly (First Month)
- [ ] Overall ratio check
- [ ] HnR status review
- [ ] Any account restrictions
- [ ] Upload/download stats

### Monthly (Ongoing)
- [ ] Account health check
- [ ] Seed time requirements
- [ ] Buffer maintenance

## Rollback Plan

If migration fails:

### Emergency Rollback
```bash
1. Stop qBittorrent on Mother
2. Restart qBittorrent on your current system
3. Contact tracker staff
4. Explain rollback
5. Resume from original IP
6. Re-evaluate migration strategy
```

### Partial Rollback
```bash
# Keep some trackers on new IP
# Keep some on old IP
# Use VPN for problematic trackers (if allowed by tracker rules)
```

## Alternative: Dual Setup (Temporary)

During transition, you could:

```bash
# Your System (Old IP)
- qBittorrent with existing torrents
- Continues seeding
- No new downloads

# Mother (New IP)  
- qBittorrent for new downloads only
- Gradually migrate old torrents
- Monitor for issues
```

**Duration**: 1-2 months
**Goal**: Zero-downtime migration

## Tracker Rules Reference

### Upload Tracker Rules Here

For each of your trackers, document:
1. Ratio requirements
2. Seeding time requirements
3. Hit and run rules
4. IP change policy
5. Freeleech usage
6. API limits
7. Announce limits
8. Staff contact method

## Security Best Practices

### Account Security
- [ ] Enable 2FA on all trackers
- [ ] Use strong unique passwords (password manager)
- [ ] Never share accounts
- [ ] Don't discuss trackers publicly
- [ ] Secure API keys (.env file, never commit)

### Traffic Security
- [ ] Use HTTPS for tracker websites
- [ ] Encrypted torrent connections (qBittorrent setting)
- [ ] Secure API communication
- [ ] Regular security audits

## Communication Templates

### Ticket Template: IP Change Request
```
Subject: IP Change Request - Planned Migration

Hello,

I am planning to change my IP address due to moving my seedbox to a new location.

Account: [your_username]
Current IP: 74.215.149.185
New IP: 74.83.151.194
Expected Change Date: [date]

This is the only account I operate on this tracker. The IP change is due to 
consolidating my media server infrastructure with a friend's homelab setup.

Could you please authorize this IP change and let me know if any additional 
steps are required?

Thank you.
```

### Forum Post Template: IP Change Announcement
```
Subject: IP Changed - Account Security

Hello staff,

My IP has changed from 74.215.149.185 to 74.83.151.194 as of [date].

This was a planned change due to infrastructure consolidation. I have only 
one account on this tracker.

If you need any verification, please let me know.

Account: [your_username]
```

## Cross-Seed Considerations

### Impact on Cross-Seeding
- New IP may affect cross-seed matching
- Some trackers may not recognize moved torrents
- May need to re-cross-seed from new IP

### Cross-Seed Migration
```bash
# Update cross-seed config with new IP
# May need to re-scan library
# Some torrents may need manual intervention
```

## Next Steps
1. ⏳ Document all tracker accounts
2. ⏳ Research each tracker's IP policy
3. ⏳ Confirm Chris has no conflicting accounts
4. ⏳ Open tickets with strict trackers
5. ⏳ Wait for approvals (1-2 weeks)
6. ⏳ Backup all torrent data
7. ⏳ Deploy Jackett on Mother
8. ⏳ Test with 1-2 trackers first
9. ⏳ Gradually migrate torrents
10. ⏳ Monitor for issues
11. ⏳ Full cutover when stable
12. ⏳ Update documentation with learnings

## Critical Reminders

🚨 **NEVER rush this migration**
🚨 **Always have tracker staff approval for strict trackers**
🚨 **One account per IP - verify with Chris first**
🚨 **Backup everything before starting**
🚨 **Monitor closely for first 2 weeks**
🚨 **Have rollback plan ready**

## Tracker Contact Methods

Document for each tracker:
- IRC channel
- Forum section for help
- Staff ticket system
- Emergency contact
- Response time expectation
