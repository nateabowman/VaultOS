#!/bin/bash
#
# VaultOS Boot Optimization
# GRUB optimization, parallel service startup, boot profiling
#

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

log() {
    echo -e "${BLUE}[BOOT-OPT]${RESET} $1"
}

# Optimize GRUB
optimize_grub() {
    log "Optimizing GRUB configuration..."
    
    if [ ! -f /etc/default/grub ]; then
        log "GRUB configuration not found, skipping"
        return 0
    fi
    
    # Backup original
    sudo cp /etc/default/grub /etc/default/grub.backup
    
    # Add performance optimizations
    if ! grep -q "GRUB_CMDLINE_LINUX_DEFAULT.*quiet" /etc/default/grub; then
        sudo sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="/&quiet /' /etc/default/grub
    fi
    
    # Reduce GRUB timeout
    sudo sed -i 's/GRUB_TIMEOUT=.*/GRUB_TIMEOUT=1/' /etc/default/grub
    
    # Update GRUB
    if command -v grub2-mkconfig &> /dev/null; then
        sudo grub2-mkconfig -o /boot/grub2/grub.cfg
    elif command -v update-grub &> /dev/null; then
        sudo update-grub
    fi
    
    log "GRUB optimized"
}

# Optimize systemd services
optimize_systemd() {
    log "Optimizing systemd services..."
    
    # Enable parallel service startup
    if [ -f /etc/systemd/system.conf ]; then
        sudo sed -i 's/#DefaultTimeoutStartSec=.*/DefaultTimeoutStartSec=10s/' /etc/systemd/system.conf
    fi
    
    # Disable unnecessary services
    local disable_services=(
        "bluetooth.service"
        "cups.service"
        "avahi-daemon.service"
    )
    
    for service in "${disable_services[@]}"; do
        if systemctl is-enabled "$service" &> /dev/null; then
            log "Disabling $service"
            sudo systemctl disable "$service" 2>/dev/null || true
        fi
    done
    
    # Reload systemd
    sudo systemctl daemon-reload
    
    log "Systemd optimized"
}

# Profile boot time
profile_boot() {
    log "Boot profiling..."
    
    if command -v systemd-analyze &> /dev/null; then
        echo -e "${GREEN}Boot Time Analysis:${RESET}"
        systemd-analyze
        echo ""
        echo -e "${GREEN}Slowest Services:${RESET}"
        systemd-analyze blame | head -10
    else
        log "systemd-analyze not available"
    fi
}

# Main
echo -e "${GREEN}VaultOS Boot Optimization${RESET}"
echo ""

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}This script requires root privileges${RESET}"
    exit 1
fi

optimize_grub
optimize_systemd
profile_boot

echo -e "${GREEN}Boot optimization completed${RESET}"

