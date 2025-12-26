#!/bin/bash
# Install VaultOS GRUB theme

THEME_DIR="/boot/grub2/themes/vaultos"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$EUID" -ne 0 ]; then 
    echo "This script must be run as root"
    exit 1
fi

echo "Installing VaultOS GRUB theme..."

# Create theme directory
mkdir -p "$THEME_DIR"

# Copy theme files
cp "$SCRIPT_DIR/theme.txt" "$THEME_DIR/"
if [ -f "$SCRIPT_DIR/background.png" ]; then
    cp "$SCRIPT_DIR/background.png" "$THEME_DIR/"
fi

# Copy graphics if they exist
for file in "$SCRIPT_DIR"/*.png; do
    if [ -f "$file" ]; then
        cp "$file" "$THEME_DIR/"
    fi
done

# Update GRUB configuration
if [ -f /etc/default/grub ]; then
    if ! grep -q "GRUB_THEME=" /etc/default/grub; then
        echo "GRUB_THEME=$THEME_DIR/theme.txt" >> /etc/default/grub
    else
        sed -i "s|GRUB_THEME=.*|GRUB_THEME=$THEME_DIR/theme.txt|" /etc/default/grub
    fi
fi

# Regenerate GRUB config
if command -v grub2-mkconfig &> /dev/null; then
    grub2-mkconfig -o /boot/grub2/grub.cfg
    echo "GRUB theme installed successfully!"
else
    echo "Warning: grub2-mkconfig not found. Please regenerate GRUB config manually."
fi

