#!/bin/bash
# VaultOS Repository Manager
# Enhanced RPM repository with signing and delta updates

set -e

REPO_DIR="/var/www/html/vaultos-repo"
GPG_KEY_NAME="VaultOS Repository"
GPG_KEY_EMAIL="repo@vaultos.org"

# Initialize repository
init_repo() {
    if [ "$EUID" -ne 0 ]; then
        echo "Error: This script must be run as root"
        exit 1
    fi
    
    mkdir -p "$REPO_DIR"
    
    # Create repository structure
    createrepo "$REPO_DIR"
    
    # Generate GPG key if not exists
    if ! gpg --list-secret-keys "$GPG_KEY_EMAIL" &> /dev/null; then
        echo "Generating GPG key for repository..."
        gpg --batch --gen-key << EOF
Key-Type: RSA
Key-Length: 2048
Name-Real: $GPG_KEY_NAME
Name-Email: $GPG_KEY_EMAIL
Expire-Date: 0
%commit
EOF
    fi
    
    echo "Repository initialized: $REPO_DIR"
}

# Add package to repository
add_package() {
    local package="$1"
    
    if [ -z "$package" ]; then
        echo "Usage: $0 add <package.rpm>"
        exit 1
    fi
    
    if [ ! -f "$package" ]; then
        echo "Error: Package not found: $package"
        exit 1
    fi
    
    # Sign package
    echo "Signing package..."
    rpm --addsign "$package"
    
    # Copy to repository
    cp "$package" "$REPO_DIR/"
    
    # Update repository
    createrepo --update "$REPO_DIR"
    
    # Sign repository metadata
    gpg --detach-sign --armor "$REPO_DIR/repodata/repomd.xml"
    
    echo "Package added to repository"
}

# Update repository
update_repo() {
    echo "Updating repository..."
    
    createrepo --update "$REPO_DIR"
    gpg --detach-sign --armor "$REPO_DIR/repodata/repomd.xml"
    
    echo "Repository updated"
}

# Export GPG key
export_key() {
    local key_file="$REPO_DIR/RPM-GPG-KEY-VaultOS"
    
    gpg --export -a "$GPG_KEY_EMAIL" > "$key_file"
    
    echo "GPG key exported: $key_file"
    echo "Users should import this key: rpm --import $key_file"
}

# Show menu
show_menu() {
    clear
    echo "VaultOS Repository Manager"
    echo ""
    echo "1) Initialize repository"
    echo "2) Add package"
    echo "3) Update repository"
    echo "4) Export GPG key"
    echo "5) Exit"
}

# Main
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root"
    exit 1
fi

if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
        show_menu
        read -p "Choice: " choice
        case $choice in
            1) init_repo;;
            2) read -p "Package file: " package; add_package "$package";;
            3) update_repo;;
            4) export_key;;
            5) exit 0;;
            *) echo "Invalid choice";;
        esac
    done
else
    # Command-line mode
    case "$1" in
        init) init_repo;;
        add) add_package "$2";;
        update) update_repo;;
        export-key) export_key;;
        *) echo "Usage: $0 {init|add|update|export-key}"; exit 1;;
    esac
fi

