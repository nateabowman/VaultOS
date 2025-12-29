#!/bin/bash
#
# Extract translatable strings from VaultOS source
# Creates POT template files
#

DOMAIN="vaultos"
TEMPLATE_DIR="templates"
SOURCE_DIRS="../utils ../shell ../services"

mkdir -p "$TEMPLATE_DIR"

# Extract from shell scripts
find $SOURCE_DIRS -name "*.sh" -type f | while read file; do
    xgettext --language=Shell --keyword=_ --output="$TEMPLATE_DIR/${DOMAIN}.pot" "$file"
done

echo "Strings extracted to $TEMPLATE_DIR/${DOMAIN}.pot"

