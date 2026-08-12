import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class ApplyPromoCode implements UseCase<Cart, ApplyPromoCodeParams> {
  final CartRepository repository;

  const ApplyPromoCode(this.repository);

  @override
  ResultFuture<Cart> call(ApplyPromoCodeParams params) {
    return repository.applyPromoCode(params.code);
  }
}

class ApplyPromoCodeParams extends Equatable {
  final String code;

  const ApplyPromoCodeParams(this.code);

  @override
  List<Object?> get props => [code];
}
