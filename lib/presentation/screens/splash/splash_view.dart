import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seetru/core/const/app_color.dart';
import 'package:seetru/core/const/app_style.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0B1136),
              Color(0xFF1A2B6D),
              Color(0xFF0D1F5C),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // ── Background orbs ──────────────────────────────────────
            Positioned(
              top: -size.height * 0.12,
              right: -size.width * 0.2,
              child: _BackgroundOrb(
                size: size.width * 0.7,
                color: AppColors.accent.withOpacity(0.12),
              ),
            ),
            Positioned(
              bottom: -size.height * 0.1,
              left: -size.width * 0.25,
              child: _BackgroundOrb(
                size: size.width * 0.65,
                color: AppColors.teal.withOpacity(0.09),
              ),
            ),
            Positioned(
              top: size.height * 0.55,
              right: -size.width * 0.1,
              child: _BackgroundOrb(
                size: size.width * 0.45,
                color: AppColors.primaryLight.withOpacity(0.18),
              ),
            ),

            // ── Grid lines (subtle) ───────────────────────────────────
            CustomPaint(
              size: Size(size.width, size.height),
              painter: _GridPainter(),
            ),

            // ── Centre content ─────────────────────────────────────────
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo mark + wordmark
                  Obx(() => AnimatedScale(
                    scale: controller.logoScale.value,
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.elasticOut,
                    child: AnimatedOpacity(
                      opacity: controller.logoOpacity.value,
                      duration: const Duration(milliseconds: 500),
                      child: Column(
                        children: [
                          // Logo icon
                          Container(
                            width: 88,
                            height: 88,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF4C6FFF), Color(0xFF00C6CF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent.withOpacity(0.45),
                                  blurRadius: 32,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: _LogoMark(),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Wordmark with shimmer
                          ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: const [
                                AppColors.textWhite,
                                Color(0xFF9BBFFF),
                                AppColors.textWhite,
                              ],
                              stops: const [0.0, 0.5, 1.0],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(bounds),
                            child: const Text(
                              'SeeTru',
                              style: AppTextStyles.splashLogo,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),

                  const SizedBox(height: 14),

                  // Tagline
                  Obx(() => AnimatedOpacity(
                    opacity: controller.taglineOpacity.value,
                    duration: const Duration(milliseconds: 600),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 1.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                AppColors.teal.withOpacity(0.6),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'See the Truth in Crypto',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textWhite.withOpacity(0.55),
                            letterSpacing: 1.4,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 20,
                          height: 1.5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.teal.withOpacity(0.6),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            // ── Bottom loader ──────────────────────────────────────────
            Positioned(
              bottom: 52,
              left: 0,
              right: 0,
              child: Obx(() => AnimatedOpacity(
                opacity: controller.taglineOpacity.value,
                duration: const Duration(milliseconds: 700),
                child: const Column(
                  children: [
                    _PulsingDots(),
                    SizedBox(height: 16),
                    Text(
                      'Powered by SeeTru Intelligence',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Satoshi',
                        fontSize: 11,
                        color: Color(0x66FFFFFF),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Logo Mark widget (custom SVG-like drawing)
// ─────────────────────────────────────────────────────────────────────────────
class _LogoMark extends StatelessWidget {
  const _LogoMark();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(44, 44),
      painter: _LogoMarkPainter(),
    );
  }
}

class _LogoMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..style = PaintingStyle.fill;

    // Eye shape (representing "See")
    final eyePath = Path();
    eyePath.moveTo(size.width * 0.1, size.height * 0.5);
    eyePath.quadraticBezierTo(
      size.width * 0.5, size.height * 0.18,
      size.width * 0.9, size.height * 0.5,
    );
    eyePath.quadraticBezierTo(
      size.width * 0.5, size.height * 0.82,
      size.width * 0.1, size.height * 0.5,
    );
    canvas.drawPath(eyePath, fillPaint);
    canvas.drawPath(eyePath, paint);

    // Pupil
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      size.width * 0.13,
      paint..color = Colors.white,
    );

    // Tick / check mark (representing "Truth")
    final tickPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final tickPath = Path();
    tickPath.moveTo(size.width * 0.32, size.height * 0.49);
    tickPath.lineTo(size.width * 0.46, size.height * 0.63);
    tickPath.lineTo(size.width * 0.68, size.height * 0.37);
    canvas.drawPath(tickPath, tickPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Background orb
// ─────────────────────────────────────────────────────────────────────────────
class _BackgroundOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _BackgroundOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Grid painter for subtle background texture
// ─────────────────────────────────────────────────────────────────────────────
class _GridPainter extends CustomPainter {
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Pulsing loading dots
// ─────────────────────────────────────────────────────────────────────────────
class _PulsingDots extends StatefulWidget {
  const _PulsingDots();

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 700),
      )..repeat(reverse: true),
    );

    _animations = List.generate(
      3,
      (i) => Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(
          parent: _controllers[i],
          curve: Curves.easeInOut,
        ),
      ),
    );

    // Stagger
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _controllers[1].forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controllers[2].forward();
    });
    _controllers[0].forward();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (_, __) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.teal.withOpacity(_animations[i].value),
            ),
          ),
        );
      }),
    );
  }
}