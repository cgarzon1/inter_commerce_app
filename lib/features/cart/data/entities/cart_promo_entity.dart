import 'package:objectbox/objectbox.dart';

import '../../domain/entities/cart_promo.dart';

@Entity()
class CartPromoEntity {
  @Id()
  int id;

  String code;
  double discountPercentage;

  CartPromoEntity({
    this.id = 0,
    required this.code,
    required this.discountPercentage,
  });

  CartPromo toDomain() => CartPromo(code: code, discountPercentage: discountPercentage);

  factory CartPromoEntity.fromDomain(CartPromo promo) => CartPromoEntity(
        code: promo.code,
        discountPercentage: promo.discountPercentage,
      );
}
