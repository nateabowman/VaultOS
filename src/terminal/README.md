# VaultOS Terminal Themes

Terminal color schemes and profiles for Fallout-themed terminal experience.

## Themes

### Pip-Boy Theme
- **File**: `themes/pipboy.conf`
- **Colors**: Green monochrome (#00FF41 on black)
- **Inspired by**: Fallout Pip-Boy interface

### Vault-Tec Theme
- **File**: `themes/vaulttec.conf`
- **Colors**: Blue and gold (#1E3A8A background, #FFD700 text)
- **Inspired by**: Vault-Tec branding

## Terminal Profiles

### Alacritty
- **File**: `profiles/alacritty-pipboy.yml`
- Copy to `~/.config/alacritty/alacritty.yml` or use with `alacritty --config-file`

### GNOME Terminal
- **File**: `profiles/gnome-terminal-pipboy.sh`
- Run the script to create a new profile with Pip-Boy colors

## Installation

### Alacritty
```bash
mkdir -p ~/.config/alacritty
cp profiles/alacritty-pipboy.yml ~/.config/alacritty/alacritty.yml
```

### GNOME Terminal
```bash
chmod +x profiles/gnome-terminal-pipboy.sh
./profiles/gnome-terminal-pipboy.sh
```

### Manual Color Configuration
For other terminals, use the color values from `themes/pipboy.conf`:
- Foreground: `#00FF41` (Pip-Boy green)
- Background: `#000000` (Black)
- Cursor: `#00FF41`

