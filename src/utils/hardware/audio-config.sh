#!/bin/bash
#
# VaultOS Audio Device Management
# Configure audio devices and settings
#

GREEN='\033[0;32m'
RESET='\033[0m'

list_audio_devices() {
    if command -v pactl &> /dev/null; then
        pactl list short sinks
    elif command -v alsamixer &> /dev/null; then
        aplay -l
    fi
}

set_default_output() {
    local device=$1
    
    if command -v pactl &> /dev/null; then
        pactl set-default-sink "$device"
        echo "Default output set to: $device"
    elif command -v alsamixer &> /dev/null; then
        # ALSA configuration
        echo "Set default device in ~/.asoundrc"
    fi
}

get_volume() {
    if command -v pactl &> /dev/null; then
        pactl get-sink-volume @DEFAULT_SINK@ | head -1
    elif command -v amixer &> /dev/null; then
        amixer get Master | grep -o '[0-9]*%' | head -1
    fi
}

set_volume() {
    local volume=$1
    
    if command -v pactl &> /dev/null; then
        pactl set-sink-volume @DEFAULT_SINK@ "$volume%"
        echo "Volume set to: $volume%"
    elif command -v amixer &> /dev/null; then
        amixer set Master "$volume%"
        echo "Volume set to: $volume%"
    fi
}

toggle_mute() {
    if command -v pactl &> /dev/null; then
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        echo "Mute toggled"
    elif command -v amixer &> /dev/null; then
        amixer set Master toggle
        echo "Mute toggled"
    fi
}

show_menu() {
    clear
    echo -e "${GREEN}╔════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║   VaultOS Audio Configuration      ║${RESET}"
    echo -e "${GREEN}╚════════════════════════════════════╝${RESET}"
    echo ""
    echo "1) List audio devices"
    echo "2) Set default output"
    echo "3) Get volume"
    echo "4) Set volume"
    echo "5) Toggle mute"
    echo "6) Exit"
    echo ""
}

# Main
while true; do
    show_menu
    read -p "Choice [1-6]: " choice
    
    case $choice in
        1)
            echo "Audio devices:"
            list_audio_devices
            read -p "Press Enter to continue..."
            ;;
        2)
            list_audio_devices
            read -p "Device name: " device
            set_default_output "$device"
            read -p "Press Enter to continue..."
            ;;
        3)
            echo "Current volume:"
            get_volume
            read -p "Press Enter to continue..."
            ;;
        4)
            read -p "Volume (0-100): " volume
            set_volume "$volume"
            read -p "Press Enter to continue..."
            ;;
        5)
            toggle_mute
            read -p "Press Enter to continue..."
            ;;
        6)
            exit 0
            ;;
    esac
done
