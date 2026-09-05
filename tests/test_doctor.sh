#!/usr/bin/env bash

set -u
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORGE="$SCRIPT_DIR/../bin/forge"
TEMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TEMP_DIR"' EXIT

passed=0
failed=0
pass() { echo "✓ $1"; passed=$((passed + 1)); }
fail() { echo "✗ $1"; failed=$((failed + 1)); }

if "$FORGE" doctor --json | grep -q '"ok":true'; then
    pass "accepts the repository manifest"
else
    fail "accepts the repository manifest"
fi

cat >"$TEMP_DIR/bad.tsv" <<'EOF2'
demo	Demo	A demo.	topic	missing-template		Summary.
demo	Demo again	A duplicate.	topic	missing-template		Summary.
EOF2
if "$FORGE" doctor --manifest "$TEMP_DIR/bad.tsv" --json >"$TEMP_DIR/result.json"; then
    fail "rejects duplicate projects and unknown templates"
elif grep -q 'duplicate repository name' "$TEMP_DIR/result.json" && grep -q 'unknown template' "$TEMP_DIR/result.json"; then
    pass "rejects duplicate projects and unknown templates"
else
    fail "reports duplicate projects and unknown templates"
fi

cat >"$TEMP_DIR/scoped.tsv" <<'EOF2'
good	Good	A valid project.	topic	python-research		Summary.
bad	Bad	An invalid project.	topic	missing-template		Summary.
EOF2
if "$FORGE" doctor good --manifest "$TEMP_DIR/scoped.tsv" --json | grep -q '"ok":true'; then
    pass "validates one selected project"
else
    fail "validates one selected project"
fi

echo "Tests passed: $passed"
echo "Tests failed: $failed"
[ "$failed" -eq 0 ]
