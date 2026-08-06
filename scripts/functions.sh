#!/usr/bin/env bash

find_repo_root() {
    local dir
    dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    while [ ! -f "$dir/.env.example" ] && [ "$dir" != "/" ]; do
        dir="$(dirname "$dir")"
    done
    if [ ! -f "$dir/.env.example" ]; then
        echo "Error: Could not find repo root (.env.example not found)" >&2
        return 1
    fi
    echo "$dir"
}

load_env() {
    local repo_root
    repo_root="$(find_repo_root)" || return 1
    if [ -f "$repo_root/.env" ]; then
        source "$repo_root/.env"
    fi
}