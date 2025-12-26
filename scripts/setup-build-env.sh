#!/bin/bash
# VaultOS Build Environment Setup Script
# Installs required tools and dependencies for building VaultOS

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== VaultOS Build Environment Setup ===${NC}"

# Check if running as root for package installation
if [ "$EUID" -ne 0 ]; then 
    echo -e "${YELLOW}Note: Some operations require root privileges${NC}"
    echo "Run with sudo for full setup, or install packages manually"
fi

# Check for Fedora
if [ ! -f /etc/fedora-release ]; then
    echo -e "${RED}Error: This script is designed for Fedora Linux${NC}"
    exit 1
fi

# Install build tools
echo "Installing build tools..."
if [ "$EUID" -eq 0 ]; then
    dnf install -y \
        lorax \
        lorax-templates-generic \
        livemedia-creator \
        rpm-build \
        rpmdevtools \
        mock \
        createrepo \
        gcc \
        gcc-c++ \
        make \
        cmake \
        pkgconfig \
        git \
        fontforge \
        imagemagick \
        gimp \
        || echo -e "${YELLOW}Some packages may have failed to install${NC}"
else
    echo -e "${YELLOW}Run as root to install packages:${NC}"
    echo "sudo dnf install lorax lorax-templates-generic livemedia-creator rpm-build rpmdevtools mock createrepo gcc gcc-c++ make cmake pkgconfig git fontforge imagemagick gimp"
fi

# Setup RPM build directories
echo "Setting up RPM build directories..."
mkdir -p "$HOME/rpmbuild"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}

# Create mock configuration if needed
if [ "$EUID" -eq 0 ] && command -v mock &> /dev/null; then
    echo "Setting up mock build environment..."
    usermod -a -G mock "$SUDO_USER" 2>/dev/null || true
fi

echo -e "${GREEN}Build environment setup complete!${NC}"

