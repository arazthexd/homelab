#!/usr/bin/env bash
# Use sudo.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="{$SCRIPT_DIR}/../.."
source "{$ROOT_DIR}/.env"

echo "== Updating system =="
apt-get update
apt-get upgrade -y
echo "Done!"
echo