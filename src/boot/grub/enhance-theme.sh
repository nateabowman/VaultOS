#!/bin/bash
# Enhance GRUB theme with animations and progress indicators

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEME_FILE="$SCRIPT_DIR/theme.txt"
BACKUP_FILE="$SCRIPT_DIR/theme.txt.backup"

# Backup original theme
if [ -f "$THEME_FILE" ] && [ ! -f "$BACKUP_FILE" ]; then
    cp "$THEME_FILE" "$BACKUP_FILE"
    echo "Backed up original theme to $BACKUP_FILE"
fi

# Add progress bar configuration
if ! grep -q "progress_bar" "$THEME_FILE" 2>/dev/null; then
    cat >> "$THEME_FILE" << 'EOF'

# Progress bar configuration
+ progress_bar {
    left = 10%
    top = 90%
    width = 80%
    height = 5
    font = "DejaVu Sans Mono"
    font_size = 16
    text_color = "#00FF41"
    bar_color = "#00FF41"
    bar_background = "#003300"
}

EOF
    echo "Added progress bar configuration"
fi

# Add boot message configuration
if ! grep -q "boot_message" "$THEME_FILE" 2>/dev/null; then
    cat >> "$THEME_FILE" << 'EOF'

# Boot message
+ boot_message {
    left = 10%
    top = 10%
    width = 80%
    height = 20%
    font = "DejaVu Sans Mono"
    font_size = 14
    text_color = "#00FF41"
    message = "VaultOS Booting..."
}

EOF
    echo "Added boot message configuration"
fi

echo "GRUB theme enhanced!"
echo "Note: Full animations require GRUB 2.06+ with video support"

