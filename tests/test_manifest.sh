#!/usr/bin/env bash
# Test suite for manifest parsing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/common.sh" || exit 1
source "$SCRIPT_DIR/../lib/manifest.sh" || exit 1

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

# Test 1: Load manifest
echo "Testing manifest loading..."
load_manifest "$SCRIPT_DIR/../manifests/projects.tsv"
if [ "${#PROJECT_REPOS[@]}" -gt 0 ]; then
    pass "Manifest loads repositories"
else
    fail "Manifest loads repositories" "No repos loaded"
fi

# Test 2: Project exists check
if project_exists 'math-machines'; then
    pass "Detects existing project"
else
    fail "Detects existing project"
fi

if ! project_exists 'nonexistent-repo'; then
    pass "Rejects nonexistent project"
else
    fail "Rejects nonexistent project"
fi

# Test 3: Project metadata extraction
title=$(project_title "math-machines")
if [ "$title" = "Math Machines" ]; then
    pass "Extracts project title"
else
    fail "Extracts project title" "Expected: Math Machines, Got: $title"
fi

description=$(project_description "math-machines")
if [ -n "$description" ]; then
    pass "Extracts project description"
else
    fail "Extracts project description"
fi

templates=$(project_templates_csv "math-machines")
if [ -n "$templates" ]; then
    pass "Extracts project templates"
else
    fail "Extracts project templates"
fi

# Test 4: Empty field handling
constraint_starter=$(project_starter_pack "constraint-games")
if [ "$constraint_starter" = "constraint-games" ]; then
    pass "Handles populated starter pack"
else
    fail "Handles populated starter pack" "Expected: constraint-games, Got: $constraint_starter"
fi

retro_starter=$(project_starter_pack "retro-terminal")
if [ -z "$retro_starter" ]; then
    pass "Handles empty starter pack"
else
    fail "Handles empty starter pack" "Expected empty, Got: $retro_starter"
fi

# Test 5: Slug conversion
result=$(slug_to_pkg 'math-machines')
if [ "$result" = "math_machines" ]; then
    pass "Converts kebab-case to snake_case"
else
    fail "Converts kebab-case to snake_case" "Expected: math_machines, Got: $result"
fi

result=$(slug_to_pkg 'idea-forge')
if [ "$result" = "idea_forge" ]; then
    pass "Converts multi-word slugs"
else
    fail "Converts multi-word slugs" "Expected: idea_forge, Got: $result"
fi

# Summary
echo ""
echo "================================"
echo "Tests passed: $TESTS_PASSED"
echo "Tests failed: $TESTS_FAILED"
echo "================================"

[ "$TESTS_FAILED" -eq 0 ] && exit 0 || exit 1
