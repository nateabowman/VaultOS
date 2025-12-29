#!/bin/bash
# VaultOS Color Blind Support
# Adjusts color schemes for color vision deficiencies

set -e

THEME_DIR="$HOME/.vaultos/themes"
COLOR_BLIND_TYPES=("deuteranopia" "protanopia" "tritanopia")

# Convert color for color blindness
convert_color() {
    local color="$1"
    local type="$2"
    
    # Extract RGB values
    local r=$(printf "%d" 0x${color:1:2})
    local g=$(printf "%d" 0x${color:3:2})
    local b=$(printf "%d" 0x${color:5:2})
    
    # Color blindness simulation matrices
    case "$type" in
        deuteranopia)
            # Deuteranopia (red-green, most common)
            local r_new=$((r * 0.625 + g * 0.375))
            local g_new=$((r * 0.7 + g * 0.3))
            local b_new=$((r * 0.0 + g * 0.0 + b * 1.0))
            ;;
        protanopia)
            # Protanopia (red-blind)
            local r_new=$((r * 0.567 + g * 0.433))
            local g_new=$((r * 0.558 + g * 0.442))
            local b_new=$((r * 0.0 + g * 0.242 + b * 0.758))
            ;;
        tritanopia)
            # Tritanopia (blue-yellow)
            local r_new=$((r * 0.95 + g * 0.05))
            local g_new=$((r * 0.0 + g * 0.433 + b * 0.567))
            local b_new=$((r * 0.0 + g * 0.475 + b * 0.525))
            ;;
        *)
            echo "$color"
            return
            ;;
    esac
    
    # Clamp values
    r_new=$((r_new > 255 ? 255 : (r_new < 0 ? 0 : r_new)))
    g_new=$((g_new > 255 ? 255 : (g_new < 0 ? 0 : g_new)))
    b_new=$((b_new > 255 ? 255 : (b_new < 0 ? 0 : b_new)))
    
    # Convert back to hex
    printf "#%02X%02X%02X" "$r_new" "$g_new" "$b_new"
}

# Apply color blind adjustments to theme
apply_color_blind_theme() {
    local theme_name="$1"
    local type="$2"
    
    if [ -z "$theme_name" ] || [ -z "$type" ]; then
        echo "Usage: $0 apply <theme_name> <type>"
        echo "Types: deuteranopia, protanopia, tritanopia"
        exit 1
    fi
    
    local theme_path="$THEME_DIR/$theme_name"
    if [ ! -d "$theme_path" ]; then
        echo "Error: Theme not found"
        exit 1
    fi
    
    local theme_json="$theme_path/theme.json"
    if [ ! -f "$theme_json" ]; then
        echo "Error: Theme JSON not found"
        exit 1
    fi
    
    if ! command -v jq &> /dev/null; then
        echo "Error: jq required"
        exit 1
    fi
    
    # Create adjusted theme
    local adjusted_theme="${theme_name}-${type}"
    local adjusted_path="$THEME_DIR/$adjusted_theme"
    mkdir -p "$adjusted_path"
    
    # Copy theme files
    cp -r "$theme_path"/* "$adjusted_path/" 2>/dev/null || true
    
    # Adjust colors in JSON
    local primary=$(jq -r '.colors.primary' "$theme_json")
    local background=$(jq -r '.colors.background' "$theme_json")
    local accent=$(jq -r '.colors.accent' "$theme_json")
    
    local primary_adj=$(convert_color "$primary" "$type")
    local background_adj=$(convert_color "$background" "$type")
    local accent_adj=$(convert_color "$accent" "$type")
    
    # Update JSON
    jq ".colors.primary = \"$primary_adj\" | .colors.background = \"$background_adj\" | .colors.accent = \"$accent_adj\"" \
        "$theme_json" > "$adjusted_path/theme.json"
    
    echo "Color blind adjusted theme created: $adjusted_theme"
    echo "Load with: vaultos-theme-engine load $adjusted_theme"
}

# Enable color blind mode
enable_color_blind() {
    local type="$1"
    
    if [ -z "$type" ]; then
        echo "Usage: $0 enable <type>"
        echo "Types: deuteranopia, protanopia, tritanopia"
        exit 1
    fi
    
    # Save preference
    mkdir -p "$HOME/.vaultos"
    echo "$type" > "$HOME/.vaultos/color_blind_type"
    
    # Apply to current theme if loaded
    if [ -f "$HOME/.vaultos/current-theme" ]; then
        local current_theme=$(cat "$HOME/.vaultos/current-theme")
        apply_color_blind_theme "$current_theme" "$type"
    fi
    
    echo "Color blind mode enabled: $type"
}

# Show menu
show_menu() {
    clear
    echo "VaultOS Color Blind Support"
    echo ""
    echo "1) Apply color blind adjustments to theme"
    echo "2) Enable color blind mode"
    echo "3) Disable color blind mode"
    echo "4) Exit"
}

# Main
if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
        show_menu
        read -p "Choice: " choice
        case $choice in
            1) read -p "Theme name: " theme; read -p "Type (deuteranopia/protanopia/tritanopia): " type; apply_color_blind_theme "$theme" "$type";;
            2) read -p "Type (deuteranopia/protanopia/tritanopia): " type; enable_color_blind "$type";;
            3) rm -f "$HOME/.vaultos/color_blind_type"; echo "Color blind mode disabled";;
            4) exit 0;;
            *) echo "Invalid choice";;
        esac
    done
else
    # Command-line mode
    case "$1" in
        apply) apply_color_blind_theme "$2" "$3";;
        enable) enable_color_blind "$2";;
        disable) rm -f "$HOME/.vaultos/color_blind_type"; echo "Color blind mode disabled";;
        *) echo "Usage: $0 {apply|enable|disable}"; exit 1;;
    esac
fi

