#!/bin/bash
#
# Theme Compatibility Tests
# Test themes for compatibility and correctness
#

THEME_DIR="${1:-../src/themes}"
ERRORS=0

test_gtk3_theme() {
    echo "Testing GTK3 theme..."
    
    if [ -f "$THEME_DIR/gtk/vaultos-gtk3.css" ]; then
        # Basic syntax check
        if grep -q "{" "$THEME_DIR/gtk/vaultos-gtk3.css" && \
           grep -q "}" "$THEME_DIR/gtk/vaultos-gtk3.css"; then
            echo "  GTK3 CSS: OK"
        else
            echo "  GTK3 CSS: FAILED (syntax error)"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo "  GTK3 theme not found"
        ERRORS=$((ERRORS + 1))
    fi
}

test_gtk4_theme() {
    echo "Testing GTK4 theme..."
    
    if [ -f "$THEME_DIR/gtk/vaultos-gtk4.css" ]; then
        if grep -q "{" "$THEME_DIR/gtk/vaultos-gtk4.css" && \
           grep -q "}" "$THEME_DIR/gtk/vaultos-gtk4.css"; then
            echo "  GTK4 CSS: OK"
        else
            echo "  GTK4 CSS: FAILED (syntax error)"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo "  GTK4 theme not found"
        ERRORS=$((ERRORS + 1))
    fi
}

test_qt_theme() {
    echo "Testing Qt theme..."
    
    if [ -f "$THEME_DIR/qt/vaultos.qss" ]; then
        echo "  Qt theme file exists: OK"
    else
        echo "  Qt theme not found"
        ERRORS=$((ERRORS + 1))
    fi
}

test_color_schemes() {
    echo "Testing color schemes..."
    
    if [ -d "$THEME_DIR/colors" ]; then
        COLOR_FILES=$(find "$THEME_DIR/colors" -name "*.colors" | wc -l)
        if [ "$COLOR_FILES" -gt 0 ]; then
            echo "  Color schemes found: $COLOR_FILES"
        else
            echo "  No color scheme files found"
        fi
    else
        echo "  Color schemes directory not found"
    fi
}

# Main
echo "Theme Compatibility Tests"
echo "========================="
echo ""

test_gtk3_theme
test_gtk4_theme
test_qt_theme
test_color_schemes

echo ""
if [ $ERRORS -eq 0 ]; then
    echo "Theme tests: PASSED"
    exit 0
else
    echo "Theme tests: FAILED ($ERRORS errors)"
    exit 1
fi

