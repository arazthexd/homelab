#!/usr/bin/env bash
# Use sudo.
set -euo pipefail

echo "== Updating system =="
apt-get update
apt-get upgrade -y
echo "Done!"
echo