#!/usr/bin/env bash

gh_require_auth() {
    require gh
    if ! gh auth status >/dev/null 2>&1; then
        err "GitHub CLI is not authenticated. Run: gh auth login"
        exit 1
    fi
}

create_repo_if_needed() {
    local owner="$1" repo="$2" description="$3" enable_github="$4"

    [ "$enable_github" = "0" ] && return

    if gh repo view "$owner/$repo" >/dev/null 2>&1; then
        log "Remote repository already exists: $owner/$repo"
    else
        gh repo create "$owner/$repo" --public --description "$description"
    fi
}

setup_topics() {
    local owner="$1" repo="$2" topics_csv="$3" enable_github="$4"
    [ "$enable_github" = "0" ] && return

    local -a topics args
    csv_to_array "$topics_csv" topics
    args=()
    for topic in "${topics[@]}"; do
        args+=(--add-topic "$topic")
    done
    [ "${#args[@]}" -eq 0 ] && return

    gh repo edit "$owner/$repo" "${args[@]}" >/dev/null
}

setup_labels() {
    local owner="$1" repo="$2" enable_github="$3"
    [ "$enable_github" = "0" ] && return

    gh label create "experiment" --repo "$owner/$repo" --description "Experimental implementation or investigation" --color "5319e7" --force >/dev/null 2>&1 || true
    gh label create "research" --repo "$owner/$repo" --description "Research, references, or theoretical discussion" --color "0052cc" --force >/dev/null 2>&1 || true
    gh label create "documentation" --repo "$owner/$repo" --description "Documentation improvements" --color "0075ca" --force >/dev/null 2>&1 || true
    gh label create "good first experiment" --repo "$owner/$repo" --description "Suitable introductory experiment" --color "7057ff" --force >/dev/null 2>&1 || true
}

update_repo_settings() {
    local owner="$1" repo="$2" description="$3" enable_github="$4"
    [ "$enable_github" = "0" ] && return

    gh repo edit "$owner/$repo" --description "$description" --enable-issues >/dev/null
}
