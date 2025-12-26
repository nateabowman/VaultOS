# VaultOS Bash Configuration
# Pip-Boy-style shell prompt and Fallout-themed customizations

# Colors (Pip-Boy green theme)
export VAULTOS_GREEN='\033[0;32m'
export VAULTOS_BRIGHT_GREEN='\033[1;32m'
export VAULTOS_AMBER='\033[1;33m'
export VAULTOS_RESET='\033[0m'

# Pip-Boy-style prompt
# Format: [USER@HOST:DIR]$ 
vaultos_prompt() {
    local exit_code=$?
    local user_color=$VAULTOS_GREEN
    local host_color=$VAULTOS_BRIGHT_GREEN
    local dir_color=$VAULTOS_GREEN
    local prompt_color=$VAULTOS_BRIGHT_GREEN
    
    # Show exit code if non-zero
    if [ $exit_code -ne 0 ]; then
        echo -ne "${VAULTOS_AMBER}[EXIT:$exit_code]${VAULTOS_RESET} "
    fi
    
    # Pip-Boy style prompt
    echo -ne "${user_color}[${VAULTOS_RESET}"
    echo -ne "${host_color}\u${VAULTOS_RESET}"
    echo -ne "${user_color}@${VAULTOS_RESET}"
    echo -ne "${host_color}\h${VAULTOS_RESET}"
    echo -ne "${user_color}:${VAULTOS_RESET}"
    echo -ne "${dir_color}\w${VAULTOS_RESET}"
    echo -ne "${user_color}]${VAULTOS_RESET}"
    echo -ne "${prompt_color}\$${VAULTOS_RESET} "
}

export PS1='$(vaultos_prompt)'

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

# Useful command aliases with Fallout flavor
alias lock='xlock'  # Screen lock
alias save='history -a'  # Save command history
alias load='history -r'  # Load command history

# Terminal title
case "$TERM" in
    xterm*|rxvt*|alacritty*)
        PS1="\[\e]0;VaultOS - \u@\h: \w\a\]$PS1"
        ;;
esac

# History configuration
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# Login message with ASCII art
if [ -t 0 ]; then
    clear
    echo -e "${VAULTOS_GREEN}"
    echo "╔════════════════════════════════════════╗"
    echo "║     VaultOS - Fallout Linux Distro    ║"
    echo "║                                        ║"
    echo "║     Pip-Boy 3000 Terminal Interface   ║"
    echo "╚════════════════════════════════════════╝"
    echo -e "${VAULTOS_RESET}"
    echo -e "${VAULTOS_BRIGHT_GREEN}Welcome, Vault Dweller!${VAULTOS_RESET}"
    echo ""
    echo "Type 'pipboy' for system information"
    echo "Type 'help' for available commands"
    echo ""
fi

# Help function
vaultos_help() {
    echo -e "${VAULTOS_BRIGHT_GREEN}VaultOS Command Reference${VAULTOS_RESET}"
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

# Load system bashrc if it exists
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

