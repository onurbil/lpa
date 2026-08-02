#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installing lpa..."

chmod +x "$SCRIPT_DIR/lpa"
chmod +x "$SCRIPT_DIR/scripts/"*.sh

echo "Building llama.cpp..."
"$SCRIPT_DIR/scripts/update.sh"

echo "Creating global command..."

sudo ln -sf "$SCRIPT_DIR/lpa" /usr/local/bin/lpa

echo
echo "Installation complete."
echo
echo "Run:"
echo "  lpa help"


