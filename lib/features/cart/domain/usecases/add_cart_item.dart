import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../products/domain/entities/product.dart';
import '../entities/cart.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';


class AddCartItem implements UseCase<Cart, AddCartItemParams> {
  final CartRepository repository;

  const AddCartItem(this.repository);

  @override
  ResultFuture<Cart> call(AddCartItemParams params) {
    final product = params.product;
    final item = CartItem(
      productId: product.id,
      title: product.title,
      subtitle: product.brand.isNotEmpty ? product.brand : product.category,
      thumbnail: product.thumbnail,
      unitPrice: product.discountedPrice,
      quantity: params.quantity,
    );
    return repository.addItem(item);
  }
}

class AddCartItemParams extends Equatable {
  final Product product;
  final int quantity;

  const AddCartItemParams({required this.product, this.quantity = 1});

  @override
  List<Object?> get props => [product, quantity];
}
