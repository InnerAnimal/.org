-- ==================================================================
-- GODMODE AGENT - D1 Database Schema
-- ==================================================================

-- Execution logs table
CREATE TABLE IF NOT EXISTS execution_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  command TEXT NOT NULL,
  status TEXT NOT NULL CHECK(status IN ('success', 'error', 'running')),
  message TEXT,
  cost REAL DEFAULT 0,
  user_email TEXT,
  timestamp TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX idx_logs_command ON execution_logs(command);
CREATE INDEX idx_logs_status ON execution_logs(status);
CREATE INDEX idx_logs_timestamp ON execution_logs(timestamp DESC);
CREATE INDEX idx_logs_user ON execution_logs(user_email);

-- Spending tracking table
CREATE TABLE IF NOT EXISTS spending_tracking (
  id INTEGER PRIMARY KEY CHECK(id = 1),
  hourly_spent REAL DEFAULT 0,
  daily_spent REAL DEFAULT 0,
  last_hourly_reset TEXT NOT NULL DEFAULT (datetime('now')),
  last_daily_reset TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Initialize spending tracker
INSERT OR IGNORE INTO spending_tracking (id, hourly_spent, daily_spent)
VALUES (1, 0, 0);

-- Email monitoring table (#MEAUXWORK)
CREATE TABLE IF NOT EXISTS email_commands (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email_id TEXT UNIQUE NOT NULL,
  from_email TEXT NOT NULL,
  subject TEXT,
  command TEXT NOT NULL,
  payload TEXT,
  executed BOOLEAN DEFAULT 0,
  executed_at TEXT,
  result TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX idx_email_executed ON email_commands(executed);
CREATE INDEX idx_email_created ON email_commands(created_at DESC);

-- Command usage statistics
CREATE TABLE IF NOT EXISTS command_stats (
  command TEXT PRIMARY KEY,
  execution_count INTEGER DEFAULT 0,
  total_cost REAL DEFAULT 0,
  avg_duration_ms INTEGER DEFAULT 0,
  success_count INTEGER DEFAULT 0,
  error_count INTEGER DEFAULT 0,
  last_executed TEXT
);

-- User permissions table
CREATE TABLE IF NOT EXISTS user_permissions (
  email TEXT PRIMARY KEY,
  role TEXT NOT NULL CHECK(role IN ('admin', 'cto', 'cmo', 'member')),
  daily_spending_limit REAL DEFAULT 5.00,
  allowed_categories TEXT,  -- JSON array of allowed command categories
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

-- Insert team members
INSERT OR IGNORE INTO user_permissions (email, role, daily_spending_limit, allowed_categories) VALUES
  ('sam@meauxbility.org', 'admin', 10.00, '["*"]'),
  ('connor@meauxbility.org', 'cto', 5.00, '["app-types", "ai-features", "github", "technical"]'),
  ('fred@meauxbility.org', 'cmo', 3.00, '["marketing", "analytics", "social"]');

-- GitHub cache table
CREATE TABLE IF NOT EXISTS github_cache (
  key TEXT PRIMARY KEY,
  data TEXT NOT NULL,
  expires_at TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX idx_github_expires ON github_cache(expires_at);

-- Analytics events table
CREATE TABLE IF NOT EXISTS analytics_events (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  event_type TEXT NOT NULL,
  event_data TEXT,  -- JSON
  user_email TEXT,
  timestamp TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE INDEX idx_analytics_type ON analytics_events(event_type);
CREATE INDEX idx_analytics_timestamp ON analytics_events(timestamp DESC);

-- Views for quick stats
CREATE VIEW IF NOT EXISTS daily_stats AS
SELECT
  date(timestamp) as date,
  COUNT(*) as total_executions,
  SUM(CASE WHEN status = 'success' THEN 1 ELSE 0 END) as successful,
  SUM(CASE WHEN status = 'error' THEN 1 ELSE 0 END) as failed,
  SUM(cost) as total_cost
FROM execution_logs
GROUP BY date(timestamp)
ORDER BY date DESC;

CREATE VIEW IF NOT EXISTS top_commands AS
SELECT
  command,
  execution_count,
  total_cost,
  ROUND(total_cost / execution_count, 4) as avg_cost,
  ROUND(100.0 * success_count / execution_count, 2) as success_rate
FROM command_stats
WHERE execution_count > 0
ORDER BY execution_count DESC
LIMIT 10;
