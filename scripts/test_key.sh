#!/usr/bin/env bash
# ipeaky - Test a stored API key
# Usage: ./test_key.sh <key_name> [credentials_dir]
# Supports: OPENAI_API_KEY, ELEVENLABS_API_KEY, ANTHROPIC_API_KEY, STRIPE_API_KEY, GITHUB_TOKEN

set -euo pipefail

KEY_NAME="${1:?Usage: test_key.sh <key_name> [credentials_dir]}"
CRED_DIR="${2:-$HOME/.openclaw/credentials}"
ENV_FILE="${CRED_DIR}/ipeaky-keys.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "ERROR: No keys stored." >&2
  exit 1
fi

VAL=$(grep -F "${KEY_NAME}=" "$ENV_FILE" | head -1 | cut -d= -f2-)
if [ -z "$VAL" ]; then
  echo "ERROR: Key '${KEY_NAME}' not found." >&2
  exit 1
fi

# All tests use read-only HTTPS endpoints. Keys in headers only (never URLs).
case "$KEY_NAME" in
  OPENAI_API_KEY)
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 \
      -H "Authorization: Bearer ${VAL}" \
      "https://api.openai.com/v1/models" 2>/dev/null)
    [ "$HTTP_CODE" = "200" ] && echo "OK: OpenAI key is valid." || echo "FAIL: OpenAI returned HTTP ${HTTP_CODE}."
    ;;
  ELEVENLABS_API_KEY)
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 \
      -H "xi-api-key: ${VAL}" \
      "https://api.elevenlabs.io/v1/user" 2>/dev/null)
    [ "$HTTP_CODE" = "200" ] && echo "OK: ElevenLabs key is valid." || echo "FAIL: ElevenLabs returned HTTP ${HTTP_CODE}."
    ;;
  ANTHROPIC_API_KEY)
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 \
      -H "x-api-key: ${VAL}" \
      -H "anthropic-version: 2023-06-01" \
      "https://api.anthropic.com/v1/models" 2>/dev/null)
    [ "$HTTP_CODE" = "200" ] && echo "OK: Anthropic key is valid." || echo "FAIL: Anthropic returned HTTP ${HTTP_CODE}."
    ;;
  STRIPE_API_KEY|STRIPE_SECRET_KEY)
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 \
      -u "${VAL}:" \
      "https://api.stripe.com/v1/balance" 2>/dev/null)
    [ "$HTTP_CODE" = "200" ] && echo "OK: Stripe key is valid." || echo "FAIL: Stripe returned HTTP ${HTTP_CODE}."
    ;;
  GITHUB_TOKEN)
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 \
      -H "Authorization: Bearer ${VAL}" \
      "https://api.github.com/user" 2>/dev/null)
    [ "$HTTP_CODE" = "200" ] && echo "OK: GitHub token is valid." || echo "FAIL: GitHub returned HTTP ${HTTP_CODE}."
    ;;
  *)
    echo "INFO: No built-in test for '${KEY_NAME}'. Key is stored (${#VAL} chars)."
    ;;
esac
