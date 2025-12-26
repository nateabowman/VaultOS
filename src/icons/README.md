# VaultOS Icons and Assets

Fallout-themed icons, wallpapers, and visual assets for VaultOS.

## Icon Sets

Icons should follow Fallout aesthetic:
- Pip-Boy green color scheme
- Retro-futuristic design
- Vault-Tec branding elements
- 1950s atomic age aesthetic

## Icon Categories

### System Icons
- Applications
- System utilities
- File types
- Devices
- Status indicators

### Application Icons
- Terminal
- File manager
- Text editor
- System settings
- Media players

### Theme Icons
- Vault-Tec logo
- Pip-Boy graphics
- Fallout-themed decorations

## Wallpapers

Wallpapers should be placed in `src/assets/wallpapers/`:
- Pip-Boy interface backgrounds
- Vault door images
- Wasteland scenes (optional)
- Retro-futuristic patterns

## Asset Requirements

### Icons
- Formats: PNG, SVG
- Sizes: 16x16, 22x22, 24x24, 32x32, 48x48, 64x64, 128x128, 256x256
- Style: Flat design with Pip-Boy green accents

### Wallpapers
- Formats: PNG, JPG
- Resolution: 1920x1080, 2560x1440, 3840x2160
- Aspect ratios: 16:9, 21:9

### Graphics
- Boot splash images
- GRUB theme graphics
- Plymouth theme graphics
- Window manager decorations

## Installation

Icons will be installed to `/usr/share/icons/VaultOS/` during system installation.

For manual installation:
```bash
sudo cp -r icons/* /usr/share/icons/VaultOS/
gtk-update-icon-cache /usr/share/icons/VaultOS/
```

## Creating Icons

Tools for creating icons:
- Inkscape (SVG)
- GIMP (raster)
- ImageMagick (conversion)

Color palette:
- Primary: #00FF41 (Pip-Boy green)
- Background: #000000 (Black)
- Accent: #003300 (Dark green)
- Secondary: #FFD700 (Gold, for Vault-Tec theme)

