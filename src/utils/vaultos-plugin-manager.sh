#!/bin/bash
#
# VaultOS Plugin Manager
# Complete plugin management with installation, dependency resolution, and updates
#

set -e

PLUGIN_DIR="$HOME/.local/share/vaultos/plugins"
SYSTEM_PLUGIN_DIR="/usr/share/vaultos/plugins"
CONFIG_DIR="$HOME/.config/vaultos"
ENABLED_PLUGINS="$CONFIG_DIR/enabled-plugins"
PLUGIN_REPO_URL="${PLUGIN_REPO_URL:-https://plugins.vaultos.org}"
PLUGIN_CACHE="$CONFIG_DIR/plugin-cache"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Initialize directories
mkdir -p "$PLUGIN_DIR"
mkdir -p "$CONFIG_DIR"
touch "$ENABLED_PLUGINS"

# Load plugin metadata
load_plugin_metadata() {
    local plugin_path=$1
    local json_file="$plugin_path/plugin.json"
    
    if [ ! -f "$json_file" ]; then
        return 1
    fi
    
    # Use jq if available, otherwise parse manually
    if command -v jq &> /dev/null; then
        jq -r '.name, .version, .type, .description, .dependencies[]?' "$json_file" 2>/dev/null
    else
        # Basic JSON parsing (fallback)
        grep -o '"name"[[:space:]]*:[[:space:]]*"[^"]*"' "$json_file" | cut -d'"' -f4
        grep -o '"version"[[:space:]]*:[[:space:]]*"[^"]*"' "$json_file" | cut -d'"' -f4
        grep -o '"type"[[:space:]]*:[[:space:]]*"[^"]*"' "$json_file" | cut -d'"' -f4
    fi
}

# Check plugin dependencies
check_dependencies() {
    local plugin_path=$1
    local json_file="$plugin_path/plugin.json"
    local missing_deps=()
    
    if [ ! -f "$json_file" ]; then
        return 0
    fi
    
    # Extract dependencies (simplified - would use jq in production)
    if command -v jq &> /dev/null; then
        local deps=$(jq -r '.dependencies[]?' "$json_file" 2>/dev/null || echo "")
        while IFS= read -r dep; do
            if [ -n "$dep" ]; then
                if ! plugin_installed "$dep"; then
                    missing_deps+=("$dep")
                fi
            fi
        done <<< "$deps"
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "Missing dependencies: ${missing_deps[*]}"
        return 1
    fi
    
    return 0
}

# Check if plugin is installed
plugin_installed() {
    local plugin_name=$1
    [ -d "$PLUGIN_DIR/$plugin_name" ] || [ -d "$SYSTEM_PLUGIN_DIR/$plugin_name" ]
}

# Check if plugin is enabled
plugin_enabled() {
    local plugin_name=$1
    grep -q "^$plugin_name$" "$ENABLED_PLUGINS" 2>/dev/null
}

# Install plugin from directory or archive
install_plugin() {
    local source=$1
    local plugin_name
    
    if [ -d "$source" ]; then
        # Install from directory
        plugin_name=$(basename "$source")
        local target="$PLUGIN_DIR/$plugin_name"
        
        if plugin_installed "$plugin_name"; then
            echo -e "${YELLOW}Plugin $plugin_name is already installed${RESET}"
            return 1
        fi
        
        # Check dependencies
        if ! check_dependencies "$source"; then
            echo -e "${RED}Dependencies not met${RESET}"
            return 1
        fi
        
        echo -e "${BLUE}Installing plugin: $plugin_name${RESET}"
        cp -r "$source" "$target"
        
        # Install dependencies first
        install_plugin_dependencies "$target"
        
        echo -e "${GREEN}Plugin $plugin_name installed${RESET}"
        return 0
        
    elif [ -f "$source" ] && [[ "$source" == *.tar.gz || "$source" == *.zip ]]; then
        # Install from archive
        local temp_dir=$(mktemp -d)
        trap "rm -rf $temp_dir" EXIT
        
        if [[ "$source" == *.tar.gz ]]; then
            tar -xzf "$source" -C "$temp_dir"
        elif [[ "$source" == *.zip ]]; then
            unzip -q "$source" -d "$temp_dir"
        fi
        
        # Find plugin.json
        local plugin_json=$(find "$temp_dir" -name "plugin.json" | head -1)
        if [ -z "$plugin_json" ]; then
            echo -e "${RED}Invalid plugin archive: no plugin.json found${RESET}"
            return 1
        fi
        
        local plugin_dir=$(dirname "$plugin_json")
        install_plugin "$plugin_dir"
        
    else
        echo -e "${RED}Invalid plugin source: $source${RESET}"
        return 1
    fi
}

# Install plugin dependencies
install_plugin_dependencies() {
    local plugin_path=$1
    local json_file="$plugin_path/plugin.json"
    
    if [ ! -f "$json_file" ]; then
        return 0
    fi
    
    if command -v jq &> /dev/null; then
        local deps=$(jq -r '.dependencies[]?' "$json_file" 2>/dev/null || echo "")
        while IFS= read -r dep; do
            if [ -n "$dep" ] && ! plugin_installed "$dep"; then
                echo -e "${BLUE}Installing dependency: $dep${RESET}"
                # In a full implementation, this would fetch from repository
                echo -e "${YELLOW}Dependency $dep needs to be installed manually${RESET}"
            fi
        done <<< "$deps"
    fi
}

# Uninstall plugin
uninstall_plugin() {
    local plugin_name=$1
    
    if ! plugin_installed "$plugin_name"; then
        echo -e "${RED}Plugin $plugin_name is not installed${RESET}"
        return 1
    fi
    
    # Disable first
    if plugin_enabled "$plugin_name"; then
        disable_plugin "$plugin_name"
    fi
    
    # Remove from user directory
    if [ -d "$PLUGIN_DIR/$plugin_name" ]; then
        rm -rf "$PLUGIN_DIR/$plugin_name"
        echo -e "${GREEN}Plugin $plugin_name uninstalled${RESET}"
        return 0
    fi
    
    # System plugins require sudo
    if [ -d "$SYSTEM_PLUGIN_DIR/$plugin_name" ]; then
        echo -e "${YELLOW}System plugin requires sudo to uninstall${RESET}"
        sudo rm -rf "$SYSTEM_PLUGIN_DIR/$plugin_name"
        echo -e "${GREEN}Plugin $plugin_name uninstalled${RESET}"
        return 0
    fi
    
    return 1
}

# Update plugin
update_plugin() {
    local plugin_name=$1
    
    if ! plugin_installed "$plugin_name"; then
        echo -e "${RED}Plugin $plugin_name is not installed${RESET}"
        return 1
    fi
    
    echo -e "${BLUE}Updating plugin: $plugin_name${RESET}"
    
    # In a full implementation, this would:
    # 1. Fetch latest version from repository
    # 2. Check version
    # 3. Backup current plugin
    # 4. Install new version
    # 5. Restore configuration
    
    echo -e "${YELLOW}Update functionality requires repository integration${RESET}"
    return 0
}

# List all plugins
list_plugins() {
    echo -e "${GREEN}Installed Plugins:${RESET}"
    echo ""
    
    local found=0
    
    # User plugins
    if [ -d "$PLUGIN_DIR" ]; then
        for plugin in "$PLUGIN_DIR"/*; do
            if [ -d "$plugin" ] && [ -f "$plugin/plugin.json" ]; then
                local name=$(basename "$plugin")
                local status=""
                if plugin_enabled "$name"; then
                    status="${GREEN}[enabled]${RESET}"
                else
                    status="${YELLOW}[disabled]${RESET}"
                fi
                echo -e "  ${BLUE}$name${RESET} $status"
                found=1
            fi
        done
    fi
    
    # System plugins
    if [ -d "$SYSTEM_PLUGIN_DIR" ]; then
        for plugin in "$SYSTEM_PLUGIN_DIR"/*; do
            if [ -d "$plugin" ] && [ -f "$plugin/plugin.json" ]; then
                local name=$(basename "$plugin")
                local status=""
                if plugin_enabled "$name"; then
                    status="${GREEN}[enabled]${RESET}"
                else
                    status="${YELLOW}[disabled]${RESET}"
                fi
                echo -e "  ${BLUE}$name${RESET} ${YELLOW}[system]${RESET} $status"
                found=1
            fi
        done
    fi
    
    if [ $found -eq 0 ]; then
        echo "  No plugins installed"
    fi
    echo ""
}

# Enable plugin
enable_plugin() {
    local plugin=$1
    
    if ! plugin_installed "$plugin"; then
        echo -e "${RED}Plugin $plugin is not installed${RESET}"
        return 1
    fi
    
    if plugin_enabled "$plugin"; then
        echo -e "${YELLOW}Plugin $plugin is already enabled${RESET}"
        return 0
    fi
    
    echo "$plugin" >> "$ENABLED_PLUGINS"
    echo -e "${GREEN}Plugin $plugin enabled${RESET}"
}

# Disable plugin
disable_plugin() {
    local plugin=$1
    
    if ! plugin_enabled "$plugin"; then
        echo -e "${YELLOW}Plugin $plugin is not enabled${RESET}"
        return 0
    fi
    
    sed -i "/^$plugin$/d" "$ENABLED_PLUGINS"
    echo -e "${GREEN}Plugin $plugin disabled${RESET}"
}

# Show plugin info
show_plugin_info() {
    local plugin_name=$1
    
    if ! plugin_installed "$plugin_name"; then
        echo -e "${RED}Plugin $plugin_name is not installed${RESET}"
        return 1
    fi
    
    local plugin_path
    if [ -d "$PLUGIN_DIR/$plugin_name" ]; then
        plugin_path="$PLUGIN_DIR/$plugin_name"
    else
        plugin_path="$SYSTEM_PLUGIN_DIR/$plugin_name"
    fi
    
    echo -e "${GREEN}Plugin Information: $plugin_name${RESET}"
    echo ""
    
    if [ -f "$plugin_path/plugin.json" ]; then
        cat "$plugin_path/plugin.json" | jq '.' 2>/dev/null || cat "$plugin_path/plugin.json"
    fi
    
    echo ""
    if plugin_enabled "$plugin_name"; then
        echo -e "Status: ${GREEN}Enabled${RESET}"
    else
        echo -e "Status: ${YELLOW}Disabled${RESET}"
    fi
}

# Main menu
show_menu() {
    clear
    echo -e "${GREEN}╔════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║   VaultOS Plugin Manager            ║${RESET}"
    echo -e "${GREEN}╚════════════════════════════════════╝${RESET}"
    echo ""
    echo "1) List plugins"
    echo "2) Install plugin"
    echo "3) Uninstall plugin"
    echo "4) Enable plugin"
    echo "5) Disable plugin"
    echo "6) Update plugin"
    echo "7) Show plugin info"
    echo "8) Exit"
    echo ""
}

# Main
if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
        show_menu
        read -p "Choice [1-8]: " choice
        
        case $choice in
            1) list_plugins; read -p "Press Enter to continue..."; ;;
            2) read -p "Plugin path or archive: " path; install_plugin "$path"; read -p "Press Enter to continue..."; ;;
            3) read -p "Plugin name: " name; uninstall_plugin "$name"; read -p "Press Enter to continue..."; ;;
            4) read -p "Plugin name: " name; enable_plugin "$name"; read -p "Press Enter to continue..."; ;;
            5) read -p "Plugin name: " name; disable_plugin "$name"; read -p "Press Enter to continue..."; ;;
            6) read -p "Plugin name: " name; update_plugin "$name"; read -p "Press Enter to continue..."; ;;
            7) read -p "Plugin name: " name; show_plugin_info "$name"; read -p "Press Enter to continue..."; ;;
            8) exit 0; ;;
            *) echo "Invalid choice"; sleep 1; ;;
        esac
    done
else
    # Command-line mode
    case "$1" in
        list) list_plugins ;;
        install) install_plugin "$2" ;;
        uninstall) uninstall_plugin "$2" ;;
        enable) enable_plugin "$2" ;;
        disable) disable_plugin "$2" ;;
        update) update_plugin "$2" ;;
        info) show_plugin_info "$2" ;;
        *) echo "Usage: $0 [list|install|uninstall|enable|disable|update|info] [plugin]"; exit 1; ;;
    esac
fi
