#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC2034 # shared defaults consumed by sourcing scripts
FORGE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck disable=SC2034 # shared defaults consumed by sourcing scripts
DEFAULT_OWNER="standardgalactic"
# shellcheck disable=SC2034 # shared defaults consumed by sourcing scripts
DEFAULT_ROOT="${HOME}/github"
# shellcheck disable=SC2034 # shared defaults consumed by sourcing scripts
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
    # shellcheck disable=SC2034 # nameref is assigned via read -a below
    local -n out_ref="$2"
    out_ref=()
    [ -z "$input" ] && return
    # shellcheck disable=SC2034 # nameref receives data from read -a
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
