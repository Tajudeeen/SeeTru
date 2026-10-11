# Verification evidence

Validated locally on 2026-10-11 using Flutter 3.47.7, Dart 3.13.5 and Node 24.19.0 (gateway supports Node 22+).

| Check | Result |
| --- | --- |
| Dart format | Clean |
| Flutter analyzer | No issues |
| Flutter tests | 20 passed |
| Node gateway tests | 7 passed |
| Release JavaScript web build | Passed |
| Render inspection | Phone 390×844 and desktop 1280×900, using bundled fonts |
| Live CoinGecko request through gateway | HTTP 200; requested Bitcoin identity and provider timestamp returned |

The Flutter suite covers chronological cost basis and fees, overselling, invalid values, backup validation, one-time fresh alerts, failed durable writes, concurrent edits, unavailable valuation, supporting-purchase deletion, restart persistence, request identity/deduplication, cache fallback and cache-write failures. Widget tests navigate all four tabs on phone and desktop and record a trade through provider search, verifying its stored ledger, cost basis and valuation.

Gateway tests cover unconfigured sources, exact CORS origins, methods, bounded routes, request deduplication, shared upstream budgets, credential-safe failures, partial provider outages, source dates and links, Dune row contracts and per-client limits.

The live market check returned one Bitcoin result with provider timestamp `2026-10-11T20:23:53.000Z`. This is connectivity and identity evidence, not a promise of quote freshness. The app evaluates the provider timestamp separately.

A browser automation binary could not be downloaded in this environment, so visual inspection used Flutter rendering rather than a browser. The JavaScript web compilation passed. GetStorage currently depends on `dart:html`, so the SDK's Wasm compatibility dry run warns; this release uses JavaScript and does not claim Wasm support.

## Configuration-dependent acceptance

Firebase sign-up, reset-email delivery, account backup isolation and cloud restore must be checked with the owner's Firebase project and deployed Firestore rules. CryptoRank, Dune and X contracts have fixture coverage; live access requires the owner's keys and provider plans. Physical Android/iOS builds, store signing, native network configuration and device accessibility remain release acceptance steps. No real trading, background monitoring, deployment or main-branch merge is claimed.
