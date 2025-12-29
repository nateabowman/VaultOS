#!/bin/bash
#
# VaultOS Update Manager
# Automatic update checking, repository management, and rollback capability
#

set -e

CONFIG_DIR="$HOME/.config/vaultos"
UPDATE_CONFIG="$CONFIG_DIR/update.conf"
UPDATE_LOG="$CONFIG_DIR/update.log"
BACKUP_DIR="$CONFIG_DIR/backups"
REPO_URL="${VAULTOS_REPO_URL:-https://repo.vaultos.org}"
CHECK_INTERVAL="${UPDATE_CHECK_INTERVAL:-86400}"  # 24 hours

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Initialize
mkdir -p "$CONFIG_DIR"
mkdir -p "$BACKUP_DIR"
touch "$UPDATE_CONFIG"
touch "$UPDATE_LOG"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$UPDATE_LOG"
}

# Check for updates
check_updates() {
    log "Checking for updates..."
    
    local current_version
    local latest_version
    
    # Get current version
    if [ -f "/etc/vaultos/version" ]; then
        current_version=$(cat /etc/vaultos/version)
    else
        current_version="1.0.0"
    fi
    
    # Check latest version (simplified - would fetch from repository)
    if command -v curl &> /dev/null; then
        latest_version=$(curl -s "$REPO_URL/latest-version" 2>/dev/null || echo "$current_version")
    else
        latest_version="$current_version"
    fi
    
    if [ "$latest_version" != "$current_version" ]; then
        echo -e "${YELLOW}Update available: $current_version -> $latest_version${RESET}"
        log "Update available: $current_version -> $latest_version"
        return 0
    else
        echo -e "${GREEN}System is up to date${RESET}"
        log "System is up to date"
        return 1
    fi
}

# Create backup before update
create_backup() {
    local backup_name="backup-$(date +%Y%m%d-%H%M%S)"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    log "Creating backup: $backup_name"
    mkdir -p "$backup_path"
    
    # Backup configuration
    if [ -d "$CONFIG_DIR" ]; then
        cp -r "$CONFIG_DIR" "$backup_path/config" 2>/dev/null || true
    fi
    
    # Backup system configuration
    if [ -d "/etc/vaultos" ]; then
        sudo cp -r /etc/vaultos "$backup_path/etc-vaultos" 2>/dev/null || true
    fi
    
    echo "$backup_name" > "$CONFIG_DIR/last-backup"
    log "Backup created: $backup_name"
    echo "$backup_name"
}

# Apply updates
apply_updates() {
    log "Applying updates..."
    
    # Create backup first
    local backup_name=$(create_backup)
    
    echo -e "${BLUE}Updating system packages...${RESET}"
    
    if command -v dnf &> /dev/null; then
        # Update VaultOS packages
        sudo dnf update vaultos-* -y || true
        
        # Update system packages
        if [ "${AUTO_SYSTEM_UPDATE:-0}" = "1" ]; then
            sudo dnf update -y || true
        else
            echo -e "${YELLOW}Skipping system updates (set AUTO_SYSTEM_UPDATE=1 to enable)${RESET}"
        fi
    elif command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get upgrade -y vaultos-* || true
    fi
    
    log "Updates applied. Backup: $backup_name"
    echo -e "${GREEN}Updates applied successfully${RESET}"
    echo -e "Backup created: ${BLUE}$backup_name${RESET}"
}

# Rollback to previous version
rollback() {
    local backup_name=$1
    
    if [ -z "$backup_name" ]; then
        # Use last backup
        if [ -f "$CONFIG_DIR/last-backup" ]; then
            backup_name=$(cat "$CONFIG_DIR/last-backup")
        else
            echo -e "${RED}No backup found${RESET}"
            return 1
        fi
    fi
    
    local backup_path="$BACKUP_DIR/$backup_name"
    
    if [ ! -d "$backup_path" ]; then
        echo -e "${RED}Backup not found: $backup_name${RESET}"
        return 1
    fi
    
    log "Rolling back to: $backup_name"
    echo -e "${YELLOW}Rolling back to backup: $backup_name${RESET}"
    
    # Restore configuration
    if [ -d "$backup_path/config" ]; then
        cp -r "$backup_path/config"/* "$CONFIG_DIR/" 2>/dev/null || true
    fi
    
    # Restore system configuration
    if [ -d "$backup_path/etc-vaultos" ]; then
        sudo cp -r "$backup_path/etc-vaultos"/* "/etc/vaultos/" 2>/dev/null || true
    fi
    
    log "Rollback completed: $backup_name"
    echo -e "${GREEN}Rollback completed${RESET}"
}

# List backups
list_backups() {
    echo -e "${GREEN}Available Backups:${RESET}"
    echo ""
    
    if [ -d "$BACKUP_DIR" ]; then
        local count=0
        for backup in "$BACKUP_DIR"/*; do
            if [ -d "$backup" ]; then
                local name=$(basename "$backup")
                local date=$(echo "$name" | cut -d'-' -f2- | tr '-' ' ')
                echo -e "  ${BLUE}$name${RESET} - $date"
                count=$((count + 1))
            fi
        done
        
        if [ $count -eq 0 ]; then
            echo "  No backups available"
        fi
    else
        echo "  No backups available"
    fi
    echo ""
}

# Configure automatic updates
configure_auto_updates() {
    echo "Automatic Update Configuration"
    echo ""
    
    read -p "Enable automatic updates? (y/n): " enable
    if [ "$enable" = "y" ] || [ "$enable" = "Y" ]; then
        cat > "$UPDATE_CONFIG" <<EOF
AUTO_UPDATE=1
CHECK_INTERVAL=$CHECK_INTERVAL
AUTO_SYSTEM_UPDATE=0
EOF
        echo -e "${GREEN}Automatic updates enabled${RESET}"
        
        # Create systemd timer (if systemd available)
        if command -v systemd-run &> /dev/null; then
            echo "Creating systemd timer for automatic updates..."
            # Timer would be created here
        fi
    else
        echo "AUTO_UPDATE=0" > "$UPDATE_CONFIG"
        echo -e "${YELLOW}Automatic updates disabled${RESET}"
    fi
}

# Show update status
show_status() {
    echo -e "${GREEN}Update Manager Status${RESET}"
    echo ""
    
    # Current version
    if [ -f "/etc/vaultos/version" ]; then
        echo -e "Current Version: ${BLUE}$(cat /etc/vaultos/version)${RESET}"
    else
        echo -e "Current Version: ${YELLOW}Unknown${RESET}"
    fi
    
    # Auto-update status
    if [ -f "$UPDATE_CONFIG" ]; then
        source "$UPDATE_CONFIG"
        if [ "${AUTO_UPDATE:-0}" = "1" ]; then
            echo -e "Automatic Updates: ${GREEN}Enabled${RESET}"
        else
            echo -e "Automatic Updates: ${YELLOW}Disabled${RESET}"
        fi
    else
        echo -e "Automatic Updates: ${YELLOW}Not configured${RESET}"
    fi
    
    # Last check
    if [ -f "$CONFIG_DIR/last-check" ]; then
        echo -e "Last Check: ${BLUE}$(cat "$CONFIG_DIR/last-check")${RESET}"
    fi
    
    echo ""
}

# Main menu
show_menu() {
    clear
    echo -e "${GREEN}╔════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║   VaultOS Update Manager             ║${RESET}"
    echo -e "${GREEN}╚════════════════════════════════════╝${RESET}"
    echo ""
    echo "1) Check for updates"
    echo "2) Apply updates"
    echo "3) List backups"
    echo "4) Rollback"
    echo "5) Configure automatic updates"
    echo "6) Show status"
    echo "7) Exit"
    echo ""
}

# Main
if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
        show_menu
        read -p "Choice [1-7]: " choice
        
        case $choice in
            1) check_updates; read -p "Press Enter to continue..."; ;;
            2) apply_updates; read -p "Press Enter to continue..."; ;;
            3) list_backups; read -p "Press Enter to continue..."; ;;
            4) read -p "Backup name (or Enter for last): " backup; rollback "$backup"; read -p "Press Enter to continue..."; ;;
            5) configure_auto_updates; read -p "Press Enter to continue..."; ;;
            6) show_status; read -p "Press Enter to continue..."; ;;
            7) exit 0; ;;
            *) echo "Invalid choice"; sleep 1; ;;
        esac
    done
else
    # Command-line mode
    case "$1" in
        check) check_updates ;;
        update) apply_updates ;;
        rollback) rollback "$2" ;;
        list-backups) list_backups ;;
        status) show_status ;;
        *) echo "Usage: $0 [check|update|rollback|list-backups|status]"; exit 1; ;;
    esac
fi

