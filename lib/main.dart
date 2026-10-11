import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'data/local_store.dart';
import 'data/market_repository.dart';
import 'data/account_service.dart';
import 'workspace_controller.dart';
import 'ui/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await GetStorage.init('seetru_v2');
    final store = DeviceStore(GetStorage('seetru_v2'));
    Get.put(
      WorkspaceController(
        store,
        MarketRepository(
          store,
          apiBase: const String.fromEnvironment('SEETRU_API_BASE'),
        ),
      ),
      permanent: true,
    );
    Get.put(await AccountService().initialize(), permanent: true);
    runApp(const SeeTruApp());
  } catch (_) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('SeeTru could not open local storage.'),
                const SizedBox(height: 16),
                FilledButton(onPressed: main, child: const Text('Try again')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
