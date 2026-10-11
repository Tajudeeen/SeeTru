import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../workspace_controller.dart';
import 'components.dart';
import 'markets.dart';
import 'portfolio.dart';
import 'research.dart';
import 'settings.dart';
import 'alerts.dart';

ThemeData buildTheme(bool dark) {
  final scheme = ColorScheme.fromSeed(
    seedColor: accent,
    brightness: dark ? Brightness.dark : Brightness.light,
    primary: dark ? accent : const Color(0xFF176443),
    surface: dark ? const Color(0xFF131E28) : Colors.white,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: 'Satoshi',
    scaffoldBackgroundColor: dark
        ? const Color(0xFF0B141C)
        : const Color(0xFFF3F6F6),
  );
  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      headlineLarge: base.textTheme.headlineLarge?.copyWith(
        fontFamily: 'ClashDisplay',
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontFamily: 'ClashDisplay',
        fontWeight: FontWeight.w600,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: base.scaffoldBackgroundColor,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(backgroundColor: scheme.surface),
  );
}

class SeeTruApp extends StatelessWidget {
  const SeeTruApp({super.key});
  @override
  Widget build(BuildContext context) {
    final c = Get.find<WorkspaceController>();
    return Obx(
      () => GetMaterialApp(
        title: 'SeeTru',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(c.workspace.value.dark),
        home: const AppShell(),
      ),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});
  static const labels = ['Markets', 'Watchlist', 'Portfolio', 'Research'];
  static const icons = [
    Icons.grid_view_rounded,
    Icons.star_outline,
    Icons.pie_chart_outline,
    Icons.auto_awesome_outlined,
  ];
  @override
  Widget build(BuildContext context) {
    final c = Get.find<WorkspaceController>();
    return Obx(() {
      if (!c.workspace.value.onboarded) {
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 650),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.visibility_outlined,
                        size: 60,
                        color: accent,
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'SEETRU / CRYPTO INTELLIGENCE',
                        style: TextStyle(letterSpacing: 2, color: accent),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'A clearer view.\nA better decision.',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineLarge?.copyWith(fontSize: 48),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Follow the market. Understand your holdings. Keep research grounded in its source.',
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 32),
                      const Panel(
                        child: Text(
                          'Your workspace starts empty and saves on this device. Accounts are optional. SeeTru records your trades; it does not execute them.',
                        ),
                      ),
                      const SizedBox(height: 28),
                      FilledButton(
                        onPressed: () => action(
                          () => c.change((w) => w.copy(onboarded: true)),
                        ),
                        child: const Text('Open my workspace'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
      final wide = MediaQuery.sizeOf(context).width >= 850;
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'SeeTru',
            style: TextStyle(
              fontFamily: 'ClashDisplay',
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Search coins',
              onPressed: () => showCoinSearch(context),
              icon: const Icon(Icons.search),
            ),
            IconButton(
              tooltip: 'Price alerts',
              onPressed: () => Get.to(() => const AlertsPage()),
              icon: Badge(
                isLabelVisible: c.workspace.value.alerts.any(
                  (a) => a.triggeredAt != null && !a.read,
                ),
                child: const Icon(Icons.notifications_none),
              ),
            ),
            IconButton(
              tooltip: 'Settings',
              onPressed: () => Get.to(() => const SettingsPage()),
              icon: const Icon(Icons.tune),
            ),
            const SizedBox(width: 12),
          ],
        ),
        body: SafeArea(
          child: Row(
            children: [
              if (wide)
                NavigationRail(
                  selectedIndex: c.tab.value,
                  onDestinationSelected: (i) => c.tab.value = i,
                  labelType: NavigationRailLabelType.all,
                  destinations: List.generate(
                    4,
                    (i) => NavigationRailDestination(
                      icon: Icon(icons[i]),
                      label: Text(labels[i]),
                    ),
                  ),
                ),
              Expanded(
                child: IndexedStack(
                  index: c.tab.value,
                  children: const [
                    MarketsPage(),
                    MarketsPage(watchlist: true),
                    PortfolioPage(),
                    ResearchPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: wide
            ? null
            : NavigationBar(
                selectedIndex: c.tab.value,
                onDestinationSelected: (i) => c.tab.value = i,
                destinations: List.generate(
                  4,
                  (i) => NavigationDestination(
                    icon: Icon(icons[i]),
                    label: labels[i],
                  ),
                ),
              ),
      );
    });
  }
}
