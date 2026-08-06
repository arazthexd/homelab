#!/usr/bin/env bash
# Use sudo.
set -euo pipefail

source "../functions.sh"
load_env

bash scripts/apps/install_base_tools.sh
bash scripts/apps/install_docker.sh
bash scripts/apps/install_tailscale.sh
bash scripts/apps/install_syncthing.sh