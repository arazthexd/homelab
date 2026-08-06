#!/usr/bin/env bash
# Use sudo.
set -euo pipefail

source "../functions.sh"
load_env

echo "== Installing base tools =="
apt-get install -y ca-certificates curl gnupg git ufw
echo "Done!"
echo