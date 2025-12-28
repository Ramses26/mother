#!/bin/bash

################################################################################
# PROJECT MOTHER - QUICK START GUIDE
################################################################################
# 
# Run this script for interactive setup and execution
#
################################################################################

cat << 'EOF'
================================================================================
PROJECT MOTHER - QUICK START
================================================================================

This will run the complete sync and deletion process overnight.
Estimated time: 45-52 hours (2+ days)

Strategy: SYNC-THEN-DELETE
  - Files are synced BEFORE deletion (never missing)
  - Safe for unattended overnight execution
  - Resume capability if interrupted

What will happen:
  1. Sync Movies (Ali ↔ Chris)
  2. Delete lower quality Movies
  3. Sync 4K Movies (Ali ↔ Chris)
  4. Delete lower quality 4K Movies

Result:
  - Both servers have ALL movies at BEST quality
  - ~2,147 lower quality files moved to Deleted folders
  - Can reclaim ~2-3 TB by emptying Deleted folders

================================================================================
EOF

echo ""
read -p "Continue with setup? (y/n): " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 1
fi

echo ""
echo "Step 1: Running pre-flight checks..."
echo "------------------------------------------------------------------------"
bash "$(dirname "$0")/preflight_checks.sh"

if [ $? -ne 0 ]; then
    echo ""
    echo "Pre-flight checks failed! Fix errors above before continuing."
    exit 1
fi

echo ""
echo "Step 2: Final confirmation"
echo "------------------------------------------------------------------------"
echo ""
echo "This will:"
echo "  - Transfer ~15.5 TB total (bidirectional)"
echo "  - Delete 2,147 lower quality files"
echo "  - Take ~45-52 hours to complete"
echo ""
echo "The script will run unattended in a screen session."
echo "You can detach and it will continue running."
echo ""
read -p "Start Project Mother execution? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cancelled. Type 'yes' to proceed."
    exit 1
fi

echo ""
echo "Step 3: Starting execution in screen..."
echo "------------------------------------------------------------------------"

# Check if screen is available
if ! command -v screen &> /dev/null; then
    echo "ERROR: screen not found! Install with: apt install screen"
    exit 1
fi

# Start in screen
echo ""
echo "Starting screen session: project-mother"
echo ""
echo "Commands:"
echo "  Detach: Ctrl+A, then D"
echo "  Reattach: screen -r project-mother"
echo "  View logs: tail -f /opt/mother/logs/project_mother_*.log"
echo ""
echo "Starting in 3 seconds..."
sleep 3

screen -S project-mother bash "$(dirname "$0")/project_mother_master.sh"

echo ""
echo "Screen session ended. Check status:"
echo "  screen -ls"
echo ""
echo "Verify completion:"
echo "  bash $(dirname "$0")/verify_completion.sh"
echo ""
