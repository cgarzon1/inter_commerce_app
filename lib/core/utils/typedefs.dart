import 'package:fpdart/fpdart.dart';

import '../error/failures.dart';


typedef ResultFuture<T> = Future<Either<Failure, T>>;

typedef JSON = Map<String, dynamic>;
