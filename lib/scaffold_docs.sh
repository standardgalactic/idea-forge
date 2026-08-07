#!/usr/bin/env bash

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
