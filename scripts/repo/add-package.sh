#!/bin/bash
#
# Add Package to VaultOS Repository
# Copies RPM package to repository and updates metadata
#

set -e

REPO_DIR="${1:-/var/www/html/vaultos-repo}"
PACKAGE="${2}"

if [ -z "$PACKAGE" ]; then
    echo "Usage: $0 [repo_dir] <package.rpm>"
    echo "Example: $0 /var/www/html/vaultos-repo vaultos-themes-1.0.0-1.fc38.x86_64.rpm"
    exit 1
fi

if [ ! -f "$PACKAGE" ]; then
    echo "Error: Package file not found: $PACKAGE"
    exit 1
fi

if [ ! -d "$REPO_DIR" ]; then
    echo "Error: Repository directory not found: $REPO_DIR"
    exit 1
fi

# Determine architecture
ARCH=$(rpm -qp --qf "%{ARCH}" "$PACKAGE" 2>/dev/null || echo "noarch")
PACKAGE_TYPE=$(rpm -qp --qf "%{NAME}" "$PACKAGE" 2>/dev/null | grep -q "\.src\.rpm$" && echo "SRPMS" || echo "$ARCH")

# Copy package to appropriate directory
if [ "$PACKAGE_TYPE" = "SRPMS" ]; then
    DEST_DIR="$REPO_DIR/SRPMS"
else
    DEST_DIR="$REPO_DIR/$PACKAGE_TYPE"
fi

echo "Adding $PACKAGE to repository..."
cp "$PACKAGE" "$DEST_DIR/"

# Update repository metadata
cd "$REPO_DIR"
if command -v createrepo_c &> /dev/null; then
    createrepo_c --update .
elif command -v createrepo &> /dev/null; then
    createrepo --update .
else
    echo "Warning: createrepo not found. Metadata not updated."
    echo "Install with: dnf install createrepo_c"
fi

echo "Package added successfully to $DEST_DIR"

