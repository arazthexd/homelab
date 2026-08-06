#!/usr/bin/env bash
# Use sudo.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="{$SCRIPT_DIR}/../.."
source "{$ROOT_DIR}/.env"

echo "== Configuring firewall (ufw) — public ports only =="
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable