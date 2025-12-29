#!/bin/bash
#
# VaultOS Build Automation Script
# Automated build and testing pipeline
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/../build"
LOG_DIR="$BUILD_DIR/logs"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
RESET='\033[0m'

log() {
    echo -e "${GREEN}[$(date +%H:%M:%S)]${RESET} $1"
}

error() {
    echo -e "${RED}[ERROR]${RESET} $1" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${RESET} $1"
}

# Create directories
mkdir -p "$LOG_DIR"

# Check dependencies
check_dependencies() {
    log "Checking build dependencies..."
    local missing=0
    
    for cmd in rpmbuild mock createrepo_c; do
        if ! command -v $cmd &> /dev/null; then
            error "$cmd not found"
            missing=1
        fi
    done
    
    if [ $missing -eq 1 ]; then
        error "Missing required dependencies. Install with:"
        echo "  sudo dnf install rpm-build mock createrepo_c"
        exit 1
    fi
    
    log "All dependencies satisfied"
}

# Build packages
build_packages() {
    log "Building RPM packages..."
    cd "$SCRIPT_DIR"
    if [ -f build-packages.sh ]; then
        ./build-packages.sh 2>&1 | tee "$LOG_DIR/build-packages-$TIMESTAMP.log"
    else
        error "build-packages.sh not found"
        exit 1
    fi
}

# Build ISO
build_iso() {
    log "Building ISO image..."
    cd "$SCRIPT_DIR"
    if [ -f build-iso.sh ]; then
        ./build-iso.sh 2>&1 | tee "$LOG_DIR/build-iso-$TIMESTAMP.log"
    else
        warning "build-iso.sh not found, skipping ISO build"
    fi
}

# Run tests
run_tests() {
    log "Running tests..."
    cd "$SCRIPT_DIR"
    if [ -f validate-scripts.sh ]; then
        ./validate-scripts.sh 2>&1 | tee "$LOG_DIR/validate-$TIMESTAMP.log"
    else
        warning "validate-scripts.sh not found, skipping validation"
    fi
}

# Generate build report
generate_report() {
    log "Generating build report..."
    REPORT_FILE="$LOG_DIR/build-report-$TIMESTAMP.txt"
    
    cat > "$REPORT_FILE" <<EOF
VaultOS Build Report
====================
Date: $(date)
Timestamp: $TIMESTAMP

Build Artifacts:
EOF

    if [ -d ~/rpmbuild/RPMS ]; then
        echo "RPM Packages:" >> "$REPORT_FILE"
        find ~/rpmbuild/RPMS -name "*.rpm" >> "$REPORT_FILE"
    fi
    
    if [ -d "$BUILD_DIR" ]; then
        echo "" >> "$REPORT_FILE"
        echo "ISO Images:" >> "$REPORT_FILE"
        find "$BUILD_DIR" -name "*.iso" >> "$REPORT_FILE"
    fi
    
    log "Build report saved to: $REPORT_FILE"
}

# Main
main() {
    log "Starting VaultOS automated build..."
    
    check_dependencies
    build_packages
    build_iso
    run_tests
    generate_report
    
    log "Build completed successfully!"
}

main "$@"

