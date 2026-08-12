/// Centralized configuration for the DummyJSON API.
class ApiConstants {
  ApiConstants._();

  static const String products = '/products';
  static const String productsSearch = '/products/search';
  static const String productCategories = '/products/categories';
  static String productDetail(int id) => '/products/$id';
  static String productsByCategory(String category) => '/products/category/$category';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Default page size used across paginated listings.
  static const int defaultPageLimit = 10;
}
