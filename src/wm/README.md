# VaultWM - VaultOS Window Manager

A lightweight, Fallout-themed window manager for X11 with Pip-Boy-style status bar.

## Features

- **Tiling and Floating Modes**: Switch between tiling and floating window layouts
- **Pip-Boy Status Bar**: Green monochrome status bar showing system information
- **Keyboard-Driven**: Fully keyboard-driven navigation
- **Lightweight**: Minimal dependencies, fast and efficient
- **Fallout Aesthetic**: Pip-Boy green color scheme throughout

## Key Bindings

- `Mod4 + Enter` - Launch terminal
- `Mod4 + Q` - Close focused window
- `Mod4 + T` - Toggle tiling/floating layout
- `Mod4 + F` - Toggle floating for current window

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

