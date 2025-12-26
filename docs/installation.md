# VaultOS Installation Guide

Complete guide for installing VaultOS on your system.

## Prerequisites

- Compatible hardware (x86_64)
- At least 10GB free disk space
- 2GB RAM minimum (4GB recommended)
- Bootable USB drive or DVD

## Installation Methods

### Method 1: Live CD Installation

1. **Download or Build ISO**
   - Download pre-built ISO, or
   - Build from source using `./scripts/build-iso.sh`

2. **Create Bootable Media**
   ```bash
   # USB drive
   sudo dd if=VaultOS.iso of=/dev/sdX bs=4M status=progress
   
   # Or use tools like:
   # - Fedora Media Writer
   # - balenaEtcher
   # - Rufus (Windows)
   ```

3. **Boot from Media**
   - Boot your computer from USB/DVD
   - Select "Install VaultOS" from boot menu

4. **Installation Process**
   - Follow the installation wizard
   - Configure disk partitioning
   - Set user account and password
   - Complete installation

5. **Reboot**
   - Remove installation media
   - Boot into VaultOS
   - Enjoy your Fallout-themed Linux!

### Method 2: Manual Component Installation

Install VaultOS components on existing Fedora system:

1. **Build Packages**
   ```bash
   ./scripts/build-packages.sh
   ```

2. **Install Packages**
   ```bash
   sudo rpm -ivh ~/rpmbuild/RPMS/x86_64/vaultos-*.rpm
   ```

3. **Configure Components**
   - GRUB theme: `cd src/boot/grub && sudo ./install.sh`
   - Plymouth: `cd src/boot/plymouth && sudo ./install.sh`
   - Shell: `cd src/shell && ./install.sh`
   - Terminal: Follow terminal-specific instructions

4. **Select Window Manager**
   - Log out
   - Select "VaultOS" session from display manager
   - Log in

## Post-Installation

### First Boot Configuration

1. **Update System**
   ```bash
   sudo dnf update
   ```

2. **Install Additional Software**
   ```bash
   sudo dnf install firefox vim git
   ```

3. **Configure Terminal**
   - Set terminal color scheme
   - Configure shell prompt
   - Test Fallout aliases

4. **Customize Theme**
   - Select VaultOS theme in settings
   - Set wallpaper
   - Configure icons

## Troubleshooting

### Boot Issues

**GRUB not showing theme:**
```bash
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

**Plymouth not working:**
```bash
sudo plymouth-set-default-theme vaultos
sudo dracut --force
```

### Display Issues

**Window manager not starting:**
- Check X11 is installed: `sudo dnf install xorg-x11-server-Xorg`
- Check logs: `journalctl -u vaultwm.service`

**Theme not applying:**
- Verify theme files: `ls /usr/share/themes/VaultOS/`
- Set theme: `gsettings set org.gnome.desktop.interface gtk-theme "VaultOS"`

### Terminal Issues

**Colors not showing:**
- Check terminal supports 256 colors
- Verify color scheme file is correct
- Try different terminal emulator

## Uninstallation

To remove VaultOS components:

```bash
# Remove packages
sudo rpm -e vaultos-themes vaultos-terminal vaultos-shell vaultos-boot vaultwm

# Remove configuration files
rm -rf ~/.config/vaultos
rm -f ~/.bashrc.vaultos ~/.zshrc.vaultos
```

## System Requirements

### Minimum
- CPU: 1GHz x86_64
- RAM: 2GB
- Disk: 10GB
- Graphics: VESA-compatible

### Recommended
- CPU: 2GHz+ multi-core
- RAM: 4GB+
- Disk: 20GB+
- Graphics: Hardware acceleration support

## Network Installation

For network-based installation:

1. Boot from minimal ISO
2. Configure network
3. Point to VaultOS repository
4. Install via kickstart

## Dual Boot

VaultOS can be installed alongside other operating systems:

1. Shrink existing partition
2. Install VaultOS to free space
3. GRUB will detect other OS
4. Select OS from boot menu

## Virtual Machine Installation

VaultOS works well in VMs:

- **VirtualBox**: Use VBoxVGA or VMSVGA
- **VMware**: Use VMware SVGA
- **QEMU/KVM**: Use virtio or qxl
- **Hyper-V**: Use standard VGA

Recommended VM settings:
- 2GB+ RAM
- 20GB+ disk
- Enable 3D acceleration if available

## Advanced Installation

### Custom Partitioning

For advanced users, custom partitioning options:
- Separate /home partition
- Swap partition
- LVM configuration
- Encryption support

### Automated Installation

Use kickstart for automated installation:
```bash
livemedia-creator --ks=vaultos.ks --make-iso
```

## Support

For installation help:
- Check logs: `/var/log/anaconda/` (during installation)
- System logs: `journalctl`
- Documentation: `docs/` directory

