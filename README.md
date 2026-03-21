# SeeTru — Crypto Intelligence App
### Flutter + GetX + Firebase + Clean Architecture

---

## 🚀 Project Overview

SeeTru is a **production-grade Flutter crypto intelligence app** with:
- **Real-time price tracking** via CoinGecko, CoinMarketCap & CryptoRank APIs
- **VC & fundraising data** from CryptoRank
- **On-chain intelligence** from Dune Analytics
- **Social alpha feed** from X (Twitter) API v2
- **Firebase backend** for auth, Firestore, push notifications
- **GetX** throughout — every screen has Controller + Binding + View

---

## 📁 Full File Structure

```
lib/
├── main.dart                          # App entry point
├── app/
│   ├── app.dart                       # GetMaterialApp root
│   └── routes/
│       └── app_routes.dart            # All named routes + GetPages
│
├── core/
│   ├── constants/
│   │   ├── app_colors.dart            # Full colour palette + gradients
│   │   ├── app_text_styles.dart       # ClashDisplay + Satoshi type scale
│   │   └── app_sizes.dart             # Spacing, radii, icon sizes, strings
│   └── theme/
│       └── app_theme.dart             # Light + Dark ThemeData
│
└── presentation/
    └── screens/
        ├── splash/                    # ✅ Full (animated, orbs, grid, dots)
        │   ├── splash_controller.dart
        │   ├── splash_binding.dart
        │   └── splash_view.dart
        ├── onboarding/               # ✅ Full (3 pages, charts, illustrations)
        │   ├── onboarding_controller.dart
        │   ├── onboarding_binding.dart
        │   └── onboarding_view.dart
        ├── auth/                     # ✅ Full (Sign In/Up, Google, Apple, validation)
        │   ├── auth_controller.dart
        │   ├── auth_binding.dart
        │   └── auth_view.dart
        ├── main/                     # ✅ Full (IndexedStack + animated bottom nav)
        │   ├── main_controller.dart
        │   ├── main_binding.dart
        │   └── main_view.dart
        ├── home/                     # ✅ Full (portfolio card, market stats, VC deals, watchlist)
        │   ├── home_controller.dart
        │   ├── home_binding.dart
        │   └── home_view.dart
        ├── portfolio/                # ✅ Full (donut chart, line chart, holdings, P&L)
        │   ├── portfolio_controller.dart
        │   ├── portfolio_binding.dart
        │   └── portfolio_view.dart
        ├── social/                   # ✅ Full (X feed, trending, KOLs, sentiment gauge)
        │   ├── social_controller.dart
        │   ├── social_binding.dart
        │   └── social_view.dart
        ├── notifications/            # ✅ Full (grouped, read/unread, filter chips, actions)
        │   ├── notification_controller.dart
        │   ├── notification_binding.dart
        │   └── notification_view.dart
        ├── history/                  # ✅ Full (grouped tx list, monthly summary, detail sheet)
        │   ├── history_controller.dart
        │   ├── history_binding.dart
        │   └── history_view.dart
        │   ├── activity_history_controller.dart  # ✅ Full (timeline, on-chain, VC, social events)
        │   ├── activity_history_binding.dart
        │   └── activity_history_view.dart
        ├── settings/                 # ✅ Full (toggles, API status, language, currency, biometrics)
        │   ├── settings_controller.dart
        │   ├── settings_binding.dart
        │   └── settings_view.dart
        ├── profile/                  # ✅ Full (hero, stats, badges, portfolio card, quick links)
        │   ├── user_profile_controller.dart
        │   ├── user_profile_binding.dart
        │   ├── user_profile_view.dart
        │   ├── edit_profile_controller.dart   # ✅ Full (form, avatar, coin prefs, danger zone)
        │   ├── edit_profile_binding.dart
        │   └── edit_profile_view.dart
        └── watchlist/                # ✅ Full (search, trending tokens, one-tap add/remove)
            ├── add_token_controller.dart
            ├── add_token_binding.dart
            └── add_token_view.dart
```

---

## ⚙️ Setup Instructions

### 1. Clone & Install
```bash
git clone <your-repo>
cd seetru
flutter pub get
```

### 2. Firebase Setup
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure for your Firebase project
flutterfire configure

# Then uncomment Firebase init in main.dart
```

### 3. Environment / API Keys
Create `lib/core/config/app_config.dart`:
```dart
class AppConfig {
  // CoinGecko (free tier available)
  static const String coinGeckoApiKey = 'YOUR_COINGECKO_API_KEY';
  static const String coinGeckoBaseUrl = 'https://api.coingecko.com/api/v3';

  // CoinMarketCap
  static const String cmcApiKey = 'YOUR_CMC_API_KEY';
  static const String cmcBaseUrl = 'https://pro-api.coinmarketcap.com/v1';

  // CryptoRank
  static const String cryptoRankApiKey = 'YOUR_CRYPTORANK_API_KEY';
  static const String cryptoRankBaseUrl = 'https://api.cryptorank.io/v1';

  // Dune Analytics
  static const String duneApiKey = 'YOUR_DUNE_API_KEY';
  static const String duneBaseUrl = 'https://api.dune.com/api/v1';

  // X (Twitter) API v2
  static const String xBearerToken = 'YOUR_X_BEARER_TOKEN';
  static const String xBaseUrl = 'https://api.twitter.com/2';
}
```

### 4. Custom Fonts
Download and place in `assets/fonts/`:
- **Satoshi**: https://www.fontshare.com/fonts/satoshi
- **ClashDisplay**: https://www.fontshare.com/fonts/clash-display

### 5. Assets Folder
Create these directories:
```bash
mkdir -p assets/images assets/icons assets/animations assets/fonts
```

### 6. Run
```bash
flutter run
```

---

## 🎨 Design System

| Token | Value |
|-------|-------|
| Primary | `#1A2B6D` (Deep Navy) |
| Accent | `#4C6FFF` (Vivid Blue) |
| Teal | `#00C6CF` |
| Green | `#00C48C` |
| Red | `#FF6B6B` |
| Background | `#F0F4FF` |
| Surface | `#FFFFFF` |
| Display Font | ClashDisplay |
| Body Font | Satoshi |

---

## 📦 Key Dependencies

| Package | Purpose |
|---------|---------|
| `get` | State management, routing, DI |
| `get_storage` | Lightweight local storage |
| `firebase_*` | Auth, Firestore, Notifications |
| `dio` | HTTP client for all APIs |
| `twitter_api_v2` | X (Twitter) social feed |
| `fl_chart` | Charts & sparklines |
| `flutter_local_notifications` | Price alerts |
| `local_auth` | Biometric login |
| `flutter_secure_storage` | Encrypted token storage |
| `cached_network_image` | Network images |
| `shimmer` | Loading skeleton |
| `lottie` | JSON animations |

---

## 🏗 Architecture

```
Presentation (GetView + GetxController)
     ↕
Domain (Use Cases + Entities)
     ↕
Data (Repositories + API Providers + Firebase)
```

Every screen follows: **View → Controller → Binding**
- `View` is stateless, reads from `controller.obs` variables
- `Controller` manages business logic and state
- `Binding` lazy-initialises the controller when the route is opened

---

## 📱 All Screens

| # | Screen | Status | Features |
|---|--------|--------|---------|
| 1 | Splash | ✅ Full | Animated logo, orbs, grid, pulsing dots, smart navigation |
| 2 | Onboarding | ✅ Full | 3 illustrated pages, animated dots, skip/continue |
| 3 | Auth | ✅ Full | Sign In/Up, Google, Apple, form validation, forgot password |
| 4 | Home | ✅ Full | Portfolio card, market stats, promo banner, trending, VC deals, watchlist, shimmer |
| 5 | Portfolio | ✅ Full | Balance, chart (6 ranges), donut allocation, holdings, P&L, transactions |
| 6 | Social | ✅ Full | X feed, trending topics, KOLs, Fear&Greed, sentiment bars |
| 7 | Notifications | ✅ Full | Read/unread, grouped, filter chips, action buttons |
| 8 | History | ✅ Full | Grouped tx list, monthly summary, detail sheet, search |
| 9 | Activity | ✅ Full | Timeline, on-chain moves, VC events, sparkline chart |
| 10 | Settings | ✅ Full | Dark mode, biometrics, notifications, API status, currency |
| 11 | Profile | ✅ Full | Hero, stats, badges, portfolio card, quick links |
| 12 | Edit Profile | ✅ Full | Form, avatar, coin prefs, danger zone |
| 13 | Add Token | ✅ Full | Search, trending list, one-tap add/remove with animation |
| 14 | Main Shell | ✅ Full | Persistent bottom nav with animated active indicator |

---

Built with ❤️ by SeeTru — *See the Truth in Crypto*