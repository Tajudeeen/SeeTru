import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seetru/core/const/app_color.dart';
import 'package:seetru/core/const/app_sizes.dart';
import 'package:seetru/core/const/app_style.dart';
import 'package:seetru/presentation/screens/social/social_controller.dart';

class SocialView extends GetView<SocialController> {
  const SocialView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _SocialAppBar(controller: controller),
          _SocialTabBar(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                );
              }
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildTab(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTab() {
    switch (controller.activeTab.value) {
      case 'Feed':
        return const _FeedTab(key: ValueKey('feed'));
      case 'Trending':
        return const _TrendingTab(key: ValueKey('trending'));
      case 'KOLs':
        return const _KOLsTab(key: ValueKey('kols'));
      case 'Sentiment':
        return const _SentimentTab(key: ValueKey('sentiment'));
      default:
        return const _FeedTab(key: ValueKey('feed'));
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Bar
// ─────────────────────────────────────────────────────────────────────────────
class _SocialAppBar extends StatelessWidget {
  final SocialController controller;
  const _SocialAppBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: AppColors.background,
        padding: const EdgeInsets.fromLTRB(
          AppSizes.screenPaddingH,
          8,
          AppSizes.screenPaddingH,
          8,
        ),
        child: Obx(
          () => controller.isSearchActive.value
              ? _SearchBar(controller: controller)
              : Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: const Center(
                        child: Text(
                          '𝕏',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Social Alpha',
                            style: AppTextStyles.headlineMedium,
                          ),
                          Text(
                            'Powered by X (Twitter)',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textHint,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: controller.toggleSearch,
                      child: const _NavIconBtn(icon: Icons.search_rounded),
                    ),
                    const SizedBox(width: 8),
                    const _NavIconBtn(icon: Icons.tune_rounded),
                  ],
                ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final SocialController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller.searchController,
            autofocus: true,
            onChanged: controller.onSearchChanged,
            style: AppTextStyles.inputText,
            decoration: InputDecoration(
              hintText: 'Search tokens, KOLs, topics...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textHint,
              ),
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
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 14,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab Bar
// ─────────────────────────────────────────────────────────────────────────────
class _SocialTabBar extends StatelessWidget {
  final SocialController controller;
  const _SocialTabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Column(
        children: [
          SizedBox(
            height: 44,
            child: Obx(() {
              final activeTab =
                  controller.activeTab.value; // tracked immediately
              return ListView.separated(
                itemCount: controller.tabs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final tab = controller.tabs[i];
                  final isActive = activeTab == tab;
                  return GestureDetector(
                    onTap: () => controller.setActiveTab(tab),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull,
                        ),
                        border: Border.all(
                          color: isActive
                              ? Colors.transparent
                              : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          tab,
                          style: AppTextStyles.labelMedium.copyWith(
                            color: isActive
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.divider),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Feed Tab
// ─────────────────────────────────────────────────────────────────────────────
class _FeedTab extends GetView<SocialController> {
  const _FeedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        _FeedFilters(controller: controller),
        const SizedBox(height: 12),
        Expanded(
          child: Obx(
            () => RefreshIndicator(
              onRefresh: controller.refresh,
              color: AppColors.accent,
              child: controller.filteredPosts.isEmpty
                  ? const _EmptyFeedState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSizes.screenPaddingH,
                        0,
                        AppSizes.screenPaddingH,
                        100,
                      ),
                      itemCount: controller.filteredPosts.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (_, i) {
                        final post = controller.filteredPosts[i];
                        return _XPostCard(post: post, controller: controller);
                      },
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeedFilters extends StatelessWidget {
  final SocialController controller;
  const _FeedFilters({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Obx(
        () => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPaddingH,
          ),
          itemCount: controller.feedFilters.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final f = controller.feedFilters[i];
            final isActive = controller.activeFeedFilter.value == f;
            return GestureDetector(
              onTap: () => controller.setFeedFilter(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                  border: Border.all(
                    color: isActive ? Colors.transparent : AppColors.border,
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (f == 'Bullish')
                        const Text('🚀 ', style: TextStyle(fontSize: 11)),
                      if (f == 'Bearish')
                        const Text('📉 ', style: TextStyle(fontSize: 11)),
                      if (f == 'Alpha')
                        const Text('⚡ ', style: TextStyle(fontSize: 11)),
                      Text(
                        f,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: isActive
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// X Post Card
// ─────────────────────────────────────────────────────────────────────────────
class _XPostCard extends StatelessWidget {
  final XPost post;
  final SocialController controller;
  const _XPostCard({required this.post, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(
          color: post.isKOL
              ? AppColors.accent.withOpacity(0.2)
              : AppColors.border,
        ),
        boxShadow: post.isKOL
            ? [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.isKOL)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.08),
                    AppColors.teal.withOpacity(0.06),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.radiusMd),
                  topRight: Radius.circular(AppSizes.radiusMd),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 12,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Alpha KOL',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.accent,
                      fontSize: 10,
                    ),
                  ),
                  const Spacer(),
                  _SentimentBadge(sentiment: post.sentiment),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceVariant,
                        border: Border.all(
                          color: post.isVerified
                              ? AppColors.accent.withOpacity(0.3)
                              : AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          post.authorAvatar,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                post.authorName,
                                style: AppTextStyles.titleMedium,
                              ),
                              if (post.isVerified) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 14,
                                  color: AppColors.accent,
                                ),
                              ],
                            ],
                          ),
                          Text(
                            '${post.authorHandle} · ${controller.timeAgo(post.postedAt)}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textHint,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      '𝕏',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _RichPostContent(post: post),
                if (post.mentionedTokens.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: post.mentionedTokens
                        .map((t) => _TokenChip(token: t))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    _PostAction(
                      icon: Icons.chat_bubble_outline_rounded,
                      count: _formatCount(post.replies),
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 20),
                    _PostAction(
                      icon: Icons.repeat_rounded,
                      count: _formatCount(post.retweets),
                      color: AppColors.green,
                    ),
                    const SizedBox(width: 20),
                    _PostAction(
                      icon: Icons.favorite_border_rounded,
                      count: _formatCount(post.likes),
                      color: AppColors.red,
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {},
                      child: const Icon(
                        Icons.share_outlined,
                        size: 16,
                        color: AppColors.textHint,
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {},
                      child: const Icon(
                        Icons.bookmark_border_rounded,
                        size: 16,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _RichPostContent extends StatelessWidget {
  final XPost post;
  const _RichPostContent({required this.post});

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final words = post.content.split(' ');

    for (final word in words) {
      if (word.startsWith('\$') && word.length > 1) {
        spans.add(
          TextSpan(
            text: '$word ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      } else if (word.startsWith('#')) {
        spans.add(
          TextSpan(
            text: '$word ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.teal,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: '$word ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              height: 1.55,
            ),
          ),
        );
      }
    }

    return Text.rich(TextSpan(children: spans));
  }
}

class _PostAction extends StatelessWidget {
  final IconData icon;
  final String count;
  final Color color;
  const _PostAction({
    required this.icon,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Text(
          count,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textHint,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _TokenChip extends StatelessWidget {
  final String token;
  const _TokenChip({required this.token});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Text(
        '\$$token',
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.accent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SentimentBadge extends StatelessWidget {
  final String sentiment;
  const _SentimentBadge({required this.sentiment});

  @override
  Widget build(BuildContext context) {
    Color color;
    String emoji;
    switch (sentiment) {
      case 'bullish':
        color = AppColors.green;
        emoji = '🚀';
        break;
      case 'bearish':
        color = AppColors.red;
        emoji = '📉';
        break;
      default:
        color = AppColors.orange;
        emoji = '😐';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 10)),
          const SizedBox(width: 3),
          Text(
            sentiment[0].toUpperCase() + sentiment.substring(1),
            style: TextStyle(
              fontFamily: 'Satoshi',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Trending Tab
// ─────────────────────────────────────────────────────────────────────────────
class _TrendingTab extends GetView<SocialController> {
  const _TrendingTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.screenPaddingH,
        16,
        AppSizes.screenPaddingH,
        100,
      ),
      itemCount: controller.trendingTopics.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final topic = controller.trendingTopics[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Text(
                  '#${i + 1}',
                  style: AppTextStyles.priceMedium.copyWith(
                    color: AppColors.textHint,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(topic.tag, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _TagChipSmall(label: topic.category),
                        const SizedBox(width: 6),
                        Text(
                          '${topic.tweetCount} tweets',
                          style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (topic.isPositive ? AppColors.green : AppColors.red)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                ),
                child: Text(
                  topic.change,
                  style: TextStyle(
                    fontFamily: 'Satoshi',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: topic.isPositive ? AppColors.green : AppColors.red,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KOLs Tab
// ─────────────────────────────────────────────────────────────────────────────
class _KOLsTab extends GetView<SocialController> {
  const _KOLsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.screenPaddingH,
        16,
        AppSizes.screenPaddingH,
        100,
      ),
      itemCount: controller.kols.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final kol = controller.kols[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceVariant,
                  border: Border.all(color: AppColors.accent.withOpacity(0.2)),
                ),
                child: Center(
                  child: Text(kol.avatar, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(kol.name, style: AppTextStyles.titleMedium),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.verified_rounded,
                          size: 14,
                          color: AppColors.accent,
                        ),
                      ],
                    ),
                    Text(
                      kol.handle,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _TagChipSmall(label: kol.category),
                        const SizedBox(width: 6),
                        Text(
                          '${kol.followers} followers',
                          style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: kol.isFollowing
                        ? null
                        : const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryLight],
                          ),
                    color: kol.isFollowing ? AppColors.surfaceVariant : null,
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    border: kol.isFollowing
                        ? Border.all(color: AppColors.border)
                        : null,
                  ),
                  child: Text(
                    kol.isFollowing ? 'Following' : 'Follow',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: kol.isFollowing
                          ? AppColors.textSecondary
                          : Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sentiment Tab
// ─────────────────────────────────────────────────────────────────────────────
class _SentimentTab extends GetView<SocialController> {
  const _SentimentTab({super.key});

  @override
  Widget build(BuildContext context) {
    const fearGreedValue = 72;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.screenPaddingH,
        16,
        AppSizes.screenPaddingH,
        100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FearGreedGauge(value: fearGreedValue),
          const SizedBox(height: 20),
          const Text('Token Sentiment', style: AppTextStyles.sectionHeader),
          const SizedBox(height: 12),
          ...controller.sentimentData.entries
              .where((e) => e.key != 'Overall')
              .map((e) => _TokenSentimentBar(token: e.key, sentiment: e.value)),
          const SizedBox(height: 20),
          const Text('Sentiment Breakdown', style: AppTextStyles.sectionHeader),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                _SentimentBar(
                  label: 'Bullish',
                  pct: 0.64,
                  color: AppColors.green,
                ),
                SizedBox(height: 10),
                _SentimentBar(
                  label: 'Neutral',
                  pct: 0.22,
                  color: AppColors.orange,
                ),
                SizedBox(height: 10),
                _SentimentBar(
                  label: 'Bearish',
                  pct: 0.14,
                  color: AppColors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FearGreedGauge extends StatelessWidget {
  final int value;
  const _FearGreedGauge({required this.value});

  String get label {
    if (value <= 20) return 'Extreme Fear';
    if (value <= 40) return 'Fear';
    if (value <= 60) return 'Neutral';
    if (value <= 80) return 'Greed';
    return 'Extreme Greed';
  }

  Color get color {
    if (value <= 20) return AppColors.red;
    if (value <= 40) return AppColors.orange;
    if (value <= 60) return AppColors.orange;
    if (value <= 80) return AppColors.green;
    return const Color(0xFF00E5A0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1136), Color(0xFF1A2B6D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Column(
        children: [
          Text(
            'Fear & Greed Index',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: CustomPaint(
              painter: _GaugePainter(value: value, color: color),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '$value',
                    style: AppTextStyles.priceLarge.copyWith(
                      color: Colors.white,
                      fontSize: 32,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Satoshi',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final int value;
  final Color color;
  _GaugePainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.85);
    final radius = size.width * 0.42;
    const strokeWidth = 14.0;
    const startAngle = math.pi;
    const sweepAngle = math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = Colors.white.withOpacity(0.1)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final valueSweep = (value / 100) * sweepAngle;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      valueSweep,
      false,
      Paint()
        ..color = color
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.value != value || old.color != color;
}

class _TokenSentimentBar extends StatelessWidget {
  final String token;
  final String sentiment;
  const _TokenSentimentBar({required this.token, required this.sentiment});

  Color get _color {
    switch (sentiment.toLowerCase()) {
      case 'very bullish':
        return const Color(0xFF00E5A0);
      case 'bullish':
        return AppColors.green;
      case 'bearish':
        return AppColors.red;
      default:
        return AppColors.orange;
    }
  }

  double get _pct {
    switch (sentiment.toLowerCase()) {
      case 'very bullish':
        return 0.88;
      case 'bullish':
        return 0.70;
      case 'neutral':
        return 0.50;
      case 'bearish':
        return 0.25;
      default:
        return 0.50;
    }
  }

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
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(token, style: AppTextStyles.labelLarge),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              child: LinearProgressIndicator(
                value: _pct,
                backgroundColor: AppColors.surfaceVariant,
                valueColor: AlwaysStoppedAnimation<Color>(_color),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            ),
            child: Text(
              sentiment,
              style: TextStyle(
                fontFamily: 'Satoshi',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: _color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SentimentBar extends StatelessWidget {
  final String label;
  final double pct;
  final Color color;
  const _SentimentBar({
    required this.label,
    required this.pct,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 56, child: Text(label, style: AppTextStyles.bodySmall)),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '${(pct * 100).toInt()}%',
          style: AppTextStyles.labelMedium.copyWith(color: color),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
class _TagChipSmall extends StatelessWidget {
  final String label;
  const _TagChipSmall({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(fontSize: 10),
      ),
    );
  }
}

class _NavIconBtn extends StatelessWidget {
  final IconData icon;
  const _NavIconBtn({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, size: 17, color: AppColors.textPrimary),
    );
  }
}

class _EmptyFeedState extends StatelessWidget {
  const _EmptyFeedState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('😶', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text('No posts found', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 6),
          Text(
            'Try a different filter or search',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}
