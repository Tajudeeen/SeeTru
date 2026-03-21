import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/const/app_color.dart';
import '../../../core/const/app_sizes.dart';
import '../../../core/const/app_style.dart';
import 'add_token_controller.dart';

class AddTokenView extends GetView<AddTokenController> {
  const AddTokenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Handle ─────────────────────────────────────────────
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 6),
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // ── Header ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.screenPaddingH,
              8,
              AppSizes.screenPaddingH,
              16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add to Watchlist',
                      style: AppTextStyles.headlineMedium,
                    ),
                    Obx(
                      () => Text(
                        '${controller.watchlistedIds.length} tokens tracked',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.accent,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceVariant,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textPrimary,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Search bar ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.screenPaddingH,
              0,
              AppSizes.screenPaddingH,
              16,
            ),
            child: TextField(
              controller: controller.searchController,
              onChanged: controller.onSearchChanged,
              style: AppTextStyles.inputText,
              decoration: InputDecoration(
                hintText: 'Search by name or symbol...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textHint,
                  size: 20,
                ),
                suffixIcon: Obx(
                  () => controller.query.value.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            controller.searchController.clear();
                            controller.onSearchChanged('');
                          },
                          child: const Icon(
                            Icons.clear_rounded,
                            color: AppColors.textHint,
                            size: 18,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  borderSide: const BorderSide(
                    color: AppColors.accent,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),

          // ── Section label ──────────────────────────────────────
          Obx(
            () => Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.screenPaddingH,
                0,
                AppSizes.screenPaddingH,
                10,
              ),
              child: Text(
                controller.query.value.isEmpty
                    ? 'All Assets'
                    : 'Search Results',
                style: AppTextStyles.sectionHeader,
              ),
            ),
          ),

          // ── Token list ─────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (controller.isSearching.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                );
              }

              final list = controller.displayList;
              if (list.isEmpty) {
                return _EmptySearch(query: controller.query.value);
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.screenPaddingH,
                  0,
                  AppSizes.screenPaddingH,
                  40,
                ),
                itemCount: list.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final token = list[i];
                  return _TokenRow(token: token, controller: controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Token Row
// ─────────────────────────────────────────────────────────────────────────────
class _TokenRow extends StatelessWidget {
  final TokenResult token;
  final AddTokenController controller;
  const _TokenRow({required this.token, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 28,
            child: Text(
              '#${token.rank}',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textHint,
                fontSize: 10,
              ),
            ),
          ),

          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withOpacity(0.15),
                  AppColors.teal.withOpacity(0.10),
                ],
              ),
            ),
            child: Center(
              child: Text(
                token.symbol[0],
                style: const TextStyle(
                  fontFamily: 'ClashDisplay',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Name + mcap
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(token.name, style: AppTextStyles.titleMedium),
                Text(
                  '${token.symbol} · ${controller.fmtCap(token.marketCap)}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),

          // Price + change
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                controller.fmt(token.price),
                style: AppTextStyles.priceSmall,
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    token.isPositive
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 10,
                    color: token.isPositive ? AppColors.green : AppColors.red,
                  ),
                  Text(
                    '${token.change24h.abs().toStringAsFixed(2)}%',
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: token.isPositive ? AppColors.green : AppColors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(width: 12),

          // Add/Remove button
          Obx(() {
            final inList = controller.isInWatchlist(token.id);
            return GestureDetector(
              onTap: () => controller.toggleWatchlist(token.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: inList
                      ? null
                      : const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                        ),
                  color: inList ? AppColors.green.withOpacity(0.1) : null,
                  borderRadius: BorderRadius.circular(10),
                  border: inList
                      ? Border.all(color: AppColors.green.withOpacity(0.3))
                      : null,
                ),
                child: Icon(
                  inList ? Icons.check_rounded : Icons.add_rounded,
                  color: inList ? AppColors.green : Colors.white,
                  size: 18,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty Search State
// ─────────────────────────────────────────────────────────────────────────────
class _EmptySearch extends StatelessWidget {
  final String query;
  const _EmptySearch({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          Text('No results for "$query"', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Try a different token name or symbol',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
