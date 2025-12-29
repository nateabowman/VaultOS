# VaultOS User Guide

Complete user guide for VaultOS - Fallout-themed Linux distribution.

## Table of Contents

1. [Introduction](#introduction)
2. [Getting Started](#getting-started)
3. [Desktop Environment](#desktop-environment)
4. [Applications](#applications)
5. [Customization](#customization)
6. [Troubleshooting](#troubleshooting)

## Introduction

VaultOS is a Linux distribution based on Fedora with comprehensive Fallout theming. Every component is designed to create an immersive retro-futuristic experience inspired by the Fallout game series.

### Key Features

- Pip-Boy green terminal aesthetic
- Vault-Tec blue/gold theme variants
- Custom VaultWM window manager
- Fallout-themed shell aliases
- Complete GTK/Qt theming
- Custom boot themes (GRUB, Plymouth)

## Getting Started

### First Boot

After installation, VaultOS will boot with:
- GRUB bootloader with Fallout theme
- Plymouth boot splash
- VaultWM window manager
- Pip-Boy terminal interface

### Initial Setup

1. **Configure Network**: Use network manager or terminal
2. **Update System**: `sudo dnf update`
3. **Install Additional Software**: `sudo dnf install <package>`

## Desktop Environment

### VaultWM Window Manager

VaultWM is a lightweight, keyboard-driven window manager.

#### Key Bindings

- `Mod4 + Enter` - Launch terminal
- `Mod4 + D` - Launch application launcher
- `Mod4 + Q` - Close window
- `Mod4 + T` - Toggle layout (Tiling → Floating → Monocle)
- `Mod4 + 1-9` - Switch workspaces
- `Mod4 + H/J/K/L` - Navigate windows (vim-style)
- `Mod4 + Arrow Keys` - Navigate windows

See [Window Manager Documentation](../src/wm/README.md) for complete key binding reference.

#### Workspaces

VaultOS provides 9 virtual workspaces. Switch between them with `Mod4 + 1-9`.

### Status Bar

The status bar displays:
- Current workspace
- CPU usage
- Memory usage
- Network status
- Date and time
- Number of windows
- Current layout mode

## Applications

### Terminal

The terminal uses Pip-Boy green color scheme (#00FF41 on black).

### Shell Commands

VaultOS includes Fallout-themed shell aliases:

- `pipboy` - Display system information
- `vault` - Go to home directory
- `status` - Show system status
- `inventory` - List files (ls -lah)
- `map` - Show current directory (pwd)
- `stimpak` - System administration (sudo)
- `quest` - Show active quests
- `wasteland` - Disk usage (df -h)
- `vault-tec` - System services (systemctl status)

### File Manager

VaultOS supports multiple file managers:
- **Ranger** - Terminal-based (recommended)
- **Thunar** - GUI file manager
- **Nautilus** - GNOME file manager

All are themed with Pip-Boy colors.

### Text Editors

- **Vim** - Configured with Pip-Boy colors
- **Nano** - Uses terminal color scheme
- **VS Code** - Pip-Boy theme available

## Customization

### Changing Themes

Switch between Pip-Boy and Vault-Tec themes:

```bash
vaultos-theme-switcher
```

Or manually:
```bash
# Pip-Boy theme (default)
gsettings set org.gnome.desktop.interface gtk-theme "VaultOS"

# Icon theme
gsettings set org.gnome.desktop.interface icon-theme "VaultOS"
```

### Wallpapers

Set wallpapers:
```bash
# Using feh (VaultWM)
feh --bg-fill ~/.local/share/vaultos/wallpapers/pipboy-grid-1920x1080.png

# Using GNOME
gsettings set org.gnome.desktop.background picture-uri file:///path/to/wallpaper.png
```

### Terminal Themes

Terminal themes are in `/usr/share/vaultos/terminal/themes/`

Apply:
```bash
# Alacritty
cp /usr/share/vaultos/terminal/profiles/alacritty-pipboy.yml ~/.config/alacritty/alacritty.yml

# GNOME Terminal
/usr/share/vaultos/terminal/profiles/gnome-terminal-pipboy.sh
```

## Troubleshooting

### Window Manager Not Starting

1. Check X11 is installed: `sudo dnf install xorg-x11-server-Xorg`
2. Check logs: `journalctl -u vaultwm.service`
3. Try starting manually: `vaultwm`

### Theme Not Applying

1. Verify theme files exist:
   ```bash
   ls /usr/share/themes/VaultOS/
   ls /usr/share/icons/VaultOS/
   ```

2. Set theme manually:
   ```bash
   gsettings set org.gnome.desktop.interface gtk-theme "VaultOS"
   gsettings set org.gnome.desktop.interface icon-theme "VaultOS"
   ```

3. Restart applications

### Terminal Colors Not Showing

1. Check terminal supports 256 colors
2. Verify color scheme file syntax
3. Try different terminal emulator

### Boot Issues

**GRUB theme not showing:**
```bash
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

**Plymouth not working:**
```bash
sudo plymouth-set-default-theme vaultos
sudo dracut --force
```

## Getting Help

- Documentation: `/usr/share/doc/vaultos/`
- Online: [Project Repository]
- Issues: [Issue Tracker]

## Advanced Usage

### System Utilities

**Pip-Boy Viewer:**
```bash
pipboy-viewer
```

Real-time system status display with Pip-Boy interface.

**System Status:**
```bash
pipboy-status
```

Detailed system information report.

### Package Management

VaultOS uses DNF package manager (Fedora-based):

```bash
# Update system
sudo dnf update

# Install package
sudo dnf install <package>

# Search packages
dnf search <keyword>

# Repository management
dnf repolist
```

## Tips and Tricks

1. **Multiple Workspaces**: Use workspaces to organize your workflow
2. **Keyboard Navigation**: Learn VaultWM key bindings for efficient navigation
3. **Shell Aliases**: Use Fallout-themed aliases for common tasks
4. **Terminal Multiplexer**: Use tmux or screen with Pip-Boy theme
5. **Custom Scripts**: Add custom scripts to `~/.local/bin/`

## See Also

- [Installation Guide](installation.md)
- [Customization Guide](customization.md)
- [Developer Documentation](developer.md)

