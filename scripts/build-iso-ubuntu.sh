#!/bin/bash
#
# VaultOS ISO Build Script for Ubuntu
# Uses Docker to run Fedora build tools on Ubuntu
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
KICKSTART_FILE="$BUILD_DIR/kickstart/vaultos.ks"
OUTPUT_DIR="$PROJECT_ROOT/iso"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  VaultOS ISO Build (Ubuntu/Docker)    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""

# Check for Docker
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}Error: Docker is required but not installed${NC}"
        echo ""
        echo "Install Docker on Ubuntu:"
        echo "  sudo apt-get update"
        echo "  sudo apt-get install docker.io"
        echo "  sudo systemctl start docker"
        echo "  sudo systemctl enable docker"
        echo "  sudo usermod -aG docker $USER"
        echo ""
        echo -e "${YELLOW}Note: After adding yourself to docker group, log out and back in.${NC}"
        exit 1
    fi
    
    # Check if Docker daemon is running
    if ! docker info &> /dev/null; then
        echo -e "${RED}Error: Docker daemon is not running${NC}"
        echo "Start Docker: sudo systemctl start docker"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Docker is available${NC}"
}

# Create necessary directories
setup_directories() {
    echo -e "${BLUE}Setting up directories...${NC}"
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$BUILD_DIR/repo"
    echo -e "${GREEN}✓ Directories ready${NC}"
}

# Build ISO using Docker
build_iso_docker() {
    echo -e "${BLUE}Preparing Fedora build container...${NC}"
    
    # Check if Fedora container image exists
    if ! docker images | grep -q "fedora:latest"; then
        echo -e "${YELLOW}Pulling Fedora Docker image (this may take a few minutes)...${NC}"
        docker pull fedora:latest
    fi
    
    echo -e "${GREEN}✓ Fedora image ready${NC}"
    echo ""
    echo -e "${BLUE}Building ISO in Docker container...${NC}"
    echo -e "${YELLOW}This will take 15-30 minutes depending on your system...${NC}"
    echo ""
    
    # Build ISO using Docker container
    docker run --rm -it \
        --privileged \
        -v "$PROJECT_ROOT:/vaultos:rw" \
        -w /vaultos \
        fedora:latest \
        bash -c "
            set -e
            
            # Install build tools
            echo '[1/5] Installing build tools...'
            dnf install -y --allowerasing \
                lorax \
                lorax-templates-generic \
                livemedia-creator \
                createrepo_c \
                rpm-build \
                mock \
                genisoimage \
                isomd5sum \
                syslinux \
                grub2-efi \
                dosfstools \
                e2fsprogs \
                > /dev/null 2>&1 || {
                echo 'Failed to install build tools'
                exit 1
            }
            
            # Check for kickstart file
            if [ ! -f /vaultos/build/kickstart/vaultos.ks ]; then
                echo 'Error: Kickstart file not found at /vaultos/build/kickstart/vaultos.ks'
                exit 1
            fi
            
            echo '[2/5] Setting up build environment...'
            mkdir -p /vaultos/iso
            cd /vaultos
            
            # Create a minimal package repository structure if needed
            if [ ! -d /vaultos/build/repo ]; then
                mkdir -p /vaultos/build/repo
                createrepo_c /vaultos/build/repo > /dev/null 2>&1 || true
            fi
            
            echo '[3/5] Building ISO (this may take 10-20 minutes)...'
            ISO_NAME=\"VaultOS-\$(date +%Y%m%d).iso\"
            RELEASEVER=\"40\"
            
            # Build ISO with livemedia-creator
            livemedia-creator \\
                --make-iso \\
                --iso-size=4096 \\
                --ks=/vaultos/build/kickstart/vaultos.ks \\
                --iso-name=\"\$ISO_NAME\" \\
                --project=\"VaultOS\" \\
                --releasever=\"\$RELEASEVER\" \\
                --volid=\"VaultOS\" \\
                --nomacboot \\
                --no-virt \\
                --logfile=/vaultos/build/iso-build.log || {
                echo 'Failed to create ISO'
                echo 'Check log: /vaultos/build/iso-build.log'
                exit 1
            }
            
            echo '[4/5] Moving ISO to output directory...'
            # Move ISO to output directory
            if [ -f \"\$ISO_NAME\" ]; then
                mv \"\$ISO_NAME\" /vaultos/iso/
                echo \"[5/5] ISO created successfully: /vaultos/iso/\$ISO_NAME\"
                
                # Show ISO info
                ISO_SIZE=\$(du -h /vaultos/iso/\$ISO_NAME | cut -f1)
                echo \"ISO Size: \$ISO_SIZE\"
            else
                echo 'Error: ISO file not found after build'
                exit 1
            fi
        "
}

# Main execution
main() {
    check_docker
    setup_directories
    
    echo ""
    build_iso_docker
    
    echo ""
    # Check if ISO was created
    ISO_FILE=$(ls -t "$OUTPUT_DIR"/*.iso 2>/dev/null | head -1)
    
    if [ -n "$ISO_FILE" ] && [ -f "$ISO_FILE" ]; then
        SIZE=$(du -h "$ISO_FILE" | cut -f1)
        echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║  ISO Build Successful!                 ║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
        echo ""
        echo -e "ISO File: ${BLUE}$ISO_FILE${NC}"
        echo -e "Size: ${BLUE}$SIZE${NC}"
        echo ""
        echo "You can now:"
        echo "  - Test in QEMU: qemu-system-x86_64 -cdrom \"$ISO_FILE\" -m 2048"
        echo "  - Write to USB: sudo dd if=\"$ISO_FILE\" of=/dev/sdX bs=4M status=progress"
        echo "  - Burn to DVD: Use your preferred burning software"
    else
        echo -e "${RED}╔════════════════════════════════════════╗${NC}"
        echo -e "${RED}║  ISO Build Failed                      ║${NC}"
        echo -e "${RED}╚════════════════════════════════════════╝${NC}"
        echo ""
        if [ -f "$BUILD_DIR/iso-build.log" ]; then
            echo "Check build log: $BUILD_DIR/iso-build.log"
        fi
        exit 1
    fi
}

main "$@"
