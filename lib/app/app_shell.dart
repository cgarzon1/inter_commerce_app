import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inter_commerce_app_design_system/inter_commerce_app_design_system.dart';

import '../features/cart/presentation/cubit/cart_cubit.dart';
import '../features/cart/presentation/cubit/cart_state.dart';
import '../features/cart/presentation/pages/cart_page.dart';
import '../features/products/presentation/pages/catalog_page.dart';
import '../l10n/generated/app_localizations.dart';


class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  void _goToShop() => setState(() => _index = 0);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final screens = [
      const CatalogPage(),
      _ComingSoonPage(icon: Icons.search_rounded),
      CartPage(onExploreCatalog: _goToShop),
      _ComingSoonPage(icon: Icons.person_outline_rounded),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        buildWhen: (previous, current) => previous.cart.itemCount != current.cart.itemCount,
        builder: (context, cartState) {
          return InterCommerceBottomNavBar(
            currentIndex: _index,
            onTap: (index) => setState(() => _index = index),
            items: [
              InterCommerceNavItem(label: l10n.navShop, icon: Icons.storefront_outlined),
              InterCommerceNavItem(label: l10n.navSearch, icon: Icons.search_rounded),
              InterCommerceNavItem(
                label: l10n.navCart,
                icon: Icons.shopping_bag_outlined,
                badgeCount: cartState.cart.itemCount,
              ),
              InterCommerceNavItem(label: l10n.navAccount, icon: Icons.person_outline_rounded),
            ],
          );
        },
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
