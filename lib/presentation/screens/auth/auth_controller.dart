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

  void _animateIn() async {
    await Future.delayed(const Duration(milliseconds: 100));
    formOpacity.value = 1.0;
    formOffset.value = 0.0;
  }

  void switchMode(AuthMode mode) {
    if (authMode.value == mode) return;
    formOpacity.value = 0.0;
    formOffset.value = 20.0;
    errorMessage.value = '';
    Future.delayed(const Duration(milliseconds: 200), () {
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
    if (!formKey.currentState!.validate()) return;
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
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
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
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ── Apple ──────────────────────────────────────────────────────────
  Future<void> signInWithApple() async {
    errorMessage.value = '';
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 800));
      errorMessage.value = 'Apple Sign In coming soon.';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Forgot Password ────────────────────────────────────────────────
  Future<void> forgotPassword() async {
    if (emailController.text.isEmpty) {
      Get.snackbar(
        'Email required',
        'Enter your email address first',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFFF4D4D).withOpacity(0.1),
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
    } catch (e) {
      errorMessage.value = e.toString();
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