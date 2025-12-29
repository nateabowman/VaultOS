#!/bin/bash
#
# Recent Applications Tracker
# Tracks recently used applications
#

RECENT_FILE="$HOME/.local/share/vaultos/recent-apps"
MAX_RECENT=20

# Create directory if it doesn't exist
mkdir -p "$(dirname "$RECENT_FILE")"

# Add application to recent list
add_recent() {
    local app="$1"
    
    if [ -z "$app" ]; then
        return
    fi
    
    # Remove if already exists
    if [ -f "$RECENT_FILE" ]; then
        grep -v "^$app$" "$RECENT_FILE" > "${RECENT_FILE}.tmp"
        mv "${RECENT_FILE}.tmp" "$RECENT_FILE"
    fi
    
    # Add to top
    echo "$app" > "${RECENT_FILE}.tmp"
    if [ -f "$RECENT_FILE" ]; then
        cat "$RECENT_FILE" >> "${RECENT_FILE}.tmp"
    fi
    mv "${RECENT_FILE}.tmp" "$RECENT_FILE"
    
    # Limit to MAX_RECENT entries
    head -n "$MAX_RECENT" "$RECENT_FILE" > "${RECENT_FILE}.tmp"
    mv "${RECENT_FILE}.tmp" "$RECENT_FILE"
}

# Get recent applications
get_recent() {
    if [ -f "$RECENT_FILE" ]; then
        cat "$RECENT_FILE"
    fi
}

# Clear recent applications
clear_recent() {
    rm -f "$RECENT_FILE"
}

# Main
case "$1" in
    add)
        add_recent "$2"
        ;;
    list)
        get_recent
        ;;
    clear)
        clear_recent
        ;;
    *)
        echo "Usage: $0 {add|list|clear} [app]"
        exit 1
        ;;
esac

