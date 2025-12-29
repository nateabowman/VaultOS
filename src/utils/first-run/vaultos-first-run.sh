#!/bin/bash
#
# VaultOS First-Run Wizard
# Onboarding wizard for new users
#

GREEN='\033[0;32m'
BRIGHT_GREEN='\033[1;32m'
RESET='\033[0m'
FIRST_RUN_FLAG="$HOME/.config/vaultos/first-run-complete"

# Check if first-run already completed
if [ -f "$FIRST_RUN_FLAG" ]; then
    exit 0
fi

clear
echo -e "${BRIGHT_GREEN}"
echo "╔════════════════════════════════════════════════════╗"
echo "║        Welcome to VaultOS!                        ║"
echo "║        Fallout-Themed Linux Distribution          ║"
echo "╚════════════════════════════════════════════════════╝"
echo -e "${RESET}"
echo ""
echo "This wizard will help you configure VaultOS."
echo "Press Enter to continue..."
read

# Theme Selection
echo ""
echo -e "${GREEN}Theme Selection${RESET}"
echo "1) Pip-Boy Theme (Green - Default)"
echo "2) Vault-Tec Theme (Blue/Gold)"
read -p "Select theme [1-2]: " theme_choice

case $theme_choice in
    2)
        echo "vaulttec" > "$HOME/.config/vaultos/current_theme"
        ;;
    *)
        echo "pipboy" > "$HOME/.config/vaultos/current_theme"
        ;;
esac

# Key Binding Tutorial
echo ""
echo -e "${GREEN}Key Binding Tutorial${RESET}"
echo "VaultWM uses Mod4 (Windows/Super key) for shortcuts:"
echo "  Mod4 + Enter  - Launch terminal"
echo "  Mod4 + D      - Launch application launcher"
echo "  Mod4 + Q      - Close window"
echo "  Mod4 + 1-9    - Switch workspaces"
echo ""
read -p "Press Enter to continue..."

# Workspace Setup
echo ""
echo -e "${GREEN}Workspace Setup${RESET}"
echo "VaultOS provides 9 workspaces for organizing your work."
echo "Workspaces are ready to use!"
read -p "Press Enter to continue..."

# Mark first-run as complete
mkdir -p "$(dirname "$FIRST_RUN_FLAG")"
touch "$FIRST_RUN_FLAG"

echo ""
echo -e "${BRIGHT_GREEN}Setup complete!${RESET}"
echo "Enjoy VaultOS!"
sleep 2
