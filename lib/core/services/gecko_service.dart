import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:seetru/core/errors/dio_error_handler.dart';
import 'package:seetru/data/models/gecko-model.dart';


// ─────────────────────────────────────────────────────────────────────────────
// Service
// ─────────────────────────────────────────────────────────────────────────────
class CoinGeckoService extends GetxService {
  static CoinGeckoService get to => Get.find();

  static const String _baseUrl = 'https://api.coingecko.com/api/v3';
  static const String _currency = 'usd';
  static const Duration _cacheExpiry = Duration(minutes: 2);

  late final Dio _dio;
  final _box = GetStorage();

  // Cache keys
  static const String _marketsCacheKey = 'cg_markets_cache';
  static const String _globalCacheKey = 'cg_global_cache';
  static const String _marketsCacheTimeKey = 'cg_markets_cache_time';
  static const String _globalCacheTimeKey = 'cg_global_cache_time';

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        // Add your API key here if you have a paid plan:
        // 'x-cg-demo-api-key': 'YOUR_API_KEY',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('🌐 CoinGecko: ${options.path}');
        handler.next(options);
      },
      onError: (error, handler) {
        debugPrint('❌ CoinGecko error: ${error.message}');
        handler.next(error);
      },
    ));
  }

  // ── Fetch top coins by market cap ──────────────────────────────────
  Future<List<CoinGeckoAsset>> getTopCoins({
    int perPage = 20,
    int page = 1,
    String? category,
    bool forceRefresh = false,
  }) async {
    // Check cache
    if (!forceRefresh && _isCacheValid(_marketsCacheTimeKey)) {
      final cached = _box.read<List>(_marketsCacheKey);
      if (cached != null) {
        return cached
            .map((e) => CoinGeckoAsset.fromJson(
                Map<String, dynamic>.from(e)))
            .toList();
      }
    }

    try {
      final response = await _dio.get(
        '/coins/markets',
        queryParameters: {
          'vs_currency': _currency,
          'order': 'market_cap_desc',
          'per_page': perPage,
          'page': page,
          'sparkline': true,
          'price_change_percentage': '24h',
          'category': ?category,
        },
      );

      final List<dynamic> data = response.data;
      final assets = data
          .map((e) => CoinGeckoAsset.fromJson(
              Map<String, dynamic>.from(e)))
          .toList();

      // Save to cache
      _box.write(_marketsCacheKey, data);
      _box.write(
          _marketsCacheTimeKey, DateTime.now().toIso8601String());

      return assets;
    } on DioException catch (e) {
      // Return cached data on error if available
      final cached = _box.read<List>(_marketsCacheKey);
      if (cached != null) {
        return cached
            .map((e) => CoinGeckoAsset.fromJson(
                Map<String, dynamic>.from(e)))
            .toList();
      }
      throw handleDioError(e);
    }
  }

  // ── Fetch specific coins by IDs ────────────────────────────────────
  Future<List<CoinGeckoAsset>> getCoinsByIds(
      List<String> ids) async {
    try {
      final response = await _dio.get(
        '/coins/markets',
        queryParameters: {
          'vs_currency': _currency,
          'ids': ids.join(','),
          'sparkline': true,
          'price_change_percentage': '24h',
        },
      );

      final List<dynamic> data = response.data;
      return data
          .map((e) => CoinGeckoAsset.fromJson(
              Map<String, dynamic>.from(e)))
          .toList();
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // ── Fetch global market data ───────────────────────────────────────
  Future<GlobalMarketData?> getGlobalData({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _isCacheValid(_globalCacheTimeKey)) {
      final cached = _box.read<Map>(_globalCacheKey);
      if (cached != null) {
        return GlobalMarketData.fromJson(
            Map<String, dynamic>.from(cached));
      }
    }

    try {
      final response = await _dio.get('/global');
      final data = Map<String, dynamic>.from(response.data);

      _box.write(_globalCacheKey, data);
      _box.write(
          _globalCacheTimeKey, DateTime.now().toIso8601String());

      return GlobalMarketData.fromJson(data);
    } on DioException catch (e) {
      final cached = _box.read<Map>(_globalCacheKey);
      if (cached != null) {
        return GlobalMarketData.fromJson(
            Map<String, dynamic>.from(cached));
      }
      throw handleDioError(e);
    }
  }

  // ── Fetch price chart data for a coin ─────────────────────────────
  Future<List<double>> getCoinChart({
    required String coinId,
    required int days,
  }) async {
    try {
      final response = await _dio.get(
        '/coins/$coinId/market_chart',
        queryParameters: {
          'vs_currency': _currency,
          'days': days,
          'interval': days <= 1 ? 'hourly' : 'daily',
        },
      );

      final List prices = response.data['prices'] ?? [];
      return prices
          .map((p) => (p[1] as num).toDouble())
          .toList();
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // ── Search coins ───────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> searchCoins(
      String query) async {
    if (query.isEmpty) return [];
    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {'query': query},
      );
      final List coins = response.data['coins'] ?? [];
      return coins
          .map((e) => Map<String, dynamic>.from(e))
          .take(10)
          .toList();
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // ── Trending coins ─────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getTrending() async {
    try {
      final response = await _dio.get('/search/trending');
      final List coins = response.data['coins'] ?? [];
      return coins
          .map((e) =>
              Map<String, dynamic>.from(e['item'] ?? {}))
          .toList();
    } on DioException catch (e) {
      throw handleDioError(e);
    }
  }

  // ── Cache helpers ──────────────────────────────────────────────────
  bool _isCacheValid(String timeKey) {
    final timeStr = _box.read<String>(timeKey);
    if (timeStr == null) return false;
    final cacheTime = DateTime.tryParse(timeStr);
    if (cacheTime == null) return false;
    return DateTime.now().difference(cacheTime) < _cacheExpiry;
  }

  void clearCache() {
    _box.remove(_marketsCacheKey);
    _box.remove(_globalCacheKey);
    _box.remove(_marketsCacheTimeKey);
    _box.remove(_globalCacheTimeKey);
  }
}