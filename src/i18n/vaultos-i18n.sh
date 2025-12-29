#!/bin/bash
#
# VaultOS Internationalization
# Translation system, multi-language support, locale management
#

set -e

I18N_DIR="${I18N_DIR:-/usr/share/vaultos/i18n}"
USER_I18N_DIR="$HOME/.local/share/vaultos/i18n"
LOCALE_CONFIG="$HOME/.config/vaultos/locale.conf"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Initialize
mkdir -p "$USER_I18N_DIR"
mkdir -p "$(dirname "$LOCALE_CONFIG")"

# Get current locale
get_locale() {
    if [ -f "$LOCALE_CONFIG" ]; then
        source "$LOCALE_CONFIG"
        echo "${LOCALE:-en_US.UTF-8}"
    else
        echo "${LANG:-en_US.UTF-8}"
    fi
}

# Set locale
set_locale() {
    local locale=$1
    
    echo "Setting locale to: $locale"
    
    # Save to config
    echo "LOCALE=$locale" > "$LOCALE_CONFIG"
    
    # Set system locale
    export LANG="$locale"
    export LC_ALL="$locale"
    
    echo -e "${GREEN}Locale set to $locale${RESET}"
}

# List available locales
list_locales() {
    echo -e "${GREEN}Available Locales:${RESET}"
    echo ""
    
    if [ -d "$I18N_DIR" ]; then
        for locale_dir in "$I18N_DIR"/*; do
            if [ -d "$locale_dir" ]; then
                local locale=$(basename "$locale_dir")
                echo -e "  ${BLUE}$locale${RESET}"
            fi
        done
    fi
    
    if [ -d "$USER_I18N_DIR" ]; then
        for locale_dir in "$USER_I18N_DIR"/*; do
            if [ -d "$locale_dir" ]; then
                local locale=$(basename "$locale_dir")
                echo -e "  ${BLUE}$locale${RESET} (user)"
            fi
        done
    fi
    
    echo ""
}

# Load translation
load_translation() {
    local key=$1
    local locale=$(get_locale)
    local translation_file
    
    # Try user translations first
    translation_file="$USER_I18N_DIR/$locale/translations.po"
    if [ ! -f "$translation_file" ]; then
        translation_file="$I18N_DIR/$locale/translations.po"
    fi
    
    if [ -f "$translation_file" ]; then
        # Extract translation (simplified - would use gettext in production)
        grep -A 1 "msgid \"$key\"" "$translation_file" | grep "msgstr" | cut -d'"' -f2
    else
        # Return key as fallback
        echo "$key"
    fi
}

# Main
case "${1:-}" in
    set)
        set_locale "$2"
        ;;
    get)
        get_locale
        ;;
    list)
        list_locales
        ;;
    *)
        echo "Usage: $0 [set|get|list] [locale]"
        exit 1
        ;;
esac

