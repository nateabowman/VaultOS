#!/bin/bash
# Validate VaultOS scripts syntax and structure
# Can run on any Linux system (not just Fedora)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== VaultOS Script Validation ===${NC}"
echo ""

# Check bash syntax
echo -e "${GREEN}Checking bash script syntax...${NC}"
for script in "$SCRIPT_DIR"/*.sh; do
    if [ -f "$script" ]; then
        if bash -n "$script" 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} $(basename "$script")"
        else
            echo -e "  ${RED}✗${NC} $(basename "$script") - Syntax error"
        fi
    fi
done

# Check project structure
echo ""
echo -e "${GREEN}Checking project structure...${NC}"

required_dirs=(
    "build/kickstart"
    "build/livecd"
    "src/boot/grub"
    "src/boot/plymouth"
    "src/wm/vaultwm"
    "src/terminal/themes"
    "src/shell/bashrc"
    "packages"
    "docs"
)

for dir in "${required_dirs[@]}"; do
    if [ -d "$PROJECT_ROOT/$dir" ]; then
        echo -e "  ${GREEN}✓${NC} $dir/"
    else
        echo -e "  ${RED}✗${NC} $dir/ - Missing"
    fi
done

# Check key files
echo ""
echo -e "${GREEN}Checking key files...${NC}"

key_files=(
    "build/kickstart/vaultos.ks"
    "src/wm/vaultwm/main.c"
    "src/wm/vaultwm/Makefile"
    "src/boot/grub/theme.txt"
    "src/terminal/themes/pipboy.conf"
    "src/shell/bashrc/vaultos.bashrc"
    "README.md"
)

for file in "${key_files[@]}"; do
    if [ -f "$PROJECT_ROOT/$file" ]; then
        echo -e "  ${GREEN}✓${NC} $file"
    else
        echo -e "  ${RED}✗${NC} $file - Missing"
    fi
done

# Check C code compilation (if gcc available)
if command -v gcc &> /dev/null; then
    echo ""
    echo -e "${GREEN}Checking window manager code...${NC}"
    if [ -f "$PROJECT_ROOT/src/wm/vaultwm/main.c" ]; then
        if gcc -fsyntax-only -I/usr/include/X11 "$PROJECT_ROOT/src/wm/vaultwm/main.c" 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} Window manager code compiles"
        else
            echo -e "  ${YELLOW}⚠${NC} Window manager code has warnings (may need X11 headers)"
        fi
    fi
fi

echo ""
echo -e "${GREEN}Validation complete!${NC}"
echo ""
echo -e "${YELLOW}Note: Full build requires Fedora Linux with:${NC}"
echo "  - rpmbuild, mock, lorax, livemedia-creator"
echo "  - X11 development libraries"
echo "  - Build tools (gcc, make)"

