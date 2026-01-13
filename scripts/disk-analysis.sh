#!/bin/bash
# Disk Space Analysis Script for Ubuntu VM
# Run this to find what's consuming disk space

echo "======================================"
echo "DISK SPACE ANALYSIS"
echo "======================================"
echo ""

echo "1. Current Disk Layout:"
echo "--------------------------------------"
lsblk
echo ""

echo "2. Filesystem Usage:"
echo "--------------------------------------"
df -h
echo ""

echo "3. Physical Volume Status (LVM):"
echo "--------------------------------------"
sudo pvdisplay
echo ""

echo "4. Volume Group Status (LVM):"
echo "--------------------------------------"
sudo vgdisplay
echo ""

echo "5. Logical Volume Status (LVM):"
echo "--------------------------------------"
sudo lvdisplay
echo ""

echo "6. Top 10 Largest Directories in /:"
echo "--------------------------------------"
sudo du -h --max-depth=1 / 2>/dev/null | sort -hr | head -20
echo ""

echo "7. Top 10 Largest Directories in /var:"
echo "--------------------------------------"
sudo du -h --max-depth=2 /var 2>/dev/null | sort -hr | head -20
echo ""

echo "8. Top 10 Largest Directories in /home:"
echo "--------------------------------------"
sudo du -h --max-depth=2 /home 2>/dev/null | sort -hr | head -20
echo ""

echo "9. Top 10 Largest Directories in /opt:"
echo "--------------------------------------"
sudo du -h --max-depth=2 /opt 2>/dev/null | sort -hr | head -20
echo ""

echo "10. Docker Space Usage (if applicable):"
echo "--------------------------------------"
if command -v docker &> /dev/null; then
    sudo docker system df -v
else
    echo "Docker not installed"
fi
echo ""

echo "11. Snap Package Usage:"
echo "--------------------------------------"
du -h /var/lib/snapd/snaps 2>/dev/null | tail -1
snap list 2>/dev/null
echo ""

echo "12. Journal Logs Size:"
echo "--------------------------------------"
sudo journalctl --disk-usage
echo ""

echo "13. APT Cache Size:"
echo "--------------------------------------"
sudo du -sh /var/cache/apt/archives
echo ""

echo "======================================"
echo "Analysis Complete!"
echo "======================================"
