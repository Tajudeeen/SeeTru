class CoinGeckoAsset {
  final String id;
  final String name;
  final String symbol;
  final String logoUrl;
  final double price;
  final double change24h;
  final double changePercent24h;
  final double marketCap;
  final double volume24h;
  final int marketCapRank;
  final List<double> sparkline;
  final double high24h;
  final double low24h;
  final double ath;
  final double atl;
  final double circulatingSupply;

  const CoinGeckoAsset({
    required this.id,
    required this.name,
    required this.symbol,
    required this.logoUrl,
    required this.price,
    required this.change24h,
    required this.changePercent24h,
    required this.marketCap,
    required this.volume24h,
    required this.marketCapRank,
    required this.sparkline,
    required this.high24h,
    required this.low24h,
    required this.ath,
    required this.atl,
    required this.circulatingSupply,
  });

  bool get isPositive => changePercent24h >= 0;

  factory CoinGeckoAsset.fromJson(Map<String, dynamic> json) {
    final sparklineData = json['sparkline_in_7d']?['price'] as List?;
    final sparkline = sparklineData
            ?.map((e) => (e as num).toDouble())
            .toList()
            .cast<double>() ??
        <double>[];

    return CoinGeckoAsset(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      symbol: (json['symbol'] ?? '').toString().toUpperCase(),
      logoUrl: json['image'] ?? '',
      price: (json['current_price'] as num?)?.toDouble() ?? 0,
      change24h:
          (json['price_change_24h'] as num?)?.toDouble() ?? 0,
      changePercent24h:
          (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0,
      marketCap: (json['market_cap'] as num?)?.toDouble() ?? 0,
      volume24h: (json['total_volume'] as num?)?.toDouble() ?? 0,
      marketCapRank: (json['market_cap_rank'] as num?)?.toInt() ?? 0,
      sparkline: sparkline,
      high24h: (json['high_24h'] as num?)?.toDouble() ?? 0,
      low24h: (json['low_24h'] as num?)?.toDouble() ?? 0,
      ath: (json['ath'] as num?)?.toDouble() ?? 0,
      atl: (json['atl'] as num?)?.toDouble() ?? 0,
      circulatingSupply:
          (json['circulating_supply'] as num?)?.toDouble() ?? 0,
    );
  }
}

class GlobalMarketData {
  final double totalMarketCap;
  final double totalVolume24h;
  final double btcDominance;
  final double marketCapChangePercent24h;

  const GlobalMarketData({
    required this.totalMarketCap,
    required this.totalVolume24h,
    required this.btcDominance,
    required this.marketCapChangePercent24h,
  });

  factory GlobalMarketData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final mcapUsd = data['total_market_cap']?['usd'];
    final volUsd = data['total_volume']?['usd'];
    final btcDom = data['market_cap_percentage']?['btc'];

    return GlobalMarketData(
      totalMarketCap: (mcapUsd as num?)?.toDouble() ?? 0,
      totalVolume24h: (volUsd as num?)?.toDouble() ?? 0,
      btcDominance: (btcDom as num?)?.toDouble() ?? 0,
      marketCapChangePercent24h:
          (data['market_cap_change_percentage_24h_usd'] as num?)
                  ?.toDouble() ??
              0,
    );
  }
}