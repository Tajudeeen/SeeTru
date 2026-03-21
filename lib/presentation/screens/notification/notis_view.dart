import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:seetru/core/const/app_color.dart';
import 'package:seetru/core/const/app_sizes.dart';
import 'package:seetru/core/const/app_style.dart';
import 'package:seetru/presentation/screens/notification/notis_controller.dart'
    hide AppColors;

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textPrimary,
            size: 20,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Notifications', style: AppTextStyles.headlineMedium),
            Obx(
              () => Text(
                '${controller.unreadCount.value} unread',
                style: AppTextStyles.bodySmall.copyWith(
                  color: controller.unreadCount.value > 0
                      ? AppColors.accent
                      : AppColors.textHint,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: controller.markAllAsRead,
            child: Text(
              'Mark all read',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          _NotifFilterChips(controller: controller),
          const SizedBox(height: 4),
          const Divider(height: 1, color: AppColors.divider),

          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.accent),
                );
              }

              final items = controller.filteredNotifications;
              if (items.isEmpty) {
                return const _EmptyNotifState();
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSizes.screenPaddingH,
                  16,
                  AppSizes.screenPaddingH,
                  100,
                ),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final notif = items[i];
                  return _NotificationCard(
                    notification: notif,
                    onTap: () => controller.markAsRead(notif.id),
                  );
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
// Filter Chips
// ─────────────────────────────────────────────────────────────────────────────
class _NotifFilterChips extends StatelessWidget {
  final NotificationController controller;
  const _NotifFilterChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Obx(
        () => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenPaddingH,
            vertical: 8,
          ),
          itemCount: controller.filters.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final f = controller.filters[i];
            final isActive = controller.activeFilter.value == f;
            return GestureDetector(
              onTap: () => controller.setFilter(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
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
                      color: isActive ? Colors.white : AppColors.textSecondary,
                      fontSize: 12,
                    ),
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
// Notification Card
// ─────────────────────────────────────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: notification.isRead
              ? AppColors.surface
              : AppColors.accent.withOpacity(0.04),
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: notification.isRead
                ? AppColors.border
                : AppColors.accent.withOpacity(0.2),
            width: notification.isRead ? 1.0 : 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: notification.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification.icon,
                  color: notification.color,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTextStyles.titleMedium.copyWith(
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Unread dot
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: notification.color,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      notification.body,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: notification.isRead
                            ? AppColors.textHint
                            : AppColors.textSecondary,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Text(
                          _notifTypeLabel(notification.type),
                          style: TextStyle(
                            fontFamily: 'Satoshi',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: notification.color,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.textHint,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _timeAgo(notification.timestamp),
                          style: AppTextStyles.labelSmall,
                        ),
                        const Spacer(),
                        if (notification.actionLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: notification.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusFull,
                              ),
                            ),
                            child: Text(
                              notification.actionLabel!,
                              style: TextStyle(
                                fontFamily: 'Satoshi',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: notification.color,
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
        ),
      ),
    );
  }

  String _notifTypeLabel(NotifType type) {
    switch (type) {
      case NotifType.priceAlert:
        return 'Price Alert';
      case NotifType.vcDeal:
        return 'VC Deal';
      case NotifType.social:
        return 'Social';
      case NotifType.portfolio:
        return 'Portfolio';
      case NotifType.system:
        return 'System';
    }
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyNotifState extends StatelessWidget {
  const _EmptyNotifState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceVariant,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 36,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 16),
          Text('No notifications yet', style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Price alerts, VC deals, and social alpha\nwill appear here.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
