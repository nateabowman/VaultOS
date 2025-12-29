#!/bin/bash
#
# VaultOS Display Configuration Utility
# Configure display resolution, refresh rate, and multi-monitor setup
#

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

detect_displays() {
    if command -v xrandr &> /dev/null; then
        xrandr --query | grep " connected" | awk '{print $1}'
    elif command -v wayland &> /dev/null; then
        # Wayland detection
        echo "Primary"
    else
        echo "Unknown"
    fi
}

list_resolutions() {
    local display=$1
    if command -v xrandr &> /dev/null; then
        xrandr | grep -A 20 "^$display" | grep -E "^\s+[0-9]+x[0-9]+" | awk '{print $1}' | sort -u
    fi
}

set_resolution() {
    local display=$1
    local resolution=$2
    
    if command -v xrandr &> /dev/null; then
        xrandr --output "$display" --mode "$resolution"
        echo "Resolution set to $resolution for $display"
    else
        echo "xrandr not available"
        return 1
    fi
}

set_refresh_rate() {
    local display=$1
    local refresh_rate=$2
    
    if command -v xrandr &> /dev/null; then
        xrandr --output "$display" --rate "$refresh_rate"
        echo "Refresh rate set to ${refresh_rate}Hz for $display"
    else
        echo "xrandr not available"
        return 1
    fi
}

configure_multi_monitor() {
    local primary=$1
    local secondary=$2
    local mode=$3  # mirror, extend, left, right, above, below
    
    if command -v xrandr &> /dev/null; then
        case $mode in
            mirror)
                xrandr --output "$secondary" --same-as "$primary"
                ;;
            extend|left)
                xrandr --output "$secondary" --left-of "$primary"
                ;;
            right)
                xrandr --output "$secondary" --right-of "$primary"
                ;;
            above)
                xrandr --output "$secondary" --above "$primary"
                ;;
            below)
                xrandr --output "$secondary" --below "$primary"
                ;;
        esac
        echo "Multi-monitor configured: $mode"
    else
        echo "xrandr not available"
        return 1
    fi
}

save_config() {
    local config_file="$HOME/.config/vaultos/display.conf"
    mkdir -p "$(dirname "$config_file")"
    
    if command -v xrandr &> /dev/null; then
        xrandr --current > "$config_file"
        echo "Configuration saved to $config_file"
    fi
}

show_menu() {
    clear
    echo -e "${GREEN}╔════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║   VaultOS Display Configuration   ║${RESET}"
    echo -e "${GREEN}╚════════════════════════════════════╝${RESET}"
    echo ""
    echo "1) List displays"
    echo "2) List available resolutions"
    echo "3) Set resolution"
    echo "4) Set refresh rate"
    echo "5) Configure multi-monitor"
    echo "6) Save configuration"
    echo "7) Exit"
    echo ""
}

# Main
if [ "$1" = "--auto" ]; then
    # Auto-detect and configure
    DISPLAYS=($(detect_displays))
    if [ ${#DISPLAYS[@]} -gt 0 ]; then
        PRIMARY="${DISPLAYS[0]}"
        echo "Auto-configuring display: $PRIMARY"
        # Set to preferred resolution
        PREFERRED=$(list_resolutions "$PRIMARY" | head -1)
        if [ -n "$PREFERRED" ]; then
            set_resolution "$PRIMARY" "$PREFERRED"
        fi
    fi
else
    # Interactive mode
    while true; do
        show_menu
        read -p "Choice [1-7]: " choice
        
        case $choice in
            1)
                echo "Connected displays:"
                detect_displays
                read -p "Press Enter to continue..."
                ;;
            2)
                read -p "Display name: " display
                echo "Available resolutions:"
                list_resolutions "$display"
                read -p "Press Enter to continue..."
                ;;
            3)
                read -p "Display name: " display
                read -p "Resolution (e.g., 1920x1080): " resolution
                set_resolution "$display" "$resolution"
                read -p "Press Enter to continue..."
                ;;
            4)
                read -p "Display name: " display
                read -p "Refresh rate (e.g., 60): " rate
                set_refresh_rate "$display" "$rate"
                read -p "Press Enter to continue..."
                ;;
            5)
                DISPLAYS=($(detect_displays))
                if [ ${#DISPLAYS[@]} -lt 2 ]; then
                    echo "Multiple displays not detected"
                else
                    echo "Primary: ${DISPLAYS[0]}"
                    echo "Secondary: ${DISPLAYS[1]}"
                    echo "Modes: mirror, extend, left, right, above, below"
                    read -p "Mode: " mode
                    configure_multi_monitor "${DISPLAYS[0]}" "${DISPLAYS[1]}" "$mode"
                fi
                read -p "Press Enter to continue..."
                ;;
            6)
                save_config
                read -p "Press Enter to continue..."
                ;;
            7)
                exit 0
                ;;
        esac
    done
fi
