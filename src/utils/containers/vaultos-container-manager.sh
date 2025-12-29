#!/bin/bash
# VaultOS Container Management Tool
# Provides unified interface for Podman and Docker

set -e

CONTAINER_RUNTIME=""
CONTAINER_CMD=""

# Detect container runtime
detect_runtime() {
    if command -v podman &> /dev/null; then
        CONTAINER_RUNTIME="podman"
        CONTAINER_CMD="podman"
    elif command -v docker &> /dev/null; then
        CONTAINER_RUNTIME="docker"
        CONTAINER_CMD="docker"
    else
        echo "Error: No container runtime found (podman or docker required)"
        exit 1
    fi
}

# List containers
list_containers() {
    $CONTAINER_CMD ps -a
}

# Start container
start_container() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "Usage: $0 start <container_name>"
        exit 1
    fi
    $CONTAINER_CMD start "$name"
}

# Stop container
stop_container() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "Usage: $0 stop <container_name>"
        exit 1
    fi
    $CONTAINER_CMD stop "$name"
}

# Create VaultOS container
create_vaultos_container() {
    local name="${1:-vaultos}"
    local image="${2:-vaultos:latest}"
    
    echo "Creating VaultOS container: $name"
    
    $CONTAINER_CMD run -d \
        --name "$name" \
        --hostname vaultos \
        -v "$HOME:/home/user" \
        -v /tmp/.X11-unix:/tmp/.X11-unix:rw \
        -e DISPLAY="$DISPLAY" \
        "$image" || {
        echo "Error: Failed to create container"
        exit 1
    }
    
    echo "Container '$name' created successfully"
}

# Build VaultOS container image
build_vaultos_image() {
    local tag="${1:-vaultos:latest}"
    local dockerfile="${2:-Dockerfile.vaultos}"
    
    if [ ! -f "$dockerfile" ]; then
        echo "Error: Dockerfile not found: $dockerfile"
        exit 1
    fi
    
    echo "Building VaultOS container image: $tag"
    $CONTAINER_CMD build -t "$tag" -f "$dockerfile" .
    echo "Image built successfully"
}

# Execute command in container
exec_in_container() {
    local name="$1"
    shift
    if [ -z "$name" ] || [ $# -eq 0 ]; then
        echo "Usage: $0 exec <container_name> <command> [args...]"
        exit 1
    fi
    $CONTAINER_CMD exec "$name" "$@"
}

# Show container logs
show_logs() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "Usage: $0 logs <container_name>"
        exit 1
    fi
    $CONTAINER_CMD logs "$name"
}

# Remove container
remove_container() {
    local name="$1"
    if [ -z "$name" ]; then
        echo "Usage: $0 remove <container_name>"
        exit 1
    fi
    $CONTAINER_CMD rm "$name"
}

# Show menu
show_menu() {
    clear
    echo "VaultOS Container Manager"
    echo "Runtime: $CONTAINER_RUNTIME"
    echo ""
    echo "1) List containers"
    echo "2) Start container"
    echo "3) Stop container"
    echo "4) Create VaultOS container"
    echo "5) Build VaultOS image"
    echo "6) Execute command in container"
    echo "7) Show container logs"
    echo "8) Remove container"
    echo "9) Exit"
}

# Main
detect_runtime

if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
        show_menu
        read -p "Choice: " choice
        case $choice in
            1) list_containers; read -p "Press Enter to continue...";;
            2) read -p "Container name: " name; start_container "$name";;
            3) read -p "Container name: " name; stop_container "$name";;
            4) read -p "Container name [vaultos]: " name; create_vaultos_container "$name";;
            5) read -p "Image tag [vaultos:latest]: " tag; build_vaultos_image "$tag";;
            6) read -p "Container name: " name; read -p "Command: " cmd; exec_in_container "$name" $cmd;;
            7) read -p "Container name: " name; show_logs "$name";;
            8) read -p "Container name: " name; remove_container "$name";;
            9) exit 0;;
            *) echo "Invalid choice";;
        esac
    done
else
    # Command-line mode
    case "$1" in
        list) list_containers;;
        start) start_container "$2";;
        stop) stop_container "$2";;
        create) create_vaultos_container "$2" "$3";;
        build) build_vaultos_image "$2" "$3";;
        exec) shift; exec_in_container "$@";;
        logs) show_logs "$2";;
        remove) remove_container "$2";;
        *) echo "Usage: $0 {list|start|stop|create|build|exec|logs|remove}"; exit 1;;
    esac
fi

