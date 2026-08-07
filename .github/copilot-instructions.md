# Copilot Instructions for idea-forge

## Project Overview

Idea Forge is a template-driven repository generation system for research organizations. It creates consistent, well-documented repositories from composable templates. The system generates projects with documentation, testing infrastructure, CI/CD workflows, and development tooling already configured.

## Commands

All work happens through the `bin/forge` executable:

```bash
# List configured projects from manifest
bin/forge list

# Bootstrap a single repository
bin/forge bootstrap <repo-name>

# Bootstrap all repositories in manifest
bin/forge bootstrap all

# Options
--manifest path      # Use alternate manifest file
--owner owner        # Set GitHub owner (default: standardgalactic)
--root path          # Set local root directory (default: ~/github)
--branch name        # Set default branch (default: main)
--no-github          # Skip GitHub API operations
--dry-run           # Preview without creating

# Re-apply templates to existing local repository
bin/forge apply <repo-name>
```

The legacy `./forge.sh` wrapper runs `bin/forge bootstrap all`.

## Architecture

### Core Components

**bin/forge** - Main CLI entry point that orchestrates all operations

**lib/** - Bash library modules:
- `common.sh` - Shared utilities, logging, path helpers
- `forge.sh` - Repository bootstrapping orchestration
- `manifest.sh` - TSV manifest parsing and project metadata extraction
- `template_engine.sh` - Template application system with composable functions
- `scaffold.sh` - Shared file generators (README, LICENSE, docs, workflows, Makefile)
- `starter_packs.sh` - Optional domain-specific starter content
- `github.sh` - GitHub API operations via `gh` CLI

**manifests/projects.tsv** - Tab-separated project definitions with columns:
- repo, title, description, topics (CSV), templates (CSV), starter_pack, summary

**templates/** - Template directories each containing:
- `template.env` - Single-line `TEMPLATE_ID=name` declaration
- `README.md` - Template-specific documentation

### Template System

Templates are implemented as Bash functions in `lib/template_engine.sh`:

```bash
template_apply_<template_name>() {
    local repo="$1" repo_path="$2" package="$3" title="$4" description="$5"
    # Create project structure
    # Generate config files
    # Set/append Makefile targets via set_make_target or append_make_target
    # Add CI workflow flavors via add_workflow_flavor
}
```

Template names use hyphens (e.g., `python-research`) but function names convert to underscores (e.g., `template_apply_python_research`).

Available templates:
- `python-research` - Python packages with pytest, ruff
- `rust-library` - Single-crate Rust libraries with cargo
- `rust-workspace` - Multi-crate Rust workspaces
- `c-library` - C libraries with make
- `c-kernel` - C kernel/OS projects
- `latex-book` - LaTeX books with pdflatex
- `latex-paper` - LaTeX papers with pdflatex
- `javascript-webapp` - Node.js webapps with npm
- `notebook-laboratory` - Jupyter notebook environments
- `static-website` - Static sites with basic HTTP serving

### Makefile Interface

All generated repositories expose a common interface:

```bash
make init       # Install dependencies
make lint       # Run linters
make test       # Run test suite
make benchmark  # Run benchmarks
make docs       # Build documentation
make format     # Format code
make release    # Build release artifacts
```

Templates set these targets using:
- `set_make_target <target> <command>` - Replace target
- `append_make_target <target> <command>` - Chain with `&&`

### Generation Flow

1. **Manifest parsing** (`load_manifest`) - Parse TSV into associative arrays
2. **Repository preparation** (`forge_prepare_repo_dir`) - Create/verify local directory, init Git
3. **GitHub setup** (`create_repo_if_needed`, `setup_topics`, `setup_labels`) - Create remote if needed
4. **Template application** (`apply_template`) - Call each template's function sequentially
5. **Shared scaffolding** - Generate common files (README, LICENSE, docs, workflows, Makefile)
6. **Starter pack** (`apply_starter_pack`) - Populate with domain-specific code if specified
7. **Commit and push** (`forge_commit_and_push`) - Commit with standard message, push to remote

### Starter Packs

Optional content generators in `lib/starter_packs.sh` that populate new repositories with working code:

```bash
starter_pack_<name>() {
    local repo_path="$1" package="$2"
    # Create source files with example implementations
}
```

Available starter packs:
- `math-machines` - Turing machines, lambda calculus, automata implementations
- `constraint-games` - Sudoku, Lights Out, puzzle solvers
- `algorithm-zoo` - Sorting, graphs, dynamic programming examples

### Common Scaffolding

`lib/scaffold.sh` provides generators called by all projects:

- `write_readme` - README.md with description and make commands
- `write_license` - MIT License with Flyxion copyright
- `write_gitignore` - Multi-language .gitignore
- `write_governance_docs` - CHANGELOG, ROADMAP, SECURITY, STYLE, AUTHORS, ACKNOWLEDGEMENTS, CODE_OF_CONDUCT, CONTRIBUTING
- `write_citation` - CITATION.cff metadata
- `write_docs_baseline` - docs/ directory with architecture.md, roadmap.md, bibliography.md
- `write_issue_templates` - GitHub issue templates (bug, feature, experiment, documentation)
- `write_pr_template` - GitHub pull request template
- `write_workflows` - GitHub Actions (ci.yml, lint.yml, docs.yml, release.yml)
- `write_makefile` - Makefile with target commands from MAKE_TARGETS array

## Key Conventions

### Template Composition

Projects can combine multiple templates. Each template:
- Creates its own directory structure
- Generates language-specific config files
- Sets or appends to shared Makefile targets
- Does not overwrite files from earlier templates

Templates are applied in the order specified in the manifest.

### Name Transformations

- Repository names use kebab-case: `math-machines`
- Python packages use snake_case: `math_machines` (via `slug_to_pkg`)
- Rust crates use snake_case: `math_machines`
- Template function names use snake_case: `template_apply_python_research`

### GitHub Integration

When `--no-github` is not set, the system:
- Requires `gh` CLI authentication
- Creates remote repositories if they don't exist
- Sets repository description, topics, and labels
- Pushes initial commit to the default branch

Custom labels added:
- `experiment` - Purple (#5319e7)
- `research` - Blue (#0052cc)
- `documentation` - Blue (#0075ca)
- `good first experiment` - Purple (#7057ff)

### State Management

The template engine uses global state:
- `MAKE_TARGETS` - Associative array of Makefile target commands
- `TEMPLATE_WORKFLOWS` - Array of workflow flavors (not currently used in workflow generation)

These are reset at the start of each project generation via `generation_reset()`.

### Error Handling

- All scripts use `set -euo pipefail`
- Missing required commands abort with `require <command>`
- Missing template implementations abort with error
- Non-empty non-git directories abort to prevent data loss

## Working with This Codebase

### Adding a New Template

1. Create `templates/<template-name>/` directory
2. Add `template.env` with `TEMPLATE_ID=<template-name>`
3. Add `README.md` describing the template
4. Implement `template_apply_<template_name>()` in `lib/template_engine.sh`:
   - Create directory structure
   - Generate config files
   - Set Makefile targets
5. Test with a manifest entry using the new template

### Adding a New Starter Pack

1. Implement `starter_pack_<name>()` in `lib/starter_packs.sh`
2. Create source files with example code
3. Use in manifest by setting the `starter_pack` column

### Modifying Shared Scaffolding

Edit functions in `lib/scaffold.sh`. Changes affect all newly generated repositories.

### Testing Changes

Use `--dry-run` to preview without creating:
```bash
bin/forge bootstrap <repo> --dry-run
```

Use `--no-github` to test local generation without GitHub API:
```bash
bin/forge bootstrap <repo> --no-github
```

Use `apply` to re-run generation in an existing checkout:
```bash
cd ~/github/<repo>
bin/forge apply <repo>
```

### Manifest Format

`manifests/projects.tsv` is tab-separated with no header row (first line is commented):

```tsv
# repo	title	description	topics	templates	starter_pack	summary
my-project	My Project	Short description	topic1,topic2	python-research,notebook-laboratory	math-machines	Longer summary paragraph
```

Empty columns are allowed (just tabs with no content).
