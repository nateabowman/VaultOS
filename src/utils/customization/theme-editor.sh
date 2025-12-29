#!/bin/bash
#
# VaultOS Theme Editor
# Interactive theme customization tool
#

THEME_DIR="$HOME/.local/share/vaultos/themes"
CURRENT_THEME_DIR="$THEME_DIR/custom"

GREEN='\033[0;32m'
BRIGHT_GREEN='\033[1;32m'
RESET='\033[0m'

mkdir -p "$CURRENT_THEME_DIR"

show_menu() {
    clear
    echo -e "${BRIGHT_GREEN}VaultOS Theme Editor${RESET}"
    echo ""
    echo "1) Edit color scheme"
    echo "2) Preview theme"
    echo "3) Export theme"
    echo "4) Import theme"
    echo "5) Reset to default"
    echo "6) Exit"
    echo ""
}

edit_colors() {
    clear
    echo -e "${BRIGHT_GREEN}Color Scheme Editor${RESET}"
    echo ""
    
    # Load current colors or defaults
    COLOR_FILE="$CURRENT_THEME_DIR/colors.conf"
    if [ ! -f "$COLOR_FILE" ]; then
        cat > "$COLOR_FILE" <<EOF
primary=#00FF41
background=#000000
accent=#003300
text=#00FF41
EOF
    fi
    
    echo "Current colors:"
    cat "$COLOR_FILE"
    echo ""
    read -p "Color to edit (primary/background/accent/text): " color_name
    read -p "New hex color (e.g., #00FF41): " color_value
    
    if [ -n "$color_name" ] && [ -n "$color_value" ]; then
        sed -i "s/^${color_name}=.*/${color_name}=${color_value}/" "$COLOR_FILE"
        echo "Color updated"
    fi
}

preview_theme() {
    echo "Theme preview:"
    echo "Loading theme colors..."
    if [ -f "$CURRENT_THEME_DIR/colors.conf" ]; then
        source "$CURRENT_THEME_DIR/colors.conf"
        echo "Primary: $primary"
        echo "Background: $background"
        echo "Accent: $accent"
        echo "Text: $text"
    else
        echo "No custom theme found"
    fi
}

export_theme() {
    read -p "Export theme name: " theme_name
    if [ -n "$theme_name" ]; then
        EXPORT_DIR="$THEME_DIR/$theme_name"
        mkdir -p "$EXPORT_DIR"
        cp -r "$CURRENT_THEME_DIR"/* "$EXPORT_DIR/" 2>/dev/null
        echo "Theme exported to: $EXPORT_DIR"
    fi
}

import_theme() {
    echo "Available themes:"
    ls -1 "$THEME_DIR" 2>/dev/null || echo "No themes found"
    echo ""
    read -p "Theme name to import: " theme_name
    
    if [ -d "$THEME_DIR/$theme_name" ]; then
        cp -r "$THEME_DIR/$theme_name"/* "$CURRENT_THEME_DIR/"
        echo "Theme imported"
    else
        echo "Theme not found"
    fi
}

reset_theme() {
    read -p "Reset to default theme? (y/n): " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        rm -rf "$CURRENT_THEME_DIR"
        mkdir -p "$CURRENT_THEME_DIR"
        echo "Theme reset to defaults"
    fi
}

# Main loop
while true; do
    show_menu
    read -p "Choice [1-6]: " choice
    
    case $choice in
        1) edit_colors; read -p "Press Enter to continue..."; ;;
        2) preview_theme; read -p "Press Enter to continue..."; ;;
        3) export_theme; read -p "Press Enter to continue..."; ;;
        4) import_theme; read -p "Press Enter to continue..."; ;;
        5) reset_theme; read -p "Press Enter to continue..."; ;;
        6) exit 0; ;;
        *) echo "Invalid choice"; sleep 1; ;;
    esac
done

