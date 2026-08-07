#!/usr/bin/env bash

write_readme() {
    local path="$1" title="$2" description="$3" summary="$4"
    cat > "$path/README.md" <<EOF2
# $title

$description

## Overview

$summary

## Development

This repository uses a standard make interface:

- \\`make init\\`
- \\`make lint\\`
- \\`make test\\`
- \\`make benchmark\\`
- \\`make docs\\`
- \\`make format\\`
- \\`make release\\`
EOF2
}

write_license() {
    local path="$1"
    cat > "$path/LICENSE" <<EOF2
MIT License

Copyright (c) $(date +%Y) Flyxion

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF2
}

write_gitignore() {
    local path="$1"
    cat > "$path/.gitignore" <<'EOF2'
# Python
__pycache__/
*.py[cod]
*.egg-info/
.pytest_cache/
.ruff_cache/
.venv/
venv/

# Rust / C
target/
*.o
*.a
*.so

# Build output
build/
dist/
out/

# Node
node_modules/

# Notebooks
.ipynb_checkpoints/

# Editors
*.swp
*.swo
*~
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# LaTeX
*.aux
*.bbl
*.bcf
*.blg
*.fdb_latexmk
*.fls
*.run.xml
*.synctex.gz
*.toc
EOF2
}

write_governance_docs() {
    local path="$1" title="$2" description="$3"

    cat > "$path/CHANGELOG.md" <<'EOF2'
# Changelog

All notable changes to this project will be documented in this file.
EOF2

    cat > "$path/ROADMAP.md" <<'EOF2'
# Roadmap

## Near-term
- Establish reproducible core examples.
- Add baseline tests and documentation.

## Mid-term
- Expand comparative experiments and benchmarks.

## Long-term
- Publish reusable research artifacts and tutorials.
EOF2

    cat > "$path/SECURITY.md" <<'EOF2'
# Security Policy

## Reporting a Vulnerability
Please open a private security advisory or contact maintainers directly with reproduction details.

## Supported Versions
The latest main branch is supported for security fixes.
EOF2

    cat > "$path/STYLE.md" <<'EOF2'
# Style Guide

- Prefer clear and explicit implementations.
- Keep modules focused and testable.
- Document assumptions and algorithmic complexity.
EOF2

    cat > "$path/AUTHORS.md" <<'EOF2'
# Authors

- Flyxion
EOF2

    cat > "$path/ACKNOWLEDGEMENTS.md" <<'EOF2'
# Acknowledgements

Thanks to contributors, reviewers, and researchers whose work informs this repository.
EOF2

    cat > "$path/CODE_OF_CONDUCT.md" <<'EOF2'
# Code of Conduct

This project follows a Contributor Covenant style expectation:
be respectful, inclusive, and constructive.
EOF2

    cat > "$path/CONTRIBUTING.md" <<EOF2
# Contributing to $title

$description

## Contribution Principles

- Keep changes reproducible and testable.
- Include documentation for non-obvious decisions.
- Add or update tests for behavioral changes.
EOF2
}

write_citation() {
    local path="$1" owner="$2" repo="$3" title="$4"
    cat > "$path/CITATION.cff" <<EOF2
cff-version: 1.2.0
message: "If you use this project, please cite the repository."
title: "$title"
type: software
authors:
  - family-names: "Flyxion"
repository-code: "https://github.com/$owner/$repo"
license: MIT
version: 0.1.0
date-released: "$(date +%Y-%m-%d)"
EOF2
}

write_docs_baseline() {
    local path="$1" summary="$2"
    mkdir -p "$path/docs"

    cat > "$path/docs/architecture.md" <<EOF2
# Architecture

$summary

The repository separates reusable implementation from experiments and docs.
EOF2

    cat > "$path/docs/roadmap.md" <<'EOF2'
# Detailed Roadmap

Add milestones and measurable deliverables as the project evolves.
EOF2

    cat > "$path/docs/bibliography.md" <<'EOF2'
# Bibliography

Track papers, manuals, datasets, and references used by this project.
EOF2
}

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

write_makefile() {
    local path="$1"

    cat > "$path/Makefile" <<EOF2
.PHONY: init lint test benchmark docs format release

init:
	${MAKE_TARGETS[init]}

lint:
	${MAKE_TARGETS[lint]}

test:
	${MAKE_TARGETS[test]}

benchmark:
	${MAKE_TARGETS[benchmark]}

docs:
	${MAKE_TARGETS[docs]}

format:
	${MAKE_TARGETS[format]}

release:
	${MAKE_TARGETS[release]}
EOF2
}
