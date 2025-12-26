# VaultOS GRUB Theme

This directory contains the GRUB bootloader theme for VaultOS with Fallout aesthetic.

## Files

- `theme.txt` - GRUB theme configuration file
- `background.png` - Boot menu background image (to be created)
- `terminal_box_*.png` - Terminal box graphics (to be created)
- `select_*.png` - Selection highlight graphics (to be created)

## Installation

The theme will be installed to `/boot/grub2/themes/vaultos/` during system installation.

To manually install:

1. Copy theme files to `/boot/grub2/themes/vaultos/`
2. Update `/etc/default/grub`:
   ```
   GRUB_THEME=/boot/grub2/themes/vaultos/theme.txt
   ```
3. Regenerate GRUB config:
   ```bash
   grub2-mkconfig -o /boot/grub2/grub.cfg
   ```

## Color Scheme

- Primary: `#00FF41` (Pip-Boy green)
- Background: `#000000` (Black)
- Selection: `#003300` (Dark green)
- Text: `#FFFFFF` (White)

