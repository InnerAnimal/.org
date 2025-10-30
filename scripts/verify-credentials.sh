#!/bin/bash

# Credential Verification Script
# Checks if required environment variables are set

echo "🔐 Credential Vault Verification"
echo "=================================="
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${RED}❌ .env file not found!${NC}"
    echo "Run: cp env.example .env"
    exit 1
fi

# Load .env
set -a
source .env
set +a

# Track status
missing_count=0
configured_count=0
total_count=0

check_var() {
    local var_name=$1
    local var_value="${!var_name}"
    local is_optional=$2

    total_count=$((total_count + 1))

    if [ -z "$var_value" ] || [ "$var_value" = "your_"* ] || [ "$var_value" = "generate_"* ]; then
        if [ "$is_optional" = "optional" ]; then
            echo -e "${YELLOW}⚠️  $var_name (optional)${NC}"
        else
            echo -e "${RED}❌ $var_name${NC}"
            missing_count=$((missing_count + 1))
        fi
    else
        echo -e "${GREEN}✅ $var_name${NC}"
        configured_count=$((configured_count + 1))
    fi
}

echo "Supabase Configuration:"
check_var "VITE_SUPABASE_URL"
check_var "VITE_SUPABASE_ANON_KEY"
check_var "VITE_SUPABASE_SERVICE_ROLE_KEY" "optional"
echo ""

echo "Cloudflare Configuration:"
check_var "CLOUDFLARE_API_TOKEN"
check_var "CLOUDFLARE_ACCOUNT_ID"
check_var "CLOUDFLARE_ZONE_ID" "optional"
echo ""

echo "OpenAI Configuration:"
check_var "OPENAI_API_KEY" "optional"
echo ""

echo "Anthropic Configuration:"
check_var "VITE_ANTHROPIC_API_KEY" "optional"
echo ""

echo "GitHub Configuration:"
check_var "GITHUB_TOKEN" "optional"
echo ""

echo "Vercel Configuration:"
check_var "VERCEL_TOKEN" "optional"
echo ""

echo "Google Services:"
check_var "VITE_GA_MEASUREMENT_ID" "optional"
echo ""

echo "Stripe Configuration:"
check_var "STRIPE_SECRET_KEY" "optional"
echo ""

echo "Security Settings:"
check_var "JWT_SECRET" "optional"
check_var "ENCRYPTION_KEY" "optional"
echo ""

# Summary
echo "=================================="
echo "Summary:"
echo -e "${GREEN}✅ Configured: $configured_count${NC}"
echo -e "${RED}❌ Missing: $missing_count${NC}"
echo -e "Total: $total_count"
echo ""

if [ $missing_count -eq 0 ]; then
    echo -e "${GREEN}🎉 All required credentials are configured!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Please configure missing credentials in .env${NC}"
    echo "Refer to CREDENTIALS.md for instructions"
    exit 1
fi
