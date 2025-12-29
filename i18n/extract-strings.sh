#!/bin/bash
#
# Extract translatable strings from VaultOS source
# Generates .pot template file
#

POT_FILE="i18n/vaultos.pot"
SOURCE_DIRS="src/utils src/shell scripts"

mkdir -p i18n

echo "Extracting translatable strings..."

# Find all shell scripts and extract strings
find $SOURCE_DIRS -name "*.sh" -type f | while read file; do
    # Extract strings (basic extraction)
    grep -hE 'echo ".*"|echo -e ".*"' "$file" 2>/dev/null | \
        sed 's/.*echo[^"]*"\(.*\)".*/\1/' | \
        grep -v '^$'
done > /tmp/vaultos_strings.txt

# Create POT file (simplified)
cat > "$POT_FILE" <<EOF
# VaultOS Translation Template
# Generated: $(date)

msgid ""
msgstr ""
"Content-Type: text/plain; charset=UTF-8\n"

EOF

# Add strings to POT file
while IFS= read -r string; do
    if [ -n "$string" ]; then
        echo "" >> "$POT_FILE"
        echo "msgid \"$string\"" >> "$POT_FILE"
        echo "msgstr \"\"" >> "$POT_FILE"
    fi
done < /tmp/vaultos_strings.txt

rm -f /tmp/vaultos_strings.txt

echo "Translation template created: $POT_FILE"
echo ""
echo "To create a new translation:"
echo "  msginit -l LANG -i $POT_FILE -o i18n/locales/LANG/vaultos.po"

