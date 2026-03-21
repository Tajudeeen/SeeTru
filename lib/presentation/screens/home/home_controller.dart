import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seetru/core/services/gecko_service.dart';
import 'package:seetru/data/models/crypto_asset.dart';
import 'package:seetru/data/models/gecko-model.dart';
import '../../../core/services/auth_service.dart';


// ─────────────────────────────────────────────────────────────────────────────
// Controller
// ─────────────────────────────────────────────────────────────────────────────
class HomeController extends GetxController {
  // ── State ──────────────────────────────────────────────────────────
  final RxBool isLoading = true.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedFilter = 'All'.obs;
  final RxBool isBalanceVisible = true.obs;
  final RxString greeting = ''.obs;
  final RxString userName = 'User'.obs;

  // ── Data ───────────────────────────────────────────────────────────
  final RxList<CryptoAsset> trendingAssets = <CryptoAsset>[].obs;
  final RxList<CryptoAsset> watchlistAssets = <CryptoAsset>[].obs;
  final RxList<CryptoAsset> gainers = <CryptoAsset>[].obs;
  final RxList<CryptoAsset> losers = <CryptoAsset>[].obs;
  final RxList<VCDeal> recentDeals = <VCDeal>[].obs;
  final RxList<MarketStat> marketStats = <MarketStat>[].obs;
  final RxDouble totalPortfolioValue = 0.0.obs;
  final RxDouble portfolioChange = 0.0.obs;

  // ── Static lists (no need for .obs — never change) ─────────────────
  final RxList<String> filterTabs =
      <String>['All', 'DeFi', 'L1/L2', 'NFT', 'Gaming'].obs;

  @override
  void onReady() {
    super.onReady();
    _setGreeting();
    _loadUserName();
    _loadData();
  }

  void _setGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      greeting.value = 'Good morning';
    } else if (hour < 17) {
      greeting.value = 'Good afternoon';
    } else {
      greeting.value = 'Good evening';
    }
  }

  void _loadUserName() {
    try {
      final user = AuthService.to.currentUser;
      if (user != null) {
        userName.value = user.displayName?.split(' ').first ?? 'User';
      }
    } catch (_) {
      userName.value = 'User';
    }
  }

  // ── Load all data ──────────────────────────────────────────────────
  Future<void> _loadData() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      // Run market data + VC deals in parallel
      await Future.wait([
        _loadMarketData(),
        _loadVCDeals(),
      ]);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Load market data from CoinGecko ───────────────────────────────
  Future<void> _loadMarketData() async {
    final results = await Future.wait([
      CoinGeckoService.to.getTopCoins(perPage: 20),
      CoinGeckoService.to.getGlobalData(),
    ]);

    final coins = results[0] as List<CoinGeckoAsset>;
    final global = results[1] as GlobalMarketData?;

    // Map to CryptoAsset
    final assets = coins.map(CryptoAsset.fromCoinGecko).toList();

    trendingAssets.value = assets.take(10).toList();
    watchlistAssets.value = assets
        .where((a) =>
            ['bitcoin', 'ethereum', 'solana', 'bnb'].contains(a.id))
        .toList();

    // Sort gainers and losers
    final sorted = List<CryptoAsset>.from(assets)
      ..sort((a, b) => b.change24h.compareTo(a.change24h));
    gainers.value = sorted.where((a) => a.isPositive).take(3).toList();
    losers.value = sorted.reversed
        .where((a) => !a.isPositive)
        .take(3)
        .toList();

    // Build market stats from global data
    if (global != null) {
      marketStats.value = [
        MarketStat(
          label: 'Market Cap',
          value: _formatLarge(global.totalMarketCap),
          change:
              '${global.marketCapChangePercent24h >= 0 ? '+' : ''}${global.marketCapChangePercent24h.toStringAsFixed(1)}%',
          isPositive: global.marketCapChangePercent24h >= 0,
          icon: Icons.bar_chart_rounded,
        ),
        MarketStat(
          label: '24h Volume',
          value: _formatLarge(global.totalVolume24h),
          change: '+Vol',
          isPositive: true,
          icon: Icons.show_chart_rounded,
        ),
        MarketStat(
          label: 'BTC Dom.',
          value: '${global.btcDominance.toStringAsFixed(1)}%',
          change: 'BTC',
          isPositive: true,
          icon: Icons.donut_large_rounded,
        ),
        const MarketStat(
          label: 'Fear & Greed',
          value: '72',
          change: 'Greed',
          isPositive: true,
          icon: Icons.sentiment_satisfied_rounded,
        ),
      ];
    }
  }

  // ── Load VC deals (mock for now, wire CryptoRank later) ───────────
  Future<void> _loadVCDeals() async {
    await Future.delayed(const Duration(milliseconds: 200));
    recentDeals.value = [
      VCDeal(
        project: 'Monad Labs',
        category: 'Layer 1',
        amount: 225,
        currency: 'M',
        investors: ['Paradigm', 'a16z', 'Coinbase Ventures'],
        round: 'Series A',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
      VCDeal(
        project: 'Berachain',
        category: 'DeFi / L1',
        amount: 100,
        currency: 'M',
        investors: ['Framework', 'Polychain'],
        round: 'Series B',
        date: DateTime.now().subtract(const Duration(days: 5)),
      ),
      VCDeal(
        project: 'zkSync Era',
        category: 'Layer 2',
        amount: 458,
        currency: 'M',
        investors: ['a16z', 'Blockchain Capital'],
        round: 'Series C',
        date: DateTime.now().subtract(const Duration(days: 8)),
      ),
    ];
  }

  // ── Pull to refresh ────────────────────────────────────────────────
  @override
  Future<void> refresh() async {
    isRefreshing.value = true;
    CoinGeckoService.to.clearCache();
    try {
      await Future.wait([
        _loadMarketData(),
        _loadVCDeals(),
      ]);
    } catch (e) {
      Get.snackbar(
        'Refresh failed',
        e.toString(),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isRefreshing.value = false;
    }
  }

  // ── Actions ────────────────────────────────────────────────────────
  void toggleBalanceVisibility() =>
      isBalanceVisible.value = !isBalanceVisible.value;

  void setFilter(String filter) => selectedFilter.value = filter;

  // ── Formatters ─────────────────────────────────────────────────────
  String formatPrice(double price) {
    if (price >= 1000) {
      return '\$${price.toStringAsFixed(2).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          )}';
    }
    if (price >= 1) return '\$${price.toStringAsFixed(2)}';
    if (price >= 0.01) return '\$${price.toStringAsFixed(4)}';
    return '\$${price.toStringAsFixed(6)}';
  }

  String formatMarketCap(double cap) {
    if (cap >= 1e12) return '\$${(cap / 1e12).toStringAsFixed(2)}T';
    if (cap >= 1e9) return '\$${(cap / 1e9).toStringAsFixed(1)}B';
    if (cap >= 1e6) return '\$${(cap / 1e6).toStringAsFixed(1)}M';
    return '\$${cap.toStringAsFixed(0)}';
  }

  String _formatLarge(double value) {
    if (value >= 1e12) return '\$${(value / 1e12).toStringAsFixed(2)}T';
    if (value >= 1e9) return '\$${(value / 1e9).toStringAsFixed(1)}B';
    if (value >= 1e6) return '\$${(value / 1e6).toStringAsFixed(1)}M';
    return '\$${value.toStringAsFixed(0)}';
  }
}