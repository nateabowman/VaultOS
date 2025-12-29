#!/bin/bash
#
# VaultOS System Monitor
# System monitoring daemon, centralized logging, performance metrics
#

set -e

CONFIG_DIR="$HOME/.config/vaultos"
MONITOR_LOG="$CONFIG_DIR/monitor.log"
METRICS_DIR="$CONFIG_DIR/metrics"
MONITOR_INTERVAL=5  # seconds

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Initialize
mkdir -p "$METRICS_DIR"
touch "$MONITOR_LOG"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$MONITOR_LOG"
}

# Collect CPU metrics
collect_cpu() {
    local cpu_file="$METRICS_DIR/cpu.json"
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    
    cat > "$cpu_file" <<EOF
{
  "timestamp": "$(date +%s)",
  "usage_percent": $cpu_usage
}
EOF
}

# Collect memory metrics
collect_memory() {
    local mem_file="$METRICS_DIR/memory.json"
    local mem_total=$(free -m | awk '/^Mem:/{print $2}')
    local mem_used=$(free -m | awk '/^Mem:/{print $3}')
    local mem_percent=$((mem_used * 100 / mem_total))
    
    cat > "$mem_file" <<EOF
{
  "timestamp": "$(date +%s)",
  "total_mb": $mem_total,
  "used_mb": $mem_used,
  "usage_percent": $mem_percent
}
EOF
}

# Collect disk metrics
collect_disk() {
    local disk_file="$METRICS_DIR/disk.json"
    local disk_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    cat > "$disk_file" <<EOF
{
  "timestamp": "$(date +%s)",
  "usage_percent": $disk_usage
}
EOF
}

# Collect network metrics
collect_network() {
    local net_file="$METRICS_DIR/network.json"
    local rx_bytes=$(cat /sys/class/net/*/statistics/rx_bytes 2>/dev/null | awk '{sum+=$1} END {print sum}' || echo "0")
    local tx_bytes=$(cat /sys/class/net/*/statistics/tx_bytes 2>/dev/null | awk '{sum+=$1} END {print sum}' || echo "0")
    
    cat > "$net_file" <<EOF
{
  "timestamp": "$(date +%s)",
  "rx_bytes": $rx_bytes,
  "tx_bytes": $tx_bytes
}
EOF
}

# Collect all metrics
collect_metrics() {
    collect_cpu
    collect_memory
    collect_disk
    collect_network
    log "Metrics collected"
}

# Monitor loop
monitor_loop() {
    log "Starting monitoring daemon"
    
    while true; do
        collect_metrics
        
        # Check for alerts
        check_alerts
        
        sleep "$MONITOR_INTERVAL"
    done
}

# Check for alert conditions
check_alerts() {
    # High CPU usage
    local cpu_usage=$(cat "$METRICS_DIR/cpu.json" 2>/dev/null | grep -o '"usage_percent": [0-9.]*' | cut -d' ' -f2 || echo "0")
    if (( $(echo "$cpu_usage > 90" | bc -l 2>/dev/null || echo "0") )); then
        log "ALERT: High CPU usage: ${cpu_usage}%"
    fi
    
    # High memory usage
    local mem_percent=$(cat "$METRICS_DIR/memory.json" 2>/dev/null | grep -o '"usage_percent": [0-9]*' | cut -d' ' -f2 || echo "0")
    if [ "$mem_percent" -gt 90 ]; then
        log "ALERT: High memory usage: ${mem_percent}%"
    fi
    
    # Low disk space
    local disk_usage=$(cat "$METRICS_DIR/disk.json" 2>/dev/null | grep -o '"usage_percent": [0-9]*' | cut -d' ' -f2 || echo "0")
    if [ "$disk_usage" -gt 90 ]; then
        log "ALERT: Low disk space: ${disk_usage}% used"
    fi
}

# Show metrics
show_metrics() {
    echo -e "${GREEN}System Metrics${RESET}"
    echo ""
    
    if [ -f "$METRICS_DIR/cpu.json" ]; then
        echo -e "${BLUE}CPU:${RESET}"
        cat "$METRICS_DIR/cpu.json" | grep -o '"usage_percent": [0-9.]*' | cut -d' ' -f2 | xargs printf "  Usage: %.1f%%\n"
    fi
    
    if [ -f "$METRICS_DIR/memory.json" ]; then
        echo -e "${BLUE}Memory:${RESET}"
        local mem_percent=$(cat "$METRICS_DIR/memory.json" | grep -o '"usage_percent": [0-9]*' | cut -d' ' -f2)
        local mem_used=$(cat "$METRICS_DIR/memory.json" | grep -o '"used_mb": [0-9]*' | cut -d' ' -f2)
        local mem_total=$(cat "$METRICS_DIR/memory.json" | grep -o '"total_mb": [0-9]*' | cut -d' ' -f2)
        echo "  Usage: ${mem_percent}% (${mem_used}MB / ${mem_total}MB)"
    fi
    
    if [ -f "$METRICS_DIR/disk.json" ]; then
        echo -e "${BLUE}Disk:${RESET}"
        local disk_usage=$(cat "$METRICS_DIR/disk.json" | grep -o '"usage_percent": [0-9]*' | cut -d' ' -f2)
        echo "  Usage: ${disk_usage}%"
    fi
    
    echo ""
}

# Main
case "${1:-}" in
    start)
        monitor_loop &
        echo $! > "$CONFIG_DIR/monitor.pid"
        echo "Monitoring daemon started (PID: $(cat "$CONFIG_DIR/monitor.pid"))"
        ;;
    stop)
        if [ -f "$CONFIG_DIR/monitor.pid" ]; then
            kill $(cat "$CONFIG_DIR/monitor.pid") 2>/dev/null || true
            rm -f "$CONFIG_DIR/monitor.pid"
            echo "Monitoring daemon stopped"
        fi
        ;;
    status)
        if [ -f "$CONFIG_DIR/monitor.pid" ] && kill -0 $(cat "$CONFIG_DIR/monitor.pid") 2>/dev/null; then
            echo "Monitoring daemon is running (PID: $(cat "$CONFIG_DIR/monitor.pid"))"
        else
            echo "Monitoring daemon is not running"
        fi
        ;;
    metrics)
        collect_metrics
        show_metrics
        ;;
    *)
        echo "Usage: $0 [start|stop|status|metrics]"
        exit 1
        ;;
esac

