# VaultWM - VaultOS Window Manager

A lightweight, Fallout-themed window manager for X11 with Pip-Boy-style status bar.

## Features

- **Tiling, Floating, and Monocle Layouts**: Switch between multiple layout modes
- **Workspace Support**: 9 virtual desktops (Mod4 + 1-9)
- **Window Navigation**: Arrow keys or hjkl (vim-style) to switch windows
- **Window Management**: Move and resize windows with keyboard or mouse
- **Pip-Boy Status Bar**: Enhanced status bar showing CPU, memory, network, time, workspace, and layout
- **Keyboard-Driven**: Fully keyboard-driven navigation
- **Lightweight**: Minimal dependencies, fast and efficient
- **Fallout Aesthetic**: Pip-Boy green color scheme throughout
- **Gap Support**: Configurable gaps between tiled windows

## Key Bindings

### Application Launching
- `Mod4 + Enter` - Launch terminal
- `Mod4 + D` - Launch application launcher (dmenu/rofi)

### Window Management
- `Mod4 + Q` - Close focused window
- `Mod4 + T` - Toggle layout (Tiling → Floating → Monocle)
- `Mod4 + F` - Toggle floating for current window
- `Mod4 + R` - Enter resize mode
- `Mod4 + M` - Enter move mode

### Window Navigation
- `Mod4 + Left` or `Mod4 + H` - Focus previous window
- `Mod4 + Right` or `Mod4 + L` - Focus next window
- `Mod4 + Up` or `Mod4 + K` - (Reserved for future use)
- `Mod4 + Down` or `Mod4 + J` - (Reserved for future use)

### Workspaces
- `Mod4 + 1-9` - Switch to workspace 1-9

### Mouse
- `Mod4 + Left Click` - Move window (makes it floating)
- `Mod4 + Right Click` - Resize window (makes it floating)

(Mod4 is typically the Super/Windows key)

## Building

```bash
cd src/wm/vaultwm
make
sudo make install
```

## Configuration

Edit `config.h` to customize:
- Colors
- Key bindings
- Status bar appearance
- Window gaps and borders

## Dependencies

- X11 development libraries
- GCC compiler
- Make

On Fedora:
```bash
sudo dnf install libX11-devel gcc make
```

## Integration

The window manager integrates with:
- Display managers (GDM, LightDM, etc.)
- Systemd services
- X11 session management

Install the desktop entry to make it available in display managers:
```bash
sudo cp config/vaultwm.desktop /usr/share/xsessions/
```

