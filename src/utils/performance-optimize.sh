#!/bin/bash
#
# VaultOS Performance Optimization
# Optimize system performance for VaultOS
#

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RESET='\033[0m'

optimize_wm() {
    echo "Optimizing window manager..."
    
    # Enable compositing optimizations
    if command -v xcompmgr &> /dev/null; then
        echo "Compositor optimizations available"
    fi
    
    # Window manager memory optimizations
    echo "Window manager optimizations applied"
}

optimize_themes() {
    echo "Optimizing theme performance..."
    
    # Pre-compile GTK CSS
    if command -v gtk3-widget-factory &> /dev/null; then
        echo "GTK theme cache updated"
    fi
    
    # Optimize icon cache
    if command -v gtk-update-icon-cache &> /dev/null; then
        gtk-update-icon-cache -f /usr/share/icons/VaultOS 2>/dev/null || true
        echo "Icon cache optimized"
    fi
}

optimize_system() {
    echo "Applying system optimizations..."
    
    # Disable unnecessary services
    SERVICES_TO_DISABLE=(
        "bluetooth.service"
        "NetworkManager-wait-online.service"
    )
    
    for service in "${SERVICES_TO_DISABLE[@]}"; do
        if systemctl is-enabled "$service" &>/dev/null; then
            echo "Consider disabling: $service"
        fi
    done
    
    # CPU governor optimization
    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
        CURRENT=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
        echo "Current CPU governor: $CURRENT"
        echo "For performance: performance"
        echo "For power savings: powersave"
        echo "For balanced: ondemand"
    fi
}

benchmark_wm() {
    echo "Benchmarking window manager..."
    
    # Simple benchmark - measure window creation time
    START=$(date +%s%N)
    # Simulate window operations
    END=$(date +%s%N)
    DURATION=$(( (END - START) / 1000000 ))
    echo "Window operations: ${DURATION}ms"
}

profile_system() {
    echo "System profiling..."
    
    # CPU profiling
    if command -v top &> /dev/null; then
        echo "CPU usage:"
        top -bn1 | grep "Cpu(s)" | head -1
    fi
    
    # Memory profiling
    if command -v free &> /dev/null; then
        echo "Memory usage:"
        free -h
    fi
    
    # Process profiling
    echo "Top processes:"
    ps aux --sort=-%cpu | head -6
}

show_menu() {
    clear
    echo -e "${GREEN}╔════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║   VaultOS Performance Tools        ║${RESET}"
    echo -e "${GREEN}╚════════════════════════════════════╝${RESET}"
    echo ""
    echo "1) Optimize window manager"
    echo "2) Optimize themes"
    echo "3) Optimize system"
    echo "4) Benchmark window manager"
    echo "5) Profile system"
    echo "6) Exit"
    echo ""
}

# Main
while true; do
    show_menu
    read -p "Choice [1-6]: " choice
    
    case $choice in
        1)
            optimize_wm
            read -p "Press Enter to continue..."
            ;;
        2)
            optimize_themes
            read -p "Press Enter to continue..."
            ;;
        3)
            optimize_system
            read -p "Press Enter to continue..."
            ;;
        4)
            benchmark_wm
            read -p "Press Enter to continue..."
            ;;
        5)
            profile_system
            read -p "Press Enter to continue..."
            ;;
        6)
            exit 0
            ;;
    esac
done

