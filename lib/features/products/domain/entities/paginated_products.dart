import 'package:equatable/equatable.dart';

import 'product.dart';

/// One "page" of products, as returned by both the listing and the search
class PaginatedProducts extends Equatable {
  final List<Product> products;
  final int total;
  final int skip;
  final int limit;

  const PaginatedProducts({
    required this.products,
    required this.total,
    required this.skip,
    required this.limit,
  });

  bool get hasMore => skip + products.length < total;

  @override
  List<Object?> get props => [products, total, skip, limit];
}
