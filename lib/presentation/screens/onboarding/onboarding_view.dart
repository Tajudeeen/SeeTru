import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seetru/core/const/app_color.dart';
import 'package:seetru/core/const/app_sizes.dart';
import 'package:seetru/core/const/app_style.dart';
import 'onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Background gradient orbs ────────────────────────────────
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 120,
            left: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.teal.withOpacity(0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Page content ───────────────────────────────────────────
          Column(
            children: [
              // Skip button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.screenPaddingH,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9),
                              gradient: const LinearGradient(
                                colors: [AppColors.accent, AppColors.teal],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.remove_red_eye_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('SeeTru',
                              style: TextStyle(
                                fontFamily: 'ClashDisplay',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              )),
                        ],
                      ),
                      TextButton(
                        onPressed: controller.skipOnboarding,
                        child: Text(
                          'Skip',
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.textHint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  itemCount: controller.totalPages,
                  itemBuilder: (_, index) => _OnboardingPage(index: index),
                ),
              ),

              // ── Dots + CTA ─────────────────────────────────────────
              Padding(
                padding: EdgeInsets.only(
                  left: AppSizes.screenPaddingH,
                  right: AppSizes.screenPaddingH,
                  bottom: MediaQuery.of(context).padding.bottom + 28,
                ),
                child: Column(
                  children: [
                    // Dots
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.totalPages,
                        (i) => _DotIndicator(
                          isActive: i == controller.currentPage.value,
                        ),
                      ),
                    )),

                    const SizedBox(height: 28),

                    // Next / Get Started button
                    Obx(() => _OnboardingButton(
                      isLast: controller.isLastPage,
                      onTap: controller.nextPage,
                    )),

                    const SizedBox(height: 16),

                    // Sign in link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                        GestureDetector(
                          onTap: controller.completeOnboarding,
                          child: Text(
                            'Sign In',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual Onboarding Page
// ─────────────────────────────────────────────────────────────────────────────
class _OnboardingPage extends GetView<OnboardingController> {
  final int index;

  const _OnboardingPage({required this.index});

  static const List<List<Color>> _illustrationColors = [
    [Color(0xFF4C6FFF), Color(0xFF00C6CF)],
    [Color(0xFF1A2B6D), Color(0xFF4C6FFF)],
    [Color(0xFF00C6CF), Color(0xFF00C48C)],
  ];

  static const List<String> _titles = AppStrings.onboardingTitles;
  static const List<String> _subtitles = AppStrings.onboardingSubtitles;

  static const List<IconData> _icons = [
    Icons.show_chart_rounded,
    Icons.analytics_rounded,
    Icons.people_alt_rounded,
  ];

  static const List<List<_StatChip>> _chips = [
    [
      _StatChip(label: 'BTC', value: '+4.2%', positive: true),
      _StatChip(label: 'ETH', value: '+2.8%', positive: true),
      _StatChip(label: 'SOL', value: '-1.1%', positive: false),
    ],
    [
      _StatChip(label: 'VC Rounds', value: '84', positive: true),
      _StatChip(label: 'Raised', value: '\$2.4B', positive: true),
      _StatChip(label: 'Protocols', value: '312', positive: true),
    ],
    [
      _StatChip(label: 'Tweets', value: '14.2K', positive: true),
      _StatChip(label: 'Trending', value: '#BTC', positive: true),
      _StatChip(label: 'KOLs', value: '240+', positive: true),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => AnimatedOpacity(
      opacity: controller.contentOpacity.value,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: Offset(0, controller.contentOffset.value / 300),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPaddingH,
          ),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // ── Illustration card ─────────────────────────────────
              _IllustrationCard(
                gradientColors: _illustrationColors[index],
                icon: _icons[index],
                chips: _chips[index],
                pageIndex: index,
              ),

              const SizedBox(height: 36),

              // Title
              Text(
                _titles[index],
                style: AppTextStyles.onboardingTitle,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  _subtitles[index],
                  style: AppTextStyles.onboardingSubtitle,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Illustration card
// ─────────────────────────────────────────────────────────────────────────────
class _IllustrationCard extends StatelessWidget {
  final List<Color> gradientColors;
  final IconData icon;
  final List<_StatChip> chips;
  final int pageIndex;

  const _IllustrationCard({
    required this.gradientColors,
    required this.icon,
    required this.chips,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradientColors[0].withOpacity(0.08),
            gradientColors[1].withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(
          color: gradientColors[0].withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Corner accent
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    gradientColors[0].withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Chart/visual illustration based on page
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _PageIllustration(
                pageIndex: pageIndex,
                color: gradientColors[0],
              ),
            ),
          ),

          // Floating stat chips
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Row(
              children: chips
                  .map((c) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: _FloatingStatChip(chip: c),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// Illustration content for each page
class _PageIllustration extends StatelessWidget {
  final int pageIndex;
  final Color color;

  const _PageIllustration({required this.pageIndex, required this.color});

  @override
  Widget build(BuildContext context) {
    if (pageIndex == 0) return _ChartIllustration(color: color);
    if (pageIndex == 1) return _VCIllustration(color: color);
    return _SocialIllustration(color: color);
  }
}

// Chart illustration
class _ChartIllustration extends StatelessWidget {
  final Color color;
  const _ChartIllustration({required this.color});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ChartPainter(color: color),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final Color color;
  _ChartPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final List<Offset> points = [
      Offset(0, size.height * 0.6),
      Offset(size.width * 0.15, size.height * 0.5),
      Offset(size.width * 0.30, size.height * 0.65),
      Offset(size.width * 0.45, size.height * 0.35),
      Offset(size.width * 0.60, size.height * 0.45),
      Offset(size.width * 0.75, size.height * 0.2),
      Offset(size.width * 0.90, size.height * 0.30),
      Offset(size.width, size.height * 0.15),
    ];

    // Fill
    final fillPath = Path()..moveTo(0, size.height);
    for (final p in points) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          colors: [color.withOpacity(0.30), color.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    final linePath = Path()..moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(
      linePath,
      Paint()
        ..color = color
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Dot on peak
    canvas.drawCircle(
      points[7],
      5,
      Paint()..color = color,
    );
    canvas.drawCircle(
      points[7],
      3,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter o) => false;
}

// VC illustration
class _VCIllustration extends StatelessWidget {
  final Color color;
  const _VCIllustration({required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _VCBar(height: 0.5, color: color, label: 'Q1'),
            _VCBar(height: 0.7, color: color, label: 'Q2'),
            _VCBar(height: 0.45, color: color, label: 'Q3'),
            _VCBar(height: 0.85, color: color, label: 'Q4'),
            _VCBar(height: 0.65, color: color, label: 'Q1'),
            _VCBar(height: 0.90, color: color, label: 'Q2'),
          ],
        ),
      ],
    );
  }
}

class _VCBar extends StatelessWidget {
  final double height;
  final Color color;
  final String label;
  const _VCBar({required this.height, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 120 * height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.3)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 9,
              color: AppColors.textHint,
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }
}

// Social illustration
class _SocialIllustration extends StatelessWidget {
  final Color color;
  const _SocialIllustration({required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialPost(
          avatar: '🐸',
          handle: '@deeen_code',
          text: '#BTC breaking \$80K resistance. This is it. 🚀',
          color: color,
        ),
        const SizedBox(height: 10),
        _SocialPost(
          avatar: '🦁',
          handle: '@deeen_code',
          text: 'New Layer2 raise: \$120M seed. \$ARB ecosystem expanding',
          color: color,
        ),
      ],
    );
  }
}

class _SocialPost extends StatelessWidget {
  final String avatar;
  final String handle;
  final String text;
  final Color color;

  const _SocialPost({
    required this.avatar,
    required this.handle,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(avatar, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(handle,
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    )),
                const SizedBox(height: 2),
                Text(text,
                    style: const TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 10,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating stat chip
// ─────────────────────────────────────────────────────────────────────────────
class _StatChip {
  final String label;
  final String value;
  final bool positive;
  const _StatChip({required this.label, required this.value, required this.positive});
}

class _FloatingStatChip extends StatelessWidget {
  final _StatChip chip;
  const _FloatingStatChip({required this.chip});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(chip.label,
              style: const TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 9,
                color: AppColors.textHint,
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(height: 2),
          Text(chip.value,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: chip.positive ? AppColors.green : AppColors.red,
              )),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Dot Indicator
// ─────────────────────────────────────────────────────────────────────────────
class _DotIndicator extends StatelessWidget {
  final bool isActive;
  const _DotIndicator({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        gradient: isActive
            ? const LinearGradient(colors: [AppColors.accent, AppColors.teal])
            : null,
        color: isActive ? null : AppColors.border,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CTA Button
// ─────────────────────────────────────────────────────────────────────────────
class _OnboardingButton extends StatelessWidget {
  final bool isLast;
  final VoidCallback onTap;
  const _OnboardingButton({required this.isLast, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: AppSizes.buttonHeight,
        decoration: BoxDecoration(
          gradient: isLast
              ? const LinearGradient(
                  colors: [AppColors.accent, AppColors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          boxShadow: [
            BoxShadow(
              color: (isLast ? AppColors.teal : AppColors.primary)
                  .withOpacity(0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLast ? 'Get Started' : 'Continue',
              style: AppTextStyles.buttonLarge,
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded,
                color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}

// Import AppStrings since we use them above
class AppStrings {
  static const List<String> onboardingTitles = [
    'Track Every\nAsset in Real‑Time',
    'Deep Crypto\nIntelligence',
    'Social Alpha\nFrom the Source',
  ];
  static const List<String> onboardingSubtitles = [
    'Monitor your portfolio, watchlist prices, and on-chain moves — all in one beautifully clear dashboard.',
    'VC rounds, fundraising data, whale activity and market sentiment — verified, live, and always up to date.',
    'Tap into X (Twitter) crypto communities and discover trending tokens before the crowd does.',
  ];
}