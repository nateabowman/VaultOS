#!/bin/bash
# Install VaultOS fonts

FONT_DIR="/usr/share/fonts/vaultos"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$EUID" -ne 0 ]; then 
    echo "This script must be run as root for system-wide installation"
    echo "For user installation, fonts will be installed to ~/.local/share/fonts/"
    USER_INSTALL=true
else
    USER_INSTALL=false
fi

if [ "$USER_INSTALL" = true ]; then
    FONT_DIR="$HOME/.local/share/fonts/vaultos"
fi

echo "Installing VaultOS fonts to $FONT_DIR..."

# Create font directory
mkdir -p "$FONT_DIR"

# Copy font files (if any exist)
if [ -d "$SCRIPT_DIR" ]; then
    find "$SCRIPT_DIR" -type f \( -name "*.ttf" -o -name "*.otf" -o -name "*.ttc" \) -exec cp {} "$FONT_DIR/" \;
fi

# Copy fontconfig configuration
if [ -f "$SCRIPT_DIR/fontconfig.xml" ]; then
    if [ "$USER_INSTALL" = true ]; then
        CONFIG_DIR="$HOME/.config/fontconfig"
    else
        CONFIG_DIR="/etc/fonts/conf.d"
    fi
    mkdir -p "$CONFIG_DIR"
    cp "$SCRIPT_DIR/fontconfig.xml" "$CONFIG_DIR/99-vaultos-fonts.conf"
fi

# Update font cache
if command -v fc-cache &> /dev/null; then
    fc-cache -fv
    echo "Font cache updated!"
else
    echo "Warning: fc-cache not found. Fonts may not be available until cache is updated."
fi

echo "Fonts installed successfully!"

