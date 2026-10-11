import { createServer } from 'node:http';
import { createGateway } from './gateway.mjs';
const handler = createGateway();
const server = createServer(async (req, res) => {
  try {
    const request = new Request(`http://localhost${req.url}`, { method: req.method, headers: req.headers });
    const response = await handler(request, { clientIp: req.socket.remoteAddress || 'unknown' });
    res.writeHead(response.status, Object.fromEntries(response.headers));
    res.end(Buffer.from(await response.arrayBuffer()));
  } catch { res.writeHead(500, { 'Content-Type': 'application/json' }); res.end('{"error":"Request failed."}'); }
});
server.requestTimeout = 15000; server.headersTimeout = 10000;
server.listen(Number(process.env.PORT) || 8787, process.env.HOST || '127.0.0.1', () => console.log('SeeTru gateway is listening.'));
