#!/bin/bash
# ==================================================================
# DEPLOY ALL CLOUDFLARE WORKERS
# ==================================================================
# Usage: ./deploy-workers.sh

set -e

echo "🚀 Deploying Meauxbility Cloudflare Workers..."
echo ""

# Check if wrangler is installed
if ! command -v wrangler &> /dev/null; then
    echo "❌ Wrangler CLI not found. Installing..."
    npm install -g wrangler
fi

# Authenticate (if not already)
echo "🔐 Checking Cloudflare authentication..."
wrangler whoami || wrangler login

cd /home/user/overnight-automation

# ==================================================================
# STEP 1: CREATE KV NAMESPACES
# ==================================================================
echo ""
echo "📦 Creating KV Namespaces..."

# API Vault KV
if ! wrangler kv:namespace list | grep -q "API_VAULT"; then
    echo "Creating API_VAULT KV namespace..."
    wrangler kv:namespace create "API_VAULT"
fi

# ==================================================================
# STEP 2: CREATE R2 BUCKETS
# ==================================================================
echo ""
echo "🪣 Creating R2 Buckets..."

# Media Assets
if ! wrangler r2 bucket list | grep -q "meauxbility-media"; then
    echo "Creating meauxbility-media bucket..."
    wrangler r2 bucket create meauxbility-media
fi

# Backups
if ! wrangler r2 bucket list | grep -q "meauxbility-backups"; then
    echo "Creating meauxbility-backups bucket..."
    wrangler r2 bucket create meauxbility-backups
fi

# Logs
if ! wrangler r2 bucket list | grep -q "meauxbility-logs"; then
    echo "Creating meauxbility-logs bucket..."
    wrangler r2 bucket create meauxbility-logs
fi

# ==================================================================
# STEP 3: SET SECRETS
# ==================================================================
echo ""
echo "🔑 Setting up secrets..."

# Read from .env file
if [ -f "/home/user/.org/.env" ]; then
    source /home/user/.org/.env

    echo "$SUPABASE_SERVICE_ROLE_KEY" | wrangler secret put SUPABASE_SERVICE_ROLE_KEY -c wrangler.toml
    echo "$STRIPE_WEBHOOK_SECRET" | wrangler secret put STRIPE_WEBHOOK_SECRET -c wrangler.toml
    echo "$API_VAULT_SECRET" | wrangler secret put API_VAULT_SECRET -c wrangler.toml

    echo "✅ Secrets configured"
else
    echo "⚠️  .env file not found. Please set secrets manually:"
    echo "   wrangler secret put SUPABASE_SERVICE_ROLE_KEY"
    echo "   wrangler secret put STRIPE_WEBHOOK_SECRET"
    echo "   wrangler secret put API_VAULT_SECRET"
fi

# ==================================================================
# STEP 4: DEPLOY WORKERS
# ==================================================================
echo ""
echo "🚀 Deploying workers..."

# Deploy each worker
for worker in api-vault image-optimizer stripe-webhook email-webhook analytics-aggregator dns-health-monitor; do
    echo ""
    echo "Deploying $worker..."
    wrangler deploy workers/${worker}.js --name $worker --compatibility-date 2024-01-01
done

# ==================================================================
# STEP 5: VERIFY DEPLOYMENTS
# ==================================================================
echo ""
echo "✅ Deployment complete! Verifying..."
echo ""

wrangler deployments list

echo ""
echo "🎉 All workers deployed successfully!"
echo ""
echo "📋 Worker URLs:"
echo "   • API Vault: https://api-vault.YOUR-ACCOUNT.workers.dev"
echo "   • Image Optimizer: https://image-optimizer.YOUR-ACCOUNT.workers.dev"
echo "   • Stripe Webhook: https://stripe-webhook.YOUR-ACCOUNT.workers.dev"
echo "   • Email Webhook: https://email-webhook.YOUR-ACCOUNT.workers.dev"
echo "   • Analytics: https://analytics-aggregator.YOUR-ACCOUNT.workers.dev"
echo "   • DNS Monitor: https://dns-health-monitor.YOUR-ACCOUNT.workers.dev"
echo ""
echo "⏰ Cron trigger configured: DNS Health Monitor runs every 5 minutes"
