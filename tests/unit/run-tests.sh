#!/bin/bash
#
# Unit Test Runner
# Run unit tests for VaultOS components
#

TESTS_PASSED=0
TESTS_FAILED=0

test_function_exists() {
    local func_name="$1"
    local script="$2"
    
    if grep -q "^${func_name}()" "$script" || grep -q "^${func_name} {" "$script"; then
        return 0
    else
        return 1
    fi
}

test_script_executable() {
    local script="$1"
    
    if [ -x "$script" ]; then
        return 0
    else
        return 1
    fi
}

run_test() {
    local test_name="$1"
    local test_func="$2"
    
    echo -n "  $test_name... "
    
    if $test_func; then
        echo "PASS"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        return 0
    else
        echo "FAIL"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

echo "VaultOS Unit Tests"
echo "=================="
echo ""

# Test utility scripts
if [ -f "../src/utils/pipboy-viewer.sh" ]; then
    echo "Testing pipboy-viewer.sh:"
    run_test "Script is executable" "test_script_executable ../src/utils/pipboy-viewer.sh"
    echo ""
fi

# Test configuration scripts
if [ -f "../src/utils/config-manager/vaultos-config-tui.sh" ]; then
    echo "Testing config-tui.sh:"
    run_test "Script is executable" "test_script_executable ../src/utils/config-manager/vaultos-config-tui.sh"
    echo ""
fi

# Summary
echo "Test Summary"
echo "============"
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"

if [ $TESTS_FAILED -eq 0 ]; then
    exit 0
else
    exit 1
fi

