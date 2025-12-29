#!/bin/bash
# Enhance Plymouth boot animations
# Adds progress indicators and enhanced visuals

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLYMOUTH_SCRIPT="$SCRIPT_DIR/vaultos.script"
BACKUP_FILE="$SCRIPT_DIR/vaultos.script.backup"

# Backup original script
if [ -f "$PLYMOUTH_SCRIPT" ] && [ ! -f "$BACKUP_FILE" ]; then
    cp "$PLYMOUTH_SCRIPT" "$BACKUP_FILE"
    echo "Backed up original script to $BACKUP_FILE"
fi

# Check if enhancements already added
if grep -q "progress_bar" "$PLYMOUTH_SCRIPT" 2>/dev/null; then
    echo "Enhancements already present in $PLYMOUTH_SCRIPT"
    exit 0
fi

# Add progress bar and enhanced visuals
cat >> "$PLYMOUTH_SCRIPT" << 'EOF'

# Progress bar
progress_bar_image = Image("progress-bar.png");
progress_bar_x = Window.GetWidth() / 2 - 200;
progress_bar_y = Window.GetHeight() - 100;

fun progress_callback(duration, progress) {
    progress_bar_image.SetOpacity(progress);
    progress_bar_image.SetX(progress_bar_x);
    progress_bar_image.SetY(progress_bar_y);
}

# Boot message
boot_message = TextBox("VaultOS", 0, 0, Window.GetWidth(), 50);
boot_message.SetAlignment("center");
boot_message.SetColor(0.0, 1.0, 0.25);  # Pip-Boy green

# Animated vault door (if image exists)
if (File.Exists("vault-door.png")) {
    vault_door = Image("vault-door.png");
    vault_door.SetX(Window.GetWidth() / 2 - 100);
    vault_door.SetY(Window.GetHeight() / 2 - 100);
    fun animate_vault_door() {
        local opacity = Math.Sin(GetTime() * 2) * 0.5 + 0.5;
        vault_door.SetOpacity(opacity);
    }
}

EOF

echo "Plymouth script enhanced!"
echo "Note: Requires progress-bar.png and vault-door.png images for full effect"
echo "Place images in: $SCRIPT_DIR/"

