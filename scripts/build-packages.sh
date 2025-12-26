#!/bin/bash
# VaultOS Package Build Script
# Builds all custom RPM packages

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PACKAGES_DIR="$PROJECT_ROOT/packages"
BUILD_DIR="$PROJECT_ROOT/build/packages"
RPMBUILD_DIR="$HOME/rpmbuild"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== VaultOS Package Build Script ===${NC}"

# Setup RPM build environment
if [ ! -d "$RPMBUILD_DIR" ]; then
    echo "Setting up RPM build directories..."
    mkdir -p "$RPMBUILD_DIR"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
fi

# Function to build a package
build_package() {
    local spec_file="$1"
    local package_name=$(basename "$spec_file" .spec)
    
    echo -e "${GREEN}Building package: $package_name${NC}"
    
    # Copy spec file to SPECS
    cp "$spec_file" "$RPMBUILD_DIR/SPECS/"
    
    # Prepare sources
    if [ -d "$PACKAGES_DIR/$package_name" ]; then
        tar -czf "$RPMBUILD_DIR/SOURCES/$package_name.tar.gz" \
            -C "$PACKAGES_DIR" "$package_name" || true
    fi
    
    # Build the package
    rpmbuild -ba "$RPMBUILD_DIR/SPECS/$package_name.spec" || {
        echo -e "${RED}Failed to build $package_name${NC}"
        return 1
    }
    
    echo -e "${GREEN}Successfully built $package_name${NC}"
}

# Build all packages
if [ -d "$PACKAGES_DIR" ]; then
    for spec_file in "$PACKAGES_DIR"/*/*.spec; do
        if [ -f "$spec_file" ]; then
            build_package "$spec_file"
        fi
    done
else
    echo -e "${YELLOW}No packages directory found. Skipping package build.${NC}"
fi

echo -e "${GREEN}Package build complete!${NC}"
echo "Built packages are in: $RPMBUILD_DIR/RPMS/"

