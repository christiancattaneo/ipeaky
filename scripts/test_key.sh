#!/usr/bin/env bash
# ipeaky - Test a stored API key
# Usage: ./test_key.sh <key_name> [credentials_dir]
# Supports: OPENAI_API_KEY, ELEVENLABS_API_KEY, X_API_KEY, ANTHROPIC_API_KEY

set -euo pipefail

KEY_NAME="${1:?Usage: test_key.sh <key_name> [credentials_dir]}"
CRED_DIR="${2:-$HOME/.openclaw/credentials}"
ENV_FILE="${CRED_DIR}/ipeaky-keys.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: No keys stored." >&2
  exit 1
fi

VAL=$(grep "^${KEY_NAME}=" "$ENV_FILE" | cut -d= -f2-)
if [ -z "$VAL" ]; then
  echo "ERROR: Key '${KEY_NAME}' not found." >&2
  exit 1
fi

case "$KEY_NAME" in
  OPENAI_API_KEY)
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
      -H "Authorization: Bearer ${VAL}" \
      "https://api.openai.com/v1/models" 2>/dev/null)
    [ "$HTTP_CODE" = "200" ] && echo "OK: OpenAI key is valid." || echo "FAIL: OpenAI returned HTTP ${HTTP_CODE}."
    ;;
  ELEVENLABS_API_KEY)
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
      -H "xi-api-key: ${VAL}" \
      "https://api.elevenlabs.io/v1/user" 2>/dev/null)
    [ "$HTTP_CODE" = "200" ] && echo "OK: ElevenLabs key is valid." || echo "FAIL: ElevenLabs returned HTTP ${HTTP_CODE}."
    ;;
  ANTHROPIC_API_KEY)
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
      -H "x-api-key: ${VAL}" \
      -H "anthropic-version: 2023-06-01" \
      "https://api.anthropic.com/v1/models" 2>/dev/null)
    [ "$HTTP_CODE" = "200" ] && echo "OK: Anthropic key is valid." || echo "FAIL: Anthropic returned HTTP ${HTTP_CODE}."
    ;;
  *)
    echo "INFO: No built-in test for '${KEY_NAME}'. Key is stored (${#VAL} chars)."
    ;;
esac
