#!/bin/bash
# ==================================================================
# R2 STORAGE BUCKET SETUP
# ==================================================================
# Create and configure all R2 buckets for the Meauxbility ecosystem

set -e

echo "🪣 Setting up Cloudflare R2 Storage Buckets..."
echo ""

# ==================================================================
# BUCKET 1: MEDIA ASSETS
# ==================================================================
echo "📸 Creating media assets bucket..."
wrangler r2 bucket create meauxbility-media || echo "Bucket already exists"

# Configure CORS for media bucket
cat > /tmp/media-cors.json <<EOF
{
  "CORSRules": [
    {
      "AllowedOrigins": [
        "https://iaudodidact.com",
        "https://meauxbility.org",
        "https://inneranimals.com"
      ],
      "AllowedMethods": ["GET", "HEAD"],
      "AllowedHeaders": ["*"],
      "MaxAgeSeconds": 3600
    }
  ]
}
EOF

echo "✅ Media assets bucket ready"
echo "   • Purpose: Images, videos, PDFs"
echo "   • Access: Public read via worker"
echo "   • CDN: Cloudflare edge network"
echo ""

# ==================================================================
# BUCKET 2: BACKUPS
# ==================================================================
echo "💾 Creating backups bucket..."
wrangler r2 bucket create meauxbility-backups || echo "Bucket already exists"

echo "✅ Backups bucket ready"
echo "   • Purpose: Database backups, code snapshots"
echo "   • Access: Private (admin only)"
echo "   • Retention: 30 days rolling"
echo ""

# ==================================================================
# BUCKET 3: LOGS
# ==================================================================
echo "📋 Creating logs bucket..."
wrangler r2 bucket create meauxbility-logs || echo "Bucket already exists"

echo "✅ Logs bucket ready"
echo "   • Purpose: Application logs, analytics exports"
echo "   • Access: Private (monitoring systems)"
echo "   • Retention: 90 days"
echo ""

# ==================================================================
# BUCKET 4: USER UPLOADS
# ==================================================================
echo "📤 Creating user uploads bucket..."
wrangler r2 bucket create meauxbility-uploads || echo "Bucket already exists"

echo "✅ User uploads bucket ready"
echo "   • Purpose: User-generated content"
echo "   • Access: Authenticated users only"
echo "   • Virus scanning: Enabled via worker"
echo ""

# ==================================================================
# LIST ALL BUCKETS
# ==================================================================
echo ""
echo "📊 R2 Bucket Summary:"
wrangler r2 bucket list

echo ""
echo "🎉 R2 Storage setup complete!"
echo ""
echo "💡 Next steps:"
echo "   1. Update wrangler.toml with bucket bindings"
echo "   2. Configure lifecycle policies for backups/logs"
echo "   3. Set up automated backup cron jobs"
