#!/bin/bash
#
# VaultOS Input Device Configuration
# Configure keyboard layouts and mouse settings
#

GREEN='\033[0;32m'
RESET='\033[0m'

list_keyboard_layouts() {
    if command -v localectl &> /dev/null; then
        localectl list-keymaps
    elif [ -d /usr/share/kbd/keymaps ]; then
        find /usr/share/kbd/keymaps -name "*.map.gz" | sed 's|.*/||;s|\.map\.gz||' | sort
    fi
}

set_keyboard_layout() {
    local layout=$1
    
    if command -v setxkbmap &> /dev/null; then
        setxkbmap "$layout"
        echo "Keyboard layout set to: $layout"
    elif command -v localectl &> /dev/null; then
        sudo localectl set-keymap "$layout"
        echo "Keyboard layout set to: $layout (system-wide)"
    else
        echo "No keyboard configuration tool found"
        return 1
    fi
}

configure_mouse() {
    local device=$1
    local setting=$2
    local value=$3
    
    if command -v xinput &> /dev/null; then
        xinput set-prop "$device" "$setting" "$value"
        echo "Mouse setting updated"
    else
        echo "xinput not available"
        return 1
    fi
}

list_mouse_devices() {
    if command -v xinput &> /dev/null; then
        xinput list --short | grep -i "pointer\|mouse"
    fi
}

show_menu() {
    clear
    echo -e "${GREEN}╔════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║   VaultOS Input Configuration      ║${RESET}"
    echo -e "${GREEN}╚════════════════════════════════════╝${RESET}"
    echo ""
    echo "1) List keyboard layouts"
    echo "2) Set keyboard layout"
    echo "3) List mouse devices"
    echo "4) Configure mouse"
    echo "5) Exit"
    echo ""
}

# Main
while true; do
    show_menu
    read -p "Choice [1-5]: " choice
    
    case $choice in
        1)
            echo "Available keyboard layouts:"
            list_keyboard_layouts | head -20
            echo "..."
            read -p "Press Enter to continue..."
            ;;
        2)
            read -p "Layout code (e.g., us, de, fr): " layout
            set_keyboard_layout "$layout"
            read -p "Press Enter to continue..."
            ;;
        3)
            echo "Mouse devices:"
            list_mouse_devices
            read -p "Press Enter to continue..."
            ;;
        4)
            list_mouse_devices
            read -p "Device ID: " device
            echo "Common settings:"
            echo "  libinput Accel Speed (mouse acceleration): -1.0 to 1.0"
            read -p "Setting name: " setting
            read -p "Value: " value
            configure_mouse "$device" "$setting" "$value"
            read -p "Press Enter to continue..."
            ;;
        5)
            exit 0
            ;;
    esac
done

