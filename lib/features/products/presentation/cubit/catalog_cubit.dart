import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/paginated_products.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/usecases/get_product_categories.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/get_products_by_category.dart';
import 'catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit({
    required this.getProducts,
    required this.getProductsByCategory,
    required this.getCategories,
  }) : super(const CatalogState());

  final GetProducts getProducts;
  final GetProductsByCategory getProductsByCategory;
  final GetProductCategories getCategories;

  static const _pageLimit = ApiConstants.defaultPageLimit;
  int _skip = 0;

  Future<void> loadInitial() async {
    emit(const CatalogState(status: CatalogStatus.loading));
    _skip = 0;

    // Fired together, not awaited one after the other: the full
    // category list and the first page of products don't depend on
    // each other, so there's no reason to pay for them sequentially.
    final productsFuture = getProducts(const GetProductsParams(skip: 0));
    final categoriesFuture = getCategories(const NoParams());

    final productsResult = await productsFuture;
    final categoriesResult = await categoriesFuture;

    productsResult.fold(
      (failure) => emit(CatalogState(status: CatalogStatus.error, failure: failure)),
      (page) {
        // Categories are supplementary — if they fail to load, degrade
        // to an empty filter row instead of blocking the whole catalog.
        final categories = categoriesResult.fold(
          (_) => const <ProductCategory>[],
          (categories) => categories,
        );
        emit(CatalogState(
          status: CatalogStatus.loaded,
          products: page.products,
          categories: categories,
          hasMore: page.hasMore,
          isOffline: page.isFromCache,
        ));
      },
    );
  }

  /// Pull-to-refresh and the "reintentar" action both call this. Reloads
  /// whatever scope is currently active — "Todo" or the selected
  /// category — not just the unfiltered listing.
  Future<void> refresh() async {
    final category = state.selectedCategory;
    _skip = 0;

    final result = await _fetchFirstPage(category);
    result.fold(
      (failure) => emit(state.copyWith(isOffline: failure is NetworkFailure)),
      (page) => emit(state.copyWith(
        products: page.products,
        hasMore: page.hasMore,
        isOffline: page.isFromCache,
      )),
    );
  }

  Future<void> loadMore() async {
    if (state.status != CatalogStatus.loaded) return;
    if (state.isLoadingMore || !state.hasMore) return;

    emit(state.copyWith(isLoadingMore: true));
    final nextSkip = _skip + _pageLimit;

    final result = await _fetchPage(state.selectedCategory, skip: nextSkip);
    result.fold(
      (failure) {
        emit(state.copyWith(
          isLoadingMore: false,
          isOffline: failure is NetworkFailure,
        ));
      },
      (page) {
        _skip = nextSkip;
        emit(state.copyWith(
          products: [...state.products, ...page.products],
          hasMore: page.hasMore,
          isLoadingMore: false,
          isOffline: page.isFromCache,
        ));
      },
    );
  }

  Future<void> selectCategory(String? category) async {
    final next = category == state.selectedCategory ? null : category;
    final previousProducts = state.products;
    final previousHasMore = state.hasMore;
    final previousCategory = state.selectedCategory;

    emit(state.copyWith(
      selectedCategory: next,
      clearSelectedCategory: next == null,
      isSwitchingCategory: true,
    ));
    _skip = 0;

    final result = await _fetchFirstPage(next);
    result.fold(
      (failure) {
        emit(state.copyWith(
          products: previousProducts,
          hasMore: previousHasMore,
          selectedCategory: previousCategory,
          clearSelectedCategory: previousCategory == null,
          isSwitchingCategory: false,
          isOffline: failure is NetworkFailure,
        ));
      },
      (page) => emit(state.copyWith(
        products: page.products,
        hasMore: page.hasMore,
        isSwitchingCategory: false,
        isOffline: page.isFromCache,
      )),
    );
  }

  Future<Either<Failure, PaginatedProducts>> _fetchFirstPage(String? category) {
    return _fetchPage(category, skip: 0);
  }

  Future<Either<Failure, PaginatedProducts>> _fetchPage(String? category, {required int skip}) {
    return category == null
        ? getProducts(GetProductsParams(skip: skip))
        : getProductsByCategory(GetProductsByCategoryParams(category: category, skip: skip));
  }
}
