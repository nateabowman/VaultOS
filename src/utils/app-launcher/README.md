# VaultOS Application Launcher Utilities

Utilities for application launching, indexing, and tracking.

## Utilities

### app-indexer.sh
Index and search applications from .desktop files.

Usage:
```bash
# Index applications
vaultos-app-indexer index

# Search applications
vaultos-app-indexer search <query>

# List all applications
vaultos-app-indexer list

# Get application information
vaultos-app-indexer info <app_name>
```

Features:
- Indexes applications from standard desktop directories
- Fast search by name
- Application information retrieval
- Categories support

### recent-apps.sh
Track recently used applications.

Usage:
```bash
# Add application to recent list
vaultos-recent-apps add <app_name>

# List recent applications
vaultos-recent-apps list

# Clear recent applications
vaultos-recent-apps clear
```

Integration:
- Can be called from application launchers (dmenu, rofi)
- Tracks up to 20 recent applications
- Stores data in `~/.local/share/vaultos/recent-apps`

## Integration with Launchers

### dmenu
```bash
# Show recent apps first
(recent-apps list; app-indexer list) | dmenu
```

### rofi
```bash
# Use rofi with recent apps
rofi -show drun -drun-show-actions
```

## Desktop Entry Directories

Applications are indexed from:
- `/usr/share/applications/` - System-wide applications
- `~/.local/share/applications/` - User applications

## See Also

- [Application Launcher Integration](../../../README.md)
- [Desktop Entry Management](https://specifications.freedesktop.org/desktop-entry-spec/)

