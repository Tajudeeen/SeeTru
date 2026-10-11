import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:seetru/ui/app.dart';
import 'package:seetru/data/account_service.dart';
import 'package:seetru/workspace_controller.dart';
import 'helpers.dart';

void main() {
  for (final size in [const Size(390, 844), const Size(1280, 900)]) {
    testWidgets('workspace flows render at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final store = MemoryStore();
      final c = WorkspaceController(store, FixtureRepository(store));
      Get.put(c, permanent: true);
      Get.put(AccountService(), permanent: true);
      addTearDown(() async {
        await Get.delete<WorkspaceController>(force: true);
        Get.reset();
      });
      try {
        await tester.pumpWidget(const SeeTruApp());
        await tester.pumpAndSettle();
        expect(find.text('Open my workspace'), findsOneWidget);
        await tester.ensureVisible(find.text('Open my workspace'));
        await tester.tap(find.text('Open my workspace'));
        await tester.pumpAndSettle();
        expect(find.text('The market, in focus'), findsOneWidget);
        await tester.ensureVisible(find.byTooltip('Add to watchlist').first);
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Add to watchlist').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Watchlist').last);
        await tester.pumpAndSettle();
        expect(find.text('Your watchlist'), findsOneWidget);
        await tester.tap(find.text('Portfolio').last);
        await tester.pumpAndSettle();
        expect(find.text('Start with your first trade'), findsOneWidget);
        await tester.tap(find.text('Research').last);
        await tester.pumpAndSettle();
        expect(find.text('Research with context'), findsOneWidget);
        expect(tester.takeException(), isNull);
        expect(store.data['workspace_v2']['watchlist'], ['bitcoin']);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await Get.delete<WorkspaceController>(force: true);
        Get.reset();
      }
    });
  }
  testWidgets('record trade through search persists ledger and valuation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1;
    final store = MemoryStore();
    final c = WorkspaceController(store, FixtureRepository(store));
    Get.put(c, permanent: true);
    Get.put(AccountService(), permanent: true);
    try {
      await c.change((w) => w.copy(onboarded: true));
      c.tab.value = 2;
      await tester.pumpWidget(const SeeTruApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Record trade'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'btc');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bitcoin'));
      await tester.pumpAndSettle();
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '2');
      await tester.enterText(fields.at(1), '80');
      await tester.enterText(fields.at(2), '4');
      await tester.ensureVisible(find.text('Save transaction'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save transaction'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      expect(c.workspace.value.trades.single.quantity, 2);
      expect(c.totalCost, 164);
      expect(c.portfolioValue, 200);
      expect(store.data['workspace_v2']['trades'].length, 1);
      expect(find.text('Start with your first trade'), findsNothing);
      expect(tester.takeException(), isNull);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await Get.delete<WorkspaceController>(force: true);
      Get.reset();
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    }
  });
}
