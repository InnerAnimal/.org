// ==================================================================
// CLOUDFLARE WORKER 5: ANALYTICS AGGREGATOR
// ==================================================================
// Collect analytics from all 3 sites, aggregate, store in Supabase
// Real-time dashboard data for admin portal

import { createClient } from '@supabase/supabase-js';

export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    // CORS headers
    const corsHeaders = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
    };

    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders });
    }

    // Initialize Supabase
    const supabase = createClient(
      env.SUPABASE_URL,
      env.SUPABASE_SERVICE_ROLE_KEY
    );

    // Routes
    if (url.pathname === '/track' && request.method === 'POST') {
      return await trackEvent(request, supabase, corsHeaders);
    }

    if (url.pathname === '/aggregate' && request.method === 'GET') {
      return await getAggregatedData(supabase, corsHeaders);
    }

    if (url.pathname === '/dashboard' && request.method === 'GET') {
      return await getDashboardStats(supabase, corsHeaders);
    }

    return new Response('Not Found', { status: 404, headers: corsHeaders });
  }
};

async function trackEvent(request, supabase, corsHeaders) {
  const eventData = await request.json();

  // Validate event
  if (!eventData.event || !eventData.source) {
    return new Response(
      JSON.stringify({ error: 'Missing required fields' }),
      { status: 400, headers: corsHeaders }
    );
  }

  // Store event
  await supabase
    .from('analytics_events')
    .insert({
      event: eventData.event,
      source: eventData.source, // 'admin-portal', 'nonprofit', 'shop'
      page: eventData.page,
      user_id: eventData.userId,
      session_id: eventData.sessionId,
      properties: eventData.properties,
      timestamp: new Date().toISOString()
    });

  // Update real-time counters
  await updateCounters(eventData.source, eventData.event, supabase);

  return new Response(
    JSON.stringify({ success: true }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}

async function updateCounters(source, event, supabase) {
  const today = new Date().toISOString().split('T')[0];

  // Upsert daily stats
  const { data: existing } = await supabase
    .from('daily_stats')
    .select('*')
    .eq('date', today)
    .eq('source', source)
    .single();

  if (existing) {
    // Increment existing
    await supabase
      .from('daily_stats')
      .update({
        total_events: existing.total_events + 1,
        unique_visitors: existing.unique_visitors, // Would need session tracking
        page_views: event === 'page_view' ? existing.page_views + 1 : existing.page_views,
        updated_at: new Date().toISOString()
      })
      .eq('id', existing.id);
  } else {
    // Create new
    await supabase
      .from('daily_stats')
      .insert({
        date: today,
        source,
        total_events: 1,
        unique_visitors: 1,
        page_views: event === 'page_view' ? 1 : 0
      });
  }
}

async function getAggregatedData(supabase, corsHeaders) {
  const last30Days = new Date();
  last30Days.setDate(last30Days.getDate() - 30);

  const { data, error } = await supabase
    .from('daily_stats')
    .select('*')
    .gte('date', last30Days.toISOString().split('T')[0])
    .order('date', { ascending: true });

  if (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: corsHeaders }
    );
  }

  // Aggregate by source
  const aggregated = {
    'admin-portal': [],
    'nonprofit': [],
    'shop': []
  };

  data.forEach(row => {
    if (!aggregated[row.source]) aggregated[row.source] = [];
    aggregated[row.source].push({
      date: row.date,
      events: row.total_events,
      visitors: row.unique_visitors,
      pageViews: row.page_views
    });
  });

  return new Response(
    JSON.stringify(aggregated),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}

async function getDashboardStats(supabase, corsHeaders) {
  const today = new Date().toISOString().split('T')[0];

  // Get today's stats
  const { data: todayStats } = await supabase
    .from('daily_stats')
    .select('*')
    .eq('date', today);

  // Get total stats
  const { data: allTimeStats } = await supabase
    .from('daily_stats')
    .select('total_events, unique_visitors, page_views');

  // Calculate totals
  const totals = {
    today: {
      events: todayStats?.reduce((sum, row) => sum + row.total_events, 0) || 0,
      visitors: todayStats?.reduce((sum, row) => sum + row.unique_visitors, 0) || 0,
      pageViews: todayStats?.reduce((sum, row) => sum + row.page_views, 0) || 0
    },
    allTime: {
      events: allTimeStats?.reduce((sum, row) => sum + row.total_events, 0) || 0,
      visitors: allTimeStats?.reduce((sum, row) => sum + row.unique_visitors, 0) || 0,
      pageViews: allTimeStats?.reduce((sum, row) => sum + row.page_views, 0) || 0
    },
    bySource: todayStats || []
  };

  return new Response(
    JSON.stringify(totals),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
}
