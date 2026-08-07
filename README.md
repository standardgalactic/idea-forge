# idea-forge

Template-driven repository forge for research organizations.

## What changed

This project now behaves like a small build system for repository bootstrapping:

- Manifest-driven project metadata (`/home/runner/work/idea-forge/idea-forge/manifests/projects.tsv`)
- Composable templates (`/home/runner/work/idea-forge/idea-forge/templates/<template-name>`)
- Modular shell architecture (`/home/runner/work/idea-forge/idea-forge/lib/*.sh`)
- Reusable CLI (`/home/runner/work/idea-forge/idea-forge/bin/forge`)
- Optional starter content packs for selected projects

## Template catalog

- python-research
- rust-library
- rust-workspace
- c-library
- c-kernel
- latex-book
- latex-paper
- javascript-webapp
- notebook-laboratory
- static-website

Templates can be composed per project by listing multiple template IDs in the manifest.

## CLI

```bash
chmod +x /home/runner/work/idea-forge/idea-forge/bin/forge

# list manifest projects
/home/runner/work/idea-forge/idea-forge/bin/forge list

# dry-run one project
/home/runner/work/idea-forge/idea-forge/bin/forge bootstrap math-machines --dry-run

# bootstrap one project without GitHub API calls
/home/runner/work/idea-forge/idea-forge/bin/forge bootstrap math-machines --no-github

# bootstrap all projects
/home/runner/work/idea-forge/idea-forge/bin/forge bootstrap all

# apply conventions in an existing repo checkout
/home/runner/work/idea-forge/idea-forge/bin/forge apply math-machines
```

## Backward compatibility

`/home/runner/work/idea-forge/idea-forge/forge.sh` remains as a wrapper that calls:

```bash
/home/runner/work/idea-forge/idea-forge/bin/forge bootstrap all
```

## Generated baseline

Every repository receives:

- Governance/lifecycle docs: CHANGELOG, ROADMAP, SECURITY, STYLE, AUTHORS, ACKNOWLEDGEMENTS, CODE_OF_CONDUCT, CONTRIBUTING, CITATION
- Standard `.github` content: issue forms, workflows (`ci`, `lint`, `docs`, `release`), PR template
- Standard Makefile interface:
  - `make init`
  - `make lint`
  - `make test`
  - `make benchmark`
  - `make docs`
  - `make format`
  - `make release`

Template stacks map these common targets to project-specific internals.
