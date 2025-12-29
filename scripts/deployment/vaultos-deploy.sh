#!/bin/bash
# VaultOS Deployment Tool
# Network installation and automated deployment

set -e

PXE_DIR="/var/lib/tftpboot/vaultos"
DEPLOY_CONFIG="/etc/vaultos/deploy.conf"

# Setup PXE boot
setup_pxe() {
    if [ "$EUID" -ne 0 ]; then
        echo "Error: This script must be run as root"
        exit 1
    fi
    
    echo "Setting up PXE boot server..."
    
    # Install required packages
    dnf install -y tftp-server dhcp-server syslinux
    
    # Create PXE directory
    mkdir -p "$PXE_DIR"
    
    # Copy boot files
    cp /usr/share/syslinux/pxelinux.0 "$PXE_DIR/"
    cp /usr/share/syslinux/menu.c32 "$PXE_DIR/"
    
    # Create PXE configuration
    cat > "$PXE_DIR/pxelinux.cfg/default" << 'EOF'
default vaultos
label vaultos
    kernel vaultos/vmlinuz
    append initrd=vaultos/initrd.img inst.ks=http://server/vaultos/kickstart.ks
EOF
    
    echo "PXE boot server configured"
}

# Deploy to multiple hosts
deploy_hosts() {
    local hosts_file="$1"
    
    if [ -z "$hosts_file" ] || [ ! -f "$hosts_file" ]; then
        echo "Usage: $0 deploy <hosts_file>"
        exit 1
    fi
    
    echo "Deploying to hosts..."
    
    while IFS= read -r host; do
        if [ -n "$host" ] && [[ ! "$host" =~ ^# ]]; then
            echo "Deploying to: $host"
            # In a real implementation, would use ansible or similar
            # ansible-playbook -i "$host" deploy-vaultos.yml
        fi
    done < "$hosts_file"
    
    echo "Deployment complete"
}

# Show menu
show_menu() {
    clear
    echo "VaultOS Deployment Tool"
    echo ""
    echo "1) Setup PXE boot"
    echo "2) Deploy to hosts"
    echo "3) Exit"
}

# Main
if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
        show_menu
        read -p "Choice: " choice
        case $choice in
            1) setup_pxe;;
            2) read -p "Hosts file: " hosts; deploy_hosts "$hosts";;
            3) exit 0;;
            *) echo "Invalid choice";;
        esac
    done
else
    # Command-line mode
    case "$1" in
        pxe) setup_pxe;;
        deploy) deploy_hosts "$2";;
        *) echo "Usage: $0 {pxe|deploy}"; exit 1;;
    esac
fi

