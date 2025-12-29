#!/bin/bash
#
# VaultOS Configuration Validator
# Validates configuration files
#

CONFIG_FILE="${1:-$HOME/.config/vaultos/config.json}"
ERRORS=0

validate_json() {
    if ! command -v jq &> /dev/null; then
        echo "Warning: jq not found. Install with: sudo dnf install jq"
        echo "Skipping JSON validation"
        return 1
    fi
    
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Error: Configuration file not found: $CONFIG_FILE"
        return 1
    fi
    
    if ! jq empty "$CONFIG_FILE" 2>/dev/null; then
        echo "Error: Invalid JSON in configuration file"
        jq . "$CONFIG_FILE" 2>&1 | head -10
        return 1
    fi
    
    echo "JSON syntax: OK"
    return 0
}

validate_values() {
    if ! command -v jq &> /dev/null; then
        return 0
    fi
    
    # Validate window gap
    GAP=$(jq -r '.window_manager.window_gap // empty' "$CONFIG_FILE" 2>/dev/null)
    if [ -n "$GAP" ]; then
        if [ "$GAP" -lt 0 ] || [ "$GAP" -gt 100 ]; then
            echo "Error: window_gap must be between 0 and 100 (found: $GAP)"
            ERRORS=$((ERRORS + 1))
        fi
    fi
    
    # Validate border width
    BORDER=$(jq -r '.window_manager.border_width // empty' "$CONFIG_FILE" 2>/dev/null)
    if [ -n "$BORDER" ]; then
        if [ "$BORDER" -lt 0 ] || [ "$BORDER" -gt 20 ]; then
            echo "Error: border_width must be between 0 and 20 (found: $BORDER)"
            ERRORS=$((ERRORS + 1))
        fi
    fi
    
    # Validate layout
    LAYOUT=$(jq -r '.window_manager.default_layout // empty' "$CONFIG_FILE" 2>/dev/null)
    if [ -n "$LAYOUT" ]; then
        case "$LAYOUT" in
            tiling|floating|monocle)
                ;;
            *)
                echo "Error: default_layout must be tiling, floating, or monocle (found: $LAYOUT)"
                ERRORS=$((ERRORS + 1))
                ;;
        esac
    fi
}

# Main
echo "Validating configuration: $CONFIG_FILE"
echo ""

if ! validate_json; then
    exit 1
fi

validate_values

if [ $ERRORS -eq 0 ]; then
    echo "Configuration validation: PASSED"
    exit 0
else
    echo "Configuration validation: FAILED ($ERRORS errors)"
    exit 1
fi

