#!/bin/bash
# FAST Disk Space Analysis - Skips network mounts and slow paths
# Should complete in under 1 minute

echo "======================================"
echo "FAST DISK SPACE ANALYSIS"
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

echo "3. LVM Status:"
echo "--------------------------------------"
sudo pvs 2>/dev/null
sudo vgs 2>/dev/null
sudo lvs 2>/dev/null
echo ""

echo "4. Top directories in / (excluding network mounts):"
echo "--------------------------------------"
sudo du -h --max-depth=1 --exclude=/mnt --exclude=/proc --exclude=/sys --exclude=/dev --exclude=/run / 2>/dev/null | sort -hr | head -15
echo ""

echo "5. Specific large directories:"
echo "--------------------------------------"
echo "/var total:"
sudo du -sh /var 2>/dev/null
echo "/var/lib/docker (if exists):"
sudo du -sh /var/lib/docker 2>/dev/null
echo "/var/log total:"
sudo du -sh /var/log 2>/dev/null
echo "/var/lib/snapd (if exists):"
sudo du -sh /var/lib/snapd 2>/dev/null
echo "/opt total:"
sudo du -sh /opt 2>/dev/null
echo "/home total:"
sudo du -sh /home 2>/dev/null
echo ""

echo "6. Docker space usage:"
echo "--------------------------------------"
if command -v docker &> /dev/null; then
    sudo docker system df 2>/dev/null || echo "Docker not running or no permission"
else
    echo "Docker not installed"
fi
echo ""

echo "7. Journal logs size:"
echo "--------------------------------------"
sudo journalctl --disk-usage 2>/dev/null
echo ""

echo "8. APT cache size:"
echo "--------------------------------------"
sudo du -sh /var/cache/apt/archives 2>/dev/null
echo ""

echo "9. Network mounts (FYI - not counted in above):"
echo "--------------------------------------"
df -h | grep -E '/mnt|nfs|cifs' || echo "No network mounts found"
echo ""

echo "======================================"
echo "Analysis Complete! (Fast version)"
echo "======================================"
