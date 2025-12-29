#!/bin/bash
#
# Create VaultOS RPM Repository
# Sets up local or remote RPM repository structure
#

set -e

REPO_DIR="${1:-/var/www/html/vaultos-repo}"
REPO_NAME="vaultos"

echo "Creating VaultOS RPM repository at $REPO_DIR..."

# Create directory structure
mkdir -p "$REPO_DIR"/{SRPMS,x86_64,noarch,repodata}

# Create repository metadata
cd "$REPO_DIR"
createrepo_c . 2>/dev/null || createrepo . 2>/dev/null || {
    echo "Warning: createrepo not found. Install with: dnf install createrepo_c"
    echo "Repository structure created but metadata not generated."
}

# Create repository configuration file
cat > "$REPO_DIR/vaultos.repo" <<EOF
[vaultos]
name=VaultOS Repository
baseurl=file://$REPO_DIR
enabled=1
gpgcheck=0
EOF

echo ""
echo "Repository created at: $REPO_DIR"
echo ""
echo "To use this repository:"
echo "  sudo cp $REPO_DIR/vaultos.repo /etc/yum.repos.d/"
echo "  sudo dnf makecache"
echo ""
echo "To add packages to the repository:"
echo "  cp *.rpm $REPO_DIR/x86_64/"
echo "  cd $REPO_DIR"
echo "  createrepo_c ."

