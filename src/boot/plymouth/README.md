# VaultOS Plymouth Boot Splash

Fallout-themed animated boot splash screen for VaultOS.

## Files

- `vaultos.plymouth` - Plymouth theme descriptor
- `vaultos.script` - Animation script
- `vault-door.png` - Vault door image (to be created)
- `pipboy.png` - Pip-Boy image (to be created)
- `progress-bar.png` - Progress bar graphic (to be created)

## Installation

The theme will be installed to `/usr/share/plymouth/themes/vaultos/` during system installation.

To manually install:

1. Copy theme files to `/usr/share/plymouth/themes/vaultos/`
2. Set as default:
   ```bash
   plymouth-set-default-theme vaultos
   ```
3. Rebuild initrd:
   ```bash
   dracut --force
   ```

## Features

- Animated vault door or Pip-Boy boot sequence
- Pip-Boy green color scheme (#00FF41)
- Progress bar showing boot progress
- Custom boot messages

