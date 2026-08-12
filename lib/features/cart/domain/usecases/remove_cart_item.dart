import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class RemoveCartItem implements UseCase<Cart, RemoveCartItemParams> {
  final CartRepository repository;

  const RemoveCartItem(this.repository);

  @override
  ResultFuture<Cart> call(RemoveCartItemParams params) => repository.removeItem(params.productId);
}

class RemoveCartItemParams extends Equatable {
  final int productId;

  const RemoveCartItemParams(this.productId);

  @override
  List<Object?> get props => [productId];
}
