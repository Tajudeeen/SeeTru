import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'biometric_service.dart';
import 'secure_storage_service.dart';

class AppLockService extends GetxService {
  static AppLockService get to => Get.find();

  final RxBool isLocked = false.obs;
  final RxBool isAuthenticating = false.obs;

  // How long before app locks after going to background (seconds)
  static const int _lockTimeoutSeconds = 30;

  DateTime? _backgroundTime;

  // ── Called when app goes to background ────────────────────────────
  void onAppBackground() {
    _backgroundTime = DateTime.now();
  }

  // ── Called when app returns to foreground ─────────────────────────
  Future<void> onAppForeground() async {
    if (_backgroundTime == null) return;
    final biometricEnabled =
        await SecureStorageService.to.isBiometricEnabled();
    if (!biometricEnabled) return;

    final elapsed =
        DateTime.now().difference(_backgroundTime!).inSeconds;

    if (elapsed >= _lockTimeoutSeconds) {
      await lockApp();
    }
  }

  // ── Lock ───────────────────────────────────────────────────────────
  Future<void> lockApp() async {
    isLocked.value = true;
    await _showLockScreen();
  }

  // ── Show lock screen overlay ───────────────────────────────────────
  Future<void> _showLockScreen() async {
    isAuthenticating.value = true;

    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // can't dismiss by back button
        child: _AppLockScreen(
          onAuthenticated: () {
            isLocked.value = false;
            isAuthenticating.value = false;
            Get.back();
          },
        ),
      ),
      barrierDismissible: false,
    );
  }

  // ── Quick auth check (for sensitive screens) ───────────────────────
  Future<bool> requireAuth({
    String reason = 'Authenticate to continue',
  }) async {
    final biometricEnabled =
        await SecureStorageService.to.isBiometricEnabled();
    if (!biometricEnabled) return true;

    return BiometricService.to.authenticate(reason: reason);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Lock Screen UI
// ─────────────────────────────────────────────────────────────────────────────
class _AppLockScreen extends StatelessWidget {
  final VoidCallback onAuthenticated;
  const _AppLockScreen({required this.onAuthenticated});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1136),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4C6FFF), Color(0xFF00C6CF)],
                  ),
                ),
                child: const Icon(
                  Icons.remove_red_eye_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'SeeTru is Locked',
                style: TextStyle(
                  fontFamily: 'ClashDisplay',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Authenticate to continue',
                style: TextStyle(
                  fontFamily: 'Satoshi',
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 48),

              // Biometric button
              GestureDetector(
                onTap: () async {
                  final success = await BiometricService.to.authenticate(
                    reason: 'Unlock SeeTru',
                  );
                  if (success) onAuthenticated();
                },
                child: Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4C6FFF), Color(0xFF00C6CF)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4C6FFF).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.fingerprint_rounded,
                          color: Colors.white, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'Unlock with ${BiometricService.to.biometricLabel}',
                        style: const TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}