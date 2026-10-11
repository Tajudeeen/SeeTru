import test from 'node:test';
import assert from 'node:assert/strict';
import { createGateway } from './gateway.mjs';
const json = (x, status = 200) => new Response(JSON.stringify(x), { status, headers: { 'content-type': 'application/json' } });
const req = (path, init) => new Request(`http://localhost${path}`, init);
test('unconfigured research is explicit and empty', async () => {
  const h = createGateway({ env: {}, fetcher: () => { throw Error('must not fetch'); } });
  const r = await h(req('/v1/research'));
  assert.equal(r.status, 200); assert.deepEqual(await r.json(), { items: [], providers: { CryptoRank: 'not_configured', Dune: 'not_configured', X: 'not_configured' } });
});
test('fixed routes validate origins, methods, IDs and chart ranges', async () => {
  const h = createGateway({ env: { ALLOWED_ORIGINS: 'https://app.test' }, fetcher: async () => json([]) });
  assert.equal((await h(req('/health', { headers: { origin: 'https://evil.test' } }))).status, 403);
  assert.equal((await h(req('/health', { method: 'POST' }))).status, 405);
  assert.equal((await h(req('/v1/market/coins/markets?ids=bad/coin'))).status, 400);
  assert.equal((await h(req('/v1/market/coins/bitcoin/market_chart?vs_currency=usd&days=2'))).status, 400);
  assert.equal((await h(req('/v1/market/search?query='))).status, 400);
  const good = await h(req('/health', { headers: { origin: 'https://app.test' } }));
  assert.equal(good.headers.get('access-control-allow-origin'), 'https://app.test');
});
test('cache deduplicates concurrent identical requests and separates identities', async () => {
  let count = 0;
  const h = createGateway({ env: {}, fetcher: async () => { count++; await new Promise(r => setTimeout(r, 5)); return json([]); } });
  const path = '/v1/market/coins/markets?ids=bitcoin';
  await Promise.all([h(req(path)), h(req(path))]); await h(req(path));
  assert.equal(count, 1); await h(req('/v1/market/coins/markets?ids=ethereum')); assert.equal(count, 2);
});
test('shared provider budget and sanitized failures', async () => {
  const h = createGateway({ env: { UPSTREAM_REQUESTS_PER_HOUR: '1', COINGECKO_DEMO_KEY: 'secret-value' },
    fetcher: async () => { throw Error('secret-value'); } });
  const first = await h(req('/v1/market/global')); assert.equal(first.status, 502);
  assert.ok(!(await first.text()).includes('secret-value'));
  assert.equal((await h(req('/v1/market/search?query=eth'))).status, 429);
});
test('one failed source does not hide other research', async () => {
  const h = createGateway({ env: { CRYPTORANK_API_KEY: 'k', DUNE_API_KEY: 'k', DUNE_QUERY_ID: '123', X_BEARER_TOKEN: 'k' },
    fetcher: async url => {
      if (url.includes('cryptorank')) return json({ data: [{ id: 1, currency: { name: 'Project' }, raised: 2000000, date: '2026-10-01', investors: [{ name: 'Investor' }] }] });
      if (url.includes('dune')) return json({ error: 'secret' }, 403);
      return json({ data: [{ id: '42', text: 'Original post', author_id: '1', created_at: '2026-10-02T00:00:00Z' }], includes: { users: [{ id: '1', username: 'researcher' }] } });
    } });
  const result = await (await h(req('/v1/research'))).json();
  assert.deepEqual(result.providers, { CryptoRank: 'available', Dune: 'unavailable', X: 'available' });
  assert.equal(result.items.length, 2); assert.equal(result.items[0].url, 'https://x.com/i/web/status/42');
  assert.equal(result.items[1].publishedAt, '2026-10-01T00:00:00.000Z');
});
test('Dune uses observed rows, safe source links and nullable dates', async () => {
  const h = createGateway({ env: { DUNE_API_KEY: 'k', DUNE_QUERY_ID: '123' }, fetcher: async () => json({ result: { rows: [
    { title: 'Observation', summary: 'Actual result', source_url: 'javascript:alert(1)', observed_at: 'bad' }, { unrelated: 5 }
  ] } }) });
  const result = await (await h(req('/v1/research'))).json();
  assert.equal(result.items.length, 1); assert.equal(result.items[0].publishedAt, null); assert.equal(result.items[0].url, 'https://dune.com/queries/123');
});
test('per-client rate limit does not trust forwarded headers', async () => {
  const h = createGateway({ env: {} });
  for (let i = 0; i < 60; i++) assert.equal((await h(req('/health'), { clientIp: 'a' })).status, 200);
  assert.equal((await h(req('/health', { headers: { 'x-forwarded-for': 'b' } }), { clientIp: 'a' })).status, 429);
  assert.equal((await h(req('/health'), { clientIp: 'b' })).status, 200);
});
