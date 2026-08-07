#!/usr/bin/env bash
# Test suite for template validation

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh" || exit 1
source "$SCRIPT_DIR/../lib/template_engine.sh" || exit 1

# Disable errexit for testing (inherited from common.sh)
set +e

TESTS_PASSED=0
TESTS_FAILED=0

pass() {
    echo "✓ $1"
    ((TESTS_PASSED++))
}

fail() {
    echo "✗ $1"
    [ -n "${2:-}" ] && echo "  $2"
    ((TESTS_FAILED++))
}

# Test 1: Generation reset
echo "Testing template engine..."
generation_reset
if [ "${MAKE_TARGETS[init]:-}" = '@echo "No init step configured"' ]; then
    pass "Reset initializes default make targets"
else
    fail "Reset initializes default make targets" "Got: ${MAKE_TARGETS[init]:-}"
fi

# Test 2: Set make target
set_make_target "test" "pytest tests/"
if [ "${MAKE_TARGETS[test]:-}" = 'pytest tests/' ]; then
    pass "Sets make target"
else
    fail "Sets make target" "Expected: pytest tests/, Got: ${MAKE_TARGETS[test]:-}"
fi

# Test 3: Append make target
append_make_target "test" "coverage report"
if [ "${MAKE_TARGETS[test]:-}" = 'pytest tests/ && coverage report' ]; then
    pass "Appends to make target"
else
    fail "Appends to make target" "Expected: pytest tests/ && coverage report, Got: ${MAKE_TARGETS[test]:-}"
fi

# Test 4: Overwrite placeholder
generation_reset
append_make_target "lint" "ruff check ."
if [ "${MAKE_TARGETS[lint]:-}" = 'ruff check .' ]; then
    pass "Overwrites placeholder with append"
else
    fail "Overwrites placeholder with append" "Expected: ruff check ., Got: ${MAKE_TARGETS[lint]:-}"
fi

# Test 5: Template function naming
fn_name=$(_template_to_fn "python-research")
if [ "$fn_name" = 'python_research' ]; then
    pass "Converts template name to function name"
else
    fail "Converts template name to function name" "Expected: python_research, Got: $fn_name"
fi

# Summary
echo ""
echo "================================"
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"
echo "================================"

[ "$TESTS_FAILED" -eq 0 ] && exit 0 || exit 1
