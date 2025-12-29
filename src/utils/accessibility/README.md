# VaultOS Accessibility Features

Accessibility configuration and features for VaultOS.

## Accessibility Configuration Tool

Interactive accessibility configuration:

```bash
vaultos-accessibility-config
```

Features:
- High contrast mode
- Font size scaling
- Screen reader support
- Keyboard navigation enhancements
- Color blind-friendly schemes (planned)

## Features

### High Contrast Mode
Increases contrast for better visibility.

Enable:
```bash
gsettings set org.gnome.desktop.a11y.interface high-contrast true
```

### Font Size Scaling
Adjust text size throughout the system.

Set scaling factor:
```bash
gsettings set org.gnome.desktop.interface text-scaling-factor 1.2
```

Values: 0.5 to 3.0 (default: 1.0)

### Screen Reader Support
VaultOS supports screen readers like Orca.

Install Orca:
```bash
sudo dnf install orca
```

Start Orca:
```bash
orca &
```

### Keyboard Navigation
- **Sticky Keys**: Press modifier keys in sequence
- **Slow Keys**: Delay before key acceptance
- **Bounce Keys**: Ignore repeated key presses

Configure via accessibility-config tool or gsettings.

## Configuration

Accessibility settings are saved to:
- `~/.config/vaultos/accessibility.conf`
- GNOME settings (gsettings)

## See Also

- [User Guide](../../docs/user-guide.md)
- [GNOME Accessibility Documentation](https://help.gnome.org/users/gnome-help/stable/a11y.html)

