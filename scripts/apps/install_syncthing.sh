#!/usr/bin/env bash
# Use sudo.
set -euo pipefail

source "../functions.sh"
load_env

if [[ -z "${MAIN_USER:-}" ]]; then
    echo "FATAL: MAIN_USER is not set. Source your .env file or run the user setup." >&2
    exit 2
fi

echo "== Installing Syncthing =="
mkdir -p /etc/apt/keyrings
curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" \
  | tee /etc/apt/sources.list.d/syncthing.list > /dev/null
apt-get update
apt-get install -y syncthing
systemctl enable --now syncthing@"${MAIN_USER}".service
echo "Done!"
echo