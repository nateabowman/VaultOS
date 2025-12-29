#!/bin/bash
#
# VaultOS Accessibility Configuration
# Configure accessibility features
#

CONFIG_DIR="$HOME/.config/vaultos"
ACCESSIBILITY_CONFIG="$CONFIG_DIR/accessibility.conf"

GREEN='\033[0;32m'
BRIGHT_GREEN='\033[1;32m'
RESET='\033[0m'

mkdir -p "$CONFIG_DIR"

show_menu() {
    clear
    echo -e "${BRIGHT_GREEN}VaultOS Accessibility Configuration${RESET}"
    echo ""
    echo "1) High contrast mode"
    echo "2) Font size scaling"
    echo "3) Screen reader support"
    echo "4) Keyboard navigation"
    echo "5) Color blind-friendly schemes"
    echo "6) Exit"
    echo ""
}

high_contrast() {
    echo -e "${GREEN}High Contrast Mode${RESET}"
    echo ""
    read -p "Enable high contrast mode? (y/n): " enable
    
    if [ "$enable" = "y" ] || [ "$enable" = "Y" ]; then
        # Increase contrast in GTK theme
        if command -v gsettings &> /dev/null; then
            gsettings set org.gnome.desktop.a11y.interface high-contrast true
        fi
        echo "HIGH_CONTRAST=1" >> "$ACCESSIBILITY_CONFIG"
        echo "High contrast mode enabled"
    else
        if command -v gsettings &> /dev/null; then
            gsettings set org.gnome.desktop.a11y.interface high-contrast false
        fi
        sed -i '/HIGH_CONTRAST/d' "$ACCESSIBILITY_CONFIG"
        echo "High contrast mode disabled"
    fi
}

font_scaling() {
    echo -e "${GREEN}Font Size Scaling${RESET}"
    echo ""
    CURRENT=$(gsettings get org.gnome.desktop.interface text-scaling-factor 2>/dev/null || echo "1.0")
    echo "Current scaling: $CURRENT"
    echo ""
    read -p "Enter scaling factor (0.5 - 3.0): " scale
    
    if [ -n "$scale" ]; then
        if command -v gsettings &> /dev/null; then
            gsettings set org.gnome.desktop.interface text-scaling-factor "$scale"
        fi
        echo "TEXT_SCALING=$scale" >> "$ACCESSIBILITY_CONFIG"
        echo "Font scaling set to: $scale"
    fi
}

screen_reader() {
    echo -e "${GREEN}Screen Reader Support${RESET}"
    echo ""
    echo "Screen reader configuration:"
    echo "1) Enable Orca (GNOME screen reader)"
    echo "2) Configure screen reader settings"
    echo "3) Back"
    echo ""
    read -p "Choice [1-3]: " choice
    
    case $choice in
        1)
            if command -v orca &> /dev/null; then
                echo "Screen reader (Orca) is available"
                echo "Run 'orca' to start screen reader"
            else
                echo "Orca not installed. Install with: sudo dnf install orca"
            fi
            ;;
        2)
            echo "Screen reader settings can be configured in:"
            echo "  - Orca preferences (if installed)"
            echo "  - System Settings > Accessibility"
            ;;
        3)
            return
            ;;
    esac
}

keyboard_nav() {
    echo -e "${GREEN}Keyboard Navigation${RESET}"
    echo ""
    echo "Keyboard navigation improvements:"
    echo "1) Enable sticky keys"
    echo "2) Enable slow keys"
    echo "3) Enable bounce keys"
    echo "4) Back"
    echo ""
    read -p "Choice [1-4]: " choice
    
    case $choice in
        1)
            if command -v gsettings &> /dev/null; then
                gsettings set org.gnome.desktop.a11y.keyboard stickykeys-enable true
                echo "Sticky keys enabled"
            fi
            ;;
        2)
            if command -v gsettings &> /dev/null; then
                gsettings set org.gnome.desktop.a11y.keyboard slowkeys-enable true
                echo "Slow keys enabled"
            fi
            ;;
        3)
            if command -v gsettings &> /dev/null; then
                gsettings set org.gnome.desktop.a11y.keyboard bouncekeys-enable true
                echo "Bounce keys enabled"
            fi
            ;;
        4)
            return
            ;;
    esac
}

color_blind() {
    echo -e "${GREEN}Color Blind-Friendly Schemes${RESET}"
    echo ""
    echo "Color blind-friendly color schemes:"
    echo "1) Deuteranopia (red-green)"
    echo "2) Protanopia (red-green)"
    echo "3) Tritanopia (blue-yellow)"
    echo "4) Back"
    echo ""
    read -p "Choice [1-4]: " choice
    
    case $choice in
        1|2|3)
            echo "Color blind-friendly schemes would require theme modifications"
            echo "This feature is planned for future release"
            ;;
        4)
            return
            ;;
    esac
}

# Main loop
while true; do
    show_menu
    read -p "Choice [1-6]: " choice
    
    case $choice in
        1) high_contrast; read -p "Press Enter to continue..."; ;;
        2) font_scaling; read -p "Press Enter to continue..."; ;;
        3) screen_reader; read -p "Press Enter to continue..."; ;;
        4) keyboard_nav; read -p "Press Enter to continue..."; ;;
        5) color_blind; read -p "Press Enter to continue..."; ;;
        6) exit 0; ;;
        *) echo "Invalid choice"; sleep 1; ;;
    esac
done

