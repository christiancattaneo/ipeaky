---
name: ipeaky
description: Secure API key management for OpenClaw. Store, list, test, and delete API keys without exposing them in chat history. Use when a user needs to provide, manage, or test API keys (e.g., OpenAI, ElevenLabs, Anthropic, X/Twitter, or any service). Triggers on phrases like "add API key", "store my key", "manage keys", "test my key", "set up API key", or when a skill requires an API key that isn't configured.
---

# ipeaky 🔑

Secure API key management — keys never appear in chat history.

## How It Works

Keys are stored in `~/.openclaw/credentials/ipeaky-keys.env` with owner-only permissions (600).
The credentials directory is locked to mode 700. Keys are passed via stdin to avoid
exposure in process lists, shell history, or chat logs.

## Storing a Key

When a user wants to store a key, use the interactive stdin approach:

```bash
# Prompt user, then pipe to store script
read -sp "" KEY && echo "$KEY" | bash scripts/store_key.sh KEY_NAME
```

**Critical rule:** NEVER echo, print, or include the key value in any chat message, tool call
argument, or log. The key must flow through stdin only.

**Workflow:**
1. Ask the user which service (OpenAI, ElevenLabs, Anthropic, X, custom)
2. Map to standard env var name (OPENAI_API_KEY, ELEVENLABS_API_KEY, etc.)
3. Tell the user to run the store command in their terminal, OR use `exec` with stdin piping
4. Confirm storage succeeded (script prints OK/ERROR)
5. Offer to test the key

## Listing Keys

```bash
bash scripts/list_keys.sh
```

Shows key names with masked values (first 4 chars + ****). Never shows full values.

## Testing a Key

```bash
bash scripts/test_key.sh KEY_NAME
```

Built-in tests for: OPENAI_API_KEY, ELEVENLABS_API_KEY, ANTHROPIC_API_KEY.
Other keys report storage status only.

## Deleting a Key

```bash
bash scripts/delete_key.sh KEY_NAME
```

## Loading Keys at Runtime

Other skills/tools can source stored keys:

```bash
source ~/.openclaw/credentials/ipeaky-keys.env
```

## Standard Key Names

| Service | Key Name |
|---------|----------|
| OpenAI | OPENAI_API_KEY |
| ElevenLabs | ELEVENLABS_API_KEY |
| Anthropic | ANTHROPIC_API_KEY |
| X / Twitter | X_API_KEY, X_API_SECRET |
| Stripe | STRIPE_API_KEY |
| Custom | USER_DEFINED_NAME |

## Security Guarantees

- Keys never appear in chat messages or tool call arguments
- Keys never appear in shell command arguments (stdin only)
- Credential files are owner-read-only (600)
- Credential directory is owner-only (700)
- List command shows masked values only
- No keys in logs or memory files
