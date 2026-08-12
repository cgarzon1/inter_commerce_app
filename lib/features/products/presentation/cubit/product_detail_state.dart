import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/product.dart';

enum ProductDetailStatus { loading, loaded, error }


class ProductDetailState extends Equatable {
  const ProductDetailState({
    this.status = ProductDetailStatus.loading,
    this.product,
    this.isSaved = false,
    this.failure,
  });

  final ProductDetailStatus status;
  final Product? product;
  final bool isSaved;
  final Failure? failure;

  ProductDetailState copyWith({
    ProductDetailStatus? status,
    Product? product,
    bool? isSaved,
    Failure? failure,
  }) {
    return ProductDetailState(
      status: status ?? this.status,
      product: product ?? this.product,
      isSaved: isSaved ?? this.isSaved,
      // Deliberately not `failure ?? this.failure` — see CatalogState.
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [status, product, isSaved, failure];
}
