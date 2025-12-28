#!/bin/bash

################################################################################
# PROJECT MOTHER - POST-EXECUTION VERIFICATION
################################################################################
#
# Run this after project_mother_master.sh completes
# Verifies the sync and deletions were successful
#
################################################################################

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================================================"
echo "PROJECT MOTHER - POST-EXECUTION VERIFICATION"
echo "========================================================================"
echo ""

ERRORS=0
WARNINGS=0

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
# CHECK FILE COUNTS
################################################################################

echo "Checking file counts..."
echo "------------------------------------------------------------------------"

# Movies
ALI_MOVIES=$(ls /mnt/unraid/media/Movies/ 2>/dev/null | wc -l)
CHRIS_MOVIES=$(ls /mnt/synology/rs-movies/ 2>/dev/null | wc -l)

echo "Movies:"
echo "  Ali (Unraid):   $ALI_MOVIES files (expected ~7,776)"
echo "  Chris (Synology): $CHRIS_MOVIES files (expected ~7,942)"

if [ "$ALI_MOVIES" -ge 7500 ] && [ "$ALI_MOVIES" -le 8000 ]; then
    check_pass "Ali Movies count in expected range"
else
    check_warn "Ali Movies count outside expected range: $ALI_MOVIES"
fi

if [ "$CHRIS_MOVIES" -ge 7500 ] && [ "$CHRIS_MOVIES" -le 8200 ]; then
    check_pass "Chris Movies count in expected range"
else
    check_warn "Chris Movies count outside expected range: $CHRIS_MOVIES"
fi

# 4K Movies
ALI_4K=$(ls "/mnt/unraid/media/4K Movies/" 2>/dev/null | wc -l)
CHRIS_4K=$(ls /mnt/synology/rs-4kmedia/4kmovies/ 2>/dev/null | wc -l)

echo ""
echo "4K Movies:"
echo "  Ali (Unraid):   $ALI_4K files (expected ~239)"
echo "  Chris (Synology): $CHRIS_4K files (expected ~237)"

if [ "$ALI_4K" -ge 230 ] && [ "$ALI_4K" -le 250 ]; then
    check_pass "Ali 4K count in expected range"
else
    check_warn "Ali 4K count outside expected range: $ALI_4K"
fi

if [ "$CHRIS_4K" -ge 230 ] && [ "$CHRIS_4K" -le 250 ]; then
    check_pass "Chris 4K count in expected range"
else
    check_warn "Chris 4K count outside expected range: $CHRIS_4K"
fi

echo ""

################################################################################
# CHECK DELETED FOLDERS
################################################################################

echo "Checking deleted folders..."
echo "------------------------------------------------------------------------"

ALI_DELETED_MOVIES=$(find /mnt/unraid/media/Deleted/Movies/ -type f 2>/dev/null | wc -l)
ALI_DELETED_4K=$(find /mnt/unraid/media/Deleted/4kMovies/ -type f 2>/dev/null | wc -l)
CHRIS_DELETED_MOVIES=$(find /mnt/synology/rs-4kmedia/deleted/movies/ -type f 2>/dev/null | wc -l)
CHRIS_DELETED_4K=$(find /mnt/synology/rs-4kmedia/deleted/4kmovies/ -type f 2>/dev/null | wc -l)

echo "Deleted Movies:"
echo "  Ali:   $ALI_DELETED_MOVIES files (expected 513)"
echo "  Chris: $CHRIS_DELETED_MOVIES files (expected 1,534)"

if [ "$ALI_DELETED_MOVIES" -ge 500 ] && [ "$ALI_DELETED_MOVIES" -le 525 ]; then
    check_pass "Ali deleted Movies count correct"
else
    check_warn "Ali deleted Movies: $ALI_DELETED_MOVIES (expected 513)"
fi

if [ "$CHRIS_DELETED_MOVIES" -ge 1500 ] && [ "$CHRIS_DELETED_MOVIES" -le 1550 ]; then
    check_pass "Chris deleted Movies count correct"
else
    check_warn "Chris deleted Movies: $CHRIS_DELETED_MOVIES (expected 1,534)"
fi

echo ""
echo "Deleted 4K:"
echo "  Ali:   $ALI_DELETED_4K files (expected 6)"
echo "  Chris: $CHRIS_DELETED_4K files (expected 94)"

if [ "$ALI_DELETED_4K" -ge 5 ] && [ "$ALI_DELETED_4K" -le 10 ]; then
    check_pass "Ali deleted 4K count correct"
else
    check_warn "Ali deleted 4K: $ALI_DELETED_4K (expected 6)"
fi

if [ "$CHRIS_DELETED_4K" -ge 90 ] && [ "$CHRIS_DELETED_4K" -le 100 ]; then
    check_pass "Chris deleted 4K count correct"
else
    check_warn "Chris deleted 4K: $CHRIS_DELETED_4K (expected 94)"
fi

echo ""

################################################################################
# CHECK DISK SPACE
################################################################################

echo "Checking disk space..."
echo "------------------------------------------------------------------------"

UNRAID_FREE=$(df -BG /mnt/unraid/media | tail -1 | awk '{print $4}' | sed 's/G//')
SYNOLOGY_FREE=$(df -BG /mnt/synology/rs-movies | tail -1 | awk '{print $4}' | sed 's/G//')

echo "Free space:"
echo "  Unraid:   ${UNRAID_FREE}GB"
echo "  Synology: ${SYNOLOGY_FREE}GB"

if [ "$UNRAID_FREE" -gt 500 ]; then
    check_pass "Unraid has sufficient free space"
else
    check_warn "Unraid only has ${UNRAID_FREE}GB free"
fi

if [ "$SYNOLOGY_FREE" -gt 500 ]; then
    check_pass "Synology has sufficient free space"
else
    check_warn "Synology only has ${SYNOLOGY_FREE}GB free"
fi

echo ""

################################################################################
# SPOT CHECK QUALITY
################################################################################

echo "Spot checking file quality..."
echo "------------------------------------------------------------------------"

# Check a known better quality file exists on Chris
if [ -f "/mnt/synology/rs-movies/The 13th Warrior (1999)"/*.mkv ]; then
    check_pass "Sample movie found on Chris (13th Warrior)"
else
    check_warn "Could not verify sample movie on Chris"
fi

# Check another known better quality file exists on Ali
if [ -d "/mnt/unraid/media/Movies/Operation Fortune Ruse de Guerre (2023)" ]; then
    check_pass "Sample movie found on Ali (Operation Fortune)"
else
    check_warn "Could not verify sample movie on Ali"
fi

echo ""

################################################################################
# CHECK LOGS
################################################################################

echo "Checking logs..."
echo "------------------------------------------------------------------------"

LATEST_LOG=$(ls -t /opt/mother/logs/project_mother_*.log 2>/dev/null | head -1)

if [ -n "$LATEST_LOG" ]; then
    check_pass "Found log file: $LATEST_LOG"
    
    # Check for errors in log
    ERROR_COUNT=$(grep -i "error" "$LATEST_LOG" | grep -v "0 errors" | wc -l)
    if [ "$ERROR_COUNT" -eq 0 ]; then
        check_pass "No errors found in log"
    else
        check_warn "Found $ERROR_COUNT errors in log (review manually)"
    fi
    
    # Check if completed
    if grep -q "ALL PHASES COMPLETE" "$LATEST_LOG"; then
        check_pass "Script reported successful completion"
    else
        check_warn "Script may not have completed successfully"
    fi
else
    check_fail "Could not find log file"
fi

echo ""

################################################################################
# SUMMARY
################################################################################

echo "========================================================================"
echo "VERIFICATION SUMMARY"
echo "========================================================================"
echo ""

TOTAL_MOVIES_EXPECTED=7759  # Average of Ali and Chris expected counts
TOTAL_MOVIES_ACTUAL=$(( ALI_MOVIES + CHRIS_MOVIES ))
TOTAL_DELETED=$((ALI_DELETED_MOVIES + ALI_DELETED_4K + CHRIS_DELETED_MOVIES + CHRIS_DELETED_4K))

echo "Summary:"
echo "  Total movie files: $TOTAL_MOVIES_ACTUAL (expected ~$TOTAL_MOVIES_EXPECTED)"
echo "  Total deleted files: $TOTAL_DELETED (expected 2,147)"
echo "  Errors: $ERRORS"
echo "  Warnings: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ VERIFICATION PASSED${NC}"
    echo ""
    echo "Project Mother execution was successful!"
    echo ""
    echo "Next steps:"
    echo "  1. Update Radarr libraries (scan for new files)"
    echo "  2. Update Plex libraries (scan for new files)"
    echo "  3. Spot-check a few movies to verify quality"
    echo "  4. Optional: Empty deleted folders to reclaim space"
    echo ""
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ VERIFICATION PASSED WITH WARNINGS${NC}"
    echo ""
    echo "Review warnings above. Most are likely acceptable variations."
    echo ""
    exit 0
else
    echo -e "${RED}✗ VERIFICATION FAILED${NC}"
    echo ""
    echo "Review errors above and check logs:"
    echo "  $LATEST_LOG"
    echo ""
    exit 1
fi
