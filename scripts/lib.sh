#!/usr/bin/env bash
# scripts/lib.sh - shared helpers for update_*.sh scripts

log()  { printf '\033[1;34m[build]\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m[warn ]\033[0m %s\n' "$1"; }
die()  { printf '\033[1;31m[error]\033[0m %s\n' "$1"; exit 1; }
need_cmd() { command -v "$1" >/dev/null 2>&1; }

sync_repo() {
    # $1 = repo dir, $2 = repo url, $3 = optional extra clone args (e.g. --recursive)
    local dir="$1" url="$2" extra="${3:-}"
    if [ ! -d "$dir/.git" ]; then
        log "Repo not found at $dir, cloning..."
        git clone $extra "$url" "$dir"
    else
        log "Updating repo at $dir..."
        git -C "$dir" pull
        if [ -n "$extra" ]; then
            git -C "$dir" submodule update --init --recursive
        fi
    fi
}

build_backend() {
    # $1 = repo dir, $2 = install dir, $3 = backend name, remaining = cmake flags
    local repo_dir="$1" install_dir="$2" name="$3"; shift 3
    local build_dir="$repo_dir/build_${name}"

    log "Configuring backend: $name"
    cmake -S "$repo_dir" -B "$build_dir" \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$install_dir" \
        "$@"

    log "Building backend: $name (jobs=$JOBS)"
    cmake --build "$build_dir" -j"$JOBS"

    log "Installing backend: $name -> $install_dir"
    cmake --install "$build_dir"
    log "Done: $name installed to $install_dir"
}