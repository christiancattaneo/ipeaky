#!/usr/bin/env bash
# ipeaky - Secure API key storage
# Reads key from stdin to avoid exposure in process lists or chat history
# Usage: echo "$KEY" | ./store_key.sh <key_name> [credentials_dir]

set -euo pipefail

KEY_NAME="${1:?Usage: store_key.sh <key_name> [credentials_dir]}"
CRED_DIR="${2:-$HOME/.openclaw/credentials}"
ENV_FILE="${CRED_DIR}/ipeaky-keys.env"

mkdir -p "$CRED_DIR"
chmod 700 "$CRED_DIR"

# Read key from stdin (no echo, no args, no history)
KEY=$(cat)

if [ -z "$KEY" ]; then
  echo "ERROR: No key provided on stdin" >&2
  exit 1
fi

# Remove existing entry for this key name if present
if [ -f "$ENV_FILE" ]; then
  grep -v "^${KEY_NAME}=" "$ENV_FILE" > "${ENV_FILE}.tmp" 2>/dev/null || true
  mv "${ENV_FILE}.tmp" "$ENV_FILE"
fi

# Append new key
echo "${KEY_NAME}=${KEY}" >> "$ENV_FILE"
chmod 600 "$ENV_FILE"

echo "OK: ${KEY_NAME} stored securely in ${ENV_FILE}"
