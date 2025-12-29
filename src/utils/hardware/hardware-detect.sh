#!/bin/bash
#
# VaultOS Hardware Detection and Auto-Configuration
# Detects hardware and suggests configurations
#

GREEN='\033[0;32m'
BRIGHT_GREEN='\033[1;32m'
AMBER='\033[1;33m'
RESET='\033[0m'

echo -e "${BRIGHT_GREEN}VaultOS Hardware Detection${RESET}"
echo ""

# CPU Detection
echo -e "${GREEN}[CPU]${RESET}"
if [ -f /proc/cpuinfo ]; then
    CPU_MODEL=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^[ \t]*//')
    CPU_CORES=$(grep -c "^processor" /proc/cpuinfo)
    echo "Model: $CPU_MODEL"
    echo "Cores: $CPU_CORES"
fi
echo ""

# Memory Detection
echo -e "${GREEN}[Memory]${RESET}"
if [ -f /proc/meminfo ]; then
    MEM_TOTAL=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    MEM_TOTAL_GB=$((MEM_TOTAL / 1024 / 1024))
    echo "Total: ${MEM_TOTAL_GB}GB"
fi
echo ""

# Graphics Detection
echo -e "${GREEN}[Graphics]${RESET}"
if command -v lspci &> /dev/null; then
    GPU=$(lspci | grep -i vga | cut -d: -f3 | sed 's/^[ \t]*//')
    echo "GPU: $GPU"
elif [ -d /sys/class/drm ]; then
    echo "Graphics cards detected:"
    ls /sys/class/drm | grep "^card[0-9]" | while read card; do
        if [ -f "/sys/class/drm/$card/device/uevent" ]; then
            echo "  $card"
        fi
    done
fi
echo ""

# Display Detection
echo -e "${GREEN}[Displays]${RESET}"
if command -v xrandr &> /dev/null; then
    DISPLAYS=$(xrandr | grep " connected" | awk '{print $1}')
    if [ -n "$DISPLAYS" ]; then
        echo "$DISPLAYS" | while read display; do
            echo "  $display"
        done
    else
        echo "No displays detected (X11 may not be running)"
    fi
else
    echo "xrandr not available"
fi
echo ""

# Audio Detection
echo -e "${GREEN}[Audio]${RESET}"
if command -v pactl &> /dev/null; then
    SINKS=$(pactl list short sinks | awk '{print $2}')
    if [ -n "$SINKS" ]; then
        echo "$SINKS" | while read sink; do
            echo "  $sink"
        done
    else
        echo "No audio sinks found"
    fi
elif command -v aplay &> /dev/null; then
    aplay -l | grep "^card"
else
    echo "Audio detection tools not available"
fi
echo ""

# Network Detection
echo -e "${GREEN}[Network]${RESET}"
if command -v ip &> /dev/null; then
    INTERFACES=$(ip link show | grep "^[0-9]" | awk -F: '{print $2}' | sed 's/^[ \t]*//')
    echo "$INTERFACES" | while read iface; do
        STATE=$(ip link show "$iface" | grep -o "state [A-Z]*" | awk '{print $2}')
        echo "  $iface: $STATE"
    done
elif command -v ifconfig &> /dev/null; then
    ifconfig -a | grep "^[a-z]" | awk '{print $1}' | cut -d: -f1
fi
echo ""

# Storage Detection
echo -e "${GREEN}[Storage]${RESET}"
if command -v lsblk &> /dev/null; then
    lsblk -d -o NAME,SIZE,MODEL
elif [ -d /sys/block ]; then
    ls /sys/block | grep -v loop | while read device; do
        if [ -f "/sys/block/$device/size" ]; then
            SIZE=$(cat "/sys/block/$device/size")
            SIZE_GB=$((SIZE * 512 / 1024 / 1024 / 1024))
            echo "  $device: ${SIZE_GB}GB"
        fi
    done
fi
echo ""

echo -e "${AMBER}Hardware detection complete${RESET}"
echo ""
echo "To configure detected hardware, use:"
echo "  vaultos-display-config  - Display configuration"
echo "  vaultos-audio-config    - Audio configuration"

