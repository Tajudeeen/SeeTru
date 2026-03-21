import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seetru/core/const/app_color.dart';
import 'package:seetru/core/const/app_sizes.dart';
import 'package:seetru/core/const/app_style.dart';
import 'package:seetru/presentation/screens/portfolio/portfolio_controller.dart';

class PortfolioView extends GetView<PortfolioController> {
  const PortfolioView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }
        return CustomScrollView(
          slivers: [
            _PortfolioAppBar(controller: controller),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _PortfolioSummaryCard(controller: controller),
                  const SizedBox(height: 20),
                  _PortfolioChartSection(controller: controller),
                  const SizedBox(height: 20),
                  _AllocationSection(controller: controller),
                  const SizedBox(height: 20),
                  _TabBar(controller: controller),
                  const SizedBox(height: 16),
                  Obx(
                    () => controller.activeTab.value == 'Holdings'
                        ? _HoldingsList(controller: controller)
                        : controller.activeTab.value == 'Performance'
                        ? _PerformanceSection(controller: controller)
                        : const _TransactionsSection(),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Bar
// ─────────────────────────────────────────────────────────────────────────────
class _PortfolioAppBar extends StatelessWidget {
  final PortfolioController controller;
  const _PortfolioAppBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.background,
      floating: true,
      snap: true,
      elevation: 0,
      toolbarHeight: 64,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.screenPaddingH,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Portfolio', style: AppTextStyles.headlineLarge),
            Row(
              children: [
                _IconBtn(icon: Icons.search_rounded, onTap: () {}),
                const SizedBox(width: 8),
                _IconBtn(icon: Icons.add_rounded, onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary Card
// ─────────────────────────────────────────────────────────────────────────────
class _PortfolioSummaryCard extends StatelessWidget {
  final PortfolioController controller;
  const _PortfolioSummaryCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingH),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0B1136), Color(0xFF1A2B6D), Color(0xFF243CA0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.35),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Balance',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                GestureDetector(
                  onTap: controller.toggleBalanceVisibility,
                  child: Obx(
                    () => Icon(
                      controller.showBalanceValue.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.white.withOpacity(0.5),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(
              () => Text(
                controller.showBalanceValue.value
                    ? controller.formatValue(controller.totalValue.value)
                    : '•••••••',
                style: AppTextStyles.priceHero.copyWith(
                  color: Colors.white,
                  fontSize: 34,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _SummaryStatItem(
                  label: 'Invested',
                  value: controller.formatValue(controller.totalCost.value),
                  valueColor: Colors.white,
                ),
                _VertDivider(),
                _SummaryStatItem(
                  label: 'P&L',
                  value:
                      '+${controller.formatValue(controller.totalPnl.value)}',
                  valueColor: AppColors.green,
                ),
                _VertDivider(),
                _SummaryStatItem(
                  label: 'Return',
                  value:
                      '+${controller.totalPnlPercent.value.toStringAsFixed(2)}%',
                  valueColor: AppColors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  const _SummaryStatItem({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.titleSmall.copyWith(
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 32,
    color: Colors.white.withOpacity(0.12),
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Portfolio Chart Section
// ─────────────────────────────────────────────────────────────────────────────
class _PortfolioChartSection extends StatelessWidget {
  final PortfolioController controller;
  const _PortfolioChartSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Range Selector
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPaddingH,
          ),
          child: Obx(
            () => Row(
              children: controller.rangeOptions
                  .map(
                    (opt) => Expanded(
                      child: GestureDetector(
                        onTap: () => controller.setRange(opt.index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color:
                                controller.selectedRangeIndex.value == opt.index
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusSm,
                            ),
                          ),
                          child: Text(
                            opt.label,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.labelMedium.copyWith(
                              color:
                                  controller.selectedRangeIndex.value ==
                                      opt.index
                                  ? Colors.white
                                  : AppColors.textHint,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Chart
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPaddingH,
          ),
          child: Container(
            height: AppSizes.chartLarge,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Obx(() {
                final chartData = controller.portfolioChart.toList();
                return CustomPaint(
                  painter: _PortfolioChartPainter(data: chartData),
                  size: const Size(double.infinity, AppSizes.chartLarge),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}

class _PortfolioChartPainter extends CustomPainter {
  final List<double> data;
  _PortfolioChartPainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final min = data.reduce((a, b) => a < b ? a : b);
    final max = data.reduce((a, b) => a > b ? a : b);
    final range = max - min;
    if (range == 0) return;

    final pts = List.generate(data.length, (i) {
      final x = i / (data.length - 1) * size.width;
      final y = size.height - ((data[i] - min) / range) * (size.height * 0.8);
      return Offset(x, y + size.height * 0.1);
    });

    // Grid lines
    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    for (int i = 0; i <= 4; i++) {
      final y = size.height * 0.1 + (size.height * 0.8 / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Fill gradient
    final fillPath = Path()..moveTo(pts.first.dx, size.height);
    for (final p in pts) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(pts.last.dx, size.height);
    fillPath.close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0x554C6FFF), Color(0x004C6FFF)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final cp1 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i - 1].dy);
      final cp2 = Offset((pts[i - 1].dx + pts[i].dx) / 2, pts[i].dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.accent
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // End dot
    canvas.drawCircle(pts.last, 5, Paint()..color = AppColors.accent);
    canvas.drawCircle(pts.last, 3, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _PortfolioChartPainter old) => old.data != data;
}

// ─────────────────────────────────────────────────────────────────────────────
// Allocation Donut
// ─────────────────────────────────────────────────────────────────────────────
class _AllocationSection extends StatelessWidget {
  final PortfolioController controller;
  const _AllocationSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingH),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Asset Allocation', style: AppTextStyles.sectionHeader),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CustomPaint(
                    painter: _DonutChartPainter(holdings: controller.holdings),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${controller.holdings.length}',
                            style: AppTextStyles.priceLarge.copyWith(
                              fontSize: 26,
                            ),
                          ),
                          Text('Assets', style: AppTextStyles.labelSmall),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: controller.holdings
                        .map((h) => _LegendItem(holding: h))
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final PortfolioHolding holding;
  const _LegendItem({required this.holding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: holding.color,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(holding.symbol, style: AppTextStyles.titleSmall),
          ),
          Text(
            '${holding.allocation.toStringAsFixed(1)}%',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<PortfolioHolding> holdings;
  _DonutChartPainter({required this.holdings});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    const strokeWidth = 22.0;
    double startAngle = -math.pi / 2;

    for (final h in holdings) {
      final sweepAngle = (h.allocation / 100) * 2 * math.pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = h.color
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.butt,
      );
      startAngle += sweepAngle + 0.02;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter old) =>
      old.holdings != holdings;
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Tab Bar
// ─────────────────────────────────────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  final PortfolioController controller;
  const _TabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingH),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(4),
        child: Obx(
          () => Row(
            children: controller.tabs
                .map(
                  (tab) => Expanded(
                    child: GestureDetector(
                      onTap: () => controller.setActiveTab(tab),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          color: controller.activeTab.value == tab
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSm,
                          ),
                        ),
                        child: Text(
                          tab,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: controller.activeTab.value == tab
                                ? Colors.white
                                : AppColors.textHint,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Holdings List
// ─────────────────────────────────────────────────────────────────────────────
class _HoldingsList extends StatelessWidget {
  final PortfolioController controller;
  const _HoldingsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingH),
      child: Column(
        children: controller.holdings
            .map((h) => _HoldingTile(holding: h, controller: controller))
            .toList(),
      ),
    );
  }
}

class _HoldingTile extends StatelessWidget {
  final PortfolioHolding holding;
  final PortfolioController controller;
  const _HoldingTile({required this.holding, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: holding.color.withOpacity(0.15),
                  border: Border.all(
                    color: holding.color.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    holding.symbol[0],
                    style: TextStyle(
                      fontFamily: 'ClashDisplay',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: holding.color,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(holding.name, style: AppTextStyles.titleMedium),
                    Text(
                      '${holding.amount.toStringAsFixed(4)} ${holding.symbol}',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    controller.formatValue(holding.totalValue),
                    style: AppTextStyles.priceSmall,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        holding.isProfit
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 10,
                        color: holding.isProfit
                            ? AppColors.green
                            : AppColors.red,
                      ),
                      Text(
                        '${holding.pnlPercentage.abs().toStringAsFixed(2)}%',
                        style: TextStyle(
                          fontFamily: 'Satoshi',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: holding.isProfit
                              ? AppColors.green
                              : AppColors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Allocation bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Allocation', style: AppTextStyles.labelSmall),
                  Text(
                    '${holding.allocation.toStringAsFixed(1)}%',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: holding.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                child: LinearProgressIndicator(
                  value: holding.allocation / 100,
                  backgroundColor: AppColors.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(holding.color),
                  minHeight: 4,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Avg buy / current price row
          Row(
            children: [
              Expanded(
                child: _StatPill(
                  label: 'Avg Buy',
                  value: controller.formatPrice(holding.avgBuyPrice),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatPill(
                  label: 'Current',
                  value: controller.formatPrice(holding.currentPrice),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatPill(
                  label: 'P&L',
                  value:
                      '${holding.isProfit ? '+' : ''}${controller.formatValue(holding.pnl)}',
                  valueColor: holding.isProfit
                      ? AppColors.green
                      : AppColors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _StatPill({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Column(
        children: [
          Text(label, style: AppTextStyles.labelSmall),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Performance Section
// ─────────────────────────────────────────────────────────────────────────────
class _PerformanceSection extends StatelessWidget {
  final PortfolioController controller;
  const _PerformanceSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingH),
      child: Column(
        children: [
          _PerformanceMetricCard(
            title: 'Best Performer',
            symbol: 'SUI',
            value: '+101.4%',
            subtitle: 'Since avg buy at \$2.10',
            color: AppColors.green,
            icon: Icons.trending_up_rounded,
          ),
          const SizedBox(height: 10),
          _PerformanceMetricCard(
            title: 'Worst Performer',
            symbol: 'SOL',
            value: '+8.2%',
            subtitle: 'Since avg buy at \$165.00',
            color: AppColors.orange,
            icon: Icons.trending_flat_rounded,
          ),
          const SizedBox(height: 10),
          _PerformanceMetricCard(
            title: 'Total Unrealised P&L',
            symbol: 'Portfolio',
            value: '+\$5,657',
            subtitle: '+29.47% overall return',
            color: AppColors.accent,
            icon: Icons.account_balance_wallet_outlined,
          ),
        ],
      ),
    );
  }
}

class _PerformanceMetricCard extends StatelessWidget {
  final String title;
  final String symbol;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;

  const _PerformanceMetricCard({
    required this.title,
    required this.symbol,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.labelSmall),
                const SizedBox(height: 2),
                Text(symbol, style: AppTextStyles.titleMedium),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Text(
            value,
            style: AppTextStyles.priceMedium.copyWith(
              color: color,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Transactions Section
// ─────────────────────────────────────────────────────────────────────────────
class _TransactionsSection extends StatelessWidget {
  const _TransactionsSection();

  @override
  Widget build(BuildContext context) {
    final txs = [
      (
        'Bought BTC',
        '0.05 BTC',
        '-\$3,392.26',
        Icons.add_circle_outline_rounded,
        AppColors.green,
      ),
      (
        'Bought ETH',
        '0.5 ETH',
        '-\$1,400.00',
        Icons.add_circle_outline_rounded,
        AppColors.green,
      ),
      (
        'Sold SOL',
        '2.0 SOL',
        '+\$357.08',
        Icons.remove_circle_outline_rounded,
        AppColors.red,
      ),
      (
        'Bought SUI',
        '200 SUI',
        '-\$420.00',
        Icons.add_circle_outline_rounded,
        AppColors.green,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingH),
      child: Column(
        children: txs
            .map(
              (tx) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        // ✅ Fixed: tx.$5 is Color, tx.$4 is IconData
                        color: tx.$5.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(tx.$4, color: tx.$5, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tx.$1, style: AppTextStyles.titleMedium),
                          Text(tx.$2, style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    Text(
                      tx.$3,
                      style: AppTextStyles.priceSmall.copyWith(
                        color: tx.$3.startsWith('+')
                            ? AppColors.green
                            : AppColors.red,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Icon Button
// ─────────────────────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }
}
