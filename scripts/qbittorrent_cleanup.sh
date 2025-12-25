#!/bin/bash

###############################################################################
# qBittorrent Torrent Cleanup Script
# 
# Purpose: Remove torrents and their data after specified retention period
# Retention: 90-120 days (configurable)
# Usage: Run via cron daily
#
# Author: Project Mother
# Last Updated: 2024-12-23
###############################################################################

# Configuration
QBITTORRENT_HOST="${QBITTORRENT_HOST:-localhost}"
QBITTORRENT_PORT="${QBITTORRENT_PORT:-8080}"
QBITTORRENT_USERNAME="${QBITTORRENT_USERNAME:-admin}"
QBITTORRENT_PASSWORD="${QBITTORRENT_PASSWORD}"

# Retention period in seconds (90 days = 7776000 seconds, 120 days = 10368000)
MIN_RETENTION_DAYS=${MIN_RETENTION_DAYS:-90}
MAX_RETENTION_DAYS=${MAX_RETENTION_DAYS:-120}
MIN_RETENTION_SECONDS=$((MIN_RETENTION_DAYS * 86400))
MAX_RETENTION_SECONDS=$((MAX_RETENTION_DAYS * 86400))

# Logging
LOG_FILE="/opt/mother/logs/qbittorrent_cleanup.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

###############################################################################
# Functions
###############################################################################

log() {
    echo -e "${TIMESTAMP} - $1" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
}

# Login to qBittorrent and get cookie
qbt_login() {
    log_info "Logging into qBittorrent..."
    
    COOKIE_FILE="/tmp/qbt_cookie_$$"
    
    curl -s -c "$COOKIE_FILE" \
         -d "username=${QBITTORRENT_USERNAME}&password=${QBITTORRENT_PASSWORD}" \
         "http://${QBITTORRENT_HOST}:${QBITTORRENT_PORT}/api/v2/auth/login" > /dev/null
    
    if [ $? -eq 0 ]; then
        log_info "Successfully logged in to qBittorrent"
        return 0
    else
        log_error "Failed to login to qBittorrent"
        return 1
    fi
}

# Get list of all torrents
qbt_get_torrents() {
    curl -s -b "$COOKIE_FILE" \
         "http://${QBITTORRENT_HOST}:${QBITTORRENT_PORT}/api/v2/torrents/info"
}

# Delete torrent and data
qbt_delete_torrent() {
    local hash=$1
    local name=$2
    
    log_info "Deleting torrent: $name (Hash: $hash)"
    
    curl -s -b "$COOKIE_FILE" \
         -d "hashes=${hash}&deleteFiles=true" \
         "http://${QBITTORRENT_HOST}:${QBITTORRENT_PORT}/api/v2/torrents/delete"
    
    if [ $? -eq 0 ]; then
        log_info "Successfully deleted: $name"
        return 0
    else
        log_error "Failed to delete: $name"
        return 1
    fi
}

# Logout from qBittorrent
qbt_logout() {
    curl -s -b "$COOKIE_FILE" \
         "http://${QBITTORRENT_HOST}:${QBITTORRENT_PORT}/api/v2/auth/logout" > /dev/null
    
    rm -f "$COOKIE_FILE"
    log_info "Logged out from qBittorrent"
}

###############################################################################
# Main Script
###############################################################################

main() {
    log_info "========================================="
    log_info "qBittorrent Cleanup Script Started"
    log_info "Retention: ${MIN_RETENTION_DAYS}-${MAX_RETENTION_DAYS} days"
    log_info "========================================="
    
    # Check if password is set
    if [ -z "$QBITTORRENT_PASSWORD" ]; then
        log_error "QBITTORRENT_PASSWORD environment variable not set"
        exit 1
    fi
    
    # Login
    if ! qbt_login; then
        log_error "Cannot proceed without login"
        exit 1
    fi
    
    # Get current timestamp
    CURRENT_TIME=$(date +%s)
    
    # Get all torrents
    log_info "Fetching torrent list..."
    TORRENTS=$(qbt_get_torrents)
    
    if [ -z "$TORRENTS" ]; then
        log_warn "No torrents found or failed to fetch list"
        qbt_logout
        exit 0
    fi
    
    # Process torrents
    DELETED_COUNT=0
    KEPT_COUNT=0
    TOTAL_COUNT=$(echo "$TORRENTS" | jq '. | length')
    
    log_info "Processing $TOTAL_COUNT torrents..."
    
    echo "$TORRENTS" | jq -c '.[]' | while read -r torrent; do
        HASH=$(echo "$torrent" | jq -r '.hash')
        NAME=$(echo "$torrent" | jq -r '.name')
        ADDED_ON=$(echo "$torrent" | jq -r '.added_on')
        STATE=$(echo "$torrent" | jq -r '.state')
        CATEGORY=$(echo "$torrent" | jq -r '.category')
        COMPLETION_ON=$(echo "$torrent" | jq -r '.completion_on')
        
        # Calculate age in seconds (from completion time if available, otherwise added time)
        if [ "$COMPLETION_ON" != "null" ] && [ "$COMPLETION_ON" -gt 0 ]; then
            AGE=$((CURRENT_TIME - COMPLETION_ON))
        else
            AGE=$((CURRENT_TIME - ADDED_ON))
        fi
        
        AGE_DAYS=$((AGE / 86400))
        
        # Determine if torrent should be deleted
        SHOULD_DELETE=false
        
        # Strategy: Delete torrents that are completed and older than retention period
        if [ "$STATE" == "uploading" ] || [ "$STATE" == "stalledUP" ] || [ "$STATE" == "pausedUP" ]; then
            # Torrent is completed and seeding
            if [ $AGE -ge $MIN_RETENTION_SECONDS ]; then
                # Use randomization to delete between MIN and MAX days
                # This prevents all torrents from being deleted at once
                RANDOM_THRESHOLD=$((MIN_RETENTION_SECONDS + RANDOM % (MAX_RETENTION_SECONDS - MIN_RETENTION_SECONDS)))
                
                if [ $AGE -ge $RANDOM_THRESHOLD ]; then
                    SHOULD_DELETE=true
                fi
            fi
        fi
        
        if [ "$SHOULD_DELETE" == "true" ]; then
            log_info "Torrent eligible for deletion: $NAME (Age: ${AGE_DAYS} days, Category: $CATEGORY)"
            
            # Uncomment the line below to actually delete (currently in dry-run mode)
            # qbt_delete_torrent "$HASH" "$NAME"
            echo "  [DRY RUN] Would delete: $NAME" | tee -a "$LOG_FILE"
            
            ((DELETED_COUNT++))
        else
            log_info "Keeping torrent: $NAME (Age: ${AGE_DAYS} days, State: $STATE)"
            ((KEPT_COUNT++))
        fi
    done
    
    # Logout
    qbt_logout
    
    # Summary
    log_info "========================================="
    log_info "Cleanup Summary:"
    log_info "  Total torrents: $TOTAL_COUNT"
    log_info "  Deleted: $DELETED_COUNT"
    log_info "  Kept: $KEPT_COUNT"
    log_info "========================================="
    log_info "qBittorrent Cleanup Script Completed"
    log_info "========================================="
}

# Run main function
main "$@"
