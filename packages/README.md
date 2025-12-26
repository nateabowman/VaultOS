# VaultOS RPM Packages

RPM spec files for packaging VaultOS custom components.

## Packages

### vaultwm
Custom window manager for VaultOS
- **Spec**: `vaultwm/vaultwm.spec`
- **Dependencies**: libX11-devel, gcc, make

### vaultos-themes
GTK, Qt, and color themes
- **Spec**: `vaultos-themes/vaultos-themes.spec`
- **Dependencies**: gtk3, gtk4, qt5-qtbase-devel

### vaultos-terminal
Terminal color schemes and profiles
- **Spec**: `vaultos-terminal/vaultos-terminal.spec`
- **Dependencies**: None

### vaultos-shell
Shell configurations (bash/zsh)
- **Spec**: `vaultos-shell/vaultos-shell.spec`
- **Dependencies**: None

### vaultos-boot
GRUB and Plymouth boot themes
- **Spec**: `vaultos-boot/vaultos-boot.spec`
- **Dependencies**: grub2, plymouth

## Building Packages

Use the build script:
```bash
./scripts/build-packages.sh
```

Or build manually:
```bash
cd packages/vaultwm
rpmbuild -ba vaultwm.spec
```

## Package Structure

Each package directory should contain:
- `*.spec` - RPM spec file
- Source files (or tarball)
- Additional resources

## Installation

After building, install packages:
```bash
sudo rpm -ivh ~/rpmbuild/RPMS/x86_64/vaultos-*.rpm
```

Or add to repository for kickstart installation.

