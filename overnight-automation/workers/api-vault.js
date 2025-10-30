// ==================================================================
// CLOUDFLARE WORKER 1: API VAULT
// ==================================================================
// Secure storage and retrieval of ALL API keys
// Access: https://api-vault.YOUR-ACCOUNT.workers.dev

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    // CORS headers
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    };

    // Handle preflight
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    // Authentication
    const authHeader = request.headers.get('Authorization');
    if (!authHeader || authHeader !== `Bearer ${env.API_VAULT_SECRET}`) {
      return new Response('Unauthorized', { status: 401 });
    }

    // Routes
    if (url.pathname === '/keys' && request.method === 'GET') {
      // List all keys (names only, not values)
      const keys = await env.API_VAULT.list();
      return new Response(JSON.stringify({
        keys: keys.keys.map(k => k.name),
        count: keys.keys.length
      }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    if (url.pathname.startsWith('/key/') && request.method === 'GET') {
      // Get specific key
      const keyName = url.pathname.split('/key/')[1];
      const value = await env.API_VAULT.get(keyName);

      if (!value) {
        return new Response('Key not found', { status: 404, headers: corsHeaders });
      }

      return new Response(JSON.stringify({ key: keyName, value }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    if (url.pathname === '/key' && request.method === 'POST') {
      // Store new key
      const { name, value, expiresIn } = await request.json();

      const options = expiresIn ? { expirationTtl: expiresIn } : {};
      await env.API_VAULT.put(name, value, options);

      return new Response(JSON.stringify({ success: true, key: name }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    return new Response('Not Found', { status: 404, headers: corsHeaders });
  }
};
