#!/bin/bash
#
# VaultOS Theme Switcher
# Switch between Pip-Boy and Vault-Tec themes
#

GREEN='\033[0;32m'
BRIGHT_GREEN='\033[1;32m'
BLUE='\033[0;34m'
GOLD='\033[1;33m'
RESET='\033[0m'

THEME_DIR="$HOME/.config/vaultos"
CURRENT_THEME_FILE="$THEME_DIR/current_theme"

show_menu() {
    clear
    echo -e "${BRIGHT_GREEN}╔════════════════════════════════════╗${RESET}"
    echo -e "${BRIGHT_GREEN}║     VaultOS Theme Switcher         ║${RESET}"
    echo -e "${BRIGHT_GREEN}╚════════════════════════════════════╝${RESET}"
    echo ""
    echo "Select theme:"
    echo ""
    echo -e "${GREEN}1)${RESET} Pip-Boy Theme (Green)"
    echo -e "${BLUE}2)${RESET} Vault-Tec Theme (Blue/Gold)"
    echo -e "${GREEN}3)${RESET} Show current theme"
    echo -e "${GREEN}4)${RESET} Exit"
    echo ""
}

apply_pipboy_theme() {
    echo "Applying Pip-Boy theme..."
    
    # GTK theme
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.interface gtk-theme "VaultOS" 2>/dev/null || true
    fi
    
    # Terminal theme (if applicable)
    echo "Pip-Boy theme applied"
    echo "pipboy" > "$CURRENT_THEME_FILE"
}

apply_vaulttec_theme() {
    echo "Applying Vault-Tec theme..."
    
    # GTK theme
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.interface gtk-theme "VaultOS" 2>/dev/null || true
    fi
    
    echo "Vault-Tec theme applied"
    echo "vaulttec" > "$CURRENT_THEME_FILE"
}

show_current_theme() {
    if [ -f "$CURRENT_THEME_FILE" ]; then
        CURRENT=$(cat "$CURRENT_THEME_FILE")
        echo "Current theme: $CURRENT"
    else
        echo "Current theme: Pip-Boy (default)"
    fi
}

# Create theme directory
mkdir -p "$THEME_DIR"

# Main loop
while true; do
    show_menu
    read -p "Choice [1-4]: " choice
    
    case $choice in
        1)
            apply_pipboy_theme
            sleep 2
            ;;
        2)
            apply_vaulttec_theme
            sleep 2
            ;;
        3)
            show_current_theme
            read -p "Press Enter to continue..."
            ;;
        4)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice"
            sleep 1
            ;;
    esac
done

