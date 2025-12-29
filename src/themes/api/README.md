# VaultOS Theming API

Programmatic theme generation and management API.

## Functions

### apply_theme(theme_name)
Apply a theme by name.

### generate_theme(theme_name, primary_color, bg_color)
Generate a new theme with specified colors.

### list_themes()
List available themes.

## Usage

```bash
source src/themes/api/theme-api.sh

# List themes
list_themes

# Generate theme
generate_theme "my-theme" "#00FF41" "#000000"

# Apply theme
apply_theme "my-theme"
```

## Theme Structure

Themes are stored in:
- `~/.local/share/vaultos/themes/<theme-name>/`

Each theme contains:
- `gtk.css` - GTK stylesheet
- `colors.conf` - Color configuration

## See Also

- [Theme Editor](../../utils/customization/theme-editor.sh)
- [Theme Guidelines](../README.md)

