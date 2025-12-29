#!/bin/bash
# VaultOS RTL (Right-to-Left) Language Support
# Configures RTL layout for Arabic, Hebrew, etc.

set -e

CONFIG_DIR="$HOME/.config/vaultos"
RTL_CONFIG="$CONFIG_DIR/rtl.conf"

# Enable RTL support
enable_rtl() {
    local lang="$1"
    
    if [ -z "$lang" ]; then
        echo "Usage: $0 enable <language_code>"
        echo "Example: $0 enable ar (Arabic) or $0 enable he (Hebrew)"
        exit 1
    fi
    
    mkdir -p "$CONFIG_DIR"
    
    # RTL languages
    local rtl_langs=("ar" "he" "fa" "ur" "yi")
    local is_rtl=0
    
    for rtl_lang in "${rtl_langs[@]}"; do
        if [ "$lang" = "$rtl_lang" ]; then
            is_rtl=1
            break
        fi
    done
    
    if [ $is_rtl -eq 0 ]; then
        echo "Warning: $lang is not typically an RTL language"
    fi
    
    # Configure RTL
    cat > "$RTL_CONFIG" << EOF
RTL_ENABLED=1
RTL_LANGUAGE=$lang
EOF
    
    # Apply RTL to GTK
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.interface text-scaling-factor 1.0
    fi
    
    # Apply to VaultWM (would need WM support)
    if [ -f "$HOME/.config/vaultwm/config" ]; then
        echo "rtl_enabled=1" >> "$HOME/.config/vaultwm/config"
        echo "rtl_language=$lang" >> "$HOME/.config/vaultwm/config"
    fi
    
    echo "RTL support enabled for: $lang"
}

# Disable RTL
disable_rtl() {
    rm -f "$RTL_CONFIG"
    
    # Remove from VaultWM config
    if [ -f "$HOME/.config/vaultwm/config" ]; then
        sed -i '/^rtl_enabled/d' "$HOME/.config/vaultwm/config"
        sed -i '/^rtl_language/d' "$HOME/.config/vaultwm/config"
    fi
    
    echo "RTL support disabled"
}

# Check RTL status
check_rtl() {
    if [ -f "$RTL_CONFIG" ]; then
        source "$RTL_CONFIG"
        echo "RTL enabled: Yes"
        echo "Language: $RTL_LANGUAGE"
    else
        echo "RTL enabled: No"
    fi
}

# Show menu
show_menu() {
    clear
    echo "VaultOS RTL Support"
    echo ""
    echo "1) Enable RTL"
    echo "2) Disable RTL"
    echo "3) Check RTL status"
    echo "4) Exit"
}

# Main
if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
        show_menu
        read -p "Choice: " choice
        case $choice in
            1) read -p "Language code (ar, he, fa, ur, yi): " lang; enable_rtl "$lang";;
            2) disable_rtl;;
            3) check_rtl; read -p "Press Enter to continue...";;
            4) exit 0;;
            *) echo "Invalid choice";;
        esac
    done
else
    # Command-line mode
    case "$1" in
        enable) enable_rtl "$2";;
        disable) disable_rtl;;
        status) check_rtl;;
        *) echo "Usage: $0 {enable|disable|status}"; exit 1;;
    esac
fi

