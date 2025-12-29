#!/bin/bash
#
# VaultOS Help System
# Context-sensitive help and documentation browser
#

HELP_DIR="/usr/share/doc/vaultos"
USER_HELP_DIR="$HOME/.local/share/vaultos/help"

GREEN='\033[0;32m'
BRIGHT_GREEN='\033[1;32m'
RESET='\033[0m'

show_help() {
    local topic="$1"
    
    case "$topic" in
        wm|window-manager)
            cat <<EOF
${BRIGHT_GREEN}VaultWM Window Manager Help${RESET}

Key Bindings:
  Mod4 + Enter    - Launch terminal
  Mod4 + D        - Launch application launcher
  Mod4 + Q        - Close window
  Mod4 + T        - Toggle layout (Tiling → Floating → Monocle)
  Mod4 + F        - Toggle floating
  Mod4 + 1-9      - Switch workspace
  Mod4 + H/J/K/L  - Navigate windows

Configuration:
  ~/.config/vaultwm/config - Runtime configuration

See also: vaultwm(1)
EOF
            ;;
        theme|themes)
            cat <<EOF
${BRIGHT_GREEN}Theme Help${RESET}

Available Themes:
  - Pip-Boy (Green) - Default theme
  - Vault-Tec (Blue/Gold) - Alternative theme

Switch Themes:
  vaultos-theme-switcher

Customize Themes:
  vaultos-theme-editor

Configuration:
  ~/.config/vaultos/theme.conf
EOF
            ;;
        config|configuration)
            cat <<EOF
${BRIGHT_GREEN}Configuration Help${RESET}

Configuration Tools:
  vaultos-config-tui - Text-based configuration manager

Configuration Files:
  ~/.config/vaultos/config.json - Main configuration
  ~/.config/vaultwm/config - Window manager config

Validate Configuration:
  vaultos-config-validator
EOF
            ;;
        commands|aliases)
            cat <<EOF
${BRIGHT_GREEN}VaultOS Commands${RESET}

System Commands:
  pipboy           - System information
  pipboy-status    - Detailed status
  status           - Quick status
  inventory        - List files (ls -lah)
  map              - Current directory (pwd)
  wasteland        - Disk usage (df -h)
  vault-tec        - System services

Fallout Commands:
  vault            - Go to home directory
  quest            - Show active quests
  stimpak          - System administration (sudo)
  nuka             - Nuka-Cola status
  radio            - Play audio files

For full list: help
EOF
            ;;
        *)
            cat <<EOF
${BRIGHT_GREEN}VaultOS Help${RESET}

Topics:
  help wm              - Window manager help
  help theme           - Theme help
  help config          - Configuration help
  help commands        - Command aliases

Documentation:
  /usr/share/doc/vaultos/
  docs/user-guide.md
  docs/FAQ.md

Quick Start:
  vaultos-first-run   - Run first-run wizard
  vaultos-config-tui  - Configure system
EOF
            ;;
    esac
}

# Main
show_help "$1"

