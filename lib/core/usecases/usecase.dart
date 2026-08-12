import 'package:equatable/equatable.dart';

import '../utils/typedefs.dart';

/// Contract every use case in the app must implement.
///
/// [ReturnType] is what the use case returns on success, [Params] is the
/// input it needs. A use case is the only thing Presentation is allowed
/// to call: it never talks to a repository or a datasource directly.
abstract class UseCase<ReturnType, Params> {
  const UseCase();

  ResultFuture<ReturnType> call(Params params);
}

/// Use for use cases that don't need any input (e.g. "get current cart").
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
