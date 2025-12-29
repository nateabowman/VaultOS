#!/bin/bash
# VaultOS Remote Management Tool
# SSH key management, remote desktop, configuration management

set -e

SSH_DIR="$HOME/.ssh"
REMOTE_CONFIG_DIR="$HOME/.vaultos/remote"

# Initialize remote management
init_remote() {
    mkdir -p "$REMOTE_CONFIG_DIR"
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    echo "Remote management initialized"
}

# Generate SSH key
generate_ssh_key() {
    local key_name="${1:-vaultos_key}"
    local key_file="$SSH_DIR/$key_name"
    
    if [ -f "$key_file" ]; then
        read -p "Key already exists. Overwrite? (y/N): " confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            return
        fi
    fi
    
    ssh-keygen -t ed25519 -f "$key_file" -C "vaultos-$(hostname)-$(date +%Y%m%d)"
    echo "SSH key generated: $key_file"
    echo "Public key: $key_file.pub"
}

# Add remote host
add_remote_host() {
    local name="$1"
    local host="$2"
    local user="${3:-$USER}"
    
    if [ -z "$name" ] || [ -z "$host" ]; then
        echo "Usage: $0 add-host <name> <host> [user]"
        exit 1
    fi
    
    local config_file="$REMOTE_CONFIG_DIR/$name.conf"
    cat > "$config_file" << EOF
REMOTE_NAME=$name
REMOTE_HOST=$host
REMOTE_USER=$user
EOF
    
    echo "Remote host added: $name ($user@$host)"
}

# Connect to remote host
connect_remote() {
    local name="$1"
    local config_file="$REMOTE_CONFIG_DIR/$name.conf"
    
    if [ ! -f "$config_file" ]; then
        echo "Error: Remote host '$name' not found"
        exit 1
    fi
    
    source "$config_file"
    ssh "$REMOTE_USER@$REMOTE_HOST"
}

# Setup remote desktop (VNC)
setup_vnc() {
    local name="$1"
    local port="${2:-5900}"
    
    if ! command -v vncserver &> /dev/null; then
        echo "Error: VNC server not installed. Install with: sudo dnf install tigervnc-server"
        exit 1
    fi
    
    echo "Setting up VNC server on port $port"
    vncserver :$((port - 5900)) -geometry 1920x1080 -depth 24
    echo "VNC server started on :$((port - 5900))"
}

# Setup RDP
setup_rdp() {
    if ! command -v xrdp &> /dev/null; then
        echo "Error: xrdp not installed. Install with: sudo dnf install xrdp"
        exit 1
    fi
    
    echo "Setting up RDP server"
    sudo systemctl enable --now xrdp
    echo "RDP server enabled"
}

# Ansible integration
setup_ansible() {
    if ! command -v ansible &> /dev/null; then
        echo "Installing Ansible..."
        sudo dnf install -y ansible
    fi
    
    local inventory_file="$REMOTE_CONFIG_DIR/ansible_inventory"
    if [ ! -f "$inventory_file" ]; then
        cat > "$inventory_file" << EOF
# VaultOS Ansible Inventory
[vaultos_hosts]
# Add your hosts here
# Example:
# host1 ansible_host=192.168.1.100 ansible_user=vaultdweller
EOF
        echo "Ansible inventory created: $inventory_file"
    fi
    
    echo "Ansible ready. Inventory: $inventory_file"
}

# Show menu
show_menu() {
    clear
    echo "VaultOS Remote Management"
    echo ""
    echo "1) Initialize remote management"
    echo "2) Generate SSH key"
    echo "3) Add remote host"
    echo "4) Connect to remote host"
    echo "5) Setup VNC server"
    echo "6) Setup RDP server"
    echo "7) Setup Ansible"
    echo "8) Exit"
}

# Main
if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
        show_menu
        read -p "Choice: " choice
        case $choice in
            1) init_remote;;
            2) read -p "Key name [vaultos_key]: " name; generate_ssh_key "${name:-vaultos_key}";;
            3) read -p "Host name: " name; read -p "Host address: " host; read -p "User [$(whoami)]: " user; add_remote_host "$name" "$host" "${user:-$(whoami)}";;
            4) read -p "Host name: " name; connect_remote "$name";;
            5) read -p "VNC port [5900]: " port; setup_vnc "" "${port:-5900}";;
            6) setup_rdp;;
            7) setup_ansible;;
            8) exit 0;;
            *) echo "Invalid choice";;
        esac
    done
else
    # Command-line mode
    case "$1" in
        init) init_remote;;
        keygen) generate_ssh_key "$2";;
        add-host) add_remote_host "$2" "$3" "$4";;
        connect) connect_remote "$2";;
        vnc) setup_vnc "$2" "$3";;
        rdp) setup_rdp;;
        ansible) setup_ansible;;
        *) echo "Usage: $0 {init|keygen|add-host|connect|vnc|rdp|ansible}"; exit 1;;
    esac
fi

