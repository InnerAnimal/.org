# Credential Collection Checklist

## Status Overview

Last Updated: 2025-10-30

### Legend
- ✅ **Configured** - Credentials added and working
- ⚠️ **Needs Setup** - Awaiting credentials from user
- 🔄 **In Progress** - Partially configured
- ❌ **Blocked** - Cannot proceed without dependencies

---

## 1. Supabase ✅ CONFIGURED

**Status**: ✅ Complete

**Credentials Provided**:
```
Project URL: https://ghiulqoqujsiofsjcrqk.supabase.co
Anon Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... ✅
Service Role Key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9... ✅
```

**Added to**: `.env` (both VITE_ and NEXT_PUBLIC_ variants)

**Test Status**: Ready to test
```bash
npm run dev
# Should connect to Supabase successfully
```

---

## 2. Cloudflare 🔄 PARTIALLY CONFIGURED

**Status**: 🔄 Partial - Need R2 credentials

**Credentials Provided**:
```
✅ API Token: lZaCkW1ZWKinWlRgu_THi45PbMyb5SSKfufZXULK
✅ Account ID: ede6590ac0d2fb7daf155b35653457b2
✅ R2 Buckets:
   - meauxbility-assets
   - inneranimals-assets
   - iaudodidact-assets
```

**Still Needed**:
```
⚠️ CLOUDFLARE_ZONE_ID (for DNS management)
⚠️ CLOUDFLARE_EMAIL (your Cloudflare account email)
⚠️ CLOUDFLARE_R2_ACCESS_KEY_ID
⚠️ CLOUDFLARE_R2_SECRET_ACCESS_KEY
```

**How to Get R2 Credentials**:
1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Click **R2** in left sidebar
3. Click **Manage R2 API Tokens**
4. Click **Create API Token**
5. Select **Read and Write** permissions
6. Copy Access Key ID and Secret Access Key

**Expiration**: API Token expires **November 3, 2025** ⏰

---

## 3. GitHub Tokens ⚠️ NEEDS SETUP

**Status**: ⚠️ Awaiting tokens from team members

**Required**: Personal Access Token for each team member

### Sam (CEO) - Admin Access
```
⚠️ Token: ghp_...
   Role: admin
   Email: sam@meauxbility.org
   Permissions: Full (repo, admin:org, delete_repo, user, project)
```

### Fred (CMO) - Marketing Access
```
⚠️ Token: ghp_...
   Role: cmo
   Email: fred@meauxbility.org
   Permissions: Content (repo, read:org, user, project)
```

### Connor (CTO) - Technical Access
```
⚠️ Token: ghp_...
   Role: cto
   Email: connor@meauxbility.org
   Permissions: Technical (repo, admin:org, workflow, user, project)
```

**Setup Guide**: See `docs/GITHUB_TOKEN_SETUP.md`

**Where to Create**: [GitHub Settings → Developer Settings → Tokens](https://github.com/settings/tokens)

---

## 4. OpenAI API ⚠️ NEEDS SETUP

**Status**: ⚠️ Awaiting credentials

**Required**:
```
⚠️ OPENAI_API_KEY (starts with sk-...)
⚠️ OPENAI_ORGANIZATION_ID (starts with org-...) [Optional]
```

**Where to Get**:
1. Go to [OpenAI Platform](https://platform.openai.com/)
2. Click **API Keys** in left sidebar
3. Click **Create new secret key**
4. Name it: "Meauxbility Admin Portal"
5. Copy the key (you won't see it again!)

**Usage**: AI content generation, analysis, GPT integration

**Cost**: Pay-per-use
- GPT-3.5-turbo: ~$0.002 per 1K tokens
- GPT-4: ~$0.03 per 1K tokens

**Recommended**: Set usage limits in OpenAI dashboard

---

## 5. Anthropic Claude API ⚠️ NEEDS SETUP

**Status**: ⚠️ Awaiting credentials

**Required**:
```
⚠️ ANTHROPIC_API_KEY (starts with sk-ant-...)
```

**Where to Get**:
1. Go to [Anthropic Console](https://console.anthropic.com/)
2. Click **API Keys** in left sidebar
3. Click **Create Key**
4. Name it: "Meauxbility Admin Portal"
5. Copy the key

**Usage**: Advanced AI analysis, content creation

**Cost**: Pay-per-use
- Claude 3 Haiku: ~$0.25 per 1M tokens
- Claude 3 Sonnet: ~$3 per 1M tokens
- Claude 3 Opus: ~$15 per 1M tokens

---

## 6. Google Services ⚠️ NEEDS SETUP

**Status**: ⚠️ Awaiting credentials

### Google Analytics
```
⚠️ VITE_GA_MEASUREMENT_ID (starts with G-...)
```

**Where to Get**:
1. Go to [Google Analytics](https://analytics.google.com/)
2. Admin → Property Settings → Data Streams
3. Click your web stream
4. Copy **Measurement ID**

### Google Cloud Platform (Optional)
```
⚠️ GOOGLE_API_KEY
⚠️ GOOGLE_PROJECT_ID
⚠️ GOOGLE_CLIENT_ID
⚠️ GOOGLE_CLIENT_SECRET
```

**Where to Get**:
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create project: "Meauxbility Admin Portal"
3. Enable APIs (Drive, Sheets, etc.)
4. Create credentials → API Key
5. Create OAuth 2.0 Client ID

### Google OAuth (For User Auth)
```
⚠️ GOOGLE_OAUTH_CLIENT_ID
⚠️ GOOGLE_OAUTH_CLIENT_SECRET
```

---

## 7. Vercel ⚠️ NEEDS SETUP

**Status**: ⚠️ Awaiting credentials

**Required**:
```
⚠️ VERCEL_TOKEN
⚠️ VERCEL_ORG_ID
⚠️ VERCEL_PROJECT_ID
⚠️ VERCEL_TEAM_ID [Optional if using teams]
```

**Where to Get**:
1. Go to [Vercel Settings](https://vercel.com/account/tokens)
2. Click **Create Token**
3. Name it: "Meauxbility Admin Portal"
4. Save token

**Get IDs**:
```bash
# Install Vercel CLI
npm i -g vercel

# Login
vercel login

# Get project info (run in project directory)
vercel project ls
```

**Current Deployment**: https://iaudodidact.com/

---

## 8. Stripe ⚠️ NEEDS SETUP

**Status**: ⚠️ Awaiting credentials

**Required**:
```
⚠️ VITE_STRIPE_PUBLISHABLE_KEY (starts with pk_...)
⚠️ STRIPE_SECRET_KEY (starts with sk_...)
⚠️ STRIPE_WEBHOOK_SECRET (starts with whsec_...)
```

**Where to Get**:
1. Go to [Stripe Dashboard](https://dashboard.stripe.com/)
2. Developers → API Keys
3. Copy Publishable key and Secret key

**Test vs Production**:
- Use **test keys** (pk_test_... / sk_test_...) for development
- Use **live keys** (pk_live_... / sk_live_...) for production

**Webhook Setup**:
1. Developers → Webhooks
2. Add endpoint: `https://iaudodidact.com/api/webhooks/stripe`
3. Select events to listen for
4. Copy webhook signing secret

**Usage**: Payment processing, donations, subscriptions

---

## 9. Optional Services ⏸️ OPTIONAL

### Sentry (Error Tracking)
```
⏸️ VITE_SENTRY_DSN
```

**Where to Get**: [Sentry.io](https://sentry.io/)

### SendGrid (Email Service)
```
⏸️ SENDGRID_API_KEY
```

**Where to Get**: [SendGrid Settings](https://app.sendgrid.com/settings/api_keys)

### Twilio (SMS Service)
```
⏸️ TWILIO_ACCOUNT_SID
⏸️ TWILIO_AUTH_TOKEN
⏸️ TWILIO_PHONE_NUMBER
```

**Where to Get**: [Twilio Console](https://console.twilio.com/)

---

## 10. Security Secrets ⚠️ NEEDS GENERATION

**Status**: ⚠️ Need to generate

**Required**:
```
⚠️ JWT_SECRET (random 32+ character string)
⚠️ ENCRYPTION_KEY (random 32+ character string)
⚠️ SESSION_SECRET (random 32+ character string)
```

**Generate Using**:

**Node.js**:
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

**OpenSSL**:
```bash
openssl rand -hex 32
```

**Python**:
```bash
python -c "import secrets; print(secrets.token_hex(32))"
```

Run the command 3 times to generate 3 different secrets.

---

## Verification Commands

### Check .env Status
```bash
./scripts/verify-credentials.sh
```

### Test Supabase Connection
```bash
npm run dev
# Navigate to app and check if data loads
```

### Test API Keys
```bash
# From admin portal Settings → API Keys module
# Should show green checkmarks for configured services
```

---

## Priority Order

### 🔥 Critical (Complete ASAP)
1. ✅ Supabase - **DONE**
2. ⚠️ Security Secrets - **Generate now**
3. ⚠️ GitHub Tokens - **Needed for repo management**

### 🎯 High Priority (Complete This Week)
4. ⚠️ Cloudflare R2 - **Complete R2 setup for asset storage**
5. ⚠️ Vercel - **For deployment automation**
6. ⚠️ Google Analytics - **For tracking**

### 📊 Medium Priority (Complete This Month)
7. ⚠️ OpenAI - **For AI features**
8. ⚠️ Anthropic Claude - **For advanced AI**
9. ⚠️ Stripe - **For payment processing**

### 🎨 Low Priority (Optional)
10. ⏸️ Sentry - **Error tracking**
11. ⏸️ SendGrid - **Email service**
12. ⏸️ Twilio - **SMS service**

---

## Next Steps

### Immediate Actions Needed

1. **Generate Security Secrets** (5 minutes)
   ```bash
   # Run 3 times for JWT, Encryption, Session secrets
   node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
   ```

2. **Team Members: Create GitHub Tokens** (10 minutes each)
   - Sam: [Create Token](https://github.com/settings/tokens/new)
   - Fred: [Create Token](https://github.com/settings/tokens/new)
   - Connor: [Create Token](https://github.com/settings/tokens/new)
   - See: `docs/GITHUB_TOKEN_SETUP.md`

3. **Complete Cloudflare R2 Setup** (5 minutes)
   - Get R2 Access Keys from dashboard
   - Add to `.env`

4. **Get Vercel Token** (5 minutes)
   - Create token at [Vercel Settings](https://vercel.com/account/tokens)
   - Get project IDs with `vercel project ls`

5. **Set up Google Analytics** (10 minutes)
   - Create GA4 property
   - Get Measurement ID
   - Add to `.env`

---

## Support & Questions

**Technical Setup Help**:
- Connor McNeely (CTO): connor@meauxbility.org

**Account Access Issues**:
- Sam (CEO): sam@meauxbility.org

**General Questions**:
- Team Slack: #admin-portal
- Documentation: See `CREDENTIALS.md`

---

## Update Log

| Date | Change | By |
|------|--------|-----|
| 2025-10-30 | Initial credential vault setup | Claude (AI) |
| 2025-10-30 | Added Supabase credentials | Claude (AI) |
| 2025-10-30 | Added Cloudflare API token & account ID | Claude (AI) |
| 2025-10-30 | Created GitHub token setup guide | Claude (AI) |

---

**Ready to proceed!**

Reply with any credentials you have available, and I'll add them to `.env` immediately.
