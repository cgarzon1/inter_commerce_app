import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class RemovePromoCode implements UseCase<Cart, NoParams> {
  final CartRepository repository;

  const RemovePromoCode(this.repository);

  @override
  ResultFuture<Cart> call(NoParams params) => repository.removePromoCode();
}
