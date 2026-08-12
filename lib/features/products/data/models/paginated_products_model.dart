import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/paginated_products.dart';
import 'product_model.dart';

/// DTO for the `{ products, total, skip, limit }` envelope shared by both
/// the listing and the search endpoints.
class PaginatedProductsModel extends PaginatedProducts {
  const PaginatedProductsModel({
    required super.products,
    required super.total,
    required super.skip,
    required super.limit,
  });

  factory PaginatedProductsModel.fromJson(JSON json) {
    return PaginatedProductsModel(
      products: (json['products'] as List<dynamic>? ?? const [])
          .map((e) => ProductModel.fromJson(e as JSON))
          .toList(),
      total: json['total'] as int? ?? 0,
      skip: json['skip'] as int? ?? 0,
      limit: json['limit'] as int? ?? 0,
    );
  }
}
