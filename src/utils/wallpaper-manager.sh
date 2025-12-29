#!/bin/bash
#
# VaultOS Wallpaper Manager
# Manage and set wallpapers
#

WALLPAPER_DIR="$HOME/.local/share/vaultos/wallpapers"

list_wallpapers() {
    find "$WALLPAPER_DIR" -type f \( -name "*.png" -o -name "*.jpg" \) 2>/dev/null | sort
}

set_wallpaper() {
    local wallpaper=$1
    if command -v feh &> /dev/null; then
        feh --bg-fill "$wallpaper"
    elif command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper"
    fi
}

show_menu() {
    WALLPAPERS=($(list_wallpapers))
    echo "Available wallpapers:"
    for i in "${!WALLPAPERS[@]}"; do
        echo "$((i+1))) $(basename "${WALLPAPERS[$i]}")"
    done
    read -p "Select wallpaper [1-${#WALLPAPERS[@]}]: " choice
    if [ -n "${WALLPAPERS[$((choice-1))]}" ]; then
        set_wallpaper "${WALLPAPERS[$((choice-1))]}"
    fi
}

show_menu

