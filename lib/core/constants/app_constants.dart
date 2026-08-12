/// Centralized configuration for the DummyJSON API.
///
/// Nothing outside `core/network` and the `data` layer of each feature
/// should ever hardcode a URL — always go through here. The base URL
/// itself is environment-dependent (dev/qa) and lives in
/// `EnvironmentConfig.apiBaseUrl`, not here — this class only holds what
/// never changes between flavors: paths, timeouts, pagination defaults.
class ApiConstants {
  ApiConstants._();

  static const String products = '/products';
  static const String productsSearch = '/products/search';
  static String productDetail(int id) => '/products/$id';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Default page size used across paginated listings.
  static const int defaultPageLimit = 10;
}
