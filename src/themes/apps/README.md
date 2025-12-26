# VaultOS Application Theming

Configuration files for theming applications with Fallout aesthetic.

## Themed Applications

### File Managers

#### Ranger
- **File**: `apps/ranger.conf`
- Terminal-based file manager
- Pip-Boy green color scheme
- Fallout-themed aliases

Installation:
```bash
mkdir -p ~/.config/ranger
cp apps/ranger.conf ~/.config/ranger/rc.conf
```

### Text Editors

#### Vim
- **File**: `apps/vimrc`
- Custom color scheme with Pip-Boy green
- Fallout-themed key bindings
- Status line customization

Installation:
```bash
cp apps/vimrc ~/.vimrc
# Or append to existing ~/.vimrc
```

#### Nano
- **File**: `apps/nano.conf`
- Basic configuration
- Uses terminal color scheme

Installation:
```bash
cp apps/nano.conf ~/.nanorc
```

## System Utilities

### Notification System
Configure notification daemon to use Pip-Boy green colors:
- Background: #000000
- Text: #00FF41
- Border: #00FF41

### System Monitor
Theme system monitoring tools (htop, etc.) with terminal color schemes.

### Panel/Status Bar
If using a panel or status bar application:
- Background: #003300
- Text: #00FF41
- Icons: Pip-Boy green

## Integration

These configurations work with:
- Terminal color schemes (Pip-Boy theme)
- GTK/Qt themes
- Window manager (VaultWM)
- Shell customizations

All components share the same color palette for consistency.

