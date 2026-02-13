#!/usr/bin/env bash
# ipeaky - Delete a stored key
# Usage: ./delete_key.sh <key_name> [credentials_dir]

set -euo pipefail

KEY_NAME="${1:?Usage: delete_key.sh <key_name> [credentials_dir]}"
CRED_DIR="${2:-$HOME/.openclaw/credentials}"
ENV_FILE="${CRED_DIR}/ipeaky-keys.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "No keys stored." >&2
  exit 1
fi

if ! grep -q "^${KEY_NAME}=" "$ENV_FILE"; then
  echo "ERROR: Key '${KEY_NAME}' not found." >&2
  exit 1
fi

grep -v "^${KEY_NAME}=" "$ENV_FILE" > "${ENV_FILE}.tmp" || true
mv "${ENV_FILE}.tmp" "$ENV_FILE"
chmod 600 "$ENV_FILE"

echo "OK: ${KEY_NAME} deleted."
