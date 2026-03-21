import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:seetru/core/services/applock_service.dart';
import 'package:seetru/core/services/biometric_service.dart';
import 'package:seetru/core/services/gecko_service.dart';
import 'package:seetru/core/services/secure_storage_service.dart';
import 'package:seetru/core/services/session_manager.dart';
import 'package:seetru/firebase_options.dart';
import 'core/services/auth_service.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  await GetStorage.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);


  await _initServices();
  runApp(const SeeTruApp());
}

Future<void> _initServices() async {
  await Get.putAsync<SecureStorageService>(() async => SecureStorageService());
  await Get.putAsync<SessionManager>(() async => SessionManager());
  await Get.putAsync<AuthService>(() async => AuthService());
  await Get.putAsync<BiometricService>(() async => BiometricService());
  await Get.putAsync<AppLockService>(() async => AppLockService());
  await Get.putAsync<CoinGeckoService>(() async => CoinGeckoService());
}
