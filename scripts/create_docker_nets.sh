#!/usr/bin/env bash
# Use sudo.
set -euo pipefail

docker network create tunnel_net
docker network create apps_net