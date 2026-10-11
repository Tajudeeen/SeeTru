# SeeTru

A Flutter crypto research workspace with live market data, a personal trade ledger, watchlists, price alerts and sourced research. Rebuilt from the original SeeTru concept without fabricated balances, posts, funding rounds or price histories.

## What works

| Area | Behavior |
| --- | --- |
| Markets | CoinGecko top 100, global overview, provider search, token details and separate 1D/7D/30D/90D/1Y chart requests |
| Watchlist | Persistent coin IDs, including tokens outside the top 100 |
| Portfolio | Empty by default; dated buys and sells, actual USD execution prices, fees, average cost, realized/unrealized P/L, holdings and history |
| Alerts | Above/below thresholds, fresh quotes only, one trigger per alert, unread state; checks while the app is open and on resume |
| Research | CryptoRank funding rounds, Dune observations and original X posts through the optional server; independent source availability |
| Saved research | Source bookmarks and personal notes with HTTPS references |
| Settings | Dark/light appearance, display name, balance privacy, validated JSON export/restore and reset |
| Accounts | Optional Firebase email/password, password reset and private manual cloud backups |
| Layout | Phone navigation and desktop rail, bundled typography, system text scaling |

Provider outages show actionable errors. Cached market data retains the original fetch time and quote timestamp. Missing values are unavailable rather than zero. SeeTru records transactions; it does not execute orders or connect to wallets.

## Run the app

Requires Flutter 3.47.7 (Dart 3.13.5) or a compatible SDK satisfying `pubspec.yaml`.

```sh
flutter pub get
flutter run
```

The app starts without Firebase or paid research credentials. It requests CoinGecko directly by default. Browser access can be affected by provider CORS or rate limits; use the gateway for deployed web apps.

```sh
cd server
cp .env.example .env
npm start
```

In a second terminal:

```sh
flutter run -d chrome --web-port 8080 --dart-define=SEETRU_API_BASE=http://localhost:8787
```

Use an HTTPS gateway URL for releases. Android emulator networking usually requires `http://10.0.2.2:8787` plus debug-only cleartext configuration; production Android should use HTTPS. Configure the gateway's exact `ALLOWED_ORIGINS` for web clients. Native clients do not send an Origin header.

## Optional accounts

Create your Firebase project, enable Email/Password Authentication and Firestore, then deploy `firestore.rules`. Add the web app's authorized domains and platform registration as applicable. Supply public Firebase client configuration with `--dart-define-from-file=firebase-config.json`:

```json
{
  "FIREBASE_API_KEY": "your-client-api-key",
  "FIREBASE_APP_ID": "your-app-id",
  "FIREBASE_PROJECT_ID": "your-project-id",
  "FIREBASE_SENDER_ID": "your-sender-id",
  "FIREBASE_AUTH_DOMAIN": "your-project.firebaseapp.com",
  "SEETRU_API_BASE": "https://your-gateway.example"
}
```

`firebase-config.json` is ignored. Never put CryptoRank, Dune or X credentials in Flutter defines. Firebase client configuration is public; Firestore rules control backup access. Accounts are optional and initialization failures preserve local access. Sign-in does not automatically sync or merge local data. Cloud restore explicitly replaces it after confirmation.

## Verify

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
node --test server/test.mjs
```

GitHub Actions runs these checks and uploads the web build. See [verification evidence](docs/VERIFICATION.md), [integration contracts](docs/INTEGRATIONS.md) and [rebuild decisions](docs/REBUILD.md).

## Boundaries

- Local data and JSON exports are not encrypted. Clearing application/browser storage removes local data. Export before changing devices.
- Alerts do not run in the background or send push notifications.
- Average cost is a tracking method, not a tax report. USD is the supported quote currency.
- Research requires provider credentials, permissions and quotas. The Dune integration reads the latest result of a configured query; it never triggers a paid query execution.
- The gateway has per-instance memory caches, rate limits and a shared request budget. Put it behind HTTPS and edge rate limiting/authentication before public exposure. CORS is not authentication. A distributed deployment needs shared quotas and durable caching.
- Native store releases still need your signing credentials, device testing and platform account configuration. Existing application identifiers are preserved for upgrade compatibility. Android release signing remains the repository's development setup.

## Structure

`lib/domain` contains validated models and ledger calculations. `lib/data` contains device storage, market access and optional Firebase. `lib/workspace_controller.dart` coordinates persisted changes and foreground refresh. `lib/ui` contains the responsive screens. `server` contains a dependency-free Node 22 provider gateway. Automated fixtures are confined to tests.
