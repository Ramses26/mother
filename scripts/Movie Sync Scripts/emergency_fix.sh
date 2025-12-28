#!/bin/bash

################################################################################
# EMERGENCY FIX - NFS Permission Errors
################################################################################
#
# This fixes the "Operation not permitted" errors you're seeing
# Run this to stop current execution and restart with fix
#
################################################################################

echo "========================================================================"
echo "EMERGENCY FIX - Stopping Current Execution"
echo "========================================================================"
echo ""

# Find and kill rsync processes
echo "Stopping rsync processes..."
pkill -f "rsync.*Movies" || echo "No rsync processes found"

# Kill the master script if running
echo "Stopping project_mother_master..."
pkill -f "project_mother_master" || echo "No master script found"

# Kill screen session
echo "Killing screen session..."
screen -S project-mother -X quit 2>/dev/null || echo "No screen session found"

echo ""
echo "✓ Stopped all Project Mother processes"
echo ""

# Clear state file
if [ -f "/opt/mother/.project_mother_state" ]; then
    echo "Clearing state file..."
    rm -f /opt/mother/.project_mother_state
    echo "✓ State cleared"
fi

echo ""
echo "========================================================================"
echo "APPLYING FIX"
echo "========================================================================"
echo ""

# The fix has already been applied to the master script
# It adds: --no-perms --no-owner --no-group to rsync commands

echo "The fixed master script is already in place."
echo "It now uses: rsync -avh --no-perms --no-owner --no-group"
echo ""
echo "This skips trying to set permissions/ownership on NFS mounts."
echo ""

echo "========================================================================"
echo "RESTART"
echo "========================================================================"
echo ""
echo "To restart with the fix:"
echo ""
echo "  bash quick_start.sh"
echo ""
echo "Or manually:"
echo "  screen -S project-mother"
echo "  bash project_mother_master.sh"
echo ""

echo "The script will start fresh (state was cleared)."
echo ""
