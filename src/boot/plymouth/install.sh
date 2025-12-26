#!/bin/bash
# Install VaultOS Plymouth theme

THEME_DIR="/usr/share/plymouth/themes/vaultos"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$EUID" -ne 0 ]; then 
    echo "This script must be run as root"
    exit 1
fi

echo "Installing VaultOS Plymouth theme..."

# Create theme directory
mkdir -p "$THEME_DIR"

# Copy theme files
cp "$SCRIPT_DIR/vaultos.plymouth" "$THEME_DIR/"
cp "$SCRIPT_DIR/vaultos.script" "$THEME_DIR/"

# Copy images if they exist
for file in "$SCRIPT_DIR"/*.png; do
    if [ -f "$file" ]; then
        cp "$file" "$THEME_DIR/"
    fi
done

# Set as default theme
if command -v plymouth-set-default-theme &> /dev/null; then
    plymouth-set-default-theme vaultos
    echo "Plymouth theme installed and set as default!"
    echo "Note: Run 'dracut --force' to rebuild initrd with the new theme"
else
    echo "Warning: plymouth-set-default-theme not found"
fi

