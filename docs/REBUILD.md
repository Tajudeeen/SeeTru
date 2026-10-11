# Rebuild decisions

The baseline was `a7ba2e4`, the original Flutter/GetX SeeTru application. Its README, routes and screen structure pointed to a mobile crypto intelligence product: combine markets, holdings, VC funding, on-chain data and social context in one workspace.

The baseline mixed real CoinGecko requests with hardcoded portfolio balances, token quantities, research posts, funding rounds, notifications and repeated chart series. Watchlist files were empty. Firebase initialized before any usable UI, asset declarations referenced missing directories, fonts were not registered, portrait orientation and fixed text scaling restricted accessibility, and the only widget test targeted the starter counter.

The rebuilt application keeps Flutter/GetX and the intended product, while replacing the screen/controller scaffolding with a smaller domain/data/UI structure. It starts with an empty portfolio and no invented research. Optional integrations report their state. Local writes serialize and publish only after durable storage succeeds. Request caches are keyed by coin identity, charts request their selected range, quote timestamps determine freshness, and a missing price prevents a misleading portfolio total.

Trades use chronological average-cost accounting including fees. Sales cannot exceed holdings available at their timestamp. Deleting a purchase validates subsequent sales before saving. Alerts require fresh matching quotes and persist one trigger. Export/restore validates a versioned workspace before replacing data.

The original platform application identifiers remain unchanged. Local workspace data now uses the `seetru_v2` GetStorage container and `workspace_v2` schema. Original hardcoded holdings and feeds are not migrated into user records. If old real device data exists under another schema, export it with the original application before upgrading and translate it into the documented version 2 schema. No unsupported migration silently imports it.

No public deployment or main-branch merge is performed by this rebuild. Paid sources and private account flows require the owner's configuration and live acceptance checks.
