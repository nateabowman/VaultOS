#!/bin/bash
# VaultOS Cloud Sync Tool
# Cloud storage integration and configuration sync

set -e

CLOUD_CONFIG_DIR="$HOME/.vaultos/cloud"
SYNC_DIRS=(
    "$HOME/.config/vaultos"
    "$HOME/.config/vaultwm"
    "$HOME/.config/alacritty"
)

# Initialize cloud sync
init_cloud() {
    local provider="$1"
    
    if [ -z "$provider" ]; then
        echo "Usage: $0 init <nextcloud|owncloud|custom>"
        exit 1
    fi
    
    mkdir -p "$CLOUD_CONFIG_DIR"
    
    case "$provider" in
        nextcloud|owncloud)
            read -p "Server URL: " server_url
            read -p "Username: " username
            read -sp "Password: " password
            echo ""
            
            cat > "$CLOUD_CONFIG_DIR/config" << EOF
PROVIDER=$provider
SERVER_URL=$server_url
USERNAME=$username
PASSWORD=$password
EOF
            chmod 600 "$CLOUD_CONFIG_DIR/config"
            echo "Cloud sync configured for $provider"
            ;;
        custom)
            read -p "Sync command (e.g., rsync, rclone): " sync_cmd
            cat > "$CLOUD_CONFIG_DIR/config" << EOF
PROVIDER=custom
SYNC_CMD=$sync_cmd
EOF
            echo "Custom sync configured"
            ;;
        *)
            echo "Error: Unknown provider: $provider"
            exit 1
            ;;
    esac
}

# Sync to cloud
sync_to_cloud() {
    if [ ! -f "$CLOUD_CONFIG_DIR/config" ]; then
        echo "Error: Cloud sync not configured. Run: $0 init"
        exit 1
    fi
    
    source "$CLOUD_CONFIG_DIR/config"
    
    echo "Syncing to cloud..."
    
    case "$PROVIDER" in
        nextcloud|owncloud)
            if command -v nextcloudcmd &> /dev/null; then
                for dir in "${SYNC_DIRS[@]}"; do
                    if [ -d "$dir" ]; then
                        nextcloudcmd "$dir" "$SERVER_URL" -u "$USERNAME" -p "$PASSWORD"
                    fi
                done
            else
                echo "Error: nextcloudcmd not installed"
                exit 1
            fi
            ;;
        custom)
            if [ -n "$SYNC_CMD" ]; then
                eval "$SYNC_CMD"
            else
                echo "Error: Custom sync command not configured"
                exit 1
            fi
            ;;
    esac
    
    echo "Sync complete"
}

# Sync from cloud
sync_from_cloud() {
    if [ ! -f "$CLOUD_CONFIG_DIR/config" ]; then
        echo "Error: Cloud sync not configured"
        exit 1
    fi
    
    source "$CLOUD_CONFIG_DIR/config"
    
    echo "Syncing from cloud..."
    
    case "$PROVIDER" in
        nextcloud|owncloud)
            if command -v nextcloudcmd &> /dev/null; then
                for dir in "${SYNC_DIRS[@]}"; do
                    mkdir -p "$dir"
                    nextcloudcmd "$SERVER_URL" "$dir" -u "$USERNAME" -p "$PASSWORD"
                done
            fi
            ;;
        custom)
            if [ -n "$SYNC_CMD" ]; then
                eval "$SYNC_CMD"
            fi
            ;;
    esac
    
    echo "Sync complete"
}

# Backup to cloud
backup_to_cloud() {
    local backup_name="vaultos-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    local backup_file="/tmp/$backup_name"
    
    echo "Creating backup..."
    tar -czf "$backup_file" "${SYNC_DIRS[@]}" 2>/dev/null || true
    
    if [ -f "$backup_file" ]; then
        sync_to_cloud
        echo "Backup created: $backup_file"
    fi
}

# Show menu
show_menu() {
    clear
    echo "VaultOS Cloud Sync"
    echo ""
    echo "1) Initialize cloud sync"
    echo "2) Sync to cloud"
    echo "3) Sync from cloud"
    echo "4) Backup to cloud"
    echo "5) Exit"
}

# Main
if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
        show_menu
        read -p "Choice: " choice
        case $choice in
            1) read -p "Provider (nextcloud|owncloud|custom): " provider; init_cloud "$provider";;
            2) sync_to_cloud;;
            3) sync_from_cloud;;
            4) backup_to_cloud;;
            5) exit 0;;
            *) echo "Invalid choice";;
        esac
    done
else
    # Command-line mode
    case "$1" in
        init) init_cloud "$2";;
        sync-up) sync_to_cloud;;
        sync-down) sync_from_cloud;;
        backup) backup_to_cloud;;
        *) echo "Usage: $0 {init|sync-up|sync-down|backup}"; exit 1;;
    esac
fi

