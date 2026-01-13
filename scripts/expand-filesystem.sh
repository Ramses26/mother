#!/bin/bash
# Filesystem Expansion Script for Ubuntu VM
# This expands the filesystem to use full ESXi provisioned space

echo "======================================"
echo "FILESYSTEM EXPANSION SCRIPT"
echo "======================================"
echo ""
echo "This script will:"
echo "1. Rescan SCSI devices to detect new disk space"
echo "2. Expand the physical volume"
echo "3. Extend the logical volume"
echo "4. Resize the filesystem"
echo ""

read -p "Continue with expansion? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "Step 1: Current Status"
echo "--------------------------------------"
echo "Current filesystem usage:"
df -h /
echo ""
echo "Current LVM status:"
sudo vgs
sudo lvs
echo ""

echo "Step 2: Rescanning SCSI devices..."
echo "--------------------------------------"
# Rescan all SCSI hosts to detect expanded disk
for host in /sys/class/scsi_host/host*/scan; do
    echo "- - -" | sudo tee $host > /dev/null
done

# Rescan specific device (usually sda)
DEVICE=$(lsblk -no PKNAME $(findmnt -n -o SOURCE /) | head -1)
echo "Rescanning device: $DEVICE"
echo 1 | sudo tee /sys/block/$DEVICE/device/rescan > /dev/null
echo "Rescan complete!"
echo ""

sleep 2

echo "Step 3: Checking for partition table..."
echo "--------------------------------------"
lsblk
echo ""

# Detect if we're using LVM
VG_NAME=$(sudo vgs --noheadings -o vg_name | tr -d ' ' | head -1)
LV_PATH=$(df / | grep -v Filesystem | awk '{print $1}')

if [ -z "$VG_NAME" ]; then
    echo "ERROR: No LVM Volume Group found!"
    echo "This script is designed for LVM setups."
    echo "Please run 'lsblk' and 'df -h' to determine your disk layout."
    exit 1
fi

echo "Detected Volume Group: $VG_NAME"
echo "Detected Logical Volume: $LV_PATH"
echo ""

echo "Step 4: Expanding partition (if needed)..."
echo "--------------------------------------"
# Check if using GPT or MBR
PART_NUM=$(echo $LV_PATH | grep -o '[0-9]*$')
if [ -z "$PART_NUM" ]; then
    # Extract partition number from /dev/mapper/ubuntu--vg-ubuntu--lv format
    PART_NUM=3  # Common default for Ubuntu
fi

echo "Attempting to grow partition ${PART_NUM}..."
sudo growpart /dev/$DEVICE ${PART_NUM} 2>/dev/null
if [ $? -eq 0 ]; then
    echo "Partition expanded successfully!"
else
    echo "Partition may already be at maximum size or growpart not needed."
fi
echo ""

echo "Step 5: Resizing Physical Volume..."
echo "--------------------------------------"
PV_PATH=$(sudo pvs --noheadings -o pv_name | tr -d ' ' | head -1)
echo "Resizing PV: $PV_PATH"
sudo pvresize $PV_PATH
echo ""

echo "Step 6: Extending Logical Volume..."
echo "--------------------------------------"
echo "Extending LV to use 100% of free space in VG..."
sudo lvextend -l +100%FREE $LV_PATH
echo ""

echo "Step 7: Resizing Filesystem..."
echo "--------------------------------------"
# Detect filesystem type
FS_TYPE=$(df -T / | grep -v Filesystem | awk '{print $2}')
echo "Detected filesystem type: $FS_TYPE"

if [ "$FS_TYPE" = "ext4" ] || [ "$FS_TYPE" = "ext3" ]; then
    echo "Resizing ext4 filesystem..."
    sudo resize2fs $LV_PATH
elif [ "$FS_TYPE" = "xfs" ]; then
    echo "Resizing XFS filesystem..."
    sudo xfs_growfs /
else
    echo "Unknown filesystem type: $FS_TYPE"
    echo "Please resize manually"
    exit 1
fi
echo ""

echo "======================================"
echo "EXPANSION COMPLETE!"
echo "======================================"
echo ""
echo "New filesystem size:"
df -h /
echo ""
echo "LVM status:"
sudo vgs
sudo lvs
