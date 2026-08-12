import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inter_commerce_app_design_system/inter_commerce_app_design_system.dart';

import '../../../../core/DI/injection_container.dart';
import '../../../../core/error/failures.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/product.dart';
import '../cubit/search_cubit.dart';
import '../cubit/search_state.dart';
import '../pages/product_detail_page.dart';
import '../utils/category_label.dart';
import '../widgets/product_network_image.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SearchCubit>(),
      child: const _SearchView(),
    );
  }
}

class _SearchView extends StatefulWidget {
  const _SearchView();

  @override
  State<_SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<_SearchView> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Only listened to for the clear button's visibility — the actual
    // search is driven by onChanged below, not this.
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    context.read<SearchCubit>().queryChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return InterCommerceScaffold(
      showBackButton: false,
      titleWidget: InterCommerceEyebrow(l10n.searchEyebrow),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              InterCommerceSpacing.lg,
              InterCommerceSpacing.md,
              InterCommerceSpacing.lg,
              InterCommerceSpacing.sm,
            ),
            child: InterCommerceTextField(
              controller: _controller,
              hintText: l10n.searchFieldHint,
              autofocus: true,
              textInputAction: TextInputAction.search,
              leadingIcon: const Icon(Icons.search_rounded, size: 20),
              trailingIcon: _controller.text.isEmpty
                  ? null
                  : InkWell(
                      onTap: _clear,
                      customBorder: const CircleBorder(),
                      child: Semantics(
                        button: true,
                        label: l10n.searchClearField,
                        child: const Icon(Icons.close_rounded, size: 18),
                      ),
                    ),
              onChanged: (value) => context.read<SearchCubit>().queryChanged(value),
            ),
          ),
          Expanded(
            child: BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                return switch (state.status) {
                  SearchStatus.initial => _SearchPrompt(l10n: l10n),
                  SearchStatus.loading => const _SearchSkeleton(),
                  SearchStatus.error => _SearchErrorView(failure: state.failure),
                  SearchStatus.loaded => state.results.isEmpty
                      ? _SearchEmptyView(l10n: l10n)
                      : _SearchResults(results: state.results),
                };
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({required this.results});

  final List<Product> results;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: InterCommerceSpacing.lg),
      itemCount: results.length,
      separatorBuilder: (_, _) => Divider(color: context.interCommerceColors.divider),
      itemBuilder: (context, index) {
        final product = results[index];
        return InterCommerceProductListTile(
          image: ProductNetworkImage(url: product.thumbnail),
          category: formatCategoryLabel(product.category),
          title: product.title,
          description: product.description,
          price: product.price,
          compareAtPrice: product.discountPercentage > 0
              ? product.price / (1 - product.discountPercentage / 100)
              : null,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailPage(productId: product.id, initialProduct: product),
            ),
          ),
        );
      },
    );
  }
}

class _SearchPrompt extends StatelessWidget {
  const _SearchPrompt({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InterCommerceEmptyState(
        icon: const Icon(Icons.search_rounded),
        title: l10n.searchInitialTitle,
        message: l10n.searchInitialMessage,
      ),
    );
  }
}

class _SearchEmptyView extends StatelessWidget {
  const _SearchEmptyView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InterCommerceEmptyState(
        icon: const Icon(Icons.search_off_rounded),
        title: l10n.commonNoResults,
        message: l10n.searchEmptyMessage,
      ),
    );
  }
}

class _SearchSkeleton extends StatelessWidget {
  const _SearchSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: InterCommerceSpacing.lg,
        vertical: InterCommerceSpacing.sm,
      ),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: InterCommerceSpacing.md),
      itemBuilder: (context, index) => const _SearchResultSkeletonRow(),
    );
  }
}

class _SearchResultSkeletonRow extends StatelessWidget {
  const _SearchResultSkeletonRow();

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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(InterCommerceRadius.md),
          child: SizedBox.square(
            dimension: InterCommerceControlSize.thumbnailSmall,
            child: DecoratedBox(decoration: BoxDecoration(color: semanticColors.skeletonBase)),
          ),
        ),
        const SizedBox(width: InterCommerceSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bar(64, 10),
              const SizedBox(height: InterCommerceSpacing.xs),
              bar(160, 14),
              const SizedBox(height: InterCommerceSpacing.xs),
              bar(80, 12),
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchErrorView extends StatelessWidget {
  const _SearchErrorView({required this.failure});

  final Failure? failure;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: InterCommerceEmptyState(
        icon: Icon(_iconFor(failure)),
        title: _messageFor(failure, l10n),
        action: InterCommerceButton(
          label: l10n.commonRetry,
          expand: false,
          onPressed: () => context.read<SearchCubit>().retry(),
        ),
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
