#!/bin/bash

# 🎮 GODMODE Integration Setup Script
# Merges overnight-automation with GODMODE production system

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎮 GODMODE Integration for Meauxbility"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
OVERNIGHT_REPO_PATH="${1:-$HOME/.org/overnight-automation}"
GODMODE_SOURCE="${2:-./meauxbility-production}"

echo "📍 Configuration:"
echo "   Overnight automation: $OVERNIGHT_REPO_PATH"
echo "   GODMODE source: $GODMODE_SOURCE"
echo ""

# ============================================================================
# Step 1: Verify Prerequisites
# ============================================================================
echo "${BLUE}[1/6]${NC} Checking prerequisites..."

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    echo "${RED}✗${NC} Wrangler CLI not found. Installing..."
    npm install -g wrangler
else
    echo "${GREEN}✓${NC} Wrangler CLI installed"
fi

# Check if overnight-automation exists
if [ ! -d "$OVERNIGHT_REPO_PATH" ]; then
    echo "${YELLOW}⚠${NC}  Overnight automation repo not found at $OVERNIGHT_REPO_PATH"
    echo "    Options:"
    echo "    1. Clone your existing repo:"
    echo "       git clone YOUR_REPO_URL $OVERNIGHT_REPO_PATH"
    echo "    2. Create new directory:"
    echo "       mkdir -p $OVERNIGHT_REPO_PATH"
    read -p "    Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
    mkdir -p "$OVERNIGHT_REPO_PATH"
fi

echo ""

# ============================================================================
# Step 2: Create Directory Structure
# ============================================================================
echo "${BLUE}[2/6]${NC} Creating directory structure..."

cd "$OVERNIGHT_REPO_PATH"

mkdir -p workers/godmode-agent
mkdir -p apps/web
mkdir -p packages/shared
mkdir -p docs
mkdir -p scripts

echo "${GREEN}✓${NC} Directory structure created"
echo ""

# ============================================================================
# Step 3: Copy GODMODE Worker
# ============================================================================
echo "${BLUE}[3/6]${NC} Installing GODMODE worker..."

if [ -d "$GODMODE_SOURCE" ]; then
    # Copy worker files
    cp -r "$GODMODE_SOURCE/workers/"* workers/godmode-agent/ 2>/dev/null || true

    # Copy wrangler config
    if [ -f "$GODMODE_SOURCE/wrangler.jsonc" ]; then
        cp "$GODMODE_SOURCE/wrangler.jsonc" workers/godmode-agent/
    fi

    # Copy package.json for dependencies
    if [ -f "$GODMODE_SOURCE/package.json" ]; then
        cp "$GODMODE_SOURCE/package.json" workers/godmode-agent/
    fi

    echo "${GREEN}✓${NC} GODMODE worker files copied"
else
    echo "${YELLOW}⚠${NC}  GODMODE source not found, will create template"

    # Create minimal worker template
    cat > workers/godmode-agent/index.js << 'EOF'
// GODMODE Agent - Minimal Template
// TODO: Copy full implementation from meauxbility-production

export default {
  async fetch(request, env, ctx) {
    return new Response('GODMODE Agent - Setup pending\nRun: wrangler deploy', {
      headers: { 'Content-Type': 'text/plain' }
    });
  }
};
EOF

    cat > workers/godmode-agent/wrangler.jsonc << 'EOF'
{
  "name": "godmode-agent",
  "main": "index.js",
  "compatibility_date": "2025-03-07",
  "compatibility_flags": ["nodejs_compat"],
  "observability": {
    "enabled": true
  }
}
EOF

fi

echo ""

# ============================================================================
# Step 4: Install Dependencies
# ============================================================================
echo "${BLUE}[4/6]${NC} Installing dependencies..."

cd workers/godmode-agent

if [ -f "package.json" ]; then
    npm install
    echo "${GREEN}✓${NC} Dependencies installed"
else
    echo "${YELLOW}⚠${NC}  No package.json found, skipping"
fi

cd ../..
echo ""

# ============================================================================
# Step 5: Update Deployment Scripts
# ============================================================================
echo "${BLUE}[5/6]${NC} Updating deployment scripts..."

# Update deploy-all.sh if it exists
if [ -f "scripts/deploy-all.sh" ]; then
    # Add GODMODE deployment if not already present
    if ! grep -q "godmode-agent" scripts/deploy-all.sh; then
        cat >> scripts/deploy-all.sh << 'EOF'

# Deploy GODMODE Agent
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎮 Deploying GODMODE Agent..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd workers/godmode-agent
wrangler deploy
cd ../..

echo "✅ GODMODE Agent deployed!"
EOF
        echo "${GREEN}✓${NC} Updated scripts/deploy-all.sh"
    else
        echo "${GREEN}✓${NC} deploy-all.sh already contains GODMODE"
    fi
else
    # Create new deploy-all.sh
    cat > scripts/deploy-all.sh << 'EOF'
#!/bin/bash

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Deploying All Workers"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Deploy GODMODE Agent
echo "🎮 Deploying GODMODE Agent..."
cd workers/godmode-agent && wrangler deploy && cd ../..

echo ""
echo "✅ All deployments complete!"
EOF
    chmod +x scripts/deploy-all.sh
    echo "${GREEN}✓${NC} Created scripts/deploy-all.sh"
fi

echo ""

# ============================================================================
# Step 6: Create Documentation
# ============================================================================
echo "${BLUE}[6/6]${NC} Generating documentation..."

# Create integration README
cat > docs/GODMODE_INTEGRATION.md << 'EOF'
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
EOF

echo "${GREEN}✓${NC} Documentation created"
echo ""

# ============================================================================
# Summary
# ============================================================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "${GREEN}✅ GODMODE Integration Complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📁 Location: $OVERNIGHT_REPO_PATH"
echo ""
echo "🎯 Next Steps:"
echo ""
echo "   1. Navigate to your repo:"
echo "      ${YELLOW}cd $OVERNIGHT_REPO_PATH${NC}"
echo ""
echo "   2. Configure Cloudflare (if not done):"
echo "      ${YELLOW}wrangler login${NC}"
echo ""
echo "   3. Set required secrets:"
echo "      ${YELLOW}cd workers/godmode-agent${NC}"
echo "      ${YELLOW}wrangler secret put ANTHROPIC_API_KEY${NC}"
echo "      ${YELLOW}wrangler secret put GITHUB_TOKEN${NC}"
echo ""
echo "   4. Deploy everything:"
echo "      ${YELLOW}cd ../.. && ./scripts/deploy-all.sh${NC}"
echo ""
echo "📚 Documentation:"
echo "   - Integration Guide: docs/GODMODE_INTEGRATION.md"
echo "   - Commands Reference: GODMODE_COMMANDS.md"
echo "   - Full README: README.md"
echo ""
echo "🎮 You now have 100 instant commands at your fingertips!"
echo ""
