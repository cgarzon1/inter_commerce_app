import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../products/domain/entities/product.dart';
import '../../domain/entities/cart.dart';
import '../../domain/usecases/add_cart_item.dart';
import '../../domain/usecases/apply_promo_code.dart';
import '../../domain/usecases/calculate_cart_totals.dart';
import '../../domain/usecases/get_cart.dart';
import '../../domain/usecases/remove_cart_item.dart';
import '../../domain/usecases/remove_promo_code.dart';
import '../../domain/usecases/update_cart_item_quantity.dart';
import 'cart_state.dart';


class CartCubit extends Cubit<CartState> {
  CartCubit({
    required this.getCart,
    required this.addCartItem,
    required this.updateCartItemQuantity,
    required this.removeCartItem,
    required this.applyPromoCode,
    required this.removePromoCode,
    required this.calculateCartTotals,
  }) : super(const CartState());

  final GetCart getCart;
  final AddCartItem addCartItem;
  final UpdateCartItemQuantity updateCartItemQuantity;
  final RemoveCartItem removeCartItem;
  final ApplyPromoCode applyPromoCode;
  final RemovePromoCode removePromoCode;
  final CalculateCartTotals calculateCartTotals;

  Future<void> load() async {
    emit(state.copyWith(status: CartStatus.loading));
    await _apply(getCart(const NoParams()));
  }

  Future<void> addProduct(Product product, {int quantity = 1}) {
    return _apply(addCartItem(AddCartItemParams(product: product, quantity: quantity)));
  }

  Future<void> changeQuantity(int productId, int quantity) {
    return _apply(
      updateCartItemQuantity(UpdateCartItemQuantityParams(productId: productId, quantity: quantity)),
    );
  }

  Future<void> removeProduct(int productId) {
    return _apply(removeCartItem(RemoveCartItemParams(productId)));
  }

  Future<void> applyPromo(String code) async {
    final result = await applyPromoCode(ApplyPromoCodeParams(code));
    await result.fold(
      (failure) async => emit(state.copyWith(promoError: failure)),
      (cart) => _onCartChanged(cart, clearPromoError: true),
    );
  }

  Future<void> removePromo() {
    return _apply(removePromoCode(const NoParams()));
  }

  /// Shared tail for every mutation: emit the fresh [Cart], then
  /// recompute totals from it. [ApplyPromoCode] doesn't run through
  /// here directly because a *failed* code shouldn't clear
  /// [CartState.promoError] the way a successful one should.
  Future<void> _apply(Future<Either<Failure, Cart>> call) async {
    final result = await call;
    await result.fold(
      (failure) async => emit(state.copyWith(status: CartStatus.error, failure: failure)),
      (cart) => _onCartChanged(cart, clearPromoError: true),
    );
  }

  Future<void> _onCartChanged(Cart cart, {required bool clearPromoError}) async {
    emit(state.copyWith(status: CartStatus.loaded, cart: cart, clearPromoError: clearPromoError));

    final totalsResult = await calculateCartTotals(cart);
    totalsResult.fold(
      (_) {}, // pure computation — practically never fails
      (totals) => emit(state.copyWith(totals: totals)),
    );
  }
}
