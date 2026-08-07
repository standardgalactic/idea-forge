#!/usr/bin/env bash
# Test runner for idea-forge

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================="
echo "Running idea-forge test suite"
echo "========================================="
echo ""

total_passed=0
total_failed=0

for test_file in "$SCRIPT_DIR"/test_*.sh; do
    if [ -f "$test_file" ]; then
        echo "Running $(basename "$test_file")..."
        if /bin/bash "$test_file"; then
            total_passed=$((total_passed + 1))
        else
            total_failed=$((total_failed + 1))
        fi
        echo ""
    fi
done

echo "========================================="
echo "Test suite summary"
echo "========================================="
echo "Test files passed: $total_passed"
echo "Test files failed: $total_failed"
echo "========================================="

[ "$total_failed" -eq 0 ] && exit 0 || exit 1
