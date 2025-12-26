# VaultOS Custom Fonts

Retro-futuristic fonts for VaultOS Fallout-themed distribution.

## Recommended Fonts

### Monospace Fonts (for terminal)
- **Unifont** - Unicode monospace font, good for terminal
- **Terminus** - Bitmap font with retro aesthetic
- **IBM Plex Mono** - Modern monospace with retro feel
- **JetBrains Mono** - Modern monospace

### Display Fonts (for UI)
- **Orbitron** - Futuristic sans-serif
- **Rajdhani** - Modern sans-serif with retro feel
- **Exo 2** - Futuristic geometric font

## Font Installation

Fonts should be placed in this directory and will be packaged for system installation.

### Manual Installation

1. Copy font files to `~/.local/share/fonts/` or `/usr/share/fonts/`
2. Update font cache:
   ```bash
   fc-cache -fv
   ```

### System-wide Installation

Fonts will be installed to `/usr/share/fonts/vaultos/` during system installation.

## Font Configuration

Font rendering is configured in:
- `src/themes/gtk/` - GTK font settings
- `src/themes/qt/` - Qt font settings
- Terminal profiles - Terminal font settings

## Creating Custom Fonts

To create custom retro-futuristic fonts:
1. Use FontForge or similar tool
2. Base on existing fonts with retro aesthetic
3. Ensure good readability
4. Test with Pip-Boy green color scheme

