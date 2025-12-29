#!/bin/bash
#
# VaultOS System Diagnostics
# Health check and troubleshooting utility
#

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

health_check() {
    echo -e "${GREEN}System Health Check${RESET}"
    echo ""
    
    # Check disk space
    DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$DISK_USAGE" -gt 90 ]; then
        echo -e "${RED}WARNING:${RESET} Disk usage is ${DISK_USAGE}%"
    else
        echo -e "${GREEN}OK:${RESET} Disk usage: ${DISK_USAGE}%"
    fi
    
    # Check memory
    MEM_USAGE=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
    if [ "$MEM_USAGE" -gt 90 ]; then
        echo -e "${RED}WARNING:${RESET} Memory usage is ${MEM_USAGE}%"
    else
        echo -e "${GREEN}OK:${RESET} Memory usage: ${MEM_USAGE}%"
    fi
    
    # Check network
    if ping -c 1 8.8.8.8 &>/dev/null; then
        echo -e "${GREEN}OK:${RESET} Network connectivity"
    else
        echo -e "${RED}WARNING:${RESET} No network connectivity"
    fi
}

troubleshooting_wizard() {
    echo "Troubleshooting Wizard"
    echo "1) Window manager issues"
    echo "2) Theme issues"
    echo "3) Boot issues"
    read -p "Select issue: " issue
    
    case $issue in
        1) echo "WM troubleshooting steps..." ;;
        2) echo "Theme troubleshooting steps..." ;;
        3) echo "Boot troubleshooting steps..." ;;
    esac
}

generate_report() {
    REPORT="$HOME/.cache/vaultos/diagnostic-report-$(date +%Y%m%d-%H%M%S).txt"
    mkdir -p "$(dirname "$REPORT")"
    
    {
        echo "VaultOS Diagnostic Report"
        echo "Generated: $(date)"
        echo ""
        echo "=== System Information ==="
        uname -a
        echo ""
        echo "=== Disk Usage ==="
        df -h
        echo ""
        echo "=== Memory ==="
        free -h
        echo ""
        echo "=== Processes ==="
        ps aux --sort=-%cpu | head -10
    } > "$REPORT"
    
    echo "Report saved to: $REPORT"
}

show_menu() {
    clear
    echo -e "${GREEN}VaultOS System Diagnostics${RESET}"
    echo "1) Health check"
    echo "2) Troubleshooting wizard"
    echo "3) Generate diagnostic report"
    echo "4) Exit"
    read -p "Choice: " choice
    
    case $choice in
        1) health_check; read -p "Press Enter..."; show_menu ;;
        2) troubleshooting_wizard; read -p "Press Enter..."; show_menu ;;
        3) generate_report; read -p "Press Enter..."; show_menu ;;
        4) exit 0 ;;
    esac
}

show_menu

