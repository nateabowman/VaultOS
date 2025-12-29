#!/bin/bash
#
# Integration tests for VaultWM window manager
# Tests full system integration
#

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

test_pass() {
    echo -e "${GREEN}✓${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

test_fail() {
    echo -e "${RED}✗${NC} $1: $2"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

echo "VaultWM Integration Tests"
echo "========================"
echo ""

# Test 1: Check if window manager compiles
echo "Testing window manager compilation..."
if [ -f "$PROJECT_ROOT/src/wm/vaultwm/Makefile" ]; then
    cd "$PROJECT_ROOT/src/wm/vaultwm"
    if make clean > /dev/null 2>&1 && make > /dev/null 2>&1; then
        test_pass "Window manager compilation"
    else
        test_fail "Window manager compilation" "Build failed"
    fi
    cd "$PROJECT_ROOT"
else
    test_fail "Window manager compilation" "Makefile not found"
fi

# Test 2: Check IPC compilation
echo "Testing IPC compilation..."
if [ -f "$PROJECT_ROOT/src/wm/config/runtime-config/ipc.c" ]; then
    # Try to compile IPC code (basic syntax check)
    if gcc -c -I"$PROJECT_ROOT/src/wm/config/runtime-config" \
           "$PROJECT_ROOT/src/wm/config/runtime-config/ipc.c" \
           -o /tmp/vaultwm-ipc-test.o 2>/dev/null; then
        test_pass "IPC compilation"
        rm -f /tmp/vaultwm-ipc-test.o
    else
        test_fail "IPC compilation" "Compilation failed"
    fi
else
    test_fail "IPC compilation" "Source file not found"
fi

# Test 3: Check config parser compilation
echo "Testing config parser compilation..."
if [ -f "$PROJECT_ROOT/src/wm/config/runtime-config/config-parser.c" ]; then
    if gcc -c -I"$PROJECT_ROOT/src/wm/config/runtime-config" \
           "$PROJECT_ROOT/src/wm/config/runtime-config/config-parser.c" \
           -o /tmp/vaultwm-config-test.o 2>/dev/null; then
        test_pass "Config parser compilation"
        rm -f /tmp/vaultwm-config-test.o
    else
        test_fail "Config parser compilation" "Compilation failed"
    fi
else
    test_fail "Config parser compilation" "Source file not found"
fi

# Test 4: Check for required header files
echo "Testing header file dependencies..."
HEADERS=(
    "src/wm/config/runtime-config/ipc.h"
    "src/wm/config/runtime-config/config-parser.h"
    "src/wm/config/config.h"
)

for header in "${HEADERS[@]}"; do
    if [ -f "$PROJECT_ROOT/$header" ]; then
        test_pass "Header file: $header"
    else
        test_fail "Header file: $header" "Not found"
    fi
done

# Test 5: Check for security features
echo "Testing security feature integration..."
if grep -q "is_safe_command\|is_valid_executable" "$PROJECT_ROOT/src/wm/vaultwm/main.c"; then
    test_pass "Security features integrated"
else
    test_fail "Security features" "Not integrated"
fi

echo ""
echo "Test Summary"
echo "============"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    exit 1
else
    echo "Failed: $TESTS_FAILED"
    exit 0
fi

