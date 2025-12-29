#!/bin/bash
#
# VaultOS Configuration Manager (TUI)
# Text-based configuration interface using dialog/whiptail
#

GREEN='\033[0;32m'
RESET='\033[0m'

CONFIG_FILE="$HOME/.config/vaultos/config.json"
BACKUP_DIR="$HOME/.config/vaultos/backups"

# Use dialog if available, fall back to whiptail
if command -v dialog &> /dev/null; then
    DIALOG=dialog
elif command -v whiptail &> /dev/null; then
    DIALOG=whiptail
else
    echo "Error: dialog or whiptail required"
    exit 1
fi

backup_config() {
    mkdir -p "$BACKUP_DIR"
    if [ -f "$CONFIG_FILE" ]; then
        cp "$CONFIG_FILE" "$BACKUP_DIR/config-$(date +%Y%m%d-%H%M%S).json"
    fi
}

save_config() {
    backup_config
    # Configuration saving would be implemented with JSON manipulation
    echo "Configuration saved"
}

show_main_menu() {
    while true; do
        choice=$($DIALOG --menu "VaultOS Configuration" 15 50 5 \
            "1" "Window Manager" \
            "2" "Themes" \
            "3" "Workspaces" \
            "4" "Key Bindings" \
            "5" "Exit" \
            3>&1 1>&2 2>&3)
        
        exit_code=$?
        if [ $exit_code -ne 0 ]; then
            exit 0
        fi
        
        case $choice in
            1) configure_wm ;;
            2) configure_themes ;;
            3) configure_workspaces ;;
            4) configure_keybindings ;;
            5) exit 0 ;;
        esac
    done
}

configure_wm() {
    $DIALOG --msgbox "Window Manager Configuration\n\nEdit ~/.config/vaultwm/config" 10 40
}

configure_themes() {
    theme=$($DIALOG --menu "Select Theme" 10 30 2 \
        "1" "Pip-Boy (Green)" \
        "2" "Vault-Tec (Blue/Gold)" \
        3>&1 1>&2 2>&3)
    
    if [ $? -eq 0 ]; then
        if [ "$theme" = "1" ]; then
            echo "pipboy" > "$HOME/.config/vaultos/current_theme"
        else
            echo "vaulttec" > "$HOME/.config/vaultos/current_theme"
        fi
        $DIALOG --msgbox "Theme changed. Restart applications to apply." 8 40
    fi
}

configure_workspaces() {
    $DIALOG --msgbox "Workspace Configuration\n\nEdit workspace names in ~/.config/vaultwm/config" 10 40
}

configure_keybindings() {
    $DIALOG --msgbox "Key Binding Configuration\n\nEdit key bindings in ~/.config/vaultwm/config" 10 40
}

# Main
show_main_menu
