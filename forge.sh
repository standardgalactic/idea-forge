#!/usr/bin/env bash
set -euo pipefail

OWNER="standardgalactic"
ROOT="${HOME}/github"
DEFAULT_BRANCH="main"

mkdir -p "$ROOT"

require() {
    command -v "$1" >/dev/null 2>&1 || {
        echo "Missing required command: $1" >&2
        exit 1
    }
}

require git
require gh

if ! gh auth status >/dev/null 2>&1; then
    echo "GitHub CLI is not authenticated."
    echo
    echo "Run:"
    echo "  gh auth login"
    exit 1
fi

declare -a REPOS=(
    "constraint-games"
    "retro-terminal"
    "microbiology-sim"
    "math-machines"
    "earth-history"
    "language-evolution"
    "tiny-operating-systems"
    "algorithm-zoo"
    "forgotten-computing"
    "procedural-universe"
)

declare -A TITLES
declare -A DESCRIPTIONS
declare -A LANGUAGES
declare -A TOPICS
declare -A SUMMARIES

TITLES["constraint-games"]="Constraint Games"
DESCRIPTIONS["constraint-games"]="Classic logic puzzles implemented as constraint satisfaction and search problems."
LANGUAGES["constraint-games"]="python"
TOPICS["constraint-games"]="constraint-satisfaction sudoku nonograms search algorithms optimization"
SUMMARIES["constraint-games"]="Constraint Games is a laboratory for studying puzzles as formal search spaces. It treats Sudoku, Kakuro, Nonograms, Slitherlink, Lights Out, and related games as compact examples of general computational problems. The repository is intended to compare exhaustive search, constraint propagation, SAT-style reasoning, heuristic search, local optimization, and stochastic methods on common problem instances."

TITLES["retro-terminal"]="Retro Terminal"
DESCRIPTIONS["retro-terminal"]="Recreations of historical terminal interfaces and interaction models."
LANGUAGES["retro-terminal"]="rust"
TOPICS["retro-terminal"]="terminal tui retrocomputing emulator history-of-computing"
SUMMARIES["retro-terminal"]="Retro Terminal explores historical command-line and terminal interaction as software archaeology. The goal is not merely to imitate old typography, but to reconstruct the behavioral assumptions of terminals from different periods: line-oriented interaction, limited control sequences, slow links, modal editors, text consoles, and early interactive shells."

TITLES["microbiology-sim"]="Microbiology Sim"
DESCRIPTIONS["microbiology-sim"]="Educational simulation of microbial colonies, ecology, and adaptation."
LANGUAGES["microbiology-sim"]="python"
TOPICS["microbiology-sim"]="microbiology simulation bacteria ecology computational-biology"
SUMMARIES["microbiology-sim"]="Microbiology Sim is an educational computational laboratory for modeling simplified microbial populations. Planned experiments include colony growth, nutrient competition, plasmid transfer, antibiotic selection, quorum sensing, biofilm formation, mutation, and spatial expansion."

TITLES["math-machines"]="Math Machines"
DESCRIPTIONS["math-machines"]="Executable models of computation, logic, automata, and symbolic machines."
LANGUAGES["math-machines"]="python"
TOPICS["math-machines"]="turing-machine automata lambda-calculus computation logic cellular-automata"
SUMMARIES["math-machines"]="Math Machines is a collection of executable mathematical models of computation. It includes Turing machines, finite automata, register machines, tag systems, rewriting systems, cellular automata, lambda calculus evaluators, combinatory logic, Post systems, and related formalisms."

TITLES["earth-history"]="Earth History"
DESCRIPTIONS["earth-history"]="Structured computational exploration of geological and evolutionary history."
LANGUAGES["earth-history"]="python"
TOPICS["earth-history"]="geology paleontology evolution earth-science timeline"
SUMMARIES["earth-history"]="Earth History turns geological time into structured data that can be queried, analyzed, and visualized. It is intended to combine major geological intervals, extinction events, climate transitions, evolutionary innovations, atmospheric changes, and continental reorganizations into a reproducible computational timeline."

TITLES["language-evolution"]="Language Evolution"
DESCRIPTIONS["language-evolution"]="Simulation of phonological, lexical, grammatical, and genealogical language change."
LANGUAGES["language-evolution"]="python"
TOPICS["language-evolution"]="linguistics language-evolution historical-linguistics simulation phonology"
SUMMARIES["language-evolution"]="Language Evolution is a computational laboratory for historical linguistics. It models sound change, lexical replacement, borrowing, semantic drift, grammaticalization, analogy, and lineage splitting to study how structured languages can diverge over long simulated periods."

TITLES["tiny-operating-systems"]="Tiny Operating Systems"
DESCRIPTIONS["tiny-operating-systems"]="Small operating-system experiments illustrating one systems concept at a time."
LANGUAGES["tiny-operating-systems"]="rust"
TOPICS["tiny-operating-systems"]="operating-systems kernel systems-programming rust education"
SUMMARIES["tiny-operating-systems"]="Tiny Operating Systems is a collection of deliberately small systems experiments. Rather than attempting to build one complete operating system immediately, each subproject isolates one concept such as scheduling, memory allocation, virtual memory, interrupts, filesystems, IPC, capability security, or device abstraction."

TITLES["algorithm-zoo"]="Algorithm Zoo"
DESCRIPTIONS["algorithm-zoo"]="Reference implementations, experiments, and benchmarks across algorithmic families."
LANGUAGES["algorithm-zoo"]="python"
TOPICS["algorithm-zoo"]="algorithms data-structures graph-theory optimization numerical-methods"
SUMMARIES["algorithm-zoo"]="Algorithm Zoo is a comparative reference of algorithms implemented with an emphasis on clarity, instrumentation, and experimentation. The long-term aim is to cover graph algorithms, search, sorting, numerical methods, optimization, compression, computational geometry, dynamic programming, probabilistic methods, and selected machine-learning algorithms."

TITLES["forgotten-computing"]="Forgotten Computing"
DESCRIPTIONS["forgotten-computing"]="Experiments in historical programming languages, systems, and computational ideas."
LANGUAGES["forgotten-computing"]="mixed"
TOPICS["forgotten-computing"]="retrocomputing forth apl prolog smalltalk programming-languages"
SUMMARIES["forgotten-computing"]="Forgotten Computing revisits programming languages, machines, and interaction models that remain intellectually interesting even when they are no longer mainstream. Planned subjects include Forth, APL, SNOBOL, Icon, Smalltalk, Prolog, Oberon, Lisp machines, stack computers, and unusual historical operating systems."

TITLES["procedural-universe"]="Procedural Universe"
DESCRIPTIONS["procedural-universe"]="Deterministic generation of fictional planets, ecosystems, cultures, and histories."
LANGUAGES["procedural-universe"]="python"
TOPICS["procedural-universe"]="procedural-generation worldbuilding simulation planets ecosystems"
SUMMARIES["procedural-universe"]="Procedural Universe is a deterministic world-generation laboratory. Starting from a seed, the system generates astronomical conditions, planetary environments, climates, ecosystems, cultures, technologies, writing systems, historical events, and other layers of a fictional world."

create_python_project() {
    local repo="$1"

    mkdir -p \
        src/"${repo//-/_}" \
        tests \
        examples \
        experiments \
        notebooks \
        benchmarks

    cat > pyproject.toml <<EOF
[build-system]
requires = ["setuptools>=68"]
build-backend = "setuptools.build_meta"

[project]
name = "$repo"
version = "0.1.0"
description = "${DESCRIPTIONS[$repo]}"
readme = "README.md"
requires-python = ">=3.11"
license = { text = "MIT" }
authors = [
    { name = "Flyxion" }
]
dependencies = []

[project.optional-dependencies]
dev = [
    "pytest>=8",
    "ruff>=0.5"
]

[tool.pytest.ini_options]
testpaths = ["tests"]

[tool.ruff]
line-length = 100
EOF

    local pkg="${repo//-/_}"

    cat > "src/$pkg/__init__.py" <<EOF
"""${TITLES[$repo]} package."""

__version__ = "0.1.0"
EOF

    cat > tests/test_smoke.py <<EOF
def test_smoke():
    assert True
EOF
}

create_rust_project() {
    local repo="$1"

    if [ ! -f Cargo.toml ]; then
        cargo init --name "${repo//-/_}" --vcs none .
    fi

    mkdir -p examples experiments benchmarks

    cat > Cargo.toml <<EOF
[package]
name = "${repo//-/_}"
version = "0.1.0"
edition = "2024"
description = "${DESCRIPTIONS[$repo]}"
license = "MIT"

[dependencies]
EOF
}

create_mixed_project() {
    mkdir -p \
        examples \
        experiments \
        interpreters \
        languages \
        notes \
        artifacts
}

write_readme() {
    local repo="$1"

    cat > README.md <<EOF
# ${TITLES[$repo]}

${DESCRIPTIONS[$repo]}

## Overview

${SUMMARIES[$repo]}

The repository is designed as an experimental and educational project rather than a finished software product. Implementations should remain understandable, reproducible, and easy to inspect.

## Repository Structure

\`\`\`text
.
├── README.md
├── LICENSE
├── CONTRIBUTING.md
├── CITATION.cff
├── docs/
├── examples/
├── experiments/
├── tests/
└── .github/
\`\`\`

Additional directories may appear as individual experiments become substantial enough to deserve their own modules.

## Design Principles

The project favors explicit implementations over opaque abstractions. Algorithms and simulations should expose intermediate state whenever practical so that their behavior can be studied rather than merely invoked.

Examples should be executable. Experiments should document their assumptions. Benchmarks should state exactly what they measure. Historical claims should be sourced. Scientific simulations should distinguish pedagogical models from validated scientific models.

## Status

This repository is at an early experimental stage.

The initial structure establishes the project boundaries, documentation conventions, testing infrastructure, and development workflow.

## Development

Clone the repository:

\`\`\`bash
git clone git@github.com:${OWNER}/${repo}.git
cd ${repo}
\`\`\`

See \`CONTRIBUTING.md\` for contribution guidance and \`docs/roadmap.md\` for planned directions.

## License

MIT.
EOF
}

write_license() {
    cat > LICENSE <<EOF
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
EOF
}

write_gitignore() {
    cat > .gitignore <<'EOF'
# Python
__pycache__/
*.py[cod]
*.egg-info/
.pytest_cache/
.ruff_cache/
.venv/
venv/

# Rust
target/

# Build output
build/
dist/
out/

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

# Logs
*.log

# LaTeX
*.aux
*.bbl
*.bcf
*.blg
*.fdb_latexmk
*.fls
*.log
*.out
*.run.xml
*.synctex.gz
*.toc
EOF
}

write_contributing() {
    local repo="$1"

    cat > CONTRIBUTING.md <<EOF
# Contributing to ${TITLES[$repo]}

Contributions are welcome.

The project values implementations that are understandable, reproducible, and appropriately documented. A small implementation that clearly demonstrates an idea is often preferable to a large abstraction that hides the mechanism being studied.

Before submitting a substantial change, consider opening an issue describing the proposed experiment, implementation, dataset, historical reconstruction, or architectural change.

Code contributions should include tests where practical. Experimental results should state assumptions and parameters. Scientific or historical claims should include references where those claims are not common knowledge.

Keep commits focused enough that the reasoning behind a change can be reconstructed from the history.
EOF
}

write_citation() {
    local repo="$1"

    cat > CITATION.cff <<EOF
cff-version: 1.2.0
message: "If you use this project, please cite the repository."
title: "${TITLES[$repo]}"
type: software
authors:
  - family-names: "Flyxion"
repository-code: "https://github.com/${OWNER}/${repo}"
license: MIT
version: 0.1.0
date-released: "$(date +%Y-%m-%d)"
EOF
}

write_docs() {
    local repo="$1"

    mkdir -p docs

    cat > docs/architecture.md <<EOF
# Architecture

## Purpose

${SUMMARIES[$repo]}

The architecture should remain modular enough that individual experiments can be understood and executed independently.

## Core Boundary

The repository separates reusable implementation from experiments.

Reusable code belongs in the primary source tree. Exploratory code belongs in \`experiments/\`. Small demonstrations belong in \`examples/\`. Performance comparisons belong in \`benchmarks/\`.

## Reproducibility

Experiments should expose configuration explicitly. Randomized experiments should accept deterministic seeds. Generated output should be reproducible whenever the underlying algorithm permits it.

## Documentation

Every substantial module should explain the computational idea being implemented, its assumptions, and any important limitations.
EOF

    cat > docs/roadmap.md <<EOF
# Roadmap

## Initial Phase

The first phase establishes a collection of minimal working examples that define the conceptual range of the repository.

## Experimental Phase

Once several examples exist, common abstractions should be extracted only where repeated implementations demonstrate a genuine shared structure.

## Comparative Phase

Different implementations or models should be compared using explicit metrics, reproducible inputs, and documented assumptions.

## Documentation Phase

The project should gradually accumulate tutorials, explanatory essays, references, and reproducible demonstrations suitable for independent study.

## Long-Term Direction

The repository may eventually support notebooks, benchmark suites, interactive tools, visualization, and companion papers, but these should grow from working experiments rather than precede them.
EOF

    cat > docs/bibliography.md <<EOF
# Bibliography

This document collects books, papers, manuals, standards, historical sources, and datasets relevant to ${TITLES[$repo]}.

References should be added as the project develops rather than populated speculatively.
EOF
}

write_issue_templates() {
    mkdir -p .github/ISSUE_TEMPLATE

    cat > .github/ISSUE_TEMPLATE/experiment.md <<'EOF'
---
name: Experiment
about: Propose a new experiment or model
title: "[experiment] "
labels: experiment
---

## Question

What question should the experiment investigate?

## Proposed Method

Describe the implementation or experimental setup.

## Expected Output

What measurements, traces, visualizations, or examples should it produce?

## References

Include relevant sources if applicable.
EOF

    cat > .github/ISSUE_TEMPLATE/bug.md <<'EOF'
---
name: Bug report
about: Report incorrect behavior
title: "[bug] "
labels: bug
---

## Description

Describe the incorrect behavior.

## Reproduction

Provide the smallest reproducible example.

## Expected Behavior

Describe what should have happened.

## Environment

Include relevant language, compiler, interpreter, or operating-system versions.
EOF
}

write_ci_python() {
    mkdir -p .github/workflows

    cat > .github/workflows/ci.yml <<'EOF'
name: CI

on:
  push:
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"

      - name: Install project
        run: |
          python -m pip install --upgrade pip
          pip install -e ".[dev]"

      - name: Ruff
        run: ruff check .

      - name: Tests
        run: pytest
EOF
}

write_ci_rust() {
    mkdir -p .github/workflows

    cat > .github/workflows/ci.yml <<'EOF'
name: CI

on:
  push:
  pull_request:

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Check
        run: cargo check --all-targets

      - name: Test
        run: cargo test

      - name: Clippy
        run: cargo clippy --all-targets -- -D warnings
EOF
}

write_ci_mixed() {
    mkdir -p .github/workflows

    cat > .github/workflows/ci.yml <<'EOF'
name: Repository Check

on:
  push:
  pull_request:

jobs:
  check:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Verify repository
        run: |
          test -f README.md
          test -f LICENSE
          test -f CONTRIBUTING.md
          test -f CITATION.cff
EOF
}

setup_labels() {
    local repo="$1"

    gh label create "experiment" \
        --repo "$OWNER/$repo" \
        --description "Experimental implementation or investigation" \
        --color "5319e7" \
        --force >/dev/null 2>&1 || true

    gh label create "research" \
        --repo "$OWNER/$repo" \
        --description "Research, references, or theoretical discussion" \
        --color "0052cc" \
        --force >/dev/null 2>&1 || true

    gh label create "documentation" \
        --repo "$OWNER/$repo" \
        --description "Documentation improvements" \
        --color "0075ca" \
        --force >/dev/null 2>&1 || true

    gh label create "good first experiment" \
        --repo "$OWNER/$repo" \
        --description "Suitable introductory experiment" \
        --color "7057ff" \
        --force >/dev/null 2>&1 || true
}

setup_topics() {
    local repo="$1"

    local args=()

    for topic in ${TOPICS[$repo]}; do
        args+=(--add-topic "$topic")
    done

    gh repo edit "$OWNER/$repo" "${args[@]}" >/dev/null
}

create_repo_if_needed() {
    local repo="$1"

    if gh repo view "$OWNER/$repo" >/dev/null 2>&1; then
        echo "Remote repository already exists."
    else
        echo "Creating GitHub repository."

        gh repo create "$OWNER/$repo" \
            --public \
            --description "${DESCRIPTIONS[$repo]}"
    fi
}

prepare_local_repo() {
    local repo="$1"
    local path="$ROOT/$repo"

    if [ -d "$path/.git" ]; then
        echo "Local repository already exists."
        cd "$path"
        return
    fi

    if [ -d "$path" ]; then
        if [ "$(find "$path" -mindepth 1 -maxdepth 1 | wc -l)" -gt 0 ]; then
            echo "Directory exists and is not empty:"
            echo "  $path"
            echo "Skipping to avoid overwriting local files."
            return 1
        fi
    else
        mkdir -p "$path"
    fi

    cd "$path"

    git init
    git branch -M "$DEFAULT_BRANCH"
    git remote add origin "git@github.com:$OWNER/$repo.git"
}

generate_project() {
    local repo="$1"

    echo "Generating project files."

    write_readme "$repo"
    write_license
    write_gitignore
    write_contributing "$repo"
    write_citation "$repo"
    write_docs "$repo"
    write_issue_templates

    case "${LANGUAGES[$repo]}" in
        python)
            create_python_project "$repo"
            write_ci_python
            ;;
        rust)
            require cargo
            create_rust_project "$repo"
            write_ci_rust
            ;;
        mixed)
            create_mixed_project
            write_ci_mixed
            ;;
        *)
            echo "Unknown language type: ${LANGUAGES[$repo]}" >&2
            exit 1
            ;;
    esac
}

commit_and_push() {
    local repo="$1"

    git add .

    if git diff --cached --quiet; then
        echo "No new changes to commit."
    else
        git commit -m "Establish initial project structure"
    fi

    if git remote get-url origin >/dev/null 2>&1; then
        :
    else
        git remote add origin "git@github.com:$OWNER/$repo.git"
    fi

    git push -u origin "$DEFAULT_BRANCH"
}

build_repo() {
    local repo="$1"

    echo
    echo "============================================================"
    echo "${TITLES[$repo]}"
    echo "$OWNER/$repo"
    echo "============================================================"

    create_repo_if_needed "$repo"

    if ! prepare_local_repo "$repo"; then
        return
    fi

    generate_project "$repo"
    commit_and_push "$repo"

    echo "Setting GitHub metadata."
    setup_topics "$repo"
    setup_labels "$repo"

    gh repo edit "$OWNER/$repo" \
        --description "${DESCRIPTIONS[$repo]}" \
        --enable-issues \
        >/dev/null

    echo "Complete: $OWNER/$repo"
}

echo
echo "GitHub Research Forge"
echo "Owner: $OWNER"
echo "Root:  $ROOT"
echo

for repo in "${REPOS[@]}"; do
    build_repo "$repo"
done

echo
echo "============================================================"
echo "Forge complete"
echo "============================================================"
echo

for repo in "${REPOS[@]}"; do
    printf "https://github.com/%s/%s\n" "$OWNER" "$repo"
done
