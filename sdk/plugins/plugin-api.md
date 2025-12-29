# VaultOS Plugin API

API documentation for developing VaultOS plugins.

## Plugin Structure

Plugins must provide:

1. **Metadata File** (`plugin.json`):
   ```json
   {
     "name": "plugin-name",
     "version": "1.0.0",
     "description": "Plugin description",
     "type": "statusbar|wm|theme|app",
     "author": "Author Name",
     "entry_point": "plugin.sh"
   }
   ```

2. **Entry Point**: Executable script or binary
3. **Configuration**: Optional configuration file

## Plugin Types

### Status Bar Plugin
Adds modules to VaultWM status bar.

Interface:
- `plugin_output()` - Returns status bar text
- `plugin_update()` - Called on update interval
- `plugin_click()` - Handle click events (optional)

### Window Manager Plugin
Extends VaultWM functionality.

Interface:
- `plugin_init()` - Initialize plugin
- `plugin_cleanup()` - Cleanup on exit
- Plugin-specific functions

### Theme Plugin
Extends theming system.

Interface:
- `plugin_apply()` - Apply theme modifications
- `plugin_colors()` - Provide color scheme

## Plugin Configuration

Plugins can have configuration files:
- `~/.config/vaultos/plugins/<plugin-name>.conf`

## Plugin Loading

Plugins are loaded from:
- `/usr/share/vaultos/plugins/` - System plugins
- `~/.local/share/vaultos/plugins/` - User plugins

## Example Plugin

See `examples/` directory for example plugins.

## See Also

- [Plugin Development Guide](../plugins/README.md)
- [Developer Documentation](../../docs/developer.md)

