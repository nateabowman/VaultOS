#!/bin/bash
#
# Icon Generator
# Generate multiple icon sizes from SVG source
#

SVG_FILE="$1"
OUTPUT_DIR="${2:-.}"

if [ -z "$SVG_FILE" ] || [ ! -f "$SVG_FILE" ]; then
    echo "Usage: $0 <svg_file> [output_directory]"
    echo "Example: $0 icon.svg icons/"
    exit 1
fi

SIZES="16 22 24 32 48 64 128 256"

mkdir -p "$OUTPUT_DIR"

echo "Generating icons from: $SVG_FILE"

for size in $SIZES; do
    if command -v inkscape &> /dev/null; then
        inkscape -w "$size" -h "$size" "$SVG_FILE" -o "$OUTPUT_DIR/${size}x${size}.png"
    elif command -v convert &> /dev/null; then
        convert -background none -resize "${size}x${size}" "$SVG_FILE" "$OUTPUT_DIR/${size}x${size}.png"
    else
        echo "Error: No suitable conversion tool found (inkscape or imagemagick)"
        exit 1
    fi
    echo "Generated: ${size}x${size}.png"
done

echo "Icon generation complete"

