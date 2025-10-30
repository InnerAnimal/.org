// GODMODE Agent - Minimal Template
// TODO: Copy full implementation from meauxbility-production

export default {
  async fetch(request, env, ctx) {
    return new Response('GODMODE Agent - Setup pending\nRun: wrangler deploy', {
      headers: { 'Content-Type': 'text/plain' }
    });
  }
};
