import '../../../../core/persistence/objectbox_store.dart';
import '../../../../objectbox.g.dart';
import '../entities/cart_item_entity.dart';
import '../entities/cart_promo_entity.dart';


abstract class CartLocalDataSource {
  List<CartItemEntity> getItems();

  void upsertItem(CartItemEntity item);

  void updateQuantity({required int productId, required int quantity});

  void removeItem(int productId);

  void clearItems();

  CartPromoEntity? getPromo();

  void setPromo(CartPromoEntity promo);

  void clearPromo();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  CartLocalDataSourceImpl(ObjectBoxStore objectBox)
      : _items = objectBox.store.box<CartItemEntity>(),
        _promo = objectBox.store.box<CartPromoEntity>();

  final Box<CartItemEntity> _items;
  final Box<CartPromoEntity> _promo;

  @override
  List<CartItemEntity> getItems() => _items.getAll();

  @override
  void upsertItem(CartItemEntity item) {
    final existing = _findByProductId(item.productId);
    if (existing != null) {
      existing.quantity += item.quantity;
      _items.put(existing);
    } else {
      _items.put(item);
    }
  }

  @override
  void updateQuantity({required int productId, required int quantity}) {
    final existing = _findByProductId(productId);
    if (existing == null) return;
    existing.quantity = quantity;
    _items.put(existing);
  }

  @override
  void removeItem(int productId) {
    final existing = _findByProductId(productId);
    if (existing == null) return;
    _items.remove(existing.id);
  }

  @override
  void clearItems() => _items.removeAll();

  @override
  CartPromoEntity? getPromo() {
    final all = _promo.getAll();
    return all.isEmpty ? null : all.first;
  }

  @override
  void setPromo(CartPromoEntity promo) {
    _promo.removeAll();
    _promo.put(promo);
  }

  @override
  void clearPromo() => _promo.removeAll();

  CartItemEntity? _findByProductId(int productId) {
    final query = _items.query(CartItemEntity_.productId.equals(productId)).build();
    try {
      return query.findFirst();
    } finally {
      query.close();
    }
  }
}
