#!/usr/bin/env bash
# ipeaky v3 — Zero-exposure key storage
# The agent NEVER sees the key. This script:
# 1. Shows a macOS popup for secure input
# 2. Calls `openclaw config set` for each config path
# 3. Returns only success/fail to the agent
#
# Usage: bash store_key_v3.sh <SERVICE_NAME> <config_path1> [config_path2] ...
# Example: bash store_key_v3.sh "Brave Search" "tools.web.search.apiKey"
# Example: bash store_key_v3.sh "ElevenLabs" "skills.entries.sag.apiKey" "talk.apiKey"

set -euo pipefail

SERVICE_NAME="${1:?Usage: store_key_v3.sh <SERVICE_NAME> <config_path> [config_path2] ...}"
shift
CONFIG_PATHS=("$@")

if [ ${#CONFIG_PATHS[@]} -eq 0 ]; then
  echo "ERROR: No config paths provided"
  exit 1
fi

# --- 1. Secure input via macOS popup ---
KEY_VALUE=$(osascript <<EOF
set dialogResult to display dialog "Enter your ${SERVICE_NAME} API key:" with title "ipeaky 🔑" default answer "" with hidden answer buttons {"Cancel", "Store"} default button "Store"
return text returned of dialogResult
EOF
) || { echo "CANCELLED"; exit 2; }

if [ -z "$KEY_VALUE" ]; then
  echo "ERROR: Empty key"
  exit 1
fi

# --- 2. Store via openclaw config set for each path ---
STORED=0
FAILED=0

for CONFIG_PATH in "${CONFIG_PATHS[@]}"; do
  if openclaw config set "$CONFIG_PATH" "$KEY_VALUE" --restart=false 2>/dev/null; then
    STORED=$((STORED + 1))
  else
    # Fallback: try without --restart flag
    if openclaw config set "$CONFIG_PATH" "$KEY_VALUE" 2>/dev/null; then
      STORED=$((STORED + 1))
    else
      FAILED=$((FAILED + 1))
      echo "WARN: Failed to set ${CONFIG_PATH}"
    fi
  fi
done

# --- 3. Clear sensitive data ---
KEY_VALUE=""

# --- 4. Restart gateway once (if we stored anything) ---
if [ "$STORED" -gt 0 ]; then
  openclaw gateway restart 2>/dev/null || true
fi

# --- 5. Report result (no key in output!) ---
if [ "$FAILED" -eq 0 ]; then
  echo "OK: ${SERVICE_NAME} key stored in ${STORED} config path(s). Gateway restarting."
else
  echo "PARTIAL: ${STORED} stored, ${FAILED} failed. Check openclaw logs."
  exit 1
fi
