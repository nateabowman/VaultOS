#!/bin/bash
#
# Application Indexer
# Index and search applications
#

INDEX_FILE="$HOME/.local/share/vaultos/app-index"
DESKTOP_DIRS="/usr/share/applications $HOME/.local/share/applications"

# Create directory if it doesn't exist
mkdir -p "$(dirname "$INDEX_FILE")"

# Index applications
index_applications() {
    echo "Indexing applications..."
    
    > "$INDEX_FILE"
    
    for dir in $DESKTOP_DIRS; do
        if [ -d "$dir" ]; then
            find "$dir" -name "*.desktop" | while read desktop_file; do
                # Extract application name and executable
                NAME=$(grep "^Name=" "$desktop_file" | head -1 | cut -d= -f2)
                EXEC=$(grep "^Exec=" "$desktop_file" | head -1 | cut -d= -f2 | cut -d' ' -f1)
                CATEGORIES=$(grep "^Categories=" "$desktop_file" | head -1 | cut -d= -f2)
                
                if [ -n "$NAME" ] && [ -n "$EXEC" ]; then
                    echo "$NAME|$EXEC|$CATEGORIES|$desktop_file" >> "$INDEX_FILE"
                fi
            done
        fi
    done
    
    echo "Indexed $(wc -l < "$INDEX_FILE") applications"
}

# Search applications
search_applications() {
    local query="$1"
    
    if [ -z "$query" ]; then
        echo "Usage: $0 search <query>"
        return 1
    fi
    
    if [ ! -f "$INDEX_FILE" ]; then
        index_applications
    fi
    
    grep -i "$query" "$INDEX_FILE" | cut -d'|' -f1
}

# List all applications
list_applications() {
    if [ ! -f "$INDEX_FILE" ]; then
        index_applications
    fi
    
    cut -d'|' -f1 "$INDEX_FILE" | sort
}

# Get application info
get_app_info() {
    local app_name="$1"
    
    if [ -z "$app_name" ]; then
        echo "Usage: $0 info <app_name>"
        return 1
    fi
    
    if [ ! -f "$INDEX_FILE" ]; then
        index_applications
    fi
    
    grep "^$app_name|" "$INDEX_FILE" | head -1
}

# Main
case "$1" in
    index)
        index_applications
        ;;
    search)
        search_applications "$2"
        ;;
    list)
        list_applications
        ;;
    info)
        get_app_info "$2"
        ;;
    *)
        echo "Usage: $0 {index|search|list|info} [arguments]"
        exit 1
        ;;
esac

