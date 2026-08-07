#!/usr/bin/env bash

write_issue_templates() {
    local path="$1"
    mkdir -p "$path/.github/ISSUE_TEMPLATE"

    cat > "$path/.github/ISSUE_TEMPLATE/bug.yml" <<'EOF2'
name: Bug report
description: Report incorrect behavior
title: "[bug] "
labels: [bug]
body:
  - type: textarea
    id: reproduction
    attributes:
      label: Reproduction
      description: Minimal reproducible case
    validations:
      required: true
EOF2

    cat > "$path/.github/ISSUE_TEMPLATE/feature.yml" <<'EOF2'
name: Feature request
description: Propose a new capability
title: "[feature] "
labels: [enhancement]
body:
  - type: textarea
    id: proposal
    attributes:
      label: Proposal
      description: What should be added and why
    validations:
      required: true
EOF2

    cat > "$path/.github/ISSUE_TEMPLATE/experiment.yml" <<'EOF2'
name: Experiment
description: Propose a new experiment
title: "[experiment] "
labels: [experiment]
body:
  - type: textarea
    id: question
    attributes:
      label: Research question
      description: What should this experiment answer?
    validations:
      required: true
EOF2

    cat > "$path/.github/ISSUE_TEMPLATE/documentation.yml" <<'EOF2'
name: Documentation
description: Request docs improvements
title: "[docs] "
labels: [documentation]
body:
  - type: textarea
    id: docs
    attributes:
      label: Documentation change
      description: What docs should change?
    validations:
      required: true
EOF2
}

write_pr_template() {
    local path="$1"
    cat > "$path/.github/pull_request_template.md" <<'EOF2'
## Summary

## Changes

## Validation

- [ ] make lint
- [ ] make test
- [ ] make docs
EOF2
}

write_workflows() {
    local path="$1"
    mkdir -p "$path/.github/workflows"

    cat > "$path/.github/workflows/ci.yml" <<'EOF2'
name: CI

on:
  push:
  pull_request:

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - name: Run CI interface
        run: |
          make init
          make lint
          make test
EOF2

    cat > "$path/.github/workflows/lint.yml" <<'EOF2'
name: Lint

on:
  pull_request:
  workflow_dispatch:

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - name: Lint + format checks
        run: |
          make init
          make format
          make lint
EOF2

    cat > "$path/.github/workflows/docs.yml" <<'EOF2'
name: Docs

on:
  push:
    paths:
      - "docs/**"
      - "site/**"
      - "papers/**"
  workflow_dispatch:

jobs:
  docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - name: Build docs interface
        run: |
          make init
          make docs
EOF2

    cat > "$path/.github/workflows/release.yml" <<'EOF2'
name: Release

on:
  workflow_dispatch:

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - name: Run release interface
        run: |
          make init
          make release
EOF2
}
