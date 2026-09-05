#!/usr/bin/env bash

DOCTOR_ERRORS=()
DOCTOR_WARNINGS=()

doctor_error() { DOCTOR_ERRORS+=("$1"); }
doctor_warning() { DOCTOR_WARNINGS+=("$1"); }

doctor_json_string() {
    local value="$1"
    value=${value//\\/\\\\}
    value=${value//\"/\\\"}
    value=${value//$'\n'/\\n}
    value=${value//$'\r'/\\r}
    value=${value//$'\t'/\\t}
    printf '"%s"' "$value"
}

doctor_json_array() {
    local -n values="$1"
    local value first=1
    printf '['
    for value in "${values[@]}"; do
        [ "$first" -eq 0 ] && printf ','
        doctor_json_string "$value"
        first=0
    done
    printf ']'
}

doctor_validate_manifest_shape() {
    local manifest_path="$1" target="$2"
    local line line_number=0 repo field_count
    local -A seen=()

    while IFS= read -r line || [ -n "$line" ]; do
        line_number=$((line_number + 1))
        [ -z "$line" ] && continue
        [[ "$line" =~ ^# ]] && continue
        repo="${line%%$'\t'*}"
        if [ -n "$target" ] && [ "$repo" != "$target" ]; then
            continue
        fi
        field_count="$(awk -F'\t' '{print NF}' <<<"$line")"
        if [ "$field_count" -ne 7 ]; then
            doctor_error "line $line_number ($repo): expected 7 tab-separated fields, found $field_count"
        fi
        if [ -n "${seen[$repo]:-}" ]; then
            doctor_error "duplicate repository name: $repo (lines ${seen[$repo]} and $line_number)"
        else
            seen[$repo]="$line_number"
        fi
    done <"$manifest_path"
}

doctor_validate_project() {
    local repo="$1" title description templates_csv starter_pack template requires dependency
    local -a templates dependencies

    title="$(project_title "$repo")"
    description="$(project_description "$repo")"
    templates_csv="$(project_templates_csv "$repo")"
    starter_pack="$(project_starter_pack "$repo")"

    [ -z "$title" ] && doctor_error "$repo: missing title"
    [ -z "$description" ] && doctor_error "$repo: missing description"
    [ -z "$templates_csv" ] && doctor_error "$repo: no templates configured"

    csv_to_array "$templates_csv" templates
    for template in "${templates[@]}"; do
        if [ ! -d "$FORGE_ROOT/templates/$template" ]; then
            doctor_error "$repo: unknown template: $template"
            continue
        fi
        if ! validate_template "$template" >/dev/null 2>&1; then
            doctor_error "$repo: invalid template: $template"
        fi
        requires="$(get_template_requires "$template")"
        csv_to_array "$requires" dependencies
        for dependency in "${dependencies[@]}"; do
            if [ ! -d "$FORGE_ROOT/templates/$dependency" ]; then
                doctor_error "$repo: template $template requires unknown template: $dependency"
            fi
        done
    done

    if [ -n "$starter_pack" ]; then
        if ! declare -f "starter_pack_${starter_pack//-/_}" >/dev/null 2>&1; then
            doctor_error "$repo: unknown starter pack: $starter_pack"
        fi
    fi
}

forge_doctor() {
    local manifest_path="$1" target="${2:-}" json="${3:-0}" repo
    DOCTOR_ERRORS=()
    DOCTOR_WARNINGS=()

    if [ ! -f "$manifest_path" ]; then
        doctor_error "manifest not found: $manifest_path"
    else
        doctor_validate_manifest_shape "$manifest_path" "$target"
        load_manifest "$manifest_path"
        if [ -n "$target" ] && ! project_exists "$target"; then
            doctor_error "repository not found in manifest: $target"
        else
            for repo in "${PROJECT_REPOS[@]}"; do
                [ -n "$target" ] && [ "$repo" != "$target" ] && continue
                doctor_validate_project "$repo"
            done
        fi
    fi

    if [ "$json" -eq 1 ]; then
        printf '{"ok":%s,"errors":' "$([ "${#DOCTOR_ERRORS[@]}" -eq 0 ] && printf true || printf false)"
        doctor_json_array DOCTOR_ERRORS
        printf ',"warnings":'
        doctor_json_array DOCTOR_WARNINGS
        printf '}\n'
    else
        for repo in "${DOCTOR_ERRORS[@]}"; do err "$repo"; done
        for repo in "${DOCTOR_WARNINGS[@]}"; do printf 'WARNING: %s\n' "$repo"; done
        if [ "${#DOCTOR_ERRORS[@]}" -eq 0 ]; then
            log "forge doctor: no errors (${#DOCTOR_WARNINGS[@]} warnings)"
        else
            err "forge doctor: ${#DOCTOR_ERRORS[@]} errors, ${#DOCTOR_WARNINGS[@]} warnings"
        fi
    fi

    [ "${#DOCTOR_ERRORS[@]}" -eq 0 ]
}
