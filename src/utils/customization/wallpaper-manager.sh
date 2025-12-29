#!/bin/bash
#
# VaultOS Wallpaper Manager
# Manage and set wallpapers
#

WALLPAPER_DIR="$HOME/.local/share/vaultos/wallpapers"
SYSTEM_WALLPAPER_DIR="/usr/share/vaultos/wallpapers"

GREEN='\033[0;32m'
BRIGHT_GREEN='\033[1;32m'
RESET='\033[0m'

mkdir -p "$WALLPAPER_DIR"

show_menu() {
    clear
    echo -e "${BRIGHT_GREEN}VaultOS Wallpaper Manager${RESET}"
    echo ""
    echo "1) List wallpapers"
    echo "2) Set wallpaper"
    echo "3) Import wallpaper"
    echo "4) Configure slideshow"
    echo "5) Exit"
    echo ""
}

list_wallpapers() {
    echo -e "${GREEN}System Wallpapers:${RESET}"
    find "$SYSTEM_WALLPAPER_DIR" -type f \( -name "*.png" -o -name "*.jpg" \) 2>/dev/null | head -20
    echo ""
    echo -e "${GREEN}User Wallpapers:${RESET}"
    find "$WALLPAPER_DIR" -type f \( -name "*.png" -o -name "*.jpg" \) 2>/dev/null
}

set_wallpaper() {
    list_wallpapers
    echo ""
    read -p "Wallpaper path: " wallpaper
    
    if [ -f "$wallpaper" ]; then
        if command -v feh &> /dev/null; then
            feh --bg-fill "$wallpaper"
        elif command -v gsettings &> /dev/null; then
            gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper"
        else
            echo "No wallpaper tool found. Install feh or use GNOME settings"
        fi
        echo "Wallpaper set"
    else
        echo "File not found: $wallpaper"
    fi
}

import_wallpaper() {
    read -p "Source file path: " source_file
    
    if [ -f "$source_file" ]; then
        cp "$source_file" "$WALLPAPER_DIR/"
        echo "Wallpaper imported to: $WALLPAPER_DIR"
    else
        echo "File not found: $source_file"
    fi
}

configure_slideshow() {
    echo "Wallpaper slideshow configuration"
    echo "Use vaultos-wallpaper-rotation service for slideshow"
    echo ""
    read -p "Enable slideshow? (y/n): " enable
    
    if [ "$enable" = "y" ] || [ "$enable" = "Y" ]; then
        CONFIG_FILE="$HOME/.config/vaultos/wallpaper-rotation.conf"
        mkdir -p "$(dirname "$CONFIG_FILE")"
        
        read -p "Interval in seconds [3600]: " interval
        interval=${interval:-3600}
        
        cat > "$CONFIG_FILE" <<EOF
INTERVAL=$interval
ENABLED=1
EOF
        
        echo "Slideshow configured. Enable service with:"
        echo "  vaultos-service-manager enable wallpaper-rotation"
    fi
}

# Main loop
while true; do
    show_menu
    read -p "Choice [1-5]: " choice
    
    case $choice in
        1) list_wallpapers; read -p "Press Enter to continue..."; ;;
        2) set_wallpaper; read -p "Press Enter to continue..."; ;;
        3) import_wallpaper; read -p "Press Enter to continue..."; ;;
        4) configure_slideshow; read -p "Press Enter to continue..."; ;;
        5) exit 0; ;;
        *) echo "Invalid choice"; sleep 1; ;;
    esac
done

