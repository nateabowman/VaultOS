# VaultOS Plugin System

Plugin and extension system for VaultOS.

## Plugin Types

- **Window Manager Plugins**: Extend VaultWM functionality
- **Status Bar Plugins**: Add modules to status bar
- **Theme Plugins**: Extend theming capabilities
- **Application Plugins**: Application integrations

## Plugin Architecture

Plugins are stored in:
- `/usr/share/vaultos/plugins/` - System plugins
- `~/.local/share/vaultos/plugins/` - User plugins

## Plugin Format

Plugins are executable scripts or binaries that:
1. Follow plugin API interface
2. Provide metadata (name, version, description)
3. Implement required functions
4. Handle configuration

## Plugin Development

See `sdk/plugins/` for:
- Plugin API documentation
- Example plugins
- Development templates
- Testing tools

## Plugin Management

Use plugin manager tool:
```bash
vaultos-plugin-manager
```

## Available Plugins

(Plugins will be listed here as they become available)

