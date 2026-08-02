#!/usr/bin/env bash
# We run this ONCE, over SSH, on a fresh Debian/Ubuntu VPS/setup.
# Use sudo.
set -euo pipefail

echo "== Updating system =="
apt-get update
apt-get upgrade -y
echo "Done!"
echo

echo "== Installing base tools =="
apt-get install -y ca-certificates curl gnupg git ufw
echo "Done!"
echo

echo "== Installing Docker Engine + Compose plugin =="
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
usermod -aG docker deploy
echo "Done!"
echo

echo "== Installing Tailscale =="
curl -fsSL https://tailscale.com/install.sh | sh

echo "== Installing Syncthing =="
mkdir -p /etc/apt/keyrings
curl -L -o /etc/apt/keyrings/syncthing-archive-keyring.gpg https://syncthing.net/release-key.gpg
echo "deb [signed-by=/etc/apt/keyrings/syncthing-archive-keyring.gpg] https://apt.syncthing.net/ syncthing stable" \
  | tee /etc/apt/sources.list.d/syncthing.list > /dev/null
apt-get update
apt-get install -y syncthing
systemctl enable --now syncthing@deploy.service

echo "== Configuring firewall (ufw) — public ports only =="
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 41641/udp   # Tailscale's direct-connection port
ufw --force enable