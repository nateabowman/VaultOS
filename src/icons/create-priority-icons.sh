#!/bin/bash
# Create priority icons for VaultOS
# Generates placeholder SVG icons for essential applications

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ICON_DIR="$SCRIPT_DIR/VaultOS/scalable"

# Create directory structure
mkdir -p "$ICON_DIR/apps"
mkdir -p "$ICON_DIR/status"
mkdir -p "$ICON_DIR/places"
mkdir -p "$ICON_DIR/mimetypes"

# Function to create a simple icon
create_icon() {
    local name="$1"
    local category="$2"
    local color="${3:-#00FF41}"
    local output="$ICON_DIR/$category/$name.svg"
    
    cat > "$output" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<svg width="512" height="512" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg">
  <!-- $name icon - placeholder -->
  <rect width="512" height="512" fill="none"/>
  <rect x="128" y="128" width="256" height="256" rx="32" 
        fill="$color" stroke="#003300" stroke-width="8"/>
  <text x="256" y="300" font-family="monospace" font-size="120" 
        fill="#000000" text-anchor="middle" font-weight="bold">${name:0:1}</text>
</svg>
EOF
    echo "Created: $output"
}

# Application icons
echo "Creating application icons..."
create_icon "alacritty" "apps" "#00FF41"
create_icon "terminal" "apps" "#00FF41"
create_icon "file-manager" "apps" "#00FF41"
create_icon "text-editor" "apps" "#00FF41"
create_icon "system-settings" "apps" "#00FF41"
create_icon "vaultwm" "apps" "#00FF41"

# Status icons
echo "Creating status icons..."
create_icon "network-wired" "status" "#00FF41"
create_icon "network-wireless" "status" "#00FF41"
create_icon "battery" "status" "#00FF41"
create_icon "volume-high" "status" "#00FF41"
create_icon "volume-muted" "status" "#FF0000"
create_icon "shutdown" "status" "#FF0000"
create_icon "reboot" "status" "#FFBF00"

# Places icons
echo "Creating places icons..."
create_icon "folder" "places" "#00FF41"
create_icon "home" "places" "#00FF41"
create_icon "desktop" "places" "#00FF41"

# MIME type icons
echo "Creating MIME type icons..."
create_icon "text-plain" "mimetypes" "#00FF41"
create_icon "application-x-executable" "mimetypes" "#FFBF00"

echo ""
echo "Priority icons created!"
echo "These are placeholder icons - replace with proper designs following ICON_GUIDELINES.md"

