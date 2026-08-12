import 'package:equatable/equatable.dart';

/// Base class for every domain-level failure.
///
/// The Domain layer never throws or catches raw exceptions coming from the
/// Data layer: repositories translate those exceptions into a [Failure] and
/// return it wrapped in `Either<Failure, T>`. Presentation only ever reacts
/// to [Failure] subtypes, never to exceptions.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// The remote API responded with an error (4xx/5xx) or the request could
/// not be completed (timeout, malformed response, etc).
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error del servidor']);
}

/// Something went wrong reading/writing local persistence (DB, prefs, etc).
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error de almacenamiento local']);
}

/// There is no network connectivity to perform the operation.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a internet']);
}

/// Input provided by the caller did not pass validation before reaching
/// the network (e.g. an empty search query).
class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Datos inválidos']);
}

/// Fallback for anything unexpected that doesn't fit the categories above.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Ha ocurrido un error inesperado']);
}
