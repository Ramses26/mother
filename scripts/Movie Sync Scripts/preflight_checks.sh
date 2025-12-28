#!/bin/bash

################################################################################
# PROJECT MOTHER - PRE-FLIGHT CHECKS
################################################################################
#
# Verifies system is ready for unattended overnight execution
# Run this BEFORE the main script
#
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

echo "========================================================================"
echo "PROJECT MOTHER - PRE-FLIGHT CHECKS"
echo "========================================================================"
echo ""

# Function to check and report
check_pass() {
    echo -e "${GREEN}✓${NC} $1"
}

check_fail() {
    echo -e "${RED}✗${NC} $1"
    ((ERRORS++))
}

check_warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

################################################################################
# CHECK 1: Verify we're running on Mother
################################################################################

echo "CHECK 1: Verify running on Mother server"
echo "------------------------------------------------------------------------"

HOSTNAME=$(hostname)
if [[ "$HOSTNAME" == "mother" ]]; then
    check_pass "Running on Mother server"
else
    check_warn "Hostname is '$HOSTNAME' (expected 'mother')"
fi
echo ""

################################################################################
# CHECK 2: Verify all mounts are active
################################################################################

echo "CHECK 2: Verify NFS mounts"
echo "------------------------------------------------------------------------"

# Check Unraid mount
if mount | grep -q "/mnt/unraid/media"; then
    check_pass "Unraid mounted at /mnt/unraid/media"
    
    # Verify it's accessible
    if [ -d "/mnt/unraid/media/Movies" ]; then
        check_pass "Unraid Movies directory accessible"
    else
        check_fail "Unraid Movies directory NOT accessible"
    fi
else
    check_fail "Unraid NOT mounted at /mnt/unraid/media"
fi

# Check Synology Movies mount
if mount | grep -q "/mnt/synology/rs-movies"; then
    check_pass "Synology Movies mounted at /mnt/synology/rs-movies"
else
    check_fail "Synology Movies NOT mounted"
fi

# Check Synology 4K mount
if mount | grep -q "/mnt/synology/rs-4kmedia/4kmovies"; then
    check_pass "Synology 4K mounted at /mnt/synology/rs-4kmedia/4kmovies"
else
    check_fail "Synology 4K NOT mounted"
fi

echo ""

################################################################################
# CHECK 3: Verify disk space
################################################################################

echo "CHECK 3: Verify sufficient disk space"
echo "------------------------------------------------------------------------"

# Function to get available space in GB
get_free_space() {
    df -BG "$1" | tail -1 | awk '{print $4}' | sed 's/G//'
}

# Check Unraid space (needs ~2.3 TB = 2300 GB)
UNRAID_FREE=$(get_free_space "/mnt/unraid/media")
if [ "$UNRAID_FREE" -gt 2300 ]; then
    check_pass "Unraid has ${UNRAID_FREE}GB free (need 2300GB)"
elif [ "$UNRAID_FREE" -gt 2000 ]; then
    check_warn "Unraid has ${UNRAID_FREE}GB free (recommended 2300GB)"
else
    check_fail "Unraid has only ${UNRAID_FREE}GB free (need 2300GB)"
fi

# Check Synology space (needs ~2.3 TB = 2300 GB)
SYNOLOGY_FREE=$(get_free_space "/mnt/synology/rs-movies")
if [ "$SYNOLOGY_FREE" -gt 2300 ]; then
    check_pass "Synology has ${SYNOLOGY_FREE}GB free (need 2300GB)"
elif [ "$SYNOLOGY_FREE" -gt 2000 ]; then
    check_warn "Synology has ${SYNOLOGY_FREE}GB free (recommended 2300GB)"
else
    check_fail "Synology has only ${SYNOLOGY_FREE}GB free (need 2300GB)"
fi

echo ""

################################################################################
# CHECK 4: Verify write permissions
################################################################################

echo "CHECK 4: Verify write permissions"
echo "------------------------------------------------------------------------"

# Test write to Unraid
TEST_FILE="/mnt/unraid/media/Movies/.project_mother_test_$$"
if touch "$TEST_FILE" 2>/dev/null; then
    rm "$TEST_FILE"
    check_pass "Write permission to Unraid Movies"
else
    check_fail "NO write permission to Unraid Movies"
fi

# Test write to Synology
TEST_FILE="/mnt/synology/rs-movies/.project_mother_test_$$"
if touch "$TEST_FILE" 2>/dev/null; then
    rm "$TEST_FILE"
    check_pass "Write permission to Synology Movies"
else
    check_fail "NO write permission to Synology Movies"
fi

# Test write to Deleted folders
if [ ! -d "/mnt/synology/rs-4kmedia/deleted/movies" ]; then
    check_warn "Synology deleted/movies folder does not exist (will be created)"
fi

if [ ! -d "/mnt/unraid/media/Deleted/Movies" ]; then
    check_warn "Unraid Deleted/Movies folder does not exist (will be created)"
fi

echo ""

################################################################################
# CHECK 5: Verify no processes holding locks
################################################################################

echo "CHECK 5: Check for existing processes"
echo "------------------------------------------------------------------------"

if pgrep -f "project_mother" > /dev/null; then
    check_warn "Found existing project_mother processes"
    pgrep -af "project_mother"
else
    check_pass "No existing project_mother processes"
fi

if pgrep -f "rsync.*Movies" > /dev/null; then
    check_warn "Found existing rsync processes"
    pgrep -af "rsync.*Movies"
else
    check_pass "No existing rsync processes"
fi

echo ""

################################################################################
# CHECK 6: Verify rsync is available
################################################################################

echo "CHECK 6: Verify required tools"
echo "------------------------------------------------------------------------"

if command -v rsync &> /dev/null; then
    RSYNC_VER=$(rsync --version | head -1)
    check_pass "rsync available: $RSYNC_VER"
else
    check_fail "rsync NOT found"
fi

if command -v screen &> /dev/null; then
    check_pass "screen available"
else
    check_warn "screen not found (recommended for long operations)"
fi

echo ""

################################################################################
# CHECK 7: Network connectivity
################################################################################

echo "CHECK 7: Network connectivity"
echo "------------------------------------------------------------------------"

# Ping Unraid
if ping -c 1 -W 2 192.168.1.10 &> /dev/null; then
    check_pass "Can ping Unraid (192.168.1.10)"
else
    check_fail "Cannot ping Unraid (192.168.1.10)"
fi

# Ping Synology (Movies)
if ping -c 1 -W 2 10.0.0.160 &> /dev/null; then
    check_pass "Can ping Synology Movies (10.0.0.160)"
else
    check_fail "Cannot ping Synology Movies (10.0.0.160)"
fi

# Ping Synology (4K)
if ping -c 1 -W 2 10.0.1.203 &> /dev/null; then
    check_pass "Can ping Synology 4K (10.0.1.203)"
else
    check_fail "Cannot ping Synology 4K (10.0.1.203)"
fi

echo ""

################################################################################
# CHECK 8: Estimate time required
################################################################################

echo "CHECK 8: Time estimates"
echo "------------------------------------------------------------------------"

echo "Estimated sync time (at 100 MB/s):"
echo "  - Movies sync: ~35-40 hours (12.5 TB)"
echo "  - 4K sync: ~10-12 hours (3.5 TB)"
echo "  - Total: ~45-52 hours"
echo ""
echo "Current time: $(date)"
echo "Estimated completion: $(date -d '+50 hours')"

echo ""

################################################################################
# SUMMARY
################################################################################

echo "========================================================================"
echo "PRE-FLIGHT CHECK SUMMARY"
echo "========================================================================"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ ALL CHECKS PASSED${NC}"
    echo ""
    echo "System is ready for overnight execution!"
    echo ""
    echo "To start:"
    echo "  screen -S project-mother"
    echo "  bash project_mother_master.sh"
    echo "  Ctrl+A, D to detach"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ PASSED WITH $WARNINGS WARNINGS${NC}"
    echo ""
    echo "System is ready but check warnings above."
    echo ""
    echo "Proceed? (y/n)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        exit 0
    else
        exit 1
    fi
else
    echo -e "${RED}✗ FAILED: $ERRORS ERRORS, $WARNINGS WARNINGS${NC}"
    echo ""
    echo "Fix errors above before proceeding!"
    exit 1
fi
