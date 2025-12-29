# VaultOS Plugin System

Plugin architecture for extending VaultOS functionality.

## Plugin Types

### Status Bar Plugins
Plugins that add modules to the VaultWM status bar.

### Window Manager Plugins
Plugins that extend window manager functionality.

### Theme Plugins
Plugins for custom theme variations.

## Plugin Structure

```
plugin-name/
├── plugin.json          # Plugin metadata
├── plugin.sh            # Plugin script (for status bar plugins)
└── README.md            # Plugin documentation
```

## Plugin Metadata (plugin.json)

```json
{
  "name": "plugin-name",
  "version": "1.0.0",
  "description": "Plugin description",
  "type": "statusbar",
  "author": "Author Name",
  "dependencies": []
}
```

## Creating a Status Bar Plugin

1. Create plugin directory: `~/.local/share/vaultos/plugins/my-plugin/`
2. Create `plugin.json` with metadata
3. Create `plugin.sh` that outputs status information
4. Enable plugin: `vaultos-plugin-manager enable my-plugin`

Example plugin.sh:
```bash
#!/bin/bash
# Output plugin status
echo "Plugin Status: Active"
```

## Plugin API

Status bar plugins output text that is displayed in the status bar.

Window manager plugins interact via IPC commands.

Theme plugins provide CSS/stylesheet modifications.

## Plugin Manager

Use `vaultos-plugin-manager` to manage plugins:
- List plugins
- Enable/disable plugins
- Install/remove plugins
- Update plugins

