import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';
import '../entities/cart_item_entity.dart';
import '../entities/cart_promo_entity.dart';


const Map<String, double> _knownPromoCodes = {
  'ATELIER10': 10,
};

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;

  const CartRepositoryImpl({required this.localDataSource});

  @override
  ResultFuture<Cart> getCart() => _guard(() {});

  @override
  ResultFuture<Cart> addItem(CartItem item) {
    return _guard(() => localDataSource.upsertItem(CartItemEntity.fromDomain(item)));
  }

  @override
  ResultFuture<Cart> updateItemQuantity({required int productId, required int quantity}) {
    return _guard(
      () => localDataSource.updateQuantity(productId: productId, quantity: quantity),
    );
  }

  @override
  ResultFuture<Cart> removeItem(int productId) {
    return _guard(() => localDataSource.removeItem(productId));
  }

  @override
  ResultFuture<Cart> clearCart() {
    return _guard(() {
      localDataSource.clearItems();
      localDataSource.clearPromo();
    });
  }

  @override
  ResultFuture<Cart> applyPromoCode(String code) async {
    final normalized = code.trim().toUpperCase();
    final discount = _knownPromoCodes[normalized];
    if (discount == null) {
      // Default message only — the actual copy shown to the user comes
      // from presentation mapping this Failure's *type*, not this
      // string (see CartPage).
      return const Left(ValidationFailure());
    }
    return _guard(
      () => localDataSource.setPromo(CartPromoEntity(code: normalized, discountPercentage: discount)),
    );
  }

  @override
  ResultFuture<Cart> removePromoCode() {
    return _guard(() => localDataSource.clearPromo());
  }

  /// Runs [write] (a synchronous ObjectBox mutation, or a no-op for
  /// reads), then re-reads the store into a fresh [Cart] — every method
  /// above returns the resulting cart so callers never issue a separate
  /// `getCart()` just to see what they changed.
  ResultFuture<Cart> _guard(void Function() write) async {
    try {
      write();
      final items = localDataSource.getItems().map((entity) => entity.toDomain()).toList();
      final promo = localDataSource.getPromo()?.toDomain();
      return Right(Cart(items: items, promo: promo));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
