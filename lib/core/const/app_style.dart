import 'package:flutter/material.dart';
import 'app_color.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Display (ClashDisplay) ─────────────────────────────────────────
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'ClashDisplay',
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
    height: 1.15,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'ClashDisplay',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.8,
    height: 1.2,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'ClashDisplay',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.25,
  );

  // ── Headline (Satoshi) ─────────────────────────────────────────────
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.1,
    height: 1.35,
  );

  // ── Title (Satoshi Medium) ─────────────────────────────────────────
  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.4,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
    height: 1.4,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
    height: 1.4,
  );

  // ── Body (Satoshi Regular) ─────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0,
    height: 1.6,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.1,
    height: 1.55,
  );

  // ── Label / Caption ────────────────────────────────────────────────
  static const TextStyle labelLarge = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
    height: 1.3,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.4,
    height: 1.3,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
    letterSpacing: 0.5,
    height: 1.3,
  );

  // ── Numeric / Price (ClashDisplay for financial figures) ───────────
  static const TextStyle priceHero = TextStyle(
    fontFamily: 'ClashDisplay',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
    height: 1.1,
  );

  static const TextStyle priceLarge = TextStyle(
    fontFamily: 'ClashDisplay',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.6,
    height: 1.15,
  );

  static const TextStyle priceMedium = TextStyle(
    fontFamily: 'ClashDisplay',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.2,
  );

  static const TextStyle priceSmall = TextStyle(
    fontFamily: 'ClashDisplay',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.25,
  );

  // ── Positive / Negative Change ─────────────────────────────────────
  static const TextStyle positiveChange = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.green,
    letterSpacing: 0.2,
    height: 1.3,
  );

  static const TextStyle negativeChange = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.red,
    letterSpacing: 0.2,
    height: 1.3,
  );

  // ── Button Text ────────────────────────────────────────────────────
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    letterSpacing: 0.3,
    height: 1.2,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    letterSpacing: 0.3,
    height: 1.2,
  );

  static const TextStyle buttonOutlined = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: 0.3,
    height: 1.2,
  );

  // ── Nav Label ──────────────────────────────────────────────────────
  static const TextStyle navLabel = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.4,
    height: 1.2,
  );

  // ── Splash / Onboarding Special ────────────────────────────────────
  static const TextStyle splashLogo = TextStyle(
    fontFamily: 'ClashDisplay',
    fontSize: 42,
    fontWeight: FontWeight.w700,
    color: AppColors.textWhite,
    letterSpacing: -1.5,
    height: 1.0,
  );

  static const TextStyle onboardingTitle = TextStyle(
    fontFamily: 'ClashDisplay',
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.8,
    height: 1.2,
  );

  static const TextStyle onboardingSubtitle = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0,
    height: 1.65,
  );

  // ── Section Header ─────────────────────────────────────────────────
  static const TextStyle sectionHeader = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.1,
    height: 1.3,
  );

  static const TextStyle seeAll = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.accent,
    letterSpacing: 0.1,
    height: 1.3,
  );

  // ── Input Fields ───────────────────────────────────────────────────
  static const TextStyle inputText = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: 0,
    height: 1.4,
  );

  static const TextStyle inputLabel = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
    height: 1.4,
  );

  static const TextStyle inputHint = TextStyle(
    fontFamily: 'Satoshi',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    letterSpacing: 0,
    height: 1.4,
  );
}