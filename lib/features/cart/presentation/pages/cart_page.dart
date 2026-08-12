import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inter_commerce_app_design_system/inter_commerce_app_design_system.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../products/presentation/widgets/product_network_image.dart';
import '../../domain/entities/cart_totals.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';
import '../widgets/promo_code_field.dart';


class CartPage extends StatelessWidget {
  const CartPage({super.key, this.onExploreCatalog});

  final VoidCallback? onExploreCatalog;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InterCommerceScaffold(
      showBackButton: false,
      titleWidget: InterCommerceEyebrow(l10n.cartEyebrow),
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          if (state.cart.isEmpty) {
            return InterCommerceEmptyState(
              icon: const Icon(Icons.shopping_bag_outlined),
              title: l10n.cartEmptyTitle,
              message: l10n.cartEmptyMessage,
              action: onExploreCatalog == null
                  ? null
                  : InterCommerceButton(
                      label: l10n.cartExploreCatalog,
                      expand: false,
                      onPressed: onExploreCatalog,
                    ),
            );
          }
          return _CartContent(state: state);
        },
      ),
    );
  }
}

class _CartContent extends StatelessWidget {
  const _CartContent({required this.state});

  final CartState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cart = state.cart;
    final totals = state.totals;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        InterCommerceSpacing.lg,
        InterCommerceSpacing.md,
        InterCommerceSpacing.lg,
        InterCommerceSpacing.xxl,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l10n.cartTitle, style: Theme.of(context).textTheme.displaySmall),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                l10n.cartItemsCount(cart.itemCount),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: InterCommerceSpacing.lg),
        for (final item in cart.items) ...[
          InterCommerceCartLineItem(
            image: ProductNetworkImage(url: item.thumbnail),
            title: item.title,
            variantLabel: item.subtitle,
            price: item.unitPrice,
            quantity: item.quantity,
            removeSemanticLabel: l10n.cartRemoveItem,
            decrementSemanticLabel: l10n.cartDecrementQuantity,
            incrementSemanticLabel: l10n.cartIncrementQuantity,
            onQuantityChanged: (quantity) =>
                context.read<CartCubit>().changeQuantity(item.productId, quantity),
            onRemove: () => context.read<CartCubit>().removeProduct(item.productId),
          ),
          Divider(color: context.interCommerceColors.divider),
        ],
        const SizedBox(height: InterCommerceSpacing.xs),
        if (cart.promo != null)
          InterCommercePromoBadge(
            code: cart.promo!.code,
            detail: l10n.cartPromoApplied(cart.promo!.discountPercentage.round()),
            onRemove: () => context.read<CartCubit>().removePromo(),
          )
        else
          PromoCodeField(
            hintText: l10n.cartPromoHint,
            applyLabel: l10n.cartPromoApply,
            errorText: state.promoError == null ? null : l10n.cartPromoInvalid,
            onApply: (code) => context.read<CartCubit>().applyPromo(code),
          ),
        const SizedBox(height: InterCommerceSpacing.xl),
        if (totals != null) _OrderSummary(totals: totals, promoCode: cart.promo?.code),
        const SizedBox(height: InterCommerceSpacing.xl),
        InterCommerceButton(
          label: l10n.cartCheckout,
          onPressed: () => _handleCheckout(context),
        ),
      ],
    );
  }

  Future<void> _handleCheckout(BuildContext context) async {
    final cubit = context.read<CartCubit>();
    final success = await cubit.checkout();
    if (!context.mounted || !success) return;

    final l10n = AppLocalizations.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle_rounded),
        title: Text(l10n.cartOrderSuccessTitle),
        content: Text(l10n.cartOrderSuccessMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.commonAccept),
          ),
        ],
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.totals, required this.promoCode});

  final CartTotals totals;
  final String? promoCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InterCommerceOrderSummary(
      totalLabel: l10n.cartTotal,
      total: totals.total,
      rows: [
        InterCommerceSummaryRow(label: l10n.cartSubtotal, amount: totals.subtotal),
        InterCommerceSummaryRow(
          label: l10n.cartTax((totals.taxRate * 100).round()),
          amount: totals.taxAmount,
        ),
        if (totals.discountAmount > 0)
          InterCommerceSummaryRow(
            label: l10n.cartDiscount(promoCode ?? ''),
            amount: -totals.discountAmount,
            emphasis: true,
          ),
        InterCommerceSummaryRow(
          label: l10n.cartShippingLabel,
          valueLabel: totals.shippingAmount == 0 ? l10n.cartShippingFree : null,
          amount: totals.shippingAmount == 0 ? null : totals.shippingAmount,
        ),
      ],
    );
  }
}
