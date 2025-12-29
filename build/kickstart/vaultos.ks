# VaultOS Kickstart Configuration
# Fedora-based Fallout-themed Linux Distribution

# System language
lang en_US.UTF-8

# Keyboard layout
keyboard us

# Network configuration
network --bootproto=dhcp --device=link --activate

# Root password - will be set on first boot (secure by default)
# Using --lock to require password change on first boot
rootpw --lock
# User account - will be created on first boot with secure password
# Default user creation moved to firstboot script for security

# System timezone
timezone America/New_York --utc

# Bootloader configuration
bootloader --location=mbr --boot-drive=sda

# Clear partitions and create new ones
clearpart --all --initlabel
autopart --type=lvm

# Packages to install
%packages --nobase --excludedocs
@core
@standard
kernel
grub2
plymouth
systemd
bash
zsh
vim
nano
ranger
alacritty
i3wm
openbox
xorg-x11-server-Xorg
xorg-x11-xinit
xorg-x11-apps
xorg-x11-utils
fontconfig
%end

# Post-installation scripts
%post
# Install VaultOS custom packages
# This will be populated with our custom RPMs

# Enable services
systemctl enable vaultwm.service || true

# Configure GRUB theme
if [ -d /boot/grub2/themes/vaultos ]; then
    grub2-mkconfig -o /boot/grub2/grub.cfg
fi

# Configure Plymouth theme
if [ -d /usr/share/plymouth/themes/vaultos ]; then
    plymouth-set-default-theme vaultos
fi

# Install security hardening script
if [ -f /usr/share/vaultos/scripts/hardening.sh ]; then
    chmod +x /usr/share/vaultos/scripts/hardening.sh
fi

# Configure firewall (basic rules)
if command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-service=ssh || true
    firewall-cmd --reload || true
fi

# Disable unnecessary services for security
systemctl disable bluetooth.service || true
systemctl disable cups.service || true

%end

# First boot configuration - REQUIRED for security
%firstboot --interactive
#!/bin/bash
# First boot security configuration script

# Force root password change
echo "VaultOS First Boot Security Configuration"
echo "=========================================="
echo ""
echo "SECURITY: You must set a root password."
passwd root

# Create default user with secure password
echo ""
echo "Creating default user 'vaultdweller'..."
echo "You will be prompted to set a secure password."
useradd -m -G wheel -s /bin/bash -c "Vault Dweller" vaultdweller
passwd vaultdweller

# Set up sudo access
echo "vaultdweller ALL=(ALL) ALL" >> /etc/sudoers.d/vaultos-users

# Run security hardening script
if [ -f /usr/share/vaultos/scripts/hardening.sh ]; then
    /usr/share/vaultos/scripts/hardening.sh
fi

# Mark first boot as complete
touch /etc/vaultos/firstboot-complete

echo ""
echo "First boot configuration complete!"
echo "Please reboot the system."
%end

