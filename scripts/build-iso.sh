#!/bin/bash
# VaultOS ISO Build Script
# Builds a custom Fedora-based Live CD with Fallout theming

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
KICKSTART_FILE="$BUILD_DIR/kickstart/vaultos.ks"
OUTPUT_DIR="$PROJECT_ROOT/iso"
ISO_NAME="VaultOS-$(date +%Y%m%d).iso"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== VaultOS ISO Build Script ===${NC}"

# Check if running on Fedora
if [ ! -f /etc/fedora-release ]; then
    echo -e "${YELLOW}Warning: Not running on Fedora. Some tools may not be available.${NC}"
fi

# Check for required tools
echo "Checking for required tools..."
MISSING_TOOLS=()

for tool in lorax livemedia-creator rpmbuild mock; do
    if ! command -v $tool &> /dev/null; then
        MISSING_TOOLS+=($tool)
    fi
done

if [ ${#MISSING_TOOLS[@]} -ne 0 ]; then
    echo -e "${RED}Error: Missing required tools: ${MISSING_TOOLS[*]}${NC}"
    echo "Install with: sudo dnf install lorax-templates-generic lorax livemedia-creator rpm-build mock"
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Build custom packages first
echo -e "${GREEN}Building custom packages...${NC}"
"$SCRIPT_DIR/build-packages.sh" || {
    echo -e "${RED}Failed to build packages${NC}"
    exit 1
}

# Build ISO using livemedia-creator
echo -e "${GREEN}Building ISO with livemedia-creator...${NC}"

livemedia-creator \
    --make-iso \
    --iso-size=4096 \
    --ks="$KICKSTART_FILE" \
    --iso-name="$ISO_NAME" \
    --project="VaultOS" \
    --releasever="$(rpm -q --qf '%{VERSION}' fedora-release 2>/dev/null || echo '40')" \
    --volid="VaultOS" \
    --nomacboot \
    --no-virt || {
    echo -e "${RED}Failed to create ISO${NC}"
    exit 1
}

# Move ISO to output directory
if [ -f "$ISO_NAME" ]; then
    mv "$ISO_NAME" "$OUTPUT_DIR/"
    echo -e "${GREEN}ISO created successfully: $OUTPUT_DIR/$ISO_NAME${NC}"
else
    echo -e "${RED}ISO file not found${NC}"
    exit 1
fi

echo -e "${GREEN}Build complete!${NC}"

