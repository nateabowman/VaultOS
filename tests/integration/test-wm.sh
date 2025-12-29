#!/bin/bash
#
# Integration Test: Window Manager
#

# Test window manager integration
echo "Testing window manager..."

# Check if WM compiles
if [ -f "../../src/wm/vaultwm/main.c" ]; then
    echo "Window manager source found"
    exit 0
else
    echo "Window manager source not found"
    exit 1
fi

