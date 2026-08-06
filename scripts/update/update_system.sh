#!/usr/bin/env bash
# Use sudo.
set -euo pipefail

source "../functions.sh"
load_env

echo "== Updating system =="
apt-get update
apt-get upgrade -y
echo "Done!"
echo