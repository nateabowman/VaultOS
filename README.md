# VaultOS - Fallout-Themed Linux Distribution

A custom Linux distribution based on Fedora with comprehensive Fallout theming, featuring Pip-Boy terminal aesthetics, Vault-Tec branding, and a custom lightweight window manager.

## Overview

VaultOS is a minimal but fully-fleshed-out Linux distribution that brings the Fallout aesthetic to your desktop. Every component is themed to create an immersive retro-futuristic experience inspired by the Fallout game series.

## Features

### Boot System
- **GRUB Theme**: Fallout-themed bootloader with Pip-Boy green color scheme
- **Plymouth Splash**: Animated boot splash with Vault door or Pip-Boy sequence
- **Custom Boot Messages**: Fallout-themed kernel boot messages

### Terminal & Shell
- **Pip-Boy Terminal Theme**: Green monochrome (#00FF41) color scheme
- **Vault-Tec Theme**: Blue and gold alternative theme
- **Custom Shell Prompt**: Pip-Boy-style prompt with Fallout-themed aliases
- **Terminal Profiles**: Pre-configured profiles for Alacritty and GNOME Terminal

### Window Manager
- **VaultWM**: Custom lightweight window manager with:
  - Tiling and floating modes
  - Pip-Boy-style status bar
  - Keyboard-driven navigation
  - Fallout aesthetic throughout

### Theming
- **GTK Themes**: GTK3 and GTK4 themes with Pip-Boy green
- **Qt Themes**: Qt stylesheet matching the aesthetic
- **Color Schemes**: Consistent Pip-Boy and Vault-Tec color palettes
- **Icons & Assets**: Fallout-themed icons and wallpapers

### Applications
- **Themed Applications**: File managers, text editors, and utilities
- **Fallout Aliases**: Custom command aliases (pipboy, vault, quest, etc.)
- **Consistent UI**: All applications share the Fallout aesthetic

## Project Structure

```
VaultOS/
├── build/              # Build scripts and configuration
│   ├── kickstart/     # Fedora kickstart files
│   ├── livecd/        # Live CD build configuration
│   └── packages/      # Custom package definitions
├── src/               # Source files
│   ├── boot/          # Bootloader themes
│   ├── wm/            # Window manager source
│   ├── terminal/      # Terminal configurations
│   ├── shell/         # Shell customizations
│   ├── fonts/         # Custom fonts
│   ├── themes/        # GTK/Qt themes
│   ├── icons/         # Icon sets
│   └── assets/        # Wallpapers and graphics
├── packages/          # RPM spec files
├── scripts/           # Build and utility scripts
└── docs/              # Documentation
```

## Quick Start

### Building VaultOS

1. **Setup Build Environment**
   ```bash
   ./scripts/setup-build-env.sh
   ```

2. **Build Custom Packages**
   ```bash
   ./scripts/build-packages.sh
   ```

3. **Build ISO**
   ```bash
   ./scripts/build-iso.sh
   ```

### Installing Components

#### GRUB Theme
```bash
cd src/boot/grub
sudo ./install.sh
```

#### Plymouth Theme
```bash
cd src/boot/plymouth
sudo ./install.sh
sudo dracut --force
```

#### Terminal Themes
```bash
# Alacritty
cp src/terminal/profiles/alacritty-pipboy.yml ~/.config/alacritty/alacritty.yml

# GNOME Terminal
cd src/terminal/profiles
./gnome-terminal-pipboy.sh
```

#### Shell Configuration
```bash
cd src/shell
./install.sh
```

#### Window Manager
```bash
cd src/wm/vaultwm
make
sudo make install
```

## Color Schemes

### Pip-Boy Theme
- **Primary**: `#00FF41` (Pip-Boy green)
- **Background**: `#000000` (Black)
- **Accent**: `#003300` (Dark green)

### Vault-Tec Theme
- **Primary**: `#FFD700` (Gold)
- **Background**: `#1E3A8A` (Vault-Tec blue)
- **Accent**: `#FFFF41` (Yellow)

## Key Bindings (VaultWM)

- `Mod4 + Enter` - Launch terminal
- `Mod4 + Q` - Close focused window
- `Mod4 + T` - Toggle tiling/floating layout
- `Mod4 + F` - Toggle floating for current window

(Mod4 is typically the Super/Windows key)

## Shell Aliases

- `pipboy` - Display system information
- `vault` - Go to home directory
- `status` - Show system status
- `inventory` - List files (ls -lah)
- `quest` - Show active quests
- `map` - Show current directory
- `stimpak` - System administration (sudo)
- `nuka` - Nuka-Cola status

## Requirements

### Build Requirements
- Fedora Linux (for building)
- Build tools: gcc, make, rpmbuild, mock
- Live CD tools: lorax, livemedia-creator
- Graphics tools: ImageMagick, GIMP (optional)

### Runtime Requirements
- X11 server
- libX11
- Terminal emulator (Alacritty, GNOME Terminal, etc.)

## Installation

### From ISO
1. Download or build the VaultOS ISO
2. Boot from ISO (Live CD or USB)
3. Install to hard drive using the installer
4. Reboot and enjoy VaultOS!

### Manual Installation
Install individual components as described in the Quick Start section.

## Documentation

- [Installation Guide](docs/installation.md)
- [Customization Guide](docs/customization.md)
- [Developer Documentation](docs/developer.md)

## Contributing

Contributions are welcome! Areas that need work:
- Icon creation
- Wallpaper design
- Additional application themes
- Window manager features
- Documentation improvements

## License

GPLv3 - See LICENSE file for details

## Credits

- Inspired by the Fallout game series
- Based on Fedora Linux
- Built with modern Linux technologies

## Status

VaultOS is in active development. Core components are implemented and continuously improved. See [CHANGELOG.md](CHANGELOG.md) for recent changes.

**Current Version**: 1.0.0 (see [VERSION](VERSION))

## Version History

See [CHANGELOG.md](CHANGELOG.md) for complete version history and release notes.

## Support

For issues, questions, or contributions, please open an issue or pull request.

---

**Welcome to VaultOS - Where the future meets the past!**

