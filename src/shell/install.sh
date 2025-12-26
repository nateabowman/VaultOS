#!/bin/bash
# Install VaultOS shell configurations

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOME_DIR="${HOME:-$HOME}"

echo "Installing VaultOS shell configurations..."

# Install bashrc
if [ -f "$SCRIPT_DIR/bashrc/vaultos.bashrc" ]; then
    if [ -f "$HOME_DIR/.bashrc" ]; then
        if ! grep -q "vaultos.bashrc" "$HOME_DIR/.bashrc"; then
            echo "" >> "$HOME_DIR/.bashrc"
            echo "# VaultOS Configuration" >> "$HOME_DIR/.bashrc"
            echo "source $SCRIPT_DIR/bashrc/vaultos.bashrc" >> "$HOME_DIR/.bashrc"
            echo "Bash configuration installed!"
        else
            echo "Bash configuration already installed"
        fi
    else
        cp "$SCRIPT_DIR/bashrc/vaultos.bashrc" "$HOME_DIR/.bashrc"
        echo "Bash configuration installed as new .bashrc"
    fi
fi

# Install zshrc
if [ -f "$SCRIPT_DIR/zshrc/vaultos.zshrc" ]; then
    if [ -f "$HOME_DIR/.zshrc" ]; then
        if ! grep -q "vaultos.zshrc" "$HOME_DIR/.zshrc"; then
            echo "" >> "$HOME_DIR/.zshrc"
            echo "# VaultOS Configuration" >> "$HOME_DIR/.zshrc"
            echo "source $SCRIPT_DIR/zshrc/vaultos.zshrc" >> "$HOME_DIR/.zshrc"
            echo "Zsh configuration installed!"
        else
            echo "Zsh configuration already installed"
        fi
    else
        cp "$SCRIPT_DIR/zshrc/vaultos.zshrc" "$HOME_DIR/.zshrc"
        echo "Zsh configuration installed as new .zshrc"
    fi
fi

echo "Shell configurations installed!"
echo "Restart your terminal or run: source ~/.bashrc (or ~/.zshrc)"

