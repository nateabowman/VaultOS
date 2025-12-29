# VaultOS API Documentation

Complete API documentation for VaultOS components.

## Table of Contents

- [Window Manager API](#window-manager-api)
- [Plugin API](#plugin-api)
- [Theme API](#theme-api)
- [IPC API](#ipc-api)

## Window Manager API

### Core Functions

#### `setup_wm()`
Initialize the window manager.

```c
void setup_wm(void);
```

Initializes X11 connection, creates status bar, sets up key bindings.

#### `cleanup_wm()`
Clean up window manager resources.

```c
void cleanup_wm(void);
```

Frees all resources, closes X11 connection.

#### `manage_window(Window w)`
Manage a new window.

```c
void manage_window(Window w);
```

Adds window to current workspace, sets borders, configures events.

#### `unmanage_window(Window w)`
Stop managing a window.

```c
void unmanage_window(Window w);
```

Removes window from management.

### Window Management

#### `focus_client(int index)`
Focus a client window.

```c
void focus_client(int index);
```

#### `switch_workspace(int workspace)`
Switch to a different workspace.

```c
void switch_workspace(int workspace);
```

#### `tile_windows(void)`
Arrange windows in current layout.

```c
void tile_windows(void);
```

### Application Launching

#### `launch_application(const char *cmd)`
Launch an application with security validation.

```c
void launch_application(const char *cmd);
```

**Security Features:**
- Command validation
- Path checking
- Dangerous character filtering

## Plugin API

### Plugin Structure

```c
typedef struct {
    char name[PLUGIN_NAME_MAX];
    char version[PLUGIN_VERSION_MAX];
    PluginType type;
    void *handle;
    void *data;
} Plugin;
```

### Plugin Types

- `PLUGIN_TYPE_STATUSBAR` - Status bar plugins
- `PLUGIN_TYPE_WM` - Window manager extensions
- `PLUGIN_TYPE_THEME` - Theme plugins
- `PLUGIN_TYPE_APP` - Application plugins

### Plugin Functions

#### `plugin_init(Plugin *plugin)`
Initialize plugin.

```c
int plugin_init(Plugin *plugin);
```

Returns 0 on success, non-zero on failure.

#### `plugin_cleanup(Plugin *plugin)`
Cleanup plugin resources.

```c
void plugin_cleanup(Plugin *plugin);
```

### Plugin Loading

#### `plugin_load(const char *plugin_path, const char *plugin_name)`
Load a plugin from file.

```c
int plugin_load(const char *plugin_path, const char *plugin_name);
```

#### `plugin_load_all(void)`
Load all plugins from system and user directories.

```c
int plugin_load_all(void);
```

### Example Plugin

```c
#include "plugin-loader.h"

int plugin_init(Plugin *plugin) {
    strncpy(plugin->name, "my-plugin", PLUGIN_NAME_MAX - 1);
    strncpy(plugin->version, "1.0.0", PLUGIN_VERSION_MAX - 1);
    plugin->type = PLUGIN_TYPE_STATUSBAR;
    return 0;
}

void plugin_cleanup(Plugin *plugin) {
    // Cleanup resources
}
```

## Theme API

### Theme Structure

Themes are defined in JSON format:

```json
{
  "name": "theme-name",
  "version": "1.0.0",
  "colors": {
    "primary": "#00FF41",
    "background": "#000000",
    "accent": "#003300"
  },
  "gtk": "path/to/gtk.css",
  "qt": "path/to/qt.qss"
}
```

### Theme Functions

#### `load_theme(const char *theme_path)`
Load a theme from directory.

```bash
vaultos-theme-api.sh load <theme-path>
```

#### `apply_theme(const char *theme_name)`
Apply a theme.

```bash
vaultos-theme-api.sh apply <theme-name>
```

## IPC API

### IPC Commands

Commands are sent via FIFO at `/tmp/vaultwm-ipc`.

#### Available Commands

- `quit` - Quit window manager
- `reload` - Reload configuration
- `workspace <N>` - Switch to workspace N
- `focus_next` - Focus next window
- `focus_prev` - Focus previous window
- `close_window` - Close focused window
- `toggle_float` - Toggle floating mode
- `toggle_layout` - Toggle layout mode
- `get_status` - Get window manager status

### Command Format

```
command [arguments]
```

Example:
```
workspace 3
focus_next
```

### Response Format

Responses are sent to stdout:
```
VaultWM IPC: OK: Command executed
VaultWM IPC: ERROR: Command not allowed
```

### Security

- FIFO permissions: 0600 (owner read/write only)
- Command whitelist enforced
- Input validation
- Buffer overflow protection

## Configuration API

### Configuration File Format

Configuration files use key=value format:

```
border_width=2
border_color_focused=0x00FF41
gap_size=5
terminal_cmd=alacritty
```

### Configuration Functions

#### `load_config(const char *config_path, VaultWMConfig *config)`
Load configuration from file.

```c
int load_config(const char *config_path, VaultWMConfig *config);
```

#### `get_default_config(VaultWMConfig *config)`
Get default configuration.

```c
void get_default_config(VaultWMConfig *config);
```

## Examples

### Creating a Status Bar Plugin

```c
#include "plugin-loader.h"

const char* plugin_output(Plugin *plugin) {
    return "CPU: 25% | MEM: 50%";
}

int plugin_init(Plugin *plugin) {
    plugin->type = PLUGIN_TYPE_STATUSBAR;
    return 0;
}
```

### Sending IPC Commands

```bash
# Switch workspace
echo "workspace 2" > /tmp/vaultwm-ipc

# Focus next window
echo "focus_next" > /tmp/vaultwm-ipc
```

### Loading Configuration

```c
VaultWMConfig config;
if (load_config("~/.config/vaultwm/config", &config)) {
    // Configuration loaded
} else {
    // Use defaults
    get_default_config(&config);
}
```

## See Also

- [Developer Documentation](developer.md)
- [Plugin Development Guide](../sdk/plugins/README.md)
- [Theme Development Guide](../sdk/examples/README.md)

