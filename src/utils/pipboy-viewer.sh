#!/bin/bash
#
# Pip-Boy Viewer - System Status Display
# TUI-style system information viewer with Pip-Boy aesthetic
#

GREEN='\033[0;32m'
BRIGHT_GREEN='\033[1;32m'
AMBER='\033[1;33m'
RESET='\033[0m'

update_display() {
    clear
    echo -e "${BRIGHT_GREEN}"
    echo "╔════════════════════════════════════════════════════════╗"
    echo "║          PIP-BOY 3000 - SYSTEM VIEWER                 ║"
    echo "╚════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    
    # Header
    echo -e "${GREEN}[STATUS]${RESET}"
    echo -e "${BRIGHT_GREEN}Time:${RESET} $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${BRIGHT_GREEN}Uptime:${RESET} $(uptime -p | sed 's/up //')"
    echo ""
    
    # CPU
    echo -e "${GREEN}[CPU STATUS]${RESET}"
    if [ -f /proc/loadavg ]; then
        LOAD=$(cat /proc/loadavg | awk '{print $1}')
        echo -e "${BRIGHT_GREEN}Load Average:${RESET} $LOAD"
    fi
    if command -v top &> /dev/null; then
        CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
        echo -e "${BRIGHT_GREEN}CPU Usage:${RESET} ${CPU_USAGE}%"
    fi
    echo ""
    
    # Memory
    echo -e "${GREEN}[MEMORY STATUS]${RESET}"
    if command -v free &> /dev/null; then
        MEM_INFO=$(free -h | grep Mem)
        MEM_TOTAL=$(echo $MEM_INFO | awk '{print $2}')
        MEM_USED=$(echo $MEM_INFO | awk '{print $3}')
        MEM_PERCENT=$(free | grep Mem | awk '{printf("%.1f", $3/$2 * 100.0)}')
        echo -e "${BRIGHT_GREEN}Total:${RESET} $MEM_TOTAL"
        echo -e "${BRIGHT_GREEN}Used:${RESET} $MEM_USED ($MEM_PERCENT%)"
    fi
    echo ""
    
    # Disk
    echo -e "${GREEN}[STORAGE STATUS]${RESET}"
    df -h / | tail -1 | awk '{printf "Root: %s / %s (%s used)\n", $3, $2, $5}'
    echo ""
    
    # Network
    echo -e "${GREEN}[NETWORK STATUS]${RESET}"
    if command -v ip &> /dev/null; then
        INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
        if [ -n "$INTERFACE" ]; then
            IP_ADDR=$(ip addr show $INTERFACE 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1)
            RX_BYTES=$(cat /sys/class/net/$INTERFACE/statistics/rx_bytes 2>/dev/null || echo "0")
            TX_BYTES=$(cat /sys/class/net/$INTERFACE/statistics/tx_bytes 2>/dev/null || echo "0")
            echo -e "${BRIGHT_GREEN}Interface:${RESET} $INTERFACE"
            if [ -n "$IP_ADDR" ]; then
                echo -e "${BRIGHT_GREEN}IP:${RESET} $IP_ADDR"
                RX_MB=$(echo "scale=2; $RX_BYTES / 1024 / 1024" | bc 2>/dev/null || echo "0")
                TX_MB=$(echo "scale=2; $TX_BYTES / 1024 / 1024" | bc 2>/dev/null || echo "0")
                echo -e "${BRIGHT_GREEN}RX/TX:${RESET} ${RX_MB}MB / ${TX_MB}MB"
            else
                echo -e "${AMBER}Status: Disconnected${RESET}"
            fi
        fi
    fi
    echo ""
    
    # Processes
    echo -e "${GREEN}[PROCESSES]${RESET}"
    PROC_COUNT=$(ps aux | wc -l)
    echo -e "${BRIGHT_GREEN}Running:${RESET} $PROC_COUNT processes"
    echo ""
    
    # Disk I/O
    echo -e "${GREEN}[DISK I/O]${RESET}"
    if [ -f /proc/diskstats ]; then
        ROOT_DEV=$(df / | tail -1 | awk '{print $1}' | sed 's/[0-9]*$//')
        if [ -n "$ROOT_DEV" ]; then
            echo -e "${BRIGHT_GREEN}Root device:${RESET} $ROOT_DEV"
        fi
    fi
    echo ""
    
    # Temperature (if available)
    echo -e "${GREEN}[TEMPERATURE]${RESET}"
    if [ -d /sys/class/thermal ]; then
        TEMP=$(cat /sys/class/thermal/thermal_zone*/temp 2>/dev/null | head -1)
        if [ -n "$TEMP" ]; then
            TEMP_C=$(echo "scale=1; $TEMP / 1000" | bc 2>/dev/null)
            echo -e "${BRIGHT_GREEN}CPU:${RESET} ${TEMP_C}°C"
        fi
    fi
    echo ""
    
    echo -e "${GREEN}Press Ctrl+C to exit${RESET}"
}

# Main loop
trap 'echo -e "\n${GREEN}Exiting Pip-Boy Viewer...${RESET}"; exit 0' INT

while true; do
    update_display
    sleep 2
done

