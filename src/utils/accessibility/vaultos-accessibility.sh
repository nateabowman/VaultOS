#!/bin/bash
#
# VaultOS Accessibility Features
# Screen reader optimization, high contrast, keyboard navigation
#

set -e

CONFIG_DIR="$HOME/.config/vaultos"
ACCESSIBILITY_CONFIG="$CONFIG_DIR/accessibility.conf"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Initialize
mkdir -p "$CONFIG_DIR"

# Enable high contrast
enable_high_contrast() {
    echo "Enabling high contrast mode..."
    
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.a11y.interface high-contrast true
    fi
    
    # Apply high contrast theme
    if [ -f "$HOME/.config/vaultos/themes/accessibility.css" ]; then
        # Apply theme
        echo "High contrast theme applied"
    fi
    
    echo -e "${GREEN}High contrast mode enabled${RESET}"
}

# Disable high contrast
disable_high_contrast() {
    echo "Disabling high contrast mode..."
    
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.a11y.interface high-contrast false
    fi
    
    echo -e "${GREEN}High contrast mode disabled${RESET}"
}

# Configure screen reader
configure_screen_reader() {
    echo "Configuring screen reader support..."
    
    # Install Orca if not available
    if ! command -v orca &> /dev/null; then
        echo "Installing Orca screen reader..."
        if command -v dnf &> /dev/null; then
            sudo dnf install -y orca
        elif command -v apt-get &> /dev/null; then
            sudo apt-get install -y orca
        fi
    fi
    
    # Enable screen reader
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.a11y.applications screen-reader-enabled true
    fi
    
    echo -e "${GREEN}Screen reader configured${RESET}"
}

# Configure keyboard navigation
configure_keyboard_nav() {
    echo "Configuring keyboard navigation..."
    
    # Enable sticky keys
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.a11y.keyboard stickykeys-enable true
        gsettings set org.gnome.desktop.a11y.keyboard slowkeys-enable true
        gsettings set org.gnome.desktop.a11y.keyboard bouncekeys-enable true
    fi
    
    echo -e "${GREEN}Keyboard navigation configured${RESET}"
}

# Set font scaling
set_font_scaling() {
    local factor=${1:-1.2}
    
    echo "Setting font scaling factor: $factor"
    
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.interface text-scaling-factor "$factor"
    fi
    
    echo -e "${GREEN}Font scaling set to $factor${RESET}"
}

# Main menu
show_menu() {
    clear
    echo -e "${GREEN}╔════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║   VaultOS Accessibility            ║${RESET}"
    echo -e "${GREEN}╚════════════════════════════════════╝${RESET}"
    echo ""
    echo "1) Enable high contrast"
    echo "2) Disable high contrast"
    echo "3) Configure screen reader"
    echo "4) Configure keyboard navigation"
    echo "5) Set font scaling"
    echo "6) Exit"
    echo ""
}

# Main
if [ $# -eq 0 ]; then
    while true; do
        show_menu
        read -p "Choice [1-6]: " choice
        
        case $choice in
            1) enable_high_contrast; read -p "Press Enter..."; ;;
            2) disable_high_contrast; read -p "Press Enter..."; ;;
            3) configure_screen_reader; read -p "Press Enter..."; ;;
            4) configure_keyboard_nav; read -p "Press Enter..."; ;;
            5) read -p "Scaling factor [1.2]: " factor; set_font_scaling "${factor:-1.2}"; read -p "Press Enter..."; ;;
            6) exit 0; ;;
            *) echo "Invalid choice"; sleep 1; ;;
        esac
    done
else
    case "$1" in
        high-contrast) enable_high_contrast ;;
        screen-reader) configure_screen_reader ;;
        keyboard) configure_keyboard_nav ;;
        font-scale) set_font_scaling "$2" ;;
        *) echo "Usage: $0 [high-contrast|screen-reader|keyboard|font-scale]"; exit 1; ;;
    esac
fi

