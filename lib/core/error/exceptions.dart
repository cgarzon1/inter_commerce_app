/// Exceptions raised by the Data layer (datasources).
///
/// These never cross into Domain or Presentation: the repository
/// implementation catches them and maps each one to its matching
/// [Failure] (see `core/error/failures.dart`).
library;

/// Thrown by a remote datasource when the API call fails: non-2xx status
/// code, timeout, or an unparseable response body.
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({this.message = 'Error del servidor', this.statusCode});

  @override
  String toString() => 'ServerException($statusCode): $message';
}

/// Thrown by a local datasource when reading/writing cached data fails.
class CacheException implements Exception {
  final String message;

  const CacheException({this.message = 'Error de almacenamiento local'});

  @override
  String toString() => 'CacheException: $message';
}
