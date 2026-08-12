import '../../../../core/utils/typedefs.dart';
import '../entities/cart.dart';
import '../entities/cart_item.dart';


abstract class CartRepository {
  ResultFuture<Cart> getCart();

  ResultFuture<Cart> addItem(CartItem item);

  ResultFuture<Cart> updateItemQuantity({required int productId, required int quantity});

  ResultFuture<Cart> removeItem(int productId);

  ResultFuture<Cart> clearCart();

  ResultFuture<Cart> applyPromoCode(String code);

  ResultFuture<Cart> removePromoCode();
}
