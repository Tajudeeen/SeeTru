import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PortfolioHolding {
  final String id;
  final String name;
  final String symbol;
  final double amount;
  final double avgBuyPrice;
  final double currentPrice;
  final double allocation; // percentage
  final Color color;
  final List<double> sparkline;

  const PortfolioHolding({
    required this.id,
    required this.name,
    required this.symbol,
    required this.amount,
    required this.avgBuyPrice,
    required this.currentPrice,
    required this.allocation,
    required this.color,
    required this.sparkline,
  });

  double get totalValue => amount * currentPrice;
  double get totalCost => amount * avgBuyPrice;
  double get pnl => totalValue - totalCost;
  double get pnlPercentage => ((currentPrice - avgBuyPrice) / avgBuyPrice) * 100;
  bool get isProfit => pnl >= 0;
}

class ChartRangeOption {
  final String label;
  final int index;
  const ChartRangeOption({required this.label, required this.index});
}

class PortfolioController extends GetxController {
  // ── State ──────────────────────────────────────────────────────────
  final RxBool isLoading = true.obs;
  final RxInt selectedRangeIndex = 2.obs; // 1D, 1W, 1M, 3M, 1Y, ALL
  final RxBool showBalanceValue = true.obs;
  final RxString activeTab = 'Holdings'.obs;

  // ── Data ───────────────────────────────────────────────────────────
  final RxList<PortfolioHolding> holdings = <PortfolioHolding>[].obs;
  final RxDouble totalValue = 24857.43.obs;
  final RxDouble totalCost = 19200.00.obs;
  final RxDouble totalPnl = 5657.43.obs;
  final RxDouble totalPnlPercent = 29.47.obs;
  final RxList<double> portfolioChart = <double>[].obs;

  final List<ChartRangeOption> rangeOptions = const [
    ChartRangeOption(label: '1D', index: 0),
    ChartRangeOption(label: '1W', index: 1),
    ChartRangeOption(label: '1M', index: 2),
    ChartRangeOption(label: '3M', index: 3),
    ChartRangeOption(label: '1Y', index: 4),
    ChartRangeOption(label: 'ALL', index: 5),
  ].obs;

  final List<String> tabs = ['Holdings', 'Performance', 'Transactions'].obs;

  @override
  void onReady() {
    super.onReady();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));
    _populateMockData();
    isLoading.value = false;
  }

  void _populateMockData() {
    holdings.value = [
      PortfolioHolding(
        id: 'bitcoin',
        name: 'Bitcoin',
        symbol: 'BTC',
        amount: 0.2481,
        avgBuyPrice: 52000,
        currentPrice: 67845.23,
        allocation: 67.8,
        color: const Color(0xFFF7931A),
        sparkline: [64200, 65100, 64800, 66200, 65900, 67100, 67845],
      ),
      PortfolioHolding(
        id: 'ethereum',
        name: 'Ethereum',
        symbol: 'ETH',
        amount: 2.14,
        avgBuyPrice: 2800,
        currentPrice: 3524.11,
        allocation: 30.3,
        color: const Color(0xFF627EEA),
        sparkline: [3380, 3420, 3390, 3460, 3510, 3490, 3524],
      ),
      PortfolioHolding(
        id: 'solana',
        name: 'Solana',
        symbol: 'SOL',
        amount: 8.5,
        avgBuyPrice: 165,
        currentPrice: 178.54,
        allocation: 6.1,
        color: const Color(0xFF9945FF),
        sparkline: [182, 180, 183, 179, 176, 178, 178.54],
      ),
      PortfolioHolding(
        id: 'sui',
        name: 'Sui',
        symbol: 'SUI',
        amount: 450,
        avgBuyPrice: 2.10,
        currentPrice: 4.23,
        allocation: 7.7,
        color: const Color(0xFF6FBCF0),
        sparkline: [3.8, 3.9, 4.0, 4.1, 4.15, 4.20, 4.23],
      ),
    ];

    portfolioChart.value = _generateChartData(selectedRangeIndex.value);
  }

  List<double> _generateChartData(int rangeIndex) {
    const base = [
      18200.0, 18800.0, 19200.0, 18900.0, 19800.0, 20400.0, 20100.0,
      21000.0, 21500.0, 20800.0, 21900.0, 22400.0, 22100.0, 23000.0,
      23500.0, 23200.0, 22800.0, 23800.0, 24200.0, 24000.0, 24600.0,
      24300.0, 24800.0, 25100.0, 24857.0,
    ];
    return base;
  }

  void setRange(int index) {
    selectedRangeIndex.value = index;
    portfolioChart.value = _generateChartData(index);
  }

  void setActiveTab(String tab) => activeTab.value = tab;
  void toggleBalanceVisibility() =>
      showBalanceValue.value = !showBalanceValue.value;

  String formatValue(double v) {
    if (v >= 1000) {
      return '\$${v.toStringAsFixed(2).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          )}';
    }
    return '\$${v.toStringAsFixed(2)}';
  }

  String formatPrice(double price) {
    if (price >= 1000) {
      return '\$${price.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]},',
          )}';
    }
    if (price >= 1) return '\$${price.toStringAsFixed(2)}';
    return '\$${price.toStringAsFixed(4)}';
  }
}