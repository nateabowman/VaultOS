#!/bin/bash
# VaultOS Dynamic Theme Engine
# Loads and applies themes dynamically

set -e

THEME_DIR="$HOME/.vaultos/themes"
SYSTEM_THEME_DIR="/usr/share/vaultos/themes"
CURRENT_THEME_FILE="$HOME/.vaultos/current-theme"

# Load theme
load_theme() {
    local theme_name="$1"
    local theme_path=""
    
    # Check user themes first, then system themes
    if [ -d "$THEME_DIR/$theme_name" ]; then
        theme_path="$THEME_DIR/$theme_name"
    elif [ -d "$SYSTEM_THEME_DIR/$theme_name" ]; then
        theme_path="$SYSTEM_THEME_DIR/$theme_name"
    else
        echo "Error: Theme '$theme_name' not found"
        exit 1
    fi
    
    echo "Loading theme: $theme_name"
    
    # Load theme configuration
    if [ -f "$theme_path/theme.json" ]; then
        # Apply theme using theme API
        if [ -f "$theme_path/apply.sh" ]; then
            bash "$theme_path/apply.sh"
        else
            # Default theme application
            apply_theme_from_json "$theme_path/theme.json"
        fi
    fi
    
    # Save current theme
    echo "$theme_name" > "$CURRENT_THEME_FILE"
    echo "Theme '$theme_name' loaded"
}

# Apply theme from JSON
apply_theme_from_json() {
    local json_file="$1"
    
    if ! command -v jq &> /dev/null; then
        echo "Error: jq required for JSON theme parsing"
        exit 1
    fi
    
    # Extract colors
    local primary=$(jq -r '.colors.primary' "$json_file")
    local background=$(jq -r '.colors.background' "$json_file")
    local accent=$(jq -r '.colors.accent' "$json_file")
    
    # Apply to GTK
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.interface gtk-theme "$(jq -r '.gtk_theme' "$json_file")"
    fi
    
    # Apply to VaultWM
    if [ -f "$HOME/.config/vaultwm/config" ]; then
        sed -i "s/^color_focused=.*/color_focused=$primary/" "$HOME/.config/vaultwm/config"
        sed -i "s/^color_background=.*/color_background=$background/" "$HOME/.config/vaultwm/config"
    fi
    
    echo "Theme applied"
}

# List available themes
list_themes() {
    echo "Available themes:"
    echo ""
    echo "User themes:"
    if [ -d "$THEME_DIR" ]; then
        ls -1 "$THEME_DIR" 2>/dev/null || echo "  (none)"
    else
        echo "  (none)"
    fi
    echo ""
    echo "System themes:"
    if [ -d "$SYSTEM_THEME_DIR" ]; then
        ls -1 "$SYSTEM_THEME_DIR" 2>/dev/null || echo "  (none)"
    else
        echo "  (none)"
    fi
}

# Preview theme
preview_theme() {
    local theme_name="$1"
    local theme_path=""
    
    if [ -d "$THEME_DIR/$theme_name" ]; then
        theme_path="$THEME_DIR/$theme_name"
    elif [ -d "$SYSTEM_THEME_DIR/$theme_name" ]; then
        theme_path="$SYSTEM_THEME_DIR/$theme_name"
    else
        echo "Error: Theme not found"
        exit 1
    fi
    
    if [ -f "$theme_path/preview.png" ]; then
        if command -v feh &> /dev/null; then
            feh "$theme_path/preview.png"
        elif command -v eog &> /dev/null; then
            eog "$theme_path/preview.png"
        else
            echo "Preview image: $theme_path/preview.png"
        fi
    else
        echo "No preview available for this theme"
    fi
}

# Show menu
show_menu() {
    clear
    echo "VaultOS Theme Engine"
    echo ""
    echo "1) Load theme"
    echo "2) List themes"
    echo "3) Preview theme"
    echo "4) Current theme"
    echo "5) Exit"
}

# Main
if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
        show_menu
        read -p "Choice: " choice
        case $choice in
            1) read -p "Theme name: " name; load_theme "$name";;
            2) list_themes; read -p "Press Enter to continue...";;
            3) read -p "Theme name: " name; preview_theme "$name";;
            4) if [ -f "$CURRENT_THEME_FILE" ]; then echo "Current theme: $(cat $CURRENT_THEME_FILE)"; else echo "No theme loaded"; fi; read -p "Press Enter to continue...";;
            5) exit 0;;
            *) echo "Invalid choice";;
        esac
    done
else
    # Command-line mode
    case "$1" in
        load) load_theme "$2";;
        list) list_themes;;
        preview) preview_theme "$2";;
        current) if [ -f "$CURRENT_THEME_FILE" ]; then cat "$CURRENT_THEME_FILE"; else echo "No theme loaded"; fi;;
        *) echo "Usage: $0 {load|list|preview|current}"; exit 1;;
    esac
fi

