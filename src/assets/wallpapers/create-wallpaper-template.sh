#!/bin/bash
# Create wallpaper template for VaultOS
# Generates a basic wallpaper template following VaultOS guidelines

OUTPUT_FILE="${1:-wallpaper-template.png}"
WIDTH="${2:-1920}"
HEIGHT="${3:-1080}"
THEME="${4:-pipboy}"

if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick convert required for wallpaper generation"
    exit 1
fi

# Color schemes
if [ "$THEME" = "pipboy" ]; then
    PRIMARY="#00FF41"
    BACKGROUND="#000000"
    ACCENT="#003300"
elif [ "$THEME" = "vaulttec" ]; then
    PRIMARY="#FFD700"
    BACKGROUND="#1E3A8A"
    ACCENT="#FFFF41"
else
    PRIMARY="#00FF41"
    BACKGROUND="#000000"
    ACCENT="#003300"
fi

# Create wallpaper using ImageMagick
convert -size "${WIDTH}x${HEIGHT}" xc:"$BACKGROUND" \
    -fill "$PRIMARY" -draw "rectangle 0,0 $WIDTH,100" \
    -fill "$ACCENT" -draw "rectangle 0,$((HEIGHT-100)) $WIDTH,$HEIGHT" \
    -pointsize 72 -fill "$PRIMARY" -gravity center \
    -annotate +0+0 "VaultOS" \
    "$OUTPUT_FILE"

echo "Wallpaper template created: $OUTPUT_FILE"
echo "Theme: $THEME"
echo "Resolution: ${WIDTH}x${HEIGHT}"
echo ""
echo "Edit this image or use as a base for custom wallpapers"

