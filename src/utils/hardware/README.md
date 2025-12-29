# VaultOS Hardware Configuration Utilities

Utilities for configuring and managing hardware on VaultOS.

## Utilities

### display-config.sh
Display configuration utility for managing monitors, resolutions, and multi-monitor setups.

**Features:**
- List connected displays
- List available resolutions
- Set display resolution
- Set refresh rate
- Configure multi-monitor arrangements (mirror, extend, left, right, above, below)
- Save configuration

**Usage:**
```bash
vaultos-display-config
# Or auto-configure
vaultos-display-config --auto
```

### input-config.sh
Input device configuration for keyboards and mice.

**Features:**
- List keyboard layouts
- Set keyboard layout
- List mouse devices
- Configure mouse settings (acceleration, sensitivity)

**Usage:**
```bash
vaultos-input-config
```

### audio-config.sh
Audio device management and configuration.

**Features:**
- List audio devices
- Set default output device
- Get/set volume
- Toggle mute

**Usage:**
```bash
vaultos-audio-config
```

### hardware-detection.sh
Hardware detection and auto-configuration.

**Features:**
- Detect CPU, GPU, memory
- Detect displays and audio devices
- Generate hardware report
- Auto-configure optimal settings

**Usage:**
```bash
# Interactive mode
vaultos-hardware-detection

# Auto-configure
vaultos-hardware-detection --auto

# Generate report
vaultos-hardware-detection --report
```

## Installation

Install utilities to system PATH:
```bash
sudo install -m 755 display-config.sh /usr/local/bin/vaultos-display-config
sudo install -m 755 input-config.sh /usr/local/bin/vaultos-input-config
sudo install -m 755 audio-config.sh /usr/local/bin/vaultos-audio-config
sudo install -m 755 hardware-detection.sh /usr/local/bin/vaultos-hardware-detection
```

## Configuration Files

Configuration is saved to:
- Display: `~/.config/vaultos/display.conf`
- Audio: `~/.config/pulse/default.pa` (PulseAudio)
- Input: System-wide via `localectl` or session via `setxkbmap`

## Hardware Compatibility

VaultOS works with standard Linux-compatible hardware:
- Intel, AMD, and ARM processors
- NVIDIA, AMD, and Intel graphics
- Standard USB/Bluetooth input devices
- PulseAudio and ALSA audio systems

For specific hardware issues, refer to Fedora documentation (VaultOS is based on Fedora).
