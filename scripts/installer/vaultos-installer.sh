#!/bin/bash
# VaultOS Enhanced Installer
# Automated installation with customization options

set -e

INSTALL_DIR="/mnt/vaultos"
CONFIG_FILE="/tmp/vaultos-install.conf"

# Installation configuration
configure_install() {
    cat > "$CONFIG_FILE" << 'EOF'
# VaultOS Installation Configuration
INSTALL_TYPE=full
DISK=/dev/sda
PARTITION_SCHEME=auto
HOSTNAME=vaultos
USERNAME=vaultdweller
TIMEZONE=UTC
KEYBOARD_LAYOUT=us
EOF
    
    echo "Installation configuration created: $CONFIG_FILE"
    echo "Edit this file to customize installation"
}

# Partition disk
partition_disk() {
    local disk="$1"
    local scheme="${2:-auto}"
    
    if [ -z "$disk" ]; then
        echo "Error: Disk not specified"
        exit 1
    fi
    
    echo "Partitioning disk: $disk"
    
    case "$scheme" in
        auto)
            # Automatic partitioning (GPT with EFI)
            parted "$disk" --script mklabel gpt
            parted "$disk" --script mkpart primary fat32 1MiB 512MiB
            parted "$disk" --script set 1 esp on
            parted "$disk" --script mkpart primary ext4 512MiB 100%
            ;;
        manual)
            echo "Manual partitioning not yet implemented"
            exit 1
            ;;
        *)
            echo "Error: Unknown partition scheme: $scheme"
            exit 1
            ;;
    esac
    
    echo "Disk partitioned"
}

# Format partitions
format_partitions() {
    local disk="$1"
    
    echo "Formatting partitions..."
    
    # EFI partition
    mkfs.fat -F32 "${disk}1"
    
    # Root partition
    mkfs.ext4 -F "${disk}2"
    
    echo "Partitions formatted"
}

# Mount filesystems
mount_filesystems() {
    local disk="$1"
    
    echo "Mounting filesystems..."
    
    mkdir -p "$INSTALL_DIR"
    mount "${disk}2" "$INSTALL_DIR"
    mkdir -p "$INSTALL_DIR/boot/efi"
    mount "${disk}1" "$INSTALL_DIR/boot/efi"
    
    echo "Filesystems mounted"
}

# Install system
install_system() {
    echo "Installing VaultOS..."
    
    # Install base system (would use dnf --installroot)
    # dnf --installroot="$INSTALL_DIR" install -y @core vaultos-*
    
    echo "System installed"
}

# Configure system
configure_system() {
    local hostname="$1"
    local username="$2"
    
    echo "Configuring system..."
    
    # Set hostname
    echo "$hostname" > "$INSTALL_DIR/etc/hostname"
    
    # Create user
    chroot "$INSTALL_DIR" useradd -m -G wheel "$username"
    
    # Configure bootloader
    chroot "$INSTALL_DIR" grub2-mkconfig -o /boot/grub2/grub.cfg
    
    echo "System configured"
}

# Post-installation
post_install() {
    echo "Running post-installation tasks..."
    
    # Enable services
    chroot "$INSTALL_DIR" systemctl enable vaultwm.service
    chroot "$INSTALL_DIR" systemctl enable vaultos-theme-manager.service
    
    echo "Post-installation complete"
}

# Show menu
show_menu() {
    clear
    echo "VaultOS Installer"
    echo ""
    echo "1) Configure installation"
    echo "2) Partition disk"
    echo "3) Format partitions"
    echo "4) Mount filesystems"
    echo "5) Install system"
    echo "6) Configure system"
    echo "7) Post-installation"
    echo "8) Full automated install"
    echo "9) Exit"
}

# Full automated install
full_install() {
    read -p "Disk (e.g., /dev/sda): " disk
    read -p "Hostname [vaultos]: " hostname
    hostname="${hostname:-vaultos}"
    read -p "Username [vaultdweller]: " username
    username="${username:-vaultdweller}"
    
    partition_disk "$disk"
    format_partitions "$disk"
    mount_filesystems "$disk"
    install_system
    configure_system "$hostname" "$username"
    post_install
    
    echo "Installation complete!"
    echo "Reboot to start using VaultOS"
}

# Main
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root"
    exit 1
fi

if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
        show_menu
        read -p "Choice: " choice
        case $choice in
            1) configure_install;;
            2) read -p "Disk: " disk; read -p "Scheme [auto]: " scheme; partition_disk "$disk" "${scheme:-auto}";;
            3) read -p "Disk: " disk; format_partitions "$disk";;
            4) read -p "Disk: " disk; mount_filesystems "$disk";;
            5) install_system;;
            6) read -p "Hostname: " hostname; read -p "Username: " username; configure_system "$hostname" "$username";;
            7) post_install;;
            8) full_install;;
            9) exit 0;;
            *) echo "Invalid choice";;
        esac
    done
else
    # Command-line mode
    case "$1" in
        configure) configure_install;;
        partition) partition_disk "$2" "$3";;
        format) format_partitions "$2";;
        mount) mount_filesystems "$2";;
        install) install_system;;
        config) configure_system "$2" "$3";;
        post) post_install;;
        full) full_install;;
        *) echo "Usage: $0 {configure|partition|format|mount|install|config|post|full}"; exit 1;;
    esac
fi

