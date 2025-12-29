#!/bin/bash
#
# VaultOS System Optimization
# Apply system optimizations for better performance
#

GREEN='\033[0;32m'
BRIGHT_GREEN='\033[1;32m'
AMBER='\033[1;33m'
RESET='\033[0m'

echo -e "${BRIGHT_GREEN}VaultOS System Optimization${RESET}"
echo ""

if [ "$EUID" -ne 0 ]; then
    echo "This script requires root privileges"
    echo "Please run with: sudo $0"
    exit 1
fi

# CPU Governor
echo -e "${GREEN}[CPU Governor]${RESET}"
if [ -d /sys/devices/system/cpu/cpu0/cpufreq ]; then
    CURRENT=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
    echo "Current CPU governor: $CURRENT"
    
    if [ "$CURRENT" != "performance" ]; then
        read -p "Set CPU governor to performance? (y/n): " choice
        if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
            for cpu in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
                echo performance > "$cpu" 2>/dev/null
            done
            echo "CPU governor set to performance"
        fi
    else
        echo "CPU governor already set to performance"
    fi
else
    echo "CPU frequency scaling not available"
fi
echo ""

# I/O Scheduler
echo -e "${GREEN}[I/O Scheduler]${RESET}"
DISKS=$(lsblk -d -n -o NAME | grep -v loop)
for disk in $DISKS; do
    if [ -f "/sys/block/$disk/queue/scheduler" ]; then
        CURRENT=$(cat /sys/block/$disk/queue/scheduler | grep -o '\[.*\]' | tr -d '[]')
        echo "$disk: $CURRENT"
        
        if [ "$CURRENT" != "deadline" ] && [ "$CURRENT" != "none" ]; then
            echo deadline > /sys/block/$disk/queue/scheduler 2>/dev/null
            echo "  Set to deadline"
        fi
    fi
done
echo ""

# Swappiness
echo -e "${GREEN}[Memory Swappiness]${RESET}"
CURRENT=$(cat /proc/sys/vm/swappiness)
echo "Current swappiness: $CURRENT"

if [ "$CURRENT" -gt 10 ]; then
    read -p "Reduce swappiness to 10? (y/n): " choice
    if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
        echo 10 > /proc/sys/vm/swappiness
        echo "vm.swappiness=10" >> /etc/sysctl.conf
        echo "Swappiness set to 10"
    fi
else
    echo "Swappiness already optimized"
fi
echo ""

# File System Optimization
echo -e "${GREEN}[File System]${RESET}"
echo "Note: File system optimizations are applied at mount time"
echo "Check /etc/fstab for mount options"
echo ""

echo -e "${AMBER}Optimization complete${RESET}"
echo ""
echo "Note: Some changes require reboot to take full effect"

