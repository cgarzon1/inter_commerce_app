import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_totals.dart';

enum CartStatus { loading, loaded, error }

class CartState extends Equatable {
  const CartState({
    this.status = CartStatus.loading,
    this.cart = const Cart(),
    this.totals,
    this.failure,
    this.promoError,
  });

  final CartStatus status;
  final Cart cart;


  final CartTotals? totals;

  final Failure? failure;

  final Failure? promoError;

  CartState copyWith({
    CartStatus? status,
    Cart? cart,
    CartTotals? totals,
    Failure? failure,
    Failure? promoError,
    bool clearPromoError = false,
  }) {
    return CartState(
      status: status ?? this.status,
      cart: cart ?? this.cart,
      totals: totals ?? this.totals,
      failure: failure,
      promoError: clearPromoError ? null : (promoError ?? this.promoError),
    );
  }

  @override
  List<Object?> get props => [status, cart, totals, failure, promoError];
}
