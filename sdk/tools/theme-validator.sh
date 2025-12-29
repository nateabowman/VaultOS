#!/bin/bash
# Theme Validation Tool
# Validates theme files and structure

validate_theme() {
    local theme_dir=$1
    echo "Validating theme: $theme_dir"
    
    # Check required files
    if [ ! -f "$theme_dir/index.theme" ]; then
        echo "ERROR: Missing index.theme"
        return 1
    fi
    
    echo "Theme validation complete"
}

validate_theme "$1"

