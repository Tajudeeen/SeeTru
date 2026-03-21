import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seetru/core/const/app_color.dart';
import 'package:seetru/core/const/app_style.dart';
import '../../../core/const/app_sizes.dart';
import 'auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _TopHeroSection(size: size),
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.only(bottom: bottom),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.28),
                  _FormCard(controller: controller),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopHeroSection extends StatelessWidget {
  final Size size;
  const _TopHeroSection({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: size.height * 0.38,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0B1136), Color(0xFF1A2B6D), Color(0xFF243CA0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(0.12),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.teal.withOpacity(0.10),
              ),
            ),
          ),
          CustomPaint(
            size: Size(size.width, size.height * 0.38),
            painter: _SubtleGridPainter(),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.screenPaddingH,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [AppColors.accent, AppColors.teal],
                          ),
                        ),
                        child: const Icon(
                          Icons.remove_red_eye_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'SeeTru',
                        style: TextStyle(
                          fontFamily: 'ClashDisplay',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Crypto intelligence\nyou can trust.',
                    style: AppTextStyles.displayMedium.copyWith(
                      color: Colors.white,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Live prices · VC data · Social alpha',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  final AuthController controller;
  const _FormCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AnimatedOpacity(
        opacity: controller.formOpacity.value,
        duration: const Duration(milliseconds: 500),
        child: AnimatedSlide(
          offset: Offset(0, controller.formOffset.value / 300),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: AppSizes.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowDeep,
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: _AuthTabToggle(controller: controller),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.xl,
                    vertical: AppSizes.sm,
                  ),
                  child: Form(
                    key: controller.formKey,
                    child: Obx(
                      () => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: controller.authMode.value == AuthMode.signIn
                            ? _SignInFields(controller: controller)
                            : _SignUpFields(controller: controller),
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => controller.errorMessage.value.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSizes.xl,
                            0,
                            AppSizes.xl,
                            AppSizes.sm,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(AppSizes.md),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSm,
                              ),
                              border: Border.all(
                                color: AppColors.error.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  color: AppColors.error,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    controller.errorMessage.value,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.xl,
                    4,
                    AppSizes.xl,
                    AppSizes.xl,
                  ),
                  child: _SubmitButton(controller: controller),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.xl,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.md,
                        ),
                        child: Text(
                          'or continue with',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.xl,
                    AppSizes.md,
                    AppSizes.xl,
                    AppSizes.xl,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          icon: Icons.g_mobiledata_rounded,
                          label: 'Google',
                          onTap: controller.signInWithGoogle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SocialButton(
                          icon: Icons.apple_rounded,
                          label: 'Apple',
                          onTap: controller.signInWithApple,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppSizes.xl,
                    left: AppSizes.xl,
                    right: AppSizes.xl,
                  ),
                  child: Text.rich(
                    TextSpan(
                      text: 'By continuing, you agree to our ',
                      style: AppTextStyles.labelSmall,
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.accent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.accent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthTabToggle extends StatelessWidget {
  final AuthController controller;
  const _AuthTabToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _TabItem(
              label: 'Sign In',
              isActive: controller.authMode.value == AuthMode.signIn,
              onTap: () => controller.switchMode(AuthMode.signIn),
            ),
            _TabItem(
              label: 'Sign Up',
              isActive: controller.authMode.value == AuthMode.signUp,
              onTap: () => controller.switchMode(AuthMode.signUp),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  const _TabItem({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
          decoration: BoxDecoration(
            color: isActive ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium.copyWith(
              color: isActive ? AppColors.primary : AppColors.textHint,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _SignInFields extends StatelessWidget {
  final AuthController controller;
  const _SignInFields({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('signin'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Welcome back 👋', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 4),
        Text('Sign in to your SeeTru account', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 24),
        _InputLabel(label: 'Email Address'),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller.emailController,
          validator: controller.validateEmail,
          keyboardType: TextInputType.emailAddress,
          style: AppTextStyles.inputText,
          decoration: const InputDecoration(
            hintText: 'deeen@code.com',
            prefixIcon: _InputIcon(icon: Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 16),
        _InputLabel(label: 'Password'),
        const SizedBox(height: 6),
        Obx(
          () => TextFormField(
            controller: controller.passwordController,
            validator: controller.validatePassword,
            obscureText: !controller.isPasswordVisible.value,
            style: AppTextStyles.inputText,
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const _InputIcon(icon: Icons.lock_outline_rounded),
              suffixIcon: GestureDetector(
                onTap: controller.togglePasswordVisibility,
                child: _InputIcon(
                  icon: controller.isPasswordVisible.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: controller.rememberMe.value,
                      onChanged: (v) =>
                          controller.rememberMe.value = v ?? false,
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(
                        color: AppColors.border,
                        width: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('Remember me', style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            TextButton(
              onPressed: controller.forgotPassword,
              child: Text(
                'Forgot Password?',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _SignUpFields extends StatelessWidget {
  final AuthController controller;
  const _SignUpFields({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('signup'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Text('Create account 🚀', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 4),
        Text(
          'Start your crypto intelligence journey',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 24),
        _InputLabel(label: 'Full Name'),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller.nameController,
          validator: controller.validateName,
          textCapitalization: TextCapitalization.words,
          style: AppTextStyles.inputText,
          decoration: const InputDecoration(
            hintText: 'Your full name',
            prefixIcon: _InputIcon(icon: Icons.person_outline_rounded),
          ),
        ),
        const SizedBox(height: 14),
        _InputLabel(label: 'Email Address'),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller.emailController,
          validator: controller.validateEmail,
          keyboardType: TextInputType.emailAddress,
          style: AppTextStyles.inputText,
          decoration: const InputDecoration(
            hintText: 'deeen@code.com',
            prefixIcon: _InputIcon(icon: Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 14),
        _InputLabel(label: 'Password'),
        const SizedBox(height: 6),
        Obx(
          () => TextFormField(
            controller: controller.passwordController,
            validator: controller.validatePassword,
            obscureText: !controller.isPasswordVisible.value,
            style: AppTextStyles.inputText,
            decoration: InputDecoration(
              hintText: 'Minimum 6 characters',
              prefixIcon: const _InputIcon(icon: Icons.lock_outline_rounded),
              suffixIcon: GestureDetector(
                onTap: controller.togglePasswordVisibility,
                child: _InputIcon(
                  icon: controller.isPasswordVisible.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _InputLabel(label: 'Confirm Password'),
        const SizedBox(height: 6),
        Obx(
          () => TextFormField(
            controller: controller.confirmPasswordController,
            validator: controller.validateConfirmPassword,
            obscureText: !controller.isConfirmPasswordVisible.value,
            style: AppTextStyles.inputText,
            decoration: InputDecoration(
              hintText: 'Re-enter password',
              prefixIcon: const _InputIcon(icon: Icons.lock_outline_rounded),
              suffixIcon: GestureDetector(
                onTap: controller.toggleConfirmPasswordVisibility,
                child: _InputIcon(
                  icon: controller.isConfirmPasswordVisible.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final AuthController controller;
  const _SubmitButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: controller.isLoading.value ? null : controller.submitForm,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: AppSizes.buttonHeight,
          decoration: BoxDecoration(
            gradient: controller.isLoading.value
                ? LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.7),
                      AppColors.primaryLight.withOpacity(0.7),
                    ],
                  )
                : LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.authMode.value == AuthMode.signIn
                            ? 'Sign In'
                            : 'Create Account',
                        style: AppTextStyles.buttonLarge,
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSizes.buttonHeightSm,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.textPrimary, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String label;
  const _InputLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.inputLabel);
  }
}

class _InputIcon extends StatelessWidget {
  final IconData icon;
  const _InputIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: AppColors.textHint, size: 18);
  }
}

class _SubtleGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;
    const step = 36.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}
