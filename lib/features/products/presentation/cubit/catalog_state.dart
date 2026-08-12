import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';

enum CatalogStatus { initial, loading, loaded, error }


class CatalogState extends Equatable {
  const CatalogState({
    this.status = CatalogStatus.initial,
    this.products = const [],
    this.categories = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.isSwitchingCategory = false,
    this.isOffline = false,
    this.selectedCategory,
    this.failure,
  });

  final CatalogStatus status;


  final List<Product> products;

  final List<ProductCategory> categories;

  final bool hasMore;
  final bool isLoadingMore;

  final bool isSwitchingCategory;

  final bool isOffline;

  final String? selectedCategory;
  final Failure? failure;

  CatalogState copyWith({
    CatalogStatus? status,
    List<Product>? products,
    List<ProductCategory>? categories,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isSwitchingCategory,
    bool? isOffline,
    String? selectedCategory,
    bool clearSelectedCategory = false,
    Failure? failure,
  }) {
    return CatalogState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isSwitchingCategory: isSwitchingCategory ?? this.isSwitchingCategory,
      isOffline: isOffline ?? this.isOffline,
      selectedCategory:
          clearSelectedCategory ? null : (selectedCategory ?? this.selectedCategory),

      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        categories,
        hasMore,
        isLoadingMore,
        isSwitchingCategory,
        isOffline,
        selectedCategory,
        failure,
      ];
}
