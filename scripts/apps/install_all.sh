#!/usr/bin/env bash
# Use sudo.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/../.."
source "$ROOT_DIR/.env"

bash $SCRIPT_DIR/install_base_tools.sh
bash $SCRIPT_DIR/install_docker.sh
bash $SCRIPT_DIR/install_tailscale.sh
bash $SCRIPT_DIR/install_syncthing.sh