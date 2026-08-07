#!/usr/bin/env bash

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"
source "$FORGE_ROOT/lib/manifest.sh"
source "$FORGE_ROOT/lib/template_engine.sh"
source "$FORGE_ROOT/lib/scaffold_base.sh"
source "$FORGE_ROOT/lib/scaffold_docs.sh"
source "$FORGE_ROOT/lib/scaffold_github.sh"
source "$FORGE_ROOT/lib/scaffold_build.sh"
source "$FORGE_ROOT/lib/starter_packs.sh"
source "$FORGE_ROOT/lib/github.sh"

forge_prepare_repo_dir() {
    local root="$1" repo="$2" branch="$3" owner="$4" enable_github="$5"
    local path="$root/$repo"

    mkdir -p "$root"

    if [ -d "$path/.git" ]; then
        log "Local repository already exists: $path"
        printf '%s' "$path"
        return 0
    fi

    if [ -d "$path" ] && [ "$(find "$path" -mindepth 1 -maxdepth 1 | wc -l)" -gt 0 ]; then
        err "Directory exists and is not empty: $path"
        return 1
    fi

    mkdir -p "$path"

    (
        cd "$path"
        git init --initial-branch="$branch" >/dev/null
        if [ "$enable_github" = "1" ]; then
            git remote add origin "git@github.com:$owner/$repo.git"
        fi
    )

    printf '%s' "$path"
}

forge_generate_project() {
    local owner="$1" repo="$2" repo_path="$3"
    local title="$4" description="$5" summary="$6" templates_csv="$7" starter_pack="$8"

    local package
    package="$(slug_to_pkg "$repo")"

    generation_reset

    local -a templates
    csv_to_array "$templates_csv" templates
    
    # Resolve template dependencies
    log "Resolving template dependencies..."
    templates_csv=$(resolve_template_dependencies "$templates_csv")
    csv_to_array "$templates_csv" templates
    log "Templates to apply (with dependencies): ${templates[*]}"
    
    # Validate all templates before applying any
    for template in "${templates[@]}"; do
        if ! validate_template "$template"; then
            err "Template validation failed for: $template"
            return 1
        fi
    done
    
    # Apply validated templates
    for template in "${templates[@]}"; do
        log "Applying template: $template"
        apply_template "$template" "$repo" "$repo_path" "$package" "$title" "$description"
    done

    write_readme "$repo_path" "$title" "$description" "$summary"
    write_license "$repo_path"
    write_gitignore "$repo_path"
    write_governance_docs "$repo_path" "$title" "$description"
    write_citation "$repo_path" "$owner" "$repo" "$title"
    write_docs_baseline "$repo_path" "$summary"
    write_issue_templates "$repo_path"
    write_pr_template "$repo_path"
    write_workflows "$repo_path"
    write_makefile "$repo_path"

    apply_starter_pack "$starter_pack" "$repo_path" "$package"
}

forge_commit_and_push() {
    local repo_path="$1" branch="$2" enable_github="$3"

    (
        cd "$repo_path"
        git add .
        if ! git diff --cached --quiet; then
            git commit -m "Establish template-driven project structure" >/dev/null
        fi

        if [ "$enable_github" = "1" ]; then
            git push -u origin "$branch"
        fi
    )
}

forge_bootstrap_repo() {
    local manifest_path="$1" owner="$2" root="$3" branch="$4" repo="$5" enable_github="$6" dry_run="$7"

    if ! project_exists "$repo"; then
        err "Repository not found in manifest: $repo"
        return 1
    fi

    local title description topics templates starter_pack summary
    title="$(project_title "$repo")"
    description="$(project_description "$repo")"
    topics="$(project_topics_csv "$repo")"
    templates="$(project_templates_csv "$repo")"
    starter_pack="$(project_starter_pack "$repo")"
    summary="$(project_summary "$repo")"

    log "============================================================"
    log "$title"
    log "$owner/$repo"
    log "============================================================"

    if [ "$dry_run" = "1" ]; then
        log ""
        log "DRY RUN - Preview of repository generation"
        log "=========================================="
        log ""
        log "Repository Details:"
        log "  Name: $repo"
        log "  Owner: $owner"
        log "  Title: $title"
        log "  Description: $description"
        log "  Path: $root/$repo"
        log ""
        log "Templates to Apply:"
        local -a template_list
        csv_to_array "$templates" template_list
        for tmpl in "${template_list[@]}"; do
            log "  - $tmpl"
        done
        log ""
        if [ -n "$starter_pack" ]; then
            log "Starter Pack: $starter_pack"
            log ""
        fi
        log "Files to Generate:"
        log "  - README.md (project description and make commands)"
        log "  - LICENSE (MIT License)"
        log "  - .gitignore (multi-language)"
        log "  - CHANGELOG.md, ROADMAP.md, SECURITY.md"
        log "  - CODE_OF_CONDUCT.md, CONTRIBUTING.md"
        log "  - CITATION.cff (citation metadata)"
        log "  - Makefile (init, lint, test, benchmark, docs, format, release)"
        log "  - .github/ISSUE_TEMPLATE/ (bug, feature, experiment, docs)"
        log "  - .github/PULL_REQUEST_TEMPLATE.md"
        log "  - .github/workflows/ (ci.yml, lint.yml, docs.yml, release.yml)"
        log "  - docs/ (architecture.md, roadmap.md, bibliography.md)"
        log ""
        if [ "$enable_github" = "1" ]; then
            log "GitHub Operations:"
            log "  - Create repository if it doesn't exist"
            log "  - Set description and topics"
            log "  - Push initial commit to branch: $branch"
            log "  - Configure labels (experiment, research, etc.)"
        else
            log "GitHub Operations: Skipped (--no-github)"
        fi
        log ""
        log "=========================================="
        return 0
    fi

    create_repo_if_needed "$owner" "$repo" "$description" "$enable_github"

    local repo_path
    repo_path="$(forge_prepare_repo_dir "$root" "$repo" "$branch" "$owner" "$enable_github")" || return 1

    forge_generate_project "$owner" "$repo" "$repo_path" "$title" "$description" "$summary" "$templates" "$starter_pack"
    forge_commit_and_push "$repo_path" "$branch" "$enable_github"

    setup_topics "$owner" "$repo" "$topics" "$enable_github"
    setup_labels "$owner" "$repo" "$enable_github"
    update_repo_settings "$owner" "$repo" "$description" "$enable_github"

    log "Complete: $owner/$repo"
}

forge_bootstrap_all() {
    local manifest_path="$1" owner="$2" root="$3" branch="$4" enable_github="$5" dry_run="$6"

    load_manifest "$manifest_path"

    for repo in "${PROJECT_REPOS[@]}"; do
        forge_bootstrap_repo "$manifest_path" "$owner" "$root" "$branch" "$repo" "$enable_github" "$dry_run"
    done
}

forge_list() {
    local manifest_path="$1"
    load_manifest "$manifest_path"
    list_repos
}
