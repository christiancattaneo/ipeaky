#!/usr/bin/env bash
# ipeaky - Native macOS secure key input
# Usage: ./secure_input_mac.sh <KEY_NAME> [credentials_dir]
# Uses native macOS dialog — no HTTP server, no browser, no port.

set -euo pipefail

KEY_NAME="${1:?Usage: secure_input_mac.sh <KEY_NAME> [credentials_dir]}"
CRED_DIR="${2:-$HOME/.openclaw/credentials}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Native macOS hidden-input dialog → pipe directly to store script (key never printed)
osascript -e "set theKey to text returned of (display dialog \"Paste your ${KEY_NAME}:\" default answer \"\" with hidden answer with title \"🔑 ipeaky\" with icon caution)" -e "return theKey" 2>/dev/null \
  | bash "${SCRIPT_DIR}/store_key.sh" "$KEY_NAME" "$CRED_DIR"
