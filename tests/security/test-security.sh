#!/bin/bash
#
# Security tests for VaultOS
# Tests security features and vulnerability fixes
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

echo "VaultOS Security Tests"
echo "======================"
echo ""

# Test 1: Check kickstart file for hardcoded passwords
echo "Testing kickstart file security..."
if grep -q "rootpw --plaintext" "$PROJECT_ROOT/build/kickstart/vaultos.ks"; then
    test_fail "Kickstart password security" "Plaintext password found"
else
    test_pass "Kickstart password security (no plaintext passwords)"
fi

# Test 2: Check IPC FIFO permissions in code
echo "Testing IPC security..."
if grep -q "mkfifo.*0666" "$PROJECT_ROOT/src/wm/config/runtime-config/ipc.c"; then
    test_fail "IPC FIFO permissions" "World-writable permissions (0666) found"
else
    if grep -q "mkfifo.*0600" "$PROJECT_ROOT/src/wm/config/runtime-config/ipc.c"; then
        test_pass "IPC FIFO permissions (0600)"
    else
        test_fail "IPC FIFO permissions" "Secure permissions not found"
    fi
fi

# Test 3: Check for unsafe string functions
echo "Testing code security (unsafe functions)..."
if grep -rn "strcpy(" "$PROJECT_ROOT/src/wm/config/runtime-config/config-parser.c" | grep -v "strncpy" | grep -v "test"; then
    test_fail "Unsafe string functions" "strcpy() found (should use strncpy)"
else
    test_pass "String function safety (strcpy replaced)"
fi

# Test 4: Check for input validation in IPC
echo "Testing IPC input validation..."
if grep -q "validate_command" "$PROJECT_ROOT/src/wm/config/runtime-config/ipc.c"; then
    test_pass "IPC input validation"
else
    test_fail "IPC input validation" "No validation function found"
fi

# Test 5: Check for command whitelist
echo "Testing IPC command whitelist..."
if grep -q "allowed_commands" "$PROJECT_ROOT/src/wm/config/runtime-config/ipc.c"; then
    test_pass "IPC command whitelist"
else
    test_fail "IPC command whitelist" "No whitelist found"
fi

# Test 6: Check window manager command validation
echo "Testing window manager security..."
if grep -q "is_safe_command\|is_valid_executable" "$PROJECT_ROOT/src/wm/vaultwm/main.c"; then
    test_pass "Window manager command validation"
else
    test_fail "Window manager command validation" "No validation found"
fi

# Test 7: Check for error handling
echo "Testing error handling..."
ERROR_HANDLING_COUNT=$(grep -c "if.*== NULL\|if.*< 0\|if.*== 0" "$PROJECT_ROOT/src/wm/vaultwm/main.c" || true)
if [ "$ERROR_HANDLING_COUNT" -gt 10 ]; then
    test_pass "Error handling (comprehensive)"
else
    test_fail "Error handling" "Insufficient error checks"
fi

# Test 8: Check security documentation exists
echo "Testing security documentation..."
if [ -f "$PROJECT_ROOT/docs/security.md" ]; then
    test_pass "Security documentation exists"
else
    test_fail "Security documentation" "docs/security.md not found"
fi

# Test 9: Check hardening script exists
echo "Testing security hardening script..."
if [ -f "$PROJECT_ROOT/src/security/hardening.sh" ]; then
    if [ -x "$PROJECT_ROOT/src/security/hardening.sh" ]; then
        test_pass "Security hardening script (executable)"
    else
        test_fail "Security hardening script" "Not executable"
    fi
else
    test_fail "Security hardening script" "Not found"
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

