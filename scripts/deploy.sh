#!/bin/bash

###############################################################################
# Mother Deployment Script
# 
# Purpose: Deploy or update Mother server stack
# Features:
#   - Pull latest images
#   - Stop running containers
#   - Start containers with new configuration
#   - Verify health
#
# Author: Project Mother
# Last Updated: 2024-12-23
###############################################################################

set -e  # Exit on error

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_FILE="/opt/mother/logs/deployment_$(date +%Y%m%d_%H%M%S).log"

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
    log "${GREEN}[INFO]${NC} ${2}"
}

log_warn() {
    log "${YELLOW}[WARN]${NC} ${2}"
}

log_error() {
    log "${RED}[ERROR]${NC} ${2}"
}

log_section() {
    log "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log "${BLUE}${1}${NC}"
    log "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"
}

check_prerequisites() {
    log_section "Checking Prerequisites"
    
    # Check if Docker is installed
    if ! command -v docker &> /dev/null; then
        log_error "Docker is not installed"
        exit 1
    fi
    log_info "✅ Docker is installed"
    
    # Check if docker-compose is available
    if ! docker compose version &> /dev/null; then
        log_error "Docker Compose plugin is not installed"
        exit 1
    fi
    log_info "✅ Docker Compose is available"
    
    # Check if .env file exists
    if [ ! -f "$PROJECT_DIR/.env" ]; then
        log_error ".env file not found at $PROJECT_DIR/.env"
        log_error "Copy .env.example to .env and configure it first"
        exit 1
    fi
    log_info "✅ .env file exists"
    
    # Check if docker-compose.yml exists
    if [ ! -f "$PROJECT_DIR/docker-compose.yml" ]; then
        log_error "docker-compose.yml not found"
        exit 1
    fi
    log_info "✅ docker-compose.yml exists"
}

backup_configs() {
    log_section "Backing Up Configurations"
    
    BACKUP_DIR="/opt/mother/backups/pre-deployment_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    
    if [ -d "/opt/mother/configs" ]; then
        log_info "Backing up configs to $BACKUP_DIR"
        cp -r /opt/mother/configs "$BACKUP_DIR/"
        log_info "✅ Configs backed up"
    else
        log_warn "No configs directory found (first deployment?)"
    fi
    
    # Backup .env and docker-compose.yml
    cp "$PROJECT_DIR/.env" "$BACKUP_DIR/.env.backup"
    cp "$PROJECT_DIR/docker-compose.yml" "$BACKUP_DIR/docker-compose.yml.backup"
    log_info "✅ .env and docker-compose.yml backed up"
}

pull_images() {
    log_section "Pulling Latest Images"
    
    cd "$PROJECT_DIR"
    log_info "Pulling images..."
    docker compose pull
    log_info "✅ Images pulled"
}

stop_containers() {
    log_section "Stopping Containers"
    
    cd "$PROJECT_DIR"
    if docker compose ps --quiet | grep -q .; then
        log_info "Stopping containers..."
        docker compose down
        log_info "✅ Containers stopped"
    else
        log_info "No running containers"
    fi
}

start_containers() {
    log_section "Starting Containers"
    
    cd "$PROJECT_DIR"
    log_info "Starting containers..."
    docker compose up -d
    log_info "✅ Containers started"
}

verify_health() {
    log_section "Verifying Container Health"
    
    cd "$PROJECT_DIR"
    
    sleep 5  # Give containers time to start
    
    log_info "Container status:"
    docker compose ps
    
    # Check if all containers are running
    local failed_containers=$(docker compose ps --format json | jq -r 'select(.State != "running") | .Name')
    
    if [ -n "$failed_containers" ]; then
        log_error "Some containers are not running:"
        echo "$failed_containers"
        log_error "Check logs with: docker compose logs [container_name]"
        return 1
    else
        log_info "✅ All containers are running"
    fi
}

show_urls() {
    log_section "Access URLs"
    
    # Get IP address
    IP=$(hostname -I | awk '{print $1}')
    
    log "Service URLs:"
    log "  qBittorrent:     http://${IP}:8080"
    log "  Radarr HD:       http://${IP}:7878"
    log "  Radarr 4K:       http://${IP}:7879"
    log "  Sonarr HD:       http://${IP}:8989"
    log "  Sonarr 4K:       http://${IP}:8990"
    log "  Prowlarr:        http://${IP}:9696"
    log "  Seerr (Ali):     http://${IP}:5055"
    log "  Seerr (Chris):   http://${IP}:5056"
    log "  NPM:             http://${IP}:81"
}

###############################################################################
# Main Script
###############################################################################

main() {
    log_section "Mother Deployment Script Started"
    log "Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
    log "User: $(whoami)"
    log "Project Dir: $PROJECT_DIR"
    
    # Create log directory
    mkdir -p "$(dirname "$LOG_FILE")"
    
    # Run deployment steps
    check_prerequisites
    backup_configs
    pull_images
    stop_containers
    start_containers
    
    # Verify
    if verify_health; then
        show_urls
        log_section "Deployment Completed Successfully"
        exit 0
    else
        log_error "Deployment completed with errors"
        log_error "Review logs: $LOG_FILE"
        exit 1
    fi
}

# Handle command line arguments
case "${1:-deploy}" in
    deploy)
        main
        ;;
    pull)
        pull_images
        ;;
    stop)
        stop_containers
        ;;
    start)
        start_containers
        ;;
    restart)
        stop_containers
        start_containers
        verify_health
        ;;
    status)
        cd "$PROJECT_DIR"
        docker compose ps
        ;;
    logs)
        cd "$PROJECT_DIR"
        docker compose logs -f "${2:-}"
        ;;
    --help|-h)
        echo "Usage: $0 [COMMAND]"
        echo ""
        echo "Commands:"
        echo "  deploy    Full deployment (default)"
        echo "  pull      Pull latest images"
        echo "  stop      Stop all containers"
        echo "  start     Start all containers"
        echo "  restart   Restart all containers"
        echo "  status    Show container status"
        echo "  logs      Show container logs (optionally specify container)"
        echo ""
        exit 0
        ;;
    *)
        echo "Unknown command: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
esac
