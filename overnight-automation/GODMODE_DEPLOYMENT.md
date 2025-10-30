# 🚀 GODMODE Deployment Guide

Quick start guide to deploy GODMODE Agent v2.0

---

## ⚡ Quick Deploy (5 Steps)

### 1. Navigate to GODMODE directory

```bash
cd /home/user/.org/overnight-automation/workers/godmode-agent
```

### 2. Install dependencies

```bash
npm install
```

### 3. Login to Cloudflare

```bash
wrangler login
```

### 4. Create Cloudflare resources

```bash
# Create D1 database
wrangler d1 create meauxbility-production

# Create KV namespace
wrangler kv:namespace create "MEAUXBILITY_KV"

# Create R2 bucket
wrangler r2 bucket create meauxbility-assets

# Initialize D1 schema
wrangler d1 execute meauxbility-production --file=migrations/001_initial.sql
```

**Update `wrangler.toml`** with the IDs from the commands above.

### 5. Set secrets

```bash
# Required
wrangler secret put ANTHROPIC_API_KEY
# Enter your key when prompted: sk-ant-...

wrangler secret put GITHUB_TOKEN
# Enter your GitHub token: ghp_...

wrangler secret put SUPABASE_URL
# Enter: https://ghiulqoqujsiofsjcrqk.supabase.co

wrangler secret put SUPABASE_SERVICE_KEY
# Enter your service role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Optional (for additional features)
wrangler secret put OPENAI_API_KEY
wrangler secret put GMAIL_API_KEY
wrangler secret put STRIPE_SECRET_KEY
```

### 6. Deploy!

```bash
wrangler deploy
```

That's it! Your GODMODE agent is now live! 🎉

---

## 🧪 Testing Your Deployment

### Test HTTP endpoint

```bash
# Health check
curl https://godmode-agent.YOUR-ACCOUNT.workers.dev/health

# Get status
curl https://godmode-agent.YOUR-ACCOUNT.workers.dev/godmode/api/status

# List commands
curl https://godmode-agent.YOUR-ACCOUNT.workers.dev/godmode/api/commands

# Execute a command
curl -X POST https://godmode-agent.YOUR-ACCOUNT.workers.dev/godmode/api/execute \
  -H "Content-Type: application/json" \
  -d '{"command":"GH","payload":{}}'
```

### Test WebSocket connection

```javascript
// test-websocket.html
const ws = new WebSocket('wss://godmode-agent.YOUR-ACCOUNT.workers.dev/godmode');

ws.onopen = () => {
  console.log('✅ Connected!');

  // Get status
  ws.send(JSON.stringify({
    type: 'GET_STATUS'
  }));
};

ws.onmessage = (event) => {
  console.log('📥 Received:', JSON.parse(event.data));
};

ws.onerror = (error) => {
  console.error('❌ Error:', error);
};
```

---

## 📊 Verify Database

```bash
# Check execution logs
wrangler d1 execute meauxbility-production \
  --command="SELECT * FROM execution_logs ORDER BY timestamp DESC LIMIT 5"

# Check spending tracker
wrangler d1 execute meauxbility-production \
  --command="SELECT * FROM spending_tracking"

# View daily stats
wrangler d1 execute meauxbility-production \
  --command="SELECT * FROM daily_stats LIMIT 7"
```

---

## 🔧 Configuration

### Update wrangler.toml

After creating resources, update these IDs:

```toml
[[kv_namespaces]]
binding = "MEAUXBILITY_KV"
id = "YOUR_KV_ID_HERE"  # From kv:namespace create command

[[d1_databases]]
binding = "MEAUXBILITY_D1"
database_name = "meauxbility-production"
database_id = "YOUR_D1_ID_HERE"  # From d1 create command
```

### Add custom domain (optional)

1. Add route in `wrangler.toml`:

```toml
[[routes]]
pattern = "api.meauxbility.org/*"
zone_name = "meauxbility.org"
```

2. Redeploy:

```bash
wrangler deploy
```

3. Configure DNS:

```
Type: CNAME
Name: api
Value: godmode-agent.YOUR-ACCOUNT.workers.dev
```

---

## 📝 Environment Variables

### Required Secrets

| Secret | Description | Example |
|--------|-------------|---------|
| `ANTHROPIC_API_KEY` | Claude API key | `sk-ant-...` |
| `GITHUB_TOKEN` | GitHub PAT | `ghp_...` |
| `SUPABASE_URL` | Supabase project URL | `https://*.supabase.co` |
| `SUPABASE_SERVICE_KEY` | Service role key | `eyJhbGc...` |

### Optional Secrets

| Secret | Description | Required For |
|--------|-------------|--------------|
| `OPENAI_API_KEY` | OpenAI API key | AI commands using GPT |
| `GMAIL_API_KEY` | Gmail API credentials | Email monitoring (#MEAUXWORK) |
| `STRIPE_SECRET_KEY` | Stripe secret | Payment commands |

---

## 🐛 Troubleshooting

### Error: "Worker not found"

**Solution**: Wait 30 seconds after deployment for propagation.

### Error: "Durable Object not found"

**Solution**: Ensure `wrangler.toml` has Durable Object configuration:

```toml
[[durable_objects.bindings]]
name = "GODMODE_AGENT"
class_name = "GodModeAgent"

[[migrations]]
tag = "v1"
new_classes = ["GodModeAgent"]
```

### Error: "Database not found"

**Solution**: Check D1 binding and database ID:

```bash
# List databases
wrangler d1 list

# Verify ID matches wrangler.toml
```

### Error: "KV namespace not found"

**Solution**: Create and bind KV namespace:

```bash
# Create namespace
wrangler kv:namespace create "MEAUXBILITY_KV"

# Update wrangler.toml with returned ID
```

### Commands returning errors

**Solution**: Check secrets are set:

```bash
# List secrets (doesn't show values)
wrangler secret list

# Re-set a secret
wrangler secret put SECRET_NAME
```

---

## 📊 Monitoring

### View live logs

```bash
# Real-time tail
wrangler tail

# Filter by status
wrangler tail --status error

# Filter by search
wrangler tail --search "command"
```

### Check analytics

```bash
# View in dashboard
wrangler dash

# Or visit: https://dash.cloudflare.com
# → Workers & Pages → godmode-agent → Analytics
```

### Query execution logs

```bash
# Recent executions
wrangler d1 execute meauxbility-production \
  --command="SELECT * FROM execution_logs ORDER BY timestamp DESC LIMIT 10"

# Error count
wrangler d1 execute meauxbility-production \
  --command="SELECT status, COUNT(*) FROM execution_logs GROUP BY status"

# Top commands
wrangler d1 execute meauxbility-production \
  --command="SELECT * FROM top_commands"
```

---

## 🔄 Updates & Maintenance

### Deploy updates

```bash
# Pull latest code
git pull origin main

# Deploy
cd workers/godmode-agent
wrangler deploy
```

### Database migrations

```bash
# Create new migration
touch migrations/002_your_changes.sql

# Apply migration
wrangler d1 execute meauxbility-production --file=migrations/002_your_changes.sql
```

### Rotate secrets

```bash
# Update secret (keeps old until deployment)
wrangler secret put SECRET_NAME

# Deploy to activate new secret
wrangler deploy
```

---

## 💰 Cost Estimates

### Cloudflare Workers

- **Free tier**: 100,000 requests/day
- **Paid**: $5/month for 10M requests

### D1 Database

- **Free tier**: 25GB storage, 25M reads, 50M writes
- **Paid**: $0.75/GB/month

### KV Storage

- **Free tier**: 1GB storage, 100k reads/day
- **Paid**: $0.50/GB/month

### R2 Storage

- **Free tier**: 10GB storage
- **Paid**: $0.015/GB/month

**Estimated monthly cost**: $0 - $1 (within free tier limits)

---

## 🆘 Support

- **Documentation**: `/home/user/.org/overnight-automation/docs/`
- **Commands**: `GODMODE_COMMANDS.md`
- **Integration**: `docs/GODMODE_INTEGRATION.md`
- **Cloudflare Docs**: https://developers.cloudflare.com/workers/

---

## ✅ Deployment Checklist

- [ ] Cloudflare account created
- [ ] Wrangler CLI installed
- [ ] Logged into Cloudflare (`wrangler login`)
- [ ] D1 database created
- [ ] KV namespace created
- [ ] R2 bucket created
- [ ] Database schema initialized
- [ ] wrangler.toml updated with resource IDs
- [ ] All required secrets set
- [ ] Worker deployed successfully
- [ ] Health check returns 200 OK
- [ ] Test command executed successfully
- [ ] WebSocket connection works
- [ ] Logs showing in D1 database

---

**You're ready to use GODMODE! 🎮**

Try your first command:
```bash
curl -X POST https://godmode-agent.YOUR-ACCOUNT.workers.dev/godmode/api/execute \
  -H "Content-Type: application/json" \
  -d '{"command":"GH"}'
```
