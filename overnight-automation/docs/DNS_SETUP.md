# 🌐 DNS CONFIGURATION GUIDE

Complete guide for configuring custom domains for all 3 Meauxbility applications.

---

## 📋 Overview

You need to configure DNS for **3 custom domains**:

1. **iaudodidact.com** → Admin Portal (Vercel)
2. **meauxbility.org** → Nonprofit Site (Vercel)
3. **inneranimals.com** → E-commerce Shop (Vercel)

---

## 🎯 DNS Configuration Steps

### Step 1: Access Your Domain Registrar

Log in to your domain registrar dashboard (GoDaddy, Namecheap, Google Domains, etc.).

### Step 2: Configure DNS Records

For **each domain**, add the following DNS records:

#### Primary Domain (@)

```
Type: CNAME
Name: @  (or leave blank)
Value: cname.vercel-dns.com
TTL: Automatic (or 3600)
```

#### WWW Subdomain

```
Type: CNAME
Name: www
Value: cname.vercel-dns.com
TTL: Automatic (or 3600)
```

---

## 📊 Domain-Specific Configuration

### iaudodidact.com (Admin Portal)

**Current Status**: ⚠️ Already exists in Vercel, needs reassignment

**Vercel Project**: admin-portal

**DNS Records**:
```
CNAME @ → cname.vercel-dns.com
CNAME www → cname.vercel-dns.com
```

**Vercel Configuration**:
1. Go to Vercel Dashboard → admin-portal project
2. Settings → Domains
3. Ensure `iaudodidact.com` is assigned to THIS project
4. Add `www.iaudodidact.com` as alias

---

### meauxbility.org (Nonprofit Site)

**Current Status**: 🆕 Needs to be added

**Vercel Project**: meauxbility-org

**DNS Records**:
```
CNAME @ → cname.vercel-dns.com
CNAME www → cname.vercel-dns.com
```

**Vercel Configuration**:
1. Go to Vercel Dashboard → meauxbility-org project
2. Settings → Domains
3. Click "Add Domain"
4. Enter `meauxbility.org`
5. Add `www.meauxbility.org`

---

### inneranimals.com (E-commerce Shop)

**Current Status**: 🆕 Needs to be added

**Vercel Project**: inneranimals-shop

**DNS Records**:
```
CNAME @ → cname.vercel-dns.com
CNAME www → cname.vercel-dns.com
```

**Vercel Configuration**:
1. Go to Vercel Dashboard → inneranimals-shop project
2. Settings → Domains
3. Click "Add Domain"
4. Enter `inneranimals.com`
5. Add `www.inneranimals.com`

---

## 🔒 SSL/TLS Certificates

**Automatic**: Vercel automatically provisions SSL certificates via Let's Encrypt

**Timeline**:
- Certificate issuance: 1-5 minutes after DNS propagation
- Automatic renewal: Every 90 days

**Verification**:
```bash
# Check SSL certificate
curl -vI https://iaudodidact.com 2>&1 | grep "SSL certificate"
```

---

## ⏱️ DNS Propagation Timeline

| Stage | Time | What's Happening |
|-------|------|------------------|
| **Immediate** | 0-5 min | Records updated at registrar |
| **Local** | 5-30 min | ISP DNS caches update |
| **Regional** | 30min-4hrs | Regional DNS servers update |
| **Global** | 4-48 hrs | Full worldwide propagation |

**Tip**: Use incognito mode or different devices to test, as your browser may cache DNS.

---

## 🧪 Testing DNS Configuration

### Method 1: Command Line (Fastest)

```bash
# Check DNS resolution
dig iaudodidact.com
dig meauxbility.org
dig inneranimals.com

# Check CNAME records
dig iaudodidact.com CNAME
```

### Method 2: Online Tools

- **DNS Checker**: https://dnschecker.org/
- **What's My DNS**: https://www.whatsmydns.net/
- **DNS Propagation Checker**: https://www.dnswatch.info/

### Method 3: Vercel Dashboard

Go to each project → Settings → Domains

Status indicators:
- ✅ Green: DNS configured correctly
- ⚠️ Yellow: DNS propagating
- ❌ Red: DNS misconfigured

---

## 🐛 Troubleshooting

### Issue: "Domain Already Assigned"

**Error**: Cannot add domain to Vercel project

**Solution**:
1. Find which project currently has the domain:
   ```bash
   vercel domains ls --token DXVdcsOQ7QM2egQhLKNLraLr
   ```
2. Remove from old project:
   ```bash
   vercel domains rm iaudodidact.com --token DXVdcsOQ7QM2egQhLKNLraLr
   ```
3. Add to new project via Vercel Dashboard

---

### Issue: "Invalid Configuration"

**Error**: Vercel shows DNS configuration error

**Solution**:
1. Verify CNAME points to `cname.vercel-dns.com` (NOT an IP address)
2. Ensure `@` record is CNAME (not A record)
3. Remove any conflicting A records

---

### Issue: SSL Certificate Not Provisioning

**Error**: "Your connection is not private" warning

**Solution**:
1. Wait 24-48 hours for DNS propagation
2. Check domain is correctly added in Vercel
3. Verify DNS records with `dig` command
4. Contact Vercel support if issue persists after 48hrs

---

### Issue: WWW Not Working

**Error**: `www.domain.com` doesn't resolve

**Solution**:
1. Add separate CNAME record for `www`
2. In Vercel, add `www.domain.com` as a separate domain
3. Or set up redirect in Vercel

---

## 📞 Vercel Domain Commands

### List All Domains
```bash
vercel domains ls --token DXVdcsOQ7QM2egQhLKNLraLr
```

### Add Domain to Project
```bash
vercel domains add meauxbility.org --token DXVdcsOQ7QM2egQhLKNLraLr
```

### Remove Domain
```bash
vercel domains rm old-domain.com --token DXVdcsOQ7QM2egQhLKNLraLr
```

### Verify Domain DNS
```bash
vercel domains verify meauxbility.org --token DXVdcsOQ7QM2egQhLKNLraLr
```

---

## 🎯 Automated DNS Setup Script

We've included a helper script:

```bash
cd /home/user/overnight-automation
./scripts/configure-dns.sh
```

This script will:
1. Check current domain status
2. Provide DNS record instructions
3. Verify configuration
4. Test accessibility

---

## ✅ Post-Configuration Checklist

After DNS configuration:

- [ ] All 3 domains resolve to correct Vercel projects
- [ ] SSL certificates issued (green lock icon in browser)
- [ ] WWW subdomains work
- [ ] HTTP automatically redirects to HTTPS
- [ ] No SSL warnings in any browser
- [ ] All pages load correctly on custom domains

---

## 📊 Expected Final State

| Domain | Points To | SSL | Status |
|--------|-----------|-----|--------|
| iaudodidact.com | admin-portal.vercel.app | ✅ | Active |
| www.iaudodidact.com | admin-portal.vercel.app | ✅ | Active |
| meauxbility.org | meauxbility-org.vercel.app | ✅ | Active |
| www.meauxbility.org | meauxbility-org.vercel.app | ✅ | Active |
| inneranimals.com | inneranimals-shop.vercel.app | ✅ | Active |
| www.inneranimals.com | inneranimals-shop.vercel.app | ✅ | Active |

---

## 🆘 Support

**DNS Issues**: connor@meauxbility.org
**Vercel Support**: https://vercel.com/support
**Domain Registrar**: Contact your registrar's support

---

**Last Updated**: 2025-10-30
**Guide Version**: 1.0
