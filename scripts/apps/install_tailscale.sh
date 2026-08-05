#!/usr/bin/env bash
# Use sudo.
set -euo pipefail

echo "== Installing Tailscale =="
curl -fsSL https://tailscale.com/install.sh | sh
echo "Done!"
echo