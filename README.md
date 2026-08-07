# idea-forge

Template-driven repository forge for research organizations.

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

- `python-research`
- `rust-library`
- `rust-workspace`
- `c-library`
- `c-kernel`
- `latex-book`
- `latex-paper`
- `javascript-webapp`
- `notebook-laboratory`
- `static-website`

Projects may combine multiple templates, allowing repositories to inherit functionality from several domains. For example, a computational research project may combine a Python research environment with notebook support and a static documentation website.

## Command-Line Interface

The primary interface is the `forge` executable.

```bash
chmod +x bin/forge

# List all configured projects
bin/forge list

# Preview repository generation
bin/forge bootstrap math-machines --dry-run

# Generate without GitHub API operations
bin/forge bootstrap math-machines --no-github

# Bootstrap every project
bin/forge bootstrap all

# Apply repository conventions to an existing checkout
bin/forge apply math-machines
```

For compatibility with existing workflows, the top-level `forge.sh` script remains available as a convenience wrapper.

```bash
./forge.sh
```

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
