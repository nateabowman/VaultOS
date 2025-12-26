#!/bin/bash
# VaultOS Live CD Build Script
# Builds Live CD using livemedia-creator with all VaultOS customizations

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
KICKSTART_FILE="$BUILD_DIR/kickstart/vaultos.ks"
OUTPUT_DIR="$PROJECT_ROOT/iso"
CONFIG_FILE="$SCRIPT_DIR/livecd.conf"

# Load configuration
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== VaultOS Live CD Build ===${NC}"

# Check for required tools
for tool in livemedia-creator lorax; do
    if ! command -v $tool &> /dev/null; then
        echo -e "${RED}Error: $tool not found${NC}"
        echo "Install with: sudo dnf install lorax livemedia-creator"
        exit 1
    fi
done

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Build custom packages first
echo -e "${GREEN}Building custom packages...${NC}"
"$PROJECT_ROOT/scripts/build-packages.sh" || {
    echo -e "${YELLOW}Warning: Package build had issues, continuing...${NC}"
}

# Create repository from built packages
if [ -d "$HOME/rpmbuild/RPMS" ]; then
    echo -e "${GREEN}Creating custom repository...${NC}"
    REPO_DIR="$BUILD_DIR/repo"
    mkdir -p "$REPO_DIR"
    cp -r "$HOME/rpmbuild/RPMS"/* "$REPO_DIR/" 2>/dev/null || true
    createrepo "$REPO_DIR" 2>/dev/null || {
        echo -e "${YELLOW}Warning: createrepo not available, skipping repo creation${NC}"
    fi
fi

# Build ISO
echo -e "${GREEN}Building ISO...${NC}"

ISO_NAME="${ISO_NAME:-VaultOS}-$(date +%Y%m%d).iso"
RELEASEVER="${RELEASEVER:-40}"

livemedia-creator \
    --make-iso \
    --iso-size="${ISO_SIZE:-4096}" \
    --ks="$KICKSTART_FILE" \
    --iso-name="$ISO_NAME" \
    --project="${ISO_NAME}" \
    --releasever="$RELEASEVER" \
    --volid="${ISO_VOLID:-VaultOS}" \
    --nomacboot \
    --no-virt \
    ${CUSTOM_REPO_PATH:+"--repo=file://$CUSTOM_REPO_PATH"} \
    || {
    echo -e "${RED}Failed to create ISO${NC}"
    exit 1
}

# Move ISO to output directory
if [ -f "$ISO_NAME" ]; then
    mv "$ISO_NAME" "$OUTPUT_DIR/"
    echo -e "${GREEN}ISO created: $OUTPUT_DIR/$ISO_NAME${NC}"
    
    # Calculate size
    SIZE=$(du -h "$OUTPUT_DIR/$ISO_NAME" | cut -f1)
    echo -e "${GREEN}ISO size: $SIZE${NC}"
else
    echo -e "${RED}ISO file not found${NC}"
    exit 1
fi

echo -e "${GREEN}Live CD build complete!${NC}"

