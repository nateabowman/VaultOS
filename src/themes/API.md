# VaultOS Theming API

Programmatic API for theme generation and management.

## Theme Structure

```
theme-name/
├── theme.json         # Theme metadata
├── colors.json        # Color definitions
├── gtk3.css          # GTK3 stylesheet
├── gtk4.css          # GTK4 stylesheet
└── qt.qss            # Qt stylesheet
```

## Theme Metadata (theme.json)

```json
{
  "name": "theme-name",
  "display_name": "Theme Display Name",
  "version": "1.0.0",
  "author": "Author Name",
  "description": "Theme description",
  "base_theme": "pipboy",
  "colors": {
    "primary": "#00FF41",
    "background": "#000000",
    "accent": "#003300"
  }
}
```

## Color Definitions (colors.json)

```json
{
  "primary": "#00FF41",
  "secondary": "#003300",
  "background": "#000000",
  "foreground": "#00FF41",
  "accent": "#66FF99"
}
```

## Theme Generation

Themes can be generated programmatically:

1. Define color scheme
2. Generate CSS from template
3. Apply theme
4. Export theme package

## Theme Inheritance

Themes can inherit from base themes (pipboy, vaulttec) and override specific values.

## Theme Scripting

Themes can include scripts for:
- Dynamic color generation
- Conditional styling
- Animation definitions

## API Functions

### Load Theme
```bash
vaultos-theme-api load <theme-name>
```

### Apply Theme
```bash
vaultos-theme-api apply <theme-name>
```

### Generate Theme
```bash
vaultos-theme-api generate --colors colors.json --output theme-name
```

### Export Theme
```bash
vaultos-theme-api export <theme-name> --output theme.tar.gz
```

