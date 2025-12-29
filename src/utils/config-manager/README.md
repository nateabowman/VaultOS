# VaultOS Configuration Manager

Configuration management system for VaultOS settings.

## Configuration Format

VaultOS uses JSON format for configuration files. Configuration is stored in:
```
~/.config/vaultos/config.json
```

## Configuration Schema

See `config-schema.json` for the complete configuration schema.

### Window Manager Settings
- `border_width`: Window border width (0-10)
- `gap_size`: Gap between windows (0-50)
- `default_layout`: Default layout mode
- Border colors (focused, unfocused, urgent)

### Theme Settings
- `name`: Theme name (pipboy, vaulttec)
- `gtk_theme`: GTK theme name
- `icon_theme`: Icon theme name

### Workspaces
Array of workspace configurations with number and name.

### Key Bindings
Key bindings for window manager actions.

### Applications
Terminal and launcher application commands.

## Tools

### vaultos-config-tui.sh
Text-based configuration interface using dialog/whiptail.

**Usage:**
```bash
vaultos-config-tui
```

**Features:**
- Window manager configuration
- Theme selection
- Workspace management
- Key binding configuration

## Configuration Import/Export

### Export Configuration
```bash
cp ~/.config/vaultos/config.json ~/vaultos-config-backup.json
```

### Import Configuration
```bash
cp ~/vaultos-config-backup.json ~/.config/vaultos/config.json
```

## Configuration Validation

Configuration files are validated against the schema. Invalid configurations will use default values.

## Default Configuration

If no configuration file exists, default values are used. See `config-example.json` for default configuration.
