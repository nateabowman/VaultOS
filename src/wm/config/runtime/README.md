# VaultWM Runtime Configuration

Runtime configuration system for VaultWM allowing customization without recompilation.

## Configuration File

Location: `~/.config/vaultwm/config`

Copy the example configuration file:
```bash
mkdir -p ~/.config/vaultwm
cp /usr/share/vaultwm/config.example ~/.config/vaultwm/config
```

Then edit `~/.config/vaultwm/config` to customize your settings.

## Configuration Options

### Terminal Settings
- `terminal` - Primary terminal command (default: "alacritty")
- `terminal_fallback` - Fallback terminal (default: "xterm")

### Application Launcher
- `launcher` - Application launcher command (default: "dmenu_run")
- `launcher_fallback` - Fallback launcher (default: "rofi -show drun")

### Status Bar
- `status_update_interval` - Update interval in seconds (default: 1)
- `status_bar_height` - Status bar height in pixels (default: 30)
- `status_bar_enabled` - Enable/disable status bar (default: true)

### Window Appearance
- `window_gap` - Gap between windows in pixels (default: 5)
- `border_width` - Window border width in pixels (default: 2)

### Colors
- `color_focused` - Focused window border color (hex, default: "#00FF41")
- `color_unfocused` - Unfocused window border color (hex, default: "#003300")
- `color_urgent` - Urgent window border color (hex, default: "#FF0000")
- `color_background` - Background color (hex, default: "#000000")

### Layout
- `default_layout` - Default layout mode: "tiling", "floating", or "monocle" (default: "tiling")
- `layout_gap` - Layout gap in pixels (default: 5)

## IPC (Inter-Process Communication)

VaultWM supports IPC via a named pipe (FIFO) for external script control.

### IPC FIFO Location
`~/.config/vaultwm/vaultwm_ipc`

### Sending Commands

Commands can be sent to VaultWM by writing to the FIFO:
```bash
echo "focus_next" > ~/.config/vaultwm/vaultwm_ipc
```

### Available Commands
- `focus_next` - Focus next window
- `focus_prev` - Focus previous window
- `switch_workspace N` - Switch to workspace N (1-9)
- `close_window` - Close focused window
- `toggle_layout` - Toggle layout mode
- `toggle_float` - Toggle floating for focused window

### Example Script

```bash
#!/bin/bash
# Switch to workspace 3
echo "switch_workspace 3" > ~/.config/vaultwm/vaultwm_ipc
```

## Reloading Configuration

To apply configuration changes:
1. Restart VaultWM, or
2. Send reload command via IPC (if implemented)

## See Also

- [VaultWM README](../README.md)
- [Configuration Header](../config.h)

