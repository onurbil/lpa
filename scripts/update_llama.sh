#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib.sh"

REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/llama.cpp"
INSTALL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/install"
JOBS="${JOBS:-$(nproc 2>/dev/null || echo 4)}"

check_cpu()      { :; }
check_vulkan()   { need_cmd glslc || die "glslc not found. Install the Vulkan SDK / shaderc (e.g. 'apt install glslc libvulkan-dev vulkan-tools')."; }
check_nvidia()   { need_cmd nvcc  || die "nvcc not found. Install the CUDA Toolkit: https://developer.nvidia.com/cuda-downloads"; }
check_openvino() {
    if [ -z "${OpenVINO_DIR:-}" ] && [ -z "${INTEL_OPENVINO_DIR:-}" ]; then
        warn "OpenVINO environment not detected. Install OpenVINO and source setupvars.sh: https://github.com/ggml-org/llama.cpp/blob/master/docs/backend/OPENVINO.md"
    fi
}

do_cpu()      { check_cpu;      build_backend "$REPO_DIR" "$INSTALL_DIR" cpu; }
do_vulkan()   { check_vulkan;   build_backend "$REPO_DIR" "$INSTALL_DIR" vulkan   -DGGML_VULKAN=ON; }
do_nvidia()   { check_nvidia;   build_backend "$REPO_DIR" "$INSTALL_DIR" nvidia   -DGGML_CUDA=ON; }
do_openvino() { check_openvino; build_backend "$REPO_DIR" "$INSTALL_DIR" openvino -DGGML_OPENVINO=ON; }

run_backend() {
    case "$1" in
        1|cpu)         do_cpu ;;
        2|vulkan)      do_vulkan ;;
        3|nvidia|cuda) do_nvidia ;;
        4|openvino)    do_openvino ;;
        *) die "Unknown backend: $1" ;;
    esac
}

show_menu() {
    echo "" >&2
    echo "Select llama.cpp backend(s) to build (space separated, e.g. '1 3'):" >&2
    echo "  1. cpu" >&2
    echo "  2. vulkan" >&2
    echo "  3. nvidia" >&2
    echo "  4. openvino" >&2
    echo -n "> " >&2
    read -r choice
    echo "$choice"
}

main() {
    sync_repo "$REPO_DIR" "https://github.com/ggml-org/llama.cpp"
    if [ "$#" -gt 0 ]; then
        for arg in "$@"; do run_backend "$arg"; done
        exit 0
    fi
    choice="$(show_menu)"
    [ -n "$choice" ] || die "No selection made."
    for c in $choice; do run_backend "$c"; done
}
main "$@"