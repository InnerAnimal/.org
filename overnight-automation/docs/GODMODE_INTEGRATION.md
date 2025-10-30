# GODMODE Integration Guide

## Overview

GODMODE has been integrated with your overnight-automation infrastructure.

## Architecture

```
overnight-automation/
├── workers/
│   ├── godmode-agent/      # 🆕 Orchestration layer (100 commands)
│   ├── api-vault/          # ✅ Existing
│   ├── image-optimizer/    # ✅ Existing
│   ├── stripe-webhook/     # ✅ Existing
│   ├── email-webhook/      # ✅ Existing
│   ├── analytics/          # ✅ Existing
│   └── health-monitor/     # ✅ Existing
└── scripts/
    └── deploy-all.sh       # Updated with GODMODE
```

## Quick Start

### 1. Configure Cloudflare Resources

```bash
# Login to Cloudflare
wrangler login

# Create Durable Objects binding (if not exists)
wrangler d1 create meauxbility-production
```

### 2. Set Secrets

```bash
cd workers/godmode-agent

# Required
wrangler secret put ANTHROPIC_API_KEY
wrangler secret put GITHUB_TOKEN

# Optional
wrangler secret put OPENAI_API_KEY
wrangler secret put GMAIL_API_KEY
```

### 3. Deploy

```bash
# From repository root
./scripts/deploy-all.sh
```

### 4. Test

```bash
# Test GODMODE agent
curl https://godmode-agent.YOUR-ACCOUNT.workers.dev/api/status

# Execute a command
curl -X POST https://godmode-agent.YOUR-ACCOUNT.workers.dev/api/execute \
  -H "Content-Type: application/json" \
  -d '{"command":"GH"}'
```

## Available Commands

See `GODMODE_COMMANDS.md` for complete list of 100 commands.

### Quick Examples

- `/GH` - Sync GitHub repos
- `/IM` - Optimize image
- `/ST` - Process Stripe payment
- `/EM` - Send email
- `/AN` - View analytics
- `/HM` - Health check all sites

## Next Steps

1. Deploy Next.js frontend (optional)
2. Set up email monitoring with #MEAUXWORK tags
3. Configure custom domains
4. Enable team access

## Support

- Documentation: `docs/`
- Commands: `GODMODE_COMMANDS.md`
- Integration: `INTEGRATION_GUIDE.md`
