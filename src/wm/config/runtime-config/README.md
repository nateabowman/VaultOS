# VaultWM Runtime Configuration

VaultWM supports runtime configuration via a configuration file, eliminating the need to recompile for most changes.

## Configuration File Location

Place your configuration file at:
```
~/.config/vaultwm/config
```

## Example Configuration

See `config.example` for a complete example configuration file.

## Configuration Options

### Color Scheme
- `color_scheme`: Color scheme name (pipboy, vaulttec)

### Window Borders
- `border_width`: Width of window borders in pixels
- `border_color_focused`: Border color for focused window (hex)
- `border_color_unfocused`: Border color for unfocused windows (hex)
- `border_color_urgent`: Border color for urgent windows (hex)

### Window Gaps
- `gap_size`: Gap between windows in pixels

### Status Bar
- `status_bar_height`: Height of status bar in pixels
- `status_bar_update_interval`: Update interval in seconds

### Key Bindings
- `terminal_key`: Key to launch terminal (e.g., Return)
- `launcher_key`: Key to launch application launcher
- `close_key`: Key to close window
- `toggle_layout_key`: Key to toggle layout mode
- `toggle_float_key`: Key to toggle floating
- `resize_key`: Key to enter resize mode
- `move_key`: Key to enter move mode

### Applications
- `terminal_cmd`: Terminal command
- `terminal_fallback`: Fallback terminal command
- `launcher_cmd`: Application launcher command
- `launcher_fallback`: Fallback launcher command

### Layouts
- `default_layout`: Default layout mode (tiling, floating, monocle, grid, fibonacci)

### Workspaces
- `workspace_1` through `workspace_9`: Optional workspace names

## IPC (Inter-Process Communication)

VaultWM provides IPC via a named pipe (FIFO) at `/tmp/vaultwm-ipc`.

### Sending Commands

```bash
# Send command to window manager
echo "workspace 2" > /tmp/vaultwm-ipc
echo "toggle_layout" > /tmp/vaultwm-ipc
echo "focus_next" > /tmp/vaultwm-ipc
```

### Available Commands

- `quit` - Quit window manager
- `reload` - Reload configuration
- `workspace N` - Switch to workspace N (1-9)
- `move_to_workspace N` - Move focused window to workspace N
- `focus_next` - Focus next window
- `focus_prev` - Focus previous window
- `close_window` - Close focused window
- `toggle_float` - Toggle floating for focused window
- `toggle_layout` - Toggle layout mode
- `get_status` - Get current status

### Example Scripts

```bash
#!/bin/bash
# Switch to workspace 2
echo "workspace 2" > /tmp/vaultwm-ipc

#!/bin/bash
# Move current window to workspace 3
echo "move_to_workspace 3" > /tmp/vaultwm-ipc
```

## Reloading Configuration

To reload configuration:
1. Edit `~/.config/vaultwm/config`
2. Send `reload` command via IPC: `echo "reload" > /tmp/vaultwm-ipc`

Or restart the window manager.

