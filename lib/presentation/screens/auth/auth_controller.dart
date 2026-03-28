import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seetru/app/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';

enum AuthMode { signIn, signUp }

class AuthController extends GetxController {
  // ── Form ───────────────────────────────────────────────────────────
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();

  // ── State ──────────────────────────────────────────────────────────
  final Rx<AuthMode> authMode = AuthMode.signIn.obs;
  final RxBool isLoading = false.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool rememberMe = false.obs;
  final RxString errorMessage = ''.obs;

  // ── Animation ──────────────────────────────────────────────────────
  final RxDouble formOpacity = 0.0.obs;
  final RxDouble formOffset = 30.0.obs;

  @override
  void onReady() {
    super.onReady();
    _animateIn();
  }

  // ✅ Fix 1: Changed to Future<void> so errors surface properly
  Future<void> _animateIn() async {
    await Future.delayed(const Duration(milliseconds: 100));
    // ✅ Fix 6: Guard before updating observables after any delay
    if (!Get.isRegistered<AuthController>()) return;
    formOpacity.value = 1.0;
    formOffset.value = 0.0;
  }

  void switchMode(AuthMode mode) {
    if (authMode.value == mode) return;
    formOpacity.value = 0.0;
    formOffset.value = 20.0;
    errorMessage.value = '';
    Future.delayed(const Duration(milliseconds: 200), () {
      // ✅ Fix 2: Guard against controller being disposed during delay
      if (!Get.isRegistered<AuthController>()) return;
      authMode.value = mode;
      _animateIn();
    });
  }

  void togglePasswordVisibility() =>
      isPasswordVisible.value = !isPasswordVisible.value;

  void toggleConfirmPasswordVisibility() =>
      isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;

  // ── Submit ─────────────────────────────────────────────────────────
  Future<void> submitForm() async {
    // ✅ Fix 4: Safe null-aware form validation instead of force-unwrap
    if (!(formKey.currentState?.validate() ?? false)) return;
    errorMessage.value = '';
    isLoading.value = true;

    try {
      if (authMode.value == AuthMode.signIn) {
        await AuthService.to.signInWithEmail(
          email: emailController.text,
          password: passwordController.text,
        );
      } else {
        await AuthService.to.signUpWithEmail(
          name: nameController.text,
          email: emailController.text,
          password: passwordController.text,
        );
      }
      Get.offAllNamed(AppRoutes.main);
    } on AuthException catch (e) {
      // ✅ Fix 3: Catch typed AuthException explicitly
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred.';
    } finally {
      // ✅ Fix 6: Guard before touching observables after async gap
      if (Get.isRegistered<AuthController>()) {
        isLoading.value = false;
      }
    }
  }

  // ── Google ─────────────────────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    errorMessage.value = '';
    isLoading.value = true;
    try {
      final result = await AuthService.to.signInWithGoogle();
      if (result != null) {
        Get.offAllNamed(AppRoutes.main);
      }
    } on AuthException catch (e) {
      // ✅ Fix 3: Catch typed AuthException explicitly
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred.';
    } finally {
      // ✅ Fix 6: Guard before touching observables after async gap
      if (Get.isRegistered<AuthController>()) {
        isLoading.value = false;
      }
    }
  }

  // ── Apple ──────────────────────────────────────────────────────────
  Future<void> signInWithApple() async {
    errorMessage.value = '';
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      if (Get.isRegistered<AuthController>()) {
        errorMessage.value = 'Apple Sign In coming soon.';
      }
    } finally {
      if (Get.isRegistered<AuthController>()) {
        isLoading.value = false;
      }
    }
  }

  // ── Forgot Password ────────────────────────────────────────────────
  Future<void> forgotPassword() async {
    if (emailController.text.isEmpty) {
      Get.snackbar(
        'Email required',
        'Enter your email address first',
        snackPosition: SnackPosition.TOP,
        // ✅ Fix 5: withOpacity() replaced with Color.fromRGBO()
        backgroundColor: const Color.fromRGBO(255, 77, 77, 0.1),
        colorText: const Color(0xFFFF4D4D),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }
    try {
      await AuthService.to.sendPasswordReset(emailController.text);
      Get.snackbar(
        '✅ Reset email sent',
        'Check your inbox for password reset instructions.',
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
      );
    } on AuthException catch (e) {
      // ✅ Fix 3: Catch typed AuthException explicitly
      errorMessage.value = e.message;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred.';
    }
  }

  // ── Validators ─────────────────────────────────────────────────────
  String? validateEmail(String? val) {
    if (val == null || val.isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(val)) return 'Enter a valid email address';
    return null;
  }

  String? validatePassword(String? val) {
    if (val == null || val.isEmpty) return 'Password is required';
    if (val.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? validateConfirmPassword(String? val) {
    if (val == null || val.isEmpty) return 'Please confirm your password';
    if (val != passwordController.text) return 'Passwords do not match';
    return null;
  }

  String? validateName(String? val) {
    if (val == null || val.isEmpty) return 'Name is required';
    if (val.length < 2) return 'Name is too short';
    return null;
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    super.onClose();
  }
}