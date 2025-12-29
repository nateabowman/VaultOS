#!/bin/bash
#
# VaultOS Theme Management Daemon
# Monitors and manages theme changes
#

CONFIG_DIR="$HOME/.config/vaultos"
THEME_CONFIG="$CONFIG_DIR/theme.conf"
PID_FILE="/tmp/vaultos-theme-daemon.pid"

# Create config directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

# Write PID
echo $$ > "$PID_FILE"

# Cleanup on exit
trap "rm -f $PID_FILE; exit" INT TERM EXIT

# Main loop
while true; do
    # Check for theme change requests
    if [ -f "$CONFIG_DIR/theme_change" ]; then
        NEW_THEME=$(cat "$CONFIG_DIR/theme_change")
        rm -f "$CONFIG_DIR/theme_change"
        
        # Apply theme change
        case "$NEW_THEME" in
            pipboy|Pip-Boy)
                gsettings set org.gnome.desktop.interface gtk-theme "VaultOS" 2>/dev/null
                echo "Pip-Boy theme applied"
                ;;
            vaulttec|Vault-Tec)
                # Apply Vault-Tec theme variant
                gsettings set org.gnome.desktop.interface gtk-theme "VaultOS" 2>/dev/null
                echo "Vault-Tec theme applied"
                ;;
        esac
        
        # Notify completion
        echo "$NEW_THEME" > "$CONFIG_DIR/current_theme"
    fi
    
    sleep 1
done

