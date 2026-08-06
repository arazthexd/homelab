#!/usr/bin/env bash
# Use sudo.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/../.."
source "$ROOT_DIR/.env"

echo "== Installing base tools =="
apt-get install -y ca-certificates curl gnupg git ufw
echo "Done!"
echo