# Credential Vault Documentation

## Overview

This document provides instructions for managing API credentials and secrets for the Meauxbility Admin Portal and associated applications.

## Security Best Practices

### Critical Rules

1. **NEVER commit `.env` files to version control**
2. **NEVER share credentials in chat, email, or public channels**
3. **Use different credentials for development, staging, and production**
4. **Rotate credentials regularly (every 90 days minimum)**
5. **Use environment-specific permissions (least privilege principle)**
6. **Enable IP restrictions where available**
7. **Set credential expiration dates**

### File Permissions

Ensure your `.env` file has proper permissions:

```bash
chmod 600 .env
```

This makes the file readable/writable only by the owner.

## Setup Instructions

### 1. Initial Setup

Copy the example file and add your credentials:

```bash
cp env.example .env
```

### 2. Fill in Credentials

Open `.env` in your editor and replace placeholder values with your actual credentials. Follow the sections below for where to obtain each credential.

## Credential Sources

### Supabase

**Location:** https://app.supabase.com/project/_/settings/api

Required credentials:
- `VITE_SUPABASE_URL` - Your project URL
- `VITE_SUPABASE_ANON_KEY` - Public anon key (safe for frontend)
- `VITE_SUPABASE_SERVICE_ROLE_KEY` - Service role key (NEVER expose to frontend)

### Cloudflare

**Location:** https://dash.cloudflare.com/profile/api-tokens

Required credentials:
- `CLOUDFLARE_API_TOKEN` - API token with appropriate permissions
- `CLOUDFLARE_ACCOUNT_ID` - Your account ID
- `CLOUDFLARE_ZONE_ID` - DNS zone ID (if managing DNS)
- `CLOUDFLARE_EMAIL` - Your Cloudflare account email

**R2 Storage:**
- Three buckets already configured:
  - `meauxbility-assets` - Meauxbility Foundation assets
  - `inneranimals-assets` - Inner Animals brand assets
  - `iaudodidact-assets` - Admin Portal assets

**Note:** Current API token expires **November 3, 2025** - set calendar reminder to rotate!

### OpenAI

**Location:** https://platform.openai.com/api-keys

Required credentials:
- `OPENAI_API_KEY` - API key (starts with `sk-`)
- `OPENAI_ORGANIZATION_ID` - Organization ID (starts with `org-`)

**Cost Management:**
- Set usage limits in OpenAI dashboard
- Monitor usage regularly
- Use GPT-3.5-turbo for non-critical features to save costs

### Anthropic Claude

**Location:** https://console.anthropic.com/settings/keys

Required credentials:
- `ANTHROPIC_API_KEY` - API key (starts with `sk-ant-`)

**Usage Notes:**
- Both `VITE_ANTHROPIC_API_KEY` and `ANTHROPIC_API_KEY` should have the same value
- `VITE_` prefix is for frontend usage (if applicable)
- Non-prefixed version is for backend/server usage

### GitHub

**Location:** https://github.com/settings/tokens

Required credentials:
- `GITHUB_TOKEN` - Personal Access Token (PAT)
- `GITHUB_ORG` - Organization name (e.g., "meauxbility")
- `GITHUB_REPO` - Repository name

**Required Permissions:**
- `repo` - Full control of private repositories
- `read:org` - Read organization data
- `read:user` - Read user profile data
- `write:discussion` - Read and write discussions (if using)

**Security:**
- Use fine-grained tokens when possible
- Set expiration dates
- Limit to specific repositories if possible

### Vercel

**Location:** https://vercel.com/account/tokens

Required credentials:
- `VERCEL_TOKEN` - API token
- `VERCEL_ORG_ID` - Organization/team ID
- `VERCEL_PROJECT_ID` - Project ID
- `VERCEL_TEAM_ID` - Team ID (if using teams)

**Finding IDs:**
```bash
# Install Vercel CLI
npm i -g vercel

# Get project info
vercel project ls
```

### Google Services

#### Google Analytics

**Location:** https://analytics.google.com/

Required credentials:
- `VITE_GA_MEASUREMENT_ID` - Measurement ID (starts with `G-`)

**Setup:**
1. Create GA4 property
2. Add data stream for web
3. Copy Measurement ID

#### Google Cloud Platform

**Location:** https://console.cloud.google.com/

Required credentials:
- `GOOGLE_API_KEY` - API key
- `GOOGLE_PROJECT_ID` - Project ID
- `GOOGLE_CLIENT_ID` - OAuth client ID
- `GOOGLE_CLIENT_SECRET` - OAuth client secret

**Services to Enable:**
- Google Drive API (if using)
- Google Sheets API (if using)
- Google Calendar API (if using)

#### Google OAuth

Required for user authentication with Google:
- `GOOGLE_OAUTH_CLIENT_ID` - OAuth 2.0 Client ID
- `GOOGLE_OAUTH_CLIENT_SECRET` - OAuth 2.0 Client Secret

**Setup:**
1. Go to Google Cloud Console > APIs & Services > Credentials
2. Create OAuth 2.0 Client ID
3. Add authorized redirect URIs
4. Copy credentials

### Stripe

**Location:** https://dashboard.stripe.com/apikeys

Required credentials:
- `VITE_STRIPE_PUBLISHABLE_KEY` - Publishable key (safe for frontend)
- `STRIPE_SECRET_KEY` - Secret key (NEVER expose to frontend)
- `STRIPE_WEBHOOK_SECRET` - Webhook signing secret

**Test vs Production:**
- Use test keys (starts with `pk_test_` / `sk_test_`) in development
- Use live keys only in production
- Keep test and live credentials completely separate

**Webhooks:**
1. Set up webhook endpoint in Stripe dashboard
2. Configure events to listen for
3. Copy webhook signing secret

## Optional Services

### Sentry (Error Tracking)

**Location:** https://sentry.io/

- `VITE_SENTRY_DSN` - Data Source Name

### SendGrid (Email)

**Location:** https://app.sendgrid.com/settings/api_keys

- `SENDGRID_API_KEY` - API key

### Twilio (SMS)

**Location:** https://console.twilio.com/

- `TWILIO_ACCOUNT_SID` - Account SID
- `TWILIO_AUTH_TOKEN` - Auth token
- `TWILIO_PHONE_NUMBER` - Your Twilio phone number

## Application Configuration

### Environment

```bash
NODE_ENV=development|staging|production
VITE_APP_ENV=development|staging|production
```

### URLs

```bash
# Development
VITE_APP_URL=http://localhost:5173
VITE_API_URL=http://localhost:3000

# Production
VITE_APP_URL=https://admin.meauxbility.org
VITE_API_URL=https://api.meauxbility.org
```

### Feature Flags

Enable/disable features without code changes:

```bash
VITE_ENABLE_AI_FEATURES=true|false
VITE_ENABLE_ANALYTICS=true|false
VITE_ENABLE_PAYMENTS=true|false
```

## Security Settings

### Generating Secure Secrets

Use these commands to generate secure random strings:

```bash
# Node.js
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# OpenSSL
openssl rand -hex 32

# Python
python -c "import secrets; print(secrets.token_hex(32))"
```

Required secrets:
- `JWT_SECRET` - For signing JWT tokens
- `ENCRYPTION_KEY` - For encrypting sensitive data
- `SESSION_SECRET` - For session management

## Deployment

### Development

```bash
# Start development server
npm run dev
```

The app will automatically load variables from `.env`.

### Vercel Deployment

1. **Via CLI:**

```bash
# Install Vercel CLI
npm i -g vercel

# Link project
vercel link

# Add environment variables
vercel env add VITE_SUPABASE_URL
vercel env add VITE_SUPABASE_ANON_KEY
# ... repeat for all variables

# Deploy
vercel --prod
```

2. **Via Dashboard:**

- Go to project settings > Environment Variables
- Add all variables from `.env`
- Redeploy

### Cloudflare Pages Deployment

```bash
# Install Wrangler
npm i -g wrangler

# Login
wrangler login

# Deploy
wrangler pages deploy dist
```

Add environment variables in Cloudflare dashboard:
Settings > Environment Variables

## Credential Rotation Schedule

| Service | Rotation Frequency | Next Rotation |
|---------|-------------------|---------------|
| Cloudflare API Token | 90 days | Nov 3, 2025 |
| GitHub PAT | 90 days | TBD |
| Supabase Keys | 180 days | TBD |
| OpenAI API Key | 90 days | TBD |
| Anthropic API Key | 90 days | TBD |
| Stripe Keys | Never (rotate on compromise) | N/A |
| JWT/Session Secrets | 180 days | TBD |

## Troubleshooting

### Common Issues

**1. "Environment variable not found"**
- Ensure variable is in `.env`
- Variables for frontend must start with `VITE_`
- Restart dev server after adding variables

**2. "Authentication failed"**
- Check for extra spaces in credentials
- Verify credential hasn't expired
- Confirm correct environment (test vs production)

**3. "CORS errors"**
- Check `VITE_APP_URL` matches actual URL
- Configure CORS in API/backend

**4. "Rate limit exceeded"**
- Check API usage in service dashboard
- Implement rate limiting in your app
- Consider upgrading plan if needed

## Monitoring

### Regular Checks

- [ ] Monitor API usage/costs monthly
- [ ] Review access logs for suspicious activity
- [ ] Verify credential expiration dates
- [ ] Check for unused/unnecessary credentials
- [ ] Update this document when adding new services

### Usage Tracking

**Supabase:**
- Dashboard > Settings > Usage

**OpenAI:**
- Platform > Usage

**Cloudflare:**
- Analytics > Requests

**Stripe:**
- Dashboard > Developers > Events

## Emergency Procedures

### If Credentials Are Compromised

1. **Immediately rotate affected credentials**
2. **Revoke compromised credentials in service dashboard**
3. **Check access logs for unauthorized usage**
4. **Update `.env` with new credentials**
5. **Deploy updated credentials to all environments**
6. **Document incident and preventive measures**

### Emergency Contacts

- **Supabase Support:** https://supabase.com/support
- **Cloudflare Support:** https://dash.cloudflare.com/support
- **Stripe Support:** https://support.stripe.com/
- **GitHub Support:** https://support.github.com/

## Team Access

### Who Has Access

- **Sam** (CEO/Admin) - Full access to all credentials
- **Connor McNeely** (CTO) - Technical credentials only
- **Fred Williams** (CMO) - Marketing service credentials only

### Access Control

- Use separate credentials per team member where possible
- Implement service-specific RBAC
- Remove access immediately upon role change/departure
- Audit access quarterly

## Additional Resources

- [Supabase Documentation](https://supabase.com/docs)
- [Cloudflare Docs](https://developers.cloudflare.com/)
- [Vercel Docs](https://vercel.com/docs)
- [Vite Environment Variables](https://vitejs.dev/guide/env-and-mode.html)

## Updates

- **2025-10-30** - Initial credential vault setup
- **2025-10-30** - Added Cloudflare R2 bucket configuration
- **2025-10-30** - Added comprehensive service documentation

---

**Remember:** Security is everyone's responsibility. When in doubt, ask before sharing or committing any credential.
