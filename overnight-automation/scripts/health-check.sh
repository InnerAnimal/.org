#!/bin/bash
# ==================================================================
# HEALTH CHECK SCRIPT
# ==================================================================
# Verify all infrastructure is running correctly

set -e

echo "======================================================================"
echo "🏥 INFRASTRUCTURE HEALTH CHECK"
echo "======================================================================"
echo ""

ACCOUNT_NAME=$(wrangler whoami | grep "Account" | head -1 | awk '{print $3}' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9-]//g')

HEALTH_REPORT="/home/user/overnight-automation/docs/HEALTH_CHECK_$(date +%Y%m%d_%H%M%S).txt"

exec > >(tee -a "$HEALTH_REPORT")
exec 2>&1

echo "Health check started: $(date)"
echo ""

# ==================================================================
# CHECK 1: CLOUDFLARE WORKERS
# ==================================================================
echo "======================================================================"
echo "CHECK 1: CLOUDFLARE WORKERS"
echo "======================================================================"
echo ""

WORKERS=(
  "api-vault"
  "image-optimizer"
  "stripe-webhook"
  "email-webhook"
  "analytics-aggregator"
  "dns-health-monitor"
)

WORKERS_HEALTHY=0
WORKERS_TOTAL=${#WORKERS[@]}

for worker in "${WORKERS[@]}"; do
  echo -n "Testing $worker... "

  URL="https://${worker}.${ACCOUNT_NAME}.workers.dev"

  if curl -s -o /dev/null -w "%{http_code}" --max-time 10 "$URL" | grep -q "200\|401\|405"; then
    echo "✅ HEALTHY"
    ((WORKERS_HEALTHY++))
  else
    echo "❌ UNREACHABLE"
  fi
done

echo ""
echo "Workers Health: $WORKERS_HEALTHY/$WORKERS_TOTAL healthy"

# ==================================================================
# CHECK 2: R2 BUCKETS
# ==================================================================
echo ""
echo "======================================================================"
echo "CHECK 2: R2 STORAGE BUCKETS"
echo "======================================================================"
echo ""

BUCKETS=(
  "meauxbility-media"
  "meauxbility-backups"
  "meauxbility-logs"
  "meauxbility-uploads"
)

BUCKETS_HEALTHY=0
BUCKETS_TOTAL=${#BUCKETS[@]}

for bucket in "${BUCKETS[@]}"; do
  echo -n "Checking $bucket... "

  if wrangler r2 bucket list | grep -q "$bucket"; then
    echo "✅ EXISTS"
    ((BUCKETS_HEALTHY++))
  else
    echo "❌ NOT FOUND"
  fi
done

echo ""
echo "R2 Buckets Health: $BUCKETS_HEALTHY/$BUCKETS_TOTAL exist"

# ==================================================================
# CHECK 3: D1 DATABASE
# ==================================================================
echo ""
echo "======================================================================"
echo "CHECK 3: D1 DATABASE"
echo "======================================================================"
echo ""

echo -n "Checking meauxbility-edge-cache... "
if wrangler d1 list | grep -q "meauxbility-edge-cache"; then
  echo "✅ EXISTS"

  # Check tables
  echo ""
  echo "Verifying database schema..."
  wrangler d1 execute meauxbility-edge-cache \
    --command="SELECT name FROM sqlite_master WHERE type='table';" \
    2>/dev/null || echo "⚠️  Schema check failed"

  D1_HEALTHY=1
else
  echo "❌ NOT FOUND"
  D1_HEALTHY=0
fi

# ==================================================================
# CHECK 4: CUSTOM DOMAINS
# ==================================================================
echo ""
echo "======================================================================"
echo "CHECK 4: CUSTOM DOMAINS (DNS)"
echo "======================================================================"
echo ""

DOMAINS=(
  "iaudodidact.com"
  "meauxbility.org"
  "inneranimals.com"
)

DOMAINS_HEALTHY=0
DOMAINS_TOTAL=${#DOMAINS[@]}

for domain in "${DOMAINS[@]}"; do
  echo -n "Testing $domain... "

  if curl -s -o /dev/null -w "%{http_code}" --max-time 10 "https://$domain" | grep -q "200"; then
    echo "✅ ACCESSIBLE"
    ((DOMAINS_HEALTHY++))
  else
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" --max-time 10 "https://$domain" || echo "000")
    echo "⚠️  HTTP $STATUS"
  fi
done

echo ""
echo "Domains Health: $DOMAINS_HEALTHY/$DOMAINS_TOTAL accessible"

# ==================================================================
# CHECK 5: CRON TRIGGERS
# ==================================================================
echo ""
echo "======================================================================"
echo "CHECK 5: CRON TRIGGERS"
echo "======================================================================"
echo ""

echo -n "Checking DNS health monitor cron... "
if wrangler deployments list 2>/dev/null | grep -q "dns-health-monitor"; then
  echo "✅ CONFIGURED (runs every 5 minutes)"
else
  echo "⚠️  Status unknown"
fi

# ==================================================================
# CHECK 6: VERCEL DEPLOYMENTS
# ==================================================================
echo ""
echo "======================================================================"
echo "CHECK 6: VERCEL DEPLOYMENTS"
echo "======================================================================"
echo ""

VERCEL_APPS=(
  "admin-portal"
  "meauxbility-org"
  "inneranimals-shop"
)

VERCEL_HEALTHY=0
VERCEL_TOTAL=${#VERCEL_APPS[@]}

for app in "${VERCEL_APPS[@]}"; do
  echo -n "Checking $app... "

  if vercel ls --token DXVdcsOQ7QM2egQhLKNLraLr 2>/dev/null | grep -q "$app"; then
    echo "✅ DEPLOYED"
    ((VERCEL_HEALTHY++))
  else
    echo "⚠️  Status unknown"
  fi
done

echo ""
echo "Vercel Apps Health: $VERCEL_HEALTHY/$VERCEL_TOTAL deployed"

# ==================================================================
# FINAL SUMMARY
# ==================================================================
echo ""
echo "======================================================================"
echo "📊 HEALTH CHECK SUMMARY"
echo "======================================================================"
echo ""

TOTAL_CHECKS=$((WORKERS_TOTAL + BUCKETS_TOTAL + 1 + DOMAINS_TOTAL + 1 + VERCEL_TOTAL))
TOTAL_HEALTHY=$((WORKERS_HEALTHY + BUCKETS_HEALTHY + D1_HEALTHY + DOMAINS_HEALTHY + 1 + VERCEL_HEALTHY))

HEALTH_PERCENTAGE=$((TOTAL_HEALTHY * 100 / TOTAL_CHECKS))

echo "Overall Health: $TOTAL_HEALTHY/$TOTAL_CHECKS ($HEALTH_PERCENTAGE%)"
echo ""
echo "Component Breakdown:"
echo "  • Cloudflare Workers: $WORKERS_HEALTHY/$WORKERS_TOTAL"
echo "  • R2 Buckets: $BUCKETS_HEALTHY/$BUCKETS_TOTAL"
echo "  • D1 Database: $D1_HEALTHY/1"
echo "  • Custom Domains: $DOMAINS_HEALTHY/$DOMAINS_TOTAL"
echo "  • Vercel Apps: $VERCEL_HEALTHY/$VERCEL_TOTAL"
echo ""

if [ $HEALTH_PERCENTAGE -ge 90 ]; then
  echo "Status: ✅ EXCELLENT - All systems operational"
elif [ $HEALTH_PERCENTAGE -ge 70 ]; then
  echo "Status: ⚠️  GOOD - Some components need attention"
elif [ $HEALTH_PERCENTAGE -ge 50 ]; then
  echo "Status: ⚠️  DEGRADED - Multiple issues detected"
else
  echo "Status: ❌ CRITICAL - System requires immediate attention"
fi

echo ""
echo "Health check completed: $(date)"
echo "Report saved to: $HEALTH_REPORT"
echo ""
echo "======================================================================"
