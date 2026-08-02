#!/usr/bin/env bash
#
# build.sh - Interactive builder for llama.cpp with selectable backend.
#
# Usage:
#   ./update.sh            # interactive menu
#   ./update.sh vulkan     # non-interactive, build a specific backend
#   ./update.sh cpu nvidia # non-interactive, build several backends in sequence
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
REPO_DIR="$SCRIPT_DIR/llama.cpp"
JOBS="${JOBS:-$(nproc 2>/dev/null || echo 4)}"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

log()  { printf '\033[1;34m[build]\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m[warn ]\033[0m %s\n' "$1"; }
die()  { printf '\033[1;31m[error]\033[0m %s\n' "$1"; exit 1; }

need_cmd() {
    command -v "$1" >/dev/null 2>&1
}

sync_repo() {
    if [ ! -d "$REPO_DIR/.git" ]; then
        log "llama.cpp repo not found at $REPO_DIR, cloning..."
        git clone https://github.com/ggml-org/llama.cpp "$REPO_DIR"
    else
        log "Updating llama.cpp repo..."
        git -C "$REPO_DIR" pull
    fi
}

# Runs cmake configure + build + install for a given backend.
#   $1 = backend name (used for build/install dir naming)
#   remaining args = extra -D... cmake flags
build_backend() {
    local name="$1"; shift
    local build_dir="$REPO_DIR/build_${name}"
    local install_dir="$SCRIPT_DIR/install"

    log "Configuring backend: $name"
    cmake -S "$REPO_DIR" \
          -B "$build_dir" \
          -DCMAKE_BUILD_TYPE=Release \
          -DCMAKE_INSTALL_PREFIX="$install_dir" \
          "$@"

    log "Building backend: $name (jobs=$JOBS)"
    cmake --build "$build_dir" -j"$JOBS"

    log "Installing backend: $name -> $install_dir"
    cmake --install "$build_dir"

    log "Done: $name installed to $install_dir"
}

# ---------------------------------------------------------------------------
# Backend definitions
# ---------------------------------------------------------------------------

check_cpu()      { :; }  # no special dependency

check_vulkan() {
    need_cmd glslc || die "glslc not found. Install the Vulkan SDK / shaderc (e.g. 'apt install glslc libvulkan-dev vulkan-tools' or download from https://vulkan.lunarg.com)."
}

check_nvidia() {
    need_cmd nvcc || die "nvcc not found. Install the CUDA Toolkit first: https://developer.nvidia.com/cuda-downloads"
}

check_openvino() {
    if [ -z "${OpenVINO_DIR:-}" ] && [ -z "${INTEL_OPENVINO_DIR:-}" ]; then
        warn "OpenVINO environment not detected. Make sure to install OpenVINO and source its setupvars.sh:"
        warn "  https://github.com/ggml-org/llama.cpp/blob/master/docs/backend/OPENVINO.md"
    fi
}

do_cpu()      { check_cpu;      build_backend cpu; }
do_vulkan()   { check_vulkan;   build_backend vulkan   -DGGML_VULKAN=ON; }
do_nvidia()   { check_nvidia;   build_backend nvidia   -DGGML_CUDA=ON; }
do_openvino() { check_openvino; build_backend openvino -DGGML_OPENVINO=ON; }

run_backend() {
    case "$1" in
        1|cpu)      do_cpu ;;
        2|vulkan)   do_vulkan ;;
        3|nvidia|cuda) do_nvidia ;;
        4|openvino) do_openvino ;;
        *) die "Unknown backend: $1" ;;
    esac
}

# ---------------------------------------------------------------------------
# Menu
# ---------------------------------------------------------------------------

show_menu() {
    echo "" >&2
    echo "Select backend(s) to build (space separated, e.g. '1 3'):" >&2
    echo "  1. cpu" >&2
    echo "  2. vulkan" >&2
    echo "  3. nvidia" >&2
    echo "  4. openvino" >&2
    echo -n "> " >&2

    read -r choice
    echo "$choice"
}

main() {
    sync_repo

    if [ "$#" -gt 0 ]; then
        for arg in "$@"; do
            run_backend "$arg"
        done
        exit 0
    fi

    choice="$(show_menu)"
    if [ -z "$choice" ]; then
        die "No selection made."
    fi

    for c in $choice; do
        run_backend "$c"
    done
}

main "$@"