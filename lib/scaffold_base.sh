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

- make init
- make lint
- make test
- make benchmark
- make docs
- make format
- make release
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
