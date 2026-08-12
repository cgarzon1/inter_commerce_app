import 'package:objectbox/objectbox.dart';

import '../../domain/entities/cart_item.dart';


@Entity()
class CartItemEntity {
  @Id()
  int id;

  @Unique(onConflict: ConflictStrategy.replace)
  int productId;

  String title;
  String subtitle;
  String thumbnail;
  double unitPrice;
  int quantity;

  CartItemEntity({
    this.id = 0,
    required this.productId,
    required this.title,
    required this.subtitle,
    required this.thumbnail,
    required this.unitPrice,
    required this.quantity,
  });

  CartItem toDomain() => CartItem(
        productId: productId,
        title: title,
        subtitle: subtitle,
        thumbnail: thumbnail,
        unitPrice: unitPrice,
        quantity: quantity,
      );

  factory CartItemEntity.fromDomain(CartItem item, {int id = 0}) => CartItemEntity(
        id: id,
        productId: item.productId,
        title: item.title,
        subtitle: item.subtitle,
        thumbnail: item.thumbnail,
        unitPrice: item.unitPrice,
        quantity: item.quantity,
      );
}
