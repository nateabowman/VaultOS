#!/bin/bash
# VaultOS Virtual Machine Management Tool
# QEMU/KVM integration for VaultOS

set -e

VM_DIR="$HOME/.vaultos/vms"
QEMU_CMD="qemu-system-x86_64"

# Check for QEMU/KVM
check_qemu() {
    if ! command -v $QEMU_CMD &> /dev/null; then
        echo "Error: QEMU not found. Install with: sudo dnf install qemu-system-x86"
        exit 1
    fi
    
    if [ ! -c /dev/kvm ]; then
        echo "Warning: /dev/kvm not found. KVM acceleration may not be available"
    fi
}

# Create VM
create_vm() {
    local name="$1"
    local disk_size="${2:-20G}"
    local memory="${3:-2048}"
    
    if [ -z "$name" ]; then
        echo "Usage: $0 create <vm_name> [disk_size] [memory_mb]"
        exit 1
    fi
    
    mkdir -p "$VM_DIR/$name"
    local disk_file="$VM_DIR/$name/disk.qcow2"
    
    # Create disk image
    if [ ! -f "$disk_file" ]; then
        qemu-img create -f qcow2 "$disk_file" "$disk_size"
        echo "Created disk image: $disk_file"
    fi
    
    # Create VM configuration
    cat > "$VM_DIR/$name/vm.conf" << EOF
VM_NAME=$name
DISK_FILE=$disk_file
MEMORY=$memory
VCPU=2
EOF
    
    echo "VM '$name' created successfully"
    echo "Disk: $disk_file"
    echo "Memory: ${memory}MB"
}

# Start VM
start_vm() {
    local name="$1"
    local iso="${2:-}"
    
    if [ -z "$name" ]; then
        echo "Usage: $0 start <vm_name> [iso_file]"
        exit 1
    fi
    
    local vm_dir="$VM_DIR/$name"
    if [ ! -d "$vm_dir" ]; then
        echo "Error: VM '$name' not found"
        exit 1
    fi
    
    source "$vm_dir/vm.conf"
    
    local cmd="$QEMU_CMD"
    cmd="$cmd -name $VM_NAME"
    cmd="$cmd -m $MEMORY"
    cmd="$cmd -smp $VCPU"
    cmd="$cmd -drive file=$DISK_FILE,format=qcow2"
    
    if [ -n "$iso" ] && [ -f "$iso" ]; then
        cmd="$cmd -cdrom $iso"
        cmd="$cmd -boot d"
    fi
    
    # Enable KVM if available
    if [ -c /dev/kvm ]; then
        cmd="$cmd -enable-kvm"
    fi
    
    # VGA and network
    cmd="$cmd -vga std"
    cmd="$cmd -netdev user,id=net0 -device virtio-net,netdev=net0"
    
    echo "Starting VM: $name"
    echo "Command: $cmd"
    $cmd &
}

# List VMs
list_vms() {
    if [ ! -d "$VM_DIR" ]; then
        echo "No VMs found"
        return
    fi
    
    echo "Available VMs:"
    for vm in "$VM_DIR"/*; do
        if [ -d "$vm" ]; then
            echo "  - $(basename "$vm")"
        fi
    done
}

# Remove VM
remove_vm() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "Usage: $0 remove <vm_name>"
        exit 1
    fi
    
    local vm_dir="$VM_DIR/$name"
    if [ ! -d "$vm_dir" ]; then
        echo "Error: VM '$name' not found"
        exit 1
    fi
    
    read -p "Remove VM '$name' and all data? (y/N): " confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        rm -rf "$vm_dir"
        echo "VM '$name' removed"
    fi
}

# Show menu
show_menu() {
    clear
    echo "VaultOS VM Manager"
    echo ""
    echo "1) Create VM"
    echo "2) Start VM"
    echo "3) List VMs"
    echo "4) Remove VM"
    echo "5) Exit"
}

# Main
check_qemu

if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
        show_menu
        read -p "Choice: " choice
        case $choice in
            1) read -p "VM name: " name; read -p "Disk size [20G]: " size; read -p "Memory MB [2048]: " mem; create_vm "$name" "${size:-20G}" "${mem:-2048}";;
            2) read -p "VM name: " name; read -p "ISO file (optional): " iso; start_vm "$name" "$iso";;
            3) list_vms; read -p "Press Enter to continue...";;
            4) read -p "VM name: " name; remove_vm "$name";;
            5) exit 0;;
            *) echo "Invalid choice";;
        esac
    done
else
    # Command-line mode
    case "$1" in
        create) create_vm "$2" "$3" "$4";;
        start) start_vm "$2" "$3";;
        list) list_vms;;
        remove) remove_vm "$2";;
        *) echo "Usage: $0 {create|start|list|remove}"; exit 1;;
    esac
fi

