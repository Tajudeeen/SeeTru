import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TokenResult {
  final String id;
  final String name;
  final String symbol;
  final double price;
  final double change24h;
  final double marketCap;
  final int rank;
  final bool isWatchlisted;

  const TokenResult({
    required this.id,
    required this.name,
    required this.symbol,
    required this.price,
    required this.change24h,
    required this.marketCap,
    required this.rank,
    required this.isWatchlisted,
  });

  bool get isPositive => change24h >= 0;
}

class AddTokenController extends GetxController {
  final searchController = TextEditingController();
  final RxString query = ''.obs;
  final RxBool isSearching = false.obs;
  final RxList<TokenResult> searchResults = <TokenResult>[].obs;
  final RxList<TokenResult> trendingTokens = <TokenResult>[].obs;
  final RxSet<String> watchlistedIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTrending();
  }

  void _loadTrending() {
    trendingTokens.value = [
      const TokenResult(id:'bitcoin', name:'Bitcoin', symbol:'BTC',
          price:67845.23, change24h:2.84, marketCap:1330000000000, rank:1, isWatchlisted:true),
      const TokenResult(id:'ethereum', name:'Ethereum', symbol:'ETH',
          price:3524.11, change24h:1.62, marketCap:423000000000, rank:2, isWatchlisted:true),
      const TokenResult(id:'solana', name:'Solana', symbol:'SOL',
          price:178.54, change24h:-1.23, marketCap:81000000000, rank:5, isWatchlisted:false),
      const TokenResult(id:'sui', name:'Sui', symbol:'SUI',
          price:4.23, change24h:8.45, marketCap:11500000000, rank:22, isWatchlisted:false),
      const TokenResult(id:'avalanche', name:'Avalanche', symbol:'AVAX',
          price:38.14, change24h:3.21, marketCap:15800000000, rank:12, isWatchlisted:false),
      const TokenResult(id:'arbitrum', name:'Arbitrum', symbol:'ARB',
          price:1.24, change24h:-0.88, marketCap:4200000000, rank:30, isWatchlisted:false),
      const TokenResult(id:'optimism', name:'Optimism', symbol:'OP',
          price:2.86, change24h:5.67, marketCap:3100000000, rank:35, isWatchlisted:false),
      const TokenResult(id:'chainlink', name:'Chainlink', symbol:'LINK',
          price:18.92, change24h:2.14, marketCap:11200000000, rank:13, isWatchlisted:false),
    ];
    // ignore: invalid_use_of_protected_member
    watchlistedIds.value = {'bitcoin', 'ethereum'};
  }

  void onSearchChanged(String q) async {
    query.value = q;
    if (q.isEmpty) {
      isSearching.value = false;
      searchResults.clear();
      return;
    }
    isSearching.value = true;
    await Future.delayed(const Duration(milliseconds: 400));
    final lq = q.toLowerCase();
    searchResults.value = trendingTokens
        .where((t) =>
            t.name.toLowerCase().contains(lq) ||
            t.symbol.toLowerCase().contains(lq))
        .toList();
    isSearching.value = false;
  }

  void toggleWatchlist(String id) {
    if (watchlistedIds.contains(id)) {
      watchlistedIds.remove(id);
      Get.snackbar('Removed', 'Token removed from watchlist',
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 1));
    } else {
      watchlistedIds.add(id);
      Get.snackbar('Added ✅', 'Token added to your watchlist',
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 1));
    }
  }

  bool isInWatchlist(String id) => watchlistedIds.contains(id);

  List<TokenResult> get displayList =>
      query.value.isEmpty ? trendingTokens : searchResults;

  String fmt(double v) {
    if (v >= 1000) return '\$${v.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
    if (v >= 1) return '\$${v.toStringAsFixed(2)}';
    return '\$${v.toStringAsFixed(4)}';
  }

  String fmtCap(double c) {
    if (c >= 1e12) return '\$${(c/1e12).toStringAsFixed(2)}T';
    if (c >= 1e9) return '\$${(c/1e9).toStringAsFixed(1)}B';
    return '\$${(c/1e6).toStringAsFixed(1)}M';
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}