# VaultOS Utilities

System utilities and helper scripts for VaultOS with Pip-Boy aesthetic.

## Utilities

### pipboy-viewer.sh
Interactive system status viewer styled like Pip-Boy interface.
- Real-time system information display
- CPU, memory, disk, and network status
- Pip-Boy green color scheme
- Updates every 2 seconds

Usage:
```bash
pipboy-viewer
# Or
~/.local/bin/pipboy-viewer
```

### Theme Switcher
Theme switching utility (located in `src/shell/scripts/theme-switcher.sh`)
- Switch between Pip-Boy and Vault-Tec themes
- Interactive menu
- Applies theme changes system-wide

Usage:
```bash
vaultos-theme-switcher
# Or
~/.local/bin/vaultos-theme-switcher
```

## Installation

Utilities will be installed to `/usr/local/bin/` or `~/.local/bin/` during system installation.

For manual installation:
```bash
cd src/utils
sudo install -m 755 pipboy-viewer.sh /usr/local/bin/pipboy-viewer
sudo install -m 755 ../shell/scripts/theme-switcher.sh /usr/local/bin/vaultos-theme-switcher
```

## Integration

These utilities integrate with:
- Shell aliases (see `src/shell/`)
- System PATH
- VaultWM status bar
- Desktop environment menus

