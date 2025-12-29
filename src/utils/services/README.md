# VaultOS System Services

Systemd user services for VaultOS functionality.

## Services

### Theme Management Daemon
**Service**: `vaultos-theme-daemon.service`
**Script**: `vaultos-theme-daemon.sh`

Manages theme changes and applies theme settings dynamically.

**Usage**:
```bash
systemctl --user start vaultos-theme-daemon.service
systemctl --user enable vaultos-theme-daemon.service
```

**Configuration**: `~/.config/vaultos/theme.conf`

### Wallpaper Rotation Service
**Service**: `vaultos-wallpaper-rotation.service`
**Script**: `vaultos-wallpaper-rotation.sh`

Rotates wallpapers on a schedule.

**Usage**:
```bash
systemctl --user start vaultos-wallpaper-rotation.service
systemctl --user enable vaultos-wallpaper-rotation.service
```

**Configuration**: `~/.config/vaultos/wallpaper-rotation.conf`

**Options**:
- `INTERVAL` - Rotation interval in seconds (default: 3600)
- `ENABLED` - Enable/disable rotation (0 or 1, default: 0)

### Status Bar Update Service
**Service**: `vaultos-status-bar.service`

Updates VaultWM status bar with system information.

### System Monitoring Service
**Service**: `vaultos-system-monitor.service`

Monitors system health and performance.

## Service Manager

Use `vaultos-service-manager.sh` to manage services:

```bash
# List services
vaultos-service-manager.sh list

# Check status
vaultos-service-manager.sh status theme-daemon

# Start service
vaultos-service-manager.sh start theme-daemon

# Stop service
vaultos-service-manager.sh stop theme-daemon

# Enable service (start on login)
vaultos-service-manager.sh enable theme-daemon

# Disable service
vaultos-service-manager.sh disable theme-daemon
```

## Installation

Services are installed to `/usr/lib/systemd/user/` during package installation.

User can also copy services to `~/.config/systemd/user/` for local customization.

## Configuration

Each service may have its own configuration file in `~/.config/vaultos/`.

