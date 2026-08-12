import 'package:flutter/material.dart';
import 'package:inter_commerce_app_design_system/inter_commerce_app_design_system.dart';

import '../features/products/presentation/pages/catalog_page.dart';
import '../l10n/generated/app_localizations.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final screens = [
      const CatalogPage(),
      _ComingSoonPage(icon: Icons.search_rounded),
      _ComingSoonPage(icon: Icons.shopping_bag_outlined),
      _ComingSoonPage(icon: Icons.person_outline_rounded),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: InterCommerceBottomNavBar(
        currentIndex: _index,
        onTap: (index) => setState(() => _index = index),
        items: [
          InterCommerceNavItem(label: l10n.navShop, icon: Icons.storefront_outlined),
          InterCommerceNavItem(label: l10n.navSearch, icon: Icons.search_rounded),
          InterCommerceNavItem(label: l10n.navCart, icon: Icons.shopping_bag_outlined),
          InterCommerceNavItem(label: l10n.navAccount, icon: Icons.person_outline_rounded),
        ],
      ),
    );
  }
}

class _ComingSoonPage extends StatelessWidget {
  const _ComingSoonPage({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InterCommerceScaffold(
      showBackButton: false,
      body: Center(
        child: InterCommerceEmptyState(
          icon: Icon(icon),
          title: l10n.comingSoonTitle,
          message: l10n.comingSoonMessage,
        ),
      ),
    );
  }
}
