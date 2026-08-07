# idea-forge

Template-driven repository forge for research organizations.

## Quick Start

```bash
# Clone the repository
git clone https://github.com/standardgalactic/idea-forge.git
cd idea-forge

# List all configured projects
bin/forge list

# Preview what would be generated (dry run)
bin/forge bootstrap math-machines --dry-run

# Generate a single repository locally
bin/forge bootstrap math-machines --no-github

# Generate with GitHub integration (requires gh CLI authentication)
bin/forge bootstrap math-machines

# Generate all repositories from the manifest
bin/forge bootstrap all
```

The generated repository will include:
- Complete documentation (README, LICENSE, CHANGELOG, ROADMAP, etc.)
- GitHub workflows (CI, linting, documentation, releases)
- Consistent Makefile interface (`make init`, `make test`, `make lint`)
- Language-specific tooling and configuration
- Issue and PR templates

## Overview

Idea Forge is a repository generation system for creating consistent, well-documented research and software projects from reusable templates. Rather than manually repeating the same setup process for every new repository, projects are described through structured metadata and assembled from composable templates that define language support, documentation, workflows, testing infrastructure, and project conventions.

The system is designed to support long-term collections of related repositories while maintaining consistent engineering practices, documentation standards, and development workflows across an entire organization.

## Architecture

The project is organized around a small number of reusable components.

```text
idea-forge/
├── bin/
│   └── forge
├── lib/
├── manifests/
│   └── projects.tsv
├── templates/
│   ├── python-research
│   ├── rust-library
│   ├── rust-workspace
│   ├── c-library
│   ├── c-kernel
│   ├── latex-book
│   ├── latex-paper
│   ├── javascript-webapp
│   ├── notebook-laboratory
│   └── static-website
├── content-packs/
└── forge.sh
```

Project metadata is stored separately from the generation logic. Templates encapsulate reusable project structures, while the command-line interface orchestrates repository creation, template composition, Git initialization, GitHub configuration, and documentation generation.

## Template Catalog

Available templates include:

| Template | Description |
|----------|-------------|
| `python-research` | Python research template with pytest, ruff linting, and project structure for computational research |
| `rust-library` | Single-crate Rust library template with cargo, testing, and documentation support |
| `rust-workspace` | Multi-crate Rust workspace with shared dependencies and workspace-level commands |
| `c-library` | C library template with make-based build system and testing support |
| `c-kernel` | C kernel/OS projects with low-level system programming structure |
| `latex-book` | LaTeX book template with pdflatex build system and chapter organization |
| `latex-paper` | LaTeX academic paper template for research publications |
| `javascript-webapp` | Node.js web application template with npm and modern JavaScript tooling |
| `notebook-laboratory` | Jupyter notebook environment for interactive research and exploration |
| `static-website` | Static website template with basic HTTP serving and documentation structure |

To see the full list with descriptions, run:
```bash
bin/forge templates
```

Projects may combine multiple templates, allowing repositories to inherit functionality from several domains. For example, a computational research project may combine a Python research environment with notebook support and a static documentation website.

## Starter Packs

Starter packs populate new repositories with domain-specific example code:

| Starter Pack | Description |
|--------------|-------------|
| `math-machines` | Turing machines, lambda calculus, automata, and formal computation models |
| `constraint-games` | Sudoku, Lights Out, and constraint satisfaction puzzle solvers |
| `algorithm-zoo` | Sorting, graphs, dynamic programming, and algorithm comparisons |

To see available starter packs, run:
```bash
bin/forge starter-packs
```

## Command-Line Interface

The primary interface is the `forge` executable.

### Basic Usage

```bash
# List configured projects
bin/forge list

# Bootstrap a single repository
bin/forge bootstrap <repo-name> [options]

# Bootstrap all repositories
bin/forge bootstrap all [options]

# Re-apply templates to existing repository
bin/forge apply <repo-name>
```

### Options

```bash
--manifest path      # Use alternate manifest file (default: manifests/projects.tsv)
--owner owner        # Set GitHub owner (default: standardgalactic)
--root path          # Set local root directory (default: ~/github)
--branch name        # Set default branch (default: main)
--no-github          # Skip GitHub API operations (local generation only)
--dry-run           # Preview what would be generated without creating anything
```

### Examples

```bash
# Preview generation
bin/forge bootstrap math-machines --dry-run

# Generate locally without GitHub
bin/forge bootstrap math-machines --no-github

# Generate with custom root directory
bin/forge bootstrap math-machines --root ~/projects

# Re-apply templates to existing checkout (useful for template updates)
cd ~/github/math-machines
bin/forge apply math-machines
```

For compatibility with existing workflows, the top-level `forge.sh` script remains available as a convenience wrapper that runs `bin/forge bootstrap all`.

## Generated Repository Baseline

Every generated repository includes a common organizational foundation consisting of governance documents, project metadata, documentation, testing infrastructure, continuous integration, and development tooling.

The generated documentation includes:

- `CHANGELOG.md`
- `ROADMAP.md`
- `SECURITY.md`
- `STYLE.md`
- `AUTHORS.md`
- `ACKNOWLEDGEMENTS.md`
- `CODE_OF_CONDUCT.md`
- `CONTRIBUTING.md`
- `CITATION.cff`

Each repository also receives a standardized GitHub configuration containing issue templates, pull request templates, and GitHub Actions workflows for continuous integration, documentation, formatting, linting, and releases.

A common `Makefile` interface provides a consistent development experience across all generated repositories.

```bash
make init
make lint
make test
make benchmark
make docs
make format
make release
```

Individual templates map these common commands onto language-specific tooling while preserving a uniform interface for developers.

## Content Packs

Templates establish project structure, while optional content packs populate repositories with domain-specific starter material. A content pack may include example implementations, tutorial notebooks, benchmark suites, reference datasets, bibliographies, architecture notes, or introductory papers.

This separation allows multiple projects to share the same engineering template while beginning with completely different technical content.

## Design Philosophy

Idea Forge treats repository creation as a reproducible engineering process rather than a manual sequence of setup tasks. Repository metadata is declared once, reusable templates capture organizational conventions, and generated projects begin with documentation, testing, automation, and development infrastructure already in place.

The resulting repositories share a common structure while remaining free to evolve independently according to the needs of their respective research programs.
