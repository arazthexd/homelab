#!/usr/bin/env bash
# Use sudo.
#
# SSH hardening is opt-in and runs last, since it should
# only happen after confirmation that the main user can actually log in.
set -euo pipefail

log "Hardening SSH"
read -rp "Have you confirmed you can log in as '${MAIN_USER}' in a SEPARATE session right now? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "Skipping SSH hardening — verify access first, then re-run."
else
    apt-get install -y fail2ban unattended-upgrades
    systemctl enable --now fail2ban
    dpkg-reconfigure -f noninteractive unattended-upgrades

    SSHD_CONFIG=/etc/ssh/sshd_config
    sed -i \
        -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' \
        -e 's/^#\?PermitRootLogin.*/PermitRootLogin no/' \
        "$SSHD_CONFIG"
    systemctl restart ssh
    echo "SSH hardened: password auth and root login are now disabled."
    echo "(Your current root session stays open — this only affects new connections.)"
fi