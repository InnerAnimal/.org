#!/bin/bash
# ==================================================================
# D1 DATABASE SETUP
# ==================================================================
# Create Cloudflare D1 database for edge caching and analytics

set -e

echo "🗄️  Setting up Cloudflare D1 Database..."
echo ""

# ==================================================================
# CREATE D1 DATABASE
# ==================================================================
echo "Creating D1 database: meauxbility-edge-cache..."
wrangler d1 create meauxbility-edge-cache || echo "Database already exists"

# Get database ID
DB_ID=$(wrangler d1 list | grep "meauxbility-edge-cache" | awk '{print $2}')

echo "✅ Database created with ID: $DB_ID"
echo ""

# ==================================================================
# CREATE SCHEMA
# ==================================================================
echo "Creating database schema..."

cat > /tmp/schema.sql <<EOF
-- ==================================================================
-- EDGE CACHE TABLE
-- ==================================================================
CREATE TABLE IF NOT EXISTS cache (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  expires_at INTEGER NOT NULL,
  created_at INTEGER DEFAULT (unixepoch()),
  updated_at INTEGER DEFAULT (unixepoch())
);

CREATE INDEX idx_expires ON cache(expires_at);

-- ==================================================================
-- ANALYTICS BUFFER TABLE
-- ==================================================================
CREATE TABLE IF NOT EXISTS analytics_buffer (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  event TEXT NOT NULL,
  source TEXT NOT NULL,
  page TEXT,
  user_id TEXT,
  session_id TEXT,
  properties TEXT,
  timestamp INTEGER DEFAULT (unixepoch())
);

CREATE INDEX idx_timestamp ON analytics_buffer(timestamp);
CREATE INDEX idx_source ON analytics_buffer(source);

-- ==================================================================
-- RATE LIMITING TABLE
-- ==================================================================
CREATE TABLE IF NOT EXISTS rate_limits (
  key TEXT PRIMARY KEY,
  count INTEGER DEFAULT 0,
  window_start INTEGER NOT NULL,
  expires_at INTEGER NOT NULL
);

CREATE INDEX idx_rate_expires ON rate_limits(expires_at);

-- ==================================================================
-- SESSION TRACKING TABLE
-- ==================================================================
CREATE TABLE IF NOT EXISTS sessions (
  session_id TEXT PRIMARY KEY,
  user_id TEXT,
  source TEXT NOT NULL,
  started_at INTEGER DEFAULT (unixepoch()),
  last_active INTEGER DEFAULT (unixepoch()),
  page_views INTEGER DEFAULT 1
);

CREATE INDEX idx_user ON sessions(user_id);
CREATE INDEX idx_last_active ON sessions(last_active);
EOF

# Execute schema
wrangler d1 execute meauxbility-edge-cache --file=/tmp/schema.sql

echo "✅ Database schema created"
echo ""

# ==================================================================
# CREATE HELPER FUNCTIONS (via SQL)
# ==================================================================
echo "Creating helper views..."

cat > /tmp/views.sql <<EOF
-- View: Active sessions (last 30 minutes)
CREATE VIEW IF NOT EXISTS active_sessions AS
SELECT
  source,
  COUNT(*) as active_count,
  AVG(page_views) as avg_page_views
FROM sessions
WHERE last_active > unixepoch() - 1800
GROUP BY source;

-- View: Cache hit rate
CREATE VIEW IF NOT EXISTS cache_stats AS
SELECT
  COUNT(*) as total_entries,
  SUM(CASE WHEN expires_at > unixepoch() THEN 1 ELSE 0 END) as valid_entries,
  SUM(CASE WHEN expires_at <= unixepoch() THEN 1 ELSE 0 END) as expired_entries
FROM cache;
EOF

wrangler d1 execute meauxbility-edge-cache --file=/tmp/views.sql

echo "✅ Database views created"
echo ""

# ==================================================================
# UPDATE WRANGLER.TOML
# ==================================================================
echo "Updating wrangler.toml..."

cat >> wrangler.toml <<EOF

# ==================================================================
# D1 DATABASE BINDING
# ==================================================================
[[d1_databases]]
binding = "EDGE_DB"
database_name = "meauxbility-edge-cache"
database_id = "$DB_ID"
EOF

echo "✅ wrangler.toml updated with D1 binding"
echo ""

# ==================================================================
# VERIFY SETUP
# ==================================================================
echo "🔍 Verifying database..."
wrangler d1 execute meauxbility-edge-cache --command="SELECT name FROM sqlite_master WHERE type='table';"

echo ""
echo "🎉 D1 Database setup complete!"
echo ""
echo "📊 Database Details:"
echo "   • Name: meauxbility-edge-cache"
echo "   • ID: $DB_ID"
echo "   • Tables: cache, analytics_buffer, rate_limits, sessions"
echo "   • Views: active_sessions, cache_stats"
echo ""
echo "💡 Usage in workers:"
echo "   const result = await env.EDGE_DB.prepare("
echo "     'SELECT value FROM cache WHERE key = ?'"
echo "   ).bind(key).first();"
