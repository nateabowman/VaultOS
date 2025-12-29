#!/bin/bash
#
# VaultOS Boot Customization Tool
# Customize GRUB and Plymouth boot themes
#

GREEN='\033[0;32m'
RESET='\033[0m'

GRUB_CONFIG="/etc/default/grub"
GRUB_THEME_DIR="/boot/grub2/themes/vaultos"
PLYMOUTH_THEME_DIR="/usr/share/plymouth/themes/vaultos"

configure_grub() {
    echo "GRUB Configuration"
    echo ""
    echo "1) Set boot timeout"
    echo "2) Set default boot option"
    echo "3) Add kernel parameters"
    echo "4) Enable/disable quiet boot"
    echo "5) Regenerate GRUB config"
    echo "6) Back"
    echo ""
    read -p "Choice [1-6]: " choice
    
    case $choice in
        1)
            read -p "Timeout in seconds: " timeout
            sudo sed -i "s/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=$timeout/" "$GRUB_CONFIG"
            echo "Boot timeout set to $timeout seconds"
            ;;
        2)
            echo "Available boot entries:"
            grep "^menuentry" /boot/grub2/grub.cfg | head -5
            read -p "Entry number (0-based): " entry
            sudo sed -i "s/^GRUB_DEFAULT=.*/GRUB_DEFAULT=$entry/" "$GRUB_CONFIG"
            echo "Default boot option set"
            ;;
        3)
            read -p "Kernel parameters (e.g., quiet splash): " params
            sudo sed -i "s/^GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX=\"$params\"/" "$GRUB_CONFIG"
            echo "Kernel parameters updated"
            ;;
        4)
            CURRENT=$(grep GRUB_CMDLINE_LINUX "$GRUB_CONFIG" | grep -o "quiet")
            if [ -n "$CURRENT" ]; then
                sudo sed -i 's/ quiet//' "$GRUB_CONFIG"
                echo "Quiet boot disabled"
            else
                sudo sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="quiet /' "$GRUB_CONFIG"
                echo "Quiet boot enabled"
            fi
            ;;
        5)
            sudo grub2-mkconfig -o /boot/grub2/grub.cfg
            echo "GRUB configuration regenerated"
            ;;
    esac
}

configure_plymouth() {
    echo "Plymouth Configuration"
    echo ""
    echo "1) Set default theme"
    echo "2) Rebuild initrd"
    echo "3) Test theme"
    echo "4) Back"
    echo ""
    read -p "Choice [1-4]: " choice
    
    case $choice in
        1)
            if command -v plymouth-set-default-theme &> /dev/null; then
                sudo plymouth-set-default-theme vaultos
                echo "Plymouth theme set to vaultos"
            else
                echo "plymouth-set-default-theme not found"
            fi
            ;;
        2)
            if command -v dracut &> /dev/null; then
                sudo dracut --force
                echo "Initrd rebuilt with Plymouth theme"
            else
                echo "dracut not found"
            fi
            ;;
        3)
            if command -v plymouthd &> /dev/null; then
                echo "Testing Plymouth theme (requires root)"
                sudo plymouthd --mode=boot --pid-file=/var/run/plymouth.pid
                sudo plymouth show-splash
                sleep 3
                sudo plymouth quit
            else
                echo "plymouthd not found"
            fi
            ;;
    esac
}

show_menu() {
    clear
    echo -e "${GREEN}╔════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║   VaultOS Boot Customization       ║${RESET}"
    echo -e "${GREEN}╚════════════════════════════════════╝${RESET}"
    echo ""
    echo "1) Configure GRUB"
    echo "2) Configure Plymouth"
    echo "3) Exit"
    echo ""
}

# Main
while true; do
    show_menu
    read -p "Choice [1-3]: " choice
    
    case $choice in
        1)
            configure_grub
            read -p "Press Enter to continue..."
            ;;
        2)
            configure_plymouth
            read -p "Press Enter to continue..."
            ;;
        3)
            exit 0
            ;;
    esac
done

