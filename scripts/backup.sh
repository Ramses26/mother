#!/bin/bash

###############################################################################
# Mother Backup Script
# 
# Purpose: Backup all Mother server configurations and databases
# Features:
#   - Backup all container configs
#   - Backup databases
#   - Compress and archive
#   - Retention management
#   - Optional remote backup
#
# Author: Project Mother
# Last Updated: 2024-12-23
###############################################################################

set -e

# Configuration
BACKUP_DIR="/opt/mother/backups"
CONFIG_DIR="/opt/mother/configs"
PROJECT_DIR="/opt/mother"
RETENTION_DAYS=30
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="mother_backup_${TIMESTAMP}"
BACKUP_PATH="${BACKUP_DIR}/${BACKUP_NAME}"

# Remote backup (optional)
REMOTE_BACKUP_ENABLED="${REMOTE_BACKUP_ENABLED:-false}"
REMOTE_BACKUP_PATH="${REMOTE_BACKUP_PATH:-}"

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
    echo -e "${1}"
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

create_backup_directory() {
    log_section "Creating Backup Directory"
    
    mkdir -p "$BACKUP_PATH"
    log_info "Created: $BACKUP_PATH"
}

backup_configs() {
    log_section "Backing Up Configurations"
    
    if [ -d "$CONFIG_DIR" ]; then
        log_info "Backing up configs..."
        cp -r "$CONFIG_DIR" "$BACKUP_PATH/configs"
        log_info "✅ Configs backed up"
    else
        log_warn "No configs directory found"
    fi
}

backup_compose_files() {
    log_section "Backing Up Docker Compose Files"
    
    mkdir -p "$BACKUP_PATH/compose"
    
    if [ -f "$PROJECT_DIR/.env" ]; then
        cp "$PROJECT_DIR/.env" "$BACKUP_PATH/compose/.env"
        log_info "✅ .env file backed up"
    fi
    
    if [ -f "$PROJECT_DIR/docker-compose.yml" ]; then
        cp "$PROJECT_DIR/docker-compose.yml" "$BACKUP_PATH/compose/docker-compose.yml"
        log_info "✅ docker-compose.yml backed up"
    fi
}

backup_scripts() {
    log_section "Backing Up Scripts"
    
    if [ -d "$PROJECT_DIR/scripts" ]; then
        log_info "Backing up scripts..."
        cp -r "$PROJECT_DIR/scripts" "$BACKUP_PATH/scripts"
        log_info "✅ Scripts backed up"
    fi
}

backup_databases() {
    log_section "Backing Up Databases"
    
    mkdir -p "$BACKUP_PATH/databases"
    
    # qBittorrent
    if docker ps --format '{{.Names}}' | grep -q "qbittorrent"; then
        log_info "Backing up qBittorrent database..."
        docker exec qbittorrent cat /config/qBittorrent/qBittorrent.conf > "$BACKUP_PATH/databases/qbittorrent.conf" 2>/dev/null || true
        docker exec qbittorrent tar czf - /config/qBittorrent/BT_backup > "$BACKUP_PATH/databases/qbittorrent_torrents.tar.gz" 2>/dev/null || true
        log_info "✅ qBittorrent backed up"
    fi
    
    # Radarr instances
    for instance in radarr-hd radarr-4k; do
        if docker ps --format '{{.Names}}' | grep -q "$instance"; then
            log_info "Backing up $instance database..."
            docker exec "$instance" cat /config/config.xml > "$BACKUP_PATH/databases/${instance}_config.xml" 2>/dev/null || true
            docker exec "$instance" cat /config/nzbdrone.db > "$BACKUP_PATH/databases/${instance}.db" 2>/dev/null || true
            log_info "✅ $instance backed up"
        fi
    done
    
    # Sonarr instances
    for instance in sonarr-hd sonarr-4k; do
        if docker ps --format '{{.Names}}' | grep -q "$instance"; then
            log_info "Backing up $instance database..."
            docker exec "$instance" cat /config/config.xml > "$BACKUP_PATH/databases/${instance}_config.xml" 2>/dev/null || true
            docker exec "$instance" cat /config/nzbdrone.db > "$BACKUP_PATH/databases/${instance}.db" 2>/dev/null || true
            log_info "✅ $instance backed up"
        fi
    done
    
    # Prowlarr
    if docker ps --format '{{.Names}}' | grep -q "prowlarr"; then
        log_info "Backing up Prowlarr database..."
        docker exec prowlarr cat /config/config.xml > "$BACKUP_PATH/databases/prowlarr_config.xml" 2>/dev/null || true
        docker exec prowlarr cat /config/prowlarr.db > "$BACKUP_PATH/databases/prowlarr.db" 2>/dev/null || true
        log_info "✅ Prowlarr backed up"
    fi
    
    # Seerr instances
    for instance in seerr-ali seerr-chris; do
        if docker ps --format '{{.Names}}' | grep -q "$instance"; then
            log_info "Backing up $instance database..."
            docker exec "$instance" cat /app/config/db/db.sqlite3 > "$BACKUP_PATH/databases/${instance}.db" 2>/dev/null || true
            log_info "✅ $instance backed up"
        fi
    done
}

create_archive() {
    log_section "Creating Compressed Archive"
    
    cd "$BACKUP_DIR"
    log_info "Compressing backup..."
    tar czf "${BACKUP_NAME}.tar.gz" "$BACKUP_NAME"
    
    # Get size
    SIZE=$(du -h "${BACKUP_NAME}.tar.gz" | cut -f1)
    log_info "✅ Archive created: ${BACKUP_NAME}.tar.gz ($SIZE)"
    
    # Remove uncompressed directory
    rm -rf "$BACKUP_NAME"
    log_info "Cleaned up temporary files"
}

remote_backup() {
    if [ "$REMOTE_BACKUP_ENABLED" == "true" ]; then
        log_section "Uploading to Remote Backup"
        
        if [ -z "$REMOTE_BACKUP_PATH" ]; then
            log_warn "REMOTE_BACKUP_PATH not set, skipping remote backup"
            return
        fi
        
        log_info "Uploading to: $REMOTE_BACKUP_PATH"
        
        # Use rsync if available, otherwise scp
        if command -v rsync &> /dev/null; then
            rsync -avz "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" "$REMOTE_BACKUP_PATH/"
            log_info "✅ Uploaded via rsync"
        elif command -v scp &> /dev/null; then
            scp "${BACKUP_DIR}/${BACKUP_NAME}.tar.gz" "$REMOTE_BACKUP_PATH/"
            log_info "✅ Uploaded via scp"
        else
            log_error "Neither rsync nor scp available for remote backup"
        fi
    fi
}

cleanup_old_backups() {
    log_section "Cleaning Up Old Backups"
    
    log_info "Retention: $RETENTION_DAYS days"
    
    # Find and delete old backups
    OLD_BACKUPS=$(find "$BACKUP_DIR" -name "mother_backup_*.tar.gz" -mtime +$RETENTION_DAYS)
    
    if [ -z "$OLD_BACKUPS" ]; then
        log_info "No old backups to remove"
    else
        log_info "Removing old backups:"
        echo "$OLD_BACKUPS"
        find "$BACKUP_DIR" -name "mother_backup_*.tar.gz" -mtime +$RETENTION_DAYS -delete
        log_info "✅ Old backups removed"
    fi
}

list_backups() {
    log_section "Available Backups"
    
    echo "Local backups in $BACKUP_DIR:"
    ls -lh "$BACKUP_DIR"/mother_backup_*.tar.gz 2>/dev/null || echo "  No backups found"
}

restore_backup() {
    local backup_file=$1
    
    if [ -z "$backup_file" ]; then
        log_error "Please specify backup file to restore"
        log_info "Available backups:"
        ls -1 "$BACKUP_DIR"/mother_backup_*.tar.gz 2>/dev/null || echo "  No backups found"
        exit 1
    fi
    
    if [ ! -f "$backup_file" ]; then
        log_error "Backup file not found: $backup_file"
        exit 1
    fi
    
    log_section "Restoring Backup"
    log_warn "This will overwrite current configuration!"
    read -p "Are you sure? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        log_info "Restore cancelled"
        exit 0
    fi
    
    log_info "Stopping containers..."
    cd "$PROJECT_DIR"
    docker compose down
    
    log_info "Extracting backup..."
    tar xzf "$backup_file" -C /tmp/
    
    EXTRACT_DIR=$(basename "$backup_file" .tar.gz)
    
    log_info "Restoring configs..."
    cp -r "/tmp/${EXTRACT_DIR}/configs/"* "$CONFIG_DIR/"
    
    log_info "Restoring compose files..."
    cp "/tmp/${EXTRACT_DIR}/compose/.env" "$PROJECT_DIR/.env"
    cp "/tmp/${EXTRACT_DIR}/compose/docker-compose.yml" "$PROJECT_DIR/docker-compose.yml"
    
    log_info "Cleanup..."
    rm -rf "/tmp/${EXTRACT_DIR}"
    
    log_info "Starting containers..."
    docker compose up -d
    
    log_section "Restore Complete"
    log_info "Please verify all services are working correctly"
}

###############################################################################
# Main Script
###############################################################################

main_backup() {
    log_section "Mother Backup Script Started"
    log "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    
    # Create backup directory structure
    mkdir -p "$BACKUP_DIR"
    
    # Execute backup steps
    create_backup_directory
    backup_configs
    backup_compose_files
    backup_scripts
    backup_databases
    create_archive
    remote_backup
    cleanup_old_backups
    
    log_section "Backup Complete"
    log_info "Backup location: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
    log_info "To restore, run: $0 restore ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
}

# Handle command line arguments
case "${1:-backup}" in
    backup)
        main_backup
        ;;
    list)
        list_backups
        ;;
    restore)
        restore_backup "$2"
        ;;
    --help|-h)
        echo "Usage: $0 [COMMAND] [OPTIONS]"
        echo ""
        echo "Commands:"
        echo "  backup    Create a new backup (default)"
        echo "  list      List available backups"
        echo "  restore   Restore from backup"
        echo ""
        echo "Examples:"
        echo "  $0                                    # Create backup"
        echo "  $0 list                              # List backups"
        echo "  $0 restore /path/to/backup.tar.gz   # Restore backup"
        echo ""
        exit 0
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac
