#!/bin/bash
#
# VaultOS Icon Theme Installation Script
# Installs the VaultOS icon theme to the system
#

set -e

ICON_THEME_DIR="VaultOS"
ICON_INSTALL_DIR="/usr/share/icons/VaultOS"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root (use sudo)"
    exit 1
fi

# Check if icon theme directory exists
if [ ! -d "$SCRIPT_DIR/$ICON_THEME_DIR" ]; then
    echo "Error: Icon theme directory not found: $SCRIPT_DIR/$ICON_THEME_DIR"
    exit 1
fi

# Create installation directory
echo "Creating icon theme directory..."
install -d "$ICON_INSTALL_DIR"

# Copy icon theme
echo "Installing icon theme..."
cp -r "$SCRIPT_DIR/$ICON_THEME_DIR"/* "$ICON_INSTALL_DIR/"

# Update icon cache
echo "Updating icon cache..."
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -f -t "$ICON_INSTALL_DIR"
    echo "Icon cache updated successfully"
else
    echo "Warning: gtk-update-icon-cache not found, skipping cache update"
fi

echo "VaultOS icon theme installed successfully to $ICON_INSTALL_DIR"
echo ""
echo "To use the theme, run:"
echo "  gsettings set org.gnome.desktop.interface icon-theme 'VaultOS'"
echo ""
echo "Or select 'VaultOS' from your desktop environment's theme settings."

