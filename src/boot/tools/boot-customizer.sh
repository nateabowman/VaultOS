#!/bin/bash
#
# VaultOS Boot Customizer
# Customize GRUB and Plymouth boot settings
#

GREEN='\033[0;32m'
BRIGHT_GREEN='\033[1;32m'
RESET='\033[0m'

GRUB_CONFIG="/etc/default/grub"
GRUB_THEME_DIR="/boot/grub2/themes/vaultos"

show_menu() {
    clear
    echo -e "${BRIGHT_GREEN}VaultOS Boot Customizer${RESET}"
    echo ""
    echo "1) Configure GRUB theme"
    echo "2) Configure GRUB timeout"
    echo "3) Add GRUB kernel parameters"
    echo "4) Configure Plymouth theme"
    echo "5) Test boot configuration"
    echo "6) Exit"
    echo ""
}

configure_grub_theme() {
    echo -e "${GREEN}GRUB Theme Configuration${RESET}"
    echo ""
    
    if [ -f "$GRUB_CONFIG" ]; then
        if grep -q "GRUB_THEME=" "$GRUB_CONFIG"; then
            CURRENT=$(grep "GRUB_THEME=" "$GRUB_CONFIG" | cut -d= -f2 | tr -d '"')
            echo "Current theme: $CURRENT"
        else
            echo "No theme currently set"
        fi
        
        echo ""
        read -p "Enable VaultOS GRUB theme? (y/n): " enable
        
        if [ "$enable" = "y" ] || [ "$enable" = "Y" ]; then
            if [ -d "$GRUB_THEME_DIR" ]; then
                sudo sed -i "s|GRUB_THEME=.*|GRUB_THEME=$GRUB_THEME_DIR/theme.txt|" "$GRUB_CONFIG"
                echo "GRUB theme enabled"
            else
                echo "VaultOS GRUB theme not found at $GRUB_THEME_DIR"
            fi
        else
            sudo sed -i "s|GRUB_THEME=.*||" "$GRUB_CONFIG"
            echo "GRUB theme disabled"
        fi
        
        sudo grub2-mkconfig -o /boot/grub2/grub.cfg
        echo "GRUB configuration updated"
    else
        echo "GRUB configuration file not found"
    fi
}

configure_grub_timeout() {
    echo -e "${GREEN}GRUB Timeout Configuration${RESET}"
    echo ""
    
    if [ -f "$GRUB_CONFIG" ]; then
        CURRENT=$(grep "GRUB_TIMEOUT=" "$GRUB_CONFIG" | cut -d= -f2)
        echo "Current timeout: $CURRENT seconds"
        echo ""
        read -p "Enter new timeout in seconds (0-30): " timeout
        
        if [ -n "$timeout" ]; then
            sudo sed -i "s|GRUB_TIMEOUT=.*|GRUB_TIMEOUT=$timeout|" "$GRUB_CONFIG"
            sudo grub2-mkconfig -o /boot/grub2/grub.cfg
            echo "Timeout set to $timeout seconds"
        fi
    fi
}

add_kernel_parameters() {
    echo -e "${GREEN}Kernel Parameters${RESET}"
    echo ""
    
    if [ -f "$GRUB_CONFIG" ]; then
        CURRENT=$(grep "GRUB_CMDLINE_LINUX=" "$GRUB_CONFIG" | cut -d= -f2 | tr -d '"')
        echo "Current parameters: $CURRENT"
        echo ""
        read -p "Enter additional kernel parameters: " params
        
        if [ -n "$params" ]; then
            if grep -q "GRUB_CMDLINE_LINUX=" "$GRUB_CONFIG"; then
                sudo sed -i "s|GRUB_CMDLINE_LINUX=.*|\"$CURRENT $params\"|" "$GRUB_CONFIG"
            else
                echo "GRUB_CMDLINE_LINUX=\"$params\"" | sudo tee -a "$GRUB_CONFIG"
            fi
            sudo grub2-mkconfig -o /boot/grub2/grub.cfg
            echo "Kernel parameters updated"
        fi
    fi
}

configure_plymouth() {
    echo -e "${GREEN}Plymouth Theme Configuration${RESET}"
    echo ""
    
    if command -v plymouth-set-default-theme &> /dev/null; then
        CURRENT=$(plymouth-set-default-theme 2>&1 | grep -o "vaultos" || echo "none")
        echo "Current theme: $CURRENT"
        echo ""
        read -p "Set VaultOS Plymouth theme? (y/n): " enable
        
        if [ "$enable" = "y" ] || [ "$enable" = "Y" ]; then
            sudo plymouth-set-default-theme vaultos
            echo "Plymouth theme set to vaultos"
            echo "Run 'sudo dracut --force' to rebuild initrd"
        fi
    else
        echo "plymouth-set-default-theme not found"
    fi
}

test_boot_config() {
    echo -e "${GREEN}Testing Boot Configuration${RESET}"
    echo ""
    echo "Checking GRUB configuration..."
    if [ -f /boot/grub2/grub.cfg ]; then
        echo "GRUB config: OK"
    else
        echo "GRUB config: Missing"
    fi
    
    echo ""
    echo "Checking Plymouth configuration..."
    if [ -d /usr/share/plymouth/themes/vaultos ]; then
        echo "Plymouth theme: OK"
    else
        echo "Plymouth theme: Missing"
    fi
    
    echo ""
    echo "Note: Actual boot test requires system reboot"
}

# Check if running as root for some operations
if [ "$EUID" -eq 0 ]; then
    echo "Warning: Running as root. Some operations may not work correctly."
    echo "It's recommended to run as regular user and use sudo when prompted."
    echo ""
fi

# Main loop
while true; do
    show_menu
    read -p "Choice [1-6]: " choice
    
    case $choice in
        1) configure_grub_theme; read -p "Press Enter to continue..."; ;;
        2) configure_grub_timeout; read -p "Press Enter to continue..."; ;;
        3) add_kernel_parameters; read -p "Press Enter to continue..."; ;;
        4) configure_plymouth; read -p "Press Enter to continue..."; ;;
        5) test_boot_config; read -p "Press Enter to continue..."; ;;
        6) exit 0; ;;
        *) echo "Invalid choice"; sleep 1; ;;
    esac
done

