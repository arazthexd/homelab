#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/../.."
source "$ROOT_DIR/.env"

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <username>"
    exit 1
fi

TARGET_USER="$1"

# Verify user exists
if ! id "$TARGET_USER" &>/dev/null; then
    echo "Error: User '$TARGET_USER' does not exist."
    exit 1
fi

# Get home directory
USER_HOME=$(eval echo "~$TARGET_USER")

# Create .ssh directory with correct permissions
mkdir -p "$USER_HOME/.ssh"
chmod 700 "$USER_HOME/.ssh"
chown "$TARGET_USER":"$TARGET_USER" "$USER_HOME/.ssh"

AUTH_FILE="$USER_HOME/.ssh/authorized_keys"
touch "$AUTH_FILE"
chmod 600 "$AUTH_FILE"
chown "$TARGET_USER":"$TARGET_USER" "$AUTH_FILE"

# Obtain the SSH public key
SSH_KEY="${MAIN_USER_SSH_KEY:-}"
if [[ -z "$SSH_KEY" ]]; then
    echo "Paste the public SSH key for $TARGET_USER (e.g., ssh-ed25519 AAAA...):"
    read -r SSH_KEY
fi

# Basic format validation
if [[ ! "$SSH_KEY" =~ ^(ssh-|ecdsa-) ]]; then
    echo "Warning: The key does not look like a standard SSH public key. Adding anyway."
fi

# Avoid duplicate keys
if grep -qFx "$SSH_KEY" "$AUTH_FILE"; then
    echo "Key is already present in authorized_keys."
else
    echo "$SSH_KEY" >> "$AUTH_FILE"
    echo "Key added successfully."
fi