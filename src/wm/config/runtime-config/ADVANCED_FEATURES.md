# VaultWM Advanced Features Documentation

## Multi-Monitor Support

### Per-Monitor Workspaces
Each monitor can have independent workspaces, allowing for better multi-monitor workflows.

### Window Placement
Windows can be placed on specific monitors using IPC commands or key bindings.

## Advanced Layout Algorithms

### Grid Layout
Grid layout divides screen into equal-sized cells, arranging windows in a grid pattern.

### Fibonacci Layout
Fibonacci spiral layout creates an aesthetically pleasing arrangement with one large window and smaller windows arranged in a spiral.

### Dwindle Layout
Similar to Fibonacci but uses a binary tree structure for window arrangement.

## Window Tagging System

Windows can be tagged with labels for better organization:
- Tag windows for specific tasks
- Filter windows by tags
- Quick tag-based window switching

## Window Rules

Define rules for automatic window behavior:
- Auto-floating for specific applications
- Workspace assignment
- Size and position rules
- Layout preferences

Example rules:
```
firefox:Navigator:floating
terminal:Alacritty:workspace=1
code:Code:tiling
```

## Window Swallowing

Terminal programs can "swallow" parent terminal windows, creating a seamless terminal experience.

## Layer Management

Windows can be organized into layers:
- Normal layer
- Below layer (always behind)
- Above layer (always on top)
- Fullscreen layer

## Border States

Window borders change based on state:
- **Normal**: Default border color
- **Focused**: Bright border (Pip-Boy green)
- **Urgent**: Red border (attention needed)
- **Unfocused**: Dimmed border

## Screenshot Integration

Built-in screenshot functionality:
- Full screen capture
- Window capture
- Selected area capture
- Screenshot with delay

## Status Bar Modules

Modular status bar supports custom modules:
- System information (CPU, memory, network)
- Battery status
- Volume control
- Brightness control
- Workspace indicators with window counts
- Custom script modules

### Creating Custom Status Bar Modules

Status bar modules are scripts that output text:

```bash
#!/bin/bash
# Custom status bar module
echo "Custom Info: $(date)"
```

Place in `~/.config/vaultwm/status-modules/` and they will be loaded automatically.

## Configuration Priority

Configuration is loaded in this order:
1. Runtime config file (`~/.config/vaultwm/config`)
2. Compile-time defaults (`config.h`)

Runtime configuration overrides compile-time defaults.

