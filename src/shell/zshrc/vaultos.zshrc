# VaultOS Zsh Configuration
# Pip-Boy-style shell prompt and Fallout-themed customizations

# Colors (Pip-Boy green theme)
export VAULTOS_GREEN='%F{green}'
export VAULTOS_BRIGHT_GREEN='%F{46}'  # Bright green (#00FF41)
export VAULTOS_AMBER='%F{yellow}'
export VAULTOS_RESET='%f'

# Pip-Boy-style prompt
autoload -U colors && colors

# Function to show exit code
vaultos_exit_code() {
    if [ $? -ne 0 ]; then
        echo -n "%{$VAULTOS_AMBER%}[EXIT:$?]%{$VAULTOS_RESET%} "
    fi
}

# Pip-Boy prompt format: [USER@HOST:DIR]$ 
setopt PROMPT_SUBST
PROMPT='$(vaultos_exit_code)%{$VAULTOS_GREEN%}[%{$VAULTOS_BRIGHT_GREEN%}%n%{$VAULTOS_GREEN%}@%{$VAULTOS_BRIGHT_GREEN%}%m%{$VAULTOS_GREEN%}:%{$VAULTOS_GREEN%}%~%{$VAULTOS_GREEN%}]%{$VAULTOS_BRIGHT_GREEN%}$%{$VAULTOS_RESET%} '

# Right prompt with time
RPROMPT='%{$VAULTOS_GREEN%}[%T]%{$VAULTOS_RESET%}'

# Fallout-themed aliases
alias vault='cd ~'
alias pipboy='clear && echo "Pip-Boy 3000 - VaultOS Terminal Interface"'
alias status='echo "System Status: OPERATIONAL" && uptime'
alias inventory='ls -lah'
alias quest='echo "Active Quests: None"'
alias map='pwd'
alias radio='mpv --no-video'  # If mpv is installed
alias stimpak='sudo'  # For system administration
alias nuka='echo "Nuka-Cola: Out of stock"'

# Useful command aliases
alias lock='xlock'
alias save='fc -W'  # Save command history
alias load='fc -R'  # Load command history

# History configuration
HISTSIZE=10000
SAVEHIST=20000
HISTFILE=~/.zsh_history
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

# Login message
if [[ -o interactive ]]; then
    clear
    echo -e "$VAULTOS_BRIGHT_GREEN"
    echo "╔════════════════════════════════════════╗"
    echo "║     VaultOS - Fallout Linux Distro    ║"
    echo "║                                        ║"
    echo "║     Pip-Boy 3000 Terminal Interface   ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "$VAULTOS_RESET"
    echo -e "$VAULTOS_BRIGHT_GREEN Welcome, Vault Dweller!$VAULTOS_RESET"
    echo ""
    echo "Type 'pipboy' for system information"
    echo "Type 'help' for available commands"
    echo ""
fi

# Help function
vaultos_help() {
    echo -e "$VAULTOS_BRIGHT_GREEN VaultOS Command Reference$VAULTOS_RESET"
    echo ""
    echo "System Commands:"
    echo "  pipboy    - Display system information"
    echo "  status    - Show system status and uptime"
    echo "  inventory - List files (ls -lah)"
    echo "  map       - Show current directory (pwd)"
    echo ""
    echo "Fallout Commands:"
    echo "  quest     - Show active quests"
    echo "  radio     - Play audio files"
    echo "  stimpak   - System administration (sudo)"
    echo "  nuka      - Nuka-Cola status"
    echo ""
    echo "Utility Commands:"
    echo "  save      - Save command history"
    echo "  load      - Load command history"
    echo "  lock      - Lock screen"
}
alias help='vaultos_help'

# Load system zshrc if it exists
if [ -f /etc/zshrc ]; then
    . /etc/zshrc
fi

# Zsh-specific options
setopt AUTO_CD
setopt CORRECT
setopt COMPLETE_IN_WORD

