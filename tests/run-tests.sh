#!/bin/bash
#
# VaultOS Test Runner
# Run all tests
#

GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

PASSED=0
FAILED=0

run_test() {
    local test=$1
    echo "Running: $test"
    
    if bash "$test"; then
        echo -e "${GREEN}PASS${RESET}: $test"
        ((PASSED++))
    else
        echo -e "${RED}FAIL${RESET}: $test"
        ((FAILED++))
    fi
}

echo "VaultOS Test Suite"
echo "=================="
echo ""

# Run unit tests
if [ -d "unit" ]; then
    for test in unit/*.sh; do
        [ -f "$test" ] && run_test "$test"
    done
fi

# Run integration tests
if [ -d "integration" ]; then
    for test in integration/*.sh; do
        [ -f "$test" ] && run_test "$test"
    done
fi

echo ""
echo "Results: $PASSED passed, $FAILED failed"

exit $FAILED

