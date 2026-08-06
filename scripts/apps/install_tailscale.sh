#!/usr/bin/env bash
# Use sudo.
set -euo pipefail

source "../functions.sh"
load_env

echo "== Installing Tailscale =="
curl -fsSL https://tailscale.com/install.sh | sh
echo "Done!"
echo

echo "== Configuring firewall (ufw) — Tailscale direct-connection port =="
ufw allow 41641/udp