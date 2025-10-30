#!/bin/bash
# ==================================================================
# GODMODE DEPLOYMENT - Automated Setup
# ==================================================================
# This script will guide you through deploying GODMODE to Cloudflare

set -e

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎮 GODMODE Deployment to Cloudflare"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd /home/user/.org/overnight-automation/workers/godmode-agent

# ============================================================================
# STEP 1: Install Dependencies
# ============================================================================
echo "📦 [1/7] Installing dependencies..."
npm install
echo "✅ Dependencies installed"
echo ""

# ============================================================================
# STEP 2: Login to Cloudflare
# ============================================================================
echo "🔐 [2/7] Cloudflare authentication..."
echo "   Run: wrangler login"
echo "   (Opens browser for authentication)"
echo ""
read -p "Press ENTER once you've logged in..."
echo ""

# ============================================================================
# STEP 3: Create D1 Database
# ============================================================================
echo "🗄️  [3/7] Creating D1 database..."
wrangler d1 create meauxbility-production

echo ""
echo "📝 Copy the database_id from above and paste it here:"
read -p "database_id: " D1_ID

# Update wrangler.toml with D1 ID
sed -i "s/database_id = \"YOUR_D1_ID\"/database_id = \"$D1_ID\"/" wrangler.toml
echo "✅ D1 database configured"
echo ""

# ============================================================================
# STEP 4: Create KV Namespace
# ============================================================================
echo "🗂️  [4/7] Creating KV namespace..."
wrangler kv:namespace create "MEAUXBILITY_KV"

echo ""
echo "📝 Copy the id from above and paste it here:"
read -p "id: " KV_ID

# Update wrangler.toml with KV ID
sed -i "s/id = \"YOUR_KV_ID\"/id = \"$KV_ID\"/" wrangler.toml
echo "✅ KV namespace configured"
echo ""

# ============================================================================
# STEP 5: Initialize Database Schema
# ============================================================================
echo "📊 [5/7] Initializing database schema..."
wrangler d1 execute meauxbility-production --file=migrations/001_initial.sql
echo "✅ Database schema created"
echo ""

# ============================================================================
# STEP 6: Set Secrets
# ============================================================================
echo "🔑 [6/7] Setting secrets..."
echo ""

# Load from .env if available
if [ -f "/home/user/.org/.env" ]; then
    source /home/user/.org/.env

    echo "Setting ANTHROPIC_API_KEY..."
    echo "$ANTHROPIC_API_KEY" | wrangler secret put ANTHROPIC_API_KEY

    echo "Setting GITHUB_TOKEN..."
    echo "$GITHUB_TOKEN" | wrangler secret put GITHUB_TOKEN

    echo "Setting SUPABASE_URL..."
    echo "$SUPABASE_URL" | wrangler secret put SUPABASE_URL

    echo "Setting SUPABASE_SERVICE_KEY..."
    echo "$SUPABASE_SERVICE_ROLE_KEY" | wrangler secret put SUPABASE_SERVICE_KEY

    echo "✅ All secrets configured from .env"
else
    echo "⚠️  .env file not found. You'll need to set secrets manually:"
    echo "   wrangler secret put ANTHROPIC_API_KEY"
    echo "   wrangler secret put GITHUB_TOKEN"
    echo "   wrangler secret put SUPABASE_URL"
    echo "   wrangler secret put SUPABASE_SERVICE_KEY"
fi

echo ""

# ============================================================================
# STEP 7: Deploy Worker
# ============================================================================
echo "🚀 [7/7] Deploying GODMODE worker..."
wrangler deploy

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ GODMODE Deployed Successfully!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🔗 Your worker is live at:"
echo "   https://godmode-agent.YOUR-ACCOUNT.workers.dev"
echo ""
echo "🧪 Test it:"
echo "   curl https://godmode-agent.YOUR-ACCOUNT.workers.dev/health"
echo ""
echo "📚 Next steps:"
echo "   1. Test the worker endpoints"
echo "   2. Try executing a command"
echo "   3. Integrate with your frontend"
echo ""
