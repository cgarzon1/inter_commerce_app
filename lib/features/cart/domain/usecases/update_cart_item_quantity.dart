import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class UpdateCartItemQuantity implements UseCase<Cart, UpdateCartItemQuantityParams> {
  final CartRepository repository;

  const UpdateCartItemQuantity(this.repository);

  @override
  ResultFuture<Cart> call(UpdateCartItemQuantityParams params) {
    return repository.updateItemQuantity(productId: params.productId, quantity: params.quantity);
  }
}

class UpdateCartItemQuantityParams extends Equatable {
  final int productId;
  final int quantity;

  const UpdateCartItemQuantityParams({required this.productId, required this.quantity});

  @override
  List<Object?> get props => [productId, quantity];
}
