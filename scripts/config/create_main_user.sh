#!/usr/bin/env bash
# Run as root (sudo).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$SCRIPT_DIR/../.."
source "$ROOT_DIR/.env"

# Ensure MAIN_USER is set, prompt if not
if [[ -z "${MAIN_USER:-}" ]]; then
    read -rp "Enter username for the main user: " MAIN_USER

    echo "== Updating .env file =="
    ENV_FILE="{$ROOT_DIR}/.env"
    if grep -q '^MAIN_USER=$' "$ENV_FILE"; then
        # Line exists but is empty – replace it with the resolved value
        sed -i "s/^MAIN_USER=.*/MAIN_USER=\"$MAIN_USER\"/" "$ENV_FILE"
    elif ! grep -q '^MAIN_USER=' "$ENV_FILE"; then
        # Line doesn't exist at all – append it
        echo "MAIN_USER=\"$MAIN_USER\"" >> "$ENV_FILE"
    fi
fi

echo "== Creating main user =="
echo "Name: $MAIN_USER"
if id "$MAIN_USER" &>/dev/null; then
    echo "User $MAIN_USER already exists, skipping creation."
else
    useradd -m -s /bin/bash -G sudo "$MAIN_USER"
    echo "User $MAIN_USER created."
    CONFIGURE_USER_LOGIN="yes"
fi
echo

echo "== Configuring main user login =="

# Determine login method: "key" or "password"
if [ $CONFIGURE_USER_LOGIN == "yes"]; then
    METHOD="${MAIN_USER_CONNECT_METHOD:-}"
    if [[ -z "$METHOD" ]]; then
        until [[ "$METHOD" =~ ^(key|password)$ ]]; do
            read -rp "Login method (key/password): " METHOD
        done
    fi

    if [[ "$METHOD" == "key" ]]; then
        echo "Setting up SSH key for $MAIN_USER..."
        bash scripts/config/add_ssh_key.sh "$MAIN_USER"
        passwd "$MAIN_USER"
    else
        echo "Setting password for $MAIN_USER..."
        passwd "$MAIN_USER"
    fi
fi

echo
echo "============================================="
echo "Configuration complete."
echo "You can now log out and connect as $MAIN_USER:"
echo "  ssh ${MAIN_USER}@<host>"
echo "============================================="