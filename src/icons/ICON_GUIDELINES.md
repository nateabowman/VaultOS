# VaultOS Icon Theme Creation Guidelines

## Color Palette

### Pip-Boy Theme (Primary)
- **Primary Green**: `#00FF41` - Main icon color
- **Background**: `#000000` - Black backgrounds
- **Dark Green**: `#003300` - Shadows and accents
- **Light Green**: `#66FF99` - Highlights

### Vault-Tec Theme (Secondary)
- **Gold**: `#FFD700` - Primary accent
- **Blue**: `#1E3A8A` - Vault-Tec blue
- **Yellow**: `#FFFF41` - Highlights
- **Dark Blue**: `#0F1F4A` - Shadows

## Design Principles

1. **Retro-Futuristic**: 1950s atomic age aesthetic with futuristic elements
2. **High Contrast**: Icons should be clearly visible at all sizes
3. **Minimalist**: Clean, simple designs that scale well
4. **Consistent Style**: All icons should share common design language
5. **Fallout Aesthetic**: Pip-Boy green or Vault-Tec blue/gold throughout

## Icon Sizes

Icons must be provided in the following sizes:
- **Scalable (SVG)**: Preferred format, in `scalable/` directories
- **Fixed (PNG)**: Fallback formats in size-specific directories
  - 16x16 - Small UI elements, status indicators
  - 22x22 - Small UI elements, toolbars
  - 24x24 - Standard UI elements
  - 32x32 - Standard icons
  - 48x48 - Application icons, large UI elements
  - 64x64 - Large application icons
  - 128x128 - Very large icons
  - 256x256 - Maximum size, rarely used

## Icon Categories

### Actions (`actions/`)
Action buttons and menu items:
- `document-open.svg` - Open file
- `edit-clear.svg` - Clear/edit
- `go-next.svg` - Forward navigation
- `system-shutdown.svg` - Shutdown
- `view-refresh.svg` - Refresh

### Applications (`apps/`)
Application launcher icons:
- `terminal.svg` - Terminal emulator
- `file-manager.svg` - File manager
- `text-editor.svg` - Text editor
- `system-settings.svg` - Settings
- `vaultwm.svg` - VaultWM window manager

### Devices (`devices/`)
Hardware device icons:
- `drive-harddisk.svg` - Hard disk
- `drive-removable-media.svg` - USB/removable
- `computer.svg` - Computer
- `network-wired.svg` - Network

### MIME Types (`mimetypes/`)
File type icons:
- `text-plain.svg` - Text file
- `text-x-script.svg` - Script file
- `application-x-executable.svg` - Executable
- `inode-directory.svg` - Directory/folder

### Places (`places/`)
Location icons:
- `folder.svg` - Folder
- `user-home.svg` - Home directory
- `folder-download.svg` - Downloads
- `network-server.svg` - Network/server

### Status (`status/`)
Status indicator icons:
- `network-wireless-connected.svg` - WiFi connected
- `battery-full.svg` - Battery status
- `audio-volume-high.svg` - Volume
- `dialog-information.svg` - Information

### Categories (`categories/`)
Application category icons:
- `applications-system.svg` - System
- `applications-development.svg` - Development
- `applications-multimedia.svg` - Multimedia
- `applications-utilities.svg` - Utilities

## SVG Template

```svg
<?xml version="1.0" encoding="UTF-8"?>
<svg width="48" height="48" version="1.1" xmlns="http://www.w3.org/2000/svg">
  <!-- Background (optional) -->
  <rect width="48" height="48" fill="#000000" rx="4"/>
  
  <!-- Icon content -->
  <path d="..." fill="#00FF41" stroke="#003300" stroke-width="1"/>
  
  <!-- Highlights -->
  <path d="..." fill="#66FF99" opacity="0.3"/>
</svg>
```

## PNG Guidelines

When creating PNG icons:
- Use transparency for backgrounds
- Anti-aliasing enabled
- No aliasing artifacts
- Consistent border/padding (2px padding recommended)
- High-quality rendering at target size

## Naming Conventions

Icons should follow FreeDesktop naming conventions:
- Use lowercase letters
- Use hyphens to separate words
- Be descriptive: `network-wireless-connected.svg` not `wifi.svg`
- Match standard icon names when possible for compatibility

## Required Icons

### Essential System Icons
- Terminal emulator icon
- File manager icon
- Settings/Preferences icon
- Window manager icon (vaultwm)
- System shutdown/reboot icons

### File Type Icons
- Directory/folder
- Text files
- Executable files
- Archive files
- Image files
- Media files

### Status Icons
- Network status (connected/disconnected)
- Battery status
- Volume/mute
- Notification icons

## Tools

Recommended tools for creating icons:
- **Inkscape** - SVG creation and editing (preferred)
- **GIMP** - Raster icon editing
- **ImageMagick** - Icon conversion and batch processing
- **Icon Generator Tools** - For creating multiple sizes from SVG

## Testing

After creating icons:
1. Install the icon theme
2. Test at various sizes
3. Verify visibility at small sizes (16x16, 22x22)
4. Check consistency across categories
5. Test in different applications

## Contributing

When adding new icons:
1. Follow the naming conventions
2. Use the color palette
3. Provide both SVG and PNG versions when possible
4. Test the icons before submitting
5. Update this documentation if adding new categories

