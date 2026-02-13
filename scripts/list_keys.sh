#!/usr/bin/env bash
# ipeaky - List stored key names (never values)
# Usage: ./list_keys.sh [credentials_dir]

set -euo pipefail

CRED_DIR="${1:-$HOME/.openclaw/credentials}"
ENV_FILE="${CRED_DIR}/ipeaky-keys.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "No keys stored yet."
  exit 0
fi

echo "Stored keys:"
sed -n 's/=.*//p' "$ENV_FILE" | while read -r name; do
  val=$(grep "^${name}=" "$ENV_FILE" | cut -d= -f2-)
  masked="${val:0:4}****"
  echo "  ${name} = ${masked}"
done
