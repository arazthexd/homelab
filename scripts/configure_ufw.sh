#!/usr/bin/env bash
# Use sudo.
set -euo pipefail

echo "== Configuring firewall (ufw) — public ports only =="
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 41641/udp   # Tailscale's direct-connection port
ufw --force enable