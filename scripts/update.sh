#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

target_script() {
    case "$1" in
        1|llama|llama.cpp) echo "$SCRIPT_DIR/update_llama.sh" ;;
        2|sd|stable-diffusion|stable-diffusion.cpp) echo "$SCRIPT_DIR/update_sd.sh" ;;
        *) echo "" ;;
    esac
}

show_target_menu() {
    echo "" >&2
    echo "Select component(s) to build (space separated, e.g. '1 2'):" >&2
    echo "  1. llama.cpp" >&2
    echo "  2. stable-diffusion.cpp" >&2
    echo -n "> " >&2
    read -r choice
    echo "$choice"
}

# Non-interactive: first arg picks the component, the rest are backend args
# passed straight through, e.g.:
#   scripts/update.sh llama vulkan nvidia
#   scripts/update.sh sd cuda
if [ "$#" -gt 0 ]; then
    target="$1"; shift
    script="$(target_script "$target")"
    [ -n "$script" ] || { echo "Unknown component: $target" >&2; exit 1; }
    exec "$script" "$@"
fi

# Interactive: pick one or more components, each then shows its own backend menu
choice="$(show_target_menu)"
[ -n "$choice" ] || { echo "No selection made." >&2; exit 1; }

for c in $choice; do
    script="$(target_script "$c")"
    if [ -z "$script" ]; then
        echo "Unknown component: $c" >&2
        continue
    fi
    "$script"
done