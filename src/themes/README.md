# VaultOS Themes

GTK and Qt themes with Fallout aesthetic for VaultOS.

## Themes

### Pip-Boy Theme
- **Colors**: Green monochrome (#00FF41 on black)
- **Files**: 
  - `gtk/vaultos-gtk3.css` - GTK3 theme
  - `gtk/vaultos-gtk4.css` - GTK4 theme
  - `qt/vaultos.qss` - Qt stylesheet
  - `colors/pipboy.colors` - Color definitions

### Vault-Tec Theme
- **Colors**: Blue and gold (#1E3A8A background, #FFD700 text)
- **Files**: `colors/vaulttec.colors` - Color definitions

## Installation

### GTK Themes

1. Copy theme files to `~/.themes/VaultOS/` or `/usr/share/themes/VaultOS/`
2. Copy CSS files:
   ```bash
   mkdir -p ~/.themes/VaultOS/gtk-3.0
   cp gtk/vaultos-gtk3.css ~/.themes/VaultOS/gtk-3.0/gtk.css
   ```
3. Set theme:
   ```bash
   gsettings set org.gnome.desktop.interface gtk-theme "VaultOS"
   ```

### Qt Themes

1. Copy QSS file to application directory or system theme directory
2. Set environment variable:
   ```bash
   export QT_STYLE_OVERIDE=vaultos
   ```
3. Or load in application:
   ```cpp
   QFile styleFile(":/themes/vaultos.qss");
   styleFile.open(QFile::ReadOnly);
   QString style(styleFile.readAll());
   app.setStyleSheet(style);
   ```

## Color Schemes

Color definitions are in `colors/` directory:
- `pipboy.colors` - Pip-Boy green theme
- `vaulttec.colors` - Vault-Tec blue/gold theme

Use these for consistent theming across applications.

