# VaultOS Customization Guide

Guide to customizing VaultOS to your preferences.

## Color Schemes

### Switching Themes

#### Pip-Boy Theme (Default)
Green monochrome theme:
```bash
# Terminal
cp src/terminal/themes/pipboy.conf ~/.config/terminal/pipboy.conf

# GTK
gsettings set org.gnome.desktop.interface gtk-theme "VaultOS"
```

#### Vault-Tec Theme
Blue and gold theme:
```bash
# Terminal
cp src/terminal/themes/vaulttec.conf ~/.config/terminal/vaulttec.conf

# Use Vault-Tec color scheme
```

### Custom Colors

Edit color scheme files:
- Terminal: `src/terminal/themes/*.conf`
- GTK: `src/themes/gtk/*.css`
- Qt: `src/themes/qt/vaultos.qss`

## Window Manager

### VaultWM Configuration

Edit `src/wm/vaultwm/config.h` to customize:
- Colors
- Key bindings
- Status bar appearance
- Window gaps

Rebuild after changes:
```bash
cd src/wm/vaultwm
make clean && make
sudo make install
```

### Key Bindings

Default bindings (Mod4 = Super key):
- `Mod4 + Enter` - Terminal
- `Mod4 + Q` - Close window
- `Mod4 + T` - Toggle layout
- `Mod4 + F` - Toggle floating

Add custom bindings in `config.h` and rebuild.

## Shell Customization

### Prompt Customization

Edit shell configuration:
- Bash: `src/shell/bashrc/vaultos.bashrc`
- Zsh: `src/shell/zshrc/vaultos.zshrc`

Customize prompt function:
```bash
vaultos_prompt() {
    # Your custom prompt code
}
```

### Aliases

Add custom aliases:
```bash
# In .bashrc or .zshrc
alias myalias='command'
```

### Functions

Add custom functions:
```bash
myfunction() {
    echo "Custom function"
}
```

## Terminal Configuration

### Alacritty

Edit `~/.config/alacritty/alacritty.yml`:
```yaml
colors:
  primary:
    background: "#000000"
    foreground: "#00FF41"
```

### GNOME Terminal

Create new profile:
```bash
./src/terminal/profiles/gnome-terminal-pipboy.sh
```

Or manually configure in GNOME Terminal preferences.

### Other Terminals

Use color values from `src/terminal/themes/pipboy.conf`:
- Foreground: `#00FF41`
- Background: `#000000`
- Cursor: `#00FF41`

## Application Themes

### File Manager

#### Ranger
Edit `~/.config/ranger/rc.conf`:
```bash
set colorscheme default
# Add custom settings
```

#### Thunar/Nautilus
Uses GTK theme automatically when VaultOS theme is selected.

### Text Editors

#### Vim
Edit `~/.vimrc`:
```vim
colorscheme desert
" Add Pip-Boy color overrides
```

#### Nano
Edit `~/.nanorc`:
```bash
set syntaxcoloring
```

## Fonts

### Installing Custom Fonts

1. Place fonts in `src/fonts/`
2. Install:
   ```bash
   cd src/fonts
   sudo ./install.sh
   ```
3. Update font cache:
   ```bash
   fc-cache -fv
   ```

### Changing Default Font

Edit font configuration:
- GTK: `src/themes/gtk/index.theme`
- Terminal: Terminal profile files
- System: `src/fonts/fontconfig.xml`

## Wallpapers

### Setting Wallpaper

#### GNOME
```bash
gsettings set org.gnome.desktop.background picture-uri file:///path/to/wallpaper.png
```

#### VaultWM
Edit window manager to load wallpaper, or use:
```bash
feh --bg-fill /path/to/wallpaper.png
```

### Creating Wallpapers

Use GIMP or Inkscape with color palette:
- Pip-Boy green: `#00FF41`
- Black: `#000000`
- Dark green: `#003300`

Recommended size: 1920x1080 or higher.

## Icons

### Installing Icon Theme

1. Place icons in `src/icons/`
2. Install:
   ```bash
   sudo cp -r src/icons/* /usr/share/icons/VaultOS/
   gtk-update-icon-cache /usr/share/icons/VaultOS/
   ```
3. Set icon theme:
   ```bash
   gsettings set org.gnome.desktop.interface icon-theme "VaultOS"
   ```

### Creating Icons

Tools:
- Inkscape (SVG)
- GIMP (raster)
- ImageMagick (conversion)

Size requirements: 16x16 to 256x256

## Boot Themes

### GRUB Theme

Edit `src/boot/grub/theme.txt`:
- Colors
- Layout
- Fonts
- Images

Regenerate GRUB config:
```bash
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

### Plymouth Theme

Edit `src/boot/plymouth/vaultos.script`:
- Animation
- Colors
- Messages

Rebuild initrd:
```bash
sudo dracut --force
```

## System Settings

### GTK Settings

Configure GTK behavior:
```bash
gsettings set org.gnome.desktop.interface gtk-theme "VaultOS"
gsettings set org.gnome.desktop.interface icon-theme "VaultOS"
gsettings set org.gnome.desktop.interface font-name "Unifont 12"
```

### Qt Settings

Set Qt style:
```bash
export QT_STYLE_OVERRIDE=vaultos
```

Or in application code:
```cpp
app.setStyleSheet(styleSheet);
```

## Advanced Customization

### Creating Custom Theme

1. Copy existing theme files
2. Modify colors and styles
3. Install theme
4. Set as default

### Package Customization

Edit RPM spec files in `packages/`:
- Add/remove files
- Change installation paths
- Modify post-install scripts

Rebuild packages:
```bash
./scripts/build-packages.sh
```

## Tips

- Keep backups of configuration files
- Test changes in virtual machine first
- Document custom modifications
- Share improvements with community

## Troubleshooting

### Theme Not Applying
- Check file permissions
- Verify theme files exist
- Restart applications
- Check logs for errors

### Colors Not Showing
- Verify terminal supports colors
- Check color scheme syntax
- Test with different terminal

### Configuration Not Loading
- Check file paths
- Verify syntax is correct
- Check file permissions
- Review logs

