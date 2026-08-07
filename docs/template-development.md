# Template Development Guide

This guide explains how to create and maintain templates for the idea-forge repository generation system.

## Template Structure

Each template is a directory under `templates/` containing at minimum:

```
templates/my-template/
├── template.env      # Template identifier (required)
└── README.md         # Template documentation (recommended)
```

### template.env Format

The `template.env` file must contain exactly one line declaring the template ID:

```bash
TEMPLATE_ID=my-template
```

This ID must match the template directory name and will be used in manifest files.

## Implementing a Template Function

Templates are implemented as Bash functions in `lib/template_engine.sh`. The function name follows a strict convention:

```bash
template_apply_<template_name>() {
    local repo="$1"          # Repository name (e.g., "math-machines")
    local repo_path="$2"     # Full path to repository directory
    local package="$3"       # Package name in snake_case (e.g., "math_machines")
    local title="$4"         # Project title (e.g., "Math Machines")
    local description="$5"   # Short project description
    
    # Your template implementation here
}
```

**Important**: Template names use hyphens (e.g., `python-research`) but function names must use underscores (e.g., `template_apply_python_research`).

## Template Implementation Best Practices

### 1. Create Directory Structure

```bash
template_apply_my_template() {
    local repo="$1" repo_path="$2" package="$3" title="$4" description="$5"
    
    # Create necessary directories
    mkdir -p "$repo_path/src/$package"
    mkdir -p "$repo_path/tests"
    mkdir -p "$repo_path/docs"
}
```

### 2. Generate Configuration Files

Use heredocs for multi-line file generation:

```bash
cat > "$repo_path/config.yaml" <<EOF2
name: $title
description: $description
version: 0.1.0
EOF2
```

**Note**: The `EOF2` delimiter is used to avoid conflicts with the main script.

### 3. Set Makefile Targets

Templates should configure the standard make targets:

```bash
set_make_target <target> <command>      # Replace target entirely
append_make_target <target> <command>   # Chain with && to existing command
```

Standard targets:
- `init` - Install dependencies
- `lint` - Run linters
- `test` - Run test suite
- `benchmark` - Run benchmarks
- `docs` - Build documentation
- `format` - Format code
- `release` - Build release artifacts

Example:

```bash
template_apply_python_research() {
    # ... directory and file creation ...
    
    set_make_target init "python -m pip install --upgrade pip && pip install -e \".[dev]\""
    set_make_target lint "ruff check ."
    set_make_target test "pytest"
    set_make_target benchmark "python -m pytest benchmarks -q || true"
    set_make_target docs "echo \"Build docs with your chosen toolchain\""
    set_make_target format "ruff format ."
}
```

### 4. Handle Multiple Templates

Templates compose - a single repository may apply multiple templates. Design templates to:

- **Not overwrite** files created by earlier templates
- **Append** to shared make targets rather than replace them
- **Create unique directories** specific to the template's purpose

Example of composable template:

```bash
template_apply_notebook_laboratory() {
    local repo="$1" repo_path="$2" package="$3" title="$4" description="$5"
    
    # Create notebook-specific directories
    mkdir -p "$repo_path/notebooks"
    mkdir -p "$repo_path/data"
    
    # Append to existing init target (don't replace)
    append_make_target init "pip install jupyter jupyterlab"
    
    # Add notebook-specific target
    set_make_target notebook "jupyter lab notebooks/"
}
```

## Complete Template Example

Here's a minimal but complete template for a Go library:

### Step 1: Create Template Directory

```bash
mkdir -p templates/go-library
```

### Step 2: Add template.env

```bash
cat > templates/go-library/template.env <<EOF
TEMPLATE_ID=go-library
EOF
```

### Step 3: Add README

```bash
cat > templates/go-library/README.md <<EOF
# Go Library Template

Generates Go library structure with:
- Go module initialization
- Package directory structure
- Basic testing setup
- Standard make targets
EOF
```

### Step 4: Implement Function in lib/template_engine.sh

```bash
template_apply_go_library() {
    local repo="$1" repo_path="$2" package="$3" title="$4" description="$5"
    
    # Create directory structure
    mkdir -p "$repo_path/pkg/$package"
    mkdir -p "$repo_path/cmd/$repo"
    mkdir -p "$repo_path/tests"
    
    # Initialize Go module
    cat > "$repo_path/go.mod" <<EOF2
module github.com/standardgalactic/$repo

go 1.22

require ()
EOF2
    
    # Create main package file
    cat > "$repo_path/pkg/$package/${package}.go" <<'EOF2'
package ${package}

// Package implements ...
EOF2
    
    # Create test file
    cat > "$repo_path/pkg/$package/${package}_test.go" <<'EOF2'
package ${package}

import "testing"

func TestSmoke(t *testing.T) {
    // Smoke test passes
}
EOF2
    
    # Set Makefile targets
    set_make_target init "go mod download"
    set_make_target lint "go vet ./..."
    set_make_target test "go test -v ./..."
    set_make_target benchmark "go test -bench=. ./..."
    set_make_target docs "go doc -all ."
    set_make_target format "gofmt -w ."
    set_make_target release "go build -o bin/$repo ./cmd/$repo"
}
```

## Testing Your Template

### 1. Validate Template Structure

Templates are automatically validated before application. The validation checks:
- Template directory exists
- `template.env` exists and has correct format
- Template function is implemented

### 2. Test with Dry Run

```bash
# Add template to a manifest entry
# Edit manifests/projects.tsv:
# test-repo	Test Project	Testing...	test	my-template		Summary

# Preview generation
bin/forge bootstrap test-repo --dry-run --no-github
```

### 3. Test Local Generation

```bash
# Generate locally without GitHub
bin/forge bootstrap test-repo --no-github --root /tmp/test-forge

# Inspect the generated repository
ls -la /tmp/test-forge/test-repo
```

### 4. Test Generated Makefile

```bash
cd /tmp/test-forge/test-repo
make init
make lint
make test
```

## Template Naming Conventions

- **Template Directory**: Use kebab-case (`python-research`, `rust-workspace`)
- **template.env ID**: Match directory name exactly
- **Function Name**: Convert hyphens to underscores (`template_apply_python_research`)
- **Repo Name**: kebab-case (`math-machines`)
- **Package Name**: snake_case (`math_machines`) - automatically converted

## Advanced Features

### Template Dependencies

Templates can specify dependencies (coming soon):

```bash
# In template.env
TEMPLATE_ID=advanced-python
TEMPLATE_REQUIRES=python-research,static-website
```

### Workflow Flavors

Add workflow variations (experimental feature):

```bash
add_workflow_flavor "python-ci"
add_workflow_flavor "docker-build"
```

## Common Pitfalls

### ❌ Don't: Hardcode Paths

```bash
# Bad
mkdir -p ~/github/my-repo/src
```

```bash
# Good
mkdir -p "$repo_path/src"
```

### ❌ Don't: Overwrite Existing Make Targets

```bash
# Bad - wipes out previous template's work
set_make_target init "npm install"
```

```bash
# Good - chains with previous commands
append_make_target init "npm install"
```

### ❌ Don't: Use Template Names with Underscores

```bash
# Bad - breaks convention
templates/python_research/

# Good
templates/python-research/
```

### ✅ Do: Check for Existing Files

```bash
if [ ! -f "$repo_path/config.yaml" ]; then
    cat > "$repo_path/config.yaml" <<EOF2
...
EOF2
fi
```

### ✅ Do: Use Defensive Programming

```bash
mkdir -p "$repo_path/src"  # Create parent dirs if needed
[ -d "$repo_path/src" ] || { err "Failed to create src/"; return 1; }
```

## Manifest Integration

Add your template to `manifests/projects.tsv`:

```tsv
repo-name	Project Title	Short description	topic1,topic2	template1,template2	starter_pack	Long summary paragraph
```

Templates are applied in the order listed (left to right).

## Getting Help

- Check existing templates in `templates/` for examples
- Review `lib/template_engine.sh` for helper functions
- Test thoroughly with `--dry-run` and `--no-github` before committing
- Ask in GitHub Discussions or open an issue

## Checklist for New Templates

- [ ] Create `templates/<template-name>/` directory
- [ ] Add `template.env` with `TEMPLATE_ID=<template-name>`
- [ ] Add `README.md` documenting the template
- [ ] Implement `template_apply_<template_name>()` in `lib/template_engine.sh`
- [ ] Use `set_make_target` or `append_make_target` for all standard targets
- [ ] Test with `--dry-run`
- [ ] Test local generation with `--no-github`
- [ ] Verify generated `make` commands work
- [ ] Test template composition with other templates
- [ ] Add to a manifest entry and test full bootstrap
- [ ] Document template in main README if adding to template catalog
