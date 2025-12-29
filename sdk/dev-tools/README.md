# VaultOS Development Tools

Development utilities for VaultOS development.

## Tools

### theme-validator.sh
Validates theme files for correctness.

Usage:
```bash
vaultos-theme-validator [theme_directory]
```

Checks:
- CSS syntax
- Color format validity
- Required files

### icon-generator.sh
Generate multiple icon sizes from SVG source.

Usage:
```bash
vaultos-icon-generator <svg_file> [output_directory]
```

Generates icons in sizes: 16, 22, 24, 32, 48, 64, 128, 256

Requirements:
- Inkscape or ImageMagick (convert)

## Asset Validation

Validate assets:
```bash
# Validate theme
vaultos-theme-validator src/themes/gtk/

# Validate icons
# (manual check or use icon-generator to regenerate)
```

## Build Helpers

Development build scripts:
- `scripts/build-packages.sh` - Build RPM packages
- `scripts/build-iso.sh` - Build ISO image
- `scripts/setup-build-env.sh` - Setup development environment

## See Also

- [Developer Documentation](../../docs/developer.md)
- [SDK README](../README.md)

