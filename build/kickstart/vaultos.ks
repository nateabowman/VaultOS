# VaultOS Kickstart Configuration
# Fedora-based Fallout-themed Linux Distribution

# System language
lang en_US.UTF-8

# Keyboard layout
keyboard us

# Network configuration
network --bootproto=dhcp --device=link --activate

# Root password (should be changed on first boot)
rootpw --plaintext vaultos
# User account
user --name=vaultdweller --groups=wheel --password=vaultos --plaintext --gecos="Vault Dweller"

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

# Set default shell to bash
usermod -s /bin/bash vaultdweller

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

%end

# First boot configuration
%firstboot --interactive
# User will be prompted to configure system on first boot
%end

