#!/bin/bash
#
# VaultOS Troubleshooting Wizard
# Interactive troubleshooting assistant
#

GREEN='\033[0;32m'
BRIGHT_GREEN='\033[1;32m'
AMBER='\033[1;33m'
RESET='\033[0m'

show_menu() {
    clear
    echo -e "${BRIGHT_GREEN}VaultOS Troubleshooting Wizard${RESET}"
    echo ""
    echo "Select issue:"
    echo ""
    echo "1) Window manager not starting"
    echo "2) Theme not applying"
    echo "3) Display issues"
    echo "4) Audio problems"
    echo "5) Network issues"
    echo "6) Performance problems"
    echo "7) Exit"
    echo ""
}

troubleshoot_wm() {
    clear
    echo -e "${BRIGHT_GREEN}Troubleshooting: Window Manager${RESET}"
    echo ""
    echo "Checking VaultWM status..."
    
    if ! pgrep -x vaultwm > /dev/null; then
        echo -e "${AMBER}VaultWM is not running${RESET}"
        echo ""
        echo "Solutions:"
        echo "1. Check X11 is running: systemctl status graphical.target"
        echo "2. Try starting manually: vaultwm"
        echo "3. Check logs: journalctl -u vaultwm.service"
        echo "4. Verify X11 packages: sudo dnf install xorg-x11-server-Xorg"
    else
        echo -e "${GREEN}VaultWM is running${RESET}"
    fi
}

troubleshoot_theme() {
    clear
    echo -e "${BRIGHT_GREEN}Troubleshooting: Theme${RESET}"
    echo ""
    echo "Checking theme configuration..."
    
    if command -v gsettings &> /dev/null; then
        CURRENT_THEME=$(gsettings get org.gnome.desktop.interface gtk-theme)
        echo "Current GTK theme: $CURRENT_THEME"
        
        if [ "$CURRENT_THEME" != "'VaultOS'" ]; then
            echo ""
            echo "Setting theme to VaultOS..."
            gsettings set org.gnome.desktop.interface gtk-theme "VaultOS"
            echo "Theme updated"
        fi
    else
        echo "gsettings not available"
    fi
    
    echo ""
    echo "Solutions:"
    echo "1. Verify theme files: ls /usr/share/themes/VaultOS/"
    echo "2. Set theme manually: gsettings set org.gnome.desktop.interface gtk-theme 'VaultOS'"
    echo "3. Restart applications"
}

troubleshoot_display() {
    clear
    echo -e "${BRIGHT_GREEN}Troubleshooting: Display${RESET}"
    echo ""
    echo "Display information:"
    
    if command -v xrandr &> /dev/null; then
        xrandr --listmonitors
        echo ""
        echo "Solutions:"
        echo "1. Use display-config: vaultos-display-config"
        echo "2. Detect displays: xrandr --auto"
        echo "3. Check graphics drivers"
    else
        echo "xrandr not available"
    fi
}

troubleshoot_audio() {
    clear
    echo -e "${BRIGHT_GREEN}Troubleshooting: Audio${RESET}"
    echo ""
    
    if command -v pactl &> /dev/null; then
        echo "Audio sinks:"
        pactl list short sinks
        echo ""
        echo "Solutions:"
        echo "1. Use audio-config: vaultos-audio-config"
        echo "2. Check PulseAudio: systemctl --user status pulseaudio"
        echo "3. Restart PulseAudio: systemctl --user restart pulseaudio"
    else
        echo "Audio tools not available"
    fi
}

troubleshoot_network() {
    clear
    echo -e "${BRIGHT_GREEN}Troubleshooting: Network${RESET}"
    echo ""
    
    if command -v ip &> /dev/null; then
        echo "Network interfaces:"
        ip addr show | grep "^[0-9]"
        echo ""
        echo "Default route:"
        ip route | grep default
        echo ""
        echo "Solutions:"
        echo "1. Check interface status: ip link show"
        echo "2. Restart NetworkManager: sudo systemctl restart NetworkManager"
        echo "3. Check DNS: cat /etc/resolv.conf"
    fi
}

troubleshoot_performance() {
    clear
    echo -e "${BRIGHT_GREEN}Troubleshooting: Performance${RESET}"
    echo ""
    
    echo "System information:"
    echo "CPU: $(grep 'model name' /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^[ \t]*//')"
    echo "Memory: $(free -h | grep Mem | awk '{print $2}')"
    echo "Load: $(cat /proc/loadavg | awk '{print $1}')"
    echo ""
    echo "Solutions:"
    echo "1. Run system-optimize: sudo vaultos-system-optimize"
    echo "2. Check resource usage: htop"
    echo "3. Clear cache if needed"
    echo "4. Check for background processes"
}

# Main loop
while true; do
    show_menu
    read -p "Choice [1-7]: " choice
    
    case $choice in
        1) troubleshoot_wm; read -p "Press Enter to continue..."; ;;
        2) troubleshoot_theme; read -p "Press Enter to continue..."; ;;
        3) troubleshoot_display; read -p "Press Enter to continue..."; ;;
        4) troubleshoot_audio; read -p "Press Enter to continue..."; ;;
        5) troubleshoot_network; read -p "Press Enter to continue..."; ;;
        6) troubleshoot_performance; read -p "Press Enter to continue..."; ;;
        7) exit 0; ;;
        *) echo "Invalid choice"; sleep 1; ;;
    esac
done

