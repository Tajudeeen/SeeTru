import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:get/get.dart';
import 'secure_storage_service.dart';

class BiometricService extends GetxService {
  static BiometricService get to => Get.find();

  final _auth = LocalAuthentication();

  final RxBool isAvailable = false.obs;
  final RxBool isEnabled = false.obs;
  final RxList<BiometricType> availableTypes = <BiometricType>[].obs;

  @override
  void onInit() {
    super.onInit();
    _checkAvailability();
    _loadEnabledState();
  }

  Future<void> _checkAvailability() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final supported = await _auth.isDeviceSupported();
      isAvailable.value = canCheck && supported;
      if (isAvailable.value) {
        availableTypes.value = await _auth.getAvailableBiometrics();
      }
    } catch (_) {
      isAvailable.value = false;
    }
  }

  Future<void> _loadEnabledState() async {
    isEnabled.value =
        await SecureStorageService.to.isBiometricEnabled();
  }

  // ── Authenticate ───────────────────────────────────────────────────
  Future<bool> authenticate({
    String reason = 'Authenticate to access SeeTru',
  }) async {
    if (!isAvailable.value) return false;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // allow PIN fallback
        ),
      );
    } catch (_) {
      return false;
    }
  }

  // ── Enable biometric ───────────────────────────────────────────────
  Future<bool> enableBiometric() async {
    if (!isAvailable.value) {
      Get.snackbar(
        'Not Available',
        'Biometric authentication is not supported on this device.',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return false;
    }
    final confirmed = await authenticate(
      reason: 'Confirm your identity to enable biometric login',
    );
    if (confirmed) {
      isEnabled.value = true;
      await SecureStorageService.to.setBiometricEnabled(true);
    }
    return confirmed;
  }

  // ── Disable biometric ──────────────────────────────────────────────
  Future<void> disableBiometric() async {
    isEnabled.value = false;
    await SecureStorageService.to.setBiometricEnabled(false);
  }

  String get biometricLabel {
    if (availableTypes.contains(BiometricType.face)) return 'Face ID';
    if (availableTypes.contains(BiometricType.fingerprint)) {
      return 'Fingerprint';
    }
    return 'Biometric';
  }
}