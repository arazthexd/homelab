#!/usr/bin/env bash
# Use sudo.
set -euo pipefail

source "functions.sh"
load_env

echo "== Configuring firewall (ufw) — public ports only =="
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable