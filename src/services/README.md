# VaultOS System Services

Systemd services for VaultOS system management.

## Available Services

### vaultos-theme-manager.service
Manages theme switching and applies theme changes system-wide.

**Features:**
- Monitors theme changes
- Applies GTK/icon themes
- Notifies applications of theme changes
- D-Bus integration

**Installation:**
```bash
cp vaultos-theme-manager.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable vaultos-theme-manager.service
systemctl --user start vaultos-theme-manager.service
```

### vaultos-wallpaper-rotation.service
Rotates desktop wallpapers on a schedule.

**Features:**
- Automatic wallpaper rotation
- Configurable rotation interval
- Sequential or random rotation
- Multiple wallpaper directory support

**Configuration:**
Create `~/.config/vaultos/wallpaper.conf`:
```bash
ROTATION_INTERVAL=3600  # seconds
ROTATION_MODE=sequential  # sequential or random
WALLPAPER_DIR="$HOME/.local/share/vaultos/wallpapers"
```

**Installation:**
```bash
cp vaultos-wallpaper-rotation.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable vaultos-wallpaper-rotation.service
systemctl --user start vaultos-wallpaper-rotation.service
```

### vaultos-status-bar-update.service
Updates VaultWM status bar with system information.

### vaultos-system-monitor.service
Monitors system health and resources.

## Service Management

Use the service manager utility:
```bash
vaultos-service-manager
```

Or use systemctl directly:
```bash
# Start service
systemctl --user start vaultos-theme-manager.service

# Stop service
systemctl --user stop vaultos-theme-manager.service

# Enable service (start on boot)
systemctl --user enable vaultos-theme-manager.service

# Check status
systemctl --user status vaultos-theme-manager.service

# View logs
journalctl --user -u vaultos-theme-manager.service -f
```

## Service Files Location

User services are installed to:
```
~/.config/systemd/user/
```

System-wide services (if needed) would be in:
```
/etc/systemd/user/
```

## Dependencies

All services require:
- systemd (user session)
- D-Bus (for some services)
- Graphical session (for theme/wallpaper services)

