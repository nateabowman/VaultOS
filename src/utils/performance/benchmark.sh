#!/bin/bash
#
# VaultOS Performance Benchmark
# Benchmark system performance
#

GREEN='\033[0;32m'
BRIGHT_GREEN='\033[1;32m'
AMBER='\033[1;33m'
RESET='\033[0m'

echo -e "${BRIGHT_GREEN}VaultOS Performance Benchmark${RESET}"
echo ""

# CPU Benchmark
echo -e "${GREEN}[CPU Benchmark]${RESET}"
echo "Running CPU benchmark (10 seconds)..."
START_TIME=$(date +%s.%N)
TIMEOUT 10 sh -c 'while :; do :; done' &>/dev/null &
PID=$!
sleep 10
kill $PID 2>/dev/null
END_TIME=$(date +%s.%N)
CPU_TIME=$(echo "$END_TIME - $START_TIME" | bc)
echo "CPU test completed"
echo ""

# Memory Benchmark
echo -e "${GREEN}[Memory Benchmark]${RESET}"
echo "Testing memory bandwidth..."
if command -v dd &> /dev/null; then
    MEM_SIZE=100M
    START_TIME=$(date +%s.%N)
    dd if=/dev/zero of=/tmp/vaultos_benchmark bs=1M count=100 2>/dev/null
    END_TIME=$(date +%s.%N)
    MEM_TIME=$(echo "$END_TIME - $START_TIME" | bc)
    MEM_MBPS=$(echo "scale=2; 100 / $MEM_TIME" | bc)
    echo "Memory write: ${MEM_MBPS} MB/s"
    rm -f /tmp/vaultos_benchmark
else
    echo "dd not available for memory test"
fi
echo ""

# Disk Benchmark
echo -e "${GREEN}[Disk Benchmark]${RESET}"
if command -v dd &> /dev/null; then
    echo "Testing disk write performance..."
    START_TIME=$(date +%s.%N)
    dd if=/dev/zero of=/tmp/vaultos_disk_benchmark bs=1M count=500 2>/dev/null
    END_TIME=$(date +%s.%N)
    DISK_TIME=$(echo "$END_TIME - $START_TIME" | bc)
    DISK_MBPS=$(echo "scale=2; 500 / $DISK_TIME" | bc)
    echo "Disk write: ${DISK_MBPS} MB/s"
    rm -f /tmp/vaultos_disk_benchmark
else
    echo "dd not available for disk test"
fi
echo ""

# Window Manager Performance
echo -e "${GREEN}[Window Manager Performance]${RESET}"
if pgrep -x vaultwm > /dev/null; then
    echo "VaultWM is running"
    # Could add WM-specific benchmarks here
else
    echo "VaultWM is not running"
fi
echo ""

echo -e "${AMBER}Benchmark complete${RESET}"

