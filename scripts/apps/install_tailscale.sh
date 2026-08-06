#!/usr/bin/env bash
# Use sudo.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="{$SCRIPT_DIR}/../.."
source "{$ROOT_DIR}/.env"

echo "== Installing Tailscale =="
curl -fsSL https://tailscale.com/install.sh | sh
echo "Done!"
echo

echo "== Configuring firewall (ufw) — Tailscale direct-connection port =="
ufw allow 41641/udp