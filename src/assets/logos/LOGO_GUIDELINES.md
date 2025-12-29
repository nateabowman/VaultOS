# VaultOS Logo Creation Guidelines

## Purpose

Logos and branding elements for VaultOS, inspired by Fallout aesthetic but original designs.

## Logo Types

### Primary Logo
- **VaultOS Logo**: Main distribution logo
- Should be recognizable and professional
- Works at various sizes (favicon to large displays)
- Available in multiple formats and color variants

### Vault-Tec Inspired Logo
- Inspired by Vault-Tec branding (original design, not copyrighted)
- Can use similar aesthetic (geometric, industrial)
- Blue and gold color scheme
- Circular or geometric designs

### Pip-Boy Graphics
- Pip-Boy-inspired interface elements
- Can be used as decorative elements
- Green monochrome style
- Retro-futuristic aesthetic

### Branding Elements
- Icon variations
- Monochrome versions
- Color variants (Pip-Boy green, Vault-Tec blue/gold)
- Horizontal and vertical layouts

## Color Variants

### Pip-Boy Green Variant
- Primary: `#00FF41` (Pip-Boy green)
- Background: `#000000` (Black) or transparent
- Accent: `#003300` (Dark green)

### Vault-Tec Blue/Gold Variant
- Primary: `#FFD700` (Gold)
- Background: `#1E3A8A` (Vault-Tec blue) or `#000000`
- Accent: `#FFFF41` (Yellow)

### Monochrome Variant
- White on transparent/black
- Black on transparent/white
- For use on various backgrounds

## Size Requirements

Logos should be provided in multiple sizes:

### Standard Sizes
- **16x16** - Favicon, small icons
- **32x32** - Small application icons
- **48x48** - Medium icons
- **64x64** - Large icons
- **128x128** - Very large icons
- **256x256** - Maximum detail
- **512x512** - High-resolution (if needed)
- **1024x1024** - Print/vector source

### Scalable Format
- **SVG** - Vector format (preferred for source)
- Can scale to any size
- Edit and modify easily

## File Formats

### Source Files
- **SVG** - Vector format (preferred)
- **PDF** - Vector format (alternative)
- **AI/XCF** - Native editor formats (keep as source)

### Raster Formats
- **PNG** - With transparency (preferred for web/UI)
- **JPG** - For photos/backgrounds (no transparency)
- **ICO** - Windows icon format (if needed)

## Design Principles

1. **Simple**: Works at small sizes (favicon)
2. **Recognizable**: Distinctive and memorable
3. **Versatile**: Works in various contexts
4. **Consistent**: Matches VaultOS aesthetic
5. **Scalable**: Looks good at all sizes
6. **Original**: Original designs (inspired, not copied)

## Logo Concepts

### VaultOS Main Logo Ideas
- Vault door with "VaultOS" text
- Geometric V-shaped logo
- Terminal/computer aesthetic
- Retro-futuristic design
- Linux penguin + Fallout aesthetic (if appropriate)

### Vault-Tec Inspired
- Circular vault door design
- Gear/cog elements
- Industrial/mechanical feel
- Blue and gold color scheme
- Geometric patterns

### Pip-Boy Graphics
- Pip-Boy interface elements
- Terminal-style graphics
- Green monochrome aesthetic
- Retro computer aesthetic

## Usage Guidelines

### Logo Placement
- Should have clear space around it
- Minimum padding: 1x logo height/width
- Don't stretch or distort
- Maintain aspect ratio

### Backgrounds
- Provide versions for light and dark backgrounds
- Transparent versions for flexibility
- Solid color versions for specific uses

### Restrictions
- Don't modify colors arbitrarily
- Don't add effects (drop shadows, bevels) without consideration
- Maintain aspect ratio
- Use high-quality versions

## File Organization

```
logos/
├── vaultos/
│   ├── svg/           # Vector source files
│   ├── png/           # Raster versions
│   │   ├── 16x16/
│   │   ├── 32x32/
│   │   ├── 48x48/
│   │   ├── 64x64/
│   │   ├── 128x128/
│   │   ├── 256x256/
│   │   └── 512x512/
│   └── variants/      # Color variants
├── vaulttec/
│   └── (similar structure)
└── pipboy/
    └── (graphics and elements)
```

## Naming Convention

- `vaultos-logo-{variant}-{size}.{ext}`
- Example: `vaultos-logo-green-256x256.png`
- Example: `vaultos-logo-monochrome-128x128.png`
- Example: `vaultos-logo-horizontal.svg`

## Tools

- **Inkscape** - Vector graphics (SVG)
- **GIMP** - Raster graphics editing
- **ImageMagick** - Batch conversion and resizing
- **FontForge** - If creating custom typography

## Testing

1. Test at all target sizes
2. Verify on light and dark backgrounds
3. Check in various contexts (boot screen, desktop, web)
4. Ensure readability at small sizes
5. Validate file sizes are reasonable
6. Test transparency renders correctly

## Legal Considerations

- All logos must be original designs
- Inspired by Fallout aesthetic but not copying copyrighted material
- Cannot use Bethesda/ZeniMax copyrighted logos directly
- Create original interpretations of similar themes
- Document sources of inspiration

## Contributing

When creating logos:
1. Provide SVG source files
2. Export to all required sizes
3. Include color variants
4. Document design decisions
5. Include usage guidelines
6. Test thoroughly

