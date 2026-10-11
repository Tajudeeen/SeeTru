import 'package:flutter_test/flutter_test.dart';
import 'package:seetru/domain/models.dart';
import 'helpers.dart';

void main() {
  test('average cost ledger includes fees and realizes sale net of fee', () {
    final p = calculatePositions([
      trade('1', qty: 2, fee: 10),
      trade('2', buy: false, qty: 1, price: 150, fee: 5, day: 2),
    ])['bitcoin']!;
    expect(p.quantity, 1);
    expect(p.cost, 105);
    expect(p.realized, 40);
  });
  test('chronology blocks selling before purchase and overselling', () {
    expect(
      () =>
          calculatePositions([trade('buy', day: 2), trade('sell', buy: false)]),
      throwsFormatException,
    );
    expect(
      () => calculatePositions([
        trade('buy'),
        trade('sell', buy: false, qty: 2, day: 2),
      ]),
      throwsFormatException,
    );
  });
  test('fully sold position has zero cost, realized survives', () {
    final p = calculatePositions([
      trade('buy'),
      trade('sell', buy: false, price: 120, day: 2),
    ])['bitcoin']!;
    expect(p.quantity, 0);
    expect(p.cost, 0);
    expect(p.realized, 20);
  });
  test('invalid numbers and duplicate IDs are rejected', () {
    expect(() => trade('x', qty: double.nan), throwsFormatException);
    expect(
      () => calculatePositions([trade('x'), trade('x')]),
      throwsFormatException,
    );
  });
  test('missing provider prices stay nullable', () {
    final c = Coin.fromJson({
      'id': 'bitcoin',
      'name': 'Bitcoin',
      'symbol': 'btc',
    });
    expect(c.price, isNull);
    expect(c.change, isNull);
    expect(c.freshAt(DateTime.now()), false);
  });
  test('alerts require matching fresh identity and trigger once', () {
    final now = DateTime.utc(2026, 10, 1);
    final a = PriceAlert(
      id: 'a',
      coinId: 'bitcoin',
      symbol: 'btc',
      target: 100,
      above: true,
    );
    final coin = Coin(
      id: 'bitcoin',
      name: 'Bitcoin',
      symbol: 'btc',
      price: 100,
      updatedAt: now,
    );
    expect(a.matches(coin, now), true);
    expect(a.copy(triggeredAt: now).matches(coin, now), false);
    expect(a.matches(coin, now.add(const Duration(minutes: 11))), false);
  });
  test('backup round trip preserves ledger and rejects invalid data', () {
    final w = Workspace(
      trades: [trade('buy')],
      watchlist: ['bitcoin'],
      onboarded: true,
    );
    expect(Workspace.parse(w.export()).trades.single.price, 100);
    expect(() => Workspace.parse('{"version":1}'), throwsFormatException);
    expect(
      () => Workspace.parse(
        Workspace(trades: [trade('sale', buy: false)]).export(),
      ),
      throwsFormatException,
    );
  });
}
