#!/bin/bash
#
# VaultOS Security Hardening Script
# Applies security best practices to the system
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/var/log/vaultos-hardening.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error() {
    echo "ERROR: $1" >&2 | tee -a "$LOG_FILE"
    exit 1
}

log "Starting VaultOS security hardening..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    error "This script must be run as root"
fi

# 1. Configure firewall
log "Configuring firewall..."
if command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --remove-service=dhcpv6-client 2>/dev/null || true
    firewall-cmd --permanent --remove-service=mdns 2>/dev/null || true
    firewall-cmd --reload
    log "Firewall configured"
else
    log "Warning: firewalld not found, skipping firewall configuration"
fi

# 2. Disable unnecessary services
log "Disabling unnecessary services..."
systemctl disable bluetooth.service 2>/dev/null || true
systemctl disable cups.service 2>/dev/null || true
systemctl disable avahi-daemon.service 2>/dev/null || true
systemctl stop bluetooth.service 2>/dev/null || true
systemctl stop cups.service 2>/dev/null || true
systemctl stop avahi-daemon.service 2>/dev/null || true
log "Unnecessary services disabled"

# 3. Configure automatic security updates
log "Configuring automatic security updates..."
if command -v dnf &> /dev/null; then
    # Install dnf-automatic for security updates
    dnf install -y dnf-automatic || true
    
    # Configure to install security updates automatically
    cat > /etc/dnf/automatic.conf <<EOF
[commands]
upgrade_type = security
random_sleep = 0
network_online_timeout = 60
download_updates = yes
apply_updates = yes

[emitters]
emit_via = stdio,email

[email]
email_from = root@localhost
email_to = root
email_host = localhost
EOF
    systemctl enable --now dnf-automatic.timer || true
    log "Automatic security updates configured"
fi

# 4. Secure boot configuration (if supported)
log "Checking secure boot support..."
if [ -d /sys/firmware/efi ]; then
    log "EFI system detected - secure boot can be enabled in BIOS/UEFI settings"
else
    log "Legacy BIOS detected - secure boot not available"
fi

# 5. Configure kernel security parameters
log "Configuring kernel security parameters..."
cat >> /etc/sysctl.d/99-vaultos-security.conf <<EOF
# VaultOS Security Hardening
# Prevent IP spoofing
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Ignore ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# Ignore send redirects
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Disable source routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# Log martian packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# Ignore ICMP ping requests
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Ignore bad ICMP errors
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Enable SYN flood protection
net.ipv4.tcp_syncookies = 1

# Disable IP forwarding
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# Enable kernel pointer obfuscation
kernel.kptr_restrict = 2

# Restrict dmesg access
kernel.dmesg_restrict = 1

# Enable ASLR
kernel.randomize_va_space = 2
EOF
sysctl -p /etc/sysctl.d/99-vaultos-security.conf
log "Kernel security parameters configured"

# 6. Configure SSH security (if SSH is installed)
if command -v sshd &> /dev/null; then
    log "Configuring SSH security..."
    if [ -f /etc/ssh/sshd_config ]; then
        # Backup original config
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.vaultos-backup
        
        # Apply security settings
        sed -i 's/#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
        sed -i 's/#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
        sed -i 's/#PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config
        sed -i 's/#X11Forwarding.*/X11Forwarding no/' /etc/ssh/sshd_config
        
        # Add additional security settings if not present
        if ! grep -q "MaxAuthTries" /etc/ssh/sshd_config; then
            echo "MaxAuthTries 3" >> /etc/ssh/sshd_config
        fi
        if ! grep -q "ClientAliveInterval" /etc/ssh/sshd_config; then
            echo "ClientAliveInterval 300" >> /etc/ssh/sshd_config
            echo "ClientAliveCountMax 2" >> /etc/ssh/sshd_config
        fi
        
        systemctl restart sshd || true
        log "SSH security configured"
    fi
fi

# 7. Set up audit logging
log "Configuring audit logging..."
if command -v auditctl &> /dev/null; then
    # Enable auditd
    systemctl enable auditd || true
    systemctl start auditd || true
    log "Audit logging enabled"
else
    log "Warning: auditd not installed, skipping audit configuration"
fi

# 8. Configure file permissions
log "Securing file permissions..."
# Remove world-writable files (except necessary ones)
find / -xdev -type f -perm -0002 -exec chmod o-w {} \; 2>/dev/null || true
# Remove world-writable directories
find / -xdev -type d -perm -0002 -exec chmod o-w {} \; 2>/dev/null || true
log "File permissions secured"

# 9. Create security audit log directory
mkdir -p /var/log/vaultos-security
chmod 750 /var/log/vaultos-security

log "VaultOS security hardening complete!"
log "Hardening log saved to: $LOG_FILE"
echo ""
echo "Security hardening completed successfully."
echo "Please review the log file at: $LOG_FILE"

