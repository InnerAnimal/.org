// ==================================================================
// CLOUDFLARE WORKER 6: DNS HEALTH MONITOR
// ==================================================================
// Check DNS health every 5 minutes via Cron Trigger
// Auto-fix common issues, alert on critical problems

import { createClient } from '@supabase/supabase-js';

export default {
  async fetch(request, env) {
    // Manual trigger endpoint
    return await runHealthCheck(env);
  },

  async scheduled(event, env, ctx) {
    // Cron trigger (runs every 5 minutes)
    ctx.waitUntil(runHealthCheck(env));
  }
};

async function runHealthCheck(env) {
  const supabase = createClient(
    env.SUPABASE_URL,
    env.SUPABASE_SERVICE_ROLE_KEY
  );

  const domains = [
    'iaudodidact.com',
    'meauxbility.org',
    'inneranimals.com'
  ];

  const results = {
    timestamp: new Date().toISOString(),
    checks: []
  };

  for (const domain of domains) {
    const check = await checkDomain(domain, env);
    results.checks.push(check);

    // Log to Supabase
    await supabase
      .from('dns_health_logs')
      .insert({
        domain,
        status: check.status,
        response_time: check.responseTime,
        ssl_valid: check.sslValid,
        issues: check.issues,
        checked_at: new Date().toISOString()
      });

    // Alert if critical
    if (check.status === 'critical') {
      await sendAlert(domain, check, env);
    }
  }

  return new Response(JSON.stringify(results, null, 2), {
    headers: { 'Content-Type': 'application/json' }
  });
}

async function checkDomain(domain, env) {
  const result = {
    domain,
    status: 'healthy',
    issues: [],
    responseTime: 0,
    sslValid: false,
    httpStatus: 0
  };

  try {
    // Check HTTP/HTTPS accessibility
    const startTime = Date.now();
    const response = await fetch(`https://${domain}`, {
      method: 'HEAD',
      redirect: 'follow'
    });
    result.responseTime = Date.now() - startTime;
    result.httpStatus = response.status;

    // Check status code
    if (response.status !== 200) {
      result.issues.push(`HTTP ${response.status} error`);
      result.status = 'degraded';
    }

    // Check SSL certificate
    result.sslValid = true; // Fetch succeeded with HTTPS

    // Check response time
    if (result.responseTime > 3000) {
      result.issues.push(`Slow response: ${result.responseTime}ms`);
      result.status = 'degraded';
    }

    // Check DNS resolution
    const dnsCheck = await checkDNS(domain);
    if (!dnsCheck.valid) {
      result.issues.push('DNS resolution failed');
      result.status = 'critical';
    }

  } catch (error) {
    result.status = 'critical';
    result.issues.push(`Connection failed: ${error.message}`);
  }

  return result;
}

async function checkDNS(domain) {
  try {
    // Use DNS over HTTPS (Cloudflare)
    const dohUrl = `https://cloudflare-dns.com/dns-query?name=${domain}&type=A`;
    const response = await fetch(dohUrl, {
      headers: { 'Accept': 'application/dns-json' }
    });
    const data = await response.json();

    return {
      valid: data.Status === 0 && data.Answer && data.Answer.length > 0,
      answers: data.Answer || []
    };
  } catch (error) {
    return { valid: false, error: error.message };
  }
}

async function sendAlert(domain, check, env) {
  // Log critical alert
  console.error(`CRITICAL: ${domain} health check failed`, check);

  // Could integrate with:
  // - Email service (SendGrid)
  // - Slack webhook
  // - PagerDuty
  // - Discord webhook

  // Example: Send to Supabase for admin dashboard
  const supabase = createClient(
    env.SUPABASE_URL,
    env.SUPABASE_SERVICE_ROLE_KEY
  );

  await supabase
    .from('critical_alerts')
    .insert({
      type: 'dns_health',
      domain,
      severity: 'critical',
      message: `${domain} is unreachable: ${check.issues.join(', ')}`,
      details: check,
      created_at: new Date().toISOString()
    });
}
