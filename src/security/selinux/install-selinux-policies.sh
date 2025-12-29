#!/bin/bash
# Install VaultOS SELinux policies

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POLICY_DIR="$SCRIPT_DIR"

if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root"
    exit 1
fi

# Check for SELinux
if ! command -v semodule &> /dev/null; then
    echo "Error: SELinux tools not found. Install with: sudo dnf install policycoreutils-python-utils"
    exit 1
fi

# Check SELinux status
if [ "$(getenforce)" != "Enforcing" ] && [ "$(getenforce)" != "Permissive" ]; then
    echo "Warning: SELinux is disabled"
fi

echo "Installing VaultOS SELinux policies..."

# Compile and install policy
cd "$POLICY_DIR"
checkmodule -M -m -o vaultos.mod vaultos.te
semodule_package -o vaultos.pp -m vaultos.mod
semodule -i vaultos.pp

echo "SELinux policies installed successfully"
echo ""
echo "To verify: semodule -l | grep vaultos"
echo "To remove: semodule -r vaultos"

