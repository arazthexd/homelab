#!/usr/bin/env bash
# scripts/bootstrap.sh
#
# Orchestrates the full first-login sequence on a fresh VM/VPS:
#   create the main user -> relocate the repo into their home -> install
#   base tools/Docker/Tailscale/Syncthing -> firewall -> swap.
#
# SSH hardening is opt-in via --harden-ssh and runs last, since it should
# only happen after confirmation that the main user can actually log in.
#
# Prerequisite (can't be automated — there's no repo to run this from until
# it's done): as root on the fresh box,
#   apt-get update && apt-get install -y git
#   git clone https://github.com/arazthexd/homelab.git && cd homelab
#
# Usage:
#   sudo bash scripts/bootstrap.sh                # everything except SSH hardening
#   sudo bash scripts/bootstrap.sh --harden-ssh    # also hardens SSH at the end
set -euo pipefail

# ---------------------------------------------------------------------------
# Preflight
# ---------------------------------------------------------------------------
if [[ $EUID -ne 0 ]]; then
    echo "FATAL: bootstrap.sh must be run as root (use sudo)." >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

HARDEN_SSH=false
for arg in "$@"; do
    case "$arg" in
        --harden-ssh) HARDEN_SSH=true ;;
        *) echo "Unknown argument: $arg" >&2; exit 1 ;;
    esac
done

log() { echo; echo "===== $* ====="; }

log "Updating package lists"
apt-get update

cd "$REPO_ROOT"
source .env

# ---------------------------------------------------------------------------
# 1. Main user
# ---------------------------------------------------------------------------
log "Creating main user"
bash "$SCRIPT_DIR/config/create_main_user.sh"

source .env   # create_main_user.sh may have just written MAIN_USER into .env
if [[ -z "${MAIN_USER:-}" ]]; then
    echo "FATAL: MAIN_USER still not set after create_main_user.sh — aborting." >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# 2. Relocate the repo into the main user's home, if it isn't already there
# ---------------------------------------------------------------------------
USER_HOME="$(eval echo "~$MAIN_USER")"
TARGET_DIR="$USER_HOME/$(basename "$REPO_ROOT")"

if [[ "$REPO_ROOT" != "$TARGET_DIR" ]]; then
    log "Moving repo into ${MAIN_USER}'s home ($TARGET_DIR)"
    if [[ -e "$TARGET_DIR" ]]; then
        echo "FATAL: $TARGET_DIR already exists — move or remove it, then re-run." >&2
        exit 1
    fi
    cp -r "$REPO_ROOT" "$TARGET_DIR"
    chown -R "$MAIN_USER":"$MAIN_USER" "$TARGET_DIR"
    REPO_ROOT="$TARGET_DIR"
    SCRIPT_DIR="$REPO_ROOT/scripts"
    echo "Repo now lives at $REPO_ROOT — continuing from there."
else
    chown -R "$MAIN_USER":"$MAIN_USER" "$REPO_ROOT"
fi

# ---------------------------------------------------------------------------
# 3. Base tools, Docker, Tailscale, Syncthing
# ---------------------------------------------------------------------------
log "Installing base tools, Docker, Tailscale, Syncthing"
( cd "$REPO_ROOT" && bash $SCRIPT_DIR/apps/install_all.sh )

# ---------------------------------------------------------------------------
# 4. Firewall
# ---------------------------------------------------------------------------
log "Configuring firewall"
( cd "$REPO_ROOT" && bash $SCRIPT_DIR/security/configure_ufw.sh )

# ---------------------------------------------------------------------------
# 5. Swap file (cheap insurance at low RAM size)
# ---------------------------------------------------------------------------
log "Checking swap"
if swapon --show | grep -q .; then
    echo "Swap already active, skipping."
elif [[ -f /swapfile ]]; then
    echo "/swapfile exists but isn't active — enabling it."
    swapon /swapfile
else
    SWAP_SIZE="${SWAP_SIZE_GB:-2}"
    echo "Creating a ${SWAP_SIZE}G swapfile..."
    fallocate -l "${SWAP_SIZE}G" /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    grep -q '^/swapfile' /etc/fstab || echo '/swapfile none swap sw 0 0' >> /etc/fstab
fi

# ---------------------------------------------------------------------------
# 6. Tailscale join
# ---------------------------------------------------------------------------
log "Tailscale"
if command -v tailscale >/dev/null 2>&1; then
    if tailscale status >/dev/null 2>&1; then
        echo "Already joined a tailnet, skipping."
    elif [[ -n "${TAILSCALE_AUTHKEY:-}" ]]; then
        tailscale up --authkey "$TAILSCALE_AUTHKEY"
    else
        echo "Not joined yet, and no TAILSCALE_AUTHKEY set in .env."
        echo "Run 'sudo tailscale up' yourself after this finishes — it needs"
        echo "an interactive browser auth step this script can't do for you."
    fi
else
    echo "tailscale binary not found — install_tailscale.sh may have failed."
fi

# ---------------------------------------------------------------------------
# 7. SSH hardening — opt-in, last, gated behind an explicit confirmation
# ---------------------------------------------------------------------------
if $HARDEN_SSH; then
    log "Hardening SSH (--harden-ssh was passed)"
    read -rp "Have you confirmed you can log in as '${MAIN_USER}' in a SEPARATE session right now? (yes/no): " CONFIRM
    if [[ "$CONFIRM" != "yes" ]]; then
        echo "Skipping SSH hardening — verify access first, then re-run with --harden-ssh."
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
else
    echo
    echo "Skipping SSH hardening (pass --harden-ssh to enable it, once you've"
    echo "confirmed the '${MAIN_USER}' login works in a separate session)."
fi

# ---------------------------------------------------------------------------
log "Bootstrap complete"
cat <<EOF
Repo location: $REPO_ROOT

Next steps:
  1. Open a NEW terminal and log in as ${MAIN_USER}: ssh ${MAIN_USER}@<host>
  2. In that session, confirm docker works without sudo: docker ps
     (if it complains about permissions, log out and back in once more -
     group membership only refreshes on a fresh login)
  3. If Tailscale wasn't joined automatically above, run: sudo tailscale up
  4. Once all of that checks out, re-run this script with --harden-ssh
EOF