import 'package:flutter/material.dart';
import 'package:seetru/data/models/gecko-model.dart';

class CryptoAsset {
  final String id;
  final String name;
  final String symbol;
  final String logoUrl;
  final double price;
  final double change24h;
  final double marketCap;
  final double volume24h;
  final List<double> sparkline;

  const CryptoAsset({
    required this.id,
    required this.name,
    required this.symbol,
    required this.logoUrl,
    required this.price,
    required this.change24h,
    required this.marketCap,
    required this.volume24h,
    required this.sparkline,
  });

  bool get isPositive => change24h >= 0;

  factory CryptoAsset.fromCoinGecko(CoinGeckoAsset c) => CryptoAsset(
        id: c.id,
        name: c.name,
        symbol: c.symbol,
        logoUrl: c.logoUrl,
        price: c.price,
        change24h: c.changePercent24h,
        marketCap: c.marketCap,
        volume24h: c.volume24h,
        sparkline: c.sparkline,
      );
}

class VCDeal {
  final String project;
  final String category;
  final double amount;
  final String currency;
  final List<String> investors;
  final String round;
  final DateTime date;

  const VCDeal({
    required this.project,
    required this.category,
    required this.amount,
    required this.currency,
    required this.investors,
    required this.round,
    required this.date,
  });
}

class MarketStat {
  final String label;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;

  const MarketStat({
    required this.label,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
  });
}