import 'package:flutter_test/flutter_test.dart';
import 'package:seetru/workspace_controller.dart';
import 'package:seetru/domain/models.dart';
import 'helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MemoryStore store;
  late WorkspaceController c;
  setUp(() {
    store = MemoryStore();
    c = WorkspaceController(store, FixtureRepository(store));
    c.onInit();
  });
  tearDown(() => c.onClose());
  test('failed durable write leaves published workspace unchanged', () async {
    store.fail = true;
    await expectLater(c.change((w) => w.copy(name: 'New')), throwsStateError);
    expect(c.workspace.value.name, '');
    store.fail = false;
    await c.change((w) => w.copy(name: 'Saved'));
    expect(c.workspace.value.name, 'Saved');
  });
  test(
    'concurrent edits compose from the latest committed workspace',
    () async {
      await Future.wait([
        c.change((w) => w.copy(name: 'Ada')),
        c.change((w) => w.copy(dark: false)),
      ]);
      expect(c.workspace.value.name, 'Ada');
      expect(c.workspace.value.dark, false);
    },
  );
  test('missing quote makes portfolio total unavailable', () async {
    await c.addTrade(trade('buy', coin: 'unpriced'));
    await c.refreshMarket();
    expect(c.portfolioValue, isNull);
  });
  test('delete of supporting purchase is rejected', () async {
    await c.addTrade(trade('buy'));
    await c.addTrade(trade('sell', buy: false, day: 2));
    await expectLater(c.deleteTrade('buy'), throwsFormatException);
    expect(c.workspace.value.trades.length, 2);
  });
  test('restart restores saved preferences and ledger', () async {
    await c.addTrade(trade('buy'));
    await c.change((w) => w.copy(name: 'Ada'));
    final other = WorkspaceController(store, FixtureRepository(store));
    other.onInit();
    expect(other.workspace.value.trades.length, 1);
    expect(other.workspace.value.name, 'Ada');
    other.onClose();
  });
  test('restore validates before replacing workspace', () async {
    await expectLater(
      c.restore(Workspace(trades: [trade('bad', buy: false)])),
      throwsFormatException,
    );
    expect(c.workspace.value.trades, isEmpty);
  });
}
