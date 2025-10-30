# 🚀 GODMODE Deployment - Quick Start

**Current Status**: Ready to deploy, needs authentication

---

## ⚡ Quick Deploy (15 minutes)

Follow these steps exactly:

### Step 1: Authenticate with Cloudflare (2 minutes)

**IMPORTANT**: The API token in `.env` doesn't have sufficient permissions for D1/KV operations.

**Option A: Create New API Token (Recommended)**

1. Go to: https://dash.cloudflare.com/profile/api-tokens
2. Click "Create Token"
3. Use "Edit Cloudflare Workers" template
4. Add these additional permissions:
   - Account > D1 > Edit
   - Account > Workers KV Storage > Edit
   - Account > Workers Scripts > Edit
5. Copy the new token
6. Update `/home/user/.org/.env`:
   ```bash
   CLOUDFLARE_API_TOKEN=your_new_token_here
   ```

**Option B: Interactive Login (Alternative)**

```bash
cd /home/user/.org/overnight-automation/workers/godmode-agent

# Login to Cloudflare (opens browser)
wrangler login
```

**What happens**: Browser opens, you authorize Wrangler, then close browser and return to terminal.

**Current Status**: API token found but lacks D1/KV permissions. Need Option A or B above.

---

### Step 2: Create D1 Database (2 minutes)

```bash
# Create database
wrangler d1 create meauxbility-production
```

**Copy the output** - you'll see something like:

```
✅ Successfully created DB 'meauxbility-production'!

[[d1_databases]]
binding = "DB"
database_name = "meauxbility-production"
database_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"  # ← COPY THIS
```

**Update wrangler.toml**:
```bash
# Replace YOUR_D1_ID with the database_id from above
sed -i 's/database_id = "YOUR_D1_ID"/database_id = "PASTE_YOUR_ID_HERE"/' wrangler.toml
```

---

### Step 3: Create KV Namespace (1 minute)

```bash
# Create KV namespace
wrangler kv:namespace create "MEAUXBILITY_KV"
```

**Copy the output** - you'll see:

```
✅ Success!
Add the following to your wrangler.toml:

[[kv_namespaces]]
binding = "MEAUXBILITY_KV"
id = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"  # ← COPY THIS
```

**Update wrangler.toml**:
```bash
# Replace YOUR_KV_ID with the id from above
sed -i 's/id = "YOUR_KV_ID"/id = "PASTE_YOUR_ID_HERE"/' wrangler.toml
```

---

### Step 4: Initialize Database Schema (1 minute)

```bash
# Run migrations
wrangler d1 execute meauxbility-production --file=migrations/001_initial.sql
```

**Expected output**: Tables created successfully ✅

---

### Step 5: Set Secrets (2 minutes)

```bash
# Load environment variables
source /home/user/.org/.env

# Set secrets (paste when prompted)
echo "$ANTHROPIC_API_KEY" | wrangler secret put ANTHROPIC_API_KEY
echo "$GITHUB_TOKEN" | wrangler secret put GITHUB_TOKEN
echo "$SUPABASE_URL" | wrangler secret put SUPABASE_URL
echo "$SUPABASE_SERVICE_ROLE_KEY" | wrangler secret put SUPABASE_SERVICE_KEY
```

**Alternative** (if .env not available):
```bash
# Set each secret manually (you'll be prompted to paste)
wrangler secret put ANTHROPIC_API_KEY
wrangler secret put GITHUB_TOKEN
wrangler secret put SUPABASE_URL
wrangler secret put SUPABASE_SERVICE_KEY
```

---

### Step 6: Deploy! (2 minutes)

```bash
# Deploy the worker
wrangler deploy
```

**Expected output**:
```
✨ Success! Uploaded worker!
🌍 https://godmode-agent.YOUR-ACCOUNT.workers.dev
```

**Copy your worker URL** - you'll need it for testing!

---

## ✅ Step 7: Verify Deployment (2 minutes)

Replace `YOUR-ACCOUNT` with your Cloudflare account name:

```bash
# Test health endpoint
curl https://godmode-agent.YOUR-ACCOUNT.workers.dev/health

# Expected:
# {"status":"healthy","version":"2.0.0","timestamp":"..."}

# Test GODMODE status
curl https://godmode-agent.YOUR-ACCOUNT.workers.dev/godmode/api/status

# Expected:
# {"status":"operational","commands":100,"activeConnections":0,...}

# List all commands
curl https://godmode-agent.YOUR-ACCOUNT.workers.dev/godmode/api/commands
```

---

## 🎯 Step 8: Execute Your First Command!

```bash
# Try syncing GitHub repos
curl -X POST https://godmode-agent.YOUR-ACCOUNT.workers.dev/godmode/api/execute \
  -H "Content-Type: application/json" \
  -d '{"command":"GH","payload":{}}'

# Expected:
# {"status":"success","message":"Synced X repositories",...}
```

---

## 📝 Step 9: Update Your Apps

Now that GODMODE is deployed, update your Next.js apps:

```bash
cd /home/user/meauxbility-monorepo-IAM

# Create .env.local for each app
# Admin Portal
cat > apps/admin-portal/.env.local << 'EOF'
NEXT_PUBLIC_WORKER_URL=https://godmode-agent.YOUR-ACCOUNT.workers.dev/godmode
NEXT_PUBLIC_SUPABASE_URL=https://ghiulqoqujsiofsjcrqk.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=YOUR_ANON_KEY
EOF

# Repeat for meauxbility-org and inneranimals-shop
```

**Replace**:
- `YOUR-ACCOUNT` with your Cloudflare account name
- `YOUR_ANON_KEY` with your Supabase anon key

---

## 🧪 Step 10: Test Command Palette

```bash
# Install dependencies
cd /home/user/meauxbility-monorepo-IAM
npm install

# Start admin portal
cd apps/admin-portal
npm run dev

# Open http://localhost:3000
# Press ⌘K (or Ctrl+K)
# Command palette should appear!
# Try executing a command (e.g., type "GH" and press Enter)
```

---

## 🎊 You're Done!

**What you now have**:
- ✅ GODMODE worker deployed to Cloudflare
- ✅ 100 commands available
- ✅ D1 database with schema
- ✅ KV namespace for storage
- ✅ All secrets configured
- ✅ Health endpoints working
- ✅ Command palette ready in all 3 apps

**Press ⌘K in any app and unleash GODMODE!** 🎮

---

## 🐛 Troubleshooting

### "You are not authenticated"
```bash
wrangler login
# Opens browser, authorize, close browser
```

### "Database not found"
```bash
# Create database
wrangler d1 create meauxbility-production
# Update wrangler.toml with the database_id
```

### "KV namespace not found"
```bash
# Create namespace
wrangler kv:namespace create "MEAUXBILITY_KV"
# Update wrangler.toml with the id
```

### "Secret not found"
```bash
# Set secret
wrangler secret put SECRET_NAME
# Paste value when prompted
```

### Deployment fails
```bash
# Check configuration
cat wrangler.toml

# Verify all IDs are set (not "YOUR_*_ID")
# Re-deploy
wrangler deploy
```

---

## 📊 Cost Tracking

After deployment, check spending:

```bash
curl https://godmode-agent.YOUR-ACCOUNT.workers.dev/godmode/api/status
```

Look for:
```json
{
  "spending": {
    "hourly": "0.00",
    "daily": "0.00",
    "limits": {
      "hourly": "$0.50",
      "daily": "$5.00"
    }
  }
}
```

---

## 🆘 Need Help?

**Worker URL**: Check after deployment with `wrangler deploy`
**View logs**: `wrangler tail`
**Check resources**: `wrangler d1 list` and `wrangler kv:namespace list`

---

**Ready to deploy?** Start with Step 1 above! 🚀
