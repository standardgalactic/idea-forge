#!/usr/bin/env bash

declare -a PROJECT_REPOS=()
declare -A PROJECT_RECORDS=()

record_sep=$'\x1f'

load_manifest() {
    local manifest_path="$1"
    local repo title description topics templates starter_pack summary line
    PROJECT_REPOS=()
    unset PROJECT_RECORDS
    declare -gA PROJECT_RECORDS=()

    while IFS= read -r line; do
        [ -z "$line" ] && continue
        [[ "$line" =~ ^# ]] && continue

        # Use awk to properly handle empty fields between tabs
        repo="$(echo "$line" | awk -F'\t' '{print $1}')"
        title="$(echo "$line" | awk -F'\t' '{print $2}')"
        description="$(echo "$line" | awk -F'\t' '{print $3}')"
        topics="$(echo "$line" | awk -F'\t' '{print $4}')"
        templates="$(echo "$line" | awk -F'\t' '{print $5}')"
        starter_pack="$(echo "$line" | awk -F'\t' '{print $6}')"
        summary="$(echo "$line" | awk -F'\t' '{print $7}')"

        [ -z "$repo" ] && continue

        PROJECT_REPOS+=("$repo")
        PROJECT_RECORDS["$repo"]="${title}${record_sep}${description}${record_sep}${topics}${record_sep}${templates}${record_sep}${starter_pack}${record_sep}${summary}"
    done <"$manifest_path"
}

project_exists() {
    local repo="$1"
    [ -n "${PROJECT_RECORDS[$repo]:-}" ]
}

project_field() {
    local repo="$1"
    local index="$2"
    local rec="${PROJECT_RECORDS[$repo]:-}"
    [ -z "$rec" ] && return 1

    local -a parts
    IFS="$record_sep" read -r -a parts <<<"$rec"
    printf '%s' "${parts[$index]:-}"
}

project_title() { project_field "$1" 0; }
project_description() { project_field "$1" 1; }
project_topics_csv() { project_field "$1" 2; }
project_templates_csv() { project_field "$1" 3; }
project_starter_pack() { project_field "$1" 4; }
project_summary() { project_field "$1" 5; }

list_repos() {
    printf '%s\n' "${PROJECT_REPOS[@]}"
}
