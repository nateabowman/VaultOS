#!/bin/bash
#
# VaultOS Health Check
# Service health checks, automatic recovery, crash reporting
#

set -e

CONFIG_DIR="$HOME/.config/vaultos"
HEALTH_LOG="$CONFIG_DIR/health.log"
HEALTH_STATUS="$CONFIG_DIR/health-status.json"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$HEALTH_LOG"
}

# Check service health
check_service() {
    local service=$1
    
    if systemctl --user is-active "$service" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Check window manager
check_window_manager() {
    if pgrep -x "vaultwm" > /dev/null; then
        return 0
    else
        return 1
    fi
}

# Check disk space
check_disk_space() {
    local usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$usage" -lt 90 ]; then
        return 0
    else
        return 1
    fi
}

# Check memory
check_memory() {
    local mem_percent=$(free | awk '/^Mem:/{printf "%.0f", $3/$2 * 100}')
    if [ "$mem_percent" -lt 90 ]; then
        return 0
    else
        return 1
    fi
}

# Automatic recovery
recover_service() {
    local service=$1
    
    log "Attempting to recover service: $service"
    
    if systemctl --user restart "$service" 2>/dev/null; then
        log "Service recovered: $service"
        return 0
    else
        log "Failed to recover service: $service"
        return 1
    fi
}

# Run health check
run_health_check() {
    local status="healthy"
    local issues=()
    
    # Check window manager
    if ! check_window_manager; then
        status="unhealthy"
        issues+=("Window manager not running")
        recover_service "vaultwm.service" || true
    fi
    
    # Check disk space
    if ! check_disk_space; then
        status="warning"
        issues+=("Low disk space")
    fi
    
    # Check memory
    if ! check_memory; then
        status="warning"
        issues+=("High memory usage")
    fi
    
    # Save status
    cat > "$HEALTH_STATUS" <<EOF
{
  "status": "$status",
  "timestamp": "$(date +%s)",
  "issues": [$(printf '"%s",' "${issues[@]}" | sed 's/,$//')]
}
EOF
    
    if [ "$status" = "healthy" ]; then
        echo -e "${GREEN}System health: OK${RESET}"
        return 0
    else
        echo -e "${YELLOW}System health: $status${RESET}"
        for issue in "${issues[@]}"; do
            echo -e "  ${YELLOW}- $issue${RESET}"
        done
        return 1
    fi
}

# Main
case "${1:-}" in
    check)
        run_health_check
        ;;
    status)
        if [ -f "$HEALTH_STATUS" ]; then
            cat "$HEALTH_STATUS" | grep -o '"status": "[^"]*"' | cut -d'"' -f4
        else
            echo "unknown"
        fi
        ;;
    *)
        echo "Usage: $0 [check|status]"
        exit 1
        ;;
esac

