#!/bin/bash
# Create icon template for VaultOS
# Generates a basic SVG template following VaultOS icon guidelines

OUTPUT_FILE="${1:-icon-template.svg}"
SIZE="${2:-512}"

cat > "$OUTPUT_FILE" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<svg width="512" height="512" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg">
  <!-- VaultOS Icon Template -->
  <!-- Follow ICON_GUIDELINES.md for design requirements -->
  
  <!-- Background (optional, usually transparent) -->
  <rect width="512" height="512" fill="none"/>
  
  <!-- Main icon shape - customize this -->
  <rect x="64" y="64" width="384" height="384" rx="32" 
        fill="#00FF41" stroke="#003300" stroke-width="4"/>
  
  <!-- Add your icon design here -->
  <!-- Use Pip-Boy green (#00FF41) as primary color -->
  <!-- Use dark green (#003300) for accents -->
  <!-- Use black (#000000) for backgrounds -->
  
</svg>
EOF

# Replace size placeholder if different size specified
if [ "$SIZE" != "512" ]; then
    sed -i "s/width=\"512\"/width=\"$SIZE\"/g" "$OUTPUT_FILE"
    sed -i "s/height=\"512\"/height=\"$SIZE\"/g" "$OUTPUT_FILE"
    sed -i "s/viewBox=\"0 0 512 512\"/viewBox=\"0 0 $SIZE $SIZE\"/g" "$OUTPUT_FILE"
fi

echo "Icon template created: $OUTPUT_FILE"
echo "Edit this file to create your custom icon design"

