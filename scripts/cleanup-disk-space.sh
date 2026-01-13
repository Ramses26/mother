#!/bin/bash
# Quick Disk Space Cleanup Script
# Run this to quickly free up space on Ubuntu

echo "Ubuntu VM Disk Space Cleanup"
echo "======================================"
echo ""

# Function to show space before/after
show_space() {
    echo "Current disk usage:"
    df -h / | grep -v Filesystem
    echo ""
}

echo "Initial Status:"
show_space

echo "1. Cleaning APT cache..."
sudo apt clean
sudo apt autoclean
FREED=$(du -sh /var/cache/apt/archives | awk '{print $1}')
echo "   Cleared: $FREED"
echo ""

echo "2. Removing old kernels and packages..."
sudo apt autoremove --purge -y
echo ""

echo "3. Cleaning journal logs (keeping last 7 days)..."
BEFORE=$(sudo journalctl --disk-usage | grep -o '[0-9.]*[A-Z]' | head -1)
sudo journalctl --vacuum-time=7d
AFTER=$(sudo journalctl --disk-usage | grep -o '[0-9.]*[A-Z]' | head -1)
echo "   Before: $BEFORE, After: $AFTER"
echo ""

echo "4. Cleaning old snap revisions..."
if command -v snap &> /dev/null; then
    sudo snap set system refresh.retain=2
    LANG=C snap list --all | awk '/disabled/{print $1, $3}' | \
    while read snapname revision; do
        echo "   Removing $snapname revision $revision"
        sudo snap remove "$snapname" --revision="$revision" 2>/dev/null
    done
fi
echo ""

echo "5. Checking for large log files..."
echo "   Top 10 largest logs:"
sudo find /var/log -type f -size +50M -exec ls -lh {} \; 2>/dev/null | head -10
echo ""

if command -v docker &> /dev/null; then
    echo "6. Docker cleanup..."
    read -p "   Clean Docker images/containers? (y/n): " docker_clean
    if [ "$docker_clean" = "y" ]; then
        echo "   Before:"
        sudo docker system df
        sudo docker system prune -a -f
        echo "   After:"
        sudo docker system df
    fi
fi
echo ""

echo "======================================"
echo "Cleanup Complete!"
echo ""
show_space

echo "To see what's still using space:"
echo "  sudo du -h --max-depth=1 / | sort -hr | head -20"
echo ""
echo "To expand filesystem to full 100GB:"
echo "  sudo /home/alig/projects/mother/scripts/expand-filesystem.sh"
