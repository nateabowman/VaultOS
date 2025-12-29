#!/bin/bash
#
# Setup script for building VaultOS ISO on Ubuntu
# Installs Docker and prepares the build environment
#

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  VaultOS Build Environment Setup       ║${NC}"
echo -e "${GREEN}║  For Ubuntu                            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if running as root for Docker installation
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Please run this script as a regular user (not root)${NC}"
    exit 1
fi

# Check if Docker is already installed
if command -v docker &> /dev/null; then
    if docker info &> /dev/null; then
        echo -e "${GREEN}✓ Docker is already installed and running${NC}"
        echo ""
        echo "You can now build the ISO:"
        echo "  ./scripts/build-iso-ubuntu.sh"
        exit 0
    else
        echo -e "${YELLOW}Docker is installed but daemon is not running${NC}"
        echo "Starting Docker daemon..."
        sudo systemctl start docker || {
            echo -e "${RED}Failed to start Docker. Please check Docker installation.${NC}"
            exit 1
        }
        echo -e "${GREEN}✓ Docker daemon started${NC}"
        exit 0
    fi
fi

# Install Docker
echo -e "${BLUE}Installing Docker...${NC}"
echo ""

# Update package list
echo "Updating package list..."
sudo apt-get update

# Install Docker
echo "Installing Docker..."
sudo apt-get install -y docker.io

# Start Docker service
echo "Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
echo "Adding $USER to docker group..."
sudo usermod -aG docker "$USER"

echo ""
echo -e "${GREEN}✓ Docker installed successfully!${NC}"
echo ""
echo -e "${YELLOW}Important: You need to log out and log back in (or restart)${NC}"
echo -e "${YELLOW}for the docker group membership to take effect.${NC}"
echo ""
echo "After logging back in, you can build the ISO with:"
echo -e "${BLUE}  ./scripts/build-iso-ubuntu.sh${NC}"
echo ""
echo "Or test Docker now with:"
echo -e "${BLUE}  newgrp docker${NC}"
echo -e "${BLUE}  docker run hello-world${NC}"

