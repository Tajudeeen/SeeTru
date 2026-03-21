import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'secure_storage_service.dart';
import 'auth_service.dart';
import '../../app/routes/app_routes.dart';

class SessionManager extends GetxService {
  static SessionManager get to => Get.find();

  final _box = GetStorage();

  // Session timeout — 24 hours of inactivity
  static const Duration _sessionTimeout = Duration(hours: 24);
  static const int _maxFailedAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 15);

  static const String _lastActiveKey   = 'last_active_time';
  static const String _failedAttempts  = 'failed_login_attempts';
  static const String _lockoutUntilKey = 'lockout_until';
  // ignore: unused_field
  static const String _deviceIdKey     = 'device_id';

  // ── Record activity ────────────────────────────────────────────────
  void recordActivity() {
    _box.write(_lastActiveKey, DateTime.now().toIso8601String());
  }

  // ── Check if session is still valid ───────────────────────────────
  bool isSessionValid() {
    final lastActiveStr = _box.read<String>(_lastActiveKey);
    if (lastActiveStr == null) return false;

    final lastActive = DateTime.tryParse(lastActiveStr);
    if (lastActive == null) return false;

    return DateTime.now().difference(lastActive) < _sessionTimeout;
  }

  // ── Failed login attempt tracking ─────────────────────────────────
  void recordFailedAttempt() {
    final attempts = _box.read<int>(_failedAttempts) ?? 0;
    final newAttempts = attempts + 1;
    _box.write(_failedAttempts, newAttempts);

    if (newAttempts >= _maxFailedAttempts) {
      _lockAccount();
    }
  }

  void recordSuccessfulLogin() {
    _box.write(_failedAttempts, 0);
    _box.remove(_lockoutUntilKey);
    recordActivity();
  }

  void _lockAccount() {
    final lockUntil =
        DateTime.now().add(_lockoutDuration).toIso8601String();
    _box.write(_lockoutUntilKey, lockUntil);

    Get.snackbar(
      '🔒 Account Temporarily Locked',
      'Too many failed attempts. Try again in 15 minutes.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  // ── Check if account is locked out ────────────────────────────────
  bool isLockedOut() {
    final lockUntilStr = _box.read<String>(_lockoutUntilKey);
    if (lockUntilStr == null) return false;

    final lockUntil = DateTime.tryParse(lockUntilStr);
    if (lockUntil == null) return false;

    if (DateTime.now().isBefore(lockUntil)) return true;

    // Lockout expired — clear it
    _box.remove(_lockoutUntilKey);
    _box.write(_failedAttempts, 0);
    return false;
  }

  // ── Get remaining lockout time ─────────────────────────────────────
  Duration? getRemainingLockout() {
    final lockUntilStr = _box.read<String>(_lockoutUntilKey);
    if (lockUntilStr == null) return null;
    final lockUntil = DateTime.tryParse(lockUntilStr);
    if (lockUntil == null) return null;
    final remaining = lockUntil.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  int get failedAttempts => _box.read<int>(_failedAttempts) ?? 0;
  int get remainingAttempts =>
      (_maxFailedAttempts - failedAttempts).clamp(0, _maxFailedAttempts);

  // ── Force sign out on session expiry ──────────────────────────────
  Future<void> checkSessionExpiry() async {
    if (!isSessionValid()) {
      await _forceSignOut(reason: 'Your session has expired. Please sign in again.');
    }
  }

  Future<void> _forceSignOut({required String reason}) async {
    await AuthService.to.signOut();
    await SecureStorageService.to.clearTokens();

    Get.offAllNamed(AppRoutes.auth);

    Future.delayed(const Duration(milliseconds: 500), () {
      Get.snackbar(
        'Session Expired',
        reason,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    });
  }

  // ── Clear session ──────────────────────────────────────────────────
  void clearSession() {
    _box.remove(_lastActiveKey);
    _box.remove(_failedAttempts);
    _box.remove(_lockoutUntilKey);
  }
}