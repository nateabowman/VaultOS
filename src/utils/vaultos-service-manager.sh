#!/bin/bash
#
# VaultOS Service Manager
# Manage VaultOS systemd services
#

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

SERVICES=(
    "vaultos-theme-manager.service"
    "vaultos-wallpaper-rotation.service"
    "vaultos-status-bar-update.service"
    "vaultos-system-monitor.service"
)

show_menu() {
    clear
    echo -e "${GREEN}╔════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║   VaultOS Service Manager          ║${RESET}"
    echo -e "${GREEN}╚════════════════════════════════════╝${RESET}"
    echo ""
    echo "1) List services"
    echo "2) Start service"
    echo "3) Stop service"
    echo "4) Restart service"
    echo "5) Enable service (start on boot)"
    echo "6) Disable service"
    echo "7) Check service status"
    echo "8) View service logs"
    echo "9) Exit"
    echo ""
}

list_services() {
    echo -e "${GREEN}VaultOS Services:${RESET}"
    echo ""
    for service in "${SERVICES[@]}"; do
        if systemctl --user list-unit-files | grep -q "$service"; then
            STATUS=$(systemctl --user is-active "$service" 2>/dev/null || echo "inactive")
            ENABLED=$(systemctl --user is-enabled "$service" 2>/dev/null || echo "disabled")
            
            if [ "$STATUS" = "active" ]; then
                echo -e "  ${GREEN}●${RESET} $service (active, $ENABLED)"
            else
                echo -e "  ${RED}●${RESET} $service (inactive, $ENABLED)"
            fi
        else
            echo -e "  ${YELLOW}○${RESET} $service (not installed)"
        fi
    done
    echo ""
    read -p "Press Enter to continue..."
}

service_action() {
    local action=$1
    local service=$2
    
    if [ -z "$service" ]; then
        echo "Available services:"
        for i in "${!SERVICES[@]}"; do
            echo "  $((i+1))) ${SERVICES[$i]}"
        done
        read -p "Select service [1-${#SERVICES[@]}]: " choice
        service="${SERVICES[$((choice-1))]}"
    fi
    
    if [ -z "$service" ]; then
        echo "Invalid selection"
        return 1
    fi
    
    case $action in
        start)
            systemctl --user start "$service" 2>/dev/null && echo "Service started" || echo "Failed to start service"
            ;;
        stop)
            systemctl --user stop "$service" 2>/dev/null && echo "Service stopped" || echo "Failed to stop service"
            ;;
        restart)
            systemctl --user restart "$service" 2>/dev/null && echo "Service restarted" || echo "Failed to restart service"
            ;;
        enable)
            systemctl --user enable "$service" 2>/dev/null && echo "Service enabled" || echo "Failed to enable service"
            ;;
        disable)
            systemctl --user disable "$service" 2>/dev/null && echo "Service disabled" || echo "Failed to disable service"
            ;;
        status)
            systemctl --user status "$service"
            ;;
        logs)
            journalctl --user -u "$service" -f
            ;;
    esac
}

# Main loop
while true; do
    show_menu
    read -p "Choice [1-9]: " choice
    
    case $choice in
        1)
            list_services
            ;;
        2)
            service_action start
            read -p "Press Enter to continue..."
            ;;
        3)
            service_action stop
            read -p "Press Enter to continue..."
            ;;
        4)
            service_action restart
            read -p "Press Enter to continue..."
            ;;
        5)
            service_action enable
            read -p "Press Enter to continue..."
            ;;
        6)
            service_action disable
            read -p "Press Enter to continue..."
            ;;
        7)
            service_action status
            read -p "Press Enter to continue..."
            ;;
        8)
            service_action logs
            ;;
        9)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice"
            sleep 1
            ;;
    esac
done
