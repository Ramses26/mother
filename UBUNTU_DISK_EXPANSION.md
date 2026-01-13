# Ubuntu VM Disk Space Analysis & Expansion Guide

## Current Situation
- ESXi shows: 100GB thin provisioned disk
- Ubuntu sees: Only 50GB
- Disk utilization: 90% full

## Part 1: Diagnose What's Consuming Space

### Quick Commands to Run First

```bash
# 1. Check current disk layout
df -h
lsblk

# 2. Check LVM status (if using LVM)
sudo pvs
sudo vgs  
sudo lvs

# 3. Find largest directories
sudo du -h --max-depth=1 / | sort -hr | head -20
```

### Run the Complete Analysis Script

```bash
# Make executable and run
chmod +x /home/alig/projects/mother/scripts/disk-analysis.sh
sudo /home/alig/projects/mother/scripts/disk-analysis.sh > disk-analysis-report.txt

# Review the report
less disk-analysis-report.txt
```

### Common Space Consumers

1. **Docker** (`/var/lib/docker/`)
   ```bash
   sudo docker system df -v
   # Clean up if needed:
   sudo docker system prune -a --volumes
   ```

2. **Journal Logs** (`/var/log/journal/`)
   ```bash
   sudo journalctl --disk-usage
   # Clean up old logs:
   sudo journalctl --vacuum-time=7d
   ```

3. **APT Cache** (`/var/cache/apt/`)
   ```bash
   sudo du -sh /var/cache/apt/archives
   # Clean up:
   sudo apt clean
   ```

4. **Snap Packages** (`/var/lib/snapd/`)
   ```bash
   snap list --all
   # Remove old versions:
   sudo snap set system refresh.retain=2
   ```

5. **Old Kernels**
   ```bash
   dpkg -l | grep linux-image
   # Remove old kernels (keep current and one previous):
   sudo apt autoremove --purge
   ```

## Part 2: Expand Filesystem to Use Full 100GB

### Prerequisites
- ESXi disk already expanded to 100GB ✓
- VM powered on
- Root/sudo access

### Method 1: Using the Automated Script (Recommended)

```bash
# Make executable
chmod +x /home/alig/projects/mother/scripts/expand-filesystem.sh

# Run the expansion script
sudo /home/alig/projects/mother/scripts/expand-filesystem.sh
```

The script will:
1. Rescan SCSI devices to detect new space
2. Grow the partition (if needed)
3. Resize the physical volume (PV)
4. Extend the logical volume (LV)
5. Resize the filesystem

### Method 2: Manual Step-by-Step

#### Step 1: Rescan SCSI Devices
```bash
# Rescan to detect expanded disk
echo 1 | sudo tee /sys/class/scsi_device/*/device/rescan
echo 1 | sudo tee /sys/block/sda/device/rescan

# Verify new size detected
lsblk
```

#### Step 2: Expand the Partition
```bash
# Install cloud-guest-utils if needed
sudo apt install cloud-guest-utils

# Check current partition
sudo fdisk -l /dev/sda

# Grow partition 3 (adjust number if different)
sudo growpart /dev/sda 3

# Verify
lsblk
```

#### Step 3: Resize Physical Volume (LVM)
```bash
# Check current PV size
sudo pvs

# Resize PV to use full partition
sudo pvresize /dev/sda3

# Verify
sudo pvs
```

#### Step 4: Extend Logical Volume
```bash
# Check VG name and available space
sudo vgs
sudo lvs

# Extend LV to use all available space
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv

# Or extend by specific amount
# sudo lvextend -L +50G /dev/ubuntu-vg/ubuntu-lv

# Verify
sudo lvs
```

#### Step 5: Resize Filesystem
```bash
# For ext4 filesystem
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv

# For XFS filesystem (if applicable)
sudo xfs_growfs /

# Verify
df -h
```

### Verification

After expansion, verify everything:
```bash
# Check filesystem size
df -h /

# Check LVM status
sudo pvs
sudo vgs
sudo lvs

# Full disk layout
lsblk
```

You should now see:
- `/` filesystem showing close to 100GB
- LVM volumes fully extended
- Available space increased

## Troubleshooting

### Issue: "No space left to extend"
- **Check**: `sudo vgs` - look at VFree column
- **Solution**: The partition may not be expanded yet. Run `sudo growpart /dev/sda 3`

### Issue: "Partition already at maximum size"
- **Check**: `lsblk` - compare sda size vs sda3 size
- **Solution**: If they match, the partition is correct. Proceed to PV resize.

### Issue: Device mapper errors
```bash
# Reload device mapper tables
sudo dmsetup ls
sudo vgchange -ay
```

### Issue: Filesystem won't resize
```bash
# Check filesystem for errors first
sudo e2fsck -f /dev/ubuntu-vg/ubuntu-lv

# Then resize
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv
```

## Common Ubuntu LVM Disk Layouts

### Layout 1: Standard Ubuntu Server Install
```
/dev/sda (100GB)
├─/dev/sda1 - /boot/efi (512MB)
├─/dev/sda2 - /boot (1GB)
└─/dev/sda3 - LVM Physical Volume
  └─ubuntu-vg
    └─ubuntu-lv (/) - Root filesystem
```

### Layout 2: Desktop Install
```
/dev/sda (100GB)
├─/dev/sda1 - /boot/efi (512MB)
└─/dev/sda2 - LVM Physical Volume
  └─ubuntu-vg
    ├─ubuntu-lv (/) - Root filesystem
    └─swap_1 - Swap
```

## Quick Space Cleanup Commands

```bash
# 1. Clean APT cache
sudo apt clean
sudo apt autoremove --purge

# 2. Clean old journal logs (keep last 7 days)
sudo journalctl --vacuum-time=7d

# 3. Clean old snap versions
sudo snap set system refresh.retain=2
LANG=C snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do sudo snap remove "$snapname" --revision="$revision"; done

# 4. Clean Docker (if applicable)
sudo docker system prune -a --volumes -f

# 5. Find and remove large log files
sudo find /var/log -type f -name "*.log" -size +100M -exec ls -lh {} \;
```

## Post-Expansion Checklist

- [ ] Filesystem expanded to ~100GB
- [ ] Services running normally
- [ ] No errors in `dmesg` or logs
- [ ] LVM volumes showing correct sizes
- [ ] Webmin showing correct disk size
- [ ] Take VM snapshot in ESXi (after successful expansion)

## Support

If expansion fails or you need help:
1. Save output of: `lsblk`, `df -h`, `sudo pvs`, `sudo vgs`, `sudo lvs`
2. Check `/var/log/syslog` for errors
3. Take VM snapshot before making changes
