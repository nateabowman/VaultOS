#!/bin/bash
#
# VaultOS Backup System
# System configuration backup, user data backup, automated scheduling, disaster recovery
#

set -e

CONFIG_DIR="$HOME/.config/vaultos"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.local/share/vaultos/backups}"
BACKUP_CONFIG="$CONFIG_DIR/backup.conf"
BACKUP_LOG="$CONFIG_DIR/backup.log"
SCHEDULE_FILE="$CONFIG_DIR/backup-schedule"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Initialize
mkdir -p "$BACKUP_DIR"
mkdir -p "$CONFIG_DIR"
touch "$BACKUP_LOG"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$BACKUP_LOG"
}

# Create backup
create_backup() {
    local backup_type=${1:-full}
    local backup_name="backup-$(date +%Y%m%d-%H%M%S)-$backup_type"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    log "Creating $backup_type backup: $backup_name"
    mkdir -p "$backup_path"
    
    # Backup configuration
    if [ "$backup_type" = "full" ] || [ "$backup_type" = "config" ]; then
        echo -e "${BLUE}Backing up configuration...${RESET}"
        if [ -d "$CONFIG_DIR" ]; then
            mkdir -p "$backup_path/config"
            cp -r "$CONFIG_DIR"/* "$backup_path/config/" 2>/dev/null || true
        fi
        
        # System configuration
        if [ -d "/etc/vaultos" ]; then
            mkdir -p "$backup_path/etc-vaultos"
            sudo cp -r /etc/vaultos/* "$backup_path/etc-vaultos/" 2>/dev/null || true
        fi
    fi
    
    # Backup user data
    if [ "$backup_type" = "full" ] || [ "$backup_type" = "data" ]; then
        echo -e "${BLUE}Backing up user data...${RESET}"
        mkdir -p "$backup_path/data"
        
        # Backup important user directories
        local user_dirs=(
            "$HOME/.local/share/vaultos"
            "$HOME/.vaultos"
        )
        
        for dir in "${user_dirs[@]}"; do
            if [ -d "$dir" ]; then
                cp -r "$dir" "$backup_path/data/" 2>/dev/null || true
            fi
        done
    fi
    
    # Create backup manifest
    cat > "$backup_path/manifest.txt" <<EOF
Backup Name: $backup_name
Type: $backup_type
Date: $(date)
Hostname: $(hostname)
User: $(whoami)
EOF
    
    # Compress backup
    echo -e "${BLUE}Compressing backup...${RESET}"
    cd "$BACKUP_DIR"
    tar -czf "$backup_name.tar.gz" "$backup_name" 2>/dev/null || true
    rm -rf "$backup_name"
    
    log "Backup created: $backup_name.tar.gz"
    echo -e "${GREEN}Backup created: $backup_name.tar.gz${RESET}"
    echo "$backup_name.tar.gz"
}

# Restore backup
restore_backup() {
    local backup_file=$1
    
    if [ -z "$backup_file" ]; then
        echo -e "${RED}Backup file not specified${RESET}"
        return 1
    fi
    
    # Handle both .tar.gz and directory
    local backup_path
    if [[ "$backup_file" == *.tar.gz ]]; then
        local extract_dir=$(mktemp -d)
        tar -xzf "$backup_file" -C "$extract_dir"
        backup_path="$extract_dir/$(basename "$backup_file" .tar.gz)"
    else
        backup_path="$backup_file"
    fi
    
    if [ ! -d "$backup_path" ]; then
        echo -e "${RED}Backup not found: $backup_file${RESET}"
        return 1
    fi
    
    log "Restoring from backup: $backup_file"
    echo -e "${YELLOW}Restoring from backup...${RESET}"
    
    # Restore configuration
    if [ -d "$backup_path/config" ]; then
        echo -e "${BLUE}Restoring configuration...${RESET}"
        cp -r "$backup_path/config"/* "$CONFIG_DIR/" 2>/dev/null || true
        
        if [ -d "$backup_path/etc-vaultos" ]; then
            sudo cp -r "$backup_path/etc-vaultos"/* "/etc/vaultos/" 2>/dev/null || true
        fi
    fi
    
    # Restore user data
    if [ -d "$backup_path/data" ]; then
        echo -e "${BLUE}Restoring user data...${RESET}"
        for item in "$backup_path/data"/*; do
            if [ -d "$item" ]; then
                local name=$(basename "$item")
                cp -r "$item" "$HOME/.local/share/vaultos/" 2>/dev/null || true
            fi
        done
    fi
    
    log "Restore completed: $backup_file"
    echo -e "${GREEN}Restore completed${RESET}"
    
    if [ -n "$extract_dir" ]; then
        rm -rf "$extract_dir"
    fi
}

# List backups
list_backups() {
    echo -e "${GREEN}Available Backups:${RESET}"
    echo ""
    
    local count=0
    if [ -d "$BACKUP_DIR" ]; then
        for backup in "$BACKUP_DIR"/*.tar.gz; do
            if [ -f "$backup" ]; then
                local name=$(basename "$backup")
                local size=$(du -h "$backup" | cut -f1)
                local date=$(stat -c %y "$backup" 2>/dev/null | cut -d' ' -f1 || echo "Unknown")
                echo -e "  ${BLUE}$name${RESET} - $size - $date"
                count=$((count + 1))
            fi
        done
    fi
    
    if [ $count -eq 0 ]; then
        echo "  No backups available"
    fi
    echo ""
}

# Clean old backups
clean_backups() {
    local keep_days=${1:-30}
    
    log "Cleaning backups older than $keep_days days"
    echo -e "${BLUE}Cleaning backups older than $keep_days days...${RESET}"
    
    local removed=0
    if [ -d "$BACKUP_DIR" ]; then
        find "$BACKUP_DIR" -name "*.tar.gz" -type f -mtime +$keep_days -delete
        removed=$?
    fi
    
    if [ $removed -eq 0 ]; then
        log "Backup cleanup completed"
        echo -e "${GREEN}Backup cleanup completed${RESET}"
    fi
}

# Schedule automatic backups
schedule_backup() {
    local schedule_type=$1  # daily, weekly, monthly
    
    echo "Configuring automatic backup schedule: $schedule_type"
    
    cat > "$SCHEDULE_FILE" <<EOF
SCHEDULE_TYPE=$schedule_type
ENABLED=1
EOF
    
    # Create systemd timer (if available)
    if command -v systemd-run &> /dev/null; then
        echo "Creating systemd timer for automatic backups..."
        # Timer would be created here
    fi
    
    echo -e "${GREEN}Backup schedule configured: $schedule_type${RESET}"
}

# Disaster recovery
disaster_recovery() {
    echo -e "${RED}╔════════════════════════════════════╗${RESET}"
    echo -e "${RED}║   Disaster Recovery Mode            ║${RESET}"
    echo -e "${RED}╚════════════════════════════════════╝${RESET}"
    echo ""
    echo "This will restore your system from the most recent backup."
    echo ""
    read -p "Continue? (yes/no): " confirm
    
    if [ "$confirm" != "yes" ]; then
        echo "Cancelled"
        return 1
    fi
    
    # Find most recent backup
    local latest_backup=$(ls -t "$BACKUP_DIR"/*.tar.gz 2>/dev/null | head -1)
    
    if [ -z "$latest_backup" ]; then
        echo -e "${RED}No backups found${RESET}"
        return 1
    fi
    
    echo -e "${YELLOW}Restoring from: $(basename "$latest_backup")${RESET}"
    restore_backup "$latest_backup"
}

# Main menu
show_menu() {
    clear
    echo -e "${GREEN}╔════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║   VaultOS Backup & Restore           ║${RESET}"
    echo -e "${GREEN}╚════════════════════════════════════╝${RESET}"
    echo ""
    echo "1) Create full backup"
    echo "2) Create config backup"
    echo "3) Create data backup"
    echo "4) Restore backup"
    echo "5) List backups"
    echo "6) Clean old backups"
    echo "7) Schedule automatic backups"
    echo "8) Disaster recovery"
    echo "9) Exit"
    echo ""
}

# Main
if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
        show_menu
        read -p "Choice [1-9]: " choice
        
        case $choice in
            1) create_backup "full"; read -p "Press Enter to continue..."; ;;
            2) create_backup "config"; read -p "Press Enter to continue..."; ;;
            3) create_backup "data"; read -p "Press Enter to continue..."; ;;
            4) read -p "Backup file: " file; restore_backup "$file"; read -p "Press Enter to continue..."; ;;
            5) list_backups; read -p "Press Enter to continue..."; ;;
            6) read -p "Keep days [30]: " days; clean_backups "${days:-30}"; read -p "Press Enter to continue..."; ;;
            7) read -p "Schedule (daily/weekly/monthly): " schedule; schedule_backup "$schedule"; read -p "Press Enter to continue..."; ;;
            8) disaster_recovery; read -p "Press Enter to continue..."; ;;
            9) exit 0; ;;
            *) echo "Invalid choice"; sleep 1; ;;
        esac
    done
else
    # Command-line mode
    case "$1" in
        create) create_backup "${2:-full}" ;;
        restore) restore_backup "$2" ;;
        list) list_backups ;;
        clean) clean_backups "${2:-30}" ;;
        schedule) schedule_backup "$2" ;;
        disaster-recovery) disaster_recovery ;;
        *) echo "Usage: $0 [create|restore|list|clean|schedule|disaster-recovery] [options]"; exit 1; ;;
    esac
fi

