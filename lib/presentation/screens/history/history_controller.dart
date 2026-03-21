import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum TxType { buy, sell, swap, transfer, receive }

class Transaction {
  final String id;
  final TxType type;
  final String assetName;
  final String assetSymbol;
  final double amount;
  final double valueUsd;
  final double priceAtTime;
  final String? toAsset;
  final double? toAmount;
  final DateTime timestamp;
  final String status;
  final String txHash;
  final String network;

  const Transaction({
    required this.id,
    required this.type,
    required this.assetName,
    required this.assetSymbol,
    required this.amount,
    required this.valueUsd,
    required this.priceAtTime,
    this.toAsset,
    this.toAmount,
    required this.timestamp,
    required this.status,
    required this.txHash,
    required this.network,
  });

  bool get isCredit => type == TxType.sell || type == TxType.receive;
}

class MonthlySummary {
  final String month;
  final double totalBought;
  final double totalSold;
  final double netPnl;
  final int txCount;

  const MonthlySummary({
    required this.month,
    required this.totalBought,
    required this.totalSold,
    required this.netPnl,
    required this.txCount,
  });
}

class HistoryController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxString activeFilter = 'All'.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isSearching = false.obs;
  final searchController = TextEditingController();

  final RxList<Transaction> allTransactions = <Transaction>[].obs;
  final RxList<Transaction> filteredTransactions = <Transaction>[].obs;
  final RxList<MonthlySummary> monthlySummaries = <MonthlySummary>[].obs;

  final RxDouble totalBought = 0.0.obs;
  final RxDouble totalSold = 0.0.obs;
  final RxDouble totalFees = 0.0.obs;
  final RxInt totalTxCount = 0.obs;

  final List<String> filters = ['All', 'Buy', 'Sell', 'Swap', 'Transfer'].obs;

  @override
  void onReady() {
    super.onReady();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 700));
    _populate();
    isLoading.value = false;
  }

  void _populate() {
    allTransactions.value = [
      Transaction(id:'1', type:TxType.buy, assetName:'Bitcoin', assetSymbol:'BTC',
          amount:0.05, valueUsd:3392.26, priceAtTime:67845.23,
          timestamp:DateTime.now().subtract(const Duration(hours:2)),
          status:'completed', txHash:'0x3a4f...9b2e', network:'Bitcoin'),
      Transaction(id:'2', type:TxType.sell, assetName:'Solana', assetSymbol:'SOL',
          amount:2.0, valueUsd:357.08, priceAtTime:178.54,
          timestamp:DateTime.now().subtract(const Duration(hours:5)),
          status:'completed', txHash:'0x8c1d...4f7a', network:'Solana'),
      Transaction(id:'3', type:TxType.swap, assetName:'Ethereum', assetSymbol:'ETH',
          amount:0.5, valueUsd:1762.06, priceAtTime:3524.11,
          toAsset:'SUI', toAmount:416.7,
          timestamp:DateTime.now().subtract(const Duration(days:1)),
          status:'completed', txHash:'0x5e9b...1c3d', network:'Ethereum'),
      Transaction(id:'4', type:TxType.buy, assetName:'Sui', assetSymbol:'SUI',
          amount:200.0, valueUsd:846.0, priceAtTime:4.23,
          timestamp:DateTime.now().subtract(const Duration(days:2)),
          status:'completed', txHash:'0x2a7c...8e5f', network:'Sui'),
      Transaction(id:'5', type:TxType.receive, assetName:'Bitcoin', assetSymbol:'BTC',
          amount:0.01, valueUsd:678.45, priceAtTime:67845.0,
          timestamp:DateTime.now().subtract(const Duration(days:3)),
          status:'completed', txHash:'0x9f3e...2b1a', network:'Bitcoin'),
      Transaction(id:'6', type:TxType.buy, assetName:'Ethereum', assetSymbol:'ETH',
          amount:0.25, valueUsd:881.03, priceAtTime:3524.11,
          timestamp:DateTime.now().subtract(const Duration(days:4)),
          status:'completed', txHash:'0x1b8d...6c4e', network:'Ethereum'),
      Transaction(id:'7', type:TxType.transfer, assetName:'USDC', assetSymbol:'USDC',
          amount:500.0, valueUsd:500.0, priceAtTime:1.0,
          timestamp:DateTime.now().subtract(const Duration(days:5)),
          status:'completed', txHash:'0x6d2a...9f7b', network:'Ethereum'),
      Transaction(id:'8', type:TxType.buy, assetName:'Solana', assetSymbol:'SOL',
          amount:5.0, valueUsd:892.7, priceAtTime:178.54,
          timestamp:DateTime.now().subtract(const Duration(days:7)),
          status:'pending', txHash:'0x4e5c...3a8d', network:'Solana'),
    ];
    filteredTransactions.value = allTransactions;
    monthlySummaries.value = [
      const MonthlySummary(month:'March 2026', totalBought:5112.99,
          totalSold:357.08, netPnl:1843.22, txCount:8),
      const MonthlySummary(month:'February 2026', totalBought:3200.0,
          totalSold:1400.0, netPnl:920.40, txCount:5),
    ];
    totalBought.value = allTransactions.where((t) => t.type == TxType.buy)
        .fold(0, (s, t) => s + t.valueUsd);
    totalSold.value = allTransactions.where((t) => t.type == TxType.sell)
        .fold(0, (s, t) => s + t.valueUsd);
    totalTxCount.value = allTransactions.length;
    totalFees.value = 24.18;
  }

  void setFilter(String f) { activeFilter.value = f; _apply(); }

  void onSearchChanged(String q) { searchQuery.value = q; _apply(); }

  void _apply() {
    var list = allTransactions.toList();
    if (activeFilter.value != 'All') {
      const m = {'Buy':TxType.buy,'Sell':TxType.sell,'Swap':TxType.swap,'Transfer':TxType.transfer};
      final t = m[activeFilter.value];
      if (t != null) list = list.where((tx) => tx.type == t).toList();
    }
    if (searchQuery.value.isNotEmpty) {
      final q = searchQuery.value.toLowerCase();
      list = list.where((tx) =>
          tx.assetName.toLowerCase().contains(q) ||
          tx.assetSymbol.toLowerCase().contains(q)).toList();
    }
    filteredTransactions.value = list;
  }

  void toggleSearch() => isSearching.value = !isSearching.value;

  String fmt(double v) => '\$${v.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';

  String timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    const mo = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${mo[dt.month-1]} ${dt.day}';
  }

  String dateLabel(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inDays == 0) return 'Today';
    if (d.inDays == 1) return 'Yesterday';
    const mo = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${mo[dt.month-1]} ${dt.day}, ${dt.year}';
  }

  Map<String, List<Transaction>> get grouped {
    final map = <String, List<Transaction>>{};
    for (final tx in filteredTransactions) {
      map.putIfAbsent(dateLabel(tx.timestamp), () => []).add(tx);
    }
    return map;
  }

  Color txColor(TxType t) {
    switch(t){
      case TxType.buy: return const Color(0xFF00C48C);
      case TxType.sell: return const Color(0xFFFF6B6B);
      case TxType.swap: return const Color(0xFF4C6FFF);
      case TxType.transfer: return const Color(0xFFFFAA38);
      case TxType.receive: return const Color(0xFF00C6CF);
    }
  }

  IconData txIcon(TxType t) {
    switch(t){
      case TxType.buy: return Icons.add_circle_outline_rounded;
      case TxType.sell: return Icons.remove_circle_outline_rounded;
      case TxType.swap: return Icons.swap_horiz_rounded;
      case TxType.transfer: return Icons.send_outlined;
      case TxType.receive: return Icons.call_received_rounded;
    }
  }

  String txLabel(TxType t) {
    switch(t){
      case TxType.buy: return 'Bought';
      case TxType.sell: return 'Sold';
      case TxType.swap: return 'Swapped';
      case TxType.transfer: return 'Sent';
      case TxType.receive: return 'Received';
    }
  }

  @override
  void onClose() { searchController.dispose(); super.onClose(); }
}