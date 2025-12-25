#!/bin/bash

###############################################################################
# Comprehensive Inventory Generation Runner
#
# Purpose: Generate all media library inventories for Ali and Chris
# Location: Run this on Mother server (has access to both networks)
# Time: Expect 1-2 days for all libraries
#
# Author: Project Mother
# Last Updated: 2024-12-23
###############################################################################

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="/opt/mother/inventories"
LOG_FILE="/opt/mother/logs/inventory_generation.log"

# Paths (adjust these to match your actual mount points)
ALI_MOVIES="/mnt/unraid/media/Movies"
ALI_4K_MOVIES="/mnt/unraid/media/4K Movies"
ALI_TV="/mnt/unraid/media/TV Shows"
ALI_4K_TV="/mnt/unraid/media/4K TV Shows"

CHRIS_MOVIES="/mnt/synology/rs-movies/movies"
CHRIS_4K_MOVIES="/mnt/synology/rs-4kmedia/4kmovies"
CHRIS_TV="/mnt/synology/rs-tv/tv"
CHRIS_4K_TV="/mnt/synology/rs-4kmedia/4ktv"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

###############################################################################
# Functions
###############################################################################

log() {
    echo -e "${1}" | tee -a "$LOG_FILE"
}

log_info() {
    log "${GREEN}[INFO]${NC} ${1}"
}

log_warn() {
    log "${YELLOW}[WARN]${NC} ${1}"
}

log_error() {
    log "${RED}[ERROR]${NC} ${1}"
}

log_section() {
    log "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log "${BLUE}${1}${NC}"
    log "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

generate_inventory() {
    local path=$1
    local output_name=$2
    local description=$3
    
    log_section "Generating: $description"
    log_info "Path: $path"
    log_info "Output: ${OUTPUT_DIR}/${output_name}"
    
    if [ ! -d "$path" ]; then
        log_error "Path not found: $path"
        log_error "Make sure NFS/SMB mounts are configured!"
        return 1
    fi
    
    log_info "Starting scan (this will take hours)..."
    local start_time=$(date +%s)
    
    # Run the Python script
    # Note: --hash flag is NOT used (too slow)
    if python3 "${SCRIPT_DIR}/generate_inventory.py" \
        "$path" \
        -o "${OUTPUT_DIR}/${output_name}" \
        >> "$LOG_FILE" 2>&1; then
        
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        local hours=$((duration / 3600))
        local minutes=$(((duration % 3600) / 60))
        
        log_info "✅ Completed in ${hours}h ${minutes}m"
        log_info "Files created:"
        log_info "  - ${OUTPUT_DIR}/${output_name}.json"
        log_info "  - ${OUTPUT_DIR}/${output_name}.csv"
        
        return 0
    else
        log_error "❌ Failed to generate inventory"
        return 1
    fi
}

check_prerequisites() {
    log_section "Checking Prerequisites"
    
    # Check Python
    if ! command -v python3 &> /dev/null; then
        log_error "Python 3 is not installed"
        exit 1
    fi
    log_info "✅ Python 3 found"
    
    # Check script exists
    if [ ! -f "${SCRIPT_DIR}/generate_inventory.py" ]; then
        log_error "generate_inventory.py not found in $SCRIPT_DIR"
        exit 1
    fi
    log_info "✅ generate_inventory.py found"
    
    # Check if mediainfo is installed (optional but recommended)
    if command -v mediainfo &> /dev/null; then
        log_info "✅ mediainfo found (will extract detailed metadata)"
    else
        log_warn "⚠️  mediainfo not installed (will use filename analysis only)"
        log_warn "   Install with: sudo apt install mediainfo"
    fi
    
    # Create output directory
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$(dirname "$LOG_FILE")"
    log_info "✅ Output directory ready: $OUTPUT_DIR"
}

show_summary() {
    log_section "Inventory Generation Summary"
    
    log "Generated files in: $OUTPUT_DIR"
    ls -lh "$OUTPUT_DIR" | tail -n +2
    
    log "\nNext steps:"
    log "1. Review the generated JSON/CSV files"
    log "2. Use compare_libraries.py to compare Ali vs Chris"
    log ""
    log "Example comparison commands:"
    log "  python3 scripts/compare_libraries.py \\"
    log "    ${OUTPUT_DIR}/ali_movies.json \\"
    log "    ${OUTPUT_DIR}/chris_movies.json \\"
    log "    -o ${OUTPUT_DIR}/reports"
}

###############################################################################
# Main Script
###############################################################################

main() {
    log_section "Comprehensive Inventory Generation Started"
    log "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    log "This will take 1-2 days to complete all libraries!"
    log "Running in background is recommended (use screen or tmux)"
    
    check_prerequisites
    
    log_warn "\n⏱️  IMPORTANT: This process will take a LONG time!"
    log_warn "    - Each library: 6-12 hours"
    log_warn "    - Total time: 1-2 days"
    log_warn "    - Hashing is DISABLED (would take weeks)"
    
    read -p "Continue? (yes/no): " confirm
    if [ "$confirm" != "yes" ]; then
        log "Cancelled by user"
        exit 0
    fi
    
    local failed=0
    
    # Ali's Libraries
    log_section "PHASE 1: Ali's Libraries"
    
    generate_inventory "$ALI_MOVIES" "ali_movies" "Ali's HD Movies" || ((failed++))
    generate_inventory "$ALI_4K_MOVIES" "ali_4kmovies" "Ali's 4K Movies" || ((failed++))
    generate_inventory "$ALI_TV" "ali_tv" "Ali's HD TV Shows" || ((failed++))
    generate_inventory "$ALI_4K_TV" "ali_4ktv" "Ali's 4K TV Shows" || ((failed++))
    
    # Chris's Libraries
    log_section "PHASE 2: Chris's Libraries"
    
    generate_inventory "$CHRIS_MOVIES" "chris_movies" "Chris's HD Movies" || ((failed++))
    generate_inventory "$CHRIS_4K_MOVIES" "chris_4kmovies" "Chris's 4K Movies" || ((failed++))
    generate_inventory "$CHRIS_TV" "chris_tv" "Chris's HD TV Shows" || ((failed++))
    generate_inventory "$CHRIS_4K_TV" "chris_4ktv" "Chris's 4K TV Shows" || ((failed++))
    
    # Summary
    show_summary
    
    if [ $failed -eq 0 ]; then
        log_section "All Inventories Generated Successfully! ✅"
    else
        log_section "Completed with $failed Failures ❌"
        log_error "Check $LOG_FILE for details"
        exit 1
    fi
}

# Check if running in screen/tmux
if [ -z "$STY" ] && [ -z "$TMUX" ]; then
    log_warn "⚠️  Not running in screen or tmux!"
    log_warn "   Recommended to run in background:"
    log_warn "   1. screen -S inventory"
    log_warn "   2. ./scripts/run_all_inventories.sh"
    log_warn "   3. Ctrl+A, D to detach"
    log_warn "   4. screen -r inventory to reattach"
    echo ""
fi

# Run main function
main "$@"
