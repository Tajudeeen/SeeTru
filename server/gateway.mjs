const ALLOWED_DAYS = new Set(['1', '7', '30', '90', '365']);
const ID = /^[a-z0-9][a-z0-9-]{0,99}$/;
const text = (x) => typeof x === 'string' ? x : '';
const date = (x) => {
  if (!x) return null;
  const value = typeof x === 'number' ? new Date(x < 1e12 ? x * 1000 : x) : new Date(x);
  return Number.isFinite(value.getTime()) ? value.toISOString() : null;
};
const https = (x, fallback) => {
  try { const u = new URL(x); return u.protocol === 'https:' ? u.href : fallback; }
  catch { return fallback; }
};
class GatewayError extends Error {
  constructor(status, message) { super(message); this.status = status; }
}
export function createGateway({ env = process.env, fetcher = fetch, now = Date.now } = {}) {
  const cache = new Map(), pending = new Map(), clients = new Map();
  const origins = new Set((env.ALLOWED_ORIGINS || '').split(',').map(x => x.trim()).filter(Boolean));
  let budgetStart = now(), budgetUsed = 0;
  const limit = Math.max(1, Math.min(1000, Number(env.UPSTREAM_REQUESTS_PER_HOUR) || 120));
  async function upstream(key, url, headers, ttl) {
    const hit = cache.get(key);
    if (hit && now() - hit.at < ttl) return hit.data;
    if (pending.has(key)) return pending.get(key);
    if (pending.size >= 12) throw new GatewayError(503, 'Data providers are busy. Try again shortly.');
    if (now() - budgetStart >= 3600000) { budgetStart = now(); budgetUsed = 0; }
    if (budgetUsed >= limit) throw new GatewayError(429, 'Provider request budget reached. Try again later.');
    budgetUsed++;
    const task = (async () => {
      try {
        const r = await fetcher(url, { headers, redirect: 'error', signal: AbortSignal.timeout(12000) });
        if (!r.ok) throw new GatewayError(r.status === 429 ? 429 : 502, 'The data provider is unavailable.');
        if (Number(r.headers.get('content-length')) > 4000000) throw new GatewayError(502, 'Provider response exceeds size limit.');
        const reader = r.body?.getReader();
        let content = '', bytes = 0;
        if (reader) {
          const decoder = new TextDecoder();
          try {
            while (true) {
              const { value, done } = await reader.read(); if (done) break;
              bytes += value.byteLength;
              if (bytes > 4000000) { await reader.cancel(); throw new GatewayError(502, 'Provider response exceeds size limit.'); }
              content += decoder.decode(value, { stream: true });
            }
            content += decoder.decode();
          } finally { reader.releaseLock(); }
        }
        const data = JSON.parse(content);
        if (cache.size >= 250) cache.delete(cache.keys().next().value);
        cache.set(key, { at: now(), data }); return data;
      } catch (e) {
        if (e instanceof GatewayError) throw e;
        throw new GatewayError(502, 'Could not read the data provider response.');
      }
    })();
    pending.set(key, task);
    try { return await task; } finally { pending.delete(key); }
  }
  async function research() {
    const providers = {}, items = [];
    async function load(name, configured, task) {
      if (!configured) { providers[name] = 'not_configured'; return; }
      try { items.push(...await task()); providers[name] = 'available'; }
      catch { providers[name] = 'unavailable'; }
    }
    await Promise.all([
      load('CryptoRank', env.CRYPTORANK_API_KEY, async () => {
        const r = await upstream('funding', 'https://api.cryptorank.io/v3/funding-rounds/list?limit=20', { 'X-Api-Key': env.CRYPTORANK_API_KEY }, 900000);
        if (!Array.isArray(r.data)) throw new Error('Invalid funding contract');
        return r.data.map((x, i) => {
          const project = x.currency || x.project || {};
          const title = text(project.name) || text(x.name) || 'Funding round';
          const amount = typeof x.raised === 'number' && Number.isFinite(x.raised) ? `Raised $${x.raised.toLocaleString('en-US')}. ` : '';
          const investors = (Array.isArray(x.investors) ? x.investors : []).map(y => text(y.name)).filter(Boolean).join(', ');
          return { id: `funding-${x.id ?? i}`, category: 'Funding', title,
            body: `${text(x.type) || 'Reported funding round'}. ${amount}${investors ? `Investors: ${investors}.` : ''}`,
            source: 'CryptoRank', url: https(x.url, 'https://cryptorank.io/funding-rounds'), publishedAt: date(x.date) };
        });
      }),
      load('Dune', env.DUNE_API_KEY && /^\d+$/.test(env.DUNE_QUERY_ID || ''), async () => {
        const r = await upstream('dune', `https://api.dune.com/api/v1/query/${env.DUNE_QUERY_ID}/results?limit=20`, { 'X-Dune-API-Key': env.DUNE_API_KEY }, 300000);
        const rows = r.result?.rows;
        if (!Array.isArray(rows)) throw new Error('Invalid Dune contract');
        return rows.filter(x => text(x.title) && text(x.summary)).map((x, i) => ({ id: `dune-${env.DUNE_QUERY_ID}-${i}`, category: 'On-chain',
          title: x.title, body: x.summary, source: 'Dune', url: https(x.source_url, `https://dune.com/queries/${env.DUNE_QUERY_ID}`),
          publishedAt: date(x.observed_at || r.execution_ended_at) }));
      }),
      load('X', env.X_BEARER_TOKEN, async () => {
        const params = new URLSearchParams({ query: env.X_SEARCH_QUERY || 'crypto -is:retweet lang:en', max_results: '10',
          'tweet.fields': 'created_at,author_id', expansions: 'author_id', 'user.fields': 'username' });
        const r = await upstream('social', `https://api.x.com/2/tweets/search/recent?${params}`, { Authorization: `Bearer ${env.X_BEARER_TOKEN}` }, 300000);
        if (r.errors && !r.data) throw new Error('Invalid X contract');
        const users = new Map((r.includes?.users || []).map(x => [x.id, x.username]));
        return (r.data || []).filter(x => text(x.id) && text(x.text)).map(x => ({ id: `x-${x.id}`, category: 'Social',
          title: users.get(x.author_id) ? `@${users.get(x.author_id)}` : 'Original X post', body: x.text,
          source: 'X', url: `https://x.com/i/web/status/${encodeURIComponent(x.id)}`, publishedAt: date(x.created_at) }));
      })
    ]);
    items.sort((a, b) => (b.publishedAt || '').localeCompare(a.publishedAt || ''));
    return { items, providers };
  }
  return async function gateway(request, { clientIp = 'unknown' } = {}) {
    const headers = { 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store', 'X-Content-Type-Options': 'nosniff', Vary: 'Origin' };
    const respond = (status, body) => new Response(body == null ? null : JSON.stringify(body), { status, headers });
    const origin = request.headers.get('origin');
    if (origin) {
      if (!origins.has(origin)) return respond(403, { error: 'Origin is not allowed.' });
      headers['Access-Control-Allow-Origin'] = origin;
      headers['Access-Control-Allow-Methods'] = 'GET, OPTIONS';
      headers['Access-Control-Allow-Headers'] = 'Content-Type';
    }
    if (request.method === 'OPTIONS') return respond(204, null);
    if (request.method !== 'GET') return respond(405, { error: 'Only GET requests are supported.' });
    const client = clients.get(clientIp);
    if (!client || now() - client.start >= 60000) {
      if (clients.size >= 10000) clients.delete(clients.keys().next().value);
      clients.set(clientIp, { start: now(), count: 1 });
    } else if (++client.count > 60) return respond(429, { error: 'Too many requests. Try again later.' });
    try {
      const u = new URL(request.url), path = u.pathname, p = u.searchParams;
      if (path === '/health') return respond(200, { status: 'ok' });
      if (path === '/v1/research') return respond(200, await research());
      if (!path.startsWith('/v1/market/')) throw new GatewayError(404, 'Route not found.');
      const route = path.slice('/v1/market'.length);
      let params = new URLSearchParams(), ttl = 120000;
      const only = (...keys) => { for (const key of p.keys()) if (!keys.includes(key)) throw new GatewayError(400, 'Unsupported query parameter.'); };
      if (route === '/coins/markets') {
        only('vs_currency', 'ids', 'order', 'per_page', 'page', 'sparkline');
        if (p.has('vs_currency') && p.get('vs_currency') !== 'usd') throw new GatewayError(400, 'Only USD quotes are supported.');
        const ids = p.get('ids');
        if (ids && (ids.length > 4000 || ids.split(',').length > 100 || ids.split(',').some(x => !ID.test(x)))) throw new GatewayError(400, 'Invalid coin IDs.');
        params = new URLSearchParams({ vs_currency: 'usd', order: 'market_cap_desc', per_page: '100', page: '1', sparkline: 'true' });
        if (ids) params.set('ids', [...new Set(ids.split(','))].sort().join(','));
      } else if (route === '/global') { only(); }
      else if (route === '/search') {
        only('query'); const query = (p.get('query') || '').trim();
        if (!query || query.length > 80) throw new GatewayError(400, 'Search requires 1 to 80 characters.');
        params.set('query', query); ttl = 300000;
      } else {
        const match = route.match(/^\/coins\/([a-z0-9-]+)\/market_chart$/);
        if (!match || !ID.test(match[1])) throw new GatewayError(404, 'Route not found.');
        only('vs_currency', 'days');
        if (p.get('vs_currency') !== 'usd' || !ALLOWED_DAYS.has(p.get('days'))) throw new GatewayError(400, 'Invalid chart currency or range.');
        params = new URLSearchParams({ vs_currency: 'usd', days: p.get('days') }); ttl = 300000;
      }
      const query = params.toString(), key = `${route}?${query}`;
      const data = await upstream(key, `https://api.coingecko.com/api/v3${route}${query ? `?${query}` : ''}`,
        env.COINGECKO_DEMO_KEY ? { 'x-cg-demo-api-key': env.COINGECKO_DEMO_KEY } : {}, ttl);
      return respond(200, data);
    } catch (e) { return respond(e instanceof GatewayError ? e.status : 500, { error: e instanceof GatewayError ? e.message : 'Could not complete the request.' }); }
  };
}
