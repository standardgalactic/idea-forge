#!/usr/bin/env bash

set -euo pipefail

FORGE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEFAULT_OWNER="standardgalactic"
DEFAULT_ROOT="${HOME}/github"
DEFAULT_BRANCH="main"

log() { printf '%s\n' "$*"; }
err() { printf 'ERROR: %s\n' "$*" >&2; }

require() {
    command -v "$1" >/dev/null 2>&1 || {
        err "Missing required command: $1"
        exit 1
    }
}

slug_to_pkg() {
    echo "$1" | tr '-' '_'
}

csv_to_array() {
    local input="$1"
    local -n out_ref="$2"
    out_ref=()
    [ -z "$input" ] && return
    IFS=',' read -r -a out_ref <<<"$input"
}

join_by() {
    local delim="$1"
    shift
    local first=1
    for part in "$@"; do
        if [ "$first" -eq 1 ]; then
            printf '%s' "$part"
            first=0
        else
            printf '%s%s' "$delim" "$part"
        fi
    done
}

write_file() {
    local path="$1"
    shift
    mkdir -p "$(dirname "$path")"
    cat >"$path"
}
