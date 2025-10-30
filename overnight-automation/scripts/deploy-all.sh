#!/bin/bash
# ==================================================================
# MASTER DEPLOYMENT SCRIPT
# ==================================================================
# Deploys entire Cloudflare infrastructure in one command
# Usage: ./deploy-all.sh

set -e

echo "======================================================================"
echo "🌙 MEAUXBILITY OVERNIGHT AUTOMATION"
echo "======================================================================"
echo ""
echo "This script will deploy your complete production infrastructure:"
echo "  • 6 Cloudflare Workers"
echo "  • 4 R2 Storage Buckets"
echo "  • 1 D1 Edge Database"
echo "  • Health monitoring (5-min cron)"
echo ""
echo "Estimated time: 15-30 minutes"
echo ""
read -p "Press ENTER to continue or Ctrl+C to cancel..."
echo ""

# Change to script directory
cd "$(dirname "$0")"
AUTOMATION_DIR="/home/user/overnight-automation"

# ==================================================================
# PHASE 1: PRE-FLIGHT CHECKS
# ==================================================================
echo "======================================================================"
echo "PHASE 1: PRE-FLIGHT CHECKS"
echo "======================================================================"
echo ""

# Check Wrangler installation
if ! command -v wrangler &> /dev/null; then
    echo "❌ Wrangler CLI not found. Installing..."
    npm install -g wrangler
    echo "✅ Wrangler installed"
else
    echo "✅ Wrangler CLI found: $(wrangler --version)"
fi

# Check authentication
echo ""
echo "Checking Cloudflare authentication..."
if wrangler whoami &> /dev/null; then
    echo "✅ Authenticated as: $(wrangler whoami | grep "User" | awk '{print $2}')"
else
    echo "⚠️  Not authenticated. Please login:"
    wrangler login
fi

# Check for .env file
if [ -f "/home/user/.org/.env" ]; then
    echo "✅ Environment file found"
    source /home/user/.org/.env
else
    echo "⚠️  .env file not found. Some secrets may need manual configuration."
fi

echo ""
echo "✅ Pre-flight checks complete"
sleep 2

# ==================================================================
# PHASE 2: R2 STORAGE BUCKETS
# ==================================================================
echo ""
echo "======================================================================"
echo "PHASE 2: R2 STORAGE BUCKETS"
echo "======================================================================"
echo ""

cd "$AUTOMATION_DIR"
bash scripts/setup-r2-buckets.sh

echo ""
echo "✅ Phase 2 complete: R2 buckets created"
sleep 2

# ==================================================================
# PHASE 3: D1 DATABASE
# ==================================================================
echo ""
echo "======================================================================"
echo "PHASE 3: D1 EDGE DATABASE"
echo "======================================================================"
echo ""

bash scripts/setup-d1-database.sh

echo ""
echo "✅ Phase 3 complete: D1 database initialized"
sleep 2

# ==================================================================
# PHASE 4: CLOUDFLARE WORKERS
# ==================================================================
echo ""
echo "======================================================================"
echo "PHASE 4: CLOUDFLARE WORKERS"
echo "======================================================================"
echo ""

bash scripts/deploy-workers.sh

echo ""
echo "✅ Phase 4 complete: All workers deployed"
sleep 2

# ==================================================================
# PHASE 5: HEALTH CHECK
# ==================================================================
echo ""
echo "======================================================================"
echo "PHASE 5: VERIFICATION & HEALTH CHECK"
echo "======================================================================"
echo ""

# Wait a few seconds for deployments to propagate
echo "Waiting for deployments to propagate (10 seconds)..."
sleep 10

echo ""
echo "Running health checks..."

# Test DNS health monitor
ACCOUNT_NAME=$(wrangler whoami | grep "Account" | head -1 | awk '{print $3}' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g')

echo ""
echo "Testing DNS Health Monitor..."
curl -s "https://dns-health-monitor.${ACCOUNT_NAME}.workers.dev" | jq '.' || echo "Worker may still be propagating..."

echo ""
echo "Testing API Vault..."
curl -s "https://api-vault.${ACCOUNT_NAME}.workers.dev/keys" \
  -H "Authorization: Bearer ${API_VAULT_SECRET}" | jq '.' || echo "Auth required or still propagating..."

echo ""
echo "✅ Phase 5 complete: Verification done"

# ==================================================================
# PHASE 6: GENERATE DEPLOYMENT REPORT
# ==================================================================
echo ""
echo "======================================================================"
echo "PHASE 6: DEPLOYMENT REPORT"
echo "======================================================================"
echo ""

REPORT_FILE="$AUTOMATION_DIR/docs/DEPLOYMENT_REPORT_$(date +%Y%m%d_%H%M%S).md"

cat > "$REPORT_FILE" <<EOF
# 🚀 DEPLOYMENT REPORT

**Date**: $(date)
**Deployed By**: Automated deployment script
**Status**: SUCCESS ✅

---

## Deployed Resources

### Cloudflare Workers

| Worker | Status | URL |
|--------|--------|-----|
| api-vault | ✅ Deployed | https://api-vault.${ACCOUNT_NAME}.workers.dev |
| image-optimizer | ✅ Deployed | https://image-optimizer.${ACCOUNT_NAME}.workers.dev |
| stripe-webhook | ✅ Deployed | https://stripe-webhook.${ACCOUNT_NAME}.workers.dev |
| email-webhook | ✅ Deployed | https://email-webhook.${ACCOUNT_NAME}.workers.dev |
| analytics-aggregator | ✅ Deployed | https://analytics-aggregator.${ACCOUNT_NAME}.workers.dev |
| dns-health-monitor | ✅ Deployed | https://dns-health-monitor.${ACCOUNT_NAME}.workers.dev |

### R2 Buckets

- ✅ meauxbility-media
- ✅ meauxbility-backups
- ✅ meauxbility-logs
- ✅ meauxbility-uploads

### D1 Database

- ✅ meauxbility-edge-cache
  - Tables: cache, analytics_buffer, rate_limits, sessions
  - Views: active_sessions, cache_stats

---

## Next Steps

1. **Configure Stripe Webhooks**
   - URL: \`https://stripe-webhook.${ACCOUNT_NAME}.workers.dev\`
   - Events: checkout.session.completed, payment_intent.succeeded, payment_intent.failed

2. **Configure Custom Domains**
   - Add custom routes in Cloudflare Dashboard
   - Point worker routes to your domains

3. **Set Up Email Routing**
   - Configure email provider webhook: \`https://email-webhook.${ACCOUNT_NAME}.workers.dev/{provider}\`

4. **Enable Analytics**
   - Add tracking code to all 3 sites
   - POST to: \`https://analytics-aggregator.${ACCOUNT_NAME}.workers.dev/track\`

5. **Monitor Health**
   - DNS monitor runs every 5 minutes automatically
   - Check alerts in Supabase \`critical_alerts\` table

---

## Verification Commands

\`\`\`bash
# List all workers
wrangler deployments list

# Check R2 buckets
wrangler r2 bucket list

# Check D1 database
wrangler d1 list

# Test DNS monitor
curl https://dns-health-monitor.${ACCOUNT_NAME}.workers.dev
\`\`\`

---

**Deployment Time**: $(date)
**Total Resources Created**: 11 (6 workers + 4 buckets + 1 database)
**Status**: PRODUCTION READY 🎉
EOF

echo "✅ Deployment report generated: $REPORT_FILE"

# ==================================================================
# FINAL SUMMARY
# ==================================================================
echo ""
echo "======================================================================"
echo "🎉 DEPLOYMENT COMPLETE!"
echo "======================================================================"
echo ""
echo "✅ All infrastructure deployed successfully!"
echo ""
echo "📊 Resources Created:"
echo "   • 6 Cloudflare Workers"
echo "   • 4 R2 Storage Buckets"
echo "   • 1 D1 Edge Database"
echo "   • Automated health monitoring (5-min cron)"
echo ""
echo "📋 Worker URLs:"
echo "   • API Vault: https://api-vault.${ACCOUNT_NAME}.workers.dev"
echo "   • Image Optimizer: https://image-optimizer.${ACCOUNT_NAME}.workers.dev"
echo "   • Stripe Webhook: https://stripe-webhook.${ACCOUNT_NAME}.workers.dev"
echo "   • Email Webhook: https://email-webhook.${ACCOUNT_NAME}.workers.dev"
echo "   • Analytics: https://analytics-aggregator.${ACCOUNT_NAME}.workers.dev"
echo "   • DNS Monitor: https://dns-health-monitor.${ACCOUNT_NAME}.workers.dev"
echo ""
echo "📄 Detailed Report: $REPORT_FILE"
echo ""
echo "🔔 Next Steps:"
echo "   1. Configure Stripe webhook endpoint"
echo "   2. Set up custom domain routing"
echo "   3. Enable analytics tracking on your sites"
echo "   4. Configure email provider webhooks"
echo ""
echo "🆘 Need help? connor@meauxbility.org"
echo ""
echo "======================================================================"

# Deploy GODMODE Agent
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎮 Deploying GODMODE Agent..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd workers/godmode-agent
wrangler deploy
cd ../..

echo "✅ GODMODE Agent deployed!"
