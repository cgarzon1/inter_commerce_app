import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inter_commerce_app_design_system/inter_commerce_app_design_system.dart';

import '../../../../core/DI/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/product.dart';
import '../cubit/product_detail_cubit.dart';
import '../cubit/product_detail_state.dart';
import '../widgets/product_image_carousel.dart';


class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key, required this.productId, this.initialProduct});


  final int productId;
  final Product? initialProduct;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductDetailCubit>()..load(productId, initial: initialProduct),
      child: const _ProductDetailView(),
    );
  }
}

class _ProductDetailView extends StatefulWidget {
  const _ProductDetailView();

  @override
  State<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<_ProductDetailView> {
  InterCommerceButtonState _ctaState = InterCommerceButtonState.idle;

  Future<void> _addToCart() async {
    // TODO(cart): wire to the Carrito de Compras module — for now this
    // only plays the button's own confirm microinteraction.
    setState(() => _ctaState = InterCommerceButtonState.pending);
    await Future.delayed(InterCommerceDurations.addToCartPending);
    if (!mounted) return;
    setState(() => _ctaState = InterCommerceButtonState.success);
    await Future.delayed(InterCommerceDurations.addToCartSuccessHold);
    if (!mounted) return;
    setState(() => _ctaState = InterCommerceButtonState.idle);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductDetailCubit, ProductDetailState>(
      builder: (context, state) {
        final product = state.product;
        if (product == null) {
          return Scaffold(
            body: SafeArea(
              child: state.status == ProductDetailStatus.error
                  ? _ErrorView(failure: state.failure)
                  : const _DetailSkeleton(),
            ),
          );
        }
        return _DetailContent(
          product: product,
          isSaved: state.isSaved,
          ctaState: _ctaState,
          onAddToCart: product.isInStock ? _addToCart : null,
        );
      },
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({
    required this.product,
    required this.isSaved,
    required this.ctaState,
    required this.onAddToCart,
  });

  final Product product;
  final bool isSaved;
  final InterCommerceButtonState ctaState;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final topInset = MediaQuery.of(context).padding.top;
    final images = product.images.isEmpty ? [product.thumbnail] : product.images;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: ProductImageCarousel(images: images)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  InterCommerceSpacing.lg,
                  InterCommerceSpacing.md,
                  InterCommerceSpacing.lg,
                  InterCommerceSpacing.xxxl,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InterCommerceEyebrow(product.category),
                      const SizedBox(height: 2),
                      Text(product.title, style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: InterCommerceSpacing.xs),
                      InterCommercePriceText(
                        product.price,
                        compareAtAmount: product.discountPercentage > 0
                            ? product.price / (1 - product.discountPercentage / 100)
                            : null,
                        size: InterCommerceFontSize.titleLarge,
                      ),
                      if (!product.isInStock) ...[
                        const SizedBox(height: InterCommerceSpacing.xxs),
                        Text(
                          l10n.detailOutOfStock,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Theme.of(context).colorScheme.error),
                        ),
                      ],
                      const SizedBox(height: InterCommerceSpacing.md),
                      const Divider(),
                      InterCommerceExpandableSection(
                        title: l10n.detailDescriptionTitle,
                        initiallyExpanded: true,
                        child: Text(product.description),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: topInset + InterCommerceSpacing.sm,
            left: InterCommerceSpacing.lg,
            child: InterCommerceIconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => Navigator.maybePop(context),
              semanticLabel: l10n.commonBack,
            ),
          ),
          Positioned(
            top: topInset + InterCommerceSpacing.sm,
            right: InterCommerceSpacing.lg,
            child: _SaveButton(
              saved: isSaved,
              onPressed: () => context.read<ProductDetailCubit>().toggleSaved(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(top: BorderSide(color: InterCommerceSemanticColors.of(context).hairline)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              InterCommerceSpacing.lg,
              InterCommerceSpacing.md,
              InterCommerceSpacing.lg,
              InterCommerceSpacing.md,
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InterCommerceEyebrow(l10n.detailTotal),
                    InterCommercePriceText(product.price, size: InterCommerceFontSize.titleMedium),
                  ],
                ),
                const SizedBox(width: InterCommerceSpacing.md),
                Expanded(
                  child: InterCommerceButton(
                    label: l10n.detailAddToCart,
                    pendingLabel: l10n.detailAddingToCart,
                    successLabel: l10n.detailAddedToCart,
                    state: ctaState,
                    onPressed: onAddToCart,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.saved, required this.onPressed});

  final bool saved;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final semanticColors = InterCommerceSemanticColors.of(context);

    return Semantics(
      button: true,
      selected: saved,
      label: saved ? l10n.detailSaved : l10n.detailSave,
      child: Material(
        color: semanticColors.glassSurface,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: InterCommerceControlSize.minimumTouchTarget),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: InterCommerceSpacing.md),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    size: 16,
                    color: colors.onSurface,
                  ),
                  const SizedBox(width: InterCommerceSpacing.xxs),
                  Text(saved ? l10n.detailSaved : l10n.detailSave,
                      style: InterCommerceTypography.eyebrow(colors.onSurface)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    final semanticColors = InterCommerceSemanticColors.of(context);

    Widget bar(double width, double height) => DecoratedBox(
          decoration: BoxDecoration(
            color: semanticColors.skeletonBase,
            borderRadius: BorderRadius.circular(InterCommerceRadius.xs),
          ),
          child: SizedBox(width: width, height: height),
        );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const InterCommerceShimmerBox(height: 420, borderRadius: 0),
          Padding(
            padding: const EdgeInsets.all(InterCommerceSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                bar(72, 10),
                const SizedBox(height: InterCommerceSpacing.sm),
                bar(220, 20),
                const SizedBox(height: InterCommerceSpacing.sm),
                bar(100, 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.failure});

  final Failure? failure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InterCommerceEmptyState(
      icon: Icon(_iconFor(failure)),
      title: _messageFor(failure, l10n),
      action: InterCommerceButton(
        label: l10n.commonRetry,
        expand: false,
        onPressed: () => Navigator.maybePop(context),
      ),
    );
  }

  IconData _iconFor(Failure? failure) {
    return switch (failure) {
      NetworkFailure() => Icons.wifi_off_rounded,
      _ => Icons.error_outline_rounded,
    };
  }

  String _messageFor(Failure? failure, AppLocalizations l10n) {
    return switch (failure) {
      NetworkFailure() => l10n.errorNetwork,
      ServerFailure() => l10n.errorServer,
      CacheFailure() => l10n.errorCache,
      ValidationFailure() => l10n.errorValidation,
      _ => l10n.errorUnexpected,
    };
  }
}
