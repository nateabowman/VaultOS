#!/bin/bash
#
# Update VaultOS RPM Repository
# Updates repository metadata after adding packages
#

set -e

REPO_DIR="${1:-/var/www/html/vaultos-repo}"

if [ ! -d "$REPO_DIR" ]; then
    echo "Error: Repository directory not found: $REPO_DIR"
    echo "Run create-repo.sh first"
    exit 1
fi

echo "Updating repository metadata at $REPO_DIR..."

cd "$REPO_DIR"

# Update repository metadata
if command -v createrepo_c &> /dev/null; then
    createrepo_c --update .
elif command -v createrepo &> /dev/null; then
    createrepo --update .
else
    echo "Error: createrepo not found. Install with: dnf install createrepo_c"
    exit 1
fi

echo "Repository metadata updated successfully"

