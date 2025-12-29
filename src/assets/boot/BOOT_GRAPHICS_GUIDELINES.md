# VaultOS Boot Graphics Guidelines

## Directory Structure

- `grub/` - GRUB bootloader graphics
- `plymouth/` - Plymouth boot splash graphics

## GRUB Graphics

### Required Files

Located in `boot/grub/`:
- `background.png` - Main background image (1920x1080 recommended)
- `terminal_box_*.png` - Terminal box graphics (optional, for themed terminal boxes)
- `select_*.png` - Selection highlight graphics (optional, for menu selection)

### Background Image (`background.png`)

**Specifications:**
- Resolution: 1920x1080 (standard) or match boot resolution
- Format: PNG (preferred) or JPG
- Aspect ratio: 16:9
- Colors: Pip-Boy green (#00FF41) on black (#000000)
- Style: Minimalist, not distracting
- Should work with green text overlay

**Design Ideas:**
- Simple Pip-Boy interface background
- Vault door silhouette
- Minimal grid pattern
- Retro-futuristic pattern

### Terminal Box Graphics

If using styled terminal boxes:
- `terminal_box_*.png` - 9-patch style boxes for terminal borders
- Should use Pip-Boy green borders
- Transparent centers
- Support for scaling

### Selection Graphics

If using image-based selection highlights:
- `select_*.png` - Highlight graphics for selected menu items
- Should use dark green (#003300) or lighter Pip-Boy green
- Support for different sizes

### Color Requirements

GRUB theme uses:
- Background: Black (#000000)
- Text: Pip-Boy green (#00FF41)
- Selection: Dark green (#003300) or white (#FFFFFF)
- Ensure sufficient contrast for readability

## Plymouth Graphics

### Required Files

Located in `boot/plymouth/`:
- `vault-door.png` - Vault door image (for animation)
- `pipboy.png` - Pip-Boy image (for animation)
- `progress-bar.png` - Progress bar graphic (optional)
- Animation frame sequences (if using frame-based animation)

### Vault Door Image

**Specifications:**
- Resolution: Match screen resolution (typically 1920x1080)
- Format: PNG with transparency
- Style: Vault door design (inspired, not copyrighted)
- Colors: Vault-Tec blue/gold or Pip-Boy green
- Should work as centerpiece for boot animation

### Pip-Boy Image

**Specifications:**
- Resolution: Match screen resolution
- Format: PNG with transparency
- Style: Pip-Boy 3000 interface aesthetic
- Colors: Pip-Boy green (#00FF41) on black
- Can be used in boot animation sequence

### Progress Bar Graphic

**Specifications:**
- Format: PNG with transparency
- Colors: Pip-Boy green (#00FF41) fill, dark green (#003300) background
- Style: Rectangular bar or themed design
- Should be scalable

### Animation Frames

If creating frame-based animations:
- Number frames sequentially: `frame-001.png`, `frame-002.png`, etc.
- Maintain consistent resolution across all frames
- Use PNG format with transparency
- Typical frame count: 10-30 frames for smooth animation
- Frame rate: 15-30 FPS

### Animation Ideas

1. **Vault Door Opening**
   - Sequence of vault door opening frames
   - Progress bar below
   - Text: "Initializing VaultOS..."

2. **Pip-Boy Boot Sequence**
   - Pip-Boy screen turning on
   - System information appearing
   - Loading progress

3. **Simple Fade/Pulse**
   - Logo/pipboy pulsing or fading
   - Progress bar filling
   - Minimal animation

## Color Palette

### Pip-Boy Theme
- Primary: `#00FF41` (Pip-Boy green)
- Background: `#000000` (Black)
- Accent: `#003300` (Dark green)
- Text: `#00FF41` or `#FFFFFF` (White)

### Vault-Tec Theme
- Primary: `#FFD700` (Gold)
- Background: `#1E3A8A` (Vault-Tec blue) or `#000000` (Black)
- Accent: `#FFFF41` (Yellow)
- Text: `#FFD700` or `#FFFFFF`

## Technical Requirements

### File Formats
- **PNG**: Preferred (supports transparency)
- **JPG**: Acceptable for backgrounds (no transparency)
- **BMP**: Not recommended

### Resolution
- Match target screen resolution
- GRUB: Typically 1920x1080 or native resolution
- Plymouth: Screen resolution or scalable

### File Size
- Keep boot graphics small for fast loading
- Optimize PNG files
- GRUB background: < 2MB
- Plymouth images: < 1MB each
- Total boot theme: < 10MB

### Performance
- Boot graphics load during system startup
- Larger files = slower boot
- Optimize for size without sacrificing quality
- Use indexed colors when possible

## Design Principles

1. **Fast Loading**: Small file sizes for quick boot
2. **Simple**: Not too complex (faster rendering)
3. **Readable**: Text must be clear over graphics
4. **Consistent**: Match VaultOS aesthetic
5. **Scalable**: Work at different resolutions

## Integration

### GRUB Integration
Graphics are referenced in `src/boot/grub/theme.txt`:
```
desktop-image: "background.png"
selected_item_pixmap_style = "select_*.png"
```

### Plymouth Integration
Graphics are referenced in `src/boot/plymouth/vaultos.script`:
- Images loaded via `image.Load()` function
- Animation sequences defined in script
- Progress bar rendering

## Tools

- **GIMP** - Image editing and optimization
- **Inkscape** - Vector graphics (convert to PNG)
- **ImageMagick** - Batch processing and optimization
- **Plymouth Theme Generator** - For testing Plymouth themes

## Testing

1. Test GRUB theme at boot (VM recommended)
2. Test Plymouth theme during boot sequence
3. Verify on different screen resolutions
4. Check file sizes are reasonable
5. Ensure fast loading times
6. Validate colors render correctly

## Contributing

When adding boot graphics:
1. Follow file naming conventions
2. Optimize for file size
3. Test in actual boot environment
4. Document any special requirements
5. Include source files if applicable

