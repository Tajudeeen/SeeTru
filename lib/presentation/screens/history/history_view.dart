import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seetru/core/const/app_color.dart';
import 'package:seetru/core/const/app_sizes.dart';
import 'package:seetru/core/const/app_style.dart';
import 'package:seetru/presentation/screens/history/history_controller.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _HistoryAppBar(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                );
              }
              return CustomScrollView(
                slivers: [
                  // Stats bar
                  SliverToBoxAdapter(child: _StatsBar(controller: controller)),

                  // Monthly summary cards
                  SliverToBoxAdapter(
                    child: _MonthlySummaryRow(controller: controller),
                  ),

                  // Filter chips
                  SliverToBoxAdapter(child: _FilterRow(controller: controller)),

                  // Transaction groups
                  Obx(() {
                    final groups = controller.grouped;
                    if (groups.isEmpty) {
                      return const SliverFillRemaining(
                        child: _EmptyHistoryState(),
                      );
                    }
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((ctx, i) {
                        final keys = groups.keys.toList();
                        final key = keys[i];
                        final txs = groups[key]!;
                        return _TransactionGroup(
                          dateLabel: key,
                          transactions: txs,
                          controller: controller,
                        );
                      }, childCount: groups.length),
                    );
                  }),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Bar
// ─────────────────────────────────────────────────────────────────────────────
class _HistoryAppBar extends StatelessWidget {
  final HistoryController controller;
  const _HistoryAppBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.screenPaddingH,
          10,
          AppSizes.screenPaddingH,
          8,
        ),
        child: Obx(
          () => controller.isSearching.value
              ? Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.searchController,
                        autofocus: true,
                        onChanged: controller.onSearchChanged,
                        style: AppTextStyles.inputText,
                        decoration: InputDecoration(
                          hintText: 'Search assets...',
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: AppColors.textHint,
                            size: 18,
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusMd,
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.accent,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: controller.toggleSearch,
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'History',
                          style: AppTextStyles.headlineLarge,
                        ),
                        Obx(
                          () => Text(
                            '${controller.totalTxCount.value} transactions',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textHint,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _IconBtn(
                          icon: Icons.search_rounded,
                          onTap: controller.toggleSearch,
                        ),
                        const SizedBox(width: 8),
                        _IconBtn(
                          icon: Icons.file_download_outlined,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats Bar
// ─────────────────────────────────────────────────────────────────────────────
class _StatsBar extends StatelessWidget {
  final HistoryController controller;
  const _StatsBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.screenPaddingH,
        4,
        AppSizes.screenPaddingH,
        16,
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0B1136), Color(0xFF1A2B6D), Color(0xFF243CA0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.30),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            _StatItem(
              label: 'Total Bought',
              value: controller.fmt(controller.totalBought.value),
              color: AppColors.green,
              icon: Icons.arrow_downward_rounded,
            ),
            _VertDiv(),
            _StatItem(
              label: 'Total Sold',
              value: controller.fmt(controller.totalSold.value),
              color: AppColors.red,
              icon: Icons.arrow_upward_rounded,
            ),
            _VertDiv(),
            _StatItem(
              label: 'Fees Paid',
              value: controller.fmt(controller.totalFees.value),
              color: AppColors.orange,
              icon: Icons.receipt_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
            ),
            child: Icon(icon, color: color, size: 13),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.priceSmall.copyWith(
              color: Colors.white,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _VertDiv extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 40,
    color: Colors.white.withOpacity(0.12),
    margin: const EdgeInsets.symmetric(horizontal: 4),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Monthly Summary Row
// ─────────────────────────────────────────────────────────────────────────────
class _MonthlySummaryRow extends StatelessWidget {
  final HistoryController controller;
  const _MonthlySummaryRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPaddingH,
          ),
          child: Text('Monthly Summary', style: AppTextStyles.sectionHeader),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.screenPaddingH,
            ),
            itemCount: controller.monthlySummaries.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) {
              final s = controller.monthlySummaries[i];
              return Container(
                width: 200,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          s.month,
                          style: AppTextStyles.titleSmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusFull,
                            ),
                          ),
                          child: Text(
                            '${s.txCount} txs',
                            style: AppTextStyles.labelSmall.copyWith(
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Net P&L', style: AppTextStyles.labelSmall),
                              Text(
                                '+${controller.fmt(s.netPnl)}',
                                style: AppTextStyles.priceMedium.copyWith(
                                  color: AppColors.green,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Volume', style: AppTextStyles.labelSmall),
                            Text(
                              controller.fmt(s.totalBought + s.totalSold),
                              style: AppTextStyles.priceSmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter Row
// ─────────────────────────────────────────────────────────────────────────────
class _FilterRow extends StatelessWidget {
  final HistoryController controller;
  const _FilterRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPaddingH,
          ),
          child: Text('Transactions', style: AppTextStyles.sectionHeader),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 36,
          child: Obx(() {
            final activeFilter =
                controller.activeFilter.value; // tracked immediately
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.screenPaddingH,
              ),
              itemCount: controller.filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = controller.filters[i];
                final isActive = activeFilter == f;
                return GestureDetector(
                  onTap: () => controller.setFilter(f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryLight,
                              ],
                            )
                          : null,
                      color: isActive ? null : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      border: Border.all(
                        color: isActive ? Colors.transparent : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        f,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isActive
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Transaction Group
// ─────────────────────────────────────────────────────────────────────────────
class _TransactionGroup extends StatelessWidget {
  final String dateLabel;
  final List<Transaction> transactions;
  final HistoryController controller;

  const _TransactionGroup({
    required this.dateLabel,
    required this.transactions,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Text(
                  dateLabel,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textHint,
                    fontSize: 11,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(child: Divider(color: AppColors.divider)),
              ],
            ),
          ),
          ...transactions.map(
            (tx) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _TransactionTile(tx: tx, controller: controller),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Transaction Tile
// ─────────────────────────────────────────────────────────────────────────────
class _TransactionTile extends StatelessWidget {
  final Transaction tx;
  final HistoryController controller;
  const _TransactionTile({required this.tx, required this.controller});

  @override
  Widget build(BuildContext context) {
    final color = controller.txColor(tx.type);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          onTap: () => _showDetail(context, tx),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Type icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    controller.txIcon(tx.type),
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${controller.txLabel(tx.type)} ${tx.assetSymbol}',
                            style: AppTextStyles.titleMedium,
                          ),
                          if (tx.type == TxType.swap && tx.toAsset != null) ...[
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 12,
                              color: AppColors.textHint,
                            ),
                            Text(
                              tx.toAsset!,
                              style: AppTextStyles.titleMedium.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            '${tx.isCredit ? '+' : '-'}${controller.fmt(tx.valueUsd)}',
                            style: AppTextStyles.priceSmall.copyWith(
                              color: tx.isCredit
                                  ? AppColors.green
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Text(
                            '${tx.amount.toStringAsFixed(4)} ${tx.assetSymbol}',
                            style: AppTextStyles.bodySmall,
                          ),
                          if (tx.type == TxType.swap &&
                              tx.toAmount != null) ...[
                            Text(' → ', style: AppTextStyles.bodySmall),
                            Text(
                              '${tx.toAmount!.toStringAsFixed(2)} ${tx.toAsset}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            controller.timeAgo(tx.timestamp),
                            style: AppTextStyles.labelSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          // Network chip
                          _SmallChip(
                            label: tx.network,
                            color: AppColors.surfaceVariant,
                          ),
                          const SizedBox(width: 6),
                          // Status chip
                          _SmallChip(
                            label: tx.status,
                            color: tx.status == 'completed'
                                ? AppColors.green.withOpacity(0.1)
                                : tx.status == 'pending'
                                ? AppColors.orange.withOpacity(0.1)
                                : AppColors.red.withOpacity(0.1),
                            textColor: tx.status == 'completed'
                                ? AppColors.green
                                : tx.status == 'pending'
                                ? AppColors.orange
                                : AppColors.red,
                          ),
                          const Spacer(),
                          // Hash
                          Text(
                            tx.txHash,
                            style: AppTextStyles.labelSmall.copyWith(
                              fontFamily: 'Satoshi',
                              color: AppColors.textHint,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, Transaction tx) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TxDetailSheet(tx: tx, controller: controller),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Transaction Detail Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _TxDetailSheet extends StatelessWidget {
  final Transaction tx;
  final HistoryController controller;
  const _TxDetailSheet({required this.tx, required this.controller});

  @override
  Widget build(BuildContext context) {
    final color = controller.txColor(tx.type);
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(controller.txIcon(tx.type), color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              '${controller.txLabel(tx.type)} ${tx.assetName}',
              style: AppTextStyles.headlineMedium,
            ),
            Text(
              controller.fmt(tx.valueUsd),
              style: AppTextStyles.priceLarge.copyWith(color: color),
            ),
            const SizedBox(height: 24),
            // Details
            _DetailRow(
              label: 'Amount',
              value: '${tx.amount.toStringAsFixed(6)} ${tx.assetSymbol}',
            ),
            _DetailRow(
              label: 'Price at Time',
              value: controller.fmt(tx.priceAtTime),
            ),
            _DetailRow(label: 'Network', value: tx.network),
            _DetailRow(label: 'Status', value: tx.status.toUpperCase()),
            _DetailRow(label: 'Tx Hash', value: tx.txHash),
            _DetailRow(
              label: 'Time',
              value: tx.timestamp.toString().substring(0, 16),
            ),
            const SizedBox(height: 20),
            // Copy hash button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy Transaction Hash'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text('Close'),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
class _SmallChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color? textColor;
  const _SmallChip({required this.label, required this.color, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          fontSize: 10,
          color: textColor ?? AppColors.textSecondary,
        ),
      ),
    );
  }
}

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

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceVariant,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 32,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 16),
          Text('No transactions found', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text('Try a different filter', style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
