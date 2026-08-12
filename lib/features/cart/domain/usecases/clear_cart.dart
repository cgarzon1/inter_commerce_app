import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class ClearCart implements UseCase<Cart, NoParams> {
  final CartRepository repository;

  const ClearCart(this.repository);

  @override
  ResultFuture<Cart> call(NoParams params) => repository.clearCart();
}
