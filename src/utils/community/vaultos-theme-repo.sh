#!/bin/bash
# VaultOS Theme Repository Manager
# Theme sharing platform with ratings and reviews

set -e

REPO_URL="${VAULTOS_THEME_REPO_URL:-https://themes.vaultos.org}"
REPO_DIR="$HOME/.vaultos/theme-repo"
CACHE_FILE="$REPO_DIR/theme-cache.json"

# Initialize repository
init_repo() {
    mkdir -p "$REPO_DIR"
    echo "Theme repository initialized"
}

# Search themes
search_themes() {
    local query="$1"
    
    if [ -z "$query" ]; then
        echo "Usage: $0 search <query>"
        exit 1
    fi
    
    if [ -f "$CACHE_FILE" ]; then
        if command -v jq &> /dev/null; then
            jq -r ".[] | select(.name | contains(\"$query\")) | \"\(.name) - \(.description) [Rating: \(.rating)]\"" "$CACHE_FILE"
        else
            grep -i "$query" "$CACHE_FILE" || echo "No themes found"
        fi
    else
        echo "Theme cache not found. Run: $0 update"
    fi
}

# List themes
list_themes() {
    if [ -f "$CACHE_FILE" ]; then
        if command -v jq &> /dev/null; then
            jq -r '.[] | "\(.name) - \(.description) [Rating: \(.rating), Downloads: \(.downloads)]"' "$CACHE_FILE"
        else
            cat "$CACHE_FILE"
        fi
    else
        echo "Theme cache not found. Run: $0 update"
    fi
}

# Update theme cache
update_cache() {
    echo "Updating theme repository cache..."
    
    # Sample cache
    cat > "$CACHE_FILE" << 'EOF'
[
  {
    "name": "pipboy-classic",
    "description": "Classic Pip-Boy green theme",
    "version": "1.0.0",
    "rating": 4.8,
    "downloads": 500,
    "author": "VaultOS Team",
    "category": "pipboy"
  },
  {
    "name": "vaulttec-blue",
    "description": "Vault-Tec blue and gold theme",
    "version": "1.0.0",
    "rating": 4.6,
    "downloads": 300,
    "author": "VaultOS Team",
    "category": "vaulttec"
  }
]
EOF
    
    echo "Cache updated"
}

# Install theme from repository
install_theme() {
    local theme_name="$1"
    
    if [ -z "$theme_name" ]; then
        echo "Usage: $0 install <theme_name>"
        exit 1
    fi
    
    echo "Installing theme: $theme_name"
    
    # In a real implementation, this would download and install the theme
    if command -v vaultos-theme-engine &> /dev/null; then
        # Download theme (simplified)
        local theme_dir="$HOME/.vaultos/themes/$theme_name"
        mkdir -p "$theme_dir"
        
        echo "Theme downloaded to: $theme_dir"
        echo "Load with: vaultos-theme-engine load $theme_name"
    else
        echo "Error: vaultos-theme-engine not found"
        exit 1
    fi
}

# Rate theme
rate_theme() {
    local theme_name="$1"
    local rating="$2"
    
    if [ -z "$theme_name" ] || [ -z "$rating" ]; then
        echo "Usage: $0 rate <theme_name> <rating 1-5>"
        exit 1
    fi
    
    echo "Rating submitted: $theme_name = $rating/5"
}

# Show menu
show_menu() {
    clear
    echo "VaultOS Theme Repository"
    echo ""
    echo "1) Search themes"
    echo "2) List themes"
    echo "3) Update cache"
    echo "4) Install theme"
    echo "5) Rate theme"
    echo "6) Exit"
}

# Main
init_repo

if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
        show_menu
        read -p "Choice: " choice
        case $choice in
            1) read -p "Search query: " query; search_themes "$query"; read -p "Press Enter to continue...";;
            2) list_themes; read -p "Press Enter to continue...";;
            3) update_cache;;
            4) read -p "Theme name: " name; install_theme "$name";;
            5) read -p "Theme name: " name; read -p "Rating (1-5): " rating; rate_theme "$name" "$rating";;
            6) exit 0;;
            *) echo "Invalid choice";;
        esac
    done
else
    # Command-line mode
    case "$1" in
        search) search_themes "$2";;
        list) list_themes;;
        update) update_cache;;
        install) install_theme "$2";;
        rate) rate_theme "$2" "$3";;
        *) echo "Usage: $0 {search|list|update|install|rate}"; exit 1;;
    esac
fi

