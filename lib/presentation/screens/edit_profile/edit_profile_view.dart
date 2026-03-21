import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seetru/core/const/app_color.dart';
import '../../../core/const/app_sizes.dart';
import '../../../core/const/app_style.dart';
import 'edit_profile_controller.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        title: const Text('Edit Profile', style: AppTextStyles.headlineMedium),
        actions: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: controller.isSaving.value ? null : controller.save,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: controller.hasChanges.value
                        ? const LinearGradient(
                            colors: [AppColors.accent, AppColors.teal],
                          )
                        : null,
                    color: controller.hasChanges.value
                        ? null
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  ),
                  child: controller.isSaving.value
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Save',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: controller.hasChanges.value
                                ? Colors.white
                                : AppColors.textHint,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.screenPaddingH,
          8,
          AppSizes.screenPaddingH,
          100,
        ),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar picker ──────────────────────────────────
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: AppSizes.avatarHero,
                      height: AppSizes.avatarHero,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [AppColors.accent, AppColors.teal],
                        ),
                        border: Border.all(color: AppColors.border, width: 3),
                      ),
                      child: const Center(
                        child: Text(
                          'A',
                          style: TextStyle(
                            fontFamily: 'ClashDisplay',
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryLight,
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.background,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Center(
                child: TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.photo_library_rounded, size: 15),
                  label: const Text('Change Photo'),
                ),
              ),

              const SizedBox(height: 20),

              // ── Form sections ──────────────────────────────────
              _SectionLabel(label: 'Personal Info'),
              const SizedBox(height: 10),

              _FormField(
                label: 'Full Name',
                controller: controller.nameController,
                hint: 'Your display name',
                icon: Icons.person_outline_rounded,
                validator: controller.validateName,
              ),

              const SizedBox(height: 14),

              _FormField(
                label: 'Username',
                controller: controller.usernameController,
                hint: '@Deeen_Code',
                icon: Icons.alternate_email_rounded,
                validator: controller.validateUsername,
              ),

              const SizedBox(height: 14),

              _FormField(
                label: 'Bio',
                controller: controller.bioController,
                hint: 'Tell the community about yourself...',
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),

              const SizedBox(height: 24),

              _SectionLabel(label: 'Contact & Links'),
              const SizedBox(height: 10),

              _FormField(
                label: 'Email Address',
                controller: controller.emailController,
                hint: 'deeen@code.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 14),

              _FormField(
                label: 'Location',
                controller: controller.locationController,
                hint: 'City, Country',
                icon: Icons.location_on_outlined,
              ),

              const SizedBox(height: 14),

              _FormField(
                label: 'Website',
                controller: controller.websiteController,
                hint: 'deeencode.com',
                icon: Icons.link_rounded,
                keyboardType: TextInputType.url,
              ),

              const SizedBox(height: 24),

              _SectionLabel(label: 'Crypto Preferences'),
              const SizedBox(height: 10),

              // Preferred coins chips
              _CoinPreferenceChips(),

              const SizedBox(height: 24),

              // Danger zone
              _DangerZone(),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Form Field
// ─────────────────────────────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.inputLabel),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: AppTextStyles.inputText,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textHint, size: 18),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textHint,
            letterSpacing: 1.0,
            fontSize: 11,
          ),
        ),
        const SizedBox(width: 8),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}

class _CoinPreferenceChips extends StatefulWidget {
  @override
  State<_CoinPreferenceChips> createState() => _CoinPreferenceChipsState();
}

class _CoinPreferenceChipsState extends State<_CoinPreferenceChips> {
  final List<String> coins = [
    'BTC',
    'ETH',
    'SOL',
    'SUI',
    'BNB',
    'AVAX',
    'ARB',
    'OP',
  ];
  final Set<String> selected = {'BTC', 'ETH'};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Favourite Assets', style: AppTextStyles.titleSmall),
          const SizedBox(height: 8),
          Text(
            'Select the assets you follow most closely',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: coins.map((c) {
              final isSelected = selected.contains(c);
              return GestureDetector(
                onTap: () => setState(() {
                  isSelected ? selected.remove(c) : selected.add(c);
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                          )
                        : null,
                    color: isSelected ? null : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppColors.border,
                    ),
                  ),
                  child: Text(
                    '\$$c',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.04),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.error.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 16,
                color: AppColors.error,
              ),
              const SizedBox(width: 6),
              Text(
                'Danger Zone',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.delete_outline_rounded,
                size: 16,
                color: AppColors.error,
              ),
              label: Text(
                'Delete Account',
                style: AppTextStyles.buttonMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                foregroundColor: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
