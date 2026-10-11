import 'package:seetru/data/local_store.dart';
import 'package:seetru/data/market_repository.dart';
import 'package:seetru/domain/models.dart';

class MemoryStore implements KeyValueStore {
  final data = <String, dynamic>{};
  bool fail = false;
  @override
  dynamic read(String key) => data[key];
  @override
  Future<void> write(String key, dynamic value) async {
    if (fail) throw StateError('Write failed');
    data[key] = value;
  }
}

class FixtureRepository extends MarketRepository {
  FixtureRepository(super.store);
  @override
  Future<MarketSnapshot> markets({
    List<String> ids = const [],
    bool force = false,
  }) async => MarketSnapshot([
    Coin(
      id: 'bitcoin',
      name: 'Bitcoin',
      symbol: 'btc',
      price: 100,
      change: 2,
      updatedAt: DateTime.now().toUtc(),
    ),
  ], DateTime.now().toUtc());
  @override
  Future<List<Coin>> search(String query) async => [
    Coin(id: 'bitcoin', name: 'Bitcoin', symbol: 'btc'),
  ];
  @override
  Future<List<PricePoint>> chart(String id, int days) async => [
    PricePoint(DateTime.utc(2026), 100),
    PricePoint(DateTime.utc(2026, 1, 2), 110),
  ];
  @override
  Future<Map<String, dynamic>> global() async => {
    'total_market_cap': {'usd': 10000},
    'total_volume': {'usd': 2000},
    'market_cap_percentage': {'btc': 50},
  };
  @override
  Future<Map<String, dynamic>> research() async => {
    'items': [],
    'providers': {'Dune': 'not_configured'},
  };
}

Trade trade(
  String id, {
  bool buy = true,
  double qty = 1,
  double price = 100,
  double fee = 0,
  int day = 1,
  String coin = 'bitcoin',
}) => Trade(
  id: id,
  coinId: coin,
  name: coin,
  symbol: 'btc',
  buy: buy,
  quantity: qty,
  price: price,
  fee: fee,
  time: DateTime.utc(2026, 1, day),
);
