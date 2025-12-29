#!/bin/bash
#
# Run All VaultOS Tests
# Execute all test suites
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FAILED=0
PASSED=0
TOTAL=0

GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

run_test_suite() {
    local suite_name="$1"
    local suite_dir="$2"
    local test_script="$3"
    
    echo "Running $suite_name tests..."
    
    if [ -f "$suite_dir/$test_script" ]; then
        cd "$suite_dir"
        if bash "$test_script"; then
            echo -e "${GREEN}$suite_name: PASSED${RESET}"
            PASSED=$((PASSED + 1))
        else
            echo -e "${RED}$suite_name: FAILED${RESET}"
            FAILED=$((FAILED + 1))
        fi
        cd "$SCRIPT_DIR"
    else
        echo "Warning: Test suite not found: $suite_dir/$test_script"
    fi
    
    TOTAL=$((TOTAL + 1))
}

echo "VaultOS Test Suite"
echo "=================="
echo ""

# Run test suites
run_test_suite "Unit" "tests/unit" "run-tests.sh"
run_test_suite "Integration" "tests/integration" "run-tests.sh"
run_test_suite "Theme" "tests/theme" "test-themes.sh"
run_test_suite "Window Manager" "tests/wm" "test-wm.sh"

# Summary
echo ""
echo "Test Summary"
echo "============"
echo "Total: $TOTAL"
echo -e "${GREEN}Passed: $PASSED${RESET}"
if [ $FAILED -gt 0 ]; then
    echo -e "${RED}Failed: $FAILED${RESET}"
    exit 1
else
    echo "Failed: $FAILED"
    exit 0
fi

