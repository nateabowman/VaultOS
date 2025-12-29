#!/bin/bash
#
# VaultOS Theming API
# Programmatic theme generation and management
#

THEME_DIR="${VAULTOS_THEME_DIR:-$HOME/.local/share/vaultos/themes}"

apply_theme() {
    local theme_name="$1"
    
    if [ -z "$theme_name" ]; then
        echo "Usage: apply_theme <theme_name>"
        return 1
    fi
    
    if [ -d "$THEME_DIR/$theme_name" ]; then
        # Apply theme files
        if [ -f "$THEME_DIR/$theme_name/gtk.css" ]; then
            cp "$THEME_DIR/$theme_name/gtk.css" "$HOME/.config/gtk-3.0/gtk.css"
        fi
        
        if [ -f "$THEME_DIR/$theme_name/colors.conf" ]; then
            source "$THEME_DIR/$theme_name/colors.conf"
        fi
        
        echo "Theme applied: $theme_name"
    else
        echo "Theme not found: $theme_name"
        return 1
    fi
}

generate_theme() {
    local theme_name="$1"
    local primary_color="${2:-#00FF41}"
    local bg_color="${3:-#000000}"
    
    mkdir -p "$THEME_DIR/$theme_name"
    
    # Generate CSS
    cat > "$THEME_DIR/$theme_name/gtk.css" <<EOF
/* Generated theme: $theme_name */
* {
    background-color: $bg_color;
    color: $primary_color;
}
EOF
    
    # Generate color config
    cat > "$THEME_DIR/$theme_name/colors.conf" <<EOF
primary=$primary_color
background=$bg_color
accent=$primary_color
text=$primary_color
EOF
    
    echo "Theme generated: $theme_name"
}

list_themes() {
    if [ -d "$THEME_DIR" ]; then
        ls -1 "$THEME_DIR"
    fi
}

# Main
case "${1:-}" in
    apply)
        apply_theme "$2"
        ;;
    generate)
        generate_theme "$2" "$3" "$4"
        ;;
    list)
        list_themes
        ;;
    *)
        echo "Usage: $0 {apply|generate|list} [args]"
        exit 1
        ;;
esac

