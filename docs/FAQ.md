# VaultOS FAQ

Frequently Asked Questions about VaultOS.

## General

### What is VaultOS?

VaultOS is a Linux distribution based on Fedora with comprehensive Fallout theming. It features Pip-Boy green terminal aesthetics, Vault-Tec branding, and a custom lightweight window manager.

### Is VaultOS official or endorsed by Bethesda?

No. VaultOS is an independent, fan-made project. It is not affiliated with, endorsed by, or associated with Bethesda Softworks, ZeniMax Media, or any of their subsidiaries.

### What base distribution does VaultOS use?

VaultOS is based on Fedora Linux. It uses Fedora's package management (DNF) and follows Fedora's release cycle.

### Is VaultOS suitable for daily use?

Yes, VaultOS is a fully functional Linux distribution. However, it's a themed distribution, so it's best for users who enjoy the Fallout aesthetic and want a unique desktop experience.

## Installation

### What are the system requirements?

- **Minimum**: 2GB RAM, 10GB disk space, x86_64 CPU
- **Recommended**: 4GB+ RAM, 20GB+ disk space, multi-core CPU

### Can I dual-boot VaultOS?

Yes, VaultOS can be installed alongside other operating systems. The GRUB bootloader will detect other OS installations.

### Can I install VaultOS in a virtual machine?

Yes, VaultOS works well in virtual machines (VirtualBox, VMware, QEMU/KVM, etc.). See the [Installation Guide](installation.md) for VM-specific instructions.

### How do I update VaultOS?

```bash
sudo dnf update
```

VaultOS uses Fedora's update mechanism.

## Customization

### Can I change the color scheme?

Yes. VaultOS includes both Pip-Boy (green) and Vault-Tec (blue/gold) themes. Switch using:

```bash
vaultos-theme-switcher
```

### How do I change wallpapers?

See the [Customization Guide](customization.md) for detailed instructions. Wallpapers are in `/usr/share/vaultos/wallpapers/`.

### Can I use a different window manager?

Yes, but VaultWM is recommended for the full VaultOS experience. You can install other window managers and select them at login.

### How do I customize the terminal theme?

Terminal themes are in `/usr/share/vaultos/terminal/themes/`. Copy to your terminal's configuration directory.

## Troubleshooting

### The window manager won't start

1. Check X11 is installed: `sudo dnf install xorg-x11-server-Xorg`
2. Check logs: `journalctl -u vaultwm.service`
3. Try starting manually: `vaultwm`

### Themes aren't applying

1. Verify theme files exist in `/usr/share/themes/VaultOS/`
2. Set theme manually using `gsettings` or GNOME Tweaks
3. Restart applications
4. Check file permissions

### GRUB theme not showing

```bash
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

### Terminal colors look wrong

1. Ensure your terminal supports 256 colors
2. Check color scheme file syntax
3. Try a different terminal emulator (Alacritty, GNOME Terminal, etc.)

### Plymouth boot splash not working

```bash
sudo plymouth-set-default-theme vaultos
sudo dracut --force
```

## Software

### Can I install software from Fedora repositories?

Yes, all Fedora packages are compatible. Use `dnf install <package>` as normal.

### What applications are included?

VaultOS includes standard Fedora applications plus VaultOS-specific themes and configurations. Install additional software using DNF.

### Can I use Flatpak/Snap?

Yes, Flatpak and Snap are supported (install them with DNF if needed).

## Development

### How do I contribute?

See the [Developer Documentation](developer.md) for contribution guidelines.

### Can I build VaultOS from source?

Yes. See the build scripts in the `scripts/` directory and the [Developer Documentation](developer.md).

### Where is the source code?

The source code is in the project repository. Check the `src/` directory for all source files.

## Legal

### Is VaultOS legal?

VaultOS uses original designs inspired by Fallout but does not copy copyrighted material. All code and most assets are original or properly licensed.

### Can I redistribute VaultOS?

VaultOS is released under GPLv3. See the LICENSE file for details.

### What about trademarks?

"Fallout", "Pip-Boy", "Vault-Tec" are trademarks of Bethesda Softworks. VaultOS is not affiliated with Bethesda and uses these terms only for descriptive purposes.

## Support

### Where can I get help?

- Documentation: `/usr/share/doc/vaultos/`
- Project repository issues
- Community forums (if available)

### How do I report bugs?

Report bugs through the project's issue tracker. Include:
- VaultOS version
- System information
- Steps to reproduce
- Error messages/logs

## See Also

- [Installation Guide](installation.md)
- [User Guide](user-guide.md)
- [Customization Guide](customization.md)
- [Developer Documentation](developer.md)

