import '../../../../core/utils/typedefs.dart';
import '../entities/paginated_products.dart';
import '../entities/product.dart';
import '../entities/product_category.dart';

/// Domain-facing contract for everything related to products. Data provides
/// the implementation (`ProductRepositoryImpl`); Domain only ever sees this
/// interface, which keeps it ignorant of Dio, DummyJSON, or any other
/// networking detail.
abstract class ProductRepository {
  /// Paginated product listing — `GET /products?limit=&skip=`.
  ResultFuture<PaginatedProducts> getProducts({
    required int limit,
    required int skip,
  });

  /// Paginated search — `GET /products/search?q=&limit=&skip=`.
  ResultFuture<PaginatedProducts> searchProducts({
    required String query,
    required int limit,
    required int skip,
  });

  /// Paginated listing scoped to one category —
  /// `GET /products/category/{category}?limit=&skip=`. Used instead of
  /// client-side filtering [getProducts]'s results so a category the
  /// user hasn't scrolled to yet still shows its full product list.
  ResultFuture<PaginatedProducts> getProductsByCategory({
    required String category,
    required int limit,
    required int skip,
  });

  /// Single product — `GET /products/{id}`.
  ResultFuture<Product> getProductById(int id);

  /// The full category list — `GET /products/categories`. Independent of
  /// pagination: unlike [getProducts], this always returns every
  /// category DummyJSON knows about in one call.
  ResultFuture<List<ProductCategory>> getCategories();
}
