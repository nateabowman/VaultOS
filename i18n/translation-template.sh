#!/bin/bash
#
# Translation Template Generator
# Creates translation template for new languages
#

LANG_CODE="$1"

if [ -z "$LANG_CODE" ]; then
    echo "Usage: $0 <language_code>"
    echo "Example: $0 es (for Spanish)"
    echo ""
    echo "Language codes (ISO 639-1):"
    echo "  en - English"
    echo "  es - Spanish"
    echo "  fr - French"
    echo "  de - German"
    echo "  ja - Japanese"
    echo "  zh - Chinese"
    exit 1
fi

POT_FILE="i18n/vaultos.pot"
PO_FILE="i18n/locales/$LANG_CODE/vaultos.po"

if [ ! -f "$POT_FILE" ]; then
    echo "Error: Template file not found: $POT_FILE"
    echo "Run extract-strings.sh first"
    exit 1
fi

mkdir -p "i18n/locales/$LANG_CODE"

if command -v msginit &> /dev/null; then
    msginit -l "$LANG_CODE" -i "$POT_FILE" -o "$PO_FILE"
    echo "Translation template created: $PO_FILE"
    echo ""
    echo "Edit the .po file to add translations"
    echo "Then compile with: msgfmt -o i18n/locales/$LANG_CODE/vaultos.mo $PO_FILE"
else
    echo "Error: msginit not found. Install gettext:"
    echo "  sudo dnf install gettext"
    exit 1
fi

