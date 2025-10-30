# GitHub Personal Access Token Setup Guide

## Overview

Each team member needs their own GitHub Personal Access Token (PAT) to enable repository management, issue tracking, and automation features in the Admin Portal.

## Why Individual Tokens?

- **Accountability**: Track actions by specific team members
- **Security**: Limit permissions based on roles
- **Flexibility**: Revoke individual tokens without affecting others
- **Audit Trail**: GitHub tracks all API activity by token

## Token Setup Instructions

### For All Team Members

#### Step 1: Navigate to GitHub Settings

1. Go to [GitHub.com](https://github.com)
2. Click your profile picture (top right)
3. Click **Settings**
4. Scroll down to **Developer settings** (bottom of left sidebar)
5. Click **Personal access tokens**
6. Click **Tokens (classic)**
7. Click **Generate new token** → **Generate new token (classic)**

#### Step 2: Configure Token

**Token Name**: `Meauxbility Admin Portal - [Your Name]`

Example:
- `Meauxbility Admin Portal - Sam`
- `Meauxbility Admin Portal - Fred`
- `Meauxbility Admin Portal - Connor`

**Expiration**: Select based on your preference
- **90 days** (Recommended) - More secure, requires periodic renewal
- **1 year** - Less frequent renewal
- **No expiration** - Not recommended (security risk)

**Note**: Set a calendar reminder to renew before expiration!

#### Step 3: Select Scopes (Permissions)

Required scopes depend on your role:

### Sam (CEO) - Admin Role

**Full Administrative Access:**

```
✅ repo (Full control of private repositories)
   ✅ repo:status
   ✅ repo_deployment
   ✅ public_repo
   ✅ repo:invite
   ✅ security_events

✅ admin:org (Full control of orgs and teams)
   ✅ write:org
   ✅ read:org
   ✅ manage_runners:org

✅ admin:repo_hook (Full control of repository hooks)
   ✅ write:repo_hook
   ✅ read:repo_hook

✅ delete_repo (Delete repositories)

✅ user (Update ALL user data)
   ✅ read:user
   ✅ user:email
   ✅ user:follow

✅ project (Full control of projects)
   ✅ read:project

✅ read:packages (Download packages)
```

### Connor (CTO) - Technical Operations

**Technical Management Access:**

```
✅ repo (Full control of private repositories)
   ✅ repo:status
   ✅ repo_deployment
   ✅ public_repo
   ✅ repo:invite
   ✅ security_events

✅ admin:org (Full control of orgs and teams)
   ✅ write:org
   ✅ read:org

✅ admin:repo_hook (Full control of repository hooks)
   ✅ write:repo_hook
   ✅ read:repo_hook

✅ workflow (Update GitHub Actions workflows)

✅ user (Update ALL user data)
   ✅ read:user
   ✅ user:email

✅ project (Full control of projects)
   ✅ read:project

✅ read:packages (Download packages)
```

### Fred (CMO) - Marketing & Content

**Content Management Access:**

```
✅ repo (Full control of private repositories)
   ✅ repo:status
   ✅ public_repo
   ✅ repo:invite

✅ read:org (Read org and team membership, read org projects)

✅ user (Update ALL user data)
   ✅ read:user
   ✅ user:email

✅ project (Full control of projects)
   ✅ read:project
```

#### Step 4: Generate Token

1. Scroll to bottom
2. Click **Generate token**
3. **IMPORTANT**: Copy the token immediately!
   - It will look like: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
   - You **cannot** see it again after leaving the page
4. Save it temporarily in a secure location

## Adding Token to Admin Portal

### Option 1: Direct Database Entry (Recommended for Security)

1. Log into Supabase: [https://ghiulqoqujsiofsjcrqk.supabase.co](https://ghiulqoqujsiofsjcrqk.supabase.co)
2. Go to **Table Editor**
3. Find the `api_keys` table
4. Add new row:
   ```
   user_id: [Your user ID from profiles table]
   service: github
   key_name: Personal Access Token
   encrypted_key: [Your token]
   permissions: [Copy from role template above]
   created_at: [Auto-generated]
   expires_at: [Your selected expiration date]
   ```

### Option 2: Via Admin Portal UI

1. Go to [https://iaudodidact.com](https://iaudodidact.com)
2. Login with your credentials
3. Navigate to **Settings** → **API Keys**
4. Click **Add GitHub Token**
5. Paste your token
6. Save

### Option 3: Via Environment Variable (Development Only)

For local development, you can add to `.env`:

```bash
# Sam's Token
GITHUB_TOKEN_SAM=ghp_your_token_here

# Fred's Token
GITHUB_TOKEN_FRED=ghp_your_token_here

# Connor's Token
GITHUB_TOKEN_CONNOR=ghp_your_token_here

# Or use a shared token for testing (not recommended for production)
GITHUB_TOKEN=ghp_your_token_here
VITE_GITHUB_TOKEN=ghp_your_token_here
```

**⚠️ WARNING**: Never commit tokens to git! `.env` is already in `.gitignore`.

## Token Usage in Admin Portal

Once configured, your token enables:

### For All Users
- View repository list
- Read repository information
- View issues and pull requests
- View commit history
- Access repository analytics

### For Admin/CTO
- Create and manage repositories
- Create and manage issues
- Merge pull requests
- Manage webhooks
- Configure branch protection
- Manage team access

### For CMO
- Create issues
- Comment on issues/PRs
- View analytics
- Manage content repositories

## Testing Your Token

### Via Command Line

```bash
# Replace YOUR_TOKEN with your actual token
curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/user

# Should return your GitHub user information
```

### Via Admin Portal

1. Navigate to **GitHub Module**
2. Check if repositories load
3. Try creating a test issue
4. If successful, token is working!

## Security Best Practices

### DO:
- ✅ Use a unique token per team member
- ✅ Set expiration dates (90 days recommended)
- ✅ Store tokens securely (password manager, Supabase encrypted storage)
- ✅ Revoke tokens immediately if compromised
- ✅ Use minimum required permissions for your role
- ✅ Rotate tokens regularly

### DON'T:
- ❌ Share tokens between team members
- ❌ Commit tokens to git
- ❌ Share tokens in Slack, email, or other unsecured channels
- ❌ Use tokens with excessive permissions
- ❌ Use "no expiration" tokens in production
- ❌ Hardcode tokens in application code

## Token Rotation Schedule

| Team Member | Current Token | Expires | Next Rotation | Status |
|-------------|---------------|---------|---------------|--------|
| Sam (CEO) | TBD | TBD | TBD | ⚠️ Needs Setup |
| Fred (CMO) | TBD | TBD | TBD | ⚠️ Needs Setup |
| Connor (CTO) | TBD | TBD | TBD | ⚠️ Needs Setup |

**Update this table when tokens are created or rotated.**

## Troubleshooting

### "Bad credentials" error

**Cause**: Token is invalid, expired, or revoked

**Solution**:
1. Generate a new token
2. Update in Admin Portal
3. Test again

### "Resource not accessible by integration" error

**Cause**: Token lacks required permissions

**Solution**:
1. Go to GitHub Settings → Developer Settings → Tokens
2. Click on your token
3. Add missing permissions
4. Regenerate token
5. Update in Admin Portal

### "Rate limit exceeded" error

**Cause**: Too many API requests

**Solution**:
- Wait for rate limit to reset (1 hour)
- Upgrade to GitHub Pro for higher limits
- Implement caching in Admin Portal

### Token not working in Admin Portal

**Checklist**:
1. Is token copied correctly? (No extra spaces)
2. Does token start with `ghp_`?
3. Are required permissions enabled?
4. Is token expired?
5. Is token saved in correct environment variable?

## GitHub API Rate Limits

**With Authentication (using token):**
- 5,000 requests per hour per user
- GraphQL: 5,000 points per hour

**Without Authentication:**
- 60 requests per hour per IP

**Checking your rate limit:**
```bash
curl -H "Authorization: token YOUR_TOKEN" https://api.github.com/rate_limit
```

## Additional Resources

- [GitHub PAT Documentation](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [GitHub API Documentation](https://docs.github.com/en/rest)
- [Token Permissions](https://docs.github.com/en/developers/apps/building-oauth-apps/scopes-for-oauth-apps)

## Emergency Procedures

### If Token is Compromised

1. **Immediately revoke token:**
   - Go to GitHub Settings → Developer Settings → Tokens
   - Find the compromised token
   - Click **Delete** or **Revoke**

2. **Generate new token:**
   - Follow setup instructions above
   - Use different name to distinguish from old token

3. **Update Admin Portal:**
   - Replace old token with new token
   - Test functionality

4. **Audit activity:**
   - Check GitHub audit log for unauthorized activity
   - Report to Sam if suspicious activity found

5. **Document incident:**
   - Date/time of compromise
   - How it was discovered
   - Actions taken
   - Preventive measures

## Support

**Technical Issues:**
- Connor McNeely (CTO): connor@meauxbility.org

**Account Access:**
- Sam (CEO): sam@meauxbility.org

**General Questions:**
- Team Slack: #admin-portal
- Email: tech@meauxbility.org

---

**Last Updated**: 2025-10-30
**Document Owner**: Connor McNeely (CTO)
**Next Review**: 2025-11-30
