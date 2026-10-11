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
      final store = MemoryStore(),
          c = WorkspaceController(
            MemoryStore(),
            FixtureRepository(MemoryStore()),
          );
      Get.put(c, permanent: true);
      Get.put(AccountService(), permanent: true);
      await tester.pumpWidget(const SeeTruApp());
      await tester.pumpAndSettle();
      expect(find.text('Open my workspace'), findsOneWidget);
      await tester.tap(find.text('Open my workspace'));
      await tester.pumpAndSettle();
      expect(find.text('The market, in focus'), findsOneWidget);
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
      expect(store.data, isEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
      await Get.delete<WorkspaceController>(force: true);
      Get.reset();
    });
  }
}
