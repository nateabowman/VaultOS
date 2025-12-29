# VaultOS Boot Customization Tools

Tools for customizing boot configuration (GRUB and Plymouth).

## Tools

### boot-customizer.sh
Interactive tool for customizing boot settings.

Usage:
```bash
vaultos-boot-customizer
```

Features:
- Configure GRUB theme
- Set GRUB timeout
- Add kernel parameters
- Configure Plymouth theme
- Test boot configuration

## GRUB Configuration

GRUB configuration is stored in `/etc/default/grub`.

After making changes, regenerate GRUB configuration:
```bash
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

## Plymouth Configuration

Set Plymouth theme:
```bash
sudo plymouth-set-default-theme vaultos
sudo dracut --force
```

## Kernel Parameters

Common kernel parameters:
- `quiet` - Reduce boot messages
- `splash` - Show boot splash
- `nomodeset` - Disable KMS (for some graphics issues)
- `acpi=off` - Disable ACPI (debugging)

## See Also

- [Boot Themes Documentation](../README.md)
- [Installation Guide](../../docs/installation.md)

