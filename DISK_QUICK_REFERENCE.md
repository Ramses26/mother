# Ubuntu VM Disk Space - Quick Reference

## Quick Diagnosis

```bash
# Current status
df -h /
lsblk
sudo vgs && sudo lvs

# What's using space?
sudo du -h --max-depth=1 / | sort -hr | head -20
```

## Quick Cleanup (Run in order)

```bash
# 1. Clean package cache
sudo apt clean && sudo apt autoremove --purge -y

# 2. Clean logs (keep 7 days)
sudo journalctl --vacuum-time=7d

# 3. Clean old snaps
sudo snap set system refresh.retain=2
LANG=C snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do sudo snap remove "$snapname" --revision="$revision"; done

# 4. Docker cleanup (if using Docker)
sudo docker system prune -a -f

# Or use the automated script:
sudo ~/projects/mother/scripts/cleanup-disk-space.sh
```

## Expand Filesystem to 100GB

### Quick Method (Automated)
```bash
sudo ~/projects/mother/scripts/expand-filesystem.sh
```

### Manual Method (if script fails)
```bash
# 1. Rescan disk
echo 1 | sudo tee /sys/block/sda/device/rescan

# 2. Grow partition
sudo growpart /dev/sda 3

# 3. Resize PV
sudo pvresize /dev/sda3

# 4. Extend LV
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv

# 5. Resize filesystem
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv

# 6. Verify
df -h /
```

## Troubleshooting

### Can't see full disk
```bash
# Rescan all SCSI devices
echo "- - -" | sudo tee /sys/class/scsi_host/host*/scan
```

### LVM won't extend
```bash
# Check free space
sudo vgs  # Look at VFree column

# If VFree is 0, grow partition first
sudo growpart /dev/sda 3
sudo pvresize /dev/sda3
```

### Filesystem resize fails
```bash
# Check filesystem
sudo e2fsck -f /dev/ubuntu-vg/ubuntu-lv

# Then resize
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv
```

## Status Check Commands

```bash
# Physical disk
lsblk

# Partitions
sudo fdisk -l /dev/sda

# LVM layers
sudo pvs    # Physical volumes
sudo vgs    # Volume groups  
sudo lvs    # Logical volumes

# Filesystem
df -h /
```

## Files Created

- `~/projects/mother/scripts/disk-analysis.sh` - Full disk analysis
- `~/projects/mother/scripts/expand-filesystem.sh` - Automated expansion
- `~/projects/mother/scripts/cleanup-disk-space.sh` - Quick cleanup
- `~/projects/mother/UBUNTU_DISK_EXPANSION.md` - Complete guide

## Expected Final State

```
/dev/sda                        100G  (Physical disk in ESXi)
├─/dev/sda1                     512M  (EFI)
├─/dev/sda2                     1G    (Boot)
└─/dev/sda3                     98.5G (LVM)
  └─ubuntu-vg/ubuntu-lv         98.5G (Root filesystem)
    mounted on /                ~95G available
```
