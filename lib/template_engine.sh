#!/usr/bin/env bash

# shellcheck disable=SC2034

declare -A MAKE_TARGETS=()
declare -a TEMPLATE_WORKFLOWS=()

generation_reset() {
    MAKE_TARGETS=()
    TEMPLATE_WORKFLOWS=()

    MAKE_TARGETS[init]="@echo \"No init step configured\""
    MAKE_TARGETS[lint]="@echo \"No lint step configured\""
    MAKE_TARGETS[test]="@echo \"No test step configured\""
    MAKE_TARGETS[benchmark]="@echo \"No benchmark step configured\""
    MAKE_TARGETS[docs]="@echo \"No docs step configured\""
    MAKE_TARGETS[format]="@echo \"No format step configured\""
    MAKE_TARGETS[release]="@echo \"No release step configured\""
}

set_make_target() {
    local target="$1"
    local command="$2"
    MAKE_TARGETS["$target"]="$command"
}

append_make_target() {
    local target="$1"
    local command="$2"
    local existing="${MAKE_TARGETS[$target]:-}"
    if [[ "$existing" == @echo*No*configured* ]]; then
        MAKE_TARGETS["$target"]="$command"
    elif [ -n "$existing" ]; then
        MAKE_TARGETS["$target"]="$existing && $command"
    else
        MAKE_TARGETS["$target"]="$command"
    fi
}

add_workflow_flavor() {
    local flavor="$1"
    TEMPLATE_WORKFLOWS+=("$flavor")
}

_template_to_fn() {
    echo "$1" | tr '-' '_'
}

apply_template() {
    local template="$1"
    local repo="$2"
    local repo_path="$3"
    local package="$4"
    local title="$5"
    local description="$6"

    local fn="template_apply_$(_template_to_fn "$template")"
    if ! declare -f "$fn" >/dev/null 2>&1; then
        err "Template implementation missing for: $template"
        exit 1
    fi

    "$fn" "$repo" "$repo_path" "$package" "$title" "$description"
}

template_apply_python_research() {
    local repo="$1" repo_path="$2" package="$3" title="$4" description="$5"
    mkdir -p "$repo_path/src/$package" "$repo_path/tests" "$repo_path/benchmarks" "$repo_path/docs" "$repo_path/papers"

    cat > "$repo_path/pyproject.toml" <<EOF2
[build-system]
requires = ["setuptools>=68"]
build-backend = "setuptools.build_meta"

[project]
name = "$repo"
version = "0.1.0"
description = "$description"
readme = "README.md"
requires-python = ">=3.11"
license = { text = "MIT" }
authors = [{ name = "Flyxion" }]
dependencies = []

[project.optional-dependencies]
dev = ["pytest>=8", "ruff>=0.6"]

[tool.pytest.ini_options]
testpaths = ["tests"]

[tool.ruff]
line-length = 100
EOF2

    cat > "$repo_path/src/$package/__init__.py" <<EOF2
"""$title package."""

__version__ = "0.1.0"
EOF2

    cat > "$repo_path/tests/test_smoke.py" <<'EOF2'
def test_smoke() -> None:
    assert True
EOF2

    set_make_target init "python -m pip install --upgrade pip && pip install -e \".[dev]\""
    set_make_target lint "ruff check ."
    set_make_target test "pytest"
    set_make_target benchmark "python -m pytest benchmarks -q || true"
    set_make_target docs "echo \"Build docs with your chosen toolchain\""
    set_make_target format "ruff format ."
    set_make_target release "python -m build || true"
    add_workflow_flavor "python"
}

template_apply_rust_library() {
    local repo="$1" repo_path="$2" package="$3" _title="$4" description="$5"
    mkdir -p "$repo_path/src" "$repo_path/tests" "$repo_path/examples" "$repo_path/benchmarks"

    cat > "$repo_path/Cargo.toml" <<EOF2
[package]
name = "$package"
version = "0.1.0"
edition = "2024"
description = "$description"
license = "MIT"

[dependencies]
EOF2

    cat > "$repo_path/src/lib.rs" <<'EOF2'
//! Library entrypoint.

pub fn version() -> &'static str {
    "0.1.0"
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn smoke() {
        assert_eq!(version(), "0.1.0");
    }
}
EOF2

    set_make_target init "cargo fetch"
    set_make_target lint "cargo clippy --all-targets -- -D warnings"
    set_make_target test "cargo test"
    set_make_target benchmark "cargo bench || true"
    set_make_target docs "cargo doc --no-deps"
    set_make_target format "cargo fmt --all"
    set_make_target release "cargo package"
    add_workflow_flavor "rust"
}

template_apply_rust_workspace() {
    local _repo="$1" repo_path="$2" _package="$3" _title="$4" _description="$5"
    mkdir -p "$repo_path/crates/core/src" "$repo_path/crates/vm/src"

    cat > "$repo_path/Cargo.toml" <<'EOF2'
[workspace]
members = ["crates/core", "crates/vm"]
resolver = "2"
EOF2

    cat > "$repo_path/crates/core/Cargo.toml" <<'EOF2'
[package]
name = "core_kernel"
version = "0.1.0"
edition = "2024"

[dependencies]
EOF2

    cat > "$repo_path/crates/core/src/lib.rs" <<'EOF2'
pub fn boot_banner() -> &'static str {
    "tiny-operating-systems core"
}
EOF2

    cat > "$repo_path/crates/vm/Cargo.toml" <<'EOF2'
[package]
name = "vm_kernel"
version = "0.1.0"
edition = "2024"

[dependencies]
core_kernel = { path = "../core" }
EOF2

    cat > "$repo_path/crates/vm/src/lib.rs" <<'EOF2'
use core_kernel::boot_banner;

pub fn describe() -> String {
    format!("workspace member uses {}", boot_banner())
}
EOF2

    append_make_target init "cargo fetch"
    set_make_target lint "cargo clippy --workspace --all-targets -- -D warnings"
    set_make_target test "cargo test --workspace"
    set_make_target benchmark "cargo bench --workspace || true"
    set_make_target docs "cargo doc --workspace --no-deps"
    set_make_target format "cargo fmt --all"
    set_make_target release "cargo package --workspace || true"
    add_workflow_flavor "rust"
}

template_apply_c_library() {
    local _repo="$1" repo_path="$2" package="$3" _title="$4" _description="$5"
    mkdir -p "$repo_path/include" "$repo_path/src" "$repo_path/tests"

    cat > "$repo_path/include/$package.h" <<EOF2
#ifndef ${package^^}_H
#define ${package^^}_H

int ${package}_version(void);

#endif
EOF2

    cat > "$repo_path/src/$package.c" <<EOF2
#include "$package.h"

int ${package}_version(void) {
    return 1;
}
EOF2

    set_make_target init "@echo \"No dependency install required\""
    set_make_target lint "@echo \"Run clang-tidy/clang-format when configured\""
    set_make_target test "@echo \"Add C test runner and update this target\""
    set_make_target benchmark "@echo \"Benchmark target not configured\""
    set_make_target docs "@echo \"Generate docs with Doxygen or Sphinx\""
    set_make_target format "@echo \"Apply C formatting tool\""
    set_make_target release "@echo \"Prepare source archives\""
    add_workflow_flavor "c"
}

template_apply_c_kernel() {
    local _repo="$1" repo_path="$2" _package="$3" _title="$4" _description="$5"
    mkdir -p "$repo_path/kernel" "$repo_path/arch/x86_64" "$repo_path/include"

    cat > "$repo_path/kernel/main.c" <<'EOF2'
#include <stdint.h>

void kernel_main(void) {
    volatile uint16_t *vga = (uint16_t *)0xB8000;
    const char *msg = "tiny-operating-systems";

    for (int i = 0; msg[i] != '\0'; ++i) {
        vga[i] = (uint16_t)msg[i] | 0x0F00;
    }
}
EOF2

    append_make_target lint "@echo \"Kernel linting toolchain can be added per platform\""
    append_make_target test "@echo \"Kernel tests are platform-specific\""
    add_workflow_flavor "c"
}

template_apply_latex_book() {
    local _repo="$1" repo_path="$2" _package="$3" _title="$4" _description="$5"
    mkdir -p "$repo_path/papers/book/chapters"

    cat > "$repo_path/papers/book/main.tex" <<'EOF2'
\documentclass[11pt]{book}
\begin{document}
\tableofcontents
\chapter{Introduction}
This book is generated by idea-forge.
\end{document}
EOF2

    cat > "$repo_path/papers/book/chapters/chapter1.tex" <<'EOF2'
\chapter{Foundations}
Add foundational material here.
EOF2

    append_make_target docs "latexmk -pdf papers/book/main.tex || true"
    add_workflow_flavor "docs"
}

template_apply_latex_paper() {
    local _repo="$1" repo_path="$2" _package="$3" _title="$4" _description="$5"
    mkdir -p "$repo_path/papers"

    cat > "$repo_path/papers/main.tex" <<'EOF2'
\documentclass[11pt]{article}
\begin{document}
\section{Introduction}
Generated by idea-forge.
\end{document}
EOF2

    append_make_target docs "latexmk -pdf papers/main.tex || true"
    add_workflow_flavor "docs"
}

template_apply_javascript_webapp() {
    local _repo="$1" repo_path="$2" _package="$3" _title="$4" _description="$5"
    mkdir -p "$repo_path/webapp/src" "$repo_path/webapp/public"

    cat > "$repo_path/webapp/package.json" <<'EOF2'
{
  "name": "idea-forge-webapp",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "lint": "echo \"add js linter\"",
    "test": "echo \"add js tests\"",
    "build": "echo \"add js build\""
  }
}
EOF2

    cat > "$repo_path/webapp/src/index.js" <<'EOF2'
console.log("idea-forge webapp template");
EOF2

    cat > "$repo_path/webapp/public/index.html" <<'EOF2'
<!doctype html>
<html>
  <head><meta charset="utf-8"><title>Idea Forge Webapp</title></head>
  <body><div id="root">Generated webapp scaffold.</div></body>
</html>
EOF2

    append_make_target lint "cd webapp && npm run lint"
    append_make_target test "cd webapp && npm run test"
    append_make_target docs "echo \"Document webapp in docs/\""
    append_make_target format "echo \"Add formatter for webapp\""
    add_workflow_flavor "javascript"
}

template_apply_notebook_laboratory() {
    local _repo="$1" repo_path="$2" _package="$3" _title="$4" _description="$5"
    mkdir -p "$repo_path/notebooks" "$repo_path/experiments"

    cat > "$repo_path/notebooks/README.md" <<'EOF2'
# Notebooks

Use this directory for reproducible notebooks. Keep seeds, input data, and environment notes explicit.
EOF2

    add_workflow_flavor "docs"
}

template_apply_static_website() {
    local _repo="$1" repo_path="$2" _package="$3" title="$4" description="$5"
    mkdir -p "$repo_path/site"

    cat > "$repo_path/site/index.md" <<EOF2
# $title

$description

This static site can host tutorials, notes, and release highlights.
EOF2

    append_make_target docs "echo \"Build static website\""
    add_workflow_flavor "docs"
}
