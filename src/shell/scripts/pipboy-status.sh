#!/bin/bash
#
# Pip-Boy 3000 Status Display
# System information styled like Pip-Boy interface
#

GREEN='\033[0;32m'
BRIGHT_GREEN='\033[1;32m'
AMBER='\033[1;33m'
RESET='\033[0m'

clear

echo -e "${BRIGHT_GREEN}"
echo "╔════════════════════════════════════════════════════╗"
echo "║          PIP-BOY 3000 - SYSTEM STATUS             ║"
echo "╚════════════════════════════════════════════════════╝"
echo -e "${RESET}"

# System Information
echo -e "${GREEN}[SYSTEM INFORMATION]${RESET}"
echo -e "${BRIGHT_GREEN}Hostname:${RESET} $(hostname)"
echo -e "${BRIGHT_GREEN}Kernel:${RESET} $(uname -r)"
echo -e "${BRIGHT_GREEN}Uptime:${RESET} $(uptime -p | sed 's/up //')"
echo ""

# CPU Information
echo -e "${GREEN}[PROCESSOR STATUS]${RESET}"
if command -v lscpu &> /dev/null; then
    CPU_MODEL=$(lscpu | grep "Model name" | cut -d: -f2 | sed 's/^[ \t]*//')
    CPU_CORES=$(lscpu | grep "^CPU(s):" | awk '{print $2}')
    echo -e "${BRIGHT_GREEN}Model:${RESET} $CPU_MODEL"
    echo -e "${BRIGHT_GREEN}Cores:${RESET} $CPU_CORES"
else
    echo -e "${BRIGHT_GREEN}CPU:${RESET} $(grep -m1 "model name" /proc/cpuinfo | cut -d: -f2 | sed 's/^[ \t]*//')"
fi

# CPU Usage
if command -v top &> /dev/null; then
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    echo -e "${BRIGHT_GREEN}Usage:${RESET} ${CPU_USAGE}%"
fi
echo ""

# Memory Information
echo -e "${GREEN}[MEMORY STATUS]${RESET}"
if command -v free &> /dev/null; then
    MEM_TOTAL=$(free -h | grep Mem | awk '{print $2}')
    MEM_USED=$(free -h | grep Mem | awk '{print $3}')
    MEM_AVAIL=$(free -h | grep Mem | awk '{print $7}')
    MEM_PERCENT=$(free | grep Mem | awk '{printf("%.1f", $3/$2 * 100.0)}')
    echo -e "${BRIGHT_GREEN}Total:${RESET} $MEM_TOTAL"
    echo -e "${BRIGHT_GREEN}Used:${RESET} $MEM_USED ($MEM_PERCENT%)"
    echo -e "${BRIGHT_GREEN}Available:${RESET} $MEM_AVAIL"
else
    echo "Memory information unavailable"
fi
echo ""

# Disk Usage
echo -e "${GREEN}[STORAGE STATUS]${RESET}"
if command -v df &> /dev/null; then
    df -h / | tail -1 | awk '{printf "Root: %s used of %s (%s)\n", $3, $2, $5}'
fi
echo ""

# Network Status
echo -e "${GREEN}[NETWORK STATUS]${RESET}"
if command -v ip &> /dev/null; then
    INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
    if [ -n "$INTERFACE" ]; then
        IP_ADDR=$(ip addr show $INTERFACE | grep "inet " | awk '{print $2}' | cut -d/ -f1)
        echo -e "${BRIGHT_GREEN}Interface:${RESET} $INTERFACE"
        echo -e "${BRIGHT_GREEN}IP Address:${RESET} $IP_ADDR"
    fi
elif command -v ifconfig &> /dev/null; then
    INTERFACE=$(route -n | grep '^0.0.0.0' | awk '{print $8}' | head -1)
    if [ -n "$INTERFACE" ]; then
        IP_ADDR=$(ifconfig $INTERFACE | grep "inet " | awk '{print $2}')
        echo -e "${BRIGHT_GREEN}Interface:${RESET} $INTERFACE"
        echo -e "${BRIGHT_GREEN}IP Address:${RESET} $IP_ADDR"
    fi
fi
echo ""

# Process Count
echo -e "${GREEN}[PROCESS STATUS]${RESET}"
PROC_COUNT=$(ps aux | wc -l)
echo -e "${BRIGHT_GREEN}Running Processes:${RESET} $PROC_COUNT"
echo ""

echo -e "${GREEN}[END OF STATUS REPORT]${RESET}"

