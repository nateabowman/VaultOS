#!/bin/bash
#
# Theme Validator
# Validates theme files for correctness
#

THEME_DIR="${1:-.}"

ERRORS=0

validate_css() {
    local css_file="$1"
    
    if [ ! -f "$css_file" ]; then
        echo "Error: CSS file not found: $css_file"
        return 1
    fi
    
    # Basic CSS syntax check (very basic)
    if ! grep -q "{" "$css_file" || ! grep -q "}" "$css_file"; then
        echo "Error: Invalid CSS syntax in $css_file"
        ERRORS=$((ERRORS + 1))
        return 1
    fi
    
    echo "CSS validation: OK"
    return 0
}

validate_colors() {
    local color_file="$1"
    
    if [ ! -f "$color_file" ]; then
        return 0  # Color file optional
    fi
    
    # Check for valid hex colors
    while IFS= read -r line; do
        if echo "$line" | grep -qE "^[a-zA-Z_]+=#([0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})$"; then
            continue
        elif echo "$line" | grep -qE "^#|^$"; then
            continue  # Comment or empty line
        elif [ -n "$line" ]; then
            echo "Warning: Invalid color format: $line"
        fi
    done < "$color_file"
}

# Main
if [ -f "$THEME_DIR/gtk.css" ] || [ -f "$THEME_DIR/vaultos-gtk3.css" ]; then
    CSS_FILE=$(find "$THEME_DIR" -name "*.css" | head -1)
    validate_css "$CSS_FILE"
fi

if [ -f "$THEME_DIR/colors.conf" ]; then
    validate_colors "$THEME_DIR/colors.conf"
fi

if [ $ERRORS -eq 0 ]; then
    echo "Theme validation: PASSED"
    exit 0
else
    echo "Theme validation: FAILED ($ERRORS errors)"
    exit 1
fi

