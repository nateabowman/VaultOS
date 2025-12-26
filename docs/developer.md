# VaultOS Developer Documentation

Guide for developers contributing to VaultOS.

## Development Setup

### Prerequisites
- Fedora Linux (recommended)
- Development tools: gcc, make, git
- Build tools: rpmbuild, mock
- Graphics tools: GIMP, Inkscape (optional)

### Getting Started
```bash
git clone <repository>
cd VaultOS
./scripts/setup-build-env.sh
```

## Project Structure

- `src/` - Source code and configurations
- `packages/` - RPM spec files
- `build/` - Build scripts and kickstart files
- `scripts/` - Utility scripts
- `docs/` - Documentation

## Building Components

### Window Manager
```bash
cd src/wm/vaultwm
make
sudo make install
```

### Packages
```bash
./scripts/build-packages.sh
```

### ISO
```bash
./scripts/build-iso.sh
```

## Contributing

### Code Style
- C code: Follow Linux kernel style
- Shell scripts: Use bash, check with shellcheck
- Configuration files: Follow existing format

### Testing
- Test in virtual machine
- Verify all components work together
- Check for regressions

### Submitting Changes
1. Fork repository
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit pull request

## Architecture

### Window Manager
- X11-based
- Lightweight design
- Minimal dependencies
- C implementation

### Theming System
- GTK3/GTK4 CSS
- Qt QSS
- Terminal color schemes
- Consistent color palette

## Resources

- Fedora Documentation
- X11 Programming
- GTK Documentation
- RPM Packaging Guide

