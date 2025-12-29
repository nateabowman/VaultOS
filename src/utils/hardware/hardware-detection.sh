#!/bin/bash
#
# VaultOS Hardware Detection and Auto-Configuration
# Detects hardware and applies optimal configurations
#

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

detect_cpu() {
    if [ -f /proc/cpuinfo ]; then
        CPU_MODEL=$(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^[ \t]*//')
        CPU_CORES=$(grep -c "^processor" /proc/cpuinfo)
        echo "CPU: $CPU_MODEL ($CPU_CORES cores)"
    fi
}

detect_gpu() {
    if command -v lspci &> /dev/null; then
        GPU=$(lspci | grep -i vga | cut -d: -f3 | sed 's/^[ \t]*//')
        echo "GPU: $GPU"
    fi
}

detect_memory() {
    if [ -f /proc/meminfo ]; then
        MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{printf "%.1f GB", $2/1024/1024}')
        echo "Memory: $MEM_TOTAL"
    fi
}

detect_displays() {
    if command -v xrandr &> /dev/null; then
        DISPLAYS=($(xrandr --query | grep " connected" | awk '{print $1}'))
        echo "Displays: ${#DISPLAYS[@]} connected"
        for display in "${DISPLAYS[@]}"; do
            RESOLUTION=$(xrandr --query | grep "^$display" | grep -o '[0-9]*x[0-9]*' | head -1)
            echo "  - $display: $RESOLUTION"
        done
    fi
}

detect_audio() {
    if command -v pactl &> /dev/null; then
        SINK_COUNT=$(pactl list short sinks | wc -l)
        echo "Audio: $SINK_COUNT output device(s)"
    elif command -v aplay &> /dev/null; then
        CARD_COUNT=$(aplay -l 2>/dev/null | grep "^card" | wc -l)
        echo "Audio: $CARD_COUNT sound card(s)"
    fi
}

auto_configure() {
    echo -e "${GREEN}Auto-configuring hardware...${RESET}"
    
    # Display configuration
    if command -v xrandr &> /dev/null; then
        DISPLAYS=($(xrandr --query | grep " connected" | awk '{print $1}'))
        if [ ${#DISPLAYS[@]} -gt 0 ]; then
            PRIMARY="${DISPLAYS[0]}"
            PREFERRED=$(xrandr --query | grep "^$PRIMARY" | grep -o '[0-9]*x[0-9]*' | head -1)
            if [ -n "$PREFERRED" ]; then
                xrandr --output "$PRIMARY" --mode "$PREFERRED" 2>/dev/null
                echo "Display configured: $PRIMARY -> $PREFERRED"
            fi
        fi
    fi
    
    # Audio configuration
    if command -v pactl &> /dev/null; then
        DEFAULT_SINK=$(pactl info | grep "Default Sink" | cut -d: -f2 | sed 's/^[ \t]*//')
        if [ -n "$DEFAULT_SINK" ]; then
            echo "Audio configured: $DEFAULT_SINK"
        fi
    fi
}

generate_report() {
    REPORT_FILE="$HOME/.cache/vaultos/hardware-report.txt"
    mkdir -p "$(dirname "$REPORT_FILE")"
    
    {
        echo "VaultOS Hardware Detection Report"
        echo "Generated: $(date)"
        echo ""
        detect_cpu
        detect_gpu
        detect_memory
        detect_displays
        detect_audio
    } > "$REPORT_FILE"
    
    echo "Report saved to: $REPORT_FILE"
    cat "$REPORT_FILE"
}

show_menu() {
    clear
    echo -e "${GREEN}╔════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║   VaultOS Hardware Detection       ║${RESET}"
    echo -e "${GREEN}╚════════════════════════════════════╝${RESET}"
    echo ""
    echo "1) Detect CPU"
    echo "2) Detect GPU"
    echo "3) Detect Memory"
    echo "4) Detect Displays"
    echo "5) Detect Audio"
    echo "6) Full detection report"
    echo "7) Auto-configure hardware"
    echo "8) Exit"
    echo ""
}

# Main
if [ "$1" = "--auto" ]; then
    auto_configure
elif [ "$1" = "--report" ]; then
    generate_report
else
    while true; do
        show_menu
        read -p "Choice [1-8]: " choice
        
        case $choice in
            1)
                detect_cpu
                read -p "Press Enter to continue..."
                ;;
            2)
                detect_gpu
                read -p "Press Enter to continue..."
                ;;
            3)
                detect_memory
                read -p "Press Enter to continue..."
                ;;
            4)
                detect_displays
                read -p "Press Enter to continue..."
                ;;
            5)
                detect_audio
                read -p "Press Enter to continue..."
                ;;
            6)
                generate_report
                read -p "Press Enter to continue..."
                ;;
            7)
                auto_configure
                read -p "Press Enter to continue..."
                ;;
            8)
                exit 0
                ;;
        esac
    done
fi

