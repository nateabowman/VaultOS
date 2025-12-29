#!/bin/bash
# VaultOS Compliance Checking Tool
# CIS benchmark compliance and security scanning

set -e

COMPLIANCE_DIR="$HOME/.vaultos/compliance"
REPORT_FILE="$COMPLIANCE_DIR/compliance-report-$(date +%Y%m%d-%H%M%S).txt"

# Initialize compliance checking
init_compliance() {
    mkdir -p "$COMPLIANCE_DIR"
    echo "Compliance checking initialized"
}

# Check CIS benchmark compliance
check_cis_benchmark() {
    echo "Checking CIS Benchmark compliance..."
    
    local score=0
    local total=0
    
    # Check 1: Password policies
    total=$((total + 1))
    if grep -q "PASS_MIN_DAYS.*7" /etc/login.defs 2>/dev/null; then
        echo "✓ Password minimum days configured"
        score=$((score + 1))
    else
        echo "✗ Password minimum days not configured"
    fi
    
    # Check 2: Firewall enabled
    total=$((total + 1))
    if systemctl is-active --quiet firewalld; then
        echo "✓ Firewall is active"
        score=$((score + 1))
    else
        echo "✗ Firewall is not active"
    fi
    
    # Check 3: SELinux enabled
    total=$((total + 1))
    if [ "$(getenforce)" != "Disabled" ]; then
        echo "✓ SELinux is enabled"
        score=$((score + 1))
    else
        echo "✗ SELinux is disabled"
    fi
    
    # Check 4: SSH root login disabled
    total=$((total + 1))
    if grep -q "^PermitRootLogin no" /etc/ssh/sshd_config 2>/dev/null; then
        echo "✓ SSH root login disabled"
        score=$((score + 1))
    else
        echo "✗ SSH root login may be enabled"
    fi
    
    # Check 5: Automatic updates
    total=$((total + 1))
    if systemctl is-enabled --quiet dnf-automatic.timer 2>/dev/null; then
        echo "✓ Automatic updates enabled"
        score=$((score + 1))
    else
        echo "✗ Automatic updates not enabled"
    fi
    
    local percentage=$((score * 100 / total))
    echo ""
    echo "CIS Benchmark Score: $score/$total ($percentage%)"
    
    return $percentage
}

# Security scanning
security_scan() {
    echo "Performing security scan..."
    
    # Check for world-writable files
    echo "Checking for world-writable files..."
    find /home -type f -perm -002 2>/dev/null | head -10
    
    # Check for SUID/SGID files
    echo "Checking for SUID/SGID files..."
    find /usr -type f \( -perm -4000 -o -perm -2000 \) 2>/dev/null | head -10
    
    # Check open ports
    echo "Checking listening ports..."
    ss -tuln | grep LISTEN
}

# Generate compliance report
generate_report() {
    mkdir -p "$COMPLIANCE_DIR"
    
    {
        echo "VaultOS Compliance Report"
        echo "Generated: $(date)"
        echo "Hostname: $(hostname)"
        echo ""
        echo "=== CIS Benchmark ==="
        check_cis_benchmark
        echo ""
        echo "=== Security Scan ==="
        security_scan
    } > "$REPORT_FILE"
    
    echo "Compliance report generated: $REPORT_FILE"
}

# Show menu
show_menu() {
    clear
    echo "VaultOS Compliance Checker"
    echo ""
    echo "1) Initialize compliance checking"
    echo "2) Check CIS benchmark"
    echo "3) Security scan"
    echo "4) Generate full report"
    echo "5) Exit"
}

# Main
if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
        show_menu
        read -p "Choice: " choice
        case $choice in
            1) init_compliance;;
            2) check_cis_benchmark; read -p "Press Enter to continue...";;
            3) security_scan; read -p "Press Enter to continue...";;
            4) generate_report;;
            5) exit 0;;
            *) echo "Invalid choice";;
        esac
    done
else
    # Command-line mode
    case "$1" in
        init) init_compliance;;
        cis) check_cis_benchmark;;
        scan) security_scan;;
        report) generate_report;;
        *) echo "Usage: $0 {init|cis|scan|report}"; exit 1;;
    esac
fi

