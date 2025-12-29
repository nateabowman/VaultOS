# VaultOS First-Run Wizard

Welcome and setup wizard for new VaultOS users.

## Usage

The first-run wizard automatically runs on first login. To run manually:

```bash
vaultos-first-run
```

To run the wizard again:

```bash
rm ~/.config/vaultos/first-run-complete
vaultos-first-run
```

## Wizard Steps

1. **Welcome Screen** - Introduction to VaultOS
2. **Theme Selection** - Choose Pip-Boy or Vault-Tec theme
3. **Key Binding Tutorial** - Learn essential shortcuts
4. **Workspace Setup** - Understand workspace system
5. **Application Preferences** - Set default applications
6. **Completion** - Setup complete message

## Configuration

The wizard saves configuration to:
- `~/.config/vaultos/current_theme` - Selected theme
- `~/.config/vaultos/app-preferences.conf` - Application preferences
- `~/.config/vaultos/first-run-complete` - Completion flag

## See Also

- [User Guide](../../docs/user-guide.md)
- [Installation Guide](../../docs/installation.md)

