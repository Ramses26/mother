#!/bin/bash

################################################################################
# PATH VERIFICATION SCRIPT FOR MOTHER SERVER
################################################################################
# Run this script on the Mother server to verify all paths are correct
# This will show you the actual paths that exist on the system
################################################################################

echo "========================================================================"
echo "PROJECT MOTHER - PATH VERIFICATION"
echo "========================================================================"
echo ""
echo "Checking paths on Mother server..."
echo ""

# Function to check if path exists
check_path() {
    local path="$1"
    local description="$2"
    
    if [ -d "$path" ]; then
        echo "✓ EXISTS: $description"
        echo "  Path: $path"
        echo "  Space: $(df -h "$path" | tail -1 | awk '{print $4}' ) free"
        echo ""
    else
        echo "✗ NOT FOUND: $description"
        echo "  Path: $path"
        echo "  (Directory does not exist)"
        echo ""
    fi
}

echo "CHECKING CHRIS'S (SYNOLOGY) PATHS:"
echo "========================================================================"

# Check possible Chris's paths
check_path "/mnt/synology/rs-movies" "Chris's Movies (expected)"
check_path "/mnt/synology/4k-movies" "Chris's 4K Movies (expected)"
check_path "/mnt/synology/deleted/movies" "Chris's Deleted Movies folder (expected)"
check_path "/mnt/synology/deleted/4k-movies" "Chris's Deleted 4K Movies folder (expected)"

# Alternative possible paths for Synology
check_path "/mnt/synology/volume1/rs-movies" "Chris's Movies (alternative 1)"
check_path "/mnt/synology/volume1/4k-movies" "Chris's 4K Movies (alternative 1)"
check_path "/volume1/rs-movies" "Chris's Movies (alternative 2)"
check_path "/volume1/4k-movies" "Chris's 4K Movies (alternative 2)"

echo ""
echo "CHECKING ALI'S (UNRAID) PATHS:"
echo "========================================================================"

# Check Ali's paths
check_path "/mnt/media/Movies" "Ali's Movies (alternative 1)"
check_path "/mnt/media/4K Movies" "Ali's 4K Movies (alternative 1)"
check_path "/mnt/user/Media/Movies" "Ali's Movies (expected)"
check_path "/mnt/user/Media/4K Movies" "Ali's 4K Movies (expected)"
check_path "/mnt/user/Media/Deleted/Movies" "Ali's Deleted Movies folder (expected)"
check_path "/mnt/user/Media/Deleted/4K Movies" "Ali's Deleted 4K Movies folder (expected)"

echo ""
echo "CHECKING WHAT'S MOUNTED:"
echo "========================================================================"
echo ""
mount | grep -E "synology|Media|media|volume1" | while read line; do
    echo "$line"
done

echo ""
echo "========================================================================"
echo "FINDING ALL POSSIBLE PATHS:"
echo "========================================================================"
echo ""
echo "Looking for directories containing 'movies' or 'Movies'..."
find /mnt -maxdepth 3 -type d -iname "*movie*" 2>/dev/null | head -20

echo ""
echo "========================================================================"
echo "SHOW ME YOUR ACTUAL DIRECTORY STRUCTURE:"
echo "========================================================================"
echo ""
echo "Run these commands to show your actual paths:"
echo ""
echo "1. Show all mounts:"
echo "   mount | grep mnt"
echo ""
echo "2. Show Synology structure:"
echo "   ls -la /mnt/synology/"
echo "   ls -la /mnt/synology/volume1/ 2>/dev/null"
echo ""
echo "3. Show Ali's structure:"
echo "   ls -la /mnt/user/Media/"
echo "   ls -la /mnt/media/ 2>/dev/null"
echo ""
echo "4. Find Deleted folders:"
echo "   find /mnt -maxdepth 4 -type d -iname 'deleted' 2>/dev/null"
echo ""
echo "========================================================================"
