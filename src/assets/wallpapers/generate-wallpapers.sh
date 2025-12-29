#!/bin/bash
# Generate VaultOS wallpapers in multiple resolutions
# Creates Pip-Boy and Vault-Tec themed wallpapers

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOLUTIONS=("1920x1080" "2560x1440" "3840x2160")
THEMES=("pipboy" "vaulttec")

if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick convert required"
    exit 1
fi

for theme in "${THEMES[@]}"; do
    theme_dir="$SCRIPT_DIR/$theme"
    mkdir -p "$theme_dir"
    
    for res in "${RESOLUTIONS[@]}"; do
        width="${res%%x*}"
        height="${res##*x}"
        output="$theme_dir/vaultos-${theme}-${res}.png"
        
        echo "Generating $theme wallpaper: ${res}..."
        "$SCRIPT_DIR/create-wallpaper-template.sh" "$output" "$width" "$height" "$theme"
    done
done

echo ""
echo "Wallpapers generated!"
echo "Location: $SCRIPT_DIR"

