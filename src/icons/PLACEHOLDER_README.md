# Icon Theme Placeholders

This directory contains the structure for the VaultOS icon theme. Icons themselves need to be created by graphic designers or contributors.

## Current Status

The icon theme structure is complete with:
- Proper FreeDesktop icon theme directory structure
- `index.theme` metadata file
- All required size directories (scalable, 16x16, 22x22, 24x24, 32x32, 48x48, 64x64, 128x128, 256x256)
- All category directories (actions, apps, devices, mimetypes, places, status, categories)
- Installation script
- Package spec file for RPM distribution

## Next Steps

1. Create SVG icons in the `scalable/` directories (preferred format)
2. Generate PNG icons for fixed sizes using tools like Inkscape or ImageMagick
3. Follow the guidelines in `ICON_GUIDELINES.md`
4. Test icons at various sizes
5. Install using `install.sh` script

## Priority Icons

The following icons should be created first:

### Applications
- Terminal emulator
- File manager
- Text editor
- System settings
- VaultWM window manager

### System
- Network status icons
- Battery icons
- Volume/mute icons
- Shutdown/reboot icons

### File Types
- Directory/folder
- Text files
- Executable files

See `ICON_GUIDELINES.md` for complete requirements and design guidelines.

