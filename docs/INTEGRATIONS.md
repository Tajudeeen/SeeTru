# Integration contracts

## CoinGecko

The app and gateway support `/coins/markets`, `/global`, `/search` and `/coins/{id}/market_chart`, with USD prices and bounded chart ranges. The gateway fixes upstream hosts, validates parameters, caches identical requests and never proxies arbitrary URLs. `COINGECKO_DEMO_KEY` is server-only.

Reference: https://docs.coingecko.com/reference/introduction

## CryptoRank

`CRYPTORANK_API_KEY` enables `https://api.cryptorank.io/v3/funding-rounds/list?limit=20` with `X-Api-Key`. The adapter consumes the `data` list and maps project/currency name, round type, raised amount, investors and source date. Missing dates remain null. Provider access and response variations must be checked against the owner's subscription before release.

Reference: https://cryptorank.io/public-api/funding-rounds

## Dune

`DUNE_API_KEY` and numeric `DUNE_QUERY_ID` enable `/api/v1/query/{id}/results?limit=20` with `X-Dune-API-Key`. Create a query returning `title`, `summary`, optional `source_url` and `observed_at` columns. Only rows with a title and summary enter the feed. Missing source links fall back to the query page. Missing observation times fall back to the execution end timestamp, or remain unavailable. This reads results and does not start executions.

Reference: https://docs.dune.com/api-reference/executions/endpoint/get-query-result

## X

`X_BEARER_TOKEN` enables `/2/tweets/search/recent` using the server's `X_SEARCH_QUERY`, with author IDs and creation timestamps. Original text links to the source post. No sentiment, engagement or verification claims are inferred. Requires the appropriate X API access.

Reference: https://docs.x.com/x-api/posts/recent-search

## Gateway behavior

`GET /health` returns status. `GET /v1/research` returns `{items, providers}` with per-source `available`, `not_configured` or `unavailable`. An unavailable source does not hide healthy results. `GET /v1/market/...` supports the fixed routes above. Only GET/OPTIONS are allowed. Web origins must exactly match `ALLOWED_ORIGINS`.

Node 22 has no package dependencies. Default binding is loopback. Request timeouts, a streamed response size cap (4 MB), 12 concurrent upstream requests, 250 cache keys, 60 requests/client/minute and a shared hourly upstream budget constrain use. `UPSTREAM_REQUESTS_PER_HOUR` defaults to 120 and is capped at 1000. Budgets and rate limits reset on process restart and do not coordinate multiple instances. Incoming forwarded headers do not override the socket client address. Use an edge limit appropriate to your proxy before exposing this server publicly.

Errors never return upstream bodies or credentials. Credentials must be provided through server environment variables. Logs contain no request credentials. No endpoint accepts client-supplied upstream URLs, query execution requests or provider tokens.
