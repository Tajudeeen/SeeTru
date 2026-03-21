import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum NotifType { priceAlert, vcDeal, social, portfolio, system }

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotifType type;
  final DateTime timestamp;
  final bool isRead;
  final String? actionLabel;
  final IconData icon;
  final Color color;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    required this.isRead,
    this.actionLabel,
    required this.icon,
    required this.color,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        body: body,
        type: type,
        timestamp: timestamp,
        isRead: isRead ?? this.isRead,
        actionLabel: actionLabel,
        icon: icon,
        color: color,
      );
}

class NotificationController extends GetxController {
  final RxBool isLoading = true.obs;
  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxString activeFilter = 'All'.obs;
  final RxInt unreadCount = 0.obs;

  final List<String> filters = ['All', 'Prices', 'VC Deals', 'Social', 'System'].obs;

  @override
  void onReady() {
    super.onReady();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 600));
    _populateMockData();
    isLoading.value = false;
  }

  void _populateMockData() {
    notifications.value = [
      AppNotification(
        id: '1',
        title: '🚀 BTC Price Alert',
        body: 'Bitcoin crossed your target price of \$67,000. Current: \$67,845.',
        type: NotifType.priceAlert,
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        isRead: false,
        actionLabel: 'View Chart',
        icon: Icons.show_chart_rounded,
        color: AppColors.green,
      ),
      AppNotification(
        id: '2',
        title: '💼 New VC Deal Detected',
        body: 'Monad Labs raised \$225M Series A led by Paradigm and a16z.',
        type: NotifType.vcDeal,
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        isRead: false,
        actionLabel: 'See Details',
        icon: Icons.business_center_rounded,
        color: AppColors.accent,
      ),
      AppNotification(
        id: '3',
        title: '🐋 Whale Movement',
        body: 'A wallet moved 1,420 BTC (\$96.3M) to Binance. Could signal sell pressure.',
        type: NotifType.priceAlert,
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        actionLabel: 'Track On-Chain',
        icon: Icons.water_rounded,
        color: AppColors.orange,
      ),
      AppNotification(
        id: '4',
        title: 'X Alpha: @CryptoKaleo',
        body: 'A KOL you follow just posted about \$SUI breaking out. High engagement.',
        type: NotifType.social,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        isRead: true,
        actionLabel: 'Read Post',
        icon: Icons.people_rounded,
        color: AppColors.teal,
      ),
      AppNotification(
        id: '5',
        title: '📊 Portfolio Up 3.24%',
        body: 'Your portfolio gained \$779.42 today. BTC and ETH leading the gains.',
        type: NotifType.portfolio,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        isRead: true,
        actionLabel: 'View Portfolio',
        icon: Icons.pie_chart_rounded,
        color: AppColors.primary,
      ),
      AppNotification(
        id: '6',
        title: '📉 SOL Price Drop',
        body: 'Solana dropped below your alert price of \$180. Current: \$178.54.',
        type: NotifType.priceAlert,
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        isRead: true,
        actionLabel: 'View Chart',
        icon: Icons.trending_down_rounded,
        color: AppColors.red,
      ),
      AppNotification(
        id: '7',
        title: '🔐 New Login Detected',
        body: 'A new sign-in to your SeeTru account from Lagos, Nigeria.',
        type: NotifType.system,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        icon: Icons.security_rounded,
        color: AppColors.orange,
      ),
    ];

    _updateUnreadCount();
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  List<AppNotification> get filteredNotifications {
    if (activeFilter.value == 'All') return notifications;
    final typeMap = {
      'Prices': NotifType.priceAlert,
      'VC Deals': NotifType.vcDeal,
      'Social': NotifType.social,
      'System': NotifType.system,
    };
    final type = typeMap[activeFilter.value];
    if (type == null) return notifications;
    return notifications.where((n) => n.type == type).toList();
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      notifications.refresh();
      _updateUnreadCount();
    }
  }

  void markAllAsRead() {
    notifications.value =
        notifications.map((n) => n.copyWith(isRead: true)).toList();
    _updateUnreadCount();
  }

  void setFilter(String filter) => activeFilter.value = filter;

  String timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class AppColors {
  static const green = Color(0xFF00C48C);
  static const red = Color(0xFFFF6B6B);
  static const accent = Color(0xFF4C6FFF);
  static const teal = Color(0xFF00C6CF);
  static const orange = Color(0xFFFFAA38);
  static const primary = Color(0xFF1A2B6D);
}