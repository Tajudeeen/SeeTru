import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary Palette ────────────────────────────────────────────────
  static const Color primary = Color(0xFF1A2B6D);        // Deep navy (btn bg)
  static const Color primaryLight = Color(0xFF2A3F9D);   // Lighter navy hover
  static const Color primaryDark = Color(0xFF0F1A4A);    // Darkest navy

  // ── Accent / Highlight ─────────────────────────────────────────────
  static const Color accent = Color(0xFF4C6FFF);         // Vivid blue accent
  static const Color accentGlow = Color(0xFF6B8AFF);     // Glow / shimmer
  static const Color teal = Color(0xFF00C6CF);           // Teal chart accent
  static const Color green = Color(0xFF00C48C);          // Profit green
  static const Color red = Color(0xFFFF6B6B);            // Loss red
  static const Color orange = Color(0xFFFFAA38);         // Warning / promo

  // ── Background ─────────────────────────────────────────────────────
  static const Color background = Color(0xFFF0F4FF);     // Soft lavender-white
  static const Color backgroundDark = Color(0xFF0B0F1E); // Dark mode bg
  static const Color surface = Color(0xFFFFFFFF);        // Card / sheet white
  static const Color surfaceVariant = Color(0xFFE8EDFF); // Tinted surface
  static const Color surfaceDark = Color(0xFF161B30);    // Dark card
  static const Color gradientStart = Color(0xFFDDE8FF);  // Onboarding grad
  static const Color gradientEnd = Color(0xFFF5F0FF);    // Onboarding grad end

  // ── Banner / Promo ─────────────────────────────────────────────────
  static const Color bannerStart = Color(0xFF1A7EFF);    // Promo banner gradient
  static const Color bannerEnd = Color(0xFF00D2FF);      // Promo banner gradient

  // ── Text ───────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0F1A4A);    // Headlines
  static const Color textSecondary = Color(0xFF5A6A9A);  // Subtitles
  static const Color textHint = Color(0xFFA0AFCF);       // Placeholders
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A2E);

  // ── Borders & Dividers ─────────────────────────────────────────────
  static const Color border = Color(0xFFD8E2FF);
  static const Color divider = Color(0xFFEEF2FF);

  // ── Shadows ────────────────────────────────────────────────────────
  static const Color shadow = Color(0x1A1A2B6D);
  static const Color shadowDeep = Color(0x331A2B6D);

  // ── Status ─────────────────────────────────────────────────────────
  static const Color success = Color(0xFF00C48C);
  static const Color warning = Color(0xFFFFAA38);
  static const Color error = Color(0xFFFF4D4D);
  static const Color info = Color(0xFF4C6FFF);

  // ── Gradients ──────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bannerGradient = LinearGradient(
    colors: [bannerStart, bannerEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF0F4FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF00C48C), Color(0xFF00E5B0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient redGradient = LinearGradient(
    colors: [Color(0xFFFF4D4D), Color(0xFFFF8080)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}