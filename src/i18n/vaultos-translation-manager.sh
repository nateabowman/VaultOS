#!/bin/bash
# VaultOS Translation Management Tool
# Manages translations using gettext

set -e

I18N_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
POT_FILE="$I18N_DIR/vaultos.pot"
LOCALE_DIR="$I18N_DIR/locales"

# Initialize translation system
init_translations() {
    mkdir -p "$LOCALE_DIR"
    
    if ! command -v xgettext &> /dev/null; then
        echo "Error: gettext tools not found. Install with: sudo dnf install gettext"
        exit 1
    fi
    
    echo "Translation system initialized"
}

# Extract translatable strings
extract_strings() {
    echo "Extracting translatable strings..."
    
    # Extract from shell scripts
    find src/utils src/shell scripts -name "*.sh" -type f | while read -r file; do
        xgettext --from-code=UTF-8 --language=Shell --keyword=_ --keyword=gettext \
            --output="$POT_FILE" "$file" 2>/dev/null || true
    done
    
    echo "Strings extracted to: $POT_FILE"
}

# Create translation file
create_translation() {
    local lang="$1"
    
    if [ -z "$lang" ]; then
        echo "Usage: $0 create <language_code>"
        echo "Example: $0 create es"
        exit 1
    fi
    
    local lang_dir="$LOCALE_DIR/$lang"
    local po_file="$lang_dir/vaultos.po"
    
    mkdir -p "$lang_dir"
    
    if [ ! -f "$POT_FILE" ]; then
        echo "Error: POT file not found. Run: $0 extract"
        exit 1
    fi
    
    if [ ! -f "$po_file" ]; then
        msginit --locale="$lang" --input="$POT_FILE" --output="$po_file"
        echo "Translation file created: $po_file"
    else
        msgmerge --update "$po_file" "$POT_FILE"
        echo "Translation file updated: $po_file"
    fi
}

# Update translations
update_translations() {
    local lang="$1"
    
    if [ -z "$lang" ]; then
        echo "Updating all translations..."
        for lang_dir in "$LOCALE_DIR"/*; do
            if [ -d "$lang_dir" ]; then
                local lang=$(basename "$lang_dir")
                local po_file="$lang_dir/vaultos.po"
                if [ -f "$po_file" ]; then
                    msgmerge --update "$po_file" "$POT_FILE"
                    echo "Updated: $lang"
                fi
            fi
        done
    else
        local po_file="$LOCALE_DIR/$lang/vaultos.po"
        if [ -f "$po_file" ]; then
            msgmerge --update "$po_file" "$POT_FILE"
            echo "Updated: $lang"
        else
            echo "Error: Translation file not found for: $lang"
            exit 1
        fi
    fi
}

# Compile translations
compile_translations() {
    local lang="$1"
    
    if [ -z "$lang" ]; then
        echo "Compiling all translations..."
        for lang_dir in "$LOCALE_DIR"/*; do
            if [ -d "$lang_dir" ]; then
                local lang=$(basename "$lang_dir")
                local po_file="$lang_dir/vaultos.po"
                local mo_file="$lang_dir/LC_MESSAGES/vaultos.mo"
                
                if [ -f "$po_file" ]; then
                    mkdir -p "$(dirname "$mo_file")"
                    msgfmt --output-file="$mo_file" "$po_file"
                    echo "Compiled: $lang"
                fi
            fi
        done
    else
        local po_file="$LOCALE_DIR/$lang/vaultos.po"
        local mo_file="$LOCALE_DIR/$lang/LC_MESSAGES/vaultos.mo"
        
        if [ -f "$po_file" ]; then
            mkdir -p "$(dirname "$mo_file")"
            msgfmt --output-file="$mo_file" "$po_file"
            echo "Compiled: $lang"
        else
            echo "Error: Translation file not found for: $lang"
            exit 1
        fi
    fi
}

# List translations
list_translations() {
    echo "Available translations:"
    for lang_dir in "$LOCALE_DIR"/*; do
        if [ -d "$lang_dir" ]; then
            local lang=$(basename "$lang_dir")
            local po_file="$lang_dir/vaultos.po"
            if [ -f "$po_file" ]; then
                local translated=$(msgfmt --statistics "$po_file" 2>&1 | grep -o '[0-9]* translated' | grep -o '[0-9]*' || echo "0")
                echo "  $lang: $translated strings translated"
            fi
        fi
    done
}

# Show menu
show_menu() {
    clear
    echo "VaultOS Translation Manager"
    echo ""
    echo "1) Initialize translation system"
    echo "2) Extract translatable strings"
    echo "3) Create translation"
    echo "4) Update translations"
    echo "5) Compile translations"
    echo "6) List translations"
    echo "7) Exit"
}

# Main
if [ $# -eq 0 ]; then
    # Interactive mode
    while true; do
        show_menu
        read -p "Choice: " choice
        case $choice in
            1) init_translations;;
            2) extract_strings;;
            3) read -p "Language code (e.g., es, fr, de): " lang; create_translation "$lang";;
            4) read -p "Language code (optional, blank for all): " lang; update_translations "$lang";;
            5) read -p "Language code (optional, blank for all): " lang; compile_translations "$lang";;
            6) list_translations; read -p "Press Enter to continue...";;
            7) exit 0;;
            *) echo "Invalid choice";;
        esac
    done
else
    # Command-line mode
    case "$1" in
        init) init_translations;;
        extract) extract_strings;;
        create) create_translation "$2";;
        update) update_translations "$2";;
        compile) compile_translations "$2";;
        list) list_translations;;
        *) echo "Usage: $0 {init|extract|create|update|compile|list}"; exit 1;;
    esac
fi

