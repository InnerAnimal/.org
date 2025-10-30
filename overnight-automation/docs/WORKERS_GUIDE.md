# 🤖 CLOUDFLARE WORKERS GUIDE

Complete usage guide for all 6 Cloudflare Workers in the Meauxbility ecosystem.

---

## 📋 Workers Overview

| Worker | Purpose | Endpoint Pattern | Cron |
|--------|---------|-----------------|------|
| **api-vault** | Secure credential storage | `api-vault.workers.dev` | - |
| **image-optimizer** | Image optimization + caching | `image-optimizer.workers.dev` | - |
| **stripe-webhook** | Payment event processing | `stripe-webhook.workers.dev` | - |
| **email-webhook** | Email routing & logging | `email-webhook.workers.dev` | - |
| **analytics-aggregator** | Real-time analytics | `analytics-aggregator.workers.dev` | - |
| **dns-health-monitor** | Health checks & monitoring | `dns-health-monitor.workers.dev` | Every 5 min |

---

## 🔐 WORKER 1: API Vault

### Purpose
Secure storage and retrieval of API keys and credentials using Cloudflare KV.

### Endpoints

#### GET /keys
List all stored keys (names only, not values)

**Request**:
```bash
curl https://api-vault.YOUR-ACCOUNT.workers.dev/keys \
  -H "Authorization: Bearer YOUR_API_VAULT_SECRET"
```

**Response**:
```json
{
  "keys": ["STRIPE_SECRET_KEY", "OPENAI_API_KEY", "GITHUB_TOKEN"],
  "count": 3
}
```

#### GET /key/:name
Retrieve a specific key value

**Request**:
```bash
curl https://api-vault.YOUR-ACCOUNT.workers.dev/key/STRIPE_SECRET_KEY \
  -H "Authorization: Bearer YOUR_API_VAULT_SECRET"
```

**Response**:
```json
{
  "key": "STRIPE_SECRET_KEY",
  "value": "sk_live_..."
}
```

#### POST /key
Store a new key

**Request**:
```bash
curl -X POST https://api-vault.YOUR-ACCOUNT.workers.dev/key \
  -H "Authorization: Bearer YOUR_API_VAULT_SECRET" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "NEW_API_KEY",
    "value": "secret_value_here",
    "expiresIn": 86400
  }'
```

**Response**:
```json
{
  "success": true,
  "key": "NEW_API_KEY"
}
```

### Integration Example

```javascript
// Fetch API key from vault
const response = await fetch('https://api-vault.YOUR-ACCOUNT.workers.dev/key/OPENAI_API_KEY', {
  headers: {
    'Authorization': `Bearer ${API_VAULT_SECRET}`
  }
});

const { value } = await response.json();
// Use value...
```

---

## 🖼️ WORKER 2: Image Optimizer

### Purpose
Automatically optimize, resize, and convert images to WebP with R2 caching.

### Query Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `url` | string | **required** | Source image URL |
| `width` | number | 800 | Target width in pixels |
| `quality` | number | 85 | Quality (1-100) |
| `format` | string | webp | Output format (webp, jpeg, png) |

### Usage Example

```html
<!-- Original image -->
<img src="https://example.com/photo.jpg" alt="Photo">

<!-- Optimized version -->
<img src="https://image-optimizer.YOUR-ACCOUNT.workers.dev?url=https://example.com/photo.jpg&width=400&quality=85&format=webp" alt="Photo">
```

### API Request

```bash
curl "https://image-optimizer.YOUR-ACCOUNT.workers.dev?url=https://example.com/photo.jpg&width=600&quality=90"
```

### Caching Behavior

- **First request**: Fetches, optimizes, stores in R2, returns optimized image (X-Cache: MISS)
- **Subsequent requests**: Returns from R2 cache (X-Cache: HIT)
- **Cache duration**: 1 year (31536000 seconds)

### Integration in Next.js

```javascript
// next.config.js
module.exports = {
  images: {
    loader: 'custom',
    loaderFile: './lib/imageLoader.js',
  },
};

// lib/imageLoader.js
export default function cloudflareImageLoader({ src, width, quality }) {
  const params = new URLSearchParams({
    url: src,
    width: width.toString(),
    quality: (quality || 85).toString(),
    format: 'webp'
  });

  return `https://image-optimizer.YOUR-ACCOUNT.workers.dev?${params}`;
}
```

---

## 💳 WORKER 3: Stripe Webhook Handler

### Purpose
Process Stripe payment events, update Supabase, send notifications.

### Webhook Configuration

**Stripe Dashboard**:
1. Go to: Developers → Webhooks
2. Add endpoint: `https://stripe-webhook.YOUR-ACCOUNT.workers.dev`
3. Select events:
   - `checkout.session.completed`
   - `payment_intent.succeeded`
   - `payment_intent.failed`
   - `customer.subscription.created`
   - `customer.subscription.updated`
   - `customer.subscription.deleted`

### Handled Events

#### checkout.session.completed
- Updates order status in Supabase
- Sends confirmation email to customer

#### payment_intent.succeeded
- Logs successful payment
- Records in `payments` table

#### payment_intent.failed
- Logs failure in `payment_failures` table
- Alerts admin via email

#### Subscription events
- Updates `subscriptions` table
- Tracks subscription lifecycle

### Testing

```bash
# Test with Stripe CLI
stripe listen --forward-to https://stripe-webhook.YOUR-ACCOUNT.workers.dev

# Trigger test event
stripe trigger checkout.session.completed
```

### Monitoring

Check Supabase tables:
- `orders` - Order status updates
- `payments` - Successful payments
- `payment_failures` - Failed attempts
- `subscriptions` - Active subscriptions

---

## 📧 WORKER 4: Email Webhook Handler

### Purpose
Process incoming emails from email providers, route to services, log in Supabase.

### Supported Providers

- **SendGrid**: POST to `/sendgrid`
- **Mailgun**: POST to `/mailgun`
- **Resend**: POST to `/resend`

### Email Routing

| Recipient | Routes To | Action |
|-----------|-----------|--------|
| support@meauxbility.org | Support tickets | Creates ticket in Supabase |
| orders@inneranimals.com | Order management | Adds note to order |
| admin@iaudodidact.com | Admin inbox | Logs in admin_inbox table |

### Provider Setup

#### SendGrid

**Inbound Parse Webhook**:
```
URL: https://email-webhook.YOUR-ACCOUNT.workers.dev/sendgrid
```

#### Mailgun

**Routes → Create Route**:
```
Expression: match_recipient(".*@meauxbility.org")
Forward to: https://email-webhook.YOUR-ACCOUNT.workers.dev/mailgun
```

### Integration Example

```javascript
// Email arrives at support@meauxbility.org
// Worker automatically:
// 1. Logs to Supabase email_logs table
// 2. Creates support ticket
// 3. Sends auto-reply
// 4. Determines priority based on subject keywords
```

---

## 📊 WORKER 5: Analytics Aggregator

### Purpose
Collect and aggregate analytics from all 3 sites in real-time.

### Endpoints

#### POST /track
Track an event

**Request**:
```javascript
fetch('https://analytics-aggregator.YOUR-ACCOUNT.workers.dev/track', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    event: 'page_view',
    source: 'nonprofit',  // 'admin-portal', 'nonprofit', 'shop'
    page: '/about',
    userId: 'user123',
    sessionId: 'session456',
    properties: {
      referrer: 'google.com',
      device: 'mobile'
    }
  })
});
```

#### GET /dashboard
Get real-time dashboard stats

**Response**:
```json
{
  "today": {
    "events": 1247,
    "visitors": 423,
    "pageViews": 1100
  },
  "allTime": {
    "events": 45231,
    "visitors": 12451,
    "pageViews": 39874
  },
  "bySource": [
    {
      "source": "admin-portal",
      "total_events": 234,
      "unique_visitors": 45
    }
  ]
}
```

#### GET /aggregate
Get 30-day aggregated data

**Response**:
```json
{
  "admin-portal": [
    { "date": "2025-10-01", "events": 567, "visitors": 234 }
  ],
  "nonprofit": [...],
  "shop": [...]
}
```

### Frontend Integration

```javascript
// Track page view
useEffect(() => {
  fetch('https://analytics-aggregator.YOUR-ACCOUNT.workers.dev/track', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      event: 'page_view',
      source: 'nonprofit',
      page: window.location.pathname,
      sessionId: getSessionId()
    })
  });
}, []);
```

---

## 🏥 WORKER 6: DNS Health Monitor

### Purpose
Automatically check health of all 3 domains every 5 minutes via cron trigger.

### Manual Trigger

```bash
curl https://dns-health-monitor.YOUR-ACCOUNT.workers.dev
```

### Response Format

```json
{
  "timestamp": "2025-10-30T12:00:00Z",
  "checks": [
    {
      "domain": "iaudodidact.com",
      "status": "healthy",
      "responseTime": 245,
      "httpStatus": 200,
      "sslValid": true,
      "issues": []
    },
    {
      "domain": "meauxbility.org",
      "status": "degraded",
      "responseTime": 3500,
      "httpStatus": 200,
      "sslValid": true,
      "issues": ["Slow response: 3500ms"]
    }
  ]
}
```

### Health Status

- **healthy**: All checks pass
- **degraded**: Minor issues (slow response, non-critical errors)
- **critical**: Site unreachable or major errors

### Alerts

Critical issues are automatically logged to:
- Supabase `critical_alerts` table
- Supabase `dns_health_logs` table

### Cron Configuration

**Frequency**: Every 5 minutes

**wrangler.toml**:
```toml
[triggers]
crons = ["*/5 * * * *"]
```

### Monitoring Dashboard

Query recent health checks:
```sql
SELECT * FROM dns_health_logs
WHERE checked_at > NOW() - INTERVAL '24 hours'
ORDER BY checked_at DESC;
```

---

## 🔧 Common Operations

### Viewing Worker Logs

```bash
# Real-time logs
wrangler tail api-vault

# With filtering
wrangler tail stripe-webhook --status error
```

### Updating Workers

```bash
# Update single worker
wrangler deploy workers/api-vault.js --name api-vault

# Update all workers
./scripts/deploy-workers.sh
```

### Setting Secrets

```bash
# Add secret to worker
wrangler secret put SUPABASE_SERVICE_ROLE_KEY --name stripe-webhook

# List secrets
wrangler secret list --name stripe-webhook
```

---

## 🆘 Troubleshooting

### Worker Returns 500 Error

**Check logs**:
```bash
wrangler tail WORKER_NAME --status error
```

**Common causes**:
- Missing environment variable
- Invalid Supabase credentials
- R2 bucket not bound correctly

### Rate Limiting

All workers support high traffic:
- 100,000 requests/day (free tier)
- 1000 requests/second burst

**If exceeded**:
- Upgrade to Workers Paid ($5/month)
- Implement caching in workers

---

## 📚 Additional Resources

- [Cloudflare Workers Docs](https://developers.cloudflare.com/workers/)
- [Wrangler CLI Reference](https://developers.cloudflare.com/workers/wrangler/)
- [KV Storage API](https://developers.cloudflare.com/workers/runtime-apis/kv/)
- [R2 Storage API](https://developers.cloudflare.com/r2/)

---

**Last Updated**: 2025-10-30
**Workers Version**: 1.0
