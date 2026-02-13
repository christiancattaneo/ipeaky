# 🔑 ipeaky

**Secure API key management for [OpenClaw](https://openclaw.ai) agents.**

Keys never touch chat history, command arguments, or logs. Ever.

## Why

AI agents need API keys. Pasting them in chat is a security nightmare — they end up in conversation history, logs, and context windows. ipeaky solves this.

## How It Works

```
User → stdin → encrypted file (600) → done
```

- Keys flow through **stdin only** — never in shell args or chat
- Stored in `~/.openclaw/credentials/` with **owner-only permissions**
- Masked display (first 4 chars + `****`)
- Built-in validation for popular APIs

## Quick Start

### Store a key (macOS — native dialog)
```bash
bash scripts/secure_input_mac.sh OPENAI_API_KEY
```

### Store a key (Linux/any — terminal)
```bash
echo -n "Key: " && read -s K && echo "$K" | bash scripts/store_key.sh OPENAI_API_KEY && echo
```

### List stored keys
```bash
bash scripts/list_keys.sh
# Output: OPENAI_API_KEY = sk-7****
```

### Test a key
```bash
bash scripts/test_key.sh OPENAI_API_KEY
# Output: OK: OpenAI key is valid.
```

### Delete a key
```bash
bash scripts/delete_key.sh OPENAI_API_KEY
```

## Supported Services

| Service | Key Name | Auto-test |
|---------|----------|-----------|
| OpenAI | `OPENAI_API_KEY` | ✅ |
| ElevenLabs | `ELEVENLABS_API_KEY` | ✅ |
| Anthropic | `ANTHROPIC_API_KEY` | ✅ |
| X / Twitter | `X_API_KEY` | — |
| Stripe | `STRIPE_API_KEY` | — |
| Any service | `YOUR_KEY_NAME` | — |

## Security Model

- **stdin-only input** — keys never appear in `ps`, `history`, or chat
- **File permissions** — credentials dir `700`, key file `600`
- **Masked output** — list shows `sk-7****`, never full values
- **No network** — storage is purely local, tests are opt-in
- **No dependencies** — pure bash, runs everywhere

## Install as OpenClaw Skill

Drop the `ipeaky/` folder into your OpenClaw skills directory, or install from ClawHub:

```
clawhub install ipeaky
```

## License

MIT — use it, fork it, secure your keys.
