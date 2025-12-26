#!/bin/bash
#
# Run all library comparisons with FIXED script
#
# Usage: ./run_all_comparisons.sh
#

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

echo "================================================================================"
echo "RUNNING ALL LIBRARY COMPARISONS (FIXED VERSION)"
echo "================================================================================"
echo ""

# Create reports directories
mkdir -p reports/{movies,4kmovies,tv,4ktv}

# Compare Movies
echo "📊 Comparing Movies (HD)..."
python3 scripts/compare_libraries.py \
  inventories/ali_movies.json \
  inventories/chris_movies.json \
  -o reports/movies
echo ""

# Compare 4K Movies
echo "📊 Comparing 4K Movies..."
python3 scripts/compare_libraries.py \
  inventories/ali_4kmovies.json \
  inventories/chris_4kmovies.json \
  -o reports/4kmovies
echo ""

# Compare TV Shows
echo "📊 Comparing TV Shows (HD)..."
python3 scripts/compare_libraries.py \
  inventories/ali_tv.json \
  inventories/chris_tv.json \
  -o reports/tv
echo ""

# Compare 4K TV Shows
echo "📊 Comparing 4K TV Shows..."
python3 scripts/compare_libraries.py \
  inventories/ali_4ktv.json \
  inventories/chris_4ktv.json \
  -o reports/4ktv
echo ""

echo "================================================================================"
echo "ALL COMPARISONS COMPLETE!"
echo "================================================================================"
echo ""
echo "Reports generated in:"
echo "  - reports/movies/"
echo "  - reports/4kmovies/"
echo "  - reports/tv/"
echo "  - reports/4ktv/"
echo ""
echo "Next steps:"
echo "  1. Review comparison_summary_*.txt files"
echo "  2. Check for quality differences (Ali better vs Chris better)"
echo "  3. Use sync_intelligent.py to execute syncs"
echo ""
