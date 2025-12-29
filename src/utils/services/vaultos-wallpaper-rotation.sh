#!/bin/bash
#
# VaultOS Wallpaper Rotation Service
# Rotates wallpapers on a schedule
#

CONFIG_DIR="$HOME/.config/vaultos"
WALLPAPER_DIR="$HOME/.local/share/vaultos/wallpapers"
CONFIG_FILE="$CONFIG_DIR/wallpaper-rotation.conf"
PID_FILE="/tmp/vaultos-wallpaper-rotation.pid"

# Default values
INTERVAL=3600  # 1 hour
ENABLED=0

# Create directories
mkdir -p "$CONFIG_DIR" "$WALLPAPER_DIR"

# Write PID
echo $$ > "$PID_FILE"

# Cleanup on exit
trap "rm -f $PID_FILE; exit" INT TERM EXIT

# Load configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Get list of wallpapers
get_wallpapers() {
    find "$WALLPAPER_DIR" -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) 2>/dev/null
}

# Set wallpaper
set_wallpaper() {
    local wallpaper="$1"
    
    if [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ]; then
        return 1
    fi
    
    # Try different methods to set wallpaper
    if command -v feh &> /dev/null; then
        feh --bg-fill "$wallpaper"
    elif command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper"
    fi
}

# Main loop
while true; do
    if [ "$ENABLED" -eq 1 ]; then
        WALLPAPERS=($(get_wallpapers))
        if [ ${#WALLPAPERS[@]} -gt 0 ]; then
            # Select random wallpaper
            RANDOM_INDEX=$((RANDOM % ${#WALLPAPERS[@]}))
            SELECTED="${WALLPAPERS[$RANDOM_INDEX]}"
            set_wallpaper "$SELECTED"
        fi
    fi
    
    sleep "$INTERVAL"
done

