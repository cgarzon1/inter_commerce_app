import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inter_commerce_app_design_system/inter_commerce_app_design_system.dart';

import '../../../../core/DI/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/product.dart';
import '../cubit/catalog_cubit.dart';
import '../cubit/catalog_state.dart';
import '../utils/category_label.dart';
import '../widgets/product_network_image.dart';
import 'product_detail_page.dart';


class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CatalogCubit>()..loadInitial(),
      child: const _CatalogView(),
    );
  }
}

class _CatalogView extends StatefulWidget {
  const _CatalogView();

  @override
  State<_CatalogView> createState() => _CatalogViewState();
}

class _CatalogViewState extends State<_CatalogView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    const threshold = 320.0;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - threshold) {
      context.read<CatalogCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InterCommerceScaffold(
      showBackButton: false,
      titleWidget: InterCommerceEyebrow(l10n.catalogEyebrow),
      body: BlocBuilder<CatalogCubit, CatalogState>(
        builder: (context, state) {
          return switch (state.status) {
            CatalogStatus.initial || CatalogStatus.loading => const _CatalogSkeleton(),
            CatalogStatus.error => _CatalogErrorView(failure: state.failure),
            CatalogStatus.loaded =>
              _CatalogLoadedView(state: state, scrollController: _scrollController),
          };
        },
      ),
    );
  }
}

class _CatalogLoadedView extends StatelessWidget {
  const _CatalogLoadedView({required this.state, required this.scrollController});

  final CatalogState state;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final products = state.products;
    final selectedCategory = state.selectedCategory;
    final title = selectedCategory != null ? _labelFor(selectedCategory) : l10n.catalogTitle;

    return Column(
      children: [
        // Fixed header: title + offline banner + category filter. Never
        // scrolls away — only the product grid below does.
        Padding(
          padding: const EdgeInsets.fromLTRB(
            InterCommerceSpacing.lg,
            InterCommerceSpacing.md,
            InterCommerceSpacing.lg,
            InterCommerceSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: InterCommerceSpacing.md),
              AnimatedSwitcher(
                duration: InterCommerceDurations.standard,
                child: state.isOffline
                    ? Padding(
                        key: const ValueKey('offline'),
                        padding: const EdgeInsets.only(bottom: InterCommerceSpacing.md),
                        child: InterCommerceOfflineBanner(message: l10n.catalogOfflineMessage),
                      )
                    : const SizedBox.shrink(key: ValueKey('online')),
              ),
              if (state.categories.isNotEmpty)
                InterCommerceChipGroup<String?>(
                  options: [null, ...state.categories.map((category) => category.slug)],
                  labelBuilder: (slug) => slug == null ? l10n.catalogFilterAll : _labelFor(slug),
                  value: selectedCategory,
                  onChanged: (slug) => context.read<CatalogCubit>().selectCategory(slug),
                ),
            ],
          ),
        ),
        Expanded(
          child: state.isSwitchingCategory
              ? const _ProductGridSkeleton()
              : RefreshIndicator(
                  onRefresh: () => context.read<CatalogCubit>().refresh(),
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      if (products.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: InterCommerceEmptyState(
                            icon: const Icon(Icons.inventory_2_outlined),
                            title: l10n.catalogEmptyTitle,
                            message: l10n.catalogEmptyMessage,
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            InterCommerceSpacing.lg,
                            0,
                            InterCommerceSpacing.lg,
                            InterCommerceSpacing.xxl,
                          ),
                          sliver: SliverGrid(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: InterCommerceSpacing.lg,
                              crossAxisSpacing: InterCommerceSpacing.md,
                              childAspectRatio: 0.62,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final product = products[index];
                                return InterCommerceProductCard(
                                  image: ProductNetworkImage(url: product.thumbnail),
                                  category: _labelFor(product.category),
                                  title: product.title,
                                  price: product.price,
                                  compareAtPrice: product.discountPercentage > 0
                                      ? product.price / (1 - product.discountPercentage / 100)
                                      : null,
                                  onTap: () => _openDetail(context, product),
                                );
                              },
                              childCount: products.length,
                            ),
                          ),
                        ),
                      if (state.isLoadingMore)
                        const SliverPadding(
                          padding: EdgeInsets.symmetric(vertical: InterCommerceSpacing.lg),
                          sliver: SliverToBoxAdapter(
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }


  String _labelFor(String slug) {
    for (final category in state.categories) {
      if (category.slug == slug) return category.name;
    }
    return formatCategoryLabel(slug);
  }

  void _openDetail(BuildContext context, Product product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(productId: product.id, initialProduct: product),
      ),
    );
  }
}

class _CatalogSkeleton extends StatelessWidget {
  const _CatalogSkeleton();

  @override
  Widget build(BuildContext context) {
    return const _ProductGridSkeleton(padding: EdgeInsets.all(InterCommerceSpacing.lg));
  }
}


class _ProductGridSkeleton extends StatelessWidget {
  const _ProductGridSkeleton({
    this.padding = const EdgeInsets.fromLTRB(
      InterCommerceSpacing.lg,
      0,
      InterCommerceSpacing.lg,
      InterCommerceSpacing.xxl,
    ),
  });

  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: padding,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: InterCommerceSpacing.lg,
        crossAxisSpacing: InterCommerceSpacing.md,
        childAspectRatio: 0.62,
      ),
      itemCount: 6,
      itemBuilder: (context, index) => const InterCommerceProductCardSkeleton(),
    );
  }
}

class _CatalogErrorView extends StatelessWidget {
  const _CatalogErrorView({required this.failure});

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
        onPressed: () => context.read<CatalogCubit>().loadInitial(),
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
