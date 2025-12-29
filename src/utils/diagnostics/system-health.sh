#!/bin/bash
#
# VaultOS System Health Check
# Diagnostic utility for system health
#

GREEN='\033[0;32m'
BRIGHT_GREEN='\033[1;32m'
AMBER='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

ISSUES=0
WARNINGS=0

check_status() {
    local name="$1"
    local status="$2"
    local severity="$3"  # info, warn, error
    
    case $severity in
        error)
            echo -e "${RED}✗${RESET} $name: $status"
            ISSUES=$((ISSUES + 1))
            ;;
        warn)
            echo -e "${AMBER}⚠${RESET} $name: $status"
            WARNINGS=$((WARNINGS + 1))
            ;;
        *)
            echo -e "${GREEN}✓${RESET} $name: $status"
            ;;
    esac
}

echo -e "${BRIGHT_GREEN}VaultOS System Health Check${RESET}"
echo ""

# Disk space
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 90 ]; then
    check_status "Disk Space" "${DISK_USAGE}% used" "error"
elif [ "$DISK_USAGE" -gt 80 ]; then
    check_status "Disk Space" "${DISK_USAGE}% used" "warn"
else
    check_status "Disk Space" "${DISK_USAGE}% used" "info"
fi

# Memory
if command -v free &> /dev/null; then
    MEM_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100)}')
    if [ "$MEM_USAGE" -gt 90 ]; then
        check_status "Memory" "${MEM_USAGE}% used" "error"
    elif [ "$MEM_USAGE" -gt 80 ]; then
        check_status "Memory" "${MEM_USAGE}% used" "warn"
    else
        check_status "Memory" "${MEM_USAGE}% used" "info"
    fi
fi

# Network
if command -v ip &> /dev/null; then
    INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
    if [ -n "$INTERFACE" ]; then
        IP_ADDR=$(ip addr show $INTERFACE 2>/dev/null | grep "inet " | awk '{print $2}' | cut -d/ -f1)
        if [ -n "$IP_ADDR" ]; then
            check_status "Network" "Connected ($INTERFACE)" "info"
        else
            check_status "Network" "Interface up, no IP" "warn"
        fi
    else
        check_status "Network" "No default route" "warn"
    fi
fi

# Services
if pgrep -x vaultwm > /dev/null; then
    check_status "VaultWM" "Running" "info"
else
    check_status "VaultWM" "Not running" "warn"
fi

# System load
if [ -f /proc/loadavg ]; then
    LOAD=$(cat /proc/loadavg | awk '{print $1}')
    CPU_CORES=$(grep -c "^processor" /proc/cpuinfo 2>/dev/null || echo "1")
    LOAD_PCT=$(echo "scale=0; ($LOAD / $CPU_CORES) * 100" | bc 2>/dev/null || echo "0")
    
    if [ "$LOAD_PCT" -gt 100 ]; then
        check_status "System Load" "${LOAD} (high)" "warn"
    else
        check_status "System Load" "${LOAD}" "info"
    fi
fi

# File system errors
if [ -f /proc/mounts ]; then
    MOUNT_ERRORS=$(dmesg | grep -i "error\|fail" | grep -i "mount\|fs" | wc -l)
    if [ "$MOUNT_ERRORS" -gt 0 ]; then
        check_status "File System" "${MOUNT_ERRORS} errors in logs" "warn"
    else
        check_status "File System" "OK" "info"
    fi
fi

echo ""
if [ $ISSUES -gt 0 ]; then
    echo -e "${RED}Health Check: FAILED ($ISSUES issues, $WARNINGS warnings)${RESET}"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${AMBER}Health Check: WARNING ($WARNINGS warnings)${RESET}"
    exit 0
else
    echo -e "${GREEN}Health Check: PASSED${RESET}"
    exit 0
fi

