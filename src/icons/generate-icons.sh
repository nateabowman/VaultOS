#!/bin/bash
# VaultOS Icon Generation Script
# Generates PNG icons from SVG sources for all required sizes

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ICON_DIR="$SCRIPT_DIR/VaultOS"
SVG_DIR="$ICON_DIR/scalable"
SIZES=(16 22 24 32 48 64 128 256)

# Check for required tools
if ! command -v inkscape &> /dev/null && ! command -v convert &> /dev/null; then
    echo "Error: inkscape or ImageMagick convert required for icon generation"
    exit 1
fi

# Function to generate PNG from SVG
generate_png() {
    local svg_file="$1"
    local size="$2"
    local output_file="$3"
    
    if [ -f "$svg_file" ]; then
        if command -v inkscape &> /dev/null; then
            inkscape --export-type=png --export-filename="$output_file" \
                --export-width="$size" --export-height="$size" "$svg_file" 2>/dev/null || true
        elif command -v convert &> /dev/null; then
            convert -background none -resize "${size}x${size}" "$svg_file" "$output_file" 2>/dev/null || true
        fi
    fi
}

# Generate icons for each size
for size in "${SIZES[@]}"; do
    size_dir="$ICON_DIR/${size}x${size}"
    mkdir -p "$size_dir"
    
    echo "Generating ${size}x${size} icons..."
    
    # Find all SVG files in scalable directories
    find "$SVG_DIR" -name "*.svg" -type f | while read -r svg_file; do
        # Get relative path from scalable directory
        rel_path="${svg_file#$SVG_DIR/}"
        rel_dir="$(dirname "$rel_path")"
        filename="$(basename "$svg_file" .svg)"
        
        # Create corresponding directory structure
        if [ "$rel_dir" != "." ]; then
            mkdir -p "$size_dir/$rel_dir"
            output_file="$size_dir/$rel_dir/$filename.png"
        else
            output_file="$size_dir/$filename.png"
        fi
        
        # Generate PNG if SVG exists
        if [ -f "$svg_file" ]; then
            generate_png "$svg_file" "$size" "$output_file"
        fi
    done
done

echo "Icon generation complete!"
echo ""
echo "To install icons, run:"
echo "  cd $SCRIPT_DIR && ./install.sh"

